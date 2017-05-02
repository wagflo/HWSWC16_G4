library ieee;
use ieee.std_logic_1164.all;

use work.operations_pkg.all;

package rayDelay_pkg is
component rayDelay is
	generic (DELAY_LENGTH : NATURAL := 1);
port (clk, reset, clk_en : in std_logic;
inputRay : in ray; outputRay : out ray);
  end component rayDelay;

  --procedure delay(source, dest : std_logic_vector; cycles : natural := 0; clk, reset, clken : std_logic_vector);

end package rayDelay_pkg;
