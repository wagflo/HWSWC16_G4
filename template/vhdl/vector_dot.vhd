library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library lpm;
use lpm.lpm_components.all;

entity vector_dot is
port (
	clk : in std_logic;
	clk_en : in std_logic;
	reset : in std_logic;
	
	x_1, y_1, z_1 : in std_logic_vector(31 downto 0);
	
	x_2, y_2, z_2 : in std_logic_vector(31 downto 0);
	
	result : out std_logic_vector (31 downto 0)
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
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
	);
	END COMPONENT;
	
COMPONENT add
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END COMPONENT;


signal x_mul, y_mul, z_mul, add1_a, add1_b, add1_res, z_mul_par, add2_a, add2_b, add2_res, next_add2_b
	: std_logic_vector(31 downto 0);

begin
x_mult : lpm_mult GENERIC MAP (
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
		dataa => x_1,
		datab => x_2,
		result(63) => x_mul(31),
		result(62 downto 47) => open,
		result(46 downto 16) => x_mul(30 downto 0),
		result(15 downto 0) => open
	);
y_mult : lpm_mult GENERIC MAP (
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
		dataa => y_1,
		datab => y_2,
		result(63) => y_mul(31),
		result(62 downto 47) => open,
		result(46 downto 16) => y_mul(30 downto 0),
		result(15 downto 0) => open
	);
z_mult : lpm_mult GENERIC MAP (
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
		dataa => z_1,
		datab => z_2,
		result(63) => z_mul(31),
		result(62 downto 47) => open,
		result(46 downto 16) => z_mul(30 downto 0),
		result(15 downto 0) => open
	);
add1 : add port map(
	dataa => add1_a,
	datab => add1_b,
	result => add1_res
);
add2 : add port map(
	dataa => add2_a,
	datab => add2_b,
	result => add2_res
);

next_add2_b <= z_mul_par;

update : process(clk, clk_en, x_mul, y_mul, z_mul, add1_res, add1_res, add2_res, next_add2_b) is 
begin
	if reset = '1' then
		add1_a <= (OTHERS => '0');
		add1_b <= (OTHERS => '0');
		z_mul_par <= (OTHERS => '0');
		add2_a <= (OTHERS => '0');
		add2_b <= (OTHERS => '0');
		result <= (OTHERS => '0');
	elsif (clk_en = '1') AND rising_edge(clk) then
		add1_a <= x_mul;
		add1_b <= y_mul;
		z_mul_par <= z_mul;
		add2_a <= add1_res;
		add2_b <= next_add2_b;
		result <= add2_res;
	end if;

end process;

end architecture;