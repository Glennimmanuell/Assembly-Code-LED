.global _start
.section .data
.equ GPIO_BASE,   0xfe200000   
.equ GPIO_SET,    0x1C          
.equ GPIO_CLR,    0x28          
.equ GPIO_PIN,    3            
on_message:  .asciz "LED ON\n"
off_message: .asciz "LED OFF\n"

.text
.section .text
.globl _start

_start:
    
    mov x8, #56            
    mov x0, #0             
    ldr x1, =gpio_device    
    mov x2, #2             
    mov x3, #0             
    svc #0

    cmp x0, #0
    blt _exit

    mov x8, #222           
    mov x0, #0            
    mov x1, #4096          
    mov x2, #3             
    mov x3, #2             
    mov x4, x0             
    mov x5, #0             
    mov x7, #222           /
    svc #0

    
    cmp x0, #0
    blt _close_fd

   
    ldr x1, =GPIO_BASE
    ldr x1, [x1]
    mov x2, #0x07
    bic x2, x2, #(0x07 << ((GPIO_PIN % 10) * 3))
    orr x2, x2, #(0x01 << ((GPIO_PIN % 10) * 3))
    str x2, [x1]

    
    mov x6, #1 << GPIO_PIN

    
    mov w8, #64            
    mov x0, #1             
    ldr x1, =on_message    
    ldr x2, =8            
    mov x7, #64            
    svc #0

loop:
    
    ldr x1, =GPIO_SET
    str x6, [x1]

    // Delay
    movz x7, #1000         
    movk x7, #1, lsl #16   
delay_high:
    subs x7, x7, #1
    bne delay_high

    
    str x6, [x0, #GPIO_CLR]

   
    movz x7, #1000         
    movk x7, #1, lsl #16   
delay_low:
    subs x7, x7, #1
    bne delay_low

    
    b loop

_close_fd:
   
    mov x8, #57            
    mov x0, x4            
    mov x7, #57            /
    svc #0

_exit:
   
    mov w8, #64            
    mov x0, #1             
    ldr x1, =off_message  
    ldr x2, =9            
    mov x7, #64            
    svc #0

    mov x8, #93            
    mov x0, #0             
    mov x7, #93            
    svc #0

gpio_device:
    .asciz "/dev/gpiomem"
