library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity forwarding_TB is

end forwarding_TB;

architecture behavior of forwarding_TB is

	-- Declare the component we are going to instantiate
	component Forwarding is
		port(IFIDimem, IDEXimem, EXMEMimem, MEMWBimem : in std_logic_vector(31 downto 0);
		MEMWBregwr, EXMEMregwr, MEMWBregdst, EXMEMregdst, MEMWBal : in std_logic_vector(0 downto 0);
		fwdALU1, fwdALU2: out std_logic_vector(1 downto 0);
		fwdBranch1, fwdBranch2 : out std_logic);
	
	end component;

-- Signals connecting to the module
	signal instruction 	: std_logic_vector(31 downto 0);

	

	begin

		DUT: MIPS_processor 
		port map(IFIDimem,
			 IDEXimem,	
			 EXMEMimem,
			 MEMWBimem : in std_logic_vector(31 downto 0);
			 MEMWBregwr,
			 EXMEMregwr,
			 MEMWBregdst,
			 EXMEMregdst,
			 MEMWBal : in std_logic_vector(0 downto 0);
			 fwdALU1, 
			 fwdALU2: out std_logic_vector(1 downto 0);
			 fwdBranch1,
			 fwdBranch2 : out std_logic);

		process
		begin
		clock <= not clock after half_period; -- Drive clock signal
		
		wait for 1 ns;
		reset <= '0';
		
		
		
		--	i_A <= "00000000000000000000000000000000";
		--	i_B <= "00000000000000000000000000000000";
		--	wait for 100 ns;

		--	i_A <= "11111111111111111111111111111111";
		--	i_B <= "11111111111111111111111111111111";

	end process;
  
end behavior;
