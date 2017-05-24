library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.operations_pkg.all;

entity mmPlusBackendTest is

end entity;

architecture arch of mmPlusBackendTest is

component mm_test_interface is
	generic (
		MAXWIDTH : natural;
		MAXHEIGHT : natural
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

--
--constant address_array : signal_array(131 downto 26) := (
--	
--	093 => X"2000",
--	094 => X"4010",
--	095 => X"4020",
--
--	096 => X"1141",
--	097 => X"1142",
--	098 => X"1143",
--	099 => X"1150",
--
--	100 => X"1141",
--	101 => X"1142",
--	102 => X"1143",
--	103 => X"1150",
--
--	104 => X"1241",
--	105 => X"1242",
--	106 => X"1243",
--	107 => X"1250",
--
--	108 => x"6000",
--	109 => x"3050",
--	110 => x"FFFF",
--	111 => x"FF00", --FF00
--
--	112 => x"6000",
--	113 => x"3050",
--	114 => x"FFFF",
--	115 => x"FF01", --FF01
--
--	116 => x"6000",
--	117 => x"3050",
--	118 => x"FFFF",
--	119 => x"FF00",
--
--	120 => x"6000",
--	121 => x"3050",
--	122 => x"FFFF",
--	123 => x"FF01",
--
--	124 => x"6000",
--	125 => x"3050",
--	126 => x"FFFF",
--	127 => x"FF00",
--
--	128 => x"6000",
--	129 => x"3050",
--	130 => x"FFFF",
--	131 => x"FF01",
--
--	others => x"0000" 
--);
--
--constant data_array : data_signal_array(131 downto 26) := (
--	093 => X"2704_0007",
--	094 => X"00A0_0000",
--	095 => X"00C0_0000",
--
--	096 => X"0001_0000",
--	097 => X"0000_0000",
--	098 => X"0000_0000",
--	099 => X"0000_0001",
--
--	100 => X"0000_0000",
--	101 => X"0001_0000",
--	102 => X"0000_0000",
--	103 => X"0000_0001",
--
--	104 => X"0000_0000",
--	105 => X"0000_0000",
--	106 => X"0001_0000",
--	107 => X"0000_0001",
--
--	108 => x"0000_0001", -- hit sphere #
--	109 => x"0000_0000", -- frame#
--	110 => x"0000_0123", -- start, daten egal
--	111 => x"0000_0000", -- read loop: kann schreiben?
--
--	112 => x"0000_0002",
--	113 => x"0000_0001",
--	114 => x"0000_0123",
--	115 => x"0000_0000",
--
--	116 => x"0000_0003",
--	117 => x"0000_0000",
--	118 => x"0000_0123",
--	119 => x"0000_0000",
--
--	120 => x"0000_0001",
--	121 => x"0000_0001",
--	122 => x"0000_0123",
--	123 => x"0000_0000",
--
--	124 => x"0000_0002",
--	125 => x"0000_0000",
--	126 => x"0000_0123",
--	127 => x"0000_0000",
-- 
--	128 => x"0000_0003",
--	129 => x"0000_0001",
--	130 => x"0000_0123",
--	131 => x"0000_0000",
--
--	others => x"0000_0000" 
--
--);



constant address_array : signal_array(63 downto 18)  := (
--general data
20 => X"2000", 
--first sphere inverse rad, rad2
21=> X"1010", 22=>X"1020", 
--first sphere center
23=>X"1031", 24=>X"1032", 25=> X"1033",
--first sphere color, emitting
26=>X"1041", 27=>X"1042", 28=> X"1043", 29=> X"1050",
--second sphere
30=> X"1110", 31=>X"1120", 
32=>X"1131", 33=>X"1132", 34=> X"1133", 
35=>X"1141", 36=>X"1142", 37=> X"1143", 38=> X"1150",
--third sphere
39=> X"1210", 40=>X"1220", 
41=>X"1231", 42=>X"1232", 43=> X"1233",
44=>X"1241", 45=>X"1242", 46=> X"1243", 47=> X"1250",
--can I write?
48 => X"0000",
--camera center + addition base
49 => X"3011", 50=>X"3012", 51=>X"3013", 52 => X"3021", 53=>X"3022", 54=>X"3023",
--addition vectors hoizontal + vertical
55 => X"3031", 56=>X"3032", 57=>X"3033", 58 => X"3041", 59=>X"3042", 60=>X"3043",
--finish the frame
61 => X"3050", 62 => X"F000",
63 => X"FF00",
-- base addresses

18 => X"4010", 19 => X"4020"
);

constant data_array : data_signal_array(63 downto 18)  := (
--general data
20 => X"27010007", 
--first sphere inverse rad, rad2
21=> X"00010000", 22=>X"00010000", 
--first sphere center
23=>X"FFFD0000", 24=>X"00030000", 25=> X"00030000",
--first sphere color, emitting
26=>X"00010000", 27=>X"00004CCC", 28=> X"00004CCC", 29=> X"00000001",
--second sphere
30=> X"00010000", 31=>X"00010000", 
32=>X"00020000", 33=>X"FFFE0000", 34=> X"FFFE0000", 
35=>X"00004CCC", 36=>X"00010000", 37=> X"00004CCC", 38=> X"00000001",
--third sphere -- copy of second
39=> X"00010000", 40=>X"00010000", 
41=>X"00030000", 42=>X"FFFD0000", 43=> X"FFFD0000", --MK
--41=>X"FFFF0000", 42=>X"00010000", 43=> X"00010000",
44=>X"00004CCC", 45=>X"00004CCC", 46=> X"00010000", 47=> X"00000001",
--can I write?
48 => X"00000000",
--camera center + addition base
49 => X"00000000", 50=>X"00000000", 51=>X"00000000", 52 => X"FFFF0000", 53=>X"00010000", 54=>X"00010000",
--addition vectors hoizontal + vertical
55 => X"0000_0089", 56=>X"00000000", 57=>X"00000000", 58 => X"00000000", 59=>X"0000_00A4", 60=>X"00000000",
--finish the frame
61 => X"00000000", 62 => X"00000000",
63 => X"00000000",
-- base addresses
18 => X"00000000", 19 => X"00400000"
);

signal i, j : natural := 26;

begin

slave_waitreq <= '0';


clk <= not(clk) after 20 ns;
res_n <= '0' after 10 ns;




mm : mm_test_interface 
generic map(

	MAXWIDTH => 400,
	MAXHEIGHT => 20
)
port map (clk => clk, reset => res_n, 
		address		=> address,
		write 		=> write,
		read		=> read,
		writedata 	=> writedata,
		readdata  	=> readdata,
		
		
		-- alternative: memmapped write master to sdram

		master_address   => master_address,
		--write     : in  std_logic;
		master_write     => master_write,
		--writedata : in  std_logic_vector(31 downto 0);
		master_colordata => master_colordata,
		slave_waitreq	 => slave_waitreq);

--cpu : process(clk, res_n) is
--
--begin
--
--if res_n = '1'  then
--	i <= 93;
--	write <= '1';
--	read <= '0';
--	j <= 0;
--elsif  rising_edge(clk) then
--	write <= '0';
--	read <= '0';
--	j <= j + 1;
--	if i = 131 then
--		if readdata = x"FFFFFFFF" then
--			i <= 108;
--			write <= '1';
--		else
--			read <= '1';
--		end if;
--	elsif i >= 110 and (i - 110) mod 4 = 0 then
--		i <= i + 1;
--		read <= '1';
--	elsif i >= 111 and (i - 111) mod 4 = 0 then
--		if readdata = x"FFFFFFFF" then
--			i <= i + 1;
--			write <= '1';
--		else
--			read <= '1';
--		end if;
--	else
--		i <= i + 1;
--		write <= '1';
--	end if;
--
--end if;
----for i in 1 to address_array'high loop
--
--  --address <= address_array(i);
--  --write <= '1';	
--  --writedata <= data_array(i);
--  --wait for 20 ns;
----end loop;
--
----wait;
--
--end process;
--

cpu : process(clk, res_n) is

begin

if res_n = '1'  then
	i <= 18;
	write <= '0';
	read <= '0';
	j <= 0;
elsif  rising_edge(clk) then
	write <= '0';
	read <= '0';
	j <= j + 1;
	
	if i = 47 then
		read <= '1';
		if  j > 1 then
			i <= i + 1;
		end if;
	elsif i = 48 then
		if readdata /= X"00000000" then
			if  j > 1 then
				i <= i + 1;
			end if;
			write <= '1';
		else read <= '1';
			i <= i;
		end if;
	elsif i = 62 then
		read <= '1';
		if  j > 1 then
			i <= i + 1;
		end if;
	elsif i >= address_array'high then
		if readdata /= X"00000000" then
			i <= 49;
			write <= '1';
		else
			read <= '1';
			i <= i;
		end if;
	elsif i < address_array'high then
		write <= '1';
		if  j > 1 then
			i <= i + 1;
		end if;
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