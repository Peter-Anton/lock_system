#include <mega16a.h>
#include <alcd.h>
#include <stdlib.h>
#include <delay.h>
#include <stdint.h>

#define F_CPU 20000000UL
#define TIMER_PRESCALER 256 // Prescaler value for Timer1
#define  ICR1  ( ICR1L | ((unsigned int)(ICR1H) << 8))

unsigned long frequency;
char buffer[16];

void ultoa_custom(unsigned long val, char *buf, unsigned char radix)
{
    unsigned char i = 0;
    unsigned char start;
    unsigned char end;
    unsigned long rem;
    char temp;

    if (val == 0)
    {
        buf[i++] = '0';
        buf[i] = '\0';
        return;
    }

    while (val != 0)
    {
        rem = val % radix;
        buf[i++] = (rem > 9) ? (rem - 10) + 'A' : rem + '0';
        val = val / radix;
    }

    buf[i] = '\0';

    // Reverse the string
    start = 0;
    end = i - 1;
    while (start < end)
    {
        temp = buf[start];
        buf[start] = buf[end];
        buf[end] = temp;
        start++;
        end--;
    }
}

void main(void)
{
    // Initialize LCD
    lcd_init(16);     
    
    // Set Timer1 to Normal mode, prescaler 256                             
    TCCR1A = 0; // Normal mode
    TCCR1B = (1 << ICES1) | (1 << CS12); // Input capture on rising edge, prescaler 256

    // Enable Timer1 overflow interrupt
    TIMSK |= (1 << TOIE1);
    
    // Enable Timer1 input capture interrupt
    TIMSK |= (1 << TICIE1);

    // Set I/O direction for ICP1 pin (PD6)
    DDRD &= ~(1 << PORTD6);

    // Global enable interrupts
    #asm("sei")

    while (1)
    {
        // Display frequency on LCD
        lcd_clear();
        lcd_gotoxy(0, 0);
        ultoa_custom(frequency, buffer, 10);
        lcd_puts(buffer);
        lcd_puts(" Hz");
        
        // Wait for a short time to update the display
        delay_ms(100);
    }
}

interrupt [TIM1_OVF] void timer1_ovf_isr(void)
{
    // Timer1 overflowed, indicating low frequency or no signal
    frequency = 0;
}

interrupt [TIM1_CAPT] void timer1_capt_isr(void)
{
    static uint32_t prev_capture = 0;
    uint32_t current_capture;
    uint32_t period;

    // Get the current capture value
    current_capture = ICR1;

    // Calculate the period (in clock cycles)
    period = current_capture - prev_capture;

    // Update the frequency (in Hz)
    frequency = (F_CPU / TIMER_PRESCALER) / period;

    // Update the previous capture value
    prev_capture = current_capture;
}