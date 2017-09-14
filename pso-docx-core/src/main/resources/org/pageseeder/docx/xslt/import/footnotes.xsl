<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to handle the generate foot notes.

  End notes are store in a separate PSML file `footnotes/footnotes.psml`.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://www.pageseeder.com/function"
                exclude-result-prefixes="#all">

<!-- Map a key to `checksum-id` for a more efficient access -->
<!-- TODO This key is probably pointless, it doesn't seem to be used anywhere! and it is declared elsewhere -->
<xsl:key name="math-checksum-id" match="@checksum-id" use="." />

<!--
  Generate `footnotes/footnotes.psml` file from the `w:footnotes` element.
-->
<xsl:template match="w:footnotes" mode="footnotes">
  <xsl:result-document href="{concat($_outputfolder, 'footnotes/footnotes.psml')}">
    <document level="portable">
      <documentinfo>
        <uri title="{concat($document-title, ' footnotes')}">
          <displaytitle><xsl:value-of select="concat($document-title, ' footnotes')" /></displaytitle>
        </uri>
      </documentinfo>
      <section id="body">
        <xsl:choose>
          <xsl:when test="$convert-footnotes-type = 'generate-files'">
            <xref-fragment id="body">
              <xsl:apply-templates mode="footnotes-generate-files" />
            </xref-fragment>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="footnotes-generate-fragments" />
          </xsl:otherwise>
        </xsl:choose>
      </section>
    </document>
  </xsl:result-document>
</xsl:template>

<!-- Template to match each footnote and generate a heading for it and it's content for each fragment-->
<xsl:template match="w:footnote[not(@w:id='-1')][not(@w:id='0')]" mode="footnotes-generate-fragments">
  <fragment id="{@w:id}">
    <heading level="4"><xsl:value-of select="concat('[',fn:get-formated-footnote-endnote-value(count(preceding-sibling::w:footnote[not(@w:id='-1')][not(@w:id='0')]) + 1,'footnote'),']')"/></heading>
    <xsl:apply-templates mode="content"/>
  </fragment>
</xsl:template>

<!-- Template to match each footnote and generate a heading for it and it's content for each document-->
<xsl:template match="w:footnote[not(@w:id='-1')][not(@w:id='0')]" mode="footnotes-generate-files">
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