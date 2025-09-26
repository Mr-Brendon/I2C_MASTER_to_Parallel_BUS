----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity testbench is
    generic(ic_frequency: integer := 27000000;        --INSERT VALUE: frequency of ic, in this case gowin fpga works with 27MHz clock.
            frequency_I2C: integer := 100000;         --INSERT VALUE: this is the effective transmission clock, it is used to count how many clk pulses are needed of internal fpga clock.
            HIGH_TO_LOW: integer range 2 to 3:= 2
            );
end testbench;

architecture test of testbench is

component I2C_MASTER_CORE is
    port(CLK, RESET, start, rw: in std_logic;
         reg_index: in std_logic_vector(6 downto 0);  --index of slave
         reg_io: inout std_logic_vector(7 downto 0);  --data byte
         SDA, SCL: inout std_logic;                   --SDA and SCL line from standard
         nack_error, bus_taken, busy: out std_logic;   --nack_error = '1' when slave not found or data byte got some troubles by slave. bus_taken = '1' error when
         bus_wait, rd_flag: out std_logic
        );                                            --multi-master conflicts. busy = '1' when master is not ready to get NEW DATA BITS AND RW BIT, so during half
                                                      --data transission(second half byte) end when is in idle_state
end component;

component block1 is
    port(block_in: in std_logic;
         block_out: inout std_logic
         );
end component;

signal CLK, RESET, start, rw: std_logic := '0';
signal reg_index: std_logic_vector(6 downto 0);  --index of slave
signal reg_io: std_logic_vector(7 downto 0);
signal SDA_bus, SCL_bus: std_logic;
signal nack_error, bus_taken,  busy: std_logic;
signal block_in, bus_wait, rd_flag: std_logic;

begin

IC_map: I2C_MASTER_CORE port map(CLK => CLK, RESET => RESET, start => start, rw => rw, reg_index => reg_index, reg_io => reg_io,
                                 SDA => SDA_bus, SCL => SCL_bus, nack_error => nack_error, bus_taken => bus_taken, busy => busy, bus_wait => bus_wait, rd_flag => rd_flag); 

IC2_map: block1 port map(block_in => block_in, block_out => SDA_bus);

Weak1_1: SDA_bus <= 'H';
Weak2_1: SCL_bus <= 'H';

test1: process
begin
    wait for 18 ns;
    CLK <= '0';
    wait for 19 ns;
    CLK <= '1';
end process;


test2: process
begin
    
    
    --reset
    RESET <= '0';
    start <= '0';
    rw <= '1';
    reg_index <= (others => '1');
    wait for 20 ns;
    
    
    --rw from 0 to 1 and vice versa
    --set all data for transmition
    block_in <= '1';
    RESET <= '1';
    --reg_index <= "1010111";
    reg_io <= (others => 'Z');
    wait for 20 ns;
    
    start <= '1';
    
    
    --at 87 us I set SDA to 0 to perform ank bit, then I'll release SDA at 97 ns.
    wait for 87 us;
    block_in <= '0';
    wait for 10 us;
    block_in <= '1';
    
    --set new data frame at 157 us
    wait for 40 us;
    block_in <= '1';
    wait for 20 us;
    block_in <= '1';
    wait for 20 us;
    --177 us
    block_in <= '1';
    wait for 10 us;
    block_in <= '1';
    wait for 33 us;
    --220
    rw <= '0';
    --reg_io <= "10101010";
    wait for 5 us;
    block_in <= '1';
    wait for 10 us;
    block_in <= '1';
    wait for 10 us;
    wait for 22 us;
    block_in <= '1';
    wait for 10 us;
    block_in <= '1';
    wait for 23 us;
    --300 us
    reg_io <= "10101010";
    wait for 70 us;
    --370
    block_in <= '0';
    wait for 10 us;
    block_in <= '1';
    wait for 20 us;
    --400 us;
    wait for 20 us;
    --420 us;
    rw <= '1';
    reg_io <= (others => 'Z');
    wait for 38 us;
    --458 us;
    block_in <= '0';
    wait for 10 us;
    block_in <= '1';
    wait for 94 us;
    --562 us;
    block_in <= '0';
    wait for 10 us;
    block_in <= '1';
    wait for 200 us;
    start <= '0';

    --end code.
    wait for 10 ms;
    std.env.stop;

end process;



end test;



