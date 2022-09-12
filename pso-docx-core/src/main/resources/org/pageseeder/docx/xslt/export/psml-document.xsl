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
  <xsl:variable name="labels" select="tokenize(documentinfo/uri/labels,',')" as="xs:string*"/>
  <xsl:variable name="current-sec-num" select="config:section-number($labels)" />
  <xsl:variable name="previous-sec-num" select="config:section-number(
          tokenize(preceding::*[1]/ancestor::document[1]/documentinfo/uri/labels,','))" />
  <xsl:if test="$current-sec-num != $previous-sec-num and ancestor::document">
    <xsl:variable name="section-properties" select="(document(
          concat($_dotxfolder, '/word/document.xml'))//w:sectPr)[position()=$previous-sec-num]"/>
    <xsl:if test="$section-properties">
      <w:p>
        <w:pPr>
          <xsl:copy-of select="$section-properties"/>
        </w:pPr>
      </w:p>
    </xsl:if>
  </xsl:if>
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
      <xsl:call-template name="add-section">
        <xsl:with-param name="labels" select="$labels" tunnel="yes"/>
      </xsl:call-template>
    </xsl:when>
    <!-- for index output field code after title section -->
    <xsl:when test="not(config:index-documentlabel() = '') and
        tokenize(documentinfo/uri/labels,',') = config:index-documentlabel()">
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
          <w:instrText xml:space="preserve">INDEX \c "<xsl:value-of select="config:index-columns()" />"</w:instrText>
        </w:r>
        <w:r>
          <w:fldChar w:fldCharType="end" w:dirty="true" />
        </w:r>
      </w:p>
      <xsl:apply-templates select="section[not(ends-with(@id,'title'))]" mode="psml" >
        <xsl:with-param name="labels" select="$labels" tunnel="yes"/>
      </xsl:apply-templates>
      <w:bookmarkEnd w:id="{$bookmark-id}"/>
      <xsl:call-template name="add-section">
        <xsl:with-param name="labels" select="$labels" tunnel="yes"/>
      </xsl:call-template>
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
          <xsl:call-template name="add-section">
            <xsl:with-param name="labels" select="$labels" tunnel="yes"/>
          </xsl:call-template>
        </w:body>
      </w:document>
    </xsl:when>
    <!-- other documents -->
    <xsl:otherwise>
      <xsl:variable name="bookmark-id" select="fn:bookmark-id(.)"/>
      <w:bookmarkStart w:name="f-{@id}" w:id="{$bookmark-id}"/>
      <xsl:apply-templates mode="psml" >
        <xsl:with-param name="labels" select="$labels" tunnel="yes"/>
        <xsl:with-param name="document-bookmark-name" select="concat('f-', @id)" tunnel="yes"/>
      </xsl:apply-templates>
      <w:bookmarkEnd w:id="{$bookmark-id}"/>
      <xsl:call-template name="add-section">
        <xsl:with-param name="labels" select="$labels" tunnel="yes"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="add-section">
  <xsl:param name="labels" tunnel="yes"/>
  <!-- Add section properties only if there's not a document directly after and not at the end of the content -->
  <!-- NOTE: Text between <document> elements that is not in it’s own element will not trigger a section break -->
  <xsl:if test="not(following::*[1]/descendant-or-self::document) and
      not(.//document[not(following::*)])">
    <xsl:variable name="current-sec-num" select="config:section-number($labels)" />
    <xsl:variable name="next-sec-num" select="config:section-number(
      tokenize(following::*[1]/ancestor::document[1]/documentinfo/uri/labels,','))" />
    <!-- If this section is different from the next or at the end of the document add section properties -->
    <xsl:if test="$current-sec-num != $next-sec-num or not(following::*)">
      <xsl:variable name="section-properties" select="(document(
      concat($_dotxfolder, '/word/document.xml'))//w:sectPr)[position()=$current-sec-num]"/>
      <xsl:if test="$section-properties">
        <xsl:choose>
          <xsl:when test="not(following::*)">
            <!-- no para for last section -->
            <xsl:copy-of select="$section-properties"/>
          </xsl:when>
          <xsl:otherwise>
            <w:p>
              <w:pPr>
                <xsl:copy-of select="$section-properties"/>
              </w:pPr>
            </w:p>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
  </xsl:if>
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
    <xsl:variable name="id" select="count(preceding::fragment) + count(ancestor::fragment) + 1"/>
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
    <!-- add bookmark end for each index entry pointing to this fragment -->
    <xsl:variable name="xrefs" select="//inline[@label=config:all-inline-index-labels()]/xref[@href=concat('#', current()/@id)]" />
    <xsl:for-each select="$xrefs">
      <xsl:variable name="bookmark" select="10000000 + count(preceding::inline)" />
      <w:bookmarkEnd  w:id="{$bookmark}" />
    </xsl:for-each>
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
  <xsl:param name="labels" tunnel="yes" />
  <xsl:variable name="bookmark-id" select="fn:bookmark-id(.)"/>
  <w:bookmarkStart w:name="f-{@id}" w:id="{$bookmark-id}"/>
  <w:tbl>
    <w:tblPr>
      <xsl:variable name="styleid" select="config:properties-table-style($labels, @type)" />
      <xsl:choose>
        <xsl:when test="$styleid != ''">
          <w:tblStyle w:val="{$styleid}" />
        </xsl:when>
        <xsl:otherwise>
          <w:tblBorders>
            <w:top w:val="single" w:sz="4" w:space="0" w:color="auto" />
            <w:left w:val="single" w:sz="4" w:space="0" w:color="auto" />
            <w:bottom w:val="single" w:sz="4" w:space="0" w:color="auto" />
            <w:right w:val="single" w:sz="4" w:space="0" w:color="auto" />
            <w:insideH w:val="single" w:sz="4" w:space="0" w:color="auto" />
            <w:insideV w:val="single" w:sz="4" w:space="0" w:color="auto" />
          </w:tblBorders>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="config:properties-table-width($labels, @type) != '' and
                    config:properties-table-width-type($labels, @type) != ''">
        <w:tblW w:w="{config:properties-table-width($labels, @type)}"
                w:type="{config:properties-table-width-type($labels, @type)}" />
      </xsl:if>
    </w:tblPr>
    <xsl:apply-templates mode="psml" />
  </w:tbl>
  <w:bookmarkEnd w:id="{$bookmark-id}"/>
</xsl:template>

<!-- Template to handle each `property` -->
<xsl:template match="property" mode="psml">
  <xsl:param name="labels" tunnel="yes" />
  <w:tr>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="0" w:type="auto"/>
      </w:tcPr>
      <w:p>
        <xsl:variable name="title-styleid" select="config:properties-title-style($labels, ../@type)" />
        <xsl:if test="$title-styleid != ''">
          <w:pPr>
            <w:pStyle w:val="{$title-styleid}" />
          </w:pPr>
        </xsl:if>
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
      <xsl:variable name="value-styleid" select="config:properties-value-style($labels, ../@type)" />
      <xsl:choose>
        <xsl:when test="@datatype = 'xref'">
          <xsl:choose>
            <xsl:when test="xref">
              <xsl:for-each select="xref">
                <w:p>
                  <xsl:if test="$value-styleid != ''">
                    <w:pPr>
                      <w:pStyle w:val="{$value-styleid}" />
                    </w:pPr>
                  </xsl:if>
                  <xsl:apply-templates mode="psml" select="." />
                </w:p>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <w:p>
                <xsl:if test="$value-styleid != ''">
                  <w:pPr>
                    <w:pStyle w:val="{$value-styleid}" />
                  </w:pPr>
                </xsl:if>
                <w:r>
                  <w:t></w:t>
                </w:r>
              </w:p>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="@datatype = 'link'">
          <xsl:choose>
            <xsl:when test="link">
              <xsl:for-each select="link">
                <w:p>
                  <xsl:if test="$value-styleid != ''">
                    <w:pPr>
                      <w:pStyle w:val="{$value-styleid}" />
                    </w:pPr>
                  </xsl:if>
                  <xsl:apply-templates mode="psml" select="." />
                </w:p>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <w:p>
                <xsl:if test="$value-styleid != ''">
                  <w:pPr>
                    <w:pStyle w:val="{$value-styleid}" />
                  </w:pPr>
                </xsl:if>
                <w:r>
                  <w:t></w:t>
                </w:r>
              </w:p>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="@datatype = 'markdown'">
          <xsl:choose>
            <xsl:when test="markdown/*">
              <xsl:apply-templates select="markdown/*" mode="psml"/>
            </xsl:when>
            <xsl:otherwise>
              <w:p>
                <xsl:if test="$value-styleid != ''">
                  <w:pPr>
                    <w:pStyle w:val="{$value-styleid}" />
                  </w:pPr>
                </xsl:if>
                <w:r>
                  <w:t><xsl:value-of select="markdown"/></w:t>
                </w:r>
              </w:p>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="@datatype = 'markup'">
          <xsl:choose>
            <xsl:when test="*">
              <xsl:apply-templates mode="psml"/>
            </xsl:when>
            <xsl:otherwise>
              <w:p>
                <xsl:if test="$value-styleid != ''">
                  <w:pPr>
                    <w:pStyle w:val="{$value-styleid}" />
                  </w:pPr>
                </xsl:if>
                <w:r>
                  <w:t></w:t>
                </w:r>
              </w:p>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="value">
          <xsl:for-each select="value">
            <w:p>
              <xsl:if test="$value-styleid != ''">
                <w:pPr>
                  <w:pStyle w:val="{$value-styleid}" />
                </w:pPr>
              </xsl:if>
              <w:r>
                <w:t><xsl:value-of select="."/></w:t>
              </w:r>
            </w:p>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <w:p>
            <xsl:if test="$value-styleid != ''">
              <w:pPr>
                <w:pStyle w:val="{$value-styleid}" />
              </w:pPr>
            </xsl:if>
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