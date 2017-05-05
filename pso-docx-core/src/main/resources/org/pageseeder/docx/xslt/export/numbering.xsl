<?xml version="1.0"?>
<!--
    This xslt creates numbering.xml
    @cvsid $Id: numbering.xsl,v 1.1 2010/04/13 04:30:09 yfeng Exp $ 
    @author Christine Feng 
-->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
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
	xmlns:fn="http://www.pageseeder.com/function" xmlns:dec="java:java.net.URLDecoder"
	exclude-result-prefixes="#all">


<!-- matches root of the numbering.xml from the template -->
	<xsl:template match="/" mode="numbering">
		<xsl:apply-templates mode="numbering" />
	</xsl:template>

<!-- copies numebring definitions from numbering.xml and crestes new numebring definitions according to the existing lists in the pageeeder document -->
	<xsl:template match="w:numbering" mode="numbering">
		<xsl:variable name="max-abstract-num"
			select="max(w:abstractNum/number(@w:abstractNumId))" />
		<xsl:variable name="max-num" select="max(w:num/number(@w:numId))" />
<!-- 	  <xsl:variable name="nlistconfig" select="$config-doc/config/lists/nlist" as="element()"/> -->
<!-- 	  <xsl:variable name="listconfig" select="$config-doc/config/lists/list" as="element()"/> -->
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:comment><xsl:apply-templates select="$all-different-lists" mode="xml"/></xsl:comment>
			 <xsl:apply-templates select="*[name() = 'w:abstractNum']"
        mode="numbering" />
<!--         <xsl:message><xsl:apply-templates select="$all-type-lists/*" mode="xml"/></xsl:message> -->
<!--         <xsl:comment><xsl:apply-templates select="$all-type-lists/*" mode="xml"/></xsl:comment> -->
        <xsl:copy-of select="$all-type-lists/*"/>
      
        <xsl:apply-templates select="*[name() = 'w:num']"
        mode="numbering" />
        <xsl:variable name="max-num-id"
          select="max(//w:num/number(@w:numId))" />
		    <xsl:variable name="max-abstract-num"
		      select="max(//w:abstractNum/number(@w:abstractNumId))" />
		       <xsl:for-each select="$all-different-lists/*[@list-type-select = '']">
		         <xsl:variable name="start-number" select="if (@start != '') then @start else '1'"/>
		         <w:num w:numId="{$max-num-id + position()}">
		           <w:abstractNumId w:val="{if (. != '') then . else 1}" />
		           <xsl:variable name="current-level" select="@level"/>
		           <xsl:variable name="levels" select="'0,1,2,3,4,5,6,7,8'"/>
		           <xsl:for-each select="tokenize($levels, ',')">
		            <xsl:choose>
		            <xsl:when test=". = $current-level">
		              <w:lvlOverride w:ilvl="{.}">
		                <w:startOverride w:val="{$start-number}"/>
		              </w:lvlOverride>
		            </xsl:when>
		            <xsl:otherwise>
		              <w:lvlOverride w:ilvl="{.}">
		                <w:startOverride w:val="1"/>
		              </w:lvlOverride>
		            </xsl:otherwise>
		           </xsl:choose>
		           </xsl:for-each>
		         </w:num>
		       </xsl:for-each>
           
           <xsl:for-each select="$all-different-lists/*[@list-type-select != '']">
             <xsl:variable name="start-number" select="if (@start != '') then @start else '1'"/>
             <w:num w:numId="{$max-num-id + count($all-different-lists/*[@list-type-select = false()]) + position()}">
               <w:abstractNumId w:val="{if (. != '') then . else 1}" />
               <xsl:variable name="current-level" select="@level"/>
               <xsl:variable name="levels" select="'0,1,2,3,4,5,6,7,8'"/>
               <xsl:for-each select="tokenize($levels, ',')">
                <xsl:choose>
                <xsl:when test=". = $current-level">
                  <w:lvlOverride w:ilvl="{.}">
                    <w:startOverride w:val="{$start-number}"/>
                  </w:lvlOverride>
                </xsl:when>
                <xsl:otherwise>
                  <w:lvlOverride w:ilvl="{.}">
                    <w:startOverride w:val="1"/>
                  </w:lvlOverride>
                </xsl:otherwise>
               </xsl:choose>
               </xsl:for-each>
             </w:num>
           </xsl:for-each>
		       
<!-- 		    </xsl:copy> -->
    
    
   
<!-- 			<xsl:for-each select="$all-lists/*"> -->
<!-- 				<xsl:choose> -->
<!-- 				  <xsl:when test="./name() = 'list'"> -->
<!--             <w:abstractNum> -->
<!--               <xsl:attribute name="w:abstractNumId"> -->
<!--                   <xsl:value-of select="$max-abstract-num + position()" /> -->
<!--                 </xsl:attribute> -->
<!--               <w:multiLevelType w:val="hybridMultilevel" /> -->
<!--               <xsl:for-each select="$listconfig/level"> -->
<!--                 <xsl:call-template name="createLvl"> -->
<!--                   <xsl:with-param name="level" select="@value" /> -->
<!--                   <xsl:with-param name="left-indent" select="left-indent/@value" /> -->
<!--                   <xsl:with-param name="right-indent" select="right-indent/@value" /> -->
<!--                   <xsl:with-param name="hanging" select="hanging/@value" /> -->
<!--                   <xsl:with-param name="format" select="format/@value" /> -->
<!--                   <xsl:with-param name="start" select="start/@value" /> -->
<!--                   <xsl:with-param name="paragraph-style" -->
<!--                     select="if (paragraph-style/@select = 'true') then paragraph-style/@value else ''" /> -->
<!--                   <xsl:with-param name="justification" select="justification/@value" /> -->
<!--                   <xsl:with-param name="level-text" select="level-text/@value" /> -->
<!--                 </xsl:call-template> -->
<!--               </xsl:for-each> -->
<!--             </w:abstractNum> -->
<!--           </xsl:when> -->
<!--           <xsl:when test="./name() = 'nlist'"> -->
<!--             <w:abstractNum> -->
<!--               <xsl:attribute name="w:abstractNumId"> -->
<!--                   <xsl:value-of select="$max-abstract-num + position()" /> -->
<!--                 </xsl:attribute> -->
<!--               <w:multiLevelType w:val="hybridMultilevel" /> -->
<!--               <xsl:for-each select="$nlistconfig/level"> -->
<!--                 <xsl:call-template name="createLvl"> -->
<!--                   <xsl:with-param name="level" select="@value" /> -->
<!--                   <xsl:with-param name="left-indent" select="left-indent/@value" /> -->
<!--                   <xsl:with-param name="right-indent" select="right-indent/@value" /> -->
<!--                   <xsl:with-param name="hanging" select="hanging/@value" /> -->
<!--                   <xsl:with-param name="format" select="format/@value" /> -->
<!--                   <xsl:with-param name="start" select="start/@value" /> -->
<!--                   <xsl:with-param name="paragraph-style" -->
<!--                     select="if (paragraph-style/@select = 'true') then paragraph-style/@value else ''" /> -->
<!--                   <xsl:with-param name="justification" select="justification/@value" /> -->
<!--                   <xsl:with-param name="level-text" select="level-text/@value" /> -->
<!--                 </xsl:call-template> -->
<!--               </xsl:for-each> -->
<!--             </w:abstractNum> -->
<!--           </xsl:when> -->

<!-- 					<xsl:otherwise> -->
<!-- 					</xsl:otherwise> -->
<!-- 				</xsl:choose> -->
<!-- 			</xsl:for-each> -->
			
      
<!-- 	     <xsl:for-each select="$all-lists/*"> -->
<!-- 	       <w:num w:numId="{$max-abstract-num + position() + 1}"> -->
<!-- 	         <w:abstractNumId w:val="{$max-abstract-num + position()}" /> -->
<!-- 	       </w:num> -->
<!-- 	     </xsl:for-each> -->
		</xsl:copy>

	</xsl:template>

<!-- creats a level definition according to the configuration document -->
	<xsl:template name="createLvl">
		<xsl:param name="level" />
		<xsl:param name="left-indent" />
		<xsl:param name="right-indent" />
		<xsl:param name="hanging" />
		<xsl:param name="format" />
		<xsl:param name="start" />
		<xsl:param name="paragraph-style" />
		<xsl:param name="justification" />
		<xsl:param name="level-text" />

		<w:lvl w:ilvl="{$level - 1}">
			<w:start w:val="{$start}" />
			<w:numFmt w:val="{$format}" />
			<w:lvlText w:val="{$level-text}" />
			<w:lvlJc w:val="{$justification}" />
			<xsl:if test="$paragraph-style != ''">
				<w:pStyle w:val="{$paragraph-style}" />
			</xsl:if>
			<w:pPr>
				<w:ind w:hanging="{$hanging}">
					<xsl:if test="$left-indent != ''">
						<xsl:attribute name="w:left" select="$left-indent" />
					</xsl:if>
					<xsl:if test="$right-indent != ''">
						<xsl:attribute name="w:right" select="$right-indent" />
					</xsl:if>
				</w:ind>
			</w:pPr>
		</w:lvl>
	</xsl:template>

<!-- Copy each numbering node recursively -->
	<xsl:template match="@*|node()" mode="numbering">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="styles" />
			<xsl:apply-templates mode="styles" />
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
