<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:fn="http://www.pageseeder.com/function"  exclude-result-prefixes="#all">

<!-- 
Function to create header: not currently used
 -->
	<xsl:function name="fn:createheader">
		<w:hdr xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
			xmlns:o="urn:schemas-microsoft-com:office:office"
			xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
			xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
			xmlns:v="urn:schemas-microsoft-com:vml"
			xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
			xmlns:w10="urn:schemas-microsoft-com:office:word"
			xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
			xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml">
			<w:p>
				<w:pPr>
					<w:jc w:val="center" />
				</w:pPr>
				<w:r>
					<w:t>
					</w:t>
				</w:r>
			</w:p>
		</w:hdr>
	</xsl:function>
</xsl:stylesheet>