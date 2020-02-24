<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to handle the generate foot notes.

  Foot notes are store in a separate PSML file `footnotes/footnotes.psml`.

  In OOXML, the `w:footnotes` element contains a sequence of `w:footnote` elements.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!--
  Generate `components/footnotes.psml` file from the `w:footnotes` element.
-->
<xsl:template match="w:footnotes" mode="footnotes">
  <xsl:if test="w:footnote[not(@w:id='-1')][not(@w:id='0')]">
    <xsl:result-document href="{concat($_outputfolder, 'components/footnotes.psml')}">
      <document type="footnotes" level="portable">
        <documentinfo>
          <uri title="Footnotes" />
        </documentinfo>

        <section id="title">
          <fragment id="0">
            <heading level="1">Footnotes</heading>
          </fragment>
        </section>

        <section id="content">
          <xsl:choose>
            <xsl:when test="config:convert-footnotes-type() = 'generate-files'">
              <xref-fragment id="content">
                <xsl:apply-templates select="w:footnote[not(@w:id='-1')][not(@w:id='0')]" mode="footnotes-generate-files" />
              </xref-fragment>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="w:footnote[not(@w:id='-1')][not(@w:id='0')]" mode="footnotes-generate-fragments" />
            </xsl:otherwise>
          </xsl:choose>
        </section>
      </document>
    </xsl:result-document>
  </xsl:if>
</xsl:template>

<!-- Template to match each footnote and generate it's content for each fragment-->
<xsl:template match="w:footnote" mode="footnotes-generate-fragments">
  <fragment id="{@w:id}">
    <xsl:apply-templates mode="content"/>
  </fragment>
</xsl:template>

<!-- Template to match each footnote and generate a heading for it and it's content for each document-->
<xsl:template match="w:footnote" mode="footnotes-generate-files">
  <blockxref href="{concat('footnotes',@w:id,'.psml')}" frag="default"><xsl:value-of select="concat('Footnote ',@w:id)" /></blockxref>
  <xsl:result-document href="{concat($_outputfolder,'footnotes/footnotes',@w:id,'.psml')}">
    <document level="portable">
      <documentinfo>
        <uri title="{concat('Footnote ',@w:id)}">
          <displaytitle>
            <xsl:value-of select="concat('Footnote ',@w:id)" />
          </displaytitle>
        </uri>
      </documentinfo>
      <section id="body">
        <fragment id="{@w:id}">
          <xsl:apply-templates mode="content"/>
        </fragment>
      </section>
    </document>
  </xsl:result-document>
</xsl:template>

</xsl:stylesheet>