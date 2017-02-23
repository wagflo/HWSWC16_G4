library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library lpm;
use lpm.lpm_components.all;

entity sqrt is

GENERIC (INPUT_WIDTH : NATURAL := 32; OUTPUT_WIDTH : NATURAL := 32);

PORT (
	input : in std_logic_vector(INPUT_WIDTH-1 DOWNTO 0);
	output : out std_logic_vector(OUTPUT_WIDTH-1 DOWNTO 0);

	clk, clk_en, reset : in std_logic	
);

end sqrt;

architecture arch of sqrt is

component lpm_sqrt PORT
	(
		aclr		: IN STD_LOGIC ;
		clk		: IN STD_LOGIC ;
		radical		: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
		remainder		: OUT STD_LOGIC_VECTOR (24 DOWNTO 0)
	);
end component;

signal sqrt_res : std_logic_vector(23 downto 0);
signal write_data, next_readdata, rdata : std_logic_vector(31 downto 0);

begin

sqrt : lpm_sqrt port map (
  aclr => reset, 
  clk => clk, 
  radical(47 downto 16) => input,
  radical(15 downto 0) => (OTHERS => '0'), --multiply with 2^32 - get result*2^16 (which is wanted)
  q => output);

--

end architecture;
