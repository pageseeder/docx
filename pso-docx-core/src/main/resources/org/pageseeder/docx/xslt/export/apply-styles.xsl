<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:fn="http://www.pageseeder.com/function" exclude-result-prefixes="#all">
  
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
<!--     <xsl:message>##<xsl:value-of select="./name()"/></xsl:message> -->
<!-- <xsl:if test="./ancestor::inline/@label"> -->
<!--     <xsl:message>#<xsl:value-of select="./ancestor::inline/@label"/></xsl:message> -->
<!--     </xsl:if> -->
    <xsl:variable name="style-name">
      <xsl:choose>
<!--         <xsl:when test="name()='toc'"> -->
<!--           <xsl:choose> -->
<!--             <xsl:when test="$config-doc/config/toc[@style != '']"> -->
<!--               <xsl:value-of select="$config-doc/config/toc/@style"/> -->
<!--             </xsl:when> -->
<!--             <xsl:otherwise> -->
<!--               <xsl:value-of select="$default-paragraph-style"/> -->
<!--             </xsl:otherwise> -->
<!--           </xsl:choose> -->
<!--         </xsl:when> -->
        
        <xsl:when test="(name()='para' and parent::block)">
        
          <xsl:variable name="block-label" select="parent::block/@label"/>
<!--           <xsl:message><xsl:value-of select="$block-label"/></xsl:message> -->
          <xsl:choose>
            <xsl:when test="fn:block-wordstyle-for-document-label($labels,parent::block/@label)='generate-ps-style'">
<!--               <xsl:message select="'1'"/> -->
              <xsl:value-of select="concat('psblock',parent::block/@label)"/>
            </xsl:when>
            <xsl:when test="fn:block-wordstyle-for-document-label($labels,parent::block/@label)!=''">
<!--               <xsl:message select="'2'"/> -->
              <xsl:value-of select="fn:block-wordstyle-for-document-label($labels,parent::block/@label)"/>
            </xsl:when>
            <xsl:when test="fn:block-default-wordstyle-for-document-label($labels) = 'generate-ps-style'">
<!--               <xsl:message select="'3'"/> -->
              <xsl:value-of select="concat('psblock',parent::block/@label)"/>
            </xsl:when>
            <xsl:when test="fn:block-default-wordstyle-for-document-label($labels) != ''">
<!--               <xsl:message select="'4'"/> -->
              <xsl:value-of select="fn:block-default-wordstyle-for-document-label($labels)"/>
            </xsl:when>
            <xsl:when test="fn:block-wordstyle-for-default-document(parent::block/@label)='generate-ps-style'">
<!--               <xsl:message select="'5'"/> -->
              <xsl:value-of select="concat('psblock',parent::block/@label)"/>
            </xsl:when>
            <xsl:when test="fn:block-wordstyle-for-default-document(parent::block/@label)!=''">
<!--               <xsl:message select="'6'"/> -->
              <xsl:value-of select="fn:block-wordstyle-for-default-document(parent::block/@label)"/>
            </xsl:when>
            <xsl:when test="fn:block-default-wordstyle-for-default-document() = 'generate-ps-style'">
<!--               <xsl:message select="'7'"/> -->
              <xsl:value-of select="concat('psblock',parent::block/@label)"/>
            </xsl:when>
            <xsl:when test="fn:block-default-wordstyle-for-default-document() !=''">
<!--               <xsl:message select="'8'"/> -->
              <xsl:value-of select="fn:block-default-wordstyle-for-default-document()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$default-paragraph-style"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        
        <xsl:when test="name()='block'">
          <xsl:variable name="block-label" select="@label"/>
<!--             <xsl:message select="@label"/> -->
          <xsl:choose>
            <xsl:when test="fn:block-wordstyle-for-document-label($labels,@label)='generate-ps-style'">
              <xsl:value-of select="concat('psblock',@label)"/>
            </xsl:when>
            <xsl:when test="fn:block-wordstyle-for-document-label($labels,@label)!=''">
              <xsl:value-of select="fn:block-wordstyle-for-document-label($labels,@label)"/>
            </xsl:when>
            <xsl:when test="fn:block-default-wordstyle-for-document-label($labels) = 'generate-ps-style'">
              <xsl:value-of select="concat('psblock',@label)"/>
            </xsl:when>
            <xsl:when test="fn:block-default-wordstyle-for-document-label($labels) != ''">
              <xsl:value-of select="fn:block-default-wordstyle-for-document-label($labels)"/>
            </xsl:when>
            <xsl:when test="fn:block-wordstyle-for-default-document(@label)='generate-ps-style'">
              <xsl:value-of select="concat('psblock',@label)"/>
            </xsl:when>
            <xsl:when test="fn:block-wordstyle-for-default-document(@label)!=''">
              
<!--               <xsl:message select="'#$@'"/><xsl:message select="fn:block-wordstyle-for-default-document(@label)"/> -->
              <xsl:value-of select="fn:block-wordstyle-for-default-document(@label)"/>
            </xsl:when>
            <xsl:when test="fn:block-default-wordstyle-for-default-document() = 'generate-ps-style'">
<!--               <xsl:message>heres</xsl:message> -->
              <xsl:value-of select="concat('psblock',@label)"/>
            </xsl:when>
            <xsl:when test="fn:block-default-wordstyle-for-default-document() !=''">
              <xsl:value-of select="fn:block-default-wordstyle-for-default-document()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$default-paragraph-style"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        
        <xsl:when test="(name()='preformat')">
          <xsl:choose>  
            <xsl:when test="fn:preformat-wordstyle-for-document-label($labels) != ''">
              <xsl:value-of select="fn:preformat-wordstyle-for-document-label($labels)"/>
            </xsl:when>
            <xsl:when test="fn:preformat-wordstyle-for-default-document() !=''">
              <xsl:value-of select="fn:preformat-wordstyle-for-default-document()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$default-paragraph-style"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        
        <xsl:when test="./ancestor::inline or name() = 'inline'">
<!--           <xsl:message select="ancestor::inline[1]/@label"/> -->
          <xsl:choose>
            <xsl:when test="fn:inline-wordstyle-for-document-label($labels,ancestor::inline[1]/@label)='generate-ps-style'">
<!--               <xsl:message>1</xsl:message> -->
              <xsl:value-of select="concat('psinline',ancestor::inline[1]/@label)"/>
            </xsl:when>
            <xsl:when test="fn:inline-wordstyle-for-document-label($labels,ancestor::inline[1]/@label)!=''">
              <xsl:variable name="name"><xsl:value-of select="ancestor::inline[1]/@label"/></xsl:variable>
              <xsl:value-of select="fn:inline-wordstyle-for-document-label($labels,ancestor::inline[1]/@label)"/>
<!--               <xsl:message>2</xsl:message> -->
            </xsl:when>            
            <xsl:when test="fn:inline-default-wordstyle-for-document-label($labels) = 'generate-ps-style'">
              <xsl:value-of select="concat('psinline',ancestor::inline[1]/@label)"/>
<!--               <xsl:message>3</xsl:message> -->
            </xsl:when>
            <xsl:when test="fn:inline-default-wordstyle-for-document-label($labels) != ''">
              <xsl:value-of select="fn:inline-default-wordstyle-for-document-label($labels)"/>
<!--               <xsl:message>4</xsl:message> -->
            </xsl:when>
            <xsl:when test="fn:inline-wordstyle-for-default-document(ancestor::inline[1]/@label)='generate-ps-style'">
              <xsl:value-of select="concat('psinline',ancestor::inline[1]/@label)"/>
<!--               <xsl:message>5</xsl:message> -->
            </xsl:when>
            <xsl:when test="fn:inline-wordstyle-for-default-document(ancestor::inline[1]/@label)!=''">
              <xsl:variable name="name"><xsl:value-of select="ancestor::inline[1]/@label"/></xsl:variable>
              <xsl:value-of select="fn:inline-wordstyle-for-default-document(ancestor::inline[1]/@label)"/>
<!--               <xsl:message>6</xsl:message> -->
            </xsl:when>
            <xsl:when test="fn:inline-default-wordstyle-for-default-document() = 'generate-ps-style'">
              <xsl:value-of select="concat('psinline',ancestor::inline[1]/@label)"/>
<!--               <xsl:message>7</xsl:message> -->
            </xsl:when>
            <xsl:when test="fn:inline-default-wordstyle-for-default-document() != ''">
              <xsl:value-of select="fn:inline-default-wordstyle-for-default-document()"/>
<!--               <xsl:message>8</xsl:message> -->
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$default-character-style"/>
<!--               <xsl:message>9</xsl:message> -->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="name()='heading'">
          <xsl:choose>
            <xsl:when test="fn:heading-wordstyle-for-document-label($labels,@level,@numbered) != ''">  
              <xsl:value-of select="fn:heading-wordstyle-for-document-label($labels,@level,@numbered)"/>
            </xsl:when>
            <xsl:when test="fn:heading-wordstyle-for-default-document(@level,@numbered) != ''">  
              <xsl:value-of select="fn:heading-wordstyle-for-default-document(@level,@numbered)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$default-paragraph-style"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="name()='title'">
          <xsl:choose>
            <xsl:when test="fn:title-wordstyle-for-document-label($labels) != ''">  
              <xsl:value-of select="fn:title-wordstyle-for-document-label($labels)"/>
            </xsl:when>
            <xsl:when test="fn:title-wordstyle-for-default-document() != ''">  
              <xsl:value-of select="fn:title-wordstyle-for-default-document()"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$default-paragraph-style"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="ancestor::item[1]">
          <xsl:variable name="level" select="count(ancestor::list)+count(ancestor::nlist)"/>
          <xsl:variable name="role" select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/@role"/>
          <xsl:variable name="list-type" select="ancestor::*[name() = 'list' or name() = 'nlist'][1]/name()"/>
<!--           <xsl:message><xsl:value-of select="$level"/>::<xsl:value-of select="$role"/>::<xsl:value-of select="$list-type"/></xsl:message> -->
          <xsl:choose>
            <xsl:when test="fn:list-wordstyle-for-document-label($labels,$role,$level,$list-type) != ''">
<!--               <xsl:message>1</xsl:message> -->
              <xsl:value-of select="fn:list-wordstyle-for-document-label($labels,$role,$level,$list-type)"/>
            </xsl:when>
            <xsl:when test="fn:list-wordstyle-for-default-document($role,$level,$list-type) != ''">
<!--               <xsl:message>2::<xsl:value-of select="fn:list-wordstyle-for-default-document($role,$level,$list-type)"/></xsl:message> -->
              <xsl:value-of select="fn:list-wordstyle-for-default-document($role,$level,$list-type)"/>
            </xsl:when>
            <xsl:otherwise>
<!--               <xsl:message>3</xsl:message> -->
              <xsl:value-of select="fn:default-list-wordstyle($level,$list-type)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="self::text() and ancestor::monospace">
          <xsl:value-of select="'monospace'"/>
        </xsl:when>
        <xsl:when test="name()='para'">
<!--           <xsl:message select="./@indent"></xsl:message> -->
<!--           <xsl:message select="./@numbered"></xsl:message> -->
<!--           <xsl:message select="fn:para-wordstyle-for-default-document(./@indent,./@numbered)"></xsl:message> -->
          <xsl:choose>
            <xsl:when test="fn:para-wordstyle-for-document-label($labels,./@indent,./@numbered,./@prefix) != ''">
              <xsl:value-of select="fn:para-wordstyle-for-document-label($labels,./@indent,./@numbered,./@prefix)"/>
            </xsl:when>
            <xsl:when test="fn:para-wordstyle-for-default-document(./@indent,./@numbered,./@prefix) != ''">
<!--               <xsl:message select="fn:para-wordstyle-for-default-document(./@indent,./@numbered)"></xsl:message> -->
              <xsl:value-of select="fn:para-wordstyle-for-default-document(./@indent,./@numbered,./@prefix)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$default-paragraph-style"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="name()='br'">
          <xsl:value-of select="$default-paragraph-style"/>
        </xsl:when>
        
        <xsl:otherwise>
          <xsl:value-of select="$default-paragraph-style"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
<!--     <xsl:message select="$style-name"/> -->
    <xsl:variable name="all-styles" select="document(concat($_dotxfolder,$styles-template))" />
    <xsl:choose>
<!--       <xsl:when test="fn:element-type(name())='para'" > -->
<!--         <w:pStyle w:val="{$all-styles/w:styles/w:style[w:name[@w:val=$config-doc/config/defaultparagraphstyle/@style]]/@w:styleId}"/> -->
<!--       </xsl:when> -->
<!--       <xsl:when test="fn:element-type(name())='br'" > -->
<!--         <w:pStyle w:val="{$all-styles/w:styles/w:style[w:name[@w:val=$config-doc/config/defaultparagraphstyle/@style]]/@w:styleId}"/> -->
<!--       </xsl:when> -->
      <xsl:when test="name()='toc' and $style-name != ''" >
        <w:pStyle w:val="{$style-name}"/>
      </xsl:when>
	    <xsl:when test="fn:element-type(name())='block' and $all-styles/w:styles/w:style/w:name[@w:val=$style-name]" >
<!-- 	     <xsl:message>here:: <xsl:value-of select="$style-name"/>-><xsl:value-of select="$all-styles/w:styles/w:style[w:name[@w:val=$style-name]]/@w:styleId"/></xsl:message> -->
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
    
</xsl:stylesheet>