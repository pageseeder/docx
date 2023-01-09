<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to handle the images from `w:drawing`, `w:pict`, and `w:object`.

  All templates in this module assume that images are inside the `media` folder .

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!--
  template to handle w:hyperlink;
-->
<xsl:template match="w:hyperlink" mode="content">
  <xsl:apply-templates select="w:r" mode="content" />
</xsl:template>

<!--
  THIS CODE DOES NOT SEEM TO BE USED

  template to handle fields;
  Currently handles REF , PAGEREF and HYPERLINK options, and transforms them into xrefs
-->
<xsl:template match="w:r[w:t != ''][w:fldChar[@w:fldCharType='separate']][w:instrText[matches(text(),
    'PAGEREF|REF|HYPERLINK|SEQ Table')][not(matches(text(),'STYLEREF'))]]">
  <xsl:param name="in-heading" select="false()" />

  <xsl:variable name="field-type">
    <xsl:choose>
      <xsl:when test="contains(w:instrText, 'PAGEREF')">link</xsl:when>
      <xsl:when test="contains(w:instrText, 'REF')">link</xsl:when>
      <xsl:when test="contains(w:instrText, 'HYPERLINK')">link</xsl:when>
      <xsl:when test="contains(w:instrText, 'XE')">index</xsl:when>
      <xsl:when test="contains(w:instrText, 'SEQ Table')">table</xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$field-type= 'link'">
      <xsl:call-template name="create-link">
        <xsl:with-param name="current" select="current()" />
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="$field-type= 'index' and config:generate-index-files()">
      <xsl:variable name="index-location" select="translate(fn:get-index-text(w:instrText,'XE'), ':', '/')" />
      <xref display="manual" frag="default" type="none" reverselink="true" reversetitle="" reversetype="none"
            title="{fn:get-index-text(w:instrText, 'XE')}"
            href="{encode-for-uri($index-location)}">
        <xsl:value-of select="concat('index/', fn:get-index-text(w:instrText, 'XE'))" />
      </xref>
    </xsl:when>

    <xsl:otherwise>
      <xsl:apply-templates mode="content" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Text for index entries -->
<xsl:template match="w:r[w:instrText[matches(text(),'XE')]][config:generate-index-files()]" mode="content">
  <xsl:variable name="temp-index-location" select="translate(translate(fn:get-index-text(w:instrText/text(), 'XE'), '/', '_'), ':', '/')" />
  <xsl:variable name="index-location" select="string-join(for $i in tokenize($temp-index-location, '/') return encode-for-uri($i), '/')"/>

  <xref display="manual" frag="default" type="none" reverselink="true" reversetitle="" reversetype="none"
        title="{fn:get-index-text(w:instrText/text(), 'XE')}"
        href="{concat('index/', $index-location, '.psml')}">
    <xsl:value-of select="fn:get-index-text(w:instrText/text(), 'XE')" />
  </xref>
</xsl:template>

<!-- template to generate a link from the current fieldcode element -->
<xsl:template name="create-link">
  <xsl:param name="current" />

  <xsl:variable name="bookmark-ref">
    <xsl:choose>
      <xsl:when test="contains($current/w:instrText,('REF'))">
        <xsl:value-of select="fn:get-bookmark-value($current/w:instrText, 'REF')" />
      </xsl:when>
      <xsl:when test="contains($current/w:instrText,('PAGEREF'))">
        <xsl:value-of select="fn:get-bookmark-value($current/w:instrText, 'PAGEREF')" />
      </xsl:when>
      <xsl:when test="contains($current/w:instrText,('HYPERLINK'))">
        <xsl:value-of select="fn:get-bookmark-value-hyperlink($current/w:instrText, 'HYPERLINK')" />
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="text" select="if (@title) then @title else string-join($current//w:t//text(), '')"/>

  <xsl:choose>
    <xsl:when test="$bookmark-ref != '' and config:references-as-links()">
      <link href="#b{$bookmark-ref}">
        <xsl:value-of select="$text" />
      </link>
    </xsl:when>
    <xsl:otherwise>
      <xref display="manual" type="none" reverselink="true" reversetitle="" reversetype="none"
            title="{string-join($current//w:t//text(), '')}"
            frag="default" href="{encode-for-uri(concat($filename,'.psml'))}">
        <xsl:value-of select="$text"/>
      </xref>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Generate a PSML `xref` from a `w:fldSimple` if it contains a REF and PAGEREF options;
  continues content processing otherwise.
-->
<xsl:template match="w:fldSimple" mode="content">
  <xsl:variable name="bookmark-ref">
    <xsl:choose>
      <xsl:when test="contains(@w:instr, ('STYLEREF'))" />
      <xsl:when test="contains(@w:instr, ('REF'))">
        <xsl:value-of select="fn:get-bookmark-value(@w:instr, 'REF')" />
      </xsl:when>
      <xsl:when test="contains(@w:instr, ('PAGEREF'))">
        <xsl:value-of select="fn:get-bookmark-value(@w:instr, 'PAGEREF')" />
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="text" select="if (@title) then @title else string-join(.//w:t//text(), '')"/>

  <xsl:choose>
    <xsl:when test="$bookmark-ref != '' and config:references-as-links()">
      <link href="#b{$bookmark-ref}">
        <xsl:value-of select="$text"/>
      </link>
    </xsl:when>
    <xsl:when test="$bookmark-ref != ''">
      <xref display="manual" type="none" reverselink="true" reversetitle="" reversetype="none"
            title="{string-join(.//w:t//text(), '')}"
            frag="default" href="{encode-for-uri(concat($filename,'.psml'))}">
        <xsl:value-of select="$text"/>
      </xref>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="content" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>