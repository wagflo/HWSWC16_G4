library ieee;
use ieee.std_logic_1164.all;

use work.delay_pkg.all;

library lpm;
use lpm.lpm_components.all;

use work.rayDelay_pkg.all;
use work.operations_pkg.all;


entity closestSpherePrep is
port (
	clk, clk_en, reset 	: in std_logic;
	input_direction 	: vector;
	a			: out std_logic_vector(31 downto 0)
);
end entity;

architecture arch of closestSpherePrep is 

begin
a_cal : vector_square generic map (INPUT_WIDTH => 32, OUTPUT_WIDTH=> 32)
port map (clk => clk, clk_en => clk_en, reset => reset, x => input_direction.x, y => input_direction.y, z => input_direction.z, result => a);
end architecture;