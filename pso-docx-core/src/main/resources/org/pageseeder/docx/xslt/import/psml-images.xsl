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
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships"
                exclude-result-prefixes="#all">

<!--
  Generate a PSML `image` from a Word `w:drawing`.
-->
<xsl:template match="w:drawing" mode="content" as="element(image)">
  <xsl:variable name="rid" select=".//a:graphic/a:graphicData/pic:pic/pic:blipFill/a:blip/@r:embed" />
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
  Generate a PSML `image` from a Word `w:pict`. When exists this kind of image inside the 
  one v:group element (transform by one formula the words images size together with only one reference)  
-->
<xsl:template match="v:shape[1][ancestor::w:pict/v:group]" mode="pict-group">
    <xsl:variable name="height-file" select="substring-before(substring-after(ancestor::w:pict/v:group/@style,'height:'),';')" />
    
    <xsl:variable name="height" select="if (contains($height-file,'pt')) then 
             number(substring-before($height-file,'pt'))*1.3334 else if (contains($height-file,'in')) then number(substring-before($height-file,'in'))*96 else $height-file" />
 
    <xsl:variable name="width-file" select="substring-before(substring-after(ancestor::w:pict/v:group/@style,'width:'),';')" />
    
    <xsl:variable name="width" select="if (contains($width-file,'pt')) then 
             number(substring-before($width-file,'pt'))*1.3334 else if (contains($width-file,'in')) then number(substring-before($width-file,'in'))*96 else $width-file" />
    
    <xsl:variable name="height-formatted" select="format-number($height,'#####')" />
    <xsl:variable name="width-formatted" select="format-number($width,'#####')" />

    <xsl:if test="number($width-formatted) gt 0">
      <xsl:attribute name="width" select="$width-formatted" />
    </xsl:if>
    <xsl:if test="number($height-formatted) gt 0">
      <xsl:attribute name="height" select="$height-formatted" />
    </xsl:if>   
</xsl:template>

<xsl:template match="v:shape[ancestor::w:pict[not(v:group)]]" mode="pict-group">
    <xsl:variable name="height-file" select="substring-before(substring-after(@style,'height:'),';')" />
    
    <xsl:variable name="height" select="if (contains($height-file,'pt')) then 
             number(substring-before($height-file,'pt'))*1.3334 else if (contains($height-file,'in')) then number(substring-before($height-file,'in'))*96 else $height-file" />
 
    <xsl:variable name="width-file" select="substring-before(substring-after(@style,'width:'),';')" />
    
    <xsl:variable name="width" select="if (contains($width-file,'pt')) then 
             number(substring-before($width-file,'pt'))*1.3334 else if (contains($width-file,'in')) then number(substring-before($width-file,'in'))*96 else $width-file" />
     
    <xsl:variable name="height-formatted" select="format-number($height,'#####')" />
    <xsl:variable name="width-formatted" select="format-number($width,'#####')" />

    <xsl:if test="number($width-formatted) gt 0">
      <xsl:attribute name="width" select="$width-formatted" />
    </xsl:if>
    <xsl:if test="number($height-formatted) gt 0">
      <xsl:attribute name="height" select="$height-formatted" />
    </xsl:if>   
</xsl:template> 

<!--
  Generate a PSML `image` from a Word `w:pict`.
-->
<xsl:template match="v:shape[ancestor::w:pict]" mode="content">
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
    
     <image src="{concat($media-folder-name, substring-after($target, 'media'))}" alt="{$alt}">
        <xsl:apply-templates select="." mode="pict-group" />
    </image>
  </xsl:if>
</xsl:template>

<!--
  Generate a PSML `image` from a Word `w:object` if it includes image data.
-->
<xsl:template match="w:object" mode="content" as="element(image)?">
  <xsl:if test=".//v:shape/v:imagedata/@r:id">
    <xsl:variable name="rid" select=".//v:shape/v:imagedata/@r:id" />
    <xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target" />
    <xsl:variable name="alt" select="substring-after($target,'media/')" />
    <image src="{concat($media-folder-name, substring-after($target,'media'))}" alt="{$alt}" />
  </xsl:if>
</xsl:template> 

</xsl:stylesheet>