library ieee;
use ieee.std_logic_1164.all;

entity sphereDistance is
  port
    (
      clk   : in std_logic;
      res_n : in std_logic;

      start : in std_logic;

 	  --i_in		: in std_logic_vector(3 downto 0);

      origin    : in std_logic_vector(95 downto 0);
      dir       : in std_logic_vector(95 downto 0);

	  a			: in std_logic_vector(31 downto 0);

      center    : in std_logic_vector(95 downto 0);
      radius2   : in std_logic_vector(31 downto 0);

	  time_min_times_a : in std_logic_vector(31 downto 0);

	  t			: out std_logic_vector(31 downto 0);
	  --i_out		: out std_logic_vector(3 downto 0);
	  done		: out std_logic

      );
end entity;

