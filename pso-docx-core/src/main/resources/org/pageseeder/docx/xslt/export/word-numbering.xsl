<?xml version="1.0"?>
<!--
  This XSLT module creates the `numbering.xml`

  @author Christine Feng
  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                exclude-result-prefixes="#all">

<!-- Match root of the `numbering.xml` from the template -->
<xsl:template match="/" mode="numbering">
  <xsl:apply-templates mode="numbering" />
</xsl:template>

<!--
  Copy numbering definitions from `numbering.xml` and create new numbering definitions according to the existing
  lists in the PSML document
-->
<xsl:template match="w:numbering" mode="numbering">
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <!-- <xsl:comment><xsl:apply-templates select="$all-different-lists" mode="xml"/></xsl:comment> -->
    <xsl:apply-templates select="*[name() = 'w:abstractNum']" mode="numbering" />
    <xsl:apply-templates select="*[name() = 'w:num']" mode="numbering" />
    <xsl:for-each select="$all-different-lists/nlist">
      <xsl:variable name="start-number" select="if (@start != '') then @start else '1'"/>
      <w:num w:numId="{$max-list-num-id + position()}">
        <w:abstractNumId w:val="{if (. != '') then . else 1}" />
        <xsl:variable name="current-level" select="@level"/>
        <xsl:variable name="levels" select="'0,1,2,3,4,5,6,7,8'"/>
        <xsl:for-each select="tokenize($levels, ',')">
          <xsl:choose>
            <xsl:when test=". = $current-level">
              <w:lvlOverride w:ilvl="{.}">
                <w:startOverride w:val="{$start-number}"/>
              </w:lvlOverride>
            </xsl:when>
            <xsl:otherwise>
              <w:lvlOverride w:ilvl="{.}">
                <w:startOverride w:val="1"/>
              </w:lvlOverride>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </w:num>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

<!-- Copy each numbering node recursively -->
<xsl:template match="@*|node()" mode="numbering">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="numbering" />
    <xsl:apply-templates mode="numbering" />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
