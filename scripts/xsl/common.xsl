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
        <xsl:value-of select="replace(replace(replace(replace(lower-case(encode-for-uri(replace(normalize-space($string), ' - ', '-'))), '%20|%2f|%27', '-'), '%28|%29|%24|%2c', ''), '_', '-'), '^-|-$', '')"/>
    </xsl:function>

    <xsl:function name="wbldfn:prepend-dataset">
        <xsl:param name="string"/>

        <xsl:if test="$string = 'approval-quarter'
                    or $string = 'calendar-year'
                    or $string = 'financial-product'
                    or $string = 'line-item'
                    or $string = 'organization'
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
            <xsl:when test="$string = 'credit-status'">
                <xsl:text>loan-status</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'credit-number'">
                <xsl:text>loan-number</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'bb-us-millions'">
                <xsl:text>bb-mlns-of-usd</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'reimbursable-us-millions'">
                <xsl:text>reimbursable-mlns-of-usd</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'betf-us-millions'">
                <xsl:text>betf-mlns-of-usd</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'commitments-total'">
                <xsl:text>commitments-total-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'trustee-fund-number'">
                <xsl:text>trustee-fund</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'disbursements-us-billions'">
                <xsl:text>disbursements-usd</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'grant-fund-name'">
                <xsl:text>grant-name</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'commitments-development-policy-lending'">
                <xsl:text>commitments-development-policy-lending-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'gross-disbursements-total'">
                <xsl:text>gross-disbursements-total-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'gross-disbursements-development-policy-lending'">
                <xsl:text>gross-disbursements-development-policy-lending-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'principal-repayments-including-prepayments'">
                <xsl:text>principal-repayments-including-prepayments-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'net-disbursements'">
                <xsl:text>net-disbursements-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'loans-outstanding'">
                <xsl:text>loans-outstanding-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'undisbursed-loans'">
                <xsl:text>undisbursed-loans-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'operating-income'">
                <xsl:text>operating-income-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'usable-capital-and-reserves'">
                <xsl:text>usable-capital-and-reserves-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'subscriptions-and-contributions-commited-us-millions'">
                <xsl:text>subscriptions-and-contributions-committed-us-millions</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
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
