<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
                xmlns:o="urn:schemas-microsoft-com:office:office"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
                xmlns:v="urn:schemas-microsoft-com:vml"
                xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
                xmlns:w10="urn:schemas-microsoft-com:office:word"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
                xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
                xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                xmlns:dfx="http://www.topologi.com/2005/Diff-X"
                xmlns:del="http://www.topologi.com/2005/Diff-X/Delete"
                xmlns:ins="http://www.topologi.com/2005/Diff-X/Insert"
                xmlns:diffx="java:com.topologi.diffx.Extension"
                xmlns:fn="http://www.pageseeder.com/function" xmlns:dec="java:java.net.URLDecoder"
                exclude-result-prefixes="#all">

<!--
  Match root of pageseeder document
-->
<xsl:template match="document" mode="content">
  <xsl:variable name="labels">
    <xsl:choose>
      <xsl:when test="documentinfo/uri/labels">
        <xsl:value-of select="documentinfo/uri/labels"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="not(ancestor::document)">
      <w:document>
        <w:body>
          <w:bookmarkStart w:name="fragment-{@id}" w:id="{count(preceding::*)}"/>
          <w:bookmarkEnd  w:id="{count(preceding::*)}" />
          <xsl:apply-templates mode="content" select="section|toc">
            <xsl:with-param name="labels" select="$labels" tunnel="yes"/>
          </xsl:apply-templates>
          <xsl:choose>
            <xsl:when test="document(concat($_dotxfolder,'/word/document.xml'))//w:body/w:sectPr[last()]">
              <xsl:copy-of select="document(concat($_dotxfolder,'/word/document.xml'))//w:body/w:sectPr[last()]"/>
            </xsl:when>
            <xsl:otherwise>
              <w:sectPr/>
            </xsl:otherwise>
          </xsl:choose>
        </w:body>
      </w:document>
    </xsl:when>
    <xsl:otherwise>
      <w:bookmarkStart w:name="fragment-{@id}" w:id="{count(preceding::*)}"/>
      <xsl:apply-templates mode="content" >
        <xsl:with-param name="labels" select="$labels" tunnel="yes"/>
      </xsl:apply-templates>
      <w:bookmarkEnd w:id="{count(preceding::*)}" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Match xref-fragment of pageseeder document
-->
<xsl:template match="xref-fragment" mode="content">
  <w:bookmarkStart w:name="fragment-{@id}" w:id="{count(preceding::*)}"/>
    <xsl:apply-templates mode="content" />
  <w:bookmarkEnd  w:id="{count(preceding::*)}" />
</xsl:template>

<!--
  Match media-fragment of pageseeder document
-->
<xsl:template match="media-fragment" mode="content">
  <w:bookmarkStart w:name="fragment-{@id}" w:id="{count(preceding::*)}"/>
  <w:bookmarkEnd  w:id="{count(preceding::*)}" />
</xsl:template>

<!--
  Match displaytitle of pageseeder document (do nothing)
-->
<xsl:template match="displaytitle" mode="content"/>

<!--
  Match documentinfo of pageseeder document (do nothing)
-->
<xsl:template match="documentinfo" mode="content"/>

<!--
  Match uri of pageseeder document (do nothing)
-->
<xsl:template match="uri" mode="content"/>

<!--
  Match `reversexrefs` of pageseeder document (do nothing)
-->
<xsl:template match="reversexrefs" mode="content"/>

<!--
  Match `fragmentinfo` of pageseeder document (do nothing)
-->
<xsl:template match="fragmentinfo" mode="content"/>

<!--
  Match section of pageseeder document;
  Has the option to create comments to reference back to pageseeder comments
-->
<xsl:template match="section" mode="content">
  <xsl:apply-templates mode="content" select="*" />
</xsl:template>

<!--
  Match fragment of pageseeder document;
  Creates bookmarks for each of the sections
 -->
<xsl:template match="fragment" mode="content">
  <!-- TODO generate comments for other xref-fragment, properties-fragment, media-fragment -->
  <xsl:if test="$generate-comments">
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
  <w:bookmarkStart w:name="fragment-{@id}" w:id="{count(preceding::*)}"/>
    <xsl:apply-templates mode="content" />
  <w:bookmarkEnd  w:id="{count(preceding::*)}" />
</xsl:template>

<!--  If could not match any, print this error message -->
<xsl:template match="*[ancestor::para or ancestor::mitem or ancestor::item ]" mode="content" priority="-1">
  <w:r>
    <w:rPr>
      <w:color w:val="991111" /><!-- TODO Magic number? -->
    </w:rPr>
    <w:t>
      Error unprocessed element:
      <xsl:value-of select="name(.)" />
    </w:t>
  </w:r>
</xsl:template>

<xsl:template match="metadata" mode="content"/>

<!-- Template to match properties fragment and transform it into a table -->
<xsl:template match="properties-fragment" mode="content">
  <w:bookmarkStart w:name="fragment-{@id}" w:id="{count(preceding::*)}"/>
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
    <xsl:apply-templates mode="content" />
  </w:tbl>
  <w:bookmarkEnd w:id="{count(preceding::*)}" />
</xsl:template>

<!-- Template to handle each `property` -->
<xsl:template match="property" mode="content">
  <w:tr>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="0" w:type="auto"/>
      </w:tcPr>
      <w:p>
        <w:r>
          <w:t>
            <!-- TODO Simplify code -->
            <xsl:choose>
              <xsl:when test="@title">
                <xsl:value-of select="@title"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@name"/>
              </xsl:otherwise>
            </xsl:choose>
          </w:t>
        </w:r>
      </w:p>
    </w:tc>
    <w:tc>
      <w:tcPr>
        <w:tcW w:w="0" w:type="auto"/>
      </w:tcPr>
      <xsl:choose>
        <!-- when contains mixed content -->
        <xsl:when test="not(@datatype)">
          <w:p>
            <w:r>
              <w:t><xsl:value-of select="@value"/></w:t>
            </w:r>
          </w:p>
        </xsl:when>
        <xsl:when test="@datatype = 'text'">
          <w:p>
            <w:r>
              <w:t><xsl:value-of select="@value"/></w:t>
            </w:r>
          </w:p>
        </xsl:when>
        <xsl:when test="@datatype = 'xref'">
          <w:p>
            <xsl:apply-templates mode="content"/>
          </w:p>
        </xsl:when>
        <xsl:when test="@datatype = 'string'">
          <w:p>
            <w:r>
              <w:t><xsl:value-of select="@value"/></w:t>
            </w:r>
          </w:p>
        </xsl:when>
        <xsl:when test="@datatype = 'datetime'">
          <w:p>
            <w:r>
              <w:t><xsl:value-of select="@value"/></w:t>
            </w:r>
          </w:p>
        </xsl:when>
        <xsl:otherwise>
          <w:p/>
        </xsl:otherwise>
      </xsl:choose>
    </w:tc>
  </w:tr>
</xsl:template>

</xsl:stylesheet>