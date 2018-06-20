<?xml version="1.0"?>
<!--
  This XSLT module creates the `footnotes.xml`

  @author Philip Rutherford
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!-- Match root of the `footnotes.xml` from the template -->
<xsl:template match="/" mode="footnotes">
  <xsl:apply-templates mode="footnotes" />
</xsl:template>

<!--
  Copy separator definitions from `footnotes.xml` and create new footnote definitions from the PSML document
-->
<xsl:template match="w:footnotes" mode="footnotes">
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates select="w:footnote[@w:id = '-1' or @w:id = '0']" mode="numbering" />
    <xsl:for-each select="$root-document//document[@type=config:footnotes-documenttype()]/section[ends-with(@id,'-content')]/fragment">
      <xsl:variable name="first-xref" select="($root-document//xref[@href=concat('#',current()/@id)])[1]" />
      <w:footnote w:id="{position()}">
        <w:p>
          <w:pPr>
            <w:pStyle w:val="{config:footnote-text-styleid($first-xref/ancestor::document[1]/documentinfo/uri/labels)}" />
          </w:pPr>
          <w:r>
            <w:rPr>
              <w:rStyle w:val="{config:footnote-reference-styleid($first-xref/ancestor::document[1]/documentinfo/uri/labels)}" />
            </w:rPr>
            <w:footnoteRef />
          </w:r>
          <w:r>
            <w:t xml:space="preserve"> </w:t>
          </w:r>
          <xsl:apply-templates select="para[1]/node()" mode="psml" />
        </w:p>
        <xsl:apply-templates select="node()[preceding-sibling::para]" mode="psml" />
      </w:footnote>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

<!-- Copy each footnotes node recursively -->
<xsl:template match="@*|node()" mode="footnotes">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="footnotes" />
    <xsl:apply-templates mode="footnotes" />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
