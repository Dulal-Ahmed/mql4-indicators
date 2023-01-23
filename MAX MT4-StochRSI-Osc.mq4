/////////////////////////////////////////////////////////////////////
// MT4-StockasticRSI-Oscillator.mq4
// Version 1.1
// Copyright © 2007, Bruce Hellstrom (brucehvn)
// bhweb@speakeasy.net
// http://www.metaquotes.net
/////////////////////////////////////////////////////////////////////

/*

This is a port of the VT Trader Stochastic-RSI-Oscillator to MT4.
    
Input Parameters:
RSIPeriod = The RSI Period to use (Default 8)
PeriodK = The Stochastic %K period. (Default 8)
SlowPeriod = The final smoothing (slow) value (Default 3)

Revision History

Version 1.0
* Initial Release

Version 1.1 ( 14 Nov 2007 )
* Fixed bug in HHV/LLV calculations to use current bar.  This avoids values > 100
    
*/    


#property copyright "Copyright © 2007, Bruce Hellstrom (brucehvn)"
#property link      "http: //www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Magenta
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

#property indicator_level1 20.0
#property indicator_level2 80.0
#property indicator_levelcolor PaleTurquoise
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

#define INDICATOR_VERSION "v1.1"


// Input Parameters
extern int RSIPeriod = 8;
extern int PeriodK = 8;
extern int SlowPeriod = 3;

// Buffers
double RSIBuffer[];
double StochBuffer[];
double TempBuffer[];
bool debug = false;


// Other Variables
string ShortName;


/////////////////////////////////////////////////////////////////////
// Custom indicator initialization function
/////////////////////////////////////////////////////////////////////

int init() {

    IndicatorBuffers( 1 );
    SetIndexStyle( 0, DRAW_LINE, STYLE_SOLID, 1 );
    SetIndexBuffer( 0, StochBuffer );
    SetIndexDrawBegin( 0, RSIPeriod );
    
    ShortName = "MT4-StochasticRSI-Oscillator-" + INDICATOR_VERSION + " (" + RSIPeriod + "," + PeriodK + "," + SlowPeriod + ")";
    
    IndicatorShortName( ShortName );
    SetIndexLabel( 0, ShortName );
    
    ArraySetAsSeries( RSIBuffer, true );
    ArraySetAsSeries( TempBuffer, true );
    
    Print( ShortName );
    Print( "Copyright (c) 2007 - Bruce Hellstrom, bhweb@speakeasy.net" );
    
    return( 0 );
}

/////////////////////////////////////////////////////////////////////
// Custom indicator deinitialization function
/////////////////////////////////////////////////////////////////////

int deinit() {
    return( 0 );
}

/////////////////////////////////////////////////////////////////////
// Indicator Logic run on every tick
/////////////////////////////////////////////////////////////////////

int start() {
    
    int counted_bars = IndicatorCounted();
    
    // Check for errors
    if ( counted_bars < 0 ) {
        return( -1 );
    }

    // Last bar will be recounted
    if ( counted_bars > 0 ) {
        counted_bars--;
    }

    // Resize the non-buffer array if necessary
    if ( ArraySize( RSIBuffer ) != ArraySize( StochBuffer ) ) {
        ArraySetAsSeries( RSIBuffer, false );
        ArrayResize( RSIBuffer, ArraySize( StochBuffer ) );
        ArraySetAsSeries( RSIBuffer, true );
    }
    
    if ( ArraySize( TempBuffer ) != ArraySize( StochBuffer ) ) {
        ArraySetAsSeries( TempBuffer, false );
        ArrayResize( TempBuffer, ArraySize( StochBuffer ) );
        ArraySetAsSeries( TempBuffer, true );
    }
    
    
    // Get the upper limit
    int limit = Bars - counted_bars;
    
    for ( int ictr = 0; ictr < limit; ictr++ ) {
        RSIBuffer[ictr] = iRSI( NULL, 0, RSIPeriod, PRICE_CLOSE, ictr );
        if ( debug ) {
            if ( RSIBuffer[ictr] > 100.0 ) {
                Print( "Bar: ", ictr, " RSI: ", RSIBuffer[ictr] );
            }
        }
    }

    for ( ictr = 0; ictr < limit; ictr++ ) {
        double llv = LLV( RSIBuffer, PeriodK, ictr );
        double hhv = HHV( RSIBuffer, PeriodK, ictr );
        
        if ( ( hhv - llv ) > 0 ) {
            TempBuffer[ictr] = ( ( RSIBuffer[ictr] - llv ) /
                                 ( hhv - llv ) ) * 100;
            if ( debug && ictr < 100 ) {
                if ( TempBuffer[ictr] > 100.0 ) {
                    Print( "Bar: ", ictr, " TempBuffer: ", TempBuffer[ictr], " RSI: ", RSIBuffer[ictr], " hhv: ", hhv, " llv:", llv );
                }
            }
        }
    }
    
    for ( ictr = 0; ictr < limit; ictr++ ) {
        StochBuffer[ictr] = iMAOnArray( TempBuffer, 0, SlowPeriod, 0, MODE_EMA, ictr );
    }
    
    return( 0 );
}


double LLV( double& indBuffer[], int Periods, int shift ) {
    double dblRet = 0.0;
    int startindex = shift;
    
    for ( int llvctr = startindex; llvctr < ( startindex + Periods ); llvctr++ ) {
        if ( llvctr == startindex ) {
            dblRet = indBuffer[llvctr];
        }
        dblRet = MathMin( dblRet, indBuffer[llvctr] );
    }
    
    return( dblRet );
}

double HHV( double& indBuffer[], int Periods, int shift ) {
    double dblRet = 0.0;
    int startindex = shift;
    
    for ( int hhvctr = startindex; hhvctr < ( startindex + Periods ); hhvctr++ ) {
        if ( hhvctr == startindex ) {
            dblRet = indBuffer[hhvctr];
        }
        dblRet = MathMax( dblRet, indBuffer[hhvctr] );
    }
    
    return( dblRet );
}



                  

    