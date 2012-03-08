/*
    Author: Sarven Capadisli <info@csarven.ca>
    Author URL: http://csarven.ca/#i

    Notes: WorldBank API XML + XSL to RDF

        I now think that the Java approach here is overkill.
        There is better performance from command-line saxonb.
        Hence, I commented out the XSLT, but you might want to use it yourself.
        At this point, the purpose of this file is to GET the data
          by grabbing certain node values in XML.
        Going forward, this approach here will be deprecated and succeeded with
          command-line tools e.g., rapper, xmllint, saxonb, shell scripts for
          better performance.
  */

import java.net.*;
import java.io.*;
import java.util.*;
import java.sql.Timestamp;

import javax.xml.transform.ErrorListener;
import javax.xml.transform.sax.*;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;

import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import org.apache.http.client.ResponseHandler;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;

public class WorldBank extends DefaultHandler {
    String WBAPI = "http://api.worldbank.org/";
    String WBFAPI = "http://finances.worldbank.org/api/";
    String[] WBAPILanguages = { "en"/*, "ar", "en", "es", "fr"*/ };
    String[] WBAPICalls = { 
        "sources",
        "topics",
        "regions",
        "incomeLevels",
        "lendingTypes",
        "countries",
        "indicators"
    };
    String WBAPIFormat = "format=xml";
    String WBAPIPerPage = "per_page=20000";

    String WBAPICall;

    String pathToCountries = "/var/www/worldbank.270a.info/data/indicators/en/countries.xml";
    String pathToLendingTypes = "/var/www/worldbank.270a.info/data/indicators/en/lendingTypes.xml";
    String pathToCurrencies = "/var/www/worldbank.270a.info/data/currencies.rdf";
    String pathToRegionsExtra = "/var/www/worldbank.270a.info/data/regions-extra.rdf";
    String pathToMeta = "/var/www/worldbank.270a.info/data/meta.rdf";

    String inXML;
    String inXSL;
    String outFile;
    Date date;
    Timestamp now;

    ArrayList WBIndicators = new ArrayList();

    ArrayList WBFinancesViews = new ArrayList();

    boolean status;

    public static void main(String[] args) {
        Properties p = System.getProperties();
        p.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl");

        WorldBank t = new WorldBank();

        for (int j = 0; j < t.WBAPILanguages.length; j++) {
            t.status = new File("../data/indicators/" + t.WBAPILanguages[j] + "/indicator").mkdirs();
        }

        t.status = new File("../data/finances/finance").mkdirs();

        //TODO: Separate these GETs into independent 

        //Concepts used in World Development Indicators. See WBAPICalls for the list
//        t.buildWorldBankMetadata();

        //World Development Indicators. ~5000 indicators. Takes a while to GET them
        WorldBankIndicatorsObservations io = new WorldBankIndicatorsObservations();
        io.buildWorldBankIndicatorsObservations();

        //World Bank Finances Datasets list and dictionary
//        t.buildWorldBankFinancesMetadata();

        //XXX: This gets all datasets that's in the World Bank Finances views file, however, it is probably not worth it because it contains views like filters, charts that gathers its data from other datasets any way. I opted for a curated list of Financial datasets (see README on how I did it) because it contains the essential list and a few other datasets that's actually excluded in this file.
        //World Bank Finances observations
//        WorldBankFinancesObservations fo = new WorldBankFinancesObservations();
//        fo.buildWorldBankFinancesObservations();
    }


    public void buildWorldBankMetadata() {
        for (int i = 0; i < this.WBAPICalls.length; i++) {
            for (int j = 0; j < this.WBAPILanguages.length; j++) {
                WBAPICall = this.WBAPI + this.WBAPILanguages[j] + "/" + this.WBAPICalls[i] + "?" + this.WBAPIFormat + "&" + this.WBAPIPerPage;
                inXML = "../data/indicators/" + this.WBAPILanguages[j] + "/" + this.WBAPICalls[i] + ".xml";
                inXSL = "xsl/" + this.WBAPICalls[i] + ".xsl";
                outFile = "../data/indicators/" + this.WBAPILanguages[j] + "/" + this.WBAPICalls[i] + ".rdf";

                try {
                    date = new Date();
                    now = new Timestamp(date.getTime());

                    System.out.println("[" + now + "] World Bank API call: " + this.WBAPICall);
                    this.transform(this.WBAPICall, inXML, inXSL, outFile, WBAPILanguages[j]);
                } catch(TransformerConfigurationException e) {
                    System.err.println("Invalid factory configuration");
                    System.err.println(e);
                } catch(TransformerException e) {
                    System.err.println("Error during transformation");
                    System.err.println(e);
                }
            }
        }
    }


    public void buildWorldBankFinancesMetadata() {
        WBAPICall = this.WBFAPI + "views.xml";
        inXML = "../data/finances/views.xml";
        inXSL = "xsl/financesViews.xsl";
        outFile = "../data/finances/views.rdf";

        try {
            date = new Date();
            now = new Timestamp(date.getTime());

            System.out.println("[" + now + "] World Bank Finances API call: " + WBAPICall);
            this.transform(WBAPICall, inXML, inXSL, outFile, "en");
        } catch(TransformerConfigurationException e) {
            System.err.println("Invalid factory configuration");
            System.err.println(e);
        } catch(TransformerException e) {
            System.err.println("Error during transformation");
            System.err.println(e);
        }
    }


    public void parseDocument(String file) {
        SAXParserFactory spf = SAXParserFactory.newInstance();
        try {
            SAXParser sp = spf.newSAXParser();
            sp.parse(file, this);
        } catch(SAXException se) {
            se.printStackTrace();
        } catch(ParserConfigurationException pce) {
            pce.printStackTrace();
        } catch (IOException ie) {
            ie.printStackTrace();
        }
    }


    public void transform(String WBAPICall, String inXML, String inXSL, String outFile, String lang)
        throws TransformerConfigurationException, TransformerException {
        TransformerFactory factory = TransformerFactory.newInstance();
        SAXTransformerFactory saxFactory = (SAXTransformerFactory) factory;

//        factory.setNamespaceAware(true);

//XXX: Commented out because I find saxonb-xslt from command-line much faster than doing it this way
//        StreamSource xslStream = new StreamSource(new File(inXSL));
//        Transformer transformer = saxFactory.newTransformer(xslStream);
//        transformer.setErrorListener(new MyErrorListener());

        try {
            long startTime = System.currentTimeMillis();

            URL url = new URL(WBAPICall);
            url.openConnection();
            InputStream reader = url.openStream();

            FileOutputStream writer = new FileOutputStream(inXML);
            byte[] buffer = new byte[153600];
            int totalBytesRead = 0;
            int bytesRead = 0;

            while ((bytesRead = reader.read(buffer)) > 0) {
                writer.write(buffer, 0, bytesRead);
                buffer = new byte[153600];
                totalBytesRead += bytesRead;
            }

//            long endTime = System.currentTimeMillis();

            //        System.out.println("Done. " + (new Integer(totalBytesRead).toString()) + " bytes read (" + (new Long(endTime - startTime).toString()) + " millseconds).");
            writer.close();
            reader.close();

//XXX: Commented out because I find saxonb-xslt from command-line much faster than doing it this way
//            StreamSource in = new StreamSource(new File(inXML));
//            StreamResult out = new StreamResult(new File(outFile));
//            transformer.setParameter("wbapi_lang", lang);
//            transformer.setParameter("pathToCountries", this.pathToCountries);
//            transformer.setParameter("pathToLendingTypes", this.pathToLendingTypes);
//            transformer.setParameter("pathToCurrencies", this.pathToLendingTypes);
//            transformer.setParameter("pathToRegionsExtra", this.pathToRegionsExtra);
//            transformer.transform(in, out);
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}


class WorldBankIndicatorsObservations extends WorldBank {
    public void buildWorldBankIndicatorsObservations() {
        super.parseDocument("../data/indicators/en/indicators.xml");

        //TODO: Perhaps this.WBIndicators?
        Object WBI[] = this.WBIndicators.toArray();


        String id;

        //FIXME: I use the list inside asList() as a workaround to revisit indicators which were not somehow retrieved the first time around.
//        List<String> codes = Arrays.asList();

        for (int i = 0; i < WBI.length; i++) {
            id = WBI[i].toString().trim();

//            if (codes.contains(id)) {
//                System.out.println("Skipping " + id);
//            } else {
                for (int j = 0; j < this.WBAPILanguages.length; j++) {
                    WBAPICall = this.WBAPI + this.WBAPILanguages[j] + "/countries/all/indicators/" + id + "?" + this.WBAPIFormat + "&" + WBAPIPerPage;
                    inXML = "../data/indicators/" + this.WBAPILanguages[j] + "/indicator/" + id + ".xml";
                    inXSL = "xsl/indicatorsObservations.xsl";
                    outFile = "../data/indicators/" + this.WBAPILanguages[j] + "/indicator/" + id +".rdf";

                    try {
                        date = new Date();
                        now = new Timestamp(date.getTime());

                        System.out.println("[" + now + "] World Bank API call: " + this.WBAPICall);
                        this.transform(this.WBAPICall, inXML, inXSL, outFile, WBAPILanguages[j]);
                    } catch(TransformerConfigurationException e) {
                        System.err.println("Invalid factory configuration");
                        System.err.println(e);
                    } catch(TransformerException e) {
                        System.err.println("Error during transformation");
                        System.err.println(e);
                    }
                }
//            }
        }
    }


    public void startElement(String uri, String localName, String qName, Attributes attributes)
        throws SAXException {

        if (qName.equalsIgnoreCase("wb:indicator")) {
            this.WBIndicators.add(attributes.getValue("id"));
        }
    }
}


class WorldBankFinancesObservations extends WorldBank {
    public void buildWorldBankFinancesObservations() {
        super.parseDocument("../data/finances/views.xml");

        Object WBF[] = this.WBFinancesViews.toArray();
        String id;

        for (int i = 0; i < WBF.length; i++) {
            id = WBF[i].toString().trim();

            WBAPICall = this.WBFAPI + "views/" + id + "/rows.xml";
            inXML = "../data/finances/finance/" + id + ".xml";
            inXSL = "xsl/financesObservations.xsl";
            outFile = "../data/finances/finance/" + id +".rdf";

            try {
                date = new Date();
                now = new Timestamp(date.getTime());

                System.out.println("[" + now + "] World Bank Finances API call: " + this.WBAPICall);
                this.transform(this.WBAPICall, inXML, inXSL, outFile, "en");
            } catch(TransformerConfigurationException e) {
                System.err.println("Invalid factory configuration");
                System.err.println(e);
            } catch(TransformerException e) {
                System.err.println("Error during transformation");
                System.err.println(e);
            }
        }
    }


    public void startElement(String uri, String localName, String qName, Attributes attributes)
        throws SAXException {

        if (qName.equalsIgnoreCase("view")) {
            this.WBFinancesViews.add(attributes.getValue("id"));
        }
    }
}



class MyErrorListener implements ErrorListener {
    public void warning(TransformerException e)
        throws TransformerException {
        show("Warning",e);
        throw(e);
    }
    public void error(TransformerException e)
        throws TransformerException {
        show("Error",e);
        throw(e);
    }
    public void fatalError(TransformerException e)
        throws TransformerException {
        show("Fatal Error",e);
        throw(e);
    }
    private void show(String type,TransformerException e) {
        System.out.println(type + ": " + e.getMessage());
        if(e.getLocationAsString() != null) {
            System.out.println(e.getLocationAsString());
        }
    }
}
