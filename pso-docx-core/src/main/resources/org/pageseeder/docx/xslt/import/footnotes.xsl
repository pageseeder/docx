<?xml version="1.0" encoding="utf-8"?>

  <!--
    This stylesheet transform openXML into PS Format
  
    @author Hugo Inacio 
    @copyright Allette Systems Pty Ltd 
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships" xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.pageseeder.com/function" exclude-result-prefixes="#all">
 

  <!-- apply templates to smart Tags:
  transform them into inline labels or just keep them as text, according to the option set on the configuration document -->
  <xsl:key name="math-checksum-id" match="@checksum-id" use="." />

  <!-- TODO -->
  <xsl:template match="w:footnotes" mode="footnotes">
    <xsl:result-document href="{concat($_outputfolder,'footnotes/footnotes.psml')}">
      <document level="portable">
        <documentinfo>
          <uri title="{concat($document-title,' footnotes')}">
            <displaytitle>
              <xsl:value-of select="concat($document-title,' footnotes')" />
            </displaytitle>
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

  <!-- TODO -->
  <xsl:template match="w:footnote[not(@w:id='-1')][not(@w:id='0')]" mode="footnotes-generate-fragments">
    <fragment id="{@w:id}">
      <heading level="4"><xsl:value-of select="concat('[',fn:get-formated-footnote-endnote-value(count(preceding-sibling::w:footnote[not(@w:id='-1')][not(@w:id='0')]) + 1,'footnote'),']')"/></heading>
      <xsl:apply-templates mode="content"/>
    </fragment>
  </xsl:template>
 
   <!-- TODO --> 
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