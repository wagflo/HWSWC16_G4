library ieee;
use ieee.std_logic_1164.all;
--use work.delay_pkg.all;
use work.components_pkg.all;

-- quite possibly misses first output!

entity readInterface is
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
    
    slave_address   : in  std_logic_vector(0 downto 0);
    --write     : in  std_logic;
    --writedata : in  std_logic_vector(31 downto 0);
    slave_data 	    : out std_logic_vector(31 downto 0);
    slave_read      : in  std_logic
    --slave_waitreq    : in std_logic
  );
end entity;

architecture beh of readInterface is

--constant FIFOSIZE : positive := 8; -- 256 => whole m9k block, zum testen 4 

signal data_betw_fifos : std_logic_vector(55 downto 0);
signal req_betw_fifos, req_for_output, first_empty, second_empty, stall_int : std_logic;

signal read_req_back : std_logic;
signal slave_address_int   : std_logic_vector(31 downto 0);
signal slave_colordata_int : std_logic_vector(31 downto 0);

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

  req_betw_fifos <= (not stall_int) and (not first_empty);

  fifoback : alt_fwft_fifo 
    generic map(
      DATA_WIDTH => 56,
      NUM_ELEMENTS => FIFOSIZE 
    )
    port map(
      aclr	=> reset,
      clock	=> clk,
      data	=> data_betw_fifos,
      rdreq	=> read_req_back, --slave_read,
      wrreq	=> req_betw_fifos,
      empty	=> second_empty,
      full	=> stall_int,
      q(55 downto 24) => slave_address_int,
      q(23 downto  0) => slave_colordata_int(23 downto 0)
    );

stall <= stall_int;

--req_for_output <= (not slave_waitreq) and (not second_empty)

slave_colordata_int(31 downto 24) <= (others => '0');

read_req_back <= slave_read and slave_address(0); -- needs to be == 1! == color

choose : process(slave_address, slave_colordata_int, slave_address_int)
begin
if slave_address(0) = '1' then
  slave_data <= slave_colordata_int;
else 
  slave_data <= slave_address_int;
end if;
end process;

end architecture;