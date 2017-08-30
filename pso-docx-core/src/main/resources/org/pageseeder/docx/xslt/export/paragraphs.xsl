<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
	xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
	xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
	xmlns:fn="http://www.pageseeder.com/function" xmlns:dec="java:java.net.URLDecoder" exclude-result-prefixes="#all">
  
  
      
  <!--##title##-->
  <!-- Title is imported as normal text, applying the default word heading styles -->
	<xsl:template match="title" mode="content">
		<w:p>
			<w:pPr>
				<xsl:call-template name="apply-style" />
			</w:pPr>
			<xsl:apply-templates mode="content" />
		</w:p>
	</xsl:template>
        
    
  <!--##heading##-->
  <!-- Headings are imported as normal text, applying the default word heading styles -->
	<xsl:template match="heading" mode="content">
		<xsl:param name="labels" tunnel="yes" />
        <!-- Handle headings. Style mapped from element name -->
<!--         <xsl:message><xsl:value-of select="$labels"/></xsl:message> -->
		<w:p>
			<w:pPr>
				<xsl:call-template name="apply-style" />
<!--         <xsl:message> -->
<!--           <xsl:call-template name="apply-style" /> -->
<!--            </xsl:message> -->
        <xsl:choose>
          <xsl:when test="fn:labels-keep-heading-with-next($labels,@level,@numbered)">
            <w:rPr>
              <w:vanish/>
              <w:specVanish/>
            </w:rPr>
          </xsl:when>
          <xsl:when test="fn:default-keep-heading-with-next(@level,@numbered)">
            <w:rPr>
              <w:vanish/>
              <w:specVanish/>
            </w:rPr>
          </xsl:when>
        </xsl:choose>
			</w:pPr>
      <!-- TODO check how prefixes work -->
			<xsl:if test="@prefix">
				<xsl:choose>
					<xsl:when test="fn:heading-prefix-select-for-document-label($labels,@level,@numbered)">
						<xsl:sequence select="fn:heading-prefix-value-for-document-label($labels,@level,current(),@numbered)" />
					</xsl:when>
					<xsl:when test="fn:heading-prefix-select-for-default-document(@level,@numbered)">
						<xsl:sequence select="fn:heading-prefix-value-for-default-document(@level,current(),@numbered)" />
					</xsl:when>
					<xsl:otherwise>
<!-- 						<w:r> -->
<!-- 							<w:t xml:space="preserve"><xsl:value-of select="@prefix" /> </w:t> -->
<!-- 						</w:r> -->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="@numbered = 'true'">
				<xsl:choose>
					<xsl:when test="fn:heading-numbered-select-for-document-label($labels,@level,@numbered)">

						<xsl:sequence select="fn:heading-numbered-value-for-document-label($labels,@level,current(),@numbered)" />
					</xsl:when>
					<xsl:when test="fn:heading-numbered-select-for-default-document(@level,@numbered)">
						<xsl:sequence select="fn:heading-numbered-value-for-default-document(@level,current(),@numbered)" />
					</xsl:when>
					<xsl:otherwise>
<!-- 						<w:r> -->
<!-- 							<w:t xml:space="preserve"><xsl:value-of select="@prefix" /></w:t> -->
<!-- 						</w:r> -->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:apply-templates mode="content" />
		</w:p>
	</xsl:template>

       
  <!--##paraLabel##-->
  <!--  A block is imported as a normal paragraph -->
	<xsl:template match="block" mode="content">
		<xsl:param name="labels" tunnel="yes" />
    <xsl:param name="cell-align" tunnel="yes" />
      <!--
        if paraLabel contains only inline elements or text, create w:p here,
      -->
      <xsl:if test="@label = 'caption'">
<!--      <xsl:message>block</xsl:message> -->
     </xsl:if>
		<xsl:variable name="id" select="concat(@label, '-', generate-id())" />
		<xsl:choose>
        <!-- when containing other block elements, including mixed content -->
        <!-- will not create w:p here -->
			<xsl:when test="matches(@label,fn:block-ignore-labels-with-document-label($labels))">
<!-- 			 <xsl:message>1</xsl:message> -->
			</xsl:when>

			<xsl:when test="matches(@label,fn:default-block-ignore-labels())">
<!-- 			 <xsl:message>2</xsl:message> -->
			</xsl:when>

			<xsl:when test="fn:has-block-elements(.)='true'">
<!-- 			 <xsl:message>3</xsl:message> -->
				<xsl:apply-templates mode="content" />
			</xsl:when>
			<xsl:otherwise>
<!-- 			 <xsl:message>otherwise</xsl:message> -->
          <!-- when containing only inline elements or text()-->
				<w:p>
					<w:pPr>
					 <xsl:if test="$cell-align != '' and  (ancestor::cell or ancestor::hcell)">
            <w:jc w:val="{$cell-align}"/>
           </xsl:if>
						<xsl:call-template name="apply-style" />
            <!--##list##-->
            <!--##nlist##-->
            <!--##item##-->
            <xsl:choose>
              <xsl:when test="fn:labels-keep-block-with-next($labels,@label)">
                <w:rPr>
                  <w:vanish/>
                  <w:specVanish/>
                </w:rPr>
              </xsl:when>
              <xsl:when test="fn:default-keep-block-with-next(@label)">
                <w:rPr>
                  <w:vanish/>
                  <w:specVanish/>
                </w:rPr>
              </xsl:when>
            </xsl:choose> 
						<xsl:if test="ancestor::item">
							<xsl:choose>
								<xsl:when test="position()=1">
									<w:numPr>
										<w:ilvl w:val="{count(ancestor::list)+count(ancestor::nlist)-1}" />
										<w:numId w:val="{fn:get-numbering-id(current())}" />
									</w:numPr>
								</xsl:when>
								<xsl:otherwise>
									<w:ind w:left="{720*(count(ancestor::list)+count(ancestor::nlist))}" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
					</w:pPr>
					<xsl:apply-templates mode="content" />
				</w:p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

  
  <!--##para##-->
  <!-- para are treated normally -->
	<xsl:template match="para" mode="content">
		<xsl:param name="labels" tunnel="yes" />
    <xsl:param name="cell-align" tunnel="yes" />
<!--     <xsl:message><xsl:value-of select="@indent"/>:<xsl:value-of select="."/></xsl:message> -->
		<w:p>
			<w:pPr>
         <xsl:if test="$cell-align != '' and (ancestor::cell or ancestor::hcell)">
          <w:jc w:val="{$cell-align}"/>
         </xsl:if>
			  <xsl:choose>
          <xsl:when test="fn:labels-keep-para-with-next($labels,@indent,@numbered)">
            <w:rPr>
              <w:vanish/>
              <w:specVanish/>
            </w:rPr>
          </xsl:when>
          <xsl:when test="fn:default-keep-para-with-next(@indent,@numbered)">
            <w:rPr>
              <w:vanish/>
              <w:specVanish/>
            </w:rPr>
          </xsl:when>
          <xsl:otherwise>
            <!-- do nothing -->
          </xsl:otherwise>
        </xsl:choose> 
        <xsl:choose>
          <xsl:when test="ancestor::item">
            <xsl:variable name="role" select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/@role"/>
            <xsl:variable name="level" select="count(ancestor::list)+count(ancestor::nlist)"/>
            <xsl:variable name="list-type" select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/name()"/>
            <xsl:variable name="item-type" select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/@type"/>
            <xsl:choose>
            <xsl:when test="position()=1">
              <xsl:choose>
<!-- 	              <xsl:when test="ancestor::item/parent::*[@role]"> -->
<!-- 	                <xsl:message>1</xsl:message> -->
<!-- 	                <w:pStyle w:val="{ancestor::item/parent::*/@role}"/> -->
<!-- 	              </xsl:when> -->
<!--                 <xsl:when test="$item-type != ''"> -->
                
<!--                 </xsl:when> -->
	              <xsl:when test="fn:list-wordstyle-for-document-label($labels,$role,$level,$list-type) != ''">
<!-- 	                <xsl:message>2</xsl:message> -->
	<!--                 <w:pStyle> -->
	<!--                 <xsl:attribute name="w:val"><xsl:value-of select="fn:list-wordstyle-for-document-label($labels,$role,$level,$list-type)"/></xsl:attribute> -->
	<!--                 </w:pStyle> -->
	                <xsl:call-template name="apply-style" />
	              </xsl:when>
	              <xsl:when test="fn:list-wordstyle-for-default-document($role,$level,$list-type) != ''">
<!-- 	              <xsl:message>3</xsl:message> -->
	<!--                 <w:pStyle> -->
	<!--                 <xsl:attribute name="w:val"><xsl:value-of select="fn:list-wordstyle-for-default-document($role,$level,$list-type)"/></xsl:attribute> -->
	<!--                 </w:pStyle> -->
	                <xsl:call-template name="apply-style" />
	              </xsl:when>
	              <xsl:otherwise>
<!-- 	                <xsl:message>4</xsl:message> -->
	                <xsl:call-template name="apply-style" />
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
<!--          <xsl:message>precedingsbling:<xsl:value-of select="count(preceding-sibling::item)"/></xsl:message>     -->
<!--           <xsl:if test="count(preceding-sibling::item) = 0"> -->
            <w:numPr>
              <xsl:variable name="level">
                <xsl:choose>
                  <xsl:when test="ancestor::item/parent::*[@role]">
                    <xsl:value-of select="fn:get-level-from-role(ancestor::item/parent::*/@role,.)"/>
<!--                     <xsl:message><xsl:value-of select="fn:get-level-from-role(parent::*/@role,.)"/></xsl:message> -->
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="count(ancestor::list)+count(ancestor::nlist) - 1"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <w:ilvl w:val="{$level}" />
              <xsl:variable name="current-pstyle">
                <xsl:variable name="call-style">
                  <xsl:call-template name="apply-style" />
                </xsl:variable>
                <xsl:value-of select="$call-style//@w:val"/>
              </xsl:variable>
<!--               <xsl:message select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/name()"></xsl:message> -->
<!--               <xsl:message select="$current-pstyle"></xsl:message> -->
              <xsl:variable name="current-num-id">
                <xsl:choose>
                  <xsl:when test="ancestor::nlist[@type !='']">
                    <xsl:variable name="current-numid" select="max(document(concat($_dotxfolder,$numbering-template))//w:abstractNum/number(@w:abstractNumId))"/>
                   <!-- all lists inside the template + all normal lists inside psml document + preceding lists with @type + itself -->
                    <xsl:value-of select="$max-num-id + count($all-different-lists/*) + count(preceding::nlist[@type]) + 1"/>
<!--                      <xsl:message>A.<xsl:value-of select="$max-num-id + count($all-different-lists/*) + count(preceding::nlist[@type]) + 1"/></xsl:message> -->
                  </xsl:when>
                  <xsl:when test="ancestor::list and document(concat($_dotxfolder,$numbering-template))//w:abstractNum/w:lvl/w:pStyle/@w:val = $current-pstyle">
                    <xsl:variable name="current-numid" select="document(concat($_dotxfolder,$numbering-template))//w:abstractNum[w:lvl/w:pStyle/@w:val = $current-pstyle]/@w:abstractNumId"/>
                   
                    <xsl:value-of select="document(concat($_dotxfolder,$numbering-template))//w:num[w:abstractNumId/@w:val = $current-numid][1]/@w:numId"/>
<!--                     <xsl:message>B.<xsl:value-of select="document(concat($_dotxfolder,$numbering-template))//w:num[w:abstractNumId/@w:val = $current-numid][1]/@w:numId"/></xsl:message> -->
                  </xsl:when>
                  <xsl:when test="parent::*[@role]">
                    <xsl:value-of select="$max-num-id + count(preceding::*[name()='nlist'][@start][not(@type != '')]) + 1"/>
<!--                     <xsl:message>C.<xsl:value-of select="$max-num-id + count(preceding::*[name()='nlist'][@start][not(@type != '')]) + 1"/></xsl:message> -->
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$max-num-id + count(ancestor::*[name()='nlist'][last()]/
                                          preceding::*[name()='nlist']
                                          [not(ancestor::list or ancestor::nlist)][not(@type != '')]) + 1"/>
<!--                     <xsl:message>D.<xsl:value-of select="$max-num-id + count(ancestor::*[name()='nlist'][last()]/preceding::*[name()='nlist'][not(ancestor::list or ancestor::nlist)][not(@type != '')]) + 1"/></xsl:message>                       -->
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <w:numId w:val="{$current-num-id}" />
            </w:numPr>
            
            </xsl:when>
            <xsl:otherwise>
<!--               <xsl:message>here</xsl:message> -->
              <xsl:variable name="list-level" select="count(ancestor::list)+count(ancestor::nlist) + 1"/>
<!--               <xsl:message><xsl:value-of select="$list-level"/></xsl:message> -->
              <xsl:choose>
		            <xsl:when test="fn:para-list-level-paragraph-for-document-label($labels,$list-level,@numbered) != ''">
<!-- 		              <xsl:message>1</xsl:message> -->
                  <xsl:variable name="style-name" select="fn:para-list-level-paragraph-for-document-label($labels,$list-level,@numbered)"/>
		              <w:pStyle w:val="{document(concat($_dotxfolder,$styles-template))//w:style[w:name/@w:val = $style-name]/@w:styleId}"/>
		            </xsl:when>
		            <xsl:when test="fn:para-list-level-paragraph-for-default-document($list-level,@numbered) != ''">
<!-- 		              <xsl:message>2</xsl:message> -->
                  <xsl:variable name="style-name" select="fn:para-list-level-paragraph-for-default-document($list-level,@numbered)"/>
                  <w:pStyle w:val="{document(concat($_dotxfolder,$styles-template))//w:style[w:name/@w:val = $style-name]/@w:styleId}"/>
		            </xsl:when>
		            <xsl:otherwise>
<!-- 		              <xsl:message>3</xsl:message> -->
		              <w:pStyle w:val="BodyText"/>
		            </xsl:otherwise>
		          </xsl:choose>
<!--               <w:ind w:left="{720*(count(ancestor::list)+count(ancestor::nlist))}" /> -->
            </xsl:otherwise>
          </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="apply-style" />
<!-- 		        <xsl:if test="string(@indent) != '' and @indent castable as xs:integer"> -->
<!-- 		          <w:ind w:left="{720*number(@indent)}" /> -->
<!-- 		        </xsl:if> -->
          </xsl:otherwise>
        </xsl:choose>
				
          <!--##list##-->
          <!--##nlist##-->
          <!--##item##-->
				<xsl:if test="ancestor::item">
					
				</xsl:if>
				<xsl:if test="@prefix">
					<xsl:choose>
						<xsl:when test="fn:para-prefix-select-for-document-label($labels,@indent,@numbered)">
							<xsl:sequence select="fn:para-prefix-value-for-document-label($labels,@indent,current(),@numbered)" />
						</xsl:when>
						<xsl:when test="fn:para-prefix-select-for-default-document(@indent,@numbered)">
							<xsl:sequence select="fn:para-prefix-value-for-default-document(@indent,current(),@numbered)" />
						</xsl:when>
						<xsl:otherwise>
							<w:r>
								<w:t xml:space="preserve"><xsl:value-of select="@prefix" /> </w:t>
							</w:r>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
				<xsl:if test="@numbered = 'true'">
					<xsl:choose>
						<xsl:when test="fn:para-numbered-select-for-document-label($labels,@indent,@numbered)">
							<xsl:sequence select="fn:para-numbered-value-for-document-label($labels,@indent,current(),@numbered)" />
						</xsl:when>
						<xsl:when test="fn:para-numbered-select-for-default-document(@indent,@numbered)">
							<xsl:sequence select="fn:para-numbered-value-for-default-document(@indent,current(),@numbered)" />
						</xsl:when>
<!-- 						<xsl:otherwise> -->
<!-- 							<w:r> -->
<!-- 								<w:t xml:space="preserve"><xsl:value-of select="@prefix" /> </w:t> -->
<!-- 							</w:r> -->
<!-- 						</xsl:otherwise> -->
					</xsl:choose>
				</xsl:if>
			</w:pPr>
			<xsl:apply-templates mode="content" />
		</w:p>
	</xsl:template>

  <!--  preformat elements are currently imported as normal paragraphs -->
	<xsl:template match="preformat" mode="content">
    <xsl:param name="cell-align" tunnel="yes" />
		<w:p>
		  <w:pPr>
         <xsl:if test="$cell-align != '' and  (ancestor::cell or ancestor::hcell)">
          <w:jc w:val="{$cell-align}"/>
         </xsl:if>
		    <xsl:call-template name="apply-style" />
		  </w:pPr>
			<xsl:apply-templates mode="content" />
		</w:p>
	</xsl:template>

</xsl:stylesheet>