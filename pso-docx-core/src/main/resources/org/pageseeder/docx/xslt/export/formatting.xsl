<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:dfx="http://www.topologi.com/2005/Diff-X"
                xmlns:fn="http://www.pageseeder.com/function"
                exclude-result-prefixes="#all">

<!--
  Match anchor element;
  Currently ignores this 
 -->
<xsl:template match="anchor" mode="content"/>

<!-- Match text which is only a space -->
<xsl:template match="text()[. = '&#10;']" mode="content"/>
<!-- TODO: Not a space a new line seems quite specific, what's the reason? -->

<!--
  Match any text in pageseeder;
  Creates a text run in word for each text found in pageseeder and handles conversion of parent inline elements to character styles
-->
<xsl:template match="text()" mode="content">
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
    <xsl:when test="matches(ancestor::inline[1]/@label,fn:tab-inline-labels-document($labels))">
      <w:r>
        <w:tab/>
      </w:r>
    </xsl:when>
    <xsl:when test="matches(ancestor::inline[1]/@label,fn:default-tab-inline-labels())">
      <w:r>
        <w:tab/>
      </w:r>
    </xsl:when>
    <xsl:when test="matches(ancestor::inline[1]/@label,fn:inline-index-labels-with-document-label($labels))">
      <xsl:variable name="quote">"</xsl:variable>
      <w:r>
        <w:t><xsl:value-of select="$text"/></w:t>
        <w:fldChar w:fldCharType="begin"/>
        <w:instrText><xsl:value-of select="concat(' XE ',$quote,$text,$quote,' ')"/></w:instrText>
        <w:fldChar w:fldCharType="separate"/>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </xsl:when>
    <xsl:when test="matches(ancestor::inline[1]/@label,fn:default-inline-index-labels())">
      <xsl:variable name="quote">"</xsl:variable>
      <w:r>
        <w:t><xsl:value-of select="$text"/></w:t>
        <w:fldChar w:fldCharType="begin"/>
        <w:instrText><xsl:value-of select="concat(' XE ',$quote,$text,$quote,' ')"/></w:instrText>
        <w:fldChar w:fldCharType="separate"/>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </xsl:when>
    <xsl:when test="matches(ancestor::inline[1]/@label,fn:inline-fieldcode-labels-with-document-label($labels)) and fn:get-document-label-inline-fieldcode-value(ancestor::inline[1]/@label,$labels) != ''">
      <w:r>
        <w:fldChar w:fldCharType="begin"/>
        <w:instrText xml:space="preserve"><xsl:value-of select="fn:get-document-label-inline-fieldcode-value(ancestor::inline[1]/@label,$labels)" /></w:instrText>
        <w:fldChar w:fldCharType="separate"/>
        <w:t xml:space="preserve"><xsl:value-of select="$text" /></w:t>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </xsl:when>
    <xsl:when test="matches(ancestor::inline[1]/@label,fn:default-inline-fieldcode-labels()) and fn:get-default-inline-fieldcode-value(ancestor::inline[1]/@label) !=''">
      <w:r>
        <w:fldChar w:fldCharType="begin"/>
        <w:instrText xml:space="preserve"><xsl:value-of select="fn:get-default-inline-fieldcode-value(ancestor::inline[1]/@label)" /></w:instrText>
        <w:fldChar w:fldCharType="separate"/>
        <w:t xml:space="preserve"><xsl:value-of select="$text" /></w:t>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </xsl:when>

    <xsl:otherwise>
      <w:r>
        <xsl:call-template name="apply-run-style" />
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
  Match code element
-->
<xsl:template match="code" mode="content">
  <w:p>
    <w:pPr>
      <xsl:call-template name="apply-style" />
    </w:pPr>
    <w:r>
      <xsl:variable name="return-char" select="codepoints-to-string(10)" />
      <xsl:for-each select="tokenize(., $return-char)">
        <xsl:if test="current() != ''">
          <w:t xml:space="preserve"><xsl:value-of select="current()" /></w:t>
          <w:cr />
        </xsl:if>
      </xsl:for-each>
    </w:r>
  </w:p>
</xsl:template>

<!--
  Matches inline labels, and creates a paragraph if they are not inside of a block element;
  processing is done inside of text
-->
<xsl:template match="inline" mode="content">
  <xsl:param name="labels" tunnel="yes"/>
  <xsl:variable name="id" select="concat(@label, '-', generate-id())" />
  <xsl:choose>
    <xsl:when test="parent::block and fn:has-block-elements(parent::block)='true'">
      <w:p>
        <xsl:apply-templates mode="content" />
      </w:p>
    </xsl:when>
    <xsl:when test="matches(@label,fn:inline-ignore-labels-with-document-label($labels))"/>
    <xsl:when test="matches(@label,fn:default-inline-ignore-labels())"/>
    <xsl:otherwise>
      <xsl:apply-templates mode="content" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- TODO Template below can be consolidated -->

<!--
  Matches bold elements; processing is done inside of text
-->
<xsl:template match="bold" mode="content">
  <xsl:apply-templates mode="content" />
</xsl:template>

<!-- Matches underline elements; processing is done inside of text -->
<xsl:template match="underline" mode="content">
  <xsl:apply-templates  mode="content"/>
</xsl:template>

<!-- Matches sub elements; processing is done inside of text -->
<xsl:template match="sub" mode="content">
  <xsl:apply-templates  mode="content"/>
</xsl:template>

<!-- Matches sup elements; processing is done inside of text -->
<xsl:template match="sup" mode="content">
  <xsl:apply-templates  mode="content"/>
</xsl:template>

<!-- Matches italic elements; processing is done inside of text -->
<xsl:template match="italic" mode="content">
  <xsl:apply-templates  mode="content"/>
</xsl:template>


<!-- Matches monospace elements; processing is done inside of text -->
<xsl:template match="monospace" mode="content">
  <xsl:apply-templates  mode="content"/>
</xsl:template>

  <!-- Match inserted content: only used when diffx is applied -->
<xsl:template match="dfx:ins" mode="content">
<w:ins w:author="Pageseeder" w:date="fn:get-current-date()">
  <xsl:attribute name="w:id" select="count(preceding::dfx:ins) + count(preceding::dfx:del) + count(preceding::fragment) + count(ancestor::fragment) +count(preceding::xref) + count(preceding::document) + count(ancestor::document) + count(preceding::link[@name])"/>
  <xsl:apply-templates  mode="content"/>
  </w:ins>
</xsl:template>

<!-- Match deleted content: only used when diffx is applied -->
<xsl:template match="dfx:del" mode="content">
  <w:del w:author="Pageseeder" w:date="fn:get-current-date()">
  <xsl:attribute name="w:id" select="count(preceding::dfx:ins) + count(preceding::dfx:del) + count(preceding::fragment) + count(ancestor::fragment) +count(preceding::xref) + count(preceding::document) + count(ancestor::document) + count(preceding::link[@name])"/>
  <xsl:apply-templates  mode="content"/>
  </w:del>
</xsl:template>


<!--
  Matches line breaks;
  create paragraph if not inside a block element
-->
<xsl:template match="br" mode="content">
  <xsl:choose>
    <xsl:when test="preceding-sibling::*[fn:is-block-element(.)='true'] or following-sibling::*[fn:is-block-element(.)='true']">
      <w:p>
        <w:pPr>
          <xsl:call-template name="apply-style" />
        </w:pPr>
        <w:r>
          <w:br />
        </w:r>
      </w:p>
    </xsl:when>
    <xsl:when test="parent::fragment">
      <w:p>
        <w:r>
          <w:br />
        </w:r>
      </w:p>
    </xsl:when>
    <xsl:otherwise>
      <w:r>
        <w:br />
      </w:r>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Caption is handled inside table -->
<xsl:template match="caption" mode="content">
  <xsl:apply-templates  mode="content"/>
</xsl:template>

</xsl:stylesheet>
