void UpdateGPS()
{
  float degs;
  GetGPS_GPRMC();
  
      if (ValidGPS())
        {

    	  // Kalkulerer Breddegrad fra element 3 og 4
    	  GPS_Lat = decimal(GetElement(3)) / 100.0;
    	  degs = floor(GPS_Lat);
    	  GPS_Lat = (100.0 * (GPS_Lat - degs)) / 60.0;
    	  GPS_Lat += degs;
    	  if (*GetElement(4) == 'S') 
            {
    	      GPS_Lat = 0.0 - GPS_Lat;
    	    };
    
          // Kalkulerer Breddegrad fra element 5 og 6
    	  GPS_Long = decimal(GetElement(5)) / 100.0;
    	  degs = floor(GPS_Long);
    	  GPS_Long = (100.0 * (GPS_Long - degs)) / 60.0;
    	  GPS_Long += degs;
    	  if (*GetElement(6) == 'W') 
            {
    	     GPS_Long = 0.0 - GPS_Long;
    	    };
    
          GPS_Hastighet = decimal(GetElement(7));
          GPS_Kurs = decimal(GetElement(8));
            
        } else {
          GetGPS_GPRMC();
        }
}

const char* GetElement(int ElementNo)
{
  Element.begin();
  int KommaNr = 0;

  for (int I=0; I <= Linje.length(); I++)
    {
      if (Linje[I] == ',') KommaNr++;
      
      if (KommaNr == ElementNo && Linje[I] != ',')
        {
          Element.print(Linje[I],BYTE);
        }
    }
  return Element;
}


boolean ValidGPS()
{
  boolean Checksum = false;
  int I = 1;
  int parity = 0;
  char Hex[] = "00\0";
  int HexValue = 0;
  while (Linje[I] != '*')
    {
      parity ^= Linje[I];
      I++;
    }
    
  Hex[0] = Linje[I+1];
  Hex[1] = Linje[I+2];
  HexValue = 16 * from_hex(Hex[0]) + from_hex(Hex[1]); 
  if (HexValue == parity) Checksum = true;
  return Checksum;
}

void GetGPS_GPRMC()
{
  char Bokstav;
  Linje = 0;
  int Antall = 0;
  Bokstav = GPS_in.read();
  //Rudder.refresh();
  
  while (Bokstav != 13)
    {
      if (Bokstav == '$') 
        {
          Linje = 0;
          Antall = 0;
          Linje.append(Bokstav);
        } else {
          Linje.append(Bokstav);
          Antall++;
        };
      Bokstav = GPS_in.read();
      //Rudder.refresh();
    };
    if (Antall > 80 || !Linje.contains("*")) GetGPS_GPRMC();  // Linjen er for lang sÃ¥ det er en feil
    if (Linje.contains("$GPRMC,"))
      {
        if (Linje.contains(",A,")) // Kun Aktive settninger
          {
            LogSjekk++;
            return;
          } else {
            GetGPS_GPRMC();
          };
      } else {
        GetGPS_GPRMC();
      };
    return;
}


int from_hex(char a) 
{
  if (a >= 'A' && a <= 'F')
    return a - 'A' + 10;
  else if (a >= 'a' && a <= 'f')
    return a - 'a' + 10;
  else
    return a - '0';
}

float decimal(const char* s) 
{
  long  rl = 0;
  float rr = 0.0;
  float rb = 0.1;
  boolean dec = false;
  int i = 0;

  if ((s[i] == '-') || (s[i] == '+')) { i++; }
  while (s[i] != 0) {
    if (s[i] == '.') {
      dec = true;
    }
    else{
      if (!dec) {
        rl = (10 * rl) + (s[i] - 48);
      }
      else {
        rr += rb * (float)(s[i] - 48);
        rb /= 10.0;
      }
    }
    i++;
  }
  rr += (float)rl;
  if (s[0] == '-') {
    rr = 0.0 - rr;
  }
  return rr;
}

float distance_between (float lat1, float long1, float lat2, float long2) 
{
  float delta = radians(long1-long2);
  float sdlong = sin(delta);
  float cdlong = cos(delta);
  lat1 = radians(lat1);
  lat2 = radians(lat2);
  float slat1 = sin(lat1);
  float clat1 = cos(lat1);
  float slat2 = sin(lat2);
  float clat2 = cos(lat2);
  delta = (clat1 * slat2) - (slat1 * clat2 * cdlong);
  delta = sq(delta);
  delta += sq(clat2 * sdlong);
  delta = sqrt(delta);
  float denom = (slat1 * slat2) + (clat1 * clat2 * cdlong);
  delta = atan2(delta, denom);
  return delta * 6372795 * 1.0;
}

float initial_course (float lat1, float long1, float lat2, float long2) 
{
  float dlon = radians(long2-long1);
  lat1 = radians(lat1);
  lat2 = radians(lat2);
  float a1 = sin(dlon) * cos(lat2);
  float a2 = sin(lat1) * cos(lat2) * cos(dlon);
  a2 = cos(lat1) * sin(lat2) - a2;
  a2 = atan2(a1, a2);
  if (a2 < 0.0) {
  	a2 += TWO_PI;
  }
  return degrees(a2);
}

