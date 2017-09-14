<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet transform openXML into PSML

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://www.pageseeder.com/function"
                exclude-result-prefixes="#all">

<xsl:decimal-format name="digits" decimal-separator="." grouping-separator="," />

<!-- Initial match of the w:document -->
<xsl:template match="w:document" mode="content">

  <document level="portable">
    <xsl:if test="fn:document-type-for-main-document() != ''">
      <xsl:attribute name="type" select="fn:document-type-for-main-document()"/>
    </xsl:if>
    <documentinfo>
      <uri title="{$document-title}">
        <displaytitle><xsl:value-of select="$document-title" /></displaytitle>
        <xsl:if test="fn:document-label-for-main-document() != ''">
          <labels><xsl:value-of select="fn:document-label-for-main-document()"/></labels>
        </xsl:if>
      </uri>
    </documentinfo>
    <xsl:choose>
      <xsl:when test="$generate-processed-psml">
        <xsl:apply-templates select="w:body" mode="processedpsml" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="w:body" mode="content" />
      </xsl:otherwise>
    </xsl:choose>
  </document>

  <!-- TODO Why is this applied twice?? -->
  <xsl:if test="$generate-index-files">
    <xsl:apply-templates select="$list-index" mode="index-files"/>
  </xsl:if>

  <xsl:if test="$generate-index-files">
    <xsl:apply-templates select="$list-index" mode="index-files"/>
  </xsl:if>

  <xsl:if test="$generate-mathml-files">
    <xsl:apply-templates select="$list-mathml" mode="mathml"/>
  </xsl:if>

  <xsl:if test="doc-available($footnotes-file) and $convert-footnotes">
    <xsl:apply-templates select="$footnotes" mode="footnotes"/>
  </xsl:if>

  <xsl:if test="doc-available($endnotes-file) and $convert-endnotes">
    <xsl:apply-templates select="$endnotes" mode="endnotes"/>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>