<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:opf="http://www.idpf.org/2007/opf"
  xmlns:epub="http://www.idpf.org/2007/ops"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns="http://www.w3.org/1999/xhtml" 
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:variable name="isbn-lookup-table" as="xs:string+" 
                select="tokenize(
                          replace(
                            unparsed-text(
                              '../../../tmp/suhrkamp_3/backlist.csv', 'UTF-8'
                            ), '\r', '', 'mi'
                          ), '\n', 'mi'
                        )"/>
  
  <xsl:template match="/opf:epub/opf:package/opf:metadata">
    <xsl:variable name="e-isbn" select="replace(dc:identifier[matches(., '[-\d]+')][1], '[\p{P}\p{L}]', '')" as="xs:string"/>
    <xsl:copy>
      <xsl:apply-templates select="*"/>
      <xsl:element name="meta" namespace="http://www.idpf.org/2007/opf">
        <xsl:attribute name="property" select="'schema:accessibilitySummary'"/>
        <xsl:text>Dieses eBook genügt den grundsätzlichen Anforderungen an Barrierefreiheit. Es ist textuell und visuell erfassbar sowie hierarchisch aufgebaut. Sollten Sie Probleme mit der Barrierefreiheit dieses eBooks feststellen, dann wenden Sie sich bitte an den Verlag (barrierefreiheit@suhrkamp.de).</xsl:text>
      </xsl:element>
      <meta property="schema:accessibilitySummary">Dieses E-Book wurde gemäß der W3C EPUB Accessibility Guidelines für eine barrierefreie Zugänglichkeit optimiert und geprüft. Sollten Sie Probleme mit der Barrierefreiheit dieses E-Books feststellen, dann wenden Sie sich bitte an den Verlag.</meta>
      <meta property="tdm:reservation">1</meta> 
      <meta property="tdm:policy">https://www.suhrkamp.de/tdm-policy-ebook</meta>
      <xsl:if test="/opf:epub/html/body//a[starts-with(@id, 'page_')]">
        <xsl:message select="'[info] opf id:    ', xs:string(dc:identifier)"/>
        <xsl:message select="'[info] e-isbn:    ', $e-isbn"/>
        <xsl:variable name="print-isbn" as="xs:string?" select="tokenize($isbn-lookup-table[matches(., $e-isbn)][1], ';')[2]"/>
        <xsl:if test="normalize-space($print-isbn)">
          <xsl:message select="'[info] print-isbn:', $print-isbn"/>
          <xsl:element name="meta" namespace="http://www.idpf.org/2007/opf">
            <xsl:attribute name="property" select="'pageBreakSource'"/>
            <xsl:value-of select="concat('urn:isbn:', $print-isbn)"/>
          </xsl:element>
          <dc:source><xsl:text>urn:isbn:</xsl:text><xsl:value-of select="$print-isbn"/></dc:source>
        </xsl:if>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/opf:epub/html/body/div[@class eq 'epub-html-split'][following-sibling::*[1][self::div[matches(@class, '^impress', 'i')]]]">
    <xsl:copy>
      <xsl:attribute name="epub:type" select="'imprint'"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/opf:epub/html/body/div[@class eq 'epub-html-split'][preceding-sibling::*[1][self::div[matches(@class, '^impress', 'i')]]]">
    <xsl:copy>
      <xsl:attribute name="epub:type" select="'bodymatter'"/>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
