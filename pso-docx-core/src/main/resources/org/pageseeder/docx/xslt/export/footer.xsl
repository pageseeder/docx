<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for creating the Word header

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://www.pageseeder.com/function" exclude-result-prefixes="xs w">

<!--
  Function to create footer (not currently used)
-->
<xsl:function name="fn:create-footer">
  <w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" exclude-result-prefixes="#all">
    <w:p>
      <w:pPr>
        <w:jc w:val="center" />
      </w:pPr>
      <w:r>
        <w:pgNum />
      </w:r>
    </w:p>
  </w:ftr>
</xsl:function>

</xsl:stylesheet>
