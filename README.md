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

   PA4 GPIO_EXTI_4

   PA5 GPIO_OUTPUT (LED)

   PA6 GPIO_EXTI_6

   PA9 GPIO_EXTI_9

   PB0 GPIO_OUTPUT

   PB1 GPIO_OUTPUT

   PB2 GPIO_OUTPUT

   PB10 GPIO_OUTPUT

   PB11 GPIO_OUTPUT

   PB12 GPIO_OUTPUT

   PB13 GPIO_OUTPUT

   PB14 GPIO_OUTPUT

   PB15 GPIO_OUTPUT

   PC13 GPIO_EXTI_13

   
