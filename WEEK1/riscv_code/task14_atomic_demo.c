#include <stdint.h>

// Global shared variables for atomic operations demonstration
volatile uint32_t shared_counter = 0;
volatile uint32_t lock_variable = 0;

// Atomic Load-Reserved / Store-Conditional operations
static inline uint32_t atomic_load_reserved(volatile uint32_t *addr) {
    uint32_t result;
    asm volatile ("lr.w %0, (%1)" : "=r"(result) : "r"(addr) : "memory");
    return result;
}

static inline uint32_t atomic_store_conditional(volatile uint32_t *addr, uint32_t value) {
    uint32_t result;
    asm volatile ("sc.w %0, %2, (%1)" : "=r"(result) : "r"(addr), "r"(value) : "memory");
    return result;  // 0 = success, 1 = failure
}

// Atomic Memory Operations (AMO)
static inline uint32_t atomic_add(volatile uint32_t *addr, uint32_t value) {
    uint32_t result;
    asm volatile ("amoadd.w %0, %2, (%1)" : "=r"(result) : "r"(addr), "r"(value) : "memory");
    return result;  // Returns old value
}

static inline uint32_t atomic_swap(volatile uint32_t *addr, uint32_t value) {
    uint32_t result;
    asm volatile ("amoswap.w %0, %2, (%1)" : "=r"(result) : "r"(addr), "r"(value) : "memory");
    return result;  // Returns old value
}

static inline uint32_t atomic_and(volatile uint32_t *addr, uint32_t value) {
    uint32_t result;
    asm volatile ("amoand.w %0, %2, (%1)" : "=r"(result) : "r"(addr), "r"(value) : "memory");
    return result;  // Returns old value
}

static inline uint32_t atomic_or(volatile uint32_t *addr, uint32_t value) {
    uint32_t result;
    asm volatile ("amoor.w %0, %2, (%1)" : "=r"(result) : "r"(addr), "r"(value) : "memory");
    return result;  // Returns old value
}

// Lock-free increment using Load-Reserved/Store-Conditional
void atomic_increment_lr_sc(volatile uint32_t *counter) {
    uint32_t old_value, result;
    
    do {
        old_value = atomic_load_reserved(counter);
        result = atomic_store_conditional(counter, old_value + 1);
    } while (result != 0);  // Retry if store-conditional failed
}

// Simple spinlock implementation using atomic operations
void acquire_lock(volatile uint32_t *lock) {
    while (atomic_swap(lock, 1) != 0) {
        // Spin until lock is acquired (old value was 0)
    }
}

void release_lock(volatile uint32_t *lock) {
    atomic_swap(lock, 0);  // Release lock
}

// Demonstration functions
void demonstrate_atomic_operations(void) {
    uint32_t old_value;
    
    // 1. Atomic Add Operation
    old_value = atomic_add(&shared_counter, 5);
    // shared_counter increased by 5, old_value contains previous value
    
    // 2. Atomic Swap Operation
    old_value = atomic_swap(&shared_counter, 100);
    // shared_counter now contains 100, old_value contains previous value
    
    // 3. Atomic AND Operation
    old_value = atomic_and(&shared_counter, 0xFF);
    // shared_counter ANDed with 0xFF, old_value contains previous value
    
    // 4. Atomic OR Operation
    old_value = atomic_or(&shared_counter, 0x80000000);
    // shared_counter ORed with 0x80000000, old_value contains previous value
}

void demonstrate_lock_free_increment(void) {
    // Lock-free increment using Load-Reserved/Store-Conditional
    for (int i = 0; i < 10; i++) {
        atomic_increment_lr_sc(&shared_counter);
    }
}

void demonstrate_spinlock(void) {
    // Acquire lock, perform critical section, release lock
    acquire_lock(&lock_variable);
    
    // Critical section - only one thread can execute this
    shared_counter += 1;
    
    release_lock(&lock_variable);
}

int main() {
    // Initialize shared variables
    shared_counter = 0;
    lock_variable = 0;
    
    // Demonstrate different atomic operations
    demonstrate_atomic_operations();
    demonstrate_lock_free_increment();
    demonstrate_spinlock();
    
    return 0;
}

/*
RISC-V 'A' Extension Explanation:
================================

The 'A' extension adds atomic instructions for multiprocessor synchronization:

1. Load-Reserved/Store-Conditional:
   - lr.w: Load-reserved word
   - sc.w: Store-conditional word
   - Used for lock-free algorithms and atomic read-modify-write

2. Atomic Memory Operations (AMO):
   - amoadd.w: Atomic add
   - amoswap.w: Atomic swap
   - amoand.w: Atomic AND
   - amoor.w: Atomic OR
   - amoxor.w: Atomic XOR
   - amomin.w/amomax.w: Atomic min/max operations

Why Atomic Instructions are Useful:
===================================
1. Lock-free data structures (queues, stacks, lists)
2. Operating system kernels (schedulers, memory management)
3. Multiprocessor synchronization without locks
4. High-performance concurrent programming
5. Avoiding race conditions in shared memory systems
*/
