<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:opf="http://www.idpf.org/2007/opf"
  version="3.0">
  
  <xsl:param name="remove-cover" as="xs:string"/>
  <xsl:param name="remove-files-list" as="xs:string?"/>
  
  <xsl:variable name="remove-files-list-list" as="xs:string*" 
                select="for $file in tokenize($remove-files-list, '\s') 
                        return replace($file, '^OEBPS/', '')"/>
  <xsl:variable name="cover-id" as="attribute(id)?" 
                select="/opf:package/opf:manifest/opf:item[   @properties eq 'cover-image' 
                                                           or @id = /opf:package/opf:metadata/opf:meta[@name eq 'cover']/@content]/@id"/>
  <xsl:variable name="cover-html-id" as="attribute(id)?" 
                select="/opf:package/opf:manifest/opf:item[/opf:package/opf:guide/opf:reference[@type eq 'cover']/@href eq @href]/@id"/>
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:template match="opf:metadata/dc:*[not(normalize-space())]
                      |opf:metadata/opf:meta[not(@name = 'cover') or (@name = 'cover' and $remove-cover = 'yes')]
                      |opf:metadata/opf:meta[(@name = 'cover') and (preceding-sibling::opf:meta[@name = 'cover'])]
                      |opf:guide
                      |opf:manifest/opf:item[@href  = $remove-files-list-list]
                      |opf:manifest/opf:item[@id    = $remove-files-list-list]
                      |opf:manifest/opf:item[@media-type = ('application/adobe-page-template+xml', 
                                                            'application/vnd.adobe-page-template+xml')]
                      |opf:spine/opf:itemref[@idref = /opf:package/opf:manifest/opf:item[@href = $remove-files-list-list]/@id]
                      |opf:manifest/opf:item[@id    = ($cover-id, $cover-html-id)][$remove-cover = 'yes']
                      |opf:spine/opf:itemref[@idref = ($cover-id, $cover-html-id)][$remove-cover = 'yes']">
  </xsl:template>
  
</xsl:stylesheet>