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
		--###########################################################################
		-- INPUTS
		--###########################################################################
		clk 		: in std_logic;
		clk_en 		: in std_logic;
		reset 		: in std_logic;
		num_samples 	: in std_logic_vector(4 downto 0); -- one hot: 16, 8, 4, 2, 1
		ray_in 		: in ray;

		--###########################################################################
		-- OUTPUTS
		--###########################################################################
		color_data 	: out std_logic_vector(23 downto 0);
		valid_data 	: out std_logic
	);
end entity;

architecture beh of backend is

  signal
	color_shifted,
	color_shifted_next,
	color_accum,
	color_accum_next,
	color_root
		: vector;

  signal
	valid_ray,
	copy_ray,
	startOfBundle,
	endOfBundle,
	next_valid
		: std_logic;

  signal
	valid_shift
		: std_logic_vector(18 downto 0);

begin

--########################################################################
-- HELPERS
--########################################################################

next_valid <= ray_in.valid and ray_in.eob;

--########################################################################
-- LOGIC
--########################################################################


-- cylce 1
shift : process(ray_in)
begin
	if num_samples(4) = '1' then
		color_shifted_next.x <= "0000" & ray_in.color.x(31 downto 4);
		color_shifted_next.y <= "0000" & ray_in.color.y(31 downto 4);
		color_shifted_next.z <= "0000" & ray_in.color.z(31 downto 4);
	elsif num_samples(3) = '1' then
		color_shifted_next.x <= "000" & ray_in.color.x(31 downto 3);
		color_shifted_next.y <= "000" & ray_in.color.y(31 downto 3);
		color_shifted_next.z <= "000" & ray_in.color.z(31 downto 3);
	elsif num_samples(2) = '1' then
		color_shifted_next.x <= "00" & ray_in.color.x(31 downto 2);
		color_shifted_next.y <= "00" & ray_in.color.y(31 downto 2);
		color_shifted_next.z <= "00" & ray_in.color.z(31 downto 2);
	elsif num_samples(1) = '1' then
		color_shifted_next.x <= "0" & ray_in.color.x(31 downto 1);
		color_shifted_next.y <= "0" & ray_in.color.y(31 downto 1);
		color_shifted_next.z <= "0" & ray_in.color.z(31 downto 1);
	else
		color_shifted_next.x <= ray_in.color.x;
		color_shifted_next.y <= ray_in.color.y;
		color_shifted_next.z <= ray_in.color.z;
	end if;
end process;

-- cycle 2
async : process(color_accum, color_shifted, startOfBundle, endOfBundle, valid_ray, copy_ray)
begin
	if  valid_ray = '1' and copy_ray = '0' then -- update the value of color accumulation
		-- if this is the first of the bundle, start anew
		if startOfBundle = '1' then 
			color_accum_next <= color_shifted;
		-- if this is an already started bundle, add up
		else 
			color_accum_next <= color_accum + color_shifted;
		end if;
	else -- keep the old value
		color_accum_next <= color_accum;
	end if;
end process;


-- sync values cycles 1-2 + validities cycles 1-19
sync : process(clk, reset, clk_en)
begin
	if reset = '1' then 
		color_accum <= (others => (others => '0'));
		valid_shift <= (others => '0');
		color_shifted <= (others => (others => '0'));
		startOfBundle <= '0';
		endOfBundle <= '0';
		copy_ray <= '0';
		valid_ray <= '0';
	elsif rising_edge(clk) and clk_en = '1' then
		color_accum <= color_accum_next;
		valid_shift <= next_valid & valid_shift(18 downto 1);
		color_shifted <= color_shifted_next;
		startOfBundle <= ray_in.sob;
		endOfBundle <= ray_in.eob;
		copy_ray <= ray_in.copy;
		valid_ray <= next_valid;
	end if;
end process;

-- cycle 3 - 18
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

-- cycle 19
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
	add_sub => '0',
	reset => reset,
	clk => clk,
	clk_en => clk_en,
	x => color_data(23 downto 16), 
	y => color_data(15 downto  8), 
	z => color_data( 7 downto  0)
);

--########################################################################
-- OUTPUTS
--########################################################################


valid_data <= valid_shift(0);


end architecture;