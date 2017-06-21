library ieee;
use ieee.std_logic_1164.all;

use work.delay_pkg.all;

--use work.lpm_util.all;
library lpm;
use lpm.lpm_components.all;

LIBRARY altera_mf;
USE altera_mf.all;


use work.operations_pkg.all;

entity closestSphereNew is port (
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


COMPONENT lpm_mult
	GENERIC (
		lpm_hint		: STRING;
		lpm_pipeline		: NATURAL;
		lpm_representation		: STRING;
		lpm_type		: STRING;
		lpm_widtha		: NATURAL;
		lpm_widthb		: NATURAL;
		lpm_widthp		: NATURAL
	);
	PORT (
			aclr	: IN STD_LOGIC ;
			clken	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
	);
	END COMPONENT;
	
COMPONENT lpm_compare
	GENERIC (
		lpm_hint		: STRING;
		lpm_pipeline		: NATURAL;
		lpm_representation		: STRING;
		lpm_type		: STRING;
		lpm_width		: NATURAL
	);
	PORT (
			aclr	: IN STD_LOGIC ;
			clken	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			agb	: OUT STD_LOGIC 
	);
	END COMPONENT;

COMPONENT lpm_divide
	GENERIC (
		lpm_drepresentation		: STRING;
		lpm_hint		: STRING;
		lpm_nrepresentation		: STRING;
		lpm_pipeline		: NATURAL;
		lpm_type		: STRING;
		lpm_widthd		: NATURAL;
		lpm_widthn		: NATURAL
	);
	PORT (
			aclr	: IN STD_LOGIC ;
			clken	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			denom	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			numer	: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
			quotient	: OUT STD_LOGIC_VECTOR (47 DOWNTO 0);
			remain	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	END COMPONENT;


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


signal origin_c6, dir_c6,
center_in1, center_in2, center_in3, center_in4, center_in5, center_in6, center_in7, center_in8
	: std_logic_vector(95 downto 0);
signal a_c6, t_min_a,
rad2_in1, rad2_in2, rad2_in3, rad2_in4, rad2_in5, rad2_in6, rad2_in7, rad2_in8, 
t1, t2, t3, t4, t5, t6, t7, t8, t12, t34, t56, t78, t1234, t5678, t12345678,
t1_c30, t2_c30, t3_c30, t4_c30, t5_c30, t6_c30, t7_c30, t8_c30,
t12_c31, t34_c31, t56_c31, t78_c31, t1234_c32, t5678_c32, t_old, t12345678_c33, t_res1
: std_logic_vector(31 downto 0);
signal subwire0_a_t_min : std_logic_vector(63 downto 0);

signal t1_valid, t2_valid, t3_valid, t4_valid, t5_valid, t6_valid, t7_valid, t8_valid,
t2_smaller, t4_smaller, t6_smaller, t8_smaller, t34_smaller, t78_smaller, t5678_smaller,
t12_valid, t34_valid, t56_valid, t78_valid,
t1234_valid, t5678_valid, t12345678_valid,
t1_valid_c30, t2_valid_c30, t3_valid_c30, t4_valid_c30, t5_valid_c30, t6_valid_c30, t7_valid_c30, t8_valid_c30,
t12_valid_c31, t34_valid_c31, t56_valid_c31, t78_valid_c31,
t1234_valid_c32, t5678_valid_c32, t12345678_valid_c33, t_old_valid, t_int_valid, t_old_smaller, t_res1_valid,
smaller_numbers, start1, start2, start3, start4, start5, start6, start7, start8,
copy_c2, copy_c33, valid_c2
: std_logic;

signal t12_sp, t34_sp, t56_sp, t78_sp, t1234_sp, t5678_sp, t12345678_sp,
t12_sp_c31, t34_sp_c31, t56_sp_c31, t78_sp_c31, t1234_sp_c32, t5678_sp_c32, t12345678_sp_c33
	: std_logic_vector(2 DOWNTO 0);

signal t_res1_sp, t_old_sp:  std_logic_vector(3 downto 0);

constant TIME_MIN : std_logic_vector(31 downto 0) := x"0000199A";

begin


center_in1 <= to_std_logic(relevantScene.spheres(0).center) when smaller_numbers = '1' else to_std_logic(relevantScene.spheres(8).center);
center_in2 <= to_std_logic(relevantScene.spheres(1).center) when smaller_numbers = '1' else to_std_logic(relevantScene.spheres(9).center);
center_in3 <= to_std_logic(relevantScene.spheres(2).center) when smaller_numbers = '1' else to_std_logic(relevantScene.spheres(10).center);
center_in4 <= to_std_logic(relevantScene.spheres(3).center) when smaller_numbers = '1' else to_std_logic(relevantScene.spheres(11).center);
center_in5 <= to_std_logic(relevantScene.spheres(4).center) when smaller_numbers = '1' else to_std_logic(relevantScene.spheres(12).center);
center_in6 <= to_std_logic(relevantScene.spheres(5).center) when smaller_numbers = '1' else to_std_logic(relevantScene.spheres(13).center);
center_in7 <= to_std_logic(relevantScene.spheres(6).center) when smaller_numbers = '1' else to_std_logic(relevantScene.spheres(14).center);
center_in8 <= to_std_logic(relevantScene.spheres(7).center) when smaller_numbers = '1' else to_std_logic(relevantScene.spheres(15).center);

rad2_in1 <= relevantScene.spheres(0).radius2 when smaller_numbers = '1' else relevantScene.spheres(8).radius2;
rad2_in2 <= relevantScene.spheres(1).radius2 when smaller_numbers = '1' else relevantScene.spheres(9).radius2;
rad2_in3 <= relevantScene.spheres(2).radius2 when smaller_numbers = '1' else relevantScene.spheres(10).radius2;
rad2_in4 <= relevantScene.spheres(3).radius2 when smaller_numbers = '1' else relevantScene.spheres(11).radius2;
rad2_in5 <= relevantScene.spheres(4).radius2 when smaller_numbers = '1' else relevantScene.spheres(12).radius2;
rad2_in6 <= relevantScene.spheres(5).radius2 when smaller_numbers = '1' else relevantScene.spheres(13).radius2;
rad2_in7 <= relevantScene.spheres(6).radius2 when smaller_numbers = '1' else relevantScene.spheres(14).radius2;
rad2_in8 <= relevantScene.spheres(7).radius2 when smaller_numbers = '1' else relevantScene.spheres(15).radius2;

t_min_a(31) <= subwire0_a_t_min(63);
t_min_a(30 downto 0) <= subwire0_a_t_min(46 downto 16);


a_t_min_calc_c1t2 : lpm_mult GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=9", --, ONE_INPUT_IS_CONSTANT=YES",
		--lpm_hint => "ONE_INPUT_IS_CONSTANT=YES",
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

origin_delay : delay_element generic map(WIDTH => 96, DEPTH => 2)
port map (clk => clk, reset => reset, clken => clk_en, source => to_std_logic(origin), dest => origin_c6
);

dir_delay : delay_element generic map(WIDTH => 96, DEPTH => 2)
port map (clk => clk, reset => reset, clken => clk_en, source => to_std_logic(dir), dest => dir_c6
);

a_delay : delay_element generic map(WIDTH => 32, DEPTH => 2)
port map (clk => clk, reset => reset, clken => clk_en, source => a, dest => a_c6
);

copy_delay_1 : delay_element generic map (WIDTH => 2, DEPTH => 2) port map(clk => clk, clken => '1', reset => reset, 
source(0) => copy,  source(1) => valid,
dest(0) => copy_c2, dest(1) => valid_c2);

copy_delay_2 : delay_element generic map (WIDTH => 1, DEPTH => 31) port map (clk=> clk, clken=>'1', reset => reset, 
source(0)=>copy_c2, dest(0)=>copy_c33);
--copy_delay_3 : delay_element generic map (WIDTH => 1, DEPTH => 1) port map (clk=>clk, clken=>'1', reset => reset, 
--source(0)=>copy_c33, dest(0)=>copy_c22);

smaller_numbers <= NOT(copy_c2); --OR NOT(relevantScene.num_spheres(3));
start1 <= valid_c2 AND ((smaller_numbers AND relevantScene.activeSpheres(0)) OR (NOT(smaller_numbers) AND relevantScene.activeSpheres(8)));
comp1_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start1,
	origin  => origin_c6,
   	dir => dir_c6,
	a => a_c6,
	center => center_in1,
   	radius2 => rad2_in1,
	t_min_a => t_min_a,
	t => t1,
	t_valid => t1_valid
);
start2 <= valid_c2 AND ((smaller_numbers AND relevantScene.activeSpheres(1)) OR (NOT(smaller_numbers) AND relevantScene.activeSpheres(9)));
comp2_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en,
	start => start2,
	origin  => origin_c6,
   	dir => dir_c6,
	a => a_c6,
	center => center_in2,
   	radius2 => rad2_in2,
	t_min_a => t_min_a,
	t => t2,
	t_valid => t2_valid
);
start3 <= valid_c2 AND ((smaller_numbers AND relevantScene.activeSpheres(2)) OR (NOT(smaller_numbers) AND relevantScene.activeSpheres(10)));
comp3_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start3,
	origin  => origin_c6,
   	dir => dir_c6,
	a => a_c6,
	center => center_in3,
   	radius2 => rad2_in3,
	t_min_a => t_min_a,
	t => t3,
	t_valid => t3_valid
);
start4 <= valid_c2 AND ((smaller_numbers AND relevantScene.activeSpheres(3)) OR (NOT(smaller_numbers) AND relevantScene.activeSpheres(11)));
comp4_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start4,
	origin  => origin_c6,
   	dir => dir_c6,
	a => a_c6,
	center => center_in4,
   	radius2 => rad2_in4,
	t_min_a => t_min_a,
	t => t4,
	t_valid => t4_valid
);
start5 <= valid_c2 AND ((smaller_numbers AND relevantScene.activeSpheres(4)) OR (NOT(smaller_numbers) AND relevantScene.activeSpheres(12)));
comp5_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start5,
	origin  => origin_c6,
   	dir => dir_c6,
	a => a_c6,
	center => center_in5,
   	radius2 => rad2_in5,
	t_min_a => t_min_a,
	t => t5,
	t_valid => t5_valid
);
start6 <= valid_c2 AND ((smaller_numbers AND relevantScene.activeSpheres(5)) OR (NOT(smaller_numbers) AND relevantScene.activeSpheres(13)));
comp6_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start6,
	origin  => origin_c6,
   	dir => dir_c6,
	a => a_c6,
	center => center_in6,
   	radius2 => rad2_in6,
	t_min_a => t_min_a,
	t => t6,
	t_valid => t6_valid
);
start7 <= valid_c2 AND ((smaller_numbers AND relevantScene.activeSpheres(6)) OR (NOT(smaller_numbers) AND relevantScene.activeSpheres(14)));
comp7_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start7,
	origin  => origin_c6,
   	dir => dir_c6,
	a => a_c6,
	center => center_in7,
   	radius2 => rad2_in7,
	t_min_a => t_min_a,
	t => t7,
	t_valid => t7_valid
);
start8 <= valid_c2 AND ((smaller_numbers AND relevantScene.activeSpheres(7)) OR (NOT(smaller_numbers) AND relevantScene.activeSpheres(15)));
comp8_c3t29 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en,
	start => start8,
	origin  => origin_c6,
   	dir => dir_c6,
	a => a_c6,
	center => center_in8,
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
delay_t1 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t1_valid, 
source(31 downto 0) => t1,
dest(32) => t1_valid_c30,
dest(31 downto 0) => t1_c30
);
delay_t2 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t2_valid, 
source(31 downto 0) => t2,
dest(32) => t2_valid_c30,
dest(31 downto 0) => t2_c30
);

assign_t12 : process(t1_valid_c30, t2_valid_c30, t2_smaller, t2_c30, t1_c30) is begin
if t1_valid_c30 = '1' and t2_valid_c30 = '1' then
	t12_valid <= '1';
	if t2_smaller = '1' then
		t12 <= t2_c30;
		t12_sp <= "001";
	else
		t12 <= t1_c30;
		t12_sp <= "000";
	end if;
elsif t1_valid_c30 = '1' then
	t12_valid <= '1';
	t12 <= t1_c30;
	t12_sp <= "000";
elsif t2_valid_c30 = '1' then
	t12_valid <= '1';
	t12 <= t2_c30;
	t12_sp <= "001";
else
	t12_valid <= '0';
	t12 <= t1_c30;
	t12_sp <= "000";
end if;
end process;

--t12_valid <= t1_valid_c30 OR t2_valid_c30;
--t12 <= t2_c30 when (t2_valid_c30 AND (t2_smaller OR NOT(t1_valid_c30))) = '1' else t1_c30;
--t12_sp <= "001" when (t2_valid_c30 AND (t2_smaller OR NOT(t1_valid_c30))) = '1' else "000";

delay_t3 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t3_valid, 
source(31 downto 0) => t3,
dest(32) => t3_valid_c30,
dest(31 downto 0) => t3_c30
);
delay_t4 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t4_valid, 
source(31 downto 0) => t4,
dest(32) => t4_valid_c30,
dest(31 downto 0) => t4_c30
);

assign_t34 : process(t3_valid_c30, t4_valid_c30, t4_smaller, t4_c30, t3_c30) is begin
if t3_valid_c30 = '1' and t4_valid_c30 = '1' then
	t34_valid <= '1';
	if t4_smaller = '1' then
		t34 <= t4_c30;
		t34_sp <= "011";
	else
		t34 <= t3_c30;
		t34_sp <= "000";
	end if;
elsif t3_valid_c30 = '1' then
	t34_valid <= '1';
	t34 <= t3_c30;
	t34_sp <= "010";
elsif t4_valid_c30 = '1' then
	t34_valid <= '1';
	t34 <= t4_c30;
	t34_sp <= "011";
else
	t34_valid <= '0';
	t34 <= t3_c30;
	t34_sp <= "010";
end if;
end process;

--t34_valid <= t3_valid_c30 OR t4_valid_c30;
--t34 <= t4_c30 when (t4_valid_c30 AND (t4_smaller OR NOT(t3_valid_c30))) = '1' else t3_c30;
--t34_sp <= "011" when (t4_valid_c30 AND (t4_smaller OR NOT(t3_valid_c30))) = '1' else "010";

delay_t5 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t5_valid, 
source(31 downto 0) => t5,
dest(32) => t5_valid_c30,
dest(31 downto 0) => t5_c30
);
delay_t6 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t6_valid, 
source(31 downto 0) => t6,
dest(32) => t6_valid_c30,
dest(31 downto 0) => t6_c30
);

assign_t56 : process(t5_valid_c30, t6_valid_c30, t6_smaller, t6_c30, t5_c30) is begin
if t5_valid_c30 = '1' and t6_valid_c30 = '1' then
	t56_valid <= '1';
	if t6_smaller = '1' then
		t56 <= t6_c30;
		t56_sp <= "101";
	else
		t56 <= t5_c30;
		t56_sp <= "100";
	end if;
elsif t5_valid_c30 = '1' then
	t56_valid <= '1';
	t56 <= t5_c30;
	t56_sp <= "100";
elsif t6_valid_c30 = '1' then
	t56_valid <= '1';
	t56 <= t6_c30;
	t56_sp <= "101";
else
	t56_valid <= '0';
	t56 <= t5_c30;
	t56_sp <= "100";
end if;
end process;

--t56_valid <= t5_valid_c30 OR t6_valid_c30;
--t56 <= t6_c30 when (t6_valid_c30 AND (t6_smaller OR NOT(t5_valid_c30))) = '1' else t5_c30;
--t56_sp <= "101" when (t6_valid_c30 AND (t6_smaller OR NOT(t5_valid_c30))) = '1' else "100";

delay_t7 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t7_valid, 
source(31 downto 0) => t7,
dest(32) => t7_valid_c30,
dest(31 downto 0) => t7_c30
);
delay_t8 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t8_valid, 
source(31 downto 0) => t8,
dest(32) => t8_valid_c30,
dest(31 downto 0) => t8_c30
);

assign_t78 : process(t7_valid_c30, t8_valid_c30, t8_smaller, t8_c30, t7_c30) is begin
if t7_valid_c30 = '1' and t8_valid_c30 = '1' then
	t78_valid <= '1';
	if t8_smaller = '1' then
		t78 <= t8_c30;
		t78_sp <= "111";
	else
		t78 <= t7_c30;
		t78_sp <= "110";
	end if;
elsif t7_valid_c30 = '1' then
	t78_valid <= '1';
	t78 <= t7_c30;
	t78_sp <= "110";
elsif t8_valid_c30 = '1' then
	t78_valid <= '1';
	t78 <= t8_c30;
	t78_sp <= "111";
else
	t78_valid <= '0';
	t78 <= t7_c30;
	t78_sp <= "110";
end if;
end process;

--t78_valid <= t7_valid_c30 OR t8_valid_c30;
--t78 <= t8_c30 when (t8_valid_c30 AND (t8_smaller OR NOT(t7_valid_c30))) = '1' else t7_c30;
--t78_sp <= "111" when (t8_valid_c30 AND (t8_smaller OR NOT(t7_valid_c30))) = '1' else "110";

delay_t12 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t12_sp,
source(32) => t12_valid, 
source(31 downto 0) => t12,
dest(32) => t12_valid_c31,
dest(31 downto 0) => t12_c31,
dest(35 downto 33) => t12_sp_c31
);
delay_t34 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t34_sp,
source(32) => t34_valid, 
source(31 downto 0) => t34,
dest(32) => t34_valid_c31,
dest(31 downto 0) => t34_c31,
dest(35 downto 33) => t34_sp_c31
);

assign_t1234 : process(t12_valid_c31, t34_valid_c31, t34_smaller, t34_c31, t12_c31, t12_sp_c31, t34_sp_c31) is begin
if t12_valid_c31 = '1' and t34_valid_c31 = '1' then
	t1234_valid <= '1';
	if t34_smaller = '1' then
		t1234 <= t34_c31;
		t1234_sp <= t34_sp_c31;
	else
		t1234 <= t12_c31;
		t1234_sp <= t12_sp_c31;
	end if;
elsif t12_valid_c31 = '1' then
	t1234_valid <= '1';
	t1234 <= t12_c31;
	t1234_sp <= t12_sp_c31;
elsif t34_valid_c31 = '1' then
	t1234_valid <= '1';
	t1234 <= t34_c31;
	t1234_sp <= t34_sp_c31;
else
	t1234_valid <= '0';
	t1234 <= t12_c31;
	t1234_sp <= t12_sp_c31;
end if;
end process;

--t1234_valid <= t12_valid_c31 OR t34_valid_c31;
--t1234 <= t34_c31 when (t34_valid_c31 AND (t34_smaller OR NOT(t12_valid_c31))) = '1' else t12_c31;
--t1234_sp <= t34_sp_c31 when (t34_valid_c31 AND (t34_smaller OR NOT(t12_valid_c31))) = '1' else t12_sp_c31;

delay_t56 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t56_sp,
source(32) => t56_valid, 
source(31 downto 0) => t12,
dest(32) => t56_valid_c31,
dest(31 downto 0) => t56_c31,
dest(35 downto 33) => t56_sp_c31
);
delay_t78 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t78_sp,
source(32) => t78_valid, 
source(31 downto 0) => t78,
dest(32) => t78_valid_c31,
dest(31 downto 0) => t78_c31,
dest(35 downto 33) => t78_sp_c31
);

assign_t5678 : process(t56_valid_c31, t78_valid_c31, t78_smaller, t78_c31, t56_c31, t56_sp_c31, t78_sp_c31) is begin
if t56_valid_c31 = '1' and t78_valid_c31 = '1' then
	t5678_valid <= '1';
	if t78_smaller = '1' then
		t5678 <= t78_c31;
		t5678_sp <= t78_sp_c31;
	else
		t5678 <= t56_c31;
		t5678_sp <= t56_sp_c31;
	end if;
elsif t56_valid_c31 = '1' then
	t5678_valid <= '1';
	t5678 <= t56_c31;
	t5678_sp <= t56_sp_c31;
elsif t78_valid_c31 = '1' then
	t5678_valid <= '1';
	t5678 <= t78_c31;
	t5678_sp <= t78_sp_c31;
else
	t5678_valid <= '0';
	t5678 <= t56_c31;
	t5678_sp <= t56_sp_c31;
end if;
end process;

--t5678_valid <= t56_valid_c31 OR t78_valid_c31;
--t5678 <= t78_c31 when (t78_valid_c31 AND (t78_smaller OR NOT(t56_valid_c31))) = '1' else t56_c31;
--t5678_sp <= t78_sp_c31 when (t78_valid_c31 AND (t78_smaller OR NOT(t56_valid_c31))) = '1' else t56_sp_c31;

delay_t1234 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t1234_sp,
source(32) => t1234_valid, 
source(31 downto 0) => t1234,
dest(32) => t1234_valid_c32,
dest(31 downto 0) => t1234_c32,
dest(35 downto 33) => t1234_sp_c32
);
delay_t5678 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t5678_sp,
source(32) => t5678_valid, 
source(31 downto 0) => t5678,
dest(32) => t5678_valid_c32,
dest(31 downto 0) => t5678_c32,
dest(35 downto 33) => t5678_sp_c32
);

assign_t12345678 : process(t1234_valid_c32, t5678_valid_c32, t5678_smaller, t5678_c32, t1234_c32, t1234_sp_c32, t5678_sp_c32) is begin
if t1234_valid_c32 = '1' and t5678_valid_c32 = '1' then
	t12345678_valid <= '1';
	if t5678_smaller = '1' then
		t12345678 <= t5678_c32;
		t12345678_sp <= t5678_sp_c32;
	else
		t12345678 <= t1234_c32;
		t12345678_sp <= t1234_sp_c32;
	end if;
elsif t1234_valid_c32 = '1' then
	t12345678_valid <= '1';
	t12345678 <= t1234_c32;
	t12345678_sp <= t1234_sp_c32;
elsif t5678_valid_c32 = '1' then
	t12345678_valid <= '1';
	t12345678 <= t5678_c32;
	t12345678_sp <= t5678_sp_c32;
else
	t12345678_valid <= '0';
	t12345678 <= t1234_c32;
	t12345678_sp <= t1234_sp_c32;
end if;
end process;

--t12345678_valid <= t1234_valid_c32 OR t5678_valid_c32;
--t12345678 <= t5678_c32 when (t5678_valid_c32 AND (t5678_smaller OR NOT(t1234_valid_c32))) = '1' else t1234_c32;
--t12345678_sp <= t5678_sp_c32 when (t5678_valid_c32 AND (t5678_smaller OR NOT(t1234_valid_c32))) = '1' else t1234_sp_c32;

delay_t12345678 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t12345678_sp,
source(32) => t12345678_valid, 
source(31 downto 0) => t12345678,
dest(32) => t12345678_valid_c33,
dest(31 downto 0) => t12345678_c33,
dest(35 downto 33) => t12345678_sp_c33
);

assign_t_res1 : process(t12345678_valid_c33, t_old_valid, t_old_smaller, t12345678_c33, t_old, t12345678_sp_c33, t_old_sp) is begin
if t12345678_valid_c33 = '1' and t_old_valid = '1' then
	t_res1_valid <= '1';
	if t_old_smaller = '1' AND copy_c33 = '1' then
		t_res1 <= t_old;
		t_res1_sp <= t_old_sp;
	else
		t_res1 <= t12345678_c33;
		t_res1_sp <= copy_c33 & t12345678_sp_c33;
	end if;
elsif t12345678_valid_c33 = '1' then
	t_res1_valid <= '1';
	t_res1 <= t12345678_c33;
	t_res1_sp <= copy_c33 & t12345678_sp_c33;
elsif t_old_valid = '1' and copy_c33 = '1' then
	t_res1_valid <= '1';
	t_res1 <= t_old;
	t_res1_sp <= t_old_sp;
else
	t_res1_valid <= '0';
	t_res1 <= t12345678_c33;
	t_res1_sp <= copy_c33 & t12345678_sp_c33;
end if;
end process;

--t_res1 <= t_old when (copy_c33 AND t_old_valid AND t_old_smaller) = '1' else t12345678_c33;
--t_res1_valid <= t_old_valid when (copy_c33 AND t_old_valid AND t_old_smaller) = '1' else t12345678_valid_c33;
--t_res1_sp <= t_old_sp when (copy_c33 AND t_old_valid AND t_old_smaller) = '1' else copy_c33 & t12345678_sp_c33;


shift : process(clk, clk_en, reset) is begin
if reset = '1' then
	t_old <= (OTHERS => '0');
	t_old_valid <= '0';
	t_old_sp <= (OTHERS => '0');
elsif (rising_edge(clk) AND clk_en = '1') then
	t_old <= t_res1;
	t_old_valid <= t_res1_valid;
	t_old_sp <= t_res1_sp;
end if;
end process;

assign_output : process(copy_c33, t_res1, t_old, t_res1_sp, t_old_sp, t_res1_valid, t_old_valid) is begin
if copy_c33 = '1' then
	t_times_a <= t_res1;
	closestSphere <= t_res1_sp;
	valid_t <= t_res1_valid;
else
	t_times_a <= t_old;
	closestSphere <= t_old_sp;
	valid_t <= t_old_valid;
end if;
end process;
end architecture;

