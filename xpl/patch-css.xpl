<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io"
  xmlns:opf="http://www.idpf.org/2007/opf" 
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:e2e="http://transpect.io/epub2epub"
  version="1.0" 
  name="e2e-patch-css"
  type="e2e:patch-css">
  
  <p:input port="source">
    <p:documentation>Expects the OPF document</p:documentation>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation>
      opf:epub XML document containing 
      all HTML documents as children
    </p:documentation>
  </p:output>
  
  <p:option name="href"/>
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="terminate-on-error" select="'no'"/>
  
  <p:import href="error-handler.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:try name="try-load-css">
    <p:group>
      <p:variable name="opf-uri" select="/opf:epub/opf:package/@xml:base"/>
      
      <p:for-each name="spine-iteration">
        <p:iteration-source select="/opf:epub/opf:package/opf:manifest/opf:item[@media-type eq 'text/css'][ends-with(@href, '.css')]"/>
        <p:variable name="css-uri" select="resolve-uri(opf:item/@href, $opf-uri)"/>
        
        <cx:message>
          <p:with-option name="message" select="'[info] patch CSS: ', $css-uri"/>
        </cx:message>
        
        <p:xslt template-name="main">
          <p:input port="stylesheet">
            <p:document href="../xsl/patch-css.xsl"/>
          </p:input>
          <p:with-param name="href" select="$css-uri"/>
        </p:xslt>
        
        <tr:store-debug name="debug-css">
          <p:with-option name="pipeline-step" select="concat('epub2epub/patch-css/', replace($css-uri, '^(.+/)(.+?)$', '$2'))"/>
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
        
        <p:store method="text" media-type="text/plain">
          <p:with-option name="href" select="$css-uri"/>
        </p:store>
        
      </p:for-each>
      
      <p:identity>
        <p:input port="source">
          <p:pipe port="source" step="e2e-patch-css"/>
        </p:input>
      </p:identity>

    </p:group>
    <p:catch name="catch">

      <e2e:error-handler name="terminate-or-continue-on-error">
        <p:input port="source">
          <p:pipe port="error" step="catch"/>
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="terminate-on-error" select="$terminate-on-error"/>
        <p:with-option name="pipeline-step" select="'epub-migrate/05-patch-css'"/>
      </e2e:error-handler>

    </p:catch>
  </p:try>

</p:declare-step>