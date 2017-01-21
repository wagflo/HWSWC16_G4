library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library lpm;
use lpm.lpm_components.all;

entity vecMulS is

PORT (
    clk : in std_logic;
	clk_en : in std_logic;
	reset : in std_logic;

	x, y, z : in std_logic_vector(31 DOWNTO 0);
	
	scalar : in std_logic_vector(31 DOWNTO 0);
	
	x_res, y_res, z_res : out std_logic_vector(31 DOWNTO 0)
	
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
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
	);
	END COMPONENT;

signal dummy1, dummy2, dummy3 : std_logic_vector(31 downto 0);

begin

x_mul : lpm_mult GENERIC MAP (
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
		dataa => x,
		datab => scalar,
		result(63) => x_res(31),
		result(62 downto 47) => dummy1(31 downto 16),
		result(46 downto 16) => x_res(30 downto 0),
		result(15 downto 0) => dummy1(15 downto 0)
	);
y_mul : lpm_mult GENERIC MAP (
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
		dataa => y,
		datab => scalar,
		result(63) => y_res(31),
		result(62 downto 47) => dummy2(31 downto 16),
		result(46 downto 16) => y_res(30 downto 0),
		result(15 downto 0) => dummy2(15 downto 0)
	);
z_mul : lpm_mult GENERIC MAP (
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
		dataa => z,
		datab => scalar,
		result(63) => z_res(31),
		result(62 downto 47) => dummy3(31 downto 16),
		result(46 downto 16) => z_res(30 downto 0),
		result(15 downto 0) => dummy3(15 downto 0)
	);

end architecture;
