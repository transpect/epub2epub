<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml" 
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs"
  version="3.0">
  
  <xsl:param name="remove-chars-regex" select="'\s'" as="xs:string"/>
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="a/@href[contains(., '#')]">
    <xsl:attribute name="href" select="concat('#', substring-after(., '#'))"/>
  </xsl:template>
  
  <xsl:template match="img/@src">
    <xsl:attribute name="{name()}" select="replace(., $remove-chars-regex, '')"/>
  </xsl:template>
  
  <xsl:template match="head/@*
                      |meta[@http-equiv]"/>
  
</xsl:stylesheet>
