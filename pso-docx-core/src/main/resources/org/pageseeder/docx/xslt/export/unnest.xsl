<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to rationalise nested block-level elements

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- TODO This list is more comprehensive than the list in the global export -->
<xsl:strip-space elements="toc uri labels displaytitle properties-fragment root description property section body document documentinfo fragment list xref-fragment blockxref locator notes note content"/>

<xsl:output encoding="UTF-8" method="xml" indent="no"/>

<!-- TODO We should use a mode so that this template can be mixed with others-->

<!-- match root element -->
<xsl:template match="/">
  <xsl:apply-templates select="element()|text()|comment()|processing-instruction()"/>
</xsl:template>

<!-- generic copy -->
<xsl:template match="attribute()|comment()|processing-instruction()">
  <xsl:copy>
    <xsl:apply-templates select="comment()|processing-instruction()"/>
  </xsl:copy>
</xsl:template>

<!-- generic copy  -->
<xsl:template match="element()">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>

<!-- wrap item content in para -->
<xsl:template match="item">
  <item>
    <!-- inline elements and image must be wrapped -->
    <xsl:for-each-group select="node()"
                        group-adjacent="if (self::list or self::nlist or self::para
                                          or self::block or self::table or self::blockxref or self::preformat)
                                        then 2
                                        else 1">
      <xsl:choose>
        <!-- wrap adjacent nodes if they have elements or non-whitespace -->
        <xsl:when test="current-grouping-key()=1 and
          (current-group()/self::* or normalize-space(string-join(current-group(), ' ')) != '')">
          <para>
            <xsl:apply-templates select="current-group()"/>
          </para>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="current-group()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </item>
</xsl:template>

<!-- wrap cell and hcell content in para  -->
<xsl:template match="cell|hcell">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <!-- inline elements and image must be wrapped -->
    <xsl:for-each-group select="node()"
                        group-adjacent="if  (self::list or self::nlist or self::para
                      or self::block or self::table or self::blockxref or self::preformat)
                    then 2
                    else 1">
      <xsl:choose>
        <!-- wrap adjacent nodes if they have elements or non-whitespace -->
        <xsl:when test="current-grouping-key()=1 and
          (current-group()/self::* or normalize-space(string-join(current-group(), ' ')) != '')">
          <para>
            <xsl:apply-templates select="current-group()"/>
          </para>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="current-group()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:copy>
</xsl:template>

<!-- wrap block content in para -->
<xsl:template match="block">
  <block>
    <xsl:copy-of select="@*"/>
    <xsl:for-each-group select="node()"
                        group-adjacent="if  (self::list or self::nlist or self::para
                                          or self::block or self::table or self::blockxref  or self::preformat
                                          or self::heading or self::image)
                                        then 2
                                        else 1">
      <xsl:choose>
        <!-- wrap adjacent nodes if they have elements or non-whitespace -->
        <xsl:when test="current-grouping-key()=1 and
          (current-group()/self::* or normalize-space(string-join(current-group(), ' ')) != '')">
          <para>
            <xsl:apply-templates select="current-group()"/>
          </para>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="current-group()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </block>
</xsl:template>

<!-- check fir breaks in text and handle whitespace-->
<xsl:template match="text()">
  <xsl:choose>
    <xsl:when test="preceding-sibling::*[1]/name() = 'br' and substring(replace(.,'[\s]+',' '),1,1) = ' '">
      <xsl:value-of select="substring(replace(.,'[\s]+',' '),2,string-length(replace(.,'[\s]+',' ')))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="replace(.,'[\s]+',' ')"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- match test inside of preformat -->
<xsl:template match="preformat/text()[. != '&#xA;']">
  <xsl:for-each select="tokenize(.,'&#xA;')">
    <xsl:sequence select="."/>
    <xsl:if test="not(position() eq last())">
      <br/>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
