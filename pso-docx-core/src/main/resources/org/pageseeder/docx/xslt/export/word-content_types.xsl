<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to create the `content_types.xml` DOCX file

  @author Christine Feng
  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio

  @version 0.6.0
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcterms="http://purl.org/dc/terms/" dcterms:W3CDTF="http://purl.org/dc/terms/W3CDTF"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:ct="http://schemas.openxmlformats.org/package/2006/content-types"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!-- 
  Template to handle creation of content_types.xml file from Template and input document
-->
<xsl:template match="/" mode="content-types">
  <xsl:param name="current-document" />
  <xsl:variable name="current-default-extension" select="upper-case(fn:items-to-regex(*[name() = 'Types']/*[name() = 'Default']/@Extension))"/>
  <xsl:for-each select="*">
    <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
      <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml" />
      <xsl:if test="config:generate-comments()">
        <Override PartName="/word/comments.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.comments+xml" />
      </xsl:if>
      <xsl:for-each select="*">
        <xsl:if test=".[name() = 'Default']">
          <xsl:copy-of select="." />
        </xsl:if>
        <xsl:if test=".[name() = 'Override'][@PartName != '/word/document.xml'][@PartName != '/word/comments.xml']">
          <xsl:copy-of select="." />
        </xsl:if>
      </xsl:for-each>
      <!-- TODO: Extension should probably look for last '.' -->
      <xsl:for-each select="distinct-values($current-document//image/upper-case(substring-after(@src, '.')))">
        <xsl:if test="not(matches(., $current-default-extension))">
          <Default ContentType="{concat('image/', .)}" Extension="{.}" />
        </xsl:if>
      </xsl:for-each>
    </Types>
  </xsl:for-each>
</xsl:template>

<!-- 
  Template to handle creation of files referenced by `content_types.xml` file
-->
<xsl:template name="create-documents">
  <xsl:variable name="document-date" select="document/@date" />

  <!-- Process the `[Content_Types].xml` file -->
  <xsl:result-document href="{concat($_outputfolder, encode-for-uri('[Content_Types].xml'))}">
    <xsl:apply-templates select="document($_content-types-template)" mode="content-types">
      <xsl:with-param name="current-document" select="current()" />
    </xsl:apply-templates>
  </xsl:result-document>

  <!-- Copy the `.rels` file verbatim -->
  <xsl:result-document href="{concat($_outputfolder,'/_rels/.rels')}">
    <xsl:apply-templates select="document(concat($_dotxfolder,'/_rels/.rels'))" mode="copy" />
  </xsl:result-document>

  <xsl:for-each select="document($_content-types-template)/ct:Types/ct:Override">
    <xsl:choose>
      <xsl:when test="matches(@PartName,'(/word/document.xml|/word/numbering.xml|/word/styles.xml|/word/comments.xml|/word/footnotes.xml|/word/endnotes.xml|word/_rels/comments.xml.rels)')">
      </xsl:when>
      <xsl:when test="matches(@PartName,'/docProps/core.xml')">
        <xsl:result-document href="{concat($_outputfolder,@PartName)}">
          <cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
                             xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/"
                             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <xsl:choose>
              <xsl:when test="$manual-core = 'Template'">
                <xsl:for-each select="document(concat($_dotxfolder,'/docProps/core.xml'))/cp:coreProperties/*">
                  <xsl:copy-of select="." />
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="config:creator() != ''">
                  <dc:creator>
                    <xsl:value-of select="config:ps-token(config:creator())" />
                  </dc:creator>
                </xsl:if>
                <xsl:variable name="description" select="config:ps-token(config:description())" />
                <xsl:choose>
                  <xsl:when test="$description != ''">
                    <dc:description>
                      <xsl:value-of select="$description" />
                    </dc:description>
                  </xsl:when>
                  <xsl:otherwise>
                    <dc:description>Document generated by PageSeeder.</dc:description>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="config:keywords() != ''">
                  <cp:keywords>
                    <xsl:value-of select="config:ps-token(config:keywords())" />
                  </cp:keywords>
                </xsl:if>
                <xsl:if test="config:revision() != ''">
                  <cp:revision>
                    <xsl:value-of select="config:ps-token(config:revision())" />
                  </cp:revision>
                </xsl:if>
                <xsl:if test="config:subject() != ''">
                  <dc:subject>
                    <xsl:value-of select="config:ps-token(config:subject())" />
                  </dc:subject>
                </xsl:if>
                <xsl:if test="config:title() != ''">
                  <dc:title>
                    <xsl:value-of select="config:ps-token(config:title())" />
                  </dc:title>
                </xsl:if>
                <xsl:if test="config:category() != ''">
                  <cp:category>
                    <xsl:value-of select="config:ps-token(config:category())" />
                  </cp:category>
                </xsl:if>
                <xsl:if test="config:version() != ''">
                  <cp:version>
                    <xsl:value-of select="config:ps-token(config:version())" />
                  </cp:version>
                </xsl:if>
                <xsl:if test="config:created() != ''">
                  <dcterms:created xsi:type="dcterms:W3CDTF">
                    <xsl:choose>
                      <!-- for backward compatibility only -->
                      <xsl:when test="$manual-created = 'Pageseeder Document Creation Date'">
                        <xsl:value-of select="$root-uri/@created" />
                      </xsl:when>
                      <!-- for backward compatibility only -->
                      <xsl:when test="$manual-created = 'Current Date'">
                        <xsl:value-of select="fn:get-current-date()" />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="config:ps-token(config:created())" />
                      </xsl:otherwise>
                    </xsl:choose>
                  </dcterms:created>
                </xsl:if>
                <xsl:if test="config:modified() != ''">
                  <dcterms:modified xsi:type="dcterms:W3CDTF">
                    <xsl:value-of select="config:ps-token(config:modified())" />
                  </dcterms:modified>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </cp:coreProperties>
        </xsl:result-document>
      </xsl:when>
      <xsl:otherwise>
        <xsl:result-document href="{concat($_outputfolder,@PartName)}">
          <xsl:apply-templates select="document(concat($_dotxfolder,encode-for-uri(@PartName)))" mode="copy" />
        </xsl:result-document>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>

  <xsl:if test="doc-available($_document-relationship)">
    <xsl:result-document href="{concat($_outputfolder,'word/_rels/document.xml.rels')}">
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        <xsl:for-each select="document($_document-relationship)//*">
          <xsl:copy-of select=".[name() = 'Relationship'][@Target!='comments.xml']"/>
        </xsl:for-each>
        <xsl:if test="config:generate-comments()">
          <Relationship Id="{concat('rId',(count(document($_document-relationship)//*[name() = 'Relationship']) + 1))}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/comments"
            Target="comments.xml" />
        </xsl:if>

        <!-- TODO Counting blockxrefs to word documents?? -->
        <xsl:variable name="word-documents" select="if($manual-master = 'true') then count(.//blockxref[@mediatype = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']) else 0"/>

        <xsl:if test="$manual-master = 'true'">
          <xsl:for-each select="//blockxref[@mediatype = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']">
            <Relationship Id="{concat('rId',(count(document($_document-relationship)//*[name() = 'Relationship']) + 1 + position()))}"
                          Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/subDocument"
                          Target="{if (config:master-select() = 'uriid') then concat(@uriid,'.docx') else tokenize(@href)[last()]}"
                          TargetMode="External"/>
          </xsl:for-each>
        </xsl:if>
        <xsl:for-each select="//image">
          <Relationship Id="{concat('rId',(count(document($_document-relationship)//*[name() = 'Relationship']) + 1 + $word-documents + position()))}"
                        Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image"
                        Target="{concat('media/',@src)}" />
        </xsl:for-each>
      </Relationships>
    </xsl:result-document>
  </xsl:if>

  <xsl:if test="doc-available(concat($_dotxfolder,'/word/_rels/settings.xml.rels'))">
    <xsl:result-document href="{concat($_outputfolder,'word/_rels/settings.xml.rels')}">
      <xsl:apply-templates select="document(concat($_dotxfolder,'/word/_rels/settings.xml.rels'))" mode="copy" />
    </xsl:result-document>
  </xsl:if>

  <xsl:if test="doc-available(concat($_dotxfolder,$numbering-template)) and $numbering-template != ''">
    <xsl:result-document href="{concat($_outputfolder,'word/numbering.xml')}">
      <xsl:apply-templates select="document(concat($_dotxfolder,$numbering-template))" mode="numbering" />
    </xsl:result-document>
  </xsl:if>

  <xsl:if test="doc-available(concat($_dotxfolder,'/word/footnotes.xml'))">
    <xsl:result-document href="{concat($_outputfolder,'word/footnotes.xml')}">
      <xsl:apply-templates select="document(concat($_dotxfolder,'/word/footnotes.xml'))" mode="footnotes" />
    </xsl:result-document>
  </xsl:if>

  <xsl:if test="doc-available(concat($_dotxfolder,'/word/endnotes.xml'))">
    <xsl:result-document href="{concat($_outputfolder,'word/endnotes.xml')}">
      <xsl:apply-templates select="document(concat($_dotxfolder,'/word/endnotes.xml'))" mode="endnotes" />
    </xsl:result-document>
  </xsl:if>

  <xsl:if test="doc-available(concat($_dotxfolder,'/customXml/item1.xml'))">
    <xsl:result-document href="{concat($_outputfolder,'customXml/item1.xml')}">
      <xsl:apply-templates select="document(concat($_dotxfolder,'/customXml/item1.xml'))" mode="citations" />
    </xsl:result-document>
  </xsl:if>

  <xsl:result-document href="{concat($_outputfolder,'word/styles.xml')}">
    <xsl:apply-templates select="document(concat($_dotxfolder,$styles-template))" mode="styles">
      <xsl:with-param name="inline-labels" select="$inline-labels" as="element()" />
      <xsl:with-param name="block-labels" select="$block-labels" as="element()" />
    </xsl:apply-templates>
  </xsl:result-document>

  <xsl:if test="config:generate-comments()">
    <xsl:result-document href="{concat($_outputfolder,'word/comments.xml')}">
      <w:comments>
        <xsl:for-each select=".//fragment">
          <xsl:variable name="id" select="position()" />
          <xsl:variable name="filename">
            <xsl:value-of select="./ancestor::document[1]/uri/displaytitle" />
          </xsl:variable>
          <w:comment w:id="{$id}" w:initials="PS" w:author="Pageseeder">
            <w:p>
              <w:pPr>
                <w:pStyle w:val="CommentReference" />
              </w:pPr>
              <w:r>
                <w:rPr>
                  <w:rStyle w:val="CommentReference" />
                </w:rPr>
                <w:annotationRef />
                <w:t>
                  <xsl:text>File:</xsl:text>
                  <xsl:value-of select="$filename" />
                </w:t>
                <w:br />
                <w:t>
                  <xsl:text>Fragment:</xsl:text>
                  <xsl:value-of select="@id" />
                </w:t>
                <w:br />
              </w:r>
              <w:hyperlink r:id="{concat('rId',$id)}">
                <w:r>
                  <w:rPr>
                    <w:rStyle w:val="Hyperlink" />
                  </w:rPr>
                  <w:t>
                    <xsl:text>Comment by email</xsl:text>
                  </w:t>
                </w:r>
              </w:hyperlink>
            </w:p>
          </w:comment>
        </xsl:for-each>
      </w:comments>
    </xsl:result-document>

    <xsl:result-document href="{concat($_outputfolder,'word/_rels/comments.xml.rels')}">
      <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        <xsl:for-each select=".//section">
          <xsl:variable name="id" select="position()" />
          <xsl:variable name="document-uri" select="./ancestor::document[1]/@id" />
          <xsl:variable name="document-host" select="./ancestor::document[1]/documentinfo/uri/@host" />
          <xsl:variable name="real-section-id">
            <xsl:variable name="match">
              <xsl:for-each select="ancestor::document">
                <xsl:value-of select="concat(./documentinfo/uri/@id,'-')" />
              </xsl:for-each>
              <xsl:if test="count(ancestor::document) = 0">
                <xsl:text>-</xsl:text>
              </xsl:if>
            </xsl:variable>

            <xsl:analyze-string regex="({$match})" select="./@id">
              <xsl:matching-substring>
              </xsl:matching-substring>
              <xsl:non-matching-substring>
                <xsl:value-of select="." />
              </xsl:non-matching-substring>
            </xsl:analyze-string>
          </xsl:variable>
          <xsl:variable name="mail-to">
            <xsl:value-of select="concat('mailto:',$document-uri,'-',$real-section-id,'@',$document-host)" />
          </xsl:variable>

          <Relationship Id="{concat('rId',$id)}"
                        Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink"
                        Target="{$mail-to}"
                        TargetMode="External" />
        </xsl:for-each>
      </Relationships>
    </xsl:result-document>
  </xsl:if>
</xsl:template>

<!-- Template to copy each node recursively -->
<xsl:template match="* | @*" mode="copy">
  <xsl:copy>
    <xsl:copy-of select="@*" />
    <xsl:apply-templates mode="copy" />
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
