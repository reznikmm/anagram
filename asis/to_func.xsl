<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.0'>

<xsl:output method="xml" indent="yes"/>

<xsl:template match="/">
<map>
  <xsl:apply-templates select= "//node[not (@helper) and not (@abstract)]"/>
  <item name="A_Procedure" func="Unit_Kind"/>
  <item name="A_Subunit" func="Unit_Kind"/>
  <item name="A_Discrete_Range" func="Definition_Kind"/>
  <item name="A_Discrete_Subtype_Definition" func="Definition_Kind"/>
  <item name="Access_To_Object_Definition" func="Access_Type_Kind"/>
  <item name="An_Anonymous_Access_to_Object_Definition"
	func="Access_Definition_Kind"/>
</map>
</xsl:template>

<xsl:template match="node[@name='Element']"/>
<xsl:template match="node[@name='An_Any_Compilation_Unit']"/>

<xsl:template match="node">
  <xsl:variable name="name" select="@name"/>
  <xsl:variable name="parents" select="ancestor::node[not (@helper) and @abstract]"/>
  <xsl:variable name="parent" select="$parents[position()=last()]"/>

  <item name="{$name}">
    <xsl:attribute name="func">
      <xsl:choose>
	<xsl:when test="$parent/@name='A_Type_Definition'">
	  <xsl:text>Type</xsl:text>
	</xsl:when>
	<xsl:when test="$parent/@name='Element'">
	  <xsl:value-of select="$parent/@name"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="substring-after($parent/@name,'_')"/>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:text>_Kind</xsl:text>
    </xsl:attribute>
  </item>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>
