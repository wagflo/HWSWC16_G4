library ieee;
use ieee.std_logic_1164.all;

use work.delay_pkg.all;

library lpm;
use lpm.lpm_components.all; 

entity closestSphere is
  port
    (
      clk   : in std_logic;
      reset : in std_logic;
      
      clk_en : in std_logic;

      start	: in std_logic;

      copy_cycle_active : in std_logic;

      origin    : in std_logic_vector(95 downto 0);
      dir       : in std_logic_vector(95 downto 0);

      center_1  : in std_logic_vector(95 downto 0);
      radius2_1 : in std_logic_vector(31 downto 0);

      center_2  : in std_logic_vector(95 downto 0);
      radius2_2 : in std_logic_vector(31 downto 0);

      center_3  : in std_logic_vector(95 downto 0);
      radius2_3 : in std_logic_vector(31 downto 0);

      center_4  : in std_logic_vector(95 downto 0);
      radius2_4 : in std_logic_vector(31 downto 0);

      center_5  : in std_logic_vector(95 downto 0);
      radius2_5 : in std_logic_vector(31 downto 0);

      center_6  : in std_logic_vector(95 downto 0);
      radius2_6 : in std_logic_vector(31 downto 0);

      center_7  : in std_logic_vector(95 downto 0);
      radius2_7 : in std_logic_vector(31 downto 0);

      center_8  : in std_logic_vector(95 downto 0);
      radius2_8 : in std_logic_vector(31 downto 0);
		
      center_9  : in std_logic_vector(95 downto 0);
      radius2_9 : in std_logic_vector(31 downto 0);

      center_10  : in std_logic_vector(95 downto 0);
      radius2_10 : in std_logic_vector(31 downto 0);

      center_11  : in std_logic_vector(95 downto 0);
      radius2_11 : in std_logic_vector(31 downto 0);

      center_12  : in std_logic_vector(95 downto 0);
      radius2_12 : in std_logic_vector(31 downto 0);

      center_13  : in std_logic_vector(95 downto 0);
      radius2_13 : in std_logic_vector(31 downto 0);

      center_14  : in std_logic_vector(95 downto 0);
      radius2_14 : in std_logic_vector(31 downto 0);

      center_15  : in std_logic_vector(95 downto 0);
      radius2_15 : in std_logic_vector(31 downto 0);

      center_16  : in std_logic_vector(95 downto 0);
      radius2_16 : in std_logic_vector(31 downto 0);
		
	second_round : in std_logic;

	spheres : in std_logic_vector(15 downto 0);

	  t			: out std_logic_vector(31 downto 0);
	  i_out		: out std_logic_vector(3 downto 0);
	  done		: out std_logic;
	  valid_t 	: out std_logic);

end entity;

architecture arch of closestSphere is

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


component vector_square is
generic(INPUT_WIDTH : NATURAL := 32;
OUTPUT_WIDTH : NATURAL := 32);
port (
	clk : in std_logic;
	clk_en : in std_logic;
	reset : in std_logic;
	
	x, y, z : in std_logic_vector(INPUT_WIDTH-1 downto 0);
	
	result : out std_logic_vector (OUTPUT_WIDTH-1 downto 0)
);
end component;
signal sub_wire0_oneovera : std_logic_vector(47 downto 0);

signal origin_c6, dir_c6,
center_in1, center_in2, center_in3, center_in4, center_in5, center_in6, center_in7, center_in8
	: std_logic_vector(95 downto 0);
signal a_c6, t_min_a,
rad2_in1, rad2_in2, rad2_in3, rad2_in4, rad2_in5, rad2_in6, rad2_in7, rad2_in8,
a, one_over_a,
t1, t2, t3, t4, t5, t6, t7, t8, t12, t34, t56, t78, t1234, t5678, t12345678,
t1_c34, t2_c34, t3_c34, t4_c34, t5_c34, t6_c34, t7_c34, t8_c34,
t12_c35, t34_c35, t56_c35, t78_c35, t1234_c36, t5678_c36, t_old, t12345678_c37,
t_int, t_int_c52
: std_logic_vector(31 downto 0);
signal subwire0_a_t_min, subwire0_t_out : std_logic_vector(63 downto 0);
signal start_shift, cycles_shift : std_logic_vector(54 downto 0);
signal cycle_even : std_logic := '0';

signal t1_valid, t2_valid, t3_valid, t4_valid, t5_valid, t6_valid, t7_valid, t8_valid,
t2_smaller, t4_smaller, t6_smaller, t8_smaller, t34_smaller, t78_smaller, t5678_smaller,
t12_valid, t34_valid, t56_valid, t78_valid,
t1234_valid, t5678_valid, t12345678_valid,
t1_valid_c34, t2_valid_c34, t3_valid_c34, t4_valid_c34, t5_valid_c34, t6_valid_c34, t7_valid_c34, t8_valid_c34,
t12_valid_c35, t34_valid_c35, t56_valid_c35, t78_valid_c35,
t1234_valid_c36, t5678_valid_c36, t12345678_valid_c37, t_old_valid, t_int_valid, t_old_smaller,
smaller_numbers, start1, start2, start3, start4, start5, start6, start7, start8, t_int_valid_c54
: std_logic;

signal t12_sp, t34_sp, t56_sp, t78_sp, t1234_sp, t5678_sp, t12345678_sp,
t12_sp_c35, t34_sp_c35, t56_sp_c35, t78_sp_c35, t1234_sp_c36, t5678_sp_c36, t12345678_sp_c37, t_old_sp
	: std_logic_vector(2 DOWNTO 0);

signal t_int_sp, t_int_sp_c54 : std_logic_vector(3 DOWNTO 0);

constant TIME_MIN : std_logic_vector(31 downto 0) := x"0000199A";

begin


center_in1 <= center_1 when (NOT(second_round) OR cycles_shift(49)) = '1' else center_9;
center_in2 <= center_2 when (NOT(second_round) OR cycles_shift(49)) = '1' else center_10;
center_in3 <= center_3 when (NOT(second_round) OR cycles_shift(49)) = '1' else center_11;
center_in4 <= center_4 when (NOT(second_round) OR cycles_shift(49)) = '1' else center_12;
center_in5 <= center_5 when (NOT(second_round) OR cycles_shift(49)) = '1' else center_13;
center_in6 <= center_6 when (NOT(second_round) OR cycles_shift(49)) = '1' else center_14;
center_in7 <= center_7 when (NOT(second_round) OR cycles_shift(49)) = '1' else center_15;
center_in8 <= center_8 when (NOT(second_round) OR cycles_shift(49)) = '1' else center_16;

rad2_in1 <= radius2_1 when (NOT(second_round) OR cycles_shift(49)) = '1' else radius2_9;
rad2_in2 <= radius2_2 when (NOT(second_round) OR cycles_shift(49)) = '1' else radius2_10;
rad2_in3 <= radius2_3 when (NOT(second_round) OR cycles_shift(49)) = '1' else radius2_11;
rad2_in4 <= radius2_4 when (NOT(second_round) OR cycles_shift(49)) = '1' else radius2_12;
rad2_in5 <= radius2_5 when (NOT(second_round) OR cycles_shift(49)) = '1' else radius2_13;
rad2_in6 <= radius2_6 when (NOT(second_round) OR cycles_shift(49)) = '1' else radius2_14;
rad2_in7 <= radius2_7 when (NOT(second_round) OR cycles_shift(49)) = '1' else radius2_15;
rad2_in8 <= radius2_8 when (NOT(second_round) OR cycles_shift(49)) = '1' else radius2_16;

t_min_a(31) <= subwire0_a_t_min(63);
t_min_a(30 downto 0) <= subwire0_a_t_min(46 downto 16);
start_shift(54) <= (start AND clk_en) AND NOT(reset);
cycles_shift(54) <= copy_cycle_active;

a_calc_c1t4 : vector_square port map (
	clk => clk,
	clk_en => clk_en,
	reset => reset,
	x => dir(95 downto 64),
	y => dir(63 downto 32),
	z => dir(31 downto 0),
	
	result => a
);

one_over_a(31)    <= sub_wire0_oneovera(47);
one_over_a(30 DOWNTO 0) <= sub_wire0_oneovera(30 DOWNTO 0);


one_over_a_c5t52 : LPM_DIVIDE
	GENERIC MAP (
		lpm_drepresentation => "SIGNED",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=YES, LPM_REMAINDERPOSITIVE=TRUE",
		lpm_nrepresentation => "SIGNED",
		lpm_pipeline => 48,
		lpm_type => "LPM_DIVIDE",
		lpm_widthd => 32,
		lpm_widthn => 48
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		denom => a,
		numer => X"000100000000",
		quotient => sub_wire0_oneovera,
		remain => open
	);

a_t_min_calc_c5t6 : lpm_mult GENERIC MAP (
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

origin_delay : delay_element generic map(WIDTH => 96, DEPTH => 6)
port map (clk => clk, reset => reset, clken => clk_en, source => origin, dest => origin_c6
);

dir_delay : delay_element generic map(WIDTH => 96, DEPTH => 6)
port map (clk => clk, reset => reset, clken => clk_en, source => dir, dest => dir_c6
);

a_delay : delay_element generic map(WIDTH => 32, DEPTH => 2)
port map (clk => clk, reset => reset, clken => clk_en, source => a, dest => a_c6
);

smaller_numbers <= copy_cycle_active OR NOT(second_round);
start1 <= start_shift(49) AND ((smaller_numbers AND spheres(0)) OR spheres(8));
comp1_c7t33 : sphereDistance port map(
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
start2 <= start_shift(49) AND ((smaller_numbers AND spheres(1)) OR spheres(9));
comp2_c7t33 : sphereDistance port map(
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
start3 <= start_shift(49) AND ((smaller_numbers AND spheres(2)) OR spheres(10));
comp3_c7t33 : sphereDistance port map(
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
start4 <= start_shift(49) AND ((smaller_numbers AND spheres(3)) OR spheres(11));
comp4_c7t33 : sphereDistance port map(
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
start5 <= start_shift(49) AND ((smaller_numbers AND spheres(4)) OR spheres(12));
comp5_c7t33 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, 
	start => start,
	origin  => origin_c6,
   dir => dir_c6,
	a => a_c6,
	center => center_in5,
   radius2 => rad2_in5,
	t_min_a => t_min_a,
	t => t5,
	t_valid => t5_valid
);
start6 <= start_shift(49) AND ((smaller_numbers AND spheres(5)) OR spheres(13));
comp6_c7t33 : sphereDistance port map(
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
start7 <= start_shift(49) AND ((smaller_numbers AND spheres(6)) OR spheres(14));
comp7_c7t33 : sphereDistance port map(
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
start8 <= start_shift(49) AND ((smaller_numbers AND spheres(7)) OR spheres(15));
comp8_c7t33 : sphereDistance port map(
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

compare1t2_c34 : LPM_COMPARE 
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
compare3t4_c34 : LPM_COMPARE 
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
compare5t6_c34 : LPM_COMPARE 
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
compare7t8_c34 : LPM_COMPARE 
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



compare12t34_c35 : LPM_COMPARE 
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
compare56t78_c35 : LPM_COMPARE 
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
compare12345678_c36 : LPM_COMPARE 
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
compare_old_c37 : LPM_COMPARE 
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
source(31 downto 0) => t12,
dest(32) => t1_valid_c34,
dest(31 downto 0) => t1_c34
);
delay_t2 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t2_valid, 
source(31 downto 0) => t2,
dest(32) => t2_valid_c34,
dest(31 downto 0) => t2_c34
);
t12_valid <= t1_valid_c34 OR t2_valid_c34;
t12 <= t2_c34 when (t2_valid_c34 AND (t2_smaller OR NOT(t1_valid_c34))) = '1' else t1_c34;
t12_sp <= "001" when (t2_valid_c34 AND (t2_smaller OR NOT(t1_valid_c34))) = '1' else "000";

delay_t3 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t3_valid, 
source(31 downto 0) => t3,
dest(32) => t3_valid_c34,
dest(31 downto 0) => t3_c34
);
delay_t4 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t4_valid, 
source(31 downto 0) => t4,
dest(32) => t4_valid_c34,
dest(31 downto 0) => t4_c34
);
t34_valid <= t3_valid_c34 OR t4_valid_c34;
t34 <= t4_c34 when (t4_valid_c34 AND (t4_smaller OR NOT(t3_valid_c34))) = '1' else t3_c34;
t34_sp <= "011" when (t4_valid_c34 AND (t4_smaller OR NOT(t3_valid_c34))) = '1' else "010";

delay_t5 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t5_valid, 
source(31 downto 0) => t5,
dest(32) => t5_valid_c34,
dest(31 downto 0) => t5_c34
);
delay_t6 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t6_valid, 
source(31 downto 0) => t6,
dest(32) => t6_valid_c34,
dest(31 downto 0) => t6_c34
);
t56_valid <= t5_valid_c34 OR t6_valid_c34;
t56 <= t6_c34 when (t6_valid_c34 AND (t6_smaller OR NOT(t5_valid_c34))) = '1' else t5_c34;
t56_sp <= "101" when (t6_valid_c34 AND (t6_smaller OR NOT(t5_valid_c34))) = '1' else "100";

delay_t7 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t7_valid, 
source(31 downto 0) => t7,
dest(32) => t7_valid_c34,
dest(31 downto 0) => t7_c34
);
delay_t8 : delay_element generic map(WIDTH => 33, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(32) => t8_valid, 
source(31 downto 0) => t8,
dest(32) => t8_valid_c34,
dest(31 downto 0) => t8_c34
);
t78_valid <= t7_valid_c34 OR t8_valid_c34;
t78 <= t8_c34 when (t8_valid_c34 AND (t8_smaller OR NOT(t7_valid_c34))) = '1' else t7_c34;
t78_sp <= "111" when (t8_valid_c34 AND (t8_smaller OR NOT(t7_valid_c34))) = '1' else "110";

delay_t12 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t12_sp,
source(32) => t12_valid, 
source(31 downto 0) => t12,
dest(32) => t12_valid_c35,
dest(31 downto 0) => t12_c35,
dest(35 downto 33) => t12_sp_c35
);
delay_t34 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t34_sp,
source(32) => t34_valid, 
source(31 downto 0) => t34,
dest(32) => t34_valid_c35,
dest(31 downto 0) => t34_c35,
dest(35 downto 33) => t34_sp_c35
);
t1234_valid <= t12_valid_c35 OR t34_valid_c35;
t1234 <= t34_c35 when (t34_valid_c35 AND (t34_smaller OR NOT(t12_valid_c35))) = '1' else t12_c35;
t1234_sp <= t34_sp_c35 when (t34_valid_c35 AND (t34_smaller OR NOT(t12_valid_c35))) = '1' else t12_sp_c35;

delay_t56 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t56_sp,
source(32) => t56_valid, 
source(31 downto 0) => t12,
dest(32) => t56_valid_c35,
dest(31 downto 0) => t56_c35,
dest(35 downto 33) => t56_sp_c35
);
delay_t78 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t78_sp,
source(32) => t78_valid, 
source(31 downto 0) => t78,
dest(32) => t78_valid_c35,
dest(31 downto 0) => t78_c35,
dest(35 downto 33) => t78_sp_c35
);
t5678_valid <= t56_valid_c35 OR t78_valid_c35;
t5678 <= t78_c35 when (t78_valid_c35 AND (t78_smaller OR NOT(t56_valid_c35))) = '1' else t56_c35;
t5678_sp <= t78_sp_c35 when (t78_valid_c35 AND (t78_smaller OR NOT(t56_valid_c35))) = '1' else t56_sp_c35;

delay_t1234 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t1234_sp,
source(32) => t1234_valid, 
source(31 downto 0) => t1234,
dest(32) => t1234_valid_c36,
dest(31 downto 0) => t1234_c36,
dest(35 downto 33) => t1234_sp_c36
);
delay_t5678 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t5678_sp,
source(32) => t5678_valid, 
source(31 downto 0) => t5678,
dest(32) => t5678_valid_c36,
dest(31 downto 0) => t5678_c36,
dest(35 downto 33) => t5678_sp_c36
);
t12345678_valid <= t1234_valid_c36 OR t5678_valid_c36;
t12345678 <= t5678_c36 when (t5678_valid_c36 AND (t5678_smaller OR NOT(t1234_valid_c36))) = '1' else t1234_c36;
t12345678_sp <= t5678_sp_c36 when (t5678_valid_c36 AND (t5678_smaller OR NOT(t1234_valid_c36))) = '1' else t1234_sp_c36;

delay_t12345678 : delay_element generic map(WIDTH => 36, DEPTH => 1) port map (
clk => clk, clken => clk_en, reset => reset, 
source(35 downto 33) => t12345678_sp,
source(32) => t12345678_valid, 
source(31 downto 0) => t12345678,
dest(32) => t12345678_valid_c37,
dest(31 downto 0) => t12345678_c37,
dest(35 downto 33) => t12345678_sp_c37
);
t_int_valid <= t12345678_valid_c37 OR (t_old_valid AND second_round AND cycle_even);
t_int <= t_old when (t_old_valid AND t_old_smaller AND second_round AND cycle_even) = '1' else t12345678_c37;
t_int_sp <= (3 => second_round AND NOT(cycle_even), 2 => t_old_sp(2), 1 => t_old_sp(1), 0 => t_old_sp(0))
	when (t_old_valid AND t_old_smaller AND second_round AND cycle_even) = '1' 
	else (3 => second_round AND cycle_even, 2 => t12345678_sp_c37(2), 1 => t12345678_sp_c37(1), 0 => t12345678_sp_c37(0));

shift : process(clk, clk_en, reset) is begin
if reset = '1' then
	start_shift(53 downto 0) <= (OTHERS => '0');
        cycles_shift(53 downto 0) <= (OTHERS => '0');
	cycle_even <= '0';
	t_old <= (OTHERS => '0');
	t_old_valid <= '0';
	t_old_sp <= (OTHERS => '0');
elsif (rising_edge(clk) AND clk_en = '1') then
	start_shift(53 downto 0) <= start_shift(54 downto 1);
        cycles_shift(53 downto 0) <= cycles_shift(54 downto 1);
	cycle_even <= NOT(cycle_even);
	t_old <= t12345678_c37;
	t_old_valid <= t12345678_valid_c37;
	t_old_sp <= t12345678_sp_c37;
end if;
end process;

t_int_delay : delay_element generic map(WIDTH => 32, DEPTH => 15)
port map( clk => clk, clken => clk_en, reset => reset, source => t_int, dest => t_int_c52
);

t_int_longer_delay : delay_element generic map(WIDTH => 5, DEPTH => 17)
port map( clk => clk, clken => clk_en, reset => reset, 
source(0) => t_int_valid,
source(4 downto 1) => t_int_sp,
dest(0) => t_int_valid_c54,
dest(4 downto 1) => t_int_sp_c54
);

final_mult : lpm_mult GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=9, ONE_INPUT_IS_CONSTANT=NO",
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
		dataa => t_int_c52,
		datab => one_over_a,
		result => subwire0_t_out
	);

t(31) <= subwire0_t_out(63);
t(30 DOWNTO 0) <= subwire0_t_out(46 DOWNTO 16);
done <= (NOT(second_round) OR cycles_shift(0)) AND start_shift(0);
i_out <= t_int_sp_c54;
valid_t <= t_int_valid_c54;

end architecture;

