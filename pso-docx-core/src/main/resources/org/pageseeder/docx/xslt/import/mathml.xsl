<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to handle MathML content.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:config="http://pageseeder.org/docx/config"
                xmlns:fn="http://pageseeder.org/docx/function"
                exclude-result-prefixes="#all">

<!-- apply templates to smart Tags:
  transform them into inline labels or just keep them as text, according to the option set on the configuration document -->
<xsl:key name="math-checksum-id" match="@checksum-id" use="." />

<!-- template to generate mathml objects in pageseeder -->
<xsl:template match="w:body" mode="mathml">
  <xsl:for-each select="distinct-values(m:math/@checksum-id)">
    <xsl:variable name="current" select="."/>
      <xsl:result-document href="{concat($_outputfolder,'mathml/',.,'.mml')}">
        <xsl:choose>
          <xsl:when test="config:convert-omml-to-mml()">
            <xsl:apply-templates select="$list-mathml//m:math[@checksum-id = $current][1]" mode="mml" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$list-mathml//m:math[@checksum-id = $current][1]" mode="mathml" />
          </xsl:otherwise>
        </xsl:choose>
    </xsl:result-document>
  </xsl:for-each>
</xsl:template>

<!--
  Generate `xref` to corresponding MathML object
-->
<xsl:template match="m:oMath[not(ancestor::m:oMathPara)][config:generate-mathml-files()]
                    |m:oMath[ancestor::m:oMathPara and ancestor::w:p][config:generate-mathml-files()]"
              mode="content" as="element(xref)">
  <xsl:variable name="current">
    <xsl:apply-templates select="." mode="xml"/>
  </xsl:variable>
  <xsl:variable name="math-checksum" select="fn:checksum($current)"/>
  <xref display="manual" frag="default" type="none" reverselink="true" reversetitle="" reversetype="none"
        title="{$math-checksum}"
        href="mathml/{$math-checksum}.mml'">
    <xsl:value-of select="$math-checksum" />
  </xref>
</xsl:template>

<!--
  Match each pre-processed text run individually
-->
<xsl:template match="m:oMathPara[config:generate-mathml-files()][not(ancestor::w:p)]" mode="content" as="element(para)">
  <xsl:variable name="current">
    <xsl:apply-templates select="." mode="xml"/>
  </xsl:variable>
  <xsl:variable name="math-checksum" select="fn:checksum($current)"/>
  <para>
    <xref display="manual" frag="default" type="none" reverselink="true" reversetitle="" reversetype="none"
          title="{$math-checksum}"
          href="mathml/{$math-checksum}.mml">
      <xsl:value-of select="$math-checksum" />
    </xref>
  </para>
</xsl:template>

<!-- copy recursively each mathml node -->
<xsl:template match="@*|node()" mode="mathml">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="mathml" />
    <xsl:apply-templates mode="mathml" />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>