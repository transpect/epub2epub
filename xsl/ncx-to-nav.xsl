<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:ncx="http://www.daisy.org/z3986/2005/ncx/"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs epub html ncx"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:param name="toc-page" as="xs:integer"/>
  
  <xsl:variable name="epub" as="document-node(element(opf:epub))"
                select="collection()[1]"/>
  <xsl:variable name="ncx" as="document-node(element(ncx:ncx))"
                select="collection()[2]"/>
  
  <xsl:variable name="manifest-items" as="element(opf:item)*" 
                select="$epub/opf:epub/opf:package/opf:manifest/opf:item"/>
  
  <xsl:key name="id-from-filename" match="$manifest-items" use="@href"/>
  
  <xsl:template match="/opf:epub/html:html/html:body/html:div[@class eq 'epub-html-split'][position() = $toc-page]">
    <div class="epub-html-split"/>
    <xsl:apply-templates select="$ncx"/>
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="$ncx/ncx:ncx">
    <nav role="doc-toc" epub:type="toc" id="toc">
      <xsl:apply-templates select="ncx:navMap"/>
    </nav>
  </xsl:template>
  
  <xsl:template match="ncx:navMap">
    <ol>
      <xsl:apply-templates select="ncx:navPoint"/>
    </ol>
  </xsl:template>
  
  <xsl:template match="ncx:navPoint">
    <li class="{@class}">
      <a href="{if(contains(ncx:content/@src, '#'))
                then concat('#', substring-after(ncx:content/@src, '#'))
                else concat('#', key('id-from-filename', ncx:content/@src)/@id)}">
        <xsl:apply-templates select="ncx:navLabel/ncx:text"/>
      </a>
      <xsl:if test="ncx:navPoint">
        <ol>
          <xsl:apply-templates select="ncx:navPoint"/>
        </ol>
      </xsl:if>
    </li>
  </xsl:template>
  
  <xsl:template match="ncx:text">
    <xsl:apply-templates/>
  </xsl:template>
  
</xsl:stylesheet>