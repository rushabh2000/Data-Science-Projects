
#include "stm32f0xx.h"
#include <stdint.h>
#include <stdlib.h>
#include "lcd.h"
#include <stdio.h>

int i =0;
int j =0;
int dig  =0;
int display[10] = {0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07, 0x7f, 0x67};
void nano_wait(unsigned int);
void setup_adc(void)
{
   RCC->AHBENR |=  RCC_AHBENR_GPIOAEN; // enable clock
   GPIOA->MODER |= 0xf; // set pis 0,1 for input
   RCC->APB2ENR |= RCC_APB2ENR_ADC1EN; // enable clock to adc
   RCC->CR2 |= RCC_CR2_HSI14ON; // turn on 14mhz
   while (!(RCC->CR2 & RCC_CR2_HSI14RDY)); // wait for cloclk to be ready
   ADC1->CR |= ADC_CR_ADEN; //enable adc by setting aden
   while (!(ADC1->ISR  & ADC_ISR_ADRDY)); // wait for adc to be ready


}

//============================================================================
// start_adc_channel()    (Autotest #2)
// Select an ADC channel, and initiate an A-to-D conversion.
// Parameters: n: channel number
//============================================================================
void start_adc_channel(int n)
{
    ADC1->CHSELR = 0 ;
    ADC1->CHSELR |= 1 << n ; // select the chanel to outoput
    while(!(ADC1->ISR & ADC_ISR_ADRDY)); // check if adc ready
    ADC1->CR |= ADC_CR_ADSTART; // start the adc calculation


}

//============================================================================
// read_adc()    (Autotest #3)
// Wait for A-to-D conversion to complete, and return the result.
// Parameters: none
// Return value: converted result
//============================================================================
int read_adc(void)
{
    //while(!(ADC1->ISR & ADC_ISR_EOC));//
    return ADC1->DR;/* replace with something meaningful */
}

void init(){
   GPIOC->ODR = display[i] ;
}
void show_digit(int d)// i passed here
{
    if( i < 10){
    int off = d & 0xf;
    GPIOC->ODR =  0 << 8 | display[off];
    }

    if(i >=10 & i< 100){
            int dig = i;
            int j = dig %10;
            j = j & 0xf;
            dig = dig /10;
            dig = dig & 0xf;


            GPIOC->ODR = (1 << 8 | display[j]);
            nano_wait(100000);
            GPIOC->ODR = ( display[dig]) ;
        }



}

void setup_tim17()//int i)
{
    // Set this to invoke the ISR 100 times per second.
    RCC->APB2ENR |= RCC_APB2ENR_TIM17EN;

        TIM17->PSC = 24000  - 1;

        TIM17->ARR = 20 - 1;

        TIM17->DIER = TIM_DIER_UIE;
                    TIM17->CR1 |= TIM_CR1_CEN;
                    NVIC->ISER[0] = (1<<TIM17_IRQn);
}
int get_cols()
{
    return (GPIOB->IDR >> 4) & 0xf;
}


void setup_portb()
{
    RCC->AHBENR |= RCC_AHBENR_GPIOBEN; // Enable Port B.
    // Set PB0-PB3 for output.
    // Set PB4-PB7 for input and enable pull-down resistors.


    RCC->AHBENR |=  RCC_AHBENR_GPIOCEN;


    GPIOC->MODER &= ~(0xf<<0);
    GPIOC->MODER &= ~(0xf<<4);
    GPIOC->MODER &= ~(0xf<<8);
    GPIOC->MODER &= ~(0xf<<12);
    GPIOC->MODER &= ~(0xf<<16);
    GPIOC->MODER &= ~(0xf<<20);

    GPIOC->MODER |= (5<<0); // pa8 for ch1
    GPIOC->MODER |= (5<<4);
    GPIOC->MODER |= (5<<8);
    GPIOC->MODER |= (5<<12);
    GPIOC->MODER |= (5<<16);
    GPIOC->MODER |= (1<<20);


    GPIOB->MODER &= ~(0xf<<0);
        GPIOB->MODER &= ~(0xf<<4);
        GPIOB->MODER &= ~(0xf<<8); // 4-7
        GPIOB->MODER &= ~(0xf<<12);


        GPIOB->MODER |= (5<<0);
        GPIOB->MODER |= (5<<4);


       GPIOB->PUPDR &= ~(0xf<<8);
       GPIOB->PUPDR &= ~(0xf<<12);

       GPIOB->PUPDR |= (10<<8);
       GPIOB->PUPDR |= (10<<12);
    // Turn on the output for the lower row.
       int row = 3 & 3;
       GPIOB->BSRR = 0xf0000 | (1<<row);


}

char check_key()
{

    int cols = get_cols();
    if(cols == 8)
        {
            return 'D';
        }
    if(cols == 1)
    {
        return '*';
    }

    else
        return 0;

    // If the '*' key is pressed, return '*'
    // If the 'D' key is pressed, return 'D'
    // Otherwise, return 0
}

void setup_spi1()
{
    // Use setup_spi1() from lab 8.
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

// Copy a subset of a large source picture into a smaller destination.
// sx,sy are the offset into the source picture.
void pic_subset(Picture *dst, const Picture *src, int sx, int sy)
{
    int dw = dst->width;
    int dh = dst->height;
    if (dw + sx > src->width)
        for(;;)
            ;
    if (dh + sy > src->height)
        for(;;)
            ;
    for(int y=0; y<dh; y++)
        for(int x=0; x<dw; x++)
            dst->pix2[dw * y + x] = src->pix2[src->width * (y+sy) + x + sx];
}

// Overlay a picture onto a destination picture.
// xoffset,yoffset are the offset into the destination picture that the
// source picture is placed.
// Any pixel in the source that is the 'transparent' color will not be
// copied.  This defines a color in the source that can be used as a
// transparent color.
void pic_overlay(Picture *dst, int xoffset, int yoffset, const Picture *src, int transparent)
{
    for(int y=0; y<src->height; y++) {
        int dy = y+yoffset;
        if (dy < 0 || dy >= dst->height)
            continue;
        for(int x=0; x<src->width; x++) {
            int dx = x+xoffset;
            if (dx < 0 || dx >= dst->width)
                continue;
            unsigned short int p = src->pix2[y*src->width + x];
            if (p != transparent)
                dst->pix2[dy*dst->width + dx] = p;
        }
    }
}
void spi_cmd (int cal)
{
    while(0 == 0)
    {
        if((SPI2-> SR & 0x2) != 0)
        {
            SPI2->DR = cal;
            return;
        }
    }
}

float speedfac = 0;
int counter = 0;
int sample = 0;
float level = 0;

// Called after a bounce, update the x,y velocity components in a
// pseudo random way.  (+/- 1)
void perturb(int *vx, int *vy)
{
    sample = read_adc();
    level = trunc(2.95 * sample / 4095)/10.0;

    if((speedfac != level) &(counter == 0)){
        counter = 1;
        speedfac = level;
        *vy = speedfac;
        *vx = speedfac;


    }

    if((speedfac != level) &(counter == 1)){
        counter = 0;
    }
    if (*vx > 0) {
        *vx += (random()%3) - 1;
        if (*vx >= 3)
            *vx = 2;
        if (*vx == 0)
            *vx = 1;
    } else {
        *vx += (random()%3) - 1;
        if (*vx <= -3)
            *vx = -2;
        if (*vx == 0)
            *vx = -1;
    }
    if (*vy > 0) {
        *vy += (random()%3) - 1;
        if (*vy >= 3)
            *vy = 2;
        if (*vy == 0)
            *vy = 1;
    } else {
        *vy += (random()%3) - 1;
        if (*vy <= -3)
            *vy = -2;
        if (*vy == 0)
            *vy = -1;
    }
}

extern const Picture background; // A 240x320 background image
extern const Picture ball; // A 19x19 purple ball with white boundaries
extern const Picture paddle; // A 59x5 paddle

const int border = 20;
int xmin; // Farthest to the left the center of the ball can go
int xmax; // Farthest to the right the center of the ball can go
int ymin; // Farthest to the top the center of the ball can go
int ymax; // Farthest to the bottom the center of the ball can go
int x,y; // Center of ball
int vx,vy; // Velocity components of ball
int score = 0;
int px; // Center of paddle offset
int newpx; // New center of paddle

// This C macro will create an array of Picture elements.
// Really, you'll just use it as a pointer to a single Picture
// element with an internal pix2[] array large enough to hold
// an image of the specified size.
// BE CAREFUL HOW LARGE OF A PICTURE YOU TRY TO CREATE:
// A 100x100 picture uses 20000 bytes.  You have 32768 bytes of SRAM.
#define TempPicturePtr(name,width,height) Picture name[(width)*(height)/6+2] = { {width,height,2} }

// Create a 29x29 object to hold the ball plus padding
TempPicturePtr(object,29,29);

void TIM17_IRQHandler(void)
{

    TIM17->SR &= ~TIM_SR_UIF;
    char key = check_key();
    if (key == '*')
        newpx -= 1;
    else if (key == 'D')
        newpx += 1;
    if (newpx - paddle.width/2 <= border || newpx + paddle.width/2 >= 240-border)
        newpx = px;
    if (newpx != px) {
        px = newpx;
        // Create a temporary object two pixels wider than the paddle.
        // Copy the background into it.
        // Overlay the paddle image into the center.
        // Draw the result.
        //
        // As long as the paddle moves no more than one pixel to the left or right
        // it will clear the previous parts of the paddle from the screen.
        TempPicturePtr(tmp,61,5);
        pic_subset(tmp, &background, px-tmp->width/2, background.height-border-tmp->height); // Copy the background
        pic_overlay(tmp, 1, 0, &paddle, -1);
        LCD_DrawPicture(px-tmp->width/2, background.height-border-tmp->height, tmp);
    }
    x += vx;
    y += vy;
    if (x <= xmin) {
        // Ball hit the left wall.
        vx = - vx;
        if (x < xmin)
            x += vx;
        perturb(&vx,&vy);
    }
    if (x >= xmax) {
        // Ball hit the right wall.
        vx = -vx;
        if (x > xmax)
            x += vx;
        perturb(&vx,&vy);
    }
    if (y <= ymin) {
        // Ball hit the top wall.
        vy = - vy;
        if (y < ymin)
            y += vy;
        perturb(&vx,&vy);
    }
    if (y >= ymax - paddle.height &&
        x >= (px - paddle.width/2) &&
        x <= (px + paddle.width/2)) {
        // The ball has hit the paddle.  Bounce.
        int pmax = ymax - paddle.height;
        vy = -vy;
        if (y > pmax)
            y += vy;

        if(vx != 0 |vy !=0 ){
        //score = score + 1;
        //char buffer[20];
        //sprintf(buffer,"score %d",score);
        //spi_display2(buffer);
        //}
        //if(i <10){
        //GPIOC->ODR = display[i] ;
        //}
        i = i + 1;


        setup_tim7();

        }

    }
    else if (y >= ymax) {
        // The ball has hit the bottom wall.  Set velocity of ball to 0,0.
        vx = 0;
        vy = 0;

    }

    TempPicturePtr(tmp,29,29); // Create a temporary 29x29 image.
    pic_subset(tmp, &background, x-tmp->width/2, y-tmp->height/2); // Copy the background
    pic_overlay(tmp, 0,0, object, 0xffff); // Overlay the object
    pic_overlay(tmp, (px-paddle.width/2) - (x-tmp->width/2),
            (background.height-border-paddle.height) - (y-tmp->height/2),
            &paddle, 0xffff); // Draw the paddle into the image
    LCD_DrawPicture(x-tmp->width/2,y-tmp->height/2, tmp); // Re-draw it to the screen
    // The object has a 5-pixel border around it that holds the background
    // image.  As long as the object does not move more than 5 pixels (in any
    // direction) from it's previous location, it will clear the old object.
}
void TIM7_IRQHandler()
{
    TIM7->SR &= ~TIM_SR_UIF;



    show_digit(i);





}
//============================================================================
// setup_tim7()    (Autotest #10)
// Configure timer 7.
// Parameters: none
//============================================================================
void setup_tim7()
{
    RCC->APB1ENR &= ~(RCC_APB1ENR_TIM6EN);
    RCC->APB1ENR |= RCC_APB1ENR_TIM7EN;
    TIM7->PSC = 4800 - 1;
    TIM7->ARR = 10 - 1;

    TIM7->DIER = TIM_DIER_UIE;
                TIM7->CR1 |= TIM_CR1_CEN;
                NVIC->ISER[0] = (1<<TIM7_IRQn);

}


int main(void)
{

    setup_portb();
    init();
    setup_spi1();
    //setup_spi2();
    //spi_init_oled();
    //char buffer2[20];
    //sprintf(buffer2,"score %d",score);
    //spi_display2(buffer2);
    LCD_Init();

    // Draw the background.
    LCD_DrawPicture(0,0,&background);

    // Set all pixels in the object to white.
    for(int i=0; i<29*29; i++)
        object->pix2[i] = 0xffff;

    // Center the 19x19 ball into center of the 29x29 object.
    // Now, the 19x19 ball has 5-pixel white borders in all directions.
    pic_overlay(object,5,5,&ball,0xffff);

    // Initialize the game state.
    xmin = border + ball.width/2;
    xmax = background.width - border - ball.width/2;
    ymin = border + ball.width/2;
    ymax = background.height - border - ball.height/2;
    x = (xmin+xmax)/2; // Center of ball
    y = ymin;
    vx = 0; // Velocity components of ball
    vy = 1;

    px = -1; // Center of paddle offset (invalid initial value to force update)
    newpx = (xmax+xmin)/2; // New center of paddle


    setup_tim17();
    setup_adc();
    start_adc_channel(0);


}
