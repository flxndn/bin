<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 
	<xsl:output omit-xml-declaration="yes" indent="no"/>
	<xsl:template match="AREA">
		<xsl:text>$array[] = </xsl:text>
		
		<xsl:value-of select="@COORDS"/>
		<xsl:text>	</xsl:text>
		<xsl:value-of select="@ALT"/>
		<xsl:text>
</xsl:text>
	</xsl:template>
	<xsl:template match="text()" />
</xsl:stylesheet>
