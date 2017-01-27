<?xml version="1.0"?>
<!-- 
  This XSLT simplifies the WordProcessingML by stripping the XML from markup 
  that isn't usually useful for transformations.
  
  This is partly based on Eric White's Markup Simplifier that is part of the 
  OpenXML powertools. 

   - RemoveComments
   - RemoveContentControls
   - RemoveEndAndFootNotes
   - RemoveFieldCodes
   - RemoveLastRenderedPageBreak (done)
   - RemovePermissions
   - RemoveProof (done)
   - RemoveRsidInfo (done - partially)
   - RemoveSmartTags
   - RemoveSoftHyphens
   - ReplaceTabsWithSpaces

  The final step collates identical styles together.
-->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" 
  xmlns:o="urn:schemas-microsoft-com:office:office" 
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" 
  xmlns:v="urn:schemas-microsoft-com:vml" 
  xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" 
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:w10="urn:schemas-microsoft-com:office:word" 
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" 
  xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" 
  xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
  xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" 
  xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
  xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types" 
  xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
  xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:f="http://www.pageseeder.com/function"
  xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main"
  xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
  exclude-result-prefixes="#all">


<!-- Configuration options -->

<xsl:param name="remove-custom-xml"               select="'true'"/>
<xsl:param name="remove-smart-tags"               select="'true'"/>
<xsl:param name="remove-content-controls"         select="'true'"/>
<xsl:param name="remove-rsid-info"                select="'true'"/>
<xsl:param name="remove-permissions"              select="'true'"/>
<xsl:param name="remove-proof"                    select="'true'"/>
<xsl:param name="remove-soft-hyphens"             select="'true'"/>
<xsl:param name="remove-last-rendered-page-break" select="'true'"/>
<xsl:param name="remove-goback-bookmarks"         select="'true'"/>
<xsl:param name="remove-bookmarks"                select="'true'"/>
<xsl:param name="remove-web-hidden"               select="'true'"/>
<xsl:param name="remove-language-info"            select="'true'"/>
<xsl:param name="remove-comments"                 select="'true'"/>
<xsl:param name="remove-end-and-foot-notes"       select="'true'"/>
<xsl:param name="remove-field-codes"              select="'true'"/>
<xsl:param name="replace-nobreak-hyphens"         select="'true'"/>
<xsl:param name="replace-tabs"                    select="'true'"/>
<xsl:param name="remove-font-info"                select="'true'"/>
<xsl:param name="remove-paragraph-properties"     select="'true'"/>


<!-- Generating XML output -->
<xsl:output encoding="UTF-8" method="xml" indent="no" standalone="yes"/>

<!-- ========================================================================================= -->
<!-- Default templates                                                                         -->
<!-- ========================================================================================= -->

<xsl:template match="/">
  <xsl:sequence select="f:purge(f:consolidate(f:purge(f:simplify(node()))))"/>
</xsl:template>

<!-- Copy attributes by default -->
<xsl:template match="@*" mode="#all">
  <xsl:copy/>
</xsl:template>

<!-- Copy elements and their content by default -->
<xsl:template match="*" mode="#all">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="#current"/>
    <xsl:apply-templates mode="#current"/>
  </xsl:copy>
</xsl:template>

<!-- ========================================================================================= -->
<!-- 1. Simplify by removing markup                                                            -->
<!-- ========================================================================================= -->

<!-- 
   Purge the data from all the empty runs and run properties
-->
<xsl:function name="f:simplify">
  <xsl:param name="data"/>
  <xsl:apply-templates select="$data" mode="simplify"/>
</xsl:function>

<!-- Remove custom XML -->
<xsl:template match="w:customXml[$remove-custom-xml = 'true']" mode="simplify">
  <xsl:apply-templates select="*" mode="simplify"/>
</xsl:template>
<xsl:template match="w:customXmlPr[$remove-custom-xml = 'true']" mode="simplify"/>

<!-- Remove Smart Tags -->
<!-- TODO Should we preserve some of the content??? -->
<xsl:template match="w:smartTag[$remove-smart-tags = 'true']" mode="simplify">
  <xsl:apply-templates select="*" mode="simplify"/>
</xsl:template>
<xsl:template match="w:smartTagPr[$remove-smart-tags = 'true']" mode="simplify"/>


<!-- Remove Structured Document Tags -->
<!-- TODO Should we preserve some of the content??? -->
<xsl:template match="w:sdt[$remove-content-controls = 'true']" mode="simplify">
  <xsl:apply-templates select="w:sdtContent/*" mode="simplify"/>
</xsl:template>

<!-- Remove RSID Info -->
<xsl:template match="@w:rsid        [$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidDel     [$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidP       [$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidR       [$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidRDefault[$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidRPr     [$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidSect    [$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidTr      [$remove-rsid-info = 'true']" mode="simplify"/>

<!-- Remove permissions -->
<xsl:template match="w:permEnd   [$remove-permissions = 'true']" mode="simplify"/>
<xsl:template match="w:permStart [$remove-permissions = 'true']" mode="simplify" />

<!-- Remove proofing errors -->
<xsl:template match="w:proofErr  [$remove-proof = 'true']" mode="simplify"/>
<xsl:template match="w:noProof   [$remove-proof = 'true']" mode="simplify" />

<!-- Remove soft hyphens -->
<xsl:template match="w:softHyphen[$remove-soft-hyphens = 'true']" mode="simplify"/>

<!-- Remove last rendered page break -->
<xsl:template match="w:lastRenderedPageBreak[$remove-last-rendered-page-break = 'true']" mode="simplify"/>

<!-- Remove bookmarks -->
<xsl:template match="w:bookmarkStart[$remove-bookmarks = 'true']" mode="simplify"/>
<xsl:template match="w:bookmarkEnd  [$remove-bookmarks = 'true']" mode="simplify"/>

<xsl:template match="w:bookmarkStart[@w:name='_GoBack'][$remove-goback-bookmarks = 'true']" mode="simplify"/>
<xsl:template match="w:bookmarkEnd[@w:id= preceding::w:bookmarkStart[@w:name='_GoBack']/@w:id][$remove-goback-bookmarks = 'true']" mode="simplify"/>

<!-- Remove Web Hidden -->
<xsl:template match="w:webHidden[$remove-web-hidden = 'true']" mode="simplify"/>

<!-- Remove language declarations -->
<xsl:template match="w:lang[$remove-language-info = 'true']" mode="simplify"/>

<!-- Remove Comments -->
<xsl:template match="w:commentRangeStart [$remove-comments = 'true']" mode="simplify"/>
<xsl:template match="w:commentRangeEnd   [$remove-comments = 'true']" mode="simplify"/>
<xsl:template match="w:commentReference  [$remove-comments = 'true']" mode="simplify"/>
<xsl:template match="w:annotationRef     [$remove-comments = 'true']" mode="simplify"/>
<xsl:template match="w:rStyle[w:val = 'CommentReference'][$remove-comments = 'true']" mode="simplify"/>

<!-- Remove End And Foot Notes -->
<xsl:template match="w:endnoteReference [$remove-end-and-foot-notes = 'true']" mode="simplify"/>
<xsl:template match="w:footnoteReference[$remove-end-and-foot-notes = 'true']" mode="simplify"/>

<!-- Remove Field Codes -->
<xsl:template match="w:fldSimple[$remove-field-codes = 'true']" mode="simplify">
  <xsl:apply-templates mode="simplify"/>
</xsl:template>
<xsl:template match="w:fldData  [$remove-field-codes = 'true']" mode="simplify"/>
<xsl:template match="w:fldChar  [$remove-field-codes = 'true']" mode="simplify"/>
<xsl:template match="w:instrText[$remove-field-codes = 'true']" mode="simplify"/>

<!-- Replace the no break hyphens -->
<xsl:template match="w:noBreakHyphen[$replace-nobreak-hyphens = 'true']" mode="simplify">
  <w:t xml:space="preserve">-</w:t>
</xsl:template>

<!-- Replace tabs -->
<xsl:template match="w:tab[$replace-tabs = 'true']" mode="simplify">
  <w:t xml:space="preserve">&#x9;</w:t>
</xsl:template>


<!-- Remove font information -->
<xsl:template match="w:rFonts        [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:sz            [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:szCs          [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:bCs           [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:color         [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:specVanish    [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:rPr/w:spacing [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:u[@w:val='none']"                           mode="simplify"/>

<!-- Remove paragraph Properties -->
<xsl:template match="w:tabs          [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:ind           [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:cnfStyle      [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:jc            [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:keepLines     [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:keepNext      [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:pBdr          [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:shd           [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:pPr/w:spacing [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:textAlignment [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:snapToGrid    [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:mirrorIndents [$remove-paragraph-properties = 'true']" mode="simplify"/>
 
   
  
  
  
  
<!-- ========================================================================================= -->
<!-- Remove empty runs and run properties                                                      -->
<!-- ========================================================================================= -->

<!-- 
   Purge the data from all the empty runs and run properties
-->
<xsl:function name="f:purge">
  <xsl:param name="data"/>
  <xsl:apply-templates select="$data" mode="purge"/>
</xsl:function>

<xsl:template match="w:r[not(*)]"   mode="purge" />
<xsl:template match="w:rPr[not(*)]" mode="purge" />
<xsl:template match="w:pPr[not(*)]" mode="purge" />


<!-- ========================================================================================= -->
<!-- Templates to consolidate the runs that share the same properties                          -->
<!-- ========================================================================================= -->

<!-- 
   Purge the data from all the empty runs and run properties
-->
<xsl:function name="f:consolidate">
  <xsl:param name="data"/>
  <xsl:apply-templates select="$data" mode="consolidate"/>
</xsl:function>

<xsl:template match="w:pPr" mode="consolidate">
  <xsl:element name="{./name()}">
    <xsl:copy-of select="@*"/>
    <xsl:for-each-group select="*" group-adjacent="f:key-for-run(.)">
      <!-- Not a Run -->
      <xsl:if test="not(self::w:rPr)">
        <xsl:apply-templates select="current-group()" mode="consolidate"/>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:element>
</xsl:template>

<xsl:template match="w:p|w:hyperlink|w:sdt|w:smartTag" mode="consolidate">
<xsl:element name="{./name()}">
  <xsl:copy-of select="@*"/>
  
  <xsl:variable name="paragraphTextRunProperties" as="element()">
      <w:rPr>
      <xsl:choose>
        <xsl:when test="./w:pPr/w:rPr">
          <xsl:copy-of select="w:rPr/*"/>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
      </w:rPr>
    </xsl:variable>
    
  <xsl:for-each-group select="*" group-adjacent="f:key-for-run(.)">
    
    <xsl:choose>

      <!-- Not a Run -->
      <xsl:when test="not(self::w:r)">
        <xsl:apply-templates select="current-group()" mode="consolidate"/>
      </xsl:when>

      <!-- Runs -->
      <xsl:otherwise>
        <xsl:variable name="runs" select="current-group()"/>
        <xsl:for-each-group select="current-group()/*" group-adjacent="if (self::w:br) then 1 else 2">
        <xsl:choose>
          <xsl:when test="current-grouping-key() = 1">
            <w:r>
              <xsl:copy-of select="current-group()"/>
            </w:r>
          </xsl:when>
          <xsl:otherwise>
            
          <xsl:for-each-group select="current-group()" group-starting-with="w:fldChar[@w:fldCharType='begin']">
            <xsl:for-each-group select="current-group()" group-ending-with="w:fldChar[@w:fldCharType='end']">  
            <w:r>
              <!-- Include run properties (from the first match - they are identical)-->
              <w:rPr>
                <xsl:variable name="runProperties" as="element()">
                  <w:rPr>
                    <xsl:copy-of select="$runs/w:rPr[1]"/>
                  </w:rPr>
                </xsl:variable>
<!--                 <xsl:message><xsl:apply-templates select="$runProperties" mode="xml"/></xsl:message> -->
                <xsl:for-each select="$runs/w:rPr">
<!--                   <xsl:message>#<xsl:value-of select="./name()" />:: -->
<!--                   <xsl:for-each select="./preceding-sibling::*"> -->
<!--                       <xsl:value-of select="./name()" /> -->
<!--                   </xsl:for-each> -->
<!--                   </xsl:message> -->
                    <xsl:choose>
                      <xsl:when test="position() = 1">
                        <xsl:copy-of select="./*"/>
                      </xsl:when>
                      <xsl:otherwise>
<!--                         <xsl:value-of select="concat('^',./name(),'$','|')" /> -->
                      </xsl:otherwise>
                    </xsl:choose>
                   </xsl:for-each>
                
                
                <xsl:variable name="runPropertyMatch">
                  <xsl:for-each select="$runs/w:rPr[1]/*">
                    <xsl:choose>
							        <xsl:when test="position() = last()">
							          <xsl:value-of select="concat('^',./name(),'$')" />
							        </xsl:when>
							        <xsl:otherwise>
							          <xsl:value-of select="concat('^',./name(),'$','|')" />
							        </xsl:otherwise>
							      </xsl:choose>
                   </xsl:for-each>
                </xsl:variable>
<!--                 <xsl:message>###<xsl:value-of select="$runPropertyMatch" /></xsl:message> -->
                  <xsl:for-each select="$paragraphTextRunProperties/*">
<!--                   <xsl:message><xsl:value-of select="./name()" /></xsl:message> -->
                  <xsl:if test="not(matches(./name(),$runPropertyMatch))">
                    <xsl:copy-of select="."/>
                  </xsl:if>
                </xsl:for-each>
                 
               
                
                
              </w:rPr>
<!--               <xsl:apply-templates select="$runs/w:rPr" mode="consolidate"/> -->
<!--                Collate other nodes --> 
              
              <xsl:for-each-group select="current-group()[not(self::w:rPr)]" group-adjacent="if (self::w:t) then 1 else if (self::w:instrText) then 2 else 3">
				        <xsl:choose>
				          <xsl:when test="current-grouping-key() = 1">
				            <w:t xml:space="preserve"><xsl:value-of select="current-group()" separator=""/></w:t>
				          </xsl:when>
				          <xsl:when test="current-grouping-key() = 2">
                    <w:instrText xml:space="preserve"><xsl:value-of select="current-group()" separator=""/></w:instrText>
                  </xsl:when>
				          <xsl:otherwise>
                    <xsl:apply-templates select="current-group()" mode="consolidate"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each-group>

            </w:r>
            </xsl:for-each-group>
            </xsl:for-each-group>
          </xsl:otherwise>
        </xsl:choose>
         
	        
        </xsl:for-each-group>
        
      </xsl:otherwise>

    </xsl:choose>
  
  </xsl:for-each-group>
</xsl:element>
</xsl:template>



<!-- <xsl:template match="w:hyperlink" mode="consolidate"> -->
<!-- <w:hyperlink> -->
<!--   <xsl:copy-of select="@*"/> -->
<!--   <xsl:for-each-group select="*" group-adjacent="f:key-for-run(.)"> -->
<!--     <xsl:choose> -->

<!--       Not a Run -->
<!--       <xsl:when test="not(self::w:r)"> -->
<!--         <xsl:apply-templates select="current-group()" mode="consolidate"/> -->
<!--       </xsl:when> -->

<!--       Runs -->
<!--       <xsl:otherwise> -->
<!--         <xsl:variable name="runs" select="current-group()"/> -->
<!--         <w:r> -->
<!--           Include run properties (from the first match - they are identical) -->
<!--           <xsl:apply-templates select="w:rPr" mode="consolidate"/> -->
<!--           Collate other nodes -->
<!--           <xsl:for-each-group select="$runs/*[not(self::w:rPr)]" group-by="name()"> -->
<!--             <xsl:choose> -->
<!--               <xsl:when test="self::w:t"> -->
<!--                 <w:t xml:space="preserve"><xsl:value-of select="current-group()" separator=""/></w:t> -->
<!--               </xsl:when> -->
<!--               <xsl:otherwise> -->
<!--                 <xsl:apply-templates select="current-group()" mode="consolidate"/> -->
<!--               </xsl:otherwise> -->
<!--             </xsl:choose> -->
<!--           </xsl:for-each-group> -->
<!--         </w:r> -->
<!--       </xsl:otherwise> -->

<!--     </xsl:choose> -->
  
<!--   </xsl:for-each-group> -->
<!-- </w:hyperlink> -->
<!-- </xsl:template> -->


<!--
  Returns a key for the run being processed
-->
<xsl:function name="f:key-for-run" as="xs:string">
  <xsl:param name="r"/>
  <xsl:choose>
    <xsl:when test="$r[self::w:r]/w:rPr/w:rStyle"><xsl:value-of select="$r/w:rPr/w:rStyle/@w:val"/></xsl:when>
    <xsl:when test="$r[self::w:r]/w:rPr">
      <xsl:variable name="serialised"><xsl:apply-templates select="$r/w:rPr" mode="serialize"/></xsl:variable>
      <xsl:value-of select="$serialised"/>
    </xsl:when>
    <xsl:when test="$r/self::w:r">{}</xsl:when>
    <xsl:otherwise>--</xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ========================================================================================= -->
<!-- Serialise XML                                                                             -->
<!-- ========================================================================================= -->

<!-- Copy attributes by default -->
<xsl:template match="@*" mode="serialize" priority="1">
  <xsl:text>[</xsl:text>
  <xsl:value-of select="name()"/>=<xsl:value-of select="."/>
  <xsl:text>]</xsl:text>
</xsl:template>

<!-- Copy elements and their content by default -->
<xsl:template match="*" mode="serialize" priority="1">
  <xsl:text>{</xsl:text>
  <xsl:value-of select="name()"/>
  <xsl:apply-templates select="@*" mode="serialize"/>
  <xsl:apply-templates select="*|text()" mode="serialize"/>
  <xsl:text>}</xsl:text>
</xsl:template>

 <!-- 
  Templates to output a XML tree as text
  <a>
    <b c="1">
      text
    </b>
  </a>
      
  To display the source XML simply use <xsl:apply-templates mode="xml"/>
-->
  <xsl:template match="*" mode="encode">
    <xsl:value-of select="concat('&lt;',name())"
      disable-output-escaping="yes" />
    <xsl:apply-templates select="@*" mode="encode" />
    <xsl:text>></xsl:text>
    <xsl:apply-templates mode="encode" />
    <xsl:value-of select="concat('&lt;',name(),'>')"
      disable-output-escaping="yes" />
  </xsl:template>
  <xsl:template match="*[not(node())]" mode="encode">
    <xsl:value-of select="concat('&lt;',name())"
      disable-output-escaping="yes" />
    <xsl:apply-templates select="@*" mode="encode" />
    <xsl:text>/></xsl:text>
  </xsl:template>
  <xsl:template match="@*" mode="encode">
    <xsl:value-of select="concat(' ',name(),'=&quot;',.,'&quot;')" />
  </xsl:template>

  <xsl:template match="*[not(text()|*)]" mode="xml">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()" />
    <xsl:apply-templates select="@*" mode="xml" />
    <xsl:text>/&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="*[text()|*]" mode="xml">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()" />
    <xsl:apply-templates select="@*" mode="xml" />
    <xsl:text>&gt;</xsl:text>
    <xsl:apply-templates select="*|text()" mode="xml" />
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="name()" />
    <xsl:text>&gt;</xsl:text>
  </xsl:template>

  <xsl:template match="text()" mode="xml">
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="@*" mode="xml">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()" />
    ="
    <xsl:value-of select="." />
    <xsl:text>"</xsl:text>
  </xsl:template>
  
</xsl:stylesheet>
