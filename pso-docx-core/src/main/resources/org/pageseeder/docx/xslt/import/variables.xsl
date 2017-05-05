<?xml version="1.0" encoding="utf-8"?>

  <!--
    This stylesheet transform openXML into PS Format
  
    @author Hugo Inacio 
    @copyright Allette Systems Pty Ltd 
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office"
	xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml"
	xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
	xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main" xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships" xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
	xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
  xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types" xmlns:fn="http://www.pageseeder.com/function" exclude-result-prefixes="#all">

  <!-- location of the configuration file -->
	<xsl:variable name="config-doc" select="document($_configfileurl)" as="node()"/>
  
  <!-- default value of the character styles input -->
	<xsl:variable name="character-styles" as="xs:string?">
		<xsl:choose>
			<xsl:when test="$config-doc/config/styles/default/characterStyles/@value">
				<xsl:value-of select="$config-doc/config/styles/default/characterStyles/@value" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'inline'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- default value of the paragraph styles input -->
	<xsl:variable name="paragraph-styles" as="xs:string?">
		<xsl:choose>
			<xsl:when test="$config-doc/config/styles/default/paragraphStyles/@value = 'para'">
				<xsl:value-of select="'para'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'block'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- boolean variable that sets usage of protected sections -->
  <xsl:variable name="use-protectedsections" as="xs:boolean">
    <xsl:choose>
      <xsl:when
        test="$config-doc/config/split/section/protectedsection[@select = 'true']">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- variable that uses protected section id -->
  <xsl:variable name="protectedsection-id">
    <xsl:choose>
      <xsl:when
        test="$config-doc/config/split/section/protectedsection[@select = 'true']">
        <xsl:value-of select="$config-doc/config/split/section/protectedsection/@id" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- location of the numbering file from the input docx -->
	<xsl:variable name="numbering" select="concat($_rootfolder,'/word/numbering.xml')" as="xs:string?"/>
  
  <!-- location of the main document file from the input docx -->
	<xsl:variable name="main" select="concat($_rootfolder,'/word/new-document.xml')" as="xs:string?"/>
  
  <!-- location of the styles  file from the input docx -->
	<xsl:variable name="styles" select="concat($_rootfolder,'word/styles.xml')" as="xs:string?" />
  
  <!-- name of the docx file without docx extention -->
	<xsl:variable name="filename" select="$_docxfilename"  as="xs:string?"/>
  
  <!-- location of the relationship file from the input docx -->
	<xsl:variable name="rels" select="concat($_rootfolder,'word/_rels/new-document.xml.rels')"  as="xs:string?"/>
  
  <!-- document node of the main document.xml file of the docx input document  -->
	<xsl:variable name="maindocument" select="document($main)" as="node()"/>
  
  <!-- footnote  file path -->
  <xsl:variable name="footnotes-file" select="concat($_rootfolder,'/word/new-footnotes.xml')"/>
  
  <!-- footnote document file -->
  <xsl:variable name="footnotes" select="document($footnotes-file)"/>
  
  <!-- endnote  file path -->
  <xsl:variable name="endnotes-file" select="concat($_rootfolder,'/word/new-endnotes.xml')"/>
  
   <!-- endnote document file -->
  <xsl:variable name="endnotes" select="document($endnotes-file)"/>

  <!-- Variable that defines name of the tile for the main document -->
	<xsl:variable name="document-title" as="xs:string?">
		<xsl:variable name="core" select="document(concat($_rootfolder,'docProps/core.xml'))" />
		<xsl:choose>
			<xsl:when test="$core//dc:title != ''">
				<xsl:value-of select="$core//dc:title" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$filename" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!--  count of total number of files: used to be referenced from xrefs, and also numbering split files -->
	<xsl:variable name="number-of-splits" select="count($maindocument//w:p[fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.)][string-join(w:r//text(), '') != '']|$maindocument//w:p[fn:matches-document-specific-split-styles(.)]) + 1"  as="xs:integer"/>

    <!--  variable used to sort output files -->
	<xsl:variable name="zeropadding"  as="xs:string">
		<xsl:choose>
			<xsl:when test="$number-of-splits &lt; 10">
				<xsl:value-of select="'0'" />
			</xsl:when>
			<xsl:when test="$number-of-splits &lt; 100">
				<xsl:value-of select="'00'" />
			</xsl:when>
			<xsl:when test="$number-of-splits &lt; 1000">
				<xsl:value-of select="'000'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'0000'" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!--  funtion to test if a paragraph stype is part of the config ignore list -->
	<xsl:function name="fn:matches-ignore-paragraph-match-list" as="xs:boolean">
		<xsl:param name="current" as="node()" />
		<xsl:choose>
			<xsl:when test="$current[matches(w:pPr/w:pStyle/@w:val,$ignore-paragraph-match-list-string)]">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!-- 
  variable used to do calculations of document position of:
  1. Lists
  2. xrefs
  3. document splits
  4. section splits
   -->
	<xsl:variable name="list-paragraphs" as="element()">
		<w:body xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office"
			xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml"
			xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
			xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
			xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main" xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships" xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
			xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.pageseeder.com/function">
<!--         <xsl:message><xsl:value-of select="$document-split-styles-string"/></xsl:message> -->
			<xsl:for-each select="$maindocument//w:p[not(parent::w:tc)][not(matches(w:pPr/w:pStyle/@w:val, $ignore-paragraph-match-list-string))][string-join(w:r//text(), '') != '']|$maindocument//w:bookmarkStart|$maindocument//w:tc|$maindocument//w:p[matches(w:pPr/w:pStyle/@w:val, $document-specific-split-styles-string)]|$maindocument//w:p[matches(w:pPr/w:pStyle/@w:val, $section-specific-split-styles-string)]">
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
    <xsl:value-of select="($maindocument//w:sectPr[w:footnotePr]/w:footnotePr/w:numFmt/@w:val)[last()]"/>
  </xsl:variable>
  
  <!-- format value of endnote numbering -->
  <xsl:variable name="endnote-format" as="xs:string?">
    <xsl:value-of select="($maindocument//w:sectPr[w:endnotePr]/w:endnotePr/w:numFmt/@w:val)[last()]"/>
  </xsl:variable>
  
   <!-- 
  variable that cotains all XE filed elements to generate indexes
   -->
	<xsl:variable name="list-index" as="element()">
		<w:body xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office"
			xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml"
			xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
			xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
			xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main" xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships" xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
			xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.pageseeder.com/function">
<!--         <xsl:message><xsl:value-of select="$document-split-styles-string"/></xsl:message> -->
			<xsl:for-each select="$maindocument//w:r[w:instrText[matches(text(),'XE')]]">
				<xsl:element name="{name()}">
					<xsl:copy-of select="@*" />
					<xsl:apply-templates mode="paracopy" />
				</xsl:element>
			</xsl:for-each>
		</w:body>
	</xsl:variable>
  
   <!-- 
  variable that cotains all mathml filed elements to generate indexes
   -->
  <xsl:variable name="list-mathml" as="element()">
    <w:body xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:o="urn:schemas-microsoft-com:office:office"
      xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml"
      xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
      xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
      xmlns:a14="http://schemas.microsoft.com/office/drawing/2010/main" xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships" xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
      xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.pageseeder.com/function">
<!--         <xsl:message><xsl:value-of select="$document-split-styles-string"/></xsl:message> -->
      <xsl:for-each select="$maindocument//(m:oMath[not(ancestor::m:oMathPara)]|m:oMath[ancestor::m:oMathPara and ancestor::w:p])">
        <xsl:variable name="current">
          <xsl:apply-templates select="." mode="xml"/>
        </xsl:variable>
        <m:math>
          <xsl:attribute name="checksum-id" select="fn:checksum($current)"/>
            <xsl:apply-templates select="@*" mode="mathml" />
            <xsl:apply-templates mode="mathml" />
        </m:math>
<!--         <xsl:message select="fn:checksum($current)"></xsl:message> -->
      </xsl:for-each>
      <xsl:for-each select="$maindocument//m:oMathPara">
        <xsl:variable name="current">
          <xsl:apply-templates select="." mode="xml"/>
        </xsl:variable>
        <m:math>
          <xsl:attribute name="checksum-id" select="fn:checksum($current)"/>
            <xsl:apply-templates select="@*" mode="mathml" />
            <xsl:apply-templates mode="mathml" />
        </m:math>
      </xsl:for-each>
      
    </w:body>
  </xsl:variable>
  
  <!-- boolean variable to set or not mathml files -->
  <xsl:variable name="generate-mathml-files" as="xs:boolean">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/mathml[@select= 'true'][@output= 'generate-files']">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
   <!-- boolean variable to convert or not mathml files -->
  <xsl:variable name="convert-omml-to-mml" as="xs:boolean">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/mathml[@select= 'true'][@convert-to-mml= 'true']">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
   <!-- boolean variable to convert or not footnote files -->
  <xsl:variable name="convert-footnotes" as="xs:boolean">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/footnotes[@select= 'true']">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  
   <!-- variable to define what type of conversion to be used for footnotes-->
  <xsl:variable name="convert-footnotes-type" as="xs:string?">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/footnotes[@select= 'true'][@output='generate-files']">
        <xsl:value-of select="'generate-files'" />
      </xsl:when>
      <xsl:when test="$config-doc/config/split/footnotes[@select= 'true'][@output='generate-fragments']">
        <xsl:value-of select="'generate-fragments'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'generate-fragments'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
   <!-- boolean variable to convert or not endnote files -->
  <xsl:variable name="convert-endnotes" as="xs:boolean">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/endnotes[@select= 'true']">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- variable to define what type of conversion to be used for endnotes-->
  <xsl:variable name="convert-endnotes-type" as="xs:string?">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/endnotes[@select= 'true'][@output='generate-files']">
        <xsl:value-of select="'generate-files'" />
      </xsl:when>
      <xsl:when test="$config-doc/config/split/endnotes[@select= 'true'][@output='generate-fragments']">
        <xsl:value-of select="'generate-fragments'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'generate-fragments'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
    
  <!-- 
  key to match XE text
   -->
	<xsl:key name="index" match="w:r/w:instrText/text()" use="." />
  
  <!-- 
  variable to sort, trim and create a tree of values to generate all index files
   -->
	<xsl:variable name="list-index-translated" as="element()">
	 <root>
		<xsl:for-each select="$maindocument//w:r/w:instrText[matches(text(),'XE')]/text()[generate-id() = generate-id(key('index',.)[1])]">
			<xsl:sort select="." />
			<xsl:variable name="temp-index-location" select="translate(translate(fn:get-index-text(.,'XE'),'/','_'),':','/')" />
			<xsl:variable name="full-index">
<!--        <xsl:message select="$temp-index-location"></xsl:message> -->
				<xsl:for-each select="tokenize($temp-index-location,'/')">
					<xsl:choose>
						<xsl:when test="position() != last()">
<!--              <xsl:message select="concat(encode-for-uri(.),'/')"></xsl:message> -->
							<xsl:value-of select="concat(encode-for-uri(.),'/')" />
						</xsl:when>
						<xsl:otherwise>
<!--              <xsl:message select="encode-for-uri(.)"></xsl:message> -->
							<xsl:value-of select="encode-for-uri(.)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:variable>

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
					<xsl:element name="element">
					  <xsl:attribute name="name" select="substring-before($full-index,'/')" />
						<xsl:attribute name="title" select="$document-title" />
						<xsl:for-each select="tokenize($temp-index-location,'/')">
							<xsl:if test="position() = 2">
                 <xsl:element name="element">
                   <xsl:attribute name="name" select="." />
                   <xsl:attribute name="title" select="$document-title" />
                 </xsl:element>
							</xsl:if>
						</xsl:for-each>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="element">
					  <xsl:attribute name="name" select="$full-index" />
						<xsl:attribute name="title" select="$document-title" />
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
  </root>
<!--     <xsl:for-each select="tokenize($full-index,'/')"> -->
<!--      <xsl:choose> -->
<!--        <xsl:when test="position() != last()"> -->
<!--          <xsl:value-of select="concat(encode-for-uri(.),'/')"/> -->
<!--             </xsl:when> -->
<!--             <xsl:otherwise> -->
<!--          <xsl:value-of select="encode-for-uri(.)"/> -->
<!--        </xsl:otherwise> -->
<!--      </xsl:choose> -->
<!--    </xsl:for-each> -->
	</xsl:variable>   

   
  <!--  List of numbering regular expressions to be captured in the config file -->
	<xsl:variable name="document-split-styles" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$config-doc/config/split/document/wordstyle/@select = ''">
				<xsl:value-of select="concat('^','No Submitted Value','$')" />
			</xsl:when>
			<xsl:when test="not($config-doc/config/split/document/wordstyle)">
				<xsl:value-of select="concat('^','No Submitted Value','$')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$config-doc/config/split/document/wordstyle/@select">
					<xsl:choose>
						<xsl:when test="position() = last()">
							<xsl:value-of select="concat('^',.,'$')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('^',.,'$','|')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- String of list of numbering regular expressions to be captured in the config file -->
  <xsl:variable name="document-split-styles-string" select="string-join($document-split-styles,'')" as="xs:string"/>
  
  <!--  List of numbering regular expressions to be captured in the config file -->
  <xsl:variable name="document-specific-split-styles" as="xs:string *">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/document/splitstyle/@select = ''">
        <xsl:value-of select="concat('^','No Submitted Value','$')" />
      </xsl:when>
      <xsl:when test="not($config-doc/config/split/document/splitstyle)">
        <xsl:value-of select="concat('^','No Submitted Value','$')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$config-doc/config/split/document/splitstyle/@select">
          <xsl:choose>
            <xsl:when test="position() = last()">
              <xsl:value-of select="concat('^',.,'$')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('^',.,'$','|')" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!--  String of list of numbering regular expressions to be captured in the config file -->
  <xsl:variable name="document-specific-split-styles-string" select="string-join($document-specific-split-styles,'')" as="xs:string"/>
  
  <!--  List of bookmark start ids defined to split at fragment level -->
  <xsl:variable name="bookmark-start-section-split-regex" as="xs:string *">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/section/bookmark/@select = ''">
        <xsl:value-of select="concat('^','No Submitted Value','$')" />
      </xsl:when>
      <xsl:when test="not($config-doc/config/split/section/bookmark)">
        <xsl:value-of select="concat('^','No Submitted Value','$')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$config-doc/config/split/section/bookmark/@select">
          <xsl:choose>
            <xsl:when test="position() = last()">
              <xsl:value-of select="concat('^',.)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('^',.,'|')" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- String of list of bookmark start ids defined to split at fragment level -->
  <xsl:variable name="bookmark-start-section-split-regex-string" select="string-join($bookmark-start-section-split-regex,'')" as="xs:string"/>
  
  <!--  List of bookmark end ids defined to split at fragment level -->
  <xsl:variable name="bookmark-end-section-split-regex-ids" as="xs:string *">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/section/bookmark/@select = ''">
        <xsl:value-of select="concat('^','No Submitted Value','$')" />
      </xsl:when>
      <xsl:when test="not($config-doc/config/split/section/bookmark)">
        <xsl:value-of select="concat('^','No Submitted Value','$')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$maindocument//w:bookmarkStart[matches(@w:name,$bookmark-start-section-split-regex-string)]">
          <xsl:choose>
            <xsl:when test="position() = last()">
              <xsl:value-of select="concat('^',@w:id,'$')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('^',@w:id,'$','|')" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- String of list of bookmark end ids defined to split at fragment level -->
  <xsl:variable name="bookmark-end-section-split-regex-ids-string" select="string-join($bookmark-end-section-split-regex-ids,'')" as="xs:string"/>
  
  <!-- list of valid pageseeder list types -->
	<xsl:variable name="pageseeder-list-types" select="'^arabic$|^upperalpha$|^loweralpha$|^upperroman$|^lowerroman$'" as="xs:string"/>
  
  <!-- Values come from configuration file: list of values that specify on what outline levels to split the document -->
	<xsl:variable name="document-split-outline" as="xs:string *">
		<xsl:choose>
			<xsl:when test="not($config-doc/config/split/document/outlinelevel)">
				<xsl:value-of select="concat('^','No Submitted Value','$')" />
			</xsl:when>
			<xsl:when test="$config-doc/config/split/document/outlinelevel/@select = ''">
				<xsl:value-of select="concat('^','No Submitted Value','$')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$config-doc/config/split/document/outlinelevel/@select">
					<xsl:choose>
						<xsl:when test="position() = last()">
							<xsl:value-of select="concat('^',.,'$')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('^',.,'$','|')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- String of list of outline levels defined to split at document level -->
  <xsl:variable name="document-split-outline-string" select="string-join($document-split-outline,'')" as="xs:string"/>
  
  <!-- Values come from configuration file: list of values that specify on what section breaks to split the document -->
	<xsl:variable name="document-split-sectionbreak" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$config-doc/config/split/document/sectionbreak/@select = ''">
				<xsl:value-of select="concat('^','No Submitted Value','$')" />
			</xsl:when>
			<xsl:when test="not($config-doc/config/split/document/sectionbreak)">
				<xsl:value-of select="concat('^','No Submitted Value','$')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$config-doc/config/split/document/sectionbreak/@select">
					<xsl:choose>
						<xsl:when test="position() = last()">
							<xsl:value-of select="concat('^',.,'$')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('^',.,'$','|')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- String of list of section breaks defined to split at document level -->
  <xsl:variable name="document-split-sectionbreak-string" select="string-join($document-split-sectionbreak,'')" as="xs:string"/>
  
  <!-- list of convert manual numbering matching regular expressions -->
	<xsl:variable name="numbering-match-list" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$config-doc/config/lists/convert-manual-numbering/@select = 'true'">
				<xsl:for-each select="$config-doc/config/lists/convert-manual-numbering/value">
					<xsl:choose>
						<xsl:when test="position() = last()">
							<xsl:value-of select="concat('^',@match)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('^',@match,'|')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('^','No Selected Value','$')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- string of lis of convert manual numbering matching regular expressions -->
  <xsl:variable name="numbering-match-list-string" select="string-join($numbering-match-list,'')" as="xs:string"/>
  
  <!-- list of convert inline labels matching regular expressions -->
	<xsl:variable name="numbering-match-list-inline" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$config-doc/config/lists/convert-manual-numbering/@select = 'true' and $config-doc/config/lists/convert-manual-numbering/value[inline]">
				<xsl:for-each select="$config-doc/config/lists/convert-manual-numbering/value[inline]">
					<xsl:choose>
						<xsl:when test="position() = last()">
							<xsl:value-of select="concat('^',@match)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('^',@match,'|')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('^','No Selected Value','$')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- string of list of convert inline labels matching regular expressions -->
  <xsl:variable name="numbering-match-list-inline-string" select="string-join($numbering-match-list-inline,'')" as="xs:string"/>
  
  <!-- configuration value to generate or not index files -->
	<xsl:variable name="generate-index-files" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$config-doc/config/styles/default/generate-index-files[@select= 'true']">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- check if prefix generation for conversion of manual numbering exists -->
	<xsl:variable name="numbering-list-prefix-exists" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$config-doc/config/lists/convert-manual-numbering/value[prefix]">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

  <!-- check if autonumbering generation for conversion of manual numbering exists -->
	<xsl:variable name="numbering-list-autonumbering-exists" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$config-doc/config/lists/convert-manual-numbering/value[autonumbering]">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- list of prefix manual conversion regular expressions -->
	<xsl:variable name="numbering-match-list-prefix" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$config-doc/config/lists/convert-manual-numbering/@select = 'true'">
				<xsl:for-each select="$config-doc/config/lists/convert-manual-numbering/value[prefix]">
					<xsl:choose>
						<xsl:when test="position() = last()">
							<xsl:value-of select="concat('^',@match)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('^',@match,'|')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('^','No Selected Value','$')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- String of list of prefix manual conversion regular expressions -->
  <xsl:variable name="numbering-match-list-prefix-string" select="string-join($numbering-match-list-prefix,'')" as="xs:string"/>
  
  <!-- list of autonumbering manual conversion regular expressions -->
	<xsl:variable name="numbering-match-list-autonumbering" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$config-doc/config/lists/convert-manual-numbering/@select = 'true' and $numbering-list-autonumbering-exists">
				<xsl:for-each select="$config-doc/config/lists/convert-manual-numbering/value[autonumbering]">
					<xsl:choose>
						<xsl:when test="position() = last()">
							<xsl:value-of select="concat('^',@match)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('^',@match,'|')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('^','No Selected Value','$')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- String of list of autonumbering manual conversion regular expressions -->
  <xsl:variable name="numbering-match-list-autonumbering-string" select="string-join($numbering-match-list-autonumbering,'')" as="xs:string"/>
  
  <!-- list of paragraph styles to ignore -->
	<xsl:variable name="ignore-paragraph-match-list" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$config-doc/config/styles/ignore/wordstyle">
				<xsl:for-each select="$config-doc/config/styles/ignore/wordstyle">
					<xsl:choose>
						<xsl:when test="position() = last()">
							<xsl:value-of select="concat('^',@value,'$')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('^',@value,'$','|')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('^','No Selected Value','$')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- String of list of paragraph styles to ignore -->
  <xsl:variable name="ignore-paragraph-match-list-string" select="string-join($ignore-paragraph-match-list,'')" as="xs:string"/>
  
  
  <!-- node of numbering document -->
	<xsl:variable name="numbering-document" select="if (doc-available($numbering)) then document($numbering) else ." as="node()"/>
  
  <!-- node of styles document -->
	<xsl:variable name="styles-document" select="document($styles)" as="node()"/>
  
  <!-- node of relationship document -->
	<xsl:variable name="relationship-document" select="document($rels)" as="node()"/>


  <!-- list of paragraph styles that belong to a list -->
	<xsl:variable name="numbering-paragraphs-list" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$numbering-document/w:numbering/w:abstractNum//w:pStyle/@w:val">
				<xsl:for-each select="$numbering-document/w:numbering/w:abstractNum//w:pStyle/@w:val">
					<xsl:choose>
						<xsl:when test="position() = last()">
							<xsl:value-of select="concat('^',.,'$')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('^',.,'$','|')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
<!-- 				<xsl:for-each select="$styles-document//w:style[w:pPr/w:numPr/w:numId/@w:val]/@w:styleId"> -->
<!--           <xsl:choose> -->
<!--             <xsl:when test="position() = 1"> -->
<!--               <xsl:value-of select="concat('|','^',.,'$','|')" /> -->
<!--             </xsl:when> -->
<!--             <xsl:when test="position() = last()"> -->
<!--               <xsl:value-of select="concat('^',.,'$')" /> -->
<!--             </xsl:when> -->
<!--             <xsl:otherwise> -->
<!--               <xsl:value-of select="concat('^',.,'$','|')" /> -->
<!--             </xsl:otherwise> -->
<!--           </xsl:choose> -->
<!--         </xsl:for-each> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('^','No Selected Value','$')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- String of list of paragraph styles that belong to a list -->
  <xsl:variable name="numbering-paragraphs-list-string" select="string-join($numbering-paragraphs-list,'')" as="xs:string"/>
  
  <!-- list of paragraph styles that are set to transform into headings in the configuration file -->
	<xsl:variable name="heading-paragraphs-list" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$config-doc/config/styles/wordstyle[@psmlelement='heading']/@name">
				<xsl:for-each select="$config-doc/config/styles/wordstyle[@psmlelement='heading']/@name">
					<xsl:choose>
						<xsl:when test="position() = last()">
							<xsl:value-of select="concat('^',.,'$')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('^',.,'$','|')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('^','No Selected Value','$')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- String of list of paragraph styles that are set to transform into headings in the configuration file -->
  <xsl:variable name="heading-paragraphs-list-string" select="string-join($heading-paragraphs-list,'')" as="xs:string"/>
  
  <!-- list of paragraph styles that are set to transform into para in the configuration file -->
	<xsl:variable name="para-paragraphs-list" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$config-doc/config/styles/wordstyle[@psmlelement='para']/@name">
				<xsl:for-each select="$config-doc/config/styles/wordstyle[@psmlelement='para']/@name">
					<xsl:choose>
						<xsl:when test="position() = last()">
							<xsl:value-of select="concat('^',.,'$')" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat('^',.,'$','|')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('^','No Selected Value','$')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- String of list of paragraph styles that are set to transform into para in the configuration file -->
  <xsl:variable name="para-paragraphs-list-string" select="string-join($para-paragraphs-list,'')" as="xs:string"/>
  
  <!-- list of paragraph styles that are set to split sections in the configuration file -->
	<xsl:variable name="section-split-styles" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$config-doc/config/split/section/wordstyle/@select">
				<xsl:choose>
					<xsl:when test="$config-doc/config/split/section/wordstyle/@select = ''">
						<xsl:value-of select="concat('^','No Submitted Value','$')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$config-doc/config/split/section/wordstyle/@select">
							<xsl:choose>
								<xsl:when test="position() = last()">
									<xsl:value-of select="concat('^',.,'$')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('^',.,'$','|')" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('^','No Selected Value','$')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- String of list of paragraph styles that are set to split sections in the configuration file -->
  <xsl:variable name="section-split-styles-string" select="string-join($section-split-styles,'')" as="xs:string"/>
  
  <!-- list of paragraph styles that are only used set to split sections in the configuration file; the content of these is then deleted -->
  <xsl:variable name="section-specific-split-styles" as="xs:string *">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/section/splitstyle/@select">
        <xsl:choose>
          <xsl:when test="$config-doc/config/split/section/splitstyle/@select = ''">
            <xsl:value-of select="concat('^','No Submitted Value','$')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="$config-doc/config/split/section/splitstyle/@select">
              <xsl:choose>
                <xsl:when test="position() = last()">
                  <xsl:value-of select="concat('^',.,'$')" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="concat('^',.,'$','|')" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('^','No Selected Value','$')" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- String of list of paragraph styles that are only used set to split sections in the configuration file; the content of these is then deleted -->
  <xsl:variable name="section-specific-split-styles-string" select="string-join($section-specific-split-styles,'')" as="xs:string"/>
  
  <!-- list of outline levels that are set to split sections in the configuration file -->
	<xsl:variable name="section-split-outline" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$config-doc/config/split/section/outlinelevel/@select">
				<xsl:choose>
					<xsl:when test="$config-doc/config/split/section/outlinelevel/@select = ''">
						<xsl:value-of select="'^','No Submitted Value','$'" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$config-doc/config/split/section/outlinelevel/@select">

							<xsl:choose>
								<xsl:when test="position() = last()">
									<xsl:value-of select="concat('^',.,'$')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('^',.,'$','|')" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('^','No Selected Value','$')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- String of list of outline levels that are set to split sections in the configuration file -->
  <xsl:variable name="section-split-outline-string" select="string-join($section-split-outline,'')" as="xs:string"/>
  
  <!-- list of sectionbreak styles that are set to split sections in the configuration file -->
	<xsl:variable name="section-split-sectionbreak" as="xs:string *">
		<xsl:choose>
			<xsl:when test="$config-doc/config/split/section/sectionbreak/@select">
				<xsl:choose>
					<xsl:when test="$config-doc/config/split/section/sectionbreak/@select = ''">
						<xsl:value-of select="'^','No Submitted Value','$'" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$config-doc/config/split/section/sectionbreak/@select">

							<xsl:choose>
								<xsl:when test="position() = last()">
									<xsl:value-of select="concat('^',.,'$')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('^',.,'$','|')" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('^','No Selected Value','$')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!-- String of list of sectionbreak styles that are set to split sections in the configuration file -->
  <xsl:variable name="section-split-sectionbreak-string" select="string-join($section-split-sectionbreak,'')" as="xs:string"/>
  
  <!-- list of references that are set to split sections in the configuration file -->
<!-- 	<xsl:variable name="section-split-reference"> -->
<!-- 		<xsl:choose> -->
<!-- 			<xsl:when test="$config-doc/config/split/section/type[@name = 'references']/@select = ''"> -->
<!-- 				<xsl:value-of select="concat('^','No Selected Value','$')" /> -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:otherwise> -->
<!-- 				<xsl:value-of select="$config-doc/config/split/document/type[@name = 'references']/@select" /> -->
<!-- 			</xsl:otherwise> -->
<!-- 		</xsl:choose> -->
<!-- 	</xsl:variable> -->
  
  <!-- list of element names that are in the configuration file -->
<!-- 	<xsl:variable name="element-property-list"> -->
<!-- 		<xsl:choose> -->
<!-- 			<xsl:when test="$config-doc/config/styles/wordstyle/@name"> -->
<!-- 				<xsl:for-each select="$config-doc/config/styles/wordstyle/@name"> -->
<!-- 					<xsl:choose> -->
<!-- 						<xsl:when test="position() = last()"> -->
<!-- 							<xsl:value-of select="concat('^',.,'$')" /> -->
<!-- 						</xsl:when> -->
<!-- 						<xsl:otherwise> -->
<!-- 							<xsl:value-of select="concat('^',.,'$','|')" /> -->
<!-- 						</xsl:otherwise> -->
<!-- 					</xsl:choose> -->
<!-- 				</xsl:for-each> -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:otherwise> -->
<!-- 				<xsl:value-of select="concat('^','No Selected Value','$')" /> -->
<!-- 			</xsl:otherwise> -->
<!-- 		</xsl:choose> -->
<!-- 	</xsl:variable> -->
  
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
  Returns the boolean if the current node matches a section document break or not.

  @param current the current node

  @return true or false
  -->
	<xsl:function name="fn:matches-document-split-sectionbreak" as="xs:boolean">
		<xsl:param name="current" as="node()" />
		<xsl:choose>
			<xsl:when test="$current[w:pPr/w:sectPr][w:pPr/w:sectPr/w:type[matches(@w:val,($document-split-sectionbreak-string))]][not(fn:matches-ignore-paragraph-match-list(.))]">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the boolean if the current node matches a outline level document break or not.

  @param current the current node

  @return true or false
  -->
	<xsl:function name="fn:matches-document-split-outline" as="xs:boolean">
		<xsl:param name="current" as="node()" />
		<xsl:choose>
			<xsl:when
				test="$current[w:pPr/w:pStyle[@w:val = $styles-document/w:styles/w:style[matches(w:pPr/w:outlineLvl/@w:val,($document-split-outline-string))]/@w:styleId][not(fn:matches-ignore-paragraph-match-list(.))]]">
<!--               <xsl:message><xsl:value-of select="'fn:matches-document-split-outline:true'"/></xsl:message> -->
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:when test="$current[w:pPr/w:pStyle[@w:val = $styles-document/w:styles/w:style[w:basedOn/@w:val][not(w:pPr/w:outlineLvl/@w:val)]/@w:styleId]]">
				<xsl:variable name="basedon" select="$styles-document/w:styles/w:style[@w:styleId = $current/w:pPr/w:pStyle/@w:val]/w:basedOn/@w:val" />
<!--           <xsl:message><xsl:value-of select="$basedon"/></xsl:message> -->
				<xsl:choose>
					<xsl:when test="$current[$basedon = $styles-document/w:styles/w:style[matches(w:pPr/w:outlineLvl/@w:val,($document-split-outline-string))]/@w:styleId][not(fn:matches-ignore-paragraph-match-list(.))]">
<!--               <xsl:message><xsl:value-of select="'fn:matches-document-split-outline:true'"/></xsl:message> -->
						<xsl:value-of select="true()" />
					</xsl:when>
					<xsl:otherwise>
<!--               <xsl:message><xsl:value-of select="'fn:matches-document-split-outline:true'"/></xsl:message> -->
						<xsl:value-of select="false()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$current[w:pPr/w:pStyle[@w:val = $styles-document/w:styles/w:style[not(w:pPr/w:outlineLvl/@w:val)]/@w:styleId]]">
				<xsl:value-of select="false()" />
			</xsl:when>
			<xsl:when
				test="$current[w:pPr/w:pStyle[@w:val = $styles-document/w:styles/w:style[matches(w:pPr/w:outlineLvl/@w:val,($document-split-outline-string))]/@w:styleId]][not(fn:matches-ignore-paragraph-match-list(.))]">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the boolean if the current node matches a paragraph style document break or not.

  @param current the current node

  @return true or false
  -->
	<xsl:function name="fn:matches-document-split-styles" as="xs:boolean">
		<xsl:param name="current" as="node()" />
<!-- 		  <xsl:message><xsl:value-of select="$document-split-styles"/></xsl:message> -->
		<xsl:choose>
			<xsl:when test="$current[matches(w:pPr/w:pStyle/@w:val, ($document-split-styles-string))][not(fn:matches-ignore-paragraph-match-list(.))]">
				<xsl:value-of select="true()" />
<!-- 				<xsl:message><xsl:value-of select="'fn:matches-document-split-styles:true'"/></xsl:message> -->
			</xsl:when>
			<xsl:otherwise>
<!-- 			 <xsl:message><xsl:value-of select="'fn:matches-document-split-styles:false'"/></xsl:message> -->
				<xsl:value-of select="false()" />

			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
   <!--
  Returns the boolean if the current node matches a paragraph style document break or not.

  @param current the current node

  @return true or false
  -->
  <xsl:function name="fn:matches-document-specific-split-styles" as="xs:boolean">
    <xsl:param name="current" as="node()" />
<!--      <xsl:message><xsl:value-of select="$document-split-styles-string"/></xsl:message> -->
    <xsl:choose>
      <xsl:when test="$current[matches(w:pPr/w:pStyle/@w:val, ($document-specific-split-styles-string))]">
        <xsl:value-of select="true()" />
<!--        <xsl:message><xsl:value-of select="'fn:matches-document-split-styles:true'"/></xsl:message> -->
      </xsl:when>
      <xsl:otherwise>
<!--       <xsl:message><xsl:value-of select="'fn:matches-document-split-styles:false'"/></xsl:message> -->
        <xsl:value-of select="false()" />

      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
  Returns the boolean if the current node matches a section section break or not.

  @param current the current node

  @return true or false
  -->
	<xsl:function name="fn:matches-section-split-sectionbreak" as="xs:boolean">
		<xsl:param name="current" as="node()" />
		<xsl:choose>
			<xsl:when test="$current[w:pPr/w:sectPr][w:pPr/w:sectPr/w:type[matches(@w:val,($section-split-sectionbreak-string))]][not(fn:matches-ignore-paragraph-match-list(.))]">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the boolean if the current node matches a section protected section or not.

  @param current the current node

  @return true or false
  -->
  <xsl:function name="fn:matches-section-split-protectedsection" as="xs:boolean">
    <xsl:param name="current" as="node()" />
    <xsl:choose>
      <xsl:when test="$current[w:pPr/w:sectPr][w:bookmarkStart[starts-with(@w:name,$protectedsection-id)]][not(fn:matches-ignore-paragraph-match-list(.))]">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--
  Returns the boolean if the current node matches a outline level section break or not.

  @param current the current node

  @return true or false
  -->
	<xsl:function name="fn:matches-section-split-outline" as="xs:boolean">
		<xsl:param name="current" as="node()" />
		<xsl:choose>
			<xsl:when
				test="$current[w:pPr/w:pStyle[@w:val = $styles-document/w:styles/w:style[matches(w:pPr/w:outlineLvl/@w:val,($section-split-outline-string))]/@w:styleId][not(fn:matches-ignore-paragraph-match-list(.))]]">
<!--               <xsl:message><xsl:value-of select="'fn:matches-document-split-outline:true'"/></xsl:message> -->
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:when test="$current[w:pPr/w:pStyle[@w:val = $styles-document/w:styles/w:style[w:basedOn/@w:val][not(w:pPr/w:outlineLvl/@w:val)]/@w:styleId]]">
				<xsl:variable name="basedon" select="$styles-document/w:styles/w:style[@w:styleId = $current/w:pPr/w:pStyle/@w:val]/w:basedOn/@w:val" />
<!--           <xsl:message><xsl:value-of select="$basedon"/></xsl:message> -->
				<xsl:choose>
					<xsl:when test="$current[$basedon = $styles-document/w:styles/w:style[matches(w:pPr/w:outlineLvl/@w:val,($section-split-outline-string))]/@w:styleId][not(fn:matches-ignore-paragraph-match-list(.))]">
<!--               <xsl:message><xsl:value-of select="'fn:matches-document-split-outline:true'"/></xsl:message> -->
						<xsl:value-of select="true()" />
					</xsl:when>
					<xsl:otherwise>
<!--               <xsl:message><xsl:value-of select="'fn:matches-document-split-outline:true'"/></xsl:message> -->
						<xsl:value-of select="false()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when
				test="$current[w:pPr/w:pStyle/@w:val = $styles-document/w:styles/w:style[matches(w:pPr/w:outlineLvl/@w:val,($section-split-outline-string))]/@w:styleId][not(fn:matches-ignore-paragraph-match-list(.))]">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the boolean if the current node matches a section break bookmark start position.

  @param current the current node

  @return true or false
  -->
  <xsl:function name="fn:matches-section-split-bookmarkstart" as="xs:boolean">
    <xsl:param name="current" as="node()" />
    <xsl:choose>
      <xsl:when
        test="$current[w:bookmarkStart[matches(@w:name,$bookmark-start-section-split-regex-string)]]">
<!--               <xsl:message><xsl:value-of select="'fn:matches-document-split-outline:true'"/></xsl:message> -->
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--
  Returns the boolean if the current node matches a paragraph style section break or not. The content of this paragraph is ignored

  @param current the current node

  @return true or false
  -->
  <xsl:function name="fn:matches-section-specific-split-styles" as="xs:boolean">
    <xsl:param name="current" as="node()" />
    <xsl:choose>
      <xsl:when test="$current[matches(w:pPr/w:pStyle/@w:val, ($section-specific-split-styles-string))]">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  
  <!--
  Returns the boolean if the current node matches a paragraph style section break or not.

  @param current the current node

  @return true or false
  -->
	<xsl:function name="fn:matches-section-split-styles" as="xs:boolean">
		<xsl:param name="current" as="node()" />
		<xsl:choose>
			<xsl:when test="$current[matches(w:pPr/w:pStyle/@w:val, ($section-split-styles-string)) or matches(w:bookmarkstart/@w:name,$bookmark-start-section-split-regex-string)][not(fn:matches-ignore-paragraph-match-list(.))]">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

  <!--
  Returns the boolean if the preceding node matches a paragraph section break or not.

  @param current the current node

  @return true or false
  -->
	<xsl:function name="fn:matches-preceding-paragraph-as-split-level" as="xs:boolean">
		<xsl:param name="current" as="node()" />
		<xsl:choose>
			<xsl:when test="$current/preceding::w:p[1][fn:matches-document-specific-split-styles(.) or fn:matches-document-split-outline(.) or fn:matches-document-split-styles(.)  or matches(w:bookmarkstart/@w:name,$bookmark-start-section-split-regex-string)]">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the number of preceding split documents.

  @param currentid the current id of the current node

  @return number of documents
  -->
	<xsl:function name="fn:count-preceding-documents"  as="xs:integer">
		<xsl:param name="currentid" />
		<xsl:variable name="currentCounter"
			select="count($list-paragraphs//*[@id=$currentid]/following::*[1]/preceding::w:p[fn:matches-document-specific-split-styles(.) or fn:matches-document-split-sectionbreak(.) or fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.)])" />

		<xsl:choose>
			<xsl:when
				test="$list-paragraphs//*[@id=$currentid]/following::*[1]/preceding::w:p[not(fn:matches-document-specific-split-styles(.) or fn:matches-document-split-sectionbreak(.) or fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.))]">
				<xsl:value-of select="number($currentCounter) + 1" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="number($currentCounter) + 1" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the number of preceding fragments in the curremtn document.

  @param currentid the current bookmark reference id of the current node

  @return number of framgments
  -->
	<xsl:function name="fn:get-fragment-position" as="xs:string">
		<xsl:param name="bookmarkRefId" />
		<xsl:variable name="precedingDocumentNodeId"
			select="$list-paragraphs//w:bookmarkStart[@w:name=$bookmarkRefId]/preceding::w:p
    [fn:matches-document-split-sectionbreak(.) or fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.) or fn:matches-document-specific-split-styles(.) or w:bookmarkEnd[matches(@w:id,$bookmark-end-section-split-regex-ids-string)]][1]/@id" />
		<xsl:variable name="fragment-position">
      <xsl:choose>
        <xsl:when test="$precedingDocumentNodeId = ''">
<!--           <xsl:value-of select="$list-paragraphs//w:p[1]/following::w:p[fn:matches-section-split-styles(.)][not(preceding::w:bookmarkStart[@w:id=$bookmarkRefId])]/@id" /> -->
          <xsl:variable name="ending-position" select="count($list-paragraphs//w:p[1]/following::w:p[fn:matches-section-split-sectionbreak(.) or w:bookmarkEnd[matches(@w:id,$bookmark-end-section-split-regex-ids-string)]]) + 1"/>
          <xsl:variable name="starting-position" select="count($list-paragraphs//w:p[1]/following::w:p[fn:matches-section-specific-split-styles(.) or fn:matches-section-split-styles(.)][not(preceding::w:bookmarkStart[@w:id=$bookmarkRefId])]) + 1"/>
          <xsl:value-of select="concat($ending-position,'-',$starting-position)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="ending-position" select="count($list-paragraphs//w:p[@id = $precedingDocumentNodeId]/following::w:p[fn:matches-section-split-sectionbreak(.) or w:bookmarkEnd[matches(@w:id,$bookmark-end-section-split-regex-ids-string)]]) + 1"/>
          <xsl:variable name="starting-position" select="count($list-paragraphs//w:p[@id = $precedingDocumentNodeId]/following::w:p[fn:matches-section-specific-split-styles(.) or fn:matches-section-split-styles(.)][not(preceding::w:bookmarkStart[@w:name=$bookmarkRefId])]) + 1"/>
<!--           <xsl:value-of select="$list-paragraphs//w:p[@id = $precedingDocumentNodeId]/following::w:p[fn:matches-section-split-styles(.)][not(preceding::w:bookmarkStart[@w:name=$bookmarkRefId])]/@id" /> -->
          <xsl:value-of select="concat($ending-position,'-',$starting-position)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$fragment-position = '1-1'">
        <xsl:value-of select="'title'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$fragment-position" />
      </xsl:otherwise>
    </xsl:choose>
    
	</xsl:function>
  
  <!--
  Returns the number of preceding documents in the current document.

  @param bookmarkrefid the current bookmark reference id of the current node

  @return number of documents
  -->
	<xsl:function name="fn:get-document-position" as="xs:string">
		<xsl:param name="bookmarkRefId" />

		<xsl:variable name="currentCounter"
			select="count($list-paragraphs//w:bookmarkStart[@w:name=$bookmarkRefId]/preceding::w:p[fn:matches-document-split-sectionbreak(.) or fn:matches-document-specific-split-styles(.) or fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.)])" />

		<xsl:choose>
			<xsl:when
				test="$list-paragraphs//w:bookmarkStart[@w:name=$bookmarkRefId]/preceding::w:p[not(fn:matches-document-split-sectionbreak(.) or fn:matches-document-specific-split-styles(.) or fn:matches-document-split-styles(.) or fn:matches-document-split-outline(.))]">
				<xsl:value-of select="number($currentCounter) + 1" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="number($currentCounter)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the type of output that the manual numbering of the current level should have.

  @param currentLevel the current level of the current node

  @return type of output
  -->
	<xsl:function name="fn:get-numbered-paragraph-value" as="xs:string">
		<xsl:param name="currentLevel" />
		<xsl:choose>
			<xsl:when test="$config-doc/config/lists/convert-to-numbered-paragraphs[not(@select='true')]">
				<xsl:value-of select="'Nothing Selected'" />
			</xsl:when>
			<xsl:when test="$config-doc/config/lists/convert-to-numbered-paragraphs[@select='true']/not(level[@value=$currentLevel])">
				<xsl:value-of select="'Nothing Selected'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$config-doc/config/lists/convert-to-numbered-paragraphs[@select='true']/level[@value=$currentLevel]/@output" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the type of numbering that the current element should have. Specific for heading

  @param style-name the current word style name

  @return type of value
  -->
	<xsl:function name="fn:get-numbered-heading-value" as="xs:string">
		<xsl:param name="style-name" />
		<xsl:choose>
			<xsl:when test="$config-doc/config/styles/wordstyle[@name=$style-name]/numbering[not(@select='true')]">
				<xsl:value-of select="'Nothing Selected'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/numbering[@select='true']/@value" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the inline label that the current element should have. Specific for heading

  @param style-name the current word style name

  @return inline label value
  -->
	<xsl:function name="fn:get-inline-heading-value" as="xs:string">
		<xsl:param name="style-name" />
		<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/numbering[@select='true']/label/@value" />
	</xsl:function>
  
  <!--
  Returns the type of numbering that the current element should have. Specific for para

  @param style-name the current word style name

  @return type of value
  -->
	<xsl:function name="fn:get-numbered-para-value" as="xs:string">
		<xsl:param name="style-name" />
		<xsl:choose>
			<xsl:when test="$config-doc/config/styles/wordstyle[@name=$style-name]/numbering[not(@select='true')]">
				<xsl:value-of select="'Nothing Selected'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/numbering[@select='true']/@value" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the inline label that the current element should have. Specific for para

  @param style-name the current word style name

  @return inline label value
  -->
	<xsl:function name="fn:get-inline-para-value"  as="xs:string">
		<xsl:param name="style-name" />
		<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/numbering[@select='true']/label/@value" />
	</xsl:function>

  <!--
  Returns the label that the current element should have.

  @param style-name the current word style name

  @return label value
  -->
	<xsl:function name="fn:get-label-from-psml-element"  as="xs:string">
		<xsl:param name="style-name" />
		<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/label/@value" />
	</xsl:function>
  
  <!--
  Returns the document label that the main references document has.

  @return document label value
  -->
  <xsl:function name="fn:document-label-for-main-document"  as="xs:string">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/main/label">
        <xsl:value-of select="$config-doc/config/split/main/label" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--
  Returns the document type that the main references document has.

  @return document type value
  -->
  <xsl:function name="fn:document-type-for-main-document"  as="xs:string">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/main/type">
        <xsl:value-of select="$config-doc/config/split/main/type" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--
  Returns the document label that the split style should have.

  @param style-name the current word style name

  @return document label value
  -->
	<xsl:function name="fn:document-label-for-split-style"  as="xs:string">
		<xsl:param name="style-name" />
		<xsl:choose>
			<xsl:when test="$config-doc/config/split/document/wordstyle[@select=$style-name]/label">
				<xsl:value-of select="$config-doc/config/split/document/wordstyle[@select=$style-name]/label" />
			</xsl:when>
      <xsl:when test="$config-doc/config/split/document/splitstyle[@select=$style-name]/label">
        <xsl:value-of select="$config-doc/config/split/document/splitstyle[@select=$style-name]/label" />
      </xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="''" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the document type that the split style should have.

  @param style-name the current word style name

  @return document type value
  -->
	<xsl:function name="fn:document-type-for-split-style" as="xs:string">
		<xsl:param name="style-name" />
		<xsl:choose>
			<xsl:when test="$config-doc/config/split/document/wordstyle[@select=$style-name]/type">
				<xsl:value-of select="$config-doc/config/split/document/wordstyle[@select=$style-name]/type" />
			</xsl:when>
      <xsl:when test="$config-doc/config/split/document/splitstyle[@select=$style-name]/type">
        <xsl:value-of select="$config-doc/config/split/document/splitstyle[@select=$style-name]/type" />
      </xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="''" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the blockxref level that the split style should have.

  @param style-name the current word style name

  @return blockxref level value
  -->
  <xsl:function name="fn:document-level-for-split-style" as="xs:string">
    <xsl:param name="style-name" />
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/document/wordstyle[@select=$style-name]/level/@value">
        <xsl:value-of select="$config-doc/config/split/document/wordstyle[@select=$style-name]/level/@value" />
      </xsl:when>
      <xsl:when test="$config-doc/config/split/document/splitstyle[@select=$style-name]/level/@value">
        <xsl:value-of select="$config-doc/config/split/document/splitstyle[@select=$style-name]/level/@value" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--
  Returns the fragment type that the split style should have.

  @param style-name the current word style name

  @return fragment type value
  -->
	<xsl:function name="fn:fragment-type-for-split-style" as="xs:string">
		<xsl:param name="style-name" />
<!--     <xsl:message><xsl:value-of select="$style-name"/></xsl:message> -->
<!--     <xsl:message><xsl:value-of select="$config-doc/config/split/section/wordstyle[@select=$style-name]/type"/></xsl:message> -->
		<xsl:choose>
			<xsl:when test="$config-doc/config/split/section/wordstyle[@select=$style-name]/type">
				<xsl:value-of select="$config-doc/config/split/section/wordstyle[@select=$style-name]/type" />
			</xsl:when>
      <xsl:when test="$config-doc/config/split/section/splitstyle[@select=$style-name]/type">
        <xsl:value-of select="$config-doc/config/split/section/splitstyle[@select=$style-name]/type" />
      </xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="''" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Returns the inline label from style name.

  @param style-name the current word style name

  @return inline label value
  -->
	<xsl:function name="fn:get-inline-label-from-psml-element" as="xs:string">
		<xsl:param name="style-name" />
    <xsl:choose>
      <xsl:when test="$config-doc/config/styles/wordstyle[@name=$style-name][@psmlelement='inline']/label/@value">
        <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name][@psmlelement='inline']/label/@value" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''" />
      </xsl:otherwise>
    </xsl:choose>
<!-- 		<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name][@psmlelement='inline']/label/@value" /> -->
	</xsl:function>
  
  <!--
  Returns the block label from style name.

  @param style-name the current word style name

  @return block label value
  -->
	<xsl:function name="fn:get-block-label-from-psml-element" as="xs:string">
		<xsl:param name="style-name" />
		<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name][@psmlelement='block']/label/@value" />
	</xsl:function>
  
  <!--
  Returns the indent value from style name.

  @param style-name the current word style name

  @return indent value value
  -->
	<xsl:function name="fn:get-para-indent-value" as="xs:string">
		<xsl:param name="style-name" />
		<xsl:choose>
			<xsl:when test="$config-doc/config/styles/wordstyle[@name=$style-name]/indent/@level">
				<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/indent/@level" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="''" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
  <!--
  Returns the word caption element style for a specific table style value.

  @param style-name the current word style name

  @return  word caption element style
  -->
	<xsl:function name="fn:get-caption-table-value" as="xs:string">
    <xsl:param name="style-name" />
    <xsl:choose>
      <xsl:when test="$config-doc/config/styles/wordstyle[@name=$style-name]/@table">
        <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/@table" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--
  Returns the psml element for a specific style value.

  @param style-name the current word style name

  @return psml element
  -->
	<xsl:function name="fn:get-psml-element" as="xs:string">
		<xsl:param name="style-name" />
		<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/@psmlelement" />
	</xsl:function>
  
  <!--
  Returns the psml element for a specific paragraph node.

  @param paragraph the current paragraph node

  @return psml element
  -->
  <xsl:function name="fn:get-psml-element-from-paragraph" as="xs:string">
    <xsl:param name="paragraph" />
    <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$paragraph/w:pPr/w:pStyle/@w:val]/@psmlelement" />
  </xsl:function>
  
  <!--
  Returns the block label for a specific style name. For headings only

  @param style-name the current word style name

  @return psml block label
  -->
	<xsl:function name="fn:get-heading-block-label" as="xs:string">
		<xsl:param name="style-name" />
		<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/label[@type='block']/@value" />
	</xsl:function>
  
  <!--
  Returns the inline label for a specific style name. For headings only

  @param style-name the current word style name

  @return psml inline label
  -->
	<xsl:function name="fn:get-heading-inline-label" as="xs:string">
		<xsl:param name="style-name" />
		<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/label[@type='inline']/@value" />
	</xsl:function>
  
  <!--
  Returns the heading level for a specific style name.

  @param style-name the current word style name
  @param document-level the current document level

  @return psml heading level
  -->
	<xsl:function name="fn:get-heading-level" as="xs:string">
		<xsl:param name="style-name" />
    <xsl:param name="document-level" />
<!--     <xsl:message select="$document-level"/> -->
    <xsl:choose>
      <xsl:when test="$document-level != '0'">
        <xsl:value-of select="if(number($config-doc/config/styles/wordstyle[@name=$style-name]/level/@value) - number($document-level) &gt; 0) then ($config-doc/config/styles/wordstyle[@name=$style-name]/level/@value - number($document-level)) else $config-doc/config/styles/wordstyle[@name=$style-name]/level/@value" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/level/@value" />
      </xsl:otherwise>
    </xsl:choose>
	</xsl:function>
  
  <!--
  Returns the block label for a specific style name. para elements only

  @param style-name the current word style name

  @return psml block label
  -->
	<xsl:function name="fn:get-para-block-label" as="xs:string">
		<xsl:param name="style-name" />
		<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/label[@type='block']/@value" />
	</xsl:function>
  
  <!--
  Returns the inline label for a specific style name. para elements only

  @param style-name the current word style name

  @return psml inline label
  -->
	<xsl:function name="fn:get-para-inline-label" as="xs:string">
		<xsl:param name="style-name" />
		<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/label[@type='inline']/@value" />
	</xsl:function>
  
  <!--
  Returns the indent level for a specific style name. para elements only

  @param style-name the current word style name

  @return psml indent level
  -->
	<xsl:function name="fn:get-para-indent" as="xs:string">
		<xsl:param name="style-name" />
		<xsl:value-of select="$config-doc/config/styles/wordstyle[@name=$style-name]/indent/@value" />
	</xsl:function>
  
  <!--
  Checks if the current style name has a word numbering format

  @param style-name the current word style name
  @param current the current node

  @return exitance of word numbering format
  -->
	<xsl:function name="fn:has-numbering-format" as="xs:boolean">
		<xsl:param name="style-name" />
		<xsl:param name="current" />
		<xsl:choose>
			<xsl:when test="matches($style-name,$numbering-paragraphs-list-string)">

				<xsl:variable name="currentNumId">
					<xsl:value-of select="fn:get-numid-from-style($current)" />
				</xsl:variable>
				<xsl:variable name="currentAbstractNumId">
					<xsl:value-of select="fn:get-abstract-num-id-from-num-id($currentNumId)" />
				</xsl:variable>
				<xsl:variable name="currentLevel">
					<xsl:value-of select="fn:get-level-from-element($current)" />
				</xsl:variable>
<!--          <xsl:message><xsl:value-of select="$currentNumId" />::<xsl:value-of select="$currentLevel" /></xsl:message> -->
				<xsl:choose>
					<xsl:when test="$numbering-document/w:numbering/w:abstractNum[@w:abstractNumId=$currentAbstractNumId]/w:lvl[@w:ilvl=$currentLevel]/w:numFmt/@w:val='bullet'">
<!--              <xsl:message>1</xsl:message> -->
						<xsl:value-of select="false()" />
					</xsl:when>
					<xsl:otherwise>
<!--              <xsl:message>2</xsl:message> -->
						<xsl:value-of select="true()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
<!--          <xsl:message>3</xsl:message> -->
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
  
  <!--
  Checks if the the convert numbered paragraphs is set in configuration

  @return true or false
  -->
	<xsl:variable name="convert-to-numbered-paragraphs" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$config-doc/config/lists/convert-to-numbered-paragraphs[@select='true']">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!--
  Checks if the split fragments is set in configuration

  @return true or false
  -->
	<xsl:variable name="split-by-sections" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$config-doc/config/split/section[@select='true']">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!--
  Checks if the generate real titles for file names is set in configuration

  @return true or false
  -->
	<xsl:variable name="generate-titles" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$config-doc/config/split/document[@use-real-titles='true']">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!--
  Checks if the split documents is set in configuration

  @return true or false
  -->
  <xsl:variable name="split-by-documents" as="xs:boolean">
    <xsl:choose>
      <xsl:when test="$config-doc/config/split/document[@select='true']">
        <xsl:value-of select="true()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!--
  Checks if the number documents is set in configuration

  @return true or false
  -->
	<xsl:variable name="number-document-title" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$config-doc/config/lists/add-numbering-to-document-titles[@select='true']">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!--
  Checks if the convert list styles into list roles is set in configuration

  @return true or false
  -->
	<xsl:variable name="convert-to-list-roles" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$config-doc/config/lists/convert-to-list-roles[@select='true']">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!--
  Checks if the transform smart tags into inline elements is set in configuration

  @return true or false
  -->
	<xsl:variable name="keep-smart-tags" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$config-doc/config/styles/default/smart-tag/@keep = 'true'">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!--
  Checks if the convert manual numbers into numbering in pageseeder is set in configuration

  @return true or false
  -->
	<xsl:variable name="convert-manual-numbering" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="$config-doc/config/lists/convert-manual-numbering[@select='true']">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
  
  <!--
  Path for the media folder

  @return media folder path
  -->
	<xsl:variable name="media-folder-name" as="xs:string"> 
		<xsl:choose>
			<xsl:when test="$_mediafoldername = ''">
				<xsl:value-of select="iri-to-uri(concat($_docxfilename,'_files'))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="iri-to-uri($_mediafoldername)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
</xsl:stylesheet>