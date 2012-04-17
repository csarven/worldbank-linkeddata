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
        <xsl:call-template name="incomelevels"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="incomelevels">
        <xsl:variable name="currentDateTime" select="wbldfn:now()"/>

        <rdf:Description rdf:about="{$wbld}classification/income-level">
            <!-- <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#ConceptScheme"/> -->
            <rdf:type rdf:resource="http://purl.org/linked-data/sdmx#CodeList"/>
            <skos:prefLabel xml:lang="en">Code list for income levels</skos:prefLabel>
            <skos:definition xml:lang="en">Income levels show the income category of a particular country as identified by the World Bank. Income levels themselves just have a name and an id code.</skos:definition>

            <xsl:variable name="dataSource">
                <xsl:text>http://api.worldbank.org/incomeLevels?format=xml</xsl:text>
            </xsl:variable>
            <xsl:call-template name="provenance">
                <xsl:with-param name="date" select="$currentDateTime"/>
                <xsl:with-param name="dataSource" select="$dataSource"/>
            </xsl:call-template>
        </rdf:Description>

        <xsl:for-each select="wb:IncomeLevels/wb:incomeLevel">
            <rdf:Description rdf:about="{$wbld}classification/income-level">
                <skos:hasTopConcept rdf:resource="{$wbld}classification/income-level/{@id}"/>
            </rdf:Description>

            <rdf:Description rdf:about="{$wbld}classification/income-level/{@id}">
                <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>

                <skos:inScheme rdf:resource="{$wbld}classification/income-level"/>
                <skos:topConceptOf rdf:resource="{$wbld}classification/income-level"/>

                <skos:notation><xsl:value-of select="@id"/></skos:notation>

                <xsl:if test="text() != ''">
                <skos:prefLabel xml:lang="{$wbapi_lang}"><xsl:value-of select="text()"/></skos:prefLabel>
                </xsl:if>
            </rdf:Description>
        </xsl:for-each>

        <rdf:Description rdf:about="{$wbld}property/income-level">
            <rdf:type rdf:resource="http://purl.org/linked-data/cube#DimensionProperty"/>
            <rdfs:label xml:lang="en">Income level</rdfs:label>
            <qb:concept rdf:resource="{$wbld}classification/income-level"/>
            <qb:codeList rdf:resource="{$wbld}classification/income-level"/>
        </rdf:Description>
    </xsl:template>
</xsl:stylesheet>
