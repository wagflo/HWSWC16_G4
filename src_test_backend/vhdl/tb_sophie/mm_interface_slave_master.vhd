library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.operations_pkg.all;
use work.components_pkg.all;
use work.lpm_util.all;
use work.delay_pkg.all;
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
constant set_color_x : std_logic_vector(15 downto 0) := x"0003";
constant set_color_y : std_logic_vector(15 downto 0) := x"0004";
constant set_color_z : std_logic_vector(15 downto 0) := x"0005";

signal start_address : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal current_address : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal next_address : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal pixel_color : std_logic_vector(23 downto 0) := (OTHERS => '0');
signal counter : natural range 0 to max_counter := 0;
signal start : std_logic := '0';
signal done : std_logic := '0';
signal done_keep : std_logic := '0';
signal was_read : std_logic := '0';
signal write_out : std_logic := '0';
signal stall : std_logic := '0';
signal finished : std_logic_vector(1 downto 0) := "00";
signal counter0, counter1 : std_logic_vector(18 downto 0) := (OTHERS => '0');
signal valid_delayed : std_logic := '0';
signal write_poss : std_logic := '0';
signal valid_data : std_logic := '0';
signal done_rdo : std_logic := '0';
signal start_picture : std_logic := '0';
signal start_rdo : std_logic := '0';
signal outputRay_rdo : ray;
signal frames : frame_array;
signal sc : scene;
signal color_vec : vector := (OTHERS => (OTHERS => '0'));
signal backend_ray : ray;
signal position : std_logic_vector(21 downto 0) := (OTHERS => '0');
signal pixel_valid : std_logic;
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
	pixel_color 			=> pixel_color,
	valid_data			=> valid_delayed,

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

static_data : picture_data 
port map (
	clk 		=> clk,
	reset		=> reset,
	clk_en		=> '1',

	w		=> write, 
	address		=> address, 
	writedata	=> writedata,

	frames		=> frames,
	sc		=> sc,
	write_poss	=> write_poss,
	valid_data	=> valid_data,
	
	next_frame	=> done_rdo,
	frames_done	=> finished,

	start		=> start_picture
);

rda : getRayDirAlt 
generic map ( MAXWIDTH => MAXWIDTH, MAXHEIGHT => MAXHEIGHT)
port map (
	clk		=> clk,
	reset		=> reset,

	clk_en		=> '1',
	fifo_full	=> stall,
	start		=> start_picture,
	hold		=> '0',
	valid_data	=> valid_data,

	frame		=> "00", 
	num_samples	=> "00001",
	num_reflects	=> sc.num_reflects(2 downto 0),

	camera_center	=> frames(0).camera_origin,
	addition_hor	=> frames(0).addition_hor,
	addition_ver	=> frames(0).addition_ver,
	addition_base 	=> frames(0).addition_base,

	outputRay	=> outputRay_rdo,
	done		=> done_rdo
);

add : lpm_add_sub
generic map (
lpm_direction 		=> "UNUSED",
lpm_hint 		=> "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
lpm_pipeline 		=> 1,
lpm_representation 	=> "UNSIGNED",
lpm_type 		=> "LPM_ADD_SUB",
lpm_width		=> 32
)
port map (
aclr 			=> reset,
clken			=> '1',
add_sub			=> '1',
clock			=> clk,

dataa			=> start_address,
datab(31 downto 22)	=> (OTHERS => '0'),
datab(21 downto 2)	=> position(19 downto 0),
datab(1 downto 0)	=> (OTHERS => '0'),
result 			=> current_address
);

valid_delay : delay_element
generic map (
	WIDTH => 1,
	DEPTH => 1
)
port map (
	clk => clk,
	clken => '1',
	reset => reset,

	source(0) =>pixel_valid,
	dest(0) => valid_delayed
);

back : backend port map (
    clk => clk, clk_en => '1',  reset => reset,

    num_samples => "00001",

    ray_in => backend_ray,

    color_data => pixel_color,
    valid_data => pixel_valid
  );
  
assign_backend_ray : process(outputRay_rdo, color_vec) is begin
backend_ray <= outputRay_rdo;
backend_ray.color <= color_vec;
end process;

position_delay : delay_element
generic map (
	WIDTH => 22,
	DEPTH => 17
)
port map (
	clk => clk, clken => '1', reset => reset,
	source => outputRay_rdo.position,
	dest => position
);

sync : process(clk, reset) is begin
if reset = '1' then
	--reset
	start_address <= (OTHERS => '0');
	color_vec <= (OTHERS => (OTHERS => '0'));
elsif rising_edge(clk) then
	if write = '1' then
		if address = set_start_address then
			start_address <= writedata;
		--write the colordata
		elsif address = set_color_x then
			color_vec.x <= writedata;
		elsif address = set_color_y then
			color_vec.y <= writedata;
		elsif address = set_color_z then
			color_vec.z <= writedata;
		end if;
	end if;
end if;



end process;

async_read : process(read, address) is begin
if read = '1' and address(15 downto 8) = x"FF" then
	if address(0) = '1' then
		readdata <= (OTHERS=>sc.pic_done(1));
	else
		readdata <= (OTHERS=>sc.pic_done(0));
	end if;
elsif read = '1' and address = x"0000" then
	readdata <= (OTHERS => write_poss);
elsif read = '1' and address = x"0001" then
	readdata <= (OTHERS => stall);
elsif read = '1' and address = x"0002" then
	readdata <= outputRay_rdo.valid & "0" & x"00" &  outputRay_rdo.position;
elsif read = '1' and address = x"0003" then
	readdata <= x"000" & "0" & counter0;
elsif read = '1' and address = x"0004" then
	readdata <= x"000" & "0" & counter1;
else
	readdata <= (OTHERS => '0');
end if;
end process;

end architecture;
