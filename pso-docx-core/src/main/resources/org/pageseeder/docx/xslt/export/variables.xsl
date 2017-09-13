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

<!-- The document node of the numbering template -->
<xsl:variable name="numbering-template" select="document($_content-types-template)/ct:Types/ct:Override[fn:string-after-last-delimiter(@ContentType,'\.') = 'numbering+xml']/@PartName" />

<!-- The location of the styles template -->
<xsl:variable name="styles-template" select="'/word/styles.xml'" as="xs:string"/>

<!-- The word style of the configuration file for xref elements -->
<xsl:variable name="xref-style" as="xs:string">
  <xsl:value-of select="string($config-doc/config/elements/xref/@style)"/>
</xsl:variable>

<!-- Node containing all inline label configured values -->
<xsl:variable name="inline-labels" as="element(inlinelabels)">
  <!-- TODO Only used in `content_types.xml` -->
  <inlinelabels>
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements/inline[@default = 'generate-ps-style']">
      <xsl:for-each select="document//inline">
        <xsl:choose>
          <xsl:when test="ancestor::document[1]/document/documentinfo/uri/labels"/>
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
        <xsl:variable name="documentLabel" select="ancestor::document[1]/document/documentinfo/uri/labels"/>
        <xsl:choose>
          <xsl:when test="$documentLabel != '' and $config-doc/config/elements[matches(@label,$documentLabel)]/block/@default != 'generate-ps-style'"/>
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
  Returns the value of the numbering id to create in the numbering.xml file
-->
<xsl:function name="fn:get-numbering-id">
  <xsl:param name="current" as="element()" />
  <xsl:choose>
    <xsl:when
        test="$current/ancestor::*[name() = 'list' or 'nlist']/parent::block and
          $current/ancestor::*[name() = 'list' or 'nlist']/parent::block/@label = $config-doc/config/lists/list/@name and
          $config-doc/config/lists/(list|nlist)[@name = $current/ancestor::*[name() = 'list' or 'nlist']/parent::block/@label][@style != '']">
      <xsl:variable name="style-name"
                    select="$config-doc/config/lists/(list|nlist)[@name = $current/ancestor::*[name() = 'list' or 'nlist']/parent::block/@label]/@style" />
      <xsl:value-of
          select="document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num[w:abstractNumId/@w:val = document(concat($_dotxfolder,$numbering-template))/w:numbering/w:abstractNum[w:numStyleLink[@w:val = $style-name]]/@w:abstractNumId]/@w:numId" />
    </xsl:when>
    <xsl:when
        test="$current/ancestor::*[name() = 'list' or 'nlist']/parent::block and
          $current/ancestor::*[name() = 'list' or 'nlist']/parent::block/@label = $config-doc/config/lists/(list|nlist)/@name">
      <xsl:variable name="style-name"
                    select="$current/ancestor::*[name() = 'list' or 'nlist']/parent::block/@label" />
      <xsl:variable name="max-num-id"
                    select="max(document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num/number(@w:numId))" />
      <xsl:variable name="position"
                    select="count($config-doc/config/lists/(list|nlist)) - count($config-doc/config/lists/(list|nlist)[@name=$style-name]/following-sibling::*[name() = 'list' or 'nlist'][@style=''])" />
      <xsl:value-of select="$max-num-id + $position" />
    </xsl:when>
    <xsl:when test="$current/parent::*[name() = 'nlist']">

      <xsl:variable name="max-num-id"
                    select="max(document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num/number(@w:numId))" />
      <xsl:variable name="default-position"
                    select="count($config-doc/config/lists/(list|nlist)) - count($config-doc/config/lists/nlist[@name='default']/following-sibling::*[name() = 'list' or 'nlist'][@style=''])" />
      <xsl:value-of select="$max-num-id + $default-position" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="max-num-id"
                    select="max(document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num/number(@w:numId))" />
      <xsl:variable name="default-position"
                    select="count($config-doc/config/lists/(list|nlist)) - count($config-doc/config/lists/list[@name='default']/following-sibling::*[name() = 'list' or 'nlist'][@style=''])" />
      <xsl:value-of select="$max-num-id + $default-position" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

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
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix[@select = 'true']/fieldcode">
      <xsl:variable name="type"   select="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/fieldcode/@type"/>
      <xsl:variable name="name"   select="concat($document-label,'-heading',$heading-level)"/>
      <xsl:variable name="regexp" select="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/fieldcode/@regexp"/>
      <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
      <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
      <xsl:variable name="flags">
        <xsl:choose>
          <xsl:when test="$current/preceding::heading[ancestor::document[1]/documentinfo/uri/labels = $document-label][@level &lt;= number($heading-level)][1][@level = $heading-level]/@prefix != ''">
            <xsl:variable name="preceding-heading-value" select="$current/preceding::heading[ancestor::document[1]/documentinfo/uri/labels = $document-label][@level &lt;= number($heading-level)][1][@level = $heading-level]/@prefix"/>
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
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix[@select = 'true']">
      <w:r>
        <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t>
      </w:r>
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix[@select = 'false']">

    </xsl:when>
    <xsl:otherwise>
      <w:r>
        <w:t xml:space="preserve"/>
      </w:r>
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
  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix[@select = 'true']/fieldcode">
      <xsl:variable name="type" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/fieldcode/@type"/>
      <xsl:variable name="name" select="concat('defaultheading',$heading-level)"/>
      <xsl:variable name="regexp" select="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix/fieldcode/@regexp"/>
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
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix[@select = 'true']">
      <w:r>
        <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t>
      </w:r>
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/heading/level[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@value=$heading-level]/prefix[@select = 'false']">
    </xsl:when>
    <xsl:otherwise>
      <w:r>
        <w:t xml:space="preserve"/>
      </w:r>
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

  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix[@select = 'true']/fieldcode">
      <xsl:variable name="type" select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix/fieldcode/@type"/>
      <xsl:variable name="name" select="concat($document-label,'-para',$current-indent)"/>
      <xsl:variable name="regexp" select="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix/fieldcode/@regexp"/>
      <xsl:variable name="numeric-type" select="fn:get-numeric-type(substring-before(substring-after($regexp,'%'),'%'))"/>
      <xsl:variable name="real-regular-expression" select="fn:replace-regexp($regexp)"/>
      <xsl:variable name="flags">
       <xsl:choose>
          <xsl:when test="$current/preceding::para[ancestor::document[1]/documentinfo/uri/labels = $document-label][@indent &lt;= number($current-indent)][1][@indent = $current-indent]/@prefix != ''">
            <xsl:variable name="precedingparavalue" select="$current/preceding::para[ancestor::document[1]/documentinfo/uri/labels = $document-label][@indent &lt;= number($current-indent)][1][@indent = $current-indent]/@prefix"/>
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
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[@label = $document-label]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix[@select = 'true']">
      <w:r>
        <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t>
      </w:r>
    </xsl:when>
    <xsl:otherwise>
      <w:r>
        <w:t xml:space="preserve"/>
      </w:r>
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

  <xsl:choose>
    <xsl:when test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix[@select = 'true']/fieldcode">
      <xsl:variable name="type" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix/fieldcode/@type"/>
      <xsl:variable name="name" select="concat('default-para',$current-indent)"/>
      <xsl:variable name="regexp" select="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix/fieldcode/@regexp"/>
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
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix[@select = 'true']">
      <w:r>
        <w:t xml:space="preserve"><xsl:value-of select="$current/@prefix"/></w:t>
      </w:r>
    </xsl:when>
    <xsl:when test="$config-doc/config/elements[not(@label)]/para/indent[if($numbered) then (@numbered =  $numbered) else not(@numbered)][@level=$current-indent]/prefix[@select = 'false']">
    </xsl:when>
    <xsl:otherwise>
      <w:r>
        <w:t xml:space="preserve"/>
      </w:r>
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


<!--
  List of all individual ps:lists

  @return a node() witl all of the ps:list and ps:nlist values
-->
<xsl:variable name="all-different-lists" as="node()">
<lists>
  <xsl:for-each select=".//nlist[not(@type) and not(descendant::nlist/@type)][not(ancestor::*[name() = 'list' or name() = 'nlist'])]"> <!--  or @role or @start] -->
    <xsl:variable name="role" select="config:get-style-from-role(@role,.)"/>
    <xsl:variable name="level" select="count(ancestor::list)+count(ancestor::nlist) + 1"/>
    <xsl:variable name="list-type" select="./name()"/>
    <xsl:variable name="labels">
      <xsl:choose>
        <xsl:when test="ancestor::document[1]/documentinfo/uri/labels">
          <xsl:value-of select="ancestor::document[1]/documentinfo/uri/labels"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="paragraph-style" >
      <xsl:choose>
        <xsl:when test="$role != ''">
          <xsl:value-of select="document(concat($_dotxfolder,$styles-template))//w:style[w:name/@w:val = $role]/@w:styleId"/>
        </xsl:when>
        <xsl:when test="config:list-wordstyle-for-document-label($labels,@role,$level,$list-type) != ''">
          <xsl:value-of select="config:list-wordstyle-for-document-label($labels,@role,$level,$list-type)"/>
        </xsl:when>
        <xsl:when test="config:list-wordstyle-for-default-document(@role,$level,$list-type) != ''">
          <xsl:value-of select="config:list-wordstyle-for-default-document(@role,$level,$list-type)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="fn:default-list-wordstyle($level,$list-type)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="paragraph-style-name" >
      <xsl:choose>
        <xsl:when test="$role != ''">
          <xsl:value-of select="$role"/>
        </xsl:when>
        <xsl:when test="config:list-wordstyle-for-document-label($labels,@role,$level,$list-type) != ''">
          <xsl:value-of select="config:list-wordstyle-for-document-label($labels,@role,$level,$list-type)"/>
        </xsl:when>
        <xsl:when test="config:list-wordstyle-for-default-document(@role,$level,$list-type) != ''">
          <xsl:value-of select="config:list-wordstyle-for-default-document(@role,$level,$list-type)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="fn:default-list-wordstyle($level,$list-type)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="paragraph-style" select="document(concat($_dotxfolder, $styles-template))//w:style[w:name/@w:val = $paragraph-style-name]/@w:styleId"/>

    <xsl:choose>
      <xsl:when test="$list-type = 'nlist'">
        <nlist start="{if (@start) then @start else 1}" >
          <xsl:attribute name="level">
              <xsl:value-of select="count(document(concat($_dotxfolder, $numbering-template))//w:abstractNum/w:lvl[w:pStyle/@w:val = $paragraph-style]/preceding-sibling::w:lvl)"/>
          </xsl:attribute>
          <xsl:attribute name="role" select="$role"/>
          <xsl:attribute name="labels" select="$labels"/>
          <xsl:attribute name="level1" select="$level"/>
          <xsl:attribute name="pstylename">
            <xsl:value-of select="$paragraph-style-name"/>
          </xsl:attribute>
          <xsl:attribute name="pstyle">
            <xsl:value-of select="$paragraph-style"/>
          </xsl:attribute>
          <xsl:value-of select="document(concat($_dotxfolder, $numbering-template))//w:abstractNum[w:lvl/w:pStyle/@w:val = $paragraph-style]/@w:abstractNumId"/>
        </nlist>
      </xsl:when>
      <xsl:otherwise>
        <list>
          <xsl:attribute name="level">
            <xsl:value-of select="count(document(concat($_dotxfolder, $numbering-template))//w:abstractNum/w:lvl[w:pStyle/@w:val = $paragraph-style]/preceding-sibling::w:lvl)"/>
          </xsl:attribute>
          <xsl:attribute name="role" select="$role"/>
          <xsl:attribute name="labels" select="$labels"/>
          <xsl:attribute name="level1" select="$level"/>
          <xsl:attribute name="pstylename">
            <xsl:value-of select="$paragraph-style-name"/>
          </xsl:attribute>
          <xsl:attribute name="pstyle">
            <xsl:value-of select="$paragraph-style"/>
          </xsl:attribute>
          <xsl:value-of select="document(concat($_dotxfolder,$numbering-template))//w:abstractNum[w:lvl/w:pStyle/@w:val = $paragraph-style]/@w:abstractNumId"/>
        </list>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:for-each>
</lists>
</xsl:variable>

<!--
  List of all type of individual ps:lists

  @return a node() with all of the w:abstractNum values
-->
<!-- TODO fix list role not working -->
<xsl:variable name="all-type-lists" as="node()">
  <lists>
  <xsl:for-each select=".//nlist[@role !='' or descendant::nlist/@role !=''][not(ancestor::*[name() = 'list' or name() = 'nlist'])]">
    <xsl:variable name="max-abstract-num" select="max(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/number(@w:abstractNumId))" />
    <w:abstractNum w:abstractNumId="{$max-abstract-num + position()}">
      <w:multiLevelType w:val="multilevel"/>
      <w:styleLink w:val="{concat('pageseeder list style',position())}"/>
      <xsl:variable name="current-list" select="current()" as="node()"/>
      <xsl:variable name="levels" select="'0,1,2,3,4,5,6,7,8'"/>
       <xsl:for-each select="tokenize($levels, ',')">
        <xsl:variable name="current-nlist-level-type" as="xs:string">
          <xsl:choose>
            <xsl:when test="$current-list//*[name() = 'nlist' or name='list'][count(ancestor::*[name() = 'list' or name() = 'nlist']) != NaN]/@type">
              <xsl:value-of select="$current-list//*[name() = 'nlist' or name='list'][count(ancestor::*[name() = 'list' or name() = 'nlist']) = number(.)]/@type"/>
            </xsl:when>
            <xsl:when test="$current-list/@type and number(.) = 0">
              <xsl:value-of select="$current-list/@type"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="current-nlist-level-start" as="xs:string">
          <xsl:choose>
            <xsl:when test="$current-list//*[name() = 'nlist' or name='list'][count(ancestor::*[name() = 'list' or name() = 'nlist']) != NaN]/@start">
              <xsl:value-of select="$current-list//*[name() = 'nlist' or name='list'][count(ancestor::*[name() = 'list' or name() = 'nlist']) = number(.)]/@start"/>
            </xsl:when>
            <xsl:when test="$current-list/@start and number(.) = 0">
              <xsl:value-of select="$current-list/@start"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="current-nlist-level-name">
          <xsl:choose>
            <xsl:when test="$current-list//*[name() = 'nlist' or name='list'][count(ancestor::*[name() = 'list' or name() = 'nlist']) != NaN]/name()">
              <xsl:value-of select="$current-list//*[name() = 'nlist' or name='list'][count(ancestor::*[name() = 'list' or name() = 'nlist']) = number(.)]/name()"/>
            </xsl:when>
            <xsl:when test="$current-list/name() and number(.) = 0">
              <xsl:value-of select="$current-list/name()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="''"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$current-nlist-level-type != ''">
            <w:lvl w:ilvl="{.}">
              <w:start w:val="{if ($current-nlist-level-start != '') then $current-nlist-level-start else '1'}"/>
              <w:numFmt w:val="{fn:return-word-numbering-style($current-nlist-level-type)}"/>
              <w:lvlText w:val="%1."/>
              <w:lvlJc w:val="left"/>
              <w:pPr>
                <w:tabs>
                  <w:tab w:val="num" w:pos="{360 * number(.)}"/>
                </w:tabs>
                <w:ind w:left="{360 * number(.)}" w:hanging="360"/>
              </w:pPr>
            </w:lvl>
          </xsl:when>
          <xsl:when test="$current-nlist-level-name = 'list'">
            <w:lvl w:ilvl="{.}">
              <w:start w:val="1"/>
              <w:numFmt w:val="bullet"/>
              <w:lvlText w:val=""/>
              <w:lvlJc w:val="left"/>
              <w:pPr>
                <w:ind w:left="{720 * number(.)}" w:hanging="360"/>
              </w:pPr>
              <w:rPr>
                <w:rFonts w:ascii="Symbol" w:hAnsi="Symbol" w:hint="default"/>
              </w:rPr>
            </w:lvl>
          </xsl:when>
          <xsl:otherwise>
            <w:lvl w:ilvl="{.}">
              <w:start w:val="{if ($current-nlist-level-start != '') then $current-nlist-level-start else 1}"/>
              <w:numFmt w:val="{fn:return-word-numbering-style(.)}"/>
              <w:lvlText w:val="%1."/>
              <w:lvlJc w:val="left"/>
              <w:pPr>
                <w:tabs>
                  <w:tab w:val="num" w:pos="{360 * number(.)}"/>
                </w:tabs>
                <w:ind w:left="{360 * number(.)}" w:hanging="360"/>
              </w:pPr>
            </w:lvl>
          </xsl:otherwise>
       </xsl:choose>
       </xsl:for-each>
     </w:abstractNum>
    </xsl:for-each>

    <xsl:for-each select=".//nlist[@type !='' or descendant::nlist/@type !=''][not(ancestor::*[name() = 'list' or name() = 'nlist'])]">
      <xsl:variable name="max-abstract-num" select="max(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/number(@w:abstractNumId))" />
      <xsl:variable name="max-num-id" select="max(document(concat($_dotxfolder,$numbering-template))//w:num/number(@w:numId))" />
      <w:num w:numId="{$max-num-id + count($all-different-lists/*) + position()}">
        <w:abstractNumId w:val="{$max-abstract-num + position()}"/>
      </w:num>
    </xsl:for-each>
  </lists>
</xsl:variable>

</xsl:stylesheet>