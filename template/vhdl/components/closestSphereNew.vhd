library ieee;
use ieee.std_logic_1164.all;

use work.delay_pkg.all;

use work.rayDelay_pkg.all;

use work.operations_pkg.all;

use work.lpm_util.all;

entity closestSphereNew is

port (
	clk, reset, clk_en 	: in std_logic;
	inputRay		: in ray;
	relevantScene		: in scInput;
	t_times_a		: out std_logic_vector(31 downto 0);
	valid_t			: out std_logic;
	closesSphere		: out sphere
	
);

end entity;

architecture arch of closestSphereNew is
begin

end architecture;
