-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------


-- ALU_32bit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 32-bit ALU with
--add,sub,and,or,xor,nand,nor
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity ALU_32bit is
  generic(N : integer := 32);
  port(operation     : in  std_logic_vector(2 downto 0);
       isUnsignedALU : in  std_logic;
       i_A           : in  std_logic_vector(N-1 downto 0);
       i_B           : in  std_logic_vector(N-1 downto 0);
       o_F           : out std_logic_vector(N-1 downto 0);
       o_C           : out std_logic;
       zero          : out std_logic;
       overflow      : out std_logic);
end ALU_32bit;     
       
architecture mixed of ALU_32bit is
  component ALU_1bit is
    port(operation : in std_logic_vector(2 downto 0);
         i_A       : in  std_logic;
         i_B       : in  std_logic;
         i_C       : in  std_logic;
         Less      : in  std_logic;
         o_S       : out std_logic;
         o_C       : out std_logic);
    end component;
    
    component Alu_1bit_final is
      port(operation : in std_logic_vector(2 downto 0);
         i_A       : in  std_logic;
         i_B       : in  std_logic;
         i_C       : in  std_logic;
         Less      : in  std_logic;
         o_S       : out std_logic;
         set       : out std_logic;
         o_C       : out std_logic;
         overflow  : out std_logic);
    end component;
    
  signal carry  : std_logic_vector(N-1 downto 0);
  signal sZero  : std_logic_vector(N downto 0);
  signal s_F   : std_logic_vector(N-1 downto 0);
  signal o_muxu1, o_muxs1, o_mux_set     : std_logic;
  signal set, Cout, temp         : std_logic;
  signal overflow_signed   : std_logic;
      
  begin
    ---- sets the carry bit----
  with operation select carry(0) <= 
    '0' when "000",
    '1' when "001",
    '1' when "010",
    '0' when others; 
    
   ----- sets up the first ALU -----
  ALU0 : ALU_1bit
    port map(operation => operation,
             i_A => i_A(0),
             i_B => i_B(0),
             i_C => carry(0),
             Less => o_mux_set,
             o_S => s_F(0),
             o_C => carry(1));
             
  --- generates ALU 1- ALU 30 -----
  for1: for i in 1 to N-2 generate
    ALUi : ALU_1bit
    port map(operation => operation,
             i_A => i_A(i),
             i_B => i_B(i),
             i_C => carry(i),
             Less => '0',
             o_S => s_F(i),
             o_C => carry(i+1));
  end generate;
   
   ---- generates the final ALU ----
   ALU31 : ALU_1bit_final
    port map(operation => operation,
             i_A => i_A(N-1),
             i_B => i_B(N-1),
             i_C => carry(N-1),
             Less => '0',
             o_S => s_F(N-1),
             set => set,
             o_C => Cout,
             overflow => overflow_signed);
             
   ---- sets overflow ------
   with overflow_signed select o_muxs1 <=
     set      when '0', 
    (not set) when '1',
    '0'       when others;

   temp <= i_A(N-1) xor i_B(N-1);

   with temp select o_muxu1 <=
     o_muxs1        when '0', 
     (not o_muxs1)  when '1',
     '0'            when others;

   with isUnsignedALU select o_mux_set <=
     o_muxs1        when '0', 
     o_muxu1        when '1',
     '0'            when others;

  ---- sets zero output ----  
 sZero(0) <= '0';
 for2: for i in 0 to N-1 generate
   sZero(i+1) <= s_F(i) or sZero(i); 
 end generate;
 

  zero <= not sZero(N);
  o_C  <= Cout;
  o_F(N-1 downto 0) <= s_F(N-1 downto 0);
   
  --- accounts for Oveflow when dealing with unsigned operations ---
  with isUnsignedALU select overflow <=
    overflow_signed when '0',
    Cout            when '1',
    '0'             when others;
  
end mixed;           
    
-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------    