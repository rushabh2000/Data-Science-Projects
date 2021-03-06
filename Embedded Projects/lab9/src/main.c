
//============================================================================
// ECE 362 lab experiment 9 -- I2C
//============================================================================

#include "stm32f0xx.h"
#include <stdint.h> // for uint8_t
#include <string.h> // for strlen() and strcmp()

// Be sure to change this to your login...
const char login[] = "ranka0";

//============================================================================
// Wait for n nanoseconds. (Maximum: 4.294 seconds)
//============================================================================
void nano_wait(unsigned int n) {
    asm(    "        mov r0,%0\n"
            "repeat: sub r0,#83\n"
            "        bgt repeat\n" : : "r"(n) : "r0", "cc");
}

// Write your subroutines below...
void setup_i2c(void)
{
    RCC->AHBENR |= RCC_AHBENR_GPIOBEN;
    GPIOB->MODER &= ~(3<<16);
    GPIOB->MODER &= ~(3<<18);
    GPIOB->MODER |= 2<<(2*8) | 2<<(2*9);
    GPIOB->AFR[1] |= 1 ;
    GPIOB->AFR[1] |= 1 << 4;

    RCC->APB1ENR |= RCC_APB1ENR_I2C1EN;
    I2C1->CR1 &= ~I2C_CR1_PE;
    I2C1->CR1 &= ~I2C_CR1_ANFOFF;
    I2C1->CR1 &= ~I2C_CR1_ERRIE;
    I2C1->CR1 &= ~I2C_CR1_NOSTRETCH;

     I2C1->TIMINGR = 0;
     I2C1->TIMINGR &= ~I2C_TIMINGR_PRESC;// Clear prescaler
     I2C1->TIMINGR |= 0 << 28; // Set prescaler to 0
     I2C1->TIMINGR |= 3 << 20; // SCLDEL
     I2C1->TIMINGR |= 1 << 16; // SDADEL
     I2C1->TIMINGR |= 3 << 8; // SCLH
     I2C1->TIMINGR |= 9 << 0; // SCLL

     I2C1->OAR1 &= ~I2C_OAR1_OA1EN;
     I2C1->OAR2 &= ~I2C_OAR2_OA2EN;

     I2C1->CR2 &= ~I2C_CR2_ADD10;
     I2C1->CR2 |= I2C_CR2_AUTOEND;

     I2C1->CR1 |= I2C_CR1_PE;

}
void i2c_start(uint32_t devaddr, uint8_t size, uint8_t dir) {
 // dir: 0 = master requests a write transfer
 // dir: 1 = master requests a read transfer
 uint32_t tmpreg = I2C1->CR2;
 tmpreg &= ~(I2C_CR2_SADD | I2C_CR2_NBYTES |
 I2C_CR2_RELOAD | I2C_CR2_AUTOEND |
 I2C_CR2_RD_WRN | I2C_CR2_START | I2C_CR2_STOP);
 if (dir == 1)
 tmpreg |= I2C_CR2_RD_WRN; // Read from slave
 else
 tmpreg &= ~I2C_CR2_RD_WRN; // Write to slave
 tmpreg |= ((devaddr<<1) & I2C_CR2_SADD) | ((size << 16) & I2C_CR2_NBYTES);
 tmpreg |= I2C_CR2_START;
 I2C1->CR2 = tmpreg;
}
void i2c_stop(void) {
 if (I2C1->ISR & I2C_ISR_STOPF)
 return;
 // Master: Generate STOP bit after current byte has been transferred.
 I2C1->CR2 |= I2C_CR2_STOP;
 // Wait until STOPF flag is reset
 while( (I2C1->ISR & I2C_ISR_STOPF) == 0);
 I2C1->ICR |= I2C_ICR_STOPCF; // Write to clear STOPF flag
}
void i2c_waitidle(void) {
 while ( (I2C1->ISR & I2C_ISR_BUSY) == I2C_ISR_BUSY); // while busy, wait.
}
int8_t i2c_senddata (uint8_t devaddr, void *pdata, uint8_t size) {
 int i;
 if (size <= 0 || pdata == 0) return -1;
 uint8_t *udata = (uint8_t*)pdata;
 i2c_waitidle();
 // Last argument is dir: 0 = sending data to the slave.
 i2c_start(devaddr, size, 0);
 for(i=0; i<size; i++) {
 // TXIS bit is set by hardware when the TXDR register is empty and the
 // data to be transmitted must be written in the TXDR register. It is
 // cleared when the next data to be sent is written in the TXDR reg

 // The TXIS flag is not set when a NACK is received.
 int count = 0;
 while( (I2C1->ISR & I2C_ISR_TXIS) == 0) {
     count += 1;
     if (count > 1000000) return -1;
// if (i2c_checknack()) { i2c_clearnack(); i2c_stop(); return -1; }

}
 // TXIS is cleared by writing to the TXDR register.
 I2C1->TXDR = udata[i] & I2C_TXDR_TXDATA;

}
 // Wait until TC flag is set or the NACK flag is set.
 while((I2C1->ISR & I2C_ISR_TC) == 0 && (I2C1->ISR & I2C_ISR_NACKF) == 0);
 if ( (I2C1->ISR & I2C_ISR_NACKF) != 0)
     return -1;
 i2c_stop();
 return 0; }

uint8_t I2C_receivedata (uint8_t SlaveAddress, uint8_t *pData, uint8_t Size)
{
    int i;

    if (Size <= 0 || pData == NULL) return -1;

    i2c_waitidle();
    i2c_start(SlaveAddress,Size,1);
    for(i = 0; i <Size ; i++){
        while((I2C1->ISR & I2C_ISR_RXNE) == 0);
        pData[i] = I2C1->RXDR & I2C_RXDR_RXDATA;

    }
    while((I2C1->ISR & I2C_ISR_TC) == 0);

    i2c_stop();
    return 0;
}

void i2c_set_iodir(uint8_t x)
{
    uint8_t data[] = {0x00, x};

    i2c_senddata(0x27, data, sizeof data);

}

void i2c_set_gpio(uint8_t x)
{
    uint8_t data[] = {0x09, x};
    i2c_senddata(0x27, data, sizeof data);
}
uint8_t i2c_get_gpio()
{

    char buffer[32];
    int x = I2C_receivedata(0x27, buffer, sizeof buffer);

    return buffer[0];
}
void i2c_write_flash(uint16_t loc, const char *data, uint8_t len)
{
        if(len >= 32){
        uint8_t buffer [34];
        buffer[0] = (loc >>8) & 0xff;
        buffer[1] = loc & 0xff;

        for (int i=2; i < len + 2; i++){
            buffer[i] = data[i - 2];

        }
        i2c_senddata(0x57,buffer,sizeof buffer );
        }

}
int i2c_write_flash_complete()
{
    while(1) {
        i2c_waitidle();
         i2c_start(0x57, 0, 0);

         int x=0;
         while(((I2C1->ISR & I2C_ISR_TC) == 0 && (I2C1->ISR & I2C_ISR_STOPF))|| ~((I2C1->ISR & I2C_ISR_NACKF) == 0)&&(I2C1->ISR & I2C_ISR_STOPF)))
          x++;

         if (I2C1->ISR & I2C_ISR_NACKF)
              I2C1->ICR |= I2C_ICR_NACKCF;
               i2c_stop();
          return 0;
          i2c_stop();
          return 1;


}}

void i2c_read_flash(uint16_t loc, char data[], uint8_t len)
{

}


void internal_clock();
void demo();
void autotest();

int main(void)
{
    //internal_clock();
    //demo();
    autotest();

    setup_i2c();
    //i2c_test();

    i2c_set_iodir(0xf0); //  upper 4 bits input / lower 4 bits output

    // Show the happy LEDs for 4 seconds.
    for(int i=0; i<10; i++) {
        for(int n=1; n <= 8; n <<= 1) {
            i2c_set_gpio(n);
            int value = i2c_get_gpio();
            if ((value & 0xf) != n)
                break;
            nano_wait(100000000); // 0.1 s
        }
    }

    const char string[] = "This is a test.";
    int len = strlen(string) + 1;
    i2c_write_flash(0x200, string, len);

    int count = 0;
    while(1) {
        if (i2c_write_flash_complete())
            break;
        count++;
    }

    if (count == 0) {
        // It could not have completed immediately.
        // i2c_write_flash_complete() does not work.  Show slow angry LEDs.
        int all = 0xf;
        for(;;) {
            i2c_set_gpio(all);
            all ^= 0xf;
            nano_wait(500000000);
        }
    }

    char readback[100];
    i2c_read_flash(0x200, readback, len);
    if (strcmp(string,readback) == 0) {
        // String comparison matched.  Show the happy LEDs.
        for(;;) {
            for(int n=1; n <= 8; n <<= 1) {
                i2c_set_gpio(n);
                int value = i2c_get_gpio();
                if ((value & 0xf) != n)
                    break;
                nano_wait(100000000); // 0.1 s
            }
        }
    } else {
        // String comparison failed.  Show the angry LEDs.
        int all = 0xf;
        for(;;) {
            i2c_set_gpio(all);
            all ^= 0xf;
            nano_wait(100000000);
        }
    }
}
