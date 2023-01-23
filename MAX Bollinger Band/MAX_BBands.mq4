//+------------------------------------------------------------------+
//|                                          MAX_BBands 2014.mq4     |
//|                     Copyright © 2014, MAX Trading Sysytem2014    |
//|                                                                  |
//|                                                                  |
//|            NOTE: This indicator calls/requires the indicator     |
//|                    MAX_BBands_Support 2014.EX4                        |
//|                       to be in the Indicators Folder             |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, MAX Trading System 2014 - ! ! !  Requires  MAX_BBands_Support 2014.EX4"
#property link      "http://www.maxtradingsystem.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_color2 Lime
#property indicator_color3 Gold
#property indicator_color4 Gold
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_style1 2
#property indicator_style1 2
#property indicator_style2 2
#property indicator_style3 2
#property indicator_style4 2


extern string  Note1="**  Needs  ' MAX_BBands_Support 2014.ex4 '";
extern string  Note2="**  It MUST be in Indicators folder";
extern string  Note3="***    ***    ***    ***    ***    ***    ***    ***";
extern int    BandsPeriod=21;
extern int    BandsShift=3;
extern double BandsDev1=1;
extern double BandsDev2=2;

double UpperBufferBB1[];
double LowerBufferBB1[];
double UpperBufferBB2[];
double LowerBufferBB2[];
//+------------------------------------------------------------------+
//| MAX Bollinger Band indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,UpperBufferBB1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,LowerBufferBB1);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,UpperBufferBB2);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,LowerBufferBB2);
//----
   SetIndexDrawBegin(0,BandsPeriod+BandsShift);
   SetIndexDrawBegin(1,BandsPeriod+BandsShift);
   SetIndexDrawBegin(2,BandsPeriod+BandsShift);
   SetIndexDrawBegin(3,BandsPeriod+BandsShift);
return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted();

// Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),0);

   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
     {
      if(Time[i]<TimeArray[y]) y++;

//***********************************************************   
      UpperBufferBB1[i]=iCustom(NULL,0,"MAX_BBands_Support 2014",BandsPeriod,BandsShift,BandsDev1,1,y);
              LowerBufferBB1[i]=iCustom(NULL,0,"MAX_BBands_Support 2014",BandsPeriod,BandsShift,BandsDev1,2,y);
              UpperBufferBB2[i]=iCustom(NULL,0,"MAX_BBands_Support 2014",BandsPeriod,BandsShift,BandsDev2,1,y);
              LowerBufferBB2[i]=iCustom(NULL,0,"MAX_BBands_Support 2014",BandsPeriod,BandsShift,BandsDev2,2,y);     
              }
return(0);
  }
//+------------------------------------------------------------------+
