<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns="http://www.w3.org/1999/xhtml" 
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs opf"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:param name="toc-page" as="xs:integer"/>
  
  <xsl:variable name="toc" as="document-node(element(nav))" select="collection()[2]"/>
  
  <xsl:template match="/opf:epub/html/body/div[@class eq 'epub-html-split'][position() = $toc-page]">
    <div class="epub-html-split"/>
    <xsl:apply-templates select="$toc"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>