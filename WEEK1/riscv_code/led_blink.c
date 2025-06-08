#include "gpio_hal.h"

// Global variables for LED state
volatile uint32_t led_counter = 0;
volatile uint8_t current_led = 0;

// Initialize GPIO for LED control
void gpio_init(void) {
    // Set LED pins as outputs
    GPIO_SET_BIT(GPIO_OUTPUT_EN, LED_PIN_RED);
    GPIO_SET_BIT(GPIO_OUTPUT_EN, LED_PIN_GREEN);
    GPIO_SET_BIT(GPIO_OUTPUT_EN, LED_PIN_BLUE);
    
    // Clear all LEDs initially (LEDs are active low)
    GPIO_SET_BIT(GPIO_OUTPUT_VAL, LED_PIN_RED);
    GPIO_SET_BIT(GPIO_OUTPUT_VAL, LED_PIN_GREEN);
    GPIO_SET_BIT(GPIO_OUTPUT_VAL, LED_PIN_BLUE);
    
    // Disable I/O functions (use as GPIO)
    GPIO_CLEAR_BIT(GPIO_IOF_EN, LED_PIN_RED);
    GPIO_CLEAR_BIT(GPIO_IOF_EN, LED_PIN_GREEN);
    GPIO_CLEAR_BIT(GPIO_IOF_EN, LED_PIN_BLUE);
}

// Simple delay function
void delay(volatile uint32_t count) {
    while (count--) {
        // Volatile prevents optimization
        asm volatile ("nop");
    }
}

// Turn on specific LED (active low)
void led_on(uint8_t led_pin) {
    GPIO_CLEAR_BIT(GPIO_OUTPUT_VAL, led_pin);
}

// Turn off specific LED (active low)
void led_off(uint8_t led_pin) {
    GPIO_SET_BIT(GPIO_OUTPUT_VAL, led_pin);
}

// Toggle specific LED
void led_toggle(uint8_t led_pin) {
    GPIO_TOGGLE_BIT(GPIO_OUTPUT_VAL, led_pin);
}

// Turn off all LEDs
void all_leds_off(void) {
    led_off(LED_PIN_RED);
    led_off(LED_PIN_GREEN);
    led_off(LED_PIN_BLUE);
}

// LED sequence patterns
void led_sequence_1(void) {
    // Red -> Green -> Blue -> All Off
    all_leds_off();
    led_on(LED_PIN_RED);
    delay(500000);
    
    led_off(LED_PIN_RED);
    led_on(LED_PIN_GREEN);
    delay(500000);
    
    led_off(LED_PIN_GREEN);
    led_on(LED_PIN_BLUE);
    delay(500000);
    
    all_leds_off();
    delay(500000);
}

void led_sequence_2(void) {
    // All blink together
    led_on(LED_PIN_RED);
    led_on(LED_PIN_GREEN);
    led_on(LED_PIN_BLUE);
    delay(300000);
    
    all_leds_off();
    delay(300000);
}

// Main program
void main(void) {
    // Initialize GPIO system
    gpio_init();
    
    // Main LED blink loop
    while (1) {
        led_counter++;
        
        // Alternate between sequences
        if (led_counter % 8 < 4) {
            led_sequence_1();  // Individual LED sequence
        } else {
            led_sequence_2();  // All LEDs together
        }
        
        // Prevent counter overflow
        if (led_counter > 1000) {
            led_counter = 0;
        }
    }
}
