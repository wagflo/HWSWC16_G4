library ieee;
use ieee.std_logic_1164.all;

use work.operations_pkg.all;

package components_pkg is


component readInterface is
  generic
  (
    FIFOSIZE : positive := 8 -- 256 => whole m9k block, zum testen 4 
  );
  port
  (
    clk 	: in std_logic;
    clk_en 	: in std_logic;
    reset 	: in std_logic;
   
    -- kein clock enable, nehme valid

    pixel_address : in std_logic_vector(31 downto 0);
    pixel_color   : in std_logic_vector(23 downto 0);
    valid_data    : in std_logic;

    stall 	  : out std_logic;
    
    slave_address   : in  std_logic_vector(0 downto 0);
    --write     : in  std_logic;
    --writedata : in  std_logic_vector(31 downto 0);
    slave_data 	    : out std_logic_vector(31 downto 0);
    slave_read      : in  std_logic
    --slave_waitreq    : in std_logic
  );
end component;

component writeInterface is
  generic
  (
    FIFOSIZE : positive := 8; -- 256 => whole m9k block, zum testen 4 
    MAXWIDTH : natural := 800;
    MAXHEIGHT : natural := 480
  );
  port
  (
    clk 	: in std_logic;
    clk_en 	: in std_logic;
    reset 	: in std_logic;
   
    -- kein clock enable, nehme valid

    pixel_address : in std_logic_vector(32 downto 0);
    pixel_color   : in std_logic_vector(23 downto 0);
    valid_data    : in std_logic;

    stall 	  : out std_logic;
    finished	  : out std_logic_vector(1 downto 0);
    
    counter0_debug 	: out std_logic_vector(18 downto 0);
    counter1_debug 	: out std_logic_vector(18 downto 0);
    

    master_address   : out  std_logic_vector(31 downto 0);
    --write     : in  std_logic;
    --writedata : in  std_logic_vector(31 downto 0);
    master_colordata : out std_logic_vector(31 downto 0);
    master_write     : out  std_logic;
    byteenable 		: out std_logic_vector(3 downto 0);
    slave_waitreq	 : in std_logic
  );
end component;

component alt_fwft_fifo IS
	generic (
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
END component;

component backend is 
  port
  (
    clk : in std_logic;
    clk_en : in std_logic;
    reset : in std_logic;

    num_samples	: in std_logic_vector(4 downto 0); -- one hot: 16, 8, 4, 2, 1

--    color_in : vector;
    --valid_data  : std_logic;
    --valid_ray   : std_logic; -- aus ray
    --copy_ray    : std_logic;

    --startOfBundle : in std_logic;
    --endOfBundle : in std_logic;

    ray_in : ray; -- with color? and position

    -- Kugeldaten: Farbe, ws nicht emitting

    --memory_address : out std_logic_vector(31 downto 0); --
    color_data : out std_logic_vector(23 downto 0);
    valid_data : out std_logic
  );
end component;

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
    --copy_ray_in : std_logic;

    -- Kugeldaten: Farbe, ws nicht emitting

    color_array : vectorArray;
    
    color_out : out vector;
    valid_color : out std_logic;
    valid_ray_out : out std_logic
  );
end component;

component getRayDirAlt is
generic (
 	MAXWIDTH : natural := 800;
    MAXHEIGHT : natural := 480
);
port(

    clk 	: in std_logic;
    clk_en 	: in std_logic;
    fifo_full   : in std_logic;
    hold 	: in std_logic;
    reset 	: in std_logic;
    start 	: in std_logic;
    valid_data	: in std_logic;

    frame	: in std_logic_vector(1 downto 0);

    num_samples : in std_logic_vector(4 downto 0);

    num_reflects  : in std_logic_vector(2 downto 0);  --MK

    camera_center : in vector; --MK

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
    clk_en 	: in std_logic;
    reset 	: in std_logic;
   
    -- kein clock enable, nehme valid

    num_samples	: in std_logic_vector(4 downto 0); -- one hot: 16, 8, 4, 2, 1
--    max_num_reflect : in std_logic_vector(2 downto 0);


--    reflectedArray	: in std_logic_vector(15 downto 0); -- input of buffered rays
    endOfBundle : in std_logic;
    startOfBundle : in std_logic;

    valid_ray_in : in std_logic;

    remaining_reflects : in std_logic_vector(2 downto 0);
    emitting_sphere : in std_logic;

    valid_t	: in std_logic;
    --t 		: in std_logic_vector(31 downto 0);
    
    isReflected : out std_logic;
    pseudoReflect : out std_logic;
    valid_ray_out  : out std_logic;

    startOfBundle_out : out std_logic;
    endOfBundle_out : out std_logic
    
  );
end component;

component reflect is 
  port
  (
    clk 	: in std_logic;
    clk_en 	: in std_logic;
    reset	: in std_logic;

    valid_t  	: in std_logic;
    t 		: in std_logic_vector(31 downto 0);

    sphere_i 	: in std_logic_vector(3 downto 0);

    valid_ray_in : in std_logic;
    copy_ray_in  : in std_logic;

    one_over_rs : in scalarArray;
    centers     : in vectorArray;

    --emitters : std_logic_vector(15 downto 0); -- noch genaui schauen, wo rein => any Refl

    origin 	: in vector;
    direction 	: in vector;

    new_origin 		: out vector;
    new_direction 	: out vector;
    valid_refl  	: out std_logic;
    valid_ray_out 	: out std_logic;
    copy_ray_out 	: out std_logic

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

component sphereDistance is
  port
    (
      clk   : in std_logic;
      reset : in std_logic;
      clk_en : in std_logic;

      start : in std_logic;


      origin    : in std_logic_vector(95 downto 0);
      dir       : in std_logic_vector(95 downto 0);

      a		: in std_logic_vector(31 downto 0);

      center    : in std_logic_vector(95 downto 0);
      radius2   : in std_logic_vector(31 downto 0);
      t_min_a 	: in std_logic_vector(31 downto 0);
      t		: out std_logic_vector(31 downto 0);
      t_valid	: out std_logic

      );
end component;

component closestSphereNew is 
port (
	clk, reset, clk_en 	: in std_logic;
	dir, origin		: in vector;
	a			: in std_logic_vector(31 downto 0);
	copy, valid		: in std_logic;
	relevantScene		: in scInput;
	t_times_a		: out std_logic_vector(31 downto 0);
	valid_t			: out std_logic;
	closestSphere		: out std_logic_vector(3 downto 0)
	
);
end component;

component picture_data is
	port(
	w : in std_logic;
	address : in std_logic_vector(15 downto 0);
	writedata : in std_logic_vector(31 downto 0);
	frames : out frame_array;
	sc : out scene;
	write_poss : out std_logic;
	clk : in std_logic;
	reset : in std_logic;
	clk_en : in std_logic;
	next_frame : in std_logic;
	start : out std_logic;
	valid_data : out std_logic;
	frames_done : in std_logic_vector(1 downto 0)
	);
end component;

component closestSpherePrep is
port (
	clk, clk_en, reset 	: in std_logic;
	input_direction 	: vector;
	a			: out std_logic_vector(31 downto 0)
);
end component;

end package;
