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
constant rayWidth : natural := 318;
constant color_start : natural := 317;
constant color_end : natural := 222;
constant origin_start : natural := 221;
constant origin_end : natural := 126;
constant direction_start : natural := 125;
constant direction_end : natural := 30;
constant position_start : natural := 29;
constant position_end : natural := 8;
constant refl_start : natural := 7;
constant refl_end : natural := 5;
constant sob : natural := 4;
constant eob : natural := 3;
constant copy : natural := 2;
constant pseudo_refl : natural := 1;
constant valid : natural := 0;
signal source, dest : std_logic_vector(317 downto 0);
begin
delay : delay_element generic map (DEPTH => DELAY_LENGTH, WIDTH => rayWidth)
port map (clk => clk, reset => reset, clken => clk_en, source => source, dest => dest);
source(color_start downto color_end) <= to_std_logic(inputRay.color);
source(origin_start downto origin_end) <= to_std_logic(inputRay.origin);
source(direction_start downto direction_end) <= to_std_logic(inputRay.direction);
source(position_start downto position_end) <= inputRay.position;
source(refl_start downto refl_end) <= inputRay.remaining_reflects;
source(sob) <= inputRay.sob;
source(eob) <= inputRay.eob;
source(copy) <= inputRay.copy;
source(pseudo_refl) <= inputRay.pseudo_refl;
source(valid) <= inputRay.valid;
outputRay.color <= tovector(dest(color_start downto color_end));
outputRay.origin <= tovector(dest(origin_start downto origin_end));
outputRay.direction <= tovector(dest(direction_start downto direction_end));
outputRay.position <= dest(position_start downto position_end);
outputRay.remaining_reflects <= dest(refl_start downto refl_end);
outputRay.sob <= dest(sob);
outputRay.eob <= dest(eob);
outputRay.pseudo_refl <= dest(pseudo_refl);
outputRay.copy <= dest(copy);
outputRay.valid <= dest(valid);
end architecture;