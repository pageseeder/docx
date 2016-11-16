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
	xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
  xmlns:fn="http://www.pageseeder.com/function" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all">

	<xsl:decimal-format name="digits" decimal-separator="." grouping-separator="," />

	
<!-- 	<xsl:template match="preprocessed" mode="content"> -->
<!--       <xsl:apply-templates select="w:document" mode="content" /> -->
<!--   </xsl:template> -->
  
  <!--##root##-->
  <!--##properties##-->
  <!--##toc##-->
  <!-- Initial match of the w:document -->
	<xsl:template match="w:document" mode="content">

		<document level="portable">
      <xsl:if test="fn:document-type-for-main-document() != ''"> 
       <xsl:attribute name="type" select="fn:document-type-for-main-document()"/>
      </xsl:if>
		  <documentinfo>
        <uri title="{$document-title}">
          <displaytitle>
            <xsl:value-of select="$document-title" />
          </displaytitle>
          <xsl:if test="fn:document-label-for-main-document() != ''"> 
            <labels><xsl:value-of select="fn:document-label-for-main-document()"/></labels>
          </xsl:if>
        </uri>
      </documentinfo>
		  <xsl:choose>
		    <xsl:when test="$generate-processed-psml">
		      <xsl:apply-templates select="w:body" mode="processedpsml" />
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:apply-templates select="w:body" mode="content" />
		    </xsl:otherwise>
		  </xsl:choose>
<!-- 			<xsl:copy-of select="$list-index-translated"/> -->
		</document>
		
    <xsl:if test="$generate-index-files">
      <xsl:apply-templates select="$list-index" mode="index-files"/>
    </xsl:if>
    
		<xsl:if test="$generate-index-files">
		  <xsl:apply-templates select="$list-index" mode="index-files"/>
		</xsl:if>
    
    <xsl:if test="$generate-mathml-files">
      <xsl:apply-templates select="$list-mathml" mode="mathml"/>
    </xsl:if>
    
    
    <xsl:if test="doc-available($footnotes-file) and $convert-footnotes">
      <xsl:apply-templates select="$footnotes" mode="footnotes"/>
    </xsl:if>
    
    <xsl:if test="doc-available($endnotes-file) and $convert-endnotes">
      <xsl:apply-templates select="$endnotes" mode="endnotes"/>
    </xsl:if>
    
    
	</xsl:template>

</xsl:stylesheet>