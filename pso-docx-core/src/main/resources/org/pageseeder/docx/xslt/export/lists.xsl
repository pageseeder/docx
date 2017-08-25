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
  xmlns:fn="http://www.pageseeder.com/function" xmlns:dec="java:java.net.URLDecoder" exclude-result-prefixes="#all">
  
  <!--##list##-->
  <!--##nlist##-->
  <!-- 
  matches nlists and lists; the type of lists are handled through the items
   -->
  <xsl:template match="nlist | list" mode="content">
        <!--
            indenting infomation is in numbering.xml and determined by list level
        -->
    <xsl:apply-templates mode="content" />

  </xsl:template>

  <!--##item##-->
  <!-- 
  Matches each item and creates w:p for each ; styles are defined by list role, type or style definition
   -->
  <xsl:template match="item" mode="content">
    <xsl:param name="labels" tunnel="yes"/>
      <!-- level of a list item is the number of ancestor list or nlist-->
    <xsl:variable name="level" select="count(ancestor::list)+count(ancestor::nlist)"/>
    <xsl:variable name="role" select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/@role"/>
    <xsl:variable name="list-type" select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/name()"/>
    
<!--     <xsl:message><xsl:value-of select="$level"/>::<xsl:value-of select="$role"/>::<xsl:value-of select="$list-type"/></xsl:message> -->
    <xsl:choose>
      <xsl:when test="text() or link or bold or italic or sup or sub or xref or inline or image or monospace">
        <w:p>
          <w:pPr>
            <xsl:choose>
              <xsl:when test="parent::*[@role]">
<!--                 <xsl:message>1</xsl:message> -->
                <w:pStyle w:val="{parent::*/@role}"/>
              </xsl:when>
              <xsl:when test="fn:list-wordstyle-for-document-label($labels,$role,$level,$list-type) != ''">
<!--                 <xsl:message>2</xsl:message> -->
                <w:pStyle>
	              <xsl:attribute name="w:val"><xsl:value-of select="fn:list-wordstyle-for-document-label($labels,$role,$level,$list-type)"/></xsl:attribute>
	              </w:pStyle>
	            </xsl:when>
	            <xsl:when test="fn:list-wordstyle-for-default-document($role,$level,$list-type) != ''">
<!-- 	             <xsl:message>3</xsl:message> -->
	              <w:pStyle>
	              <xsl:attribute name="w:val"><xsl:value-of select="fn:list-wordstyle-for-default-document($role,$level,$list-type)"/></xsl:attribute>
	              </w:pStyle>
	            </xsl:when>
              <xsl:otherwise>
<!--                 <xsl:message>4</xsl:message> -->
                <w:pStyle>
                  <xsl:attribute name="w:val"><xsl:value-of select="fn:default-list-wordstyle($level,$list-type)"/></xsl:attribute>
                </w:pStyle>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:variable name="max-num-id">
	            <xsl:choose>
	              <xsl:when test="doc-available(concat($_dotxfolder,$numbering-template))">
	                <xsl:value-of select="max(document(concat($_dotxfolder,$numbering-template))/w:numbering/w:num/number(@w:numId))"/>
	              </xsl:when>
	              <xsl:otherwise><xsl:value-of select="0"/></xsl:otherwise>
	            </xsl:choose>
		        </xsl:variable>
<!-- 		      <xsl:message>precedingsbling:<xsl:value-of select="count(preceding-sibling::item)"/></xsl:message>     -->
<!--           <xsl:if test="count(preceding-sibling::item) = 0"> -->
            <w:numPr>
              <xsl:variable name="level">
                <xsl:choose>
                  <xsl:when test="parent::*[@role]">
                    <xsl:value-of select="fn:get-level-from-role(parent::*/@role,.)"/>
<!--                     <xsl:message><xsl:value-of select="fn:get-level-from-role(parent::*/@role,.)"/></xsl:message> -->
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="count(ancestor::list)+count(ancestor::nlist) - 1"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <w:ilvl w:val="{$level}" />
              <xsl:variable name="current-num-id">
                <xsl:choose>
                  <xsl:when test="parent::*[@role]">
                    <xsl:value-of select="$max-num-id + count(preceding::*[name()='list' or name()='nlist'][@start]) + 1"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$max-num-id + count(ancestor::*[name()='list' or name()='nlist'][last()]/
                                          preceding::*[name()='list' or name()='nlist']
                                          [not(ancestor::list or ancestor::nlist)]) + 1"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
	            <w:numId w:val="{$current-num-id}" />
            </w:numPr>
<!--             </xsl:if> -->
          </w:pPr>
          <xsl:apply-templates select="text() | link | bold | italic | sup | sub | xref | inline | image | monospace"  mode="content"/>
        </w:p>
        <xsl:apply-templates select="list|nlist" mode="content"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates  mode="content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>