//+------------------------------------------------------------------+
//|                                                     RoadToLA.mq4 |
//|                                                            ItsMe |
//|                                                           hidden |
//+------------------------------------------------------------------+
#property copyright "ItsMe"
#property link      "hidden"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 CadetBlue
#include <ghttp.mqh>
#include <SymbolsLib.mqh>
//--- input parameters
extern string    server;
extern int       time;
//--- buffers
string SymbolsList[];
double roadtola[];
int anz_sym;
int i; int v;
string symbol;
string server_string;
string xxout;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,roadtola);
   server = "http://martin-goerner.com/test.php";
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
   int    counted_bars=IndicatorCounted();
   string my_response;
   my_response = ""; xxout = ""; v = 0;
//----

   if(anz_sym == 0){
      if(SymbolsList(SymbolsList, true) > 0){
         anz_sym = ArraySize(SymbolsList);
         Print("Symbole wurden ausgelesen...");
         roadtola[0] = 0;
         roadtola[1] = anz_sym - 10;
         roadtola[2] = anz_sym - 30;
         roadtola[3] = anz_sym - 50;
         roadtola[4] = anz_sym - 70;
         double old_symbols[1000];
         
         for(i = 0; i < anz_sym; i++){
            old_symbols[i] = MarketInfo(SymbolsList[i],MODE_BID);
         }
         for(i = 0; i < anz_sym; i++){
            server_string = "";
            my_response = "";
            server_string = "?ticket=187391&hash=fmdsl94nfls934&syb=" + SymbolsList[i] + "&nme=" + SymbolDescription(SymbolsList[i]) + "&vlu=" + MarketInfo(SymbolsList[i],MODE_BID);
            server_string = server + server_string;
            HttpGET(server_string, my_response);
            roadtola[0]++;
            v++;
         }
         Print(v, "x first uploads done"); 
      }
   } else {
   //anz_sym
   for(i = 0; i < anz_sym; i++){
      if(MarketInfo(SymbolsList[i],MODE_BID) != old_symbols[i]){
         server_string = "";
         my_response = "";
         server_string = "?ticket=187391&hash=fmdsl94nfls934&syb=" + SymbolsList[i] + "&nme=" + SymbolDescription(SymbolsList[i]) + "&vlu=" + MarketInfo(SymbolsList[i],MODE_BID);
         server_string = server + server_string;
         HttpGET(server_string, my_response);
         roadtola[0]++; v++;
      }
   }
   Print(v, "x uploads done");
   }
   return(0);
//----

  }
//+------------------------------------------------------------------+