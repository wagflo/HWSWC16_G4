library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;


library lpm;
use lpm.lpm_components.all;

entity vector_square is
generic(INPUT_WIDTH : NATURAL := 32;
OUTPUT_WIDTH : NATURAL := 32);
port (
	clk : in std_logic;
	clk_en : in std_logic;
	reset : in std_logic;
	
	x, y, z : in std_logic_vector(INPUT_WIDTH-1 downto 0);
	
	result : out std_logic_vector (OUTPUT_WIDTH-1 downto 0)
);

end entity;

architecture arch of vector_square is

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
			data	: IN STD_LOGIC_VECTOR (INPUT_WIDTH-1 DOWNTO 0);
			ena	: IN STD_LOGIC ;
			result	: OUT STD_LOGIC_VECTOR (INPUT_WIDTH*2-1 DOWNTO 0)
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

signal x_sq, y_sq, z_sq, z_par, add1_res
	: std_logic_vector(OUTPUT_WIDTH-1 downto 0);
signal subwire0, subwire1, subwire2 : std_logic_vector(INPUT_WIDTH*2-1 downto 0);


constant MULT_OPEN_1 : NATURAL := 2*INPUT_WIDTH - 1 - (2*INPUT_WIDTH - OUTPUT_WIDTH)/2;
constant MULT_OPEN_2 : NATURAL := (2*INPUT_WIDTH - OUTPUT_WIDTH)/2;

begin

x_sq(OUTPUT_WIDTH-1) <= subwire0(2*INPUT_WIDTH-1);
x_sq(OUTPUT_WIDTH-2 DOWNTO 0) <= subwire0(MULT_OPEN_1 - 1 DOWNTO MULT_OPEN_2);
y_sq(OUTPUT_WIDTH-1) <= subwire1(2*INPUT_WIDTH-1);
y_sq(OUTPUT_WIDTH-2 DOWNTO 0) <= subwire1(MULT_OPEN_1 - 1 DOWNTO MULT_OPEN_2);
z_sq(OUTPUT_WIDTH-1) <= subwire2(2*INPUT_WIDTH-1);
z_sq(OUTPUT_WIDTH-2 DOWNTO 0) <= subwire2(MULT_OPEN_1 - 1 DOWNTO MULT_OPEN_2);

x2 : altsquare
	GENERIC MAP (
		data_width => INPUT_WIDTH,
		lpm_type => "ALTSQUARE",
		pipeline => 2,
		representation => "SIGNED",
		result_width => 2*INPUT_WIDTH
	)
	PORT MAP (
		aclr => reset,
		clock => clk,
		data => x,
		ena => clk_en,
		result => subwire0
	);
y2 : altsquare
	GENERIC MAP (
		data_width => INPUT_WIDTH,
		lpm_type => "ALTSQUARE",
		pipeline => 2,
		representation => "SIGNED",
		result_width => 2*INPUT_WIDTH
	)
	PORT MAP (
		aclr => reset,
		clock => clk,
		data => y,
		ena => clk_en,
		result => subwire1
	);
z2 : altsquare
	GENERIC MAP (
		data_width => INPUT_WIDTH,
		lpm_type => "ALTSQUARE",
		pipeline => 2,
		representation => "SIGNED",
		result_width => 2*INPUT_WIDTH
	)
	PORT MAP (
		aclr => reset,
		clock => clk,
		data => z,
		ena => clk_en,
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
		dataa => x_sq,
		datab => y_sq,
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
		dataa => z_par,
		datab => add1_res,
		result => result
	);

update : process(clk, clk_en, z_sq) is 
begin
	if reset = '1' then
		z_par <= (OTHERS => '0');
	elsif (clk_en = '1') AND rising_edge(clk) then
		z_par <= z_sq;
	end if;
end process;



end architecture;
