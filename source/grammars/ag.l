%x In_Rule

%%

"::="                   {Equal_Token}
Inherited               {Inherited_Token}
Synthesized             {Synthesized_Token}
attributes              {Attributes_Token}
Rules                   {Rules_Token}
[A-Za-z0-9]+            {Identifier_Token}
"Token"                 {Token_Token}
"(."                    {Open_Rule_Token}
<In_Rule>([^.]|\.[^)])+ {Rule_Body_Token}
".)"                    {Close_Rule_Token}
for                     {For_Token}
[A-Za-z0-9+*?()^\[\]]+  {Regexp_Token}
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
[ \n]+                  {Spaces}
"--"[^\n]*              {Comment}

%%
