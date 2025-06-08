#include <stdint.h>
#define GPIO_ADDR 0x10012000

void toggle_gpio_no_volatile(void) {
    uint32_t *gpio = (uint32_t *)GPIO_ADDR; // No volatile
    *gpio = 0x1;
    *gpio = 0x0;
    *gpio = 0x1; // Compiler might optimize this away
}

int main() {
    toggle_gpio_no_volatile();
    return 0;
}
