<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.daisy.org/z3986/2005/ncx/"
  exclude-result-prefixes="xs"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="/ncx">
    <nav role="doc-toc" epub:type="toc" id="toc">
      <xsl:apply-templates select="navMap"/>
    </nav>
  </xsl:template>
  
  <xsl:template match="navMap">
    <ol>
      <xsl:apply-templates select="navPoint"/>
    </ol>
  </xsl:template>
  
  <xsl:template match="navPoint">
    <li class="{@class}">
      <a href="{if(contains(content/@src, '#'))
                then concat('#', substring-after(content/@src, '#'))
                else content/@src}">
        <xsl:apply-templates select="navLabel/text"/>
      </a>
      <xsl:if test="navPoint">
        <ol>
          <xsl:apply-templates select="navPoint"/>
        </ol>
      </xsl:if>
    </li>
  </xsl:template>
  
  <xsl:template match="text">
    <xsl:apply-templates/>
  </xsl:template>
  
</xsl:stylesheet>