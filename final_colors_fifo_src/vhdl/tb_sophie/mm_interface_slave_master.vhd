library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.components_pkg.all;

entity mm_test_interface is
	generic (
    		MAXWIDTH : natural := 800;
    		MAXHEIGHT : natural := 480
	);
	port (
		clk   : in std_logic;
		reset : in std_logic;
		
		--memory mapped slave
		address   : in  std_logic_vector(15 downto 0);
		write     : in  std_logic;
		read      : in  std_logic;
		writedata : in  std_logic_vector(31 downto 0);
		readdata  : out std_logic_vector(31 downto 0);

		master_address   : out  std_logic_vector(31 downto 0);
		--write     : in  std_logic;
		master_write     : out  std_logic;
		--writedata : in  std_logic_vector(31 downto 0);
		master_colordata : out std_logic_vector(31 downto 0);
    		byteenable 		: out std_logic_vector(3 downto 0);
		slave_waitreq	 : in std_logic
		
	);
end entity;

architecture arch of mm_test_interface is

constant max_counter : natural := 480*800 - 1;
constant set_color : std_logic_vector(15 downto 0) := x"0001";
constant set_start_address : std_logic_vector(15 downto 0) := x"0002";
constant start_writing : std_logic_vector(15 downto 0) := x"0000";
signal start_address : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal current_address : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal next_address : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal color : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal counter : natural range 0 to max_counter := 0;
signal start : std_logic := '0';
signal done : std_logic := '0';
signal was_read : std_logic := '0';
signal write_out : std_logic := '0';
signal stall : std_logic := '0';
signal finished : std_logic_vector(1 downto 0) := "00";
signal counter0, counter1 : std_logic_vector(18 downto 0) := (OTHERS => '0');
signal done_keep : std_logic := '0';
begin 

writeIF : writeInterface
generic map (
	FIFOSIZE 	=> 1024,
	MAXWIDTH	=> MAXWIDTH,
	MAXHEIGHT	=> MAXHEIGHT
)
port map (
	clk 		=> clk,
	clk_en		=> '1',
	reset		=> reset,

	pixel_address(32) 		=> '0',
	pixel_address(31 downto 0) 	=> current_address,
	pixel_color 			=> color(23 downto 0),
	valid_data			=> write_out,

	stall 		=> stall,
	finished 	=> finished,

	counter0_debug	=> counter0,
	counter1_debug	=> counter1,

	master_address		=> master_address,
	master_colordata 	=> master_colordata,
	master_write 		=> master_write,
	byteenable 		=> byteenable,
	slave_waitreq 		=> slave_waitreq
);

sync : process(clk, reset) is begin
if reset = '1' then
	--reset
	start_address <= (OTHERS => '0');
	color <= (OTHERS => '0');
	counter <= 0;
	start <= '0';
	done <= '0';
	done_keep <= '0';
	current_address <= (OTHERS => '0');
	write_out <= '0';
elsif rising_edge(clk) then
	done_keep <= done_keep OR finished(0);
	write_out <= '0';
	if write = '1' then
		--writing means starting a new frame
		done <= '0';
		start <= '0';
		counter <= 0;
		--write the base address
		if address = set_start_address then
			start_address <= writedata;
		--write the colordata
		elsif address = set_color then
			color <= writedata;
		--start witing to the sdram
		elsif address = start_writing then
			start <= '1';
			current_address <= start_address;
			write_out <= '1';
		end if;
	elsif start = '1' AND was_read = '1' then
		if counter < max_counter then
		--let's count up
			current_address <= next_address;
			write_out <= '1';
			counter <= counter + 1;
			write_out <= '1';
		else
			--the last pixel was already read
			counter <= 0;
			start <= '0';
			write_out <= '0';
		end if;
	elsif (done_keep OR finished(0)) = '1' then
		done <= '1';
		done_keep <= '0';
	end if;
end if;

end process;

--master_colordata <= color;
--byteenable <= (OTHERS => write_out);
--master_write <= write_out;
--master_address <= current_address;
next_address <= std_logic_vector(unsigned(current_address) + x"00000004");
was_read <= not(stall);

async_read : process(read, address) is begin
if read = '1' AND address = x"0000" then
	readdata <= (OTHERS => done);
elsif read = '1' AND address = x"0001" then
	readdata <= x"000" & "0" & counter0;
elsif read = '1' AND address = x"0002" then
	readdata <= x"000" & "0" & counter1;
else
	readdata <= (OTHERS => '0');
end if;
end process;

end architecture;
