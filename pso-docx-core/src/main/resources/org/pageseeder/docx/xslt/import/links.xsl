<?xml version="1.0" encoding="utf-8"?>

  <!--
    This stylesheet transform openXML into PS Format
  
    @author Hugo Inacio 
    @copyright Allette Systems Pty Ltd 
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships" xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/" xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.pageseeder.com/function"
  xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
  exclude-result-prefixes="#all">

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
<!--           <xsl:when test="$split-by-sections"> -->
<!--              <xsl:value-of select="fn:get-fragment-position($bookmark-ref)" /> -->
<!--           </xsl:when> -->
<!--           <xsl:otherwise> -->
<!--              <xsl:value-of select="'Default'" /> -->
<!--           </xsl:otherwise> -->
<!--           </xsl:choose> -->
            
<!--         </xsl:attribute> -->
<!--           <xsl:attribute name="href"> -->
<!--             <xsl:choose> -->
<!--               <xsl:when test="$split-by-documents"> -->
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
    <xsl:variable name="character-style-name">
      <xsl:value-of select="w:rPr/w:rStyle/@w:val" />
    </xsl:variable>
<!--     <xsl:message> -->
<!--       <xsl:value-of select=".//w:instrText" /> -->
<!--     </xsl:message> -->
    <xsl:variable name="inline-value">
      <xsl:value-of select="fn:get-inline-label-from-psml-element($character-style-name)" />
    </xsl:variable>

    <xsl:variable name="field-type">
      <xsl:choose>
        <xsl:when test="contains(w:instrText,('PAGEREF'))">
          <xsl:value-of select="'link'" />
        </xsl:when>
        <xsl:when test="contains(w:instrText,('REF'))">
          <xsl:value-of select="'link'" />
        </xsl:when>
        <xsl:when test="contains(w:instrText,('HYPERLINK'))">
          <xsl:value-of select="'link'" />
        </xsl:when>
        <xsl:when test="contains(w:instrText,('XE'))">
          <xsl:value-of select="'index'" />
        </xsl:when>
        <xsl:when test="contains(w:instrText,('SEQ Table'))">
          <xsl:value-of select="'table'" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$field-type= 'link'">
        <xsl:call-template name="create-link">
          <xsl:with-param name="current" select="current()" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$field-type= 'index' and $generate-index-files">

        <xsl:variable name="index-location" select="translate(fn:get-index-text(w:instrText,'XE'),':','/')" />
<!--         <inline label="index-term"> -->
        <xref display="manual" frag="default" type="none" reverselink="true" reversetitle="" reversetype="none">
          <xsl:attribute name="title">
	             <xsl:value-of select="fn:get-index-text(w:instrText,'XE')" />
	        </xsl:attribute>
          <xsl:attribute name="href">
	             <xsl:value-of select="encode-for-uri($index-location)" />
	        </xsl:attribute>
          <xsl:value-of select="concat('index/',fn:get-index-text(w:instrText,'XE'))" />
        </xref>
<!--         </inline> -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="content" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Text for index entries -->
  <xsl:template match="w:r[w:instrText[matches(text(),'XE')]][$generate-index-files]" mode="content">
    <xsl:variable name="temp-index-location" select="translate(translate(fn:get-index-text(w:instrText/text(),'XE'),'/','_'),':','/')" />
    <xsl:variable name="index-location">
<!--       <xsl:message select="w:instrText/text()"></xsl:message> -->
      <xsl:for-each select="tokenize($temp-index-location,'/')">
        <xsl:choose>
          <xsl:when test="position() != last()">
<!--               <xsl:message select="concat(encode-for-uri(.),'/')"></xsl:message> -->
            <xsl:value-of select="concat(encode-for-uri(.),'/')" />
          </xsl:when>
          <xsl:otherwise>
<!--               <xsl:message select="encode-for-uri(.)"></xsl:message> -->
            <xsl:value-of select="encode-for-uri(.)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    
<!--         <inline label="index-term"> -->
    <xref display="manual" frag="default" type="none" reverselink="true" reversetitle="" reversetype="none">
      <xsl:attribute name="title">
               <xsl:value-of select="fn:get-index-text(w:instrText/text(),'XE')" />
          </xsl:attribute>
      <xsl:attribute name="href">
               <xsl:value-of select="concat('index/',$index-location,'.psml')" />
          </xsl:attribute>
      <xsl:value-of select="fn:get-index-text(w:instrText/text(),'XE')" />
    </xref>
<!--         </inline> -->
  </xsl:template>

  <!-- template to generate a link from the current fieldcode element -->
  <xsl:template name="create-link">
    <xsl:param name="current" />

    <xsl:variable name="bookmark-ref">
      <xsl:choose>
        <xsl:when test="contains($current/w:instrText,('REF'))">
          <xsl:value-of select="fn:get-bookmark-value($current/w:instrText,'REF')" />
        </xsl:when>
        <xsl:when test="contains($current/w:instrText,('PAGEREF'))">
          <xsl:value-of select="fn:get-bookmark-value($current/w:instrText,'PAGEREF')" />
        </xsl:when>
        <xsl:when test="contains($current/w:instrText,('HYPERLINK'))">
          <xsl:value-of select="fn:get-bookmark-value-hyperlink($current/w:instrText,'HYPERLINK')" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xref display="manual" type="none" reverselink="true" reversetitle="" reversetype="none">
      <xsl:attribute name="title">
             <xsl:value-of select="string-join($current//w:t//text(),'')" />
        </xsl:attribute>
      <xsl:attribute name="frag">
          <xsl:choose>
          <xsl:when test="$split-by-sections">
             <xsl:value-of select="fn:get-fragment-position($bookmark-ref)" />
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="'default'" />
          </xsl:otherwise>
          </xsl:choose>
            
        </xsl:attribute>
      <xsl:attribute name="href">
       <xsl:choose>
          <xsl:when test="$split-by-documents">
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
      <xsl:choose>
        <xsl:when test="@title">
          <xsl:value-of select="@title" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="string-join($current//w:t//text(),'')" />
        </xsl:otherwise>
      </xsl:choose>
    </xref>

  </xsl:template>
<!--
  template to handle w:fldSimple;
  Currently handles REF and PAGEREF options, and transforms them into xrefs
-->
  <xsl:template match="w:fldSimple" mode="content">
    <xsl:variable name="bookmark-ref">
      <xsl:choose>
        <xsl:when test="contains(@w:instr,('REF'))">
          <xsl:value-of select="fn:get-bookmark-value(@w:instr,'REF')" />
        </xsl:when>
        <xsl:when test="contains(@w:instr,('PAGEREF'))">
          <xsl:value-of select="fn:get-bookmark-value(@w:instr,'PAGEREF')" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$bookmark-ref != ''">
        <xref display="manual" type="none" reverselink="true" reversetitle="" reversetype="none">
          <xsl:attribute name="title">
		           <xsl:value-of select="string-join(.//w:t//text(),'')" />
		        </xsl:attribute>
          <xsl:attribute name="frag">
		         <xsl:choose>
		           <xsl:when test="$split-by-sections and $bookmark-ref != ''">
		             <xsl:value-of select="fn:get-fragment-position($bookmark-ref)" />
		          </xsl:when>
		            <xsl:otherwise>
		             <xsl:value-of select="'default'" />
		            </xsl:otherwise>
		         </xsl:choose>
		        </xsl:attribute>
          <xsl:attribute name="href">
					   <xsl:choose>
		          <xsl:when test="$split-by-documents">
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
          <xsl:choose>
            <xsl:when test="@title">
              <xsl:value-of select="@title" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="string-join(.//w:t//text(),'')" />
            </xsl:otherwise>
          </xsl:choose>
        </xref>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="content" />
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>