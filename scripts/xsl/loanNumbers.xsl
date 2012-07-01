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
    xmlns:sdmx-attribute="http://purl.org/linked-data/sdmx/2009/attribute#"
    xmlns:sdmx-dimension="http://purl.org/linked-data/sdmx/2009/dimension#"
    xmlns:sdmx-code="http://purl.org/linked-data/sdmx/2009/code#"
    xmlns:wb="http://www.worldbank.org"
    xmlns:wbs="http://search.worldbank.org/ns/1.0"
    xmlns:wbld="http://worldbank.270a.info/"
    xmlns:property="http://worldbank.270a.info/property/"
    xmlns:classification="http://worldbank.270a.info/classification/"
    xmlns:loan-number="http://worldbank.270a.info/classification/loan-number/"
    xmlns:lending-type="http://worldbank.270a.info/classification/lending-type/">

    <xsl:import href="common.xsl"/>
    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="wbapi_lang"/>
    <xsl:param name="pathToCountries"/>
    <xsl:param name="pathToLendingTypes"/>
    <xsl:param name="pathToCurrencies"/>
    <xsl:param name="pathToRegionsExtra"/>
    <xsl:param name="pathToMeta"/>

    <xsl:variable name="currentDateTime" select="wbldfn:now()"/>
    <xsl:variable name="wbld">http://worldbank.270a.info/</xsl:variable>
    <xsl:variable name="classification">http://worldbank.270a.info/classification/</xsl:variable>

    <xsl:template match="/">
        <rdf:RDF>
            <xsl:for-each select="distinct-values(/response/row/row/loan_number/text())">
                <xsl:call-template name="createLoanNumbers"/>
            </xsl:for-each>

            <xsl:for-each select="distinct-values(/response/row/row/credit_number/text())">
                <xsl:call-template name="createLoanNumbers"/>
            </xsl:for-each>

            <xsl:for-each select="distinct-values(/projects/project/wbs:projects.financier/text())">
                <xsl:call-template name="createLoanNumbers"/>
            </xsl:for-each>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="createLoanNumbers">
        <!-- XXX: This is a bit dirty i.e., check for substring in lendingTypes file instead -->

        <xsl:variable name="lendingTypeString" select="replace(., '(IBRD|Blend|IDA|Not classified).*', '$1')"/>
        <xsl:choose>
            <xsl:when test="document($pathToLendingTypes)/rdf:RDF/rdf:Description[skos:prefLabel/text() = $lendingTypeString]">
                <rdf:Description rdf:about="{$classification}loan-number">
                    <skos:hasTopConcept rdf:resource="{$classification}loan-number/{normalize-space(.)}"/>
                </rdf:Description>

                <rdf:Description rdf:about="{$classification}loan-number/{normalize-space(.)}">
                    <rdf:type>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="document($pathToLendingTypes)/rdf:RDF/rdf:Description[skos:prefLabel/text() = $lendingTypeString]/@rdf:about"/>
                        </xsl:attribute>
                    </rdf:type>
                    <skos:topConceptOf rdf:resource="{$classification}loan-number"/>
                    <skos:notation><xsl:value-of select="normalize-space(.)"/></skos:notation>
                </rdf:Description>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
