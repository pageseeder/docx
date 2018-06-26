<?xml version="1.0"?>
<!--
  This XSLT module creates the `endnotes.xml`

  @author Philip Rutherford
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:b="http://schemas.openxmlformats.org/officeDocument/2006/bibliography"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!-- Match root of the `customXml/item1.xml` from the template -->
<xsl:template match="/" mode="citations">
  <xsl:apply-templates mode="citations" />
</xsl:template>

<!--
  Copy citation definitions from the PSML document - THEY MUST BE POST PROCESSED INTO WORD FORMAT
-->
<xsl:template match="b:Sources" mode="citations">
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <xsl:for-each select="$root-document//document[@type=config:citations-documenttype()]/section[ends-with(@id,'content')]/properties-fragment">
      <xsl:copy-of select="." />
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
