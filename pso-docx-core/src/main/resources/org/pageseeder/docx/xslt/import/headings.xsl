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
	xmlns:dcterms="http://purl.org/dc/terms/" 
  xmlns:c="http://schemas.openxmlformats.org/drawingml/2006/chart"
  xmlns:ps="http://www.pageseeder.com/editing/2.0" xmlns:fn="http://www.pageseeder.com/function" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="#all">

<!-- template to match styles that are configured to transform into a heading -->
  <xsl:template match="w:p[matches(fn:get-psml-element(w:pPr/w:pStyle/@w:val),'heading') and not(ancestor::w:tbl)]" mode="content">
    <xsl:param name="document-level" tunnel="yes" />
    <xsl:call-template name="create-heading">
      <xsl:with-param name="style-name" select="w:pPr/w:pStyle/@w:val" />
      <xsl:with-param name="current-num-id" select="fn:get-numid-from-style(.)" />
      <xsl:with-param name="current" select="current()" />
      <xsl:with-param name="full-text" select="fn:get-current-full-text(current())" />
      <xsl:with-param name="has-numbering-format" select="fn:has-numbering-format(w:pPr/w:pStyle/@w:val,current())" />
      <xsl:with-param name="document-level" select="$document-level" />
    </xsl:call-template>
  </xsl:template>
<!-- 
Template to match all paragraphs and ,according to the configuration file:
1. Creates Headings
2. Creates Block labels
3. Creates para elements
4. Creates lists
 -->
	<xsl:template name="create-heading" >
    <xsl:param name="style-name"/>
    <xsl:param name="current-num-id"/>
    <xsl:param name="current"/>
    <xsl:param name="full-text"/>
    <xsl:param name="has-numbering-format"/>
    <xsl:param name="document-level"/>
    
      <!-- when headings not in tables -->
      <!--##heading##-->
<!--         <xsl:message select="$has-numbering-format"/> -->
<!--         <xsl:message select="$numbering-paragraphs-list-string"/> -->
        
				<xsl:choose>
					<xsl:when test="fn:get-heading-block-label($style-name) != ''">
						<block label="{fn:get-heading-block-label($style-name)}">
							<xsl:element name="heading">
								<xsl:attribute name="level" select="fn:get-heading-level($style-name,$document-level)" />
								<xsl:if test="$current/w:pPr/w:numPr/w:numId or matches($style-name,$numbering-paragraphs-list-string)">
<!--                   <xsl:message>has numbering</xsl:message> -->
									<xsl:variable name="currentNumId">
										<xsl:value-of select="fn:get-numid-from-style($current)" />
									</xsl:variable>

									<xsl:variable name="currentLevel">
										<xsl:value-of select="fn:get-level-from-element($current)" />
									</xsl:variable>

									<xsl:variable name="isBullet" as="xs:boolean"
										select="if ($numbering-document/w:numbering/w:abstractNum[@w:abstractNumId=$currentNumId]/w:lvl[@w:ilvl=$currentLevel]/w:numFmt/@w:val='bullet') then true() else false()" />


									<xsl:if test="not($isBullet)">
										<xsl:choose>
											<xsl:when test="fn:get-numbered-heading-value($style-name)='prefix'">
												<xsl:if test="$has-numbering-format">
													<xsl:attribute name="prefix" select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
												</xsl:if>
											</xsl:when>
											<xsl:when test="fn:get-numbered-heading-value($style-name)='numbering'">
												<xsl:attribute name="numbered" select="'true'" />
											</xsl:when>
											<xsl:otherwise>
									     <!-- don't add nothing -->
											</xsl:otherwise>
										</xsl:choose>

									</xsl:if>
								</xsl:if>
                
                <xsl:choose>
                <xsl:when test="fn:get-heading-inline-label($style-name) != ''">
<!--                  <xsl:message select="fn:get-heading-inline-label($style-name)" /> -->
                  <inline label="{fn:get-heading-inline-label($style-name)}">
                    <xsl:if test="fn:get-numbered-heading-value($style-name)='inline' and $list-paragraphs/w:p[@id = $current/@id]">
                      <xsl:if test="$has-numbering-format">
                        <inline label="{fn:get-inline-heading-value($style-name)}">
                          <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                          <xsl:text> </xsl:text>
                        </inline>
                      </xsl:if>
                    </xsl:if>

                    <xsl:if test="fn:get-numbered-heading-value($style-name)='text' and $list-paragraphs/w:p[@id = $current/@id]">
                      <xsl:if test="$has-numbering-format">
                        <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                        <xsl:text> </xsl:text>
                      </xsl:if>
                    </xsl:if>
                    <xsl:apply-templates select="$current/*" mode="content">
                      <xsl:with-param name="in-heading" select="true()" />
                      <xsl:with-param name="full-text" select="$full-text" />
                    </xsl:apply-templates>
                  </inline>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:if test="fn:get-numbered-heading-value($style-name)='inline' and $list-paragraphs/w:p[@id = $current/@id]">
                  <xsl:if test="$has-numbering-format">
                    <inline label="{fn:get-inline-heading-value($style-name)}">
                      <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                      <xsl:text> </xsl:text>
                    </inline>
                  </xsl:if>
                </xsl:if>

                <xsl:if test="fn:get-numbered-heading-value($style-name)='text' and $list-paragraphs/w:p[@id = $current/@id]">
                  <xsl:if test="$has-numbering-format">
                    <xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
                    <xsl:text> </xsl:text>
                  </xsl:if>
                </xsl:if>
                <xsl:apply-templates select="$current/*" mode="content">
                  <xsl:with-param name="in-heading" select="true()" />
                  <xsl:with-param name="full-text" select="$full-text" />
                </xsl:apply-templates>
                </xsl:otherwise>
                </xsl:choose>
								

							</xsl:element>
						</block>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="heading">
              
							<xsl:attribute name="level" select="fn:get-heading-level($style-name,$document-level)" />
<!--               <xsl:message>$style-name::<xsl:value-of select="$style-name"/>;$document-level::<xsl:value-of select="$document-level"/>;config::<xsl:value-of select="number($config-doc/config/styles/wordstyle[@name=$style-name]/level/@value)"/>;</xsl:message> -->
							<xsl:if test="$current/w:pPr/w:numPr/w:numId or matches($style-name,$numbering-paragraphs-list-string)">

								<xsl:variable name="currentNumId">
									<xsl:value-of select="fn:get-numid-from-style($current)" />
								</xsl:variable>
                
                <xsl:variable name="currentAbstractNumId">
                  <xsl:value-of select="fn:get-abstract-num-id-from-num-id($currentNumId)" />
                </xsl:variable>
                
								<xsl:variable name="currentLevel">
									<xsl:value-of select="fn:get-level-from-element($current)" />
								</xsl:variable>

								<xsl:variable name="isBullet" as="xs:boolean"
									select="if ($numbering-document/w:numbering/w:abstractNum[@w:abstractNumId=$currentAbstractNumId]/w:lvl[@w:ilvl=$currentLevel]/w:numFmt/@w:val='bullet') then true() else false()" />


								<xsl:if test="not($isBullet)">
<!-- 								  <xsl:message>not($isBullet)</xsl:message> -->
<!-- 								  <xsl:message>not($isBullet)<xsl:value-of select="fn:get-numbered-heading-value($style-name)"/></xsl:message> -->
<!--                   <xsl:message>not($isBullet)<xsl:value-of select="fn:get-numbered-heading-value($style-name)"/></xsl:message> -->
									<xsl:choose>
										<xsl:when test="fn:get-numbered-heading-value($style-name)='prefix'">
											<xsl:if test="$has-numbering-format">
												<xsl:attribute name="prefix" select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
											</xsl:if>
										</xsl:when>
										<xsl:when test="fn:get-numbered-heading-value($style-name)='numbering'">
											<xsl:attribute name="numbered" select="'true'" />
										</xsl:when>
										<xsl:otherwise>
	                       <!-- don't add nothing -->
										</xsl:otherwise>
									</xsl:choose>

								</xsl:if>
							</xsl:if>


							<xsl:variable name="isNumbered" as="xs:boolean">
								<xsl:choose>
									<xsl:when test="matches($full-text,$numbering-match-list-string) and $convert-manual-numbering">
						<!--           <xsl:message>true</xsl:message> -->
										<xsl:value-of select="true()" />
									</xsl:when>
									<xsl:otherwise>
						<!--           <xsl:message>false</xsl:message> -->
										<xsl:value-of select="false()" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
<!-- 						      <xsl:message><xsl:value-of select="$numbering-match-list-string"/>::<xsl:value-of select="$convert-manual-numbering"/></xsl:message> -->
<!-- 						      <xsl:message><xsl:value-of select="$full-text"/>::<xsl:value-of select="$isNumbered"/></xsl:message> -->
							
							<xsl:if test="$numbering-list-prefix-exists">
							 
								<xsl:analyze-string regex="({$numbering-match-list-prefix-string})(.*)" select="$full-text">
									<xsl:matching-substring>
										<xsl:attribute name="prefix" select="regex-group(1)" />
									</xsl:matching-substring>
								</xsl:analyze-string>
							</xsl:if>

							<xsl:if test="$numbering-list-autonumbering-exists">
								<xsl:analyze-string regex="({$numbering-match-list-autonumbering-string})(.*)" select="$full-text">
									<xsl:matching-substring>
										<xsl:attribute name="numbered" select="'true'" />
									</xsl:matching-substring>
								</xsl:analyze-string>
							</xsl:if>


							<xsl:choose>
								<xsl:when test="fn:get-heading-inline-label($style-name) != ''">
<!-- 									<xsl:message select="fn:get-heading-inline-label($style-name)" /> -->
									<inline label="{fn:get-heading-inline-label($style-name)}">
										<xsl:if test="fn:get-numbered-heading-value($style-name)='inline' and $list-paragraphs/w:p[@id = $current/@id]">
											<xsl:if test="$has-numbering-format">
												<inline label="{fn:get-inline-heading-value($style-name)}">
													<xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
													<xsl:text> </xsl:text>
												</inline>
											</xsl:if>
										</xsl:if>

										<xsl:if test="fn:get-numbered-heading-value($style-name)='text' and $list-paragraphs/w:p[@id = $current/@id]">
											<xsl:if test="$has-numbering-format">
												<xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
												<xsl:text> </xsl:text>
											</xsl:if>
										</xsl:if>
										<xsl:apply-templates select="$current/*" mode="content">
											<xsl:with-param name="in-heading" select="true()" />
											<xsl:with-param name="full-text" select="$full-text" />
										</xsl:apply-templates>
									</inline>
								</xsl:when>
								<xsl:otherwise>
								  
									<xsl:if test="fn:get-numbered-heading-value($style-name)='inline' and $list-paragraphs/w:p[@id = $current/@id]">
									 
										<xsl:if test="$has-numbering-format">
										  
											<inline label="{fn:get-inline-heading-value($style-name)}">
												<xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
												<xsl:text> </xsl:text>
											</inline>
										</xsl:if>
									</xsl:if>

									<xsl:if test="fn:get-numbered-heading-value($style-name)='text' and $list-paragraphs/w:p[@id = $current/@id]">
										<xsl:if test="$has-numbering-format">
											<xsl:value-of select="fn:get-numbering-value-from-paragraph-style($current,$style-name)" />
											<xsl:text> </xsl:text>
										</xsl:if>
									</xsl:if>
									<xsl:apply-templates select="$current/*" mode="content">
										<xsl:with-param name="in-heading" select="true()" />
										<xsl:with-param name="full-text" select="$full-text" />
									</xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
		
	</xsl:template>
  
</xsl:stylesheet>