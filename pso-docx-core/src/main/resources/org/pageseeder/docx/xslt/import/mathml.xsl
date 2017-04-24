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
  xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships" xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.pageseeder.com/function" exclude-result-prefixes="#all">
 

  <!-- apply templates to smart Tags:
  transform them into inline labels or just keep them as text, according to the option set on the configuration document -->
  <xsl:key name="math-checksum-id" match="@checksum-id" use="." />
  
  <!-- TODO -->
  <xsl:template match="w:body" mode="mathml">
    <xsl:for-each select="distinct-values(m:math/@checksum-id)">
      <xsl:variable name="current" select="."/>
          <xsl:result-document href="{concat($_outputfolder,'mathml/',.,'.mml')}">
            <xsl:choose>
              <xsl:when test="$convert-omml-to-mml">
                <xsl:apply-templates select="$list-mathml//m:math[@checksum-id = $current][1]" mode="mml" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="$list-mathml//m:math[@checksum-id = $current][1]" mode="mathml" />
              </xsl:otherwise>
            </xsl:choose>
            
        </xsl:result-document>
    </xsl:for-each>
    
  </xsl:template>
  
   <!-- TODO --> 
  <xsl:template match="m:oMath[not(ancestor::m:oMathPara)][$generate-mathml-files]|m:oMath[ancestor::m:oMathPara and ancestor::w:p][$generate-mathml-files]" mode="content">
    <xsl:variable name="current">
      <xsl:apply-templates select="." mode="xml"/>
    </xsl:variable>
    <xsl:variable name="math-checksum" select="fn:checksum($current)"/>
    <xref display="manual" frag="default" type="none" reverselink="true" reversetitle="" reversetype="none" title="{$math-checksum}">
          <xsl:attribute name="href">
               <xsl:value-of select="concat('mathml/',fn:checksum($current),'.mml')" />
          </xsl:attribute>
          <xsl:value-of select="$math-checksum" />
        </xref>
  </xsl:template>
  
  <!-- Match each pre-processed text run individually -->
  <xsl:template match="m:oMathPara[$generate-mathml-files][not(ancestor::w:p)]" mode="content">
  <xsl:variable name="current">
      <xsl:apply-templates select="." mode="xml"/>
    </xsl:variable>
    <xsl:variable name="math-checksum" select="fn:checksum($current)"/>
    <para>
    <xref display="manual" frag="default" type="none" reverselink="true" reversetitle="" reversetype="none" title="{$math-checksum}">
          <xsl:attribute name="href">
               <xsl:value-of select="concat('mathml/',fn:checksum($current),'.mml')" />
          </xsl:attribute>
          <xsl:value-of select="$math-checksum" />
        </xref>
        </para>
  </xsl:template>

   <!-- TODO -->     
  <xsl:template match="@*|node()" mode="mathml">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="mathml" />
      <xsl:apply-templates mode="mathml" />
    </xsl:copy>
  </xsl:template>
  
<!--   <xsl:function name="fn:checksum" as="xs:integer"> -->
<!--         <xsl:param name="str" as="xs:string"/> -->
<!--         <xsl:variable name="codepoints" select="string-to-codepoints($str)"/> -->
<!--         <xsl:value-of select="fn:fletcher16($codepoints, count($codepoints), 1, 0, 0)"/> -->
<!--     </xsl:function> -->

    <!-- can I change some xs:integers to xs:int and help performance? -->
<!--     <xsl:function name="fn:fletcher16"> -->
<!--         <xsl:param name="str" as="xs:integer*"/> -->
<!--         <xsl:param name="len" as="xs:integer" /> -->
<!--         <xsl:param name="index" as="xs:integer" /> -->
<!--         <xsl:param name="sum1" as="xs:integer" /> -->
<!--         <xsl:param name="sum2" as="xs:integer"/> -->
<!--         <xsl:choose> -->
<!--             <xsl:when test="$index gt $len"> -->
<!--                 <xsl:sequence select="$sum2 * 256 + $sum1"/> -->
<!--             </xsl:when> -->
<!--             <xsl:otherwise> -->
<!--                 <xsl:variable name="newSum1" as="xs:integer" -->
<!--                     select="($sum1 + $str[$index]) mod 255"/> -->
<!--                 <xsl:sequence select="fn:fletcher16($str, $len, $index + 1, $newSum1, -->
<!--                         ($sum2 + $newSum1) mod 255)" /> -->
<!--             </xsl:otherwise> -->
<!--         </xsl:choose> -->
<!--     </xsl:function> -->
</xsl:stylesheet>