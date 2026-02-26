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
  
  <xsl:param name="hide-toc" as="xs:string"/>
  <xsl:param name="toc-page" as="xs:integer"/>
  
  <xsl:variable name="epub" select="/opf:epub"         as="element(opf:epub)"/>
  <xsl:variable name="ncx"  select="/opf:epub/ncx:ncx" as="element(ncx:ncx)"/>
  
  <xsl:template match="/opf:epub/html:html/html:body/html:div[@class eq 'epub-html-split'][position() = $toc-page]" priority="10">
    <div class="epub-html-split"/>
    <xsl:apply-templates select="/opf:epub/ncx:ncx" mode="toc"/>
    <xsl:copy>
      <xsl:if test="not(//@epub:type[. = 'bodymatter'])">
        <xsl:attribute name="epub:type" select="'bodymatter'"/>  
      </xsl:if>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/opf:epub/html:html/html:body/html:div[@class eq 'epub-html-split'][following-sibling::*[1][self::html:div[@class eq 'cover-img']]]
                      |/opf:epub/html:html/html:body/html:div[@class eq 'cover-img']"/>
  
  <xsl:template match="ncx:ncx" mode="toc">
    <nav role="doc-toc" epub:type="toc" id="toc">
      <xsl:if test="$hide-toc eq 'yes'">
        <xsl:attribute name="hidden" select="'hidden'"/>
      </xsl:if>
      <xsl:apply-templates select="ncx:navMap" mode="#current"/>
    </nav>
  </xsl:template>
  
  <xsl:template match="ncx:navMap" mode="toc">
    <ol class="toc-level-1">
      <xsl:apply-templates select="ncx:navPoint" mode="#current"/>
    </ol>
  </xsl:template>
  
  <xsl:variable name="ncx-fragment-identifiers" as="element(ncx:navPoint)*"
                select="//ncx:navPoint[contains(ncx:content/@src, '#')]"/>
  
  <xsl:template match="ncx:navPoint" mode="toc">
    <xsl:if test="normalize-space(.)">
      <xsl:variable name="ncx-source" as="attribute(src)" select="ncx:content/@src"/>
      <xsl:variable name="manifest-item" as="element(opf:item)"
                    select="$epub/opf:package/opf:manifest/opf:item[@href = replace($ncx-source, '^(.+)#.+$', '$1')]"/>
      <li>
        <a href="{if(contains(ncx:content/@src, 'cover')) 
                    then '#epub-cover-image-container'
                  else if(not(contains($ncx-source, '#')) and matches($ncx-source, '\.x?html$'))
                    then concat(
                           '#',
                           $manifest-item/@id
                         )
                    else concat(
                           '#', 
                           $manifest-item/@id, 
                           '_', 
                           substring-after($ncx-source, '#')
                         )}">
          <xsl:apply-templates select="ncx:navLabel/ncx:text" mode="#current"/>
        </a>
        <xsl:if test="ncx:navPoint">
          <ol class="toc-level-{count(ancestor::ncx:navPoint) + 2}">
            <xsl:apply-templates select="ncx:navPoint" mode="#current"/>
          </ol>
        </xsl:if>
      </li>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="ncx:text" mode="toc">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="ncx:pageList" mode="toc"/>
  
  <xsl:template match="html:*[@id][not(@class eq 'epub-html-split')][starts-with(@id, '#')]">  
    <xsl:variable name="id" select="@id" as="attribute(id)"/>
    <xsl:variable name="matching-ncx-fragment-entries" as="element(ncx:navPoint)" 
                  select="$ncx-fragment-identifiers[replace(ncx:content/@src, '^.*?#', '') = $id]"/>
    <xsl:copy>
      <xsl:attribute name="id" select="if($matching-ncx-fragment-entries) 
                                       then concat(preceding::html:div[@class eq 'epub-html-split'][1]/@id, @id)
                                       else @id"/>
      <xsl:apply-templates select="@* except @id, node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>