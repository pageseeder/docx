<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to split to the content based on the headings in the document and generate a single processed PSML
  document where the document content is inlined within the blockxrefs.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!-- =============================================================
         Match w:body
         Sections are created for every level of headings
     ============================================================= -->
<xsl:template match="w:body" mode="processed-psml">

  <!-- master document will contain link to all split files  -->
  <xsl:choose>
    <xsl:when test="config:split-by-documents()">
      <xsl:variable name="frontmatter"
          select="not(*[1][config:matches-document-split-styles(.) or fn:matches-document-split-outline(.) or config:matches-document-specific-split-styles(.)])" />
      <section id="title">
        <fragment id="1">
        <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-document-split-sectionbreak(.)]">
          <xsl:for-each-group select="current-group()" group-starting-with="w:p[config:matches-document-split-styles(.) or fn:matches-document-split-outline(.)][string-join(w:r//text(), '') != '']|w:p[config:matches-document-specific-split-styles(.)]">
            <xsl:if test="position() = 1 and $frontmatter">
              <xsl:apply-templates select="current-group()" mode="content" />
            </xsl:if>
          </xsl:for-each-group>
        </xsl:for-each-group>
        </fragment>
      </section>
      <section id="xrefs">
        <xref-fragment id="2">
          <!-- Document split for each section break first, then styles then outline level.
          If any of the breaks match, only only break will be created  -->
          <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-document-split-sectionbreak(.)]">

            <xsl:for-each-group select="current-group()" group-starting-with="w:p[config:matches-document-split-styles(.) or fn:matches-document-split-outline(.)][string-join(w:r//text(), '') != '']|w:p[config:matches-document-specific-split-styles(.)]">
              <xsl:if test="not(position() = 1) or not($frontmatter)">
                <xsl:variable name="document-number">
                <xsl:value-of select="fn:count-preceding-documents(generate-id(current-group()[./name() = 'w:p'][string-join(w:r//text(), '') != ''][1]))" />
              </xsl:variable>
                <!-- create a body variable to be analysed for each document -->
                <xsl:variable name="body" as="element(body)">
                  <body>
                    <xsl:apply-templates select="current-group()" mode="bodycopy" />
                  </body>
                </xsl:variable>

                <xsl:variable name="document-title" select="fn:generate-document-title($body)"/>

                <xsl:variable name="document-full-filename">
                  <xsl:choose>
                    <xsl:when test="config:generate-titles()">
                      <xsl:value-of select="replace($document-title,'\W','_')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="encode-for-uri(concat($filename,'-',format-number(number($document-number), $zeropadding)))"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                <xsl:variable name="level">
                  <xsl:choose>
                    <xsl:when test="config:document-level-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''">
                      <xsl:value-of select="config:document-level-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>0</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <blockxref title="{$document-title}" frag="default" display="document"
                           type="embed" reverselink="true" reversetitle="" reversetype="none"
                           href="{concat($component-folder-name,$document-full-filename,'.psml')}">
                  <!-- Not currently used: Levels push the heading level down ( so a Heading 1 at level 2, would be a Heading 3) -->
                  <xsl:if test="$level != '0'">
                    <xsl:attribute name="level" select="$level"/>
                  </xsl:if>

                  <document level="processed">
                    <xsl:if test="config:document-type-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''">
                      <xsl:attribute name="type" select="config:document-type-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)"/>
                    </xsl:if>
                    <documentinfo>
                      <uri title="{$document-title}">
                        <displaytitle>
                          <xsl:value-of select="$document-title" />
                        </displaytitle>
                        <xsl:if test="config:document-label-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val) != ''">
                          <labels><xsl:value-of select="config:document-label-for-split-style($body/w:p[1]/w:pPr/w:pStyle/@w:val)"/></labels>
                        </xsl:if>
                      </uri>

                    </documentinfo>
                    <xsl:apply-templates select="$body" mode="section-split">
                      <xsl:with-param name="document-title" select="$document-title" />
                      <xsl:with-param name="document-level" select="$level" tunnel="yes"/>
                    </xsl:apply-templates>
                  </document>

                </blockxref>
              </xsl:if>
            </xsl:for-each-group>
          </xsl:for-each-group>
        </xref-fragment>
      </section>
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