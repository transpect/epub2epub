<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="c tr xs"
  version="3.0">
  
  <xsl:param name="href" as="xs:string"/>
  
  <xsl:variable name="additional-css" as="document-node(element(c:data))?" 
                select="collection()[2]"/>
  
  <xsl:template name="main">
    <xsl:variable name="css" select="if(unparsed-text-available($href))
                                     then unparsed-text($href)
                                     else unparsed-text($href, 'cp1252')" as="xs:string?"/>
    <c:data content-type="text/plain">
      <xsl:value-of select="tr:patch-css($css)"/>
      <!-- do not display list styles for generated nav toc -->
      <xsl:text>&#xa;nav ol, ol.toc-level-1, ol.toc-level-2, ol.toc-level-3, ol.toc-level-4, ol.toc-level-5, ol.toc-level-6, ol.toc-level-7, ol.toc-level-8, ol.toc-level-9 { list-style:none }</xsl:text>
      <xsl:sequence select="$additional-css/c:data/text()"/>
    </c:data>
  </xsl:template>
  
  <xsl:function name="tr:patch-css" as="xs:string?">
    <xsl:param name="css" as="xs:string"/>
    <xsl:sequence select="replace(
                            replace(
                              replace(
                                replace(
                                  replace(
                                    replace($css, '&#xD;', ''), 
                                      '(font-style:\s*italic\s*),\s*oblique', '$1'
                                    ), '(font-)(weight)(:\s*italic\s*)', '$1style$3'
                                ), '(margin|padding)(-(top|right|bottom|left))?(:)?(\s*0)mm', '$1$2$3:$5'
                              ), '(padding)(-(top|right|bottom|left))?(:)?(-\.|-)?', '$1$2$4'
                            ), '([\d])\.([a-z])', '$1$2'
                          )"/>
  </xsl:function>
  
</xsl:stylesheet>
