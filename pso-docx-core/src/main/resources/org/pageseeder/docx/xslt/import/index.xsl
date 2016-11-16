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
	xmlns:dcterms="http://purl.org/dc/terms/" xmlns:fn="http://www.pageseeder.com/function" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:ps="http://www.pageseeder.com/editing/2.0"
	xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all">
  
  <!-- Ingnore all text for index files by default -->
	<xsl:template match="text()" mode="index-files" />
  
  <!-- handle generation of index files with filedcode text -->
	<xsl:template match="w:instrText[matches(text(),'XE')]" mode="index-files">
		<xsl:variable name="temp-index-location" select="translate(translate(fn:get-index-text(text(),'XE'),'/','_'),':','/')" />
		<xsl:variable name="full-index">
<!-- 		    <xsl:message select="$temp-index-location"></xsl:message> -->
			<xsl:for-each select="tokenize($temp-index-location,'/')">
				<xsl:choose>
					<xsl:when test="position() != last()">
<!-- 		          <xsl:message select="concat(encode-for-uri(.),'/')"></xsl:message> -->
						<xsl:value-of select="concat(encode-for-uri(.),'/')" />
					</xsl:when>
					<xsl:otherwise>
<!-- 		          <xsl:message select="encode-for-uri(.)"></xsl:message> -->
						<xsl:value-of select="encode-for-uri(.)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		  
<!-- 		  <xsl:message select="$full-index"></xsl:message> -->
		<xsl:variable name="document-title">
			<xsl:choose>
				<xsl:when test="contains(fn:get-index-text(text(),'XE'),':')">
					<xsl:value-of select="fn:string-after-last-delimiter(fn:get-index-text(text(),'XE'),':')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="fn:get-index-text(text(),'XE')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="preceding::w:instrText[matches(text(),'XE')]">
				<xsl:if test="not(preceding::w:instrText[matches(text(),'XE')]/translate(translate(fn:get-index-text(text(),'XE'),'/','_'),':','/') = $temp-index-location)">
		        
<!-- 		        <xsl:message>compare: #<xsl:value-of select="text()" />#<xsl:value-of select="fn:get-index-text(text(),'XE')" /></xsl:message> -->
<!-- 		        <xsl:message>with: -->
<!-- 		          <xsl:for-each select="preceding::w:instrText[matches(text(),'XE')]"> -->
<!-- 		            #<xsl:value-of select="translate(fn:get-index-text(text(),'XE'),':','/')" /># -->
<!-- 		          </xsl:for-each> -->
<!-- 		        </xsl:message> -->
					<xsl:result-document href="{concat($_outputfolder,'index/',$full-index,'.psml')}">
						<document level="portable">
							<documentinfo>
								<uri title="{$document-title}">
									<displaytitle>
										<xsl:value-of select="$document-title" />
									</displaytitle>
								</uri>
							</documentinfo>
							<section id="title">
								<fragment id="title">
									<heading level="1">
										<xsl:value-of select="$document-title" />
									</heading>
								</fragment>
							</section>
							

<!-- 								<xsl:for-each select="$list-index-translated/root/element"> -->
<!--                   <section> -->
<!-- 									<xsl:if test="matches(@name,concat('^',$full-index,'$')) and element"> -->
<!-- 										<xref display="manual" frag="default" type="none" reverselink="true" reversetitle="" reversetype="none"> -->
<!-- 											<xsl:attribute name="title"> -->
<!-- 									         <xsl:value-of select="@title" /> -->
<!-- 									    </xsl:attribute> -->
<!-- 											<xsl:attribute name="href"> -->
<!-- 									       <xsl:value-of select="concat('index/',$full-index,'.psml')" /> -->
<!-- 									    </xsl:attribute> -->
<!-- 											<xsl:value-of select="@title" /> -->
<!-- 										</xref> -->
<!-- 									</xsl:if> -->

<!--                   </section> -->
<!-- 								</xsl:for-each> -->


							
						</document>
					</xsl:result-document>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:result-document href="{concat($_outputfolder,'index/',$full-index,'.psml')}">
					<document level="portable">
						<documentinfo>
							<uri title="{$document-title}">
								<displaytitle>
									<xsl:value-of select="$document-title" />
								</displaytitle>
							</uri>
						</documentinfo>
						<section id="title">
							<fragment id="title">
								<heading level="1">
									<xsl:value-of select="$document-title" />
								</heading>
							</fragment>
						</section>
					</document>
				</xsl:result-document>
			</xsl:otherwise>
		</xsl:choose>
		  
<!-- 		<xsl:if test="$generate-index-files"> -->
<!-- 		  <xsl:apply-templates mode="index-files"/> -->
<!-- 		</xsl:if> -->
	</xsl:template>

</xsl:stylesheet>