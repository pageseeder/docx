<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for processing PSML paragraphs.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!-- Ignore any paragraphs that have their style marked to ignore in the config -->
<xsl:template match="w:p[matches(w:pPr/w:pStyle/@w:val, config:ignore-paragraph-match-list-string())]" mode="content" priority="100"/>

<!-- Ignore any paragraphs that have their style marked up as specific for fragment split in the config -->
<xsl:template match="w:p[matches(w:pPr/w:pStyle/@w:val, config:section-specific-split-styles-string())]" mode="content"  priority="100"/>

<!-- Ignore any paragraphs that have their style marked up as specific for document split in the config -->
<xsl:template match="w:p[matches(w:pPr/w:pStyle/@w:val, config:document-specific-split-styles-string())]" mode="content"  priority="100"/>

<!-- Ignore any paragraphs that have their style marked up as specific for heading in the config but have no content -->
<xsl:template match="w:p[matches(config:get-psml-element(w:pPr/w:pStyle/@w:val),'heading') and string-join((w:r|w:hyperlink)//text(), '') = '']" mode="content"  priority="100"/>

<!-- Ignore any paragraphs that have their style marked up caption( handled inside the table itself -->
<xsl:template match="w:p[matches(config:get-psml-element(w:pPr/w:pStyle/@w:val),'caption') and ( (following-sibling::*[1][name() = 'w:tbl'][not(w:tblPr/w:tblStyle/@w:val)] and config:get-caption-table-value(w:pPr/w:pStyle/@w:val) = 'default')
                            or  (following-sibling::*[1][name() = 'w:tbl'][w:tblPr/w:tblStyle/@w:val= config:get-caption-table-value(w:pPr/w:pStyle/@w:val)] and config:get-caption-table-value(w:pPr/w:pStyle/@w:val) != '' ))]"
    mode="content" />

<!--
  Handle any styles that are mapped for transformation into block labels
-->
<xsl:template match="w:p[matches(config:get-psml-element(w:pPr/w:pStyle/@w:val), 'block')]" mode="content" as="element(block)">
  <block label="{config:get-block-label-from-psml-element(w:pPr/w:pStyle/@w:val)}">
    <xsl:apply-templates select="./*" mode="content">
      <xsl:with-param name="full-text" select="fn:get-current-full-text(current())" />
    </xsl:apply-templates>
  </block>
</xsl:template>

<!--
  Handle any styles that are mapped for transformation into preformat elements
-->
<xsl:template match="w:p[matches(config:get-psml-element(w:pPr/w:pStyle/@w:val), 'preformat')]" mode="content" as="element(preformat)">
  <preformat>
    <xsl:apply-templates select="*" mode="content">
      <xsl:with-param name="full-text" select="fn:get-current-full-text(current())" />
    </xsl:apply-templates>
  </preformat>
</xsl:template>

<!--
  Handle any styles that are mapped for transformation into inline labels
-->
<xsl:template match="w:p[matches(config:get-psml-element(w:pPr/w:pStyle/@w:val), 'inline')]" mode="content" as="element(para)">
  <para>
    <inline label="{config:get-inline-label-from-psml-element(w:pPr/w:pStyle/@w:val)}">
      <xsl:apply-templates select="*" mode="content">
        <xsl:with-param name="full-text" select="fn:get-current-full-text(current())" />
      </xsl:apply-templates>
    </inline>
  </para>
</xsl:template>

<!--
  Handle any styles that are mapped for transformation into monospace elements
-->
<xsl:template match="w:p[matches(config:get-psml-element(w:pPr/w:pStyle/@w:val), 'monospace')]" mode="content" as="element(para)">
  <para>
    <monospace>
      <xsl:apply-templates select="*" mode="content">
        <xsl:with-param name="full-text" select="fn:get-current-full-text(current())" />
      </xsl:apply-templates>
    </monospace>
  </para>
</xsl:template>

<!--
  Handle any styles that are mapped for transformation into para
-->
<xsl:template match="w:p[matches(config:get-psml-element(w:pPr/w:pStyle/@w:val), 'para')]" mode="content">
  <xsl:call-template name="create-para">
    <xsl:with-param name="style-name" select="w:pPr/w:pStyle/@w:val" />
    <xsl:with-param name="current-num-id" select="fn:get-numid-from-style(.)" />
    <xsl:with-param name="current" select="current()" />
    <xsl:with-param name="full-text" select="fn:get-current-full-text(current())" />
    <xsl:with-param name="has-numbering-format" select="fn:has-numbering-format(w:pPr/w:pStyle/@w:val,current())" />
  </xsl:call-template>
</xsl:template>

<!--
  Handle any styles that are mapped for transformation into para and handling of inline, block and list generation
-->
<xsl:template name="create-para" >
  <xsl:param name="style-name"/>
  <xsl:param name="current-num-id"/>
  <xsl:param name="current"/>
  <xsl:param name="full-text"/>
  <xsl:param name="has-numbering-format"/>
  <xsl:choose>
    <xsl:when test="config:get-para-block-label($style-name) != ''">
      <block label="{config:get-para-block-label($style-name)}">
        <xsl:element name="para">
          <xsl:if test="config:get-para-indent($style-name) != ''">
            <xsl:attribute name="indent" select="config:get-para-indent($style-name)" />
          </xsl:if>
          <xsl:if test="$current/w:pPr/w:numPr/w:numId or matches($style-name,$numbering-paragraphs-list-string)">
            <xsl:variable name="currentNumId">
              <xsl:value-of select="fn:get-numid-from-style($current)" />
            </xsl:variable>

            <xsl:variable name="currentLevel">
              <xsl:value-of select="fn:get-level-from-element($current)" />
            </xsl:variable>

            <xsl:variable name="isBullet" as="xs:boolean"
              select="if ($numbering-document/w:numbering/w:abstractNum[@w:abstractNumId=$currentNumId]/w:lvl[@w:ilvl=$currentLevel]/w:numFmt/@w:val='bullet') then true() else false()" />

            <xsl:if test="not($isBullet)">
              <xsl:choose>
                <xsl:when test="config:get-numbered-para-value($style-name)='prefix'">
                  <xsl:if test="$has-numbering-format">
                    <xsl:attribute name="prefix" select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                  </xsl:if>
                </xsl:when>
                <xsl:when test="config:get-numbered-para-value($style-name)='numbering'">
                  <xsl:attribute name="numbered" select="'true'" />
                </xsl:when>
              </xsl:choose>

            </xsl:if>
          </xsl:if>

          <xsl:if test="config:numbering-list-prefix-exists()">
            <xsl:analyze-string regex="({config:numbering-match-list-prefix-string()})(.*)" select="$full-text">
              <xsl:matching-substring>
                <xsl:attribute name="prefix" select="regex-group(1)" />
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:if>

          <xsl:if test="config:numbering-list-autonumbering-exists()">
            <xsl:analyze-string regex="({config:numbering-match-list-autonumbering-string()})(.*)" select="$full-text">
              <xsl:matching-substring>
                <xsl:attribute name="numbered" select="'true'" />
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:if>

          <xsl:choose>
            <xsl:when test="config:get-para-inline-label($style-name) != ''">
              <inline label="{config:get-para-inline-label($style-name)}">
                <xsl:if test="config:get-numbered-para-value($style-name)='inline' and $list-paragraphs/w:p[@id = $current/@id]">
                  <xsl:if test="$has-numbering-format">
                    <inline label="{config:get-inline-para-value($style-name)}">
                      <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                      <xsl:text> </xsl:text>
                    </inline>
                  </xsl:if>
                </xsl:if>

                <xsl:if test="config:get-numbered-para-value($style-name)='text' and $list-paragraphs/w:p[@id = $current/@id]">
                  <xsl:if test="$has-numbering-format">
                    <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                    <xsl:text> </xsl:text>
                  </xsl:if>
                </xsl:if>
                <xsl:apply-templates select="$current/*" mode="content">
                  <xsl:with-param name="full-text" select="$full-text" />
                </xsl:apply-templates>
              </inline>
            </xsl:when>
            <xsl:otherwise>

              <xsl:if test="config:get-numbered-para-value($style-name)='inline' and $list-paragraphs/w:p[@id = $current/@id]">
                <xsl:if test="$has-numbering-format">
                  <inline label="{config:get-inline-para-value($style-name)}">
                    <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                    <xsl:text> </xsl:text>
                  </inline>
                </xsl:if>
              </xsl:if>

              <xsl:if test="config:get-numbered-para-value($style-name)='text' and $list-paragraphs/w:p[@id = $current/@id]">
                <xsl:if test="$has-numbering-format">
                  <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                  <xsl:text> </xsl:text>
                </xsl:if>
              </xsl:if>
              <xsl:apply-templates select="$current/*" mode="content">
                <xsl:with-param name="full-text" select="$full-text" />
              </xsl:apply-templates>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:element>
      </block>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="para">
        <xsl:if test="config:get-para-indent($style-name) != ''">
          <xsl:attribute name="indent" select="config:get-para-indent($style-name)" />
        </xsl:if>
        <xsl:if test="$current/w:pPr/w:numPr/w:numId or matches($style-name,$numbering-paragraphs-list-string)">

          <xsl:variable name="currentNumId">
            <xsl:value-of select="fn:get-numid-from-style($current)" />
          </xsl:variable>

          <xsl:variable name="currentAbstractNumId">
            <xsl:value-of select="fn:get-abstract-num-id-from-num-id($currentNumId)" />
          </xsl:variable>

          <xsl:variable name="currentLevel">
            <xsl:value-of select="fn:get-level-from-element($current)" />
          </xsl:variable>

          <xsl:variable name="isBullet" as="xs:boolean"
            select="if ($numbering-document/w:numbering/w:abstractNum[@w:abstractNumId=$currentAbstractNumId]/w:lvl[@w:ilvl=$currentLevel]/w:numFmt/@w:val='bullet') then true() else false()" />

          <xsl:if test="not($isBullet)">
            <xsl:choose>
              <xsl:when test="config:get-numbered-para-value($style-name)='prefix'">
                <xsl:if test="$has-numbering-format">
                  <xsl:attribute name="prefix" select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                </xsl:if>
              </xsl:when>
              <xsl:when test="config:get-numbered-para-value($style-name)='numbering'">
                <xsl:attribute name="numbered" select="'true'" />
              </xsl:when>
            </xsl:choose>
          </xsl:if>
        </xsl:if>

        <xsl:if test="config:numbering-list-prefix-exists()">
          <xsl:analyze-string regex="({config:numbering-match-list-prefix-string()})(.*)" select="$full-text">
            <xsl:matching-substring>
              <xsl:attribute name="prefix" select="regex-group(1)" />
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:if>

        <xsl:if test="config:numbering-list-autonumbering-exists()">
          <xsl:analyze-string regex="({config:numbering-match-list-autonumbering-string()})(.*)" select="$full-text">
            <xsl:matching-substring>
              <xsl:attribute name="numbered" select="'true'" />
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:if>

        <xsl:choose>
          <xsl:when test="config:get-para-inline-label($style-name) != ''">
            <inline label="{config:get-para-inline-label($style-name)}">
              <xsl:if test="config:get-numbered-para-value($style-name)='inline' and $list-paragraphs/w:p[@id = $current/@id]">
                <xsl:if test="$has-numbering-format">
                  <inline label="{config:get-inline-para-value($style-name)}">
                    <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                    <xsl:text> </xsl:text>
                  </inline>
                </xsl:if>
              </xsl:if>

              <xsl:if test="config:get-numbered-para-value($style-name)='text' and $list-paragraphs/w:p[@id = $current/@id]">
                <xsl:if test="$has-numbering-format">
                  <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                  <xsl:text> </xsl:text>
                </xsl:if>
              </xsl:if>
              <xsl:apply-templates select="$current/*" mode="content">
                <xsl:with-param name="full-text" select="$full-text" />
              </xsl:apply-templates>
            </inline>
          </xsl:when>
          <xsl:otherwise>

            <xsl:if test="config:get-numbered-para-value($style-name)='inline' and $list-paragraphs/w:p[@id = $current/@id]">
              <xsl:if test="$has-numbering-format">
                <inline label="{config:get-inline-para-value($style-name)}">
                  <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                  <xsl:text> </xsl:text>
                </inline>
              </xsl:if>
            </xsl:if>

            <xsl:if test="config:get-numbered-para-value($style-name)='text' and $list-paragraphs/w:p[@id = $current/@id]">
              <xsl:if test="$has-numbering-format">
                <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                <xsl:text> </xsl:text>
              </xsl:if>
            </xsl:if>
            <xsl:apply-templates select="$current/*" mode="content">
              <xsl:with-param name="full-text" select="$full-text" />
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Template to match all paragraphs by default.

  Handles if the paragraph is by default set to generate a block label, or a para; Also handles any manual numbering
-->
<xsl:template match="w:p[config:get-psml-element(w:pPr/w:pStyle/@w:val) = '']" mode="content">
  <xsl:variable name="current" select="current()" as="node()"/>
  <xsl:choose>
    <!-- if the element is set to create a block in the config file -->
    <xsl:when test="$paragraph-styles = 'block' and w:pPr/w:pStyle/@w:val !=''">
      <block label="{w:pPr/w:pStyle/@w:val}">
        <xsl:apply-templates select="*" mode="content">
          <xsl:with-param name="full-text" select="fn:get-current-full-text($current)" />
        </xsl:apply-templates>
      </block>
      <xsl:apply-templates mode="textbox" /> 
    </xsl:when>
    <xsl:when test="w:pPr/w:sectPr/w:pgSz">
      <xsl:variable name="type-page" select="if (w:pPr/w:sectPr/w:pgSz/@w:orient) then 'landscape_end' else 'portrait_end'" />
      <block label="{$type-page}" />
    </xsl:when>
    <xsl:otherwise>
      <para>
        <xsl:if test="config:numbering-list-prefix-exists()">
          <xsl:analyze-string regex="({config:numbering-match-list-prefix-string()})(.*)" select="fn:get-current-full-text($current)">
            <xsl:matching-substring>
              <xsl:attribute name="prefix" select="regex-group(1)"/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:if>
        <xsl:if test="config:numbering-list-autonumbering-exists()">
          <xsl:analyze-string regex="({config:numbering-match-list-autonumbering-string()})(.*)" select="fn:get-current-full-text($current)">
            <xsl:matching-substring>
              <xsl:attribute name="numbered" select="'true'"/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:if>
        <xsl:apply-templates select="*" mode="content">
          <xsl:with-param name="full-text" select="fn:get-current-full-text($current)" />
        </xsl:apply-templates>
      </para>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Template to match the end of section word page

  Adds the block label and analysis if this section it is portrait or landscape
-->

<xsl:template match="w:sectPr/w:pgSz" mode="content">
  <xsl:variable name="type-page" select="if (@w:orient) then 'landscape_end' else 'portrait_end'" />
  <block label="{$type-page}" />
</xsl:template>

</xsl:stylesheet>