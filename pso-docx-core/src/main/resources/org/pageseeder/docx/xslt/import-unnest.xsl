<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:f="http://www.pageseeder.com/function"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all">

<xsl:param name="remove-custom-xml"               select="'true'"/>
<xsl:param name="remove-smart-tags"               select="'false'"/>
<xsl:param name="remove-content-controls"         select="'false'"/>
<xsl:param name="remove-rsid-info"                select="'true'"/>
<xsl:param name="remove-permissions"              select="'true'"/>
<xsl:param name="remove-proof"                    select="'true'"/>
<xsl:param name="remove-soft-hyphens"             select="'true'"/>
<xsl:param name="remove-last-rendered-page-break" select="'true'"/>
<xsl:param name="remove-goback-bookmarks"         select="'true'"/>
<xsl:param name="remove-bookmarks"                select="'false'"/>
<xsl:param name="remove-web-hidden"               select="'true'"/>
<xsl:param name="remove-language-info"            select="'true'"/>
<xsl:param name="remove-comments"                 select="'true'"/>
<xsl:param name="remove-end-and-foot-notes"       select="'false'"/>
<xsl:param name="remove-field-codes"              select="'false'"/>
<xsl:param name="replace-nobreak-hyphens"         select="'true'"/>
<xsl:param name="replace-tabs"                    select="'true'"/>
<xsl:param name="remove-font-info"                select="'true'"/>
<xsl:param name="remove-paragraph-properties"     select="'true'"/>

<!-- TODO Move to utilities -->

<xsl:output encoding="UTF-8" method="xml" indent="no" />

<xsl:variable name="stylesdocument" select="document('styles.xml')"/>

<!-- match root and handle purges, consolidations and simplifications -->
<xsl:template match="/">
  <xsl:sequence select="f:purge(f:consolidate(f:purge(f:simplify(node()))))"/>
</xsl:template>

<!-- Copy attributes by default -->
<xsl:template match="@*" mode="#all">
  <xsl:copy/>
</xsl:template>

<!-- Copy elements and their content by default -->
<xsl:template match="*" mode="#all">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="#current"/>
    <xsl:apply-templates mode="#current"/>
  </xsl:copy>
</xsl:template>

<!-- ========================================================================================= -->
<!-- 1. Simplify by removing markup                                                            -->
<!-- ========================================================================================= -->

<!--
   Purge the data from all the empty runs and run properties
-->
<xsl:function name="f:simplify">
  <xsl:param name="data"/>
  <xsl:apply-templates select="$data" mode="simplify"/>
</xsl:function>

<!-- Remove custom XML -->
<xsl:template match="w:customXml[$remove-custom-xml = 'true']" mode="simplify">
  <xsl:apply-templates select="*" mode="simplify"/>
</xsl:template>
<xsl:template match="w:customXmlPr[$remove-custom-xml = 'true']" mode="simplify"/>

<!-- Remove Smart Tags -->
<!-- TODO Should we preserve some of the content??? -->
<xsl:template match="w:smartTag[$remove-smart-tags = 'true']" mode="simplify">
  <xsl:apply-templates select="*" mode="simplify"/>
</xsl:template>
<xsl:template match="w:smartTagPr[$remove-smart-tags = 'true']" mode="simplify"/>


<!-- Remove Structured Document Tags -->
<!-- TODO Should we preserve some of the content??? -->
<xsl:template match="w:sdt[$remove-content-controls = 'true']" mode="simplify">
  <xsl:apply-templates select="w:sdtContent/*" mode="simplify"/>
</xsl:template>

<!-- Remove RSID Info -->
<xsl:template match="@w:rsid        [$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidDel     [$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidP       [$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidR       [$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidRDefault[$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidRPr     [$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidSect    [$remove-rsid-info = 'true']" mode="simplify"/>
<xsl:template match="@w:rsidTr      [$remove-rsid-info = 'true']" mode="simplify"/>

<!-- Remove permissions -->
<xsl:template match="w:permEnd   [$remove-permissions = 'true']" mode="simplify"/>
<xsl:template match="w:permStart [$remove-permissions = 'true']" mode="simplify" />

<!-- Remove proofing errors -->
<xsl:template match="w:proofErr  [$remove-proof = 'true']" mode="simplify"/>
<xsl:template match="w:noProof   [$remove-proof = 'true']" mode="simplify" />

<!-- Remove soft hyphens -->
<xsl:template match="w:softHyphen[$remove-soft-hyphens = 'true']" mode="simplify"/>

<!-- Remove last rendered page break -->
<xsl:template match="w:lastRenderedPageBreak[$remove-last-rendered-page-break = 'true']" mode="simplify"/>

<!-- Remove bookmarks -->
<xsl:template match="w:bookmarkStart[$remove-bookmarks = 'true']" mode="simplify"/>
<xsl:template match="w:bookmarkEnd  [$remove-bookmarks = 'true']" mode="simplify"/>

<xsl:template match="w:bookmarkStart[@w:name='_GoBack'][$remove-goback-bookmarks = 'true']" mode="simplify"/>
<xsl:template match="w:bookmarkEnd[@w:id= preceding::w:bookmarkStart[@w:name='_GoBack']/@w:id][$remove-goback-bookmarks = 'true']" mode="simplify"/>

<!-- Remove Web Hidden -->
<xsl:template match="w:webHidden[$remove-web-hidden = 'true']" mode="simplify"/>

<!-- Remove language declarations -->
<xsl:template match="w:lang[$remove-language-info = 'true']" mode="simplify"/>

<!-- Remove Comments -->
<xsl:template match="w:commentRangeStart [$remove-comments = 'true']" mode="simplify"/>
<xsl:template match="w:commentRangeEnd   [$remove-comments = 'true']" mode="simplify"/>
<xsl:template match="w:commentReference  [$remove-comments = 'true']" mode="simplify"/>
<xsl:template match="w:annotationRef     [$remove-comments = 'true']" mode="simplify"/>
<xsl:template match="w:rStyle[w:val = 'CommentReference'][$remove-comments = 'true']" mode="simplify"/>

<!-- Remove End And Foot Notes -->
<xsl:template match="w:endnoteReference [$remove-end-and-foot-notes = 'true']" mode="simplify"/>
<xsl:template match="w:footnoteReference[$remove-end-and-foot-notes = 'true']" mode="simplify"/>

<!-- Remove Field Codes -->
<xsl:template match="w:fldSimple[$remove-field-codes = 'true']" mode="simplify">
  <xsl:apply-templates mode="simplify"/>
</xsl:template>
<xsl:template match="w:fldData  [$remove-field-codes = 'true']" mode="simplify"/>
<xsl:template match="w:fldChar  [$remove-field-codes = 'true']" mode="simplify"/>
<xsl:template match="w:instrText[$remove-field-codes = 'true']" mode="simplify"/>

<!-- Replace the no break hyphens -->
<xsl:template match="w:noBreakHyphen[$replace-nobreak-hyphens = 'true']" mode="simplify">
  <xsl:choose>
    <xsl:when test="preceding-sibling::*[1][name() = 'w:t']">
      <xsl:element name="{preceding-sibling::*[1]/name()}">
        <xsl:attribute name="xml:space">preserve</xsl:attribute>
        <xsl:text>-</xsl:text>
      </xsl:element>
    </xsl:when>
    <xsl:when test="following-sibling::*[1][name() = 'w:t']">
      <xsl:element name="{following-sibling::*[1]/name()}">
        <xsl:attribute name="xml:space">preserve</xsl:attribute>
        <xsl:text>-</xsl:text>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <w:t xml:space="preserve">-</w:t>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Replace tabs -->
<xsl:template match="w:tab[$replace-tabs = 'true']" mode="simplify">
  <xsl:choose>
    <xsl:when test="preceding-sibling::*[1][name() = 'w:t']">
      <xsl:element name="{preceding-sibling::*[1]/name()}">
        <xsl:attribute name="xml:space">preserve</xsl:attribute>
        <xsl:text>&#x9;</xsl:text>
      </xsl:element>
    </xsl:when>
    <xsl:when test="following-sibling::*[1][name() = 'w:t']">
      <xsl:element name="{following-sibling::*[1]/name()}">
        <xsl:attribute name="xml:space">preserve</xsl:attribute>
        <xsl:text>&#x9;</xsl:text>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <w:t xml:space="preserve">&#x9;</w:t>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Remove font information -->
<xsl:template match="w:rFonts        [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:sz            [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:szCs          [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:bCs           [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:color         [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:specVanish    [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:rPr/w:spacing [$remove-font-info = 'true']" mode="simplify"/>
<xsl:template match="w:u[@w:val='none']"                           mode="simplify"/>

<!-- Remove paragraph Properties -->
<xsl:template match="w:tabs          [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:ind           [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:cnfStyle      [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:jc            [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:keepLines     [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:keepNext      [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:pBdr          [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:shd           [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:pPr/w:spacing [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:textAlignment [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:snapToGrid    [$remove-paragraph-properties = 'true']" mode="simplify"/>
<xsl:template match="w:mirrorIndents [$remove-paragraph-properties = 'true']" mode="simplify"/>

<!-- Fix break pages with styles -->
<xsl:template match="w:p[w:pPr/w:sectPr and w:pPr/w:pStyle]" mode="simplify">
  <xsl:variable name="content-section" select="if(w:r/w:t) then 'yes' else 'no'" />
  <xsl:choose>
    <xsl:when test="$content-section = 'no'">
    </xsl:when>
    <xsl:otherwise>
      <w:p>
        <xsl:copy-of select="w:pPr/*[not(name()='w:sectPr')]" />
        <xsl:copy-of select="*[not(name()='w:pPr')]" />
      </w:p>
    </xsl:otherwise>
  </xsl:choose>

  <!-- Put the w:sectPr element in another w:p element when it has some content -->
  <w:p>
    <w:pPr>
      <xsl:copy-of select="w:pPr/w:sectPr" />
    </w:pPr>
  </w:p>

</xsl:template>

<!-- simplifiy paragraphs -->
<xsl:template match="w:p" mode="simplify">
  <w:p>
	<!-- Add all bookmarkStart out of w:p element ancestor to the next w:p element -->
	<xsl:if test="self::w:p[not(ancestor::w:p) and preceding-sibling::*[1][self::w:bookmarkStart]]">
	  <xsl:variable name="bookmark-starts">
        <xsl:choose>
          <xsl:when test="preceding-sibling::w:p[1]">
            <xsl:variable name="first-not-bookmark-id" select="generate-id(preceding-sibling::w:p[1])" />
            <xsl:copy-of select="preceding-sibling::w:bookmarkStart[preceding-sibling::*[$first-not-bookmark-id = generate-id(.)]]" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="preceding-sibling::w:bookmarkStart"/>
          </xsl:otherwise>
        </xsl:choose>
	  </xsl:variable>
	  <xsl:copy-of select="$bookmark-starts/w:bookmarkStart" />
	</xsl:if>

    <xsl:for-each-group select="*" group-starting-with="w:r[w:fldChar[@w:fldCharType='begin']]">
      <xsl:for-each-group select="current-group()" group-ending-with="w:r[w:fldChar[@w:fldCharType='end']]">
        <xsl:choose>
          <xsl:when test="current-group()[w:fldChar[@w:fldCharType='end']]">
            <xsl:apply-templates select="current-group()[self::w:bookmarkStart or self::w:bookmarkEnd]" mode="simplify"/>
            <w:r>
              <xsl:choose>
                <xsl:when test="current-group()/w:rPr">
                  <xsl:apply-templates select="current-group()/w:rPr" mode="simplify"/>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
              </xsl:choose>
              <xsl:apply-templates select="current-group()/*[not(name()='w:rPr')]" mode="simplify"/>
            </w:r>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" mode="simplify"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:for-each-group>
  </w:p>
</xsl:template>

<!-- ========================================================================================= -->
<!-- Remove empty runs and run properties                                                      -->
<!-- ========================================================================================= -->

<!--
   Purge the data from all the empty runs and run properties
-->
<xsl:function name="f:purge">
  <xsl:param name="data"/>
  <xsl:apply-templates select="$data" mode="purge"/>
</xsl:function>

<!-- purge empty text runs -->
<xsl:template match="w:r[not(*)]"   mode="purge" />

<!-- purge empty text run properties -->
<xsl:template match="w:rPr[not(*)]" mode="purge" />

<!-- purge empty paragraph properties -->
<xsl:template match="w:pPr[not(*)]" mode="purge" />


<!-- ========================================================================================= -->
<!-- Templates to consolidate the runs that share the same properties                          -->
<!-- ========================================================================================= -->

<!--
   Purge the data from all the empty runs and run properties
-->
<xsl:function name="f:consolidate">
  <xsl:param name="data"/>
  <xsl:apply-templates select="$data" mode="consolidate"/>
</xsl:function>

<!-- consolidate paragraph properties -->
<xsl:template match="w:pPr" mode="consolidate">
  <xsl:element name="{./name()}">
    <xsl:copy-of select="@*"/>
    <xsl:for-each-group select="*" group-adjacent="f:key-for-run(.)">
      <!-- Not a Run -->
      <xsl:if test="not(self::w:rPr)">
        <xsl:apply-templates select="current-group()" mode="consolidate"/>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:element>
</xsl:template>

<!-- consolidate paragraphs hyperlinks, sdts, and smart tags -->
<xsl:template match="w:p|w:hyperlink|w:sdt|w:smartTag" mode="consolidate">
  <xsl:element name="{./name()}">
    <xsl:copy-of select="@*"/>

    <xsl:variable name="paragraphTextRunProperties" as="element()">
      <w:rPr>
      <xsl:if test="./w:pPr/w:rPr">
          <xsl:copy-of select="w:rPr/*"/>
      </xsl:if>
      </w:rPr>
    </xsl:variable>

    <xsl:for-each-group select="*" group-adjacent="f:key-for-run(.)">
      <xsl:comment><xsl:apply-templates select="current-group()" mode="xml"/></xsl:comment>
      <xsl:choose>

        <!-- Not a Run -->
        <xsl:when test="not(self::w:r)">
          <xsl:apply-templates select="current-group()" mode="consolidate"/>
        </xsl:when>

        <!-- Runs -->
        <xsl:otherwise>
          <xsl:variable name="runs" select="current-group()"/>
          <xsl:for-each-group select="current-group()/*" group-adjacent="if (self::w:br) then 1 else 2">
          <xsl:choose>
            <xsl:when test="current-grouping-key() = 1">
              <w:r>
                <xsl:copy-of select="current-group()"/>
              </w:r>
            </xsl:when>
            <xsl:otherwise>

            <xsl:for-each-group select="current-group()" group-starting-with="w:fldChar[@w:fldCharType='begin']">
              <xsl:for-each-group select="current-group()" group-ending-with="w:fldChar[@w:fldCharType='end']">
              <w:r>
                <xsl:variable name="runStyleName" select="w:rPr/r:pStyle/@w:val"/>
                <!-- Include run properties (from the first match - they are identical)-->
                <w:rPr>
                  <xsl:variable name="runProperties" as="element()">
                    <w:rPr>
                      <xsl:copy-of select="$runs/w:rPr[1]"/>
                    </w:rPr>
                  </xsl:variable>

                  <xsl:variable name="runPropertyMatch">
                    <xsl:for-each select="$runs/w:rPr[1]/*">
                      <xsl:choose>
                        <xsl:when test="position() = last()">
                          <xsl:value-of select="concat('^',./name(),'$')" />
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="concat('^',./name(),'$','|')" />
                        </xsl:otherwise>
                      </xsl:choose>
                     </xsl:for-each>
                  </xsl:variable>

                  <xsl:for-each select="$paragraphTextRunProperties/*">
                    <xsl:if test="not(matches(./name(),$runPropertyMatch))">
                      <xsl:copy-of select="."/>
                    </xsl:if>
                  </xsl:for-each>

                  <xsl:for-each select="$runProperties/w:rPr/*">
                      <xsl:copy-of select="."/>
                  </xsl:for-each>
                </w:rPr>

                <xsl:for-each-group select="current-group()[not(self::w:rPr)]" group-adjacent="if (self::w:t) then 1 else if (self::w:instrText) then 2 else 3">
                  <xsl:choose>
                    <xsl:when test="current-grouping-key() = 1">
                      <w:t xml:space="preserve"><xsl:value-of select="current-group()" separator=""/></w:t>
                    </xsl:when>
                    <xsl:when test="current-grouping-key() = 2">
                      <w:instrText xml:space="preserve"><xsl:value-of select="current-group()" separator=""/></w:instrText>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="current-group()" mode="consolidate"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each-group>

              </w:r>
              </xsl:for-each-group>
              </xsl:for-each-group>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:for-each-group>

      </xsl:otherwise>
    </xsl:choose>

  </xsl:for-each-group>
</xsl:element>
</xsl:template>

<!--
  Returns a key for the run being processed
-->
<xsl:function name="f:key-for-run" as="xs:string">
  <xsl:param name="r"/>
  <xsl:choose>
    <xsl:when test="$r[self::w:r]/w:rPr/*[name() != 'w:rStyle']">
      <xsl:variable name="serialised"><xsl:apply-templates select="$r/w:rPr" mode="serialize"/></xsl:variable>
      <xsl:value-of select="$serialised"/>
    </xsl:when>
    <xsl:when test="$r[self::w:r]/w:rPr/w:rStyle"><xsl:value-of select="$r/w:rPr/w:rStyle/@w:val"/></xsl:when>
    <xsl:when test="$r/self::w:r">{}</xsl:when>
    <xsl:otherwise>--</xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- ========================================================================================= -->
<!-- Serialise XML                                                                             -->
<!-- ========================================================================================= -->

<!-- Copy attributes by default -->
<xsl:template match="@*" mode="serialize" priority="1">
  <xsl:text>[</xsl:text>
  <xsl:value-of select="name()"/>=<xsl:value-of select="."/>
  <xsl:text>]</xsl:text>
</xsl:template>

<!-- Copy elements and their content by default -->
<xsl:template match="*" mode="serialize" priority="1">
  <xsl:text>{</xsl:text>
  <xsl:value-of select="name()"/>
  <xsl:apply-templates select="@*" mode="serialize"/>
  <xsl:apply-templates select="*|text()" mode="serialize"/>
  <xsl:text>}</xsl:text>
</xsl:template>

 <!--
  Templates to output a XML tree as text
  <a>
    <b c="1">
      text
    </b>
  </a>

  To display the source XML simply use <xsl:apply-templates mode="xml"/>
-->
<xsl:template match="*" mode="encode">
  <xsl:value-of select="concat('&lt;',name())" disable-output-escaping="yes" />
  <xsl:apply-templates select="@*" mode="encode" />
  <xsl:text>></xsl:text>
  <xsl:apply-templates mode="encode" />
  <xsl:value-of select="concat('&lt;',name(),'>')" disable-output-escaping="yes" />
</xsl:template>

<!-- encoding of element for uniqueness -->
<xsl:template match="*[not(node())]" mode="encode">
  <xsl:value-of select="concat('&lt;',name())" disable-output-escaping="yes" />
  <xsl:apply-templates select="@*" mode="encode" />
  <xsl:text>/></xsl:text>
</xsl:template>

<!-- encoding of attribute for uniqueness -->
<xsl:template match="@*" mode="encode">
  <xsl:value-of select="concat(' ',name(),'=&quot;',.,'&quot;')" />
</xsl:template>

<!-- output as text xml of elements -->
<xsl:template match="*[not(text()|*)]" mode="xml">
  <xsl:text>&lt;</xsl:text>
  <xsl:value-of select="name()" />
  <xsl:apply-templates select="@*" mode="xml" />
  <xsl:text>/&gt;</xsl:text>
</xsl:template>


<!-- output as text xml of elements -->
<xsl:template match="*[text()|*]" mode="xml">
  <xsl:text>&lt;</xsl:text>
  <xsl:value-of select="name()" />
  <xsl:apply-templates select="@*" mode="xml" />
  <xsl:text>&gt;</xsl:text>
  <xsl:apply-templates select="*|text()" mode="xml" />
  <xsl:text>&lt;/</xsl:text>
  <xsl:value-of select="name()" />
  <xsl:text>&gt;</xsl:text>
</xsl:template>


<!-- output as text xml of elements -->
<xsl:template match="text()" mode="xml">
  <xsl:value-of select="." />
</xsl:template>


<!-- output as text xml of elements -->
<xsl:template match="@*" mode="xml" priority="1">
  <xsl:text> </xsl:text>
  <xsl:value-of select="name()" />
  <xsl:text>="</xsl:text>
  <xsl:value-of select="." />
  <xsl:text>"</xsl:text>
</xsl:template>

</xsl:stylesheet>
