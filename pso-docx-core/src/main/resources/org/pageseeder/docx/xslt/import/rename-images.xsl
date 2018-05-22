<?xml version="1.0" encoding="utf-8"?>
<!--
  Main XSLT module to help rename images inside a word document prior to importing.

  This module assumes that the images are inside the `media` folder.

  @source main Word document
  @output List of images

  @author Hugo Inacio
  @author Christophe Lauret

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:v="urn:schemas-microsoft-com:vml"
                xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
                xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all">

<!-- TODO Move out of import folder into util -->

<xsl:output encoding="utf-8" method="text"/>

<!-- Root folder -->
<xsl:param name="_rootfolder" select="'root'" as="xs:string"/>

<!-- Path to the relationship definitions -->
<xsl:variable name="rels" select="concat($_rootfolder, 'word/_rels/document.xml.rels')" as="xs:string?"/>

<!-- Relationship document -->
<xsl:variable name="relationship-document" select="document($rels)" as="node()"/>

<!--
  Main template processing the `w:drawing` and `w:pict` elements in the document and
-->
<xsl:template match="/">
  <xsl:for-each select=".//w:drawing|.//w:pict//v:shape">
    <xsl:sort select=".//a:graphic/a:graphicData/pic:pic/pic:blipFill/a:blip/@r:embed|.//v:imagedata/@r:id"/>
    <xsl:choose>
      <xsl:when test="matches(wp:inline/wp:docPr/@name,'^\d+$')">
        <xsl:variable name="rid"    select=".//a:graphic/a:graphicData/pic:pic/pic:blipFill/a:blip/@r:embed" />
        <xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target" />
        <xsl:variable name="type"   select="substring-after($target,'.')" />
        <xsl:value-of select="concat($target, '###', $rid, '###', 'media/', wp:inline/wp:docPr/@name,'.',$type, '&#xA;')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="rid"    select=".//a:graphic/a:graphicData/pic:pic/pic:blipFill/a:blip/@r:embed|.//v:imagedata/@r:id"/>
        <xsl:variable name="target" select="$relationship-document/rs:Relationships/rs:Relationship[@Id=$rid]/@Target"/>
        <xsl:value-of select="concat($target, '###', $rid, '&#xA;')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>