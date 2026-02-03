<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:tr="http://transpect.io"
  xmlns:epub="http://transpect.io/epubtools"
  xmlns:e2e="http://transpect.io/epub2epub"
  version="1.0"
  name="epub2epub" 
  type="e2e:epub2epub">
  
  <p:documentation>
    Pipeline to migrate an EPUB2. Consumes an EPUB file and 
    converts output suitable for processing with the epubtools 
    module to generate a new EPUB.
  </p:documentation>
  
  <p:input port="stylesheet" primary="false">
    <p:documentation>
      Custom XSLT that is applied on the combined OPF/HTML XML document.
    </p:documentation>
    <p:document href="../xsl/custom-xslt-placeholder.xsl"/>
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
  
  <p:input port="alt-xml" primary="false" sequence="true">
    <p:documentation>
      Optional input if alternative texts should be 
      applied to HTML img elements. The schema for 
      this input is stored in ../schema/links.rng.
    </p:documentation>
    <p:inline>
      <links/>
    </p:inline>
  </p:input>
  
  <p:output port="result" primary="true">
    <p:documentation>The EPUB paths document</p:documentation>
    <p:pipe port="result" step="main"/>
  </p:output>
  
  <p:output port="html" primary="false">
    <p:documentation>The HTML document</p:documentation>
    <p:pipe port="html" step="main"/>
  </p:output>
  
  <p:output port="opf" primary="false">
    <p:documentation>The OPF document</p:documentation>
    <p:pipe port="opf" step="main"/>
  </p:output>
  
  <p:output port="report" primary="false" sequence="true">
    <p:pipe port="report" step="main"/>
  </p:output>
  
  <p:output port="input-for-schematron" primary="false" sequence="true">
    <p:pipe port="input-for-schematron" step="main"/>
  </p:output>
  
  <p:option name="href">
    <p:documentation>
      Path to the EPUB file.
    </p:documentation>
  </p:option>
  <p:option name="outdir" select="'out'">
    <p:documentation>
      Where the output will be stored
    </p:documentation>
  </p:option>
  <p:option name="create-epub" select="'yes'">
    <p:documentation>
      Whether to create an EPUB with transpect epubtools module. When set to 'no', 
      the contents and epub-config extracted from the input EPUB are stored to outdir.
    </p:documentation>
  </p:option>
  <p:option name="epub-version" select="'EPUB3'">
    <p:documentation>
      EPUB version for conversion, e.g. 'EPUB2', 'EPUB3'. For example, if the EPUB is 
      simply invalid, you can simply keep the version and repair it.
    </p:documentation>
  </p:option>
  <p:option name="html-subdir-name" select="'content'">
    <p:documentation>
      New filename of the HTML file in the EPUB package.
    </p:documentation>
  </p:option>
  <p:option name="toc-page" select="4">
    <p:documentation>
      Page index after there the toc is inserted
    </p:documentation>
  </p:option>
  <p:option name="hide-toc" select="'yes'">
    <p:documentation>
      Whether the generated HTML toc should be hidden. Default is "yes" to prevent duplicate HTML ToCs.
    </p:documentation>
  </p:option>
  <p:option name="remove-cover" select="'no'">
    <p:documentation>
      Whether the cover should be removed or not.
    </p:documentation>
  </p:option>
  <p:option name="remove-files-list" select="''">
    <p:documentation>
      Whitespace-separated list of OPF manifest items that are not considered for the conversion.
    </p:documentation>
  </p:option>
  <p:option name="remove-chars-regex" select="'([\p{Zs}]|%20)'">
    <p:documentation>
      Regular expression which matches characters to be deleted in filenames
    </p:documentation>
  </p:option>
  <p:option name="html-lang" select="'en'">
    <p:documentation>
      If the HTML document language is not set, this value will be inserted.
    </p:documentation>
  </p:option>
  <p:option name="debug" select="'no'">
    <p:documentation>
      Pass "yes" to switch on storing debugging output
    </p:documentation>
  </p:option>
  <p:option name="debug-dir-uri" select="'debug'">
    <p:documentation>
      The URI where the debug files are stored.
    </p:documentation>
  </p:option>
  <p:option name="status-dir-uri" select="'status'">
    <p:documentation>
      The URI where messages are stored. 
    </p:documentation>
  </p:option>
  <p:option name="terminate-on-error" select="'no'">
    <p:documentation>Abort on error or attempt to catch it</p:documentation>
  </p:option>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/epubtools/xpl/epub-convert.xpl"/>
  
  <p:import href="unzip.xpl"/>
  <p:import href="load-rootfile.xpl"/>
  <p:import href="load-html.xpl"/>
  <p:import href="include-alt-xml.xpl"/>
  <p:import href="patch-css.xpl"/>
  <p:import href="copy-resources.xpl"/>
  <p:import href="create-config.xpl"/>
  <p:import href="ncx-to-nav.xpl"/>
  
  <tr:file-uri name="normalize-epub-path">
    <p:with-option name="filename" select="$href"/>
  </tr:file-uri>
  
  <tr:file-uri name="normalize-outdir-path">
    <p:with-option name="filename" select="$outdir"/>
  </tr:file-uri>
  
  <p:group name="main">
    <p:output port="result" primary="true"/>
    <p:output port="report" primary="false" sequence="true">
      <p:pipe port="report" step="unzip"/>
      <p:pipe port="report" step="load-rootfile"/>
      <p:pipe port="report" step="load-html"/>
      <p:pipe port="report" step="include-alt-xml"/>
      <p:pipe port="report" step="copy-resources"/>
      <p:pipe port="report" step="choose-create-epub"/>
    </p:output>
    <p:output port="input-for-schematron" primary="false" sequence="true">
      <p:pipe port="input-for-schematron" step="choose-create-epub"/>
    </p:output>
    <p:output port="html">
      <p:pipe port="html" step="load-html"/>
    </p:output>
    <p:output port="opf">
      <p:pipe port="result" step="load-rootfile"/>
    </p:output>
    <p:variable name="outdir-href" select="/c:result/@local-href"/>
    <p:variable name="epub-href" select="/c:result/@local-href">
      <p:pipe port="result" step="normalize-epub-path"/>
    </p:variable>
    <p:variable name="tmpdir" select="concat($outdir-href, '/tmp')"/>
    
    <e2e:unzip name="unzip">
      <p:with-option name="href" select="$epub-href"/>
      <p:with-option name="outdir" select="$tmpdir"/>
      <p:with-option name="remove-files-list" select="$remove-files-list"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="terminate-on-error" select="$terminate-on-error"/>
    </e2e:unzip>
    
    <e2e:load-rootfile name="load-rootfile">
      <p:with-option name="remove-cover" select="$remove-cover"/>
      <p:with-option name="remove-files-list" select="$remove-files-list"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="terminate-on-error" select="$terminate-on-error"/>
    </e2e:load-rootfile>
    
    <e2e:load-html name="load-html">
      <p:input port="stylesheet">
        <p:pipe port="stylesheet" step="epub2epub"/>
      </p:input>
      <p:with-option name="href" select="$epub-href"/>
      <p:with-option name="remove-cover" select="$remove-cover"/>
      <p:with-option name="remove-chars-regex" select="$remove-chars-regex"/>
      <p:with-option name="html-lang" select="$html-lang"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="terminate-on-error" select="$terminate-on-error"/>
    </e2e:load-html>
    
    <e2e:include-alt-xml name="include-alt-xml">
      <p:input port="alt-xml">
        <p:pipe port="alt-xml" step="epub2epub"/>
      </p:input>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="terminate-on-error" select="$terminate-on-error"/>
    </e2e:include-alt-xml>
    
    <e2e:patch-css name="patch-css" cx:depends-on="load-html">
      <p:input port="css">
        <p:pipe port="css" step="epub2epub"/>
      </p:input>
      <p:with-option name="href" select="$epub-href"/>
      <p:with-option name="hide-toc" select="$hide-toc"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="terminate-on-error" select="$terminate-on-error"/>
    </e2e:patch-css>
    
    <e2e:ncx-to-nav name="ncx-to-nav" cx:depends-on="patch-css">
      <p:with-option name="toc-page" select="$toc-page"/>
      <p:with-option name="hide-toc" select="$hide-toc"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    </e2e:ncx-to-nav>
    
    <e2e:copy-resources name="copy-resources" cx:depends-on="ncx-to-nav">
      <p:with-option name="outdir" select="$outdir-href"/>
      <p:with-option name="remove-chars-regex" select="$remove-chars-regex"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      <p:with-option name="terminate-on-error" select="$terminate-on-error"/>
    </e2e:copy-resources>
    
    <e2e:create-config name="create-config" cx:depends-on="copy-resources">
      <p:with-option name="epub-version" select="$epub-version"/>
      <p:with-option name="html-subdir-name" select="$html-subdir-name"/>
      <p:with-option name="remove-chars-regex" select="$remove-chars-regex"/>
      <p:with-option name="outdir" select="$outdir-href"/>
      <p:with-option name="debug" select="$debug"/>
      <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    </e2e:create-config>
    
    <p:choose name="choose-create-epub" cx:depends-on="create-config">
      <p:when test="$create-epub eq 'yes'">
        <p:output port="result" primary="true"/>
        <p:output port="input-for-schematron" primary="false" sequence="true">
          <p:pipe port="input-for-schematron" step="epub-convert"/>
        </p:output>
        <p:output port="report" sequence="true">
          <p:pipe port="report" step="epub-convert"/>
        </p:output>
        <epub:convert name="epub-convert">
          <p:input port="source" select="/opf:epub/html:html">
            <p:pipe port="result" step="create-config"/>
          </p:input>
          <p:input port="meta" select="/opf:epub/epub-config">
            <p:pipe port="result" step="create-config"/>
          </p:input>
          <p:input port="conf">
            <p:empty/>
          </p:input>
          <p:with-option name="debug" select="$debug"/>
          <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
          <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
          <p:with-option name="create-a11y-meta" select="'true'"/>
          <p:with-option name="drop-epub-types-without-matching-aria-role" select="'true'"/>
          <p:with-option name="terminate-on-error" select="$terminate-on-error"/>
        </epub:convert>
      </p:when>
      <p:otherwise>
        <p:output port="result" primary="true" sequence="true"/>
        <p:output port="input-for-schematron" primary="false" sequence="true">
          <p:empty/>
        </p:output>
        <p:output port="report">
          <p:empty/>
        </p:output>
        <p:identity/>
      </p:otherwise>
    </p:choose>
    
  </p:group>
  
</p:declare-step>