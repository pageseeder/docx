<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet transform openXML into PSML

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<xsl:decimal-format name="digits" decimal-separator="." grouping-separator="," />

<!-- Initial match of the w:document -->
<xsl:template match="w:document" mode="content">

  <document level="portable">
    <xsl:if test="config:document-type-for-main-document() != ''">
      <xsl:attribute name="type" select="config:document-type-for-main-document()"/>
    </xsl:if>
    <documentinfo>
      <uri title="{$document-title}">
        <displaytitle><xsl:value-of select="$document-title" /></displaytitle>
        <xsl:if test="config:document-label-for-main-document() != ''">
          <labels><xsl:value-of select="config:document-label-for-main-document()"/></labels>
        </xsl:if>
      </uri>
    </documentinfo>
    <xsl:choose>
      <xsl:when test="$generate-processed-psml">
        <xsl:apply-templates select="w:body" mode="processed-psml" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="w:body" mode="content" />
      </xsl:otherwise>
    </xsl:choose>
  </document>

  <xsl:if test="config:generate-index-files()">
    <xsl:apply-templates select="$list-index" mode="index-files"/>
  </xsl:if>

  <xsl:if test="config:generate-mathml()">
    <xsl:apply-templates select="$list-mathml" mode="mathml"/>
  </xsl:if>

  <xsl:if test="doc-available($footnotes-file) and config:convert-footnotes()">
    <xsl:apply-templates select="document($footnotes-file)" mode="footnotes"/>
  </xsl:if>

  <xsl:if test="doc-available($endnotes-file) and config:convert-endnotes()">
    <xsl:apply-templates select="document($endnotes-file)" mode="endnotes"/>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>