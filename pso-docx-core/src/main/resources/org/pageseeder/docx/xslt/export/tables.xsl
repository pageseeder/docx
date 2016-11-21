<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ve="http://schemas.openxmlformats.org/markup-compatibility/2006"
	xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
	xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
	xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
	xmlns:fn="http://www.pageseeder.com/function" exclude-result-prefixes="#all">

  <!--
    Handle tables with colspan and rowspan
    
    @author Hugo Inacio
  -->
  
  <!-- Template to match table. It calls a named template to create each row -->
	<xsl:template match="table[.//row]" mode="content">
		<xsl:param name="labels" tunnel="yes" />
    <!--caption goes before the table in WordProcessingML-->
		<xsl:if test="caption">
			<w:p>
				<w:pPr>
					<w:pStyle w:val="Tablecaption" />
				</w:pPr>
				<xsl:apply-templates select="caption" mode="content" />
			</w:p>
		</xsl:if>

		<w:tbl>
			<w:tblPr>  
<!-- 			<xsl:message select="fn:default-table-style()"/> -->
				<xsl:choose>
					<xsl:when test="fn:table-roles-with-document-label($labels,@role) != ''">
						<w:tblStyle w:val="{fn:table-roles-with-document-label(@role,$labels)}" />
						<xsl:if test="fn:table-roles-with-document-label-type($labels,@role) != ''">
						   <w:tblW w:w="{fn:table-roles-with-document-label-type-value($labels,@role)}" w:type="{fn:table-roles-with-document-label-type($labels,@role)}" />
						</xsl:if>
					</xsl:when>
					<xsl:when test="fn:default-table-style-with-document-label($labels) != ''">
						<w:tblStyle w:val="{fn:default-table-style-with-document-label($labels)}" />
						<xsl:if test="fn:default-table-style-with-document-label-type($labels) != ''">
               <w:tblW w:w="{fn:default-table-style-with-document-label-type-value($labels)}" w:type="{fn:default-table-style-with-document-label-type($labels)}" />
            </xsl:if>
					</xsl:when>
          <xsl:when test="fn:default-table-roles(@role) != ''">
            <w:tblStyle w:val="{fn:default-table-roles(@role)}" />
            <xsl:if test="fn:default-table-roles-type(@role) != ''">
               <w:tblW w:w="{fn:default-table-roles-type-value(@role)}" w:type="{fn:default-table-roles-type(@role)}" />
            </xsl:if>
          </xsl:when>
					<xsl:when test="fn:default-table-style() != ''">
<!--             <xsl:message select="fn:default-table-style()"></xsl:message> -->
						<w:tblStyle w:val="{fn:default-table-style()}" />
						<xsl:if test="fn:default-table-style-type() != ''">
               <w:tblW w:w="{fn:default-table-style-type-value()}" w:type="{fn:default-table-style-type()}" />
            </xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<w:tblBorders>
							<w:top w:val="single" w:sz="4" w:space="0" w:color="auto" />
							<w:left w:val="single" w:sz="4" w:space="0" w:color="auto" />
							<w:bottom w:val="single" w:sz="4" w:space="0" w:color="auto" />
							<w:right w:val="single" w:sz="4" w:space="0" w:color="auto" />
							<w:insideH w:val="single" w:sz="4" w:space="0" w:color="auto" />
							<w:insideV w:val="single" w:sz="4" w:space="0" w:color="auto" />
						</w:tblBorders>
						<w:tblW w:w="0" w:type="auto" />
					</xsl:otherwise>
				</xsl:choose>
        <xsl:if test="caption">
          <w:tblCaption w:val="{caption}"/>
        </xsl:if>
        <xsl:if test="@summary">
          <w:tblDescription w:val="{@summary}"/>
        </xsl:if>
        
        <w:tblLook w:val="05E0" w:firstRow="{if(row[1][@part = 'header']) then 1 else 0}" w:lastRow="{if(row[last()][@part = 'footer']) then 1 else 0}" w:firstColumn="{if(col[1][@part = 'header']) then 1 else 0}" w:lastColumn="{if(col[last()][@part = 'footer']) then 1 else 0}"/>
			</w:tblPr>
			<xsl:variable name="max-columns" select="count(row[1]/*[name() = 'cell' or 'hcell'][not(@colspan)]) + sum(row[1]/*[name() = 'cell' or 'hcell'][@colspan]/@colspan)" />

<!-- 			<xsl:if test="col[@width]"> -->
<!-- 				<w:tblGrid> -->
<!-- 					<xsl:for-each select="col"> -->
<!-- 						<w:gridCol> -->
<!-- 							<xsl:attribute name="w:w" select="format-number(number(substring-before(@width,'px')) * 15, '#######')" /> -->
<!-- 						</w:gridCol> -->
<!-- 					</xsl:for-each> -->
<!-- 				</w:tblGrid> -->
<!-- 			</xsl:if> -->
			<xsl:variable name="column-properties" as="element()">
				<columns>
          <xsl:for-each select="./col">
              <col>
                <xsl:choose>
                  <xsl:when test="@width">
                    <xsl:analyze-string regex="(\d+)(.*)" select="@width">
                      <xsl:matching-substring>
                        <xsl:attribute name="value" select="if(regex-group(2) = '%') then number(regex-group(1)) * 50 else number(regex-group(1)) * 15"/>
                        <xsl:attribute name="type" select="if(regex-group(2) = '%') then 'pct' else 'dxa'"/>
                      </xsl:matching-substring>
                      <xsl:non-matching-substring>
                      </xsl:non-matching-substring>
                    </xsl:analyze-string>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="value" select="0"/>
                    <xsl:attribute name="type" select="'auto'"/>
                  </xsl:otherwise>
                </xsl:choose>
              </col>
            </xsl:for-each>
					<xsl:copy-of select="./col" />
          <xsl:if test="$max-columns != count(col)">
            <xsl:for-each select="count(col) to xs:integer($max-columns)">
              <col value="0" type="auto"/>
            </xsl:for-each>
          </xsl:if>
				</columns>
			</xsl:variable>
<!--       <xsl:message><xsl:value-of select=".//row[1]"/></xsl:message> -->
			<xsl:call-template name="create-rows-recursively">
				<xsl:with-param name="row-position" select="1" />
				<xsl:with-param name="previous-position" select="0" />
				<xsl:with-param name="previous-row" select=".//row[1]" as="element()" />
				<xsl:with-param name="row" select=".//row[1]" as="node()" />
        <xsl:with-param name="column-properties" select="$column-properties" as="element()" />
			</xsl:call-template>
		</w:tbl>
	</xsl:template>
  
  <!-- Template that creates each row recursively. It calls a template to calculate the preceding row's colspans and rowspans -->
	<xsl:template name="create-rows-recursively">
		<xsl:param name="row-position" />
		<xsl:param name="previous-position" />
		<xsl:param name="previous-row" as="element()" />
		<xsl:param name="row" as="node()" />
    <xsl:param name="column-properties" as="element()" />
    
		<xsl:variable name="current" select="$row" />

		<xsl:choose>
			<xsl:when test="$previous-position = 0">
				<w:tr>
          <xsl:if test="$row/hcell">
            <w:trPr>
              <w:tblHeader/>
            </w:trPr>
          </xsl:if>
					<xsl:for-each select="$row/*[name() = 'cell' or 'hcell']">
            <xsl:variable name="position" select="position()"/>
						<w:tc>
							<w:tcPr>
								<w:tcW w:w="{$column-properties/col[position() = $position]/@value}" w:type="{$column-properties/col[position() = $position]/@type}" />
								<xsl:if test="@colspan">
									<w:gridSpan w:val="{@colspan}" />
								</xsl:if>
								<xsl:if test="@rowspan">
									<w:vMerge w:val="restart" />
								</xsl:if>
							</w:tcPr>
							<xsl:choose>
                      <!-- when contains mixed content -->
								<xsl:when test="para or block or preformat or nlist or list or heading">
									<xsl:apply-templates mode="content">
                     <xsl:with-param name="cell-align" select="fn:return-word-cell-alignment(@align)" tunnel="yes"/>
                     </xsl:apply-templates>
								</xsl:when>
                      <!-- If no content, generate a dummy paragraph anyway -->
								<xsl:when test="not(child::node())">
									<w:p />
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates mode="content" >
                     <xsl:with-param name="cell-align" select="fn:return-word-cell-alignment(@align)" tunnel="yes"/>
                  </xsl:apply-templates>
								</xsl:otherwise>
							</xsl:choose>
						</w:tc>
					</xsl:for-each>
				</w:tr>
			</xsl:when>
			<xsl:otherwise>
				<w:tr>
					<xsl:for-each select="$previous-row/*[name() = 'cell' or 'hcell']">
            <xsl:variable name="position" select="position()"/>
						<xsl:variable name="row-position" select="
            count(preceding-sibling::*[name() = 'cell' or 'hcell'][not(number(@rowspan) gt 1)]) + (if(.[not(number(@rowspan) gt 1)]) then 1 else 0)" />
						<xsl:choose>
							<xsl:when test="number(@rowspan) gt 1">
								<xsl:choose>
									<xsl:when test="not(@colspans)">
										<w:tc>
											<w:tcPr>
												<w:tcW w:w="{$column-properties/col[position() = $position]/@value}" w:type="{$column-properties/col[position() = $position]/@type}" />
												<w:vMerge />
											</w:tcPr>
											<w:p />
										</w:tc>
									</xsl:when>
									<xsl:when test="@colspans = preceding-sibling::*/@colspans">
									</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="colspans-value" select="@colspans" />
										<xsl:variable name="number-of-colspans" select="count(following-sibling::*[@colspans = $colspans-value]) + 1" />
										<w:tc>
											<w:tcPr>
												<w:tcW w:w="{$column-properties/col[position() = $position]/@value}" w:type="{$column-properties/col[position() = $position]/@type}" />
												<w:gridSpan w:val="{$number-of-colspans}" />
												<w:vMerge />
											</w:tcPr>
											<w:p />
										</w:tc>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="$current/*[name() = 'cell' or 'hcell']">
                <xsl:variable name="position" select="position()"/>
									<xsl:variable name="current-row-position" select="count(preceding-sibling::*[name() = 'cell' or 'hcell'][not(@colspan)]) + sum(preceding-sibling::*[name() = 'cell' or 'hcell'][@colspan]/@colspan) + 1" />
									<xsl:choose>
										<xsl:when test="$row-position = $current-row-position">
											<w:tc>
												<w:tcPr>
													<w:tcW w:w="{$column-properties/col[position() = $position]/@value}" w:type="{$column-properties/col[position() = $position]/@type}" />
													<xsl:if test="@colspan">
														<w:gridSpan w:val="{@colspan}" />
													</xsl:if>
													<xsl:if test="@rowspan">
														<w:vMerge w:val="restart" />
													</xsl:if>
												</w:tcPr>
												<xsl:choose>
						                      <!-- when contains mixed content -->
													<xsl:when test="para or block or preformat or nlist or list or heading">
														<xsl:apply-templates mode="content"  >
                              <xsl:with-param name="cell-align" select="fn:return-word-cell-alignment(@align)" tunnel="yes"/>
                            </xsl:apply-templates>
													</xsl:when>
						                      <!-- If no content, generate a dummy paragraph anyway -->
													<xsl:when test="not(child::node())">
														<w:p />
													</xsl:when>
													<xsl:otherwise>
														<xsl:apply-templates mode="content"  >
                              <xsl:with-param name="cell-align" select="fn:return-word-cell-alignment(@align)" tunnel="yes"/>
                            </xsl:apply-templates>
													</xsl:otherwise>
												</xsl:choose>
											</w:tc>
										</xsl:when>
										<xsl:otherwise>

										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>

				</w:tr>
			</xsl:otherwise>
		</xsl:choose>


		<xsl:if test="$row/following-sibling::row[1]">
			<xsl:variable name="previous-row" as="element()">
				<xsl:call-template name="calculate-previous-row">
					<xsl:with-param name="row-position" select="count($row/following-sibling::row[1]/preceding-sibling::row)" />
					<xsl:with-param name="previous-position" select="count($row/following-sibling::row[1]/preceding-sibling::row) + 1" />
					<xsl:with-param name="previous-row" select="$previous-row" as="element()" />
					<xsl:with-param name="row" select="$row" as="node()" />
				</xsl:call-template>
			</xsl:variable>
      
			<xsl:call-template name="create-rows-recursively">
				<xsl:with-param name="row-position" select="count($row/following-sibling::row[1]/preceding-sibling::row) + 1" />
				<xsl:with-param name="previous-position" select="count($row/following-sibling::row[1]/preceding-sibling::row)" />
				<xsl:with-param name="previous-row" select="$previous-row" as="element()" />
				<xsl:with-param name="row" select="$row/following-sibling::row[1]" as="node()" />
          <xsl:with-param name="column-properties" select="$column-properties" as="element()" />
			</xsl:call-template>

		</xsl:if>

	</xsl:template>
  
  <!-- Template to normalize the preceding row colspans and rowspans -->
	<xsl:template name="calculate-previous-row">
		<xsl:param name="row-position" />
		<xsl:param name="previous-position" />
		<xsl:param name="previous-row" as="element()" />
		<xsl:param name="row" as="node()" />
		<xsl:choose>
			<xsl:when test="$row-position = $previous-position">
				<row>
					<xsl:copy-of select="$previous-row/*" />
				</row>
			</xsl:when>
			<xsl:when test="$row-position = 1">
				<xsl:variable name="currentRow" as="element()">
					<row>
						<xsl:for-each select="$row/*[name() = 'cell' or 'hcell']">
							<xsl:variable name="current-element" select="." />
							<xsl:choose>
								<xsl:when test="@colspan">
									<xsl:variable name="int-colspan" select="@colspan" as="xs:integer" />
									<xsl:for-each select="1 to $int-colspan">
										<xsl:element name="{$current-element/name()}">
											<xsl:attribute name="colspans" select="generate-id($current-element)" />
											<xsl:if test="$current-element/@rowspan">
												<xsl:attribute name="rowspan" select="$current-element/@rowspan" />
											</xsl:if>
										</xsl:element>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="{$current-element/name()}">
										<xsl:if test="$current-element/@rowspan">
											<xsl:attribute name="rowspan" select="$current-element/@rowspan" />
										</xsl:if>
									</xsl:element>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</row>
				</xsl:variable>

				<xsl:call-template name="calculate-previous-row">
					<xsl:with-param name="row-position" select="number($row-position) + 1" />
					<xsl:with-param name="previous-position" select="$previous-position" />
					<xsl:with-param name="previous-row" select="$currentRow" as="element()" />
					<xsl:with-param name="row" select="$row/ancestor::table[1]//row[$row-position + 1]" as="node()" />
				</xsl:call-template>
			</xsl:when>

			<xsl:otherwise>
				<xsl:variable name="currentRow" as="element()">
					<row>
						<xsl:for-each select="$previous-row/*[name() = 'cell' or 'hcell']">
							<xsl:choose>
								<xsl:when test="number(@rowspan) gt 1">
									<xsl:variable name="current-element" select="." />
									<xsl:choose>
										<xsl:when test="@colspan">
											<xsl:variable name="int-colspan" select="@colspan" as="xs:integer" />

											<xsl:for-each select="1 to $int-colspan">
												<xsl:element name="{$current-element/name()}">
													<xsl:attribute name="colspans" select="generate-id($current-element)" />
													<xsl:if test="$current-element/@rowspan">
														<xsl:attribute name="rowspan" select="number($current-element/@rowspan) - 1" />
													</xsl:if>
												</xsl:element>
											</xsl:for-each>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="{$current-element/name()}">
												<xsl:if test="$current-element/@rowspan">
													<xsl:attribute name="rowspan" select="number($current-element/@rowspan) - 1" />
													<xsl:if test="$current-element/@colspans">
                            <xsl:attribute name="colspans" select="$current-element/@colspans" />
                          </xsl:if>
												</xsl:if>
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="current-row-position"
										select="count(preceding-sibling::*[name() = 'cell' or 'hcell'][not(number(@rowspan) gt 1)])
                                                                  + sum(preceding-sibling::*[name() = 'cell' or 'hcell'][@colspan]/@colspan) + 1" />
									<xsl:for-each select="$row/*[name() = 'cell' or 'hcell']">
										<xsl:variable name="row-position"
											select="count(preceding-sibling::*[name() = 'cell' or 'hcell'][not(@colspan)])
                                                             + sum(preceding-sibling::*[name() = 'cell' or 'hcell'][@colspan]/@colspan) + 1" />
										<xsl:choose>
											<xsl:when test="$row-position = $current-row-position">
												<xsl:variable name="current-element" select="." />
												<xsl:choose>
													<xsl:when test="@colspan">
														<xsl:variable name="int-colspan" select="@colspan" as="xs:integer" />

														<xsl:for-each select="1 to $int-colspan">
															<xsl:element name="{$current-element/name()}">
																<xsl:attribute name="colspans" select="generate-id($current-element)" />
																<xsl:if test="$current-element/@rowspan">
																	<xsl:attribute name="rowspan" select="number($current-element/@rowspan)" />
																</xsl:if>
															</xsl:element>
														</xsl:for-each>
													</xsl:when>
													<xsl:otherwise>
														<xsl:element name="{$current-element/name()}">
															<xsl:if test="$current-element/@rowspan">
																<xsl:attribute name="rowspan" select="number($current-element/@rowspan)" />
															</xsl:if>
														</xsl:element>
													</xsl:otherwise>
												</xsl:choose>
											</xsl:when>
											<xsl:otherwise>

											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</row>
				</xsl:variable>
				<xsl:call-template name="calculate-previous-row">
					<xsl:with-param name="row-position" select="number($row-position) + 1" />
					<xsl:with-param name="previous-position" select="$previous-position" />
					<xsl:with-param name="previous-row" select="$currentRow" as="element()" />
					<xsl:with-param name="row" select="$row/ancestor::table[1]/row[$row-position + 1]" as="node()" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>


</xsl:stylesheet>