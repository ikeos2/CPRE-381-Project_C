-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity s_architecture is
  port(ADDR    	 : in  std_logic_vector(1 downto 0);
       DATA    	 : in  std_logic_vector(31 downto 0);
       lstypesel : in  std_logic_vector(1 downto 0);
       byteena 	 : out std_logic_vector(3 downto 0);
       dmem_data : out std_logic_vector(31 downto 0));
end s_architecture;

architecture structure of s_architecture is
  
component sb_decoder is
  port(i_sel        : in std_logic_vector(1 downto 0);  
       o_F          : out std_logic_vector(3 downto 0));   
 end component;

component sh_decoder is
  port(i_sel        : in std_logic;  
       o_F          : out std_logic_vector(3 downto 0));   
 end component;

signal sb_decoder_out, sh_decoder_out : std_logic_vector(3 downto 0);
signal sb_data, sh_data : std_logic_vector(31 downto 0);

begin

  sb_decode : sb_decoder
  port map(i_sel => ADDR,
           o_F   => sb_decoder_out);

  sh_decode : sh_decoder
  port map(i_sel => ADDR(1),
	   o_F => sh_decoder_out);

  with lstypesel select byteena <=
        sb_decoder_out when "00",
        sh_decoder_out when "01",
        "1111" when "10",
        "0000" when others;
  
  sb_data(31 downto 24) <= DATA(7 downto 0);
  sb_data(23 downto 16) <= DATA(7 downto 0);
  sb_data(15 downto 8)  <= DATA(7 downto 0);
  sb_data(7 downto 0)   <= DATA(7 downto 0);

  sh_data(31 downto 16) <= DATA(15 downto 0);
  sh_data(15 downto 0)  <= DATA(15 downto 0);

  with lstypesel select dmem_data <=
        sb_data when "00",
        sh_data when "01",
        DATA when "10",
        x"00000000" when others;

end structure;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------