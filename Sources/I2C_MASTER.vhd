----------------------------------------------------------------------------------
-- 
--
--busy is usually high, it is low when you can change data for the all low time,
--(better if you change the data with interrupt, so in falling edge).
--for changing slave index, you can do it whenever you want: state machine undertakes to manage it.
--NOTE: always when SDA is high impedance, master has to control if SDA is high and not low. Otherwise it has to stop trasmission, MULTI MASTER DETECTION.
--NOTE: always when SCL is high impedance, master has to control if SCL ia high, otherwise there is a striching by slave.
--If it was easy, everyone would do it, this game is not easy and it's better that way.
--IMPORTANT: master requires 3 clock sections: half count to switch SCL from high or low, 3/4 count to pre-set SDA due to latency of bus
--and the last, so the entire period to restart clock again and set proper signals.
--NOTE: if master has to read SDA, it sets SDA = 'Z' immediately when SCL = '0'.
--
--
----------------------------------------------------------------------------------
--COME STRACAZZO E' POSSIBILE CHE SE BEVO LA MONSTER E MI SENTO SUBITO EUFORICO BHOO
--NOTA io prima faccio il count che aspetta ed alla fine del ciclo la lettura/scrittura, essendo che alla fine lo stop dovrà avere il ciclo che aspetta esempio
--il nack o gli altri, poi dovra avere un doppio count perchè l'idle non ce l'a prima il count, quindi lo stop dovrà farlo prima per lo stato prima
--e poi dopo per il suo stato. STA ROBA DIREI CHE E DA SCRIVERE IN INGLESE PERCHE E IMPORTANTE.



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity I2C_MASTER_CORE is
    generic(ic_frequency: integer := 27000000;        --INSERT VALUE: frequency of ic, in this case gowin fpga works with 27MHz clock.
            frequency_I2C: integer := 100000          --INSERT VALUE: this is the effective transmission clock, it is used to count how many clk pulses are needed of internal fpga clock.
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
signal clk_count: integer := 0;                                       --used by counter to get 100kHz or others...
signal bit_count: integer := 0;                                       --used to send/recieve bit by bit.
signal reg_rw_index: std_logic_vector(7 downto 0) := (others => '0'); --used to concatenate rw and reg_index signals.
signal buffer_io: std_logic_vector(7 downto 0) := (others => '0');    --used to write next data value.


begin
--GESTIRE IL BUSY !!!!!!!!!!!!!!!!!!!!!!!!!!!!
--Nota che buffer è solo per il dato da inviare, quello che si riceve bisogna gestirlo!!!!!!!!!!!!!!!!!!!!!!!




Merge: reg_rw_index <= rw & reg_index;              --it is usefull because in the counter we want to send all bits with just one condition, so < 8.

--probabilmente serve perchè il buffer deve essere caricato prima, va bene quando entra in indrw_state? 
Sample: process(RESET, current_state)
begin
    if(RESET = '0') then
        buffer_io <= (others => '0');
    elsif(current_state = indrw_bit) then           --it executes here just ones, when state changes from idle_bit to indrw_bit.
        buffer_io <= reg_io;
    end if;

end process;


I2C_SM: process(RESET, CLK)
begin

    if(RESET = '0') then
        current_state <= idle_bit;
        buffer_io <= (others => '0');
        reg_io <= (others => 'Z');              --it is important because if the value is high or low it could create a short-circuit.
        nack_error <= '0';
        bus_taken <= '0';--probabilmente usato poi per il multi_master
        clk_count <= 0;
        bit_count <= 0;
        busy <= '1';
        SDA <= 'Z';
        SCL <= 'Z';
        
        
    elsif(rising_edge(CLK)) then
        case current_state is
            
            
            
            
            
            when idle_bit =>                    --here there is not buffer_io cause it could store next frame.
                reg_io <= (others => 'Z');
                nack_error <= '0';
                bus_taken <= '0';--probabilmente usato poi per il multi_master
                clk_count <= 0;
                bit_count <= 0;
                busy <= '0';                    --here busy is equal to '0' so master is free.
                SDA <= 'Z';
                SCL <= 'Z';
                
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
                busy <= '1';                                    --buffer occupied for half comunication time.
                
                if(clk_count < (clk_per_bit-1)/2) then          --change SCL each half period.
                        SCL <= 'Z';
                else
                        SCL <= '0';
                end if;
                                                                --slave index starts with rising edge, so SCL has to wait one period of frequency_I2C to be high again.
                
                if(bit_count < 8) then                          --it counts from 0 to 7 (7 index bits and also r/w bit), then it reads ACK.
                    
                    if(clk_count = (clk_per_bit-1)*3/4) then    --before index starts, master needs to precharge index bit to stability reason, 3/4 of period is enought.
                        
                                                                    --7 - bit_count because master sends from MSB to LSB and r/w bit, so from 7(MSB) to 0(r/w).
                        if(reg_rw_index(7-bit_count) = '0') then    --to set SDA to '0' or 'Z' a condition is needed, otherwise it can't perform high impedance
                            SDA <= '0';                             --with just this code line: SDA <= reg_rw_index(7 - bit_count)
                        else
                            SDA <= 'Z';
                        end if;


                    elsif(clk_count = clk_per_bit-1) then
                        clk_count <= 0;
                        bit_count <= bit_count + 1;             --bit_count is updated just when clk_count reaches clk_per_bit-1.
                    
                    else
                        clk_count <= clk_count + 1;
                    end if;
                   
                elsif(bit_count = 8) then                       --pay attention bit_count <= 1 just at current_state <= wr or rd.
                
                
                    if(clk_count = (clk_per_bit-1)/2) then
                        SDA <= 'Z';                             --Everytime SDA is used like an input, it requires to be setted high impedance in low edge SCL.
                    
                    
                    elsif(clk_count = clk_count-1) then
                        
                        clk_count <= 0;                         --ACK/NACK management
                        
                        if(SDA = '0') then
                            
                            if(rw = '0') then                   --ACK management
                                current_state <= wr_bit;        --writing state.
                            else
                                current_state <= rd_bit;        --reading state.
                            end if;
                                                                -- --> ricorda che io faccio sempre prima il ciclo e poi la lettura perche lho fatto cosi,
                                                                --quindi il tempo del nack e il tempo che scorre nello stop, ricorda poi che nello stop
                                                                --dovra poi aspettare poi dopo lo stop stesso
                        else                                    --NACK management
                            current_state <= stop_bit;
                        end if;
                        
                        clk_count <= 0;
                        bit_count <= 0;   
                        
                    else
                        clk_count <= clk_count + 1;
                    
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
                
                
                if(bit_count < 8) then  --poi vedi se è effettivamente 8 o altro

                    
                    if(clk_count = (clk_per_bit-1)*3/4) then    --before data starts, master needs to precharge data bit to stability reason, 3/4 of period is enought.
                        SDA <= reg_rw_index(7 - bit_count);--qui ci va buffer_io
                        
                    elsif(clk_count = clk_per_bit-1) then
                        clk_count <= 0;
                        bit_count <= bit_count + 1;             --bit_count is updated just when clk_count reaches clk_per_bit-1.
                    
                    else
                        clk_count <= clk_count + 1;
                    end if;
                    
                    
                elsif(bit_count = 8) then ---vedere se 8 è giusto
                
                    --gestire lultimo bit dopo data credo qui ci sia ack
                    
                    
                else                                            --it will not enter here cause bit_count = 8 (9 bits) is the max allowed.
                    
                    current_state <= idle_bit;
                    bit_count <= 0;
                    clk_count <= 0;
                    
 
                    
                    
                end if;
                
                
                
         
                
            
            when others =>
                current_state <= idle_bit;
                
        end case;
    end if;

end process;

       

end I2C_CORE_bh;



--FORSE HO FINITO DI FARE ORA DEVO PRIMA FARE UNA PULITA DEL CODICE, POI UN CONTROLLO SE E' FATTO BENE, SE LA LOGICA FUNZIONA, POI STUDIO DOVE SONO ARRIVATO
--PER I PROSSIMI STATI.
--forse sarebbe anche ora di creare un testbench perchè sennò tutta sta monnezza non funziona

--poi guardo se il codice è scritto sensato logicamente e metto bene l'aspetto del codice







