/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2025 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "i2c.h"
#include "usart.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include <stdio.h>
#include <string.h>
/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

/***************\
|*CODE VARIABLES|
\***************/

uint8_t RX_buffer[2];											//data received by slave
uint8_t rx_data[2];												//data received by master
uint8_t tx_data[2] = {0x41, 0x42};								//data sent by master
uint8_t TX_buffer[2] = {0x43, 0x44};							//data sent by slave
uint8_t busy_count, rd_count = 0;

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */
void General_Error(void);
void Set_GPIO_Value(uint8_t value);
void Read_GPIO_Value(uint8_t *value, int pos);
void Set_Pins_As_Output(void);
void Set_Pins_As_Input(void);

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */

  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_USART2_UART_Init();
  MX_I2C1_Init();
  /* USER CODE BEGIN 2 */

  /****************************************************************************\
  |*MAIN CODE I2C: TESTER FOR I2C MASTER STANDARD MODE ON FPGA, STM32 I2C SLAVE|
  \****************************************************************************/		
	
  /*\THIS SCRIPT PROVIDES TESTING FPGA I2C MASTER, AT THE BEGINNING MASTER WRITES DATA AND STM32 SLAVE READS DATA,
   *THEN MASTER WORKS AS RECEIVER DEVICE, SO STM32 WILL SEND DATA.
   *RX_buffer STORES DATA SENT FROM MASTER.
   *TX_buffer IS DATA, THE SLAVE WILL SEND.
   *ALL DATA SENT AND RECEIVED ARE DISPLAYED IN TERMINAL THROUGH UART TRANSMITION:
   *RX_buffer AND rx_data (THE DATA TRANSMITTED AND READDEN FROM FPGA TO CHECK).
  \*/
	
	
	
	//I2C INIT START:******************************************************
	
	//reset portc1: RESET_STATE
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_1, 0);
	HAL_Delay(400);
	
	//start porta0 --->NO start = 0
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_0, 0);
	
	//rw porta1: rw = 0 master transmit
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_1, 0);
	
	//reset portc1: RESET_STATE
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_1, 0);
	
	//reset portc1: NO_RESET
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_1, 1);
	
	//busy porta4 ---> reading
	//nack_error portb0 ---> writing;
	//il bus_taken let floating
	
	//*********************************************************************
	
	
	//disactive PIN_9 interrupt(bus_wait), not used in this code
	EXTI->IMR &= ~EXTI_IMR_MR9;
	
	//enable I2C slave (reading)
	HAL_I2C_Slave_Receive_IT(&hi2c1, RX_buffer, sizeof(RX_buffer));
	
	//STM32 (no I2C slave) sets first parallel data to transmit from master to slave
	Set_GPIO_Value(tx_data[0]);
	

  /* USER CODE END 2 */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
  }
  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_BYPASS;
  RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */



void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{

	switch (GPIO_Pin)
	{
		case GPIO_PIN_4:						//busy
		{
			//At the beginning STM32 receives, so busy should falls twice before changing to transmit.
			
			if(busy_count == 1)
			{
				//STM32 (no I2C slave) sets second parallel data to transmit from master to slave
				Set_GPIO_Value(tx_data[1]);

			}
			else if(busy_count == 2)
			{
				//change master from transmition to reception
				//rw porta1: rw = 1 master reception
				HAL_GPIO_WritePin(GPIOA, GPIO_PIN_1, 1);
				
				//start porta0 --->Switch off, start = 0
				HAL_GPIO_WritePin(GPIOA, GPIO_PIN_0, 0);
				
				
			}
			else if(busy_count == 3)
			{
				//STM32 (no slave I2C) reads first parallel_bus frame from master
				Read_GPIO_Value(rx_data, 0);

			}
			else if(busy_count == 4)
			{
				//STM32 (no slave I2C) reads second parallel_bus frame from master
				Read_GPIO_Value(rx_data, 1);
			}
			busy_count++;
			break;
		}
		
		
		case GPIO_PIN_6:						//rd_flag
		{
			rd_count++;
			
			if(rd_count == 1)
			{
				//after trasmition bytes, master will receive, so STM32 has to read parallel_bus data.
				Set_Pins_As_Input();
			}
			if(rd_count == 2)
			{
				//finish comunication
				//start porta0 --->NO start = 0
				HAL_GPIO_WritePin(GPIOA, GPIO_PIN_0, 0);
			}
			break;
		}
		

		case GPIO_PIN_9:						//bus_wait
		{

			if(HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_6) == 0)
			{
				
			}
			else
				General_Error();
			break;
		}
		
		
		case GPIO_PIN_13:						//blue_button
		{
			//start comunication
			//start porta0 ---> start = 1
			HAL_GPIO_WritePin(GPIOA, GPIO_PIN_0, 1);
			break;
		}
	}
	
	
}



void HAL_I2C_SlaveRxCpltCallback(I2C_HandleTypeDef *hi2c)
{
	uint8_t rtr1[] = "Il valore dei frames sono: ";
	uint8_t rtr2[] = "\r\n";
	
	HAL_UART_Transmit(&huart2, rtr1, sizeof(rtr1), 100);
	HAL_UART_Transmit(&huart2, RX_buffer, sizeof(RX_buffer), 100);
	HAL_UART_Transmit(&huart2, rtr2, sizeof(rtr2), 100);
	
	//transmit I2C slave setup
	HAL_I2C_Slave_Transmit_IT(&hi2c1, TX_buffer, sizeof(TX_buffer));

}

void HAL_I2C_SlaveTxCpltCallback(I2C_HandleTypeDef *hi2c)
{
	uint8_t rtr1[] = "Il valore dei frames sono: ";
	uint8_t rtr2[] = "\r\n";
	
	HAL_UART_Transmit(&huart2, rtr1, sizeof(rtr1), 100);
	HAL_UART_Transmit(&huart2, rx_data, sizeof(rx_data), 100);
	HAL_UART_Transmit(&huart2, rtr2, sizeof(rtr2), 100);
}


void HAL_I2C_ErrorCallback(I2C_HandleTypeDef *hi2c)
{
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, 1);
    uint32_t error = HAL_I2C_GetError(hi2c);

    if (error == HAL_I2C_ERROR_NONE)
    {
        // No errors
        //HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, 1);
    }
    else if (error == HAL_I2C_ERROR_BERR)
    {
        // Bus error
        //HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, 1);
    }
    else if (error == HAL_I2C_ERROR_ARLO)
    {
        // Arbitration lost
        //HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, 1);
    }
    else if (error == HAL_I2C_ERROR_AF)
    {
        // Acknowledge failure
        //HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, 1);
    }
    else if (error == HAL_I2C_ERROR_OVR)
    {
        // Overrun/Underrun
        //HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, 1);
    }
    else if (error == HAL_I2C_ERROR_DMA)
    {
        // DMA transfer error
        //HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, 1);
    }
    else if (error == HAL_I2C_ERROR_TIMEOUT)
    {
        // Timeout
        //HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, 1);
    }
    else if (error == HAL_I2C_ERROR_SIZE)
    {
        // Dimention error
        //HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, 1);
    }
    else if (error == HAL_I2C_ERROR_DMA_PARAM)
    {
        // DMA wrong parameters
        //HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, 1);
    }
    else
    {
        char error_msg[64];
				uint32_t error = HAL_I2C_GetError(hi2c);
				snprintf(error_msg, sizeof(error_msg), "Error I2C: 0x%08lX\r\n", (unsigned long)error);
				HAL_UART_Transmit(&huart2, (uint8_t*)error_msg, strlen(error_msg), 100);
    }
}




//sets value --> parallel_reg
void Set_GPIO_Value(uint8_t value)
{
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_1, ((value >> 7) & 0x01));
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_2, ((value >> 6) & 0x01));
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_10, ((value >> 5) & 0x01));
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_11, ((value >> 4) & 0x01));
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_12, ((value >> 3) & 0x01));
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_13, ((value >> 2) & 0x01));
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_14, ((value >> 1) & 0x01));
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_15, ((value >> 0) & 0x01));
	return;
}

//reads from parallel bus, value is the array buffer, 
void Read_GPIO_Value(uint8_t *value, int pos)
{
	value[pos] |= HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_1) << 7;
	value[pos] |= HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_2) << 6;
	value[pos] |= HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_10) << 5;
	value[pos] |= HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_11) << 4;
	value[pos] |= HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_12) << 3;
	value[pos] |= HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_13) << 2;
	value[pos] |= HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_14) << 1;
	value[pos] |= HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_15) << 0;
	return;
}


void Set_Pins_As_Output(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    GPIO_InitStruct.Pin = GPIO_PIN_1 | GPIO_PIN_2 | GPIO_PIN_10 |
                          GPIO_PIN_11 | GPIO_PIN_12 | GPIO_PIN_13 |
                          GPIO_PIN_14 | GPIO_PIN_15;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
}

void Set_Pins_As_Input(void)
{
	//set parallel bus as input
	GPIO_InitTypeDef GPIO_InitStruct = {0};

	// Reinit pins as input (no pull-up/down)
	GPIO_InitStruct.Pin = GPIO_PIN_1 | GPIO_PIN_2 | GPIO_PIN_10 |
												GPIO_PIN_11 | GPIO_PIN_12 | GPIO_PIN_13 |
												GPIO_PIN_14 | GPIO_PIN_15;
	GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
	GPIO_InitStruct.Pull = GPIO_NOPULL;

	HAL_GPIO_DeInit(GPIOB, GPIO_InitStruct.Pin);
	HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
}

void General_Error(void)
{
	while(1)
	{
		HAL_Delay(500);
		//HAL_GPIO_TogglePin(GPIOA, GPIO_PIN_5);
	}
	return;
}


/* USER CODE END 4 */

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}
#ifdef USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
