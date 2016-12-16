library IEEE;
use IEEE.std_logic_1164.all;

entity EX_MEM is
	port(
		i_Clk : in std_logic;
		i_Rst : in std_logic;
		i_We : in std_logic;
		i_RegDst, i_memToReg, i_RegWrite, i_link, i_lui : in std_logic_vector(0 downto 0);
		o_RegDst, o_memToReg, o_RegWrite, o_link, o_lui : out std_logic_vector(0 downto 0);
		i_memOP : in std_logic_vector(1 downto 0);
		o_memOP : out std_logic_vector(1 downto 0);
		i_ALU, i_Rdata2, i_PCinc, i_imem, i_lui32 : in std_logic_vector(31 downto 0);
		o_ALU, o_Rdata2, o_PCinc, o_imem, o_lui32 : out std_logic_vector(31 downto 0));
end EX_MEM;


architecture structure of EX_MEM is

component nbit_dff_falling is
	generic(N : integer := 32);
	port(
		i_CLK : in std_logic;
		i_RST : in std_logic;
		i_WE : in std_logic;
		i_D : in std_logic_vector(N-1 downto 0);
		o_Q : out std_logic_vector(N-1 downto 0));
end component;

signal s_memOP : std_logic_vector(1 downto 0);

begin

with i_Rst select --This mux is here because when we flush the default value for memOP is '111'.
	s_memOP <=
		i_memOP when '0',
		"11" when '1',
		"11" when others;


-- 1 bit registers
RegDst_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_RegDst,
		 o_Q => o_RegDst);

memToReg_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_memToReg,
		 o_Q => o_memToReg);


regWrite_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_regWrite,
		 o_Q => o_regWrite);


andLink_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_Link,
		 o_Q => o_Link);


lui_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_lui,
		 o_Q => o_lui);

--end 1 bit registers
--3 bit registers
memOP_Reg : nbit_dff_falling
	generic map(N => 2)
	port map(i_CLK => i_Clk,
		 i_RST => '0',
		 i_WE => i_WE,
		 i_D => s_memOP,
		 o_Q => o_memOP);

--end 3 bit registers

--32 bit registers

ALU_Reg : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_ALU,
		 o_Q => o_ALU);

Rdata2_Reg : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_Rdata2,
		 o_Q => o_Rdata2);

PCinc_0 : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_PCinc,
		 o_Q => o_PCinc);
		 
imem : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_imem,
		 o_Q => o_imem);

luiVal : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_lui32,
		 o_Q => o_lui32);


--end 32 bit registers
end structure;
