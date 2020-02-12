<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module providing functions to access the configuration.

  All functions in this module rely on the configuration document. Only functions from the
  `http://pageseeder.org/docx/config` namespace can dispense with providing the configuration
  as parameter.

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio

  @version 0.6.0
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:config="http://pageseeder.org/docx/config"
                xmlns:fn="http://pageseeder.org/docx/function"
                exclude-result-prefixes="#all">

<!-- The configuration file -->
<xsl:variable name="config-doc" select="document($_configfileurl)" as="node()"/>

<!-- Indicates whether internal references should be imported as PSML link elements -->
<xsl:function name="config:references-as-links" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/styles/default/references/@psmlelement='link'"/>
</xsl:function>

<!-- 
  Return anchor elements for each bookmarkStart child of current
  
  @param current  the current w:p element
 -->
<xsl:function name="fn:generate-anchors">
  <xsl:param name="current"/>
  <xsl:if test="config:references-as-links()">
    <xsl:for-each select="$current/w:bookmarkStart">
      <anchor name="{@w:name}" />
    </xsl:for-each>
  </xsl:if>
</xsl:function>

<!-- Indicates whether the mathml files should be generated -->
<xsl:function name="config:generate-mathml-files" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/split/mathml[@select= 'true']/@output= 'generate-files'"/>
</xsl:function>

<!-- Indicates whether the mathml content should be generated -->
<xsl:function name="config:generate-mathml" as="xs:boolean">
  <xsl:sequence select="not($config-doc/config/split/mathml/@select= 'false')"/>
</xsl:function>

<!-- Indicates whether the mathml files should be converted -->
<xsl:function name="config:convert-omml-to-mml" as="xs:boolean">
  <xsl:sequence select="not($config-doc/config/split/mathml/@convert-to-mml= 'false')"/>
</xsl:function>

<!-- Indicates whether the footnote files should be converted -->
<xsl:function name="config:convert-footnotes" as="xs:boolean">
  <xsl:sequence select="not($config-doc/config/split/footnotes/@select= 'false')"/>
</xsl:function>

<!-- variable to define what type of conversion to be used for footnotes-->
<xsl:function name="config:convert-footnotes-type" as="xs:string">
  <xsl:variable name="output" select="$config-doc/config/split/footnotes[@select= 'true']/@output"/>
  <xsl:choose>
    <xsl:when test="$output='generate-files'">generate-files</xsl:when>
    <xsl:when test="$output='generate-fragments'">generate-fragments</xsl:when>
    <xsl:otherwise>generate-fragments</xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- boolean variable to convert or not endnote files -->
<xsl:function name="config:convert-endnotes" as="xs:boolean">
  <xsl:sequence select="not($config-doc/config/split/endnotes/@select= 'false')"/>
</xsl:function>

<!-- variable to define what type of conversion to be used for endnotes-->
<xsl:function name="config:convert-endnotes-type" as="xs:string">
  <xsl:variable name="output" select="$config-doc/config/split/endnotes[@select= 'true']/@output"/>
  <xsl:choose>
    <xsl:when test="$output='generate-files'">generate-files</xsl:when>
    <xsl:when test="$output='generate-fragments'">generate-fragments</xsl:when>
    <xsl:otherwise>generate-fragments</xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- String of list of numbering regular expressions to be captured in the config file -->
<xsl:function name="config:document-split-styles-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($config-doc/config/split/document/wordstyle/@select)"/>
</xsl:function>

<!-- TODO Create function (might need to use backing field) -->

<!-- default value of the character styles input -->
<xsl:variable name="character-styles" as="xs:string?">
  <xsl:choose>
    <xsl:when test="$config-doc/config/styles/default/characterStyles/@value">
      <xsl:value-of select="$config-doc/config/styles/default/characterStyles/@value" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'inline'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- default value of the paragraph styles input -->
<xsl:variable name="paragraph-styles" as="xs:string?">
  <xsl:choose>
    <xsl:when test="$config-doc/config/styles/default/paragraphStyles/@value = 'para'">
      <xsl:value-of select="'para'" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'block'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
  Indicate if the current node matches a paragraph style document break or not.

  @param current the current node

  @return true or false
-->
<xsl:function name="config:matches-document-split-styles" as="xs:boolean">
  <xsl:param name="current" as="node()" />
  <!-- TODO document what type of node/context it applies to -->
  <xsl:sequence select="exists($current[matches(w:pPr/w:pStyle/@w:val, config:document-split-styles-string())][not(fn:matches-ignore-paragraph-match-list(.))])"/>
</xsl:function>

<!-- String of list of numbering regular expressions to be captured in the config file -->
<xsl:function name="config:document-specific-split-styles-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($config-doc/config/split/document/splitstyle/@select)"/>
</xsl:function>

<!--
  Returns the boolean if the current node matches a paragraph style document break or not.

  @param current the current node

  @return true or false
-->
<xsl:function name="config:matches-document-specific-split-styles" as="xs:boolean">
  <xsl:param name="current" as="node()" />
  <!-- TODO document what type of node/context it applies to -->
  <xsl:sequence select="exists($current[matches(w:pPr/w:pStyle/@w:val, config:document-specific-split-styles-string())])"/>
</xsl:function>

<!-- String of list of bookmark start ids defined to split at fragment level -->
<xsl:function name="config:bookmark-start-section-split-regex-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($config-doc/config/split/section/bookmark/@select)"/>
</xsl:function>

<!-- String of list of paragraph styles that are set to transform into headings in the configuration file -->
<xsl:function name="config:heading-paragraphs-list-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($config-doc/config/styles/wordstyle[@psmlelement='heading']/@name)"/>
</xsl:function>

<!-- String of list of paragraph styles that are set to transform into para in the configuration file -->
<!-- TODO Might not be used! -->
<xsl:function name="config:para-paragraphs-list-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($config-doc/config/styles/wordstyle[@psmlelement='para']/@name)"/>
</xsl:function>

<!-- String of list of paragraph styles that are set to split sections in the configuration file -->
<xsl:function name="config:section-split-styles-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($config-doc/config/split/section/wordstyle/@select)"/>
</xsl:function>

<!-- String of list of paragraph styles that are only used set to split sections in the configuration file; the content of these is then deleted -->
<xsl:function name="config:section-specific-split-styles-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($config-doc/config/split/section/splitstyle/@select)"/>
</xsl:function>

<!-- String of list of outline levels that are set to split sections in the configuration file -->
<xsl:function name="config:section-split-outline-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($config-doc/config/split/section/outlinelevel/@select)"/>
</xsl:function>

<!-- String of list of sectionbreak styles that are set to split sections in the configuration file -->
<xsl:function name="config:section-split-sectionbreak-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($config-doc/config/split/section/sectionbreak/@select)"/>
</xsl:function>

<!-- String of list of paragraph styles to ignore -->
<xsl:function name="config:ignore-paragraph-match-list-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($config-doc/config/styles/ignore/wordstyle/@value)"/>
</xsl:function>

<!-- Function to test if a paragraph style is part of the config ignore list -->
<xsl:function name="fn:matches-ignore-paragraph-match-list" as="xs:boolean">
  <xsl:param name="current" as="node()" />
  <xsl:sequence select="exists($current[matches(w:pPr/w:pStyle/@w:val, config:ignore-paragraph-match-list-string())])"/>
</xsl:function>

<!-- String of list of outline levels defined to split at document level -->
<xsl:function name="config:document-split-outline-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($config-doc/config/split/document/outlinelevel/@select)"/>
</xsl:function>

<!-- String of list of section breaks defined to split at document level -->
<xsl:function name="config:document-split-sectionbreak-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($config-doc/config/split/document/sectionbreak/@select)"/>
</xsl:function>

<!-- string of lis of convert manual numbering matching regular expressions -->
<xsl:function name="config:numbering-match-list-string" as="xs:string">
  <xsl:variable name="manual-numbering" select="$config-doc/config/lists/convert-manual-numbering"/>
  <xsl:sequence select="if ($manual-numbering/@select='true') then fn:items-to-start-regex($manual-numbering/value/@match) else fn:items-to-start-regex(())"/>
</xsl:function>

<!-- String of list of convert inline labels matching regular expressions -->
<xsl:function name="config:numbering-match-list-inline-string" as="xs:string">
  <xsl:variable name="manual-numbering" select="$config-doc/config/lists/convert-manual-numbering"/>
  <xsl:sequence select="if ($manual-numbering/@select='true') then fn:items-to-start-regex($manual-numbering/value[inline]/@match) else fn:items-to-start-regex(())"/>
</xsl:function>

<!-- String of list of prefix manual conversion regular expressions -->
<xsl:function name="config:numbering-match-list-prefix-string" as="xs:string">
  <xsl:variable name="manual-numbering" select="$config-doc/config/lists/convert-manual-numbering"/>
  <xsl:sequence select="if ($manual-numbering/@select='true') then fn:items-to-start-regex($manual-numbering/value[prefix]/@match) else fn:items-to-start-regex(())"/>
</xsl:function>

<!-- String of list of autonumbering manual conversion regular expressions -->
<xsl:function name="config:numbering-match-list-autonumbering-string" as="xs:string">
  <xsl:variable name="manual-numbering" select="$config-doc/config/lists/convert-manual-numbering"/>
  <xsl:sequence select="if ($manual-numbering/@select='true') then fn:items-to-start-regex($manual-numbering/value[autonumbering]/@match) else fn:items-to-start-regex(())"/>
</xsl:function>

<!--
  Returns the boolean if the current node matches a section break bookmark start position.

  @param current the current node

  @return true or false
-->
<xsl:function name="config:matches-section-split-bookmarkstart" as="xs:boolean">
  <xsl:param name="current" as="node()" />
  <xsl:sequence select="exists($current[w:bookmarkStart[matches(@w:name, config:bookmark-start-section-split-regex-string())]])"/>
</xsl:function>

<!--
  Returns the boolean if the current node matches a paragraph style section break or not. The content of this paragraph is ignored

  @param current the current node

  @return true or false
-->
<xsl:function name="config:matches-section-specific-split-styles" as="xs:boolean">
  <xsl:param name="current" as="node()"/>
  <xsl:sequence select="exists($current[matches(w:pPr/w:pStyle/@w:val, config:section-specific-split-styles-string())])"/>
</xsl:function>

<!--
  Checks if the the convert numbered paragraphs is set in configuration

  @return true or false
-->
<xsl:function name="config:convert-to-numbered-paragraphs" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/lists/convert-to-numbered-paragraphs/@select='true'"/>
</xsl:function>

<!--
  Checks if the split fragments is set in configuration

  @return true or false
-->
<xsl:function name="config:split-by-sections" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/split/section/@select='true'"/>
</xsl:function>

<!--
  Checks if the generate real titles for file names is set in configuration

  @return true or false
-->
<xsl:function name="config:generate-titles" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/split/document/@use-real-titles='true'"/>
</xsl:function>

<!--
  Checks if the split documents is set in configuration

  @return true or false
-->
<xsl:function name="config:split-by-documents" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/split/document/@select='true'"/>
</xsl:function>

<!--
  Checks if the number documents is set in configuration

  @return true or false
-->
<xsl:function name="config:number-document-title" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/lists/add-numbering-to-document-titles/@select='true'"/>
</xsl:function>

<!--
  Checks if the convert list styles into list roles is set in configuration

  @return true or false
-->
<xsl:function name="config:convert-to-list-roles" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/lists/convert-to-list-roles/@select='true'"/>
</xsl:function>

<!--
  Checks if the transform smart tags into inline elements is set in configuration

  @return true or false
-->
<xsl:function name="config:keep-smart-tags" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/styles/default/smart-tag/@keep = 'true'"/>
</xsl:function>

<!--
  Checks if the convert manual numbers into numbering in pageseeder is set in configuration

  @return true or false
-->
<xsl:function name="config:convert-manual-numbering" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/lists/convert-manual-numbering/@select='true'"/>
</xsl:function>

<!-- configuration value to generate or not index files -->
<xsl:function name="config:generate-index-files" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/styles/default/generate-index-files/@select= 'true'"/>
</xsl:function>

<!-- check if prefix generation for conversion of manual numbering exists -->
<xsl:function name="config:numbering-list-prefix-exists" as="xs:boolean">
  <xsl:sequence select="exists($config-doc/config/lists/convert-manual-numbering/value/prefix)"/>
</xsl:function>

<!-- check if autonumbering generation for conversion of manual numbering exists -->
<xsl:function name="config:numbering-list-autonumbering-exists" as="xs:boolean">
  <xsl:sequence select="exists($config-doc/config/lists/convert-manual-numbering/value/autonumbering)"/>
</xsl:function>

<!--
  Returns the type of output that the manual numbering of the current level should have.

  @param currentLevel the current level of the current node

  @return type of output
-->
<xsl:function name="config:get-numbered-paragraph-value" as="xs:string">
  <xsl:param name="currentLevel" />
  <xsl:choose>
    <xsl:when test="$config-doc/config/lists/convert-to-numbered-paragraphs[not(@select='true')]">
      <xsl:value-of select="'Nothing Selected'" />
    </xsl:when>
    <xsl:when test="$config-doc/config/lists/convert-to-numbered-paragraphs[@select='true']/not(level[@value=$currentLevel])">
      <xsl:value-of select="'Nothing Selected'" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$config-doc/config/lists/convert-to-numbered-paragraphs[@select='true']/level[@value=$currentLevel]/@output" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the type of numbering that the current element should have. Specific for heading

  @param style-name the current word style name

  @return type of value
-->
<xsl:function name="config:get-numbered-heading-value" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:choose>
    <xsl:when test="$config-doc/config/styles/wordstyle[@name=$style-name]/numbering[not(@select='true')]">
      <xsl:value-of select="'Nothing Selected'" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/numbering[@select='true']/@value" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the inline label that the current element should have. Specific for heading

  @param style-name the current word style name

  @return inline label value
-->
<xsl:function name="config:get-inline-heading-value" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:value-of select="string($config-doc/config/styles/wordstyle[@name=$style-name]/numbering[@select='true']/label/@value)" />
</xsl:function>

<!--
  Returns the type of numbering that the current element should have. Specific for para

  @param style-name the current word style name

  @return type of value
-->
<xsl:function name="config:get-numbered-para-value" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:choose>
    <xsl:when test="$config-doc/config/styles/wordstyle[@name=$style-name]/numbering[not(@select='true')]">
      <xsl:value-of select="'Nothing Selected'" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/numbering[@select='true']/@value" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the inline label that the current element should have. Specific for para

  @param style-name the current word style name

  @return inline label value
-->
<xsl:function name="config:get-inline-para-value"  as="xs:string">
  <xsl:param name="style-name" />
  <xsl:value-of select="string($config-doc/config/styles/wordstyle[@name=$style-name]/numbering[@select='true']/label/@value)" />
</xsl:function>

<!--
  Returns the label that the current element should have.

  @param style-name the current word style name

  @return label value
-->
<!-- TODO Unused ! -->
<xsl:function name="config:get-label-from-psml-element" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:value-of select="string($config-doc/config/styles/wordstyle[@name=$style-name]/label/@value)" />
</xsl:function>

<!--
  Returns the document label that the main references document has.

  @return document label value
-->
<xsl:function name="config:document-label-for-main-document"  as="xs:string">
  <xsl:value-of select="string($config-doc/config/split/main/label)"/>
</xsl:function>

<!--
  Returns the document type that the main references document has.

  @return document type value
-->
<xsl:function name="config:document-type-for-main-document"  as="xs:string">
  <xsl:value-of select="string($config-doc/config/split/main/type)"/>
</xsl:function>

<!--
  Returns the document label that the split style should have.

  @param style-name the current word style name

  @return document label value
-->
<xsl:function name="config:document-label-for-split-style"  as="xs:string">
  <xsl:param name="style-name" />
  <xsl:choose>
    <xsl:when test="$config-doc/config/split/document/wordstyle[@select=$style-name]/label">
      <xsl:value-of select="$config-doc/config/split/document/wordstyle[@select=$style-name]/label" />
    </xsl:when>
    <xsl:when test="$config-doc/config/split/document/splitstyle[@select=$style-name]/label">
      <xsl:value-of select="$config-doc/config/split/document/splitstyle[@select=$style-name]/label" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document type that the split style should have.

  @param style-name the current word style name

  @return document type value
-->
<xsl:function name="config:document-type-for-split-style" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:choose>
    <xsl:when test="$config-doc/config/split/document/wordstyle[@select=$style-name]/type">
      <xsl:value-of select="$config-doc/config/split/document/wordstyle[@select=$style-name]/type" />
    </xsl:when>
    <xsl:when test="$config-doc/config/split/document/splitstyle[@select=$style-name]/type">
      <xsl:value-of select="$config-doc/config/split/document/splitstyle[@select=$style-name]/type" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the blockxref level that the split style should have.

  @param style-name the current word style name

  @return blockxref level value
-->
<xsl:function name="config:document-level-for-split-style" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:choose>
    <xsl:when test="$config-doc/config/split/document/wordstyle[@select=$style-name]/level/@value">
      <xsl:value-of select="$config-doc/config/split/document/wordstyle[@select=$style-name]/level/@value" />
    </xsl:when>
    <xsl:when test="$config-doc/config/split/document/splitstyle[@select=$style-name]/level/@value">
      <xsl:value-of select="$config-doc/config/split/document/splitstyle[@select=$style-name]/level/@value" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the fragment type that the split style should have.

  @param style-name the current word style name

  @return fragment type value
-->
<xsl:function name="config:fragment-type-for-split-style" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:choose>
    <xsl:when test="$config-doc/config/split/section/wordstyle[@select=$style-name]/type">
      <xsl:value-of select="$config-doc/config/split/section/wordstyle[@select=$style-name]/type" />
    </xsl:when>
    <xsl:when test="$config-doc/config/split/section/splitstyle[@select=$style-name]/type">
      <xsl:value-of select="$config-doc/config/split/section/splitstyle[@select=$style-name]/type" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the inline label from style name.

  @param style-name the current word style name

  @return inline label value
-->
<xsl:function name="config:get-inline-label-from-psml-element" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:choose>
    <xsl:when test="$config-doc/config/styles/wordstyle[@name=$style-name][@psmlelement='inline']/label/@value">
      <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name][@psmlelement='inline']/label/@value" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the block label from style name.

  @param style-name the current word style name

  @return block label value
-->
<xsl:function name="config:get-block-label-from-psml-element" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name][@psmlelement='block']/label/@value" />
</xsl:function>

<!--
  Returns the indent value from style name.

  @param style-name the current word style name

  @return indent value value
-->
<!-- TODO Unused ! -->
<xsl:function name="config:get-para-indent-value" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:choose>
    <xsl:when test="$config-doc/config/styles/wordstyle[@name=$style-name]/indent/@level">
      <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/indent/@level" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the word caption element style for a specific table style value.

  @param style-name the current word style name

  @return  word caption element style
-->
<xsl:function name="config:get-caption-table-value" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:choose>
    <xsl:when test="$config-doc/config/styles/wordstyle[@name=$style-name]/@table">
      <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/@table" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the psml element for a specific style value.

  @param style-name the current word style name

  @return psml element
-->
<xsl:function name="config:get-psml-element" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/@psmlelement" />
</xsl:function>

<!--
  Returns the psml element for a specific paragraph node.

  @param paragraph the current paragraph node

  @return psml element
-->
<xsl:function name="config:get-psml-element-from-paragraph" as="xs:string">
  <xsl:param name="paragraph" />
  <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$paragraph/w:pPr/w:pStyle/@w:val]/@psmlelement" />
</xsl:function>

<!--
  Returns the block label for a specific style name. For headings only

  @param style-name the current word style name

  @return psml block label
-->
<xsl:function name="config:get-heading-block-label" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/label[@type='block']/@value" />
</xsl:function>

<!--
  Returns the inline label for a specific style name. For headings only

  @param style-name the current word style name

  @return psml inline label
-->
<xsl:function name="config:get-heading-inline-label" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/label[@type='inline']/@value" />
</xsl:function>

<!--
  Returns the heading level for a specific style name.

  @param style-name the current word style name
  @param document-level the current document level

  @return psml heading level
-->
<xsl:function name="config:get-heading-level" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:param name="document-level" />
  <!--     <xsl:message select="$document-level"/> -->
  <xsl:choose>
    <xsl:when test="$document-level != '0'">
      <xsl:value-of select="if(number($config-doc/config/styles/wordstyle[@name=$style-name]/level/@value) - number($document-level) &gt; 0) then ($config-doc/config/styles/wordstyle[@name=$style-name]/level/@value - number($document-level)) else $config-doc/config/styles/wordstyle[@name=$style-name]/level/@value" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/level/@value" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the block label for a specific style name. para elements only

  @param style-name the current word style name

  @return psml block label
-->
<xsl:function name="config:get-para-block-label" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/label[@type='block']/@value" />
</xsl:function>

<!--
  Returns the inline label for a specific style name. para elements only

  @param style-name the current word style name

  @return psml inline label
-->
<xsl:function name="config:get-para-inline-label" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/label[@type='inline']/@value" />
</xsl:function>

<!--
  Returns the indent level for a specific style name. para elements only

  @param style-name the current word style name

  @return psml indent level
-->
<xsl:function name="config:get-para-indent" as="xs:string">
  <xsl:param name="style-name" />
  <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/indent/@value" />
</xsl:function>

</xsl:stylesheet>
