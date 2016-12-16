library IEEE;
use IEEE.std_logic_1164.all;




entity ID_EX is
	port(
		i_Clk : in std_logic; --
		i_Rst : in std_logic; --
		i_Flush : in std_logic; -- 
		i_We : in std_logic; --
		i_RegDst, i_memToReg, i_ALUSrc, i_RegWrite, i_link, i_lui, i_Mux_signed_unsigned, i_jr, i_or : in std_logic_vector(0 downto 0);
		o_RegDst, o_memToReg, o_ALUSrc, o_RegWrite, o_link, o_lui, o_Mux_signed_unsigned, o_jr, o_or : out std_logic_vector(0 downto 0);
		i_ALUBOX_op : in std_logic_vector(1 downto 0);
		o_ALUBOX_op : out std_logic_vector(1 downto 0);
		i_memOP : in std_logic_vector(1 downto 0);
		o_memOP : out std_logic_vector(1 downto 0);
		i_ALUOP : in std_logic_vector(5 downto 0);
		o_ALUOP : out std_logic_vector(5 downto 0);
		i_Rdata1, i_Rdata2, i_imem, i_PCinc,  i_lui32, i_alu_32_out, i_mux_jump,i_imm32 : in std_logic_vector(31 downto 0); 
		o_Rdata1, o_Rdata2, o_imem, o_PCinc,  o_lui32, o_alu_32_out, o_mux_jump,o_imm32 : out std_logic_vector(31 downto 0)); 
end ID_EX;


architecture structure of ID_EX is

component nbit_dff_falling is
	generic(N : integer := 32);
	port(
		i_CLK : in std_logic;
		i_RST : in std_logic;
		i_WE : in std_logic;
		i_D : in std_logic_vector(N-1 downto 0);
		o_Q : out std_logic_vector(N-1 downto 0));
end component;

signal s_FlushOrReset : std_logic;

signal s_memOP : std_logic_vector(2 downto 0);
signal tmp_memOp : std_logic_vector(2 downto 0);

begin

tmp_memOP(2) <= '0';
tmp_memop(1 downto 0) <= i_memop;

with i_Rst select --This mux is here because when we flush the default value for memOP is '111'.
	s_memOP <=
		tmp_memOP when '0',
		"111" when '1',
		"111" when others;


s_FlushOrReset <= i_Flush or i_Rst;


-- 1 bit registers
RegDst_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_RegDst,
		 o_Q => o_RegDst);

memToReg_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_memToReg,
		 o_Q => o_memToReg);


ALUSrc_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_ALUSrc,
		 o_Q => o_ALUSrc);


regWrite_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_regWrite,
		 o_Q => o_regWrite);

andLink_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_Link,
		 o_Q => o_Link);

lui_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_lui,
		 o_Q => o_lui);

signed_unsigned_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_Mux_signed_unsigned,
		 o_Q => o_Mux_signed_unsigned);

jr_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_jr,
		 o_Q => o_jr);

or_Reg : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_or,
		 o_Q => o_or);


--end 1 bit registers

--2 bit registers

ALUBOX_op_Reg : nbit_dff_falling
	generic map(N => 2)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_ALUBOX_op,
		 o_Q => o_ALUBOX_op);

memOP_Reg : nbit_dff_falling
	generic map(N => 2)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => s_memOP(1 downto 0),
		 o_Q => o_memOP);
		 
--end 2 bit registers
		 
--6 bit registers

ALUOP_Reg : nbit_dff_falling
	generic map(N => 6)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_ALUOP,
		 o_Q => o_ALUOP);


--end 6 bit registers

--32 bit registers

imem_Reg : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_imem,
		 o_Q => o_imem);



PCinc_Reg : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_PCinc,
		 o_Q => o_PCinc);


Rdata1_Reg : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_Rdata1,
		 o_Q => o_Rdata1);

Rdata2_Reg : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_Rdata2,
		 o_Q => o_Rdata2);

lui32_0 : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_lui32,
		 o_Q => o_lui32);


--luiVal : nbit_dff_falling
--	generic map(N => 32)
--	port map(i_CLK => i_Clk,
--		 i_RST => s_FlushOrReset,
--		 i_WE => i_WE,
--		 i_D => i_luiVal,
--		 o_Q => o_luiVal);


alu_32_1 : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_alu_32_out,
		 o_Q => o_alu_32_out);

mux_jump : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_mux_jump,
		 o_Q => o_mux_jump);
		 
		 imm32 : nbit_dff_falling
	generic map(N => 32)
	port map(i_CLK => i_Clk,
		 i_RST => s_FlushOrReset,
		 i_WE => i_WE,
		 i_D => i_imm32,
		 o_Q => o_imm32);


--end 32 bit registers
end structure;
