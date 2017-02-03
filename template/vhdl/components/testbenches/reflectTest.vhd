library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components_pkg.all;
use work.operations_pkg.all;

entity reflTest is

end entity;

architecture arch of latencyTest is

signal clk : std_logic := '0';
signal res : std_logic := '1';
signal s,t : std_logic_vector (31 downto 0) := x"00000000";
constant v1, v2 : std_logic_vector(95 downto 0) := X"000100000001000000010000";
constant v3, v4 : std_logic_vector(95 downto 0) := X"000100000001000000010000";
signal result : vector;


constant three : std_logic_vector(31 downto 0) := x"00030000";
constant five : std_logic_vector(31 downto 0) := x"00050000";



begin

grd : getRayDir
--generic map (WIDTH => 32, DEPTH => 2)
port map ( clk => clk, clken => '1', reset => res, 

s => s,
t => t,


camera_horizontal => tovector(v1),
camera_vertical => tovector(v2),
camera_lower_left_corner => tovector(v3),
camera_origin => tovector(v4),

result => result
);

clk <= not clk after 10 ns;

res <= '0' after 25 ns;

data : process(clk) is 
begin
if rising_edge(clk) then
	s <= std_logic_vector(signed(s) + signed(three));
	t <= std_logic_vector(signed(t) + signed(five));
end if;
end process;

end architecture;