# I2C_MASTER_to_parallel_bus
It works in STANDARD and FAST MODE.
In the following lines, it is explaned hot to use I2C_MASTER inside an FPGA (GOWIN) and test it with and STM32 mcu.

HOW TO CONTROL I2C MASTER:
Main control pins are: busy, bus_wait, rw, rd_flag and nack_error.
When busy is low, you can change data in the parallel_bus (reg_io), otherwise when it is high, changing is not allowed.
When busy is low you can also change slave index (reg_index).
If rw = 1 master performs reading mode, rw = 0 master performs writing mode.
When master is in writing mode, when busy falls down you can add the next data frame or stop the comunication/ switch rw or index
(it finishes at the end of the current frame).
When master is in reading mode, when busy falls down, you can get the parallel_bus data (), when rd_flag falls down you can stop comunication,
switch rw or index (it finishes at the end of the current frame).
NOTE: Be aware, when master switches from reading to writing mode, parallel_bus (reg_io) switches from output to input. To avoid short-circuit
with the device which send parallel_bus data to the master, the external devices has to wait as follows:
After busy falls down, the device has to check wait_bus (it should be high), when bus_wait falls (so both busy and bus_wait are low)
you exactly know paralel_bus is in three-state. 



Test program as follows:
After flashing TANG NANO 9K and STM32_board
1) Reset the board (black button)
2) Open a serial terminal(link: https://github.com/TeraTermProject/teraterm/releases), set serial comunication with 115200 bps baudrate
3) Push blue button to perform master trasmition of two bytes, push again to receive two bites from STM32(slave)
4) In main.c you can change TX and RX value
5) See TX and RX value on serial terminal


HOW TO START:

1) Open an HDL editor and insert I2C_MASTER.vhd and block1.vhd found in Design directory.
2) To simulate the design, use the testbech found in sim directory.

HOW TO IMPLEMENT I2C IN FPGA:

1) Download GOWIN IDE (link: https://www.gowinsemi.com/en/support/home/).
2) Create New_FPGA_Project.
3) Insert target FPGA device (GW1NR-LV9QNC6/I5 for Tang Nano 9k board).
4) Create Physical Constrain file and insert Constrain.scr found in FPGA_Implementation directory.
5) Create VHDL file and insert I2C_MASTER_.vhd found in Design directory.

HOW TO IMPLEMENT STM32 CODE:



1) open STM_CUBE_IDE or CUBE_MX.
2) set pins as follows (on STM32F103RB):
   
   First set pins as default on Nucleo64f103RB board

   PB7 I2C_SDA (high_impedance, connect the line to Vcc 3.3V through a 4.7kOhm resistor).
   
   PB6 I2C_SCL (high_impedance, connect the line to Vcc 3.3V through a 4.7kOhm resistor).
   
   PA0 GPIO_OUTPUT

   PA1 GPIO_OUTPUT

   PA2 UART_TX

   PA3 UART_RX

   PA4 GPIO_EXTI_4 (FALLING_EDGE)

   PA5 GPIO_OUTPUT (LED)

   PA6 GPIO_EXTI_6 (FALLING_EDGE)

   PA9 GPIO_EXTI_9 (FALLING_EDGE)

   PB0 GPIO_OUTPUT

   PB1 GPIO_OUTPUT

   PB2 GPIO_OUTPUT

   PB10 GPIO_OUTPUT

   PB11 GPIO_OUTPUT

   PB12 GPIO_OUTPUT

   PB13 GPIO_OUTPUT

   PB14 GPIO_OUTPUT

   PB15 GPIO_OUTPUT

   PC13 GPIO_EXTI_13 (FALLING_EDGE)

   PC1 RESET

4) set I2C1, Standard Mode: 100kHz, 7bit addres (the addres is 74 for the project), Clock_no_stretch ENABLED.
5) enable all EXTI and I2C interrupt, set on NVIC EXTI4, I2C1 event and error interrupt as priority = 2, and EXTI [15-10] as priority = 1.
6) set frequency HCLK on 72 MHz.
7) Generate code on STM_CUBE_IDE or Keil.
8) Replace main.c with the one in Test.
9) Connect STM32 to Tang Nano 9k pins as shown:
   
   STM-->TANG NANO 9K
   PA0   pin_32

   PB7   pin_27 (high_impedance, connect the line to Vcc 3.3V through a 4.7kOhm resistor).

   PB6   pin_28 (high_impedance, connect the line to Vcc 3.3V through a 4.7kOhm resistor).

   PA1   pin_26

   PA2   connected on board

   PA3   connected on board

   PA4   pin_29

   PA5   connected on board

   PA6   pin_37

   PA9   pin_63

   PB0   pin_30

   PB1   pin_70

   PB2   pin_71

   PB10  pin_72

   PB11  pin_73
   
   PB12  pin_74

   PB13  pin_75

   PB14  pin_76

   PB15  pin_77

   PC1   pin_34
   
   PC13  connected on board

   Index pins are connected to GND or VCC to have 74 index.
   Pins are in orther from 0 to 6:
   
   "reg_index[0]" 40; 

   "reg_index[1]" 35; 

   "reg_index[2]" 41; 

   "reg_index[3]" 42; 

   "reg_index[4]" 51; 

   "reg_index[5]" 53; 

   "reg_index[6]" 57;

IF THERE ARE ANY KIND OF ISSUE, PLEASE CONTACT ME TO SOLVE THEM. THANKS IN ADVANCE.




   
