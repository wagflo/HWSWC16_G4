library ieee;
use ieee.std_logic_1164.all;
--use work.delay_pkg.all;
use work.components_pkg.all;



entity writeInterface is
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

constant FIFOSIZE : positive := 8; -- 256 => whole m9k block, zum testen 4 

signal data_betw_fifos : std_logic_vector(55 downto 0);
signal req_betw_fifos, req_for_output, first_empty, second_empty, stall_int : std_logic;

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
      full	=> open,
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
      rdreq	=> req_for_output,
      wrreq	=> req_betw_fifos,
      empty	=> second_empty,
      full	=> stall_int,
      q(55 downto 24) => master_address,
      q(23 downto  0) => master_colordata(23 downto 0)
    );

stall <= stall_int;

req_for_output <= (not slave_waitreq) and (not second_empty);

master_colordata(31 downto 24) <= (others => '0');

end architecture;