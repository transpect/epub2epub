<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="c tr xs"
  version="3.0">
  
  <xsl:param name="href"       as="xs:string"/>
  <xsl:param name="hide-toc"   as="xs:string"/>
  <xsl:param name="nav-exists" as="xs:boolean"/>
  
  <xsl:import href="http://transpect.io/xslt-util/strings/xsl/regex-functions.xsl"/>
  
  <xsl:variable name="additional-css" as="document-node(element(c:data))?" 
                select="collection()[2]"/>
  
  <xsl:variable name="css-unit-regex" as="xs:string" 
                select="'(cm|mm|Q|in|pc|pt|px|r?em|vw|vh|%)'"/>
  
  <xsl:template name="main">
    <xsl:variable name="css" select="if(unparsed-text-available($href))
                                     then unparsed-text($href)
                                     else unparsed-text($href, 'cp1252')" as="xs:string?"/>
    <c:data content-type="text/plain">
      <xsl:value-of select="tr:patch-css($css)"/>
      <!-- do not display list styles for generated nav toc -->
      <xsl:text>&#xa;nav ol, ol.toc-level-1, ol.toc-level-2, ol.toc-level-3, ol.toc-level-4, ol.toc-level-5, ol.toc-level-6, ol.toc-level-7, ol.toc-level-8, ol.toc-level-9 { list-style:none }</xsl:text>
      <!-- Hide the table of contents if the option is set to 'yes'. If an EPUB 2.0 ToC 
           is present, we hide the new navigation anyway to avoid duplicate HTML ToCs. 
           Since the EPUB 2.0 spec defines only an NCX ToC and not an HTML ToC, we simply 
           check for the absence of an EPUB 3.0 navigation and assume an EPUB 2.0 HTML 
           ToC might exist. -->
      <xsl:if test="$hide-toc = 'yes' or not($nav-exists)">
        <xsl:text>&#xa;#toc { display:none }</xsl:text>
      </xsl:if>
      <xsl:sequence select="$additional-css/c:data/text()"/>
    </c:data>
  </xsl:template>
  
  <xsl:function name="tr:patch-css" as="xs:string?">
    <xsl:param name="css" as="xs:string"/>
    <xsl:sequence select="tr:replace-list(
                            $css,
                            ('&#xD;',
                             '(font-style:\s*italic\s*),\s*oblique',
                             '(font-)(weight)(:\s*italic\s*)',
                             '(margin|padding)(-(top|right|bottom|left))?(:)?(\s*0)mm',
                             '(padding)(-(top|right|bottom|left))?(:)?(-\.|-)?',
                             concat(':\s*([\d])\.', $css-unit-regex),
                             'a[\p{Z}\p{Cc}]*\{[\p{Z}\p{Cc}]*text-decoration:[\p{Z}\p{Cc}]*none[\p{Z}\p{Cc}]*;[\p{Z}\p{Cc}]*\}'
                            ),
                            ('',
                             '$1',
                             '$1style$3',
                             '$1$2$3:$5',
                             '$1$2$4',
                             ':$1$2',
                             ''
                            )
                          )"/>
  </xsl:function>
  
</xsl:stylesheet>
