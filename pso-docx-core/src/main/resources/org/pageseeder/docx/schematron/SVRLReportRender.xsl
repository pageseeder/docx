<xsl:stylesheet version="2.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
      xmlns:xs="http://www.w3.org/2001/XMLSchema"
      xmlns:ps="http://www.pageseeder.com/editing/2.0" 
      xmlns:svrl="http://purl.oclc.org/dsdl/svrl" 
      xmlns:sch="http://www.ascc.net/xml/schematron"
      xmlns:iso="http://purl.oclc.org/dsdl/schematron" 
      xmlns="http://www.w3.org/1999/xhtml" 
      exclude-result-prefixes="xsl xs ps svrl sch iso">

  <xsl:param name="css" />
  
  <xsl:output encoding="UTF-8" method="xhtml" indent="yes" />

  <xsl:template match="/">
    <html>
      <xsl:comment>no seeding</xsl:comment>
      <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>Validation Report</title>
        <link rel="stylesheet" href="{$css}" type="text/css" />
      </head>
      <body>
        <h1>Validation Report</h1>
        <xsl:for-each select="fileset/file">
          <xsl:apply-templates select="." />
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="file">

    <xsl:choose>
      <xsl:when test="svrl:schematron-output/svrl:failed-assert[contains(.,'FATAL')]">
        <h3 class="error">Results: The file is <span style="color:red">INVALID</span>. Please see the notes below:</h3>
      </xsl:when>
      <xsl:when test="(count(svrl:schematron-output/svrl:successful-report) + count(svrl:schematron-output/svrl:failed-assert)) != 0">
        <h3 class="warning">Results: The file is valid, but with the following warning(s):</h3>
      </xsl:when>
      <xsl:otherwise>
        <h3 class="ok">Results: The file is valid</h3>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates />

  </xsl:template>

  <!-- 
    Display the schematron output grouping by error message
  -->
  <xsl:template match="svrl:schematron-output">
    <xsl:for-each-group select="svrl:successful-report|svrl:failed-assert" group-by="substring-before(svrl:text,':')">
      <div class="{local-name(.)}">
        <h4><xsl:copy-of select="ps:highlight-style(substring-before(svrl:text,':'))"/></h4>
        <xsl:for-each select="current-group()">
          <xsl:variable name="context" select="substring-after(svrl:text,':')"/>
          <xsl:if test="$context and string-length($context) gt 0">
            <blockquote><xsl:value-of select="$context" /></blockquote> 
          </xsl:if>
        </xsl:for-each>
      </div>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="text()" />

  <xsl:function name="ps:highlight-style">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="starts-with($text, 'Unsupported style ') and contains($text, ' will be')">
        <xsl:text>Unsupported style </xsl:text>
        <u><xsl:value-of select="substring-before(substring-after($text, 'Unsupported style '), ' will be')"/></u>
        <xsl:text> will be</xsl:text>
        <xsl:value-of select="substring-after($text, ' will be')"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>

