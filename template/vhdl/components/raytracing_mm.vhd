
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.delay_pkg.all;
use work.operations_pkg.all;
use work.components_pkg.all;
use work.lpm_util.all;

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
constant one48 : std_logic_vector(47 downto 0) := (32 => '1', OTHERS => '0');

signal next_readdata : std_logic_vector(31 downto 0);
signal t, elem, coord, sphere : std_logic_vector(3 downto 0);
signal number_filled : natural := 0;
signal number_filled_v : std_logic_vector(1 downto 0);
signal t_times_a : std_logic_vector(31 downto 0);
signal one_over_a : std_logic_vector(47 downto 0);
signal mult_input : std_logic_vector(31 downto 0);

signal can_feed, start_rdo, start_rdo_next, done_rdo, copyRay_rdo : std_logic;

signal outputRay_rdo,reflected_ray, rightRay : ray;
signal position_rdo : std_logic_vector(21 downto 0);

signal sph_demux : std_logic_vector(15 downto 0) := "0000000000011111";

signal start_sphere, valid, done : std_logic;

signal toggle, stall, valid_t, write_poss : std_logic := '0';

signal i : std_logic_vector(3 downto 0);

signal distance, a : std_logic_vector(31 downto 0);

signal gcsInputRay : std_logic_vector(193 downto 0);

signal gcsInput : scInput;

signal closestSphere : std_logic_vector(3 downto 0);

signal subwire_t : std_logic_vector(63 downto 0);

begin

next_readdata <= (OTHERS=>NOT(write_poss));
number_filled_v <= (1 => frames(0).all_info AND frames(1).all_info, 0 => frames(0).all_info XOR frames(1).all_info);
gcsInput <= to_scInput(sc);

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

    outputRay 	=> outputRay_rdo,
    done	=> done_rdo);

rightRay <= outputRay_rdo when stall = '0' else reflected_ray;

csp : closestSpherePrep port map(
	clk => clk, reset => res_n, clk_en=> can_feed,
	input_direction => rightRay.direction,
	a => a
);

delay_dir_gcs : delay_element generic map (DEPTH => 4, WIDTH => 194)
port map (clk => clk, reset => res_n, clken => '1', source(193 downto 98) => to_std_logic(rightRay.direction),
source(97 downto 2) => to_std_logic(rightRay.origin), source(1) => rightRay.copy, source(0) => rightRay.valid, dest => gcsInputRay);

gcs : closestSphereNew port map (
	clk => clk,
	reset => res_n,
	clk_en => '1',
	dir => tovector(gcsInputRay(193 downto 98)),
	origin	=> tovector(gcsInputRay(97 downto 2)),
	a => a,
	copy => gcsInputRay(1),
	valid => gcsInputRay(0),
	relevantScene => gcsInput,
	t_times_a => t_times_a,
	valid_t	 => valid_t,
	closestSphere	=> closestSphere
);

static_data : picture_data port map (
	w => write,
	address => address,
	writedata => writedata,
	frames => frames,
	sc => sc,
	write_poss => write_poss,
	clk => clk,
	reset => res_n,
	clk_en => '1'
);

next_raydir : process(done_rdo, frames) is begin
if done_rdo = '1' then
	frames_next(0) <= frames(1);
	frames_next(1) <= initial_frame;
else 
	start_rdo_next <= '0';
end if;
end process;

div_a : lpm_divide generic map (lpm_drepresentation => "SIGNED",
		lpm_hint => "ONE_INPUT_IS_ CONSTANT = YES",
		lpm_nrepresentation => "SIGNED",
		lpm_pipeline => 48,
		lpm_type => "lpm_divide",
		lpm_widthd => 32,
		lpm_widthn => 48)
port map(aclr => res_n, clken => '1', clock => clk, denom => a, numer => one48, quotient => one_over_a, remain => open);

delay_t_min_a : delay_element generic map (WIDTH => 32, DEPTH => 25) 
port map (clk => clk, clken => '1', reset => res_n, source => t_times_a, dest => mult_input)
;
mult : lpm_mult
	GENERIC MAP (
		lpm_hint => "UNUSED",
		lpm_pipeline => 2,
		lpm_representation => "SIGNED",
		lpm_type => "lpm_mult",
		lpm_widtha => 32,
		lpm_widthb => 32,
		lpm_widthp => 64
	)
	PORT MAP (
			aclr => res_n,
			clken	=> '1',
			clock	=> clk,
			dataa	=> mult_input(31 downto 0),
			datab	=> one_over_a(31 downto 0),
			result	=> subwire_t
	);

end architecture;


