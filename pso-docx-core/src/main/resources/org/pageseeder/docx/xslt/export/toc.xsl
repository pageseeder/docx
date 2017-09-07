<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
                xmlns:o="urn:schemas-microsoft-com:office:office"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
                xmlns:v="urn:schemas-microsoft-com:vml"
                xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
                xmlns:w10="urn:schemas-microsoft-com:office:word"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
                xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
                xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                xmlns:fn="http://www.pageseeder.com/function" xmlns:dec="java:java.net.URLDecoder"
                exclude-result-prefixes="#all">

<!--
  Handle Table of Contents (`toc`) marker.

  Create initial toc paragraphs only if the `$create-toc` global variable is `true`.
-->
<xsl:template match="toc" mode="content">
  <xsl:choose>
    <xsl:when test="$create-toc">
      <xsl:variable name="toc-text">
        <xsl:text>TOC </xsl:text>
        <xsl:if test="$generate-toc-headings and $toc-heading-values != ''">
          <xsl:text>\o "</xsl:text><xsl:value-of select="$toc-heading-values"/><xsl:text>" </xsl:text>
        </xsl:if>
        <xsl:if test="$generate-toc-outline and $toc-outline-values != ''">
          <xsl:text>\u "</xsl:text><xsl:value-of select="$toc-outline-values"/><xsl:text>" </xsl:text>
        </xsl:if>
        <xsl:if test="$generate-toc-paragraphs">
         <xsl:text>\t "</xsl:text><xsl:value-of select="$toc-paragraph-values"/><xsl:text>" </xsl:text>
        </xsl:if>
      </xsl:variable>
      <w:p>
        <w:r>
          <w:fldChar w:fldCharType="begin" />
        </w:r>
        <w:r>
          <w:instrText xml:space="preserve"><xsl:value-of select="$toc-text" /></w:instrText>
        </w:r>
        <w:r>
          <w:fldChar w:fldCharType="end" />
        </w:r>
      </w:p>
    </xsl:when>
    <!-- Do nothing -->
    <xsl:otherwise/>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
