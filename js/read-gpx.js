var trackPoints;
var settings = {
	xWidth : 19900.0,
	yWidth : 13500.0,
	latRoot : 46.9877911,
	lonRoot : 7.131336
}

var readAndParseGPX = function() {
	// old fashion xmlHttpRequest
	if (window.XMLHttpRequest) {
	   xhttp = new XMLHttpRequest();
	} else {    // IE 5/6
	   xhttp = new ActiveXObject("Microsoft.XMLHTTP");
	}
	xhttp.overrideMimeType('text/xml');
	xhttp.open("GET", "../gpx/train-track.gpx", false);
	xhttp.send(null);
	xmlDoc = xhttp.responseXML;
	trackPoints = xmlDoc.getElementsByTagName("trkpt")
}();

var insertNewPath = function() {
	var pathString = "M";
	var mappedLonRoot = 0.0;
	var mappedLatRoot = 0.0;
	var mappedLatitude = function(lat) {
		return ((180 - (lat + 90)) / 180) * settings.yWidth;
	};
	var mappedLongitude = function(lon) {
		if (lon < 0) 
			return (((180 + (180 - Math.abs(lon))) / 360) * settings.xWidth); 
		else 
			return ((lon / 360) * settings.xWidth);
	};
	
	mappedLonRoot = mappedLongitude(settings.lonRoot);
	mappedLatRoot = mappedLatitude(settings.latRoot);
	lastMappedLatitude = mappedLatitude(parseFloat(trackPoints[0].attributes['lat'].value));
	lastMappedLongitude = mappedLongitude(parseFloat(trackPoints[0].attributes['lon'].value));
	
	pathString += (lastMappedLongitude - mappedLonRoot) + "," + (lastMappedLatitude - mappedLatRoot);

	for ( i = 1; i < trackPoints.length; i++ ) { 
		currentMappedLatitude = mappedLatitude(parseFloat(trackPoints[i].attributes['lat'].value));
		currentMappedLongitude = mappedLongitude(parseFloat(trackPoints[i].attributes['lon'].value));
		pathString += "l" + (currentMappedLongitude - lastMappedLongitude) + "," + (currentMappedLatitude - lastMappedLatitude);
		lastMappedLatitude = currentMappedLatitude;
		lastMappedLongitude = currentMappedLongitude;
	}
	
	var insertPath = document.getElementById('odgps-insert');
	insertPath.setAttribute('d',pathString);
};

