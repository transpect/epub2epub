<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io"
  xmlns:e2e="http://transpect.io/epub2epub"
  version="1.0" 
  name="e2e-apply-custom-xslt"
  type="e2e:apply-custom-xslt">
  
  <p:input port="source" primary="true">
    <p:documentation>Expects the combined opf:epub document</p:documentation>
  </p:input>

  <p:input port="stylesheet" primary="false">
    <p:documentation>XSLT for custom overrides</p:documentation>
    <p:document href="../xsl/custom-xslt-placeholder.xsl"/>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation>Transformed opf:epub document</p:documentation>
    <p:pipe port="result" step="try-apply-custom-xslt"/>
  </p:output>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="terminate-on-error" select="'no'"/>
  
  <p:import href="error-handler.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:try name="try-apply-custom-xslt">
    <p:group>
      <p:output port="result"/>
      
      <p:xslt name="patch-html">
        <p:input port="stylesheet">
          <p:pipe port="stylesheet" step="e2e-apply-custom-xslt"/>
        </p:input>
        <p:input port="parameters">
          <p:empty/>
        </p:input>
      </p:xslt>
      
      <tr:store-debug pipeline-step="epub2epub/16-apply-custom-xslt">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>

    </p:group>
    <p:catch name="catch">
      <p:output port="result"/>

      <e2e:error-handler name="terminate-or-continue-on-error">
        <p:input port="source">
          <p:pipe port="error" step="catch"/>
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="terminate-on-error" select="$terminate-on-error"/>
        <p:with-option name="pipeline-step" select="'epub2epub/16-apply-custom-xslt'"/>
      </e2e:error-handler>

    </p:catch>
  </p:try>

</p:declare-step>
