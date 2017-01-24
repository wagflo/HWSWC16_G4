library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library lpm;
use lpm.lpm_components.all;

entity vecMulS is

GENERIC (INPUT_WIDTH : NATURAL := 32; OUTPUT_WIDTH : NATURAL := 32);

PORT (
	x, y, z : in std_logic_vector(INPUT_WIDTH-1 DOWNTO 0);
	scalar : in std_logic_vector(INPUT_WIDTH-1 DOWNTO 0);
	
	x_res, y_res, z_res : out std_logic_vector(OUTPUT_WIDTH-1 DOWNTO 0);

	clk, clk_en, reset : in std_logic	
);

end vecMulS;

architecture arch of vecMulS is

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
			dataa	: IN STD_LOGIC_VECTOR (INPUT_WIDTH-1 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (INPUT_WIDTH-1 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (INPUT_WIDTH*2-1 DOWNTO 0)
	);
	END COMPONENT;
signal subwire1, subwire0, subwire2 : std_logic_vector(INPUT_WIDTH*2-1 downto 0);

constant MULT_OPEN_1 : NATURAL := 2*INPUT_WIDTH - 1 - (2*INPUT_WIDTH - OUTPUT_WIDTH)/2;
constant MULT_OPEN_2 : NATURAL := (2*INPUT_WIDTH - OUTPUT_WIDTH)/2;

begin

x_res(OUTPUT_WIDTH-1) <= subwire0(INPUT_WIDTH*2-1);
x_res(OUTPUT_WIDTH-2 DOWNTO 0) <= subwire0(MULT_OPEN_1-1 DOWNTO MULT_OPEN_2);
y_res(OUTPUT_WIDTH-1) <= subwire1(INPUT_WIDTH*2-1);
y_res(OUTPUT_WIDTH-2 DOWNTO 0) <= subwire1(MULT_OPEN_1-1 DOWNTO MULT_OPEN_2);
z_res(OUTPUT_WIDTH-1) <= subwire2(INPUT_WIDTH*2-1);
z_res(OUTPUT_WIDTH-2 DOWNTO 0) <= subwire2(MULT_OPEN_1-1 DOWNTO MULT_OPEN_2);

x_mul : lpm_mult GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=9",
		lpm_pipeline => 2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => INPUT_WIDTH,
		lpm_widthb => INPUT_WIDTH,
		lpm_widthp => INPUT_WIDTH*2
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => x,
		datab => scalar,
		result => subwire0
	);
y_mul : lpm_mult GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=9",
		lpm_pipeline => 2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => INPUT_WIDTH,
		lpm_widthb => INPUT_WIDTH,
		lpm_widthp => INPUT_WIDTH*2
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => y,
		datab => scalar,
		result => subwire1
	);
z_mul : lpm_mult GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=9",
		lpm_pipeline => 2,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => INPUT_WIDTH,
		lpm_widthb => INPUT_WIDTH,
		lpm_widthp => INPUT_WIDTH*2
	)
	PORT MAP (
		aclr => reset,
		clken => clk_en,
		clock => clk,
		dataa => z,
		datab => scalar,
		result => subwire2
	);

end architecture;
