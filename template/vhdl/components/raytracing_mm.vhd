
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
		address   : in  std_logic_vector(15 downto 0);
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

signal sc, sc_next : scene;
signal frames, frames_next : frame_array := (OTHERS => initial_frame);

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

signal can_feed, start_rdo, start_rdo_next, done_rdo, copyRay_rdo : std_logic;

signal result_rdo : vector;
signal position_rdo : std_logic_vector(21 downto 0);

signal sph_demux : std_logic_vector(15 downto 0) := "0000000000011111";

signal start_sphere, valid, done : std_logic;

signal toggle, stall : std_logic := '0';

signal i : std_logic_vector(3 downto 0);

signal distance : std_logic_vector(31 downto 0);
begin

--next_readdata(31 downto 1) <= (OTHERS => '0');
--next_readdata(0) <= frames(0).all_info AND frames(1).all_info;
next_readdata <= frames(0).camera_origin.x xor frames(1).camera_origin.x;
number_filled_v <= (1 => frames(0).all_info AND frames(1).all_info, 0 => frames(0).all_info XOR frames(1).all_info);


syn : process(res_n, clk) is begin
	if res_n = '1' then 
		frames <= (OTHERS => initial_frame);
		readdata <= (OTHERS => '0');
		number_filled <= 0;
		toggle <= '0';
	elsif rising_edge(clk) then
		readdata <= next_readdata;
		number_filled <= natural(to_integer(unsigned(number_filled_v)));
		frames <= frames_next;
		start_rdo <= start_rdo_next;
                if can_feed = '1' then
			toggle <= not(toggle);
		end if;
	end if;
end process;

can_feed <= frames(0).all_info AND NOT(stall);

rdo : getRayDirAlt port map (
    clk => clk,
    clk_en => can_feed,
    reset => res_n,
    start => start_rdo,
    hold => toggle,

    frame => frames(0).frame_no,

    num_samples => sc.num_samples(4 downto 0),

    addition_hor => frames(0).addition_hor,

    addition_ver => frames(0).addition_ver,

    addition_base => frames(0).addition_ver,
    
    result	=> result_rdo,

    position	=> position_rdo,
    done	=> done_rdo,
    copyRay	=> copyRay_rdo);

gcs : closestSphere port map (
	clk => clk,
	reset => res_n,
	clk_en => '1',
	copy_cycle_active => copyRay_rdo,
	start => start_sphere,
	origin => to_std_logic(frames(0).camera_origin),
	dir => to_std_logic(result_rdo),
	center_1 => to_std_logic(sc.spheres(0).center),
	radius2_1 => sc.spheres(0).radius2,
	center_2 => to_std_logic(sc.spheres(1).center),
	radius2_2 => sc.spheres(1).radius2,
	radius2_3 => sc.spheres(2).radius2,
	center_3 => to_std_logic(sc.spheres(2).center),
	radius2_4 => sc.spheres(3).radius2,
	center_4 => to_std_logic(sc.spheres(3).center),
	radius2_5 => sc.spheres(4).radius2,
	center_5 => to_std_logic(sc.spheres(4).center),
	radius2_6 => sc.spheres(5).radius2,
	center_6 => to_std_logic(sc.spheres(5).center),
	radius2_7 => sc.spheres(6).radius2,
	center_7 => to_std_logic(sc.spheres(6).center),
	radius2_8 => sc.spheres(7).radius2,
	center_8 => to_std_logic(sc.spheres(7).center),
	radius2_9 => sc.spheres(8).radius2,
	center_9 => to_std_logic(sc.spheres(8).center),
	radius2_10 => sc.spheres(9).radius2,
	center_10 => to_std_logic(sc.spheres(9).center),
	radius2_11 => sc.spheres(10).radius2,
	center_11 => to_std_logic(sc.spheres(10).center),
	radius2_12 => sc.spheres(11).radius2,
	center_12 => to_std_logic(sc.spheres(11).center),
	radius2_13 => sc.spheres(12).radius2,
	center_13 => to_std_logic(sc.spheres(12).center),
	radius2_14 => sc.spheres(13).radius2,
	center_14 => to_std_logic(sc.spheres(13).center),
	radius2_15 => sc.spheres(14).radius2,
	center_15 => to_std_logic(sc.spheres(14).center),
	radius2_16 => sc.spheres(15).radius2,
	center_16 => to_std_logic(sc.spheres(15).center),
	second_round => sc.num_spheres(3),
	spheres => sph_demux,
	t => distance,
	i_out => i,
	done => done,
	valid_t => valid
);



next_raydir : process(done_rdo, frames) is begin
if done_rdo = '1' then
	frames_next(0) <= frames(1);
	frames_next(1) <= initial_frame;
else 
	start_rdo_next <= '0';
end if;
end process;

end architecture;


