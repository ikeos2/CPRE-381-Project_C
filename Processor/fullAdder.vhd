-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity fullAdder is
  generic(N : integer := 32);
  port (i_A : in  std_logic_vector(N-1 downto 0);
        i_B : in  std_logic_vector(N-1 downto 0);
        i_C : in  std_logic;
        o_C : out std_logic;
        o_S : out std_logic_vector(N-1 downto 0));
end fullAdder;

architecture dataflow of fullAdder is
signal temp_Sum : std_logic_vector(N downto 0);
begin
  
  temp_Sum <= ('0' & i_A) + ('0' & i_B) + i_C;
  o_C <= temp_Sum(N);
  o_S <= temp_Sum(N-1 downto 0);

end dataflow;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------