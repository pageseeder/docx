<?xml version="1.0"?>
<!--
  This XSLT module creates `numbering.xml`

  @author Christine Feng
  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
								exclude-result-prefixes="#all">

<!-- matches root of the numbering.xml from the template -->
<xsl:template match="/" mode="numbering">
	<xsl:apply-templates mode="numbering" />
</xsl:template>

<!-- copies numbering definitions from numbering.xml and creates new numbering definitions according to the existing lists in the pageseeder document -->
<xsl:template match="w:numbering" mode="numbering">
	<xsl:copy>
		<xsl:copy-of select="@*" />
		<xsl:comment><xsl:apply-templates select="$all-different-lists" mode="xml"/></xsl:comment>
		<xsl:apply-templates select="*[name() = 'w:abstractNum']" mode="numbering" />
		<xsl:copy-of select="$all-type-lists/*"/>
		<xsl:apply-templates select="*[name() = 'w:num']" mode="numbering" />
		<xsl:variable name="max-num-id" select="max(//w:num/number(@w:numId))" />
		<xsl:for-each select="$all-different-lists/*">
			<xsl:variable name="start-number" select="if (@start != '') then @start else '1'"/>
			<w:num w:numId="{$max-num-id + position()}">
				<w:abstractNumId w:val="{if (. != '') then . else 1}" />
				<xsl:variable name="current-level" select="@level"/>
				<xsl:variable name="levels" select="'0,1,2,3,4,5,6,7,8'"/>
				<xsl:for-each select="tokenize($levels, ',')">
					<xsl:choose>
						<xsl:when test=". = $current-level">
							<w:lvlOverride w:ilvl="{.}">
								<w:startOverride w:val="{$start-number}"/>
							</w:lvlOverride>
						</xsl:when>
						<xsl:otherwise>
							<w:lvlOverride w:ilvl="{.}">
								<w:startOverride w:val="1"/>
							</w:lvlOverride>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</w:num>
		</xsl:for-each>
	</xsl:copy>
</xsl:template>

<!-- TODO naming convention -->

<!-- Create a level definition according to the configuration document -->
<xsl:template name="createLvl">
	<xsl:param name="level" />
	<xsl:param name="left-indent" />
	<xsl:param name="right-indent" />
	<xsl:param name="hanging" />
	<xsl:param name="format" />
	<xsl:param name="start" />
	<xsl:param name="paragraph-style" />
	<xsl:param name="justification" />
	<xsl:param name="level-text" />

	<w:lvl w:ilvl="{$level - 1}">
		<w:start w:val="{$start}" />
		<w:numFmt w:val="{$format}" />
		<w:lvlText w:val="{$level-text}" />
		<w:lvlJc w:val="{$justification}" />
		<xsl:if test="$paragraph-style != ''">
			<w:pStyle w:val="{$paragraph-style}" />
		</xsl:if>
		<w:pPr>
			<w:ind w:hanging="{$hanging}">
				<xsl:if test="$left-indent != ''">
					<xsl:attribute name="w:left" select="$left-indent" />
				</xsl:if>
				<xsl:if test="$right-indent != ''">
					<xsl:attribute name="w:right" select="$right-indent" />
				</xsl:if>
			</w:ind>
		</w:pPr>
	</w:lvl>
</xsl:template>

<!-- Copy each numbering node recursively -->
<xsl:template match="@*|node()" mode="numbering">
	<xsl:copy>
		<xsl:apply-templates select="@*" mode="styles" />
		<xsl:apply-templates mode="styles" />
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
