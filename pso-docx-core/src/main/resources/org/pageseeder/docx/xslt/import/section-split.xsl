<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for splitting at section level.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!-- TODO Suspicious template match of `body` element (no longer in PSML or is it `w:body` ? -->

<!--
  Template to split each document as sections according to the definitions in the configuration file
 -->
<xsl:template match="body" mode="section-split">
  <xsl:param name="document-level" tunnel="yes" />
  <xsl:choose>
    <xsl:when test="config:split-by-sections()">
      <xsl:variable name="is-multi-valued-group" as="xs:boolean">
        <xsl:variable name="group-value">
          <groups>
            <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-section-split-sectionbreak(.) or w:bookmarkEnd[matches(@w:id,$bookmark-end-section-split-regex-ids-string)]]">
              <xsl:for-each-group select="current-group()"
                group-starting-with="w:p[fn:matches-section-split-outline(.) or fn:matches-section-split-styles(.) or config:matches-section-split-bookmarkstart(.)]|w:p[config:matches-section-specific-split-styles(.)]">
                <group value="{count(current-group())}"/>
              </xsl:for-each-group>
            </xsl:for-each-group>
          </groups>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="count($group-value/groups/group) &gt; 1">
            <xsl:value-of select="true()" />
          </xsl:when>
          <xsl:when test="$group-value/groups/group/@value &gt; 1">
            <xsl:value-of select="true()" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="false()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <section id="title">
        <fragment id="title">
          <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-section-split-sectionbreak(.) or w:bookmarkEnd[matches(@w:id,$bookmark-end-section-split-regex-ids-string)]]">
            <xsl:variable name="relative-position" select="position()" />
            <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-section-split-outline(.)
                                                                               or fn:matches-section-split-styles(.)
                                                                               or config:matches-section-split-bookmarkstart(.)]
                                                                             |w:p[config:matches-section-specific-split-styles(.)]">
              <xsl:choose>
                <xsl:when test="position()*$relative-position = 1">
                  <xsl:if test="config:fragment-type-for-split-style(current-group()//w:pPr[1]/w:pStyle/@w:val[1]) != ''">
                    <xsl:attribute name="type" select="config:fragment-type-for-split-style(current-group()//w:pPr[1]/w:pStyle/@w:val[1])" />
                  </xsl:if>
                  <xsl:apply-templates select="current-group()[position() = 1]" mode="content">
                    <xsl:with-param name="document-level" select="$document-level" tunnel="yes" />
                  </xsl:apply-templates>
                </xsl:when>
              </xsl:choose>
            </xsl:for-each-group>
          </xsl:for-each-group>
        </fragment>
      </section>
      <xsl:if test="$is-multi-valued-group">
        <section id="body">
          <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-section-split-sectionbreak(.) or w:bookmarkEnd[matches(@w:id,$bookmark-end-section-split-regex-ids-string)]]">
            <xsl:variable name="relative-position" select="position()" />
            <xsl:for-each-group select="current-group()"
              group-starting-with="w:p[fn:matches-section-split-outline(.) or fn:matches-section-split-styles(.) or config:matches-section-split-bookmarkstart(.)]|w:p[config:matches-section-specific-split-styles(.)]">
              <xsl:choose>
                <xsl:when test="position()*$relative-position != 1">
                  <fragment id="{concat($relative-position,'-',position())}">
                    <xsl:if test="config:fragment-type-for-split-style(current-group()//w:pPr[1]/w:pStyle/@w:val[1]) != ''">
                      <xsl:attribute name="type" select="config:fragment-type-for-split-style(current-group()//w:pPr[1]/w:pStyle/@w:val[1])" />
                    </xsl:if>
                    <xsl:apply-templates select="current-group()" mode="content">
                      <xsl:with-param name="document-level" select="$document-level" tunnel="yes" />
                    </xsl:apply-templates>
                  </fragment>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:if test="current-group()[position() = 2]">
                    <fragment id="{concat($relative-position,'-',position())}">
                      <xsl:if test="config:fragment-type-for-split-style(current-group()//w:pPr[1]/w:pStyle/@w:val[1]) != ''">
                        <xsl:attribute name="type" select="config:fragment-type-for-split-style(current-group()//w:pPr[1]/w:pStyle/@w:val[1])" />
                      </xsl:if>
                      <xsl:apply-templates select="current-group()[position() != 1]" mode="content">
                        <xsl:with-param name="document-level" select="$document-level" tunnel="yes" />
                      </xsl:apply-templates>
                    </fragment>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each-group>
          </xsl:for-each-group>
        </section>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <section id="title">
        <fragment id="title">
          <xsl:apply-templates select="*[1]" mode="content">
            <xsl:with-param name="document-level" select="$document-level" tunnel="yes" />
          </xsl:apply-templates>
        </fragment>
      </section>
      <section id="1">
        <fragment id="1">
          <xsl:apply-templates select="*[position() != 1]" mode="content">
            <xsl:with-param name="document-level" select="$document-level" tunnel="yes" />
          </xsl:apply-templates>
        </fragment>
      </section>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>