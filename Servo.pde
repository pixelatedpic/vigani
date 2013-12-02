void JusterRor(void)
{
  int ServoPos = 90;
  float Heading;
  
  WP_Kurs = initial_course (GPS_Lat, GPS_Long, WP_Lat, WP_Long);
  Heading = WP_Kurs - GPS_Kurs;
  if (Heading < 0.0) Heading += 360.0;
  
  if (Heading > 0 && Heading <=180)
    {
      if (Heading > 0 && Heading <=90)
       {
          ServoPos = map(Heading,0,90,90,110);
       } else {
         ServoPos = 120;
       }
     } else {
       if (Heading > 270 && Heading <= 360)
        {
           ServoPos = map(Heading,270,360,70,90);
        } else {
           ServoPos = 60;
        };
     }; 

  Rudder.write(ServoPos);
  delay(20);
};

void Vink(void)
{

  Rudder.write(60);
  delay(2000);
  Rudder.write(120);
  delay(2000);
  Rudder.write(90);

}

