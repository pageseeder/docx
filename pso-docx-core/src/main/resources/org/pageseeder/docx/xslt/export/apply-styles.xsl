<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module to apply the Word styles based on common PSML elements

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:fn="http://pageseeder.org/docx/function"
                xmlns:config="http://pageseeder.org/docx/config"
                exclude-result-prefixes="#all">

<!--
  Template to handle word style creation from:
  1. inline labels
  2. block labels
  3. para elements inside block labels
  4. heading elements
  5. list default elements
  6. title elements
-->
<xsl:template name="apply-style">
  <xsl:param name="labels" tunnel="yes"/>
  <xsl:variable name="style-name">
    <xsl:choose>

      <!-- TODO The code below should be implemented using a specific mode so that it is more extensible and easier to document -->

      <!-- Paragraphs within blocks -->
      <xsl:when test="self::para and parent::block">
        <xsl:variable name="blocklabel" select="(ancestor::block)[last()]/@label" />
        <xsl:variable name="fragmentlabel" select="tokenize((ancestor::fragment)[last()]/@labels,',')" />
        <xsl:choose>
          <xsl:when test="config:para-wordstyle-for-block-label-document-label($blocklabel,$labels,./@indent, ./@numbered, ./@prefix) != ''">
            <xsl:value-of select="config:para-wordstyle-for-block-label-document-label($blocklabel,$labels, ./@indent, ./@numbered, ./@prefix)"/>
          </xsl:when>
          <xsl:when test="config:para-wordstyle-for-block-label($blocklabel,./@indent, ./@numbered, ./@prefix) != ''">
            <xsl:value-of select="config:para-wordstyle-for-block-label($blocklabel, ./@indent, ./@numbered, ./@prefix)"/>
          </xsl:when>
          <xsl:when test="config:para-wordstyle-for-fragment-label-document-label($fragmentlabel,$labels,./@indent, ./@numbered, ./@prefix) != ''">
            <xsl:value-of select="config:para-wordstyle-for-fragment-label-document-label($fragmentlabel,$labels, ./@indent, ./@numbered, ./@prefix)"/>
          </xsl:when>
          <xsl:when test="config:para-wordstyle-for-fragment-label($fragmentlabel,./@indent, ./@numbered, ./@prefix) != ''">
            <xsl:value-of select="config:para-wordstyle-for-fragment-label($fragmentlabel, ./@indent, ./@numbered, ./@prefix)"/>
          </xsl:when>
          <xsl:when test="config:block-wordstyle-for-document-label($labels, parent::block/@label) = 'generate-ps-style'">
            <xsl:value-of select="concat('ps_blk_',parent::block/@label)"/>
          </xsl:when>
          <xsl:when test="config:block-wordstyle-for-document-label($labels, parent::block/@label)!=''">
            <xsl:value-of select="config:block-wordstyle-for-document-label($labels, parent::block/@label)"/>
          </xsl:when>
          <xsl:when test="config:block-default-wordstyle-for-document-label($labels) = 'generate-ps-style'">
            <xsl:value-of select="concat('ps_blk_', parent::block/@label)"/>
          </xsl:when>
          <xsl:when test="config:block-default-wordstyle-for-document-label($labels) != ''">
            <xsl:value-of select="config:block-default-wordstyle-for-document-label($labels)"/>
          </xsl:when>
          <xsl:when test="config:block-wordstyle-for-default-document(parent::block/@label)='generate-ps-style'">
            <xsl:value-of select="concat('ps_blk_', parent::block/@label)"/>
          </xsl:when>
          <xsl:when test="config:block-wordstyle-for-default-document(parent::block/@label)!=''">
            <xsl:value-of select="config:block-wordstyle-for-default-document(parent::block/@label)"/>
          </xsl:when>
          <xsl:when test="config:block-default-wordstyle-for-default-document() = 'generate-ps-style'">
            <xsl:value-of select="concat('ps_blk_', parent::block/@label)"/>
          </xsl:when>
          <xsl:when test="config:block-default-wordstyle-for-default-document() !=''">
            <xsl:value-of select="config:block-default-wordstyle-for-default-document()"/>
          </xsl:when>
          <xsl:when test="config:para-wordstyle-for-document-label($labels,./@indent, ./@numbered, ./@prefix) != ''">
            <xsl:value-of select="config:para-wordstyle-for-document-label($labels, ./@indent, ./@numbered, ./@prefix)"/>
          </xsl:when>
          <xsl:when test="config:para-wordstyle-for-default-document(./@indent, ./@numbered, ./@prefix) != ''">
            <xsl:value-of select="config:para-wordstyle-for-default-document(./@indent, ./@numbered, ./@prefix)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$default-paragraph-style"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- Paragraphs within property -->
      <xsl:when test="self::para and ancestor::properties-fragment">
        <xsl:variable name="props" select="ancestor::properties-fragment[1]" />
        <xsl:value-of select="config:properties-value-style-name($labels, $props/@type)" />
      </xsl:when>

      <!-- Paragraphs within table -->
      <xsl:when test="self::para and ancestor::table">
        <xsl:variable name="table" select="ancestor::table[1]" />
        <xsl:variable name="row" select="ancestor::row[1]" />
        <xsl:variable name="cell" select="(ancestor::*[name()='cell' or name()='hcell'])[1]" />
        <!-- TODO how should colspan and rowspan be handled for header? -->
        <xsl:variable name="header" select="$row/@part='header' or
            $table/col[position()=(count($cell/preceding-sibling::*)+1)]/@part='header'" />
        <xsl:choose>
          <xsl:when test="$header">
            <xsl:value-of select="config:table-head-style($labels, $table/@role)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="config:table-body-style($labels, $table/@role)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- TODO The block of code below is a copy of the above with different context -->
      <!-- Block labels -->
      <xsl:when test="self::block">
        <xsl:choose>
          <xsl:when test="config:block-wordstyle-for-document-label($labels, @label)='generate-ps-style'">
            <xsl:value-of select="concat('ps_blk_', @label)"/>
          </xsl:when>
          <xsl:when test="config:block-wordstyle-for-document-label($labels, @label)!=''">
            <xsl:value-of select="config:block-wordstyle-for-document-label($labels, @label)"/>
          </xsl:when>
          <xsl:when test="config:block-default-wordstyle-for-document-label($labels) = 'generate-ps-style'">
            <xsl:value-of select="concat('ps_blk_', @label)"/>
          </xsl:when>
          <xsl:when test="config:block-default-wordstyle-for-document-label($labels) != ''">
            <xsl:value-of select="config:block-default-wordstyle-for-document-label($labels)"/>
          </xsl:when>
          <xsl:when test="config:block-wordstyle-for-default-document(@label)='generate-ps-style'">
            <xsl:value-of select="concat('ps_blk_', @label)"/>
          </xsl:when>
          <xsl:when test="config:block-wordstyle-for-default-document(@label)!=''">
            <xsl:value-of select="config:block-wordstyle-for-default-document(@label)"/>
          </xsl:when>
          <xsl:when test="config:block-default-wordstyle-for-default-document() = 'generate-ps-style'">
            <xsl:value-of select="concat('ps_blk_', @label)"/>
          </xsl:when>
          <xsl:when test="config:block-default-wordstyle-for-default-document() !=''">
            <xsl:value-of select="config:block-default-wordstyle-for-default-document()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$default-paragraph-style"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- image -->
      <xsl:when test="self::image">
        <xsl:choose>
          <xsl:when test="config:image-wordstyle-for-document-label($labels) != ''">
            <xsl:value-of select="config:image-wordstyle-for-document-label($labels)"/>
          </xsl:when>
          <xsl:when test="config:image-wordstyle-for-default-document() !=''">
            <xsl:value-of select="config:image-wordstyle-for-default-document()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$default-character-style"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- pre-formatted text -->
      <xsl:when test="self::preformat">
        <xsl:choose>
          <xsl:when test="config:preformat-wordstyle-for-document-label($labels) != ''">
            <xsl:value-of select="config:preformat-wordstyle-for-document-label($labels)"/>
          </xsl:when>
          <xsl:when test="config:preformat-wordstyle-for-default-document() !=''">
            <xsl:value-of select="config:preformat-wordstyle-for-default-document()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$default-paragraph-style"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- Inline label or content within inline label -->
      <xsl:when test="self::inline or ancestor::inline">
        <!-- TODO Use a variable for label attribute -->
        <xsl:choose>
          <xsl:when test="config:inline-wordstyle-for-document-label($labels, ancestor::inline[1]/@label)='generate-ps-style'">
            <xsl:value-of select="concat('ps_inl_', ancestor::inline[1]/@label)"/>
          </xsl:when>
          <xsl:when test="config:inline-wordstyle-for-document-label($labels, ancestor::inline[1]/@label)!=''">
            <xsl:value-of select="config:inline-wordstyle-for-document-label($labels, ancestor::inline[1]/@label)"/>
          </xsl:when>
          <xsl:when test="config:inline-default-wordstyle-for-document-label($labels) = 'generate-ps-style'">
            <xsl:value-of select="concat('ps_inl_', ancestor::inline[1]/@label)"/>
          </xsl:when>
          <xsl:when test="config:inline-default-wordstyle-for-document-label($labels) != ''">
            <xsl:value-of select="config:inline-default-wordstyle-for-document-label($labels)"/>
          </xsl:when>
          <xsl:when test="config:inline-wordstyle-for-default-document(ancestor::inline[1]/@label)='generate-ps-style'">
            <xsl:value-of select="concat('ps_inl_', ancestor::inline[1]/@label)"/>
          </xsl:when>
          <xsl:when test="config:inline-wordstyle-for-default-document(ancestor::inline[1]/@label)!=''">
            <xsl:value-of select="config:inline-wordstyle-for-default-document(ancestor::inline[1]/@label)"/>
          </xsl:when>
          <xsl:when test="config:inline-default-wordstyle-for-default-document() = 'generate-ps-style'">
            <xsl:value-of select="concat('ps_inl_', ancestor::inline[1]/@label)"/>
          </xsl:when>
          <xsl:when test="config:inline-default-wordstyle-for-default-document() != ''">
            <xsl:value-of select="config:inline-default-wordstyle-for-default-document()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$default-character-style"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- Heading -->
      <xsl:when test="self::heading">
        <xsl:variable name="blocklabel" select="(ancestor::block)[last()]/@label" />
        <xsl:variable name="fragmentlabel" select="tokenize((ancestor::fragment)[last()]/@labels,',')" />
        <xsl:choose>
          <xsl:when test="config:heading-wordstyle-for-block-label-document-label($blocklabel,$labels,@level,@numbered,@prefix) != ''">
            <xsl:value-of select="config:heading-wordstyle-for-block-label-document-label($blocklabel,$labels,@level,@numbered,@prefix)"/>
          </xsl:when>
          <xsl:when test="config:heading-wordstyle-for-block-label($blocklabel,@level,@numbered,@prefix) != ''">
            <xsl:value-of select="config:heading-wordstyle-for-block-label($blocklabel,@level,@numbered,@prefix)"/>
          </xsl:when>
          <xsl:when test="config:heading-wordstyle-for-fragment-label-document-label($fragmentlabel,$labels,@level,@numbered,@prefix) != ''">
            <xsl:value-of select="config:heading-wordstyle-for-fragment-label-document-label($fragmentlabel,$labels,@level,@numbered,@prefix)"/>
          </xsl:when>
          <xsl:when test="config:heading-wordstyle-for-fragment-label($fragmentlabel,@level,@numbered,@prefix) != ''">
            <xsl:value-of select="config:heading-wordstyle-for-fragment-label($fragmentlabel,@level,@numbered,@prefix)"/>
          </xsl:when>
          <xsl:when test="config:heading-wordstyle-for-document-label($labels,@level,@numbered,@prefix) != ''">
            <xsl:value-of select="config:heading-wordstyle-for-document-label($labels,@level,@numbered,@prefix)"/>
          </xsl:when>
          <xsl:when test="config:heading-wordstyle-for-default-document(@level,@numbered,@prefix) != ''">
            <xsl:value-of select="config:heading-wordstyle-for-default-document(@level,@numbered,@prefix)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$default-paragraph-style"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- Section titles -->
      <xsl:when test="self::title">
        <xsl:choose>
          <xsl:when test="config:title-wordstyle-for-document-label($labels) != ''">
            <xsl:value-of select="config:title-wordstyle-for-document-label($labels)"/>
          </xsl:when>
          <xsl:when test="config:title-wordstyle-for-default-document() != ''">
            <xsl:value-of select="config:title-wordstyle-for-default-document()"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$default-paragraph-style"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <!-- List item -->
      <xsl:when test="ancestor::item[1]">
        <xsl:variable name="blocklabel" select="ancestor::*[name() = 'list' or name() = 'nlist'][last()]/(ancestor::block)[last()]/@label" />
        <xsl:variable name="fragmentlabel" select="tokenize(ancestor::*[name() = 'list' or name() = 'nlist'][last()]/(ancestor::fragment)[last()]/@labels,',')" />
        <xsl:variable name="level" select="count(ancestor::list)+count(ancestor::nlist)"/>
        <xsl:variable name="role"      select="ancestor::*[name() = 'list' or name() = 'nlist'][last()]/@role"/>
        <xsl:variable name="list-type" select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/name()"/>
        <xsl:choose>
          <xsl:when test="config:list-paragraphstyle-for-block-label-document-label($blocklabel,$labels,$role,$level,$list-type) != ''">
            <xsl:value-of select="config:list-paragraphstyle-for-block-label-document-label($blocklabel,$labels,$role,$level,$list-type)"/>
          </xsl:when>
          <xsl:when test="config:list-paragraphstyle-for-block-label($blocklabel,$role,$level,$list-type) != ''">
            <xsl:value-of select="config:list-paragraphstyle-for-block-label($blocklabel,$role,$level,$list-type)"/>
          </xsl:when>
          <xsl:when test="config:list-paragraphstyle-for-fragment-label-document-label($fragmentlabel,$labels,$role,$level,$list-type) != ''">
            <xsl:value-of select="config:list-paragraphstyle-for-fragment-label-document-label($fragmentlabel,$labels,$role,$level,$list-type)"/>
          </xsl:when>
          <xsl:when test="config:list-paragraphstyle-for-fragment-label($fragmentlabel,$role,$level,$list-type) != ''">
            <xsl:value-of select="config:list-paragraphstyle-for-fragment-label($fragmentlabel,$role,$level,$list-type)"/>
          </xsl:when>
          <xsl:when test="config:list-paragraphstyle-for-document-label($labels,$role,$level,$list-type) != ''">
            <xsl:value-of select="config:list-paragraphstyle-for-document-label($labels,$role,$level,$list-type)"/>
          </xsl:when>
          <xsl:when test="config:list-paragraphstyle-for-default-document($role,$level,$list-type) != ''">
            <xsl:value-of select="config:list-paragraphstyle-for-default-document($role,$level,$list-type)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="fn:default-list-wordstyle($level,$list-type)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:when test="self::para">
        <xsl:variable name="blocklabel" select="(ancestor::block)[last()]/@label" />
        <xsl:variable name="fragmentlabel" select="tokenize((ancestor::fragment)[last()]/@labels,',')" />
        <xsl:choose>
          <xsl:when test="config:para-wordstyle-for-block-label-document-label($blocklabel,$labels,./@indent, ./@numbered, ./@prefix) != ''">
            <xsl:value-of select="config:para-wordstyle-for-block-label-document-label($blocklabel,$labels, ./@indent, ./@numbered, ./@prefix)"/>
          </xsl:when>
          <xsl:when test="config:para-wordstyle-for-block-label($blocklabel,./@indent, ./@numbered, ./@prefix) != ''">
            <xsl:value-of select="config:para-wordstyle-for-block-label($blocklabel, ./@indent, ./@numbered, ./@prefix)"/>
          </xsl:when>
          <xsl:when test="config:para-wordstyle-for-fragment-label-document-label($fragmentlabel,$labels,./@indent, ./@numbered, ./@prefix) != ''">
            <xsl:value-of select="config:para-wordstyle-for-fragment-label-document-label($fragmentlabel,$labels, ./@indent, ./@numbered, ./@prefix)"/>
          </xsl:when>
          <xsl:when test="config:para-wordstyle-for-fragment-label($fragmentlabel,./@indent, ./@numbered, ./@prefix) != ''">
            <xsl:value-of select="config:para-wordstyle-for-fragment-label($fragmentlabel, ./@indent, ./@numbered, ./@prefix)"/>
          </xsl:when>
          <xsl:when test="config:para-wordstyle-for-document-label($labels,./@indent, ./@numbered, ./@prefix) != ''">
            <xsl:value-of select="config:para-wordstyle-for-document-label($labels, ./@indent, ./@numbered, ./@prefix)"/>
          </xsl:when>
          <xsl:when test="config:para-wordstyle-for-default-document(./@indent, ./@numbered, ./@prefix) != ''">
            <xsl:value-of select="config:para-wordstyle-for-default-document(./@indent, ./@numbered, ./@prefix)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$default-paragraph-style"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:when test="self::br">
        <xsl:value-of select="$default-paragraph-style"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$default-paragraph-style"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="all-styles" select="document(concat($_dotxfolder, $styles-template))" />
  <xsl:choose>
<!--       <xsl:when test="fn:element-type(name())='para'" > -->
<!--         <w:pStyle w:val="{$all-styles/w:styles/w:style[w:name[@w:val=$config-doc/config/defaultparagraphstyle/@style]]/@w:styleId}"/> -->
<!--       </xsl:when> -->
<!--       <xsl:when test="fn:element-type(name())='br'" > -->
<!--         <w:pStyle w:val="{$all-styles/w:styles/w:style[w:name[@w:val=$config-doc/config/defaultparagraphstyle/@style]]/@w:styleId}"/> -->
<!--       </xsl:when> -->
    <!-- TODO This code does not appear to be used (not referenced from toc) -->
    <xsl:when test="name()='toc' and $style-name != ''" >
      <w:pStyle w:val="{$style-name}"/>
    </xsl:when>
    <xsl:when test="fn:element-type(name())='block' and $all-styles/w:styles/w:style/w:name[@w:val=$style-name]" >
      <w:pStyle w:val="{$all-styles/w:styles/w:style[w:name[@w:val=$style-name]]/@w:styleId}"/>
    </xsl:when>
    <xsl:when test="fn:element-type(name())='block' and $style-name != ''" >
      <w:pStyle w:val="{$style-name}"/>
    </xsl:when>
    <xsl:when test="fn:element-type(name())='block'" >
      <w:pStyle w:val="{$all-styles/w:styles/w:style[w:name[@w:val=$default-paragraph-style]]/@w:styleId}"/>
    </xsl:when>
    <xsl:when test="fn:element-type(name())='inline' and $all-styles/w:styles/w:style[w:name[@w:val=$style-name]]/@w:styleId">
      <w:rStyle w:val="{$all-styles/w:styles/w:style[w:name[@w:val=$style-name]]/@w:styleId}"/>
    </xsl:when>
    <xsl:when test="fn:element-type(name())='inline' and $style-name != ''">
      <w:rStyle w:val="{$style-name}"/>
    </xsl:when>
    <xsl:when test="fn:element-type(name())='inline'">
      <w:rStyle w:val="{$all-styles/w:styles/w:style[w:name[@w:val=$default-character-style]]/@w:styleId}"/>
    </xsl:when>
    <xsl:when test="fn:element-type(name())='table' and $all-styles/w:styles/w:style[w:name[@w:val=$style-name]]/@w:styleId">
      <w:tblStyle w:val="{$config-doc/config/table/@default}"/>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!--
  Template to handle text run style creation from:
  - inline labels
  - monospace
  - sup
  - sub
  - bold
  - italic
  - underline
  Must be inside a <w:rPr> element.
-->
<xsl:template name="apply-run-style">
  <xsl:param name="labels" tunnel="yes"/>
  <!-- Inline labels -->
  <xsl:if test="ancestor::inline">
    <!-- if parent is an inline label -->
    <xsl:choose>
      <xsl:when test="matches(ancestor::inline[1]/@label, config:inline-fieldcode-labels-with-document-label($labels))"/>
      <xsl:when test="matches(ancestor::inline[1]/@label, config:default-inline-fieldcode-labels())"/>
      <xsl:when test="matches(ancestor::inline[1]/@label, config:inline-index-labels-with-document-label($labels))"/>
      <xsl:when test="matches(ancestor::inline[1]/@label, config:default-inline-index-labels())"/>
      <xsl:when test="ancestor::inline[@label]">
        <xsl:call-template name="apply-style" />
      </xsl:when>
      <!-- otherwise, inherit style from paragraph -->
    </xsl:choose>
  </xsl:if>
  <!-- `placeholder` -->
  <xsl:choose>
    <xsl:when test="ancestor::placeholder/@unresolved='true' and config:placeholder-unresolved-styleid()">
      <w:rStyle w:val="{config:placeholder-unresolved-styleid()}"/>
    </xsl:when>
    <xsl:when test="ancestor::placeholder and config:placeholder-resolved-styleid()">
      <w:rStyle w:val="{config:placeholder-resolved-styleid()}"/>
    </xsl:when>
  </xsl:choose>
  <!-- `monospace` -->
  <xsl:if test="ancestor::monospace">
    <w:rStyle w:val="HTMLCode"/>
  </xsl:if>
  <!-- `superscript` -->
  <xsl:if test="ancestor::sup">
    <w:vertAlign w:val="superscript" />
  </xsl:if>
  <!-- `subscript` -->
  <xsl:if test="ancestor::sub">
    <w:vertAlign w:val="subscript" />
  </xsl:if>
  <!-- `bold` -->
  <xsl:if test="ancestor::bold">
    <w:b />
  </xsl:if>
  <!-- `italic` -->
  <xsl:if test="ancestor::italic ">
    <w:i />
  </xsl:if>
  <!-- `underline` -->
  <xsl:if test="ancestor::underline">
    <w:u w:val="single" />
  </xsl:if>
<!-- TODO Handling of diff elements -->
<!--             <xsl:if test="ancestor::dfx:del"> -->
<!--               <w:highlight w:val="red"/> -->
<!--             </xsl:if> -->
<!--             <xsl:if test="ancestor::dfx:ins"> -->
<!--               <w:highlight w:val="yellow"/> -->
<!--             </xsl:if> -->
</xsl:template>

</xsl:stylesheet>