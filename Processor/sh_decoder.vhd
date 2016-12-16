-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity sh_decoder is
  port(i_sel        : in std_logic;  
       o_F          : out std_logic_vector(3 downto 0));   
 end sh_decoder;

architecture dataflow of sh_decoder is
  
begin
  
  with i_sel select o_F <=
        "0011" when '0',
        "1100" when '1',
        "0000" when others;
  
end dataflow;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------


