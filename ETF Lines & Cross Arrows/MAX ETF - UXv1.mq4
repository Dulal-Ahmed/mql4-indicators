//+------------------------------------------------------------------+
//|                               MAX Trading System ETF Indicator   |
//|                Based on work of Patrick Mulloy and Robert Hill   | 
//|                            simplified by Mark Fric               |
//| Based on the formula developed by Patrick Mulloy                 |
//|                                                                  |
//|     Adapted by Alexey for www.maxtradingsystem.com               |
//|              MAX ETF   - MA of TEMA                              |
//|                                                                  |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2013, www.maxtradingsystem.com"
#property  link      "http://www.maxtradingsystem.com/"

//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 2
#property  indicator_color1  CLR_NONE 
#property  indicator_width1  1
#property  indicator_color2  Yellow
#property  indicator_width2  3
//----
extern int EMA_Period=13;
extern int EMA_Method=2;
extern int EMA_Shift=0;
extern int EMA_Applied=0;

extern int MAofTema_Period=3;
extern int MAofTema_Method=2;
extern int MAofTema_Shift=0;
//---- buffers
double Ema[];
double MAofTema[];
double EmaOfEma[];
double EmaOfEmaOfEma[];
double Tema[];

//+------------------------------------------------------------------+

int init() {
   IndicatorBuffers(5);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexDrawBegin(0,EMA_Period);
   SetIndexDrawBegin(1,MAofTema_Period);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);

   SetIndexBuffer(0,Tema);
   SetIndexBuffer(1,MAofTema);
   SetIndexBuffer(2,EmaOfEma);
   SetIndexBuffer(3,EmaOfEmaOfEma);
   SetIndexBuffer(4,Ema);

   IndicatorShortName("MAX ETF UXv1("+EMA_Period+";"+MAofTema_Period+")");

   return(0);
}

//+------------------------------------------------------------------+

int start() {
   int i, limit;
   int    counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(i=limit; i>=0; i--)
      Ema[i]=iMA(NULL,0,EMA_Period,EMA_Shift,EMA_Method,EMA_Applied,i);
   for(i=limit; i >=0; i--)
      EmaOfEma[i]=iMAOnArray(Ema,Bars,EMA_Period,0,EMA_Method,i);

   for(i=limit; i >=0; i--)
      EmaOfEmaOfEma[i]=iMAOnArray(EmaOfEma,Bars,EMA_Period,0,EMA_Method,i);

   for(i=limit; i >=0; i--)
      Tema[i]=3 * Ema[i] - 3 * EmaOfEma[i] + EmaOfEmaOfEma[i];

   for(i=limit; i >=0; i--)
      MAofTema[i]=iMAOnArray(Tema,Bars,MAofTema_Period,MAofTema_Shift,MAofTema_Method,i);
      
   return(0);
}

//+------------------------------------------------------------------+

