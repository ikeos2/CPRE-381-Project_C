library IEEE;
use IEEE.std_logic_1164.all;


entity MEM_WB is
	port(
		i_Clk : in std_logic;
		i_Rst : in std_logic;
		i_We : in std_logic;
		i_RegDst, i_RegWrite, i_link, i_lui : in std_logic_vector(0 downto 0);
		o_RegDst, o_RegWrite, o_link, o_lui : out std_logic_vector(0 downto 0);
		
		i_WriteData, i_PCinc, i_imem, i_lui32 : in std_logic_vector(31 downto 0);
		o_WriteData, o_PCinc, o_imem, o_lui32 : out std_logic_vector(31 downto 0));
end MEM_WB;


architecture structure of MEM_WB is

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
-- 1 bit registers
RegDst_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_RegDst,
		 o_Q => o_RegDst);

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

--32 bit registers
WriteData_Reg : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_WriteData,
		 o_Q => o_WriteData);

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

lui32 : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => i_Rst,
		 i_WE => i_WE,
		 i_D => i_lui32,
		 o_Q => o_lui32);


--end 32 bit registers

end structure;
