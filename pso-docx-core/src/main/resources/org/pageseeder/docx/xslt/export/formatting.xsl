<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
  xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:w10="urn:schemas-microsoft-com:office:word"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
  xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
   
                xmlns:dfx="http://www.topologi.com/2005/Diff-X"
                xmlns:del="http://www.topologi.com/2005/Diff-X/Delete"
                xmlns:ins="http://www.topologi.com/2005/Diff-X/Insert"
                xmlns:diffx="java:com.topologi.diffx.Extension"
  xmlns:fn="http://www.pageseeder.com/function" xmlns:dec="java:java.net.URLDecoder" exclude-result-prefixes="#all">
  
  <!--  
  Match anchor element;
  Currently ignores this 
   -->
  <xsl:template match="anchor" mode="content"/>
  
  <!-- Match text which is only a space -->
   <xsl:template match="text()[. = '&#10;']" mode="content">
<!--     <xsl:message>EMPYSTRING!!!!</xsl:message> -->
   </xsl:template>
   
    <!--  
  Match any text in pageseeder;
  Creates a text run in word for each text found in pageseeder and handles conversion of parent inline elements to character styles
   -->
  <xsl:template match="text()" mode="content">
    <xsl:param name="labels" tunnel="yes"/>
      <!-- no mixed content, create a run instead -->
<!--       <xsl:message>#<xsl:value-of select="."/>#</xsl:message> -->
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
<!--     <xsl:message>*<xsl:value-of select="$text"/>*</xsl:message> -->
    <xsl:choose>
      <xsl:when test="parent::displaytitle">
      </xsl:when>
      <xsl:when test="parent::fragment">
        <w:p>
          <w:r>
            <w:t xml:space="preserve"><xsl:value-of select="$text" /></w:t>
          </w:r>
        </w:p>
      </xsl:when>
       <xsl:when test="matches(ancestor::inline[1]/@label,fn:tab-inline-labels-document($labels))">
           <w:r>
<!--             <xsl:if -->
<!--               test="ancestor::inline[position() != 1][@label]"> -->
<!--               <xsl:call-template name="apply-style" /> -->
<!--             </xsl:if> -->
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
  
  <!--##code##-->
  <!--  
  Match code element;
   -->
  <xsl:template match="code" mode="content">
    <w:p>
      <w:pPr>
        <xsl:call-template name="apply-style" />
      </w:pPr>
      <w:r>
        <xsl:variable name="return-char" select="codepoints-to-string(10)" />
        <xsl:for-each select="tokenize(.,$return-char)">
          <xsl:if test="current() !='' ">
            <w:t xml:space="preserve"><xsl:value-of select="current()" /></w:t>
            <w:cr />
          </xsl:if>
        </xsl:for-each>
      </w:r>
    </w:p>
  </xsl:template>

  <!-- inlineLabels -->
  <!--##inline##-->
  <!-- Matches inline labels, and creates a paragraph if they are not inside of a block element; processing is done inside of text -->
  <xsl:template match="inline" mode="content">
    <xsl:param name="labels" tunnel="yes"/>
    <xsl:variable name="id" select="concat(@label, '-', generate-id())" />
<!--     <xsl:message select="@label"></xsl:message> -->
    <xsl:choose>
      <xsl:when test="parent::block and fn:has-block-elements(parent::block)='true'">
        <w:p>
          <xsl:apply-templates mode="content" />
        </w:p>
      </xsl:when>
      <xsl:when test="matches(@label,fn:inline-ignore-labels-with-document-label($labels))">
       
      </xsl:when>
      <xsl:when test="matches(@label,fn:default-inline-ignore-labels())">
       
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="content" /> 
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--##bold##-->
  <!-- Matches bold elements; processing is done inside of text -->
  <xsl:template match="bold" mode="content">
    <xsl:apply-templates mode="content" />
  </xsl:template>
  
  <!--##underline##-->
  <!-- Matches underline elements; processing is done inside of text -->
  <xsl:template match="underline" mode="content">
    <xsl:apply-templates  mode="content"/>
  </xsl:template>
  
  <!--##sub##-->
  <!-- Matches sub elements; processing is done inside of text -->
  <xsl:template match="sub" mode="content">
    <xsl:apply-templates  mode="content"/>
  </xsl:template>
  
  <!--##sup##-->
  <!-- Matches sup elements; processing is done inside of text -->
  <xsl:template match="sup" mode="content">
    <xsl:apply-templates  mode="content"/>
  </xsl:template>
  
  <!--##italic##-->
  <!-- Matches italic elements; processing is done inside of text -->
  <xsl:template match="italic" mode="content">
    <xsl:apply-templates  mode="content"/>
  </xsl:template>
  
  <!-- Match inserted content: only used when diffx is applied -->
  <xsl:template match="dfx:ins" mode="content">
  <w:ins w:author="Pageseeder" w:date="fn:get-current-date()">
    <xsl:attribute name="w:id" select="count(preceding::dfx:ins) + count(preceding::dfx:del) + count(preceding::fragment) + count(ancestor::fragment) +count(preceding::xref) + count(preceding::document) + count(ancestor::document) + count(preceding::link[@name])"/>
    <xsl:apply-templates  mode="content"/>
    </w:ins>
  </xsl:template>
  
<!--   <xsl:template match="dfx:del[not(preceding-sibling::dfx:ins) and not(following-sibling::dfx:ins)]" mode="content"> -->
<!--     <w:r> -->
<!--       <w:rPr> -->
<!--         <w:highlight w:val="yellow"/> -->
<!--       </w:rPr> -->
<!--       <w:t>***</w:t> -->
<!--     </w:r> -->
<!--   </xsl:template> -->
  
  <!-- Match deleted content: only used when diffx is applied -->
  <xsl:template match="dfx:del" mode="content">
    <w:del w:author="Pageseeder" w:date="fn:get-current-date()">
    <xsl:attribute name="w:id" select="count(preceding::dfx:ins) + count(preceding::dfx:del) + count(preceding::fragment) + count(ancestor::fragment) +count(preceding::xref) + count(preceding::document) + count(ancestor::document) + count(preceding::link[@name])"/>
    <xsl:apply-templates  mode="content"/>
    </w:del>
  </xsl:template>
  
  <!--##monospace##-->
  <!-- Matches monospace elements; processing is done inside of text -->
  <xsl:template match="monospace" mode="content">
    <xsl:apply-templates  mode="content"/>
  </xsl:template>
  
  <!--##br##-->
  <!-- Matches br elements; creats paragraph if not inside a block element-->
  <xsl:template match="br" mode="content">
    <xsl:choose>
      <xsl:when
        test="preceding-sibling::*[fn:is-block-element(.)='true'] or following-sibling::*[fn:is-block-element(.)='true']">
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