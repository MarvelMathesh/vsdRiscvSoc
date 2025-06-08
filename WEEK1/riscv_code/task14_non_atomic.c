#include <stdint.h>

// Same operations but WITHOUT atomic instructions (race condition prone)
volatile uint32_t shared_counter = 0;
volatile uint32_t lock_variable = 0;

// Non-atomic increment (race condition possible)
void non_atomic_increment(volatile uint32_t *counter) {
    uint32_t temp = *counter;  // Read
    temp = temp + 1;           // Modify
    *counter = temp;           // Write (race condition here!)
}

// Non-atomic lock (unreliable)
void unreliable_lock(volatile uint32_t *lock) {
    while (*lock != 0) {
        // Wait for lock to be free
    }
    *lock = 1;  // This is NOT atomic - race condition!
}

int main() {
    // This code has race conditions in multiprocessor systems
    non_atomic_increment(&shared_counter);
    unreliable_lock(&lock_variable);
    
    return 0;
}

/*
Problems with Non-Atomic Operations:
====================================
1. Race conditions in multiprocessor systems
2. Lost updates when multiple cores access same memory
3. Inconsistent data in shared data structures
4. Need for expensive locking mechanisms
5. Reduced performance due to lock contention

This is why the 'A' extension is crucial for modern systems!
*/
