<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for creating the Word header

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
								xmlns:fn="http://www.pageseeder.com/function" exclude-result-prefixes="#all">

<!-- TODO naming convention and mode to file for footers, remove useless xmlns -->

<!--
	Function to create header (not currently used)
-->
<xsl:function name="fn:create-header">
	<w:hdr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
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
