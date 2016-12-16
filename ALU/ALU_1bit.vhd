-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ALU_1bit is
  port(operation : in std_logic_vector(2 downto 0);
       i_A  : in  std_logic;
       i_B  : in  std_logic;
       i_C  : in  std_logic;
       Less : in  std_logic;
       o_S  : out std_logic;
       o_C  : out std_logic);
end ALU_1bit;

architecture dataflow of ALU_1bit is
  
  signal and_r, or_r, nand_r, nor_r, xor_r, adder_iB, adder_sum : std_logic;

begin
  
  and_r <= i_A and i_B;
  or_r <= i_A or i_B;
  nand_r <= i_A nand i_B;
  nor_r <= i_A nor i_B;
  xor_r <= i_A xor i_B;
  
  with operation(1 downto 0) select adder_iB <=
    (not i_B) when "01",
    (not i_B) when "10",
    i_B when others;
    
  adder_sum <= i_A xor adder_iB xor i_C;
  o_C <= ((i_A xor adder_iB) and i_C) or (i_A and adder_iB);
  
  with operation select o_S <=
    adder_sum when "000",
    adder_sum when "001",
    Less when "010",
    and_r when "011",
    or_r when "100",
    xor_r when "101",
    nand_r when "110",
    nor_r when "111",
    '0' when others;

end dataflow; 

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------    