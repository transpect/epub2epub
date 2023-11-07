<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="xs" 
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:param name="outdir" as="xs:string"/>
  
  <xsl:template match="/opf:epub">
    <xsl:variable name="cover-id" as="attribute(content)" 
                  select="opf:package/opf:metadata/opf:meta[@name eq 'cover']/@content"/>
    <epub-config format="EPUB3" 
      layout="reflowable" 
      css-handling="regenerated-per-split remove-comments"
      css-parser="REx"
      html-subdir-name="text" 
      indent="selective"
      font-subset="false"
      consider-headings-in-tables="false">
      
      <cover svg="true" svg-scale-hack="true" 
             href="{opf:package/opf:manifest/opf:item[@id eq $cover-id]/@href}"/>
      
      <types>
        <type name="toc" heading="Inhaltsverzeichnis" hidden="true" fallback-id-for-landmark="rendered_toc"/> 
        <type name="landmarks" heading="Übersicht" hidden="true" types="bodymatter toc"/>
        <type name="cover" heading="Cover" file="cover" guide-type="text"/>
      </types>
      
      <metadata>
        <xsl:apply-templates select="opf:package/opf:metadata/*"/>  
      </metadata>
      
      <hierarchy media-type="application/xhtml+xml" max-population="40" max-text-length="200000">
        <heading elt="h1"/>
        <unconditional-split attr="class" attval="epub-html-split"/>
      </hierarchy>
      
      <checks>
        <check param="result-max-mb" value="12" severity="warning"/> 
        <check param="result-max-mb" value="500" severity="error"/>
        <check param="html-max-kb" value="300" severity="warning"/>
        <check param="image-max-mb" value="1.5" severity="warning"/>
        <check param="image-max-mpx" value="3.2" severity="warning"/>
        <check param="image-min-dpi" value="300" severity="warning"/>
        <check param="image-max-dpi" value="300" severity="warning"/>
        <check param="image-max-height" value="750" severity="warning"/>
        <check param="cover-min-width-px" value="800" severity="warning"/>
        <check param="cover-max-width-px" value="1440" severity="warning"/>
        <check param="table-max-str-length" value="20000" severity="warning"/>
        <check param="table-max-cell-count" value="1800"  severity="warning"/>
      </checks>
      
    </epub-config>
  </xsl:template>
  
  <xsl:template match="opf:metadata/dc:date"/>
  
</xsl:stylesheet>