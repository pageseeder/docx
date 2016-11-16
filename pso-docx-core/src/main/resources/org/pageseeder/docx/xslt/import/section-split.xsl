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
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.pageseeder.com/function"
	xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
  exclude-result-prefixes="#all">

  <!-- 
  Template to split each document as sections according to the definitions in the configuration file
   -->
	<xsl:template match="body" mode="section-split">
    <xsl:param name="document-level" tunnel="yes" />
    <xsl:variable name="current" select="current()"/>
		<xsl:choose>
			<xsl:when test="$split-by-sections">
      <xsl:variable name="is-multi-valued-group" as="xs:boolean">
        <xsl:variable name="group-value">
          <groups>
           <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-section-split-sectionbreak(.) or w:bookmarkEnd[matches(@w:id,$bookmark-end-section-split-regex-ids-string)]]">
                <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-section-split-outline(.) or fn:matches-section-split-styles(.) or fn:matches-section-split-bookmarkstart(.)]|w:p[fn:matches-section-specific-split-styles(.)]">
<!--                   <xsl:for-each-group select="current-group()" group-starting-with="w:p[]"> -->
<!--                     <xsl:variable name="bookmark-id" select="current-group()/w:bookmarkStart/@w:id"/> -->
<!--                     <xsl:for-each-group select="current-group()" group-ending-with="w:p[w:bookmarkEnd[@w:id = $bookmark-id]]">   -->
                      <group value="{count(current-group())}"></group>
<!--                     </xsl:for-each-group> -->
<!--                   </xsl:for-each-group> -->
                </xsl:for-each-group>
           </xsl:for-each-group>
           </groups>
        </xsl:variable>
<!--         <xsl:message> -->
<!--         <xsl:apply-templates select="$group-value" mode="xml"/> -->
<!--       </xsl:message> -->
<!--       <xsl:message select="count($group-value/groups/group)"/> -->
<!--       <xsl:message select="$group-value/groups/group/@value"/> -->
        <xsl:choose>
          <xsl:when test="count($group-value/groups/group) &gt; 1">
            <xsl:value-of select="true()"/>
          </xsl:when>
          <xsl:when test="$group-value/groups/group/@value &gt; 1">
            <xsl:value-of select="true()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="false()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      
			 <section id="title">
          <fragment id="title">
            <xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-section-split-sectionbreak(.) or w:bookmarkEnd[matches(@w:id,$bookmark-end-section-split-regex-ids-string)]]">
                <xsl:variable name="relative-position" select="position()"/>
                <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-section-split-outline(.) or fn:matches-section-split-styles(.) or fn:matches-section-split-bookmarkstart(.)]|w:p[fn:matches-section-specific-split-styles(.)]">
<!--                 <xsl:for-each-group select="current-group()" group-ending-with="w:p[]">   -->
<!--                   <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-section-split-bookmarkstart(.)]"> -->
<!--                       <xsl:message> -->
<!--                         <xsl:apply-templates select="current-group()" mode="xml"/> -->
<!--                       </xsl:message> -->
    	                <xsl:choose>
                        <xsl:when test="position()*$relative-position = 1">
                          <xsl:if test="fn:fragment-type-for-split-style(current-group()//w:pPr[1]/w:pStyle/@w:val[1]) != ''"> 
                             <xsl:attribute name="type" select="fn:fragment-type-for-split-style(current-group()//w:pPr[1]/w:pStyle/@w:val[1])"/>
                            </xsl:if>
                          <xsl:apply-templates select="current-group()[position() = 1]" mode="content" >
                            <xsl:with-param name="document-level" select="$document-level" tunnel="yes" />
                          </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise></xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each-group>
<!--                   </xsl:for-each-group> -->
<!-- 	            </xsl:for-each-group> -->
	          </xsl:for-each-group>
          </fragment>
        </section>
       <xsl:if test="$is-multi-valued-group">
			 <section id="body">
					<xsl:for-each-group select="*" group-ending-with="w:p[fn:matches-section-split-sectionbreak(.) or w:bookmarkEnd[matches(@w:id,$bookmark-end-section-split-regex-ids-string)]]">
              <xsl:variable name="relative-position" select="position()"/>
                <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-section-split-outline(.) or fn:matches-section-split-styles(.) or fn:matches-section-split-bookmarkstart(.)]|w:p[fn:matches-section-specific-split-styles(.)]">
<!--               <xsl:for-each-group select="current-group()" group-starting-with="w:p[fn:matches-section-split-bookmarkstart(.)]"> -->
<!--                     <xsl:variable name="bookmark-id" select="current-group()/w:bookmarkStart/@w:id"/> -->
<!--                     <xsl:for-each-group select="current-group()" group-ending-with="w:p[w:bookmarkEnd[@w:id = $bookmark-id]]">   -->
								<xsl:choose>
                    <xsl:when test="position()*$relative-position != 1">
<!--                       <fragment id="{concat($relative-position,'-',position())}"> -->
                      <xsl:variable name="current-id" select="current-group()/node()[1]/generate-id()"/>
                      <fragment id="{concat($relative-position,'-',position())}">
                        <xsl:if test="fn:fragment-type-for-split-style(current-group()//w:pPr[1]/w:pStyle/@w:val[1]) != ''"> 
                         <xsl:attribute name="type" select="fn:fragment-type-for-split-style(current-group()//w:pPr[1]/w:pStyle/@w:val[1])"/>
                        </xsl:if>
			                  <xsl:apply-templates select="current-group()" mode="content" >
                            <xsl:with-param name="document-level" select="$document-level" tunnel="yes" />
                          </xsl:apply-templates>
			                </fragment>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:if test="current-group()[position() = 2]"> 
                        <xsl:variable name="current-id" select="current-group()/node()[1]/generate-id()"/>
<!--                         <fragment id="{concat($relative-position,'-',position())}">   -->
                       <fragment id="{concat($relative-position,'-',position())}">
                          <xsl:if test="fn:fragment-type-for-split-style(current-group()//w:pPr[1]/w:pStyle/@w:val[1]) != ''"> 
                            <xsl:attribute name="type" select="fn:fragment-type-for-split-style(current-group()//w:pPr[1]/w:pStyle/@w:val[1])"/>
                           </xsl:if>  
                          <xsl:apply-templates select="current-group()[position() != 1]" mode="content" >
                            <xsl:with-param name="document-level" select="$document-level" tunnel="yes" />
                          </xsl:apply-templates>
                        </fragment>
                      </xsl:if>
                      </xsl:otherwise>
                  </xsl:choose>
<!--                     </xsl:for-each-group> -->
                  </xsl:for-each-group>
<!-- 						</xsl:for-each-group> -->
					</xsl:for-each-group>
					</section>
          </xsl:if>
			</xsl:when>
			<xsl:otherwise>
			 <section id="title">
          <fragment id="title">
            <xsl:apply-templates select="*[1]" mode="content" >
                            <xsl:with-param name="document-level" select="$document-level" tunnel="yes" />
                          </xsl:apply-templates>
          </fragment>
          </section>
				<section id="1">
					<fragment id="1">
						<xsl:apply-templates select="*[position() != 1]" mode="content" >
                            <xsl:with-param name="document-level" select="$document-level" tunnel="yes" />
                          </xsl:apply-templates>
					</fragment>
				</section>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>