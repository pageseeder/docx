<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for Word styles

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
								exclude-result-prefixes="#all">

<!-- 
  Copies the styles.xml from Template and adds new styles from inline and block labels
-->
<xsl:template match="/" mode="styles">
  <xsl:param name="inline-labels" as="element()"/>
  <xsl:param name="block-labels" as="element()"/>
	<xsl:apply-templates  mode="styles">
		<xsl:with-param name="inline-labels" select="$inline-labels" as="element()"/>
		<xsl:with-param name="block-labels" select="$block-labels" as="element()"/>
	</xsl:apply-templates>
</xsl:template>

<!-- template to generate the styles.xml file -->
<xsl:template match="w:styles" mode="styles">
 <xsl:param name="inline-labels" as="element()"/>
 <xsl:param name="block-labels" as="element()"/>
	<xsl:copy>
		<xsl:copy-of select="@*" />
		<xsl:apply-templates mode="styles"/>
		<xsl:for-each select="$inline-labels/label">
		 <xsl:variable name="id" select="concat('psinline',@name)"/>
			<w:style w:type="character" w:styleId="{$id}">
				<w:name w:val="{$id}" />
				<w:basedOn w:val="Normal" />
				<w:rPr><w:bdr w:val="single" w:sz="4" w:space="0" w:color="D99594" w:themeColor="accent2" w:themeTint="99"/></w:rPr>
			</w:style>
		</xsl:for-each>
		<xsl:for-each select="$block-labels/label">
		  <xsl:variable name="id" select="concat('psblock', @name)"/>
		  <w:style w:type="paragraph" w:styleId="{$id}">
			  <w:name w:val="{$id}" />
			  <w:basedOn w:val="Normal" />
			  <w:pPr>
					<w:pBdr>
						<w:top w:val="single" w:sz="4" w:space="1" w:color="8DB3E2" w:themeColor="text2" w:themeTint="66" />
						<w:left w:val="single" w:sz="4" w:space="4" w:color="8DB3E2" w:themeColor="text2" w:themeTint="66" />
						<w:bottom w:val="single" w:sz="4" w:space="1" w:color="8DB3E2" w:themeColor="text2" w:themeTint="66" />
						<w:right w:val="single" w:sz="4" w:space="4" w:color="8DB3E2" w:themeColor="text2" w:themeTint="66" />
					</w:pBdr>
				</w:pPr>
		  </w:style>
		</xsl:for-each>
	</xsl:copy>
</xsl:template>

<!-- standard copy template -->
<xsl:template match="@*|node()" mode="styles">
	<xsl:copy>
		<xsl:apply-templates select="@*" mode="styles"/>
		<xsl:apply-templates mode="styles" />
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
