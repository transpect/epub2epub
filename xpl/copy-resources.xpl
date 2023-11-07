<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:tr="http://transpect.io"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:e2e="http://transpect.io/epub2epub"
  version="1.0" 
  name="copy-resources"
  type="e2e:copy-resources">
  
  <p:input port="source">
    <p:documentation>
      Expects the &lt;opf:epub&gt; containing HTML and OPF
    </p:documentation>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation>The wrapped HTML document</p:documentation>
  </p:output>
  
  <p:output port="report" primary="false" sequence="true">
    <p:pipe port="report" step="try-copy-resources"/>
  </p:output>
  
  <p:option name="outdir"/>
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="terminate-on-error" select="'no'"/>

  <p:import href="error-handler.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:try name="try-copy-resources">
    <p:group>
      <p:output port="result" primary="true"/>
      <p:output port="report" primary="false" sequence="true">
        <p:empty/>
      </p:output>
      <p:variable name="opf-uri" select="/opf:epub/opf:package/@xml:base"/>
      <p:variable name="html-filename" 
                  select="replace(/opf:epub/@xml:base, '^.+/(.+?)\.epub$', '$1.html', 'i')"/>
      
      <p:for-each name="file-iteration">
        <p:iteration-source select="/opf:epub/opf:package/opf:manifest/opf:item[not(@media-type = ('application/xhtml+xml', 
                                                                                                   'application/x-dtbncx+xml'))]"/>
        <p:variable name="path" select="resolve-uri(opf:item/@href, $opf-uri)"/>
        <p:variable name="target" select="concat($outdir, '/', opf:item/@href)"/>
        
        <cx:message>
          <p:with-option name="message" select="'[info] copy resource: ', opf:item/@href"/>
        </cx:message>
        
        <pxf:copy name="copy-individual-resource">
          <p:with-option name="href" select="$path"/>
          <p:with-option name="target" select="$target"/>
        </pxf:copy>
        
        <p:add-attribute match="/c:file" attribute-name="name" name="create-file-reference">
          <p:input port="source">
            <p:inline>
              <c:file/>
            </p:inline>
          </p:input>
          <p:with-option name="attribute-value" select="$target"/>
        </p:add-attribute>
        
      </p:for-each>
      
      <p:wrap-sequence wrapper="c:files" name="wrap-file-references"/>
      
      <p:store name="store-html">
        <p:input port="source" select="/opf:epub/html:html">
          <p:pipe port="source" step="copy-resources"/>
        </p:input>
        <p:with-option name="href" select="concat($outdir, '/', $html-filename)"/>
      </p:store>
      
      <p:insert position="first-child">
        <p:input port="source">
          <p:pipe port="result" step="wrap-file-references"/>
        </p:input>
        <p:input port="insertion">
          <p:inline>
            <c:file/>
          </p:inline>
        </p:input>
      </p:insert>
      
      <p:add-attribute attribute-name="name" match="/c:files/c:file[not(@name)]" name="create-html-file-reference">
        <p:with-option name="attribute-value" select="concat($outdir, '/', $html-filename)"/>
      </p:add-attribute>
      
      <p:insert name="insert-files" match="/opf:epub" position="last-child">
        <p:input port="insertion">
          <p:pipe port="result" step="create-html-file-reference"/>
        </p:input>
        <p:input port="source">
          <p:pipe port="source" step="copy-resources"/>
        </p:input>
      </p:insert>
      
      <p:add-attribute match="/opf:epub/html:html" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="concat($outdir, '/', $html-filename)"/>
      </p:add-attribute>
      
      <tr:store-debug pipeline-step="epub-migrate/08-copy-resources">
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
        <p:with-option name="pipeline-step" select="'epub-migrate/08-copy-resources'"/>
      </e2e:error-handler>
      
    </p:catch>
  </p:try>

</p:declare-step>
