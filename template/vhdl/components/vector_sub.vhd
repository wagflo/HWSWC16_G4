library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library lpm;
use lpm.lpm_components.all;

entity vector_sub is

port (
	x1, y1, z1 : in std_logic_vector(31 downto 0);
	x2, y2, z2 : in std_logic_vector(31 downto 0);
	
	x, y, z : out std_logic_vector(31 downto 0)
);


end entity;

architecture arch of vector_sub is
component sub IS
	PORT
	(
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END component;

begin
x_sub : sub port map (dataa => x1, datab => x2, result => x);
y_sub : sub port map (dataa => y1, datab => y2, result => y);
z_sub : sub port map (dataa => z1, datab => z2, result => z);

end architecture;
