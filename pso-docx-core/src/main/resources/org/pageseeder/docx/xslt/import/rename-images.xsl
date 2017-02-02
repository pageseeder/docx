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
  
  <xsl:param name="_rootfolder" select="'root'" as="xs:string"/>
  <xsl:variable name="rels" select="concat($_rootfolder,'word/_rels/document.xml.rels')"  as="xs:string?"/>
  <xsl:variable name="relationship-document" select="document($rels)" as="node()"/>
  
  <xsl:template match="/">
    <xsl:for-each select=".//w:drawing|.//w:pict">
      <xsl:sort select=".//a:graphic/a:graphicData/pic:pic/pic:blipFill/a:blip/@r:embed|.//v:shape/v:imagedata/@r:id"/>
      <xsl:choose>
        <xsl:when test="matches(wp:inline/wp:docPr/@name,'\d+')">
          <xsl:variable name="rid" select=".//a:graphic/a:graphicData/pic:pic/pic:blipFill/a:blip/@r:embed" />
          <xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target" />
          <xsl:variable name="type" select="substring-after($target,'.')" />
          <xsl:value-of select="concat($target,'###',$rid,'###','media/',wp:inline/wp:docPr/@name,'.',$type,'&#10;')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="rid" select=".//a:graphic/a:graphicData/pic:pic/pic:blipFill/a:blip/@r:embed|.//v:shape/v:imagedata/@r:id" />
          <xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target" />
          <xsl:value-of select="concat($target,'###',$rid,'&#10;')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>