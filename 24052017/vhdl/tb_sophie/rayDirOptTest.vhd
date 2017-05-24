library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.operations_pkg.all;

entity rayDirOptTest is

end entity;

architecture arch of rayDirOptTest is 


component getRayDirOpt is

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

  ); end component;

constant zero : std_logic_vector(95 downto 0) := (OTHERS => '0');
constant one : std_logic_vector(95 downto 0) := (80 => '1', 48 => '1', 16 => '1', OTHERS => '0');
constant zero_vector : vector := tovector(zero);
constant one_vector : vector := tovector(one);

signal start : std_logic := '1';
signal reset : std_logic := '1';
signal clk : std_logic := '0';
signal done : std_logic;

signal r : vector;
signal position : std_logic_vector(21 downto 0);

begin

clk <= not(clk) after 5 ns;
reset <= '0' after 10 ns;
start <= '0' after 25 ns;

test : getRayDirOpt port map(
	clk => clk, clk_en => '1', reset => reset, start => start,
	frame => "00", num_samples_i => "001", num_samples_j => "001",
	addition_hor => one_vector, addition_ver => one_vector, addition_base => zero_vector,
	result => r, done => done, position => position
);



end architecture;