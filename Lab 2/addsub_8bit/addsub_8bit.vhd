-- Input as Tri-stated (and not with weak pulll-up) important
-- Make sure project name matches file names
-- Make sure device marked in Programmer is the DE0-CV
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity addsub_8bit is
    port (
        -- Input ports
        -- KEY0/1 for latching, SW0-7 for 8-bit binary number input, SW8 unused, SW9 indicates add/sub
        KEY			  : in STD_LOGIC_VECTOR(1 downto 0);
        SW          : in STD_LOGIC_VECTOR(9 downto 0);
        -- Output ports
        -- LEDR indicates result
        LEDR 	     : out STD_LOGIC_VECTOR(7 downto 0)
    );
end addsub_8bit;

architecture mytest of addsub_8bit is
    -- Define variables to hold 8-bit values
    signal a    : signed(7 downto 0);
    signal b    : signed(7 downto 0);
    signal ans  : signed(8 downto 0);
begin
    process(KEY, SW)
    begin
        if(KEY(0) = '0') then
            a <= signed(SW(7 downto 0));
        end if;
        if(KEY(1) = '0') then
            b <= signed(SW(7 downto 0));
        end if;
    end process;
ans <= ('0' & a) + ('0' & (not b)+1) when SW(9) = '1' else ('0' & a) + ('0' & b);
LEDR <= STD_LOGIC_VECTOR(abs(ans(7 downto 0)));

end architecture mytest;