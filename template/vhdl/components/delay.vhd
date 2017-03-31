library ieee;
use ieee.std_logic_1164.all;
use work.delay_pkg.all;
use work.operations_pkg.all;

entity delay_element is
  generic
  (
	WIDTH : natural;
	DEPTH : natural
  );
  port
  (
	clk 	: in  std_logic;
	reset 	: in  std_logic;
	clken 	: in  std_logic;
	
	source 	: in  std_logic_vector(WIDTH - 1 downto 0);
	dest 	: out std_logic_vector(WIDTH - 1 downto 0)
  );
end entity delay_element;

architecture beh of delay_element is

  signal store : std_logic_vector(WIDTH*(DEPTH +1) - 1 downto 0);

begin

	IF0 : if depth*width > 200 and depth > 3 generate -- ram shift register, depth must be > 3 for on-chip ram

	  ram : sr_ram
	    generic map(
	      width => width,
	      depth => depth
	    )
            port map(
		aclr => reset,
		clken => clken,
	 	clock => clk,
		
		shiftin => source,
		shiftout => dest,
		taps => open
	    );

        end generate;

	IF1 : if not(depth*width > 200 and depth > 3) and
		 DEPTH > 0 AND WIDTH > 0 generate -- sonst mit generate

	-- real delay
	store(WIDTH*(DEPTH +1) - 1 downto WIDTH*DEPTH) <= source;
	dest <= store(WIDTH-1 DOWNTO 0);

	sync : process(clk, reset, clken) is begin
		if reset = '1' then

			store(WIDTH*DEPTH - 1 DOWNTO 0) <= (others => '0');
		elsif rising_edge(clk) AND clken =  '1' then
			store(WIDTH*DEPTH - 1 DOWNTO 0) <= store(WIDTH*(DEPTH +1) - 1 DOWNTO WIDTH);
		end if;
	end process;
	end generate;

	IF2 : if DEPTH = 0 generate
	
	  dest <= source;

	end generate;

end architecture;
