<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for processing PSML images

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio

  @version 0.6.0
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
                xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
                xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!--
  Template to create image
-->
<xsl:template match="image" mode="psml">
  <xsl:choose>
    <xsl:when test="parent::fragment">
      <!-- We need to wrap in paragraph -->
      <w:p>
        <xsl:apply-templates select="." mode="psml-run"/>
      </w:p>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="." mode="psml-run"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Process the image into a run containing a drawing if possible or a warning if the format is BMP
-->
<xsl:template match="image" mode="psml-run" as="element(w:r)">
  <xsl:choose>
    <xsl:when test="ends-with(lower-case(@src), '.bmp')">
      <w:r>
        <w:t>Images with BMP format are not supported.</w:t>
      </w:r>
    </xsl:when>
    <xsl:otherwise>
      <w:r>
        <w:pPr>
          <xsl:call-template name="apply-style" />
        </w:pPr>
        <xsl:call-template name="create-drawing-for-image"/>
      </w:r>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--
  Template to create the `w:drawing` object from the image
-->
<xsl:template name="create-drawing-for-image" as="element(w:drawing)">
  <xsl:param name="labels" tunnel="yes"/>
  <xsl:variable name="id"     select="count(preceding::image) + 1"/>
  <xsl:variable name="title"  select="string(@alt)"/>
  <xsl:variable name="maxwidth" select="config:image-maxwidth($labels)" />
  <xsl:variable name="pixelwidth" select="if (contains(@width,'px')) then substring-before(@width, 'px') else @width" />
  <xsl:variable name="pixelheight" select="if (contains(@height,'px')) then substring-before(@height, 'px') else @height" />
  <xsl:variable name="width">
    <xsl:choose>
      <xsl:when test="$maxwidth castable as xs:integer and $pixelwidth castable as xs:integer and
                      xs:integer($pixelwidth) gt xs:integer($maxwidth)">
        <xsl:value-of select="fn:dimension-to-emu($maxwidth, 3048000)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="fn:dimension-to-emu(@width, 3048000)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="height">
    <xsl:choose>
      <xsl:when test="$maxwidth castable as xs:integer and $pixelwidth castable as xs:integer and
                      xs:integer($pixelwidth) gt xs:integer($maxwidth) and $pixelheight castable as xs:integer">
        <xsl:value-of select="fn:pixels-to-emu(
                              xs:integer($maxwidth) div xs:integer($pixelwidth) * xs:integer($pixelheight))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="fn:dimension-to-emu(@height, 2032000)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <w:drawing>
    <wp:inline distT="0" distB="0" distL="0" distR="0">
      <wp:extent cx="{$width}" cy="{$height}" />
      <!-- Currently `@descr` is read by the docxcreator to find the target image in the image folder -->
      <wp:docPr id="{$id}" name="{substring-before(@src, '.')}" descr="" title="{$title}"/>
      <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
        <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
          <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:nvPicPr>
              <!-- name here is not essential  -->
              <pic:cNvPr id="0" name="whatever" />
              <pic:cNvPicPr/>
            </pic:nvPicPr>
            <pic:blipFill>
              <!-- the id in .rels, essential -->
              <a:blip r:embed="{concat('rId',(count(document($_document-relationship)//*[name() = 'Relationship']) + 2 + count(preceding::image)))}" />
              <a:stretch>
                <a:fillRect/>
              </a:stretch>
            </pic:blipFill>
            <pic:spPr>
              <a:xfrm>
                <a:off x="0" y="0"/>
                <!-- this is the size of the image frame -->
                <a:ext cx="{$width}" cy="{$height}"/>
              </a:xfrm>
              <a:prstGeom prst="rect">
                <a:avLst/>
              </a:prstGeom>
            </pic:spPr>
          </pic:pic>
        </a:graphicData>
      </a:graphic>
    </wp:inline>
  </w:drawing>
</xsl:template>

<!--
  Converts the width or height possibly followed by 'px' into EMU (1 pixel = 9525 EMUs)

  @param dimension The height or width
  @param fallback  A fallback value

  @return the formatted string value
-->
<xsl:function name="fn:dimension-to-emu" as="xs:string">
  <xsl:param name="dimension"/>
  <xsl:param name="default"/>
  <xsl:choose>
    <xsl:when test="$dimension[contains(., 'px')]">
      <xsl:value-of select="fn:pixels-to-emu(number(substring-before($dimension, 'px')))" />
    </xsl:when>
    <xsl:when test="$dimension castable as xs:integer">
      <xsl:value-of select="fn:pixels-to-emu(xs:integer($dimension))" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$default" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!--
  Converts the pixel size into EMU (1 pixel = 9525 EMUs)

  @param pixels The size in pixels
  @return the formatted string value
-->
<xsl:function name="fn:pixels-to-emu" as="xs:string">
  <xsl:param name="pixels"/>
  <xsl:value-of select="format-number($pixels * 9525, '#######')"/>
</xsl:function>

</xsl:stylesheet>
