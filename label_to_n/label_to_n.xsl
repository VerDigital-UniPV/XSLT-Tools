<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mei="http://www.music-encoding.org/ns/mei">
    
    <xsl:template match="mei:measure">
        <xsl:copy>
            <!-- copy all existing attributes except @n (optional) -->
            <xsl:apply-templates select="@*|node()"/>
            
            <!-- add or overwrite @n with the value of @label -->
            <xsl:attribute name="n">
                <xsl:value-of select="@label"/>
            </xsl:attribute>
            
            <!-- copy child nodes -->
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Identity template: copy everything by default -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>