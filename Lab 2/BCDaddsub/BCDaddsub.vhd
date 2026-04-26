library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity BCDaddsub is
    port (
        -- Input ports
        -- KEY0/1 for latching b/a, SW0-7 for 8-bit binary number input, SW8 unused, SW9 indicates add/sub
        KEY				: in STD_LOGIC_VECTOR(1 downto 0);
        SW          	: in STD_LOGIC_VECTOR(9 downto 0);
        -- Output ports
        -- LEDR3 indicates display overflow. 0-1=Sum, 2-3=b, 4-5=a
        LEDR			: out STD_LOGIC_VECTOR(9 downto 0);
		  HEX0			: out STD_LOGIC_VECTOR(0 to 6);
		  HEX1			: out STD_LOGIC_VECTOR(0 to 6);
		  HEX2			: out STD_LOGIC_VECTOR(0 to 6);
		  HEX3			: out STD_LOGIC_VECTOR(0 to 6);
		  HEX4			: out STD_LOGIC_VECTOR(0 to 6);
		  HEX5			: out STD_LOGIC_VECTOR(0 to 6)
    );
end BCDaddsub;

architecture mytest of BCDaddsub is
    -- Define variables to hold 1st and 2nd BCD digits of operands and sum (4-bit per digit).
   signal a0, a1, b0, b1    	: STD_LOGIC_VECTOR(3 downto 0);
   signal sum0, sum1  			: STD_LOGIC_VECTOR(3 downto 0);
	signal Ci0, Ci1, Co0, Co1	: STD_LOGIC; -- Carry in and Carry out
	signal subflag					: STD_LOGIC;
	 
	component bcd_to_7seg is
		port(
			bcd : in STD_LOGIC_VECTOR(3 downto 0);
			output : out STD_LOGIC_VECTOR(0 to 6)
		);
	end component;
	
	component addsub is
		port(
			a, b 							: in STD_LOGIC_VECTOR(3 downto 0);
			C_in, sub					: in STD_LOGIC;
			C_out							: out STD_LOGIC;
			sum							: out STD_LOGIC_VECTOR(3 downto 0)
		);
	end component;	
	
	signal lsb_carry, msb_carry		: STD_LOGIC; -- msb_carry unused?
	
	 
begin
	process(SW, KEY)
	begin
		if KEY(0) = '0' then
			b0 <= SW(3 downto 0);
			b1 <= SW(7 downto 4);
		end if;
		if KEY(1)='0' then
			a0 <= SW(3 downto 0);
			a1 <= SW(7 downto 4);
		end if;
	end process;
	subflag <= SW(9);
	
	add_lsb : addsub port map (
		a => a0, 
		b => b0, 
		C_in => subflag, 
		sub => subflag,
		C_out => lsb_carry,
		sum => sum0
	);
	
	add_msb : addsub port map (
		a => a1, 
		b => b1, 
		C_in => lsb_carry, 
		sub => subflag,
		C_out => msb_carry,
		sum => sum1
	);
	LEDR(3) <= msb_carry; -- If msb_carry = 1, sum is greater than 2-bits.
	
	HEX0_out : bcd_to_7seg port map(bcd => sum0, output => HEX0);
	HEX1_out : bcd_to_7seg port map(bcd => sum1, output => HEX1);
	HEX2_out : bcd_to_7seg port map(bcd => b0, output => HEX2);
	HEX3_out : bcd_to_7seg port map(bcd => b1, output => HEX3);
	HEX4_out : bcd_to_7seg port map(bcd => a0, output => HEX4);
	HEX5_out : bcd_to_7seg port map(bcd => a1, output => HEX5);
	
end architecture mytest;