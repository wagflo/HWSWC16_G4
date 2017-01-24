

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library lpm;
use lpm.lpm_components.all;

entity ci_div is
	port (
		clk   : in std_logic;
		clk_en : in std_logic;
		reset : in std_logic;
		
		dataa : in std_logic_vector(31 downto 0); 
		datab : in std_logic_vector(31 downto 0);
		result : out std_logic_vector(31 downto 0);

		start : in std_logic;
		done : out std_logic;
		
		n : in std_logic_vector(0 downto 0)
	);
end entity;


architecture arch of ci_div is
component lpm_div_gen PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		denom		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		numer		: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		quotient		: OUT STD_LOGIC_VECTOR (47 DOWNTO 0);
		remain		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;
component alt_fwft_fifo	generic (
		DATA_WIDTH : integer := 32;
		NUM_ELEMENTS : integer 
	);
	PORT (
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0)
	);
end component;
signal results_ready : std_logic_vector(47 downto 0) := (OTHERS => '0');
signal res, num_input, next_num_input : std_logic_vector(47 downto 0);
signal R, W, E, F, shift_bit, next_done, next_rd, next_wr, next_start, last_start : std_logic;
signal write_input : std_logic_vector(31 downto 0);
signal wayne : std_logic_vector(15 downto 0);
begin
ip : lpm_div_gen port map (
	aclr => reset,
	clock => clk,
	denom => datab,
	numer(47 downto 16) => dataa(31 downto 0),
    numer(15 downto 0) => (Others => '0'),
	quotient(47 downto 47) => write_input(31 downto 31),
    quotient(30 downto 0) => write_input(30 downto 0),
    quotient (46 downto 31) => wayne,
	remain => open
);

fifo : alt_fwft_fifo generic map (
	DATA_WIDTH => 32,
	NUM_ELEMENTS => 16)
port map (
	aclr => reset,
	clock => clk,
	data => write_input,
	rdreq => R,
	wrreq=> W,
	empty => E,
	full => F,
	q => result
);

shift_bit <= start AND clk_en AND NOT n(0);
next_done <= (start AND clk_en AND NOT n(0) AND NOT F) OR ((start OR last_start) and n(0) AND NOT(E));
next_wr <= results_ready(0) AND NOT(F);
next_rd <= (((start AND clk_en) or last_start) AND n(0)) AND NOT(E);
next_start <= ((start AND clk_en) or last_start) AND n(0) AND E;
update : process(clk, clk_en, reset) is
begin
  if reset = '1' then
	W <= '0';
    R <= '0';
    results_ready <= (OTHERS => '0');
    done <= '0';
    last_start <= '0';
  elsif rising_edge(clk) then
	results_ready(46 downto 0) <= results_ready(47 downto 1);
	results_ready(47) <= shift_bit;
	W <= next_wr;
	--set inputs for fifo
	R <= next_rd;
	--update outputs
	done <= next_done;
	last_start <= next_start;
  end if;
end process;
end architecture;
