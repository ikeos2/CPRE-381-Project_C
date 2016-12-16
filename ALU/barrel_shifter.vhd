-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.math_real.all;

entity barrel_shifter is
  port(shamt : in  std_logic_vector(4 downto 0);
       issra : in  std_logic;
       issll : in  std_logic;
       i_A   : in  std_logic_vector(31 downto 0);
       o_C   : out std_logic_vector(31 downto 0));
end barrel_shifter;

architecture structure of barrel_shifter is

component mux2to1 is
  generic(N : integer := 32);
  port (i_A : in  std_logic_vector(N-1 downto 0);
        i_B : in  std_logic_vector(N-1 downto 0);
        i_S : in  std_logic;
        o_F : out std_logic_vector(N-1 downto 0));
end component;

signal muxjio : std_logic_vector(32*6-1 downto 0);
signal sra_mux : std_logic_vector(0 downto 0);
signal i_A_rev, o_C_rev : std_logic_vector(31 downto 0);

begin

  ---- Flips bits for sll ----
  for0 : for l in 0 to 31 generate 
    i_A_rev(l) <= i_A(31-l);
  end generate;

  ---- Decides between sll and sr* input, so either same input or reversed input ----
  mux0 : mux2to1
  port map(i_A => i_A_rev(31 downto 0),
           i_B => i_A(31 downto 0),
           i_S => issll,
           o_F => muxjio(31 downto 0));

  ---- This is the pad bit decision, either '0' for srl or MSB for sra ----
  mux1 : mux2to1
  generic map(N => 1)
  port map(i_A => i_A(31 downto 31),
               i_B => "0",
               i_S => issra,
               o_F => sra_mux(0 downto 0));

  ---- This is the loop that simulates five levels of muxs
  for1 : for j in 0 to 4 generate
    
    ---- This is the loop that simulates the muxes that pad ----
    for2 : for k in 0 to (2**j)-1 generate 
      
      ---- Either pad with the value decided upon in mux1 or keep the same value ----
      mux2 : mux2to1
      generic map(N => 1)
      port map(i_A => sra_mux(0 downto 0),
               i_B => muxjio(32*(j+1)-1-k downto 32*(j+1)-1-k),
               i_S => shamt(j),
               o_F => muxjio(32*(j+2)-1-k downto 32*(j+2)-1-k));

    end generate;

    ---- Loop that simulates the muxes that are connected to other muxes, not padding ----
    for3 : for i in 0 to 31-(2**j) generate
      
      ---- Either keep the same value or shift by 1,2,4,8, or 16 ----
      mux3 : mux2to1
      generic map(N => 1)
      port map(i_A => muxjio(32*(j)+i+(2**j) downto 32*(j)+i+(2**j)),
               i_B => muxjio(32*(j)+i downto 32*(j)+i),
               i_S => shamt(j),
               o_F => muxjio(32*(j+1)+i downto 32*(j+1)+i));

    end generate;
  
  end generate;
  
  ---- Flips the output for sll instructions ----
  for4 : for m in 0 to 31 generate
    o_C_rev(m) <= muxjio(32*6-1-m);
  end generate;

  ---- Decided to output either the reversed output or the non reverse one ----
  mux4 : mux2to1
  port map(i_A => o_C_rev(32-1 downto 0),
           i_B => muxjio(32*6-1 downto 32*5),
           i_S => issll,
           o_F => o_C(32-1 downto 0));

end structure;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------