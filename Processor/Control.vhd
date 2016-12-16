
-- Control.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a dataflow implementation of our 
-- control logic for the different branch functions
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


entity Control is
  port(Instr          : in  std_logic_vector(5 downto 0);
       rt_Addr        : in  std_logic_vector(4 downto 0);
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
       ImmSign	      : out std_logic;
       ALU_OP         : out std_logic_vector(5 downto 0);
       Branch_Sel     : out std_logic_vector(2 downto 0);
       lsTypeSel      : out std_logic_vector(1 downto 0));
end Control;


architecture dataflow of Control is
  signal Sig_Reg_w_en, Sig_isLink :std_logic;
  signal Sig_Branch_Sel           :std_logic_vector(2 downto 0);
  signal Sig_isBranchLink         :std_logic;
  
begin
  
  with Instr select bgtz_blez <=
       '1'  when "000111",
       '1'  when "000110",
       '0'  when others;
       
  with Instr select ALU_OP <=
       "100001"  when "001001",--Addiu
       "100100"  when "001100",--Andi
       "111111"  when "011100",--mul
       "100101"  when "001101",--ori
       "100110"  when "001110",--xori
       "101010"  when "001010",--slti
       "101011"  when "001011",--sltiu
       "100010"  when "000100",--beq
       "101010"  when "000111",--bgtz
       "101010"  when "000110",--blez
       "100010"  when "000101",--bne
       "101010"  when "000001",--other branch instructions
       "100000"  when others;   
  
   with Instr select Branch <=
      '1' when "000100",
      '1' when "000001",
      '1' when "000111",
      '1' when "000110",
      '1' when "000101",
      '0' when others;
  
   with Instr select isJump <=
      '1' when "000010",
      '1' when "000011",
      '0' when others;    
      
   with Instr select dmem_w_en <=
      '1' when "101000",
      '1' when "101001",
      '1' when "101011",
      '0' when  others;   
       
    with Instr select Reg_w_en <=
    	'0' when "000100",
    	Sig_Reg_w_en when "000001",
    	'0' when "000111",
    	'0' when "000110",
    	'0' when "000101",
    	'0' when "000010",
    	'0' when "101000",
    	'0' when "101001",
    	'0' when "101011",
    	'1' when others;
    
    with rt_Addr select Sig_Reg_w_en <= 	
    	'1'          when "10001",
    	'1'          when "10000",
    	'0'          when others;
    
    with Instr select RegDst <=
    	'0' when "000000",
    	'0' when "011100",
    	'1' when others;
    	
    with rt_Addr select Sig_isLink <=
    	'0'        when "00000",
    	'0'        when "00001",
    	'1'        when others;
    	
    with Instr select isBranchLink <=
    	Sig_isLink when "000001",
    	'0' when others;
    	
    with Instr select isLink <= 
    	'1'        when "000011",
    	Sig_isLink when "000001",
    	'0'        when others;
    	
    with Instr select UpperImm <=
    	'1' when "001111",
    	'0' when others;
    
    with Instr select isImmAlu <=
    	'0' when "000000",
    	'0' when "011100",
    	'0' when "001111",
    	'0' when "000100",
    	'0' when "000111",
    	'0' when "000110",
    	'0' when "000101",
    	'0' when "000010",
    	'0' when "000011",
    	'1' when others;
    	
    with Instr select isLoad <=
    	'1' when "100000",
    	'1' when "100100",
    	'1' when "100001",
    	'1' when "100101",
    	'1' when "100011",
    	'0' when others;
    	
    with Instr select Branch_Sel <=
    	"000" when "000100",
    	"011" when "000111",
    	"100" when "000110",
    	"111" when "000101",
    	Sig_Branch_Sel when others;
    	
    with rt_Addr select Sig_Branch_Sel <=
    	"001"          when "00001",
    	"010"          when "10001",
    	"101"          when "10000",
    	"110"          when others;
    	
    with Instr select isRtype <=
    	'1' when "000000",
    	'0' when others;
    
    with Instr select compareZero <=
    	'1' when "000001",
    	'0' when others;
    	
    with Instr select isLoadU <=
        '1' when "100100",
        '1' when "100101",
        '0' when others;

    with Instr select lsTypeSel <=
        "00" when "100000",
        "00" when "100100",
        "00" when "101000",
        "01" when "100001",
        "01" when "100101",
        "01" when "101001",
        "10" when "100011",
        "10" when "101011",
        "11" when others;
        
end dataflow;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------
       
