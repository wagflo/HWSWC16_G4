
--					if (nearest_obj != NULL)
--					{
--						vec3Mul (&col_tmp, &col_tmp, &nearest_obj->color);
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
--				/* ray miss or max num reflects reached */
--				if (k == 0 || nearest_obj == NULL)
--				{
--					col_tmp.x[0] = 0;
--					col_tmp.x[1] = 0;
--					col_tmp.x[2] = 0;
--				}
--
--				vec3Add (&col, &col, &col_tmp);

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.operations_pkg.all;



entity colorUpdate is 
  port
  (
    clk : in std_logic;
    clk_en : in std_logic;
    reset : in std_logic;


    color_in : vector;
    valid_t  : std_logic;
    sphere_i : std_logic_vector(3 downto 0);

    -- Kugeldaten: Farbe, ws nicht emitting

    color_array : vectorArray;
    
    color_out : out vector
  );
end entity;

architecture beh of colorUpdate is

  signal index : natural;
  signal hitColor : vector;
  signal color_out_next : vector;

begin

  sync : process

  begin

  if reset = '1' then 

    color_out <= (others => "0");

  elsif rising_edge(clk) then

    color_out <= color_out_next;

  end if;

  end process;

  

  index <= natural(to_integer(unsigned(sphere_i)));

  async : process

  begin

  if valid_t = '1' then 
    hitColor <= color_array(index);
  else 
    hitColor <= (others => "0");
  end if;
  end process;

  mul_x : mul
  port map(

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    a => color_in.x,
    b => hitColor.x,

    res => color_out_next.x
  );

  mul_y : mul
  port map(

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    a => color_in.y,
    b => hitColor.y,

    res => color_out_next.y
  );

  mul_z : mul
  port map(

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    a => color_in.z,
    b => hitColor.z,

    res => color_out_next.z
  );

end architecture;