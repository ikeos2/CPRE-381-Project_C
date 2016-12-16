-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ALU_control is
  port(funct_code    : in  std_logic_vector(5 downto 0);
       isRtype       : in  std_logic;
       ALUOp         : in  std_logic_vector(5 downto 0);
       operation     : out std_logic_vector(2 downto 0);
       ALUsel        : out std_logic_vector(1 downto 0);
       issv          : out std_logic;
       isJumpReg     : out std_logic;
       isLinkALU     : out std_logic;
       ALU_write     : out std_logic;
       isUnsignedALU : out std_logic);
end ALU_control;

architecture mixed of ALU_control is
  
  component mux2to1 is
    generic(N : integer := 32);
    port (i_A : in  std_logic_vector(N-1 downto 0);
          i_B : in  std_logic_vector(N-1 downto 0);
          i_S : in  std_logic;
          o_F : out std_logic_vector(N-1 downto 0));
  end component;

  signal function_code : std_logic_vector(5 downto 0);

begin

  mux1 : mux2to1
  generic map(N => 6)
  port map(i_A => funct_code,
           i_B => ALUOp,
           i_S => isRtype,
           o_F => function_code);

  with function_code select ALUsel <=
    "00" when "111111",
    "10" when "000000", 
    "10" when "000100",
    "10" when "000011", 
    "10" when "000111", 
    "10" when "000010", 
    "10" when "000110",  
    "01" when others;

  with function_code select operation <=
    "010" when "000000",
    "010" when "000100",
    "001" when "000111",
    "001" when "000011",
    "000" when "000110",
    "000" when "000010",
    "000" when "100000", --add
    "000" when "100001",
    "001" when "100010",
    "001" when "100011",
    "010" when "101010",
    "010" when "101011",
    "011" when "100100",
    "100" when "100101",
    "101" when "100110",
    "111" when "100111",
    "000" when others;

  with function_code select isUnsignedALU <=
    '1' when "100001",
    '1' when "100011",
    '1' when "101011",
    '0' when others;
 
  with function_code select issv <=
    '1' when "000100",
    '1' when "000111",
    '1' when "000110",
    '0' when others;
  
  with function_code select isLinkALU <=
    '1' when "001001",
    '0' when others;
  
  with function_code select ALU_write <=
    '0' when "001000",
    '1' when others;  
    
  with function_code select isJumpReg <=
    '1' when "001000",
    '1' when "001001",
    '0' when others;
    
end mixed;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------
