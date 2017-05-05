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
  
  <xsl:param name="_imagelist" select="'root'" as="xs:string"/>
  
  <xsl:variable name="imagelistdocument" select="unparsed-text($_imagelist,'UTF-8')"/>
  
  
  <xsl:variable name="lines" select="if($imagelistdocument) then tokenize($imagelistdocument, '\n') else 'NONE'" as="xs:string+" />
  
  <xsl:variable name="lines-element">
    <lines>
    <xsl:for-each select="$lines">
      <line>
        <xsl:for-each select="tokenize(., '###')">
          <xsl:if test="position() = 1">
            <original><xsl:value-of select="."/></original>
          </xsl:if>
          <xsl:if test="position() = 2">
            <id><xsl:value-of select="."/></id>
          </xsl:if>
          <xsl:if test="position() = 3">
            <new><xsl:value-of select="."/></new>
          </xsl:if>
        </xsl:for-each>
      </line>
    </xsl:for-each>
    </lines>
  </xsl:variable>
  
  <!-- template to rename all images if needed -->
 <xsl:template match="/">
    <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
      <xsl:for-each select=".//*[name() = 'Relationship']">
        <xsl:copy-of select=".[@Type!='http://schemas.openxmlformats.org/officeDocument/2006/relationships/image']"></xsl:copy-of>
      </xsl:for-each>
      <xsl:for-each select=".//*[@Type='http://schemas.openxmlformats.org/officeDocument/2006/relationships/image']">
        <xsl:variable name="currentId" select="@Id"/>
        <xsl:variable name="currentTarget" select="@Target"/>
        <Relationship Target="{if($lines-element//line[id= $currentId]/new) then ($lines-element//line[id= $currentId]/new)[1] else $currentTarget}">
          <xsl:copy-of select="@*[name() !='Target']"/>
        </Relationship>
      </xsl:for-each>
    </Relationships>
  </xsl:template>

  <!-- recursevely copy -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>
  
  

</xsl:stylesheet>