library ieee;
use ieee.std_logic_1164.all;

entity anyRefl is
  port
  (
    clk 	: in std_logic;
    reset 	: in std_logic;
   
    -- kein clock enable, nehme valid

    validRay 	: in std_logic;
    startBundle : in std_logic;

    valid_t	: in std_logic;
    t 		: in std_logic_vector(31 downto 0);
    
    isReflected : out std_logic
  );
end entity;

architecture beh of anyRefl is

signal any, anyNext : std_logic;

begin

anyNext <= (startBundle and valid_t) or
	   (not startBundle and (valid_t or any));

sync : process(clk, reset, validRay)
begin

  if reset = '1' then

    any <= '0';

  elsif rising_edge(clk) and validRay = '1' then

    any <= anyNext;

  end if;

end process;

isReflected <= any;

end architecture;