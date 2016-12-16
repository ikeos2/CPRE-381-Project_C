-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity multiplier is
  generic(N : integer := 32);
  port (i_A      : in  std_logic_vector(N-1 downto 0);
        i_B      : in  std_logic_vector(N-1 downto 0);
        is_multu : in  std_logic;
        o_F      : out std_logic_vector(N-1 downto 0));
end multiplier;

architecture structure of multiplier is
  
  component ALU_32bit is
  generic(N : integer := 32);
  port(operation     : in  std_logic_vector(2 downto 0);
       isUnsignedALU : in  std_logic;
       i_A           : in  std_logic_vector(N-1 downto 0);
       i_B           : in  std_logic_vector(N-1 downto 0);
       o_F           : out std_logic_vector(N-1 downto 0);
       o_C           : out std_logic;
       zero          : out std_logic;
       overflow      : out std_logic); 
  end component; 

  component multiplier_unsigned is
  generic(N : integer := 32);
  port (i_A : in  std_logic_vector(N-1 downto 0);
        i_B : in  std_logic_vector(N-1 downto 0);
        o_F : out std_logic_vector(2*N-1 downto 0));
  end component;

  component mux2to1 is
  generic(N : integer := 32);
  port (i_A : in  std_logic_vector(N-1 downto 0);
        i_B : in  std_logic_vector(N-1 downto 0);
        i_S : in  std_logic;
        o_F : out std_logic_vector(N-1 downto 0));
  end component;
  
  signal mult, rev_mult, result : std_logic_vector(N*2-1 downto 0);
  signal mux1c, mux2c, mux3c : std_logic;
  signal rev_A, rev_B, A, B : std_logic_vector(N-1 downto 0);
  
begin
 
  revA : ALU_32bit
  port map(operation => "001",
           isUnsignedALU => '0',
           i_A => (others => '0'),
           i_B => i_A,
           o_F => rev_A);
 
  mux1c <= i_A(N-1) and (not is_multu);
 
  mux1 : mux2to1
  port map(i_A => rev_A,
           i_B => i_A,
           i_S => mux1c,
           o_F => A);

  revB : ALU_32bit
  port map(operation => "001",
           isUnsignedALU => '0',
           i_A => (others => '0'),
           i_B => i_B,
           o_F => rev_B);
      
  mux2c <= i_B(N-1) and (not is_multu); 
       
  mux2 : mux2to1
  port map(i_A => rev_B,
           i_B => i_B,
           i_S => mux2c,
           o_F => B);
           
  multiply : multiplier_unsigned
  port map(i_A => A,
           i_B => B,
           o_F => mult);
  
  revmult : ALU_32bit
  generic map ( N => 64)
  port map(operation => "001",
           isUnsignedALU => '0',
           i_A => (others => '0'),
           i_B => mult,
           o_F => rev_mult);
         
  mux3c <= (i_B(N-1) xor i_A(N-1));      
           
  mux3 : mux2to1
  generic map( N => 64)
  port map(i_A => rev_mult,
           i_B => mult,
           i_S => mux3c,
           o_F => result);           

  o_F <= result(N-1 downto 0);
  
end structure;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------