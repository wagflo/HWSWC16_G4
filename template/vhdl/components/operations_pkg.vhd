library ieee;
use ieee.std_logic_1164.all;

package operations_pkg is 

  type vector is record

    x, y, z : std_logic_vector(31 DOWNTO 0);  

  end record;

 -- type scalar is array(31 downto 0) of std_logic_vector;

  type scalar is record 

    x : std_logic_vector(31 DOWNTO 0);

  end record;

  type vectorArray is array(15 downto 0) of vector;
  type scalarArray is array(15 downto 0) of scalar;


  function tovector(input : std_logic_vector(95 downto 0)) return vector;

  function to_std_logic(input : vector) return std_logic_vector;

  function toscalar(input : std_logic_vector(31 downto 0)) return scalar;

  function to_std_logic(input : scalar) return std_logic_vector;

  type sphere is record
	center : vector;
	radius : std_logic_vector(31 downto 0);
	radius2 : std_logic_vector(31 downto 0);
  end record;

  type sphere_array is array (15 downto 0) of sphere;

  type frame_info is record
	all_info : std_logic;
	camera_origin : vector;
	addition_base : vector;
	addition_hor : vector;
	addition_ver : vector;
	frame_no : std_logic_vector(1 downto 0);
  end record;

  type frame_array is array(1 downto 0) of frame_info;

  type scene is record
	num_spheres, num_reflects, num_samples_i, num_samples_j : std_logic_vector(7 downto 0);
	spheres : sphere_array;
  end record;



  component mul is

  generic (INPUT_WIDTH : NATURAL := 32; OUTPUT_WIDTH : NATURAL := 32);

  port (
	a : in std_logic_vector(INPUT_WIDTH-1 DOWNTO 0);
	b : in std_logic_vector(INPUT_WIDTH-1 DOWNTO 0);
	
	res : out std_logic_vector(OUTPUT_WIDTH-1 DOWNTO 0);

	clk, clk_en, reset : in std_logic	
  );

  end component mul;


  component vecMulS is

    port (

      clk : in std_logic;
      clk_en : in std_logic;
      reset : in std_logic;

      x, y, z 	: in std_logic_vector(31 DOWNTO 0);
	
      scalar 	: in std_logic_vector(31 DOWNTO 0);
	
      x_res, y_res, z_res : out std_logic_vector(31 DOWNTO 0)
	
    );

  end component vecMulS;

  component vector_add_sub is

    generic(
      DATA_WIDTH : NATURAL := 32
    );
    port (
      x1, y1, z1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
      x2, y2, z2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
      add_sub, reset, clk, clk_en : in std_logic;
	
      x, y, z : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );

  end component;

  component vector_dot is
  
    generic (
      INPUT_WIDTH : NATURAL := 32;
      OUTPUT_WIDTH : NATURAL := 32
    );
    port (
      clk : in std_logic;
      clk_en : in std_logic;
      reset : in std_logic;
	
      x_1, y_1, z_1 : in std_logic_vector(INPUT_WIDTH - 1 downto 0);
	
      x_2, y_2, z_2 : in std_logic_vector(INPUT_WIDTH - 1 downto 0);
	
      result : out std_logic_vector (OUTPUT_WIDTH - 1 downto 0)
    );

  end component;

  component vector_square is

    generic(
      INPUT_WIDTH : NATURAL := 32;
      OUTPUT_WIDTH : NATURAL := 32
    );
    port (
      clk 	: in std_logic;
      clk_en 	: in std_logic;
      reset 	: in std_logic;
	
      x, y, z : in std_logic_vector(INPUT_WIDTH-1 downto 0);
	
      result 	: out std_logic_vector (OUTPUT_WIDTH-1 downto 0)
    );

  end component;


end package;

package body operations_pkg is
function tovector(input : std_logic_vector(95 downto 0)) return vector is

variable result : vector;

begin
  result.x := input(95 downto 64);
  result.y := input(63 downto 32);
  result.z := input(31 downto  0);

  return result;
end tovector;

function to_std_logic(input : vector) return std_logic_vector is
variable result : std_logic_vector(95 downto 0);

begin
	result(95 downto 64) := input.x;
	result(63 downto 32) := input.y;
	result(31 downto 0) := input.z;
	
	return result;
end to_std_logic;

function toscalar(input : std_logic_vector(31 downto 0)) return scalar is

  variable result : scalar;

begin

  result.x := input(31 downto  0);

  return result;
end toscalar;

function to_std_logic(input : scalar) return std_logic_vector is

  variable result : std_logic_vector(31 downto 0);

begin

  result(31 downto 0) := input.x;
	
  return result;
end to_std_logic;


end package body;