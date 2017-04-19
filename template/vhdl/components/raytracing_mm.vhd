
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.delay_pkg.all;
use work.rayDelay_pkg.all;
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
constant base_address1 : std_logic_vector(31 downto 0) := (x"00000000");
constant base_address2 : std_logic_vector(31 downto 0) := (x"00000000");

signal next_readdata : std_logic_vector(31 downto 0);
signal t, elem, coord, sphere : std_logic_vector(3 downto 0);
signal number_filled : natural := 0;
signal number_filled_v : std_logic_vector(1 downto 0);
signal t_times_a : std_logic_vector(31 downto 0);
signal one_over_a : std_logic_vector(47 downto 0);
signal mult_input : std_logic_vector(31 downto 0);
signal ref_dir, ref_origin, colUp_color_in : std_logic_vector(95 downto 0);

signal can_feed, start_rdo, start_rdo_next, done_rdo, copyRay_rdo,
anyref_ray_endOfBundle, anyref_ray_startOfBundle, anyref_ray_valid, 
anyref_ray_pseudo_refl, gcsp_emmiting, anyref_csp_emitting, anyref_csp_valid_t,
anyrefo_isRef, anyrefo_pseudo, anyrefo_valid_ray, anyrefo_sob, anyrefo_eob,
anyref_valid_t, ref_valid_t, ref_valid, ref_copy, ref_out_valid, ref_out_copy, fifo_full,
colUp_valid_t, colUp_valid_t_in, colUp_valid, updatedColorRayValid, updatedColorValid, colUp_pseudo,
backend_valid, backend_sob, backend_eob, backend_copy, back_out_valid
 : std_logic;

signal anyref_ray_rem_ref, rem_reflects_old : std_logic_vector(2 downto 0);

signal outputRay_rdo,reflected_ray, rightRay, delayed_reflected_ray, backend_ray : ray;
signal position_rdo, old_position, backend_position, back_out_address : std_logic_vector(21 downto 0);

signal sph_demux : std_logic_vector(15 downto 0) := "0000000000011111";

signal start_sphere, valid, done : std_logic;

signal toggle, stall, valid_t, write_poss : std_logic := '0';

signal i, ref_sphere_i, colUp_sphere : std_logic_vector(3 downto 0);

signal distance, a : std_logic_vector(31 downto 0);

signal gcsInputRay : std_logic_vector(193 downto 0);

signal gcsInput : scInput;

signal one_over_rs : scalarArray;

signal centers, colUp_colors : vectorArray;

signal closestSphere : std_logic_vector(3 downto 0);

signal subwire_t : std_logic_vector(63 downto 0);

signal ref_out_origin, ref_out_dir, updatedColor, backend_color : vector;

signal old_color : std_logic_vector(95 downto 0);

signal back_out_color : std_logic_vector(23 downto 0);

signal pixel_address_writeIF : std_logic_vector(31 downto 0);

begin

next_readdata <= (OTHERS=>NOT(write_poss));
number_filled_v <= (1 => frames(0).all_info AND frames(1).all_info, 0 => frames(0).all_info XOR frames(1).all_info);
gcsInput <= to_scInput(sc);

syn : process(res_n, clk) is begin
	if res_n = '1' then 
		--frames <= (OTHERS => initial_frame);
		--readdata <= (OTHERS => '0');
		--number_filled <= 0;
		toggle <= '0'; 
		start_rdo <= '0';
		-- start-rdo auch angeben
	elsif rising_edge(clk) then
		--readdata <= next_readdata;
		--number_filled <= natural(to_integer(unsigned(number_filled_v)));
		--frames <= frames_next;
		start_rdo <= start_rdo_next;
                if can_feed = '1' then
			toggle <= not(toggle); -- ws besser auch else Zweig angeben
		--else 
		--  toggle <= toggle;
		end if;
	end if;
end process;

can_feed <= frames(0).all_info AND NOT(stall);
stall <= reflected_ray.valid OR fifo_full;

rdo : getRayDirAlt port map (
    clk => clk,
    clk_en => can_feed,
    reset => res_n,
    start => start_rdo,
    hold => toggle,

    frame => frames(0).frame_no,

    num_samples => sc.num_samples(4 downto 0), --MK

    num_reflects  => sc.num_reflects(2 downto 0),  --MK

    camera_center => frames(0).camera_origin,  --MK

    addition_hor => frames(0).addition_hor,

    addition_ver => frames(0).addition_ver,

    addition_base => frames(0).addition_ver,

    outputRay 	=> outputRay_rdo,
    done	=> done_rdo);

rightRay <= outputRay_rdo when stall = '0' else delayed_reflected_ray;

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

assign_gcsp_emmiting : process(closestSphere) is begin
case closestSphere is
	when "0000" =>
		gcsp_emmiting <= sc.spheres(0).emitting;
	when "0001" =>
		gcsp_emmiting <= sc.spheres(1).emitting;
	when "0010" =>
		gcsp_emmiting <= sc.spheres(2).emitting;
	when "0011" =>
		gcsp_emmiting <= sc.spheres(3).emitting;
	when "0100" =>
		gcsp_emmiting <= sc.spheres(4).emitting;
	when "0101" =>
		gcsp_emmiting <= sc.spheres(5).emitting;
	when "0110" =>
		gcsp_emmiting <= sc.spheres(6).emitting;
	when "0111" =>
		gcsp_emmiting <= sc.spheres(7).emitting;
	when "1000" =>
		gcsp_emmiting <= sc.spheres(8).emitting;
	when "1001" =>
		gcsp_emmiting <= sc.spheres(9).emitting;
	when "1010" =>
		gcsp_emmiting <= sc.spheres(10).emitting;
	when "1011" =>
		gcsp_emmiting <= sc.spheres(11).emitting;
	when "1100" =>
		gcsp_emmiting <= sc.spheres(12).emitting;
	when "1101" =>
		gcsp_emmiting <= sc.spheres(13).emitting;
	when "1110" =>
		gcsp_emmiting <= sc.spheres(14).emitting;
	when "1111" =>
		gcsp_emmiting <= sc.spheres(15).emitting;
	when others => 
		gcsp_emmiting <= sc.spheres(0).emitting;
end case;
end process;

static_data : picture_data port map (
	w => write,
	address => address,
	writedata => writedata,
	frames => frames,
	sc => sc,
	write_poss => write_poss,
	clk => clk,
	reset => res_n,
	clk_en => '1',
	next_frame => done_rdo,
	start => start_rdo
);


div_a : lpm_divide 
generic map 
(lpm_drepresentation => "SIGNED",
		lpm_hint => "ONE_INPUT_IS_CONSTANT = YES",
		lpm_nrepresentation => "SIGNED",
		lpm_pipeline => 48,
		lpm_type => "lpm_divide",
		lpm_widthd => 32,
		lpm_widthn => 48)
port map(
aclr => res_n, clken => '1', clock => clk, 
denom => a, numer => one48, quotient => one_over_a, remain => open);

delay_t_min_a : delay_element generic map (WIDTH => 32, DEPTH => 23) 
port map (clk => clk, clken => '1', reset => res_n, source => t_times_a, dest => mult_input)
;
mult : scalarMul --lpm_mult
	--GENERIC MAP (
	--	lpm_hint => "UNUSED",
	--	lpm_pipeline => 2,
	--	lpm_representation => "SIGNED",
	--	lpm_type => "lpm_mult",
	--	lpm_widtha => 32,
	--	lpm_widthb => 32,
	--	lpm_widthp => 64
	--)
	--PORT MAP (
	--		aclr => res_n,
	--		clken	=> '1',
	--		clock	=> clk,
	--		dataa	=> mult_input(31 downto 0),
	--		datab	=> one_over_a(31 downto 0),
	--		result	=> subwire_t
	--);
	PORT map(
	a => mult_input(31 downto 0),
	b => one_over_a(31 downto 0),
	result => subwire_t,

	clk => clk, clk_en => '1', reset => res_n
);

anyref_rayDelay : delay_element generic map(DEPTH => 36, WIDTH => 7)
port map (clk => clk, reset => res_n, clken => '1', source(6) => rightRay.eob, source(5) => rightRay.sob, source(4) => rightRay.valid,
source(3) => rightRay.pseudo_refl, source(2 downto 0) => rightRay.remaining_reflects,
dest(6) => anyref_ray_endOfBundle, dest(5) => anyref_ray_startOfBundle, dest(4) => anyref_ray_valid,
dest(3) => anyref_ray_pseudo_refl, dest(2 downto 0) => anyref_ray_rem_ref);

anyref_cspDelay : delay_element generic map (DEPTH =>7, WIDTH => 2)
port map (clk => clk, reset => res_n, clken => '1', source(1) => gcsp_emmiting, source(0) => valid_t, dest(1) => anyref_csp_emitting, dest(0) => anyref_csp_valid_t);

anyref_valid_t <= NOT(anyref_ray_pseudo_refl) AND anyref_csp_valid_t;

anyref : anyRefl port map (clk => clk,
    clk_en => '1',
    reset => res_n,
   
    -- kein clock enable, nehme valid

    num_samples => sc.num_samples(4 downto 0),
    endOfBundle => anyref_ray_endOfBundle,
    startOfBundle => anyref_ray_startOfBundle,

    valid_ray_in => anyref_ray_valid,
    remaining_reflects => anyref_ray_rem_ref,
    emitting_sphere => anyref_csp_emitting,

    valid_t => anyref_valid_t,
    
    isReflected => anyrefo_isRef,
    pseudoReflect => anyrefo_pseudo,
    valid_ray_out  => anyrefo_valid_ray,

    startOfBundle_out => anyrefo_sob,
    endOfBundle_out => anyrefo_eob);

ref_ray_delay : delay_element generic map (WIDTH => 194, DEPTH => 54)
port map (clk => clk, clken => '1', reset => res_n, 
source(193) => rightRay.valid, source(192) => rightRay.copy, source(191 DOWNTO 96) => to_std_logic(rightRay.direction), source(95 downto 0) => to_std_logic(rightRay.origin),
dest(193) => ref_valid, dest(192) => ref_copy, dest(191 downto 96) => ref_dir, dest(95 downto 0) => ref_origin);

ref_gcs_delay : delay_element generic map (WIDTH => 5, DEPTH => 25) port map(
clk => clk, clken => '1', reset => res_n, source(4) => valid_t, source(3 downto 0) => closestSphere, dest(4) => ref_valid_t, dest(3 downto 0) => ref_sphere_i);

one_over_rs <= (0 => toscalar(sc.spheres(0).radius), 
1 => toscalar(sc.spheres(1).radius),
2 => toscalar(sc.spheres(2).radius),
3 => toscalar(sc.spheres(3).radius), 
4 => toscalar(sc.spheres(4).radius), 
5 => toscalar(sc.spheres(5).radius), 
6 => toscalar(sc.spheres(6).radius), 
7 => toscalar(sc.spheres(7).radius), 
8 => toscalar(sc.spheres(8).radius), 
9 => toscalar(sc.spheres(9).radius), 
10 => toscalar(sc.spheres(10).radius), 
11 => toscalar(sc.spheres(11).radius), 
12 => toscalar(sc.spheres(12).radius), 
13 => toscalar(sc.spheres(13).radius), 
14 => toscalar(sc.spheres(14).radius), 
15 => toscalar(sc.spheres(15).radius));
centers <= (0 => sc.spheres(0).center, 
1 => sc.spheres(1).center,
2 => sc.spheres(2).center,
3 => sc.spheres(3).center, 
4 => sc.spheres(4).center, 
5 => sc.spheres(5).center, 
6 => sc.spheres(6).center, 
7 => sc.spheres(7).center, 
8 => sc.spheres(8).center, 
9 => sc.spheres(9).center, 
10 => sc.spheres(10).center, 
11 => sc.spheres(11).center, 
12 => sc.spheres(12).center, 
13 => sc.spheres(13).center, 
14 => sc.spheres(14).center, 
15 => sc.spheres(15).center);

refl : reflect
  port map
  (
    clk => clk,
    clk_en => '1',
    reset => res_n,

    valid_t => ref_valid_t,
    t(31) => subwire_t(63),
    t(30 downto 0) => subwire_t(46 downto 16),

    sphere_i => ref_sphere_i,

    valid_ray_in => ref_valid,
    copy_ray_in => ref_copy,

    one_over_rs => one_over_rs,
    centers   =>  centers,

    --emitters : std_logic_vector(15 downto 0); -- noch genaui schauen, wo rein => any Refl

    origin => tovector(ref_origin),
    direction => tovector(ref_dir),

    new_origin => ref_out_origin,
    new_direction => ref_out_dir,
    valid_refl  => open,
    valid_ray_out => ref_out_valid,
    copy_ray_out => ref_out_copy
  );

colUp : colorUpdate  port map
  (
    clk => clk, clk_en => '1', reset => res_n,
    color_in => tovector(colUp_color_in), valid_t => colUp_valid_t_in, sphere_i => colUp_sphere, valid_ray_in => colUp_valid,

    copy_ray_in => ?? -- noch copy aus delay holen

    -- Kugeldaten: Farbe, ws nicht emitting

    color_array => colUp_colors,
    color_out => updatedColor,
    valid_color => updatedColorValid,
    valid_ray_out => updatedColorRayValid
  );

colUp_par_color : delay_element  generic map (WIDTH => 96, DEPTH => 2) port map (clk => clk, clken => '1', reset => res_n, source => colUp_color_in, dest => old_color);

colUp_valid_t_in <= colUp_valid_t AND NOT(colUp_pseudo);

colUp_ray_delay : delay_element generic map (DEPTH => 66, WIDTh => 98) port map (clk => clk, clken => '1', reset => res_n,
source(97) => rightRay.valid, source(96) => rightRay.pseudo_refl, source(95 downto 0) => to_std_logic(rightRay.color),
dest(97) => colUp_valid, dest(96) => colUp_pseudo, dest(95 downto 0) => colUp_color_in);

colUp_gcs_delay : delay_element generic map (DEPTH => 37, WIDTH => 5) port map (clk => clk, clken=> '1', reset => res_n,
source(4) => valid_t, source(3 downto 0) => closestSphere, dest(4) => colUp_valid_t, dest(3 downto 0) => colUp_sphere);

colUp_colors <= (0 => sc.spheres(0).colour, 
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
15 => sc.spheres(15).colour);

demux : process(anyrefo_pseudo, anyrefo_isRef, updatedColorRayValid, updatedColorValid, old_color, updatedColor) is begin
reflected_ray.valid <= '0';
backend_valid <= '0';

if anyrefo_pseudo = '1' then
	reflected_ray.pseudo_refl <= anyrefo_pseudo AND NOT(anyrefo_isRef);
	reflected_ray.valid <= updatedColorRayValid;
	if updatedColorValid = '1' then 
        	reflected_ray.color <= updatedColor;
	else reflected_ray.color <= tovector(old_color);
	end if;
	reflected_ray.origin <= ref_out_origin;
	reflected_ray.direction <= ref_out_dir;

	reflected_ray.remaining_reflects <= std_logic_vector(to_unsigned(to_integer(unsigned(rem_reflects_old)) - 1, 3));

	
	reflected_ray.sob <= anyrefo_sob;
	reflected_ray.eob <= anyrefo_eob;
	reflected_ray.copy <= ref_out_copy;

	reflected_ray.position <= old_position;
else
	backend_ray.position <= old_position;
	backend_ray.valid <= updatedColorRayValid;
	if updatedColorValid = '1' then 
        	backend_ray.color <= updatedColor;
	else backend_ray.color <= tovector(old_color);
	end if;
	backend_ray.sob <= anyrefo_sob;
	backend_ray.eob <= anyrefo_eob;
	backend_ray.copy <= ref_out_copy;
end if;
end process;
rem_ref_delay : delay_element generic map (WIDTH => 3, DEPTH => 32) port map (clk => clk, clken => '1', reset => res_n, source => anyref_ray_rem_ref, dest => rem_reflects_old);
position_delay : delay_element generic map (WIDTH => 22, DEPTH => 68) port map (clk => clk, clken=> '1', reset => res_n, source => rightRay.position, dest => old_position);

reflectDelay : rayDelay generic map (DELAY_LENGTH => 28)
port map(clk => clk, reset => res_n, clk_en => '1',
inputRay => reflected_ray, outputRay => delayed_reflected_ray);

back : backend
  port map
  (
    clk => clk, clk_en => '1', reset => res_n,

    num_samples	=> sc.num_samples(4 downto 0),

    ray_in => backend_ray, color_data => back_out_color, valid_data => back_out_valid
  );

backend_par : delay_element generic map (WIDTH => 22, DEPTH => 17) port map (clk => clk, clken => '1', reset => res_n, source => backend_ray.position, dest => back_out_address);


writeIF : writeInterface 
  generic map
  (
    FIFOSIZE => 256
  )
  port map
  (
    clk => clk, clk_en => '1', reset => res_n,
   
    -- kein clock enable, nehme valid

    pixel_address => pixel_address_writeIF,
    pixel_color   => back_out_color,
    valid_data    => back_out_valid,

    stall 	  => fifo_full,
    
    master_address   => master_address,
    --write     : in  std_logic;
    --writedata : in  std_logic_vector(31 downto 0);
    master_colordata => master_colordata,
    master_write     => master_write,
    slave_waitreq    => slave_waitreq
  );

pixel_address_async : process(back_out_address) is begin
if back_out_address(21 downto 20) = "00" OR back_out_address(21 downto 20) = "10" then
	pixel_address_writeIF <= std_logic_vector(to_unsigned(to_integer(unsigned(base_address1)) +to_integer(unsigned(back_out_address(19 downto 0))) ,32));
elsif back_out_address(21 downto 20) = "01" OR back_out_address(21 downto 20) = "11" then 
	pixel_address_writeIF <= std_logic_vector(to_unsigned(to_integer(unsigned(base_address2)) +to_integer(unsigned(back_out_address(19 downto 0))) ,32));
end if;
end process;
end architecture;