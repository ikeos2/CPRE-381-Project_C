-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity extender8to32 is
  port(i_con        : in  std_logic;
       i_data       : in  std_logic_vector(7 downto 0);  
       o_F          : out std_logic_vector(31 downto 0));   
 end extender8to32;

architecture behav of extender8to32 is
  
begin
  
  extend : process(i_con, i_data)
  begin
    if (i_con = '0') then
      o_F(7 downto 0) <= i_data;
      o_F(31 downto 8) <= (others => '0');
    else
      o_F(7 downto 0) <= i_data;
      o_F(31 downto 8) <= (others => i_data(7));
    end if;
  end process extend;
  
end behav;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------


