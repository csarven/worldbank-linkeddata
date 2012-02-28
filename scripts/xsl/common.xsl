<!--
    Author: Sarven Capadisli <info@csarven.ca>
    Author URL: http://csarven.ca/#i
-->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:dcterms="http://purl.org/dc/terms/">

    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

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
