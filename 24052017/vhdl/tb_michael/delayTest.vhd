library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.delay_pkg.all;


entity delayTest is

end entity;

architecture arch of delayTest is

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

signal input : std_logic_vector(31 downto 0) := x"5a_6c_5c_6a"; -- := "0000000";
signal output1, output2, output3: std_logic_vector(31 downto 0);


--signal sob, eob : std_logic := '0';

begin


delay1 : delay_element -- standard register delay
  generic map (
    width => 32,
    depth => 3
  )
  port map
  (
    clk => clk,
    clken => '1',
    reset => res,

    source => input,
    dest => output1
  );

delay2 : delay_element -- ram based delay
  generic map (
    width => 32,
    depth => 8
  )
  port map
  (
    clk => clk,
    clken => '1',
    reset => res,

    source => input,
    dest => output2
  );


delay3 : delay_element -- no delay => through-connection
  generic map (
    width => 32,
    depth => 0
  )
  port map
  (
    clk => clk,
    clken => '1',
    reset => res,

    source => input,
    dest => output3
  );


clk <= not clk after 10 ns;

res <= '0' after 25 ns;

--input <= not input after 10 ns;

sync : process(clk, res) 
begin

if res = '1' then

  input <= x"5a_6c_5c_6a";

elsif rising_edge(clk) then

	input <= std_logic_vector(to_signed(to_integer(signed(input)) + 1, 32));

end if;

end process;

--input <= data(counter);
--sob <= input(7);
--eob <= input(6);
--valid_ray <= input(5);
--valid_t <= input(4);
--emitting <= input(3);
--remaining <= input(2 downto 0);

--counting : process(clk, res)
--begin
--if res = '1' then
 
--  input <= "0000000";
--  counter <= 0;
--els
--if rising_edge(clk) then
  --input <= data(counter);
--  counter <= counter + 1;
--  if counter = data'length - 1 then
--    counter <= 0;
--  end if;
--end if;
--end process;

assert output1 = x"00000000";
assert output2 = x"00000000";
assert output3 = x"00000000";



end architecture;