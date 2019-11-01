<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to handle tables.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!--
  Generate a PSML `table` from a `w:tbl` element.
-->
<xsl:template match="w:tbl" mode="content" as="element(table)">
  <table>
    <xsl:if test="w:tblPr/w:tblStyle/@w:val!=''">
      <!-- if the table has a style name, create the style attribute -->
      <xsl:attribute name="role">
        <xsl:value-of select="w:tblPr/w:tblStyle/@w:val" />
      </xsl:attribute>
    </xsl:if>

    <xsl:if test="w:tblPr/w:tblW/@w:w!='' and w:tblPr/w:tblW/@w:type != 'auto'">
      <xsl:attribute name="width">
        <xsl:value-of select="if(w:tblPr/w:tblW/@w:type = 'pct') then format-number((number(w:tblPr/w:tblW/@w:w) idiv 5000), '#%') else (number(w:tblPr/w:tblW/@w:w) idiv 15)" />
      </xsl:attribute>
    </xsl:if>

    <xsl:if test="w:tblPr/w:tblCaption/@w:val!='' or w:tblPr/w:tblDescription/@w:val!=''">
      <xsl:attribute name="summary">
        <xsl:value-of select="if(w:tblPr/w:tblCaption/@w:val!='') then w:tblPr/w:tblCaption/@w:val else w:tblPr/w:tblDescription/@w:val" />
      </xsl:attribute>
    </xsl:if>

    <xsl:variable name="style-name" select="preceding-sibling::*[1][name() = 'w:p']/w:pPr/w:pStyle/@w:val"/>
    <xsl:if test="(not(w:tblPr/w:tblStyle/@w:val) and preceding-sibling::*[1][name() = 'w:p'] and config:get-caption-table-value($style-name) = 'default')
                          or  (w:tblPr/w:tblStyle/@w:val= config:get-caption-table-value($style-name) and  preceding-sibling::*[1][name() = 'w:p'] and config:get-caption-table-value($style-name) != '' )">

      <caption><xsl:value-of select="preceding-sibling::*[1][name() = 'w:p']//text()"/></caption>
    </xsl:if>

    <xsl:variable name="number-of-columns" select="count(w:tr[1]/w:tc[not(w:tcPr/w:gridSpan)]) +  + sum(w:tr[1]/w:tc/w:tcPr/w:gridSpan/@w:val)"/>

    <xsl:variable name="current-table" select="current()"/>

    <xsl:variable name="total-width" select="number(sum(w:tblGrid/w:gridCol/@w:w))" />

    <xsl:variable name="columns-width">
      <cols>
      <xsl:for-each select="w:tblGrid/w:gridCol">
        <xsl:variable name="value-width" select="(number(@w:w) div $total-width) * number(100)" />
        <xsl:variable name="content" select="concat(substring(string($value-width),1,2),'%')" />
        <col><xsl:value-of select="$content" /></col>
      </xsl:for-each>
      </cols>
    </xsl:variable>

    <xsl:for-each select="1 to xs:integer($number-of-columns)">
      <xsl:variable name="pos" select="position()" />
      <col width="{$columns-width/cols/col[position() = $pos]}">
        <xsl:if test=".=1 and $current-table/w:tblPr/w:tblLook/@w:firstColumn='1'">
          <xsl:attribute name="part" select="'header'"/>
        </xsl:if>
        <xsl:if test="$number-of-columns !=1  and .=$number-of-columns and $current-table/w:tblPr/w:tblLook/@w:lastColumn='1'">
          <xsl:attribute name="part" select="'footer'"/>
        </xsl:if>
      </col>
    </xsl:for-each>
    <xsl:if test="count(w:tr) = 0">
      <row>
        <cell/>
      </row>
    </xsl:if>

    <xsl:apply-templates select="w:tr" mode="content" />
  </table>
</xsl:template>

<!--
  Generate a PSML row from a Word `w:tr` element.
-->
<xsl:template match="w:tr" mode="content" as="element(row)">
  <row>
    <xsl:if test="w:trPr/w:tblHeader or (position() = 1 and ancestor::w:tbl[1]/w:tblPr/w:tblLook/@w:firstRow = '1')">
      <xsl:attribute name="part" select="'header'"/>
    </xsl:if>
    <xsl:if test="position() = last() and not(position() = 1) and ancestor::w:tbl[1]/w:tblPr/w:tblLook/@w:lastRow = '1'">
      <xsl:attribute name="part" select="'footer'"/>
    </xsl:if>
    <xsl:apply-templates select="w:tc" mode="content" />
    <xsl:if test="count(w:tc) = 0">
      <cell />
    </xsl:if>
  </row>
</xsl:template>

<!-- 
  Generate a PSML cell from a Word `w:tc` element if possible.
  (handles table cells and calculates corresponding rowspans and colspans)
-->
<xsl:template match="w:tc" mode="content">
  <xsl:choose>
    <xsl:when test="w:tcPr/w:vMerge[not(@w:val)]"/>
    <xsl:otherwise>
      <cell>
        <xsl:if test="w:tcPr/w:gridSpan">
          <xsl:attribute name="colspan" select="w:tcPr/w:gridSpan/@w:val" />
        </xsl:if>
        <xsl:if test="w:p/w:pPr/w:jc/@w:val !=''">
          <xsl:attribute name="align" select="if ((w:p/w:pPr/w:jc/@w:val)[1] = 'right') then 'right' else
                                              if ((w:p/w:pPr/w:jc/@w:val)[1] = 'center') then 'center' else
                                              if ((w:p/w:pPr/w:jc/@w:val)[1] = 'both') then 'justify' else 'left'" />
        </xsl:if>
        <xsl:if test="w:tcPr/w:vMerge[@w:val = 'restart']">
          <xsl:variable name="this-colnum"
            select="count(preceding-sibling::w:tc) + 1 +
                    sum(preceding-sibling::w:tc/w:tcPr/w:gridSpan/@w:val) -
                    count(preceding-sibling::w:tc/w:tcPr/w:gridSpan[@w:val])" />
          <xsl:attribute name="rowspan">
            <xsl:variable name="remainder">
              <xsl:call-template name="count-rowspan">
                <xsl:with-param name="row" select="../following-sibling::w:tr[1]" />
                <xsl:with-param name="colnum" select="$this-colnum" />
              </xsl:call-template>
            </xsl:variable>
            <xsl:value-of select="number($remainder) + 1" />
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates mode="content" />
      </cell>
    </xsl:otherwise>
  </xsl:choose>
  <!-- else, no content or merged cells -->
</xsl:template>

<!-- TODO Template below should be a function -->

<!--
  calculates the size of the rowspan
-->
<xsl:template name="count-rowspan">
  <xsl:param name="row" />
  <xsl:param name="colnum" select="0" />

  <xsl:variable name="cell"
    select="$row/w:tc[count(preceding-sibling::w:tc) + 1 +
                        sum(preceding-sibling::w:tc/w:tcPr/w:gridSpan/@w:val) -
                      count(preceding-sibling::w:tc/w:tcPr/w:gridSpan[@w:val]) = $colnum]" />
  <xsl:choose>
    <xsl:when test="not($cell)">
      <xsl:text>0</xsl:text>
    </xsl:when>
    <xsl:when test="$cell/w:tcPr/w:vMerge[not(@w:val = 'restart')]">
      <xsl:variable name="remainder">
        <xsl:call-template name="count-rowspan">
          <xsl:with-param name="row" select="$row/following-sibling::w:tr[1]" />
          <xsl:with-param name="colnum" select="$colnum" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="$remainder + 1" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>0</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Generate a PSML `hcell` element from a Word table cell `w:tc`
  (handles table heading cells and calculates corresponding colspans)
-->
<xsl:template match="w:tc" mode="hcell" as="element(hcell)">
  <hcell>
    <xsl:if test="w:tcPr/w:gridSpan">
      <xsl:attribute name="colspan" select="w:tcPr/w:gridSpan/@w:val" />
    </xsl:if>
    <xsl:apply-templates mode="content" />
  </hcell>
  <!-- else, no content or merged cells -->
</xsl:template>

</xsl:stylesheet>