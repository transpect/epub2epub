<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns="http://www.w3.org/1999/xhtml" 
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs epub"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:param name="heading-level" as="xs:string"/>
  
  <xsl:template match="*[matches(local-name(), concat('^h', $heading-level, '$'))]">
    <xsl:sequence select="epub:repair-heading-order(.)"/>
  </xsl:template>
  
  <xsl:variable name="headings" as="element()*" 
                select="//*[local-name() = ('h1', 'h2', 'h3', 'h4', 'h5', 'h6')]"/>
  
  <xsl:function name="epub:repair-heading-order">
    <xsl:param name="heading" as="element()*"/>
    <xsl:variable name="heading-index" select="index-of($headings, $heading)" as="xs:integer"/>
    <xsl:variable name="current-heading-level" as="xs:integer"
                  select="xs:integer(
                            substring-after($heading/local-name(), 'h')
                          )" />
    <xsl:variable name="previous-heading-level" as="xs:integer"
                  select="xs:integer(
                            substring-after($headings[$heading-index - 1]/local-name(), 'h')
                          )" />
    <xsl:element name="{if($previous-heading-level - $current-heading-level lt -1) 
                        then concat('h', $previous-heading-level + 1)
                        else $heading/local-name()}">
      <xsl:apply-templates select="$heading/@*, $heading/node()"/>
    </xsl:element>
  </xsl:function>
  
</xsl:stylesheet>