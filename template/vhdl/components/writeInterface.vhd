library ieee;
use ieee.std_logic_1164.all;
--use work.delay_pkg.all;
use work.components_pkg.all;



entity writeInterface is
  generic
  (
    FIFOSIZE : positive := 8 -- 256 => whole m9k block, zum testen 4 
  );
  port
  (
    clk 	: in std_logic;
    clk_en 	: in std_logic;
    reset 	: in std_logic;
   
    -- kein clock enable, nehme valid

    pixel_address : in std_logic_vector(31 downto 0);
    pixel_color   : in std_logic_vector(23 downto 0);
    valid_data    : in std_logic;

    stall 	  : out std_logic;
    
    master_address   : out  std_logic_vector(31 downto 0);
    --write     : in  std_logic;
    --writedata : in  std_logic_vector(31 downto 0);
    master_colordata : out std_logic_vector(31 downto 0);
    master_write     : out  std_logic;
    slave_waitreq	 : in std_logic
  );
end entity;

architecture beh of writeInterface is

--constant FIFOSIZE : positive := 8; -- 256 => whole m9k block, zum testen 4 

signal data_betw_fifos : std_logic_vector(55 downto 0);
signal req_betw_fifos, readreq_for_second_fifo, first_empty, second_empty, stall_int : std_logic;
signal slave_waitreq_registered : std_logic;
signal data_delayed_1, address_delayed_1 : std_logic_vector(31 downto 0);
signal data_delayed_2, address_delayed_2 : std_logic_vector(31 downto 0);
signal fifoback_address, fifoback_colordata : std_logic_vector(31 downto 0);

signal second_empty_delayed_1 : std_logic;
signal second_empty_delayed_2 : std_logic;

begin

  fifofront: alt_fwft_fifo 
    generic map(
      DATA_WIDTH => 56,
      NUM_ELEMENTS => FIFOSIZE 
    )
    port map(
      aclr	=> reset,
      clock	=> clk,
      data(55 downto 24) => pixel_address,
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
      DATA_WIDTH => 56,
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
      q(55 downto 24) => fifoback_address,
      q(23 downto  0) => fifoback_colordata(23 downto 0)
    );

stall <= stall_int;

fifoback_colordata(31 downto 24) <= (others => '0');

-- to conform to Avalon-MM timing:

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
elsif rising_edge(clk) then

  slave_waitreq_registered <= slave_waitreq;
  address_delayed_1 <= fifoback_address;
  address_delayed_2 <= address_delayed_1;
  data_delayed_1 <= fifoback_colordata;
  data_delayed_2 <= data_delayed_1;
  second_empty_delayed_1 <= second_empty;
  second_empty_delayed_2 <= second_empty_delayed_1;
end if;
end process;

readreq_for_second_fifo <= (not slave_waitreq) and (not second_empty);
--(not slave_waitreq_registered) and (not second_empty);

--readreq_for_second_fifo <= (not slave_waitreq) and (not second_empty) after 1 ns;

master_write <= not second_empty; --econd_empty_delayed_2;

--master_write <= readreq_for_second_fifo;

master_colordata <= fifoback_colordata;
master_address <= fifoback_address;

end architecture;