<?xml version="1.0"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:o="urn:schemas-microsoft-com:office:office"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
  xmlns:v="urn:schemas-microsoft-com:vml"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:w10="urn:schemas-microsoft-com:office:word"
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
  xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:rs="http://schemas.openxmlformats.org/package/2006/relationships"
  xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:f="http://www.pageseeder.com/function"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all">


  <xsl:output encoding="UTF-8" method="xml" indent="no" />

    
 <xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="w:style">
  <xsl:variable name="basedon" select="if(w:basedOn/@w:val) then w:basedOn/@w:val else ''"/>
  <w:style>
     <xsl:apply-templates select="@*"/>
  <xsl:choose>
    <xsl:when test="$basedon != ''">
      <xsl:variable name="basedOnNode" select="//w:style[@w:styleId= $basedon][1]" as="node()"/>
      <xsl:call-template name="generate-unnested-styles">
        <xsl:with-param name="basedOnNode" select="$basedOnNode"/>
        <xsl:with-param name="currentNode" select="current()"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
  </w:style>
</xsl:template>

<xsl:template name="generate-unnested-styles">
  <xsl:param name="basedOnNode"/>
  <xsl:param name="currentNode"/>
  
  <xsl:variable name="basedon" select="if($basedOnNode/w:basedOn/@w:val) then $basedOnNode/w:basedOn/@w:val else ''"/>
  
  <xsl:variable name="runPropertyMatch">
     <xsl:for-each select="$currentNode/*">
       <xsl:choose>
        <xsl:when test="./name() = 'w:basedOn'">
         </xsl:when>
         <xsl:when test="position() = last()">
           <xsl:value-of select="concat('^',./name(),'$')" />
         </xsl:when>
         <xsl:otherwise>
           <xsl:value-of select="concat('^',./name(),'$','|')" />
         </xsl:otherwise>
       </xsl:choose>
      </xsl:for-each>
   </xsl:variable>
<!--    <xsl:message select="$runPropertyMatch"></xsl:message>              -->
  <xsl:choose>
    <xsl:when test="$basedon != ''">
      <xsl:variable name="basedOnNode2" select="//w:style[@w:styleId= $basedon][1]" as="node()"/>
      <xsl:call-template name="generate-unnested-styles">
        <xsl:with-param name="basedOnNode" select="$basedOnNode2"/>
        <xsl:with-param name="currentNode" select="$basedOnNode"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="$basedOnNode/*">
        <xsl:variable name="elementName" select="./name()"/>
        <xsl:choose>
          <xsl:when test="not(matches($elementName,$runPropertyMatch)) and not(matches($elementName,'w:basedOn'))">
            <xsl:apply-templates select="."/>
          </xsl:when>
          <xsl:when test="matches($elementName,$runPropertyMatch) and $currentNode/*[name() = $elementName][@val='0']">
<!--             <xsl:copy-of select="."/> -->
          </xsl:when>
          <xsl:otherwise>
            <!--  do nothing -->
          </xsl:otherwise>
        </xsl:choose> 
      </xsl:for-each>
    </xsl:otherwise>
  </xsl:choose>
  
  <xsl:apply-templates select="$currentNode/*[not(matches(name(),'w:basedOn'))]"/>
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
    <xsl:value-of select="concat('&lt;',name())"
      disable-output-escaping="yes" />
    <xsl:apply-templates select="@*" mode="encode" />
    <xsl:text>></xsl:text>
    <xsl:apply-templates mode="encode" />
    <xsl:value-of select="concat('&lt;',name(),'>')"
      disable-output-escaping="yes" />
  </xsl:template>
  <xsl:template match="*[not(node())]" mode="encode">
    <xsl:value-of select="concat('&lt;',name())"
      disable-output-escaping="yes" />
    <xsl:apply-templates select="@*" mode="encode" />
    <xsl:text>/></xsl:text>
  </xsl:template>
  <xsl:template match="@*" mode="encode">
    <xsl:value-of select="concat(' ',name(),'=&quot;',.,'&quot;')" />
  </xsl:template>

  <xsl:template match="*[not(text()|*)]" mode="xml">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()" />
    <xsl:apply-templates select="@*" mode="xml" />
    <xsl:text>/&gt;</xsl:text>
  </xsl:template>

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

  <xsl:template match="text()" mode="xml">
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="@*" mode="xml">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()" />
    ="
    <xsl:value-of select="." />
    <xsl:text>"</xsl:text>
  </xsl:template>
  
</xsl:stylesheet>
