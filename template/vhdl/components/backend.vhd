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
    valid_data  : std_logic;
    valid_ray   : std_logic;

    ray_in : ray; -- with color? and position

    -- Kugeldaten: Farbe, ws nicht emitting

    memory_address : out std_logic_vector(31 downto 0);
    color_data : out std_logic_vector(31 downto 0)
  );
end entity;

architecture beh of backend is

  signal index : natural;
  signal hitColor : vector;
  signal color_out_next : vector;
  signal valid_t_vec, valid_color_vec : std_logic_vector(0 downto 0);
  signal valid_ray_in_vec, valid_ray_out_vec : std_logic_vector(0 downto 0);
  signal valid_color_next : std_logic;

--  signal color_shifted_x : std_logic_vector(31 downto 0);
--  signal color_shifted_y : std_logic_vector(31 downto 0);
--  signal color_shifted_z : std_logic_vector(31 downto 0);

  signal color_shifted : vector;

begin

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

-- latchen ws
-- ins SQRT rein

-- addieren, wenn valid(delayed), mit eob raus und mit sob neu machen


  --sync : process(clk, reset)

  --begin

  --if reset = '1' then 

  --  color_out <= (others => (others => '0'));

  --elsif rising_edge(clk) then

   -- if valid_color_next = '1' then 

    --  color_out <= color_out_next;
   -- else

   --   color_out <= (others => (others => '0'));
   -- end if;

   -- valid_color <= valid_color_next;

  --end if;

--  end process;




end architecture;