# gpx-to-svg
Some tools to render GPX encoded geo tracks to a SVG path.

The sample track (gpx/train-track.gpx) is generated by the iOS app Track (version 2.3) by 7SOLS.

The sample map (svg/italy-map.svg) is free licenced for non commercial use by https://www.amcharts.com/svg-maps/.

![svg sample](https://raw.githubusercontent.com/OpenDGPS/gpx-to-svg/master/media/sample.png "Sample SVG Output")

*Sample SVG rendering from multiple trips in Umbria, Italy.*

###1. XSLT

Reads SVG file as map and transform a new SVG file

The example file ('italy-map.svg') comes from https://www.amcharts.com/svg-maps/

If there is a path element with id="odgps-insert" it will replace this path
  with a new path generated from a GPX track.

The available tracks are defined in $doc-list as '<filename without extension>' 
  multiple files seperate by comma (sample: train-track.gpx)

The map has to be normalized. Set $lat-root to the coordinates of 
  the top coordinates (svg position:y) and $lon-root to the very left coordinates (svg position:x)

Run:
  java -jar <xslt2-processor> svg/italy-map.svg xslt/gpx-to-svg.xslt > out/out.svg

Run (with saxon):
  java -jar saxon9.jar svg/italy-map.svg xslt/gpx-to-svg.xslt > out/out.svg
  
###2. JavaScript

TODO: create sample

###3. Julia

TODO: create sample

###4. C

TODO: create sample

