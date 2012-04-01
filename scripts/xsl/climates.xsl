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
    xmlns:property="http://worldbank.270a.info/property/"
    xmlns:classification="http://worldbank.270a.info/classification/"
    xmlns:country="http://worldbank.270a.info/classification/country/"
    xmlns:global-circulation-model="http://worldbank.270a.info/classification/global-circulation-model/"
    xmlns:variable="http://worldbank.270a.info/classification/variable/"
    xmlns:scenario="http://worldbank.270a.info/classification/scenario/"
    xmlns:stats-type="http://worldbank.270a.info/classification/stats-type/"
    xmlns:world-bank-climates="http://worldbank.270a.info/dataset/world-bank-climates/"
    xmlns:intervals="http://reference.data.gov.uk/def/intervals/">

    <xsl:import href="common.xsl"/>
    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="wbapi_lang"/>
    <xsl:param name="pathToCountries"/>
    <xsl:param name="countryCode"/>
    <xsl:param name="basinCode"/>
    <xsl:param name="statstypeCode"/>
    <xsl:param name="variableCode"/>

    <xsl:variable name="wbld">http://worldbank.270a.info/</xsl:variable>
    <xsl:variable name="property">http://worldbank.270a.info/property/</xsl:variable>
    <xsl:variable name="classification">http://worldbank.270a.info/classification/</xsl:variable>
    <xsl:variable name="qb">http://purl.org/linked-data/cube#</xsl:variable>
    <xsl:variable name="world-bank-climates">http://worldbank.270a.info/dataset/world-bank-climates/</xsl:variable>

    <xsl:template match="/">
        <rdf:RDF>
            <xsl:call-template name="climatesObservations"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="climatesObservations">
        <xsl:variable name="currentDateTime" select="wbldfn:now()"/>

        <xsl:variable name="country">
            <xsl:if test="$countryCode != ''">
                <xsl:value-of select="wbldfn:ISO-3166_3-to-ISO-3166_2($countryCode)"/>
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="areaCode">
            <xsl:choose>
                <xsl:when test="$countryCode != ''">
                    <xsl:value-of select="$country"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$basinCode"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$statstypeCode = 'mavg'
                        or $statstypeCode = 'annualavg'
                        or $statstypeCode = 'manom'
                        or $statstypeCode = 'annualanom'
                        or $statstypeCode = 'mavg-ensemble'
                        or $statstypeCode = 'annualavg-ensemble'
                        or $statstypeCode = 'manom-ensemble'
                        or $statstypeCode = 'annualanom-ensemble'
                        or $statstypeCode = 'mavg-ensemble-derived'
                        or $statstypeCode = 'annualavg-ensemble-derived'
                        or $statstypeCode = 'manom-ensemble-derived'
                        or $statstypeCode = 'annualanom-ensemble-derived'
                        ">
                <xsl:call-template name="climatesRegularObservations">
                    <xsl:with-param name="areaCode" select="$areaCode"/>
                    <xsl:with-param name="country" select="$country"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$statstypeCode = 'month-average-historical'
                        or $statstypeCode = 'year-average-historical'
                        or $statstypeCode = 'decade-average-historical'
                        ">
                <xsl:call-template name="climatesHistoricalObservations">
                    <xsl:with-param name="areaCode" select="$areaCode"/>
                    <xsl:with-param name="country" select="$country"/>
                </xsl:call-template>
            </xsl:when>
<!--
            <xsl:when test="$statstypeCode = 'mavg-ensemble-derived'
                        or $statstypeCode = 'annualavg-ensemble-derived'
                        or $statstypeCode = 'manom-ensemble-derived'
                        or $statstypeCode = 'annualanom-ensemble-derived'
                        ">
                <xsl:call-template name="climatesEnsembleDerivedObservations">
                    <xsl:with-param name="areaCode" select="$areaCode"/>
                    <xsl:with-param name="country" select="$country"/>
                </xsl:call-template>
            </xsl:when>
-->
            <xsl:otherwise>
<xsl:message><xsl:text>FIXME 0</xsl:text></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="climatesRegularObservations">
        <xsl:param name="areaCode"/>
        <xsl:param name="country"/>

        <xsl:for-each select="list/*">
            <xsl:variable name="nodeName" select="name()"/>
<!--    <xsl:message><xsl:value-of select="$nodeName"/></xsl:message> -->
            <xsl:variable name="statstype" select="wbldfn:canonical-term($statstypeCode)"/>

            <xsl:variable name="fromYear">
                <xsl:if test="fromYear">
                    <xsl:value-of select="normalize-space(fromYear/text())"/>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="toYear">
                <xsl:if test="toYear">
                    <xsl:value-of select="normalize-space(toYear/text())"/>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="variable">
                <xsl:choose>
                    <xsl:when test="variable">
                        <xsl:text>/</xsl:text><xsl:value-of select="wbldfn:canonical-term(variable/text())"/>
                    </xsl:when>
                    <xsl:when test="$variableCode != ''">
                        <xsl:text>/</xsl:text><xsl:value-of select="wbldfn:canonical-term(wbldfn:safe-term($variableCode))"/>
                    </xsl:when>
                    <xsl:otherwise>
<xsl:message><xsl:text>FIXME variable</xsl:text></xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="gcm">
                <xsl:if test="gcm">
                    <xsl:text>/</xsl:text><xsl:value-of select="wbldfn:safe-term(normalize-space(gcm/text()))"/>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="scenario">
                <xsl:if test="scenario">
                    <xsl:text>/</xsl:text><xsl:value-of select="normalize-space(scenario/text())"/>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="percentile">
                <xsl:if test="percentile">
                    <xsl:text>/</xsl:text><xsl:value-of select="normalize-space(percentile/text())"/>
                </xsl:if>
            </xsl:variable>

            <xsl:if test="child::node()/name() = 'monthVals'
                        or child::node()/name() = 'annualData'
                        or child::node()/name() = 'annualVal'">
                <xsl:variable name="periodType" select="child::node()/name()"/>

                <xsl:for-each select="node()/*">
                    <xsl:variable name="month">
                        <xsl:if test="$periodType = 'monthVals'">
                            <xsl:value-of select="wbldfn:get-month(position())"/><xsl:text>/</xsl:text>
                        </xsl:if>
                    </xsl:variable>

                    <xsl:variable name="resourceClimateObservation">
                        <xsl:value-of select="$world-bank-climates"/><xsl:value-of select="$statstype"/><xsl:text>/</xsl:text><xsl:value-of select="$fromYear"/><xsl:text>-</xsl:text><xsl:value-of select="$toYear"/><xsl:text>/</xsl:text><xsl:value-of select="$month"/><xsl:value-of select="$areaCode"/><xsl:value-of select="$variable"/><xsl:value-of select="$gcm"/><xsl:value-of select="$scenario"/><xsl:value-of select="$percentile"/>
                    </xsl:variable>

                    <rdf:Description rdf:about="{$resourceClimateObservation}">
                        <qb:dataSet rdf:resource="{$world-bank-climates}{$statstype}"/>
                        <rdf:type rdf:resource="{$qb}Observation"/>

                        <xsl:choose>
                            <xsl:when test="$countryCode != ''">
                                <sdmx-dimension:refArea rdf:resource="{$classification}country/{$country}"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <sdmx-dimension:refArea rdf:resource="{$classification}basin/{$basinCode}"/>
                            </xsl:otherwise>
                        </xsl:choose>

                        <sdmx-dimension:refPeriod rdf:resource="http://reference.data.gov.uk/id/gregorian-interval/{$fromYear}-01-01T00:00:00/P20Y"/>

                        <xsl:if test="$variable != ''">
                            <property:variable rdf:resource="{$classification}variable{$variable}"/>
                        </xsl:if>

                        <xsl:if test="$gcm != ''">
                            <property:global-circulation-model rdf:resource="{$classification}global-circulation-model{$gcm}"/>
                        </xsl:if>

                        <xsl:if test="$scenario != ''">
                            <property:scenario rdf:resource="{$classification}scenario{$scenario}"/>
                        </xsl:if>

                        <xsl:if test="$percentile != ''">
                            <property:percentile rdf:resource="{$classification}percentile{$percentile}"/>
                        </xsl:if>

                        <xsl:choose>
                            <xsl:when test="$periodType = 'monthVals'">
                                <property:month-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:month-average>

                                <property:recurring-interval rdf:resource="http://reference.data.gov.uk/def/intervals/{wbldfn:get-month-from-number(position())}"/>
                            </xsl:when>
                            <xsl:when test="$periodType = 'annualData' or $periodType = 'annualVal'">
                                <property:year-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:year-average>
                            </xsl:when>

                            <xsl:otherwise>
<xsl:message><xsl:text>FIXME 2 OTHERWISE</xsl:text></xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>
                    </rdf:Description>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="climatesHistoricalObservations">
        <xsl:param name="areaCode"/>
        <xsl:param name="country"/>

        <xsl:variable name="variable" select="wbldfn:canonical-term($variableCode)"/>

        <xsl:choose>
            <xsl:when test="$statstypeCode = 'month-average-historical'">
                <xsl:for-each select="list/*">
                    <xsl:variable name="refPeriod">
                        <xsl:choose>
                            <xsl:when test="$countryCode != ''">
                                <xsl:text>1900-2009</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>1960-2009</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="resourceClimateObservation">
                        <xsl:value-of select="$world-bank-climates"/><xsl:value-of select="$statstypeCode"/><xsl:text>/</xsl:text><xsl:value-of select="$refPeriod"/><xsl:text>/</xsl:text><xsl:value-of select="wbldfn:get-month(month/text() + 1)"/><xsl:text>/</xsl:text><xsl:value-of select="$areaCode"/><xsl:text>/</xsl:text><xsl:value-of select="$variable"/>
                    </xsl:variable>

                    <rdf:Description rdf:about="{$resourceClimateObservation}">
                        <qb:dataSet rdf:resource="{$world-bank-climates}{$statstypeCode}"/>
                        <rdf:type rdf:resource="{$qb}Observation"/>

                        <xsl:choose>
                            <xsl:when test="$countryCode != ''">
                                <sdmx-dimension:refArea rdf:resource="{$classification}country/{$country}"/>
                                <sdmx-dimension:refPeriod rdf:resource="http://reference.data.gov.uk/id/gregorian-interval/1901-01-01T00:00:00/P109Y"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <sdmx-dimension:refArea rdf:resource="{$classification}basin/{$basinCode}"/>
                                <sdmx-dimension:refPeriod rdf:resource="http://reference.data.gov.uk/id/gregorian-interval/1960-01-01T00:00:00/P50Y"/>
                            </xsl:otherwise>
                        </xsl:choose>

                        <property:variable rdf:resource="{$classification}variable/{$variable}"/>

                        <xsl:for-each select=".">
                            <property:month-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:month-average>

                            <property:recurring-interval rdf:resource="http://reference.data.gov.uk/def/intervals/{wbldfn:get-month-from-number(month/text() + 1)}"/>
                        </xsl:for-each>
                    </rdf:Description>
                </xsl:for-each>
            </xsl:when>

            <xsl:when test="$statstypeCode = 'year-average-historical' or $statstypeCode = 'decade-average-historical'">
                <xsl:for-each select="list/*">
                    <xsl:variable name="resourceClimateObservation">
                        <xsl:value-of select="$world-bank-climates"/><xsl:value-of select="$statstypeCode"/><xsl:text>/</xsl:text><xsl:value-of select="normalize-space(year/text())"/><xsl:text>/</xsl:text><xsl:value-of select="$areaCode"/><xsl:text>/</xsl:text><xsl:value-of select="$variable"/>
                    </xsl:variable>

                    <rdf:Description rdf:about="{$resourceClimateObservation}">
                        <qb:dataSet rdf:resource="{$world-bank-climates}{$statstypeCode}"/>
                        <rdf:type rdf:resource="{$qb}Observation"/>

                        <xsl:choose>
                            <xsl:when test="$countryCode != ''">
                                <sdmx-dimension:refArea rdf:resource="{$classification}country/{$country}"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <sdmx-dimension:refArea rdf:resource="{$classification}basin/{$basinCode}"/>
                            </xsl:otherwise>
                        </xsl:choose>

                        <xsl:choose>
                            <xsl:when test="$statstypeCode = 'year-average-historical'">
                                <sdmx-dimension:refPeriod rdf:resource="http://reference.data.gov.uk/id/year/{year/text()}"/>
                                <property:year-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:year-average>
                            </xsl:when>
                            <xsl:otherwise>
                                <sdmx-dimension:refPeriod rdf:resource="http://reference.data.gov.uk/id/gregorian-interval/{year/text()}-01-01T00:00:00/P10Y"/>
                                <property:decade-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:decade-average>
                            </xsl:otherwise>
                        </xsl:choose>

                        <property:variable rdf:resource="{$classification}variable/{$variable}"/>
                    </rdf:Description>
                </xsl:for-each>
            </xsl:when>

            <xsl:otherwise>
<xsl:message><xsl:text>FIXME year/decade</xsl:text></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
