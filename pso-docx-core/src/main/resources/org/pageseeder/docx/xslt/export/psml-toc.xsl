<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT modules for the Table of Contents (TOC)

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio

  @version 0.6.0
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!--
  Handle Table of Contents (`toc`) marker.

  Create initial toc paragraphs only if the `$create-toc` global variable is `true`.
-->
<xsl:template match="toc[not(preceding::toc)]" mode="psml">
  <xsl:if test="config:generate-toc()">
    <xsl:variable name="toc-text">
      <xsl:text>TOC </xsl:text>
      <xsl:if test="config:generate-toc-headings() and config:toc-heading-values() != ''">
        <xsl:text>\o "</xsl:text><xsl:value-of select="config:toc-heading-values()"/><xsl:text>" </xsl:text>
      </xsl:if>
      <xsl:if test="config:generate-toc-outline() and config:toc-outline-values() != ''">
        <xsl:text>\u "</xsl:text><xsl:value-of select="config:toc-outline-values()"/><xsl:text>" </xsl:text>
      </xsl:if>
      <xsl:if test="config:generate-toc-paragraphs()">
       <xsl:text>\t "</xsl:text><xsl:value-of select="config:toc-paragraph-values()"/><xsl:text>" </xsl:text>
      </xsl:if>
    </xsl:variable>
    <w:p>
      <w:r>
        <w:fldChar w:fldCharType="begin" w:dirty="true" />
      </w:r>
      <w:r>
        <w:instrText xml:space="preserve"><xsl:value-of select="$toc-text" /></w:instrText>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="end" w:dirty="true" />
      </w:r>
    </w:p>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
