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

<!--
  Substitute a PageSeeder token with the corresponding value. The supported tokens are:
    [ps-current-user]
    [ps-document-description]
    [ps-document-title]
    [ps-document-created]
    [ps-document-modified]
    [ps-current-date]
    [ps-document-labels]

  @param token   the token string

  @return the substituted value or the original token if not recognized
-->
<xsl:function name="config:ps-token" as="xs:string">
  <xsl:param name="token"/>
  <xsl:choose>
    <xsl:when test="$token = '[ps-current-user]'">
      <xsl:value-of select="$current-user"/>
    </xsl:when>
    <xsl:when test="$token = '[ps-document-description]'">
      <xsl:value-of select="$root-uri/description"/>
    </xsl:when>
    <xsl:when test="$token = '[ps-document-title]'">
      <xsl:value-of select="if ($root-uri/@title) then $root-uri/@title else substring-before($root-uri/displaytitle,'.psml')"/>
    </xsl:when>
    <xsl:when test="$token = '[ps-document-created]'">
      <xsl:value-of select="$root-uri/@created"/>
    </xsl:when>
    <xsl:when test="$token = '[ps-document-modified]'">
      <xsl:value-of select="$root-uri/@modified"/>
    </xsl:when>
    <xsl:when test="$token = '[ps-current-date]'">
      <xsl:value-of select="fn:get-current-date()"/>
    </xsl:when>
    <xsl:when test="$token = '[ps-document-labels]'">
      <xsl:value-of select="$root-uri/labels"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$token"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- The value of the modified property -->
<xsl:function name="config:modified" as="xs:string">
  <xsl:choose>
    <xsl:when test="$manual-core = 'Template'">
      <xsl:value-of select="document(concat($_dotxfolder,'/docProps/core.xml'))/cp:coreProperties/dcterms:modified"/>
    </xsl:when>
    <xsl:when test="$manual-core = 'Config'">
      <xsl:value-of select="$config-doc/config/core/modified/@select"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$manual-modified"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- The value of the created property -->
<xsl:function name="config:created" as="xs:string">
  <xsl:choose>
    <xsl:when test="$manual-core = 'Template'">
      <xsl:value-of select="document(concat($_dotxfolder,'/docProps/core.xml'))/cp:coreProperties/dcterms:created"/>
    </xsl:when>
    <xsl:when test="$manual-core = 'Config'">
      <xsl:value-of select="$config-doc/config/core/created/@select"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$manual-created"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

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

<!-- The value of the keywords property -->
<xsl:function name="config:keywords" as="xs:string">
  <xsl:choose>
    <xsl:when test="$manual-core = 'Template'">
      <xsl:value-of select="document(concat($_dotxfolder,'/docProps/core.xml'))/cp:coreProperties/cp:keywords"/>
    </xsl:when>
    <xsl:when test="$manual-core = 'Config'">
      <xsl:value-of select="$config-doc/config/core/keywords/@select"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$manual-keywords"/>
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
  Returns whether to create a table of contents on the root document.

  @return true or false
-->
<xsl:function name="config:generate-toc" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/toc/@generate = 'true'" />
</xsl:function>

<!--
  Returns whether to create a table of contents on a non-root document.

  @param document-label the document label

  @return true or false
-->
<xsl:function name="config:generate-toc-for-document-label" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/toc/@generate">
      <xsl:sequence select="$config-doc/config/elements[@label = $document-label]/toc/@generate = 'true'" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$config-doc/config/elements[not(@label)]/toc/@generate = 'true'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the confirmation of creation a table of contents with headings or not.

  @return true or false
-->
<xsl:function name="config:generate-toc-headings" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/toc/headings/@generate = 'true'"/>
</xsl:function>

<!--
  Returns whether to create a table of contents headings on a non-root document.

  @param document-label the document label

  @return true or false
-->
<xsl:function name="config:generate-toc-headings-for-document-label" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/toc/headings/@generate">
      <xsl:sequence select="$config-doc/config/elements[@label = $document-label]/toc/headings/@generate = 'true'" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$config-doc/config/elements[not(@label)]/toc/headings/@generate = 'true'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the values of the heading values for Table of contents.

  @return value of heading levels
-->
<xsl:function name="config:toc-heading-values" as="xs:string">
  <xsl:value-of select="string($config-doc/config/toc/headings/@select)"/>
</xsl:function>

<!--
  Returns table of contents headings values on a non-root document.

  @param document-label the document label

  @return value of heading levels
-->
<xsl:function name="config:toc-heading-values-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/toc/headings/@generate = 'true'">
      <xsl:value-of select="string($config-doc/config/elements[@label = $document-label]/headings/@select)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="string($config-doc/config/elements[not(@label)]/headings/@select)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the confirmation of creation a table of contents with outline levels or not.

  @return true or false
-->
<xsl:function name="config:generate-toc-outline" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/toc/outline/@generate = 'true'"/>
</xsl:function>

<!--
  Returns whether to create a table of contents outline on a non-root document.

  @param document-label the document label

  @return true or false
-->
<xsl:function name="config:generate-toc-outline-for-document-label" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/toc/outline/@generate">
      <xsl:sequence select="$config-doc/config/elements[@label = $document-label]/toc/outline/@generate = 'true'" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:sequence select="$config-doc/config/elements[not(@label)]/toc/outline/@generate = 'true'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the values of the outline level values for Table of contents.

  @return value of outline levels
-->
<xsl:function name="config:toc-outline-values" as="xs:string">
  <xsl:value-of select="string($config-doc/config/toc/outline/@select)" />
</xsl:function>

<!--
  Returns table of contents outline values on a non-root document.

  @param document-label the document label

  @return value of outline levels
-->
<xsl:function name="config:toc-outline-values-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/toc/outline/@generate = 'true'">
      <xsl:value-of select="string($config-doc/config/elements[@label = $document-label]/outline/@select)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="string($config-doc/config/elements[not(@label)]/outline/@select)"/>
    </xsl:otherwise>
  </xsl:choose>
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
  Returns the PSML document type for the footnotes.

  @return the document type
-->
<xsl:function name="config:footnotes-documenttype" as="xs:string">
  <xsl:value-of select="$config-doc/config/default/footnotes/@documenttype" />
</xsl:function>

<!--
  Returns the word section number for a document label otherwise 1.

  @param document-label the document label

  @return the section number
-->
<xsl:function name="config:section-number" as="xs:integer">
  <xsl:param name="document-label"/>

  <xsl:variable name="label-section" select="$config-doc/config/elements[@label = $document-label]/document/@wordsection"/>
  <xsl:variable name="default-section" select="$config-doc/config/elements[not(@label)]/document/@wordsection"/>
  <xsl:value-of select="if ($label-section) then number($label-section)
                        else if ($default-section) then number($default-section)
                        else 1" />
</xsl:function>

<!--
  Returns the style ID for the configured footnote text style.

  @param document-label the document label

  @return the style ID
-->
<xsl:function name="config:footnote-text-styleid" as="xs:string">
  <xsl:param name="document-label"/>

  <xsl:variable name="label-style" select="$config-doc/config/elements[@label = $document-label]/xref/footnote/@textstyle"/>
  <xsl:variable name="default-style" select="$config-doc/config/elements[not(@label)]/xref/footnote/@textstyle"/>
  <xsl:variable name="style" select="if ($label-style != '') then $label-style
    else if ($default-style != '') then $default-style else 'footnote text'"/>
  <xsl:variable name="styleid"
    select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style]/@w:styleId"/>
  <xsl:value-of select="if (string($styleid)!='') then $styleid else 'Normal'" />
</xsl:function>

<!--
  Returns the style ID for the configured footnote reference style.

  @param document-label the document label

  @return the style ID
-->
<xsl:function name="config:footnote-reference-styleid" as="xs:string">
  <xsl:param name="document-label"/>

  <xsl:variable name="label-style" select="$config-doc/config/elements[@label = $document-label]/xref/footnote/@referencestyle"/>
  <xsl:variable name="default-style" select="$config-doc/config/elements[not(@label)]/xref/footnote/@referencestyle"/>
  <xsl:variable name="style" select="if ($label-style != '') then $label-style
    else if ($default-style != '') then $default-style else 'footnote reference'"/>
  <xsl:variable name="styleid"
    select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style]/@w:styleId"/>
  <xsl:value-of select="if (string($styleid)!='') then $styleid else 'DefaultParagraphFont'" />
</xsl:function>

<!--
  Returns the PSML document type for the endnotes.

  @return the document type
-->
<xsl:function name="config:endnotes-documenttype" as="xs:string">
  <xsl:value-of select="$config-doc/config/default/endnotes/@documenttype" />
</xsl:function>

<!--
  Returns the style ID for the configured endnote text style.

  @param document-label the document label

  @return the style ID
-->
<xsl:function name="config:endnote-text-styleid" as="xs:string">
  <xsl:param name="document-label"/>

  <xsl:variable name="label-style" select="$config-doc/config/elements[@label = $document-label]/xref/endnote/@textstyle"/>
  <xsl:variable name="default-style" select="$config-doc/config/elements[not(@label)]/xref/endnote/@textstyle"/>
  <xsl:variable name="style" select="if ($label-style != '') then $label-style
    else if ($default-style != '') then $default-style else 'endnote text'"/>
  <xsl:variable name="styleid"
    select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style]/@w:styleId"/>
  <xsl:value-of select="if (string($styleid)!='') then $styleid else 'Normal'" />
</xsl:function>

<!--
  Returns the style ID for the configured endnote reference style.

  @param document-label the document label

  @return the style ID
-->
<xsl:function name="config:endnote-reference-styleid" as="xs:string">
  <xsl:param name="document-label"/>

  <xsl:variable name="label-style" select="$config-doc/config/elements[@label = $document-label]/xref/endnote/@referencestyle"/>
  <xsl:variable name="default-style" select="$config-doc/config/elements[not(@label)]/xref/endnote/@referencestyle"/>
  <xsl:variable name="style" select="if ($label-style != '') then $label-style
    else if ($default-style != '') then $default-style else 'endnote reference'"/>
  <xsl:variable name="styleid"
    select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style]/@w:styleId"/>
  <xsl:value-of select="if (string($styleid)!='') then $styleid else 'DefaultParagraphFont'" />
</xsl:function>

<!--
  Returns the PSML document type for the citations.

  @return the document type
-->
<xsl:function name="config:citations-documenttype" as="xs:string">
  <xsl:value-of select="$config-doc/config/default/citations/@documenttype" />
</xsl:function>

<!--
  Returns the PSML inline label name for the citation pages.

  @return the document type
-->
<xsl:function name="config:citations-pageslabel" as="xs:string">
  <xsl:value-of select="$config-doc/config/default/citations/@pageslabel" />
</xsl:function>

<!--
  Returns the style ID for the configured citation reference style.

  @param document-label the document label

  @return the style ID
-->
<xsl:function name="config:citation-reference-styleid" as="xs:string">
  <xsl:param name="document-label"/>

  <xsl:variable name="label-style" select="$config-doc/config/elements[@label = $document-label]/xref/citation/@referencestyle"/>
  <xsl:variable name="default-style" select="$config-doc/config/elements[not(@label)]/xref/citation/@referencestyle"/>
  <xsl:variable name="style" select="if ($label-style != '') then $label-style
    else if ($default-style != '') then $default-style else $default-character-style"/>
  <xsl:variable name="styleid"
    select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style]/@w:styleId"/>
  <xsl:value-of select="if (string($styleid)!='') then $styleid else 'DefaultParagraphFont'" />
</xsl:function>

<!--
  Returns the style ID for the resolved placeholder style.

  @return the style ID or '' if none defined
-->
<xsl:function name="config:placeholder-resolved-styleid" as="xs:string?">
  <xsl:variable name="style" select="$config-doc/config/default/placeholders/@resolvedstyle" />
  <xsl:if test="$style">
    <xsl:variable name="styleid"
      select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style]/@w:styleId"/>
    <xsl:value-of select="if (string($styleid)!='') then $styleid else 'DefaultParagraphFont'" />
  </xsl:if>
</xsl:function>

<!--
  Returns the style ID for the unresolved placeholder style.

  @return the style ID or '' if none defined
-->
<xsl:function name="config:placeholder-unresolved-styleid" as="xs:string?">
  <xsl:variable name="style" select="$config-doc/config/default/placeholders/@unresolvedstyle" />
  <xsl:if test="$style">
    <xsl:variable name="styleid"
      select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style]/@w:styleId"/>
    <xsl:value-of select="if (string($styleid)!='') then $styleid else 'DefaultParagraphFont'" />
  </xsl:if>
</xsl:function>

<!--
  Indicate whether cross-references should be generated.

  @return true or false
-->
<xsl:function name="config:generate-cross-references" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/default/xrefs/@type = 'cross-reference'"/>
</xsl:function>

<!--
Indicate whether hyperlinks should be generated.

@return true or false
-->
<xsl:function name="config:generate-hyperlinks" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/default/xrefs/@type = 'hyperlink'"/>
</xsl:function>

<!--
  Returns the style ID for the configured hyperlink style.

  @return the style ID
-->
<xsl:function name="config:hyperlink-styleid" as="xs:string">
  <xsl:variable name="style" select="if ($config-doc/config/default/xrefs/@hyperlinkstyle) then
    $config-doc/config/default/xrefs/@hyperlinkstyle else 'PS Hyperlink'"/>
  <xsl:variable name="styleid"
    select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style]/@w:styleId"/>
  <xsl:value-of select="if (string($styleid)!='') then $styleid else 'DefaultParagraphFont'" />
</xsl:function>

<!--
  Returns the style ID for the configured reference style.

  @return the style ID
-->
<xsl:function name="config:reference-styleid" as="xs:string">
  <xsl:variable name="style" select="if ($config-doc/config/default/xrefs/@referencestyle) then
    $config-doc/config/default/xrefs/@referencestyle else 'PS Reference'"/>
  <xsl:variable name="styleid"
    select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style]/@w:styleId"/>
  <xsl:value-of select="if (string($styleid)!='') then $styleid else 'DefaultParagraphFont'" />
</xsl:function>

<!--
  Returns the style ID for the configured xrefconfig reference style.

  @param document-label the document label
  @param config-name    the config attribute on the XRef

  @return the style ID
-->
<xsl:function name="config:xrefconfig-reference-styleid" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="config-name"/>

  <xsl:variable name="label-style" select="$config-doc/config/elements[@label = $document-label]/xref/xrefconfig[@name=$config-name]/@referencestyle"/>
  <xsl:variable name="nolabel-style" select="$config-doc/config/elements[not(@label)]/xref/xrefconfig[@name=$config-name]/@referencestyle"/>
  <xsl:variable name="default-style" select="if ($config-doc/config/default/xrefs/@referencestyle) then
    $config-doc/config/default/xrefs/@referencestyle else 'PS Reference'"/>
  <xsl:variable name="style" select="if ($label-style != '') then $label-style
    else if ($nolabel-style != '') then $nolabel-style else $default-style"/>
  <xsl:variable name="styleid"
    select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style]/@w:styleId"/>
  <xsl:value-of select="if (string($styleid)!='') then $styleid else 'DefaultParagraphFont'" />
</xsl:function>

<!--
  Returns the style ID for the configured xrefconfig hyperlink style.

  @param document-label the document label
  @param config-name    the config attribute on the XRef

  @return the style ID
-->
<xsl:function name="config:xrefconfig-hyperlink-styleid" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="config-name"/>

  <xsl:variable name="label-style" select="$config-doc/config/elements[@label = $document-label]/xref/xrefconfig[@name=$config-name]/@hyperlinkstyle"/>
  <xsl:variable name="nolabel-style" select="$config-doc/config/elements[not(@label)]/xref/xrefconfig[@name=$config-name]/@hyperlinkstyle"/>
  <xsl:variable name="default-style" select="if ($config-doc/config/default/xrefs/@hyperlinkstyle) then
    $config-doc/config/default/xrefs/@hyperlinkstyle else 'PS Hyperlink'"/>
  <xsl:variable name="style" select="if ($label-style != '') then $label-style
    else if ($nolabel-style != '') then $nolabel-style else $default-style"/>
  <xsl:variable name="styleid"
    select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style]/@w:styleId"/>
  <xsl:value-of select="if (string($styleid)!='') then $styleid else 'DefaultParagraphFont'" />
</xsl:function>

<!--
  Returns the confirmation of creation of comments.

  @return true or false
-->
<xsl:function name="config:generate-mathml" as="xs:boolean">
  <xsl:sequence select="$config-doc/config/default/mathml/@generate = 'true'"/>
</xsl:function>

<!--
  Returns the naming of docx files on export master (for backward compatibility only).

  @return type of export: 'uriid' or ''
-->
<xsl:function name="config:master-select" as="xs:string">
  <xsl:value-of select="if ($config-doc/config/default/master/@select = 'uriid') then 'uriid' else ''" />
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
  Returns the index document label configured.

  @return the document label
-->
<xsl:function name="config:index-documentlabel" as="xs:string">
  <xsl:value-of select="$config-doc/config/default/indexdoc/@documentlabel" />
</xsl:function>

<!--
  Returns the number of index columns configured (default 2).

  @return the number of columns
-->
<xsl:function name="config:index-columns" as="xs:integer">
  <xsl:variable name="columns" select="$config-doc/config/default/indexdoc/@columns" />
  <xsl:choose>
    <xsl:when test="$columns castable as xs:integer and
        xs:integer($columns) gt 0 and xs:integer($columns) lt 5">
      <xsl:value-of select="$columns" />
    </xsl:when>
    <xsl:otherwise>2</xsl:otherwise>
  </xsl:choose>
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
  Returns the document label and properties-fragment type specific property table style
  otherwise the document label specific property table style
  otherwise the document role specific property table style
  otherwise the default property table style
  otherwise the default paragraph style.

  @param document-label the document label
  @param type the properties-fragment type

  @return the word style ID or empty
-->
<xsl:function name="config:properties-table-style" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="type"/>
  <xsl:variable name="label-type-style" select="$config-doc/config/elements[@label = $document-label]/properties-fragments/properties-fragment[@type = $type]/@tablestyle"/>
  <xsl:variable name="label-style" select="$config-doc/config/elements[@label = $document-label]/properties-fragments/properties-fragment[not(@type)]/@tablestyle"/>
  <xsl:variable name="type-style" select="$config-doc/config/elements[not(@label)]/properties-fragments/properties-fragment[@type = $type]/@tablestyle"/>
  <xsl:variable name="default-style" select="$config-doc/config/elements[not(@label)]/properties-fragments/properties-fragment[not(@type)]/@tablestyle"/>
  <xsl:variable name="style-name">
    <xsl:choose>
      <xsl:when test="$label-type-style != ''">
        <xsl:value-of select="$label-type-style" />
      </xsl:when>
      <xsl:when test="$label-style != ''">
        <xsl:value-of select="$label-style" />
      </xsl:when>
      <xsl:when test="$type-style != ''">
        <xsl:value-of select="$type-style" />
      </xsl:when>
      <xsl:when test="$default-style != ''">
        <xsl:value-of select="$default-style" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$default-paragraph-style" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="string(document(concat($_dotxfolder, $styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $style-name]/@w:styleId)"/>
</xsl:function>

<!--
  Returns the document label and properties-fragment type specific property table width
  otherwise the document label specific property table width
  otherwise the document role specific property table width
  otherwise the default property table width.

  @param document-label the document label
  @param type the properties-fragment type

  @return the width value or empty
-->
<xsl:function name="config:properties-table-width" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="type"/>
  <xsl:variable name="label-type-width" select="$config-doc/config/elements[@label = $document-label]/properties-fragments/properties-fragment[@type = $type]/width/@value"/>
  <xsl:variable name="label-width" select="$config-doc/config/elements[@label = $document-label]/properties-fragments/properties-fragment[not(@type)]/width/@value"/>
  <xsl:variable name="type-width" select="$config-doc/config/elements[not(@label)]/properties-fragments/properties-fragment[@type = $type]/width/@value"/>
  <xsl:variable name="default-width" select="$config-doc/config/elements[not(@label)]/properties-fragments/properties-fragment[not(@type)]/width/@value"/>
  <xsl:choose>
    <xsl:when test="$label-type-width != ''">
      <xsl:value-of select="$label-type-width" />
    </xsl:when>
    <xsl:when test="$label-width != ''">
      <xsl:value-of select="$label-width" />
    </xsl:when>
    <xsl:when test="$type-width != ''">
      <xsl:value-of select="$type-width" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$default-width" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label and properties-fragment type specific property table width type
  otherwise the document label specific property table width type
  otherwise the document role specific property table width type
  otherwise the default property table width type.

  @param document-label the document label
  @param type the properties-fragment type

  @return the width type or empty
-->
<xsl:function name="config:properties-table-width-type" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="type"/>
  <xsl:variable name="label-type-width" select="$config-doc/config/elements[@label = $document-label]/properties-fragments/properties-fragment[@type = $type]/width/@type"/>
  <xsl:variable name="label-width" select="$config-doc/config/elements[@label = $document-label]/properties-fragments/properties-fragment[not(@type)]/width/@type"/>
  <xsl:variable name="type-width" select="$config-doc/config/elements[not(@label)]/properties-fragments/properties-fragment[@type = $type]/width/@type"/>
  <xsl:variable name="default-width" select="$config-doc/config/elements[not(@label)]/properties-fragments/properties-fragment[not(@type)]/width/@type"/>
  <xsl:choose>
    <xsl:when test="$label-type-width != ''">
      <xsl:value-of select="$label-type-width" />
    </xsl:when>
    <xsl:when test="$label-width != ''">
      <xsl:value-of select="$label-width" />
    </xsl:when>
    <xsl:when test="$type-width != ''">
      <xsl:value-of select="$type-width" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$default-width" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


  <!--
    Returns the document label and properties-fragment type specific property title style
    otherwise the document label specific property title style
    otherwise the document role specific property title style
    otherwise the default property title style
    otherwise the default paragraph style.

    @param document-label the document label
    @param type the properties-fragment type

    @return the word style ID or empty
  -->
<xsl:function name="config:properties-title-style" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="type"/>
  <xsl:variable name="label-type-style" select="$config-doc/config/elements[@label = $document-label]/properties-fragments/properties-fragment[@type = $type]/@titlestyle"/>
  <xsl:variable name="label-style" select="$config-doc/config/elements[@label = $document-label]/properties-fragments/properties-fragment[not(@type)]/@titlestyle"/>
  <xsl:variable name="type-style" select="$config-doc/config/elements[not(@label)]/properties-fragments/properties-fragment[@type = $type]/@titlestyle"/>
  <xsl:variable name="default-style" select="$config-doc/config/elements[not(@label)]/properties-fragments/properties-fragment[not(@type)]/@titlestyle"/>
  <xsl:variable name="style-name">
    <xsl:choose>
      <xsl:when test="$label-type-style != ''">
        <xsl:value-of select="$label-type-style" />
      </xsl:when>
      <xsl:when test="$label-style != ''">
        <xsl:value-of select="$label-style" />
      </xsl:when>
      <xsl:when test="$type-style != ''">
        <xsl:value-of select="$type-style" />
      </xsl:when>
      <xsl:when test="$default-style != ''">
        <xsl:value-of select="$default-style" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$default-paragraph-style" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="string(document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style-name]/@w:styleId)"/>
</xsl:function>

<!--
  Returns the document label and properties-fragment type specific property value style
  otherwise the document label specific property value style
  otherwise the document role specific property value style
  otherwise the default property value style
  otherwise the default paragraph style.

  @param document-label the document label
  @param type the properties-fragment type

  @return the word style ID or empty
-->
<xsl:function name="config:properties-value-style" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="type"/>
  <xsl:variable name="style-name" select="config:properties-value-style-name($document-label, $type)" />
  <xsl:value-of select="string(document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style-name]/@w:styleId)"/>
</xsl:function>

<!--
  Returns the document label and properties-fragment type specific property value style
  otherwise the document label specific property value style
  otherwise the document role specific property value style
  otherwise the default property value style
  otherwise the default paragraph style.

  @param document-label the document label
  @param type the properties-fragment type

  @return the word style name or empty
-->
<xsl:function name="config:properties-value-style-name" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="type"/>
  <xsl:variable name="label-type-style" select="$config-doc/config/elements[@label = $document-label]/properties-fragments/properties-fragment[@type = $type]/@valuestyle"/>
  <xsl:variable name="label-style" select="$config-doc/config/elements[@label = $document-label]/properties-fragments/properties-fragment[not(@type)]/@valuestyle"/>
  <xsl:variable name="type-style" select="$config-doc/config/elements[not(@label)]/properties-fragments/properties-fragment[@type = $type]/@valuestyle"/>
  <xsl:variable name="default-style" select="$config-doc/config/elements[not(@label)]/properties-fragments/properties-fragment[not(@type)]/@valuestyle"/>
  <xsl:choose>
    <xsl:when test="$label-type-style != ''">
      <xsl:value-of select="$label-type-style" />
    </xsl:when>
    <xsl:when test="$label-style != ''">
      <xsl:value-of select="$label-style" />
    </xsl:when>
    <xsl:when test="$type-style != ''">
      <xsl:value-of select="$type-style" />
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

  @return the word style name
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

  @return the word style name
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
  Returns the document label and table role specific table layout
  otherwise the document label specific table layout
  otherwise the document role specific table layout
  otherwise the default table layout
  otherwise empty.

  @param document-label the document label
  @param role the table role

  @return the table layout or empty
-->
<xsl:function name="config:table-layout" as="xs:string?">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:variable name="label-role-layout" select="$config-doc/config/elements[@label = $document-label]/tables/table[@role = $role]/@layout"/>
  <xsl:variable name="label-layout" select="$config-doc/config/elements[@label = $document-label]/tables/table[@default]/@layout"/>
  <xsl:variable name="role-layout" select="$config-doc/config/elements[not(@label)]/tables/table[@role = $role]/@layout"/>
  <xsl:variable name="default-layout" select="$config-doc/config/elements[not(@label)]/tables/table[@default]/@layout"/>
  <xsl:choose>
    <xsl:when test="$label-role-layout != ''">
      <xsl:value-of select="$label-role-layout" />
    </xsl:when>
    <xsl:when test="$label-layout != ''">
      <xsl:value-of select="$label-layout" />
    </xsl:when>
    <xsl:when test="$role-layout != ''">
      <xsl:value-of select="$role-layout" />
    </xsl:when>
    <xsl:when test="$default-layout != ''">
      <xsl:value-of select="$default-layout" />
    </xsl:when>
    <xsl:otherwise></xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label and col role specific col config
  otherwise the document label specific col config
  otherwise the document role specific col config
  otherwise the default col config
  otherwise nothing.

  col config format:
  <col role="[col role]">
    <shading fill="" />
    <borders value="[top][,][bottom][,][start][,][end]"/>
  </col>

  @param document-label the document label
  @param role the table role

  @return the col config or nothing
-->
<xsl:function name="config:table-col" as="element(col)?">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:variable name="label-role-config" select="$config-doc/config/elements[@label = $document-label]/tables/col[@role = $role]"/>
  <xsl:variable name="label-config" select="$config-doc/config/elements[@label = $document-label]/tables/col[not(@role)]"/>
  <xsl:variable name="role-config" select="$config-doc/config/elements[not(@label)]/tables/col[@role = $role]"/>
  <xsl:variable name="default-config" select="$config-doc/config/elements[not(@label)]/tables/col[not(@role)]"/>
  <xsl:choose>
    <xsl:when test="$label-role-config">
      <xsl:sequence select="$label-role-config" />
    </xsl:when>
    <xsl:when test="$label-config">
      <xsl:sequence select="$label-config" />
    </xsl:when>
    <xsl:when test="$role-config">
      <xsl:sequence select="$role-config" />
    </xsl:when>
    <xsl:when test="$default-config">
      <xsl:sequence select="$default-config" />
    </xsl:when>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label and row role specific row config
  otherwise the document label specific row config
  otherwise the document role specific row config
  otherwise the default row config
  otherwise nothing.

  Row config format:
  <row role="[row role]"
       cansplit="[true|false]"
       align="[center|start|end]">
    <height type="[atleast|exact]" value=""/>
    <shading fill="" />
    <borders value="[top][,][bottom][,][start][,][end]"/>
  </row>

  @param document-label the document label
  @param role the table role

  @return the row config or nothing
-->
<xsl:function name="config:table-row" as="element(row)?">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:variable name="label-role-config" select="$config-doc/config/elements[@label = $document-label]/tables/row[@role = $role]"/>
  <xsl:variable name="label-config" select="$config-doc/config/elements[@label = $document-label]/tables/row[not(@role)]"/>
  <xsl:variable name="role-config" select="$config-doc/config/elements[not(@label)]/tables/row[@role = $role]"/>
  <xsl:variable name="default-config" select="$config-doc/config/elements[not(@label)]/tables/row[not(@role)]"/>
  <xsl:choose>
    <xsl:when test="$label-role-config">
      <xsl:sequence select="$label-role-config" />
    </xsl:when>
    <xsl:when test="$label-config">
      <xsl:sequence select="$label-config" />
    </xsl:when>
    <xsl:when test="$role-config">
      <xsl:sequence select="$role-config" />
    </xsl:when>
    <xsl:when test="$default-config">
      <xsl:sequence select="$default-config" />
    </xsl:when>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label and hcell role specific hcell config
  otherwise the document label specific hcell config
  otherwise the document role specific hcell config
  otherwise the default hcell config
  otherwise nothing.

  Hcell config format:
  <hcell role="[hcell role]"
       valign="[bottom|center|top]">
    <width type="[dxa|pct|auto]" value=""/>
    <shading fill="" />
    <borders value="[top][,][bottom][,][start][,][end]"/>
  </hcell>

  @param document-label the document label
  @param role the table role

  @return the hcell config or nothing
-->
<xsl:function name="config:table-hcell" as="element(hcell)?">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:variable name="label-role-config" select="$config-doc/config/elements[@label = $document-label]/tables/hcell[@role = $role]"/>
  <xsl:variable name="label-config" select="$config-doc/config/elements[@label = $document-label]/tables/hcell[not(@role)]"/>
  <xsl:variable name="role-config" select="$config-doc/config/elements[not(@label)]/tables/hcell[@role = $role]"/>
  <xsl:variable name="default-config" select="$config-doc/config/elements[not(@label)]/tables/hcell[not(@role)]"/>
  <xsl:choose>
    <xsl:when test="$label-role-config">
      <xsl:sequence select="$label-role-config" />
    </xsl:when>
    <xsl:when test="$label-config">
      <xsl:sequence select="$label-config" />
    </xsl:when>
    <xsl:when test="$role-config">
      <xsl:sequence select="$role-config" />
    </xsl:when>
    <xsl:when test="$default-config">
      <xsl:sequence select="$default-config" />
    </xsl:when>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label and cell role specific cell config
  otherwise the document label specific cell config
  otherwise the document role specific cell config
  otherwise the default cell config
  otherwise nothing.

  Cell config format:
  <cell role="[cell role]"
       valign="[bottom|center|top]">
    <width type="[dxa|pct|auto]" value=""/>
    <shading fill="" />
    <borders value="[top][,][bottom][,][start][,][end]"/>
  </cell>

  @param document-label the document label
  @param role the table role

  @return the cell config or nothing
-->
<xsl:function name="config:table-cell" as="element(cell)?">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:variable name="label-role-config" select="$config-doc/config/elements[@label = $document-label]/tables/cell[@role = $role]"/>
  <xsl:variable name="label-config" select="$config-doc/config/elements[@label = $document-label]/tables/cell[not(@role)]"/>
  <xsl:variable name="role-config" select="$config-doc/config/elements[not(@label)]/tables/cell[@role = $role]"/>
  <xsl:variable name="default-config" select="$config-doc/config/elements[not(@label)]/tables/cell[not(@role)]"/>
  <xsl:choose>
    <xsl:when test="$label-role-config">
      <xsl:sequence select="$label-role-config" />
    </xsl:when>
    <xsl:when test="$label-config">
      <xsl:sequence select="$label-config" />
    </xsl:when>
    <xsl:when test="$role-config">
      <xsl:sequence select="$role-config" />
    </xsl:when>
    <xsl:when test="$default-config">
      <xsl:sequence select="$default-config" />
    </xsl:when>
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
  Returns the configured style for ps:image element for label specific documents.

  @param document-label the document label
  @return the w:style
-->
<xsl:function name="config:image-wordstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label]/image/@wordstyle)" />
</xsl:function>

<!--
  Returns the configured style for ps:image element for default documents.

  @return the w:style
-->
<xsl:function name="config:image-wordstyle-for-default-document" as="xs:string">
  <xsl:value-of select="string($config-doc/config/elements[not(@label)]/image/@wordstyle)" />
</xsl:function>

<!--
  Returns the configured maximum width for ps:image element for label specific documents
  with fall back to default configuration.

  @param document-label the document label
  @return the  maximum width in pixels
-->
<xsl:function name="config:image-maxwidth" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:variable name="specificmax"
                select="string($config-doc/config/elements[@label = $document-label]/image/@maxwidth)" />
  <xsl:variable name="defaultmax"
                select="string($config-doc/config/elements[not(@label)]/image/@maxwidth)" />
  <xsl:choose>
    <xsl:when test="not($document-label = '' or $specificmax = '')">
      <xsl:value-of select="$specificmax" />
    </xsl:when>
    <xsl:when test="not($defaultmax = '')">
      <xsl:value-of select="$defaultmax" />
    </xsl:when>
    <xsl:otherwise>620</xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured image label which will ignore image maxwidth.

  @param document-label the document label
  @return the label
-->
<xsl:function name="config:image-widelabel" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:variable name="specificlabel"
                select="string($config-doc/config/elements[@label = $document-label]/image/@widelabel)" />
  <xsl:choose>
    <xsl:when test="not($document-label = '' or $specificlabel = '')">
      <xsl:value-of select="$specificlabel" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="string($config-doc/config/elements[not(@label)]/image/@widelabel)" />
    </xsl:otherwise>
  </xsl:choose>
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
  <xsl:value-of select="if ($style = 'generate-ps-style') then concat('ps_inl_', $inline-label) else string($style)"/>
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
  Returns the configured w:style for ps:heading element with block labels and document label.

  @param document-label the block label
  @param document-label the document label
  @param heading-level the current heading level
  @param numbered the numbered attribute value of the heading
  @param prefix the prefix attribute value of the heading

  @return the w:style
-->
<xsl:function name="config:heading-wordstyle-for-block-label-document-label" as="xs:string">
  <xsl:param name="block-label"/>
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label
][@blocklabel = $block-label]/heading/level[if($numbered)
then (@numbered = $numbered) else not(@numbered='true')][if($prefix)
then @prefixed='true' else not(@prefixed='true')][@value=$heading-level]/@wordstyle)" />
</xsl:function>

<!--
  Returns the configured w:style for ps:heading element with fragment labels and document label.

  @param document-label the fragment label
  @param document-label the document label
  @param heading-level the current heading level
  @param numbered the numbered attribute value of the heading
  @param prefix the prefix attribute value of the heading

  @return the w:style
-->
<xsl:function name="config:heading-wordstyle-for-fragment-label-document-label" as="xs:string">
  <xsl:param name="fragment-label"/>
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label
][@fragmentlabel = $fragment-label]/heading/level[if($numbered)
then (@numbered = $numbered) else not(@numbered='true')][if($prefix)
then @prefixed='true' else not(@prefixed='true')][@value=$heading-level]/@wordstyle)" />
</xsl:function>

<!--
  Returns the configured w:style for ps:heading element with block labels in default documents.

  @param document-label the block label
  @param heading-level the current heading level
  @param numbered the numbered attribute value of the heading
  @param prefix the prefix attribute value of the heading

  @return the w:style
-->
<xsl:function name="config:heading-wordstyle-for-block-label" as="xs:string">
  <xsl:param name="block-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:value-of select="string($config-doc/config/elements[not(@label)
  ][@blocklabel = $block-label]/heading/level[if($numbered)
  then (@numbered = $numbered) else not(@numbered='true')][if($prefix)
  then @prefixed='true' else not(@prefixed='true')][@value=$heading-level]/@wordstyle)" />
</xsl:function>

<!--
  Returns the configured w:style for ps:heading element with fragment labels in default documents.

  @param document-label the fragment label
  @param heading-level the current heading level
  @param numbered the numbered attribute value of the heading
  @param prefix the prefix attribute value of the heading

  @return the w:style
-->
<xsl:function name="config:heading-wordstyle-for-fragment-label" as="xs:string">
  <xsl:param name="fragment-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:value-of select="string($config-doc/config/elements[not(@label)
][@fragmentlabel = $fragment-label]/heading/level[if($numbered)
then (@numbered = $numbered) else not(@numbered='true')][if($prefix)
then @prefixed='true' else not(@prefixed='true')][@value=$heading-level]/@wordstyle)" />
</xsl:function>

<!--
  Returns the configured w:style for ps:heading element for label specific documents.

  @param document-label the document label
  @param heading-level the current heading level
  @param numbered the numbered attribute value of the heading
  @param prefix the prefix attribute value of the heading

  @return the w:style
-->
<xsl:function name="config:heading-wordstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:value-of select="string($config-doc/config/elements[@label = $document-label
    ][not(@blocklabel)][not(@fragmentlabel)]/heading/level[if($numbered)
    then (@numbered = $numbered) else not(@numbered='true')][if($prefix)
    then @prefixed='true' else not(@prefixed='true')][@value=$heading-level]/@wordstyle)" />
</xsl:function>

<!--
  Returns the configured w:style for ps:heading element for default documents.

  @param heading-level the current heading level
  @param numbered the numbered attribute value of the heading
  @param prefix the prefix attribute value of the heading

  @return the w:style
-->
<xsl:function name="config:heading-wordstyle-for-default-document" as="xs:string">
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:value-of select="string($config-doc/config/elements[not(@label)
    ][not(@blocklabel)][not(@fragmentlabel)]/heading/level[if($numbered)
    then (@numbered = $numbered) else not(@numbered='true')][if($prefix)
    then @prefixed='true' else not(@prefixed='true')][@value=$heading-level]/@wordstyle)" />
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
  <xsl:sequence select="exists($config-doc/config/elements[@label = $document-label]/block/label[@value=$label]/keep-paragraph-with-next)"/>
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
  Returns the list paragraph w:style for the given list w:style
  NOTE: Returns a style ID not name.

  @param list-style-name the list style name
  @param list-level the current list level

  @return the w:style ID
-->
<xsl:function name="config:list-paragraphstyle-for-list-style" as="xs:string">
  <xsl:param name="list-style-name"/>
  <xsl:param name="list-level"/>

  <xsl:variable name="list-style" select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $list-style-name]/@w:styleId"/>
  <xsl:variable name="abstract-num" select="document(concat($_dotxfolder, $numbering-template))//w:abstractNum[w:styleLink/@w:val = $list-style]"/>
  <xsl:variable name="para-style" select="$abstract-num/w:lvl[@w:ilvl=number($list-level - 1)]/w:pStyle/@w:val" />
  <xsl:value-of select="if ($para-style) then $para-style else ''"/>
</xsl:function>

<!--
  Returns the configured ps:list paragraph w:style for block label specific documents
  NOTE: Returns a style ID not name.

  @param block-label the current block label
  @param document-label the current document label
  @param list-role the current list role
  @param list-level the current list level
  @param list-type list or nlist

  @return the w:style ID
-->
<xsl:function name="config:list-paragraphstyle-for-block-label-document-label" as="xs:string">
  <xsl:param name="block-label"/>
  <xsl:param name="document-label"/>
  <xsl:param name="list-role"/>
  <xsl:param name="list-level"/>
  <xsl:param name="list-type"/>

  <xsl:variable name="list-style" select="config:list-style-for-block-label-document-label($block-label, $document-label, $list-role, $list-type)" />
  <xsl:value-of select="config:list-paragraphstyle-for-list-style($list-style, $list-level)" />
</xsl:function>

<!--
  Returns the configured ps:list paragraph w:style for block label default documents
  NOTE: Returns a style ID not name.

  @param block-label the current block label
  @param list-role the current list role
  @param list-level the current list level
  @param list-type list or nlist

  @return the w:style ID
-->
<xsl:function name="config:list-paragraphstyle-for-block-label" as="xs:string">
  <xsl:param name="block-label"/>
  <xsl:param name="list-role"/>
  <xsl:param name="list-level"/>
  <xsl:param name="list-type"/>

  <xsl:variable name="list-style" select="config:list-style-for-block-label($block-label, $list-role, $list-type)" />
  <xsl:value-of select="config:list-paragraphstyle-for-list-style($list-style, $list-level)" />
</xsl:function>

<!--
  Returns the configured ps:list paragraph w:style for fragment label specific documents
  NOTE: Returns a style ID not name.

  @param fragment-label the current fragment label
  @param document-label the current document label
  @param list-role the current list role
  @param list-level the current list level
  @param list-type list or nlist

  @return the w:style ID
-->
<xsl:function name="config:list-paragraphstyle-for-fragment-label-document-label" as="xs:string">
  <xsl:param name="fragment-label"/>
  <xsl:param name="document-label"/>
  <xsl:param name="list-role"/>
  <xsl:param name="list-level"/>
  <xsl:param name="list-type"/>

  <xsl:variable name="list-style" select="config:list-style-for-fragment-label-document-label($fragment-label, $document-label, $list-role, $list-type)" />
  <xsl:value-of select="config:list-paragraphstyle-for-list-style($list-style, $list-level)" />
</xsl:function>

<!--
  Returns the configured ps:list paragraph w:style for fragment label default documents
  NOTE: Returns a style ID not name.

  @param fragment-label the current fragment label
  @param list-role the current list role
  @param list-level the current list level
  @param list-type list or nlist

  @return the w:style ID
-->
<xsl:function name="config:list-paragraphstyle-for-fragment-label" as="xs:string">
  <xsl:param name="fragment-label"/>
  <xsl:param name="list-role"/>
  <xsl:param name="list-level"/>
  <xsl:param name="list-type"/>

  <xsl:variable name="list-style" select="config:list-style-for-fragment-label($fragment-label, $list-role, $list-type)" />
  <xsl:value-of select="config:list-paragraphstyle-for-list-style($list-style, $list-level)" />
</xsl:function>

<!--
  Returns the configured ps:list paragraph w:style for document label specific documents
  NOTE: Returns a style ID not name.

  @param document-label the current document label
  @param list-role the current list role
  @param list-level the current list level
  @param list-type list or nlist

  @return the w:style ID
-->
<xsl:function name="config:list-paragraphstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="list-role"/>
  <xsl:param name="list-level"/>
  <xsl:param name="list-type"/>

  <xsl:variable name="list-style" select="config:list-style-for-document-label($document-label, $list-role, $list-type)" />
  <xsl:value-of select="config:list-paragraphstyle-for-list-style($list-style, $list-level)" />
</xsl:function>

<!--
  Returns the configured ps:list paragraph w:style for default documents
  NOTE: Returns a style ID not name.

  @param list-role the current list role
  @param list-level the current list level
  @param list-type list or nlist

  @return the w:style ID
-->
<xsl:function name="config:list-paragraphstyle-for-default-document" as="xs:string">
  <xsl:param name="list-role"/>
  <xsl:param name="list-level"/>
  <xsl:param name="list-type"/>

  <xsl:variable name="list-style" select="config:list-style-for-default-document($list-role, $list-type)" />
  <xsl:value-of select="config:list-paragraphstyle-for-list-style($list-style, $list-level)" />
</xsl:function>

<!--
  Returns the configured ps:list  w:style for block label specific documents

  @param block-label the current block label
  @param document-label the current document label
  @param list-role the current list role

  @return the w:style
-->
<xsl:function name="config:list-style-for-block-label-document-label" as="xs:string">
  <xsl:param name="block-label"/>
  <xsl:param name="document-label"/>
  <xsl:param name="list-role"/>
  <xsl:param name="list-type"/>
  <xsl:choose>
    <xsl:when test="$list-role != '' and $config-doc/config/elements[@label = $document-label
      ][@blocklabel = $block-label]/*[name() = $list-type]/role[@value=$list-role]/@liststyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label
        ][@blocklabel = $block-label]/*[name() = $list-type]/role[@value=$list-role]/@liststyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[@label = $document-label
      ][@blocklabel = $block-label]/*[name() = $list-type]/@liststyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label
        ][@blocklabel = $block-label]/*[name() = $list-type]/@liststyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:list  w:style for block label default documents

  @param block-label the current block label
  @param list-role the current list role

  @return the w:style
-->
<xsl:function name="config:list-style-for-block-label" as="xs:string">
  <xsl:param name="block-label"/>
  <xsl:param name="list-role"/>
  <xsl:param name="list-type"/>
  <xsl:choose>
    <xsl:when test="$list-role != '' and $config-doc/config/elements[not(@label)
        ][@blocklabel = $block-label]/*[name() = $list-type]/role[@value=$list-role]/@liststyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)
          ][@blocklabel = $block-label]/*[name() = $list-type]/role[@value=$list-role]/@liststyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)
        ][@blocklabel = $block-label]/*[name() = $list-type]/@liststyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)
          ][@blocklabel = $block-label]/*[name() = $list-type]/@liststyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:list  w:style for fragment label specific documents

  @param fragment-label the current fragment label
  @param document-label the current document label
  @param list-role the current list role

  @return the w:style
-->
<xsl:function name="config:list-style-for-fragment-label-document-label" as="xs:string">
  <xsl:param name="fragment-label"/>
  <xsl:param name="document-label"/>
  <xsl:param name="list-role"/>
  <xsl:param name="list-type"/>
  <xsl:choose>
    <xsl:when test="$list-role != '' and $config-doc/config/elements[@label = $document-label
    ][@fragmentlabel = $fragment-label]/*[name() = $list-type]/role[@value=$list-role]/@liststyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label
      ][@fragmentlabel = $fragment-label]/*[name() = $list-type]/role[@value=$list-role]/@liststyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[@label = $document-label
    ][@fragmentlabel = $fragment-label]/*[name() = $list-type]/@liststyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label
      ][@fragmentlabel = $fragment-label]/*[name() = $list-type]/@liststyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:list  w:style for fragment label default documents

  @param fragment-label the current fragment label
  @param list-role the current list role

  @return the w:style
-->
<xsl:function name="config:list-style-for-fragment-label" as="xs:string">
  <xsl:param name="fragment-label"/>
  <xsl:param name="list-role"/>
  <xsl:param name="list-type"/>
  <xsl:choose>
    <xsl:when test="$list-role != '' and $config-doc/config/elements[not(@label)
      ][@fragmentlabel = $fragment-label]/*[name() = $list-type]/role[@value=$list-role]/@liststyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)
        ][@fragmentlabel = $fragment-label]/*[name() = $list-type]/role[@value=$list-role]/@liststyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)
      ][@fragmentlabel = $fragment-label]/*[name() = $list-type]/@liststyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)
        ][@fragmentlabel = $fragment-label]/*[name() = $list-type]/@liststyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:list  w:style for document label specific documents

  @param document-label the current document label
  @param list-role the current list role

  @return the w:style
-->
<xsl:function name="config:list-style-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="list-role"/>
  <xsl:param name="list-type"/>
  <xsl:choose>
    <xsl:when test="$list-role != '' and $config-doc/config/elements[@label = $document-label
        ][not(@blocklabel)][not(@fragmentlabel)][not(@fragmentlabel)]/*[name() = $list-type]/role[@value=$list-role]/@liststyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label
          ][not(@blocklabel)][not(@fragmentlabel)][not(@fragmentlabel)]/*[name() = $list-type]/role[@value=$list-role]/@liststyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[@label = $document-label
        ][not(@blocklabel)][not(@fragmentlabel)][not(@fragmentlabel)]/*[name() = $list-type]/@liststyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label
          ][not(@blocklabel)][not(@fragmentlabel)][not(@fragmentlabel)]/*[name() = $list-type]/@liststyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:list w:style for default documents

  @param list-role the current list role

  @return the w:style
-->
<xsl:function name="config:list-style-for-default-document" as="xs:string">
  <xsl:param name="list-role"/>
  <xsl:param name="list-type"/>
  <xsl:choose>
    <xsl:when test="$list-role != '' and $config-doc/config/elements[not(@label)
        ][not(@blocklabel)][not(@fragmentlabel)]/*[name() = $list-type]/role[@value=$list-role]/@liststyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)
          ][not(@blocklabel)][not(@fragmentlabel)]/*[name() = $list-type]/role[@value=$list-role]/@liststyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)
        ][not(@blocklabel)][not(@fragmentlabel)]/*[name() = $list-type]/@liststyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)
          ][not(@blocklabel)][not(@fragmentlabel)]/*[name() = $list-type]/@liststyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:para w:style for a specific block label and document label

  @param block-label the closest ancestor block label
  @param document-label the current document label
  @param indent-level the current ps:para indent level
  @param numbered the @ps:numbered attribute of the ps:para
  @param prefix the current ps:para prefix

  @return the w:style
-->
<xsl:function name="config:para-wordstyle-for-block-label-document-label" as="xs:string">
  <xsl:param name="block-label"/>
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:variable name="indent" select="$config-doc/config/elements[@label = $document-label
    ][@blocklabel = $block-label]/para/indent[if($numbered)
    then (@numbered = $numbered) else not(@numbered='true')][if($prefix)
    then @prefixed='true' else not(@prefixed='true')]"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $indent[@level='0']/@wordstyle">
      <xsl:value-of select="$indent[@level='0'][1]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$indent[@level=$indent-level]/@wordstyle">
      <xsl:value-of select="$indent[@level=$indent-level][1]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

  <!--
  Returns the configured ps:para w:style for a specific block label

  @param block-label the closest ancestor block label
  @param indent-level the current ps:para indent level
  @param numbered the @ps:numbered attribute of the ps:para
  @param prefix the current ps:para prefix

  @return the w:style
-->
<xsl:function name="config:para-wordstyle-for-block-label" as="xs:string">
  <xsl:param name="block-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:variable name="indent" select="$config-doc/config/elements[not(@label)
  ][@blocklabel = $block-label]/para/indent[if($numbered)
  then (@numbered = $numbered) else not(@numbered='true')][if($prefix)
  then @prefixed='true' else not(@prefixed='true')]"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $indent[@level='0']/@wordstyle">
      <xsl:value-of select="$indent[@level='0'][1]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$indent[@level=$indent-level]/@wordstyle">
      <xsl:value-of select="$indent[@level=$indent-level][1]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:para w:style for a specific fragment label and document label

  @param fragment-label the closest ancestor fragment label
  @param document-label the current document label
  @param indent-level the current ps:para indent level
  @param numbered the @ps:numbered attribute of the ps:para
  @param prefix the current ps:para prefix

  @return the w:style
-->
<xsl:function name="config:para-wordstyle-for-fragment-label-document-label" as="xs:string">
  <xsl:param name="fragment-label"/>
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:variable name="indent" select="$config-doc/config/elements[@label = $document-label
  ][@fragmentlabel = $fragment-label]/para/indent[if($numbered)
  then (@numbered = $numbered) else not(@numbered='true')][if($prefix)
  then @prefixed='true' else not(@prefixed='true')]"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $indent[@level='0']/@wordstyle">
      <xsl:value-of select="$indent[@level='0'][1]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$indent[@level=$indent-level]/@wordstyle">
      <xsl:value-of select="$indent[@level=$indent-level][1]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:para w:style for a specific fragment label

  @param fragment-label the closest ancestor fragment label
  @param indent-level the current ps:para indent level
  @param numbered the @ps:numbered attribute of the ps:para
  @param prefix the current ps:para prefix

  @return the w:style
-->
<xsl:function name="config:para-wordstyle-for-fragment-label" as="xs:string">
  <xsl:param name="fragment-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:variable name="indent" select="$config-doc/config/elements[not(@label)
  ][@fragmentlabel = $fragment-label]/para/indent[if($numbered)
  then (@numbered = $numbered) else not(@numbered='true')][if($prefix)
  then @prefixed='true' else not(@prefixed='true')]"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $indent[@level='0']/@wordstyle">
      <xsl:value-of select="$indent[@level='0'][1]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$indent[@level=$indent-level]/@wordstyle">
      <xsl:value-of select="$indent[@level=$indent-level][1]/@wordstyle" />
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
  @param prefix the current ps:para prefix

  @return the w:style
-->
<xsl:function name="config:para-wordstyle-for-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:variable name="indent" select="$config-doc/config/elements[@label = $document-label
    ][not(@blocklabel)][not(@fragmentlabel)]/para/indent[if($numbered)
    then (@numbered = $numbered) else not(@numbered='true')][if($prefix)
    then @prefixed='true' else not(@prefixed='true')]"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $indent[@level='0']/@wordstyle">
      <xsl:value-of select="$indent[@level='0'][1]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$indent[@level=$indent-level]/@wordstyle">
      <xsl:value-of select="$indent[@level=$indent-level][1]/@wordstyle" />
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
  @param prefix the current ps:para prefix

  @return the w:style
-->
<xsl:function name="config:para-wordstyle-for-default-document" as="xs:string">
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:variable name="indent" select="$config-doc/config/elements[not(@label)
    ][not(@blocklabel)][not(@fragmentlabel)]/para/indent[if($numbered)
    then (@numbered = $numbered) else not(@numbered='true')][if($prefix)
    then @prefixed='true' else not(@prefixed='true')]"/>
  <xsl:choose>
    <xsl:when test="not($indent-level) and $indent[@level='0']/@wordstyle">
      <xsl:value-of select="$indent[@level='0'][1]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$indent[@level=$indent-level]/@wordstyle">
      <xsl:value-of select="$indent[@level=$indent-level][1]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

</xsl:stylesheet>