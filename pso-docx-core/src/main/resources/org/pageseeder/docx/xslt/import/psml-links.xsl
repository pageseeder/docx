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

<!-- TODO Remove big chunks of commented code -->

<!--
  template to handle w:hyperlink;
  1. It it has a r:id attribute, then it is an external link
  2. if it has a w:anchor attribute, it is an internal link
  3. otherwise, keep the text
-->
<xsl:template match="w:hyperlink" mode="content">
  <!--##link##-->
<!--     <xsl:choose> -->
<!--       <xsl:when test="@r:id"> -->
<!--         <xsl:variable name="rid" select="@r:id" /> -->
<!--         <link href="{$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target}"> -->
<!--           <xsl:value-of select="w:r/w:t" /> -->
<!--         </link> -->
<!--       </xsl:when> -->
<!--       <xsl:when test="@w:anchor"> -->
<!--         <xsl:variable name="bookmark-ref" select="@w:anchor" /> -->


<!--         <xref display="manual" type="none" reverselink="true" reversetitle="" reversetype="none"> -->
<!--           <xsl:attribute name="title"> -->
<!--                  <xsl:value-of select="string-join(.//w:t//text(),'')" /> -->
<!--             </xsl:attribute> -->
<!--           <xsl:attribute name="frag"> -->
<!--           <xsl:choose> -->
<!--           <xsl:when test="config:split-by-sections()"> -->
<!--              <xsl:value-of select="fn:get-fragment-position($bookmark-ref)" /> -->
<!--           </xsl:when> -->
<!--           <xsl:otherwise> -->
<!--              <xsl:value-of select="'Default'" /> -->
<!--           </xsl:otherwise> -->
<!--           </xsl:choose> -->

<!--         </xsl:attribute> -->
<!--           <xsl:attribute name="href"> -->
<!--             <xsl:choose> -->
<!--               <xsl:when test="config:split-by-documents()"> -->
<!--                  <xsl:variable name="document-number"> -->
<!--                   <xsl:value-of select="fn:get-document-position($bookmark-ref)" /> -->
<!--                 </xsl:variable> -->
<!--                 <xsl:value-of select="encode-for-uri(concat($filename,'-',format-number($document-number, $zeropadding),'.psml'))" /> -->
<!--               </xsl:when> -->
<!--               <xsl:otherwise> -->
<!--                 <xsl:value-of select="encode-for-uri(concat($filename,'.psml'))" /> -->
<!--               </xsl:otherwise> -->
<!--             </xsl:choose> -->
<!--           </xsl:attribute> -->
<!--           <xsl:choose> -->
<!--             <xsl:when test="@title"> -->
<!--               <xsl:value-of select="@title" /> -->
<!--             </xsl:when> -->
<!--             <xsl:otherwise> -->
<!--               <xsl:value-of select="string-join(.//w:t//text(),'')" /> -->
<!--             </xsl:otherwise> -->
<!--           </xsl:choose> -->
<!--         </xref> -->
<!--       </xsl:when> -->
<!--       <xsl:otherwise> -->
  <xsl:apply-templates select="w:r" mode="content" />
<!--       </xsl:otherwise> -->
<!--     </xsl:choose> -->
</xsl:template>


<!--
  template to handle fields;
  Currently handles REF , PAGEREF and HYPERLINK options, and transforms them into xrefs
-->
<xsl:template match="w:r[w:t != ''][w:fldChar[@w:fldCharType='separate']][w:instrText[matches(text(),'PAGEREF|REF|HYPERLINK|SEQ Table')]]">
  <xsl:param name="in-heading" select="false()" />

  <xsl:variable name="field-type">
    <xsl:choose>
      <xsl:when test="contains(w:instrText,('PAGEREF'))">link</xsl:when>
      <xsl:when test="contains(w:instrText,('REF'))">link</xsl:when>
      <xsl:when test="contains(w:instrText,('HYPERLINK'))">link</xsl:when>
      <xsl:when test="contains(w:instrText,('XE'))">index</xsl:when>
      <xsl:when test="contains(w:instrText,('SEQ Table'))">table</xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$field-type= 'link'">
      <xsl:call-template name="create-link">
        <xsl:with-param name="current" select="current()" />
      </xsl:call-template>
    </xsl:when>

    <xsl:when test="$field-type= 'index' and config:generate-index-files()">
      <xsl:variable name="index-location" select="translate(fn:get-index-text(w:instrText,'XE'),':','/')" />
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
  <xsl:variable name="temp-index-location" select="translate(translate(fn:get-index-text(w:instrText/text(),'XE'),'/','_'),':','/')" />
  <xsl:variable name="index-location">
    <xsl:for-each select="tokenize($temp-index-location, '/')">
      <xsl:choose>
        <xsl:when test="position() != last()">
          <xsl:value-of select="concat(encode-for-uri(.), '/')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="encode-for-uri(.)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>

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
  <xref display="manual" type="none" reverselink="true" reversetitle="" reversetype="none"
        title="{string-join($current//w:t//text(),'')}"
        frag="{if (config:split-by-sections()) then fn:get-fragment-position($bookmark-ref) else 'default'}">
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
    <xsl:value-of select="if (@title) then @title else string-join($current//w:t//text(), '')"/>
  </xref>
</xsl:template>

<!--
  Generate a PSML `xref` from a `w:fldSimple` if it contains a REF and PAGEREF options;
  continues content processing otherwise.
-->
<xsl:template match="w:fldSimple" mode="content">
  <xsl:variable name="bookmark-ref">
    <xsl:choose>
      <xsl:when test="contains(@w:instr, ('REF'))">
        <xsl:value-of select="fn:get-bookmark-value(@w:instr, 'REF')" />
      </xsl:when>
      <xsl:when test="contains(@w:instr, ('PAGEREF'))">
        <xsl:value-of select="fn:get-bookmark-value(@w:instr, 'PAGEREF')" />
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$bookmark-ref != ''">
      <xref display="manual" type="none" reverselink="true" reversetitle="" reversetype="none"
            title="{string-join(.//w:t//text(),'')}">
        <xsl:attribute name="frag">
          <xsl:choose>
            <xsl:when test="config:split-by-sections() and $bookmark-ref != ''">
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
        <xsl:value-of select="if (@title) then @title else string-join(.//w:t//text(), '')" />
      </xref>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="content" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>