library ieee;
use ieee.std_logic_1164.all;
use work.operations_pkg.all;
use IEEE.numeric_std.all;

entity getRayDirAlt is

port(

    clk 	: in std_logic;
    clk_en 	: in std_logic;
    hold 	: in std_logic;
    reset 	: in std_logic;
    start 	: in std_logic;

    frame	: in std_logic_vector(1 downto 0);

    num_samples : in std_logic_vector(4 downto 0);

    addition_hor : in vector;

    addition_ver : in vector;

    addition_base : in vector;
    
    result	: out vector;

    position	: out std_logic_vector (21 downto 0);
    done	: out std_logic;
    copyRay	: out std_logic;
    valid	: out std_logic;
    sob		: out std_logic;
    eob		: out std_logic

  );

end getRayDirAlt;

architecture arch of getRayDirAlt is

signal next_done, next_copyRay, next_valid : std_logic;

signal next_sob, next_eob : std_logic;

signal ver_base, next_result, next_result_hold, result_hold, next_ver_base, ran_add, next_ran_add : vector;
signal next_i, j, next_j, i, samples, next_samples : natural;
signal next_frame_no, frame_no : std_logic_vector(1 downto 0);
signal ran : std_logic_vector(31 downto 0) := x"00000000";

component lfsr is
  port (
    cout   :out std_logic_vector (7 downto 0);-- Output of the counter
    enable :in  std_logic;                    -- Enable counting
    clk    :in  std_logic;                    -- Input rlock
    reset  :in  std_logic                     -- Input reset
  );
end component;


constant max_width : natural := 799;

constant max_height : natural := 479;

begin
l1 : lfsr port map(cout => ran(31 downto 24), clk => clk, reset => reset, enable => clk_en);
l2 : lfsr port map(cout => ran(23 downto 16), clk => clk, reset => reset, enable => clk_en);
l3 : lfsr port map(cout => ran(15 downto 8), clk => clk, reset => reset, enable => clk_en);
l4 : lfsr port map(cout => ran(7 downto 0), clk => clk, reset => reset, enable => clk_en);
async : process(j, i, start, clk) is begin
position(21 downto 20) <= frame_no;
position(19 downto 10) <= std_logic_vector(to_unsigned(i, 10));
position(9 downto 0) <= std_logic_vector(to_unsigned(j, 10));
next_frame_no <= frame;
next_copyRay <= hold;
next_valid <= '1';
next_done <= '0';
next_sob <= '0';
next_eob <= '0';
next_ran_add <= addition_ver + addition_hor;
next_result <= result_hold;
next_result_hold <= result_hold;
if start =  '1' then
	next_j <= 0;
	next_i <= 0;
	next_result <= addition_base;
	next_ver_base <= addition_base;
	next_done <= '0';
	next_samples <= 1;
	next_sob <= '1';
	if num_samples = "00001" then
		next_eob <= '1';
	end if;
else
	if samples = unsigned(num_samples) then
		next_samples <= 1;
		next_sob <= '1';
		if num_samples = "00001" then
			next_eob <= '1';
		end if;
		if i = max_width then
			if j >= max_height then
				next_valid <= '0';
			else
				next_result_hold <= ver_base + addition_ver;
				next_ver_base <= ver_base + addition_ver;
				next_result <= ver_base + addition_ver + (ran_add and ran);
				next_i <= 0;
				next_j <= j + 1;
			end if;
			
		else
			next_result_hold <= result_hold + addition_hor;
			next_result <= result_hold + addition_hor + (ran_add and ran);
			next_i <= i + 1;
			next_j <= j;
			if j = max_height AND i = max_height -1 then
				next_done <= '1';
			end if;
		end if;
	else
		if samples = unsigned(num_samples) - 1 then
			next_eob <= '1';
		end if;
		next_samples <= samples + 1;
		next_j <= j;
		next_i <= i;
		next_valid <= '1';
		next_result <= result_hold + (ran_add and ran);
	end if;
	
end if;

end process;

sync : process(clk, reset, clk_en, hold) is begin
if reset = '1' then
	samples <= 0;
	i <= 0;
	j <= 0;
	result <= (x => (OTHERS => '0'), y => (OTHERS => '0'), z => (OTHERS => '0'));
	result_hold <= (x => (OTHERS => '0'), y => (OTHERS => '0'), z => (OTHERS => '0'));
	done <= '0';
	sob <= '0';
	eob <= '0';
	ran_add <= (x => (OTHERS => '0'), y => (OTHERS => '0'), z => (OTHERS => '0'));
	frame_no <= "00";
elsif rising_edge(clk) AND clk_en = '1' then
	copyRay <= next_copyRay;
	if hold = '0' then
		samples <= next_samples;
		i <= next_i;
		j <= next_j;
		result <= next_result;
		result_hold <= next_result_hold;
		valid <= next_valid;
		done <= next_done;
		sob <= next_sob;
		eob <= next_eob;
		ran_add <= next_ran_add;
		frame_no <= next_frame_no;
	end if;
end if;
end process;


end architecture;
