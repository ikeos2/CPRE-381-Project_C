-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity dmem is 
  generic (mif_filename : string := "mem.mif");
  port(address    : in  std_logic_vector(31 downto 0);
       data_in    : in  std_logic_vector(31 downto 0);
       lstypesel  : in  std_logic_vector(1 downto 0);
       lu_sel     : in  std_logic;
       clock      : in  std_logic;
       wren       : in  std_logic;
       data_out   : out std_logic_vector(31 downto 0));
end dmem;

architecture structure of dmem is

component l_architecture is
  port(dmem_out	 	: in  std_logic_vector(31 downto 0);
       ADDR    		: in  std_logic_vector(1 downto 0);
       lstypesel 	: in  std_logic_vector(1 downto 0);
       lu_sel     	: in  std_logic;
       to_reg_file	: out std_logic_vector(31 downto 0));
end component;

component s_architecture is
  port(ADDR    	 : in  std_logic_vector(1 downto 0);
       DATA    	 : in  std_logic_vector(31 downto 0);
       lstypesel : in  std_logic_vector(1 downto 0);
       byteena 	 : out std_logic_vector(3 downto 0);
       dmem_data : out std_logic_vector(31 downto 0));
end component;

component mem
 	generic(depth_exp_of_2 	: integer := 10;
			    mif_filename 	: string := "mem.mif");
  port(address			: IN  STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');
       byteena			: IN  STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '1');
       clock			: IN  STD_LOGIC := '1';
       data			: IN  STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
       wren			: IN  STD_LOGIC := '0';
       q			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)); 
end component;
 
signal byteena_temp : std_logic_vector(3 downto 0);
signal dmem_data_temp, dmem_out,dummy : std_logic_vector(31 downto 0);


begin

  store_arch : s_architecture
    port map(ADDR => address(1 downto 0),
             DATA => data_in,
             lstypesel => "10",
             byteena => byteena_temp,
             dmem_data => dmem_data_temp);

  memory : mem
    generic map(mif_filename => mif_filename)
    port map(address => address(11 downto 2),
	     byteena => byteena_temp,
	     clock => clock,
	     data => dmem_data_temp,
             wren => wren,
	     q => data_out);

  load_arch : l_architecture
    port map(dmem_out => dmem_out,
             ADDR => address(1 downto 0),
	     lstypesel => "10",
             lu_sel => lu_sel,
             to_reg_file => dummy);--data_out);

end structure;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------
