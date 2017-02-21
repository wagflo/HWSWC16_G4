
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.operations_pkg.all;

entity picture_data is
	port(
	w : in std_logic;
	address : std_logic_vector(15 downto 0);
	writedata : std_logic_vector(31 downto 0);
	frames : out frame_array;
	sc : out scene;
	write_poss : out std_logic;
	clk : in std_logic;
	reset : in std_logic;
	clk_en : in std_logic
	);
end entity;

architecture arch of picture_data is
constant zero : std_logic_vector(31 downto 0) := (others=> '0');
constant zero_vector : vector := (x => zero, y => zero, z => zero);
constant initial_frame : frame_info := (all_info => '0', 
	camera_origin => zero_vector,
	addition_base => zero_vector,
	addition_hor => zero_vector,
	addition_ver => zero_vector,
	frame_no => (OTHERS => '0'));
signal sc_sig : scene;
signal frames_sig : frame_array := (OTHERS => initial_frame);
signal number_filled : natural := 0;

signal t, sphere, elem, coord : std_logic_vector(3 downto 0);

constant finish_frame : std_logic_vector(3 downto 0) := X"F";
constant change_spheres : std_logic_vector(3 downto 0) := X"1";
constant change_general : std_logic_vector(3 downto 0) := X"2";
constant change_frame : std_logic_vector(3 downto 0) := X"3";
constant radius : std_logic_vector(3 downto 0) := X"1";
constant radius2 : std_logic_vector(3 downto 0) := X"2";
constant center : std_logic_vector(3 downto 0) := X"3";
constant x : std_logic_vector(3 downto 0) := X"1";
constant y : std_logic_vector(3 downto 0) := X"2";
constant z : std_logic_vector(3 downto 0) := X"3";
constant camera_origin : std_logic_vector(3 downto 0) := X"1";
constant addition_base : std_logic_vector(3 downto 0) := X"2";
constant addition_hor : std_logic_vector(3 downto 0) := X"3";
constant addition_ver : std_logic_vector(3 downto 0) := X"4";
constant frame_no : std_logic_vector(3 downto 0) := X"5";


begin

t <= address(15 downto 12);
sphere <= address(11 downto 8);
elem <= address(7 downto 4);
coord <= address(3 downto 0);

write_poss <= '1' when number_filled < 2 else '0';
async_update : process(address, w, writedata) is begin
if w = '1' then
	if t = finish_frame then
		--the current frame has all data
		frames(number_filled).all_info <= '1';
		number_filled <= number_filled + 1;
	elsif t = change_spheres then
		---change a parameter of a sphere
		if elem = radius then
			sc_sig.spheres(to_integer(unsigned(sphere))).radius <= writedata;
		elsif elem = radius2 then
			sc_sig.spheres(to_integer(unsigned(sphere))).radius2 <= writedata;
		elsif elem = center then
			if coord = x then
				sc_sig.spheres(to_integer(unsigned(sphere))).center.x <= writedata;
			elsif coord = y then
				sc_sig.spheres(to_integer(unsigned(sphere))).center.y <= writedata;
			elsif coord = z then
				sc_sig.spheres(to_integer(unsigned(sphere))).center.z <= writedata;
			end if;
		end if;
	elsif t = change_general then
		--update the general data
		sc_sig.num_spheres <= writedata(31 downto 24);
		sc_sig.num_reflects <= writedata(23 downto 16);
		sc_sig.num_samples <= writedata(15 downto 8);
	elsif t = change_frame then
		--set a param in the camera position
		if elem = camera_origin then
			if coord = x then
				frames_sig(number_filled).camera_origin.x <= writedata;
			elsif coord = y then
				frames_sig(number_filled).camera_origin.y <= writedata;
			elsif coord = z then
				frames_sig(number_filled).camera_origin.z <= writedata;
			end if;
		elsif elem = addition_base then
			if coord = x then
				frames_sig(number_filled).addition_base.x <= writedata;
			elsif coord = y then
				frames_sig(number_filled).addition_base.y <= writedata;
			elsif coord = z then
				frames_sig(number_filled).addition_base.z <= writedata;
			end if;
		elsif elem = addition_hor then
			if coord = x then
				frames_sig(number_filled).addition_hor.x <= writedata;
			elsif coord = y then
				frames_sig(number_filled).addition_hor.y <= writedata;
			elsif coord = z then
				frames_sig(number_filled).addition_hor.z <= writedata;
			end if;
		elsif elem = addition_ver then
			if coord = x then
				frames_sig(number_filled).addition_ver.x <= writedata;
			elsif coord = y then
				frames_sig(number_filled).addition_ver.y <= writedata;
			elsif coord = z then
				frames_sig(number_filled).addition_ver.z <= writedata;
			end if;
		elsif elem = frame_no then
			frames_sig(number_filled).frame_no <= writedata(1 downto 0);
		end if;
	end if;
	
end if;
end process;

output : process(clk, reset, clk_en) is begin
if reset = '1' then
	---
elsif rising_edge(clk) and clk_en = '1' then
	frames <= frames_sig;
	sc <= sc_sig;
end if;
end process;


end architecture;