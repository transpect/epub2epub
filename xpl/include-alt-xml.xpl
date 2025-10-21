<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  xmlns:e2e="http://transpect.io/epub2epub"
  xmlns:html="http://www.w3.org/1999/xhtml"
  version="1.0"
  name="e2e-include-alt-xml"
  type="e2e:include-alt-xml">
  
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <p>This pipeline patches alt texts into a HTML document.</p>
  </p:documentation>
  
  <p:input port="source" primary="true">
    <p:documentation>
      Expects a HTML document
    </p:documentation>
  </p:input>
  
  <p:input port="alt-xml" primary="false" sequence="true">
    <p:documentation>
      Expects a links xml document.
    </p:documentation>
    <p:inline>
      <links/>
    </p:inline>
  </p:input>
  
  <p:output port="result" primary="true">
    <p:documentation>
      The either patched or untouched HTML document
    </p:documentation>
  </p:output>
  
  <p:output port="report" primary="false" sequence="true">
    <p:documentation>
      reports conversion errors
    </p:documentation>
    <p:pipe port="report" step="try-include-alt-xml"/>
  </p:output>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  <p:option name="terminate-on-error" select="'no'"/>
  
  <p:import href="error-handler.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:try name="try-include-alt-xml">
    <p:group>
      <p:output port="result" primary="true">
        <p:pipe port="result" step="include-alt-or-skip"/>
      </p:output>
      <p:output port="report" primary="false" sequence="true">
        <p:empty/>
      </p:output>

      <p:choose name="include-alt-or-skip">
        <p:when test="count(/links/link) gt 0">
          <p:xpath-context>
            <p:pipe port="alt-xml" step="e2e-include-alt-xml"/>
          </p:xpath-context>
          <p:output port="result"/>
          
          <p:sink name="drop-1"/>
          
          <p:validate-with-relax-ng assert-valid="true">
            <p:input port="source">
              <p:pipe port="alt-xml" step="e2e-include-alt-xml"/>
            </p:input>
            <p:input port="schema">
              <p:document href="../schema/links.rng"/>
            </p:input>
          </p:validate-with-relax-ng>
          
          <p:sink name="drop-2"/>
          
          <p:identity name="identity-1">
            <p:input port="source">
              <p:pipe port="source" step="e2e-include-alt-xml"/>
            </p:input>
          </p:identity>
          
          <p:viewport match="/html:html/html:body//html:img">
            <p:variable name="filename" select="replace(html:img/@src, '^(.+/)?(.+)', '$2')"/>
            <p:variable name="alt-text" select="/links/link[matches(@name, $filename)]/@alt">
              <p:pipe port="alt-xml" step="e2e-include-alt-xml"/>
            </p:variable>
            
            <p:add-attribute attribute-name="alt" match="*">
              <p:with-option name="attribute-value" select="$alt-text"/>
            </p:add-attribute>
            
          </p:viewport>
          
          <tr:store-debug pipeline-step="epub2epub/05-alt-text">
            <p:with-option name="active" select="$debug"/>
            <p:with-option name="base-uri" select="$debug-dir-uri"/>
          </tr:store-debug>
          
        </p:when>
        <p:otherwise>
          <p:output port="result"/>
          
          <p:identity name="identity-2">
            <p:input port="source">
              <p:pipe port="source" step="e2e-include-alt-xml"/>
            </p:input>
          </p:identity>
          
        </p:otherwise>
      </p:choose>
    </p:group>
    <p:catch name="catch">
      <p:output port="result" primary="true"/>
      <p:output port="report" primary="false" sequence="true">
        <p:pipe port="result" step="terminate-or-continue-on-error"/>
      </p:output>
      
      <e2e:error-handler name="terminate-or-continue-on-error">
        <p:input port="source">
          <p:pipe port="error" step="catch"/>
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="terminate-on-error" select="$terminate-on-error"/>
        <p:with-option name="pipeline-step" select="'epub-migrate/05-alt-text'"/>
      </e2e:error-handler>
      
    </p:catch>
  </p:try>
  
</p:declare-step>