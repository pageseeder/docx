<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to handle the general Word formatting from text runs and smart tags.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!--
  Turn a `smartTags` into inline labels or just keep them as text based on the configuration
-->
<xsl:template match="w:smartTag" mode="content">
  <xsl:choose>
    <xsl:when test="config:keep-smart-tags()">
      <inline label="{concat('st-',@w:element)}">
        <xsl:apply-templates mode="content" />
      </inline>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="content" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Match each pre-processed text run individually -->
<xsl:template match="w:r" mode="content">
  <xsl:param name="full-text" />
  <xsl:param name="in-heading" select="false()" />
  <xsl:variable name="position" select="count(preceding-sibling::w:r)" />
  <!-- Name of text run style (if available) -->
  <xsl:variable name="character-style-name" select="./w:rPr[1]/w:rStyle[1]/@w:val[1]" />

  <!-- Variable to define if an element has been defined for this current style  -->
  <xsl:variable name="inline-value" select="config:get-inline-label-from-psml-element($character-style-name)" />

  <!-- bold italic, underline, subscript and superscript are processed recursively -->
  <xsl:variable name="monospace" select="if (config:get-psml-element($character-style-name) = 'monospace') then 'true' else 'false'" />
  <xsl:variable name="bold" select="if (current()[w:rPr/w:b[not(@w:val = '0')]]) then 'true' else 'false'" />
  <xsl:variable name="italic" select="if (current()[w:rPr/w:i[not(@w:val = '0')]]) then 'true' else 'false'" />
  <xsl:variable name="underline" select="if (current()[w:rPr/w:u[not(@w:val = '0')]]) then 'true' else 'false'" />
  <xsl:variable name="sub" select="if (current()[w:rPr/w:vertAlign[not(@w:val = '0')][@w:val='subscript']]) then 'true' else 'false'" />
  <xsl:variable name="sup" select="if (current()[w:rPr/w:vertAlign[not(@w:val = '0')][@w:val='superscript']]) then 'true' else 'false'" />
  <xsl:variable name="in-hyperlink" select="if (current()[ancestor::*[name() = 'w:hyperlink']]) then 'true' else 'false'" />

  <xsl:for-each select="*">
    <!-- Check if the w:r and containing w:p are numbered -->
    <!-- TODO Simplify -->
    <xsl:variable name="is-numbered" as="xs:boolean">
      <xsl:choose>
        <xsl:when test="$position = 0 and matches($full-text,config:numbering-match-list-string()) and config:convert-manual-numbering()">
          <xsl:value-of select="true()" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <!-- Ignore text inside a form field -->
      <xsl:when test="current()/name() = 'w:t' and
          preceding::w:fldChar[@w:fldCharType='begin' or @w:fldCharType='end'][1][w:ffData/w:name/@w:val]">
      </xsl:when>
      
      <!-- Handle form field -->
      <xsl:when test="current()/name() = 'w:fldChar' and w:ffData/w:name/@w:val">
        <inline label="ps_field">
          <inline label="ps_field_name">
            <xsl:value-of select="w:ffData/w:name/@w:val" />
          </inline>
          <xsl:value-of select="normalize-space(w:ffData/w:textInput/w:default/@w:val)" />
        </inline>
      </xsl:when>
      
      <!-- Check if the text is inside a field code -->
      <xsl:when test="current()/name() = 'w:t' and preceding::*[name() = 'w:fldChar'][1][@w:fldCharType='separate']">
        <xsl:call-template name="apply-wr-style">
          <xsl:with-param name="style" select="$character-style-name" />
          <xsl:with-param name="text" select="current()" />
          <xsl:with-param name="bold" select="$bold" />
          <xsl:with-param name="italic" select="$italic" />
          <xsl:with-param name="underline" select="$underline" />
          <xsl:with-param name="sub" select="$sub" />
          <xsl:with-param name="sup" select="$sup" />
          <xsl:with-param name="monospace" select="$monospace" />
          <xsl:with-param name="in-heading" select="$in-heading" />
          <xsl:with-param name="inline-value" select="if ($inline-value != '') then $inline-value else ''" />
          <xsl:with-param name="is-numbered" select="$is-numbered" />
          <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
          <xsl:with-param name="in-link" select="'true'"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="current()/name() = 'w:t' and ancestor::*[name() = 'w:hyperlink']">
        <xsl:call-template name="apply-wr-style">
          <xsl:with-param name="style" select="$character-style-name" />
          <xsl:with-param name="text" select="current()" />
          <xsl:with-param name="bold" select="$bold" />
          <xsl:with-param name="italic" select="$italic" />
          <xsl:with-param name="underline" select="$underline" />
          <xsl:with-param name="sub" select="$sub" />
          <xsl:with-param name="sup" select="$sup" />
          <xsl:with-param name="monospace" select="$monospace" />
          <xsl:with-param name="in-heading" select="$in-heading" />
          <xsl:with-param name="inline-value" select="if ($inline-value != '') then $inline-value else ''" />
          <xsl:with-param name="is-numbered" select="$is-numbered" />
          <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
          <xsl:with-param name="in-link" select="'false'"/>
        </xsl:call-template>
      </xsl:when>

      <!-- Check if it is text -->
      <xsl:when test="current()/name() = 'w:t'">
        <xsl:call-template name="apply-wr-style">
          <xsl:with-param name="style" select="$character-style-name" />
          <xsl:with-param name="text" select="current()" />
          <xsl:with-param name="bold" select="$bold" />
          <xsl:with-param name="italic" select="$italic" />
          <xsl:with-param name="underline" select="$underline" />
          <xsl:with-param name="sub" select="$sub" />
          <xsl:with-param name="sup" select="$sup" />
          <xsl:with-param name="monospace" select="$monospace" />
          <xsl:with-param name="in-heading" select="$in-heading" />
          <xsl:with-param name="inline-value" select="if ($inline-value != '') then $inline-value else ''" />
          <xsl:with-param name="is-numbered" select="$is-numbered" />
          <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
          <xsl:with-param name="in-link" select="'false'" />
        </xsl:call-template>
      </xsl:when>

      <!-- When is a break to page or column (do nothing) -->
      <xsl:when test="current()/name() = 'w:br' and (current()/@w:type = 'page' or current()/@w:type = 'column')"/>
      <!-- When is a break -->
      <xsl:when test="current()/name() = 'w:br'">
        <br />
      </xsl:when>
      <!-- When is a tab it is replaced by the corresponding tab unicode -->
      <xsl:when test="current()/name() = 'w:tab'">
        <xsl:text>&#x9;</xsl:text>
      </xsl:when>
      <!-- When is a noBreakHyphen replace it by a normal hyphen -->
      <xsl:when test="current()/name() = 'w:noBreakHyphen'">
        <xsl:text>-</xsl:text>
      </xsl:when>
      <!-- When is a graphic, create image -->
      <xsl:when test="current()/name() = 'w:drawing' and not($in-heading)">
        <xsl:apply-templates select="current()" mode="content" />
      </xsl:when>

      <xsl:when test="current()/name() = 'w:object' and not($in-heading)">
        <xsl:apply-templates select="current()" mode="content" />
      </xsl:when>
      <!-- When is a pict, create image -->
      <xsl:when test="current()/name() = 'w:pict' and not($in-heading)">
        <xsl:apply-templates select="current()" mode="content" />
      </xsl:when>
      <xsl:when test="current()/name() = 'w:footnoteReference' and config:convert-footnotes()">
        <sup>
          <xsl:choose>
          <xsl:when test="config:convert-footnotes-type() = 'generate-files'">
            <xref frag="default" display="manual" type="none" title="{concat('[',fn:get-formated-footnote-endnote-value(@w:id,'footnote'),']')}"
            reverselink="true" reversetitle="" reversetype="none" labels="footnote"
            href="footnotes/footnotes{@w:id}.psml">
            <xsl:value-of select="concat('[',fn:get-formated-footnote-endnote-value(@w:id,'footnote'),']')" />
          </xref>
          </xsl:when>
          <xsl:otherwise>
            <xref frag="{@w:id}" display="manual" type="none" title="{concat('[',fn:get-formated-footnote-endnote-value(@w:id,'footnote'),']')}"
            reverselink="true" reversetitle="" reversetype="none" labels="footnote"
            href="footnotes/footnotes.psml">
            <xsl:value-of select="concat('[',fn:get-formated-footnote-endnote-value(@w:id,'footnote'),']')" />
          </xref>
          </xsl:otherwise>
          </xsl:choose>
        </sup>
      </xsl:when>
      <xsl:when test="current()/name() = 'w:endnoteReference' and config:convert-endnotes()">
        <sup>
          <xsl:choose>
          <xsl:when test="config:convert-endnotes-type() = 'generate-files'">
            <xref frag="default" display="manual" type="none" title="{concat('[',fn:get-formated-footnote-endnote-value(@w:id,'endnote'),']')}"
            reverselink="true" reversetitle="" reversetype="none" labels="endnote"
            href="endnotes/endnotes{@w:id}.psml">
            <xsl:value-of select="concat('[',fn:get-formated-footnote-endnote-value(@w:id,'endnote'),']')" />
          </xref>
          </xsl:when>
          <xsl:otherwise>
            <xref frag="{@w:id}" display="manual" type="none" title="{concat('[',fn:get-formated-footnote-endnote-value(@w:id,'endnote'),']')}"
            reverselink="true" reversetitle="" reversetype="none" labels="endnote"
            href="endnotes/endnotes.psml">
            <xsl:value-of select="concat('[',fn:get-formated-footnote-endnote-value(@w:id,'endnote'),']')" />
          </xref>
          </xsl:otherwise>
          </xsl:choose>
        </sup>
      </xsl:when>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

<!--  template that calls itself recursively to create inline elements -->
<xsl:template name="apply-wr-style">
  <!-- This template processes inline elements recursively -->
  <xsl:param name="style" />
  <xsl:param name="text" />
  <xsl:param name="bold" />
  <xsl:param name="italic" />
  <xsl:param name="underline" />
  <xsl:param name="sub" />
  <xsl:param name="sup" />
  <xsl:param name="monospace" />
  <xsl:param name="inline-value" />
  <xsl:param name="is-numbered" />
  <xsl:param name="in-heading" />
  <xsl:param name="in-hyperlink" />
  <xsl:param name="in-link" />
  <xsl:choose>
    <xsl:when test="$inline-value!=''">
      <inline label="{$inline-value}">
        <xsl:call-template name="apply-wr-style">
          <xsl:with-param name="style" select="''" />
          <xsl:with-param name="text" select="$text" />
          <xsl:with-param name="bold" select="$bold" />
          <xsl:with-param name="italic" select="$italic" />
          <xsl:with-param name="underline" select="$underline" />
          <xsl:with-param name="sub" select="$sub" />
          <xsl:with-param name="sup" select="$sup" />
          <xsl:with-param name="monospace" select="$monospace" />
          <xsl:with-param name="inline-value" select="''" />
          <xsl:with-param name="in-heading" select="$in-heading" />
          <xsl:with-param name="is-numbered" select="$is-numbered" />
          <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
          <xsl:with-param name="in-link" select="$in-link" />
        </xsl:call-template>
      </inline>
    </xsl:when>
    <xsl:when test="($style!='' and $character-styles = 'inline' and $monospace = 'false')">
      <inline label="{$style}">
        <xsl:call-template name="apply-wr-style">
          <xsl:with-param name="style" select="''" />
          <xsl:with-param name="text" select="$text" />
          <xsl:with-param name="bold" select="$bold" />
          <xsl:with-param name="italic" select="$italic" />
          <xsl:with-param name="underline" select="$underline" />
          <xsl:with-param name="sub" select="$sub" />
          <xsl:with-param name="sup" select="$sup" />
          <xsl:with-param name="monospace" select="$monospace" />
          <xsl:with-param name="inline-value" select="$inline-value" />
          <xsl:with-param name="in-heading" select="$in-heading" />
          <xsl:with-param name="is-numbered" select="$is-numbered" />
          <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
          <xsl:with-param name="in-link" select="$in-link" />
        </xsl:call-template>
      </inline>
    </xsl:when>
    <xsl:when test="$bold='true'">
      <bold>
        <xsl:call-template name="apply-wr-style">
          <xsl:with-param name="style" select="$style" />
          <xsl:with-param name="text" select="$text" />
          <xsl:with-param name="bold" select="'false'" />
          <xsl:with-param name="italic" select="$italic" />
          <xsl:with-param name="underline" select="$underline" />
          <xsl:with-param name="sub" select="$sub" />
          <xsl:with-param name="sup" select="$sup" />
          <xsl:with-param name="monospace" select="$monospace" />
          <xsl:with-param name="inline-value" select="$inline-value" />
          <xsl:with-param name="in-heading" select="$in-heading" />
          <xsl:with-param name="is-numbered" select="$is-numbered" />
          <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
          <xsl:with-param name="in-link" select="$in-link" />
        </xsl:call-template>
      </bold>
    </xsl:when>
    <xsl:when test="$italic='true'">
      <italic>
        <xsl:call-template name="apply-wr-style">
          <xsl:with-param name="style" select="$style" />
          <xsl:with-param name="text" select="$text" />
          <xsl:with-param name="bold" select="$bold" />
          <xsl:with-param name="italic" select="'false'" />
          <xsl:with-param name="underline" select="$underline" />
          <xsl:with-param name="sub" select="$sub" />
          <xsl:with-param name="sup" select="$sup" />
          <xsl:with-param name="monospace" select="$monospace" />
          <xsl:with-param name="inline-value" select="$inline-value" />
          <xsl:with-param name="in-heading" select="$in-heading" />
          <xsl:with-param name="is-numbered" select="$is-numbered" />
          <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
          <xsl:with-param name="in-link" select="$in-link" />
        </xsl:call-template>
      </italic>
    </xsl:when>
    <xsl:when test="$underline='true'">
      <underline>
        <xsl:call-template name="apply-wr-style">
          <xsl:with-param name="style" select="$style" />
          <xsl:with-param name="text" select="$text" />
          <xsl:with-param name="bold" select="$bold" />
          <xsl:with-param name="italic" select="$italic" />
          <xsl:with-param name="underline" select="'false'" />
          <xsl:with-param name="sub" select="$sub" />
          <xsl:with-param name="sup" select="$sup" />
          <xsl:with-param name="monospace" select="$monospace" />
          <xsl:with-param name="inline-value" select="$inline-value" />
          <xsl:with-param name="in-heading" select="$in-heading" />
          <xsl:with-param name="is-numbered" select="$is-numbered" />
          <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
          <xsl:with-param name="in-link" select="$in-link" />
        </xsl:call-template>
      </underline>
    </xsl:when>
    <xsl:when test="$sub='true'">
      <sub>
        <xsl:call-template name="apply-wr-style">
          <xsl:with-param name="style" select="$style" />
          <xsl:with-param name="text" select="$text" />
          <xsl:with-param name="bold" select="$bold" />
          <xsl:with-param name="italic" select="$italic" />
          <xsl:with-param name="underline" select="$underline" />
          <xsl:with-param name="sub" select="'false'" />
          <xsl:with-param name="sup" select="$sup" />
          <xsl:with-param name="monospace" select="$monospace" />
          <xsl:with-param name="inline-value" select="$inline-value" />
          <xsl:with-param name="in-heading" select="$in-heading" />
          <xsl:with-param name="is-numbered" select="$is-numbered" />
          <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
          <xsl:with-param name="in-link" select="$in-link" />
        </xsl:call-template>
      </sub>
    </xsl:when>
    <xsl:when test="$sup='true'">
      <sup>
        <xsl:call-template name="apply-wr-style">
          <xsl:with-param name="style" select="$style" />
          <xsl:with-param name="text" select="$text" />
          <xsl:with-param name="bold" select="$bold" />
          <xsl:with-param name="italic" select="$italic" />
          <xsl:with-param name="underline" select="$underline" />
          <xsl:with-param name="sub" select="$sub" />
          <xsl:with-param name="sup" select="'false'" />
          <xsl:with-param name="monospace" select="$monospace" />
          <xsl:with-param name="inline-value" select="$inline-value" />
          <xsl:with-param name="in-heading" select="$in-heading" />
          <xsl:with-param name="is-numbered" select="$is-numbered" />
          <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
          <xsl:with-param name="in-link" select="$in-link" />
        </xsl:call-template>
      </sup>
    </xsl:when>
    <xsl:when test="$monospace='true'">
      <monospace>
        <xsl:call-template name="apply-wr-style">
          <xsl:with-param name="style" select="''" />
          <xsl:with-param name="text" select="$text" />
          <xsl:with-param name="bold" select="$bold" />
          <xsl:with-param name="italic" select="$italic" />
          <xsl:with-param name="underline" select="$underline" />
          <xsl:with-param name="sub" select="$sub" />
          <xsl:with-param name="sup" select="$sup" />
          <xsl:with-param name="monospace" select="'false'" />
          <xsl:with-param name="inline-value" select="$inline-value" />
          <xsl:with-param name="in-heading" select="$in-heading" />
          <xsl:with-param name="is-numbered" select="$is-numbered" />
          <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
          <xsl:with-param name="in-link" select="$in-link" />
        </xsl:call-template>
      </monospace>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="config:numbering-list-prefix-exists() and $is-numbered and matches($text/text(),config:numbering-match-list-prefix-string()) ">
          <xsl:analyze-string regex="({config:numbering-match-list-prefix-string()})(.*)" select="$text">
            <xsl:matching-substring>
              <xsl:call-template name="process-text-runs">
                <xsl:with-param name="text" select="regex-group(2)" />
                <xsl:with-param name="in-link" select="$in-link" />
                <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
                <xsl:with-param name="current" select="current()" />
              </xsl:call-template>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:call-template name="process-text-runs">
                <xsl:with-param name="text" select="$text" />
                <xsl:with-param name="in-link" select="$in-link" />
                <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
                <xsl:with-param name="current" select="current()" />
              </xsl:call-template>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="config:numbering-list-autonumbering-exists() and $is-numbered and matches($text/text(), config:numbering-match-list-autonumbering-string()) ">
          <xsl:analyze-string regex="({config:numbering-match-list-autonumbering-string()})(.*)" select="$text">
            <xsl:matching-substring>
              <xsl:call-template name="process-text-runs">
                <xsl:with-param name="text" select="regex-group(2)" />
                <xsl:with-param name="in-link" select="$in-link" />
                <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
                <xsl:with-param name="current" select="current()" />
              </xsl:call-template>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:call-template name="process-text-runs">
                <xsl:with-param name="text" select="$text" />
                <xsl:with-param name="in-link" select="$in-link" />
                <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
                <xsl:with-param name="current" select="current()" />
              </xsl:call-template>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:when test="$is-numbered and matches($text, config:numbering-match-list-inline-string()) ">
          <xsl:analyze-string regex="({config:numbering-match-list-inline-string()})(.*)" select="$text">
            <xsl:matching-substring>
              <xsl:variable name="context-string" select="$text" />
              <xsl:for-each select="$config-doc/config/lists/convert-manual-numbering/value[inline/@label]">
                <xsl:choose>
                  <xsl:when test="matches($context-string,concat('^',@match))">
                    <inline>
                      <xsl:attribute name="label" select="inline/@label" />
                      <xsl:value-of select="regex-group(1)" />
                    </inline>
                  </xsl:when>
                </xsl:choose>
              </xsl:for-each>
              <xsl:call-template name="process-text-runs">
                <xsl:with-param name="text" select="regex-group(2)" />
                <xsl:with-param name="in-link" select="$in-link" />
                <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
                <xsl:with-param name="current" select="current()" />
              </xsl:call-template>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:call-template name="process-text-runs">
                <xsl:with-param name="text" select="$text" />
                <xsl:with-param name="in-link" select="$in-link" />
                <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
                <xsl:with-param name="current" select="current()" />
              </xsl:call-template>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="process-text-runs">
            <xsl:with-param name="text" select="$text" />
            <xsl:with-param name="in-link" select="$in-link" />
            <xsl:with-param name="in-hyperlink" select="$in-hyperlink" />
            <xsl:with-param name="current" select="current()" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  template to handle text node creation:
  Check if a text is inside a link,
  *if not copy the text,
  *if it is, create the corresponding xref
 -->
<xsl:template name="process-text-runs">
  <xsl:param name="text" />
  <xsl:param name="in-link" />
  <xsl:param name="in-hyperlink" />
  <xsl:param name="current" />
  <xsl:choose>
    <xsl:when test="$in-hyperlink = 'true'">
      <xsl:variable name="bookmark-ref" select="$current/ancestor::w:hyperlink/@w:anchor" />
      <xsl:variable name="htext">
        <xsl:choose>
          <xsl:when test="$current/ancestor::w:hyperlink/@title">
            <xsl:value-of select="$current/ancestor::w:hyperlink/@title" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="string-join($current/ancestor::w:hyperlink//w:t//text(),'')" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:choose>
        <xsl:when test="$current/ancestor::w:hyperlink/@r:id">
          <xsl:variable name="rid" select="$current/ancestor::w:hyperlink/@r:id" />
          <link href="{$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target}">
            <xsl:value-of select="$current/ancestor::w:hyperlink/w:r/w:t" />
          </link>
        </xsl:when>
        <xsl:when test="$bookmark-ref != '' and config:references-as-links()">
          <link href="#{$bookmark-ref}">
            <xsl:value-of select="$htext" />
          </link>
        </xsl:when>
        <xsl:when test="$current/ancestor::w:hyperlink/@w:anchor and fn:get-document-position($current/ancestor::w:hyperlink/@w:anchor) != '0'">
          <xref display="manual" type="none" reverselink="true" reversetitle="" reversetype="none">
            <xsl:attribute name="title">
               <xsl:value-of select="string-join($current/ancestor::w:hyperlink//w:t//text(),'')" />
            </xsl:attribute>
            <xsl:attribute name="frag">
              <xsl:choose>
              <xsl:when test="config:split-by-sections()">
                 <xsl:value-of select="fn:get-fragment-position($bookmark-ref)" />
              </xsl:when>
              <xsl:otherwise>
                 <xsl:value-of select="'default'" />
              </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="href">
              <xsl:choose>
                <xsl:when test="config:split-by-documents()">
                   <xsl:variable name="document-number">
                    <xsl:value-of select="fn:get-document-position($bookmark-ref)" />
                  </xsl:variable>
                  <xsl:value-of select="encode-for-uri(concat($filename,'-',format-number($document-number, $zeropadding),'.psml'))" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="encode-for-uri(concat($filename,'.psml'))" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="$htext" />
          </xref>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$text" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$in-link = 'true'">
      <xsl:variable name="bookmark-ref">
        <xsl:choose>
          <xsl:when test="contains(current()/preceding-sibling::w:instrText[1],('REF'))">
            <xsl:value-of select="fn:get-bookmark-value(current()/preceding-sibling::w:instrText[1],'REF')" />
          </xsl:when>
          <xsl:when test="contains(current()/preceding-sibling::w:instrText[1],('PAGEREF'))">
            <xsl:value-of select="fn:get-bookmark-value(current()/preceding-sibling::w:instrText[1],'PAGEREF')" />
          </xsl:when>
          <xsl:when test="contains(current()/preceding-sibling::w:instrText[1],('HYPERLINK'))">
            <xsl:value-of select="fn:get-bookmark-value-hyperlink(current()/preceding-sibling::w:instrText[1],'HYPERLINK')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'NONE'" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$bookmark-ref = 'NONE'">
          <xsl:value-of select="$text" />
        </xsl:when>
        <xsl:when test="(contains(current()/preceding-sibling::w:instrText[1],('HYPERLINK'))
                         or config:references-as-links()) and $bookmark-ref != ''">
            <link href="#{$bookmark-ref}"><xsl:value-of select="$text" /></link>
          </xsl:when>
        <xsl:otherwise>
          <xref display="manual" type="none" reverselink="true" reversetitle="" reversetype="none">
            <xsl:attribute name="title">
               <xsl:value-of select="$text" />
          </xsl:attribute>
            <xsl:attribute name="frag">
           <xsl:choose>
             <xsl:when test="$bookmark-ref != '' and config:split-by-sections()">
                <xsl:value-of select="fn:get-fragment-position($bookmark-ref)" />
             </xsl:when>
             <xsl:otherwise>
             <xsl:value-of select="'default'" />
             </xsl:otherwise>
           </xsl:choose>
          </xsl:attribute>
            <xsl:attribute name="href">
           <xsl:choose>
            <xsl:when test="config:split-by-documents()">
              <xsl:variable name="document-number">
                <xsl:value-of select="fn:get-document-position($bookmark-ref)" />
              </xsl:variable>
              <xsl:value-of select="encode-for-uri(concat($filename,'-',format-number($document-number, $zeropadding),'.psml'))" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="encode-for-uri(concat($filename,'.psml'))" />
            </xsl:otherwise>
          </xsl:choose>
          </xsl:attribute>
            <xsl:value-of select="$text" />
          </xref>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>