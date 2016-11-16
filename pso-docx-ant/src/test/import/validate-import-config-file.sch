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
        
        @author Hugo Inacio
        @version 23 March 2011
    
        Copyright (C) 2011 Weborganic Systems Pty. Ltd.
        ==========================================================================
     -->
    
    <sch:pattern id="Elements">
        
        
        
                
        <!-- 
              Table and contents of tables rules
        -->
        <sch:rule context="/">
          <sch:assert test="config" flag="fatal">This document must have as root element 'config' </sch:assert>
        </sch:rule>
        
        <sch:rule context="config">
          <sch:assert test="styles"             flag="fatal">This document must have as the element 'styles' under config</sch:assert>
          <sch:assert test="numbering"          flag="fatal">This document must have as the element 'numbering' under config</sch:assert>
          <sch:assert test="split"              flag="fatal">This document must have as the element 'split' under config</sch:assert>
          <sch:assert test="toc"                flag="fatal">This document must have as the element 'toc' under config</sch:assert>
          <sch:assert test="number-paragraphs"  flag="fatal">This document must have as the element 'number-paragraphs' under config</sch:assert>
        </sch:rule>
        
        
        
        <sch:rule context="split">
          <sch:assert test="document">This document must have as the element 'document' under split</sch:assert>
          <sch:assert test="section">This document must have as the element 'section' under split</sch:assert>
        </sch:rule>
        
        
        
        <sch:rule context="split/document">
          <sch:assert test="type">This document must have as the element 'type' under split/document</sch:assert>
        </sch:rule>
        
        <sch:rule context="split/section">
          <sch:assert test="type">This document must have as the element 'type' under split/section</sch:assert>
        </sch:rule>
        
        <sch:rule context="split/document/type">
          <sch:assert test="@name">This document must have as the attribute 'name' under split/document/type</sch:assert>
          <sch:assert test="@select">This document must have as the attribute 'select' under split/document/type</sch:assert>
          <sch:assert test="matches(@name,'style|outlineLevel|sectionBreak')">The attribute 'name' under split/document/type must contain the value 'style' or 'outlineLevel' or 'sectionBreak'</sch:assert>
          <sch:assert test="not(@name = 'sectionBreak') or matches(@select,'([continuous|evenPage|oddPage|\|]*)')">[FATAL]:attribute select can only contain : 'continuous' or 'evenPage' or 'oddPage' or '|'</sch:assert>
          <sch:assert test="not(@name = 'outlineLevel') or matches(@select,'([0-8\-\|]*)')">[FATAL]:attribute select can only contain : '0-8' or '|'</sch:assert>
        </sch:rule>
                
        <sch:rule context="split/section/type">
          <sch:assert test="@name">This document must have as the attribute 'name' under split/section/type</sch:assert>
          <sch:assert test="@select">This document must have as the attribute 'select' under split/section/type</sch:assert>
		      <sch:assert test="matches(@name,'style|outlineLevel|sectionBreak')">The attribute 'name' under split/section/type must contain the value 'style' or 'outlineLevel' or 'sectionBreak'</sch:assert>
		      <sch:assert test="not(@name = 'sectionBreak') or matches(@select,'([continuous|evenPage|oddPage|\|]*)')">[FATAL]:attribute select can only contain : 'continuous' or 'evenPage' or 'oddPage' or '|'</sch:assert>
		      <sch:assert test="not(@name = 'outlineLevel') or matches(@select,'([0-8\-\|]*)')">[FATAL]:attribute select can only contain : '0-8' or '|'</sch:assert>
        </sch:rule>
                
        <sch:rule context="styles">
          <sch:assert test="default">This document must have as the element 'default' under styles</sch:assert>
          <sch:assert test="smart-tag">This document must have as the element 'smart-tag' under styles</sch:assert>
          <!-- ignore ?-->
        </sch:rule>
        
        <sch:rule context="styles/default">
          <sch:assert test="property">This document must have as the element 'property' under styles/default</sch:assert>
        </sch:rule>
        
        <sch:rule context="styles/default/property">
          <sch:assert test="@name">This document must have as the attribute 'name' under styles/default/property</sch:assert>
          <sch:assert test="@value">This document must have as the attribute 'value' under styles/default/property</sch:assert>
		      <sch:assert test="matches(@name,'paragraphStyles|prefix|characterStyles')">The attribute 'name' under styles/default/property must contain the value 'paragraphStyles' or 'prefix' or 'characterStyles'</sch:assert>
		      
		      <sch:assert test="not(@name='paragraphStyles') or matches(@value,'(^block$|^para$)')">[FATAL]:attribute value can only contain : 'block' or 'para'</sch:assert>
		      <sch:assert test="not(@name='characterStyles') or matches(@value,'(^inlineLabel$|^none$)')">[FATAL]:attribute value can only contain : 'inlineLabel' or 'none'</sch:assert>
		      <sch:assert test="not(@name='prefix') or matches(@value,'(^false$|^true$)')">[FATAL]:attribute value can only contain : 'false' or 'true'</sch:assert>
		    </sch:rule>
        
        <sch:rule context="styles/smart-tag">
          <sch:assert test="@keep">styles/smart-tag must contain the attribute 'keep'</sch:assert>
          <sch:assert test="matches(@keep,'(^false$|^true$)')">attribute keep can only contain : 'false' or 'true'</sch:assert>
        </sch:rule>
        
        <sch:rule context="styles/element">
          <sch:assert test="@name">styles/element must contain the attribute 'name'</sch:assert>
          <sch:assert test="property[@name = 'style']">styles/element must contain the element 'property'</sch:assert>
          <sch:assert test="not(property[@name='style'][@value='heading']) or property[@name = 'level']">elements transformed into 'heading' must have a property with a level attribute</sch:assert>
          <sch:assert test="not(property[@name='style'][@value='heading']) or  matches(property[@name = 'level']/@value,'([1-6])')">only 1-6 heading values are valid</sch:assert> 
        
        </sch:rule>
        
        <sch:rule context="styles/element/property">
          <sch:assert test="@name">styles/element/property must contain the attribute 'name'</sch:assert>
          <sch:assert test="@value">styles/element/property must contain the attribute 'value'</sch:assert>
          </sch:rule>
        
        <sch:rule context="numbering">
          <sch:assert test="@select">numbering must contain the attribute 'select'</sch:assert>
          <sch:assert test="matches(@select,'(^false$|^true$)')">attribute select can only contain : 'false' or 'true'</sch:assert>
        </sch:rule>
        
        <sch:rule context="numbering/value">
          <sch:assert test="@match">numbering/value must contain the attribute 'match'</sch:assert>
          <sch:assert test="element">numbering/value must contain the element 'element'</sch:assert>
        </sch:rule>
        
        <sch:rule context="numbering/value/element">
          <sch:assert test="@name">numbering/value/element must contain the attribute 'name'</sch:assert>
          <sch:assert test="@value">numbering/value/element must contain the attribute 'value'</sch:assert>
        </sch:rule>
        
        <sch:rule context="style/ignore">
          <sch:assert test="@name">style/ignore must contain the attribute 'name'</sch:assert>
        </sch:rule>
        
        <sch:rule context="element">
          <sch:assert test="@name">style/ignore must contain the attribute 'name'</sch:assert>
        </sch:rule>
        
    </sch:pattern>
</sch:schema>
