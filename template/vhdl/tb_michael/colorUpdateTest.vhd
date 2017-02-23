library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components_pkg.all;
use work.operations_pkg.all;

entity colorUpdateTest is

end entity;

architecture arch of colorUpdateTest is

signal clk : std_logic := '1';
signal res : std_logic := '1';
signal valid_t : std_logic := '0';
signal valid_ray_in :std_logic := '0';

signal sphere_i : std_logic_vector (3 downto 0) := x"0";

signal color_in, color_out : vector;
signal valid_color : std_logic;
signal valid_ray_out : std_logic;

constant scalar_zero_std : std_logic_vector(31 downto 0) := x"00000000";
constant vector_zero_std : std_logic_vector(95 downto 0) := scalar_zero_std & scalar_zero_std & scalar_zero_std;

constant scalar_zero : scalar := toscalar(scalar_zero_std);
constant vector_zero : vector := tovector(vector_zero_std);

--signal one_over_rs : scalarArray := (others => scalar_zero);
signal colors 	: vectorArray 	 := (others => vector_zero);

--constant three : std_logic_vector(31 downto 0) := x"00030000";
--constant five : std_logic_vector(31 downto 0) := x"00050000";



begin

refl : colorUpdate  
  port map
  (
    clk => clk,
    clk_en => '1',
    reset => res,

    color_in => color_in,
    valid_t  => valid_t,
    sphere_i => sphere_i,

    valid_ray_in  => valid_ray_in,

    -- Kugeldaten: Farbe, ws nicht emitting

    color_array => colors,
    
    color_out => color_out,
    valid_color => valid_color,

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

colors <= (0 => tempvec1, 1 => tempvec2, 2 => tempvec3, others => vector_zero);


stdscalar1 := x"00010000";
stdscalar2 := x"0000_8000"; --x"0000B505"; -- 

color_in <= tovector(stdscalar1 & stdscalar2 & stdscalar2);

wait for 1 sec;

end process;


data : process
begin

wait for 40 ns; --110 ns;

sphere_i <= x"0";
wait for 40 ns;

sphere_i <= x"1";
wait for 40 ns;

sphere_i <= x"2";
end process;

--toggle_valid : process
--begin

--wait for 110 ns;

valid_t <= not valid_t after 120 ns;

valid_ray_in <= not valid_ray_in after 20 ns;

--end process;

assert color_out = vector_zero;
assert valid_color = '1';






end architecture;