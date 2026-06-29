<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mei="http://www.music-encoding.org/ns/mei">

  <!-- Identity template: copy everything by default -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <!-- Copy all attributes except those whose name or value contains 'substring' -->
      <xsl:apply-templates select="@*[not(contains(name(), 'mscore') or contains(., 'mscore'))]" />
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>  

</xsl:stylesheet>
