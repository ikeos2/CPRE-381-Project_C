-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity MIPS_processor is
  generic(N : integer := 32;
          dmem_mif_filename : string := "mem.mif";
          imem_mif_filename : string := "i_mem.mif");
  port(CLK            : in  std_logic;
       reg_reset      : in  std_logic;
       PC_reset       : in  std_logic;
       instruction : out std_logic_vector(31 downto 0);
       PCplus4     : out std_logic_vector(31 downto 0);
       rs_data : out std_logic_vector(31 downto 0);
       rt_data : out std_logic_vector(31 downto 0));
end MIPS_processor;
 
architecture structure of MIPS_processor is
   
component mux2to1
  generic(N : integer := 32);
  port (i_A        : in  std_logic_vector(N-1 downto 0);
        i_B        : in  std_logic_vector(N-1 downto 0);
        i_S        : in  std_logic;
        o_F        : out std_logic_vector(N-1 downto 0));
end component;

component MIPS_register_file
  port(CLK            : in  std_logic;
       rs_sel         : in  std_logic_vector(4 downto 0);     
       rt_sel         : in  std_logic_vector(4 downto 0);
       w_data         : in  std_logic_vector(31 downto 0);
       w_sel          : in  std_logic_vector(4 downto 0);
       w_en           : in  std_logic;
       reset          : in  std_logic;
       rs_data        : out std_logic_vector(31 downto 0);
       rt_data        : out std_logic_vector(31 downto 0));
 end component;
 
  component ID_EX
    port(
        i_Clk : in std_logic;
        i_Rst : in std_logic;
        i_Flush : in std_logic;
        i_We : in std_logic;
        i_RegDst, i_memToReg, i_ALUSrc, i_RegWrite, i_link, i_lui, i_Mux_signed_unsigned, i_jr, i_or : in std_logic_vector(0 downto 0);
        o_RegDst, o_memToReg, o_ALUSrc, o_RegWrite, o_link, o_lui, o_Mux_signed_unsigned, o_jr, o_or : out std_logic_vector(0 downto 0);
        i_ALUBOX_op : in std_logic_vector(1 downto 0);
        o_ALUBOX_op : out std_logic_vector(1 downto 0);
        i_memOP : in std_logic_vector(1 downto 0);
        o_memOP : out std_logic_vector(1 downto 0);
        i_ALUOP : in std_logic_vector(5 downto 0);
        o_ALUOP : out std_logic_vector(5 downto 0);
        i_Rdata1, i_Rdata2, i_imem, i_PCinc,  i_lui32, i_alu_32_out, i_mux_jump, i_imm32 : in std_logic_vector(31 downto 0); 
        o_Rdata1, o_Rdata2, o_imem, o_PCinc,  o_lui32, o_alu_32_out, o_mux_jump, o_imm32 : out std_logic_vector(31 downto 0)); 
end component;

component IF_ID
    port(
        i_Clk : in std_logic;
        i_Rst : in std_logic;
        i_We : in std_logic;
        i_IMem, i_PC : in std_logic_vector(31 downto 0);
        o_IMem, o_PC : out std_logic_vector(31 downto 0)) ;
end component;

component MEM_WB
    port(
        i_Clk : in std_logic;
        i_Rst : in std_logic;
        i_We : in std_logic;
        i_RegDst, i_RegWrite, i_link, i_lui : in std_logic_vector(0 downto 0);
        o_RegDst, o_RegWrite, o_link, o_lui : out std_logic_vector(0 downto 0);
        i_WriteData, i_PCinc, i_imem, i_lui32 : in std_logic_vector(31 downto 0);
        o_WriteData, o_PCinc, o_imem, o_lui32 : out std_logic_vector(31 downto 0));
end component;

component EX_MEM
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

component dmem 
  generic (mif_filename : string := "mem.mif");
  port(address    : in  std_logic_vector(31 downto 0);
       data_in    : in  std_logic_vector(31 downto 0);
       lstypesel  : in  std_logic_vector(1 downto 0);
       lu_sel     : in  std_logic;
       clock      : in  std_logic;
       wren       : in  std_logic;
       data_out   : out std_logic_vector(31 downto 0));
end component;

component extender16to32
  port(i_con        : in  std_logic;
       i_data       : in  std_logic_vector(15 downto 0);  
       o_F          : out std_logic_vector(31 downto 0));   
end component;

component ALU is
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
end component;

component instruction_fetch 
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
end component;
 
component Branch_Architecture is
  port(Branch_Sel     : in  std_logic_vector(2 downto 0);
       i_Zero         : in  std_logic;
       i_ALU_Out      : in  std_logic;
       o_F            : out std_logic);
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

component Forwarding is
  port(IFIDimem, IDEXimem, EXMEMimem, MEMWBimem : in std_logic_vector(31 downto 0);
        MEMWBregwr, EXMEMregwr, MEMWBregdst, EXMEMregdst, MEMWBal : in std_logic_vector(0 downto 0);
        fwdALU1, fwdALU2: out std_logic_vector(1 downto 0);
        fwdBranch1, fwdBranch2 : out std_logic);
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

component nbit_dff_falling is
  generic (N : integer := 32);
  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic_vector(N-1 downto 0);     -- Data value input
       o_Q          : out std_logic_vector(N-1 downto 0));   -- Data value output
 end component;
 
	--signal upper_imm
	signal PCp4, ALU_out, Imm32, instr : std_logic_vector(31 downto 0);
	signal temp_rs, temp_rt, dmem_out : std_logic_vector(31 downto 0);
	signal mux7_out, mux8_out, mux9_out, mux10_out, mux11_out, mux12_out, mux13_out : std_logic_vector(31 downto 0);
	signal mux14_out, zero, isUnsignedALU, issv, Branch_out, ALU_write, isLinkALU : std_logic;
	signal mux4_out, mux5_out, mux6_out : std_logic_vector(4 downto 0);
	signal operation, Branch_sel : std_logic_vector(2 downto 0);
	signal s_IDEX_memOP : std_logic_vector(1 downto 0);
	signal ALUSel, lstypesel : std_logic_vector(1 downto 0);
	signal ALUOp : std_logic_vector(5 downto 0);
	-- unused signal -- Reg_w_en link
	signal bgtz_blez, isLink, Branch, isJumpReg, isBranchLink, CompareZero, isBranch : std_logic;
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
   PCplus4 <= PCp4;
   instruction <= instr;
   
   rs_data <= temp_rs;
   rt_data <= temp_rt;
   
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

        -- We can ignore this section until the registers pipeline registers work
        
    -- forward_control : Forwarding
      -- port(IFIDimem => , 
          -- IDEXimem => ,
          -- EXMEMimem => , 
          -- MEMWBimem => ,
          -- MEMWBregwr => ,
          -- EXMEMregwr => , 
          -- MEMWBregdst => , 
          -- EXMEMregdst => , 
          -- MEMWBal => ,
          -- fwdALU1 => , 
          -- fwdALU2 => ,
          -- fwdBranch1 => , 
          -- fwdBranch2 => );

   sign_extend_imm : extender16to32
   port map(i_con => '1', -- This should connect to s_ImmSign once it's been connected
              i_data => instr(15 downto 0),
            o_F   => Imm32);
            
   Register_File : MIPS_register_file
   port map(CLK => CLK,
            rs_sel => instr(25 downto 21),
            rt_sel => instr(20 downto 16),
            w_data => mux8_out,
            w_sel => mux5_out,
            w_en => s_MEMWB_RegWrite(0),  
            reset => reg_reset,
            rs_data => dmem_temp_rs,
            rt_data => dmem_temp_rt);

   memory : dmem  
   generic map(mif_filename => dmem_mif_filename)
   port map(address    => s_EXMEM_ALU,
            data_in    => s_EXMEM_Rdata2,
            lstypesel  => s_EXMEM_memOP,
            lu_sel     => s_isloadu_exmem(0),
            clock      => CLK,
            wren       => s_dmem_w_exmem(0),
            data_out   => dmem_out);
   
   Branch_arch: Branch_Architecture
   port map(Branch_Sel => Branch_sel,
            i_Zero => zero,
            i_ALU_out => s_EXMEM_ALU(0),
            o_F => Branch_out);     
       
   main_ALU: ALU
   port map(operation     => operation,
            ALUsel        => ALUSel,
            shamt         => instr(10 downto 6),
            i_A           => mux11_out,
            i_B           => mux12_out,
            issv          => issv,
            isUnsignedALU => isUnsignedALU,
            zero          => zero,
            ALU_out       => ALU_out);     
            
  isBranch <= Branch_out and Branch;  
          
  instr_fetch : instruction_fetch
  generic map(mif_filename => imem_mif_filename)
  port map(CLK => CLK,
           PC_reset => PC_reset,
           isJump => s_IDEX_jr(0),
           isJumpReg => isJumpReg,
           reg_data => d_temp_rs,
           isBranch => isBranch,
           instr => s_imem_IN,
           PCp4 => PCp4);
            
   mux4: mux2to1
   generic map (N => 5)
   port map(i_A => s_MEMWB_imem(20 downto 16),
            i_B => s_MEMWB_imem(15 downto 11),
            i_S => s_MEMWB_RegDst(0),
            o_F => mux4_out);
   
   s_link(0) <= isLink or isLinkALU;   
   
   mux5: mux2to1
   generic map (N => 5)
   port map(i_A => mux6_out,
            i_B => mux4_out,
            i_S => s_MEMWB_link(0),
            o_F => mux5_out);
   
   mux6: mux2to1
   generic map (N => 5)
   port map(i_A => instr(15 downto 11),
            i_B => "11111",
            i_S => isLinkALU,
            o_F => mux6_out);
       
     -- 
   s_immval(31 downto 16) <= instr(15 downto 0); -- Instruction is trimmed down here
   s_immval(15 downto 0) <= (others => '0');
   
   mux7: mux2to1
   port map(i_A => s_MEMWB_lui32,
            i_B => s_MEMWB_WriteData, 
            i_S => s_MEMWB_lui(0), 
            o_F => mux7_out);
            
   mux8: mux2to1
   port map(i_A => s_EXMEM_PCinc,  --used to be s_PCp4_out.  where does s_PCp4_out go to?
            i_B => mux7_out,
            i_S => s_IDEX_link(0),
            o_F => mux8_out);            
   
   mux9: mux2to1
   port map(i_A => x"00000000",
            i_B => s_imm32,
            i_S => CompareZero,
            o_F => mux9_out); 
            
   mux10: mux2to1
   port map(i_A => mux9_out,
            i_B => temp_rt,
            i_S => s_isImmALU(0),
            o_F => mux10_out); 
  
   mux11: mux2to1
   port map(i_A => mux10_out,
            i_B => temp_rs,
            i_S => bgtz_blez,
            o_F => mux11_out); 
   
   mux12: mux2to1
   port map(i_A => temp_rs,
            i_B => mux10_out,
            i_S => bgtz_blez,
            o_F => mux12_out);                         

   mux13: mux2to1
   port map(i_A => dmem_out,
            i_B => s_EXMEM_ALU,
            i_S => s_EXMEM_memToReg(0), -- Should this connect to memwb?
            o_F => mux13_out); 
            
---- Mux 14 ----
  with isBranchLink select mux14_out <=
    (s_Reg_w_en(0) and ALU_write) when '0',
    Branch_out when others;
    
    
-- For testing purposes, a gate is placed for isRtype
rtype : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => Clk,
		 i_RST => '0',
		 i_WE => '1',
		 i_D => isRtype,
		 o_Q => s_isRtype);
		 
isloadu_idex : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => Clk,
		 i_RST => '0',
		 i_WE => '1',
		 i_D => s_isloadu_control,
		 o_Q => s_isloadu_idex);

isloadu_exmem : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => Clk,
		 i_RST => '0',
		 i_WE => '1',
		 i_D => s_isloadu_idex,
		 o_Q => s_isloadu_exmem);
		 
dmem_w_idex : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => Clk,
		 i_RST => '0',
		 i_WE => '1',
		 i_D => s_dmem_w_control,
		 o_Q => s_dmem_w_idex);

dmem_w_exmem : nbit_dff_falling
	generic map(N => 1)
	port map(i_CLK => Clk,
		 i_RST => '0',
		 i_WE => '1',
		 i_D => s_dmem_w_idex,
		 o_Q => s_dmem_w_exmem);

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
           
           
           -- Register Values start
           
        s_jumparino(0) <=  ((Branch_out) or (isJump(0))); -- Jump is undefined, changed to isJump. May need to change this to some other jump signal
-- IF_ID        
   IFID : IF_ID
    port map(
      i_Clk => CLK, --
      i_Rst => IF_ID_reset, --
      i_We  => '1', --
      i_IMem=> s_imem_IN, --
      i_PC  => PCp4,-- Same value as what iMem is using to read. --
      o_IMem=> instr, -- The output at this stage should only be the instruction --
      o_PC  => s_PCp4_out); --where does s_PCp4_out go to?  Used to go to mux 8, probably should just go to the next register. --

-- DFF for testing - We think the ALU shouldn't feed to IDEX instead it should feed EXMEM

-- ID_EX
  IDEX : ID_EX
    port map(
      i_Clk    => CLK, --
      i_Rst    => ID_EX_reset, --
      i_Flush  => '0', -- Note: We should readdress this. Flush is the same things as reset. -- this fails when reset and flush are the same.
      i_We     => '1', 
      i_RegDst => RegDst, --
      i_jr     => isJump, --
      o_jr     => s_IDEX_jr, --
      i_or     => s_jumparino, --
      o_or     => s_IDEX_or, -- This doesn't connect to anything and this name sucks
      i_alu_32_out => ALU_out, --
      o_alu_32_out => s_IDEX_alu_32_o_F_1, -- 
      i_mux_jump    => dmem_temp_rs, -- This is the jump address --
      o_mux_jump    => d_temp_rs, -- This connects to instruction fetch --
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
      i_We      => '1',              --
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
      i_We      => '1',
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

end structure;
