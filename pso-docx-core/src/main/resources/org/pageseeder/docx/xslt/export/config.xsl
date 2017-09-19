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
                xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"
                xmlns:config="http://pageseeder.org/docx/config"
                xmlns:fn="http://pageseeder.org/docx/function"
                exclude-result-prefixes="#all">

<!--
  The document node of the configuration file

  This variable should not be used outside this module
-->
<xsl:variable name="config-doc" select="document($_configfileurl)" />

<!-- The value of the creator property -->
<xsl:function name="config:creator" as="xs:string">
  <xsl:choose>
    <xsl:when test="$manual-core = 'Template'">
      <xsl:value-of select="document(concat($_dotxfolder,'/docProps/core.xml'))/cp:coreProperties/dc:creator"/>
    </xsl:when>
    <xsl:when test="$manual-core = 'Config'">
      <xsl:value-of select="$config-doc/config/core/creator/@select"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$manual-creator"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- The value of the revision property -->
<xsl:function name="config:revision" as="xs:string">
  <xsl:choose>
    <xsl:when test="$manual-core = 'Template'">
      <xsl:value-of select="document(concat($_dotxfolder,'/docProps/core.xml'))/cp:coreProperties/cp:revision"/>
    </xsl:when>
    <xsl:when test="$manual-core = 'Config'">
      <xsl:value-of select="$config-doc/config/core/revision/@select"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$manual-revision"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- The value of the description property -->
<xsl:function name="config:description" as="xs:string">
  <xsl:choose>
    <xsl:when test="$manual-core = 'Template'">
      <xsl:value-of select="document(concat($_dotxfolder,'/docProps/core.xml'))/cp:coreProperties/dcterms:description"/>
    </xsl:when>
    <xsl:when test="$manual-core = 'Config'">
      <xsl:value-of select="$config-doc/config/core/description/@select"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$manual-description"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- The value of the subject property -->
<xsl:function name="config:subject" as="xs:string">
  <xsl:choose>
    <xsl:when test="$manual-core = 'Template'">
      <xsl:value-of select="document(concat($_dotxfolder,'/docProps/core.xml'))/cp:coreProperties/dcterms:subject"/>
    </xsl:when>
    <xsl:when test="$manual-core = 'Config'">
      <xsl:value-of select="$config-doc/config/core/subject/@select"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$manual-subject"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- The value of the title property -->
<xsl:function name="config:title" as="xs:string">
  <xsl:choose>
    <xsl:when test="$manual-core = 'Template'">
      <xsl:value-of select="document(concat($_dotxfolder,'/docProps/core.xml'))/cp:coreProperties/dcterms:title"/>
    </xsl:when>
    <xsl:when test="$manual-core = 'Config'">
      <xsl:value-of select="$config-doc/config/core/title/@select"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$manual-title"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- The value of the category property -->
<xsl:function name="config:category" as="xs:string">
  <xsl:choose>
    <xsl:when test="$manual-core = 'Template'">
      <xsl:value-of select="document(concat($_dotxfolder,'/docProps/core.xml'))/cp:coreProperties/cp:category"/>
    </xsl:when>
    <xsl:when test="$manual-core = 'Config'">
      <xsl:value-of select="$config-doc/config/core/category/@select"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$manual-category"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- The value of the version property -->
<xsl:function name="config:version" as="xs:string">
  <xsl:choose>
    <xsl:when test="$manual-core = 'Template'">
      <xsl:value-of select="document(concat($_dotxfolder,'/docProps/core.xml'))/cp:coreProperties/cp:version"/>
    </xsl:when>
    <xsl:when test="$manual-core = 'Config'">
      <xsl:value-of select="$config-doc/config/core/version/@select"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$manual-version"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the confirmation of creation a table of contents or not at PSML toc level.

  @return true or false
-->
<xsl:function name="config:generate-toc" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/toc/@generate = 'true'" />
</xsl:function>

<!--
  Returns the confirmation of creation a table of contents with headings or not.

  @return true or false
-->
<xsl:function name="config:generate-toc-headings" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/toc/headings/@generate = 'true'"/>
</xsl:function>

<!--
  Returns the values of the heading values for Table of contents.

  @return value of heading levels
-->
<xsl:function name="config:toc-heading-values" as="xs:string">
  <xsl:value-of select="string($config-doc/config/toc/headings/@select)"/>
</xsl:function>

<!--
  Returns the confirmation of creation a table of contents with outline levels or not.

  @return true or false
-->
<xsl:function name="config:generate-toc-outline" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/toc/outline/@generate = 'true'"/>
</xsl:function>

<!--
  Returns the values of the outline level values for Table of contents.

  @return value of outline levels
-->
<xsl:function name="config:toc-outline-values" as="xs:string">
  <xsl:value-of select="string($config-doc/config/toc/outline/@select)" />
</xsl:function>

<!--
  Returns the confirmation of creation a table of contents with paragraph styles or not.

  @return true or false
-->
<xsl:function name="config:generate-toc-paragraphs" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/toc/paragraph/@generate = 'true'" />
</xsl:function>

<!--
  Returns the values of the paragraph styles values for Table of contents.

  @return list of paragraph styles and indent value
-->
<xsl:function name="config:toc-paragraph-values">
  <!-- TODO Looks like this function's return type is `xs:string*`, but used in `xslvalue-of` -->
  <xsl:for-each select="$config-doc/config/toc/paragraph/style">
    <xsl:choose>
      <xsl:when test="position() = last()">
        <xsl:value-of select="concat(@value, ',', @indent)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(@value, ',', @indent, ',')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:function>

<!--
  Returns the confirmation of creation of comments.

  @return true or false
-->
<xsl:function name="config:generate-comments" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/default/comments/@generate = 'true'" />
</xsl:function>

<!--
  Indicate whether cross-references should be generated.

  @return true or false
-->
<xsl:function name="config:generate-cross-references" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/default/xref/@type = 'cross-reference'"/>
</xsl:function>

<!--
  Returns the confirmation of creation of comments.

  @return true or false
-->
<xsl:function name="config:generate-mathml" as="xs:boolean">
  <xslsequence select="$config-doc/config/default/mathml/@generate = 'true'"/>
</xsl:function>

<!--
  Returns the naming of docx files on export master.

  @return type of export: 'urititle' or 'uriid'
-->
<xsl:function name="config:master-select" as="xs:string">
  <xsl:value-of select="if ($config-doc/config/default/master/@select = 'urititle') then 'urititle' else 'uriid'" />
</xsl:function>

<!--
  @return a regular expression matching all the inline labels that should create a tab
-->
<xsl:function name="config:default-tab-inline-labels" as="xs:string">
  <xsl:value-of select="fn:items-to-regex($config-doc/config/elements[not(@label)]/inline/tab/@label)"/>
</xsl:function>

<!--
  @param document-label the document label to match
  @return a regular expression matching all inline labels that should create a tab specific for a document label
-->
<xsl:function name="config:tab-inline-labels-document" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:value-of select="fn:items-to-regex($config-doc/config/elements[@label = $document-label]/inline/tab/@label)"/>
</xsl:function>

<!--
  @return a regular expression matching all the default inline labels to transform to fieldcodes.
-->
<xsl:function name="config:default-inline-fieldcode-labels" as="xs:string">
  <xsl:value-of select="fn:items-to-regex($config-doc/config/elements[not(@label)]/inline/fieldcode/@label)"/>
</xsl:function>

<!--
  @param document-label the document label to match
  @return a regular expression matching the list of a specific document label inline labels to transform to fieldcodes.
-->
<xsl:function name="config:inline-fieldcode-labels-with-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:value-of select="fn:items-to-regex($config-doc/config/elements[@label = $document-label]/inline/fieldcode/@label)"/>
</xsl:function>

<!--
  Returns the default fieldcode value for a specific inline label.

  @param inline-label the value of the inline label
  @return the value of the fieldcode
-->
<xsl:function name="config:get-default-inline-fieldcode-value" as="xs:string">
  <xsl:param name="inline-label"/>
  <xsl:value-of select="string($config-doc/config/elements[not(@label)]/inline/fieldcode[@label = $inline-label]/@value)"/>
</xsl:function>

<!--
  Returns the list of default inline labels to transform to fieldcodes.

  @return the list of inline labels
-->
<xsl:function name="config:default-inline-index-labels" as="xs:string">
  <xsl:value-of select="fn:items-to-regex($config-doc/config/elements[not(@label)]/inline/index/@label)"/>
</xsl:function>

<!--
  Returns the list of a specific document label inline labels to transform to fieldcodes.

  @return the list of inline labels
-->
<xsl:function name="config:inline-index-labels-with-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:value-of select="fn:items-to-regex($config-doc/config/elements[@label = $document-label]/inline/index/@label)"/>
</xsl:function>

<!--
  Returns the document label specific fieldcode value for a specific inline label.

  @param inline-label the value of the inline label
  @param document-label the value of the document label

  @return the value of the fieldcode
-->
<xsl:function name="config:get-document-label-inline-fieldcode-value" as="xs:string">
  <xsl:param name="inline-label"/>
  <xsl:param name="document-label"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label]/inline/fieldcode[@label = $inline-label]/@value)" />
</xsl:function>

<!--
  Returns the list of default ignore inline labels.

  @return the list of inline labels
-->
<xsl:function name="config:default-inline-ignore-labels" as="xs:string">
  <xsl:value-of select="fn:items-to-regex($config-doc/config/elements[not(@label)]/inline/ignore/@label)"/>
</xsl:function>

<!--
  Returns the list of document label specific ignore inline labels.

  @param document-label the value of the document label

  @return the list of inline labels
-->
<xsl:function name="config:inline-ignore-labels-with-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:value-of select="fn:items-to-regex($config-doc/config/elements[@label = $document-label]/inline/ignore/@label)"/>
</xsl:function>

<!--
  Returns the list of default ignore block labels.

  @return the list of block labels
-->
<xsl:function name="config:default-block-ignore-labels" as="xs:string">
  <xsl:value-of select="fn:items-to-regex($config-doc/config/elements[not(@label)]/block/ignore/@label)"/>
</xsl:function>

<!--
  Returns the list of document label specific ignore block labels.

  @param document-label the value of the document label

  @return the list of block labels
-->
<xsl:function name="config:block-ignore-labels-with-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:value-of select="fn:items-to-regex($config-doc/config/elements[@label = $document-label]/block/ignore/@label)"/>
</xsl:function>

<!--
  Returns the default table style.

  @return the word table style
-->
<xsl:function name="config:default-table-style" as="xs:string">
  <xsl:variable name="table-name" select="$config-doc/config/elements[not(@label)]/tables/table/@default"/>
  <xsl:value-of select="string(document(concat($_dotxfolder, $styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $table-name]/@w:styleId)" />
</xsl:function>

<!--
  Returns the default table style based on a table role.

  @param role the table role

  @return the word table style
-->
<xsl:function name="config:default-table-roles" as="xs:string">
  <xsl:param name="role"/>
  <xsl:variable name="table-name" select="$config-doc/config/elements[not(@label)]/tables/table[@role = $role]/@tablestyle"/>
  <xsl:value-of select="string(document(concat($_dotxfolder, $styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $table-name]/@w:styleId)" />
</xsl:function>

<!--
  Returns the document label specific table style.

  @return the word table style
-->
<xsl:function name="config:default-table-style-with-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:variable name="table-name" select="$config-doc/config/elements[@label = $document-label]/tables/table/@default"/>
  <xsl:value-of select="string(document(concat($_dotxfolder, $styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $table-name]/@w:styleId)" />
</xsl:function>

<!--
  Returns the document label specific table style based on a table role.

  @param role the table role

  @return the word table style
-->
<xsl:function name="config:table-roles-with-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:variable name="table-name" select="$config-doc/config/elements[@label = $document-label]/tables/table[@role = $role]/@tablestyle"/>
  <xsl:value-of select="string(document(concat($_dotxfolder, $styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $table-name]/@w:styleId)"/>
</xsl:function>

<!--
  Returns the document label and table role specific table head style
  otherwise the document label specific table head style
  otherwise the document role specific table head style
  otherwise the default table head style
  otherwise the default paragraph style.

  @param document-label the document label
  @param role the table role

  @return the word table width type
-->
<xsl:function name="config:table-head-style" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:variable name="label-role-style" select="$config-doc/config/elements[@label = $document-label]/tables/table[@role = $role]/@headstyle"/>
  <xsl:variable name="label-style" select="$config-doc/config/elements[@label = $document-label]/tables/table[@default]/@headstyle"/>
  <xsl:variable name="role-style" select="$config-doc/config/elements[not(@label)]/tables/table[@role = $role]/@headstyle"/>
  <xsl:variable name="default-style" select="$config-doc/config/elements[not(@label)]/tables/table[@default]/@headstyle"/>
  <xsl:choose>
    <xsl:when test="$label-role-style != ''">
      <xsl:value-of select="$label-role-style" />
    </xsl:when>
    <xsl:when test="$label-style != ''">
      <xsl:value-of select="$label-style" />
    </xsl:when>
    <xsl:when test="$role-style != ''">
      <xsl:value-of select="$role-style" />
    </xsl:when>
    <xsl:when test="$default-style != ''">
      <xsl:value-of select="$default-style" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$default-paragraph-style" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label and table role specific table body style
  otherwise the document label specific table body style
  otherwise the document role specific table body style
  otherwise the default table body style
  otherwise the default paragraph style.

  @param document-label the document label
  @param role the table role

  @return the word table width type
-->
<xsl:function name="config:table-body-style" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:variable name="label-role-style" select="$config-doc/config/elements[@label = $document-label]/tables/table[@role = $role]/@bodystyle"/>
  <xsl:variable name="label-style" select="$config-doc/config/elements[@label = $document-label]/tables/table[@default]/@bodystyle"/>
  <xsl:variable name="role-style" select="$config-doc/config/elements[not(@label)]/tables/table[@role = $role]/@bodystyle"/>
  <xsl:variable name="default-style" select="$config-doc/config/elements[not(@label)]/tables/table[@default]/@bodystyle"/>
  <xsl:choose>
    <xsl:when test="$label-role-style != ''">
      <xsl:value-of select="$label-role-style" />
    </xsl:when>
    <xsl:when test="$label-style != ''">
      <xsl:value-of select="$label-style" />
    </xsl:when>
    <xsl:when test="$role-style != ''">
      <xsl:value-of select="$role-style" />
    </xsl:when>
    <xsl:when test="$default-style != ''">
      <xsl:value-of select="$default-style" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$default-paragraph-style" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the default table width type.

  @return the word table with type
-->
<xsl:function name="config:default-table-style-type" as="xs:string">
  <xsl:value-of select="string($config-doc/config/elements[not(@label)]/tables/table[@default]/width/@type)" />
</xsl:function>

<!--
  Returns the default table width value.

  @return the word table with value
-->
<xsl:function name="config:default-table-style-type-value" as="xs:string">
  <xsl:value-of select="string($config-doc/config/elements[not(@label)]/tables/table[@default]/width/@value)" />
</xsl:function>

<!--
  Returns the default table width type based on a table role.

  @param role the table role

  @return the word table width type
-->
<xsl:function name="config:default-table-roles-type" as="xs:string">
  <xsl:param name="role"/>
  <xsl:value-of select="string($config-doc/config/elements[not(@label)]/tables/table[@role = $role]/width/@type)"/>
</xsl:function>

<!--
Returns the default table width value based on a table role.

@param role the table role

@return the word table width value
-->
<xsl:function name="config:default-table-roles-type-value" as="xs:string">
  <xsl:param name="role"/>
  <xsl:value-of select="string($config-doc/config/elements[not(@label)]/tables/table[@role = $role]/width/@value)"/>
</xsl:function>

<!--
  Returns the document label specific table width type.

  @return the word table width type
-->
<xsl:function name="config:default-table-style-with-document-label-type" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label]/tables/table[@default]/width/@type)"/>
</xsl:function>

<!--
  Returns the document label specific table width value.

  @return the word table width value
-->
<xsl:function name="config:default-table-style-with-document-label-type-value" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label]/tables/table[@default]/width/@value)" />
</xsl:function>

<!--
  Returns the document label specific table width type based on a table role.

  @param document-label the document label
  @param role the table role

  @return the word table width type
-->
<xsl:function name="config:table-roles-with-document-label-type" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label]/tables/table[@role = $role]/width/@type)" />
</xsl:function>

<!--
  Returns the document label specific table width value based on a table role.

  @param document-label the document label
  @param role the table value

  @return the word table width type
-->
<xsl:function name="config:table-roles-with-document-label-type-value" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label]/tables/table[@role = $role]/width/@value)" />
</xsl:function>

<!--
  Returns the configured style for ps:preformat element for label specific documents.

  @param document-label the document label
  @return the w:style
-->
<xsl:function name="config:preformat-wordstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label]/preformat/@wordstyle)" />
</xsl:function>

<!--
  Returns the configured style for ps:preformat element for default documents.

  @return the w:style
-->
<xsl:function name="config:preformat-wordstyle-for-default-document" as="xs:string">
  <xsl:value-of select="string($config-doc/config/elements[not(@label)]/preformat/@wordstyle)" />
</xsl:function>

<!--
  Returns the configured w:style for ps:block element for label specific documents.

  @param document-label the document label
  @param block-label the current block label
  @return the w:style
-->
<xsl:function name="config:block-wordstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="block-label"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label]/block/label[@value=$block-label]/@wordstyle)" />
</xsl:function>

<!--
  Returns the default w:style for ps:block element for label specific documents.

  @param document-label the document label
  @return the w:style
-->
<xsl:function name="config:block-default-wordstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:variable name="style" select="$config-doc/config/elements[@label = $document-label]/block/@default"/>
  <xsl:value-of select="if ($style = 'none') then '' else string($style)" />
</xsl:function>

<!--
  Returns the configured w:style for ps:block element for default documents.

  @param block-label the document label
  @return the w:style
-->
<xsl:function name="config:block-wordstyle-for-default-document" as="xs:string">
  <xsl:param name="block-label"/>
  <xsl:value-of select="string($config-doc/config/elements[not(@label)]/block/label[@value=$block-label]/@wordstyle)" />
</xsl:function>

<!--
  Returns the default w:style for ps:block element for default documents.

  @return the w:style
-->
<xsl:function name="config:block-default-wordstyle-for-default-document" as="xs:string">
  <xsl:variable name="style" select="$config-doc/config/elements[not(@label)]/block/@default"/>
  <xsl:value-of select="if ($style = 'none') then '' else string($style)" />
</xsl:function>

<!--
  Returns the configured w:style for ps:inline element for label specific documents.

  @param document-label the document label
  @param inline-label the current inline label
  @return the w:style
-->
<xsl:function name="config:inline-wordstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="inline-label"/>
  <xsl:variable name="style" select="$config-doc/config/elements[@label = $document-label]/inline/label[@value=$inline-label]/@wordstyle"/>
  <xsl:value-of select="if ($style = 'generate-ps-style') then concat('psinline', $inline-label) else string($style)"/>
</xsl:function>

<!--
  Returns the configured w:style for ps:inline element for label specific documents.

  @param document-label the document label
  @return the w:style
-->
<xsl:function name="config:inline-default-wordstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:variable name="style" select="$config-doc/config/elements[@label = $document-label]/inline/@default"/>
  <xsl:value-of select="if ($style = 'none') then '' else string($style)" />
</xsl:function>

<!--
  Returns the configured w:style for ps:inline element for default documents.

  @param inline-label the current inline label
  @return the w:style
-->
<xsl:function name="config:inline-wordstyle-for-default-document" as="xs:string">
  <xsl:param name="inline-label"/>
  <xsl:value-of select="string($config-doc/config/elements[not(@label)]/inline/label[@value=$inline-label]/@wordstyle)" />
</xsl:function>

<!--
  Returns the default w:style for ps:inline element for default documents.

  @return the w:style
-->
<xsl:function name="config:inline-default-wordstyle-for-default-document" as="xs:string">
  <xsl:variable name="style" select="$config-doc/config/elements[not(@label)]/inline/@default"/>
  <xsl:value-of select="if ($style = 'none') then '' else string($style)"/>
</xsl:function>

<!--
  Returns the configured w:style for ps:heading element for label specific documents.

  @param document-label the document label
  @param heading-level the current heading level
  @param numbered the numbered attribute value of the heading
  @return the w:style
-->
<xsl:function name="config:heading-wordstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/@wordstyle)" />
</xsl:function>

<!--
  Returns the configured w:style for ps:heading element for default documents.

  @param heading-level the current heading level
  @param numbered the numbered attribute value of the heading
  @return the w:style
-->
<xsl:function name="config:heading-wordstyle-for-default-document" as="xs:string">
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:value-of select="string($config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/@wordstyle)" />
</xsl:function>

<!--
  Returns if the configured w:style for ps:heading element for default documents should convert the prefix into a value or not.

  @param heading-level the current heading level
  @param numbered the numbered attribute value of the heading
  @return true or false
-->
<xsl:function name="config:heading-prefix-select-for-default-document" as="xs:boolean">
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:variable name="select" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/@select"/>
  <xsl:sequence select="$select = 'true' or $select = 'false'"/>
</xsl:function>

<!--
  Returns if the configured w:style for ps:heading element for default documents should keep with the next w:paragraph.

  @param heading-level the current heading level
  @param numbered the numbered attribute value of the heading
  @return true or false
-->
<xsl:function name="config:default-keep-heading-with-next" as="xs:boolean">
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:sequence select="exists($config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/keep-paragraph-with-next)"/>
</xsl:function>

<!--
  Returns if the configured w:style for ps:heading element for document label specific documents should convert the prefix into a value or not.

  @param heading-level the current heading level
  @param numbered the numbered attribute value of the heading
  @return true or false
-->
<xsl:function name="config:heading-prefix-select-for-document-label" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:variable name="select" select="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/@select"/>
  <xsl:sequence select="$select = 'true' or $select = 'false'" />
</xsl:function>

<!--
  Returns if the configured w:style for ps:heading element for document label specific documents should keep with the next w:paragraph.

  @param heading-level the current heading level
  @param numbered the numbered attribute value of the heading
  @return true or false
-->
<xsl:function name="config:labels-keep-heading-with-next" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:sequence select="exists($config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/keep-paragraph-with-next)"/>
</xsl:function>

<!--
  Returns if the configured w:style for ps:para element for default documents should handle the @ps:prefix.

  @param indent-level the current indent level
  @param numbered the numbered attribute value of the ps:para
  @return true or false
-->
<xsl:function name="config:para-prefix-select-for-default-document" as="xs:boolean">
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:variable name="indent" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)]"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $indent[@level='0']/prefix/@select = 'true'">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:when test="$indent[@level=$indent-level]/prefix/@select = 'true'
               or $indent[@level=$indent-level]/prefix/@select = 'false'">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns if the configured w:style for ps:para element for default documents should keep with the next w:paragraph.

  @param indent-level the current ps:para level
  @param numbered the numbered attribute value of the ps:para
  @return true or false
-->
<xsl:function name="config:default-keep-para-with-next" as="xs:boolean">
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level='0']/keep-paragraph-with-next">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/keep-paragraph-with-next">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns if the configured w:style for ps:para element for document label specific documents should keep with the next w:paragraph.

  @param document-label the current document label
  @param indent-level the current ps:para level
  @param numbered the numbered attribute value of the ps:para
  @return true or false
-->
<xsl:function name="config:labels-keep-para-with-next" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level='0']/keep-paragraph-with-next">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/keep-paragraph-with-next">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns if the configured w:style for ps:para element for document label specific documents should handle the @ps:prefix.

  @param document-label the current document label
  @param indent-level the current indent level
  @param numbered the numbered attribute value of the ps:para
  @return true or false
-->
<xsl:function name="config:para-prefix-select-for-document-label" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level='0']/prefix/@select = 'true'">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/prefix/@select = 'true'">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/prefix/@select = 'false'">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the w:style for ps:para element that is inside a ps:list for label specific document.

  @param document-label the current document label
  @param list-level the current list level
  @param numbered the numbered attribute value of the ps:para
  @return w:style
-->
<xsl:function name="config:para-list-level-paragraph-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="list-level"/>
  <xsl:param name="numbered"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label]/listpara/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$list-level]/@wordstyle)" />
</xsl:function>

<!--
  Returns the w:style for ps:para element that is inside a ps:list for default document.

  @param list-level the current list level
  @param numbered the numbered attribute value of the ps:para
  @return w:style
-->
<xsl:function name="config:para-list-level-paragraph-for-default-document" as="xs:string">
  <xsl:param name="list-level"/>
  <xsl:param name="numbered"/>
  <xsl:value-of select="string($config-doc/config/elements[not(@label)]/listpara/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$list-level]/@wordstyle)" />
</xsl:function>

<!--
  Returns if the configured w:style for ps:para element for default documents should handle the @ps:numbering.

  @param indent-level the current indent level
  @param numbered the numbered attribute value of the ps:para
  @return true or false
-->
<xsl:function name="config:para-numbered-select-for-default-document" as="xs:boolean">
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:variable name="indent" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)]"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $indent[@level='0']/numbered/@select = 'true'">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:when test="$indent[@level=$indent-level]/numbered/@select = 'true'
               or $indent[@level=$indent-level]/numbered/@select = 'false'">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns if the configured w:style for ps:para element for label specific documents should handle the @ps:numbering.

  @param document-level the current document label
  @param indent-level the current indent level
  @param numbered the numbered attribute value of the ps:para
  @return true or false
-->
<xsl:function name="config:para-numbered-select-for-document-label" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:variable name="indent" select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)]"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $indent[@level='0']/numbered/@select = 'true'">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:when test="$indent[@level=$indent-level]/numbered/@select = 'true'
               or $indent[@level=$indent-level]/numbered/@select = 'false'">
      <xsl:sequence select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns if the configured w:style for ps:heading element for default documents should handle the @ps:numbering.

  @param heading-level the current indent level
  @param numbered the numbered attribute value of the ps:para
  @return true or false
-->
<xsl:function name="config:heading-numbered-select-for-default-document" as="xs:boolean">
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:variable name="select" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/@select"/>
  <xsl:sequence select="$select = 'true' or $select = 'false'" />
</xsl:function>

<!--
  Returns if the configured w:style for ps:heading element for label specific documents should handle the @ps:numbering.

  @param document-label the current document label
  @param indent-level the current indent level
  @param numbered the numbered attribute value of the ps:para
  @return true or false
-->
<xsl:function name="config:heading-numbered-select-for-document-label" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:variable name="select" select="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/@select"/>
  <xsl:sequence select="$select = 'true' or $select = 'false'"/>
</xsl:function>

<!--
  Returns if the configured w:style for ps:block element for default documents should keep with the next w:paragraph.

  @param label the current ps:block label
  @return true or false
-->
<xsl:function name="config:default-keep-block-with-next" as="xs:boolean">
  <xsl:param name="label"/>
  <xsl:sequence select="exists($config-doc/config/elements[not(@label)]/block/label[@value=$label]/keep-paragraph-with-next)"/>
</xsl:function>

<!--
  Returns if the configured w:style for ps:block element for document label specific documents should keep with the next w:paragraph.

  @param document-label the current ps:document label
  @param label the current ps:block label
  @return true or false
-->
<xsl:function name="config:labels-keep-block-with-next" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="label"/>
  <xsl:value-of select="exists($config-doc/config/elements[@label = $document-label]/block/label[@value=$label]/keep-paragraph-with-next)"/>
</xsl:function>

<!--
  Returns the configured ps:title w:style for document label specific documents

  @param document-label the current document label

  @return the w:style
-->
<xsl:function name="config:title-wordstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:sequence select="string($config-doc/config/elements[@label = $document-label]/title/@wordstyle)"/>
</xsl:function>

<!--
  Returns the configured ps:title w:style for default documents

  @return the w:style
-->
<xsl:function name="config:title-wordstyle-for-default-document" as="xs:string">
  <xsl:value-of select="string($config-doc/config/elements[not(@label)]/title/@wordstyle)"/>
</xsl:function>

<!--
  Returns the configured ps:list w:style for document label specific documents

  @param document-label the current document label
  @param list-role the current list role
  @param list-level the current list level
  @param list-type list or nlist

  @return the w:style
-->
<xsl:function name="config:list-wordstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="list-role"/>
  <xsl:param name="list-level"/>
  <xsl:param name="list-type"/>
  <xsl:choose>
    <xsl:when test="$list-role != '' and $config-doc/config/elements[@label = $document-label]/*[name() = $list-type]/role[@value=$list-role]/level[@value=$list-level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/*[name() = $list-type]/level[@value=$list-level]/role[@value=$list-role]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/*[name() = $list-type]/default/level[@value=$list-level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/*[name() = $list-type]/default/level[@value=$list-level]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:list w:style for default documents

  @param list-role the current list role
  @param list-level the current list level
  @param list-type list or nlist

  @return the w:style
-->
<xsl:function name="config:list-wordstyle-for-default-document" as="xs:string">
  <xsl:param name="list-role"/>
  <xsl:param name="list-level"/>
  <xsl:param name="list-type"/>
  <xsl:choose>
    <xsl:when test="$list-role != '' and $config-doc/config/elements[not(@label)]/*[name() = $list-type]/role[@value=$list-role]/level[@value=$list-level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/*[name() = $list-type]/role[@value=$list-role]/level[@value=$list-level]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/*[name() = $list-type]/default/level[@value=$list-level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/*[name() = $list-type]/default/level[@value=$list-level]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<!--
  Returns the configured ps:para w:style for a specific document label

  @param document-label the current document label
  @param indent-level the current ps:para indent level
  @param numbered the @ps:numbered attribute of the ps:para

  @return the w:style
-->
<xsl:function name="config:para-wordstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:variable name="indent" select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (numbered/@select =  $numbered) else not(numbered)][if($prefix) then prefix else not(prefix)]"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $indent[@level='0']/@wordstyle">
      <xsl:value-of select="$indent[@level='0']/@wordstyle" />
    </xsl:when>
    <xsl:when test="$indent[@level=$indent-level]/@wordstyle">
      <xsl:value-of select="$indent[@level=$indent-level]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:para w:style for a default document

  @param indent-level the current ps:para indent level
  @param numbered the @ps:numbered attribute of the ps:para

  @return the w:style
-->
<xsl:function name="config:para-wordstyle-for-default-document" as="xs:string">
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <!-- TODO check how prefixes work (removed [if($prefix) then prefix else not(prefix)] from all xpaths) -->

  <xsl:choose>
    <xsl:when test="not($indent-level) and $config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level='0']/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level='0']/@wordstyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:(n)list w:style for a specific role

  @param role the current list role
  @param current the current node

  @return the w:style
-->
<xsl:function name="config:get-style-from-role" as="xs:string">
  <xsl:param name="role"/>
  <xsl:param name="current" as="node()"/>
  <xsl:variable name="document-label" select="$current/ancestor::document[1]/documentinfo/uri/labels"/>
  <xsl:variable name="list-type" select="$current/name()"/>
  <xsl:variable name="level" select="count($current/ancestor::*[name() = 'nlist' or name() = 'list']) + 1"/>
  <xsl:choose>
    <xsl:when test="$document-label != '' and $config-doc/config/elements[@label = $document-label]/*[name()=$list-type]/role[@value=$role]/level[@value=$level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/*[name()=$list-type]/role[@value=$role]/level[@value=$level]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$document-label != '' and $config-doc/config/elements[@label = $document-label]/*[name()=$list-type]/default/level[@value=$level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/*[name()=$list-type]/default/level[@value=$level]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/*[name()=$list-type]/role[@value=$role]/level[@value=$level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/*[name()=$list-type]/role[@value=$role]/level[@value=$level]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/*[name()=$list-type]/default/level[@value=$level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/*[name()=$list-type]/default/level[@value=$level]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>