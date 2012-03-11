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
    xmlns:dbp="http://dbpedia.org/property/"
    xmlns:dbo="http://dbpedia.org/ontology/"
    xmlns:dbr="http://dbpedia.org/resource/"
    xmlns:qb="http://purl.org/linked-data/cube#"
    xmlns:sdmx-dimension="http://purl.org/linked-data/sdmx/2009/dimension#"
    xmlns:wb="http://search.worldbank.org/ns/1.0"
    xmlns:wb-a="http://www.worldbank.org"
    xmlns:wbld="http://worldbank.270a.info/"
    xmlns:property="http://worldbank.270a.info/property/">

    <xsl:import href="common.xsl"/>
    <xsl:output encoding="utf-8" indent="yes" method="xml" omit-xml-declaration="no"/>

    <xsl:param name="wbapi_lang"/>
    <xsl:param name="pathToCountries"/>
    <xsl:param name="pathToLendingTypes"/>
    <xsl:param name="pathToRegionsExtra"/>

    <xsl:variable name="wbld">http://worldbank.270a.info/</xsl:variable>

    <xsl:template match="/">
        <rdf:RDF>
        <xsl:call-template name="projectsObservations"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template name="projectsObservations">
        <xsl:variable name="currentDateTime" select="wbldfn:now()"/>

        <rdf:Description rdf:about="{$wbld}classification/project">
          <!-- <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#ConceptScheme"/> -->
            <rdf:type rdf:resource="http://purl.org/linked-data/sdmx#CodeList"/>
            <skos:prefLabel xml:lang="en">Code list for World Bank Projects and Operations</skos:prefLabel>
        </rdf:Description>

        <xsl:for-each select="projects/project">
            <xsl:variable name="projectId" select="normalize-space(@id)"/>

            <rdf:Description rdf:about="{$wbld}classification/project">
                <skos:hasTopConcept rdf:resource="{$wbld}classification/project/{$projectId}"/>
            </rdf:Description>

            <rdf:Description rdf:about="{$wbld}classification/project/{$projectId}">
                <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
                <rdf:type rdf:resource="http://dbpedia.org/ontology/Project"/>

                <skos:inScheme rdf:resource="{$wbld}classification/project"/>
                <skos:topConceptOf rdf:resource="{$wbld}classification/project"/>

                <xsl:for-each select="node()">
                    <!--
                        TODO: Revisit. Not sure how to catch the 'useful' linkable stuff better instead of cherry picking most common ones. Perhaps that's not too bad. There are some duplicates also where they could go out to meta.ttl
                    -->
                    <xsl:variable name="nodeName" select="wbldfn:canonical-term(wbldfn:safe-term(replace(name(), 'wb:projects.', '')))"/>

                    <xsl:if test="wbldfn:usable-term($nodeName)">
                        <xsl:choose>
                            <xsl:when test="$nodeName = 'id'">
                                <skos:notation><xsl:value-of select="./text()"/></skos:notation>
                            </xsl:when>

                            <xsl:when test="$nodeName = 'project-name'">
    <!--                            <property:project-name><xsl:value-of select="./text()"/></property:project-name> -->
                                <skos:prefLabel xml:lang="{$wbapi_lang}"><xsl:value-of select="./text()"/></skos:prefLabel>
                            </xsl:when>

                            <xsl:when test="$nodeName = 'financier'">
    <!--                            <property:financier><xsl:value-of select="./text()"/></property:financier> -->
                                <property:loan-number rdf:resource="{$wbld}loan-number/{normalize-space(./text())}"/>
                            </xsl:when>

                            <!-- These match up with strings -->
                            <!--
                                TODO: Some of the countries don't match e.g., "Yemen, Rep." in countries.xml and "Yemen, People's Democratic Republic of" or "Yemen, Republic of" in ax5s-vav5.xml.
                                XXX: Currently using sdmx-dimension:refArea "Yemen, Republic of". Could use property:country_beneficiary "Yemen, Republic of". Not sure about it right now.
                            -->
                            <xsl:when test="$nodeName = 'country'">
                                <xsl:variable name="countryString" select="./text()"/>

                                <xsl:element name="property:country">
                                    <xsl:choose>
                                        <xsl:when test="document($pathToCountries)/wb-a:countries/wb-a:country[wb-a:name/text() = $countryString]">
                                            <xsl:attribute name="rdf:resource">
                                                <xsl:value-of select="$wbld"/><xsl:text>classification/country/</xsl:text><xsl:value-of select="document($pathToCountries)/wb-a:countries/wb-a:country[wb-a:name/text() = $countryString]/wb-a:iso2Code/normalize-space(text())"/>
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

                                <xsl:element name="property:region">
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

                            <xsl:when test="$nodeName = 'url'">
                                <foaf:page rdf:resource="{./text()}"/>
                            </xsl:when>

                            <xsl:when test="$nodeName = 'listing-relative-url'">
                                <property:listing-relative-url rdf:resource="http://www.worldbank.org/projects/{$projectId}{./text()}??lang=en"/>
                            </xsl:when>

                            <xsl:when test="$nodeName = 'lendprojectcost'
                                            or $nodeName = 'grantamt'
                                            or $nodeName = 'ibrdcommamt'
                                            or $nodeName = 'idacommamt'
                                            or $nodeName = 'totalamt'
                                            or $nodeName = 'totalcommamt'
                                            ">
                                <xsl:element name="property:{$nodeName}">
                                    <xsl:call-template name="datatype-dbo-usd"/>
                                    <xsl:value-of select="replace(./text(), ',', '')"/>
                                </xsl:element>
                            </xsl:when>

                            <xsl:when test="$nodeName = 'timestamp'
                                            or $nodeName= 'board-approval-date'
                                            or $nodeName = 'closing-date'
                                            ">
                                <xsl:element name="property:{$nodeName}">
                                    <xsl:call-template name="datatype-date"/>
                                    <xsl:value-of select="normalize-space(./text())"/>
                                </xsl:element>
                            </xsl:when>

                            <xsl:when test="$nodeName = 'board-approval-year'">
                                <xsl:element name="property:{$nodeName}">
                                    <xsl:call-template name="resource-refperiod">
                                        <xsl:with-param name="date" select="normalize-space(./text())"/>
                                    </xsl:call-template>
                                </xsl:element>
                            </xsl:when>

                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="$nodeName = ''">
                                        <xsl:element name="property:external">
                                            <xsl:value-of select="./text()"/>
                                        </xsl:element>
                                    </xsl:when>

                                    <xsl:otherwise>
                                        <!-- TODO: Crazy bnode stuff or URIs per child node -->
                                        <xsl:choose>
                                            <xsl:when test="count(child::*) > 0">
                                                <xsl:element name="property:{$nodeName}">
                                                    <xsl:variable name="position" select="position()"/>
    <!-- <xsl:message><xsl:text>2: </xsl:text><xsl:value-of select="$projectId"/><xsl:text> </xsl:text><xsl:value-of select="$position"/><xsl:text> </xsl:text><xsl:value-of select="name()"/></xsl:message> -->
                                                    <xsl:attribute name="rdf:nodeID">
                                                        <xsl:value-of select="$projectId"/><xsl:value-of select="$nodeName"/><xsl:value-of select="$position"/>
                                                    </xsl:attribute>
                                                </xsl:element>
                                            </xsl:when>

                                            <!-- TODO:
                                                This catches wb:projects.countryname:
                                                It should be moved out to its own post-processing XSLT where it creates triples like:
                                                http://worldbank.270a.info/classification/country/CD
                                                    dbp:conventionalLongName wb:projects.countryname
                                            -->
                                            <xsl:otherwise>

    <!-- <property:XXX><xsl:value-of select="name()"/> <xsl:value-of select="./text()"/></property:XXX> -->

                                                <xsl:if test="$nodeName != ''">
                                                    <xsl:element name="property:{$nodeName}">
                                                        <xsl:value-of select="./text()"/>
                                                    </xsl:element>
                                                </xsl:if>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
            </rdf:Description>
        </xsl:for-each>

        <xsl:for-each select="projects/project/wb:projects.financier">
            <!-- XXX: This is a bit dirty i.e., check for substring in lendingTypes file instead -->
            <xsl:variable name="lendingTypeString" select="replace(./text(), '(IBRD|Blend|IDA|Not classified).*', '$1')"/>
                <xsl:choose>
                    <xsl:when test="document($pathToLendingTypes)/rdf:RDF/rdf:Description[skos:prefLabel/text() = $lendingTypeString]">
                        <rdf:Description rdf:about="{$wbld}loan-number/{normalize-space(./text())}">
                            <rdf:type>
                                <xsl:attribute name="rdf:resource">
                                    <xsl:value-of select="document($pathToLendingTypes)/rdf:RDF/rdf:Description[skos:prefLabel/text() = $lendingTypeString]/@rdf:about"/>
                                </xsl:attribute>
                            </rdf:type>
                        </rdf:Description>
                    </xsl:when>
                </xsl:choose>
        </xsl:for-each>

<!--
projectid wb:projects.mjsector_and_mdk     bnode_projectid_Node#OfProperty

bnode_projectid+Node#ofProperty
<wb:projects.mjsector_and_mdk.name>Education</wb:projects.mjsector_and_mdk.name>

<xsl:value-of select="replace(name(), 'wb:projects.', '')"/>

-->

        <!-- Takes care of the bnodes -->
        <xsl:for-each select="projects/project">
            <xsl:variable name="projectId" select="normalize-space(@id)"/>
            <xsl:for-each select="node()">
                <xsl:if test="count(child::*) > 0">
                    <xsl:variable name="position" select="position()"/>
                    <rdf:Description rdf:nodeID="{$projectId}{replace(name(), 'wb:projects.', '')}{$position}">
                        <xsl:for-each select="child::*">
    <!-- <xsl:message><xsl:value-of select="name()"/></xsl:message> -->
                            <xsl:variable name="nodeName" select="wbldfn:canonical-term(wbldfn:safe-term(replace(name(), 'wb:projects.', '')))"/>

                            <xsl:if test="wbldfn:usable-term($nodeName)">
                                <xsl:choose>
                                    <xsl:when test="$nodeName = 'date'">
                                        <xsl:element name="dcterms:date">
                                            <xsl:call-template name="datatype-date"/>
                                            <xsl:value-of select="wbldfn:get-date(./text())"/>
                                        </xsl:element>
                                    </xsl:when>
                                    <xsl:when test="$nodeName = 'description'">
                                        <dcterms:description xml:lang="en"><xsl:value-of select="normalize-space(./text())"/></dcterms:description>
                                    </xsl:when>
                                    <xsl:when test="$nodeName = 'url'">
                                        <foaf:page rdf:resource="{normalize-space(./text())}"/>
                                    </xsl:when>
                                    <xsl:when test="$nodeName = 'id'">
                                        <dcterms:identifier><xsl:value-of select="normalize-space(./text())"/></dcterms:identifier>
                                    </xsl:when>
                                    <xsl:when test="$nodeName = 'type'">
                                        <rdf:type rdf:resource="{$wbld}classification/document/{wbldfn:safe-term(./text())}"/>
                                    </xsl:when>

                                    <xsl:otherwise>
                                        <xsl:element name="property:{$nodeName}">
                                            <xsl:value-of select="normalize-space(text())"/>
                                        </xsl:element>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                         </xsl:for-each>
                    </rdf:Description>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
