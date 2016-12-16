library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity pipeline_TB is

end pipeline_TB;

architecture behavior of pipeline_TB is

	-- Declare the component we are going to instantiate
	component EX_MEM is
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
	end component;

	component ID_EX is
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
	end component;
	
	component MEM_WB is
	port(
		i_Clk : in std_logic;
		i_Rst : in std_logic;
		i_We : in std_logic;
		i_RegDst, i_RegWrite, i_link, i_lui : in std_logic_vector(0 downto 0);
		o_RegDst, o_RegWrite, o_link, o_lui : out std_logic_vector(0 downto 0);
		
		i_WriteData, i_PCinc, i_imem, i_lui32 : in std_logic_vector(31 downto 0);
		o_WriteData, o_PCinc, o_imem, o_lui32 : out std_logic_vector(31 downto 0));
	end component;

	component IF_ID is
	port(
		i_Clk : in std_logic;
		i_Rst : in std_logic;
		i_We : in std_logic;
		i_IMem,	i_PC : in std_logic_vector(31 downto 0);
		o_IMem,	o_PC : out std_logic_vector(31 downto 0)) ;
	end component;
	
	component control
	  port(Instr          : in  std_logic_vector(5 downto 0);
	       rt_Addr       : in  std_logic_vector(4 downto 0);
	       bgtz_blez      : out std_logic;
	       isLink         : out std_logic;
	       Branch         : out std_logic;
	       isJump         : out std_logic;
	       Reg_w_en       : out std_logic;
	       dmem_w_en      : out std_logic;
	       RegDst         : out std_logic;
	       UpperImm       : out std_logic;
	       isImmALU       : out std_logic;
	       isLoad         : out std_logic;
	       isRtype        : out std_logic;
	       compareZero    : out std_logic;
	       isLoadU        : out std_logic;
	       isBranchLink   : out std_logic;
	       ALU_OP         : out std_logic_vector(5 downto 0);
	       Branch_Sel     : out std_logic_vector(2 downto 0);
	       lsTypeSel      : out std_logic_vector(1 downto 0));
	end component;
	
	component ALU_control
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
	end component;


-- Signals connecting to the module
 	signal clk , IF_ID_w, ID_EX_w, EX_MEM_w, MEM_WB_w: std_logic;
	--signal upper_imm
	signal PCp4, ALU_out, Imm32, instr : std_logic_vector(31 downto 0);
	signal temp_rs, temp_rt : std_logic_vector(31 downto 0);
	signal mux13_out : std_logic_vector(31 downto 0);
	signal isUnsignedALU, issv, ALU_write, isLinkALU : std_logic;
	signal operation, Branch_sel : std_logic_vector(2 downto 0);
	signal s_IDEX_memOP : std_logic_vector(1 downto 0);
	signal ALUSel, lstypesel : std_logic_vector(1 downto 0);
	signal ALUOp : std_logic_vector(5 downto 0);
	-- unused signal -- Reg_w_en link
	signal bgtz_blez, isLink, Branch, isJumpReg, isBranchLink, CompareZero : std_logic;
	--signal s_imem : std_logic_vector(31 downto 0);
	-- 0 to 0 vectors
	signal s_IDEX_memToReg, s_IDEX_RegDst, RegDst, isLoad, isImmALU, s_link, UpperImm, isJump, s_jumparino : std_logic_vector(0 downto 0);
	signal s_EXMEM_RegDst, s_IDEX_or, s_IDEX_lui, s_IDEX_link, s_IDEX_RegWrite : std_logic_vector(0 downto 0);
	--signal s_IF_ID_IMem, s_IF_ID_PC : std_logic_vector(31 downto 0);
	signal s_MEMWB_RegDst: std_logic_vector(0 downto 0);
	signal s_EXMEM_RegWrite, s_EXMEM_memToReg, s_IDEX_jr: std_logic_vector(0 downto 0); 
	signal s_IDEX_alu_32_o_F_1 : std_logic_vector(31 downto 0);
	-- unused signal -- s_IDEX_mux_9
	signal s_EXMEM_lui, s_MEMWB_lui, isRtype, s_isRtype: std_logic_vector(0 downto 0);
	Signal IF_ID_reset : std_logic := '0';
	Signal ID_EX_reset : std_logic;-- := '0'; -- Once we implement hazard remove these assignments
	Signal EX_MEM_reset : std_logic := '0';
	Signal MEM_WB_reset : std_logic := '0'; -- Reset for each pipeline register
	--Signal IF_ID_imem_in : std_logic_vector(31 downto 0); -- Imem -> (IF_ID)    
	--Signal IF_ID_PC_out : std_logic_vector(31 downto 0); -- PC -> (IF_ID) -> IF_ID_PC_out
	Signal s_isImmALU : std_logic_vector(0 downto 0); -- ID_EX -> mux10
	Signal s_PCp4_out : std_logic_vector(31 downto 0);
	-- s_RegDst, not used signal
	Signal s_EXMEM_link : std_logic_vector(0 downto 0);
	Signal s_ID_EX_ALUOP :  std_logic_vector(5 downto 0);  -- ALU controller opcode, (ID_EX) -> (EX_MEM)
	Signal dmem_temp_rs, dmem_temp_rt, s_IDEX_PCinc, s_EXMEM_PCinc : std_logic_vector(31 downto 0); -- dmem -> EX_MEM 
	Signal i_ALUBOX_op, o_ALUBOX_op : std_logic_vector(1 downto 0); -- Unused register in the ID_EX register
	Signal d_temp_rs : std_logic_vector(31 downto 0); -- mux_jump output for ID_EX
	Signal s_Reg_w_en : std_logic_vector(0 downto 0); -- Control -> ID_EX
	Signal s_IDEX_imem : std_logic_vector(31 downto 0);
	Signal s_MEMWB_WriteData : std_logic_vector(31 downto 0);
	--Signal s_lstypesel : std_logic_vector(1 downto 0); 
	signal ImmSign : std_logic_vector(0 downto 0); -- This signal needs to be added to the control logic.
	signal s_ImmSign : std_logic_vector(0 downto 0); -- control -> ID_EX
	signal s_MEMWB_RegWrite : std_logic_vector(0 downto 0); -- Write enable connected to the register
	signal s_imem_IN : std_logic_vector(31 downto 0); -- IF_ID -> Instruction fetch
	signal s_MEMWB_lui32, s_MEMWB_imem, s_MEMWB_PCinc, s_EXMEM_imem, s_EXMEM_lui32 : std_logic_vector(31 downto 0);
	signal s_MEMWB_link: std_logic_vector(0 downto 0); 
	Signal s_EXMEM_ALU, s_IDEX_lui32, s_EXMEM_Rdata2,s_imm32 : std_logic_vector(31 downto 0); -- EX_MEM -> ALU_CONTROL
		-- unused data s_IDEX_Rdata2
	Signal s_EXMEM_memOP : std_logic_vector(1 downto 0); 
	signal s_immval : std_logic_vector(31 downto 0); -- used for imm val trimming
	signal s_isloadu_control, s_isloadu_idex, s_isloadu_exmem: std_logic_vector(0 downto 0); -- used for pipelining signals we missed in main pipeline registers
	signal s_dmem_w_control, s_dmem_w_idex, s_dmem_w_exmem: std_logic_vector(0 downto 0); -- used for pipelining signals we missed in main pipeline registers
	
	begin

-- IF_ID	       
   IFID : IF_ID
    port map(
      i_Clk => CLK, --
      i_Rst => IF_ID_reset, --
      i_We  => IF_ID_w, --
      i_IMem=> s_imem_IN, -- This needs a value driven
      i_PC  => PCp4,-- This needs a value driven
      o_IMem=> instr, -- 
      o_PC  => s_PCp4_out); --

-- ID_EX
  IDEX : ID_EX
    port map(
      i_Clk    => CLK, --
      i_Rst    => ID_EX_reset, --
      i_Flush  => '0', -- 
      i_We     => ID_EX_w, --
      i_RegDst => RegDst, --
      i_jr     => isJump, --
      o_jr     => s_IDEX_jr, --
      i_or     => s_jumparino, --
      o_or     => s_IDEX_or, -- 
      i_alu_32_out => ALU_out, -- this needs driven
      o_alu_32_out => s_IDEX_alu_32_o_F_1, -- 
      i_mux_jump    => dmem_temp_rs, --  this needs driven
      o_mux_jump    => d_temp_rs, -- 
      i_memToReg => isLoad, --
      i_ALUSrc   => isImmALU, --
      i_RegWrite => s_Reg_w_en, --
      i_link      => s_link, --
      i_lui      => UpperImm, --
      o_RegDst   => s_IDEX_RegDst, --
      o_memToReg => s_IDEX_memToReg, -- 
      o_ALUSrc   => s_isImmALU, --
      o_RegWrite => s_IDEX_RegWrite, --
      o_link  => s_IDEX_link, --
      o_lui      => s_IDEX_lui, --
      i_ALUBOX_op => i_ALUBOX_op,-- Don't need this --
      o_ALUBOX_op => o_ALUBOX_op,-- Don't need this --
      i_ALUOP  => ALUOp, --
      i_memOP  => lstypesel, -- lstypesel is similiar to byteen
      o_ALUOP  => s_ID_EX_ALUOP, -- ALUop --
      i_imm32 => imm32,
      o_imm32 => s_imm32,
      o_memOP  => s_IDEX_memOP, --
      i_Rdata1 => dmem_temp_rs, -- dmem1 --
      i_Rdata2 => dmem_temp_rt, -- dmem2 --
      i_Mux_signed_unsigned  => ImmSign, --
      i_imem   => instr, -- 
      i_PCinc  => s_PCp4_out, --
      i_lui32  => s_immval, -- full instruction should be passed, it's shrunk down later(see mux 7 and code directly above it)
      o_Rdata1 => temp_rs, --dmem1 --
      o_Rdata2 => temp_rt, --dmem2 --
      o_Mux_signed_unsigned  => s_ImmSign, -- This needs to be connected after control part has been implemented
      o_imem   => s_IDEX_imem, --
      o_PCinc  => s_IDEX_PCinc, -- 
      o_lui32  => s_IDEX_lui32 --
        );


-- EX_MEM
  EXMEM : EX_MEM
    port map(
      i_Clk     => CLK,              --
      i_Rst     => EX_MEM_reset,     --
      i_We      => EX_MEM_w,              --
      i_RegDst  => s_IDEX_RegDst,    --
      i_memToReg=> s_IDEX_memToReg,  --
      i_RegWrite=> s_IDEX_RegWrite,  --
      i_link    => s_IDEX_link,      --
      i_lui     => s_IDEX_lui,       --
      o_RegDst  => s_EXMEM_RegDst,   -- add2forw
      o_memToReg=> s_EXMEM_memToReg, --
      o_RegWrite=> s_EXMEM_RegWrite, -- add2forw
      o_link    => s_EXMEM_link,     -- add2haz
      o_lui     => s_EXMEM_lui,      --
      i_memOP   => s_IDEX_memOP,     --
      o_memOP   => s_EXMEM_memOP,	-- connects to dmem
      i_ALU     => ALU_out,   -- ADO - Assuming this is the ALU output
      i_Rdata2  => temp_rt,  
      i_PCinc   => s_IDEX_PCinc,    --
      i_imem    => s_IDEX_imem,     --
      i_lui32   => s_IDEX_lui32,
      o_ALU     => s_EXMEM_ALU,
      o_Rdata2  => s_EXMEM_Rdata2,	-- connects to dmem
      o_PCinc   => s_EXMEM_PCinc,
      o_imem    => s_EXMEM_imem,
      o_lui32   =>  s_EXMEM_lui32);
           
-- MEM_WB
  MEMWB : MEM_WB --mux 1,2,3 are in the instruction fetch logic
    port map(
      i_Clk     => CLK,
      i_Rst     => MEM_WB_reset,
      i_We      => MEM_WB_w,
      i_RegDst  => s_EXMEM_RegDst,
      i_RegWrite=> s_EXMEM_RegWrite,
      i_link    => s_EXMEM_link, 
      i_lui     => s_EXMEM_lui,
      o_RegDst  => s_MEMWB_RegDst, --needs to also go into forwarding
      o_RegWrite=> s_MEMWB_RegWrite, --
      o_link    => s_MEMWB_link, --mux5 done missing mux3 may be an issue but you know, also needs to go to fwding
      o_lui     => s_MEMWB_lui,
      i_WriteData =>  mux13_out,
      i_PCinc   => s_EXMEM_PCinc, --
      i_imem    => s_EXMEM_imem,
      i_lui32   => s_EXMEM_lui32,
      o_WriteData => s_MEMWB_WriteData, --
      o_PCinc   => s_MEMWB_PCinc,
      o_imem    => s_MEMWB_imem, --mux portion is done need to go to forwarding
      o_lui32   => s_MEMWB_lui32); --
      
      
      control_unit : control -- This needs reworked for the immSign 
    port map(Instr          => instr(31 downto 26),
             rt_Addr       => instr(20 downto 16),
             bgtz_blez      => bgtz_blez, -- this needs to go through IDEX
             isLink         => isLink,
             Branch         => Branch,
             isJump         => isJump(0),
             Reg_w_en       => s_Reg_w_en(0),
             dmem_w_en      => s_dmem_w_control(0),
             RegDst         => RegDst(0),
             UpperImm       => UpperImm(0),
             isImmALU       => isImmALU(0),
             isLoad         => isLoad(0),
             isRtype        => isRtype(0),
             compareZero    => compareZero,
             isLoadU        => s_isloadu_control(0),
             isBranchLink   => isBranchLink,
             ALU_OP         => ALUOp,
             Branch_Sel     => Branch_Sel,
             lsTypeSel      => lsTypeSel);
             
             
	control_ALU : ALU_control
	  port map(funct_code => s_IDEX_imem(5 downto 0),
		   isRtype => s_isRtype(0),
		   ALUOp => s_ID_EX_ALUOP, --s_EXMEM_ALU -- I changed this from the EXMEM value to an IDEX value, seemed out of order
		   operation => operation,
		   ALUsel => ALUsel,
		   issv => issv,
		   isJumpReg => isJumpReg, -- connects to instruction fetch, I think this will need pipelining
		   isLinkALU => isLinkALU,
		   ALU_write => ALU_write,
		   isUnsignedALU => isUnsignedALU);

--=============================================================================================================================================================================
-- Begin test bench

		process
		begin
			
		wait for 1 ns;	
		
		--	i_A <= "00000000000000000000000000000000";
		--	i_B <= "00000000000000000000000000000000";
		--	wait for 100 ns;

		--	i_A <= "11111111111111111111111111111111";
		--	i_B <= "11111111111111111111111111111111";

	end process;
  
end behavior;
