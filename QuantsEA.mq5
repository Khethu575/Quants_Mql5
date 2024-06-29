//+------------------------------------------------------------------+
//|                                                     QuantsEA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//+------------------------------------------------------------------+
#property version   "1.00"

// Global variables
input ushort CloseTradeSeconds = 20; 
input double LotSize = 0.01;
input int BWMFILevel = 8; // Set your desired MFI threshold value (assuming 8 as an example)
input ushort InitialStopLossValue = 150;
input ushort MidStopLossValue = 50;
input ushort FinalStopLossValue = 20;
input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;

double previousHigh = 0.0;
double currentHigh = 0.0;
double rangeLow, rangeHigh;
int mfiHandler;

// candlestick object
struct Candlestick
{
    double open;
    double high;
    double low;
    double close;
    double bwmfi;
};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialization code can be added here if needed
   // initialise MFI handler
   mfiHandler = iBWMFI(NULL, TimeFrame, VOLUME_TICK);
   
   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Cleanup code can be added here if needed
}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // functionality to run on every tick event
}

//+------------------------------------------------------------------+
// We write our custom-made functions
//+------------------------------------------------------------------+


//Khethu
void modifyHighs(){
   previousHigh = iHigh(NULL, TimeFrame, 2); // Get the high of the previous candle, Null represents current symbol
   currentHigh = iHigh(NULL, TimeFrame, 1); // Get the high of the currently closed candle, Null represents current symbol

   if (currentHigh > previousHigh)
   {
      // Calculate MFI value
      double mfiArray[];
      CopyBuffer(mfiHandler, 0, 1, 1, mfiArray);

      if (mfiArray[0] < BWMFILevel) // not a spike, we dont have to store the MFI as we just want to check
      {
         currentHigh = NormalizeDouble(currentHigh, _Digits); // Round off the high to desired decimal places
         previousHigh = currentHigh; // Shift the high to the new value
      }
   }
}

// Jude - function to draw our range high and low
void drawRangeBounds(double rgHigh, double rgLow, bool boundsExists=false){
   if(!boundsExists){
      if(ObjectCreate(0,"highLine", OBJ_HLINE, 0 ,0, rgHigh)){ Print("High drawn"); };
      ObjectSetInteger(0, "highLine", OBJPROP_COLOR, clrRoyalBlue);
      
      if(ObjectCreate(0,"lowLine", OBJ_HLINE, 0 ,0, rgLow)){ Print("Low drawn"); };
      ObjectSetInteger(0, "lowLine", OBJPROP_COLOR, clrDarkGreen);
   }
   else {
      ObjectMove(0, "highLine", 0, 0, rgHigh);
      ObjectMove(0, "lowLine", 0, 0, rgLow);
      Print("Range bounds redrawn!");
   }
   
}

//Jude - function check if candle is a spike using MFI
bool isCandleSpike(Candlestick &candle){
   if(candle.bwmfi >= BWMFILevel){ return true; }
   else return false;
}


//Jude - function to determine if spike is bullish (1) or bearish (0)
// in OnTick
ushort getSpikeType(Candlestick &candle){
   if(candle.low < rangeLow){ return 0;}
   else if(candle.high > rangeHigh) {return 1;}
   
   return -1; // if all conditions fail
}

