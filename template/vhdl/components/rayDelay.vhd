library ieee;
use ieee.std_logic_1164.all;

use work.delay_pkg.all;

use work.operations_pkg.all;

entity rayDelay is 
generic (DELAY_LENGTH : NATURAL := 1);
port (clk, reset, clk_en : in std_logic;
inputRay : in ray; outputRay : out ray);
end entity;

architecture arch of rayDelay is
signal subwire0, subwire1 : std_logic_vector(95 downto 0);
begin
delay : delay_element generic map (DEPTH => DELAY_LENGTH, WIDTH => 96)
port map (clk => clk, reset => reset, clken => clk_en, source => subwire0, dest => subwire1);
end architecture;