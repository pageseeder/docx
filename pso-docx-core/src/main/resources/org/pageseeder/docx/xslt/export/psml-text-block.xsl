<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for processing PSML titles, headings and paragraphs and other block-level content.

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://www.pageseeder.com/function"
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
  <w:p>
    <w:pPr>
      <xsl:call-template name="apply-style" />
      <xsl:choose>
        <xsl:when test="fn:labels-keep-heading-with-next($labels,@level, @numbered)">
          <w:rPr>
            <w:vanish/>
            <w:specVanish/>
          </w:rPr>
        </xsl:when>
        <xsl:when test="fn:default-keep-heading-with-next(@level, @numbered)">
          <w:rPr>
            <w:vanish/>
            <w:specVanish/>
          </w:rPr>
        </xsl:when>
      </xsl:choose>
    </w:pPr>
    <!-- TODO check how prefixes work -->
    <xsl:if test="@prefix">
      <xsl:choose>
        <xsl:when test="fn:heading-prefix-select-for-document-label($labels, @level, @numbered)">
          <xsl:sequence select="fn:heading-prefix-value-for-document-label($labels, @level, current(), @numbered)" />
        </xsl:when>
        <xsl:when test="fn:heading-prefix-select-for-default-document(@level, @numbered)">
          <xsl:sequence select="fn:heading-prefix-value-for-default-document(@level, current(), @numbered)" />
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="@numbered = 'true'">
      <xsl:choose>
        <xsl:when test="fn:heading-numbered-select-for-document-label($labels, @level, @numbered)">
          <xsl:sequence select="fn:heading-numbered-value-for-document-label($labels, @level, current(), @numbered)" />
        </xsl:when>
        <xsl:when test="fn:heading-numbered-select-for-default-document(@level, @numbered)">
          <xsl:sequence select="fn:heading-numbered-value-for-default-document(@level, current(), @numbered)" />
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:apply-templates mode="psml" />
  </w:p>
</xsl:template>

<!--
  A block is imported as a normal paragraph
-->
<xsl:template match="block" mode="psml">
  <xsl:param name="labels" tunnel="yes" />
  <xsl:param name="cell-align" tunnel="yes" />
    <!--
      if paraLabel contains only inline elements or text, create w:p here,
    -->
  <xsl:choose>
    <!-- when containing other block elements, including mixed content -->
    <!-- will not create w:p here -->
    <xsl:when test="matches(@label, fn:block-ignore-labels-with-document-label($labels))"/>
    <xsl:when test="matches(@label, fn:default-block-ignore-labels())"/>
    <xsl:when test="fn:has-block-elements(.)">
      <xsl:apply-templates mode="psml" />
    </xsl:when>
    <xsl:otherwise>
      <!-- when containing only inline elements or text()-->
      <w:p>
        <w:pPr>
          <xsl:if test="$cell-align != '' and  (ancestor::cell or ancestor::hcell)">
             <w:jc w:val="{$cell-align}"/>
          </xsl:if>
          <xsl:call-template name="apply-style" />
          <xsl:choose>
            <xsl:when test="fn:labels-keep-block-with-next($labels, @label) or fn:default-keep-block-with-next(@label)">
              <w:rPr>
                <w:vanish/>
                <w:specVanish/>
              </w:rPr>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="ancestor::item">
            <xsl:choose>
              <xsl:when test="position()=1">
                <w:numPr>
                  <w:ilvl w:val="{count(ancestor::list)+count(ancestor::nlist)-1}" />
                  <w:numId w:val="{fn:get-numbering-id(current())}" />
                </w:numPr>
              </xsl:when>
              <xsl:otherwise>
                <w:ind w:left="{720*(count(ancestor::list)+count(ancestor::nlist))}" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </w:pPr>
        <xsl:apply-templates mode="psml" />
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
  <w:p>
    <w:pPr>
      <xsl:if test="$cell-align != '' and (ancestor::cell or ancestor::hcell)">
        <w:jc w:val="{$cell-align}"/>
      </xsl:if>
      <xsl:if test="fn:labels-keep-para-with-next($labels, @indent, @numbered)
                 or fn:default-keep-para-with-next(@indent, @numbered)">
        <w:rPr>
          <w:vanish/>
          <w:specVanish/>
        </w:rPr>
      </xsl:if>
      <xsl:choose>
        <!-- TODO Code is near copy of item template -->
        <xsl:when test="ancestor::item">
          <xsl:variable name="role" select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/@role"/>
          <xsl:variable name="level" select="count(ancestor::list)+count(ancestor::nlist)"/>
          <xsl:variable name="list-type" select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/name()"/>
          <xsl:choose>
          <xsl:when test="position()=1">
            <xsl:choose>
              <xsl:when test="fn:list-wordstyle-for-document-label($labels, $role, $level, $list-type) != ''">
                <xsl:call-template name="apply-style" />
              </xsl:when>
              <xsl:when test="fn:list-wordstyle-for-default-document($role, $level, $list-type) != ''">
                <xsl:call-template name="apply-style" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="apply-style" />
              </xsl:otherwise>
            </xsl:choose>
            <xsl:variable name="max-num-id">
              <xsl:choose>
                <xsl:when test="doc-available(concat($_dotxfolder,$numbering-template))">
                  <xsl:value-of select="max(document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num/number(@w:numId))"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
          <w:numPr>
            <xsl:variable name="adjusted-level">
              <xsl:choose>
                <xsl:when test="ancestor::item/parent::*[@role]">
                  <xsl:value-of select="fn:get-level-from-role(ancestor::item/parent::*/@role,.)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="count(ancestor::list)+count(ancestor::nlist) - 1"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <w:ilvl w:val="{$adjusted-level}" />
            <xsl:variable name="current-pstyle">
              <xsl:variable name="call-style">
                <xsl:call-template name="apply-style" />
              </xsl:variable>
              <xsl:value-of select="$call-style//@w:val"/>
            </xsl:variable>
            <xsl:variable name="current-num-id">
              <xsl:choose>
                <xsl:when test="ancestor::nlist[@type !='']">
                  <!-- all lists inside the template + all normal lists inside psml document + preceding lists with @type + itself -->
                  <xsl:value-of select="$max-num-id + count($all-different-lists/*) + count(preceding::nlist[@type]) + 1"/>
                </xsl:when>
                <xsl:when test="ancestor::list and document(concat($_dotxfolder,$numbering-template))//w:abstractNum/w:lvl/w:pStyle/@w:val = $current-pstyle">
                  <xsl:variable name="current-numid" select="document(concat($_dotxfolder,$numbering-template))//w:abstractNum[w:lvl/w:pStyle/@w:val = $current-pstyle]/@w:abstractNumId"/>
                  <xsl:value-of select="document(concat($_dotxfolder,$numbering-template))//w:num[w:abstractNumId/@w:val = $current-numid][1]/@w:numId"/>
                </xsl:when>
                <xsl:when test="parent::*[@role]">
                  <xsl:value-of select="$max-num-id + count(preceding::*[name()='nlist'][@start][not(@type != '')]) + 1"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$max-num-id + count(ancestor::*[name()='nlist'][last()]/
                                        preceding::*[name()='nlist']
                                        [not(ancestor::list or ancestor::nlist)][not(@type != '')]) + 1"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <w:numId w:val="{$current-num-id}" />
          </w:numPr>

          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="list-level" select="count(ancestor::list)+count(ancestor::nlist) + 1"/>
            <xsl:choose>
              <xsl:when test="fn:para-list-level-paragraph-for-document-label($labels,$list-level,@numbered) != ''">
                <xsl:variable name="style-name" select="fn:para-list-level-paragraph-for-document-label($labels,$list-level,@numbered)"/>
                <w:pStyle w:val="{document(concat($_dotxfolder,$styles-template))//w:style[w:name/@w:val = $style-name]/@w:styleId}"/>
              </xsl:when>
              <xsl:when test="fn:para-list-level-paragraph-for-default-document($list-level,@numbered) != ''">
                <xsl:variable name="style-name" select="fn:para-list-level-paragraph-for-default-document($list-level,@numbered)"/>
                <w:pStyle w:val="{document(concat($_dotxfolder,$styles-template))//w:style[w:name/@w:val = $style-name]/@w:styleId}"/>
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

      <xsl:if test="@prefix">
        <xsl:choose>
          <xsl:when test="fn:para-prefix-select-for-document-label($labels, @indent, @numbered)">
            <xsl:sequence select="fn:para-prefix-value-for-document-label($labels, @indent, current(), @numbered)" />
          </xsl:when>
          <xsl:when test="fn:para-prefix-select-for-default-document(@indent, @numbered)">
            <xsl:sequence select="fn:para-prefix-value-for-default-document(@indent, current(), @numbered)" />
          </xsl:when>
          <xsl:otherwise>
            <w:r>
              <w:t xml:space="preserve"><xsl:value-of select="@prefix" /> </w:t>
            </w:r>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="@numbered = 'true'">
        <xsl:choose>
          <xsl:when test="fn:para-numbered-select-for-document-label($labels,@indent,@numbered)">
            <xsl:sequence select="fn:para-numbered-value-for-document-label($labels,@indent,current(),@numbered)" />
          </xsl:when>
          <xsl:when test="fn:para-numbered-select-for-default-document(@indent,@numbered)">
            <xsl:sequence select="fn:para-numbered-value-for-default-document(@indent,current(),@numbered)" />
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </w:pPr>
    <xsl:apply-templates mode="psml" />
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
