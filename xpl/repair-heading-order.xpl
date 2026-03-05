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
    This step repairs the hierarchy recursively.
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
  
  <p:option name="heading-level" select="xs:integer(3)">
    <p:documentation>
      The heading level to be corrected in each run. We start with h3 because 
      the difference between h1 and h2 is already the maximum 
      allowed (1), and therefore is considered acceptable
    </p:documentation>
  </p:option>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <p:xslt name="patch-html">
    <p:input port="stylesheet">
      <p:document href="../xsl/repair-heading-order.xsl"/>
    </p:input>
    <p:with-param name="heading-level" select="$heading-level"/>
  </p:xslt>
  
  <p:choose>
    <p:when test="xs:integer($heading-level) lt 7">
      
      <cx:message>
        <p:with-option name="message" select="'[info] repair heading level: ', $heading-level"/>
      </cx:message>
      
      <e2e:repair-heading-order>
        <p:with-option name="heading-level" select="$heading-level + 1"/>
      </e2e:repair-heading-order>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  
</p:declare-step>