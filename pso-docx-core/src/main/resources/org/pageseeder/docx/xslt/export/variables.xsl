<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module containing global variables and functions.

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!-- TODO Too many repeated XPaths that may cause unnecessary tree traversal, use variables when appropriate -->

<!-- TODO Too many global variables, this creates complex global state that make the system hard to test -->

<!-- TODO Too many functions rely on global variable, look at options to pass variables as parameters -->

<!-- FIXME Many functions erroneously use `xsl:value-of` in place of `xsl:sequence` to return boolean values: check usage and use appropriate XSLT instruction -->

<!-- The location of the Content_Types.xml file -->
<xsl:variable name="_content-types-template" select="concat($_dotxfolder, encode-for-uri('[Content_Types].xml'))" as="xs:string"/>

<!-- The location of the document.xml.rels file -->
<xsl:variable name="_document-relationship" select="concat($_dotxfolder, encode-for-uri('word/_rels/document.xml.rels'))" as="xs:string"/>

<!-- The name of the docx file -->
<xsl:variable name="filename" select="substring-before($_docxfilename,'.docx')" as="xs:string"/>

<!-- The root PSML document -->
<xsl:variable name="root-document" select="/document" />

<!-- The uri element of the root PSML document -->
<xsl:variable name="root-uri" select="/document/documentinfo/uri" />

<!-- The document node of the numbering template -->
<xsl:variable name="numbering-template" select="document($_content-types-template)/ct:Types/ct:Override[fn:string-after-last-delimiter(@ContentType,'\.') = 'numbering+xml']/@PartName" />

<!-- The location of the styles template -->
<xsl:variable name="styles-template" select="'/word/styles.xml'" as="xs:string"/>

<xsl:variable name="footnote-ids">
  <xsl:for-each select="$root-document//xref[@documenttype=config:footnotes-documenttype()]/fragment">
    <footnote xref="{../@id}" id="{position()}" />
  </xsl:for-each>
</xsl:variable>

<xsl:variable name="endnote-ids">
  <xsl:for-each select="$root-document//xref[@documenttype=config:endnotes-documenttype()]/fragment">
    <endnote xref="{../@id}" id="{position()}" />
  </xsl:for-each>
</xsl:variable>

<!-- Node containing all inline label configured values -->
<xsl:variable name="inline-labels" as="element(inlinelabels)">
  <!-- TODO Only used in `content_types.xml` -->
  <inlinelabels>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements/inline[@default = 'generate-ps-style']">
      <xsl:for-each select="document//inline">
        <xsl:choose>
          <xsl:when test="$config-doc/config/elements/inline/label[@value = current()/@label]"/>
          <xsl:when test="$config-doc/config/elements/inline/ignore[@value = current()/@label]"/>
          <xsl:when test="$config-doc/config/elements/inline/tab[@value = current()/@label]"/>
          <xsl:when test="@label[not(following::inline/@label = current()/@label)]">
            <label name="{@label}"/>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="$config-doc/config/elements/inline/label[@wordstyle = 'generate-ps-style']">
        <label name="{@value}"/>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
  </inlinelabels>
</xsl:variable>

<!-- Node containing all block label configured values -->
<xsl:variable name="block-labels" as="element(blocklabels)">
  <!-- TODO Only used in `content_types.xml` -->
  <blocklabels>
   <xsl:choose>
    <xsl:when test="$config-doc/config/elements/block[@default = 'generate-ps-style']">
      <xsl:for-each select="document//block">
        <xsl:choose>
          <xsl:when test="$config-doc/config/elements/block/label[@value = current()/@label]"/>
          <xsl:when test="$config-doc/config/elements/block/ignore[@value = current()/@label]"/>
          <xsl:when test="$config-doc/config/elements/block/tab[@value = current()/@label]"/>
          <xsl:when test="@label[not(following::block/@label = current()/@label)]">
            <label name="{@label}"/>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
   </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="$config-doc/config/elements/block/label[@wordstyle = 'generate-ps-style']">
        <label name="{@value}"/>
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
  </blocklabels>
</xsl:variable>

<!-- TODO Move functions related specifically to the config to a separate module -->

<!--
  Returns the configured default paragraph style.

  @return the value of the default paragraph style
-->
<xsl:variable name="default-paragraph-style" as="xs:string">
  <xsl:variable name="style" select="$config-doc/config/default/defaultparagraphstyle/@wordstyle"/>
  <xsl:value-of select="if ($style and $style != '' and $style != 'none') then $style else 'Body Text'" />
</xsl:variable>

<!--
  Returns the configured default character style.

  @return the value of the default character style
-->
<xsl:variable name="default-character-style" as="xs:string">
  <xsl:variable name="style" select="$config-doc/config/default/defaultcharacterstyle/@wordstyle"/>
  <xsl:value-of select="if ($style and $style != '' and $style != 'none') then $style else 'Default Paragraph Font'" />
</xsl:variable>

<!--
  Automates the creation of a prefix for a heading defined by the expression set in configuration for document label specific documents.

  @param document-label the value of the current document label
  @param heading-level the value of the current heading level
  @param current the value of the current node
  @param numbered the value of the current numbered attribute

  @return the real regular expression value
-->
<xsl:function name="fn:heading-prefix-value-for-document-label" >
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="current"/>
  <xsl:param name="numbered"/>
  <xsl:variable name="level-element"
      select="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]" />
  <xsl:choose>
    <xsl:when test="$level-element/prefix[@select = 'true']/fieldcode">
      <xsl:variable name="type"   select="$level-element/prefix/fieldcode/@type"/>
      <xsl:variable name="name"   select="concat($document-label,'-heading',$heading-level)"/>
      <xsl:variable name="regexp" select="$level-element/prefix/fieldcode/@regexp"/>
      <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
      <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
      <xsl:variable name="flags">
        <xsl:choose>
          <xsl:when test="$current/preceding::heading[tokenize(ancestor::document[1]/documentinfo/uri/labels,',') = $document-label][@level &lt;= number($heading-level)][1][@level = $heading-level]/@prefix != ''">
            <xsl:variable name="preceding-heading-value" select="$current/preceding::heading[
                tokenize(ancestor::document[1]/documentinfo/uri/labels,',') = $document-label][@level &lt;= number($heading-level)][1][@level = $heading-level]/@prefix"/>
            <xsl:choose>
              <xsl:when test="number(fn:get-number-from-regexp($preceding-heading-value,$regexp,$real-regular-expression)) + 1 = number(fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))">
                <xsl:value-of select="'\n'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="string-before-regexp">
        <xsl:choose>
          <xsl:when test="substring-before($regexp,'%') !=''">
            <xsl:variable name="regexp-before" select="concat('(',substring-before($regexp,'%'),').*')"/>
            <xsl:analyze-string regex="({$regexp-before})" select="replace($current/@prefix,'&#160;',' ')">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(2)"/>
              </xsl:matching-substring>
             </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="string-after-regexp">
        <xsl:choose>
          <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
            <xsl:variable name="regexp-after" select="concat('.*(',replace($regexp,'.*%[^%]+%',''),')')"/>
            <xsl:analyze-string regex="({$regexp-after})" select="replace($current/@prefix,'&#160;',' ')">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(2)"/>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="$string-before-regexp != ''">
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-before-regexp"/></w:t>
        </w:r>
      </xsl:if>
      <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
      </w:fldSimple>
      <xsl:if test="$string-after-regexp != ''">
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-after-regexp"/></w:t>
        </w:r>
      </xsl:if>
      <xsl:sequence select="fn:prefix-separator($level-element/prefix/@separator)" />
    </xsl:when>
    <xsl:when test="$level-element/prefix[@select = 'false']">
    </xsl:when>
    <xsl:otherwise>
      <w:r>
        <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t>
      </w:r>
      <xsl:sequence select="fn:prefix-separator($level-element/prefix/@separator)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Automates the creation of a numbered value for a heading defined by the expression set in configuration for document label specific documents.

  @param document-label the value of the current document label
  @param heading-level the value of the current heading level
  @param current the value of the current node
  @param numbered the value of the current numbered attribute

  @return the real regular expression value
-->
 <xsl:function name="fn:heading-numbered-value-for-document-label" >
  <xsl:param name="document-label"/>
  <xsl:param name="heading-level"/>
  <xsl:param name="current"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered[@select = 'true']/fieldcode">
      <xsl:variable name="type" select="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/fieldcode/@type"/>
      <xsl:variable name="name" select="concat($document-label,'-heading-num',$heading-level)"/>
      <xsl:variable name="regexp" select="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/fieldcode/@regexp"/>
      <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
      <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
      <xsl:variable name="flags">
        <xsl:choose>
          <xsl:when test="$current/preceding::heading[@numbered][1][@level &lt; $heading-level]">
            <xsl:value-of select="'\r 1'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'\n'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="string-before-regexp">
        <xsl:choose>
          <xsl:when test="substring-before($regexp,'%') !=''">
            <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="substring-before($regexp,'%')">
              <xsl:matching-substring>
                <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),$document-label,$current,$numbered)}">
                </w:fldSimple>
                <xsl:if test="regex-group(4) != ''">
                  <w:r>
                    <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                  </w:r>
                </xsl:if>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="string-after-regexp">
        <xsl:choose>
          <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
            <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="replace($regexp,'.*%[^%]+%','')">
              <xsl:matching-substring>
                <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),'default',$current,$numbered)}">
                </w:fldSimple>
                <xsl:if test="regex-group(4) != ''">
                  <w:r>
                    <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                  </w:r>
                </xsl:if>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="$string-before-regexp != ''">
        <xsl:sequence select="$string-before-regexp"/>
      </xsl:if>
      <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
      </w:fldSimple>

      <xsl:if test="$string-after-regexp != ''">
        <xsl:sequence select="$string-after-regexp"/>
      </xsl:if>
    </xsl:when>
  </xsl:choose>
</xsl:function>

<!--
  Automates the creation of a prefix for a heading defined by the expression set in configuration for default documents.

  @param heading-level the value of the current heading level
  @param current the value of the current node
  @param numbered the value of the current numbered attribute

  @return the real regular expression value
-->
<xsl:function name="fn:heading-prefix-value-for-default-document" >
  <xsl:param name="heading-level"/>
  <xsl:param name="current" as="node()"/>
  <xsl:param name="numbered"/>
  <xsl:variable name="level-element"
      select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]" />
  <xsl:choose>
    <xsl:when test="$level-element/prefix[@select = 'true']/fieldcode">
      <xsl:variable name="type" select="$level-element/prefix/fieldcode/@type"/>
      <xsl:variable name="name" select="concat('defaultheading',$heading-level)"/>
      <xsl:variable name="regexp" select="$level-element/prefix/fieldcode/@regexp"/>
      <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
      <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
      <xsl:variable name="flags">
        <xsl:choose>
          <xsl:when test="$current/preceding::heading[ancestor::document[1]/not(.//labels)][@level &lt;= number($heading-level)][1][@level = $heading-level]/@prefix != ''">
            <xsl:variable name="preceding-heading-value" select="$current/preceding::heading[ancestor::document[1]/not(.//labels)][@level &lt;= number($heading-level)][1][@level = $heading-level]/@prefix"/>
            <xsl:choose>
              <xsl:when test="number(fn:get-number-from-regexp($preceding-heading-value,$regexp,$real-regular-expression)) + 1 = number(fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))">
                <xsl:value-of select="'\n'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="string-before-regexp">
        <xsl:choose>
          <xsl:when test="substring-before($regexp,'%') !=''">
            <xsl:variable name="regexp-before" select="concat('(',substring-before($regexp,'%'),').*')"/>
            <xsl:analyze-string regex="({$regexp-before})" select="replace($current/@prefix,'&#160;',' ')">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(2)"/>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="string-after-regexp">
        <xsl:choose>
          <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
            <xsl:variable name="regexp-after" select="concat('.*(',replace($regexp,'.*%[^%]+%',''),')')"/>
            <xsl:analyze-string regex="({$regexp-after})" select="replace($current/@prefix,'&#160;',' ')">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(2)"/>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="$string-before-regexp != ''">
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-before-regexp"/></w:t>
        </w:r>
      </xsl:if>
      <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
      </w:fldSimple>
      <xsl:if test="$string-after-regexp != ''">
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-after-regexp"/></w:t>
        </w:r>
      </xsl:if>
      <xsl:sequence select="fn:prefix-separator($level-element/prefix/@separator)" />
    </xsl:when>
    <xsl:when test="$level-element/prefix[@select = 'false']">
    </xsl:when>
    <xsl:otherwise>
      <w:r>
        <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t>
      </w:r>
      <xsl:sequence select="fn:prefix-separator($level-element/prefix/@separator)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>


<!--
  Automates the creation of a numbered value for a heading defined by the expression set in configuration for default documents.

  @param heading-level the value of the current heading level
  @param current the value of the current node
  @param numbered the value of the current numbered attribute

  @return the real regular expression value
-->
<xsl:function name="fn:heading-numbered-value-for-default-document" >
  <xsl:param name="heading-level"/>
  <xsl:param name="current" as="node()"/>
  <xsl:param name="numbered"/>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered[@select = 'true']/fieldcode">
      <xsl:variable name="type" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/fieldcode/@type"/>
      <xsl:variable name="name" select="concat('default-heading-num',$heading-level)"/>
      <xsl:variable name="regexp" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/numbered/fieldcode/@regexp"/>
      <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
      <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
      <xsl:variable name="flags">
        <xsl:choose>
          <xsl:when test="$current/preceding::heading[1][@level &lt; $heading-level]">
            <xsl:value-of select="'\r 1'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'\n'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="string-before-regexp">
        <xsl:choose>
          <xsl:when test="substring-before($regexp,'%') !=''">
            <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="substring-before($regexp,'%')">
              <xsl:matching-substring>
                <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),'default',$current,$numbered)}">
                </w:fldSimple>
                <xsl:if test="regex-group(4) != ''">
                  <w:r>
                    <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                  </w:r>
                </xsl:if>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="string-after-regexp">
        <xsl:choose>
          <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
            <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="replace($regexp,'.*%[^%]+%','')">
              <xsl:matching-substring>
                <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),'default',$current,$numbered)}">
                </w:fldSimple>
                <xsl:if test="regex-group(4) != ''">
                  <w:r>
                    <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                  </w:r>
                </xsl:if>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="$string-before-regexp != ''">
        <xsl:sequence select="$string-before-regexp"/>
      </xsl:if>
      <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
      </w:fldSimple>
      <xsl:if test="$string-after-regexp != ''">
        <xsl:sequence select="$string-after-regexp"/>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Automates the creation of a prefix for a ps:para defined by the expression set in configuration for document label specific documents.

  @param document-label the value of the current document label
  @param indent-level the value of the current para indent
  @param current the value of the current node
  @param numbered the value of the current numbered attribute

  @return the real regular expression value
-->
<xsl:function name="fn:para-prefix-value-for-document-label" >
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="current"/>
  <xsl:param name="numbered"/>

  <xsl:variable name="current-indent" select="if ($indent-level) then string($indent-level) else '0'"/>
  <xsl:variable name="indent-element"
      select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]"/>
  <xsl:choose>
    <xsl:when test="$indent-element/prefix[@select = 'true']/fieldcode">
      <xsl:variable name="type" select="$indent-element/prefix/fieldcode/@type"/>
      <xsl:variable name="name" select="concat($document-label,'-para',$current-indent)"/>
      <xsl:variable name="regexp" select="$indent-element/prefix/fieldcode/@regexp"/>
      <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
      <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
      <xsl:variable name="flags">
       <xsl:choose>
          <xsl:when test="$current/preceding::para[tokenize(ancestor::document[1]/documentinfo/uri/labels,',') = $document-label][@indent &lt;= number($current-indent)][1][@indent = $current-indent]/@prefix != ''">
            <xsl:variable name="precedingparavalue" select="$current/preceding::para[
                tokenize(ancestor::document[1]/documentinfo/uri/labels,',') = $document-label][@indent &lt;= number($current-indent)][1][@indent = $current-indent]/@prefix"/>
            <xsl:choose>
              <xsl:when test="number(fn:get-number-from-regexp($precedingparavalue,$regexp,$real-regular-expression)) + 1 = number(fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))">
                <xsl:value-of select="'\n'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="string-before-regexp">
        <xsl:choose>
          <xsl:when test="substring-before($regexp,'%') !=''">
            <xsl:variable name="regexp-before" select="concat('(',substring-before($regexp,'%'),').*')"/>
            <xsl:analyze-string regex="({$regexp-before})" select="replace($current/@prefix,'&#160;',' ')">
               <xsl:matching-substring>
                 <xsl:value-of select="regex-group(2)"/>
               </xsl:matching-substring>
             </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="string-after-regexp">
        <xsl:choose>
          <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
            <xsl:variable name="regexp-after" select="concat('.*(',replace($regexp,'.*%[^%]+%',''),')')"/>
            <xsl:analyze-string regex="({$regexp-after})" select="replace($current/@prefix,'&#160;',' ')">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(2)"/>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="$string-before-regexp != ''">
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-before-regexp"/></w:t>
        </w:r>
      </xsl:if>
      <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
      </w:fldSimple>
      <xsl:if test="$string-after-regexp != ''">
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-after-regexp"/></w:t>
        </w:r>
      </xsl:if>
      <xsl:sequence select="fn:prefix-separator($indent-element/prefix/@separator)" />
    </xsl:when>
    <xsl:when test="$indent-element/prefix[@select = 'false']">
    </xsl:when>
    <xsl:otherwise>
      <w:r>
        <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t>
      </w:r>
      <xsl:sequence select="fn:prefix-separator($indent-element/prefix/@separator)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Automates the creation of a numbered value for a ps:para defined by the expression set in configuration for document label specific documents.

  @param document-label the value of the current document label
  @param indent-level the value of the current para indent
  @param current the value of the current node
  @param numbered the value of the current numbered attribute

  @return the real regular expression value
-->
<xsl:function name="fn:para-numbered-value-for-document-label" >
  <xsl:param name="document-label"/>
  <xsl:param name="indent-level"/>
  <xsl:param name="current"/>
  <xsl:param name="numbered"/>

  <xsl:variable name="current-indent" select="if ($indent-level) then string($indent-level) else '0'"/>

  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/numbered[@select = 'true']/fieldcode">
      <xsl:variable name="type" select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/numbered/fieldcode/@type"/>
      <xsl:variable name="name" select="concat($document-label,'-para-num',$current-indent)"/>
      <xsl:variable name="regexp" select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/numbered/fieldcode/@regexp"/>
      <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
      <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
      <xsl:variable name="flags">
        <xsl:choose>
          <xsl:when test="$current/preceding::para[@numbered][1][@indent &lt; $current-indent]">
            <xsl:value-of select="'\r 1'"/>
          </xsl:when>
          <xsl:when test="$current/preceding::heading[1][not(following::para[@indent &gt;= $current-indent][following::*[generate-id() = generate-id($current)]])]">
            <xsl:value-of select="'\r 1'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'\n'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="string-before-regexp">
        <xsl:choose>
          <xsl:when test="substring-before($regexp,'%') !=''">
            <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="substring-before($regexp,'%')">
              <xsl:matching-substring>
                <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),$document-label,$current,$numbered)}">
                </w:fldSimple>
                <xsl:if test="regex-group(4) != ''">
                  <w:r>
                    <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                  </w:r>
                </xsl:if>
             </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="string-after-regexp">
        <xsl:choose>
          <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
            <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="replace($regexp,'.*%[^%]+%','')">
              <xsl:matching-substring>
                <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),'default',$current,$numbered)}">
                </w:fldSimple>
                <xsl:if test="regex-group(4) != ''">
                  <w:r>
                    <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                  </w:r>
                </xsl:if>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="$string-before-regexp != ''">
        <xsl:sequence select="$string-before-regexp"/>
      </xsl:if>
      <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
      </w:fldSimple>
      <xsl:if test="$string-after-regexp != ''">
       <xsl:sequence select="$string-after-regexp"/>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Automates the creation of a prefix for a ps:para defined by the expression set in configuration for default documents.

  @param indent-level the value of the current para indent
  @param current the value of the current node
  @param numbered the value of the current numbered attribute

  @return the real regular expression value
-->
<xsl:function name="fn:para-prefix-value-for-default-document" >
  <xsl:param name="indent-level"/>
  <xsl:param name="current"/>
  <xsl:param name="numbered"/>

  <xsl:variable name="current-indent" select="if ($indent-level) then string($indent-level) else '0'"/>
  <xsl:variable name="indent-element"
      select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]"/>
  <xsl:choose>
    <xsl:when test="$indent-element/prefix[@select = 'true']/fieldcode">
      <xsl:variable name="type" select="$indent-element/prefix/fieldcode/@type"/>
      <xsl:variable name="name" select="concat('default-para',$current-indent)"/>
      <xsl:variable name="regexp" select="$indent-element/prefix/fieldcode/@regexp"/>
      <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
      <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
      <xsl:variable name="flags">
       <xsl:choose>
          <xsl:when test="$current/preceding::para[@prefix][ancestor::document[1]/not(.//labels)]
          [number(@indent) &lt;= number($current-indent)][1]
          [number(@indent) = number($current-indent)]/@prefix != ''">
            <xsl:variable name="precedingparavalue" select="$current/preceding::para[ancestor::document[1]/not(.//labels)][@indent &lt;= number($current-indent)][1][@indent = number($current-indent)]/@prefix"/>
            <xsl:choose>
              <xsl:when test="number(fn:get-number-from-regexp($precedingparavalue,$regexp,$real-regular-expression)) + 1 = number(fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))">
                <xsl:value-of select="'\n'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('\r ',fn:get-number-from-regexp($current/@prefix,$regexp,$real-regular-expression))"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="string-before-regexp">
        <xsl:choose>
          <xsl:when test="substring-before($regexp,'%') !=''">
            <xsl:variable name="regexp-before" select="concat('(',substring-before($regexp,'%'),').*')"/>
            <xsl:analyze-string regex="({$regexp-before})" select="replace($current/@prefix,'&#160;',' ')">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(2)"/>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="string-after-regexp">
        <xsl:choose>
          <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
            <xsl:variable name="regexp-after" select="concat('.*(',replace($regexp,'.*%[^%]+%',''),')')"/>
            <xsl:analyze-string regex="({$regexp-after})" select="replace($current/@prefix,'&#160;',' ')">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(2)"/>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="$string-before-regexp != ''">
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-before-regexp"/></w:t>
        </w:r>
      </xsl:if>
      <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
      </w:fldSimple>
      <xsl:if test="$string-after-regexp != ''">
        <w:r>
          <w:t xml:space="preserve"><xsl:value-of select="$string-after-regexp"/></w:t>
        </w:r>
      </xsl:if>
      <xsl:sequence select="fn:prefix-separator($indent-element/prefix/@separator)" />
    </xsl:when>
    <xsl:when test="$indent-element/prefix[@select = 'false']">
    </xsl:when>
    <xsl:otherwise>
      <w:r>
        <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t>
      </w:r>
      <xsl:sequence select="fn:prefix-separator($indent-element/prefix/@separator)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Automates the creation of a numbered value for a ps:para defined by the expression set in configuration for prefix documents.

  @param indent-level the value of the current para indent
  @param current the value of the current node
  @param numbered the value of the current numbered attribute

  @return the real regular expression value
-->
<xsl:function name="fn:para-numbered-value-for-default-document" >
  <xsl:param name="indent-level"/>
  <xsl:param name="current"/>
  <xsl:param name="numbered"/>

  <xsl:variable name="current-indent" select="if ($indent-level) then string($indent-level) else '0'"/>

  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/numbered[@select = 'true']/fieldcode">
      <xsl:variable name="type" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/numbered/fieldcode/@type"/>
      <xsl:variable name="name" select="concat('default-para-num',$current-indent)"/>
      <xsl:variable name="regexp" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/numbered/fieldcode/@regexp"/>
      <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
      <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
      <xsl:variable name="flags">
        <xsl:choose>
          <xsl:when test="$current/preceding::para[@numbered][1][@indent &lt; $current-indent]">
            <xsl:value-of select="'\r 1'"/>
          </xsl:when>
          <xsl:when test="$current/preceding::heading[1]">
            <xsl:variable name="preceding-heading" select="$current/preceding::heading[1]"/>
            <xsl:choose>
              <xsl:when test="$preceding-heading/following::para[following::*[generate-id() = generate-id($current)]][@indent &lt;= $current-indent]">
                <xsl:value-of select="'\n'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'\r 1'"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="'\r 1'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'\n'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="string-before-regexp">
        <xsl:choose>
          <xsl:when test="substring-before($regexp,'%') !=''">
            <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="substring-before($regexp,'%')">
              <xsl:matching-substring>
                <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),'default',$current,$numbered)}">
                </w:fldSimple>
                <xsl:if test="regex-group(4) != ''">
                <w:r>
                  <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                </w:r>
                </xsl:if>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="string-after-regexp">
        <xsl:choose>
          <xsl:when test="replace($regexp,'.*%[^%]+%','') !=''">
            <xsl:analyze-string regex="((\^([^\^]*)\^)?([^\^]+))" select="replace($regexp,'.*%[^%]+%','')">
              <xsl:matching-substring>
                <w:fldSimple w:instr="{fn:get-field-code(regex-group(3),'default',$current,$numbered)}">
                </w:fldSimple>
                <xsl:if test="regex-group(4) != ''">
                  <w:r>
                    <w:t xml:space="preserve"><xsl:value-of select="regex-group(4)"/></w:t>
                  </w:r>
                </xsl:if>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="''"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:if test="$string-before-regexp != ''">
        <xsl:sequence select="$string-before-regexp"/>
      </xsl:if>
      <w:fldSimple w:instr="{concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)}">
      </w:fldSimple>
      <xsl:if test="$string-after-regexp != ''">
        <xsl:sequence select="$string-after-regexp"/>
      </xsl:if>
    </xsl:when>
  </xsl:choose>
</xsl:function>

<!--
  Generates the field code formula based on params

  @param field-type the type of the fieldcode
  @param field-name-value document label or default
  @param current the value of the current node
  @param numbered the value of the current numbered attribute

  @return the field code value
-->
<xsl:function name="fn:get-field-code">
  <xsl:param name="field-type" />
  <xsl:param name="field-name-value" />
  <xsl:param name="current" />
  <xsl:param name="numbered" />
  <xsl:variable name="type" select="tokenize(string($field-type), '-')[1]"/>
  <xsl:variable name="level" select="tokenize(string($field-type), '-')[2]"/>

  <xsl:choose>
    <xsl:when test="$field-name-value = 'default'">
      <xsl:choose>
        <xsl:when test="$type = 'heading'">
          <xsl:variable name="type" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$level]/numbered/fieldcode/@type"/>
          <xsl:variable name="name" select="concat($field-name-value,'-heading-num',$level)"/>
          <xsl:variable name="regexp" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$level]/numbered/fieldcode/@regexp"/>
          <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
          <xsl:variable name="flags">
            <xsl:choose>
              <xsl:when test="$current/preceding::heading[@level &lt; $level]">
                <xsl:variable name="preceding-lower-heading" select="$current/preceding::heading[@level &lt; $level]"/>
                <xsl:choose>
                  <xsl:when test="$preceding-lower-heading[not(following::heading[@level = $level][following::*[generate-id() = generate-id($current)]])]">
                    <xsl:value-of select="'\r 0'"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="'\c'"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'\c'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:value-of select="concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)"/>
        </xsl:when>
        <xsl:when test="$type = 'para'">
          <xsl:variable name="type" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$level]/numbered/fieldcode/@type"/>
          <xsl:variable name="name" select="concat($field-name-value,'-para-num',$level)"/>
          <xsl:variable name="regexp" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$level]/numbered/fieldcode/@regexp"/>
          <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
          <xsl:variable name="flags" select="'\c'"/>
          <xsl:value-of select="concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$type = 'heading'">
          <xsl:variable name="type" select="$config-doc/config/elements[@label = $field-name-value]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$level]/numbered/fieldcode/@type"/>
          <xsl:variable name="name" select="concat($field-name-value,'-heading-num',$level)"/>
          <xsl:variable name="regexp" select="$config-doc/config/elements[@label = $field-name-value]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$level]/numbered/fieldcode/@regexp"/>
          <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
          <xsl:variable name="flags">
            <xsl:choose>
              <xsl:when test="$current/preceding::heading[@level &lt; $level]">
                <xsl:variable name="preceding-lower-heading" select="$current/preceding::heading[@level &lt; $level]"/>
                <xsl:choose>
                  <xsl:when test="$preceding-lower-heading[not(following::heading[@level = $level][following::*[generate-id() = generate-id($current)]])]">
                    <xsl:value-of select="'\r 0'"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="'\c'"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="'\c'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:value-of select="concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)"/>
        </xsl:when>
        <xsl:when test="$type = 'para'">
          <xsl:variable name="type" select="$config-doc/config/elements[@label = $field-name-value]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$level]/numbered/fieldcode/@type"/>
          <xsl:variable name="name" select="concat($field-name-value,'-para-num',$level)"/>
          <xsl:variable name="regexp" select="$config-doc/config/elements[@label = $field-name-value]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$level]/numbered/fieldcode/@regexp"/>
          <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
          <xsl:variable name="flags" select="'\c'"/>
          <xsl:value-of select="concat($type,' ',$name,' \* ',$numeric-type,' ',$flags)"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:variable name="max-list-num-id">
  <xsl:choose>
    <xsl:when test="doc-available(concat($_dotxfolder,$numbering-template))">
      <xsl:value-of select="max(document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num/number(@w:numId))"/>
    </xsl:when>
    <xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
  All lists
-->
<xsl:variable name="all-different-lists" as="node()">
<lists>
  <xsl:for-each select=".//*[self::nlist or self::list]">
    <xsl:variable name="role" select="ancestor-or-self::*[name() = 'list' or name() = 'nlist'][last()]/@role"/>
    <xsl:variable name="level" select="count(ancestor::list)+count(ancestor::nlist) + 1"/>
    <xsl:variable name="list-type" select="./name()"/>
    <xsl:variable name="labels" as="xs:string*">
      <xsl:choose>
        <xsl:when test="ancestor::document[1]/documentinfo/uri/labels">
          <xsl:sequence select="tokenize(ancestor::document[1]/documentinfo/uri/labels,',')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="blocklabel" select="(ancestor::block)[last()]/@label" />
    <xsl:variable name="fragmentlabel" select="tokenize((ancestor::fragment)[last()]/@labels,',')" />
    <xsl:variable name="list-style-name" >
      <xsl:choose>
        <xsl:when test="config:list-style-for-block-label-document-label($blocklabel,$labels,$role,$list-type) != ''">
          <xsl:value-of select="config:list-style-for-block-label-document-label($blocklabel,$labels,$role,$list-type)"/>
        </xsl:when>
        <xsl:when test="config:list-style-for-block-label($blocklabel,$role,$list-type) != ''">
          <xsl:value-of select="config:list-style-for-block-label($blocklabel,$role,$list-type)"/>
        </xsl:when>
        <xsl:when test="config:list-style-for-fragment-label-document-label($fragmentlabel,$labels,$role,$list-type) != ''">
          <xsl:value-of select="config:list-style-for-fragment-label-document-label($fragmentlabel,$labels,$role,$list-type)"/>
        </xsl:when>
        <xsl:when test="config:list-style-for-fragment-label($fragmentlabel,$role,$list-type) != ''">
          <xsl:value-of select="config:list-style-for-fragment-label($fragmentlabel,$role,$list-type)"/>
        </xsl:when>
        <xsl:when test="config:list-style-for-document-label($labels,$role,$list-type) != ''">
          <xsl:value-of select="config:list-style-for-document-label($labels,$role,$list-type)"/>
        </xsl:when>
        <xsl:when test="config:list-style-for-default-document($role,$list-type) != ''">
          <xsl:value-of select="config:list-style-for-default-document($role,$list-type)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="list-style" select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $list-style-name]/@w:styleId"/>

    <xsl:variable name="abstract-num" select="document(concat($_dotxfolder, $numbering-template))//w:abstractNum[w:styleLink/@w:val = $list-style]"/>

    <xsl:variable name="abstract-num-id">
      <xsl:choose>
        <!-- if abstractNum not found try to find default -->
        <xsl:when test="not($abstract-num)">
          <xsl:variable name="paragraph-style-id" select="if ($list-type = 'nlist') then 'ListNumber' else 'ListBullet'" />
          <xsl:variable name="num-id" select="document(concat($_dotxfolder, $styles-template))//w:style[@w:styleId = $paragraph-style-id]/w:pPr/w:numPr/w:numId/@w:val"/>
          <xsl:choose>
            <!-- if no number ID then error -->
            <xsl:when test="not($num-id)">
              <xsl:message>DOCX EXPORT ERROR: No style found for <xsl:value-of
                select="$list-type"/> with role=<xsl:value-of select="$role"/> (URI ID: <xsl:value-of
                select="/document/documentinfo/uri/@id" />)</xsl:message>
              <xsl:value-of select="'0'" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="document(concat($_dotxfolder, $numbering-template))//w:num[@w:numId=$num-id]/w:abstractNumId/@w:val"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$abstract-num/@w:abstractNumId" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$list-type = 'nlist'">
        <nlist start="{if (@start) then @start else 1}" >
          <xsl:attribute name="role" select="$role"/>
          <xsl:attribute name="level" select="$level - 1"/>
          <xsl:value-of select="$abstract-num-id" />
        </nlist>
      </xsl:when>
      <xsl:otherwise>
        <list>
          <xsl:attribute name="role" select="$role"/>
          <xsl:attribute name="level" select="$level - 1"/>
          <xsl:attribute name="numid"
            select="(document(concat($_dotxfolder, $numbering-template))//w:num[w:abstractNumId/@w:val=$abstract-num-id])[1]/@w:numId" />
          <xsl:value-of select="$abstract-num-id" />
        </list>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:for-each>
</lists>
</xsl:variable>

</xsl:stylesheet>