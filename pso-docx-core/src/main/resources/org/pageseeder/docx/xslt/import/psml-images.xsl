<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to handle the images from `w:drawing`, `w:pict`, and `w:object`.

  All templates in this module assume that images are inside the `media` folder .

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:v="urn:schemas-microsoft-com:vml"
                xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
                xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!--
  Generate a PSML `image` from a Word `w:drawing`.
-->
<xsl:template match="w:drawing" mode="content" as="element(image)">
  <xsl:variable name="rid" select=".//a:graphic/a:graphicData/pic:pic/pic:blipFill/a:blip/@r:embed" />
  <xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target" />
  <xsl:variable name="alt" >
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
  </xsl:variable>
  <!-- TODO Use function here -->
  <xsl:variable name="height" select="if (wp:inline/wp:extent/@cy) then
                                         (number(wp:inline/wp:extent/@cy) idiv 9525) else 0" />
  <xsl:variable name="width" select="if (wp:inline/wp:extent/@cx) then
                                         (number(wp:inline/wp:extent/@cx) idiv 9525) else 0" />
  <image src="{concat($media-folder-name, substring-after($target, 'media'))}" alt="{$alt}">
    <xsl:if test="$width gt 0">
      <xsl:attribute name="width" select="$width" />
    </xsl:if>
    <xsl:if test="$height gt 0">
      <xsl:attribute name="height" select="$height" />
    </xsl:if>
  </image>
</xsl:template>

<!--
  Generate a PSML `image` from a Word `w:pict`.

  If there is a caption it will be included in a block with label `caption`.
-->
<xsl:template match="w:pict" mode="content">
  <xsl:param name="rels" tunnel="yes" />
  <xsl:for-each select=".//w:txbxContent/w:p[w:pPr/w:pStyle/@w:val='Caption']">
    <block label="caption">
      <xsl:value-of select="w:r/w:t" />
      <xsl:value-of select="w:fldSimple/w:r/w:t" />
    </block>
  </xsl:for-each>
  <xsl:if test=".//v:shape/v:imagedata/@r:id">
    <xsl:variable name="rid" select=".//v:shape/v:imagedata/@r:id" />
    <xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target" />
    <xsl:variable name="alt" select="substring-after($target, 'media/')" />
    <image src="{concat($media-folder-name, substring-after($target, 'media'))}" alt="{$alt}" />
  </xsl:if>
</xsl:template>

<!--
  Generate a PSML `image` from a Word `w:object` if it includes image data.
-->
<xsl:template match="w:object" mode="content" as="element(image)?">
  <xsl:param name="rels" tunnel="yes" />
  <xsl:if test=".//v:shape/v:imagedata/@r:id">
    <xsl:variable name="rid" select=".//v:shape/v:imagedata/@r:id" />
    <xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target" />
    <xsl:variable name="alt" select="substring-after($target,'media/')" />
    <image src="{concat($media-folder-name,substring-after($target,'media'))}" alt="{$alt}" />
  </xsl:if>
</xsl:template>

</xsl:stylesheet>