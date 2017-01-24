library ieee;
use ieee.std_logic_1164.all;
use work.operations_pkg.all;

entity getRayDir is

  port(

    clk 	: in std_logic;
    clken 	: in std_logic;
    reset 	: in std_logic;
    start 	: in std_logic := '1';

    s, t 					: in std_logic_vector(31 downto 0);
    camera_horizontal, camera_vertical 		: in vector;
    camera_lower_left_corner, camera_origin 	: in vector;
    
    result : out vector
  );

end entity;

architecture beh of getRayDir is

signal scaled_horiz_next, scaled_vert_next, scaled_both_next, point_in_plane_next : vector;
signal scaled_horiz, scaled_vert, scaled_both, point_in_plane : vector;

     constant zero : std_logic_vector(95 downto 0) := (others => '0');
     constant zerovec : vector := tovector(zero);


begin

  Mul1 : vecMulS
  port map(

    clk   => clk,
    clk_en => clken,
    reset => reset,

    x => camera_horizontal.x,
    y => camera_horizontal.y,
    z => camera_horizontal.z,

    scalar => s,

    x_res => scaled_horiz.x,
    y_res => scaled_horiz.y,
    z_res => scaled_horiz.z

  );

  Mul2 : vecMulS
  port map(

    clk   => clk,
    clk_en => clken,
    reset => reset,

    x => camera_vertical.x,
    y => camera_vertical.y,
    z => camera_vertical.z,

    scalar => t,

    x_res => scaled_vert.x,
    y_res => scaled_vert.y,
    z_res => scaled_vert.z

  );

  addVecs : vector_add_sub 
  port map (

    x1 => scaled_vert.x,
    y1 => scaled_vert.y,
    z1 => scaled_vert.z,

    x2 => scaled_horiz.x,
    y2 => scaled_horiz.y,
    z2 => scaled_horiz.z,

    add_sub => '1',
    reset => reset,
    clk => clk,
    clk_en => clken,
	
    x => scaled_both.x,
    y => scaled_both.y,
    z => scaled_both.z

  );

  add_to_lower_left : vector_add_sub 
  port map (

    x1 => scaled_both.x,
    y1 => scaled_both.y,
    z1 => scaled_both.z,

    x2 => camera_lower_left_corner.x,
    y2 => camera_lower_left_corner.y,
    z2 => camera_lower_left_corner.z,

    add_sub => '1',
    reset => reset,
    clk => clk,
    clk_en => clken,
	
    x => point_in_plane.x,
    y => point_in_plane.y,
    z => point_in_plane.z

  );

  point_minus_origin : vector_add_sub 
  port map (

    x1 => point_in_plane.x,
    y1 => point_in_plane.y,
    z1 => point_in_plane.z,

    x2 => camera_origin.x,
    y2 => camera_origin.y,
    z2 => camera_origin.z,

    add_sub => '0',
    reset => reset,
    clk => clk,
    clk_en => clken,
	
    x => result.x,
    y => result.y,
    z => result.z

  );

   sync : process (clk, clken, reset)



     begin
     

     if reset = '1' then

       scaled_horiz <= zerovec;
       scaled_vert <= zerovec;       
       scaled_both <= zerovec;

     end if;
   end process;


end architecture;
