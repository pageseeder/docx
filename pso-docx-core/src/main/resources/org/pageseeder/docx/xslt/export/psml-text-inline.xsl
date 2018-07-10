<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT modules handling inline and text styling PSML elements such as bold, italic, code as well as inline labels

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio

  @version 0.6.0
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:dfx="http://www.topologi.com/2005/Diff-X"
                xmlns:config="http://pageseeder.org/docx/config"
                xmlns:fn="http://pageseeder.org/docx/function"
                exclude-result-prefixes="#all">

<!-- Match text which is only a space -->
<xsl:template match="text()[. = '&#10;']" mode="psml"/>
<!-- TODO: Not a space a new line seems quite specific, what's the reason? -->

<!--
  Match any text in pageseeder;
  Creates a text run in word for each text found in pageseeder and handles conversion of parent inline elements to character styles
-->
<xsl:template match="text()" mode="psml">
  <xsl:param name="labels" tunnel="yes"/>
  <!-- no mixed content, create a run instead -->
  <xsl:variable name="text">
    <xsl:choose>
      <xsl:when test="count(preceding-sibling::node()) = 0 and (parent::para or parent::block)">
        <xsl:value-of select="fn:trim-leading-spaces(.)"/>
      </xsl:when>
      <xsl:when test="count(following-sibling::node()) = 0 and (parent::para or parent::block)">
        <xsl:value-of select="fn:trim-trailing-spaces(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="parent::displaytitle"/>
    <xsl:when test="parent::fragment">
      <w:p>
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$text" /></w:t>
        </w:r>
      </w:p>
    </xsl:when>
    <xsl:when test="matches(ancestor::inline[1]/@label, config:tab-inline-labels-document($labels))">
      <w:r>
        <w:tab/>
      </w:r>
    </xsl:when>
    <xsl:when test="matches(ancestor::inline[1]/@label, config:default-tab-inline-labels())">
      <w:r>
        <w:tab/>
      </w:r>
    </xsl:when>
    <xsl:when test="matches(ancestor::inline[1]/@label, config:inline-index-labels-with-document-label($labels))">
      <xsl:variable name="quote">"</xsl:variable>
      <w:r>
        <w:t><xsl:value-of select="$text"/></w:t>
        <w:fldChar w:fldCharType="begin"/>
        <w:instrText><xsl:value-of select="concat(' XE ', $quote,$text,$quote, ' ')"/></w:instrText>
        <w:fldChar w:fldCharType="separate"/>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </xsl:when>
    <xsl:when test="matches(ancestor::inline[1]/@label, config:default-inline-index-labels())">
      <xsl:variable name="quote">"</xsl:variable>
      <w:r>
        <w:t><xsl:value-of select="$text"/></w:t>
        <w:fldChar w:fldCharType="begin"/>
        <w:instrText><xsl:value-of select="concat(' XE ', $quote, $text, $quote, ' ')"/></w:instrText>
        <w:fldChar w:fldCharType="separate"/>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </xsl:when>
    <xsl:when test="matches(ancestor::inline[1]/@label, config:inline-fieldcode-labels-with-document-label($labels))
                and config:get-document-label-inline-fieldcode-value(ancestor::inline[1]/@label, $labels) != ''">
      <w:r>
        <w:fldChar w:fldCharType="begin"/>
        <w:instrText xml:space="preserve"><xsl:value-of select="config:get-document-label-inline-fieldcode-value(ancestor::inline[1]/@label, $labels)" /></w:instrText>
        <w:fldChar w:fldCharType="separate"/>
        <w:t xml:space="preserve"><xsl:value-of select="$text" /></w:t>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </xsl:when>
    <xsl:when test="matches(ancestor::inline[1]/@label, config:default-inline-fieldcode-labels()) and config:get-default-inline-fieldcode-value(ancestor::inline[1]/@label) !=''">
      <w:r>
        <w:fldChar w:fldCharType="begin"/>
        <w:instrText xml:space="preserve"><xsl:value-of select="config:get-default-inline-fieldcode-value(ancestor::inline[1]/@label)" /></w:instrText>
        <w:fldChar w:fldCharType="separate"/>
        <w:t xml:space="preserve"><xsl:value-of select="$text" /></w:t>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </xsl:when>

    <xsl:otherwise>
      <w:r>
        <w:rPr>
        <xsl:call-template name="apply-run-style" />
        </w:rPr>
        <xsl:choose>
          <xsl:when test="ancestor::dfx:del">
          <w:delText xml:space="preserve"><xsl:value-of select="$text" /></w:delText>
          </xsl:when>
          <xsl:otherwise>
            <w:t xml:space="preserve"><xsl:value-of select="$text" /></w:t>
          </xsl:otherwise>
        </xsl:choose>
      </w:r>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Matches inline labels, and creates a paragraph if they are not inside of a block element;
  processing is done inside of text
-->
<xsl:template match="inline" mode="psml">
  <xsl:param name="labels" tunnel="yes"/>
  <xsl:choose>
    <xsl:when test="matches(@label, config:inline-ignore-labels-with-document-label($labels))"/>
    <xsl:when test="matches(@label, config:default-inline-ignore-labels())"/>
    <xsl:when test="@label=config:citations-pageslabel()"/>
    <xsl:otherwise>
      <xsl:apply-templates mode="psml" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Other inline elements: just keep processing
-->
<xsl:template match="bold|italic|monospace|sub|sup|underline" mode="psml">
  <xsl:apply-templates mode="psml"/>
</xsl:template>

<!-- Match inserted content: only used when diffx is applied -->
<xsl:template match="dfx:ins" mode="psml">
<w:ins w:author="Pageseeder" w:date="{fn:get-current-date()}">
  <xsl:attribute name="w:id" select="count(preceding::dfx:ins) + count(preceding::dfx:del) + count(preceding::fragment) + count(ancestor::fragment) +count(preceding::xref) + count(preceding::document) + count(ancestor::document) + count(preceding::link[@name])"/>
  <xsl:apply-templates mode="psml"/>
</w:ins>
</xsl:template>

<!-- Match deleted content: only used when diffx is applied -->
<xsl:template match="dfx:del" mode="psml">
  <w:del w:author="Pageseeder" w:date="{fn:get-current-date()}">
    <xsl:attribute name="w:id" select="count(preceding::dfx:ins) + count(preceding::dfx:del) + count(preceding::fragment) + count(ancestor::fragment) +count(preceding::xref) + count(preceding::document) + count(ancestor::document) + count(preceding::link[@name])"/>
    <xsl:apply-templates mode="psml"/>
  </w:del>
</xsl:template>

<!--
  Matches line breaks; create paragraph if fragment is parent
-->
<xsl:template match="br" mode="psml">
  <xsl:choose>
    <xsl:when test="parent::fragment">
      <w:p>
        <w:r>
          <w:br />
        </w:r>
      </w:p>
    </xsl:when>
    <xsl:when test="fn:has-block-elements(parent::*)">
      <xsl:message>DOCX EXPORT ERROR: <br/> must be wrapped by a block level element (URI ID: <xsl:value-of
        select="/document/documentinfo/uri/@id" />)</xsl:message>
    </xsl:when>
    <xsl:otherwise>
      <w:r>
        <w:br />
      </w:r>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
