--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ag;

with Ada.Directories;
with Ada.Streams.Stream_IO;

with League.Strings;
with League.Text_Codecs;

package body Anagram.Grammars.Reader is

   function Read_File
     (File_Name : String)
     return League.Strings.Universal_String;

   function Read_File
     (File_Name : String)
     return League.Strings.Universal_String
   is
      Decoder : constant League.Text_Codecs.Text_Codec :=
        League.Text_Codecs.Codec_For_Application_Locale;

      Size : constant Ada.Directories.File_Size :=
        Ada.Directories.Size (File_Name);

      Length : constant Ada.Streams.Stream_Element_Offset :=
        Ada.Streams.Stream_Element_Count (Size);

      File   : Ada.Streams.Stream_IO.File_Type;
      Data   : Ada.Streams.Stream_Element_Array (1 .. Length);
      Last   : Ada.Streams.Stream_Element_Offset;
   begin
      Ada.Streams.Stream_IO.Open
        (File, Ada.Streams.Stream_IO.In_File, File_Name);
      Ada.Streams.Stream_IO.Read (File, Data, Last);
      Ada.Streams.Stream_IO.Close (File);

      return Decoder.Decode (Data (1 .. Last));
   end Read_File;

   function Read
     (File_Name : String;
      Tail_List : Boolean := False) return Grammar
   is
      Parser : Ag.Parser;
   begin
      Parser.Read (Read_File (File_Name), Tail_List);
      return Parser.Grammar;
   end Read;

end Anagram.Grammars.Reader;
