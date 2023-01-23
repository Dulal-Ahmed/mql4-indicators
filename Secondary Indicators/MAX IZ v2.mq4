#property indicator_chart_window
#property indicator_buffers 1
#property indicator_width1 1
#property indicator_color1 Magenta
#property indicator_style1 STYLE_DOT

extern string info1 = "Visible or hidden?";
extern bool Show = true;
extern string info2 = "Fixed or 0 for the entire chart";
extern int BarsBack = 0;

double iz[];

int init() {
   IndicatorBuffers(1);
   SetIndexBuffer(0, iz);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexShift(0, 4);
   return(0);
}

int deinit() {
   return(0);
}

int start() {
   if (!Show) return(0);
   int limit;
   if (BarsBack <= 0) {
      int counted_bars = IndicatorCounted();
      if (counted_bars < 0) return(-1);
      if (counted_bars > 0) counted_bars--;
      limit = Bars - counted_bars;
   } else {
      limit = BarsBack;
   }
   for (int i = 0; i < limit; i++) {
      if (CheckAlignment(i)) {
         iz[i] = (iMA(NULL,0,21,3,MODE_EMA,PRICE_CLOSE,i-3) + iMA(NULL,0,55,5,MODE_EMA,PRICE_CLOSE,i-5)) / 2;
      } else {
         iz[i] = EMPTY_VALUE;
      }
   }
   return(0);
}

bool CheckAlignment(int index) {
   if ((iMA(NULL,0,21,3,MODE_EMA,PRICE_CLOSE,index-3) <= iMA(NULL,0,55,5,MODE_EMA,PRICE_CLOSE,index-5) && iMA(NULL,0,55,5,MODE_EMA,PRICE_CLOSE,index-5) <= iMA(NULL,0,89,8,MODE_EMA,PRICE_CLOSE,index-8)) ||
       (iMA(NULL,0,21,3,MODE_EMA,PRICE_CLOSE,index-3) >= iMA(NULL,0,55,5,MODE_EMA,PRICE_CLOSE,index-5) && iMA(NULL,0,55,5,MODE_EMA,PRICE_CLOSE,index-5) >= iMA(NULL,0,89,8,MODE_EMA,PRICE_CLOSE,index-8))) {
       return(true);
   }
   return(false);
}