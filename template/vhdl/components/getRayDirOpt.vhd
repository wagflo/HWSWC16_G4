library ieee;
use ieee.std_logic_1164.all;
use work.operations_pkg.all;
use IEEE.numeric_std.all;

entity getRayDirOpt is

port(

    clk 	: in std_logic;
    clk_en 	: in std_logic;
    reset 	: in std_logic;
    start 	: in std_logic;

    frame	: in std_logic_vector(1 downto 0);

    num_samples_i : in std_logic_vector(2 downto 0);

    num_samples_j : in std_logic_vector(2 downto 0); 

    addition_hor : in vector;

    addition_ver : in vector;

    addition_base : in vector;
    
    result	: out vector;

    position	: out std_logic_vector (21 downto 0);
    done	: out std_logic

  );

end getRayDirOpt;

architecture arch of getRayDirOpt is

signal last_j_vector, last_i_vector, last_sample_base : vector;

signal next_vector, addition_result, addition_input1, addition_input2 : vector;

signal i, j, sample_i, sample_j, last_i, last_j, last_sample_i, last_sample_j : natural;

signal next_done : std_logic;

constant max_width : natural := 799;

constant max_height : natural := 479;

begin

add : vector_add_sub 
  port map (

    x1 => addition_input1.x,
    y1 => addition_input1.y,
    z1 => addition_input1.z,

    x2 => addition_input2.x,
    y2 => addition_input2.y,
    z2 => addition_input2.z,

    add_sub => '1',
    reset => reset,
    clk => clk,
    clk_en => clk_en,
	
    x => addition_result.x,
    y => addition_result.y,
    z => addition_result.z

  );

async : process(start, last_i, last_j, last_sample_i, last_sample_j) is begin
if start = '1' then 
	i <= 0;
	j <= 0;
	sample_i <= 1;
	sample_j <= 1;
	addition_input1 <= addition_base;
	addition_input2 <= addition_hor;
	last_j_vector <= addition_base;
	last_i_vector <= addition_base;
	last_sample_base <= addition_base;
else
	if last_sample_i >= unsigned(num_samples_i) then
		if last_sample_j >= unsigned(num_samples_j) then
			if last_i >= max_width then
				i <= 0;
				j <= last_j + 1;
				sample_i <= 1;
				sample_j <= 1;
				last_sample_base <= addition_result;
			else
				i <= last_i + 1;
				sample_i <= 1;
				sample_j <= 1;
				last_sample_base <= addition_result;
				if last_i = 1 then
					last_j_vector <= addition_result;
				end if;
			end if;
		else
			sample_j <= last_sample_j + 1;
			sample_i <= 1;
			last_sample_base <= addition_result;
		end if;
	else
		sample_i <= last_sample_i + 1;
	end if;

	if (last_sample_i = unsigned(num_samples_i)-1 OR (last_sample_i = 1 AND num_samples_i = "001")) AND last_sample_j = 1 then
		last_i_vector <= addition_result;
	end if;

	if last_sample_i >= unsigned(num_samples_i)-1 then
		if last_sample_j >= unsigned(num_samples_j) - 1 then
			if last_i >= max_width - 1 then
				addition_input1 <= last_j_vector;
				addition_input2 <= addition_ver;
			else
				addition_input1 <= last_i_vector;
				addition_input2 <= addition_hor;
			end if;
		else
			addition_input1 <= last_sample_base;
			addition_input2 <= addition_ver;
		end if;
	else
		addition_input1 <= addition_result;
		addition_input2 <= addition_hor;
	end if;
					
			
	
end if;
end process;

result <= addition_base when start = '1' else addition_result;

next_done <= '1' when (sample_i = unsigned(num_samples_i) AND sample_j = unsigned(num_samples_j) AND i = max_width AND j = max_height) else '0';

sync : process(clk, clk_en, reset) is begin
if reset = '1' then
	
elsif rising_edge(clk) AND clk_en = '1' then
	last_i <= i;
	last_j <= j;
	last_sample_i <= sample_i;
	last_sample_j <= sample_j;
	done <= next_done;
	position(21 downto 20) <= frame;
	position(19 downto 10) <= std_logic_vector(to_unsigned(i, 10));
	position(9 downto 0) <= std_logic_vector(to_unsigned(j, 10));
	
end if;
end process;

end architecture;