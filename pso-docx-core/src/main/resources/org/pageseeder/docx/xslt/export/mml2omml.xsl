<?xml version="1.0" encoding="utf-8"?>
<!--
  XSLT module for processing MathML

  This is a slightly modified version of a file that came from the Microsoft Office Open SDK
  and a copy of the latest version can be found on `c:/Program Files (x86)/Microsoft Office/Office[version]`

  NB Beta Version 070708

  @author Christophe Lauret
  @author Philip Rutherford
  @author Hugo Inacio
-->
<xsl:stylesheet xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mml="http://www.w3.org/1998/Math/MathML"
                xmlns="http://schemas.openxmlformats.org/officeDocument/2006/math"
                xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"
                version="2.0"
                exclude-result-prefixes="mml m w">

<!-- TODO This looks like XSLT1.0 style code copied and pasted from another project -->

<!-- TODO This is useless -->
<xsl:output method="xml" encoding="UTF-8"/>


<xsl:variable name="StrUCAlphabet">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
<xsl:variable name="StrLCAlphabet">abcdefghijklmnopqrstuvwxyz</xsl:variable>

<!-- initial match to mathml -->
<xsl:template match="m:math">
  <m:oMath>
      <xsl:apply-templates mode="mml"/>
  </m:oMath>
</xsl:template>

<!-- %%Template: SReplace

  Replace all occurences of sOrig in sInput with sReplacement
  and return the resulting string. -->
<xsl:template name="SReplace">
    <xsl:param name="sInput"/>
    <xsl:param name="sOrig"/>
    <xsl:param name="sReplacement"/>

    <xsl:choose>
       <xsl:when test="not(contains($sInput, $sOrig))">
          <xsl:value-of select="$sInput"/>
       </xsl:when>
       <xsl:otherwise>
          <xsl:variable name="sBefore" select="substring-before($sInput, $sOrig)"/>
          <xsl:variable name="sAfter" select="substring-after($sInput, $sOrig)"/>
          <xsl:variable name="sAfterProcessed">
             <xsl:call-template name="SReplace">
                <xsl:with-param name="sInput" select="$sAfter"/>
                <xsl:with-param name="sOrig" select="$sOrig"/>
                <xsl:with-param name="sReplacement" select="$sReplacement"/>
             </xsl:call-template>
          </xsl:variable>

          <xsl:value-of select="concat($sBefore, concat($sReplacement, $sAfterProcessed))"/>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- %%Template: OutputText

  Post processing on the string given and otherwise do
  a xsl:value-of on it -->
<xsl:template name="OutputText">
    <xsl:param name="sInput"/>

    <!-- Add local Variable as you add new post processing tasks -->

  <!-- 1. Remove any unwanted characters -->
  <xsl:variable name="sCharStrip">
       <xsl:value-of select="translate($sInput, '⁢​', '')"/>
    </xsl:variable>

    <!-- 2. Replace any characters as needed -->
  <!--  Replace &#x2A75; <-> ==      -->
  <xsl:variable name="sCharReplace">
       <xsl:call-template name="SReplace">
          <xsl:with-param name="sInput" select="$sCharStrip"/>
          <xsl:with-param name="sOrig" select="'⩵'"/>
          <xsl:with-param name="sReplacement" select="'=='"/>
       </xsl:call-template>
    </xsl:variable>

    <!-- Finally, return the last value -->
  <xsl:value-of select="$sCharReplace"/>
</xsl:template>


<!-- Template that determines whether or the given node
     ndCur is a token element that doesn't have an mglyph as
     a child.
-->
<xsl:template name="FNonGlyphToken">
    <xsl:param name="ndCur" select="."/>
    <xsl:choose>
       <xsl:when test="$ndCur/self::mi[not(child::mglyph)] | $ndCur/self::mn[not(child::mglyph)] | $ndCur/self::mo[not(child::mglyph)] | $ndCur/self::ms[not(child::mglyph)] | $ndCur/self::mtext[not(child::mglyph)]">1</xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Template used to determine if the current token element (ndCur) is the beginning of a run.
     A token element is the beginning of if:

     the count of preceding elements is 0
     or
     the directory preceding element is not a non-glyph token.
-->
<xsl:template name="FStartOfRun">
    <xsl:param name="ndCur" select="."/>
    <xsl:variable name="fPrecSibNonGlyphToken">
       <xsl:call-template name="FNonGlyphToken">
          <xsl:with-param name="ndCur" select="$ndCur/preceding-sibling::*[1]"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
       <xsl:when test="count($ndCur/preceding-sibling::*)=0             or $fPrecSibNonGlyphToken=0">1</xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Template that determines if ndCur is the argument of an nary expression.

     ndCur is the argument of an nary expression if:

     1.  The preceding sibling is one of the following:  munder, mover, msub, msup, munder, msubsup, munderover
     and
     2.  The preceding sibling's child is an nary char as specified by the template "isNary"
-->
<xsl:template name="FIsNaryArgument">
    <xsl:param name="ndCur" select="."/>

    <xsl:variable name="fNary">
       <xsl:call-template name="isNary">
          <xsl:with-param name="ndCur" select="$ndCur/preceding-sibling::*[1]/child::*[1]"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
       <xsl:when test="preceding-sibling::*[1][self::munder or self::mover or self::munderover or self::msub or self::msup or self::msubsup] and $fNary='true'">1</xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- %%Template: mrow | mstyle

   if this row is the next sibling of an n-ary (i.e. any of
       mover, munder, munderover, msupsub, msup, or msub with
       the base being an n-ary operator) then ignore this. Otherwise
       pass through -->
<xsl:template mode="mml" match="mrow|mstyle">
    <xsl:variable name="fNaryArgument">
       <xsl:call-template name="FIsNaryArgument">
          <xsl:with-param name="ndCur" select="."/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$fNaryArgument=0">
       <xsl:variable name="fLinearFrac">
          <xsl:call-template name="FLinearFrac">
             <xsl:with-param name="ndCur" select="."/>
          </xsl:call-template>
       </xsl:variable>
       <xsl:choose>
          <xsl:when test="$fLinearFrac=1">
             <xsl:call-template name="MakeLinearFraction">
                <xsl:with-param name="ndCur" select="."/>
             </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
             <xsl:variable name="fFunc">
                <xsl:call-template name="FIsFunc">
                   <xsl:with-param name="ndCur" select="."/>
                </xsl:call-template>
             </xsl:variable>
             <xsl:choose>
                <xsl:when test="$fFunc=1">
                   <xsl:call-template name="WriteFunc">
                      <xsl:with-param name="ndCur" select="."/>
                   </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:apply-templates mode="mml"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:if>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template mode="mml"
               match="mi[not(child::mglyph)] | mn[not(child::mglyph)] | mo[not(child::mglyph)] | ms[not(child::mglyph)] | mtext[not(child::mglyph)]">

  <!-- tokens with mglyphs as children are tranformed
     in a different manner than "normal" token elements.
     Where normal token elements are token elements that
     contain only text -->
  <xsl:variable name="fStartOfRun">
       <xsl:call-template name="FStartOfRun">
          <xsl:with-param name="ndCur" select="."/>
       </xsl:call-template>
    </xsl:variable>

    <!--In MathML, successive characters that are all part of one string are sometimes listed as separate
    tags based on their type (identifier (mi), name (mn), operator (mo), quoted (ms), literal text (mtext)),
    where said tags act to link one another into one logical run.  In order to wrap the text of successive mi's,
    mn's, and mo's into one t, we need to denote where a run begins.  The beginning of a run is the first mi, mn,
    or mo whose immediately preceding sibling either doesn't exist or is something other than a "normal" mi, mn, mo,
    ms, or mtext tag-->

  <!-- If this mi/mo/mn/ms . . . is part the numerator or denominator of a linear fraction, then don't collect. -->
  <xsl:variable name="fLinearFracParent">
       <xsl:call-template name="FLinearFrac">
          <xsl:with-param name="ndCur" select="parent::*"/>
       </xsl:call-template>
    </xsl:variable>
    <!-- If this mi/mo/mn/ms . . . is part of the name of a function, then don't collect. -->
  <xsl:variable name="fFunctionName">
       <xsl:call-template name="FIsFunc">
          <xsl:with-param name="ndCur" select="parent::*"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="fShouldCollect"
                  select="($fLinearFracParent=0 and $fFunctionName=0) and (parent::mrow or parent::mstyle or parent::msqrt or parent::menclose or      parent::math or parent::mphantom or parent::mtd or parent::maction)"/>

    <!--In MathML, the meaning of the different parts that make up mathematical structures, such as a fraction
    having a numerator and a denominator, is determined by the relative order of those different parts.
    For instance, In a fraction, the numerator is the first child and the denominator is the second child.
    To allow for more complex structures, MathML allows one to link a group of mi, mn, and mo's together
    using the mrow, or mstyle tags.  The mi, mn, and mo's found within any of the above tags are considered
    one run.  Therefore, if the parent of any mi, mn, or mo is found to be an mrow or mstyle, then the contiguous
    mi, mn, and mo's will be considered one run.-->
  <xsl:choose>
       <xsl:when test="$fShouldCollect">
          <xsl:choose>
             <xsl:when test="$fStartOfRun=1">
          <!--If this is the beginning of the run, pass all run attributes to CreateRunWithSameProp.-->
          <xsl:call-template name="CreateRunWithSameProp">
                   <xsl:with-param name="mathbackground">
              <!-- Look for the unqualified mathml attribute mathbackground.
                   Fall back to the qualified mathml attribute if necessary.
                   This priority of unqualified over qualified will be
                   followed throughout this xslt. -->
              <xsl:choose>
                         <xsl:when test="@mathbackground">
                            <xsl:value-of select="@mathbackground"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="@mathbackground"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:with-param>
                   <xsl:with-param name="mathcolor">
                      <xsl:choose>
                         <xsl:when test="@mathcolor">
                            <xsl:value-of select="@mathcolor"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="@mathcolor"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:with-param>
                   <xsl:with-param name="mathvariant">
                      <xsl:choose>
                         <xsl:when test="@mathvariant">
                            <xsl:value-of select="@mathvariant"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="@mathvariant"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:with-param>
                   <xsl:with-param name="color">
                      <xsl:choose>
                         <xsl:when test="@color">
                            <xsl:value-of select="@color"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="@color"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:with-param>
                   <xsl:with-param name="font-family">
                      <xsl:choose>
                         <xsl:when test="@font-family">
                            <xsl:value-of select="@font-family"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="@font-family"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:with-param>
                   <xsl:with-param name="fontsize">
                      <xsl:choose>
                         <xsl:when test="@fontsize">
                            <xsl:value-of select="@fontsize"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="@fontsize"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:with-param>
                   <xsl:with-param name="fontstyle">
                      <xsl:choose>
                         <xsl:when test="@fontstyle">
                            <xsl:value-of select="@fontstyle"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="@fontstyle"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:with-param>
                   <xsl:with-param name="fontweight">
                      <xsl:choose>
                         <xsl:when test="@fontweight">
                            <xsl:value-of select="@fontweight"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="@fontweight"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:with-param>
                   <xsl:with-param name="mathsize">
                      <xsl:choose>
                         <xsl:when test="@mathsize">
                            <xsl:value-of select="@mathsize"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="@m:mathsize"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:with-param>
                   <xsl:with-param name="ndTokenFirst" select="."/>
                </xsl:call-template>
             </xsl:when>
          </xsl:choose>
       </xsl:when>
       <xsl:otherwise>
      <!--Only one element will be part of run-->
      <m:r>
        <!--Create Run Properties based on current node's attributes-->
        <xsl:call-template name="CreateRunProp">
                <xsl:with-param name="mathvariant">
                   <xsl:choose>
                      <xsl:when test="@mathvariant">
                         <xsl:value-of select="@mathvariant"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@mathvariant"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="fontstyle">
                   <xsl:choose>
                      <xsl:when test="@fontstyle">
                         <xsl:value-of select="@fontstyle"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@fontstyle"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="fontweight">
                   <xsl:choose>
                      <xsl:when test="@fontweight">
                         <xsl:value-of select="@fontweight"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@fontweight"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="mathcolor">
                   <xsl:choose>
                      <xsl:when test="@mathcolor">
                         <xsl:value-of select="@mathcolor"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@mathcolor"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="mathsize">
                   <xsl:choose>
                      <xsl:when test="@mathsize">
                         <xsl:value-of select="@mathsize"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@mathsize"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="color">
                   <xsl:choose>
                      <xsl:when test="@color">
                         <xsl:value-of select="@color"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@color"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="fontsize">
                   <xsl:choose>
                      <xsl:when test="@fontsize">
                         <xsl:value-of select="@fontsize"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@fontsize"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="ndCur" select="."/>
                <xsl:with-param name="fNor">
                   <xsl:call-template name="FNor">
                      <xsl:with-param name="ndCur" select="."/>
                   </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="fLit">
                   <xsl:call-template name="FLit">
                      <xsl:with-param name="ndCur" select="."/>
                   </xsl:call-template>
                </xsl:with-param>
             </xsl:call-template>
             <m:t>
                <xsl:call-template name="OutputText">
                   <xsl:with-param name="sInput" select="normalize-space(.)"/>
                </xsl:call-template>
             </m:t>
          </m:r>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- %%Template: CreateRunWithSameProp
-->
<xsl:template name="CreateRunWithSameProp">
    <xsl:param name="mathbackground"/>
    <xsl:param name="mathcolor"/>
    <xsl:param name="mathvariant"/>
    <xsl:param name="color"/>
    <xsl:param name="font-family"/>
    <xsl:param name="fontsize"/>
    <xsl:param name="fontstyle"/>
    <xsl:param name="fontweight"/>
    <xsl:param name="mathsize"/>
    <xsl:param name="ndTokenFirst"/>

    <!--Given mathcolor, color, mstyle's (ancestor) color, and precedence of
    said attributes, determine the actual color of the current run-->
  <xsl:variable name="sColorPropCur">
       <xsl:choose>
          <xsl:when test="$mathcolor!=''">
             <xsl:value-of select="$mathcolor"/>
          </xsl:when>
          <xsl:when test="$color!=''">
             <xsl:value-of select="$color"/>
          </xsl:when>
          <xsl:when test="$ndTokenFirst/ancestor::mstyle[@color][1]/@color!=''">
             <xsl:value-of select="$ndTokenFirst/ancestor::mstyle[@color][1]/@color"/>
          </xsl:when>
          <xsl:when test="$ndTokenFirst/ancestor::mstyle[@color][1]/@color!=''">
             <xsl:value-of select="$ndTokenFirst/ancestor::mstyle[@color][1]/@color"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="''"/>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:variable>

    <!--Given mathsize, and fontsize and precedence of said attributes,
    determine the actual font size of the current run-->
  <xsl:variable name="sSzCur">
       <xsl:choose>
          <xsl:when test="$mathsize!=''">
             <xsl:value-of select="$mathsize"/>
          </xsl:when>
          <xsl:when test="$fontsize!=''">
             <xsl:value-of select="$fontsize"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="''"/>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:variable>

    <!--Given mathvariant, fontstyle, and fontweight, and precedence of
    the attributes, determine the actual font of the current run-->
  <xsl:variable name="sFontCur">
       <xsl:call-template name="GetFontCur">
          <xsl:with-param name="mathvariant" select="$mathvariant"/>
          <xsl:with-param name="fontstyle" select="$fontstyle"/>
          <xsl:with-param name="fontweight" select="$fontweight"/>
          <xsl:with-param name="ndCur" select="$ndTokenFirst"/>
       </xsl:call-template>
    </xsl:variable>

    <!-- The omml equivalent structure for mtext is an omml run with the run property nor (normal) set.
       Therefore, we can only collect mtexts with  other mtext elements.  Suppose the $ndTokenFirst is an
       mtext, then if any of its following siblings are to be grouped, they must also be text elements.
       The inverse is also true, suppose the $ndTokenFirst isn't an mtext, then if any of its following siblings
       are to be grouped with $ndTokenFirst, they can't be mtext elements-->
  <xsl:variable name="fNdTokenFirstIsMText">
       <xsl:choose>
          <xsl:when test="$ndTokenFirst/self::mtext">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
       </xsl:choose>
    </xsl:variable>

    <!--In order to determine the length of the run, we will find the number of nodes before the inital node in the run and
    the number of nodes before the first node that DOES NOT belong to the current run.  The number of nodes that will
    be printed is One Less than the difference between the latter and the former-->

  <!--Find index of current node-->
  <xsl:variable name="nndBeforeFirst" select="count($ndTokenFirst/preceding-sibling::*)"/>

    <!--Find index of next change in run properties.

      The basic idea is that we want to find the position of the last node in the longest
      sequence of nodes, starting from ndTokenFirst, that can be grouped into a run.  For
      example, nodes A and B can be grouped together into the same run iff they have the same
      props.

      To accomplish this grouping, we want to find the next sibling to ndTokenFirst that shouldn't be
      included in the run of text.  We do this by counting the number of elements that precede the first
      such element that doesn't belong.  The xpath that accomplishes this is below.

          Count the number of siblings the precede the first element after ndTokenFirst that shouldn't belong.
          count($ndTokenFirst/following-sibling::*[ . . . ][1]/preceding-sibling::*)

      Now, the hard part to this is what is represented by the '. . .' above.  This conditional expression is
      defining what elements *don't* belong to the current run.  The conditions are as follows:

      The element is not a token element (mi, mn, mo, ms, or mtext)

      or

      The token element contains a glyph child (this is handled separately).

      or

      The token is an mtext and the run didn't start with an mtext, or the token isn't an mtext and the run started
      with an mtext.  We do this check because mtext transforms into an omml nor property, and thus, these mtext
      token elements need to be grouped separately from other token elements.

      // We do an or not( . . . ), because it was easier to define what token elements match than how they don't match.
      // Thus, this inner '. . .' defines how token attributes equate to one another.  We add the 'not' outside of to accomplish
      // the goal of the outer '. . .', which is the find the next element that *doesn't* match.
      or not(
         The background colors match.

         and

            The current font (sFontCur) matches the mathvariant

            or

            sFontCur is normal and matches the current font characteristics

            or

            sFontCur is italic and matches the current font characteristics

            or

            . . .

         and

         The font family matches the current font family.
         ) // end of not().-->
  <xsl:variable name="nndBeforeLim"
                  select="count($ndTokenFirst/following-sibling::*[(not(self::mi) and not(self::mn) and not(self::mo) and not(self::ms) and not(self::mtext)) or (self::mi[child::mglyph] or self::mn[child::mglyph] or self::mo[child::mglyph] or self::ms[child::mglyph] or self::mtext[child::mglyph]) or (($fNdTokenFirstIsMText=1 and not(self::mtext)) or ($fNdTokenFirstIsMText=0 and self::mtext)) or not(((($sFontCur=@mathvariant or $sFontCur=@mathvariant) or ($sFontCur='normal' and ((@mathvariant='normal' or @mathvariant='normal') or (((not(@mathvariant) or @mathvariant='') and (not(@mathvariant) or @mathvariant=''))              and (                     ((@fontstyle='normal' or @fontstyle='normal') and (not(@fontweight='bold') and not(@fontweight='bold')))                     or (self::mi and string-length(normalize-space(.)) &gt; 1)                    )               )           )        )        or        ($sFontCur='italic'          and ((@mathvariant='italic' or @mathvariant='italic')            or (((not(@mathvariant) or @mathvariant='') and (not(@mathvariant) or @mathvariant=''))             and (                     ((@fontstyle='italic' or @fontstyle='italic') and (not(@fontweight='bold') and not(@fontweight='bold')))                    or                  (self::mn                  or self::mo                 or (self::mi and string-length(normalize-space(.)) &lt;= 1))                    )               )           )        )         or        ($sFontCur='bold'         and ((@mathvariant='bold' or @mathvariant='bold')            or (((not(@mathvariant) or @mathvariant='') and (not(@mathvariant) or @mathvariant=''))                and (                     ((@fontweight='bold' or @fontweight='bold')                     and ((@fontstyle='normal' or @fontstyle='normal') or (self::mi and string-length(normalize-space(.)) &lt;= 1))                    )               )             )             )        )         or        (($sFontCur='bi' or $sFontCur='bold-italic')         and (            (@mathvariant='bold-italic' or @mathvariant='bold-italic')            or (((not(@mathvariant) or @mathvariant='') and (not(@mathvariant) or @mathvariant=''))             and (                ((@fontweight='bold' or @fontweight='bold') and (@fontstyle='italic' or @fontstyle='italic'))                or ((@fontweight='bold' or @fontweight='bold')                   and (self::mn                       or self::mo                     or (self::mi and string-length(normalize-space(.)) &lt;= 1)))                    )               )           )        )               or               (($sFontCur=''                   and (                      ((not(@mathvariant) or @mathvariant='')                         and (not(@mathvariant) or @mathvariant='')                         and (not(@fontstyle) or @fontstyle='')                         and (not(@fontstyle) or @fontstyle='')                         and (not(@fontweight)or @fontweight='')                         and (not(@fontweight) or @fontweight='')                 )                        or                          (@mathvariant='italic' or @mathvariant='italic')                         or (                            ((not(@mathvariant) or @mathvariant='') and (not(@mathvariant) or @mathvariant=''))                                and (                                   (((@fontweight='normal' or @fontweight='normal')                                    and (@fontstyle='italic' or @fontstyle='italic'))                                   )                                   or                                   ((not(@fontweight) or @fontweight='') and (not(@fontweight) or @fontweight=''))                                    and (@fontstyle='italic' or @fontstyle='italic')                                   or                                   ((not(@fontweight) or @fontweight='') and (not(@fontweight) or @fontweight=''))                                    and (not(@fontstyle) or @fontstyle='') and (not(@fontstyle) or @fontstyle=''))                             )                 )                )) or ($sFontCur='normal' and ((self::mi and (not(@mathvariant) or @mathvariant='') and (not(@mathvariant) or @mathvariant) and (not(@fontstyle) or @fontstyle='') and (not(@fontstyle) or @fontstyle='') and (not(@fontweight) or @fontweight='') and (not(@fontweight) or @fontweight='') and (string-length(normalize-space(.)) &gt; 1)) or ((self::ms or self::mtext) and (not(@mathvariant) or @mathvariant='') and (not(@mathvariant) or @mathvariant) and (not(@fontstyle) or @fontstyle) and (not(@fontstyle) or @fontstyle='') and (not(@fontweight) or @fontweight) and (not(@fontweight) or @fontweight=''))))) and (($font-family = @font-family or $font-family = @font-family) or (($font-family='' or not($font-family)) and (not(@font-family) or @font-family='') and (not(@font-family) or @font-family='')))))][1]/preceding-sibling::*)"/>

    <xsl:variable name="cndRun" select="$nndBeforeLim - $nndBeforeFirst"/>

    <!--Contiguous groups of like-property mi, mn, and mo's are separated by non- mi, mn, mo tags, or mi,mn, or mo
    tags with different properties.  nndBeforeLim is the number of nodes before the next tag which separates contiguous
    groups of like-property mi, mn, and mo's.  Knowing this delimiting tag allows for the aggregation of the correct
    number of mi, mn, and mo tags.-->
  <m:r>

    <!--The beginning and ending of the current run has been established. Now we should open a run element-->
    <xsl:choose>

      <!--If cndRun > 0, then there is a following diffrent prop, or non- Token,
          although there may or may not have been a preceding different prop, or non-
          Token-->
      <xsl:when test="$cndRun &gt; 0">
             <xsl:call-template name="CreateRunProp">
                <xsl:with-param name="mathvariant" select="$mathvariant"/>
                <xsl:with-param name="fontstyle" select="$fontstyle"/>
                <xsl:with-param name="fontweight" select="$fontweight"/>
                <xsl:with-param name="mathcolor" select="$mathcolor"/>
                <xsl:with-param name="mathsize" select="$mathsize"/>
                <xsl:with-param name="color" select="$color"/>
                <xsl:with-param name="fontsize" select="$fontsize"/>
                <xsl:with-param name="ndCur" select="$ndTokenFirst"/>
                <xsl:with-param name="fNor">
                   <xsl:call-template name="FNor">
                      <xsl:with-param name="ndCur" select="$ndTokenFirst"/>
                   </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="fLit">
                   <xsl:call-template name="FLit">
                      <xsl:with-param name="ndCur" select="$ndTokenFirst"/>
                   </xsl:call-template>
                </xsl:with-param>
             </xsl:call-template>
             <m:t>
                <xsl:call-template name="OutputText">
                   <xsl:with-param name="sInput">
                      <xsl:choose>
                         <xsl:when test="namespace-uri($ndTokenFirst) = 'http://www.w3.org/1998/Math/MathML' and local-name($ndTokenFirst) = 'ms'">
                            <xsl:call-template name="OutputMs">
                               <xsl:with-param name="msCur" select="$ndTokenFirst"/>
                            </xsl:call-template>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="normalize-space($ndTokenFirst)"/>
                         </xsl:otherwise>
                      </xsl:choose>
                      <xsl:for-each select="$ndTokenFirst/following-sibling::*[position() &lt; $cndRun]">
                         <xsl:choose>
                            <xsl:when test="namespace-uri(.) = 'http://www.w3.org/1998/Math/MathML' and local-name(.) = 'ms'">
                               <xsl:call-template name="OutputMs">
                                  <xsl:with-param name="msCur" select="."/>
                               </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                               <xsl:value-of select="normalize-space(.)"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </xsl:for-each>
                   </xsl:with-param>
                </xsl:call-template>
             </m:t>
          </xsl:when>
          <xsl:otherwise>

        <!--if cndRun lt;= 0, then iNextNonToken = 0,
          and iPrecNonToken gt;= 0.  In either case, b/c there
          is no next different property or non-Token
          (which is implied by the nndBeforeLast being equal to 0)
          you can put all the remaining mi, mn, and mo's into one
          group.-->
        <xsl:call-template name="CreateRunProp">
                <xsl:with-param name="mathvariant" select="$mathvariant"/>
                <xsl:with-param name="fontstyle" select="$fontstyle"/>
                <xsl:with-param name="fontweight" select="$fontweight"/>
                <xsl:with-param name="mathcolor" select="$mathcolor"/>
                <xsl:with-param name="mathsize" select="$mathsize"/>
                <xsl:with-param name="color" select="$color"/>
                <xsl:with-param name="fontsize" select="$fontsize"/>
                <xsl:with-param name="ndCur" select="$ndTokenFirst"/>
                <xsl:with-param name="fNor">
                   <xsl:call-template name="FNor">
                      <xsl:with-param name="ndCur" select="$ndTokenFirst"/>
                   </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="fLit">
                   <xsl:call-template name="FLit">
                      <xsl:with-param name="ndCur" select="$ndTokenFirst"/>
                   </xsl:call-template>
                </xsl:with-param>
             </xsl:call-template>
             <m:t>

          <!--Create the Run, first output current, then in a
            for-each, because all the following siblings are
            mn, mi, and mo's that conform to the run's properties,
            group them together-->
          <xsl:call-template name="OutputText">
                   <xsl:with-param name="sInput">
                      <xsl:choose>
                         <xsl:when test="namespace-uri($ndTokenFirst) = 'http://www.w3.org/1998/Math/MathML' and local-name($ndTokenFirst) = 'ms'">
                            <xsl:call-template name="OutputMs">
                               <xsl:with-param name="msCur" select="$ndTokenFirst"/>
                            </xsl:call-template>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="normalize-space($ndTokenFirst)"/>
                         </xsl:otherwise>
                      </xsl:choose>
                      <xsl:for-each select="$ndTokenFirst/following-sibling::*[self::mi or self::mn or self::mo or self::ms or self::mtext]">
                         <xsl:choose>
                            <xsl:when test="namespace-uri(.) = 'http://www.w3.org/1998/Math/MathML' and               local-name(.) = 'ms'">
                               <xsl:call-template name="OutputMs">
                                  <xsl:with-param name="msCur" select="."/>
                               </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                               <xsl:value-of select="normalize-space(.)"/>
                            </xsl:otherwise>
                         </xsl:choose>
                      </xsl:for-each>
                   </xsl:with-param>
                </xsl:call-template>
             </m:t>
          </xsl:otherwise>
       </xsl:choose>
    </m:r>

    <!--The run was terminated by an mi, mn, mo, ms, or mtext with different properties,
      therefore, call-template CreateRunWithSameProp, using cndRun+1 node as new start node-->
  <xsl:if test="$nndBeforeLim!=0 and ($ndTokenFirst/following-sibling::*[$cndRun]/self::mi or $ndTokenFirst/following-sibling::*[$cndRun]/self::mn or $ndTokenFirst/following-sibling::*[$cndRun]/self::mo or $ndTokenFirst/following-sibling::*[$cndRun]/self::ms or $ndTokenFirst/following-sibling::*[$cndRun]/self::mtext) and (count($ndTokenFirst/following-sibling::*[$cndRun]/mglyph) = 0)">
       <xsl:call-template name="CreateRunWithSameProp">
          <xsl:with-param name="mathbackground">
             <xsl:choose>
                <xsl:when test="$ndTokenFirst/following-sibling::*[$cndRun]/@mathbackground">
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@mathbackground"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@mathbackground"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="mathcolor">
             <xsl:choose>
                <xsl:when test="$ndTokenFirst/following-sibling::*[$cndRun]/@mathcolor">
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@mathcolor"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@mathcolor"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="mathvariant">
             <xsl:choose>
                <xsl:when test="$ndTokenFirst/following-sibling::*[$cndRun]/@mathvariant">
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@mathvariant"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@mathvariant"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="color">
             <xsl:choose>
                <xsl:when test="$ndTokenFirst/following-sibling::*[$cndRun]/@color">
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@color"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@color"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="font-family">
             <xsl:choose>
                <xsl:when test="$ndTokenFirst/following-sibling::*[$cndRun]/@font-family">
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@font-family"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@font-family"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="fontsize">
             <xsl:choose>
                <xsl:when test="$ndTokenFirst/following-sibling::*[$cndRun]/@fontsize">
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@fontsize"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@fontsize"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="fontstyle">
             <xsl:choose>
                <xsl:when test="$ndTokenFirst/following-sibling::*[$cndRun]/@fontstyle">
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@fontstyle"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@fontstyle"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="fontweight">
             <xsl:choose>
                <xsl:when test="$ndTokenFirst/following-sibling::*[$cndRun]/@fontweight">
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@fontweight"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@fontweight"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="mathsize">
             <xsl:choose>
                <xsl:when test="$ndTokenFirst/following-sibling::*[$cndRun]/@mathsize">
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@mathsize"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="$ndTokenFirst/following-sibling::*[$cndRun]/@mathsize"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="ndTokenFirst" select="$ndTokenFirst/following-sibling::*[$cndRun]"/>
       </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- %%Template: FNor
       Given the context of ndCur, determine if ndCur should be omml's normal style.
-->
<xsl:template name="FNor">
    <xsl:param name="ndCur" select="."/>
    <xsl:choose>
    <!-- Is the current node an mtext, or if this is an mglyph whose parent is
           an mtext. -->
    <xsl:when test="$ndCur/self::mtext or ($ndCur/self::mglyph and parent::mtext)">1</xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- %%Template: FLit
       Given the context of ndCur, determine if ndCur should have the
       run omml property of lit (literal, no build up).
-->
<xsl:template name="FLit">
    <xsl:param name="ndCur" select="."/>
    <xsl:variable name="sLowerActiontype">
       <xsl:choose>
          <xsl:when test="$ndCur/ancestor::maction[@actiontype='lit']/@actiontype">
             <xsl:value-of select="translate($ndCur/ancestor::maction[@actiontype='lit']/@actiontype, $StrUCAlphabet,                                                                                                       $StrLCAlphabet)"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="translate($ndCur/ancestor::maction[@actiontype='lit']/@actiontype, $StrUCAlphabet,                                                                                                       $StrLCAlphabet)"/>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:variable>
    <xsl:choose>
       <xsl:when test="$sLowerActiontype='lit'">1</xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- %%Template: CreateRunProp
-->
<xsl:template name="CreateRunProp">
    <xsl:param name="mathbackground"/>
    <xsl:param name="mathcolor"/>
    <xsl:param name="mathvariant"/>
    <xsl:param name="color"/>
    <xsl:param name="font-family">Cambria Math</xsl:param>
    <xsl:param name="fontsize"/>
    <xsl:param name="fontstyle"/>
    <xsl:param name="fontweight"/>
    <xsl:param name="mathsize"/>
    <xsl:param name="ndCur"/>
    <xsl:param name="fNor"/>
    <xsl:param name="fLit"/>
    <w:rPr>
<xsl:call-template name="mathrRpHook"/>
       <w:rFonts w:ascii="{$font-family}" w:eastAsia="{$font-family}" w:hAnsi="{$font-family}"
                 w:cs="{$font-family}"/>
 <xsl:choose>
   <xsl:when test="$fontweight=''"/>
   <xsl:when test="$fontweight='bold'">
     <w:b/>
   </xsl:when>
   <xsl:when test="$fontweight='normal'">
     <w:b w:val="0"/>
   </xsl:when>
 </xsl:choose>
 <xsl:choose>
   <xsl:when test="$fontstyle=''"/>
   <xsl:when test="$fontstyle='italic'">
     <w:i/>
   </xsl:when>
   <xsl:when test="$fontstyle='normal'">
     <w:i w:val="0"/>
   </xsl:when>
 </xsl:choose>
    </w:rPr>
    <xsl:variable name="mstyleColor">
       <xsl:if test="not(not($ndCur))">
          <xsl:choose>
             <xsl:when test="$ndCur/ancestor::mstyle[@color][1]/@color">
                <xsl:value-of select="$ndCur/ancestor::mstyle[@color][1]/@color"/>
             </xsl:when>
             <xsl:otherwise>
                <xsl:value-of select="$ndCur/ancestor::mstyle[@color][1]/@color"/>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:if>
    </xsl:variable>
    <xsl:call-template name="CreateMathRPR">
       <xsl:with-param name="mathvariant" select="$mathvariant"/>
       <xsl:with-param name="fontstyle" select="$fontstyle"/>
       <xsl:with-param name="fontweight" select="$fontweight"/>
       <xsl:with-param name="ndCur" select="$ndCur"/>
       <xsl:with-param name="fNor" select="$fNor"/>
       <xsl:with-param name="fLit" select="$fLit"/>
    </xsl:call-template>
</xsl:template>

<!-- %%Template: CreateMathRPR
-->
<xsl:template name="CreateMathRPR">
    <xsl:param name="mathvariant"/>
    <xsl:param name="fontstyle"/>
    <xsl:param name="fontweight"/>
    <xsl:param name="ndCur"/>
    <xsl:param name="fNor"/>
    <xsl:param name="fLit"/>
    <xsl:variable name="sFontCur">
       <xsl:call-template name="GetFontCur">
          <xsl:with-param name="mathvariant" select="$mathvariant"/>
          <xsl:with-param name="fontstyle" select="$fontstyle"/>
          <xsl:with-param name="fontweight" select="$fontweight"/>
          <xsl:with-param name="ndCur" select="$ndCur"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$fLit=1 or $fNor=1 or ($sFontCur!='italic' and $sFontCur!='')">
       <w:rPr>
          <xsl:if test="$fNor=1">
             <m:nor/>
          </xsl:if>
          <xsl:if test="$fLit=1">
             <m:lit/>
          </xsl:if>
          <xsl:call-template name="CreateMathScrStyProp">
             <xsl:with-param name="font" select="$sFontCur"/>
             <xsl:with-param name="fNor" select="$fNor"/>
          </xsl:call-template>
       </w:rPr>
    </xsl:if>
</xsl:template>

<!-- %%Template: GetFontCur
-->
<xsl:template name="GetFontCur">
    <xsl:param name="ndCur"/>
    <xsl:param name="mathvariant"/>
    <xsl:param name="fontstyle"/>
    <xsl:param name="fontweight"/>
    <xsl:choose>
       <xsl:when test="$mathvariant!=''">
          <xsl:value-of select="$mathvariant"/>
       </xsl:when>
       <xsl:when test="not($ndCur)">
          <xsl:value-of select="'italic'"/>
       </xsl:when>
       <xsl:when test="$ndCur/self::mi and (string-length(normalize-space($ndCur)) &lt;= 1) or $ndCur/self::mn and string(number($ndCur/text()))!='NaN' or $ndCur/self::mo">

   <!-- The default for the above three cases is fontstyle=italic fontweight=normal.-->
   <xsl:choose>
     <xsl:when test="$fontstyle='normal' and $fontweight='bold'">
       <!-- In omml, a sty of 'b' (which is what bold is translated into)
      implies a normal fontstyle -->
       <xsl:value-of select="'bold'"/>
     </xsl:when>
     <xsl:when test="$fontstyle='normal'">
       <xsl:value-of select="'normal'"/>
     </xsl:when>
     <xsl:when test="$fontweight='bold'">
       <xsl:value-of select="'bi'"/>
     </xsl:when>
     <xsl:when test="$fontweight='normal'">
       <xsl:value-of select="'i'"/>
     </xsl:when>
     <xsl:otherwise>
       <xsl:value-of select="'italic'"/>
     </xsl:otherwise>
   </xsl:choose>
 </xsl:when>
 <xsl:otherwise>
   <!--Default is fontweight = 'normal' and fontstyle='normal'-->
      <xsl:choose>
  <xsl:when test="$fontstyle='italic' and $fontweight='bold'">
    <xsl:value-of select="'bi'"/>
  </xsl:when>
  <xsl:when test="$fontstyle='italic'">
    <xsl:value-of select="'italic'"/>
  </xsl:when>
     <xsl:when test="$fontweight='normal'">
       <xsl:value-of select="'italic'"/>
     </xsl:when>
  <xsl:when test="$fontweight='bold'">
    <xsl:value-of select="'bold'"/>
  </xsl:when>
  <xsl:otherwise>
    <xsl:value-of select="'normal'"/>
  </xsl:otherwise>
          </xsl:choose>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- %%Template: CreateMathScrStyProp
-->
<xsl:template name="CreateMathScrStyProp">
    <xsl:param name="font"/>
    <xsl:param name="fNor" select="0"/>
    <xsl:choose>
       <xsl:when test="$font='normal' and $fNor=0">
          <m:sty>
             <xsl:attribute name="m:val">p</xsl:attribute>
          </m:sty>
       </xsl:when>
       <xsl:when test="$font='bold'">
          <m:sty>
             <xsl:attribute name="m:val">b</xsl:attribute>
          </m:sty>
       </xsl:when>
       <xsl:when test="$font='italic'">
    </xsl:when>
       <xsl:when test="$font='script'">
          <m:scr>
             <xsl:attribute name="m:val">script</xsl:attribute>
          </m:scr>
       </xsl:when>
       <xsl:when test="$font='bold-script'">
          <m:scr>
             <xsl:attribute name="m:val">script</xsl:attribute>
          </m:scr>
          <m:sty>
             <xsl:attribute name="m:val">b</xsl:attribute>
          </m:sty>
       </xsl:when>
       <xsl:when test="$font='double-struck'">
          <m:scr>
             <xsl:attribute name="m:val">double-struck</xsl:attribute>
          </m:scr>
          <m:sty>
             <xsl:attribute name="m:val">p</xsl:attribute>
          </m:sty>
       </xsl:when>
       <xsl:when test="$font='fraktur'">
          <m:scr>
             <xsl:attribute name="m:val">fraktur</xsl:attribute>
          </m:scr>
          <m:sty>
             <xsl:attribute name="m:val">p</xsl:attribute>
          </m:sty>
       </xsl:when>
       <xsl:when test="$font='bold-fraktur'">
          <m:scr>
             <xsl:attribute name="m:val">fraktur</xsl:attribute>
          </m:scr>
          <m:sty>
             <xsl:attribute name="m:val">b</xsl:attribute>
          </m:sty>
       </xsl:when>
       <xsl:when test="$font='sans-serif'">
          <m:scr>
             <xsl:attribute name="m:val">sans-serif</xsl:attribute>
          </m:scr>
          <m:sty>
             <xsl:attribute name="m:val">p</xsl:attribute>
          </m:sty>
       </xsl:when>
       <xsl:when test="$font='bold-sans-serif'">
          <m:scr>
             <xsl:attribute name="m:val">sans-serif</xsl:attribute>
          </m:scr>
          <m:sty>
             <xsl:attribute name="m:val">b</xsl:attribute>
          </m:sty>
       </xsl:when>
       <xsl:when test="$font='sans-serif-italic'">
          <m:scr>
             <xsl:attribute name="m:val">sans-serif</xsl:attribute>
          </m:scr>
       </xsl:when>
       <xsl:when test="$font='sans-serif-bold-italic'">
          <m:scr>
             <xsl:attribute name="m:val">sans-serif</xsl:attribute>
          </m:scr>
          <m:sty>
             <xsl:attribute name="m:val">bi</xsl:attribute>
          </m:sty>
       </xsl:when>
       <xsl:when test="$font='monospace'"/>
       <!-- We can't do monospace, so leave empty -->
    <xsl:when test="$font='bold'">
          <m:sty>
             <xsl:attribute name="m:val">b</xsl:attribute>
          </m:sty>
       </xsl:when>
       <xsl:when test="$font='bi' or $font='bold-italic'">
          <m:sty>
             <xsl:attribute name="m:val">bi</xsl:attribute>
          </m:sty>
       </xsl:when>
    </xsl:choose>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template name="FBar">
    <xsl:param name="sLineThickness"/>
    <xsl:variable name="sLowerLineThickness"
                  select="translate($sLineThickness, $StrUCAlphabet, $StrLCAlphabet)"/>
    <xsl:choose>
       <xsl:when test="string-length($sLowerLineThickness)=0 or $sLowerLineThickness='thin' or $sLowerLineThickness='medium' or $sLowerLineThickness='thick'">1</xsl:when>
       <xsl:otherwise>
          <xsl:variable name="fStrContainsNonZeroDigit">
             <xsl:call-template name="FStrContainsNonZeroDigit">
                <xsl:with-param name="s" select="$sLowerLineThickness"/>
             </xsl:call-template>
          </xsl:variable>
          <xsl:choose>
             <xsl:when test="$fStrContainsNonZeroDigit=1">1</xsl:when>
             <xsl:otherwise>0</xsl:otherwise>
          </xsl:choose>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- %%Template: match mfrac
  -->
<xsl:template mode="mml" match="mfrac">
    <xsl:variable name="fBar">
       <xsl:call-template name="FBar">
          <xsl:with-param name="sLineThickness">
             <xsl:choose>
                <xsl:when test="@linethickness">
                   <xsl:value-of select="@linethickness"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="@linethickness"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
       </xsl:call-template>
    </xsl:variable>

    <m:f>
       <m:fPr>
          <m:type>
             <xsl:attribute name="m:val">
                <xsl:choose>
                   <xsl:when test="$fBar=0">noBar</xsl:when>
                   <xsl:when test="@bevelled='true' or @bevelled='true'">skw</xsl:when>
                   <xsl:otherwise>bar</xsl:otherwise>
                </xsl:choose>
             </xsl:attribute>
          </m:type>
       </m:fPr>
       <m:num>
          <xsl:call-template name="CreateArgProp"/>
          <xsl:apply-templates mode="mml" select="child::*[1]"/>
       </m:num>
       <m:den>
          <xsl:call-template name="CreateArgProp"/>
          <xsl:apply-templates mode="mml" select="child::*[2]"/>
       </m:den>
    </m:f>
</xsl:template>

<!-- %%Template: match menclose msqrt
-->
<xsl:template mode="mml" match="menclose | msqrt">
    <xsl:variable name="sLowerCaseNotation">
       <xsl:choose>
          <xsl:when test="@notation">
             <xsl:value-of select="translate(@notation, $StrUCAlphabet, $StrLCAlphabet)"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="translate(@notation, $StrUCAlphabet, $StrLCAlphabet)"/>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:variable>
    <xsl:choose>
    <!-- Take care of default -->
    <xsl:when test="$sLowerCaseNotation='radical' or not($sLowerCaseNotation) or $sLowerCaseNotation='' or self::msqrt">
          <m:rad>
             <m:radPr>
                <m:degHide>
                   <xsl:attribute name="m:val">on</xsl:attribute>
                </m:degHide>
             </m:radPr>
             <m:deg>
                <xsl:call-template name="CreateArgProp"/>
             </m:deg>
             <m:e>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml"/>
             </m:e>
          </m:rad>
       </xsl:when>
       <xsl:otherwise>
          <xsl:choose>
             <xsl:when test="$sLowerCaseNotation='actuarial' or $sLowerCaseNotation='longdiv'"/>
             <xsl:otherwise>
                <m:borderBox>
            <!-- Dealing with more complex notation attribute -->
            <xsl:variable name="fBox">
                      <xsl:choose>
                <!-- Word doesn't have circle and roundedbox concepts, therefore, map both to a
                     box. -->
                <xsl:when test="contains($sLowerCaseNotation, 'box') or contains($sLowerCaseNotation, 'circle') or contains($sLowerCaseNotation, 'roundedbox')">1</xsl:when>
                         <xsl:otherwise>0</xsl:otherwise>
                      </xsl:choose>
                   </xsl:variable>
                   <xsl:variable name="fTop">
                      <xsl:choose>
                         <xsl:when test="contains($sLowerCaseNotation, 'top')">1</xsl:when>
                         <xsl:otherwise>0</xsl:otherwise>
                      </xsl:choose>
                   </xsl:variable>
                   <xsl:variable name="fBot">
                      <xsl:choose>
                         <xsl:when test="contains($sLowerCaseNotation, 'bottom')">1</xsl:when>
                         <xsl:otherwise>0</xsl:otherwise>
                      </xsl:choose>
                   </xsl:variable>
                   <xsl:variable name="fLeft">
                      <xsl:choose>
                         <xsl:when test="contains($sLowerCaseNotation, 'left')">1</xsl:when>
                         <xsl:otherwise>0</xsl:otherwise>
                      </xsl:choose>
                   </xsl:variable>
                   <xsl:variable name="fRight">
                      <xsl:choose>
                         <xsl:when test="contains($sLowerCaseNotation, 'right')">1</xsl:when>
                         <xsl:otherwise>0</xsl:otherwise>
                      </xsl:choose>
                   </xsl:variable>
                   <xsl:variable name="fStrikeH">
                      <xsl:choose>
                         <xsl:when test="contains($sLowerCaseNotation, 'horizontalstrike')">1</xsl:when>
                         <xsl:otherwise>0</xsl:otherwise>
                      </xsl:choose>
                   </xsl:variable>
                   <xsl:variable name="fStrikeV">
                      <xsl:choose>
                         <xsl:when test="contains($sLowerCaseNotation, 'verticalstrike')">1</xsl:when>
                         <xsl:otherwise>0</xsl:otherwise>
                      </xsl:choose>
                   </xsl:variable>
                   <xsl:variable name="fStrikeBLTR">
                      <xsl:choose>
                         <xsl:when test="contains($sLowerCaseNotation, 'updiagonalstrike')">1</xsl:when>
                         <xsl:otherwise>0</xsl:otherwise>
                      </xsl:choose>
                   </xsl:variable>
                   <xsl:variable name="fStrikeTLBR">
                      <xsl:choose>
                         <xsl:when test="contains($sLowerCaseNotation, 'downdiagonalstrike')">1</xsl:when>
                         <xsl:otherwise>0</xsl:otherwise>
                      </xsl:choose>
                   </xsl:variable>

                   <!-- Should we create borderBoxPr?
                 We should if the enclosure isn't Word's default, which is
                 a plain box -->
            <xsl:if test="$fStrikeH=1 or $fStrikeV=1 or $fStrikeBLTR=1 or $fStrikeTLBR=1 or ($fBox=0 and not($fTop=1 and $fBot=1 and $fLeft=1 and $fRight=1))">
                      <m:borderBoxPr>
                         <xsl:if test="$fBox=0">
                            <xsl:if test="$fTop=0">
                               <m:hideTop>
                                  <xsl:attribute name="m:val">on</xsl:attribute>
                               </m:hideTop>
                            </xsl:if>
                            <xsl:if test="$fBot=0">
                               <m:hideBot>
                                  <xsl:attribute name="m:val">on</xsl:attribute>
                               </m:hideBot>
                            </xsl:if>
                            <xsl:if test="$fLeft=0">
                               <m:hideLeft>
                                  <xsl:attribute name="m:val">on</xsl:attribute>
                               </m:hideLeft>
                            </xsl:if>
                            <xsl:if test="$fRight=0">
                               <m:hideRight>
                                  <xsl:attribute name="m:val">on</xsl:attribute>
                               </m:hideRight>
                            </xsl:if>
                         </xsl:if>
                         <xsl:if test="$fStrikeH=1">
                            <m:strikeH>
                               <xsl:attribute name="m:val">on</xsl:attribute>
                            </m:strikeH>
                         </xsl:if>
                         <xsl:if test="$fStrikeV=1">
                            <m:strikeV>
                               <xsl:attribute name="m:val">on</xsl:attribute>
                            </m:strikeV>
                         </xsl:if>
                         <xsl:if test="$fStrikeBLTR=1">
                            <m:strikeBLTR>
                               <xsl:attribute name="m:val">on</xsl:attribute>
                            </m:strikeBLTR>
                         </xsl:if>
                         <xsl:if test="$fStrikeTLBR=1">
                            <m:strikeTLBR>
                               <xsl:attribute name="m:val">on</xsl:attribute>
                            </m:strikeTLBR>
                         </xsl:if>
                      </m:borderBoxPr>
                   </xsl:if>
                   <m:e>
                      <xsl:call-template name="CreateArgProp"/>
                      <xsl:apply-templates mode="mml"/>
                   </m:e>
                </m:borderBox>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- %%Template: CreateArgProp
-->
<xsl:template name="CreateArgProp">
    <xsl:if test="not(count(ancestor-or-self::mstyle[@scriptlevel='0' or @scriptlevel='1' or @scriptlevel='2'])=0) or not(count(ancestor-or-self::mstyle[@scriptlevel='0' or @scriptlevel='1' or @scriptlevel='2'])=0)">
       <m:argPr>
          <m:scrLvl>
             <xsl:attribute name="m:val">
                <xsl:choose>
                   <xsl:when test="ancestor-or-self::mstyle[@scriptlevel][1]/@scriptlevel">
                      <xsl:value-of select="ancestor-or-self::mstyle[@scriptlevel][1]/@scriptlevel"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="ancestor-or-self::mstyle[@scriptlevel][1]/@scriptlevel"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:attribute>
          </m:scrLvl>
       </m:argPr>
    </xsl:if>
</xsl:template>

<!-- %%Template: match mroot
-->
<xsl:template mode="mml" match="mroot">
    <m:rad>
       <m:radPr>
          <m:degHide>
             <xsl:attribute name="m:val">off</xsl:attribute>
          </m:degHide>
       </m:radPr>
       <m:deg>
          <xsl:call-template name="CreateArgProp"/>
          <xsl:apply-templates mode="mml" select="child::*[2]"/>
       </m:deg>
       <m:e>
          <xsl:call-template name="CreateArgProp"/>
          <xsl:apply-templates mode="mml" select="child::*[1]"/>
       </m:e>
    </m:rad>
</xsl:template>

<!-- MathML has no concept of a linear fraction.  When transforming a linear fraction
     from Omml to MathML, we create the following MathML:

     <m:mrow>
       <m:mrow>
          // numerator
       </m:mrow>
       <m:mo>/</m:mo>
       <m:mrow>
          // denominator
       </m:mrow>
     </m:mrow>

     This template looks for four things:
        1.  ndCur is an m:mrow
        2.  ndCur has three children
        3.  The second child is an <m:mo>
        4.  The second child's text is '/'

     -->
<xsl:template name="FLinearFrac">
    <xsl:param name="ndCur" select="."/>
    <xsl:variable name="sNdText">
       <xsl:value-of select="normalize-space($ndCur/*[2])"/>
    </xsl:variable>

    <xsl:choose>
    <!-- I spy a linear fraction -->
    <xsl:when test="$ndCur/self::mrow and count($ndCur/*)=3 and $ndCur/*[2][self::mo] and $sNdText='/'">1</xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Though presentation mathml can certainly typeset any generic function with the
     appropriate function operator spacing, presentation MathML has no concept of
     a function structure like omml does.  In order to preserve the omml <func>
     element, we must establish how an omml <func> element looks in mml.  This
     is shown below:

     <m:mrow>
       <m:mrow>
          // function name
       </m:mrow>
       <m:mo>&#x02061;</m:mo>
       <m:mrow>
          // function argument
       </m:mrow>
     </m:mrow>

     This template looks for six things to be true:
        1.  ndCur is an m:mrow
        2.  ndCur has three children
        3.  The first child is an <m:mrow>
        4.  The second child is an <m:mo>
        5.  The third child is an <m:mrow>
        6.  The second child's text is '&#x02061;'
     -->
<xsl:template name="FIsFunc">
    <xsl:param name="ndCur" select="."/>
    <xsl:variable name="sNdText">
       <xsl:value-of select="normalize-space($ndCur/*[2])"/>
    </xsl:variable>

    <xsl:choose>
    <!-- Is this an omml function -->
    <xsl:when test="count($ndCur/*)=3 and $ndCur/self::*[self::mrow] and $ndCur/*[2][self::mo] and $sNdText='⁡'">1</xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Given the node of the linear fraction's parent mrow,
     make a linear fraction -->
<xsl:template name="MakeLinearFraction">
    <xsl:param name="ndCur" select="."/>
    <m:f>
       <m:fPr>
          <m:type>
             <xsl:attribute name="m:val">lin</xsl:attribute>
          </m:type>
       </m:fPr>
       <m:num>
          <xsl:call-template name="CreateArgProp"/>
          <xsl:apply-templates mode="mml" select="$ndCur/*[1]"/>
       </m:num>
       <m:den>
          <xsl:call-template name="CreateArgProp"/>
          <xsl:apply-templates mode="mml" select="$ndCur/*[3]"/>
       </m:den>
    </m:f>
</xsl:template>


<!-- Given the node of the function's parent mrow,
     make an omml function -->
<xsl:template name="WriteFunc">
    <xsl:param name="ndCur" select="."/>

    <m:func>
       <m:fName>
          <xsl:apply-templates mode="mml" select="$ndCur/child::*[1]"/>
       </m:fName>
       <m:e>
          <xsl:apply-templates mode="mml" select="$ndCur/child::*[3]"/>
       </m:e>
    </m:func>
</xsl:template>


<!-- MathML doesn't have the concept of nAry structures.  The best approximation
     to these is to have some under/over or sub/sup followed by an mrow or mstyle.

     In the case that we've come across some under/over or sub/sup that contains an
     nAry operator, this function handles the following sibling to the nAry structure.

     If the following sibling is:

        m:mstyle, then apply templates to the children of this m:mstyle

        m:mrow, determine if this mrow is a linear fraction
        (see comments for FlinearFrac template).
            If so, make an Omml linear fraction.
            If not, apply templates as was done for m:mstyle.

     -->
<xsl:template name="NaryHandleMrowMstyle">
    <xsl:param name="ndCur" select="."/>
    <!-- if the next sibling is an mrow, pull it in by
            doing whatever we would have done to its children.
            The mrow itself will be skipped, see template above. -->
  <xsl:choose>
       <xsl:when test="$ndCur[self::mrow]">
      <!-- Check for linear fraction -->
      <xsl:variable name="fLinearFrac">
             <xsl:call-template name="FLinearFrac">
                <xsl:with-param name="ndCur" select="$ndCur"/>
             </xsl:call-template>
          </xsl:variable>
          <xsl:choose>
             <xsl:when test="$fLinearFrac=1">
                <xsl:call-template name="MakeLinearFraction">
                   <xsl:with-param name="ndCur" select="$ndCur"/>
                </xsl:call-template>
             </xsl:when>
             <xsl:otherwise>
                <xsl:variable name="fFunc">
                   <xsl:call-template name="FIsFunc">
                      <xsl:with-param name="ndCur" select="."/>
                   </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                   <xsl:when test="$fFunc=1">
                      <xsl:call-template name="WriteFunc">
                         <xsl:with-param name="ndCur" select="."/>
                      </xsl:call-template>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:apply-templates mode="mml" select="$ndCur/*"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:when>
       <xsl:when test="$ndCur[self::mstyle]">
          <xsl:apply-templates mode="mml" select="$ndCur/*"/>
       </xsl:when>
    </xsl:choose>
</xsl:template>


<!-- MathML munder/mover can represent several Omml constructs
     (m:bar, m:limLow, m:limUpp, m:acc, m:groupChr, etc.).  The following
     templates (FIsBar, FIsAcc, and FIsGroupChr) are used to determine
     which of these Omml constructs an munder/mover should be translated into. -->

<!-- Note:  ndCur should only be an munder/mover MathML element.

     ndCur should be interpretted as an m:bar if
        1)  its respective accent attribute is not true
        2)  its second child is an m:mo
        3)  the character of the m:mo is the correct under/over bar. -->
<xsl:template name="FIsBar">
    <xsl:param name="ndCur"/>
    <xsl:variable name="fUnder">
       <xsl:choose>
          <xsl:when test="$ndCur[self::munder]">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
       </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sLowerCaseAccent">
       <xsl:choose>
          <xsl:when test="$fUnder=1">
             <xsl:choose>
                <xsl:when test="$ndCur/@accentunder">
                   <xsl:value-of select="translate($ndCur/@accentunder, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="translate($ndCur/@accentunder, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
             <xsl:choose>
                <xsl:when test="$ndCur/@accent">
                   <xsl:value-of select="translate($ndCur/@accent, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="translate($ndCur/@accent, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fAccent">
       <xsl:choose>
          <xsl:when test="$sLowerCaseAccent='true'">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
       </xsl:choose>
    </xsl:variable>

    <xsl:choose>
    <!-- The script is unaccented and the second child is an mo -->
    <xsl:when test="$fAccent = 0 and $ndCur/child::*[2]/self::mo">
          <xsl:variable name="sOperator">
             <xsl:value-of select="$ndCur/child::*[2]"/>
          </xsl:variable>
          <xsl:choose>
        <!-- Should we write an underbar? -->
        <xsl:when test="$fUnder = 1">
                <xsl:choose>
                   <xsl:when test="$sOperator = '̲'">1</xsl:when>
                   <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
             </xsl:when>
             <!-- Should we write an overbar? -->
        <xsl:otherwise>
                <xsl:choose>
                   <xsl:when test="$sOperator = '¯'">1</xsl:when>
                   <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Note:  ndCur should only be an mover MathML element.

     ndCur should be interpretted as an acc if
        1)  its accent attribute is true
        2)  its second child is an mo
        3)  there is only one character in the mo -->
<xsl:template name="FIsAcc">
    <xsl:param name="ndCur" select="."/>

    <xsl:variable name="sLowerCaseAccent">
       <xsl:choose>
          <xsl:when test="$ndCur/@accent">
             <xsl:value-of select="translate($ndCur/@accent, $StrUCAlphabet, $StrLCAlphabet)"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="translate($ndCur/@accent, $StrUCAlphabet, $StrLCAlphabet)"/>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:variable>
    <xsl:variable name="fAccent">
       <xsl:choose>
          <xsl:when test="$sLowerCaseAccent='true'">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
       </xsl:choose>
    </xsl:variable>

    <xsl:choose>
    <!-- The script is accented and the second child is an mo -->
    <xsl:when test="$fAccent = 1 and $ndCur/child::*[2] = mo">
          <xsl:variable name="sOperator">
             <xsl:value-of select="$ndCur/child::*[2]"/>
          </xsl:variable>
          <xsl:choose>
        <!-- There is only one operator, this is a valid Omml accent! -->
        <xsl:when test="string-length($sOperator) = 1">1</xsl:when>
             <!-- More than one accented operator.  This isn't a valid
             omml accent -->
        <xsl:otherwise>0</xsl:otherwise>
          </xsl:choose>
       </xsl:when>
       <!-- Not accented, not an operator, or both, but in any case, this is
         not an Omml accent. -->
    <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Is ndCur a groupChr?
     ndCur is a groupChr if:

       1.  The accent is false (note:  accent attribute
           for munder is accentunder).
       2.  ndCur is an munder or mover.
       3.  ndCur has two children
       4.  Of these two children, one is an mo and the other is an mrow
       5.  The number of characters in the mo is 1.

     If all of the above are true, then return 1, else return 0.
-->
<xsl:template name="FIsGroupChr">
    <xsl:param name="ndCur" select="."/>
    <xsl:variable name="fUnder">
       <xsl:choose>
          <xsl:when test="$ndCur[self::munder]">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
       </xsl:choose>
    </xsl:variable>
    <xsl:variable name="sLowerCaseAccent">
       <xsl:choose>
          <xsl:when test="$fUnder=1">
             <xsl:choose>
                <xsl:when test="$ndCur/@accentunder">
                   <xsl:value-of select="translate($ndCur/@accentunder, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="translate($ndCur/@accentunder, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
             <xsl:choose>
                <xsl:when test="$ndCur/@accent">
                   <xsl:value-of select="translate($ndCur/@accent, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="translate($ndCur/@accent, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:variable>

    <xsl:variable name="fAccentFalse">
       <xsl:choose>
          <xsl:when test="$sLowerCaseAccent='false'">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
       </xsl:choose>
    </xsl:variable>

    <xsl:choose>
       <xsl:when test="$fAccentFalse=1 and $ndCur[self::munder or self::mover] and count($ndCur/child::*)=2 and (($ndCur/child::*[1][self::mrow] and $ndCur/child::*[2][self::mo]) or ($ndCur/child::*[1][self::mo] and $ndCur/child::*[2][self::mrow]))">
          <xsl:variable name="sOperator">
             <xsl:value-of select="$ndCur/child::mo"/>
          </xsl:variable>
          <xsl:choose>
             <xsl:when test="string-length($sOperator) &lt;= 1">1</xsl:when>
             <xsl:otherwise>0</xsl:otherwise>
          </xsl:choose>
       </xsl:when>

       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- %%Template: match munder
-->
<xsl:template mode="mml" match="munder">
    <xsl:variable name="fNary">
       <xsl:call-template name="isNary">
          <xsl:with-param name="ndCur" select="child::*[1]"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
       <xsl:when test="$fNary='true'">
          <m:nary>
             <xsl:call-template name="CreateNaryProp">
                <xsl:with-param name="chr">
                   <xsl:value-of select="normalize-space(child::*[1])"/>
                </xsl:with-param>
                <xsl:with-param name="sMathmlType" select="'munder'"/>
             </xsl:call-template>
             <m:sub>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[2]"/>
             </m:sub>
             <m:sup>
                <xsl:call-template name="CreateArgProp"/>
             </m:sup>
             <m:e>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:call-template name="NaryHandleMrowMstyle">
                   <xsl:with-param name="ndCur" select="following-sibling::*[1]"/>
                </xsl:call-template>
             </m:e>
          </m:nary>
       </xsl:when>
       <xsl:otherwise>
      <!-- Should this munder be interpreted as an OMML m:bar? -->
      <xsl:variable name="fIsBar">
             <xsl:call-template name="FIsBar">
                <xsl:with-param name="ndCur" select="."/>
             </xsl:call-template>
          </xsl:variable>
          <xsl:choose>
             <xsl:when test="$fIsBar=1">
                <m:bar>
                   <m:barPr>
                      <m:pos m:val="bot"/>
                   </m:barPr>
                   <m:e>
                      <xsl:call-template name="CreateArgProp"/>
                      <xsl:apply-templates mode="mml" select="child::*[1]"/>
                   </m:e>
                </m:bar>
             </xsl:when>
             <xsl:otherwise>
          <!-- It isn't an integral or underbar, is this a groupChr? -->
          <xsl:variable name="fGroupChr">
                   <xsl:call-template name="FIsGroupChr">
                      <xsl:with-param name="ndCur" select="."/>
                   </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                   <xsl:when test="$fGroupChr=1">
                      <m:groupChr>
                         <xsl:call-template name="CreateGroupChrPr">
                            <xsl:with-param name="chr">
                               <xsl:value-of select="mo"/>
                            </xsl:with-param>
                            <xsl:with-param name="pos">
                               <xsl:choose>
                                  <xsl:when test="child::*[1][self::mrow]">bot</xsl:when>
                                  <xsl:otherwise>top</xsl:otherwise>
                               </xsl:choose>
                            </xsl:with-param>
                            <xsl:with-param name="vertJc">top</xsl:with-param>
                         </xsl:call-template>
                         <m:e>
                            <xsl:apply-templates mode="mml" select="mrow"/>
                         </m:e>
                      </m:groupChr>
                   </xsl:when>
                   <xsl:otherwise>
              <!-- Generic munder -->
              <m:limLow>
                         <m:e>
                            <xsl:call-template name="CreateArgProp"/>
                            <xsl:apply-templates mode="mml" select="child::*[1]"/>
                         </m:e>
                         <m:lim>
                            <xsl:call-template name="CreateArgProp"/>
                            <xsl:apply-templates mode="mml" select="child::*[2]"/>
                         </m:lim>
                      </m:limLow>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Given the values for chr, pos, and vertJc, create an omml
     groupChr's groupChrPr -->
<xsl:template name="CreateGroupChrPr">
    <xsl:param name="chr">⏟</xsl:param>
    <xsl:param name="pos" select="bot"/>
    <xsl:param name="vertJc" select="top"/>
    <m:groupChrPr>
       <m:chr>
          <xsl:attribute name="m:val">
             <xsl:value-of select="$chr"/>
          </xsl:attribute>
       </m:chr>
       <m:pos>
          <xsl:attribute name="m:val">
             <xsl:value-of select="$pos"/>
          </xsl:attribute>
       </m:pos>
       <m:vertJc>
          <xsl:attribute name="m:val">
             <xsl:value-of select="$vertJc"/>
          </xsl:attribute>
       </m:vertJc>
    </m:groupChrPr>
</xsl:template>


<!-- %%Template: match mover
-->
<xsl:template mode="mml" match="mover">
    <xsl:variable name="fNary">
       <xsl:call-template name="isNary">
          <xsl:with-param name="ndCur" select="child::*[1]"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
       <xsl:when test="$fNary='true'">
          <m:nary>
             <xsl:call-template name="CreateNaryProp">
                <xsl:with-param name="chr">
                   <xsl:value-of select="normalize-space(child::*[1])"/>
                </xsl:with-param>
                <xsl:with-param name="sMathmlType" select="'mover'"/>
             </xsl:call-template>
             <m:sub>
                <xsl:call-template name="CreateArgProp"/>
             </m:sub>
             <m:sup>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[2]"/>
             </m:sup>
             <m:e>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:call-template name="NaryHandleMrowMstyle">
                   <xsl:with-param name="ndCur" select="following-sibling::*[1]"/>
                </xsl:call-template>
             </m:e>
          </m:nary>
       </xsl:when>
       <xsl:otherwise>
      <!-- Should this munder be interpreted as an OMML m:bar or m:acc? -->

      <!-- Check to see if this is an m:bar -->
      <xsl:variable name="fIsBar">
             <xsl:call-template name="FIsBar">
                <xsl:with-param name="ndCur" select="."/>
             </xsl:call-template>
          </xsl:variable>
          <xsl:choose>
             <xsl:when test="$fIsBar = 1">
                <m:bar>
                   <m:barPr>
                      <m:pos m:val="top"/>
                   </m:barPr>
                   <m:e>
                      <xsl:call-template name="CreateArgProp"/>
                      <xsl:apply-templates mode="mml" select="child::*[1]"/>
                   </m:e>
                </m:bar>
             </xsl:when>
             <xsl:otherwise>
          <!-- Not an m:bar, should it be an m:acc? -->
          <xsl:variable name="fIsAcc">
                   <xsl:call-template name="FIsAcc">
                      <xsl:with-param name="ndCur" select="."/>
                   </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                   <xsl:when test="$fIsAcc=1">
                      <m:acc>
                         <m:accPr>
                            <m:chr>
                               <xsl:attribute name="m:val">
                                  <xsl:value-of select="child::*[2]"/>
                               </xsl:attribute>
                            </m:chr>
                         </m:accPr>
                         <m:e>
                            <xsl:call-template name="CreateArgProp"/>
                            <xsl:apply-templates mode="mml" select="child::*[1]"/>
                         </m:e>
                      </m:acc>
                   </xsl:when>
                   <xsl:otherwise>
              <!-- This isn't an integral, overbar or accent,
                   could it be a groupChr? -->
              <xsl:variable name="fGroupChr">
                         <xsl:call-template name="FIsGroupChr">
                            <xsl:with-param name="ndCur" select="."/>
                         </xsl:call-template>
                      </xsl:variable>
                      <xsl:choose>
                         <xsl:when test="$fGroupChr=1">
                            <m:groupChr>
                               <xsl:call-template name="CreateGroupChrPr">
                                  <xsl:with-param name="chr">
                                     <xsl:value-of select="mo"/>
                                  </xsl:with-param>
                                  <xsl:with-param name="pos">
                                     <xsl:choose>
                                        <xsl:when test="child::*[1][self::mrow]">top</xsl:when>
                                        <xsl:otherwise>bot</xsl:otherwise>
                                     </xsl:choose>
                                  </xsl:with-param>
                                  <xsl:with-param name="vertJc">bot</xsl:with-param>
                               </xsl:call-template>
                               <m:e>
                                  <xsl:apply-templates mode="mml" select="mrow"/>
                               </m:e>
                            </m:groupChr>
                         </xsl:when>
                         <xsl:otherwise>
                  <!-- Generic mover -->
                  <m:limUpp>
                               <m:e>
                                  <xsl:call-template name="CreateArgProp"/>
                                  <xsl:apply-templates mode="mml" select="child::*[1]"/>
                               </m:e>
                               <m:lim>
                                  <xsl:call-template name="CreateArgProp"/>
                                  <xsl:apply-templates mode="mml" select="child::*[2]"/>
                               </m:lim>
                            </m:limUpp>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- %%Template: match munderover
-->
<xsl:template mode="mml" match="munderover">
    <xsl:variable name="fNary">
       <xsl:call-template name="isNary">
          <xsl:with-param name="ndCur" select="child::*[1]"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
       <xsl:when test="$fNary='true'">
          <m:nary>
             <xsl:call-template name="CreateNaryProp">
                <xsl:with-param name="chr">
                   <xsl:value-of select="normalize-space(child::*[1])"/>
                </xsl:with-param>
                <xsl:with-param name="sMathmlType" select="'munderover'"/>
             </xsl:call-template>
             <m:sub>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[2]"/>
             </m:sub>
             <m:sup>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[3]"/>
             </m:sup>
             <m:e>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:call-template name="NaryHandleMrowMstyle">
                   <xsl:with-param name="ndCur" select="following-sibling::*[1]"/>
                </xsl:call-template>
             </m:e>
          </m:nary>
       </xsl:when>
       <xsl:otherwise>
          <m:limUpp>
             <m:e>
                <xsl:call-template name="CreateArgProp"/>
                <m:limLow>
                   <m:e>
                      <xsl:call-template name="CreateArgProp"/>
                      <xsl:apply-templates mode="mml" select="child::*[1]"/>
                   </m:e>
                   <m:lim>
                      <xsl:call-template name="CreateArgProp"/>
                      <xsl:apply-templates mode="mml" select="child::*[2]"/>
                   </m:lim>
                </m:limLow>
             </m:e>
             <m:lim>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[3]"/>
             </m:lim>
          </m:limUpp>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- %%Template: match mfenced -->
<xsl:template mode="mml" match="mfenced">
    <m:d>
       <xsl:call-template name="CreateDelimProp">
          <xsl:with-param name="fChOpenValid">
             <xsl:choose>
                <xsl:when test="@open">
                   <xsl:value-of select="1"/>
                </xsl:when>
                <xsl:when test="@open">
                   <xsl:value-of select="1"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="0"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="chOpen">
             <xsl:choose>
                <xsl:when test="@open">
                   <xsl:value-of select="@open"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="@open"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="fChSeparatorsValid">
             <xsl:choose>
                <xsl:when test="@separators">
                   <xsl:value-of select="1"/>
                </xsl:when>
                <xsl:when test="@separators">
                   <xsl:value-of select="1"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="0"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="chSeparators">
             <xsl:choose>
                <xsl:when test="@separators">
                   <xsl:value-of select="@separators"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="@separators"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="fChCloseValid">
             <xsl:choose>
                <xsl:when test="@close">
                   <xsl:value-of select="1"/>
                </xsl:when>
                <xsl:when test="@close">
                   <xsl:value-of select="1"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="0"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="chClose">
             <xsl:choose>
                <xsl:when test="@close">
                   <xsl:value-of select="@close"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="@close"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
       </xsl:call-template>
       <xsl:for-each select="*">
          <m:e>
             <xsl:call-template name="CreateArgProp"/>
             <xsl:apply-templates mode="mml" select="."/>
          </m:e>
       </xsl:for-each>
    </m:d>
</xsl:template>

<!-- %%Template: CreateDelimProp

  Given the characters to use as open, close and separators for
  the delim object, create the m:dPr (delim properties).

  MathML can have any number of separators in an mfenced object, but
  OMML can only represent one separator for each d (delim) object.
  So, we pick the first separator specified.
-->
<xsl:template name="CreateDelimProp">
    <xsl:param name="fChOpenValid"/>
    <xsl:param name="chOpen"/>
    <xsl:param name="fChSeparatorsValid"/>
    <xsl:param name="chSeparators"/>
    <xsl:param name="fChCloseValid"/>
    <xsl:param name="chClose"/>
    <xsl:variable name="chSep" select="substring($chSeparators, 1, 1)"/>

    <!-- do we need a dPr at all? If everything's at its default value, then
    don't bother at all -->
  <xsl:if test="($fChOpenValid=1 and not($chOpen = '(')) or ($fChCloseValid=1 and not($chClose = ')')) or not($chSep = '|')">
       <m:dPr>
      <!-- the default for MathML and OMML is '('. -->
      <xsl:if test="$fChOpenValid=1 and not($chOpen = '(')">
             <m:begChr>
                <xsl:attribute name="m:val">
                   <xsl:value-of select="$chOpen"/>
                </xsl:attribute>
             </m:begChr>
          </xsl:if>

          <!-- the default for MathML is ',' and for OMML is '|' -->

      <xsl:choose>
        <!-- matches OMML's default, don't bother to write anything out -->
        <xsl:when test="$chSep = '|'"/>

             <!-- Not specified, use MathML's default. We test against
        the existence of the actual attribute, not the substring -->
        <xsl:when test="$fChSeparatorsValid=0">
                <m:sepChr m:val=","/>
             </xsl:when>

             <xsl:otherwise>
                <m:sepChr>
                   <xsl:attribute name="m:val">
                      <xsl:value-of select="$chSep"/>
                   </xsl:attribute>
                </m:sepChr>
             </xsl:otherwise>
          </xsl:choose>

          <!-- the default for MathML and OMML is ')'. -->
      <xsl:if test="$fChCloseValid=1 and not($chClose = ')')">
             <m:endChr>
                <xsl:attribute name="m:val">
                   <xsl:value-of select="$chClose"/>
                </xsl:attribute>
             </m:endChr>
          </xsl:if>
       </m:dPr>
    </xsl:if>
</xsl:template>

<!-- %%Template: OutputMs
-->
<xsl:template name="OutputMs">
    <xsl:param name="msCur"/>
    <xsl:choose>
       <xsl:when test="(not($msCur/@lquote) or $msCur/@lquote='') and (not($msCur/@lquote) or $msCur/@lquote='')">
          <xsl:text>"</xsl:text>
       </xsl:when>
       <xsl:otherwise>
          <xsl:choose>
             <xsl:when test="$msCur/@lquote">
                <xsl:value-of select="$msCur/@lquote"/>
             </xsl:when>
             <xsl:otherwise>
                <xsl:value-of select="$msCur/@lquote"/>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="normalize-space($msCur)"/>
    <xsl:choose>
       <xsl:when test="(not($msCur/@rquote) or $msCur/@rquote='') and (not($msCur/@rquote) or $msCur/@rquote='')">
          <xsl:text>"</xsl:text>
       </xsl:when>
       <xsl:otherwise>
          <xsl:choose>
             <xsl:when test="$msCur/@rquote">
                <xsl:value-of select="$msCur/@rquote"/>
             </xsl:when>
             <xsl:otherwise>
                <xsl:value-of select="$msCur/@rquote"/>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- %%Template: match msub
-->
<xsl:template mode="mml" match="msub">
    <xsl:variable name="fNary">
       <xsl:call-template name="isNary">
          <xsl:with-param name="ndCur" select="child::*[1]"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
       <xsl:when test="$fNary='true'">
          <m:nary>
             <xsl:call-template name="CreateNaryProp">
                <xsl:with-param name="chr">
                   <xsl:value-of select="normalize-space(child::*[1])"/>
                </xsl:with-param>
                <xsl:with-param name="sMathmlType" select="'msub'"/>
             </xsl:call-template>
             <m:sub>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[2]"/>
             </m:sub>
             <m:sup>
                <xsl:call-template name="CreateArgProp"/>
             </m:sup>
             <m:e>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:call-template name="NaryHandleMrowMstyle">
                   <xsl:with-param name="ndCur" select="following-sibling::*[1]"/>
                </xsl:call-template>
             </m:e>
          </m:nary>
       </xsl:when>
       <xsl:otherwise>
          <m:sSub>
             <m:e>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[1]"/>
             </m:e>
             <m:sub>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[2]"/>
             </m:sub>
          </m:sSub>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- %%Template: match msup
-->
<xsl:template mode="mml" match="msup">
    <xsl:variable name="fNary">
       <xsl:call-template name="isNary">
          <xsl:with-param name="ndCur" select="child::*[1]"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
       <xsl:when test="$fNary='true'">
          <m:nary>
             <xsl:call-template name="CreateNaryProp">
                <xsl:with-param name="chr">
                   <xsl:value-of select="normalize-space(child::*[1])"/>
                </xsl:with-param>
                <xsl:with-param name="sMathmlType" select="'msup'"/>
             </xsl:call-template>
             <m:sub>
                <xsl:call-template name="CreateArgProp"/>
             </m:sub>
             <m:sup>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[2]"/>
             </m:sup>
             <m:e>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:call-template name="NaryHandleMrowMstyle">
                   <xsl:with-param name="ndCur" select="following-sibling::*[1]"/>
                </xsl:call-template>
             </m:e>
          </m:nary>
       </xsl:when>
       <xsl:otherwise>
          <m:sSup>
             <m:e>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[1]"/>
             </m:e>
             <m:sup>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[2]"/>
             </m:sup>
          </m:sSup>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- %%Template: match msubsup
-->
<xsl:template mode="mml" match="msubsup">
    <xsl:variable name="fNary">
       <xsl:call-template name="isNary">
          <xsl:with-param name="ndCur" select="child::*[1]"/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
       <xsl:when test="$fNary='true'">
          <m:nary>
             <xsl:call-template name="CreateNaryProp">
                <xsl:with-param name="chr">
                   <xsl:value-of select="normalize-space(child::*[1])"/>
                </xsl:with-param>
                <xsl:with-param name="sMathmlType" select="'msubsup'"/>
             </xsl:call-template>
             <m:sub>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[2]"/>
             </m:sub>
             <m:sup>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[3]"/>
             </m:sup>
             <m:e>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:call-template name="NaryHandleMrowMstyle">
                   <xsl:with-param name="ndCur" select="following-sibling::*[1]"/>
                </xsl:call-template>
             </m:e>
          </m:nary>
       </xsl:when>
       <xsl:otherwise>
          <m:sSubSup>
             <m:e>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[1]"/>
             </m:e>
             <m:sub>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[2]"/>
             </m:sub>
             <m:sup>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[3]"/>
             </m:sup>
          </m:sSubSup>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- %%Template: SplitScripts

  Takes an collection of nodes, and splits them
  odd and even into sup and sub scripts. Used for dealing with
  mmultiscript.

  This template assumes you want to output both a sub and sup element.
  -->
<xsl:template name="SplitScripts">
    <xsl:param name="ndScripts"/>
    <m:sub>
       <xsl:call-template name="CreateArgProp"/>
       <xsl:apply-templates mode="mml" select="$ndScripts[(position() mod 2) = 1]"/>
    </m:sub>
    <m:sup>
       <xsl:call-template name="CreateArgProp"/>
       <xsl:apply-templates mode="mml" select="$ndScripts[(position() mod 2) = 0]"/>
    </m:sup>
</xsl:template>

<!-- %%Template: match mmultiscripts

  There is some subtlety with the m:mprescripts element. Everything that comes before
  that is considered a script (as opposed to a pre-script), but it need not be present.
-->
<xsl:template mode="mml" match="mmultiscripts">

  <!-- count the nodes. Everything that comes after a mprescripts is considered a pre-script;
    Everything that does not have an mprescript as a preceding-sibling (and is not itself
    mprescript) is a script, except for the first child which is always the base.
    The none element is a place holder for a sub/sup element slot.

    mmultisript pattern:
    <mmultiscript>
      (base)
      (sub sup)* // Where <none/> can replace a sub/sup entry to preserve pattern.
      <mprescripts />
      (presub presup)*
    </mmultiscript>
    -->
  <!-- Count of presecript nodes that we'd print (this is essentially anything but the none placeholder. -->
  <xsl:variable name="cndPrescriptStrict"
                  select="count(mprescripts[1]/following-sibling::*[not(self::none)])"/>
    <!-- Count of all super script excluding none -->
  <xsl:variable name="cndSuperScript"
                  select="count(*[not(preceding-sibling::mprescripts) and not(self::mprescripts) and ((position() mod 2) = 1) and not(self::none)]) - 1"/>
    <!-- Count of all sup script excluding none -->
  <xsl:variable name="cndSubScript"
                  select="count(*[not(preceding-sibling::mprescripts)  and not(self::mprescripts) and ((position() mod 2) = 0) and not(self::none)])"/>
    <!-- Count of all scripts excluding none -->
  <xsl:variable name="cndScriptStrict" select="$cndSuperScript + $cndSubScript"/>
    <!-- Count of all scripts including none.  This is essentially all nodes before the
  first mprescripts except the base. -->
  <xsl:variable name="cndScript"
                  select="count(*[not(preceding-sibling::mprescripts) and not(self::mprescripts)]) - 1"/>

    <xsl:choose>
    <!-- The easy case first. No prescripts, and no script ... just a base -->
    <xsl:when test="$cndPrescriptStrict &lt;= 0 and $cndScriptStrict &lt;= 0">
          <xsl:apply-templates mode="mml" select="*[1]"/>
       </xsl:when>

       <!-- Next, if there are no prescripts -->
    <xsl:when test="$cndPrescriptStrict &lt;= 0">
      <!-- we know we have some scripts or else we would have taken the earlier
          branch. -->
      <xsl:choose>
        <!-- We have both sub and super scripts-->
        <xsl:when test="$cndSuperScript &gt; 0 and $cndSubScript &gt; 0">
                <m:sSubSup>
                   <m:e>
                      <xsl:call-template name="CreateArgProp"/>
                      <xsl:apply-templates mode="mml" select="child::*[1]"/>
                   </m:e>

                   <!-- Every child except the first is a script.  Do the split -->
            <xsl:call-template name="SplitScripts">
                      <xsl:with-param name="ndScripts" select="*[position() &gt; 1]"/>
                   </xsl:call-template>
                </m:sSubSup>
             </xsl:when>
             <!-- Just a sub script -->
        <xsl:when test="$cndSubScript &gt; 0">
                <m:sSub>
                   <m:e>
                      <xsl:call-template name="CreateArgProp"/>
                      <xsl:apply-templates mode="mml" select="child::*[1]"/>
                   </m:e>

                   <!-- No prescripts and no super scripts, therefore, it's a sub. -->
            <m:sub>
                      <xsl:apply-templates mode="mml" select="*[position() &gt; 1]"/>
                   </m:sub>
                </m:sSub>
             </xsl:when>
             <!-- Just super script -->
        <xsl:otherwise>
                <m:sSup>
                   <m:e>
                      <xsl:call-template name="CreateArgProp"/>
                      <xsl:apply-templates mode="mml" select="child::*[1]"/>
                   </m:e>

                   <!-- No prescripts and no sub scripts, therefore, it's a sup. -->
            <m:sup>
                      <xsl:apply-templates mode="mml" select="*[position() &gt; 1]"/>
                   </m:sup>
                </m:sSup>
             </xsl:otherwise>
          </xsl:choose>
       </xsl:when>

       <!-- Next, if there are no scripts -->
    <xsl:when test="$cndScriptStrict &lt;= 0">
      <!-- we know we have some prescripts or else we would have taken the earlier
          branch. So, create an sPre and split the elements -->
      <m:sPre>
             <m:e>
                <xsl:call-template name="CreateArgProp"/>
                <xsl:apply-templates mode="mml" select="child::*[1]"/>
             </m:e>

             <!-- The prescripts come after the m:mprescript and if we get here
            we know there exists some elements after the mprescript element.

            The prescript element has no sub/subsup variation, therefore, even if
            we're only writing sub, we need to write out both the sub and sup element.
            -->
        <xsl:call-template name="SplitScripts">
                <xsl:with-param name="ndScripts" select="mprescripts[1]/following-sibling::*"/>
             </xsl:call-template>
          </m:sPre>
       </xsl:when>

       <!-- Finally, the case with both prescripts and scripts. Create an sPre
      element to house the prescripts, with a sub/sup/subsup element at its base. -->
    <xsl:otherwise>
          <m:sPre>
             <m:e>
                <xsl:choose>
            <!-- We have both sub and super scripts-->
            <xsl:when test="$cndSuperScript &gt; 0 and $cndSubScript &gt; 0">
                      <m:sSubSup>
                         <m:e>
                            <xsl:call-template name="CreateArgProp"/>
                            <xsl:apply-templates mode="mml" select="child::*[1]"/>
                         </m:e>

                         <!-- scripts come before the m:mprescript but after the first child, so their
               positions will be 2, 3, ... ($nndScript + 1) -->
                <xsl:call-template name="SplitScripts">
                            <xsl:with-param name="ndScripts"
                                            select="*[(position() &gt; 1) and (position() &lt;= ($cndScript + 1))]"/>
                         </xsl:call-template>
                      </m:sSubSup>
                   </xsl:when>
                   <!-- Just a sub script -->
            <xsl:when test="$cndSubScript &gt; 0">
                      <m:sSub>
                         <m:e>
                            <xsl:call-template name="CreateArgProp"/>
                            <xsl:apply-templates mode="mml" select="child::*[1]"/>
                         </m:e>

                         <!-- We have prescripts but no super scripts, therefore, do a sub
                and apply templates to all tokens counted by cndScript. -->
                <m:sub>
                            <xsl:apply-templates mode="mml" select="*[position() &gt; 1 and (position() &lt;= ($cndScript + 1))]"/>
                         </m:sub>
                      </m:sSub>
                   </xsl:when>
                   <!-- Just super script -->
            <xsl:otherwise>
                      <m:sSup>
                         <m:e>
                            <xsl:call-template name="CreateArgProp"/>
                            <xsl:apply-templates mode="mml" select="child::*[1]"/>
                         </m:e>

                         <!-- We have prescripts but no sub scripts, therefore, do a sub
                and apply templates to all tokens counted by cndScript. -->
                <m:sup>
                            <xsl:apply-templates mode="mml" select="*[position() &gt; 1 and (position() &lt;= ($cndScript + 1))]"/>
                         </m:sup>
                      </m:sSup>
                   </xsl:otherwise>
                </xsl:choose>
             </m:e>

             <!-- The prescripts come after the m:mprescript and if we get here
            we know there exists one such element -->
        <xsl:call-template name="SplitScripts">
                <xsl:with-param name="ndScripts" select="mprescripts[1]/following-sibling::*"/>
             </xsl:call-template>
          </m:sPre>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Template that determines if ndCur is an equation array.

     ndCur is an equation array if:

     0.  The table has a columnalign other than the default (center)
     1.  There are are no frame lines
     2.  There are no column lines
     3.  There are no row lines
     4.  There is no row with more than 1 column
     5.  There is no row with fewer than 1 column
     6.  There are no labeled rows.

-->
<xsl:template name="FIsEqArray">
    <xsl:param name="ndCur" select="."/>

    <!-- There should be no frame, columnlines, or rowlines -->
  <xsl:choose>
       <xsl:when test="@columnalign!='center'">0</xsl:when>
       <xsl:when test="(not($ndCur/@frame) or $ndCur/@frame='' or $ndCur/@frame='none')
     and (not($ndCur/@frame) or $ndCur/@frame='' or $ndCur/@frame='none')
     and (not($ndCur/@columnlines) or $ndCur/@columnlines='' or $ndCur/@columnlines='none')
     and (not($ndCur/@columnlines) or $ndCur/@columnlines='' or $ndCur/@columnlines='none')
     and (not($ndCur/@rowlines) or $ndCur/@rowlines='' or $ndCur/@rowlines='none')
     and (not($ndCur/@rowlines) or $ndCur/@rowlines='' or $ndCur/@rowlines='none')
     and not($ndCur/mtr[count(mtd) &gt; 1])
     and not($ndCur/mtr[count(mtd) &lt; 1])
     and not($ndCur/mlabeledtr)">1</xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Template used to determine if we should ignore a collection when iterating through
     a mathml equation array row.

     So far, the only thing that needs to be ignored is the argument of an nary.  We
     can ignore this since it is output when we apply-templates to the munder[over]/msub[sup].
-->
<xsl:template name="FIgnoreCollection">
    <xsl:param name="ndCur" select="."/>

    <xsl:variable name="fNaryArgument">
       <xsl:call-template name="FIsNaryArgument">
          <xsl:with-param name="ndCur" select="$ndCur"/>
       </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
       <xsl:when test="$fNaryArgument=1">1</xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- Template used to determine if we've already encountered an maligngroup or malignmark.

     This is needed because omml has an implicit spacing alignment (omml spacing alignment =
     mathml's maligngroup element) at the beginning of each equation array row.  Therefore,
     the first maligngroup (implied or explicit) we encounter does not need to be output.
     This template recursively searches up the xml tree and looks at previous siblings to see
     if they have a descendant that is an maligngroup or malignmark.  We look for the malignmark
     to find the implicit maligngroup.
-->
<xsl:template name="FFirstAlignAlreadyFound">
    <xsl:param name="ndCur" select="."/>

    <xsl:choose>
       <xsl:when test="count($ndCur/preceding-sibling::*[descendant-or-self::maligngroup or descendant-or-self::malignmark]) &gt; 0">1</xsl:when>
       <xsl:when test="not($ndCur/parent::mtd)">
          <xsl:call-template name="FFirstAlignAlreadyFound">
             <xsl:with-param name="ndCur" select="$ndCur/parent::*"/>
          </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- This template builds a string that is result of concatenating a given string several times.

     Given strToRepeat, create a string that has strToRepeat repeated iRepitions times.
-->
<xsl:template name="ConcatStringRepeat">
    <xsl:param name="strToRepeat" select="''"/>
    <xsl:param name="iRepetitions" select="0"/>
    <xsl:param name="strBuilding" select="''"/>

    <xsl:choose>
       <xsl:when test="$iRepetitions &lt;= 0">
          <xsl:value-of select="$strBuilding"/>
       </xsl:when>
       <xsl:otherwise>
          <xsl:call-template name="ConcatStringRepeat">
             <xsl:with-param name="strToRepeat" select="$strToRepeat"/>
             <xsl:with-param name="iRepetitions" select="$iRepetitions - 1"/>
             <xsl:with-param name="strBuilding" select="concat($strBuilding, $strToRepeat)"/>
          </xsl:call-template>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- This template determines if ndCur is a special collection.
     By special collection, I mean is ndCur the outer element of some special grouping
     of mathml elements that actually represents some over all omml structure.

     For instance, is ndCur a linear fraction, or an omml function.
-->
<xsl:template name="FSpecialCollection">
    <xsl:param name="ndCur" select="."/>
    <xsl:choose>
       <xsl:when test="$ndCur/self::mrow">
          <xsl:variable name="fLinearFraction">
             <xsl:call-template name="FLinearFrac">
                <xsl:with-param name="ndCur" select="$ndCur"/>
             </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="fFunc">
             <xsl:call-template name="FIsFunc">
                <xsl:with-param name="ndCur" select="$ndCur"/>
             </xsl:call-template>
          </xsl:variable>
          <xsl:choose>
             <xsl:when test="$fLinearFraction=1 or $fFunc=1">1</xsl:when>
             <xsl:otherwise>0</xsl:otherwise>
          </xsl:choose>
       </xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- This template iterates through the children of an equation array row (mtr) and outputs
     the equation.

     This template does all the work to output ampersands and skip the right elements when needed.
-->
<xsl:template name="ProcessEqArrayRow">
    <xsl:param name="ndCur" select="."/>

    <xsl:for-each select="$ndCur/*">
       <xsl:variable name="fSpecialCollection">
          <xsl:call-template name="FSpecialCollection">
             <xsl:with-param name="ndCur" select="."/>
          </xsl:call-template>
       </xsl:variable>
       <xsl:variable name="fIgnoreCollection">
          <xsl:call-template name="FIgnoreCollection">
             <xsl:with-param name="ndCur" select="."/>
          </xsl:call-template>
       </xsl:variable>
       <xsl:choose>
      <!-- If we have an alignment element output the ampersand. -->
      <xsl:when test="self::maligngroup or self::malignmark">
        <!-- Omml has an implied spacing alignment at the beginning of each equation.
             Therefore, if this is the first ampersand to be output, don't actually output. -->
        <xsl:variable name="fFirstAlignAlreadyFound">
                <xsl:call-template name="FFirstAlignAlreadyFound">
                   <xsl:with-param name="ndCur" select="."/>
                </xsl:call-template>
             </xsl:variable>
             <!-- Don't output unless it is an malignmark or we have already previously found an alignment point. -->
        <xsl:if test="self::malignmark or $fFirstAlignAlreadyFound=1">
                <m:r>
                   <m:t>&amp;</m:t>
                </m:r>
             </xsl:if>
          </xsl:when>
          <!-- If this node is an non-special mrow or mstyle and we aren't supposed to ignore this collection, then
           go ahead an apply templates to this node. -->
      <xsl:when test="$fIgnoreCollection=0 and ((self::mrow and $fSpecialCollection=0) or self::mstyle)">
             <xsl:call-template name="ProcessEqArrayRow">
                <xsl:with-param name="ndCur" select="."/>
             </xsl:call-template>
          </xsl:when>
          <!-- At this point we have some mathml structure (fraction, nary, non-grouping element, etc.) -->
      <!-- If this mathml structure has alignment groups or marks as children, then extract those since
           omml can't handle that. -->
      <xsl:when test="descendant::maligngroup or descendant::malignmark">
             <xsl:variable name="cMalignGroups">
                <xsl:value-of select="count(descendant::maligngroup)"/>
             </xsl:variable>
             <xsl:variable name="cMalignMarks">
                <xsl:value-of select="count(descendant::malignmark)"/>
             </xsl:variable>
             <!-- Output all maligngroups and malignmarks as '&amp;' -->
        <xsl:if test="$cMalignGroups + $cMalignMarks &gt; 0">
                <xsl:variable name="str">
                   <xsl:call-template name="ConcatStringRepeat">
                      <xsl:with-param name="strToRepeat" select="'&amp;'"/>
                      <xsl:with-param name="iRepetitions" select="$cMalignGroups + $cMalignMarks"/>
                      <xsl:with-param name="strBuilding" select="''"/>
                   </xsl:call-template>
                </xsl:variable>
                <m:r>
                   <m:t>
                      <xsl:call-template name="OutputText">
                         <xsl:with-param name="sInput" select="$str"/>
                      </xsl:call-template>
                   </m:t>
                </m:r>
             </xsl:if>
             <!-- Now that the '&amp;' have been extracted, just apply-templates to this node.-->
        <xsl:apply-templates mode="mml" select="."/>
          </xsl:when>
          <!-- If there are no alignment points as descendants, then go ahead and output this node. -->
      <xsl:otherwise>
             <xsl:apply-templates mode="mml" select="."/>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:for-each>
</xsl:template>

<!-- This template transforms mtable into its appropriate omml type.

     There are two possible omml constructs that an mtable can become:  a matrix or
     an equation array.

     Because omml has no generic table construct, the omml matrix is the best approximate
     for a mathml table.

     Our equation array transformation is very simple.  The main goal of this transform is to
     allow roundtripping omml eq arrays through mathml.  The template ProcessEqArrayRow was never
     intended to account for many of the alignment flexibilities that are present in mathml like
     using the alig attribute, using alignmark attribute in token elements, etc.

     The restrictions on this transform require <malignmark> and <maligngroup> elements to be outside of
     any non-grouping mathml elements (that is, mrow and mstyle).  Moreover, these elements cannot be the children of
     mrows that represent linear fractions or functions.  Also, <malignmark> cannot be a child
     of token attributes.

     In the case that the above

-->
<xsl:template mode="mml" match="mtable">
    <xsl:variable name="fEqArray">
       <xsl:call-template name="FIsEqArray">
          <xsl:with-param name="ndCur" select="."/>
       </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="alignment">
<xsl:value-of select="@columnalign"/>
    </xsl:variable>
    <xsl:choose>
       <xsl:when test="$fEqArray=1">
          <m:eqArr>
      <xsl:if test="$alignment!=''">
  <m:eqArrPr>
    <baseJc m:val="{$alignment}"/>
  </m:eqArrPr>
      </xsl:if>
             <xsl:for-each select="mtr">
                <m:e>
                   <xsl:call-template name="ProcessEqArrayRow">
                      <xsl:with-param name="ndCur" select="mtd"/>
                   </xsl:call-template>
                </m:e>
             </xsl:for-each>
          </m:eqArr>
       </xsl:when>
       <xsl:otherwise>
          <xsl:variable name="cMaxElmtsInRow">
             <xsl:call-template name="CountMaxElmtsInRow">
                <xsl:with-param name="ndCur" select="*[1]"/>
                <xsl:with-param name="cMaxElmtsInRow" select="0"/>
             </xsl:call-template>
          </xsl:variable>
          <m:m>
             <m:mPr>
                <m:baseJc m:val="center"/>
                <m:plcHide m:val="on"/>
                <m:mcs>
                   <m:mc>
                      <m:mcPr>
                         <m:count>
                            <xsl:attribute name="m:val">
                               <xsl:value-of select="$cMaxElmtsInRow"/>
                            </xsl:attribute>
                         </m:count>
                         <m:mcJc m:val="{$alignment}"/>
                      </m:mcPr>
                   </m:mc>
                </m:mcs>
             </m:mPr>
             <xsl:for-each select="*">
                <xsl:choose>
                   <xsl:when test="self::mtr or self::mlabeledtr">
                      <m:mr>
                         <xsl:choose>
                            <xsl:when test="self::mtr">
                               <xsl:for-each select="*">
                                  <m:e>
                                     <xsl:apply-templates mode="mml" select="."/>
                                  </m:e>
                               </xsl:for-each>
                               <xsl:call-template name="CreateEmptyElmt">
                                  <xsl:with-param name="cEmptyMtd" select="$cMaxElmtsInRow - count(*)"/>
                               </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                               <xsl:for-each select="*[position() &gt; 1]">
                                  <m:e>
                                     <xsl:apply-templates mode="mml" select="."/>
                                  </m:e>
                               </xsl:for-each>
                               <xsl:call-template name="CreateEmptyElmt">
                                  <xsl:with-param name="cEmptyMtd" select="$cMaxElmtsInRow - (count(*) - 1)"/>
                               </xsl:call-template>
                            </xsl:otherwise>
                         </xsl:choose>
                      </m:mr>
                   </xsl:when>
                   <xsl:otherwise>
                      <m:mr>
                         <m:e>
                            <xsl:apply-templates mode="mml" select="."/>
                         </m:e>
                         <xsl:call-template name="CreateEmptyElmt">
                            <xsl:with-param name="cEmptyMtd" select="$cMaxElmtsInRow - 1"/>
                         </xsl:call-template>
                      </m:mr>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:for-each>
          </m:m>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template mode="mml" match="mtd">
    <xsl:apply-templates mode="mml"/>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template name="CreateEmptyElmt">
    <xsl:param name="cEmptyMtd"/>
    <xsl:if test="$cEmptyMtd &gt; 0">
       <m:e/>
       <xsl:call-template name="CreateEmptyElmt">
          <xsl:with-param name="cEmptyMtd" select="$cEmptyMtd - 1"/>
       </xsl:call-template>
    </xsl:if>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template name="CountMaxElmtsInRow">
    <xsl:param name="ndCur"/>
    <xsl:param name="cMaxElmtsInRow" select="0"/>
    <xsl:choose>
       <xsl:when test="not($ndCur)">
          <xsl:value-of select="$cMaxElmtsInRow"/>
       </xsl:when>
       <xsl:otherwise>
          <xsl:call-template name="CountMaxElmtsInRow">
             <xsl:with-param name="ndCur" select="$ndCur/following-sibling::*[1]"/>
             <xsl:with-param name="cMaxElmtsInRow">
                <xsl:choose>
                   <xsl:when test="local-name($ndCur) = 'mlabeledtr' and namespace-uri($ndCur) = 'http://www.w3.org/1998/Math/MathML'">
                      <xsl:choose>
                         <xsl:when test="(count($ndCur/*) - 1) &gt; $cMaxElmtsInRow">
                            <xsl:value-of select="count($ndCur/*) - 1"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="$cMaxElmtsInRow"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:when>
                   <xsl:when test="local-name($ndCur) = 'mtr' and namespace-uri($ndCur) = 'http://www.w3.org/1998/Math/MathML'">
                      <xsl:choose>
                         <xsl:when test="count($ndCur/*) &gt; $cMaxElmtsInRow">
                            <xsl:value-of select="count($ndCur/*)"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="$cMaxElmtsInRow"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:choose>
                         <xsl:when test="1 &gt; $cMaxElmtsInRow">
                            <xsl:value-of select="1"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="$cMaxElmtsInRow"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:with-param>
          </xsl:call-template>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template mode="mml" match="mglyph">
    <xsl:call-template name="CreateMglyph"/>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template mode="mml"
               match="mi[child::mglyph] | mn[child::mglyph] | mo[child::mglyph] | ms[child::mglyph] | mtext[child::mglyph]">
    <xsl:if test="string-length(normalize-space(.)) &gt; 0">
       <m:r>
          <xsl:call-template name="CreateRunProp">
             <xsl:with-param name="mathvariant">
                <xsl:choose>
                   <xsl:when test="@mathvariant">
                      <xsl:value-of select="@mathvariant"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="@mathvariant"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:with-param>
             <xsl:with-param name="fontstyle">
                <xsl:choose>
                   <xsl:when test="@fontstyle">
                      <xsl:value-of select="@fontstyle"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="@fontstyle"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:with-param>
             <xsl:with-param name="fontweight">
                <xsl:choose>
                   <xsl:when test="@fontweight">
                      <xsl:value-of select="@fontweight"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="@fontweight"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:with-param>
             <xsl:with-param name="mathcolor">
                <xsl:choose>
                   <xsl:when test="@mathcolor">
                      <xsl:value-of select="@mathcolor"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="@mathcolor"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:with-param>
             <xsl:with-param name="mathsize">
                <xsl:choose>
                   <xsl:when test="@mathsize">
                      <xsl:value-of select="@mathsize"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="@mathsize"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:with-param>
             <xsl:with-param name="color">
                <xsl:choose>
                   <xsl:when test="@color">
                      <xsl:value-of select="@color"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="@color"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:with-param>
             <xsl:with-param name="fontsize">
                <xsl:choose>
                   <xsl:when test="@fontsize">
                      <xsl:value-of select="@fontsize"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="@fontsize"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:with-param>
             <xsl:with-param name="fNor">
                <xsl:call-template name="FNor">
                   <xsl:with-param name="ndCur" select="."/>
                </xsl:call-template>
             </xsl:with-param>
             <xsl:with-param name="fLit">
                <xsl:call-template name="FLit">
                   <xsl:with-param name="ndCur" select="."/>
                </xsl:call-template>
             </xsl:with-param>
             <xsl:with-param name="ndCur" select="."/>
          </xsl:call-template>
          <m:t>
             <xsl:call-template name="OutputText">
                <xsl:with-param name="sInput">
                   <xsl:choose>
                      <xsl:when test="self::ms">
                         <xsl:call-template name="OutputMs">
                            <xsl:with-param name="msCur" select="."/>
                         </xsl:call-template>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="normalize-space(.)"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:with-param>
             </xsl:call-template>
          </m:t>
       </m:r>
    </xsl:if>
    <xsl:for-each select="child::mglyph">
       <xsl:call-template name="CreateMglyph">
          <xsl:with-param name="ndCur" select="."/>
       </xsl:call-template>
    </xsl:for-each>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template name="FGlyphIndexOk">
    <xsl:param name="index"/>
    <xsl:if test="$index != ''">
       <xsl:choose>
          <xsl:when test="string(number(string(floor($index)))) = 'NaN'"/>
          <xsl:when test="number($index) &lt; 32 and not(number($index) = 9 or number($index) = 10 or number($index) = 13)"/>
          <xsl:when test="number($index) = 65534 or number($index) = 65535"/>
          <xsl:otherwise>1</xsl:otherwise>
       </xsl:choose>
    </xsl:if>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template name="CreateMglyph">
    <xsl:param name="ndCur"/>
    <m:r>
       <xsl:call-template name="CreateRunProp">
          <xsl:with-param name="mathvariant">
             <xsl:choose>
                <xsl:when test="(not(@mathvariant) or @mathvariant='') and (not(@mathvariant) or @mathvariant='') and (../@mathvariant!='' or ../@mathvariant!='')">
                   <xsl:choose>
                      <xsl:when test="../@mathvariant">
                         <xsl:value-of select="../@mathvariant"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="../mathvariant"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:choose>
                      <xsl:when test="@mathvariant">
                         <xsl:value-of select="@mathvariant"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@mathvariant"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="fontstyle">
             <xsl:choose>
                <xsl:when test="(not(@fontstyle) or @fontstyle='') and (not(@fontstyle) or @fontstyle='') and (../@fontstyle!='' or ../@fontstyle!='')">
                   <xsl:choose>
                      <xsl:when test="../@fontstyle">
                         <xsl:value-of select="../@fontstyle"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="../@fontstyle"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:choose>
                      <xsl:when test="@fontstyle">
                         <xsl:value-of select="@fontstyle"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@fontstyle"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="fontweight">
             <xsl:choose>
                <xsl:when test="(not(@fontweight) or @fontweight='') and (not(@fontweight) or @fontweight='') and (../@fontweight!='' or ../@fontweight!='')">
                   <xsl:choose>
                      <xsl:when test="../@fontweight">
                         <xsl:value-of select="../@fontweight"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="../@fontweight"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:choose>
                      <xsl:when test="@fontweight">
                         <xsl:value-of select="@fontweight"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@fontweight"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="mathcolor">
             <xsl:choose>
                <xsl:when test="(not(@mathcolor) or @mathcolor='') and (not(@mathcolor) or @mathcolor='') and (../@mathcolor!='' or ../@mathcolor!='')">
                   <xsl:choose>
                      <xsl:when test="../@mathcolor">
                         <xsl:value-of select="../@mathcolor"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="../@mathcolor"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:choose>
                      <xsl:when test="@mathcolor">
                         <xsl:value-of select="@mathcolor"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@mathcolor"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="mathsize">
             <xsl:choose>
                <xsl:when test="(not(@mathsize) or @mathsize='') and (not(@mathsize) or @mathsize='') and (../@mathsize!='' or ../@mathsize!='')">
                   <xsl:choose>
                      <xsl:when test="../@mathsize">
                         <xsl:value-of select="../@mathsize"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="../@mathsize"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:choose>
                      <xsl:when test="@mathsize">
                         <xsl:value-of select="@mathsize"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@mathsize"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="color">
             <xsl:choose>
                <xsl:when test="(not(@color) or @color='') and (not(@color) or @color='') and (../@color!='' or ../@color!='')">
                   <xsl:choose>
                      <xsl:when test="../@color">
                         <xsl:value-of select="../@color"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="../@color"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:choose>
                      <xsl:when test="@color">
                         <xsl:value-of select="@color"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@color"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="fontsize">
             <xsl:choose>
                <xsl:when test="(not(@fontsize) or @fontsize='') and (not(@m:fontsize) or @fontsize='') and (../@fontsize!='' or ../@fontsize!='')">
                   <xsl:choose>
                      <xsl:when test="../@fontsize">
                         <xsl:value-of select="../@fontsize"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="../@fontsize"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:choose>
                      <xsl:when test="@fontsize">
                         <xsl:value-of select="@fontsize"/>
                      </xsl:when>
                      <xsl:otherwise>
                         <xsl:value-of select="@fontsize"/>
                      </xsl:otherwise>
                   </xsl:choose>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="ndCur" select="."/>
          <xsl:with-param name="font-family">
             <xsl:choose>
                <xsl:when test="@fontfamily">
                   <xsl:value-of select="@fontfamily"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="@fontfamily"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="fNor">
             <xsl:call-template name="FNor">
                <xsl:with-param name="ndCur" select="."/>
             </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="fLit">
             <xsl:call-template name="FLit">
                <xsl:with-param name="ndCur" select="."/>
             </xsl:call-template>
          </xsl:with-param>
       </xsl:call-template>
       <xsl:variable name="shouldGlyphUseIndex">
          <xsl:call-template name="FGlyphIndexOk">
             <xsl:with-param name="index">
                <xsl:choose>
                   <xsl:when test="@index">
                      <xsl:value-of select="@index"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="@index"/>
                   </xsl:otherwise>
                </xsl:choose>
             </xsl:with-param>
          </xsl:call-template>
       </xsl:variable>
       <xsl:choose>
          <xsl:when test="not($shouldGlyphUseIndex = '1')">
             <m:t>
                <xsl:choose>
                   <xsl:when test="@alt">
                      <xsl:value-of select="@alt"/>
                   </xsl:when>
                   <xsl:otherwise>
                      <xsl:value-of select="@alt"/>
                   </xsl:otherwise>
                </xsl:choose>
             </m:t>
          </xsl:when>
          <xsl:otherwise>
             <xsl:variable name="nHexIndex">
                <xsl:call-template name="ConvertDecToHex">
                   <xsl:with-param name="index">
                      <xsl:choose>
                         <xsl:when test="@index">
                            <xsl:value-of select="@index"/>
                         </xsl:when>
                         <xsl:otherwise>
                            <xsl:value-of select="@index"/>
                         </xsl:otherwise>
                      </xsl:choose>
                   </xsl:with-param>
                </xsl:call-template>
             </xsl:variable>
             <m:t>
                <xsl:text disable-output-escaping="yes">&amp;#x</xsl:text>
                <xsl:value-of select="$nHexIndex"/>
                <xsl:text>;</xsl:text>
             </m:t>
          </xsl:otherwise>
       </xsl:choose>
    </m:r>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template name="ConvertDecToHex">
    <xsl:param name="index"/>
    <xsl:if test="$index &gt; 0">
       <xsl:call-template name="ConvertDecToHex">
          <xsl:with-param name="index" select="floor($index div 16)"/>
       </xsl:call-template>
       <xsl:choose>
          <xsl:when test="$index mod 16 &lt; 10">
             <xsl:value-of select="$index mod 16"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:choose>
                <xsl:when test="$index mod 16 = 10">A</xsl:when>
                <xsl:when test="$index mod 16 = 11">B</xsl:when>
                <xsl:when test="$index mod 16 = 12">C</xsl:when>
                <xsl:when test="$index mod 16 = 13">D</xsl:when>
                <xsl:when test="$index mod 16 = 14">E</xsl:when>
                <xsl:when test="$index mod 16 = 15">F</xsl:when>
                <xsl:otherwise>A</xsl:otherwise>
             </xsl:choose>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:if>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template name="FStrContainsNonZeroDigit">
    <xsl:param name="s"/>

    <!-- Translate any nonzero digit into a 9 -->
  <xsl:variable name="sNonZeroDigitsToNineDigit" select="translate($s, '12345678', '99999999')"/>
    <xsl:choose>
    <!-- Search for 9s -->
    <xsl:when test="contains($sNonZeroDigitsToNineDigit, '9')">1</xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template name="FStrContainsDigits">
    <xsl:param name="s"/>

    <!-- Translate any digit into a 0 -->
  <xsl:variable name="sDigitsToZeroDigit" select="translate($s, '123456789', '000000000')"/>
    <xsl:choose>
    <!-- Search for 0s -->
    <xsl:when test="contains($sDigitsToZeroDigit, '0')">1</xsl:when>
       <xsl:otherwise>0</xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Used to determine if mpadded attribute {width, height, depth }
     indicates to show everything.

     Unlike mathml, whose mpadded structure has great flexibility in modifying the
     bounding box's width, height, and depth, Word can only have zero or full width, height, and depth.
     Thus, if the width, height, or depth attributes indicate any kind of nonzero width, height,
     or depth, we'll translate that into a show full width, height, or depth for OMML.  Only if the attribute
     indicates a zero width, height, or depth, will we report back FFull as false.

     Example:  s=0%    ->  FFull returns 0.
               s=2%    ->  FFull returns 1.
               s=0.1em ->  FFull returns 1.

     -->
<xsl:template name="FFull">
    <xsl:param name="s"/>

    <xsl:variable name="fStrContainsNonZeroDigit">
       <xsl:call-template name="FStrContainsNonZeroDigit">
          <xsl:with-param name="s" select="$s"/>
       </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="fStrContainsDigits">
       <xsl:call-template name="FStrContainsDigits">
          <xsl:with-param name="s" select="$s"/>
       </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
    <!-- String contained non-zero digit -->
    <xsl:when test="$fStrContainsNonZeroDigit=1">1</xsl:when>
       <!-- String didn't contain a non-zero digit, but it did contain digits.
         This must mean that all digits in the string were 0s. -->
    <xsl:when test="$fStrContainsDigits=1">0</xsl:when>
       <!-- Else, no digits, therefore, return true.
         We return true in the otherwise condition to take account for the possibility
         in MathML to say something like width="height". -->
    <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
</xsl:template>


<!-- Just outputs phant properties, doesn't do any fancy
     thinking of its own, just obeys the defaults of
     phants. -->
<xsl:template name="CreatePhantPropertiesCore">
    <xsl:param name="fShow" select="1"/>
    <xsl:param name="fFullWidth" select="1"/>
    <xsl:param name="fFullHeight" select="1"/>
    <xsl:param name="fFullDepth" select="1"/>

    <xsl:if test="$fShow=0 or $fFullWidth=0 or $fFullHeight=0 or $fFullDepth=0">
       <m:phantPr>
          <xsl:if test="$fShow=0">
             <m:show>
                <xsl:attribute name="m:val">off</xsl:attribute>
             </m:show>
          </xsl:if>
          <xsl:if test="$fFullWidth=0">
             <m:zeroWid>
                <xsl:attribute name="m:val">on</xsl:attribute>
             </m:zeroWid>
          </xsl:if>
          <xsl:if test="$fFullHeight=0">
             <m:zeroAsc>
                <xsl:attribute name="m:val">on</xsl:attribute>
             </m:zeroAsc>
          </xsl:if>
          <xsl:if test="$fFullDepth=0">
             <m:zeroDesc>
                <xsl:attribute name="m:val">on</xsl:attribute>
             </m:zeroDesc>
          </xsl:if>
       </m:phantPr>
    </xsl:if>
</xsl:template>

<!-- Figures out if we should factor in width, height, and depth attributes.

     If so, then it
     gets these attributes, does some processing to figure out what the attributes indicate,
     then passes these indications to CreatePhantPropertiesCore.

     If we aren't supposed to factor in width, height, or depth, then we'll just output the show
     attribute. -->
<xsl:template name="CreatePhantProperties">
    <xsl:param name="ndCur" select="."/>
    <xsl:param name="fShow" select="1"/>

    <xsl:choose>
    <!-- In the special case that we have an mphantom with one child which is an mpadded, then we should
         subsume the mpadded attributes into the mphantom attributes.  The test statement below imples the
         'one child which is an mpadded'.  The first part, that the parent of mpadded is an mphantom, is implied
         by being in this template, which is only called when we've encountered an mphantom.

         Word outputs its invisible phantoms with smashing as

            <m:mphantom>
              <m:mpadded . . . >

              </m:mpadded>
            </m:mphantom>

          This test is used to allow roundtripping smashed invisible phantoms. -->
    <xsl:when test="count($ndCur/child::*)=1 and count($ndCur/mpadded)=1">
          <xsl:variable name="sLowerCaseWidth">
             <xsl:choose>
                <xsl:when test="$ndCur/mpadded/@width">
                   <xsl:value-of select="translate($ndCur/mpadded/@width, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="translate($ndCur/mpadded/@width, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:variable>
          <xsl:variable name="sLowerCaseHeight">
             <xsl:choose>
                <xsl:when test="$ndCur/mpadded/@height">
                   <xsl:value-of select="translate($ndCur/mpadded/@height, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="translate($ndCur/mpadded/@height, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:variable>
          <xsl:variable name="sLowerCaseDepth">
             <xsl:choose>
                <xsl:when test="$ndCur/mpadded/@depth">
                   <xsl:value-of select="translate($ndCur/mpadded/@depth, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="translate($ndCur/mpadded/@depth, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:variable>

          <xsl:variable name="fFullWidth">
             <xsl:call-template name="FFull">
                <xsl:with-param name="s" select="$sLowerCaseWidth"/>
             </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="fFullHeight">
             <xsl:call-template name="FFull">
                <xsl:with-param name="s" select="$sLowerCaseHeight"/>
             </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="fFullDepth">
             <xsl:call-template name="FFull">
                <xsl:with-param name="s" select="$sLowerCaseDepth"/>
             </xsl:call-template>
          </xsl:variable>

          <xsl:call-template name="CreatePhantPropertiesCore">
             <xsl:with-param name="fShow" select="$fShow"/>
             <xsl:with-param name="fFullWidth" select="$fFullWidth"/>
             <xsl:with-param name="fFullHeight" select="$fFullHeight"/>
             <xsl:with-param name="fFullDepth" select="$fFullDepth"/>
          </xsl:call-template>
       </xsl:when>
       <xsl:otherwise>
          <xsl:call-template name="CreatePhantPropertiesCore">
             <xsl:with-param name="fShow" select="$fShow"/>
          </xsl:call-template>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template mode="mml" match="mpadded">
    <xsl:choose>
       <xsl:when test="count(parent::mphantom)=1 and count(preceding-sibling::*)=0 and count(following-sibling::*)=0">
      <!-- This mpadded is inside an mphantom that has already setup phantom attributes, therefore, just apply templates -->
      <xsl:apply-templates mode="mml"/>
       </xsl:when>
       <xsl:otherwise>
          <xsl:variable name="sLowerCaseWidth">
             <xsl:choose>
                <xsl:when test="@width">
                   <xsl:value-of select="@width"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="@width"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:variable>
          <xsl:variable name="sLowerCaseHeight">
             <xsl:choose>
                <xsl:when test="@height">
                   <xsl:value-of select="@height"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="@height"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:variable>
          <xsl:variable name="sLowerCaseDepth">
             <xsl:choose>
                <xsl:when test="@depth">
                   <xsl:value-of select="@depth"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="@depth"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:variable>

          <xsl:variable name="fFullWidth">
             <xsl:call-template name="FFull">
                <xsl:with-param name="s" select="$sLowerCaseWidth"/>
             </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="fFullHeight">
             <xsl:call-template name="FFull">
                <xsl:with-param name="s" select="$sLowerCaseHeight"/>
             </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="fFullDepth">
             <xsl:call-template name="FFull">
                <xsl:with-param name="s" select="$sLowerCaseDepth"/>
             </xsl:call-template>
          </xsl:variable>

          <m:phant>
             <xsl:call-template name="CreatePhantPropertiesCore">
                <xsl:with-param name="fShow" select="1"/>
                <xsl:with-param name="fFullWidth" select="$fFullWidth"/>
                <xsl:with-param name="fFullHeight" select="$fFullHeight"/>
                <xsl:with-param name="fFullDepth" select="$fFullDepth"/>
             </xsl:call-template>
             <m:e>
                <xsl:apply-templates mode="mml"/>
             </m:e>
          </m:phant>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template mode="mml" match="mphantom">
    <m:phant>
       <xsl:call-template name="CreatePhantProperties">
          <xsl:with-param name="ndCur" select="."/>
          <xsl:with-param name="fShow" select="0"/>
       </xsl:call-template>
       <m:e>
          <xsl:apply-templates mode="mml"/>
       </m:e>
    </m:phant>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template name="isNaryOper">
    <xsl:param name="sNdCur"/>
    <xsl:value-of select="($sNdCur = '∫' or $sNdCur = '∬' or $sNdCur = '∭' or $sNdCur = '∮' or $sNdCur = '∯' or $sNdCur = '∰' or $sNdCur = '∲' or $sNdCur = '∳' or $sNdCur = '∱' or $sNdCur = '∩' or $sNdCur = '∪' or $sNdCur = '∏' or $sNdCur = '∐' or $sNdCur = '∑')"/>
</xsl:template>


<!-- office internal mathml template -->
<xsl:template name="isNary">
  <!-- ndCur is the element around the nAry operator -->
  <xsl:param name="ndCur"/>
    <xsl:variable name="sNdCur">
       <xsl:value-of select="normalize-space($ndCur)"/>
    </xsl:variable>

    <xsl:variable name="fNaryOper">
       <xsl:call-template name="isNaryOper">
          <xsl:with-param name="sNdCur" select="$sNdCur"/>
       </xsl:call-template>
    </xsl:variable>

    <!-- Narys shouldn't be MathML accents.  -->
  <xsl:variable name="fUnder">
       <xsl:choose>
          <xsl:when test="$ndCur/parent::*[self::munder]">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
       </xsl:choose>
    </xsl:variable>

    <xsl:variable name="sLowerCaseAccent">
       <xsl:choose>
          <xsl:when test="$fUnder=1">
             <xsl:choose>
                <xsl:when test="$ndCur/parent::*[self::munder]/@accentunder">
                   <xsl:value-of select="translate($ndCur/parent::*[self::munder]/@accentunder, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="translate($ndCur/parent::*[self::munder]/@accentunder, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
             <xsl:choose>
                <xsl:when test="$ndCur/parent::*/@accent">
                   <xsl:value-of select="translate($ndCur/parent::*/@accent, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="translate($ndCur/parent::*/@accent, $StrUCAlphabet, $StrLCAlphabet)"/>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:otherwise>
       </xsl:choose>
    </xsl:variable>

    <xsl:variable name="fAccent">
       <xsl:choose>
          <xsl:when test="$sLowerCaseAccent='true'">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
       </xsl:choose>
    </xsl:variable>

    <xsl:choose>
    <!-- This ndCur is in fact part of an nAry if

         1)  The last descendant of ndCur (which could be ndCur itself) is an operator.
         2)  Along that chain of descendants we only encounter mo, mstyle, and mrow elements.
         3)  the operator in mo is a valid nAry operator
         4)  The nAry is not accented.
         -->
    <xsl:when test="$fNaryOper = 'true' and $fAccent=0 and $ndCur/descendant-or-self::*[last()]/self::mo and not($ndCur/descendant-or-self::*[not(self::mo or self::mstyle or self::mrow)])">
          <xsl:value-of select="true()"/>
       </xsl:when>
       <xsl:otherwise>
          <xsl:value-of select="false()"/>
       </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template name="CreateNaryProp">
    <xsl:param name="chr"/>
    <xsl:param name="sMathmlType"/>
    <m:naryPr>
       <m:chr>
          <xsl:attribute name="m:val">
             <xsl:value-of select="$chr"/>
          </xsl:attribute>
       </m:chr>
       <m:limLoc>
          <xsl:attribute name="m:val">
             <xsl:choose>
                <xsl:when test="$sMathmlType='munder' or $sMathmlType='mover' or $sMathmlType='munderover'">
                   <xsl:text>undOvr</xsl:text>
                </xsl:when>
                <xsl:when test="$sMathmlType='msub' or $sMathmlType='msup' or $sMathmlType='msubsup'">
                   <xsl:text>subSup</xsl:text>
                </xsl:when>
             </xsl:choose>
          </xsl:attribute>
       </m:limLoc>
       <m:grow>
          <xsl:attribute name="m:val">
             <xsl:value-of select="'on'"/>
          </xsl:attribute>
       </m:grow>
       <m:subHide>
          <xsl:attribute name="m:val">
             <xsl:choose>
                <xsl:when test="$sMathmlType='mover' or $sMathmlType='msup'">
                   <xsl:text>on</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:text>off</xsl:text>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:attribute>
       </m:subHide>
       <m:supHide>
          <xsl:attribute name="m:val">
             <xsl:choose>
                <xsl:when test="$sMathmlType='munder' or $sMathmlType='msub'">
                   <xsl:text>on</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:text>off</xsl:text>
                </xsl:otherwise>
             </xsl:choose>
          </xsl:attribute>
       </m:supHide>
    </m:naryPr>
</xsl:template>

<!-- office internal mathml template -->
<xsl:template name="mathrRpHook"/>

</xsl:stylesheet>