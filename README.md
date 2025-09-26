# I2C_MASTER_to_parallel_bus
It works in STANDARD and FAST MODE.
In the following lines, it is explaned hot to use I2C_MASTER inside an FPGA (GOWIN) and test it with and STM32 mcu.

HOW TO START:

1) Open an HDL editor and insert I2C_MASTER.vhd and block1.vhd found in Design directory.
2) To simulate the design, use the testbech found in sim directory

HOW TO IMPLEMENT I2C IN FPGA:

1) Download GOWIN IDE (link below)
2) Create New_FPGA_Project
3) Insert target FPGA device (GW1NR-LV9QNC6/I5 for Tang Nano 9k board)
4) Create Physical Constrain file and insert Constrain.scr found on FPGA_Implementation
5) Create VHDL file and insert I2C_MASTER_.vhd

HOW TO IMPLEMENT STM32 CODE:

1)
