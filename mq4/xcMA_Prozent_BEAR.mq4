//+------------------------------------------------------------------+
//|                                                  xcMAProzent.mq4 |
//|                                                               Me |
//|                                                               me |
//+------------------------------------------------------------------+
#property copyright "Me"
#property link      "me"

#property indicator_separate_window
#property indicator_buffers 1

#property indicator_color1 Crimson

//--- buffers
double BUFFER[];

extern int PERIODE = 4;

string DATUM;
int initPos, pos;
int lastPeriod;
int firstDate;
string theSymbol;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(0,BUFFER);
      
   pos = Bars - 7;
   initPos = Bars;
   
   lastPeriod = Period();
   theSymbol = Symbol();
   firstDate = Time[Bars-1];
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   DATUM = "";
   pos = Bars - 7;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){
   if(lastPeriod == Period() && theSymbol == Symbol() && firstDate == Time[Bars-1]){
      if(DATUM != TimeToStr(Time[pos+1]) && pos == -1){
         DATUM = TimeToStr(Time[pos+1]);
         pos = 0;
      }
   } else {
      initPos = Bars;
      pos = Bars - 7;
      DATUM = "";
      Print(initPos);
   }
//----
   while(pos >= 0){
      BUFFER[pos] = (Open[pos] - iMA(NULL,NULL,PERIODE,1,MODE_EMA,PRICE_HIGH,pos)) / Open[pos];
      pos--;
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+