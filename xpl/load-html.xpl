<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:tr="http://transpect.io"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:e2e="http://transpect.io/epub2epub"
  version="1.0" 
  name="e2e-load-html"
  type="e2e:load-html">
  
  <p:input port="source" primary="true">
    <p:documentation>Expects the OPF document</p:documentation>
  </p:input>

  <p:input port="stylesheet" primary="false">
    <p:documentation>
      Custom XSLT that is applied on the combined OPF/HTML XML document.
    </p:documentation>
    <p:document href="../xsl/custom-xslt-placeholder.xsl"/>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation>
      opf:epub XML document containing 
      all HTML documents as children
    </p:documentation>
    <p:pipe port="result" step="try-load-html"/>
  </p:output>
  
  <p:output port="html" primary="false">
    <p:documentation>
      The HTML document
    </p:documentation>
    <p:pipe port="html" step="try-load-html"/>
  </p:output>
  
  <p:output port="report" primary="false" sequence="true">
    <p:pipe port="report" step="try-load-html"/>
  </p:output>
  
  <p:option name="href"/>
  <p:option name="remove-cover" select="'no'"/>
  <p:option name="remove-chars-regex" select="'\s'"/>
  <p:option name="html-lang" select="'en'"/>
  <p:option name="debug" select="'no'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="terminate-on-error" select="'no'"/>
  
  <p:import href="error-handler.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:try name="try-load-html">
    <p:group>
      <p:output port="result" primary="true">
        <p:pipe port="result" step="apply-custom-xslt"/>
      </p:output>
      <p:output port="html" primary="false" sequence="true">
        <p:pipe port="result" step="filter-html"/>
      </p:output>
      <p:output port="report" primary="false" sequence="true">
        <p:empty/>
      </p:output>
      <p:variable name="opf-uri" select="/opf:package/@xml:base"/>
      <p:variable name="cover-id" select="/opf:package/opf:metadata/*:meta[@name eq 'cover']/@content"/>
      <p:variable name="cover-name" 
                  select="tokenize(
                            /opf:package/opf:manifest/opf:item[@id eq $cover-id]/@href,
                            '/'
                          )[last()]"/>

      <p:for-each name="spine-iteration">
        <p:iteration-source select="/opf:package/opf:spine/opf:itemref"/>
        <p:variable name="idref" select="opf:itemref/@idref"/>
        <p:variable name="path" select="/opf:package/opf:manifest/opf:item[@id eq $idref]/@href">
          <p:pipe port="source" step="e2e-load-html"/>
        </p:variable>
        
        <cx:message>
          <p:with-option name="message" select="'[info] load HTML document: ', $path"/>
        </cx:message>
        
        <p:load name="load-individual-html-file">
          <p:with-option name="href" select="resolve-uri($path, $opf-uri)"/>
        </p:load>
        
        <p:group>
          <p:variable name="is-cover-html" select="(//*:img/tokenize(@src, '/')[last()],
                                                    //*:image/tokenize(@*:href, '/')[last()]) = $cover-name"/>
          
          <p:choose name="choose-to-wrap-cover">
            <p:when test="$is-cover-html = 'true'">
              
              <p:wrap match="/html:html" wrapper="tr:cover"/>
                          
            </p:when>
            <p:otherwise>
              
              <p:identity/>
              
            </p:otherwise>
          </p:choose>
          
          <p:delete match="/html:html/html:body/html:div[@class eq 'epub-html-split']
                          |/tr:cover/html:html/html:body/html:div[@class eq 'epub-html-split']"/>
          
          <p:choose name="choose-to-insert-split-point">
            <p:when test="p:iteration-position() = 1">
              
              <p:identity name="no-split-point-at-first-page"/>
              
            </p:when>
            <p:otherwise>
              <p:insert match="/html:html/html:body" position="first-child" name="insert-split-point">
                <p:input port="insertion">
                  <p:inline>
                    <div class="epub-html-split" xmlns="http://www.w3.org/1999/xhtml"/>
                  </p:inline>
                </p:input>
              </p:insert>
              
              <p:add-attribute match="/html:html/html:body/html:div[@class eq 'epub-html-split']" attribute-name="id">
                <p:with-option name="attribute-value" select="$idref"/>
              </p:add-attribute>
              
            </p:otherwise>
          </p:choose>
          
          <p:add-attribute match="/html:html/html:body/*" attribute-name="xml:base">
            <p:with-option name="attribute-value" select="base-uri()"/>
          </p:add-attribute>
        
        </p:group>
        
      </p:for-each>
      
      <p:wrap-sequence wrapper="opf:epub" name="wrap-html"/>
      
      <p:insert match="/opf:epub/html:html[1]/html:body" position="last-child" name="insert-other-html-bodies">
        <p:input port="insertion" select="/opf:epub/html:html[position() ne 1]/html:body/*">
          <p:pipe port="result" step="wrap-html"/>
        </p:input>
      </p:insert>
      
      <p:insert match="/opf:epub/html:html[1]/html:head" position="last-child" name="insert-html-css-refs">
        <p:input port="insertion" 
                 select="/opf:epub//html:link[@rel eq 'stylesheet']">
          <p:pipe port="result" step="wrap-html"/>
        </p:input>
      </p:insert>
      
      <p:delete match="/opf:epub/html:html[position() ne 1]
                      |/opf:epub/html:html[1]/html:body/@epub:type
                      |html:link[@href = preceding-sibling::html:link/@href]" name="delete-rest"/>
      
      <p:insert match="/opf:epub" position="first-child" name="insert-opf">
        <p:input port="insertion">
          <p:pipe port="source" step="e2e-load-html"/>
        </p:input>
      </p:insert>
      
      <p:add-attribute match="/opf:epub" attribute-name="xml:base">
        <p:with-option name="attribute-value" select="$href"/>
      </p:add-attribute>
      
      <p:choose name="choose-to-remove-cover">
        <p:when test="$remove-cover eq 'yes'">
          
          <p:delete match="/opf:epub/tr:cover
                          |/opf:epub/opf:package/opf:manifest/opf:item[@id    = /opf:epub/tr:cover/html:html/html:body/html:div/@id]
                          |/opf:epub/opf:package/opf:spine/opf:itemref[@idref = /opf:epub/tr:cover/html:html/html:body/html:div/@id]"/>
          
        </p:when>
        <p:otherwise>
          
          <!-- cover is created subsequently from generated epub-config -->
          
          <p:delete match="/opf:epub/tr:cover"/>
          
        </p:otherwise>
      </p:choose>
      
      <cx:message>
        <p:with-option name="message" select="'[info] patch deprecated html elements and attributes'"/>
      </cx:message>
      
      <tr:store-debug pipeline-step="epub2epub/04-html-plus-opf">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <p:xslt name="patch-html">
        <p:input port="stylesheet">
          <p:document href="../xsl/patch-html.xsl"/>
        </p:input>
        <p:with-param name="remove-chars-regex" select="$remove-chars-regex"/>
        <p:with-param name="html-lang" select="$html-lang"/>
        <p:with-param name="remove-cover" select="$remove-cover"/>
      </p:xslt>
      
      <p:add-attribute name="copy-xml-base" attribute-name="xml:base" match="/opf:epub/html:html">
        <p:with-option name="attribute-value" select="/opf:epub/@xml:base"/>
      </p:add-attribute>
      
      <!-- remove split duplicates -->
      
      <p:delete match="/opf:epub/html:html/html:body/html:div[@class eq 'epub-html-split'][following-sibling::*[1][@class eq 'epub-html-split']]"/>
      
      <tr:store-debug pipeline-step="epub2epub/05-html-plus-opf-patched">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <p:sink/>
      
      <p:xslt name="apply-custom-xslt">
        <p:input port="source">
          <p:pipe port="result" step="copy-xml-base"/>
        </p:input>
        <p:input port="stylesheet">
          <p:pipe port="stylesheet" step="e2e-load-html"/>
        </p:input>
        <p:input port="parameters">
          <p:empty/>
        </p:input>
      </p:xslt>
      
      <tr:store-debug pipeline-step="epub2epub/06-custom-xslt">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <p:filter select="/opf:epub/html:html" name="filter-html"/>
      
      <tr:store-debug pipeline-step="epub2epub/07-html-only">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <p:sink/>      

    </p:group>
    <p:catch name="catch">
      <p:output port="result" primary="true"/>
      <p:output port="html" primary="false" sequence="true">
        <p:inline>
          <html>
            <head>report</head>
            <body><p>Error while loading html</p></body>
          </html>
        </p:inline>
      </p:output>
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
        <p:with-option name="pipeline-step" select="'epub-migrate/04-html'"/>
      </e2e:error-handler>

    </p:catch>
  </p:try>

</p:declare-step>
