
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.operations_pkg.all;

entity picture_data is
	port(
	w : in std_logic;
	address : in std_logic_vector(15 downto 0);
	writedata : in std_logic_vector(31 downto 0);
	frames : out frame_array;
	sc : out scene;
	write_poss : out std_logic;
	clk : in std_logic;
	reset : in std_logic;
	clk_en : in std_logic;
	next_frame : in std_logic;
	start : out std_logic;
	valid_data : out std_logic;
	frames_done : in std_logic_vector(1 downto 0)
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
constant initial_sphere : sphere := (center => zero_vector, colour => zero_vector, radius => zero, radius2 => zero, emitting => '0');
constant initial_spheres : sphere_array := (OTHERS => initial_sphere);
constant initial_scene : scene := (num_spheres => (OTHERS => '0'), num_reflects=> (OTHERS => '0'), num_samples=> (OTHERS => '0'),
	spheres => initial_spheres, sphere_enable => (OTHERS => '0'), address1 => (OTHERS => '0'), address2 => (OTHERS => '0'), pic_done=> (OTHERS => '0'));
signal frames_out, frames_sig : frame_array;
--signal number_filled : natural := 0;
signal start_sig, start_out : std_logic;

signal sc_sig, sc_out : scene;

signal t, sphere, elem, coord : std_logic_vector(3 downto 0);

signal last_frames_done, next_last_frames_done : std_logic_vector(1 downto 0);

signal next_last_nextframe, last_nextframe : std_logic;

constant finish_frame : std_logic_vector(3 downto 0) := X"F";
constant change_spheres : std_logic_vector(3 downto 0) := X"1";
constant change_general : std_logic_vector(3 downto 0) := X"2";
constant change_frame : std_logic_vector(3 downto 0) := X"3";
constant change_address : std_logic_vector(3 downto 0) := X"4";
constant reset_data : std_logic_vector(3 downto 0) := X"5";

constant radius : std_logic_vector(3 downto 0) := X"1";
constant radius2 : std_logic_vector(3 downto 0) := X"2";
constant center : std_logic_vector(3 downto 0) := X"3";
constant color : std_logic_vector(3 downto 0) := X"4";
constant emitting : std_logic_vector(3 downto 0) := X"5";

constant x : std_logic_vector(3 downto 0) := X"1";
constant y : std_logic_vector(3 downto 0) := X"2";
constant z : std_logic_vector(3 downto 0) := X"3";

constant camera_origin : std_logic_vector(3 downto 0) := X"1";
constant addition_base : std_logic_vector(3 downto 0) := X"2";
constant addition_hor : std_logic_vector(3 downto 0) := X"3";
constant addition_ver : std_logic_vector(3 downto 0) := X"4";
constant frame_no : std_logic_vector(3 downto 0) := X"5";
constant address1 : std_logic_vector(3 downto 0) := X"1";
constant address2 : std_logic_vector(3 downto 0) := X"2";

begin

t <= address(15 downto 12);
sphere <= address(11 downto 8);
elem <= address(7 downto 4);
coord <= address(3 downto 0);

write_poss <= NOT(frames_out(1).all_info) OR NOT(frames_out(0).all_info);
valid_data <= frames_out(0).all_info;


async_write : process(sc_out, frames_out, w, address, writedata, next_frame, last_nextframe, frames_done, last_frames_done, t, sphere, elem, coord) is begin
start_sig <= '0';
frames_sig <= frames_out;
sc_sig <= sc_out;
next_last_nextframe <= next_frame OR last_nextframe;
next_last_frames_done <= last_frames_done OR frames_done;
	if w = '1' then
		--start <= '0';
		if t = finish_frame then
			--the current frame has all data
			if frames_out(0).all_info = '0' then
				frames_sig(0).all_info <= '1';
				start_sig <= '1';
			else
				frames_sig(1).all_info <= '1';
			end if;
		elsif t = change_address then
 			if elem = address1 then
				sc_sig.address1 <= writedata;
			elsif elem = address2 then
				sc_sig.address2 <= writedata;
			end if;
		elsif t = change_spheres then
		---change a parameter of a sphere
		if elem = radius then
			case sphere is
				when "0000" => sc_sig.spheres(0).radius <= writedata;
				when "0001" => sc_sig.spheres(1).radius <= writedata;
				when "0010" => sc_sig.spheres(2).radius <= writedata;
				when "0011" => sc_sig.spheres(3).radius <= writedata;
				when "0100" => sc_sig.spheres(4).radius <= writedata;
				when "0101" => sc_sig.spheres(5).radius <= writedata;
				when "0110" => sc_sig.spheres(6).radius <= writedata;
				when "0111" => sc_sig.spheres(7).radius <= writedata;
				when "1000" => sc_sig.spheres(8).radius <= writedata;
				when "1001" => sc_sig.spheres(9).radius <= writedata;
				when "1010" => sc_sig.spheres(10).radius <= writedata;
				when "1011" => sc_sig.spheres(11).radius <= writedata;
				when "1100" => sc_sig.spheres(12).radius <= writedata;
				when "1101" => sc_sig.spheres(13).radius <= writedata;
				when "1110" => sc_sig.spheres(14).radius <= writedata;
				when "1111" => sc_sig.spheres(15).radius <= writedata;
				when others =>
					null;
			end case;
			--sc_sig.spheres(to_integer(unsigned(sphere))).radius <= writedata;
		elsif elem = radius2 then
			case sphere is
				when "0000" => sc_sig.spheres(0).radius2 <= writedata;
				when "0001" => sc_sig.spheres(1).radius2 <= writedata;
				when "0010" => sc_sig.spheres(2).radius2 <= writedata;
				when "0011" => sc_sig.spheres(3).radius2 <= writedata;
				when "0100" => sc_sig.spheres(4).radius2 <= writedata;
				when "0101" => sc_sig.spheres(5).radius2 <= writedata;
				when "0110" => sc_sig.spheres(6).radius2 <= writedata;
				when "0111" => sc_sig.spheres(7).radius2 <= writedata;
				when "1000" => sc_sig.spheres(8).radius2 <= writedata;
				when "1001" => sc_sig.spheres(9).radius2 <= writedata;
				when "1010" => sc_sig.spheres(10).radius2 <= writedata;
				when "1011" => sc_sig.spheres(11).radius2 <= writedata;
				when "1100" => sc_sig.spheres(12).radius2 <= writedata;
				when "1101" => sc_sig.spheres(13).radius2 <= writedata;
				when "1110" => sc_sig.spheres(14).radius2 <= writedata;
				when "1111" => sc_sig.spheres(15).radius2 <= writedata;
				when others =>
					null;
			end case;
			--sc_sig.spheres(to_integer(unsigned(sphere))).radius2 <= writedata;
		elsif elem = center then
			if coord = x then
				case sphere is
					when "0000" => sc_sig.spheres(0).center.x <= writedata;
					when "0001" => sc_sig.spheres(1).center.x <= writedata;
					when "0010" => sc_sig.spheres(2).center.x <= writedata;
					when "0011" => sc_sig.spheres(3).center.x <= writedata;
					when "0100" => sc_sig.spheres(4).center.x <= writedata;
					when "0101" => sc_sig.spheres(5).center.x <= writedata;
					when "0110" => sc_sig.spheres(6).center.x <= writedata;
					when "0111" => sc_sig.spheres(7).center.x <= writedata;
					when "1000" => sc_sig.spheres(8).center.x <= writedata;
					when "1001" => sc_sig.spheres(9).center.x <= writedata;
					when "1010" => sc_sig.spheres(10).center.x <= writedata;
					when "1011" => sc_sig.spheres(11).center.x <= writedata;
					when "1100" => sc_sig.spheres(12).center.x <= writedata;
					when "1101" => sc_sig.spheres(13).center.x <= writedata;
					when "1110" => sc_sig.spheres(14).center.x <= writedata;
					when "1111" => sc_sig.spheres(15).center.x <= writedata;
					when others =>
						null;
				end case;
				elsif coord = y then
					case sphere is
					when "0000" => sc_sig.spheres(0).center.y <= writedata;
					when "0001" => sc_sig.spheres(1).center.y <= writedata;
					when "0010" => sc_sig.spheres(2).center.y <= writedata;
					when "0011" => sc_sig.spheres(3).center.y <= writedata;
					when "0100" => sc_sig.spheres(4).center.y <= writedata;
					when "0101" => sc_sig.spheres(5).center.y <= writedata;
					when "0110" => sc_sig.spheres(6).center.y <= writedata;
					when "0111" => sc_sig.spheres(7).center.y <= writedata;
					when "1000" => sc_sig.spheres(8).center.y <= writedata;
					when "1001" => sc_sig.spheres(9).center.y <= writedata;
					when "1010" => sc_sig.spheres(10).center.y <= writedata;
					when "1011" => sc_sig.spheres(11).center.y <= writedata;
					when "1100" => sc_sig.spheres(12).center.y <= writedata;
					when "1101" => sc_sig.spheres(13).center.y <= writedata;
					when "1110" => sc_sig.spheres(14).center.y <= writedata;
					when "1111" => sc_sig.spheres(15).center.y <= writedata;
					when others =>
						null;
					end case;
				elsif coord = z then
					case sphere is
					when "0000" => sc_sig.spheres(0).center.z <= writedata;
					when "0001" => sc_sig.spheres(1).center.z <= writedata;
					when "0010" => sc_sig.spheres(2).center.z <= writedata;
					when "0011" => sc_sig.spheres(3).center.z <= writedata;
					when "0100" => sc_sig.spheres(4).center.z <= writedata;
					when "0101" => sc_sig.spheres(5).center.z <= writedata;
					when "0110" => sc_sig.spheres(6).center.z <= writedata;
					when "0111" => sc_sig.spheres(7).center.z <= writedata;
					when "1000" => sc_sig.spheres(8).center.z <= writedata;
					when "1001" => sc_sig.spheres(9).center.z <= writedata;
					when "1010" => sc_sig.spheres(10).center.z <= writedata;
					when "1011" => sc_sig.spheres(11).center.z <= writedata;
					when "1100" => sc_sig.spheres(12).center.z <= writedata;
					when "1101" => sc_sig.spheres(13).center.z <= writedata;
					when "1110" => sc_sig.spheres(14).center.z <= writedata;
					when "1111" => sc_sig.spheres(15).center.z <= writedata;
					when others =>
						null;
					end case;
					--sc_sig.spheres(to_integer(unsigned(sphere))).center.z <= writedata;
				end if;
			elsif elem = color then
				if coord = x then
					case sphere is
					when "0000" => sc_sig.spheres(0).colour.x <= writedata;
					when "0001" => sc_sig.spheres(1).colour.x <= writedata;
					when "0010" => sc_sig.spheres(2).colour.x <= writedata;
					when "0011" => sc_sig.spheres(3).colour.x <= writedata;
					when "0100" => sc_sig.spheres(4).colour.x <= writedata;
					when "0101" => sc_sig.spheres(5).colour.x <= writedata;
					when "0110" => sc_sig.spheres(6).colour.x <= writedata;
					when "0111" => sc_sig.spheres(7).colour.x <= writedata;
					when "1000" => sc_sig.spheres(8).colour.x <= writedata;
					when "1001" => sc_sig.spheres(9).colour.x <= writedata;
					when "1010" => sc_sig.spheres(10).colour.x <= writedata;
					when "1011" => sc_sig.spheres(11).colour.x <= writedata;
					when "1100" => sc_sig.spheres(12).colour.x <= writedata;
					when "1101" => sc_sig.spheres(13).colour.x <= writedata;
					when "1110" => sc_sig.spheres(14).colour.x <= writedata;
					when "1111" => sc_sig.spheres(15).colour.x <= writedata;
					when others =>
						null;
					end case;
					--sc_sig.spheres(to_integer(unsigned(sphere))).center.x <= writedata;
				elsif coord = y then
					case sphere is
					when "0000" => sc_sig.spheres(0).colour.y <= writedata;
					when "0001" => sc_sig.spheres(1).colour.y <= writedata;
					when "0010" => sc_sig.spheres(2).colour.y <= writedata;
					when "0011" => sc_sig.spheres(3).colour.y <= writedata;
					when "0100" => sc_sig.spheres(4).colour.y <= writedata;
					when "0101" => sc_sig.spheres(5).colour.y <= writedata;
					when "0110" => sc_sig.spheres(6).colour.y <= writedata;
					when "0111" => sc_sig.spheres(7).colour.y <= writedata;
					when "1000" => sc_sig.spheres(8).colour.y <= writedata;
					when "1001" => sc_sig.spheres(9).colour.y <= writedata;
					when "1010" => sc_sig.spheres(10).colour.y <= writedata;
					when "1011" => sc_sig.spheres(11).colour.y <= writedata;
					when "1100" => sc_sig.spheres(12).colour.y <= writedata;
					when "1101" => sc_sig.spheres(13).colour.y <= writedata;
					when "1110" => sc_sig.spheres(14).colour.y <= writedata;
					when "1111" => sc_sig.spheres(15).colour.y <= writedata;
					when others =>
						null;
					end case;
					--sc_sig.spheres(to_integer(unsigned(sphere))).center.y <= writedata;
				elsif coord = z then
					case sphere is
					when "0000" => sc_sig.spheres(0).colour.z <= writedata;
					when "0001" => sc_sig.spheres(1).colour.z <= writedata;
					when "0010" => sc_sig.spheres(2).colour.z <= writedata;
					when "0011" => sc_sig.spheres(3).colour.z <= writedata;
					when "0100" => sc_sig.spheres(4).colour.z <= writedata;
					when "0101" => sc_sig.spheres(5).colour.z <= writedata;
					when "0110" => sc_sig.spheres(6).colour.z <= writedata;
					when "0111" => sc_sig.spheres(7).colour.z <= writedata;
					when "1000" => sc_sig.spheres(8).colour.z <= writedata;
					when "1001" => sc_sig.spheres(9).colour.z <= writedata;
					when "1010" => sc_sig.spheres(10).colour.z <= writedata;
					when "1011" => sc_sig.spheres(11).colour.z <= writedata;
					when "1100" => sc_sig.spheres(12).colour.z <= writedata;
					when "1101" => sc_sig.spheres(13).colour.z <= writedata;
					when "1110" => sc_sig.spheres(14).colour.z <= writedata;
					when "1111" => sc_sig.spheres(15).colour.z <= writedata;
					when others =>
						null;
					end case;
					--sc_sig.spheres(to_integer(unsigned(sphere))).center.z <= writedata;
				end if;
			elsif elem = emitting then
				case sphere is
					when "0000" => sc_sig.spheres(0).emitting <= writedata(0);
					when "0001" => sc_sig.spheres(1).emitting <= writedata(0);
					when "0010" => sc_sig.spheres(2).emitting <= writedata(0);
					when "0011" => sc_sig.spheres(3).emitting <= writedata(0);
					when "0100" => sc_sig.spheres(4).emitting <= writedata(0);
					when "0101" => sc_sig.spheres(5).emitting <= writedata(0);
					when "0110" => sc_sig.spheres(6).emitting <= writedata(0);
					when "0111" => sc_sig.spheres(7).emitting <= writedata(0);
					when "1000" => sc_sig.spheres(8).emitting <= writedata(0);
					when "1001" => sc_sig.spheres(9).emitting <= writedata(0);
					when "1010" => sc_sig.spheres(10).emitting <= writedata(0);
					when "1011" => sc_sig.spheres(11).emitting <= writedata(0);
					when "1100" => sc_sig.spheres(12).emitting <= writedata(0);
					when "1101" => sc_sig.spheres(13).emitting <= writedata(0);
					when "1110" => sc_sig.spheres(14).emitting <= writedata(0);
					when "1111" => sc_sig.spheres(15).emitting <= writedata(0);
					when others =>
						null;
					end case;
				--sc_sig.spheres(to_integer(unsigned(sphere))).emitting <= writedata(0);
			end if;
		elsif t = change_general then
			--update the general data
			sc_sig.num_spheres <= X"0" & writedata(31 downto 28);
			sc_sig.num_reflects <= X"0" & writedata(27 downto 24);
			sc_sig.num_samples <= writedata(23 downto 16);
			sc_sig.sphere_enable <= writedata(15 downto 0);
		elsif t = change_frame then
			--set a param in the camera position
			if elem = camera_origin then
				if coord = x then
					if frames_out(0).all_info = '0' then
						frames_sig(0).camera_origin.x <= writedata;
					else
						frames_sig(1).camera_origin.x <= writedata;
					end if;
				elsif coord = y then
					if frames_out(0).all_info = '0' then
						frames_sig(0).camera_origin.y <= writedata;
					else
						frames_sig(1).camera_origin.y <= writedata;
					end if;
				elsif coord = z then
					if frames_out(0).all_info = '0' then
						frames_sig(0).camera_origin.z <= writedata;
					else
						frames_sig(1).camera_origin.z <= writedata;
					end if;
				end if;
			elsif elem = addition_base then
				if coord = x then
					if frames_out(0).all_info = '0' then
						frames_sig(0).addition_base.x <= writedata;
					else
						frames_sig(1).addition_base.x <= writedata;
					end if;
				elsif coord = y then
					if frames_out(0).all_info = '0' then
						frames_sig(0).addition_base.y <= writedata;
					else
						frames_sig(1).addition_base.y <= writedata;
					end if;
				elsif coord = z then
					if frames_out(0).all_info = '0' then
						frames_sig(0).addition_base.z <= writedata;
					else
						frames_sig(1).addition_base.z <= writedata;
					end if;
				end if;
			elsif elem = addition_hor then
				if coord = x then
					if frames_out(0).all_info = '0' then
						frames_sig(0).addition_hor.x <= writedata;
					else
						frames_sig(1).addition_hor.x <= writedata;
					end if;
				elsif coord = y then
					if frames_out(0).all_info = '0' then
						frames_sig(0).addition_hor.y <= writedata;
					else
						frames_sig(1).addition_hor.y <= writedata;
					end if;
				elsif coord = z then
					if frames_out(0).all_info = '0' then
						frames_sig(0).addition_hor.z <= writedata;
					else
						frames_sig(1).addition_hor.z <= writedata;
					end if;
				end if;
			elsif elem = addition_ver then
				if coord = x then
					if frames_out(0).all_info = '0' then
						frames_sig(0).addition_ver.x <= writedata;
					else
						frames_sig(1).addition_ver.x <= writedata;
					end if;
				elsif coord = y then
					if frames_out(0).all_info = '0' then
						frames_sig(0).addition_ver.y <= writedata;
					else
						frames_sig(1).addition_ver.y <= writedata;
					end if;
				elsif coord = z then
					if frames_out(0).all_info = '0' then
						frames_sig(0).addition_ver.z <= writedata;
					else
						frames_sig(1).addition_ver.z <= writedata;
					end if;
				end if;
			elsif elem = frame_no then
				if frames_out(0).all_info = '0' then
					frames_sig(0).frame_no <= writedata(1 downto 0);
				else
					frames_sig(1).frame_no <= writedata(1 downto 0);
				end if;
				if writedata(0) = '0' then --MK vl umgekehrt?
					sc_sig.pic_done(0) <= '0';
				else 
					sc_sig.pic_done(1) <= '0';
				end if;
			end if;
		end if;
	elsif next_frame = '1' OR last_nextframe = '1' then
		start_sig <= frames_out(1).all_info;
		frames_sig(0) <= frames_out(1);
		frames_sig(1) <= initial_frame;
		next_last_nextframe <= '0';
	elsif frames_done /= "00" OR last_frames_done /= "00" then
		sc_sig.pic_done <= sc_out.pic_done OR frames_done OR last_frames_done;
		next_last_frames_done <= "00";
	end if;
end process;

output : process(clk, reset, clk_en) is begin
if reset = '1' then
	sc_out <= initial_scene;
	frames_out <= (OTHERS => initial_frame);
	start_out <= '0';
	last_nextframe <= '0';
	last_frames_done <= (OTHERS => '0');
elsif rising_edge(clk) then
	sc_out <= sc_sig;
	frames_out <= frames_sig;
	start_out <= start_sig;
	last_nextframe <= next_last_nextframe;
	last_frames_done <= next_last_frames_done;
end if;
end process;

frames <= frames_out;
sc <= sc_out;
start <= start_out;
end architecture;
