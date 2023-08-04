#property version   "1.00"

#include<Trade/Trade.mqh>
CTrade trade;
double Lots;
input double risk = 1;
input double SL = 50;
input double RR = 10;
input double Ceiling = 50;
input int BeTriggerPoints = 50;
input int BePufferPoints = 5;
input double PartialCloseFactor = 0.5;
input double PartialClosePointsRR = 4;
string H = "range30";
double bid;
double ask;
double Mid;
double high30;
double low30;

double max=0;
double min=10;
double SLdist;

int OnInit()
  {
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
    
  }

void OnTick()
  {    
     if (H=="range30")
         range30();
     else if(H=="BO_UP_30")
         BO_UP_30();
     else if(H=="BO_DOWN_30")
         BO_DOWN_30();    
     else if(H=="Min_5_UP")
         Min_5_UP(); 
     else if(H=="Min_5_DOWN")
         Min_5_DOWN();  
     else if(H=="Trade_sell")
         Trade_sell();
     else if(H=="Trade_buy")
         Trade_buy();                
     else
         range30(); 
              
  DrawObjects(); 
  TakeProfits();   
  }

void range30()
{
       //Print("in range");
       double open30 = iOpen(_Symbol,PERIOD_M30,1);
       double close30 = iClose(_Symbol,PERIOD_M30,1);
       max=0;
       min=10;
       int Count_Green30 = 2;
       int Count_Red30 = 2;
       
       double openG_30 = iOpen(_Symbol,PERIOD_M30,Count_Green30);
       double closeG_30 = iClose(_Symbol,PERIOD_M30,Count_Green30);
       
       double openR_30 = iOpen(_Symbol,PERIOD_M30,Count_Red30);
       double closeR_30 = iClose(_Symbol,PERIOD_M30,Count_Red30);
       
       
       double Lowest30;
       double Highest30;
       double Rangle_Low30[];
       double Rangle_High30[];
       
       if(openG_30<closeG_30)
       {
           if(open30>close30)
           {
               while(openG_30<closeG_30)
               {
                   openG_30 = iOpen(_Symbol,PERIOD_M30,Count_Green30);
                   closeG_30 = iClose(_Symbol,PERIOD_M30,Count_Green30);
                   Count_Green30++;                                  
               }
               
               ArraySetAsSeries(Rangle_High30,true);
               CopyHigh(_Symbol,PERIOD_M30,0,Count_Green30-1,Rangle_High30);
               Highest30 = ArrayMaximum(Rangle_High30,0,Count_Green30-1);
               
               ArraySetAsSeries(Rangle_Low30,true);
               CopyLow(_Symbol,PERIOD_M30,0,Count_Green30,Rangle_Low30);
               Lowest30 = ArrayMinimum(Rangle_Low30,0,Count_Green30);
               
               if (Highest30 != 0 && Lowest30 != 0)
               {
               
                  high30 = iHigh(_Symbol,PERIOD_M30,Highest30);
                  high30 = NormalizeDouble(high30,_Digits);
                  low30 = iLow(_Symbol,PERIOD_M30,Lowest30);
                  low30 = NormalizeDouble(low30,_Digits);
                  Mid = (high30+low30)/2;
                  Mid = NormalizeDouble(Mid,_Digits);
                  bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                  bid = NormalizeDouble(bid,_Digits);
                  double check1 = iLow(_Symbol,PERIOD_M30,1);
                 // Comment("1low ",Lowest30,"\nhigh ",Highest30,"\nlow30 ",low30,"\nhigh30 ",high30,"\nmid high",Mid,"\nbid",bid,"\ncheck1",check1);
                  
                  if(check1 > Mid)
                  {
                     if(bid > Mid && bid < high30)
                     {    
                         BO_UP_30(); 
                         return;                            
                     }
                  }  
                }              
           }
       }
       
       else if(openR_30>closeR_30)
       {        
           if(open30<close30)
           {
               while(openR_30>closeR_30)
               {
                   openR_30 = iOpen(_Symbol,PERIOD_M30,Count_Red30);
                   closeR_30 = iClose(_Symbol,PERIOD_M30,Count_Red30);
                   Count_Red30++;                
               }
               
               ArraySetAsSeries(Rangle_High30,true);
               CopyHigh(_Symbol,PERIOD_M30,0,Count_Red30,Rangle_High30);
               Highest30 = ArrayMaximum(Rangle_High30,0,Count_Red30);
               
               ArraySetAsSeries(Rangle_Low30,true);
               CopyLow(_Symbol,PERIOD_M30,0,Count_Red30-1,Rangle_Low30);
               Lowest30 = ArrayMinimum(Rangle_Low30,0,Count_Red30-1);
              
               if(Highest30 != 0 && Lowest30 != 0)
               {
                  high30 = iHigh(_Symbol,PERIOD_M30,Highest30);
                  high30 = NormalizeDouble(high30,_Digits);
                  low30 = iLow(_Symbol,PERIOD_M30,Lowest30);
                  low30 = NormalizeDouble(low30,_Digits);
                  Mid = (high30+low30)/2;
                  Mid = NormalizeDouble(Mid,_Digits);
                  bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
                  bid = NormalizeDouble(bid,_Digits);
                  double check1 = iHigh(_Symbol,PERIOD_M30,1);
                  //Comment("low ",Lowest30,"\nhigh ",Highest30,"\nlow30 ",low30,"\nhigh30 ",high30,"\nmid low",Mid,"\nbid",bid,"\ncheck1",check1);
                            
                  if( check1 < Mid)
                  {
                     if(bid < Mid && bid > low30)
                     {                         
                       BO_DOWN_30();  
                       return;                
                     }
                  }
               }
           }
       }   
}
void BO_UP_30()
{  
  // Print("in BO_UP_30");  
   H = "BO_UP_30";                   
   bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
  // Print("bop",high30," ",bid," ",Mid);
   if(bid > high30)
   {     
     H="Min_5_UP";                           
     return;
   }
   else if(bid < Mid)
   {
     H = "range30";
     return;
   }
} 

void BO_DOWN_30()
{
   //Print("in BO_DOWN_30");
   H = "BO_DOWN_30";
   bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(bid < low30)
   {
     H="Min_5_DOWN";    
     return;
   }
   else if(bid > Mid)
   {
     H = "range30";
     return;
   }  
   
}

void Min_5_UP()
{
    // Print("in Min_5_UP");
     H="Min_5_UP";
     bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
     if(bid > (high30 + Ceiling * _Point))
     {
       H = "range30";
       return;
     }
     else if (bid > max)
     { 
       max = bid;
       return;
     }
     else if (bid < high30)
     {
       SLdist = max - high30;
       H = "Trade_sell";
       return;
     }

     else 
     { 
       H="Min_5_UP";
       return;        
     }
}  

 
void Min_5_DOWN()
{
    // Print("in Min_5_DOWN");
     H="Min_5_DOWN";
     ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
     if(ask < (low30 - Ceiling * _Point))
     {
       H = "range30";
       return;
     }
     else if (ask < min)
     { 
       min = ask;
       return;
     }
     else if (ask > low30)
     {
       SLdist = min - low30;
       H = "Trade_buy";
       return;
     }

     else 
     { 
       H="Min_5_DOWN";
       return;        
     }
} 
        
void Trade_sell()  
{ 
    
    //Print("im in sell");

       int spread = (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
       bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
       bid = NormalizeDouble(bid,_Digits);
       double accBal = AccountInfoDouble(ACCOUNT_BALANCE);
       accBal = NormalizeDouble(accBal,_Digits);
       
       max =  NormalizeDouble(max,_Digits);
       SLdist = NormalizeDouble(SLdist,_Digits);

       Lots = ((accBal / ((SLdist+SL)*10000))/(1000/risk));
       //Lots = 0.1;
       Lots = NormalizeDouble(Lots,2);
      // Print("max : ",max);
 
       trade.Sell(Lots,_Symbol,bid,bid + (SL + spread) * _Point,bid-(SL * RR) * _Point,NULL);
       H = "range30";
       return;

}

void Trade_buy()  
{ 

   // Print("im in buy"); 
   

       int spread = (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
 
       double accBal = AccountInfoDouble(ACCOUNT_BALANCE);
       accBal = NormalizeDouble(accBal,_Digits);
       
       ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
       ask = NormalizeDouble(ask,_Digits);
              
       min =  NormalizeDouble(min,_Digits);
       SLdist = NormalizeDouble(SLdist,_Digits);

       Lots = ((accBal / ((SLdist+SL)*10000))/(1000/risk));
      //Lots = 0.1;
       Lots = NormalizeDouble(Lots,2);
      // Print("min : ",min);

       trade.Buy(Lots,_Symbol,ask,ask - (SL - spread) * _Point,ask+(SL * RR) * _Point,NULL);
       H = "range30";
       return;

}

void DrawObjects()
{
    datetime time = iTime(_Symbol,PERIOD_CURRENT,20);
    
    //high
    ObjectDelete(NULL,"high");
    ObjectCreate(NULL,"high",OBJ_TREND,0,time,high30,TimeCurrent(),high30);
    ObjectSetInteger(NULL,"high",OBJPROP_WIDTH,2);
    ObjectSetInteger(NULL,"high",OBJPROP_COLOR,clrWhite);
    
    //Mid
    ObjectDelete(NULL,"mid");
    ObjectCreate(NULL,"mid",OBJ_TREND,0,time,Mid,TimeCurrent(),Mid);
    ObjectSetInteger(NULL,"mid",OBJPROP_WIDTH,2);
    ObjectSetInteger(NULL,"mid",OBJPROP_COLOR,clrWhite);
    
    //low
    ObjectDelete(NULL,"low");
    ObjectCreate(NULL,"low",OBJ_TREND,0,time,low30,TimeCurrent(),low30);
    ObjectSetInteger(NULL,"low",OBJPROP_WIDTH,2);
    ObjectSetInteger(NULL,"low",OBJPROP_COLOR,clrWhite);
}

void TakeProfits()
{
    bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
    bid = NormalizeDouble(bid,_Digits);
    ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
    ask = NormalizeDouble(ask,_Digits);
    for(int i = PositionsTotal()-1; i>=0; i--)
    {
        ulong posTicket = PositionGetTicket(i);
        if(PositionSelectByTicket(posTicket))
        {
            double posOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double posVolume = PositionGetDouble(POSITION_VOLUME);
            double posTp = PositionGetDouble(POSITION_TP);
            double posSl = PositionGetDouble(POSITION_SL);
            ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            
            //BE Stops
            if(posType == POSITION_TYPE_BUY)
            {
                if(bid > posOpenPrice + BeTriggerPoints * _Point)
                { 
                    double sl = posOpenPrice + BePufferPoints * _Point;
                    sl = NormalizeDouble(sl,_Digits);
                    
                    if(sl > posSl)
                    {
                        if(trade.PositionModify(posTicket,sl,posTp)){
                            Print("sl be");
                        }
                    }
                }
            }
            else if(posType == POSITION_TYPE_SELL)
            {
                if(ask < posOpenPrice - BeTriggerPoints * _Point)
                { 
                    double sl = posOpenPrice - BePufferPoints * _Point;
                    sl = NormalizeDouble(sl,_Digits);
                    
                    if(sl < posSl)
                    {
                        if(trade.PositionModify(posTicket,sl,posTp)){
                            Print("sl be");
                        }
                    }
                }
            }
            if(posVolume == Lots)
            {
                double lotsToclose = posVolume * PartialCloseFactor;
                lotsToclose = NormalizeDouble(lotsToclose,2);
                
                if(posType == POSITION_TYPE_BUY)
                {
                    if(bid > posOpenPrice + (PartialClosePointsRR * posSl ) * _Point)
                    {
                        trade.PositionClosePartial(posTicket,lotsToclose);
                    }
                }
                else if(posType == POSITION_TYPE_BUY)
                {
                    if(ask < posOpenPrice - (PartialClosePointsRR * posSl) * _Point)
                    {
                        trade.PositionClosePartial(posTicket,lotsToclose);
                    }
                } 
            }
        }
    }
}