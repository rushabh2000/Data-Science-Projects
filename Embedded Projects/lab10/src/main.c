
//============================================================================
// ECE 362 lab experiment 10 -- Asynchronous Serial Communication
//============================================================================

#include "stm32f0xx.h"
#include "ff.h"
#include "diskio.h"
#include "fifo.h"
#include "tty.h"
#include <string.h> // for memset()
#include <stdio.h> // for printf()

void advance_fattime(void);
void command_shell(void);

// Write your subroutines below.
void setup_usart5(void)
{
    RCC->AHBENR |= RCC_AHBENR_GPIOCEN ;
    RCC->AHBENR |= RCC_AHBENR_GPIODEN;
    RCC->APB1ENR |= RCC_APB1ENR_USART5EN;
    GPIOC->MODER &= ~(3<<24);
    GPIOD->MODER &= ~(3<<8);

    GPIOC->MODER |= 2<<(2*12); //pc12
    GPIOD->MODER |= 2<<(2*2);//pd2

    GPIOC->AFR[1] |= 2 << 16;
    GPIOD->AFR[0] |= 2 << 8;


    USART5->CR1 &= 0x10009401;
    USART5->CR2 &= 0x3000;
    USART5->BRR = 0x1a1;
    USART5->CR1 |= 0xd;

    while(!(USART5->ISR &  0x00600000)); // acknnoweldge the te bit

}
int simple_putchar(int n )
{
    while(!(USART5->ISR &  USART_ISR_TXE)); // acknnoweldge the te bit
    USART5->TDR = n;
    return n;
}


// Write your subroutines above.
int simple_getchar(void){
    while(!(USART5->ISR &  USART_ISR_RXNE));
    int n = USART5->RDR;
    return n;
}
int better_putchar(int n )
       {
            if( n == '\n'){
                while(!(USART5->ISR &  USART_ISR_TXE)); // acknnoweldge the te bit
                USART5->TDR = '\r';
                while(!(USART5->ISR &  USART_ISR_TXE));
                return USART5->TDR = '\n';

            }
           while(!(USART5->ISR &  USART_ISR_TXE)); // acknnoweldge the te bit
           USART5->TDR = n;
           return n;
       }
int better_getchar(void){


    while(!(USART5->ISR &  USART_ISR_RXNE));
    if(USART5->RDR == '\r'){
        return '\n';
    }
    int n = USART5->RDR;
    return n;
}
int interrupt_getchar(void) {


           // Wait for a newline to complete the buffer.
               if (fifo_newline(&input_fifo) == 0) {

                                  asm volatile ("wfi");



           }
               char ch = fifo_remove(&input_fifo);
                                             return ch;
       }


int __io_putchar(int ch) {
           return better_putchar(ch);
       }

       int __io_getchar(void) {
           return interrupt_getchar();
       }



void USART3_4_5_6_7_8_IRQHandler(void)
{
    if (USART5->ISR & USART_ISR_ORE)
            USART5->ICR |= USART_ICR_ORECF;

    int a = (USART5->RDR);

    if(fifo_full(&input_fifo) == 1){
        return;
    }
    insert_echo_char(a);

}
void enable_tty_interrupt(void)
{
    USART5->CR1 |= USART_CR1_RXNEIE;
    NVIC->ISER[0] = 1 << USART3_8_IRQn;
}

void setup_spi1(void)
{
    RCC->AHBENR |= RCC_AHBENR_GPIOAEN;


    GPIOA->MODER &= ~(3<<2);

    GPIOA->MODER |= (1<<2);

    GPIOA->MODER &= ~(3<< 12);
    GPIOA->MODER |= (2<<12); //6
    GPIOA->MODER &= ~(3<< 10);
    GPIOA->MODER |= (2<<10); //5
    GPIOA->MODER &= ~(3<< 14);
    GPIOA->MODER |= (2<<14); //7

    GPIOA->PUPDR |= 1<<12;

    RCC->APB2ENR |= RCC_APB2ENR_SPI1EN; // enable spi

    SPI1->CR1 &=  ~SPI_CR1_SPE;
    SPI1->CR1 |= SPI_CR1_MSTR | SPI_CR1_BR_0 | SPI_CR1_BR_1 | SPI_CR1_BR_2 ; // lowezt baud rate



    SPI1->CR2 &=  ~SPI_CR2_DS_3;

    SPI1->CR2 =  SPI_CR2_DS_0 |SPI_CR2_DS_1 | SPI_CR2_DS_2 ;
    SPI1->CR2 |= SPI_CR2_FRXTH | SPI_CR2_NSSP;
    SPI1->CR1|=  SPI_CR1_SPE; // eable peripheral
}
void spi_high_speed()
{
    SPI1->CR1 &= ~SPI_CR1_SPE;

    SPI1->CR1 |= SPI_CR1_BR_1 ;
    SPI1->CR1 |= SPI_CR1_SPE;  // enable the sp1 chanel

}

void TIM14_IRQHandler(void)
{
    TIM14->SR &= ~TIM_SR_UIF; // acknlowedge interrupt
    advance_fattime();
}
void setup_tim14()
{
    RCC->APB1ENR |= RCC_APB1ENR_TIM14EN;//enable clock to tim14
    TIM14->PSC = 48000 - 1;
    TIM14->ARR = 2000-1;
    TIM14->DIER = TIM_DIER_UIE; // generate an interrupt for each update event.
    TIM14->CR1 |= TIM_CR1_CEN; // enable timer
    NVIC->ISER[0] = (1<<TIM14_IRQn); // enable isr to tim14
}

const char testline[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\r\n";

int main()
{
    setup_usart5();

    // Uncomment these when you're asked to...
    setbuf(stdin, 0);
    setbuf(stdout, 0);
    setbuf(stderr, 0);

    // Test 2.2 simple_putchar()

    //for(;;)
      //  for(const char *t=testline; *t; t++)
        //   simple_putchar(*t);

    // Test for 2.3 simple_getchar()
    //
    //for(;;)
      //  simple_putchar( simple_getchar() );

    // Test for 2.4 and 2.5 __io_putchar() and __io_getchar()

    //printf("Hello!\n");
    //for(;;)
      //  putchar(getchar() );

    // Test for 2.6
    //
    //for(;;) {
      //  printf("Enter string: ");
       // char line[100];
      //fgets(line, 99, stdin);
        //line[99] = '\0'; // just in case
        //printf("You entered: %s", line);
    //}

    // Test for 2.7

   //enable_tty_interrupt();
    //for(;;) {
     //   printf("Enter string: ");
     //   char line[100];
     //   fgets(line, 99, stdin);
     //   line[99] = '\0'; // just in case
     //   printf("You entered: %s", line);
   // }

    // Test for 2.8 Test the command shell and clock.
    //
    enable_tty_interrupt();
    setup_tim14();
    FATFS fs_storage;
    FATFS *fs = &fs_storage;
    f_mount(fs, "", 1);
    command_shell();

    return 0;
}
