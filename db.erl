-module(db).
-compile(export_all).
-include_lib("stdlib/include/qlc.hrl"). 

-record(stocks, {index, pid, stock_name, abb_stock_name}).
-record(transactions, {index, pid, user_name, match_price, shares}).
-record(offers, {index, pid, user_name, action, offer, shares}).

init()-> 
    mnesia:create_schema(node()),
    mnesia:start(),
    mnesia:create_table(stocks, 
			[{attributes, record_info(fields, stocks)}]),
    mnesia:create_table(transactions, 
			[{attributes, record_info(fields, transactions)}]),
    mnesia:create_table(offers,
		        [{attributes, record_info(fields, offers)}]).

%% functions for table stocks
new_stock(Index, StockName, AbbStockName)->
   {stock, Index, StockName, AbbStockName}.


insert_stock(Index, Pid, StockName, AbbStockName)->
    Fun = fun() ->
	  mnesia:write(
	  #stocks{index = Index, pid = Pid, stock_name = StockName, abb_stock_name = AbbStockName})
	  end,
    mnesia:transaction(Fun).

select_stocks(Index)->
    Fun = fun() ->
	  mnesia:read({stocks, Index})
       	  end,
       {atomic, [Row]} = mnesia:transaction(Fun),
       io:format(" ~p ~p ~p ~n", [Row#stocks.pid, Row#stocks.stock_name, Row#stocks.abb_stock_name]).
      
%% selects from stocks table by name and returns Pid
select_stock_by_name(Name)->
    Fun = fun() ->
	  mnesia:match_object({stocks, '_','_',Name, '_'})
	  end,
          {atomic, [A|B]} = mnesia:transaction(Fun),
    {stocks, _Index, Pid, _Name, _AbbName} = A,
    Pid.

select_all_stocks()->
    mnesia:transaction(
     fun() -> qlc:eval(qlc:q(
		      [ X || X <- mnesia:table(stocks)]))
     end ).
%% functions for table transactions
new_transaction(Index, UserName, MatchPrice, Shares)->
    {transaction, Index, UserName, MatchPrice, Shares}.

insert_transaction(Index, Pid, UserName, MatchPrice, Shares)->
    Fun = fun() ->
	  mnesia:write(
	  #transactions{index = Index, pid = Pid, user_name = UserName, match_price = MatchPrice, shares = Shares})
	  end,
    mnesia:transaction(Fun).

select_transaction(Index)->
    Fun = fun() ->
	  mnesia:read({transactions, Index})
       	  end,
       {atomic, [Row]} = mnesia:transaction(Fun),
       io:format(" ~p ~p ~p ~p ~n", [Row#transactions.pid, Row#transactions.user_name, 
			       Row#transactions.match_price, Row#transactions.shares]).

select_transaction_with_username(UserName)->
    Fun = fun() ->
	  mnesia:match_object({transactions, '_','_',UserName, '_', '_'})
	  end,
          {atomic, Results} = mnesia:transaction(Fun),
          Results.

select_all_transactions()->
    mnesia:transaction(
     fun() -> qlc:eval(qlc:q(
		      [ X || X <- mnesia:table(transactions)]))
     end ).


%% functions for offers
new_offer(Index, UserName, Action, Offer, Shares)->
    {offer, Index, UserName, Action, Offer, Shares}.

insert_offer(Index, Pid, UserName, Action, Offer, Shares)->
    Fun = fun() ->
	  mnesia:write(
	  #offers{index = Index, pid = Pid, user_name = UserName, action = Action, offer = Offer, shares = Shares})
	  end,
    mnesia:transaction(Fun).

select_offer(Index)->
    Fun = fun() ->
	  mnesia:read({offers, Index})
       	  end,
       {atomic, [Row]} = mnesia:transaction(Fun),
       io:format(" ~p ~p ~p ~p ~p ~n", [Row#offers.pid, Row#offers.user_name, 
				     Row#offers.action, Row#offers.offer, Row#offers.shares]).

select_offer_with_username(UserName)->
    Fun = fun() ->
	  mnesia:match_object({offers, '_','_',UserName, '_', '_','_'})
	  end,
          {atomic, Results} = mnesia:transaction(Fun),
          Results.

select_all_offers()->
    mnesia:transaction(
     fun() -> qlc:eval(qlc:q(
		      [ X || X <- mnesia:table(offers)]))
     end ).
