%x In_Rule
%s With_Regexp
%%

"::="                   {Equal_Token}
Inherited               {Inherited_Token}
Synthesized             {Synthesized_Token}
attributes              {Attributes_Token}
Rules                   {Rules_Token}
Token                   {Token_Token}
for                     {For_Token}
[A-Za-z0-9_]+           {Identifier_Token}
"(."                    {Open_Rule_Token}
<In_Rule>([^.]|\.[^)])+ {Rule_Body_Token}
".)"                    {Close_Rule_Token}
";"                     {Semicolon_Token}
"("                     {Open_Production_Name_Token}
")"                     {Close_Production_Name_Token}
"<"                     {Open_Part_Name_Token}
">"                     {Close_Part_Name_Token}
"{"                     {Open_List_Token}
"}"                     {Close_List_Token}
"["                     {Open_Option_Token}
"]"                     {Close_Option_Token}
":"                     {Colon_Token}
"|"                     {Or_Token}
<With_Regexp>[A-Za-z0-9_.+*?()^\[\]]+  {Regexp_Token}
[ \t]+                  {Spaces}
"--"[^\n]*              {Comment}
[\n]+                   {New_Line}

%%
