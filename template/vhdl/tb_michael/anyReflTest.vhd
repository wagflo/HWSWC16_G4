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

signal sob, eob, emitting : std_logic;
signal remaining : std_logic_vector(2 downto 0);
signal num_samples : std_logic_vector(4 downto 0);

signal is_refl, pseudoReflect, valid_data, sob_out, eob_out : std_logic;

type data_array is array(natural range <>) of std_logic_vector(6 downto 0);

signal data : data_array(8 downto 0) := (
	-- sob, eob, valid_t, emitting, remaining
	0 => "1010111",
	1 => "0110111",
	2 => "0000000",
	3 => "0000000",
	4 => "0000000",
	5 => "1010000",
	6 => "0110000",
	7 => "1011010",
	8 => "0111010" );

signal input : std_logic_vector(6 downto 0); -- := "0000000";

signal counter : natural := 0;

begin

refl : anyRefl  
    port map (
    clk 	=> clk,
    reset 	=> res,

    num_samples	=> "00010", --num_samples,

    endOfBundle => eob,
    startOfBundle => sob,

    remaining_reflects => remaining,
    emitting_sphere => emitting,

    valid_t	=> valid_t,
    
    isReflected => is_refl,
    pseudoReflect => pseudoReflect,
    valid_data => valid_data,

    startOfBundle_out => sob_out,
    endOfBundle_out => eob_out
    
  );

clk <= not clk after 10 ns;

res <= '0' after 25 ns;

input <= data(counter);
sob <= input(6);
eob <= input(5);
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