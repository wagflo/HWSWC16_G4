
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.delay_pkg.all;
use work.operations_pkg.all;
use work.components_pkg.all;

entity raytracing_mm is
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		--memory mapped slave
		address   : in  std_logic_vector(31 downto 0);
		write     : in  std_logic;
		read      : in  std_logic;
		writedata : in  std_logic_vector(31 downto 0);
		readdata  : out std_logic_vector(31 downto 0)
		
		--framereader master
		
	);
end entity;

architecture arch of raytracing_mm is

constant zero : std_logic_vector(31 downto 0) := (others=> '0');
constant zero_vector : vector := (x => zero, y => zero, z => zero);
constant initial_frame : frame_info := (all_info => '0', 
	camera_origin => zero_vector,
	addition_base => zero_vector,
	addition_hor => zero_vector,
	addition_ver => zero_vector,
	frame_no => (OTHERS => '0'));

signal sc : scene;
signal frames : frame_array := (OTHERS => initial_frame);

constant can_write : std_logic_vector(31 downto 0) := X"00000000";
constant finish_frame : std_logic_vector(31 downto 0) := X"FFFFFFFF";
constant change_scene : std_logic_vector(31 downto 0) := X"10000000";
constant change_frame : std_logic_vector(31 downto 0) := X"20000000";
constant radius : std_logic_vector(31 downto 0) := X"00000010";
constant radius2 : std_logic_vector(31 downto 0) := X"00000020";
constant center : std_logic_vector(31 downto 0) := X"00000030";
constant x : std_logic_vector(31 downto 0) := X"00000001";
constant y : std_logic_vector(31 downto 0) := X"00000002";
constant z : std_logic_vector(31 downto 0) := X"00000003";
constant camera_origin : std_logic_vector(31 downto 0) := X"00000010";
constant addition_base : std_logic_vector(31 downto 0) := X"00000020";
constant addition_hor : std_logic_vector(31 downto 0) := X"00000030";
constant addition_ver : std_logic_vector(31 downto 0) := X"00000040";

signal next_readdata : std_logic_vector(31 downto 0);
signal t, elem, coord : std_logic_vector(3 downto 0);

begin

next_readdata(31 downto 1) <= (OTHERS => '0');
next_readdata(0) <= frames(0).all_info AND frames(1).all_info;

syn : process(res_n, clk) is begin
	if res_n = '1' then 
		frames <= (OTHERS => initial_frame);
		readdata <= (OTHERS => '0');
	elsif rising_edge(clk) then
		readdata <= next_readdata;
	end if;
end process;

t <= address(31 downto 28);
elem <= address(7 downto 4);
coord <= address(3 downto 0);

asyn : process(

end architecture;


