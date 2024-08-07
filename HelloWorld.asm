; This uses nasm, you will need to install nasm for this to work.
; Build and run with this command: 
;  Linux 32-bit: nasm -felf32 HelloWorld.asm && ld -m elf_i386 HelloWorld.o && ./a.out
;  Linux 64-bit: nasm -felf64 HelloWorld.asm && ld HelloWorld.o && ./a.out
;  Windows 32-bit: nasm -f win32 HelloWorld.asm -o HelloWorld.obj && link /subsystem:console /entry:start HelloWorld.obj kernel32.lib
;  Windows 64-bit: nasm -f win64 HelloWorld.asm -o HelloWorld.obj && link /subsystem:console /entry:start HelloWorld.obj kernel32.lib

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

%elifidn __OUTPUT_FORMAT__, win32

  ; Windows 32-bit hello world

  extern _GetStdHandle@4
  extern _WriteFile@20
  extern _ExitProcess@4

  section .data
  handle dd 0
  written dd 0

  section .text

  ; Get the handle to standard output
  push -11
  call _GetStdHandle@4
  mov [handle], eax

  ; Write the message to standard output
  push 0
  lea eax, [written]
  push eax
  push hellolen
  push hello
  push [handle]
  call _WriteFile@20

  ; Exit the process
  push 0
  call _ExitProcess@4

%elifidn __OUTPUT_FORMAT__, win64

  ; Windows 64-bit hello world

  extern GetStdHandle
  extern WriteFile
  extern ExitProcess

  section .data
  handle dq 0
  written dq 0

  section .text

  ; Get the handle to standard output
  sub rsp, 28h
  mov ecx, -11
  call GetStdHandle
  mov [handle], rax

  ; Write the message to standard output
  mov rcx, [handle]
  lea rdx, [hello]
  mov r8, hellolen
  lea r9, [written]
  call WriteFile

  ; Exit the process
  xor ecx, ecx
  call ExitProcess

%else
  %error "Unsupported OS or binary format!!"
%endif
