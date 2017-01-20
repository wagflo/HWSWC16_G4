library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.delay_pkg.all;

entity latencyTest is

end entity;

architecture arch of latencyTest is

signal clk : std_logic := '0';
signal res : std_logic := '1';
signal r : std_logic_vector (31 downto 0);
signal v1, v2 : std_logic_vector(95 downto 0) := X"000100000001000000010000";

begin

del : delay_element
generic map (WIDTH => 32, DEPTH => 2)
port map ( clk => clk, clken => '1', reset => res, 
source => v1(95 downto 64), dest => v2(95 downto 64));

clk <= not clk after 10 ns;

res <= '0' after 25 ns;

data : process(clk) is 
begin
if rising_edge(clk) then
	v1 <= std_logic_vector(signed(v1) + X"000100000001000000010000");
end if;
end process;

assert clk = '1';

end architecture;