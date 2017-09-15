<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to handle the generate "end notes".

  End notes are stored in a separate PSML file `endnotes/endnotes.psml`.

  In OOXML, the `w:endnotes` element contains a sequence of `w:endnote` elements.

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
  Generate `endnotes/endnotes.psml` file from the `w:endnotes` element.
-->
<xsl:template match="w:endnotes" mode="endnotes">
  <xsl:result-document href="{concat($_outputfolder, 'endnotes/endnotes.psml')}">
    <document level="portable">
      <documentinfo>
        <uri title="{concat($document-title,' endnotes')}">
          <displaytitle>
            <xsl:value-of select="concat($document-title,' endnotes')" />
          </displaytitle>
        </uri>
      </documentinfo>
      <section id="body">
        <xsl:choose>
          <xsl:when test="config:convert-endnotes-type() = 'generate-files'">
            <xref-fragment id="body">
              <xsl:apply-templates select="w:endnote[not(@w:id='-1')][not(@w:id='0')]" mode="endnotes-generate-files" />
            </xref-fragment>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="w:endnote[not(@w:id='-1')][not(@w:id='0')]" mode="endnotes-generate-fragments" />
          </xsl:otherwise>
        </xsl:choose>
      </section>
    </document>
  </xsl:result-document>
</xsl:template>

<!--
  Generate a fragment with the heading and associated content for a matching `w:endnote` element
-->
<xsl:template match="w:endnote" mode="endnotes-generate-fragments" as="element(fragment)">
  <fragment id="{@w:id}">
    <heading level="4"><xsl:value-of select="concat('[',fn:get-formated-footnote-endnote-value(count(preceding-sibling::w:endnote[not(@w:id='-1')][not(@w:id='0')]) + 1,'endnote'),']')"/></heading>
    <xsl:apply-templates mode="content"/>
  </fragment>
</xsl:template>

<!--
  Generate a `blockxref` for a matching `w:endnote` element as well as the corresponding PSML document
  in `endnotes/endnotes[id].psml`
-->
<xsl:template match="w:endnote" mode="endnotes-generate-files" as="element(blockxref)">
  <blockxref href="{concat('endnotes', @w:id, '.psml')}" frag="default"><xsl:value-of select="concat('Endnote ',@w:id)" /></blockxref>
  <xsl:result-document href="{concat($_outputfolder, 'endnotes/endnotes', @w:id, '.psml')}">
    <document level="portable">
      <documentinfo>
        <uri title="{concat('Endnote ', @w:id)}">
          <displaytitle><xsl:value-of select="concat('Endnote ', @w:id)" /></displaytitle>
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