<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URL: http://csarven.ca/#i
-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:sdmx-code="http://purl.org/linked-data/sdmx/2009/code#"
    xmlns:property="http://worldbank.270a.info/property#"
    version="2.0">

    <xsl:import href="common.xsl"/>
    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="wbapi_lang"/>
    <xsl:param name="pathToCountries"/>

    <xsl:variable name="wbld">http://worldbank.270a.info/</xsl:variable>
    <xsl:variable name="sdmx-code">http://purl.org/linked-data/sdmx/2009/code#</xsl:variable>

    <xsl:template match="/ISO_CCY_CODES">
        <xsl:variable name="currentDateTime" select="wbldfn:now()"/>
        <rdf:RDF>
            <rdf:Description rdf:about="{$wbld}classification/currency">
                <rdf:type rdf:resource="http://purl.org/linked-data/sdmx#CodeList"/>
                <skos:prefLabel xml:lang="en">Code list for currencies</skos:prefLabel>
                <skos:exactMatch rdf:resource="http://dbpedia.org/ontology/Currency"/>

                <xsl:variable name="dataSource">
                    <xsl:text>http://www.currency-iso.org/dl_iso_table_a1.xml</xsl:text>
                </xsl:variable>
                <xsl:call-template name="provenance">
                    <xsl:with-param name="date" select="$currentDateTime"/>
                    <xsl:with-param name="dataSource" select="$dataSource"/>
                </xsl:call-template>
            </rdf:Description>

            <xsl:apply-templates select="*"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="ISO_CURRENCY">
        <xsl:if test="normalize-space(ALPHABETIC_CODE) != ''">
            <rdf:Description rdf:about="{$wbld}classification/currency">
                <skos:hasTopConcept rdf:resource="{$wbld}classification/currency/{normalize-space(ALPHABETIC_CODE)}"/>
            </rdf:Description>

            <rdf:Description rdf:about="{$wbld}classification/currency/{normalize-space(ALPHABETIC_CODE)}">
                <rdf:type rdf:resource="{$sdmx-code}Currency"/>
                <skos:inScheme rdf:resource="{$wbld}classification/currency"/>
                <skos:topConceptOf rdf:resource="{$wbld}classification/currency"/>
<!--
                dbo:usingCountry
                <property:using-country><xsl:value-of select="ENTITY"/></property:using-country>
-->
                <xsl:variable name="entity" select="lower-case(normalize-space(ENTITY))"/>

                <xsl:variable name="country" select="document($pathToCountries)/rdf:RDF/rdf:Description[skos:prefLabel/lower-case(text()) = $entity]/@rdf:about"/>

                <xsl:choose>
                    <xsl:when test="$country != ''">
                        <!-- XXX: I prefer to use 'currency' instead of 'currency-of-commitment' but that would mean that I have to change the property name in the dictionary wc6g-9zmq ... Hey Sarven from the past, do you reall have to change that? -->
                        <xsl:element name="property:using-country">
                            <xsl:attribute name="rdf:resource">
                               <xsl:value-of select="$country"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:element name="property:using-country">
                            <xsl:value-of select="ENTITY"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>

                <skos:prefLabel xml:lang="{$wbapi_lang}"><xsl:value-of select="CURRENCY"/></skos:prefLabel>
                <skos:notation><xsl:value-of select="ALPHABETIC_CODE"/></skos:notation>
                <property:numeric-code><xsl:value-of select="NUMERIC_CODE"/></property:numeric-code>
                <property:minor-unit><xsl:value-of select="MINOR_UNIT"/></property:minor-unit>
            </rdf:Description>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
