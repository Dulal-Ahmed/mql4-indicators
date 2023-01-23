#property  indicator_separate_window
#property  indicator_buffers    9
#property  indicator_color1     clrNONE
#property  indicator_color2     clrNONE
#property  indicator_color3     clrNONE
#property  indicator_color4     clrNONE
#property  indicator_color5     clrNONE
#property  indicator_color8     clrLime
#property  indicator_color9     clrRed
#property  indicator_width1     2
#property  indicator_width2     2
#property  indicator_width3     2
#property  indicator_width4     2
#property  indicator_width5     2
#property  indicator_width8     3
#property  indicator_width9     3
#property  indicator_maximum    2.2
#property  indicator_minimum   -2.2
#property  indicator_levelcolor clrRed
#property  indicator_levelwidth 1 
#property  indicator_levelstyle 2


extern ENUM_TIMEFRAMES    TimeFrame   = PERIOD_M30;  // Time frame
//extern string             BiasInfo1   = "Set Timeframe Dropdown = 4x to 6x Chart time";
//extern string  FYI_BuildInfo   = "2012.10.15 by pips4life of ForexFactory";
//= "Or"; // use 'Current' & Length between 30 & 60 & Adjust Levels";
extern int                Length      = 8;              // Period
extern ENUM_APPLIED_PRICE Price       = PRICE_CLOSE;    // Price
extern int                NlLength    = 5;             // NonLag smoothing period
extern double             Level1      = 1.9;           // Level 1
extern double             Level2      = 0.0;            // Level 2
extern double             Level3      = -1.9;           // Level 3
extern bool               Interpolate = true;            // Interpolate in multi time frame mode
extern double             BiasAmplifier = 10.0;
extern bool               HighlightChange = true;

double ifishua[],ifishub[],ifishda[],ifishdb[],ifisher[],ifisherMain[],ifisherSecondary[],trend[],count[], temp;
string indicatorFileName;
#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Length,Price,NlLength,Level1,Level2,Level3,_buff,_y)

int OnInit() {
    IndicatorBuffers(9);
    SetIndexStyle(0, DRAW_LINE);
    SetIndexStyle(7, DRAW_LINE);
    SetIndexStyle(8, DRAW_LINE);
    SetIndexBuffer(0, ifisher);
    SetIndexBuffer(1, ifishda);
    SetIndexBuffer(2, ifishdb);
    SetIndexBuffer(3, ifishua);
    SetIndexBuffer(4, ifishub);
    SetIndexBuffer(5, trend);
    SetIndexBuffer(6, count);
    SetIndexBuffer(7, ifisherMain);
    SetIndexBuffer(8, ifisherSecondary);
    SetIndexEmptyValue(7, EMPTY_VALUE);
    SetIndexEmptyValue(8, EMPTY_VALUE);
    SetLevelValue(0, Level1);
    SetLevelValue(1, Level2);
    SetLevelValue(2, Level3);
    SetIndexLabel(0, "");
    SetIndexLabel(1, "");
    SetIndexLabel(2, "");
    SetIndexLabel(3, "");
    SetIndexLabel(4, "");
    SetIndexLabel(5, "");
    SetIndexLabel(6, "");
    SetIndexLabel(7, "Slow1");
    SetIndexLabel(8, "Slow2");
    indicatorFileName = WindowExpertName();
    TimeFrame         = MathMax(TimeFrame,_Period);
    IndicatorShortName(timeFrameToString(TimeFrame)+" SLOW Bias ");
    //IndicatorShortName("MAX SLOW Bias");
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) { return;}

int OnCalculate (const int       rates_total,
                 const int       prev_calculated,
                 const datetime& time[],
                 const double&   open[],
                 const double&   high[],
                 const double&   low[],
                 const double&   close[],
                 const long&     tick_volume[],
                 const long&     volume[],
                 const int&      spread[] ) {
    int limit=MathMax(rates_total-prev_calculated-1,0); count[0]=limit;
    if (TimeFrame!=_Period) {
        limit = (int)MathMax(limit,MathMin(rates_total-1,(_mtfCall(6,0)+1)*TimeFrame/_Period));
        if (trend[limit]== 1) CleanPoint(limit,ifishua,ifishub);
        if (trend[limit]==-1) CleanPoint(limit,ifishda,ifishdb);
        int i=limit; for (; i>=0 && !_StopFlag; i--) {
            int y = iBarShift(NULL,TimeFrame,time[i]);
            ifisher[i] = _mtfCall(0,y);
            if (ifisher[i] != 0) {
               if (ifisher[i] > 0) {
                  if (!HighlightChange) ifisherMain[i] = ifisher[i] + pow(ifisher[i], BiasAmplifier);
                  else {
                     if (ifisherMain[i+1] != EMPTY_VALUE) temp = ifisherMain[i+1];
                     else temp = ifisherSecondary[i+1];
                     if (ifisher[i] + pow(ifisher[i], BiasAmplifier) > temp || ifisher[i] + pow(ifisher[i], BiasAmplifier) == ifisherMain[i+1]) {
                        ifisherMain[i] = ifisher[i] + pow(ifisher[i], BiasAmplifier);
                        if (ifisherMain[i+1] == EMPTY_VALUE) ifisherMain[i+1] = ifisherSecondary[i+1];
                     } else {
                        ifisherSecondary[i] = ifisher[i] + pow(ifisher[i], BiasAmplifier);
                        if (ifisherSecondary[i+1] == EMPTY_VALUE) ifisherSecondary[i+1] = ifisherMain[i+1];
                     }
                  }
               } else {
                  if (!HighlightChange) ifisherMain[i] = (-1) * (MathAbs(ifisher[i]) + MathAbs(pow(ifisher[i], BiasAmplifier)));
                  else {
                     if (ifisherMain[i+1] != EMPTY_VALUE) temp = ifisherMain[i+1];
                     else temp = ifisherSecondary[i+1];
                     if ((-1) * (MathAbs(ifisher[i]) + MathAbs(pow(ifisher[i], BiasAmplifier))) < temp || (-1) * (MathAbs(ifisher[i]) + MathAbs(pow(ifisher[i], BiasAmplifier))) == ifisherSecondary[i+1]) {
                        ifisherSecondary[i] = (-1) * (MathAbs(ifisher[i]) + MathAbs(pow(ifisher[i], BiasAmplifier)));
                        if (ifisherSecondary[i+1] == EMPTY_VALUE) ifisherSecondary[i+1] = ifisherMain[i+1];
                     } else {
                        ifisherMain[i] = (-1) * (MathAbs(ifisher[i]) + MathAbs(pow(ifisher[i], BiasAmplifier)));
                        if (ifisherMain[i+1] == EMPTY_VALUE) ifisherMain[i+1] = ifisherSecondary[i+1];
                     }
                  }
               }
            } else {
               ifisherMain[i] = 0;
            }
            trend[i]   = _mtfCall(5,y);
            ifishda[i] = EMPTY_VALUE; 
            ifishdb[i] = EMPTY_VALUE;         
            ifishua[i] = EMPTY_VALUE; 
            ifishub[i] = EMPTY_VALUE;         
            if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,time[i-1]))) continue;
            #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
            int n,k; datetime ctime = iTime(NULL,TimeFrame,y);
            for(n = 1; (i+n)<rates_total && time[i+n] >= ctime; n++) continue;    
            for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) _interpolate(ifisher);
        }
        for (i=limit; i>=0 && !_StopFlag; i--) {
            if (trend[i]== 1) PlotPoint(i,ifishua,ifishub,ifisher);
            if (trend[i]==-1) PlotPoint(i,ifishda,ifishdb,ifisher);
        }
        return(rates_total-i-1);
    }
    if (trend[limit]== 1) CleanPoint(limit,ifishua,ifishub);
    if (trend[limit]==-1) CleanPoint(limit,ifishda,ifishdb);
    int i1=limit; for(int r=Bars-i1-1; i1>=0 && !_StopFlag; i1--,r++) {
        double avg = iNonLagMa(0.1 * (iRsx(iMA(NULL,0,1,0,MODE_SMA,Price,i1),Length,i1,rates_total)-50),NlLength,i1,rates_total);
        ifisher[i1] = (MathExp(2*avg)-1)/(MathExp(2*avg)+1);
        if (ifisher[i1] != 0) {
            if (ifisher[i1] > 0) {
               if (!HighlightChange) ifisherMain[i1] = ifisher[i1] + pow(ifisher[i1], BiasAmplifier);
               else {
                  if (ifisherMain[i1+1] != EMPTY_VALUE) temp = ifisherMain[i1+1];
                  else temp = ifisherSecondary[i1+1];
                  if (ifisher[i1] + pow(ifisher[i1], BiasAmplifier) > temp || ifisher[i1] + pow(ifisher[i1], BiasAmplifier) == ifisherMain[i1+1]) {
                     ifisherMain[i1] = ifisher[i1] + pow(ifisher[i1], BiasAmplifier);
                     if (ifisherMain[i1+1] == EMPTY_VALUE) ifisherMain[i1+1] = ifisherSecondary[i1+1];
                  } else {
                     ifisherSecondary[i1] = ifisher[i1] + pow(ifisher[i1], BiasAmplifier);
                     if (ifisherSecondary[i1+1] == EMPTY_VALUE) ifisherSecondary[i1+1] = ifisherMain[i1+1];
                  }
               }
            } else {
               if (!HighlightChange) ifisherMain[i1] = (-1) * (MathAbs(ifisher[i1]) + MathAbs(pow(ifisher[i1], BiasAmplifier)));
               else {
                  if (ifisherMain[i1+1] != EMPTY_VALUE) temp = ifisherMain[i1+1];
                  else temp = ifisherSecondary[i1+1];
                  if ((-1) * (MathAbs(ifisher[i1]) + MathAbs(pow(ifisher[i1], BiasAmplifier))) < temp || (-1) * (MathAbs(ifisher[i1]) + MathAbs(pow(ifisher[i1], BiasAmplifier))) == ifisherSecondary[i1+1]) {
                     ifisherSecondary[i1] = (-1) * (MathAbs(ifisher[i1]) + MathAbs(pow(ifisher[i1], BiasAmplifier)));
                     if (ifisherSecondary[i1+1] == EMPTY_VALUE) ifisherSecondary[i1+1] = ifisherMain[i1+1];
                  } else {
                     ifisherMain[i1] = (-1) * (MathAbs(ifisher[i1]) + MathAbs(pow(ifisher[i1], BiasAmplifier)));
                     if (ifisherMain[i1+1] == EMPTY_VALUE) ifisherMain[i1+1] = ifisherSecondary[i1+1];
                  }
               }
            }
        } else {
            ifisherMain[i1] = 0;
        }
        trend[i1]   = (i1<rates_total-1) ? trend[i1+1] : 0;
        if (ifisher[i1] < Level1 && ifisher[i1] > Level3) trend[i1] =  0;
        if (ifisher[i1] > Level1)                        trend[i1] =  1;
        if (ifisher[i1] < Level3)                        trend[i1] = -1;
        ifishda[i1] = EMPTY_VALUE; ifishdb[i1] = EMPTY_VALUE;         
        ifishua[i1] = EMPTY_VALUE; ifishub[i1] = EMPTY_VALUE;         
        if (trend[i1]== 1) PlotPoint(i1,ifishua,ifishub,ifisher);
        if (trend[i1]==-1) PlotPoint(i1,ifishda,ifishdb,ifisher);
    }
    return(rates_total-i1-1);
}

#define _rsiInstances     1
#define _rsiInstancesSize 13
double workRsi[][_rsiInstances*_rsiInstancesSize];
#define _price  0
#define _change 1
#define _changa 2

double iRsx(double price, double period, int i, int bars, int instanceNo=0) {
    if (ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);
    int z = instanceNo*_rsiInstancesSize; 
    int r = bars-i-1;
    workRsi[r][z+_price] = price;
    double Kg = (3.0)/(2.0+period), Hg = 1.0-Kg;
    if (r<1) { for (int k=1; k<13; k++) workRsi[r][k+z] = 0; return(50); }  
    double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
    double moa = MathAbs(mom);
    for (int k1=0; k1<3; k1++) {
        int kk = k1*2;
        workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
        workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
        workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
        workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
    }
    return(MathMax(MathMin((mom/MathMax(moa,DBL_MIN)+1.0)*50.0,100.00),0.00));
}

#define _length  0
#define _len     1
#define _weight  2

double  nlmvalues[ ][3];
double  nlmprices[ ][1];
double  nlmalphas[ ][1];

double iNonLagMa(double price, double length, int r, int bars, int instanceNo=0) {
    if (ArrayRange(nlmprices,0) != bars) ArrayResize(nlmprices,bars);
    if (ArrayRange(nlmvalues,0) < instanceNo+1) ArrayResize(nlmvalues,instanceNo+1); r=bars-r-1;
    nlmprices[r][instanceNo]=price;
    if (length<5 || r<3) return(nlmprices[r][instanceNo]);
    if (nlmvalues[instanceNo][_length] != length) {
        double Cycle = 4.0;
        double Coeff = 3.0*M_PI;
        int    Phase = (int)(length-1);
        nlmvalues[instanceNo][_length] =       length;
        nlmvalues[instanceNo][_len   ] = (int)(length*4) + Phase;  
        nlmvalues[instanceNo][_weight] = 0;
        if (ArrayRange(nlmalphas,0) < (int)nlmvalues[instanceNo][_len]) ArrayResize(nlmalphas,(int)nlmvalues[instanceNo][_len]);
        for (int k=0; k<(int)nlmvalues[instanceNo][_len]; k++) {
            double t;
            if (k<=Phase-1) t = 1.0 * k/(Phase-1);
            else  t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(M_PI*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
            nlmalphas[k][instanceNo]        = g * beta;
            nlmvalues[instanceNo][_weight] += nlmalphas[k][instanceNo];
        }
    }
    if (nlmvalues[instanceNo][_weight]>0) {
        double sum = 0;
        for (int k2=0; k2 < (int)nlmvalues[instanceNo][_len] && (r-k2)>=0; k2++) sum += nlmalphas[k2][instanceNo]*nlmprices[r-k2][instanceNo];
        return( sum / nlmvalues[instanceNo][_weight]);
    }
    else return(0);           
}

void CleanPoint(int i,double& first[],double& second[]) {
    if (i>=Bars-2) return;
    if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE)) second[i+1] = EMPTY_VALUE;
    else if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE)) first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[]) {
    if (i>=Bars-2) return;
    if (first[i+1] == EMPTY_VALUE)
        if (first[i+2] == EMPTY_VALUE) { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
        else { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
    else { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf) {
    for (int i=ArraySize(iTfTable)-1; i>=0; i--)
        if (tf==iTfTable[i]) return(sTfTable[i]);
    return("");
}
