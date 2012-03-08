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
    <xsl:param name="pathToMeta"/>
    <xsl:param name="pathToCountries"/>
    <xsl:param name="pathToLendingTypes"/>
    <xsl:param name="pathToCurrencies"/>
    <xsl:param name="pathToRegionsExtra"/>
    <xsl:param name="pathToFinancesDictionary"/>
    <xsl:param name="financeDatasetID"/>

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

        <xsl:choose>
            <!-- XXX: When running this XSLT, make sure that this case gets taken care of first. -->
            <xsl:when test="$financeDatasetID = 'wc6g-9zmq'">
                <xsl:for-each select="response/row/row">

                    <xsl:variable name="data_element" select="wbldfn:safe-term(data_element)"/>

                    <xsl:if test="$data_element != 'uuid'
                                and $data_element != 'project-name'">
                        <xsl:variable name="dataset_name">
                            <xsl:if test="$data_element = 'approval-quarter'
                                        or $data_element = 'calendar-year'
                                        or $data_element = 'financial-product'
                                        or $data_element = 'line-item'
                                        or $data_element = 'organization'
                                        or $data_element = 'sub-account'">
                                <xsl:value-of select="wbldfn:safe-term(dataset_name)"/><xsl:text>-</xsl:text>
                            </xsl:if>
                        </xsl:variable>

                        <xsl:variable name="data_element">
                            <xsl:choose>
                                <xsl:when test="$data_element = 'credit-status'">
                                    <xsl:text>loan-status</xsl:text>
                                </xsl:when>
                                <xsl:when test="$data_element = 'credit-number'">
                                    <xsl:text>loan-number</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$data_element"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>

                        <xsl:variable name="resourceDescriptionProperty">
                            <xsl:value-of select="$wbld"/><xsl:text>property/</xsl:text><xsl:value-of select="$dataset_name"/><xsl:value-of select="$data_element"/>
                        </xsl:variable>

                        <rdf:Description rdf:about="{$resourceDescriptionProperty}">
                            <!-- XXX: I'm not sure about this -->
                            <xsl:if test="$data_element = 'project-id'">
                                <rdfs:subPropertyOf rdf:resource="{$wbld}property/project-id"/>
                            </xsl:if>

                            <xsl:if test="$data_element = 'loan-number' or $data_element = 'credit-number'">
                                <rdfs:subPropertyOf rdf:resource="{$wbld}property/loan-number"/>
                            </xsl:if>

                            <xsl:if test="$data_element = 'loan-status' or $data_element = 'credit-status'">
                                <rdfs:subPropertyOf rdf:resource="{$wbld}property/loan-status"/>
                            </xsl:if>

                            <xsl:if test="$data_element = 'loan-type'">
                                <rdfs:subPropertyOf rdf:resource="{$wbld}property/loan-type"/>
                            </xsl:if>

                            <!-- TODO: I'm not sure about these qb concept/codeList for ibrd/ida project-ids-->
                            <qb:concept rdf:resource="{$classification}{$data_element}"/>
                            <qb:codeList rdf:resource="{$classification}{$data_element}"/>
                            <rdfs:label xml:lang="{$wbapi_lang}"><xsl:value-of select="normalize-space(data_element)"/></rdfs:label>
                            <!-- <property:uuid><xsl:value-of select="@_uuid"/></property:uuid> -->
                            <!-- <property:view-row-id><xsl:value-of select="@_id"/></property:view-row-id> -->

                            <dcterms:source rdf:resource="http://finances.worldbank.org/api/views/wc6g-9zmq/rows.xml"/>
                            <dcterms:issued>
                                <xsl:call-template name="datatype-date"/>
                                <xsl:value-of select="$currentDateTime"/>
                            </dcterms:issued>

                            <xsl:choose>
                                <xsl:when test="$data_element = 'country-code'
                                                or $data_element = 'guarantor-country-code'
                                                or $data_element = 'country'
                                                or $data_element = 'country-beneficiary'
                                                or $data_element = 'donor-name'
                                                or $data_element = 'guarantor'
                                                or $data_element = 'member'
                                                or $data_element = 'member-country'

                                                or $data_element = 'region'

                                                or $data_element = 'agreement-signing-date'
                                                or $data_element = 'as-of-date'
                                                or $data_element = 'board-approval-date'
                                                or $data_element = 'closed-date-most-recent'
                                                or $data_element = 'effective-date-most-recent'
                                                or $data_element = 'end-of-period'
                                                or $data_element = 'first-repayment-date'
                                                or $data_element = 'last-repayment-date'
                                                or $data_element = 'last-disbursement-date'
                                                or $data_element = 'period-end-date'

                                                or $data_element = 'fiscal-year'
                                                or $data_element = 'calendar-year'

                                                or $data_element = 'approval-quarter'
                                                or $data_element = 'receipt-quarter'
                                                or $data_element = 'transfer-quarter'

                                                or $data_element = 'loan-type'
                                                or $data_element = 'loan-number'

                                                or $data_element = 'category'
                                                or $data_element = 'line-item'

                                                or $data_element = 'project-id'
                                                or $data_element = 'project-name'

                                                or $data_element = 'receipt-type'
                                                or $data_element = 'contribution-type'
                                                or $data_element = 'financial-product'

                                                or $data_element = 'fund-name'
                                                or $data_element = 'source'
                                                or $data_element = 'use-code'
                                                or $data_element = 'recipient'

                                                or $data_element = 'organization'
                                                or $data_element = 'principal-recipient'

                                                or $data_element = 'borrower'
                                                or $data_element = 'membership'

                                                or $data_element = 'sector-theme'
                                                ">
                                    <rdf:type rdf:resource="{$qb}DimensionProperty"/>
                                </xsl:when>

                                <xsl:when test="$data_element = 'amount-in-usd'
                                                or $data_element = 'amounts-paid-in'
                                                or $data_element = 'amount-us-millions'
                                                or $data_element = 'amounts-subject-to-call'
                                                or $data_element = 'borrower-s-obligation'
                                                or $data_element = 'cancelled-amount'
                                                or $data_element = 'commitments-total-us-millions'
                                                or $data_element = 'contributions-paid-in-usd'
                                                or $data_element = 'credits-held'
                                                or $data_element = 'counterparty-rating'
                                                or $data_element = 'credits-outstanding-us-millions'
                                                or $data_element = 'development-grant-expenses-us-millions'
                                                or $data_element = 'disbursed-amount'
                                                or $data_element = 'due-3rd-party'
                                                or $data_element = 'due-to-ibrd'
                                                or $data_element = 'due-to-ida'
                                                or $data_element = 'equity-to-loans-ratio'
                                                or $data_element = 'exchange-adjustment'
                                                or $data_element = 'gross-disbursements-total-us-millions'
                                                or $data_element = 'gross-disbursements-development-policy-lending-us-millions'
                                                or $data_element = 'interest-rate'
                                                or $data_element = 'loan-status'
                                                or $data_element = 'loans-held'
                                                or $data_element = 'loans-outstanding'
                                                or $data_element = 'net-disbursements-us-millions'
                                                or $data_element = 'number-of-votes'
                                                or $data_element = 'operating-income-us-millions'
                                                or $data_element = 'original-principal-amount'
                                                or $data_element = 'percentage-of-total-shares'
                                                or $data_element = 'percentage-of-total-votes'
                                                or $data_element = 'principal-repayments-including-prepayments-us-millions'
                                                or $data_element = 'receipt-amount'
                                                or $data_element = 'repaid-3rd-party'
                                                or $data_element = 'repaid-to-ibrd'
                                                or $data_element = 'repaid-to-ida'
                                                or $data_element = 'shares'
                                                or $data_element = 'service-charge-rate'
                                                or $data_element = 'sold-3rd-party'
                                                or $data_element = 'subscriptions-and-contributions-committed-us-millions'
                                                or $data_element = 'total-amounts'
                                                or $data_element = 'undisbursed-amount'
                                                or $data_element = 'undisbursed-credits-us-millions'
                                                or $data_element = 'undisbursed-grants-us-millions'
                                                or $data_element = 'undisbursed-loans-us-millions'
                                                or $data_element = 'usable-capital-and-reserves-us-millions'
                                                ">
                                    <rdf:type rdf:resource="{$qb}MeasureProperty"/>
                                </xsl:when>

                                <xsl:when test="$data_element = 'currency-of-commitment'
                                                or $data_element = 'receipt-currency'">
                                    <rdf:type rdf:resource="{$qb}AttributeProperty"/>
                                </xsl:when>

                                <xsl:when test="$data_element = 'credit-status'">
                                    <rdf:type rdf:resource="{$qb}AttributeProperty"/>
                                </xsl:when>

                                <!-- FIXME: Make sure to catch all properties. This is here temporarily. -->
                                <xsl:otherwise>
                                    <xsl:text>FIXME----PLEASE----CONTACT----MAINTAINER----http://csarven.ca/#i</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </rdf:Description>

                        <rdf:Description rdf:about="{$classification}finance">
                            <skos:hasTopConcept rdf:resource="{$classification}{$data_element}"/>
                        </rdf:Description>

                        <rdf:Description rdf:about="{$classification}{$data_element}">
                            <rdf:type rdf:resource="{$qb}Concept"/>
                            <skos:inScheme rdf:resource="{$classification}finance"/>
                            <skos:topConceptOf rdf:resource="{$classification}finance"/>

                            <skos:prefLabel xml:lang="{$wbapi_lang}"><xsl:value-of select="normalize-space(data_element)"/></skos:prefLabel>
                            <skos:definition xml:lang="{$wbapi_lang}"><xsl:value-of select="description"/></skos:definition>

                            <dcterms:source rdf:resource="http://finances.worldbank.org/api/views/{$financeDatasetID}/rows.xml"/>
                            <dcterms:issued>
                                <xsl:call-template name="datatype-date"/>
                                <xsl:value-of select="$currentDateTime"/>
                            </dcterms:issued>
                        </rdf:Description>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>

            <xsl:otherwise>
                <xsl:for-each select="//response/row/row[1]/*">
                    <xsl:variable name="dataElement" select="wbldfn:safe-term(name())"/>
                    <xsl:variable name="dataElement">
                        <xsl:choose>
                            <xsl:when test="$dataElement = 'credit-status'">
                                <xsl:text>loan-status</xsl:text>
                            </xsl:when>
                            <xsl:when test="$dataElement = 'credit-number'">
                                <xsl:text>loan-number</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$dataElement"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:if test="$dataElement != 'uuid'
                                and $dataElement != 'project-name'">
                        <xsl:variable name="financeDataset">
                            <xsl:value-of select="$wbld"/><xsl:text>dataset/world-bank-finances/</xsl:text><xsl:value-of select="$financeDatasetID"/>
                        </xsl:variable>

                        <xsl:variable name="datasetName">
                            <xsl:value-of select="document($pathToMeta)/rdf:RDF/rdf:Description[@rdf:about = $financeDataset]/rdfs:label"/>
                        </xsl:variable>

                        <xsl:variable name="datasetName">
                            <xsl:if test="name() = 'approval_quarter'
                                        or name() = 'calendar_year'
                                        or name() = 'financial_product'
                                        or name() = 'line_item'
                                        or name() = 'organization'
                                        or name() = 'sub_account'">
                                <xsl:value-of select="wbldfn:safe-term($datasetName)"/><xsl:text>-</xsl:text>
                            </xsl:if>
                        </xsl:variable>

                        <xsl:variable name="resourceDescriptionProperty">
                            <xsl:value-of select="$wbld"/><xsl:text>property/</xsl:text><xsl:value-of select="$datasetName"/><xsl:value-of select="$dataElement"/>
                        </xsl:variable>
<xsl:message><xsl:text>resourceDescriptionProperty: </xsl:text><xsl:value-of select="$resourceDescriptionProperty"/></xsl:message>
                        <qb:DataStructureDefinition rdf:about="{$wbld}property/world-bank-finances/{$financeDatasetID}/structure">
                            <qb:component>
                                <qb:ComponentSpecification>
                                    <xsl:variable name="componentPropertyURI">
                                        <xsl:value-of select="document($pathToFinancesDictionary)/rdf:RDF/rdf:Description[@rdf:about = $resourceDescriptionProperty][1]/rdf:type/@rdf:resource"/>
                                    </xsl:variable>

                                    <xsl:variable name="componentPropertyURI">
                                        <xsl:choose>
                                            <xsl:when test="$componentPropertyURI = ''">
                                                <xsl:value-of select="document($pathToMeta)/rdf:RDF/rdf:Description[@rdf:about = $resourceDescriptionProperty][1]/rdf:type/@rdf:resource"/>
                                            </xsl:when>

                                            <xsl:otherwise>
                                                <xsl:value-of select="$componentPropertyURI"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>

<xsl:message><xsl:text>componentPropertyURI: </xsl:text><xsl:value-of select="$componentPropertyURI"/></xsl:message>
                                    <xsl:variable name="componentProperty">
                                        <xsl:choose>
                                            <xsl:when test="$componentPropertyURI = 'http://purl.org/linked-data/cube#DimensionProperty'">
                                                <xsl:text>qb:dimension</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$componentPropertyURI = 'http://purl.org/linked-data/cube#MeasureProperty'">
                                                <xsl:text>qb:measure</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$componentPropertyURI = 'http://purl.org/linked-data/cube#AttributeProperty'">
                                                <xsl:text>qb:attribute</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>qb:FIXME----PLEASE----CONTACT----MAINTAINER----</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>

                                    <xsl:element name="{$componentProperty}">
                                        <xsl:attribute name="rdf:resource" select="$resourceDescriptionProperty"/>
                                    </xsl:element>
                                </qb:ComponentSpecification>
                            </qb:component>
                        </qb:DataStructureDefinition>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
