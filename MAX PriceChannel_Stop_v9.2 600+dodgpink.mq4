//+------------------------------------------------------------------+
//|                                  PriceChannel_Stop_v9.2 600+.mq4 |
//|                             Copyright © 2005-14, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005-14, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_chart_window
#property indicator_buffers 8

#property indicator_color1 DodgerBlue
#property indicator_color2 DeepPink
#property indicator_color3 DodgerBlue
#property indicator_color4 DeepPink
#property indicator_width3 2
#property indicator_width4 2
#property indicator_color5 DodgerBlue
#property indicator_color6 DeepPink
#property indicator_color7 DodgerBlue
#property indicator_color8 DeepPink
#property indicator_width7 3
#property indicator_width8 3


//---- input parameters
extern int     TimeFrame            =     0;    //TimeFrame in min
extern int     UpBandPrice          =     2;    //Upper Band Price(ex.2 for High)     
extern int     LoBandPrice          =     3;    //Lower Band Price(ex.3 for Low) 
extern int     ChannelPeriod        =     9;    //Channel Period (eg.9)
extern double  Risk                 =     0;    //Channel Narrowing Factor(0..0.5)   
extern double  Ratchet              =   0.0;    //Ratchet(-1-off,>= 0-on) 
extern double  MoneyRisk            =  1.00;    //Offset Factor(eg.1.2)

extern int     SignalMode           =     1;    //SignalMode: 0-off,1-on 
extern int     LineMode             =     1;    //Line mode : 0-off,1-on  
extern int     DotMode              =     0;    //Dot mode  : 0-off,1-on  
extern int     BarsMode             =     1;    //Bars mode : 0-off,1-on  

extern string  alerts               = "--- Alerts & Emails ---";
extern int     AlertMode            =     0;
extern int     SoundsNumber         =     5;    //Number of sounds after Signal
extern int     SoundsPause          =     5;    //Pause in sec between sounds 
extern string  UpSound              = "alert.wav";
extern string  DnSound              = "alert2.wav";
extern int     EmailMode            =     0;    //0-on,1-off   
extern int     EmailsNumber         =     1;    //0-on,1-off


//---- indicator buffers
double UpTrend[];
double DnTrend[];
double UpSignal[];
double DnSignal[];
double UpLine[];
double DnLine[];
double UpBar[];
double DnBar[];

int      length[2];
double   HiArray[],LoArray[], trend[3], upfrac[2], dnfrac[2], upband1[2], dnband1[2], upband2[2], dnband2[2], len[2], hh[2], ll[2];
datetime prevtime, preTime, ptime;
string   short_name, TF, IndicatorName, prevmess, prevemail;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   if(TimeFrame <= Period()) TimeFrame = Period();
   TF = tf(TimeFrame);
   
//---- 
   SetIndexBuffer(0, UpTrend); SetIndexStyle(0,    DRAW_ARROW); SetIndexArrow(0,159);
   SetIndexBuffer(1, DnTrend); SetIndexStyle(1,    DRAW_ARROW); SetIndexArrow(1,159);
   SetIndexBuffer(2,UpSignal); SetIndexStyle(2,    DRAW_ARROW); SetIndexArrow(2,108);
   SetIndexBuffer(3,DnSignal); SetIndexStyle(3,    DRAW_ARROW); SetIndexArrow(3,108);
   SetIndexBuffer(4,  UpLine); SetIndexStyle(4,     DRAW_LINE);
   SetIndexBuffer(5,  DnLine); SetIndexStyle(5,     DRAW_LINE);
   SetIndexBuffer(6,   UpBar); SetIndexStyle(6,DRAW_HISTOGRAM);
   SetIndexBuffer(7,   DnBar); SetIndexStyle(7,DRAW_HISTOGRAM);
   
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- 
   
   IndicatorName = WindowExpertName(); 
   short_name    = IndicatorName+"["+TF+"]("+UpBandPrice+","+LoBandPrice+","+ChannelPeriod+","+DoubleToStr(Risk,2)+","+DoubleToStr(Ratchet,2)+","+DoubleToStr(MoneyRisk,2)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"UpTrend Stop");
   SetIndexLabel(1,"DnTrend Stop");
   SetIndexLabel(2,"UpTrend Signal");
   SetIndexLabel(3,"DnTrend Signal");
   SetIndexLabel(4,"UpTrend Line");
   SetIndexLabel(5,"DnTrend Line");
   SetIndexLabel(6,"UpTrend Bar");
   SetIndexLabel(7,"DnTrend Bar");

//----
   int draw_begin = MathMax(2,Bars - iBars(NULL,TimeFrame)*TimeFrame/Period() + ChannelPeriod); 
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   SetIndexDrawBegin(4,draw_begin);
   SetIndexDrawBegin(5,draw_begin);
   SetIndexDrawBegin(6,draw_begin);
   SetIndexDrawBegin(7,draw_begin);
//----
   
   return(0);
}

//----
int deinit() {Comment(""); return(0);}

//+------------------------------------------------------------------+
//| PriceChannel_Stop_v9.2 600+                                      |
//+------------------------------------------------------------------+
int start()
{
   int shift, limit, counted_bars=IndicatorCounted();
      
   if(counted_bars > 0) limit = Bars - counted_bars - 1;
   if(counted_bars < 0) return(0);
   if(counted_bars < 1)
   { 
   limit = Bars-1;   
      for(int i=0;i<limit;i++)
      { 
      UpTrend[i]  = EMPTY_VALUE;
      DnTrend[i]  = EMPTY_VALUE;
      UpSignal[i] = EMPTY_VALUE;
      DnSignal[i] = EMPTY_VALUE;
      UpLine[i]   = EMPTY_VALUE;
      DnLine[i]   = EMPTY_VALUE;
      UpBar[i]    = EMPTY_VALUE;
      DnBar[i]    = EMPTY_VALUE;
      }
   }   
   
   
   if(TimeFrame != Period())
	{
   limit = MathMax(limit,TimeFrame/Period());   
      
      for(shift = 0;shift < limit;shift++) 
      {	
      int y = iBarShift(NULL,TimeFrame,Time[shift]);
      
         if(DotMode > 0)
         {
         UpTrend[shift]  = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,ChannelPeriod,Risk,Ratchet,MoneyRisk,SignalMode,LineMode,DotMode,BarsMode,
                                   "",AlertMode,SoundsNumber,SoundsPause,UpSound,DnSound,EmailMode,EmailsNumber,0,y);
                                      
         DnTrend[shift]  = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,ChannelPeriod,Risk,Ratchet,MoneyRisk,SignalMode,LineMode,DotMode,BarsMode,
                                   "",AlertMode,SoundsNumber,SoundsPause,UpSound,DnSound,EmailMode,EmailsNumber,1,y);      
         }
         
         if(SignalMode > 0)
         {         
         UpSignal[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,ChannelPeriod,Risk,Ratchet,MoneyRisk,SignalMode,LineMode,DotMode,BarsMode,
                                   "",AlertMode,SoundsNumber,SoundsPause,UpSound,DnSound,EmailMode,EmailsNumber,2,y);      
         DnSignal[shift] = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,ChannelPeriod,Risk,Ratchet,MoneyRisk,SignalMode,LineMode,DotMode,BarsMode,
                                   "",AlertMode,SoundsNumber,SoundsPause,UpSound,DnSound,EmailMode,EmailsNumber,3,y);      
         }       
      
         if(LineMode > 0)
         {
         UpLine[shift]   = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,ChannelPeriod,Risk,Ratchet,MoneyRisk,SignalMode,LineMode,DotMode,BarsMode,
                                   "",AlertMode,SoundsNumber,SoundsPause,UpSound,DnSound,EmailMode,EmailsNumber,4,y);      
         DnLine[shift]   = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,ChannelPeriod,Risk,Ratchet,MoneyRisk,SignalMode,LineMode,DotMode,BarsMode,
                                   "",AlertMode,SoundsNumber,SoundsPause,UpSound,DnSound,EmailMode,EmailsNumber,5,y);      
         }
              
         if(BarsMode > 0)
         {
         UpBar[shift]   = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,ChannelPeriod,Risk,Ratchet,MoneyRisk,SignalMode,LineMode,DotMode,BarsMode,
                                   "",AlertMode,SoundsNumber,SoundsPause,UpSound,DnSound,EmailMode,EmailsNumber,6,y);      
         DnBar[shift]   = iCustom(NULL,TimeFrame,IndicatorName,0,UpBandPrice,LoBandPrice,ChannelPeriod,Risk,Ratchet,MoneyRisk,SignalMode,LineMode,DotMode,BarsMode,
                                   "",AlertMode,SoundsNumber,SoundsPause,UpSound,DnSound,EmailMode,EmailsNumber,7,y);      
         }
     
     
     }  
	
	return(0);
	}
	else
	{
      for(shift=limit;shift>=0;shift--) 
      {	
         if(prevtime != Time[shift])
         {
         length[1]  = length[1];
         upfrac[1]  = upfrac[0];
         dnfrac[1]  = dnfrac[0];
         upband1[1] = upband1[0];
         dnband1[1] = dnband1[0];
         upband2[1] = upband2[0];
         dnband2[1] = dnband2[0];
         trend[2]   = trend[1];
         trend[1]   = trend[0];
         len[1]     = len[0];
         hh[1]      = hh[0];
         ll[1]      = ll[0];
         prevtime   = Time[shift];
         }
   
      
      if(trend[1] != trend[2]) len[1] = ChannelPeriod;
            
      length[0] = MathMin(MathFloor(len[1]) + 1,ChannelPeriod);
                  
      double himax = 0, lomin = 100000000;    
         for(i=0;i<length[0];i++)
         {
         if(iMA(NULL,0,1,0,0,UpBandPrice,shift+i) > himax) himax = iMA(NULL,0,1,0,0,UpBandPrice,shift+i);
         if(iMA(NULL,0,1,0,0,LoBandPrice,shift+i) < lomin) lomin = iMA(NULL,0,1,0,0,LoBandPrice,shift+i);    
         }
         
      double diff = himax - lomin;
      
      upband1[0]  = himax - diff*Risk;
      dnband1[0]  = lomin + diff*Risk;
        
      upband2[0]  = upband1[0] + 0.5*(MoneyRisk - 1)*diff;  
      dnband2[0]  = dnband1[0] - 0.5*(MoneyRisk - 1)*diff;
      	      
      trend[0] = trend[1];
	   len[0]   = len[1];
	   hh[0]    = hh[1];
	   ll[0]    = ll[1]; 
	 
      if(Close[shift] > upband1[1] && trend[1] <= 0) {trend[0] = 1; hh[0] = iMA(NULL,0,1,0,0,UpBandPrice,shift);}  
      if(Close[shift] < dnband1[1] && trend[1] >= 0) {trend[0] =-1; ll[0] = iMA(NULL,0,1,0,0,LoBandPrice,shift);}
	
      hh[0] = MathMax(iMA(NULL,0,1,0,0,UpBandPrice,shift),hh[0]);
      ll[0] = MathMin(iMA(NULL,0,1,0,0,LoBandPrice,shift),ll[0]);
      
      
      
      UpTrend[shift]  = EMPTY_VALUE;  
      DnTrend[shift]  = EMPTY_VALUE;  
      UpSignal[shift] = EMPTY_VALUE;  
      DnSignal[shift] = EMPTY_VALUE;  
      UpLine[shift]   = EMPTY_VALUE;  
      DnLine[shift]   = EMPTY_VALUE;
	   UpBar[shift]    = EMPTY_VALUE;  
      DnBar[shift]    = EMPTY_VALUE;
      
         
         if(trend[0] > 0)
         {
            if(trend[1] > 0 && Ratchet >= 0)
            {
            if(hh[0] > hh[1] && trend[1] > 0) len[0] = MathMax(2,len[1] - Ratchet);
               
            if(dnband1[0] < dnband1[1]) dnband1[0] = dnband1[1];
            if(dnband2[0] < dnband2[1]) dnband2[0] = dnband2[1];
	         }
	      	           
         if(DotMode    > 0) UpTrend[shift] = dnband2[0];
	      if(LineMode   > 0) UpLine[shift]  = dnband2[0];   
         if(SignalMode > 0 && trend[1] < 0) UpSignal[shift] = dnband2[0];
      
            if(BarsMode > 0)
            {
            if(Risk > 0) double uplevel = upband1[0]; else uplevel = 0.5*(upband1[0] + dnband1[0]);
	         
               if(Close[shift] > uplevel)
	            {
               UpBar[shift] = MathMax(Open[shift],Close[shift]);
	            DnBar[shift] = MathMin(Open[shift],Close[shift]);   
	            }
	         }   
         }      
	  
         if(trend[0] < 0)
         {
            if(trend[1] < 0 && Ratchet >= 0)
            {
            if(ll[0] < ll[1] && trend[1] < 0) len[0] = MathMax(2,len[1] - Ratchet);
            
            if(upband1[0] > upband1[1]) upband1[0] = upband1[1];
            if(upband2[0] > upband2[1]) upband2[0] = upband2[1];	  
	         }
	           
         if(DotMode    > 0) DnTrend[shift] = upband2[0];
         if(LineMode   > 0) DnLine[shift]  = upband2[0];   
         if(SignalMode > 0 && trend[1] > 0) DnSignal[shift] = upband2[0];
            
            if(BarsMode > 0)
            {
            if(Risk > 0) double lolevel = dnband1[0]; else lolevel = 0.5*(upband1[0] + dnband1[0]);
	         
               if(Close[shift] < lolevel)
	            {
               UpBar[shift] = MathMin(Open[shift],Close[shift]);
	            DnBar[shift] = MathMax(Open[shift],Close[shift]);   
               }
	         }         
         }      
      }
//----
      if(AlertMode > 0)
      {
      bool uptrend = trend[1] > 0 && trend[2] <= 0;                  
      bool dntrend = trend[1] < 0 && trend[2] >= 0;
        
         if(uptrend || dntrend)
         {
            if(isNewBar(TimeFrame))
            {
            BoxAlert(uptrend," : BUY Signal at " +DoubleToStr(Close[1],Digits)+", StopLoss at "+DoubleToStr(UpSignal[1],Digits));   
            BoxAlert(dntrend," : SELL Signal at "+DoubleToStr(Close[1],Digits)+", StopLoss at "+DoubleToStr(DnSignal[1],Digits)); 
            }
      
         WarningSound(uptrend,SoundsNumber,SoundsPause,UpSound,Time[1]);
         WarningSound(dntrend,SoundsNumber,SoundsPause,DnSound,Time[1]);
         
            if(EmailMode > 0)
            {
            EmailAlert(uptrend,"BUY" ," : BUY Signal at " +DoubleToStr(Close[1],Digits)+", StopLoss at "+DoubleToStr(UpSignal[1],Digits),EmailsNumber); 
            EmailAlert(dntrend,"SELL"," : SELL Signal at "+DoubleToStr(Close[1],Digits)+", StopLoss at "+DoubleToStr(DnSignal[1],Digits),EmailsNumber); 
            }
         }
      }
   }   
   
	 	         
//----	
	return(0);	
}



bool isNewBar(int tf)
{
   static datetime pTime;
   bool res=false;
   
   if(tf >= 0)
   {
      if (iTime(NULL,tf,0)!= pTime)
      {
      res=true;
      pTime=iTime(NULL,tf,0);
      }   
   }
   else res = true;
   
   return(res);
}

bool BoxAlert(bool cond,string text)   
{      
   string mess = IndicatorName + "("+Symbol()+","+TF + ")" + text;
   
   if (cond && mess != prevmess)
	{
	Alert (mess);
	prevmess = mess; 
	return(true);
	} 
  
   return(false);  
}

bool Pause(int sec)
{
   if(TimeCurrent() >= preTime + sec) {preTime = TimeCurrent(); return(true);}
   
   return(false);
}

void WarningSound(bool cond,int num,int sec,string sound,datetime ctime)
{
   static int i;
   
   if(cond)
   {
   if(ctime != ptime) i = 0; 
   if(i < num && Pause(sec)) {PlaySound(sound); ptime = ctime; i++;}       	
   }
}

bool EmailAlert(bool cond,string text1,string text2,int num)   
{      
   string subj = "New " + text1 +" Signal from " + IndicatorName + "!!!";    
   string mess = IndicatorName + "("+Symbol()+","+TF + ")" + text2;
   
   if (cond && mess != prevemail)
	{
	if(subj != "" && mess != "") for(int i=0;i<num;i++) SendMail(subj, mess);  
	prevemail = mess; 
	return(true);
	} 
  
   return(false);  
}	         
 
string tf(int timeframe)
{
   switch(timeframe)
   {
   case PERIOD_M1:   return("M1");
   case PERIOD_M5:   return("M5");
   case PERIOD_M15:  return("M15");
   case PERIOD_M30:  return("M30");
   case PERIOD_H1:   return("H1");
   case PERIOD_H4:   return("H4");
   case PERIOD_D1:   return("D1");
   case PERIOD_W1:   return("W1");
   case PERIOD_MN1:  return("MN1");
   default:          return("Unknown timeframe");
   }
}                  