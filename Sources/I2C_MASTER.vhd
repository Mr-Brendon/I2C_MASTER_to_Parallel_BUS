----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------
--busy is usually high, it is low when you can change data for the all low time,
--(better if you change the data with interrupt, so in falling edge).
--for changing slave index, you can do it whenever you want: state machine undertakes to manage it.
--NOTE: always when SDA is high impedance, master has to control if SDA is high and not low. Otherwise it has to stop trasmission, MULTI MASTER DETECTION.
--NOTE: always when SCL is high impedance, master has to control if SCL ia high, otherwise there is a striching by slave.
--If it was easy, everyone would do it, this game is not easy and it's better that way.
--importante da trascrivere in inglese: sembra che ci vogliano tre sezioni del clock, a metà per SCL high o low, a 3/4 per caricare SDA e per il finale ossia l'intero periodo.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity I2C_MASTER_CORE is
    generic(ic_frequency: integer := 27000000;        --INSERT VALUE: frequency of ic, in this case gowin fpga works with 27MHz clock.
            frequency_I2C: integer := 100000          --INSERT VALUE: this is the effective transmission clock, it is used to count ok many clk pulses needed if internal fpga clock.
            );
    port(CLK, RESET, start, rw: in std_logic;
         reg_index: in std_logic_vector(6 downto 0);  --index of slave
         reg_io: inout std_logic_vector(7 downto 0);  --data byte
         SDA, SCL: inout std_logic;                   --SDA and SCL line from standard
         nack_error, bus_taken, busy: out std_logic   --nack_error = '1' when slave not found or data byte got some troubles by slave. bus_taken = '1' error when
                                                      --multi-master conflicts. busy = '1' when master is not ready to get NEW DATA BITS AND RW BIT, so during half
                                                      --data transission end others da vedere gli altri casi e quando è libero!!!!!!!!!
                                                                                                            
         );
end I2C_MASTER_CORE;

architecture I2C_CORE_bh of I2C_MASTER_CORE is

constant clk_per_bit: integer := ic_frequency/frequency_I2C;
type SM is (idle_bit, indrw_bit, wr_bit, rd_bit, ack2_bit, master_ack_bit, stop_bit);
signal current_state: SM := idle_bit;
signal clk_count: integer := 0;                     --used by counter to get 100kHz or others...
signal bit_count: integer := 0;                     --used to send/recieve bit by bit.
signal reg_rw_index: std_logic_vector(7 downto 0) := (others => '0'); --used to concatenate rw and reg_index signals.
signal buffer_io: std_logic_vector(7 downto 0) := (others => '0');


begin
--GESTIRE IL BUSY !!!!!!!!!!!!!!!!!!!!!!!!!!!![2]
--Questo potrebbe essere un buon codice per implementare busy = '0' a meta trasmissione, da fare sugli stati di leggere e scrivere.
--Essendo che bit_count lo setto poi a zero sempre alla fine degli stati, posso utilizzarlo poi anche negli altri stati.
--------------------------------------------------------------------------------------------------------------------
                --if(bit_count = 5) then                          --this code line is used to set busy = '0' in the middle ol data transmition.
                --    busy <= '0';                                --input device has half data trasmition time to write or read another value in burrer_io
                --end if;
--------------------------------------------------------------------------------------------------------------------
--Nota che buffer è solo per il dato da inviare, quello che si riceve bisogna gestirlo!!!!!!!!!!!!!!!!!!!!!!!

Merge: reg_rw_index <= rw & reg_index;  --it is usefull cause in the counter we want to send all bit with just one condition, so < 8.

--probabilmente serve perchè il buffer deve essere caricato prima, va bene quando entra in indrw_state? 
Sample: process(RESET, current_state) --è bene non aver paura di creare più process, in questo modo posso far fare una cosa ad uno stato solo una volta anche se lo stato dura per un po'.
begin
    if(RESET = '0') then
        buffer_io <= (others => '0');
    elsif(current_state = indrw_bit) then           --it executes here just ones, when state changes from idle_bit to indrw_bit.
        buffer_io <= reg_io;
    end if;

end process;

--
--I2C_SM: process(RESET, CLK)
--begin
--
--    if(RESET = '0') then
--        current_state <= idle_bit;
--        buffer_io <= (others => '0');
--        high_low_check <= '0';
--        clk_count <= 0;
--        nack_error <= '0';
--        bus_taken <= '0';
--        busy <= '1';
--        SDA <= 'Z';
--        SCL <= 'Z';
--    end if;
--    
    
    
-----------------------------------------

I2C_SM: process(RESET, CLK)
begin

    if(RESET = '0') then
        current_state <= idle_bit;
        clk_count <= 0;
        busy <= '1';
        SDA <= 'Z';
        SCL <= 'Z';
        
    elsif(rising_edge(CLK)) then
        case current_state is
            
            when idle_bit =>--mettere tutti i segnali a 0...!!!!!!!!!!!!![3]
                busy <= '0';
                
                if(start = '1') then            --start comunication.
                    current_state <= indrw_bit;
                    SDA <= '0';--poi ci andrà da controllare
                    SCL <= 'Z';
                else
                    current_state <= idle_bit;   --it is not needed but usefull to clarify.
                    SDA <= 'Z';
                    SCL <= 'Z';
                end if;
                
                
                
            when indrw_bit =>
                busy <= '1';
                
                if(clk_count < (clk_per_bit-1)/2) then          --change SCL each half period.
                        SCL <= 'Z';
                else
                        SCL <= '0';
                end if;
                                                                --slave index starts with rising edge, so SCL has to wait one period of frequency_I2C to be high again.
                if(bit_count < 8) then                          --it counts from 0 to 7 (7 index bits and also r/w bit), then it reads ACK.
                    
                    if(clk_count = (clk_per_bit-1)*3/4) then    --before index starts, master needs to precharge index bit to stability reason, 3/4 of period is enought.
                        SDA <= reg_rw_index(7 - bit_count);     --7 - bit_count because master sends from MSB to LSB and r/w bit, so from 7(MSB) to 0(r/w).
                                                                --!!!!!!!!!poi ci dovrà essere il controllo prima se SDA è zero per il multi master
                    elsif(clk_count = clk_per_bit-1) then
                        clk_count <= 0;
                        bit_count <= bit_count + 1;             --bit_count deve essere aggiornato solo una volta che finisce l'intero ciclo del clock.
                    
                    else
                        clk_count <= clk_count + 1;
                    end if;
                   
                
                elsif(bit_count = 8) then                       --pay attention bit_count <= 0 just at the end of state, so when current_state <= wr or rd.
                
                     if(SDA = '0') then                         --ACK menagement.
                        if(clk_count = clk_per_bit-1) then      --reading SDA, if it is in rising edge of SCL, but it lasts for an entire SCL period.
                            if(rw = '0') then
                                current_state <= wr_bit;        --writing state        mi sa che devo precaricare il primo bit di dati a 3/4 non a clk_per_bit
                            else
                                current_state <= rd_bit;        --reading state       qui forse è apposto perche e lo slava che lo fa
                            end if;
                            clk_count <= 0;
                            bit_count <= 0;
                        else
                            clk_count <= clk_count + 1 ;
                        end if;
                     
                     else
                                                                --NACK menagement.
                        nack_error <= '1';                      --theorically nack_error lasts an entire clock cycle, so it has to wait for ic_frequency/frequency_I2C.
                        if(clk_count = clk_per_bit-1) then--non so se alla fine dopo current state mettere il nack_error a 0!!!!!!
                            clk_count <= 0;
                            current_state <= stop_bit; --(gestire il busy nello stop_bit)poi fare bene lo stop_bit state dico nel case when stop_bit non qui.
                            bit_count <= 0;
                        else
                            clk_count <= clk_count + 1;
                        end if;
                     end if;

                else                                            --it will not enter here cause bit_count = 8 (9 bits) is the max allowed.
                    
                    current_state <= idle_bit;
                    bit_count <= 0;
                    clk_count <= 0;
                    
                end if;
                    
            when wr_bit=>
                if(clk_count < (clk_per_bit-1)/2) then          --change SCL each half period.
                        SCL <= 'Z';
                else
                        SCL <= '0';
                end if;
                
                
                if(bit_count = 5) then                          --this code line is used to set busy = '0' in the middle of data transmition.
                    busy <= '0';                                --input device has half data trasmition time to write or read another value in burrer_io
                end if;
                
                
                if(bit_count = 0) then       --devo mettere prima gia il primo bit subito credo, poi anticipare a 3/4 il secondo e poi si puo andare con laltro if fino a 8
                                             --se 0 qui sennò se minore di 8 ma non zero dilà
                
                
                elsif(bit_count < 8) then  --poi vedi se è effettivamente 8 o altro
                    

                    --forse essendo gia stato aspettato un clk_per_bit bisognarebbe gia far partire il primo bit di dato, da controllare
                    --oppure se questo viene difficile forse si puo togliere il waiting di clk_per_bit sopra in indrw_bit, l0'ultimo, però non so
                    --se è semplice e non rompe tutto.
                    
                    if(clk_count = (clk_per_bit-1)*3/4) then    --before data starts, master needs to precharge data bit to stability reason, 3/4 of period is enought.
                        SDA <= reg_rw_index(7 - bit_count);
                        
                    elsif(clk_count = clk_per_bit-1) then
                        clk_count <= 0;
                        bit_count <= bit_count + 1;             --bit_count deve essere aggiornato solo una volta che finisce l'intero ciclo del clock.
                    
                    else
                        clk_count <= clk_count + 1;
                    end if;
                    
                    
                    
                    
                    
                    
                    
                end if;
                
                
                
                
                
                
                
                
                
                
                
                
            
            when others =>
                current_state <= idle_bit;
                
        end case;
    end if;

end process;

       

end I2C_CORE_bh;




