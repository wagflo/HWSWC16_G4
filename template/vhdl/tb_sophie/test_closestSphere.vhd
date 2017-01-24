library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity closestTB is

end entity;

architecture arch of closestTB is

component closestSphere is
  port
    (
      clk   : in std_logic;
      reset : in std_logic;
      
      clk_en : in std_logic;

      start	: in std_logic;

      origin    : in std_logic_vector(95 downto 0);
      dir       : in std_logic_vector(95 downto 0);

      center_1  : in std_logic_vector(95 downto 0);
      radius2_1 : in std_logic_vector(31 downto 0);

      center_2  : in std_logic_vector(95 downto 0);
      radius2_2 : in std_logic_vector(31 downto 0);

      center_3  : in std_logic_vector(95 downto 0);
      radius2_3 : in std_logic_vector(31 downto 0);

      center_4  : in std_logic_vector(95 downto 0);
      radius2_4 : in std_logic_vector(31 downto 0);

      center_5  : in std_logic_vector(95 downto 0);
      radius2_5 : in std_logic_vector(31 downto 0);

      center_6  : in std_logic_vector(95 downto 0);
      radius2_6 : in std_logic_vector(31 downto 0);

      center_7  : in std_logic_vector(95 downto 0);
      radius2_7 : in std_logic_vector(31 downto 0);

      center_8  : in std_logic_vector(95 downto 0);
      radius2_8 : in std_logic_vector(31 downto 0);
		
      center_9  : in std_logic_vector(95 downto 0);
      radius2_9 : in std_logic_vector(31 downto 0);

      center_10  : in std_logic_vector(95 downto 0);
      radius2_10 : in std_logic_vector(31 downto 0);

      center_11  : in std_logic_vector(95 downto 0);
      radius2_11 : in std_logic_vector(31 downto 0);

      center_12  : in std_logic_vector(95 downto 0);
      radius2_12 : in std_logic_vector(31 downto 0);

      center_13  : in std_logic_vector(95 downto 0);
      radius2_13 : in std_logic_vector(31 downto 0);

      center_14  : in std_logic_vector(95 downto 0);
      radius2_14 : in std_logic_vector(31 downto 0);

      center_15  : in std_logic_vector(95 downto 0);
      radius2_15 : in std_logic_vector(31 downto 0);

      center_16  : in std_logic_vector(95 downto 0);
      radius2_16 : in std_logic_vector(31 downto 0);
		
	second_round : in std_logic;

	spheres : in std_logic_vector(15 downto 0);

	  t			: out std_logic_vector(31 downto 0);
	  i_out		: out std_logic_vector(3 downto 0);
	  done		: out std_logic;
	  valid_t 	: out std_logic);

end component;

signal clk, start : std_logic := '0';
signal reset : std_logic := '1';
signal t : std_logic_vector(31 downto 0);
signal i : std_logic_vector(3 downto 0);
signal done, valid : std_logic;

begin

clk <= not(clk) after 10 ns;
reset <= '0' after 20 ns;

start <= '1';

cl : closestSphere port map (
	clk => clk,
	reset => reset,
	clk_en => '1',
	start => start,
	origin => X"000000000000000000000000",
	dir => X"000000000001000000000000",
	center_1 => X"000000000005000000000000",
	radius2_1 => X"00040000",
	center_2 => X"000000000005000000000000",
	radius2_2 => X"00040000",
	radius2_3 => X"00040000",
	center_3 => X"000000000005000000000000",
	radius2_4 => X"00040000",
	center_4 => X"000000000005000000000000",
	radius2_5 => X"00040000",
	center_5 => X"000000000005000000000000",
	radius2_6 => X"00040000",
	center_6 => X"000000000005000000000000",
	radius2_7 => X"00040000",
	center_7 => X"000000000005000000000000",
	radius2_8 => X"00040000",
	center_8 => X"000000000005000000000000",
	radius2_9 => X"00040000",
	center_9 => X"000000000005000000000000",
	radius2_10 => X"00040000",
	center_10 => X"000000000005000000000000",
	radius2_11 => X"00040000",
	center_11 => X"000000000005000000000000",
	radius2_12 => X"00040000",
	center_12 => X"000000000005000000000000",
	radius2_13 => X"00040000",
	center_13 => X"000000000005000000000000",
	radius2_14 => X"00040000",
	center_14 => X"000000000005000000000000",
	radius2_15 => X"00040000",
	center_15 => X"000000000005000000000000",
	radius2_16 => X"00040000",
	center_16 => X"000000000005000000000000",
	second_round => '0',
	spheres => "0000000000000001",
	t => t,
	i_out => i,
	done => done,
	valid_t => valid
);

end architecture;