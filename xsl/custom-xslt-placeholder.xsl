<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns="http://www.w3.org/1999/xhtml" 
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <!--<xsl:template match="/opf:epub/opf:package/opf:metadata">
    <xsl:copy>
      <xsl:apply-templates select="*"/>
      <meta property="schema:accessibilitySummary">In addition to meeting accessibility standards, 
        this publication includes subtitles for all video content.</meta>
    </xsl:copy>
  </xsl:template>-->
  
</xsl:stylesheet>