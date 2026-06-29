<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    exclude-result-prefixes="mei xs">
    
    <!-- PARAMETER: space-separated list of MEI files -->
    <xsl:param name="meiFiles" as="xs:string" select="'sources/facsimile_part_01_flauto.xml sources/facsimile_part_02_oboe_1.xml sources/facsimile_part_03_oboe_2.xml sources/facsimile_part_04_clarinetto_1.xml sources/facsimile_part_05_clarinetto_2.xml sources/facsimile_part_06_fagotto.xml sources/facsimile_part_07_corno_1.xml sources/facsimile_part_08_corno_2.xml sources/facsimile_part_09_violino_1.xml sources/facsimile_part_10_violino_2.xml sources/facsimile_part_11_viola.xml sources/facsimile_part_12_basso.xml sources/facsimile_part_13_basso_2.xml sources/numero01_fac_score.xml sources/numero03_fac_score.xml sources/numero05_fac_score.xml edition/numero01.xml edition/numero03.xml edition/numero05_vMain.xml'"/>
    <xsl:param name="movement" as="xs:integer" select="5"/>
    <!-- Parameter: special files in which the cut is applied in number 5 -->
    <xsl:param name="specialFiles" as="xs:string*"
        select="('sources/facsimile_part_01_flauto.xml',
        'sources/facsimile_part_02_oboe_1.xml',
        'sources/facsimile_part_03_oboe_2.xml',
        'sources/facsimile_part_04_clarinetto_1.xml',
        'sources/facsimile_part_05_clarinetto_2.xml',
        'sources/facsimile_part_06_fagotto.xml',
        'sources/facsimile_part_07_corno_1.xml',
        'sources/facsimile_part_08_corno_2.xml',
        'sources/facsimile_part_09_violino_1.xml',
        'sources/facsimile_part_10_violino_2.xml',
        'sources/facsimile_part_11_viola.xml',
        'sources/facsimile_part_12_basso.xml',
        'sources/facsimile_part_13_basso_2.xml',
        'edition/numero05_vMain.xml')" />
    
    <xsl:template match="/">
        <connections label="Takt">
            
            <!-- Step 1: Load all documents and attach original file path to measures -->
            <xsl:variable name="allMeasures" as="element(mei:measure)*">
                <xsl:for-each select="tokenize(normalize-space($meiFiles), '\s+')">
                    <xsl:variable name="filePath" select="."/>
                    <xsl:variable name="doc" select="document($filePath)"/>
                    
                    <xsl:for-each select="$doc//mei:mdiv[@n=$movement]//mei:measure">
                        <!-- store the measure node so inner loop can reference it -->
                        <xsl:variable name="measureNode" select="."/>
                        <!-- compute distinct numeric tokens from @n (remove whitespace, split on comma or equals) -->
                        <xsl:variable name="nValues" as="xs:string*" 
                            select="distinct-values(tokenize(replace(@n, '\s', ''), '[,=]'))"/>
                        
                        <!-- replicate the measure for each parsed n -->
                        <xsl:for-each select="$nValues">
                            <xsl:variable name="nValue" select="."/>
                            <!-- Modify the measure number if we are in the second part of a file with cut in movement 5 NN=43-28=15 -->
                            <xsl:variable name="nValueAdjusted"
                                select="
                                if ($movement = 5 and $filePath = $specialFiles and number($nValue) > 27)
                                then string(number($nValue) + 15)
                                else $nValue
                                "/>
                            <!-- create a new mei:measure element in the MEI namespace -->
                            <xsl:element name="mei:measure" namespace="http://www.music-encoding.org/ns/mei">
                                <!-- copy all original attributes except the original @n -->
                                <xsl:copy-of select="$measureNode/@*[not(local-name() = 'n')]"/>
                                <!-- set the new @n to the single token value -->
                                <xsl:attribute name="n" select="$nValueAdjusted"/>
                                <!-- attach the source file path -->
                                <xsl:attribute name="data-path" select="$filePath"/>
                                <!-- copy the children (notes, etc.) -->
                                <xsl:copy-of select="$measureNode/node()"/>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:variable>
            
            <!-- Step 2: Group measures by @n -->
            <xsl:for-each-group select="$allMeasures" group-by="@n">
                <xsl:sort select="number(current-grouping-key())"/>
                <xsl:variable name="n" select="current-grouping-key()"/>
                
                <connection name="{$n}">
                    <xsl:attribute name="plist">
                        <xsl:for-each select="current-group()">
                            <xsl:variable name="tokens" select="tokenize(@data-path,'/')" as="xs:string*"/>
                            <xsl:variable name="filename" select="if (exists($tokens[last()])) then $tokens[last()] else 'unknown.xml'"/>
                            <xsl:variable name="folder" select="if (count($tokens) gt 1) then $tokens[last()-1] else ''"/>
                            <xsl:variable name="xmlid" select="@xml:id"/>
                            
                            <xsl:text>xmldb:exist:///db/apps/edirom/adelson_e_salvini_model/content/</xsl:text>
                            <xsl:if test="string-length($folder) gt 0">
                                <xsl:value-of select="$folder"/>
                                <xsl:text>/</xsl:text>
                            </xsl:if>
                            <xsl:value-of select="$filename"/>
                            <xsl:text>#</xsl:text>
                            <xsl:value-of select="$xmlid"/>
                            
                            <!-- Space between multiple entries -->
                            <xsl:if test="position() != last()">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:attribute>
                </connection>
            </xsl:for-each-group>
            
        </connections>
    </xsl:template>
    
</xsl:stylesheet>
