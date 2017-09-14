<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for list processing.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.pageseeder.com/function"
                exclude-result-prefixes="#all">

<!--
  Match w:p inside of a list;
  Creates a item for the current paragraph and checks if there are forther paragraphs to create list items or next level of lists
  create list item
-->
<xsl:template match="w:p[matches(w:pPr/w:pStyle/@w:val,$numbering-paragraphs-list-string) and not(w:pPr/w:numPr/w:numId/@w:val = '0') and fn:get-psml-element(w:pPr/w:pStyle/@w:val) = '']" mode="content">
  <xsl:variable name="style-name" select="w:pPr/w:pStyle/@w:val" />
  <xsl:variable name="has-numbering-format" select="fn:has-numbering-format($style-name,current())" as="xs:boolean"/>
  <xsl:variable name="current-num-id" select="fn:get-abstract-num-id-from-element(.)"/>
  <xsl:variable name="current-abstract-num-id">
    <xsl:value-of select="fn:get-abstract-num-id-from-element(.)"/>
  </xsl:variable>
  <xsl:variable name="current-level">
    <xsl:value-of select="fn:get-level-from-element(.)"/>
  </xsl:variable>

  <xsl:variable name="is-bullet" as="xs:boolean"
    select="if ($numbering-document/w:numbering/w:abstractNum[@w:abstractNumId=$current-abstract-num-id]/w:lvl[@w:ilvl=$current-level]/w:numFmt/@w:val='bullet') then true() else false()" />

  <xsl:choose>
    <xsl:when test="not($convert-to-numbered-paragraphs)">
      <xsl:choose>
        <!-- Numbered paragraph -->
        <xsl:when test="preceding::w:p[1][matches(w:pPr/w:pStyle/@w:val,$heading-paragraphs-list-string)]">
          <xsl:call-template name="list">
            <xsl:with-param name="abstract-id" select="$current-num-id" />
            <xsl:with-param name="level" select="$current-level" />
            <xsl:with-param name="id" select="@id" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when
          test="preceding::w:p[1][matches(w:pPr/w:pStyle/@w:val,$numbering-paragraphs-list-string)][not(matches(w:pPr/w:pStyle/@w:val,$heading-paragraphs-list-string))][fn:get-abstract-num-id-from-element(.) =$current-num-id][parent::* = current()/parent::*][not(matches(fn:get-psml-element-from-paragraph(.),'para'))]">
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="list">
            <xsl:with-param name="abstract-id" select="$current-num-id" />
            <xsl:with-param name="level" select="$current-level" />
            <xsl:with-param name="id" select="@id" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <para>
        <xsl:attribute name="indent" select="number($current-level) - number(fn:get-preceding-heading-level-from-element(.)) + 1" />
        <xsl:choose>
          <xsl:when test="not($is-bullet) and fn:get-numbered-paragraph-value($current-level + 1)='numbering'">
            <xsl:attribute name="numbered" select="'true'" />
          </xsl:when>
          <xsl:when test="not($is-bullet) and fn:get-numbered-paragraph-value($current-level + 1)='prefix' and $list-paragraphs/w:p[@id = current()/@id]">
            <xsl:if test="$has-numbering-format and fn:get-numbering-value-from-paragraph-style(.,$style-name) != ''">
              <xsl:attribute name="prefix" select="fn:get-numbering-value-from-paragraph-style(.,$style-name)" />
            </xsl:if>
          </xsl:when>
          <xsl:when test="matches(fn:get-numbered-paragraph-value($current-level + 1),'inline=[\w|-|_]+') and $list-paragraphs/w:p[@id = current()/@id]">
            <xsl:if test="$has-numbering-format and fn:get-numbering-value-from-paragraph-style(.,$style-name) != ''">
              <xsl:variable name="inline-label" select="substring-after(fn:get-numbered-paragraph-value($current-level + 1),'inline=')" />
              <inline label="{$inline-label}">
                <xsl:value-of select="fn:get-numbering-value-from-paragraph-style(.,$style-name)" />
                <xsl:text> </xsl:text>
              </inline>
            </xsl:if>
          </xsl:when>
          <xsl:when test="fn:get-numbered-paragraph-value($current-level + 1) = 'text'">
            <xsl:if test="$has-numbering-format">
              <xsl:value-of select="fn:get-numbering-value-from-paragraph-style(.,$style-name)" />
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
        <xsl:apply-templates select="./*" mode="content">
          <xsl:with-param name="full-text" select="fn:get-current-full-text(current())" />
        </xsl:apply-templates>
      </para>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<!-- template to handle list creation -->
<xsl:template match="w:p[w:pPr/w:numPr[w:ilvl][w:numId] and not(matches(w:pPr/w:pStyle/@w:val,$numbering-paragraphs-list-string)) and not(w:pPr/w:numPr/w:numId/@w:val = '0') and fn:get-psml-element(w:pPr/w:pStyle/@w:val) = '']" mode="content">
  <xsl:variable name="style-name" select="w:pPr/w:pStyle/@w:val" />
  <xsl:variable name="has-numbering-format" select="fn:has-numbering-format($style-name,current())" as="xs:boolean" />
  <xsl:variable name="listID" select="w:pPr/w:numPr/w:numId/@w:val" />
  <xsl:variable name="abstractNumId" select="fn:get-abstract-num-id-from-element(.)" />
  <xsl:variable name="current-level" select="fn:get-level-from-element(.)" />
  <xsl:variable name="is-bullet" as="xs:boolean"
    select="if ($numbering-document/w:numbering/w:abstractNum[@w:abstractNumId=$abstractNumId]/w:lvl[@w:ilvl=$current-level]/w:numFmt/@w:val='bullet') then true() else false()" />

  <xsl:choose>
    <xsl:when test="not($convert-to-numbered-paragraphs)">
      <xsl:choose>
        <xsl:when test="preceding-sibling::w:p[1][./w:pPr/w:numPr/w:numId/@w:val]" />
        <xsl:otherwise>
          <xsl:call-template name="list">
            <xsl:with-param name="abstract-id" select="$numbering-document/w:numbering/w:num[@w:numId=$listID]/w:abstractNumId/@w:val" />
            <xsl:with-param name="level" select="w:pPr/w:numPr/w:ilvl/@w:val" />
            <xsl:with-param name="id" select="@id" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <para>
        <xsl:attribute name="indent" select="number($current-level) - number(fn:get-preceding-heading-level-from-element(.)) + 1" />
        <xsl:choose>
          <xsl:when test="not($is-bullet) and fn:get-numbered-paragraph-value($current-level + 1)='numbering'">
            <xsl:attribute name="numbered" select="'true'" />
          </xsl:when>
          <xsl:when test="not($is-bullet) and fn:get-numbered-paragraph-value($current-level + 1)='prefix' and $list-paragraphs/w:p[@id = current()/@id]">
            <xsl:if test="$has-numbering-format and fn:get-numbering-value-from-paragraph-style(.,$style-name) != ''">
              <xsl:attribute name="prefix" select="fn:get-numbering-value-from-paragraph-style(.,$style-name)" />
            </xsl:if>
          </xsl:when>
          <xsl:when test="matches(fn:get-numbered-paragraph-value($current-level + 1),'inline=[\w|-|_]+') and $list-paragraphs/w:p[@id = current()/@id]">
            <xsl:if test="$has-numbering-format and fn:get-numbering-value-from-paragraph-style(.,$style-name) != ''">
              <xsl:variable name="inline-label" select="substring-after(fn:get-numbered-paragraph-value($current-level + 1),'inline=')" />
              <inline label="{$inline-label}">
                <xsl:value-of select="fn:get-numbering-value-from-paragraph-style(.,$style-name)" />
                <xsl:text> </xsl:text>
              </inline>
            </xsl:if>
          </xsl:when>
          <xsl:when test="fn:get-numbered-paragraph-value($current-level + 1) = 'text'">
            <xsl:if test="$has-numbering-format and fn:get-numbering-value-from-paragraph-style(.,$style-name) != ''">
              <xsl:value-of select="fn:get-numbering-value-from-paragraph-style(.,$style-name)" />
              <xsl:text> </xsl:text>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
        <xsl:apply-templates select="./*" mode="content">
          <xsl:with-param name="full-text" select="fn:get-current-full-text(current())" />
        </xsl:apply-templates>
      </para>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Template to handle a w:p inide of a list -->
<xsl:template match="w:p" mode="insidelist">
  <xsl:variable name="level" select="fn:get-level-from-element(.)" />
  <xsl:variable name="abstract-num-id" select="fn:get-abstract-num-id-from-element(.)" />

  <xsl:variable name="nested-list"
    select="following-sibling::w:p[1][fn:get-level-from-element(.) &gt; $level][fn:get-abstract-num-id-from-element(.) = $abstract-num-id][not(matches(fn:get-psml-element-from-paragraph(.),'para'))]" />
  <item>
    <xsl:apply-templates  mode="content"/>
    <xsl:for-each select="$nested-list">
      <xsl:call-template name="list">
        <xsl:with-param name="abstract-id" select="$abstract-num-id" />
        <xsl:with-param name="level" select="fn:get-level-from-element(.)" />
        <xsl:with-param name="id" select="@id" />
      </xsl:call-template>
    </xsl:for-each>
  </item>

  <xsl:choose>
    <xsl:when test="$nested-list">
        <!-- skip to next item at this level just after nested list -->
      <xsl:apply-templates
        select="following-sibling::w:p
            [fn:get-level-from-element(.)=$level][fn:get-abstract-num-id-from-element(.)=$abstract-num-id][1]
            [fn:get-level-from-element(preceding-sibling::w:p[1]) &gt; $level]"
        mode="insidelist">
      </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
      <!-- get next item if it is at the same level -->
      <xsl:apply-templates
        select="following-sibling::w:p[1]
            [fn:get-level-from-element(.)=$level][fn:get-abstract-num-id-from-element(.)=$abstract-num-id]"
        mode="insidelist">
      </xsl:apply-templates>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- 
  create list or nlist, based on the list type defined
  in numbering.xml

  @return `list` or `nlist`
-->
<xsl:template name="list">
  <xsl:param name="abstract-id" />
  <xsl:param name="level" />
  <xsl:param name="id"/>
  <xsl:variable name="style-name" select="w:pPr/w:pStyle/@w:val"/>
  <xsl:choose>
    <xsl:when test="$numbering-document/w:numbering/w:abstractNum[@w:abstractNumId=$abstract-id]/w:lvl[@w:ilvl=$level]/w:numFmt/@w:val='bullet'">
      <list>
        <xsl:if test="$convert-to-list-roles and $style-name != ''">
          <xsl:attribute name="role" select="$style-name"/>
        </xsl:if>
        <xsl:apply-templates select="." mode="insidelist" />
      </list>
    </xsl:when>
    <xsl:otherwise>
      <nlist>
        <xsl:if test="$convert-to-list-roles and $style-name != ''">
          <xsl:attribute name="role" select="$style-name"/>
        </xsl:if>

        <xsl:if test="fn:return-pageseeder-numbering-style($abstract-id, $level, $style-name)">
          <xsl:sequence select="fn:return-pageseeder-numbering-style($abstract-id, $level, $style-name)"/>
        </xsl:if>

        <xsl:variable name="start">
          <xsl:choose>
            <xsl:when test="preceding::w:p[fn:get-abstract-num-id-from-element(.) = $abstract-id][1][fn:get-level-from-element(.) &lt; $level]">
              <xsl:value-of select="'1'"/>
            </xsl:when>
            <xsl:when test="preceding-sibling::w:p[fn:get-abstract-num-id-from-element(.) = $abstract-id][fn:get-level-from-element(.)=$level]">
              <xsl:call-template name="get-numbering-value-from-node">
                <xsl:with-param name="current-node" select="$list-paragraphs//*[@id = $id]"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'1'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:if test="$start != ''">
          <xsl:attribute name="start" select="$start"/>
        </xsl:if>

      <!-- JB: removed because it's not valid according to standard.xsd
        <xsl:attribute name="liststyle">
          <xsl:value-of select="$numberingdoc/w:numbering/w:abstractNum[@w:abstractNumId=$abstract-id]/w:lvl[@w:ilvl=$level]/w:numFmt/@w:val"/>
        </xsl:attribute>
       -->
        <xsl:apply-templates select="." mode="insidelist" />
      </nlist>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- 
Initial template to create lists as numbered paragraphs
-->
<xsl:template name="createlist">
  <xsl:param name="current" as="element()?" />
  <xsl:param name="level" />
  <xsl:param name="numid" />
  <xsl:param name="paragraph-style" />

  <xsl:call-template name="create-item">
    <xsl:with-param name="current" select="$current" />
  </xsl:call-template>

</xsl:template>

<!-- 
  Template to create lists as numbered paragraphs
-->
<xsl:template name="create-item">
  <xsl:param name="current" as="node()?" />
  <xsl:variable name="current-num-id" select="fn:get-numid-from-style($current)" />
  <xsl:variable name="level" select="fn:get-level-from-element($current)" />
  <xsl:variable name="current-paragraph-style" select="$current/w:pPr/w:pStyle/@w:val" />
  <xsl:variable name="nested-list" select="$current/following-sibling::w:p[1][fn:get-level-from-element(.) &gt; $level][fn:get-numid-from-style(.) = $current-num-id][not(matches(fn:get-psml-element-from-paragraph(.),'para'))]" />

  <para>
    <xsl:attribute name="indent" select="$level" />
    <xsl:attribute name="prefix" select="fn:get-numbering-value-from-paragraph-style($current,$current-paragraph-style)" />
    <xsl:apply-templates select="$current/*"  mode="content"/>
  </para>
  <xsl:for-each select="$nested-list">
    <xsl:variable name="nlist-id" select="fn:get-numid-from-style(.)" />
    <xsl:variable name="nlist-level" select="fn:get-level-from-element(.)" />
    <xsl:variable name="nestedlist-paragraph-style" select="$nested-list/w:pPr/w:pStyle/@w:val" />
    <xsl:call-template name="nested-lists">
      <xsl:with-param name="current" select="$nested-list" />
      <xsl:with-param name="level" select="$nlist-level" />
      <xsl:with-param name="numid" select="$nlist-id" />
    </xsl:call-template>
  </xsl:for-each>

  <xsl:choose>
    <xsl:when test="$nested-list">
      <xsl:if
        test="$current/following-sibling::w:p
             [fn:get-level-from-element(.)=$level][fn:get-numid-from-style(.)=$current-num-id][1]
            [preceding-sibling::w:p[1][fn:get-level-from-element(.) &gt; $level]]">
        <xsl:call-template name="create-item">
          <xsl:with-param name="current"
            select="$current/following-sibling::w:p
            [fn:get-level-from-element(.)=$level][fn:get-numid-from-style(.)=$current-num-id][1]
            [preceding-sibling::w:p[1][fn:get-level-from-element(.) &gt; $level]]" />
        </xsl:call-template>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$current/following::w:p[1]
            [parent::* = $current/parent::*]
            [fn:get-level-from-element(.)=$level][fn:get-numid-from-style(.) = $current-num-id]">
          <xsl:call-template name="create-item">
            <xsl:with-param name="current"
              select="$current/following::w:p[1]
           [parent::* = $current/parent::*]
            [fn:get-level-from-element(.)=$level][fn:get-numid-from-style(.) = $current-num-id]" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- 
  Template to handle nested lists as numbered paragraphs
-->
<xsl:template name="nested-lists">
  <xsl:param name="current" as="node()" />
  <xsl:param name="level" />
  <xsl:param name="numid" />
  <xsl:call-template name="create-item">
    <xsl:with-param name="current" select="$current" />
  </xsl:call-template>
</xsl:template>

</xsl:stylesheet>