<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="tei">
    
    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="output-filename" as="xs:string"/>
    
    <!-- Definition of the sources -->
    <xsl:variable name="sources" as="xs:string*" select="('#1816', '#1825')"/>
    
    <!-- Actual processing -->
    <xsl:template match="/">
        <xsl:variable name="doc" select="."/>
        
        <xsl:for-each select="$sources">
            <xsl:variable name="sourceID" select="."/>
            <xsl:variable name="cleanSourceName" select="replace($sourceID, '#', '')"/>
            <xsl:result-document href="{$output-filename}/{$output-filename}_{$cleanSourceName}.xml">
                <xsl:apply-templates select="$doc" mode="bySource">
                    <xsl:with-param name="sourceID" select="$sourceID"/>
                </xsl:apply-templates>
            </xsl:result-document>            
        </xsl:for-each>
    </xsl:template>
    
    <!-- Identity transform for all modes -->
    <xsl:template match="@*|node()" mode="bySource">
        <xsl:param name="sourceID"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="bySource">
                <xsl:with-param name="sourceID" select="$sourceID"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <!-- Override for <app> in outputs -->
    <xsl:template match="tei:app" mode="bySource">
        <xsl:param name="sourceID"/>
        <xsl:variable name="selectedRdg" select="tei:rdg[@source = $sourceID]"/>
        <xsl:apply-templates select="$selectedRdg/node()" mode="bySource">
            <xsl:with-param name="sourceID" select="$sourceID"/>
        </xsl:apply-templates>
    </xsl:template>

    <!-- Add the line number to l by selecting it from the right source lb -->
    <xsl:template match="tei:l" mode="bySource">
        <xsl:param name="sourceID"/>
        <xsl:variable name="lineNumber" select="tei:lb[@ed = $sourceID]/@n"/>
        <xsl:copy>
            <xsl:attribute name="n">
                <xsl:value-of select="$lineNumber"/>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()" mode="bySource">
                <xsl:with-param name="sourceID" select="$sourceID"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <!-- Avoid copying lb -->
    <xsl:template match="tei:lb" mode="bySource">
        <xsl:param name="sourceID"/>
    </xsl:template>
</xsl:stylesheet>