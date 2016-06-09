using Requests;
import Requests: get, post, put, delete, options;
using Gumbo;
# Pkg.add("LightXML");
using LightXML;

xWidth = 19900.0
yWidth = 13500.0
latRoot = 46.9877911
lonRoot = 7.131336
pathString = "M"

function mappedLongitude(lon)
    
    if (lon < 0) 
        (((180 + (180 - abs(lon))) / 360) * xWidth)
    else 
        ((lon / 360) * xWidth) 
    end
end


function mappedLatitude(lat)
    with_rounding(Float64,RoundDown) do
        ((180 - (lat + 90)) / 180) * yWidth
    end
end



gpxDoc = parse_file("/Users/rene/Development/gps-test/github/gpx/1k.gpx")

xroot = root(gpxDoc)
trk = get_elements_by_tagname(xroot, "trk")[1]
trkseg = get_elements_by_tagname(trk, "trkseg")[1]
trkpt = get_elements_by_tagname(trkseg, "trkpt")
nodeCounter = 1
lastMappedLongitude = 1.0
lastMappedLatitude = 1.0
for c in child_nodes(trkseg)
    if is_elementnode(c)
        #thisNode = XMLElement(c)
        ad = attributes_dict(XMLElement(c))
        if (nodeCounter == 1)
            lastMappedLongitude = mappedLongitude(parse(Float32,(ad["lon"])))
            lastMappedLatitude = mappedLatitude(parse(Float32,(ad["lat"])))
            mappedLonRoot = mappedLongitude(lonRoot)
            mappedLatRoot = mappedLatitude(latRoot)
            pathString = string(pathString,round(lastMappedLongitude - mappedLonRoot,5) , "," , round(lastMappedLatitude - mappedLatRoot,5))
        else
            currentMappedLongitude = mappedLongitude(parse(Float32,(ad["lon"])))
            currentMappedLatitude = mappedLatitude(parse(Float32,(ad["lat"])))
            pathString = string(pathString,"l",round((currentMappedLongitude - lastMappedLongitude),5) , "," , round((currentMappedLatitude - lastMappedLatitude),5))
            lastMappedLongitude = currentMappedLongitude
            lastMappedLatitude = currentMappedLatitude
        end
        nodeCounter = nodeCounter + 1
    end
end


println(pathString)

