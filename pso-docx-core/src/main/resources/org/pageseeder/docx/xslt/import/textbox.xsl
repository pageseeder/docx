<?xml version="1.0" encoding="utf-8"?>
<!--

  @author Adriano Akaishi

  @version 0.0.1
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:v="urn:schemas-microsoft-com:vml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
                xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships"
                xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
                exclude-result-prefixes="#all">

      
 <xsl:template match="v:textbox" mode="textbox">
   <block label="ps_textbox">
     <xsl:for-each select="w:txbxContent/w:p[normalize-space(.)!='']">
       <para><xsl:value-of select="." /></para>
     </xsl:for-each>
   </block>
 </xsl:template> 
 
 <xsl:template match="text()" mode="textbox" /> 

</xsl:stylesheet> 