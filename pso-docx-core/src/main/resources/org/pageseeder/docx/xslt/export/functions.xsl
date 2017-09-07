<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module contains reusable global functions.

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
								xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
								xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
								xmlns:fn="http://www.pageseeder.com/function"
								exclude-result-prefixes="#all">

<!-- TODO Consistency in parameter names -->
<!-- TODO Indicate return type -->

<!--
  Returns type of Word numbering style based on the current pageseeder list style.

  @param string the PSML list style

  @return the corresponding Word list style
-->
<xsl:function name="fn:return-word-numbering-style" as="xs:string">
	<xsl:param name="style" />
	<xsl:choose>
		<xsl:when test="$style = 'lowerroman'">lowerRoman</xsl:when>
		<xsl:when test="$style = 'upperroman'">upperRoman</xsl:when>
		<xsl:when test="$style = 'arabic'">decimal</xsl:when>
		<xsl:when test="$style = 'loweralpha'">lowerLetter</xsl:when>
		<xsl:when test="$style = 'upperalpha'">upperLetter</xsl:when>
		<xsl:otherwise>decimal</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!--
  Returns the current Word cell alignment from the PSML cell alignment

  @param string the PSML cell alignment

  @return the corresponding Word cell alignment
-->
<xsl:function name="fn:return-word-cell-alignment" as="xs:string?">
	<xsl:param name="pageseeder-cell-alignment" />
	<xsl:choose>
		<xsl:when test="$pageseeder-cell-alignment = 'right'">right</xsl:when>
		<xsl:when test="$pageseeder-cell-alignment = 'justify'">both</xsl:when>
		<xsl:when test="$pageseeder-cell-alignment = 'center'">center</xsl:when>
		<xsl:otherwise/>
	</xsl:choose>
</xsl:function>

<!--
  Returns type of Word numbering style based on the current pageseeder list style.

  @param string the current 

  @return the corresponding word list style
-->
<xsl:function name="fn:return-default-pageseeder-numebring-style">
	<!-- TODO Fix typo, check usage and comment -->
	<xsl:param name="string" />
	<xsl:choose>
		<xsl:when test="$string = '1'">decimal</xsl:when>
		<xsl:when test="$string = '2'">lowerLetter</xsl:when>
		<xsl:when test="$string = '3'">lowerRoman</xsl:when>
		<xsl:when test="$string = '4'">lowerRoman</xsl:when>
		<xsl:when test="$string = '5'">lowerRoman</xsl:when>
		<xsl:when test="$string = '6'">lowerRoman</xsl:when>
		<xsl:otherwise>decimal</xsl:otherwise>
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
  Returns the value of the numbering id to create in the numbering.xml file
-->
<xsl:function name="fn:get-numbering-id">
	<xsl:param name="current" as="element()" />
	<xsl:choose>
		<xsl:when
			test="$current/ancestor::*[name() = 'list' or 'nlist']/parent::block and
						$current/ancestor::*[name() = 'list' or 'nlist']/parent::block/@label = $config-doc/config/lists/list/@name and
						$config-doc/config/lists/(list|nlist)[@name = $current/ancestor::*[name() = 'list' or 'nlist']/parent::block/@label][@style != '']">
			<xsl:variable name="style-name"
				select="$config-doc/config/lists/(list|nlist)[@name = $current/ancestor::*[name() = 'list' or 'nlist']/parent::block/@label]/@style" />
			<xsl:value-of
				select="document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num[w:abstractNumId/@w:val = document(concat($_dotxfolder,$numbering-template))/w:numbering/w:abstractNum[w:numStyleLink[@w:val = $style-name]]/@w:abstractNumId]/@w:numId" />
		</xsl:when>
		<xsl:when
			test="$current/ancestor::*[name() = 'list' or 'nlist']/parent::block and
						$current/ancestor::*[name() = 'list' or 'nlist']/parent::block/@label = $config-doc/config/lists/(list|nlist)/@name">
			<xsl:variable name="style-name"
				select="$current/ancestor::*[name() = 'list' or 'nlist']/parent::block/@label" />
			<xsl:variable name="max-num-id"
				select="max(document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num/number(@w:numId))" />
			<xsl:variable name="position"
				select="count($config-doc/config/lists/(list|nlist)) - count($config-doc/config/lists/(list|nlist)[@name=$style-name]/following-sibling::*[name() = 'list' or 'nlist'][@style=''])" />
			<xsl:value-of select="$max-num-id + $position" />
		</xsl:when>
		<xsl:when test="$current/parent::*[name() = 'nlist']">

			<xsl:variable name="max-num-id"
				select="max(document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num/number(@w:numId))" />
			<xsl:variable name="default-position"
				select="count($config-doc/config/lists/(list|nlist)) - count($config-doc/config/lists/nlist[@name='default']/following-sibling::*[name() = 'list' or 'nlist'][@style=''])" />
			<xsl:value-of select="$max-num-id + $default-position" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="max-num-id"
				select="max(document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num/number(@w:numId))" />
			<xsl:variable name="default-position"
				select="count($config-doc/config/lists/(list|nlist)) - count($config-doc/config/lists/list[@name='default']/following-sibling::*[name() = 'list' or 'nlist'][@style=''])" />
			<xsl:value-of select="$max-num-id + $default-position" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- 
  Checks if the current element contains block elements or not
 -->
<xsl:function name="fn:has-block-elements">
	<xsl:param name="element" />
	<xsl:choose>
		<xsl:when
			test="$element/block or $element/para or $element/heading or $element/code or $element/nlist or $element/table or $element/list or $element/blockxref">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- 
  Checks if the current element is a block element or not
-->
<xsl:function name="fn:is-block-element">
	<xsl:param name="element" />
	<xsl:choose>
		<xsl:when
			test="$element[name()='heading' or contains(name(),'list') or name()='para' or
																			name()='block' or name()='table' or name()='preformat' or name()='blockxref']">
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
  @return the substring after the delimeter.
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
<xsl:function name="fn:get-current-date">
	<!-- TODO Use date formatter!!! -->
	<xsl:value-of select="concat(year-from-dateTime(current-dateTime()),'-',format-number(number(month-from-dateTime(current-dateTime())), '00'),'-',format-number(number(day-from-dateTime(current-dateTime())), '00'),'T',format-number(number(hours-from-dateTime(current-dateTime())), '00'),':',format-number(number(minutes-from-dateTime(current-dateTime())), '00'),':00')"/>
</xsl:function>

<!--
  Returns the string before a given delimiter, from an input string

  @param string the input string
  @param delimiter the delimiter to check for
  @return the substring before the delimeter.
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
