
OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")

OUTPUT_ARCH( "riscv" )
ENTRY( _start )
SECTIONS
{
  
  /* text: test code section */
  
  . = 0x00000200;
  
  .text : {  *(.text)  }
  
  
  /* data: Initialized data segment */
  
  . = 0x00030200;
  
  .data : { *(.data) }
  
  .sdata          :
  {
    __global_pointer$ = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2) *(.srodata .srodata.*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  }
  
  _edata = .; PROVIDE (edata = .);
  . = .;

  .tohost ALIGN(0x100) : { *(.tohost) }
  
  /* End of uninitalized data segement */
  _end = .;
  
}

