-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity sb_decoder is
  port(i_sel        : in std_logic_vector(1 downto 0);  
       o_F          : out std_logic_vector(3 downto 0));   
 end sb_decoder;

architecture dataflow of sb_decoder is
  
begin
  
  with i_sel select o_F <=
        "0001" when "00",
        "0010" when "01",
        "0100" when "10",
        "1000" when "11",
        "0000" when others;
  
end dataflow;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

