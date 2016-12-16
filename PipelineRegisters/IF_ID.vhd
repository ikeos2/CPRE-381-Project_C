library IEEE;
use IEEE.std_logic_1164.all;


entity IF_ID is
	port(
		i_Clk : in std_logic;
		i_Rst : in std_logic;
		i_We : in std_logic;
		i_IMem,	i_PC : in std_logic_vector(31 downto 0);
		o_IMem,	o_PC : out std_logic_vector(31 downto 0)) ;
end IF_ID;


architecture structure of IF_ID is

component nbit_dff_falling is
	generic(N : integer := 32);
	port(
		i_CLK : in std_logic;
		i_RST : in std_logic;
		i_WE : in std_logic;
		i_D : in std_logic_vector(N-1 downto 0);
		o_Q : out std_logic_vector(N-1 downto 0));
end component;


begin
--start 32 bit registers

PC_Reg : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_PC,
		 o_Q => o_PC);

IMem_Reg : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_IMem,
		 o_Q => o_IMem);
		 
--end 32 bit registers


end structure;