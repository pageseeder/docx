<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to generate the index files.

  The index files are located in the `index` folder.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://pageseeder.org/docx/function"
                exclude-result-prefixes="#all">

<!-- Ignore all text for index files by default -->
<xsl:template match="text()" mode="index-files" />

<!-- handle generation of index files with filedcode text -->
<xsl:template match="w:instrText[matches(text(),'XE')]" mode="index-files">
  <xsl:variable name="temp-index-location" select="translate(translate(fn:get-index-text(text(),'XE'),'/','_'),':','/')" />
  <!-- TODO Use XQuery and XPath function instead -->
  <xsl:variable name="full-index">
    <xsl:for-each select="tokenize($temp-index-location,'/')">
      <xsl:choose>
        <xsl:when test="position() != last()">
          <xsl:value-of select="concat(encode-for-uri(.),'/')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="encode-for-uri(.)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="document-title">
    <xsl:choose>
      <xsl:when test="contains(fn:get-index-text(text(), 'XE'),':')">
        <xsl:value-of select="fn:string-after-last-delimiter(fn:get-index-text(text(),'XE'),':')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="fn:get-index-text(text(), 'XE')" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="preceding::w:instrText[matches(text(),'XE')]">
      <xsl:if test="not(preceding::w:instrText[matches(text(),'XE')]/translate(translate(fn:get-index-text(text(),'XE'),'/','_'),':','/') = $temp-index-location)">
        <xsl:result-document href="{concat($_outputfolder,'index/',$full-index,'.psml')}">
          <document level="portable">
            <documentinfo>
              <uri title="{$document-title}">
                <displaytitle>
                  <xsl:value-of select="$document-title" />
                </displaytitle>
              </uri>
            </documentinfo>
            <section id="title">
              <fragment id="title">
                <heading level="1">
                  <xsl:value-of select="$document-title" />
                </heading>
              </fragment>
            </section>
          </document>
        </xsl:result-document>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:result-document href="{concat($_outputfolder,'index/',$full-index,'.psml')}">
        <document level="portable">
          <documentinfo>
            <uri title="{$document-title}">
              <displaytitle>
                <xsl:value-of select="$document-title" />
              </displaytitle>
            </uri>
          </documentinfo>
          <section id="title">
            <fragment id="title">
              <heading level="1">
                <xsl:value-of select="$document-title" />
              </heading>
            </fragment>
          </section>
        </document>
      </xsl:result-document>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>