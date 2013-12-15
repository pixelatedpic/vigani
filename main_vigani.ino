#include <SPI.h>
#include <SD.h>

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

/*
Function accepts int arg, which is the required waypoint (line)
to be returned (String type).
Also if no more wps, returns string "NMWPS".
*/
String locate_wp(int needed_wp){
  String lat_lon="";
  int curr_line=0;
  
  if (SD.exists("test.txt"))//checking if the file exists
  {
   // Serial.println("file available to read");//debug
    waypoints = SD.open("test.txt",FILE_READ);
    
    while(waypoints.available())
    {
     c = waypoints.read();
     
     if(c=='\n')
     {
       curr_line++;
     }
     
     if (curr_line == needed_wp)
     {
         lat_lon += c;
         lat_lon.trim();
         
         if(c==';')
         {
           waypoints.close();
           return lat_lon;
         }
      }
    }
    waypoints.close();
    
    if (!waypoints.available())
    {
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

void setup() {
  // put your setup code here, to run once:
  hom =true;
  Serial.begin(9600);
  SD.begin(10);
  
  Serial.println("Calculating total WPs ...");
  tot_wps_infile = total_wps();
  Serial.print("Total WPS in file = ");
  Serial.println(tot_wps_infile);
  Serial.println();
  
}

void loop() {
/*  
  int getwp=0;
  
  if (blah==1) 
  {
     String returned_wp;
     returned_wp = locate_wp(getwp);
     Serial.print("Returned lat_lon=");
     Serial.println(returned_wp);
     blah++;
  }
  */

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
  
}
