
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.operations_pkg.all;

entity pic_data_test is

end entity;

architecture arch of pic_data_test is

component picture_data port(
	w : in std_logic;
	address : in std_logic_vector(15 downto 0);
	writedata : in std_logic_vector(31 downto 0);
	frames : out frame_array;
	sc : out scene;
	write_poss : out std_logic;
	clk : in std_logic;
	reset : in std_logic;
	clk_en : in std_logic;
	next_frame : in std_logic;
	start : out std_logic;
	valid_data : out std_logic);
end component;

signal clk, write, read, start, write_poss, vd : std_logic := '0';
signal res_n : std_logic := '1';
signal writedata : std_logic_vector(31 downto 0);
signal address : std_logic_vector(15 downto 0);

type signal_array is array (natural range <>) of std_logic_vector(15 downto 0);
type data_signal_array is array (natural range <>) of std_logic_vector(31 downto 0);

signal frames : frame_array;
signal sc : scene;

constant address_array : signal_array(41 downto 0)  := (
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
12=>X"1131", 13=>X"1132", 14=> X"1233", 
15=>X"1041", 16=>X"1042", 17=> X"1043", 18=> X"1050",
--third sphere
19=> X"1210", 20=>X"1220", 
21=>X"1231", 22=>X"1232", 23=> X"1233",
24=>X"1041", 25=>X"1042", 26=> X"1043", 27=> X"1050",
--can I write?
28 => X"0000",
--camera center + addition base
29 => X"3011", 30=>X"3012", 31=>X"3013", 32 => X"3021", 33=>X"3022", 34=>X"3023",
--addition vectors hoizontal + vertical
35 => X"3031", 36=>X"3032", 37=>X"3033", 38 => X"3041", 39=>X"3042", 40=>X"3043",
--finish the frame
41 => X"3050"
);

constant data_array : data_signal_array(41 downto 0)  := (
--general data
0 => X"03070100", 
--first sphere inverse rad, rad2
1=> X"00010000", 2=>X"00010000", 
--first sphere center
3=>X"FFFE0000", 4=>X"00020000", 5=> X"00020000",
--first sphere color, emitting
6=>X"00010000", 7=>X"00004CCC", 8=> X"00004CCC", 9=> X"00000001",
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
35 => X"0000_00A4", 36=>X"00000000", 37=>X"00000000", 38 => X"0000_0089", 39=>X"00000000", 40=>X"00000000",
--finish the frame
41 => X"12345678"
);

signal i : natural;

begin


clk <= not(clk) after 20 ns;
res_n <= '0' after 30 ns;



mm : picture_data port map (clk => clk, reset => res_n,  clk_en => '1',
		address		=> address,
		w 		=> write,
		writedata 	=> writedata,
		next_frame 	=> '0',
		start 		=> start,
		write_poss	=> write_poss,
		frames 		=> frames,
		sc		=> sc,
		valid_data 	=> vd);
		--readdata  	=> readdata,
		
		--framereader master
		-- first step: memmapped read interface for pixel address and color
		--pixel_address   => pixel_address,
		--write     : in  std_logic;
		--pixel_read      => pixel_read,
		--writedata : in  std_logic_vector(31 downto 0);
		--pixel_readdata  => pixel_readdata,

		-- alternative: memmapped write master to sdram

		--master_address   => master_address,
		--write     : in  std_logic;
		--master_write     => master_write,
		--writedata : in  std_logic_vector(31 downto 0);
		--master_colordata => master_colordata,
		--slave_waitreq	 => slave_waitreq);

cpu : process(clk, res_n) is

begin

if res_n = '1'  then
	i <= 0;
	write <= '0';
elsif  rising_edge(clk) then
	if i /= 28 AND i < address_array'high then
		i <= i + 1;
		write <= '1';
	elsif i = 28 AND write_poss = '1' then
		i <= i + 1;
		write <= '1';
	else
		write <= '0';
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