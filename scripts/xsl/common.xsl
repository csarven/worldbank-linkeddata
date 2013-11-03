<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URL: http://csarven.ca/#i
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:wb="http://www.worldbank.org"
    xmlns:wbldfn="http://worldbank.270a.info/xpath-function/"
    xmlns:property="http://worldbank.270a.info/property/"
    >

    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="pathToCountries"/>
    <xsl:param name="pathToCurrencies"/>

    <xsl:variable name="classification">http://worldbank.270a.info/classification/</xsl:variable>

    <xsl:function name="wbldfn:safe-term">
        <xsl:param name="string"/>
        <xsl:value-of select="replace(replace(replace(replace(replace(lower-case(encode-for-uri(replace(normalize-space($string), ' - ', '-'))), '%20|%2f|%27', '-'), '%28|%29|%24|%2c', ''), '_', '-'), '--', '-'), '^-|-$', '')"/>
    </xsl:function>

    <xsl:function name="wbldfn:prepend-dataset">
        <xsl:param name="string"/>

        <xsl:if test="$string = 'line-item'
                    or $string = 'trustee-fund'
                    or $string = 'trustee-fund-name'
                    ">
<!--                    or $string = 'financial-product'-->
            <xsl:value-of select="true()"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="wbldfn:usable-term">
        <xsl:param name="string"/>
<!--
XXX: Temporary stuff:

*mdk* no longer exists in the data from the projects API. Thus, those restrictions here will be removed when I change from the static file to the API. The API is not quite ready yet and the static file appears to be more stable.

The 'location' data is broken in the XML version. The JSON version contains the proper keys for its children. I will wait until the projects API's XML output is better, and then output the location data.

Excluding projectdoc.doctype for the time being as well because the XML data is not clean enough. Rather introduce these triples later on.

Ignoring mjsector[1-5].name for now. When there is classification/major-section codelist, each concept will include the name, notation (from mjsector[1-5].code.

Ignoring sector[1-5].
..

XXX: Review every single term here. Mostly projects-and-operations related. Only uuid, country-name, donor-name and partially the project-name is from finances.


XXX: This is from some datasets that are not clear whether they are in release-quality. Leaving them out for now until they are resolved in the emails with WB finances team:
date-of-report
project-status
category-code
allocated-amount-usd
disbursed-amount-usd
undisbursed-amount-usd
special-commitments-usd
funds-available-usd
historical-category-disbursed-usd
-->
        <xsl:if test="$string != ''
                    and $string != 'agencyinfo'
                    and $string != 'board-approval-month'
                    and $string != 'board-approval-year'
                    and $string != 'borrower-country'
                    and $string != 'countryname'
                    and $string != 'countryname-and-mdk'
                    and $string != 'countrynameshortname-and-mdk'
                    and $string != 'countrynameshortname-and-mdk-exact'
                    and $string != 'countryshortname-and-mdk'
                    and $string != 'countryshortname-and-mdk-exact'
                    and $string != 'docty'
                    and $string != 'donor-name'
                    and $string != 'linkinfo'
                    and $string != 'location'
                    and $string != 'beneficiary-name'
                    and $string != 'isrr-doc'
                    and $string != 'majorsector-percent'
                    and $string != 'mjsector'
                    and $string != 'mjsector-and-mdk'
                    and $string != 'mjsector-and-mdk-exact'
                    and $string != 'mjsector1'
                    and $string != 'mjsector2'
                    and $string != 'mjsector3'
                    and $string != 'mjsector4'
                    and $string != 'mjsector5'
                    and $string != 'mjtheme1name'
                    and $string != 'mjtheme2name'
                    and $string != 'mjtheme3name'
                    and $string != 'mjtheme4name'
                    and $string != 'mjtheme5name'
                    and $string != 'projectinfo'
                    and $string != 'project-name'
                    and $string != 'project-name-and-mdk'
                    and $string != 'projectdoc.doctype'
                    and $string != 'regionname-and-mdk'
                    and $string != 'regionname-and-mdk-exact'
                    and $string != 'sector-and-mdk'
                    and $string != 'sector-and-mdk-exact'
                    and $string != 'sector1'
                    and $string != 'sector2'
                    and $string != 'sector3'
                    and $string != 'sector4'
                    and $string != 'sector5'
                    and $string != 'timestamp'
                    and $string != 'theme-and-mdk'
                    and $string != 'theme-and-mdk-exact'
                    and $string != 'theme1'
                    and $string != 'theme2'
                    and $string != 'theme3'
                    and $string != 'theme4'
                    and $string != 'theme5'


                    and $string != 'date-of-report'
                    and $string != 'project-status'
                    and $string != 'category-code'
                    and $string != 'allocated-amount-usd'
                    and $string != 'disbursed-amount-usd'
                    and $string != 'undisbursed-amount-usd'
                    and $string != 'special-commitments-usd'
                    and $string != 'funds-available-usd'
                    and $string != 'historical-category-disbursed-usd'

                    and $string != 'uuid'
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
            <xsl:when test="$string = 'beneficiary-code'">
                <xsl:text>beneficiary</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'betf-mlns-of-usd'">
                <xsl:text>betf-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'boardapprovaldate'">
                <xsl:text>board-approval-date</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'borrower-country-code'">
                <xsl:text>borrower</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'closingdate'">
                <xsl:text>closing-date</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'commitments-development-policy-lending'">
                <xsl:text>commitments-development-policy-lending-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'commitments-total'">
                <xsl:text>commitments-total-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'countryshortname-exact'">
                <xsl:text>country</xsl:text>
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
            <xsl:when test="$string = 'country-beneficiary'">
                <xsl:text>beneficiary</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'country-code'">
                <xsl:text>country</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'country-id'">
                <xsl:text>country</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'currency-of-commitment'">
                <xsl:text>currency</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'development-grant-expenses'">
                <xsl:text>development-grant-expenses-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'disbursements-usd'">
                <xsl:text>disbursements-us-billions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'donor-code'">
                <xsl:text>donor</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'envassesmentcategorycode'">
                <xsl:text>environmental-assessment-category-code</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'equity-millions'">
                <xsl:text>equity-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'grantamt'">
                <xsl:text>grant-amount-us-millions</xsl:text>
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
            <xsl:when test="$string = 'guarantor-country-code'">
                <xsl:text>guarantor</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'guarantees-millions'">
                <xsl:text>guarantees-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'ibrdcommamt'">
                <xsl:text>ibrd-commitment-amount</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'idacommamt'">
                <xsl:text>ida-commitment-amount</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'impagency'">
                <xsl:text>implementing-agency</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'indextype'">
                <xsl:text>index-type</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'lendinginstr'">
                <xsl:text>lending-instrument</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'lendinginstrtype'">
                <xsl:text>lending-instrument-type</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'lendprojectcost'">
                <xsl:text>lend-project-cost</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'listing-relative-url'">
                <xsl:text>listing-url</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'loans-outstanding'">
                <xsl:text>loans-outstanding-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'loans-millions'">
                <xsl:text>loans-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'loan-syndications-millions'">
                <xsl:text>loan-syndications-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'member-country'">
                <xsl:text>member</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'mjsectorcode'">
                <xsl:text>major-sector</xsl:text>
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
            <xsl:when test="$string = 'prodline'">
                <xsl:text>product-line</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'project-id'">
                <xsl:text>project</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'productlinetype'">
                <xsl:text>product-line-type</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'projectdocs'">
                <xsl:text>references</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'projectdoc.docdate'">
                <xsl:text>date</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'projectdoc.entityid'">
                <xsl:text>id</xsl:text>
            </xsl:when>
<!--
            <xsl:when test="$string = 'projectdoc.doctype'">
                <xsl:text>type</xsl:text>
            </xsl:when>
-->
            <xsl:when test="$string = 'projectdoc.doctypedesc'">
                <xsl:text>title</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'projectdoc.docurl'">
                <xsl:text>url</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'projectstatusdisplay'">
                <xsl:text>status</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'receipt-currency'">
                <xsl:text>currency</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'reimbursable-mlns-of-usd'">
                <xsl:text>reimbursable-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'risk-management-products-millions'">
                <xsl:text>risk-management-products-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'regionname'">
                <xsl:text>region</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'subscriptions-and-contributions-commited-us-millions'">
                <xsl:text>subscriptions-and-contributions-committed-us-millions</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'supplementprojectflg'">
                <xsl:text>supplement-project-flag</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'totalamt'">
                <xsl:text>total-amounts</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'totalcommamt'">
                <xsl:text>total-commitment-amount</xsl:text>
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


            <xsl:when test="$string = 'mavg'">
                <xsl:text>month-average</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'annualavg'">
                <xsl:text>year-average</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'manom'">
                <xsl:text>month-average-anomaly</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'annualanom'">
                <xsl:text>year-average-anomaly</xsl:text>
            </xsl:when>

            <xsl:when test="$string = 'mavg-ensemble'">
                <xsl:text>month-average-ensemble</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'annualavg-ensemble'">
                <xsl:text>year-average-ensemble</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'manom-ensemble'">
                <xsl:text>month-average-anomaly-ensemble</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'annualanom-ensemble'">
                <xsl:text>year-average-anomaly-ensemble</xsl:text>
            </xsl:when>

            <xsl:when test="$string = 'mavg-ensemble-derived'">
                <xsl:text>month-average-ensemble-derived</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'annualavg-ensemble-derived'">
                <xsl:text>year-average-ensemble-derived</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'manom-ensemble-derived'">
                <xsl:text>month-average-anomaly-ensemble-derived</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'annualanom-ensemble-derived'">
                <xsl:text>year-average-anomaly-ensemble-derived</xsl:text>
            </xsl:when>
<!--
            <xsl:when test="$string = 'pr'">
                <xsl:text>ppt</xsl:text>
            </xsl:when>
            <xsl:when test="$string = 'tas'">
                <xsl:text>temp</xsl:text>
            </xsl:when>
-->
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
                    or $string = 'equity-us-millions'
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
                    or $string = 'grant-amount-us-millions'
                    or $string = 'grant-commitments-usd'
                    or $string = 'gross-disbursements-development-policy-lending-us-millions'
                    or $string = 'gross-disbursements-total-us-millions'
                    or $string = 'guarantees-us-millions'
                    or $string = 'ibrd-commitment-amount'
                    or $string = 'ida-commitment-amount'
                    or $string = 'lend-project-cost'
                    or $string = 'loans-held'
                    or $string = 'loans-outstanding-us-millions'
                    or $string = 'loan-syndications-millions'
                    or $string = 'loans-us-millions'
                    or $string = 'net-disbursements-us-millions'
                    or $string = 'operating-income-us-millions'
                    or $string = 'original-principal-amount'
                    or $string = 'principal-repayments-including-prepayments-us-millions'
                    or $string = 'receipt-amount'
                    or $string = 'reimbursable-us-millions'
                    or $string = 'repaid-3rd-party'
                    or $string = 'repaid-to-ibrd'
                    or $string = 'repaid-to-ida'
                    or $string = 'risk-management-products-millions'
                    or $string = 'sold-3rd-party'
                    or $string = 'subscriptions-and-contributions-committed-us-millions'
                    or $string = 'total-amounts'
                    or $string = 'total-commitment-amount'
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

    <xsl:function name="wbldfn:classification">
        <xsl:param name="string"/>

        <xsl:if test="$string = 'basin'
					or $string = 'country'
					or $string = 'currency'
					or $string = 'global-circulation-model'
					or $string = 'income-level'
					or $string = 'indicator'
					or $string = 'lending-type'
					or $string = 'loan-status'
					or $string = 'loan-type'
					or $string = 'region'
					or $string = 'scenario'
					or $string = 'source'
					or $string = 'topic'
					or $string = 'variable'
                    ">
            <xsl:value-of select="true()"/>
        </xsl:if>
    </xsl:function>

    <xsl:template name="property-currency">
        <xsl:param name="currencyCode"/>

        <xsl:choose>
            <xsl:when test="document($pathToCurrencies)/rdf:RDF/rdf:Description[skos:notation/text() = $currencyCode]/@rdf:about">
                <xsl:element name="property:currency">
                    <xsl:attribute name="rdf:resource">
                       <xsl:value-of select="$classification"/><xsl:text>currency/</xsl:text><xsl:value-of select="$currencyCode"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>

            <xsl:otherwise>
                <xsl:element name="property:currency">
                    <xsl:value-of select="./text()"/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:function name="wbldfn:ISO-3166_3-to-ISO-3166_2">
        <xsl:param name="countryCode"/>

        <xsl:choose>
            <xsl:when test="document($pathToCountries)/wb:countries/wb:country[@id = $countryCode]">
                <xsl:value-of select="document($pathToCountries)/wb:countries/wb:country[@id = $countryCode]/wb:iso2Code/normalize-space(text())"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:value-of select="$countryCode"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="wbldfn:now">
        <xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>
    </xsl:function>


    <xsl:function name="wbldfn:get-month">
        <xsl:param name="month"/>

        <xsl:choose>
            <xsl:when test="string-length(format-number($month, '#')) = 1">
                <xsl:text>0</xsl:text><xsl:value-of select="$month"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$month"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="wbldfn:get-month-from-number">
        <xsl:param name="monthNumber"/>

        <xsl:choose>
            <xsl:when test="$monthNumber = 1"><xsl:text>January</xsl:text></xsl:when>
            <xsl:when test="$monthNumber = 2"><xsl:text>February</xsl:text></xsl:when>
            <xsl:when test="$monthNumber = 3"><xsl:text>March</xsl:text></xsl:when>
            <xsl:when test="$monthNumber = 4"><xsl:text>April</xsl:text></xsl:when>
            <xsl:when test="$monthNumber = 5"><xsl:text>May</xsl:text></xsl:when>
            <xsl:when test="$monthNumber = 6"><xsl:text>June</xsl:text></xsl:when>
            <xsl:when test="$monthNumber = 7"><xsl:text>July</xsl:text></xsl:when>
            <xsl:when test="$monthNumber = 8"><xsl:text>August</xsl:text></xsl:when>
            <xsl:when test="$monthNumber = 9"><xsl:text>September</xsl:text></xsl:when>
            <xsl:when test="$monthNumber = 10"><xsl:text>October</xsl:text></xsl:when>
            <xsl:when test="$monthNumber = 11"><xsl:text>November</xsl:text></xsl:when>
            <xsl:when test="$monthNumber = 12"><xsl:text>December</xsl:text></xsl:when>

            <xsl:otherwise>
<xsl:message><xsl:text>FIXME 1 OTHERWISE</xsl:text></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="wbldfn:get-quarter">
        <xsl:param name="string"/>

        <xsl:choose>
            <xsl:when test="lower-case(normalize-space($string)) = 'jan-mar'">
                <xsl:text>Q1</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case(normalize-space($string)) = 'apr-jun'">
                <xsl:text>Q2</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case(normalize-space($string)) = 'jul-sep'">
                <xsl:text>Q3</xsl:text>
            </xsl:when>
            <xsl:when test="lower-case(normalize-space($string)) = 'oct-dec'">
                <xsl:text>Q4</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="wbldfn:get-date">
        <xsl:param name="date"/>

        <xsl:variable name="date" select="lower-case(normalize-space($date))"/>

        <xsl:analyze-string select="$date" regex="([0-9]{{2}})-([a-z]{{3}})-([0-9]{{4}})">
            <xsl:matching-substring>
                <xsl:variable name="monthName" select="regex-group(2)"/>

                <xsl:variable name="month">
                    <xsl:choose>
                        <xsl:when test="$monthName = 'jan'"><xsl:text>01</xsl:text></xsl:when>
                        <xsl:when test="$monthName = 'feb'"><xsl:text>02</xsl:text></xsl:when>
                        <xsl:when test="$monthName = 'mar'"><xsl:text>03</xsl:text></xsl:when>
                        <xsl:when test="$monthName = 'apr'"><xsl:text>04</xsl:text></xsl:when>
                        <xsl:when test="$monthName = 'may'"><xsl:text>05</xsl:text></xsl:when>
                        <xsl:when test="$monthName = 'jun'"><xsl:text>06</xsl:text></xsl:when>
                        <xsl:when test="$monthName = 'jul'"><xsl:text>07</xsl:text></xsl:when>
                        <xsl:when test="$monthName = 'aug'"><xsl:text>08</xsl:text></xsl:when>
                        <xsl:when test="$monthName = 'sep'"><xsl:text>09</xsl:text></xsl:when>
                        <xsl:when test="$monthName = 'oct'"><xsl:text>10</xsl:text></xsl:when>
                        <xsl:when test="$monthName = 'nov'"><xsl:text>11</xsl:text></xsl:when>
                        <xsl:when test="$monthName = 'dec'"><xsl:text>12</xsl:text></xsl:when>
                        <xsl:otherwise><xsl:text>00</xsl:text></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:value-of select="regex-group(3)"/><xsl:text>-</xsl:text><xsl:value-of select="$month"/><xsl:text>-</xsl:text><xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>

            <xsl:non-matching-substring>
                <xsl:analyze-string select="$date" regex="([0-9]{{2}})[^0-9]{{1}}([0-9]{{2}})[^0-9]{{1}}([0-9]{{4}})">
                    <xsl:matching-substring>
                    <xsl:value-of select="regex-group(3)"/><xsl:text>-</xsl:text><xsl:value-of select="regex-group(1)"/><xsl:text>-</xsl:text><xsl:value-of select="regex-group(2)"/>
                    </xsl:matching-substring>

                    <xsl:non-matching-substring>
<!--
    xmlns:func="http://exslt.org/functions"
                xmlns:is-date="http://www.intelligentstreaming.com/xsl/date-time"
                extension-element-prefixes="func"
    exclude-result-prefixes="func is-date"

                        <xsl:analyze-string select="$date" regex="([0-9]+)">
                            <xsl:matching-substring>

XXX: My brain stopped here. I can't be bothered with this POS. I need to sleep.
<xsl:value-of select="format-date(current-dateTime(), '[Y0001]-[M01]-[D01]')">
<xsl:value-of select='xsd:dateTime("1970-01-01T00:00:00") + $date * xsd:dayTimeDuration("PT0.001S")'/>
<xsl:value-of select="date:add('1970-01-01T00:00:00Z', date:duration($date div 1000))"/>

<xsl:value-of select="is-date:iso-from-unix($date)"/>
<xsl:variable name="date" select="$date" as="xsd:integer"/>
                            </xsl:matching-substring>

                            <xsl:non-matching-substring>
                                <xsl:value-of select="$date"/>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
-->

                        <xsl:analyze-string select="$date" regex="(([0-9]{{4}})|([1-9][0-9]{{3,}})+)-?q([1-4])">
                            <xsl:matching-substring>
                                <xsl:value-of select="regex-group(1)"/><xsl:text>-Q</xsl:text><xsl:value-of select="regex-group(4)"/>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
<!--
                                <xsl:analyze-string select="$date" regex="(([0-9]{{4}})-([0-9]{{4}}))">
                                    <xsl:matching-substring>
                                        <xsl:value-of select="regex-group(2)"/>-<xsl:value-of select="regex-group(3)"/>
                                    </xsl:matching-substring>

                                    <xsl:non-matching-substring>
-->
                                        <xsl:value-of select="$date"/>
<!--
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
-->
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:template name="resource-refperiod">
        <xsl:param name="date"/>

        <xsl:attribute name="rdf:resource">
            <xsl:analyze-string select="$date" regex="(([0-9]{{4}})|([1-9][0-9]{{3,}})+)(-?Q([1-4]))" flags="i">
                <xsl:matching-substring>
                    <xsl:text>http://reference.data.gov.uk/id/quarter/</xsl:text><xsl:value-of select="regex-group(1)"/><xsl:text>-Q</xsl:text><xsl:value-of select="regex-group(5)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:analyze-string select="$date" regex="(([0-9]{{4}})|([1-9][0-9]{{3,}})+)">
                        <xsl:matching-substring>
                           <xsl:text>http://reference.data.gov.uk/id/year/</xsl:text><xsl:value-of select="regex-group(1)"/>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:analyze-string select="$date" regex="FY([0-9]{{2}})" flags="i">
                                <xsl:matching-substring>
                                   <xsl:text>http://reference.data.gov.uk/id/year/20</xsl:text><xsl:value-of select="regex-group(1)"/>
                                </xsl:matching-substring>

                                <xsl:non-matching-substring>
<!--
                                    <xsl:analyze-string select="$date" regex="([0-9]{{4}})-([0-9]{{4}})">
                                        <xsl:matching-substring>
                                            <xsl:value-of select="regex-group(1)"/>-<xsl:value-of select="regex-group(2)"/>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
-->
                                           <xsl:text>http://reference.data.gov.uk/id/year/</xsl:text><xsl:value-of select="$date"/>
<!--
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
-->
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="datatype-dateTime">
        <xsl:attribute name="rdf:datatype">
            <xsl:text>http://www.w3.org/2001/XMLSchema#dateTime</xsl:text>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="datatype-date">
        <xsl:attribute name="rdf:datatype">
            <xsl:text>http://www.w3.org/2001/XMLSchema#date</xsl:text>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="datatype-xsd-decimal">
        <xsl:attribute name="rdf:datatype">
            <xsl:text>http://www.w3.org/2001/XMLSchema#decimal</xsl:text>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="datatype-dbo-usd">
        <xsl:attribute name="rdf:datatype">
            <xsl:text>http://dbpedia.org/resource/United_States_dollar</xsl:text>
        </xsl:attribute>
    </xsl:template>

    <xsl:template name="rdfDatatypeXSD">
        <xsl:param name="type"/>

        <xsl:if test="$type != ''">
            <xsl:attribute name="rdf:datatype"><xsl:text>http://www.w3.org/2001/XMLSchema#</xsl:text><xsl:value-of select="$type"/></xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:function name="wbldfn:detectDatatype">
        <xsl:param name="value"/>

        <xsl:choose>
            <xsl:when test="string($value) castable as xs:decimal">
                <xsl:value-of select="'decimal'"/>
            </xsl:when>
            <xsl:when test="string($value) castable as xs:double">
                <xsl:value-of select="'double'"/>
            </xsl:when>
            <xsl:when test="string($value) castable as xs:float">
                <xsl:value-of select="'float'"/>
            </xsl:when>
            <xsl:otherwise>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template name="provenance">
        <xsl:param name="date"/>
        <xsl:param name="dataSource"/>
        <dcterms:created rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">2012-02-29T00:00:00Z</dcterms:created>

        <dcterms:issued>
            <xsl:call-template name="datatype-dateTime"/>
            <xsl:value-of select="$date"/>
        </dcterms:issued>
        <dcterms:source rdf:resource="{$dataSource}"/>
        <dcterms:creator rdf:resource="http://csarven.ca/#i"/>
        <dcterms:license rdf:resource="http://creativecommons.org/publicdomain/zero/1.0/"/>
    </xsl:template>
</xsl:stylesheet>
