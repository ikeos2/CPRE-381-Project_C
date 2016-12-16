-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity multiplier_unsigned is
  generic(N : integer := 32);
  port (i_A : in  std_logic_vector(N-1 downto 0);
        i_B : in  std_logic_vector(N-1 downto 0);
        o_F : out std_logic_vector(2*N-1 downto 0));
end multiplier_unsigned;

architecture mixed of multiplier_unsigned is
  
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

  signal result : std_logic_vector(N*2*N-1 downto 0);
  signal temp : std_logic_vector(N*2*(N-1)-1 downto 0) := (others => '0');
  
begin
  
  for1 : for m in 0 to N-1 generate
    result(m) <= i_A(m) and i_B(0);
    result(m+N) <= '0';
  end generate;

  for2 : for i in 1 to N-1 generate
      
   for3 : for k in 0 to i-1 generate

      temp(k+N*2*(i-1)) <= '0';

   end generate;
     
   for4 : for j in 0 to N-1 generate
       
      temp(i+j+(N*2*(i-1))) <= i_A(j) and i_B(i);
    
   end generate;
  
  --for5 : for n in 0 to N-1-i generate
  --    temp(N-1-n+(N*2*(i-1))) <= '0';
  --end generate;
  
  add : ALU_32bit
  generic map(N => N*2)
  port map (operation => "000",
            isUnsignedALU => '0',
            i_A => temp(N*2*i-1 downto N*2*(i-1)),
            i_B => result(N*2*i-1 downto N*2*(i-1)),
            o_F => result(N*2*(i+1)-1 downto N*2*i));
  
  end generate;
  
  o_F <= result(N*2*(N-1)-1 downto N*2*(N-2));
  
end mixed;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------