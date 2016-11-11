
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
USE lpm.lpm_components.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

entity avalon_mm_sqrt is
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		--memory mapped slave
		address   : in  std_logic_vector(0 downto 0);
		write     : in  std_logic;
		read      : in  std_logic;
		writedata : in  std_logic_vector(31 downto 0);
		readdata  : out std_logic_vector(31 downto 0)
	);
end entity;


architecture rtl of avalon_mm_sqrt is
component ip_sqrt PORT
	(
		aclr		: IN STD_LOGIC ;
		clk		: IN STD_LOGIC ;
		radical		: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		q		: OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
		remainder		: OUT STD_LOGIC_VECTOR (24 DOWNTO 0)
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
signal sqrt_res : std_logic_vector(23 downto 0);
signal write_data, next_readdata, rdata : std_logic_vector(31 downto 0);
signal op_done : std_logic_vector(15 downto 0) := (OTHERS => '0');
signal R, W, E, F, shift_bit, next_rd, next_wr : std_logic;
begin
ip : ip_sqrt port map (
  aclr => res_n, 
  clk => clk, 
  radical(47 downto 16) => writedata,
  radical(15 downto 0) => (OTHERS => '0'), --multiply with 2^32 - get result*2^16 (which is wanted)
  q => sqrt_res);
fifo : alt_fwft_fifo generic map (
  DATA_WIDTH => 32, 
  NUM_ELEMENTS => 16)
port map (
	aclr => res_n, 
	clock => clk, 
	data(31 downto 24) => (OTHERS => '0'),
	data(23 downto 0) => sqrt_res,
	rdreq => R,
	wrreq => W,
	empty => E,
	full => F, 
	q => rdata);
shift_bit <= write AND NOT(address(0)) AND NOT(F);
next_rd <= read AND address(0) AND NOT(E);
next_wr <= op_done(0) AND NOT(F);
next_readdata(31 downto 1) <= (OTHERS => '0');
next_readdata(0) <= E;
update : process(clk, res_n) is
begin
	if res_n = '1' then
		W <= '0';
		R <= next_rd;
		write_data <= (OTHERS => '0');
		op_done <= (OTHERS => '0');
		readdata <= (OTHERS => '0');
	elsif rising_edge(clk) then
		W <= next_wr;
		R <= next_rd;
		op_done(14 downto 0) <= op_done(15 downto 1);
		op_done(15) <= shift_bit;
		if address(0) = '0' then
		  readdata <= next_readdata;
		else
		  readdata <= rdata;
		end if;
	end if;
end process;
end architecture;

