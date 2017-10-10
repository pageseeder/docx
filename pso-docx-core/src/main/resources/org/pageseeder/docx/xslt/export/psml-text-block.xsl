<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for processing PSML titles, headings and paragraphs and other block-level content.

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:config="http://pageseeder.org/docx/config"
                xmlns:fn="http://pageseeder.org/docx/function"
                exclude-result-prefixes="#all">

<!--
  Section title is imported as normal text,
  applying the default word heading styles
-->
<xsl:template match="title" mode="psml">
  <w:p>
    <w:pPr>
      <xsl:call-template name="apply-style" />
    </w:pPr>
    <xsl:apply-templates mode="psml" />
  </w:p>
</xsl:template>

<!--
  Headings are imported as normal text, applying the default word heading styles.

  The style is mapped from element name.
-->
<xsl:template match="heading" mode="psml">
  <xsl:param name="labels" tunnel="yes" />
  <xsl:variable name="vanish" select="config:labels-keep-heading-with-next($labels, @level, @numbered) or
      config:default-keep-heading-with-next(@level, @numbered)" />
  <w:p>
    <w:pPr>
      <xsl:call-template name="apply-style" />
      <xsl:if test="$vanish">
        <w:rPr>
          <w:vanish/>
          <w:specVanish/>
        </w:rPr>
      </xsl:if>
    </w:pPr>
    <xsl:if test="@prefix">
      <xsl:choose>
        <xsl:when test="config:heading-prefix-select-for-document-label($labels, @level, @numbered)">
          <xsl:sequence select="fn:heading-prefix-value-for-document-label($labels, @level, current(), @numbered)" />
        </xsl:when>
        <xsl:when test="config:heading-prefix-select-for-default-document(@level, @numbered)">
          <xsl:sequence select="fn:heading-prefix-value-for-default-document(@level, current(), @numbered)" />
        </xsl:when>
        <xsl:otherwise>
          <w:r>
            <w:t xml:space="preserve"><xsl:value-of select="@prefix"/></w:t>
          </w:r>
          <w:r>
            <w:tab/>
          </w:r>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="@numbered = 'true'">
      <xsl:choose>
        <xsl:when test="config:heading-numbered-select-for-document-label($labels, @level, @numbered)">
          <xsl:sequence select="fn:heading-numbered-value-for-document-label($labels, @level, current(), @numbered)" />
        </xsl:when>
        <xsl:when test="config:heading-numbered-select-for-default-document(@level, @numbered)">
          <xsl:sequence select="fn:heading-numbered-value-for-default-document(@level, current(), @numbered)" />
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates mode="psml" />
    <xsl:if test="$vanish">
      <w:r>
        <w:t xml:space="preserve"> </w:t>
      </w:r>      
    </xsl:if>
  </w:p>
</xsl:template>

<!--
  A block is imported as a normal paragraph
-->
<xsl:template match="block" mode="psml">
  <xsl:param name="labels" tunnel="yes" />
  <xsl:param name="cell-align" tunnel="yes" />
  <xsl:choose>
    <!-- when containing other block elements, including mixed content -->
    <!-- will not create w:p here -->
    <xsl:when test="matches(@label, config:block-ignore-labels-with-document-label($labels))"/>
    <xsl:when test="matches(@label, config:default-block-ignore-labels())"/>
    <xsl:when test="fn:has-block-elements(.)">
      <xsl:apply-templates mode="psml" />
    </xsl:when>
    <xsl:when test="node()">
      <xsl:message>DOCX EXPORT ERROR: Inline content inside <block/> must be wrapped in a <para/> (URI ID: <xsl:value-of
        select="/document/documentinfo/uri/@id" />)</xsl:message>
    </xsl:when>
    <!-- empty block only contains style marker for post processing -->
    <xsl:otherwise>
      <w:p>
        <w:pPr>
          <xsl:call-template name="apply-style" />
        </w:pPr>
      </w:p>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  PSML para are treated as normal Word paragraphs
-->
<xsl:template match="para" mode="psml">
  <xsl:param name="labels" tunnel="yes" />
  <xsl:param name="cell-align" tunnel="yes" />
  <!-- if vanish on parent block and last para in block then vanish -->
  <xsl:variable name="vanish-block" select="parent::block and position()=last() and
      (config:labels-keep-block-with-next($labels, parent::block/@label) or
      config:default-keep-block-with-next(parent::block/@label))"/>
  <xsl:variable name="vanish" select="$vanish-block or config:labels-keep-para-with-next($labels, @indent, @numbered)
               or config:default-keep-para-with-next(@indent, @numbered)" />
  <w:p>
    <w:pPr>
      <xsl:if test="$cell-align != '' and (ancestor::cell or ancestor::hcell)">
        <w:jc w:val="{$cell-align}"/>
      </xsl:if>
      <xsl:if test="$vanish">
        <w:rPr>
          <w:vanish/>
          <w:specVanish/>
        </w:rPr>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="ancestor::item">
          <xsl:choose>
            <xsl:when test="position()=1">
              <xsl:call-template name="apply-style" />
              <xsl:variable name="max-num-id">
                <xsl:choose>
                  <xsl:when test="doc-available(concat($_dotxfolder,$numbering-template))">
                    <xsl:value-of select="max(document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num/number(@w:numId))"/>
                  </xsl:when>
                  <xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <w:numPr>
                <w:ilvl w:val="{count(ancestor::list)+count(ancestor::nlist) - 1}" />
                <xsl:variable name="current-pstyle">
                  <xsl:variable name="call-style">
                    <xsl:call-template name="apply-style" />
                  </xsl:variable>
                  <xsl:value-of select="$call-style//@w:val"/>
                </xsl:variable>
                <!-- count ancestor lists of current + preceding lists of the parent list -->
                <w:numId w:val="{$max-num-id + count(./ancestor::*[name() = 'list' or name() = 'nlist']) +
                    count(./ancestor::*[name() = 'list' or name() = 'nlist'][1]/preceding::*[name() = 'list' or name() = 'nlist'])}" />
              </w:numPr>
  
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="list-level" select="count(ancestor::list)+count(ancestor::nlist) + 1"/>
              <xsl:choose>
                <xsl:when test="config:para-list-level-paragraph-for-document-label($labels,$list-level, @numbered) != ''">
                  <xsl:variable name="style-name" select="config:para-list-level-paragraph-for-document-label($labels,$list-level, @numbered)"/>
                  <w:pStyle w:val="{document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style-name]/@w:styleId}"/>
                </xsl:when>
                <xsl:when test="config:para-list-level-paragraph-for-default-document($list-level, @numbered) != ''">
                  <xsl:variable name="style-name" select="config:para-list-level-paragraph-for-default-document($list-level, @numbered)"/>
                  <w:pStyle w:val="{document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $style-name]/@w:styleId}"/>
                </xsl:when>
                <xsl:otherwise>
                  <w:pStyle w:val="BodyText"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="apply-style" />
        </xsl:otherwise>
      </xsl:choose>
    </w:pPr>
    <xsl:if test="@prefix">
      <xsl:choose>
        <xsl:when test="config:para-prefix-select-for-document-label($labels, @indent, @numbered)">
          <xsl:sequence select="fn:para-prefix-value-for-document-label($labels, @indent, current(), @numbered)" />
        </xsl:when>
        <xsl:when test="config:para-prefix-select-for-default-document(@indent, @numbered)">
          <xsl:sequence select="fn:para-prefix-value-for-default-document(@indent, current(), @numbered)" />
        </xsl:when>
        <xsl:otherwise>
          <w:r>
            <w:t xml:space="preserve"><xsl:value-of select="@prefix" /></w:t>
          </w:r>
          <w:r>
            <w:tab/>
          </w:r>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="@numbered = 'true'">
      <xsl:choose>
        <xsl:when test="config:para-numbered-select-for-document-label($labels,@indent,@numbered)">
          <xsl:sequence select="fn:para-numbered-value-for-document-label($labels,@indent,current(),@numbered)" />
        </xsl:when>
        <xsl:when test="config:para-numbered-select-for-default-document(@indent,@numbered)">
          <xsl:sequence select="fn:para-numbered-value-for-default-document(@indent,current(),@numbered)" />
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates mode="psml" />
    <xsl:if test="$vanish">
      <w:r>
        <w:t xml:space="preserve"> </w:t>
      </w:r>      
    </xsl:if>
  </w:p>
</xsl:template>

<!--
  Preformat elements are currently imported as normal paragraphs
-->
<xsl:template match="preformat" mode="psml">
  <xsl:param name="cell-align" tunnel="yes" />
  <w:p>
    <w:pPr>
      <xsl:if test="$cell-align != '' and (ancestor::cell or ancestor::hcell)">
        <w:jc w:val="{$cell-align}"/>
      </xsl:if>
      <xsl:call-template name="apply-style" />
    </w:pPr>
    <xsl:apply-templates mode="psml" />
  </w:p>
</xsl:template>

</xsl:stylesheet>
