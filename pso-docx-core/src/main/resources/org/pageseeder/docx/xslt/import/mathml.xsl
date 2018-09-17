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

<!-- template to generate mathml objects in pageseeder -->
<xsl:template match="w:body" mode="mathml">
  <xsl:for-each select="distinct-values(m:math/@checksum-id)">
    <xsl:variable name="current" select="."/>
      <xsl:choose>
        <xsl:when test="config:generate-mathml-files()">
          <xsl:result-document href="{concat($_outputfolder,'mathml/mathml-',.,'.mml')}">
            <xsl:choose>
              <xsl:when test="config:convert-omml-to-mml()">
                <xsl:apply-templates select="$list-mathml//m:math[@checksum-id = $current][1]" mode="mml" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="$list-mathml//m:math[@checksum-id = $current][1]" mode="mathml" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:result-document>
        </xsl:when>
        <xsl:otherwise>
          <xsl:result-document href="{concat($_outputfolder,'mathml/mathml-',.,'.psml')}">
            <document type="mathml" level="portable">           
              <section id="media">
                <media-fragment id="1" mediatype="application/mathml+xml">
                  <xsl:apply-templates select="$list-mathml//m:math[@checksum-id = $current][1]" mode="mml" />
                </media-fragment>
              </section>            
            </document>
          </xsl:result-document>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!--
  Generate `xref` to corresponding MathML object
-->
<xsl:template match="m:oMath[not(ancestor::m:oMathPara)][config:generate-mathml()]
                    |m:oMath[ancestor::m:oMathPara and ancestor::w:p][config:generate-mathml()]"
              mode="content" as="element(xref)">
  <!-- TODO The pattern used in this template should be revieved -->
  <xsl:variable name="current">
    <xsl:apply-templates select="." mode="xml"/>
  </xsl:variable>
  <xsl:variable name="math-checksum" select="fn:checksum($current)"/>
  <xsl:call-template name="math-xref">
    <xsl:with-param name="math-id" select="$math-checksum" />
  </xsl:call-template>
</xsl:template>

<!--
  Match each pre-processed text run individually
-->
<xsl:template match="m:oMathPara[config:generate-mathml()][not(ancestor::w:p)]" mode="content" as="element(para)">
  <xsl:variable name="current">
    <xsl:apply-templates select="." mode="xml"/>
  </xsl:variable>
  <xsl:variable name="math-checksum" select="fn:checksum($current)"/>
  <para>
    <xsl:call-template name="math-xref">
      <xsl:with-param name="math-id" select="$math-checksum" />
    </xsl:call-template>
  </para>
</xsl:template>

<!--
  Generate math XRef
-->
<xsl:template name="math-xref">
  <xsl:param name="math-id" />
  <xsl:choose>
    <xsl:when test="config:generate-mathml-files()">
      <xref display="manual" frag="default" type="math" title="{$math-id}"
            href="mathml/mathml-{$math-id}.mml">
        <xsl:value-of select="concat('mathml-',$math-id)" />
      </xref>
    </xsl:when>
    <xsl:otherwise>
      <xref display="document" frag="1" type="math" config="mathml"
            href="mathml/mathml-{$math-id}.psml">
        <xsl:value-of select="concat('mathml-',$math-id)" />
      </xref>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- copy recursively each mathml node -->
<xsl:template match="@*|node()" mode="mathml">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="mathml" />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>