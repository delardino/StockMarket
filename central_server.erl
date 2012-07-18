%%%-------------------------------------------------------------------
%%% @author aydin <delardino@delardino>
%%% @copyright (C) 2012, aydin
%%% @doc
%%%
%%% @end
%%% Created : 11 Jul 2012 by aydin <delardino@delardino>
%%%-------------------------------------------------------------------
-module(central_server).

-behaviour(gen_server).

%% API
-compile(export_all).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
	 terminate/2, code_change/3]).

-define(SERVER, ?MODULE). 

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the server
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
%% administrator functions
start() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).
    %%db:init().

new_stock(Index, StockName, AbbStockName)->
    gen_server:call(?MODULE, {new_stock, Index,StockName,AbbStockName}).

list_stocks()->
    gen_server:call(?MODULE, {list_stocks}).





%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Initializes the server
%%
%% @spec init(Args) -> {ok, State} |
%%                     {ok, State, Timeout} |
%%                     ignore |
%%                     {stop, Reason}
%% @end
%%--------------------------------------------------------------------
init([]) ->
   %% db:init(),
    {ok, #state{}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling call messages
%%
%% @spec handle_call(Request, From, State) ->
%%                                   {reply, Reply, State} |
%%                                   {reply, Reply, State, Timeout} |
%%                                   {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, Reply, State} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_call({new_stock, Index, StockName, AbbStockName}, _From, State) ->
    Reply = stock_entry(Index, StockName, AbbStockName),
    {reply, Reply, State};

handle_call({list_stocks}, _From, State)->
    Reply = all_stocks(),
    {reply, Reply, State}.
    

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling cast messages
%%
%% @spec handle_cast(Msg, State) -> {noreply, State} |
%%                                  {noreply, State, Timeout} |
%%                                  {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
stop()->
    gen_server:cast(?MODULE, stop).

handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handling all non call/cast messages
%%
%% @spec handle_info(Info, State) -> {noreply, State} |
%%                                   {noreply, State, Timeout} |
%%                                   {stop, Reason, State}
%% @end
%%--------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called by a gen_server when it is about to
%% terminate. It should be the opposite of Module:init/1 and do any
%% necessary cleaning up. When it returns, the gen_server terminates
%% with Reason. The return value is ignored.
%%
%% @spec terminate(Reason, State) -> void()
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Convert process state when code is changed
%%
%% @spec code_change(OldVsn, State, Extra) -> {ok, NewState}
%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

stock_entry(Index, Name, AbbName)->
    Pid = spawn(db, new_stock, [Index, Name, AbbName]),
    db:insert_stock(Index, Pid, Name, AbbName),
    {stock_entry, Index, Pid, Name, AbbName}.

stock_by_index(Index)->
    db:select_stocks(Index).

all_stocks()->
    db:select_all_stocks().
