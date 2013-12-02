void DUMP_GPS()
{
  while (true)
  {
    Bokstav = GPS_in.read();
    Serial.print(Bokstav);
  }
};


void SkrivLCD(void)
{
  Serial.print(0xFE, BYTE);   //command flag
  Serial.print(0x01, BYTE);   //clear command.
  Serial.print("WP:");Serial.print(CurrentWP,DEC);
  Serial.print(" Dis ");Serial.print(Distance,0); Serial.print("m");
  Serial.print(0xFE, BYTE);   //command flag
  Serial.print(192, BYTE);    //position
  Serial.print("WPn:");Serial.print(MaxWP,DEC);
  Serial.print(" Krs:");Serial.print(GPS_Kurs,0);
}


void SkrivUt(void)
{
  Serial.print("WP nr.\t\t");Serial.print(CurrentWP,DEC);Serial.print(" av ");Serial.println(MaxWP,DEC);
  Serial.print("GPS Koord\t");Serial.print(GPS_Long,5);Serial.print("\t"); Serial.print(GPS_Lat,5); Serial.println();
  Serial.print("GPS Kurs\t");Serial.print(GPS_Kurs,2);Serial.println();
  Serial.print("WP Koord\t");Serial.print(WP_Long,5);Serial.print("\t"); Serial.print(WP_Lat,5); Serial.println();
  Serial.print("WP Kurs\t\t");Serial.print(WP_Kurs,0); Serial.println();
  Serial.print("Avstand\t\t");Serial.print(Distance,0); Serial.println("m");
  Serial.println("\n");
}

void Debug(void)
{
  pinMode(2, INPUT);
  int val = 0; 
  val = digitalRead(2);
  if (val == HIGH) 
  {            
    MarkWP(1.11);
    WP_Lock = true;
  };
};





