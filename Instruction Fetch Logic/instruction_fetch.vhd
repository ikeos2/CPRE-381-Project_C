-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity instruction_fetch is
  generic(N : integer := 32;
          mif_filename : string := "i_mem.mif");
  port(CLK            : in  std_logic;
       PC_reset       : in  std_logic;
       isJump         : in  std_logic;
       isJumpReg      : in  std_logic;
       reg_data       : in  std_logic_vector(31 downto 0);
       isBranch       : in  std_logic;
       instr          : out std_logic_vector(31 downto 0);
       PCp4           : out std_logic_vector(31 downto 0));
end instruction_fetch;

architecture structure of instruction_fetch is
  
component mux2to1
  generic(N : integer := 32);
  port (i_A        : in  std_logic_vector(N-1 downto 0);
        i_B        : in  std_logic_vector(N-1 downto 0);
        i_S        : in  std_logic;
        o_F        : out std_logic_vector(N-1 downto 0));
end component;

component AddSub
  port (A   		    : in  std_logic_vector(N-1 downto 0);
        B 		      : in  std_logic_vector(N-1 downto 0);
	      nAdd_Sub  : in  std_logic;
	      o_S 		    : out std_logic_vector(N-1 downto 0);
	      o_C 		    : out std_logic);
end component;

component extender16to32
  port(i_con        : in  std_logic;
       i_data       : in  std_logic_vector(15 downto 0);  
       o_F          : out std_logic_vector(31 downto 0));   
end component;

component register_Nbit is
  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic_vector(32-1 downto 0);     -- Data value input
       o_Q          : out std_logic_vector(32-1 downto 0));   -- Data value output
end component;

component i_mem
  	generic(depth_exp_of_2 	: integer := 10;
			     mif_filename 	: string := "i_mem.mif");
  port(address			: IN  STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');
       byteena			: IN  STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '1');
       clock			: IN  STD_LOGIC := '1';
       data			: IN  STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
       wren			: IN  STD_LOGIC := '0';
       q			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)); 
end component;

signal branch_shifter_out, mux1_out, mux2_out, mux3_out, branch_addr, s_PCp4, PC, Imm32, jump_addr, instruction : std_logic_vector(31 downto 0);
begin
   
   PCp4 <= s_PCp4;
   
   instr_mem : i_mem
   generic map(mif_filename => mif_filename)
   port map(address => PC(11 downto 2),
	          byteena => "0000",
	          clock => CLK,
	          data => x"00000000",
            wren => '0',
	          q => instruction);
	     
   PC_reg : register_Nbit
   port map(i_CLK => CLK, 
            i_RST => PC_reset,
            i_WE  => '1',
            i_D   => mux3_out,
            o_Q   => PC); 

   PC_adder: AddSub
   port map(A => PC,
            B => x"00000004",
            nAdd_Sub => '0',
            o_S => s_PCp4);
   
   branch_shifter_out(1 downto 0) <= (others => '0');
   branch_shifter_out(31 downto 2) <= Imm32(29 downto 0);
   
   sign_extend_imm : extender16to32
   port map(i_con => '1',
	          i_data => instruction(15 downto 0),
            o_F   => Imm32);
                     
   Branch_adder: AddSub
   port map(A => s_PCp4,
            B => branch_shifter_out,
            nAdd_Sub => '0',
            o_S => branch_addr);
            
	-- These 3 muxes need to be put in the next stage
	-- The order of the muxes must be maintained

   mux1: mux2to1
   port map(i_A => branch_addr,
            i_B => s_PCp4,
            i_S => isBranch,
            o_F => mux1_out);
            
   jump_addr(1 downto 0) <= (others => '0');
   jump_addr(27 downto 2) <= instruction(25 downto 0);
   jump_addr(31 downto 28) <= s_PCp4(31 downto 28);
  
   mux2: mux2to1
   port map(i_A => jump_addr,
            i_B => mux1_out,
            i_S => isJump,
            o_F => mux2_out);
   
   mux3: mux2to1
   port map(i_A => reg_data,
            i_B => mux2_out,
            i_S => isJumpReg,
            o_F => mux3_out);
       
  instr <= instruction;
       
end structure;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------
