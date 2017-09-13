<!--
  Main XSLT module to export PSML as DOCX

  Current functionalities:

  1) Default options:
      a) Default Character Style: used to define all character styles that are not set
      b) Default Paragraph Style: used to define all paragraph styles that are not set

  2) Fragments/Sections - create bookmarks for each fragment

  Parameters starting with `_` are supplied by the Java a framework.

  This template expects that the PSML content has already been "unnested":
   * Free text under list items and table cells has been wrapped in `<para>`
   * new lines and line breaks in preformatted block have been normalized to use `<br>`

  @source the PSML document to export as Word
  @output the `word/document.xml` file included in the DOCX format

  @author Hugo Inacio
  @author Christophe Lauret
  @author Philip Rutherford
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dcterms="http://purl.org/dc/terms/" dcterms:W3CDTF="http://purl.org/dc/terms/W3CDTF"
                exclude-result-prefixes="#all">

<!-- XML format: No indent to avoid affecting white-spaces -->
<xsl:output method="xml" version="1.0" indent="no" encoding="UTF-8" standalone="yes" />

<!-- Spaces around block-level elements are ignorable can be stripped -->
<xsl:strip-space elements="root section body document fragment item list nlist block cell hcell xref-fragment blockxref properties-fragment"/>

<!-- We must preserve white-spaces within inline elements -->
<xsl:preserve-space elements="bold italic underline sup sub inline monospace"/>

<!-- TODO: Shouldn't we specify the white-space control for every PSML element?? -->

<!-- Parameter that contains the relative location of any referenced external files -->
<xsl:param name="resourcefolder"/>

<!-- Parameter that chooses to generate master document or not -->
<xsl:param name="manual-master" select="'false'"/>

<!-- Parameter that sets the core property in word -->
<xsl:param name="manual-core"/>

<!-- Parameter that sets the crestor property in word -->
<xsl:param name="manual-creator"/>

<!-- Parameter that sets the revision property in word -->
<xsl:param name="manual-revision"/>

<!-- Parameter that sets the created property in word -->
<xsl:param name="manual-created"/>

<!-- Parameter that sets the version property in word -->
<xsl:param name="manual-version"/>

<!-- Parameter that sets the category property in word -->
<xsl:param name="manual-category"/>

<!-- Parameter that sets the title property in word -->
<xsl:param name="manual-title"/>

<!-- Parameter that sets the subject property in word -->
<xsl:param name="manual-subject"/>

<!-- Parameter that sets the description property in word -->
<xsl:param name="manual-description"/>

<!-- The root folder where the DOCX files will be created -->
<xsl:param name="_outputfolder"/>

<!-- The root folder containing the Word Template files -->
<xsl:param name="_dotxfolder"/>

<!-- The name of the DOCX file to create -->
<xsl:param name="_docxfilename"/>

<!-- The location of the configuration file used -->
<xsl:param name="_configfileurl"/>

<!-- Common utility templates -->
<xsl:include href="export/config.xsl" />
<xsl:include href="export/variables.xsl" />
<xsl:include href="export/apply-styles.xsl" />
<xsl:include href="export/functions.xsl" />

<!-- MathML -->
<xsl:include href="export/mml2omml.xsl" />

<!-- Generate content for DOCX package (other than `document.xml`) -->
<xsl:include href="export/word-numbering.xsl" />
<xsl:include href="export/word-content_types.xsl" />
<xsl:include href="export/word-styles.xsl" />

<!-- Handling PSML elements -->
<xsl:include href="export/psml-document.xsl" />
<xsl:include href="export/psml-image.xsl" />
<xsl:include href="export/psml-link.xsl" />
<xsl:include href="export/psml-list.xsl" />
<xsl:include href="export/psml-table.xsl" />
<xsl:include href="export/psml-text-block.xsl" />
<xsl:include href="export/psml-text-inline.xsl" />
<xsl:include href="export/psml-toc.xsl" />

<!--
  The root node of the psml file
-->
<xsl:template match="/">

  <!-- Creating files to include in the DOCX package -->
  <xsl:call-template name="create-documents" />

  <!-- Processing the PSML-->
  <xsl:apply-templates mode="psml" />

</xsl:template>

</xsl:stylesheet>
