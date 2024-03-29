//+------------------------------------------------------------------+
//|                                                           非农.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input datetime 开启时间=D'2019.09.17 12:35';
input int 浮动差值=2;

datetime dd= D'2019.09.17 6:30';
//--- 外部输入变量
extern int 时间周期=1;
extern double 下单量=1;
extern int 止损点数=0;
extern int 止盈点数=0;
extern int 移动止损点数=500;
extern int magic=10010;
datetime buytime=0;
datetime selltime=0;
bool bb = false;
bool cc = false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   if( 开启时间 == Time[0])
   { 
      if(buytime!=Time[0])
      {

         if(OrderSend(Symbol(),OP_BUYSTOP,下单量,Ask+浮动差值/10,50,0,0,Symbol()+"buyStop",magic,0,clrTeal)>0)
         {
            if(OrderSend(Symbol(),OP_SELLSTOP,下单量,Bid-浮动差值/10,50,0,0,Symbol()+"sellStop",magic,0,clrTeal)>0)
            {
               buytime=Time[0];
            } 
         }
         
       }          
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

void closeall()
{ 
    int t=OrdersTotal();
    for(int i=t-1;i>=0;i--)
      {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
          {
            if(OrderType()<=1 && OrderSymbol()==Symbol())
              {
                bool a =OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),Green);
              }
            if(OrderType()>1 && OrderSymbol()==Symbol())
              {
                bool a =OrderDelete(OrderTicket());
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

//标签函数
void Label(string chart_id,string name,int x,int y,int size,color col)
{
    if(ObjectFind(chart_id)<0)
     {
        ObjectCreate(chart_id,OBJ_LABEL,0,0,0);
        ObjectSetText(chart_id,name,size,"黑体",col);
        ObjectSet(chart_id,OBJPROP_XDISTANCE,x);
        ObjectSet(chart_id,OBJPROP_YDISTANCE,y);
        ObjectSet(chart_id,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
        
     }
    else
     {
        ObjectSetText(chart_id,name,size,"宋体",col);
        WindowRedraw();
     }
}

//按钮函数
void Button(string chart_id,color col,int x,int y,string name,int size=0)
{
   ObjectCreate(0,chart_id,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,chart_id,OBJPROP_COLOR,col);
   ObjectSetInteger(0,chart_id,OBJPROP_BGCOLOR,clrDarkGray);
   ObjectSetInteger(0,chart_id,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,chart_id,OBJPROP_YDISTANCE,y);
   ObjectSet(chart_id,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSet(chart_id,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   if(size==0)
    {
      int as=StringLen(name);
      ObjectSetInteger(0,chart_id,OBJPROP_XSIZE,as*17);
    }
   else
    {
      ObjectSetInteger(0,chart_id,OBJPROP_XSIZE,size);
    }
   ObjectSetInteger(0,chart_id,OBJPROP_YSIZE,20);
   ObjectSetString(0,chart_id,OBJPROP_FONT,"黑体");
   ObjectSetString(0,chart_id,OBJPROP_TEXT,name);
   ObjectSetInteger(0,chart_id,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,chart_id,OBJPROP_BORDER_COLOR,clrBlack);
}

//输入框函数
void InputBox(string chart_id,color col,int x,int y,double price)
{
   ObjectCreate(0,chart_id,OBJ_EDIT,0,0,0);
   ObjectSet(chart_id,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
   ObjectSet(chart_id,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,chart_id,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,chart_id,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,chart_id,OBJPROP_XSIZE,60);
   ObjectSetInteger(0,chart_id,OBJPROP_YSIZE,20);

   ObjectSetInteger(0,chart_id,OBJPROP_FONTSIZE,10);

   ObjectSetInteger(0,chart_id,OBJPROP_ALIGN,ALIGN_CENTER);

   ObjectSetInteger(0,chart_id,OBJPROP_READONLY,false);


   ObjectSetInteger(0,chart_id,OBJPROP_COLOR,col);

   ObjectSetInteger(0,chart_id,OBJPROP_BGCOLOR,clrWhite);

   ObjectSetInteger(0,chart_id,OBJPROP_BORDER_COLOR,clrBlack);

   ObjectSetInteger(0,chart_id,OBJPROP_BACK,false);
   ObjectSetString(0,chart_id,OBJPROP_TEXT,DoubleToString(price,6));
   

}
