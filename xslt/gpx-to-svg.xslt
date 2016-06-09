<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    Description: gpx-to-svg.xslt
    
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
        
    Author: info@opendgps.de
    
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:odgps="http://opendgps.de"
    xmlns:amcharts="http://amcharts.com/ammap" 
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:svg="http://www.w3.org/2000/svg"
    exclude-result-prefixes="xs odgps"
    version="2.0">
    <xsl:output method="xml" media-type="text/svg" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:variable name="doc-list" select="('train-track')"/>
    <xsl:variable name="x-width" select="19900" as="xs:integer"/>
    <xsl:variable name="y-width" select="13500" as="xs:integer"/>
    <xsl:variable name="lon-root" select="7.131336" as="xs:double"/>
    <xsl:variable name="lat-root" select="46.9877911" as="xs:double"/>
    <xsl:template match="/* | *">
        <xsl:element name="{name()}" namespace="http://www.w3.org/2000/svg">
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="comment() | text()"/>
            <xsl:apply-templates select="*"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="*[name() = 'path'][@id = 'odgps-insert']">
        <xsl:for-each select="$doc-list">
            <xsl:variable name="path">
                <xsl:apply-templates select="doc(concat('../gpx/',current(),'.gpx'))//*[name() = 'trkpt'][1]" mode="gpx-track"/>
            </xsl:variable>
            <xsl:element name="path" namespace="http://www.w3.org/2000/svg">
                <xsl:attribute name="class" select="concat('way color',position(),' ',current())"/>
                <xsl:attribute name="d" select="$path"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="*[name() = 'trkpt'][not(preceding-sibling::*)]" mode="gpx-track">
        <xsl:value-of select="'M'"/>
        <xsl:value-of select="odgps:getXFromLongitude(@lon) - odgps:getXFromLongitude($lon-root),',',odgps:getYFromLatitude(@lat) - odgps:getYFromLatitude($lat-root)" separator=""/> 
        <xsl:apply-templates select="following-sibling::*[1]" mode="gpx-track"/>
    </xsl:template>
    <xsl:template match="*" mode="gpx-track">
        <xsl:value-of select="'l'"/>
        <xsl:value-of select="format-number(odgps:getXFromLongitude(@lon)-odgps:getXFromLongitude( preceding-sibling::*[1]/@lon),'##0.000'),',',format-number(odgps:getYFromLatitude(@lat) - odgps:getYFromLatitude( preceding-sibling::*[1]/@lat),'##0.000')" separator=""/>
        <xsl:apply-templates select="following-sibling::*[name() = 'trkpt'][1]" mode="gpx-track"/>
    </xsl:template>
    <xsl:function name="odgps:getXFromLongitude">
        <!-- returns a value between lon=0 (x=maxleft) and lon=-0 (x=maxright)-->
        <xsl:param name="longitude" as="xs:double"/>
        <xsl:value-of select="if ($longitude &lt; 0) then ((180 + (180 - abs($longitude))) div 360) * $x-width else ($longitude div 360) * $x-width"/>
    </xsl:function>
    <xsl:function name="odgps:getYFromLatitude">
        <!-- returns a value between 0 (y=maxtop) and 1 (y=maxbottom)-->
        <xsl:param name="latitude" as="xs:double"/>
        <xsl:value-of select="((180 - ($latitude + 90)) div 180) * $y-width"/>
    </xsl:function>
    <xsl:function name="odgps:scaleXY">
        <!-- returns a tuple of x by scale and y by scale -->
        <xsl:param name="x" as="xs:double"/>
        <xsl:param name="y" as="xs:double"/>
        <xsl:param name="x-factor" as="xs:integer"/>
        <xsl:param name="y-factor" as="xs:integer"/>
        <xsl:value-of select="$x*$x-factor,$y*$y-factor" separator=","/>
    </xsl:function>
</xsl:stylesheet>
