library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

  function "and"(a : vector; b : std_logic_vector(31 downto 0)) return vector;

  function to_std_logic(input : vector) return std_logic_vector;

  function toscalar(input : std_logic_vector(31 downto 0)) return scalar;

  function to_std_logic(input : scalar) return std_logic_vector;

  function "+"(a, b : vector) return vector;

  type sphere is record
	center : vector;
	radius : std_logic_vector(31 downto 0);
	radius2 : std_logic_vector(31 downto 0);
	colour : vector;
	emitting : std_logic;
  end record;

  type sCInputSpheres is record
	center : vector;
	radius2 : std_logic_vector(31 downto 0);
  end record;

  type sCInputSpheresArray is array(15 downto 0) of sCInputSpheres;
  function to_sCInputSpheres(input : sphere) return sCInputSpheres;

  type scInput is record
	spheres : sCInputSpheresArray;
	activeSpheres : std_logic_vector(15 downto 0);
	num_spheres : std_logic_vector(3 downto 0);
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
	num_spheres, num_reflects, num_samples : std_logic_vector(7 downto 0);
	spheres : sphere_array;
	sphere_enable : std_logic_vector(15 downto 0);
  end record;

 function to_scInput(input : scene) return scInput;

  type ray is record

        color : vector;
	origin, direction : vector;

	remaining_reflects : std_logic_vector(2 downto 0);

	
	sob, eob, copy, pseudo_refl, valid : std_logic;

-- oder 	origin, direction, color : vector; ?


	position : std_logic_vector (21 downto 0);      

  end record;



--  component mul is

--  generic (INPUT_WIDTH : NATURAL := 32; OUTPUT_WIDTH : NATURAL := 32);

--  port (
--	a : in std_logic_vector(INPUT_WIDTH-1 DOWNTO 0);
--	b : in std_logic_vector(INPUT_WIDTH-1 DOWNTO 0);
	
--	res : out std_logic_vector(OUTPUT_WIDTH-1 DOWNTO 0);

--	clk, clk_en, reset : in std_logic	
--  );

--  end component mul;

component sr_ram IS
	GENERIC (
		width		: NATURAL;
		depth		: NATURAL := 3 --needs to be greater than 3  
	);
	PORT
	(
		aclr		: IN STD_LOGIC  := '1';
		clken		: IN STD_LOGIC  := '1';
		clock		: IN STD_LOGIC ;
		shiftin		: IN STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
		shiftout	: OUT STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
		taps		: OUT STD_LOGIC_VECTOR (width - 1 DOWNTO 0)
	);
END component sr_ram;

component sqrt is

GENERIC (INPUT_WIDTH : NATURAL := 32; OUTPUT_WIDTH : NATURAL := 32);

PORT (
	input : in std_logic_vector(INPUT_WIDTH-1 DOWNTO 0);
	output : out std_logic_vector(OUTPUT_WIDTH-1 DOWNTO 0);

	clk, clk_en, reset : in std_logic	
);
end component sqrt;

component scalarMul is

GENERIC (INPUT_WIDTH : NATURAL := 32; OUTPUT_WIDTH : NATURAL := 32);

PORT (
	a, b : in std_logic_vector(INPUT_WIDTH-1 DOWNTO 0);
	result : out std_logic_vector(OUTPUT_WIDTH-1 DOWNTO 0);

	clk, clk_en, reset : in std_logic	
);

end component scalarMul;


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


function "+"(a, b : vector) return vector is
  variable result : vector;

begin
	result.x := std_logic_vector(signed(a.x) + signed(b.x));
	result.y := std_logic_vector(signed(a.y) + signed(b.y));
	result.z := std_logic_vector(signed(a.z) + signed(b.z));
return result;
end "+";


function "and"(a : vector; b : std_logic_vector(31 downto 0)) return vector is
	variable result : vector;
begin
	result.x := a.x and b;
	result.y := a.y and b;
	result.z := a.z and b;
return result;
end "and";

function to_scInput(input : scene) return scInput is 
	variable result : scInput;
begin
	result.num_spheres := input.num_spheres(3 downto 0);
	result.activeSpheres := input.sphere_enable;
	result.spheres(0) := to_sCInputSpheres(input.spheres(0));
	result.spheres(1) := to_sCInputSpheres(input.spheres(1));
	result.spheres(2) := to_sCInputSpheres(input.spheres(2));
	result.spheres(3) := to_sCInputSpheres(input.spheres(3));
	result.spheres(4) := to_sCInputSpheres(input.spheres(4));
	result.spheres(5) := to_sCInputSpheres(input.spheres(5));
	result.spheres(6) := to_sCInputSpheres(input.spheres(6));
	result.spheres(7) := to_sCInputSpheres(input.spheres(7));
	result.spheres(8) := to_sCInputSpheres(input.spheres(8));
	result.spheres(9) := to_sCInputSpheres(input.spheres(9));
	result.spheres(10) := to_sCInputSpheres(input.spheres(10));
	result.spheres(11) := to_sCInputSpheres(input.spheres(11));
	result.spheres(12) := to_sCInputSpheres(input.spheres(12));
	result.spheres(13) := to_sCInputSpheres(input.spheres(13));
	result.spheres(14) := to_sCInputSpheres(input.spheres(14));
	result.spheres(15) := to_sCInputSpheres(input.spheres(15));
return result;
end to_scInput;

function to_sCInputSpheres(input : sphere) return sCInputSpheres is
	variable result : sCInputSpheres;
begin
	result.center := input.center;
	result.radius2 := input.radius2;
return result;
end to_sCInputSpheres;

end package body;