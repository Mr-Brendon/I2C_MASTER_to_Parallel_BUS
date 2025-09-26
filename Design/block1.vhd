----------------------------------------------------------------------------------
--NOTE: IT IS JUST USED FOR SIMULATION PURPOSE.
--IT SIMULATES SLAVE: ACK OR DATA TRASMITION.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity block1 is
    port(block_in: in std_logic;
         block_out: inout std_logic
         );
end block1;

architecture Behavioral of block1 is


begin

block_out <= '0' when block_in = '0' else 'Z';
                 
end Behavioral;
