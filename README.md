# I2C_MASTER_to_parallel_bus
It works in STANDARD and FAST MODE.
In the following lines, it is explaned hot to use I2C_MASTER inside an FPGA (GOWIN) and test it with and STM32 mcu.

HOW TO START:

1) Open an HDL editor and insert I2C_MASTER.vhd and block1.vhd found in Design directory.
2) To simulate the design, use the testbech found in sim directory.

HOW TO IMPLEMENT I2C IN FPGA:

1) Download GOWIN IDE (link below).
2) Create New_FPGA_Project.
3) Insert target FPGA device (GW1NR-LV9QNC6/I5 for Tang Nano 9k board).
4) Create Physical Constrain file and insert Constrain.scr found in FPGA_Implementation directory.
5) Create VHDL file and insert I2C_MASTER_.vhd found in Design directory.

HOW TO IMPLEMENT STM32 CODE:

1) open STM_CUBE_IDE or CUBE_MX.
2) set pins as follows (on STM32F103RB):
   
   First set pins as default on Nucleo64f103RB board
   
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

4) set I2C1, Standard Mode: 100kHz, 7bit addres (the addres is 74 for the project), Clock_no_stretch ENABLED.
5) enable all EXTI and I2C interrupt, set on NVIC EXTI4, I2C1 event and error interrupt as priority = 2, and EXTI [15-10] as priority = 1.
6) set frequency HCLK on 72 MHz.
7) Generate code on STM_CUBE_IDE or Keil.
8) Replace main.c with the one in Test.
9) Connect STM32 to Tang Nano 9k pins as shown:
   

   PA0   pin_32

   PA1   pin_26

   PA2   connected on board

   PA3   connected on board

   PA4 

   PA5 

   PA6 

   PA9 

   PB0 

   PB1 

   PB2 

   PB10
   
   PB11 

   PB12 

   PB13 

   PB14 

   PB15 

   PC13 
