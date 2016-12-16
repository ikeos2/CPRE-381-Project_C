-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ALU is
  port(operation     : in  std_logic_vector(2 downto 0);
       ALUsel        : in  std_logic_vector(1 downto 0);
       shamt         : in  std_logic_vector(4 downto 0);
       i_A           : in  std_logic_vector(31 downto 0);
       i_B           : in  std_logic_vector(31 downto 0);
       issv          : in  std_logic;
       isUnsignedALU : in  std_logic;
       zero          : out std_logic;
       carry_out     : out std_logic;
       overflow      : out std_logic;
       ALU_out       : out std_logic_vector(31 downto 0));
end ALU;

architecture structure of ALU is
  
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

  component multiplier is
    generic(N : integer := 32);
    port (i_A      : in  std_logic_vector(N-1 downto 0);
          i_B      : in  std_logic_vector(N-1 downto 0);
          is_multu : in  std_logic;
          o_F      : out std_logic_vector(N-1 downto 0));
  end component;

  component barrel_shifter is
    port(shamt : in  std_logic_vector(4 downto 0);
         issra : in  std_logic;
         issll : in  std_logic;
         i_A   : in  std_logic_vector(31 downto 0);
         o_C   : out std_logic_vector(31 downto 0));
  end component;

  component mux2to1 is
    generic(N : integer := 32);
    port (i_A : in  std_logic_vector(N-1 downto 0);
          i_B : in  std_logic_vector(N-1 downto 0);
          i_S : in  std_logic;
          o_F : out std_logic_vector(N-1 downto 0));
  end component;

  signal mult_out, shifter_out, ALU_32bit_out : std_logic_vector(31 downto 0);
  signal mux_out : std_logic_vector(4 downto 0);

begin

  shifter : barrel_shifter
  port map(shamt => mux_out,
           issra => operation(0),
           issll => operation(1),
           i_A   => i_B,
           o_C   => shifter_out);

  mux1 : mux2to1
  generic map(N => 5)
  port map(i_A => i_A(4 downto 0),
           i_B => shamt,
           i_S => issv,
           o_F => mux_out);

  ALU1 : ALU_32bit 
  port map(operation     => operation,
           isUnsignedALU => isUnsignedALU,
           i_A           => i_A,
           i_B           => i_B,
           o_F           => ALU_32bit_out,
           o_C           => carry_out,
           zero          => zero,
           overflow      => overflow);

  mul : multiplier
  port map(i_A => i_A,
           i_B => i_B,
           is_multu => '0',
           o_F => mult_out);

  with ALUsel select ALU_out <=
    mult_out        when "00",
    ALU_32bit_out   when "01",
    shifter_out     when "10",
    (others => '0') when others;

end structure;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------