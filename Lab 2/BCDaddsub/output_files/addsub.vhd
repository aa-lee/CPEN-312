library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_unsigned.all; -- important to define '+'

entity addsub is
	port(
		a, b 							: in STD_LOGIC_VECTOR(3 downto 0);
		C_in, sub					: in STD_LOGIC;
		C_out							: out STD_LOGIC;
		sum							: out STD_LOGIC_VECTOR(3 downto 0)
	);
end addsub;	
	
architecture a of addsub is
	signal sum_W, sum_withCarry, b_W		: STD_LOGIC_VECTOR(4 downto 0);
	begin
	
	process (b, sub) is
	begin
		-- 9's complement table
		if sub = '1' then
			case b is
				when "0000" => b_W<="01001";
				when "0001" => b_W<="01000";
				when "0010" => b_W<="00111";
				when "0011" => b_W<="00110";
				when "0100" => b_W<="00101";
				when "0101" => b_W<="00100";
				when "0110" => b_W<="00011";
				when "0111" => b_W<="00010";
				when "1000" => b_W<="00001";
				when "1001" => b_W<="00000";
				when others => b_W<="00000";
			end case;
		else
			b_W <= ('0' & b);
		end if;
	end process;
	
	process (a, b_W, C_in)
	begin
		-- If addition, C_in = 0. Sum unaffected a+b. If sub, C_in = 1. e.g 5-3=2 => 00101+00110=01011 +1=01100 +5=10010 = 2
		-- For 0-0, you get 00000+01001+1=01010 > 9, => so C_out = 1
		sum_W <= ('0' & a) + b_W + ("0000" & C_in);
		sum_withCarry <= sum_W + "00110";
		if (sum_W > 9) then
			C_out <= '1';
			sum <= sum_withCarry(3 downto 0);
		else
			C_out <= '0';
			sum <= sum_W(3 downto 0);
		end if; 
	end process;
end a;