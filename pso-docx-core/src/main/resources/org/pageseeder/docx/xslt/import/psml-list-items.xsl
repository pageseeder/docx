<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to handle list items.

  @author Adriano Akaishi

  @version 0.0.1
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!--
  Match styles that are configured to transform into a PSML list items.
-->

  <!-- Variable name defined to levels 1 to 5 ListBullet name wordstyles -->
  <xsl:variable name="list-level1" select="('ListBullet')" /> 
  <xsl:variable name="list-level2" select="('ListBullet2')" /> 
  <xsl:variable name="list-level3" select="('ListBullet3')" /> 
  <xsl:variable name="list-level4" select="('ListBullet4')" /> 
  <xsl:variable name="list-level5" select="('ListBullet5')" /> 
  <!-- Variable name defined to levels 1 to 5 ListContinue name wordstyles -->
  <xsl:variable name="list-continue-level1" select="('ListContinue')" /> 
  <xsl:variable name="list-continue-level2" select="('ListContinue2')" /> 
  <xsl:variable name="list-continue-level3" select="('ListContinue3')" /> 
  <xsl:variable name="list-continue-level4" select="('ListContinue4')" /> 
  <xsl:variable name="list-continue-level5" select="('ListContinue5')" /> 

  <xsl:variable name="all-lists" select="($list-level1,$list-level2,$list-level3,$list-level4,$list-level5)" /> 
  <xsl:variable name="all-lists-continue" select="($list-continue-level1,$list-continue-level2,$list-continue-level3,$list-continue-level4,$list-continue-level5)" />
  <xsl:variable name="all-lists-complete" select="($all-lists, $all-lists-continue)" />
  
  <!-- Starts analysis to catch all first level to starts the list -->
  <xsl:template match="w:p[w:pPr/w:pStyle/@w:val = $all-lists and (preceding-sibling::*[1][not(name()='w:p') or not(w:pPr/w:pStyle/@w:val = $all-lists-complete)] or count(preceding-sibling::*) = 0)]" mode="content">
    <xsl:apply-templates select="." mode="create-list"/> 
  </xsl:template>
  
  <!-- Block all contents for each levels -->
  <xsl:template match="w:p[w:pPr/w:pStyle/@w:val = $all-lists and preceding-sibling::*[1][name()='w:p' and w:pPr/w:pStyle/@w:val = $all-lists-complete]]" mode="content"/>
  
  <!-- Starts creating a list -->  
  <xsl:template match="w:p" mode="create-list">
    <list>
       <xsl:apply-templates select="." mode="create-item-list"/>  
       <xsl:variable name="current-style-name" select="w:pPr/w:pStyle/@w:val"/>
       <xsl:variable name="upper-level-style-name" select="fn:get-list-next-upper-style($current-style-name)"/>     
       <xsl:variable name="next-non-list" select="following-sibling::*[not(w:pPr/w:pStyle[@w:val = $all-lists-complete])][1]"/>
       <xsl:variable name="next-id" select="if ($next-non-list) then generate-id($next-non-list) else ''"/>
       <xsl:variable name="next-upper-level" select="following-sibling::w:p[w:pPr/w:pStyle/@w:val = $upper-level-style-name and ($next-id = '' or following-sibling::*[generate-id(.) = $next-id])][1]"/>
       <xsl:variable name="edge-id" select="if ($next-upper-level) then generate-id($next-upper-level) else $next-id"/>
       <xsl:for-each select="following-sibling::w:p[w:pPr/w:pStyle/@w:val = $current-style-name and ($edge-id = '' or following-sibling::*[generate-id(.) = $edge-id])]">
         <xsl:apply-templates select="." mode="create-item-list"/> 
       </xsl:for-each>  
     </list>
  </xsl:template>
  
  <!-- Starts creating a item lists and verify the next levels. -->
  <xsl:template match="w:p" mode="create-item-list">
    <item>
      <xsl:variable name="current-item" select="." />
      <xsl:variable name="current-id" select="generate-id($current-item)" />
      <xsl:variable name="current-item-style"  select="$current-item/w:pPr/w:pStyle/@w:val"/>
      <xsl:variable name="continue-style"  select="fn:get-list-continue-style($current-item-style)"/>
      <xsl:variable name="sublevel-style"  select="fn:get-list-next-lower-style($current-item-style)"/>

      <!-- Get all indents of this level (current item level) which has the current item as the first preceding (logical Parent) -->
      <xsl:variable name="continue-list" select="following-sibling::*[w:pPr/w:pStyle/@w:val = $continue-style and generate-id(preceding-sibling::w:p[w:pPr/w:pStyle/@w:val = $current-item-style][1]) = $current-id]"/>

      <xsl:apply-templates select="$current-item/node()"/>
      <xsl:choose>
        <xsl:when test="$continue-list">
          <xsl:for-each select="$continue-list">
            <para><xsl:apply-templates select="."/></para>
            <xsl:apply-templates select="following-sibling::*[1][name()='w:p' and w:pPr/w:pStyle/@w:val = $sublevel-style]" mode="create-list"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <!-- empty continue -->
          <xsl:apply-templates select="$current-item/following-sibling::*[1][name()='w:p' and w:pPr/w:pStyle/@w:val = $sublevel-style]" mode="create-list"/>
        </xsl:otherwise>
      </xsl:choose>   
    </item>
  </xsl:template>
</xsl:stylesheet>