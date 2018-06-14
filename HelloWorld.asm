; This uses nasm, you will need to install nasm for this to work.
; Build and run with this command: 
;  Linux 32-bit: nasm -felf32 HelloWorld.asm && ld -m elf_i386 HelloWorld.o && ./a.out
;  Linux 64-bit: nasm -felf64 HelloWorld.asm && ld HelloWorld.o && ./a.out
;  Windows: TODO: need to write one for this os

section .data
hello:    db "Hello, world!", 0xa
hellolen: equ $ - hello
db 0 ; For extra null bit when needed.

global _start

section .text

_start:

%ifidn __OUTPUT_FORMAT__, elf64

  ; Linux 64-bit hello world

  ; Write 'Hello, world'
  mov rdi, 1        ; fd = stdout
  mov rsi, hello    ; buff = [hello]
  mov edx, hellolen ; len = hellolen
  mov eax, 1        ; sys_write
  syscall

  ; Exit normally
  mov rdi, 0   ; error_code = 0
  mov eax, 60  ; sys_exit
  syscall

%elifidn __OUTPUT_FORMAT__, elf32

  ; Linux 32-bit hello world

  ; Write 'Hello, world'
  mov ebx, 1        ; fd = stdout
  mov ecx, hello    ; buff = [hello]
  mov edx, hellolen ; len = hellolen
  mov eax, 4        ; sys_write
  int 0x80

  ; Exit normally
  mov ebx, 0   ; error_code = 0
  mov eax, 1   ; sys_exit
  int 0x80

%else
  ; TODO: maybe write a windows equivalent?
  %error "Unsupported OS or binary format!!"
%endif
