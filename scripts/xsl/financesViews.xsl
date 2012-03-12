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
    xmlns:wb="http://www.worldbank.org"
    xmlns:wbld="http://worldbank.270a.info/"
    xmlns:property="http://worldbank.270a.info/property/">

    <xsl:import href="common.xsl"/>
    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="wbapi_lang"/>
    <xsl:param name="pathToMeta"/>
    <xsl:variable name="wbld">http://worldbank.270a.info/</xsl:variable>

    <xsl:template match="/">
        <rdf:RDF>
        <xsl:call-template name="finances-views"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="finances-views">
        <!-- FIXME: This is slightly hacky. I'm tired. Use finances-views.extra.rdf when not tired -->
        <xsl:variable name="currentDateTime" select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]Z')"/>

        <xsl:for-each select="response/view">
            <xsl:variable name="financeDataset">
                <xsl:text>http://worldbank.270a.info/dataset/world-bank-finances/</xsl:text><xsl:value-of select="@id"/>
            </xsl:variable>
            <xsl:variable name="datasetName">
                <xsl:value-of select="document($pathToMeta)/rdf:RDF/rdf:Description[@rdf:about = $financeDataset]"/>
            </xsl:variable>

            <xsl:if test="$datasetName != '' or @id = 'wc6g-9zmq'">
                <xsl:variable name="viewResource">
                    <xsl:choose>
                        <xsl:when test="@id = 'wc6g-9zmq'">
                            <xsl:text>http://worldbank.270a.info/classification/finance</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>http://worldbank.270a.info/dataset/world-bank-finances/</xsl:text><xsl:value-of select="@id"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <rdf:Description rdf:about="{$viewResource}">
                    <xsl:if test="@id = 'wc6g-9zmq'">
                        <rdf:type rdf:resource="http://purl.org/linked-data/sdmx#CodeList"/>
                    </xsl:if>

                    <dcterms:identifier><xsl:value-of select="@id"/></dcterms:identifier>

                    <!-- XXX: Probably need to grab everyting instead of cherry picking -->

                    <!-- XXX: JSON format for this data has attribution and attribution link but the XML doesn't -->

                    <xsl:if test="@name != ''">
                    <rdfs:label xml:lang="{$wbapi_lang}"><xsl:value-of select="normalize-space(@name)"/></rdfs:label>
                    </xsl:if>

                    <xsl:if test="@description != ''">
                    <dcterms:description xml:lang="{$wbapi_lang}"><xsl:value-of select="normalize-space(@description)"/></dcterms:description>
                    </xsl:if>

                    <xsl:if test="@category != ''">
                    <skos:scopeNote xml:lang="{$wbapi_lang}"><xsl:value-of select="normalize-space(@category)"/></skos:scopeNote>
                    </xsl:if>

<!--
                    <xsl:if test="@publicationStage != ''">
                    <property:publication-stage xml:lang="{$wbapi_lang}"><xsl:value-of select="@publicationStage"/></property:publication-stage>
                    </xsl:if>
-->

                    <!-- TODO: Convert from UNIX to ISO timestamps -->
                    <xsl:if test="@createdAt != ''">
                    <dcterms:created><xsl:value-of select="@createdAt"/></dcterms:created>
                    </xsl:if>

                    <xsl:if test="@publicationDate != ''">
                    <dcterms:available><xsl:value-of select="@publicationDate"/></dcterms:available>
                    </xsl:if>

                    <!-- XXX: This is probably more 'useful' than @viewLastModified -->
                    <xsl:if test="./metadata/custom_fields/Data-As-Of/@Data-As-Of != ''">
                        <xsl:element name="dcterms:modified">
                            <xsl:call-template name="datatype-date"/>
                            <xsl:value-of select="wbldfn:get-date(./metadata/custom_fields/Data-As-Of/@Data-As-Of)"/>
                        </xsl:element>
                    </xsl:if>

                    <!-- XXX: I had to dig out the proper URL to the definition because the @filename URL doesn't resolve. The actual file is sent by content-disposition (an attachment) by the API via https://finances.worldbank.org/api/views/XXXX-XXXX/rows.pdf?accessType=DOWNLOAD -->
                    <xsl:if test="./metadata/attachments/item/@blobId != ''">
                    <rdfs:isDefinedBy rdf:resource="http://finances.worldbank.org/api/assets/{normalize-space(./metadata/attachments/item/@blobId)}"/>
                    </xsl:if>
                </rdf:Description>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
<!--
    <xsl:template name="convertUnixTimeToISO8601">
        <xsl:param name="unixTime"/>
        <xsl:value-of select="'1970-01-01T00:00:00' + $unixTime * days-from-duration('PT0.001S')"/>
    </xsl:template>
-->
</xsl:stylesheet>
