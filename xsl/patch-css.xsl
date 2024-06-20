<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="c tr xs"
  version="3.0">
  
  <xsl:param name="href" as="xs:string"/>
  
  <xsl:template name="main">
    <xsl:variable name="css" select="unparsed-text($href)" as="xs:string?"/>
    <c:data content-type="text/plain">
      <xsl:value-of select="tr:patch-css($css)"/>
    </c:data>
  </xsl:template>
  
  <xsl:function name="tr:patch-css" as="xs:string?">
    <xsl:param name="css" as="xs:string"/>
    <xsl:sequence select="replace(
                            replace(
                              replace($css, '&#xD;', ''), 
                                '(font-style:\s*italic\s*),\s*oblique', '$1'
                            ), '(margin|padding)(-(top|right|bottom|left))?(:)?(\s*0)mm', '$1$2$3:$5'
                          )"/>
  </xsl:function>
  
</xsl:stylesheet>