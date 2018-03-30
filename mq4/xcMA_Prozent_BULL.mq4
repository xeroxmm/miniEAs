//+------------------------------------------------------------------+
//|                                                  xcMAProzent.mq4 |
//|                                                               Me |
//|                                                               me |
//+------------------------------------------------------------------+
#property copyright "Me"
#property link      "me"

#property indicator_separate_window
#property indicator_buffers 2

#property indicator_color1 Green
#property indicator_color2 Green

//--- buffers
double BUFFER[];
double BUFFER_REAL[];

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
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,BUFFER);
   
   SetIndexStyle(1,DRAW_HISTOGRAM,0,2);
   SetIndexBuffer(1,BUFFER_REAL);
      
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
      BUFFER_REAL[pos] = (Open[pos] - iMA(NULL,NULL,PERIODE,1,MODE_EMA,PRICE_LOW,pos)) / Open[pos];
      if(BUFFER_REAL[pos] < 0)
         BUFFER[pos] = 0.0;
      else {
         if(BUFFER_REAL[pos] > BUFFER_REAL[pos + 1])
            BUFFER[pos] = 0.0;
         else
            BUFFER[pos] = 0.0;
      }
      pos--;
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+