<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URL: http://csarven.ca/#i
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:wbldfn="http://worldbank.270a.info/xpath-function/"
    xmlns:wgs="http://www.w3.org/2003/01/geo/wgs84_pos#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:qb="http://purl.org/linked-data/cube#"
    xmlns:sdmx-dimension="http://purl.org/linked-data/sdmx/2009/dimension#"
    xmlns:sdmx-measure="http://purl.org/linked-data/sdmx/2009/measure#"
    xmlns:wb="http://www.worldbank.org"
    xmlns:wbld="http://worldbank.270a.info/"
    xmlns:property="http://worldbank.270a.info/property/">

    <xsl:import href="common.xsl"/>
    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="wbapi_lang"/>
    <xsl:variable name="wbld">http://worldbank.270a.info/</xsl:variable>

    <xsl:template match="/">
        <rdf:RDF>
        <xsl:call-template name="indicatorsObservations"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="indicatorsObservations">
        <xsl:variable name="currentDateTime" select="wbldfn:now()"/>

        <xsl:for-each select="wb:data/wb:data">
            <xsl:variable name="wbld_indicator" select="normalize-space(wb:indicator/@id)"/>

            <!-- TODO See if we can use country codes here instead for non-countries in countries.xml
                e.g., where World is 1W. What would Africa be?
            -->
            <xsl:variable name="wbld_country">
                <xsl:choose>
                    <xsl:when test="wb:country/@id = ''">
                        <xsl:value-of select="normalize-space(wb:country/text())"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(wb:country/@id)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="wbld_date" select="normalize-space(wb:date/text())"/>

            <rdf:Description rdf:about="{$wbld}dataset/world-development-indicators/{$wbld_indicator}#{$wbld_country};{$wbld_date}">
                <rdf:type rdf:resource="http://purl.org/linked-data/cube#Observation"/>
                <qb:dataSet rdf:resource="{$wbld}dataset/world-development-indicators"/>

                <property:indicator rdf:resource="{$wbld}classification/indicator/{$wbld_indicator}"/>

                <!-- TODO See if we can use country codes here instead for non-countries in countries.xml
                    e.g., where World is 1W. What would Africa be?
                    <property:iso2Code rdf:resource="{$wbld}classification/country/{$wbld_country}"/>
                -->
                <sdmx-dimension:refArea rdf:resource="{$wbld}classification/country/{$wbld_country}"/>

                <sdmx-dimension:refPeriod rdf:resource="http://reference.data.gov.uk/id/year/{$wbld_date}"/>

                <sdmx-measure:obsValue><xsl:value-of select="wb:value/text()"/></sdmx-measure:obsValue>

                <property:decimal><xsl:value-of select="wb:decimal/text()"/></property:decimal>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
