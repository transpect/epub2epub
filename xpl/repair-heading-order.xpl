<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" 
  xmlns:e2e="http://transpect.io/epub2epub"
  version="1.0"
  name="repair-heading-order" 
  type="e2e:repair-heading-order">
  
  <p:documentation>This step fixes the heading hierarchy. For example, 
    having an h1 followed directly by an h3 is not ideal for accessibility. 
    This step repairs the hierarchy at once.
  </p:documentation>
  
  <p:input port="source">
    <p:documentation>
      The HTML document.
    </p:documentation>
  </p:input>
  
  <p:output port="result">
    <p:documentation>
      The HTML document with corrected heading order.
    </p:documentation>
  </p:output>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:xslt name="patch-html">
    <p:input port="stylesheet">
      <p:document href="../xsl/repair-heading-order.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt> 
  
</p:declare-step>