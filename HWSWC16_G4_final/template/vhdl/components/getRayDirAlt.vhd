library ieee;
use ieee.std_logic_1164.all;
use work.operations_pkg.all;
use IEEE.numeric_std.all;

entity getRayDirAlt is
generic(
 MAXWIDTH : natural := 800;
    MAXHEIGHT : natural := 480
);
port(

    clk 	: in std_logic;
    clk_en 	: in std_logic;
    hold 	: in std_logic;
    reset 	: in std_logic;
    start 	: in std_logic;
    valid_data	: in std_logic;

    frame	: in std_logic_vector(1 downto 0);

    num_samples : in std_logic_vector(4 downto 0);


    num_reflects  : in std_logic_vector(2 downto 0);

    camera_center : in vector;

    addition_hor : in vector;

    addition_ver : in vector;

    addition_base : in vector;

    outputRay	: out ray;

    done	: out std_logic;
    valid	: out std_logic

  );

end getRayDirAlt;

architecture arch of getRayDirAlt is

constant one : std_logic_vector(31 downto 0) := x"00010000";
constant zero : std_logic_vector(31 downto 0) := x"00000000";

constant basisColourVector : vector := (x => one, y => one, z => one);
constant blackVector : vector := (x => zero, y => zero, z => zero);

signal next_done, next_copyRay, next_valid : std_logic;

signal next_sob, next_eob : std_logic;

signal ver_base, next_result, next_result_hold, result_hold, next_ver_base, ran_add, next_ran_add : vector;
signal next_i, j, next_j, i, samples, next_samples : natural;
signal next_frame_no, frame_no : std_logic_vector(1 downto 0);
signal ran : std_logic_vector(31 downto 0) := x"00000000";

signal address : natural := 0;
signal next_address : natural;

component lfsr is
  port (
    cout   :out std_logic_vector (7 downto 0);-- Output of the counter
    enable :in  std_logic;                    -- Enable counting
    clk    :in  std_logic;                    -- Input rlock
    reset  :in  std_logic                     -- Input reset
  );
end component;


constant max_width : natural := MAXWIDTH - 1;

constant max_height : natural := MAXHEIGHT - 1;

begin
l1 : lfsr port map(cout => ran(31 downto 24), clk => clk, reset => reset, enable => clk_en);
l2 : lfsr port map(cout => ran(23 downto 16), clk => clk, reset => reset, enable => clk_en);
l3 : lfsr port map(cout => ran(15 downto 8), clk => clk, reset => reset, enable => clk_en);
l4 : lfsr port map(cout => ran(7 downto 0), clk => clk, reset => reset, enable => clk_en);
async : process(j, i, start, addition_ver, frame, hold, addition_hor, result_hold, ran_add, ran, num_samples, address, ver_base, addition_base) is begin
next_frame_no <= frame;
next_copyRay <= hold;
next_done <= '0';
next_sob <= '0';
next_eob <= '0';
next_ran_add <= addition_ver + addition_hor;
next_result <= result_hold;
next_result_hold <= result_hold;

next_ver_base <= ver_base; --MK
next_j <= j;	--MK
next_i <= i;	--MK
next_address <= address; --MK
next_samples <= samples; --MK

if valid_data = '0' then
	next_valid <= '0';
	next_copyRay <= '0';
	next_j <= 0;
	next_i <= 0;
else 
	next_valid <= '1';
	if start =  '1' then
		next_j <= 0;
		next_i <= 0;
		next_result <= addition_base;
		next_ver_base <= addition_base;
		next_result_hold <= addition_base;
		next_done <= '0';
		next_samples <= 1;
		next_sob <= '1';
		if num_samples = "00001" then
			next_eob <= '1';
		end if;
		next_address <= 0;
	else
		if samples >= unsigned(num_samples) then
			next_address <= address + 1;
			next_samples <= 1;
			next_sob <= '1';
			if num_samples = "00001" then
				next_eob <= '1';
				if j = max_height AND i = max_width -1 then
					next_done <= '1';
				end if;
			end if;
			if i >= max_width then
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
				next_ver_base <= ver_base;
			end if;
		else
			if samples = unsigned(num_samples) - 1 then
				next_eob <= '1';
				if j = max_height AND i = max_width then
					next_done <= '1';
				end if;
			end if;
			next_address <= address;
			next_samples <= samples + 1;
			next_j <= j;
			next_i <= i;
			next_valid <= '1';
			next_result <= result_hold + (ran_add and ran);
			next_result_hold <= result_hold;
		end if;
		
	end if;
end if;
end process;

sync : process(clk, reset, clk_en, hold) is begin
if reset = '1' then
	samples <= 1;
	i <= 0;
	j <= 0;
	result_hold <= (x => (OTHERS => '0'), y => (OTHERS => '0'), z => (OTHERS => '0'));
	ver_base <= (x => (OTHERS => '0'), y => (OTHERS => '0'), z => (OTHERS => '0'));
	done <= '0';
	ran_add <= (x => (OTHERS => '0'), y => (OTHERS => '0'), z => (OTHERS => '0'));
	outputRay.direction <= (OTHERS => (OTHERS => '0'));
	outputRay.sob <= '0';
	outputRay.eob <= '0';
	outputRay.position <= (OTHERS => '0');
	outputRay.origin <= (OTHERS => (OTHERS=> '0'));
	outputRay.color <= basisColourVector;
	outputRay.remaining_reflects <= (OTHERS => '0');
	outputRay.pseudo_refl <= '0';
	outputRay.valid <= '0';
	valid <= '0';
	address <= 0;
	outputRay.copy <= '0';
elsif rising_edge(clk) AND clk_en = '1' then
	outputRay.copy <= next_copyRay;
	if hold = '0' then
		samples <= next_samples;
		i <= next_i;
		j <= next_j;
		outputRay.direction <= next_result;
		outputRay.sob <= next_sob;
		outputRay.eob <= next_eob;
		outputRay.position(21 downto 20) <= next_frame_no;
		--outputRay.position(19 downto 10) <= std_logic_vector(to_unsigned(next_i, 10));
		--outputRay.position(9 downto 0) <= std_logic_vector(to_unsigned(next_j, 10));
		outputRay.position(19 downto 0) <= std_logic_vector(to_unsigned(next_address, 20));
		outputRay.origin <= camera_center;
		outputRay.color <= basisColourVector;
		outputRay.remaining_reflects <= num_reflects;
		--outputRay.copy <= next_copy;
		outputRay.valid <= next_valid;
		result_hold <= next_result_hold;
		ver_base <= next_ver_base;
		valid <= next_valid;
		done <= next_done;
		ran_add <= next_ran_add;
		outputRay.pseudo_refl <= '0';
		address <= next_address;
	end if;
end if;
end process;


end architecture;
