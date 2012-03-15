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
    xmlns:sdmx-code="http://purl.org/linked-data/sdmx/2009/code#"
    xmlns:wb="http://www.worldbank.org"
    xmlns:wbld="http://worldbank.270a.info/"
    xmlns:property="http://worldbank.270a.info/property/"
    xmlns:classification="http://worldbank.270a.info/classification/">

    <xsl:import href="common.xsl"/>
    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="wbapi_lang"/>
    <xsl:param name="pathToCountries"/>
    <xsl:param name="pathToLendingTypes"/>
    <xsl:param name="pathToCurrencies"/>
    <xsl:param name="pathToRegionsExtra"/>
    <xsl:param name="pathToMeta"/>

    <xsl:variable name="wbld">http://worldbank.270a.info/</xsl:variable>
    <xsl:variable name="property">http://worldbank.270a.info/property/</xsl:variable>
    <xsl:variable name="classification">http://worldbank.270a.info/classification/</xsl:variable>
    <xsl:variable name="qb">http://purl.org/linked-data/cube#</xsl:variable>

    <xsl:template match="/">
        <rdf:RDF>
        <xsl:call-template name="financesObservations"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="financesObservations">
        <xsl:variable name="currentDateTime" select="wbldfn:now()"/>

        <xsl:for-each select="response/row/row">
            <xsl:variable name="wbldf_view">
                <xsl:value-of select="replace(@_address, 'http://finances.worldbank.org/views/(_)?([^/]*).*', '$2')"/>
            </xsl:variable>

<!-- XXX: Either I have to add this date to the observeration URI or not. Some observations don't have a date. Also, what about other the other dimensions? Perhaps it can do without because there is a unique id per observation any way.
            <xsl:variable name="observationYear">
                <xsl:choose>
                    <xsl:when test="child::calendar_year">
                        <xsl:text>;</xsl:text><xsl:value-of select="normalize-space(child::calendar_year/text())"/>
                    </xsl:when>
                    <xsl:when test="child::fiscal_year">
                        <xsl:text>;</xsl:text><xsl:value-of select="replace(normalize-space(child::fiscal_year/text()), 'FY([0-9]{2})', '20$1')"/>
                    </xsl:when>
                    <xsl:when test="child::end_of_period">
                        <xsl:text>;</xsl:text><xsl:value-of select="replace(normalize-space(child::end_of_period/text()))"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
-->

            <rdf:Description rdf:about="{$wbld}dataset/world-bank-finances/{$wbldf_view}#{@_id}">
                <rdf:type rdf:resource="http://purl.org/linked-data/cube#Observation"/>
                <qb:dataSet rdf:resource="{$wbld}dataset/world-bank-finances/{$wbldf_view}"/>

                <!-- XXX: _uuid available only in XML format. RDF doesn't have it 
                          Alternative:
                            <dcterms:identifier rdf:resource="urn:uuid:{@_uuid}"/>
                            <dcterms:identifier><xsl:value-of select="@_uuid"/></dcterms:identifier>
                          However, the it is not obvious what the literal is without datatype.
                          Either find a datatype for uuid, or find an uuid property out there.
                -->
                <!-- <property:uuid><xsl:value-of select="@_uuid"/></property:uuid> -->

                <!-- XXX: Not critical as this is just a row number in the table -->
<!--                <property:view-row-id><xsl:value-of select="@_id"/></property:view-row-id>-->

                <xsl:for-each select="node()">
                    <xsl:variable name="nodeName" select="wbldfn:canonical-term(wbldfn:safe-term(name()))"/>
                    
                    <xsl:if test="wbldfn:usable-term($nodeName)">
                        <xsl:variable name="financeDataset">
                            <xsl:text>http://worldbank.270a.info/dataset/world-bank-finances/</xsl:text><xsl:value-of select="$wbldf_view"/>
                        </xsl:variable>

                        <xsl:variable name="datasetName">
                            <xsl:value-of select="document($pathToMeta)/rdf:RDF/rdf:Description[@rdf:about = $financeDataset]/rdfs:label"/>
                        </xsl:variable>

                        <xsl:variable name="datasetName">
                            <xsl:if test="wbldfn:prepend-dataset($nodeName)">
                                <xsl:value-of select="wbldfn:safe-term($datasetName)"/><xsl:text>-</xsl:text>
                            </xsl:if>
                        </xsl:variable>

                        <xsl:call-template name="nodeProperty">
                            <xsl:with-param name="nodeName" select="$nodeName"/>
                            <xsl:with-param name="datasetName" select="$datasetName"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:for-each>
            </rdf:Description>
        </xsl:for-each>

        <xsl:call-template name="loan-number"/>
    </xsl:template>

    <xsl:template name="nodeProperty">
        <xsl:param name="nodeName"/>
        <xsl:param name="datasetName"/>

        <xsl:choose>
            <xsl:when test="$nodeName = 'project'">
                <xsl:element name="property:{$nodeName}">
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$wbld"/><xsl:text>project/</xsl:text><xsl:value-of select="normalize-space(./text())"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>

            <!--
            <xsl:when test="$nodeName = 'project-name'">
                <xsl:element name="property:{$datasetName}{$nodeName}">
                    <xsl:value-of select="./text()"/>
                </xsl:element>
            </xsl:when>
            -->

            <!-- These match up with ISO codes -->
            <xsl:when test="$nodeName = 'beneficiary'
                        or $nodeName = 'country'
                        or $nodeName = 'donor'
                        or $nodeName = 'guarantor'
                        or $nodeName = 'member'
                        ">
                <xsl:variable name="countryString" select="normalize-space(./text())"/>

                <xsl:choose>
                    <xsl:when test="$countryString = ''">
                        <xsl:element name="property:{$datasetName}{$nodeName}"/>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="string-length($countryString) = 2">
                                <xsl:element name="property:{$datasetName}{$nodeName}">
                                    <xsl:attribute name="rdf:resource">
                                        <xsl:value-of select="$classification"/><xsl:text>country/</xsl:text><xsl:value-of select="$countryString"/>
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:when>

                            <xsl:otherwise>
                                <xsl:choose>
                                    <!--
                                        TODO: Some of the countries don't match e.g., "Yemen, Rep." in countries.xml and "Yemen, People's Democratic Republic of" or "Yemen, Republic of" in ax5s-vav5.xml.
                                    -->
                                    <xsl:when test="document($pathToCountries)/wb:countries/wb:country[wb:name/text() = $countryString]">
                                        <xsl:element name="property:{$datasetName}{$nodeName}">
                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="$classification"/><xsl:text>country/</xsl:text><xsl:value-of select="document($pathToCountries)/wb:countries/wb:country[wb:name/text() = $countryString]/wb:iso2Code/normalize-space(text())"/>
                                            </xsl:attribute>
                                        </xsl:element>
                                    </xsl:when>

                                    <xsl:otherwise>
                                        <xsl:element name="property:{$datasetName}{$nodeName}">
                                            <xsl:value-of select="$countryString"/>
                                        </xsl:element>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="$nodeName = 'region'">
                <xsl:variable name="regionString" select="./text()"/>

                <xsl:element name="property:{$datasetName}{$nodeName}">
                    <xsl:choose>
                        <xsl:when test="document($pathToRegionsExtra)/rdf:RDF/rdf:Description[skos:altLabel/text() = $regionString]">
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of select="document($pathToRegionsExtra)/rdf:RDF/rdf:Description[skos:altLabel/text() = $regionString]/@rdf:about"/>
                            </xsl:attribute>
                        </xsl:when>

                        <xsl:otherwise>
                            <xsl:value-of select="./text()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                 </xsl:element>
            </xsl:when>

            <xsl:when test="$nodeName = 'category'">
                <xsl:element name="property:{$datasetName}{$nodeName}">
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$classification"/><xsl:text>category/</xsl:text><xsl:value-of select="wbldfn:safe-term(./text())"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>

            <xsl:when test="$nodeName = 'agreement-signing-date'
                            or $nodeName = 'as-of-date'
                            or $nodeName = 'board-approval-date'
                            or $nodeName = 'closed-date-most-recent'
                            or $nodeName = 'effective-date-most-recent'
                            or $nodeName = 'end-of-period'
                            or $nodeName = 'first-repayment-date'
                            or $nodeName = 'grant-agreement-date'
                            or $nodeName = 'last-disbursement-date'
                            or $nodeName = 'last-repayment-date'
                            or $nodeName = 'period-end-date'
                            ">
                <xsl:element name="property:{$datasetName}{$nodeName}">
                    <xsl:call-template name="datatype-date"/>
                    <xsl:value-of select="normalize-space(./text())"/>
                </xsl:element>
            </xsl:when>

            <!-- XXX: Perhaps the next two conditions should use sdmx:refPeriod -->
            <xsl:when test="$nodeName = 'fiscal-year'
                            or $nodeName = 'calendar-year'
                            or $nodeName = 'fiscal-year-of-receipt'">
                <xsl:element name="property:{$datasetName}{$nodeName}">
                    <xsl:call-template name="resource-refperiod">
                        <xsl:with-param name="date" select="normalize-space(./text())"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:when>

            <!-- TODO: Approval Quarter, Receipt Quarter, Transfer Quarter-->
            <xsl:when test="$nodeName = 'approval-quarter'
                            or $nodeName = 'receipt-quarter'
                            or $nodeName = 'transfer-quarter'">
                <xsl:variable name="quarter" select="wbldfn:get-quarter(./text())"/>

                <xsl:element name="property:{$datasetName}{$nodeName}">
                    <xsl:call-template name="resource-refperiod">
                        <xsl:with-param name="date">
                            <xsl:value-of select="normalize-space(../calendar_year)"/><xsl:value-of select="$quarter"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:when>

            <!-- TODO: $nodeName date, end_date are UNIX timestamps, convert them -->

            <xsl:when test="$nodeName = 'line-item'">
                <xsl:element name="property:{$datasetName}{$nodeName}">
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$classification"/><xsl:text>line-item/</xsl:text><xsl:value-of select="wbldfn:safe-term(./text())"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>

            <!-- XXX: A bit unsure about this. Reconsider property and find a different datatype? -->
            <!-- TODO: I could maybe use the currencies.rdf here. Depending on how it is defined -->
            <xsl:when test="wbldfn:money-amount($nodeName)">
                <xsl:element name="property:{$datasetName}{$nodeName}">
                    <xsl:call-template name="datatype-dbo-usd"/>
                    <xsl:value-of select="./text()"/>
                </xsl:element>
            </xsl:when>

            <xsl:when test="$nodeName = 'currency-of-commitment'
                            or $nodeName = 'receipt-currency'">
                <xsl:variable name="currency" select="normalize-space(./text())"/>

                <xsl:choose>
                    <xsl:when test="document($pathToCurrencies)/rdf:RDF/rdf:Description[skos:notation/text() = $currency]/@rdf:about">
                        <!-- XXX: I prefer to use 'currency' instead of 'currency-of-commitment' but that would mean that I have to change the property name in the dictionary wc6g-9zmq -->
                        <xsl:element name="property:{$nodeName}">
                            <xsl:attribute name="rdf:resource">
                               <xsl:value-of select="$classification"/><xsl:text>currency/</xsl:text><xsl:value-of select="$currency"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:element name="property:{$nodeName}">
                            <xsl:value-of select="./text()"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="$nodeName = 'description'">
                <xsl:element name="property:{$datasetName}{$nodeName}">
                    <xsl:value-of select="./text()"/>
                </xsl:element>
            </xsl:when>

            <xsl:when test="$nodeName = 'loan-number'
                            or $nodeName = 'credit-number'">
                <!-- XXX: This is a bit dirty i.e., check for substring in lendingTypes file instead -->
                <xsl:variable name="lendingTypeString" select="replace(./text(), '(IBRD|Blend|IDA|Not classified).*', '$1')"/>
                <xsl:choose>
                    <xsl:when test="document($pathToLendingTypes)/rdf:RDF/rdf:Description[skos:prefLabel/text() = $lendingTypeString]">
                        <xsl:element name="property:{$nodeName}">
                            <xsl:attribute name="rdf:resource">
                               <xsl:value-of select="$wbld"/><xsl:text>loan-number/</xsl:text><xsl:value-of select="normalize-space(./text())"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:element name="property:{$nodeName}">
                            <xsl:value-of select="./text()"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="$nodeName = 'loan-status'
                            or $nodeName = 'credit-status'">
                <xsl:variable name="loanStatus" select="lower-case(normalize-space(./text()))"/>
                <property:loan-status rdf:resource="{$classification}{$nodeName}/{$loanStatus}"/>
            </xsl:when>

            <xsl:when test="$nodeName = 'loan-type'">
                <xsl:variable name="loanType" select="replace(lower-case(normalize-space(./text())), '\s+', '-')"/>
                <property:loan-type rdf:resource="{$classification}{$nodeName}/{$loanType}"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:element name="property:{$datasetName}{$nodeName}">
                    <xsl:value-of select="./text()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="loan-number">
        <!-- XXX: This is a bit dirty i.e., check for substring in lendingTypes file instead -->
        <xsl:for-each select="distinct-values(/response/row/row/loan_number/text())">
            <xsl:variable name="lendingTypeString" select="replace(., '(IBRD|Blend|IDA|Not classified).*', '$1')"/>
            <xsl:choose>
                <xsl:when test="document($pathToLendingTypes)/rdf:RDF/rdf:Description[skos:prefLabel/text() = $lendingTypeString]">
                    <rdf:Description rdf:about="{$wbld}loan-number/{normalize-space(.)}">
                        <rdf:type>
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of select="document($pathToLendingTypes)/rdf:RDF/rdf:Description[skos:prefLabel/text() = $lendingTypeString]/@rdf:about"/>
                            </xsl:attribute>
                        </rdf:type>
                    </rdf:Description>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
