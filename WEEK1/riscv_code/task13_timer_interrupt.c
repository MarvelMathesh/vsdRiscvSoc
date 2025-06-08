#include <stdint.h>

// Memory-mapped timer registers (QEMU virt machine)
#define MTIME_BASE 0x0200BFF8
#define MTIMECMP_BASE 0x02004000

volatile uint64_t *mtime = (volatile uint64_t *)MTIME_BASE;
volatile uint64_t *mtimecmp = (volatile uint64_t *)MTIMECMP_BASE;

// Global counter for interrupt handling
volatile uint32_t interrupt_count = 0;

// Timer interrupt handler with interrupt attribute
void __attribute__((interrupt)) timer_interrupt_handler(void) {
    // Clear timer interrupt by setting next compare value
    *mtimecmp = *mtime + 10000000;  // Next interrupt in ~1 second (assuming 10MHz)
    
    // Increment interrupt counter
    interrupt_count++;
}

// Function to read CSR registers
static inline uint32_t read_csr_mstatus(void) {
    uint32_t result;
    asm volatile ("csrr %0, mstatus" : "=r"(result));
    return result;
}

static inline uint32_t read_csr_mie(void) {
    uint32_t result;
    asm volatile ("csrr %0, mie" : "=r"(result));
    return result;
}

// Function to write CSR registers
static inline void write_csr_mstatus(uint32_t value) {
    asm volatile ("csrw mstatus, %0" : : "r"(value));
}

static inline void write_csr_mie(uint32_t value) {
    asm volatile ("csrw mie, %0" : : "r"(value));
}

static inline void write_csr_mtvec(uint32_t value) {
    asm volatile ("csrw mtvec, %0" : : "r"(value));
}

void enable_timer_interrupt(void) {
    // Set initial timer compare value
    *mtimecmp = *mtime + 10000000;  // First interrupt in ~1 second
    
    // Set interrupt vector (direct mode)
    write_csr_mtvec((uint32_t)timer_interrupt_handler);
    
    // Enable machine timer interrupt in mie register
    uint32_t mie = read_csr_mie();
    mie |= (1 << 7);  // MTIE bit (Machine Timer Interrupt Enable)
    write_csr_mie(mie);
    
    // Enable global machine interrupts in mstatus
    uint32_t mstatus = read_csr_mstatus();
    mstatus |= (1 << 3);  // MIE bit (Machine Interrupt Enable)
    write_csr_mstatus(mstatus);
}

void delay(volatile int count) {
    while(count--) {
        asm volatile ("nop");
    }
}

int main() {
    // Initialize interrupt system
    enable_timer_interrupt();
    
    uint32_t last_count = 0;
    
    while(1) {
        // Check if interrupt occurred
        if (interrupt_count != last_count) {
            last_count = interrupt_count;
            // In real hardware, this could toggle an LED or print
            // For demonstration, we just continue
        }
        
        delay(100000);
        
        // Break after some interrupts for demonstration
        if (interrupt_count >= 5) {
            break;
        }
    }
    
    return 0;
}
