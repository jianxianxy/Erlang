-module(e2p).
-compile(export_all).

%% 发送请求
request_url() ->
    Url = "/index/index/index",
    SendMethod = "POST",
    %%Argument = [{"username","zengfeng"},{"password", "123456"},{"hello","yes"}],
    Argument = ["msg=ok&username=zengfeng&password=123456"],
    request_url(Url, SendMethod, Argument).
%% 发送请求
%% @param Url 请求Url
%% @param SendMethod 发送方式
%% @param Argument 参数
request_url(Url, SendMethod, Argument) ->
    Host = "127.0.0.1",
    Port = 80,
    request_url(Host, Port, Url, SendMethod,Argument).

%% 发送请求
%% @param Host 服务器地址http://erlide.sourceforge.net/update
%% @param Port 服务器端口
%% @param Url 请求Url
%% @param SendMethod 发送方式
%% @param Argument 参数
request_url(Host, Port, Url, SendMethod, Argument) ->
    {ok, Socket} = gen_tcp:connect(Host, Port, [binary, {packet, 0}]), 
    %取得请求头内容
    RequestHead = get_request_head(Url, SendMethod, Argument),
    %RequestHead = "POST /phperlang/gateway.php?a=1&a2=2 HTTP/1.0\r\nContent-Type:application/x-www-form-urlencoded\r\nContent-Length:84\r\nConnection:close\r\n\r\narr=array('key1' => 'value1', 'key2' = 'value2')&username=zengfeng75&password=123456",
    io:format("REQ:~p~n",[RequestHead]),
    ok = gen_tcp:send(Socket, list_to_binary(RequestHead)),  %向服务器发送请求
    receive_data(Socket, []). %接收服务器返回的数据

%% 取得请求头内容, 如果不带参数
%% @param Url 请求Url
%% @param SendMethod 发送方式
%% @param Argument 参数
get_request_head_method(Url, SendMethod, []) ->
    %第一行,请求方式和协议
    HeadLine_1 = string:join([SendMethod, Url, "HTTP/1.0\r\n"], " "),
    [HeadLine_1,"\r\n"];

%% 取得请求头内容, 带参数,如果是以GET方式发送
%% @param Url 请求Url
%% @param SendMethod 发送方式
%% @param Argument 参数
get_request_head_method(Url, "GET", Argument) ->
    ArgumentStr = arguments_join(Argument),
    UrlAndArgs = string:join([Url, ArgumentStr], "?"),
    %第一行,请求方式和协议
    HeadLine_1 = string:join(["GET", UrlAndArgs, "HTTP/1.0\r\n"], " "),
    [HeadLine_1, "\r\n"];

%% 取得请求头内容, 带参数,如果是以POST方式发送
%% @param Url 请求Url
%% @param SendMethod 发送方式
%% @param Argument 参数
get_request_head_method(Url, "POST", Argument) ->
%第一行,请求方式和协议
    HeadLine_1 = string:join(["POST", Url, "HTTP/1.0\r\n"], " "),
    ArgumentStr = arguments_join(Argument), %处理参数为一个字符串
    ArgumentStrLength = size(list_to_binary(ArgumentStr)), %取得要发送参数的总长度,如果是POST就要向服务说明发送的内容有多长Content-Length
    [HeadLine_1,"Content-Type:application/x-www-form-urlencoded\r\n",
    string:join(["Content-Length:",integer_to_list(ArgumentStrLength),"\r\n"],""),
    "Connection:close\r\n\r\n",ArgumentStr].

%% 取得请求头内容
%% @param Url 请求Url
%% @param SendMethod 发送方式
%% @param Argument 参数
get_request_head(Url, SendMethod, Argument) ->
    get_request_head_method(Url, SendMethod, Argument).

%% 合并参数
arguments_join([]) -> [];
%% 合并参数, 当参数是元组时如[{"username","zengfeng"}, {"passowrd", "123455"}] 
arguments_join([Head | _T] = L) when is_tuple(Head) ->
    List = argument_join_key_value(L, []),  %合并参数的key和value
%io:format("arguments_join's List:~p~n", [List]),
arguments_join(List); %继续进行合并


%% 合并参数, 当参数是列表时如["username=zengfeng", "password=1234"] 
%% 将会返回这种方试 "username=zengfeng&password=1234"
    arguments_join([Head | T] = L) ->
%io:format("arguments_join's T:~p~n", [T]),
case T of
    [] -> Head;
    _Other -> 
	    io:format("========================~n"),
	       string:join(L, "&")
    end.


%合并参数的key和value 如[{"username","zengfeng"}, {"passowrd", "123455"}] 
%% 将会返回这种方试 ["username=zengfeng", "password=1234"] 
argument_join_key_value([{Key, Value} | T], Result) ->
%io:format("Result= ~p~n",[Result]),
    case T of
    [] ->
	    io:format("[]------------~n"), 
	    [(string:join([Key, Value], "="))| Result];                
    [{_Key, _Value} | _T] ->
	    io:format("true----------~n"),
	    argument_join_key_value(T, [(string:join([Key, Value], "=")) | Result])
    end.


%%接收数据
receive_data(Socket, SoFar) ->
    receive
        {tcp, Socket, Bin} ->
	        receive_data(Socket, [Bin | SoFar]);
        {tcp_closed, Socket} ->
	        Content = list_to_binary(lists:reverse(SoFar)), %此时的内容会包含PHP服务器发来的一些头
	        %io:format("~p~n", [Content]),
	        %<<_Head:1480, Data/binary>> = Content,
	        get_content(Content) %将会把头去掉，得到PHP返回的输出
    after 5000 -> %如果超时5秒就结束
	    io:format("over time5000"),
	    receive_data_over_time5000
    end.

%% 取得去掉头的数据
get_content(Data) ->
    %% 取得去掉头的数据,先试着头长度为165.为会如果正文内容长度超过8000时，头内容就不会变
    io:format("~p~n",[Data]).
    %%split_content(Data, 165).

%% 取得去掉头的数据
split_content(Data, StartLength) when StartLength =:= 165 ->
    {B1, B2} = split_binary(Data, StartLength),
    {_B1_1, B1_2} = split_binary(B1, (StartLength - 27)),
    HeadEnd = <<"Content-Type: text/html\r\n\r\n">>,
    if
        B1_2 =:= HeadEnd ->
	        B2;
        B1_2 =/= HeadEnd ->
	        split_content(Data, 180)
    end;
%% 取得去掉头的数据
split_content(Data, StartLength) ->
    {B1, B2} = split_binary(Data, StartLength),
    {_B1_1, B1_2} = split_binary(B1, (StartLength - 27)),
    HeadEnd = <<"Content-Type: text/html\r\n\r\n">>,
    if
        B1_2 =:= HeadEnd ->
            B2;
        B1_2 =/= HeadEnd ->
	        split_content(Data, (StartLength + 1))
    end.
