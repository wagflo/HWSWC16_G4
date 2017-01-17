library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library lpm;
use lpm.lpm_components.all;

entity vector_square is
port (
	clk : in std_logic;
	clk_en : in std_logic;
	reset : in std_logic;
	
	x, y, z : in std_logic_vector(31 downto 0);
	
	result : out std_logic_vector (31 downto 0)
);

end entity;

architecture arch of vector_square is
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

COMPONENT add
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END COMPONENT;

signal x_sq, y_sq, z_sq, z_par, add1_a, add1_b, add1_res, add2_a, add2_b, add2_res, next_add2_b
	: std_logic_vector(31 downto 0);

begin
x2 : square port map (
	aclr => reset,
	clock => clk,
	dataa => x,
	ena => clk_en,
	result(63) => x_sq(31),
	result(62 downto 47) => open,
	result(46 downto 16) => x_sq(30 downto 0),
	result(15 downto 0) => open
);
y2 : square port map (
	aclr => reset,
	clock => clk,
	dataa => y,
	ena => clk_en,
	result(63) => y_sq(31),
	result(62 downto 47) => open,
	result(46 downto 16) => y_sq(30 downto 0),
	result(15 downto 0) => open
);
z2 : square port map (
	aclr => reset,
	clock => clk,
	dataa => z,
	ena => clk_en,
	result(63) => z_sq(31),
	result(62 downto 47) => open,
	result(46 downto 16) => z_sq(30 downto 0),
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

next_add2_b <= z_par;

update : process(clk, clk_en, x_sq, y_sq, z_sq, add1_res, add1_res, add2_res, next_add2_b) is 
begin
	if reset = '1' then
		add1_a <= (OTHERS => '0');
		add1_b <= (OTHERS => '0');
		z_par <= (OTHERS => '0');
		add2_a <= (OTHERS => '0');
		add2_b <= (OTHERS => '0');
		result <= (OTHERS => '0');
	elsif (clk_en = '1') AND rising_edge(clk) then
		add1_a <= x_sq;
		add1_b <= y_sq;
		z_par <= z_sq;
		add2_a <= add1_res;
		add2_b <= next_add2_b;
		result <= add2_res;
	end if;

end process;



end architecture;
