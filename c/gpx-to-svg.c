/************************************************************************/
/*    gpx-to-svg.c                                                      */
/*    simple tool to read GPX track data,                               */
/*    convert to SVG path data and place on a map                       */
/*    compile:                                                          */
/*       gcc -Wall -lxml2 -I /usr/include/libxml2 -o c/xpath c/xpath.c  */
/*    run:                                                              */
/*       c/xpath svg/italy-map.svg gpx/train-track.gpx                  */
/*    author:                                                           */
/*       info@opendgps.de                                               */
/************************************************************************/

#include <stdio.h>
#include <string.h>
#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>

// svg width/height in px 
#define X_WIDTH         19900.0
#define Y_WIDTH         13500.0

// lat/lon of x:y = 0:0 
#define LATITUDE_ROOT   46.9877911
#define LONGITUDE_ROOT  7.131336

// string buffer to replace the value of d-attribute <p … d="alt"/>
char *pathString[64000];

// read and parse XML document by file
xmlDocPtr GetXMLDoc(char* xmlFileName) {
    xmlDocPtr xmlDoc = xmlParseFile(xmlFileName);
    if (xmlDoc == NULL ) {
        return NULL;
    }
    return xmlDoc;
}

// apply XPath to xmlDoc
xmlXPathObjectPtr GetNodeSet(const xmlDocPtr xmlDoc, xmlChar* xPath) {
    xmlXPathContextPtr xpathContext = NULL;
    xmlXPathObjectPtr xmlXpathResult = NULL;
    xpathContext = xmlXPathNewContext(xmlDoc);
    if (xpathContext == NULL) return NULL;
    xmlXpathResult = xmlXPathEvalExpression(xPath, xpathContext);
    xmlXPathFreeContext(xpathContext);
    if (xmlXpathResult == NULL) return NULL;
    if (xmlXPathNodeSetIsEmpty(xmlXpathResult->nodesetval)) {
        xmlXPathFreeObject(xmlXpathResult);
        return NULL;
    }
    return xmlXpathResult;
}

// map value of latitude to svg coord
double mappedLatitude(double lat) {
	return (((180 - (lat + 90)) / 180) * Y_WIDTH);
}

// map value of longitude to svg coord
double mappedLongitude(double lon) {
	if (lon < 0) 
		return (((180 + (180 - abs(lon))) / 360) * X_WIDTH); 
	else 
		return ((lon / 360) * X_WIDTH);
};


int setNewAttributeForPath(char* gpxFile) {
	xmlDocPtr gpxDoc;
	xmlChar *latId, *lonId;
	latId = (xmlChar *) "lat";
	lonId = (xmlChar *) "lon";
	char *stringBuffer[30];
	xmlChar *xpath = (xmlChar*) "//*[name() = 'trkpt']";
	xmlNodeSetPtr nodeset;
	xmlXPathObjectPtr result;
	double lastMappedLatitude,lastMappedLongitude;
	double currentMappedLatitude,currentMappedLongitude;
	double mappedLatRoot,mappedLonRoot;
	mappedLatRoot = mappedLatitude(LATITUDE_ROOT);
	mappedLonRoot = mappedLongitude(LONGITUDE_ROOT);
	gpxDoc = GetXMLDoc(gpxFile);
	result = GetNodeSet (gpxDoc, xpath);
	if (result) {
		nodeset = result->nodesetval;
		lastMappedLatitude = mappedLatitude(atof( ( const char * ) xmlGetProp(nodeset->nodeTab[0], latId)));
		lastMappedLongitude = mappedLongitude(atof( ( const char * ) xmlGetProp(nodeset->nodeTab[0], lonId)));
		sprintf( ( char * ) stringBuffer, "M%f,%f", (lastMappedLongitude - mappedLonRoot),(lastMappedLatitude - mappedLatRoot));
		strcat( ( char * ) pathString, ( const char * ) stringBuffer);
		for (int nodeNr=1; nodeNr < nodeset->nodeNr; nodeNr++) {
			currentMappedLatitude = mappedLatitude(atof( ( const char * ) xmlGetProp(nodeset->nodeTab[nodeNr], latId)));
			currentMappedLongitude = mappedLongitude(atof( ( const char * ) xmlGetProp(nodeset->nodeTab[nodeNr], lonId)));
			sprintf( ( char * ) stringBuffer, "l%f,%f", (currentMappedLongitude - lastMappedLongitude),(currentMappedLatitude - lastMappedLatitude));
			strcat( ( char * ) pathString, ( const char * ) stringBuffer);
			lastMappedLatitude = currentMappedLatitude;
			lastMappedLongitude = currentMappedLongitude;
		}
		xmlXPathFreeObject (result);
	}
	xmlFreeDoc(gpxDoc);
	xmlCleanupParser();
	return (1);
}


int main(int argc, char **argv) {
	char *svgFileName, *gpxFileName;
	const xmlChar *attributeName = (const xmlChar *) "d";
	xmlNodePtr svgNode = NULL;
	xmlDocPtr svgDoc = NULL;
	xmlNodeSetPtr svgNodeSet = NULL;
	xmlXPathObjectPtr svgXpathResult = NULL;
	svgFileName = argv[1];
	gpxFileName = argv[2];
	svgDoc = GetXMLDoc(svgFileName);
	xmlXPathContextPtr context = xmlXPathNewContext(svgDoc);
	xmlXPathRegisterNs(context,  BAD_CAST "svg", BAD_CAST "http://www.w3.org/2000/svg");
	xmlChar *xpath = (xmlChar*) "//*[name() = 'path'][@*[name() = 'id'] = 'odgps-insert']";
	svgXpathResult = GetNodeSet(svgDoc, xpath);
	setNewAttributeForPath(gpxFileName);
	if (svgXpathResult && svgXpathResult->nodesetval) {
		svgNodeSet = svgXpathResult->nodesetval;
		for (int svgNodeSetValue = 0; svgNodeSetValue < svgNodeSet->nodeNr; svgNodeSetValue++) {
			if (svgNodeSet->nodeTab) {
				svgNode = svgNodeSet->nodeTab[svgNodeSetValue];
				if (svgNode) {
					if (xmlGetProp(svgNode, attributeName)) {
						xmlSetProp(svgNode, BAD_CAST attributeName, (const xmlChar *) pathString);
					}
				}
			}
		}
	}
	xmlSaveFormatFile (svgFileName, svgDoc, 1);
	xmlFreeDoc(svgDoc);
	return 1;
}
