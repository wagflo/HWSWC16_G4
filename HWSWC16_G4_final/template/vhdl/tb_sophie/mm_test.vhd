library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.operations_pkg.all;

library modelsim_lib;

use modelsim_lib.util.all;

entity mm_test is

end entity;

architecture arch of mm_test is

component raytracing_mm is
	generic (
		MAXWIDTH : natural;
		MAXHEIGHT : natural
	);
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

constant MAXWIDTH  : integer := 200;
constant MAXHEIGHT : integer :=  120;


signal clk, write, read, slave_waitreq, master_write, pixel_read, old_reset : std_logic := '0';
signal res_n : std_logic := '1';
signal master_address, master_colordata, writedata, readdata, pixel_readdata : std_logic_vector(31 downto 0);
signal address : std_logic_vector(15 downto 0);
signal pixel_address : std_logic_vector(0 downto 0);

signal position_debug : std_logic_vector(21 downto 0);

type signal_array is array (natural range <>) of std_logic_vector(15 downto 0);
type data_signal_array is array (natural range <>) of std_logic_vector(31 downto 0);

constant stall_array : std_logic_vector(63 downto 0) := x"F_7F_3F_1F_0F_07_03_01_0";

subtype my_bit_array is bit_vector(MAXWIDTH*MAXHEIGHT - 1 downto 0);

signal test_all_sent : my_bit_array := (others => '0');
signal new_address, old_address : std_logic_vector(31 downto 0) := (others => '0'); --std_logic_vector(to_unsigned(MAXWIDTH*MAXHEIGHT*4, 32)); --(others => '0');
signal spy_fr_done : std_logic_vector(1 downto 0);

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
26=>X"00010000", 27=>X"00004CCC", 28=> X"00004CCC", 29=> X"00000000",
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

signal i, j : natural := 18;

begin

spy_process : process
begin
init_signal_spy("/mm/fr_done","/spy_fr_done",1);
wait;
end process spy_process;

--init_signal_spy("/mm/old_position","/position_debug", 1);

--slave_waitreq <= '0';


clk <= not(clk) after 20 ns;
res_n <= '0' after 10 ns;




mm : raytracing_mm 
generic map(

	MAXWIDTH => MAXWIDTH,
	MAXHEIGHT => MAXHEIGHT
)
port map (clk => clk, res_n => res_n, 
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
	i <= 18;
	write <= '0';
	read <= '0';
	j <= 0;
	slave_waitreq <= '0';

elsif  rising_edge(clk) then
	--if j mod 8 = 0 then
	--	slave_waitreq <= '0';
	--else
	--	slave_waitreq <= '1';
	--end if;
	
	if master_write = '1' and slave_waitreq = '0' then 

		test_all_sent(to_integer(unsigned(master_address)) / 4) <= '1';
	end if;

	if spy_fr_done /= "00" then 

		test_all_sent <= (others => '0');
	end if;
	
	--test_all_sent(to_integer(unsigned(master_address)) mod 4) <= '1' when master_write = '1' and slave_waitreq = '0' else '0';

--	if to_integer(unsigned(old_address)) != to_integer(unsigned(master_address)) then

	if old_address /= master_address then
		old_address <= master_address;
	end if;

	slave_waitreq <= stall_array(j mod stall_array'LEFT);

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

--assert test_all_sent = my_bit_array'(others => '0');
assert test_all_sent(MAXWIDTH*MAXHEIGHT - 1) = '0' report "test_all_sent last written"; -- nur letztes

assert unsigned(old_address) <= unsigned(master_address) report "probably reflected ray overtakes, as it should OR SIMPLY NEW PICTURE";

address <= address_array(i);
writedata <= data_array(i);

end architecture;