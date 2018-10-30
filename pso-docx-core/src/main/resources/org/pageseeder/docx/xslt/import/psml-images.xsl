<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to handle the images from `w:drawing`, `w:pict`, and `w:object`.

  All templates in this module assume that images are inside the `media` folder .

  @author Hugo Inacio
  @author Christophe Lauret
  @author Adriano Akaishi

  @version 1.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:v="urn:schemas-microsoft-com:vml"
                xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
                xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships"
                exclude-result-prefixes="#all">

  <!--
  Generate a PSML `image` from a Word `w:drawing`.
-->
  <xsl:template match="w:drawing[1]" mode="drawing-element">
    <!-- Height and Width of the image --> 
    <xsl:variable name="height" as="xs:integer">
      <xsl:choose>
        <xsl:when test="wp:anchor">
          <xsl:value-of select="if (wp:anchor/wp:extent/@cy) then
                                         (number(wp:anchor/wp:extent/@cy) idiv 9525) else 0" />
        </xsl:when>
        <xsl:when test="wp:inline">
          <xsl:value-of select="if (wp:inline/wp:extent/@cy) then
                                         (number(wp:inline/wp:extent/@cy) idiv 9525) else 0" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="width" as="xs:integer">
      <xsl:choose>
        <xsl:when test="wp:anchor">
          <xsl:value-of select="if (wp:anchor/wp:extent/@cx) then
                                         (number(wp:anchor/wp:extent/@cx) idiv 9525) else 0" />
        </xsl:when>
        <xsl:when test="wp:inline">
          <xsl:value-of select="if (wp:inline/wp:extent/@cx) then
                                         (number(wp:inline/wp:extent/@cx) idiv 9525) else 0" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$width gt 0">
      <xsl:attribute name="width" select="$width" />
    </xsl:if>
    <xsl:if test="$height gt 0">
      <xsl:attribute name="height" select="$height" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="w:drawing" mode="content" as="element(image)">
    <xsl:param name="component" select="false()" tunnel="yes"/>
    <xsl:variable name="rid" select=".//a:graphic/a:graphicData/pic:pic/pic:blipFill/a:blip/@r:embed" />
    <xsl:variable name="count-images-element" select="count($rid)" />
    <xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target" />
    <xsl:variable name="alt" >
      <xsl:choose>
        <xsl:when test="wp:inline">
          <xsl:choose>
            <xsl:when test="wp:inline/wp:docPr/@title != ''">
              <xsl:value-of select="wp:inline/wp:docPr/@title"/>
            </xsl:when>
            <xsl:when test="wp:inline/wp:docPr/@descr != ''">
              <xsl:value-of select="wp:inline/wp:docPr/@descr"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring-after($target, 'media/')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="wp:anchor">
          <xsl:choose>
            <xsl:when test="wp:anchor/wp:docPr/@title != ''">
              <xsl:value-of select="wp:anchor/wp:docPr/@title"/>
            </xsl:when>
            <xsl:when test="wp:anchor/wp:docPr/@descr != ''">
              <xsl:value-of select="wp:anchor/wp:docPr/@descr"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring-after($target, 'media/')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <image src="{concat(if ($component) then '../' else '', $media-folder-name, lower-case(substring-after($target, 'media')))}" alt="{$alt}">
      <xsl:apply-templates select="." mode="drawing-element" />
    </image>
  </xsl:template>

  <!--
  Generate a PSML `image` from a Word `w:pict`. When exists this kind of image inside the 
  one v:group element (transform by one formula the words images size together with only one reference)  
-->
  <xsl:template match="v:shape[1][ancestor::w:pict/v:group or ancestor::w:object/v:group]" mode="pict-group">
    <xsl:variable name="height-file" select="if (contains(substring-after(ancestor::w:pict/v:group/@style,'height:'),';')) then substring-before(substring-after(ancestor::w:pict/v:group/@style,'height:'),';') else substring-after(ancestor::w:pict/v:group/@style,'height:')" />

    <xsl:variable name="height" as="xs:string" select="if (contains($height-file,'pt')) then 
             format-number(number(substring-before($height-file,'pt'))*1.3334,'#') else if (contains($height-file,'in')) then format-number(number(substring-before($height-file,'in'))*96,'#') else format-number(number($height-file),'#')" />

    <xsl:variable name="width-file" select="if (contains(substring-after(ancestor::w:pict/v:group/@style,'width:'),';')) then substring-before(substring-after(ancestor::w:pict/v:group/@style,'width:'),';') else substring-after(ancestor::w:pict/v:group/@style,'width:')" />

    <xsl:variable name="width" as="xs:string" select="if (contains($width-file,'pt')) then 
             format-number(number(substring-before($width-file,'pt'))*1.3334,'#') else if (contains($width-file,'in')) then format-number(number(substring-before($width-file,'in'))*96,'#') else format-number(number($width-file),'#')" />

    <xsl:if test="number($width) gt 0">
      <xsl:attribute name="width" select="number($width)" />
    </xsl:if>
    <xsl:if test="number($height) gt 0">
      <xsl:attribute name="height" select="number($height)" />
    </xsl:if>   
  </xsl:template>

  <xsl:template match="v:shape[ancestor::w:pict[not(v:group)] or ancestor::w:object[not(v:group)]]" mode="pict-group">
    <xsl:variable name="height-file" select="if (contains(substring-after(@style,'height:'),';')) then substring-before(substring-after(@style,'height:'),';') else substring-after(@style,'height:')" />

    <xsl:variable name="height" as="xs:string" select="if (contains($height-file,'pt')) then 
             format-number(number(substring-before($height-file,'pt'))*1.3334,'#') else if (contains($height-file,'in')) then format-number(number(substring-before($height-file,'in'))*96,'#') else format-number(number($height-file),'#')" />

    <xsl:variable name="width-file" select="if (contains(substring-after(@style,'width:'),';')) then substring-before(substring-after(@style,'width:'),';') else substring-after(@style,'width:')" />

    <xsl:variable name="width" as="xs:string" select="if (contains($width-file,'pt')) then 
             format-number(number(substring-before($width-file,'pt'))*1.3334,'#') else if (contains($width-file,'in')) then format-number(number(substring-before($width-file,'in'))*96,'#') else format-number(number($width-file),'#')" />

    <xsl:if test="number($width) gt 0">
      <xsl:attribute name="width" select="number($width)" />
    </xsl:if>
    <xsl:if test="number($height) gt 0">
      <xsl:attribute name="height" select="number($height)" />
    </xsl:if>   
  </xsl:template> 

  <!--
  Generate a PSML `image` from a Word `w:pict`.
-->
  <xsl:template match="v:shape[ancestor::w:pict or ancestor::w:object]" mode="content">
    <xsl:param name="component" select="false()" tunnel="yes"/>
    <xsl:for-each select=".//w:txbxContent/w:p[w:pPr/w:pStyle/@w:val='Caption']">
      <block label="caption">
        <xsl:value-of select="w:r/w:t" />
        <xsl:value-of select="w:fldSimple/w:r/w:t" />
      </block>
    </xsl:for-each>
    <xsl:if test="v:imagedata/@r:id">
      <xsl:variable name="rid" select="v:imagedata/@r:id" />
      <xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target" />
      <xsl:variable name="alt" select="substring-after($target, 'media/')" />

      <image src="{concat(if ($component) then '../' else '', $media-folder-name, lower-case(substring-after($target, 'media')))}" alt="{$alt}">
        <xsl:apply-templates select="." mode="pict-group" />
      </image>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>