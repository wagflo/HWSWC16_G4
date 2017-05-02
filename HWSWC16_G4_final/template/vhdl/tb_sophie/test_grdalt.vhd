library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.operations_pkg.all;
use work.components_pkg.all;

entity test_grdalt is

end entity;

architecture arch of test_grdalt is

constant zero_vec : vector := (OTHERS => (OTHERS => '0'));
constant one_hor : vector := (x=> x"00010000", OTHERS => (OTHERS => '0'));
constant one_ver : vector := (y=> x"00010000", OTHERS => (OTHERS => '0'));
constant zero_ray : ray := (direction => zero_vec, origin => zero_vec, 
	color => zero_vec, remaining_reflects=> (OTHERS => '0'), 
	position=> (OTHERS => '0'), OTHERS => '0');

signal clk, stall, hold, reset, done, valid, valid_data, start, clk_en, fifo_full : std_logic := '1';
signal output_ray, right_ray : ray;

signal i : natural := 0;

begin

clk_en <= NOT(stall);

grdald : getRayDirAlt 
generic map (
	MAXWIDTH => 5,
	MAXHEIGHT => 7
)
port map (
    clk => clk, clk_en  => clk_en, hold =>'0', reset => reset, 
    start => start, 
    valid_data => valid_data,
    fifo_full => fifo_full,

    frame => "01",

    num_samples => "00001",


    num_reflects  => "111",

    camera_center => zero_vec,

    addition_hor => one_hor,

    addition_ver => one_ver,

    addition_base => zero_vec,

    outputRay => output_ray,

    done => done,
    valid => valid
);

clk <= NOT(clk) after 10 ns;
reset <= '0' after 10 ns;

right_ray <= output_ray when stall='0' else zero_ray;

sync_update : process(clk, reset, i) is begin
	if reset = '1' then
		i <= 0;
		stall <= '0';
		start <= '0';
		valid_data <= '0';
	elsif rising_edge(clk) then
		i <= i+1;
		if i = 1 then start <= '1'; valid_data <= '1';
		else start <= '0';
		end if;
		if (i mod 10) = 0 then
			stall <= '1';
		else
			stall <= '0';
		end if;
		if (i mod 3 = 0) then
			fifo_full <= '0';
		else
			fifo_full <= '1';
		end if;
	end if;
end process;

assert right_ray.valid /= '0';

end architecture;