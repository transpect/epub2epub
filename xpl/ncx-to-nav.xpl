<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:tr="http://transpect.io"
  xmlns:e2e="http://transpect.io/epub2epub"
  version="1.0" 
  name="e2e-ncx-to-nav"
  type="e2e:ncx-to-nav">
  
  <p:input port="source">
    <p:documentation>
      Expects the &lt;opf:epub&gt; containing HTML, OPF and &lt;c:files&gt;
    </p:documentation>
  </p:input>

  <p:output port="result">
    <p:documentation>epub-config for transpect epubtools module</p:documentation>
  </p:output>
  
  <p:option name="toc-page" select="4"/>
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>

  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:variable name="toc-id" select="/opf:epub/opf:package/opf:spine/@toc"/>
  <p:variable name="pos" select="$toc-page"/>
  
  <p:load name="load-ncx">
    <p:with-option name="href"
                   select="resolve-uri(/opf:epub/opf:package/opf:manifest/opf:item[@id eq $toc-id]/@href,
                                       /opf:epub/opf:package/@xml:base)"/>
  </p:load>
  
  <p:xslt name="transform-ncx">
    <p:input port="stylesheet">
      <p:document href="../xsl/ncx-to-nav.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  
  <p:sink/>
  
  <p:xslt name="insert-nav">
    <p:input port="source">
      <p:pipe port="source" step="e2e-ncx-to-nav"/>
      <p:pipe port="result" step="transform-ncx"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xsl/insert-nav.xsl"/>
    </p:input>
    <p:with-param name="toc-page" select="$toc-page"/>
  </p:xslt>
  
  <tr:store-debug pipeline-step="epub-migrate/06-ncx-to-nav">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

</p:declare-step>
