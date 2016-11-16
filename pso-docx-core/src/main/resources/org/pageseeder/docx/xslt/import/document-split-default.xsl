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
  xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main" xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships" xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
  xmlns:dgm="http://schemas.openxmlformats.org/drawingml/2006/diagram" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
  xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/" xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.pageseeder.com/function"
  xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" exclude-result-prefixes="#all">


  <!--##section##-->
  <!--##body##-->
<!-- =============================================================
         Match w:body
         Sections are created for every level of headings
     ============================================================= -->
  <xsl:template match="w:body" mode="content">
<!-- debug result document containing all paras and bookmarks with ids 	
   <xsl:result-document href="{concat($_outputfolder,'listparas.psml')}">

       <w:body xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
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
  xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.pageseeder.com/function">
        <xsl:for-each select="$maindocument//w:p[not(parent::w:tc)][not(matches(w:pPr/w:pStyle/@w:val, $ignore-paragraph-match-list-string))][string-join(w:r//text(), '') != '']|$maindocument//w:bookmarkStart|$maindocument//w:tc">
        <xsl:element name="{name()}">
          <xsl:attribute name="id" select="generate-id(.)" />
          <xsl:copy-of select="@*" />
          <xsl:if test="w:pPr">
            <xsl:apply-templates select="w:pPr" mode="paracopy" />
          </xsl:if>
          <xsl:if test="w:p">
            <xsl:apply-templates select="w:p" mode="paracopy" />
          </xsl:if>
        </xsl:element>
      </xsl:for-each>
        
       </w:body>
      </xsl:result-document>
-->
	  <!-- master document will contain link to all split files  -->
    <xsl:choose>
      <xsl:when test="$split-by-documents">
        <xsl:choose>
          <xsl:when test="not(*[1][fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.) or fn:matches-document-specific-split-styles(.)])">
            <section id="front">
              <fragment id="front">
                <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-document-split-sectionbreak(.)]">
                  <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.)][string-join(w:r//text(), '') != '']|w:p[fn:matches-document-specific-split-styles(.)] ">
                    <xsl:choose>
                      <xsl:when test="position() = 1">
<!-- 										    <xsl:result-document href="{concat($_outputfolder,'body1.psml')}"> -->
<!--                   <body id="{generate-id(current-group()[./name() = 'w:p'][1])}" number="{fn:count-preceding-documents(generate-id(current-group()[./name() = 'w:p'][1]))}">                     -->
<!--                      <xsl:apply-templates select="current-group()" mode="bodycopy"/> -->
<!--                     <xsl:for-each select="current-group()"> -->
<!--                       <xsl:choose> -->
<!--                         <xsl:when test="self::w:p"> -->
<!--                           <xsl:element name="w:p"> -->
<!--                             <xsl:attribute name="id" select="generate-id()"/> -->
<!--                             <xsl:copy-of select="*" /> -->
<!--                           </xsl:element> -->
<!--                           <xsl:copy-of select="current-group()" /> -->
<!--                         </xsl:when> -->
<!--                         <xsl:otherwise> -->
<!--                           <xsl:copy-of select="." /> -->
<!--                         </xsl:otherwise> -->
<!--                       </xsl:choose> -->
<!--                     </xsl:for-each> -->
<!--                     <xsl:copy-of select="current-group()" /> -->
<!--                   </body> -->
<!--                 </xsl:result-document> -->
                        <xsl:variable name="body" as="element()">
                          <body>
                            <xsl:apply-templates select="current-group()" mode="bodycopy" />
                          </body>
                        </xsl:variable>
                        <xsl:apply-templates select="$body" mode="content" />



                      </xsl:when>
                      <xsl:otherwise></xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each-group>
                </xsl:for-each-group>
              </fragment>
            </section>
            <section id="content">
              <xref-fragment id="content">
        <!-- Document split for each section break first, then styles then outline level. If any of the breaks match, only only break will be created  -->
                <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-document-split-sectionbreak(.)]">
                  <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.)][string-join(w:r//text(), '') != '']|w:p[fn:matches-document-specific-split-styles(.)] ">
                    <xsl:if test="not(position() = 1)">
<!-- debug result document used to check different splits -->
<!--                  <xsl:result-document href="{concat($_outputfolder,'body',fn:count-preceding-documents(generate-id(current-group()[./name() = 'w:p'][1])),'.psml')}"> -->
                  
<!--                   <body id="{generate-id(current-group()[./name() = 'w:p'][1])}" number="{fn:count-preceding-documents(generate-id(current-group()[./name() = 'w:p'][1]))}">                     -->
<!--                      <xsl:apply-templates select="current-group()" mode="bodycopy"/> -->

<!--                   </body> -->
<!--                 </xsl:result-document> -->

                      <xsl:variable name="document-number">
                        <xsl:value-of select="fn:count-preceding-documents(generate-id(current-group()[./name() = 'w:p'][string-join(w:r//text(), '') != ''][1]))" />
                      </xsl:variable>
<!--                       <xsl:message select="generate-id(current-group()[./name() = 'w:p'][string-join(w:r//text(), '') != ''][1])"/> -->
<!--                       <xsl:message select="$document-split-sectionbreak"/> -->
                      
 <!-- create a body variable to be analysed for each document -->
                      <xsl:variable name="body" as="element()">
                        <body>
                          <xsl:apply-templates select="current-group()" mode="bodycopy" />
                        </body>
                      </xsl:variable>

                      <xsl:variable name="document-title" select="fn:generate-document-title($body)" />
                      
<!--                       <xsl:variable name="generate-titles" select="true()"/> -->

                      <xsl:variable name="document-full-filename">
                        <xsl:choose>
                          <xsl:when test="$generate-titles">
                            <xsl:value-of select="translate($document-title,'\W','_')" />
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="concat($filename,'-',format-number(number($document-number), $zeropadding))" />
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:variable>
                      <xsl:message><xsl:value-of select="concat('Generating document ',$document-number,'/',$number-of-splits,':',$document-title)" /></xsl:message>
                      <xsl:message><xsl:value-of select="concat('Name of document: ',$_outputfolder,$document-full-filename,'.psml')" /></xsl:message>
                      
                      <xsl:variable name="level">
                        <xsl:choose>
                          <xsl:when test="fn:document-level-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''">
                            <xsl:value-of select="fn:document-level-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)" />
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>0</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:variable>
                      
                      <xsl:result-document
                        href="{concat($_outputfolder,if($generate-titles) then translate($document-title,'\W','_') else concat(encode-for-uri($filename),'-',format-number(number($document-number), $zeropadding)),'.psml')}">

                        <document level="portable">
                          <xsl:if test="fn:document-type-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''">
                            <xsl:attribute name="type" select="fn:document-type-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)" />
                          </xsl:if>
                          <documentinfo>
                            <uri title="{$document-title}">
                              <displaytitle>
                                <xsl:value-of select="$document-title" />
                              </displaytitle>
                              <xsl:if test="fn:document-label-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''">
                                <labels>
                                  <xsl:value-of select="fn:document-label-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)" />
                                </labels>
                              </xsl:if>
                            </uri>
                          </documentinfo>
<!--                           <xsl:message select="$level"/> -->
                          <xsl:apply-templates select="$body" mode="section-split">
                            <xsl:with-param name="document-title" select="$document-title" />
                            <xsl:with-param name="document-level" select="$level" tunnel="yes" />
                          </xsl:apply-templates>
                        </document>
                      </xsl:result-document>

                      <xsl:variable name="current-level">
                        <xsl:value-of select="$styles-document/w:styles/w:style[@w:styleId = $body/w:p[1]/w:pPr/w:pStyle/@w:val]/w:pPr/w:outlineLvl/@w:val" />
                      </xsl:variable>

                      
                      
                      <blockxref title="{$document-title}" frag="default" display="document" type="embed" reverselink="true" reversetitle="" reversetype="none"
                        href="{encode-for-uri(concat($document-full-filename,'.psml'))}">
<!-- Not currently used: Levels push the heading level down ( so a Heading 1 at level 2, would be a Heading 3) -->
                        <xsl:if test="$level != '0'">
                          <xsl:attribute name="level" select="$level" />
                        </xsl:if>
                        <xsl:value-of select="$document-title" />
                      </blockxref>
                    </xsl:if>
                  </xsl:for-each-group>
                </xsl:for-each-group>
                <xsl:if test="doc-available($footnotes-file) and $convert-footnotes">
                  <blockxref title="{concat($document-title,' footnotes')}" frag="default" display="document" type="embed" reverselink="true" reversetitle="" reversetype="none"
                        href="footnotes/footnotes.psml">
                        <xsl:value-of select="concat($document-title,' footnotes')" />
                      </blockxref>
                </xsl:if>
                
                <xsl:if test="doc-available($endnotes-file) and $convert-endnotes">
                  <blockxref title="{concat($document-title,' endnotes')}" frag="default" display="document" type="embed" reverselink="true" reversetitle="" reversetype="none"
                        href="endnotes/endnotes.psml">
                        <xsl:value-of select="concat($document-title,' endnotes')" />
                      </blockxref>
                </xsl:if>
              </xref-fragment>
            </section>
          </xsl:when>
          <xsl:otherwise>
            <section id="content">
              <xref-fragment id="content">
        <!-- Document split for each section break first, then styles then outline level. If any of the breaks match, only only break will be created  -->
                <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-document-split-sectionbreak(.)]">
                <!--                 <xsl:message><xsl:value-of select="current-group()/w:p[1]"/></xsl:message> -->
                  <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.)][string-join(w:r//text(), '') != ''] |w:p[fn:matches-document-specific-split-styles(.)]">

                    <xsl:variable name="document-number">
                      <xsl:value-of select="fn:count-preceding-documents(generate-id(current-group()[./name() = 'w:p'][string-join(w:r//text(), '') != ''][1]))" />
                    </xsl:variable>
                  
                <!-- create a body variable to be analysed for each document -->
                    <xsl:variable name="body" as="element()">
                      <body>
                        <xsl:apply-templates select="current-group()" mode="bodycopy" />
                      </body>
                    </xsl:variable>

										<!-- debug result document used to check different splits -->
<!--                  <xsl:result-document href="{concat($_outputfolder,'body',fn:count-preceding-documents(generate-id(current-group()[./name() = 'w:p'][1])),'.psml')}"> -->
                  
<!--                   <body id="{generate-id(current-group()[./name() = 'w:p'][1])}" number="{fn:count-preceding-documents(generate-id(current-group()[./name() = 'w:p'][1]))}">                     -->
<!--                      <xsl:apply-templates select="current-group()" mode="bodycopy"/> -->

<!--                   </body> -->
<!--                 </xsl:result-document> -->
                    <xsl:variable name="document-title" select="fn:generate-document-title($body)" />
                    
<!--                     <xsl:variable name="generate-titles" select="true()"/> -->

                    <xsl:variable name="document-full-filename">
                      <xsl:choose>
                        <xsl:when test="$generate-titles">
                          <xsl:value-of select="translate($document-title,'\W','_')" />
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="concat($filename,'-',format-number(number($document-number), $zeropadding))" />
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:variable name="level">
                      <xsl:choose>
                        <xsl:when test="fn:document-level-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''">
                          <xsl:value-of select="fn:document-level-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)" />
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text>0</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:result-document
                      href="{concat($_outputfolder,if($generate-titles) then translate($document-title,'\W','_') else concat(encode-for-uri($filename),'-',format-number(number($document-number), $zeropadding)),'.psml')}">
                      <xsl:message><xsl:value-of select="concat('Generating document ',$document-number,'/',$number-of-splits,':',$document-title)" /></xsl:message>
                      <document level="portable">
                        <xsl:if test="fn:document-type-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''">
                          <xsl:attribute name="type" select="fn:document-type-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)" />
                        </xsl:if>
                        <documentinfo>
                          <uri title="{$document-title}">
                            <displaytitle>
                              <xsl:value-of select="$document-title" />
                            </displaytitle>
<!-- 														<xsl:message>1: <xsl:value-of select="$body/w:p[1]/w:pPr/w:pStyle/@w:val"/></xsl:message> -->
                            <xsl:if test="fn:document-label-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''">
                              <labels>
                                <xsl:value-of select="fn:document-label-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)" />
                              </labels>
                            </xsl:if>
                          </uri>
                        </documentinfo>
<!--                           <xsl:message select="$level"/> -->
                        <xsl:apply-templates select="$body" mode="section-split">
                          <xsl:with-param name="document-title" select="$document-title" />
                          <xsl:with-param name="document-level" select="$level" tunnel="yes"/>
                        </xsl:apply-templates>
                      </document>
                    </xsl:result-document>
                    <xsl:variable name="current-level">
                      <xsl:value-of select="$styles-document/w:styles/w:style[@w:styleId = $body/w:p[1]/w:pPr/w:pStyle/@w:val]/w:pPr/w:outlineLvl/@w:val" />
                    </xsl:variable>

                    

                    <blockxref title="{$document-title}" frag="default" display="document" type="embed" reverselink="true" reversetitle="" reversetype="none"
                      href="{encode-for-uri(concat($document-full-filename,'.psml'))}">
<!-- Not currently used: Levels push the heading level down ( so a Heading 1 at level 2, would be a Heading 3) -->
                      <xsl:if test="$level != '0'">
                        <xsl:attribute name="level" select="$level" />
                      </xsl:if>
                      <xsl:value-of select="$document-title" />
                    </blockxref>
                  </xsl:for-each-group>
                </xsl:for-each-group>
                <xsl:if test="doc-available($footnotes-file) and $convert-footnotes">
                  <blockxref title="{concat($document-title,' footnotes')}" frag="default" display="document" type="embed" reverselink="true" reversetitle="" reversetype="none"
                        href="footnotes/footnotes.psml">
                        <xsl:value-of select="concat($document-title,' footnotes')" />
                      </blockxref>
                </xsl:if>
                
                <xsl:if test="doc-available($endnotes-file) and $convert-endnotes">
                  <blockxref title="{concat($document-title,' endnotes')}" frag="default" display="document" type="embed" reverselink="true" reversetitle="" reversetype="none"
                        href="endnotes/endnotes.psml">
                        <xsl:value-of select="concat($document-title,' endnotes')" />
                      </blockxref>
                </xsl:if>
              </xref-fragment>
            </section>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="body" as="element()">
          <body>
            <xsl:apply-templates select="*" mode="bodycopy" />
          </body>
        </xsl:variable>
        <xsl:apply-templates select="$body" mode="section-split">
        </xsl:apply-templates>
        
        <xsl:if test="doc-available($footnotes-file) and $convert-footnotes">
        <xref-fragment id="footnotes">
                  <blockxref title="{concat($document-title,' footnotes')}" frag="default" display="document" type="embed" reverselink="true" reversetitle="" reversetype="none"
                        href="footnotes/footnotes.psml">
                        <xsl:value-of select="concat($document-title,' footnotes')" />
                      </blockxref>
                      </xref-fragment>
                </xsl:if>
                
                <xsl:if test="doc-available($endnotes-file) and $convert-endnotes">
                <xref-fragment id="endnotes">
                  <blockxref title="{concat($document-title,' endnotes')}" frag="default" display="document" type="embed" reverselink="true" reversetitle="" reversetype="none"
                        href="endnotes/endnotes.psml">
                        <xsl:value-of select="concat($document-title,' endnotes')" />
                      </blockxref>
                      </xref-fragment>
                </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>