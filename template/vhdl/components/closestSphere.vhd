library ieee;
use ieee.std_logic_1164.all;

entity closestSphere is
  generic (
	 TIME_MIN : std_logic_vector(15 downto 0) := x"199A";
  );

  port
    (
      clk   : in std_logic;
      res_n : in std_logic;

      start	: in std_logic;

 	  --i_in		: in std_logic_vector(3 downto 0);

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

	  last_t	: in std_logic_vector(31 downto 0);

	  t			: out std_logic_vector(31 downto 0);
	  i_out		: out std_logic_vector(2 downto 0);
	  done		: out std_logic

      );

end entity;

architecture structural of closestSphere is

	signal start_comp 	: std_logic;

 	  --i_in		: in std_logic_vector(3 downto 0);

	signal origin_comp	: std_logic_vector(95 downto 0);
	signal dir_comp     : std_logic_vector(95 downto 0);

    signal center_1, center_2, center_3, center_4  		: std_logic_vector(95 downto 0);
    signal radius2_1, radius2_2, radius2_3, radius2_4 	: std_logic_vector(31 downto 0);

    signal last_t		: std_logic_vector(31 downto 0);
	
	signal time_min_times_a_comp : std_logic_vector(31 downto 0);


	component sphereDistance is 
	  port
		(
		  clk   : in std_logic;
		  res_n : in std_logic;

	 	  --i_in		: in std_logic_vector(3 downto 0);

		  origin    : in std_logic_vector(95 downto 0);
		  dir       : in std_logic_vector(95 downto 0);

		  a			: in std_logic_vector(31 downto 0); --moeglicherweise verzoegerter Input

		  center    : in std_logic_vector(95 downto 0);
		  radius2   : in std_logic_vector(31 downto 0);

		  time_min_times_a : in std_logic_vector(31 downto 0);

		  t			: out std_logic_vector(31 downto 0);
		  --i_out		: out std_logic_vector(3 downto 0);

		  );
	end component;

begin

	check1 : sphereDistance
    port map (

		clk => clk,
		res_n => res_n,
		origin => origin,
		dir => dir,
		center => center1,
		radius2 => radius2_1
	  )

end architecture;

