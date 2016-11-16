<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
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
  xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="#all">

  <xsl:output encoding="UTF-8" method="xml" indent="no" />

    
  <xsl:template match="/">
    <xsl:apply-templates select="element()|text()|comment()|processing-instruction()"/>
  </xsl:template>

  <xsl:template match="attribute()|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="comment()|processing-instruction()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="element()">
    <xsl:copy>
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="w:proofErr"/>
  
</xsl:stylesheet>
