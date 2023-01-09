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
    <documentinfo>
      <uri title="{$document-title}">
        <displaytitle><xsl:value-of select="$document-title" /></displaytitle>
      </uri>
    </documentinfo>
    <xsl:variable name="body" as="element(body)">
      <body>
        <xsl:apply-templates select="w:body/*" mode="bodycopy" />
      </body>
    </xsl:variable>
    <xsl:apply-templates select="$body" mode="sections"/>
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

<xsl:template match="body" mode="sections">
  <section id="title">
    <fragment id="title">
      <xsl:apply-templates select="*[1]" mode="content"/>
    </fragment>
  </section>
  <section id="1">
    <fragment id="1">
      <xsl:apply-templates select="*[position() != 1]" mode="content"/>
    </fragment>
  </section>
</xsl:template>

</xsl:stylesheet>