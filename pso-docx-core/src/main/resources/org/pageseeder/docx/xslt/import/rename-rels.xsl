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
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all">

<!-- TODO Move to utility folder instead of import -->

<!-- Name of the file where the list of images is stored -->
<xsl:param name="_imagelist" select="'root'" as="xs:string"/>

<!-- Name of the file where the list of images is stored -->
<xsl:variable name="imagelistdocument" select="unparsed-text($_imagelist,'UTF-8')"/>

<!-- Lines in the image list document -->
<xsl:variable name="lines" select="if($imagelistdocument) then tokenize($imagelistdocument, '\n') else 'NONE'" as="xs:string+" />

<!-- TODO Refactor, to generate XML directly instead of generating and parsing plain text -->

<!-- Lines in the image list document as a tree -->
<xsl:variable name="lines-element" as="element(lines)">
  <lines>
  <xsl:for-each select="$lines">
    <line>
      <xsl:for-each select="tokenize(., '###')">
        <xsl:if test="position() = 1">
          <original><xsl:value-of select="."/></original>
        </xsl:if>
        <xsl:if test="position() = 2">
          <id><xsl:value-of select="."/></id>
        </xsl:if>
        <xsl:if test="position() = 3">
          <new><xsl:value-of select="."/></new>
        </xsl:if>
      </xsl:for-each>
    </line>
  </xsl:for-each>
  </lines>
</xsl:variable>

<!-- Template to rename all images if needed -->
<xsl:template match="/">
  <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <xsl:for-each select=".//*[name() = 'Relationship']">
      <xsl:copy-of select=".[@Type!='http://schemas.openxmlformats.org/officeDocument/2006/relationships/image']"/>
    </xsl:for-each>
    <xsl:for-each select=".//*[@Type='http://schemas.openxmlformats.org/officeDocument/2006/relationships/image']">
      <xsl:variable name="id" select="@Id"/>
      <xsl:variable name="target" select="@Target"/>
      <Relationship Target="{if($lines-element//line[id=$id]/new) then ($lines-element//line[id=$id]/new)[1] else $target}">
        <xsl:copy-of select="@*[name() != 'Target']"/>
      </Relationship>
    </xsl:for-each>
  </Relationships>
</xsl:template>

<!-- TODO It look like the template below will never be used! -->

<!-- Recursively copy -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*" />
    <xsl:apply-templates />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>