<?xml version="1.0"?>
<!--
  This XSLT module creates the `endnotes.xml`

  @author Philip Rutherford
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!-- Match root of the `endnotes.xml` from the template -->
<xsl:template match="/" mode="endnotes">
  <xsl:apply-templates mode="endnotes" />
</xsl:template>

<!--
  Copy separator definitions from `endnotes.xml` and create new endnote definitions from the PSML document
-->
<xsl:template match="w:endnotes" mode="endnotes">
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates select="w:endnote[@w:id = '-1' or @w:id = '0']" mode="numbering" />
    <xsl:for-each select="$root-document//document[@type=config:endnotes-documenttype()]/section[ends-with(@id,'-content')]/fragment">
      <xsl:variable name="first-xref" select="($root-document//xref[@href=concat('#',current()/@id)])[1]" />
      <w:endnote w:id="{position()}">
        <w:p>
          <w:pPr>
            <w:pStyle w:val="{config:endnote-text-styleid($first-xref/ancestor::document[1]/documentinfo/uri/labels)}" />
          </w:pPr>
          <w:r>
            <w:rPr>
              <w:rStyle w:val="{config:endnote-reference-styleid($first-xref/ancestor::document[1]/documentinfo/uri/labels)}" />
            </w:rPr>
            <w:endnoteRef />
          </w:r>
          <w:r>
            <w:t xml:space="preserve"> </w:t>
          </w:r>
          <xsl:apply-templates select="para[1]/node()" mode="psml" />
        </w:p>
        <xsl:apply-templates select="node()[preceding-sibling::para]" mode="psml" />
      </w:endnote>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

<!-- Copy each endnotes node recursively -->
<xsl:template match="@*|node()" mode="endnotes">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="endnotes" />
    <xsl:apply-templates mode="endnotes" />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
