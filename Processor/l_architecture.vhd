-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity l_architecture is
  port(dmem_out	 	: in  std_logic_vector(31 downto 0);
       ADDR    		: in  std_logic_vector(1 downto 0);
       lstypesel 	: in  std_logic_vector(1 downto 0);
       lu_sel     	: in  std_logic;
       to_reg_file	: out std_logic_vector(31 downto 0));
end l_architecture;

architecture structure of l_architecture is
  
component extender8to32 is
  port(i_con        : in  std_logic;
       i_data       : in  std_logic_vector(7 downto 0);  
       o_F          : out std_logic_vector(31 downto 0));   
 end component;

component extender16to32 is
  port(i_con        : in  std_logic;
       i_data       : in  std_logic_vector(15 downto 0);  
       o_F          : out std_logic_vector(31 downto 0));   
end component;

signal lh_data_in : std_logic_vector(15 downto 0);
signal lb_data_in : std_logic_vector(7 downto 0);
signal sign8to32_out, zero8to32_out, sign16to32_out, zero16to32_out, lb_data_out, lh_data_out : std_logic_vector(31 downto 0);

begin

  sign_extend_byte : extender8to32
  port map(i_con => '1',
	   i_data => lb_data_in,
           o_F   => sign8to32_out);

  zero_extend_byte : extender8to32
  port map(i_con => '0',
	   i_data => lb_data_in,
           o_F   => zero8to32_out);

  sign_extend_half : extender16to32
  port map(i_con => '1',
	   i_data => lh_data_in,
           o_F   => sign16to32_out);

  zero_extend_half : extender16to32
  port map(i_con => '0',
	   i_data => lh_data_in,
           o_F   => zero16to32_out);

  with ADDR(1) select lh_data_in <=
        dmem_out(15 downto 0)  when '0',
        dmem_out(31 downto 16) when '1',
        x"0000" when others;

  with ADDR(1 downto 0) select lb_data_in <=
        dmem_out(7 downto 0) when "00",
        dmem_out(15 downto 8) when "01",
        dmem_out(23 downto 16) when "10",
        dmem_out(31 downto 24) when "11",
	x"00" when others;
 
 with lu_sel select lb_data_out <=
	sign8to32_out when '0',
	zero8to32_out when '1',
	x"00000000" when others;

 with lu_sel select lh_data_out <=
	sign16to32_out when '0',
	zero16to32_out when '1',
	x"00000000" when others;

 with lstypesel select to_reg_file <=
	lb_data_out when "00",
	lh_data_out when "01",
	dmem_out    when "10",
	x"00000000" when others;

end structure;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------