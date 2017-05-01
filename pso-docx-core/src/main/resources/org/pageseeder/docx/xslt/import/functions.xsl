<?xml version="1.0" encoding="UTF-8"?>

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
  xmlns:dcterms="http://purl.org/dc/terms/" xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
  xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
  xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" xmlns:fn="http://www.pageseeder.com/function">


<!-- 
Function to return the corresponding Abstract Number Id from word, from the input parameter, acording to it's style
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
<!--       <xsl:when test="$numbering-document//w:abstractNum[w:lvl/w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val]"> -->
<!--         <xsl:value-of select="$numbering-document//w:abstractNum[w:lvl/w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val]/@w:abstractNumId" /> -->
<!--       </xsl:when> -->
<!--       <xsl:when test="$styles-document//w:style[@w:styleId = $current/w:pPr/w:pStyle/@w:val]/w:pPr/w:numPr/w:numId/@w:val"> -->
<!--         <xsl:variable name="temp-abstract-num-id"> -->
<!--           <xsl:value-of select="$styles-document//w:style[@w:styleId = $current/w:pPr/w:pStyle/@w:val]/w:pPr/w:numPr/w:numId/@w:val" /> -->
<!--         </xsl:variable> -->
<!--         <xsl:message><xsl:value-of select="$current/w:pPr/w:pStyle/@w:val"/>::<xsl:value-of select="$temp-abstract-num-id"/></xsl:message> -->
<!--         <xsl:choose> -->
<!--           <xsl:when test="$numbering-document//w:abstractNum[@w:abstractNumId=$temp-abstract-num-id]/w:numStyleLink"> -->
<!--             <xsl:variable name="temp-style-link" select="$numbering-document//w:abstractNum[@w:abstractNumId=$temp-abstract-num-id]/w:numStyleLink/@w:val"/> -->
<!--             <xsl:value-of select="$numbering-document//w:abstractNum[w:styleLink/@w:val = $temp-style-link]/@w:abstractNumId"/> -->
<!--           </xsl:when> -->
<!--           <xsl:otherwise> -->
<!--             <xsl:value-of select="$temp-abstract-num-id"/> -->
<!--           </xsl:otherwise> -->
<!--         </xsl:choose> -->
<!--       </xsl:when> -->
      
<!--       <xsl:when test="$numbering-document//w:abstractNum[@w:abstractNumId = $numbering-document//w:num[@w:numId = $styles-document//w:style[@w:type='numbering']/w:pPr/w:numPr/w:numId/@w:val]/w:abstractNumId/@w:val][w:lvl/w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val]"> -->
      
      <!--  TODO -->
<!--         <xsl:value-of select="$numbering-document//w:num[@w:numId = $current/w:pPr/w:numPr/w:numId/@w:val]/w:abstractNumId/@w:val" /> -->
<!--       </xsl:when> -->
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
  <xsl:function name="fn:get-preceding-heading-level-from-element" as="xs:string?">
    <xsl:param name="current" as="element()" />

    <xsl:choose>
      <xsl:when test="$current/w:pPr/w:numPr/w:ilvl">
        <xsl:value-of select="'0'" />
      </xsl:when>
      <xsl:when test="$numbering-document//w:abstractNum/w:lvl[w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val]">
        <xsl:value-of
          select="count($numbering-document//w:abstractNum/w:lvl[w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val]/preceding-sibling::w:lvl[matches(w:pStyle/@w:val,$heading-paragraphs-list-string)])" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'0'" />
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
   <!--  <xsl:message><xsl:value-of select="$current/w:pPr/w:pStyle/@w:val" /></xsl:message> -->
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
<!-- 			<xsl:when test="$styles-document//w:style[@w:styleId = $current/w:pPr/w:pStyle/@w:val]/w:pPr/w:numPr/w:numId/@w:val"> -->
<!--         <xsl:variable name="temp-abstract-num-id"> -->
<!--           <xsl:value-of select="$styles-document//w:style[@w:styleId = $current/w:pPr/w:pStyle/@w:val]/w:pPr/w:numPr/w:numId/@w:val" /> -->
<!--         </xsl:variable> -->
<!--         <xsl:choose> -->
<!--           <xsl:when test="$numbering-document//w:abstractNum[@w:abstractNumId=$temp-abstract-num-id]/w:numStyleLink"> -->
<!--             <xsl:variable name="temp-style-link" select="$numbering-document//w:abstractNum[@w:abstractNumId=$temp-abstract-num-id]/w:numStyleLink/@w:val"/> -->
<!--             <xsl:value-of select="$numbering-document//w:abstractNum[w:styleLink/@w:val = $temp-style-link]/@w:abstractNumId"/> -->
<!--           </xsl:when> -->
<!--           <xsl:otherwise> -->
<!--             <xsl:value-of select="$temp-abstract-num-id"/> -->
<!--           </xsl:otherwise> -->
<!--         </xsl:choose> -->
<!--       </xsl:when> -->
      <xsl:otherwise>
<!-- 			 <xsl:message>###<xsl:value-of select="$numbering-document//w:abstractNum[w:lvl/w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val]/@w:abstractNumId"/></xsl:message> -->
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

  <!-- TODO -->
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
<!-- 		<xsl:message select="$current-node"></xsl:message> -->
<!-- 		<xsl:message select="$style"></xsl:message> -->

    <xsl:variable name="current-level" select="number((document($numbering)/w:numbering/w:abstractNum/w:lvl[w:pStyle[@w:val = $style]][1]/@w:ilvl)[1])" />

    <xsl:variable name="current-abstract-num-id" select="fn:get-abstract-num-id-from-element($current-node)" />

    <xsl:choose>
      <xsl:when test="$current-node/w:pPr/w:numPr/w:numId and document($numbering)/w:numbering/w:num[@w:numId = $current-node/w:pPr/w:numPr/w:numId/@w:val]/w:lvlOverride">
        <xsl:variable name="numbering-val" select="$current-node/w:pPr/w:numPr/w:numId/@w:val" />
        <xsl:variable name="offset" select="count($current-node/preceding::w:p[w:pPr/w:numPr/w:numId/@w:val = $numbering-val])" />
<!--         <xsl:message>A:<xsl:value-of select="document($numbering)//w:num[@w:numId = $current-node//w:pPr/w:numPr/w:numId/@w:val]/w:lvlOverride[@w:ilvl = string($current-level)]/w:startOverride/@w:val + $offset"/></xsl:message> -->
        <xsl:value-of select="document($numbering)/w:numbering/w:num[@w:numId = $current-node/w:pPr/w:numPr/w:numId/@w:val]/w:lvlOverride[@w:ilvl = string($current-level)]/w:startOverride/@w:val + $offset" />
      </xsl:when>
      <xsl:when
        test="$current-node/preceding::w:p[w:pPr[w:pStyle[@w:val=$style]]/w:numPr/w:numId][1][not(following::w:p)][fn:get-abstract-num-id-from-element(.) = $current-abstract-num-id][number(fn:get-level-from-element(.)) &lt; $current-level][@id = $current-node/preceding::w:p/@id]">
<!--         <xsl:message><xsl:value-of select="$current-node/preceding::w:p[w:pPr[w:pStyle/@w:val=$style][w:numPr/w:numId]][1]/w:pPr/w:numPr/w:numId/@w:val"/></xsl:message> -->
        <xsl:variable name="numbering-offset"
          select="document($numbering)/w:numbering/w:num[@w:numId = $current-node/preceding::w:p[w:pPr[w:pStyle/@w:val=$style][w:numPr/w:numId]][1]/w:pPr/w:numPr/w:numId/@w:val]/w:lvlOverride[@w:ilvl = string($current-level)]/w:startOverride/@w:val" />
<!--         <xsl:message>numbering-offset:<xsl:value-of select="document($numbering)//w:num[@w:numId = $current-node/preceding::w:p[w:pPr[w:pStyle/@w:val=$style][w:numPr/w:numId]][1]/w:pPr/w:numPr/w:numId/@w:val]/w:lvlOverride[@w:ilvl = string($current-level)]/w:startOverride/@w:val"/></xsl:message> -->
<!--         <xsl:message>B:<xsl:value-of select="count($current-node/preceding::w:p[w:pPr/w:pStyle/@w:val=$style][generate-id(.) = $current-node/preceding::w:p[w:pPr[w:pStyle[@w:val=$style]][w:numPr/w:numId]][1]/following-sibling::w:p[w:pPr/w:pStyle/@w:val=$style]/generate-id()]) + $numbering-offset + 1"/></xsl:message> -->
        <xsl:value-of
          select="count($current-node/preceding::w:p[w:pPr/w:pStyle/@w:val=$style][generate-id(.) = $current-node/preceding::w:p[w:pPr[w:pStyle[@w:val=$style]][w:numPr/w:numId]][1]/following-sibling::w:p[w:pPr/w:pStyle/@w:val=$style]/generate-id()]) + $numbering-offset + 1" />
      </xsl:when>
      <xsl:when test="$current-node/preceding::w:p[fn:get-abstract-num-id-from-element(.) = $current-abstract-num-id][number(fn:get-level-from-element(.)) &lt; $current-level][1]">
        <xsl:variable name="reference-node" select="$current-node/preceding::w:p[fn:get-abstract-num-id-from-element(.) = $current-abstract-num-id][number(fn:get-level-from-element(.)) &lt; $current-level][1]"
          as="element()" />
<!--         <xsl:message>reference-node:<xsl:value-of select="$reference-node/@id"/></xsl:message> -->
<!--         <xsl:message>C1:<xsl:value-of select="count($current-node/preceding::w:p[w:pPr/w:pStyle[@w:val=$style]][generate-id() = $reference-node/following-sibling::w:p[w:pPr/w:pStyle[@w:val=$style]]/generate-id()]) + 1"/></xsl:message> -->
<!--         <xsl:message>C2:<xsl:value-of select="count($current-node/preceding::w:p[w:pPr/w:pStyle[@w:val=$style]][@id = $current-node/preceding::w:p[fn:get-abstract-num-id-from-element(.) = $current-abstract-num-id][number(fn:get-level-from-element(.)) &lt; $current-level][1]/following-sibling::w:p[w:pPr/w:pStyle[@w:val=$style]]/@id]) + 1"/></xsl:message> -->
        <xsl:value-of
          select="count($current-node/preceding::w:p[w:pPr/w:pStyle[@w:val=$style]][@id = $current-node/preceding::w:p[fn:get-abstract-num-id-from-element(.) = $current-abstract-num-id][number(fn:get-level-from-element(.)) &lt; $current-level][1]/following-sibling::w:p[w:pPr/w:pStyle[@w:val=$style]]/@id]) + 1" />
      </xsl:when>
      <xsl:when test="$current-node[preceding-sibling::w:p/w:pPr[w:numPr/w:numId]/w:pStyle[@w:val=$style]]//w:pPr[w:numPr/w:numId]">
<!--        <xsl:message>D:<xsl:value-of select="count($current-node/preceding-sibling::w:p/w:pPr[w:numPr/w:numId/@w:val = $current-node//w:pPr/w:numPr/w:numId/@w:val]/w:pStyle[@w:val=$style]) + 1"/></xsl:message> -->
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
<!--        <xsl:message>E:<xsl:value-of select="count($offset-node/following-sibling::w:p[w:pPr/w:pStyle[@w:val=$style]][following::w:p[generate-id(.) = $current-node-id]]) + 1 + $offset-node-value"/></xsl:message> -->
        <xsl:value-of select="count($offset-node/following-sibling::w:p[w:pPr/w:pStyle[@w:val=$style]][following::w:p[generate-id(.) = $current-node-id]]) + 1 + $offset-node-value" />
      </xsl:when>
      <xsl:when test="document($numbering)/w:numbering/w:abstractNum/w:lvl/w:pStyle/@w:val = $style">
<!--         <xsl:message>F:<xsl:value-of select="count($current-node/preceding-sibling::w:p/w:pPr/w:pStyle[@w:val=$style]) + 1"/></xsl:message> -->
        <xsl:value-of select="count($current-node/preceding-sibling::w:p/w:pPr/w:pStyle[@w:val=$style]) + document($numbering)/w:numbering/w:abstractNum/w:lvl[w:pStyle/@w:val = $style]/w:start/@w:val" />
      </xsl:when>
      <xsl:otherwise>
<!--         <xsl:message>G:<xsl:value-of select="count($current-node/preceding-sibling::w:p/w:pPr/w:pStyle[@w:val=$style]) + 1"/></xsl:message> -->
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
<!-- 		<xsl:message select="$style"/> -->
    <xsl:variable name="abstract-num-id" select="fn:get-num-id-from-abstract-num-id($current-node/w:pPr/w:numPr/w:numId/@w:val)" />

    <xsl:variable name="current-level" select="number($numbering-document//*[w:pStyle[@w:val = $style]]/@w:ilvl) + 1" />
<!--     <xsl:variable name="current-level"> -->
<!--       <xsl:choose> -->
<!--         <xsl:when test="$current-node/w:pPr/w:numPr/w:ilvl/@w:val"> -->
<!--           <xsl:value-of select="number($current-node/w:pPr/w:numPr/w:ilvl/@w:val) + 1"/> -->
<!--         </xsl:when> -->
<!--         <xsl:otherwise>  -->
<!--           <xsl:value-of select="number($numbering-document//*[w:pStyle[@w:val = $style]]/@w:ilvl) + 1"/> -->
<!--         </xsl:otherwise> -->
<!--       </xsl:choose> -->
<!--     </xsl:variable> -->
    <xsl:variable name="current-list" as="element()">
      <xsl:choose>
<!--         <xsl:when test="$current-node/w:pPr/w:numPr/w:numId/@w:val"> -->
          
<!--           <xsl:copy-of select="$numbering-document//w:numbering/w:abstractNum[@w:abstractNumId = $abstract-num-id]" /> -->
<!--         </xsl:when> -->
        <xsl:when test="$numbering-document//w:numbering/w:abstractNum[w:lvl/w:pStyle[@w:val = $style]]">
<!--           <xsl:message select="$style"></xsl:message> -->
          <xsl:copy-of select="$numbering-document//w:numbering/w:abstractNum[w:lvl/w:pStyle[@w:val = $style]]" />
        </xsl:when>
        <xsl:otherwise>
          <w:abstractNum />
        </xsl:otherwise>
      </xsl:choose>

    </xsl:variable>
<!--     <xsl:message select="$current-node//@id"/> -->
    <xsl:variable name="current-list-node" select="$list-paragraphs/w:p[@id = $current-node//@id]" as="element()">
    </xsl:variable>

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

<!--     <xsl:message select="$parent-position"/> -->
    <xsl:variable name="current-position">
      <xsl:call-template name="get-numbering-value-from-node">
        <xsl:with-param name="current-node" select="$current-list-node" />
      </xsl:call-template>
    </xsl:variable>



<!--     <xsl:message select="$style"/> -->
    <xsl:variable name="format-style" select="$numbering-document//*[w:pStyle[not(ancestor::w:lvlOverride)][@w:val = $style][1]][1]/w:lvlText/@w:val[1]" />
    <xsl:analyze-string regex="([^%]*)%(\d)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)%?(\d?)([^%]*)" select="$format-style">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(1)" />
        <xsl:value-of
          select="fn:get-formated-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(2))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(2),$current-list),fn:get-format-value-from-level-value(regex-group(2),$current-list))" />
        <xsl:value-of select="regex-group(3)" />
        <xsl:if test="regex-group(4) != ''">
          <xsl:value-of
            select="fn:get-formated-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(4))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(4),$current-list),fn:get-format-value-from-level-value(regex-group(4),$current-list))" />
        </xsl:if>
        <xsl:if test="regex-group(5) != ''">
          <xsl:value-of select="regex-group(5)" />
        </xsl:if>
        <xsl:if test="regex-group(6) != ''">
          <xsl:value-of
            select="fn:get-formated-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(6))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(6),$current-list),fn:get-format-value-from-level-value(regex-group(6),$current-list))" />
        </xsl:if>
        <xsl:if test="regex-group(7) != ''">
          <xsl:value-of select="regex-group(7)" />
        </xsl:if>
        <xsl:if test="regex-group(8) != ''">
          <xsl:value-of
            select="fn:get-formated-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(8))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(8),$current-list),fn:get-format-value-from-level-value(regex-group(8),$current-list))" />
        </xsl:if>
        <xsl:if test="regex-group(9) != ''">
          <xsl:value-of select="regex-group(9)" />
        </xsl:if>
        <xsl:if test="regex-group(10) != ''">
          <xsl:value-of
            select="fn:get-formated-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(10))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(10),$current-list),fn:get-format-value-from-level-value(regex-group(10),$current-list))" />
        </xsl:if>
        <xsl:if test="regex-group(11) != ''">
          <xsl:value-of select="regex-group(11)" />
        </xsl:if>
        <xsl:if test="regex-group(12) != ''">
          <xsl:value-of
            select="fn:get-formated-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(12))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(12),$current-list),fn:get-format-value-from-level-value(regex-group(12),$current-list))" />
        </xsl:if>
        <xsl:if test="regex-group(13) != ''">
          <xsl:value-of select="regex-group(13)" />
        </xsl:if>
        <xsl:if test="regex-group(14) != ''">
          <xsl:value-of
            select="fn:get-formated-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(14))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(14),$current-list),fn:get-format-value-from-level-value(regex-group(14),$current-list))" />
        </xsl:if>
        <xsl:if test="regex-group(15) != ''">
          <xsl:value-of select="regex-group(15)" />
        </xsl:if>
        <xsl:if test="regex-group(16) != ''">
          <xsl:value-of
            select="fn:get-formated-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(16))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(16),$current-list),fn:get-format-value-from-level-value(regex-group(16),$current-list))" />
        </xsl:if>
        <xsl:if test="regex-group(17) != ''">
          <xsl:value-of select="regex-group(17)" />
        </xsl:if>
        <xsl:if test="regex-group(18) != ''">
          <xsl:value-of
            select="fn:get-formated-value-by-style(tokenize(string($parent-position), ',')[number(regex-group(18))],$current-position,$style,$current-node,fn:get-paragraph-value-from-level-value(regex-group(18),$current-list),fn:get-format-value-from-level-value(regex-group(18),$current-list))" />
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
  Returns the value of the numbering scheme depeding on format

  @param style current paragraph style
  @param current current node()
  @param paragraph current paragraph style
  @param format current lsit formating value
  @return the corresponding number with the correct format.
-->
  <xsl:function name="fn:get-formated-value-by-style" as="xs:string">
    <xsl:param name="parent-position" />
    <xsl:param name="current-position" />
    <xsl:param name="style" />
    <xsl:param name="current" as="node()" />
    <xsl:param name="paragraph" />
    <xsl:param name="format" />
    <xsl:variable name="current-positions" select="if (string($parent-position) != '') then $parent-position else $current-position" />
<!--     <xsl:message><xsl:value-of select="$style" />::<xsl:value-of select="$paragraph" />::<xsl:value-of select="$format" />::</xsl:message> -->
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
<!--         <xsl:message><xsl:value-of select="$style" />::<xsl:value-of select="$paragraph" />::<xsl:value-of select="$format" />::</xsl:message> -->
        <xsl:value-of select="$numbering-decimal[number($current-positions)]" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
    <!-- TODO -->
  <xsl:function name="fn:get-formated-footnote-endnote-value" as="xs:string">
    <xsl:param name="position" />
    <xsl:param name="type" />
<!--     <xsl:message select="($maindocument//w:sectPr[w:footnotePr]/w:footnotePr/w:numFmt/@w:val)[last()]"/> -->
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
<!--         <xsl:message><xsl:value-of select="$style" />::<xsl:value-of select="$paragraph" />::<xsl:value-of select="$format" />::</xsl:message> -->
        <xsl:value-of select="$numbering-decimal[number($position)]" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
<!--
  Returns the string after a given delimiter, from an input string

  @param string the input string
  @param delimiter the delimiter to check for
  @return the substring after the delimeter.
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
  @return the substring before the delimeter.
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
<!--     <xsl:message select="$string"/> -->
<!--     <xsl:message select="$reference"/> -->
    <xsl:analyze-string regex="^(.*)[{$reference}].*&#x022;(.+)&#x022;.*" select="$string">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(2)" />
      </xsl:matching-substring>
<!--       <xsl:non-matching-substring> -->
<!--         <xsl:value-of select="'Missing reference'" /> -->
<!--       </xsl:non-matching-substring> -->
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
<!--         <xsl:message><xsl:value-of select="regex-group(1)" />###<xsl:value-of select="regex-group(2)" />###<xsl:value-of select="regex-group(3)" /></xsl:message> -->
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
    <xsl:value-of select="string(number($string) div 15)" />
  </xsl:function>
  
   <!--
  Returns pageseeder numbering style from corresponding word list style

  @param string the input string
  @return the pageseeder numbering style.
-->
  <xsl:function name="fn:word-numbering-to-pageseeder-numbering" as="xs:string">
    <xsl:param name="string" />
    <xsl:choose>
      <xsl:when test="$string = 'lowerRoman'">
        <xsl:value-of select="'lowerroman'"/>
      </xsl:when>
      <xsl:when test="$string = 'upperRoman'">
        <xsl:value-of select="'upperroman'"/>
      </xsl:when>
      <xsl:when test="$string = 'decimal'">
        <xsl:value-of select="'arabic'"/>
      </xsl:when>
      <xsl:when test="$string = 'lowerLetter'">
        <xsl:value-of select="'loweralpha'"/>
      </xsl:when>
      <xsl:when test="$string = 'upperLetter'">
        <xsl:value-of select="'upperalpha'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'arabic'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
    <!-- TODO -->
  <xsl:function name="fn:return-pageseeder-numbering-style">
    <xsl:param name="abstract-id" />
    <xsl:param name="level" />
    <xsl:param name="style" />
    <xsl:choose>
      <xsl:when test="$numbering-document/w:numbering/w:abstractNum[@w:abstractNumId = $abstract-id]/w:lvl[@w:ilvl = $level]/w:numFmt/@w:val != 'decimal'">
        <xsl:attribute name="type" select="fn:word-numbering-to-pageseeder-numbering($numbering-document/w:numbering/w:abstractNum[@w:abstractNumId = $abstract-id]/w:lvl[@w:ilvl = $level]/w:numFmt/@w:val)"/>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
    
   
  </xsl:function>
   
<!--
  template to generate xml tree as text; used for debugging purposes

-->
  <xsl:template match="*[not(text()|*)]" mode="xml">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()" />
    <xsl:apply-templates select="@*" mode="xml" />
    <xsl:text>/&gt;</xsl:text>
  </xsl:template>
<!--
  template to generate xml tree as text; used for debugging purposes

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
    <xsl:element name="{name()}">
      <xsl:copy-of select="@*" />
      <xsl:apply-templates mode="bodycopy" />
    </xsl:element>
  </xsl:template>

 <!-- copy each w:p to the $body variable and include unique id as attribute -->
  <xsl:template match="w:p" mode="bodycopy">
    <xsl:element name="{name()}">
      <xsl:attribute name="id" select="generate-id()" />
      <xsl:copy-of select="@*" />
      <xsl:apply-templates mode="bodycopy" />
    </xsl:element>
  </xsl:template>

<!-- copy each w:bookmarkStart to the $body variable and include unique id as attribute -->
  <xsl:template match="w:bookmarkStart" mode="bodycopy">
    <xsl:element name="{name()}">
      <xsl:attribute name="id" select="generate-id()" />
      <xsl:copy-of select="@*" />
      <xsl:apply-templates mode="bodycopy" />
    </xsl:element>
  </xsl:template>

<!-- copy each element to the listparas resultdocument as default: used only as debug -->
  <xsl:template match="element()" mode="paracopy">
    <xsl:element name="{name()}">
      <xsl:copy-of select="@*" />
      <xsl:apply-templates mode="paracopy" />
    </xsl:element>
  </xsl:template>

<!-- copy each element to the listparas resultdocument as default: used only as debug -->
  <xsl:template match="w:p" mode="paracopy">
    <xsl:element name="w:p">
      <xsl:attribute name="id" select="generate-id()" />
      <xsl:copy-of select="@*" />
      <xsl:apply-templates mode="paracopy" />
    </xsl:element>
  </xsl:template>
  
    <!--
  Returns the generated document title based on position and title definitions

  @param body the current document node
  
  @return the current document title.
  -->
  <xsl:function name="fn:generate-document-title" as="xs:string">
    <xsl:param name="body" />
    
    <!-- Title prefix will depend on first paragraph and numbering values -->
    <xsl:variable name="title-prefix">
      <xsl:variable name="style-name" select="$body/w:p[1]/w:pPr/w:pStyle/@w:val" />
      <xsl:variable name="has-numbering-format" as="xs:boolean">
        <xsl:choose>
          <xsl:when test="matches($style-name,$numbering-paragraphs-list-string)">
            <xsl:variable name="current-num-id">
              <xsl:value-of select="fn:get-abstract-num-id-from-element($body/w:p[1])" />
            </xsl:variable>
            <xsl:variable name="current-level">
              <xsl:value-of select="fn:get-level-from-element($body/w:p[1])" />
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$numbering-document/w:numbering/w:abstractNum[@w:abstractNumId=$current-num-id]/w:lvl[@w:ilvl=$current-level]/w:numFmt/@w:val='bullet'">
                <xsl:value-of select="false()" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="true()" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="false()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$number-document-title and matches($style-name,$numbering-paragraphs-list-string)">
          <xsl:if test="$has-numbering-format">
            <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($body/w:p[1],$style-name)" />
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length(string-join($body/w:p[1]//w:t/text(),'')) &gt; (249 - string-length($title-prefix))">
        <xsl:value-of select="concat($title-prefix,'','',substring(string-join($body/w:p[1]//w:t/text(),''),1,(249 - string-length($title-prefix))))" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($title-prefix,'','',string-join($body/w:p[1]//w:t/text(),''))" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
    <!-- TODO -->
  <xsl:function name="fn:checksum" as="xs:integer">
        <xsl:param name="str" as="xs:string"/>
        <xsl:variable name="codepoints" select="string-to-codepoints($str)"/>
        <xsl:value-of select="fn:fletcher16($codepoints, count($codepoints), 1, 0, 0)"/>
    </xsl:function>

  <!-- TODO -->
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
                <xsl:variable name="newSum1" as="xs:integer"
                    select="($sum1 + $str[$index]) mod 255"/>
                <xsl:sequence select="fn:fletcher16($str, $len, $index + 1, $newSum1,
                        ($sum2 + $newSum1) mod 255)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>