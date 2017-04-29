library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.delay_pkg.all;
use work.components_pkg.all;



entity writeInterface is
  generic
  (
    FIFOSIZE : positive := 8; -- 256 => whole m9k block, zum testen 4 
    MAXWIDTH : natural := 800;
    MAXHEIGHT : natural := 480

  );
  port
  (
    clk 	: in std_logic;
    clk_en 	: in std_logic;
    reset 	: in std_logic;
   
    -- kein clock enable, nehme valid

    pixel_address : in std_logic_vector(32 downto 0);
    pixel_color   : in std_logic_vector(23 downto 0);
    valid_data    : in std_logic;

    stall 	  : out std_logic;

    --start_counter : in std_logic;
    finished	  : out std_logic_vector(1 downto 0); -- uses readreq_for_second fifo for counting 
				   -- all pixels of current frame have already passed!

    counter0_debug 	: out std_logic_vector(18 downto 0);
    counter1_debug 	: out std_logic_vector(18 downto 0);
    
    master_address   : out  std_logic_vector(31 downto 0);
    --write     : in  std_logic;
    --writedata : in  std_logic_vector(31 downto 0);
    master_colordata : out std_logic_vector(31 downto 0);
    master_write     : out  std_logic;
    --byteenable : out std_logic_vector(3 downto 0);
    slave_waitreq	 : in std_logic
  );
end entity;

architecture beh of writeInterface is

--constant FIFOSIZE : positive := 8; -- 256 => whole m9k block, zum testen 4 

signal data_betw_fifos : std_logic_vector(56 downto 0);
signal req_betw_fifos, readreq_for_second_fifo, first_empty, second_empty, stall_int : std_logic;
signal slave_waitreq_registered, frame : std_logic;
signal data_delayed_1, address_delayed_1 : std_logic_vector(31 downto 0);
signal data_delayed_2, address_delayed_2 : std_logic_vector(31 downto 0);
signal fifoback_address, fifoback_colordata : std_logic_vector(31 downto 0);

signal second_empty_delayed_1 : std_logic;
signal second_empty_delayed_2 : std_logic;

signal counter0, counter0_next, counter1, counter1_next : integer range 0 to MAXWIDTH*MAXHEIGHT - 1;
--signal counter_next : integer range 0 to MAXWIDTH*MAXHEIGHT - 1;

signal finished_next : std_logic_vector(1 downto 0);

begin

  fifofront: alt_fwft_fifo 
    generic map(
      DATA_WIDTH => 57,
      NUM_ELEMENTS => FIFOSIZE 
    )
    port map(
      aclr	=> reset,
      clock	=> clk,
      data(56 downto 24) => pixel_address,
      data(23 downto 0) => pixel_color,
      rdreq	=> req_betw_fifos,
      wrreq	=> valid_data,
      empty	=> first_empty,
      full	=> open,	-- design needs to guard against first FIFO getting full => stall + big enough
      q => data_betw_fifos
    );

  req_betw_fifos <= (not stall_int) and (not first_empty); -- stall_int == second FIFO full

  fifoback : alt_fwft_fifo 
    generic map(
      DATA_WIDTH => 57,
      NUM_ELEMENTS => FIFOSIZE 
    )
    port map(
      aclr	=> reset,
      clock	=> clk,
      data	=> data_betw_fifos,
      rdreq	=> readreq_for_second_fifo,
      wrreq	=> req_betw_fifos,
      empty	=> second_empty,
      full	=> stall_int,
      q(56)	=> frame,
      q(55 downto 24) => fifoback_address,
      q(23 downto  0) => fifoback_colordata(23 downto 0)
    );

stall <= stall_int;

fifoback_colordata(31 downto 24) <= (others => '0');

-- to conform to Avalon-MM timing:

counter0_debug <= std_logic_vector(to_unsigned(counter0, 19));
counter1_debug <= std_logic_vector(to_unsigned(counter1, 19));

async : process(counter1, counter0, readreq_for_second_fifo, frame)
begin

finished_next <= "00";
if readreq_for_second_fifo = '1' then
  if frame = '0' then
	if counter0 = MAXWIDTH*MAXHEIGHT - 1 then
    		counter0_next <= 0;
    		finished_next(0) <= '1';
	else
		counter0_next <= counter0 + 1;
	end if;
  else
    	if counter1 = MAXWIDTH*MAXHEIGHT - 1 then
    		counter1_next <= 0;
    		finished_next(1) <= '1';
	else
		counter1_next <= counter1 + 1;
	end if;
  end if;
else
  counter0_next <= counter0;
  counter1_next <= counter1;
end if;

end process;


sync : process(clk, reset)
begin
if reset = '1' then

  slave_waitreq_registered <= '0';
  address_delayed_1 <= (others => '0');
  data_delayed_1 <= (others => '0');
  address_delayed_2 <= (others => '0');
  data_delayed_2 <= (others => '0');
  second_empty_delayed_1 <= '0';
  second_empty_delayed_2 <= '0';
  counter0 <= 0;
  counter1 <= 0;
  finished <= "00";
elsif rising_edge(clk) then

  slave_waitreq_registered <= slave_waitreq;
  address_delayed_1 <= fifoback_address;
  address_delayed_2 <= address_delayed_1;
  data_delayed_1 <= fifoback_colordata;
  data_delayed_2 <= data_delayed_1;
  second_empty_delayed_1 <= second_empty;
  second_empty_delayed_2 <= second_empty_delayed_1;
  counter0 <= counter0_next;
  counter1 <= counter1_next;
  finished <= finished_next;
end if;
end process;

readreq_for_second_fifo <= inertial (not slave_waitreq) and (not second_empty) after 2 ns; -- delay against waitreq glitches
--(not slave_waitreq_registered) and (not second_empty);

--readreq_for_second_fifo <= (not slave_waitreq) and (not second_empty) after 1 ns;

master_write <= not second_empty; --econd_empty_delayed_2;

--master_write <= readreq_for_second_fifo;

master_colordata <= fifoback_colordata;
master_address <= fifoback_address(31 downto 0);

--byteenable <= "1111";

end architecture;