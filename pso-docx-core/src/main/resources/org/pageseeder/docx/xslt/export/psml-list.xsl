<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for processing PSML lists

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:config="http://pageseeder.org/docx/config"
                xmlns:fn="http://pageseeder.org/docx/function"
                exclude-result-prefixes="#all">

<!--
  Handles numbered and unordered lists.

  The type of list is handled when processing individual items.

  Note: indenting information is in numbering.xml and determined by list level
-->
<xsl:template match="nlist | list" mode="psml">
  <xsl:apply-templates mode="psml" />
</xsl:template>

<!--
  Handles a list item and creates w:p for each.

  The styles are defined by list role, type or style definition
-->
<xsl:template match="item" mode="psml">
  <xsl:param name="labels" tunnel="yes"/>
  <!-- level of a list item is the number of ancestor list or nlist-->
  <xsl:variable name="level"     select="count(ancestor::list)+count(ancestor::nlist)"/>
  <xsl:variable name="role"      select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/@role"/>
  <xsl:variable name="list-type" select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/name()"/>
  <xsl:choose>
    <xsl:when test="text() or link or bold or italic or sup or sub or xref or inline or image or monospace">
      <xsl:message>DOCX EXPORT ERROR: Inline content inside <item/> must be wrapped in a <para/> (URI ID: <xsl:value-of
        select="/document/documentinfo/uri/@id" />)</xsl:message>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates  mode="psml"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
