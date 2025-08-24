----------------------------------------------------------------------------------
-- 
--
--busy is usually high, it is low when you can change data for the all low time,
--(better if you change the data with interrupt, so in falling edge, but master doesn't store new data immediately, but when it enters in indrw_bit or wr_bit).
--for changing slave index, you can do it whenever you want: state machine undertakes to manage it.
--NOTE: always when SDA is high impedance, master has to control if SDA is high and not low. Otherwise it has to stop trasmission, MULTI MASTER DETECTION.
--NOTE: always when SCL is high impedance, master has to control if SCL ia high, otherwise there is a striching by slave.
--If it was easy, everyone would do it, this game is not easy and it's better that way.
--IMPORTANT: master requires 3 clock sections: half count to switch SCL from high or low, 3/4 count to pre-set SDA due to latency of bus
--and the last, so the entire period to restart clock again and set proper signals.
--NOTE: if master has to read SDA, it sets SDA = 'Z' immediately when SCL = '0'.
--ic_frequency >> frequency_I2C, -> ic_frequency >= 20 * frequency_I2C.
--
--
----------------------------------------------------------------------------------
--COME STRACAZZO E' POSSIBILE CHE SE BEVO LA MONSTER E MI SENTO SUBITO EUFORICO BHOO
--NOTA io prima faccio il count che aspetta ed alla fine del ciclo la lettura/scrittura, essendo che alla fine lo stop dovrà avere il ciclo che aspetta esempio
--il nack o gli altri, poi dovra avere un doppio count perchè l'idle non ce l'a prima il count, quindi lo stop dovrà farlo prima per lo stato prima
--e poi dopo per il suo stato. STA ROBA DIREI CHE E DA SCRIVERE IN INGLESE PERCHE E IMPORTANTE.


--forse su stop non serve mettere il busy a 1 dato che poi torna a 0 quindi dove mi serve che vada a 1 lo metto prima? poi ci penso

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
        );                                            --multi-master conflicts. busy = '1' when master is not ready to get NEW DATA BITS AND RW BIT, so during half
                                                      --data transission(second half byte) end when is in idle_state
end I2C_MASTER_CORE;

architecture I2C_CORE_bh of I2C_MASTER_CORE is

constant clk_per_bit: integer := ic_frequency/frequency_I2C;
type SM is (idle_bit, indrw_bit, wr_bit, rd_bit, timing_bit, stop_bit);
signal current_state: SM := idle_bit;
signal clk_count: integer := 0;                                       --used by counter to get 100kHz or others...
signal bit_count: integer := 0;                                       --used to send/recieve bit by bit.
signal reg_rw_index: std_logic_vector(7 downto 0) := (others => '0'); --used to concatenate rw and reg_index signals.
signal buffer_io: std_logic_vector(7 downto 0) := (others => '0');    --used to write/read next data value.
signal past_index: std_logic_vector(6 downto 0) := (others => '0');   --used like buffer to compare with current reg_index.
signal temp: integer range 0 to 1:= 0;                                --used to do double SCL clicle: first for ACK/NACK statement, second one for stop_bit
                                                                      --because idle doesn't start with an if(clk_count = clk_per_bit),
                                                                      --so mastes has to do the stop_bit cicle inside stop_bit statement.

begin

--allora parliamo di buffer_io, puo essere usato sia in in che out, devo vedere che posso usarlo in entrambi i casi, vedendo se è possibile
--gestire la transizione di buffer_io da in ad out e viceversa. inoltre devo considerare che di defeault reg_io deve essere tri-state per evitare conflitti
--o peggio cortocircuiti.
--inoltre devo sistemare che ho due process che assegnano valori allo stesso signal.
--per ovviare a ciò non e difficile, perche se vedo bene il valore lo assegno solo appena entrato in wr_bit o rd_bit dove clk_count = 0 (una sola volta).

--poi cera qualcosa da fare con buffer o rd_bit








Merge: reg_rw_index <= reg_index & rw;              --it is usefull because in the counter we want to send all bits with just one condition, so < 8.
                                                    --rw LSB sent after reg_index.


--devo capire se all'inzio della trasmissione è ok, perchè in questo modo bisogna avere il busy piu che allo start dopo o no bho




I2C_SM: process(RESET, CLK)
begin

    if(RESET = '0') then
        current_state <= idle_bit;
        ---------------------------------------------apposto cosi cioe in idle basta il reg_io non gli altri due qui invece servono tutti e tre
        buffer_io <= (others => '0');
        past_index <= (others => '0');
        reg_io <= (others => 'Z');
        ---------------------------------------------
        --buffer_io <= (others => '0');         --already reset in Sample process.
        reg_io <= (others => 'Z');              --it is important because if the value is high or low it could create a short-circuit.
        nack_error <= '0';
        bus_taken <= '0';--probabilmente usato poi per il multi_master
        clk_count <= 0;
        bit_count <= 0;
        temp <= 0;
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
                temp <= 0;
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
                --busy <= '1';                                    --buffer occupied for half comunication time.
                
                
                if(bit_count = 0 AND clk_count = 0) then        --just when current_state enters in indrw_bit.
                    past_index <= reg_index;                    --when current_state is indrw_bit it stores the slave index for future comparation.
                end if;
                
                
                if(clk_count < (clk_per_bit-1)/2) then          --change SCL each half period.
                        SCL <= 'Z';
                else
                        SCL <= '0';
                end if;
                                                                --slave index starts with rising edge, so SCL has to wait one period of frequency_I2C to be high again.
                
                if(bit_count = 5) then
                    busy <= '1';
                end if;
                
                
                if(bit_count < 8) then                          --it counts from 0 to 7 (7 index bits and also r/w bit), then it reads ACK.
                    
                    if(clk_count = (clk_per_bit-1)*3/4) then    --before index starts, master needs to precharge index bit to stability reason, 3/4 of period is enought.
                        
                                                                    --7 - bit_count because master sends from MSB to LSB and r/w bit, so from 7(MSB) to 0(r/w).
                        if(reg_rw_index(7-bit_count) = '0') then    --to set SDA to '0' or 'Z' a condition is needed, otherwise it can't perform high impedance
                            SDA <= '0';                             --with just this code line: SDA <= reg_rw_index(7 - bit_count)
                        else
                            SDA <= 'Z';
                        end if;
                        clk_count <= clk_count + 1;

                    elsif(clk_count = clk_per_bit-1) then
                        clk_count <= 0;
                        bit_count <= bit_count + 1;             --bit_count is updated just when clk_count reaches clk_per_bit-1.
                    
                    else
                        clk_count <= clk_count + 1;
                    end if;
                   
                elsif(bit_count = 8) then                       --pay attention bit_count <= 1 just at current_state <= wr or rd. ACK reading if
                
                
                    if(clk_count = (clk_per_bit-1)*11/20) then  --times 11/20 and not 1/2 cause master has to wait a bit more than 1/2, so 1/2 + 1/20
                        SDA <= 'Z';                             --Everytime SDA is used like an input, it requires to be setted high impedance in low edge SCL.
                        clk_count <= clk_count + 1;
                    
                    elsif(clk_count = clk_per_bit-1) then
                        
                        
                        if(SDA = '0') then                      --ACK/NACK management
                            
                            if(rw = '0') then                   --ACK management
                                current_state <= wr_bit;        --writing state.
                            else
                                current_state <= rd_bit;        --reading state.
                            end if;
                                                                ----> ricorda che io faccio sempre prima il ciclo e poi la lettura perche lho fatto cosi,
                                                                --quindi il tempo del nack e il tempo che scorre nello stop, ricorda poi che nello stop
                                                                --dovra poi aspettare poi dopo lo stop stesso
                                                                
                        else                                    --NACK management
                            current_state <= stop_bit;
                            nack_error <= '1';                  --dovrebbe esserci giusto ? !!!!!!!!!! mi pare di si
                            
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
                
                
                if(bit_count = 0 AND clk_count = 0) then        --only the first time current_state enters in wr_bit.
                    buffer_io <= reg_io;                        --it set the new data frame.
                end if;
                
                if(bit_count = 5) then                          --this code line is used to set busy = '0' in the middle of data transmition.
                    busy <= '0';                                --input device has half data trasmition time to write or read another value in burrer_io
                end if;                                         --busy = '0' when bit_count > 5.
                
                
                if(bit_count < 8) then

                    
                    if(clk_count = (clk_per_bit-1)*3/4) then    --before data starts, master needs to precharge data bit to stability reason, 3/4 of period is enought.

                        if(buffer_io(7-bit_count) = '0') then    --to set SDA to '0' or 'Z' a condition is needed, otherwise it can't perform high impedance
                            SDA <= '0';                          --with just this code line: SDA <= reg_rw_index(7 - bit_count)
                        else
                            SDA <= 'Z';
                        end if;--ATTENZIONE FORSE ALLA FINE DEL WR_BIT DOVREI METTERE SDA A TRI-STATE BHOO
                        clk_count <= clk_count + 1;
                        
                    elsif(clk_count = clk_per_bit-1) then
                        clk_count <= 0;
                        bit_count <= bit_count + 1;             --bit_count is updated just when clk_count reaches clk_per_bit-1.
                    
                    else
                        clk_count <= clk_count + 1;
                    end if;
                    
                    
                elsif(bit_count = 8) then --qui devo leggere l'ack
                
                    if(clk_count = (clk_per_bit-1)*11/20) then  --times 11/20 and not 1/2 cause master has to wait a bit more than 1/2, so 1/2 + 1/20
                        SDA <= 'Z';                             --Everytime SDA is used like an input, it requires to be setted high impedance in low edge SCL.
                        clk_count <= clk_count + 1;
                    
                    elsif(clk_count = clk_per_bit-1) then
                        
                        clk_count <= 0;   
                        --guarda se si puo mettere fuori anche bit_count          
                        
                        if(SDA = '0') then                      --ACK/NACK management
                        
                            buffer_io <= reg_io;
                            bit_count <= 0;
                            
                            if(start = '1' AND rw = '0' AND past_index = reg_index) then
                                --next frame transmition
                                --past_index <= reg_index; --itis already the same. Not needed.
                                --current_state <= wr_bit; --not needed but to clarify.
                                busy <= '1';
                                
                            elsif((start = '1' AND past_index /= reg_index) OR rw = '1') then
                                --idle o start veloce
                                --posso andare in idle perchè tanto la trasmissione è sincrona con SCL
                                current_state <= idle_bit;--idle_bit is just one ic_frequency clock pulse, it doesn't loose sincronization because transition is syncronous.
                                busy <= '0'; --already 0.
                                
                                
                            elsif(start = '0') then
                                --stop transmition
                                current_state <= stop_bit;

                            else                                --it will not enter here cause bit_count = 8 (9 bits) is the max allowed.
                                current_state <= idle_bit;
                                
                            end if;
                            
                        else                                    --NACK management
                            current_state <= stop_bit;
                            nack_error <= '1';
                        end if;
                        
                    
                    else
                        clk_count <= clk_count + 1;
                    
                    
                    end if;
                       
                    
                else                                            --it will not enter here cause bit_count = 8 (9 bits) is the max allowed.
                    
                    current_state <= idle_bit;
                    bit_count <= 0;
                    clk_count <= 0;
                    
 
                    
                    
                end if;
                
           
           
           
           
           
           
           
                
            when rd_bit =>                                      --busy bit in reading mode works differently.
                                                                --master reads in rd_bit when SCL rises up eacjìh time, so state machine works in this way:
                                                                --busy = '0' in idle_bit, it became '1' when starts, then at the end of frame reading,
                                                                --busy becames '0', it lasts '0' for ack bit and for first half clock frame transition period.
                                                                --so it works contrarily than wr_bit that sets busy to '0' in second half clock period.
                                                                
                if(clk_count < (clk_per_bit-1)/2) then          --change SCL each half period.
                        SCL <= 'Z';
                else
                        SCL <= '0';
                end if;
                
                
                if(bit_count = 5) then              --busy = '1' when bit_count > 5.
                    busy <= '1';                    --because busy = '0' just at the end of firts data reception, then it stays low for first half period.
                end if;
                --ricorda pero di mettere busy a 0 dopo

                if(bit_count < 8) then
                    if(clk_count = clk_per_bit-1) then
                        clk_count <= 0;
                        bit_count <= bit_count + 1;
                        buffer_io(7 - bit_count) <= SDA;        --here master gets SDA bit at clk_per_bit and not like wr_bit where SDA is set at 3/4 of period.
                                                                --this cause wr_bit precharge data to send to slave, whereas here it reads data at risign edge of clock
                                                                --at the beginning SDA is already tri-state.
                        --controllare se ci sono conflitti dell'uso di buffer_io.
                        --ricordati tutti i tipi per start veloce ecc e il past_index
                        
                    else
                        clk_count <= clk_count + 1;
                    end if;
                
                elsif(bit_count = 8) then
                
                    if(clk_count = (clk_per_bit-1)*3/4) then                --precharge SDA.
                        if(start = '1' AND rw = '1' AND past_index = reg_index) then
                            --next frame reception..
                            SDA <= '0';                                     --ACK
                        elsif((start = '1' AND past_index /= reg_index) OR rw = '0') then
                            --idle o start veloce
                            SDA <= 'Z';                                     --NACK
                        elsif(start = '0') then
                            SDA <= 'Z';                                     --NACK
                        end if;
                        clk_count <= clk_count + 1;
                        
                    elsif(clk_count = clk_per_bit-1) then
                        clk_count <= 0;
                        bit_count <= 0;
                        busy <= '0';
                        reg_io <= buffer_io;        --teoricamente giusto per tutti perche sempre lo butta in uscita il valore
                        
                        if(start = '1' AND rw = '1' AND past_index = reg_index) then
                            --next frame reception.
                            current_state <= rd_bit;                         --the same.
                            
                            
                        elsif((start = '1' AND past_index /= reg_index) OR rw = '0') then
                            current_state <= timing_bit;                     --right in idle_bit like above in wwr_bit state
                            

                                  
                        elsif(start = '0') then
                            current_state <= stop_bit;
                        
                        else                                --it will not enter here cause bit_count = 8 (9 bits) is the max allowed.
                            current_state <= idle_bit;
                        end if;
                        
                    else
                        clk_count <= clk_count + 1;
                    end if;
                    
                    --forse qui 3 condizioni perche il nack e quando start = 0
                    
                end if;

            
            
      
            
            when timing_bit =>                                  --it is a state where master counts until clk_per_bit, it is used in some state when master needs
                                                                --to count (example repeated start, it waits ack bit before enter in idle_bit)
                if(clk_count = 0) then
                    SCL <= 'Z';                                 --set ACK/NACK of past state. and it stays high for the whole period.ù
                    clk_count <= clk_count + 1;
                elsif(clk_count = clk_per_bit-1) then
                    current_state <= idle_bit;
                    clk_count <= 0;                             --devo gia mettere SDA a 'Z' quan dentro a 3/4 sennò lo fa a clk_per_bit cioè a ridosso del
                else                                            --rising edge, non va bene perchè sembra un altro fronte start o stop
                    clk_count <= clk_count + 1;                 --forse questa cosa è meglio controllarla per tutti gli sda cambiati che non facciano qualche
                end if;                                         --cambio quando SCL è alto
                --dimmi che posso mettere sda gia li a 3/4, si è giusto perche lo precarica sda nel ciclo prima, poi ce SCL che va alto che lo legge,
                --o meglio lo fa leggere allo slave e poi lo precarica a 3/4 per il prossimo SCL high nell'idle, no spe forse devo comportarmi tenendo
                --scl alto perche e bloccata la comunicazione
            
            
            
            
            
            
            when stop_bit =>
                if(temp = 0) then                               --temp = '0', ACK/NACK state period clock.
                    if(clk_count < (clk_per_bit-1)/2) then
                        SCL <= 'Z';
                    else
                        SCL <= '0';
                    end if;
                    
                    if(clk_count = (clk_per_bit-1)*3/4) then
                        SDA <= '0';                             --[1]SDA set to 0 to perform stop bit action.
                        clk_count <= clk_count + 1;
                    
                    elsif(clk_count = clk_per_bit-1) then
                        clk_count <= 0;
                        current_state <= stop_bit;
                        temp <= 1;
                        SCL <= 'Z';                             --[2]
                    
                    else
                        clk_count <= clk_count + 1;
                    
                    end if;
                    
                else                                            --temp = '1'
                    if(clk_count = (clk_per_bit-1)/2) then      --At half clock period, SDA <= 'Z' to perform stop action. (With SCL already high).
                        SDA <= 'Z';                             --[3] here it can be (clk_per_bit-1)/2 cause SCL is always high.
                        clk_count <= clk_count + 1;
                    elsif(clk_count = clk_per_bit-1) then
                        clk_count <= 0;
                        current_state <= idle_bit;
                        temp <= 0;
                        
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

--FINITO! più o meno, rivedi tutto il codice cancellando commenti in ita e fai si che sia leggibile,
--poi ricordati di dare un'occhiata se funziona il tri state su SDA o SCL perche sai che magari non è messo bene senza segnale intermedio bho
--fai il testbench
--ricordati delle conduizioni multi master e slave streaching però dopo aver visto che funziona

--guarda il tri state alla fine di wr_bit

--appena finisce la parte alta del clock e va basso, aspetto qualche ciclo di clock con SDA come era prima e poi lo metto ad alta impedenza, questo perchè
--se lo faccio istantaneamente potrebbero esserci problemi. Tanto lo slave controlla SDA solo al rising edge, o quando è alto per start e stop.
--Direi di far aspettare 1/20 di clk_per_bit cosi da essere proprio a ridosso comunque. e ricordati poi il clk_count <= clk_count + 1 se lo metti nell'if.


--(clk_count = (clk_count-1)*11/20)

