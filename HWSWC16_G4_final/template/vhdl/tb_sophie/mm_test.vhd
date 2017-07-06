library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sim_bmppack.all;
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

-- bitmap debugging: mit GIMP BILD mit MAXWIDTH mal MAXHEIGHT Pixeln erstellen, export as ..., Windows BMP, 
-- dann 24 bits und "do not write color space information" anklicken, damit headerfile passt

constant MAXWIDTH  : integer := 200; -- fuer bitmap debug muss 3*MAXWIDTH modulo 4 = 0 sein!
constant MAXHEIGHT : integer := 120;


signal clk, write, read, slave_waitreq, master_write, pixel_read, old_reset : std_logic := '0';
signal res_n : std_logic := '1';
signal master_address, master_colordata, writedata, readdata, pixel_readdata : std_logic_vector(31 downto 0);
signal address : std_logic_vector(15 downto 0);
signal pixel_address : std_logic_vector(0 downto 0);

signal position_debug : std_logic_vector(21 downto 0);

type signal_array is array (natural range <>) of std_logic_vector(15 downto 0);
type data_signal_array is array (natural range <>) of std_logic_vector(31 downto 0);

constant stall_array : std_logic_vector(63 downto 0) := x"F_7F_3F_1F_0F_07_03_01_0";--x"0_00_00_00_00_00_00_00_0"; --x"F_7F_7F_7F_7F_7F_7F_7F_7"; --x"F_7F_3F_1F_0F_07_03_01_0";

subtype my_bit_array is bit_vector(MAXWIDTH*MAXHEIGHT - 1 downto 0);
--subtype bitzeile is bit_vector(MAXWIDTH - 1 downto 0);
type my_bit_array2 is array (0 to MAXHEIGHT - 1) of bit_vector(MAXWIDTH - 1 downto 0);

type bildtyp is array (0 to MAXWIDTH*MAXHEIGHT - 1) of std_logic_vector(23 downto 0);
type zeilentyp is array(0 to MAXWIDTH - 1) of std_logic_vector(23 downto 0);
type bildtyp2 is array (0 to MAXHEIGHT - 1) of zeilentyp;

type bildzahltyp is array (0 to MAXWIDTH*MAXHEIGHT - 1) of Integer;

signal test_all_sent, test_2nd_sent, test_bitmap, test_backendInput : my_bit_array := (others => '0');
signal test_all_sent2, test_2nd_sent2, test_bitmap2  : my_bit_array2 := (others => (others => '0'));
signal new_address, old_address : std_logic_vector(31 downto 0) := (others => '0'); --std_logic_vector(to_unsigned(MAXWIDTH*MAXHEIGHT*4, 32)); --(others => '0');
signal spy_fr_done : std_logic_vector(1 downto 0);
signal spy_rightRay : ray;
signal spy_backendray : ray;

--signal dummy_color : std_logic_vector(23 downto 0) := x"000000";
signal red 	: std_logic_vector(23 downto 0) := x"0000FF";
signal green 	: std_logic_vector(23 downto 0) := x"00FF00";
signal blue 	: std_logic_vector(23 downto 0) := x"FF0000";
signal bild : bildtyp := (others => x"000000");
signal bild2 : bildtyp2 := (others => (others => x"000000"));
signal firstNonWhite : bildtyp := (others => x"FFFFFF");
signal lastBackendInput : bildtyp := (others => x"FFFFFF");

signal minNumRefl : bildzahltyp := (others => 9);
signal orderDrawn : bildzahltyp := (others => 0);
signal counterDrawn : Integer := 0;
signal howoftenRightRay : bildzahltyp := (others => 0);

type reflColorLookuptype is array(0 to 9) of std_logic_vector(23 downto 0);
constant reflColorLU : reflColorLookuptype := (x"0000FF", x"00FF00", x"FF0000", x"0000FF", x"00FF00", x"FF0000", x"0000FF", 
					       x"00FF00", x"0000FF", x"000000");

--signal dummy_thresh : std_logic_vector(31 downto 0) := x"00017500";

signal bildnummer : integer := 0;

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
49 => X"00000000", 50=>X"00000000", 51=>X"00000000", 52 => X"FFFF0000", 53=>X"00015000", 54=>X"00010000",
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

--ReadFile("/homes/a0426419/Documents/fitting.bmp"); -- Groesse muss wohl passen von, Bild muss da sein, fuer Header Info
			
	--	for i in 0 to MAXWIDTH - 1 loop
	--		for j in 0 to MAXHEIGHT - 1 loop
	--			if test_bitmap(j*MAXWIDTH + i) = '1' then
	--				SetPixel (i, j, dummy_color);
	--			end if;
	--		end loop;
	--	end loop;

--SetPixel (10, 10, red);
--SetPixel (10, 11, green);
--SetPixel (11, 10, blue);
--SetPixel (11, 11, red);

--WriteFile("/homes/a0426419/Documents/result.bmp");


init_signal_spy("/mm/fr_done", "/spy_fr_done", 1);
init_signal_spy("/mm/rightRay", "/spy_rightRay", 1);
init_signal_spy("/mm/backend_ray", "/spy_backendray", 1);

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
variable dummy_color : std_logic_vector(23 downto 0) := x"000000";

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
	
	--if(unsigned(master_address) <= unsigned(dummy_thresh)) then -- ??? warum dummy noch checken!!!!!!! 
	if spy_rightRay.valid = '1' then

		if minNumRefl(to_integer(unsigned(spy_rightRay.position))) >= to_integer(unsigned(spy_rightRay.remaining_reflects)) then
			minNumRefl(to_integer(unsigned(spy_rightRay.position))) <= to_integer(unsigned(spy_rightRay.remaining_reflects)); 			
		else 
			minNumRefl(to_integer(unsigned(spy_rightRay.position))) <= minNumRefl(to_integer(unsigned(spy_rightRay.position)));
		end if;
		
		--assert minNumRefl(to_integer(unsigned(spy_rightRay.position))) >= to_integer(unsigned(spy_rightRay.remaining_reflects));
		--report "New rightRay with more or equal number of remaing refl";
		howoftenRightRay(to_integer(unsigned(spy_rightRay.position))) <= howoftenRightRay(to_integer(unsigned(spy_rightRay.position))) + 1;

		--if firstNonWhite(to_integer(unsigned(spy_rightRay.position))) = x"010000" then

			firstNonWhite(to_integer(unsigned(spy_rightRay.position))) <= spy_rightRay.color.x(15 downto 8) & 
				spy_rightRay.color.y(15 downto 8) & spy_rightRay.color.z(15 downto 8 ); --& '1' letzte 1 zur Sicherheit, damit nicht mehr 010000
				
			--spy_rightRay.color.y(23 downto 0);

		--end if;

	
	end if;

	if spy_backendray.valid = '1' then

		lastBackendInput(to_integer(unsigned(spy_backendray.position))) <= spy_backendray.color.x(16 downto 9) & 
				spy_backendray.color.y(16 downto 9) & spy_backendray.color.z(16 downto 9 );-- hier noch backend spy machen
				-- besser 16 bis 9 als 15 bis 8 damit 10000 von weiss noch drauf
		test_backendInput(to_integer(unsigned(spy_backendray.position))) <= '1';
	end if;

	if master_write = '1' and slave_waitreq = '0' and to_integer(unsigned(master_address(31 downto 2))) < MAXWIDTH*MAXHEIGHT then 

		test_all_sent(to_integer(unsigned(master_address(31 downto 2)))) <= '1';
		test_all_sent2(to_integer(unsigned(master_address(31 downto 2))) / (MAXWIDTH))((to_integer(unsigned(master_address(31 downto 2))) mod (MAXWIDTH)) ) <= '1';

		if test_all_sent(to_integer(unsigned(master_address(31 downto 2)))) = '1' then

			test_2nd_sent(to_integer(unsigned(master_address(31 downto 2))) ) <= '1';
			test_2nd_sent2(to_integer(unsigned(master_address(31 downto 2))) / (MAXWIDTH))((to_integer(unsigned(master_address(31 downto 2))) mod (MAXWIDTH)) ) <= '1';
	
		end if;

		if master_colordata /= x"0000_0000" then
			test_bitmap(to_integer(unsigned(master_address)) / 4) <= '1';
			test_bitmap2(to_integer(unsigned(master_address)) / (4*MAXWIDTH))((to_integer(unsigned(master_address)) mod (4*MAXWIDTH)) / 4) <= '1';
		else 
			test_bitmap(to_integer(unsigned(master_address)) / 4) <= '0';
			test_bitmap2(to_integer(unsigned(master_address)) / (4*MAXWIDTH))((to_integer(unsigned(master_address)) mod (4*MAXWIDTH)) / 4) <= '0';
		end if;

		bild(to_integer(unsigned(master_address)) / 4) <= master_colordata(23 downto 0);
		bild2(to_integer(unsigned(master_address)) / (4*MAXWIDTH))((to_integer(unsigned(master_address)) mod (4*MAXWIDTH)) / 4) <= master_colordata(23 downto 0);

		orderDrawn(to_integer(unsigned(master_address)) / 4) <= counterDrawn;
		
		--if counterDrawn < 255 then
		--	counterDrawn <= counterDrawn + 1;
		--elsif counterDrawn < 65535 then
		--	counterDrawn <= counterDrawn + 256;
		--elsif counterDrawn < 16777215 then
		--	counterDrawn <= counterDrawn + 65536;
		if counterDrawn < 16777215 then
			counterDrawn <= counterDrawn + 65536 + 256 + 1;
		else 
			counterDrawn <= 0;
		end if;

		--bild2(to_integer(unsigned(master_address)) / (4*MAXWIDTH))((to_integer(unsigned(master_address)) mod / (4*MAXWIDTH)) / 4) <= master_colordata(23 downto 0);
	end if;

	if spy_fr_done /= "00" then 

		ReadFile("/homes/a0426419/Documents/fitting.bmp"); -- Groesse muss wohl passen von, Bild muss da sein, fuer Header Info
			
		for my_i in 0 to MAXWIDTH - 1 loop
			for my_j in 0 to MAXHEIGHT - 1 loop
				if test_bitmap(my_j*MAXWIDTH + my_i) = '1' then
					dummy_color := bild(my_j*MAXWIDTH + my_i);
					SetPixel (my_i, my_j, dummy_color);
				end if;
			end loop;
		end loop;

		WriteFile("/homes/a0426419/Documents/result" & integer'image(bildnummer) & ".bmp");

		test_all_sent <= (others => '0');
		test_2nd_sent <= (others => '0');
		test_bitmap <= (others => '0');
		test_backendInput <= (others => '0');
		bild <= (others => x"000000");

		test_all_sent2 <= (others => (others => '0'));
		test_2nd_sent2 <= (others => (others => '0'));
		test_bitmap2 <= (others => (others => '0'));
		bild2 <= (others => (others => x"000000"));

		ReadFile("/homes/a0426419/Documents/fitting.bmp"); -- Groesse muss wohl passen von, Bild muss da sein, fuer Header Info
			
		for i in 0 to MAXWIDTH - 1 loop
			for j in 0 to MAXHEIGHT - 1 loop
				--if test_bitmap(j*MAXWIDTH + i) = '1' then
					dummy_color := reflColorLU(minNumRefl(j*MAXWIDTH + i));
					SetPixel (i, j, dummy_color);
				--end if;
			end loop;
		end loop;

		WriteFile("/homes/a0426419/Documents/min_rem_refl" & integer'image(bildnummer) & ".bmp");

		minNumRefl <= (others => 9);
	
		ReadFile("/homes/a0426419/Documents/fitting.bmp"); -- Groesse muss wohl passen von, Bild muss da sein, fuer Header Info
			
		for i in 0 to MAXWIDTH - 1 loop
			for j in 0 to MAXHEIGHT - 1 loop
				--if test_bitmap(j*MAXWIDTH + i) = '1' then
					dummy_color := std_logic_vector(to_unsigned(orderDrawn(j*MAXWIDTH + i) mod 256, 24));
					SetPixel (i, j, dummy_color);
				--end if;
			end loop;
		end loop;

		WriteFile("/homes/a0426419/Documents/orderDrawn" & integer'image(bildnummer) & ".bmp");

		orderDrawn <= (others => 0);

		
		ReadFile("/homes/a0426419/Documents/fitting.bmp"); -- Groesse muss wohl passen von, Bild muss da sein, fuer Header Info
			
		for i in 0 to MAXWIDTH - 1 loop
			for j in 0 to MAXHEIGHT - 1 loop
				--if test_bitmap(j*MAXWIDTH + i) = '1' then
					dummy_color := reflColorLU(howoftenRightRay(j*MAXWIDTH + i));
					SetPixel (i, j, dummy_color);
				--end if;
			end loop;
		end loop;

		WriteFile("/homes/a0426419/Documents/howoftenRightRay" & integer'image(bildnummer) & ".bmp");
		howoftenRightRay <= (others => 0);

		ReadFile("/homes/a0426419/Documents/fitting.bmp"); -- Groesse muss wohl passen von, Bild muss da sein, fuer Header Info
			
		for i in 0 to MAXWIDTH - 1 loop
			for j in 0 to MAXHEIGHT - 1 loop
				--if test_bitmap(j*MAXWIDTH + i) = '1' then
					dummy_color := firstNonWhite(j*MAXWIDTH + i);
					SetPixel (i, j, dummy_color);
				--end if;
			end loop;
		end loop;

		WriteFile("/homes/a0426419/Documents/firstNonWhite" & integer'image(bildnummer) & ".bmp");
		firstNonWhite <= (others => x"FFFFFF");

	ReadFile("/homes/a0426419/Documents/fitting.bmp"); -- Groesse muss wohl passen von, Bild muss da sein, fuer Header Info
			
		for i in 0 to MAXWIDTH - 1 loop
			for j in 0 to MAXHEIGHT - 1 loop
				--if test_bitmap(j*MAXWIDTH + i) = '1' then
					dummy_color := lastBackendInput(j*MAXWIDTH + i);
					SetPixel (i, j, dummy_color);
				--end if;
			end loop;
		end loop;

		WriteFile("/homes/a0426419/Documents/lastBackendInput" & integer'image(bildnummer) & ".bmp");
		firstNonWhite <= (others => x"FFFFFF");


		bildnummer <= bildnummer + 1;
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
assert test_all_sent(MAXWIDTH*MAXHEIGHT - 1) = '0' report "test_all_sent last written"; -- nur letztes, fuer Anzeige in Sim
assert test_2nd_sent(MAXWIDTH*MAXHEIGHT - 1) = '0' report "test_all_sent last written"; -- nur letztes, fuer Anzeige in Sim
assert test_bitmap(MAXWIDTH*MAXHEIGHT - 1) = '0' report "test_bitmap last written"; -- fuer Anzeige in Sim
assert test_backendInput(MAXWIDTH*MAXHEIGHT - 1) = '0' report "test_bitmap last written"; -- fuer Anzeige in Sim
assert bild(MAXHEIGHT*MAXWIDTH - 1) = x"000000" report "test_bitmap last written"; -- fuer Anzeige in Sim
assert lastBackendInput(MAXHEIGHT*MAXWIDTH - 1) = x"000000" report "test_bitmap last written"; -- fuer Anzeige in Sim
assert firstNonWhite(MAXHEIGHT*MAXWIDTH - 1) = x"000000" report "test_bitmap last written"; -- fuer Anzeige in Sim
assert minNumRefl(MAXHEIGHT*MAXWIDTH - 1) = 0 report "test_bitmap last written"; -- fuer Anzeige in Sim
assert howoftenRightRay(MAXHEIGHT*MAXWIDTH - 1) = 0 report "test_bitmap last written"; -- fuer Anzeige in Sim

assert test_all_sent2(MAXHEIGHT - 1)(MAXWIDTH - 1) = '0' report "test_all_sent last written"; -- nur letztes, fuer Anzeige in Sim
assert test_2nd_sent2(MAXHEIGHT - 1)(MAXWIDTH - 1) = '0' report "test_all_sent last written"; -- nur letztes, fuer Anzeige in Sim
assert test_bitmap2(MAXHEIGHT - 1)(MAXWIDTH - 1) = '0' report "test_bitmap last written"; -- fuer Anzeige in Sim
assert bild2(MAXHEIGHT-1)(MAXWIDTH - 1) = x"000000" report "test_bitmap last written"; -- fuer Anzeige in Sim

--assert unsigned(old_address) <= unsigned(master_address) report "probably reflected ray overtakes, as it should OR SIMPLY NEW PICTURE";

address <= address_array(i);
writedata <= data_array(i);

end architecture;