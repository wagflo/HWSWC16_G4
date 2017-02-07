library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components_pkg.all;
use work.operations_pkg.all;

entity reflectTest is

end entity;

architecture arch of reflectTest is

signal clk : std_logic := '0';
signal res : std_logic := '1';
signal valid_t : std_logic := '0';
signal t : std_logic_vector (31 downto 0) := x"00000000";
signal sphere_i : std_logic_vector (3 downto 0) := x"0";
constant v1, v2 : std_logic_vector(95 downto 0) := X"000100000001000000010000";
constant v3, v4 : std_logic_vector(95 downto 0) := X"000100000001000000010000";
signal origin, direction : vector;
signal new_origin, new_direction : vector;
signal valid_refl : std_logic;

--constant three : std_logic_vector(31 downto 0) := x"00030000";
--constant five : std_logic_vector(31 downto 0) := x"00050000";



begin

refl : reflect
--generic map (WIDTH => 32, DEPTH => 2)
port map ( 

  clk => clk, 
  clken => '1', 
  reset => res, 

  valid_t => valid_t_input,
  t => t,

  sphere_i => sphere_i,

  one_over_rs : scalarArray,
  centers     : vectorArray,

  origin => origin,
  direction => direction,

  new_origin => new_origin,
  new_direction => new_direction,
  valid_refl  => valid_refl

);

clk <= not clk after 10 ns;

res <= '0' after 25 ns;

data : process(clk) is 
begin
if rising_edge(clk) then
	--s <= std_logic_vector(signed(s) + signed(three));
--	t <= std_logic_vector(signed(t) + signed(five));
end if;
end process;

end architecture;