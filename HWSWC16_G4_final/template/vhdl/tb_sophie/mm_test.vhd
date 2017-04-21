library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.operations_pkg.all;

entity mm_test is

end entity;

architecture arch of mm_test is

component raytracing_mm is
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		--memory mapped slave
		address   : in  std_logic_vector(15 downto 0);
		write     : in  std_logic;
		read      : in  std_logic;
		writedata : in  std_logic_vector(31 downto 0);
		readdata  : out std_logic_vector(31 downto 0);
		
		--framereader master
		-- first step: memmapped read interface for pixel address and color
		pixel_address   : in  std_logic_vector(0 downto 0);
		--write     : in  std_logic;
		pixel_read      : in  std_logic;
		--writedata : in  std_logic_vector(31 downto 0);
		pixel_readdata  : out std_logic_vector(31 downto 0);

		-- alternative: memmapped write master to sdram

		master_address   : out  std_logic_vector(31 downto 0);
		--write     : in  std_logic;
		master_write     : out  std_logic;
		--writedata : in  std_logic_vector(31 downto 0);
		master_colordata : out std_logic_vector(31 downto 0);
		slave_waitreq	 : in std_logic
		
	);
end component;

signal clk, write, read, slave_waitreq, master_write, pixel_read, old_reset : std_logic := '0';
signal res_n : std_logic := '1';
signal master_address, master_colordata, writedata, readdata, pixel_readdata : std_logic_vector(31 downto 0);
signal address : std_logic_vector(15 downto 0);
signal pixel_address : std_logic_vector(0 downto 0);

type signal_array is array (natural range <>) of std_logic_vector(15 downto 0);
type data_signal_array is array (natural range <>) of std_logic_vector(31 downto 0);


constant address_array : signal_array(42 downto 0)  := (
--general data
0 => X"2000", 
--first sphere inverse rad, rad2
1=> X"1010", 2=>X"1020", 
--first sphere center
3=>X"1031", 4=>X"1032", 5=> X"1033",
--first sphere color, emitting
6=>X"1041", 7=>X"1042", 8=> X"1043", 9=> X"1050",
--second sphere
10=> X"1110", 11=>X"1120", 
12=>X"1131", 13=>X"1132", 14=> X"1133", 
15=>X"1141", 16=>X"1142", 17=> X"1143", 18=> X"1150",
--third sphere
19=> X"1210", 20=>X"1220", 
21=>X"1231", 22=>X"1232", 23=> X"1233",
24=>X"1241", 25=>X"1242", 26=> X"1243", 27=> X"1250",
--can I write?
28 => X"0000",
--camera center + addition base
29 => X"3011", 30=>X"3012", 31=>X"3013", 32 => X"3021", 33=>X"3022", 34=>X"3023",
--addition vectors hoizontal + vertical
35 => X"3031", 36=>X"3032", 37=>X"3033", 38 => X"3041", 39=>X"3042", 40=>X"3043",
--finish the frame
41 => X"3050", 42 => X"F000"
);

constant data_array : data_signal_array(42 downto 0)  := (
--general data
0 => X"27010007", 
--first sphere inverse rad, rad2
1=> X"00010000", 2=>X"00010000", 
--first sphere center
3=>X"FFFD0000", 4=>X"00030000", 5=> X"00030000",
--first sphere color, emitting
6=>X"00010000", 7=>X"00004CCC", 8=> X"00004CCC", 9=> X"00000000",
--second sphere
10=> X"00010000", 11=>X"00010000", 
12=>X"00020000", 13=>X"FFFE0000", 14=> X"FFFE0000", 
15=>X"00004CCC", 16=>X"00010000", 17=> X"00004CCC", 18=> X"00000001",
--third sphere -- copy of second
19=> X"00010000", 20=>X"00010000", 
21=>X"00020000", 22=>X"FFFE0000", 23=> X"FFFE0000",
24=>X"00004CCC", 25=>X"00004CCC", 26=> X"00010000", 27=> X"00000001",
--can I write?
28 => X"00000000",
--camera center + addition base
29 => X"00000000", 30=>X"00000000", 31=>X"00000000", 32 => X"FFFF0000", 33=>X"00010000", 34=>X"00010000",
--addition vectors hoizontal + vertical
35 => X"0000_0089", 36=>X"00000000", 37=>X"00000000", 38 => X"00000000", 39=>X"0000_00A4", 40=>X"00000000",
--finish the frame
41 => X"00000000", 42 => X"00000000"
);

signal i, j : natural;

begin


clk <= not(clk) after 20 ns;
res_n <= '0' after 10 ns;



mm : raytracing_mm port map (clk => clk, res_n => res_n, 
		address		=> address,
		write 		=> write,
		read		=> read,
		writedata 	=> writedata,
		readdata  	=> readdata,
		
		--framereader master
		-- first step: memmapped read interface for pixel address and color
		pixel_address   => pixel_address,
		--write     : in  std_logic;
		pixel_read      => pixel_read,
		--writedata : in  std_logic_vector(31 downto 0);
		pixel_readdata  => pixel_readdata,

		-- alternative: memmapped write master to sdram

		master_address   => master_address,
		--write     : in  std_logic;
		master_write     => master_write,
		--writedata : in  std_logic_vector(31 downto 0);
		master_colordata => master_colordata,
		slave_waitreq	 => slave_waitreq);

cpu : process(clk, res_n) is

begin

if res_n = '1'  then
	i <= 0;
	write <= '0';
	j <= 0;
elsif  rising_edge(clk) then
	write <= '0';
	j <= j + 1;
	if i /= 28 AND i < address_array'high then
		write <= '1';
		if  j > 1 then
			i <= i + 1;
		end if;
	elsif i = 28 AND readdata /= X"00000000" then
		if  j > 1 then
			i <= i + 1;
		end if;
		write <= '1';
	end if;

end if;
--for i in 1 to address_array'high loop

  --address <= address_array(i);
  --write <= '1';	
  --writedata <= data_array(i);
  --wait for 20 ns;
--end loop;

--wait;

end process;


address <= address_array(i);
writedata <= data_array(i);
end architecture;