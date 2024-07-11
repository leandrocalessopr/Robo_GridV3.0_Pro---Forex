//+------------------------------------------------------------------+
//|                                               funcoes_gerais.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"

/*

func_total_ordens_abertas_buy_sell()
func_painel()
ObterSpread()
func_AbrirOrdem()
func_fecha_todas_ordens()
func_soma_lotes_abertos()
func_calculDistanciaOrden_buy_favor()
func_calculDistanciaOrden_buy_contra()
func_resultado_total_expert()
func_calculDistanciaOrden_sell_favor()
func_calculDistanciaOrden_sell_contra()

func_analize_bloqueio()
*/


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double func_resultado_total_expert()
  {
   ulong  posTicket_order = 0;
   bool   res_ctrade      = false;
   int    ordens_total    = 0;
   ulong  vetor_tickets[];
   double profit_order    = 0.0;
   string comment         = "";

   HistorySelect(0,TimeCurrent());
   ordens_total = HistoryDealsTotal();

   for(int i = ordens_total-1; i >= 0; i--)
     {
      posTicket_order = HistoryDealGetTicket(i);

      if(posTicket_order > 0)
        {
         comment       = HistoryDealGetString(posTicket_order, DEAL_COMMENT);
         if(comment == "Expert_Grid3.0_Pro")
           {
             printf("entrei..............");
             profit_order += HistoryDealGetDouble(posTicket_order, DEAL_PROFIT);
           }

        }
      else
        {
         i += 1;
         ResetLastError();
         continue;
        }

     } // for

   return profit_order;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int func_analize_bloqueio()
  {

   int retorno = 0;

   ENUM_ACCOUNT_TRADE_MODE account_type = (ENUM_ACCOUNT_TRADE_MODE) AccountInfoInteger(ACCOUNT_TRADE_MODE);

   switch(account_type)
     {
      case ACCOUNT_TRADE_MODE_DEMO:
         retorno = ACCOUNT_TRADE_MODE_DEMO;
         break;
      case ACCOUNT_TRADE_MODE_CONTEST:
         retorno = ACCOUNT_TRADE_MODE_CONTEST;
         break;
      case ACCOUNT_TRADE_MODE_REAL:
         retorno = ACCOUNT_TRADE_MODE_REAL;
         break;
      default:
         retorno = -1; // tipo de conta desconhecido.
         break;
     }

   return retorno;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool func_calculDistanciaOrden_buy_favor(double entryPrice, int input_distancia)
  {

   int retorno              = 0;
   int distancia_atual      = 0;

   if(ultimosDadosAtivo.ask > entryPrice)
     {
      distancia_atual = ((ultimosDadosAtivo.ask - entryPrice) / _Point);
      if(distancia_atual >= input_distancia)
        {
         return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool func_calculDistanciaOrden_buy_contra(double entryPrice, int input_distancia)
  {

   int distancia_atual      = 0;

   if(ultimosDadosAtivo.ask < entryPrice)
     {
      distancia_atual = ((entryPrice - ultimosDadosAtivo.ask) / _Point);

      if(distancia_atual >= input_distancia)
        {
         return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool func_calculDistanciaOrden_sell_favor(double entryPrice, int input_distancia)
  {

   int distancia_atual      = 0;

   if(ultimosDadosAtivo.ask < entryPrice)
     {
      distancia_atual = ((entryPrice - ultimosDadosAtivo.ask) / _Point);

      if(distancia_atual >= input_distancia)
        {
         return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool func_calculDistanciaOrden_sell_contra(double entryPrice, int input_distancia)
  {

   int retorno              = 0;
   int distancia_atual      = 0;

   if(entryPrice < ultimosDadosAtivo.ask)
     {
      distancia_atual = ((ultimosDadosAtivo.ask - entryPrice) / _Point);

      if(distancia_atual >= input_distancia)
        {
         return true;
        }
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double func_soma_lotes_abertos()
  {
   double soma_lote_var = 0.0;

   for(int i = 0; i < ArraySize(abertas_result); i++)
     {
      soma_lote_var += abertas_result[ i ].volume;
     }

   return soma_lote_var;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ObterSpread()
  {
   int spread = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);
   return spread;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool func_AbrirOrdem(ulong           magic_number_param,
                     ENUM_ORDER_TYPE tipoOrdem_param,
                     double          lote_volume_param,
                     double          precoAbertura_param,
                     string          simbolo_param)
  {
   bool retorno = false;
//ZeroMemory(request);
//ZeroMemory(result);
//ZeroMemory(result_chek_money);
   OrderCheck(request, result_chek_money);

   request.action       = TRADE_ACTION_DEAL;
   request.magic        = magic_number_param;
   request.symbol       = simbolo_param;
   request.volume       = lote_volume_param;
   request.deviation    = 10;
   request.price        = precoAbertura_param;
   request.type         = tipoOrdem_param;
   request.tp           = 0.0;
   request.sl           = 0.0;
   request.comment      = "Expert_Grid3.0_Pro";
   request.type_filling = ORDER_FILLING_FOK;

   if(result_chek_money.retcode != TRADE_RETCODE_REQUOTE)
     {
      if(result_chek_money.retcode != TRADE_RETCODE_REJECT)
        {
         if(result_chek_money.retcode != TRADE_RETCODE_INVALID)
           {
            if(result_chek_money.retcode != TRADE_RETCODE_ERROR)
              {
               if(result_chek_money.retcode != TRADE_RETCODE_TIMEOUT)
                 {
                  if(result_chek_money.retcode != TRADE_RETCODE_INVALID_VOLUME)
                    {
                     if(result_chek_money.retcode != TRADE_RETCODE_INVALID_PRICE)
                       {
                        if(result_chek_money.retcode != TRADE_RETCODE_INVALID_STOPS)
                          {
                           if(result_chek_money.retcode != TRADE_RETCODE_NO_MONEY)
                             {
                              if(OrderSend(request,result) == true)
                                {
                                 ArrayResize(abertas_result, ArraySize(abertas_result) + 1);
                                 abertas_result[ArraySize(abertas_result) - 1] = request;
                                 retorno = true;
                                }
                             }
                           else
                              printf("Erro : "+"TRADE_RETCODE_NO_MONEY");
                          }
                        else
                           printf("Erro : "+"TRADE_RETCODE_INVALID_STOPS");
                       }
                     else
                        printf("Erro : "+"TRADE_RETCODE_INVALID_PRICE");
                    }
                  else
                     printf("Erro : "+"TRADE_RETCODE_INVALID_VOLUME");
                 }
               else
                  printf("Erro : "+"TRADE_RETCODE_TIMEOUT");
              }
            else
               printf("Erro : "+"TRADE_RETCODE_ERROR");
           }
         else
            printf("Erro : "+"TRADE_RETCODE_INVALID");
        }
      else
         printf("Erro : "+"TRADE_RETCODE_REJECT");
     }
   else
      printf("Erro : "+"TRADE_RETCODE_REQUOTE");

   return retorno;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_fecha_todas_ordens()
  {
   ulong  posTicket_order = 0;
   bool   res_ctrade      = false;
   int    ordens_total    = 0;
   ulong  vetor_tickets[];

   ordens_total = PositionsTotal();

   for(int i = ordens_total-1; i >= 0; i--)
     {
      posTicket_order = PositionGetTicket(i);

      if(posTicket_order > 0)
        {
         ArrayResize(vetor_tickets, ArraySize(vetor_tickets) + 1);
         vetor_tickets [ ArraySize(vetor_tickets) -1 ] = posTicket_order;
        }
      else
        {
         i += 1;
         ResetLastError();
         continue;
        }
     } // for

   for(int p = 0; p < ArraySize(vetor_tickets); p++)
     {
      res_ctrade = ctrade.PositionClose(vetor_tickets[ p ]);
      if(res_ctrade != true)
        {
         int cont_loop = 1;
         int max_loop  = 5;
         while(cont_loop <= max_loop)
           {
            Sleep(1000);
            res_ctrade = ctrade.PositionClose(vetor_tickets[ p ]);
            if(res_ctrade == true)
              {
               break;
              }
            if(cont_loop == max_loop)
              {
               break;
              }
           } // While.
        }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void func_painel()
  {

   Comment("\n\n\n ---------------- ESTATÍSTICA ESTRATÉGIA ----------------"         + "\n"+

           "\nTOTAL ORDENS ABERTAS : "  + IntegerToString(PositionsTotal())                               + "\n" +
           " TOTAL ORDENS BUY : "       + IntegerToString(func_total_ordens_abertas_buy_sell(1))          + "\n" +
           " TOTAL ORDENS SELL : "      + IntegerToString(func_total_ordens_abertas_buy_sell(0))          + "\n" +
           " SOMA ORDENS BUY : "        + IntegerToString(func_soma_ordens_abertas_buy_sell(1))           + "\n" +
           " SOMA ORDENS SELL : "       + IntegerToString(func_soma_ordens_abertas_buy_sell(0))           + "\n" +
           " TOTAL ORDENS POSTIVAS : "  + IntegerToString(func_total_ordens_abertas_posit_negat(1))       + "\n" +
           " TOTAL ORDENS NEGATIVAS : " + IntegerToString(func_total_ordens_abertas_posit_negat(0))       + "\n" +
           " LUCRO TOTAL EXPERT : "     + DoubleToString(aux_lucro_total_robot, 2) + " / " + DoubleToString ( aux_lucro_total_robot / AccountInfoDouble(ACCOUNT_BALANCE) * 100, 2) + "%\n" +
           " MARGEM LIVRE : "           + DoubleToString ( AccountInfoDouble( ACCOUNT_MARGIN_LEVEL ), 2)  + "\n" +
           " SPREAD : "                 + IntegerToString( SymbolInfoInteger( Symbol(), SYMBOL_SPREAD ) ) + "\n" +
           " DRAWNDOWN : "              + DoubleToString ( AccountInfoDouble ( ACCOUNT_PROFIT  ), 2 ) + " / " +DoubleToString ( func_retorna_drawndown(), 2 ) + "%\n" +
           " MÁXIMO DRAWNDOWN : "       + DoubleToString (aux_max_drawndown,2)+"%");         
  }

void func_maximo_drawndown()
{

     double balance      = AccountInfoDouble ( ACCOUNT_BALANCE );
     double profit_atual = AccountInfoDouble ( ACCOUNT_PROFIT  );
     
     double diff         = profit_atual / balance * 100;     
     
     if ( diff < 0 )
        if ( diff * ( -1 ) > aux_max_drawndown * ( -1 ) ) aux_max_drawndown = diff;
        
}

double func_retorna_drawndown()
{

     double balance      = AccountInfoDouble ( ACCOUNT_BALANCE );
     double profit_atual = AccountInfoDouble ( ACCOUNT_PROFIT  );
     
     double diff         = profit_atual / balance * 100;     
     
     return diff;
}

// 1 p/ buy
// 0 p/ sell
int func_total_ordens_abertas_buy_sell(int flag_aux_param)
  {

   int    cont_ordens_buy  = 0;
   int    cont_ordens_sell = 0;

   ulong  ticket_order       = 0;
   int    tipo_ordem         = 0;

   int    total_ordens       = PositionsTotal();
   int    retorno            = 0;

   for(int i = 0; i < total_ordens; i++)
     {
      ticket_order = PositionGetTicket(i);

      if(ticket_order > 0)
        {

         tipo_ordem         = PositionGetInteger(POSITION_TYPE);

         if(POSITION_TYPE_BUY  == tipo_ordem)
            cont_ordens_buy  += 1;
         else
            if(POSITION_TYPE_SELL == tipo_ordem)
               cont_ordens_sell += 1;

        }
      else
        {

         Sleep(1000);
         i -= 1;
        }
     }

   switch(flag_aux_param)
     {
      case 1:
         retorno = cont_ordens_buy;
         break;
      case 0:
         retorno = cont_ordens_sell;
         break;
     }

   return retorno;
  }

// 1 p/ buy
// 0 p/ sell
double func_soma_ordens_abertas_buy_sell(int flag_aux_param)
  {

   int    cont_ordens_buy  = 0;
   int    cont_ordens_sell = 0;

   ulong  ticket_order       = 0;
   int    tipo_ordem         = 0;

   int    total_ordens       = PositionsTotal();
   double soma_total_buy     = 0.0;
   double soma_total_sell    = 0.0;
   double retorno            = 0.0;

   for(int i = 0; i < total_ordens; i++)
     {
      ticket_order = PositionGetTicket(i);

      if(ticket_order > 0)
        {

         tipo_ordem         = PositionGetInteger(POSITION_TYPE);

         if(POSITION_TYPE_BUY  == tipo_ordem)
            soma_total_buy  += PositionGetDouble(POSITION_PROFIT);
         else
            if(POSITION_TYPE_SELL == tipo_ordem)
               soma_total_sell += PositionGetDouble(POSITION_PROFIT);

        }
      else
        {

         Sleep(1000);
         i -= 1;
        }
     }

   switch(flag_aux_param)
     {
      case 1:
         retorno = cont_ordens_buy;
         break;
      case 0:
         retorno = cont_ordens_sell;
         break;
     }

   return retorno;
  }

// 1 p/ positivas
// 0 p/ negativas
double func_total_ordens_abertas_posit_negat(int flag_aux_param)
  {

   int    cont_ordens_buy  = 0;
   int    cont_ordens_sell = 0;

   ulong  ticket_order       = 0;
   int    tipo_ordem         = 0;

   int    total_ordens       = PositionsTotal();
   double total_ordens_posit = 0.0;
   double total_ordens_negat = 0.0;
   int    retorno            = 0;

   for(int i = 0; i < total_ordens; i++)
     {
      ticket_order = PositionGetTicket(i);

      if(ticket_order > 0)
        {
         double profit = PositionGetDouble(POSITION_PROFIT);

         if(profit < 0)
           {
            total_ordens_negat += profit;
           }
         else
            if(profit > 0)
              {
               total_ordens_posit = profit;
              }


        }
      else
        {

         Sleep(1000);
         i -= 1;
        }
     }

   switch(flag_aux_param)
     {
      case 1:
         retorno = cont_ordens_buy;
         break;
      case 0:
         retorno = cont_ordens_sell;
         break;
     }

   return retorno;
  }
