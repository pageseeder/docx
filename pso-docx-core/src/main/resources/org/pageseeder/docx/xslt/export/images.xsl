<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for processing PSML images

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
                  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
                  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                  xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
                  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                  xmlns:fn="http://www.pageseeder.com/function"
                  exclude-result-prefixes="#all">

<!--
  Template to create image
-->
<xsl:template match="image" mode="content">
  <xsl:variable name="src" select="@src" />
  <xsl:variable name="filename">
    <xsl:choose>
      <xsl:when test="contains(tokenize(@src,'/')[last()],'.')">
        <xsl:value-of select="@src" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(@src,'.png')" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="ends-with($filename, '.bmp')">
      <xsl:choose>
        <xsl:when test="parent::body">
          <w:p>
            <w:r>
              <w:t>Images with BMP format are not supported.</w:t>
            </w:r>
          </w:p>
        </xsl:when>
        <xsl:otherwise>
          <w:r>
            <w:t>Images with BMP format are not supported.</w:t>
          </w:r>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
     <xsl:when test="parent::fragment">
       <w:p>
         <xsl:call-template name="create-pict">
           <xsl:with-param name="src" select="$src" />
         </xsl:call-template>
       </w:p>
     </xsl:when>
     <xsl:when test="parent::block and fn:has-block-elements(parent::block)='true'">
       <w:p>
         <xsl:call-template name="create-pict">
           <xsl:with-param name="src" select="$src" />
         </xsl:call-template>
       </w:p>
     </xsl:when>
     <xsl:otherwise>
       <xsl:call-template name="create-pict">
         <xsl:with-param name="src" select="$src" />
       </xsl:call-template>
     </xsl:otherwise>
   </xsl:choose>
</xsl:template>

<!-- TODO Use function for EMU conversion -->

<!-- 
  Template to create image
-->
<xsl:template name="create-pict">
  <xsl:param name="src" />
  <xsl:variable name="id" select="count(preceding::image) + 1" />
  <xsl:variable name="alt" select="if (@alt) then @alt else ''" />
  <xsl:variable name="width">
    <xsl:choose>
      <xsl:when test="@width[contains(.,'px')]">
        <!-- 1 pixel=9525 EMU= -->
        <xsl:value-of
          select="format-number(number(substring-before(@width,'px')) * 9525, '#######')" />
      </xsl:when>
      <xsl:when test="@width">
        <!-- 1 pixel=9525 EMU= -->
        <xsl:value-of select="format-number(@width * 9525, '#######')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="3048000" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="height">
    <xsl:choose>
      <xsl:when test="@height[contains(.,'px')]">
        <!-- 1 pixel=9525 EMU= -->
        <xsl:value-of
          select="format-number(number(substring-before(@height,'px')) * 9525, '#######')" />
      </xsl:when>
      <xsl:when test="@height">
        <!-- 1 pixel=9525 EMU= -->
        <xsl:value-of select="format-number(@height * 9525, '#######')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="2032000" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <w:r>
    <w:drawing>
      <wp:inline distT="0" distB="0" distL="0" distR="0">
        <wp:extent cx="{$width}" cy="{$height}" />
        <!--
          currently descr is read by the docxcreator to find the target
          image in the image folder
        -->
        <wp:docPr id="{$id}" name="{substring-before(@src,'.')}" descr="" title="{$alt}"/>
        <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
          <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
              <pic:nvPicPr>
                <!-- name here is not essential  -->
                <pic:cNvPr id="0" name="whatever" />
                <pic:cNvPicPr />
              </pic:nvPicPr>
              <pic:blipFill>
                <!-- the id in .rels, essential -->
                <a:blip r:embed="{concat('rId',(count(document($_document-relationship)//*[name() = 'Relationship']) + 2 + count(preceding::image)))}" />
                <a:stretch>
                  <a:fillRect />
                </a:stretch>
              </pic:blipFill>
              <pic:spPr>
                <a:xfrm>
                  <a:off x="0" y="0" />
                  <!-- this is the size of the image frame -->
                  <a:ext cx="{$width}" cy="{$height}" />
                </a:xfrm>
                <a:prstGeom prst="rect">
                  <a:avLst />
                </a:prstGeom>
              </pic:spPr>
            </pic:pic>
          </a:graphicData>
        </a:graphic>
      </wp:inline>
    </w:drawing>
  </w:r>
</xsl:template>

</xsl:stylesheet>
