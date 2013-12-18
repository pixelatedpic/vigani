#include <TinyGPS++.h>
#include <SoftwareSerial.h>
#include <SPI.h>
#include <SD.h>

TinyGPSPlus gps;
SoftwareSerial ss(2, 3); // RX, TX

File waypoints;
char c=0;
char buffer[22];
int q=1;
char byteRead;
int t;
boolean hom = false;
int rr = 2;
int ff=0;
int inc;
String er;
int tot_wps_infile;
int blah=1;
int blah2=1;
String logfilename="20131217-01.csv";


/*
Function accepts int arg, which is the required waypoint (line)
to be returned (String type).
Also if no more wps, returns string "NMWPS".
*/
String locate_wp(int needed_wp){
  String lat_lon="";
  int curr_line=0;
  
  if (SD.exists("test.txt")) { //checking if the file exists
    waypoints = SD.open("test.txt",FILE_READ);
    
    while(waypoints.available()) {
     c = waypoints.read();
     
     if(c=='\n') {
       curr_line++;
     }
     
     if (curr_line == needed_wp) {
       lat_lon += c;
       lat_lon.trim();
       
       if(c==';') {
         waypoints.close();
         return lat_lon;
       }
      }
    }
    waypoints.close();
    
    if (!waypoints.available()) {
      lat_lon="NMWPS";
      return lat_lon;
    }

  } else {
      Serial.println("Could not open the file");
  } 
}

/*
Counts the total wap points in given file.
Uses locate_wp() function.
Returns count (type int).
*/
int total_wps(){
  int total_wps;
  for (total_wps=0; total_wps<=1000; total_wps++) {
    String check_wp;
    check_wp = locate_wp(total_wps);
    if (check_wp == "NMWPS") {
      return total_wps;
    }
  }
}

/*
Function descr here...
Uses TinyGPS++ lib.
*/
bool feedGPS() {
  while (ss.available()) {
    if (gps.encode(ss.read())) {
      return true;    
    }
  }
  return false;
}

/*
Function descr here...
timestamp, lat, lon, z
Uses TinyGPS++ lib.
*/
void getcurGPS() {

  feedGPS();
  if (gps.date.isUpdated()) {
    Serial.println();
    Serial.print(gps.date.value()); 
  }
  
  feedGPS();
  if (gps.time.isUpdated()) {
    Serial.print("_");
    Serial.print(gps.time.value()); 
  }
  
  Serial.print(",");
  Serial.print(gps.satellites.value());
  Serial.print(",");
  Serial.print(gps.hdop.value());
  
  feedGPS();
  if (gps.location.isUpdated()) {
    Serial.print(",");
    Serial.print(gps.location.lat(),6);
    Serial.print(",");
    Serial.print(gps.location.lng(),6); 
  }

  feedGPS();
  if (gps.altitude.isUpdated()) {
    Serial.print(",");
    Serial.print(gps.altitude.meters(),3); 
  }
    
  write_points(gps.date.value(),gps.time.value(),gps.satellites.value(),gps.hdop.value(),gps.location.lat(),gps.location.lng(),gps.altitude.meters());
}

void write_points(double write_date, double write_time, int write_sats, double write_hdop, double write_lat, double write_lon, double write_alt) {
  File log_file = SD.open("abc.csv", FILE_WRITE);
  if (log_file) {
    log_file.print(write_date);
    log_file.print('_');
    log_file.print(write_time);
    log_file.print(',');
    log_file.print(write_sats);
    log_file.print(',');
    log_file.print(write_hdop);
    log_file.print(',');
    log_file.print(write_lat,6);
    log_file.print(',');
    log_file.print(write_lon,6);
    log_file.print(',');
    log_file.println(write_alt,6);
    log_file.close();
  }
}

float getBearing(String dest_wp){
  // get current latlon from getcurGPS func
  // Calculate Bearing/Course 
  // Return Course, Distance
}

void setup() {
  // put your setup code here, to run once:
  hom =true;
  Serial.begin(9600);
  ss.begin(9600);
  
  SD.begin(10);
  
  Serial.println("Calculating total WPs ...");
  tot_wps_infile = total_wps();
  Serial.print("Total WPS in file = ");
  Serial.println(tot_wps_infile);
  Serial.println();
  
  File log_file = SD.open("abc.csv", FILE_WRITE);
  if (log_file) {
    log_file.println("##################"); 
    String header = "date_time(UTC), sats-in-use, lat, lon, alt(z)";
    log_file.println(header);
    log_file.close();
  } else {
    Serial.println("Couldn't open log (aquired GPS) file");
  }
}

void loop() {
  
  if (blah==1) {
    int getwp;
    tot_wps_infile--;
    for (getwp=0; getwp<=tot_wps_infile; getwp++) {
      String returned_wp;
      returned_wp = locate_wp(getwp);
      delay (250);
      Serial.print("Returned lat_lon=");
      Serial.println(returned_wp);
    }
    blah++;
  }
  
  /*
  while (ss.available() > 0) {
    gps.encode(ss.read());
  }
  if (gps.location.isUpdated()) {
      Serial.print(gps.location.lat());
      Serial.print(" , ");
      Serial.println(gps.location.lng());
  }
  */
  bool newdata = false;
  unsigned long start = millis();
  
  while (millis() - start < 500) {
    if (feedGPS()) {
      newdata = true;
    }
  }

  if (newdata) {
    getcurGPS();
  }
  
 /* if (blah2<=100) {
    getcurGPS();
    blah2++;
    Serial.println();
    delay(500);
  }
*/
  
}
