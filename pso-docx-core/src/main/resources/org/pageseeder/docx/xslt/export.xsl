<!--
  This is the default template to import a DOCX document as PSML.

  @author Christophe Lauret
  @version 18 February 2013
  
  Current functionalities:
  
  1) Default options:
      a) Default Character Style: used to define all character styles that are not set
      b) Default Paragraph Style: used to define all paragraph styles that are not set
      
  2) Fragments/Sections - create bookmarks for each fragment
  
  3)  
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"
  xmlns:dfx="http://www.topologi.com/2005/Diff-X" xmlns:del="http://www.topologi.com/2005/Diff-X/Delete" xmlns:ins="http://www.topologi.com/2005/Diff-X/Insert" xmlns:diffx="java:com.topologi.diffx.Extension"
  xmlns:fn="http://www.pageseeder.com/function"  xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" dcterms:W3CDTF="http://purl.org/dc/terms/W3CDTF"
  xmlns:dcmitype="http://purl.org/dc/dcmitype/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="#all">

  <xsl:output method="xml" indent="no" />
  <xsl:strip-space elements="root section body document fragment item list nlist block cell hcell xref-fragment blockxref properties-fragment" />
  <xsl:preserve-space elements="bold italic underline sup sub inline monospace" />

  <!-- Not used 
  <xsl:param name="take-style-from-type-attribute" select="'true'" />
  <xsl:param name="hardcode-bold-and-italic" select="'false'" />
  <xsl:param name="header-text" />
  <xsl:param name="imagemapping" />
  <xsl:param name="stylemapping" />
  <xsl:param name="default-style" select="'Normal'" />
  <xsl:param name="default-table-style" select="'TableNormal'" />
  <xsl:param name="generate-continuation" select="'true'" />-->


  
  
  <!-- Parameter that contains the relative location of any referenced external files -->
  <xsl:param name="resourcefolder" />
  <!-- Parameter that chooses to generate master document or not -->
  <xsl:param name="manual-master" select="'false'"/>
  <!-- Parameter that sets the core property in word -->
  <xsl:param name="manual-core" />
  <!-- Parameter that sets the crestor property in word -->
  <xsl:param name="manual-creator" />
  <!-- Parameter that sets the revision property in word -->
  <xsl:param name="manual-revision" />
  <!-- Parameter that sets the created property in word -->
  <xsl:param name="manual-created" />
  <!-- Parameter that sets the version property in word -->
  <xsl:param name="manual-version" />
  <!-- Parameter that sets the category property in word -->
  <xsl:param name="manual-category" />
  <!-- Parameter that sets the title property in word -->
  <xsl:param name="manual-title" />
  <!-- Parameter that sets the subject property in word -->
  <xsl:param name="manual-subject" />
  <!-- Parameter that sets the description property in word -->
  <xsl:param name="manual-description" />
<!-- The root folder where the DOCX files will be created -->
  <xsl:param name="_outputfolder" />
<!-- The root folder containing the Word Template files -->
  <xsl:param name="_dotxfolder" />
<!-- The name of the DOCX file to create -->
  <xsl:param name="_docxfilename" />
<!-- The location of the configuration file used -->
  <xsl:param name="_configfileurl" />

  <xsl:include href="export/variables.xsl" />
  <xsl:include href="export/document.xsl" />
  <xsl:include href="export/footer.xsl" />
  <xsl:include href="export/header.xsl" />
  <xsl:include href="export/numbering.xsl" />
  <xsl:include href="export/content_types.xsl" />
  <xsl:include href="export/apply-styles.xsl" />
  <xsl:include href="export/functions.xsl" />
  <xsl:include href="export/mml2omml.xsl" />
  <xsl:include href="export/tables.xsl" />
  <xsl:include href="export/images.xsl" />
  <xsl:include href="export/links.xsl" />
  <xsl:include href="export/lists.xsl" />
  <xsl:include href="export/paragraphs.xsl" />
  <xsl:include href="export/formatting.xsl" />
  <xsl:include href="export/styles.xsl" />
  <xsl:include href="export/toc.xsl" />
  


<!-- The date of the current exported document -->
  <xsl:variable name="document-date" select="document/@date" />
   
  
<!-- [content_types].xml ====================================================================== -->

  <xsl:output method="xml" version="1.0" indent="no" encoding="UTF-8" standalone="yes" />


<!--
  The root node of the psml file
-->
  <xsl:template match="/">
    <xsl:variable name="maincontext" select="current()" />
    <xsl:result-document href="{concat($_outputfolder,'../','output/numbering.xml')}">
      <lists>
        <xsl:for-each select=".//nlist[@start]">
          <xsl:variable name="role" select="fn:get-style-from-role(@role,.)" />
          <nlist start="{@start}">
            <xsl:attribute name="level">
                    <xsl:value-of select="count(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/w:lvl[w:pStyle/@w:val = $role]/preceding-sibling::w:lvl)" />
                </xsl:attribute>
            <xsl:value-of select="document(concat($_dotxfolder,$numbering-template))//w:abstractNum[w:lvl/w:pStyle/@w:val = $role]/@w:abstractNumId" />
          </nlist>
        </xsl:for-each>
        <xsl:for-each select=".//list[@start]">
          <xsl:variable name="role" select="fn:get-style-from-role(@role,.)" />
          <list start="{@start}">
            <xsl:attribute name="level">
                    <xsl:value-of select="count(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/w:lvl[w:pStyle/@w:val = $role]/preceding-sibling::w:lvl)" />
                </xsl:attribute>
            <xsl:value-of select="document(concat($_dotxfolder,$numbering-template))//w:abstractNum[w:lvl/w:pStyle/@w:val = $role]/@w:abstractNumId" />
          </list>
        </xsl:for-each>
      </lists>
    </xsl:result-document>
    <xsl:variable name="word-documents" select="if($manual-master = 'true') then count(.//blockxref[@mediatype = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']) else 0"/>
    <xsl:call-template name="create-documents" >
      <xsl:with-param name="word-documents" select="$word-documents" tunnel="yes"/>
    </xsl:call-template>
    <xsl:apply-templates mode="content" >
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
