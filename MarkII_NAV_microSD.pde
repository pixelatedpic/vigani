#include <string.h>
#include <PString.h>
#include <SoftwareSerial.h>
#include <WString.h> 
#include <Wire.h>
#include <Servo.h>
#include <SdFat.h>
#include <SdFatUtil.h>

#define MotorPin 4
#define Ekko_rxPin 5
#define GPS_rxPin 6
#define RunPin 7
#define SERVOpin 9

#define GPS_txPin 99 //dummy

#define RECORDSIZE 30
#define WP_RADIUS 20.0
#define BUFFERSIZE 100

float WP_Long, WP_Lat, WP_Kurs;
float GPS_Long, GPS_Lat, GPS_Hastighet, GPS_Kurs;
float Distance;
unsigned int MaxWP; 
unsigned int CurrentWP;
boolean WP_Lock = false;
char Bokstav;
char Hex[] = "00\0";
int HexValue = 0;
int parity = 0;
bool parity_complete = false;
int LogSjekk = 0;
String Linje = String(BUFFERSIZE);

Sd2Card card;
SdVolume volume;
SdFile root;
SdFile file;

// store error strings in flash to save RAM
#define error(s) error_P(PSTR(s))
void error_P(const char *str)
{
  PgmPrint("error: ");
  SerialPrintln_P(str);
  if (card.errorCode()) {
    PgmPrint("SD error: ");
    Serial.print(card.errorCode(), HEX);
    Serial.print(',');
    Serial.println(card.errorData(), HEX);
  }
  while(1);
}

void writeCRLF(SdFile &f)
{
  f.write((uint8_t *)"\r\n", 2);
}

void writeString(SdFile &f, char *str)
{
  uint8_t n;
  for (n = 0; str[n]; n++);
  f.write((uint8_t *)str, n);
}

SoftwareSerial GPS_in =  SoftwareSerial(GPS_rxPin, GPS_txPin);

char ElementBuffer[30];
PString Element(ElementBuffer, sizeof(ElementBuffer));
char OutputBuffer[BUFFERSIZE];
PString Output(OutputBuffer, sizeof(OutputBuffer));

Servo Rudder;

void setup()
{
  
  Rudder.attach(SERVOpin);
  Rudder.write(90);
  
  Serial.begin(9600);
  
  digitalWrite(MotorPin, LOW); 
  pinMode(RunPin, INPUT);
  pinMode(MotorPin, OUTPUT);
  pinMode(SERVOpin, OUTPUT);

  pinMode(GPS_rxPin,INPUT);
  pinMode(GPS_txPin,OUTPUT);
  GPS_in.begin(4800);
  
  if (!card.init()) error("card.init");
  if (!volume.init(card)) error("volume.init");
  if (!root.openRoot(volume)) error("openRoot");
  MaxWP = AntallWP();
  CurrentWP = 1;  
  Vink();                           // Sjekk ror og nullstill dem.
};

void loop()
{
  float LastDistance;
  LastDistance = WP_RADIUS + 5;
  WP_Lock = false;
  CurrentWP++;
  if (CurrentWP > MaxWP) CurrentWP = 0;
  LesWaypoint(CurrentWP);
  delay(500);
  LogWP();
  while (!WP_Lock)
  {
    //Rudder.refresh();
    UpdateGPS();
    JusterRor();
    if (digitalRead(RunPin) == HIGH)
      {
        digitalWrite(MotorPin, HIGH);  // Motor ON
      } else {
        digitalWrite(MotorPin, LOW);  // Motor OFF
      };

    Distance = distance_between(GPS_Lat, GPS_Long, WP_Lat, WP_Long);
    
    //Debug(); // Skrur på WP overstyring
    //WP_Lock = true; //dummy for å se om vi leser..

    if (Distance < WP_RADIUS)
    {
      if (Distance > LastDistance)
      {
        MarkWP(LastDistance);
        WP_Lock = true;
      } 
      else {
        LastDistance = Distance;
      };
    };
    SkrivLCD();
    //SkrivUt(); //Debug til monitor
  }; 
};






