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
    xmlns:stats-type="http://worldbank.270a.info/classification/stats-type/">

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
                    <xsl:text>country/</xsl:text><xsl:value-of select="$country"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>basin/</xsl:text><xsl:value-of select="$basinCode"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$statstypeCode = 'mavg'
                        or $statstypeCode = 'annualavg'
                        or $statstypeCode = 'manom'
                        or $statstypeCode = 'annualanom'
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
            <xsl:variable name="statstype">
                <xsl:choose>
                    <xsl:when test="$statstypeCode = 'mavg' and $nodeName = 'domain.web.MonthlyGcmDatum'">
                        <xsl:text>month-average</xsl:text>
                    </xsl:when>
                    <xsl:when test="$statstypeCode = 'annualavg' and $nodeName = 'domain.web.AnnualGcmDatum'">
                        <xsl:text>year-average</xsl:text>
                    </xsl:when>
                    <xsl:when test="$statstypeCode = 'manom' and $nodeName = 'domain.web.MonthlyGcmDatum'">
                        <xsl:text>month-average-anomaly</xsl:text>
                    </xsl:when>
                    <xsl:when test="$statstypeCode = 'annualanom' and $nodeName = 'domain.web.AnnualGcmDatum'">
                        <xsl:text>year-average-anomaly</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
<xsl:message><xsl:text>FIXME: </xsl:text><xsl:value-of select="$nodeName"/></xsl:message>
                        <xsl:value-of select="$statstypeCode"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="fromYear" select="normalize-space(fromYear/text())"/>
            <xsl:variable name="toYear" select="normalize-space(toYear/text())"/>
            <xsl:variable name="variable" select="normalize-space(variable/text())"/>
            <xsl:variable name="gcm" select="wbldfn:safe-term(gcm/text())"/>

            <xsl:variable name="scenario">
                <xsl:if test="scenario != ''">
<!--    <xsl:message><xsl:text>name() = 'scenario'</xsl:text></xsl:message> -->
                    <xsl:text>/</xsl:text><xsl:value-of select="normalize-space(scenario/text())"/>
                </xsl:if>
            </xsl:variable>

            <xsl:variable name="resourceClimateObservation">
                <xsl:value-of select="$wbld"/><xsl:text>dataset/world-bank-climates/</xsl:text><xsl:value-of select="$areaCode"/><xsl:text>/</xsl:text><xsl:value-of select="$fromYear"/><xsl:text>-</xsl:text><xsl:value-of select="$toYear"/><xsl:text>/</xsl:text><xsl:value-of select="$statstype"/><xsl:text>/</xsl:text><xsl:value-of select="$variable"/><xsl:text>/</xsl:text><xsl:value-of select="$gcm"/><xsl:value-of select="$scenario"/>
            </xsl:variable>

            <rdf:Description rdf:about="{$resourceClimateObservation}">
                <qb:dataset rdf:resource="{$wbld}dataset/world-bank-climates/{$statstype}"/>

                <xsl:choose>
                    <xsl:when test="$countryCode != ''">
                        <sdmx-dimension:refArea rdf:resource="{$classification}country/{$country}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <sdmx-dimension:refArea rdf:resource="{$classification}basin/{$basinCode}"/>
                    </xsl:otherwise>
                </xsl:choose>

                <sdmx-dimension:refPeriod rdf:resource="http://reference.data.gov.uk/id/gregorian-interval/{$fromYear}-01-01T00:00:00/P20Y"/>

                <property:variable rdf:resource="{$classification}variable/{$variable}"/>

                <property:global-circulation-model rdf:resource="{$classification}global-circulation-model/{$gcm}"/>

                <xsl:if test="$scenario != ''">
                    <property:scenario rdf:resource="{$classification}scenario{$scenario}"/>
                </xsl:if>

                <xsl:if test="monthVals">
                    <xsl:for-each select="node()/*">
                        <xsl:choose>
                            <xsl:when test="position() = 1">
                                <property:january-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:january-average>
                            </xsl:when>
                            <xsl:when test="position() = 2">
                                <property:february-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:february-average>
                            </xsl:when>
                            <xsl:when test="position() = 3">
                                <property:march-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:march-average>
                            </xsl:when>
                            <xsl:when test="position() = 4">
                                <property:april-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:april-average>
                            </xsl:when>
                            <xsl:when test="position() = 5">
                                <property:may-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:may-average>
                            </xsl:when>
                            <xsl:when test="position() = 6">
                                <property:june-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:june-average>
                            </xsl:when>
                            <xsl:when test="position() = 7">
                                <property:july-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:july-average>
                            </xsl:when>
                            <xsl:when test="position() = 8">
                                <property:august-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:august-average>
                            </xsl:when>
                            <xsl:when test="position() = 9">
                                <property:september-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:september-average>
                            </xsl:when>
                            <xsl:when test="position() = 10">
                                <property:october-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:october-average>
                            </xsl:when>
                            <xsl:when test="position() = 11">
                                <property:november-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:november-average>
                            </xsl:when>
                            <xsl:when test="position() = 12">
                                <property:december-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="text()"/></property:december-average>
                            </xsl:when>
                            <xsl:otherwise>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="annualData">
                    <property:year-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="annualData/double/text()"/></property:year-average>
                </xsl:if>

                <property:stats-type rdf:resource="{$classification}stats-type/{$statstype}"/>
            </rdf:Description>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="climatesHistoricalObservations">
        <xsl:param name="areaCode"/>
        <xsl:param name="country"/>

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
                        <xsl:value-of select="$wbld"/><xsl:text>dataset/world-bank-climates/</xsl:text><xsl:value-of select="$areaCode"/><xsl:text>/</xsl:text><xsl:value-of select="$refPeriod"/><xsl:text>/</xsl:text><xsl:value-of select="$statstypeCode"/><xsl:text>/</xsl:text><xsl:value-of select="$variableCode"/>
                    </xsl:variable>

                    <rdf:Description rdf:about="{$resourceClimateObservation}">
                        <qb:dataset rdf:resource="{$wbld}dataset/world-bank-climates/{$statstypeCode}"/>

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

                        <property:variable rdf:resource="{$classification}variable/{$variableCode}"/>

                        <xsl:for-each select=".">
                            <xsl:choose>
                                <xsl:when test="month/text() = 0">
                                    <property:january-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:january-average>
                                </xsl:when>
                                <xsl:when test="month/text() = 1">
                                    <property:february-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:february-average>
                                </xsl:when>
                                <xsl:when test="month/text() = 2">
                                    <property:march-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:march-average>
                                </xsl:when>
                                <xsl:when test="month/text() = 3">
                                    <property:april-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:april-average>
                                </xsl:when>
                                <xsl:when test="month/text() = 4">
                                    <property:may-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:may-average>
                                </xsl:when>
                                <xsl:when test="month/text() = 5">
                                    <property:june-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:june-average>
                                </xsl:when>
                                <xsl:when test="month/text() = 6">
                                    <property:july-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:july-average>
                                </xsl:when>
                                <xsl:when test="month/text() = 7">
                                    <property:august-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:august-average>
                                </xsl:when>
                                <xsl:when test="month/text() = 8">
                                    <property:september-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:september-average>
                                </xsl:when>
                                <xsl:when test="month/text() = 9">
                                    <property:october-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:october-average>
                                </xsl:when>
                                <xsl:when test="month/text() = 10">
                                    <property:november-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:november-average>
                                </xsl:when>
                                <xsl:when test="month/text() = 11">
                                    <property:december-average rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal"><xsl:value-of select="data/text()"/></property:december-average>
                                </xsl:when>

                                <xsl:otherwise>
<xsl:message><xsl:text>FIXME month</xsl:text></xsl:message>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>

                        <property:stats-type rdf:resource="{$classification}stats-type/{$statstypeCode}"/>
                    </rdf:Description>
                </xsl:for-each>
            </xsl:when>

            <xsl:when test="$statstypeCode = 'year-average-historical' or $statstypeCode = 'decade-average-historical'">
                <xsl:for-each select="list/*">
                    <xsl:variable name="resourceClimateObservation">
                        <xsl:value-of select="$wbld"/><xsl:text>dataset/world-bank-climates/</xsl:text><xsl:value-of select="$areaCode"/><xsl:text>/</xsl:text><xsl:value-of select="year"/><xsl:text>/</xsl:text><xsl:value-of select="$statstypeCode"/><xsl:text>/</xsl:text><xsl:value-of select="$variableCode"/>
                    </xsl:variable>

                    <rdf:Description rdf:about="{$resourceClimateObservation}">
                        <qb:dataset rdf:resource="{$wbld}dataset/world-bank-climates/{$statstypeCode}"/>

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

                        <property:variable rdf:resource="{$classification}variable/{$variableCode}"/>

                        <property:stats-type rdf:resource="{$classification}stats-type/{$statstypeCode}"/>
                    </rdf:Description>
                </xsl:for-each>
            </xsl:when>

            <xsl:otherwise>
<xsl:message><xsl:text>FIXME year/decade</xsl:text></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
