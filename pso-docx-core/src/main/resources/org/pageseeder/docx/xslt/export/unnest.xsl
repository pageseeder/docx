<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/" xmlns:log="http://www.allette.com.au/log" exclude-result-prefixes="saxon log">
  <xsl:strip-space
    elements="toc uri labels displaytitle properties-fragment root description property section body document documentinfo fragment list xref-fragment blockxref locator notes note content" />
  <xsl:output encoding="UTF-8" method="xml" indent="no" />

  <!-- match root element -->
  <xsl:template match="/">
    <xsl:apply-templates select="element()|text()|comment()|processing-instruction()" />
  </xsl:template>

  <!-- generic copy -->
  <xsl:template match="attribute()|comment()|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="comment()|processing-instruction()" />
    </xsl:copy>
  </xsl:template>

  <!-- generic copy  -->
  <xsl:template match="element()">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <!--unnest items -->
  <xsl:template match="item">
    <item>
      <xsl:for-each-group select="node()"
        group-adjacent="if  (self::bold or self::xref or self::italic 
                        or self::sup or self::sub or self::underline
                        or self::monospace or self::link or self::br or self::inline or self::image or self::text()) 
                      then 2 
                      else 1">
        <xsl:choose>
          <xsl:when test="current-grouping-key()=1">

            <xsl:apply-templates select="current-group()" />

          </xsl:when>
          <xsl:when test="current-grouping-key()=2 and normalize-space(.) = ''">
<!--             <xsl:apply-templates select="current-group()" /> -->
          </xsl:when>
          <xsl:otherwise>
            <para>
              <xsl:apply-templates select="current-group()" />
            </para>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </item>

  </xsl:template>

  <!--unnest cells and hcells  -->
  <xsl:template match="cell|hcell">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:for-each-group select="node()"
        group-adjacent="if  (self::list or self::nlist or self::para or self::item
                          or self::block or self::table or self::blockxref or self::preformat
                          ) 
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

  <!--unnest blocks -->
  <xsl:template match="block">
    <block>
      <xsl:copy-of select="@*" />
      <xsl:for-each-group select="node()"
        group-adjacent="if  (self::list or self::nlist or self::para or self::item
                          or self::block or self::table or self::blockxref  or self::preformat
                          or self::heading 
                          ) 
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

  <!-- check fir breaks in text and handle whitespace-->
  <xsl:template match="text()">
    <xsl:choose>
      <xsl:when test="preceding-sibling::*[1]/name() = 'br' and substring(replace(.,'[\s]+',' '),1,1) = ' '">
        <xsl:value-of select="substring(replace(.,'[\s]+',' '),2,string-length(replace(.,'[\s]+',' ')))" />

      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="replace(.,'[\s]+',' ')" />
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- match test inside of preformat -->
 <xsl:template match="text()[. != '&#10;'][parent::preformat]">
    <xsl:for-each select="tokenize(.,'&#10;')">
      <xsl:sequence select="." />
      <xsl:if test="not(position() eq last())">
        <br />
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
 
<!--  <xsl:template match="para[not(@indent)]"> -->
<!--   <para indent="0"> -->
<!--     <xsl:apply-templates/> -->
<!--   </para> -->
<!--  </xsl:template> -->

</xsl:stylesheet>
