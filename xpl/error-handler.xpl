<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:tr="http://transpect.io"
  xmlns:e2e="http://transpect.io/epub2epub"
  version="1.0" 
  name="e2e-error-handler"
  type="e2e:error-handler">

  <p:input port="source">
    <p:documentation>
      &lt;c:errors&gt; document
    </p:documentation>
  </p:input>

  <p:output port="result">
    <p:documentation>
      replication of the &lt;c:errors&gt; document
    </p:documentation>
  </p:output>
  
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="pipeline-step"/>
  <p:option name="terminate-on-error" select="'no'"/>
  
  <p:choose name="terminate-or-continue-on-error">
    <p:when test="$terminate-on-error eq 'yes'">
      <p:output port="result"/>
      <p:error code="epub-migrate_load-html">
        <p:input port="source">
          <p:pipe port="source" step="e2e-error-handler"/>
        </p:input>
      </p:error>
    </p:when>
    <p:otherwise>
      <p:output port="result"/>
      <p:identity>
        <p:input port="source">
          <p:pipe port="source" step="e2e-error-handler"/>
        </p:input>
      </p:identity>
    </p:otherwise>
  </p:choose>
  
  <tr:store-debug name="debug-error">
    <p:with-option name="pipeline-step" select="$pipeline-step"/>
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

</p:declare-step>
