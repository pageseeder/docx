<!--
  Main XSLT module to export PSML as DOCX

  Current functionalities:

  1) Default options:
      a) Default Character Style: used to define all character styles that are not set
      b) Default Paragraph Style: used to define all paragraph styles that are not set

  2) Fragments/Sections - create bookmarks for each fragment

  @author Hugo Inacio
  @author Christophe Lauret
  @author Philip Rutherford
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://www.pageseeder.com/function"
                xmlns:dcterms="http://purl.org/dc/terms/" dcterms:W3CDTF="http://purl.org/dc/terms/W3CDTF"
                exclude-result-prefixes="#all">

<!-- XML format: No indent to avoid affecting white-spaces -->
<xsl:output method="xml" version="1.0" indent="no" encoding="UTF-8" standalone="yes" />

<!-- Spaces around block-level elements are ignorable can be stripped -->
<xsl:strip-space elements="root section body document fragment item list nlist block cell hcell xref-fragment blockxref properties-fragment"/>

<!-- We must preserve white-spaces within inline elements -->
<xsl:preserve-space elements="bold italic underline sup sub inline monospace"/>

<!-- TODO: Shouldn't we specified the white-space control for every PSML element?? -->

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

<xsl:include href="export/variables.xsl" />
<xsl:include href="export/footer.xsl" />
<xsl:include href="export/header.xsl" />
<xsl:include href="export/numbering.xsl" />
<xsl:include href="export/content_types.xsl" />
<xsl:include href="export/apply-styles.xsl" />
<xsl:include href="export/functions.xsl" />
<xsl:include href="export/mml2omml.xsl" />

<!-- Handling PSML elements -->
<xsl:include href="export/psml-document.xsl" />
<xsl:include href="export/psml-image.xsl" />
<xsl:include href="export/psml-link.xsl" />
<xsl:include href="export/psml-list.xsl" />
<xsl:include href="export/psml-table.xsl" />
<xsl:include href="export/psml-text-block.xsl" />
<xsl:include href="export/psml-text-inline.xsl" />
<xsl:include href="export/psml-toc.xsl" />


<xsl:include href="export/styles.xsl" />




<!-- The date of the current exported document -->
<xsl:variable name="document-date" select="document/@date" />


<!--
  The root node of the psml file
-->
<xsl:template match="/">
  <xsl:result-document href="{concat($_outputfolder, '../output/numbering.xml')}">
    <lists>
      <xsl:for-each select=".//nlist[@start]">
        <xsl:variable name="role" select="fn:get-style-from-role(@role, .)" />
        <nlist start="{@start}">
          <!-- TODO Simplify code -->
          <xsl:attribute name="level">
            <xsl:value-of select="count(document(concat($_dotxfolder, $numbering-template))//w:abstractNum/w:lvl[w:pStyle/@w:val = $role]/preceding-sibling::w:lvl)" />
          </xsl:attribute>
          <xsl:value-of select="document(concat($_dotxfolder, $numbering-template))//w:abstractNum[w:lvl/w:pStyle/@w:val = $role]/@w:abstractNumId" />
        </nlist>
      </xsl:for-each>
      <xsl:for-each select=".//list[@start]">
        <xsl:variable name="role" select="fn:get-style-from-role(@role, .)" />
        <list start="{@start}">
          <!-- TODO Simplify code -->
          <xsl:attribute name="level">
            <xsl:value-of select="count(document(concat($_dotxfolder, $numbering-template))//w:abstractNum/w:lvl[w:pStyle/@w:val = $role]/preceding-sibling::w:lvl)" />
          </xsl:attribute>
          <xsl:value-of select="document(concat($_dotxfolder, $numbering-template))//w:abstractNum[w:lvl/w:pStyle/@w:val = $role]/@w:abstractNumId" />
        </list>
      </xsl:for-each>
    </lists>
  </xsl:result-document>
  <xsl:variable name="word-documents" select="if($manual-master = 'true') then count(.//blockxref[@mediatype = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']) else 0"/>
  <xsl:call-template name="create-documents" >
    <xsl:with-param name="word-documents" select="$word-documents" tunnel="yes"/>
  </xsl:call-template>
  <xsl:apply-templates mode="psml">
    <xsl:with-param name="word-documents" select="$word-documents" tunnel="yes"/>
  </xsl:apply-templates>
</xsl:template>

<!-- Template to copy each node recursively -->
<xsl:template match="* | @*" mode="copy">
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="copy" />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
