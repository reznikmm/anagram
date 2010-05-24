<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.0'>

<xsl:output method="text"/>

<xsl:template match="/">
  <xsl:apply-templates select= "/ast/*"/>
</xsl:template>

<xsl:template match="alt_rule">
  <xsl:for-each select="alternative">
    <xsl:variable name="name" select="@name"/>
    <xsl:if test="not(//alt_rule[@name=$name]) and not (//rule[@name=$name])">
      <xsl:value-of select="$name"/> undefined
</xsl:if>
  </xsl:for-each>
  <xsl:variable name="my_name" select="@name"/>
    <xsl:if test=
     "not(//alternative[@name=$my_name]) and not (//child[@name=$my_name])">
      <xsl:value-of select="$my_name"/> unused
</xsl:if>
</xsl:template>

<xsl:template match="rule">
  <xsl:for-each select="child">
    <xsl:variable name="name" select="@name"/>
    <xsl:if test="not(//alt_rule[@name=$name]) and not (//rule[@name=$name])">
      <xsl:value-of select="$name"/> undefined
</xsl:if>
  </xsl:for-each>
  <xsl:variable name="my_name" select="@name"/>
    <xsl:if test=
     "not(//alternative[@name=$my_name]) and not (//child[@name=$my_name])">
      <xsl:value-of select="$my_name"/> unused
</xsl:if>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>
