
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.delay_pkg.all;
use work.operations_pkg.all;
use work.components_pkg.all;

entity raytracing_mm is
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		--memory mapped slave
		address   : in  std_logic_vector(31 downto 0);
		write     : in  std_logic;
		read      : in  std_logic;
		writedata : in  std_logic_vector(31 downto 0);
		readdata  : out std_logic_vector(31 downto 0)
		
		--framereader master
		
	);
end entity;

architecture arch of raytracing_mm is

constant zero : std_logic_vector(31 downto 0) := (others=> '0');
constant zero_vector : vector := (x => zero, y => zero, z => zero);
constant initial_frame : frame_info := (all_info => '0', 
	camera_origin => zero_vector,
	addition_base => zero_vector,
	addition_hor => zero_vector,
	addition_ver => zero_vector,
	frame_no => (OTHERS => '0'));

signal sc : scene;
signal frames : frame_array := (OTHERS => initial_frame);

constant can_write : std_logic_vector(31 downto 0) := X"00000000";
constant finish_frame : std_logic_vector(3 downto 0) := X"F";
constant change_spheres : std_logic_vector(3 downto 0) := X"1";
constant change_general : std_logic_vector(3 downto 0) := X"2";
constant change_frame : std_logic_vector(3 downto 0) := X"3";
constant radius : std_logic_vector(3 downto 0) := X"1";
constant radius2 : std_logic_vector(3 downto 0) := X"2";
constant center : std_logic_vector(3 downto 0) := X"3";
constant x : std_logic_vector(3 downto 0) := X"1";
constant y : std_logic_vector(3 downto 0) := X"2";
constant z : std_logic_vector(3 downto 0) := X"3";
constant camera_origin : std_logic_vector(3 downto 0) := X"1";
constant addition_base : std_logic_vector(3 downto 0) := X"2";
constant addition_hor : std_logic_vector(3 downto 0) := X"3";
constant addition_ver : std_logic_vector(3 downto 0) := X"4";
constant frame_no : std_logic_vector(3 downto 0) := X"5";

signal next_readdata : std_logic_vector(31 downto 0);
signal t, elem, coord, sphere : std_logic_vector(3 downto 0);
signal number_filled : natural := 0;
signal number_filled_v : std_logic_vector(1 downto 0);

signal can_feed, start_rdo, done_rdo : std_logic;

signal result_rdo : vector;
signal position_rdo : std_logic_vector(21 downto 0);

signal start_sphere, valid, done : std_logic;

signal i : std_logic_vector(3 downto 0);

signal distance : std_logic_vector(31 downto 0);
begin

next_readdata(31 downto 1) <= (OTHERS => '0');
next_readdata(0) <= frames(0).all_info AND frames(1).all_info;
number_filled_v <= (1 => frames(0).all_info AND frames(1).all_info, 0 => frames(0).all_info XOR frames(1).all_info);

syn : process(res_n, clk) is begin
	if res_n = '1' then 
		frames <= (OTHERS => initial_frame);
		readdata <= (OTHERS => '0');
		number_filled <= 0;
	elsif rising_edge(clk) then
		readdata <= next_readdata;
		number_filled <= natural(to_integer(unsigned(number_filled_v)));
	end if;
end process;

t <= address(31 downto 28);
sphere <= address(11 downto 8);
elem <= address(7 downto 4);
coord <= address(3 downto 0);

rdo : getRayDirOpt port map (
    clk => clk,
    clk_en => can_feed,
    reset => res_n,
    start => start_rdo,

    frame => frames(0).frame_no,

    num_samples_i => sc.num_samples_i(2 downto 0),

    num_samples_j => sc.num_samples_j(2 downto 0),

    addition_hor => frames(0).addition_hor,

    addition_ver => frames(0).addition_ver,

    addition_base => frames(0).addition_ver,
    
    result	=> result_rdo,

    position	=> position_rdo,
    done	=> done_rdo);

gcs : closestSphere port map (
	clk => clk,
	reset => res_n,
	clk_en => '1',
	start => start_sphere,
	origin => X"000000000000000000000000",
	dir => X"000000000001000000000000",
	center_1 => X"000000000005000000000000",
	radius2_1 => X"00040000",
	center_2 => X"000000000005000000000000",
	radius2_2 => X"00040000",
	radius2_3 => X"00040000",
	center_3 => X"000000000005000000000000",
	radius2_4 => X"00040000",
	center_4 => X"000000000005000000000000",
	radius2_5 => X"00040000",
	center_5 => X"000000000005000000000000",
	radius2_6 => X"00040000",
	center_6 => X"000000000005000000000000",
	radius2_7 => X"00040000",
	center_7 => X"000000000005000000000000",
	radius2_8 => X"00040000",
	center_8 => X"000000000005000000000000",
	radius2_9 => X"00040000",
	center_9 => X"000000000005000000000000",
	radius2_10 => X"00040000",
	center_10 => X"000000000005000000000000",
	radius2_11 => X"00040000",
	center_11 => X"000000000005000000000000",
	radius2_12 => X"00040000",
	center_12 => X"000000000005000000000000",
	radius2_13 => X"00040000",
	center_13 => X"000000000005000000000000",
	radius2_14 => X"00040000",
	center_14 => X"000000000005000000000000",
	radius2_15 => X"00040000",
	center_15 => X"000000000005000000000000",
	radius2_16 => X"00040000",
	center_16 => X"000000000005000000000000",
	second_round => '0',
	spheres => "0000000000000001",
	t => distance,
	i_out => i,
	done => done,
	valid_t => valid
);

writeproc : process(t, elem, coord, write, writedata) is begin
if write = '1' then
--write
	if t = finish_frame then
		--finish_frame
		frames(number_filled).all_info <= '1';
	elsif t = change_spheres then
		--change a param of a sphere
		if elem = radius then
			sc.spheres(to_integer(unsigned(sphere))).radius <= writedata;
		elsif elem = radius2 then
			sc.spheres(to_integer(unsigned(sphere))).radius2 <= writedata;
		elsif elem = center then
			if coord = x then
				sc.spheres(to_integer(unsigned(sphere))).center.x <= writedata;
			elsif coord = y then
				sc.spheres(to_integer(unsigned(sphere))).center.y <= writedata;
			elsif coord = z then
				sc.spheres(to_integer(unsigned(sphere))).center.z <= writedata;
			end if;
		end if;
	elsif t = change_general then
		--change the gerneral parameters
		sc.num_spheres <= writedata(31 downto 24);
		sc.num_reflects <= writedata(23 downto 16);
		sc.num_samples_i <= writedata(15 downto 8);
		sc.num_samples_j <= writedata(7 downto 0);
	elsif t = change_frame then
		--set a param in the camera position
		if elem = camera_origin then
			if coord = x then
				frames(number_filled).camera_origin.x <= writedata;
			elsif coord = y then
				frames(number_filled).camera_origin.y <= writedata;
			elsif coord = z then
				frames(number_filled).camera_origin.z <= writedata;
			end if;
		elsif elem = addition_base then
			if coord = x then
				frames(number_filled).addition_base.x <= writedata;
			elsif coord = y then
				frames(number_filled).addition_base.y <= writedata;
			elsif coord = z then
				frames(number_filled).addition_base.z <= writedata;
			end if;
		elsif elem = addition_hor then
			if coord = x then
				frames(number_filled).addition_hor.x <= writedata;
			elsif coord = y then
				frames(number_filled).addition_hor.y <= writedata;
			elsif coord = z then
				frames(number_filled).addition_hor.z <= writedata;
			end if;
		elsif elem = addition_ver then
			if coord = x then
				frames(number_filled).addition_ver.x <= writedata;
			elsif coord = y then
				frames(number_filled).addition_ver.y <= writedata;
			elsif coord = z then
				frames(number_filled).addition_ver.z <= writedata;
			end if;
		elsif elem = frame_no then
			frames(number_filled).frame_no <= writedata(1 downto 0);
		end if;
	end if;
end if;
end process;

end architecture;


