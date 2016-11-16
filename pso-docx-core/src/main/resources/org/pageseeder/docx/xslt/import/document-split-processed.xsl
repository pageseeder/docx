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
  xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
  exclude-result-prefixes="#all">


  <!--##section##-->
  <!--##body##-->
<!-- =============================================================
         Match w:body
         Sections are created for every level of headings
     ============================================================= -->
  <xsl:template match="w:body" mode="processedpsml">

<!-- debug result document containing all paras and bookmarks with ids -->  
<!--    <xsl:result-document href="{concat($_outputfolder,'listparas.psml')}"> -->

<!--        <w:body xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006" -->
<!--   xmlns:o="urn:schemas-microsoft-com:office:office" -->
<!--   xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" -->
<!--   xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" -->
<!--   xmlns:v="urn:schemas-microsoft-com:vml" -->
<!--   xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" -->
<!--   xmlns:w10="urn:schemas-microsoft-com:office:word" -->
<!--   xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" -->
<!--   xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" -->
<!--   xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" -->
<!--   xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" -->
<!--   xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships" -->
<!--   xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" -->
<!--   xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" -->
<!--   xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" -->
<!--   xmlns:fn="http://www.pageseeder.com/function"> -->
<!--         <xsl:for-each select="$maindocument//w:p[not(matches(w:pPr/w:pStyle/@w:val, $ignore-paragraph-match-list-string))]|$maindocument//w:bookmarkStart"> -->
<!--           <xsl:element name="{name()}"> -->
<!--              <xsl:attribute name="id" select="generate-id(.)"/> -->
<!--              <xsl:if test="matches(w:pPr/w:pStyle/@w:val,$numbering-paragraphs-list-string)"> -->
<!--               <xsl:attribute name="numid" select="fn:get-numid-from-style(.)"/> -->
<!--              </xsl:if> -->
<!--              <xsl:copy-of select="@*"/> -->
<!--              <xsl:if test="w:pPr"> -->
<!--               <xsl:apply-templates select="w:pPr" mode="paracopy"/> -->
<!--              </xsl:if> -->
<!--            </xsl:element> -->
<!--          </xsl:for-each> -->
<!--        </w:body> -->
<!--       </xsl:result-document> -->

    <!-- master document will contain link to all split files  -->
    <xsl:choose>
      <xsl:when test="$split-by-documents">
        <xsl:choose>
          <xsl:when test="not(w:p[1][fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.)])">
            <section id="front">
              <fragment id="front">
              <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-document-split-sectionbreak(.)]">
                <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.)][string-join(w:r//text(), '') != ''] ">
                  <xsl:choose>
                    <xsl:when test="position() = 1">
                      <xsl:apply-templates select="current-group()" mode="content" />
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
<!--                 <xsl:message><xsl:value-of select="current-group()/w:p[1]"/></xsl:message> -->
                  <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.)][string-join(w:r//text(), '') != ''] ">
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
 <!-- create a body variable to be analysed for each document -->
                      <xsl:variable name="body" as="element()">
                        <body>
                          <xsl:apply-templates select="current-group()" mode="bodycopy" />
                        </body>
                      </xsl:variable>

                      
                      <xsl:variable name="document-title" select="fn:generate-document-title($body)"/>
                      
                      <xsl:variable name="document-full-filename">
                        <xsl:choose>
                          <xsl:when test="$generate-titles">
                            <xsl:value-of select="translate($document-title,'\W','_')"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="concat($filename,'-',format-number(number($document-number), $zeropadding))"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:variable>
                      
<!--                       <xsl:message ><xsl:value-of select="$filename"/></xsl:message> -->
                      <xsl:variable name="current-level">
                        <xsl:value-of select="$styles-document/w:styles/w:style[@w:styleId = $body/w:p[1]/w:pPr/w:pStyle/@w:val]/w:pPr/w:outlineLvl/@w:val" />
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
                      <blockxref title="{$document-title}" frag="default" display="document" type="embed" reverselink="true" reversetitle="" reversetype="none"
                        href="{encode-for-uri(concat($document-full-filename,'.psml'))}">
<!-- Not currently used: Levels push the heading level down ( so a Heading 1 at level 2, would be a Heading 3) -->
                       <xsl:if test="$level != '0'">
                        <xsl:attribute name="level" select="$level"/>
                       </xsl:if>
<!--                         <xsl:value-of select="$document-title" /> -->
                        
<!--                         <xsl:result-document href="{concat($_outputfolder,$filename,'-',format-number(number($document-number), $zeropadding),'.psml')}"> -->

                        <document level="processed">
                          <xsl:if test="fn:document-type-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''"> 
                             <xsl:attribute name="type" select="fn:document-type-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)"/>
                            </xsl:if>
                          <documentinfo>
                            <uri title="{$document-title}">
                              <displaytitle>
                                <xsl:value-of select="$document-title" />
                              </displaytitle>
                               <xsl:if test="fn:document-label-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''"> 
                              <labels><xsl:value-of select="fn:document-label-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)"/></labels>
                            </xsl:if>
                            </uri>
                             
                          </documentinfo>
                          <xsl:apply-templates select="$body" mode="section-split">
                            <xsl:with-param name="document-title" select="$document-title" />
                            <xsl:with-param name="document-level" select="$level" tunnel="yes"/>
                          </xsl:apply-templates>
                        </document>
<!--                       </xsl:result-document> -->
                      </blockxref>
                    </xsl:if>
                  </xsl:for-each-group>
                </xsl:for-each-group>
              </xref-fragment>
            </section>
          </xsl:when>
          <xsl:otherwise>
            <section id="content">
              <xref-fragment id="content">
        <!-- Document split for each section break first, then styles then outline level. If any of the breaks match, only only break will be created  -->
                <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-document-split-sectionbreak(.)]">
                <!--                 <xsl:message><xsl:value-of select="current-group()/w:p[1]"/></xsl:message> -->
                  <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.)][string-join(w:r//text(), '') != ''] ">

                  <xsl:variable name="document-number">
                      <xsl:value-of select="fn:count-preceding-documents(generate-id(current-group()[./name() = 'w:p'][string-join(w:r//text(), '') != ''][1]))" />
                    </xsl:variable>
                <!-- create a body variable to be analysed for each document -->
                    <xsl:variable name="body" as="element()">
                      <body>
                        <xsl:apply-templates select="current-group()" mode="bodycopy" />
                      </body>
                    </xsl:variable>

                    <xsl:variable name="document-title" select="fn:generate-document-title($body)"/>
                    
                    <xsl:variable name="document-full-filename">
                        <xsl:choose>
                          <xsl:when test="$generate-titles">
                            <xsl:value-of select="translate($document-title,'\W','_')"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="concat($filename,'-',format-number(number($document-number), $zeropadding))"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:variable>
                    <!--  <xsl:message select="concat($_outputfolder,$filename,'-',format-number(number($document-number), $zeropadding),'.psml')"/> -->
<!--                     <xsl:result-document href="{concat($_outputfolder,$filename,'-',format-number(number($document-number), $zeropadding),'.psml')}"> -->
                      <blockxref title="{$document-title}" frag="default" display="document" type="embed" reverselink="true" reversetitle="" reversetype="none"
                        href="{encode-for-uri(concat($document-full-filename,'.psml'))}">
                      
                      <document level="processed">
                          <xsl:if test="fn:document-type-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''"> 
                             <xsl:attribute name="type" select="fn:document-type-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)"/>
                            </xsl:if>
                        <documentinfo>
                          <uri title="{$document-title}">
                            <displaytitle>
                              <xsl:value-of select="$document-title" />
                            </displaytitle>
                             <xsl:if test="fn:document-label-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''"> 
                              <labels><xsl:value-of select="fn:document-label-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)"/></labels>
                            </xsl:if>
                          </uri>
                        </documentinfo>
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
                        <xsl:apply-templates select="$body" mode="section-split">
                          <xsl:with-param name="document-title" select="$document-title" />
                            <xsl:with-param name="document-level" select="$level" tunnel="yes"/>
                        </xsl:apply-templates>
                      </document>
                      </blockxref>
<!--                     </xsl:result-document> -->
                    <xsl:variable name="current-level">
                      <xsl:value-of select="$styles-document/w:styles/w:style[@w:styleId = $body/w:p[1]/w:pPr/w:pStyle/@w:val]/w:pPr/w:outlineLvl/@w:val" />
                    </xsl:variable>

                    <!--                      <xsl:variable name="level">  -->
<!--                        <xsl:choose> -->
<!--                          <xsl:when test="matches($current-level,($document-split-outline-string))"> -->
<!--                            <xsl:value-of select="number($current-level) + 1" /> -->
<!--                          </xsl:when> -->
<!--                          <xsl:otherwise> -->
<!--                            <xsl:text>0</xsl:text> -->
<!--                          </xsl:otherwise> -->
<!--                        </xsl:choose> -->
<!--                      </xsl:variable> -->
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
                    <blockxref title="{$document-title}" frag="default" display="document" type="embed" reverselink="true" reversetitle="" reversetype="none"
                      href="{encode-for-uri(concat($filename,'-',format-number(number($document-number), $zeropadding),'.psml'))}">
<!-- Not currently used: Levels push the heading level down ( so a Heading 1 at level 2, would be a Heading 3) -->
                    <xsl:if test="$level != '0'">
                      <xsl:attribute name="level" select="$level"/>
                    </xsl:if>
                      <xsl:value-of select="$document-title" />
                    </blockxref>
                  </xsl:for-each-group>
                </xsl:for-each-group>
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
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>