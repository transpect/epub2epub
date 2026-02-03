<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:tr="http://transpect.io"
  xmlns:opf="http://www.idpf.org/2007/opf" 
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:e2e="http://transpect.io/epub2epub"
  version="1.0" 
  name="e2e-patch-css"
  type="e2e:patch-css">
  
  <p:input port="source" primary="true">
    <p:documentation>Expects the OPF document</p:documentation>
  </p:input>
  
  <p:input port="css" primary="false" sequence="true">
    <p:documentation>
      Custom CSS to be added to the end of all CSS files. Input is expected to look like this:
      
      &lt;c:body>
      a.link { color:none }
      &lt;/c:body>
    </p:documentation>
    <p:empty/>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation>
      opf:epub XML document containing 
      all HTML documents as children
    </p:documentation>
  </p:output>
  
  <p:option name="href"/>
  <p:option name="hide-toc" select="'no'"/>
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="terminate-on-error" select="'no'"/>
  
  <p:import href="error-handler.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:try name="try-load-css">
    <p:group>
      <p:variable name="opf-uri" select="/opf:epub/opf:package/@xml:base"/>
      <p:variable name="nav-exists" select="/opf:epub/html:html//html:nav[@epub:type = 'toc']"/>
      
      <p:for-each name="spine-iteration">
        <p:iteration-source select="/opf:epub/opf:package/opf:manifest/opf:item[@media-type eq 'text/css'][ends-with(@href, '.css')]"/>
        <p:variable name="css-uri" select="resolve-uri(opf:item/@href, $opf-uri)"/>
        
        <cx:message>
          <p:with-option name="message" select="'[info] patch CSS: ', $css-uri"/>
        </cx:message>
        
        <p:sink/>
        
        <tr:store-debug pipeline-step="css/css">
          <p:input port="source">
            <p:pipe port="css" step="e2e-patch-css"/>
          </p:input>
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
        
        <p:sink/>
        
        <p:xslt template-name="main" name="patch-css">
          <p:input port="source">
            <p:pipe port="current" step="spine-iteration"/>
            <p:pipe port="css" step="e2e-patch-css"/>
          </p:input>
          <p:input port="stylesheet">
            <p:document href="../xsl/patch-css.xsl"/>
          </p:input>
          <p:with-param name="href" select="$css-uri"/>
          <p:with-param name="hide-toc" select="$hide-toc"/>
        </p:xslt>
        
        <tr:store-debug name="debug-css">
          <p:with-option name="pipeline-step" select="concat('epub2epub/patch-css/', replace($css-uri, '^(.+/)(.+?)$', '$2'))"/>
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
        
        <cx:message>
          <p:with-option name="message" select="'[info] store CSS: ', $css-uri"/>
        </cx:message>
        
        <p:store method="text" media-type="text/plain" encoding="utf8" cx:depends-on="patch-css">
          <p:with-option name="href" select="$css-uri"/>
        </p:store>
        
      </p:for-each>
      
      <p:identity>
        <p:input port="source">
          <p:pipe port="source" step="e2e-patch-css"/>
        </p:input>
      </p:identity>
      
      <p:viewport match="/opf:epub/opf:package/opf:manifest/opf:item[@media-type eq 'text/css'][ends-with(@href, '.css')]">
        <p:variable name="css-href" select="opf:item/@href"/>
        
        <p:add-attribute match="opf:item" attribute-name="href">
          <p:with-option name="attribute-value" select="$css-href"/>
        </p:add-attribute>
        
      </p:viewport>
      
      <p:viewport match="/opf:epub/html:html/html:head/html:link[@rel eq 'stylesheet']">
        <p:variable name="css-href" select="html:link/@href"/>
        
        <cx:message>
          <p:with-option name="message" select="'[info] rename CSS: references ', $css-href"/>
        </cx:message>
        
        <p:add-attribute match="html:link" attribute-name="href">
          <p:with-option name="attribute-value" select="$css-href"/>
        </p:add-attribute>
        
      </p:viewport>

      <tr:store-debug name="debug-xy">
        <p:with-option name="pipeline-step" select="'epub2epub/___after-css'"/>
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>

      <p:identity/>

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