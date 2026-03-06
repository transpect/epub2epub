<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:e2e="http://transpect.io/epub2epub"
  xmlns="http://www.w3.org/1999/xhtml" 
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs e2e"
  version="3.0">
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:variable name="e2e:headings" as="element()*"
                select="//*[local-name() = ('h1', 'h2', 'h3', 'h4', 'h5', 'h6')]"/>
  
  <xsl:variable name="e2e:sequential-heading-order" as="xs:integer*" 
                select="e2e:create-sequential-heading-order(
                          e2e:get-heading-levels($e2e:headings)
                        )"/>
  
  <xsl:template match="h2
                      |h3
                      |h4
                      |h5
                      |h6">
    <xsl:variable name="sequential-heading-level" as="xs:integer" select="e2e:get-sequential-heading-level(.)"/>
    <xsl:element name="h{$sequential-heading-level}">
      <xsl:apply-templates select="@*, node()"/>
    </xsl:element>
  </xsl:template>
  
  <!-- e2e:get-sequential-heading-level( element(), element()+ ) => xs:integer
       First argument is the current heading and the second argument are all headings 
       in the document. Provdes the sequential heading level as output. -->
  
  <xsl:function name="e2e:get-sequential-heading-level" as="xs:integer">
    <xsl:param name="heading" as="element()"/>
    <xsl:param name="heading-seq" as="element()+"/>
    <xsl:variable name="i" as="xs:integer" 
                  select="index-of($heading-seq/generate-id(), $heading/generate-id())"/>
    <xsl:sequence select="e2e:create-sequential-heading-order(
                            e2e:get-heading-levels($heading-seq)
                          )[$i]"/>
  </xsl:function>
  
  <!-- e2e:get-sequential-heading-level( element() ) => xs:integer
       Optimized shorthand function that takes only one argument, but depends 
       on the existence of $e2e:headings and $e2e:sequential-heading-order. The benefit 
       is that e2e:create-sequential-heading-order() is called only once, which helps
       save the climate and gives you more time with your friends and family. -->
  
  <xsl:function name="e2e:get-sequential-heading-level" as="xs:integer">
    <xsl:param name="heading" as="element()"/>
    <xsl:variable name="i" as="xs:integer" 
                  select="index-of($e2e:headings/generate-id(), $heading/generate-id())"/>
    <xsl:sequence select="$e2e:sequential-heading-order[$i]"/>
  </xsl:function>
  
  <!-- e2e:create-sequential-heading-order( xs:integer* ) => xs:integer*
       Takes a sequence of heading levels (e.g., 1, 2, 1, 4) and returns 
       true or false depending on whether they form a logical order. -->
  
  <xsl:function name="e2e:create-sequential-heading-order" as="xs:integer*">
    <xsl:param name="heading-levels" as="xs:integer*"/>
    <xsl:variable name="heading-levels-grouped-by-level" as="element(h-group)*">
      <xsl:for-each-group select="$heading-levels" group-adjacent=".">
        <h-group level="{current-group()[1]}">
          <xsl:for-each select="current-group()">
            <h><xsl:value-of select="."/></h>
          </xsl:for-each>
        </h-group>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:variable name="new-heading-levels" 
                  select="for $i in (1 to count($heading-levels-grouped-by-level))
                          return 
                            if($i = 1 or xs:integer($heading-levels-grouped-by-level[$i]/@level) - xs:integer($heading-levels-grouped-by-level[$i - 1]/@level) lt 2)
                            then 
                              for $j in $heading-levels-grouped-by-level[$i]/h 
                              return xs:integer($j)
                            else 
                              for $j in $heading-levels-grouped-by-level[$i]/h 
                              return xs:integer($heading-levels-grouped-by-level[$i - 1]/@level) + 1"/>
    <!-- The previous approach, which did not use grouping, caused an issue 
         where only the first heading in a sequence of same-level subheadings was corrected. -->
    <!--<xsl:variable name="new-heading-levels" 
                      select="for $i in (1 to count($heading-levels))
                              return 
                                if($i = 1 or $heading-levels[$i] - $heading-levels[$i - 1] lt 2)
                                then $heading-levels[$i] 
                                else $heading-levels[$i - 1] + 1"/>-->
    <xsl:choose>
      <xsl:when test="e2e:heading-levels-valid($new-heading-levels)">
        <xsl:sequence select="$new-heading-levels"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="e2e:create-sequential-heading-order($new-heading-levels)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- e2e:get-heading-levels( element()* ) => xs:integer*
       takes a sequence of headline elements, e.g. (<h1/>, <h2/>, <h1/>, <h4/>)
       returns the heading levels as sequence of integers, e.g. (1, 2, 1, 4) -->
  
  <xsl:function name="e2e:get-heading-levels" as="xs:integer*">
    <xsl:param name="headings" as="element()*"/>
    <xsl:sequence select="for $heading in $headings
                          return xs:integer(
                                   substring-after($heading/local-name(), 'h')
                                 )"/>
  </xsl:function>  

  <!-- e2e:heading-levels-valid( xs:integer* ) => xs:boolean*
       Takes a sequence of heading levels (e.g., 1, 2, 1, 4) and returns 
       true or false depending on whether they form a logical order. -->

  <xsl:function name="e2e:heading-levels-valid" as="xs:boolean*">
    <xsl:param name="heading-levels" as="xs:integer*"/>
    <xsl:sequence select="every $i in (1 to count($heading-levels))
                          satisfies
                            if($i = 1) 
                            then true() 
                            else $heading-levels[$i] - $heading-levels[$i - 1] lt 2"/>
  </xsl:function>
  
</xsl:stylesheet>