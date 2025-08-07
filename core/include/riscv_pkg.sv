/* Copyright 2018 ETH Zurich and University of Bologna.
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the “License”); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * File:   riscv_pkg.sv
 * Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>
 * Date:   30.6.2017
 *
 * Description: Common RISC-V definitions.
 */

 /*verilator tracing_off*/

package riscv;

  // ----------------------
  // Import cva6 config from cva6_config_pkg
  // ----------------------
  // FIXME stop using them from CoreV-Verif and HPDCache
  // Then remove them from this package
  localparam XLEN = cva6_config_pkg::CVA6ConfigXlen;
  localparam PLEN = (XLEN == 32) ? 34 : 56;

  // --------------------
  // Privilege Spec
  // --------------------
  typedef enum logic [1:0] {
    PRIV_LVL_M  = 2'b11,
    PRIV_LVL_HS = 2'b10,
    PRIV_LVL_S  = 2'b01,
    PRIV_LVL_U  = 2'b00
  } priv_lvl_t;

  // type which holds xlen
  typedef enum logic [1:0] {
    XLEN_32  = 2'b01,
    XLEN_64  = 2'b10,
    XLEN_128 = 2'b11
  } xlen_e;

  typedef enum logic [1:0] {
    Off     = 2'b00,
    Initial = 2'b01,
    Clean   = 2'b10,
    Dirty   = 2'b11
  } xs_t;

  typedef struct packed {
    logic sd;  // signal dirty state - read-only
    logic [62:34] wpri6;  // writes preserved reads ignored
    xlen_e uxl;  // variable user mode xlen - hardwired to zero
    logic [11:0] wpri5;  // writes preserved reads ignored
    logic mxr;  // make executable readable
    logic sum;  // permit supervisor user memory access
    logic wpri4;  // writes preserved reads ignored
    xs_t xs;  // extension register - hardwired to zero
    xs_t fs;  // floating point extension register
    logic [1:0] wpri3;  // writes preserved reads ignored
    xs_t vs;  // vector extension register
    logic spp;  // holds the previous privilege mode up to supervisor
    logic wpri2;  // writes preserved reads ignored
    logic mpie;  // machine interrupts enable bit active prior to trap
    logic         ube;    // UBE controls whether explicit load and store memory accesses made from U-mode are little-endian (UBE=0) or big-endian (UBE=1)
    logic spie;  // supervisor interrupts enable bit active prior to trap
    logic [2:0] wpri1;  // writes preserved reads ignored
    logic sie;  // supervisor interrupts enable
    logic wpri0;  // writes preserved reads ignored
  } sstatus_rv_t;

  typedef struct packed {
    logic [63:34] wpri4;  // writes preserved reads ignored
    xlen_e        vsxl;   // variable virtual supervisor mode xlen - hardwired to zero
    logic [8:0]   wpri3;  // floating point extension register
    logic         vtsr;   // virtual trap sret
    logic         vtw;    // virtual time wait
    logic         vtvm;   // virtual trap virtual memory
    logic [1:0]   wpri2;  // writes preserved reads ignored
    logic [5:0]   vgein;  // virtual guest external interrupt number
    logic [1:0]   wpri1;  // writes preserved reads ignored
    logic         hu;     // virtual-machine load/store instructions enable in U-mode
    logic         spvp;   // supervisor previous virtual privilege
    logic         spv;    // supervisor previous virtualization mode
    logic         gva;    // variable set when trap writes to stval
    logic         vsbe;   // endianness of explicit memory accesses made from VS-mode
    logic [4:0]   wpri0;  // writes preserved reads ignored
  } hstatus_rv_t;

  typedef struct packed {
    logic sd;  // signal dirty state - read-only
    logic [62:40] wpri4;  // writes preserved reads ignored
    logic mpv;  // machine previous virtualization mode
    logic gva;  // variable set when trap writes to stval
    logic mbe;  // endianness memory accesses made from M-mode
    logic sbe;  // endianness memory accesses made from S-mode
    xlen_e sxl;  // variable supervisor mode xlen - hardwired to zero
    xlen_e uxl;  // variable user mode xlen - hardwired to zero
    logic [8:0] wpri3;  // writes preserved reads ignored
    logic tsr;  // trap sret
    logic tw;  // time wait
    logic tvm;  // trap virtual memory
    logic mxr;  // make executable readable
    logic sum;  // permit supervisor user memory access
    logic mprv;  // modify privilege - privilege level for ld/st
    xs_t xs;  // extension register - hardwired to zero
    xs_t fs;  // floating point extension register
    priv_lvl_t mpp;  // holds the previous privilege mode up to machine
    xs_t vs;  // vector extension register
    logic spp;  // holds the previous privilege mode up to supervisor
    logic mpie;  // machine interrupts enable bit active prior to trap
    logic         ube;    // UBE controls whether explicit load and store memory accesses made from U-mode are little-endian (UBE=0) or big-endian (UBE=1)
    logic spie;  // supervisor interrupts enable bit active prior to trap
    logic wpri2;  // writes preserved reads ignored
    logic mie;  // machine interrupts enable
    logic wpri1;  // writes preserved reads ignored
    logic sie;  // supervisor interrupts enable
    logic wpri0;  // writes preserved reads ignored
  } mstatus_rv_t;

  typedef struct packed {
    logic        stce;   // not implemented - requires Sctc extension
    logic        pbmte;  // not implemented - requires Svpbmt extension
    logic [61:8] wpri1;  // writes preserved reads ignored
    logic        cbze;   // not implemented - requires Zicboz extension
    logic        cbcfe;  // not implemented - requires Zicbom extension
    logic [1:0]  cbie;   // not implemented - requires Zicbom extension
    logic [2:0]  wpri0;  // writes preserved reads ignored
    logic        fiom;   // fence of I/O implies memory
  } envcfg_rv_t;

  // --------------------
  // Instruction Types
  // --------------------
  typedef struct packed {
    logic [31:25] funct7;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] funct3;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } rtype_t;

  typedef struct packed {
    logic [31:27] rs3;
    logic [26:25] funct2;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] funct3;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } r4type_t;

  typedef struct packed {
    logic [31:27] funct5;
    logic [26:25] fmt;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] rm;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } rftype_t;  // floating-point

  typedef struct packed {
    logic [31:30] funct2;
    logic [29:25] vecfltop;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:14] repl;
    logic [13:12] vfmt;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } rvftype_t;  // vectorial floating-point

  typedef struct packed {
    logic [31:20] imm;
    logic [19:15] rs1;
    logic [14:12] funct3;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } itype_t;

  typedef struct packed {
    logic [31:25] imm;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] funct3;
    logic [11:7]  imm0;
    logic [6:0]   opcode;
  } stype_t;

  typedef struct packed {
    logic [31:12] imm;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } utype_t;

  // atomic instructions
  typedef struct packed {
    logic [31:27] funct5;
    logic         aq;
    logic         rl;
    logic [24:20] rs2;
    logic [19:15] rs1;
    logic [14:12] funct3;
    logic [11:7]  rd;
    logic [6:0]   opcode;
  } atype_t;

  typedef union packed {
    logic [31:0] instr;
    rtype_t      rtype;
    r4type_t     r4type;
    rftype_t     rftype;
    rvftype_t    rvftype;
    itype_t      itype;
    stype_t      stype;
    utype_t      utype;
    atype_t      atype;
  } instruction_t;

  // --------------------
  // Opcodes
  // --------------------
  // RV32/64G listings:
  // Quadrant 0
  localparam OpcodeLoad = 7'b00_000_11;
  localparam OpcodeLoadFp = 7'b00_001_11;
  localparam OpcodeCustom0 = 7'b00_010_11;
  localparam OpcodeMiscMem = 7'b00_011_11;
  localparam OpcodeOpImm = 7'b00_100_11;
  localparam OpcodeAuipc = 7'b00_101_11;
  localparam OpcodeOpImm32 = 7'b00_110_11;
  // Quadrant 1
  localparam OpcodeStore = 7'b01_000_11;
  localparam OpcodeStoreFp = 7'b01_001_11;
  localparam OpcodeCustom1 = 7'b01_010_11;
  localparam OpcodeAmo = 7'b01_011_11;
  localparam OpcodeOp = 7'b01_100_11;
  localparam OpcodeLui = 7'b01_101_11;
  localparam OpcodeOp32 = 7'b01_110_11;
  // Quadrant 2
  localparam OpcodeMadd = 7'b10_000_11;
  localparam OpcodeMsub = 7'b10_001_11;
  localparam OpcodeNmsub = 7'b10_010_11;
  localparam OpcodeNmadd = 7'b10_011_11;
  localparam OpcodeOpFp = 7'b10_100_11;
  localparam OpcodeVec = 7'b10_101_11;
  localparam OpcodeCustom2 = 7'b10_110_11;
  // Quadrant 3
  localparam OpcodeBranch = 7'b11_000_11;
  localparam OpcodeJalr = 7'b11_001_11;
  localparam OpcodeRsrvd2 = 7'b11_010_11;
  localparam OpcodeJal = 7'b11_011_11;
  localparam OpcodeSystem = 7'b11_100_11;
  localparam OpcodeRsrvd3 = 7'b11_101_11;
  localparam OpcodeCustom3 = 7'b11_110_11;

  // RV64C/RV32C listings:
  // Quadrant 0
  localparam OpcodeC0 = 2'b00;
  localparam OpcodeC0Addi4spn = 3'b000;
  localparam OpcodeC0Fld = 3'b001;
  localparam OpcodeC0Lw = 3'b010;
  localparam OpcodeC0Ld = 3'b011;
  localparam OpcodeC0Zcb = 3'b100;
  localparam OpcodeC0Fsd = 3'b101;
  localparam OpcodeC0Sw = 3'b110;
  localparam OpcodeC0Sd = 3'b111;
  // Quadrant 1
  localparam OpcodeC1 = 2'b01;
  localparam OpcodeC1Addi = 3'b000;
  localparam OpcodeC1Addiw = 3'b001;  //for RV64I only
  localparam OpcodeC1Jal = 3'b001;  //for RV32I only
  localparam OpcodeC1Li = 3'b010;
  localparam OpcodeC1LuiAddi16sp = 3'b011;
  localparam OpcodeC1MiscAlu = 3'b100;
  localparam OpcodeC1J = 3'b101;
  localparam OpcodeC1Beqz = 3'b110;
  localparam OpcodeC1Bnez = 3'b111;
  // Quadrant 2
  localparam OpcodeC2 = 2'b10;
  localparam OpcodeC2Slli = 3'b000;
  localparam OpcodeC2Fldsp = 3'b001;
  localparam OpcodeC2Lwsp = 3'b010;
  localparam OpcodeC2Ldsp = 3'b011;
  localparam OpcodeC2JalrMvAdd = 3'b100;
  localparam OpcodeC2Fsdsp = 3'b101;
  localparam OpcodeC2Swsp = 3'b110;
  localparam OpcodeC2Sdsp = 3'b111;

  // ----------------------
  // Virtual Memory
  // ----------------------
  // memory management, pte for sv39
  typedef struct packed {
    logic [9:0] reserved;
    logic [44-1:0] ppn;  // PPN length for
    logic [1:0] rsw;
    logic d;
    logic a;
    logic g;
    logic u;
    logic x;
    logic w;
    logic r;
    logic v;
  } pte_t;

  // memory management, pte for sv32
  typedef struct packed {
    logic [22-1:0] ppn;  // PPN length for
    logic [1:0] rsw;
    logic d;
    logic a;
    logic g;
    logic u;
    logic x;
    logic w;
    logic r;
    logic v;
  } pte_sv32_t;

  // ----------------------
  // Exception Cause Codes
  // ----------------------
  localparam logic [XLEN-1:0] INSTR_ADDR_MISALIGNED = 0;
  localparam logic [XLEN-1:0] INSTR_ACCESS_FAULT    = 1;  // Illegal access as governed by PMPs and PMAs
  localparam logic [XLEN-1:0] ILLEGAL_INSTR = 2;
  localparam logic [XLEN-1:0] BREAKPOINT = 3;
  localparam logic [XLEN-1:0] LD_ADDR_MISALIGNED = 4;
  localparam logic [XLEN-1:0] LD_ACCESS_FAULT = 5;  // Illegal access as governed by PMPs and PMAs
  localparam logic [XLEN-1:0] ST_ADDR_MISALIGNED = 6;
  localparam logic [XLEN-1:0] ST_ACCESS_FAULT = 7;  // Illegal access as governed by PMPs and PMAs
  localparam logic [XLEN-1:0] ENV_CALL_UMODE = 8;  // environment call from user mode or virtual user mode
  localparam logic [XLEN-1:0] ENV_CALL_SMODE = 9;  // environment call from hypervisor-extended supervisor mode
  localparam logic [XLEN-1:0] ENV_CALL_VSMODE = 10; // environment call from virtual supervisor mode
  localparam logic [XLEN-1:0] ENV_CALL_MMODE = 11;  // environment call from machine mode
  localparam logic [XLEN-1:0] INSTR_PAGE_FAULT = 12;  // Instruction page fault
  localparam logic [XLEN-1:0] LOAD_PAGE_FAULT = 13;  // Load page fault
  localparam logic [XLEN-1:0] STORE_PAGE_FAULT = 15;  // Store page fault
  localparam logic [XLEN-1:0] INSTR_GUEST_PAGE_FAULT = 20;  // Instruction guest-page fault
  localparam logic [XLEN-1:0] LOAD_GUEST_PAGE_FAULT = 21;  // Load guest-page fault
  localparam logic [XLEN-1:0] VIRTUAL_INSTRUCTION = 22;  // virtual instruction
  localparam logic [XLEN-1:0] STORE_GUEST_PAGE_FAULT = 23;  // Store guest-page fault
  localparam logic [XLEN-1:0] DEBUG_REQUEST = 24;  // Debug request

  localparam int unsigned IRQ_S_SOFT = 1;
  localparam int unsigned IRQ_VS_SOFT = 2;
  localparam int unsigned IRQ_M_SOFT = 3;
  localparam int unsigned IRQ_S_TIMER = 5;
  localparam int unsigned IRQ_VS_TIMER = 6;
  localparam int unsigned IRQ_M_TIMER = 7;
  localparam int unsigned IRQ_S_EXT = 9;
  localparam int unsigned IRQ_VS_EXT = 10;
  localparam int unsigned IRQ_M_EXT = 11;
  localparam int unsigned IRQ_HS_EXT = 12;

  localparam logic [31:0] MIP_SSIP = 1 << IRQ_S_SOFT;
  localparam logic [31:0] MIP_VSSIP = 1 << IRQ_VS_SOFT;
  localparam logic [31:0] MIP_MSIP = 1 << IRQ_M_SOFT;
  localparam logic [31:0] MIP_STIP = 1 << IRQ_S_TIMER;
  localparam logic [31:0] MIP_VSTIP = 1 << IRQ_VS_TIMER;
  localparam logic [31:0] MIP_MTIP = 1 << IRQ_M_TIMER;
  localparam logic [31:0] MIP_SEIP = 1 << IRQ_S_EXT;
  localparam logic [31:0] MIP_VSEIP = 1 << IRQ_VS_EXT;
  localparam logic [31:0] MIP_MEIP = 1 << IRQ_M_EXT;
  localparam logic [31:0] MIP_SGEIP = 1 << IRQ_HS_EXT;

  // ----------------------
  // PseudoInstructions Codes
  // ----------------------
  localparam logic [31:0] READ_32_PSEUDOINSTRUCTION = 32'h00002000;
  localparam logic [31:0] WRITE_32_PSEUDOINSTRUCTION = 32'h00002020;
  localparam logic [31:0] READ_64_PSEUDOINSTRUCTION = 32'h00003000;
  localparam logic [31:0] WRITE_64_PSEUDOINSTRUCTION = 32'h00003020;

  // -----
  // CSRs
  // -----
  typedef enum logic [11:0] {
    // Floating-Point CSRs
    CSR_FFLAGS           = 12'h001,
    CSR_FRM              = 12'h002,
    CSR_FCSR             = 12'h003,
    CSR_FTRAN            = 12'h800,
    // Vector CSRs
    CSR_VSTART           = 12'h008,
    CSR_VXSAT            = 12'h009,
    CSR_VXRM             = 12'h00A,
    CSR_VCSR             = 12'h00F,
    CSR_VL               = 12'hC20,
    CSR_VTYPE            = 12'hC21,
    CSR_VLENB            = 12'hC22,
    // Virtual Supervisor Mode CSRs
    CSR_VSSTATUS         = 12'h200,
    CSR_VSIE             = 12'h204,
    CSR_VSTVEC           = 12'h205,
    CSR_VSSCRATCH        = 12'h240,
    CSR_VSEPC            = 12'h241,
    CSR_VSCAUSE          = 12'h242,
    CSR_VSTVAL           = 12'h243,
    CSR_VSIP             = 12'h244,
    CSR_VSISELECT        = 12'h250,
    CSR_VSIREG           = 12'h251,
    CSR_VSIREG2          = 12'h252,
    CSR_VSIREG3          = 12'h253,
    CSR_VSIREG4          = 12'h255,
    CSR_VSIREG5          = 12'h256,
    CSR_VSIREG6          = 12'h257,
    CSR_VSATP            = 12'h280,
    CSR_VSPMPSWITCH0     = 12'hA50,
    CSR_VSPMPSWITCH1     = 12'hA51,
    // Supervisor Mode CSRs
    CSR_SSTATUS          = 12'h100,
    CSR_SIE              = 12'h104,
    CSR_STVEC            = 12'h105,
    CSR_SCOUNTEREN       = 12'h106,
    CSR_SENVCFG          = 12'h10A,
    CSR_SSCRATCH         = 12'h140,
    CSR_SEPC             = 12'h141,
    CSR_SCAUSE           = 12'h142,
    CSR_STVAL            = 12'h143,
    CSR_SIP              = 12'h144,
    CSR_SISELECT         = 12'h150,
    CSR_SIREG            = 12'h151,
    CSR_SIREG2           = 12'h152,
    CSR_SIREG3           = 12'h153,
    CSR_SIREG4           = 12'h155,
    CSR_SIREG5           = 12'h156,
    CSR_SIREG6           = 12'h157,
    CSR_SATP             = 12'h180,
    CSR_SPMPDELEG        = 12'h1F0,
    CSR_SPMPSWITCH       = 12'h550,
    CSR_SPMPSWITCHH      = 12'h551,
    // Hypervisor-extended Supervisor Mode CSRs
    CSR_HSTATUS          = 12'h600,
    CSR_HEDELEG          = 12'h602,
    CSR_HIDELEG          = 12'h603,
    CSR_HIE              = 12'h604,
    CSR_HCOUNTEREN       = 12'h606,
    CSR_HGEIE            = 12'h607,
    CSR_HTVAL            = 12'h643,
    CSR_HIP              = 12'h644,
    CSR_HVIP             = 12'h645,
    CSR_HTINST           = 12'h64A,
    CSR_HGEIP            = 12'hE12,
    CSR_HENVCFG          = 12'h60A,
    CSR_HENVCFGH         = 12'h61A,
    CSR_HGATP            = 12'h680,
    CSR_HSPMPSWITCH0     = 12'h682,
    CSR_HSPMPSWITCH1     = 12'h683,
    CSR_HCONTEXT         = 12'h6A8,
    CSR_HTIMEDELTA       = 12'h605,
    CSR_HTIMEDELTAH      = 12'h615,
    // Machine Mode CSRs
    CSR_MSTATUS          = 12'h300,
    CSR_MISA             = 12'h301,
    CSR_MEDELEG          = 12'h302,
    CSR_MIDELEG          = 12'h303,
    CSR_MIE              = 12'h304,
    CSR_MTVEC            = 12'h305,
    CSR_MCOUNTEREN       = 12'h306,
    CSR_MSTATUSH         = 12'h310,
    CSR_MCOUNTINHIBIT    = 12'h320,
    CSR_MHPM_EVENT_3     = 12'h323,  //Machine performance monitoring Event Selector
    CSR_MHPM_EVENT_4     = 12'h324,  //Machine performance monitoring Event Selector
    CSR_MHPM_EVENT_5     = 12'h325,  //Machine performance monitoring Event Selector
    CSR_MHPM_EVENT_6     = 12'h326,  //Machine performance monitoring Event Selector
    CSR_MHPM_EVENT_7     = 12'h327,  //Machine performance monitoring Event Selector
    CSR_MHPM_EVENT_8     = 12'h328,  //Machine performance monitoring Event Selector
    CSR_MHPM_EVENT_9     = 12'h329,  //Reserved
    CSR_MHPM_EVENT_10    = 12'h32A,  //Reserved
    CSR_MHPM_EVENT_11    = 12'h32B,  //Reserved
    CSR_MHPM_EVENT_12    = 12'h32C,  //Reserved
    CSR_MHPM_EVENT_13    = 12'h32D,  //Reserved
    CSR_MHPM_EVENT_14    = 12'h32E,  //Reserved
    CSR_MHPM_EVENT_15    = 12'h32F,  //Reserved
    CSR_MHPM_EVENT_16    = 12'h330,  //Reserved
    CSR_MHPM_EVENT_17    = 12'h331,  //Reserved
    CSR_MHPM_EVENT_18    = 12'h332,  //Reserved
    CSR_MHPM_EVENT_19    = 12'h333,  //Reserved
    CSR_MHPM_EVENT_20    = 12'h334,  //Reserved
    CSR_MHPM_EVENT_21    = 12'h335,  //Reserved
    CSR_MHPM_EVENT_22    = 12'h336,  //Reserved
    CSR_MHPM_EVENT_23    = 12'h337,  //Reserved
    CSR_MHPM_EVENT_24    = 12'h338,  //Reserved
    CSR_MHPM_EVENT_25    = 12'h339,  //Reserved
    CSR_MHPM_EVENT_26    = 12'h33A,  //Reserved
    CSR_MHPM_EVENT_27    = 12'h33B,  //Reserved
    CSR_MHPM_EVENT_28    = 12'h33C,  //Reserved
    CSR_MHPM_EVENT_29    = 12'h33D,  //Reserved
    CSR_MHPM_EVENT_30    = 12'h33E,  //Reserved
    CSR_MHPM_EVENT_31    = 12'h33F,  //Reserved
    CSR_MSCRATCH         = 12'h340,
    CSR_MEPC             = 12'h341,
    CSR_MCAUSE           = 12'h342,
    CSR_MTVAL            = 12'h343,
    CSR_MIP              = 12'h344,
    CSR_MTINST           = 12'h34A,
    CSR_MTVAL2           = 12'h34B,
    CSR_MENVCFG          = 12'h30A,
    CSR_MENVCFGH         = 12'h31A,
    CSR_MISELECT         = 12'h350,
    CSR_MIREG            = 12'h351,
    CSR_MIREG2           = 12'h352,
    CSR_MIREG3           = 12'h353,
    CSR_MIREG4           = 12'h355,
    CSR_MIREG5           = 12'h356,
    CSR_MIREG6           = 12'h357,
    CSR_PMPCFG0          = 12'h3A0,
    CSR_PMPCFG1          = 12'h3A1,
    CSR_PMPCFG2          = 12'h3A2,
    CSR_PMPCFG3          = 12'h3A3,
    CSR_PMPCFG4          = 12'h3A4,
    CSR_PMPCFG5          = 12'h3A5,
    CSR_PMPCFG6          = 12'h3A6,
    CSR_PMPCFG7          = 12'h3A7,
    CSR_PMPCFG8          = 12'h3A8,
    CSR_PMPCFG9          = 12'h3A9,
    CSR_PMPCFG10         = 12'h3AA,
    CSR_PMPCFG11         = 12'h3AB,
    CSR_PMPCFG12         = 12'h3AC,
    CSR_PMPCFG13         = 12'h3AD,
    CSR_PMPCFG14         = 12'h3AE,
    CSR_PMPCFG15         = 12'h3AF,
    CSR_PMPADDR0         = 12'h3B0,
    CSR_PMPADDR1         = 12'h3B1,
    CSR_PMPADDR2         = 12'h3B2,
    CSR_PMPADDR3         = 12'h3B3,
    CSR_PMPADDR4         = 12'h3B4,
    CSR_PMPADDR5         = 12'h3B5,
    CSR_PMPADDR6         = 12'h3B6,
    CSR_PMPADDR7         = 12'h3B7,
    CSR_PMPADDR8         = 12'h3B8,
    CSR_PMPADDR9         = 12'h3B9,
    CSR_PMPADDR10        = 12'h3BA,
    CSR_PMPADDR11        = 12'h3BB,
    CSR_PMPADDR12        = 12'h3BC,
    CSR_PMPADDR13        = 12'h3BD,
    CSR_PMPADDR14        = 12'h3BE,
    CSR_PMPADDR15        = 12'h3BF,
    CSR_PMPADDR16        = 12'h3C0,
    CSR_PMPADDR17        = 12'h3C1,
    CSR_PMPADDR18        = 12'h3C2,
    CSR_PMPADDR19        = 12'h3C3,
    CSR_PMPADDR20        = 12'h3C4,
    CSR_PMPADDR21        = 12'h3C5,
    CSR_PMPADDR22        = 12'h3C6,
    CSR_PMPADDR23        = 12'h3C7,
    CSR_PMPADDR24        = 12'h3C8,
    CSR_PMPADDR25        = 12'h3C9,
    CSR_PMPADDR26        = 12'h3CA,
    CSR_PMPADDR27        = 12'h3CB,
    CSR_PMPADDR28        = 12'h3CC,
    CSR_PMPADDR29        = 12'h3CD,
    CSR_PMPADDR30        = 12'h3CE,
    CSR_PMPADDR31        = 12'h3CF,
    CSR_PMPADDR32        = 12'h3D0,
    CSR_PMPADDR33        = 12'h3D1,
    CSR_PMPADDR34        = 12'h3D2,
    CSR_PMPADDR35        = 12'h3D3,
    CSR_PMPADDR36        = 12'h3D4,
    CSR_PMPADDR37        = 12'h3D5,
    CSR_PMPADDR38        = 12'h3D6,
    CSR_PMPADDR39        = 12'h3D7,
    CSR_PMPADDR40        = 12'h3D8,
    CSR_PMPADDR41        = 12'h3D9,
    CSR_PMPADDR42        = 12'h3DA,
    CSR_PMPADDR43        = 12'h3DB,
    CSR_PMPADDR44        = 12'h3DC,
    CSR_PMPADDR45        = 12'h3DD,
    CSR_PMPADDR46        = 12'h3DE,
    CSR_PMPADDR47        = 12'h3DF,
    CSR_PMPADDR48        = 12'h3E0,
    CSR_PMPADDR49        = 12'h3E1,
    CSR_PMPADDR50        = 12'h3E2,
    CSR_PMPADDR51        = 12'h3E3,
    CSR_PMPADDR52        = 12'h3E4,
    CSR_PMPADDR53        = 12'h3E5,
    CSR_PMPADDR54        = 12'h3E6,
    CSR_PMPADDR55        = 12'h3E7,
    CSR_PMPADDR56        = 12'h3E8,
    CSR_PMPADDR57        = 12'h3E9,
    CSR_PMPADDR58        = 12'h3EA,
    CSR_PMPADDR59        = 12'h3EB,
    CSR_PMPADDR60        = 12'h3EC,
    CSR_PMPADDR61        = 12'h3ED,
    CSR_PMPADDR62        = 12'h3EE,
    CSR_PMPADDR63        = 12'h3EF,
    CSR_MPMPDELEG        = 12'h3F0,
    CSR_MVENDORID        = 12'hF11,
    CSR_MARCHID          = 12'hF12,
    CSR_MIMPID           = 12'hF13,
    CSR_MHARTID          = 12'hF14,
    CSR_MCONFIGPTR       = 12'hF15,
    CSR_MCYCLE           = 12'hB00,
    CSR_MCYCLEH          = 12'hB80,
    CSR_MINSTRET         = 12'hB02,
    CSR_MINSTRETH        = 12'hB82,
    //Performance Counters
    CSR_MHPM_COUNTER_3   = 12'hB03,
    CSR_MHPM_COUNTER_4   = 12'hB04,
    CSR_MHPM_COUNTER_5   = 12'hB05,
    CSR_MHPM_COUNTER_6   = 12'hB06,
    CSR_MHPM_COUNTER_7   = 12'hB07,
    CSR_MHPM_COUNTER_8   = 12'hB08,
    CSR_MHPM_COUNTER_9   = 12'hB09,  // reserved
    CSR_MHPM_COUNTER_10  = 12'hB0A,  // reserved
    CSR_MHPM_COUNTER_11  = 12'hB0B,  // reserved
    CSR_MHPM_COUNTER_12  = 12'hB0C,  // reserved
    CSR_MHPM_COUNTER_13  = 12'hB0D,  // reserved
    CSR_MHPM_COUNTER_14  = 12'hB0E,  // reserved
    CSR_MHPM_COUNTER_15  = 12'hB0F,  // reserved
    CSR_MHPM_COUNTER_16  = 12'hB10,  // reserved
    CSR_MHPM_COUNTER_17  = 12'hB11,  // reserved
    CSR_MHPM_COUNTER_18  = 12'hB12,  // reserved
    CSR_MHPM_COUNTER_19  = 12'hB13,  // reserved
    CSR_MHPM_COUNTER_20  = 12'hB14,  // reserved
    CSR_MHPM_COUNTER_21  = 12'hB15,  // reserved
    CSR_MHPM_COUNTER_22  = 12'hB16,  // reserved
    CSR_MHPM_COUNTER_23  = 12'hB17,  // reserved
    CSR_MHPM_COUNTER_24  = 12'hB18,  // reserved
    CSR_MHPM_COUNTER_25  = 12'hB19,  // reserved
    CSR_MHPM_COUNTER_26  = 12'hB1A,  // reserved
    CSR_MHPM_COUNTER_27  = 12'hB1B,  // reserved
    CSR_MHPM_COUNTER_28  = 12'hB1C,  // reserved
    CSR_MHPM_COUNTER_29  = 12'hB1D,  // reserved
    CSR_MHPM_COUNTER_30  = 12'hB1E,  // reserved
    CSR_MHPM_COUNTER_31  = 12'hB1F,  // reserved
    CSR_MHPM_COUNTER_3H  = 12'hB83,
    CSR_MHPM_COUNTER_4H  = 12'hB84,
    CSR_MHPM_COUNTER_5H  = 12'hB85,
    CSR_MHPM_COUNTER_6H  = 12'hB86,
    CSR_MHPM_COUNTER_7H  = 12'hB87,
    CSR_MHPM_COUNTER_8H  = 12'hB88,
    CSR_MHPM_COUNTER_9H  = 12'hB89,  // reserved
    CSR_MHPM_COUNTER_10H = 12'hB8A,  // reserved
    CSR_MHPM_COUNTER_11H = 12'hB8B,  // reserved
    CSR_MHPM_COUNTER_12H = 12'hB8C,  // reserved
    CSR_MHPM_COUNTER_13H = 12'hB8D,  // reserved
    CSR_MHPM_COUNTER_14H = 12'hB8E,  // reserved
    CSR_MHPM_COUNTER_15H = 12'hB8F,  // reserved
    CSR_MHPM_COUNTER_16H = 12'hB90,  // reserved
    CSR_MHPM_COUNTER_17H = 12'hB91,  // reserved
    CSR_MHPM_COUNTER_18H = 12'hB92,  // reserved
    CSR_MHPM_COUNTER_19H = 12'hB93,  // reserved
    CSR_MHPM_COUNTER_20H = 12'hB94,  // reserved
    CSR_MHPM_COUNTER_21H = 12'hB95,  // reserved
    CSR_MHPM_COUNTER_22H = 12'hB96,  // reserved
    CSR_MHPM_COUNTER_23H = 12'hB97,  // reserved
    CSR_MHPM_COUNTER_24H = 12'hB98,  // reserved
    CSR_MHPM_COUNTER_25H = 12'hB99,  // reserved
    CSR_MHPM_COUNTER_26H = 12'hB9A,  // reserved
    CSR_MHPM_COUNTER_27H = 12'hB9B,  // reserved
    CSR_MHPM_COUNTER_28H = 12'hB9C,  // reserved
    CSR_MHPM_COUNTER_29H = 12'hB9D,  // reserved
    CSR_MHPM_COUNTER_30H = 12'hB9E,  // reserved
    CSR_MHPM_COUNTER_31H = 12'hB9F,  // reserved
    // Cache Control (platform specifc)
    CSR_DCACHE           = 12'h7C1,
    CSR_ICACHE           = 12'h7C0,
    // Accelerator memory consistency (platform specific)
    CSR_ACC_CONS         = 12'h7C2,
    // Triggers
    CSR_TSELECT          = 12'h7A0,
    CSR_TDATA1           = 12'h7A1,
    CSR_TDATA2           = 12'h7A2,
    CSR_TDATA3           = 12'h7A3,
    CSR_TINFO            = 12'h7A4,
    // Debug CSR
    CSR_DCSR             = 12'h7b0,
    CSR_DPC              = 12'h7b1,
    CSR_DSCRATCH0        = 12'h7b2,  // optional
    CSR_DSCRATCH1        = 12'h7b3,  // optional
    // Counters and Timers from Zicntr extension (User Mode - R/O Shadows)
    CSR_CYCLE            = 12'hC00,
    CSR_CYCLEH           = 12'hC80,
    CSR_TIME             = 12'hC01,
    CSR_TIMEH            = 12'hC81,
    CSR_INSTRET          = 12'hC02,
    CSR_INSTRETH         = 12'hC82,
    // Performance counters from Zihpm extension (User Mode - R/O Shadows)
    CSR_HPM_COUNTER_3    = 12'hC03,
    CSR_HPM_COUNTER_4    = 12'hC04,
    CSR_HPM_COUNTER_5    = 12'hC05,
    CSR_HPM_COUNTER_6    = 12'hC06,
    CSR_HPM_COUNTER_7    = 12'hC07,
    CSR_HPM_COUNTER_8    = 12'hC08,
    CSR_HPM_COUNTER_9    = 12'hC09,  // reserved
    CSR_HPM_COUNTER_10   = 12'hC0A,  // reserved
    CSR_HPM_COUNTER_11   = 12'hC0B,  // reserved
    CSR_HPM_COUNTER_12   = 12'hC0C,  // reserved
    CSR_HPM_COUNTER_13   = 12'hC0D,  // reserved
    CSR_HPM_COUNTER_14   = 12'hC0E,  // reserved
    CSR_HPM_COUNTER_15   = 12'hC0F,  // reserved
    CSR_HPM_COUNTER_16   = 12'hC10,  // reserved
    CSR_HPM_COUNTER_17   = 12'hC11,  // reserved
    CSR_HPM_COUNTER_18   = 12'hC12,  // reserved
    CSR_HPM_COUNTER_19   = 12'hC13,  // reserved
    CSR_HPM_COUNTER_20   = 12'hC14,  // reserved
    CSR_HPM_COUNTER_21   = 12'hC15,  // reserved
    CSR_HPM_COUNTER_22   = 12'hC16,  // reserved
    CSR_HPM_COUNTER_23   = 12'hC17,  // reserved
    CSR_HPM_COUNTER_24   = 12'hC18,  // reserved
    CSR_HPM_COUNTER_25   = 12'hC19,  // reserved
    CSR_HPM_COUNTER_26   = 12'hC1A,  // reserved
    CSR_HPM_COUNTER_27   = 12'hC1B,  // reserved
    CSR_HPM_COUNTER_28   = 12'hC1C,  // reserved
    CSR_HPM_COUNTER_29   = 12'hC1D,  // reserved
    CSR_HPM_COUNTER_30   = 12'hC1E,  // reserved
    CSR_HPM_COUNTER_31   = 12'hC1F,  // reserved
    CSR_HPM_COUNTER_3H   = 12'hC83,
    CSR_HPM_COUNTER_4H   = 12'hC84,
    CSR_HPM_COUNTER_5H   = 12'hC85,
    CSR_HPM_COUNTER_6H   = 12'hC86,
    CSR_HPM_COUNTER_7H   = 12'hC87,
    CSR_HPM_COUNTER_8H   = 12'hC88,
    CSR_HPM_COUNTER_9H   = 12'hC89,  // reserved
    CSR_HPM_COUNTER_10H  = 12'hC8A,  // reserved
    CSR_HPM_COUNTER_11H  = 12'hC8B,  // reserved
    CSR_HPM_COUNTER_12H  = 12'hC8C,  // reserved
    CSR_HPM_COUNTER_13H  = 12'hC8D,  // reserved
    CSR_HPM_COUNTER_14H  = 12'hC8E,  // reserved
    CSR_HPM_COUNTER_15H  = 12'hC8F,  // reserved
    CSR_HPM_COUNTER_16H  = 12'hC90,  // reserved
    CSR_HPM_COUNTER_17H  = 12'hC91,  // reserved
    CSR_HPM_COUNTER_18H  = 12'hC92,  // reserved
    CSR_HPM_COUNTER_19H  = 12'hC93,  // reserved
    CSR_HPM_COUNTER_20H  = 12'hC94,  // reserved
    CSR_HPM_COUNTER_21H  = 12'hC95,  // reserved
    CSR_HPM_COUNTER_22H  = 12'hC96,  // reserved
    CSR_HPM_COUNTER_23H  = 12'hC97,  // reserved
    CSR_HPM_COUNTER_24H  = 12'hC98,  // reserved
    CSR_HPM_COUNTER_25H  = 12'hC99,  // reserved
    CSR_HPM_COUNTER_26H  = 12'hC9A,  // reserved
    CSR_HPM_COUNTER_27H  = 12'hC9B,  // reserved
    CSR_HPM_COUNTER_28H  = 12'hC9C,  // reserved
    CSR_HPM_COUNTER_29H  = 12'hC9D,  // reserved
    CSR_HPM_COUNTER_30H  = 12'hC9E,  // reserved
    CSR_HPM_COUNTER_31H  = 12'hC9F   // reserved
  } csr_reg_t;

  // CSRs accessible only via Sxcsrind
  typedef enum logic [12:0] {
    // SPMP Config
    CSR_SPMPCFG0         = 13'h1000,
    CSR_SPMPCFG1         = 13'h1001,
    CSR_SPMPCFG2         = 13'h1002,
    CSR_SPMPCFG3         = 13'h1003,
    CSR_SPMPCFG4         = 13'h1004,
    CSR_SPMPCFG5         = 13'h1005,
    CSR_SPMPCFG6         = 13'h1006,
    CSR_SPMPCFG7         = 13'h1007,
    CSR_SPMPCFG8         = 13'h1008,
    CSR_SPMPCFG9         = 13'h1009,
    CSR_SPMPCFG10        = 13'h100A,
    CSR_SPMPCFG11        = 13'h100B,
    CSR_SPMPCFG12        = 13'h100C,
    CSR_SPMPCFG13        = 13'h100D,
    CSR_SPMPCFG14        = 13'h100E,
    CSR_SPMPCFG15        = 13'h100F,
    CSR_SPMPCFG16        = 13'h1010,
    CSR_SPMPCFG17        = 13'h1011,
    CSR_SPMPCFG18        = 13'h1012,
    CSR_SPMPCFG19        = 13'h1013,
    CSR_SPMPCFG20        = 13'h1014,
    CSR_SPMPCFG21        = 13'h1015,
    CSR_SPMPCFG22        = 13'h1016,
    CSR_SPMPCFG23        = 13'h1017,
    CSR_SPMPCFG24        = 13'h1018,
    CSR_SPMPCFG25        = 13'h1019,
    CSR_SPMPCFG26        = 13'h101A,
    CSR_SPMPCFG27        = 13'h101B,
    CSR_SPMPCFG28        = 13'h101C,
    CSR_SPMPCFG29        = 13'h101D,
    CSR_SPMPCFG30        = 13'h101E,
    CSR_SPMPCFG31        = 13'h101F,
    CSR_SPMPCFG32        = 13'h1020,
    CSR_SPMPCFG33        = 13'h1021,
    CSR_SPMPCFG34        = 13'h1022,
    CSR_SPMPCFG35        = 13'h1023,
    CSR_SPMPCFG36        = 13'h1024,
    CSR_SPMPCFG37        = 13'h1025,
    CSR_SPMPCFG38        = 13'h1026,
    CSR_SPMPCFG39        = 13'h1027,
    CSR_SPMPCFG40        = 13'h1028,
    CSR_SPMPCFG41        = 13'h1029,
    CSR_SPMPCFG42        = 13'h102A,
    CSR_SPMPCFG43        = 13'h102B,
    CSR_SPMPCFG44        = 13'h102C,
    CSR_SPMPCFG45        = 13'h102D,
    CSR_SPMPCFG46        = 13'h102E,
    CSR_SPMPCFG47        = 13'h102F,
    CSR_SPMPCFG48        = 13'h1030,
    CSR_SPMPCFG49        = 13'h1031,
    CSR_SPMPCFG50        = 13'h1032,
    CSR_SPMPCFG51        = 13'h1033,
    CSR_SPMPCFG52        = 13'h1034,
    CSR_SPMPCFG53        = 13'h1035,
    CSR_SPMPCFG54        = 13'h1036,
    CSR_SPMPCFG55        = 13'h1037,
    CSR_SPMPCFG56        = 13'h1038,
    CSR_SPMPCFG57        = 13'h1039,
    CSR_SPMPCFG58        = 13'h103A,
    CSR_SPMPCFG59        = 13'h103B,
    CSR_SPMPCFG60        = 13'h103C,
    CSR_SPMPCFG61        = 13'h103D,
    CSR_SPMPCFG62        = 13'h103E,
    CSR_SPMPCFG63        = 13'h103F,
    // SPMP Addr
    CSR_SPMPADDR0        = 13'h1040,
    CSR_SPMPADDR1        = 13'h1041,
    CSR_SPMPADDR2        = 13'h1042,
    CSR_SPMPADDR3        = 13'h1043,
    CSR_SPMPADDR4        = 13'h1044,
    CSR_SPMPADDR5        = 13'h1045,
    CSR_SPMPADDR6        = 13'h1046,
    CSR_SPMPADDR7        = 13'h1047,
    CSR_SPMPADDR8        = 13'h1048,
    CSR_SPMPADDR9        = 13'h1049,
    CSR_SPMPADDR10       = 13'h104A,
    CSR_SPMPADDR11       = 13'h104B,
    CSR_SPMPADDR12       = 13'h104C,
    CSR_SPMPADDR13       = 13'h104D,
    CSR_SPMPADDR14       = 13'h104E,
    CSR_SPMPADDR15       = 13'h104F,
    CSR_SPMPADDR16       = 13'h1050,
    CSR_SPMPADDR17       = 13'h1051,
    CSR_SPMPADDR18       = 13'h1052,
    CSR_SPMPADDR19       = 13'h1053,
    CSR_SPMPADDR20       = 13'h1054,
    CSR_SPMPADDR21       = 13'h1055,
    CSR_SPMPADDR22       = 13'h1056,
    CSR_SPMPADDR23       = 13'h1057,
    CSR_SPMPADDR24       = 13'h1058,
    CSR_SPMPADDR25       = 13'h1059,
    CSR_SPMPADDR26       = 13'h105A,
    CSR_SPMPADDR27       = 13'h105B,
    CSR_SPMPADDR28       = 13'h105C,
    CSR_SPMPADDR29       = 13'h105D,
    CSR_SPMPADDR30       = 13'h105E,
    CSR_SPMPADDR31       = 13'h105F,
    CSR_SPMPADDR32       = 13'h1060,
    CSR_SPMPADDR33       = 13'h1061,
    CSR_SPMPADDR34       = 13'h1062,
    CSR_SPMPADDR35       = 13'h1063,
    CSR_SPMPADDR36       = 13'h1064,
    CSR_SPMPADDR37       = 13'h1065,
    CSR_SPMPADDR38       = 13'h1066,
    CSR_SPMPADDR39       = 13'h1067,
    CSR_SPMPADDR40       = 13'h1068,
    CSR_SPMPADDR41       = 13'h1069,
    CSR_SPMPADDR42       = 13'h106A,
    CSR_SPMPADDR43       = 13'h106B,
    CSR_SPMPADDR44       = 13'h106C,
    CSR_SPMPADDR45       = 13'h106D,
    CSR_SPMPADDR46       = 13'h106E,
    CSR_SPMPADDR47       = 13'h106F,
    CSR_SPMPADDR48       = 13'h1070,
    CSR_SPMPADDR49       = 13'h1071,
    CSR_SPMPADDR50       = 13'h1072,
    CSR_SPMPADDR51       = 13'h1073,
    CSR_SPMPADDR52       = 13'h1074,
    CSR_SPMPADDR53       = 13'h1075,
    CSR_SPMPADDR54       = 13'h1076,
    CSR_SPMPADDR55       = 13'h1077,
    CSR_SPMPADDR56       = 13'h1078,
    CSR_SPMPADDR57       = 13'h1079,
    CSR_SPMPADDR58       = 13'h107A,
    CSR_SPMPADDR59       = 13'h107B,
    CSR_SPMPADDR60       = 13'h107C,
    CSR_SPMPADDR61       = 13'h107D,
    CSR_SPMPADDR62       = 13'h107E,
    CSR_SPMPADDR63       = 13'h107F,
    // vSPMP Config
    CSR_VSPMPCFG0        = 13'h1080,
    CSR_VSPMPCFG1        = 13'h1081,
    CSR_VSPMPCFG2        = 13'h1082,
    CSR_VSPMPCFG3        = 13'h1083,
    CSR_VSPMPCFG4        = 13'h1084,
    CSR_VSPMPCFG5        = 13'h1085,
    CSR_VSPMPCFG6        = 13'h1086,
    CSR_VSPMPCFG7        = 13'h1087,
    CSR_VSPMPCFG8        = 13'h1088,
    CSR_VSPMPCFG9        = 13'h1089,
    CSR_VSPMPCFG10       = 13'h108A,
    CSR_VSPMPCFG11       = 13'h108B,
    CSR_VSPMPCFG12       = 13'h108C,
    CSR_VSPMPCFG13       = 13'h108D,
    CSR_VSPMPCFG14       = 13'h108E,
    CSR_VSPMPCFG15       = 13'h108F,
    CSR_VSPMPCFG16       = 13'h1090,
    CSR_VSPMPCFG17       = 13'h1091,
    CSR_VSPMPCFG18       = 13'h1092,
    CSR_VSPMPCFG19       = 13'h1093,
    CSR_VSPMPCFG20       = 13'h1094,
    CSR_VSPMPCFG21       = 13'h1095,
    CSR_VSPMPCFG22       = 13'h1096,
    CSR_VSPMPCFG23       = 13'h1097,
    CSR_VSPMPCFG24       = 13'h1098,
    CSR_VSPMPCFG25       = 13'h1099,
    CSR_VSPMPCFG26       = 13'h109A,
    CSR_VSPMPCFG27       = 13'h109B,
    CSR_VSPMPCFG28       = 13'h109C,
    CSR_VSPMPCFG29       = 13'h109D,
    CSR_VSPMPCFG30       = 13'h109E,
    CSR_VSPMPCFG31       = 13'h109F,
    CSR_VSPMPCFG32       = 13'h10A0,
    CSR_VSPMPCFG33       = 13'h10A1,
    CSR_VSPMPCFG34       = 13'h10A2,
    CSR_VSPMPCFG35       = 13'h10A3,
    CSR_VSPMPCFG36       = 13'h10A4,
    CSR_VSPMPCFG37       = 13'h10A5,
    CSR_VSPMPCFG38       = 13'h10A6,
    CSR_VSPMPCFG39       = 13'h10A7,
    CSR_VSPMPCFG40       = 13'h10A8,
    CSR_VSPMPCFG41       = 13'h10A9,
    CSR_VSPMPCFG42       = 13'h10AA,
    CSR_VSPMPCFG43       = 13'h10AB,
    CSR_VSPMPCFG44       = 13'h10AC,
    CSR_VSPMPCFG45       = 13'h10AD,
    CSR_VSPMPCFG46       = 13'h10AE,
    CSR_VSPMPCFG47       = 13'h10AF,
    CSR_VSPMPCFG48       = 13'h10B0,
    CSR_VSPMPCFG49       = 13'h10B1,
    CSR_VSPMPCFG50       = 13'h10B2,
    CSR_VSPMPCFG51       = 13'h10B3,
    CSR_VSPMPCFG52       = 13'h10B4,
    CSR_VSPMPCFG53       = 13'h10B5,
    CSR_VSPMPCFG54       = 13'h10B6,
    CSR_VSPMPCFG55       = 13'h10B7,
    CSR_VSPMPCFG56       = 13'h10B8,
    CSR_VSPMPCFG57       = 13'h10B9,
    CSR_VSPMPCFG58       = 13'h10BA,
    CSR_VSPMPCFG59       = 13'h10BB,
    CSR_VSPMPCFG60       = 13'h10BC,
    CSR_VSPMPCFG61       = 13'h10BD,
    CSR_VSPMPCFG62       = 13'h10BE,
    CSR_VSPMPCFG63       = 13'h10BF,
    // vSPMP Addr
    CSR_VSPMPADDR0       = 13'h10C0,
    CSR_VSPMPADDR1       = 13'h10C1,
    CSR_VSPMPADDR2       = 13'h10C2,
    CSR_VSPMPADDR3       = 13'h10C3,
    CSR_VSPMPADDR4       = 13'h10C4,
    CSR_VSPMPADDR5       = 13'h10C5,
    CSR_VSPMPADDR6       = 13'h10C6,
    CSR_VSPMPADDR7       = 13'h10C7,
    CSR_VSPMPADDR8       = 13'h10C8,
    CSR_VSPMPADDR9       = 13'h10C9,
    CSR_VSPMPADDR10      = 13'h10CA,
    CSR_VSPMPADDR11      = 13'h10CB,
    CSR_VSPMPADDR12      = 13'h10CC,
    CSR_VSPMPADDR13      = 13'h10CD,
    CSR_VSPMPADDR14      = 13'h10CE,
    CSR_VSPMPADDR15      = 13'h10CF,
    CSR_VSPMPADDR16      = 13'h10D0,
    CSR_VSPMPADDR17      = 13'h10D1,
    CSR_VSPMPADDR18      = 13'h10D2,
    CSR_VSPMPADDR19      = 13'h10D3,
    CSR_VSPMPADDR20      = 13'h10D4,
    CSR_VSPMPADDR21      = 13'h10D5,
    CSR_VSPMPADDR22      = 13'h10D6,
    CSR_VSPMPADDR23      = 13'h10D7,
    CSR_VSPMPADDR24      = 13'h10D8,
    CSR_VSPMPADDR25      = 13'h10D9,
    CSR_VSPMPADDR26      = 13'h10DA,
    CSR_VSPMPADDR27      = 13'h10DB,
    CSR_VSPMPADDR28      = 13'h10DC,
    CSR_VSPMPADDR29      = 13'h10DD,
    CSR_VSPMPADDR30      = 13'h10DE,
    CSR_VSPMPADDR31      = 13'h10DF,
    CSR_VSPMPADDR32      = 13'h10E0,
    CSR_VSPMPADDR33      = 13'h10E1,
    CSR_VSPMPADDR34      = 13'h10E2,
    CSR_VSPMPADDR35      = 13'h10E3,
    CSR_VSPMPADDR36      = 13'h10E4,
    CSR_VSPMPADDR37      = 13'h10E5,
    CSR_VSPMPADDR38      = 13'h10E6,
    CSR_VSPMPADDR39      = 13'h10E7,
    CSR_VSPMPADDR40      = 13'h10E8,
    CSR_VSPMPADDR41      = 13'h10E9,
    CSR_VSPMPADDR42      = 13'h10EA,
    CSR_VSPMPADDR43      = 13'h10EB,
    CSR_VSPMPADDR44      = 13'h10EC,
    CSR_VSPMPADDR45      = 13'h10ED,
    CSR_VSPMPADDR46      = 13'h10EE,
    CSR_VSPMPADDR47      = 13'h10EF,
    CSR_VSPMPADDR48      = 13'h10F0,
    CSR_VSPMPADDR49      = 13'h10F1,
    CSR_VSPMPADDR50      = 13'h10F2,
    CSR_VSPMPADDR51      = 13'h10F3,
    CSR_VSPMPADDR52      = 13'h10F4,
    CSR_VSPMPADDR53      = 13'h10F5,
    CSR_VSPMPADDR54      = 13'h10F6,
    CSR_VSPMPADDR55      = 13'h10F7,
    CSR_VSPMPADDR56      = 13'h10F8,
    CSR_VSPMPADDR57      = 13'h10F9,
    CSR_VSPMPADDR58      = 13'h10FA,
    CSR_VSPMPADDR59      = 13'h10FB,
    CSR_VSPMPADDR60      = 13'h10FC,
    CSR_VSPMPADDR61      = 13'h10FD,
    CSR_VSPMPADDR62      = 13'h10FE,
    CSR_VSPMPADDR63      = 13'h10FF,
    // Aux encoding for indirect CSR accesses to unimplemented addresses
    CSR_ILLEGAL          = 13'hFFFF
  } csr_ind_reg_t;

  localparam logic [63:0] SSTATUS_UIE = 'h00000001;
  localparam logic [63:0] SSTATUS_SIE = 'h00000002;
  localparam logic [63:0] SSTATUS_SPIE = 'h00000020;
  localparam logic [63:0] SSTATUS_SPP = 'h00000100;
  localparam logic [63:0] SSTATUS_FS = 'h00006000;
  localparam logic [63:0] SSTATUS_XS = 'h00018000;
  localparam logic [63:0] SSTATUS_SUM = 'h00040000;
  localparam logic [63:0] SSTATUS_MXR = 'h00080000;
  localparam logic [63:0] SSTATUS_UPIE = 'h00000010;
  localparam logic [63:0] SSTATUS_UXL = 64'h0000000300000000;
  function automatic logic [63:0] sstatus_sd(logic IS_XLEN64);
    return {IS_XLEN64, 31'h00000000, ~IS_XLEN64, 31'h00000000};
  endfunction

  localparam logic [63:0] HSTATUS_VSBE = 'h00000020;
  localparam logic [63:0] HSTATUS_GVA = 'h00000040;
  localparam logic [63:0] HSTATUS_SPV = 'h00000080;
  localparam logic [63:0] HSTATUS_SPVP = 'h00000100;
  localparam logic [63:0] HSTATUS_HU = 'h00000200;
  localparam logic [63:0] HSTATUS_VGEIN = 'h0003F000;
  localparam logic [63:0] HSTATUS_VTVM = 'h00100000;
  localparam logic [63:0] HSTATUS_VTW = 'h00200000;
  localparam logic [63:0] HSTATUS_VTSR = 'h00400000;
  localparam logic [63:0] HSTATUS_VSXL = 64'h0000000300000000;

  localparam logic [63:0] MSTATUS_UIE = 'h00000001;
  localparam logic [63:0] MSTATUS_SIE = 'h00000002;
  localparam logic [63:0] MSTATUS_HIE = 'h00000004;
  localparam logic [63:0] MSTATUS_MIE = 'h00000008;
  localparam logic [63:0] MSTATUS_UPIE = 'h00000010;
  localparam logic [63:0] MSTATUS_SPIE = 'h00000020;
  localparam logic [63:0] MSTATUS_HPIE = 'h00000040;
  localparam logic [63:0] MSTATUS_MPIE = 'h00000080;
  localparam logic [63:0] MSTATUS_SPP = 'h00000100;
  localparam logic [63:0] MSTATUS_HPP = 'h00000600;
  localparam logic [63:0] MSTATUS_MPP = 'h00001800;
  localparam logic [63:0] MSTATUS_FS = 'h00006000;
  localparam logic [63:0] MSTATUS_XS = 'h00018000;
  localparam logic [63:0] MSTATUS_MPRV = 'h00020000;
  localparam logic [63:0] MSTATUS_SUM = 'h00040000;
  localparam logic [63:0] MSTATUS_MXR = 'h00080000;
  localparam logic [63:0] MSTATUS_TVM = 'h00100000;
  localparam logic [63:0] MSTATUS_TW = 'h00200000;
  localparam logic [63:0] MSTATUS_TSR = 'h00400000;
  function automatic logic [63:0] mstatus_uxl(logic IS_XLEN64);
    return {30'h0000000, IS_XLEN64, IS_XLEN64, 32'h00000000};
  endfunction
  function automatic logic [63:0] mstatus_sxl(logic IS_XLEN64);
    return {28'h0000000, IS_XLEN64, IS_XLEN64, 34'h00000000};
  endfunction
  function automatic logic [63:0] mstatus_sd(logic IS_XLEN64);
    return {IS_XLEN64, 31'h00000000, ~IS_XLEN64, 31'h00000000};
  endfunction

  localparam logic [63:0] MENVCFG_FIOM = 'h00000001;
  localparam logic [63:0] MENVCFG_CBIE = 'h00000030;
  localparam logic [63:0] MENVCFG_CBFE = 'h00000040;
  localparam logic [63:0] MENVCFG_CBZE = 'h00000080;
  localparam logic [63:0] MENVCFG_PBMTE = 64'h4000000000000000;
  localparam logic [63:0] MENVCFG_STCE = 64'h8000000000000000;



  typedef enum logic [2:0] {
    CSRRW  = 3'h1,
    CSRRS  = 3'h2,
    CSRRC  = 3'h3,
    CSRRWI = 3'h5,
    CSRRSI = 3'h6,
    CSRRCI = 3'h7
  } csr_op_t;

  // decoded CSR address
  typedef struct packed {
    logic [1:0] rw;
    priv_lvl_t  priv_lvl;
    logic [7:0] address;
  } csr_addr_t;

  typedef union packed {
    csr_reg_t  address;
    csr_addr_t csr_decode;
  } csr_t;

  // CSR Indirect Access
  typedef struct packed {
    logic csrind_only;
    csr_t csr;
  } csr_ind_t;

  // Floating-Point control and status register (32-bit!)
  typedef struct packed {
    logic [31:15] reserved;  // reserved for L extension, return 0 otherwise
    logic [6:0]   fprec;     // div/sqrt precision control
    logic [2:0]   frm;       // float rounding mode
    logic [4:0]   fflags;    // float exception flags
  } fcsr_t;

  // PMP
  typedef enum logic [1:0] {
    OFF   = 2'b00,
    TOR   = 2'b01,
    NA4   = 2'b10,
    NAPOT = 2'b11
  } pmp_addr_mode_t;

  // PMP Access Type
  typedef enum logic [2:0] {
    ACCESS_NONE  = 3'b000,
    ACCESS_READ  = 3'b001,
    ACCESS_WRITE = 3'b010,
    ACCESS_EXEC  = 3'b100
  } pmp_access_t;

  typedef struct packed {
    logic x;
    logic w;
    logic r;
  } pmpcfg_access_t;

  // packed struct of a PMP configuration register (8bit)
  typedef struct packed {
    logic           locked;       // lock this configuration
    logic [1:0]     reserved;
    pmp_addr_mode_t addr_mode;    // Off, TOR, NA4, NAPOT
    pmpcfg_access_t access_type;  // [x, w, r]
  } pmpcfg_t;

  // -----
  // SPMP
  // -----
  // SPMP configuration fields
  typedef struct packed {
    logic [5:0] reserved;
    logic       shared;   // Shared region
    logic       u;        // U-mode /S-mode rule
  } spmpcfg_t;

  // -----
  // Debug
  // -----
  typedef struct packed {
    logic [31:28] xdebugver;
    logic [27:18] zero2;
    logic         ebreakvs;
    logic         ebreakvu;
    logic         ebreakm;
    logic         zero1;
    logic         ebreaks;
    logic         ebreaku;
    logic         stepie;
    logic         stopcount;
    logic         stoptime;
    logic [8:6]   cause;
    logic         v;
    logic         mprven;
    logic         nmip;
    logic         step;
    priv_lvl_t    prv;
  } dcsr_t;

  // Instruction Generation *incomplete*
  function automatic logic [31:0] jal(logic [4:0] rd, logic [20:0] imm);
    // OpCode Jal
    return {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'h6f};
  endfunction

  function automatic logic [31:0] jalr(logic [4:0] rd, logic [4:0] rs1, logic [11:0] offset);
    // OpCode Jal
    return {offset[11:0], rs1, 3'b0, rd, 7'h67};
  endfunction

  function automatic logic [31:0] andi(logic [4:0] rd, logic [4:0] rs1, logic [11:0] imm);
    // OpCode andi
    return {imm[11:0], rs1, 3'h7, rd, 7'h13};
  endfunction

  function automatic logic [31:0] slli(logic [4:0] rd, logic [4:0] rs1, logic [5:0] shamt);
    // OpCode slli
    return {6'b0, shamt[5:0], rs1, 3'h1, rd, 7'h13};
  endfunction

  function automatic logic [31:0] srli(logic [4:0] rd, logic [4:0] rs1, logic [5:0] shamt);
    // OpCode srli
    return {6'b0, shamt[5:0], rs1, 3'h5, rd, 7'h13};
  endfunction

  function automatic logic [31:0] load(logic [2:0] size, logic [4:0] dest, logic [4:0] base,
                                       logic [11:0] offset);
    // OpCode Load
    return {offset[11:0], base, size, dest, 7'h03};
  endfunction

  function automatic logic [31:0] auipc(logic [4:0] rd, logic [20:0] imm);
    // OpCode Auipc
    return {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'h17};
  endfunction

  function automatic logic [31:0] store(logic [2:0] size, logic [4:0] src, logic [4:0] base,
                                        logic [11:0] offset);
    // OpCode Store
    return {offset[11:5], src, base, size, offset[4:0], 7'h23};
  endfunction

  function automatic logic [31:0] float_load(logic [2:0] size, logic [4:0] dest, logic [4:0] base,
                                             logic [11:0] offset);
    // OpCode Load
    return {offset[11:0], base, size, dest, 7'b00_001_11};
  endfunction

  function automatic logic [31:0] float_store(logic [2:0] size, logic [4:0] src, logic [4:0] base,
                                              logic [11:0] offset);
    // OpCode Store
    return {offset[11:5], src, base, size, offset[4:0], 7'b01_001_11};
  endfunction

  function automatic logic [31:0] csrw(csr_reg_t csr, logic [4:0] rs1);
    // CSRRW, rd, OpCode System
    return {csr, rs1, 3'h1, 5'h0, 7'h73};
  endfunction

  function automatic logic [31:0] csrr(csr_reg_t csr, logic [4:0] dest);
    // rs1, CSRRS, rd, OpCode System
    return {csr, 5'h0, 3'h2, dest, 7'h73};
  endfunction

  function automatic logic [31:0] branch(logic [4:0] src2, logic [4:0] src1, logic [2:0] funct3,
                                         logic [11:0] offset);
    // OpCode Branch
    return {offset[11], offset[9:4], src2, src1, funct3, offset[3:0], offset[10], 7'b11_000_11};
  endfunction

  function automatic logic [31:0] ebreak();
    return 32'h00100073;
  endfunction

  function automatic logic [31:0] wfi();
    return 32'h10500073;
  endfunction

  function automatic logic [31:0] nop();
    return 32'h00000013;
  endfunction

  function automatic logic [31:0] illegal();
    return 32'h00000000;
  endfunction

  // This functions converts S-mode CSR addresses into VS-mode CSR addresses
  // when V=1 (i.e., running in VS-mode).
  function automatic csr_t convert_vs_access_csr(csr_t csr_addr, logic v);
    csr_t ret;
    ret = csr_addr;
    unique case (csr_addr.address) inside
      [CSR_SSTATUS : CSR_STVEC], [CSR_SSCRATCH : CSR_SATP], [CSR_SPMPCFG0 : CSR_SPMPSWITCHH]: begin
        if (v) begin
          ret.csr_decode.priv_lvl = PRIV_LVL_HS;
        end
        return ret;
      end
      default: return ret;
    endcase
  endfunction

  // Indirect‑CSR mapping tables
  localparam int unsigned XISELECT_ENTRIES = 64;
  localparam int SELW = $clog2(XISELECT_ENTRIES);
  localparam int unsigned XIREGS = 6;

  // M‑mode table
  localparam csr_ind_reg_t MCSRIND_MAP [XISELECT_ENTRIES][XIREGS] = '{
  /* miselect */   /* mireg - mireg6 */
  /*     0    */ '{ CSR_SPMPADDR0,  CSR_SPMPCFG0,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     1    */ '{ CSR_SPMPADDR1,  CSR_SPMPCFG1,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     2    */ '{ CSR_SPMPADDR2,  CSR_SPMPCFG2,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     3    */ '{ CSR_SPMPADDR3,  CSR_SPMPCFG3,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     4    */ '{ CSR_SPMPADDR4,  CSR_SPMPCFG4,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     5    */ '{ CSR_SPMPADDR5,  CSR_SPMPCFG5,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     6    */ '{ CSR_SPMPADDR6,  CSR_SPMPCFG6,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     7    */ '{ CSR_SPMPADDR7,  CSR_SPMPCFG7,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     8    */ '{ CSR_SPMPADDR8,  CSR_SPMPCFG8,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     9    */ '{ CSR_SPMPADDR9,  CSR_SPMPCFG9,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    10    */ '{ CSR_SPMPADDR10, CSR_SPMPCFG10, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    11    */ '{ CSR_SPMPADDR11, CSR_SPMPCFG11, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    12    */ '{ CSR_SPMPADDR12, CSR_SPMPCFG12, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    13    */ '{ CSR_SPMPADDR13, CSR_SPMPCFG13, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    14    */ '{ CSR_SPMPADDR14, CSR_SPMPCFG14, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    15    */ '{ CSR_SPMPADDR15, CSR_SPMPCFG15, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    16    */ '{ CSR_SPMPADDR16, CSR_SPMPCFG16, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    17    */ '{ CSR_SPMPADDR17, CSR_SPMPCFG17, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    18    */ '{ CSR_SPMPADDR18, CSR_SPMPCFG18, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    19    */ '{ CSR_SPMPADDR19, CSR_SPMPCFG19, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    20    */ '{ CSR_SPMPADDR20, CSR_SPMPCFG20, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    21    */ '{ CSR_SPMPADDR21, CSR_SPMPCFG21, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    22    */ '{ CSR_SPMPADDR22, CSR_SPMPCFG22, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    23    */ '{ CSR_SPMPADDR23, CSR_SPMPCFG23, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    24    */ '{ CSR_SPMPADDR24, CSR_SPMPCFG24, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    25    */ '{ CSR_SPMPADDR25, CSR_SPMPCFG25, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    26    */ '{ CSR_SPMPADDR26, CSR_SPMPCFG26, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    27    */ '{ CSR_SPMPADDR27, CSR_SPMPCFG27, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    28    */ '{ CSR_SPMPADDR28, CSR_SPMPCFG28, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    29    */ '{ CSR_SPMPADDR29, CSR_SPMPCFG29, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    30    */ '{ CSR_SPMPADDR30, CSR_SPMPCFG30, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    31    */ '{ CSR_SPMPADDR31, CSR_SPMPCFG31, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    32    */ '{ CSR_SPMPADDR32, CSR_SPMPCFG32, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    33    */ '{ CSR_SPMPADDR33, CSR_SPMPCFG33, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    34    */ '{ CSR_SPMPADDR34, CSR_SPMPCFG34, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    35    */ '{ CSR_SPMPADDR35, CSR_SPMPCFG35, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    36    */ '{ CSR_SPMPADDR36, CSR_SPMPCFG36, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    37    */ '{ CSR_SPMPADDR37, CSR_SPMPCFG37, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    38    */ '{ CSR_SPMPADDR38, CSR_SPMPCFG38, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    39    */ '{ CSR_SPMPADDR39, CSR_SPMPCFG39, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    40    */ '{ CSR_SPMPADDR40, CSR_SPMPCFG40, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    41    */ '{ CSR_SPMPADDR41, CSR_SPMPCFG41, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    42    */ '{ CSR_SPMPADDR42, CSR_SPMPCFG42, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    43    */ '{ CSR_SPMPADDR43, CSR_SPMPCFG43, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    44    */ '{ CSR_SPMPADDR44, CSR_SPMPCFG44, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    45    */ '{ CSR_SPMPADDR45, CSR_SPMPCFG45, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    46    */ '{ CSR_SPMPADDR46, CSR_SPMPCFG46, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    47    */ '{ CSR_SPMPADDR47, CSR_SPMPCFG47, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    48    */ '{ CSR_SPMPADDR48, CSR_SPMPCFG48, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    49    */ '{ CSR_SPMPADDR49, CSR_SPMPCFG49, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    50    */ '{ CSR_SPMPADDR50, CSR_SPMPCFG50, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    51    */ '{ CSR_SPMPADDR51, CSR_SPMPCFG51, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    52    */ '{ CSR_SPMPADDR52, CSR_SPMPCFG52, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    53    */ '{ CSR_SPMPADDR53, CSR_SPMPCFG53, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    54    */ '{ CSR_SPMPADDR54, CSR_SPMPCFG54, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    55    */ '{ CSR_SPMPADDR55, CSR_SPMPCFG55, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    56    */ '{ CSR_SPMPADDR56, CSR_SPMPCFG56, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    57    */ '{ CSR_SPMPADDR57, CSR_SPMPCFG57, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    58    */ '{ CSR_SPMPADDR58, CSR_SPMPCFG58, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    59    */ '{ CSR_SPMPADDR59, CSR_SPMPCFG59, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    60    */ '{ CSR_SPMPADDR60, CSR_SPMPCFG60, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    61    */ '{ CSR_SPMPADDR61, CSR_SPMPCFG61, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    62    */ '{ CSR_SPMPADDR62, CSR_SPMPCFG62, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    63    */ '{ CSR_SPMPADDR63, CSR_SPMPCFG63, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL }
  };

  // S-mode table
  localparam csr_ind_reg_t SCSRIND_MAP [XISELECT_ENTRIES][XIREGS] = '{
  /* siselect */  /* sireg - sireg6 */
  /*     0    */ '{ CSR_SPMPADDR0,  CSR_SPMPCFG0,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     1    */ '{ CSR_SPMPADDR1,  CSR_SPMPCFG1,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     2    */ '{ CSR_SPMPADDR2,  CSR_SPMPCFG2,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     3    */ '{ CSR_SPMPADDR3,  CSR_SPMPCFG3,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     4    */ '{ CSR_SPMPADDR4,  CSR_SPMPCFG4,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     5    */ '{ CSR_SPMPADDR5,  CSR_SPMPCFG5,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     6    */ '{ CSR_SPMPADDR6,  CSR_SPMPCFG6,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     7    */ '{ CSR_SPMPADDR7,  CSR_SPMPCFG7,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     8    */ '{ CSR_SPMPADDR8,  CSR_SPMPCFG8,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     9    */ '{ CSR_SPMPADDR9,  CSR_SPMPCFG9,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    10    */ '{ CSR_SPMPADDR10, CSR_SPMPCFG10, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    11    */ '{ CSR_SPMPADDR11, CSR_SPMPCFG11, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    12    */ '{ CSR_SPMPADDR12, CSR_SPMPCFG12, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    13    */ '{ CSR_SPMPADDR13, CSR_SPMPCFG13, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    14    */ '{ CSR_SPMPADDR14, CSR_SPMPCFG14, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    15    */ '{ CSR_SPMPADDR15, CSR_SPMPCFG15, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    16    */ '{ CSR_SPMPADDR16, CSR_SPMPCFG16, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    17    */ '{ CSR_SPMPADDR17, CSR_SPMPCFG17, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    18    */ '{ CSR_SPMPADDR18, CSR_SPMPCFG18, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    19    */ '{ CSR_SPMPADDR19, CSR_SPMPCFG19, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    20    */ '{ CSR_SPMPADDR20, CSR_SPMPCFG20, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    21    */ '{ CSR_SPMPADDR21, CSR_SPMPCFG21, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    22    */ '{ CSR_SPMPADDR22, CSR_SPMPCFG22, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    23    */ '{ CSR_SPMPADDR23, CSR_SPMPCFG23, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    24    */ '{ CSR_SPMPADDR24, CSR_SPMPCFG24, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    25    */ '{ CSR_SPMPADDR25, CSR_SPMPCFG25, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    26    */ '{ CSR_SPMPADDR26, CSR_SPMPCFG26, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    27    */ '{ CSR_SPMPADDR27, CSR_SPMPCFG27, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    28    */ '{ CSR_SPMPADDR28, CSR_SPMPCFG28, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    29    */ '{ CSR_SPMPADDR29, CSR_SPMPCFG29, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    30    */ '{ CSR_SPMPADDR30, CSR_SPMPCFG30, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    31    */ '{ CSR_SPMPADDR31, CSR_SPMPCFG31, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    32    */ '{ CSR_SPMPADDR32, CSR_SPMPCFG32, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    33    */ '{ CSR_SPMPADDR33, CSR_SPMPCFG33, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    34    */ '{ CSR_SPMPADDR34, CSR_SPMPCFG34, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    35    */ '{ CSR_SPMPADDR35, CSR_SPMPCFG35, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    36    */ '{ CSR_SPMPADDR36, CSR_SPMPCFG36, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    37    */ '{ CSR_SPMPADDR37, CSR_SPMPCFG37, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    38    */ '{ CSR_SPMPADDR38, CSR_SPMPCFG38, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    39    */ '{ CSR_SPMPADDR39, CSR_SPMPCFG39, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    40    */ '{ CSR_SPMPADDR40, CSR_SPMPCFG40, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    41    */ '{ CSR_SPMPADDR41, CSR_SPMPCFG41, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    42    */ '{ CSR_SPMPADDR42, CSR_SPMPCFG42, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    43    */ '{ CSR_SPMPADDR43, CSR_SPMPCFG43, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    44    */ '{ CSR_SPMPADDR44, CSR_SPMPCFG44, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    45    */ '{ CSR_SPMPADDR45, CSR_SPMPCFG45, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    46    */ '{ CSR_SPMPADDR46, CSR_SPMPCFG46, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    47    */ '{ CSR_SPMPADDR47, CSR_SPMPCFG47, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    48    */ '{ CSR_SPMPADDR48, CSR_SPMPCFG48, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    49    */ '{ CSR_SPMPADDR49, CSR_SPMPCFG49, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    50    */ '{ CSR_SPMPADDR50, CSR_SPMPCFG50, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    51    */ '{ CSR_SPMPADDR51, CSR_SPMPCFG51, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    52    */ '{ CSR_SPMPADDR52, CSR_SPMPCFG52, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    53    */ '{ CSR_SPMPADDR53, CSR_SPMPCFG53, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    54    */ '{ CSR_SPMPADDR54, CSR_SPMPCFG54, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    55    */ '{ CSR_SPMPADDR55, CSR_SPMPCFG55, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    56    */ '{ CSR_SPMPADDR56, CSR_SPMPCFG56, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    57    */ '{ CSR_SPMPADDR57, CSR_SPMPCFG57, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    58    */ '{ CSR_SPMPADDR58, CSR_SPMPCFG58, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    59    */ '{ CSR_SPMPADDR59, CSR_SPMPCFG59, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    60    */ '{ CSR_SPMPADDR60, CSR_SPMPCFG60, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    61    */ '{ CSR_SPMPADDR61, CSR_SPMPCFG61, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    62    */ '{ CSR_SPMPADDR62, CSR_SPMPCFG62, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    63    */ '{ CSR_SPMPADDR63, CSR_SPMPCFG63, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL }
};

  // VS-mode table
  localparam csr_ind_reg_t VSCSRIND_MAP [XISELECT_ENTRIES][XIREGS] = '{
  /* vsiselect */  /* vsireg - vsireg6 */
  /*     0    */ '{ CSR_VSPMPADDR0,  CSR_VSPMPCFG0,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     1    */ '{ CSR_VSPMPADDR1,  CSR_VSPMPCFG1,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     2    */ '{ CSR_VSPMPADDR2,  CSR_VSPMPCFG2,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     3    */ '{ CSR_VSPMPADDR3,  CSR_VSPMPCFG3,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     4    */ '{ CSR_VSPMPADDR4,  CSR_VSPMPCFG4,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     5    */ '{ CSR_VSPMPADDR5,  CSR_VSPMPCFG5,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     6    */ '{ CSR_VSPMPADDR6,  CSR_VSPMPCFG6,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     7    */ '{ CSR_VSPMPADDR7,  CSR_VSPMPCFG7,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     8    */ '{ CSR_VSPMPADDR8,  CSR_VSPMPCFG8,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*     9    */ '{ CSR_VSPMPADDR9,  CSR_VSPMPCFG9,  CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    10    */ '{ CSR_VSPMPADDR10, CSR_VSPMPCFG10, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    11    */ '{ CSR_VSPMPADDR11, CSR_VSPMPCFG11, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    12    */ '{ CSR_VSPMPADDR12, CSR_VSPMPCFG12, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    13    */ '{ CSR_VSPMPADDR13, CSR_VSPMPCFG13, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    14    */ '{ CSR_VSPMPADDR14, CSR_VSPMPCFG14, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    15    */ '{ CSR_VSPMPADDR15, CSR_VSPMPCFG15, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    16    */ '{ CSR_VSPMPADDR16, CSR_VSPMPCFG16, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    17    */ '{ CSR_VSPMPADDR17, CSR_VSPMPCFG17, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    18    */ '{ CSR_VSPMPADDR18, CSR_VSPMPCFG18, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    19    */ '{ CSR_VSPMPADDR19, CSR_VSPMPCFG19, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    20    */ '{ CSR_VSPMPADDR20, CSR_VSPMPCFG20, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    21    */ '{ CSR_VSPMPADDR21, CSR_VSPMPCFG21, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    22    */ '{ CSR_VSPMPADDR22, CSR_VSPMPCFG22, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    23    */ '{ CSR_VSPMPADDR23, CSR_VSPMPCFG23, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    24    */ '{ CSR_VSPMPADDR24, CSR_VSPMPCFG24, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    25    */ '{ CSR_VSPMPADDR25, CSR_VSPMPCFG25, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    26    */ '{ CSR_VSPMPADDR26, CSR_VSPMPCFG26, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    27    */ '{ CSR_VSPMPADDR27, CSR_VSPMPCFG27, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    28    */ '{ CSR_VSPMPADDR28, CSR_VSPMPCFG28, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    29    */ '{ CSR_VSPMPADDR29, CSR_VSPMPCFG29, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    30    */ '{ CSR_VSPMPADDR30, CSR_VSPMPCFG30, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    31    */ '{ CSR_VSPMPADDR31, CSR_VSPMPCFG31, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    32    */ '{ CSR_VSPMPADDR32, CSR_VSPMPCFG32, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    33    */ '{ CSR_VSPMPADDR33, CSR_VSPMPCFG33, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    34    */ '{ CSR_VSPMPADDR34, CSR_VSPMPCFG34, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    35    */ '{ CSR_VSPMPADDR35, CSR_VSPMPCFG35, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    36    */ '{ CSR_VSPMPADDR36, CSR_VSPMPCFG36, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    37    */ '{ CSR_VSPMPADDR37, CSR_VSPMPCFG37, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    38    */ '{ CSR_VSPMPADDR38, CSR_VSPMPCFG38, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    39    */ '{ CSR_VSPMPADDR39, CSR_VSPMPCFG39, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    40    */ '{ CSR_VSPMPADDR40, CSR_VSPMPCFG40, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    41    */ '{ CSR_VSPMPADDR41, CSR_VSPMPCFG41, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    42    */ '{ CSR_VSPMPADDR42, CSR_VSPMPCFG42, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    43    */ '{ CSR_VSPMPADDR43, CSR_VSPMPCFG43, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    44    */ '{ CSR_VSPMPADDR44, CSR_VSPMPCFG44, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    45    */ '{ CSR_VSPMPADDR45, CSR_VSPMPCFG45, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    46    */ '{ CSR_VSPMPADDR46, CSR_VSPMPCFG46, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    47    */ '{ CSR_VSPMPADDR47, CSR_VSPMPCFG47, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    48    */ '{ CSR_VSPMPADDR48, CSR_VSPMPCFG48, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    49    */ '{ CSR_VSPMPADDR49, CSR_VSPMPCFG49, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    50    */ '{ CSR_VSPMPADDR50, CSR_VSPMPCFG50, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    51    */ '{ CSR_VSPMPADDR51, CSR_VSPMPCFG51, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    52    */ '{ CSR_VSPMPADDR52, CSR_VSPMPCFG52, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    53    */ '{ CSR_VSPMPADDR53, CSR_VSPMPCFG53, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    54    */ '{ CSR_VSPMPADDR54, CSR_VSPMPCFG54, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    55    */ '{ CSR_VSPMPADDR55, CSR_VSPMPCFG55, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    56    */ '{ CSR_VSPMPADDR56, CSR_VSPMPCFG56, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    57    */ '{ CSR_VSPMPADDR57, CSR_VSPMPCFG57, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    58    */ '{ CSR_VSPMPADDR58, CSR_VSPMPCFG58, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    59    */ '{ CSR_VSPMPADDR59, CSR_VSPMPCFG59, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    60    */ '{ CSR_VSPMPADDR60, CSR_VSPMPCFG60, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    61    */ '{ CSR_VSPMPADDR61, CSR_VSPMPCFG61, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    62    */ '{ CSR_VSPMPADDR62, CSR_VSPMPCFG62, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL },
  /*    63    */ '{ CSR_VSPMPADDR63, CSR_VSPMPCFG63, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL, CSR_ILLEGAL }
};

  // Output the address of the corresponding CSR when it 
  //  is accessed indirectly via one of the xireg CSRs
  function automatic csr_ind_t convert_csrind_access(csr_t csr_addr, logic [63:0] miselect, 
                                                 logic [63:0] siselect, logic [63:0] vsiselect);
    csr_ind_t ret;

    unique case (csr_addr.address) inside
      [CSR_MIREG : CSR_MIREG3]: begin
        automatic int unsigned xireg = csr_addr.address - CSR_MIREG;
        ret = csr_ind_t'(MCSRIND_MAP[miselect[SELW-1:0]][xireg[2:0]]);
      end
      [CSR_MIREG4 : CSR_MIREG6]: begin
        automatic int unsigned xireg = csr_addr.address - CSR_MIREG - 1;
        ret = csr_ind_t'(MCSRIND_MAP[miselect[SELW-1:0]][xireg[2:0]]);
      end
      [CSR_SIREG : CSR_SIREG3]: begin
        automatic int unsigned xireg = csr_addr.address - CSR_SIREG;
        ret = csr_ind_t'(SCSRIND_MAP[siselect[SELW-1:0]][xireg[2:0]]);
      end
      [CSR_SIREG4 : CSR_SIREG6]: begin
        automatic int unsigned xireg = csr_addr.address - CSR_SIREG - 1;
        ret = csr_ind_t'(SCSRIND_MAP[siselect[SELW-1:0]][xireg[2:0]]);
      end
      [CSR_VSIREG : CSR_VSIREG3]: begin
        automatic int unsigned xireg = csr_addr.address - CSR_VSIREG;
        ret = csr_ind_t'(VSCSRIND_MAP[vsiselect[SELW-1:0]][xireg[2:0]]);
      end
      [CSR_VSIREG4 : CSR_VSIREG6]: begin
        automatic int unsigned xireg = csr_addr.address - CSR_VSIREG - 1;
        ret = csr_ind_t'(VSCSRIND_MAP[vsiselect[SELW-1:0]][xireg[2:0]]);
      end
      default: begin
        ret.csrind_only = 1'b0;
        ret.csr = csr_addr;
      end
    endcase

    return ret;
  endfunction

  // Determine whether an indirect CSR access was done via miselect
  function automatic logic is_csrind_miselect(csr_t csr_addr);

    unique case (csr_addr.address) inside
      [CSR_MIREG : CSR_MIREG3]: begin
        return 1'b1;
      end
      [CSR_MIREG4 : CSR_MIREG6]: begin
        return 1'b1;
      end
      default: begin
        return 1'b0;
      end
    endcase
  endfunction

  // trace log compatible to spikes commit log feature
  // pragma translate_off
  function string spikeCommitLog(logic [63:0] pc, priv_lvl_t priv_lvl, logic [31:0] instr,
                                 logic [4:0] rd, logic [63:0] result, logic rd_fpr);
    string rd_s;
    string instr_word;

    automatic string rf_s = rd_fpr ? "f" : "x";

    if (instr[1:0] != 2'b11) begin
      instr_word = $sformatf("(0x%h)", instr[15:0]);
    end else begin
      instr_word = $sformatf("(0x%h)", instr);
    end

    if (rd < 10) rd_s = $sformatf("%s %0d", rf_s, rd);
    else rd_s = $sformatf("%s%0d", rf_s, rd);

    if (rd_fpr || rd != 0) begin
      // 0 0x0000000080000118 (0xeecf8f93) x31 0x0000000080004000
      return $sformatf("%d 0x%h %s %s 0x%h\n", priv_lvl, pc, instr_word, rd_s, result);
    end else begin
      // 0 0x000000008000019c (0x0040006f)
      return $sformatf("%d 0x%h %s\n", priv_lvl, pc, instr_word);
    end
  endfunction

  typedef struct {
    byte priv;
    longint unsigned pc;
    byte is_fp;
    byte rd;
    longint unsigned data;
    int unsigned instr;
    byte was_exception;
  } commit_log_t;
  // pragma translate_on

endpackage

/*verilator tracing_off*/
