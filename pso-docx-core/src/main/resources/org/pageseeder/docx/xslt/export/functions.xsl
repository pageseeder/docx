<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module contains reusable global functions.

  These functions do not rely on the global state (i.e. there are pure functions)

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://pageseeder.org/docx/function"
                exclude-result-prefixes="#all">

<!-- TODO Consistency in parameter names -->
<!-- TODO Indicate return type -->

<!--
  Returns type of Word numbering style based on the current pageseeder list style.

  @param list-style the PSML list style

  @return the corresponding Word list style
-->
<xsl:function name="fn:return-word-numbering-style" as="xs:string">
  <xsl:param name="list-style" />
  <xsl:choose>
    <xsl:when test="$list-style = 'lowerroman'">lowerRoman</xsl:when>
    <xsl:when test="$list-style = 'upperroman'">upperRoman</xsl:when>
    <xsl:when test="$list-style = 'arabic'">decimal</xsl:when>
    <xsl:when test="$list-style = 'loweralpha'">lowerLetter</xsl:when>
    <xsl:when test="$list-style = 'upperalpha'">upperLetter</xsl:when>
    <xsl:otherwise>decimal</xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the current Word cell alignment from the PSML cell alignment

  @param cell-alignment the PSML cell alignment

  @return the corresponding Word cell alignment
-->
<xsl:function name="fn:return-word-cell-alignment" as="xs:string?">
  <xsl:param name="cell-alignment" />
  <xsl:choose>
    <xsl:when test="$cell-alignment = 'right'">right</xsl:when>
    <xsl:when test="$cell-alignment = 'justify'">both</xsl:when>
    <xsl:when test="$cell-alignment = 'center'">center</xsl:when>
    <xsl:otherwise/>
  </xsl:choose>
</xsl:function>

<!--
  Returns type of current element.

  @param name the elements name 

  @return the type of pageseeder element
-->
<xsl:function name="fn:element-type" as="xs:string">
  <xsl:param name="name" />
  <!-- TODO Use regex and simplify code -->
  <xsl:choose>
    <xsl:when test="$name='para' or $name='item' or $name='block' or $name='preformat' or $name='blockxref' or $name='heading' or $name='title'">
      <xsl:value-of select="'block'" />
    </xsl:when>
    <xsl:when test="$name='table'">
      <xsl:value-of select="'table'" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'inline'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns string with leading spaces trimmed.

  @param arg the string to be space stripped 

  @return string with leading spaces trimmed.
-->
<xsl:function name="fn:trim-leading-spaces" as="xs:string">
  <xsl:param name="arg" as="xs:string?"/>
  <xsl:sequence select="replace($arg,'^\s+','','m')"/>
</xsl:function>

<!--
  Returns string with trailing spaces trimmed.

  @param arg the string to be space stripped 

  @return string with trailing spaces trimmed.
-->
<xsl:function name="fn:trim-trailing-spaces" as="xs:string">
  <xsl:param name="arg" as="xs:string?"/>
  <xsl:sequence select="replace($arg,'\s+$','','m')"/>
</xsl:function>

<!--
  Returns the list of document label specific ignore inline labels.

  @param document-label the value of the document label

  @return the list of inline labels
-->
<xsl:function name="fn:items-to-regex" as="xs:string">
  <xsl:param name="items"/>
  <xsl:choose>
    <xsl:when test="$items">
      <xsl:value-of select="string-join(for $i in $items return concat('^', $i ,'$'), '|')"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- specify table width of a table -->
<xsl:function name="fn:table-set-width-value">
  <xsl:param name="node"/>
  <xsl:choose>
    <xsl:when test="$node/@width">
      <xsl:analyze-string regex="(\d+)(.*)" select="$node/@width">
        <xsl:matching-substring>
          <xsl:attribute name="w:w" select="if(regex-group(2) = '%') then number(regex-group(1)) * 50 else number(regex-group(1)) * 15"/>
          <xsl:attribute name="w:type" select="if(regex-group(2) = '%') then 'pct' else 'dxa'"/>
        </xsl:matching-substring>
        <xsl:non-matching-substring/>
      </xsl:analyze-string>
    </xsl:when>
    <xsl:otherwise>
      <xsl:attribute name="w:w" select="0"/>
      <xsl:attribute name="w:type" select="'auto'"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the word numeric value for pageseeder numeric value.

  @param regexp-value the value of the current regex value
  @return the pageseeder numeric value
-->
<xsl:function name="fn:get-numeric-type" as="xs:string?">
  <xsl:param name="regexp-value"/>
  <xsl:choose>
    <xsl:when test="$regexp-value = 'arabic'">
      <xsl:value-of select="'Arabic'"/>
    </xsl:when>
    <xsl:when test="$regexp-value = 'lowerletter'">
      <xsl:value-of select="'alphabetic'"/>
    </xsl:when>
    <xsl:when test="$regexp-value = 'upperletter'">
      <xsl:value-of select="'ALPHABETIC'"/>
    </xsl:when>
    <xsl:when test="$regexp-value = 'lowerroman'">
      <xsl:value-of select="'roman'"/>
    </xsl:when>
    <xsl:when test="$regexp-value = 'upperroman'">
      <xsl:value-of select="'ROMAN'"/>
    </xsl:when>
  </xsl:choose>
</xsl:function>

<!--
  Replaces each set numeric value with a real regular expression.

  @param regexp-value the value of the current regex value
  @return the real regular expression value
-->
<xsl:function name="fn:replace-regexp" as="xs:string?">
  <xsl:param name="regexp-value"/>
  <xsl:choose>
    <xsl:when test="matches($regexp-value, '%arabic%')">
      <xsl:value-of select="replace($regexp-value, '%arabic%', '(\\d+)')"/>
    </xsl:when>
    <xsl:when test="matches($regexp-value, '%lowerletter%')">
      <xsl:value-of select="replace($regexp-value, '%lowerletter%', '([a-z]+)')"/>
    </xsl:when>
    <xsl:when test="matches($regexp-value, 'upperletter')">
      <xsl:value-of select="replace($regexp-value, '%upperletter%', '([A-Z]+)')"/>
    </xsl:when>
    <xsl:when test="matches($regexp-value, 'upperroman')">
      <xsl:value-of select="replace($regexp-value, '%upperroman%', '([IVXCLDM]+)')"/>
    </xsl:when>
    <xsl:when test="matches($regexp-value, 'lowerroman')">
      <xsl:value-of select="replace($regexp-value, '%lowerroman%', '([ivxcldm]+)')"/>
    </xsl:when>
  </xsl:choose>
</xsl:function>

<!--
  Returns the numeric value of a regular expression variable

  @param prefix the prefix value
  @param user-regexp the user defined regular expression
  @param real-regexp the real valiue of the regular expression

  @return the numeric value
-->
<xsl:function name="fn:get-number-from-regexp">
  <xsl:param name="prefix" />
  <xsl:param name="user-regexp" />
  <xsl:param name="real-regexp" />
  <xsl:variable name="prefix-value">
    <xsl:analyze-string regex="({$real-regexp})" select="replace($prefix, '&#160;', ' ')">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="matches($user-regexp, 'arabic')">
      <xsl:value-of select="$prefix-value"/>
    </xsl:when>
    <xsl:when test="matches($user-regexp, 'upperletter|lowerletter')">
      <xsl:value-of select="fn:alpha-to-integer($prefix-value, 1)"/>
    </xsl:when>
    <xsl:when test="matches($user-regexp, 'lowerroman|upperroman')">
      <xsl:value-of select="fn:roman-to-integer($prefix-value, 1)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the default ps:list w:style

  @param list-level the current list level
  @param list-type list or nlist

  @return the w:style
-->
<xsl:function name="fn:default-list-wordstyle" as="xs:string">
  <xsl:param name="list-level"/>
  <xsl:param name="list-type"/>
  <xsl:value-of>
    <xsl:value-of select="'List '"/>
    <xsl:value-of select="if ($list-type = 'nlist') then 'Number' else 'Bullet'"/>
    <xsl:if test="$list-level gt 1">
      <xsl:value-of select="format-number($list-level, ' #')"/>
    </xsl:if>
  </xsl:value-of>
</xsl:function>

<!--
  Counts preceding top level lists containing @type

  @param current  the current node

  @return the count
-->
<xsl:function name="fn:count-preceding-lists-with-type" as="xs:integer">
  <xsl:param name="current" as="node()" />
  
  <xsl:value-of select="count($current/preceding::*[name() = 'list' or name() = 'nlist'][@type !='' or descendant::nlist/@type !='' or
      descendant::list/@type !=''][not(ancestor::*[name() = 'list' or name() = 'nlist'])])" />
</xsl:function>

<!--
  Counts ancestor lists of current and preceding lists of the ancestor list not containing @type

  @param current  the current node

  @return the count
-->
<xsl:function name="fn:count-ancestor-preceding-lists-without-type" as="xs:integer">
  <xsl:param name="current" as="node()" />
  
  <xsl:value-of select="count($current/ancestor::*[name() = 'list' or name() = 'nlist'][not(ancestor-or-self::*[name() = 'list' or
      name() = 'nlist'][last()]/descendant::*[name() = 'list' or name() = 'nlist']/@type)]) +
      count($current/ancestor::*[name() = 'list' or name() = 'nlist'][1]/preceding::*[name() = 'list' or
      name() = 'nlist'][not(ancestor-or-self::*[name() = 'list' or
      name() = 'nlist'][last()]/descendant::*[name() = 'list' or name() = 'nlist']/@type)])" />
</xsl:function>


<!--
  Returns the roman value of a numeric value

  @param roman-number the roman number to convert value
  @param index the current integer value

  @return the numeric value
-->
<xsl:function name="fn:roman-to-integer">
  <xsl:param name="roman-number" />
  <xsl:param name="index" />
  <xsl:variable name="temp">
    <xsl:value-of select="fn:to-roman($index)"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$temp = $roman-number">
      <xsl:value-of select="$index" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="fn:roman-to-integer($roman-number,$index + 1)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the roman value of a numeric value

  @param value the current integer value

  @return the roman value
-->
<xsl:function name="fn:to-roman">
  <xsl:param name="value"/>
  <xsl:number value="$value" format="I"/>
</xsl:function>

<!--
  Returns the alpha value of a numeric value

  @param alpha-number the alpha number to convert value
  @param index the current integer value

  @return the numeric value
-->
<xsl:function name="fn:alpha-to-integer" as="xs:string">
  <xsl:param name="alpha-number" />
  <xsl:param name="index" />
  <xsl:choose>
    <xsl:when test="fn:to-alpha($index) = $alpha-number">
      <xsl:value-of select="$index" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="fn:alpha-to-integer($alpha-number, $index + 1)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the alpha value of a numeric value

  @param value the current integer value

  @return the alpha value
-->
<xsl:function name="fn:to-alpha" as="xs:string">
  <xsl:param name="value"/>
  <xsl:number value="$value" format="A"/>
</xsl:function>

<!--
  Checks if the current element contains block elements or not
 -->
<xsl:function name="fn:has-block-elements" as="xs:boolean">
  <xsl:param name="element" />
  <xsl:sequence select="$element/block or $element/para or $element/heading or $element/code or $element/nlist or $element/table or $element/list or $element/blockxref"/>
</xsl:function>

<!-- 
  Checks if the current element is a block element or not
-->
<xsl:function name="fn:is-block-element">
  <xsl:param name="element" />
  <xsl:choose>
    <xsl:when test="$element[name()='heading' or contains(name(),'list') or name()='para' or name()='block' or name()='table' or name()='preformat' or name()='blockxref']">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the string after a given delimiter, from an input string

  @param string the input string
  @param delimiter the delimiter to check for
  @return the substring after the delimiter.
-->
<xsl:function name="fn:string-after-last-delimiter">
  <xsl:param name="string" />
  <xsl:param name="delimiter" />
  <xsl:analyze-string regex="^(.*)[{$delimiter}]([^{$delimiter}]+)" select="$string">
    <xsl:matching-substring>
      <xsl:value-of select="regex-group(2)" />
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:function>

<!--
  Returns the current date in format

  @return the current date in format.
-->
<xsl:function name="fn:get-current-date" as="xs:string">
  <!-- TODO Use date formatter!!! -->
  <xsl:value-of select="concat(year-from-dateTime(current-dateTime()),'-',format-number(number(month-from-dateTime(current-dateTime())), '00'),'-',format-number(number(day-from-dateTime(current-dateTime())), '00'),'T',format-number(number(hours-from-dateTime(current-dateTime())), '00'),':',format-number(number(minutes-from-dateTime(current-dateTime())), '00'),':00')"/>
</xsl:function>

<!--
  Returns the string before a given delimiter, from an input string

  @param string the input string
  @param delimiter the delimiter to check for
  @return the substring before the delimiter.
-->
<xsl:function name="fn:string-before-last-delimiter">
  <xsl:param name="string" />
  <xsl:param name="delimiter" />
  <xsl:analyze-string regex="^(.*)[{$delimiter}][^{$delimiter}]+"
    select="$string">
    <xsl:matching-substring>
      <xsl:value-of select="regex-group(1)" />
    </xsl:matching-substring>
  </xsl:analyze-string>
</xsl:function>

<!-- TODO Move these `mode="xml"` to appropriate file -->

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

</xsl:stylesheet>
