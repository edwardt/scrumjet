%% @author Alain O'Dea <alain.odea@gmail.com>
%% @copyright 2009 Alain O'Dea.
%% @doc ScrumJet Category Resource.

-module(scrumjet_category_resource).
-author('Alain O\'Dea <alain.odea@gmail.com>').
-export([init/1]).
-export([to_html/2,
         allowed_methods/2,
    	 resource_exists/2,
         % last_modified/2,
         % content_types_provided/2,
         content_types_accepted/2,
         from_webform/2
         % delete_resource/2,
         % post_is_create/2,
         % create_path/2,
         % provide_content/2,
         % accept_content/2,
         % generate_etag/2
    	 ]).

-include("scrumjet.hrl").
-include_lib("webmachine/include/webmachine.hrl").
-include_lib("stdlib/include/qlc.hrl").

-record(context, {category}).

init([]) -> {ok, #context{}}.

resource_exists(ReqData, Context) ->
    ID = wrq:disp_path(ReqData),
    case scrumjet_category:find({id, ID}) of
        [] -> {false, ReqData, Context#context{category=#scrumjet_category{id=ID}}};
        [Category] -> {true, ReqData, Context#context{category=Category}}
    end.

to_html(ReqData, Context=#context{category=#scrumjet_category{id=ID, name=Name}}) ->
    {[<<"<!DOCTYPE html>
<html>
<head>
<title>Category ID: ">>,ID,<<" - ScrumJet</title>
<body>
<h1>">>,Name,<<"</h1>
<h2>Tasks</h2>
<ul>
">>,
list(ID),
<<"
</ul>
</body>
</html>
">>], ReqData, Context}.

%% should accept PUT requests to create new tasks
allowed_methods(ReqData, Context) -> {['GET', 'HEAD', 'PUT'], ReqData, Context}.

content_types_accepted(ReqData, Context) -> {[{"application/x-www-urlencoded", from_webform}], ReqData, Context}.

from_webform(ReqData, Context=#context{category=Category}) ->
    Params = mochiweb_util:parse_qs(wrq:req_body(ReqData)),
    Name = proplists:get_value("name", Params, ""),
    scrumjet_category:store(Category#scrumjet_category{name=Name}),
    {true, ReqData, Context}.

-spec list(string()) -> iolist().
list(ID) -> lists:foldl(fun html:li/2, [], scrumjet_category_task:find({tasks, ID})).