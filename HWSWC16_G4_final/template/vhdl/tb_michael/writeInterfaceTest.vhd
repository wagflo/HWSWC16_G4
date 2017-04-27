library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components_pkg.all;
use work.operations_pkg.all;

entity writeIFTest is

end entity;

architecture arch of writeIFTest is

constant PIPEMAX : integer := 12; -- how much can be in pipeline

constant RAYPERIOD : integer := 7;
constant RAYCYCLESACTIVE : integer := 0;-- including zero
constant FIFOSIZE : integer := 5;

signal pipeline : std_logic_vector(PIPEMAX - 1 downto 0) := (others => '0');

signal clk : std_logic := '1';
signal res : std_logic := '1';
signal valid_t : std_logic := '0';

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
signal output1, output2 : std_logic_vector(31 downto 0);

signal counter : integer := 0;
signal pipeline_counter : integer := PIPEMAX;
signal slave_counter : integer := 0;

signal input_address 	: std_logic_vector(31 downto 0);
signal input_color 	: std_logic_vector(23 downto 0);
signal input_valid 	: std_logic;
signal output_address	: std_logic_vector(31 downto 0);
signal output_color 	: std_logic_vector(31 downto 0);
signal output_write 	: std_logic;

signal stall : std_logic;
signal finished : std_logic;

signal waitreq : std_logic := '0';

function to_std_logic(input : boolean) return std_logic is
begin
if input then
  return '1';
else
  return '0';
end if;
end function;

function rayOrNot(count : integer; period : integer; active : integer) return std_logic is
begin

return to_std_logic(count mod period <= active);

end function;

begin

dut : writeInterface
  generic map
  (
    FIFOSIZE => FIFOSIZE,
    MAXWIDTH => 4,
    MAXHEIGHT => 3
  )
  port map
  (
    clk 	=> clk,
    clk_en 	=> '1',
    reset 	=> res,
   
    -- kein clock enable, nehme valid

    pixel_address => input_address,
    pixel_color   => input_color,
    valid_data    => pipeline(PIPEMAX - 1),

    stall 	  => stall,
    finished 	  => finished,
    
    master_address  	=> output_address,
    master_colordata	=> output_color,
    master_write    	=> output_write,

    slave_waitreq	=> waitreq
  );

clk <= not clk after 10 ns;

res <= '0' after 25 ns;

--forever : process -- to get finished in wave simulation list
--begin
--wait;
--assert finished = '0' or finished = '1';
--end process;

assert (finished and '0') = '0';

--input <= not input after 10 ns;

sync : process(clk, res) 
begin

if res = '1' then

  input_address <= (others => '0');
  input_color   <= (others => '0');
  input_valid   <= '0';
  pipeline 	<= (others => '0'); 

elsif rising_edge(clk) then

  pipeline(0) <= not stall and rayOrNot(slave_counter, RAYPERIOD, RAYCYCLESACTIVE);
 --(to_std_logic((slave_counter mod RAYPERIOD) = 1));
 -- and (to_std_logic((slave_counter mod RAYPERIOD) = 1) 
 -- or to_std_logic((slave_counter mod RAYPERIOD) = 2) or to_std_logic((slave_counter mod RAYPERIOD) = 3)
 -- or to_std_logic((slave_counter mod RAYPERIOD) = 4));
  pipeline(PIPEMAX - 1 downto 1) <= pipeline(PIPEMAX - 2 downto 0);

  slave_counter <= slave_counter + 1;

  if stall = '0' and pipeline_counter < PIPEMAX then
    pipeline_counter <= pipeline_counter + 1;
  elsif stall = '1' and pipeline_counter > 0 then
    pipeline_counter <= pipeline_counter - 1;
  else 
    pipeline_counter <= pipeline_counter;
  end if;

  if pipeline_counter > 0 then
    counter <= counter + 1;
    input_valid <= '1';
  else
    counter <= counter;
    input_valid <= '0';
  end if;
  
  input_address <= std_logic_vector(to_signed(counter, 32));
  input_color <= std_logic_vector(to_signed(counter, 24));

end if;

end process;

  waitreq <= output_write and (to_std_logic((slave_counter mod 7) = 1) 
  or to_std_logic((slave_counter mod 7) = 2) or to_std_logic((slave_counter mod 7) = 3)
  or to_std_logic((slave_counter mod 7) = 4) or to_std_logic((slave_counter mod 7) = 5))
  after 1 ns;


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





end architecture;