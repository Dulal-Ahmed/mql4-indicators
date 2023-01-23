//+------------------------------------------------------------------+
//|                                        MTF_MACD_inColorAlert.mq4 |
//|                                    Copyright © 2007, MQL Service |
//|                                        http://www.mqlservice.com |
//+------------------------------------------------------------------+
//| $Id: //mqlservice/mt4files/experts/indicators/MTF_MACD_inColorAlert.mq4#2 $
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MQL Service"
#property link      "http://www.mqlservice.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 LightGray
#property indicator_width1 1
#property indicator_color2 LightGray
#property indicator_width2 1

extern int  TimeFrame = 0;        //  Default 0  
extern int  Soundon   = 0;        //  Default 0 ...  choices ... 0=Off  1=On     
extern int  AlertBarClose = 1;    //  Default 1 .... number choices ... 1,2,3,4,5  (arrow appears)
extern int  FastEMA = 3;          //  Default 5 ...  present setting           
extern int  SlowEMA = 6;          //  Default 8 ...  present setting
extern int  SignalSMA = 3;        //  Default 3 ...  present setting
extern int  AppliedPrice = 0;     //  Default 0  ... present setting 
 
//---- buffers
double ExtMapBuffer5[];
double ExtMapBuffer6[];

int init()
{
//---- indicators
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,119);
   SetIndexBuffer(0,ExtMapBuffer5);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,119);
   SetIndexBuffer(1,ExtMapBuffer6);
//----
  return(0);
}

int deinit()
{
  return(0);
}

int start()
{
  int    i,limit,counted_bars;
  static datetime _cu, _cd;
  static datetime _at;
 
  counted_bars=IndicatorCounted();
  //---- check for possible errors
  if(counted_bars<0) return(-1);
  //---- the last counted bar will be recounted
  if(counted_bars>0) counted_bars--;
  limit=Bars-counted_bars;

  //---- main loop
  for(i=MathMin(limit,Bars-2); i>=0; i--)
  {
    if(counted_bars==0)
    {
      ExtMapBuffer5[i] = EMPTY_VALUE;
      ExtMapBuffer6[i] = EMPTY_VALUE;
    }
    double _m1 = iCustom(Symbol(), 0, "MAX MTF_MACD_inColor", TimeFrame,FastEMA,SlowEMA,SignalSMA,AppliedPrice, 2, i+1)+
                 iCustom(Symbol(), 0, "MAX MTF_MACD_inColor", TimeFrame,FastEMA,SlowEMA,SignalSMA,AppliedPrice, 3, i+1);
    double _m = iCustom(Symbol(), 0, "MAX MTF_MACD_inColor", TimeFrame,FastEMA,SlowEMA,SignalSMA,AppliedPrice, 2, i)+
                iCustom(Symbol(), 0, "MAX MTF_MACD_inColor", TimeFrame,FastEMA,SlowEMA,SignalSMA,AppliedPrice, 3, i);
    if(i>0)
    {
      if(_m > 0 && _m1 <= 0) {_cu=Time[i]; _cd=0;}// Cross up 
      if(_m < 0 && _m1 >= 0) {_cd=Time[i];_cu=0;} // Cross down
    }
    if(iBarShift(Symbol(),0,_cu)-iBarShift(Symbol(),0,Time[i])==AlertBarClose)
    {
    //Print("up");
      ExtMapBuffer5[i] = Low[i] - 10*Point;
      if(i==0)
      if(_at != Time[0]) // only once per bar
      {
        if(Soundon!=0) Alert(WindowExpertName()," ",Symbol()+Period()," cross UP detected");
        _at = Time[0];
      }
    }
    if(iBarShift(Symbol(),0,_cd)-iBarShift(Symbol(),0,Time[i])==AlertBarClose)
    {     
    //Print("down");      
      ExtMapBuffer6[i] = High[i] + 10*Point;
      if(i==0)
      if(_at != Time[0]) // only once per bar
      {
        if(Soundon!=0) Alert(WindowExpertName()," ",Symbol()+Period()," cross DOWN detected");
        _at = Time[0];
      }
    }
  }
  //---- done
  return(0);
}

//+---- Programmed by Michal Rutka @ MQLService.com -----------------+