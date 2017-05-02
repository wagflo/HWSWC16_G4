library ieee;
use ieee.std_logic_1164.all;
use work.operations_pkg.all;

package getRayDir_pkg is

component getRayDir is

  port(

    clk 	: in std_logic;
    clken 	: in std_logic;
    reset 	: in std_logic;

    s, t 					: in std_logic_vector(31 downto 0);
    camera_horizontal, camera_vertical 		: in vector;
    camera_lower_left_corner, camera_origin 	: in vector;
    
    result : out vector
  );

end component;

end package;