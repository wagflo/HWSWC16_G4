library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.getRayDir_pkg.all;
use work.operations_pkg.all;

entity latencyTest is

end entity;

architecture arch of latencyTest is

signal clk : std_logic := '0';
signal res : std_logic := '1';
signal s,t : std_logic_vector (31 downto 0) := x"00000000";
signal v1, v2 : std_logic_vector(95 downto 0) := X"000100000001000000010000";
signal v3, v4 : std_logic_vector(95 downto 0) := X"000100000001000000010000";
signal result : vector;



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
if falling_edge(clk) then
	s <= std_logic_vector(signed(s) + X"3");
	t <= std_logic_vector(signed(t) + X"5");
end if;
end process;

assert clk = '1';

end architecture;