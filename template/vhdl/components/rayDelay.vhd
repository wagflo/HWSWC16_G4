library ieee;
use ieee.std_logic_1164.all;

use work.delay_pkg.all;

use work.operations_pkg.all;

entity rayDelay is 
generic (DELAY_LENGTH : NATURAL := 1);
port (inputRay : in ray; outputRay : out ray);
end entity;

