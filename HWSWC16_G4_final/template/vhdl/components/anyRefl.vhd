library ieee;
use ieee.std_logic_1164.all;
use work.delay_pkg.all;

-- entity that decides whether a single ray should be reflected
entity anyRefl is
	port
	(
		--######################################################################
		-- INPUTS
		--######################################################################
		-- the clock
		clk				: in std_logic;
		-- clock enable - stall when '0'
		clk_en 				: in std_logic;
		-- asynchronous reset - active when '1'
		reset 				: in std_logic;
		-- one hot - 1, 2, 4, 8, 16
		num_samples			: in std_logic_vector(4 downto 0);
		-- '1' signals that the current input ray is the last of a bundle
		endOfBundle 			: in std_logic;
		-- '1' signals that the current input ray is the first of a bundle
		startOfBundle 			: in std_logic;
		-- '1' signals that the current input ray is valid
		valid_ray_in 			: in std_logic;
		-- represents how many times the current input ray can still be reflected
		remaining_reflects 		: in std_logic_vector(2 downto 0);
		-- '1' signals that the current input ray hit a sphere that is emmitting
		emitting_sphere 		: in std_logic;
		-- '1' signals that the current input ray actually hit a sphere
		valid_t				: in std_logic;
		--######################################################################
		-- OUTPUTS
		--######################################################################
		-- '1'  signals that the current output ray is to be reflected
    		isReflected 			: out std_logic;
    		-- '1' signals that the current output ray is to be sent back to the
	    	-- beginning of the loop
	    	pseudoReflect 			: out std_logic;
	    	-- '1' signals that the current output ray is valid
	    	valid_ray_out  			: out std_logic;
	    	-- '1' signals that the current output ray is the start of a bundle
	    	startOfBundle_out 		: out std_logic;
	    	-- '1' signals that the current output ray is the last of a bundle
	    	endOfBundle_out 		: out std_logic
		--######################################################################
		--######################################################################
    );
end entity;

-- Architecture of the entity deciding whether a ray should be reflected
architecture beh of anyRefl is

signal 
	any,
	anyNext 
		: std_logic;

signal
	reflect,
	next_reflect,
	pseudo_reflect,
	next_pseudo_reflect,
	bundle,
	next_bundle
		: std_logic_vector(31 downto 0);

signal
	anyNext_vec,
	eob_vec,
	eob_delay,
	sob_delay
		: std_logic_vector(31 downto 0);

begin
--########################################################################
-- DELAYS
--########################################################################
-- element delaying the ray validity for 32 cycles (length of this element)
delay_ray_validity: delay_element
generic map(WIDTH => 1, DEPTH => 32)
port map (
	clk => clk, clken => clk_en, reset => reset, 
	source(0) => valid_ray_in,
	dest(0) => valid_ray_out
);

--########################################################################
-- HELPERS
--########################################################################
-- a vector where each element is the current decision value for re-loop
anyNext_vec <= (OTHERS => anyNext);
-- a vector where each element is the value of the eob flag
eob_vec <= (OTHERS => endOfBundle);
-- the current ray is part of a closed bundle if it is not valid or
-- the end of bundle flag is set
next_bundle(31) <= endOfBundle OR NOT(valid_ray_in);
-- earlier bundles are "closed" on reception of the eob flag set to '1'
next_bundle(30 downto 0) <= bundle(31 downto 1) OR eob_vec(31 downto 1);

--########################################################################
-- LOGIC
--########################################################################
-- defines the next value for whether any ray in the current bundle is to be reflected
-- refl_remaining <= remaining_reflects(0) or remaining_reflects(1) or remaining_reflects(2);
-- this_refl <= valid_t AND refl_remaining AND not(emmiting_sphere);
-- anyNext <= this_refl OR (not(startOfBundle) AND any)
anyNext <= 
(
	startOfBundle
	and valid_t
	and (
		remaining_reflects(0)
		or remaining_reflects(1) 
		or remaining_reflects(2)
	) 
	and not(emitting_sphere)
) 
or (
	not(startOfBundle)
	and (
		(
			valid_t 
			and (
				remaining_reflects(0) 
				or remaining_reflects(1) 
				or remaining_reflects(2)
			) 
			and not emitting_sphere
		)
		or any
	)
);
-- represents whether the current input ray is to be reflected.
-- '1' when a non-emmitting sphere was hit.
next_reflect(31) <= 
(
	valid_ray_in and
	(
		valid_t and 
		(
			remaining_reflects(0) 
			or remaining_reflects(1) 
			or remaining_reflects(2)
		) 
		and not(emitting_sphere)
  )
);
-- the current output of reflections is shifted
next_reflect(30 downto 0) <= reflect(31 downto 1);

-- whether or not a ray is to be sent through the loop again
-- the current ray is sent through again if any ray in the
-- bundle is so far sent through
next_pseudo_reflect(31) <= anyNext;
-- rays that belong to an already finished bundle keep their value
-- while rays that belong to the current bundle are updated with the value
-- of the current ray.
next_pseudo_reflect(30 downto 0) <= 
(
	NOT(bundle(31 downto 1)) 
	AND anyNext_vec(31 downto 1)
) OR
(
	bundle(31 downto 1) 
	AND pseudo_reflect(31 downto 1)
);

-- process that synchronously advances the values of the internal signals
sync : process(clk, reset)
begin
	if reset = '1' then
		any <= '0';
   	reflect <= (OTHERS => '0');
   	pseudo_reflect <= (OTHERS => '0');
   	bundle <= (OTHERS => '1');
		sob_delay <= (others => '0');
		eob_delay <= (others => '0');
	elsif rising_edge(clk) and clk_en = '1' then
		any <= anyNext;
		reflect <= next_reflect;
		pseudo_reflect <= next_pseudo_reflect;
		bundle <= next_bundle;
		sob_delay <= startOfBundle & sob_delay(31 downto 1);
		eob_delay <= endOfBundle & eob_delay(31 downto 1);
	end if;
end process;

--########################################################################
-- OUTPUT
--########################################################################
isReflected <= reflect(0);
pseudoReflect <= pseudo_reflect(0);
startOfBundle_out <= sob_delay(0);
endOfBundle_out <= eob_delay(0);
	

end architecture;