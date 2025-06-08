#include <stdint.h>

// Define the GPIO register address
#define GPIO_ADDR 0x10012000

// Function to toggle GPIO with proper volatile usage
void toggle_gpio(void) {
    volatile uint32_t *gpio = (volatile uint32_t *)GPIO_ADDR;
    
    // Set GPIO pin high
    *gpio = 0x1;
    
    // Toggle operation - read current state and flip
    uint32_t current_state = *gpio;
    *gpio = ~current_state;
    
    // Set specific bits (example: set bit 0, clear bit 1)
    *gpio |= (1 << 0);   // Set bit 0
    *gpio &= ~(1 << 1);  // Clear bit 1
}

// Function to demonstrate different GPIO operations
void gpio_operations(void) {
    volatile uint32_t *gpio = (volatile uint32_t *)GPIO_ADDR;
    
    // Write operations to prevent optimization
    *gpio = 0x0;         // Clear all pins
    *gpio = 0x1;         // Set pin 0
    *gpio = 0xFFFFFFFF;  // Set all pins
    *gpio = 0x0;         // Clear all pins again
}

int main() {
    // Demonstrate GPIO operations
    toggle_gpio();
    gpio_operations();
    
    // Infinite loop to keep program running (bare-metal style)
    while(1) {
        // In real hardware, this would continue GPIO operations
        // For demonstration, we'll break after some iterations
        static volatile int counter = 0;
        counter++;
        if (counter > 1000000) break;
    }
    
    return 0;
}

/*
Memory-Mapped I/O Explanation:
- volatile uint32_t *gpio: Prevents compiler optimization
- volatile tells compiler the memory can change outside program control
- Essential for hardware registers and memory-mapped I/O
- Address 0x10012000 must be 4-byte aligned for uint32_t access
- Each write operation will actually occur in hardware
*/
