#include <stdint.h>

// Global shared resources
volatile int spinlock = 0;
volatile int shared_counter = 0;
volatile int thread1_iterations = 0;
volatile int thread2_iterations = 0;

// Spinlock acquire using LR/SC atomic instructions
void spinlock_acquire(volatile int *lock) {
    int tmp;
    asm volatile (
        "1:\n"
        "    lr.w    %0, (%1)\n"           // Load-reserved from lock address
        "    bnez    %0, 1b\n"             // If lock != 0, retry (spin)
        "    li      %0, 1\n"              // Load immediate 1 (locked state)
        "    sc.w    %0, %0, (%1)\n"       // Store-conditional 1 to lock
        "    bnez    %0, 1b\n"             // If sc.w failed, retry
        : "=&r" (tmp)                      // Output: temporary register
        : "r" (lock)                       // Input: lock address
        : "memory"                         // Memory barrier
    );
}

// Spinlock release
void spinlock_release(volatile int *lock) {
    asm volatile (
        "sw      zero, 0(%0)\n"            // Store 0 (unlocked state)
        :
        : "r" (lock)                       // Input: lock address
        : "memory"                         // Memory barrier
    );
}

// Critical section function with mutex protection
void increment_shared_counter(int thread_id, int iterations) {
    for (int i = 0; i < iterations; i++) {
        // Acquire spinlock (enter critical section)
        spinlock_acquire(&spinlock);
        
        // Critical section - only one thread can execute this
        int temp = shared_counter;
        temp = temp + 1;
        shared_counter = temp;
        
        // Update thread-specific counter
        if (thread_id == 1) {
            thread1_iterations++;
        } else {
            thread2_iterations++;
        }
        
        // Release spinlock (exit critical section)
        spinlock_release(&spinlock);
    }
}

// Pseudo-thread 1 function
void thread1_function(void) {
    increment_shared_counter(1, 50000);
}

// Pseudo-thread 2 function
void thread2_function(void) {
    increment_shared_counter(2, 50000);
}

// Delay function to simulate work
void delay(volatile int count) {
    while(count--) {
        asm volatile ("nop");
    }
}

int main() {
    // Initialize shared variables
    spinlock = 0;
    shared_counter = 0;
    thread1_iterations = 0;
    thread2_iterations = 0;
    
    // Simulate two threads executing concurrently
    thread1_function();
    delay(1000);
    thread2_function();
    
    return 0;
}
