library ieee;
use ieee.std_logic_1164.all;

entity closestSphere is
  port
    (
      clk   : in std_logic;
      res_n : in std_logic;
		
		clk_en : in std_logic;

      start	: in std_logic;

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
		
	  num_spheres : in std_logic_vector(3 downto 0);

	  t			: out std_logic_vector(31 downto 0);
	  i_out		: out std_logic_vector(3 downto 0);
	  done		: out std_logic);

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

signal second_round : std_logic;

signal origin_c1, origin_c2, origin_c3, origin_c4, origin_c5, origin_c6,
dir_c1, dir_c2, dir_c3, dir_c4, dir_c5, dir_c6,
center_in1, center_in2, center_in3, center_in4, center_in5, center_in6, center_in7, center_in8
	: std_logic_vector(95 downto 0);
signal a_c5, a_c6, t_min_a,
rad2_in1, rad2_in2, rad2_in3, rad2_in4, rad2_in5, rad2_in6, rad2_in7, rad2_in8
: std_logic_vector(31 downto 0);
signal subwire0_a_t_min : std_logic_vector(63 downto 0);
signal start_shift : std_logic_vector(6 downto 0);
signal cycle_even : std_logic := '1';

constant TIME_MIN : std_logic_vector(31 downto 0) := x"0000199A";

begin

second_round <= num_spheres(3) OR num_spheres(2);

t_min_a(31) <= subwire0_a_t_min(63);
t_min_a(30 downto 0) <= subwire0_a_t_min(46 downto 16);
start_shift(6) <= start;

a_calc_c1t4 : vector_square port map (
	clk => clk,
	clk_en => clk_en,
	reset => reset,
	x => dir(95 downto 64),
	y => dir(63 downto 32),
	z => dir(31 downto 0),
	
	result => a
);

a_t_min_clac_c5t6 : lpm_mult GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=9, ONE_INPUT_IS_CONSTANT=YES",
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
	
comp1_c7t36 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, start => start_shift(0),
	origin  => origin_c6,
   dir => dir_c6,
	a => a_c6,
	center => center_in1,
   radius2 => rad2_in1,
	t_min_a => t_min_a,
	t => t1,
	t_valid => t1_valid
);
comp2_c7t36 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, start => start_shift(0),
	origin  => origin_c6,
   dir => dir_c6,
	a => a_c6,
	center => center_in2,
   radius2 => rad2_in2,
	t_min_a => t_min_a,
	t => t2,
	t_valid => t2_valid
);
comp3_c7t36 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, start => start_shift(0),
	origin  => origin_c6,
   dir => dir_c6,
	a => a_c6,
	center => center_in3,
   radius2 => rad2_in3,
	t_min_a => t_min_a,
	t => t3,
	t_valid => t3_valid
);
comp4_c7t36 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, start => start_shift(0),
	origin  => origin_c6,
   dir => dir_c6,
	a => a_c6,
	center => center_in4,
   radius2 => rad2_in4,
	t_min_a => t_min_a,
	t => t4,
	t_valid => t4_valid
);
comp5_c7t36 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, start => start_shift(0),
	origin  => origin_c6,
   dir => dir_c6,
	a => a_c6,
	center => center_in5,
   radius2 => rad2_in5,
	t_min_a => t_min_a,
	t => t5,
	t_valid => t5_valid
);
comp6_c7t36 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, start => start_shift(0),
	origin  => origin_c6,
   dir => dir_c6,
	a => a_c6,
	center => center_in6,
   radius2 => rad2_in6,
	t_min_a => t_min_a,
	t => t6,
	t_valid => t6_valid
);
comp7_c7t36 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, start => start_shift(0),
	origin  => origin_c6,
   dir => dir_c6,
	a => a_c6,
	center => center_in7,
   radius2 => rad2_in7,
	t_min_a => t_min_a,
	t => t7,
	t_valid => t7_valid
);
comp8_c7t36 : sphereDistance port map(
	clk => clk, reset => reset, clk_en => clk_en, start => start_shift(0),
	origin  => origin_c6,
   dir => dir_c6,
	a => a_c6,
	center => center_in8,
   radius2 => rad2_in8,
	t_min_a => t_min_a,
	t => t8,
	t_valid => t8_valid
);

compare1t2_c37 : LPM_COMPARE 
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
compare3t4_c37 : LPM_COMPARE 
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
compare5t6_c37 : LPM_COMPARE 
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
compare7t8_c37 : LPM_COMPARE 
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
compare12t34_c38 : LPM_COMPARE 
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
compare56t78_c38 : LPM_COMPARE 
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
compare12345678_c39 : LPM_COMPARE 
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
	

t_min_first_level : process(t1_1, t2_1,t3_1,t4_1,t5_1,t6_1,t7_1,t8_1,
	t1_valid_1,t2_valid_1,t3_valid_1,t4_valid_1,t5_valid_1, t6_valid_1, t7_valid_1, t8_valid_1,
	t2_smaller, t4_smaller, t6_smaller, t8_smaller) is begin
	
	if t1_valid = '1' AND t2_valid = '1' then
		t12_valid <= '1';
		if t2_smaller = '1' then
			t12 <= t2_1;
		else
			t12 <= t1_1;
		end if;
	elsif t1_valid = '1' then
		t12_valid <= '1';
		t12 <= t1_1;
	elsif t2_valid = '1' then
		t12_valid <= '1';
		t12 <= t2_1;
	else
		t12_valid <= '0';
		t12 <= (OTHERS => '0');
	end if;
	
	if t3_valid = '1' AND t4_valid = '1' then
		t34_valid <= '1';
		if t4_smaller = '1' then
			t34 <= t4_1;
		else
			t34 <= t3_1;
		end if;
	elsif t3_valid = '1' then
		t34_valid <= '1';
		t34 <= t3_1;
	elsif t4_valid = '1' then
		t34_valid <= '1';
		t34 <= t4_1;
	else
		t34_valid <= '0';
		t34 <= (OTHERS => '0');
	end if;
	
	if t5_valid = '1' AND t6_valid = '1' then
		t56_valid <= '1';
		if t6_smaller = '1' then
			t56 <= t6_1;
		else
			t56 <= t5_1;
		end if;
	elsif t5_valid = '1' then
		t56_valid <= '1';
		t56 <= t5_1;
	elsif t6_valid = '1' then
		t56_valid <= '1';
		t56 <= t6_1;
	else
		t56_valid <= '0';
		t56 <= (OTHERS => '0');
	end if;
	
	if t7_valid = '1' AND t8_valid = '1' then
		t78_valid <= '1';
		if t8_smaller = '1' then
			t78 <= t8_1;
		else
			t78 <= t7_1;
		end if;
	elsif t7_valid = '1' then
		t78_valid <= '1';
		t78 <= t7_1;
	elsif t8_valid = '1' then
		t78_valid <= '1';
		t78 <= t8_1;
	else
		t78_valid <= '0';
		t78 <= (OTHERS => '0');
	end if;
end process;
	
shift : process(clk, clk_en, reset) is begin
if reset = '1' then
	start_shift(5 downto 0) <= (OTHERS => '0');
elsif rising_edge(clk) AND clk_en = '1' then
	start_shift(5 downto 0) <= start_shift(6 downto 1);
end if;
end process;

end architecture;

