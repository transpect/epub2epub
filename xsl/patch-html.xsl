<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns="http://www.w3.org/1999/xhtml" 
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="dc opf xs"
  version="3.0">
  
  <xsl:param name="remove-chars-regex" select="'\s'" as="xs:string"/>
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="html[not(@lang)]">
    <xsl:copy>
      <xsl:attribute name="lang" select="(@lang, @xml:lang, lower-case(/opf:epub/opf:package/opf:metadata/dc:language))[1]"/>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="a/@href[contains(., '#')]">
    <xsl:attribute name="href" select="concat('#', substring-after(., '#'))"/>
  </xsl:template>
  
  <xsl:template match="img/@src">
    <xsl:attribute name="{name()}" select="replace(., $remove-chars-regex, '')"/>
  </xsl:template>
  
  <xsl:template match="head/@*
                      |meta[@http-equiv]"/>
  
  <xsl:template match="s
                      |strike">
    <span class="html-deprecated-s-tag" style="text-decoration: line-through;">
      <xsl:apply-templates select="@*, node()"/>
    </span>
  </xsl:template>
  
  <xsl:template match="acronym">
    <abbr class="html-deprecated-acronym-tag">
      <xsl:apply-templates select="@*, node()"/>
    </abbr>
  </xsl:template>
  
  <xsl:template match="big">
    <span class="html-deprecated-bigger-tag" style="font-size: larger;">
      <xsl:apply-templates select="@*, node()"/>
    </span>
  </xsl:template>
  
  <xsl:template match="center">
    <span class="html-deprecated-center-tag" style="text-align: center;">
      <xsl:apply-templates select="@*, node()"/>
    </span>
  </xsl:template>
  
  <xsl:template match="u">
    <span class="html-deprecated-u-tag" style="text-decoration: underline;">
      <xsl:apply-templates select="@*, node()"/>
    </span>
  </xsl:template>
  
  <xsl:template match="tt">
    <span class="html-deprecated-tt-tag" style="font-family: monospace;">
      <xsl:apply-templates select="@*, node()"/>
    </span>
  </xsl:template>
  
  <xsl:template match="table[@border and not(@border = ('', '0'))]">
    <div class="html-deprecated-border-att" style="{concat('border: ', @border, 'px solid #000;')}">
      <xsl:copy>
        <xsl:apply-templates select="@* except @border, node()"/>
      </xsl:copy>
    </div>
  </xsl:template>
  
  <xsl:template match="img[@border and not(@border = ('', '0'))]">
    <span class="html-deprecated-border-att" style="{concat('border: ', @border, 'px solid #000;')}">
      <xsl:copy>
        <xsl:apply-templates select="@* except @border, node()"/>
      </xsl:copy>
    </span>
  </xsl:template>
  
  <xsl:template match="font">
    <span class="html-deprecated-font-tag">
      <xsl:attribute name="style">
        <xsl:apply-templates select="@face, @color, @size, @style"/>
      </xsl:attribute>
      <xsl:apply-templates select="@* except @style, node()"/>
    </span>
  </xsl:template>
  
  <xsl:template match="font/@face">
    <xsl:value-of select="concat('font-family: ', ., '; ')"/>
  </xsl:template>
  
  <xsl:template match="font/@size">
    <xsl:value-of select="concat('font-size: ', ., '; ')"/>
  </xsl:template>
  
  <xsl:template match="font/@color">
    <xsl:value-of select="concat('color: ', ., '; ')"/>
  </xsl:template>
  
  <xsl:template match="font/@style">
    <xsl:value-of select="."/>
  </xsl:template>
  
  <xsl:template match="dir
                      |frame
                      |frameset
                      |noframes">
    <div  class="html-deprecated-{local-name()}-tag">
      <xsl:apply-templates select="@*, node()"/>
    </div>
  </xsl:template>
  
  <xsl:template match="img/@longdesc">
    <img>
      <xsl:apply-templates select="@*"/>
    </img>
  </xsl:template>
  
  <xsl:template match="a/@charset
                      |a/@coords
                      |a/@rev
                      |body/@alink
                      |body/@background
                      |body/@link
                      |body/@text
                      |body/@vlink
                      |br/@clear
                      |hr/@noshade
                      |hr/@size
                      |html/@version
                      |iframe/@marginheight
                      |iframe/@marginwidth    
                      |iframe/@scrolling
                      |iframe/@frameborder
                      |link/@charset
                      |link/@rev
                      |@align
                      |@border[. = ('', '0')]
                      |@char
                      |@charoff
                      |@clear
                      |@frame
                      |@hspace
                      |@vspace
                      |@shape
                      |@size
                      |@type
                      |@valign
                      |@width"/>
  
  <xsl:variable name="ids" select="//@id" as="attribute(id)*"/>
  
  <xsl:template match="@id[count(index-of($ids, .)) gt 1]">
    <xsl:variable name="id" select="."/>
    <xsl:if test="not(preceding::*[@id eq $id])">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>