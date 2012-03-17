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
    xmlns:wb="http://www.worldbank.org"
    xmlns:wbld="http://worldbank.270a.info/"
    xmlns:property="http://worldbank.270a.info/property/">

    <xsl:import href="common.xsl"/>
    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="wbapi_lang"/>
    <xsl:variable name="wbld">http://worldbank.270a.info/</xsl:variable>

    <xsl:template match="/">
        <rdf:RDF>
        <xsl:call-template name="topics"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="topics">
        <xsl:variable name="currentDateTime" select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>

        <rdf:Description rdf:about="{$wbld}classification/topic">
            <rdf:type rdf:resource="http://purl.org/linked-data/sdmx#CodeList"/>
            <skos:prefLabel xml:lang="en">Code list for topics</skos:prefLabel>
            <skos:definition xml:lang="en">Topics are high level categories that all indicators are mapped to.</skos:definition>

            <xsl:variable name="dataSource">
                <xsl:text>http://api.worldbank.org/topics?format=xml</xsl:text>
            </xsl:variable>
            <xsl:call-template name="provenance">
                <xsl:with-param name="date" select="$currentDateTime"/>
                <xsl:with-param name="dataSource" select="$dataSource"/>
            </xsl:call-template>
        </rdf:Description>

        <xsl:for-each select="wb:topics/wb:topic">
            <rdf:Description rdf:about="{$wbld}classification/topic">
                <skos:hasTopConcept rdf:resource="{$wbld}classification/topic/{@id}"/>
            </rdf:Description>

            <rdf:Description rdf:about="{$wbld}classification/topic/{@id}">
                <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>

                <skos:inScheme rdf:resource="{$wbld}classification/topic"/>
                <skos:topConceptOf rdf:resource="{$wbld}classification/topic"/>

                <skos:notation><xsl:value-of select="@id"/></skos:notation>

                <xsl:if test="wb:value != ''">
                <skos:prefLabel xml:lang="{$wbapi_lang}"><xsl:value-of select="wb:value/text()"/></skos:prefLabel>
                </xsl:if>

                <xsl:if test="wb:sourceNote != ''">
                <skos:definition xml:lang="{$wbapi_lang}"><xsl:value-of select="wb:sourceNote/text()"/></skos:definition>
                </xsl:if>
            </rdf:Description>
        </xsl:for-each>

        <rdf:Description rdf:about="{$wbld}property/topic">
            <rdf:type rdf:resource="http://purl.org/linked-data/cube#DimensionProperty"/>
            <rdfs:label xml:lang="en">Indicator topic</rdfs:label>
            <qb:concept rdf:resource="{$wbld}classification/topic"/>
            <qb:codeList rdf:resource="{$wbld}classification/topic"/>
        </rdf:Description>
    </xsl:template>
</xsl:stylesheet>
