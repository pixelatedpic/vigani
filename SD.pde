int AntallWP(void)
{
  int Antall = -2;
  int StringLength = RECORDSIZE;
  
  if (file.open(root, "WAYPOINT.TXT", O_READ)) 
   {
     while (StringLength == RECORDSIZE)
    {
      StringLength = file.read(Linje, RECORDSIZE);
      Antall++;
      if (Linje.contains("*END*")) break;
    }
   } else {
    error("file.open");
  }
  file.close();
  return (Antall);
};

boolean LesWaypoint(int LinjeNr)
{
  if (file.open(root, "WAYPOINT.TXT", O_READ)) 
   {
     for (int I = 0; I < LinjeNr + 1; I++)
       {
        file.read(Linje, RECORDSIZE);
        };
   } else {
    error("file.open");
  }
  file.close();
  setKoordinater();
  if (WP_Long < 1 || WP_Lat < 1) LesWaypoint(LinjeNr); //En feil er oppstått så vi forsøker å lese en gang til
  return false;
};

void setKoordinater(void)
{
  Linje[12] = 0;
  Linje[18] = 0;
  Linje[22] = 0;
  long int LongDes,LatDes;
  double des;
  char* ptrLat = &Linje[10];
  char* ptrLatDes = &Linje[13];
  char* ptrLong = &Linje[19];
  char* ptrLongDes = &Linje[23];

  WP_Long = atoi(ptrLong);
  LongDes = atol(ptrLongDes);
  des = (double) LongDes / 100000;
  WP_Long = WP_Long + des;
  
  WP_Lat = atoi(ptrLat);
  LatDes = atol(ptrLatDes);
  des = (double) LatDes / 100000;
  WP_Lat = WP_Lat + des;
};

void LogWP(void)
{
  // Oppdater koordinater og avstand så vi skriver relle tall
  UpdateGPS();
  Distance = distance_between(GPS_Lat, GPS_Long, WP_Lat, WP_Long);
  TimeStamp();
  
  Output.begin();
  Output.print("Skal til WP nr. ");Output.print(CurrentWP,DEC);Output.print(" av ");Output.print(MaxWP,DEC);
  SkrivLinje();
  
  Output.begin();
  Output.print("Avstand: ");Output.print(Distance, 0);Output.print("m");
  SkrivLinje();
  
  Output.begin();
  Output.print("WP koordinater: ");Output.print(WP_Long, 5);Output.print(", ");Output.print(WP_Lat, 5);
  SkrivLinje();
  
  Output.begin();
  Output.print("GPS: ");Output.print(GPS_Long,5);Output.print(", ");Output.print(GPS_Lat,5);
  SkrivLinje();
 
};

void MarkWP(float LastDistance)
{
  TimeStamp();
  
  Output.begin();
  Output.print("\tPasserer WP nr. ");Output.print(CurrentWP,DEC);Output.print(", avstand ");Output.print(LastDistance, 0);Output.print("m");
  SkrivLinje();
  
  Output.begin();
  Output.print("\tGPS: ");Output.print(GPS_Long,5);Output.print(", ");Output.print(GPS_Lat,5);Output.print("\n\n");
  SkrivLinje();
};



void SkrivLinje(void)
{
  file.open(root, "LOG.TXT", O_CREAT | O_APPEND | O_WRITE);
  if (file.isOpen())
    {
      writeString(file, OutputBuffer);
      writeCRLF(file);
      file.close();
    };
};



void TimeStamp(void)
  {
    Output.begin();
    Output.print("Timestamp: ");
    Output.print(millis(),DEC);
    SkrivLinje();
  };



