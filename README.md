vigani
======

Autonomus boat for surveying


###Calculation distance between two waypoints
Link for reference : 
http://www.movable-type.co.uk/scripts/latlong.html


http://tronixstuff.com/2011/03/16/tutorial-your-arduinos-inbuilt-eeprom/
http://aprs.gids.nl/nmea/
http://learn.adafruit.com/memories-of-an-arduino/optimizing-sram

Spherical Law of Cosines

In fact, when Sinnott published the haversine formula, computational precision was limited. Nowadays, JavaScript (and most modern computers & languages) use IEEE 754 64-bit floating-point numbers, which provide 15 significant figures of precision. With this precision, the simple spherical law of cosines formula (cos c = cos a cos b + sin a sin b cos C) gives well-conditioned results down to distances as small as around 1 metre. (Note that the geodetic form of the law of cosines is rearranged from the canonical one so that the latitude can be used directly, rather than the colatitude).

This makes the simpler law of cosines a reasonable 1-line alternative to the haversine formula for many purposes. The choice may be driven by coding context, available trig functions (in different languages), etc.
Spherical
law of cosines: 	d = acos( sin(φ1).sin(φ2) + cos(φ1).cos(φ2).cos(Δλ) ).R
JavaScript: 	

var R = 6371; // km
var d = Math.acos(Math.sin(lat1)*Math.sin(lat2) + 
                  Math.cos(lat1)*Math.cos(lat2) *
                  Math.cos(lon2-lon1)) * R;

Excel: 	=ACOS(SIN(lat1)*SIN(lat2)+COS(lat1)*COS(lat2)*COS(lon2-lon1))*6371

(Note that here and in all subsequent code fragments, for simplicity I do not show conversions from degrees to radians; see code below for complete versions).



###Bearing calculations reference

In general, your current heading will vary as you follow a great circle path (orthodrome); the final heading will differ from the initial heading by varying degrees according to distance and latitude (if you were to go from say 35°N,45°E (Baghdad) to 35°N,135°E (Osaka), you would start on a heading of 60° and end up on a heading of 120°!).

This formula is for the initial bearing (sometimes referred to as forward azimuth) which if followed in a straight line along a great-circle arc will take you from the start point to the end point:1
Formula: 	θ = atan2( sin(Δλ).cos(φ2), cos(φ1).sin(φ2) − sin(φ1).cos(φ2).cos(Δλ) )
JavaScript: 	

var y = Math.sin(dLon) * Math.cos(lat2);
var x = Math.cos(lat1)*Math.sin(lat2) -
        Math.sin(lat1)*Math.cos(lat2)*Math.cos(dLon);
var brng = Math.atan2(y, x).toDeg();

Excel: 	=ATAN2(COS(lat1)*SIN(lat2)-SIN(lat1)*COS(lat2)*COS(lon2-lon1),
       SIN(lon2-lon1)*COS(lat2))
*note that Excel reverses the arguments to ATAN2 – see notes below

Since atan2 returns values in the range -π ... +π (that is, -180° ... +180°), to normalise the result to a compass bearing (in the range 0° ... 360°, with −ve values transformed into the range 180° ... 360°), convert to degrees and then use (θ+360) % 360, where % is modulo.

For final bearing, simply take the initial bearing from the end point to the start point and reverse it (using θ = (θ+180) % 360).

