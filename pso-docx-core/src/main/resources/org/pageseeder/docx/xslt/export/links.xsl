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
                exclude-result-prefixes="#all">


<!--
  Inline cross-references
-->
<xsl:template match="xref" mode="content">
  <xsl:choose>
    <!-- TODO check requirements for generate cross references -->
    <xsl:when test="$generate-cross-references">
      <w:r>
        <w:fldChar w:fldCharType="begin"/>
      </w:r>
      <w:r>
        <w:instrText xml:space="preserve"><xsl:value-of select="concat('REF ',replace(concat(@uriid,if(@frag != 'default') then '_' else '',if(@frag != 'default') then @frag else ''),'\W','_'),' \r \h ')"/></w:instrText>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="separate"/>
      </w:r>
      <w:r>
        <xsl:call-template name="apply-run-style" />
        <w:t><xsl:value-of select="."/></w:t>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </xsl:when>

    <xsl:when test="@external = 'true'">
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
        <xsl:call-template name="apply-run-style" />
        <w:t><xsl:value-of select="." /></w:t>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="end" />
      </w:r>
    </xsl:when>

    <!-- TODO check requirements for mathml processing -->
    <xsl:when test="starts-with(@href,'_external/') and $generate-mathml">
      <!-- External xref: choose to copy or not based on type and config -->
      <xsl:variable name="referenced-document" select="document(@href)" />
      <xsl:choose>
        <xsl:when test="$referenced-document//section/media-fragment[@mediatype='application/mathml+xml'] and $generate-mathml">
          <xsl:variable name="mathml">
            <m:math>
              <xsl:sequence select="$referenced-document//section/media-fragment[@mediatype='application/mathml+xml']/*"/>
            </m:math>
          </xsl:variable>
          <xsl:apply-templates select="$mathml//m:math"/>
        </xsl:when>
        <xsl:otherwise>
          <w:r>
            <xsl:call-template name="apply-run-style" />
            <w:t><xsl:value-of select="." /></w:t>
          </w:r>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:when test="@href[not(starts-with(.,'#'))][not(ends-with(.,'.psml'))]">
      <w:hyperlink w:anchor="{@href}" w:history="1">
        <w:r>
          <w:rPr>
            <xsl:choose>
              <xsl:when test="$xref-style != ''">
                <w:rStyle w:val="{$xref-style}"/>
              </xsl:when>
              <xsl:otherwise>
                <w:color w:val="0000FF"/>
                <w:u w:val="single"/>
              </xsl:otherwise>
            </xsl:choose>
          </w:rPr>
          <w:t xml:space="preserve"><xsl:value-of select="." /></w:t>
        </w:r>
      </w:hyperlink>
    </xsl:when>
    <xsl:when test="@href[not(starts-with(.,'#'))]">
      <!-- only process internal link-->
      <w:r>
        <xsl:call-template name="apply-run-style" />
        <w:t xml:space="preserve"><xsl:value-of select="." /></w:t>
      </w:r>
    </xsl:when>
    <xsl:otherwise>
      <w:hyperlink w:anchor="{concat('fragment-',substring-after(@href,'#'))}" w:history="1">
        <w:r>
          <xsl:choose>
            <xsl:when test="$xref-style != ''">
              <w:rPr>
                <w:rStyle w:val="{$xref-style}"/>
              </w:rPr>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="apply-run-style" />
            </xsl:otherwise>
          </xsl:choose>
          <w:t><xsl:value-of select="." /></w:t>
        </w:r>
      </w:hyperlink>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<!--
  handles blockxref transformations;
  checks also for document labels so that styles are applied accordingly through the configuration
-->
<xsl:template match="blockxref" mode="content">
  <xsl:param name="word-documents" tunnel="yes"/>
  <xsl:choose>
    <xsl:when test="@mediatype = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' and $manual-master = 'true'">
      <w:p>
        <w:pPr>
          <xsl:copy-of select="document(concat($_dotxfolder,'/word/document.xml'))//w:body/w:sectPr[last()]"/>
        </w:pPr>
      </w:p>
      <w:p>
        <w:pPr>
          <xsl:copy-of select="document(concat($_dotxfolder,'/word/document.xml'))//w:body/w:sectPr[last()]"/>
        </w:pPr>
        <w:subDoc r:id="{concat('rId',(count(document($_document-relationship)//*[name() = 'Relationship']) + 2 + count(preceding::blockxref[@mediatype = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'])))}"/>
      </w:p>
    </xsl:when>
    <xsl:when test="document | fragment">
      <xsl:apply-templates mode="content"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- TODO generate internal link if target is internal -->
      <xsl:variable name="content" select="if (@title != '') then @title else @urititle" />
      <w:p>
        <w:r>
          <w:rPr>
            <w:rStyle w:val="reference" />
          </w:rPr>
          <w:t>
            <xsl:value-of select="$content" />
          </w:t>
        </w:r>
      </w:p>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Regular PSML links

  Implementation note: currently only support external link
-->
<xsl:template match="link" mode="content">
  <xsl:choose>
    <xsl:when test="@href[starts-with(.,'#')]">
      <xsl:variable name="internal-reference" select="concat('anchor-',substring-after(@href,'#'))" />
      <w:hyperlink w:anchor="{$internal-reference}" w:history="1">
        <w:r>
          <w:rPr>
          <w:rStyle w:val="Hyperlink"/>
          <w:color w:val="0000FF"/>
          <w:u w:val="single"/>
        </w:rPr>
          <w:t xml:space="preserve"><xsl:value-of select="." /></w:t>
        </w:r>
      </w:hyperlink>
    </xsl:when>
    <xsl:when test="@href[not(starts-with(.,'#'))]">
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
          <xsl:call-template name="apply-style" />
        </w:rPr>
        <w:t>
          <xsl:value-of select="." />
        </w:t>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="end" />
      </w:r>
    </xsl:when>
    <xsl:when test="not(@href) and not(@name)">
      <xsl:apply-templates mode="content"/>
    </xsl:when>
    <xsl:when test="@name">
      <w:bookmarkStart w:name="anchor-{@name}" w:id="{count(preceding::*)}" />
      <w:bookmarkEnd  w:id="{count(preceding::*)}" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="content"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>