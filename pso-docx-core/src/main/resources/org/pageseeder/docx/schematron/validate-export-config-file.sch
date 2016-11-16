<?xml version="1.0" encoding="UTF-8"?>
<?xar Schematron?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            queryBinding="xslt2" >
        <sch:title>Validation for importing docx as PSXML</sch:title>
        <sch:ns prefix="w" uri="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>
        <sch:ns prefix="r" uri="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/>
        <sch:ns prefix="ve" uri="http://schemas.openxmlformats.org/markup-compatibility/2006" />
        <sch:ns prefix="o" uri="urn:schemas-microsoft-com:office:office"/>
        <sch:ns prefix="r" uri="http://schemas.openxmlformats.org/officeDocument/2006/relationships"/> 
        <sch:ns prefix="m" uri="http://schemas.openxmlformats.org/officeDocument/2006/math" /> 
        <sch:ns prefix="v" uri="urn:schemas-microsoft-com:vml" />
        <sch:ns prefix="wp" uri="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" />
        <sch:ns prefix="w10" uri="urn:schemas-microsoft-com:office:word" />
        <sch:ns prefix="w" uri="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>
        <sch:ns prefix="wne" uri="http://schemas.microsoft.com/office/word/2006/wordml"/>
        
    <!-- 
        ==========================================================================
        This schema validates docx for importing as PSXML.
        
        @author Christine Feng
        @author William Liem
        @author Rick Jellife
        @author Philip Rutherford
        @version 23 March 2011
    
        Copyright (C) 2011 Weborganic Systems Pty. Ltd.
        ==========================================================================
     -->
    
    <sch:pattern id="Elements">
        
        
        
                
        <sch:rule context="/">
          <sch:assert test="config" flag="fatal">This document must have as root element 'config' </sch:assert>
        </sch:rule>
        
        <sch:rule context="config">
          <sch:assert test="defaultparagraphstyle"  flag="fatal">This document must have as the element 'defaultparagraphstyle' under config</sch:assert>
          <sch:assert test="defaultcharacterstyle"  flag="fatal">This document must have as the element 'defaultcharacterstyle' under config</sch:assert>
          <sch:assert test="block"                  flag="fatal">This document must have as the element 'block' under config</sch:assert>
          <sch:assert test="inline"                 flag="fatal">This document must have as the element 'inline' under config</sch:assert>
          <sch:assert test="tables"                 flag="fatal">This document must have as the element 'tables' under config</sch:assert>
          <sch:assert test="heading"                flag="fatal">This document must have as the element 'heading' under config</sch:assert>
          <sch:assert test="toc"                    flag="fatal">This document must have as the element 'toc' under config</sch:assert>
          <sch:assert test="xref"                   flag="fatal">This document must have as the element 'xref' under config</sch:assert>
          <sch:assert test="lists"                  flag="fatal">This document must have as the element 'lists' under config</sch:assert>
          <sch:assert test="core"                   flag="fatal">This document must have as the element 'core' under config</sch:assert>
          <sch:assert test="tab"                    flag="fatal">This document must have as the element 'tab' under config</sch:assert>
          <sch:assert test="comments"               flag="fatal">This document must have as the element 'comments' under config</sch:assert>
          <sch:assert test="title"                  flag="fatal">This document must have as the element 'title' under config</sch:assert>
          
        </sch:rule>
         
        <sch:rule context="core">
           <sch:assert test="creator"  flag="fatal">This document must have as the element 'creator'</sch:assert>
          <sch:assert test="subject"  flag="fatal">This document must have as the element 'subject'</sch:assert>
          <sch:assert test="title"  flag="fatal">This document must have as the element 'title'</sch:assert>
          <sch:assert test="description"  flag="fatal">This document must have as the element 'description'</sch:assert>
          <sch:assert test="category"  flag="fatal">This document must have as the element 'category'</sch:assert>
          <sch:assert test="version"  flag="fatal">This document must have as the element 'version'</sch:assert>
          <sch:assert test="revision"  flag="fatal">This document must have as the element 'revision'</sch:assert>
        </sch:rule>
        
        <sch:rule context="core/creator">
          <sch:assert test="@select"  flag="fatal">core/creator must have as the atribute 'select'</sch:assert>
        </sch:rule>
        
        <sch:rule context="core/subject">
          <sch:assert test="@select"  flag="fatal">core/subject must have as the atribute 'select'</sch:assert>
        </sch:rule>
        
        <sch:rule context="core/title">
          <sch:assert test="@select"  flag="fatal">core/title must have as the atribute 'select'</sch:assert>
        </sch:rule>
        
        <sch:rule context="core/description">
          <sch:assert test="@select"  flag="fatal">core/description must have as the atribute 'select'</sch:assert>
        </sch:rule>
        
        <sch:rule context="core/category">
          <sch:assert test="@select"  flag="fatal">core/category must have as the atribute 'select'</sch:assert>
        </sch:rule>
        
        <sch:rule context="core/version">
          <sch:assert test="@select"  flag="fatal">core/version must have as the atribute 'select'</sch:assert>
        </sch:rule>
        
        <sch:rule context="core/revision">
          <sch:assert test="@select"  flag="fatal">core/revision must have as the atribute 'select'</sch:assert>
        </sch:rule>
        
        <sch:rule context="tab">
          <sch:assert test="@label"  flag="fatal">tab must have as the atribute 'label'</sch:assert>
        </sch:rule>
        
        <sch:rule context="tables">
          <sch:assert test="@default"  flag="fatal">tables must have as the atribute 'default'</sch:assert>
        </sch:rule>
        
        <sch:rule context="title">
          <sch:assert test="@name"  flag="fatal">title must have as the atribute 'name'</sch:assert>
        </sch:rule>
        
        <sch:rule context="defaultparagraphstyle">
          <sch:assert test="@style"  flag="fatal">defaultparagraphstyle must have as the atribute 'style'</sch:assert>
        </sch:rule>
        
        <sch:rule context="defaultcharacterstyle">
          <sch:assert test="@style"  flag="fatal">defaultcharacterstyle must have as the atribute 'style'</sch:assert>
        </sch:rule>
        
        <sch:rule context="comments">
          <sch:assert test="@generate"  flag="fatal">comments must have as the atribute 'generate'</sch:assert>
        </sch:rule>
        
        <sch:rule context="block">
          <sch:assert test="@default"  flag="fatal">block must have as the atribute 'default'</sch:assert>
          <sch:assert test="@ignore"  flag="fatal">block must have as the atribute 'ignore'</sch:assert>
        </sch:rule>
        
      
        <sch:rule context="inline">
          <sch:assert test="@default"  flag="fatal">inline must have as the atribute 'default'</sch:assert>
          <sch:assert test="@ignore"  flag="fatal">inline must have as the atribute 'ignore'</sch:assert>
        </sch:rule>
        
        <sch:rule context="block/label">
          <sch:assert test="@name"  flag="fatal">block/label must have as the atribute 'name'</sch:assert>
          <sch:assert test="@style"  flag="fatal">block/label must have as the atribute 'style'</sch:assert>
        </sch:rule>
        
        <sch:rule context="inline/label">
          <sch:assert test="@name or @fieldcode"  flag="fatal">inline/label must have as the atribute 'name' or 'fieldcode'</sch:assert>
          <sch:assert test="@style"  flag="fatal">inline/label must have as the atribute 'style'</sch:assert>
        </sch:rule>
        
        <sch:rule context="heading/style">
          <sch:assert test="@level"  flag="fatal">heading/style must have as the atribute 'level'</sch:assert>
          <sch:assert test="@name"  flag="fatal">heading/style must have as the atribute 'name'</sch:assert>
        </sch:rule>
        
        <sch:rule context="toc">
           <sch:assert test="headings"  flag="fatal">toc must have as the element 'headings'</sch:assert>
          <sch:assert test="outline"  flag="fatal">toc must have as the element 'outline'</sch:assert>
          <sch:assert test="paragraph"  flag="fatal">toc must have as the element 'paragraph'</sch:assert>
          <sch:assert test="@generate"  flag="fatal">toc must have as the atribute 'generate'</sch:assert>
          <sch:assert test="@style"  flag="fatal">toc must have as the atribute 'style'</sch:assert>
        </sch:rule>
        
        <sch:rule context="toc/headings">
          <sch:assert test="@generate"  flag="fatal">toc/headings must have as the atribute 'generate'</sch:assert>
          <sch:assert test="@select"  flag="fatal">toc/headings must have as the atribute 'select'</sch:assert>
        </sch:rule>
        
        <sch:rule context="toc/outline">
          <sch:assert test="@generate"  flag="fatal">toc/outline must have as the atribute 'generate'</sch:assert>
          <sch:assert test="@select"  flag="fatal">toc/outline must have as the atribute 'select'</sch:assert>
        </sch:rule>
        
        <sch:rule context="toc/paragraph">
          <sch:assert test="@generate"  flag="fatal">toc/paragraph must have as the atribute 'generate'</sch:assert>
        </sch:rule>
        
        <sch:rule context="xref">
          <sch:assert test="@default"  flag="fatal">xref must have as the atribute 'default'</sch:assert>
        </sch:rule>
        
        <sch:rule context="tables/style">
          <sch:assert test="@role"  flag="fatal">tables/style must have as the atribute 'role'</sch:assert>
          <sch:assert test="@name"  flag="fatal">tables/style must have as the atribute 'name'</sch:assert>
        </sch:rule>
        
        <sch:rule context="toc/paragraph/type">
          <sch:assert test="@name"  flag="fatal">toc/paragraph/type must have as the atribute 'name'</sch:assert>
          <sch:assert test="@level"  flag="fatal">toc/paragraph/type must have as the atribute 'level'</sch:assert>
        </sch:rule>
 
        
         <!--
        <sch:rule context="lists/list"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/*">
            <sch:report test="true()">[FATAL]:element lists cannot contain element: <sch:value-of select="."/> . It can only contain the elements: list and nlist</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/list/level"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/*">
            <sch:report test="true()">[FATAL]:element list cannot contain element: <sch:value-of select="."/> . It can only contain the elements: level</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/nlist/level"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/*">
            <sch:report test="true()">[FATAL]:element nlist cannot contain element: <sch:value-of select="."/> . It can only contain the elements: level</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/list/@name"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/@style"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/*@">
            <sch:report test="true()">[FATAL]:element list cannot contain attribute: <sch:value-of select="."/> . It can only contain the attributes: name and style</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/nlist/@name"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/@style"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/*@">
            <sch:report test="true()">[FATAL]:element nlist cannot contain attribute: <sch:value-of select="."/> . It can only contain the attributes: name and style</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/list/level/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/*@">
            <sch:report test="true()">[FATAL]:element level cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/list/level/left-indent"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/right-indent"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/hanging"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/format"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/start"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/paragraphstyle"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/justification"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/levelText"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/*">
            <sch:report test="true()">[FATAL]:element lists cannot contain element: <sch:value-of select="."/> . It can only contain the elements: list and nlist</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/list/level/left-indent/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/left-indent/*@">
            <sch:report test="true()">[FATAL]:element left-indent cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/list/level/right-indent/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/right-indent/*@">
            <sch:report test="true()">[FATAL]:element right-indent cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/list/level/hanging/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/hanging/*@">
            <sch:report test="true()">[FATAL]:element hanging cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/list/level/format/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/format/*@">
            <sch:report test="true()">[FATAL]:element format cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/list/level/start/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/start/*@">
            <sch:report test="true()">[FATAL]:element start cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/list/level/paragraphstyle/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/paragraphstyle/@select"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/paragraphstyle/*@">
            <sch:report test="true()">[FATAL]:element paragraphstyle cannot contain attribute: <sch:value-of select="."/> . It can only contain the attributes: value and select</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/list/level/justification/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/justification/*@">
            <sch:report test="true()">[FATAL]:element justification cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/list/level/levelText/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/list/level/levelText/*@">
            <sch:report test="true()">[FATAL]:element levelText cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/nlist/level/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/*@">
            <sch:report test="true()">[FATAL]:element level cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/nlist/level/left-indent"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/right-indent"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/hanging"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/format"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/start"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/paragraphstyle"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/justification"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/levelText"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/*">
            <sch:report test="true()">[FATAL]:element lists cannot contain element: <sch:value-of select="."/> . It can only contain the elements: list and nlist</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/nlist/level/left-indent/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/left-indent/*@">
            <sch:report test="true()">[FATAL]:element left-indent cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/nlist/level/right-indent/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/right-indent/*@">
            <sch:report test="true()">[FATAL]:element right-indent cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/nlist/level/hanging/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/hanging/*@">
            <sch:report test="true()">[FATAL]:element hanging cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/nlist/level/format/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/format/*@">
            <sch:report test="true()">[FATAL]:element format cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/nlist/level/start/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/start/*@">
            <sch:report test="true()">[FATAL]:element start cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/nlist/level/paragraphstyle/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/paragraphstyle/@select"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/paragraphstyle/*@">
            <sch:report test="true()">[FATAL]:element paragraphstyle cannot contain attribute: <sch:value-of select="."/> . It can only contain the attributes: value and select</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/nlist/level/justification/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/justification/*@">
            <sch:report test="true()">[FATAL]:element justification cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        
        <sch:rule context="lists/nlist/level/levelText/@value"><sch:assert test="true()"/></sch:rule>
        <sch:rule context="lists/nlist/level/levelText/*@">
            <sch:report test="true()">[FATAL]:element levelText cannot contain attribute: <sch:value-of select="."/> . It can only contain the attribute: value</sch:report>
        </sch:rule>
        -->
    </sch:pattern>
</sch:schema>
