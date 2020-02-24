<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for processing PSML links and cross-references.

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:config="http://pageseeder.org/docx/config"
                xmlns:fn="http://pageseeder.org/docx/function"
                exclude-result-prefixes="#all">

<!--
  Inline cross-references
-->
<xsl:template name="xref-content">
  <xsl:param name="labels" tunnel="yes" />
  
  <xsl:choose>

    <!-- Cross-reference to a footnote -->
    <xsl:when test="@documenttype = config:footnotes-documenttype() and $footnote-ids/footnote[@xref=current()/@id]">
      <w:r>
        <w:rPr>
            <w:rStyle w:val="{config:footnote-reference-styleid($labels)}"/>
        </w:rPr>
        <w:footnoteReference w:id="{$footnote-ids/footnote[@xref=current()/@id]/@id}"/>
      </w:r>
    </xsl:when>

    <!-- Cross-reference to a endnote -->
    <xsl:when test="@documenttype = config:endnotes-documenttype() and $endnote-ids/endnote[@xref=current()/@id]">
      <w:r>
        <w:rPr>
            <w:rStyle w:val="{config:endnote-reference-styleid($labels)}"/>
        </w:rPr>
        <w:endnoteReference w:id="{$endnote-ids/endnote[@xref=current()/@id]/@id}"/>
      </w:r>
    </xsl:when>


    <!-- Cross-reference to a citation -->
    <xsl:when test="@documenttype = config:citations-documenttype() and
        $root-document//properties-fragment[@id=substring-after(current()/@href,'#')]">
      <xsl:variable name="pages" select="following-sibling::*[1][local-name()='inline' and @label=config:citations-pageslabel()]" />
      <w:r>
        <w:fldChar w:fldCharType="begin" />
      </w:r>
      <w:r>
        <w:rPr>
            <w:rStyle w:val="{config:citation-reference-styleid($labels)}"/>
        </w:rPr>
        <w:instrText>
          <xsl:attribute name="xml:space">preserve</xsl:attribute>
          <xsl:text>CITATION </xsl:text>
          <xsl:value-of select="substring-after(current()/@href,'#')"/>
          <xsl:if test="$pages">
            <xsl:text> \p "</xsl:text>
            <xsl:value-of select="$pages"/>
            <xsl:text>"</xsl:text>
          </xsl:if>
        </w:instrText>
        <!-- Preserve style after update -->
        <w:instrText xml:space="preserve"> \* MERGEFORMAT </w:instrText>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="separate"/>
      </w:r>
      <w:r>
        <w:rPr>
            <w:rStyle w:val="{config:citation-reference-styleid($labels)}"/>
        </w:rPr>
        <w:t>
          <xsl:value-of select="."/>
          <xsl:if test="$pages">
            <xsl:text> (pp. </xsl:text>
            <xsl:value-of select="$pages"/>
            <xsl:text>)</xsl:text>
          </xsl:if>
        </w:t>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="end" />
      </w:r>
    </xsl:when>

    <!-- Cross-reference to a URL or non-PSML document -->
    <xsl:when test="@external = 'true' or (not(starts-with(@href, '#')) and not(ends-with(@href, '.psml')))">
      <w:r>
        <w:fldChar w:fldCharType="begin" />
      </w:r>
      <w:r>
        <w:instrText xml:space="preserve"> HYPERLINK "<xsl:value-of select="@href" />" </w:instrText>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="separate" />
      </w:r>
      <w:r>
        <w:rPr>
          <w:rStyle w:val="{config:xrefconfig-hyperlink-styleid($labels, @config)}"/>
          <xsl:call-template name="apply-run-style" />
        </w:rPr>
        <w:t><xsl:value-of select="." /></w:t>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="end" />
      </w:r>
    </xsl:when>

    <!-- Cross-reference to a PSML document -->
    <xsl:when test="not(starts-with(@href, '#'))">
      <w:r>
        <w:rPr>
          <w:rStyle w:val="{config:xrefconfig-hyperlink-styleid($labels, @config)}"/>
          <xsl:call-template name="apply-run-style" />
        </w:rPr>
        <w:t xml:space="preserve"><xsl:value-of select="." /></w:t>
      </w:r>
    </xsl:when>

    <!-- Internal cross-reference (i.e. to another fragment) -->
    <xsl:otherwise>
      <xsl:choose>
        <!-- if dynamic link text generate updatable reference -->
        <xsl:when test="@display='template' and
            (contains(@title,'{prefix}') or contains(@title,'{parentnumber}') or contains(@title,'{heading}'))">
          <!-- if link text contains {heading} or {parentnumber} add link for numbering -->
          <xsl:if test="contains(@title,'{prefix}') or contains(@title,'{parentnumber}')">
            <w:r>
              <w:fldChar w:fldCharType="begin"/>
            </w:r>
            <w:r>
              <w:instrText xml:space="preserve"><xsl:value-of select="concat('REF ','f-', substring-after(@href, '#'),' \r \h ')"/></w:instrText>
              <!-- Preserve style after update -->
              <w:instrText xml:space="preserve"> \* MERGEFORMAT </w:instrText>
            </w:r>
            <w:r>
              <w:fldChar w:fldCharType="separate"/>
            </w:r>
            <w:r>
              <w:rPr>
                <w:rStyle w:val="{config:xrefconfig-reference-styleid($labels, @config)}"/>
                <xsl:call-template name="apply-run-style" />
              </w:rPr>
              <w:t><xsl:value-of select="if (@display='template' and contains(@title,'{heading}')) then
                substring-before(.,' ') else ."/></w:t>
            </w:r>
            <w:r>
              <w:fldChar w:fldCharType="end"/>
            </w:r>
          </xsl:if>
          <!-- if both numbering and heading add a space between them -->
          <xsl:if test="(contains(@title,'{prefix}') or contains(@title,'{parentnumber}')) and contains(@title,'{heading}')">
            <w:r>
              <w:t xml:space="preserve"> </w:t>
            </w:r>
          </xsl:if>
          <!-- if link text contains {heading} add link for heading -->
          <xsl:if test="contains(@title,'{heading}')">
            <w:r>
              <w:fldChar w:fldCharType="begin"/>
            </w:r>
            <w:r>
              <w:instrText xml:space="preserve"><xsl:value-of select="concat('REF ','h-', substring-after(@href, '#'),' \h ')"/></w:instrText>
              <!-- Preserve style after update -->
              <w:instrText xml:space="preserve"> \* MERGEFORMAT </w:instrText>
            </w:r>
            <w:r>
              <w:fldChar w:fldCharType="separate"/>
            </w:r>
            <w:r>
              <w:rPr>
                <w:rStyle w:val="{config:xrefconfig-reference-styleid($labels, @config)}"/>
                <xsl:call-template name="apply-run-style" />
              </w:rPr>
              <w:t><xsl:value-of select="if (@display='template' and (contains(@title,'{prefix}') or contains(@title,'{parentnumber}'))) then
                substring-after(.,' ') else ."/></w:t>
            </w:r>
            <w:r>
              <w:fldChar w:fldCharType="end"/>
            </w:r>
          </xsl:if>
        </xsl:when>
        <!-- if force generation if updatable reference -->
        <xsl:when test="config:generate-cross-references()">
          <w:r>
            <w:fldChar w:fldCharType="begin"/>
          </w:r>
          <w:r>
            <w:instrText xml:space="preserve"><xsl:value-of select="concat('REF ','f-', substring-after(@href, '#'),' \h ')"/></w:instrText>
            <!-- Preserve style after update -->
            <w:instrText xml:space="preserve"> \* MERGEFORMAT </w:instrText>
          </w:r>
          <w:r>
            <w:fldChar w:fldCharType="separate"/>
          </w:r>
          <w:r>
            <w:rPr>
              <w:rStyle w:val="{config:xrefconfig-reference-styleid($labels, @config)}"/>
              <xsl:call-template name="apply-run-style" />
            </w:rPr>
            <w:t><xsl:value-of select="if (@display='template' and contains(@title,'{heading}')) then
              substring-before(.,' ') else ."/></w:t>
          </w:r>
          <w:r>
            <w:fldChar w:fldCharType="end"/>
          </w:r>
        </xsl:when>
        <!-- otherwise use hyperlink for fixed text-->
        <xsl:otherwise>
          <w:hyperlink w:anchor="{concat('f-', substring-after(@href, '#'))}" w:history="1">
            <w:r>
              <w:rPr>
                <w:rStyle w:val="{config:xrefconfig-reference-styleid($labels, @config)}"/>
                <xsl:call-template name="apply-run-style" />
              </w:rPr>
              <w:t><xsl:value-of select="." /></w:t>
            </w:r>
          </w:hyperlink>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!--
  Inline cross-references
-->
<xsl:template match="xref" mode="psml">
  <xsl:choose>
    <xsl:when test="not(@type='alternate') and
        exists(document | fragment | media-fragment | xref-fragment | properties-fragment)">
      <xsl:apply-templates mode="psml"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="xref-content" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Handles blockxref transformations
-->
<xsl:template match="blockxref" mode="psml">
  <xsl:choose>
    <xsl:when test="@mediatype = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' and $manual-master = 'true'">
      <w:p>
        <w:pPr>
          <xsl:copy-of select="document(concat($_dotxfolder, '/word/document.xml'))//w:body/w:sectPr[last()]"/>
        </w:pPr>
        <w:subDoc r:id="{concat('rId',(count(document($_document-relationship)//*[name() = 'Relationship']) + 2 + count(preceding::blockxref[@mediatype = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'])))}"/>
      </w:p>
    </xsl:when>
    <xsl:when test="document | fragment | media-fragment | xref-fragment | properties-fragment">
      <xsl:apply-templates mode="psml"/>
    </xsl:when>
    <xsl:otherwise>
      <w:p>
        <xsl:call-template name="xref-content" />
      </w:p>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Regular PSML links

  Implementation note: currently only support external link
-->
<xsl:template match="link" mode="psml">
  <xsl:choose>
    <xsl:when test="@href[starts-with(., '#')]">
      <xsl:variable name="internal-reference" select="concat('a-', substring-after(@href, '#'))" />
      <w:hyperlink w:anchor="{$internal-reference}" w:history="1">
        <w:r>
          <w:rPr>
            <w:rStyle w:val="{config:hyperlink-styleid()}"/>
          </w:rPr>
          <w:t xml:space="preserve"><xsl:value-of select="." /></w:t>
        </w:r>
      </w:hyperlink>
    </xsl:when>
    <xsl:when test="@href[not(starts-with(., '#'))]">
      <!-- only process internal link-->
      <w:r>
        <w:fldChar w:fldCharType="begin" />
      </w:r>
      <w:r>
        <w:instrText xml:space="preserve"><xsl:text> HYPERLINK "</xsl:text><xsl:value-of
          select="@href" /><xsl:text>" </xsl:text></w:instrText>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="separate" />
      </w:r>
      <w:r>
        <w:rPr>
          <w:rStyle w:val="{config:hyperlink-styleid()}"/>
        </w:rPr>
        <w:t>
          <xsl:value-of select="."/>
        </w:t>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="end" />
      </w:r>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="psml"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Anchor elements -->
<xsl:template match="anchor" mode="psml">
  <xsl:variable name="bookmark-id" select="fn:bookmark-id(.)"/>
  <w:bookmarkStart w:id="{$bookmark-id}" w:name="a-{@name}"/>
  <w:bookmarkEnd w:id="{$bookmark-id}"/>
</xsl:template>

</xsl:stylesheet>