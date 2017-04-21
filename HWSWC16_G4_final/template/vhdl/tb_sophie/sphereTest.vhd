library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sphereDistanceTB is

end entity;

architecture arch of sphereDistanceTB is

component sphereDistance is
  port
    (
      clk   : in std_logic;
      reset : in std_logic;
		clk_en : in std_logic;

      start : in std_logic;


      origin    : in std_logic_vector(95 downto 0);
      dir       : in std_logic_vector(95 downto 0);

	   a			 : in std_logic_vector(31 downto 0);

      center    : in std_logic_vector(95 downto 0);
      radius2   : in std_logic_vector(31 downto 0);

	   t_min_a : in std_logic_vector(31 downto 0);

	   t			: out std_logic_vector(31 downto 0);
		
	   t_valid		: out std_logic

      );
end component;

signal clk : std_logic := '0';
signal res : std_logic := '1';
signal start, t_valid : std_logic;
signal t, a, radius2, t_min_a : std_logic_vector (31 downto 0);
signal origin, dir, center : std_logic_vector(95 downto 0);

begin

sd : sphereDistance
port map ( clk => clk, clk_en => '1', reset => res, 
start => start, origin => origin, dir => dir, a => a, 
center => center, radius2 => radius2, t_min_a => t_min_a, t => t, t_valid => t_valid
);


clk <= not clk after 10 ns;
res <= '0' AFTER 20 ns;
origin <= X"000000000000000000000000";
dir <= X"000000000001000000000000";
center <= X"000000000005000000000000";
radius2 <= X"00040000";
a <= X"00010000";
t_min_a <= X"00001AAF";

start <= '1';

assert clk = '1';

end architecture;