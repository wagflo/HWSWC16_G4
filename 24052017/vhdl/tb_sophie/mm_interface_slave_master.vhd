library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

use work.operations_pkg.all;
use work.components_pkg.all;
use work.delay_pkg.all;
use work.rayDelay_pkg.all;

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

COMPONENT lpm_add_sub
	GENERIC (
		lpm_direction		: STRING;
		lpm_hint		: STRING;
		lpm_pipeline		: NATURAL;
		lpm_representation	: STRING;
		lpm_type		: STRING;
		lpm_width		: NATURAL
	);
	PORT (
			aclr 		: IN STD_LOGIC;
			clken		: IN STD_LOGIC;
			add_sub	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			dataa	: IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (lpm_width-1 DOWNTO 0)
	);
	END COMPONENT;

constant max_counter : natural := MAXWIDTH*MAXHEIGHT - 1;
constant hit_sphere_address : std_logic_vector(15 downto 0) := x"6000";

signal start_address : std_logic_vector(31 downto 0);-- := (OTHERS => '0');
signal current_address : std_logic_vector(31 downto 0);-- := (OTHERS => '0');
signal next_address : std_logic_vector(31 downto 0);-- := (OTHERS => '0');
signal pixel_color : std_logic_vector(23 downto 0);-- := (OTHERS => '0');
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
signal backend_ray, delayed_Ray, rightRay : ray;
signal position : std_logic_vector(21 downto 0) := (OTHERS => '0');
signal pixel_valid : std_logic;
signal current_sphere, colUp_inputSphere : std_logic_vector(3 downto 0) := (OTHERS => '0');
signal scene_colors : vectorArray;
signal delayed_frame : std_logic_vector(0 downto 0);
signal a, t_times_a : std_logic_vector(31 downto 0) := (OTHERS => '0');
signal gcs_inputDirection, gcs_inputOrigin, colUp_inputColor : std_logic_vector(95 downto 0) := (OTHERS => '0');
signal gcs_inputCopy , gcs_inputValid, valid_t, colUp_inputValid, colUp_inputValidT : std_logic := '0';
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

	pixel_address(32) 		=> delayed_frame(0),
	pixel_address(31 downto 0) 	=> current_address,
	pixel_color 			=> pixel_color,
	valid_data			=> pixel_valid,

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

scene_colors <= (
0 => sc.spheres(0).colour,
1 => sc.spheres(1).colour,
2 => sc.spheres(2).colour,
3 => sc.spheres(3).colour,
4 => sc.spheres(4).colour,
5 => sc.spheres(5).colour,
6 => sc.spheres(6).colour,
7 => sc.spheres(7).colour,
8 => sc.spheres(8).colour,
9 => sc.spheres(9).colour,
10 => sc.spheres(10).colour,
11 => sc.spheres(11).colour,
12 => sc.spheres(12).colour,
13 => sc.spheres(13).colour,
14 => sc.spheres(14).colour,
15 => sc.spheres(15).colour
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

	frame		=> frames(0).frame_no, 
	num_samples	=> sc.num_samples(4 downto 0),
	num_reflects	=> sc.num_reflects(2 downto 0),

	camera_center	=> frames(0).camera_origin,
	addition_hor	=> frames(0).addition_hor,
	addition_ver	=> frames(0).addition_ver,
	addition_base 	=> frames(0).addition_base,

	outputRay	=> outputRay_rdo,
	done		=> done_rdo
);
--change here to allow eflection
rightRay <= outputRay_rdo;

csp_c1t4 : closestSpherePrep port map(
	clk => clk, reset => reset, clk_en=> '1',
	input_direction => rightRay.direction,
	a => a
);
--direction + origin + copy + valid for getClosesSphere
csp_par : delay_element generic map (width => 194, depth => 4)
port map (
clk => clk, reset => reset, clken=> '1',
source (193 downto 98) => to_std_logic(rightRay.direction),
source (97 downto 2) => to_std_logic(rightRay.origin),
source(1) => rightRay.copy,
source(0) => rightRay.valid,
dest (193 downto 98) => gcs_inputDirection,
dest (97 downto 2) => gcs_inputOrigin,
dest(1) => gcs_inputCopy,
dest(0) => gcs_inputValid
);



gcs : closestSphereNew 
port map (
	clk => clk, reset => reset, clk_en => '1',
	dir => tovector(gcs_inputDirection), origin => tovector(gcs_inputOrigin),
	a => a,
	copy => gcs_inputCopy, valid => gcs_inputValid,
	relevantScene => to_scInput(sc),
	t_times_a => t_times_a,
	valid_t => valid_t,
	closestSphere => current_sphere
);

-- MK
start_address_async : process(position(21 downto 20), sc.address1, sc.address2) is begin
if position(21 downto 20) = "00" OR position(21 downto 20) = "10" then
	start_address <= sc.address1; --std_logic_vector(to_unsigned(to_integer(unsigned(sc.address1))-- +to_integer(unsigned(pixel_byte_address)) ,32));
elsif position(21 downto 20) = "01" OR position(21 downto 20) = "11" then 
	start_address <= sc.address2; -- std_logic_vector(to_unsigned(to_integer(unsigned(sc.address2))-- +to_integer(unsigned(pixel_byte_address)) ,32));
else
	start_address <= sc.address1; --std_logic_vector(to_unsigned(to_integer(unsigned(sc.address1))-- +to_integer(unsigned(pixel_byte_address)) ,32));
end if;
end process;

add : LPM_ADD_SUB
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

frame_delay : delay_element
generic map (WIDTH => 1, DEPTH => 1)
port map (
clk => clk, reset => reset, clken => '1',
source => position(20 downto 20),
dest => delayed_frame
);

ray_delay : rayDelay
generic map (DELAY_LENGTH => 69)
port map(clk => clk, reset => reset, clk_en => '1',
inputRay => outputRay_rdo, outputRay => delayed_Ray);

backend_ray.sob <= delayed_Ray.sob;
backend_ray.eob <= delayed_Ray.eob;
backend_ray.copy <= delayed_Ray.copy;
backend_ray.pseudo_refl <= delayed_Ray.pseudo_refl;

back : backend port map (
    clk => clk, clk_en => '1',  reset => reset,

    num_samples => sc.num_samples(4 downto 0),

    ray_in => backend_ray,

    color_data => pixel_color,
    valid_data => pixel_valid
  );

position_delay : delay_element
generic map (
	WIDTH => 22,
	DEPTH => 17
)
port map (
	clk => clk, clken => '1', reset => reset,
	source => delayed_Ray.position,
	dest => position
);

delayRayForColUp : delay_element
generic map (depth => 67, width => 97)
port map (clk => clk, clken => '1', reset => reset,
source(96) => rightRay.valid,
source(95 downto 0) => to_std_logic(rightRay.color),
dest (96) => colUp_inputValid,
dest (95 downto 0) => colUp_inputColor);

delaySphereForColUp : delay_element
generic map (depth => 30, width =>5)
port map (clk => clk, clken => '1', reset => reset,
source(4) => valid_t,
source(3 downto 0) => current_sphere,
dest(4) => colUp_inputValidT,
dest(3 downto 0) => colUp_inputSphere
);

colUp : colorUpdate port map (
    clk => clk,
    clk_en => '1',
    reset => reset,


    color_in => tovector(colUp_inputColor),
    valid_t  => colUp_inputValidT,
    sphere_i => colUp_inputSphere,

    valid_ray_in => colUp_inputValid,
    --copy_ray_in : std_logic;

    -- Kugeldaten: Farbe, ws nicht emitting

    color_array => scene_colors,
    
    color_out => backend_ray.color,
    valid_color => open,
    valid_ray_out => backend_ray.valid
    --copy_ray_out : out std_logic
);

sync : process(clk, reset) is begin
if reset = '1' then
	--reset
	--current_sphere <= (OTHERS => '0');
elsif rising_edge(clk) then
	if write = '1' then
--		if address = hit_sphere_address then
--			current_sphere <= writedata(3 downto 0);
--		end if;
	end if;
end if;



end process;

async_read : process(read, address, write_poss, sc, outputRay_rdo) is begin
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
