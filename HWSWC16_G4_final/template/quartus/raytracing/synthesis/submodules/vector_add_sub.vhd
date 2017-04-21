library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library lpm;
use lpm.lpm_components.all;

entity vector_add_sub is
GENERIC(DATA_WIDTH : NATURAL := 32);
port (
	x1, y1, z1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	x2, y2, z2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
	add_sub, reset, clk, clk_en : in std_logic;
	
	x, y, z : out std_logic_vector(DATA_WIDTH-1 downto 0)
);


end entity;

architecture arch of vector_add_sub is
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
			dataa	: IN STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (DATA_WIDTH - 1 DOWNTO 0)
	);
	END COMPONENT;

begin
x_sub : LPM_ADD_SUB
	GENERIC MAP (
		lpm_direction => "UNUSED",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => DATA_WIDTH
	)
	PORT MAP (
		aclr	=> reset,
		clken	=> clk_en, 
		add_sub => add_sub,
		clock => clk,
		dataa => x1,
		datab => x2,
		result => x
	);
y_sub : LPM_ADD_SUB
	GENERIC MAP (
		lpm_direction => "UNUSED",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => DATA_WIDTH
	)
	PORT MAP (
		aclr	=> reset,
		clken	=> clk_en, 
		add_sub => add_sub,
		clock => clk,
		dataa => y1,
		datab => y2,
		result => y
	);
z_sub : LPM_ADD_SUB
	GENERIC MAP (
		lpm_direction => "UNUSED",
		lpm_hint => "ONE_INPUT_IS_CONSTANT=NO,CIN_USED=NO",
		lpm_pipeline => 1,
		lpm_representation => "SIGNED",
		lpm_type => "LPM_ADD_SUB",
		lpm_width => DATA_WIDTH
	)
	PORT MAP (
		aclr	=> reset,
		clken	=> clk_en, 
		add_sub => add_sub,
		clock => clk,
		dataa => z1,
		datab => z2,
		result => z
	);

end architecture;
