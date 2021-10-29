<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to generate bibliography entries as nested block and inline elements.

  In OOXML, the bibliography is stored in the `customXML/item[N].xml` file.

  @author Philip Rutherford

  @since 0.8.20
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:b="http://schemas.openxmlformats.org/officeDocument/2006/bibliography"
                exclude-result-prefixes="#all">

<!--
  Generate bibliography entries.
-->
<xsl:template match="w:p[w:r/w:instrText='BIBLIOGRAPHY']" mode="content">
  <!-- check first 5 customXML/item[N].xml files -->
  <xsl:for-each select="1 to 5">
    <xsl:variable name="bibliography-file" select="concat($_rootfolder,'customXML/item',.,'.xml')"/>
    <xsl:if test="doc-available($bibliography-file)">
      <xsl:apply-templates select="document($bibliography-file)/b:Sources/b:Source" mode="bibliography" />
    </xsl:if>
  </xsl:for-each>
</xsl:template>

<!-- Template to match each source -->
<xsl:template match="b:Source" mode="bibliography">
  <block label="BibSource">
    <anchor name="bs-{b:Tag}" />
    <xsl:for-each select="b:Author/b:Author/b:NameList/b:Person">
      <para>
        <xsl:apply-templates mode="bibliography"/>
      </para>
    </xsl:for-each>
    <xsl:for-each select="b:Author/b:Author/b:Corporate">
      <para>
        <xsl:apply-templates select="." mode="bibliography"/>
      </para>
    </xsl:for-each>
    <para>
      <xsl:apply-templates select="*[not(self::b:Author or self::b:Tag or self::b:Guid or self::b:RefOrder)]" mode="bibliography"/>
    </para>
  </block>
</xsl:template>

<!-- Template to match inline bibliography elements -->
<xsl:template match="*" mode="bibliography">
  <xsl:if test="normalize-space(.) != ''">
    <inline label="{local-name()}">
      <xsl:value-of select="." />
    </inline>
    <xsl:text> </xsl:text>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>