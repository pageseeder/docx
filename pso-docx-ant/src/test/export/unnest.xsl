<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                              xmlns:saxon="http://saxon.sf.net/" 
                              xmlns:log="http://www.allette.com.au/log" 
                              exclude-result-prefixes="saxon log">

  <xsl:output encoding="UTF-8" method="xml" indent="no" />

  <xsl:template match="/">
    <xsl:apply-templates select="element()|text()|comment()|processing-instruction()" />
  </xsl:template>

  <xsl:template match="attribute()|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="comment()|processing-instruction()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="element()">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <!--comment ID: 302792, fixed mixed content in item -->
  <xsl:template match="item">
    <xsl:for-each-group select="node()"
      group-adjacent="if  (self::list or self::nlist or self::para 
                        or self::block or self::table or self::blockxref
                        or self::text()[normalize-space(.) = '']) 
                      then 2 
                      else 1">
      <item>
        <xsl:apply-templates select="current-group()" />
      </item>
    </xsl:for-each-group>
  </xsl:template>

  <!--comment ID: 302792, fixed mixed content in table cell -->
  <xsl:template match="cell|hcell">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:for-each-group select="node()"
        group-adjacent="if  (self::list or self::nlist or self::para 
                          or self::block or self::table or self::blockxref
                          or self::text()[normalize-space(.) = '']) 
                        then 2 
                        else 1">
        <xsl:choose>
          <xsl:when test="current-grouping-key()=1">
            <para>
              <xsl:apply-templates select="current-group()" />
            </para>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <!--comment ID: 302792, fixed mixed content in block -->
  <xsl:template match="block">
    <block>
      <xsl:copy-of select="@*" />
      <xsl:for-each-group select="node()"
        group-adjacent="if  (self::list or self::nlist or self::para
                          or self::block or self::table or self::blockxref 
                          or self::heading 
                          or self::text()[normalize-space(.) = '']) 
                        then 2 
                        else 1">
        <xsl:choose>
          <xsl:when test="current-grouping-key()=1">
            <para>
              <xsl:apply-templates select="current-group()" />
            </para>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="current-group()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </block>
  </xsl:template>

</xsl:stylesheet>
