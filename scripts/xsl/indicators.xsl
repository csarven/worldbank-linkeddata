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
        <xsl:call-template name="indicators"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="indicators">
        <xsl:variable name="currentDateTime" select="wbldfn:now()"/>

        <rdf:Description rdf:about="{$wbld}classification/indicator">
            <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#ConceptScheme"/>
            <skos:prefLabel xml:lang="en">Code list for World Bank indicators</skos:prefLabel>
            <skos:prefLabel xml:lang="fr">Liste des codes pour les indicateurs de développement dans le monde</skos:prefLabel>
            <skos:prefLabel xml:lang="es">Lista de códigos para el mundo de los indicadores de desarrollo</skos:prefLabel>
            <skos:prefLabel xml:lang="ar">قائمة رمز لمؤشرات التنمية العالمية</skos:prefLabel>

            <skos:definition xml:lang="en">Indicators represent data like total population, gross national income, energy use, and many more.</skos:definition>

            <skos:closeMatch rdf:resource="http://dbpedia.org/resource/World_Development_Indicators"/>

            <xsl:variable name="dataSource">
                <xsl:text>http://api.worldbank.org/indicators?format=xml</xsl:text>
            </xsl:variable>
            <xsl:call-template name="provenance">
                <xsl:with-param name="date" select="$currentDateTime"/>
                <xsl:with-param name="dataSource" select="$dataSource"/>
            </xsl:call-template>
        </rdf:Description>

        <xsl:for-each select="wb:indicators/wb:indicator">
            <xsl:variable name="id" select="normalize-space(@id)"/>

            <xsl:if test="not(contains($id, ' '))">
                <rdf:Description rdf:about="{$wbld}dataset/{$id}">
                    <rdf:type rdf:resource="http://purl.org/linked-data/cube#DataSet"/>
                    <dcterms:isPartOf rdf:resource="{$wbld}dataset/world-bank-indicators"/>

                    <xsl:if test="wb:name != ''">
                    <dcterms:title xml:lang="{$wbapi_lang}"><xsl:value-of select="normalize-space(wb:name/text())"/></dcterms:title>
                    </xsl:if>
                    <dcterms:source rdf:resource="http://api.worldbank.org/{$wbapi_lang}/countries/all/indicators/{$id}?format=xml"/>
                    <qb:structure rdf:resource="{$wbld}dataset/world-development-indicators/structure"/>
                </rdf:Description>

                <rdf:Description rdf:about="{$wbld}classification/indicator">
                    <skos:hasTopConcept rdf:resource="{$wbld}classification/indicator/{$id}"/>
                </rdf:Description>

                <rdf:Description rdf:about="{$wbld}classification/indicator/{$id}">
                    <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>

                    <skos:inScheme rdf:resource="{$wbld}classification/indicator"/>
                    <skos:topConceptOf rdf:resource="{$wbld}classification/indicator"/>

                    <skos:notation><xsl:value-of select="$id"/></skos:notation>

                    <xsl:if test="wb:name != ''">
                    <skos:prefLabel xml:lang="{$wbapi_lang}"><xsl:value-of select="normalize-space(wb:name/text())"/></skos:prefLabel>
                    </xsl:if>

                    <foaf:page rdf:resource="http://data.worldbank.org/indicator/{$id}"/>

                    <xsl:if test="wb:source/@id">
                    <property:source rdf:resource="{$wbld}classification/source/{normalize-space(wb:source/@id)}"/>
                    </xsl:if>

                    <xsl:if test="wb:sourceNote != ''">
                    <skos:definition xml:lang="{$wbapi_lang}"><xsl:value-of select="normalize-space(wb:sourceNote/text())"/></skos:definition>
                    </xsl:if>

                    <xsl:if test="wb:sourceOrganization != ''">
                    <property:source-organization xml:lang="{$wbapi_lang}"><xsl:value-of select="wb:sourceOrganization/text()"/></property:source-organization>
                    </xsl:if>

                    <xsl:for-each select="wb:topics/wb:topic">
                    <property:topic rdf:resource="{$wbld}classification/topic/{normalize-space(@id)}"/>
                    </xsl:for-each>

                    <xsl:variable name="dataSource">
                        <xsl:text>http://api.worldbank.org/indicator/</xsl:text><xsl:value-of select="$id"/><xsl:text>?format=xml</xsl:text>
                    </xsl:variable>
                    <xsl:call-template name="provenance">
                        <xsl:with-param name="date" select="$currentDateTime"/>
                        <xsl:with-param name="dataSource" select="$dataSource"/>
                    </xsl:call-template>
                </rdf:Description>
            </xsl:if>
        </xsl:for-each>

        <rdf:Description rdf:about="{$wbld}property/indicator">
            <rdf:type rdf:resource="http://purl.org/linked-data/cube#DimensionProperty"/>
            <rdf:type rdf:resource="http://www.w3.org/1999/02/22-rdf-syntax-ns#Property"/>
            <rdfs:label xml:lang="en">Indicator</rdfs:label>
            <qb:codeList rdf:resource="{$wbld}classification/indicator"/>
        </rdf:Description>
    </xsl:template>
</xsl:stylesheet>
