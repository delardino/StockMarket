-module(client).
-compile(export_all).

%% this module stands for user-clients

request(StockName, Request, Offer, Shares)->
    Pid = pid,
    UserName = username,
    broker:send_request(Pid, UserName, Request, Offer, Shares).
    
