//+------------------------------------------------------------------+
//|                                                   VolumeTreeDaily.mq4 |
//|                                                   Xerox Consades |
//|                                                             none |
//+------------------------------------------------------------------+
#property copyright "Xerox Consades"
#property link      "none"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 DarkBlue
//--- input parameters
extern string       useCandles = "4";
//--- buffers
double ExtMapBuffer1[];
int istInit = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

// Was dieser Indikator darstellt
// 
// Volumen der letzten, sinnvollen Periode wird an der ersten FolgeKerze abgebildet
//
// Beispiel:
//
// Input: 4
// Stundenchart -> letzten 4h werden die Ticks ausgelesen
// Wenn M1 verfügbar, wird solange m1 genutzt, wie genügend Informationen für einen gesamten zyklus vorhanden sind
// dann wird auf M5 gewechselt, und so weiter ... ->
//
// Input: d,w,m
// Stundenchart -> letzten n-Stunden werden die Ticks ausgelesen, um einen ganzen Tag (d), WOche (w) zu füllen
// Wenn M1 verfügbar, wird solange m1 genutzt, wie genügend Informationen für einen gesamten zyklus vorhanden sind
// dann wird auf M5 gewechselt, und so weiter ... ->

int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   if(istInit == 1)
      return(0);
   int    i, counted_bars=IndicatorCounted();
   
   // Prüfen ob die Eingabe ein Integerwert ist
   int isInteger = StrToInteger(useCandles);
 //----
   // Prüfen, ob es genügend Bars gibt
   if(Bars <= 4) 
      return(0);
   // Initialiseren der EndKerze   
   i = Bars;
   
   string $TagKennung = "";
   string $TagAlt = "n";
   int $ErsteTagesBar = -1;
   int $AlteTagesBar;
   int $durchlauf = 0;
   
   double IntHigh = -1;
   double IntLow = -1;
   
   double $Delta = 0;
   
   int nochmalStart = 0;
   int nochmalEnde  = 0;
   
   int volumeGes = 0;
   int anzahl = 0;
   
   double VolArray[50];
   ArrayInitialize(VolArray,0.0);
   
   double Faktor = 0;
   
   double tempHightoLow = 0;
   double tempDelta = 0;
   int tempAnzArrayElem = 0;
   int tempArrayStart = 0;
   
   int TempLength = 0;
   
   // Durchlaufen der Kerzen von neu zu alt
   for(int j = 0; j < Bars; j++){
      // schauen, wann eiin neuer Tag beginnt
      $TagKennung = getDayStringOfUNIXTimeStamp(Time[j]);
      if($TagAlt == "n"){
         $TagAlt = $TagKennung;
      } else if($TagKennung != $TagAlt){
         // ein älterer Tag scheint zu beginnen
         $AlteTagesBar = $ErsteTagesBar;
         $ErsteTagesBar = j - 1;
         ObjectCreate("line"+j, OBJ_VLINE, 0, Time[$ErsteTagesBar], 0);
                
         if($AlteTagesBar != $ErsteTagesBar && $AlteTagesBar != -1){
            // Tag komplett
            ObjectCreate("lineX"+j+1, OBJ_VLINE, 0, Time[$AlteTagesBar], 0);
            // Auslesen der M1-Werte
            for(int g = 0; g < iBars(NULL,PERIOD_H4); g++){
               if(iTime(NULL,PERIOD_H4,g) < Time[$AlteTagesBar]){
                  if(nochmalStart == 0)
                     nochmalStart = g;
                  nochmalEnde = g;
                  if(iTime(NULL,PERIOD_H4,g) < Time[$ErsteTagesBar]){
                     g = 999999999999;
                     //Print(TimeToStr(iTime(NULL,PERIOD_H4,g))+" -> "+iHigh(NULL,PERIOD_H4,g));
                     break;
                  }
                  if(iHigh(NULL,PERIOD_H4,g) > IntHigh)
                     IntHigh = iHigh(NULL,PERIOD_H4,g);
            
                  if(iLow(NULL,PERIOD_H4,g) < IntLow || IntLow == -1)
                     IntLow = iLow(NULL,PERIOD_H4,g);
                     
                  volumeGes = volumeGes + iVolume(NULL,PERIOD_H4,g);
                  anzahl = anzahl + 1;
               }
            }
            // Berechnen, in welchen Schritten die Volomen verteilt werden
            $Delta = IntHigh - IntLow;
            Faktor = $Delta / 50; // 200 P delta -> 4 P je ArraySlot
            
            for(g = nochmalStart;g < nochmalEnde; g++){
               // aktueller High - Low -> 2100 - 1850 = 250;
               tempHightoLow = iLow(NULL,PERIOD_H4,g) - IntLow;
               // Delta der Kerze berechnen 2100 - 2000 = 100;
               tempDelta = iHigh(NULL,PERIOD_H4,g) - iLow(NULL,PERIOD_H4,g);
               // Delta / Faktor = Anzahl der ArrayElemente -> 100 / 5 = 20;
               tempAnzArrayElem = MathRound(tempDelta / Faktor);
               // Wert / Faktor = Arrayplatz -> 250 / 5 = 50;
               tempArrayStart = MathRound(tempHightoLow / Faktor);
               
               // StartArray -> bis MinusArray mit Volume durch Anzahl ArrayElemente
               if(tempAnzArrayElem <= 1)
                  VolArray[tempArrayStart] = VolArray[tempArrayStart] + iVolume(NULL,PERIOD_H4,g);
               else {
                  for(int p = 0; p < tempAnzArrayElem; p++){
                     VolArray[tempArrayStart+p] = VolArray[tempArrayStart+p] + iVolume(NULL,PERIOD_H4,g)/tempAnzArrayElem;
                  }
               }
            }

            for(int m = 0; m < 50; m++){
               TempLength = Time[$AlteTagesBar]+MathRound(60*15*VolArray[m] / volumeGes * 40000);
               ObjectCreate("UniqueRect"+j+"m"+m, OBJ_RECTANGLE, 0, Time[$AlteTagesBar], IntLow+Faktor*m, (TempLength), IntLow+Faktor*(m+1),0,0);
               //Print(Time[$AlteTagesBar]+" -> "+(TempLength));
            }
           
            nochmalStart = 0;
            nochmalEnde  = 0;
            ArrayInitialize(VolArray,0);
            
            ObjectCreate("UniqueName"+j, OBJ_TREND, 0, Time[$AlteTagesBar], IntHigh, Time[$ErsteTagesBar], IntHigh,0,0);
            ObjectCreate("UniqueName2"+j, OBJ_TREND, 0, Time[$AlteTagesBar], IntLow, Time[$ErsteTagesBar], IntLow,0,0);
            
            ObjectSet("UniqueName"+j, OBJPROP_RAY, 0);
            ObjectSet("UniqueName2"+j, OBJPROP_RAY, 0);
            
            IntHigh = -1;
            IntLow = -1;
         }
         //Print(j);
         volumeGes = 0;
         anzahl = 0;
         $durchlauf++;
         if($durchlauf > 20){
            istInit = 1;
            return(0);
         }
      }
      $TagAlt = $TagKennung;
   }
   
   istInit = 1;
   // Quit Indikator  
   return(0);  
//----
   return(0);
  }
//+------------------------------------------------------------------+

// FUnktion des IntegerIntervalls
string getDayStringOfUNIXTimeStamp(int UnixTime){
   string temp = TimeToStr(UnixTime,TIME_DATE);
   // yyyy.mm.dd
   temp = StringSubstr(temp,5,2);
   
   return(temp);
}

int nextDayDate(int UnixTime){
   int temp = StrToTime(TimeToStr(UnixTime+(60*60*24),TIME_DATE));
   
   return(temp);
}