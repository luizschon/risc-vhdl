-- Artefatos codificados por Luiz Carlos Schonarth Junior, 
-- matrícula 19/0055171, UnB - Universidade de Brasília

-- Copyright 2022 Luiz Schonarth

-- This file is part of RISC-VHDL.

-- RISC-VHDL is free software: you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- RISC_VHDL  is distributed in the hope that it will be useful, but 
-- WITHOUT ANY WARRANTY; without even the implied warranty of 
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with RISC-VHDL. If not, see <https://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

package memory is

  constant WSIZE     : integer := 32;
  constant ADDRSIZE  : integer := 12;
  constant TEXTWORDS : integer := (16#2000#/4);
  constant NWORDS    : integer := (2**ADDRSIZE);
  type MemArray is array ( 0 to NWORDS-1 ) of std_logic_vector(0 to WSIZE-1);

  impure function load_mem_file return MemArray;

end package memory;

package body memory is 

  impure function load_mem_file return MemArray is
    file text_file_handle : text;
    file data_file_handle : text;
    variable open_status : FILE_OPEN_STATUS;
    variable text_line : line;
    variable data_line : line;
    variable ram_content : MemArray;
  begin
    file_open(open_status, text_file_handle, "text_mem_dump.txt", read_mode);

    -- Checks if text file was opened, a.k.a. the file exists
    if open_status = open_ok then
      for i in 0 to TEXTWORDS-1 loop
        if not endfile(text_file_handle) then
          readline(text_file_handle, text_line);
          hread(text_line, ram_content(i));
        else
          -- If EOF is detected, fills the memory with '0'
          ram_content(i) := (others => '0');
        end if;
      end loop;
    end if;

    file_close(text_file_handle);

    file_open(open_status, data_file_handle, "data_mem_dump.txt", read_mode);

    -- Checks if data file was opened, a.k.a. the file exists
    if open_status = open_ok then
      for i in TEXTWORDS to NWORDS-1 loop
        if not endfile(data_file_handle) then
          readline(data_file_handle, data_line);
          hread(data_line, ram_content(i));
        else
          -- If EOF is detected, fills the memory with '0'
          ram_content(i) := (others => '0');
        end if;
      end loop;
    end if;

    file_close(data_file_handle);
   
    return ram_content;
  end function; 

end package body memory;
