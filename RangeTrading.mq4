//+------------------------------------------------------------------+
//|                                                 RangeTrading.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4


//--- plot 上区间压力
#property indicator_label1  "上区间压力"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot 中区间压力_上区间支撑
#property indicator_label2  "中区间压力_上区间支撑"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot 中区间支撑_下区间压力
#property indicator_label3  "中区间支撑_下区间压力"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot 下区间支撑
#property indicator_label4  "下区间支撑"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1


//--- 外部输入变量
extern int 区间差值=20;
extern int 时间周期=0;
extern double 下单量=1;
extern int 止损点数=0;
extern int 止盈点数=0;
extern int 移动止损点数=500;
extern int magic=20010;
datetime buytime=0;
datetime selltime=0;
bool bb = false;
bool cc = false;
int 上区间压力线=0.00;
int 中区间压力_上区间支撑=0.00;
int 中区间支撑_下区间压力=0.00;
int 下区间支撑=0.00;


//--- indicator buffers
double         上区间压力Buffer[];
double         中区间压力_上区间支撑Buffer[];
double         中区间支撑_下区间压力Buffer[];
double         下区间支撑Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,上区间压力Buffer);
   SetIndexBuffer(1,中区间压力_上区间支撑Buffer);
   SetIndexBuffer(2,中区间支撑_下区间压力Buffer);
   SetIndexBuffer(3,下区间支撑Buffer);
   
   Label("EA","支撑压力线交易EA",10,15,15,clrWhite);
   Button("closeall",clrBlack,165,38,"平本货币所有市价单");
   
   InputBox("上A1",clrBlack,165,60,Ask);
   Button("上B1",clrBlack,104,60,"上区间压力线",92);
   //ObjectGetDouble(,OBJPROP_NAME
   
   InputBox("中A1",clrBlack,165,80,Ask);
   Button("中B1",clrBlack,104,80,"中压力上支撑",92);
   
   InputBox("中A2",clrBlack,165,100,Ask);
   Button("中B2",clrBlack,104,100,"中支撑下压力",92);
   
   InputBox("下A1",clrBlack,165,120,Ask);
   Button("下B1",clrBlack,104,120,"下区间支撑线",92);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //for(int i=rates_total-1;i>=0;i--)
   //{
   //   上区间压力Buffer[i]=上区间压力线;
   //   中区间压力_上区间支撑Buffer[i]=中区间压力_上区间支撑;
   //   中区间支撑_下区间压力Buffer[i]=中区间支撑_下区间压力;
   //   下区间支撑Buffer[i]=下区间支撑;
   //}
   return(rates_total);
}
  
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam=="closeall")
      {
         closeall();
      }
      if(sparam=="上B1")
      {
         
         ObjectCreate(01,"上区间压力线",OBJ_HLINE,0,0,上区间压力线);
      }
      if(sparam=="中B1")
      {
         ObjectCreate(02,"中区间压力_上区间支撑",OBJ_HLINE,0,0,中区间压力_上区间支撑);
      }
      if(sparam=="中B2")
      {
         ObjectCreate(03,"中区间支撑_下区间压力",OBJ_HLINE,0,0,中区间支撑_下区间压力);
      }
      if(sparam=="下B1")
      {
         ObjectCreate(04,"下区间支撑",OBJ_HLINE,0,0,下区间支撑);
      }
   }


}
//+------------------------------------------------------------------+
void OnTick()
{
   //中区间交易
   if(Bid <中区间压力_上区间支撑Buffer[0] && Bid>=中区间压力_上区间支撑Buffer[0]-区间差值)
   {
      closesell(Symbol()+"sell",magic);
      closebuy(Symbol()+"buy",magic);
      if(selltime!=Time[0])
      {
         if(sell(下单量,止损点数,止盈点数,Symbol()+"sell",magic)>0)
         {
            selltime=Time[0];
         }
      }
   }
   if(Bid >中区间支撑_下区间压力Buffer[0] && Bid<=中区间支撑_下区间压力Buffer[0]+区间差值)
   {
      closesell(Symbol()+"sell",magic);
      closebuy(Symbol()+"buy",magic);
      if(buytime!=Time[0])
       {
         if(buy(下单量,止损点数,止盈点数,Symbol()+"buy",magic)>0)
          {
            buytime=Time[0];
          }
       }
   }
   
   //上区间交易
   if(Bid <上区间压力Buffer[0] && Bid>=上区间压力Buffer[0]-区间差值)
   {
      closesell(Symbol()+"sell",magic);
      closebuy(Symbol()+"buy",magic);
      if(selltime!=Time[0])
      {
         if(sell(下单量,止损点数,止盈点数,Symbol()+"sell",magic)>0)
         {
            selltime=Time[0];
         }
      }
   }
   if(Bid >中区间压力_上区间支撑Buffer[0] && Bid<=中区间压力_上区间支撑Buffer[0]+区间差值)
   {
      closesell(Symbol()+"sell",magic);
      closebuy(Symbol()+"buy",magic);
      if(buytime!=Time[0])
       {
         if(buy(下单量,止损点数,止盈点数,Symbol()+"buy",magic)>0)
          {
            buytime=Time[0];
          }
       }
   }
      //下区间交易
   if(Bid <中区间支撑_下区间压力Buffer[0] && Bid>=中区间支撑_下区间压力Buffer[0]-区间差值)
   {
      closesell(Symbol()+"sell",magic);
      closebuy(Symbol()+"buy",magic);
      if(selltime!=Time[0])
      {
         if(sell(下单量,止损点数,止盈点数,Symbol()+"sell",magic)>0)
         {
            selltime=Time[0];
         }
      }
   }
   if(Bid >下区间支撑Buffer[0] && Bid<=下区间支撑Buffer[0]+区间差值)
   {
      closesell(Symbol()+"sell",magic);
      closebuy(Symbol()+"buy",magic);
      if(buytime!=Time[0])
       {
         if(buy(下单量,止损点数,止盈点数,Symbol()+"buy",magic)>0)
          {
            buytime=Time[0];
          }
       }
   }
   //超出区间平仓不交易
   if(Bid <下区间支撑Buffer[0])
   {
      closesell(Symbol()+"sell",magic);
      closebuy(Symbol()+"buy",magic);
      
   }
   if(Bid >上区间压力Buffer[0])
   {
      closebuy(Symbol()+"buy",magic);
      closesell(Symbol()+"sell",magic);
   }

   MoveStop();


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
double InputBox(string chart_id,color col,int x,int y,double price)
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
   
   return price;
}
