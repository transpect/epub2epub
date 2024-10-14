<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:html="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:param name="html-filename" as="xs:string"/>
  <xsl:param name="outdir" as="xs:string"/>
  <xsl:param name="remove-chars-regex" as="xs:string"/>  
  
  <xsl:variable name="opf-uri" as="xs:string" 
                select="replace(/opf:epub/opf:package/@xml:base, '^(.+/).+?$', '$1')"/>
  
  <xsl:template match="/opf:epub">
    <xsl:variable name="resources" as="element(c:file)*">
      <xsl:for-each select="opf:package/opf:manifest/opf:item[not(@media-type = ('application/xhtml+xml', 
                                                                                 'application/x-dtbncx+xml'))]">
        <c:file opf-name="{@href}" name="{concat($opf-uri, @href)}" target="{concat($outdir, '/', replace(@href, $remove-chars-regex, ''))}"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates>
        <xsl:with-param name="resources" as="element(c:file)*" select="$resources" tunnel="yes"/>
      </xsl:apply-templates>
      <c:files>
        <xsl:sequence select="$resources"/>
      </c:files>
    </xsl:copy>
  </xsl:template>
  
  <xsl:variable name="fileref-att-names" as="xs:string*" 
                select="'src', 'data', 'poster', 'href', 'altimg'"/>
  
  <xsl:template match="html:html//*/@*[local-name() = $fileref-att-names]
                                      [not(starts-with(., '#'))]
                                      [not(starts-with(., 'http'))]
                                      [not(starts-with(., 'www.'))]
                                      [not(starts-with(., 'mailto:'))]
                                      [not(matches(., '\.x?html$', 'i'))]">
    <xsl:param name="resources" as="element(c:file)*" tunnel="yes"/>
    <xsl:variable name="fileref" select="replace(., '\.\./', '')" as="xs:string"/>
    <xsl:variable name="normalized-fileref" as="element(c:file)" 
                  select="$resources[matches(@opf-name, $fileref)]"/>
    <xsl:attribute name="{local-name()}" select="$normalized-fileref/@opf-name"/>
  </xsl:template>
  
</xsl:stylesheet>