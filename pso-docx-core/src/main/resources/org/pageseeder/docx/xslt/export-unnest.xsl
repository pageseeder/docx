<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to rationalise nested block-level elements prior to running the main XSLT module to convert
  the PSML into DOCX to ease processing.

  This involves:
   * wrapping text, inline-levels elements and images inside table cells and list items in paragraphs if they are
     not within a block level element
   * wrapping text or inline-levels elements inside table cells and list items in paragraphs if they are not within a
     block level element
   * Normalizes the content of preformatted blocks so that all new line characters are replaced by a line break
     element `<br/>`
   * Normalizes white spaces around `<br/>` elements

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- TODO This list is more comprehensive than the list in the global export -->
<xsl:strip-space elements="toc uri labels displaytitle properties-fragment root description property section body document documentinfo fragment list xref-fragment blockxref locator notes note content"/>

<!-- XML format: No indent to avoid affecting white-spaces -->
<xsl:output method="xml" version="1.0" indent="no" encoding="UTF-8" standalone="yes" />

<!--
  Process everything in `unnest` mode.
-->
<xsl:template match="/">
  <xsl:apply-templates select="element()|text()|comment()|processing-instruction()" mode="unnest"/>
</xsl:template>

<!--
  Copy attributes, comments and processing instructions verbatim.
-->
<xsl:template match="attribute()|comment()|processing-instruction()" mode="unnest">
  <xsl:copy-of select="."/>
</xsl:template>

<!--
  Shallow copy the element and keep processing
-->
<xsl:template match="element()" mode="unnest">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="unnest"/>
  </xsl:copy>
</xsl:template>

<!--
  Process list items and cell content to ensure that adjacent nodes which are not block-level elements are wrapped in
  a paragraph.
-->
<xsl:template match="item|cell|hcell" mode="unnest">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <!-- Word doesn't like the first node in a list item to be a table -->
    <xsl:if test="self::item and
        (node()[1][not(self::text())] or normalize-space(text()[1]) = '') and
        (.//item | .//para | .//block | .//table | .//preformat)[1][self::table]">
      <para/>
    </xsl:if>
    <!-- Adjacent text, text with double <br/>, inline elements and image must be wrapped -->
    <xsl:for-each-group select="node()"
                        group-adjacent="if  (self::list or self::nlist or self::para or self::block
                                          or self::table or self::blockxref or self::preformat
                                          or (self::br and following-sibling::*[1][self::br] and
                                              normalize-space(following-sibling::node()[1]) = '')
                                          or (self::br and preceding-sibling::*[1][self::br] and
                                              normalize-space(preceding-sibling::node()[1]) = ''))
                                        then 2
                                        else 1">
      <xsl:choose>
        <!-- Wrap adjacent nodes if they have elements or non-whitespace (to avoid wrapping indentation in a para) -->
        <xsl:when test="current-grouping-key()=1
                   and (current-group()/self::* or normalize-space(string-join(current-group(), ' ')) != '')">
          <para>
            <xsl:apply-templates select="current-group()" mode="unnest"/>
          </para>
        </xsl:when>
        <xsl:otherwise>
          <!-- ignore double <br/> -->
          <xsl:apply-templates select="current-group()[not(self::br)]" mode="unnest"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
    <!-- Word doesn't like the last node in a cell to be a table -->
    <xsl:if test="(self::cell or self::hcell) and
        (node()[last()][not(self::text())] or normalize-space(text()[last()]) = '') and
        (.//item | .//para | .//block | .//table | .//preformat)[last()][self::table]">
      <para/>
    </xsl:if>

  </xsl:copy>
</xsl:template>

<!--
  Split para containing double <br/> into 2 <para> elements.
-->
<xsl:template match="para[br]" mode="unnest">
  <xsl:variable name="para" select="." />
  <xsl:for-each-group select="node()"
                      group-adjacent="if ((self::br and following-sibling::*[1][self::br] and
                                            normalize-space(following-sibling::node()[1]) = '')
                                        or (self::br and preceding-sibling::*[1][self::br] and
                                            normalize-space(preceding-sibling::node()[1]) = ''))
                                      then 2
                                      else 1">
    <!-- Wrap adjacent nodes if they have elements or non-whitespace (to avoid wrapping indentation in a para) -->
    <xsl:if test="current-grouping-key()=1
               and (current-group()/self::* or normalize-space(string-join(current-group(), ' ')) != '')">
      <para>
        <!-- copy all attributes from original para, except copy 'prefix' only for the first one -->
        <xsl:if test="position()=1">
          <xsl:copy-of select="$para/@*[name()='prefix']"/>
        </xsl:if>
        <xsl:copy-of select="$para/@*[name()!='prefix']"/>
        <xsl:apply-templates select="current-group()" mode="unnest"/>
      </para>
    </xsl:if>
  </xsl:for-each-group>
</xsl:template>

<!--
  Process block content to ensure that adjacent nodes which are not block-level elements are wrapped in a paragraph.

  Note: this differs from the item and cell processing by allowing headings to be included directly within
  a block label
-->
<xsl:template match="block" mode="unnest">
  <block>
    <xsl:copy-of select="@*"/>
    <xsl:for-each-group select="node()"
                        group-adjacent="if  (self::list or self::nlist or self::para or self::block
                                          or self::table or self::blockxref or self::preformat
                                          or self::heading)
                                        then 2
                                        else 1">
      <xsl:choose>
        <!-- wrap adjacent nodes if they have elements or non-whitespace -->
        <xsl:when test="current-grouping-key() = 1
                   and (current-group()/self::* or normalize-space(string-join(current-group(), ' ')) != '')">
          <para>
            <xsl:apply-templates select="current-group()" mode="unnest"/>
          </para>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="current-group()" mode="unnest"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </block>
</xsl:template>

<!-- check fir breaks in text and handle whitespace-->
<xsl:template match="text()" mode="unnest">
  <xsl:choose>
    <xsl:when test="preceding-sibling::*[1]/name() = 'br' and substring(replace(.,'[\s]+',' '),1,1) = ' '">
      <xsl:value-of select="substring(replace(.,'[\s]+',' '),2,string-length(replace(.,'[\s]+',' ')))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="replace(.,'[\s]+',' ')"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Replace new line characters by a line break element `<br/>`  -->
<xsl:template match="preformat/text()[. != '&#xA;']" mode="unnest">
  <xsl:for-each select="tokenize(.,'&#xA;')">
    <xsl:sequence select="."/>
    <xsl:if test="not(position() eq last())">
      <br/>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
