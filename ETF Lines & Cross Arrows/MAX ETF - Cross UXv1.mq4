//+------------------------------------------------------------------+
//|                               MAX Trading System ETF Indicator   |
//|                                                                  |
//|     Created by Alexey for www.maxtradingsystem.com               |
//|              MAX ETF   - MA of TEMA                              |
//|                                                                  |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2013, www.maxtradingsystem.com"
#property  link      "http://www.maxtradingsystem.com/"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 White

double g_ibuf_76[];
double g_ibuf_80[];
int gi_84 = 0;
int LastAlertBar = 0;
extern string Ind_1_set = "--- settings of first indicator ---";
extern int EMA_Period_1=13;
extern int EMA_Method_1=2;
extern int EMA_Shift_1=0;
extern int EMA_Applied_1=0;

extern int MAofTema_Period_1=3;
extern int MAofTema_Method_1=2;
extern int MAofTema_Shift_1=0;

extern string Ind_2_set = "--- settings of second indicator ---";
extern int EMA_Period_2=13;
extern int EMA_Method_2=2;
extern int EMA_Shift_2=0;
extern int EMA_Applied_2=1;

extern int MAofTema_Period_2=3;
extern int MAofTema_Method_2=2;
extern int MAofTema_Shift_2=0;

extern int ArrowShifting = 50;
extern int Show_Alert = 0;
extern int Play_Sound = 0;
extern int Send_Mail = 0;
//extern bool AlertOnBarClose = true;
extern string SoundFilename = "alert.wav";

int init() {
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, g_ibuf_76);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, g_ibuf_80);
   LastAlertBar=Bars-1;
   
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int li_0;
   int li_68 = IndicatorCounted();
   if (li_68 < 0) return (-1);
   if (li_68 > 0) li_68--;
   int li_72 = Bars - li_68;
   bool li_76 = FALSE;
   for (int i = 0; i <= li_72; i++) {
      g_ibuf_76[i] = 0;
      g_ibuf_80[i] = 0;
      double tema1      = iCustom(NULL, 0, "MAX ETF - UXv1", EMA_Period_1, EMA_Method_1, EMA_Shift_1, EMA_Applied_1, MAofTema_Period_1, MAofTema_Method_1, MAofTema_Shift_1, 1, i);
      double tema1_prev = iCustom(NULL, 0, "MAX ETF - UXv1", EMA_Period_1, EMA_Method_1, EMA_Shift_1, EMA_Applied_1, MAofTema_Period_1, MAofTema_Method_1, MAofTema_Shift_1, 1, i+1);
      double tema2      = iCustom(NULL, 0, "MAX ETF - UXv1", EMA_Period_2, EMA_Method_2, EMA_Shift_2, EMA_Applied_2, MAofTema_Period_2, MAofTema_Method_2, MAofTema_Shift_2, 1, i);
      double tema2_prev = iCustom(NULL, 0, "MAX ETF - UXv1", EMA_Period_2, EMA_Method_2, EMA_Shift_2, EMA_Applied_2, MAofTema_Period_2, MAofTema_Method_2, MAofTema_Shift_2, 1, i+1);
      if (tema1 > tema2 && tema1_prev < tema2_prev) {
         g_ibuf_76[i] = tema2 - ArrowShifting*Point;
         if (li_76 == FALSE && gi_84 != 1 && Bars>LastAlertBar) {
            LastAlertBar=Bars;
            if (Show_Alert == 1) Alert("Cross Up on " + Symbol() + "_" + Period() + " " + EMA_Period_1 + "/" + EMA_Period_2 + " Tema");
            if (Play_Sound == 1) PlaySound(SoundFilename);
            if (Send_Mail == 1) SendMail("Cross Up on " + Symbol() + "_" + Period() + " " + EMA_Period_1 + "/" + EMA_Period_2 + " Tema", "");
            gi_84 = 1;
         }
         if (li_76 == FALSE) li_76 = TRUE;
      } else {
      if (tema1 < tema2 && tema1_prev > tema2_prev) {
            g_ibuf_80[i] = tema2 + ArrowShifting*Point;
            if (li_76 == FALSE && gi_84 != -1 && Bars>LastAlertBar) {
               LastAlertBar=Bars;
               if (Show_Alert == 1) Alert("Cross Down on " + Symbol() + "_" + Period() + " " + EMA_Period_1 + "/" + EMA_Period_2 + " Tema");
               if (Play_Sound == 1) PlaySound(SoundFilename);
               if (Send_Mail == 1) SendMail("Cross Down on " + Symbol() + "_" + Period() + " " + EMA_Period_1 + "/" + EMA_Period_2 + " Tema", "");
               gi_84 = -1;
            }
            if (li_76 == FALSE) li_76 = TRUE;
         }
      }
   }
   return (0);
}