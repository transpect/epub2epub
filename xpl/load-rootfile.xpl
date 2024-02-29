<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io"
  xmlns:ocf="urn:oasis:names:tc:opendocument:xmlns:container"
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
