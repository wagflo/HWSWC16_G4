
--	if (nearest_obj->mat == EMITTING)
--		break;
--	
--	/* if not emitting reflect */
--	/* ray_origin = ray_origin + t * ray_dir */
--	vec3_t tmp;
--	vec3MulS (&tmp, tmin, &ray_dir);
--	vec3Add (&ray_origin, &tmp, &ray_origin);
--	/* n = (ray_origin - center) / radius  */
--	vec3_t n; /* surface normal */
--	vec3Sub (&n, &ray_origin, &nearest_obj->center);
--	//fix16_t rr = nearest_obj->rec_radius;
--	vec3MulS (&n, nearest_obj->rec_radius, &n);
--	reflect (&ray_dir, &ray_dir, &n);
--
--	reflect (vec3_t *r, vec3_t *v, vec3_t *n)
--	{
--	vec3_t tmp;
--	fix16_t t = ALT_CI_CI_MUL_0 (fix16_one << 1, vec3Dot (v, n));
--	vec3MulS (&tmp, t, n);
--	vec3Sub (r, v, &tmp);
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.operations_pkg.all;
use work.delay_pkg.all;



entity reflect is 
port (
	clk 		: in std_logic;
	clk_en 		: in std_logic;
	reset		: in std_logic;
	valid_t		: in std_logic;
	t		: in std_logic_vector(31 downto 0);
	sphere_i	: in std_logic_vector(3 downto 0);
	valid_ray_in	: in std_logic;
	copy_ray_in	: in std_logic;
	one_over_rs	: in scalarArray;
	centers		: in vectorArray;
	origin		: in vector;
	direction	: in vector;
	new_origin	: out vector;
	new_direction	: out vector;
	valid_refl	: out std_logic;
	valid_ray_out	: out std_logic;
	copy_ray_out	: out std_logic
);
end entity;

architecture beh of reflect is

signal
	index_for_center,
	index_for_one_over_r
		: natural;

signal
	center,
	new_origin_next,
	new_direction_next,
	scaled_dir,
	hitpoint,
	normal_vec,
	unit_normal_vec,
	scaled_normal_vec,
	origin_delayed,
	dir_delay_c6,
	dir_delay_c12,
	unit_normal_vec_delayed
		: vector;

signal
	one_over_r,
	one_over_r_delayed,
	dot_prod_res,
	dot_prod_input
		:  std_logic_vector(31 downto 0);

signal
	valid_refl_next,
	valid_t_for_center,
	valid_t_for_one_over_r
		: std_logic;
signal
	sphere_i_for_center,
	sphere_i_for_one_over_r
		: std_logic_vector(3 downto 0);
signal
	origin_delayed_std_logic,
	new_origin_std_logic,
	dir_std_logic_delay_c6,
	dir_std_logic_delay_c12,
	unit_normal_vec_delayed_std_logic
		: std_logic_vector(95 downto 0);

signal
	valid_ray_in_vec,
	valid_ray_out_vec
		: std_logic_vector(0 downto 0);



constant scalar_zero : std_logic_vector(31 downto 0) := x"00000000";
constant vector_zero : std_logic_vector(95 downto 0) := scalar_zero & scalar_zero & scalar_zero;

begin

index_for_center     <= natural(to_integer(unsigned(sphere_i_for_center)));
index_for_one_over_r <= natural(to_integer(unsigned(sphere_i_for_one_over_r)));

async : process(centers, one_over_rs, index_for_center, index_for_one_over_r)
begin
	if valid_t_for_center = '1' then 
		center <= centers(index_for_center);
	else 
		center <= tovector(vector_zero);
	end if;
	if valid_t_for_one_over_r = '1' then 
		one_over_r <= to_std_logic(one_over_rs(index_for_one_over_r));
	else 
		one_over_r <= scalar_zero; --toscalar(scalar_zero);
	end if;
end process;



delay_other_validities_c1t14: delay_element
generic map(WIDTH => 2, DEPTH => 14)
port map (
	clk => clk,
	clken => clk_en,
	reset => reset, 
	source(0) => valid_ray_in, source(1) => copy_ray_in,
	dest(0) => valid_ray_out, dest(1) => copy_ray_out
);

delay_sphere_i_for_center_c1t3: delay_element
generic map(WIDTH => 5, DEPTH => 3) 
port map (
	clk => clk, clken => clk_en, reset => reset, 
	source(4 downto 1) => sphere_i,
	source(0) => valid_t,
	dest(4 downto 1) => sphere_i_for_center,
	dest(0) => valid_t_for_center
);

delay_sphere_i_for_one_over_r_c4: delay_element
generic map(WIDTH => 5, DEPTH => 1) 
port map (
	clk => clk,
	clken => clk_en,
	reset => reset, 
	source(4 downto 1) => sphere_i_for_center,
	source(0) => valid_t_for_center,
	dest(4 downto 1) => sphere_i_for_one_over_r,
	dest(0) => valid_t_for_one_over_r
);

delay_validity_c5t13: delay_element
generic map(WIDTH => 1, DEPTH => 9)
port map (
	clk => clk, clken => clk_en, reset => reset, 
	source(0) => valid_t_for_one_over_r,
	dest(0) => valid_refl_next
);

  

  

  sync : process(clk, clk_en, reset) --************************ AM ENDE NOCHMAL GELATCHT ***********************

  begin

    if reset = '1' then 
      new_origin <= tovector(vector_zero);
      new_direction <= tovector(vector_zero);
      valid_refl <= '0';
    elsif rising_edge(clk) and clk_en = '1' then
      new_origin <= new_origin_next;
      new_direction <= new_direction_next;
      valid_refl <= valid_refl_next;
    end if;
  end process;


  mulDir_c1t2 : vecMulS
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

  delay_ray_validity_c1t14: delay_element generic map(WIDTH => 1, DEPTH => 14) 
  port map (
    clk => clk, clken => clk_en, reset => reset, 
    source(0) => valid_ray_in,
    dest(0) => valid_ray_out
  );

  delay_dir_for_dot_product_c1t6: delay_element generic map(WIDTH => 96, DEPTH => 6) 
  port map (
    clk => clk, clken => clk_en, reset => reset, 
    source => to_std_logic(direction),
    dest => dir_std_logic_delay_c6
  );

  dir_delay_c6 <= tovector(dir_std_logic_delay_c6);


  delay_origin_for_add2origin_c1t2: delay_element generic map(WIDTH => 96, DEPTH => 2) 
  port map (
    clk => clk, clken => clk_en, reset => reset, 
    source => to_std_logic(origin),
    dest => origin_delayed_std_logic
  );

  origin_delayed <= tovector(origin_delayed_std_logic);



  add2origin_c3 : vector_add_sub 
  port map (

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    add_sub => '1', --MK

    x1 => origin_delayed.x,
    y1 => origin_delayed.y,
    z1 => origin_delayed.z,

    x2 => scaled_dir.x,
    y2 => scaled_dir.y,
    z2 => scaled_dir.z,

    x => hitpoint.x,
    y => hitpoint.y,
    z => hitpoint.z
  );

  delay_hitpoint_c4t13 : delay_element generic map(WIDTH => 96, DEPTH => 10) port map (
  
    clk => clk, clken => clk_en, reset => reset, 
    source => to_std_logic(hitpoint),
    dest => new_origin_std_logic
  );

  new_origin_next <= tovector(new_origin_std_logic);

  normalVec_c4 : vector_add_sub 
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

  --delay_one_over_r: delay_element generic map(WIDTH => 32, DEPTH => 1) 
  --  port map (
  
  --  clk => clk, clken => clk_en, reset => reset, 
  --  source => one_over_r,
  --  dest => one_over_r_delayed
  --);

  normalizeNormalVec_c5t6 : vecMulS
  port map(

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    x => normal_vec.x,
    y => normal_vec.y,
    z => normal_vec.z,

    scalar => one_over_r, --one_over_r_delayed,

    x_res => unit_normal_vec.x,
    y_res => unit_normal_vec.y,
    z_res => unit_normal_vec.z

  );

-- in C subroutine reflect

  delay_unit_normal_vec_for_scaleNormalVec_c7t10: delay_element generic map(WIDTH => 96, DEPTH => 4) 
  port map (
    clk => clk, clken => clk_en, reset => reset, 
    source => to_std_logic(unit_normal_vec),
    dest => unit_normal_vec_delayed_std_logic
  );

  unit_normal_vec_delayed <= tovector(unit_normal_vec_delayed_std_logic);


  v_dot_n_c7t10 : vector_dot
  port map(

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    x_1 => dir_delay_c6.x,
    y_1 => dir_delay_c6.y,
    z_1 => dir_delay_c6.z,

    x_2 => unit_normal_vec.x, --unit_normal_vec_delayed.x,
    y_2 => unit_normal_vec.y, --unit_normal_vec_delayed.y,
    z_2 => unit_normal_vec.z, --unit_normal_vec_delayed.z,

    result => dot_prod_res--(32 downto 1)
  );

  --dot_prod_input <= dot_prod_res(30 downto 0) & '0';
  dot_prod_input <= dot_prod_res(31) & dot_prod_res(29 downto 0) & '0';

  scaleNormalVec_c11t12 : vecMulS
  port map(

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    x => unit_normal_vec_delayed.x, --unit_normal_vec.x,
    y => unit_normal_vec_delayed.y, --unit_normal_vec.y,
    z => unit_normal_vec_delayed.z, --unit_normal_vec.z,

    scalar => dot_prod_input, --(31 downto 1),

    x_res => scaled_normal_vec.x,
    y_res => scaled_normal_vec.y,
    z_res => scaled_normal_vec.z

  );

  delay_dir_for_new_dir_next_c7t12 : delay_element generic map(WIDTH => 96, DEPTH => 6) 
  port map (
    clk => clk, clken => clk_en, reset => reset, 
    source => dir_std_logic_delay_c6,
    dest => dir_std_logic_delay_c12
  );

  dir_delay_c12 <= tovector(dir_std_logic_delay_c12);

  reflect_direction_c13 : vector_add_sub 
  port map (

    clk => clk,
    clk_en => clk_en,
    reset => reset,

    add_sub => '0', --MK

    --x1 => scaled_dir_delay_10.x,
--    y1 => scaled_dir_delay_10.y,
--    z1 => scaled_dir_delay_10.z,

--    x2 => scaled_normal_vec.x,
--    y2 => scaled_normal_vec.y,
--    z2 => scaled_normal_vec.z,

    x2 => dir_delay_c12.x,
    y2 => dir_delay_c12.y,
    z2 => dir_delay_c12.z,

    x1 => scaled_normal_vec.x,
    y1 => scaled_normal_vec.y,
    z1 => scaled_normal_vec.z,

    x => new_direction_next.x,
    y => new_direction_next.y,
    z => new_direction_next.z
  );


  
end architecture;