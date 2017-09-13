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
    <!--  TODO Remove code below and display error message instead -->
    <xsl:when test="text() or link or bold or italic or sup or sub or xref or inline or image or monospace">
      <w:p>
        <w:pPr>
          <xsl:choose>
            <xsl:when test="parent::*[@role]">
              <w:pStyle w:val="{parent::*/@role}"/>
            </xsl:when>
            <xsl:when test="config:list-wordstyle-for-document-label($labels ,$role, $level, $list-type) != ''">
              <w:pStyle w:val="{config:list-wordstyle-for-document-label($labels, $role, $level, $list-type)}"/>
            </xsl:when>
            <xsl:when test="config:list-wordstyle-for-default-document($role, $level, $list-type) != ''">
              <w:pStyle w:val="{config:list-wordstyle-for-default-document($role, $level, $list-type)}"/>
            </xsl:when>
            <xsl:otherwise>
              <w:pStyle w:val="{fn:default-list-wordstyle($level, $list-type)}"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:variable name="max-num-id">
            <xsl:choose>
              <xsl:when test="doc-available(concat($_dotxfolder,$numbering-template))">
                <xsl:value-of select="max(document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num/number(@w:numId))"/>
              </xsl:when>
              <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <w:numPr>
            <xsl:variable name="adjusted-level">
              <xsl:choose>
                <xsl:when test="parent::*[@role]">
                  <xsl:value-of select="config:get-level-from-role(parent::*/@role, .)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="count(ancestor::list)+count(ancestor::nlist) - 1"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <w:ilvl w:val="{$adjusted-level}" />
            <xsl:variable name="current-num-id">
              <xsl:choose>
                <xsl:when test="parent::*[@role]">
                  <xsl:value-of select="$max-num-id + count(preceding::*[name()='list' or name()='nlist'][@start]) + 1"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$max-num-id + count(ancestor::*[name()='list' or name()='nlist'][last()]/
                                        preceding::*[name()='list' or name()='nlist']
                                        [not(ancestor::list or ancestor::nlist)]) + 1"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <w:numId w:val="{$current-num-id}" />
          </w:numPr>
        </w:pPr>
        <!-- Process all possible inline elements that can be included in the paragraph -->
        <xsl:apply-templates select="text() | link | bold | italic | sup | sub | xref | inline | image | monospace"  mode="psml"/>
      </w:p>
      <!-- Sub-lists outside the para -->
      <xsl:apply-templates select="list|nlist" mode="psml"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates  mode="psml"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
