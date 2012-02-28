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
        <xsl:variable name="currentDateTime" select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>

        <!-- TODO Add provenance data -->

        <xsl:for-each select="response/row/row">
            <xsl:variable name="wbldf_view">
                <xsl:value-of select="replace(@_address, 'http://finances.worldbank.org/views/(_)?([^/]*).*', '$2')"/>
            </xsl:variable>

            <!-- FIXME -->
            <xsl:variable name="observationYear">
                <xsl:choose>
                    <xsl:when test="child::calendar_year">
                        <xsl:text>;</xsl:text><xsl:value-of select="normalize-space(child::calendar_year/text())"/>
                    </xsl:when>
                    <xsl:when test="child::fiscal_year">
                        <xsl:text>;</xsl:text><xsl:value-of select="replace(normalize-space(child::fiscal_year/text()), 'FY([0-9]{2})', '20$1')"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <!-- TODO: Find more dimension values for the observation URI -->
            <rdf:Description rdf:about="{$wbld}dataset/world-bank-finances/{$wbldf_view}#{@_id}{$observationYear}">
                <rdf:type rdf:resource="http://purl.org/linked-data/cube#Observation"/>
                <qb:dataSet rdf:resource="{$wbld}dataset/world-bank-finances/{$wbldf_view}"/>

                <!-- XXX: _uuid available only in XML format. RDF doesn't have it 
                          Alternative:
                            <dcterms:identifier rdf:resource="urn:uuid:{@_uuid}"/>
                            <dcterms:identifier><xsl:value-of select="@_uuid"/></dcterms:identifier>
                          However, the it is not obvious what the literal is without datatype.
                          Either find a datatype for uuid, or find an uuid property out there.
                -->
                <property:uuid><xsl:value-of select="@_uuid"/></property:uuid>

                <!-- XXX: Not critical as this is just a row number in the table -->
                <property:view-row-id><xsl:value-of select="@_id"/></property:view-row-id>

                <xsl:for-each select="node()">
                    <xsl:variable name="financeDataset">
                        <xsl:text>http://worldbank.270a.info/dataset/world-bank-finances/</xsl:text><xsl:value-of select="$wbldf_view"/>
                    </xsl:variable>

                    <xsl:variable name="datasetName">
                        <xsl:value-of select="document($pathToMeta)/rdf:RDF/rdf:Description[@rdf:about = $financeDataset]/rdfs:label"/>
                    </xsl:variable>

                    <xsl:variable name="datasetName">
                        <xsl:if test="$datasetName != ''">
                            <xsl:value-of select="replace(replace(lower-case(encode-for-uri(replace(normalize-space($datasetName), ' - ', '-'))), '%20|%2f', '-'), '%27|%28|%29|%24|%2c', '')"/><xsl:text>-</xsl:text>
                        </xsl:if>
                    </xsl:variable>

                    <xsl:call-template name="nodeProperty">
                        <xsl:with-param name="nodeName" select="name()"/>
                        <xsl:with-param name="datasetName" select="$datasetName"/>
                    </xsl:call-template>
                </xsl:for-each>
            </rdf:Description>
        </xsl:for-each>

        <xsl:call-template name="loan-number"/>
    </xsl:template>

    <xsl:template name="nodeProperty">
        <xsl:param name="nodeName"/>
        <xsl:param name="datasetName"/>

        <xsl:choose>
            <!-- TODO: I'm not sure about these duplicates. Best practice is..? 
                Move some of them out into meta.ttl e.g., sdmx-dimension:refPeriod
            -->
            <xsl:when test="$nodeName = 'project_id'">
                <xsl:element name="property:project-id">
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$wbld"/><xsl:text>project/</xsl:text><xsl:value-of select="normalize-space(./text())"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>

            <xsl:when test="$nodeName = 'project_name'
                            or $nodeName = 'project_name_'">
                <xsl:element name="property:{$datasetName}project-name">
                    <xsl:value-of select="./text()"/>
                </xsl:element>
            </xsl:when>

            <!-- These match up with ISO codes -->
            <xsl:when test="$nodeName = 'country_code'">
                <xsl:choose>
                    <xsl:when test="./text() = ''">
                        <xsl:element name="property:{$datasetName}country-code"/>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:element name="sdmx-dimension:refArea">
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of select="$classification"/><xsl:text>country/</xsl:text><xsl:value-of select="normalize-space(./text())"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="$nodeName = 'guarantor_country_code'">
                <xsl:choose>
                    <xsl:when test="./text() = ''">
                        <xsl:element name="property:{$datasetName}guarantor-country-code"/>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:element name="property:{$datasetName}guarantor-country-code">
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of select="$classification"/><xsl:text>country/</xsl:text><xsl:value-of select="normalize-space(./text())"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <!--
                TODO: Some of the countries don't match e.g., "Yemen, Rep." in countries.xml and "Yemen, People's Democratic Republic of" or "Yemen, Republic of" in ax5s-vav5.xml.
                XXX: Currently using sdmx-dimension:refArea "Yemen, Republic of". Could use property:country_beneficiary "Yemen, Republic of". Not sure about it right now.
            -->
            <xsl:when test="$nodeName = 'country'">
                <xsl:variable name="countryString" select="./text()"/>

                <xsl:element name="sdmx-dimension:refArea">
                    <xsl:choose>
                        <xsl:when test="document($pathToCountries)/wb:countries/wb:country[wb:name/text() = $countryString]">
                            <xsl:attribute name="rdf:resource">
                                <xsl:value-of select="$classification"/><xsl:text>country/</xsl:text><xsl:value-of select="document($pathToCountries)/wb:countries/wb:country[wb:name/text() = $countryString]/wb:iso2Code/normalize-space(text())"/>
                            </xsl:attribute>
                        </xsl:when>

                        <xsl:otherwise>
                            <xsl:value-of select="./text()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                 </xsl:element>
            </xsl:when>

            <xsl:when test="$nodeName = 'country_beneficiary'
                            or $nodeName = 'donor_name'
                            or $nodeName = 'guarantor'
                            or $nodeName = 'member'
                            or $nodeName = 'member_country'">
                <xsl:variable name="countryString" select="./text()"/>

                <xsl:element name="property:{$datasetName}{replace($nodeName, '_', '-')}">
                    <xsl:choose>
                        <xsl:when test="document($pathToCountries)/wb:countries/wb:country[wb:name/text() = $countryString]">
                            <xsl:attribute name="rdf:resource">

                                <xsl:value-of select="$classification"/><xsl:text>country/</xsl:text><xsl:value-of select="document($pathToCountries)/wb:countries/wb:country[wb:name/text() = $countryString]/wb:iso2Code/normalize-space(text())"/>
                            </xsl:attribute>
                        </xsl:when>

                        <xsl:otherwise>
                            <xsl:value-of select="./text()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                 </xsl:element>
            </xsl:when>

            <xsl:when test="$nodeName = 'region'">
                <xsl:variable name="regionString" select="./text()"/>

                <xsl:element name="property:{$datasetName}region">
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

            <xsl:when test="$nodeName = 'category'
                            or $nodeName = 'category_'">
                <xsl:element name="property:{$datasetName}category">
                    <xsl:attribute name="rdf:resource">
                        <!-- XXX -->
                        <xsl:value-of select="$classification"/><xsl:text>category/</xsl:text><xsl:value-of select="replace(replace(lower-case(encode-for-uri(replace(normalize-space(./text()), ' - ', '-'))), '%20|%2f', '-'), '%27|%28|%29|%24|%2c', '')"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>

            <xsl:when test="$nodeName = 'agreement_signing_date'
                            or $nodeName = 'as_of_date'
                            or $nodeName = 'board_approval_date'
                            or $nodeName = 'closed_date_most_recent_'
                            or $nodeName = 'effective_date_most_recent_'
                            or $nodeName = 'end_of_period'
                            or $nodeName = 'first_repayment_date'
                            or $nodeName = 'last_repayment_date'
                            or $nodeName = 'last_disbursement_date'
                            or $nodeName = 'period_end_date'">
                <xsl:variable name="term" select="replace(replace(normalize-space($nodeName), '_', '-'), '-$', '')"/>
                <xsl:element name="property:{$datasetName}{$term}">
                    <xsl:call-template name="datatype-date"/>
                    <xsl:value-of select="normalize-space(./text())"/>
                </xsl:element>
            </xsl:when>

            <!-- XXX: Perhaps the next two conditions should use sdmx:refPeriod -->
            <xsl:when test="$nodeName = 'fiscal_year'
                            or $nodeName = 'calendar_year'">
                <xsl:variable name="term" select="replace(replace(normalize-space($nodeName), '_', '-'), '-$', '')"/>
                <xsl:element name="property:{$datasetName}{$term}">
                    <xsl:call-template name="resource-refperiod">
                        <xsl:with-param name="date" select="normalize-space(./text())"/>
                    </xsl:call-template>
                </xsl:element>
            </xsl:when>

            <!-- TODO: Approval Quarter, Receipt Quarter, Transfer Quarter-->
            <xsl:when test="$nodeName = 'approval_quarter'
                            or $nodeName = 'receipt_quarter'
                            or $nodeName = 'transfer_quarter'">
                <xsl:variable name="term" select="replace(replace(normalize-space($nodeName), '_', '-'), '-$', '')"/>

                <xsl:variable name="quarter">
                    <xsl:choose>
                        <xsl:when test="lower-case(normalize-space(./text())) = 'jan-mar'">
                            <xsl:text>Q1</xsl:text>
                        </xsl:when>
                        <xsl:when test="lower-case(normalize-space(./text())) = 'apr-jun'">
                            <xsl:text>Q2</xsl:text>
                        </xsl:when>
                        <xsl:when test="lower-case(normalize-space(./text())) = 'jul-sep'">
                            <xsl:text>Q3</xsl:text>
                        </xsl:when>
                        <xsl:when test="lower-case(normalize-space(./text())) = 'oct-dec'">
                            <xsl:text>Q4</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text></xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:element name="property:{$datasetName}{$term}">
                    <xsl:call-template name="resource-refperiod">
                        <xsl:with-param name="date">
                            <xsl:value-of select="normalize-space(../calendar_year)"/><xsl:value-of select="$quarter"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:when>

            <!-- TODO: $nodeName date, end_date are UNIX timestamps, convert them -->

            <xsl:when test="$nodeName = 'line_item'">
                <xsl:element name="property:{$datasetName}line-item">
                    <xsl:attribute name="rdf:resource">
                        <xsl:value-of select="$classification"/><xsl:text>linte-item/</xsl:text><xsl:value-of select="replace(replace(lower-case(encode-for-uri(replace(normalize-space(./text()), ' - ', '-'))), '%20|%2f', '-'), '%27|%28|%29|%24|%2c', '')"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>

            <!-- XXX: A bit unsure about this. Reconsider property and find a different datatype? -->
            <!-- TODO: I could maybe use the currencies.rdf here. Depending on how it is defined -->
            <xsl:when test="$nodeName = 'amount_in_usd'
                        or $nodeName = 'amount_us_millions'
                        or $nodeName = 'commitments_total_us_millions'
                        or $nodeName = 'credits_outstanding_us_millions_'
                        or $nodeName = 'development_grant_expenses_us_millions'
                        or $nodeName = 'disbursed_amount'
                        or $nodeName = 'due_to_ibrd'
                        or $nodeName = 'gross_disbursements_total_us_millions'
                        or $nodeName = 'gross-disbursements-development-policy-lending-us-millions'
                        or $nodeName = 'net_disbursements_us_millions'
                        or $nodeName = 'operating_income_us_millions'
                        or $nodeName = 'original_principal_amount'
                        or $nodeName = 'principal_repayments_including_prepayments_us_millions'
                        or $nodeName = 'repaid_to_ibrd'
                        or $nodeName = 'repaid_to_ida'
                        or $nodeName = 'subscriptions_and_contributions_commited_us_millions'
                        or $nodeName = 'undisbursed_loans_us_millions_'
                        or $nodeName = 'undisbursed_credits_us_millions_'
                        or $nodeName = 'undisbursed_grants_us_millions_'
                        or $nodeName = 'usable_capital_and_reserves_us_millions'

                        or $nodeName = 'due_3rd_party'
                        or $nodeName = 'due to_ida'
                        or $nodeName = 'loans_held'
                        or $nodeName = 'loans_outstanding'
                        or $nodeName = 'receipt_amount'
                        or $nodeName = 'repaid_3rd_party'
                        or $nodeName = 'total_amounts'
                        or $nodeName = 'undisbursed_amount'
                        ">
                <xsl:variable name="term" select="replace(replace(normalize-space($nodeName), '_', '-'), '-$', '')"/>
                <xsl:element name="property:{$datasetName}{$term}">
                    <xsl:call-template name="datatype-dbo-usd"/>
                    <xsl:value-of select="./text()"/>
                </xsl:element>
            </xsl:when>

            <xsl:when test="$nodeName = 'currency_of_commitment'
                            or $nodeName = 'receipt_currency'">
                <xsl:variable name="currency" select="normalize-space(./text())"/>
                <xsl:variable name="term" select="replace(replace(normalize-space($nodeName), '_', '-'), '-$', '')"/>

                <xsl:choose>
                    <xsl:when test="document($pathToCurrencies)/rdf:RDF/rdf:Description[skos:notation/text() = $currency]/@rdf:about">
                        <!-- XXX: I prefer to use 'currency' instead of 'currency-of-commitment' but that would mean that I have to change the property name in the dictionary wc6g-9zmq -->
                        <xsl:element name="property:{$term}">
                            <xsl:attribute name="rdf:resource">
                               <xsl:value-of select="$classification"/><xsl:text>currency/</xsl:text><xsl:value-of select="$currency"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:element name="property:{$term}">
                            <xsl:value-of select="./text()"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="$nodeName = 'description'">
                <xsl:element name="property:{$datasetName}desription">
                    <xsl:value-of select="./text()"/>
                </xsl:element>
            </xsl:when>

            <xsl:when test="$nodeName = 'loan_number'
                            or $nodeName = 'credit_number'">
                <!-- XXX: This is a bit dirty i.e., check for substring in lendingTypes file instead -->
                <xsl:variable name="lendingTypeString" select="replace(./text(), '(IBRD|Blend|IDA|Not classified).*', '$1')"/>
                <xsl:choose>
                    <xsl:when test="document($pathToLendingTypes)/rdf:RDF/rdf:Description[skos:prefLabel/text() = $lendingTypeString]">
                        <xsl:element name="property:loan-number">
                            <xsl:attribute name="rdf:resource">
                               <xsl:value-of select="$wbld"/><xsl:text>loan-number/</xsl:text><xsl:value-of select="normalize-space(./text())"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:element name="property:loan-number">
                            <xsl:value-of select="./text()"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="$nodeName = 'loan_status'
                            or $nodeName = 'credit_status'">
                <xsl:variable name="loanStatus" select="lower-case(normalize-space(./text()))"/>
                <property:loan-status rdf:resource="{$classification}loan-status/{$loanStatus}"/>
            </xsl:when>

            <xsl:when test="$nodeName = 'loan_type'">
                <xsl:variable name="loanType" select="replace(lower-case(normalize-space(./text())), '\s+', '-')"/>
                <property:loan-type rdf:resource="{$classification}loan-type/{$loanType}"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:element name="property:{$datasetName}{replace(replace(normalize-space($nodeName), '_', '-'), '-$', '')}">
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
