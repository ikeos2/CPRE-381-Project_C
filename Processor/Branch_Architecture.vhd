-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------


-- Branch_Architecture.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a dataflow implementation of our 
-- control logic for the different branch functions
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity Branch_Architecture is
  port(Branch_Sel     : in  std_logic_vector(2 downto 0);
       i_Zero         : in  std_logic;
       i_ALU_Out      : in  std_logic;
       o_F            : out std_logic);
end Branch_Architecture;


architecture dataflow of Branch_Architecture is
  
begin
  
  with Branch_Sel select o_F <=
       i_Zero         when "000",
      (not i_ALU_Out) when "001",        
      (not i_ALU_Out) when "010",
       i_ALU_Out      when "011",
      (not i_ALU_Out) when "100",   
       i_ALU_Out      when "101",
       i_ALU_Out      when "110",
       (not i_Zero)   when "111",
       '0'            when others;
       
end dataflow;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------
       