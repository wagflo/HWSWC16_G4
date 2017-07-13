
--					if (nearest_obj != NULL)
--					{
--						vec3Mul (&col_tmp, &col_tmp, &nearest_obj->color); <<<<<<<<<<<<<<<<<<<<<<
--						if (nearest_obj->mat == EMITTING)
--							break;
--						
--						/* if not emitting reflect */
--						/* ray_origin = ray_origin + t * ray_dir */
--						vec3_t tmp;
--						vec3MulS (&tmp, tmin, &ray_dir);
----						vec3Add (&ray_origin, &tmp, &ray_origin);
--						/* n = (ray_origin - center) / radius  */
--						vec3_t n; /* surface normal */
--						vec3Sub (&n, &ray_origin, &nearest_obj->center);
--						//fix16_t rr = nearest_obj->rec_radius;
--						vec3MulS (&n, nearest_obj->rec_radius, &n);
--						reflect (&ray_dir, &ray_dir, &n);
--					}
--					else
--					{
--						/* ray miss */
--v						break;
--					}
--					if (k > 1) {
--					  nearest_obj = getClosestSphere (&tmin, &ray_origin, &ray_dir);
--					}
--				}
--				/* ray miss or max num reflects reached */     <<<<<<<<<<<<<<
--				if (k == 0 || nearest_obj == NULL)             <<<<<<<<<<<<<<
--				{
--					col_tmp.x[0] = 0;                      <<<<
--					col_tmp.x[1] = 0;                      <<<<
--					col_tmp.x[2] = 0;                      <<<<
--				}
--
--				vec3Add (&col, &col, &col_tmp);                <<<<

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.operations_pkg.all;
use work.delay_pkg.all;

--COLOR NULL SETZEN ***********************************************************************
--*****************************************************************************************
--*****************************************************************************************
--*****************************************************************************************
--*****************************************************************************************
--*****************************************************************************************
--*****************************************************************************************
--*****************************************************************************************
--*****************************************************************************************
--*****************************************************************************************
--*****************************************************************************************


entity colorUpdate is 
port (
	--########################################################################
	-- INPUTS
	--########################################################################
	clk		: in std_logic;
	clk_en		: in std_logic;
	reset		: in std_logic;
	color_in	: in vector;
	valid_t		: in std_logic;
	sphere_i	: in std_logic_vector(3 downto 0);
	valid_ray_in	: in std_logic;
	color_array	: in vectorArray;
	--########################################################################
	-- OUTPUTS
	--########################################################################
	color_out	: out vector;
	valid_color	: out std_logic;
	valid_ray_out	: out std_logic
);
end entity;

architecture beh of colorUpdate is

  signal
	index
		: natural;
  signal
	hitColor
		: vector;
  signal
	validities_in_vec,
	validities_out_vec
		: std_logic_vector(1 downto 0);
begin

--########################################################################
-- HELPERS
--########################################################################
validities_in_vec(0) <= valid_t;
validities_in_vec(1) <= valid_ray_in;
index <= natural(to_integer(unsigned(sphere_i)));

async : process(valid_t, index)
begin
	if valid_t = '1' then 
		hitColor <= color_array(index);
	else 
		hitColor <= (others => (others => '0'));
	end if;
end process;


--########################################################################
-- DELAYS
--########################################################################
delay_validities: delay_element
generic map(WIDTH => 2, DEPTH => 2) 
port map (
	clk => clk,
	clken => clk_en,
	reset => reset,
	source => validities_in_vec,
	dest => validities_out_vec
);

--########################################################################
-- LOGIC
--########################################################################

-- cycle 1-2
mul_x : scalarMul
port map (
	clk => clk,
	clk_en => clk_en,
	reset => reset,
	a => color_in.x,
	b => hitColor.x,
	result => color_out.x 
);

mul_y : scalarMul
port map (
	clk => clk,
	clk_en => clk_en,
	reset => reset,
	a => color_in.y,
	b => hitColor.y,
	result => color_out.y
);

mul_z : scalarMul
port map(
	clk => clk,
	clk_en => clk_en,
	reset => reset,
	a => color_in.z,
	b => hitColor.z,
	result => color_out.z --color_out_next.z
);

--########################################################################
-- OUTPUTS
--########################################################################
valid_color <= validities_out_vec(0);
valid_ray_out <= validities_out_vec(1);

end architecture;