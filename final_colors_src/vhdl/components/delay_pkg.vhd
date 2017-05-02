library ieee;
use ieee.std_logic_1164.all;

package delay_pkg is

  component delay_element is
	generic
	(
	  WIDTH : natural;
	  DEPTH : natural
	);
	port
	(
	  clk 	: in std_logic;
	  reset : in std_logic;
	  clken : in std_logic;
	
	  source 	: in std_logic_vector(WIDTH - 1 downto 0);
	  dest 		: out std_logic_vector(WIDTH - 1 downto 0)
	);
  end component delay_element;

  --procedure delay(source, dest : std_logic_vector; cycles : natural := 0; clk, reset, clken : std_logic_vector);

end package delay_pkg;

--package body math_pkg is

--  procedure delay(source, dest : std_logic_vector; cycles : natural := 0; clk, reset, clken : std_logic_vector) is 

--  begin

--	if cycles > 0 then 

--	-- echtes delay

--	else 
	
--	  dest <= source;

--	end if 

--  end procedure;

--end package body;
