-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity AddSub is
  generic(N : integer := 32);
	port (A   		    : in  std_logic_vector(N-1 downto 0);
		    B 		      : in  std_logic_vector(N-1 downto 0);
		    nAdd_Sub  : in  std_logic;
		    o_S 		    : out std_logic_vector(N-1 downto 0);
		    o_C 		    : out std_logic);
end AddSub;

architecture structure of AddSub is
	
	component mux2to1 is
		port(i_A : in  std_logic_vector(N-1 downto 0);
			   i_B : in  std_logic_vector(N-1 downto 0);
			   i_S : in  std_logic;
			   o_F : out std_logic_vector(N-1 downto 0));
	end component;

	component onesComp is
		port(i_A : in  std_logic_vector(N-1 downto 0);
			   o_F : out std_logic_vector(N-1 downto 0));
	end component;
	
	component fullAdder is
		port(i_A : in  std_logic_vector(N-1 downto 0);
			   i_B : in  std_logic_vector(N-1 downto 0);
			   i_C : in  std_logic;
			   o_C : out std_logic;
			   o_S : out std_logic_vector(N-1 downto 0));
	end component;
	
	signal sVALUE_nB : std_logic_vector(N-1 downto 0);
	signal sVALUE_oMux : std_logic_vector(N-1 downto 0);
	
begin

   invB : onesComp
		port map (i_A => B,
				      o_F => sVALUE_nB);

   BonB : mux2to1
		port map (i_A => sVALUE_nB,
				      i_B => B,
				      i_S => nAdd_Sub,
				      o_F => sVALUE_oMux);			

	 ApmB : fullAdder
		port map (i_A => A,
				      i_B => sVALUE_oMux,
				      i_C => nAdd_Sub,
				      o_C => o_C,
				      o_S => o_S);
				      
end structure;

-------------------------------------------------------------------------
-- CprE 381 TAs
-- Fall 2016
-------------------------------------------------------------------------