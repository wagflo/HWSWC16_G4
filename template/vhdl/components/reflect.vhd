
--						if (nearest_obj->mat == EMITTING)
--							break;
--						
--						/* if not emitting reflect */
--						/* ray_origin = ray_origin + t * ray_dir */
--						vec3_t tmp;
--						vec3MulS (&tmp, tmin, &ray_dir);
--						vec3Add (&ray_origin, &tmp, &ray_origin);
--						/* n = (ray_origin - center) / radius  */
--						vec3_t n; /* surface normal */
--						vec3Sub (&n, &ray_origin, &nearest_obj->center);
--						//fix16_t rr = nearest_obj->rec_radius;
--						vec3MulS (&n, nearest_obj->rec_radius, &n);
--						reflect (&ray_dir, &ray_dir, &n);
--reflect (vec3_t *r, vec3_t *v, vec3_t *n)
--{
--	vec3_t tmp;
--	fix16_t t = ALT_CI_CI_MUL_0 (fix16_one << 1, vec3Dot (v, n));
--	vec3MulS (&tmp, t, n);
--	vec3Sub (r, v, &tmp);


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.operations_pkg.all;
use work.delay_pkg.all;



entity reflect is 
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
end entity;

architecture beh of reflect is

  signal index_for_center, index_for_one_over_r : natural;
  signal center: vector;
  signal one_over_r, one_over_r_delayed : scalar; --std_logic_vector(31 downto 0);
  signal scaled_dir, hitpoint, normal_vec, unit_normal_vec, scaled_normal_vec : vector;
  signal new_origin_next, new_direction_next : vector;
  signal sphere_i_for_center, sphere_i_for_one_over_r : std_logic_vector(3 downto 0);
  signal valid_t_for_center, valid_t_for_one_over_r : std_logic;
  --signal valid_t_vec, valid_refl_vec : std_logic_vector(0 downto 0);
  signal dot_prod : std_logic_vector(32 downto 0); -- because of factor 2
  signal new_origin_std_logic :std_logic_vector(95 downto 0);

begin

  --valid_t_vec(0) <= valid_t;

  delay_sphere_i_for_center: delay_element generic map(WIDTH => 5, DEPTH => 3) port map (
  clk => clk, clken => clk_en, reset => reset, 
  source(5 downto 1) => sphere_i,
  source(0) => valid_t,
  dest(5 downto 1) => sphere_i_for_center,
  dest(0) => valid_t_for_center
  );

  delay_sphere_i_for_one_over_r: delay_element generic map(WIDTH => 5, DEPTH => 1) port map (
  clk => clk, clken => clk_en, reset => reset, 
  source(5 downto 1) => sphere_i_for_center,
  source(0) => valid_t_for_center,
  dest(5 downto 1) => sphere_i_for_one_over_r,
  dest(0) => valid_t_for_one_over_r
  );


  delay_validity: delay_element generic map(WIDTH => 1, DEPTH => 13) port map (
  clk => clk, clken => clk_en, reset => reset, 
  source(0) => valid_t,
  dest(0) => valid_refl
  );

  index_for_center     <= natural(to_integer(unsigned(sphere_i_for_center)));
  index_for_one_over_r <= natural(to_integer(unsigned(sphere_i_for_one_over_r)));

  async : process

  begin

  if valid_t = '1' then 
    center <= centers(index_for_center);
    one_over_r <= one_over_rs(index_for_one_over_r);
  else 
    center <= tovector(others => "0");
    one_over_r <= toscalar(others => '0');
  end if;
  end process;

  sync : process

  begin

  if reset = '1' then 
    new_origin <= (others => "0");
    new_direction <= (others => "0");
  elsif rising_edge(clk) and clk_en = '1' then
    new_origin <= new_origin_next;
    new_direction <= new_direction_next;
  end if;
  end process;


  mulDir : vecMulS
  port map(

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    x => direction.x,
    y => direction.y,
    z => direction.z,

    scalar => t,

    x_res => scaled_dir.x,
    y_res => scaled_dir.y,
    z_res => scaled_dir.z

  );

  add2origin : vector_add_sub 
  port map (

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    add_sub => '1',

    x1 => origin.x,
    y1 => origin.y,
    z1 => origin.z,

    x2 => scaled_dir.x,
    y2 => scaled_dir.y,
    z2 => scaled_dir.z,

    x => hitpoint.x,
    y => hitpoint.y,
    z => hitpoint.z
  );

  delay_hitpoint: delay_element generic map(WIDTH => 96, DEPTH => 1) port map (
  
    clk => clk, clken => clk_en, reset => reset, 
    source => to_std_logic(hitpoint),
    dest => new_origin_std_logic
  );

  new_origin_next <= tovector(new_origin_std_logic);

  normalVec : vector_add_sub 
  port map (

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    add_sub => '0',

    x1 => hitpoint.x,
    y1 => hitpoint.y,
    z1 => hitpoint.z,

    x2 => center.x,
    y2 => center.y,
    z2 => center.z,

    x => normal_vec.x,
    y => normal_vec.y,
    z => normal_vec.z
  );

  delay_one_over_r: delay_element generic map(WIDTH => 32, DEPTH => 1) port map (
  
    clk => clk, clken => clk_en, reset => reset, 
    source => one_over_r,
    dest => one_over_r_delayed
  );

  normalizeNormalVec : vecMulS
  port map(

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    x => normal_vec.x,
    y => normal_vec.y,
    z => normal_vec.z,

    scalar => one_over_r_delayed,

    x_res => unit_normal_vec.x,
    y_res => unit_normal_vec.y,
    z_res => unit_normal_vec.z

  );

-- in C subroutine reflect

  v_dot_n : vector_dot
  port map(

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    x_1 => scaled_dir.x,
    y_1 => scaled_dir.y,
    z_1 => scaled_dir.z,

    x_2 => unit_normal_vec.x,
    y_2 => unit_normal_vec.y,
    z_2 => unit_normal_vec.z,

    result => dot_prod(32 downto 1)
  );

  scaleNormalVec : vecMulS
  port map(

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    x => unit_normal_vec.x,
    y => unit_normal_vec.y,
    z => unit_normal_vec.z,

    scalar => dot_prod(31 downto 0),

    x_res => scaled_normal_vec.x,
    y_res => scaled_normal_vec.y,
    z_res => scaled_normal_vec.z

  );

  reflect_direction : vector_add_sub 
  port map (

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    add_sub => '0',

    x1 => scaled_dir.x,
    y1 => scaled_dir.y,
    z1 => scaled_dir.z,

    x2 => scaled_normal_vec.x,
    y2 => scaled_normal_vec.y,
    z2 => scaled_normal_vec.z,

    x => new_direction_next.x,
    y => new_direction_next.y,
    z => new_direction_next.z
  );
  
end architecture;