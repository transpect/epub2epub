<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:tr="http://transpect.io"
  xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:e2e="http://transpect.io/epub2epub"
  version="1.0" 
  name="e2e-load-rootfile"
  type="e2e:load-rootfile">
  
  <p:input port="source">
    <p:documentation>Expects file listing from tr:unzip</p:documentation>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation>The OPF document</p:documentation>
  </p:output>

  <p:output port="report" primary="false" sequence="true">
    <p:pipe port="report" step="try-load-rootfile"/>
  </p:output>
  
  <p:option name="remove-cover" select="'no'"/>
  <p:option name="ignore-files" select="''"/>
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="terminate-on-error" select="'no'"/>

  <p:import href="error-handler.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:try name="try-load-rootfile">
    <p:group>
      <p:output port="result" primary="true"/>
      <p:output port="report" primary="false" sequence="true">
        <p:empty/>
      </p:output>
      <p:variable name="epubdir" select="/c:files/@xml:base"/>
      <p:variable name="href" 
                  select="concat($epubdir, 
                                 /c:files//c:file[@name eq 'META-INF/container.xml']/@name)"/>

      <p:load name="load-container">
        <p:with-option name="href" select="$href"/>
      </p:load>
      
      <p:load name="load-opf">
        <p:with-option name="href" 
                       select="concat($epubdir, 
                                      /ocf:container/ocf:rootfiles/ocf:rootfile/@full-path)"/>
      </p:load>
      
      <p:add-xml-base name="add-xml-base"/>
      
      <p:xslt name="remove-ignored-files" cx:depends-on="load-opf">
        <p:input port="stylesheet">
          <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                            xmlns:xs="http://www.w3.org/2001/XMLSchema"
                            version="3.0">
              
              <xsl:param name="remove-cover" as="xs:string"/>
              <xsl:param name="ignore-files" as="xs:string?"/>
              <xsl:variable name="ignore-files-list" as="xs:string*" 
                            select="for $file in tokenize($ignore-files, '\s') 
                                    return replace($file, '^OEBPS/', '')"/>
              <xsl:variable name="cover-id" as="attribute(id)?" 
                            select="/opf:package/opf:manifest/opf:item[   @properties eq 'cover-image' 
                                                                       or @id = /opf:package/opf:metadata/opf:meta[@name eq 'cover']/@content]/@id"/>
              <xsl:variable name="cover-html-id" as="attribute(id)?" 
                            select="/opf:package/opf:manifest/opf:item[/opf:package/opf:guide/opf:reference[@type eq 'cover']/@href eq @href]/@id"/>
              
              <xsl:mode on-no-match="shallow-copy"/>
              
              <xsl:template match="opf:metadata/dc:*[not(normalize-space())]
                                  |opf:metadata/opf:meta[not(@name = 'cover') or (@name = 'cover' and $remove-cover = 'yes')]
                                  |opf:guide
                                  |opf:manifest/opf:item[@href  = $ignore-files-list]
                                  |opf:manifest/opf:item[@id    = $ignore-files-list]
                                  |opf:spine/opf:itemref[@idref = /opf:package/opf:manifest/opf:item[@href = $ignore-files-list]/@id]
                                  |opf:manifest/opf:item[@id    = ($cover-id, $cover-html-id)][$remove-cover = 'yes']
                                  |opf:spine/opf:itemref[@idref = ($cover-id, $cover-html-id)][$remove-cover = 'yes']">
              </xsl:template>
              
            </xsl:stylesheet>
          </p:inline>
        </p:input>
        <p:with-param name="remove-cover" select="$remove-cover"/>
        <p:with-param name="ignore-files" select="$ignore-files"/>
      </p:xslt>

      <tr:store-debug pipeline-step="epub2epub/02-opf">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>

    </p:group>
    <p:catch name="catch">
      <p:output port="result" primary="true"/>
      <p:output port="report" primary="false">
        <p:pipe port="result" step="terminate-or-continue-on-error"/>
      </p:output>
      
      <e2e:error-handler name="terminate-or-continue-on-error">
        <p:input port="source">
          <p:pipe port="error" step="catch"/>
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="terminate-on-error" select="$terminate-on-error"/>
        <p:with-option name="pipeline-step" select="'epub-migrate/02-opf'"/>
      </e2e:error-handler>

    </p:catch>
  </p:try>

</p:declare-step>
