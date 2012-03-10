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
    xmlns:dbp="http://dbpedia.org/property/"
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
        <xsl:call-template name="countries"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="countries">
        <xsl:variable name="currentDateTime" select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>

        <rdf:Description rdf:about="{$wbld}classification/country">
            <!-- <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#ConceptScheme"/> -->
            <rdf:type rdf:resource="http://purl.org/linked-data/sdmx#CodeList"/>
            <skos:prefLabel xml:lang="en">Code list for countries</skos:prefLabel>
            <skos:prefLabel xml:lang="fr">Liste des codes pour les pays</skos:prefLabel>
            <skos:prefLabel xml:lang="es">Lista de códigos de países</skos:prefLabel>
            <skos:prefLabel xml:lang="ar">قائمة رمز للبلدان</skos:prefLabel>
            <skos:note xml:lang="en">The World Bank follows the ISO 3 letter and 2 letter codes to represent most of the countries, with the following exceptions:

3 letter Code differences: Andorra, Congo, Dem. Rep., Isle of Man, Romania, Timor-Leste, West Bank and Gaza

2 letter Code differences: Congo, Dem. Rep., Serbia, Timor-Leste, Yemen, Rep., West Bank and Gaza

Countries not yet represented using ISO codes: Channel Islands, Kosovo</skos:note>

            <skos:closeMatch rdf:resource="http://dbpedia.org/ontology/Country"/>

            <xsl:variable name="dataSource">
                <xsl:text>http://api.worldbank.org/countries?format=xml</xsl:text>
            </xsl:variable>
            <xsl:call-template name="provenance">
                <xsl:with-param name="date" select="$currentDateTime"/>
                <xsl:with-param name="dataSource" select="$dataSource"/>
            </xsl:call-template>
        </rdf:Description>

        <!-- XXX: Consider what to do rdf:about non-countries e.g., 1A, 1W, 4E, 7E, 8S, B1, B2, B3, B4, B6, B7, D2, D3, D4, D5, D6, D7, D8, D9, T2, T3, T4, T6, T7, XC, XD, XE, XJ, XL, XM, XN, XO, XP, XQ, XR, XS, XT, XU, XY, Z4, Z7, ZB, ZF, ZG, ZJ, ZQ, ZT
            e.g., Skip over them;
                  Leave an rdfs:comment
        -->
        <xsl:for-each select="wb:countries/wb:country">
            <rdf:Description rdf:about="{$wbld}classification/country">
                <skos:hasTopConcept rdf:resource="{$wbld}classification/country/{normalize-space(wb:iso2Code/text())}"/>
            </rdf:Description>

            <rdf:Description rdf:about="{$wbld}classification/country/{normalize-space(wb:iso2Code/text())}">
                <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
                <rdf:type rdf:resource="http://dbpedia.org/ontology/Country"/>
                <!-- XXX: Only one is necessary since both have the same value-->
                <skos:inScheme rdf:resource="{$wbld}classification/country"/>
                <skos:topConceptOf rdf:resource="{$wbld}classification/country"/>

                <!--
                <skos:notation><xsl:value-of select="@id"/></skos:notation>
                -->
                <skos:notation><xsl:value-of select="wb:iso2Code/text()"/></skos:notation>

                <xsl:if test="wb:iso2Code/text() != ''">
                <skos:exactMatch rdf:resource="{$wbld}classification/country/{@id}"/>
                </xsl:if>

                <xsl:if test="wb:name != ''">
                <skos:prefLabel xml:lang="{$wbapi_lang}"><xsl:value-of select="wb:name/text()"/></skos:prefLabel>
                </xsl:if>

                <xsl:if test="wb:region/@id != ''">
                <property:region rdf:resource="{$wbld}classification/region/{wb:region/@id}"/>
                </xsl:if>

                <xsl:if test="wb:adminregion/@id != ''">
                <property:admin-region rdf:resource="{$wbld}classification/region/{wb:adminregion/@id}"/>
                </xsl:if>

                <xsl:if test="wb:incomeLevel/@id != ''">
                <property:income-level rdf:resource="{$wbld}classification/income-level/{wb:incomeLevel/@id}"/>
                </xsl:if>

                <xsl:if test="wb:lendingType/@id != ''">
                <property:lending-type rdf:resource="{$wbld}classification/lending-type/{wb:lendingType/@id}"/>
                </xsl:if>

                <xsl:if test="wb:capitalCity != ''">
                <dbp:capital xml:lang="{$wbapi_lang}"><xsl:value-of select="wb:capitalCity/text()"/></dbp:capital>
                </xsl:if>

                <xsl:if test="wb:longitude != ''">
                <wgs:long rdf:datatype="http://www.w3.org/2001/XMLSchema#float"><xsl:value-of select="wb:longitude/text()"/></wgs:long>
                </xsl:if>

                <xsl:if test="wb:latitude != ''">
                <wgs:lat rdf:datatype="http://www.w3.org/2001/XMLSchema#float"><xsl:value-of select="wb:latitude/text()"/></wgs:lat>
                </xsl:if>

                <foaf:page rdf:resource="http://data.worldbank.org/country/{normalize-space(wb:iso2Code/text())}"/>
            </rdf:Description>

            <rdf:Description rdf:about="{$wbld}classification/country/{@id}">
                <skos:notation><xsl:value-of select="@id"/></skos:notation>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
