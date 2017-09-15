<?xml version="1.0" encoding="UTF-8"?>
<!--
  XSLT module providing generic (pure) utility functions.

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all">

<!--
  Returns the list of document label specific ignore inline labels.

  @param document-label the value of the document label

  @return the list of inline labels
-->
<xsl:function name="fn:items-to-regex" as="xs:string">
  <xsl:param name="items"/>
  <xsl:value-of select="if ($items and $items != '')
   then string-join(for $i in $items return concat('^', $i ,'$'), '|')
   else '^No Selected Value$'"/>
</xsl:function>

<!--
  Returns the list of document label specific ignore inline labels.

  @param document-label the value of the document label

  @return the list of inline labels
-->
<xsl:function name="fn:items-to-start-regex" as="xs:string">
  <xsl:param name="items"/>
  <xsl:value-of select="if ($items and $items != '')
 then string-join(for $i in $items return concat('^', $i), '|')
 else '^No Selected Value$'"/>
</xsl:function>

<!-- 
  Function to return the corresponding Abstract Number Id from word, from the input parameter, according to it's style
 -->
<xsl:function name="fn:get-abstract-num-id-from-element" as="xs:string?">
  <xsl:param name="current" as="node()" />
  <xsl:variable name="current-level" select="number(fn:get-level-from-element($current))" />
  <xsl:choose>
    <xsl:when test="$current/w:pPr/w:numPr/w:numId/@w:val">
      <xsl:variable name="temp-abstract-num-id">
        <xsl:value-of select="$numbering-document//w:num[@w:numId = $current/w:pPr/w:numPr/w:numId/@w:val]/w:abstractNumId/@w:val" />
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$numbering-document//w:abstractNum[@w:abstractNumId=$temp-abstract-num-id]/w:numStyleLink">
          <xsl:variable name="temp-style-link" select="$numbering-document//w:abstractNum[@w:abstractNumId=$temp-abstract-num-id]/w:numStyleLink/@w:val" />
          <xsl:value-of select="$numbering-document//w:abstractNum[w:styleLink/@w:val = $temp-style-link]/@w:abstractNumId" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$temp-abstract-num-id" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$numbering-document//w:abstractNum[w:lvl/w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val]/@w:abstractNumId" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the level of the numbered paragraph for pageseeder heading levels.

  @param current the node

  @return the corresponding level
-->
<xsl:function name="fn:get-current-full-text" as="xs:string?">
  <xsl:param name="current" as="node()" />
  <xsl:variable name="text">
    <xsl:for-each select="$current//(w:r|w:hyperlink)/*">
      <xsl:choose>
        <xsl:when test="current()/name() = 'w:br'">
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:when test="current()/name() = 'w:tab'">
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:when test="current()/name() = 'w:noBreakHyphen'">
          <xsl:text>-</xsl:text>
        </xsl:when>
        <xsl:when test="current()/name() = 'w:t'">
          <xsl:value-of select="." />
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:variable>
  <xsl:value-of select="string-join($text,'')"/>
</xsl:function>

<!--
  Returns the level of the numbered paragraph.

  @param current the node

  @return the corresponding level
-->
<xsl:function name="fn:get-level-from-element" as="xs:integer?">
  <xsl:param name="current" as="element()" />
  <xsl:choose>
    <xsl:when test="$current/w:pPr/w:numPr/w:ilvl">
      <xsl:value-of select="$current/w:pPr/w:numPr/w:ilvl/@w:val" />
    </xsl:when>
    <xsl:when test="$numbering-document/w:numbering/w:abstractNum/w:lvl[w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val]">
      <xsl:value-of select="($numbering-document/w:numbering/w:abstractNum/w:lvl[w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val][1]/@w:ilvl)[1]" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="-1" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the numId of the current paragraph.

  @param current the node

  @return the corresponding numId
-->
<xsl:function name="fn:get-numid-from-style" as="xs:string?">
  <xsl:param name="current" as="node()" />
  <xsl:variable name="current-level" select="number(fn:get-level-from-element($current))" />
  <xsl:variable name="current-id" select="$current/@id" />
  <xsl:choose>
    <xsl:when test="$current/w:pPr/w:numPr">
      <xsl:value-of select="$current/w:pPr/w:numPr/w:numId/@w:val" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="fn:get-num-id-from-abstract-num-id($numbering-document//w:abstractNum[w:lvl/w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val]/@w:abstractNumId)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the Abstract id of the current style.

  @param current the node

  @return the corresponding numId
-->
<xsl:function name="fn:get-abstractlist-from-style" as="xs:string?">
  <xsl:param name="current" as="node()" />
  <xsl:variable name="current-level" select="number(fn:get-level-from-element($current))" />
  <xsl:variable name="current-id" select="$current/@id" />
  <xsl:value-of select="fn:get-num-id-from-abstract-num-id($numbering-document//w:abstractNum[w:lvl/w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val]/@w:abstractNumId)" />
</xsl:function>

<!--
  Returns the numId from the value of the abstractNumId.

  @param abstractNumId the current abstractNumId

  @return the corresponding numId
-->
<xsl:function name="fn:get-num-id-from-abstract-num-id" as="xs:string?">
  <xsl:param name="abstract-num-id" />
  <xsl:value-of select="$numbering-document//w:num[w:abstractNumId/@w:val = $abstract-num-id][not(w:lvlOverride)][1]/@w:numId" />
</xsl:function>

<!--
  Returns the temp numId from the value of the abstractNumId.

  @param num-id the current abstractNumId

  @return the temp corresponding numId
-->
<xsl:function name="fn:get-abstract-num-id-from-num-id" as="xs:string?">
  <xsl:param name="num-id" />
  <xsl:variable name="temp-abstract-num-id">
    <xsl:value-of select="$numbering-document//w:num[@w:numId = $num-id][not(w:lvlOverride)][1]/w:abstractNumId/@w:val" />
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$numbering-document//w:abstractNum[@w:abstractNumId=$temp-abstract-num-id]/w:numStyleLink">
      <xsl:variable name="temp-style-link" select="$numbering-document//w:abstractNum[@w:abstractNumId=$temp-abstract-num-id]/w:numStyleLink/@w:val" />
      <xsl:value-of select="$numbering-document//w:abstractNum[w:styleLink/@w:val = $temp-style-link]/@w:abstractNumId" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$temp-abstract-num-id" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the number counter from the current node. It checks:
  1. If the current paragraph has a numbering Id and a level override. If so it sets the value as the level override;
  2. If there is a preceding paragraph at the same level, with the same 'parent' upper level, that has a numbering Id. Count the position relative to that element and set the numbering value from there;
  3. If there is a preceding paragraph from the same list of a lower level. Count the elements from that element;
  4. Else, if none of the previous conditions apply, count the preceding total number of elements that are the same level from the same list;

  @param current-node the current Node

  @return the current position in the list
-->
<xsl:template name="get-numbering-value-from-node" as="xs:string">
  <xsl:param name="current-node" as="node()" />
  <xsl:variable name="style" select="$current-node/w:pPr/w:pStyle/@w:val" />
  <xsl:variable name="current-num-id" select="fn:get-numid-from-style($current-node)" />
  <xsl:variable name="current-level" select="number((document($numbering)/w:numbering/w:abstractNum/w:lvl[w:pStyle[@w:val = $style]][1]/@w:ilvl)[1])" />
  <xsl:variable name="current-abstract-num-id" select="fn:get-abstract-num-id-from-element($current-node)" />

  <xsl:choose>
    <xsl:when test="$current-node/w:pPr/w:numPr/w:numId and document($numbering)/w:numbering/w:num[@w:numId = $current-node/w:pPr/w:numPr/w:numId/@w:val]/w:lvlOverride">
      <xsl:variable name="numbering-val" select="$current-node/w:pPr/w:numPr/w:numId/@w:val" />
      <xsl:variable name="offset" select="count($current-node/preceding::w:p[w:pPr/w:numPr/w:numId/@w:val = $numbering-val])" />
      <xsl:value-of select="document($numbering)/w:numbering/w:num[@w:numId = $current-node/w:pPr/w:numPr/w:numId/@w:val]/w:lvlOverride[@w:ilvl = string($current-level)]/w:startOverride/@w:val + $offset" />
    </xsl:when>
    <xsl:when
      test="$current-node/preceding::w:p[w:pPr[w:pStyle[@w:val=$style]]/w:numPr/w:numId][1][not(following::w:p)][fn:get-abstract-num-id-from-element(.) = $current-abstract-num-id][number(fn:get-level-from-element(.)) &lt; $current-level][@id = $current-node/preceding::w:p/@id]">
      <xsl:variable name="numbering-offset"
        select="document($numbering)/w:numbering/w:num[@w:numId = $current-node/preceding::w:p[w:pPr[w:pStyle/@w:val=$style][w:numPr/w:numId]][1]/w:pPr/w:numPr/w:numId/@w:val]/w:lvlOverride[@w:ilvl = string($current-level)]/w:startOverride/@w:val" />
      <xsl:value-of
        select="count($current-node/preceding::w:p[w:pPr/w:pStyle/@w:val=$style][generate-id(.) = $current-node/preceding::w:p[w:pPr[w:pStyle[@w:val=$style]][w:numPr/w:numId]][1]/following-sibling::w:p[w:pPr/w:pStyle/@w:val=$style]/generate-id()]) + $numbering-offset + 1" />
    </xsl:when>
    <xsl:when test="$current-node/preceding::w:p[fn:get-abstract-num-id-from-element(.) = $current-abstract-num-id][number(fn:get-level-from-element(.)) &lt; $current-level][1]">
      <xsl:value-of
        select="count($current-node/preceding::w:p[w:pPr/w:pStyle[@w:val=$style]][@id = $current-node/preceding::w:p[fn:get-abstract-num-id-from-element(.) = $current-abstract-num-id][number(fn:get-level-from-element(.)) &lt; $current-level][1]/following-sibling::w:p[w:pPr/w:pStyle[@w:val=$style]]/@id]) + 1" />
    </xsl:when>
    <xsl:when test="$current-node[preceding-sibling::w:p/w:pPr[w:numPr/w:numId]/w:pStyle[@w:val=$style]]//w:pPr[w:numPr/w:numId]">
      <xsl:value-of select="count($current-node/preceding-sibling::w:p/w:pPr[w:numPr/w:numId/@w:val = $current-node//w:pPr/w:numPr/w:numId/@w:val]/w:pStyle[@w:val=$style]) + 1" />
    </xsl:when>
    <xsl:when test="$current-node//preceding::w:p[w:pPr/w:pStyle[@w:val=$style]][w:pPr/w:numPr/w:numId]">
      <xsl:variable name="offset-node" select="$current-node//preceding::w:p[w:pPr/w:pStyle[@w:val=$style]][w:pPr/w:numPr/w:numId][1]" />
      <xsl:variable name="offset-node-value">
        <xsl:call-template name="get-numbering-value-from-node">
          <xsl:with-param name="current-node" select="$offset-node" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="current-node-id" select="generate-id($current-node)" />
      <xsl:value-of select="count($offset-node/following-sibling::w:p[w:pPr/w:pStyle[@w:val=$style]][following::w:p[generate-id(.) = $current-node-id]]) + 1 + $offset-node-value" />
    </xsl:when>
    <xsl:when test="document($numbering)/w:numbering/w:abstractNum/w:lvl/w:pStyle/@w:val = $style">
      <xsl:value-of select="count($current-node/preceding-sibling::w:p/w:pPr/w:pStyle[@w:val=$style]) + document($numbering)/w:numbering/w:abstractNum/w:lvl[w:pStyle/@w:val = $style]/w:start/@w:val" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="count($current-node/preceding-sibling::w:p/w:pPr/w:pStyle[@w:val=$style]) + 1" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Returns the word format of the current style

  @param current-node current node of the file
  @param style current node paragraph style
  @return the formatted value of the current style.
-->
<xsl:function name="fn:get-numbering-value-from-paragraph-style">
  <xsl:param name="current-node" as="node()" />
  <xsl:param name="style" />
  <xsl:variable name="abstract-num-id" select="fn:get-num-id-from-abstract-num-id($current-node/w:pPr/w:numPr/w:numId/@w:val)" />
  <xsl:variable name="current-level" select="number($numbering-document//*[w:pStyle[@w:val = $style]]/@w:ilvl) + 1" />
  <xsl:variable name="current-list" as="element()">
    <xsl:choose>
      <xsl:when test="$numbering-document//w:numbering/w:abstractNum[w:lvl/w:pStyle[@w:val = $style]]">
        <xsl:copy-of select="$numbering-document//w:numbering/w:abstractNum[w:lvl/w:pStyle[@w:val = $style]]" />
      </xsl:when>
      <xsl:otherwise>
        <w:abstractNum />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="current-list-node" select="$list-paragraphs/w:p[@id = $current-node//@id]" as="element()"/>

  <xsl:variable name="parent-position">
    <xsl:for-each select="$numbering-document//*[w:pStyle[@w:val = $style]]/preceding-sibling::w:lvl">
      <xsl:sort select="position()" data-type="number" order="ascending" />
      <xsl:variable name="parent-style" select="w:pStyle/@w:val" />
      <xsl:variable name="parent-level" select="@w:ilvl" />

      <xsl:choose>
        <xsl:when test="$current-list-node/preceding::w:p[w:pPr/w:pStyle[@w:val=$parent-style]]">
          <xsl:variable name="current-parent-node" select="$current-list-node/preceding::w:p[w:pPr/w:pStyle[@w:val=$parent-style]][1]" as="node()" />

          <xsl:call-template name="get-numbering-value-from-node">
            <xsl:with-param name="current-node" select="$current-parent-node" />
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="','" />
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="current-position">
    <xsl:call-template name="get-numbering-value-from-node">
      <xsl:with-param name="current-node" select="$current-list-node" />
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="format-style" select="$numbering-document//*[w:pStyle[not(ancestor::w:lvlOverride)][@w:val = $style][1]][1]/w:lvlText/@w:val[1]" />
  <xsl:analyze-string regex="([^%]*)%(\d)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)" select="$format-style">
    <xsl:matching-substring>
      <xsl:value-of select="regex-group(1)" />
      <xsl:value-of
        select="fn:get-formatted-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(2))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(2),$current-list),fn:get-format-value-from-level-value(regex-group(2),$current-list))" />
      <xsl:value-of select="regex-group(3)" />
      <xsl:if test="regex-group(4) != ''">
        <xsl:value-of
          select="fn:get-formatted-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(4))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(4),$current-list),fn:get-format-value-from-level-value(regex-group(4),$current-list))" />
      </xsl:if>
      <xsl:if test="regex-group(5) != ''">
        <xsl:value-of select="regex-group(5)" />
      </xsl:if>
      <xsl:if test="regex-group(6) != ''">
        <xsl:value-of
          select="fn:get-formatted-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(6))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(6),$current-list),fn:get-format-value-from-level-value(regex-group(6),$current-list))" />
      </xsl:if>
      <xsl:if test="regex-group(7) != ''">
        <xsl:value-of select="regex-group(7)" />
      </xsl:if>
      <xsl:if test="regex-group(8) != ''">
        <xsl:value-of
          select="fn:get-formatted-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(8))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(8),$current-list),fn:get-format-value-from-level-value(regex-group(8),$current-list))" />
      </xsl:if>
      <xsl:if test="regex-group(9) != ''">
        <xsl:value-of select="regex-group(9)" />
      </xsl:if>
      <xsl:if test="regex-group(10) != ''">
        <xsl:value-of
          select="fn:get-formatted-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(10))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(10),$current-list),fn:get-format-value-from-level-value(regex-group(10),$current-list))" />
      </xsl:if>
      <xsl:if test="regex-group(11) != ''">
        <xsl:value-of select="regex-group(11)" />
      </xsl:if>
      <xsl:if test="regex-group(12) != ''">
        <xsl:value-of
          select="fn:get-formatted-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(12))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(12),$current-list),fn:get-format-value-from-level-value(regex-group(12),$current-list))" />
      </xsl:if>
      <xsl:if test="regex-group(13) != ''">
        <xsl:value-of select="regex-group(13)" />
      </xsl:if>
      <xsl:if test="regex-group(14) != ''">
        <xsl:value-of
          select="fn:get-formatted-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(14))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(14),$current-list),fn:get-format-value-from-level-value(regex-group(14),$current-list))" />
      </xsl:if>
      <xsl:if test="regex-group(15) != ''">
        <xsl:value-of select="regex-group(15)" />
      </xsl:if>
      <xsl:if test="regex-group(16) != ''">
        <xsl:value-of
          select="fn:get-formatted-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(16))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(16),$current-list),fn:get-format-value-from-level-value(regex-group(16),$current-list))" />
      </xsl:if>
      <xsl:if test="regex-group(17) != ''">
        <xsl:value-of select="regex-group(17)" />
      </xsl:if>
      <xsl:if test="regex-group(18) != ''">
        <xsl:value-of
          select="fn:get-formatted-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(18))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(18),$current-list),fn:get-format-value-from-level-value(regex-group(18),$current-list))" />
      </xsl:if>
      <xsl:if test="regex-group(19) != ''">
        <xsl:value-of select="regex-group(19)" />
      </xsl:if>
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:function>

<!--
  Returns the paragraph style from the current level

  @param level current list level
  @param list current list
  @return the corresponding paragraph style.
-->
<xsl:function name="fn:get-paragraph-value-from-level-value" as="xs:string">
  <xsl:param name="level" />
  <xsl:param name="list" as="element()" />
  <xsl:variable name="current-level" select="number($level) - 1" />
  <xsl:value-of select="$list/w:lvl[@w:ilvl = $current-level]/w:pStyle/@w:val" />
</xsl:function>

<!--
  Returns the numFmt value of the list ( bullet, alpha or number)

  @param level current list level
  @param list current list
  @return the corresponding number format value.
-->
<xsl:function name="fn:get-format-value-from-level-value" as="xs:string">
  <xsl:param name="level" />
  <xsl:param name="list" as="element()" />
  <xsl:variable name="current-level" select="number($level) - 1" />
  <xsl:value-of select="$list/w:lvl[@w:ilvl = $current-level]/w:numFmt/@w:val" />
</xsl:function>

<!--
  Returns the value of the numbering scheme depending on format

  @param style current paragraph style
  @param current current node()
  @param paragraph current paragraph style
  @param format current list formatting value
  @return the corresponding number with the correct format.
-->
<xsl:function name="fn:get-formatted-value-by-style" as="xs:string">
  <xsl:param name="parent-position" />
  <xsl:param name="current-position" />
  <xsl:param name="style" />
  <xsl:param name="current" as="node()" />
  <xsl:param name="paragraph" />
  <xsl:param name="format" />
  <xsl:variable name="current-positions" select="if (string($parent-position) != '') then $parent-position else $current-position" />
  <xsl:choose>
    <xsl:when test="$format = 'decimal'">
      <xsl:value-of select="$numbering-decimal[number($current-positions)]" />
    </xsl:when>
    <xsl:when test="$format = 'upperLetter'">
      <xsl:value-of select="upper-case($numbering-alpha[number($current-positions)])" />
    </xsl:when>
    <xsl:when test="$format = 'lowerLetter'">
      <xsl:value-of select="$numbering-alpha[number($current-positions)]" />
    </xsl:when>
    <xsl:when test="$format = 'upperRoman'">
      <xsl:value-of select="upper-case($numbering-roman[number($current-positions)])" />
    </xsl:when>
    <xsl:when test="$format = 'lowerRoman'">
      <xsl:value-of select="$numbering-roman[number($current-positions)]" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$numbering-decimal[number($current-positions)]" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the number formatted value for footnotes and endnotes numbering
-->
<xsl:function name="fn:get-formated-footnote-endnote-value" as="xs:string">
  <xsl:param name="position" />
  <xsl:param name="type" />
  <xsl:variable name="format">
    <xsl:choose>
      <xsl:when test="$type='footnote'">
        <xsl:value-of select="$footnote-format"/>
      </xsl:when>
      <xsl:when test="$type='endnote'">
        <xsl:value-of select="$endnote-format"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'none'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$format = 'decimal'">
      <xsl:value-of select="$numbering-decimal[number($position)]" />
    </xsl:when>
    <xsl:when test="$format = 'upperLetter'">
      <xsl:value-of select="upper-case($numbering-alpha[number($position)])" />
    </xsl:when>
    <xsl:when test="$format = 'lowerLetter'">
      <xsl:value-of select="$numbering-alpha[number($position)]" />
    </xsl:when>
    <xsl:when test="$format = 'upperRoman'">
      <xsl:value-of select="upper-case($numbering-roman[number($position)])" />
    </xsl:when>
    <xsl:when test="$format = 'lowerRoman'">
      <xsl:value-of select="$numbering-roman[number($position)]" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$numbering-decimal[number($position)]" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>
  
<!--
  Returns the string after a given delimiter, from an input string

  @param string the input string
  @param delimiter the delimiter to check for
  @return the substring after the delimiter.
-->
<xsl:function name="fn:string-after-last-delimiter" as="xs:string">
  <xsl:param name="string" />
  <xsl:param name="delimiter" />
  <xsl:analyze-string regex="^(.*)[{$delimiter}]([^{$delimiter}]+)" select="$string">
    <xsl:matching-substring>
      <xsl:value-of select="regex-group(2)" />
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:function>

<!--
  Returns the string before a given delimiter, from an input string

  @param string the input string
  @param delimiter the delimiter to check for
  @return the substring before the delimiter.
-->
<xsl:function name="fn:string-before-last-delimiter" as="xs:string">
  <xsl:param name="string" />
  <xsl:param name="delimiter" />
  <xsl:analyze-string regex="^(.*)[{$delimiter}][^{$delimiter}]+" select="$string">
    <xsl:matching-substring>
      <xsl:value-of select="regex-group(1)" />
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:function>

<!--
  Returns the reference string from a word bookmark

  @param string the input string
  @param reference the reference from word
  @return the bookmark reference.
-->
<xsl:function name="fn:get-bookmark-value" as="xs:string">
  <xsl:param name="string" />
  <xsl:param name="reference" />
  <xsl:analyze-string regex="^(.*)[{$reference}]\s+([\w_\.]+).*" select="$string">
    <xsl:matching-substring>
      <xsl:value-of select="regex-group(2)" />
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:function>

<!--
  Returns the reference string from a word hyperlink

  @param string the input string
  @param reference the reference from word
  @return the hyperlink reference.
-->
<xsl:function name="fn:get-bookmark-value-hyperlink" as="xs:string">
  <xsl:param name="string" />
  <xsl:param name="reference" />
  <xsl:analyze-string regex="^(.*)[{$reference}].*&#x022;(.+)&#x022;.*" select="$string">
    <xsl:matching-substring>
      <xsl:value-of select="regex-group(2)" />
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:function>

<!--
  Returns the reference string from a word hyperlink

  @param string the input string
  @param reference the reference from word
  @return the hyperlink reference.
-->
<xsl:function name="fn:get-index-text" as="xs:string">
  <xsl:param name="string" />
  <xsl:param name="reference" />
  <xsl:analyze-string regex="^.*?[{$reference}].*?&#x022;([^&#x022;]*?)&#x022;.*" select="$string">
    <xsl:matching-substring>
      <xsl:value-of select="regex-group(1)" />
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:function>

<!--
  Returns converted value of a twentieth point to a pixel

  @param string the input string
  @return the pixel value.
-->
<xsl:function name="fn:twentiethpoint-to-pixel" as="xs:string">
  <xsl:param name="string" />
  <xsl:value-of select="string(number($string) div 15)"/>
</xsl:function>

<!--
  Returns pageseeder numbering style from corresponding word list style

  @param string the input string
  @return the pageseeder numbering style.
-->
<xsl:function name="fn:word-numbering-to-pageseeder-numbering" as="xs:string">
  <xsl:param name="string" />
  <xsl:choose>
    <xsl:when test="$string = 'lowerRoman'">lowerroman</xsl:when>
    <xsl:when test="$string = 'upperRoman'">upperroman</xsl:when>
    <xsl:when test="$string = 'decimal'">arabic</xsl:when>
    <xsl:when test="$string = 'lowerLetter'">loweralpha</xsl:when>
    <xsl:when test="$string = 'upperLetter'">upperalpha</xsl:when>
    <xsl:otherwise>arabic</xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- Returns the numbering format for the current numbered item -->
<xsl:function name="fn:return-pageseeder-numbering-style" as="attribute(type)?">
  <xsl:param name="abstract-id" />
  <xsl:param name="level" />
  <xsl:param name="style" />
  <xsl:if test="$numbering-document/w:numbering/w:abstractNum[@w:abstractNumId = $abstract-id]/w:lvl[@w:ilvl = $level]/w:numFmt/@w:val != 'decimal'">
    <xsl:attribute name="type" select="fn:word-numbering-to-pageseeder-numbering($numbering-document/w:numbering/w:abstractNum[@w:abstractNumId = $abstract-id]/w:lvl[@w:ilvl = $level]/w:numFmt/@w:val)"/>
  </xsl:if>
</xsl:function>

<!--
  Template to generate xml tree as text; used for debugging purposes
-->
<xsl:template match="*[not(text()|*)]" mode="xml">
  <xsl:text>&lt;</xsl:text>
  <xsl:value-of select="name()" />
  <xsl:apply-templates select="@*" mode="xml" />
  <xsl:text>/&gt;</xsl:text>
</xsl:template>

<!--
  Template to generate xml tree as text; used for debugging purposes
-->
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

<!--
  template to generate xml tree as text; used for debugging purposes
-->
<xsl:template match="text()" mode="xml">
  <xsl:value-of select="." />
</xsl:template>

<!--
  template to generate xml tree as text; used for debugging purposes
-->
<xsl:template match="@*" mode="xml">
  <xsl:value-of select="concat(' ',name(),'=&quot;',.,'&quot;')" />
</xsl:template>

<!-- copy each element to the $body variable as default -->
<xsl:template match="element()" mode="bodycopy">
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="bodycopy" />
  </xsl:copy>
</xsl:template>

<!-- copy each w:p to the $body variable and include unique id as attribute -->
<xsl:template match="w:p" mode="bodycopy">
  <xsl:copy>
    <xsl:attribute name="id" select="generate-id()" />
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="bodycopy" />
  </xsl:copy>
</xsl:template>

<!-- copy each w:bookmarkStart to the $body variable and include unique id as attribute -->
<xsl:template match="w:bookmarkStart" mode="bodycopy">
  <xsl:copy>
    <xsl:attribute name="id" select="generate-id()" />
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="bodycopy" />
  </xsl:copy>
</xsl:template>

<!-- copy each element to the listparas result document as default: used only as debug -->
<xsl:template match="element()" mode="paracopy">
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="paracopy" />
  </xsl:copy>
</xsl:template>

<!-- copy each element to the listparas resultdocument as default: used only as debug -->
<xsl:template match="w:p" mode="paracopy">
  <xsl:copy>
    <xsl:attribute name="id" select="generate-id()" />
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="paracopy" />
  </xsl:copy>
</xsl:template>

<!-- Checksum function to generate a unique value -->
<xsl:function name="fn:checksum" as="xs:integer">
  <xsl:param name="str" as="xs:string"/>
  <xsl:variable name="codepoints" select="string-to-codepoints($str)"/>
  <xsl:value-of select="fn:fletcher16($codepoints, count($codepoints), 1, 0, 0)"/>
</xsl:function>

<!-- Function that uses fletcher16 to generate value -->
<xsl:function name="fn:fletcher16">
  <xsl:param name="str" as="xs:integer*"/>
  <xsl:param name="len" as="xs:integer" />
  <xsl:param name="index" as="xs:integer" />
  <xsl:param name="sum1" as="xs:integer" />
  <xsl:param name="sum2" as="xs:integer"/>
  <xsl:choose>
    <xsl:when test="$index gt $len">
      <xsl:sequence select="$sum2 * 256 + $sum1"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="newSum1" as="xs:integer" select="($sum1 + $str[$index]) mod 255"/>
      <xsl:sequence select="fn:fletcher16($str, $len, $index + 1, $newSum1, ($sum2 + $newSum1) mod 255)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>
