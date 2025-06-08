#ifndef GPIO_HAL_H
#define GPIO_HAL_H

#include <stdint.h>

// GPIO register addresses (SiFive FE310-like layout)
#define GPIO_BASE       0x10012000
#define GPIO_INPUT_VAL  (GPIO_BASE + 0x00)  // GPIO input value
#define GPIO_INPUT_EN   (GPIO_BASE + 0x04)  // GPIO input enable
#define GPIO_OUTPUT_EN  (GPIO_BASE + 0x08)  // GPIO output enable
#define GPIO_OUTPUT_VAL (GPIO_BASE + 0x0C)  // GPIO output value
#define GPIO_PUE        (GPIO_BASE + 0x10)  // GPIO pull-up enable
#define GPIO_DS         (GPIO_BASE + 0x14)  // GPIO drive strength
#define GPIO_RISE_IE    (GPIO_BASE + 0x18)  // GPIO rise interrupt enable
#define GPIO_RISE_IP    (GPIO_BASE + 0x1C)  // GPIO rise interrupt pending
#define GPIO_FALL_IE    (GPIO_BASE + 0x20)  // GPIO fall interrupt enable
#define GPIO_FALL_IP    (GPIO_BASE + 0x24)  // GPIO fall interrupt pending
#define GPIO_HIGH_IE    (GPIO_BASE + 0x28)  // GPIO high interrupt enable
#define GPIO_HIGH_IP    (GPIO_BASE + 0x2C)  // GPIO high interrupt pending
#define GPIO_LOW_IE     (GPIO_BASE + 0x30)  // GPIO low interrupt enable
#define GPIO_LOW_IP     (GPIO_BASE + 0x34)  // GPIO low interrupt pending
#define GPIO_IOF_EN     (GPIO_BASE + 0x38)  // GPIO I/O function enable
#define GPIO_IOF_SEL    (GPIO_BASE + 0x3C)  // GPIO I/O function select
#define GPIO_OUT_XOR    (GPIO_BASE + 0x40)  // GPIO output XOR

// LED pin definitions
#define LED_PIN_RED     22  // Red LED on pin 22
#define LED_PIN_GREEN   19  // Green LED on pin 19
#define LED_PIN_BLUE    21  // Blue LED on pin 21

// GPIO control macros
#define GPIO_SET_BIT(reg, pin)   (*((volatile uint32_t*)(reg)) |= (1 << (pin)))
#define GPIO_CLEAR_BIT(reg, pin) (*((volatile uint32_t*)(reg)) &= ~(1 << (pin)))
#define GPIO_TOGGLE_BIT(reg, pin) (*((volatile uint32_t*)(reg)) ^= (1 << (pin)))
#define GPIO_READ_BIT(reg, pin)  ((*((volatile uint32_t*)(reg)) >> (pin)) & 1)

#endif /* GPIO_HAL_H */
