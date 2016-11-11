library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


LIBRARY lpm;
USE lpm.lpm_components.all;

entity ci_mul is
	port (
		clk   : in std_logic;
		clk_en : in std_logic;
		reset : in std_logic;
		dataa : in std_logic_vector(31 downto 0); 
		datab : in std_logic_vector(31 downto 0);
		result : out std_logic_vector(31 downto 0)
	);
end entity;

architecture arch of ci_mul is

-- part of code generated with IP catalog
	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (63 DOWNTO 0);



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

BEGIN
	result    <= sub_wire0(47 DOWNTO 16);

	lpm_mult_component : lpm_mult
	GENERIC MAP (
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
		dataa => dataa,
		datab => datab,
		result => sub_wire0

	);
end architecture;

