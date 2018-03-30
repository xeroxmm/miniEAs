//+------------------------------------------------------------------+
//|                                               xcAutoFibo_v30.mq4 |
//|                                                               Me |
//|                                                               me |
//+------------------------------------------------------------------+
#property copyright "Me"
#property link      "me"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 Red

#property indicator_color3 Blue
#property indicator_color4 Blue
#property indicator_color5 Blue

#property indicator_color6 Silver
#property indicator_color7 Silver
//--- input parameters
extern int       PERIODE = 16;

double LinieOben[];
double LinieUnten[];

double Linie20[];
double Linie30[];
double Linie50[];
double Linie70[];
double Linie80[];

double tLow = 0.0;
int    tLowCnt = 0;
double tHigh = 0.0;
int    tUpCnt = 0;
   
int    useDownCnt = 0;
int    useUpCnt = 0;
//----
int    ExtCountedBars=0;
int    lastTime = 0;
int    isInit = 1;

string timeString;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexShift(0,0);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   
   IndicatorShortName("xcFibonacciAuto v3.0("+PERIODE+")");
   SetIndexDrawBegin(0,0);
//---- indicator buffers mapping
   SetIndexBuffer(0,LinieOben);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexShift(1,0);

   SetIndexDrawBegin(1,0);
//---- indicator buffers mapping
   SetIndexBuffer(1,LinieUnten);
   
   SetIndexStyle(2,DRAW_LINE,2);
   SetIndexShift(2,0);
   SetIndexDrawBegin(2,0);
   SetIndexBuffer(2,Linie30);
   
   SetIndexStyle(3,DRAW_LINE,2);
   SetIndexShift(3,0);
   SetIndexDrawBegin(3,0);
   SetIndexBuffer(3,Linie50);
   
   SetIndexStyle(4,DRAW_LINE,2);
   SetIndexShift(4,0);
   SetIndexDrawBegin(4,0);
   SetIndexBuffer(4,Linie70);
   
   SetIndexStyle(5,DRAW_LINE,3);
   SetIndexShift(5,0);
   SetIndexDrawBegin(5,0);
   SetIndexBuffer(5,Linie20);
   
   SetIndexStyle(6,DRAW_LINE,3);
   SetIndexShift(6,0);
   SetIndexDrawBegin(6,0);
   SetIndexBuffer(6,Linie80);
   
   tLow = Low[Bars-1];
   tHigh= High[Bars-1];
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars = IndicatorCounted();
//----
   double sum = 0;
   double lowestLow = 0.0;
   double highestHigh = 0.0;
   int    i,z,pos=Bars - counted_bars - 1;
//----
   while(pos >= 0){
      if(timeString == TimeToStr(Time[pos])){
         pos--;
         continue;
      }
      timeString = TimeToStr(Time[pos]);
      if(pos > Bars - PERIODE - 1){
         pos--;
         continue;
      }
      if(Low[pos] < tLow){
         tLowCnt = 0;
         tLow = Low[pos];
      } else if(tLowCnt >= PERIODE){
         lowestLow = Low[pos];
         for(z = 1; z < PERIODE; z++){
            if(Low[pos+z] < lowestLow)
               lowestLow = Low[pos+z];
         }
         if(lowestLow > (tHigh - tLow) * 0.236 + tLow)
            tLow = (tHigh - tLow) * 0.236 + tLow;
         else
            tLow = lowestLow;
            
         tLowCnt = 0;
      } else {
         tLowCnt++;
      }
      
      if(High[pos] > tHigh){
         tUpCnt = 0;
         tHigh = High[pos];
      } else if(tUpCnt >= PERIODE){
         highestHigh = High[pos];
         for(z = 1; z < PERIODE; z++){
            if(High[pos+z] > highestHigh)
               highestHigh = High[pos+z];
         }
         if(highestHigh < (tHigh - tLow) * 0.764 + tLow)
            tHigh = (tHigh - tLow) * 0.764 + tLow;
         else
            tHigh = highestHigh;
            
         tUpCnt = 0;
      } else {
         tUpCnt++;
      }
      
      LinieUnten[pos] = tLow;
      
      Linie20[pos] = (tHigh - tLow) * 0.236 + tLow;      
      Linie30[pos] = (tHigh - tLow) * 0.382 + tLow;
      Linie50[pos] = (tHigh - tLow) * 0.5 + tLow;
      Linie70[pos] = (tHigh - tLow) * 0.618 + tLow;
      Linie80[pos] = (tHigh - tLow) * 0.764 + tLow;
      
      
      LinieOben[pos] = tHigh;
      
      pos--;
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+