#include <TinyGPS++.h>
#include <SoftwareSerial.h>
#include <SPI.h>
#include <SD.h>

TinyGPSPlus gps;
SoftwareSerial ss(2, 3); // RX, TX

File waypoints;
char c=0;
char buffer[100];
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

   // Serial.println("file available to read");//debug
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
############################
*/
bool feedGPS() {
//  Serial.println("Blkah bah inside feedGPS now");
  while (ss.available()) {
    if (gps.encode(ss.read())) {
//      Serial.println("Blkah bah ss.read success");
      return true;    
    }
  }
//  Serial.println("Blkah bah ss.available fail");
  return false;
}

/*
Returns current GPS lat,lon in an array.
Uses TinyGPS++ lib.
#########NEED TO TEST FUNCTION!!!!##############
*/
void getcurGPS() {
//  Serial.println("Blkah bah inside getcurGPS");
  
  feedGPS();
  
  if (gps.location.isUpdated()) {
    Serial.print(gps.location.lat(),6);
    Serial.print(",");
    Serial.println(gps.location.lng(),6); 
    write_points(gps.location.lat(),gps.location.lng());
    }
    //lat_lon_GPS[0]=gps.location.lat(); // Latitude in degrees (double)
    //lat_lon_GPS[1]=gps.location.lng(); // Longitude in degrees (double)
}

void write_points(double write_lat, double write_lon) {
  File log_file = SD.open("abc.csv", FILE_WRITE);
  if (log_file) {
    log_file.print(write_lat,6);
    log_file.print(',');
    log_file.println(write_lon,6);
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
  
  // commented since write doesnt work!!!!!!!!!!!!!!!!!!
//  Serial.println("Calculating total WPs ...");
//  tot_wps_infile = total_wps();
//  Serial.print("Total WPS in file = ");
//  Serial.println(tot_wps_infile);
//  Serial.println();
  
  File log_file = SD.open("abc.csv", FILE_WRITE);
  if (log_file) {
    log_file.println(" , "); //Just a leading blank line, incase there was previous data
    String header = "lat,lon";
    log_file.println(header);
    log_file.close();
  } else {
    Serial.println("Couldn't open log (aquired GPS) file");
  }
}

void loop() {
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
  
  while (millis() - start < 250) {
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

/*
  if (blah==1) 
  {
    int getwp;
    tot_wps_infile--;
    for (getwp=0; getwp<=tot_wps_infile; getwp++) 
    {
       String returned_wp;
       returned_wp = locate_wp(getwp);
       delay (100);
       Serial.print("Returned lat_lon=");
       Serial.println(returned_wp);
    }
      blah++;
  }  
  */
}

