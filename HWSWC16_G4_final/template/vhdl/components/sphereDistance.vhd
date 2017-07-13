library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

library lpm;
use lpm.lpm_components.all;

LIBRARY altera_mf;
USE altera_mf.all;

USE work.delay_pkg.all;

entity sphereDistance is
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
end entity;

architecture arch of sphereDistance is

component vector_add_sub is 
GENERIC(DATA_WIDTH : NATURAL := 32);
port (
	x1, y1, z1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	x2, y2, z2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	add_sub, reset, clk, clk_en : in std_logic;
	
	x, y, z : out std_logic_vector(DATA_WIDTH-1 downto 0)
); end component;

component vector_dot is 
generic (INPUT_WIDTH : NATURAL := 32;
OUTPUT_WIDTH : NATURAL := 32);
port (
	clk : in std_logic;
	clk_en : in std_logic;
	reset : in std_logic;
	
	x_1, y_1, z_1 : in std_logic_vector(INPUT_WIDTH - 1 downto 0);
	
	x_2, y_2, z_2 : in std_logic_vector(INPUT_WIDTH - 1 downto 0);
	
	result : out std_logic_vector (OUTPUT_WIDTH - 1 downto 0)
);

end component;

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


COMPONENT lpm_add_sub
	GENERIC (
		lpm_direction		: STRING;
		lpm_hint		: STRING;
		lpm_pipeline		: NATURAL;
		lpm_representation		: STRING;
		lpm_type		: STRING;
		lpm_width		: NATURAL
	);
	PORT (
			aclr 		: IN STD_LOGIC;
			clken		: IN STD_LOGIC;
			add_sub	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	END COMPONENT;

	COMPONENT altsquare
	GENERIC (
		data_width		: NATURAL;
		lpm_type		: STRING;
		pipeline		: NATURAL;
		representation		: STRING;
		result_width		: NATURAL
	);
	PORT (
			aclr	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			data	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			ena	: IN STD_LOGIC ;
			result	: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
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

COMPONENT altsqrt
	GENERIC (
		pipeline		: NATURAL;
		q_port_width		: NATURAL;
		r_port_width		: NATURAL;
		width		: NATURAL;
		lpm_type		: STRING
	);
	PORT (
			aclr	: IN STD_LOGIC ;
			clk	: IN STD_LOGIC ;
			radical	: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
			q	: OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
			remainder	: OUT STD_LOGIC_VECTOR (24 DOWNTO 0)
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
signal dir_cycle1, oc : std_logic_vector(95 downto 0);
signal t2_c27, t1_c27, t_min_a_c26,	
b_c24, b_c6, b, 
a_c6, 
radius2_c5,
almost_c, c, b2, ac, discr, discr_after, t1_cycle27, t2_cycle27, t1, t2, t_inputb
	: std_logic_vector(31 downto 0);
signal valid_cycle27, valid, t1_valid, t2_valid, t2_smaller
: std_logic;
signal subwire0_b2, subwire0_ac : std_logic_vector(63 downto 0);
signal sub_wire0_discr_after : std_logic_vector(23 downto 0);

signal start_shift : std_logic_vector(26 downto 0);
begin

b2(31) <= subwire0_b2(63);
b2(30 downto 0) <= subwire0_b2(46 downto 16);
ac(31) <= subwire0_ac(63);
ac(30 downto 0) <= subwire0_ac(46 downto 16);
discr_after(31 downto 24) <= (OTHERS => '0');
discr_after(23 downto 0) <= sub_wire0_discr_after(23 downto 0);
--t_inputb <= (0 - signed(b_c25));-- std_logic_vector(signed(NOT(b_c25)) + 1);
--start_shift(26) <= NOT(reset) AND start;

sub_oc_c1 : vector_add_sub
generic map(DATA_WIDTH => 32)
port map (
	x1 => origin(95 downto 64),
	y1 => origin(63 downto 32),
	z1 => origin(31 downto 0),
	
	x2 => center(95 downto 64),
	y2 => center(63 downto 32),
	z2 => center(31 downto 0),
	
	x => oc(95 downto 64),
	y => oc(63 downto 32),
	z => oc(31 downto 0),
	clk => clk,
	clk_en => clk_en,
	reset => reset,
	add_sub => '0'
);

delay_t_min_a : delay_element generic map(WIDTH => 32, DEPTH => 26)
port map( clk => clk, clken => clk_en, reset => reset, source => t_min_a, dest => t_min_a_c26
);

delay_dir : delay_element generic map(WIDTH => 96, DEPTH => 1)
port map( clk => clk, clken => clk_en, reset => reset, source => dir, dest => dir_cycle1
);

delay_radius2 : delay_element generic map(WIDTH => 32, DEPTH => 5)
port map(clk => clk, clken => clk_en, reset => reset, source => radius2, dest => radius2_c5
);

delay_b_first : delay_element generic map(WIDTH => 32, DEPTH => 1)
port map (clk => clk, clken => clk_en, reset => reset, source => b, dest => b_c6
);

delay_b_second : delay_element generic map (WIDTH => 32, DEPTH => 18)
port map ( clk => clk, clken => clk_en, reset => reset, source => b_c6, dest => b_c24);

delay_a : delay_element generic map (WIDTH => 32, DEPTH => 6)
port map(clk => clk, clken => clk_en, reset => reset, source => a, dest => a_c6);

delay_t1 : delay_element generic map (WIDTH => 32, DEPTH => 1)
port map(clk => clk, clken => clk_en, reset => reset, source => t1, dest => t1_cycle27);

delay_t2 : delay_element generic map (WIDTH => 32, DEPTH => 1)
port map(clk => clk, clken => clk_en, reset => reset, source => t2, dest => t2_cycle27);

delay_valid : delay_element generic map (WIDTH => 1, DEPTH => 17)
port map(clk => clk, clken => clk_en , reset => reset, source(0)=>valid, dest(0) => valid_cycle27);

vecdot_b_c2to5 : vector_dot port map(
	clk => clk,
	clk_en => clk_en,
	reset => reset,
	
	x_1 => oc(95 downto 64),
	y_1 => oc(63 downto 32),
	z_1 => oc(31 downto 0),
	
	x_2 => dir_cycle1(95 downto 64),
	y_2 => dir_cycle1(63 downto 32),
	z_2 => dir_cycle1(31 downto 0),
	
	result => b
);
vecsquare_c_c2to5 : vector_square port map (
	clk => clk,
	clk_en => clk_en,
	reset => reset,
	x => oc(95 downto 64),
	y => oc(63 downto 32),
	z => oc(31 downto 0),
	
	result => almost_c
);

c_sub_c6 : LPM_ADD_SUB
	GENERIC MAP (
		lpm_direction => "UNUSED",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => 32
	)
	PORT MAP (
		aclr	=> reset,
		clken	=> clk_en, 
		add_sub => '0',
		clock => clk,
		dataa => almost_c,
		datab => radius2_c5,
		result => c
	);

square_b_c7to8 : altsquare
	GENERIC MAP (
		data_width => 32,
		lpm_type => "ALTSQUARE",
		pipeline => 2,
		representation => "SIGNED",
		result_width => 64
	)
	PORT MAP (
		aclr => reset,
		clock => clk,
		data => b_c6,
		ena => clk_en,
		result => subwire0_b2
	);

mul_ac_c7to8 : lpm_mult GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=9",
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
		dataa => a_c6,
		datab => c,
		result => subwire0_ac
	);

discr_c9 : lpm_add_sub
GENERIC MAP (
		lpm_direction => "UNUSED",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => 32
	)
	PORT MAP (
		aclr	=> reset,
		clken	=> clk_en, 
		add_sub => '0',
		clock => clk,
		dataa => b2,
		datab => ac,
		result => discr
	);

discr_g0_c10 : LPM_COMPARE 
	GENERIC MAP (
		lpm_hint => "ONE_INPUT_IS_CONSTANT=YES",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_COMPARE",
		lpm_width => 32
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => discr,
		datab => (OTHERS => '0'),
		agb => valid
	);
	
	
sqrt_c10to25 : ALTSQRT
	GENERIC MAP (
		pipeline => 16,
		q_port_width => 24,
		r_port_width => 25,
		width => 48,
		lpm_type => "ALTSQRT"
	)
	PORT MAP (
		aclr => reset,
		clk => clk,
		radical(47 downto 16) => discr,
		radical(15 downto 0) => (OTHERS => '0'),
		q => sub_wire0_discr_after,
		remainder => open
	);

t_inputb_c25 : lpm_add_sub
GENERIC MAP (
		lpm_direction => "UNUSED",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=YES,CIN_USED=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => 32
	)
	PORT MAP (
		aclr	=> reset,
		clken	=> clk_en, 
		add_sub => '0',
		clock => clk,
		dataa => (OTHERS => '0'),
		datab => b_c24,
		result => t_inputb
	);
	
t1_c26 : lpm_add_sub GENERIC MAP (
		lpm_direction => "UNUSED",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => 32
	)
	PORT MAP (
		aclr	=> reset,
		clken	=> clk_en, 
		add_sub => '0',
		clock => clk,
		dataa => t_inputb,
		datab => discr_after,
		result => t1
	);

t2_c26 : lpm_add_sub GENERIC MAP (
		lpm_direction => "UNUSED",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => 32
	)
	PORT MAP (
		aclr	=> reset,
		clken	=> clk_en, 
		add_sub => '1',
		clock => clk,
		dataa => t_inputb,
		datab => discr_after,
		result => t2
	);
t1_g_timemin_c27 : LPM_COMPARE 
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
		datab => t_min_a_c26,
		agb => t1_valid
	);
t2_g_timemin_c27: LPM_COMPARE 
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
		dataa => t2,
		datab => t_min_a_c26,
		agb => t2_valid
	);

t1_g_t2_c27 :LPM_COMPARE 
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


output : process(t1_valid, t2_valid, t2_smaller, t1_cycle27, t2_cycle27, start_shift(0)) is begin
if 
--valid_cycle27 = '1' AND 
start_shift(0) = '1' then
	if t1_valid = '1' AND t2_valid = '1' then
		if t2_smaller = '0' then
			t_valid <= '1';
			t <= t1_cycle27;
		else
			t_valid <= '1';
			t <= t2_cycle27;
		end if;
	elsif t1_valid = '1' then
		t_valid <= '1';
		t <= t1_cycle27;
	elsif t2_valid = '1' then
		t_valid <= '1';
		t <= t2_cycle27;
	else 
		t_valid <= '0';
		t <= (OTHERS => '0');
	end if;
else
	t_valid <= '0';
	t <= (OTHERS => '0');
end if;
end process;

shift : process(clk_en, clk, reset) is begin
if reset = '1' then
	start_shift <= (OTHERS=>'0');
elsif clk_en = '1' AND rising_edge(clk) then
	start_shift <= start & start_shift(26 downto 1);
 end if;
end process;


	
end architecture;

