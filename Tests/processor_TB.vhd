library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity proccesor_TB is

end proccesor_TB;

architecture behavior of proccesor_TB is

	-- Declare the component we are going to instantiate
	component MIPS_processor is
	  generic(N : integer := 32;
		  dmem_mif_filename : string := "dmem_bubblesort.mif";
		  imem_mif_filename : string := "imem_SimpleAdding.mif");
		  port(CLK            : in  std_logic;
			reg_reset      : in  std_logic;
			PC_reset       : in  std_logic; -- Begin new
			isRtype_out	: out std_logic;
			isLinkALU_out	: out std_logic;
			ALU_write_out	: out std_logic;
			isUnsignedALU_out : out std_logic;
			zero_out	: out std_logic;
			dmem_out_out	: out std_logic_vector(31 downto 0);
			ALU_out_out 	: out std_logic_vector(31 downto 0);
			instruction : out std_logic_vector(31 downto 0); -- End new
			PCplus4     : out std_logic_vector(31 downto 0);
			rs_data : out std_logic_vector(31 downto 0);
			rt_data : out std_logic_vector(31 downto 0));
	end component;

-- Signals connecting to the module
	signal instruction 	: std_logic_vector(31 downto 0);
	signal counter		: std_logic_vector(31 downto 0); 
	signal rs_data 		: std_logic_vector(31 downto 0);
	signal rt_data 		: std_logic_vector(31 downto 0);
	signal isRtype_out	: std_logic;
	signal isLinkALU_out	: std_logic;
	signal ALU_write_out	: std_logic;
	signal isUnsignedALU_out: std_logic;
	signal zero_out		: std_logic;
	signal dmem_out_out	: std_logic_vector(31 downto 0);
	signal ALU_out_out	: std_logic_vector(31 downto 0);
	constant half_period 	: time := 50 ns; -- for a period of 100 ns
	signal clock		: std_logic := '1';
	signal reset		: std_logic := '1';
	

	begin

		DUT: MIPS_processor 
		port map(CLK		=> clock,
			reg_reset	=> reset,
			PC_reset	=> reset,
			isRtype_out	=> isRtype_out,
			isLinkALU_out	=> isLinkALU_out,
			ALU_write_out	=> ALU_write_out,
			isUnsignedALU_out => isUnsignedALU_out,
			zero_out	=> zero_out,
			dmem_out_out	=> dmem_out_out,
			ALU_out_out	=> ALU_out_out,
			instruction 	=> instruction,
			PCplus4     	=> counter,
			rs_data 	=> rs_data,
			rt_data		=> rt_data);

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
