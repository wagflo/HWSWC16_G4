library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
begin 

sync : process(clk, reset) is begin
if reset = '1' then
	--reset
	start_address <= (OTHERS => '0');
	color <= (OTHERS => '0');
	counter <= 0;
	start <= '0';
	done <= '0';
	current_address <= (OTHERS => '0');
	write_out <= '0';
elsif rising_edge(clk) then
	if write = '1' then
		--writing means starting a new frame
		done <= '0';
		start <= '0';
		counter <= 0;
		write_out <= '0';
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
		else
			--the last pixel was already read
			counter <= 0;
			start <= '0';
			write_out <= '0';
			done <= '1';
		end if;
	end if;
end if;

end process;

master_colordata <= color;
byteenable <= (OTHERS => write_out);
master_write <= write_out;
master_address <= current_address;
next_address <= std_logic_vector(unsigned(current_address) + x"00000004");
was_read <= not(slave_waitreq) AND write_out;

async_read : process(read, address) is begin
if read = '1' then
	readdata <= (OTHERS => done);
else
	readdata <= (OTHERS => '0');
end if;
end process;

end architecture;
