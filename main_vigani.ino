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
int blah=1;

/*
Function accepts int arg, which is the required waypoint (line)
to be returned (String type).
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
         //PString mystring(buffer, sizeof(buffer),c);
         //lat_lon += mystring;
         lat_lon += c;
         lat_lon.trim();
         if(c==';')
         {
           return lat_lon;
         }
      }
    }
    waypoints.close();
  } else {
      Serial.println("Could not open the file");
  } 
}

void setup() {
  // put your setup code here, to run once:
  hom =true;
  Serial.begin(9600);
  SD.begin(10);
}

void loop() {
  
  int getwp=0;
  
  if (blah==1) 
  {
     String returned_wp;
     returned_wp = locate_wp(getwp);
     Serial.print("Returned lat_lon=");
     Serial.println(returned_wp);
     blah++;
  }
}
