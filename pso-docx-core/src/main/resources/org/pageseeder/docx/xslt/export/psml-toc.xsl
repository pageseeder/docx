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

-->
<xsl:template match="toc" mode="psml">
  <xsl:param name="labels" tunnel="yes" />
  <xsl:param name="document-bookmark-name" tunnel="yes" />
  <xsl:variable name="toc-config" as="element(toc)?">
    <xsl:choose>
      <xsl:when test="../ancestor::document">
        <xsl:sequence select="config:generate-toc-for-document-label($labels)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="config:generate-toc()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:if test="$toc-config">
    <xsl:variable name="toc-text">
      <xsl:text>TOC </xsl:text>
      <xsl:if test="../ancestor::document">
        <xsl:text>\b </xsl:text><xsl:value-of select="$document-bookmark-name" /><xsl:text> </xsl:text>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="config:generate-toc-outline($toc-config) and config:toc-outline-values($toc-config) != ''">
          <xsl:text>\o "</xsl:text><xsl:value-of select="config:toc-outline-values($toc-config)"/><xsl:text>" </xsl:text>
        </xsl:when>
        <!-- FOR BACKWARD COMPATIBILITY ONLY -->
        <xsl:when test="config:generate-toc-headings($toc-config) and config:toc-heading-values($toc-config) != ''">
          <xsl:text>\o "</xsl:text><xsl:value-of select="config:toc-heading-values($toc-config)"/><xsl:text>" </xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="config:generate-toc-paragraphs($toc-config)">
       <xsl:text>\t "</xsl:text><xsl:value-of select="config:toc-paragraph-values($toc-config)"/><xsl:text>" </xsl:text>
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
