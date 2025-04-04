<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for processing PSML tables with colspan and rowspan

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!-- Template to match table. It calls a named template to create each row -->
<xsl:template match="table[.//row]" mode="psml">
  <xsl:param name="labels" tunnel="yes" />
  <!-- Caption goes before the table in WordProcessingML-->
  <xsl:if test="caption">
    <w:p>
      <w:pPr>
        <w:pStyle w:val="Tablecaption" />
      </w:pPr>
      <xsl:apply-templates select="caption" mode="psml" />
    </w:p>
  </xsl:if>

  <w:tbl>
    <w:tblPr>
      <xsl:choose>

        <!-- Table with role AND document label -->
        <xsl:when test="config:table-roles-with-document-label($labels, @role) != ''">
          <w:tblStyle w:val="{config:table-roles-with-document-label(@role, $labels)}" />
          <xsl:if test="config:table-roles-with-document-label-type($labels, @role) != ''">
            <w:tblW>
              <xsl:choose>
                <xsl:when test="config:table-roles-with-document-label-type-value($labels, @role) != ''">
                  <xsl:attribute name="w:w" select="config:table-roles-with-document-label-type-value($labels, @role)"/>
                  <xsl:attribute name="w:type" select="config:table-roles-with-document-label-type($labels, @role)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="fn:table-set-width-value(.)"/>
                </xsl:otherwise>
              </xsl:choose>
            </w:tblW>
          </xsl:if>
        </xsl:when>

        <!-- Table with document label -->
        <xsl:when test="config:default-table-style-with-document-label($labels) != ''">
          <w:tblStyle w:val="{config:default-table-style-with-document-label($labels)}" />
          <xsl:if test="config:default-table-style-with-document-label-type($labels) != ''">
            <w:tblW>
              <xsl:choose>
                <xsl:when test="config:default-table-style-with-document-label-type-value($labels) != ''">
                  <xsl:attribute name="w:w" select="config:default-table-style-with-document-label-type-value($labels)"/>
                  <xsl:attribute name="w:type" select="config:default-table-style-with-document-label-type($labels)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="fn:table-set-width-value(.)"/>
                </xsl:otherwise>
              </xsl:choose>
            </w:tblW>
          </xsl:if>
        </xsl:when>

        <!-- Table with role -->
        <xsl:when test="config:default-table-roles(@role) != ''">
          <w:tblStyle w:val="{config:default-table-roles(@role)}" />
          <xsl:if test="config:default-table-roles-type(@role) != ''">
             <w:tblW>
              <xsl:choose>
                <xsl:when test="config:default-table-roles-type-value(@role) != ''">
                  <xsl:attribute name="w:w" select="config:default-table-roles-type-value(@role)"/>
                  <xsl:attribute name="w:type" select="config:default-table-roles-type(@role)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="fn:table-set-width-value(.)"/>
                </xsl:otherwise>
              </xsl:choose>
            </w:tblW>
          </xsl:if>
        </xsl:when>

        <!-- Default table -->
        <xsl:when test="config:default-table-style() != ''">
          <w:tblStyle w:val="{config:default-table-style()}" />
          <xsl:if test="config:default-table-style-type() != ''">
            <w:tblW>
              <xsl:choose>
                <xsl:when test="config:default-table-style-type-value() != ''">
                  <xsl:attribute name="w:w" select="config:default-table-style-type-value()"/>
                  <xsl:attribute name="w:type" select="config:default-table-style-type()"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="fn:table-set-width-value(.)"/>
                </xsl:otherwise>
              </xsl:choose>
            </w:tblW>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <w:tblBorders>
            <w:top w:val="single" w:sz="4" w:space="0" w:color="auto" />
            <w:left w:val="single" w:sz="4" w:space="0" w:color="auto" />
            <w:bottom w:val="single" w:sz="4" w:space="0" w:color="auto" />
            <w:right w:val="single" w:sz="4" w:space="0" w:color="auto" />
            <w:insideH w:val="single" w:sz="4" w:space="0" w:color="auto" />
            <w:insideV w:val="single" w:sz="4" w:space="0" w:color="auto" />
          </w:tblBorders>
          <w:tblW>
            <xsl:sequence select="fn:table-set-width-value(.)"/>
          </w:tblW>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="layout" select="config:table-layout($labels, @role)" />
      <xsl:if test="$layout != ''">
        <w:tblLayout w:type="{$layout}"/>
      </xsl:if>
      <!-- TODO There is already a condition for caption above -->
      <xsl:if test="caption">
        <w:tblCaption w:val="{caption}"/>
      </xsl:if>
      <xsl:if test="@summary">
        <w:tblDescription w:val="{@summary}"/>
      </xsl:if>
      <!-- Required to correctly format header/footer columns/rows -->
      <w:tblLook w:firstRow="{if(row[1][@part = 'header']) then 1 else 0}"
                 w:lastRow="{if(row[last()][@part = 'footer']) then 1 else 0}"
                 w:firstColumn="{if(col[1][@part = 'header']) then 1 else 0}"
                 w:lastColumn="{if(col[last()][@part = 'footer']) then 1 else 0}"/>
    </w:tblPr>
    <xsl:variable name="max-columns" select="count(row[1]/*[name() = 'cell' or 'hcell'][not(@colspan)]) + sum(row[1]/*[name() = 'cell' or 'hcell'][@colspan]/@colspan) cast as xs:integer" />

    <!-- tblGrid is only used when <w:tblLayout w:type="fixed"/>
    <xsl:if test="col[@width]">
      <xsl:variable name="total-width" select="if (@width) then fn:table-width-dxa(@width) else '5000'" />
      <w:tblGrid>
        <xsl:for-each select="col">
          <w:gridCol>
            <xsl:attribute name="w:w">
              <xsl:analyze-string regex="([\d|\.]+)(%|px)?" select="@width">
                <xsl:matching-substring>
                  <xsl:choose>
                    <xsl:when test="regex-group(2) = '%'">
                      <xsl:value-of select="floor(number($total-width) * number(regex-group(1)) div 100)" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="number(regex-group(1)) * 15" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:matching-substring>
                <!- - this shouldn't happen - ->
                <xsl:non-matching-substring>200</xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:attribute>
          </w:gridCol>
        </xsl:for-each>
      </w:tblGrid>
    </xsl:if>
    -->

    <xsl:variable name="column-properties" as="element()">
      <columns>
        <xsl:for-each select="./col">
          <col>
            <xsl:choose>
              <xsl:when test="@width">
                <xsl:analyze-string regex="([\d|\.]+)(%|px)?" select="@width">
                  <xsl:matching-substring>
                    <xsl:attribute name="value" select="if(regex-group(2) = '%') then regex-group(0) else number(regex-group(1)) * 15"/>
                    <xsl:attribute name="type" select="if(regex-group(2) = '%') then 'pct' else 'dxa'"/>
                  </xsl:matching-substring>
                  <xsl:non-matching-substring>
                  </xsl:non-matching-substring>
                </xsl:analyze-string>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="value" select="0"/>
                <xsl:attribute name="type" select="'auto'"/>
              </xsl:otherwise>
            </xsl:choose>
          </col>
        </xsl:for-each>
        <xsl:copy-of select="./col" />
        <xsl:if test="$max-columns != count(col)">
          <xsl:for-each select="count(col) to $max-columns">
            <col value="0" type="auto"/>
          </xsl:for-each>
        </xsl:if>
      </columns>
    </xsl:variable>

    <xsl:call-template name="create-rows-recursively">
      <xsl:with-param name="row-position" select="1" />
      <xsl:with-param name="previous-position" select="0" />
      <xsl:with-param name="previous-row" select="(.//row)[1]" as="element()" />
      <xsl:with-param name="row" select="(.//row)[1]" as="node()" />
      <xsl:with-param name="column-properties" select="$column-properties" as="element()" />
    </xsl:call-template>
  </w:tbl>
</xsl:template>

<!--
  Template that creates each row recursively.

  It calls a template to calculate the preceding row's colspans and rowspans
-->
<xsl:template name="create-rows-recursively">
  <xsl:param name="labels" tunnel="yes" />
  <xsl:param name="row-position" />
  <xsl:param name="previous-position" />
  <xsl:param name="previous-row" as="element()" />
  <xsl:param name="row" as="node()" />
  <xsl:param name="column-properties" as="element()" />

  <xsl:variable name="current" select="$row" />

  <w:tr>
    <w:trPr>
      <xsl:if test="$row/@part='header'">
        <!-- Note that headers will not repeat if there is not room for them due to <w:cantSplit/> -->
        <w:tblHeader/>
      </xsl:if>
      <xsl:variable name="row-config" select="config:table-row($labels,$row/@role)" />
      <xsl:if test="$row-config/@cantsplit='true'">
        <w:cantSplit/>
      </xsl:if>
      <xsl:if test="$row-config/@align">
        <w:jc w:val="{$row-config/@align}"/>
      </xsl:if>
      <xsl:if test="$row-config/height">
        <w:trHeight w:val="{$row-config/height/@value}"
                     w:hRule="{if ($row-config/height/@type='exact') then 'exact' else 'atLeast'}"/>
      </xsl:if>
    </w:trPr>
    <xsl:choose>
      <xsl:when test="$previous-position = 0">
        <xsl:for-each select="$row/*[name() = 'cell' or 'hcell']">
          <xsl:variable name="position" select="xs:integer(count(preceding-sibling::*[not(@colspan)]) +
              sum(preceding-sibling::*/@colspan) + 1)"/>
          <w:tc>
            <w:tcPr>
              <xsl:call-template name="add-cell-properties">
                <xsl:with-param name="labels"            select="$labels" tunnel="yes"/>
                <xsl:with-param name="cell"              select="."/>
                <xsl:with-param name="position"          select="$position"/>
                <xsl:with-param name="column-properties" select="$column-properties"/>
              </xsl:call-template>
            </w:tcPr>
            <xsl:choose>
              <!-- when contains mixed content -->
              <xsl:when test="para or block or preformat or nlist or list or heading">
                <xsl:apply-templates mode="psml">
                   <xsl:with-param name="cell-align" select="fn:return-word-cell-alignment(@align)" tunnel="yes"/>
                </xsl:apply-templates>
              </xsl:when>
              <!-- If no content, generate a dummy paragraph anyway -->
              <xsl:when test="not(child::*) and normalize-space(.) = ''">
                <w:p>
                  <w:pPr>
                    <xsl:call-template name="apply-style" />
                  </w:pPr>
                </w:p>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates mode="psml" >
                   <xsl:with-param name="cell-align" select="fn:return-word-cell-alignment(@align)" tunnel="yes"/>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </w:tc>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$previous-row/*[name() = 'cell' or 'hcell']">
          <xsl:variable name="position" select="position()"/>
          <xsl:variable name="row-position" select="
          count(preceding-sibling::*[name() = 'cell' or 'hcell'][not(number(@rowspan) gt 1)]) + (if(.[not(number(@rowspan) gt 1)]) then 1 else 0)" />
          <xsl:choose>
            <xsl:when test="number(@rowspan) gt 1">
              <xsl:choose>
                <xsl:when test="not(@colspans)">
                  <w:tc>
                    <w:tcPr>
                      <!-- <w:tcW w:w="{$column-properties/col[position() = $position]/@value}" w:type="{$column-properties/col[position() = $position]/@type}" /> -->
                      <w:vMerge />
                    </w:tcPr>
                    <w:p />
                  </w:tc>
                </xsl:when>
                <xsl:when test="@colspans = preceding-sibling::*/@colspans">
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="colspans-value" select="@colspans" />
                  <xsl:variable name="number-of-colspans" select="count(following-sibling::*[@colspans = $colspans-value]) + 1" />
                  <w:tc>
                    <w:tcPr>
                      <!-- <w:tcW w:w="{$column-properties/col[position() = $position]/@value}" w:type="{$column-properties/col[position() = $position]/@type}" /> -->
                      <w:gridSpan w:val="{$number-of-colspans}" />
                      <w:vMerge />
                    </w:tcPr>
                    <w:p />
                  </w:tc>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="$current/*[name() = 'cell' or 'hcell']">
                <xsl:variable name="current-row-position" select="count(preceding-sibling::*[name() = 'cell' or 'hcell'][not(@colspan)]) + sum(preceding-sibling::*[name() = 'cell' or 'hcell'][@colspan]/@colspan) + 1" />
                <xsl:choose>
                  <xsl:when test="$row-position = $current-row-position">
                    <w:tc>
                      <w:tcPr>
                        <xsl:call-template name="add-cell-properties">
                          <xsl:with-param name="labels"            select="$labels" tunnel="yes"/>
                          <xsl:with-param name="cell"              select="."/>
                          <xsl:with-param name="position"          select="$position"/>
                          <xsl:with-param name="column-properties" select="$column-properties"/>
                        </xsl:call-template>
                      </w:tcPr>
                      <xsl:choose>
                        <!-- when contains mixed content -->
                        <xsl:when test="para or block or preformat or nlist or list or heading">
                          <xsl:apply-templates mode="psml"  >
                            <xsl:with-param name="cell-align" select="fn:return-word-cell-alignment(@align)" tunnel="yes"/>
                          </xsl:apply-templates>
                        </xsl:when>
                        <!-- If no content, generate a dummy paragraph anyway -->
                        <!-- If no content, generate a dummy paragraph anyway -->
                        <xsl:when test="not(child::*) and normalize-space(.) = ''">
                          <w:p>
                            <w:pPr>
                              <xsl:call-template name="apply-style" />
                            </w:pPr>
                          </w:p>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:apply-templates mode="psml"  >
                            <xsl:with-param name="cell-align" select="fn:return-word-cell-alignment(@align)" tunnel="yes"/>
                          </xsl:apply-templates>
                        </xsl:otherwise>
                      </xsl:choose>
                    </w:tc>
                  </xsl:when>
                  <xsl:otherwise>

                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </w:tr>

  <xsl:if test="$row/following-sibling::row[1]">
    <xsl:variable name="previous-row" as="element()">
      <xsl:call-template name="calculate-previous-row">
        <xsl:with-param name="row-position" select="count($row/following-sibling::row[1]/preceding-sibling::row)" />
        <xsl:with-param name="previous-position" select="count($row/following-sibling::row[1]/preceding-sibling::row) + 1" />
        <xsl:with-param name="previous-row" select="$previous-row" as="element()" />
        <xsl:with-param name="row" select="$row" as="node()" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="create-rows-recursively">
      <xsl:with-param name="row-position" select="count($row/following-sibling::row[1]/preceding-sibling::row) + 1" />
      <xsl:with-param name="previous-position" select="count($row/following-sibling::row[1]/preceding-sibling::row)" />
      <xsl:with-param name="previous-row" select="$previous-row" as="element()" />
      <xsl:with-param name="row" select="($row/following-sibling::row)[1]" as="node()" />
      <xsl:with-param name="column-properties" select="$column-properties" as="element()" />
    </xsl:call-template>

  </xsl:if>

</xsl:template>

<xsl:template name="add-cell-properties">
  <xsl:param name="labels" tunnel="yes" />
  <xsl:param name="cell" as="element()"/>
  <xsl:param name="position" as="xs:integer"/>
  <xsl:param name="column-properties" as="element()"/>

  <xsl:variable name="cell-config" select="if (name($cell) = 'hcell') then
      config:table-hcell($labels, $cell/@role) else config:table-cell($labels, $cell/@role)" />
  <xsl:variable name="row-config" select="config:table-row($labels, $cell/../@role)" />
  <xsl:variable name="col-config" select="config:table-col($labels, $cell/../../col[position() = $position]/@role)" />

  <xsl:if test="$cell/@colspan">
    <w:gridSpan w:val="{$cell/@colspan}" />
  </xsl:if>
  <xsl:if test="$cell/@rowspan">
    <w:vMerge w:val="restart" />
  </xsl:if>

  <xsl:if test="$cell-config/@valign">
    <w:vAlign w:val="{$cell-config/@valign}" />
  </xsl:if>

  <!-- For width use cell config then row config then col attributes -->
  <xsl:variable name="width-config" select="if ($cell-config/width) then $cell-config/width
      else if ($row-config/width) then $row-config/width else $column-properties/col[position() = $position]" />
  <w:tcW w:w="{$width-config/@value}" w:type="{$width-config/@type}" />

  <!-- For shading use cell config then row config then col config -->
  <xsl:variable name="shading-config" select="if ($cell-config/shading) then $cell-config/shading
      else if ($row-config/shading) then $row-config/shading else $col-config/shading" />
  <xsl:if test="$shading-config/@fill">
    <w:shd w:fill="{$shading-config/@fill}" />
  </xsl:if>

  <!-- For borders use cell config then row config then col config -->
  <xsl:variable name="borders-config" select="if ($cell-config/borders) then $cell-config/borders
      else if ($row-config/borders) then $row-config/borders else $col-config/borders" />
  <xsl:if test="$borders-config">
    <w:tcBorders>
      <xsl:if test="$borders-config/top">
        <w:top w:val="{$borders-config/top/@type}" w:color="{$borders-config/top/@color}" w:sz="{$borders-config/top/@size}" />
      </xsl:if>
      <xsl:if test="$borders-config/bottom">
        <w:bottom w:val="{$borders-config/bottom/@type}" w:color="{$borders-config/bottom/@color}" w:sz="{$borders-config/bottom/@size}" />
      </xsl:if>
      <xsl:if test="$borders-config/start">
        <w:start w:val="{$borders-config/start/@type}" w:color="{$borders-config/start/@color}" w:sz="{$borders-config/start/@size}" />
      </xsl:if>
      <xsl:if test="$borders-config/end">
        <w:end w:val="{$borders-config/end/@type}" w:color="{$borders-config/end/@color}" w:sz="{$borders-config/end/@size}" />
      </xsl:if>
    </w:tcBorders>
  </xsl:if>
</xsl:template>

<!-- Template to normalize the preceding row colspans and rowspans -->
<xsl:template name="calculate-previous-row">
  <xsl:param name="row-position" />
  <xsl:param name="previous-position" />
  <xsl:param name="previous-row" as="element()" />
  <xsl:param name="row" as="node()" />
  <xsl:choose>
    <xsl:when test="$row-position = $previous-position">
      <row>
        <xsl:copy-of select="$previous-row/*" />
      </row>
    </xsl:when>
    <xsl:when test="$row-position = 1">
      <xsl:variable name="currentRow" as="element()">
        <row>
          <xsl:for-each select="$row/*[name() = 'cell' or 'hcell']">
            <xsl:variable name="current-element" select="." />
            <xsl:choose>
              <xsl:when test="@colspan">
                <xsl:variable name="int-colspan" select="@colspan" as="xs:integer" />
                <xsl:for-each select="1 to $int-colspan">
                  <xsl:element name="{$current-element/name()}">
                    <xsl:attribute name="colspans" select="generate-id($current-element)" />
                    <xsl:if test="$current-element/@rowspan">
                      <xsl:attribute name="rowspan" select="$current-element/@rowspan" />
                    </xsl:if>
                  </xsl:element>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:element name="{$current-element/name()}">
                  <xsl:if test="$current-element/@rowspan">
                    <xsl:attribute name="rowspan" select="$current-element/@rowspan" />
                  </xsl:if>
                </xsl:element>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </row>
      </xsl:variable>

      <xsl:call-template name="calculate-previous-row">
        <xsl:with-param name="row-position" select="number($row-position) + 1" />
        <xsl:with-param name="previous-position" select="$previous-position" />
        <xsl:with-param name="previous-row" select="$currentRow" as="element()" />
        <xsl:with-param name="row" select="($row/ancestor::table[1]//row)[$row-position + 1]" as="node()" />
      </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
      <xsl:variable name="currentRow" as="element()">
        <row>
          <xsl:for-each select="$previous-row/*[name() = 'cell' or 'hcell']">
            <xsl:choose>
              <xsl:when test="number(@rowspan) gt 1">
                <xsl:variable name="current-element" select="." />
                <xsl:choose>
                  <xsl:when test="@colspan">
                    <xsl:variable name="int-colspan" select="@colspan" as="xs:integer" />

                    <xsl:for-each select="1 to $int-colspan">
                      <xsl:element name="{$current-element/name()}">
                        <xsl:attribute name="colspans" select="generate-id($current-element)" />
                        <xsl:if test="$current-element/@rowspan">
                          <xsl:attribute name="rowspan" select="number($current-element/@rowspan) - 1" />
                        </xsl:if>
                      </xsl:element>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:element name="{$current-element/name()}">
                      <xsl:if test="$current-element/@rowspan">
                        <xsl:attribute name="rowspan" select="number($current-element/@rowspan) - 1" />
                        <xsl:if test="$current-element/@colspans">
                          <xsl:attribute name="colspans" select="$current-element/@colspans" />
                        </xsl:if>
                      </xsl:if>
                    </xsl:element>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="current-row-position" select="count(preceding-sibling::*[name() = 'cell' or 'hcell'][not(number(@rowspan) gt 1)])
                                                                + sum(preceding-sibling::*[name() = 'cell' or 'hcell'][@colspan]/@colspan) + 1" />
                <xsl:for-each select="$row/*[name() = 'cell' or 'hcell']">
                  <xsl:variable name="row-position" select="count(preceding-sibling::*[name() = 'cell' or 'hcell'][not(@colspan)])
                                                          + sum(preceding-sibling::*[name() = 'cell' or 'hcell'][@colspan]/@colspan) + 1" />
                  <xsl:choose>
                    <xsl:when test="$row-position = $current-row-position">
                      <xsl:variable name="current-element" select="." />
                      <xsl:choose>
                        <xsl:when test="@colspan">
                          <xsl:variable name="int-colspan" select="@colspan" as="xs:integer" />

                          <xsl:for-each select="1 to $int-colspan">
                            <xsl:element name="{$current-element/name()}">
                              <xsl:attribute name="colspans" select="generate-id($current-element)" />
                              <xsl:if test="$current-element/@rowspan">
                                <xsl:attribute name="rowspan" select="number($current-element/@rowspan)" />
                              </xsl:if>
                            </xsl:element>
                          </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:element name="{$current-element/name()}">
                            <xsl:if test="$current-element/@rowspan">
                              <xsl:attribute name="rowspan" select="number($current-element/@rowspan)" />
                            </xsl:if>
                          </xsl:element>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>

                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </row>
      </xsl:variable>
      <xsl:call-template name="calculate-previous-row">
        <xsl:with-param name="row-position" select="number($row-position) + 1" />
        <xsl:with-param name="previous-position" select="$previous-position" />
        <xsl:with-param name="previous-row" select="$currentRow" as="element()" />
        <xsl:with-param name="row" select="($row/ancestor::table[1]/row)[$row-position + 1]" as="node()" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Caption is handled inside table -->
<xsl:template match="caption" mode="psml">
  <xsl:apply-templates mode="psml"/>
</xsl:template>

</xsl:stylesheet>
