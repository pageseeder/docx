<!--
  Main XSLT module to import a DOCX document as PSML.

  This module is applied against the `[content_types].xml` inside a docx package.

  Current functionalities:

  1) Default options:
      a) convert all paragraph styles into:
          i)  para element or
          ii) block element with paragraph style name as a label
      b) convert all character styles into:
          i)  plain text or
          ii) inline element with character style name as a label

  2) Document Split according to:
     a) Selected Section Break
     b) Selected Outline Level
     c) Selected Paragraph Style

     Naming of each file is defined as '[docx_filename]-[document-split-counter]'

  3) Section Split according to:
     a) Selected Section Break
     b) Selected Outline Level
     c) Selected Paragraph Style
     d) ALWAYS break for bookmark ( so that if there is any reference, there will be a section to point to
  
  4) Table of Contents:
      Option to convert or not word TOC ( will be converted as normal sections,paragraphs,xrefs for bookmarks, etc...)
      
  5) Paragraph Styles
      Can be converted into:
        a) Headings
        b) Block elements
        c) Para elements
          i) Para elements can be enumerated with a prefix
        d) Inline elements
        e) Any defined element in the configuration file ( title, etc...) 
        
  6) numbering
     A function for picking up manual numbering is now available [a),b),c);(i),(ii),(iii);1.,2.,3.;etc...] 
     used to number paragraphs and set prefix
      
  7) smartTags are converted and can be:
     a) normal text
     b) inline label     
     
  8) Text runs can be conveted with:
     a) bold
     b) italic
     c) underline
     d) subscript
     e) superscript
     f) with inline label for any text run properties ( Emphasis, Strong, etc...)
        can be:
          i)  A specific inline label
          ii) A pre-defined inline label
  
  9) hyperlinks and bookmarks are converted into xrefs           
  
  10) table styles are saved under the [@role] attribute
  
  11) lists are supported
        TODO: support for named list style as block label
  
  12) images are supported
  
  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"
                exclude-result-prefixes="#all">

<!-- Common utilities -->
<xsl:import href="import/config.xsl" />
<xsl:import href="import/variables.xsl" />
<xsl:import href="import/functions.xsl" />

<!-- Splitting -->
<xsl:import href="import/document-split-processed.xsl" />
<xsl:import href="import/document-split-default.xsl" />
<xsl:import href="import/section-split.xsl" />

<!-- Mapping to PSML elements -->
<xsl:import href="import/psml-document.xsl" />
<xsl:import href="import/psml-headings.xsl" />
<xsl:import href="import/psml-images.xsl" />
<xsl:import href="import/psml-links.xsl" />
<xsl:import href="import/psml-tables.xsl" />
<xsl:import href="import/psml-formatting.xsl" />
<xsl:import href="import/psml-paragraphs.xsl" />
<!-- TODO Changing the order of the import affects results: check for conflicts! -->
<xsl:import href="import/psml-lists.xsl" />

<!-- MathML support -->
<xsl:import href="import/mathml.xsl" />
<xsl:import href="import/omml2mml.xsl" />

<!-- Shapes support -->
<xsl:import href="import/textbox.xsl" />


<!-- Other generated filed -->
<xsl:import href="import/endnotes.xsl" />
<xsl:import href="import/footnotes.xsl" />
<xsl:import href="import/index.xsl" />


<xsl:strip-space elements="*" />
<xsl:preserve-space elements="para block" />

<!-- Root folder -->
<xsl:param name="_rootfolder" select="'root'" as="xs:string"/>

<!-- Output folder -->
<xsl:param name="_outputfolder"  select="'output'" as="xs:string"/>

<!-- Name of the file to import -->
<xsl:param name="_docxfilename"   select="'default-file-name'" as="xs:string"/>

<!-- Name of the configuration file being used -->
<xsl:param name="_configfileurl"  select="'import/wpml-config.xml'" as="xs:string" />

<!-- Name of the media folder to reference images and external files -->
<xsl:param name="_mediafoldername"  select="'media'" as="xs:string" />

<!-- Parameter to define if debug mode is set or not -->
<xsl:param name="debug"  select="false()"  as="xs:boolean"/>

<!-- Parameter to generate only a processed psml file or multiple split files -->
<xsl:param name="generate-processed-psml" select="false()" as="xs:boolean"/>

<!-- [content_types].xml ====================================================================== -->

<xsl:output method="xml" version="1.0" indent="no" encoding="UTF-8" />

<!-- Dummy template to ignore warning issued by Saxon -->
<xsl:template match="ct:Dummy"/>

<xsl:template match="/">
  <xsl:apply-templates select="document($main)" mode="content" />
</xsl:template>

</xsl:stylesheet>
