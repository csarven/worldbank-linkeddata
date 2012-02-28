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
    xmlns:wgs="http://www.w3.org/2003/01/geo/wgs84_pos#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:wb="http://www.worldbank.org"
    xmlns:wbld="http://worldbank.270a.info/"
    xmlns:property="http://worldbank.270a.info/property/">

    <xsl:import href="common.xsl"/>
    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="wbapi_lang"/>
    <xsl:variable name="wbld">http://worldbank.270a.info/</xsl:variable>

    <xsl:template match="/">
        <rdf:RDF>
        <xsl:call-template name="sources"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="sources">
        <xsl:variable name="currentDateTime" select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>

        <rdf:Description rdf:about="{$wbld}classification/source">
            <rdf:type rdf:resource="http://purl.org/linked-data/sdmx#CodeList"/>
            <skos:prefLabel xml:lang="en">Code list for sources</skos:prefLabel>

            <xsl:variable name="dataSource">
                <xsl:text>http://api.worldbank.org/sources?format=xml</xsl:text>
            </xsl:variable>
            <xsl:call-template name="provenance">
                <xsl:with-param name="date" select="$currentDateTime"/>
                <xsl:with-param name="dataSource" select="$dataSource"/>
            </xsl:call-template>
        </rdf:Description>

        <xsl:for-each select="wb:sources/wb:source">
            <rdf:Description rdf:about="{$wbld}classification/source">
                <skos:hasTopConcept rdf:resource="{$wbld}classification/source/{@id}"/>
            </rdf:Description>

            <rdf:Description rdf:about="{$wbld}classification/source/{@id}">
                <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>

                <skos:inScheme rdf:resource="{$wbld}classification/source"/>
                <skos:topConceptOf rdf:resource="{$wbld}classification/source"/>

                <skos:notation><xsl:value-of select="@id"/></skos:notation>

                <xsl:if test="wb:name != ''">
                <skos:prefLabel xml:lang="{$wbapi_lang}"><xsl:value-of select="wb:name/text()"/></skos:prefLabel>
                </xsl:if>

                <xsl:if test="wb:description != ''">
                <skos:definition xml:lang="{$wbapi_lang}"><xsl:value-of select="wb:description/text()"/></skos:definition>
                </xsl:if>

                <xsl:if test="wb:url != ''">
                <foaf:page rdf:resource="{normalize-space(wb:url/text())}"/>
                </xsl:if>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
