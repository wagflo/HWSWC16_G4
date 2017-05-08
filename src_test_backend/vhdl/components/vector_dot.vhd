library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;


library lpm;
use lpm.lpm_components.all;

entity vector_dot is
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

end entity;

architecture arch of vector_dot is

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
			dataa	: IN STD_LOGIC_VECTOR (INPUT_WIDTH - 1 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (INPUT_WIDTH - 1 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (2*INPUT_WIDTH - 1 DOWNTO 0)
	);
	END COMPONENT;
	
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
			aclr	: IN STD_LOGIC ;
			clken	: IN STD_LOGIC ;
			add_sub	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			dataa	: IN STD_LOGIC_VECTOR (OUTPUT_WIDTH - 1 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (OUTPUT_WIDTH - 1 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (OUTPUT_WIDTH - 1 DOWNTO 0)
	);
	END COMPONENT;
signal x_mul, y_mul, z_mul, add1_res, z_mul_par
	: std_logic_vector(OUTPUT_WIDTH - 1 DOWNTO 0);
	
signal subwire0, subwire1, subwire2 : std_logic_vector(2*INPUT_WIDTH - 1 DOWNTO 0);

constant MULT_OPEN_1 : NATURAL := 2*INPUT_WIDTH - 1 - (2*INPUT_WIDTH - OUTPUT_WIDTH)/2;
constant MULT_OPEN_2 : NATURAL := (2*INPUT_WIDTH - OUTPUT_WIDTH)/2;

	
begin

x_mul(OUTPUT_WIDTH -1) <= subwire0(INPUT_WIDTH*2 - 1);
x_mul(OUTPUT_WIDTH -2 DOWNTO 0) <= subwire0(MULT_OPEN_1 - 1 DOWNTO MULT_OPEN_2);
y_mul(OUTPUT_WIDTH -1) <= subwire1(INPUT_WIDTH*2 - 1);
y_mul(OUTPUT_WIDTH -2 DOWNTO 0) <= subwire1(MULT_OPEN_1 - 1 DOWNTO MULT_OPEN_2);
z_mul(OUTPUT_WIDTH -1) <= subwire2(INPUT_WIDTH*2 - 1);
z_mul(OUTPUT_WIDTH -2 DOWNTO 0) <= subwire2(MULT_OPEN_1 - 1 DOWNTO MULT_OPEN_2);


x_mult : lpm_mult GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=9",
		lpm_pipeline => 2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => INPUT_WIDTH,
		lpm_widthb => INPUT_WIDTH,
		lpm_widthp => 2*INPUT_WIDTH
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => x_1,
		datab => x_2,
		result => subwire0
	);
y_mult : lpm_mult GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=9",
		lpm_pipeline => 2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => INPUT_WIDTH,
		lpm_widthb => INPUT_WIDTH,
		lpm_widthp => 2*INPUT_WIDTH
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => y_1,
		datab => y_2,
		result => subwire1
	);
z_mult : lpm_mult GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=9",
		lpm_pipeline => 2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => INPUT_WIDTH,
		lpm_widthb => INPUT_WIDTH,
		lpm_widthp => 2*INPUT_WIDTH
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => z_1,
		datab => z_2,
		result => subwire2
	);
add1 : LPM_ADD_SUB
	GENERIC MAP (
		lpm_direction => "UNUSED",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => OUTPUT_WIDTH
	)
	PORT MAP (
		aclr	=> reset,
		clken	=> clk_en, 
		add_sub => '1',
		clock => clk,
		dataa => x_mul,
		datab => y_mul,
		result => add1_res
	);
add2 : LPM_ADD_SUB
	GENERIC MAP (
		lpm_direction => "UNUSED",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => OUTPUT_WIDTH
	)
	PORT MAP (
		aclr	=> reset,
		clken	=> clk_en, 
		add_sub => '1',
		clock => clk,
		dataa => add1_res,
		datab => z_mul_par,
		result => result
	);

update : process(clk, clk_en, z_mul) is 
begin
	if reset = '1' then
		z_mul_par <= (OTHERS => '0');
	elsif (clk_en = '1') AND rising_edge(clk) then
		z_mul_par <= z_mul;
	end if;

end process;

end architecture;