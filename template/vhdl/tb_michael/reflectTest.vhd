library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components_pkg.all;
use work.operations_pkg.all;

entity reflectTest is

end entity;

architecture arch of reflectTest is

signal clk : std_logic := '1';
signal res : std_logic := '1';
signal valid_t : std_logic := '0';
signal t : std_logic_vector (31 downto 0) := x"00000000";

signal valid_ray_in :std_logic := '0';

signal sphere_i : std_logic_vector (3 downto 0) := x"0";
signal origin, direction : vector;

signal new_origin, new_direction : vector;
signal valid_refl : std_logic;
signal valid_ray_out : std_logic;

constant scalar_zero_std : std_logic_vector(31 downto 0) := x"00000000";
constant vector_zero_std : std_logic_vector(95 downto 0) := scalar_zero_std & scalar_zero_std & scalar_zero_std;

constant scalar_zero : scalar := toscalar(scalar_zero_std);
constant vector_zero : vector := tovector(vector_zero_std);

signal one_over_rs : scalarArray := (others => scalar_zero);
signal centers 	: vectorArray 	 := (others => vector_zero);

--constant three : std_logic_vector(31 downto 0) := x"00030000";
--constant five : std_logic_vector(31 downto 0) := x"00050000";



begin

refl : reflect
port map ( 

  clk => clk, 
  clk_en => '1', 
  reset => res, 

  valid_t => valid_t,
  t => t,

  sphere_i => sphere_i,

  valid_ray_in  => valid_ray_in,

  one_over_rs => one_over_rs,
  centers     => centers,

  origin => origin,
  direction => direction,

  new_origin => new_origin,
  new_direction => new_direction,
  valid_refl  => valid_refl,
  valid_ray_out  => valid_ray_out

);

clk <= not clk after 10 ns;

res <= '0' after 25 ns;

init : process
variable tempvec1, tempvec2, tempvec3 : vector;
variable tempscalar1, tempscalar2, tempscalar3 : scalar;

variable stdscalar1, stdscalar2, stdscalar3 : std_logic_vector(31 downto 0);


begin


stdscalar1 := x"00070000";
tempvec1 := tovector(stdscalar1 & scalar_zero_std & scalar_zero_std);

stdscalar1 := x"000A0000";
stdscalar2 := x"FFFF0000";
tempvec2 := tovector(stdscalar1 & stdscalar2 & scalar_zero_std);

stdscalar1 := x"000E0000";
stdscalar2 := x"FFFF0000";
tempvec3 := tovector(stdscalar1 & stdscalar2 & scalar_zero_std);

centers <= (0 => tempvec1, 1 => tempvec2, 2 => tempvec3, others => vector_zero);



stdscalar1 := x"00010000";
stdscalar2 := x"0000_8000"; --x"0000B505"; -- 
tempscalar1 := toscalar(stdscalar1);
tempscalar2 := toscalar(stdscalar2);

one_over_rs <= (0 => tempscalar1, 1 => tempscalar2, 2 => tempscalar1, others => scalar_zero);

direction <= tovector(stdscalar1 & scalar_zero_std & scalar_zero_std);

origin <= tovector(stdscalar1 & scalar_zero_std & scalar_zero_std);

wait for 1 sec;

end process;


data : process
begin

wait for 40 ns; --110 ns;

t <= x"00050000";
sphere_i <= x"0";

wait for 40 ns;

t <= x"0007_4498"; --x"00080000"; -- 
sphere_i <= x"1";
wait for 40 ns;

t <= x"000D0000";
sphere_i <= x"2";
end process;

--toggle_valid : process
--begin

--wait for 110 ns;

valid_t <= not valid_t after 160 ns;

valid_ray_in <= not valid_ray_in after 20 ns;

--end process;

assert new_origin = vector_zero;
assert new_direction = vector_zero;
assert valid_refl = '1';
assert valid_ray_out = '1';






end architecture;