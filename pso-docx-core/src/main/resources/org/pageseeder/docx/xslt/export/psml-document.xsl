<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to process the `document` PSML element and other structural PSML elements

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio

  @version 0.6.0
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
                xmlns:config="http://pageseeder.org/docx/config"
                xmlns:fn="http://pageseeder.org/docx/function"
                exclude-result-prefixes="#all">

<!--
  Document element of a PSML document.

  This is typically the entry point for processing the PSML, but it could also be transcluded content!
-->
<xsl:template match="document" mode="psml">
  <!-- TODO all functions treat labels as a single label so this will not work if there is more than one -->
  <xsl:variable name="labels" select="string(documentinfo/uri/labels)" as="xs:string"/>
  <xsl:choose>
    <!-- don't include footnotes and endnotes documents -->
    <xsl:when test="@type=config:footnotes-documenttype() or @type=config:endnotes-documenttype()" />
    <!-- for bibliography only output title section and field code -->    
    <xsl:when test="@type=config:citations-documenttype()">
      <xsl:variable name="bookmark-id" select="fn:bookmark-id(.)"/>
      <w:bookmarkStart w:name="f-{@id}" w:id="{$bookmark-id}"/>
      <xsl:apply-templates select="section[ends-with(@id,'title')]" mode="psml" >
        <xsl:with-param name="labels" select="$labels" tunnel="yes"/>
      </xsl:apply-templates>
      <w:p>
        <w:r>
          <w:fldChar w:fldCharType="begin" w:dirty="true" />
        </w:r>
        <w:r>
          <w:instrText xml:space="preserve">BIBLIOGRAPHY</w:instrText>
        </w:r>
        <w:r>
          <w:fldChar w:fldCharType="end" w:dirty="true" />
        </w:r>
      </w:p>
      <w:bookmarkEnd w:id="{$bookmark-id}"/>
    </xsl:when>
    <!-- root document -->
    <xsl:when test="not(ancestor::document)">
      <w:document>
        <w:body>
          <xsl:variable name="bookmark-id" select="fn:bookmark-id(.)"/>
          <w:bookmarkStart w:name="f-{@id}" w:id="{$bookmark-id}"/>
          <w:bookmarkEnd w:id="{$bookmark-id}" />
          <xsl:apply-templates select="section|toc" mode="psml">
            <xsl:with-param name="labels" select="$labels" tunnel="yes"/>
          </xsl:apply-templates>
          <xsl:variable name="section-properties" select="document(concat($_dotxfolder, '/word/document.xml'))//w:body/w:sectPr[last()]"/>
          <xsl:choose>
            <xsl:when test="$section-properties">
              <xsl:copy-of select="$section-properties"/>
            </xsl:when>
            <xsl:otherwise>
              <w:sectPr/>
            </xsl:otherwise>
          </xsl:choose>
        </w:body>
      </w:document>
    </xsl:when>
    <!-- other documents -->
    <xsl:otherwise>
      <xsl:variable name="bookmark-id" select="fn:bookmark-id(.)"/>
      <w:bookmarkStart w:name="f-{@id}" w:id="{$bookmark-id}"/>
      <xsl:apply-templates mode="psml" >
        <xsl:with-param name="labels" select="$labels" tunnel="yes"/>
      </xsl:apply-templates>
      <w:bookmarkEnd w:id="{$bookmark-id}"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Match section of pageseeder document;
  Has the option to create comments to reference back to pageseeder comments
-->
<xsl:template match="section" mode="psml">
  <!-- TODO Add a bookmark? -->
  <xsl:apply-templates select="*" mode="psml"/>
</xsl:template>

<!--
  Match fragment of pageseeder document;
  Creates bookmarks for each of the sections
 -->
<xsl:template match="fragment" mode="psml">
  <!-- TODO generate comments for other xref-fragment, properties-fragment, media-fragment -->
  <xsl:if test="config:generate-comments()">
    <xsl:variable name="id" select="count(preceding::fragment) + 1"/>
    <w:p>
     <w:commentRangeStart w:id="{$id}"/>
      <w:r>
       <w:rPr>
         <w:rStyle w:val="CommentReference"/>
       </w:rPr>
         <w:commentReference w:id="{$id}"/>
      </w:r>
     <w:commentRangeEnd w:id="{$id}"/>
    </w:p>
  </xsl:if>
  <xsl:variable name="bookmark-id" select="fn:bookmark-id(.)"/>
  <w:bookmarkStart w:name="f-{@id}" w:id="{$bookmark-id}"/>
    <xsl:apply-templates mode="psml">
      <xsl:with-param name="fragment-id" tunnel="yes" select="@id" />
    </xsl:apply-templates>
  <w:bookmarkEnd  w:id="{$bookmark-id}" />
</xsl:template>

<!--
  Match xref-fragment of pageseeder document
-->
<xsl:template match="xref-fragment" mode="psml">
  <xsl:variable name="bookmark-id" select="fn:bookmark-id(.)"/>
  <w:bookmarkStart w:name="f-{@id}" w:id="{$bookmark-id}"/>
  <xsl:apply-templates mode="psml" />
  <w:bookmarkEnd w:id="{$bookmark-id}" />
</xsl:template>

<!--
  Match media-fragment of pageseeder document
-->
<xsl:template match="media-fragment" mode="psml">
  <xsl:variable name="bookmark-id" select="fn:bookmark-id(.)"/>
  <w:bookmarkStart w:name="f-{@id}" w:id="{$bookmark-id}"/>
    <xsl:if test="@mediatype='application/mathml+xml'">
      <xsl:apply-templates mode="mml" />
    </xsl:if>
  <w:bookmarkEnd w:id="{$bookmark-id}" />
</xsl:template>

<!-- Template to match properties fragment and transform it into a table -->
<xsl:template match="properties-fragment" mode="psml">
  <xsl:variable name="bookmark-id" select="fn:bookmark-id(.)"/>
  <w:bookmarkStart w:name="f-{@id}" w:id="{$bookmark-id}"/>
  <w:tbl>
    <w:tblPr>
      <w:tblBorders>
        <w:top w:val="single" w:sz="4" w:space="0" w:color="auto" />
        <w:left w:val="single" w:sz="4" w:space="0" w:color="auto" />
        <w:bottom w:val="single" w:sz="4" w:space="0" w:color="auto" />
        <w:right w:val="single" w:sz="4" w:space="0" w:color="auto" />
        <w:insideH w:val="single" w:sz="4" w:space="0" w:color="auto" />
        <w:insideV w:val="single" w:sz="4" w:space="0" w:color="auto" />
      </w:tblBorders>
    </w:tblPr>
    <xsl:apply-templates mode="psml" />
  </w:tbl>
  <w:bookmarkEnd w:id="{$bookmark-id}"/>
</xsl:template>

<!-- Template to handle each `property` -->
<xsl:template match="property" mode="psml">
  <w:tr>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="0" w:type="auto"/>
      </w:tcPr>
      <w:p>
        <w:r>
          <w:t>
            <xsl:value-of select="if (@title) then @title else @name"/>
          </w:t>
        </w:r>
      </w:p>
    </w:tc>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="0" w:type="auto"/>
      </w:tcPr>
      <xsl:choose>
        <xsl:when test="@datatype = 'xref'">
          <w:p>
            <xsl:apply-templates mode="psml"/>
          </w:p>
        </xsl:when>
        <xsl:when test="@datatype = 'markdown'">
          <xsl:choose>
            <xsl:when test="markdown/*">
              <xsl:apply-templates select="markdown/*" mode="psml"/>
            </xsl:when>
            <xsl:otherwise>
              <w:p>
                <w:r>
                  <w:t><xsl:value-of select="markdown"/></w:t>
                </w:r>
              </w:p>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="value">
          <xsl:for-each select="value">
            <w:p>
              <w:r>
                <w:t><xsl:value-of select="."/></w:t>
              </w:r>
            </w:p>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <w:p>
            <w:r>
              <w:t><xsl:value-of select="@value"/></w:t>
            </w:r>
          </w:p>
        </xsl:otherwise>
      </xsl:choose>
    </w:tc>
  </w:tr>
</xsl:template>

<!--
  Elements which are ignored by default.
-->
<xsl:template match="displaytitle|documentinfo|uri|reversexrefs|fragmentinfo|locator|metadata" mode="psml"/>

<!-- If could not match any, print this error message -->
<xsl:template match="*[ancestor::para or ancestor::mitem or ancestor::item or ancestor::heading]" mode="psml" priority="-1">
  <w:r>
    <w:rPr>
      <w:color w:val="991111" /><!-- TODO Magic number? -->
    </w:rPr>
    <w:t>Error unprocessed element: <xsl:value-of select="name(.)" /></w:t>
  </w:r>
</xsl:template>

</xsl:stylesheet>