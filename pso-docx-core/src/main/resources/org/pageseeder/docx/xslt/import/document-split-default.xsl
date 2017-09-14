<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to split to the content based on the headings in the document.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://www.pageseeder.com/function"
                exclude-result-prefixes="#all">

<!-- TODO Remove big chunks of commented content -->

<!--
  Main template generating sections from the Word body element `w:body`
-->
<xsl:template match="w:body" mode="content">
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
                      <xsl:variable name="body" as="element(body)">
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
              <!-- Document split for each section break first, then styles then outline level.
                 If any of the breaks match, only only break will be created  -->
              <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-document-split-sectionbreak(.)]">
                <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.)][string-join(w:r//text(), '') != '']|w:p[fn:matches-document-specific-split-styles(.)] ">
                  <xsl:if test="not(position() = 1)">

                    <xsl:variable name="document-number">
                      <xsl:value-of select="fn:count-preceding-documents(generate-id(current-group()[./name() = 'w:p'][string-join(w:r//text(), '') != ''][1]))" />
                    </xsl:variable>

                    <!-- create a body variable to be analysed for each document -->
                    <xsl:variable name="body" as="element()">
                      <body>
                        <xsl:apply-templates select="current-group()" mode="bodycopy" />
                      </body>
                    </xsl:variable>

                    <xsl:variable name="document-title" select="fn:generate-document-title($body)" />

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
                    <xsl:message select="concat('Generating document ',$document-number,'/',$number-of-splits,':',$document-title)" />
                    <xsl:message select="concat('Name of document: ',$_outputfolder,$document-full-filename,'.psml')" />

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
                        <xsl:apply-templates select="$body" mode="section-split">
                          <xsl:with-param name="document-title" select="$document-title" />
                          <xsl:with-param name="document-level" select="$level" tunnel="yes" />
                        </xsl:apply-templates>
                      </document>
                    </xsl:result-document>

                    <blockxref title="{$document-title}" frag="default" display="document"
                               type="embed" reverselink="true" reversetitle="" reversetype="none"
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
                <blockxref title="{concat($document-title,' footnotes')}" frag="default" display="document"
                           type="embed" reverselink="true" reversetitle="" reversetype="none"
                           href="footnotes/footnotes.psml">
                  <xsl:value-of select="concat($document-title,' footnotes')" />
                </blockxref>
              </xsl:if>

              <xsl:if test="doc-available($endnotes-file) and $convert-endnotes">
                <blockxref title="{concat($document-title,' endnotes')}" frag="default" display="document"
                           type="embed" reverselink="true" reversetitle="" reversetype="none"
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
              <!-- Document split for each section break first, then styles then outline level.
              If any of the breaks match, only only break will be created  -->
              <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-document-split-sectionbreak(.)]">
                <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.)][string-join(w:r//text(), '') != ''] |w:p[fn:matches-document-specific-split-styles(.)]">

                  <xsl:variable name="document-number">
                    <xsl:value-of select="fn:count-preceding-documents(generate-id(current-group()[./name() = 'w:p'][string-join(w:r//text(), '') != ''][1]))" />
                  </xsl:variable>

                  <!-- create a body variable to be analysed for each document -->
                  <xsl:variable name="body" as="element(body)">
                    <body>
                      <xsl:apply-templates select="current-group()" mode="bodycopy" />
                    </body>
                  </xsl:variable>

                  <xsl:variable name="document-title" select="fn:generate-document-title($body)" />

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
                          <xsl:if test="fn:document-label-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''">
                            <labels>
                              <xsl:value-of select="fn:document-label-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)" />
                            </labels>
                          </xsl:if>
                        </uri>
                      </documentinfo>

                      <xsl:apply-templates select="$body" mode="section-split">
                        <xsl:with-param name="document-title" select="$document-title" />
                        <xsl:with-param name="document-level" select="$level" tunnel="yes"/>
                      </xsl:apply-templates>
                    </document>
                  </xsl:result-document>

                  <blockxref title="{$document-title}" frag="default" display="document"
                             type="embed" reverselink="true" reversetitle="" reversetype="none"
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
                <blockxref title="{concat($document-title,' footnotes')}" frag="default" display="document"
                           type="embed" reverselink="true" reversetitle="" reversetype="none"
                           href="footnotes/footnotes.psml">
                  <xsl:value-of select="concat($document-title,' footnotes')" />
                </blockxref>
              </xsl:if>

              <xsl:if test="doc-available($endnotes-file) and $convert-endnotes">
                <blockxref title="{concat($document-title,' endnotes')}" frag="default" display="document"
                           type="embed" reverselink="true" reversetitle="" reversetype="none"
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
      <xsl:variable name="body" as="element(body)">
        <body>
          <xsl:apply-templates select="*" mode="bodycopy" />
        </body>
      </xsl:variable>

      <xsl:apply-templates select="$body" mode="section-split"/>

      <xsl:if test="doc-available($footnotes-file) and $convert-footnotes">
        <xref-fragment id="footnotes">
          <blockxref title="{concat($document-title,' footnotes')}" frag="default" display="document"
                     type="embed" reverselink="true" reversetitle="" reversetype="none"
                     href="footnotes/footnotes.psml">
            <xsl:value-of select="concat($document-title,' footnotes')" />
          </blockxref>
        </xref-fragment>
      </xsl:if>

      <xsl:if test="doc-available($endnotes-file) and $convert-endnotes">
        <xref-fragment id="endnotes">
          <blockxref title="{concat($document-title,' endnotes')}" frag="default" display="document"
                     type="embed" reverselink="true" reversetitle="" reversetype="none"
                     href="endnotes/endnotes.psml">
            <xsl:value-of select="concat($document-title,' endnotes')" />
          </blockxref>
        </xref-fragment>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>