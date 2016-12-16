library IEEE;
use IEEE.std_logic_1164.all;

entity hazard is
  port(IFIDimem, IDEXimem, EXMEMimem, MEMWBimem : in std_logic_vector(31 downto 0);
		MEMWBregwr, EXMEMregwr, MEMWBregdst, EXMEMregdst, MEMWBal : in std_logic_vector(0 downto 0);
		fwdALU1, fwdALU2: out std_logic_vector(1 downto 0);
		fwdBranch1, fwdBranch2 : out std_logic);
	
end hazard;


-- FILE WILL NEED UPDATING ONCE PIPELINED PROCESSOR IS FIRST IMPLEMENTED:  MAKES SOME ASSUMPTIONS ON WHAT SIGNALS WILL BE PRESENT


architecture dataflow of hazard is

signal IDEXrs, IDEXrt, IDEXrd, IFIDrs, IFIDrt, IFIDrd, EXMEMrs, EXMEMrt, EXMEMrd, MEMWBrs, MEMWBrt, MEMWBrd : std_logic_vector(4 downto 0);
signal sMEMWBregwr, sMEMWBal, sEXMEMregwr, sEXMEMregdst, sMEMWBregdst : std_logic_vector(0 downto 0);

begin


Possible matches




IDEXrs <= IDEXimem(25 downto 21);
IDEXrt <= IDEXimem(20 downto 16);
IDEXrd <= IDEXimem(15 downto 11);
IFIDrs <= IFIDimem(25 downto 21);
IFIDrt <= IFIDimem(20 downto 16);
IFIDrd <= IFIDimem(15 downto 11);
EXMEMrs <= EXMEMimem(25 downto 21);
EXMEMrt <= EXMEMimem(20 downto 16);
EXMEMrd <= EXMEMimem(15 downto 11);
MEMWBrs <= MEMWBimem(25 downto 21);
MEMWBrt <= MEMWBimem(20 downto 16);
MEMWBrd <= MEMWBimem(15 downto 11);

sMEMWBregwr <= MEMWBregwr;
sEXMEMregwr <= EXMEMregwr;
sEXMEMregdst <= EXMEMregdst;
sMEMWBregdst <= MEMWBregdst;
sMEMWBal <= MEMWBal;


process(sEXMEMregdst, sMEMWBregdst, sMEMWBregwr, MEMWBrd, MEMWBrs, MEMWBrt, EXMEMrt, IDEXrs, sEXMEMregwr, EXMEMrd, sMEMWBal)
	begin
    
		--x = arithmetic/logical instruction
		--xi = arithmetic/logical instruction with immediate
		
		-- x $1, $2, $3
		-- x $3, $1, $2 RAW
		if (sEXMEMregdst = "1" and sEXMEMregwr = "1" and (EXMEMrd = IDEXrs) and (not (EXMEMrd = "00000"))) then
			fwdALU1 <= "01";
		
		-- xi $1, $2, $3
		-- x  $3, $1, $2  RAW
		elsif ((not (sEXMEMregdst = "1") )	and sEXMEMregwr = "1" and (EXMEMrt = IDEXrs) and (not (EXMEMrt = "00000"))) then
			fwdALU1 <= "01";
			
		--x $1, $2, $3
		--nop
		--x $3, $1, $2  RAW
		elsif (sMEMWBregdst = "1" and sMEMWBregwr = "1" and (MEMWBrd = IDEXrs) and (not (MEMWBrd = "00000"))) then
			fwdALU1 <= "10";
	
		--xi $1, $2, $3
		--nop
		--x  $3, $1, $2  RAW
		elsif ((not (sMEMWBregdst = "1") )	and sMEMWBregwr = "1" and (MEMWBrt = IDEXrs) and (not (MEMWBrt = "00000"))) then
			fwdALU1 <= "10";
		
		elsif	((sMEMWBal = "1" and sMEMWBregwr = "1" and IDEXrs="11111")) then
			fwdALU1 <= "10";
		
		else
			fwdALU1 <= "00";
		end if;
	end process;

	process(sEXMEMregdst, sMEMWBregdst, sMEMWBregwr, MEMWBrd, MEMWBrt, IDEXrt, sEXMEMregwr, EXMEMrd, EXMEMrt)
	begin

		--x $1, $2, $3
		--x $3, $2, $1  RAW
		if (sEXMEMregdst = "1" and sEXMEMregwr = "1" and (EXMEMrd = IDEXrt) and (not (EXMEMrd = "00000"))) then
			fwdALU2 <= "01";
			
		--xi $1, $2, $3
		--x  $3, $2, $1  RAW
		elsif ((not (sEXMEMregdst = "1"))	and sEXMEMregwr = "1" and (EXMEMrt = IDEXrt) and (not (EXMEMrt = "00000"))) then
			fwdALU2 <= "01";
			
		--x $1, $2, $3
		--nop
		--x $3, $2, $1  RAW
		elsif (sMEMWBregdst = "1" and sMEMWBregwr = "1" and (MEMWBrd = IDEXrt) and (not (MEMWBrd = "00000"))) then
			fwdALU2 <= "10";
			
		--xi $1, $2, $3
		--nop
		--x  $3, $2, $1  RAW		
		elsif (not (sMEMWBregdst = "1")	and sMEMWBregwr = "1" and (MEMWBrt  = IDEXrt) and (not (MEMWBrt = "00000"))) then
			fwdALU2 <= "10";
			
		elsif	((sMEMWBal = "1" and sMEMWBregwr = "1"	and IDEXrt="11111")) then
			fwdALU2 <= "10";
			
		else
			fwdALU2 <= "00";
		end if;
	end process;
	
	process(sEXMEMregdst, sEXMEMregwr, EXMEMrd, IFIDrs, IFIDrt, EXMEMrt)
	begin

		--x $1, $2, $3
		--nop
		--branch $1, $2, L1
		if (sEXMEMregdst = "1" and sEXMEMregwr = "1" and (EXMEMrd = IFIDrs) and (not (EXMEMrd = "00000"))) then
			fwdBranch1 <= '1';
			
		--xi $1, $2, $3
		--nop
		--branch $1, $2, L1		
		elsif ((not (sEXMEMregdst = "1"))	and sEXMEMregwr = "1" and (EXMEMrt = IFIDrs) and (not (EXMEMrt = "00000"))) then
			fwdBranch1 <= '1';
		else
			fwdBranch1 <= '0';
		end if;

		--x $1, $2, $3
		--nop
		--branch $2, $1, L1		
		if (sEXMEMregdst = "1" and sEXMEMregwr = "1" and (EXMEMrd = IFIDrt) and (not (EXMEMrd = "00000"))) then
			fwdBranch2 <= '1';
			
		--xi $1, $2, $3
		--nop
		--branch $2, $1, L1	
		elsif ((not (sEXMEMregdst = "1") )	and sEXMEMregwr = "1" and (EXMEMrt = IFIDrt) and (not (EXMEMrt = "00000"))) then
			fwdBranch2 <= '1';
			
		else
			fwdBranch2 <= '0';
		end if;
	end process;

end dataflow;
