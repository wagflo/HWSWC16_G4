--	/* set pixel */
--	vec3MulS (&col, num_samples_r, &col); /* col /= num_samples */
--	vec3Sqrt (&col, &col); /* gammagetRayDir correction */
--	/* pack rgb values into one 32 bit value */
--	fix16_t bit_mask = 255 << 16;
--	col.x[0] = ALT_CI_CI_MUL_0 (col.x[0], bit_mask) & bit_mask;
--	bit_mask = 255 << 8;
--	col.x[1] = ALT_CI_CI_MUL_0 (col.x[1], bit_mask) & bit_mask;
--	bit_mask = 255;
--	col.x[2] = ALT_CI_CI_MUL_0 (col.x[2], bit_mask) & bit_mask;
--	uint32_t rgb = col.x[0] | col.x[1] | col.x[2];
--	displaySetPixel (FRAME_HEIGHT-1-j, i, rgb);

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.operations_pkg.all;
use work.delay_pkg.all;



entity backend is 
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
end entity;

architecture beh of backend is

  signal index : natural;
  signal valid_t_vec, valid_color_vec : std_logic_vector(0 downto 0);
  signal valid_ray_in_vec, valid_ray_out_vec : std_logic_vector(0 downto 0);

--  signal color_accum : vector;

--  signal color_shifted_x : std_logic_vector(31 downto 0);
--  signal color_shifted_y : std_logic_vector(31 downto 0);
--  signal color_shifted_z : std_logic_vector(31 downto 0);

  signal color_shifted, color_accum, color_accum_next, color_root : vector;
  signal eob_and_valid, eob_and_valid_next : std_logic;

  signal valid_ray, copy_ray, startOfBundle, endOfBundle : std_logic;
  signal valid_shift : std_logic_vector(17 downto 0);
begin

  valid_ray <= ray_in.valid;
  copy_ray  <= ray_in.copy;
  startOfBundle <= ray_in.sob;
  endOfBundle   <= ray_in.eob;

  shift : process(ray_in)
  begin

    if num_samples(4) = '1' then

      color_shifted.x <= "0000" & ray_in.color.x(31 downto 4);
      color_shifted.y <= "0000" & ray_in.color.y(31 downto 4);
      color_shifted.z <= "0000" & ray_in.color.z(31 downto 4);
    elsif num_samples(3) = '1' then

      color_shifted.x <= "000" & ray_in.color.x(31 downto 3);
      color_shifted.y <= "000" & ray_in.color.y(31 downto 3);
      color_shifted.z <= "000" & ray_in.color.z(31 downto 3);
    elsif num_samples(2) = '1' then

      color_shifted.x <= "00" & ray_in.color.x(31 downto 2);
      color_shifted.y <= "00" & ray_in.color.y(31 downto 2);
      color_shifted.z <= "00" & ray_in.color.z(31 downto 2);
    elsif num_samples(1) = '1' then

      color_shifted.x <= "0" & ray_in.color.x(31 downto 1);
      color_shifted.y <= "0" & ray_in.color.y(31 downto 1);
      color_shifted.z <= "0" & ray_in.color.z(31 downto 1);
    else

      color_shifted.x <= ray_in.color.x;
      color_shifted.y <= ray_in.color.y;
      color_shifted.z <= ray_in.color.z;
    end if;
  end process;

-- latchen ws/vl mal schauen
async : process(color_accum, color_shifted, startOfBundle, endOfBundle, valid_ray, copy_ray)
begin
if  valid_ray = '1' and copy_ray = '0' then
  
  eob_and_valid_next <= endOfBundle; -- oder einfach in delay Element?
  if startOfBundle = '1' then 
    
    color_accum_next <= color_shifted;
  else 
    
    color_accum_next <= color_accum + color_shifted;
  end if;

else -- wird latchen sonst

  eob_and_valid_next <= '0';
  color_accum_next <= color_accum;

end if;
end process;
  
-- addieren, wenn valid(delayed), mit eob raus und mit sob neu machen

sqrt_x : sqrt
port map (
  input => color_accum.x,
  output => color_root.x,

  clk => clk, 
  clk_en => clk_en, 
  reset => reset
);

sqrt_y : sqrt
port map (
  input => color_accum.y,
  output => color_root.y,

  clk => clk, 
  clk_en => clk_en, 
  reset => reset
);

sqrt_z : sqrt
port map (
  input => color_accum.z,
  output => color_root.z,

  clk => clk, 
  clk_en => clk_en, 
  reset => reset
);

--color_data <= color.root;
-- ins SQRT rein

-- Adressberechnung! oder eh von Anfang an?
-- noch color packen

vec_sub : vector_add_sub 
  generic map (
    DATA_WIDTH => 8
  )
  port map (
    x1 => color_root.x(15 downto 8),
    y1 => color_root.y(15 downto 8),
    z1 => color_root.z(15 downto 8),
    x2 => color_root.x(23 downto 16), 
    y2 => color_root.y(23 downto 16),  
    z2 => color_root.z(23 downto 16), 
    add_sub => '0', -- testen 
    
    reset => reset,
    clk => clk,
    clk_en => clk_en,
	
    x => color_data(23 downto 16), 
    y => color_data(15 downto  8), 
    z => color_data( 7 downto  0)
  );

sync : process(clk, reset)
begin

  if reset = '1' then 

    color_accum <= (others => (others => '0'));
    eob_and_valid <= '0';

  elsif rising_edge(clk) and clk_en = '1' then

    color_accum <= color_accum_next;
    eob_and_valid <= eob_and_valid_next;

  end if;
end process;




end architecture;