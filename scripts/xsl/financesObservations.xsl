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

    <xsl:variable name="currentDateTime" select="wbldfn:now()"/>
    <xsl:variable name="wbld">http://worldbank.270a.info/</xsl:variable>
    <xsl:variable name="property">http://worldbank.270a.info/property/</xsl:variable>
    <xsl:variable name="classification">http://worldbank.270a.info/classification/</xsl:variable>
    <xsl:variable name="qb">http://purl.org/linked-data/cube#</xsl:variable>
    <xsl:variable name="currencyCodeUSD">USD</xsl:variable>

    <xsl:template match="/">
        <rdf:RDF>
        <xsl:call-template name="financesObservations"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="financesObservations">
        <xsl:for-each select="response/row/row">
            <xsl:variable name="wbldf_view">
                <xsl:value-of select="replace(@_address, 'http://finances.worldbank.org/views/(_)?([^/]*).*', '$2')"/>
            </xsl:variable>

<!-- XXX: Either I have to add this date to the observeration URI or not. Some observations don't have a date. Also, what about other the other dimensions? Perhaps it can do without because there is a unique id per observation any way.

Perhaps gather the list of dimensions for each observation and add them here .. use document()
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

            <xsl:choose>
                <xsl:when test="$wbldf_view = '536v-dxib'">
                    <xsl:variable name="datasetCase">
                        <xsl:text>a</xsl:text>
                    </xsl:variable>
                    <xsl:variable name="ignoreProperty">
                        <xsl:text>receipt-amount</xsl:text>
                    </xsl:variable>
                    <xsl:call-template name="createDescriptions">
                        <xsl:with-param name="wbldf_view" select="$wbldf_view"/>
                        <xsl:with-param name="datasetCase" select="$datasetCase"/>
                        <xsl:with-param name="ignoreProperty" select="$ignoreProperty"/>
                    </xsl:call-template>

                    <xsl:variable name="datasetCase">
                        <xsl:text>b</xsl:text>
                    </xsl:variable>
                    <xsl:variable name="ignoreProperty">
                        <xsl:text>amount-in-usd</xsl:text>
                    </xsl:variable>
                    <xsl:call-template name="createDescriptions">
                        <xsl:with-param name="wbldf_view" select="$wbldf_view"/>
                        <xsl:with-param name="datasetCase" select="$datasetCase"/>
                        <xsl:with-param name="ignoreProperty" select="$ignoreProperty"/>
                    </xsl:call-template>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:call-template name="createDescriptions">
                        <xsl:with-param name="wbldf_view" select="$wbldf_view"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="createDescriptions">
        <xsl:param name="wbldf_view"/>
        <xsl:param name="datasetCase"/>
        <xsl:param name="ignoreProperty"/>

        <xsl:variable name="wbldf_view">
            <xsl:choose>
                <xsl:when test="$datasetCase = ''">
                    <xsl:value-of select="$wbldf_view"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$wbldf_view"/><xsl:text>/</xsl:text><xsl:value-of select="$datasetCase"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <rdf:Description rdf:about="{$wbld}dataset/world-bank-finances/{$wbldf_view}/{@_id}">
            <rdf:type rdf:resource="{$qb}Observation"/>
            <qb:dataSet rdf:resource="{$wbld}dataset/world-bank-finances/{$wbldf_view}"/>
            <xsl:if test="@_address">
                <dcterms:source rdf:resource="{@_address}.xml"/>
            </xsl:if>

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

                <xsl:if test="wbldfn:usable-term($nodeName) and $nodeName != 'currency'">
                    <xsl:if test="$nodeName != $ignoreProperty">
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
                            <xsl:with-param name="wbldf_view" select="$wbldf_view"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>

<!--
TODO
536v-dxib needs a single currency code per observation (there are two types of observations and come with different values)

ebmi-69yj has service-charge-rate (measure) and a bunch of amounts (measure). Need to split these observations into two, like in 536v-dxib

jeqz-f7mn has equity-to-loans-ratio (measure) .. similar to ebmi-69yj

rcx4-r7xj has shares, percentage-of-total-shares, number-of-votes, percentage-of-total-votes (different measures), total-amounts, amounts-paid-in, amounts-subject-to-call (measures)

sfv5-tf7p has interest-rate (measure) and a bunch of amounts (measure)

tdwh-3krx has service-charge-rate (measure) and a bunch of amounts (measure)

v84d-dq44 has number-of-votes, percentage-of-total-votes (measure), and subscriptions-and-contributions-commited (measure)

zucq-nrc3 has interest-rate (measure) and a bunch of amounts (measure)
-->

            <xsl:choose>
                <xsl:when test="$wbldf_view = '4i57-byta'
                            or $wbldf_view = '9pv4-rtrm'
                            or $wbldf_view = 'ax5s-vav5'
                            or $wbldf_view = 'csrh-vv7b'
                            or $wbldf_view = 'e8yz-96c6'
                            or $wbldf_view = 'eycy-ub35'
                            or $wbldf_view = 'fie8-6fxn'
                            or $wbldf_view = 'gprm-cvxz'
                            or $wbldf_view = 'h4s8-nwev'
                            or $wbldf_view = 'h9ga-h5eb'
                            or $wbldf_view = 'hcqu-nmwb'
                            or $wbldf_view = 'i7za-uwi5'
                            or $wbldf_view = 'iww5-3sst'
                            or $wbldf_view = 'kmwd-f4rk'
                            or $wbldf_view = 'm54j-ersw'
                            or $wbldf_view = 'nh5z-5qch'
                            or $wbldf_view = 'p65j-3upu'
                            or $wbldf_view = 'pyda-ktbg'
                            or $wbldf_view = 'ri54-wt6e'
                            or $wbldf_view = 's3ey-mkx3'
                            or $wbldf_view = 'wphw-pasx'
                            or $wbldf_view = 'xs8h-cwh5'
                            or $wbldf_view = 'zyqx-8e4a'

                            or $wbldf_view = 'jeqz-f7mn'
                            or $wbldf_view = 'rcx4-r7xj'
                            or $wbldf_view = 'sfv5-tf7p'
                            or $wbldf_view = 'tdwh-3krx'
                            or $wbldf_view = 'v84d-dq44'
                            or $wbldf_view = 'zucq-nrc3'
                            ">
                    <xsl:call-template name="property-currency">
                        <xsl:with-param name="currencyCode" select="$currencyCodeUSD"/>
                    </xsl:call-template>
                </xsl:when>

                <xsl:otherwise>
<!--
<xsl:message><xsl:text>FIXME: </xsl:text><xsl:value-of select="$wbldf_view"/></xsl:message>
-->
                </xsl:otherwise>
            </xsl:choose>
        </rdf:Description>
    </xsl:template>


    <xsl:template name="nodeProperty">
        <xsl:param name="nodeName"/>
        <xsl:param name="datasetName"/>
        <xsl:param name="wbldf_view"/>

        <xsl:choose>
            <xsl:when test="$nodeName = 'project'">
                <xsl:element name="property:{$nodeName}">
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$classification"/><xsl:text>project/</xsl:text><xsl:value-of select="normalize-space(./text())"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>

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
                    <xsl:call-template name="datatype-dateTime"/>
                    <xsl:value-of select="normalize-space(./text())"/><xsl:text>Z</xsl:text>
                </xsl:element>
            </xsl:when>

            <xsl:when test="$nodeName = 'fiscal-year'
                            or $nodeName = 'calendar-year'
                            or $nodeName = 'fiscal-year-of-receipt'">
                <xsl:element name="property:{$datasetName}{$nodeName}">
                    <xsl:call-template name="resource-refperiod">
                        <xsl:with-param name="date" select="normalize-space(./text())"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:when>

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

            <xsl:when test="wbldfn:money-amount($nodeName)">
                <xsl:element name="property:{$datasetName}{$nodeName}">
                    <xsl:call-template name="datatype-xsd-decimal"/>
                    <xsl:value-of select="replace(normalize-space(./text()), '\$', '')"/>
                </xsl:element>

                <xsl:if test="$wbldf_view = '536v-dxib/a'
                            or $wbldf_view = '536v-dxib/b'
                            or $wbldf_view = 'ebmi-69yj'
                            ">
                    <xsl:variable name="currencyCode">
                        <xsl:choose>
                            <xsl:when test="../receipt_currency/text() != '' and $nodeName != 'amount-in-usd'">
                                <xsl:value-of select="normalize-space(../receipt_currency/text())"/>
                            </xsl:when>

                            <xsl:when test="../currency_of_commitment/text() != '' and $nodeName != 'amount-in-usd'">
                                <xsl:value-of select="normalize-space(../currency_of_commitment/text())"/>
                            </xsl:when>

                            <xsl:otherwise>
                                <xsl:value-of select="$currencyCodeUSD"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:call-template name="property-currency">
                        <xsl:with-param name="currencyCode" select="$currencyCode"/>
                    </xsl:call-template>
                </xsl:if>
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
                               <xsl:value-of select="$classification"/><xsl:text>loan-number/</xsl:text><xsl:value-of select="normalize-space(./text())"/>
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
</xsl:stylesheet>
