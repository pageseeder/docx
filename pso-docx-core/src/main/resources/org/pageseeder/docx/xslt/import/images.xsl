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
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
  xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all">

<!--
  template to generate w:drawing as pageseeder image; Assumas that images will be inside 'media' folder 

-->
	<xsl:template match="w:drawing" mode="content">
		<xsl:variable name="rid" select=".//a:graphic/a:graphicData/pic:pic/pic:blipFill/a:blip/@r:embed" />
		<xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target" />
		<xsl:variable name="alt" >
      <xsl:choose>
        <xsl:when test="wp:inline/wp:docPr/@descr != ''">
          <xsl:value-of select="wp:inline/wp:docPr/@descr"/>
        </xsl:when>
        <xsl:when test="wp:inline/wp:docPr/@title != ''">
          <xsl:value-of select="wp:inline/wp:docPr/@title"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-after($target,'media/')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
		<xsl:variable name="height" select="if (./wp:inline/wp:extent/@cy) then 
				                                   (number(./wp:inline/wp:extent/@cy) idiv 9525) else 0" />
		<xsl:variable name="width" select="if (./wp:inline/wp:extent/@cx) then 
                                           (number(./wp:inline/wp:extent/@cx) idiv 9525) else 0" />
		<image src="{concat($media-folder-name,substring-after($target,'media'))}" alt="{$alt}">
			<xsl:if test="$width!=0">
				<xsl:attribute name="width" select="$width" />
			</xsl:if>
			<xsl:if test="$height!=0">
				<xsl:attribute name="height" select="$height" />
			</xsl:if>
		</image>
	</xsl:template>

<!--
  template to generate w:pict as pageseeder image; Assumes that images will be inside 'media' folder 

-->
	<xsl:template match="w:pict" mode="content">
		<xsl:param name="rels" tunnel="yes" />
				<!--##caption##-->
		<xsl:for-each select=".//w:txbxContent/w:p[w:pPr/w:pStyle/@w:val='Caption']">
			<block label="caption">
				<xsl:value-of select="w:r/w:t" />
				<xsl:value-of select="w:fldSimple/w:r/w:t" />
			</block>
		</xsl:for-each>
				<!--##graphic##-->
		<xsl:if test=".//v:shape/v:imagedata/@r:id">
			<xsl:variable name="rid" select=".//v:shape/v:imagedata/@r:id" />
			<xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target" />
			<xsl:variable name="alt" select="substring-after($target,'media/')" />
			<image src="{concat($media-folder-name,substring-after($target,'media'))}" alt="{$alt}" />
		</xsl:if>
	</xsl:template>
	
  <!--  template to generate w:object as pageseeder image if an image exists  -->
	<xsl:template match="w:object" mode="content">
    <xsl:param name="rels" tunnel="yes" />
        <!--##graphic##-->
    <xsl:if test=".//v:shape/v:imagedata/@r:id">
      <xsl:variable name="rid" select=".//v:shape/v:imagedata/@r:id" />
      <xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target" />
      <xsl:variable name="alt" select="substring-after($target,'media/')" />
      <image src="{concat($media-folder-name,substring-after($target,'media'))}" alt="{$alt}" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>