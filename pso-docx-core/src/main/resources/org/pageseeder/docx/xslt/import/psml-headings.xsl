<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to handle headings.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
								xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
								xmlns:fn="http://www.pageseeder.com/function"
								xmlns:xs="http://www.w3.org/2001/XMLSchema"
								exclude-result-prefixes="#all">

<!--
  Match styles that are configured to transform into a PSML heading.
-->
<xsl:template match="w:p[matches(fn:get-psml-element(w:pPr/w:pStyle/@w:val), 'heading') and not(ancestor::w:tbl)]" mode="content">
	<xsl:param name="document-level" tunnel="yes" />
	<xsl:call-template name="create-heading">
		<xsl:with-param name="style-name" select="w:pPr/w:pStyle/@w:val" />
		<xsl:with-param name="current" select="current()" />
		<xsl:with-param name="full-text" select="fn:get-current-full-text(current())" />
		<xsl:with-param name="has-numbering-format" select="fn:has-numbering-format(w:pPr/w:pStyle/@w:val,current())" />
		<xsl:with-param name="document-level" select="$document-level" />
	</xsl:call-template>
</xsl:template>

<!-- 
  Template to match all paragraphs and ,according to the configuration file:
  1. Creates Headings
  2. Creates Block labels
  3. Creates para elements
  4. Creates lists
 -->
<xsl:template name="create-heading">
  <xsl:param name="style-name"/>
  <xsl:param name="current"/>
  <xsl:param name="full-text"/>
  <xsl:param name="has-numbering-format"/>
  <xsl:param name="document-level"/>

  <xsl:choose>
    <xsl:when test="fn:get-heading-block-label($style-name) != ''">
      <block label="{fn:get-heading-block-label($style-name)}">
        <xsl:element name="heading">
          <xsl:attribute name="level" select="fn:get-heading-level($style-name,$document-level)" />
          <xsl:if test="$current/w:pPr/w:numPr/w:numId or matches($style-name,$numbering-paragraphs-list-string)">
            <xsl:variable name="currentNumId" select="fn:get-numid-from-style($current)" />
            <xsl:variable name="currentLevel" select="fn:get-level-from-element($current)" />
            <xsl:variable name="isBullet" as="xs:boolean"
              select="if ($numbering-document/w:numbering/w:abstractNum[@w:abstractNumId=$currentNumId]/w:lvl[@w:ilvl=$currentLevel]/w:numFmt/@w:val='bullet') then true() else false()" />

            <xsl:if test="not($isBullet)">
              <xsl:choose>
                <xsl:when test="fn:get-numbered-heading-value($style-name)='prefix'">
                  <xsl:if test="$has-numbering-format">
                    <xsl:attribute name="prefix" select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                  </xsl:if>
                </xsl:when>
                <xsl:when test="fn:get-numbered-heading-value($style-name)='numbering'">
                  <xsl:attribute name="numbered" select="'true'" />
                </xsl:when>
              </xsl:choose>
            </xsl:if>
          </xsl:if>

          <xsl:choose>
            <xsl:when test="fn:get-heading-inline-label($style-name) != ''">
              <inline label="{fn:get-heading-inline-label($style-name)}">
                <xsl:if test="fn:get-numbered-heading-value($style-name)='inline' and $list-paragraphs/w:p[@id = $current/@id]">
                  <xsl:if test="$has-numbering-format">
                    <inline label="{fn:get-inline-heading-value($style-name)}">
                      <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                      <xsl:text> </xsl:text>
                    </inline>
                  </xsl:if>
                </xsl:if>

                <xsl:if test="fn:get-numbered-heading-value($style-name)='text' and $list-paragraphs/w:p[@id = $current/@id]">
                  <xsl:if test="$has-numbering-format">
                    <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                    <xsl:text> </xsl:text>
                  </xsl:if>
                </xsl:if>
                <xsl:apply-templates select="$current/*" mode="content">
                  <xsl:with-param name="in-heading" select="true()" />
                  <xsl:with-param name="full-text" select="$full-text" />
                </xsl:apply-templates>
              </inline>
            </xsl:when>

            <xsl:otherwise>
              <xsl:if test="fn:get-numbered-heading-value($style-name)='inline' and $list-paragraphs/w:p[@id = $current/@id]">
                <xsl:if test="$has-numbering-format">
                  <inline label="{fn:get-inline-heading-value($style-name)}">
                    <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                    <xsl:text> </xsl:text>
                  </inline>
                </xsl:if>
              </xsl:if>

              <xsl:if test="fn:get-numbered-heading-value($style-name)='text' and $list-paragraphs/w:p[@id = $current/@id]">
                <xsl:if test="$has-numbering-format">
                  <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                  <xsl:text> </xsl:text>
                </xsl:if>
              </xsl:if>
              <xsl:apply-templates select="$current/*" mode="content">
                <xsl:with-param name="in-heading" select="true()" />
                <xsl:with-param name="full-text" select="$full-text" />
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:element>
      </block>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="heading">
        <xsl:attribute name="level" select="fn:get-heading-level($style-name,$document-level)" />

        <xsl:if test="$current/w:pPr/w:numPr/w:numId or matches($style-name,$numbering-paragraphs-list-string)">

          <xsl:variable name="currentNumId" select="fn:get-numid-from-style($current)" />
          <xsl:variable name="currentAbstractNumId" select="fn:get-abstract-num-id-from-num-id($currentNumId)" />
          <xsl:variable name="currentLevel" select="fn:get-level-from-element($current)" />

          <xsl:variable name="isBullet" as="xs:boolean"
            select="if ($numbering-document/w:numbering/w:abstractNum[@w:abstractNumId=$currentAbstractNumId]/w:lvl[@w:ilvl=$currentLevel]/w:numFmt/@w:val='bullet') then true() else false()" />

          <xsl:if test="not($isBullet)">
            <xsl:choose>
              <xsl:when test="fn:get-numbered-heading-value($style-name)='prefix'">
                <xsl:if test="$has-numbering-format">
                  <xsl:attribute name="prefix" select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                </xsl:if>
              </xsl:when>
              <xsl:when test="fn:get-numbered-heading-value($style-name)='numbering'">
                <xsl:attribute name="numbered" select="'true'" />
              </xsl:when>
            </xsl:choose>
          </xsl:if>
        </xsl:if>

        <xsl:if test="$numbering-list-prefix-exists">
          <xsl:analyze-string regex="({$numbering-match-list-prefix-string})(.*)" select="$full-text">
            <xsl:matching-substring>
              <xsl:attribute name="prefix" select="regex-group(1)" />
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:if>

        <xsl:if test="$numbering-list-autonumbering-exists">
          <xsl:analyze-string regex="({$numbering-match-list-autonumbering-string})(.*)" select="$full-text">
            <xsl:matching-substring>
              <xsl:attribute name="numbered" select="'true'" />
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:if>

        <xsl:choose>
          <xsl:when test="fn:get-heading-inline-label($style-name) != ''">
            <inline label="{fn:get-heading-inline-label($style-name)}">
              <xsl:if test="fn:get-numbered-heading-value($style-name)='inline' and $list-paragraphs/w:p[@id = $current/@id]">
                <xsl:if test="$has-numbering-format">
                  <inline label="{fn:get-inline-heading-value($style-name)}">
                    <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                    <xsl:text> </xsl:text>
                  </inline>
                </xsl:if>
              </xsl:if>

              <xsl:if test="fn:get-numbered-heading-value($style-name)='text' and $list-paragraphs/w:p[@id = $current/@id]">
                <xsl:if test="$has-numbering-format">
                  <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                  <xsl:text> </xsl:text>
                </xsl:if>
              </xsl:if>
              <xsl:apply-templates select="$current/*" mode="content">
                <xsl:with-param name="in-heading" select="true()" />
                <xsl:with-param name="full-text" select="$full-text" />
              </xsl:apply-templates>
            </inline>
          </xsl:when>
          <xsl:otherwise>

            <xsl:if test="fn:get-numbered-heading-value($style-name)='inline' and $list-paragraphs/w:p[@id = $current/@id]">
              <xsl:if test="$has-numbering-format">
                <inline label="{fn:get-inline-heading-value($style-name)}">
                  <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                  <xsl:text> </xsl:text>
                </inline>
              </xsl:if>
            </xsl:if>

            <xsl:if test="fn:get-numbered-heading-value($style-name)='text' and $list-paragraphs/w:p[@id = $current/@id]">
              <xsl:if test="$has-numbering-format">
                <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                <xsl:text> </xsl:text>
              </xsl:if>
            </xsl:if>

            <xsl:apply-templates select="$current/*" mode="content">
              <xsl:with-param name="in-heading" select="true()" />
              <xsl:with-param name="full-text" select="$full-text" />
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

</xsl:stylesheet>