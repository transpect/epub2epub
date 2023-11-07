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
  name="e2e-create-config"
  type="e2e:create-config">
  
  <p:input port="source">
    <p:documentation>
      Expects the &lt;opf:epub&gt; containing HTML, OPF and &lt;c:files&gt;
    </p:documentation>
  </p:input>

  <p:output port="result">
    <p:documentation>epub-config for transpect epubtools module</p:documentation>
  </p:output>
  
  <p:option name="outdir"/>
  <p:option name="epub-version" select="'3.0'"/>
  <p:option name="html-filename" select="'content.html'"/>
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>

  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:xslt name="extract-config-from-epub">
    <p:input port="stylesheet">
      <p:document href="../xsl/create-config.xsl"/>
    </p:input>
    <p:with-param name="outdir" select="$outdir"/>
    <p:with-param name="html-filename" select="$html-filename"/>
    <p:with-param name="epub-version" select="$epub-version"/>
  </p:xslt>
  
  <p:store indent="true" include-content-type="true">
    <p:with-option name="href" select="concat($outdir, '/', 'epub-config.xml')"/>
  </p:store>
  
  <p:insert name="insert-config" match="/opf:epub" position="last-child">
    <p:input port="source">
      <p:pipe port="source" step="e2e-create-config"/>
    </p:input>
    <p:input port="insertion">
      <p:pipe port="result" step="extract-config-from-epub"/>
    </p:input>
  </p:insert>
  
  <tr:store-debug pipeline-step="epub-migrate/10-epub-config">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

</p:declare-step>
