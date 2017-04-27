library ieee;
use ieee.std_logic_1164.all;
use work.delay_pkg.all;

entity anyRefl is
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
end entity;

architecture beh of anyRefl is

signal any, anyNext : std_logic; --startOfBundle_out_next, endOfBundle_out_next: std_logic;

signal reflect, next_reflect, pseudo_reflect, next_pseudo_reflect, bundle, next_bundle, eob_delay, sob_delay : std_logic_vector(32 downto 0);

signal anyNext_vec, eob_vec: std_logic_vector(31 downto 0);
signal valid_ray_in_vec, valid_ray_out_vec : std_logic_vector(0 downto 0);

begin

valid_ray_in_vec(0) <= valid_ray_in;

delay_ray_validity: delay_element generic map(WIDTH => 1, DEPTH => 32) -- falsch?
port map (
  clk => clk, clken => clk_en, reset => reset, 
  source => valid_ray_in_vec,
  dest => valid_ray_out_vec
);

valid_ray_out <= valid_ray_out_vec(0);

anyNext <= --(valid_ray_in and (
	   (startOfBundle and valid_t and (remaining_reflects(0) OR remaining_reflects(1) or remaining_reflects(2)) and not emitting_sphere) 
	   or 
	   (not(startOfBundle) and 
	   ((valid_t and (remaining_reflects(0) or remaining_reflects(1) or remaining_reflects(2)) and not emitting_sphere) or any))
	   ;--));

next_reflect(32) <= (valid_ray_in and (
	   valid_t and (remaining_reflects(0) OR remaining_reflects(1) or remaining_reflects(2)) and not emitting_sphere
	   ));

next_reflect(31 downto 0) <= reflect(32 downto 1);

next_pseudo_reflect(32) <= anyNext;

anyNext_vec <= (OTHERS => anyNext);

next_pseudo_reflect(31 downto 0) <= (NOT(bundle(32 downto 1)) AND anyNext_vec) OR (bundle(32 downto 1) AND pseudo_reflect(32 downto 1));

eob_vec <= (OTHERS => endOfBundle);

next_bundle(32) <= endOfBundle;

next_bundle(31 downto 0) <= bundle(32 downto 1) OR eob_vec;

isReflected <= reflect(0);
pseudoReflect <= pseudo_reflect(0);

startOfBundle_out <= sob_delay(32);
endOfBundle_out <= eob_delay(32);

sync : process(clk, reset)
begin

  if reset = '1' then

    any <= '0';
    reflect <= (OTHERS => '0');
    pseudo_reflect <= (OTHERS => '0');
    bundle <= (OTHERS => '1');
--    startOfBundle_out <= '0';
--    endOfBundle_out <= '0';
    sob_delay <= (others => '0');
    eob_delay <= (others => '0');

  elsif rising_edge(clk) and clk_en = '1' then

    any <= anyNext;
    reflect <= next_reflect;
    pseudo_reflect <= next_pseudo_reflect;
    bundle <= next_bundle;

    sob_delay <= sob_delay(31 downto 0) & startOfBundle;
    eob_delay <= eob_delay(31 downto 0) & endOfBundle;

  end if;

end process;


end architecture;