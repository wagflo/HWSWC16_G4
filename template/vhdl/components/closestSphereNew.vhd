library ieee;
use ieee.std_logic_1164.all;

use work.delay_pkg.all;

use work.rayDelay_pkg.all;

use work.operations_pkg.all;

use work.lpm_util.all;

entity closestSphereNew is

port (
	clk, reset, clk_en 	: in std_logic;
	dir, origin		: in vector;
	a			: in std_logic_vector(31 downto 0);
	copy, valid		: in std_logic;
	relevantScene		: in scInput;
	t_times_a		: out std_logic_vector(31 downto 0);
	valid_t			: out std_logic;
	closestSphere		: out std_logic_vector(3 downto 0)
	
);

end entity;

architecture arch of closestSphereNew is

component sphereDistance is
  port
    (
      clk   : in std_logic;
      reset : in std_logic;
		clk_en : in std_logic;

      start : in std_logic;


      origin    : in std_logic_vector(95 downto 0);
      dir       : in std_logic_vector(95 downto 0);

	   a			 : in std_logic_vector(31 downto 0);

      center    : in std_logic_vector(95 downto 0);
      radius2   : in std_logic_vector(31 downto 0);

	   t_min_a : in std_logic_vector(31 downto 0);

	   t			: out std_logic_vector(31 downto 0);
		
	   t_valid		: out std_logic

      );
end component;

constant TIME_MIN : std_logic_vector(31 downto 0) := x"0000199A";

signal subwire0_a_t_min : std_logic_vector(63 downto 0);

signal origin_c2, dir_c2 : std_logic_vector(95 downto 0);

signal center_in1, center_in2, center_in3, center_in4, center_in5, center_in6, center_in7, center_in8 : vector;

signal rad2_in1, rad2_in2, rad2_in3, rad2_in4, rad2_in5, rad2_in6, rad2_in7, rad2_in8, t_min_a : std_logic_vector(31 downto 0);

signal a_c2, t1, t2, t3, t4, t5, t6, t7, t8, t12, t34, t56, t78, t1234, t5678, t12345678, t_old : std_logic_vector(31 downto 0);

signal start1, start2, start3, start4, start5, start6, start7, start8, smaller_numbers,
t2_smaller, t4_smaller, t6_smaller, t8_smaller, t34_smaller, t78_smaller, t5678_smaller, t_old_smaller,
t1_valid, t2_valid, t3_valid, t4_valid, t5_valid, t6_valid, t7_valid, t8_valid
	 : std_logic;

begin

a_t_min_calc_c1t2 : lpm_mult GENERIC MAP (
		lpm_hint => "ONE_INPUT_IS_CONSTANT=YES",
		lpm_pipeline => 2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 32,
		lpm_widthb => 32,
		lpm_widthp => 64
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => a,
		datab => TIME_MIN,
		result => subwire0_a_t_min
	);
t_min_a <= subwire0_a_t_min(63) & subwire0_a_t_min(46 downto 16);
origin_delay : delay_element generic map(WIDTH => 96, DEPTH => 2)
port map (clk => clk, reset => reset, clken => clk_en, source => to_std_logic(origin), dest => origin_c2
);

dir_delay : delay_element generic map(WIDTH => 96, DEPTH => 62)
port map (clk => clk, reset => reset, clken => clk_en, source => to_std_logic(dir), dest => dir_c2
);

a_delay : delay_element generic map(WIDTH => 32, DEPTH => 2)
port map (clk => clk, reset => reset, clken => clk_en, source => a, dest => a_c2
);
start1 <= valid AND ((smaller_numbers AND relevantScene.activeSpheres(0)) OR relevantScene.activeSpheres(8));
center_in1 <= relevantScene.spheres(0).center when smaller_numbers = '1' else relevantScene.spheres(8).center;
rad2_in1 <= relevantScene.spheres(0).radius2 when smaller_numbers = '1' else relevantScene.spheres(8).radius2;
comp1_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start1,
	origin  => origin_c2,
   	dir => dir_c2,
	a => a_c2,
	center => to_std_logic(center_in1),
   	radius2 => rad2_in1,
	t_min_a => t_min_a,
	t => t1,
	t_valid => t1_valid
);
start2 <= valid AND ((smaller_numbers AND relevantScene.activeSpheres(1)) OR relevantScene.activeSpheres(9));
center_in2 <= relevantScene.spheres(1).center when smaller_numbers = '1' else relevantScene.spheres(9).center;
rad2_in1 <= relevantScene.spheres(1).radius2 when smaller_numbers = '1' else relevantScene.spheres(9).radius2;
comp2_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en,
	start => start2,
	origin  => origin_c2,
   	dir => dir_c2,
	a => a_c2,
	center => to_std_logic(center_in2),
   	radius2 => rad2_in2,
	t_min_a => t_min_a,
	t => t2,
	t_valid => t2_valid
);
start3 <= valid AND ((smaller_numbers AND relevantScene.activeSpheres(2)) OR relevantScene.activeSpheres(10));
center_in3 <= relevantScene.spheres(2).center when smaller_numbers = '1' else relevantScene.spheres(10).center;
rad2_in3 <= relevantScene.spheres(2).radius2 when smaller_numbers = '1' else relevantScene.spheres(10).radius2;
comp3_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start3,
	origin  => origin_c2,
	dir => dir_c2,
	a => a_c2,
	center => to_std_logic(center_in3),
	radius2 => rad2_in3,
	t_min_a => t_min_a,
	t => t3,
	t_valid => t3_valid
);
start4 <= valid AND ((smaller_numbers AND relevantScene.activeSpheres(3)) OR relevantScene.activeSpheres(11));
center_in4 <= relevantScene.spheres(3).center when smaller_numbers = '1' else relevantScene.spheres(11).center;
rad2_in4 <= relevantScene.spheres(3).radius2 when smaller_numbers = '1' else relevantScene.spheres(11).radius2;
comp4_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start4,
	origin  => origin_c2,
   	dir => dir_c2,
	a => a_c2,
	center => to_std_logic(center_in4),
	radius2 => rad2_in4,
	t_min_a => t_min_a,
	t => t4,
	t_valid => t4_valid
);
start5 <= valid AND ((smaller_numbers AND relevantScene.activeSpheres(4)) OR relevantScene.activeSpheres(12));
center_in5 <= relevantScene.spheres(4).center when smaller_numbers = '1' else relevantScene.spheres(12).center;
rad2_in5 <= relevantScene.spheres(4).radius2 when smaller_numbers = '1' else relevantScene.spheres(12).radius2;
comp5_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start5,
	origin  => origin_c2,
	dir => dir_c2,
	a => a_c2,
	center => to_std_logic(center_in5),
   	radius2 => rad2_in5,
	t_min_a => t_min_a,
	t => t5,
	t_valid => t5_valid
);
start6 <= valid AND ((smaller_numbers AND relevantScene.activeSpheres(5)) OR relevantScene.activeSpheres(13));
center_in6 <= relevantScene.spheres(5).center when smaller_numbers = '1' else relevantScene.spheres(13).center;
rad2_in6 <= relevantScene.spheres(5).radius2 when smaller_numbers = '1' else relevantScene.spheres(13).radius2;
comp6_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start6,
	origin  => origin_c2,
   	dir => dir_c2,
	a => a_c2,
	center => to_std_logic(center_in6),
   	radius2 => rad2_in6,
	t_min_a => t_min_a,
	t => t6,
	t_valid => t6_valid
);
start7 <= valid AND ((smaller_numbers AND relevantScene.activeSpheres(6)) OR relevantScene.activeSpheres(14));
center_in7 <= relevantScene.spheres(6).center when smaller_numbers = '1' else relevantScene.spheres(14).center;
rad2_in7 <= relevantScene.spheres(6).radius2 when smaller_numbers = '1' else relevantScene.spheres(14).radius2;
comp7_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start7,
	origin  => origin_c2,
   	dir => dir_c2,
	a => a_c2,
	center => to_std_logic(center_in7),
   	radius2 => rad2_in7,
	t_min_a => t_min_a,
	t => t7,
	t_valid => t7_valid
);
start8 <= valid AND ((smaller_numbers AND relevantScene.activeSpheres(7)) OR relevantScene.activeSpheres(15));
center_in8 <= relevantScene.spheres(7).center when smaller_numbers = '1' else relevantScene.spheres(15).center;
rad2_in8 <= relevantScene.spheres(7).radius2 when smaller_numbers = '1' else relevantScene.spheres(15).radius2;
comp8_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en,
	start => start8,
	origin  => origin_c2,
   	dir => dir_c2,
	a => a_c2,
	center => to_std_logic(center_in8),
   	radius2 => rad2_in8,
	t_min_a => t_min_a,
	t => t8,
	t_valid => t8_valid
);
compare1t2_c30 : LPM_COMPARE 
	GENERIC MAP (
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_COMPARE",
		lpm_width => 32
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => t1,
		datab => t2,
		agb => t2_smaller
	);
compare3t4_c30 : LPM_COMPARE 
	GENERIC MAP (
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_COMPARE",
		lpm_width => 32
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => t3,
		datab => t4,
		agb => t4_smaller
	);
compare5t6_c30 : LPM_COMPARE 
	GENERIC MAP (
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_COMPARE",
		lpm_width => 32
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => t5,
		datab => t6,
		agb => t6_smaller
	);
compare7t8_c30 : LPM_COMPARE 
	GENERIC MAP (
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_COMPARE",
		lpm_width => 32
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => t7,
		datab => t8,
		agb => t8_smaller
	);



compare12t34_c31 : LPM_COMPARE 
	GENERIC MAP (
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_COMPARE",
		lpm_width => 32
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => t12,
		datab => t34,
		agb => t34_smaller
	);
compare56t78_c31 : LPM_COMPARE 
	GENERIC MAP (
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_COMPARE",
		lpm_width => 32
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => t56,
		datab => t78,
		agb => t78_smaller
	);
compare12345678_c32 : LPM_COMPARE 
	GENERIC MAP (
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_COMPARE",
		lpm_width => 32
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => t1234,
		datab => t5678,
		agb => t5678_smaller
	);
compare_old_c33 : LPM_COMPARE 
	GENERIC MAP (
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_COMPARE",
		lpm_width => 32
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => t12345678,
		datab => t_old,
		agb => t_old_smaller
	);


end architecture;
