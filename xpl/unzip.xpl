<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io"
  xmlns:e2e="http://transpect.io/epub2epub"
  version="1.0" 
  name="e2e-unzip"
  type="e2e:unzip">

  <p:output port="result" primary="true"/>

  <p:output port="report" primary="false" sequence="true">
    <p:pipe port="report" step="try-unzip"/>
  </p:output>

  <p:option name="href" required="true"/>
  <p:option name="outdir" required="true"/>
  <p:option name="ignore-files" select="''"/>
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  <p:option name="terminate-on-error" select="'no'"/>
  
  <p:import href="error-handler.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/calabash-extensions/unzip-extension/unzip-declaration.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>

  <p:try name="try-unzip">
    <p:group>
      <p:output port="result" primary="true"/>
      <p:output port="report" primary="false" sequence="true">
        <p:empty/>
      </p:output>

      <tr:unzip name="unzip-epub">
        <p:with-option name="zip" select="$href"/>
        <p:with-option name="dest-dir" select="$outdir"/>
        <p:with-option name="overwrite" select="'yes'"/>
        <p:with-option name="safe" select="'no'"/>
      </tr:unzip>
      
      <cx:message>
        <p:with-option name="message" select="'[info] exclude files: ', $ignore-files"/>
      </cx:message>
      
      <p:xslt name="ignore-files" cx:depends-on="unzip-epub">
        <p:input port="stylesheet">
          <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                            xmlns:xs="http://www.w3.org/2001/XMLSchema"
                            version="3.0">
              
              <xsl:param name="ignore-files" as="xs:string?"/>
              
              <xsl:mode on-no-match="shallow-copy"/>
              
              <xsl:template match="/c:files/c:file[@name = tokenize($ignore-files, '\s')]"/>
              
            </xsl:stylesheet>
          </p:inline>
        </p:input>
        <p:with-param name="ignore-files" select="$ignore-files"/>
      </p:xslt>
      
      <cx:message>
        <p:with-option name="message" select="'[info] unzip: ', $href, ' => ', $outdir"/>
      </cx:message>

      <tr:store-debug pipeline-step="epub2epub/00-unzip">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>

    </p:group>
    <p:catch name="catch">
      <p:output port="result" primary="true"/>
      <p:output port="report" primary="false">
        <p:inline>
          <c:errors tr:rule-family="epub-migrate">
            <c:error code="unzip-epub-failed" id="unzip-epub-failed"
              severity="fatal-error">
              The EPUB file seems to be corrupted and cannot be unzipped.
              Please check whether the submitted path is correct and if the file is readable.
            </c:error>
          </c:errors>
        </p:inline>
      </p:output>
      
      <e2e:error-handler name="terminate-or-continue-on-error">
        <p:input port="source">
          <p:pipe port="error" step="catch"/>
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="terminate-on-error" select="$terminate-on-error"/>
        <p:with-option name="pipeline-step" select="'epub-migrate/00-unzip'"/>
      </e2e:error-handler>

    </p:catch>
  </p:try>

</p:declare-step>
