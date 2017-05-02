library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components_pkg.all;
use work.operations_pkg.all;

entity anyReflTest is

end entity;

architecture arch of anyReflTest is

signal clk : std_logic := '1';
signal res : std_logic := '1';
signal valid_t : std_logic := '0';

signal sob, eob, emitting, valid_ray : std_logic;
signal remaining : std_logic_vector(2 downto 0);
signal num_samples : std_logic_vector(4 downto 0);

signal is_refl, pseudoReflect, valid_data, sob_out, eob_out : std_logic;

-- BEWARE OF LONG INIT/RESET PHASE: 17 clocks

type data_array is array(natural range <>) of std_logic_vector(7 downto 0);

signal data : data_array(14 downto 0) := (
	-- sob, eob, valid_ray, valid_t, emitting, remaining
	0 => "10100111", -- no refl (no valid_t)			nr p
	1 => "01110111", -- refl => all pseudo				r  p
	2 => "00000001",	--					0  0
	3 => "00000010",	--					0  0	
	4 => "00000100", --						0  0
	5 => "10110000", --						nr np 
	6 => "01110000", -- no remaining => no pseudo => no refl	nr np
	7 => "10111010", -- 						nr np
	8 => "01111010", -- valid_t but, emitting => no pseudo, no refl	nr np
	9 => "00000000", --						0  0   => kleiner Fehler, aber ausserhalb von sob, eob
	10=> "00000000", --						0  0
	11=> "10110010", -- refl					r  p
	12=> "01111010", -- only one emitting => pseudo                 nr p
	13=> "10101010", -- 						nr np
	14=> "01101010"); -- no refl, just emitting => no pseudo	nr np

signal input : std_logic_vector(7 downto 0); -- := "0000000";

signal counter : natural := 0;

begin

refl : anyRefl  
    port map (
    clk 	=> clk,
    clk_en => '1',
    reset 	=> res,

    num_samples	=> "00010", --num_samples,

    endOfBundle => eob,
    startOfBundle => sob,

    valid_ray_in => valid_ray,

    remaining_reflects => remaining,
    emitting_sphere => emitting,

    valid_t	=> valid_t,
    
    isReflected => is_refl,
    pseudoReflect => pseudoReflect,
    valid_ray_out => valid_data,

    startOfBundle_out => sob_out,
    endOfBundle_out => eob_out
    
  );

clk <= not clk after 10 ns;

res <= '0' after 25 ns;

input <= data(counter);
sob <= input(7);
eob <= input(6);
valid_ray <= input(5);
valid_t <= input(4);
emitting <= input(3);
remaining <= input(2 downto 0);

counting : process(clk, res)
begin
--if res = '1' then
 
--  input <= "0000000";
--  counter <= 0;
--els
if rising_edge(clk) then
  --input <= data(counter);
  counter <= counter + 1;
  if counter = data'length - 1 then
    counter <= 0;
  end if;
end if;
end process;

--datap : process
--begin

--wait for 40 ns; --110 ns;

--sphere_i <= x"0";
--wait for 40 ns;

--sphere_i <= x"1";
--wait for 40 ns;

--sphere_i <= x"2";
--end process;



assert is_refl = '0';
assert pseudoReflect = '0';
assert valid_data = '0';
assert sob_out = '0';
assert eob_out = '0';


end architecture;