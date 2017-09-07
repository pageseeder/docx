<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module containing global variables and functions.

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"
                xmlns:fn="http://www.pageseeder.com/function"
                exclude-result-prefixes="#all">

<!-- The location of the Content_Types.xml file -->
<xsl:variable name="_content-types-template" select="concat($_dotxfolder, encode-for-uri('[Content_Types].xml'))" as="xs:string"/>

<!-- The location of the document.xml.rels file -->
<xsl:variable name="_document-relationship" select="concat($_dotxfolder, encode-for-uri('word/_rels/document.xml.rels'))" as="xs:string"/>

<!-- The name of the docx file -->
<xsl:variable name="filename" select="substring-before($_docxfilename,'.docx')" as="xs:string"/>

<!-- The document node of the numbering template -->
<xsl:variable name="numbering-template" select="document($_content-types-template)/ct:Types/ct:Override[fn:string-after-last-delimiter(@ContentType,'\.') = 'numbering+xml']/@PartName" />

<!-- The location of the styles template -->
<xsl:variable name="styles-template" select="'/word/styles.xml'" as="xs:string"/>

<!-- The document node of the configuration file -->
<xsl:variable name="config-doc" select="document($_configfileurl)" />

<!-- The value of the creator property -->
<xsl:variable name="creator">
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
</xsl:variable>

<!-- The value of the revision property -->
<xsl:variable name="revision">
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
</xsl:variable>

<!-- The value of the description property -->
<xsl:variable name="description">
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
</xsl:variable>

<!-- The value of the subject property -->
<xsl:variable name="subject">
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
</xsl:variable>

<!-- The value of the title property -->
<xsl:variable name="title">
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
</xsl:variable>

<!-- The value of the category property -->
<xsl:variable name="category">
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
</xsl:variable>

<!-- The value of the version property -->
<xsl:variable name="version">
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
</xsl:variable>

<!-- The word style of the configuration file for xref elements -->
<xsl:variable name="xref-style" as="xs:string">
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements/xref">
      <xsl:value-of select="$config-doc/config/elements/xref/@style"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- Node containing all inline label configured values -->
<xsl:variable name="inline-labels" as="element()">
  <inlinelabels>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements/inline[@default = 'generate-ps-style']">
      <xsl:for-each select="document//inline">
        <xsl:choose>
          <xsl:when test="ancestor::document[1]/document/documentinfo/uri/labels">
            <!-- TODO Useless code -->
            <xsl:if test="$config-doc/config/elements[matches(@label,ancestor::document[1]/document/documentinfo/uri/labels)]/inline/@default != 'generate-ps-style'"/>
          </xsl:when>
          <xsl:when test="$config-doc/config/elements/inline/label[@value = current()/@label]"/>
          <xsl:when test="$config-doc/config/elements/inline/ignore[@value = current()/@label]"/>
          <xsl:when test="$config-doc/config/elements/inline/tab[@value = current()/@label]"/>
          <xsl:when test="@label[not(following::inline/@label = current()/@label)]">
            <label name="{@label}"/>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="$config-doc/config/elements/inline/label[@wordstyle = 'generate-ps-style']">
        <label name="{@value}"/>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
  </inlinelabels>
</xsl:variable>

<!-- TODO Simplify code for functions below -->
<!-- TODO Specify return type -->
<!-- TODO Move functions related specifically to the config to a separate module -->

<!-- Sequence of all inline labels that should create a tab -->
<xsl:function name="fn:default-tab-inline-labels">
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/inline/tab/@label">
      <xsl:for-each select="$config-doc/config/elements[not(@label)]/inline/tab/@label">
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:value-of select="concat('^',.,'$')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('^',.,'$','|')" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- Sequence of all inline labels that should create a tab specific for a document label-->
<xsl:function name="fn:tab-inline-labels-document">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/inline/tab/@label">
      <xsl:for-each select="$config-doc/config/elements[@label = $document-label]/inline/tab/@label">
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:value-of select="concat('^',.,'$')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('^',.,'$','|')" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- Node containing all block label configured values -->
<xsl:variable name="block-labels" as="element()">
  <blocklabels>
   <xsl:choose>
    <xsl:when test="$config-doc/config/elements/block[@default = 'generate-ps-style']">
      <xsl:for-each select="document//block">
        <xsl:variable name="documentLabel" select="ancestor::document[1]/document/documentinfo/uri/labels"/>
        <xsl:choose>
          <xsl:when test="$documentLabel != '' and $config-doc/config/elements[matches(@label,$documentLabel)]/block/@default != 'generate-ps-style'"/>
          <xsl:when test="$config-doc/config/elements/block/label[@value = current()/@label]"/>
          <xsl:when test="$config-doc/config/elements/block/ignore[@value = current()/@label]"/>
          <xsl:when test="$config-doc/config/elements/block/tab[@value = current()/@label]"/>
          <xsl:when test="@label[not(following::block/@label = current()/@label)]">
            <label name="{@label}"/>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
   </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="$config-doc/config/elements/block/label[@wordstyle = 'generate-ps-style']">
        <label name="{@value}"/>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
  </blocklabels>
</xsl:variable>

<!-- Node containing all lists and nlists in the current pageseeder document -->
<xsl:variable name="all-lists">
  <xsl:copy-of select="//*[name()='list' or name()='nlist'][not(ancestor::list or ancestor::nlist)]" />
</xsl:variable>

<!-- Number of all the lists -->
<xsl:variable name="num-all-lists">
  <xsl:value-of select="count($all-lists/*)" />
</xsl:variable>

<!--
  Returns the list of default inline labels to transform to fieldcodes.

  @return the list of inline labels
-->
<xsl:function name="fn:default-inline-fieldcode-labels">
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/inline/fieldcode/@label">
     <xsl:for-each select="$config-doc/config/elements[not(@label)]/inline/fieldcode/@label">
      <xsl:choose>
        <xsl:when test="position() = last()">
          <xsl:value-of select="concat('^',.,'$')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('^',.,'$','|')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the list of a specific document label inline labels to transform to fieldcodes.

  @return the list of inline labels
-->
<xsl:function name="fn:inline-fieldcode-labels-with-document-label">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/inline/fieldcode/@label">
     <xsl:for-each select="$config-doc/config/elements[@label = $document-label]/inline/fieldcode/@label">
      <xsl:choose>
        <xsl:when test="position() = last()">
          <xsl:value-of select="concat('^',.,'$')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('^',.,'$','|')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the default fieldcode value for a specific inline label.

  @param inline-label the value of the inline label

  @return the value of the fieldcode
-->
<xsl:function name="fn:get-default-inline-fieldcode-value">
  <xsl:param name="inline-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/inline/fieldcode[@label = $inline-label]/@value != ''">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/inline/fieldcode[@label = $inline-label]/@value" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the list of default inline labels to transform to fieldcodes.

  @return the list of inline labels
-->
<xsl:function name="fn:default-inline-index-labels">
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/inline/index/@label">
      <xsl:for-each select="$config-doc/config/elements[not(@label)]/inline/index/@label">
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:value-of select="concat('^',.,'$')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('^',.,'$','|')" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the list of a specific document label inline labels to transform to fieldcodes.

  @return the list of inline labels
-->
<xsl:function name="fn:inline-index-labels-with-document-label">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/inline/index/@label">
     <xsl:for-each select="$config-doc/config/elements[@label = $document-label]/inline/index/@label">
      <xsl:choose>
        <xsl:when test="position() = last()">
          <xsl:value-of select="concat('^',.,'$')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('^',.,'$','|')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label specific fieldcode value for a specific inline label.

  @param inline-label the value of the inline label
  @param document-label the value of the document label

  @return the value of the fieldcode
-->
<xsl:function name="fn:get-document-label-inline-fieldcode-value" as="xs:string">
  <xsl:param name="inline-label"/>
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/inline/fieldcode[@label = $inline-label]/@value != ''">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/inline/fieldcode[@label = $inline-label]/@value" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the list of default ignore inline labels.

  @return the list of inline labels
-->
<xsl:function name="fn:default-inline-ignore-labels">
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/inline/ignore/@label">
     <xsl:for-each
      select="$config-doc/config/elements[not(@label)]/inline/ignore/@label">
      <xsl:choose>
        <xsl:when test="position() = last()">
          <xsl:value-of select="concat('^',.,'$')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('^',.,'$','|')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the list of document label specific ignore inline labels.

  @param document-label the value of the document label

  @return the list of inline labels
-->
<xsl:function name="fn:inline-ignore-labels-with-document-label">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/inline/ignore/@label">
     <xsl:for-each select="$config-doc/config/elements[@label = $document-label]/inline/ignore/@label">
      <xsl:choose>
        <xsl:when test="position() = last()">
          <xsl:value-of select="concat('^',.,'$')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('^',.,'$','|')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the list of default ignore block labels.

  @return the list of block labels
-->
<xsl:function name="fn:default-block-ignore-labels">
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/block/ignore/@label">
     <xsl:for-each select="$config-doc/config/elements[not(@label)]/block/ignore/@label">
      <xsl:choose>
        <xsl:when test="position() = last()">
          <xsl:value-of select="concat('^',.,'$')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('^',.,'$','|')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the list of document label specific ignore block labels.

  @param document-label the value of the document label

  @return the list of block labels
-->
<xsl:function name="fn:block-ignore-labels-with-document-label">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/block/ignore/@label">
     <xsl:for-each select="$config-doc/config/elements[@label = $document-label]/block/ignore/@label">
      <xsl:choose>
        <xsl:when test="position() = last()">
          <xsl:value-of select="concat('^',.,'$')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('^',.,'$','|')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the default table style.

@return the word table style
-->
<xsl:function name="fn:default-table-style" as="xs:string">
  <xsl:variable name="table-name" select="$config-doc/config/elements[not(@label)]/tables/table/@default"/>
  <xsl:choose>
    <xsl:when test="document(concat($_dotxfolder,$styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $table-name]/@w:styleId != ''">
      <xsl:value-of select="document(concat($_dotxfolder,$styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $table-name]/@w:styleId" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the default table style based on a table role.

  @param role the table role

  @return the word table style
-->
<xsl:function name="fn:default-table-roles" as="xs:string">
  <xsl:param name="role"/>
  <xsl:variable name="table-name" select="$config-doc/config/elements[not(@label)]/tables/table[@role = $role]/@tablestyle"/>
  <xsl:choose>
    <xsl:when test="document(concat($_dotxfolder,$styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $table-name]/@w:styleId != ''">
      <xsl:value-of select="document(concat($_dotxfolder,$styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $table-name]/@w:styleId" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label specific table style.

  @return the word table style
-->
<xsl:function name="fn:default-table-style-with-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:variable name="table-name" select="$config-doc/config/elements[@label = $document-label]/tables/table/@default"/>
  <xsl:choose>
    <xsl:when test="document(concat($_dotxfolder,$styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $table-name]/@w:styleId != ''">
      <xsl:value-of select="document(concat($_dotxfolder,$styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $table-name]/@w:styleId" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label specific table style based on a table role.

  @param role the table role

  @return the word table style
-->
<xsl:function name="fn:table-roles-with-document-label" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:variable name="table-name" select="$config-doc/config/elements[@label = $document-label]/tables/table[@role = $role]/@tablestyle"/>
  <xsl:choose>
    <xsl:when test="document(concat($_dotxfolder,$styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $table-name]/@w:styleId != ''">
          <xsl:value-of select="document(concat($_dotxfolder,$styles-template))//w:style[@w:type = 'table'][w:name/@w:val = $table-name]/@w:styleId" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the default table width type.

  @return the word table with type
-->
<xsl:function name="fn:default-table-style-type" as="xs:string">
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/tables/table[@default]/width/@type != ''">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/tables/table[@default]/width/@type" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the default table width value.

  @return the word table with value
-->
<xsl:function name="fn:default-table-style-type-value" as="xs:string">
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/tables/table[@default]/width/@value != ''">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/tables/table[@default]/width/@value" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the default table width type based on a table role.

  @param role the table role

  @return the word table width type
-->
<xsl:function name="fn:default-table-roles-type" as="xs:string">
  <xsl:param name="role"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/tables/table[@role = $role]/width/@type != ''">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/tables/table[@role = $role]/width/@type" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the default table width value based on a table role.

@param role the table role

@return the word table width value
-->
<xsl:function name="fn:default-table-roles-type-value" as="xs:string">
  <xsl:param name="role"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/tables/table[@role = $role]/width/@value != ''">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/tables/table[@role = $role]/width/@value" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label specific table width type.

  @return the word table width type
-->
<xsl:function name="fn:default-table-style-with-document-label-type" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/tables/table[@default]/width/@type != ''">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/tables/table[@default]/width/@type" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label specific table width value.

  @return the word table width value
-->
<xsl:function name="fn:default-table-style-with-document-label-type-value" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/tables/table[@default]/width/@value != ''">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/tables/table[@default]/width/@value" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label specific table width type based on a table role.

  @param document-label the document label
  @param role the table role

  @return the word table width type
-->
<xsl:function name="fn:table-roles-with-document-label-type" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/tables/table[@role = $role]/width/@type != ''">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/tables/table[@role = $role]/width/@type" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the document label specific table width value based on a table role.

  @param document-label the document label
  @param role the table value

  @return the word table width type
-->
<xsl:function name="fn:table-roles-with-document-label-type-value" as="xs:string">
  <xsl:param name="document-label"/>
  <xsl:param name="role"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/tables/table[@role = $role]/width/@value != ''">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/tables/table[@role = $role]/width/@value" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
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
  Returns the confirmation of creation a table of contents or not at ps:toc level.

  @return true or false
-->
<xsl:variable name="create-toc" as="xs:boolean">
  <!-- TODO Simplify code -->
  <xsl:choose>
    <xsl:when test="$config-doc/config/toc[@generate = 'true']">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
  Returns the confirmation of creation a table of contents or not at ps:toc level.

  @return true or false
-->
<xsl:variable name="create-endnotes" as="xs:boolean">
  <!-- TODO Simplify code -->
  <xsl:choose>
    <xsl:when test="$config-doc/config/default/endnotes[@generate = 'true']">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:function name="fn:endnote-labels">
  <xsl:choose>
    <xsl:when test="$create-endnotes">
      <xsl:for-each select="tokenize($config-doc/config/default/endnotes/@xref-labels,',')">
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:value-of select="concat('^',.,'$')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('^',.,'$','|')" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the confirmation of creation a table of contents or not at ps:toc level.

  @return true or false
-->
<xsl:variable name="create-footnotes" as="xs:boolean">
  <!-- TODO Simplify code -->
  <xsl:choose>
    <xsl:when test="$config-doc/config/default/footnotes[@generate = 'true']">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>


<xsl:function name="fn:footnote-labels">
  <xsl:choose>
    <xsl:when test="$create-footnotes">
      <xsl:for-each select="tokenize($config-doc/config/default/footnotes/@xref-labels,',')">
        <xsl:choose>
          <xsl:when test="position() = last()">
            <xsl:value-of select="concat('^',.,'$')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('^',.,'$','|')" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat('^','No Selected Value','$')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the confirmation of creation a table of contents with headings or not.

  @return true or false
-->
<xsl:variable name="generate-toc-headings" as="xs:boolean">
  <!-- TODO Simplify code -->
  <xsl:choose>
    <xsl:when test="$config-doc/config/toc/headings[@generate = 'true']">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
  Returns the values of the heading values for Table of contents.

  @return value of heading levels
-->
<xsl:variable name="toc-heading-values" as="xs:string">
  <xsl:choose>
    <xsl:when test="$config-doc/config/toc/headings/@select != ''">
      <xsl:value-of select="$config-doc/config/toc/headings/@select" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
  Returns the confirmation of creation a table of contents with outline levels or not.

  @return true or false
-->
<xsl:variable name="generate-toc-outline" as="xs:boolean">
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/toc/outline[@generate = 'true']">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
  Returns the values of the outline level values for Table of contents.

  @return value of outline levels
-->
<xsl:variable name="toc-outline-values">
  <xsl:choose>
    <xsl:when test="$config-doc/config/toc/outline/@select != ''">
      <xsl:value-of select="$config-doc/config/toc/outline/@select" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
  Returns the confirmation of creation a table of contents with paragraph styles or not.

  @return true or false
-->
<xsl:variable name="generate-toc-paragraphs" as="xs:boolean">
  <xsl:choose>
    <xsl:when test="$config-doc/config/toc/paragraph[@generate = 'true']">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
Returns the values of the paragraph styles values for Table of contents.

@return list of paragprah styles and indent value
-->
<xsl:variable name="toc-paragraph-values">
  <xsl:for-each select="$config-doc/config/toc/paragraph/style">
    <xsl:choose>
      <xsl:when test="position() = last()">
        <xsl:value-of select="concat(./@value,',',./@indent)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(./@value,',',./@indent,',')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:variable>

<!--
Returns the confirmation of creation of comments.

@return true or false
-->
<xsl:variable name="generate-comments" as="xs:boolean">
  <xsl:choose>
    <xsl:when test="$config-doc/config/default/comments/@generate = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
Returns the naming of docx files on export master.

@return type of export
-->
<xsl:variable name="master-select" as="xs:string">
  <xsl:choose>
    <xsl:when test="$config-doc/config/default/master/@select = 'uriid'">
      <xsl:value-of select="'uriid'" />
    </xsl:when>
    <xsl:when test="$config-doc/config/default/master/@select = 'urititle'">
      <xsl:value-of select="'urititle'" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'uriid'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
Returns the confirmation of creation of comments.

@return true or false
-->
<xsl:variable name="generate-mathml" as="xs:boolean">
  <xsl:choose>
    <xsl:when test="$config-doc/config/default/mathml/@generate = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- boolean variable to generate cross references or not -->
<xsl:variable name="generate-cross-references" as="xs:boolean">
  <xsl:choose>
    <xsl:when test="$config-doc/config/default/xref/@type = 'cross-reference'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
Returns the configured default paragraph style.

@return the value of the default paragraph style
-->
<xsl:variable name="default-paragraph-style">
  <xsl:choose>
    <xsl:when test="$config-doc/config/default/defaultparagraphstyle/@wordstyle = 'none'">
      <xsl:value-of select="'Body Text'" />
    </xsl:when>
    <xsl:when test="$config-doc/config/default/defaultparagraphstyle/@wordstyle != ''">
      <xsl:value-of select="$config-doc/config/default/defaultparagraphstyle/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'Body Text'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
Returns the configured default character style.

@return the value of the default character style
-->
<xsl:variable name="default-character-style">
  <xsl:choose>
    <xsl:when test="$config-doc/config/default/defaultcharacterstyle/@wordstyle = 'none'">
      <xsl:value-of select="'Default Paragraph Font'" />
    </xsl:when>
    <xsl:when test="$config-doc/config/default/defaultcharacterstyle/@wordstyle != ''">
      <xsl:value-of select="$config-doc/config/default/defaultcharacterstyle/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'Default Paragraph Font'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
Returns the configured style for ps:preformat element for label specific documents.

@param document-label the document label
@return the w:style
-->
<xsl:function name="fn:preformat-wordstyle-for-document-label">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/preformat/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/preformat/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the configured style for ps:preformat element for default documents.

@return the w:style
-->
<xsl:function name="fn:preformat-wordstyle-for-default-document">
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/preformat/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/preformat/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the configured w:style for ps:block element for label specific documents.

@param document-label the document label
@param block-label the current block label
@return the w:style
-->
<xsl:function name="fn:block-wordstyle-for-document-label">
  <xsl:param name="document-label"/>
  <xsl:param name="block-label"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/block/label[@value=$block-label]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/block/label[@value=$block-label]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the default w:style for ps:block element for label specific documents.

@param document-label the document label
@return the w:style
-->
<xsl:function name="fn:block-default-wordstyle-for-document-label">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/block/@default = 'none'">
      <xsl:value-of select="''" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/block/@default">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/block/@default" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the configured w:style for ps:block element for default documents.

@param block-label the document label
@return the w:style
-->
<xsl:function name="fn:block-wordstyle-for-default-document">
  <xsl:param name="block-label"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/block/label[@value=$block-label]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/block/label[@value=$block-label]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the default w:style for ps:block element for default documents.

@return the w:style
-->
<xsl:function name="fn:block-default-wordstyle-for-default-document">
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/block/@default = 'none'">
      <xsl:value-of select="''" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/block/@default">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/block/@default" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the configured w:style for ps:inline element for label specific documents.

@param document-label the document label
@param inline-label the current inline label
@return the w:style
-->
<xsl:function name="fn:inline-wordstyle-for-document-label">
  <xsl:param name="document-label"/>
  <xsl:param name="inline-label"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/inline/label[@value=$inline-label]/@wordstyle = 'generate-ps-style'">
      <xsl:value-of select="concat('psinline',$inline-label)" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/inline/label[@value=$inline-label]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/inline/label[@value=$inline-label]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the configured w:style for ps:inline element for label specific documents.

@param document-label the document label
@return the w:style
-->
<xsl:function name="fn:inline-default-wordstyle-for-document-label">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/inline/@default = 'none'">
      <xsl:value-of select="''" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/inline/@default">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/inline/@default" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the configured w:style for ps:inline element for default documents.

@param inline-label the current inline label
@return the w:style
-->
<xsl:function name="fn:inline-wordstyle-for-default-document">
  <xsl:param name="inline-label"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/inline/label[@value=$inline-label]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/inline/label[@value=$inline-label]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the default w:style for ps:inline element for default documents.

@return the w:style
-->
<xsl:function name="fn:inline-default-wordstyle-for-default-document">
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/inline/@default = 'none'">
      <xsl:value-of select="''" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/inline/@default">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/inline/@default" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the configured w:style for ps:heading element for label specific documents.

@param document-label the document label
@param heading-level the current heading level
@param numbered the numbered attribute value of the heading
@return the w:style
-->
<xsl:function name="fn:heading-wordstyle-for-document-label">
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the configured w:style for ps:heading element for default documents.

@param heading-level the current heading level
@param numbered the numbered attribute value of the heading
@return the w:style
-->
<xsl:function name="fn:heading-wordstyle-for-default-document">
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
<!--     <xsl:message>test</xsl:message> -->
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/@wordstyle">
<!--         <xsl:message>here</xsl:message> -->
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
<!--         <xsl:message>not here</xsl:message> -->
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns if the configured w:style for ps:heading element for default documents should convert the prefix into a value or not.

@param heading-level the current heading level
@param numbered the numbered attribute value of the heading
@return true or false
-->
<xsl:function name="fn:heading-prefix-select-for-default-document" as="xs:boolean">
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/@select = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/@select = 'false'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns if the configured w:style for ps:heading element for default documents should keep with the next w:paragraph.

@param heading-level the current heading level
@param numbered the numbered attribute value of the heading
@return true or false
-->
<xsl:function name="fn:default-keep-heading-with-next" as="xs:boolean">
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
      <xsl:choose>
        <xsl:when
          test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/keep-paragraph-with-next">
          <xsl:value-of select="true()" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()" />
        </xsl:otherwise>
      </xsl:choose>
</xsl:function>

<!--
Returns if the configured w:style for ps:heading element for document label specific documents should convert the prefix into a value or not.

@param heading-level the current heading level
@param numbered the numbered attribute value of the heading
@return true or false
-->
<xsl:function name="fn:heading-prefix-select-for-document-label" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/@select = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/@select = 'false'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns if the configured w:style for ps:heading element for document label specific documents should keep with the next w:paragraph.

@param heading-level the current heading level
@param numbered the numbered attribute value of the heading
@return true or false
-->
<xsl:function name="fn:labels-keep-heading-with-next" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
      <xsl:choose>
        <xsl:when test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/keep-paragraph-with-next">
          <xsl:value-of select="true()" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="false()" />
        </xsl:otherwise>
      </xsl:choose>
</xsl:function>

<!--
Returns if the configured w:style for ps:para element for default documents should handle the @ps:prefix.

@param indent-level the current indent level
@param numbered the numbered attribute value of the ps:para
@return true or false
-->
<xsl:function name="fn:para-prefix-select-for-default-document" as="xs:boolean">
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="not($indent-level) and $config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level='0']/prefix/@select = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/prefix/@select = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/prefix/@select = 'false'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns if the configured w:style for ps:para element for default documents should keep with the next w:paragraph.

@param indent-level the current ps:para level
@param numbered the numbered attribute value of the ps:para
@return true or false
-->
<xsl:function name="fn:default-keep-para-with-next" as="xs:boolean">
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="not($indent-level) and $config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level='0']/keep-paragraph-with-next">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/keep-paragraph-with-next">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
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
<xsl:function name="fn:labels-keep-para-with-next" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="not($indent-level) and $config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level='0']/keep-paragraph-with-next">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/keep-paragraph-with-next">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
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
<xsl:function name="fn:para-prefix-select-for-document-label" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="not($indent-level) and $config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level='0']/prefix/@select = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/prefix/@select = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/prefix/@select = 'false'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
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
<xsl:function name="fn:para-list-level-paragraph-for-document-label">
  <xsl:param name="document-label"/>
  <xsl:param name="list-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/listpara/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$list-level]/@wordstyle != ''">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/listpara/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$list-level]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the w:style for ps:para element that is inside a ps:list for default document.

@param list-level the current list level
@param numbered the numbered attribute value of the ps:para
@return w:style
-->
 <xsl:function name="fn:para-list-level-paragraph-for-default-document">
  <xsl:param name="list-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/listpara/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$list-level]/@wordstyle != ''">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/listpara/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$list-level]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns if the configured w:style for ps:para element for default documents should handle the @ps:numbering.

@param indent-level the current indent level
@param numbered the numbered attribute value of the ps:para
@return true or false
-->
<xsl:function name="fn:para-numbered-select-for-default-document" as="xs:boolean">
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="not($indent-level) and $config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level='0']/numbered/@select = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/numbered/@select = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/numbered/@select = 'false'">
      <!-- TODO check logic for @select = 'false' here and in all code below -->
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
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
<xsl:function name="fn:para-numbered-select-for-document-label" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="not($indent-level) and $config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level='0']/numbered/@select = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/numbered/@select = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$indent-level]/numbered/@select = 'false'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns if the configured w:style for ps:heading element for default documents should handle the @ps:numbering.

@param heading-level the current indent level
@param numbered the numbered attribute value of the ps:para
@return true or false
-->
<xsl:function name="fn:heading-numbered-select-for-default-document" as="xs:boolean">
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/@select = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/@select = 'false'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns if the configured w:style for ps:heading element for label specific documents should handle the @ps:numbering.

@param document-label the current document label
@param indent-level the current indent level
@param numbered the numbered attribute value of the ps:para
@return true or false
-->
<xsl:function name="fn:heading-numbered-select-for-document-label" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/@select = 'true'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/@select = 'false'">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

 <!--
Returns if the configured w:style for ps:block element for default documents should keep with the next w:paragraph.

@param label the current ps:block label

@return true or false
-->
<xsl:function name="fn:default-keep-block-with-next" as="xs:boolean">
  <xsl:param name="label"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[not(@label)]/block/label[@value=$label]/keep-paragraph-with-next">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns if the configured w:style for ps:block element for document label specific documents should keep with the next w:paragraph.

@param document-label the current ps:document label
@param label the current ps:block label

@return true or false
-->
<xsl:function name="fn:labels-keep-block-with-next" as="xs:boolean">
  <xsl:param name="document-label"/>
  <xsl:param name="label"/>
  <xsl:choose>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/block/label[@value=$label]/keep-paragraph-with-next">
      <xsl:value-of select="true()" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
Returns the word numeric value for pageseeder numeric value.

@param regexp-value the value of the current regex value

@return the pageseeder numeric value
-->
<xsl:function name="fn:get-numeric-type">
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
<xsl:function name="fn:replace-regexp">
  <xsl:param name="regexp-value"/>
  <xsl:choose>
    <xsl:when test="matches($regexp-value,'%arabic%')">
      <xsl:value-of select="replace($regexp-value,'%arabic%','(\\d+)')"/>
    </xsl:when>
    <xsl:when test="matches($regexp-value,'%lowerletter%')">
      <xsl:value-of select="replace($regexp-value,'%lowerletter%','([a-z]+)')"/>
    </xsl:when>
    <xsl:when test="matches($regexp-value,'upperletter')">
      <xsl:value-of select="replace($regexp-value,'%upperletter%','([A-Z]+)')"/>
    </xsl:when>
    <xsl:when test="matches($regexp-value,'upperroman')">
      <xsl:value-of select="replace($regexp-value,'%upperroman%','([IVXCLDM]+)')"/>
    </xsl:when>
    <xsl:when test="matches($regexp-value,'lowerroman')">
      <xsl:value-of select="replace($regexp-value,'%lowerroman%','([ivxcldm]+)')"/>
    </xsl:when>
  </xsl:choose>
</xsl:function>

<!--
Automates the creation of a prefix for a heading defined by the expression set in configuration for document label specific documents.

@param document-label the value of the current document label
@param heading-level the value of the current heading level
@param current the value of the current node
@param numbered the value of the current numbered attribute

@return the real regular expression value
-->
<xsl:function name="fn:heading-prefix-value-for-document-label" >
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="current"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
     <xsl:when test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix[@select = 'true']/fieldcode">
        <xsl:variable name="type" select="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/fieldcode/@type"/>
        <xsl:variable name="name" select="concat($document-label,'-heading',$heading-level)"/>
        <xsl:variable name="regexp" select="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/fieldcode/@regexp"/>
        <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
        <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
        <xsl:variable name="flags">
         <xsl:choose>
            <xsl:when test="$current/preceding::heading[ancestor::document[1]/documentinfo/uri/labels = $document-label][@level &lt;= number($heading-level)][1][@level = $heading-level]/@prefix != ''">
              <xsl:variable name="preceding-heading-value" select="$current/preceding::heading[ancestor::document[1]/documentinfo/uri/labels = $document-label][@level &lt;= number($heading-level)][1][@level = $heading-level]/@prefix"/>
<!--                 <xsl:message>heading-level:<xsl:value-of select="$heading-level"/></xsl:message> -->
<!--                 <xsl:message>preceding-heading-level:<xsl:value-of select="$current/preceding::heading[ancestor::document[1]/not(.//labels)][@level &lt;= number($heading-level)][1]/@level"/></xsl:message> -->
<!--                 <xsl:message>headingvalue:<xsl:value-of select="$current/@prefix"/></xsl:message> -->
<!--                 <xsl:message>preceding-heading-value:<xsl:value-of select="$preceding-heading-value"/></xsl:message> -->
<!--                 <xsl:message>1:<xsl:value-of select="fn:get-number-from-regexp($preceding-heading-value,$regexp,$real-regular-expression)"/></xsl:message> -->
<!--                 <xsl:message>2:<xsl:value-of select="fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression)"/></xsl:message> -->

        <xsl:choose>
                <xsl:when test="number(fn:get-number-from-regexp($preceding-heading-value,$regexp,$real-regular-expression)) + 1 = number(fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))">
                  <xsl:value-of select="'\n'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="string-before-regexp">
          <xsl:choose>
            <xsl:when test="substring-before($regexp,'%') !=''">
              <xsl:variable name="regexp-before" select="concat('(',substring-before($regexp,'%'),').*')"/>
<!--                <xsl:message>regexp-before:<xsl:value-of select="$regexp-before"/></xsl:message> -->
<!--                <xsl:message>$current/@prefix:<xsl:value-of select="$current/@prefix"/></xsl:message> -->
              <xsl:analyze-string regex="({$regexp-before})" select="replace($current/@prefix,'&#160;',' ')">
                 <xsl:matching-substring>
<!--                    <xsl:message>regex:<xsl:value-of select="regex-group(2)"/></xsl:message> -->
                   <xsl:value-of select="regex-group(2)"/>
                 </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="string-after-regexp">
          <xsl:choose>
            <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
              <xsl:variable name="regexp-after" select="concat('.*(',replace($regexp,'.*%[^%]+%',''),')')"/>
              <xsl:analyze-string regex="({$regexp-after})" select="replace($current/@prefix,'&#160;',' ')">
                 <xsl:matching-substring>
          <!--         <xsl:message>regex:<xsl:value-of select="regex-group(2)"/></xsl:message> -->
                   <xsl:value-of select="regex-group(2)"/>
                 </xsl:matching-substring>
               </xsl:analyze-string>
             </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="''"/>
              </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="$string-before-regexp != ''">
          <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-before-regexp"/></w:t>
        </w:r>
        </xsl:if>
        <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
        </w:fldSimple>
        <xsl:if test="$string-after-regexp != ''">
          <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-after-regexp"/></w:t>
        </w:r>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix[@select = 'true']">
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t>
        </w:r>
      </xsl:when>
      <xsl:when test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix[@select = 'false']">

      </xsl:when>
      <xsl:otherwise>
        <w:r>
          <w:t xml:space="preserve"/>
        </w:r>
      </xsl:otherwise>
    </xsl:choose>
</xsl:function>

<!--
Automates the creation of a numbered value for a heading defined by the expression set in configuration for document label specific documents.

@param document-label the value of the current document label
@param heading-level the value of the current heading level
@param current the value of the current node
@param numbered the value of the current numbered attribute

@return the real regular expression value
-->
 <xsl:function name="fn:heading-numbered-value-for-document-label" >
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="current"/>
  <xsl:param name="numbered"/>
<!--     <xsl:message>indent-level:<xsl:value-of select="number($indent-level)"/></xsl:message> -->
<!--     <xsl:message>paraprefix:<xsl:value-of select="$current/@prefix"/></xsl:message> -->
<!--     <xsl:message>precedingparavalue:<xsl:value-of select="$current/preceding::para[ancestor::document[1]/not(.//labels)][@indent &lt;= number($indent-level)][1][@indent = number($indent-level)][@prefix]"/></xsl:message> -->
<!--     <xsl:message>precedingparaindent:<xsl:value-of select="number($current/preceding::para[ancestor::document[1]/not(.//labels)][@indent &lt;= number($indent-level)][1][@indent = number($indent-level)][@prefix]/@indent)"/></xsl:message> -->
  <xsl:choose>
     <xsl:when test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered[@select = 'true']/fieldcode">
        <xsl:variable name="type" select="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/fieldcode/@type"/>
        <xsl:variable name="name" select="concat($document-label,'-heading-num',$heading-level)"/>
        <xsl:variable name="regexp" select="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/fieldcode/@regexp"/>
        <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
        <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
        <xsl:variable name="flags">
          <xsl:choose>
            <xsl:when test="$current/preceding::heading[@numbered][1][@level &lt; $heading-level]">
              <xsl:value-of select="'\r 1'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'\n'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="string-before-regexp">
          <xsl:choose>
            <xsl:when test="substring-before($regexp,'%') !=''">

              <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="substring-before($regexp,'%')">
                 <xsl:matching-substring>
<!--                     <xsl:message>here</xsl:message> -->
                      <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),$document-label,$current,$numbered)}">
                      </w:fldSimple>
<!--                    <xsl:message>regex1:<xsl:value-of select="regex-group(2)"/></xsl:message> -->
                      <xsl:if test="regex-group(4) != ''">
                      <w:r>
                        <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                      </w:r>
                      </xsl:if>
                 </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>


        <xsl:variable name="string-after-regexp">
          <xsl:choose>
            <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
              <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="replace($regexp,'.*%[^%]+%','')">
                 <xsl:matching-substring>
                      <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),'default',$current,$numbered)}">
                      </w:fldSimple>
<!--                    <xsl:message>regex2:<xsl:value-of select="regex-group(2)"/></xsl:message> -->
                      <xsl:if test="regex-group(4) != ''">
                      <w:r>
                        <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                      </w:r>
                      </xsl:if>
                 </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:if test="$string-before-regexp != ''">
          <xsl:sequence select="$string-before-regexp"/>
        </xsl:if>
        <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
        </w:fldSimple>
<!--           <w:r> -->
<!--             <w:t xml:space="preserve"><xsl:value-of select="' '"/></w:t> -->
<!--           </w:r> -->
        <xsl:if test="$string-after-regexp != ''">
         <xsl:sequence select="$string-after-regexp"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
</xsl:function>

<!--
Automates the creation of a prefix for a heading defined by the expression set in configuration for default documents.

@param heading-level the value of the current heading level
@param current the value of the current node
@param numbered the value of the current numbered attribute

@return the real regular expression value
-->
<xsl:function name="fn:heading-prefix-value-for-default-document" >
  <xsl:param name="heading-level"/>
  <xsl:param name="current" as="node()"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
     <xsl:when test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix[@select = 'true']/fieldcode">
        <xsl:variable name="type" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/fieldcode/@type"/>
        <xsl:variable name="name" select="concat('defaultheading',$heading-level)"/>
        <xsl:variable name="regexp" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/fieldcode/@regexp"/>
        <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
        <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
        <xsl:variable name="flags">
         <xsl:choose>
            <xsl:when test="$current/preceding::heading[ancestor::document[1]/not(.//labels)][@level &lt;= number($heading-level)][1][@level = $heading-level]/@prefix != ''">
              <xsl:variable name="preceding-heading-value" select="$current/preceding::heading[ancestor::document[1]/not(.//labels)][@level &lt;= number($heading-level)][1][@level = $heading-level]/@prefix"/>
<!--                 <xsl:message>heading-level:<xsl:value-of select="$heading-level"/></xsl:message> -->
<!--                 <xsl:message>preceding-heading-level:<xsl:value-of select="$current/preceding::heading[ancestor::document[1]/not(.//labels)][@level &lt;= number($heading-level)][1]/@level"/></xsl:message> -->
<!--                 <xsl:message>headingvalue:<xsl:value-of select="$current/@prefix"/></xsl:message> -->
<!--                 <xsl:message>preceding-heading-value:<xsl:value-of select="$preceding-heading-value"/></xsl:message> -->
<!--                 <xsl:message>1:<xsl:value-of select="fn:get-number-from-regexp($preceding-heading-value,$regexp,$real-regular-expression)"/></xsl:message> -->
<!--                 <xsl:message>2:<xsl:value-of select="fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression)"/></xsl:message> -->

              <xsl:choose>
                <xsl:when test="number(fn:get-number-from-regexp($preceding-heading-value,$regexp,$real-regular-expression)) + 1 = number(fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))">
                  <xsl:value-of select="'\n'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="string-before-regexp">
          <xsl:choose>
            <xsl:when test="substring-before($regexp,'%') !=''">
              <xsl:variable name="regexp-before" select="concat('(',substring-before($regexp,'%'),').*')"/>
<!-- 		            <xsl:message>regexp-before:<xsl:value-of select="$regexp-before"/></xsl:message> -->
<!-- 		            <xsl:message>$current/@prefix:<xsl:value-of select="$current/@prefix"/></xsl:message> -->
              <xsl:analyze-string regex="({$regexp-before})" select="replace($current/@prefix,'&#160;',' ')">
                 <xsl:matching-substring>
<!-- 		                <xsl:message>regex:<xsl:value-of select="regex-group(2)"/></xsl:message> -->
                   <xsl:value-of select="regex-group(2)"/>
                 </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:variable>


        <xsl:variable name="string-after-regexp">
          <xsl:choose>
            <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
              <xsl:variable name="regexp-after" select="concat('.*(',replace($regexp,'.*%[^%]+%',''),')')"/>
              <xsl:analyze-string regex="({$regexp-after})" select="replace($current/@prefix,'&#160;',' ')">
                 <xsl:matching-substring>
          <!--         <xsl:message>regex:<xsl:value-of select="regex-group(2)"/></xsl:message> -->
                   <xsl:value-of select="regex-group(2)"/>
                 </xsl:matching-substring>
               </xsl:analyze-string>
             </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="''"/>
              </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

<!--           <xsl:message>type:<xsl:value-of select="$type"/></xsl:message> -->
<!--           <xsl:message>name:<xsl:value-of select="$name"/></xsl:message> -->
<!--           <xsl:message>regexp:<xsl:value-of select="$regexp"/></xsl:message> -->
<!--           <xsl:message>numeric-type:<xsl:value-of select="$numeric-type"/></xsl:message> -->
<!--           <xsl:message>real-regular-expression:<xsl:value-of select="$real-regular-expression"/></xsl:message> -->
<!--           <xsl:message>flags:<xsl:value-of select="$flags"/></xsl:message> -->
        <xsl:if test="$string-before-regexp != ''">
          <w:r>
            <w:t xml:space="preserve"><xsl:value-of select="$string-before-regexp"/></w:t>
          </w:r>
        </xsl:if>
        <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
        </w:fldSimple>
        <xsl:if test="$string-after-regexp != ''">
          <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-after-regexp"/></w:t>
        </w:r>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix[@select = 'true']">
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t>
        </w:r>
      </xsl:when>
      <xsl:when test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix[@select = 'false']">
<!--           <w:r> -->
<!--             <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t> -->
<!--           </w:r> -->
      </xsl:when>
      <xsl:otherwise>
        <w:r>
          <w:t xml:space="preserve"/>
        </w:r>
      </xsl:otherwise>
    </xsl:choose>
</xsl:function>


<!--
Automates the creation of a numbered value for a heading defined by the expression set in configuration for default documents.

@param heading-level the value of the current heading level
@param current the value of the current node
@param numbered the value of the current numbered attribute

@return the real regular expression value
-->
<xsl:function name="fn:heading-numbered-value-for-default-document" >
  <xsl:param name="heading-level"/>
  <xsl:param name="current" as="node()"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
     <xsl:when test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered[@select = 'true']/fieldcode">
        <xsl:variable name="type" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/fieldcode/@type"/>
        <xsl:variable name="name" select="concat('default-heading-num',$heading-level)"/>
        <xsl:variable name="regexp" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/fieldcode/@regexp"/>
        <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
        <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
        <xsl:variable name="flags">
          <xsl:choose>
            <xsl:when test="$current/preceding::heading[1][@level &lt; $heading-level]">
              <xsl:value-of select="'\r 1'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'\n'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="string-before-regexp">
          <xsl:choose>
            <xsl:when test="substring-before($regexp,'%') !=''">
<!--                 <xsl:message>substring-before($regexp,'%')</xsl:message> -->
              <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="substring-before($regexp,'%')">
                 <xsl:matching-substring>
<!--                     <xsl:message>here</xsl:message> -->
                      <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),'default',$current,$numbered)}">
                      </w:fldSimple>
<!--                    <xsl:message>regex1:<xsl:value-of select="regex-group(2)"/></xsl:message> -->
                      <xsl:if test="regex-group(4) != ''">
                      <w:r>
                        <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                      </w:r>
                      </xsl:if>
                 </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="string-after-regexp">
          <xsl:choose>
            <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
              <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="replace($regexp,'.*%[^%]+%','')">
                 <xsl:matching-substring>
                      <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),'default',$current,$numbered)}">
                      </w:fldSimple>
<!--                    <xsl:message>regex2:<xsl:value-of select="regex-group(2)"/></xsl:message> -->
                      <xsl:if test="regex-group(4) != ''">
                      <w:r>
                        <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                      </w:r>
                      </xsl:if>
                 </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:if test="$string-before-regexp != ''">
          <xsl:sequence select="$string-before-regexp"/>
        </xsl:if>
        <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
        </w:fldSimple>
<!--           <w:r> -->
<!--             <w:t xml:space="preserve"><xsl:value-of select="' '"/></w:t> -->
<!--           </w:r> -->
        <xsl:if test="$string-after-regexp != ''">
         <xsl:sequence select="$string-after-regexp"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
</xsl:function>

<!--
Automates the creation of a prefix for a ps:para defined by the expression set in configuration for document label specific documents.

@param document-label the value of the current document label
@param indent-level the value of the current para indent
@param current the value of the current node
@param numbered the value of the current numbered attribute

@return the real regular expression value
-->
<xsl:function name="fn:para-prefix-value-for-document-label" >
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="current"/>
  <xsl:param name="numbered"/>

  <xsl:variable name="current-indent">
    <xsl:choose>
      <xsl:when test="not($indent-level)">
        <xsl:value-of select="'0'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$indent-level"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

<!--     <xsl:message>indent:<xsl:value-of select="$indent-level"/></xsl:message> -->
  <xsl:choose>
     <xsl:when test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix[@select = 'true']/fieldcode">
        <xsl:variable name="type" select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix/fieldcode/@type"/>
        <xsl:variable name="name" select="concat($document-label,'-para',$current-indent)"/>
        <xsl:variable name="regexp" select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix/fieldcode/@regexp"/>
        <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
        <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
        <xsl:variable name="flags">
         <xsl:choose>
            <xsl:when test="$current/preceding::para[ancestor::document[1]/documentinfo/uri/labels = $document-label][@indent &lt;= number($current-indent)][1][@indent = $current-indent]/@prefix != ''">
              <xsl:variable name="precedingparavalue" select="$current/preceding::para[ancestor::document[1]/documentinfo/uri/labels = $document-label][@indent &lt;= number($current-indent)][1][@indent = $current-indent]/@prefix"/>
<!--                 <xsl:message>indent-level:<xsl:value-of select="$indent-level"/></xsl:message> -->
<!--                 <xsl:message>preceding-heading-level:<xsl:value-of select="$current/preceding::para[ancestor::document[1]/not(.//labels)][@level &lt;= number($heading-level)][1]/@level"/></xsl:message> -->
<!--                 <xsl:message>paraprefix:<xsl:value-of select="$current/@prefix"/></xsl:message> -->
<!--                 <xsl:message>precedingparavalue:<xsl:value-of select="$precedingparavalue"/></xsl:message> -->
<!--                 <xsl:message>1:<xsl:value-of select="fn:get-number-from-regexp($precedingparavalue,$regexp,$real-regular-expression)"/></xsl:message> -->
<!--                 <xsl:message>2:<xsl:value-of select="fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression)"/></xsl:message> -->

              <xsl:choose>
                <xsl:when test="number(fn:get-number-from-regexp($precedingparavalue,$regexp,$real-regular-expression)) + 1 = number(fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))">
                  <xsl:value-of select="'\n'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="string-before-regexp">
          <xsl:choose>
            <xsl:when test="substring-before($regexp,'%') !=''">

              <xsl:variable name="regexp-before" select="concat('(',substring-before($regexp,'%'),').*')"/>
<!--                <xsl:message>regexp-before:<xsl:value-of select="$regexp-before"/></xsl:message> -->
<!--                <xsl:message>$current/@prefix:<xsl:value-of select="$current/@prefix"/></xsl:message> -->
              <xsl:analyze-string regex="({$regexp-before})" select="replace($current/@prefix,'&#160;',' ')">
                 <xsl:matching-substring>
<!--                    <xsl:message>regex:<xsl:value-of select="regex-group(2)"/></xsl:message> -->
                   <xsl:value-of select="regex-group(2)"/>
                 </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:variable>


        <xsl:variable name="string-after-regexp">
          <xsl:choose>
            <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
              <xsl:variable name="regexp-after" select="concat('.*(',replace($regexp,'.*%[^%]+%',''),')')"/>
              <xsl:analyze-string regex="({$regexp-after})" select="replace($current/@prefix,'&#160;',' ')">
                 <xsl:matching-substring>
          <!--         <xsl:message>regex:<xsl:value-of select="regex-group(2)"/></xsl:message> -->
                   <xsl:value-of select="regex-group(2)"/>
                 </xsl:matching-substring>
               </xsl:analyze-string>
             </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="''"/>
              </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="$string-before-regexp != ''">
          <w:r>
            <w:t xml:space="preserve"><xsl:value-of select="$string-before-regexp"/></w:t>
          </w:r>
        </xsl:if>
        <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
        </w:fldSimple>
        <xsl:if test="$string-after-regexp != ''">
          <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-after-regexp"/></w:t>
        </w:r>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix[@select = 'true']">
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t>
        </w:r>
      </xsl:when>
      <xsl:otherwise>
        <w:r>
          <w:t xml:space="preserve"/>
        </w:r>
      </xsl:otherwise>
    </xsl:choose>
</xsl:function>

<!--
Automates the creation of a numbered value for a ps:para defined by the expression set in configuration for document label specific documents.

@param document-label the value of the current document label
@param indent-level the value of the current para indent
@param current the value of the current node
@param numbered the value of the current numbered attribute

@return the real regular expression value
-->
<xsl:function name="fn:para-numbered-value-for-document-label" >
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="current"/>
  <xsl:param name="numbered"/>

  <xsl:variable name="current-indent">
    <xsl:choose>
      <xsl:when test="not($indent-level)">
        <xsl:value-of select="'0'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$indent-level"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
<!--     <xsl:message>indent-level:<xsl:value-of select="number($indent-level)"/></xsl:message> -->
<!--     <xsl:message>paraprefix:<xsl:value-of select="$current/@prefix"/></xsl:message> -->
<!--     <xsl:message>precedingparavalue:<xsl:value-of select="$current/preceding::para[ancestor::document[1]/not(.//labels)][@indent &lt;= number($indent-level)][1][@indent = number($indent-level)][@prefix]"/></xsl:message> -->
<!--     <xsl:message>precedingparaindent:<xsl:value-of select="number($current/preceding::para[ancestor::document[1]/not(.//labels)][@indent &lt;= number($indent-level)][1][@indent = number($indent-level)][@prefix]/@indent)"/></xsl:message> -->
  <xsl:choose>
     <xsl:when test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/numbered[@select = 'true']/fieldcode">
        <xsl:variable name="type" select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/numbered/fieldcode/@type"/>
        <xsl:variable name="name" select="concat($document-label,'-para-num',$current-indent)"/>
        <xsl:variable name="regexp" select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/numbered/fieldcode/@regexp"/>
        <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
        <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
        <xsl:variable name="flags">
          <xsl:choose>
            <xsl:when test="$current/preceding::para[@numbered][1][@indent &lt; $current-indent]">
              <xsl:value-of select="'\r 1'"/>
            </xsl:when>
            <xsl:when test="$current/preceding::heading[1][not(following::para[@indent &gt;= $current-indent][following::*[generate-id() = generate-id($current)]])]">
              <xsl:value-of select="'\r 1'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'\n'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="string-before-regexp">
          <xsl:choose>
            <xsl:when test="substring-before($regexp,'%') !=''">

<!--                 <xsl:message>substring-before($regexp,'%')</xsl:message> -->
              <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="substring-before($regexp,'%')">
                 <xsl:matching-substring>
<!--                     <xsl:message>here</xsl:message> -->
                      <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),$document-label,$current,$numbered)}">
                      </w:fldSimple>
<!--                         <xsl:comment>regex1:<xsl:value-of select="regex-group(1)"/></xsl:comment> -->
<!--                         <xsl:comment>regex2:<xsl:value-of select="regex-group(2)"/></xsl:comment> -->
<!--                         <xsl:comment>regex3:<xsl:value-of select="regex-group(3)"/></xsl:comment> -->
<!--                         <xsl:comment>regex4:<xsl:value-of select="regex-group(4)"/></xsl:comment> -->


                      <xsl:if test="regex-group(4) != ''">
                      <w:r>
                        <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                      </w:r>
                      </xsl:if>
                 </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>


        <xsl:variable name="string-after-regexp">
<!--             <xsl:message>$regexp:<xsl:value-of select="$regexp"/></xsl:message> -->
<!--             <xsl:message>substring-after:<xsl:value-of select="replace($regexp,'.*%[^%]+%','')"/></xsl:message> -->
          <xsl:choose>
            <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">

              <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="replace($regexp,'.*%[^%]+%','')">
                 <xsl:matching-substring>
                      <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),'default',$current,$numbered)}">
                      </w:fldSimple>
<!--                    <xsl:message>regex2:<xsl:value-of select="regex-group(2)"/></xsl:message> -->
                      <xsl:if test="regex-group(4) != ''">
                      <w:r>
                        <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                      </w:r>
                      </xsl:if>
                 </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:if test="$string-before-regexp != ''">
          <xsl:sequence select="$string-before-regexp"/>
        </xsl:if>
        <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
        </w:fldSimple>
<!--           <w:r> -->
<!--             <w:t xml:space="preserve"><xsl:value-of select="' '"/></w:t> -->
<!--           </w:r> -->
        <xsl:if test="$string-after-regexp != ''">
         <xsl:sequence select="$string-after-regexp"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
</xsl:function>

<!--
Automates the creation of a prefix for a ps:para defined by the expression set in configuration for default documents.

@param indent-level the value of the current para indent
@param current the value of the current node
@param numbered the value of the current numbered attribute

@return the real regular expression value
-->
<xsl:function name="fn:para-prefix-value-for-default-document" >
  <xsl:param name="indent-level"/>
  <xsl:param name="current"/>
  <xsl:param name="numbered"/>

  <xsl:variable name="current-indent">
    <xsl:choose>
      <xsl:when test="not($indent-level)">
        <xsl:value-of select="'0'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$indent-level"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
     <xsl:when test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix[@select = 'true']/fieldcode">
        <xsl:variable name="type" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix/fieldcode/@type"/>
        <xsl:variable name="name" select="concat('default-para',$current-indent)"/>
        <xsl:variable name="regexp" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix/fieldcode/@regexp"/>
        <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
        <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
        <xsl:variable name="flags">
         <xsl:choose>
            <xsl:when test="$current/preceding::para[@prefix][ancestor::document[1]/not(.//labels)]
            [number(@indent) &lt;= number($current-indent)][1]
            [number(@indent) = number($current-indent)]/@prefix != ''">
              <xsl:variable name="precedingparavalue" select="$current/preceding::para[ancestor::document[1]/not(.//labels)][@indent &lt;= number($current-indent)][1][@indent = number($current-indent)]/@prefix"/>
              <xsl:choose>
                <xsl:when test="number(fn:get-number-from-regexp($precedingparavalue,$regexp,$real-regular-expression)) + 1 = number(fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))">
                  <xsl:value-of select="'\n'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="string-before-regexp">
          <xsl:choose>
            <xsl:when test="substring-before($regexp,'%') !=''">
              <xsl:variable name="regexp-before" select="concat('(',substring-before($regexp,'%'),').*')"/>
              <xsl:analyze-string regex="({$regexp-before})" select="replace($current/@prefix,'&#160;',' ')">
                 <xsl:matching-substring>
                   <xsl:value-of select="regex-group(2)"/>
                 </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:variable>


        <xsl:variable name="string-after-regexp">
          <xsl:choose>
            <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
              <xsl:variable name="regexp-after" select="concat('.*(',replace($regexp,'.*%[^%]+%',''),')')"/>
              <xsl:analyze-string regex="({$regexp-after})" select="replace($current/@prefix,'&#160;',' ')">
                 <xsl:matching-substring>
                   <xsl:value-of select="regex-group(2)"/>
                 </xsl:matching-substring>
               </xsl:analyze-string>
             </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="''"/>
              </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="$string-before-regexp != ''">
          <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-before-regexp"/></w:t>
        </w:r>
        </xsl:if>
        <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
        </w:fldSimple>
        <xsl:if test="$string-after-regexp != ''">
          <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-after-regexp"/></w:t>
        </w:r>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix[@select = 'true']">
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t>
        </w:r>
      </xsl:when>
      <xsl:when test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix[@select = 'false']">
<!--           <w:r> -->
<!--             <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t> -->
<!--           </w:r> -->
      </xsl:when>
      <xsl:otherwise>
        <w:r>
          <w:t xml:space="preserve"/>
        </w:r>
      </xsl:otherwise>
    </xsl:choose>
</xsl:function>

<!--
  Automates the creation of a numbered value for a ps:para defined by the expression set in configuration for prefix documents.

  @param indent-level the value of the current para indent
  @param current the value of the current node
  @param numbered the value of the current numbered attribute

  @return the real regular expression value
-->
<xsl:function name="fn:para-numbered-value-for-default-document" >
  <xsl:param name="indent-level"/>
  <xsl:param name="current"/>
  <xsl:param name="numbered"/>

  <xsl:variable name="current-indent">
    <xsl:choose>
      <xsl:when test="not($indent-level)">
        <xsl:value-of select="'0'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$indent-level"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
     <xsl:when test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/numbered[@select = 'true']/fieldcode">
        <xsl:variable name="type" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/numbered/fieldcode/@type"/>
        <xsl:variable name="name" select="concat('default-para-num',$current-indent)"/>
        <xsl:variable name="regexp" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/numbered/fieldcode/@regexp"/>
        <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
        <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
        <xsl:variable name="flags">
          <xsl:choose>
            <xsl:when test="$current/preceding::para[@numbered][1][@indent &lt; $current-indent]">
              <xsl:value-of select="'\r 1'"/>
            </xsl:when>
            <xsl:when test="$current/preceding::heading[1]">
              <xsl:variable name="preceding-heading" select="$current/preceding::heading[1]"/>
              <xsl:choose>
                <xsl:when test="$preceding-heading/following::para[following::*[generate-id() = generate-id($current)]][@indent &lt;= $current-indent]">
                  <xsl:value-of select="'\n'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="'\r 1'"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="'\r 1'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'\n'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="string-before-regexp">
          <xsl:choose>
            <xsl:when test="substring-before($regexp,'%') !=''">
              <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="substring-before($regexp,'%')">
                 <xsl:matching-substring>
                      <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),'default',$current,$numbered)}">
                      </w:fldSimple>
                      <xsl:if test="regex-group(4) != ''">
                      <w:r>
                        <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                      </w:r>
                      </xsl:if>
                 </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>


        <xsl:variable name="string-after-regexp">
          <xsl:choose>
            <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
              <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="replace($regexp,'.*%[^%]+%','')">
                 <xsl:matching-substring>
                      <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),'default',$current,$numbered)}">
                      </w:fldSimple>
                      <xsl:if test="regex-group(4) != ''">
                      <w:r>
                        <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                      </w:r>
                      </xsl:if>
                 </xsl:matching-substring>
               </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:if test="$string-before-regexp != ''">
          <xsl:sequence select="$string-before-regexp"/>
        </xsl:if>
        <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
        </w:fldSimple>
<!--           <w:r> -->
<!--             <w:t xml:space="preserve"><xsl:value-of select="' '"/></w:t> -->
<!--           </w:r> -->
        <xsl:if test="$string-after-regexp != ''">
         <xsl:sequence select="$string-after-regexp"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
</xsl:function>

<!--
Generates the field code formula based on params

@param field-type the type of the fieldcode
@param field-name-value document label or default
@param current the value of the current node
@param numbered the value of the current numbered attribute

@return the field code value
-->
<xsl:function name="fn:get-field-code">
  <xsl:param name="field-type" />
  <xsl:param name="field-name-value" />
  <xsl:param name="current" />
  <xsl:param name="numbered" />
  <xsl:variable name="type" select="tokenize(string($field-type), '-')[1]"/>
  <xsl:variable name="level" select="tokenize(string($field-type), '-')[2]"/>

  <xsl:choose>
    <xsl:when test="$field-name-value = 'default'">
      <xsl:choose>
        <xsl:when test="$type = 'heading'">
          <xsl:variable name="type" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$level]/numbered/fieldcode/@type"/>
          <xsl:variable name="name" select="concat($field-name-value,'-heading-num',$level)"/>
          <xsl:variable name="regexp" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$level]/numbered/fieldcode/@regexp"/>
          <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
          <xsl:variable name="flags">
            <xsl:choose>
              <xsl:when test="$current/preceding::heading[@level &lt; $level]">
                <xsl:variable name="preceding-lower-heading" select="$current/preceding::heading[@level &lt; $level]"/>
                <xsl:choose>
                  <xsl:when test="$preceding-lower-heading[not(following::heading[@level = $level][following::*[generate-id() = generate-id($current)]])]">
                    <xsl:value-of select="'\r 0'"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="'\c'"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'\c'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:value-of select="concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)"/>
        </xsl:when>
        <xsl:when test="$type = 'para'">
          <xsl:variable name="type" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$level]/numbered/fieldcode/@type"/>
          <xsl:variable name="name" select="concat($field-name-value,'-para-num',$level)"/>
          <xsl:variable name="regexp" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$level]/numbered/fieldcode/@regexp"/>
          <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
          <xsl:variable name="flags" select="'\c'"/>
          <xsl:value-of select="concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$type = 'heading'">
          <xsl:variable name="type" select="$config-doc/config/elements[@label = $field-name-value]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$level]/numbered/fieldcode/@type"/>
          <xsl:variable name="name" select="concat($field-name-value,'-heading-num',$level)"/>
          <xsl:variable name="regexp" select="$config-doc/config/elements[@label = $field-name-value]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$level]/numbered/fieldcode/@regexp"/>
          <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
          <xsl:variable name="flags">
            <xsl:choose>
              <xsl:when test="$current/preceding::heading[@level &lt; $level]">
                <xsl:variable name="preceding-lower-heading" select="$current/preceding::heading[@level &lt; $level]"/>
                <xsl:choose>
                  <xsl:when test="$preceding-lower-heading[not(following::heading[@level = $level][following::*[generate-id() = generate-id($current)]])]">
                    <xsl:value-of select="'\r 0'"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="'\c'"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'\c'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:value-of select="concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)"/>
        </xsl:when>
        <xsl:when test="$type = 'para'">
          <xsl:variable name="type" select="$config-doc/config/elements[@label = $field-name-value]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$level]/numbered/fieldcode/@type"/>
          <xsl:variable name="name" select="concat($field-name-value,'-para-num',$level)"/>
          <xsl:variable name="regexp" select="$config-doc/config/elements[@label = $field-name-value]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$level]/numbered/fieldcode/@regexp"/>
          <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
          <xsl:variable name="flags" select="'\c'"/>
          <xsl:value-of select="concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:otherwise>
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
    <xsl:analyze-string regex="({$real-regexp})" select="replace($prefix,'&#160;',' ')">
      <xsl:matching-substring>
        <xsl:value-of select="regex-group(2)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="matches($user-regexp,'arabic')">
      <xsl:value-of select="$prefix-value"/>
    </xsl:when>
    <xsl:when test="matches($user-regexp,'upperletter|lowerletter')">
      <xsl:value-of select="fn:alpha-to-integer($prefix-value,1)"/>
    </xsl:when>
    <xsl:when test="matches($user-regexp,'lowerroman|upperroman')">
      <xsl:value-of select="fn:roman-to-integer($prefix-value,1)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
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
<xsl:function name="fn:alpha-to-integer">
 <xsl:param name="alpha-number" />
 <xsl:param name="index" />
 <xsl:variable name="temp">
  <xsl:value-of select="fn:to-alpha($index)"/>
 </xsl:variable>
 <xsl:choose>
   <xsl:when test="$temp = $alpha-number">
     <xsl:value-of select="$index" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="fn:alpha-to-integer($alpha-number,$index + 1)" />
   </xsl:otherwise>
 </xsl:choose>
</xsl:function>

<!--
  Returns the alpha value of a numeric value

  @param value the current integer value

  @return the alpha value
-->
<xsl:function name="fn:to-alpha">
  <xsl:param name="value"/>
  <xsl:number value="$value" format="A"/>
</xsl:function>

<!--
  Returns the configured ps:title w:style for document label specific documents

  @param document-label the current document label

  @return the w:style
-->
<xsl:function name="fn:title-wordstyle-for-document-label">
  <xsl:param name="document-label"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/title/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/title/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:title w:style for default documents

  @return the w:style
-->
<xsl:function name="fn:title-wordstyle-for-default-document">
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/title/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/title/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:list w:style for document label specific documents

  @param document-label the current document label
  @param list-role the current list role
  @param list-level the current list level
  @param list-type list or nlist

  @return the w:style
-->
<xsl:function name="fn:list-wordstyle-for-document-label">
  <xsl:param name="document-label"/>
  <xsl:param name="list-role"/>
  <xsl:param name="list-level"/>
  <xsl:param name="list-type"/>
  <xsl:choose>
    <xsl:when test="$list-role != '' and $config-doc/config/elements[@label = $document-label]/*[name() = $list-type]/role[@value=$list-role]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/*[name() = $list-type]/role[@value=$list-role]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/*[name() = $list-type]/level[@value=$list-level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/*[name() = $list-type]/level[@value=$list-level]/@wordstyle" />
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
<xsl:function name="fn:list-wordstyle-for-default-document">
  <xsl:param name="list-role"/>
  <xsl:param name="list-level"/>
  <xsl:param name="list-type"/>
  <xsl:choose>
    <xsl:when test="$list-role != '' and $config-doc/config/elements[not(@label)]/*[name() = $list-type]/role[@value=$list-role]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/*[name() = $list-type]/role[@value=$list-role]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/*[name() = $list-type]/level[@value=$list-level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/*[name() = $list-type]/level[@value=$list-level]/@wordstyle" />
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
<xsl:function name="fn:default-list-wordstyle">
  <xsl:param name="list-level"/>
  <xsl:param name="list-type"/>
  <xsl:choose>
    <xsl:when test="$list-level = 1">
      <xsl:choose>
        <xsl:when test="$list-type = 'nlist'">
          <xsl:value-of select="'List Number'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'List Bullet'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$list-level = 2">
      <xsl:choose>
        <xsl:when test="$list-type = 'nlist'">
          <xsl:value-of select="'List Number 2'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'List Bullet 2'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$list-level = 3">
      <xsl:choose>
        <xsl:when test="$list-type = 'nlist'">
          <xsl:value-of select="'List Number 3'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'List Bullet 3'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$list-level = 4">
      <xsl:choose>
        <xsl:when test="$list-type = 'nlist'">
          <xsl:value-of select="'List Number 4'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'List Bullet 4'" />
        </xsl:otherwise>
        </xsl:choose>
    </xsl:when>
    <xsl:when test="$list-level = 5">
      <xsl:choose>
        <xsl:when test="$list-type = 'nlist'">
          <xsl:value-of select="'List Number 5'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'List Bullet 5'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$list-level = 6">
      <xsl:choose>
        <xsl:when test="$list-type = 'nlist'">
          <xsl:value-of select="'List Number 6'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'List Bullet 6'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$list-level = 7">
      <xsl:choose>
        <xsl:when test="$list-type = 'nlist'">
          <xsl:value-of select="'List Number 7'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'List Bullet 7'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$list-level = 8">
      <xsl:choose>
        <xsl:when test="$list-type = 'nlist'">
          <xsl:value-of select="'List Number 8'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'List Bullet 8'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$list-type = 'nlist'">
          <xsl:value-of select="'List Number 9'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'List Bullet 9'" />
        </xsl:otherwise>
      </xsl:choose>
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
<xsl:function name="fn:para-wordstyle-for-document-label">
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="numbered"/>
  <xsl:param name="prefix"/>
  <xsl:choose>
    <xsl:when
      test="not($indent-level) and $config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (numbered/@select =  $numbered) else not(numbered)][if($prefix) then prefix else not(prefix)][@level='0']/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (numbered/@select =  $numbered) else not(@numbered)][if($prefix) then prefix else not(prefix)][@level='0']/@wordstyle" />
    </xsl:when>
    <xsl:when
      test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (numbered/@select =  $numbered) else not(numbered)][if($prefix) then prefix else not(prefix)][@level=$indent-level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (numbered/@select =  $numbered) else not(numbered)][if($prefix) then prefix else not(prefix)][@level=$indent-level]/@wordstyle" />
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
<xsl:function name="fn:para-wordstyle-for-default-document">
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
 <xsl:function name="fn:get-style-from-role">
  <xsl:param name="role"/>
  <xsl:param name="current" as="node()"/>
  <xsl:variable name="document-label" select="$current/ancestor::document[1]/documentinfo/uri/labels"/>
  <xsl:variable name="list-type" select="$current/name()"/>
  <xsl:variable name="level" select="count($current/ancestor::*[name() = 'nlist' or name() = 'list']) + 1"/>
  <xsl:choose>
    <xsl:when test="$document-label != '' and $config-doc/config/elements[@label = $document-label]/*[name()=$list-type]/role[@value=$role]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/*[name()=$list-type]/role[@value=$role]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$document-label != '' and $config-doc/config/elements[@label = $document-label]/*[name()=$list-type]/default/level[@value=$level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[@label = $document-label]/*[name()=$list-type]/default/level[@value=$level]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/*[name()=$list-type]/role[@value=$role]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/*[name()=$list-type]/role[@value=$role]/@wordstyle" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/*[name()=$list-type]/default/level[@value=$level]/@wordstyle">
      <xsl:value-of select="$config-doc/config/elements[not(@label)]/*[name()=$list-type]/default/level[@value=$level]/@wordstyle" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the configured ps:(n)list w:lvl for a specific role

  @param role the current list role
  @param current the current node

  @return the w:lvl
-->
<xsl:function name="fn:get-level-from-role">
  <xsl:param name="role"/>
  <xsl:param name="current" as="node()"/>
  <xsl:variable name="document-label" select="$current/ancestor::document[1]/documentinfo/uri/labels"/>
  <xsl:variable name="list-type" select="$current/parent::*/name()"/>
  <xsl:variable name="level" select="count($current/ancestor::*[name() = 'nlist' or name() = 'list']) + 1"/>
  <xsl:choose>
    <xsl:when test="$document-label != '' and $config-doc/config/elements[@label = $document-label]/*[name()=$list-type]/role[@value=$role]/@wordstyle">
      <xsl:value-of select="count(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/w:lvl[w:pStyle/@w:val = $config-doc/config/elements[@label = $document-label]/*[name()=$list-type]/role[@value=$role]/@wordstyle]/preceding-sibling::w:lvl)" />
    </xsl:when>
    <xsl:when test="$document-label != '' and $config-doc/config/elements[@label = $document-label]/*[name()=$list-type]/default/level[@value=$level]/@wordstyle">
      <xsl:value-of select="count(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/w:lvl[w:pStyle/@w:val = $config-doc/config/elements[@label = $document-label]/*[name()=$list-type]/default/level[@value=$level]/@wordstyle]/preceding-sibling::w:lvl)" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/*[name()=$list-type]/role[@value=$role]/@wordstyle">
      <xsl:value-of select="count(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/w:lvl[w:pStyle/@w:val = $config-doc/config/elements[not(@label)]/*[name()=$list-type]/role[@value=$role]/@wordstyle]/preceding-sibling::w:lvl)" />
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/*[name()=$list-type]/default/level[@value=$level]/@wordstyle">
      <xsl:value-of select="count(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/w:lvl[w:pStyle/@w:val = $config-doc/config/elements[not(@label)]/*[name()=$list-type]/default/level[@value=$level]/@wordstyle]/preceding-sibling::w:lvl)" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="''" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  List of all individual ps:lists

  @return a node() witl all of the ps:list and ps:nlist values
-->
<xsl:variable name="all-different-lists" as="node()">
<lists>
  <xsl:for-each select=".//nlist[not(@type) and not(descendant::nlist/@type)][not(ancestor::*[name() = 'list' or name() = 'nlist'])]"> <!--  or @role or @start] -->
      <xsl:variable name="role" select="fn:get-style-from-role(@role,.)"/>
      <xsl:variable name="level" select="count(ancestor::list)+count(ancestor::nlist) + 1"/>
      <xsl:variable name="list-type" select="./name()"/>
      <xsl:variable name="labels">
        <xsl:choose>
          <xsl:when test="ancestor::document[1]/documentinfo/uri/labels">
            <xsl:value-of select="ancestor::document[1]/documentinfo/uri/labels"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="paragraph-style" >
        <xsl:choose>
          <xsl:when test="$role != ''">
            <xsl:value-of select="document(concat($_dotxfolder,$styles-template))//w:style[w:name/@w:val = $role]/@w:styleId"/>
          </xsl:when>
          <xsl:when test="fn:list-wordstyle-for-document-label($labels,@role,$level,$list-type) != ''">
            <xsl:value-of select="fn:list-wordstyle-for-document-label($labels,@role,$level,$list-type)"/>
          </xsl:when>
          <xsl:when test="fn:list-wordstyle-for-default-document(@role,$level,$list-type) != ''">
            <xsl:value-of select="fn:list-wordstyle-for-default-document(@role,$level,$list-type)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="fn:default-list-wordstyle($level,$list-type)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="paragraph-style-name" >
        <xsl:choose>
          <xsl:when test="$role != ''">
            <xsl:value-of select="$role"/>
          </xsl:when>
          <xsl:when test="fn:list-wordstyle-for-document-label($labels,@role,$level,$list-type) != ''">
            <xsl:value-of select="fn:list-wordstyle-for-document-label($labels,@role,$level,$list-type)"/>
          </xsl:when>
          <xsl:when test="fn:list-wordstyle-for-default-document(@role,$level,$list-type) != ''">
            <xsl:value-of select="fn:list-wordstyle-for-default-document(@role,$level,$list-type)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="fn:default-list-wordstyle($level,$list-type)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="paragraph-style" select="document(concat($_dotxfolder,$styles-template))//w:style[w:name/@w:val = $paragraph-style-name]/@w:styleId"/>

      <xsl:choose>
        <xsl:when test="$list-type = 'nlist'">
          <nlist start="{if (@start) then @start else 1}" >
            <xsl:attribute name="level">
                <xsl:value-of select="count(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/w:lvl[w:pStyle/@w:val = $paragraph-style]/preceding-sibling::w:lvl)"/>
            </xsl:attribute>
            <xsl:attribute name="role" select="$role"/>
            <xsl:attribute name="labels" select="$labels"/>
            <xsl:attribute name="level1" select="$level"/>
            <xsl:attribute name="pstylename">
              <xsl:value-of select="$paragraph-style-name"/>
            </xsl:attribute>
            <xsl:attribute name="pstyle">
              <xsl:value-of select="$paragraph-style"/>
            </xsl:attribute>
            <xsl:value-of select="document(concat($_dotxfolder,$numbering-template))//w:abstractNum[w:lvl/w:pStyle/@w:val = $paragraph-style]/@w:abstractNumId"/>
          </nlist>
        </xsl:when>
        <xsl:otherwise>
          <list>
            <xsl:attribute name="level">
              <xsl:value-of select="count(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/w:lvl[w:pStyle/@w:val = $paragraph-style]/preceding-sibling::w:lvl)"/>
            </xsl:attribute>
            <xsl:attribute name="role" select="$role"/>
            <xsl:attribute name="labels" select="$labels"/>
            <xsl:attribute name="level1" select="$level"/>
            <xsl:attribute name="pstylename">
              <xsl:value-of select="$paragraph-style-name"/>
            </xsl:attribute>
            <xsl:attribute name="pstyle">
              <xsl:value-of select="$paragraph-style"/>
            </xsl:attribute>
            <xsl:value-of select="document(concat($_dotxfolder,$numbering-template))//w:abstractNum[w:lvl/w:pStyle/@w:val = $paragraph-style]/@w:abstractNumId"/>
          </list>
        </xsl:otherwise>
      </xsl:choose>

    </xsl:for-each>
  </lists>
</xsl:variable>

<!--
  List of all type of individual ps:lists

  @return a node() with all of the w:abstractNum values
-->
<!-- TODO fix list role not working -->
<xsl:variable name="all-type-lists" as="node()">
  <lists>
  <xsl:for-each select=".//nlist[@role !='' or descendant::nlist/@role !=''][not(ancestor::*[name() = 'list' or name() = 'nlist'])]">
    <xsl:variable name="max-abstract-num" select="max(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/number(@w:abstractNumId))" />
    <w:abstractNum w:abstractNumId="{$max-abstract-num + position()}">
      <w:multiLevelType w:val="multilevel"/>
      <w:styleLink w:val="{concat('pageseeder list style',position())}"/>
      <xsl:variable name="current-list" select="current()" as="node()"/>
      <xsl:variable name="levels" select="'0,1,2,3,4,5,6,7,8'"/>
       <xsl:for-each select="tokenize($levels, ',')">
        <xsl:variable name="current-nlist-level-type" as="xs:string">
          <xsl:choose>
            <xsl:when test="$current-list//*[name() = 'nlist' or name='list'][count(ancestor::*[name() = 'list' or name() = 'nlist']) != NaN]/@type">
              <xsl:value-of select="$current-list//*[name() = 'nlist' or name='list'][count(ancestor::*[name() = 'list' or name() = 'nlist']) = number(.)]/@type"/>
            </xsl:when>
            <xsl:when test="$current-list/@type and number(.) = 0">
              <xsl:value-of select="$current-list/@type"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="current-nlist-level-start" as="xs:string">
          <xsl:choose>
            <xsl:when test="$current-list//*[name() = 'nlist' or name='list'][count(ancestor::*[name() = 'list' or name() = 'nlist']) != NaN]/@start">
              <xsl:value-of select="$current-list//*[name() = 'nlist' or name='list'][count(ancestor::*[name() = 'list' or name() = 'nlist']) = number(.)]/@start"/>
            </xsl:when>
            <xsl:when test="$current-list/@start and number(.) = 0">
              <xsl:value-of select="$current-list/@start"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="current-nlist-level-name">
          <xsl:choose>
            <xsl:when test="$current-list//*[name() = 'nlist' or name='list'][count(ancestor::*[name() = 'list' or name() = 'nlist']) != NaN]/name()">
              <xsl:value-of select="$current-list//*[name() = 'nlist' or name='list'][count(ancestor::*[name() = 'list' or name() = 'nlist']) = number(.)]/name()"/>
            </xsl:when>
            <xsl:when test="$current-list/name() and number(.) = 0">
              <xsl:value-of select="$current-list/name()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$current-nlist-level-type != ''">
            <w:lvl w:ilvl="{.}">
              <w:start w:val="{if ($current-nlist-level-start != '') then $current-nlist-level-start else '1'}"/>
              <w:numFmt w:val="{fn:return-word-numbering-style($current-nlist-level-type)}"/>
              <w:lvlText w:val="%1."/>
              <w:lvlJc w:val="left"/>
              <w:pPr>
                <w:tabs>
                  <w:tab w:val="num" w:pos="{360 * number(.)}"/>
                </w:tabs>
                <w:ind w:left="{360 * number(.)}" w:hanging="360"/>
              </w:pPr>
            </w:lvl>
          </xsl:when>
          <xsl:when test="$current-nlist-level-name = 'list'">
            <w:lvl w:ilvl="{.}">
              <w:start w:val="1"/>
              <w:numFmt w:val="bullet"/>
              <w:lvlText w:val=""/>
              <w:lvlJc w:val="left"/>
              <w:pPr>
                <w:ind w:left="{720 * number(.)}" w:hanging="360"/>
              </w:pPr>
              <w:rPr>
                <w:rFonts w:ascii="Symbol" w:hAnsi="Symbol" w:hint="default"/>
              </w:rPr>
            </w:lvl>
          </xsl:when>
          <xsl:otherwise>
            <w:lvl w:ilvl="{.}">
              <w:start w:val="{if ($current-nlist-level-start != '') then $current-nlist-level-start else 1}"/>
              <w:numFmt w:val="{fn:return-word-numbering-style(.)}"/>
              <w:lvlText w:val="%1."/>
              <w:lvlJc w:val="left"/>
              <w:pPr>
                <w:tabs>
                  <w:tab w:val="num" w:pos="{360 * number(.)}"/>
                </w:tabs>
                <w:ind w:left="{360 * number(.)}" w:hanging="360"/>
              </w:pPr>
            </w:lvl>
          </xsl:otherwise>
       </xsl:choose>
       </xsl:for-each>
     </w:abstractNum>
    </xsl:for-each>

    <xsl:for-each select=".//nlist[@type !='' or descendant::nlist/@type !=''][not(ancestor::*[name() = 'list' or name() = 'nlist'])]">
      <xsl:variable name="max-abstract-num" select="max(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/number(@w:abstractNumId))" />
      <xsl:variable name="max-num-id" select="max(document(concat($_dotxfolder,$numbering-template))//w:num/number(@w:numId))" />
      <w:num w:numId="{$max-num-id + count($all-different-lists/*) + position()}">
        <w:abstractNumId w:val="{$max-abstract-num + position()}"/>
      </w:num>
    </xsl:for-each>
  </lists>
</xsl:variable>

</xsl:stylesheet>