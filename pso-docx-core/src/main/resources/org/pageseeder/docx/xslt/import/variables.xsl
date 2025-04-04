<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module providing global variables.

  Note: Global variables that should be shared between modules should be defined and documented here.

  @author Hugo Inacio
  @author Christophe Lauret
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!--
  Key to match XE text
-->
<!-- TODO Does not appear to be used, check... -->
<xsl:key name="index" match="w:r/w:instrText/text()" use="." />

<!-- TODO Move config functions to a `config` module -->

<!-- location of the numbering file from the input docx -->
<xsl:variable name="numbering" select="concat($_rootfolder,'/word/numbering.xml')" as="xs:string?"/>

<!-- location of the main document file from the input docx -->
<xsl:variable name="main" select="concat($_rootfolder,'/word/new-document.xml')" as="xs:string?"/>

<!-- location of the styles  file from the input docx -->
<xsl:variable name="styles" select="concat($_rootfolder,'word/styles.xml')" as="xs:string?" />

<!-- name of the docx file without docx extention -->
<xsl:variable name="filename" select="lower-case(replace($_docxfilename,' ','_'))"  as="xs:string?"/>

<!-- location of the relationship file from the input docx -->
<xsl:variable name="rels" select="concat($_rootfolder,'word/_rels/document.xml.rels')"  as="xs:string?"/>

<!-- location of the footnotes relationship file from the input docx -->
<xsl:variable name="f-rels" select="concat($_rootfolder,'word/_rels/footnotes.xml.rels')"  as="xs:string?"/>

<!-- location of the endnotes relationship file from the input docx -->
<xsl:variable name="e-rels" select="concat($_rootfolder,'word/_rels/endnotes.xml.rels')"  as="xs:string?"/>

<!-- document node of the main document.xml file of the docx input document  -->
<xsl:variable name="main-document" select="document($main)" as="node()"/>

<!-- node of numbering document -->
<xsl:variable name="numbering-document" select="if (doc-available($numbering)) then document($numbering) else ." as="node()"/>

<!-- node of styles document -->
<xsl:variable name="styles-document" select="document($styles)" as="node()"/>

<!-- node of relationship document -->
<xsl:variable name="relationship-document" select="document($rels)" as="node()"/>

<!-- node of footnotes relationship document -->
<xsl:variable name="f-relationship-document" select="document($f-rels)" as="node()"/>

<!-- node of endnotes relationship document -->
<xsl:variable name="e-relationship-document" select="document($e-rels)" as="node()"/>

<!-- Footnote  file path -->
<xsl:variable name="footnotes-file" select="concat($_rootfolder,'/word/new-footnotes.xml')"/>

<!-- Endnote file path -->
<xsl:variable name="endnotes-file" select="concat($_rootfolder,'/word/new-endnotes.xml')"/>

  <!-- Variable that defines name of the tile for the main document -->
<xsl:variable name="document-title" as="xs:string?">
  <xsl:variable name="core" select="document(concat($_rootfolder,'docProps/core.xml'))" />
  <xsl:choose>
    <xsl:when test="$core//dc:title != ''">
      <xsl:value-of select="$core//dc:title" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$_docxfilename" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
  variable used to do calculations of document position of:
  1. Lists
  2. xrefs
 -->
<xsl:variable name="list-paragraphs" as="element()">
  <w:body xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
          xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml"
          xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
          xmlns:xs="http://www.w3.org/2001/XMLSchema"
          xmlns:fn="http://pageseeder.org/docx/function">
    <xsl:for-each select="$main-document//w:p[not(parent::w:tc)][not(matches(w:pPr/w:pStyle/@w:val, config:ignore-paragraph-match-list-string()))][string-join(w:r//text(), '') != '']|$main-document//w:bookmarkStart|$main-document//w:tc">
      <xsl:element name="{name()}">
        <xsl:attribute name="id" select="generate-id(.)" />
        <xsl:copy-of select="@*" />
        <xsl:if test="w:pPr">
          <xsl:apply-templates select="w:pPr" mode="paracopy" />
        </xsl:if>
        <xsl:if test="w:p">
          <xsl:apply-templates select="w:p" mode="paracopy" />
        </xsl:if>
      </xsl:element>
    </xsl:for-each>
  </w:body>
</xsl:variable>

<!-- format value of footnote numbering -->
<xsl:variable name="footnote-format" as="xs:string?">
  <xsl:value-of select="($main-document//w:sectPr[w:footnotePr]/w:footnotePr/w:numFmt/@w:val)[last()]"/>
</xsl:variable>

<!-- format value of endnote numbering -->
<xsl:variable name="endnote-format" as="xs:string?">
  <xsl:value-of select="($main-document//w:sectPr[w:endnotePr]/w:endnotePr/w:numFmt/@w:val)[last()]"/>
</xsl:variable>

<!--
  Variable that contains all XE filed elements to generate indexes
-->
<xsl:variable name="list-index" as="element()">
  <w:body xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
          xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
    <xsl:for-each select="$main-document//w:r[w:instrText[matches(text(),'XE')]]">
      <xsl:element name="{name()}">
        <xsl:copy-of select="@*" />
        <xsl:apply-templates mode="paracopy" />
      </xsl:element>
    </xsl:for-each>
  </w:body>
</xsl:variable>

<!--
  Variable that contains all mathml filed elements to generate indexes
-->
<xsl:variable name="list-mathml" as="element()">
  <w:body xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml"
          xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
    <xsl:for-each select="$main-document//(m:oMath[not(ancestor::m:oMathPara)]|m:oMath[ancestor::m:oMathPara and ancestor::w:p])">
      <xsl:variable name="current">
        <xsl:apply-templates select="." mode="xml"/>
      </xsl:variable>
      <m:math>
        <xsl:attribute name="checksum-id" select="fn:checksum($current)"/>
        <xsl:apply-templates select="@*" mode="mathml" />
        <xsl:apply-templates mode="mathml" />
      </m:math>
    </xsl:for-each>
    <xsl:for-each select="$main-document//m:oMathPara[not(ancestor::w:p)]">
      <xsl:variable name="current">
        <xsl:apply-templates select="." mode="xml"/>
      </xsl:variable>
      <m:math checksum-id="{fn:checksum($current)}">
        <xsl:apply-templates select="@*" mode="mathml" />
        <xsl:apply-templates mode="mathml" />
      </m:math>
    </xsl:for-each>
  </w:body>
</xsl:variable>

<!--
  variable to sort, trim and create a tree of values to generate all index files
-->
<xsl:variable name="list-index-translated" as="element()">
 <root>
  <xsl:for-each select="$main-document//w:r/w:instrText[matches(text(),'XE')]/text()[generate-id() = generate-id(key('index',.)[1])]">
    <xsl:sort select="." />
    <xsl:variable name="temp-index-location" select="translate(translate(fn:get-index-text(.,'XE'),'/','_'),':','/')" />
    <xsl:variable name="full-index" select="string-join(for $i in tokenize($temp-index-location,'/') return encode-for-uri($i), '/')"/>

    <xsl:variable name="document-title">
      <xsl:choose>
        <xsl:when test="contains(fn:get-index-text(.,'XE'),':')">
          <xsl:value-of select="fn:string-after-last-delimiter(fn:get-index-text(.,'XE'),':')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="fn:get-index-text(.,'XE')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="contains($full-index,'/')">
        <element name="{substring-before($full-index,'/')}" title="{$document-title}">
          <xsl:for-each select="tokenize($temp-index-location,'/')">
            <xsl:if test="position() = 2">
               <element name="{.}" title="{$document-title}" />
            </xsl:if>
          </xsl:for-each>
        </element>
      </xsl:when>
      <xsl:otherwise>
        <element name="{$full-index}" title="{$document-title}" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</root>
</xsl:variable>

<!-- String of list of paragraph styles that belong to a list -->
<xsl:variable name="numbering-paragraphs-list-string" as="xs:string">
  <xsl:sequence select="fn:items-to-regex($numbering-document/w:numbering/w:abstractNum//w:pStyle/@w:val)"/>
</xsl:variable>

<!-- TODO We should probably use a function for the numbering... at least for error handling -->

<!-- List of valid integer numbering values -->
<xsl:variable name="numbering-decimal" as="xs:integer*"
  select="1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 167, 168, 169, 170, 171, 172 ,173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200" />

<!-- List of valid alpha numbering values -->
<xsl:variable name="numbering-alpha" as="xs:string*"
  select="'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'aa', 'bb', 'cc', 'dd', 'ee', 'ff', 'gg', 'hh', 'ii', 'jj', 'kk', 'll', 'mm', 'nn', 'oo', 'pp', 'qq', 'rr', 'ss', 'tt', 'uu', 'vv', 'ww', 'xx', 'yy', 'zz'" />

<!-- List of valid roman numbering values -->
<xsl:variable name="numbering-roman" as="xs:string*"
  select="'i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii', 'viii', 'ix', 'x', 'xi', 'xii', 'xiii', 'xiv', 'xv', 'xvi', 'xvii', 'xviii', 'xix', 'xx', 'xxi', 'xxii', 'xxiii', 'xxiv', 'xxv', 'xxvi', 'xxvii', 'xxviii', 'xxix', 'xxx', 'xxxi', 'xxxii', 'xxxiii', 'xxxiv', 'xxxv', 'xxxvi', 'xxxvii', 'xxxviii', 'xxxix', 'xl', 'xli', 'xlii', 'xliii', 'xliv', 'xlv', 'xlvi', 'xlvii', 'xlviii', 'xlix', 'l', 'li', 'lii', 'liii', 'liv', 'lv', 'lvi', 'lvii', 'lviii', 'lvix', 'lx', 'lxi', 'lxii', 'lxiii', 'lxiv', 'lxv', 'lxvi', 'lxvii', 'lxviii', 'lxix', 'lxx', 'lxxi', 'lxxii', 'lxxiii', 'lxxiv', 'lxxv', 'lxxvi', 'lxxvii', 'lxxviii', 'lxxix', 'lxxx', 'lxxxi', 'lxxxii', 'lxxxiii', 'lxxxiv', 'lxxxv', 'lxxxvi', 'lxxxvii', 'lxxxviii', 'lxxxix', 'xc', 'xci', 'xcii', 'xciii', 'xciv', 'xcv', 'xcvi', 'xcvii', 'xcviii', 'xcix', 'c'" />

<!--
  Checks if the current style name has a word numbering format

  @param style-name the current word style name
  @param current the current node

  @return whether a word numbering format is defined
-->
<xsl:function name="fn:has-numbering-format" as="xs:boolean">
  <xsl:param name="style-name" />
  <xsl:param name="current" />
  <xsl:choose>
    <xsl:when test="matches($style-name, $numbering-paragraphs-list-string)">
      <xsl:variable name="currentNumId">
        <xsl:sequence select="fn:get-numid-from-style($current)" />
      </xsl:variable>
      <xsl:variable name="currentAbstractNumId">
        <xsl:value-of select="fn:get-abstract-num-id-from-num-id($currentNumId)" />
      </xsl:variable>
      <xsl:variable name="currentLevel">
        <xsl:value-of select="fn:get-level-from-element($current)" />
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$numbering-document/w:numbering/w:abstractNum[@w:abstractNumId=$currentAbstractNumId]/w:lvl[@w:ilvl=$currentLevel]/w:numFmt/@w:val='bullet'">
          <xsl:sequence select="false()" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="true()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="false()" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Returns the level of the numbered paragraph for pageseeder heading levels.

  @param current the node

  @return the corresponding level
-->
<xsl:function name="fn:get-preceding-heading-level-from-element" as="xs:string">
  <xsl:param name="current" as="element()" />
  <xsl:choose>
    <xsl:when test="$current/w:pPr/w:numPr/w:ilvl">
      <xsl:value-of select="'0'" />
    </xsl:when>
    <xsl:when test="$numbering-document//w:abstractNum/w:lvl[w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val]">
      <xsl:value-of select="count($numbering-document//w:abstractNum/w:lvl[w:pStyle/@w:val = $current/w:pPr/w:pStyle/@w:val]/preceding-sibling::w:lvl[matches(w:pStyle/@w:val,config:heading-paragraphs-list-string())])" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="'0'" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Path for the media folder

  @return media folder path
-->
<xsl:variable name="media-folder-name" as="xs:string">
  <xsl:choose>
    <xsl:when test="$_mediafoldername = ''">
      <xsl:value-of select="encode-for-uri(concat($filename,'_files'))" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="encode-for-uri($_mediafoldername)" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!--
  Path for the component folder

  @return component folder path
-->
<xsl:variable name="component-folder-name" as="xs:string">
  <xsl:choose>
    <xsl:when test="$_componentfoldername = ''">
      <xsl:value-of select="''" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat(encode-for-uri($_componentfoldername),'/')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>


</xsl:stylesheet>