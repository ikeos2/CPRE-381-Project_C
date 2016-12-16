-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity onesComp is
  generic(N : integer := 32);
  port (i_A : in  std_logic_vector(N-1 downto 0);
        o_F : out std_logic_vector(N-1 downto 0));
end onesComp;

architecture dataflow of onesComp is
begin
      
  o_F <= NOT i_A;
 
end dataflow;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------