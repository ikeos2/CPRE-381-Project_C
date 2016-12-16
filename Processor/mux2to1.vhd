-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux2to1 is
  generic(N : integer := 32);
  port (i_A : in  std_logic_vector(N-1 downto 0);
        i_B : in  std_logic_vector(N-1 downto 0);
        i_S : in  std_logic;
        o_F : out std_logic_vector(N-1 downto 0));
end mux2to1;

architecture dataflow of mux2to1 is
begin
     
  o_F <= i_A WHEN i_S = '1' ELSE
         i_B;
    
end dataflow;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------