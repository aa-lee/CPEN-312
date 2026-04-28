LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

-- SW(9) used to turn alarm on/off and to indicate if KEY(3 downto 0) latches alarm values
-- SW(8) used to set AM/PM
-- SW(7 downto 4) sets hms MSD, SW(3 downto 0) sets hms LSD
-- KEY(3 downto 0) latches AM/PM, hours, minutes, seconds, respectively.
-- HEX5/4 : hr, HEX3/2 : min, HEX1/0 : sec, LEDR9 : AM/PM, LEDR0 : alarm!
-- CLK_50 is PIN_M9. Spent hours wondering why the clock didn't clock...

entity clock is
	port(
		CLK_50	: in STD_LOGIC;
		KEY		: in STD_LOGIC_VECTOR(3 downto 0);
		SW			: in STD_LOGIC_VECTOR(9 downto 0);
		HEX0		: out STD_LOGIC_VECTOR(0 to 6);
		HEX1		: out STD_LOGIC_VECTOR(0 to 6);
		HEX2		: out STD_LOGIC_VECTOR(0 to 6);
		HEX3		: out STD_LOGIC_VECTOR(0 to 6);
		HEX4		: out STD_LOGIC_VECTOR(0 to 6);
		HEX5		: out STD_LOGIC_VECTOR(0 to 6);
		LEDR		: out STD_LOGIC_VECTOR(9 downto 0)
	);
end clock;

architecture a of clock is
	component bcd_to_7seg is
		port(
			bcd		: in STD_LOGIC_VECTOR(3 downto 0);
			output	: out STD_LOGIC_VECTOR(6 downto 0)
		);
	end component;
	
	signal h0, h1, m0, m1, s0, s1				: STD_LOGIC_VECTOR(3 downto 0);
	signal ah0, ah1, am0, am1, as0, as1		: STD_LOGIC_VECTOR(3 downto 0);
	signal AMPM, alarmAMPM, alarmFlag		: STD_LOGIC;
	
	-- From BCDCount example
	signal ClkFlag				: STD_LOGIC;
	signal Internal_Count	: STD_LOGIC_VECTOR(28 downto 0);
	
	begin
	
	HEX0_disp : bcd_to_7seg port map(bcd => s0, output => HEX0);
	HEX1_disp : bcd_to_7seg port map(bcd => s1, output => HEX1);
	HEX2_disp : bcd_to_7seg port map(bcd => m0, output => HEX2);
	HEX3_disp : bcd_to_7seg port map(bcd => m1, output => HEX3);
	HEX4_disp : bcd_to_7seg port map(bcd => h0, output => HEX4);
	HEX5_disp : bcd_to_7seg port map(bcd => h1, output => HEX5);
	LEDR(9) <= AMPM;
	LEDR(0) <= alarmFlag;
	
	-- Also from BCDCount. CLK_50 is a signal that runs at 50MHz
	PROCESS(CLK_50)
	BEGIN
		if(CLK_50'event and CLK_50='1') then
			if Internal_Count<250000 then	-- 25000000 for 1 second
				Internal_Count<=Internal_Count+1;
			else
				Internal_Count<=(others => '0'); 
				ClkFlag<=not ClkFlag;
			end if;
		end if;
	END PROCESS;
	
	-- Important to have everything that modifies h0, h1... under the same process.
	-- Otherwise, you get "because its behavior does not match any supported register model" error which I don't understand.
	process(ClkFlag, KEY, SW)
	begin
		-- Reset all to 12h59m59s AM
		if(KEY(3) = '0' and KEY(0) = '0') then
			h1 <= "0001";
			h0 <= "0010";
			m1 <= "0101";
			m0 <= "1001";
			s1 <= "0101";
			s0 <= "1001";
			ah1 <= "0001";
			ah0 <= "0010";
			am1 <= "0101";
			am0 <= "1001";
			as1 <= "0101";
			as0 <= "1001";
			AMPM <= '0';	
			alarmAMPM <= '0';
		
		-- Ripple counter clock action
		elsif(ClkFlag'event and ClkFlag = '1') then
			if(s0 = 9) then
				s0 <= "0000";
				if(s1 = 5) then
					s1 <= "0000";
					if(m0 = 9) then
						m0 <= "0000";
						if(m1 = 5) then
							m1 <= "0000";
							if(h1 = "0001" and h0 = "0010") then
								h1 <= "0000";
								h0 <= "0001";
							elsif(h0 = 9) then
									h0 <= "0000";
									h1 <= h1+'1';
							else h0 <= h0+'1';
							end if;
							if (h1 = "0001" and h0 = "0001") then
								AMPM <= not AMPM;
							end if;
						else m1 <= m1+'1';
						end if;
					else m0 <= m0+'1';
					end if;
				else s1 <= s1+'1';
				end if;
			else s0 <= s0+'1';
			end if;
		
			-- The elsif(ClkFlag...) changes h0, h1... on a clocked basis. 
			-- As such, setting h0, h1... must happen on a clocked basis. 
			-- If not it throws an "because it does not hold its value outside the clock edge" error.	
			-- Setting current time. SW9 = off 
			if(SW(9) = '0') then
				if(KEY(3) = '0') then
					AMPM <= SW(8);
				end if;
				if(KEY(2) = '0') then
					h0 <= SW(3 downto 0);
					h1 <= SW(7 downto 4);
				end if;
				if(KEY(1) = '0') then
					m0 <= SW(3 downto 0);
					m1 <= SW(7 downto 4);
				end if;
				if(KEY(0) = '0') then
					s0 <= SW(3 downto 0);
					s1 <= SW(7 downto 4);
				end if;
				
			-- Setting alarm time. SW9 = on (also alarm enabled)
			elsif(SW(9) = '1') then
				if(KEY(3) = '0') then
					alarmAMPM <= SW(8);
				end if;
				if(KEY(2) = '0') then
					ah0 <= SW(3 downto 0);
					ah1 <= SW(7 downto 4);
				end if;
				if(KEY(1) = '0') then
					am0 <= SW(3 downto 0);
					am1 <= SW(7 downto 4);
				end if;
				if(KEY(0) = '0') then
					as0 <= SW(3 downto 0);
					as1 <= SW(7 downto 4);
				end if;
				alarmAMPM <= SW(8);
			end if;
			
			-- Check if alarm time
			if (	h1 = ah1 and 
					h0 = ah0 and
					m1 = am1 and
					m0 = am0 and
					s1 = as1 and
					s0 = as0 and
					AMPM = alarmAMPM and
					SW(9) = '1') then
				alarmFlag <= '1';
			else alarmFlag <= '0';
			end if;
		end if;
	end process;

end a;