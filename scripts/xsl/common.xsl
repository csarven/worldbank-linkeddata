<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URL: http://csarven.ca/#i
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:wbldfn="http://worldbank.270a.info/xpath-function/">

    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:function name="wbldfn:safe-term">
        <xsl:param name="string"/>
        <xsl:value-of select="replace(replace(replace(replace(replace(lower-case(encode-for-uri(replace(normalize-space($string), ' - ', '-'))), '%20|%2f|%27', '-'), '%28|%29|%24|%2c', ''), '_', '-'), '--', '-'), '^-|-$', '')"/>
    </xsl:function>

    <xsl:function name="wbldfn:prepend-dataset">
        <xsl:param name="string"/>

        <xsl:if test="$string = 'approval-quarter'
                    or $string = 'calendar-year'
                    or $string = 'financial-product'
                    or $string = 'line-item'
                    or $string = 'organization'
                    or $string = 'source'
                    or $string = 'status'
                    or $string = 'sub-account'
                    or $string = 'trustee-fund'
                    or $string = 'trustee-fund-name'
                    ">
            <xsl:value-of select="true()"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="wbldfn:canonical-term">
        <xsl:param name="string"/>

        <xsl:choose>
            <xsl:when test="$string = 'bb-mlns-of-usd'">
                <xsl:text>bb-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'betf-mlns-of-usd'">
                <xsl:text>betf-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'commitments-development-policy-lending'">
                <xsl:text>commitments-development-policy-lending-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'commitments-total'">
                <xsl:text>commitments-total-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'credit-number'">
                <xsl:text>loan-number</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'credits-outstanding'">
                <xsl:text>credits-outstanding-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'credit-status'">
                <xsl:text>loan-status</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'development-grant-expenses'">
                <xsl:text>development-grant-expenses-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'disbursements-usd'">
                <xsl:text>disbursements-us-billions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'grant-fund-name'">
                <xsl:text>grant-name</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'gross-disbursements-development-policy-lending'">
                <xsl:text>gross-disbursements-development-policy-lending-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'gross-disbursements-total'">
                <xsl:text>gross-disbursements-total-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'loans-outstanding'">
                <xsl:text>loans-outstanding-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'net-disbursements'">
                <xsl:text>net-disbursements-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'operating-income'">
                <xsl:text>operating-income-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'principal-repayments-including-prepayments'">
                <xsl:text>principal-repayments-including-prepayments-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'reimbursable-mlns-of-usd'">
                <xsl:text>reimbursable-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'subscriptions-and-contributions-commited-us-millions'">
                <xsl:text>subscriptions-and-contributions-committed-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'trustee-fund-number'">
                <xsl:text>trustee-fund</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'undisbursed-credits'">
                <xsl:text>undisbursed-credits-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'undisbursed-grants'">
                <xsl:text>undisbursed-grants-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'undisbursed-loans'">
                <xsl:text>undisbursed-loans-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'usable-capital-and-reserves'">
                <xsl:text>usable-capital-and-reserves-us-millions</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="wbldfn:money-amount">
        <xsl:param name="string"/>
        <xsl:if test="$string = 'amount-in-usd'
                    or $string = 'amounts-paid-in'
                    or $string = 'amounts-subject-to-call'
                    or $string = 'amount-us-millions'
                    or $string = 'bb-us-millions'
                    or $string = 'betf-us-millions'
                    or $string = 'borrower-s-obligation'
                    or $string = 'cancelled-amount'
                    or $string = 'cash-contributions-us-billions'
                    or $string = 'commitments-development-policy-lending-us-millions'
                    or $string = 'commitments-total-us-millions'
                    or $string = 'contributions-outstanding-usd'
                    or $string = 'contributions-paid-in-usd'
                    or $string = 'credits-held'
                    or $string = 'credits-outstanding-us-millions'
                    or $string = 'development-grant-expenses-us-millions'
                    or $string = 'disbursed-amount'
                    or $string = 'disbursements-us-billions'
                    or $string = 'due-3rd-party'
                    or $string = 'due-to-ibrd'
                    or $string = 'due-to-ida'
                    or $string = 'exchange-adjustment'
                    or $string = 'fy05-amount-us-millions'
                    or $string = 'fy06-amount-us-millions'
                    or $string = 'fy07-amount-us-millions'
                    or $string = 'fy08-amount-us-millions'
                    or $string = 'fy09-amount-us-millions'
                    or $string = 'fy09-budget-plan'
                    or $string = 'fy10-amount-us-millions'
                    or $string = 'fy10-budget-plan'
                    or $string = 'fy11-amount-us-millions'
                    or $string = 'fy11-budget-plan'
                    or $string = 'fy11-budget-remap'
                    or $string = 'fy12-budget-plan-fy11'
                    or $string = 'fy13-indicative-plan-fy12'
                    or $string = 'fy14-indicative-plan-fy12'
                    or $string = 'grant-commitments-usd'
                    or $string = 'gross-disbursements-development-policy-lending-us-millions'
                    or $string = 'gross-disbursements-total-us-millions'
                    or $string = 'loans-held'
                    or $string = 'loans-outstanding-us-millions'
                    or $string = 'net-disbursements-us-millions'
                    or $string = 'operating-income-us-millions'
                    or $string = 'original-principal-amount'
                    or $string = 'principal-repayments-including-prepayments-us-millions'
                    or $string = 'receipt-amount'
                    or $string = 'reimbursable-us-millions'
                    or $string = 'repaid-3rd-party'
                    or $string = 'repaid-to-ibrd'
                    or $string = 'repaid-to-ida'
                    or $string = 'sold-3rd-party'
                    or $string = 'subscriptions-and-contributions-committed-us-millions'
                    or $string = 'total-amounts'
                    or $string = 'total-contribution-usd'
                    or $string = 'undisbursed-amount'
                    or $string = 'undisbursed-credits-us-millions'
                    or $string = 'undisbursed-grants-us-millions'
                    or $string = 'undisbursed-loans-us-millions'
                    or $string = 'usable-capital-and-reserves-us-millions'
                    ">
            <xsl:value-of select="true()"/>
        </xsl:if>
    </xsl:function>

    <xsl:template name="resource-refperiod">
        <xsl:param name="date"/>
        <xsl:attribute name="rdf:resource">
            <xsl:analyze-string select="$date" regex="(([0-9]{{4}})|([1-9][0-9]{{3,}})+)(Q[1-4])">
                <xsl:matching-substring>
                    <xsl:text>http://reference.data.gov.uk/id/quarter/</xsl:text><xsl:value-of select="regex-group(1)"/><xsl:text>-</xsl:text><xsl:value-of select="regex-group(4)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:analyze-string select="$date" regex="(([0-9]{{4}})|([1-9][0-9]{{3,}})+)">
                        <xsl:matching-substring>
                           <xsl:text>http://reference.data.gov.uk/id/year/</xsl:text><xsl:value-of select="regex-group(1)"/>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:analyze-string select="$date" regex="FY([0-9]{{2}})">
                                <xsl:matching-substring>
                                   <xsl:text>http://reference.data.gov.uk/id/year/20</xsl:text><xsl:value-of select="regex-group(1)"/>
                                </xsl:matching-substring>
                                <!-- XXX: May not be ideal -->
                                <xsl:non-matching-substring>
                                   <xsl:text>http://reference.data.gov.uk/id/year/{date}"</xsl:text>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="datatype-date">
        <xsl:attribute name="rdf:datatype">
            <xsl:text>http://www.w3.org/2001/XMLSchema#dateTime</xsl:text>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="datatype-dbo-usd">
        <xsl:attribute name="rdf:datatype">
            <xsl:text>http://dbpedia.org/resource/United_States_dollar</xsl:text>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="provenance">
        <xsl:param name="date"/>
        <xsl:param name="dataSource"/>
        <dcterms:issued>
            <xsl:call-template name="datatype-date"/>
            <xsl:value-of select="$date"/>
        </dcterms:issued>
        <dcterms:source rdf:resource="{$dataSource}"/>
        <dcterms:creator rdf:resource="http://csarven.ca/#i"/>
    </xsl:template>
</xsl:stylesheet>
