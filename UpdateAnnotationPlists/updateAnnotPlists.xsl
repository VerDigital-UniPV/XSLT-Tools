<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="mei">
    
    <!-- Declare parameters -->
    <xsl:param name="old.path"/>
    <xsl:param name="new.paths"/>
    
    <!-- Identity template: copy everything as is -->
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" />
        </xsl:copy>
    </xsl:template>
    
    <!-- Match the <annot> nodes -->
    <xsl:template match="mei:annot">
        <xsl:copy>
            <!-- Copy existing attributes -->
            <xsl:copy-of select="@*"/>
            
            <!-- Process the plist attribute -->
            <xsl:attribute name="plist">               
                <!-- Call the recursive template to split the plist value -->
                <xsl:call-template name="split-plist">
                    <xsl:with-param name="plist" select="@plist"/>
                </xsl:call-template>
            </xsl:attribute>
            
            <!-- Process and copy child elements -->
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Recursive template to split the plist attribute value by spaces -->
    <xsl:template name="split-plist">
        <xsl:param name="plist"/>
        <xsl:param name="isFirst" select="true()"/>
        
        <!-- Base case: If the plist is empty, do nothing -->
        <xsl:if test="string($plist) != ''">
            <!-- Split on space -->
            <xsl:variable name="first" select="substring-before(concat($plist, ' '), ' ')"/>
            <xsl:variable name="rest" select="substring-after($plist, ' ')"/>
            
            <!-- Detect tail (e.g., #something) -->
            <xsl:variable name="has-tail" select="contains($first, '#')"/>
            <xsl:variable name="path-base" select="substring-before($first, '#')"/>
            <xsl:variable name="tail" select="substring-after($first, '#')"/>
            
            <!-- Add original path -->

            <!-- If it's NOT the old path, output it -->
            <xsl:if test="$path-base != $old.path">
                <!-- Add space before non-first items -->
                <xsl:if test="not($isFirst)">
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:value-of select="$first"/>
            </xsl:if>
            
            <!-- If the path-base matches old.path, append new.paths with tail -->
            <xsl:if test="$path-base = $old.path">
                <xsl:if test="not($isFirst)">
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:call-template name="append-new-paths">
                    <xsl:with-param name="tail" select="$tail"/>
                    <xsl:with-param name="prefix-space" select="false()"/>
                </xsl:call-template>
            </xsl:if>
            
            <!-- Process the rest of the plist -->
            <xsl:if test="$rest != ''">
                <xsl:text> </xsl:text>
                <xsl:call-template name="split-plist">
                    <xsl:with-param name="plist" select="$rest"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <!-- Template to append new.paths, adding tail if present -->
    <xsl:template name="append-new-paths">
        <xsl:param name="tail"/>
        
        <!-- Loop through each new path -->
        <xsl:call-template name="split-space-list">
            <xsl:with-param name="list" select="$new.paths"/>
            <xsl:with-param name="tail" select="$tail"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Helper: Split space-separated list and append tail -->
    <xsl:template name="split-space-list">
        <xsl:param name="list"/>
        <xsl:param name="tail"/>
        <xsl:if test="string($list) != ''">
            <xsl:variable name="first" select="substring-before(concat($list, ' '), ' ')"/>
            <xsl:variable name="rest" select="substring-after($list, ' ')"/>
            
            <xsl:text> </xsl:text>
            <xsl:value-of select="$first"/>
            <xsl:if test="string($tail) != ''">
                <xsl:text>#</xsl:text>
                <xsl:value-of select="$tail"/>
            </xsl:if>
            
            <xsl:call-template name="split-space-list">
                <xsl:with-param name="list" select="$rest"/>
                <xsl:with-param name="tail" select="$tail"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>
