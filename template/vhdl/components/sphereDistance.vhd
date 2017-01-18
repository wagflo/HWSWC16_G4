library ieee;
use ieee.std_logic_1164.all;

entity sphereDistance is
  port
    (
      clk   : in std_logic;
      reset : in std_logic;
		clk_en : in std_logic;

      start : in std_logic;

 	  --i_in		: in std_logic_vector(3 downto 0);

      origin    : in std_logic_vector(95 downto 0);
      dir       : in std_logic_vector(95 downto 0);

	   a			 : in std_logic_vector(31 downto 0);

      center    : in std_logic_vector(95 downto 0);
      radius2   : in std_logic_vector(31 downto 0);

	   time_min_times_a : in std_logic_vector(31 downto 0);

	   t			: out std_logic_vector(31 downto 0);
	   --i_out		: out std_logic_vector(3 downto 0);
	   done		: out std_logic

      );
end entity;

architecture arch of sphereDistance is

component vector_sub is 
port (
	x1, y1, z1 : in std_logic_vector(31 downto 0);
	x2, y2, z2 : in std_logic_vector(31 downto 0);
	
	x, y, z : out std_logic_vector(31 downto 0)
);
end component;

component vector_dot is 
port (
	clk : in std_logic;
	clk_en : in std_logic;
	reset : in std_logic;
	
	x_1, y_1, z_1 : in std_logic_vector(31 downto 0);
	
	x_2, y_2, z_2 : in std_logic_vector(31 downto 0);
	
	result : out std_logic_vector (31 downto 0)
);
end component;

component vector_square is

port (
	clk : in std_logic;
	clk_en : in std_logic;
	reset : in std_logic;
	
	x, y, z : in std_logic_vector(31 downto 0);
	
	result : out std_logic_vector (31 downto 0)
);
end component;

component sub is
PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

COMPONENT square IS
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		ena		: IN STD_LOGIC ;
		result		: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
	);
END COMPONENT;

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

COMPONENT ip_sqrt IS
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clk		: IN STD_LOGIC ;
		radical		: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
		remainder		: OUT STD_LOGIC_VECTOR (24 DOWNTO 0)
	);
END COMPONENT;	

signal next_oc, oc, dir_latch1
	: std_logic_vector (95 downto 0);
signal time_min_times_a_latch1, radius2_latch1, b, next_b, next_almost_c, almost_c, next_c, c,
time_min_times_a_latch2, radius2_latch2, time_min_times_a_latch3, radius2_latch3, time_min_times_a_latch4, radius2_latch4,
time_min_times_a_latch5, radius2_latch5,
a_latch1, a_latch2, a_latch3, a_latch4, a_latch5, a_latch6, b_latch1, time_min_times_a_latch6,
time_min_times_a_latch7, ac, b_sq, discr, time_min_times_a_latch8, next_discr, b_latch2, b_latch3, discr_after_sqrt, t1, t2,
b_latch4, b_latch5, b_latch6, b_latch7, b_latch8, b_latch9, b_latch10, b_latch11, b_latch12, b_latch13, b_latch14, b_latch15, 
b_latch16, b_latch17, b_latch18, b_latch19,
time_min_times_a_latch9, time_min_times_a_latch10, time_min_times_a_latch11, time_min_times_a_latch12, time_min_times_a_latch13,
time_min_times_a_latch14, time_min_times_a_latch15, time_min_times_a_latch16, time_min_times_a_latch17, time_min_times_a_latch18,
time_min_times_a_latch19, time_min_times_a_latch20, time_min_times_a_latch21, time_min_times_a_latch22, time_min_times_a_latch23,
time_min_times_a_latch24
	: std_logic_vector (31 downto 0);
begin
sub_oc : vector_sub port map (
	x1 => origin(95 downto 64),
	y1 => origin(63 downto 32),
	z1 => origin(31 downto 0),
	
	x2 => center(95 downto 64),
	y2 => center(63 downto 32),
	z2 => center(31 downto 0),
	
	x => next_oc(95 downto 64),
	y => next_oc(63 downto 32),
	z => next_oc(31 downto 0)
);
oc_update : process (next_oc, time_min_times_a, radius2, dir, a, clk, clk_en, reset) is
begin
if reset = '1' then
	oc <= (OTHERS => '0');
	time_min_times_a_latch1 <= (OTHERS => '0');
	radius2_latch1 <= (OTHERS => '0');
	dir_latch1 <= (OTHERS => '0');
	a_latch1 <= (OTHERS => '0');
elsif rising_edge(clk) AND clk_en = '1' then
	time_min_times_a_latch1 <= time_min_times_a;
	radius2_latch1 <= radius2;
	dir_latch1 <= dir;
	oc <= next_oc;
	a_latch1 <= a;
end if;
end process;

vecdot_b : vector_dot port map(
	clk => clk,
	clk_en => clk_en,
	reset => reset,
	
	x_1 => oc(95 downto 64),
	y_1 => oc(63 downto 32),
	z_1 => oc(31 downto 0),
	
	x_2 => dir_latch1(95 downto 64),
	y_2 => dir_latch1(63 downto 32),
	z_2 => dir_latch1(31 downto 0),
	
	result => b
);
vecsquare_c : vector_square port map (
	clk => clk,
	clk_en => clk_en,
	reset => reset,
	x => oc(95 downto 64),
	y => oc(63 downto 32),
	z => oc(31 downto 0),
	
	result => almost_c
);

vecsquare_par_odd : process (time_min_times_a_latch2, radius2_latch2, radius2_latch4, 
time_min_times_a_latch4, a_latch2, a_latch4, clk, reset, clk_en)
is
begin
if reset = '1' then
	time_min_times_a_latch3 <= (OTHERS => '0');
	radius2_latch3 <= (OTHERS => '0');
	a_latch3 <= (OTHERS => '0');
	time_min_times_a_latch5 <= (OTHERS => '0');
	radius2_latch5 <= (OTHERS => '0');
	a_latch5 <= (OTHERS => '0');
elsif clk_en = '1' AND rising_edge(clk) then
	time_min_times_a_latch3 <= time_min_times_a_latch2;
	radius2_latch3 <= radius2_latch2;
	a_latch3 <= a_latch2;
	time_min_times_a_latch5 <= time_min_times_a_latch4;
	radius2_latch5 <= radius2_latch4;
	a_latch5 <= a_latch4;
end if;
end process;

vecsquare_par_even : process (time_min_times_a_latch1, radius2_latch1, dir_latch1 , 
time_min_times_a_latch3, radius2_latch3,  clk, reset, clk_en,
a_latch1, a_latch3)
is
begin
if reset = '1' then
	time_min_times_a_latch2 <= (OTHERS => '0');
	radius2_latch2 <= (OTHERS => '0');
	a_latch2 <= (OTHERS => '0');
	time_min_times_a_latch4 <= (OTHERS => '0');
	radius2_latch4 <= (OTHERS => '0');
	a_latch4 <= (OTHERS => '0');
elsif clk_en = '1' AND rising_edge(clk) then
	time_min_times_a_latch2 <= time_min_times_a_latch1;
	radius2_latch2 <= radius2_latch1;
	a_latch2 <= a_latch1;
	time_min_times_a_latch4 <= time_min_times_a_latch3;
	radius2_latch4 <= radius2_latch3;
	a_latch4 <= a_latch3;
end if;
end process;

c_sub : sub port map (
	dataa => almost_c,
	datab => radius2_latch5,
	result => next_c
);

c_sub_cal : process (reset, clk, clk_en, a_latch5, time_min_times_a_latch5, next_c, b) is
begin
	if reset = '1' then
		a_latch6 <= (OTHERS => '0');
		time_min_times_a_latch6 <= (OTHERS => '0');
		c <= (OTHERS => '0');
		b_latch1 <= (OTHERS => '0');
	elsif rising_edge(clk) AND clk_en = '1' then
		a_latch6 <= a_latch5;
		time_min_times_a_latch5 <= time_min_times_a_latch5;
		c <= next_c;
		b_latch1 <= b;
	end if;
end process;

square_b : square port map (
	aclr => reset,
	clock => clk,
	dataa => b_latch1,
	ena => clk_en,
	result(63) => b_sq(31),
	result(62 downto 47) => open,
	result(46 downto 16) => b_sq(30 downto 0),
	result(15 downto 0) => open
);

mul_ac : lpm_mult GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=9",
		lpm_pipeline => 1,
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
		dataa => a_latch6,
		datab => c,
		result(63) => ac(31),
		result(62 downto 47) => open,
		result(46 downto 16) => ac(30 downto 0),
		result(15 downto 0) => open
	);

	
mul_ac_par : process (clk, clk_en, reset, time_min_times_a_latch6, b_latch1) is begin

if reset = '1' then 
	time_min_times_a_latch7 <= (OTHERS => '0');
	b_latch2 <= (OTHERS => '0');
elsif rising_edge(clk) and clk_en = '1' then
	time_min_times_a_latch7 <= time_min_times_a_latch6;
	b_latch2 <= b_latch1;
end if;
end process;

ac_b_sq_sub : sub port map (
	dataa => b_sq,
	datab => ac,
	result => next_discr
);

ac_b2_sub_par : process (next_discr, time_min_times_a_latch7, b_latch2, reset, clk, clk_en) is begin
if reset = '1' then
	discr <= (OTHERS => '0');
	time_min_times_a_latch8 <= (OTHERS => '0');
	b_latch3 <= (OTHERS => '0');
elsif rising_edge(clk) AND clk_en = '1' then
	discr <= next_discr;
	time_min_times_a_latch8 <= time_min_times_a_latch7;
	b_latch3 <= b_latch2;
end if;
end process;

sqrt : ip_sqrt 
	PORT MAP
	(
		aclr => reset,
		clk => clk,
		radical(47 downto 16) => discr,
		radical(15 downto 0) => (OTHERS => '0'),
		q => discr_after_sqrt,
		remainder => open
	);
END ip_sqrt;

sqr_par : process(clk, clk_en, reset) is begin
if reset = 1 then
	time_min_times_a_latch9 <= (OTHERS => '0');
	time_min_times_a_latch10 <= (OTHERS => '0');
	time_min_times_a_latch11 <= (OTHERS => '0');
	time_min_times_a_latch12 <= (OTHERS => '0');
	time_min_times_a_latch13 <= (OTHERS => '0');
	time_min_times_a_latch14 <= (OTHERS => '0');
	time_min_times_a_latch15 <= (OTHERS => '0');
	time_min_times_a_latch16 <= (OTHERS => '0');
	time_min_times_a_latch17 <= (OTHERS => '0');
	time_min_times_a_latch18 <= (OTHERS => '0');
	time_min_times_a_latch19 <= (OTHERS => '0');
	time_min_times_a_latch20 <= (OTHERS => '0');
	time_min_times_a_latch21 <= (OTHERS => '0');
	time_min_times_a_latch22 <= (OTHERS => '0');
	time_min_times_a_latch23 <= (OTHERS => '0');
	time_min_times_a_latch24 <= (OTHERS => '0');
	b_latch4 <= (OTHERS => '0');
	b_latch5 <= (OTHERS => '0');
	b_latch6 <= (OTHERS => '0');
	b_latch7 <= (OTHERS => '0');
	b_latch8 <= (OTHERS => '0');
	b_latch9 <= (OTHERS => '0');
	b_latch10 <= (OTHERS => '0');
	b_latch11 <= (OTHERS => '0');
	b_latch12 <= (OTHERS => '0');
	b_latch13 <= (OTHERS => '0');
	b_latch14 <= (OTHERS => '0');
	b_latch15 <= (OTHERS => '0');
	b_latch16 <= (OTHERS => '0');
	b_latch17 <= (OTHERS => '0');
	b_latch18 <= (OTHERS => '0');
	b_latch19 <= (OTHERS => '0');
elsif rising_edge(clk) AND clk_en = '1' then
	time_min_times_a_latch9 <= time_min_times_a_latch8;
	time_min_times_a_latch10 <= time_min_times_a_latch9;
	time_min_times_a_latch11 <= time_min_times_a_latch10;
	time_min_times_a_latch12 <= time_min_times_a_latch11;
	time_min_times_a_latch13 <= time_min_times_a_latch12;
	time_min_times_a_latch14 <= time_min_times_a_latch13;
	time_min_times_a_latch15 <= time_min_times_a_latch14;
	time_min_times_a_latch16 <= time_min_times_a_latch15;
	time_min_times_a_latch17 <= time_min_times_a_latch16;
	time_min_times_a_latch18 <= time_min_times_a_latch17;
	time_min_times_a_latch19 <= time_min_times_a_latch18;
	time_min_times_a_latch20 <= time_min_times_a_latch19;
	time_min_times_a_latch21 <= time_min_times_a_latch20;
	time_min_times_a_latch22 <= time_min_times_a_latch21;
	time_min_times_a_latch23 <= time_min_times_a_latch22;
	time_min_times_a_latch24 <= time_min_times_a_latch23;
	b_latch4 <= b_latch3;
	b_latch5 <= b_latch4;
	b_latch6 <= b_latch5;
	b_latch7 <= b_latch6;
	b_latch8 <= b_latch7;
	b_latch9 <= b_latch8;
	b_latch10 <= b_latch9;
	b_latch11 <= b_latch10;
	b_latch12 <= b_latch11;
	b_latch13 <= b_latch12;
	b_latch14 <= b_latch13
	b_latch15 <= b_latch14;
	b_latch16 <= b_latch15;
	b_latch17 <= b_latch16;
	b_latch18 <= b_latch17;
	b_latch19 <= b_latch18;
end if;
end process;



end architecture;

