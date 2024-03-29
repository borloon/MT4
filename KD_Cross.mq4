//+------------------------------------------------------------------+
//|                                                     MA_Cross.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//--- 外部输入变量
extern int KD指标_k=24;
extern int KD指标_d=3;
extern int KD指标_slow=3;
extern int 时间周期=15;
extern double 下单量=1;
extern int 止损点数=0;
extern int 止盈点数=0;
extern int 移动止损点数=500;
extern int magic=52142;
datetime buytime=0;
datetime selltime=0;
bool jin1 = false;
bool jin2 = false;
bool jin3 = false;
bool si1 =false;
bool si2 =false;
bool si3 =false;
int qujian=0;//区间0为错误区间，上区间（k && d>80）：1            中区间（20<k && d<80）：2                下区间（k && d<20）：3

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {

  }
void OnTick()
  {
      double  left_k =iStochastic(Symbol(),时间周期,KD指标_k,KD指标_d,KD指标_slow,MODE_SMMA,0,MODE_MAIN,2);
      double  left_d =iStochastic(Symbol(),时间周期,KD指标_k,KD指标_d,KD指标_slow,MODE_SMMA,0,MODE_SIGNAL,2);
      double right_k =iStochastic(Symbol(),时间周期,KD指标_k,KD指标_d,KD指标_slow,MODE_SMMA,0,MODE_MAIN,0);
      double right_d =iStochastic(Symbol(),时间周期,KD指标_k,KD指标_d,KD指标_slow,MODE_SMMA,0,MODE_SIGNAL,0);

      
      if(left_k<left_d && right_k>right_d )//金叉 
      {
         if(right_k<20 && right_d<20)
         {
            jin3=true;
         }
         if(right_k>80 && right_d>80)
         {
            jin1=true;
         }
         if(right_k<=80 && right_d<=80 && right_k>=20 && right_d>=20 )
         {
            jin2=true;
         }
         
      }
      if(left_k>left_d && right_k<right_d )//死叉 
      {
         if(right_k<20 && right_d<20)
         {
            si3 =true;
         }
         if(right_k>80 && right_d>80)
         {
            si1=true;
         }
         if(right_k<=80 && right_d<=80 && right_k>=20 && right_d>=20 )
         {
            si2=true;
         }
         
      }
      
      if(jin2)
      {
         closesell(Symbol()+"sell",magic);
         if(buytime!=Time[0])
          {
           
            if(buy(下单量,止损点数,止盈点数,Symbol()+"buy",magic)>0)
             {
               buytime=Time[0];
             }
          }
          jin2=false;
      }
      if(right_k>20 && right_d>20 && jin3)
      {
         closesell(Symbol()+"sell",magic);
         if(buytime!=Time[0])
          {
           
            if(buy(下单量,止损点数,止盈点数,Symbol()+"buy",magic)>0)
             {
               buytime=Time[0];
             }
          }
          jin3=false;
      }
      if(si2)
      {
         closebuy(Symbol()+"buy",magic);
         if(selltime!=Time[0])
          {
            if(sell(下单量,止损点数,止盈点数,Symbol()+"sell",magic)>0)
              {
                selltime=Time[0];
              }
          }
          si2=false;
      }
      if(right_k<80 && right_d<80 && si1)
      {
         closebuy(Symbol()+"buy",magic);
         if(selltime!=Time[0])
          {
            if(sell(下单量,止损点数,止盈点数,Symbol()+"sell",magic)>0)
              {
                selltime=Time[0];
              }
          }
          si1=false;
      }

      MoveStop();

   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+


//移动止损
void MoveStop()
{
   for(int i=0;i<OrdersTotal();i++)//移动止损通用代码,次代码会自动检测buy和sell单并对其移动止损
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
          if(OrderType()==0 && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
            {
               if((Bid-OrderOpenPrice())>=Point*移动止损点数)
                {
                   if(OrderStopLoss()<(Bid-Point*移动止损点数) || (OrderStopLoss()==0))
                     {
                        bool a =OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*移动止损点数,OrderTakeProfit(),0,clrForestGreen);
                     }
                }      
            }
          if(OrderType()==1 && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
            {
              if((OrderOpenPrice()-Ask)>=(Point*移动止损点数))
                {
                   if((OrderStopLoss()>(Ask+Point*移动止损点数)) || (OrderStopLoss()==0))
                     {
                        bool a =OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*移动止损点数,OrderTakeProfit(),0,clrForestGreen);
                     }
                }
            }
        }
   }
}

void closebuy(string com,int magic1)
{
   int t=OrdersTotal();
   for(int i=t-1;i>=0;i--)
   {
     if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
       {
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderComment()==com && OrderMagicNumber()==magic1)
           {
             bool a =OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),300,clrYellow);
           }
       }
   }
}
void closesell(string com,int magic1)
{
   int t=OrdersTotal();
   for(int i=t-1;i>=0;i--)
   {
     if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
       {
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderComment()==com && OrderMagicNumber()==magic1)
           {
             bool a =OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),300,clrYellow);
           }
       }
   }
}
int buy(double lots,double sl,double tp,string com,int buymagic)
{
    int a=0;
    bool zhaodan=false;
    for(int i=0;i<OrdersTotal();i++)
      {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
          {
            string zhushi=OrderComment();
            int ma=OrderMagicNumber();
            if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && zhushi==com && ma==buymagic)
              {
                zhaodan=true;
                break;
              }
          }
      }
    if(zhaodan==false)
      {
        if(sl!=0 && tp==0)
         {
          a=OrderSend(Symbol(),OP_BUY,lots,Ask,50,Ask-sl*Point,0,com,buymagic,0,clrTeal);
         }
        if(sl==0 && tp!=0)
         {
          a=OrderSend(Symbol(),OP_BUY,lots,Ask,50,0,Ask+tp*Point,com,buymagic,0,clrTeal);
         }
        if(sl==0 && tp==0)
         {
          a=OrderSend(Symbol(),OP_BUY,lots,Ask,50,0,0,com,buymagic,0,clrTeal);
         }
        if(sl!=0 && tp!=0)
         {
          a=OrderSend(Symbol(),OP_BUY,lots,Ask,50,Ask-sl*Point,Ask+tp*Point,com,buymagic,0,clrTeal);
         } 
      }
    return(a);
}
int sell(double lots,double sl,double tp,string com,int sellmagic)
{
    int a=0;
    bool zhaodan=false;
     for(int i=0;i<OrdersTotal();i++)
      {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
          {
            string zhushi=OrderComment();
            int ma=OrderMagicNumber();
            if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && zhushi==com && ma==sellmagic)
              {
                zhaodan=true;
                break;
              }
          }
      }
    if(zhaodan==false)
      {
        if(sl==0 && tp!=0)
         {
           a=OrderSend(Symbol(),OP_SELL,lots,Bid,50,0,Bid-tp*Point,com,sellmagic,0,clrRed);
         }
        if(sl!=0 && tp==0)
         {
           a=OrderSend(Symbol(),OP_SELL,lots,Bid,50,Bid+sl*Point,0,com,sellmagic,0,clrRed);
         }
        if(sl==0 && tp==0)
         {
           a=OrderSend(Symbol(),OP_SELL,lots,Bid,50,0,0,com,sellmagic,0,clrRed);
         }
        if(sl!=0 && tp!=0)
         {
           a=OrderSend(Symbol(),OP_SELL,lots,Bid,50,Bid+sl*Point,Bid-tp*Point,com,sellmagic,0,clrRed);
         }
      }
    return(a);
}
