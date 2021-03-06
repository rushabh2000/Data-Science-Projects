
//============================================================================
// ECE 362 lab experiment 8 -- SPI and DMA
//============================================================================

#include "stm32f0xx.h"
#include "lcd.h"
#include <stdio.h> // for sprintf()

// Be sure to change this to your login...
const char login[] = "ranka0";

// Prototypes for misc things in lcd.c
void nano_wait(unsigned int);

// Write your subroutines below.
void setup_bb()
{
    RCC->AHBENR |=  RCC_AHBENR_GPIOBEN;
    GPIOB->MODER &= ~(3<<24);
    GPIOB->MODER |= (1<<24); // set output on pb12
    GPIOB->MODER &= ~(3<<26);
    GPIOB->MODER |= (1<<26); // set output on pb 13
    GPIOB->MODER &= ~(3<<30);
    GPIOB->MODER |= (1<<30); // set output on pb 15

    // InitALIZE ODR
    GPIOB->ODR |= GPIO_ODR_12 ; //nss high ---------
    GPIOB->ODR &= ~(GPIO_ODR_13); // sck is low----------

}
void small_delay (void)
{
    nano_wait(10000000);

}
void bb_write_bit(int n)
{
    GPIOB->ODR &= ~(GPIO_ODR_15);
    GPIOB->ODR |= n << 15;// set mosi pin to value of parameter-------------
    small_delay();
    GPIOB->ODR &= ~(GPIO_ODR_13);
    GPIOB->ODR |= GPIO_ODR_13;//set sck pin to high
    small_delay();
    GPIOB->ODR &= ~(GPIO_ODR_13);// set sck pin to low
}
void bb_write_byte(int n)
{
    bb_write_bit((n >> 7) & 1);// ---------------
    bb_write_bit((n >> 6) & 1);
    bb_write_bit((n >> 5) & 1);
    bb_write_bit((n >> 4) & 1);
    bb_write_bit((n >> 3) & 1);
    bb_write_bit((n >> 2) & 1);
    bb_write_bit((n >> 1) & 1);
    bb_write_bit((n >> 0) & 1);
}
void bb_cmd(int n)
{
    GPIOB->ODR &= ~(GPIO_ODR_12); // set nss to low
    small_delay();
    bb_write_bit(0);
    bb_write_bit(0);
    bb_write_byte(n);
    small_delay();
    GPIOB->ODR &= ~(GPIO_ODR_12);
    GPIOB->ODR |= (GPIO_ODR_12); // set nss to high
    small_delay();

}
void bb_data(int n)
{
    GPIOB->ODR &= ~(GPIO_ODR_12); // set nss to low
    small_delay();
    bb_write_bit(1);
    bb_write_bit(0);
    bb_write_byte(n);
    small_delay();
    GPIOB->ODR &= ~(GPIO_ODR_12);
    GPIOB->ODR |= (GPIO_ODR_12); // set nss to high
    small_delay();

}

void bb_init_oled()
{
    nano_wait(1000000);
    bb_cmd(0x38); // set for 8-bit operation
    bb_cmd(0x08); // turn display off
    //bb_cmd(0x01); // clear display
    nano_wait(2000000) ;
    bb_cmd(0x06); // set the display to scroll
    bb_cmd(0x02); // move the cursor to the home position
    bb_cmd(0x0c); // turn the display on
}

void bb_display1(const char *n)
{
    bb_cmd(0x02);
   int i = 0;
   while( n[i] != NULL){
       bb_data(n[i]);
       i++;
    }

}
void bb_display2(const char *n)
{
    bb_cmd(0xc0);
    int i = 0;
    while( n[i] != NULL){
          bb_data(n[i]);
          i++;
       }
}
void setup_spi2()
{
    RCC->AHBENR |=  RCC_AHBENR_GPIOBEN;
    RCC->APB1ENR |= RCC_APB1ENR_SPI2EN;
    GPIOB->MODER &= ~(3<<24);
    GPIOB->MODER |= (2<<24); // pb 12 alternate
    GPIOB->MODER &= ~(3<<26);
    GPIOB->MODER |= (2<<26); // pb13 alternate
    GPIOB->MODER &= ~(3<<30);
    GPIOB->MODER |= (2<<30); // pb15  alternate

    SPI2->CR1 |= SPI_CR1_MSTR | SPI_CR1_BR_0 | SPI_CR1_BR_1 | SPI_CR1_BR_2 ;
    SPI2->CR1 |= SPI_CR1_BIDIMODE  | SPI_CR1_BIDIOE ;


    SPI2->CR2 = SPI_CR2_SSOE | SPI_CR2_NSSP | SPI_CR2_DS_3 | SPI_CR2_DS_0 ;
    SPI2->CR1 |= SPI_CR1_SPE;  // enable the sp1 chanel

}
void spi_cmd(int n)
{
    while(!(SPI2->SR & SPI_SR_TXE ));
    SPI2->DR |= n;
}
void spi_data(int n)
{
    while(!(SPI2->SR & SPI_SR_TXE))  ;
        SPI2->DR |= ( n | 0x200);


}
void spi_init_oled()
{
    nano_wait(1000000);
    spi_cmd(0x38); // set for 8-bit operation
    spi_cmd(0x08); // turn display off
    spi_cmd(0x01); // clear display
    nano_wait(2000000) ;
    spi_cmd(0x06); // set the display to scroll
    spi_cmd(0x02); // move the cursor to the home position
    spi_cmd(0x0c); // turn the display on
}
void spi_display1(const char *n)
{

               spi_cmd(0x02);
               int i = 0;
                 while( n[i] != NULL){
                     spi_data(n[i]);
                     i++;
                  }}
void spi_display2(const char *n)
{

    spi_cmd(0xc0);
    int i = 0;
      while( n[i] != NULL){
          spi_data(n[i]);
          i++;
       }
}
void spi_enable_dma(const short*a)
{
    RCC->AHBENR |= RCC_AHBENR_DMA1EN; // wnable dma1
    //DMA1_Channel5->CCR &= ~DMA_CCR_EN;
    DMA1_Channel5->CPAR = (uint32_t)(&(SPI2->DR));
    DMA1_Channel5->CMAR = (uint32_t)(a);//Set CMAR to the parameter passed in.
    DMA1_Channel5->CNDTR = 34; // Set CNDTR to 34. elements to transfer
    DMA1_Channel5->CCR |= DMA_CCR_DIR; //Set the DIRection for copying from-memory-to-peripheral.
    DMA1_Channel5->CCR |= DMA_CCR_MINC; //Set the MINC to increment the CMAR for every transfer.
    DMA1_Channel5->CCR |= DMA_CCR_MSIZE_0;//Set the memory datum size to 16-bit.
    DMA1_Channel5->CCR |= DMA_CCR_PSIZE_0;//Set the peripheral datum size to 16-bit
    DMA1_Channel5->CCR |= DMA_CCR_CIRC; //Set the channel for CIRCular operation. to start data trasfer contiuosolyu
    DMA1_Channel5->CCR |= DMA_CCR_EN; // enable the dma channel
    SPI2->CR2 |= SPI_CR2_TXDMAEN; // enable dma trasfer when tx is empty

}

void setup_spi1()
{
    RCC->AHBENR |= RCC_AHBENR_GPIOAEN;
    GPIOA->MODER &= ~(3<< 8);
    GPIOA->MODER |= (2<<8); //4
    GPIOA->MODER &= ~(3<< 10);
    GPIOA->MODER |= (2<<10); //5
    GPIOA->MODER &= ~(3<< 14);
    GPIOA->MODER |= (2<<14); //7
    GPIOA->MODER &= ~(3<<4);
    GPIOA->MODER |= (1<<4); // pa output
    GPIOA->MODER &= ~(3<<6);
    GPIOA->MODER |= (1<<6); // pa3

       // cofig of spi1
        RCC->APB2ENR |= RCC_APB2ENR_SPI1EN;

        SPI1->CR1 &= ~SPI_CR1_BR;// baud rate as small as possible
        SPI1->CR1 |= SPI_CR1_MSTR |SPI_CR1_BIDIMODE  | SPI_CR1_BIDIOE ;


        SPI1->CR2 &=  ~SPI_CR2_DS_3;
        SPI1->CR2 = SPI_CR2_SSOE | SPI_CR2_NSSP | SPI_CR2_DS_0 |SPI_CR2_DS_1 | SPI_CR2_DS_2 ;
        SPI1->CR1 |=  SPI_CR1_SPE;



}
// Write your subroutines above.

void show_counter(short buffer[])
{
    for(int i=0; i<10000; i++) {
        char line[17];
        sprintf(line,"% 16d", i);
        for(int b=0; b<16; b++)
            buffer[1+b] = line[b] | 0x200;
    }
}

void internal_clock();
void demo();
void autotest();

extern const Picture *image;

int main(void)
{
    //internal_clock();
    //demo();
    autotest();

   //setup_bb();
   //bb_init_oled();
   //bb_display1("Hello,");
   // bb_display2(login);

   //setup_spi2();
   //spi_init_oled();
   // spi_display1("Hello again,");
    //spi_display2(login);

    short buffer[34] = {
            0x02, // This word sets the cursor to the beginning of line 1.
            // Line 1 consists of spaces (0x20)
            0x220, 0x220, 0x220, 0x220, 0x220, 0x220, 0x220, 0x220,
            0x220, 0x220, 0x220, 0x220, 0x220, 0x220, 0x220, 0x220,
            0xc0, // This word sets the cursor to the beginning of line 2.
            // Line 2 consists of spaces (0x20)
            0x220, 0x220, 0x220, 0x220, 0x220, 0x220, 0x220, 0x220,
            0x220, 0x220, 0x220, 0x220, 0x220, 0x220, 0x220, 0x220,
    };

   // spi_enable_dma(buffer);
    //show_counter(buffer);

    setup_spi1();
    LCD_Init();
    LCD_Clear(BLACK);
    LCD_DrawLine(10,20,100,200, WHITE);
    LCD_DrawRectangle(10,20,100,200, GREEN);
    LCD_DrawFillRectangle(120,20,220,200, RED);
    LCD_Circle(50, 260, 50, 1, BLUE);
    LCD_DrawFillTriangle(130,130, 130,200, 190,160, YELLOW);
    LCD_DrawChar(150,155, BLACK, WHITE, 'X', 16, 1);
    LCD_DrawString(140,60,  WHITE, BLACK, "ECE 362", 16, 0);
    LCD_DrawString(140,80,  WHITE, BLACK, "has the", 16, 1);
    LCD_DrawString(130,100, BLACK, GREEN, "best toys", 16, 0);
    LCD_DrawPicture(110,220,(const Picture *)&image);
}
