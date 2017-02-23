library ieee;
use ieee.std_logic_1164.all;

use work.operations_pkg.all;

package components_pkg is

component colorUpdate is 
  port
  (
    clk : in std_logic;
    clk_en : in std_logic;
    reset : in std_logic;


    color_in : vector;
    valid_t  : std_logic;
    sphere_i : std_logic_vector(3 downto 0);

    valid_ray_in : std_logic;

    -- Kugeldaten: Farbe, ws nicht emitting

    color_array : vectorArray;
    
    color_out : out vector;
    valid_color : out std_logic;
    valid_ray_out : out std_logic
  );
end component;

component getRayDirAlt is

port(

    clk 	: in std_logic;
    clk_en 	: in std_logic;
    hold 	: in std_logic;
    reset 	: in std_logic;
    start 	: in std_logic;

    frame	: in std_logic_vector(1 downto 0);

    num_samples : in std_logic_vector(4 downto 0);

    addition_hor : in vector;

    addition_ver : in vector;

    addition_base : in vector;
    
    outputRay 	: out ray;

    done	: out std_logic;
    valid	: out std_logic

  );

end component;

component anyRefl is
  port
  (
    clk 	: in std_logic;
    reset 	: in std_logic;
   
    -- kein clock enable, nehme valid

    num_samples	: in std_logic_vector(4 downto 0); -- one hot: 16, 8, 4, 2, 1
--    max_num_reflect : in std_logic_vector(2 downto 0);


--    reflectedArray	: in std_logic_vector(15 downto 0); -- input of buffered rays
    endOfBundle : in std_logic;
    startOfBundle : in std_logic;

    remaining_reflects : in std_logic_vector(2 downto 0);

    valid_t	: in std_logic;
    --t 		: in std_logic_vector(31 downto 0);
    
    isReflected : out std_logic;
    pseudoReflect : out std_logic;
    valid_data  : out std_logic;

    startOfBundle_out : out std_logic;
    endOfBundle_out : out std_logic
    
  );
end component;

component reflect is 
  port
  (
    clk : in std_logic;
    clk_en : in std_logic;
    reset : in std_logic;

    valid_t  : in std_logic;
    t : in std_logic_vector(31 downto 0);

    sphere_i : std_logic_vector(3 downto 0);

    one_over_rs : scalarArray;
    centers     : vectorArray;

    origin : vector;
    direction : vector;

    new_origin : out vector;
    new_direction : out vector;
    valid_refl  : out std_logic

  );
end component;

component getRayDirOpt is

port(

    clk 	: in std_logic;
    clk_en 	: in std_logic;
    reset 	: in std_logic;
    start 	: in std_logic;

    frame	: in std_logic_vector(1 downto 0);

    num_samples_i : in std_logic_vector(2 downto 0);

    num_samples_j : in std_logic_vector(2 downto 0); 

    addition_hor : in vector;

    addition_ver : in vector;

    addition_base : in vector;
    
    result	: out vector;

    position	: out std_logic_vector (21 downto 0);
    done	: out std_logic

  ); 
end component;

component closestSphere is
  port
    (
      clk   : in std_logic;
      reset : in std_logic;
      
      clk_en : in std_logic;

      start	: in std_logic;

      copy_cycle_active : in std_logic;

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



end package;
