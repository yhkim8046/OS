
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	18010113          	add	sp,sp,384 # 80009180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	sllw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	1761                	add	a4,a4,-8 # 200bff8 <_entry-0x7dff4008>
    8000003a:	6318                	ld	a4,0(a4)
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	add	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	ff070713          	add	a4,a4,-16 # 80009040 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	c0e78793          	add	a5,a5,-1010 # 80005c70 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	or	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	or	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e2078793          	add	a5,a5,-480 # 80000ecc <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	3c6080e7          	jalr	966(ra) # 800024f0 <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7de080e7          	jalr	2014(ra) # 80000918 <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addw	s2,s2,1
    80000144:	0485                	add	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    8000014c:	74e2                	ld	s1,56(sp)
    8000014e:	79a2                	ld	s3,40(sp)
    80000150:	7a02                	ld	s4,32(sp)
    80000152:	6ae2                	ld	s5,24(sp)
    80000154:	a039                	j	80000162 <consolewrite+0x62>
    80000156:	4901                	li	s2,0
    80000158:	a029                	j	80000162 <consolewrite+0x62>
    8000015a:	74e2                	ld	s1,56(sp)
    8000015c:	79a2                	ld	s3,40(sp)
    8000015e:	7a02                	ld	s4,32(sp)
    80000160:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	add	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	add	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	add	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	ff450513          	add	a0,a0,-12 # 80011180 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a9e080e7          	jalr	-1378(ra) # 80000c32 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	fe448493          	add	s1,s1,-28 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a4:	00011917          	auipc	s2,0x11
    800001a8:	07490913          	add	s2,s2,116 # 80011218 <cons+0x98>
  while(n > 0){
    800001ac:	0d305463          	blez	s3,80000274 <consoleread+0x106>
    while(cons.r == cons.w){
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71963          	bne	a4,a5,8000026a <consoleread+0xfc>
      if(myproc()->killed){
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	874080e7          	jalr	-1932(ra) # 80001a30 <myproc>
    800001c4:	551c                	lw	a5,40(a0)
    800001c6:	e7ad                	bnez	a5,80000230 <consoleread+0xc2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	f2a080e7          	jalr	-214(ra) # 800020f6 <sleep>
    while(cons.r == cons.w){
    800001d4:	0984a783          	lw	a5,152(s1)
    800001d8:	09c4a703          	lw	a4,156(s1)
    800001dc:	fef700e3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e0:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF];
    800001e2:	00011717          	auipc	a4,0x11
    800001e6:	f9e70713          	add	a4,a4,-98 # 80011180 <cons>
    800001ea:	0017869b          	addw	a3,a5,1
    800001ee:	08d72c23          	sw	a3,152(a4)
    800001f2:	07f7f693          	and	a3,a5,127
    800001f6:	9736                	add	a4,a4,a3
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80000200:	4691                	li	a3,4
    80000202:	04db8a63          	beq	s7,a3,80000256 <consoleread+0xe8>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000206:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020a:	4685                	li	a3,1
    8000020c:	faf40613          	add	a2,s0,-81
    80000210:	85d2                	mv	a1,s4
    80000212:	8556                	mv	a0,s5
    80000214:	00002097          	auipc	ra,0x2
    80000218:	286080e7          	jalr	646(ra) # 8000249a <either_copyout>
    8000021c:	57fd                	li	a5,-1
    8000021e:	04f50a63          	beq	a0,a5,80000272 <consoleread+0x104>
      break;

    dst++;
    80000222:	0a05                	add	s4,s4,1
    --n;
    80000224:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    80000226:	47a9                	li	a5,10
    80000228:	06fb8163          	beq	s7,a5,8000028a <consoleread+0x11c>
    8000022c:	6be2                	ld	s7,24(sp)
    8000022e:	bfbd                	j	800001ac <consoleread+0x3e>
        release(&cons.lock);
    80000230:	00011517          	auipc	a0,0x11
    80000234:	f5050513          	add	a0,a0,-176 # 80011180 <cons>
    80000238:	00001097          	auipc	ra,0x1
    8000023c:	aae080e7          	jalr	-1362(ra) # 80000ce6 <release>
        return -1;
    80000240:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000242:	60e6                	ld	ra,88(sp)
    80000244:	6446                	ld	s0,80(sp)
    80000246:	64a6                	ld	s1,72(sp)
    80000248:	6906                	ld	s2,64(sp)
    8000024a:	79e2                	ld	s3,56(sp)
    8000024c:	7a42                	ld	s4,48(sp)
    8000024e:	7aa2                	ld	s5,40(sp)
    80000250:	7b02                	ld	s6,32(sp)
    80000252:	6125                	add	sp,sp,96
    80000254:	8082                	ret
      if(n < target){
    80000256:	0009871b          	sext.w	a4,s3
    8000025a:	01677a63          	bgeu	a4,s6,8000026e <consoleread+0x100>
        cons.r--;
    8000025e:	00011717          	auipc	a4,0x11
    80000262:	faf72d23          	sw	a5,-70(a4) # 80011218 <cons+0x98>
    80000266:	6be2                	ld	s7,24(sp)
    80000268:	a031                	j	80000274 <consoleread+0x106>
    8000026a:	ec5e                	sd	s7,24(sp)
    8000026c:	bf9d                	j	800001e2 <consoleread+0x74>
    8000026e:	6be2                	ld	s7,24(sp)
    80000270:	a011                	j	80000274 <consoleread+0x106>
    80000272:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000274:	00011517          	auipc	a0,0x11
    80000278:	f0c50513          	add	a0,a0,-244 # 80011180 <cons>
    8000027c:	00001097          	auipc	ra,0x1
    80000280:	a6a080e7          	jalr	-1430(ra) # 80000ce6 <release>
  return target - n;
    80000284:	413b053b          	subw	a0,s6,s3
    80000288:	bf6d                	j	80000242 <consoleread+0xd4>
    8000028a:	6be2                	ld	s7,24(sp)
    8000028c:	b7e5                	j	80000274 <consoleread+0x106>

000000008000028e <consputc>:
{
    8000028e:	1141                	add	sp,sp,-16
    80000290:	e406                	sd	ra,8(sp)
    80000292:	e022                	sd	s0,0(sp)
    80000294:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    80000296:	10000793          	li	a5,256
    8000029a:	00f50a63          	beq	a0,a5,800002ae <consputc+0x20>
    uartputc_sync(c);
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	59c080e7          	jalr	1436(ra) # 8000083a <uartputc_sync>
}
    800002a6:	60a2                	ld	ra,8(sp)
    800002a8:	6402                	ld	s0,0(sp)
    800002aa:	0141                	add	sp,sp,16
    800002ac:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	58a080e7          	jalr	1418(ra) # 8000083a <uartputc_sync>
    800002b8:	02000513          	li	a0,32
    800002bc:	00000097          	auipc	ra,0x0
    800002c0:	57e080e7          	jalr	1406(ra) # 8000083a <uartputc_sync>
    800002c4:	4521                	li	a0,8
    800002c6:	00000097          	auipc	ra,0x0
    800002ca:	574080e7          	jalr	1396(ra) # 8000083a <uartputc_sync>
    800002ce:	bfe1                	j	800002a6 <consputc+0x18>

00000000800002d0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002d0:	1101                	add	sp,sp,-32
    800002d2:	ec06                	sd	ra,24(sp)
    800002d4:	e822                	sd	s0,16(sp)
    800002d6:	e426                	sd	s1,8(sp)
    800002d8:	1000                	add	s0,sp,32
    800002da:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002dc:	00011517          	auipc	a0,0x11
    800002e0:	ea450513          	add	a0,a0,-348 # 80011180 <cons>
    800002e4:	00001097          	auipc	ra,0x1
    800002e8:	94e080e7          	jalr	-1714(ra) # 80000c32 <acquire>

  switch(c){
    800002ec:	47d5                	li	a5,21
    800002ee:	0af48563          	beq	s1,a5,80000398 <consoleintr+0xc8>
    800002f2:	0297c963          	blt	a5,s1,80000324 <consoleintr+0x54>
    800002f6:	47a1                	li	a5,8
    800002f8:	0ef48c63          	beq	s1,a5,800003f0 <consoleintr+0x120>
    800002fc:	47c1                	li	a5,16
    800002fe:	10f49f63          	bne	s1,a5,8000041c <consoleintr+0x14c>
  case C('P'):  // Print process list.
    procdump();
    80000302:	00002097          	auipc	ra,0x2
    80000306:	244080e7          	jalr	580(ra) # 80002546 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    8000030a:	00011517          	auipc	a0,0x11
    8000030e:	e7650513          	add	a0,a0,-394 # 80011180 <cons>
    80000312:	00001097          	auipc	ra,0x1
    80000316:	9d4080e7          	jalr	-1580(ra) # 80000ce6 <release>
}
    8000031a:	60e2                	ld	ra,24(sp)
    8000031c:	6442                	ld	s0,16(sp)
    8000031e:	64a2                	ld	s1,8(sp)
    80000320:	6105                	add	sp,sp,32
    80000322:	8082                	ret
  switch(c){
    80000324:	07f00793          	li	a5,127
    80000328:	0cf48463          	beq	s1,a5,800003f0 <consoleintr+0x120>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000032c:	00011717          	auipc	a4,0x11
    80000330:	e5470713          	add	a4,a4,-428 # 80011180 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09872703          	lw	a4,152(a4)
    8000033c:	9f99                	subw	a5,a5,a4
    8000033e:	07f00713          	li	a4,127
    80000342:	fcf764e3          	bltu	a4,a5,8000030a <consoleintr+0x3a>
      c = (c == '\r') ? '\n' : c;
    80000346:	47b5                	li	a5,13
    80000348:	0cf48d63          	beq	s1,a5,80000422 <consoleintr+0x152>
      consputc(c);
    8000034c:	8526                	mv	a0,s1
    8000034e:	00000097          	auipc	ra,0x0
    80000352:	f40080e7          	jalr	-192(ra) # 8000028e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000356:	00011797          	auipc	a5,0x11
    8000035a:	e2a78793          	add	a5,a5,-470 # 80011180 <cons>
    8000035e:	0a07a703          	lw	a4,160(a5)
    80000362:	0017069b          	addw	a3,a4,1
    80000366:	0006861b          	sext.w	a2,a3
    8000036a:	0ad7a023          	sw	a3,160(a5)
    8000036e:	07f77713          	and	a4,a4,127
    80000372:	97ba                	add	a5,a5,a4
    80000374:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000378:	47a9                	li	a5,10
    8000037a:	0cf48b63          	beq	s1,a5,80000450 <consoleintr+0x180>
    8000037e:	4791                	li	a5,4
    80000380:	0cf48863          	beq	s1,a5,80000450 <consoleintr+0x180>
    80000384:	00011797          	auipc	a5,0x11
    80000388:	e947a783          	lw	a5,-364(a5) # 80011218 <cons+0x98>
    8000038c:	0807879b          	addw	a5,a5,128
    80000390:	f6f61de3          	bne	a2,a5,8000030a <consoleintr+0x3a>
    80000394:	863e                	mv	a2,a5
    80000396:	a86d                	j	80000450 <consoleintr+0x180>
    80000398:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000039a:	00011717          	auipc	a4,0x11
    8000039e:	de670713          	add	a4,a4,-538 # 80011180 <cons>
    800003a2:	0a072783          	lw	a5,160(a4)
    800003a6:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003aa:	00011497          	auipc	s1,0x11
    800003ae:	dd648493          	add	s1,s1,-554 # 80011180 <cons>
    while(cons.e != cons.w &&
    800003b2:	4929                	li	s2,10
    800003b4:	02f70a63          	beq	a4,a5,800003e8 <consoleintr+0x118>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003b8:	37fd                	addw	a5,a5,-1
    800003ba:	07f7f713          	and	a4,a5,127
    800003be:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003c0:	01874703          	lbu	a4,24(a4)
    800003c4:	03270463          	beq	a4,s2,800003ec <consoleintr+0x11c>
      cons.e--;
    800003c8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003cc:	10000513          	li	a0,256
    800003d0:	00000097          	auipc	ra,0x0
    800003d4:	ebe080e7          	jalr	-322(ra) # 8000028e <consputc>
    while(cons.e != cons.w &&
    800003d8:	0a04a783          	lw	a5,160(s1)
    800003dc:	09c4a703          	lw	a4,156(s1)
    800003e0:	fcf71ce3          	bne	a4,a5,800003b8 <consoleintr+0xe8>
    800003e4:	6902                	ld	s2,0(sp)
    800003e6:	b715                	j	8000030a <consoleintr+0x3a>
    800003e8:	6902                	ld	s2,0(sp)
    800003ea:	b705                	j	8000030a <consoleintr+0x3a>
    800003ec:	6902                	ld	s2,0(sp)
    800003ee:	bf31                	j	8000030a <consoleintr+0x3a>
    if(cons.e != cons.w){
    800003f0:	00011717          	auipc	a4,0x11
    800003f4:	d9070713          	add	a4,a4,-624 # 80011180 <cons>
    800003f8:	0a072783          	lw	a5,160(a4)
    800003fc:	09c72703          	lw	a4,156(a4)
    80000400:	f0f705e3          	beq	a4,a5,8000030a <consoleintr+0x3a>
      cons.e--;
    80000404:	37fd                	addw	a5,a5,-1
    80000406:	00011717          	auipc	a4,0x11
    8000040a:	e0f72d23          	sw	a5,-486(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    8000040e:	10000513          	li	a0,256
    80000412:	00000097          	auipc	ra,0x0
    80000416:	e7c080e7          	jalr	-388(ra) # 8000028e <consputc>
    8000041a:	bdc5                	j	8000030a <consoleintr+0x3a>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000041c:	ee0487e3          	beqz	s1,8000030a <consoleintr+0x3a>
    80000420:	b731                	j	8000032c <consoleintr+0x5c>
      consputc(c);
    80000422:	4529                	li	a0,10
    80000424:	00000097          	auipc	ra,0x0
    80000428:	e6a080e7          	jalr	-406(ra) # 8000028e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000042c:	00011797          	auipc	a5,0x11
    80000430:	d5478793          	add	a5,a5,-684 # 80011180 <cons>
    80000434:	0a07a703          	lw	a4,160(a5)
    80000438:	0017069b          	addw	a3,a4,1
    8000043c:	0006861b          	sext.w	a2,a3
    80000440:	0ad7a023          	sw	a3,160(a5)
    80000444:	07f77713          	and	a4,a4,127
    80000448:	97ba                	add	a5,a5,a4
    8000044a:	4729                	li	a4,10
    8000044c:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000450:	00011797          	auipc	a5,0x11
    80000454:	dcc7a623          	sw	a2,-564(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    80000458:	00011517          	auipc	a0,0x11
    8000045c:	dc050513          	add	a0,a0,-576 # 80011218 <cons+0x98>
    80000460:	00002097          	auipc	ra,0x2
    80000464:	e22080e7          	jalr	-478(ra) # 80002282 <wakeup>
    80000468:	b54d                	j	8000030a <consoleintr+0x3a>

000000008000046a <consoleinit>:

void
consoleinit(void)
{
    8000046a:	1141                	add	sp,sp,-16
    8000046c:	e406                	sd	ra,8(sp)
    8000046e:	e022                	sd	s0,0(sp)
    80000470:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    80000472:	00008597          	auipc	a1,0x8
    80000476:	b8e58593          	add	a1,a1,-1138 # 80008000 <etext>
    8000047a:	00011517          	auipc	a0,0x11
    8000047e:	d0650513          	add	a0,a0,-762 # 80011180 <cons>
    80000482:	00000097          	auipc	ra,0x0
    80000486:	720080e7          	jalr	1824(ra) # 80000ba2 <initlock>

  uartinit();
    8000048a:	00000097          	auipc	ra,0x0
    8000048e:	354080e7          	jalr	852(ra) # 800007de <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000492:	00021797          	auipc	a5,0x21
    80000496:	e8678793          	add	a5,a5,-378 # 80021318 <devsw>
    8000049a:	00000717          	auipc	a4,0x0
    8000049e:	cd470713          	add	a4,a4,-812 # 8000016e <consoleread>
    800004a2:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    800004a4:	00000717          	auipc	a4,0x0
    800004a8:	c5c70713          	add	a4,a4,-932 # 80000100 <consolewrite>
    800004ac:	ef98                	sd	a4,24(a5)
}
    800004ae:	60a2                	ld	ra,8(sp)
    800004b0:	6402                	ld	s0,0(sp)
    800004b2:	0141                	add	sp,sp,16
    800004b4:	8082                	ret

00000000800004b6 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004b6:	7179                	add	sp,sp,-48
    800004b8:	f406                	sd	ra,40(sp)
    800004ba:	f022                	sd	s0,32(sp)
    800004bc:	1800                	add	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004be:	c219                	beqz	a2,800004c4 <printint+0xe>
    800004c0:	08054963          	bltz	a0,80000552 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004c4:	2501                	sext.w	a0,a0
    800004c6:	4881                	li	a7,0
    800004c8:	fd040693          	add	a3,s0,-48

  i = 0;
    800004cc:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004ce:	2581                	sext.w	a1,a1
    800004d0:	00008617          	auipc	a2,0x8
    800004d4:	22860613          	add	a2,a2,552 # 800086f8 <digits>
    800004d8:	883a                	mv	a6,a4
    800004da:	2705                	addw	a4,a4,1
    800004dc:	02b577bb          	remuw	a5,a0,a1
    800004e0:	1782                	sll	a5,a5,0x20
    800004e2:	9381                	srl	a5,a5,0x20
    800004e4:	97b2                	add	a5,a5,a2
    800004e6:	0007c783          	lbu	a5,0(a5)
    800004ea:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004ee:	0005079b          	sext.w	a5,a0
    800004f2:	02b5553b          	divuw	a0,a0,a1
    800004f6:	0685                	add	a3,a3,1
    800004f8:	feb7f0e3          	bgeu	a5,a1,800004d8 <printint+0x22>

  if(sign)
    800004fc:	00088c63          	beqz	a7,80000514 <printint+0x5e>
    buf[i++] = '-';
    80000500:	fe070793          	add	a5,a4,-32
    80000504:	00878733          	add	a4,a5,s0
    80000508:	02d00793          	li	a5,45
    8000050c:	fef70823          	sb	a5,-16(a4)
    80000510:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    80000514:	02e05b63          	blez	a4,8000054a <printint+0x94>
    80000518:	ec26                	sd	s1,24(sp)
    8000051a:	e84a                	sd	s2,16(sp)
    8000051c:	fd040793          	add	a5,s0,-48
    80000520:	00e784b3          	add	s1,a5,a4
    80000524:	fff78913          	add	s2,a5,-1
    80000528:	993a                	add	s2,s2,a4
    8000052a:	377d                	addw	a4,a4,-1
    8000052c:	1702                	sll	a4,a4,0x20
    8000052e:	9301                	srl	a4,a4,0x20
    80000530:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000534:	fff4c503          	lbu	a0,-1(s1)
    80000538:	00000097          	auipc	ra,0x0
    8000053c:	d56080e7          	jalr	-682(ra) # 8000028e <consputc>
  while(--i >= 0)
    80000540:	14fd                	add	s1,s1,-1
    80000542:	ff2499e3          	bne	s1,s2,80000534 <printint+0x7e>
    80000546:	64e2                	ld	s1,24(sp)
    80000548:	6942                	ld	s2,16(sp)
}
    8000054a:	70a2                	ld	ra,40(sp)
    8000054c:	7402                	ld	s0,32(sp)
    8000054e:	6145                	add	sp,sp,48
    80000550:	8082                	ret
    x = -xx;
    80000552:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000556:	4885                	li	a7,1
    x = -xx;
    80000558:	bf85                	j	800004c8 <printint+0x12>

000000008000055a <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000055a:	1101                	add	sp,sp,-32
    8000055c:	ec06                	sd	ra,24(sp)
    8000055e:	e822                	sd	s0,16(sp)
    80000560:	e426                	sd	s1,8(sp)
    80000562:	1000                	add	s0,sp,32
    80000564:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000566:	00011797          	auipc	a5,0x11
    8000056a:	cc07ad23          	sw	zero,-806(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	a9a50513          	add	a0,a0,-1382 # 80008008 <etext+0x8>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	02e080e7          	jalr	46(ra) # 800005a4 <printf>
  printf(s);
    8000057e:	8526                	mv	a0,s1
    80000580:	00000097          	auipc	ra,0x0
    80000584:	024080e7          	jalr	36(ra) # 800005a4 <printf>
  printf("\n");
    80000588:	00008517          	auipc	a0,0x8
    8000058c:	a8850513          	add	a0,a0,-1400 # 80008010 <etext+0x10>
    80000590:	00000097          	auipc	ra,0x0
    80000594:	014080e7          	jalr	20(ra) # 800005a4 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000598:	4785                	li	a5,1
    8000059a:	00009717          	auipc	a4,0x9
    8000059e:	a6f72323          	sw	a5,-1434(a4) # 80009000 <panicked>
  for(;;)
    800005a2:	a001                	j	800005a2 <panic+0x48>

00000000800005a4 <printf>:
{
    800005a4:	7131                	add	sp,sp,-192
    800005a6:	fc86                	sd	ra,120(sp)
    800005a8:	f8a2                	sd	s0,112(sp)
    800005aa:	e8d2                	sd	s4,80(sp)
    800005ac:	f06a                	sd	s10,32(sp)
    800005ae:	0100                	add	s0,sp,128
    800005b0:	8a2a                	mv	s4,a0
    800005b2:	e40c                	sd	a1,8(s0)
    800005b4:	e810                	sd	a2,16(s0)
    800005b6:	ec14                	sd	a3,24(s0)
    800005b8:	f018                	sd	a4,32(s0)
    800005ba:	f41c                	sd	a5,40(s0)
    800005bc:	03043823          	sd	a6,48(s0)
    800005c0:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c4:	00011d17          	auipc	s10,0x11
    800005c8:	c7cd2d03          	lw	s10,-900(s10) # 80011240 <pr+0x18>
  if(locking)
    800005cc:	040d1463          	bnez	s10,80000614 <printf+0x70>
  if (fmt == 0)
    800005d0:	040a0b63          	beqz	s4,80000626 <printf+0x82>
  va_start(ap, fmt);
    800005d4:	00840793          	add	a5,s0,8
    800005d8:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005dc:	000a4503          	lbu	a0,0(s4)
    800005e0:	18050b63          	beqz	a0,80000776 <printf+0x1d2>
    800005e4:	f4a6                	sd	s1,104(sp)
    800005e6:	f0ca                	sd	s2,96(sp)
    800005e8:	ecce                	sd	s3,88(sp)
    800005ea:	e4d6                	sd	s5,72(sp)
    800005ec:	e0da                	sd	s6,64(sp)
    800005ee:	fc5e                	sd	s7,56(sp)
    800005f0:	f862                	sd	s8,48(sp)
    800005f2:	f466                	sd	s9,40(sp)
    800005f4:	ec6e                	sd	s11,24(sp)
    800005f6:	4981                	li	s3,0
    if(c != '%'){
    800005f8:	02500b13          	li	s6,37
    switch(c){
    800005fc:	07000b93          	li	s7,112
  consputc('x');
    80000600:	4cc1                	li	s9,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000602:	00008a97          	auipc	s5,0x8
    80000606:	0f6a8a93          	add	s5,s5,246 # 800086f8 <digits>
    switch(c){
    8000060a:	07300c13          	li	s8,115
    8000060e:	06400d93          	li	s11,100
    80000612:	a0b1                	j	8000065e <printf+0xba>
    acquire(&pr.lock);
    80000614:	00011517          	auipc	a0,0x11
    80000618:	c1450513          	add	a0,a0,-1004 # 80011228 <pr>
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	616080e7          	jalr	1558(ra) # 80000c32 <acquire>
    80000624:	b775                	j	800005d0 <printf+0x2c>
    80000626:	f4a6                	sd	s1,104(sp)
    80000628:	f0ca                	sd	s2,96(sp)
    8000062a:	ecce                	sd	s3,88(sp)
    8000062c:	e4d6                	sd	s5,72(sp)
    8000062e:	e0da                	sd	s6,64(sp)
    80000630:	fc5e                	sd	s7,56(sp)
    80000632:	f862                	sd	s8,48(sp)
    80000634:	f466                	sd	s9,40(sp)
    80000636:	ec6e                	sd	s11,24(sp)
    panic("null fmt");
    80000638:	00008517          	auipc	a0,0x8
    8000063c:	9e850513          	add	a0,a0,-1560 # 80008020 <etext+0x20>
    80000640:	00000097          	auipc	ra,0x0
    80000644:	f1a080e7          	jalr	-230(ra) # 8000055a <panic>
      consputc(c);
    80000648:	00000097          	auipc	ra,0x0
    8000064c:	c46080e7          	jalr	-954(ra) # 8000028e <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000650:	2985                	addw	s3,s3,1
    80000652:	013a07b3          	add	a5,s4,s3
    80000656:	0007c503          	lbu	a0,0(a5)
    8000065a:	10050563          	beqz	a0,80000764 <printf+0x1c0>
    if(c != '%'){
    8000065e:	ff6515e3          	bne	a0,s6,80000648 <printf+0xa4>
    c = fmt[++i] & 0xff;
    80000662:	2985                	addw	s3,s3,1
    80000664:	013a07b3          	add	a5,s4,s3
    80000668:	0007c783          	lbu	a5,0(a5)
    8000066c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000670:	10078b63          	beqz	a5,80000786 <printf+0x1e2>
    switch(c){
    80000674:	05778a63          	beq	a5,s7,800006c8 <printf+0x124>
    80000678:	02fbf663          	bgeu	s7,a5,800006a4 <printf+0x100>
    8000067c:	09878863          	beq	a5,s8,8000070c <printf+0x168>
    80000680:	07800713          	li	a4,120
    80000684:	0ce79563          	bne	a5,a4,8000074e <printf+0x1aa>
      printint(va_arg(ap, int), 16, 1);
    80000688:	f8843783          	ld	a5,-120(s0)
    8000068c:	00878713          	add	a4,a5,8
    80000690:	f8e43423          	sd	a4,-120(s0)
    80000694:	4605                	li	a2,1
    80000696:	85e6                	mv	a1,s9
    80000698:	4388                	lw	a0,0(a5)
    8000069a:	00000097          	auipc	ra,0x0
    8000069e:	e1c080e7          	jalr	-484(ra) # 800004b6 <printint>
      break;
    800006a2:	b77d                	j	80000650 <printf+0xac>
    switch(c){
    800006a4:	09678f63          	beq	a5,s6,80000742 <printf+0x19e>
    800006a8:	0bb79363          	bne	a5,s11,8000074e <printf+0x1aa>
      printint(va_arg(ap, int), 10, 1);
    800006ac:	f8843783          	ld	a5,-120(s0)
    800006b0:	00878713          	add	a4,a5,8
    800006b4:	f8e43423          	sd	a4,-120(s0)
    800006b8:	4605                	li	a2,1
    800006ba:	45a9                	li	a1,10
    800006bc:	4388                	lw	a0,0(a5)
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	df8080e7          	jalr	-520(ra) # 800004b6 <printint>
      break;
    800006c6:	b769                	j	80000650 <printf+0xac>
      printptr(va_arg(ap, uint64));
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	add	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006d8:	03000513          	li	a0,48
    800006dc:	00000097          	auipc	ra,0x0
    800006e0:	bb2080e7          	jalr	-1102(ra) # 8000028e <consputc>
  consputc('x');
    800006e4:	07800513          	li	a0,120
    800006e8:	00000097          	auipc	ra,0x0
    800006ec:	ba6080e7          	jalr	-1114(ra) # 8000028e <consputc>
    800006f0:	84e6                	mv	s1,s9
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006f2:	03c95793          	srl	a5,s2,0x3c
    800006f6:	97d6                	add	a5,a5,s5
    800006f8:	0007c503          	lbu	a0,0(a5)
    800006fc:	00000097          	auipc	ra,0x0
    80000700:	b92080e7          	jalr	-1134(ra) # 8000028e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000704:	0912                	sll	s2,s2,0x4
    80000706:	34fd                	addw	s1,s1,-1
    80000708:	f4ed                	bnez	s1,800006f2 <printf+0x14e>
    8000070a:	b799                	j	80000650 <printf+0xac>
      if((s = va_arg(ap, char*)) == 0)
    8000070c:	f8843783          	ld	a5,-120(s0)
    80000710:	00878713          	add	a4,a5,8
    80000714:	f8e43423          	sd	a4,-120(s0)
    80000718:	6384                	ld	s1,0(a5)
    8000071a:	cc89                	beqz	s1,80000734 <printf+0x190>
      for(; *s; s++)
    8000071c:	0004c503          	lbu	a0,0(s1)
    80000720:	d905                	beqz	a0,80000650 <printf+0xac>
        consputc(*s);
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b6c080e7          	jalr	-1172(ra) # 8000028e <consputc>
      for(; *s; s++)
    8000072a:	0485                	add	s1,s1,1
    8000072c:	0004c503          	lbu	a0,0(s1)
    80000730:	f96d                	bnez	a0,80000722 <printf+0x17e>
    80000732:	bf39                	j	80000650 <printf+0xac>
        s = "(null)";
    80000734:	00008497          	auipc	s1,0x8
    80000738:	8e448493          	add	s1,s1,-1820 # 80008018 <etext+0x18>
      for(; *s; s++)
    8000073c:	02800513          	li	a0,40
    80000740:	b7cd                	j	80000722 <printf+0x17e>
      consputc('%');
    80000742:	855a                	mv	a0,s6
    80000744:	00000097          	auipc	ra,0x0
    80000748:	b4a080e7          	jalr	-1206(ra) # 8000028e <consputc>
      break;
    8000074c:	b711                	j	80000650 <printf+0xac>
      consputc('%');
    8000074e:	855a                	mv	a0,s6
    80000750:	00000097          	auipc	ra,0x0
    80000754:	b3e080e7          	jalr	-1218(ra) # 8000028e <consputc>
      consputc(c);
    80000758:	8526                	mv	a0,s1
    8000075a:	00000097          	auipc	ra,0x0
    8000075e:	b34080e7          	jalr	-1228(ra) # 8000028e <consputc>
      break;
    80000762:	b5fd                	j	80000650 <printf+0xac>
    80000764:	74a6                	ld	s1,104(sp)
    80000766:	7906                	ld	s2,96(sp)
    80000768:	69e6                	ld	s3,88(sp)
    8000076a:	6aa6                	ld	s5,72(sp)
    8000076c:	6b06                	ld	s6,64(sp)
    8000076e:	7be2                	ld	s7,56(sp)
    80000770:	7c42                	ld	s8,48(sp)
    80000772:	7ca2                	ld	s9,40(sp)
    80000774:	6de2                	ld	s11,24(sp)
  if(locking)
    80000776:	020d1263          	bnez	s10,8000079a <printf+0x1f6>
}
    8000077a:	70e6                	ld	ra,120(sp)
    8000077c:	7446                	ld	s0,112(sp)
    8000077e:	6a46                	ld	s4,80(sp)
    80000780:	7d02                	ld	s10,32(sp)
    80000782:	6129                	add	sp,sp,192
    80000784:	8082                	ret
    80000786:	74a6                	ld	s1,104(sp)
    80000788:	7906                	ld	s2,96(sp)
    8000078a:	69e6                	ld	s3,88(sp)
    8000078c:	6aa6                	ld	s5,72(sp)
    8000078e:	6b06                	ld	s6,64(sp)
    80000790:	7be2                	ld	s7,56(sp)
    80000792:	7c42                	ld	s8,48(sp)
    80000794:	7ca2                	ld	s9,40(sp)
    80000796:	6de2                	ld	s11,24(sp)
    80000798:	bff9                	j	80000776 <printf+0x1d2>
    release(&pr.lock);
    8000079a:	00011517          	auipc	a0,0x11
    8000079e:	a8e50513          	add	a0,a0,-1394 # 80011228 <pr>
    800007a2:	00000097          	auipc	ra,0x0
    800007a6:	544080e7          	jalr	1348(ra) # 80000ce6 <release>
}
    800007aa:	bfc1                	j	8000077a <printf+0x1d6>

00000000800007ac <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ac:	1101                	add	sp,sp,-32
    800007ae:	ec06                	sd	ra,24(sp)
    800007b0:	e822                	sd	s0,16(sp)
    800007b2:	e426                	sd	s1,8(sp)
    800007b4:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    800007b6:	00011497          	auipc	s1,0x11
    800007ba:	a7248493          	add	s1,s1,-1422 # 80011228 <pr>
    800007be:	00008597          	auipc	a1,0x8
    800007c2:	87258593          	add	a1,a1,-1934 # 80008030 <etext+0x30>
    800007c6:	8526                	mv	a0,s1
    800007c8:	00000097          	auipc	ra,0x0
    800007cc:	3da080e7          	jalr	986(ra) # 80000ba2 <initlock>
  pr.locking = 1;
    800007d0:	4785                	li	a5,1
    800007d2:	cc9c                	sw	a5,24(s1)
}
    800007d4:	60e2                	ld	ra,24(sp)
    800007d6:	6442                	ld	s0,16(sp)
    800007d8:	64a2                	ld	s1,8(sp)
    800007da:	6105                	add	sp,sp,32
    800007dc:	8082                	ret

00000000800007de <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007de:	1141                	add	sp,sp,-16
    800007e0:	e406                	sd	ra,8(sp)
    800007e2:	e022                	sd	s0,0(sp)
    800007e4:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007e6:	100007b7          	lui	a5,0x10000
    800007ea:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ee:	10000737          	lui	a4,0x10000
    800007f2:	f8000693          	li	a3,-128
    800007f6:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007fa:	468d                	li	a3,3
    800007fc:	10000637          	lui	a2,0x10000
    80000800:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000804:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000808:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	461d                	li	a2,7
    80000812:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000816:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000081a:	00008597          	auipc	a1,0x8
    8000081e:	81e58593          	add	a1,a1,-2018 # 80008038 <etext+0x38>
    80000822:	00011517          	auipc	a0,0x11
    80000826:	a2650513          	add	a0,a0,-1498 # 80011248 <uart_tx_lock>
    8000082a:	00000097          	auipc	ra,0x0
    8000082e:	378080e7          	jalr	888(ra) # 80000ba2 <initlock>
}
    80000832:	60a2                	ld	ra,8(sp)
    80000834:	6402                	ld	s0,0(sp)
    80000836:	0141                	add	sp,sp,16
    80000838:	8082                	ret

000000008000083a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000083a:	1101                	add	sp,sp,-32
    8000083c:	ec06                	sd	ra,24(sp)
    8000083e:	e822                	sd	s0,16(sp)
    80000840:	e426                	sd	s1,8(sp)
    80000842:	1000                	add	s0,sp,32
    80000844:	84aa                	mv	s1,a0
  push_off();
    80000846:	00000097          	auipc	ra,0x0
    8000084a:	3a0080e7          	jalr	928(ra) # 80000be6 <push_off>

  if(panicked){
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	7b27a783          	lw	a5,1970(a5) # 80009000 <panicked>
    80000856:	eb85                	bnez	a5,80000886 <uartputc_sync+0x4c>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000858:	10000737          	lui	a4,0x10000
    8000085c:	0715                	add	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    8000085e:	00074783          	lbu	a5,0(a4)
    80000862:	0207f793          	and	a5,a5,32
    80000866:	dfe5                	beqz	a5,8000085e <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000868:	0ff4f513          	zext.b	a0,s1
    8000086c:	100007b7          	lui	a5,0x10000
    80000870:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000874:	00000097          	auipc	ra,0x0
    80000878:	412080e7          	jalr	1042(ra) # 80000c86 <pop_off>
}
    8000087c:	60e2                	ld	ra,24(sp)
    8000087e:	6442                	ld	s0,16(sp)
    80000880:	64a2                	ld	s1,8(sp)
    80000882:	6105                	add	sp,sp,32
    80000884:	8082                	ret
    for(;;)
    80000886:	a001                	j	80000886 <uartputc_sync+0x4c>

0000000080000888 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000888:	00008797          	auipc	a5,0x8
    8000088c:	7807b783          	ld	a5,1920(a5) # 80009008 <uart_tx_r>
    80000890:	00008717          	auipc	a4,0x8
    80000894:	78073703          	ld	a4,1920(a4) # 80009010 <uart_tx_w>
    80000898:	06f70f63          	beq	a4,a5,80000916 <uartstart+0x8e>
{
    8000089c:	7139                	add	sp,sp,-64
    8000089e:	fc06                	sd	ra,56(sp)
    800008a0:	f822                	sd	s0,48(sp)
    800008a2:	f426                	sd	s1,40(sp)
    800008a4:	f04a                	sd	s2,32(sp)
    800008a6:	ec4e                	sd	s3,24(sp)
    800008a8:	e852                	sd	s4,16(sp)
    800008aa:	e456                	sd	s5,8(sp)
    800008ac:	e05a                	sd	s6,0(sp)
    800008ae:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008b0:	10000937          	lui	s2,0x10000
    800008b4:	0915                	add	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008b6:	00011a97          	auipc	s5,0x11
    800008ba:	992a8a93          	add	s5,s5,-1646 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    800008be:	00008497          	auipc	s1,0x8
    800008c2:	74a48493          	add	s1,s1,1866 # 80009008 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008c6:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008ca:	00008997          	auipc	s3,0x8
    800008ce:	74698993          	add	s3,s3,1862 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008d2:	00094703          	lbu	a4,0(s2)
    800008d6:	02077713          	and	a4,a4,32
    800008da:	c705                	beqz	a4,80000902 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008dc:	01f7f713          	and	a4,a5,31
    800008e0:	9756                	add	a4,a4,s5
    800008e2:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008e6:	0785                	add	a5,a5,1
    800008e8:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008ea:	8526                	mv	a0,s1
    800008ec:	00002097          	auipc	ra,0x2
    800008f0:	996080e7          	jalr	-1642(ra) # 80002282 <wakeup>
    WriteReg(THR, c);
    800008f4:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    800008f8:	609c                	ld	a5,0(s1)
    800008fa:	0009b703          	ld	a4,0(s3)
    800008fe:	fcf71ae3          	bne	a4,a5,800008d2 <uartstart+0x4a>
  }
}
    80000902:	70e2                	ld	ra,56(sp)
    80000904:	7442                	ld	s0,48(sp)
    80000906:	74a2                	ld	s1,40(sp)
    80000908:	7902                	ld	s2,32(sp)
    8000090a:	69e2                	ld	s3,24(sp)
    8000090c:	6a42                	ld	s4,16(sp)
    8000090e:	6aa2                	ld	s5,8(sp)
    80000910:	6b02                	ld	s6,0(sp)
    80000912:	6121                	add	sp,sp,64
    80000914:	8082                	ret
    80000916:	8082                	ret

0000000080000918 <uartputc>:
{
    80000918:	7179                	add	sp,sp,-48
    8000091a:	f406                	sd	ra,40(sp)
    8000091c:	f022                	sd	s0,32(sp)
    8000091e:	e052                	sd	s4,0(sp)
    80000920:	1800                	add	s0,sp,48
    80000922:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80000924:	00011517          	auipc	a0,0x11
    80000928:	92450513          	add	a0,a0,-1756 # 80011248 <uart_tx_lock>
    8000092c:	00000097          	auipc	ra,0x0
    80000930:	306080e7          	jalr	774(ra) # 80000c32 <acquire>
  if(panicked){
    80000934:	00008797          	auipc	a5,0x8
    80000938:	6cc7a783          	lw	a5,1740(a5) # 80009000 <panicked>
    8000093c:	c391                	beqz	a5,80000940 <uartputc+0x28>
    for(;;)
    8000093e:	a001                	j	8000093e <uartputc+0x26>
    80000940:	ec26                	sd	s1,24(sp)
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000942:	00008717          	auipc	a4,0x8
    80000946:	6ce73703          	ld	a4,1742(a4) # 80009010 <uart_tx_w>
    8000094a:	00008797          	auipc	a5,0x8
    8000094e:	6be7b783          	ld	a5,1726(a5) # 80009008 <uart_tx_r>
    80000952:	02078793          	add	a5,a5,32
    80000956:	02e79f63          	bne	a5,a4,80000994 <uartputc+0x7c>
    8000095a:	e84a                	sd	s2,16(sp)
    8000095c:	e44e                	sd	s3,8(sp)
      sleep(&uart_tx_r, &uart_tx_lock);
    8000095e:	00011997          	auipc	s3,0x11
    80000962:	8ea98993          	add	s3,s3,-1814 # 80011248 <uart_tx_lock>
    80000966:	00008497          	auipc	s1,0x8
    8000096a:	6a248493          	add	s1,s1,1698 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000096e:	00008917          	auipc	s2,0x8
    80000972:	6a290913          	add	s2,s2,1698 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	85ce                	mv	a1,s3
    80000978:	8526                	mv	a0,s1
    8000097a:	00001097          	auipc	ra,0x1
    8000097e:	77c080e7          	jalr	1916(ra) # 800020f6 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000982:	00093703          	ld	a4,0(s2)
    80000986:	609c                	ld	a5,0(s1)
    80000988:	02078793          	add	a5,a5,32
    8000098c:	fee785e3          	beq	a5,a4,80000976 <uartputc+0x5e>
    80000990:	6942                	ld	s2,16(sp)
    80000992:	69a2                	ld	s3,8(sp)
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000994:	00011497          	auipc	s1,0x11
    80000998:	8b448493          	add	s1,s1,-1868 # 80011248 <uart_tx_lock>
    8000099c:	01f77793          	and	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    800009a6:	0705                	add	a4,a4,1
    800009a8:	00008797          	auipc	a5,0x8
    800009ac:	66e7b423          	sd	a4,1640(a5) # 80009010 <uart_tx_w>
      uartstart();
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ed8080e7          	jalr	-296(ra) # 80000888 <uartstart>
      release(&uart_tx_lock);
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	32c080e7          	jalr	812(ra) # 80000ce6 <release>
    800009c2:	64e2                	ld	s1,24(sp)
}
    800009c4:	70a2                	ld	ra,40(sp)
    800009c6:	7402                	ld	s0,32(sp)
    800009c8:	6a02                	ld	s4,0(sp)
    800009ca:	6145                	add	sp,sp,48
    800009cc:	8082                	ret

00000000800009ce <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009ce:	1141                	add	sp,sp,-16
    800009d0:	e422                	sd	s0,8(sp)
    800009d2:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	0795                	add	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009da:	0007c783          	lbu	a5,0(a5)
    800009de:	8b85                	and	a5,a5,1
    800009e0:	cb81                	beqz	a5,800009f0 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009e2:	100007b7          	lui	a5,0x10000
    800009e6:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009ea:	6422                	ld	s0,8(sp)
    800009ec:	0141                	add	sp,sp,16
    800009ee:	8082                	ret
    return -1;
    800009f0:	557d                	li	a0,-1
    800009f2:	bfe5                	j	800009ea <uartgetc+0x1c>

00000000800009f4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009f4:	1101                	add	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009fe:	54fd                	li	s1,-1
    80000a00:	a029                	j	80000a0a <uartintr+0x16>
      break;
    consoleintr(c);
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	8ce080e7          	jalr	-1842(ra) # 800002d0 <consoleintr>
    int c = uartgetc();
    80000a0a:	00000097          	auipc	ra,0x0
    80000a0e:	fc4080e7          	jalr	-60(ra) # 800009ce <uartgetc>
    if(c == -1)
    80000a12:	fe9518e3          	bne	a0,s1,80000a02 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a16:	00011497          	auipc	s1,0x11
    80000a1a:	83248493          	add	s1,s1,-1998 # 80011248 <uart_tx_lock>
    80000a1e:	8526                	mv	a0,s1
    80000a20:	00000097          	auipc	ra,0x0
    80000a24:	212080e7          	jalr	530(ra) # 80000c32 <acquire>
  uartstart();
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	e60080e7          	jalr	-416(ra) # 80000888 <uartstart>
  release(&uart_tx_lock);
    80000a30:	8526                	mv	a0,s1
    80000a32:	00000097          	auipc	ra,0x0
    80000a36:	2b4080e7          	jalr	692(ra) # 80000ce6 <release>
}
    80000a3a:	60e2                	ld	ra,24(sp)
    80000a3c:	6442                	ld	s0,16(sp)
    80000a3e:	64a2                	ld	s1,8(sp)
    80000a40:	6105                	add	sp,sp,32
    80000a42:	8082                	ret

0000000080000a44 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a44:	1101                	add	sp,sp,-32
    80000a46:	ec06                	sd	ra,24(sp)
    80000a48:	e822                	sd	s0,16(sp)
    80000a4a:	e426                	sd	s1,8(sp)
    80000a4c:	e04a                	sd	s2,0(sp)
    80000a4e:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a50:	03451793          	sll	a5,a0,0x34
    80000a54:	ebb9                	bnez	a5,80000aaa <kfree+0x66>
    80000a56:	84aa                	mv	s1,a0
    80000a58:	00025797          	auipc	a5,0x25
    80000a5c:	5a878793          	add	a5,a5,1448 # 80026000 <end>
    80000a60:	04f56563          	bltu	a0,a5,80000aaa <kfree+0x66>
    80000a64:	47c5                	li	a5,17
    80000a66:	07ee                	sll	a5,a5,0x1b
    80000a68:	04f57163          	bgeu	a0,a5,80000aaa <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6c:	6605                	lui	a2,0x1
    80000a6e:	4585                	li	a1,1
    80000a70:	00000097          	auipc	ra,0x0
    80000a74:	2be080e7          	jalr	702(ra) # 80000d2e <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a78:	00011917          	auipc	s2,0x11
    80000a7c:	80890913          	add	s2,s2,-2040 # 80011280 <kmem>
    80000a80:	854a                	mv	a0,s2
    80000a82:	00000097          	auipc	ra,0x0
    80000a86:	1b0080e7          	jalr	432(ra) # 80000c32 <acquire>
  r->next = kmem.freelist;
    80000a8a:	01893783          	ld	a5,24(s2)
    80000a8e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a90:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a94:	854a                	mv	a0,s2
    80000a96:	00000097          	auipc	ra,0x0
    80000a9a:	250080e7          	jalr	592(ra) # 80000ce6 <release>
}
    80000a9e:	60e2                	ld	ra,24(sp)
    80000aa0:	6442                	ld	s0,16(sp)
    80000aa2:	64a2                	ld	s1,8(sp)
    80000aa4:	6902                	ld	s2,0(sp)
    80000aa6:	6105                	add	sp,sp,32
    80000aa8:	8082                	ret
    panic("kfree");
    80000aaa:	00007517          	auipc	a0,0x7
    80000aae:	59650513          	add	a0,a0,1430 # 80008040 <etext+0x40>
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	aa8080e7          	jalr	-1368(ra) # 8000055a <panic>

0000000080000aba <freerange>:
{
    80000aba:	7179                	add	sp,sp,-48
    80000abc:	f406                	sd	ra,40(sp)
    80000abe:	f022                	sd	s0,32(sp)
    80000ac0:	ec26                	sd	s1,24(sp)
    80000ac2:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ac4:	6785                	lui	a5,0x1
    80000ac6:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000aca:	00e504b3          	add	s1,a0,a4
    80000ace:	777d                	lui	a4,0xfffff
    80000ad0:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad2:	94be                	add	s1,s1,a5
    80000ad4:	0295e463          	bltu	a1,s1,80000afc <freerange+0x42>
    80000ad8:	e84a                	sd	s2,16(sp)
    80000ada:	e44e                	sd	s3,8(sp)
    80000adc:	e052                	sd	s4,0(sp)
    80000ade:	892e                	mv	s2,a1
    kfree(p);
    80000ae0:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ae2:	6985                	lui	s3,0x1
    kfree(p);
    80000ae4:	01448533          	add	a0,s1,s4
    80000ae8:	00000097          	auipc	ra,0x0
    80000aec:	f5c080e7          	jalr	-164(ra) # 80000a44 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000af0:	94ce                	add	s1,s1,s3
    80000af2:	fe9979e3          	bgeu	s2,s1,80000ae4 <freerange+0x2a>
    80000af6:	6942                	ld	s2,16(sp)
    80000af8:	69a2                	ld	s3,8(sp)
    80000afa:	6a02                	ld	s4,0(sp)
}
    80000afc:	70a2                	ld	ra,40(sp)
    80000afe:	7402                	ld	s0,32(sp)
    80000b00:	64e2                	ld	s1,24(sp)
    80000b02:	6145                	add	sp,sp,48
    80000b04:	8082                	ret

0000000080000b06 <kinit>:
{
    80000b06:	1141                	add	sp,sp,-16
    80000b08:	e406                	sd	ra,8(sp)
    80000b0a:	e022                	sd	s0,0(sp)
    80000b0c:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b0e:	00007597          	auipc	a1,0x7
    80000b12:	53a58593          	add	a1,a1,1338 # 80008048 <etext+0x48>
    80000b16:	00010517          	auipc	a0,0x10
    80000b1a:	76a50513          	add	a0,a0,1898 # 80011280 <kmem>
    80000b1e:	00000097          	auipc	ra,0x0
    80000b22:	084080e7          	jalr	132(ra) # 80000ba2 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b26:	45c5                	li	a1,17
    80000b28:	05ee                	sll	a1,a1,0x1b
    80000b2a:	00025517          	auipc	a0,0x25
    80000b2e:	4d650513          	add	a0,a0,1238 # 80026000 <end>
    80000b32:	00000097          	auipc	ra,0x0
    80000b36:	f88080e7          	jalr	-120(ra) # 80000aba <freerange>
}
    80000b3a:	60a2                	ld	ra,8(sp)
    80000b3c:	6402                	ld	s0,0(sp)
    80000b3e:	0141                	add	sp,sp,16
    80000b40:	8082                	ret

0000000080000b42 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b42:	1101                	add	sp,sp,-32
    80000b44:	ec06                	sd	ra,24(sp)
    80000b46:	e822                	sd	s0,16(sp)
    80000b48:	e426                	sd	s1,8(sp)
    80000b4a:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b4c:	00010497          	auipc	s1,0x10
    80000b50:	73448493          	add	s1,s1,1844 # 80011280 <kmem>
    80000b54:	8526                	mv	a0,s1
    80000b56:	00000097          	auipc	ra,0x0
    80000b5a:	0dc080e7          	jalr	220(ra) # 80000c32 <acquire>
  r = kmem.freelist;
    80000b5e:	6c84                	ld	s1,24(s1)
  if(r)
    80000b60:	c885                	beqz	s1,80000b90 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b62:	609c                	ld	a5,0(s1)
    80000b64:	00010517          	auipc	a0,0x10
    80000b68:	71c50513          	add	a0,a0,1820 # 80011280 <kmem>
    80000b6c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b6e:	00000097          	auipc	ra,0x0
    80000b72:	178080e7          	jalr	376(ra) # 80000ce6 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b76:	6605                	lui	a2,0x1
    80000b78:	4595                	li	a1,5
    80000b7a:	8526                	mv	a0,s1
    80000b7c:	00000097          	auipc	ra,0x0
    80000b80:	1b2080e7          	jalr	434(ra) # 80000d2e <memset>
  return (void*)r;
}
    80000b84:	8526                	mv	a0,s1
    80000b86:	60e2                	ld	ra,24(sp)
    80000b88:	6442                	ld	s0,16(sp)
    80000b8a:	64a2                	ld	s1,8(sp)
    80000b8c:	6105                	add	sp,sp,32
    80000b8e:	8082                	ret
  release(&kmem.lock);
    80000b90:	00010517          	auipc	a0,0x10
    80000b94:	6f050513          	add	a0,a0,1776 # 80011280 <kmem>
    80000b98:	00000097          	auipc	ra,0x0
    80000b9c:	14e080e7          	jalr	334(ra) # 80000ce6 <release>
  if(r)
    80000ba0:	b7d5                	j	80000b84 <kalloc+0x42>

0000000080000ba2 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000ba2:	1141                	add	sp,sp,-16
    80000ba4:	e422                	sd	s0,8(sp)
    80000ba6:	0800                	add	s0,sp,16
  lk->name = name;
    80000ba8:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000baa:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bae:	00053823          	sd	zero,16(a0)
}
    80000bb2:	6422                	ld	s0,8(sp)
    80000bb4:	0141                	add	sp,sp,16
    80000bb6:	8082                	ret

0000000080000bb8 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bb8:	411c                	lw	a5,0(a0)
    80000bba:	e399                	bnez	a5,80000bc0 <holding+0x8>
    80000bbc:	4501                	li	a0,0
  return r;
}
    80000bbe:	8082                	ret
{
    80000bc0:	1101                	add	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bca:	6904                	ld	s1,16(a0)
    80000bcc:	00001097          	auipc	ra,0x1
    80000bd0:	e48080e7          	jalr	-440(ra) # 80001a14 <mycpu>
    80000bd4:	40a48533          	sub	a0,s1,a0
    80000bd8:	00153513          	seqz	a0,a0
}
    80000bdc:	60e2                	ld	ra,24(sp)
    80000bde:	6442                	ld	s0,16(sp)
    80000be0:	64a2                	ld	s1,8(sp)
    80000be2:	6105                	add	sp,sp,32
    80000be4:	8082                	ret

0000000080000be6 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000be6:	1101                	add	sp,sp,-32
    80000be8:	ec06                	sd	ra,24(sp)
    80000bea:	e822                	sd	s0,16(sp)
    80000bec:	e426                	sd	s1,8(sp)
    80000bee:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf0:	100024f3          	csrr	s1,sstatus
    80000bf4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bf8:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bfa:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bfe:	00001097          	auipc	ra,0x1
    80000c02:	e16080e7          	jalr	-490(ra) # 80001a14 <mycpu>
    80000c06:	5d3c                	lw	a5,120(a0)
    80000c08:	cf89                	beqz	a5,80000c22 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c0a:	00001097          	auipc	ra,0x1
    80000c0e:	e0a080e7          	jalr	-502(ra) # 80001a14 <mycpu>
    80000c12:	5d3c                	lw	a5,120(a0)
    80000c14:	2785                	addw	a5,a5,1
    80000c16:	dd3c                	sw	a5,120(a0)
}
    80000c18:	60e2                	ld	ra,24(sp)
    80000c1a:	6442                	ld	s0,16(sp)
    80000c1c:	64a2                	ld	s1,8(sp)
    80000c1e:	6105                	add	sp,sp,32
    80000c20:	8082                	ret
    mycpu()->intena = old;
    80000c22:	00001097          	auipc	ra,0x1
    80000c26:	df2080e7          	jalr	-526(ra) # 80001a14 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c2a:	8085                	srl	s1,s1,0x1
    80000c2c:	8885                	and	s1,s1,1
    80000c2e:	dd64                	sw	s1,124(a0)
    80000c30:	bfe9                	j	80000c0a <push_off+0x24>

0000000080000c32 <acquire>:
{
    80000c32:	1101                	add	sp,sp,-32
    80000c34:	ec06                	sd	ra,24(sp)
    80000c36:	e822                	sd	s0,16(sp)
    80000c38:	e426                	sd	s1,8(sp)
    80000c3a:	1000                	add	s0,sp,32
    80000c3c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c3e:	00000097          	auipc	ra,0x0
    80000c42:	fa8080e7          	jalr	-88(ra) # 80000be6 <push_off>
  if(holding(lk))
    80000c46:	8526                	mv	a0,s1
    80000c48:	00000097          	auipc	ra,0x0
    80000c4c:	f70080e7          	jalr	-144(ra) # 80000bb8 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c50:	4705                	li	a4,1
  if(holding(lk))
    80000c52:	e115                	bnez	a0,80000c76 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c54:	87ba                	mv	a5,a4
    80000c56:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c5a:	2781                	sext.w	a5,a5
    80000c5c:	ffe5                	bnez	a5,80000c54 <acquire+0x22>
  __sync_synchronize();
    80000c5e:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c62:	00001097          	auipc	ra,0x1
    80000c66:	db2080e7          	jalr	-590(ra) # 80001a14 <mycpu>
    80000c6a:	e888                	sd	a0,16(s1)
}
    80000c6c:	60e2                	ld	ra,24(sp)
    80000c6e:	6442                	ld	s0,16(sp)
    80000c70:	64a2                	ld	s1,8(sp)
    80000c72:	6105                	add	sp,sp,32
    80000c74:	8082                	ret
    panic("acquire");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	3da50513          	add	a0,a0,986 # 80008050 <etext+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8dc080e7          	jalr	-1828(ra) # 8000055a <panic>

0000000080000c86 <pop_off>:

void
pop_off(void)
{
    80000c86:	1141                	add	sp,sp,-16
    80000c88:	e406                	sd	ra,8(sp)
    80000c8a:	e022                	sd	s0,0(sp)
    80000c8c:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c8e:	00001097          	auipc	ra,0x1
    80000c92:	d86080e7          	jalr	-634(ra) # 80001a14 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c96:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c9a:	8b89                	and	a5,a5,2
  if(intr_get())
    80000c9c:	e78d                	bnez	a5,80000cc6 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c9e:	5d3c                	lw	a5,120(a0)
    80000ca0:	02f05b63          	blez	a5,80000cd6 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000ca4:	37fd                	addw	a5,a5,-1
    80000ca6:	0007871b          	sext.w	a4,a5
    80000caa:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cac:	eb09                	bnez	a4,80000cbe <pop_off+0x38>
    80000cae:	5d7c                	lw	a5,124(a0)
    80000cb0:	c799                	beqz	a5,80000cbe <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cb6:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cba:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cbe:	60a2                	ld	ra,8(sp)
    80000cc0:	6402                	ld	s0,0(sp)
    80000cc2:	0141                	add	sp,sp,16
    80000cc4:	8082                	ret
    panic("pop_off - interruptible");
    80000cc6:	00007517          	auipc	a0,0x7
    80000cca:	39250513          	add	a0,a0,914 # 80008058 <etext+0x58>
    80000cce:	00000097          	auipc	ra,0x0
    80000cd2:	88c080e7          	jalr	-1908(ra) # 8000055a <panic>
    panic("pop_off");
    80000cd6:	00007517          	auipc	a0,0x7
    80000cda:	39a50513          	add	a0,a0,922 # 80008070 <etext+0x70>
    80000cde:	00000097          	auipc	ra,0x0
    80000ce2:	87c080e7          	jalr	-1924(ra) # 8000055a <panic>

0000000080000ce6 <release>:
{
    80000ce6:	1101                	add	sp,sp,-32
    80000ce8:	ec06                	sd	ra,24(sp)
    80000cea:	e822                	sd	s0,16(sp)
    80000cec:	e426                	sd	s1,8(sp)
    80000cee:	1000                	add	s0,sp,32
    80000cf0:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cf2:	00000097          	auipc	ra,0x0
    80000cf6:	ec6080e7          	jalr	-314(ra) # 80000bb8 <holding>
    80000cfa:	c115                	beqz	a0,80000d1e <release+0x38>
  lk->cpu = 0;
    80000cfc:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d00:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d04:	0f50000f          	fence	iorw,ow
    80000d08:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d0c:	00000097          	auipc	ra,0x0
    80000d10:	f7a080e7          	jalr	-134(ra) # 80000c86 <pop_off>
}
    80000d14:	60e2                	ld	ra,24(sp)
    80000d16:	6442                	ld	s0,16(sp)
    80000d18:	64a2                	ld	s1,8(sp)
    80000d1a:	6105                	add	sp,sp,32
    80000d1c:	8082                	ret
    panic("release");
    80000d1e:	00007517          	auipc	a0,0x7
    80000d22:	35a50513          	add	a0,a0,858 # 80008078 <etext+0x78>
    80000d26:	00000097          	auipc	ra,0x0
    80000d2a:	834080e7          	jalr	-1996(ra) # 8000055a <panic>

0000000080000d2e <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d2e:	1141                	add	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d34:	ca19                	beqz	a2,80000d4a <memset+0x1c>
    80000d36:	87aa                	mv	a5,a0
    80000d38:	1602                	sll	a2,a2,0x20
    80000d3a:	9201                	srl	a2,a2,0x20
    80000d3c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d40:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d44:	0785                	add	a5,a5,1
    80000d46:	fee79de3          	bne	a5,a4,80000d40 <memset+0x12>
  }
  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	add	sp,sp,16
    80000d4e:	8082                	ret

0000000080000d50 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d50:	1141                	add	sp,sp,-16
    80000d52:	e422                	sd	s0,8(sp)
    80000d54:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d56:	ca05                	beqz	a2,80000d86 <memcmp+0x36>
    80000d58:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d5c:	1682                	sll	a3,a3,0x20
    80000d5e:	9281                	srl	a3,a3,0x20
    80000d60:	0685                	add	a3,a3,1
    80000d62:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d64:	00054783          	lbu	a5,0(a0)
    80000d68:	0005c703          	lbu	a4,0(a1)
    80000d6c:	00e79863          	bne	a5,a4,80000d7c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d70:	0505                	add	a0,a0,1
    80000d72:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000d74:	fed518e3          	bne	a0,a3,80000d64 <memcmp+0x14>
  }

  return 0;
    80000d78:	4501                	li	a0,0
    80000d7a:	a019                	j	80000d80 <memcmp+0x30>
      return *s1 - *s2;
    80000d7c:	40e7853b          	subw	a0,a5,a4
}
    80000d80:	6422                	ld	s0,8(sp)
    80000d82:	0141                	add	sp,sp,16
    80000d84:	8082                	ret
  return 0;
    80000d86:	4501                	li	a0,0
    80000d88:	bfe5                	j	80000d80 <memcmp+0x30>

0000000080000d8a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	add	sp,sp,-16
    80000d8c:	e422                	sd	s0,8(sp)
    80000d8e:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d90:	c205                	beqz	a2,80000db0 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d92:	02a5e263          	bltu	a1,a0,80000db6 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d96:	1602                	sll	a2,a2,0x20
    80000d98:	9201                	srl	a2,a2,0x20
    80000d9a:	00c587b3          	add	a5,a1,a2
{
    80000d9e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000da0:	0585                	add	a1,a1,1
    80000da2:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd9001>
    80000da4:	fff5c683          	lbu	a3,-1(a1)
    80000da8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000dac:	feb79ae3          	bne	a5,a1,80000da0 <memmove+0x16>

  return dst;
}
    80000db0:	6422                	ld	s0,8(sp)
    80000db2:	0141                	add	sp,sp,16
    80000db4:	8082                	ret
  if(s < d && s + n > d){
    80000db6:	02061693          	sll	a3,a2,0x20
    80000dba:	9281                	srl	a3,a3,0x20
    80000dbc:	00d58733          	add	a4,a1,a3
    80000dc0:	fce57be3          	bgeu	a0,a4,80000d96 <memmove+0xc>
    d += n;
    80000dc4:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dc6:	fff6079b          	addw	a5,a2,-1
    80000dca:	1782                	sll	a5,a5,0x20
    80000dcc:	9381                	srl	a5,a5,0x20
    80000dce:	fff7c793          	not	a5,a5
    80000dd2:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dd4:	177d                	add	a4,a4,-1
    80000dd6:	16fd                	add	a3,a3,-1
    80000dd8:	00074603          	lbu	a2,0(a4)
    80000ddc:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000de0:	fef71ae3          	bne	a4,a5,80000dd4 <memmove+0x4a>
    80000de4:	b7f1                	j	80000db0 <memmove+0x26>

0000000080000de6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000de6:	1141                	add	sp,sp,-16
    80000de8:	e406                	sd	ra,8(sp)
    80000dea:	e022                	sd	s0,0(sp)
    80000dec:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000dee:	00000097          	auipc	ra,0x0
    80000df2:	f9c080e7          	jalr	-100(ra) # 80000d8a <memmove>
}
    80000df6:	60a2                	ld	ra,8(sp)
    80000df8:	6402                	ld	s0,0(sp)
    80000dfa:	0141                	add	sp,sp,16
    80000dfc:	8082                	ret

0000000080000dfe <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dfe:	1141                	add	sp,sp,-16
    80000e00:	e422                	sd	s0,8(sp)
    80000e02:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e04:	ce11                	beqz	a2,80000e20 <strncmp+0x22>
    80000e06:	00054783          	lbu	a5,0(a0)
    80000e0a:	cf89                	beqz	a5,80000e24 <strncmp+0x26>
    80000e0c:	0005c703          	lbu	a4,0(a1)
    80000e10:	00f71a63          	bne	a4,a5,80000e24 <strncmp+0x26>
    n--, p++, q++;
    80000e14:	367d                	addw	a2,a2,-1
    80000e16:	0505                	add	a0,a0,1
    80000e18:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e1a:	f675                	bnez	a2,80000e06 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e1c:	4501                	li	a0,0
    80000e1e:	a801                	j	80000e2e <strncmp+0x30>
    80000e20:	4501                	li	a0,0
    80000e22:	a031                	j	80000e2e <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000e24:	00054503          	lbu	a0,0(a0)
    80000e28:	0005c783          	lbu	a5,0(a1)
    80000e2c:	9d1d                	subw	a0,a0,a5
}
    80000e2e:	6422                	ld	s0,8(sp)
    80000e30:	0141                	add	sp,sp,16
    80000e32:	8082                	ret

0000000080000e34 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e34:	1141                	add	sp,sp,-16
    80000e36:	e422                	sd	s0,8(sp)
    80000e38:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e3a:	87aa                	mv	a5,a0
    80000e3c:	86b2                	mv	a3,a2
    80000e3e:	367d                	addw	a2,a2,-1
    80000e40:	02d05563          	blez	a3,80000e6a <strncpy+0x36>
    80000e44:	0785                	add	a5,a5,1
    80000e46:	0005c703          	lbu	a4,0(a1)
    80000e4a:	fee78fa3          	sb	a4,-1(a5)
    80000e4e:	0585                	add	a1,a1,1
    80000e50:	f775                	bnez	a4,80000e3c <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e52:	873e                	mv	a4,a5
    80000e54:	9fb5                	addw	a5,a5,a3
    80000e56:	37fd                	addw	a5,a5,-1
    80000e58:	00c05963          	blez	a2,80000e6a <strncpy+0x36>
    *s++ = 0;
    80000e5c:	0705                	add	a4,a4,1
    80000e5e:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e62:	40e786bb          	subw	a3,a5,a4
    80000e66:	fed04be3          	bgtz	a3,80000e5c <strncpy+0x28>
  return os;
}
    80000e6a:	6422                	ld	s0,8(sp)
    80000e6c:	0141                	add	sp,sp,16
    80000e6e:	8082                	ret

0000000080000e70 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e70:	1141                	add	sp,sp,-16
    80000e72:	e422                	sd	s0,8(sp)
    80000e74:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e76:	02c05363          	blez	a2,80000e9c <safestrcpy+0x2c>
    80000e7a:	fff6069b          	addw	a3,a2,-1
    80000e7e:	1682                	sll	a3,a3,0x20
    80000e80:	9281                	srl	a3,a3,0x20
    80000e82:	96ae                	add	a3,a3,a1
    80000e84:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e86:	00d58963          	beq	a1,a3,80000e98 <safestrcpy+0x28>
    80000e8a:	0585                	add	a1,a1,1
    80000e8c:	0785                	add	a5,a5,1
    80000e8e:	fff5c703          	lbu	a4,-1(a1)
    80000e92:	fee78fa3          	sb	a4,-1(a5)
    80000e96:	fb65                	bnez	a4,80000e86 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e98:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e9c:	6422                	ld	s0,8(sp)
    80000e9e:	0141                	add	sp,sp,16
    80000ea0:	8082                	ret

0000000080000ea2 <strlen>:

int
strlen(const char *s)
{
    80000ea2:	1141                	add	sp,sp,-16
    80000ea4:	e422                	sd	s0,8(sp)
    80000ea6:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ea8:	00054783          	lbu	a5,0(a0)
    80000eac:	cf91                	beqz	a5,80000ec8 <strlen+0x26>
    80000eae:	0505                	add	a0,a0,1
    80000eb0:	87aa                	mv	a5,a0
    80000eb2:	86be                	mv	a3,a5
    80000eb4:	0785                	add	a5,a5,1
    80000eb6:	fff7c703          	lbu	a4,-1(a5)
    80000eba:	ff65                	bnez	a4,80000eb2 <strlen+0x10>
    80000ebc:	40a6853b          	subw	a0,a3,a0
    80000ec0:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000ec2:	6422                	ld	s0,8(sp)
    80000ec4:	0141                	add	sp,sp,16
    80000ec6:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ec8:	4501                	li	a0,0
    80000eca:	bfe5                	j	80000ec2 <strlen+0x20>

0000000080000ecc <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ecc:	1141                	add	sp,sp,-16
    80000ece:	e406                	sd	ra,8(sp)
    80000ed0:	e022                	sd	s0,0(sp)
    80000ed2:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000ed4:	00001097          	auipc	ra,0x1
    80000ed8:	b30080e7          	jalr	-1232(ra) # 80001a04 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000edc:	00008717          	auipc	a4,0x8
    80000ee0:	13c70713          	add	a4,a4,316 # 80009018 <started>
  if(cpuid() == 0){
    80000ee4:	c139                	beqz	a0,80000f2a <main+0x5e>
    while(started == 0)
    80000ee6:	431c                	lw	a5,0(a4)
    80000ee8:	2781                	sext.w	a5,a5
    80000eea:	dff5                	beqz	a5,80000ee6 <main+0x1a>
      ;
    __sync_synchronize();
    80000eec:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ef0:	00001097          	auipc	ra,0x1
    80000ef4:	b14080e7          	jalr	-1260(ra) # 80001a04 <cpuid>
    80000ef8:	85aa                	mv	a1,a0
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	19e50513          	add	a0,a0,414 # 80008098 <etext+0x98>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	6a2080e7          	jalr	1698(ra) # 800005a4 <printf>
    kvminithart();    // turn on paging
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	0d8080e7          	jalr	216(ra) # 80000fe2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f12:	00001097          	auipc	ra,0x1
    80000f16:	776080e7          	jalr	1910(ra) # 80002688 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f1a:	00005097          	auipc	ra,0x5
    80000f1e:	d9a080e7          	jalr	-614(ra) # 80005cb4 <plicinithart>
  }

  scheduler();        
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	022080e7          	jalr	34(ra) # 80001f44 <scheduler>
    consoleinit();
    80000f2a:	fffff097          	auipc	ra,0xfffff
    80000f2e:	540080e7          	jalr	1344(ra) # 8000046a <consoleinit>
    printfinit();
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	87a080e7          	jalr	-1926(ra) # 800007ac <printfinit>
    printf("\n");
    80000f3a:	00007517          	auipc	a0,0x7
    80000f3e:	0d650513          	add	a0,a0,214 # 80008010 <etext+0x10>
    80000f42:	fffff097          	auipc	ra,0xfffff
    80000f46:	662080e7          	jalr	1634(ra) # 800005a4 <printf>
    printf("xv6 kernel is booting\n");
    80000f4a:	00007517          	auipc	a0,0x7
    80000f4e:	13650513          	add	a0,a0,310 # 80008080 <etext+0x80>
    80000f52:	fffff097          	auipc	ra,0xfffff
    80000f56:	652080e7          	jalr	1618(ra) # 800005a4 <printf>
    printf("\n");
    80000f5a:	00007517          	auipc	a0,0x7
    80000f5e:	0b650513          	add	a0,a0,182 # 80008010 <etext+0x10>
    80000f62:	fffff097          	auipc	ra,0xfffff
    80000f66:	642080e7          	jalr	1602(ra) # 800005a4 <printf>
    kinit();         // physical page allocator
    80000f6a:	00000097          	auipc	ra,0x0
    80000f6e:	b9c080e7          	jalr	-1124(ra) # 80000b06 <kinit>
    kvminit();       // create kernel page table
    80000f72:	00000097          	auipc	ra,0x0
    80000f76:	322080e7          	jalr	802(ra) # 80001294 <kvminit>
    kvminithart();   // turn on paging
    80000f7a:	00000097          	auipc	ra,0x0
    80000f7e:	068080e7          	jalr	104(ra) # 80000fe2 <kvminithart>
    procinit();      // process table
    80000f82:	00001097          	auipc	ra,0x1
    80000f86:	9c4080e7          	jalr	-1596(ra) # 80001946 <procinit>
    trapinit();      // trap vectors
    80000f8a:	00001097          	auipc	ra,0x1
    80000f8e:	6d6080e7          	jalr	1750(ra) # 80002660 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	6f6080e7          	jalr	1782(ra) # 80002688 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9a:	00005097          	auipc	ra,0x5
    80000f9e:	d00080e7          	jalr	-768(ra) # 80005c9a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa2:	00005097          	auipc	ra,0x5
    80000fa6:	d12080e7          	jalr	-750(ra) # 80005cb4 <plicinithart>
    binit();         // buffer cache
    80000faa:	00002097          	auipc	ra,0x2
    80000fae:	e30080e7          	jalr	-464(ra) # 80002dda <binit>
    iinit();         // inode table
    80000fb2:	00002097          	auipc	ra,0x2
    80000fb6:	4bc080e7          	jalr	1212(ra) # 8000346e <iinit>
    fileinit();      // file table
    80000fba:	00003097          	auipc	ra,0x3
    80000fbe:	460080e7          	jalr	1120(ra) # 8000441a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc2:	00005097          	auipc	ra,0x5
    80000fc6:	e12080e7          	jalr	-494(ra) # 80005dd4 <virtio_disk_init>
    userinit();      // first user process
    80000fca:	00001097          	auipc	ra,0x1
    80000fce:	d3e080e7          	jalr	-706(ra) # 80001d08 <userinit>
    __sync_synchronize();
    80000fd2:	0ff0000f          	fence
    started = 1;
    80000fd6:	4785                	li	a5,1
    80000fd8:	00008717          	auipc	a4,0x8
    80000fdc:	04f72023          	sw	a5,64(a4) # 80009018 <started>
    80000fe0:	b789                	j	80000f22 <main+0x56>

0000000080000fe2 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fe2:	1141                	add	sp,sp,-16
    80000fe4:	e422                	sd	s0,8(sp)
    80000fe6:	0800                	add	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fe8:	00008797          	auipc	a5,0x8
    80000fec:	0387b783          	ld	a5,56(a5) # 80009020 <kernel_pagetable>
    80000ff0:	83b1                	srl	a5,a5,0xc
    80000ff2:	577d                	li	a4,-1
    80000ff4:	177e                	sll	a4,a4,0x3f
    80000ff6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000ff8:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ffc:	12000073          	sfence.vma
  sfence_vma();
}
    80001000:	6422                	ld	s0,8(sp)
    80001002:	0141                	add	sp,sp,16
    80001004:	8082                	ret

0000000080001006 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001006:	7139                	add	sp,sp,-64
    80001008:	fc06                	sd	ra,56(sp)
    8000100a:	f822                	sd	s0,48(sp)
    8000100c:	f426                	sd	s1,40(sp)
    8000100e:	f04a                	sd	s2,32(sp)
    80001010:	ec4e                	sd	s3,24(sp)
    80001012:	e852                	sd	s4,16(sp)
    80001014:	e456                	sd	s5,8(sp)
    80001016:	e05a                	sd	s6,0(sp)
    80001018:	0080                	add	s0,sp,64
    8000101a:	84aa                	mv	s1,a0
    8000101c:	89ae                	mv	s3,a1
    8000101e:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001020:	57fd                	li	a5,-1
    80001022:	83e9                	srl	a5,a5,0x1a
    80001024:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001026:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001028:	04b7f263          	bgeu	a5,a1,8000106c <walk+0x66>
    panic("walk");
    8000102c:	00007517          	auipc	a0,0x7
    80001030:	08450513          	add	a0,a0,132 # 800080b0 <etext+0xb0>
    80001034:	fffff097          	auipc	ra,0xfffff
    80001038:	526080e7          	jalr	1318(ra) # 8000055a <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000103c:	060a8663          	beqz	s5,800010a8 <walk+0xa2>
    80001040:	00000097          	auipc	ra,0x0
    80001044:	b02080e7          	jalr	-1278(ra) # 80000b42 <kalloc>
    80001048:	84aa                	mv	s1,a0
    8000104a:	c529                	beqz	a0,80001094 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000104c:	6605                	lui	a2,0x1
    8000104e:	4581                	li	a1,0
    80001050:	00000097          	auipc	ra,0x0
    80001054:	cde080e7          	jalr	-802(ra) # 80000d2e <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001058:	00c4d793          	srl	a5,s1,0xc
    8000105c:	07aa                	sll	a5,a5,0xa
    8000105e:	0017e793          	or	a5,a5,1
    80001062:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001066:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd8ff7>
    80001068:	036a0063          	beq	s4,s6,80001088 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000106c:	0149d933          	srl	s2,s3,s4
    80001070:	1ff97913          	and	s2,s2,511
    80001074:	090e                	sll	s2,s2,0x3
    80001076:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001078:	00093483          	ld	s1,0(s2)
    8000107c:	0014f793          	and	a5,s1,1
    80001080:	dfd5                	beqz	a5,8000103c <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001082:	80a9                	srl	s1,s1,0xa
    80001084:	04b2                	sll	s1,s1,0xc
    80001086:	b7c5                	j	80001066 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001088:	00c9d513          	srl	a0,s3,0xc
    8000108c:	1ff57513          	and	a0,a0,511
    80001090:	050e                	sll	a0,a0,0x3
    80001092:	9526                	add	a0,a0,s1
}
    80001094:	70e2                	ld	ra,56(sp)
    80001096:	7442                	ld	s0,48(sp)
    80001098:	74a2                	ld	s1,40(sp)
    8000109a:	7902                	ld	s2,32(sp)
    8000109c:	69e2                	ld	s3,24(sp)
    8000109e:	6a42                	ld	s4,16(sp)
    800010a0:	6aa2                	ld	s5,8(sp)
    800010a2:	6b02                	ld	s6,0(sp)
    800010a4:	6121                	add	sp,sp,64
    800010a6:	8082                	ret
        return 0;
    800010a8:	4501                	li	a0,0
    800010aa:	b7ed                	j	80001094 <walk+0x8e>

00000000800010ac <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010ac:	57fd                	li	a5,-1
    800010ae:	83e9                	srl	a5,a5,0x1a
    800010b0:	00b7f463          	bgeu	a5,a1,800010b8 <walkaddr+0xc>
    return 0;
    800010b4:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010b6:	8082                	ret
{
    800010b8:	1141                	add	sp,sp,-16
    800010ba:	e406                	sd	ra,8(sp)
    800010bc:	e022                	sd	s0,0(sp)
    800010be:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010c0:	4601                	li	a2,0
    800010c2:	00000097          	auipc	ra,0x0
    800010c6:	f44080e7          	jalr	-188(ra) # 80001006 <walk>
  if(pte == 0)
    800010ca:	c105                	beqz	a0,800010ea <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010cc:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010ce:	0117f693          	and	a3,a5,17
    800010d2:	4745                	li	a4,17
    return 0;
    800010d4:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010d6:	00e68663          	beq	a3,a4,800010e2 <walkaddr+0x36>
}
    800010da:	60a2                	ld	ra,8(sp)
    800010dc:	6402                	ld	s0,0(sp)
    800010de:	0141                	add	sp,sp,16
    800010e0:	8082                	ret
  pa = PTE2PA(*pte);
    800010e2:	83a9                	srl	a5,a5,0xa
    800010e4:	00c79513          	sll	a0,a5,0xc
  return pa;
    800010e8:	bfcd                	j	800010da <walkaddr+0x2e>
    return 0;
    800010ea:	4501                	li	a0,0
    800010ec:	b7fd                	j	800010da <walkaddr+0x2e>

00000000800010ee <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010ee:	715d                	add	sp,sp,-80
    800010f0:	e486                	sd	ra,72(sp)
    800010f2:	e0a2                	sd	s0,64(sp)
    800010f4:	fc26                	sd	s1,56(sp)
    800010f6:	f84a                	sd	s2,48(sp)
    800010f8:	f44e                	sd	s3,40(sp)
    800010fa:	f052                	sd	s4,32(sp)
    800010fc:	ec56                	sd	s5,24(sp)
    800010fe:	e85a                	sd	s6,16(sp)
    80001100:	e45e                	sd	s7,8(sp)
    80001102:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001104:	c639                	beqz	a2,80001152 <mappages+0x64>
    80001106:	8aaa                	mv	s5,a0
    80001108:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    8000110a:	777d                	lui	a4,0xfffff
    8000110c:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001110:	fff58993          	add	s3,a1,-1
    80001114:	99b2                	add	s3,s3,a2
    80001116:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000111a:	893e                	mv	s2,a5
    8000111c:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80001120:	6b85                	lui	s7,0x1
    80001122:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001126:	4605                	li	a2,1
    80001128:	85ca                	mv	a1,s2
    8000112a:	8556                	mv	a0,s5
    8000112c:	00000097          	auipc	ra,0x0
    80001130:	eda080e7          	jalr	-294(ra) # 80001006 <walk>
    80001134:	cd1d                	beqz	a0,80001172 <mappages+0x84>
    if(*pte & PTE_V)
    80001136:	611c                	ld	a5,0(a0)
    80001138:	8b85                	and	a5,a5,1
    8000113a:	e785                	bnez	a5,80001162 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000113c:	80b1                	srl	s1,s1,0xc
    8000113e:	04aa                	sll	s1,s1,0xa
    80001140:	0164e4b3          	or	s1,s1,s6
    80001144:	0014e493          	or	s1,s1,1
    80001148:	e104                	sd	s1,0(a0)
    if(a == last)
    8000114a:	05390063          	beq	s2,s3,8000118a <mappages+0x9c>
    a += PGSIZE;
    8000114e:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001150:	bfc9                	j	80001122 <mappages+0x34>
    panic("mappages: size");
    80001152:	00007517          	auipc	a0,0x7
    80001156:	f6650513          	add	a0,a0,-154 # 800080b8 <etext+0xb8>
    8000115a:	fffff097          	auipc	ra,0xfffff
    8000115e:	400080e7          	jalr	1024(ra) # 8000055a <panic>
      panic("mappages: remap");
    80001162:	00007517          	auipc	a0,0x7
    80001166:	f6650513          	add	a0,a0,-154 # 800080c8 <etext+0xc8>
    8000116a:	fffff097          	auipc	ra,0xfffff
    8000116e:	3f0080e7          	jalr	1008(ra) # 8000055a <panic>
      return -1;
    80001172:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001174:	60a6                	ld	ra,72(sp)
    80001176:	6406                	ld	s0,64(sp)
    80001178:	74e2                	ld	s1,56(sp)
    8000117a:	7942                	ld	s2,48(sp)
    8000117c:	79a2                	ld	s3,40(sp)
    8000117e:	7a02                	ld	s4,32(sp)
    80001180:	6ae2                	ld	s5,24(sp)
    80001182:	6b42                	ld	s6,16(sp)
    80001184:	6ba2                	ld	s7,8(sp)
    80001186:	6161                	add	sp,sp,80
    80001188:	8082                	ret
  return 0;
    8000118a:	4501                	li	a0,0
    8000118c:	b7e5                	j	80001174 <mappages+0x86>

000000008000118e <kvmmap>:
{
    8000118e:	1141                	add	sp,sp,-16
    80001190:	e406                	sd	ra,8(sp)
    80001192:	e022                	sd	s0,0(sp)
    80001194:	0800                	add	s0,sp,16
    80001196:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001198:	86b2                	mv	a3,a2
    8000119a:	863e                	mv	a2,a5
    8000119c:	00000097          	auipc	ra,0x0
    800011a0:	f52080e7          	jalr	-174(ra) # 800010ee <mappages>
    800011a4:	e509                	bnez	a0,800011ae <kvmmap+0x20>
}
    800011a6:	60a2                	ld	ra,8(sp)
    800011a8:	6402                	ld	s0,0(sp)
    800011aa:	0141                	add	sp,sp,16
    800011ac:	8082                	ret
    panic("kvmmap");
    800011ae:	00007517          	auipc	a0,0x7
    800011b2:	f2a50513          	add	a0,a0,-214 # 800080d8 <etext+0xd8>
    800011b6:	fffff097          	auipc	ra,0xfffff
    800011ba:	3a4080e7          	jalr	932(ra) # 8000055a <panic>

00000000800011be <kvmmake>:
{
    800011be:	1101                	add	sp,sp,-32
    800011c0:	ec06                	sd	ra,24(sp)
    800011c2:	e822                	sd	s0,16(sp)
    800011c4:	e426                	sd	s1,8(sp)
    800011c6:	e04a                	sd	s2,0(sp)
    800011c8:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800011ca:	00000097          	auipc	ra,0x0
    800011ce:	978080e7          	jalr	-1672(ra) # 80000b42 <kalloc>
    800011d2:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800011d4:	6605                	lui	a2,0x1
    800011d6:	4581                	li	a1,0
    800011d8:	00000097          	auipc	ra,0x0
    800011dc:	b56080e7          	jalr	-1194(ra) # 80000d2e <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800011e0:	4719                	li	a4,6
    800011e2:	6685                	lui	a3,0x1
    800011e4:	10000637          	lui	a2,0x10000
    800011e8:	100005b7          	lui	a1,0x10000
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	fa0080e7          	jalr	-96(ra) # 8000118e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	6685                	lui	a3,0x1
    800011fa:	10001637          	lui	a2,0x10001
    800011fe:	100015b7          	lui	a1,0x10001
    80001202:	8526                	mv	a0,s1
    80001204:	00000097          	auipc	ra,0x0
    80001208:	f8a080e7          	jalr	-118(ra) # 8000118e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000120c:	4719                	li	a4,6
    8000120e:	004006b7          	lui	a3,0x400
    80001212:	0c000637          	lui	a2,0xc000
    80001216:	0c0005b7          	lui	a1,0xc000
    8000121a:	8526                	mv	a0,s1
    8000121c:	00000097          	auipc	ra,0x0
    80001220:	f72080e7          	jalr	-142(ra) # 8000118e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001224:	00007917          	auipc	s2,0x7
    80001228:	ddc90913          	add	s2,s2,-548 # 80008000 <etext>
    8000122c:	4729                	li	a4,10
    8000122e:	80007697          	auipc	a3,0x80007
    80001232:	dd268693          	add	a3,a3,-558 # 8000 <_entry-0x7fff8000>
    80001236:	4605                	li	a2,1
    80001238:	067e                	sll	a2,a2,0x1f
    8000123a:	85b2                	mv	a1,a2
    8000123c:	8526                	mv	a0,s1
    8000123e:	00000097          	auipc	ra,0x0
    80001242:	f50080e7          	jalr	-176(ra) # 8000118e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001246:	46c5                	li	a3,17
    80001248:	06ee                	sll	a3,a3,0x1b
    8000124a:	4719                	li	a4,6
    8000124c:	412686b3          	sub	a3,a3,s2
    80001250:	864a                	mv	a2,s2
    80001252:	85ca                	mv	a1,s2
    80001254:	8526                	mv	a0,s1
    80001256:	00000097          	auipc	ra,0x0
    8000125a:	f38080e7          	jalr	-200(ra) # 8000118e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000125e:	4729                	li	a4,10
    80001260:	6685                	lui	a3,0x1
    80001262:	00006617          	auipc	a2,0x6
    80001266:	d9e60613          	add	a2,a2,-610 # 80007000 <_trampoline>
    8000126a:	040005b7          	lui	a1,0x4000
    8000126e:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001270:	05b2                	sll	a1,a1,0xc
    80001272:	8526                	mv	a0,s1
    80001274:	00000097          	auipc	ra,0x0
    80001278:	f1a080e7          	jalr	-230(ra) # 8000118e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000127c:	8526                	mv	a0,s1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	624080e7          	jalr	1572(ra) # 800018a2 <proc_mapstacks>
}
    80001286:	8526                	mv	a0,s1
    80001288:	60e2                	ld	ra,24(sp)
    8000128a:	6442                	ld	s0,16(sp)
    8000128c:	64a2                	ld	s1,8(sp)
    8000128e:	6902                	ld	s2,0(sp)
    80001290:	6105                	add	sp,sp,32
    80001292:	8082                	ret

0000000080001294 <kvminit>:
{
    80001294:	1141                	add	sp,sp,-16
    80001296:	e406                	sd	ra,8(sp)
    80001298:	e022                	sd	s0,0(sp)
    8000129a:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	f22080e7          	jalr	-222(ra) # 800011be <kvmmake>
    800012a4:	00008797          	auipc	a5,0x8
    800012a8:	d6a7be23          	sd	a0,-644(a5) # 80009020 <kernel_pagetable>
}
    800012ac:	60a2                	ld	ra,8(sp)
    800012ae:	6402                	ld	s0,0(sp)
    800012b0:	0141                	add	sp,sp,16
    800012b2:	8082                	ret

00000000800012b4 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800012b4:	715d                	add	sp,sp,-80
    800012b6:	e486                	sd	ra,72(sp)
    800012b8:	e0a2                	sd	s0,64(sp)
    800012ba:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800012bc:	03459793          	sll	a5,a1,0x34
    800012c0:	e39d                	bnez	a5,800012e6 <uvmunmap+0x32>
    800012c2:	f84a                	sd	s2,48(sp)
    800012c4:	f44e                	sd	s3,40(sp)
    800012c6:	f052                	sd	s4,32(sp)
    800012c8:	ec56                	sd	s5,24(sp)
    800012ca:	e85a                	sd	s6,16(sp)
    800012cc:	e45e                	sd	s7,8(sp)
    800012ce:	8a2a                	mv	s4,a0
    800012d0:	892e                	mv	s2,a1
    800012d2:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012d4:	0632                	sll	a2,a2,0xc
    800012d6:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012da:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012dc:	6b05                	lui	s6,0x1
    800012de:	0935fb63          	bgeu	a1,s3,80001374 <uvmunmap+0xc0>
    800012e2:	fc26                	sd	s1,56(sp)
    800012e4:	a8a9                	j	8000133e <uvmunmap+0x8a>
    800012e6:	fc26                	sd	s1,56(sp)
    800012e8:	f84a                	sd	s2,48(sp)
    800012ea:	f44e                	sd	s3,40(sp)
    800012ec:	f052                	sd	s4,32(sp)
    800012ee:	ec56                	sd	s5,24(sp)
    800012f0:	e85a                	sd	s6,16(sp)
    800012f2:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800012f4:	00007517          	auipc	a0,0x7
    800012f8:	dec50513          	add	a0,a0,-532 # 800080e0 <etext+0xe0>
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	25e080e7          	jalr	606(ra) # 8000055a <panic>
      panic("uvmunmap: walk");
    80001304:	00007517          	auipc	a0,0x7
    80001308:	df450513          	add	a0,a0,-524 # 800080f8 <etext+0xf8>
    8000130c:	fffff097          	auipc	ra,0xfffff
    80001310:	24e080e7          	jalr	590(ra) # 8000055a <panic>
      panic("uvmunmap: not mapped");
    80001314:	00007517          	auipc	a0,0x7
    80001318:	df450513          	add	a0,a0,-524 # 80008108 <etext+0x108>
    8000131c:	fffff097          	auipc	ra,0xfffff
    80001320:	23e080e7          	jalr	574(ra) # 8000055a <panic>
      panic("uvmunmap: not a leaf");
    80001324:	00007517          	auipc	a0,0x7
    80001328:	dfc50513          	add	a0,a0,-516 # 80008120 <etext+0x120>
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	22e080e7          	jalr	558(ra) # 8000055a <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    80001334:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001338:	995a                	add	s2,s2,s6
    8000133a:	03397c63          	bgeu	s2,s3,80001372 <uvmunmap+0xbe>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000133e:	4601                	li	a2,0
    80001340:	85ca                	mv	a1,s2
    80001342:	8552                	mv	a0,s4
    80001344:	00000097          	auipc	ra,0x0
    80001348:	cc2080e7          	jalr	-830(ra) # 80001006 <walk>
    8000134c:	84aa                	mv	s1,a0
    8000134e:	d95d                	beqz	a0,80001304 <uvmunmap+0x50>
    if((*pte & PTE_V) == 0)
    80001350:	6108                	ld	a0,0(a0)
    80001352:	00157793          	and	a5,a0,1
    80001356:	dfdd                	beqz	a5,80001314 <uvmunmap+0x60>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001358:	3ff57793          	and	a5,a0,1023
    8000135c:	fd7784e3          	beq	a5,s7,80001324 <uvmunmap+0x70>
    if(do_free){
    80001360:	fc0a8ae3          	beqz	s5,80001334 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
    80001364:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    80001366:	0532                	sll	a0,a0,0xc
    80001368:	fffff097          	auipc	ra,0xfffff
    8000136c:	6dc080e7          	jalr	1756(ra) # 80000a44 <kfree>
    80001370:	b7d1                	j	80001334 <uvmunmap+0x80>
    80001372:	74e2                	ld	s1,56(sp)
    80001374:	7942                	ld	s2,48(sp)
    80001376:	79a2                	ld	s3,40(sp)
    80001378:	7a02                	ld	s4,32(sp)
    8000137a:	6ae2                	ld	s5,24(sp)
    8000137c:	6b42                	ld	s6,16(sp)
    8000137e:	6ba2                	ld	s7,8(sp)
  }
}
    80001380:	60a6                	ld	ra,72(sp)
    80001382:	6406                	ld	s0,64(sp)
    80001384:	6161                	add	sp,sp,80
    80001386:	8082                	ret

0000000080001388 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001388:	1101                	add	sp,sp,-32
    8000138a:	ec06                	sd	ra,24(sp)
    8000138c:	e822                	sd	s0,16(sp)
    8000138e:	e426                	sd	s1,8(sp)
    80001390:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001392:	fffff097          	auipc	ra,0xfffff
    80001396:	7b0080e7          	jalr	1968(ra) # 80000b42 <kalloc>
    8000139a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000139c:	c519                	beqz	a0,800013aa <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000139e:	6605                	lui	a2,0x1
    800013a0:	4581                	li	a1,0
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	98c080e7          	jalr	-1652(ra) # 80000d2e <memset>
  return pagetable;
}
    800013aa:	8526                	mv	a0,s1
    800013ac:	60e2                	ld	ra,24(sp)
    800013ae:	6442                	ld	s0,16(sp)
    800013b0:	64a2                	ld	s1,8(sp)
    800013b2:	6105                	add	sp,sp,32
    800013b4:	8082                	ret

00000000800013b6 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013b6:	7179                	add	sp,sp,-48
    800013b8:	f406                	sd	ra,40(sp)
    800013ba:	f022                	sd	s0,32(sp)
    800013bc:	ec26                	sd	s1,24(sp)
    800013be:	e84a                	sd	s2,16(sp)
    800013c0:	e44e                	sd	s3,8(sp)
    800013c2:	e052                	sd	s4,0(sp)
    800013c4:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800013c6:	6785                	lui	a5,0x1
    800013c8:	04f67863          	bgeu	a2,a5,80001418 <uvminit+0x62>
    800013cc:	8a2a                	mv	s4,a0
    800013ce:	89ae                	mv	s3,a1
    800013d0:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    800013d2:	fffff097          	auipc	ra,0xfffff
    800013d6:	770080e7          	jalr	1904(ra) # 80000b42 <kalloc>
    800013da:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800013dc:	6605                	lui	a2,0x1
    800013de:	4581                	li	a1,0
    800013e0:	00000097          	auipc	ra,0x0
    800013e4:	94e080e7          	jalr	-1714(ra) # 80000d2e <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013e8:	4779                	li	a4,30
    800013ea:	86ca                	mv	a3,s2
    800013ec:	6605                	lui	a2,0x1
    800013ee:	4581                	li	a1,0
    800013f0:	8552                	mv	a0,s4
    800013f2:	00000097          	auipc	ra,0x0
    800013f6:	cfc080e7          	jalr	-772(ra) # 800010ee <mappages>
  memmove(mem, src, sz);
    800013fa:	8626                	mv	a2,s1
    800013fc:	85ce                	mv	a1,s3
    800013fe:	854a                	mv	a0,s2
    80001400:	00000097          	auipc	ra,0x0
    80001404:	98a080e7          	jalr	-1654(ra) # 80000d8a <memmove>
}
    80001408:	70a2                	ld	ra,40(sp)
    8000140a:	7402                	ld	s0,32(sp)
    8000140c:	64e2                	ld	s1,24(sp)
    8000140e:	6942                	ld	s2,16(sp)
    80001410:	69a2                	ld	s3,8(sp)
    80001412:	6a02                	ld	s4,0(sp)
    80001414:	6145                	add	sp,sp,48
    80001416:	8082                	ret
    panic("inituvm: more than a page");
    80001418:	00007517          	auipc	a0,0x7
    8000141c:	d2050513          	add	a0,a0,-736 # 80008138 <etext+0x138>
    80001420:	fffff097          	auipc	ra,0xfffff
    80001424:	13a080e7          	jalr	314(ra) # 8000055a <panic>

0000000080001428 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001428:	1101                	add	sp,sp,-32
    8000142a:	ec06                	sd	ra,24(sp)
    8000142c:	e822                	sd	s0,16(sp)
    8000142e:	e426                	sd	s1,8(sp)
    80001430:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001432:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001434:	00b67d63          	bgeu	a2,a1,8000144e <uvmdealloc+0x26>
    80001438:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000143a:	6785                	lui	a5,0x1
    8000143c:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000143e:	00f60733          	add	a4,a2,a5
    80001442:	76fd                	lui	a3,0xfffff
    80001444:	8f75                	and	a4,a4,a3
    80001446:	97ae                	add	a5,a5,a1
    80001448:	8ff5                	and	a5,a5,a3
    8000144a:	00f76863          	bltu	a4,a5,8000145a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000144e:	8526                	mv	a0,s1
    80001450:	60e2                	ld	ra,24(sp)
    80001452:	6442                	ld	s0,16(sp)
    80001454:	64a2                	ld	s1,8(sp)
    80001456:	6105                	add	sp,sp,32
    80001458:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000145a:	8f99                	sub	a5,a5,a4
    8000145c:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000145e:	4685                	li	a3,1
    80001460:	0007861b          	sext.w	a2,a5
    80001464:	85ba                	mv	a1,a4
    80001466:	00000097          	auipc	ra,0x0
    8000146a:	e4e080e7          	jalr	-434(ra) # 800012b4 <uvmunmap>
    8000146e:	b7c5                	j	8000144e <uvmdealloc+0x26>

0000000080001470 <uvmalloc>:
  if(newsz < oldsz)
    80001470:	0ab66563          	bltu	a2,a1,8000151a <uvmalloc+0xaa>
{
    80001474:	7139                	add	sp,sp,-64
    80001476:	fc06                	sd	ra,56(sp)
    80001478:	f822                	sd	s0,48(sp)
    8000147a:	ec4e                	sd	s3,24(sp)
    8000147c:	e852                	sd	s4,16(sp)
    8000147e:	e456                	sd	s5,8(sp)
    80001480:	0080                	add	s0,sp,64
    80001482:	8aaa                	mv	s5,a0
    80001484:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001486:	6785                	lui	a5,0x1
    80001488:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000148a:	95be                	add	a1,a1,a5
    8000148c:	77fd                	lui	a5,0xfffff
    8000148e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001492:	08c9f663          	bgeu	s3,a2,8000151e <uvmalloc+0xae>
    80001496:	f426                	sd	s1,40(sp)
    80001498:	f04a                	sd	s2,32(sp)
    8000149a:	894e                	mv	s2,s3
    mem = kalloc();
    8000149c:	fffff097          	auipc	ra,0xfffff
    800014a0:	6a6080e7          	jalr	1702(ra) # 80000b42 <kalloc>
    800014a4:	84aa                	mv	s1,a0
    if(mem == 0){
    800014a6:	c90d                	beqz	a0,800014d8 <uvmalloc+0x68>
    memset(mem, 0, PGSIZE);
    800014a8:	6605                	lui	a2,0x1
    800014aa:	4581                	li	a1,0
    800014ac:	00000097          	auipc	ra,0x0
    800014b0:	882080e7          	jalr	-1918(ra) # 80000d2e <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014b4:	4779                	li	a4,30
    800014b6:	86a6                	mv	a3,s1
    800014b8:	6605                	lui	a2,0x1
    800014ba:	85ca                	mv	a1,s2
    800014bc:	8556                	mv	a0,s5
    800014be:	00000097          	auipc	ra,0x0
    800014c2:	c30080e7          	jalr	-976(ra) # 800010ee <mappages>
    800014c6:	e915                	bnez	a0,800014fa <uvmalloc+0x8a>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014c8:	6785                	lui	a5,0x1
    800014ca:	993e                	add	s2,s2,a5
    800014cc:	fd4968e3          	bltu	s2,s4,8000149c <uvmalloc+0x2c>
  return newsz;
    800014d0:	8552                	mv	a0,s4
    800014d2:	74a2                	ld	s1,40(sp)
    800014d4:	7902                	ld	s2,32(sp)
    800014d6:	a819                	j	800014ec <uvmalloc+0x7c>
      uvmdealloc(pagetable, a, oldsz);
    800014d8:	864e                	mv	a2,s3
    800014da:	85ca                	mv	a1,s2
    800014dc:	8556                	mv	a0,s5
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	f4a080e7          	jalr	-182(ra) # 80001428 <uvmdealloc>
      return 0;
    800014e6:	4501                	li	a0,0
    800014e8:	74a2                	ld	s1,40(sp)
    800014ea:	7902                	ld	s2,32(sp)
}
    800014ec:	70e2                	ld	ra,56(sp)
    800014ee:	7442                	ld	s0,48(sp)
    800014f0:	69e2                	ld	s3,24(sp)
    800014f2:	6a42                	ld	s4,16(sp)
    800014f4:	6aa2                	ld	s5,8(sp)
    800014f6:	6121                	add	sp,sp,64
    800014f8:	8082                	ret
      kfree(mem);
    800014fa:	8526                	mv	a0,s1
    800014fc:	fffff097          	auipc	ra,0xfffff
    80001500:	548080e7          	jalr	1352(ra) # 80000a44 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001504:	864e                	mv	a2,s3
    80001506:	85ca                	mv	a1,s2
    80001508:	8556                	mv	a0,s5
    8000150a:	00000097          	auipc	ra,0x0
    8000150e:	f1e080e7          	jalr	-226(ra) # 80001428 <uvmdealloc>
      return 0;
    80001512:	4501                	li	a0,0
    80001514:	74a2                	ld	s1,40(sp)
    80001516:	7902                	ld	s2,32(sp)
    80001518:	bfd1                	j	800014ec <uvmalloc+0x7c>
    return oldsz;
    8000151a:	852e                	mv	a0,a1
}
    8000151c:	8082                	ret
  return newsz;
    8000151e:	8532                	mv	a0,a2
    80001520:	b7f1                	j	800014ec <uvmalloc+0x7c>

0000000080001522 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001522:	7179                	add	sp,sp,-48
    80001524:	f406                	sd	ra,40(sp)
    80001526:	f022                	sd	s0,32(sp)
    80001528:	ec26                	sd	s1,24(sp)
    8000152a:	e84a                	sd	s2,16(sp)
    8000152c:	e44e                	sd	s3,8(sp)
    8000152e:	e052                	sd	s4,0(sp)
    80001530:	1800                	add	s0,sp,48
    80001532:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001534:	84aa                	mv	s1,a0
    80001536:	6905                	lui	s2,0x1
    80001538:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000153a:	4985                	li	s3,1
    8000153c:	a829                	j	80001556 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000153e:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001540:	00c79513          	sll	a0,a5,0xc
    80001544:	00000097          	auipc	ra,0x0
    80001548:	fde080e7          	jalr	-34(ra) # 80001522 <freewalk>
      pagetable[i] = 0;
    8000154c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001550:	04a1                	add	s1,s1,8
    80001552:	03248163          	beq	s1,s2,80001574 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001556:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001558:	00f7f713          	and	a4,a5,15
    8000155c:	ff3701e3          	beq	a4,s3,8000153e <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001560:	8b85                	and	a5,a5,1
    80001562:	d7fd                	beqz	a5,80001550 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001564:	00007517          	auipc	a0,0x7
    80001568:	bf450513          	add	a0,a0,-1036 # 80008158 <etext+0x158>
    8000156c:	fffff097          	auipc	ra,0xfffff
    80001570:	fee080e7          	jalr	-18(ra) # 8000055a <panic>
    }
  }
  kfree((void*)pagetable);
    80001574:	8552                	mv	a0,s4
    80001576:	fffff097          	auipc	ra,0xfffff
    8000157a:	4ce080e7          	jalr	1230(ra) # 80000a44 <kfree>
}
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	6942                	ld	s2,16(sp)
    80001586:	69a2                	ld	s3,8(sp)
    80001588:	6a02                	ld	s4,0(sp)
    8000158a:	6145                	add	sp,sp,48
    8000158c:	8082                	ret

000000008000158e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000158e:	1101                	add	sp,sp,-32
    80001590:	ec06                	sd	ra,24(sp)
    80001592:	e822                	sd	s0,16(sp)
    80001594:	e426                	sd	s1,8(sp)
    80001596:	1000                	add	s0,sp,32
    80001598:	84aa                	mv	s1,a0
  if(sz > 0)
    8000159a:	e999                	bnez	a1,800015b0 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000159c:	8526                	mv	a0,s1
    8000159e:	00000097          	auipc	ra,0x0
    800015a2:	f84080e7          	jalr	-124(ra) # 80001522 <freewalk>
}
    800015a6:	60e2                	ld	ra,24(sp)
    800015a8:	6442                	ld	s0,16(sp)
    800015aa:	64a2                	ld	s1,8(sp)
    800015ac:	6105                	add	sp,sp,32
    800015ae:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015b0:	6785                	lui	a5,0x1
    800015b2:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015b4:	95be                	add	a1,a1,a5
    800015b6:	4685                	li	a3,1
    800015b8:	00c5d613          	srl	a2,a1,0xc
    800015bc:	4581                	li	a1,0
    800015be:	00000097          	auipc	ra,0x0
    800015c2:	cf6080e7          	jalr	-778(ra) # 800012b4 <uvmunmap>
    800015c6:	bfd9                	j	8000159c <uvmfree+0xe>

00000000800015c8 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800015c8:	c679                	beqz	a2,80001696 <uvmcopy+0xce>
{
    800015ca:	715d                	add	sp,sp,-80
    800015cc:	e486                	sd	ra,72(sp)
    800015ce:	e0a2                	sd	s0,64(sp)
    800015d0:	fc26                	sd	s1,56(sp)
    800015d2:	f84a                	sd	s2,48(sp)
    800015d4:	f44e                	sd	s3,40(sp)
    800015d6:	f052                	sd	s4,32(sp)
    800015d8:	ec56                	sd	s5,24(sp)
    800015da:	e85a                	sd	s6,16(sp)
    800015dc:	e45e                	sd	s7,8(sp)
    800015de:	0880                	add	s0,sp,80
    800015e0:	8b2a                	mv	s6,a0
    800015e2:	8aae                	mv	s5,a1
    800015e4:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015e6:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015e8:	4601                	li	a2,0
    800015ea:	85ce                	mv	a1,s3
    800015ec:	855a                	mv	a0,s6
    800015ee:	00000097          	auipc	ra,0x0
    800015f2:	a18080e7          	jalr	-1512(ra) # 80001006 <walk>
    800015f6:	c531                	beqz	a0,80001642 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015f8:	6118                	ld	a4,0(a0)
    800015fa:	00177793          	and	a5,a4,1
    800015fe:	cbb1                	beqz	a5,80001652 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001600:	00a75593          	srl	a1,a4,0xa
    80001604:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001608:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000160c:	fffff097          	auipc	ra,0xfffff
    80001610:	536080e7          	jalr	1334(ra) # 80000b42 <kalloc>
    80001614:	892a                	mv	s2,a0
    80001616:	c939                	beqz	a0,8000166c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001618:	6605                	lui	a2,0x1
    8000161a:	85de                	mv	a1,s7
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	76e080e7          	jalr	1902(ra) # 80000d8a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001624:	8726                	mv	a4,s1
    80001626:	86ca                	mv	a3,s2
    80001628:	6605                	lui	a2,0x1
    8000162a:	85ce                	mv	a1,s3
    8000162c:	8556                	mv	a0,s5
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	ac0080e7          	jalr	-1344(ra) # 800010ee <mappages>
    80001636:	e515                	bnez	a0,80001662 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001638:	6785                	lui	a5,0x1
    8000163a:	99be                	add	s3,s3,a5
    8000163c:	fb49e6e3          	bltu	s3,s4,800015e8 <uvmcopy+0x20>
    80001640:	a081                	j	80001680 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001642:	00007517          	auipc	a0,0x7
    80001646:	b2650513          	add	a0,a0,-1242 # 80008168 <etext+0x168>
    8000164a:	fffff097          	auipc	ra,0xfffff
    8000164e:	f10080e7          	jalr	-240(ra) # 8000055a <panic>
      panic("uvmcopy: page not present");
    80001652:	00007517          	auipc	a0,0x7
    80001656:	b3650513          	add	a0,a0,-1226 # 80008188 <etext+0x188>
    8000165a:	fffff097          	auipc	ra,0xfffff
    8000165e:	f00080e7          	jalr	-256(ra) # 8000055a <panic>
      kfree(mem);
    80001662:	854a                	mv	a0,s2
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	3e0080e7          	jalr	992(ra) # 80000a44 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000166c:	4685                	li	a3,1
    8000166e:	00c9d613          	srl	a2,s3,0xc
    80001672:	4581                	li	a1,0
    80001674:	8556                	mv	a0,s5
    80001676:	00000097          	auipc	ra,0x0
    8000167a:	c3e080e7          	jalr	-962(ra) # 800012b4 <uvmunmap>
  return -1;
    8000167e:	557d                	li	a0,-1
}
    80001680:	60a6                	ld	ra,72(sp)
    80001682:	6406                	ld	s0,64(sp)
    80001684:	74e2                	ld	s1,56(sp)
    80001686:	7942                	ld	s2,48(sp)
    80001688:	79a2                	ld	s3,40(sp)
    8000168a:	7a02                	ld	s4,32(sp)
    8000168c:	6ae2                	ld	s5,24(sp)
    8000168e:	6b42                	ld	s6,16(sp)
    80001690:	6ba2                	ld	s7,8(sp)
    80001692:	6161                	add	sp,sp,80
    80001694:	8082                	ret
  return 0;
    80001696:	4501                	li	a0,0
}
    80001698:	8082                	ret

000000008000169a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000169a:	1141                	add	sp,sp,-16
    8000169c:	e406                	sd	ra,8(sp)
    8000169e:	e022                	sd	s0,0(sp)
    800016a0:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016a2:	4601                	li	a2,0
    800016a4:	00000097          	auipc	ra,0x0
    800016a8:	962080e7          	jalr	-1694(ra) # 80001006 <walk>
  if(pte == 0)
    800016ac:	c901                	beqz	a0,800016bc <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016ae:	611c                	ld	a5,0(a0)
    800016b0:	9bbd                	and	a5,a5,-17
    800016b2:	e11c                	sd	a5,0(a0)
}
    800016b4:	60a2                	ld	ra,8(sp)
    800016b6:	6402                	ld	s0,0(sp)
    800016b8:	0141                	add	sp,sp,16
    800016ba:	8082                	ret
    panic("uvmclear");
    800016bc:	00007517          	auipc	a0,0x7
    800016c0:	aec50513          	add	a0,a0,-1300 # 800081a8 <etext+0x1a8>
    800016c4:	fffff097          	auipc	ra,0xfffff
    800016c8:	e96080e7          	jalr	-362(ra) # 8000055a <panic>

00000000800016cc <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016cc:	c6bd                	beqz	a3,8000173a <copyout+0x6e>
{
    800016ce:	715d                	add	sp,sp,-80
    800016d0:	e486                	sd	ra,72(sp)
    800016d2:	e0a2                	sd	s0,64(sp)
    800016d4:	fc26                	sd	s1,56(sp)
    800016d6:	f84a                	sd	s2,48(sp)
    800016d8:	f44e                	sd	s3,40(sp)
    800016da:	f052                	sd	s4,32(sp)
    800016dc:	ec56                	sd	s5,24(sp)
    800016de:	e85a                	sd	s6,16(sp)
    800016e0:	e45e                	sd	s7,8(sp)
    800016e2:	e062                	sd	s8,0(sp)
    800016e4:	0880                	add	s0,sp,80
    800016e6:	8b2a                	mv	s6,a0
    800016e8:	8c2e                	mv	s8,a1
    800016ea:	8a32                	mv	s4,a2
    800016ec:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016ee:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016f0:	6a85                	lui	s5,0x1
    800016f2:	a015                	j	80001716 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016f4:	9562                	add	a0,a0,s8
    800016f6:	0004861b          	sext.w	a2,s1
    800016fa:	85d2                	mv	a1,s4
    800016fc:	41250533          	sub	a0,a0,s2
    80001700:	fffff097          	auipc	ra,0xfffff
    80001704:	68a080e7          	jalr	1674(ra) # 80000d8a <memmove>

    len -= n;
    80001708:	409989b3          	sub	s3,s3,s1
    src += n;
    8000170c:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000170e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001712:	02098263          	beqz	s3,80001736 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001716:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000171a:	85ca                	mv	a1,s2
    8000171c:	855a                	mv	a0,s6
    8000171e:	00000097          	auipc	ra,0x0
    80001722:	98e080e7          	jalr	-1650(ra) # 800010ac <walkaddr>
    if(pa0 == 0)
    80001726:	cd01                	beqz	a0,8000173e <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001728:	418904b3          	sub	s1,s2,s8
    8000172c:	94d6                	add	s1,s1,s5
    if(n > len)
    8000172e:	fc99f3e3          	bgeu	s3,s1,800016f4 <copyout+0x28>
    80001732:	84ce                	mv	s1,s3
    80001734:	b7c1                	j	800016f4 <copyout+0x28>
  }
  return 0;
    80001736:	4501                	li	a0,0
    80001738:	a021                	j	80001740 <copyout+0x74>
    8000173a:	4501                	li	a0,0
}
    8000173c:	8082                	ret
      return -1;
    8000173e:	557d                	li	a0,-1
}
    80001740:	60a6                	ld	ra,72(sp)
    80001742:	6406                	ld	s0,64(sp)
    80001744:	74e2                	ld	s1,56(sp)
    80001746:	7942                	ld	s2,48(sp)
    80001748:	79a2                	ld	s3,40(sp)
    8000174a:	7a02                	ld	s4,32(sp)
    8000174c:	6ae2                	ld	s5,24(sp)
    8000174e:	6b42                	ld	s6,16(sp)
    80001750:	6ba2                	ld	s7,8(sp)
    80001752:	6c02                	ld	s8,0(sp)
    80001754:	6161                	add	sp,sp,80
    80001756:	8082                	ret

0000000080001758 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001758:	caa5                	beqz	a3,800017c8 <copyin+0x70>
{
    8000175a:	715d                	add	sp,sp,-80
    8000175c:	e486                	sd	ra,72(sp)
    8000175e:	e0a2                	sd	s0,64(sp)
    80001760:	fc26                	sd	s1,56(sp)
    80001762:	f84a                	sd	s2,48(sp)
    80001764:	f44e                	sd	s3,40(sp)
    80001766:	f052                	sd	s4,32(sp)
    80001768:	ec56                	sd	s5,24(sp)
    8000176a:	e85a                	sd	s6,16(sp)
    8000176c:	e45e                	sd	s7,8(sp)
    8000176e:	e062                	sd	s8,0(sp)
    80001770:	0880                	add	s0,sp,80
    80001772:	8b2a                	mv	s6,a0
    80001774:	8a2e                	mv	s4,a1
    80001776:	8c32                	mv	s8,a2
    80001778:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000177a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000177c:	6a85                	lui	s5,0x1
    8000177e:	a01d                	j	800017a4 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001780:	018505b3          	add	a1,a0,s8
    80001784:	0004861b          	sext.w	a2,s1
    80001788:	412585b3          	sub	a1,a1,s2
    8000178c:	8552                	mv	a0,s4
    8000178e:	fffff097          	auipc	ra,0xfffff
    80001792:	5fc080e7          	jalr	1532(ra) # 80000d8a <memmove>

    len -= n;
    80001796:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000179a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000179c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017a0:	02098263          	beqz	s3,800017c4 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017a4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017a8:	85ca                	mv	a1,s2
    800017aa:	855a                	mv	a0,s6
    800017ac:	00000097          	auipc	ra,0x0
    800017b0:	900080e7          	jalr	-1792(ra) # 800010ac <walkaddr>
    if(pa0 == 0)
    800017b4:	cd01                	beqz	a0,800017cc <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017b6:	418904b3          	sub	s1,s2,s8
    800017ba:	94d6                	add	s1,s1,s5
    if(n > len)
    800017bc:	fc99f2e3          	bgeu	s3,s1,80001780 <copyin+0x28>
    800017c0:	84ce                	mv	s1,s3
    800017c2:	bf7d                	j	80001780 <copyin+0x28>
  }
  return 0;
    800017c4:	4501                	li	a0,0
    800017c6:	a021                	j	800017ce <copyin+0x76>
    800017c8:	4501                	li	a0,0
}
    800017ca:	8082                	ret
      return -1;
    800017cc:	557d                	li	a0,-1
}
    800017ce:	60a6                	ld	ra,72(sp)
    800017d0:	6406                	ld	s0,64(sp)
    800017d2:	74e2                	ld	s1,56(sp)
    800017d4:	7942                	ld	s2,48(sp)
    800017d6:	79a2                	ld	s3,40(sp)
    800017d8:	7a02                	ld	s4,32(sp)
    800017da:	6ae2                	ld	s5,24(sp)
    800017dc:	6b42                	ld	s6,16(sp)
    800017de:	6ba2                	ld	s7,8(sp)
    800017e0:	6c02                	ld	s8,0(sp)
    800017e2:	6161                	add	sp,sp,80
    800017e4:	8082                	ret

00000000800017e6 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017e6:	cacd                	beqz	a3,80001898 <copyinstr+0xb2>
{
    800017e8:	715d                	add	sp,sp,-80
    800017ea:	e486                	sd	ra,72(sp)
    800017ec:	e0a2                	sd	s0,64(sp)
    800017ee:	fc26                	sd	s1,56(sp)
    800017f0:	f84a                	sd	s2,48(sp)
    800017f2:	f44e                	sd	s3,40(sp)
    800017f4:	f052                	sd	s4,32(sp)
    800017f6:	ec56                	sd	s5,24(sp)
    800017f8:	e85a                	sd	s6,16(sp)
    800017fa:	e45e                	sd	s7,8(sp)
    800017fc:	0880                	add	s0,sp,80
    800017fe:	8a2a                	mv	s4,a0
    80001800:	8b2e                	mv	s6,a1
    80001802:	8bb2                	mv	s7,a2
    80001804:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80001806:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001808:	6985                	lui	s3,0x1
    8000180a:	a825                	j	80001842 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000180c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001810:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001812:	37fd                	addw	a5,a5,-1
    80001814:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001818:	60a6                	ld	ra,72(sp)
    8000181a:	6406                	ld	s0,64(sp)
    8000181c:	74e2                	ld	s1,56(sp)
    8000181e:	7942                	ld	s2,48(sp)
    80001820:	79a2                	ld	s3,40(sp)
    80001822:	7a02                	ld	s4,32(sp)
    80001824:	6ae2                	ld	s5,24(sp)
    80001826:	6b42                	ld	s6,16(sp)
    80001828:	6ba2                	ld	s7,8(sp)
    8000182a:	6161                	add	sp,sp,80
    8000182c:	8082                	ret
    8000182e:	fff90713          	add	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001832:	9742                	add	a4,a4,a6
      --max;
    80001834:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001838:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    8000183c:	04e58663          	beq	a1,a4,80001888 <copyinstr+0xa2>
{
    80001840:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001842:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001846:	85a6                	mv	a1,s1
    80001848:	8552                	mv	a0,s4
    8000184a:	00000097          	auipc	ra,0x0
    8000184e:	862080e7          	jalr	-1950(ra) # 800010ac <walkaddr>
    if(pa0 == 0)
    80001852:	cd0d                	beqz	a0,8000188c <copyinstr+0xa6>
    n = PGSIZE - (srcva - va0);
    80001854:	417486b3          	sub	a3,s1,s7
    80001858:	96ce                	add	a3,a3,s3
    if(n > max)
    8000185a:	00d97363          	bgeu	s2,a3,80001860 <copyinstr+0x7a>
    8000185e:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001860:	955e                	add	a0,a0,s7
    80001862:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001864:	c695                	beqz	a3,80001890 <copyinstr+0xaa>
    80001866:	87da                	mv	a5,s6
    80001868:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000186a:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000186e:	96da                	add	a3,a3,s6
    80001870:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001872:	00f60733          	add	a4,a2,a5
    80001876:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    8000187a:	db49                	beqz	a4,8000180c <copyinstr+0x26>
        *dst = *p;
    8000187c:	00e78023          	sb	a4,0(a5)
      dst++;
    80001880:	0785                	add	a5,a5,1
    while(n > 0){
    80001882:	fed797e3          	bne	a5,a3,80001870 <copyinstr+0x8a>
    80001886:	b765                	j	8000182e <copyinstr+0x48>
    80001888:	4781                	li	a5,0
    8000188a:	b761                	j	80001812 <copyinstr+0x2c>
      return -1;
    8000188c:	557d                	li	a0,-1
    8000188e:	b769                	j	80001818 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001890:	6b85                	lui	s7,0x1
    80001892:	9ba6                	add	s7,s7,s1
    80001894:	87da                	mv	a5,s6
    80001896:	b76d                	j	80001840 <copyinstr+0x5a>
  int got_null = 0;
    80001898:	4781                	li	a5,0
  if(got_null){
    8000189a:	37fd                	addw	a5,a5,-1
    8000189c:	0007851b          	sext.w	a0,a5
}
    800018a0:	8082                	ret

00000000800018a2 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    800018a2:	7139                	add	sp,sp,-64
    800018a4:	fc06                	sd	ra,56(sp)
    800018a6:	f822                	sd	s0,48(sp)
    800018a8:	f426                	sd	s1,40(sp)
    800018aa:	f04a                	sd	s2,32(sp)
    800018ac:	ec4e                	sd	s3,24(sp)
    800018ae:	e852                	sd	s4,16(sp)
    800018b0:	e456                	sd	s5,8(sp)
    800018b2:	e05a                	sd	s6,0(sp)
    800018b4:	0080                	add	s0,sp,64
    800018b6:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800018b8:	00010497          	auipc	s1,0x10
    800018bc:	e1848493          	add	s1,s1,-488 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800018c0:	8b26                	mv	s6,s1
    800018c2:	04fa5937          	lui	s2,0x4fa5
    800018c6:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800018ca:	0932                	sll	s2,s2,0xc
    800018cc:	fa590913          	add	s2,s2,-91
    800018d0:	0932                	sll	s2,s2,0xc
    800018d2:	fa590913          	add	s2,s2,-91
    800018d6:	0932                	sll	s2,s2,0xc
    800018d8:	fa590913          	add	s2,s2,-91
    800018dc:	040009b7          	lui	s3,0x4000
    800018e0:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018e2:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e4:	00015a97          	auipc	s5,0x15
    800018e8:	7eca8a93          	add	s5,s5,2028 # 800170d0 <tickslock>
    char *pa = kalloc();
    800018ec:	fffff097          	auipc	ra,0xfffff
    800018f0:	256080e7          	jalr	598(ra) # 80000b42 <kalloc>
    800018f4:	862a                	mv	a2,a0
    if(pa == 0)
    800018f6:	c121                	beqz	a0,80001936 <proc_mapstacks+0x94>
    uint64 va = KSTACK((int) (p - proc));
    800018f8:	416485b3          	sub	a1,s1,s6
    800018fc:	858d                	sra	a1,a1,0x3
    800018fe:	032585b3          	mul	a1,a1,s2
    80001902:	2585                	addw	a1,a1,1
    80001904:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001908:	4719                	li	a4,6
    8000190a:	6685                	lui	a3,0x1
    8000190c:	40b985b3          	sub	a1,s3,a1
    80001910:	8552                	mv	a0,s4
    80001912:	00000097          	auipc	ra,0x0
    80001916:	87c080e7          	jalr	-1924(ra) # 8000118e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000191a:	16848493          	add	s1,s1,360
    8000191e:	fd5497e3          	bne	s1,s5,800018ec <proc_mapstacks+0x4a>
  }
}
    80001922:	70e2                	ld	ra,56(sp)
    80001924:	7442                	ld	s0,48(sp)
    80001926:	74a2                	ld	s1,40(sp)
    80001928:	7902                	ld	s2,32(sp)
    8000192a:	69e2                	ld	s3,24(sp)
    8000192c:	6a42                	ld	s4,16(sp)
    8000192e:	6aa2                	ld	s5,8(sp)
    80001930:	6b02                	ld	s6,0(sp)
    80001932:	6121                	add	sp,sp,64
    80001934:	8082                	ret
      panic("kalloc");
    80001936:	00007517          	auipc	a0,0x7
    8000193a:	88250513          	add	a0,a0,-1918 # 800081b8 <etext+0x1b8>
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	c1c080e7          	jalr	-996(ra) # 8000055a <panic>

0000000080001946 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001946:	7139                	add	sp,sp,-64
    80001948:	fc06                	sd	ra,56(sp)
    8000194a:	f822                	sd	s0,48(sp)
    8000194c:	f426                	sd	s1,40(sp)
    8000194e:	f04a                	sd	s2,32(sp)
    80001950:	ec4e                	sd	s3,24(sp)
    80001952:	e852                	sd	s4,16(sp)
    80001954:	e456                	sd	s5,8(sp)
    80001956:	e05a                	sd	s6,0(sp)
    80001958:	0080                	add	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000195a:	00007597          	auipc	a1,0x7
    8000195e:	86658593          	add	a1,a1,-1946 # 800081c0 <etext+0x1c0>
    80001962:	00010517          	auipc	a0,0x10
    80001966:	93e50513          	add	a0,a0,-1730 # 800112a0 <pid_lock>
    8000196a:	fffff097          	auipc	ra,0xfffff
    8000196e:	238080e7          	jalr	568(ra) # 80000ba2 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001972:	00007597          	auipc	a1,0x7
    80001976:	85658593          	add	a1,a1,-1962 # 800081c8 <etext+0x1c8>
    8000197a:	00010517          	auipc	a0,0x10
    8000197e:	93e50513          	add	a0,a0,-1730 # 800112b8 <wait_lock>
    80001982:	fffff097          	auipc	ra,0xfffff
    80001986:	220080e7          	jalr	544(ra) # 80000ba2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000198a:	00010497          	auipc	s1,0x10
    8000198e:	d4648493          	add	s1,s1,-698 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001992:	00007b17          	auipc	s6,0x7
    80001996:	846b0b13          	add	s6,s6,-1978 # 800081d8 <etext+0x1d8>
      p->kstack = KSTACK((int) (p - proc));
    8000199a:	8aa6                	mv	s5,s1
    8000199c:	04fa5937          	lui	s2,0x4fa5
    800019a0:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800019a4:	0932                	sll	s2,s2,0xc
    800019a6:	fa590913          	add	s2,s2,-91
    800019aa:	0932                	sll	s2,s2,0xc
    800019ac:	fa590913          	add	s2,s2,-91
    800019b0:	0932                	sll	s2,s2,0xc
    800019b2:	fa590913          	add	s2,s2,-91
    800019b6:	040009b7          	lui	s3,0x4000
    800019ba:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019bc:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019be:	00015a17          	auipc	s4,0x15
    800019c2:	712a0a13          	add	s4,s4,1810 # 800170d0 <tickslock>
      initlock(&p->lock, "proc");
    800019c6:	85da                	mv	a1,s6
    800019c8:	8526                	mv	a0,s1
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	1d8080e7          	jalr	472(ra) # 80000ba2 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    800019d2:	415487b3          	sub	a5,s1,s5
    800019d6:	878d                	sra	a5,a5,0x3
    800019d8:	032787b3          	mul	a5,a5,s2
    800019dc:	2785                	addw	a5,a5,1
    800019de:	00d7979b          	sllw	a5,a5,0xd
    800019e2:	40f987b3          	sub	a5,s3,a5
    800019e6:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019e8:	16848493          	add	s1,s1,360
    800019ec:	fd449de3          	bne	s1,s4,800019c6 <procinit+0x80>
  }
}
    800019f0:	70e2                	ld	ra,56(sp)
    800019f2:	7442                	ld	s0,48(sp)
    800019f4:	74a2                	ld	s1,40(sp)
    800019f6:	7902                	ld	s2,32(sp)
    800019f8:	69e2                	ld	s3,24(sp)
    800019fa:	6a42                	ld	s4,16(sp)
    800019fc:	6aa2                	ld	s5,8(sp)
    800019fe:	6b02                	ld	s6,0(sp)
    80001a00:	6121                	add	sp,sp,64
    80001a02:	8082                	ret

0000000080001a04 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a04:	1141                	add	sp,sp,-16
    80001a06:	e422                	sd	s0,8(sp)
    80001a08:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a0a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a0c:	2501                	sext.w	a0,a0
    80001a0e:	6422                	ld	s0,8(sp)
    80001a10:	0141                	add	sp,sp,16
    80001a12:	8082                	ret

0000000080001a14 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001a14:	1141                	add	sp,sp,-16
    80001a16:	e422                	sd	s0,8(sp)
    80001a18:	0800                	add	s0,sp,16
    80001a1a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a1c:	2781                	sext.w	a5,a5
    80001a1e:	079e                	sll	a5,a5,0x7
  return c;
}
    80001a20:	00010517          	auipc	a0,0x10
    80001a24:	8b050513          	add	a0,a0,-1872 # 800112d0 <cpus>
    80001a28:	953e                	add	a0,a0,a5
    80001a2a:	6422                	ld	s0,8(sp)
    80001a2c:	0141                	add	sp,sp,16
    80001a2e:	8082                	ret

0000000080001a30 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001a30:	1101                	add	sp,sp,-32
    80001a32:	ec06                	sd	ra,24(sp)
    80001a34:	e822                	sd	s0,16(sp)
    80001a36:	e426                	sd	s1,8(sp)
    80001a38:	1000                	add	s0,sp,32
  push_off();
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	1ac080e7          	jalr	428(ra) # 80000be6 <push_off>
    80001a42:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a44:	2781                	sext.w	a5,a5
    80001a46:	079e                	sll	a5,a5,0x7
    80001a48:	00010717          	auipc	a4,0x10
    80001a4c:	85870713          	add	a4,a4,-1960 # 800112a0 <pid_lock>
    80001a50:	97ba                	add	a5,a5,a4
    80001a52:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	232080e7          	jalr	562(ra) # 80000c86 <pop_off>
  return p;
}
    80001a5c:	8526                	mv	a0,s1
    80001a5e:	60e2                	ld	ra,24(sp)
    80001a60:	6442                	ld	s0,16(sp)
    80001a62:	64a2                	ld	s1,8(sp)
    80001a64:	6105                	add	sp,sp,32
    80001a66:	8082                	ret

0000000080001a68 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a68:	1141                	add	sp,sp,-16
    80001a6a:	e406                	sd	ra,8(sp)
    80001a6c:	e022                	sd	s0,0(sp)
    80001a6e:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a70:	00000097          	auipc	ra,0x0
    80001a74:	fc0080e7          	jalr	-64(ra) # 80001a30 <myproc>
    80001a78:	fffff097          	auipc	ra,0xfffff
    80001a7c:	26e080e7          	jalr	622(ra) # 80000ce6 <release>

  if (first) {
    80001a80:	00007797          	auipc	a5,0x7
    80001a84:	d907a783          	lw	a5,-624(a5) # 80008810 <first.1>
    80001a88:	eb89                	bnez	a5,80001a9a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a8a:	00001097          	auipc	ra,0x1
    80001a8e:	c16080e7          	jalr	-1002(ra) # 800026a0 <usertrapret>
}
    80001a92:	60a2                	ld	ra,8(sp)
    80001a94:	6402                	ld	s0,0(sp)
    80001a96:	0141                	add	sp,sp,16
    80001a98:	8082                	ret
    first = 0;
    80001a9a:	00007797          	auipc	a5,0x7
    80001a9e:	d607ab23          	sw	zero,-650(a5) # 80008810 <first.1>
    fsinit(ROOTDEV);
    80001aa2:	4505                	li	a0,1
    80001aa4:	00002097          	auipc	ra,0x2
    80001aa8:	94a080e7          	jalr	-1718(ra) # 800033ee <fsinit>
    80001aac:	bff9                	j	80001a8a <forkret+0x22>

0000000080001aae <allocpid>:
allocpid() {
    80001aae:	1101                	add	sp,sp,-32
    80001ab0:	ec06                	sd	ra,24(sp)
    80001ab2:	e822                	sd	s0,16(sp)
    80001ab4:	e426                	sd	s1,8(sp)
    80001ab6:	e04a                	sd	s2,0(sp)
    80001ab8:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001aba:	0000f917          	auipc	s2,0xf
    80001abe:	7e690913          	add	s2,s2,2022 # 800112a0 <pid_lock>
    80001ac2:	854a                	mv	a0,s2
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	16e080e7          	jalr	366(ra) # 80000c32 <acquire>
  pid = nextpid;
    80001acc:	00007797          	auipc	a5,0x7
    80001ad0:	d4878793          	add	a5,a5,-696 # 80008814 <nextpid>
    80001ad4:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ad6:	0014871b          	addw	a4,s1,1
    80001ada:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001adc:	854a                	mv	a0,s2
    80001ade:	fffff097          	auipc	ra,0xfffff
    80001ae2:	208080e7          	jalr	520(ra) # 80000ce6 <release>
}
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	60e2                	ld	ra,24(sp)
    80001aea:	6442                	ld	s0,16(sp)
    80001aec:	64a2                	ld	s1,8(sp)
    80001aee:	6902                	ld	s2,0(sp)
    80001af0:	6105                	add	sp,sp,32
    80001af2:	8082                	ret

0000000080001af4 <proc_pagetable>:
{
    80001af4:	1101                	add	sp,sp,-32
    80001af6:	ec06                	sd	ra,24(sp)
    80001af8:	e822                	sd	s0,16(sp)
    80001afa:	e426                	sd	s1,8(sp)
    80001afc:	e04a                	sd	s2,0(sp)
    80001afe:	1000                	add	s0,sp,32
    80001b00:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b02:	00000097          	auipc	ra,0x0
    80001b06:	886080e7          	jalr	-1914(ra) # 80001388 <uvmcreate>
    80001b0a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b0c:	c121                	beqz	a0,80001b4c <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b0e:	4729                	li	a4,10
    80001b10:	00005697          	auipc	a3,0x5
    80001b14:	4f068693          	add	a3,a3,1264 # 80007000 <_trampoline>
    80001b18:	6605                	lui	a2,0x1
    80001b1a:	040005b7          	lui	a1,0x4000
    80001b1e:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b20:	05b2                	sll	a1,a1,0xc
    80001b22:	fffff097          	auipc	ra,0xfffff
    80001b26:	5cc080e7          	jalr	1484(ra) # 800010ee <mappages>
    80001b2a:	02054863          	bltz	a0,80001b5a <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b2e:	4719                	li	a4,6
    80001b30:	05893683          	ld	a3,88(s2)
    80001b34:	6605                	lui	a2,0x1
    80001b36:	020005b7          	lui	a1,0x2000
    80001b3a:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b3c:	05b6                	sll	a1,a1,0xd
    80001b3e:	8526                	mv	a0,s1
    80001b40:	fffff097          	auipc	ra,0xfffff
    80001b44:	5ae080e7          	jalr	1454(ra) # 800010ee <mappages>
    80001b48:	02054163          	bltz	a0,80001b6a <proc_pagetable+0x76>
}
    80001b4c:	8526                	mv	a0,s1
    80001b4e:	60e2                	ld	ra,24(sp)
    80001b50:	6442                	ld	s0,16(sp)
    80001b52:	64a2                	ld	s1,8(sp)
    80001b54:	6902                	ld	s2,0(sp)
    80001b56:	6105                	add	sp,sp,32
    80001b58:	8082                	ret
    uvmfree(pagetable, 0);
    80001b5a:	4581                	li	a1,0
    80001b5c:	8526                	mv	a0,s1
    80001b5e:	00000097          	auipc	ra,0x0
    80001b62:	a30080e7          	jalr	-1488(ra) # 8000158e <uvmfree>
    return 0;
    80001b66:	4481                	li	s1,0
    80001b68:	b7d5                	j	80001b4c <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b6a:	4681                	li	a3,0
    80001b6c:	4605                	li	a2,1
    80001b6e:	040005b7          	lui	a1,0x4000
    80001b72:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b74:	05b2                	sll	a1,a1,0xc
    80001b76:	8526                	mv	a0,s1
    80001b78:	fffff097          	auipc	ra,0xfffff
    80001b7c:	73c080e7          	jalr	1852(ra) # 800012b4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b80:	4581                	li	a1,0
    80001b82:	8526                	mv	a0,s1
    80001b84:	00000097          	auipc	ra,0x0
    80001b88:	a0a080e7          	jalr	-1526(ra) # 8000158e <uvmfree>
    return 0;
    80001b8c:	4481                	li	s1,0
    80001b8e:	bf7d                	j	80001b4c <proc_pagetable+0x58>

0000000080001b90 <proc_freepagetable>:
{
    80001b90:	1101                	add	sp,sp,-32
    80001b92:	ec06                	sd	ra,24(sp)
    80001b94:	e822                	sd	s0,16(sp)
    80001b96:	e426                	sd	s1,8(sp)
    80001b98:	e04a                	sd	s2,0(sp)
    80001b9a:	1000                	add	s0,sp,32
    80001b9c:	84aa                	mv	s1,a0
    80001b9e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ba0:	4681                	li	a3,0
    80001ba2:	4605                	li	a2,1
    80001ba4:	040005b7          	lui	a1,0x4000
    80001ba8:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001baa:	05b2                	sll	a1,a1,0xc
    80001bac:	fffff097          	auipc	ra,0xfffff
    80001bb0:	708080e7          	jalr	1800(ra) # 800012b4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bb4:	4681                	li	a3,0
    80001bb6:	4605                	li	a2,1
    80001bb8:	020005b7          	lui	a1,0x2000
    80001bbc:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bbe:	05b6                	sll	a1,a1,0xd
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	6f2080e7          	jalr	1778(ra) # 800012b4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bca:	85ca                	mv	a1,s2
    80001bcc:	8526                	mv	a0,s1
    80001bce:	00000097          	auipc	ra,0x0
    80001bd2:	9c0080e7          	jalr	-1600(ra) # 8000158e <uvmfree>
}
    80001bd6:	60e2                	ld	ra,24(sp)
    80001bd8:	6442                	ld	s0,16(sp)
    80001bda:	64a2                	ld	s1,8(sp)
    80001bdc:	6902                	ld	s2,0(sp)
    80001bde:	6105                	add	sp,sp,32
    80001be0:	8082                	ret

0000000080001be2 <freeproc>:
{
    80001be2:	1101                	add	sp,sp,-32
    80001be4:	ec06                	sd	ra,24(sp)
    80001be6:	e822                	sd	s0,16(sp)
    80001be8:	e426                	sd	s1,8(sp)
    80001bea:	1000                	add	s0,sp,32
    80001bec:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bee:	6d28                	ld	a0,88(a0)
    80001bf0:	c509                	beqz	a0,80001bfa <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	e52080e7          	jalr	-430(ra) # 80000a44 <kfree>
  p->trapframe = 0;
    80001bfa:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bfe:	68a8                	ld	a0,80(s1)
    80001c00:	c511                	beqz	a0,80001c0c <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c02:	64ac                	ld	a1,72(s1)
    80001c04:	00000097          	auipc	ra,0x0
    80001c08:	f8c080e7          	jalr	-116(ra) # 80001b90 <proc_freepagetable>
  p->pagetable = 0;
    80001c0c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c10:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c14:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c18:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c1c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c20:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c24:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c28:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c2c:	0004ac23          	sw	zero,24(s1)
}
    80001c30:	60e2                	ld	ra,24(sp)
    80001c32:	6442                	ld	s0,16(sp)
    80001c34:	64a2                	ld	s1,8(sp)
    80001c36:	6105                	add	sp,sp,32
    80001c38:	8082                	ret

0000000080001c3a <allocproc>:
{
    80001c3a:	1101                	add	sp,sp,-32
    80001c3c:	ec06                	sd	ra,24(sp)
    80001c3e:	e822                	sd	s0,16(sp)
    80001c40:	e426                	sd	s1,8(sp)
    80001c42:	e04a                	sd	s2,0(sp)
    80001c44:	1000                	add	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c46:	00010497          	auipc	s1,0x10
    80001c4a:	a8a48493          	add	s1,s1,-1398 # 800116d0 <proc>
    80001c4e:	00015917          	auipc	s2,0x15
    80001c52:	48290913          	add	s2,s2,1154 # 800170d0 <tickslock>
    acquire(&p->lock);
    80001c56:	8526                	mv	a0,s1
    80001c58:	fffff097          	auipc	ra,0xfffff
    80001c5c:	fda080e7          	jalr	-38(ra) # 80000c32 <acquire>
    if(p->state == UNUSED) {
    80001c60:	4c9c                	lw	a5,24(s1)
    80001c62:	cf81                	beqz	a5,80001c7a <allocproc+0x40>
      release(&p->lock);
    80001c64:	8526                	mv	a0,s1
    80001c66:	fffff097          	auipc	ra,0xfffff
    80001c6a:	080080e7          	jalr	128(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c6e:	16848493          	add	s1,s1,360
    80001c72:	ff2492e3          	bne	s1,s2,80001c56 <allocproc+0x1c>
  return 0;
    80001c76:	4481                	li	s1,0
    80001c78:	a889                	j	80001cca <allocproc+0x90>
  p->pid = allocpid();
    80001c7a:	00000097          	auipc	ra,0x0
    80001c7e:	e34080e7          	jalr	-460(ra) # 80001aae <allocpid>
    80001c82:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c84:	4785                	li	a5,1
    80001c86:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c88:	fffff097          	auipc	ra,0xfffff
    80001c8c:	eba080e7          	jalr	-326(ra) # 80000b42 <kalloc>
    80001c90:	892a                	mv	s2,a0
    80001c92:	eca8                	sd	a0,88(s1)
    80001c94:	c131                	beqz	a0,80001cd8 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c96:	8526                	mv	a0,s1
    80001c98:	00000097          	auipc	ra,0x0
    80001c9c:	e5c080e7          	jalr	-420(ra) # 80001af4 <proc_pagetable>
    80001ca0:	892a                	mv	s2,a0
    80001ca2:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001ca4:	c531                	beqz	a0,80001cf0 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001ca6:	07000613          	li	a2,112
    80001caa:	4581                	li	a1,0
    80001cac:	06048513          	add	a0,s1,96
    80001cb0:	fffff097          	auipc	ra,0xfffff
    80001cb4:	07e080e7          	jalr	126(ra) # 80000d2e <memset>
  p->context.ra = (uint64)forkret;
    80001cb8:	00000797          	auipc	a5,0x0
    80001cbc:	db078793          	add	a5,a5,-592 # 80001a68 <forkret>
    80001cc0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cc2:	60bc                	ld	a5,64(s1)
    80001cc4:	6705                	lui	a4,0x1
    80001cc6:	97ba                	add	a5,a5,a4
    80001cc8:	f4bc                	sd	a5,104(s1)
}
    80001cca:	8526                	mv	a0,s1
    80001ccc:	60e2                	ld	ra,24(sp)
    80001cce:	6442                	ld	s0,16(sp)
    80001cd0:	64a2                	ld	s1,8(sp)
    80001cd2:	6902                	ld	s2,0(sp)
    80001cd4:	6105                	add	sp,sp,32
    80001cd6:	8082                	ret
    freeproc(p);
    80001cd8:	8526                	mv	a0,s1
    80001cda:	00000097          	auipc	ra,0x0
    80001cde:	f08080e7          	jalr	-248(ra) # 80001be2 <freeproc>
    release(&p->lock);
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	fffff097          	auipc	ra,0xfffff
    80001ce8:	002080e7          	jalr	2(ra) # 80000ce6 <release>
    return 0;
    80001cec:	84ca                	mv	s1,s2
    80001cee:	bff1                	j	80001cca <allocproc+0x90>
    freeproc(p);
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	00000097          	auipc	ra,0x0
    80001cf6:	ef0080e7          	jalr	-272(ra) # 80001be2 <freeproc>
    release(&p->lock);
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	fea080e7          	jalr	-22(ra) # 80000ce6 <release>
    return 0;
    80001d04:	84ca                	mv	s1,s2
    80001d06:	b7d1                	j	80001cca <allocproc+0x90>

0000000080001d08 <userinit>:
{
    80001d08:	1101                	add	sp,sp,-32
    80001d0a:	ec06                	sd	ra,24(sp)
    80001d0c:	e822                	sd	s0,16(sp)
    80001d0e:	e426                	sd	s1,8(sp)
    80001d10:	1000                	add	s0,sp,32
  p = allocproc();
    80001d12:	00000097          	auipc	ra,0x0
    80001d16:	f28080e7          	jalr	-216(ra) # 80001c3a <allocproc>
    80001d1a:	84aa                	mv	s1,a0
  initproc = p;
    80001d1c:	00007797          	auipc	a5,0x7
    80001d20:	30a7b623          	sd	a0,780(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d24:	03400613          	li	a2,52
    80001d28:	00007597          	auipc	a1,0x7
    80001d2c:	af858593          	add	a1,a1,-1288 # 80008820 <initcode>
    80001d30:	6928                	ld	a0,80(a0)
    80001d32:	fffff097          	auipc	ra,0xfffff
    80001d36:	684080e7          	jalr	1668(ra) # 800013b6 <uvminit>
  p->sz = PGSIZE;
    80001d3a:	6785                	lui	a5,0x1
    80001d3c:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d3e:	6cb8                	ld	a4,88(s1)
    80001d40:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d44:	6cb8                	ld	a4,88(s1)
    80001d46:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d48:	4641                	li	a2,16
    80001d4a:	00006597          	auipc	a1,0x6
    80001d4e:	49658593          	add	a1,a1,1174 # 800081e0 <etext+0x1e0>
    80001d52:	15848513          	add	a0,s1,344
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	11a080e7          	jalr	282(ra) # 80000e70 <safestrcpy>
  p->cwd = namei("/");
    80001d5e:	00006517          	auipc	a0,0x6
    80001d62:	49250513          	add	a0,a0,1170 # 800081f0 <etext+0x1f0>
    80001d66:	00002097          	auipc	ra,0x2
    80001d6a:	0ce080e7          	jalr	206(ra) # 80003e34 <namei>
    80001d6e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d72:	478d                	li	a5,3
    80001d74:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d76:	8526                	mv	a0,s1
    80001d78:	fffff097          	auipc	ra,0xfffff
    80001d7c:	f6e080e7          	jalr	-146(ra) # 80000ce6 <release>
}
    80001d80:	60e2                	ld	ra,24(sp)
    80001d82:	6442                	ld	s0,16(sp)
    80001d84:	64a2                	ld	s1,8(sp)
    80001d86:	6105                	add	sp,sp,32
    80001d88:	8082                	ret

0000000080001d8a <growproc>:
{
    80001d8a:	1101                	add	sp,sp,-32
    80001d8c:	ec06                	sd	ra,24(sp)
    80001d8e:	e822                	sd	s0,16(sp)
    80001d90:	e426                	sd	s1,8(sp)
    80001d92:	e04a                	sd	s2,0(sp)
    80001d94:	1000                	add	s0,sp,32
    80001d96:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d98:	00000097          	auipc	ra,0x0
    80001d9c:	c98080e7          	jalr	-872(ra) # 80001a30 <myproc>
    80001da0:	892a                	mv	s2,a0
  sz = p->sz;
    80001da2:	652c                	ld	a1,72(a0)
    80001da4:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001da8:	00904f63          	bgtz	s1,80001dc6 <growproc+0x3c>
  } else if(n < 0){
    80001dac:	0204cd63          	bltz	s1,80001de6 <growproc+0x5c>
  p->sz = sz;
    80001db0:	1782                	sll	a5,a5,0x20
    80001db2:	9381                	srl	a5,a5,0x20
    80001db4:	04f93423          	sd	a5,72(s2)
  return 0;
    80001db8:	4501                	li	a0,0
}
    80001dba:	60e2                	ld	ra,24(sp)
    80001dbc:	6442                	ld	s0,16(sp)
    80001dbe:	64a2                	ld	s1,8(sp)
    80001dc0:	6902                	ld	s2,0(sp)
    80001dc2:	6105                	add	sp,sp,32
    80001dc4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dc6:	00f4863b          	addw	a2,s1,a5
    80001dca:	1602                	sll	a2,a2,0x20
    80001dcc:	9201                	srl	a2,a2,0x20
    80001dce:	1582                	sll	a1,a1,0x20
    80001dd0:	9181                	srl	a1,a1,0x20
    80001dd2:	6928                	ld	a0,80(a0)
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	69c080e7          	jalr	1692(ra) # 80001470 <uvmalloc>
    80001ddc:	0005079b          	sext.w	a5,a0
    80001de0:	fbe1                	bnez	a5,80001db0 <growproc+0x26>
      return -1;
    80001de2:	557d                	li	a0,-1
    80001de4:	bfd9                	j	80001dba <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001de6:	00f4863b          	addw	a2,s1,a5
    80001dea:	1602                	sll	a2,a2,0x20
    80001dec:	9201                	srl	a2,a2,0x20
    80001dee:	1582                	sll	a1,a1,0x20
    80001df0:	9181                	srl	a1,a1,0x20
    80001df2:	6928                	ld	a0,80(a0)
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	634080e7          	jalr	1588(ra) # 80001428 <uvmdealloc>
    80001dfc:	0005079b          	sext.w	a5,a0
    80001e00:	bf45                	j	80001db0 <growproc+0x26>

0000000080001e02 <fork>:
{
    80001e02:	7139                	add	sp,sp,-64
    80001e04:	fc06                	sd	ra,56(sp)
    80001e06:	f822                	sd	s0,48(sp)
    80001e08:	f04a                	sd	s2,32(sp)
    80001e0a:	e456                	sd	s5,8(sp)
    80001e0c:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001e0e:	00000097          	auipc	ra,0x0
    80001e12:	c22080e7          	jalr	-990(ra) # 80001a30 <myproc>
    80001e16:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e18:	00000097          	auipc	ra,0x0
    80001e1c:	e22080e7          	jalr	-478(ra) # 80001c3a <allocproc>
    80001e20:	12050063          	beqz	a0,80001f40 <fork+0x13e>
    80001e24:	e852                	sd	s4,16(sp)
    80001e26:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e28:	048ab603          	ld	a2,72(s5)
    80001e2c:	692c                	ld	a1,80(a0)
    80001e2e:	050ab503          	ld	a0,80(s5)
    80001e32:	fffff097          	auipc	ra,0xfffff
    80001e36:	796080e7          	jalr	1942(ra) # 800015c8 <uvmcopy>
    80001e3a:	04054a63          	bltz	a0,80001e8e <fork+0x8c>
    80001e3e:	f426                	sd	s1,40(sp)
    80001e40:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e42:	048ab783          	ld	a5,72(s5)
    80001e46:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e4a:	058ab683          	ld	a3,88(s5)
    80001e4e:	87b6                	mv	a5,a3
    80001e50:	058a3703          	ld	a4,88(s4)
    80001e54:	12068693          	add	a3,a3,288
    80001e58:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e5c:	6788                	ld	a0,8(a5)
    80001e5e:	6b8c                	ld	a1,16(a5)
    80001e60:	6f90                	ld	a2,24(a5)
    80001e62:	01073023          	sd	a6,0(a4)
    80001e66:	e708                	sd	a0,8(a4)
    80001e68:	eb0c                	sd	a1,16(a4)
    80001e6a:	ef10                	sd	a2,24(a4)
    80001e6c:	02078793          	add	a5,a5,32
    80001e70:	02070713          	add	a4,a4,32
    80001e74:	fed792e3          	bne	a5,a3,80001e58 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e78:	058a3783          	ld	a5,88(s4)
    80001e7c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e80:	0d0a8493          	add	s1,s5,208
    80001e84:	0d0a0913          	add	s2,s4,208
    80001e88:	150a8993          	add	s3,s5,336
    80001e8c:	a015                	j	80001eb0 <fork+0xae>
    freeproc(np);
    80001e8e:	8552                	mv	a0,s4
    80001e90:	00000097          	auipc	ra,0x0
    80001e94:	d52080e7          	jalr	-686(ra) # 80001be2 <freeproc>
    release(&np->lock);
    80001e98:	8552                	mv	a0,s4
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	e4c080e7          	jalr	-436(ra) # 80000ce6 <release>
    return -1;
    80001ea2:	597d                	li	s2,-1
    80001ea4:	6a42                	ld	s4,16(sp)
    80001ea6:	a071                	j	80001f32 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001ea8:	04a1                	add	s1,s1,8
    80001eaa:	0921                	add	s2,s2,8
    80001eac:	01348b63          	beq	s1,s3,80001ec2 <fork+0xc0>
    if(p->ofile[i])
    80001eb0:	6088                	ld	a0,0(s1)
    80001eb2:	d97d                	beqz	a0,80001ea8 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb4:	00002097          	auipc	ra,0x2
    80001eb8:	5f8080e7          	jalr	1528(ra) # 800044ac <filedup>
    80001ebc:	00a93023          	sd	a0,0(s2)
    80001ec0:	b7e5                	j	80001ea8 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ec2:	150ab503          	ld	a0,336(s5)
    80001ec6:	00001097          	auipc	ra,0x1
    80001eca:	75e080e7          	jalr	1886(ra) # 80003624 <idup>
    80001ece:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed2:	4641                	li	a2,16
    80001ed4:	158a8593          	add	a1,s5,344
    80001ed8:	158a0513          	add	a0,s4,344
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	f94080e7          	jalr	-108(ra) # 80000e70 <safestrcpy>
  pid = np->pid;
    80001ee4:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001ee8:	8552                	mv	a0,s4
    80001eea:	fffff097          	auipc	ra,0xfffff
    80001eee:	dfc080e7          	jalr	-516(ra) # 80000ce6 <release>
  acquire(&wait_lock);
    80001ef2:	0000f497          	auipc	s1,0xf
    80001ef6:	3c648493          	add	s1,s1,966 # 800112b8 <wait_lock>
    80001efa:	8526                	mv	a0,s1
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	d36080e7          	jalr	-714(ra) # 80000c32 <acquire>
  np->parent = p;
    80001f04:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001f08:	8526                	mv	a0,s1
    80001f0a:	fffff097          	auipc	ra,0xfffff
    80001f0e:	ddc080e7          	jalr	-548(ra) # 80000ce6 <release>
  acquire(&np->lock);
    80001f12:	8552                	mv	a0,s4
    80001f14:	fffff097          	auipc	ra,0xfffff
    80001f18:	d1e080e7          	jalr	-738(ra) # 80000c32 <acquire>
  np->state = RUNNABLE;
    80001f1c:	478d                	li	a5,3
    80001f1e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f22:	8552                	mv	a0,s4
    80001f24:	fffff097          	auipc	ra,0xfffff
    80001f28:	dc2080e7          	jalr	-574(ra) # 80000ce6 <release>
  return pid;
    80001f2c:	74a2                	ld	s1,40(sp)
    80001f2e:	69e2                	ld	s3,24(sp)
    80001f30:	6a42                	ld	s4,16(sp)
}
    80001f32:	854a                	mv	a0,s2
    80001f34:	70e2                	ld	ra,56(sp)
    80001f36:	7442                	ld	s0,48(sp)
    80001f38:	7902                	ld	s2,32(sp)
    80001f3a:	6aa2                	ld	s5,8(sp)
    80001f3c:	6121                	add	sp,sp,64
    80001f3e:	8082                	ret
    return -1;
    80001f40:	597d                	li	s2,-1
    80001f42:	bfc5                	j	80001f32 <fork+0x130>

0000000080001f44 <scheduler>:
{
    80001f44:	7139                	add	sp,sp,-64
    80001f46:	fc06                	sd	ra,56(sp)
    80001f48:	f822                	sd	s0,48(sp)
    80001f4a:	f426                	sd	s1,40(sp)
    80001f4c:	f04a                	sd	s2,32(sp)
    80001f4e:	ec4e                	sd	s3,24(sp)
    80001f50:	e852                	sd	s4,16(sp)
    80001f52:	e456                	sd	s5,8(sp)
    80001f54:	e05a                	sd	s6,0(sp)
    80001f56:	0080                	add	s0,sp,64
    80001f58:	8792                	mv	a5,tp
  int id = r_tp();
    80001f5a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f5c:	00779a93          	sll	s5,a5,0x7
    80001f60:	0000f717          	auipc	a4,0xf
    80001f64:	34070713          	add	a4,a4,832 # 800112a0 <pid_lock>
    80001f68:	9756                	add	a4,a4,s5
    80001f6a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f6e:	0000f717          	auipc	a4,0xf
    80001f72:	36a70713          	add	a4,a4,874 # 800112d8 <cpus+0x8>
    80001f76:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f78:	498d                	li	s3,3
        p->state = RUNNING;
    80001f7a:	4b11                	li	s6,4
        c->proc = p;
    80001f7c:	079e                	sll	a5,a5,0x7
    80001f7e:	0000fa17          	auipc	s4,0xf
    80001f82:	322a0a13          	add	s4,s4,802 # 800112a0 <pid_lock>
    80001f86:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f88:	00015917          	auipc	s2,0x15
    80001f8c:	14890913          	add	s2,s2,328 # 800170d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f94:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f98:	10079073          	csrw	sstatus,a5
    80001f9c:	0000f497          	auipc	s1,0xf
    80001fa0:	73448493          	add	s1,s1,1844 # 800116d0 <proc>
    80001fa4:	a811                	j	80001fb8 <scheduler+0x74>
      release(&p->lock);
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	fffff097          	auipc	ra,0xfffff
    80001fac:	d3e080e7          	jalr	-706(ra) # 80000ce6 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fb0:	16848493          	add	s1,s1,360
    80001fb4:	fd248ee3          	beq	s1,s2,80001f90 <scheduler+0x4c>
      acquire(&p->lock);
    80001fb8:	8526                	mv	a0,s1
    80001fba:	fffff097          	auipc	ra,0xfffff
    80001fbe:	c78080e7          	jalr	-904(ra) # 80000c32 <acquire>
      if(p->state == RUNNABLE) {
    80001fc2:	4c9c                	lw	a5,24(s1)
    80001fc4:	ff3791e3          	bne	a5,s3,80001fa6 <scheduler+0x62>
        p->state = RUNNING;
    80001fc8:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fcc:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fd0:	06048593          	add	a1,s1,96
    80001fd4:	8556                	mv	a0,s5
    80001fd6:	00000097          	auipc	ra,0x0
    80001fda:	620080e7          	jalr	1568(ra) # 800025f6 <swtch>
        c->proc = 0;
    80001fde:	020a3823          	sd	zero,48(s4)
    80001fe2:	b7d1                	j	80001fa6 <scheduler+0x62>

0000000080001fe4 <sched>:
{
    80001fe4:	7179                	add	sp,sp,-48
    80001fe6:	f406                	sd	ra,40(sp)
    80001fe8:	f022                	sd	s0,32(sp)
    80001fea:	ec26                	sd	s1,24(sp)
    80001fec:	e84a                	sd	s2,16(sp)
    80001fee:	e44e                	sd	s3,8(sp)
    80001ff0:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80001ff2:	00000097          	auipc	ra,0x0
    80001ff6:	a3e080e7          	jalr	-1474(ra) # 80001a30 <myproc>
    80001ffa:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ffc:	fffff097          	auipc	ra,0xfffff
    80002000:	bbc080e7          	jalr	-1092(ra) # 80000bb8 <holding>
    80002004:	c93d                	beqz	a0,8000207a <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002006:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002008:	2781                	sext.w	a5,a5
    8000200a:	079e                	sll	a5,a5,0x7
    8000200c:	0000f717          	auipc	a4,0xf
    80002010:	29470713          	add	a4,a4,660 # 800112a0 <pid_lock>
    80002014:	97ba                	add	a5,a5,a4
    80002016:	0a87a703          	lw	a4,168(a5)
    8000201a:	4785                	li	a5,1
    8000201c:	06f71763          	bne	a4,a5,8000208a <sched+0xa6>
  if(p->state == RUNNING)
    80002020:	4c98                	lw	a4,24(s1)
    80002022:	4791                	li	a5,4
    80002024:	06f70b63          	beq	a4,a5,8000209a <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002028:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000202c:	8b89                	and	a5,a5,2
  if(intr_get())
    8000202e:	efb5                	bnez	a5,800020aa <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002030:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002032:	0000f917          	auipc	s2,0xf
    80002036:	26e90913          	add	s2,s2,622 # 800112a0 <pid_lock>
    8000203a:	2781                	sext.w	a5,a5
    8000203c:	079e                	sll	a5,a5,0x7
    8000203e:	97ca                	add	a5,a5,s2
    80002040:	0ac7a983          	lw	s3,172(a5)
    80002044:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002046:	2781                	sext.w	a5,a5
    80002048:	079e                	sll	a5,a5,0x7
    8000204a:	0000f597          	auipc	a1,0xf
    8000204e:	28e58593          	add	a1,a1,654 # 800112d8 <cpus+0x8>
    80002052:	95be                	add	a1,a1,a5
    80002054:	06048513          	add	a0,s1,96
    80002058:	00000097          	auipc	ra,0x0
    8000205c:	59e080e7          	jalr	1438(ra) # 800025f6 <swtch>
    80002060:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002062:	2781                	sext.w	a5,a5
    80002064:	079e                	sll	a5,a5,0x7
    80002066:	993e                	add	s2,s2,a5
    80002068:	0b392623          	sw	s3,172(s2)
}
    8000206c:	70a2                	ld	ra,40(sp)
    8000206e:	7402                	ld	s0,32(sp)
    80002070:	64e2                	ld	s1,24(sp)
    80002072:	6942                	ld	s2,16(sp)
    80002074:	69a2                	ld	s3,8(sp)
    80002076:	6145                	add	sp,sp,48
    80002078:	8082                	ret
    panic("sched p->lock");
    8000207a:	00006517          	auipc	a0,0x6
    8000207e:	17e50513          	add	a0,a0,382 # 800081f8 <etext+0x1f8>
    80002082:	ffffe097          	auipc	ra,0xffffe
    80002086:	4d8080e7          	jalr	1240(ra) # 8000055a <panic>
    panic("sched locks");
    8000208a:	00006517          	auipc	a0,0x6
    8000208e:	17e50513          	add	a0,a0,382 # 80008208 <etext+0x208>
    80002092:	ffffe097          	auipc	ra,0xffffe
    80002096:	4c8080e7          	jalr	1224(ra) # 8000055a <panic>
    panic("sched running");
    8000209a:	00006517          	auipc	a0,0x6
    8000209e:	17e50513          	add	a0,a0,382 # 80008218 <etext+0x218>
    800020a2:	ffffe097          	auipc	ra,0xffffe
    800020a6:	4b8080e7          	jalr	1208(ra) # 8000055a <panic>
    panic("sched interruptible");
    800020aa:	00006517          	auipc	a0,0x6
    800020ae:	17e50513          	add	a0,a0,382 # 80008228 <etext+0x228>
    800020b2:	ffffe097          	auipc	ra,0xffffe
    800020b6:	4a8080e7          	jalr	1192(ra) # 8000055a <panic>

00000000800020ba <yield>:
{
    800020ba:	1101                	add	sp,sp,-32
    800020bc:	ec06                	sd	ra,24(sp)
    800020be:	e822                	sd	s0,16(sp)
    800020c0:	e426                	sd	s1,8(sp)
    800020c2:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    800020c4:	00000097          	auipc	ra,0x0
    800020c8:	96c080e7          	jalr	-1684(ra) # 80001a30 <myproc>
    800020cc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	b64080e7          	jalr	-1180(ra) # 80000c32 <acquire>
  p->state = RUNNABLE;
    800020d6:	478d                	li	a5,3
    800020d8:	cc9c                	sw	a5,24(s1)
  sched();
    800020da:	00000097          	auipc	ra,0x0
    800020de:	f0a080e7          	jalr	-246(ra) # 80001fe4 <sched>
  release(&p->lock);
    800020e2:	8526                	mv	a0,s1
    800020e4:	fffff097          	auipc	ra,0xfffff
    800020e8:	c02080e7          	jalr	-1022(ra) # 80000ce6 <release>
}
    800020ec:	60e2                	ld	ra,24(sp)
    800020ee:	6442                	ld	s0,16(sp)
    800020f0:	64a2                	ld	s1,8(sp)
    800020f2:	6105                	add	sp,sp,32
    800020f4:	8082                	ret

00000000800020f6 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020f6:	7179                	add	sp,sp,-48
    800020f8:	f406                	sd	ra,40(sp)
    800020fa:	f022                	sd	s0,32(sp)
    800020fc:	ec26                	sd	s1,24(sp)
    800020fe:	e84a                	sd	s2,16(sp)
    80002100:	e44e                	sd	s3,8(sp)
    80002102:	1800                	add	s0,sp,48
    80002104:	89aa                	mv	s3,a0
    80002106:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002108:	00000097          	auipc	ra,0x0
    8000210c:	928080e7          	jalr	-1752(ra) # 80001a30 <myproc>
    80002110:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	b20080e7          	jalr	-1248(ra) # 80000c32 <acquire>
  release(lk);
    8000211a:	854a                	mv	a0,s2
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	bca080e7          	jalr	-1078(ra) # 80000ce6 <release>

  // Go to sleep.
  p->chan = chan;
    80002124:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002128:	4789                	li	a5,2
    8000212a:	cc9c                	sw	a5,24(s1)

  sched();
    8000212c:	00000097          	auipc	ra,0x0
    80002130:	eb8080e7          	jalr	-328(ra) # 80001fe4 <sched>

  // Tidy up.
  p->chan = 0;
    80002134:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002138:	8526                	mv	a0,s1
    8000213a:	fffff097          	auipc	ra,0xfffff
    8000213e:	bac080e7          	jalr	-1108(ra) # 80000ce6 <release>
  acquire(lk);
    80002142:	854a                	mv	a0,s2
    80002144:	fffff097          	auipc	ra,0xfffff
    80002148:	aee080e7          	jalr	-1298(ra) # 80000c32 <acquire>
}
    8000214c:	70a2                	ld	ra,40(sp)
    8000214e:	7402                	ld	s0,32(sp)
    80002150:	64e2                	ld	s1,24(sp)
    80002152:	6942                	ld	s2,16(sp)
    80002154:	69a2                	ld	s3,8(sp)
    80002156:	6145                	add	sp,sp,48
    80002158:	8082                	ret

000000008000215a <wait>:
{
    8000215a:	715d                	add	sp,sp,-80
    8000215c:	e486                	sd	ra,72(sp)
    8000215e:	e0a2                	sd	s0,64(sp)
    80002160:	fc26                	sd	s1,56(sp)
    80002162:	f84a                	sd	s2,48(sp)
    80002164:	f44e                	sd	s3,40(sp)
    80002166:	f052                	sd	s4,32(sp)
    80002168:	ec56                	sd	s5,24(sp)
    8000216a:	e85a                	sd	s6,16(sp)
    8000216c:	e45e                	sd	s7,8(sp)
    8000216e:	e062                	sd	s8,0(sp)
    80002170:	0880                	add	s0,sp,80
    80002172:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002174:	00000097          	auipc	ra,0x0
    80002178:	8bc080e7          	jalr	-1860(ra) # 80001a30 <myproc>
    8000217c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000217e:	0000f517          	auipc	a0,0xf
    80002182:	13a50513          	add	a0,a0,314 # 800112b8 <wait_lock>
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	aac080e7          	jalr	-1364(ra) # 80000c32 <acquire>
    havekids = 0;
    8000218e:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002190:	4a15                	li	s4,5
        havekids = 1;
    80002192:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002194:	00015997          	auipc	s3,0x15
    80002198:	f3c98993          	add	s3,s3,-196 # 800170d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000219c:	0000fc17          	auipc	s8,0xf
    800021a0:	11cc0c13          	add	s8,s8,284 # 800112b8 <wait_lock>
    800021a4:	a87d                	j	80002262 <wait+0x108>
          pid = np->pid;
    800021a6:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800021aa:	000b0e63          	beqz	s6,800021c6 <wait+0x6c>
    800021ae:	4691                	li	a3,4
    800021b0:	02c48613          	add	a2,s1,44
    800021b4:	85da                	mv	a1,s6
    800021b6:	05093503          	ld	a0,80(s2)
    800021ba:	fffff097          	auipc	ra,0xfffff
    800021be:	512080e7          	jalr	1298(ra) # 800016cc <copyout>
    800021c2:	04054163          	bltz	a0,80002204 <wait+0xaa>
          freeproc(np);
    800021c6:	8526                	mv	a0,s1
    800021c8:	00000097          	auipc	ra,0x0
    800021cc:	a1a080e7          	jalr	-1510(ra) # 80001be2 <freeproc>
          release(&np->lock);
    800021d0:	8526                	mv	a0,s1
    800021d2:	fffff097          	auipc	ra,0xfffff
    800021d6:	b14080e7          	jalr	-1260(ra) # 80000ce6 <release>
          release(&wait_lock);
    800021da:	0000f517          	auipc	a0,0xf
    800021de:	0de50513          	add	a0,a0,222 # 800112b8 <wait_lock>
    800021e2:	fffff097          	auipc	ra,0xfffff
    800021e6:	b04080e7          	jalr	-1276(ra) # 80000ce6 <release>
}
    800021ea:	854e                	mv	a0,s3
    800021ec:	60a6                	ld	ra,72(sp)
    800021ee:	6406                	ld	s0,64(sp)
    800021f0:	74e2                	ld	s1,56(sp)
    800021f2:	7942                	ld	s2,48(sp)
    800021f4:	79a2                	ld	s3,40(sp)
    800021f6:	7a02                	ld	s4,32(sp)
    800021f8:	6ae2                	ld	s5,24(sp)
    800021fa:	6b42                	ld	s6,16(sp)
    800021fc:	6ba2                	ld	s7,8(sp)
    800021fe:	6c02                	ld	s8,0(sp)
    80002200:	6161                	add	sp,sp,80
    80002202:	8082                	ret
            release(&np->lock);
    80002204:	8526                	mv	a0,s1
    80002206:	fffff097          	auipc	ra,0xfffff
    8000220a:	ae0080e7          	jalr	-1312(ra) # 80000ce6 <release>
            release(&wait_lock);
    8000220e:	0000f517          	auipc	a0,0xf
    80002212:	0aa50513          	add	a0,a0,170 # 800112b8 <wait_lock>
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	ad0080e7          	jalr	-1328(ra) # 80000ce6 <release>
            return -1;
    8000221e:	59fd                	li	s3,-1
    80002220:	b7e9                	j	800021ea <wait+0x90>
    for(np = proc; np < &proc[NPROC]; np++){
    80002222:	16848493          	add	s1,s1,360
    80002226:	03348463          	beq	s1,s3,8000224e <wait+0xf4>
      if(np->parent == p){
    8000222a:	7c9c                	ld	a5,56(s1)
    8000222c:	ff279be3          	bne	a5,s2,80002222 <wait+0xc8>
        acquire(&np->lock);
    80002230:	8526                	mv	a0,s1
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	a00080e7          	jalr	-1536(ra) # 80000c32 <acquire>
        if(np->state == ZOMBIE){
    8000223a:	4c9c                	lw	a5,24(s1)
    8000223c:	f74785e3          	beq	a5,s4,800021a6 <wait+0x4c>
        release(&np->lock);
    80002240:	8526                	mv	a0,s1
    80002242:	fffff097          	auipc	ra,0xfffff
    80002246:	aa4080e7          	jalr	-1372(ra) # 80000ce6 <release>
        havekids = 1;
    8000224a:	8756                	mv	a4,s5
    8000224c:	bfd9                	j	80002222 <wait+0xc8>
    if(!havekids || p->killed){
    8000224e:	c305                	beqz	a4,8000226e <wait+0x114>
    80002250:	02892783          	lw	a5,40(s2)
    80002254:	ef89                	bnez	a5,8000226e <wait+0x114>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002256:	85e2                	mv	a1,s8
    80002258:	854a                	mv	a0,s2
    8000225a:	00000097          	auipc	ra,0x0
    8000225e:	e9c080e7          	jalr	-356(ra) # 800020f6 <sleep>
    havekids = 0;
    80002262:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002264:	0000f497          	auipc	s1,0xf
    80002268:	46c48493          	add	s1,s1,1132 # 800116d0 <proc>
    8000226c:	bf7d                	j	8000222a <wait+0xd0>
      release(&wait_lock);
    8000226e:	0000f517          	auipc	a0,0xf
    80002272:	04a50513          	add	a0,a0,74 # 800112b8 <wait_lock>
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	a70080e7          	jalr	-1424(ra) # 80000ce6 <release>
      return -1;
    8000227e:	59fd                	li	s3,-1
    80002280:	b7ad                	j	800021ea <wait+0x90>

0000000080002282 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002282:	7139                	add	sp,sp,-64
    80002284:	fc06                	sd	ra,56(sp)
    80002286:	f822                	sd	s0,48(sp)
    80002288:	f426                	sd	s1,40(sp)
    8000228a:	f04a                	sd	s2,32(sp)
    8000228c:	ec4e                	sd	s3,24(sp)
    8000228e:	e852                	sd	s4,16(sp)
    80002290:	e456                	sd	s5,8(sp)
    80002292:	0080                	add	s0,sp,64
    80002294:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002296:	0000f497          	auipc	s1,0xf
    8000229a:	43a48493          	add	s1,s1,1082 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000229e:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022a0:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800022a2:	00015917          	auipc	s2,0x15
    800022a6:	e2e90913          	add	s2,s2,-466 # 800170d0 <tickslock>
    800022aa:	a811                	j	800022be <wakeup+0x3c>
      }
      release(&p->lock);
    800022ac:	8526                	mv	a0,s1
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	a38080e7          	jalr	-1480(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022b6:	16848493          	add	s1,s1,360
    800022ba:	03248663          	beq	s1,s2,800022e6 <wakeup+0x64>
    if(p != myproc()){
    800022be:	fffff097          	auipc	ra,0xfffff
    800022c2:	772080e7          	jalr	1906(ra) # 80001a30 <myproc>
    800022c6:	fea488e3          	beq	s1,a0,800022b6 <wakeup+0x34>
      acquire(&p->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	966080e7          	jalr	-1690(ra) # 80000c32 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022d4:	4c9c                	lw	a5,24(s1)
    800022d6:	fd379be3          	bne	a5,s3,800022ac <wakeup+0x2a>
    800022da:	709c                	ld	a5,32(s1)
    800022dc:	fd4798e3          	bne	a5,s4,800022ac <wakeup+0x2a>
        p->state = RUNNABLE;
    800022e0:	0154ac23          	sw	s5,24(s1)
    800022e4:	b7e1                	j	800022ac <wakeup+0x2a>
    }
  }
}
    800022e6:	70e2                	ld	ra,56(sp)
    800022e8:	7442                	ld	s0,48(sp)
    800022ea:	74a2                	ld	s1,40(sp)
    800022ec:	7902                	ld	s2,32(sp)
    800022ee:	69e2                	ld	s3,24(sp)
    800022f0:	6a42                	ld	s4,16(sp)
    800022f2:	6aa2                	ld	s5,8(sp)
    800022f4:	6121                	add	sp,sp,64
    800022f6:	8082                	ret

00000000800022f8 <reparent>:
{
    800022f8:	7179                	add	sp,sp,-48
    800022fa:	f406                	sd	ra,40(sp)
    800022fc:	f022                	sd	s0,32(sp)
    800022fe:	ec26                	sd	s1,24(sp)
    80002300:	e84a                	sd	s2,16(sp)
    80002302:	e44e                	sd	s3,8(sp)
    80002304:	e052                	sd	s4,0(sp)
    80002306:	1800                	add	s0,sp,48
    80002308:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000230a:	0000f497          	auipc	s1,0xf
    8000230e:	3c648493          	add	s1,s1,966 # 800116d0 <proc>
      pp->parent = initproc;
    80002312:	00007a17          	auipc	s4,0x7
    80002316:	d16a0a13          	add	s4,s4,-746 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000231a:	00015997          	auipc	s3,0x15
    8000231e:	db698993          	add	s3,s3,-586 # 800170d0 <tickslock>
    80002322:	a029                	j	8000232c <reparent+0x34>
    80002324:	16848493          	add	s1,s1,360
    80002328:	01348d63          	beq	s1,s3,80002342 <reparent+0x4a>
    if(pp->parent == p){
    8000232c:	7c9c                	ld	a5,56(s1)
    8000232e:	ff279be3          	bne	a5,s2,80002324 <reparent+0x2c>
      pp->parent = initproc;
    80002332:	000a3503          	ld	a0,0(s4)
    80002336:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002338:	00000097          	auipc	ra,0x0
    8000233c:	f4a080e7          	jalr	-182(ra) # 80002282 <wakeup>
    80002340:	b7d5                	j	80002324 <reparent+0x2c>
}
    80002342:	70a2                	ld	ra,40(sp)
    80002344:	7402                	ld	s0,32(sp)
    80002346:	64e2                	ld	s1,24(sp)
    80002348:	6942                	ld	s2,16(sp)
    8000234a:	69a2                	ld	s3,8(sp)
    8000234c:	6a02                	ld	s4,0(sp)
    8000234e:	6145                	add	sp,sp,48
    80002350:	8082                	ret

0000000080002352 <exit>:
{
    80002352:	7179                	add	sp,sp,-48
    80002354:	f406                	sd	ra,40(sp)
    80002356:	f022                	sd	s0,32(sp)
    80002358:	ec26                	sd	s1,24(sp)
    8000235a:	e84a                	sd	s2,16(sp)
    8000235c:	e44e                	sd	s3,8(sp)
    8000235e:	e052                	sd	s4,0(sp)
    80002360:	1800                	add	s0,sp,48
    80002362:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002364:	fffff097          	auipc	ra,0xfffff
    80002368:	6cc080e7          	jalr	1740(ra) # 80001a30 <myproc>
    8000236c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000236e:	00007797          	auipc	a5,0x7
    80002372:	cba7b783          	ld	a5,-838(a5) # 80009028 <initproc>
    80002376:	0d050493          	add	s1,a0,208
    8000237a:	15050913          	add	s2,a0,336
    8000237e:	02a79363          	bne	a5,a0,800023a4 <exit+0x52>
    panic("init exiting");
    80002382:	00006517          	auipc	a0,0x6
    80002386:	ebe50513          	add	a0,a0,-322 # 80008240 <etext+0x240>
    8000238a:	ffffe097          	auipc	ra,0xffffe
    8000238e:	1d0080e7          	jalr	464(ra) # 8000055a <panic>
      fileclose(f);
    80002392:	00002097          	auipc	ra,0x2
    80002396:	16c080e7          	jalr	364(ra) # 800044fe <fileclose>
      p->ofile[fd] = 0;
    8000239a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000239e:	04a1                	add	s1,s1,8
    800023a0:	01248563          	beq	s1,s2,800023aa <exit+0x58>
    if(p->ofile[fd]){
    800023a4:	6088                	ld	a0,0(s1)
    800023a6:	f575                	bnez	a0,80002392 <exit+0x40>
    800023a8:	bfdd                	j	8000239e <exit+0x4c>
  begin_op();
    800023aa:	00002097          	auipc	ra,0x2
    800023ae:	c8a080e7          	jalr	-886(ra) # 80004034 <begin_op>
  iput(p->cwd);
    800023b2:	1509b503          	ld	a0,336(s3)
    800023b6:	00001097          	auipc	ra,0x1
    800023ba:	46a080e7          	jalr	1130(ra) # 80003820 <iput>
  end_op();
    800023be:	00002097          	auipc	ra,0x2
    800023c2:	cf0080e7          	jalr	-784(ra) # 800040ae <end_op>
  p->cwd = 0;
    800023c6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800023ca:	0000f497          	auipc	s1,0xf
    800023ce:	eee48493          	add	s1,s1,-274 # 800112b8 <wait_lock>
    800023d2:	8526                	mv	a0,s1
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	85e080e7          	jalr	-1954(ra) # 80000c32 <acquire>
  reparent(p);
    800023dc:	854e                	mv	a0,s3
    800023de:	00000097          	auipc	ra,0x0
    800023e2:	f1a080e7          	jalr	-230(ra) # 800022f8 <reparent>
  wakeup(p->parent);
    800023e6:	0389b503          	ld	a0,56(s3)
    800023ea:	00000097          	auipc	ra,0x0
    800023ee:	e98080e7          	jalr	-360(ra) # 80002282 <wakeup>
  acquire(&p->lock);
    800023f2:	854e                	mv	a0,s3
    800023f4:	fffff097          	auipc	ra,0xfffff
    800023f8:	83e080e7          	jalr	-1986(ra) # 80000c32 <acquire>
  p->xstate = status;
    800023fc:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002400:	4795                	li	a5,5
    80002402:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002406:	8526                	mv	a0,s1
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	8de080e7          	jalr	-1826(ra) # 80000ce6 <release>
  sched();
    80002410:	00000097          	auipc	ra,0x0
    80002414:	bd4080e7          	jalr	-1068(ra) # 80001fe4 <sched>
  panic("zombie exit");
    80002418:	00006517          	auipc	a0,0x6
    8000241c:	e3850513          	add	a0,a0,-456 # 80008250 <etext+0x250>
    80002420:	ffffe097          	auipc	ra,0xffffe
    80002424:	13a080e7          	jalr	314(ra) # 8000055a <panic>

0000000080002428 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002428:	7179                	add	sp,sp,-48
    8000242a:	f406                	sd	ra,40(sp)
    8000242c:	f022                	sd	s0,32(sp)
    8000242e:	ec26                	sd	s1,24(sp)
    80002430:	e84a                	sd	s2,16(sp)
    80002432:	e44e                	sd	s3,8(sp)
    80002434:	1800                	add	s0,sp,48
    80002436:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002438:	0000f497          	auipc	s1,0xf
    8000243c:	29848493          	add	s1,s1,664 # 800116d0 <proc>
    80002440:	00015997          	auipc	s3,0x15
    80002444:	c9098993          	add	s3,s3,-880 # 800170d0 <tickslock>
    acquire(&p->lock);
    80002448:	8526                	mv	a0,s1
    8000244a:	ffffe097          	auipc	ra,0xffffe
    8000244e:	7e8080e7          	jalr	2024(ra) # 80000c32 <acquire>
    if(p->pid == pid){
    80002452:	589c                	lw	a5,48(s1)
    80002454:	01278d63          	beq	a5,s2,8000246e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002458:	8526                	mv	a0,s1
    8000245a:	fffff097          	auipc	ra,0xfffff
    8000245e:	88c080e7          	jalr	-1908(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002462:	16848493          	add	s1,s1,360
    80002466:	ff3491e3          	bne	s1,s3,80002448 <kill+0x20>
  }
  return -1;
    8000246a:	557d                	li	a0,-1
    8000246c:	a829                	j	80002486 <kill+0x5e>
      p->killed = 1;
    8000246e:	4785                	li	a5,1
    80002470:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002472:	4c98                	lw	a4,24(s1)
    80002474:	4789                	li	a5,2
    80002476:	00f70f63          	beq	a4,a5,80002494 <kill+0x6c>
      release(&p->lock);
    8000247a:	8526                	mv	a0,s1
    8000247c:	fffff097          	auipc	ra,0xfffff
    80002480:	86a080e7          	jalr	-1942(ra) # 80000ce6 <release>
      return 0;
    80002484:	4501                	li	a0,0
}
    80002486:	70a2                	ld	ra,40(sp)
    80002488:	7402                	ld	s0,32(sp)
    8000248a:	64e2                	ld	s1,24(sp)
    8000248c:	6942                	ld	s2,16(sp)
    8000248e:	69a2                	ld	s3,8(sp)
    80002490:	6145                	add	sp,sp,48
    80002492:	8082                	ret
        p->state = RUNNABLE;
    80002494:	478d                	li	a5,3
    80002496:	cc9c                	sw	a5,24(s1)
    80002498:	b7cd                	j	8000247a <kill+0x52>

000000008000249a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000249a:	7179                	add	sp,sp,-48
    8000249c:	f406                	sd	ra,40(sp)
    8000249e:	f022                	sd	s0,32(sp)
    800024a0:	ec26                	sd	s1,24(sp)
    800024a2:	e84a                	sd	s2,16(sp)
    800024a4:	e44e                	sd	s3,8(sp)
    800024a6:	e052                	sd	s4,0(sp)
    800024a8:	1800                	add	s0,sp,48
    800024aa:	84aa                	mv	s1,a0
    800024ac:	892e                	mv	s2,a1
    800024ae:	89b2                	mv	s3,a2
    800024b0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024b2:	fffff097          	auipc	ra,0xfffff
    800024b6:	57e080e7          	jalr	1406(ra) # 80001a30 <myproc>
  if(user_dst){
    800024ba:	c08d                	beqz	s1,800024dc <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024bc:	86d2                	mv	a3,s4
    800024be:	864e                	mv	a2,s3
    800024c0:	85ca                	mv	a1,s2
    800024c2:	6928                	ld	a0,80(a0)
    800024c4:	fffff097          	auipc	ra,0xfffff
    800024c8:	208080e7          	jalr	520(ra) # 800016cc <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024cc:	70a2                	ld	ra,40(sp)
    800024ce:	7402                	ld	s0,32(sp)
    800024d0:	64e2                	ld	s1,24(sp)
    800024d2:	6942                	ld	s2,16(sp)
    800024d4:	69a2                	ld	s3,8(sp)
    800024d6:	6a02                	ld	s4,0(sp)
    800024d8:	6145                	add	sp,sp,48
    800024da:	8082                	ret
    memmove((char *)dst, src, len);
    800024dc:	000a061b          	sext.w	a2,s4
    800024e0:	85ce                	mv	a1,s3
    800024e2:	854a                	mv	a0,s2
    800024e4:	fffff097          	auipc	ra,0xfffff
    800024e8:	8a6080e7          	jalr	-1882(ra) # 80000d8a <memmove>
    return 0;
    800024ec:	8526                	mv	a0,s1
    800024ee:	bff9                	j	800024cc <either_copyout+0x32>

00000000800024f0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024f0:	7179                	add	sp,sp,-48
    800024f2:	f406                	sd	ra,40(sp)
    800024f4:	f022                	sd	s0,32(sp)
    800024f6:	ec26                	sd	s1,24(sp)
    800024f8:	e84a                	sd	s2,16(sp)
    800024fa:	e44e                	sd	s3,8(sp)
    800024fc:	e052                	sd	s4,0(sp)
    800024fe:	1800                	add	s0,sp,48
    80002500:	892a                	mv	s2,a0
    80002502:	84ae                	mv	s1,a1
    80002504:	89b2                	mv	s3,a2
    80002506:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002508:	fffff097          	auipc	ra,0xfffff
    8000250c:	528080e7          	jalr	1320(ra) # 80001a30 <myproc>
  if(user_src){
    80002510:	c08d                	beqz	s1,80002532 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002512:	86d2                	mv	a3,s4
    80002514:	864e                	mv	a2,s3
    80002516:	85ca                	mv	a1,s2
    80002518:	6928                	ld	a0,80(a0)
    8000251a:	fffff097          	auipc	ra,0xfffff
    8000251e:	23e080e7          	jalr	574(ra) # 80001758 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002522:	70a2                	ld	ra,40(sp)
    80002524:	7402                	ld	s0,32(sp)
    80002526:	64e2                	ld	s1,24(sp)
    80002528:	6942                	ld	s2,16(sp)
    8000252a:	69a2                	ld	s3,8(sp)
    8000252c:	6a02                	ld	s4,0(sp)
    8000252e:	6145                	add	sp,sp,48
    80002530:	8082                	ret
    memmove(dst, (char*)src, len);
    80002532:	000a061b          	sext.w	a2,s4
    80002536:	85ce                	mv	a1,s3
    80002538:	854a                	mv	a0,s2
    8000253a:	fffff097          	auipc	ra,0xfffff
    8000253e:	850080e7          	jalr	-1968(ra) # 80000d8a <memmove>
    return 0;
    80002542:	8526                	mv	a0,s1
    80002544:	bff9                	j	80002522 <either_copyin+0x32>

0000000080002546 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002546:	715d                	add	sp,sp,-80
    80002548:	e486                	sd	ra,72(sp)
    8000254a:	e0a2                	sd	s0,64(sp)
    8000254c:	fc26                	sd	s1,56(sp)
    8000254e:	f84a                	sd	s2,48(sp)
    80002550:	f44e                	sd	s3,40(sp)
    80002552:	f052                	sd	s4,32(sp)
    80002554:	ec56                	sd	s5,24(sp)
    80002556:	e85a                	sd	s6,16(sp)
    80002558:	e45e                	sd	s7,8(sp)
    8000255a:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000255c:	00006517          	auipc	a0,0x6
    80002560:	ab450513          	add	a0,a0,-1356 # 80008010 <etext+0x10>
    80002564:	ffffe097          	auipc	ra,0xffffe
    80002568:	040080e7          	jalr	64(ra) # 800005a4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000256c:	0000f497          	auipc	s1,0xf
    80002570:	2bc48493          	add	s1,s1,700 # 80011828 <proc+0x158>
    80002574:	00015917          	auipc	s2,0x15
    80002578:	cb490913          	add	s2,s2,-844 # 80017228 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000257c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000257e:	00006997          	auipc	s3,0x6
    80002582:	ce298993          	add	s3,s3,-798 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    80002586:	00006a97          	auipc	s5,0x6
    8000258a:	ce2a8a93          	add	s5,s5,-798 # 80008268 <etext+0x268>
    printf("\n");
    8000258e:	00006a17          	auipc	s4,0x6
    80002592:	a82a0a13          	add	s4,s4,-1406 # 80008010 <etext+0x10>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002596:	00006b97          	auipc	s7,0x6
    8000259a:	17ab8b93          	add	s7,s7,378 # 80008710 <states.0>
    8000259e:	a00d                	j	800025c0 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025a0:	ed86a583          	lw	a1,-296(a3)
    800025a4:	8556                	mv	a0,s5
    800025a6:	ffffe097          	auipc	ra,0xffffe
    800025aa:	ffe080e7          	jalr	-2(ra) # 800005a4 <printf>
    printf("\n");
    800025ae:	8552                	mv	a0,s4
    800025b0:	ffffe097          	auipc	ra,0xffffe
    800025b4:	ff4080e7          	jalr	-12(ra) # 800005a4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025b8:	16848493          	add	s1,s1,360
    800025bc:	03248263          	beq	s1,s2,800025e0 <procdump+0x9a>
    if(p->state == UNUSED)
    800025c0:	86a6                	mv	a3,s1
    800025c2:	ec04a783          	lw	a5,-320(s1)
    800025c6:	dbed                	beqz	a5,800025b8 <procdump+0x72>
      state = "???";
    800025c8:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ca:	fcfb6be3          	bltu	s6,a5,800025a0 <procdump+0x5a>
    800025ce:	02079713          	sll	a4,a5,0x20
    800025d2:	01d75793          	srl	a5,a4,0x1d
    800025d6:	97de                	add	a5,a5,s7
    800025d8:	6390                	ld	a2,0(a5)
    800025da:	f279                	bnez	a2,800025a0 <procdump+0x5a>
      state = "???";
    800025dc:	864e                	mv	a2,s3
    800025de:	b7c9                	j	800025a0 <procdump+0x5a>
  }
}
    800025e0:	60a6                	ld	ra,72(sp)
    800025e2:	6406                	ld	s0,64(sp)
    800025e4:	74e2                	ld	s1,56(sp)
    800025e6:	7942                	ld	s2,48(sp)
    800025e8:	79a2                	ld	s3,40(sp)
    800025ea:	7a02                	ld	s4,32(sp)
    800025ec:	6ae2                	ld	s5,24(sp)
    800025ee:	6b42                	ld	s6,16(sp)
    800025f0:	6ba2                	ld	s7,8(sp)
    800025f2:	6161                	add	sp,sp,80
    800025f4:	8082                	ret

00000000800025f6 <swtch>:
    800025f6:	00153023          	sd	ra,0(a0)
    800025fa:	00253423          	sd	sp,8(a0)
    800025fe:	e900                	sd	s0,16(a0)
    80002600:	ed04                	sd	s1,24(a0)
    80002602:	03253023          	sd	s2,32(a0)
    80002606:	03353423          	sd	s3,40(a0)
    8000260a:	03453823          	sd	s4,48(a0)
    8000260e:	03553c23          	sd	s5,56(a0)
    80002612:	05653023          	sd	s6,64(a0)
    80002616:	05753423          	sd	s7,72(a0)
    8000261a:	05853823          	sd	s8,80(a0)
    8000261e:	05953c23          	sd	s9,88(a0)
    80002622:	07a53023          	sd	s10,96(a0)
    80002626:	07b53423          	sd	s11,104(a0)
    8000262a:	0005b083          	ld	ra,0(a1)
    8000262e:	0085b103          	ld	sp,8(a1)
    80002632:	6980                	ld	s0,16(a1)
    80002634:	6d84                	ld	s1,24(a1)
    80002636:	0205b903          	ld	s2,32(a1)
    8000263a:	0285b983          	ld	s3,40(a1)
    8000263e:	0305ba03          	ld	s4,48(a1)
    80002642:	0385ba83          	ld	s5,56(a1)
    80002646:	0405bb03          	ld	s6,64(a1)
    8000264a:	0485bb83          	ld	s7,72(a1)
    8000264e:	0505bc03          	ld	s8,80(a1)
    80002652:	0585bc83          	ld	s9,88(a1)
    80002656:	0605bd03          	ld	s10,96(a1)
    8000265a:	0685bd83          	ld	s11,104(a1)
    8000265e:	8082                	ret

0000000080002660 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002660:	1141                	add	sp,sp,-16
    80002662:	e406                	sd	ra,8(sp)
    80002664:	e022                	sd	s0,0(sp)
    80002666:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    80002668:	00006597          	auipc	a1,0x6
    8000266c:	c3858593          	add	a1,a1,-968 # 800082a0 <etext+0x2a0>
    80002670:	00015517          	auipc	a0,0x15
    80002674:	a6050513          	add	a0,a0,-1440 # 800170d0 <tickslock>
    80002678:	ffffe097          	auipc	ra,0xffffe
    8000267c:	52a080e7          	jalr	1322(ra) # 80000ba2 <initlock>
}
    80002680:	60a2                	ld	ra,8(sp)
    80002682:	6402                	ld	s0,0(sp)
    80002684:	0141                	add	sp,sp,16
    80002686:	8082                	ret

0000000080002688 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002688:	1141                	add	sp,sp,-16
    8000268a:	e422                	sd	s0,8(sp)
    8000268c:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000268e:	00003797          	auipc	a5,0x3
    80002692:	55278793          	add	a5,a5,1362 # 80005be0 <kernelvec>
    80002696:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000269a:	6422                	ld	s0,8(sp)
    8000269c:	0141                	add	sp,sp,16
    8000269e:	8082                	ret

00000000800026a0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026a0:	1141                	add	sp,sp,-16
    800026a2:	e406                	sd	ra,8(sp)
    800026a4:	e022                	sd	s0,0(sp)
    800026a6:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    800026a8:	fffff097          	auipc	ra,0xfffff
    800026ac:	388080e7          	jalr	904(ra) # 80001a30 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026b4:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026b6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026ba:	00005697          	auipc	a3,0x5
    800026be:	94668693          	add	a3,a3,-1722 # 80007000 <_trampoline>
    800026c2:	00005717          	auipc	a4,0x5
    800026c6:	93e70713          	add	a4,a4,-1730 # 80007000 <_trampoline>
    800026ca:	8f15                	sub	a4,a4,a3
    800026cc:	040007b7          	lui	a5,0x4000
    800026d0:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800026d2:	07b2                	sll	a5,a5,0xc
    800026d4:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026d6:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026da:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026dc:	18002673          	csrr	a2,satp
    800026e0:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026e2:	6d30                	ld	a2,88(a0)
    800026e4:	6138                	ld	a4,64(a0)
    800026e6:	6585                	lui	a1,0x1
    800026e8:	972e                	add	a4,a4,a1
    800026ea:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026ec:	6d38                	ld	a4,88(a0)
    800026ee:	00000617          	auipc	a2,0x0
    800026f2:	14060613          	add	a2,a2,320 # 8000282e <usertrap>
    800026f6:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026f8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026fa:	8612                	mv	a2,tp
    800026fc:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026fe:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002702:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002706:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000270a:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000270e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002710:	6f18                	ld	a4,24(a4)
    80002712:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002716:	692c                	ld	a1,80(a0)
    80002718:	81b1                	srl	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000271a:	00005717          	auipc	a4,0x5
    8000271e:	97670713          	add	a4,a4,-1674 # 80007090 <userret>
    80002722:	8f15                	sub	a4,a4,a3
    80002724:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002726:	577d                	li	a4,-1
    80002728:	177e                	sll	a4,a4,0x3f
    8000272a:	8dd9                	or	a1,a1,a4
    8000272c:	02000537          	lui	a0,0x2000
    80002730:	157d                	add	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80002732:	0536                	sll	a0,a0,0xd
    80002734:	9782                	jalr	a5
}
    80002736:	60a2                	ld	ra,8(sp)
    80002738:	6402                	ld	s0,0(sp)
    8000273a:	0141                	add	sp,sp,16
    8000273c:	8082                	ret

000000008000273e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000273e:	1101                	add	sp,sp,-32
    80002740:	ec06                	sd	ra,24(sp)
    80002742:	e822                	sd	s0,16(sp)
    80002744:	e426                	sd	s1,8(sp)
    80002746:	1000                	add	s0,sp,32
  acquire(&tickslock);
    80002748:	00015497          	auipc	s1,0x15
    8000274c:	98848493          	add	s1,s1,-1656 # 800170d0 <tickslock>
    80002750:	8526                	mv	a0,s1
    80002752:	ffffe097          	auipc	ra,0xffffe
    80002756:	4e0080e7          	jalr	1248(ra) # 80000c32 <acquire>
  ticks++;
    8000275a:	00007517          	auipc	a0,0x7
    8000275e:	8d650513          	add	a0,a0,-1834 # 80009030 <ticks>
    80002762:	411c                	lw	a5,0(a0)
    80002764:	2785                	addw	a5,a5,1
    80002766:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002768:	00000097          	auipc	ra,0x0
    8000276c:	b1a080e7          	jalr	-1254(ra) # 80002282 <wakeup>
  release(&tickslock);
    80002770:	8526                	mv	a0,s1
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	574080e7          	jalr	1396(ra) # 80000ce6 <release>
}
    8000277a:	60e2                	ld	ra,24(sp)
    8000277c:	6442                	ld	s0,16(sp)
    8000277e:	64a2                	ld	s1,8(sp)
    80002780:	6105                	add	sp,sp,32
    80002782:	8082                	ret

0000000080002784 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002784:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002788:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    8000278a:	0a07d163          	bgez	a5,8000282c <devintr+0xa8>
{
    8000278e:	1101                	add	sp,sp,-32
    80002790:	ec06                	sd	ra,24(sp)
    80002792:	e822                	sd	s0,16(sp)
    80002794:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    80002796:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    8000279a:	46a5                	li	a3,9
    8000279c:	00d70c63          	beq	a4,a3,800027b4 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    800027a0:	577d                	li	a4,-1
    800027a2:	177e                	sll	a4,a4,0x3f
    800027a4:	0705                	add	a4,a4,1
    return 0;
    800027a6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027a8:	06e78163          	beq	a5,a4,8000280a <devintr+0x86>
  }
}
    800027ac:	60e2                	ld	ra,24(sp)
    800027ae:	6442                	ld	s0,16(sp)
    800027b0:	6105                	add	sp,sp,32
    800027b2:	8082                	ret
    800027b4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800027b6:	00003097          	auipc	ra,0x3
    800027ba:	536080e7          	jalr	1334(ra) # 80005cec <plic_claim>
    800027be:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027c0:	47a9                	li	a5,10
    800027c2:	00f50963          	beq	a0,a5,800027d4 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    800027c6:	4785                	li	a5,1
    800027c8:	00f50b63          	beq	a0,a5,800027de <devintr+0x5a>
    return 1;
    800027cc:	4505                	li	a0,1
    } else if(irq){
    800027ce:	ec89                	bnez	s1,800027e8 <devintr+0x64>
    800027d0:	64a2                	ld	s1,8(sp)
    800027d2:	bfe9                	j	800027ac <devintr+0x28>
      uartintr();
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	220080e7          	jalr	544(ra) # 800009f4 <uartintr>
    if(irq)
    800027dc:	a839                	j	800027fa <devintr+0x76>
      virtio_disk_intr();
    800027de:	00004097          	auipc	ra,0x4
    800027e2:	9e2080e7          	jalr	-1566(ra) # 800061c0 <virtio_disk_intr>
    if(irq)
    800027e6:	a811                	j	800027fa <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    800027e8:	85a6                	mv	a1,s1
    800027ea:	00006517          	auipc	a0,0x6
    800027ee:	abe50513          	add	a0,a0,-1346 # 800082a8 <etext+0x2a8>
    800027f2:	ffffe097          	auipc	ra,0xffffe
    800027f6:	db2080e7          	jalr	-590(ra) # 800005a4 <printf>
      plic_complete(irq);
    800027fa:	8526                	mv	a0,s1
    800027fc:	00003097          	auipc	ra,0x3
    80002800:	514080e7          	jalr	1300(ra) # 80005d10 <plic_complete>
    return 1;
    80002804:	4505                	li	a0,1
    80002806:	64a2                	ld	s1,8(sp)
    80002808:	b755                	j	800027ac <devintr+0x28>
    if(cpuid() == 0){
    8000280a:	fffff097          	auipc	ra,0xfffff
    8000280e:	1fa080e7          	jalr	506(ra) # 80001a04 <cpuid>
    80002812:	c901                	beqz	a0,80002822 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002814:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002818:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000281a:	14479073          	csrw	sip,a5
    return 2;
    8000281e:	4509                	li	a0,2
    80002820:	b771                	j	800027ac <devintr+0x28>
      clockintr();
    80002822:	00000097          	auipc	ra,0x0
    80002826:	f1c080e7          	jalr	-228(ra) # 8000273e <clockintr>
    8000282a:	b7ed                	j	80002814 <devintr+0x90>
}
    8000282c:	8082                	ret

000000008000282e <usertrap>:
{
    8000282e:	1101                	add	sp,sp,-32
    80002830:	ec06                	sd	ra,24(sp)
    80002832:	e822                	sd	s0,16(sp)
    80002834:	e426                	sd	s1,8(sp)
    80002836:	e04a                	sd	s2,0(sp)
    80002838:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000283a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000283e:	1007f793          	and	a5,a5,256
    80002842:	e3ad                	bnez	a5,800028a4 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002844:	00003797          	auipc	a5,0x3
    80002848:	39c78793          	add	a5,a5,924 # 80005be0 <kernelvec>
    8000284c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002850:	fffff097          	auipc	ra,0xfffff
    80002854:	1e0080e7          	jalr	480(ra) # 80001a30 <myproc>
    80002858:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000285a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000285c:	14102773          	csrr	a4,sepc
    80002860:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002862:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002866:	47a1                	li	a5,8
    80002868:	04f71c63          	bne	a4,a5,800028c0 <usertrap+0x92>
    if(p->killed)
    8000286c:	551c                	lw	a5,40(a0)
    8000286e:	e3b9                	bnez	a5,800028b4 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002870:	6cb8                	ld	a4,88(s1)
    80002872:	6f1c                	ld	a5,24(a4)
    80002874:	0791                	add	a5,a5,4
    80002876:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002878:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000287c:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002880:	10079073          	csrw	sstatus,a5
    syscall();
    80002884:	00000097          	auipc	ra,0x0
    80002888:	2e0080e7          	jalr	736(ra) # 80002b64 <syscall>
  if(p->killed)
    8000288c:	549c                	lw	a5,40(s1)
    8000288e:	ebc1                	bnez	a5,8000291e <usertrap+0xf0>
  usertrapret();
    80002890:	00000097          	auipc	ra,0x0
    80002894:	e10080e7          	jalr	-496(ra) # 800026a0 <usertrapret>
}
    80002898:	60e2                	ld	ra,24(sp)
    8000289a:	6442                	ld	s0,16(sp)
    8000289c:	64a2                	ld	s1,8(sp)
    8000289e:	6902                	ld	s2,0(sp)
    800028a0:	6105                	add	sp,sp,32
    800028a2:	8082                	ret
    panic("usertrap: not from user mode");
    800028a4:	00006517          	auipc	a0,0x6
    800028a8:	a2450513          	add	a0,a0,-1500 # 800082c8 <etext+0x2c8>
    800028ac:	ffffe097          	auipc	ra,0xffffe
    800028b0:	cae080e7          	jalr	-850(ra) # 8000055a <panic>
      exit(-1);
    800028b4:	557d                	li	a0,-1
    800028b6:	00000097          	auipc	ra,0x0
    800028ba:	a9c080e7          	jalr	-1380(ra) # 80002352 <exit>
    800028be:	bf4d                	j	80002870 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028c0:	00000097          	auipc	ra,0x0
    800028c4:	ec4080e7          	jalr	-316(ra) # 80002784 <devintr>
    800028c8:	892a                	mv	s2,a0
    800028ca:	c501                	beqz	a0,800028d2 <usertrap+0xa4>
  if(p->killed)
    800028cc:	549c                	lw	a5,40(s1)
    800028ce:	c3a1                	beqz	a5,8000290e <usertrap+0xe0>
    800028d0:	a815                	j	80002904 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028d2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028d6:	5890                	lw	a2,48(s1)
    800028d8:	00006517          	auipc	a0,0x6
    800028dc:	a1050513          	add	a0,a0,-1520 # 800082e8 <etext+0x2e8>
    800028e0:	ffffe097          	auipc	ra,0xffffe
    800028e4:	cc4080e7          	jalr	-828(ra) # 800005a4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028e8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028ec:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028f0:	00006517          	auipc	a0,0x6
    800028f4:	a2850513          	add	a0,a0,-1496 # 80008318 <etext+0x318>
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	cac080e7          	jalr	-852(ra) # 800005a4 <printf>
    p->killed = 1;
    80002900:	4785                	li	a5,1
    80002902:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002904:	557d                	li	a0,-1
    80002906:	00000097          	auipc	ra,0x0
    8000290a:	a4c080e7          	jalr	-1460(ra) # 80002352 <exit>
  if(which_dev == 2)
    8000290e:	4789                	li	a5,2
    80002910:	f8f910e3          	bne	s2,a5,80002890 <usertrap+0x62>
    yield();
    80002914:	fffff097          	auipc	ra,0xfffff
    80002918:	7a6080e7          	jalr	1958(ra) # 800020ba <yield>
    8000291c:	bf95                	j	80002890 <usertrap+0x62>
  int which_dev = 0;
    8000291e:	4901                	li	s2,0
    80002920:	b7d5                	j	80002904 <usertrap+0xd6>

0000000080002922 <kerneltrap>:
{
    80002922:	7179                	add	sp,sp,-48
    80002924:	f406                	sd	ra,40(sp)
    80002926:	f022                	sd	s0,32(sp)
    80002928:	ec26                	sd	s1,24(sp)
    8000292a:	e84a                	sd	s2,16(sp)
    8000292c:	e44e                	sd	s3,8(sp)
    8000292e:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002930:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002934:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002938:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000293c:	1004f793          	and	a5,s1,256
    80002940:	cb85                	beqz	a5,80002970 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002942:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002946:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002948:	ef85                	bnez	a5,80002980 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000294a:	00000097          	auipc	ra,0x0
    8000294e:	e3a080e7          	jalr	-454(ra) # 80002784 <devintr>
    80002952:	cd1d                	beqz	a0,80002990 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002954:	4789                	li	a5,2
    80002956:	06f50a63          	beq	a0,a5,800029ca <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000295a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000295e:	10049073          	csrw	sstatus,s1
}
    80002962:	70a2                	ld	ra,40(sp)
    80002964:	7402                	ld	s0,32(sp)
    80002966:	64e2                	ld	s1,24(sp)
    80002968:	6942                	ld	s2,16(sp)
    8000296a:	69a2                	ld	s3,8(sp)
    8000296c:	6145                	add	sp,sp,48
    8000296e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002970:	00006517          	auipc	a0,0x6
    80002974:	9c850513          	add	a0,a0,-1592 # 80008338 <etext+0x338>
    80002978:	ffffe097          	auipc	ra,0xffffe
    8000297c:	be2080e7          	jalr	-1054(ra) # 8000055a <panic>
    panic("kerneltrap: interrupts enabled");
    80002980:	00006517          	auipc	a0,0x6
    80002984:	9e050513          	add	a0,a0,-1568 # 80008360 <etext+0x360>
    80002988:	ffffe097          	auipc	ra,0xffffe
    8000298c:	bd2080e7          	jalr	-1070(ra) # 8000055a <panic>
    printf("scause %p\n", scause);
    80002990:	85ce                	mv	a1,s3
    80002992:	00006517          	auipc	a0,0x6
    80002996:	9ee50513          	add	a0,a0,-1554 # 80008380 <etext+0x380>
    8000299a:	ffffe097          	auipc	ra,0xffffe
    8000299e:	c0a080e7          	jalr	-1014(ra) # 800005a4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029a2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029a6:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029aa:	00006517          	auipc	a0,0x6
    800029ae:	9e650513          	add	a0,a0,-1562 # 80008390 <etext+0x390>
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	bf2080e7          	jalr	-1038(ra) # 800005a4 <printf>
    panic("kerneltrap");
    800029ba:	00006517          	auipc	a0,0x6
    800029be:	9ee50513          	add	a0,a0,-1554 # 800083a8 <etext+0x3a8>
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	b98080e7          	jalr	-1128(ra) # 8000055a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029ca:	fffff097          	auipc	ra,0xfffff
    800029ce:	066080e7          	jalr	102(ra) # 80001a30 <myproc>
    800029d2:	d541                	beqz	a0,8000295a <kerneltrap+0x38>
    800029d4:	fffff097          	auipc	ra,0xfffff
    800029d8:	05c080e7          	jalr	92(ra) # 80001a30 <myproc>
    800029dc:	4d18                	lw	a4,24(a0)
    800029de:	4791                	li	a5,4
    800029e0:	f6f71de3          	bne	a4,a5,8000295a <kerneltrap+0x38>
    yield();
    800029e4:	fffff097          	auipc	ra,0xfffff
    800029e8:	6d6080e7          	jalr	1750(ra) # 800020ba <yield>
    800029ec:	b7bd                	j	8000295a <kerneltrap+0x38>

00000000800029ee <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029ee:	1101                	add	sp,sp,-32
    800029f0:	ec06                	sd	ra,24(sp)
    800029f2:	e822                	sd	s0,16(sp)
    800029f4:	e426                	sd	s1,8(sp)
    800029f6:	1000                	add	s0,sp,32
    800029f8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029fa:	fffff097          	auipc	ra,0xfffff
    800029fe:	036080e7          	jalr	54(ra) # 80001a30 <myproc>
  switch (n) {
    80002a02:	4795                	li	a5,5
    80002a04:	0497e163          	bltu	a5,s1,80002a46 <argraw+0x58>
    80002a08:	048a                	sll	s1,s1,0x2
    80002a0a:	00006717          	auipc	a4,0x6
    80002a0e:	d3670713          	add	a4,a4,-714 # 80008740 <states.0+0x30>
    80002a12:	94ba                	add	s1,s1,a4
    80002a14:	409c                	lw	a5,0(s1)
    80002a16:	97ba                	add	a5,a5,a4
    80002a18:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a1a:	6d3c                	ld	a5,88(a0)
    80002a1c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a1e:	60e2                	ld	ra,24(sp)
    80002a20:	6442                	ld	s0,16(sp)
    80002a22:	64a2                	ld	s1,8(sp)
    80002a24:	6105                	add	sp,sp,32
    80002a26:	8082                	ret
    return p->trapframe->a1;
    80002a28:	6d3c                	ld	a5,88(a0)
    80002a2a:	7fa8                	ld	a0,120(a5)
    80002a2c:	bfcd                	j	80002a1e <argraw+0x30>
    return p->trapframe->a2;
    80002a2e:	6d3c                	ld	a5,88(a0)
    80002a30:	63c8                	ld	a0,128(a5)
    80002a32:	b7f5                	j	80002a1e <argraw+0x30>
    return p->trapframe->a3;
    80002a34:	6d3c                	ld	a5,88(a0)
    80002a36:	67c8                	ld	a0,136(a5)
    80002a38:	b7dd                	j	80002a1e <argraw+0x30>
    return p->trapframe->a4;
    80002a3a:	6d3c                	ld	a5,88(a0)
    80002a3c:	6bc8                	ld	a0,144(a5)
    80002a3e:	b7c5                	j	80002a1e <argraw+0x30>
    return p->trapframe->a5;
    80002a40:	6d3c                	ld	a5,88(a0)
    80002a42:	6fc8                	ld	a0,152(a5)
    80002a44:	bfe9                	j	80002a1e <argraw+0x30>
  panic("argraw");
    80002a46:	00006517          	auipc	a0,0x6
    80002a4a:	97250513          	add	a0,a0,-1678 # 800083b8 <etext+0x3b8>
    80002a4e:	ffffe097          	auipc	ra,0xffffe
    80002a52:	b0c080e7          	jalr	-1268(ra) # 8000055a <panic>

0000000080002a56 <fetchaddr>:
{
    80002a56:	1101                	add	sp,sp,-32
    80002a58:	ec06                	sd	ra,24(sp)
    80002a5a:	e822                	sd	s0,16(sp)
    80002a5c:	e426                	sd	s1,8(sp)
    80002a5e:	e04a                	sd	s2,0(sp)
    80002a60:	1000                	add	s0,sp,32
    80002a62:	84aa                	mv	s1,a0
    80002a64:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a66:	fffff097          	auipc	ra,0xfffff
    80002a6a:	fca080e7          	jalr	-54(ra) # 80001a30 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a6e:	653c                	ld	a5,72(a0)
    80002a70:	02f4f863          	bgeu	s1,a5,80002aa0 <fetchaddr+0x4a>
    80002a74:	00848713          	add	a4,s1,8
    80002a78:	02e7e663          	bltu	a5,a4,80002aa4 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a7c:	46a1                	li	a3,8
    80002a7e:	8626                	mv	a2,s1
    80002a80:	85ca                	mv	a1,s2
    80002a82:	6928                	ld	a0,80(a0)
    80002a84:	fffff097          	auipc	ra,0xfffff
    80002a88:	cd4080e7          	jalr	-812(ra) # 80001758 <copyin>
    80002a8c:	00a03533          	snez	a0,a0
    80002a90:	40a00533          	neg	a0,a0
}
    80002a94:	60e2                	ld	ra,24(sp)
    80002a96:	6442                	ld	s0,16(sp)
    80002a98:	64a2                	ld	s1,8(sp)
    80002a9a:	6902                	ld	s2,0(sp)
    80002a9c:	6105                	add	sp,sp,32
    80002a9e:	8082                	ret
    return -1;
    80002aa0:	557d                	li	a0,-1
    80002aa2:	bfcd                	j	80002a94 <fetchaddr+0x3e>
    80002aa4:	557d                	li	a0,-1
    80002aa6:	b7fd                	j	80002a94 <fetchaddr+0x3e>

0000000080002aa8 <fetchstr>:
{
    80002aa8:	7179                	add	sp,sp,-48
    80002aaa:	f406                	sd	ra,40(sp)
    80002aac:	f022                	sd	s0,32(sp)
    80002aae:	ec26                	sd	s1,24(sp)
    80002ab0:	e84a                	sd	s2,16(sp)
    80002ab2:	e44e                	sd	s3,8(sp)
    80002ab4:	1800                	add	s0,sp,48
    80002ab6:	892a                	mv	s2,a0
    80002ab8:	84ae                	mv	s1,a1
    80002aba:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002abc:	fffff097          	auipc	ra,0xfffff
    80002ac0:	f74080e7          	jalr	-140(ra) # 80001a30 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ac4:	86ce                	mv	a3,s3
    80002ac6:	864a                	mv	a2,s2
    80002ac8:	85a6                	mv	a1,s1
    80002aca:	6928                	ld	a0,80(a0)
    80002acc:	fffff097          	auipc	ra,0xfffff
    80002ad0:	d1a080e7          	jalr	-742(ra) # 800017e6 <copyinstr>
  if(err < 0)
    80002ad4:	00054763          	bltz	a0,80002ae2 <fetchstr+0x3a>
  return strlen(buf);
    80002ad8:	8526                	mv	a0,s1
    80002ada:	ffffe097          	auipc	ra,0xffffe
    80002ade:	3c8080e7          	jalr	968(ra) # 80000ea2 <strlen>
}
    80002ae2:	70a2                	ld	ra,40(sp)
    80002ae4:	7402                	ld	s0,32(sp)
    80002ae6:	64e2                	ld	s1,24(sp)
    80002ae8:	6942                	ld	s2,16(sp)
    80002aea:	69a2                	ld	s3,8(sp)
    80002aec:	6145                	add	sp,sp,48
    80002aee:	8082                	ret

0000000080002af0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002af0:	1101                	add	sp,sp,-32
    80002af2:	ec06                	sd	ra,24(sp)
    80002af4:	e822                	sd	s0,16(sp)
    80002af6:	e426                	sd	s1,8(sp)
    80002af8:	1000                	add	s0,sp,32
    80002afa:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002afc:	00000097          	auipc	ra,0x0
    80002b00:	ef2080e7          	jalr	-270(ra) # 800029ee <argraw>
    80002b04:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b06:	4501                	li	a0,0
    80002b08:	60e2                	ld	ra,24(sp)
    80002b0a:	6442                	ld	s0,16(sp)
    80002b0c:	64a2                	ld	s1,8(sp)
    80002b0e:	6105                	add	sp,sp,32
    80002b10:	8082                	ret

0000000080002b12 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b12:	1101                	add	sp,sp,-32
    80002b14:	ec06                	sd	ra,24(sp)
    80002b16:	e822                	sd	s0,16(sp)
    80002b18:	e426                	sd	s1,8(sp)
    80002b1a:	1000                	add	s0,sp,32
    80002b1c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b1e:	00000097          	auipc	ra,0x0
    80002b22:	ed0080e7          	jalr	-304(ra) # 800029ee <argraw>
    80002b26:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b28:	4501                	li	a0,0
    80002b2a:	60e2                	ld	ra,24(sp)
    80002b2c:	6442                	ld	s0,16(sp)
    80002b2e:	64a2                	ld	s1,8(sp)
    80002b30:	6105                	add	sp,sp,32
    80002b32:	8082                	ret

0000000080002b34 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b34:	1101                	add	sp,sp,-32
    80002b36:	ec06                	sd	ra,24(sp)
    80002b38:	e822                	sd	s0,16(sp)
    80002b3a:	e426                	sd	s1,8(sp)
    80002b3c:	e04a                	sd	s2,0(sp)
    80002b3e:	1000                	add	s0,sp,32
    80002b40:	84ae                	mv	s1,a1
    80002b42:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b44:	00000097          	auipc	ra,0x0
    80002b48:	eaa080e7          	jalr	-342(ra) # 800029ee <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b4c:	864a                	mv	a2,s2
    80002b4e:	85a6                	mv	a1,s1
    80002b50:	00000097          	auipc	ra,0x0
    80002b54:	f58080e7          	jalr	-168(ra) # 80002aa8 <fetchstr>
}
    80002b58:	60e2                	ld	ra,24(sp)
    80002b5a:	6442                	ld	s0,16(sp)
    80002b5c:	64a2                	ld	s1,8(sp)
    80002b5e:	6902                	ld	s2,0(sp)
    80002b60:	6105                	add	sp,sp,32
    80002b62:	8082                	ret

0000000080002b64 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002b64:	1101                	add	sp,sp,-32
    80002b66:	ec06                	sd	ra,24(sp)
    80002b68:	e822                	sd	s0,16(sp)
    80002b6a:	e426                	sd	s1,8(sp)
    80002b6c:	e04a                	sd	s2,0(sp)
    80002b6e:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b70:	fffff097          	auipc	ra,0xfffff
    80002b74:	ec0080e7          	jalr	-320(ra) # 80001a30 <myproc>
    80002b78:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b7a:	05853903          	ld	s2,88(a0)
    80002b7e:	0a893783          	ld	a5,168(s2)
    80002b82:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b86:	37fd                	addw	a5,a5,-1
    80002b88:	4751                	li	a4,20
    80002b8a:	00f76f63          	bltu	a4,a5,80002ba8 <syscall+0x44>
    80002b8e:	00369713          	sll	a4,a3,0x3
    80002b92:	00006797          	auipc	a5,0x6
    80002b96:	bc678793          	add	a5,a5,-1082 # 80008758 <syscalls>
    80002b9a:	97ba                	add	a5,a5,a4
    80002b9c:	639c                	ld	a5,0(a5)
    80002b9e:	c789                	beqz	a5,80002ba8 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002ba0:	9782                	jalr	a5
    80002ba2:	06a93823          	sd	a0,112(s2)
    80002ba6:	a839                	j	80002bc4 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ba8:	15848613          	add	a2,s1,344
    80002bac:	588c                	lw	a1,48(s1)
    80002bae:	00006517          	auipc	a0,0x6
    80002bb2:	81250513          	add	a0,a0,-2030 # 800083c0 <etext+0x3c0>
    80002bb6:	ffffe097          	auipc	ra,0xffffe
    80002bba:	9ee080e7          	jalr	-1554(ra) # 800005a4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002bbe:	6cbc                	ld	a5,88(s1)
    80002bc0:	577d                	li	a4,-1
    80002bc2:	fbb8                	sd	a4,112(a5)
  }
}
    80002bc4:	60e2                	ld	ra,24(sp)
    80002bc6:	6442                	ld	s0,16(sp)
    80002bc8:	64a2                	ld	s1,8(sp)
    80002bca:	6902                	ld	s2,0(sp)
    80002bcc:	6105                	add	sp,sp,32
    80002bce:	8082                	ret

0000000080002bd0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002bd0:	1101                	add	sp,sp,-32
    80002bd2:	ec06                	sd	ra,24(sp)
    80002bd4:	e822                	sd	s0,16(sp)
    80002bd6:	1000                	add	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002bd8:	fec40593          	add	a1,s0,-20
    80002bdc:	4501                	li	a0,0
    80002bde:	00000097          	auipc	ra,0x0
    80002be2:	f12080e7          	jalr	-238(ra) # 80002af0 <argint>
    return -1;
    80002be6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002be8:	00054963          	bltz	a0,80002bfa <sys_exit+0x2a>
  exit(n);
    80002bec:	fec42503          	lw	a0,-20(s0)
    80002bf0:	fffff097          	auipc	ra,0xfffff
    80002bf4:	762080e7          	jalr	1890(ra) # 80002352 <exit>
  return 0;  // not reached
    80002bf8:	4781                	li	a5,0
}
    80002bfa:	853e                	mv	a0,a5
    80002bfc:	60e2                	ld	ra,24(sp)
    80002bfe:	6442                	ld	s0,16(sp)
    80002c00:	6105                	add	sp,sp,32
    80002c02:	8082                	ret

0000000080002c04 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c04:	1141                	add	sp,sp,-16
    80002c06:	e406                	sd	ra,8(sp)
    80002c08:	e022                	sd	s0,0(sp)
    80002c0a:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002c0c:	fffff097          	auipc	ra,0xfffff
    80002c10:	e24080e7          	jalr	-476(ra) # 80001a30 <myproc>
}
    80002c14:	5908                	lw	a0,48(a0)
    80002c16:	60a2                	ld	ra,8(sp)
    80002c18:	6402                	ld	s0,0(sp)
    80002c1a:	0141                	add	sp,sp,16
    80002c1c:	8082                	ret

0000000080002c1e <sys_fork>:

uint64
sys_fork(void)
{
    80002c1e:	1141                	add	sp,sp,-16
    80002c20:	e406                	sd	ra,8(sp)
    80002c22:	e022                	sd	s0,0(sp)
    80002c24:	0800                	add	s0,sp,16
  return fork();
    80002c26:	fffff097          	auipc	ra,0xfffff
    80002c2a:	1dc080e7          	jalr	476(ra) # 80001e02 <fork>
}
    80002c2e:	60a2                	ld	ra,8(sp)
    80002c30:	6402                	ld	s0,0(sp)
    80002c32:	0141                	add	sp,sp,16
    80002c34:	8082                	ret

0000000080002c36 <sys_wait>:

uint64
sys_wait(void)
{
    80002c36:	1101                	add	sp,sp,-32
    80002c38:	ec06                	sd	ra,24(sp)
    80002c3a:	e822                	sd	s0,16(sp)
    80002c3c:	1000                	add	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c3e:	fe840593          	add	a1,s0,-24
    80002c42:	4501                	li	a0,0
    80002c44:	00000097          	auipc	ra,0x0
    80002c48:	ece080e7          	jalr	-306(ra) # 80002b12 <argaddr>
    80002c4c:	87aa                	mv	a5,a0
    return -1;
    80002c4e:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002c50:	0007c863          	bltz	a5,80002c60 <sys_wait+0x2a>
  return wait(p);
    80002c54:	fe843503          	ld	a0,-24(s0)
    80002c58:	fffff097          	auipc	ra,0xfffff
    80002c5c:	502080e7          	jalr	1282(ra) # 8000215a <wait>
}
    80002c60:	60e2                	ld	ra,24(sp)
    80002c62:	6442                	ld	s0,16(sp)
    80002c64:	6105                	add	sp,sp,32
    80002c66:	8082                	ret

0000000080002c68 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c68:	7179                	add	sp,sp,-48
    80002c6a:	f406                	sd	ra,40(sp)
    80002c6c:	f022                	sd	s0,32(sp)
    80002c6e:	1800                	add	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002c70:	fdc40593          	add	a1,s0,-36
    80002c74:	4501                	li	a0,0
    80002c76:	00000097          	auipc	ra,0x0
    80002c7a:	e7a080e7          	jalr	-390(ra) # 80002af0 <argint>
    80002c7e:	87aa                	mv	a5,a0
    return -1;
    80002c80:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002c82:	0207c263          	bltz	a5,80002ca6 <sys_sbrk+0x3e>
    80002c86:	ec26                	sd	s1,24(sp)
  addr = myproc()->sz;
    80002c88:	fffff097          	auipc	ra,0xfffff
    80002c8c:	da8080e7          	jalr	-600(ra) # 80001a30 <myproc>
    80002c90:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002c92:	fdc42503          	lw	a0,-36(s0)
    80002c96:	fffff097          	auipc	ra,0xfffff
    80002c9a:	0f4080e7          	jalr	244(ra) # 80001d8a <growproc>
    80002c9e:	00054863          	bltz	a0,80002cae <sys_sbrk+0x46>
    return -1;
  return addr;
    80002ca2:	8526                	mv	a0,s1
    80002ca4:	64e2                	ld	s1,24(sp)
}
    80002ca6:	70a2                	ld	ra,40(sp)
    80002ca8:	7402                	ld	s0,32(sp)
    80002caa:	6145                	add	sp,sp,48
    80002cac:	8082                	ret
    return -1;
    80002cae:	557d                	li	a0,-1
    80002cb0:	64e2                	ld	s1,24(sp)
    80002cb2:	bfd5                	j	80002ca6 <sys_sbrk+0x3e>

0000000080002cb4 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002cb4:	7139                	add	sp,sp,-64
    80002cb6:	fc06                	sd	ra,56(sp)
    80002cb8:	f822                	sd	s0,48(sp)
    80002cba:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002cbc:	fcc40593          	add	a1,s0,-52
    80002cc0:	4501                	li	a0,0
    80002cc2:	00000097          	auipc	ra,0x0
    80002cc6:	e2e080e7          	jalr	-466(ra) # 80002af0 <argint>
    return -1;
    80002cca:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ccc:	06054b63          	bltz	a0,80002d42 <sys_sleep+0x8e>
    80002cd0:	f04a                	sd	s2,32(sp)
  acquire(&tickslock);
    80002cd2:	00014517          	auipc	a0,0x14
    80002cd6:	3fe50513          	add	a0,a0,1022 # 800170d0 <tickslock>
    80002cda:	ffffe097          	auipc	ra,0xffffe
    80002cde:	f58080e7          	jalr	-168(ra) # 80000c32 <acquire>
  ticks0 = ticks;
    80002ce2:	00006917          	auipc	s2,0x6
    80002ce6:	34e92903          	lw	s2,846(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002cea:	fcc42783          	lw	a5,-52(s0)
    80002cee:	c3a1                	beqz	a5,80002d2e <sys_sleep+0x7a>
    80002cf0:	f426                	sd	s1,40(sp)
    80002cf2:	ec4e                	sd	s3,24(sp)
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002cf4:	00014997          	auipc	s3,0x14
    80002cf8:	3dc98993          	add	s3,s3,988 # 800170d0 <tickslock>
    80002cfc:	00006497          	auipc	s1,0x6
    80002d00:	33448493          	add	s1,s1,820 # 80009030 <ticks>
    if(myproc()->killed){
    80002d04:	fffff097          	auipc	ra,0xfffff
    80002d08:	d2c080e7          	jalr	-724(ra) # 80001a30 <myproc>
    80002d0c:	551c                	lw	a5,40(a0)
    80002d0e:	ef9d                	bnez	a5,80002d4c <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d10:	85ce                	mv	a1,s3
    80002d12:	8526                	mv	a0,s1
    80002d14:	fffff097          	auipc	ra,0xfffff
    80002d18:	3e2080e7          	jalr	994(ra) # 800020f6 <sleep>
  while(ticks - ticks0 < n){
    80002d1c:	409c                	lw	a5,0(s1)
    80002d1e:	412787bb          	subw	a5,a5,s2
    80002d22:	fcc42703          	lw	a4,-52(s0)
    80002d26:	fce7efe3          	bltu	a5,a4,80002d04 <sys_sleep+0x50>
    80002d2a:	74a2                	ld	s1,40(sp)
    80002d2c:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002d2e:	00014517          	auipc	a0,0x14
    80002d32:	3a250513          	add	a0,a0,930 # 800170d0 <tickslock>
    80002d36:	ffffe097          	auipc	ra,0xffffe
    80002d3a:	fb0080e7          	jalr	-80(ra) # 80000ce6 <release>
  return 0;
    80002d3e:	4781                	li	a5,0
    80002d40:	7902                	ld	s2,32(sp)
}
    80002d42:	853e                	mv	a0,a5
    80002d44:	70e2                	ld	ra,56(sp)
    80002d46:	7442                	ld	s0,48(sp)
    80002d48:	6121                	add	sp,sp,64
    80002d4a:	8082                	ret
      release(&tickslock);
    80002d4c:	00014517          	auipc	a0,0x14
    80002d50:	38450513          	add	a0,a0,900 # 800170d0 <tickslock>
    80002d54:	ffffe097          	auipc	ra,0xffffe
    80002d58:	f92080e7          	jalr	-110(ra) # 80000ce6 <release>
      return -1;
    80002d5c:	57fd                	li	a5,-1
    80002d5e:	74a2                	ld	s1,40(sp)
    80002d60:	7902                	ld	s2,32(sp)
    80002d62:	69e2                	ld	s3,24(sp)
    80002d64:	bff9                	j	80002d42 <sys_sleep+0x8e>

0000000080002d66 <sys_kill>:

uint64
sys_kill(void)
{
    80002d66:	1101                	add	sp,sp,-32
    80002d68:	ec06                	sd	ra,24(sp)
    80002d6a:	e822                	sd	s0,16(sp)
    80002d6c:	1000                	add	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002d6e:	fec40593          	add	a1,s0,-20
    80002d72:	4501                	li	a0,0
    80002d74:	00000097          	auipc	ra,0x0
    80002d78:	d7c080e7          	jalr	-644(ra) # 80002af0 <argint>
    80002d7c:	87aa                	mv	a5,a0
    return -1;
    80002d7e:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002d80:	0007c863          	bltz	a5,80002d90 <sys_kill+0x2a>
  return kill(pid);
    80002d84:	fec42503          	lw	a0,-20(s0)
    80002d88:	fffff097          	auipc	ra,0xfffff
    80002d8c:	6a0080e7          	jalr	1696(ra) # 80002428 <kill>
}
    80002d90:	60e2                	ld	ra,24(sp)
    80002d92:	6442                	ld	s0,16(sp)
    80002d94:	6105                	add	sp,sp,32
    80002d96:	8082                	ret

0000000080002d98 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d98:	1101                	add	sp,sp,-32
    80002d9a:	ec06                	sd	ra,24(sp)
    80002d9c:	e822                	sd	s0,16(sp)
    80002d9e:	e426                	sd	s1,8(sp)
    80002da0:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002da2:	00014517          	auipc	a0,0x14
    80002da6:	32e50513          	add	a0,a0,814 # 800170d0 <tickslock>
    80002daa:	ffffe097          	auipc	ra,0xffffe
    80002dae:	e88080e7          	jalr	-376(ra) # 80000c32 <acquire>
  xticks = ticks;
    80002db2:	00006497          	auipc	s1,0x6
    80002db6:	27e4a483          	lw	s1,638(s1) # 80009030 <ticks>
  release(&tickslock);
    80002dba:	00014517          	auipc	a0,0x14
    80002dbe:	31650513          	add	a0,a0,790 # 800170d0 <tickslock>
    80002dc2:	ffffe097          	auipc	ra,0xffffe
    80002dc6:	f24080e7          	jalr	-220(ra) # 80000ce6 <release>
  return xticks;
}
    80002dca:	02049513          	sll	a0,s1,0x20
    80002dce:	9101                	srl	a0,a0,0x20
    80002dd0:	60e2                	ld	ra,24(sp)
    80002dd2:	6442                	ld	s0,16(sp)
    80002dd4:	64a2                	ld	s1,8(sp)
    80002dd6:	6105                	add	sp,sp,32
    80002dd8:	8082                	ret

0000000080002dda <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002dda:	7179                	add	sp,sp,-48
    80002ddc:	f406                	sd	ra,40(sp)
    80002dde:	f022                	sd	s0,32(sp)
    80002de0:	ec26                	sd	s1,24(sp)
    80002de2:	e84a                	sd	s2,16(sp)
    80002de4:	e44e                	sd	s3,8(sp)
    80002de6:	e052                	sd	s4,0(sp)
    80002de8:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002dea:	00005597          	auipc	a1,0x5
    80002dee:	5f658593          	add	a1,a1,1526 # 800083e0 <etext+0x3e0>
    80002df2:	00014517          	auipc	a0,0x14
    80002df6:	2f650513          	add	a0,a0,758 # 800170e8 <bcache>
    80002dfa:	ffffe097          	auipc	ra,0xffffe
    80002dfe:	da8080e7          	jalr	-600(ra) # 80000ba2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e02:	0001c797          	auipc	a5,0x1c
    80002e06:	2e678793          	add	a5,a5,742 # 8001f0e8 <bcache+0x8000>
    80002e0a:	0001c717          	auipc	a4,0x1c
    80002e0e:	54670713          	add	a4,a4,1350 # 8001f350 <bcache+0x8268>
    80002e12:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e16:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e1a:	00014497          	auipc	s1,0x14
    80002e1e:	2e648493          	add	s1,s1,742 # 80017100 <bcache+0x18>
    b->next = bcache.head.next;
    80002e22:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002e24:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002e26:	00005a17          	auipc	s4,0x5
    80002e2a:	5c2a0a13          	add	s4,s4,1474 # 800083e8 <etext+0x3e8>
    b->next = bcache.head.next;
    80002e2e:	2b893783          	ld	a5,696(s2)
    80002e32:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002e34:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002e38:	85d2                	mv	a1,s4
    80002e3a:	01048513          	add	a0,s1,16
    80002e3e:	00001097          	auipc	ra,0x1
    80002e42:	4b2080e7          	jalr	1202(ra) # 800042f0 <initsleeplock>
    bcache.head.next->prev = b;
    80002e46:	2b893783          	ld	a5,696(s2)
    80002e4a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002e4c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e50:	45848493          	add	s1,s1,1112
    80002e54:	fd349de3          	bne	s1,s3,80002e2e <binit+0x54>
  }
}
    80002e58:	70a2                	ld	ra,40(sp)
    80002e5a:	7402                	ld	s0,32(sp)
    80002e5c:	64e2                	ld	s1,24(sp)
    80002e5e:	6942                	ld	s2,16(sp)
    80002e60:	69a2                	ld	s3,8(sp)
    80002e62:	6a02                	ld	s4,0(sp)
    80002e64:	6145                	add	sp,sp,48
    80002e66:	8082                	ret

0000000080002e68 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e68:	7179                	add	sp,sp,-48
    80002e6a:	f406                	sd	ra,40(sp)
    80002e6c:	f022                	sd	s0,32(sp)
    80002e6e:	ec26                	sd	s1,24(sp)
    80002e70:	e84a                	sd	s2,16(sp)
    80002e72:	e44e                	sd	s3,8(sp)
    80002e74:	1800                	add	s0,sp,48
    80002e76:	892a                	mv	s2,a0
    80002e78:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e7a:	00014517          	auipc	a0,0x14
    80002e7e:	26e50513          	add	a0,a0,622 # 800170e8 <bcache>
    80002e82:	ffffe097          	auipc	ra,0xffffe
    80002e86:	db0080e7          	jalr	-592(ra) # 80000c32 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e8a:	0001c497          	auipc	s1,0x1c
    80002e8e:	5164b483          	ld	s1,1302(s1) # 8001f3a0 <bcache+0x82b8>
    80002e92:	0001c797          	auipc	a5,0x1c
    80002e96:	4be78793          	add	a5,a5,1214 # 8001f350 <bcache+0x8268>
    80002e9a:	02f48f63          	beq	s1,a5,80002ed8 <bread+0x70>
    80002e9e:	873e                	mv	a4,a5
    80002ea0:	a021                	j	80002ea8 <bread+0x40>
    80002ea2:	68a4                	ld	s1,80(s1)
    80002ea4:	02e48a63          	beq	s1,a4,80002ed8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002ea8:	449c                	lw	a5,8(s1)
    80002eaa:	ff279ce3          	bne	a5,s2,80002ea2 <bread+0x3a>
    80002eae:	44dc                	lw	a5,12(s1)
    80002eb0:	ff3799e3          	bne	a5,s3,80002ea2 <bread+0x3a>
      b->refcnt++;
    80002eb4:	40bc                	lw	a5,64(s1)
    80002eb6:	2785                	addw	a5,a5,1
    80002eb8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002eba:	00014517          	auipc	a0,0x14
    80002ebe:	22e50513          	add	a0,a0,558 # 800170e8 <bcache>
    80002ec2:	ffffe097          	auipc	ra,0xffffe
    80002ec6:	e24080e7          	jalr	-476(ra) # 80000ce6 <release>
      acquiresleep(&b->lock);
    80002eca:	01048513          	add	a0,s1,16
    80002ece:	00001097          	auipc	ra,0x1
    80002ed2:	45c080e7          	jalr	1116(ra) # 8000432a <acquiresleep>
      return b;
    80002ed6:	a8b9                	j	80002f34 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ed8:	0001c497          	auipc	s1,0x1c
    80002edc:	4c04b483          	ld	s1,1216(s1) # 8001f398 <bcache+0x82b0>
    80002ee0:	0001c797          	auipc	a5,0x1c
    80002ee4:	47078793          	add	a5,a5,1136 # 8001f350 <bcache+0x8268>
    80002ee8:	00f48863          	beq	s1,a5,80002ef8 <bread+0x90>
    80002eec:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002eee:	40bc                	lw	a5,64(s1)
    80002ef0:	cf81                	beqz	a5,80002f08 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ef2:	64a4                	ld	s1,72(s1)
    80002ef4:	fee49de3          	bne	s1,a4,80002eee <bread+0x86>
  panic("bget: no buffers");
    80002ef8:	00005517          	auipc	a0,0x5
    80002efc:	4f850513          	add	a0,a0,1272 # 800083f0 <etext+0x3f0>
    80002f00:	ffffd097          	auipc	ra,0xffffd
    80002f04:	65a080e7          	jalr	1626(ra) # 8000055a <panic>
      b->dev = dev;
    80002f08:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f0c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f10:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f14:	4785                	li	a5,1
    80002f16:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f18:	00014517          	auipc	a0,0x14
    80002f1c:	1d050513          	add	a0,a0,464 # 800170e8 <bcache>
    80002f20:	ffffe097          	auipc	ra,0xffffe
    80002f24:	dc6080e7          	jalr	-570(ra) # 80000ce6 <release>
      acquiresleep(&b->lock);
    80002f28:	01048513          	add	a0,s1,16
    80002f2c:	00001097          	auipc	ra,0x1
    80002f30:	3fe080e7          	jalr	1022(ra) # 8000432a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002f34:	409c                	lw	a5,0(s1)
    80002f36:	cb89                	beqz	a5,80002f48 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002f38:	8526                	mv	a0,s1
    80002f3a:	70a2                	ld	ra,40(sp)
    80002f3c:	7402                	ld	s0,32(sp)
    80002f3e:	64e2                	ld	s1,24(sp)
    80002f40:	6942                	ld	s2,16(sp)
    80002f42:	69a2                	ld	s3,8(sp)
    80002f44:	6145                	add	sp,sp,48
    80002f46:	8082                	ret
    virtio_disk_rw(b, 0);
    80002f48:	4581                	li	a1,0
    80002f4a:	8526                	mv	a0,s1
    80002f4c:	00003097          	auipc	ra,0x3
    80002f50:	fe6080e7          	jalr	-26(ra) # 80005f32 <virtio_disk_rw>
    b->valid = 1;
    80002f54:	4785                	li	a5,1
    80002f56:	c09c                	sw	a5,0(s1)
  return b;
    80002f58:	b7c5                	j	80002f38 <bread+0xd0>

0000000080002f5a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f5a:	1101                	add	sp,sp,-32
    80002f5c:	ec06                	sd	ra,24(sp)
    80002f5e:	e822                	sd	s0,16(sp)
    80002f60:	e426                	sd	s1,8(sp)
    80002f62:	1000                	add	s0,sp,32
    80002f64:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f66:	0541                	add	a0,a0,16
    80002f68:	00001097          	auipc	ra,0x1
    80002f6c:	45c080e7          	jalr	1116(ra) # 800043c4 <holdingsleep>
    80002f70:	cd01                	beqz	a0,80002f88 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f72:	4585                	li	a1,1
    80002f74:	8526                	mv	a0,s1
    80002f76:	00003097          	auipc	ra,0x3
    80002f7a:	fbc080e7          	jalr	-68(ra) # 80005f32 <virtio_disk_rw>
}
    80002f7e:	60e2                	ld	ra,24(sp)
    80002f80:	6442                	ld	s0,16(sp)
    80002f82:	64a2                	ld	s1,8(sp)
    80002f84:	6105                	add	sp,sp,32
    80002f86:	8082                	ret
    panic("bwrite");
    80002f88:	00005517          	auipc	a0,0x5
    80002f8c:	48050513          	add	a0,a0,1152 # 80008408 <etext+0x408>
    80002f90:	ffffd097          	auipc	ra,0xffffd
    80002f94:	5ca080e7          	jalr	1482(ra) # 8000055a <panic>

0000000080002f98 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f98:	1101                	add	sp,sp,-32
    80002f9a:	ec06                	sd	ra,24(sp)
    80002f9c:	e822                	sd	s0,16(sp)
    80002f9e:	e426                	sd	s1,8(sp)
    80002fa0:	e04a                	sd	s2,0(sp)
    80002fa2:	1000                	add	s0,sp,32
    80002fa4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fa6:	01050913          	add	s2,a0,16
    80002faa:	854a                	mv	a0,s2
    80002fac:	00001097          	auipc	ra,0x1
    80002fb0:	418080e7          	jalr	1048(ra) # 800043c4 <holdingsleep>
    80002fb4:	c925                	beqz	a0,80003024 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80002fb6:	854a                	mv	a0,s2
    80002fb8:	00001097          	auipc	ra,0x1
    80002fbc:	3c8080e7          	jalr	968(ra) # 80004380 <releasesleep>

  acquire(&bcache.lock);
    80002fc0:	00014517          	auipc	a0,0x14
    80002fc4:	12850513          	add	a0,a0,296 # 800170e8 <bcache>
    80002fc8:	ffffe097          	auipc	ra,0xffffe
    80002fcc:	c6a080e7          	jalr	-918(ra) # 80000c32 <acquire>
  b->refcnt--;
    80002fd0:	40bc                	lw	a5,64(s1)
    80002fd2:	37fd                	addw	a5,a5,-1
    80002fd4:	0007871b          	sext.w	a4,a5
    80002fd8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002fda:	e71d                	bnez	a4,80003008 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002fdc:	68b8                	ld	a4,80(s1)
    80002fde:	64bc                	ld	a5,72(s1)
    80002fe0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002fe2:	68b8                	ld	a4,80(s1)
    80002fe4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fe6:	0001c797          	auipc	a5,0x1c
    80002fea:	10278793          	add	a5,a5,258 # 8001f0e8 <bcache+0x8000>
    80002fee:	2b87b703          	ld	a4,696(a5)
    80002ff2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002ff4:	0001c717          	auipc	a4,0x1c
    80002ff8:	35c70713          	add	a4,a4,860 # 8001f350 <bcache+0x8268>
    80002ffc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002ffe:	2b87b703          	ld	a4,696(a5)
    80003002:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003004:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003008:	00014517          	auipc	a0,0x14
    8000300c:	0e050513          	add	a0,a0,224 # 800170e8 <bcache>
    80003010:	ffffe097          	auipc	ra,0xffffe
    80003014:	cd6080e7          	jalr	-810(ra) # 80000ce6 <release>
}
    80003018:	60e2                	ld	ra,24(sp)
    8000301a:	6442                	ld	s0,16(sp)
    8000301c:	64a2                	ld	s1,8(sp)
    8000301e:	6902                	ld	s2,0(sp)
    80003020:	6105                	add	sp,sp,32
    80003022:	8082                	ret
    panic("brelse");
    80003024:	00005517          	auipc	a0,0x5
    80003028:	3ec50513          	add	a0,a0,1004 # 80008410 <etext+0x410>
    8000302c:	ffffd097          	auipc	ra,0xffffd
    80003030:	52e080e7          	jalr	1326(ra) # 8000055a <panic>

0000000080003034 <bpin>:

void
bpin(struct buf *b) {
    80003034:	1101                	add	sp,sp,-32
    80003036:	ec06                	sd	ra,24(sp)
    80003038:	e822                	sd	s0,16(sp)
    8000303a:	e426                	sd	s1,8(sp)
    8000303c:	1000                	add	s0,sp,32
    8000303e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003040:	00014517          	auipc	a0,0x14
    80003044:	0a850513          	add	a0,a0,168 # 800170e8 <bcache>
    80003048:	ffffe097          	auipc	ra,0xffffe
    8000304c:	bea080e7          	jalr	-1046(ra) # 80000c32 <acquire>
  b->refcnt++;
    80003050:	40bc                	lw	a5,64(s1)
    80003052:	2785                	addw	a5,a5,1
    80003054:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003056:	00014517          	auipc	a0,0x14
    8000305a:	09250513          	add	a0,a0,146 # 800170e8 <bcache>
    8000305e:	ffffe097          	auipc	ra,0xffffe
    80003062:	c88080e7          	jalr	-888(ra) # 80000ce6 <release>
}
    80003066:	60e2                	ld	ra,24(sp)
    80003068:	6442                	ld	s0,16(sp)
    8000306a:	64a2                	ld	s1,8(sp)
    8000306c:	6105                	add	sp,sp,32
    8000306e:	8082                	ret

0000000080003070 <bunpin>:

void
bunpin(struct buf *b) {
    80003070:	1101                	add	sp,sp,-32
    80003072:	ec06                	sd	ra,24(sp)
    80003074:	e822                	sd	s0,16(sp)
    80003076:	e426                	sd	s1,8(sp)
    80003078:	1000                	add	s0,sp,32
    8000307a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000307c:	00014517          	auipc	a0,0x14
    80003080:	06c50513          	add	a0,a0,108 # 800170e8 <bcache>
    80003084:	ffffe097          	auipc	ra,0xffffe
    80003088:	bae080e7          	jalr	-1106(ra) # 80000c32 <acquire>
  b->refcnt--;
    8000308c:	40bc                	lw	a5,64(s1)
    8000308e:	37fd                	addw	a5,a5,-1
    80003090:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003092:	00014517          	auipc	a0,0x14
    80003096:	05650513          	add	a0,a0,86 # 800170e8 <bcache>
    8000309a:	ffffe097          	auipc	ra,0xffffe
    8000309e:	c4c080e7          	jalr	-948(ra) # 80000ce6 <release>
}
    800030a2:	60e2                	ld	ra,24(sp)
    800030a4:	6442                	ld	s0,16(sp)
    800030a6:	64a2                	ld	s1,8(sp)
    800030a8:	6105                	add	sp,sp,32
    800030aa:	8082                	ret

00000000800030ac <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800030ac:	1101                	add	sp,sp,-32
    800030ae:	ec06                	sd	ra,24(sp)
    800030b0:	e822                	sd	s0,16(sp)
    800030b2:	e426                	sd	s1,8(sp)
    800030b4:	e04a                	sd	s2,0(sp)
    800030b6:	1000                	add	s0,sp,32
    800030b8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800030ba:	00d5d59b          	srlw	a1,a1,0xd
    800030be:	0001c797          	auipc	a5,0x1c
    800030c2:	7067a783          	lw	a5,1798(a5) # 8001f7c4 <sb+0x1c>
    800030c6:	9dbd                	addw	a1,a1,a5
    800030c8:	00000097          	auipc	ra,0x0
    800030cc:	da0080e7          	jalr	-608(ra) # 80002e68 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800030d0:	0074f713          	and	a4,s1,7
    800030d4:	4785                	li	a5,1
    800030d6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800030da:	14ce                	sll	s1,s1,0x33
    800030dc:	90d9                	srl	s1,s1,0x36
    800030de:	00950733          	add	a4,a0,s1
    800030e2:	05874703          	lbu	a4,88(a4)
    800030e6:	00e7f6b3          	and	a3,a5,a4
    800030ea:	c69d                	beqz	a3,80003118 <bfree+0x6c>
    800030ec:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800030ee:	94aa                	add	s1,s1,a0
    800030f0:	fff7c793          	not	a5,a5
    800030f4:	8f7d                	and	a4,a4,a5
    800030f6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800030fa:	00001097          	auipc	ra,0x1
    800030fe:	112080e7          	jalr	274(ra) # 8000420c <log_write>
  brelse(bp);
    80003102:	854a                	mv	a0,s2
    80003104:	00000097          	auipc	ra,0x0
    80003108:	e94080e7          	jalr	-364(ra) # 80002f98 <brelse>
}
    8000310c:	60e2                	ld	ra,24(sp)
    8000310e:	6442                	ld	s0,16(sp)
    80003110:	64a2                	ld	s1,8(sp)
    80003112:	6902                	ld	s2,0(sp)
    80003114:	6105                	add	sp,sp,32
    80003116:	8082                	ret
    panic("freeing free block");
    80003118:	00005517          	auipc	a0,0x5
    8000311c:	30050513          	add	a0,a0,768 # 80008418 <etext+0x418>
    80003120:	ffffd097          	auipc	ra,0xffffd
    80003124:	43a080e7          	jalr	1082(ra) # 8000055a <panic>

0000000080003128 <balloc>:
{
    80003128:	711d                	add	sp,sp,-96
    8000312a:	ec86                	sd	ra,88(sp)
    8000312c:	e8a2                	sd	s0,80(sp)
    8000312e:	e4a6                	sd	s1,72(sp)
    80003130:	e0ca                	sd	s2,64(sp)
    80003132:	fc4e                	sd	s3,56(sp)
    80003134:	f852                	sd	s4,48(sp)
    80003136:	f456                	sd	s5,40(sp)
    80003138:	f05a                	sd	s6,32(sp)
    8000313a:	ec5e                	sd	s7,24(sp)
    8000313c:	e862                	sd	s8,16(sp)
    8000313e:	e466                	sd	s9,8(sp)
    80003140:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003142:	0001c797          	auipc	a5,0x1c
    80003146:	66a7a783          	lw	a5,1642(a5) # 8001f7ac <sb+0x4>
    8000314a:	cbc1                	beqz	a5,800031da <balloc+0xb2>
    8000314c:	8baa                	mv	s7,a0
    8000314e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003150:	0001cb17          	auipc	s6,0x1c
    80003154:	658b0b13          	add	s6,s6,1624 # 8001f7a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003158:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000315a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000315c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000315e:	6c89                	lui	s9,0x2
    80003160:	a831                	j	8000317c <balloc+0x54>
    brelse(bp);
    80003162:	854a                	mv	a0,s2
    80003164:	00000097          	auipc	ra,0x0
    80003168:	e34080e7          	jalr	-460(ra) # 80002f98 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000316c:	015c87bb          	addw	a5,s9,s5
    80003170:	00078a9b          	sext.w	s5,a5
    80003174:	004b2703          	lw	a4,4(s6)
    80003178:	06eaf163          	bgeu	s5,a4,800031da <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    8000317c:	41fad79b          	sraw	a5,s5,0x1f
    80003180:	0137d79b          	srlw	a5,a5,0x13
    80003184:	015787bb          	addw	a5,a5,s5
    80003188:	40d7d79b          	sraw	a5,a5,0xd
    8000318c:	01cb2583          	lw	a1,28(s6)
    80003190:	9dbd                	addw	a1,a1,a5
    80003192:	855e                	mv	a0,s7
    80003194:	00000097          	auipc	ra,0x0
    80003198:	cd4080e7          	jalr	-812(ra) # 80002e68 <bread>
    8000319c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000319e:	004b2503          	lw	a0,4(s6)
    800031a2:	000a849b          	sext.w	s1,s5
    800031a6:	8762                	mv	a4,s8
    800031a8:	faa4fde3          	bgeu	s1,a0,80003162 <balloc+0x3a>
      m = 1 << (bi % 8);
    800031ac:	00777693          	and	a3,a4,7
    800031b0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031b4:	41f7579b          	sraw	a5,a4,0x1f
    800031b8:	01d7d79b          	srlw	a5,a5,0x1d
    800031bc:	9fb9                	addw	a5,a5,a4
    800031be:	4037d79b          	sraw	a5,a5,0x3
    800031c2:	00f90633          	add	a2,s2,a5
    800031c6:	05864603          	lbu	a2,88(a2)
    800031ca:	00c6f5b3          	and	a1,a3,a2
    800031ce:	cd91                	beqz	a1,800031ea <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031d0:	2705                	addw	a4,a4,1
    800031d2:	2485                	addw	s1,s1,1
    800031d4:	fd471ae3          	bne	a4,s4,800031a8 <balloc+0x80>
    800031d8:	b769                	j	80003162 <balloc+0x3a>
  panic("balloc: out of blocks");
    800031da:	00005517          	auipc	a0,0x5
    800031de:	25650513          	add	a0,a0,598 # 80008430 <etext+0x430>
    800031e2:	ffffd097          	auipc	ra,0xffffd
    800031e6:	378080e7          	jalr	888(ra) # 8000055a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031ea:	97ca                	add	a5,a5,s2
    800031ec:	8e55                	or	a2,a2,a3
    800031ee:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800031f2:	854a                	mv	a0,s2
    800031f4:	00001097          	auipc	ra,0x1
    800031f8:	018080e7          	jalr	24(ra) # 8000420c <log_write>
        brelse(bp);
    800031fc:	854a                	mv	a0,s2
    800031fe:	00000097          	auipc	ra,0x0
    80003202:	d9a080e7          	jalr	-614(ra) # 80002f98 <brelse>
  bp = bread(dev, bno);
    80003206:	85a6                	mv	a1,s1
    80003208:	855e                	mv	a0,s7
    8000320a:	00000097          	auipc	ra,0x0
    8000320e:	c5e080e7          	jalr	-930(ra) # 80002e68 <bread>
    80003212:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003214:	40000613          	li	a2,1024
    80003218:	4581                	li	a1,0
    8000321a:	05850513          	add	a0,a0,88
    8000321e:	ffffe097          	auipc	ra,0xffffe
    80003222:	b10080e7          	jalr	-1264(ra) # 80000d2e <memset>
  log_write(bp);
    80003226:	854a                	mv	a0,s2
    80003228:	00001097          	auipc	ra,0x1
    8000322c:	fe4080e7          	jalr	-28(ra) # 8000420c <log_write>
  brelse(bp);
    80003230:	854a                	mv	a0,s2
    80003232:	00000097          	auipc	ra,0x0
    80003236:	d66080e7          	jalr	-666(ra) # 80002f98 <brelse>
}
    8000323a:	8526                	mv	a0,s1
    8000323c:	60e6                	ld	ra,88(sp)
    8000323e:	6446                	ld	s0,80(sp)
    80003240:	64a6                	ld	s1,72(sp)
    80003242:	6906                	ld	s2,64(sp)
    80003244:	79e2                	ld	s3,56(sp)
    80003246:	7a42                	ld	s4,48(sp)
    80003248:	7aa2                	ld	s5,40(sp)
    8000324a:	7b02                	ld	s6,32(sp)
    8000324c:	6be2                	ld	s7,24(sp)
    8000324e:	6c42                	ld	s8,16(sp)
    80003250:	6ca2                	ld	s9,8(sp)
    80003252:	6125                	add	sp,sp,96
    80003254:	8082                	ret

0000000080003256 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003256:	7179                	add	sp,sp,-48
    80003258:	f406                	sd	ra,40(sp)
    8000325a:	f022                	sd	s0,32(sp)
    8000325c:	ec26                	sd	s1,24(sp)
    8000325e:	e84a                	sd	s2,16(sp)
    80003260:	e44e                	sd	s3,8(sp)
    80003262:	1800                	add	s0,sp,48
    80003264:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003266:	47ad                	li	a5,11
    80003268:	04b7ff63          	bgeu	a5,a1,800032c6 <bmap+0x70>
    8000326c:	e052                	sd	s4,0(sp)
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000326e:	ff45849b          	addw	s1,a1,-12
    80003272:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003276:	0ff00793          	li	a5,255
    8000327a:	0ae7e463          	bltu	a5,a4,80003322 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000327e:	08052583          	lw	a1,128(a0)
    80003282:	c5b5                	beqz	a1,800032ee <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003284:	00092503          	lw	a0,0(s2)
    80003288:	00000097          	auipc	ra,0x0
    8000328c:	be0080e7          	jalr	-1056(ra) # 80002e68 <bread>
    80003290:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003292:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    80003296:	02049713          	sll	a4,s1,0x20
    8000329a:	01e75593          	srl	a1,a4,0x1e
    8000329e:	00b784b3          	add	s1,a5,a1
    800032a2:	0004a983          	lw	s3,0(s1)
    800032a6:	04098e63          	beqz	s3,80003302 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800032aa:	8552                	mv	a0,s4
    800032ac:	00000097          	auipc	ra,0x0
    800032b0:	cec080e7          	jalr	-788(ra) # 80002f98 <brelse>
    return addr;
    800032b4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800032b6:	854e                	mv	a0,s3
    800032b8:	70a2                	ld	ra,40(sp)
    800032ba:	7402                	ld	s0,32(sp)
    800032bc:	64e2                	ld	s1,24(sp)
    800032be:	6942                	ld	s2,16(sp)
    800032c0:	69a2                	ld	s3,8(sp)
    800032c2:	6145                	add	sp,sp,48
    800032c4:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800032c6:	02059793          	sll	a5,a1,0x20
    800032ca:	01e7d593          	srl	a1,a5,0x1e
    800032ce:	00b504b3          	add	s1,a0,a1
    800032d2:	0504a983          	lw	s3,80(s1)
    800032d6:	fe0990e3          	bnez	s3,800032b6 <bmap+0x60>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800032da:	4108                	lw	a0,0(a0)
    800032dc:	00000097          	auipc	ra,0x0
    800032e0:	e4c080e7          	jalr	-436(ra) # 80003128 <balloc>
    800032e4:	0005099b          	sext.w	s3,a0
    800032e8:	0534a823          	sw	s3,80(s1)
    800032ec:	b7e9                	j	800032b6 <bmap+0x60>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800032ee:	4108                	lw	a0,0(a0)
    800032f0:	00000097          	auipc	ra,0x0
    800032f4:	e38080e7          	jalr	-456(ra) # 80003128 <balloc>
    800032f8:	0005059b          	sext.w	a1,a0
    800032fc:	08b92023          	sw	a1,128(s2)
    80003300:	b751                	j	80003284 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003302:	00092503          	lw	a0,0(s2)
    80003306:	00000097          	auipc	ra,0x0
    8000330a:	e22080e7          	jalr	-478(ra) # 80003128 <balloc>
    8000330e:	0005099b          	sext.w	s3,a0
    80003312:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003316:	8552                	mv	a0,s4
    80003318:	00001097          	auipc	ra,0x1
    8000331c:	ef4080e7          	jalr	-268(ra) # 8000420c <log_write>
    80003320:	b769                	j	800032aa <bmap+0x54>
  panic("bmap: out of range");
    80003322:	00005517          	auipc	a0,0x5
    80003326:	12650513          	add	a0,a0,294 # 80008448 <etext+0x448>
    8000332a:	ffffd097          	auipc	ra,0xffffd
    8000332e:	230080e7          	jalr	560(ra) # 8000055a <panic>

0000000080003332 <iget>:
{
    80003332:	7179                	add	sp,sp,-48
    80003334:	f406                	sd	ra,40(sp)
    80003336:	f022                	sd	s0,32(sp)
    80003338:	ec26                	sd	s1,24(sp)
    8000333a:	e84a                	sd	s2,16(sp)
    8000333c:	e44e                	sd	s3,8(sp)
    8000333e:	e052                	sd	s4,0(sp)
    80003340:	1800                	add	s0,sp,48
    80003342:	89aa                	mv	s3,a0
    80003344:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003346:	0001c517          	auipc	a0,0x1c
    8000334a:	48250513          	add	a0,a0,1154 # 8001f7c8 <itable>
    8000334e:	ffffe097          	auipc	ra,0xffffe
    80003352:	8e4080e7          	jalr	-1820(ra) # 80000c32 <acquire>
  empty = 0;
    80003356:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003358:	0001c497          	auipc	s1,0x1c
    8000335c:	48848493          	add	s1,s1,1160 # 8001f7e0 <itable+0x18>
    80003360:	0001e697          	auipc	a3,0x1e
    80003364:	f1068693          	add	a3,a3,-240 # 80021270 <log>
    80003368:	a039                	j	80003376 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000336a:	02090b63          	beqz	s2,800033a0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000336e:	08848493          	add	s1,s1,136
    80003372:	02d48a63          	beq	s1,a3,800033a6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003376:	449c                	lw	a5,8(s1)
    80003378:	fef059e3          	blez	a5,8000336a <iget+0x38>
    8000337c:	4098                	lw	a4,0(s1)
    8000337e:	ff3716e3          	bne	a4,s3,8000336a <iget+0x38>
    80003382:	40d8                	lw	a4,4(s1)
    80003384:	ff4713e3          	bne	a4,s4,8000336a <iget+0x38>
      ip->ref++;
    80003388:	2785                	addw	a5,a5,1
    8000338a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000338c:	0001c517          	auipc	a0,0x1c
    80003390:	43c50513          	add	a0,a0,1084 # 8001f7c8 <itable>
    80003394:	ffffe097          	auipc	ra,0xffffe
    80003398:	952080e7          	jalr	-1710(ra) # 80000ce6 <release>
      return ip;
    8000339c:	8926                	mv	s2,s1
    8000339e:	a03d                	j	800033cc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033a0:	f7f9                	bnez	a5,8000336e <iget+0x3c>
      empty = ip;
    800033a2:	8926                	mv	s2,s1
    800033a4:	b7e9                	j	8000336e <iget+0x3c>
  if(empty == 0)
    800033a6:	02090c63          	beqz	s2,800033de <iget+0xac>
  ip->dev = dev;
    800033aa:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800033ae:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800033b2:	4785                	li	a5,1
    800033b4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800033b8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800033bc:	0001c517          	auipc	a0,0x1c
    800033c0:	40c50513          	add	a0,a0,1036 # 8001f7c8 <itable>
    800033c4:	ffffe097          	auipc	ra,0xffffe
    800033c8:	922080e7          	jalr	-1758(ra) # 80000ce6 <release>
}
    800033cc:	854a                	mv	a0,s2
    800033ce:	70a2                	ld	ra,40(sp)
    800033d0:	7402                	ld	s0,32(sp)
    800033d2:	64e2                	ld	s1,24(sp)
    800033d4:	6942                	ld	s2,16(sp)
    800033d6:	69a2                	ld	s3,8(sp)
    800033d8:	6a02                	ld	s4,0(sp)
    800033da:	6145                	add	sp,sp,48
    800033dc:	8082                	ret
    panic("iget: no inodes");
    800033de:	00005517          	auipc	a0,0x5
    800033e2:	08250513          	add	a0,a0,130 # 80008460 <etext+0x460>
    800033e6:	ffffd097          	auipc	ra,0xffffd
    800033ea:	174080e7          	jalr	372(ra) # 8000055a <panic>

00000000800033ee <fsinit>:
fsinit(int dev) {
    800033ee:	7179                	add	sp,sp,-48
    800033f0:	f406                	sd	ra,40(sp)
    800033f2:	f022                	sd	s0,32(sp)
    800033f4:	ec26                	sd	s1,24(sp)
    800033f6:	e84a                	sd	s2,16(sp)
    800033f8:	e44e                	sd	s3,8(sp)
    800033fa:	1800                	add	s0,sp,48
    800033fc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800033fe:	4585                	li	a1,1
    80003400:	00000097          	auipc	ra,0x0
    80003404:	a68080e7          	jalr	-1432(ra) # 80002e68 <bread>
    80003408:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000340a:	0001c997          	auipc	s3,0x1c
    8000340e:	39e98993          	add	s3,s3,926 # 8001f7a8 <sb>
    80003412:	02000613          	li	a2,32
    80003416:	05850593          	add	a1,a0,88
    8000341a:	854e                	mv	a0,s3
    8000341c:	ffffe097          	auipc	ra,0xffffe
    80003420:	96e080e7          	jalr	-1682(ra) # 80000d8a <memmove>
  brelse(bp);
    80003424:	8526                	mv	a0,s1
    80003426:	00000097          	auipc	ra,0x0
    8000342a:	b72080e7          	jalr	-1166(ra) # 80002f98 <brelse>
  if(sb.magic != FSMAGIC)
    8000342e:	0009a703          	lw	a4,0(s3)
    80003432:	102037b7          	lui	a5,0x10203
    80003436:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000343a:	02f71263          	bne	a4,a5,8000345e <fsinit+0x70>
  initlog(dev, &sb);
    8000343e:	0001c597          	auipc	a1,0x1c
    80003442:	36a58593          	add	a1,a1,874 # 8001f7a8 <sb>
    80003446:	854a                	mv	a0,s2
    80003448:	00001097          	auipc	ra,0x1
    8000344c:	b54080e7          	jalr	-1196(ra) # 80003f9c <initlog>
}
    80003450:	70a2                	ld	ra,40(sp)
    80003452:	7402                	ld	s0,32(sp)
    80003454:	64e2                	ld	s1,24(sp)
    80003456:	6942                	ld	s2,16(sp)
    80003458:	69a2                	ld	s3,8(sp)
    8000345a:	6145                	add	sp,sp,48
    8000345c:	8082                	ret
    panic("invalid file system");
    8000345e:	00005517          	auipc	a0,0x5
    80003462:	01250513          	add	a0,a0,18 # 80008470 <etext+0x470>
    80003466:	ffffd097          	auipc	ra,0xffffd
    8000346a:	0f4080e7          	jalr	244(ra) # 8000055a <panic>

000000008000346e <iinit>:
{
    8000346e:	7179                	add	sp,sp,-48
    80003470:	f406                	sd	ra,40(sp)
    80003472:	f022                	sd	s0,32(sp)
    80003474:	ec26                	sd	s1,24(sp)
    80003476:	e84a                	sd	s2,16(sp)
    80003478:	e44e                	sd	s3,8(sp)
    8000347a:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    8000347c:	00005597          	auipc	a1,0x5
    80003480:	00c58593          	add	a1,a1,12 # 80008488 <etext+0x488>
    80003484:	0001c517          	auipc	a0,0x1c
    80003488:	34450513          	add	a0,a0,836 # 8001f7c8 <itable>
    8000348c:	ffffd097          	auipc	ra,0xffffd
    80003490:	716080e7          	jalr	1814(ra) # 80000ba2 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003494:	0001c497          	auipc	s1,0x1c
    80003498:	35c48493          	add	s1,s1,860 # 8001f7f0 <itable+0x28>
    8000349c:	0001e997          	auipc	s3,0x1e
    800034a0:	de498993          	add	s3,s3,-540 # 80021280 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800034a4:	00005917          	auipc	s2,0x5
    800034a8:	fec90913          	add	s2,s2,-20 # 80008490 <etext+0x490>
    800034ac:	85ca                	mv	a1,s2
    800034ae:	8526                	mv	a0,s1
    800034b0:	00001097          	auipc	ra,0x1
    800034b4:	e40080e7          	jalr	-448(ra) # 800042f0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800034b8:	08848493          	add	s1,s1,136
    800034bc:	ff3498e3          	bne	s1,s3,800034ac <iinit+0x3e>
}
    800034c0:	70a2                	ld	ra,40(sp)
    800034c2:	7402                	ld	s0,32(sp)
    800034c4:	64e2                	ld	s1,24(sp)
    800034c6:	6942                	ld	s2,16(sp)
    800034c8:	69a2                	ld	s3,8(sp)
    800034ca:	6145                	add	sp,sp,48
    800034cc:	8082                	ret

00000000800034ce <ialloc>:
{
    800034ce:	7139                	add	sp,sp,-64
    800034d0:	fc06                	sd	ra,56(sp)
    800034d2:	f822                	sd	s0,48(sp)
    800034d4:	f426                	sd	s1,40(sp)
    800034d6:	f04a                	sd	s2,32(sp)
    800034d8:	ec4e                	sd	s3,24(sp)
    800034da:	e852                	sd	s4,16(sp)
    800034dc:	e456                	sd	s5,8(sp)
    800034de:	e05a                	sd	s6,0(sp)
    800034e0:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800034e2:	0001c717          	auipc	a4,0x1c
    800034e6:	2d272703          	lw	a4,722(a4) # 8001f7b4 <sb+0xc>
    800034ea:	4785                	li	a5,1
    800034ec:	04e7f863          	bgeu	a5,a4,8000353c <ialloc+0x6e>
    800034f0:	8aaa                	mv	s5,a0
    800034f2:	8b2e                	mv	s6,a1
    800034f4:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800034f6:	0001ca17          	auipc	s4,0x1c
    800034fa:	2b2a0a13          	add	s4,s4,690 # 8001f7a8 <sb>
    800034fe:	00495593          	srl	a1,s2,0x4
    80003502:	018a2783          	lw	a5,24(s4)
    80003506:	9dbd                	addw	a1,a1,a5
    80003508:	8556                	mv	a0,s5
    8000350a:	00000097          	auipc	ra,0x0
    8000350e:	95e080e7          	jalr	-1698(ra) # 80002e68 <bread>
    80003512:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003514:	05850993          	add	s3,a0,88
    80003518:	00f97793          	and	a5,s2,15
    8000351c:	079a                	sll	a5,a5,0x6
    8000351e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003520:	00099783          	lh	a5,0(s3)
    80003524:	c785                	beqz	a5,8000354c <ialloc+0x7e>
    brelse(bp);
    80003526:	00000097          	auipc	ra,0x0
    8000352a:	a72080e7          	jalr	-1422(ra) # 80002f98 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000352e:	0905                	add	s2,s2,1
    80003530:	00ca2703          	lw	a4,12(s4)
    80003534:	0009079b          	sext.w	a5,s2
    80003538:	fce7e3e3          	bltu	a5,a4,800034fe <ialloc+0x30>
  panic("ialloc: no inodes");
    8000353c:	00005517          	auipc	a0,0x5
    80003540:	f5c50513          	add	a0,a0,-164 # 80008498 <etext+0x498>
    80003544:	ffffd097          	auipc	ra,0xffffd
    80003548:	016080e7          	jalr	22(ra) # 8000055a <panic>
      memset(dip, 0, sizeof(*dip));
    8000354c:	04000613          	li	a2,64
    80003550:	4581                	li	a1,0
    80003552:	854e                	mv	a0,s3
    80003554:	ffffd097          	auipc	ra,0xffffd
    80003558:	7da080e7          	jalr	2010(ra) # 80000d2e <memset>
      dip->type = type;
    8000355c:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003560:	8526                	mv	a0,s1
    80003562:	00001097          	auipc	ra,0x1
    80003566:	caa080e7          	jalr	-854(ra) # 8000420c <log_write>
      brelse(bp);
    8000356a:	8526                	mv	a0,s1
    8000356c:	00000097          	auipc	ra,0x0
    80003570:	a2c080e7          	jalr	-1492(ra) # 80002f98 <brelse>
      return iget(dev, inum);
    80003574:	0009059b          	sext.w	a1,s2
    80003578:	8556                	mv	a0,s5
    8000357a:	00000097          	auipc	ra,0x0
    8000357e:	db8080e7          	jalr	-584(ra) # 80003332 <iget>
}
    80003582:	70e2                	ld	ra,56(sp)
    80003584:	7442                	ld	s0,48(sp)
    80003586:	74a2                	ld	s1,40(sp)
    80003588:	7902                	ld	s2,32(sp)
    8000358a:	69e2                	ld	s3,24(sp)
    8000358c:	6a42                	ld	s4,16(sp)
    8000358e:	6aa2                	ld	s5,8(sp)
    80003590:	6b02                	ld	s6,0(sp)
    80003592:	6121                	add	sp,sp,64
    80003594:	8082                	ret

0000000080003596 <iupdate>:
{
    80003596:	1101                	add	sp,sp,-32
    80003598:	ec06                	sd	ra,24(sp)
    8000359a:	e822                	sd	s0,16(sp)
    8000359c:	e426                	sd	s1,8(sp)
    8000359e:	e04a                	sd	s2,0(sp)
    800035a0:	1000                	add	s0,sp,32
    800035a2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800035a4:	415c                	lw	a5,4(a0)
    800035a6:	0047d79b          	srlw	a5,a5,0x4
    800035aa:	0001c597          	auipc	a1,0x1c
    800035ae:	2165a583          	lw	a1,534(a1) # 8001f7c0 <sb+0x18>
    800035b2:	9dbd                	addw	a1,a1,a5
    800035b4:	4108                	lw	a0,0(a0)
    800035b6:	00000097          	auipc	ra,0x0
    800035ba:	8b2080e7          	jalr	-1870(ra) # 80002e68 <bread>
    800035be:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800035c0:	05850793          	add	a5,a0,88
    800035c4:	40d8                	lw	a4,4(s1)
    800035c6:	8b3d                	and	a4,a4,15
    800035c8:	071a                	sll	a4,a4,0x6
    800035ca:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800035cc:	04449703          	lh	a4,68(s1)
    800035d0:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800035d4:	04649703          	lh	a4,70(s1)
    800035d8:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800035dc:	04849703          	lh	a4,72(s1)
    800035e0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800035e4:	04a49703          	lh	a4,74(s1)
    800035e8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800035ec:	44f8                	lw	a4,76(s1)
    800035ee:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800035f0:	03400613          	li	a2,52
    800035f4:	05048593          	add	a1,s1,80
    800035f8:	00c78513          	add	a0,a5,12
    800035fc:	ffffd097          	auipc	ra,0xffffd
    80003600:	78e080e7          	jalr	1934(ra) # 80000d8a <memmove>
  log_write(bp);
    80003604:	854a                	mv	a0,s2
    80003606:	00001097          	auipc	ra,0x1
    8000360a:	c06080e7          	jalr	-1018(ra) # 8000420c <log_write>
  brelse(bp);
    8000360e:	854a                	mv	a0,s2
    80003610:	00000097          	auipc	ra,0x0
    80003614:	988080e7          	jalr	-1656(ra) # 80002f98 <brelse>
}
    80003618:	60e2                	ld	ra,24(sp)
    8000361a:	6442                	ld	s0,16(sp)
    8000361c:	64a2                	ld	s1,8(sp)
    8000361e:	6902                	ld	s2,0(sp)
    80003620:	6105                	add	sp,sp,32
    80003622:	8082                	ret

0000000080003624 <idup>:
{
    80003624:	1101                	add	sp,sp,-32
    80003626:	ec06                	sd	ra,24(sp)
    80003628:	e822                	sd	s0,16(sp)
    8000362a:	e426                	sd	s1,8(sp)
    8000362c:	1000                	add	s0,sp,32
    8000362e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003630:	0001c517          	auipc	a0,0x1c
    80003634:	19850513          	add	a0,a0,408 # 8001f7c8 <itable>
    80003638:	ffffd097          	auipc	ra,0xffffd
    8000363c:	5fa080e7          	jalr	1530(ra) # 80000c32 <acquire>
  ip->ref++;
    80003640:	449c                	lw	a5,8(s1)
    80003642:	2785                	addw	a5,a5,1
    80003644:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003646:	0001c517          	auipc	a0,0x1c
    8000364a:	18250513          	add	a0,a0,386 # 8001f7c8 <itable>
    8000364e:	ffffd097          	auipc	ra,0xffffd
    80003652:	698080e7          	jalr	1688(ra) # 80000ce6 <release>
}
    80003656:	8526                	mv	a0,s1
    80003658:	60e2                	ld	ra,24(sp)
    8000365a:	6442                	ld	s0,16(sp)
    8000365c:	64a2                	ld	s1,8(sp)
    8000365e:	6105                	add	sp,sp,32
    80003660:	8082                	ret

0000000080003662 <ilock>:
{
    80003662:	1101                	add	sp,sp,-32
    80003664:	ec06                	sd	ra,24(sp)
    80003666:	e822                	sd	s0,16(sp)
    80003668:	e426                	sd	s1,8(sp)
    8000366a:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000366c:	c10d                	beqz	a0,8000368e <ilock+0x2c>
    8000366e:	84aa                	mv	s1,a0
    80003670:	451c                	lw	a5,8(a0)
    80003672:	00f05e63          	blez	a5,8000368e <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003676:	0541                	add	a0,a0,16
    80003678:	00001097          	auipc	ra,0x1
    8000367c:	cb2080e7          	jalr	-846(ra) # 8000432a <acquiresleep>
  if(ip->valid == 0){
    80003680:	40bc                	lw	a5,64(s1)
    80003682:	cf99                	beqz	a5,800036a0 <ilock+0x3e>
}
    80003684:	60e2                	ld	ra,24(sp)
    80003686:	6442                	ld	s0,16(sp)
    80003688:	64a2                	ld	s1,8(sp)
    8000368a:	6105                	add	sp,sp,32
    8000368c:	8082                	ret
    8000368e:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003690:	00005517          	auipc	a0,0x5
    80003694:	e2050513          	add	a0,a0,-480 # 800084b0 <etext+0x4b0>
    80003698:	ffffd097          	auipc	ra,0xffffd
    8000369c:	ec2080e7          	jalr	-318(ra) # 8000055a <panic>
    800036a0:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036a2:	40dc                	lw	a5,4(s1)
    800036a4:	0047d79b          	srlw	a5,a5,0x4
    800036a8:	0001c597          	auipc	a1,0x1c
    800036ac:	1185a583          	lw	a1,280(a1) # 8001f7c0 <sb+0x18>
    800036b0:	9dbd                	addw	a1,a1,a5
    800036b2:	4088                	lw	a0,0(s1)
    800036b4:	fffff097          	auipc	ra,0xfffff
    800036b8:	7b4080e7          	jalr	1972(ra) # 80002e68 <bread>
    800036bc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036be:	05850593          	add	a1,a0,88
    800036c2:	40dc                	lw	a5,4(s1)
    800036c4:	8bbd                	and	a5,a5,15
    800036c6:	079a                	sll	a5,a5,0x6
    800036c8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800036ca:	00059783          	lh	a5,0(a1)
    800036ce:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800036d2:	00259783          	lh	a5,2(a1)
    800036d6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800036da:	00459783          	lh	a5,4(a1)
    800036de:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036e2:	00659783          	lh	a5,6(a1)
    800036e6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800036ea:	459c                	lw	a5,8(a1)
    800036ec:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800036ee:	03400613          	li	a2,52
    800036f2:	05b1                	add	a1,a1,12
    800036f4:	05048513          	add	a0,s1,80
    800036f8:	ffffd097          	auipc	ra,0xffffd
    800036fc:	692080e7          	jalr	1682(ra) # 80000d8a <memmove>
    brelse(bp);
    80003700:	854a                	mv	a0,s2
    80003702:	00000097          	auipc	ra,0x0
    80003706:	896080e7          	jalr	-1898(ra) # 80002f98 <brelse>
    ip->valid = 1;
    8000370a:	4785                	li	a5,1
    8000370c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000370e:	04449783          	lh	a5,68(s1)
    80003712:	c399                	beqz	a5,80003718 <ilock+0xb6>
    80003714:	6902                	ld	s2,0(sp)
    80003716:	b7bd                	j	80003684 <ilock+0x22>
      panic("ilock: no type");
    80003718:	00005517          	auipc	a0,0x5
    8000371c:	da050513          	add	a0,a0,-608 # 800084b8 <etext+0x4b8>
    80003720:	ffffd097          	auipc	ra,0xffffd
    80003724:	e3a080e7          	jalr	-454(ra) # 8000055a <panic>

0000000080003728 <iunlock>:
{
    80003728:	1101                	add	sp,sp,-32
    8000372a:	ec06                	sd	ra,24(sp)
    8000372c:	e822                	sd	s0,16(sp)
    8000372e:	e426                	sd	s1,8(sp)
    80003730:	e04a                	sd	s2,0(sp)
    80003732:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003734:	c905                	beqz	a0,80003764 <iunlock+0x3c>
    80003736:	84aa                	mv	s1,a0
    80003738:	01050913          	add	s2,a0,16
    8000373c:	854a                	mv	a0,s2
    8000373e:	00001097          	auipc	ra,0x1
    80003742:	c86080e7          	jalr	-890(ra) # 800043c4 <holdingsleep>
    80003746:	cd19                	beqz	a0,80003764 <iunlock+0x3c>
    80003748:	449c                	lw	a5,8(s1)
    8000374a:	00f05d63          	blez	a5,80003764 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000374e:	854a                	mv	a0,s2
    80003750:	00001097          	auipc	ra,0x1
    80003754:	c30080e7          	jalr	-976(ra) # 80004380 <releasesleep>
}
    80003758:	60e2                	ld	ra,24(sp)
    8000375a:	6442                	ld	s0,16(sp)
    8000375c:	64a2                	ld	s1,8(sp)
    8000375e:	6902                	ld	s2,0(sp)
    80003760:	6105                	add	sp,sp,32
    80003762:	8082                	ret
    panic("iunlock");
    80003764:	00005517          	auipc	a0,0x5
    80003768:	d6450513          	add	a0,a0,-668 # 800084c8 <etext+0x4c8>
    8000376c:	ffffd097          	auipc	ra,0xffffd
    80003770:	dee080e7          	jalr	-530(ra) # 8000055a <panic>

0000000080003774 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003774:	7179                	add	sp,sp,-48
    80003776:	f406                	sd	ra,40(sp)
    80003778:	f022                	sd	s0,32(sp)
    8000377a:	ec26                	sd	s1,24(sp)
    8000377c:	e84a                	sd	s2,16(sp)
    8000377e:	e44e                	sd	s3,8(sp)
    80003780:	1800                	add	s0,sp,48
    80003782:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003784:	05050493          	add	s1,a0,80
    80003788:	08050913          	add	s2,a0,128
    8000378c:	a021                	j	80003794 <itrunc+0x20>
    8000378e:	0491                	add	s1,s1,4
    80003790:	01248d63          	beq	s1,s2,800037aa <itrunc+0x36>
    if(ip->addrs[i]){
    80003794:	408c                	lw	a1,0(s1)
    80003796:	dde5                	beqz	a1,8000378e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003798:	0009a503          	lw	a0,0(s3)
    8000379c:	00000097          	auipc	ra,0x0
    800037a0:	910080e7          	jalr	-1776(ra) # 800030ac <bfree>
      ip->addrs[i] = 0;
    800037a4:	0004a023          	sw	zero,0(s1)
    800037a8:	b7dd                	j	8000378e <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800037aa:	0809a583          	lw	a1,128(s3)
    800037ae:	ed99                	bnez	a1,800037cc <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800037b0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800037b4:	854e                	mv	a0,s3
    800037b6:	00000097          	auipc	ra,0x0
    800037ba:	de0080e7          	jalr	-544(ra) # 80003596 <iupdate>
}
    800037be:	70a2                	ld	ra,40(sp)
    800037c0:	7402                	ld	s0,32(sp)
    800037c2:	64e2                	ld	s1,24(sp)
    800037c4:	6942                	ld	s2,16(sp)
    800037c6:	69a2                	ld	s3,8(sp)
    800037c8:	6145                	add	sp,sp,48
    800037ca:	8082                	ret
    800037cc:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800037ce:	0009a503          	lw	a0,0(s3)
    800037d2:	fffff097          	auipc	ra,0xfffff
    800037d6:	696080e7          	jalr	1686(ra) # 80002e68 <bread>
    800037da:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800037dc:	05850493          	add	s1,a0,88
    800037e0:	45850913          	add	s2,a0,1112
    800037e4:	a021                	j	800037ec <itrunc+0x78>
    800037e6:	0491                	add	s1,s1,4
    800037e8:	01248b63          	beq	s1,s2,800037fe <itrunc+0x8a>
      if(a[j])
    800037ec:	408c                	lw	a1,0(s1)
    800037ee:	dde5                	beqz	a1,800037e6 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    800037f0:	0009a503          	lw	a0,0(s3)
    800037f4:	00000097          	auipc	ra,0x0
    800037f8:	8b8080e7          	jalr	-1864(ra) # 800030ac <bfree>
    800037fc:	b7ed                	j	800037e6 <itrunc+0x72>
    brelse(bp);
    800037fe:	8552                	mv	a0,s4
    80003800:	fffff097          	auipc	ra,0xfffff
    80003804:	798080e7          	jalr	1944(ra) # 80002f98 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003808:	0809a583          	lw	a1,128(s3)
    8000380c:	0009a503          	lw	a0,0(s3)
    80003810:	00000097          	auipc	ra,0x0
    80003814:	89c080e7          	jalr	-1892(ra) # 800030ac <bfree>
    ip->addrs[NDIRECT] = 0;
    80003818:	0809a023          	sw	zero,128(s3)
    8000381c:	6a02                	ld	s4,0(sp)
    8000381e:	bf49                	j	800037b0 <itrunc+0x3c>

0000000080003820 <iput>:
{
    80003820:	1101                	add	sp,sp,-32
    80003822:	ec06                	sd	ra,24(sp)
    80003824:	e822                	sd	s0,16(sp)
    80003826:	e426                	sd	s1,8(sp)
    80003828:	1000                	add	s0,sp,32
    8000382a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000382c:	0001c517          	auipc	a0,0x1c
    80003830:	f9c50513          	add	a0,a0,-100 # 8001f7c8 <itable>
    80003834:	ffffd097          	auipc	ra,0xffffd
    80003838:	3fe080e7          	jalr	1022(ra) # 80000c32 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000383c:	4498                	lw	a4,8(s1)
    8000383e:	4785                	li	a5,1
    80003840:	02f70263          	beq	a4,a5,80003864 <iput+0x44>
  ip->ref--;
    80003844:	449c                	lw	a5,8(s1)
    80003846:	37fd                	addw	a5,a5,-1
    80003848:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000384a:	0001c517          	auipc	a0,0x1c
    8000384e:	f7e50513          	add	a0,a0,-130 # 8001f7c8 <itable>
    80003852:	ffffd097          	auipc	ra,0xffffd
    80003856:	494080e7          	jalr	1172(ra) # 80000ce6 <release>
}
    8000385a:	60e2                	ld	ra,24(sp)
    8000385c:	6442                	ld	s0,16(sp)
    8000385e:	64a2                	ld	s1,8(sp)
    80003860:	6105                	add	sp,sp,32
    80003862:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003864:	40bc                	lw	a5,64(s1)
    80003866:	dff9                	beqz	a5,80003844 <iput+0x24>
    80003868:	04a49783          	lh	a5,74(s1)
    8000386c:	ffe1                	bnez	a5,80003844 <iput+0x24>
    8000386e:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003870:	01048913          	add	s2,s1,16
    80003874:	854a                	mv	a0,s2
    80003876:	00001097          	auipc	ra,0x1
    8000387a:	ab4080e7          	jalr	-1356(ra) # 8000432a <acquiresleep>
    release(&itable.lock);
    8000387e:	0001c517          	auipc	a0,0x1c
    80003882:	f4a50513          	add	a0,a0,-182 # 8001f7c8 <itable>
    80003886:	ffffd097          	auipc	ra,0xffffd
    8000388a:	460080e7          	jalr	1120(ra) # 80000ce6 <release>
    itrunc(ip);
    8000388e:	8526                	mv	a0,s1
    80003890:	00000097          	auipc	ra,0x0
    80003894:	ee4080e7          	jalr	-284(ra) # 80003774 <itrunc>
    ip->type = 0;
    80003898:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000389c:	8526                	mv	a0,s1
    8000389e:	00000097          	auipc	ra,0x0
    800038a2:	cf8080e7          	jalr	-776(ra) # 80003596 <iupdate>
    ip->valid = 0;
    800038a6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800038aa:	854a                	mv	a0,s2
    800038ac:	00001097          	auipc	ra,0x1
    800038b0:	ad4080e7          	jalr	-1324(ra) # 80004380 <releasesleep>
    acquire(&itable.lock);
    800038b4:	0001c517          	auipc	a0,0x1c
    800038b8:	f1450513          	add	a0,a0,-236 # 8001f7c8 <itable>
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	376080e7          	jalr	886(ra) # 80000c32 <acquire>
    800038c4:	6902                	ld	s2,0(sp)
    800038c6:	bfbd                	j	80003844 <iput+0x24>

00000000800038c8 <iunlockput>:
{
    800038c8:	1101                	add	sp,sp,-32
    800038ca:	ec06                	sd	ra,24(sp)
    800038cc:	e822                	sd	s0,16(sp)
    800038ce:	e426                	sd	s1,8(sp)
    800038d0:	1000                	add	s0,sp,32
    800038d2:	84aa                	mv	s1,a0
  iunlock(ip);
    800038d4:	00000097          	auipc	ra,0x0
    800038d8:	e54080e7          	jalr	-428(ra) # 80003728 <iunlock>
  iput(ip);
    800038dc:	8526                	mv	a0,s1
    800038de:	00000097          	auipc	ra,0x0
    800038e2:	f42080e7          	jalr	-190(ra) # 80003820 <iput>
}
    800038e6:	60e2                	ld	ra,24(sp)
    800038e8:	6442                	ld	s0,16(sp)
    800038ea:	64a2                	ld	s1,8(sp)
    800038ec:	6105                	add	sp,sp,32
    800038ee:	8082                	ret

00000000800038f0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038f0:	1141                	add	sp,sp,-16
    800038f2:	e422                	sd	s0,8(sp)
    800038f4:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    800038f6:	411c                	lw	a5,0(a0)
    800038f8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038fa:	415c                	lw	a5,4(a0)
    800038fc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038fe:	04451783          	lh	a5,68(a0)
    80003902:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003906:	04a51783          	lh	a5,74(a0)
    8000390a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000390e:	04c56783          	lwu	a5,76(a0)
    80003912:	e99c                	sd	a5,16(a1)
}
    80003914:	6422                	ld	s0,8(sp)
    80003916:	0141                	add	sp,sp,16
    80003918:	8082                	ret

000000008000391a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000391a:	457c                	lw	a5,76(a0)
    8000391c:	0ed7ef63          	bltu	a5,a3,80003a1a <readi+0x100>
{
    80003920:	7159                	add	sp,sp,-112
    80003922:	f486                	sd	ra,104(sp)
    80003924:	f0a2                	sd	s0,96(sp)
    80003926:	eca6                	sd	s1,88(sp)
    80003928:	fc56                	sd	s5,56(sp)
    8000392a:	f85a                	sd	s6,48(sp)
    8000392c:	f45e                	sd	s7,40(sp)
    8000392e:	f062                	sd	s8,32(sp)
    80003930:	1880                	add	s0,sp,112
    80003932:	8baa                	mv	s7,a0
    80003934:	8c2e                	mv	s8,a1
    80003936:	8ab2                	mv	s5,a2
    80003938:	84b6                	mv	s1,a3
    8000393a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000393c:	9f35                	addw	a4,a4,a3
    return 0;
    8000393e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003940:	0ad76c63          	bltu	a4,a3,800039f8 <readi+0xde>
    80003944:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003946:	00e7f463          	bgeu	a5,a4,8000394e <readi+0x34>
    n = ip->size - off;
    8000394a:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000394e:	0c0b0463          	beqz	s6,80003a16 <readi+0xfc>
    80003952:	e8ca                	sd	s2,80(sp)
    80003954:	e0d2                	sd	s4,64(sp)
    80003956:	ec66                	sd	s9,24(sp)
    80003958:	e86a                	sd	s10,16(sp)
    8000395a:	e46e                	sd	s11,8(sp)
    8000395c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    8000395e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003962:	5cfd                	li	s9,-1
    80003964:	a82d                	j	8000399e <readi+0x84>
    80003966:	020a1d93          	sll	s11,s4,0x20
    8000396a:	020ddd93          	srl	s11,s11,0x20
    8000396e:	05890613          	add	a2,s2,88
    80003972:	86ee                	mv	a3,s11
    80003974:	963a                	add	a2,a2,a4
    80003976:	85d6                	mv	a1,s5
    80003978:	8562                	mv	a0,s8
    8000397a:	fffff097          	auipc	ra,0xfffff
    8000397e:	b20080e7          	jalr	-1248(ra) # 8000249a <either_copyout>
    80003982:	05950d63          	beq	a0,s9,800039dc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003986:	854a                	mv	a0,s2
    80003988:	fffff097          	auipc	ra,0xfffff
    8000398c:	610080e7          	jalr	1552(ra) # 80002f98 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003990:	013a09bb          	addw	s3,s4,s3
    80003994:	009a04bb          	addw	s1,s4,s1
    80003998:	9aee                	add	s5,s5,s11
    8000399a:	0769f863          	bgeu	s3,s6,80003a0a <readi+0xf0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    8000399e:	000ba903          	lw	s2,0(s7)
    800039a2:	00a4d59b          	srlw	a1,s1,0xa
    800039a6:	855e                	mv	a0,s7
    800039a8:	00000097          	auipc	ra,0x0
    800039ac:	8ae080e7          	jalr	-1874(ra) # 80003256 <bmap>
    800039b0:	0005059b          	sext.w	a1,a0
    800039b4:	854a                	mv	a0,s2
    800039b6:	fffff097          	auipc	ra,0xfffff
    800039ba:	4b2080e7          	jalr	1202(ra) # 80002e68 <bread>
    800039be:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800039c0:	3ff4f713          	and	a4,s1,1023
    800039c4:	40ed07bb          	subw	a5,s10,a4
    800039c8:	413b06bb          	subw	a3,s6,s3
    800039cc:	8a3e                	mv	s4,a5
    800039ce:	2781                	sext.w	a5,a5
    800039d0:	0006861b          	sext.w	a2,a3
    800039d4:	f8f679e3          	bgeu	a2,a5,80003966 <readi+0x4c>
    800039d8:	8a36                	mv	s4,a3
    800039da:	b771                	j	80003966 <readi+0x4c>
      brelse(bp);
    800039dc:	854a                	mv	a0,s2
    800039de:	fffff097          	auipc	ra,0xfffff
    800039e2:	5ba080e7          	jalr	1466(ra) # 80002f98 <brelse>
      tot = -1;
    800039e6:	59fd                	li	s3,-1
      break;
    800039e8:	6946                	ld	s2,80(sp)
    800039ea:	6a06                	ld	s4,64(sp)
    800039ec:	6ce2                	ld	s9,24(sp)
    800039ee:	6d42                	ld	s10,16(sp)
    800039f0:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800039f2:	0009851b          	sext.w	a0,s3
    800039f6:	69a6                	ld	s3,72(sp)
}
    800039f8:	70a6                	ld	ra,104(sp)
    800039fa:	7406                	ld	s0,96(sp)
    800039fc:	64e6                	ld	s1,88(sp)
    800039fe:	7ae2                	ld	s5,56(sp)
    80003a00:	7b42                	ld	s6,48(sp)
    80003a02:	7ba2                	ld	s7,40(sp)
    80003a04:	7c02                	ld	s8,32(sp)
    80003a06:	6165                	add	sp,sp,112
    80003a08:	8082                	ret
    80003a0a:	6946                	ld	s2,80(sp)
    80003a0c:	6a06                	ld	s4,64(sp)
    80003a0e:	6ce2                	ld	s9,24(sp)
    80003a10:	6d42                	ld	s10,16(sp)
    80003a12:	6da2                	ld	s11,8(sp)
    80003a14:	bff9                	j	800039f2 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a16:	89da                	mv	s3,s6
    80003a18:	bfe9                	j	800039f2 <readi+0xd8>
    return 0;
    80003a1a:	4501                	li	a0,0
}
    80003a1c:	8082                	ret

0000000080003a1e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a1e:	457c                	lw	a5,76(a0)
    80003a20:	10d7ee63          	bltu	a5,a3,80003b3c <writei+0x11e>
{
    80003a24:	7159                	add	sp,sp,-112
    80003a26:	f486                	sd	ra,104(sp)
    80003a28:	f0a2                	sd	s0,96(sp)
    80003a2a:	e8ca                	sd	s2,80(sp)
    80003a2c:	fc56                	sd	s5,56(sp)
    80003a2e:	f85a                	sd	s6,48(sp)
    80003a30:	f45e                	sd	s7,40(sp)
    80003a32:	f062                	sd	s8,32(sp)
    80003a34:	1880                	add	s0,sp,112
    80003a36:	8b2a                	mv	s6,a0
    80003a38:	8c2e                	mv	s8,a1
    80003a3a:	8ab2                	mv	s5,a2
    80003a3c:	8936                	mv	s2,a3
    80003a3e:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003a40:	00e687bb          	addw	a5,a3,a4
    80003a44:	0ed7ee63          	bltu	a5,a3,80003b40 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a48:	00043737          	lui	a4,0x43
    80003a4c:	0ef76c63          	bltu	a4,a5,80003b44 <writei+0x126>
    80003a50:	e0d2                	sd	s4,64(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a52:	0c0b8d63          	beqz	s7,80003b2c <writei+0x10e>
    80003a56:	eca6                	sd	s1,88(sp)
    80003a58:	e4ce                	sd	s3,72(sp)
    80003a5a:	ec66                	sd	s9,24(sp)
    80003a5c:	e86a                	sd	s10,16(sp)
    80003a5e:	e46e                	sd	s11,8(sp)
    80003a60:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a62:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a66:	5cfd                	li	s9,-1
    80003a68:	a091                	j	80003aac <writei+0x8e>
    80003a6a:	02099d93          	sll	s11,s3,0x20
    80003a6e:	020ddd93          	srl	s11,s11,0x20
    80003a72:	05848513          	add	a0,s1,88
    80003a76:	86ee                	mv	a3,s11
    80003a78:	8656                	mv	a2,s5
    80003a7a:	85e2                	mv	a1,s8
    80003a7c:	953a                	add	a0,a0,a4
    80003a7e:	fffff097          	auipc	ra,0xfffff
    80003a82:	a72080e7          	jalr	-1422(ra) # 800024f0 <either_copyin>
    80003a86:	07950263          	beq	a0,s9,80003aea <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a8a:	8526                	mv	a0,s1
    80003a8c:	00000097          	auipc	ra,0x0
    80003a90:	780080e7          	jalr	1920(ra) # 8000420c <log_write>
    brelse(bp);
    80003a94:	8526                	mv	a0,s1
    80003a96:	fffff097          	auipc	ra,0xfffff
    80003a9a:	502080e7          	jalr	1282(ra) # 80002f98 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a9e:	01498a3b          	addw	s4,s3,s4
    80003aa2:	0129893b          	addw	s2,s3,s2
    80003aa6:	9aee                	add	s5,s5,s11
    80003aa8:	057a7663          	bgeu	s4,s7,80003af4 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003aac:	000b2483          	lw	s1,0(s6)
    80003ab0:	00a9559b          	srlw	a1,s2,0xa
    80003ab4:	855a                	mv	a0,s6
    80003ab6:	fffff097          	auipc	ra,0xfffff
    80003aba:	7a0080e7          	jalr	1952(ra) # 80003256 <bmap>
    80003abe:	0005059b          	sext.w	a1,a0
    80003ac2:	8526                	mv	a0,s1
    80003ac4:	fffff097          	auipc	ra,0xfffff
    80003ac8:	3a4080e7          	jalr	932(ra) # 80002e68 <bread>
    80003acc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ace:	3ff97713          	and	a4,s2,1023
    80003ad2:	40ed07bb          	subw	a5,s10,a4
    80003ad6:	414b86bb          	subw	a3,s7,s4
    80003ada:	89be                	mv	s3,a5
    80003adc:	2781                	sext.w	a5,a5
    80003ade:	0006861b          	sext.w	a2,a3
    80003ae2:	f8f674e3          	bgeu	a2,a5,80003a6a <writei+0x4c>
    80003ae6:	89b6                	mv	s3,a3
    80003ae8:	b749                	j	80003a6a <writei+0x4c>
      brelse(bp);
    80003aea:	8526                	mv	a0,s1
    80003aec:	fffff097          	auipc	ra,0xfffff
    80003af0:	4ac080e7          	jalr	1196(ra) # 80002f98 <brelse>
  }

  if(off > ip->size)
    80003af4:	04cb2783          	lw	a5,76(s6)
    80003af8:	0327fc63          	bgeu	a5,s2,80003b30 <writei+0x112>
    ip->size = off;
    80003afc:	052b2623          	sw	s2,76(s6)
    80003b00:	64e6                	ld	s1,88(sp)
    80003b02:	69a6                	ld	s3,72(sp)
    80003b04:	6ce2                	ld	s9,24(sp)
    80003b06:	6d42                	ld	s10,16(sp)
    80003b08:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b0a:	855a                	mv	a0,s6
    80003b0c:	00000097          	auipc	ra,0x0
    80003b10:	a8a080e7          	jalr	-1398(ra) # 80003596 <iupdate>

  return tot;
    80003b14:	000a051b          	sext.w	a0,s4
    80003b18:	6a06                	ld	s4,64(sp)
}
    80003b1a:	70a6                	ld	ra,104(sp)
    80003b1c:	7406                	ld	s0,96(sp)
    80003b1e:	6946                	ld	s2,80(sp)
    80003b20:	7ae2                	ld	s5,56(sp)
    80003b22:	7b42                	ld	s6,48(sp)
    80003b24:	7ba2                	ld	s7,40(sp)
    80003b26:	7c02                	ld	s8,32(sp)
    80003b28:	6165                	add	sp,sp,112
    80003b2a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b2c:	8a5e                	mv	s4,s7
    80003b2e:	bff1                	j	80003b0a <writei+0xec>
    80003b30:	64e6                	ld	s1,88(sp)
    80003b32:	69a6                	ld	s3,72(sp)
    80003b34:	6ce2                	ld	s9,24(sp)
    80003b36:	6d42                	ld	s10,16(sp)
    80003b38:	6da2                	ld	s11,8(sp)
    80003b3a:	bfc1                	j	80003b0a <writei+0xec>
    return -1;
    80003b3c:	557d                	li	a0,-1
}
    80003b3e:	8082                	ret
    return -1;
    80003b40:	557d                	li	a0,-1
    80003b42:	bfe1                	j	80003b1a <writei+0xfc>
    return -1;
    80003b44:	557d                	li	a0,-1
    80003b46:	bfd1                	j	80003b1a <writei+0xfc>

0000000080003b48 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003b48:	1141                	add	sp,sp,-16
    80003b4a:	e406                	sd	ra,8(sp)
    80003b4c:	e022                	sd	s0,0(sp)
    80003b4e:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003b50:	4639                	li	a2,14
    80003b52:	ffffd097          	auipc	ra,0xffffd
    80003b56:	2ac080e7          	jalr	684(ra) # 80000dfe <strncmp>
}
    80003b5a:	60a2                	ld	ra,8(sp)
    80003b5c:	6402                	ld	s0,0(sp)
    80003b5e:	0141                	add	sp,sp,16
    80003b60:	8082                	ret

0000000080003b62 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b62:	7139                	add	sp,sp,-64
    80003b64:	fc06                	sd	ra,56(sp)
    80003b66:	f822                	sd	s0,48(sp)
    80003b68:	f426                	sd	s1,40(sp)
    80003b6a:	f04a                	sd	s2,32(sp)
    80003b6c:	ec4e                	sd	s3,24(sp)
    80003b6e:	e852                	sd	s4,16(sp)
    80003b70:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b72:	04451703          	lh	a4,68(a0)
    80003b76:	4785                	li	a5,1
    80003b78:	00f71a63          	bne	a4,a5,80003b8c <dirlookup+0x2a>
    80003b7c:	892a                	mv	s2,a0
    80003b7e:	89ae                	mv	s3,a1
    80003b80:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b82:	457c                	lw	a5,76(a0)
    80003b84:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b86:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b88:	e79d                	bnez	a5,80003bb6 <dirlookup+0x54>
    80003b8a:	a8a5                	j	80003c02 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b8c:	00005517          	auipc	a0,0x5
    80003b90:	94450513          	add	a0,a0,-1724 # 800084d0 <etext+0x4d0>
    80003b94:	ffffd097          	auipc	ra,0xffffd
    80003b98:	9c6080e7          	jalr	-1594(ra) # 8000055a <panic>
      panic("dirlookup read");
    80003b9c:	00005517          	auipc	a0,0x5
    80003ba0:	94c50513          	add	a0,a0,-1716 # 800084e8 <etext+0x4e8>
    80003ba4:	ffffd097          	auipc	ra,0xffffd
    80003ba8:	9b6080e7          	jalr	-1610(ra) # 8000055a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bac:	24c1                	addw	s1,s1,16
    80003bae:	04c92783          	lw	a5,76(s2)
    80003bb2:	04f4f763          	bgeu	s1,a5,80003c00 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003bb6:	4741                	li	a4,16
    80003bb8:	86a6                	mv	a3,s1
    80003bba:	fc040613          	add	a2,s0,-64
    80003bbe:	4581                	li	a1,0
    80003bc0:	854a                	mv	a0,s2
    80003bc2:	00000097          	auipc	ra,0x0
    80003bc6:	d58080e7          	jalr	-680(ra) # 8000391a <readi>
    80003bca:	47c1                	li	a5,16
    80003bcc:	fcf518e3          	bne	a0,a5,80003b9c <dirlookup+0x3a>
    if(de.inum == 0)
    80003bd0:	fc045783          	lhu	a5,-64(s0)
    80003bd4:	dfe1                	beqz	a5,80003bac <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003bd6:	fc240593          	add	a1,s0,-62
    80003bda:	854e                	mv	a0,s3
    80003bdc:	00000097          	auipc	ra,0x0
    80003be0:	f6c080e7          	jalr	-148(ra) # 80003b48 <namecmp>
    80003be4:	f561                	bnez	a0,80003bac <dirlookup+0x4a>
      if(poff)
    80003be6:	000a0463          	beqz	s4,80003bee <dirlookup+0x8c>
        *poff = off;
    80003bea:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003bee:	fc045583          	lhu	a1,-64(s0)
    80003bf2:	00092503          	lw	a0,0(s2)
    80003bf6:	fffff097          	auipc	ra,0xfffff
    80003bfa:	73c080e7          	jalr	1852(ra) # 80003332 <iget>
    80003bfe:	a011                	j	80003c02 <dirlookup+0xa0>
  return 0;
    80003c00:	4501                	li	a0,0
}
    80003c02:	70e2                	ld	ra,56(sp)
    80003c04:	7442                	ld	s0,48(sp)
    80003c06:	74a2                	ld	s1,40(sp)
    80003c08:	7902                	ld	s2,32(sp)
    80003c0a:	69e2                	ld	s3,24(sp)
    80003c0c:	6a42                	ld	s4,16(sp)
    80003c0e:	6121                	add	sp,sp,64
    80003c10:	8082                	ret

0000000080003c12 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c12:	711d                	add	sp,sp,-96
    80003c14:	ec86                	sd	ra,88(sp)
    80003c16:	e8a2                	sd	s0,80(sp)
    80003c18:	e4a6                	sd	s1,72(sp)
    80003c1a:	e0ca                	sd	s2,64(sp)
    80003c1c:	fc4e                	sd	s3,56(sp)
    80003c1e:	f852                	sd	s4,48(sp)
    80003c20:	f456                	sd	s5,40(sp)
    80003c22:	f05a                	sd	s6,32(sp)
    80003c24:	ec5e                	sd	s7,24(sp)
    80003c26:	e862                	sd	s8,16(sp)
    80003c28:	e466                	sd	s9,8(sp)
    80003c2a:	1080                	add	s0,sp,96
    80003c2c:	84aa                	mv	s1,a0
    80003c2e:	8b2e                	mv	s6,a1
    80003c30:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003c32:	00054703          	lbu	a4,0(a0)
    80003c36:	02f00793          	li	a5,47
    80003c3a:	02f70263          	beq	a4,a5,80003c5e <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003c3e:	ffffe097          	auipc	ra,0xffffe
    80003c42:	df2080e7          	jalr	-526(ra) # 80001a30 <myproc>
    80003c46:	15053503          	ld	a0,336(a0)
    80003c4a:	00000097          	auipc	ra,0x0
    80003c4e:	9da080e7          	jalr	-1574(ra) # 80003624 <idup>
    80003c52:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003c54:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003c58:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003c5a:	4b85                	li	s7,1
    80003c5c:	a875                	j	80003d18 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003c5e:	4585                	li	a1,1
    80003c60:	4505                	li	a0,1
    80003c62:	fffff097          	auipc	ra,0xfffff
    80003c66:	6d0080e7          	jalr	1744(ra) # 80003332 <iget>
    80003c6a:	8a2a                	mv	s4,a0
    80003c6c:	b7e5                	j	80003c54 <namex+0x42>
      iunlockput(ip);
    80003c6e:	8552                	mv	a0,s4
    80003c70:	00000097          	auipc	ra,0x0
    80003c74:	c58080e7          	jalr	-936(ra) # 800038c8 <iunlockput>
      return 0;
    80003c78:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c7a:	8552                	mv	a0,s4
    80003c7c:	60e6                	ld	ra,88(sp)
    80003c7e:	6446                	ld	s0,80(sp)
    80003c80:	64a6                	ld	s1,72(sp)
    80003c82:	6906                	ld	s2,64(sp)
    80003c84:	79e2                	ld	s3,56(sp)
    80003c86:	7a42                	ld	s4,48(sp)
    80003c88:	7aa2                	ld	s5,40(sp)
    80003c8a:	7b02                	ld	s6,32(sp)
    80003c8c:	6be2                	ld	s7,24(sp)
    80003c8e:	6c42                	ld	s8,16(sp)
    80003c90:	6ca2                	ld	s9,8(sp)
    80003c92:	6125                	add	sp,sp,96
    80003c94:	8082                	ret
      iunlock(ip);
    80003c96:	8552                	mv	a0,s4
    80003c98:	00000097          	auipc	ra,0x0
    80003c9c:	a90080e7          	jalr	-1392(ra) # 80003728 <iunlock>
      return ip;
    80003ca0:	bfe9                	j	80003c7a <namex+0x68>
      iunlockput(ip);
    80003ca2:	8552                	mv	a0,s4
    80003ca4:	00000097          	auipc	ra,0x0
    80003ca8:	c24080e7          	jalr	-988(ra) # 800038c8 <iunlockput>
      return 0;
    80003cac:	8a4e                	mv	s4,s3
    80003cae:	b7f1                	j	80003c7a <namex+0x68>
  len = path - s;
    80003cb0:	40998633          	sub	a2,s3,s1
    80003cb4:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003cb8:	099c5863          	bge	s8,s9,80003d48 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003cbc:	4639                	li	a2,14
    80003cbe:	85a6                	mv	a1,s1
    80003cc0:	8556                	mv	a0,s5
    80003cc2:	ffffd097          	auipc	ra,0xffffd
    80003cc6:	0c8080e7          	jalr	200(ra) # 80000d8a <memmove>
    80003cca:	84ce                	mv	s1,s3
  while(*path == '/')
    80003ccc:	0004c783          	lbu	a5,0(s1)
    80003cd0:	01279763          	bne	a5,s2,80003cde <namex+0xcc>
    path++;
    80003cd4:	0485                	add	s1,s1,1
  while(*path == '/')
    80003cd6:	0004c783          	lbu	a5,0(s1)
    80003cda:	ff278de3          	beq	a5,s2,80003cd4 <namex+0xc2>
    ilock(ip);
    80003cde:	8552                	mv	a0,s4
    80003ce0:	00000097          	auipc	ra,0x0
    80003ce4:	982080e7          	jalr	-1662(ra) # 80003662 <ilock>
    if(ip->type != T_DIR){
    80003ce8:	044a1783          	lh	a5,68(s4)
    80003cec:	f97791e3          	bne	a5,s7,80003c6e <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003cf0:	000b0563          	beqz	s6,80003cfa <namex+0xe8>
    80003cf4:	0004c783          	lbu	a5,0(s1)
    80003cf8:	dfd9                	beqz	a5,80003c96 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003cfa:	4601                	li	a2,0
    80003cfc:	85d6                	mv	a1,s5
    80003cfe:	8552                	mv	a0,s4
    80003d00:	00000097          	auipc	ra,0x0
    80003d04:	e62080e7          	jalr	-414(ra) # 80003b62 <dirlookup>
    80003d08:	89aa                	mv	s3,a0
    80003d0a:	dd41                	beqz	a0,80003ca2 <namex+0x90>
    iunlockput(ip);
    80003d0c:	8552                	mv	a0,s4
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	bba080e7          	jalr	-1094(ra) # 800038c8 <iunlockput>
    ip = next;
    80003d16:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d18:	0004c783          	lbu	a5,0(s1)
    80003d1c:	01279763          	bne	a5,s2,80003d2a <namex+0x118>
    path++;
    80003d20:	0485                	add	s1,s1,1
  while(*path == '/')
    80003d22:	0004c783          	lbu	a5,0(s1)
    80003d26:	ff278de3          	beq	a5,s2,80003d20 <namex+0x10e>
  if(*path == 0)
    80003d2a:	cb9d                	beqz	a5,80003d60 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003d2c:	0004c783          	lbu	a5,0(s1)
    80003d30:	89a6                	mv	s3,s1
  len = path - s;
    80003d32:	4c81                	li	s9,0
    80003d34:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003d36:	01278963          	beq	a5,s2,80003d48 <namex+0x136>
    80003d3a:	dbbd                	beqz	a5,80003cb0 <namex+0x9e>
    path++;
    80003d3c:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80003d3e:	0009c783          	lbu	a5,0(s3)
    80003d42:	ff279ce3          	bne	a5,s2,80003d3a <namex+0x128>
    80003d46:	b7ad                	j	80003cb0 <namex+0x9e>
    memmove(name, s, len);
    80003d48:	2601                	sext.w	a2,a2
    80003d4a:	85a6                	mv	a1,s1
    80003d4c:	8556                	mv	a0,s5
    80003d4e:	ffffd097          	auipc	ra,0xffffd
    80003d52:	03c080e7          	jalr	60(ra) # 80000d8a <memmove>
    name[len] = 0;
    80003d56:	9cd6                	add	s9,s9,s5
    80003d58:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d5c:	84ce                	mv	s1,s3
    80003d5e:	b7bd                	j	80003ccc <namex+0xba>
  if(nameiparent){
    80003d60:	f00b0de3          	beqz	s6,80003c7a <namex+0x68>
    iput(ip);
    80003d64:	8552                	mv	a0,s4
    80003d66:	00000097          	auipc	ra,0x0
    80003d6a:	aba080e7          	jalr	-1350(ra) # 80003820 <iput>
    return 0;
    80003d6e:	4a01                	li	s4,0
    80003d70:	b729                	j	80003c7a <namex+0x68>

0000000080003d72 <dirlink>:
{
    80003d72:	7139                	add	sp,sp,-64
    80003d74:	fc06                	sd	ra,56(sp)
    80003d76:	f822                	sd	s0,48(sp)
    80003d78:	f04a                	sd	s2,32(sp)
    80003d7a:	ec4e                	sd	s3,24(sp)
    80003d7c:	e852                	sd	s4,16(sp)
    80003d7e:	0080                	add	s0,sp,64
    80003d80:	892a                	mv	s2,a0
    80003d82:	8a2e                	mv	s4,a1
    80003d84:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d86:	4601                	li	a2,0
    80003d88:	00000097          	auipc	ra,0x0
    80003d8c:	dda080e7          	jalr	-550(ra) # 80003b62 <dirlookup>
    80003d90:	ed25                	bnez	a0,80003e08 <dirlink+0x96>
    80003d92:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d94:	04c92483          	lw	s1,76(s2)
    80003d98:	c49d                	beqz	s1,80003dc6 <dirlink+0x54>
    80003d9a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d9c:	4741                	li	a4,16
    80003d9e:	86a6                	mv	a3,s1
    80003da0:	fc040613          	add	a2,s0,-64
    80003da4:	4581                	li	a1,0
    80003da6:	854a                	mv	a0,s2
    80003da8:	00000097          	auipc	ra,0x0
    80003dac:	b72080e7          	jalr	-1166(ra) # 8000391a <readi>
    80003db0:	47c1                	li	a5,16
    80003db2:	06f51163          	bne	a0,a5,80003e14 <dirlink+0xa2>
    if(de.inum == 0)
    80003db6:	fc045783          	lhu	a5,-64(s0)
    80003dba:	c791                	beqz	a5,80003dc6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dbc:	24c1                	addw	s1,s1,16
    80003dbe:	04c92783          	lw	a5,76(s2)
    80003dc2:	fcf4ede3          	bltu	s1,a5,80003d9c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003dc6:	4639                	li	a2,14
    80003dc8:	85d2                	mv	a1,s4
    80003dca:	fc240513          	add	a0,s0,-62
    80003dce:	ffffd097          	auipc	ra,0xffffd
    80003dd2:	066080e7          	jalr	102(ra) # 80000e34 <strncpy>
  de.inum = inum;
    80003dd6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dda:	4741                	li	a4,16
    80003ddc:	86a6                	mv	a3,s1
    80003dde:	fc040613          	add	a2,s0,-64
    80003de2:	4581                	li	a1,0
    80003de4:	854a                	mv	a0,s2
    80003de6:	00000097          	auipc	ra,0x0
    80003dea:	c38080e7          	jalr	-968(ra) # 80003a1e <writei>
    80003dee:	872a                	mv	a4,a0
    80003df0:	47c1                	li	a5,16
  return 0;
    80003df2:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003df4:	02f71863          	bne	a4,a5,80003e24 <dirlink+0xb2>
    80003df8:	74a2                	ld	s1,40(sp)
}
    80003dfa:	70e2                	ld	ra,56(sp)
    80003dfc:	7442                	ld	s0,48(sp)
    80003dfe:	7902                	ld	s2,32(sp)
    80003e00:	69e2                	ld	s3,24(sp)
    80003e02:	6a42                	ld	s4,16(sp)
    80003e04:	6121                	add	sp,sp,64
    80003e06:	8082                	ret
    iput(ip);
    80003e08:	00000097          	auipc	ra,0x0
    80003e0c:	a18080e7          	jalr	-1512(ra) # 80003820 <iput>
    return -1;
    80003e10:	557d                	li	a0,-1
    80003e12:	b7e5                	j	80003dfa <dirlink+0x88>
      panic("dirlink read");
    80003e14:	00004517          	auipc	a0,0x4
    80003e18:	6e450513          	add	a0,a0,1764 # 800084f8 <etext+0x4f8>
    80003e1c:	ffffc097          	auipc	ra,0xffffc
    80003e20:	73e080e7          	jalr	1854(ra) # 8000055a <panic>
    panic("dirlink");
    80003e24:	00004517          	auipc	a0,0x4
    80003e28:	7e450513          	add	a0,a0,2020 # 80008608 <etext+0x608>
    80003e2c:	ffffc097          	auipc	ra,0xffffc
    80003e30:	72e080e7          	jalr	1838(ra) # 8000055a <panic>

0000000080003e34 <namei>:

struct inode*
namei(char *path)
{
    80003e34:	1101                	add	sp,sp,-32
    80003e36:	ec06                	sd	ra,24(sp)
    80003e38:	e822                	sd	s0,16(sp)
    80003e3a:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003e3c:	fe040613          	add	a2,s0,-32
    80003e40:	4581                	li	a1,0
    80003e42:	00000097          	auipc	ra,0x0
    80003e46:	dd0080e7          	jalr	-560(ra) # 80003c12 <namex>
}
    80003e4a:	60e2                	ld	ra,24(sp)
    80003e4c:	6442                	ld	s0,16(sp)
    80003e4e:	6105                	add	sp,sp,32
    80003e50:	8082                	ret

0000000080003e52 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003e52:	1141                	add	sp,sp,-16
    80003e54:	e406                	sd	ra,8(sp)
    80003e56:	e022                	sd	s0,0(sp)
    80003e58:	0800                	add	s0,sp,16
    80003e5a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003e5c:	4585                	li	a1,1
    80003e5e:	00000097          	auipc	ra,0x0
    80003e62:	db4080e7          	jalr	-588(ra) # 80003c12 <namex>
}
    80003e66:	60a2                	ld	ra,8(sp)
    80003e68:	6402                	ld	s0,0(sp)
    80003e6a:	0141                	add	sp,sp,16
    80003e6c:	8082                	ret

0000000080003e6e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e6e:	1101                	add	sp,sp,-32
    80003e70:	ec06                	sd	ra,24(sp)
    80003e72:	e822                	sd	s0,16(sp)
    80003e74:	e426                	sd	s1,8(sp)
    80003e76:	e04a                	sd	s2,0(sp)
    80003e78:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e7a:	0001d917          	auipc	s2,0x1d
    80003e7e:	3f690913          	add	s2,s2,1014 # 80021270 <log>
    80003e82:	01892583          	lw	a1,24(s2)
    80003e86:	02892503          	lw	a0,40(s2)
    80003e8a:	fffff097          	auipc	ra,0xfffff
    80003e8e:	fde080e7          	jalr	-34(ra) # 80002e68 <bread>
    80003e92:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e94:	02c92603          	lw	a2,44(s2)
    80003e98:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e9a:	00c05f63          	blez	a2,80003eb8 <write_head+0x4a>
    80003e9e:	0001d717          	auipc	a4,0x1d
    80003ea2:	40270713          	add	a4,a4,1026 # 800212a0 <log+0x30>
    80003ea6:	87aa                	mv	a5,a0
    80003ea8:	060a                	sll	a2,a2,0x2
    80003eaa:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003eac:	4314                	lw	a3,0(a4)
    80003eae:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003eb0:	0711                	add	a4,a4,4
    80003eb2:	0791                	add	a5,a5,4
    80003eb4:	fec79ce3          	bne	a5,a2,80003eac <write_head+0x3e>
  }
  bwrite(buf);
    80003eb8:	8526                	mv	a0,s1
    80003eba:	fffff097          	auipc	ra,0xfffff
    80003ebe:	0a0080e7          	jalr	160(ra) # 80002f5a <bwrite>
  brelse(buf);
    80003ec2:	8526                	mv	a0,s1
    80003ec4:	fffff097          	auipc	ra,0xfffff
    80003ec8:	0d4080e7          	jalr	212(ra) # 80002f98 <brelse>
}
    80003ecc:	60e2                	ld	ra,24(sp)
    80003ece:	6442                	ld	s0,16(sp)
    80003ed0:	64a2                	ld	s1,8(sp)
    80003ed2:	6902                	ld	s2,0(sp)
    80003ed4:	6105                	add	sp,sp,32
    80003ed6:	8082                	ret

0000000080003ed8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ed8:	0001d797          	auipc	a5,0x1d
    80003edc:	3c47a783          	lw	a5,964(a5) # 8002129c <log+0x2c>
    80003ee0:	0af05d63          	blez	a5,80003f9a <install_trans+0xc2>
{
    80003ee4:	7139                	add	sp,sp,-64
    80003ee6:	fc06                	sd	ra,56(sp)
    80003ee8:	f822                	sd	s0,48(sp)
    80003eea:	f426                	sd	s1,40(sp)
    80003eec:	f04a                	sd	s2,32(sp)
    80003eee:	ec4e                	sd	s3,24(sp)
    80003ef0:	e852                	sd	s4,16(sp)
    80003ef2:	e456                	sd	s5,8(sp)
    80003ef4:	e05a                	sd	s6,0(sp)
    80003ef6:	0080                	add	s0,sp,64
    80003ef8:	8b2a                	mv	s6,a0
    80003efa:	0001da97          	auipc	s5,0x1d
    80003efe:	3a6a8a93          	add	s5,s5,934 # 800212a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f02:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f04:	0001d997          	auipc	s3,0x1d
    80003f08:	36c98993          	add	s3,s3,876 # 80021270 <log>
    80003f0c:	a00d                	j	80003f2e <install_trans+0x56>
    brelse(lbuf);
    80003f0e:	854a                	mv	a0,s2
    80003f10:	fffff097          	auipc	ra,0xfffff
    80003f14:	088080e7          	jalr	136(ra) # 80002f98 <brelse>
    brelse(dbuf);
    80003f18:	8526                	mv	a0,s1
    80003f1a:	fffff097          	auipc	ra,0xfffff
    80003f1e:	07e080e7          	jalr	126(ra) # 80002f98 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f22:	2a05                	addw	s4,s4,1
    80003f24:	0a91                	add	s5,s5,4
    80003f26:	02c9a783          	lw	a5,44(s3)
    80003f2a:	04fa5e63          	bge	s4,a5,80003f86 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f2e:	0189a583          	lw	a1,24(s3)
    80003f32:	014585bb          	addw	a1,a1,s4
    80003f36:	2585                	addw	a1,a1,1
    80003f38:	0289a503          	lw	a0,40(s3)
    80003f3c:	fffff097          	auipc	ra,0xfffff
    80003f40:	f2c080e7          	jalr	-212(ra) # 80002e68 <bread>
    80003f44:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003f46:	000aa583          	lw	a1,0(s5)
    80003f4a:	0289a503          	lw	a0,40(s3)
    80003f4e:	fffff097          	auipc	ra,0xfffff
    80003f52:	f1a080e7          	jalr	-230(ra) # 80002e68 <bread>
    80003f56:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003f58:	40000613          	li	a2,1024
    80003f5c:	05890593          	add	a1,s2,88
    80003f60:	05850513          	add	a0,a0,88
    80003f64:	ffffd097          	auipc	ra,0xffffd
    80003f68:	e26080e7          	jalr	-474(ra) # 80000d8a <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f6c:	8526                	mv	a0,s1
    80003f6e:	fffff097          	auipc	ra,0xfffff
    80003f72:	fec080e7          	jalr	-20(ra) # 80002f5a <bwrite>
    if(recovering == 0)
    80003f76:	f80b1ce3          	bnez	s6,80003f0e <install_trans+0x36>
      bunpin(dbuf);
    80003f7a:	8526                	mv	a0,s1
    80003f7c:	fffff097          	auipc	ra,0xfffff
    80003f80:	0f4080e7          	jalr	244(ra) # 80003070 <bunpin>
    80003f84:	b769                	j	80003f0e <install_trans+0x36>
}
    80003f86:	70e2                	ld	ra,56(sp)
    80003f88:	7442                	ld	s0,48(sp)
    80003f8a:	74a2                	ld	s1,40(sp)
    80003f8c:	7902                	ld	s2,32(sp)
    80003f8e:	69e2                	ld	s3,24(sp)
    80003f90:	6a42                	ld	s4,16(sp)
    80003f92:	6aa2                	ld	s5,8(sp)
    80003f94:	6b02                	ld	s6,0(sp)
    80003f96:	6121                	add	sp,sp,64
    80003f98:	8082                	ret
    80003f9a:	8082                	ret

0000000080003f9c <initlog>:
{
    80003f9c:	7179                	add	sp,sp,-48
    80003f9e:	f406                	sd	ra,40(sp)
    80003fa0:	f022                	sd	s0,32(sp)
    80003fa2:	ec26                	sd	s1,24(sp)
    80003fa4:	e84a                	sd	s2,16(sp)
    80003fa6:	e44e                	sd	s3,8(sp)
    80003fa8:	1800                	add	s0,sp,48
    80003faa:	892a                	mv	s2,a0
    80003fac:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003fae:	0001d497          	auipc	s1,0x1d
    80003fb2:	2c248493          	add	s1,s1,706 # 80021270 <log>
    80003fb6:	00004597          	auipc	a1,0x4
    80003fba:	55258593          	add	a1,a1,1362 # 80008508 <etext+0x508>
    80003fbe:	8526                	mv	a0,s1
    80003fc0:	ffffd097          	auipc	ra,0xffffd
    80003fc4:	be2080e7          	jalr	-1054(ra) # 80000ba2 <initlock>
  log.start = sb->logstart;
    80003fc8:	0149a583          	lw	a1,20(s3)
    80003fcc:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003fce:	0109a783          	lw	a5,16(s3)
    80003fd2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003fd4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003fd8:	854a                	mv	a0,s2
    80003fda:	fffff097          	auipc	ra,0xfffff
    80003fde:	e8e080e7          	jalr	-370(ra) # 80002e68 <bread>
  log.lh.n = lh->n;
    80003fe2:	4d30                	lw	a2,88(a0)
    80003fe4:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003fe6:	00c05f63          	blez	a2,80004004 <initlog+0x68>
    80003fea:	87aa                	mv	a5,a0
    80003fec:	0001d717          	auipc	a4,0x1d
    80003ff0:	2b470713          	add	a4,a4,692 # 800212a0 <log+0x30>
    80003ff4:	060a                	sll	a2,a2,0x2
    80003ff6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003ff8:	4ff4                	lw	a3,92(a5)
    80003ffa:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ffc:	0791                	add	a5,a5,4
    80003ffe:	0711                	add	a4,a4,4
    80004000:	fec79ce3          	bne	a5,a2,80003ff8 <initlog+0x5c>
  brelse(buf);
    80004004:	fffff097          	auipc	ra,0xfffff
    80004008:	f94080e7          	jalr	-108(ra) # 80002f98 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000400c:	4505                	li	a0,1
    8000400e:	00000097          	auipc	ra,0x0
    80004012:	eca080e7          	jalr	-310(ra) # 80003ed8 <install_trans>
  log.lh.n = 0;
    80004016:	0001d797          	auipc	a5,0x1d
    8000401a:	2807a323          	sw	zero,646(a5) # 8002129c <log+0x2c>
  write_head(); // clear the log
    8000401e:	00000097          	auipc	ra,0x0
    80004022:	e50080e7          	jalr	-432(ra) # 80003e6e <write_head>
}
    80004026:	70a2                	ld	ra,40(sp)
    80004028:	7402                	ld	s0,32(sp)
    8000402a:	64e2                	ld	s1,24(sp)
    8000402c:	6942                	ld	s2,16(sp)
    8000402e:	69a2                	ld	s3,8(sp)
    80004030:	6145                	add	sp,sp,48
    80004032:	8082                	ret

0000000080004034 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004034:	1101                	add	sp,sp,-32
    80004036:	ec06                	sd	ra,24(sp)
    80004038:	e822                	sd	s0,16(sp)
    8000403a:	e426                	sd	s1,8(sp)
    8000403c:	e04a                	sd	s2,0(sp)
    8000403e:	1000                	add	s0,sp,32
  acquire(&log.lock);
    80004040:	0001d517          	auipc	a0,0x1d
    80004044:	23050513          	add	a0,a0,560 # 80021270 <log>
    80004048:	ffffd097          	auipc	ra,0xffffd
    8000404c:	bea080e7          	jalr	-1046(ra) # 80000c32 <acquire>
  while(1){
    if(log.committing){
    80004050:	0001d497          	auipc	s1,0x1d
    80004054:	22048493          	add	s1,s1,544 # 80021270 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004058:	4979                	li	s2,30
    8000405a:	a039                	j	80004068 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000405c:	85a6                	mv	a1,s1
    8000405e:	8526                	mv	a0,s1
    80004060:	ffffe097          	auipc	ra,0xffffe
    80004064:	096080e7          	jalr	150(ra) # 800020f6 <sleep>
    if(log.committing){
    80004068:	50dc                	lw	a5,36(s1)
    8000406a:	fbed                	bnez	a5,8000405c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000406c:	5098                	lw	a4,32(s1)
    8000406e:	2705                	addw	a4,a4,1
    80004070:	0027179b          	sllw	a5,a4,0x2
    80004074:	9fb9                	addw	a5,a5,a4
    80004076:	0017979b          	sllw	a5,a5,0x1
    8000407a:	54d4                	lw	a3,44(s1)
    8000407c:	9fb5                	addw	a5,a5,a3
    8000407e:	00f95963          	bge	s2,a5,80004090 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004082:	85a6                	mv	a1,s1
    80004084:	8526                	mv	a0,s1
    80004086:	ffffe097          	auipc	ra,0xffffe
    8000408a:	070080e7          	jalr	112(ra) # 800020f6 <sleep>
    8000408e:	bfe9                	j	80004068 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004090:	0001d517          	auipc	a0,0x1d
    80004094:	1e050513          	add	a0,a0,480 # 80021270 <log>
    80004098:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000409a:	ffffd097          	auipc	ra,0xffffd
    8000409e:	c4c080e7          	jalr	-948(ra) # 80000ce6 <release>
      break;
    }
  }
}
    800040a2:	60e2                	ld	ra,24(sp)
    800040a4:	6442                	ld	s0,16(sp)
    800040a6:	64a2                	ld	s1,8(sp)
    800040a8:	6902                	ld	s2,0(sp)
    800040aa:	6105                	add	sp,sp,32
    800040ac:	8082                	ret

00000000800040ae <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800040ae:	7139                	add	sp,sp,-64
    800040b0:	fc06                	sd	ra,56(sp)
    800040b2:	f822                	sd	s0,48(sp)
    800040b4:	f426                	sd	s1,40(sp)
    800040b6:	f04a                	sd	s2,32(sp)
    800040b8:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800040ba:	0001d497          	auipc	s1,0x1d
    800040be:	1b648493          	add	s1,s1,438 # 80021270 <log>
    800040c2:	8526                	mv	a0,s1
    800040c4:	ffffd097          	auipc	ra,0xffffd
    800040c8:	b6e080e7          	jalr	-1170(ra) # 80000c32 <acquire>
  log.outstanding -= 1;
    800040cc:	509c                	lw	a5,32(s1)
    800040ce:	37fd                	addw	a5,a5,-1
    800040d0:	0007891b          	sext.w	s2,a5
    800040d4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800040d6:	50dc                	lw	a5,36(s1)
    800040d8:	e7b9                	bnez	a5,80004126 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    800040da:	06091163          	bnez	s2,8000413c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800040de:	0001d497          	auipc	s1,0x1d
    800040e2:	19248493          	add	s1,s1,402 # 80021270 <log>
    800040e6:	4785                	li	a5,1
    800040e8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800040ea:	8526                	mv	a0,s1
    800040ec:	ffffd097          	auipc	ra,0xffffd
    800040f0:	bfa080e7          	jalr	-1030(ra) # 80000ce6 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800040f4:	54dc                	lw	a5,44(s1)
    800040f6:	06f04763          	bgtz	a5,80004164 <end_op+0xb6>
    acquire(&log.lock);
    800040fa:	0001d497          	auipc	s1,0x1d
    800040fe:	17648493          	add	s1,s1,374 # 80021270 <log>
    80004102:	8526                	mv	a0,s1
    80004104:	ffffd097          	auipc	ra,0xffffd
    80004108:	b2e080e7          	jalr	-1234(ra) # 80000c32 <acquire>
    log.committing = 0;
    8000410c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004110:	8526                	mv	a0,s1
    80004112:	ffffe097          	auipc	ra,0xffffe
    80004116:	170080e7          	jalr	368(ra) # 80002282 <wakeup>
    release(&log.lock);
    8000411a:	8526                	mv	a0,s1
    8000411c:	ffffd097          	auipc	ra,0xffffd
    80004120:	bca080e7          	jalr	-1078(ra) # 80000ce6 <release>
}
    80004124:	a815                	j	80004158 <end_op+0xaa>
    80004126:	ec4e                	sd	s3,24(sp)
    80004128:	e852                	sd	s4,16(sp)
    8000412a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000412c:	00004517          	auipc	a0,0x4
    80004130:	3e450513          	add	a0,a0,996 # 80008510 <etext+0x510>
    80004134:	ffffc097          	auipc	ra,0xffffc
    80004138:	426080e7          	jalr	1062(ra) # 8000055a <panic>
    wakeup(&log);
    8000413c:	0001d497          	auipc	s1,0x1d
    80004140:	13448493          	add	s1,s1,308 # 80021270 <log>
    80004144:	8526                	mv	a0,s1
    80004146:	ffffe097          	auipc	ra,0xffffe
    8000414a:	13c080e7          	jalr	316(ra) # 80002282 <wakeup>
  release(&log.lock);
    8000414e:	8526                	mv	a0,s1
    80004150:	ffffd097          	auipc	ra,0xffffd
    80004154:	b96080e7          	jalr	-1130(ra) # 80000ce6 <release>
}
    80004158:	70e2                	ld	ra,56(sp)
    8000415a:	7442                	ld	s0,48(sp)
    8000415c:	74a2                	ld	s1,40(sp)
    8000415e:	7902                	ld	s2,32(sp)
    80004160:	6121                	add	sp,sp,64
    80004162:	8082                	ret
    80004164:	ec4e                	sd	s3,24(sp)
    80004166:	e852                	sd	s4,16(sp)
    80004168:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000416a:	0001da97          	auipc	s5,0x1d
    8000416e:	136a8a93          	add	s5,s5,310 # 800212a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004172:	0001da17          	auipc	s4,0x1d
    80004176:	0fea0a13          	add	s4,s4,254 # 80021270 <log>
    8000417a:	018a2583          	lw	a1,24(s4)
    8000417e:	012585bb          	addw	a1,a1,s2
    80004182:	2585                	addw	a1,a1,1
    80004184:	028a2503          	lw	a0,40(s4)
    80004188:	fffff097          	auipc	ra,0xfffff
    8000418c:	ce0080e7          	jalr	-800(ra) # 80002e68 <bread>
    80004190:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004192:	000aa583          	lw	a1,0(s5)
    80004196:	028a2503          	lw	a0,40(s4)
    8000419a:	fffff097          	auipc	ra,0xfffff
    8000419e:	cce080e7          	jalr	-818(ra) # 80002e68 <bread>
    800041a2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800041a4:	40000613          	li	a2,1024
    800041a8:	05850593          	add	a1,a0,88
    800041ac:	05848513          	add	a0,s1,88
    800041b0:	ffffd097          	auipc	ra,0xffffd
    800041b4:	bda080e7          	jalr	-1062(ra) # 80000d8a <memmove>
    bwrite(to);  // write the log
    800041b8:	8526                	mv	a0,s1
    800041ba:	fffff097          	auipc	ra,0xfffff
    800041be:	da0080e7          	jalr	-608(ra) # 80002f5a <bwrite>
    brelse(from);
    800041c2:	854e                	mv	a0,s3
    800041c4:	fffff097          	auipc	ra,0xfffff
    800041c8:	dd4080e7          	jalr	-556(ra) # 80002f98 <brelse>
    brelse(to);
    800041cc:	8526                	mv	a0,s1
    800041ce:	fffff097          	auipc	ra,0xfffff
    800041d2:	dca080e7          	jalr	-566(ra) # 80002f98 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041d6:	2905                	addw	s2,s2,1
    800041d8:	0a91                	add	s5,s5,4
    800041da:	02ca2783          	lw	a5,44(s4)
    800041de:	f8f94ee3          	blt	s2,a5,8000417a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800041e2:	00000097          	auipc	ra,0x0
    800041e6:	c8c080e7          	jalr	-884(ra) # 80003e6e <write_head>
    install_trans(0); // Now install writes to home locations
    800041ea:	4501                	li	a0,0
    800041ec:	00000097          	auipc	ra,0x0
    800041f0:	cec080e7          	jalr	-788(ra) # 80003ed8 <install_trans>
    log.lh.n = 0;
    800041f4:	0001d797          	auipc	a5,0x1d
    800041f8:	0a07a423          	sw	zero,168(a5) # 8002129c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800041fc:	00000097          	auipc	ra,0x0
    80004200:	c72080e7          	jalr	-910(ra) # 80003e6e <write_head>
    80004204:	69e2                	ld	s3,24(sp)
    80004206:	6a42                	ld	s4,16(sp)
    80004208:	6aa2                	ld	s5,8(sp)
    8000420a:	bdc5                	j	800040fa <end_op+0x4c>

000000008000420c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000420c:	1101                	add	sp,sp,-32
    8000420e:	ec06                	sd	ra,24(sp)
    80004210:	e822                	sd	s0,16(sp)
    80004212:	e426                	sd	s1,8(sp)
    80004214:	e04a                	sd	s2,0(sp)
    80004216:	1000                	add	s0,sp,32
    80004218:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000421a:	0001d917          	auipc	s2,0x1d
    8000421e:	05690913          	add	s2,s2,86 # 80021270 <log>
    80004222:	854a                	mv	a0,s2
    80004224:	ffffd097          	auipc	ra,0xffffd
    80004228:	a0e080e7          	jalr	-1522(ra) # 80000c32 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000422c:	02c92603          	lw	a2,44(s2)
    80004230:	47f5                	li	a5,29
    80004232:	06c7c563          	blt	a5,a2,8000429c <log_write+0x90>
    80004236:	0001d797          	auipc	a5,0x1d
    8000423a:	0567a783          	lw	a5,86(a5) # 8002128c <log+0x1c>
    8000423e:	37fd                	addw	a5,a5,-1
    80004240:	04f65e63          	bge	a2,a5,8000429c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004244:	0001d797          	auipc	a5,0x1d
    80004248:	04c7a783          	lw	a5,76(a5) # 80021290 <log+0x20>
    8000424c:	06f05063          	blez	a5,800042ac <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004250:	4781                	li	a5,0
    80004252:	06c05563          	blez	a2,800042bc <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004256:	44cc                	lw	a1,12(s1)
    80004258:	0001d717          	auipc	a4,0x1d
    8000425c:	04870713          	add	a4,a4,72 # 800212a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004260:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004262:	4314                	lw	a3,0(a4)
    80004264:	04b68c63          	beq	a3,a1,800042bc <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004268:	2785                	addw	a5,a5,1
    8000426a:	0711                	add	a4,a4,4
    8000426c:	fef61be3          	bne	a2,a5,80004262 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004270:	0621                	add	a2,a2,8
    80004272:	060a                	sll	a2,a2,0x2
    80004274:	0001d797          	auipc	a5,0x1d
    80004278:	ffc78793          	add	a5,a5,-4 # 80021270 <log>
    8000427c:	97b2                	add	a5,a5,a2
    8000427e:	44d8                	lw	a4,12(s1)
    80004280:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004282:	8526                	mv	a0,s1
    80004284:	fffff097          	auipc	ra,0xfffff
    80004288:	db0080e7          	jalr	-592(ra) # 80003034 <bpin>
    log.lh.n++;
    8000428c:	0001d717          	auipc	a4,0x1d
    80004290:	fe470713          	add	a4,a4,-28 # 80021270 <log>
    80004294:	575c                	lw	a5,44(a4)
    80004296:	2785                	addw	a5,a5,1
    80004298:	d75c                	sw	a5,44(a4)
    8000429a:	a82d                	j	800042d4 <log_write+0xc8>
    panic("too big a transaction");
    8000429c:	00004517          	auipc	a0,0x4
    800042a0:	28450513          	add	a0,a0,644 # 80008520 <etext+0x520>
    800042a4:	ffffc097          	auipc	ra,0xffffc
    800042a8:	2b6080e7          	jalr	694(ra) # 8000055a <panic>
    panic("log_write outside of trans");
    800042ac:	00004517          	auipc	a0,0x4
    800042b0:	28c50513          	add	a0,a0,652 # 80008538 <etext+0x538>
    800042b4:	ffffc097          	auipc	ra,0xffffc
    800042b8:	2a6080e7          	jalr	678(ra) # 8000055a <panic>
  log.lh.block[i] = b->blockno;
    800042bc:	00878693          	add	a3,a5,8
    800042c0:	068a                	sll	a3,a3,0x2
    800042c2:	0001d717          	auipc	a4,0x1d
    800042c6:	fae70713          	add	a4,a4,-82 # 80021270 <log>
    800042ca:	9736                	add	a4,a4,a3
    800042cc:	44d4                	lw	a3,12(s1)
    800042ce:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800042d0:	faf609e3          	beq	a2,a5,80004282 <log_write+0x76>
  }
  release(&log.lock);
    800042d4:	0001d517          	auipc	a0,0x1d
    800042d8:	f9c50513          	add	a0,a0,-100 # 80021270 <log>
    800042dc:	ffffd097          	auipc	ra,0xffffd
    800042e0:	a0a080e7          	jalr	-1526(ra) # 80000ce6 <release>
}
    800042e4:	60e2                	ld	ra,24(sp)
    800042e6:	6442                	ld	s0,16(sp)
    800042e8:	64a2                	ld	s1,8(sp)
    800042ea:	6902                	ld	s2,0(sp)
    800042ec:	6105                	add	sp,sp,32
    800042ee:	8082                	ret

00000000800042f0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800042f0:	1101                	add	sp,sp,-32
    800042f2:	ec06                	sd	ra,24(sp)
    800042f4:	e822                	sd	s0,16(sp)
    800042f6:	e426                	sd	s1,8(sp)
    800042f8:	e04a                	sd	s2,0(sp)
    800042fa:	1000                	add	s0,sp,32
    800042fc:	84aa                	mv	s1,a0
    800042fe:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004300:	00004597          	auipc	a1,0x4
    80004304:	25858593          	add	a1,a1,600 # 80008558 <etext+0x558>
    80004308:	0521                	add	a0,a0,8
    8000430a:	ffffd097          	auipc	ra,0xffffd
    8000430e:	898080e7          	jalr	-1896(ra) # 80000ba2 <initlock>
  lk->name = name;
    80004312:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004316:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000431a:	0204a423          	sw	zero,40(s1)
}
    8000431e:	60e2                	ld	ra,24(sp)
    80004320:	6442                	ld	s0,16(sp)
    80004322:	64a2                	ld	s1,8(sp)
    80004324:	6902                	ld	s2,0(sp)
    80004326:	6105                	add	sp,sp,32
    80004328:	8082                	ret

000000008000432a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000432a:	1101                	add	sp,sp,-32
    8000432c:	ec06                	sd	ra,24(sp)
    8000432e:	e822                	sd	s0,16(sp)
    80004330:	e426                	sd	s1,8(sp)
    80004332:	e04a                	sd	s2,0(sp)
    80004334:	1000                	add	s0,sp,32
    80004336:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004338:	00850913          	add	s2,a0,8
    8000433c:	854a                	mv	a0,s2
    8000433e:	ffffd097          	auipc	ra,0xffffd
    80004342:	8f4080e7          	jalr	-1804(ra) # 80000c32 <acquire>
  while (lk->locked) {
    80004346:	409c                	lw	a5,0(s1)
    80004348:	cb89                	beqz	a5,8000435a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000434a:	85ca                	mv	a1,s2
    8000434c:	8526                	mv	a0,s1
    8000434e:	ffffe097          	auipc	ra,0xffffe
    80004352:	da8080e7          	jalr	-600(ra) # 800020f6 <sleep>
  while (lk->locked) {
    80004356:	409c                	lw	a5,0(s1)
    80004358:	fbed                	bnez	a5,8000434a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000435a:	4785                	li	a5,1
    8000435c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000435e:	ffffd097          	auipc	ra,0xffffd
    80004362:	6d2080e7          	jalr	1746(ra) # 80001a30 <myproc>
    80004366:	591c                	lw	a5,48(a0)
    80004368:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000436a:	854a                	mv	a0,s2
    8000436c:	ffffd097          	auipc	ra,0xffffd
    80004370:	97a080e7          	jalr	-1670(ra) # 80000ce6 <release>
}
    80004374:	60e2                	ld	ra,24(sp)
    80004376:	6442                	ld	s0,16(sp)
    80004378:	64a2                	ld	s1,8(sp)
    8000437a:	6902                	ld	s2,0(sp)
    8000437c:	6105                	add	sp,sp,32
    8000437e:	8082                	ret

0000000080004380 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004380:	1101                	add	sp,sp,-32
    80004382:	ec06                	sd	ra,24(sp)
    80004384:	e822                	sd	s0,16(sp)
    80004386:	e426                	sd	s1,8(sp)
    80004388:	e04a                	sd	s2,0(sp)
    8000438a:	1000                	add	s0,sp,32
    8000438c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000438e:	00850913          	add	s2,a0,8
    80004392:	854a                	mv	a0,s2
    80004394:	ffffd097          	auipc	ra,0xffffd
    80004398:	89e080e7          	jalr	-1890(ra) # 80000c32 <acquire>
  lk->locked = 0;
    8000439c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043a0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800043a4:	8526                	mv	a0,s1
    800043a6:	ffffe097          	auipc	ra,0xffffe
    800043aa:	edc080e7          	jalr	-292(ra) # 80002282 <wakeup>
  release(&lk->lk);
    800043ae:	854a                	mv	a0,s2
    800043b0:	ffffd097          	auipc	ra,0xffffd
    800043b4:	936080e7          	jalr	-1738(ra) # 80000ce6 <release>
}
    800043b8:	60e2                	ld	ra,24(sp)
    800043ba:	6442                	ld	s0,16(sp)
    800043bc:	64a2                	ld	s1,8(sp)
    800043be:	6902                	ld	s2,0(sp)
    800043c0:	6105                	add	sp,sp,32
    800043c2:	8082                	ret

00000000800043c4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800043c4:	7179                	add	sp,sp,-48
    800043c6:	f406                	sd	ra,40(sp)
    800043c8:	f022                	sd	s0,32(sp)
    800043ca:	ec26                	sd	s1,24(sp)
    800043cc:	e84a                	sd	s2,16(sp)
    800043ce:	1800                	add	s0,sp,48
    800043d0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800043d2:	00850913          	add	s2,a0,8
    800043d6:	854a                	mv	a0,s2
    800043d8:	ffffd097          	auipc	ra,0xffffd
    800043dc:	85a080e7          	jalr	-1958(ra) # 80000c32 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800043e0:	409c                	lw	a5,0(s1)
    800043e2:	ef91                	bnez	a5,800043fe <holdingsleep+0x3a>
    800043e4:	4481                	li	s1,0
  release(&lk->lk);
    800043e6:	854a                	mv	a0,s2
    800043e8:	ffffd097          	auipc	ra,0xffffd
    800043ec:	8fe080e7          	jalr	-1794(ra) # 80000ce6 <release>
  return r;
}
    800043f0:	8526                	mv	a0,s1
    800043f2:	70a2                	ld	ra,40(sp)
    800043f4:	7402                	ld	s0,32(sp)
    800043f6:	64e2                	ld	s1,24(sp)
    800043f8:	6942                	ld	s2,16(sp)
    800043fa:	6145                	add	sp,sp,48
    800043fc:	8082                	ret
    800043fe:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004400:	0284a983          	lw	s3,40(s1)
    80004404:	ffffd097          	auipc	ra,0xffffd
    80004408:	62c080e7          	jalr	1580(ra) # 80001a30 <myproc>
    8000440c:	5904                	lw	s1,48(a0)
    8000440e:	413484b3          	sub	s1,s1,s3
    80004412:	0014b493          	seqz	s1,s1
    80004416:	69a2                	ld	s3,8(sp)
    80004418:	b7f9                	j	800043e6 <holdingsleep+0x22>

000000008000441a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000441a:	1141                	add	sp,sp,-16
    8000441c:	e406                	sd	ra,8(sp)
    8000441e:	e022                	sd	s0,0(sp)
    80004420:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004422:	00004597          	auipc	a1,0x4
    80004426:	14658593          	add	a1,a1,326 # 80008568 <etext+0x568>
    8000442a:	0001d517          	auipc	a0,0x1d
    8000442e:	f8e50513          	add	a0,a0,-114 # 800213b8 <ftable>
    80004432:	ffffc097          	auipc	ra,0xffffc
    80004436:	770080e7          	jalr	1904(ra) # 80000ba2 <initlock>
}
    8000443a:	60a2                	ld	ra,8(sp)
    8000443c:	6402                	ld	s0,0(sp)
    8000443e:	0141                	add	sp,sp,16
    80004440:	8082                	ret

0000000080004442 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004442:	1101                	add	sp,sp,-32
    80004444:	ec06                	sd	ra,24(sp)
    80004446:	e822                	sd	s0,16(sp)
    80004448:	e426                	sd	s1,8(sp)
    8000444a:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000444c:	0001d517          	auipc	a0,0x1d
    80004450:	f6c50513          	add	a0,a0,-148 # 800213b8 <ftable>
    80004454:	ffffc097          	auipc	ra,0xffffc
    80004458:	7de080e7          	jalr	2014(ra) # 80000c32 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000445c:	0001d497          	auipc	s1,0x1d
    80004460:	f7448493          	add	s1,s1,-140 # 800213d0 <ftable+0x18>
    80004464:	0001e717          	auipc	a4,0x1e
    80004468:	f0c70713          	add	a4,a4,-244 # 80022370 <ftable+0xfb8>
    if(f->ref == 0){
    8000446c:	40dc                	lw	a5,4(s1)
    8000446e:	cf99                	beqz	a5,8000448c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004470:	02848493          	add	s1,s1,40
    80004474:	fee49ce3          	bne	s1,a4,8000446c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004478:	0001d517          	auipc	a0,0x1d
    8000447c:	f4050513          	add	a0,a0,-192 # 800213b8 <ftable>
    80004480:	ffffd097          	auipc	ra,0xffffd
    80004484:	866080e7          	jalr	-1946(ra) # 80000ce6 <release>
  return 0;
    80004488:	4481                	li	s1,0
    8000448a:	a819                	j	800044a0 <filealloc+0x5e>
      f->ref = 1;
    8000448c:	4785                	li	a5,1
    8000448e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004490:	0001d517          	auipc	a0,0x1d
    80004494:	f2850513          	add	a0,a0,-216 # 800213b8 <ftable>
    80004498:	ffffd097          	auipc	ra,0xffffd
    8000449c:	84e080e7          	jalr	-1970(ra) # 80000ce6 <release>
}
    800044a0:	8526                	mv	a0,s1
    800044a2:	60e2                	ld	ra,24(sp)
    800044a4:	6442                	ld	s0,16(sp)
    800044a6:	64a2                	ld	s1,8(sp)
    800044a8:	6105                	add	sp,sp,32
    800044aa:	8082                	ret

00000000800044ac <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800044ac:	1101                	add	sp,sp,-32
    800044ae:	ec06                	sd	ra,24(sp)
    800044b0:	e822                	sd	s0,16(sp)
    800044b2:	e426                	sd	s1,8(sp)
    800044b4:	1000                	add	s0,sp,32
    800044b6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800044b8:	0001d517          	auipc	a0,0x1d
    800044bc:	f0050513          	add	a0,a0,-256 # 800213b8 <ftable>
    800044c0:	ffffc097          	auipc	ra,0xffffc
    800044c4:	772080e7          	jalr	1906(ra) # 80000c32 <acquire>
  if(f->ref < 1)
    800044c8:	40dc                	lw	a5,4(s1)
    800044ca:	02f05263          	blez	a5,800044ee <filedup+0x42>
    panic("filedup");
  f->ref++;
    800044ce:	2785                	addw	a5,a5,1
    800044d0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800044d2:	0001d517          	auipc	a0,0x1d
    800044d6:	ee650513          	add	a0,a0,-282 # 800213b8 <ftable>
    800044da:	ffffd097          	auipc	ra,0xffffd
    800044de:	80c080e7          	jalr	-2036(ra) # 80000ce6 <release>
  return f;
}
    800044e2:	8526                	mv	a0,s1
    800044e4:	60e2                	ld	ra,24(sp)
    800044e6:	6442                	ld	s0,16(sp)
    800044e8:	64a2                	ld	s1,8(sp)
    800044ea:	6105                	add	sp,sp,32
    800044ec:	8082                	ret
    panic("filedup");
    800044ee:	00004517          	auipc	a0,0x4
    800044f2:	08250513          	add	a0,a0,130 # 80008570 <etext+0x570>
    800044f6:	ffffc097          	auipc	ra,0xffffc
    800044fa:	064080e7          	jalr	100(ra) # 8000055a <panic>

00000000800044fe <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800044fe:	7139                	add	sp,sp,-64
    80004500:	fc06                	sd	ra,56(sp)
    80004502:	f822                	sd	s0,48(sp)
    80004504:	f426                	sd	s1,40(sp)
    80004506:	0080                	add	s0,sp,64
    80004508:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000450a:	0001d517          	auipc	a0,0x1d
    8000450e:	eae50513          	add	a0,a0,-338 # 800213b8 <ftable>
    80004512:	ffffc097          	auipc	ra,0xffffc
    80004516:	720080e7          	jalr	1824(ra) # 80000c32 <acquire>
  if(f->ref < 1)
    8000451a:	40dc                	lw	a5,4(s1)
    8000451c:	04f05c63          	blez	a5,80004574 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004520:	37fd                	addw	a5,a5,-1
    80004522:	0007871b          	sext.w	a4,a5
    80004526:	c0dc                	sw	a5,4(s1)
    80004528:	06e04263          	bgtz	a4,8000458c <fileclose+0x8e>
    8000452c:	f04a                	sd	s2,32(sp)
    8000452e:	ec4e                	sd	s3,24(sp)
    80004530:	e852                	sd	s4,16(sp)
    80004532:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004534:	0004a903          	lw	s2,0(s1)
    80004538:	0094ca83          	lbu	s5,9(s1)
    8000453c:	0104ba03          	ld	s4,16(s1)
    80004540:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004544:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004548:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000454c:	0001d517          	auipc	a0,0x1d
    80004550:	e6c50513          	add	a0,a0,-404 # 800213b8 <ftable>
    80004554:	ffffc097          	auipc	ra,0xffffc
    80004558:	792080e7          	jalr	1938(ra) # 80000ce6 <release>

  if(ff.type == FD_PIPE){
    8000455c:	4785                	li	a5,1
    8000455e:	04f90463          	beq	s2,a5,800045a6 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004562:	3979                	addw	s2,s2,-2
    80004564:	4785                	li	a5,1
    80004566:	0527fb63          	bgeu	a5,s2,800045bc <fileclose+0xbe>
    8000456a:	7902                	ld	s2,32(sp)
    8000456c:	69e2                	ld	s3,24(sp)
    8000456e:	6a42                	ld	s4,16(sp)
    80004570:	6aa2                	ld	s5,8(sp)
    80004572:	a02d                	j	8000459c <fileclose+0x9e>
    80004574:	f04a                	sd	s2,32(sp)
    80004576:	ec4e                	sd	s3,24(sp)
    80004578:	e852                	sd	s4,16(sp)
    8000457a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000457c:	00004517          	auipc	a0,0x4
    80004580:	ffc50513          	add	a0,a0,-4 # 80008578 <etext+0x578>
    80004584:	ffffc097          	auipc	ra,0xffffc
    80004588:	fd6080e7          	jalr	-42(ra) # 8000055a <panic>
    release(&ftable.lock);
    8000458c:	0001d517          	auipc	a0,0x1d
    80004590:	e2c50513          	add	a0,a0,-468 # 800213b8 <ftable>
    80004594:	ffffc097          	auipc	ra,0xffffc
    80004598:	752080e7          	jalr	1874(ra) # 80000ce6 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000459c:	70e2                	ld	ra,56(sp)
    8000459e:	7442                	ld	s0,48(sp)
    800045a0:	74a2                	ld	s1,40(sp)
    800045a2:	6121                	add	sp,sp,64
    800045a4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800045a6:	85d6                	mv	a1,s5
    800045a8:	8552                	mv	a0,s4
    800045aa:	00000097          	auipc	ra,0x0
    800045ae:	3a2080e7          	jalr	930(ra) # 8000494c <pipeclose>
    800045b2:	7902                	ld	s2,32(sp)
    800045b4:	69e2                	ld	s3,24(sp)
    800045b6:	6a42                	ld	s4,16(sp)
    800045b8:	6aa2                	ld	s5,8(sp)
    800045ba:	b7cd                	j	8000459c <fileclose+0x9e>
    begin_op();
    800045bc:	00000097          	auipc	ra,0x0
    800045c0:	a78080e7          	jalr	-1416(ra) # 80004034 <begin_op>
    iput(ff.ip);
    800045c4:	854e                	mv	a0,s3
    800045c6:	fffff097          	auipc	ra,0xfffff
    800045ca:	25a080e7          	jalr	602(ra) # 80003820 <iput>
    end_op();
    800045ce:	00000097          	auipc	ra,0x0
    800045d2:	ae0080e7          	jalr	-1312(ra) # 800040ae <end_op>
    800045d6:	7902                	ld	s2,32(sp)
    800045d8:	69e2                	ld	s3,24(sp)
    800045da:	6a42                	ld	s4,16(sp)
    800045dc:	6aa2                	ld	s5,8(sp)
    800045de:	bf7d                	j	8000459c <fileclose+0x9e>

00000000800045e0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800045e0:	715d                	add	sp,sp,-80
    800045e2:	e486                	sd	ra,72(sp)
    800045e4:	e0a2                	sd	s0,64(sp)
    800045e6:	fc26                	sd	s1,56(sp)
    800045e8:	f44e                	sd	s3,40(sp)
    800045ea:	0880                	add	s0,sp,80
    800045ec:	84aa                	mv	s1,a0
    800045ee:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800045f0:	ffffd097          	auipc	ra,0xffffd
    800045f4:	440080e7          	jalr	1088(ra) # 80001a30 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800045f8:	409c                	lw	a5,0(s1)
    800045fa:	37f9                	addw	a5,a5,-2
    800045fc:	4705                	li	a4,1
    800045fe:	04f76863          	bltu	a4,a5,8000464e <filestat+0x6e>
    80004602:	f84a                	sd	s2,48(sp)
    80004604:	892a                	mv	s2,a0
    ilock(f->ip);
    80004606:	6c88                	ld	a0,24(s1)
    80004608:	fffff097          	auipc	ra,0xfffff
    8000460c:	05a080e7          	jalr	90(ra) # 80003662 <ilock>
    stati(f->ip, &st);
    80004610:	fb840593          	add	a1,s0,-72
    80004614:	6c88                	ld	a0,24(s1)
    80004616:	fffff097          	auipc	ra,0xfffff
    8000461a:	2da080e7          	jalr	730(ra) # 800038f0 <stati>
    iunlock(f->ip);
    8000461e:	6c88                	ld	a0,24(s1)
    80004620:	fffff097          	auipc	ra,0xfffff
    80004624:	108080e7          	jalr	264(ra) # 80003728 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004628:	46e1                	li	a3,24
    8000462a:	fb840613          	add	a2,s0,-72
    8000462e:	85ce                	mv	a1,s3
    80004630:	05093503          	ld	a0,80(s2)
    80004634:	ffffd097          	auipc	ra,0xffffd
    80004638:	098080e7          	jalr	152(ra) # 800016cc <copyout>
    8000463c:	41f5551b          	sraw	a0,a0,0x1f
    80004640:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004642:	60a6                	ld	ra,72(sp)
    80004644:	6406                	ld	s0,64(sp)
    80004646:	74e2                	ld	s1,56(sp)
    80004648:	79a2                	ld	s3,40(sp)
    8000464a:	6161                	add	sp,sp,80
    8000464c:	8082                	ret
  return -1;
    8000464e:	557d                	li	a0,-1
    80004650:	bfcd                	j	80004642 <filestat+0x62>

0000000080004652 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004652:	7179                	add	sp,sp,-48
    80004654:	f406                	sd	ra,40(sp)
    80004656:	f022                	sd	s0,32(sp)
    80004658:	e84a                	sd	s2,16(sp)
    8000465a:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000465c:	00854783          	lbu	a5,8(a0)
    80004660:	cbc5                	beqz	a5,80004710 <fileread+0xbe>
    80004662:	ec26                	sd	s1,24(sp)
    80004664:	e44e                	sd	s3,8(sp)
    80004666:	84aa                	mv	s1,a0
    80004668:	89ae                	mv	s3,a1
    8000466a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000466c:	411c                	lw	a5,0(a0)
    8000466e:	4705                	li	a4,1
    80004670:	04e78963          	beq	a5,a4,800046c2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004674:	470d                	li	a4,3
    80004676:	04e78f63          	beq	a5,a4,800046d4 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000467a:	4709                	li	a4,2
    8000467c:	08e79263          	bne	a5,a4,80004700 <fileread+0xae>
    ilock(f->ip);
    80004680:	6d08                	ld	a0,24(a0)
    80004682:	fffff097          	auipc	ra,0xfffff
    80004686:	fe0080e7          	jalr	-32(ra) # 80003662 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000468a:	874a                	mv	a4,s2
    8000468c:	5094                	lw	a3,32(s1)
    8000468e:	864e                	mv	a2,s3
    80004690:	4585                	li	a1,1
    80004692:	6c88                	ld	a0,24(s1)
    80004694:	fffff097          	auipc	ra,0xfffff
    80004698:	286080e7          	jalr	646(ra) # 8000391a <readi>
    8000469c:	892a                	mv	s2,a0
    8000469e:	00a05563          	blez	a0,800046a8 <fileread+0x56>
      f->off += r;
    800046a2:	509c                	lw	a5,32(s1)
    800046a4:	9fa9                	addw	a5,a5,a0
    800046a6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046a8:	6c88                	ld	a0,24(s1)
    800046aa:	fffff097          	auipc	ra,0xfffff
    800046ae:	07e080e7          	jalr	126(ra) # 80003728 <iunlock>
    800046b2:	64e2                	ld	s1,24(sp)
    800046b4:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800046b6:	854a                	mv	a0,s2
    800046b8:	70a2                	ld	ra,40(sp)
    800046ba:	7402                	ld	s0,32(sp)
    800046bc:	6942                	ld	s2,16(sp)
    800046be:	6145                	add	sp,sp,48
    800046c0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800046c2:	6908                	ld	a0,16(a0)
    800046c4:	00000097          	auipc	ra,0x0
    800046c8:	3fa080e7          	jalr	1018(ra) # 80004abe <piperead>
    800046cc:	892a                	mv	s2,a0
    800046ce:	64e2                	ld	s1,24(sp)
    800046d0:	69a2                	ld	s3,8(sp)
    800046d2:	b7d5                	j	800046b6 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800046d4:	02451783          	lh	a5,36(a0)
    800046d8:	03079693          	sll	a3,a5,0x30
    800046dc:	92c1                	srl	a3,a3,0x30
    800046de:	4725                	li	a4,9
    800046e0:	02d76a63          	bltu	a4,a3,80004714 <fileread+0xc2>
    800046e4:	0792                	sll	a5,a5,0x4
    800046e6:	0001d717          	auipc	a4,0x1d
    800046ea:	c3270713          	add	a4,a4,-974 # 80021318 <devsw>
    800046ee:	97ba                	add	a5,a5,a4
    800046f0:	639c                	ld	a5,0(a5)
    800046f2:	c78d                	beqz	a5,8000471c <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    800046f4:	4505                	li	a0,1
    800046f6:	9782                	jalr	a5
    800046f8:	892a                	mv	s2,a0
    800046fa:	64e2                	ld	s1,24(sp)
    800046fc:	69a2                	ld	s3,8(sp)
    800046fe:	bf65                	j	800046b6 <fileread+0x64>
    panic("fileread");
    80004700:	00004517          	auipc	a0,0x4
    80004704:	e8850513          	add	a0,a0,-376 # 80008588 <etext+0x588>
    80004708:	ffffc097          	auipc	ra,0xffffc
    8000470c:	e52080e7          	jalr	-430(ra) # 8000055a <panic>
    return -1;
    80004710:	597d                	li	s2,-1
    80004712:	b755                	j	800046b6 <fileread+0x64>
      return -1;
    80004714:	597d                	li	s2,-1
    80004716:	64e2                	ld	s1,24(sp)
    80004718:	69a2                	ld	s3,8(sp)
    8000471a:	bf71                	j	800046b6 <fileread+0x64>
    8000471c:	597d                	li	s2,-1
    8000471e:	64e2                	ld	s1,24(sp)
    80004720:	69a2                	ld	s3,8(sp)
    80004722:	bf51                	j	800046b6 <fileread+0x64>

0000000080004724 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004724:	00954783          	lbu	a5,9(a0)
    80004728:	12078963          	beqz	a5,8000485a <filewrite+0x136>
{
    8000472c:	715d                	add	sp,sp,-80
    8000472e:	e486                	sd	ra,72(sp)
    80004730:	e0a2                	sd	s0,64(sp)
    80004732:	f84a                	sd	s2,48(sp)
    80004734:	f052                	sd	s4,32(sp)
    80004736:	e85a                	sd	s6,16(sp)
    80004738:	0880                	add	s0,sp,80
    8000473a:	892a                	mv	s2,a0
    8000473c:	8b2e                	mv	s6,a1
    8000473e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004740:	411c                	lw	a5,0(a0)
    80004742:	4705                	li	a4,1
    80004744:	02e78763          	beq	a5,a4,80004772 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004748:	470d                	li	a4,3
    8000474a:	02e78a63          	beq	a5,a4,8000477e <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000474e:	4709                	li	a4,2
    80004750:	0ee79863          	bne	a5,a4,80004840 <filewrite+0x11c>
    80004754:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004756:	0cc05463          	blez	a2,8000481e <filewrite+0xfa>
    8000475a:	fc26                	sd	s1,56(sp)
    8000475c:	ec56                	sd	s5,24(sp)
    8000475e:	e45e                	sd	s7,8(sp)
    80004760:	e062                	sd	s8,0(sp)
    int i = 0;
    80004762:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004764:	6b85                	lui	s7,0x1
    80004766:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000476a:	6c05                	lui	s8,0x1
    8000476c:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004770:	a851                	j	80004804 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004772:	6908                	ld	a0,16(a0)
    80004774:	00000097          	auipc	ra,0x0
    80004778:	248080e7          	jalr	584(ra) # 800049bc <pipewrite>
    8000477c:	a85d                	j	80004832 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000477e:	02451783          	lh	a5,36(a0)
    80004782:	03079693          	sll	a3,a5,0x30
    80004786:	92c1                	srl	a3,a3,0x30
    80004788:	4725                	li	a4,9
    8000478a:	0cd76a63          	bltu	a4,a3,8000485e <filewrite+0x13a>
    8000478e:	0792                	sll	a5,a5,0x4
    80004790:	0001d717          	auipc	a4,0x1d
    80004794:	b8870713          	add	a4,a4,-1144 # 80021318 <devsw>
    80004798:	97ba                	add	a5,a5,a4
    8000479a:	679c                	ld	a5,8(a5)
    8000479c:	c3f9                	beqz	a5,80004862 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    8000479e:	4505                	li	a0,1
    800047a0:	9782                	jalr	a5
    800047a2:	a841                	j	80004832 <filewrite+0x10e>
      if(n1 > max)
    800047a4:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800047a8:	00000097          	auipc	ra,0x0
    800047ac:	88c080e7          	jalr	-1908(ra) # 80004034 <begin_op>
      ilock(f->ip);
    800047b0:	01893503          	ld	a0,24(s2)
    800047b4:	fffff097          	auipc	ra,0xfffff
    800047b8:	eae080e7          	jalr	-338(ra) # 80003662 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047bc:	8756                	mv	a4,s5
    800047be:	02092683          	lw	a3,32(s2)
    800047c2:	01698633          	add	a2,s3,s6
    800047c6:	4585                	li	a1,1
    800047c8:	01893503          	ld	a0,24(s2)
    800047cc:	fffff097          	auipc	ra,0xfffff
    800047d0:	252080e7          	jalr	594(ra) # 80003a1e <writei>
    800047d4:	84aa                	mv	s1,a0
    800047d6:	00a05763          	blez	a0,800047e4 <filewrite+0xc0>
        f->off += r;
    800047da:	02092783          	lw	a5,32(s2)
    800047de:	9fa9                	addw	a5,a5,a0
    800047e0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800047e4:	01893503          	ld	a0,24(s2)
    800047e8:	fffff097          	auipc	ra,0xfffff
    800047ec:	f40080e7          	jalr	-192(ra) # 80003728 <iunlock>
      end_op();
    800047f0:	00000097          	auipc	ra,0x0
    800047f4:	8be080e7          	jalr	-1858(ra) # 800040ae <end_op>

      if(r != n1){
    800047f8:	029a9563          	bne	s5,s1,80004822 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    800047fc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004800:	0149da63          	bge	s3,s4,80004814 <filewrite+0xf0>
      int n1 = n - i;
    80004804:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004808:	0004879b          	sext.w	a5,s1
    8000480c:	f8fbdce3          	bge	s7,a5,800047a4 <filewrite+0x80>
    80004810:	84e2                	mv	s1,s8
    80004812:	bf49                	j	800047a4 <filewrite+0x80>
    80004814:	74e2                	ld	s1,56(sp)
    80004816:	6ae2                	ld	s5,24(sp)
    80004818:	6ba2                	ld	s7,8(sp)
    8000481a:	6c02                	ld	s8,0(sp)
    8000481c:	a039                	j	8000482a <filewrite+0x106>
    int i = 0;
    8000481e:	4981                	li	s3,0
    80004820:	a029                	j	8000482a <filewrite+0x106>
    80004822:	74e2                	ld	s1,56(sp)
    80004824:	6ae2                	ld	s5,24(sp)
    80004826:	6ba2                	ld	s7,8(sp)
    80004828:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    8000482a:	033a1e63          	bne	s4,s3,80004866 <filewrite+0x142>
    8000482e:	8552                	mv	a0,s4
    80004830:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004832:	60a6                	ld	ra,72(sp)
    80004834:	6406                	ld	s0,64(sp)
    80004836:	7942                	ld	s2,48(sp)
    80004838:	7a02                	ld	s4,32(sp)
    8000483a:	6b42                	ld	s6,16(sp)
    8000483c:	6161                	add	sp,sp,80
    8000483e:	8082                	ret
    80004840:	fc26                	sd	s1,56(sp)
    80004842:	f44e                	sd	s3,40(sp)
    80004844:	ec56                	sd	s5,24(sp)
    80004846:	e45e                	sd	s7,8(sp)
    80004848:	e062                	sd	s8,0(sp)
    panic("filewrite");
    8000484a:	00004517          	auipc	a0,0x4
    8000484e:	d4e50513          	add	a0,a0,-690 # 80008598 <etext+0x598>
    80004852:	ffffc097          	auipc	ra,0xffffc
    80004856:	d08080e7          	jalr	-760(ra) # 8000055a <panic>
    return -1;
    8000485a:	557d                	li	a0,-1
}
    8000485c:	8082                	ret
      return -1;
    8000485e:	557d                	li	a0,-1
    80004860:	bfc9                	j	80004832 <filewrite+0x10e>
    80004862:	557d                	li	a0,-1
    80004864:	b7f9                	j	80004832 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004866:	557d                	li	a0,-1
    80004868:	79a2                	ld	s3,40(sp)
    8000486a:	b7e1                	j	80004832 <filewrite+0x10e>

000000008000486c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000486c:	7179                	add	sp,sp,-48
    8000486e:	f406                	sd	ra,40(sp)
    80004870:	f022                	sd	s0,32(sp)
    80004872:	ec26                	sd	s1,24(sp)
    80004874:	e052                	sd	s4,0(sp)
    80004876:	1800                	add	s0,sp,48
    80004878:	84aa                	mv	s1,a0
    8000487a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000487c:	0005b023          	sd	zero,0(a1)
    80004880:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004884:	00000097          	auipc	ra,0x0
    80004888:	bbe080e7          	jalr	-1090(ra) # 80004442 <filealloc>
    8000488c:	e088                	sd	a0,0(s1)
    8000488e:	cd49                	beqz	a0,80004928 <pipealloc+0xbc>
    80004890:	00000097          	auipc	ra,0x0
    80004894:	bb2080e7          	jalr	-1102(ra) # 80004442 <filealloc>
    80004898:	00aa3023          	sd	a0,0(s4)
    8000489c:	c141                	beqz	a0,8000491c <pipealloc+0xb0>
    8000489e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048a0:	ffffc097          	auipc	ra,0xffffc
    800048a4:	2a2080e7          	jalr	674(ra) # 80000b42 <kalloc>
    800048a8:	892a                	mv	s2,a0
    800048aa:	c13d                	beqz	a0,80004910 <pipealloc+0xa4>
    800048ac:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800048ae:	4985                	li	s3,1
    800048b0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048b4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048b8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048bc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800048c0:	00004597          	auipc	a1,0x4
    800048c4:	ce858593          	add	a1,a1,-792 # 800085a8 <etext+0x5a8>
    800048c8:	ffffc097          	auipc	ra,0xffffc
    800048cc:	2da080e7          	jalr	730(ra) # 80000ba2 <initlock>
  (*f0)->type = FD_PIPE;
    800048d0:	609c                	ld	a5,0(s1)
    800048d2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048d6:	609c                	ld	a5,0(s1)
    800048d8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048dc:	609c                	ld	a5,0(s1)
    800048de:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800048e2:	609c                	ld	a5,0(s1)
    800048e4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800048e8:	000a3783          	ld	a5,0(s4)
    800048ec:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800048f0:	000a3783          	ld	a5,0(s4)
    800048f4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800048f8:	000a3783          	ld	a5,0(s4)
    800048fc:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004900:	000a3783          	ld	a5,0(s4)
    80004904:	0127b823          	sd	s2,16(a5)
  return 0;
    80004908:	4501                	li	a0,0
    8000490a:	6942                	ld	s2,16(sp)
    8000490c:	69a2                	ld	s3,8(sp)
    8000490e:	a03d                	j	8000493c <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004910:	6088                	ld	a0,0(s1)
    80004912:	c119                	beqz	a0,80004918 <pipealloc+0xac>
    80004914:	6942                	ld	s2,16(sp)
    80004916:	a029                	j	80004920 <pipealloc+0xb4>
    80004918:	6942                	ld	s2,16(sp)
    8000491a:	a039                	j	80004928 <pipealloc+0xbc>
    8000491c:	6088                	ld	a0,0(s1)
    8000491e:	c50d                	beqz	a0,80004948 <pipealloc+0xdc>
    fileclose(*f0);
    80004920:	00000097          	auipc	ra,0x0
    80004924:	bde080e7          	jalr	-1058(ra) # 800044fe <fileclose>
  if(*f1)
    80004928:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000492c:	557d                	li	a0,-1
  if(*f1)
    8000492e:	c799                	beqz	a5,8000493c <pipealloc+0xd0>
    fileclose(*f1);
    80004930:	853e                	mv	a0,a5
    80004932:	00000097          	auipc	ra,0x0
    80004936:	bcc080e7          	jalr	-1076(ra) # 800044fe <fileclose>
  return -1;
    8000493a:	557d                	li	a0,-1
}
    8000493c:	70a2                	ld	ra,40(sp)
    8000493e:	7402                	ld	s0,32(sp)
    80004940:	64e2                	ld	s1,24(sp)
    80004942:	6a02                	ld	s4,0(sp)
    80004944:	6145                	add	sp,sp,48
    80004946:	8082                	ret
  return -1;
    80004948:	557d                	li	a0,-1
    8000494a:	bfcd                	j	8000493c <pipealloc+0xd0>

000000008000494c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000494c:	1101                	add	sp,sp,-32
    8000494e:	ec06                	sd	ra,24(sp)
    80004950:	e822                	sd	s0,16(sp)
    80004952:	e426                	sd	s1,8(sp)
    80004954:	e04a                	sd	s2,0(sp)
    80004956:	1000                	add	s0,sp,32
    80004958:	84aa                	mv	s1,a0
    8000495a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000495c:	ffffc097          	auipc	ra,0xffffc
    80004960:	2d6080e7          	jalr	726(ra) # 80000c32 <acquire>
  if(writable){
    80004964:	02090d63          	beqz	s2,8000499e <pipeclose+0x52>
    pi->writeopen = 0;
    80004968:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000496c:	21848513          	add	a0,s1,536
    80004970:	ffffe097          	auipc	ra,0xffffe
    80004974:	912080e7          	jalr	-1774(ra) # 80002282 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004978:	2204b783          	ld	a5,544(s1)
    8000497c:	eb95                	bnez	a5,800049b0 <pipeclose+0x64>
    release(&pi->lock);
    8000497e:	8526                	mv	a0,s1
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	366080e7          	jalr	870(ra) # 80000ce6 <release>
    kfree((char*)pi);
    80004988:	8526                	mv	a0,s1
    8000498a:	ffffc097          	auipc	ra,0xffffc
    8000498e:	0ba080e7          	jalr	186(ra) # 80000a44 <kfree>
  } else
    release(&pi->lock);
}
    80004992:	60e2                	ld	ra,24(sp)
    80004994:	6442                	ld	s0,16(sp)
    80004996:	64a2                	ld	s1,8(sp)
    80004998:	6902                	ld	s2,0(sp)
    8000499a:	6105                	add	sp,sp,32
    8000499c:	8082                	ret
    pi->readopen = 0;
    8000499e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049a2:	21c48513          	add	a0,s1,540
    800049a6:	ffffe097          	auipc	ra,0xffffe
    800049aa:	8dc080e7          	jalr	-1828(ra) # 80002282 <wakeup>
    800049ae:	b7e9                	j	80004978 <pipeclose+0x2c>
    release(&pi->lock);
    800049b0:	8526                	mv	a0,s1
    800049b2:	ffffc097          	auipc	ra,0xffffc
    800049b6:	334080e7          	jalr	820(ra) # 80000ce6 <release>
}
    800049ba:	bfe1                	j	80004992 <pipeclose+0x46>

00000000800049bc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049bc:	711d                	add	sp,sp,-96
    800049be:	ec86                	sd	ra,88(sp)
    800049c0:	e8a2                	sd	s0,80(sp)
    800049c2:	e4a6                	sd	s1,72(sp)
    800049c4:	e0ca                	sd	s2,64(sp)
    800049c6:	fc4e                	sd	s3,56(sp)
    800049c8:	f852                	sd	s4,48(sp)
    800049ca:	f456                	sd	s5,40(sp)
    800049cc:	1080                	add	s0,sp,96
    800049ce:	84aa                	mv	s1,a0
    800049d0:	8aae                	mv	s5,a1
    800049d2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800049d4:	ffffd097          	auipc	ra,0xffffd
    800049d8:	05c080e7          	jalr	92(ra) # 80001a30 <myproc>
    800049dc:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800049de:	8526                	mv	a0,s1
    800049e0:	ffffc097          	auipc	ra,0xffffc
    800049e4:	252080e7          	jalr	594(ra) # 80000c32 <acquire>
  while(i < n){
    800049e8:	0d405563          	blez	s4,80004ab2 <pipewrite+0xf6>
    800049ec:	f05a                	sd	s6,32(sp)
    800049ee:	ec5e                	sd	s7,24(sp)
    800049f0:	e862                	sd	s8,16(sp)
  int i = 0;
    800049f2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049f4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800049f6:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800049fa:	21c48b93          	add	s7,s1,540
    800049fe:	a089                	j	80004a40 <pipewrite+0x84>
      release(&pi->lock);
    80004a00:	8526                	mv	a0,s1
    80004a02:	ffffc097          	auipc	ra,0xffffc
    80004a06:	2e4080e7          	jalr	740(ra) # 80000ce6 <release>
      return -1;
    80004a0a:	597d                	li	s2,-1
    80004a0c:	7b02                	ld	s6,32(sp)
    80004a0e:	6be2                	ld	s7,24(sp)
    80004a10:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a12:	854a                	mv	a0,s2
    80004a14:	60e6                	ld	ra,88(sp)
    80004a16:	6446                	ld	s0,80(sp)
    80004a18:	64a6                	ld	s1,72(sp)
    80004a1a:	6906                	ld	s2,64(sp)
    80004a1c:	79e2                	ld	s3,56(sp)
    80004a1e:	7a42                	ld	s4,48(sp)
    80004a20:	7aa2                	ld	s5,40(sp)
    80004a22:	6125                	add	sp,sp,96
    80004a24:	8082                	ret
      wakeup(&pi->nread);
    80004a26:	8562                	mv	a0,s8
    80004a28:	ffffe097          	auipc	ra,0xffffe
    80004a2c:	85a080e7          	jalr	-1958(ra) # 80002282 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a30:	85a6                	mv	a1,s1
    80004a32:	855e                	mv	a0,s7
    80004a34:	ffffd097          	auipc	ra,0xffffd
    80004a38:	6c2080e7          	jalr	1730(ra) # 800020f6 <sleep>
  while(i < n){
    80004a3c:	05495c63          	bge	s2,s4,80004a94 <pipewrite+0xd8>
    if(pi->readopen == 0 || pr->killed){
    80004a40:	2204a783          	lw	a5,544(s1)
    80004a44:	dfd5                	beqz	a5,80004a00 <pipewrite+0x44>
    80004a46:	0289a783          	lw	a5,40(s3)
    80004a4a:	fbdd                	bnez	a5,80004a00 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a4c:	2184a783          	lw	a5,536(s1)
    80004a50:	21c4a703          	lw	a4,540(s1)
    80004a54:	2007879b          	addw	a5,a5,512
    80004a58:	fcf707e3          	beq	a4,a5,80004a26 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a5c:	4685                	li	a3,1
    80004a5e:	01590633          	add	a2,s2,s5
    80004a62:	faf40593          	add	a1,s0,-81
    80004a66:	0509b503          	ld	a0,80(s3)
    80004a6a:	ffffd097          	auipc	ra,0xffffd
    80004a6e:	cee080e7          	jalr	-786(ra) # 80001758 <copyin>
    80004a72:	05650263          	beq	a0,s6,80004ab6 <pipewrite+0xfa>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a76:	21c4a783          	lw	a5,540(s1)
    80004a7a:	0017871b          	addw	a4,a5,1
    80004a7e:	20e4ae23          	sw	a4,540(s1)
    80004a82:	1ff7f793          	and	a5,a5,511
    80004a86:	97a6                	add	a5,a5,s1
    80004a88:	faf44703          	lbu	a4,-81(s0)
    80004a8c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004a90:	2905                	addw	s2,s2,1
    80004a92:	b76d                	j	80004a3c <pipewrite+0x80>
    80004a94:	7b02                	ld	s6,32(sp)
    80004a96:	6be2                	ld	s7,24(sp)
    80004a98:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004a9a:	21848513          	add	a0,s1,536
    80004a9e:	ffffd097          	auipc	ra,0xffffd
    80004aa2:	7e4080e7          	jalr	2020(ra) # 80002282 <wakeup>
  release(&pi->lock);
    80004aa6:	8526                	mv	a0,s1
    80004aa8:	ffffc097          	auipc	ra,0xffffc
    80004aac:	23e080e7          	jalr	574(ra) # 80000ce6 <release>
  return i;
    80004ab0:	b78d                	j	80004a12 <pipewrite+0x56>
  int i = 0;
    80004ab2:	4901                	li	s2,0
    80004ab4:	b7dd                	j	80004a9a <pipewrite+0xde>
    80004ab6:	7b02                	ld	s6,32(sp)
    80004ab8:	6be2                	ld	s7,24(sp)
    80004aba:	6c42                	ld	s8,16(sp)
    80004abc:	bff9                	j	80004a9a <pipewrite+0xde>

0000000080004abe <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004abe:	715d                	add	sp,sp,-80
    80004ac0:	e486                	sd	ra,72(sp)
    80004ac2:	e0a2                	sd	s0,64(sp)
    80004ac4:	fc26                	sd	s1,56(sp)
    80004ac6:	f84a                	sd	s2,48(sp)
    80004ac8:	f44e                	sd	s3,40(sp)
    80004aca:	f052                	sd	s4,32(sp)
    80004acc:	ec56                	sd	s5,24(sp)
    80004ace:	0880                	add	s0,sp,80
    80004ad0:	84aa                	mv	s1,a0
    80004ad2:	892e                	mv	s2,a1
    80004ad4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ad6:	ffffd097          	auipc	ra,0xffffd
    80004ada:	f5a080e7          	jalr	-166(ra) # 80001a30 <myproc>
    80004ade:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ae0:	8526                	mv	a0,s1
    80004ae2:	ffffc097          	auipc	ra,0xffffc
    80004ae6:	150080e7          	jalr	336(ra) # 80000c32 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004aea:	2184a703          	lw	a4,536(s1)
    80004aee:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004af2:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004af6:	02f71663          	bne	a4,a5,80004b22 <piperead+0x64>
    80004afa:	2244a783          	lw	a5,548(s1)
    80004afe:	cb9d                	beqz	a5,80004b34 <piperead+0x76>
    if(pr->killed){
    80004b00:	028a2783          	lw	a5,40(s4)
    80004b04:	e38d                	bnez	a5,80004b26 <piperead+0x68>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b06:	85a6                	mv	a1,s1
    80004b08:	854e                	mv	a0,s3
    80004b0a:	ffffd097          	auipc	ra,0xffffd
    80004b0e:	5ec080e7          	jalr	1516(ra) # 800020f6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b12:	2184a703          	lw	a4,536(s1)
    80004b16:	21c4a783          	lw	a5,540(s1)
    80004b1a:	fef700e3          	beq	a4,a5,80004afa <piperead+0x3c>
    80004b1e:	e85a                	sd	s6,16(sp)
    80004b20:	a819                	j	80004b36 <piperead+0x78>
    80004b22:	e85a                	sd	s6,16(sp)
    80004b24:	a809                	j	80004b36 <piperead+0x78>
      release(&pi->lock);
    80004b26:	8526                	mv	a0,s1
    80004b28:	ffffc097          	auipc	ra,0xffffc
    80004b2c:	1be080e7          	jalr	446(ra) # 80000ce6 <release>
      return -1;
    80004b30:	59fd                	li	s3,-1
    80004b32:	a0a5                	j	80004b9a <piperead+0xdc>
    80004b34:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b36:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b38:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b3a:	05505463          	blez	s5,80004b82 <piperead+0xc4>
    if(pi->nread == pi->nwrite)
    80004b3e:	2184a783          	lw	a5,536(s1)
    80004b42:	21c4a703          	lw	a4,540(s1)
    80004b46:	02f70e63          	beq	a4,a5,80004b82 <piperead+0xc4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b4a:	0017871b          	addw	a4,a5,1
    80004b4e:	20e4ac23          	sw	a4,536(s1)
    80004b52:	1ff7f793          	and	a5,a5,511
    80004b56:	97a6                	add	a5,a5,s1
    80004b58:	0187c783          	lbu	a5,24(a5)
    80004b5c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b60:	4685                	li	a3,1
    80004b62:	fbf40613          	add	a2,s0,-65
    80004b66:	85ca                	mv	a1,s2
    80004b68:	050a3503          	ld	a0,80(s4)
    80004b6c:	ffffd097          	auipc	ra,0xffffd
    80004b70:	b60080e7          	jalr	-1184(ra) # 800016cc <copyout>
    80004b74:	01650763          	beq	a0,s6,80004b82 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b78:	2985                	addw	s3,s3,1
    80004b7a:	0905                	add	s2,s2,1
    80004b7c:	fd3a91e3          	bne	s5,s3,80004b3e <piperead+0x80>
    80004b80:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b82:	21c48513          	add	a0,s1,540
    80004b86:	ffffd097          	auipc	ra,0xffffd
    80004b8a:	6fc080e7          	jalr	1788(ra) # 80002282 <wakeup>
  release(&pi->lock);
    80004b8e:	8526                	mv	a0,s1
    80004b90:	ffffc097          	auipc	ra,0xffffc
    80004b94:	156080e7          	jalr	342(ra) # 80000ce6 <release>
    80004b98:	6b42                	ld	s6,16(sp)
  return i;
}
    80004b9a:	854e                	mv	a0,s3
    80004b9c:	60a6                	ld	ra,72(sp)
    80004b9e:	6406                	ld	s0,64(sp)
    80004ba0:	74e2                	ld	s1,56(sp)
    80004ba2:	7942                	ld	s2,48(sp)
    80004ba4:	79a2                	ld	s3,40(sp)
    80004ba6:	7a02                	ld	s4,32(sp)
    80004ba8:	6ae2                	ld	s5,24(sp)
    80004baa:	6161                	add	sp,sp,80
    80004bac:	8082                	ret

0000000080004bae <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004bae:	df010113          	add	sp,sp,-528
    80004bb2:	20113423          	sd	ra,520(sp)
    80004bb6:	20813023          	sd	s0,512(sp)
    80004bba:	ffa6                	sd	s1,504(sp)
    80004bbc:	fbca                	sd	s2,496(sp)
    80004bbe:	0c00                	add	s0,sp,528
    80004bc0:	892a                	mv	s2,a0
    80004bc2:	dea43c23          	sd	a0,-520(s0)
    80004bc6:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004bca:	ffffd097          	auipc	ra,0xffffd
    80004bce:	e66080e7          	jalr	-410(ra) # 80001a30 <myproc>
    80004bd2:	84aa                	mv	s1,a0

  begin_op();
    80004bd4:	fffff097          	auipc	ra,0xfffff
    80004bd8:	460080e7          	jalr	1120(ra) # 80004034 <begin_op>

  if((ip = namei(path)) == 0){
    80004bdc:	854a                	mv	a0,s2
    80004bde:	fffff097          	auipc	ra,0xfffff
    80004be2:	256080e7          	jalr	598(ra) # 80003e34 <namei>
    80004be6:	c135                	beqz	a0,80004c4a <exec+0x9c>
    80004be8:	f3d2                	sd	s4,480(sp)
    80004bea:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004bec:	fffff097          	auipc	ra,0xfffff
    80004bf0:	a76080e7          	jalr	-1418(ra) # 80003662 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004bf4:	04000713          	li	a4,64
    80004bf8:	4681                	li	a3,0
    80004bfa:	e5040613          	add	a2,s0,-432
    80004bfe:	4581                	li	a1,0
    80004c00:	8552                	mv	a0,s4
    80004c02:	fffff097          	auipc	ra,0xfffff
    80004c06:	d18080e7          	jalr	-744(ra) # 8000391a <readi>
    80004c0a:	04000793          	li	a5,64
    80004c0e:	00f51a63          	bne	a0,a5,80004c22 <exec+0x74>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004c12:	e5042703          	lw	a4,-432(s0)
    80004c16:	464c47b7          	lui	a5,0x464c4
    80004c1a:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c1e:	02f70c63          	beq	a4,a5,80004c56 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c22:	8552                	mv	a0,s4
    80004c24:	fffff097          	auipc	ra,0xfffff
    80004c28:	ca4080e7          	jalr	-860(ra) # 800038c8 <iunlockput>
    end_op();
    80004c2c:	fffff097          	auipc	ra,0xfffff
    80004c30:	482080e7          	jalr	1154(ra) # 800040ae <end_op>
  }
  return -1;
    80004c34:	557d                	li	a0,-1
    80004c36:	7a1e                	ld	s4,480(sp)
}
    80004c38:	20813083          	ld	ra,520(sp)
    80004c3c:	20013403          	ld	s0,512(sp)
    80004c40:	74fe                	ld	s1,504(sp)
    80004c42:	795e                	ld	s2,496(sp)
    80004c44:	21010113          	add	sp,sp,528
    80004c48:	8082                	ret
    end_op();
    80004c4a:	fffff097          	auipc	ra,0xfffff
    80004c4e:	464080e7          	jalr	1124(ra) # 800040ae <end_op>
    return -1;
    80004c52:	557d                	li	a0,-1
    80004c54:	b7d5                	j	80004c38 <exec+0x8a>
    80004c56:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004c58:	8526                	mv	a0,s1
    80004c5a:	ffffd097          	auipc	ra,0xffffd
    80004c5e:	e9a080e7          	jalr	-358(ra) # 80001af4 <proc_pagetable>
    80004c62:	8b2a                	mv	s6,a0
    80004c64:	30050563          	beqz	a0,80004f6e <exec+0x3c0>
    80004c68:	f7ce                	sd	s3,488(sp)
    80004c6a:	efd6                	sd	s5,472(sp)
    80004c6c:	e7de                	sd	s7,456(sp)
    80004c6e:	e3e2                	sd	s8,448(sp)
    80004c70:	ff66                	sd	s9,440(sp)
    80004c72:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c74:	e7042d03          	lw	s10,-400(s0)
    80004c78:	e8845783          	lhu	a5,-376(s0)
    80004c7c:	14078563          	beqz	a5,80004dc6 <exec+0x218>
    80004c80:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c82:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c84:	4d81                	li	s11,0
    if((ph.vaddr % PGSIZE) != 0)
    80004c86:	6c85                	lui	s9,0x1
    80004c88:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c8c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004c90:	6a85                	lui	s5,0x1
    80004c92:	a0b5                	j	80004cfe <exec+0x150>
      panic("loadseg: address should exist");
    80004c94:	00004517          	auipc	a0,0x4
    80004c98:	91c50513          	add	a0,a0,-1764 # 800085b0 <etext+0x5b0>
    80004c9c:	ffffc097          	auipc	ra,0xffffc
    80004ca0:	8be080e7          	jalr	-1858(ra) # 8000055a <panic>
    if(sz - i < PGSIZE)
    80004ca4:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004ca6:	8726                	mv	a4,s1
    80004ca8:	012c06bb          	addw	a3,s8,s2
    80004cac:	4581                	li	a1,0
    80004cae:	8552                	mv	a0,s4
    80004cb0:	fffff097          	auipc	ra,0xfffff
    80004cb4:	c6a080e7          	jalr	-918(ra) # 8000391a <readi>
    80004cb8:	2501                	sext.w	a0,a0
    80004cba:	26a49e63          	bne	s1,a0,80004f36 <exec+0x388>
  for(i = 0; i < sz; i += PGSIZE){
    80004cbe:	012a893b          	addw	s2,s5,s2
    80004cc2:	03397563          	bgeu	s2,s3,80004cec <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80004cc6:	02091593          	sll	a1,s2,0x20
    80004cca:	9181                	srl	a1,a1,0x20
    80004ccc:	95de                	add	a1,a1,s7
    80004cce:	855a                	mv	a0,s6
    80004cd0:	ffffc097          	auipc	ra,0xffffc
    80004cd4:	3dc080e7          	jalr	988(ra) # 800010ac <walkaddr>
    80004cd8:	862a                	mv	a2,a0
    if(pa == 0)
    80004cda:	dd4d                	beqz	a0,80004c94 <exec+0xe6>
    if(sz - i < PGSIZE)
    80004cdc:	412984bb          	subw	s1,s3,s2
    80004ce0:	0004879b          	sext.w	a5,s1
    80004ce4:	fcfcf0e3          	bgeu	s9,a5,80004ca4 <exec+0xf6>
    80004ce8:	84d6                	mv	s1,s5
    80004cea:	bf6d                	j	80004ca4 <exec+0xf6>
    sz = sz1;
    80004cec:	e0843483          	ld	s1,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004cf0:	2d85                	addw	s11,s11,1
    80004cf2:	038d0d1b          	addw	s10,s10,56
    80004cf6:	e8845783          	lhu	a5,-376(s0)
    80004cfa:	06fddf63          	bge	s11,a5,80004d78 <exec+0x1ca>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004cfe:	2d01                	sext.w	s10,s10
    80004d00:	03800713          	li	a4,56
    80004d04:	86ea                	mv	a3,s10
    80004d06:	e1840613          	add	a2,s0,-488
    80004d0a:	4581                	li	a1,0
    80004d0c:	8552                	mv	a0,s4
    80004d0e:	fffff097          	auipc	ra,0xfffff
    80004d12:	c0c080e7          	jalr	-1012(ra) # 8000391a <readi>
    80004d16:	03800793          	li	a5,56
    80004d1a:	1ef51863          	bne	a0,a5,80004f0a <exec+0x35c>
    if(ph.type != ELF_PROG_LOAD)
    80004d1e:	e1842783          	lw	a5,-488(s0)
    80004d22:	4705                	li	a4,1
    80004d24:	fce796e3          	bne	a5,a4,80004cf0 <exec+0x142>
    if(ph.memsz < ph.filesz)
    80004d28:	e4043603          	ld	a2,-448(s0)
    80004d2c:	e3843783          	ld	a5,-456(s0)
    80004d30:	1ef66163          	bltu	a2,a5,80004f12 <exec+0x364>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004d34:	e2843783          	ld	a5,-472(s0)
    80004d38:	963e                	add	a2,a2,a5
    80004d3a:	1ef66063          	bltu	a2,a5,80004f1a <exec+0x36c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004d3e:	85a6                	mv	a1,s1
    80004d40:	855a                	mv	a0,s6
    80004d42:	ffffc097          	auipc	ra,0xffffc
    80004d46:	72e080e7          	jalr	1838(ra) # 80001470 <uvmalloc>
    80004d4a:	e0a43423          	sd	a0,-504(s0)
    80004d4e:	1c050a63          	beqz	a0,80004f22 <exec+0x374>
    if((ph.vaddr % PGSIZE) != 0)
    80004d52:	e2843b83          	ld	s7,-472(s0)
    80004d56:	df043783          	ld	a5,-528(s0)
    80004d5a:	00fbf7b3          	and	a5,s7,a5
    80004d5e:	1c079a63          	bnez	a5,80004f32 <exec+0x384>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d62:	e2042c03          	lw	s8,-480(s0)
    80004d66:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004d6a:	00098463          	beqz	s3,80004d72 <exec+0x1c4>
    80004d6e:	4901                	li	s2,0
    80004d70:	bf99                	j	80004cc6 <exec+0x118>
    sz = sz1;
    80004d72:	e0843483          	ld	s1,-504(s0)
    80004d76:	bfad                	j	80004cf0 <exec+0x142>
    80004d78:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004d7a:	8552                	mv	a0,s4
    80004d7c:	fffff097          	auipc	ra,0xfffff
    80004d80:	b4c080e7          	jalr	-1204(ra) # 800038c8 <iunlockput>
  end_op();
    80004d84:	fffff097          	auipc	ra,0xfffff
    80004d88:	32a080e7          	jalr	810(ra) # 800040ae <end_op>
  p = myproc();
    80004d8c:	ffffd097          	auipc	ra,0xffffd
    80004d90:	ca4080e7          	jalr	-860(ra) # 80001a30 <myproc>
    80004d94:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004d96:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004d9a:	6985                	lui	s3,0x1
    80004d9c:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004d9e:	99a6                	add	s3,s3,s1
    80004da0:	77fd                	lui	a5,0xfffff
    80004da2:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004da6:	6609                	lui	a2,0x2
    80004da8:	964e                	add	a2,a2,s3
    80004daa:	85ce                	mv	a1,s3
    80004dac:	855a                	mv	a0,s6
    80004dae:	ffffc097          	auipc	ra,0xffffc
    80004db2:	6c2080e7          	jalr	1730(ra) # 80001470 <uvmalloc>
    80004db6:	892a                	mv	s2,a0
    80004db8:	e0a43423          	sd	a0,-504(s0)
    80004dbc:	e519                	bnez	a0,80004dca <exec+0x21c>
  if(pagetable)
    80004dbe:	e1343423          	sd	s3,-504(s0)
    80004dc2:	4a01                	li	s4,0
    80004dc4:	aa95                	j	80004f38 <exec+0x38a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004dc6:	4481                	li	s1,0
    80004dc8:	bf4d                	j	80004d7a <exec+0x1cc>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004dca:	75f9                	lui	a1,0xffffe
    80004dcc:	95aa                	add	a1,a1,a0
    80004dce:	855a                	mv	a0,s6
    80004dd0:	ffffd097          	auipc	ra,0xffffd
    80004dd4:	8ca080e7          	jalr	-1846(ra) # 8000169a <uvmclear>
  stackbase = sp - PGSIZE;
    80004dd8:	7bfd                	lui	s7,0xfffff
    80004dda:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004ddc:	e0043783          	ld	a5,-512(s0)
    80004de0:	6388                	ld	a0,0(a5)
    80004de2:	c52d                	beqz	a0,80004e4c <exec+0x29e>
    80004de4:	e9040993          	add	s3,s0,-368
    80004de8:	f9040c13          	add	s8,s0,-112
    80004dec:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004dee:	ffffc097          	auipc	ra,0xffffc
    80004df2:	0b4080e7          	jalr	180(ra) # 80000ea2 <strlen>
    80004df6:	0015079b          	addw	a5,a0,1
    80004dfa:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004dfe:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    80004e02:	13796463          	bltu	s2,s7,80004f2a <exec+0x37c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e06:	e0043d03          	ld	s10,-512(s0)
    80004e0a:	000d3a03          	ld	s4,0(s10)
    80004e0e:	8552                	mv	a0,s4
    80004e10:	ffffc097          	auipc	ra,0xffffc
    80004e14:	092080e7          	jalr	146(ra) # 80000ea2 <strlen>
    80004e18:	0015069b          	addw	a3,a0,1
    80004e1c:	8652                	mv	a2,s4
    80004e1e:	85ca                	mv	a1,s2
    80004e20:	855a                	mv	a0,s6
    80004e22:	ffffd097          	auipc	ra,0xffffd
    80004e26:	8aa080e7          	jalr	-1878(ra) # 800016cc <copyout>
    80004e2a:	10054263          	bltz	a0,80004f2e <exec+0x380>
    ustack[argc] = sp;
    80004e2e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e32:	0485                	add	s1,s1,1
    80004e34:	008d0793          	add	a5,s10,8
    80004e38:	e0f43023          	sd	a5,-512(s0)
    80004e3c:	008d3503          	ld	a0,8(s10)
    80004e40:	c909                	beqz	a0,80004e52 <exec+0x2a4>
    if(argc >= MAXARG)
    80004e42:	09a1                	add	s3,s3,8
    80004e44:	fb8995e3          	bne	s3,s8,80004dee <exec+0x240>
  ip = 0;
    80004e48:	4a01                	li	s4,0
    80004e4a:	a0fd                	j	80004f38 <exec+0x38a>
  sp = sz;
    80004e4c:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004e50:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e52:	00349793          	sll	a5,s1,0x3
    80004e56:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd8f90>
    80004e5a:	97a2                	add	a5,a5,s0
    80004e5c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e60:	00148693          	add	a3,s1,1
    80004e64:	068e                	sll	a3,a3,0x3
    80004e66:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e6a:	ff097913          	and	s2,s2,-16
  sz = sz1;
    80004e6e:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004e72:	f57966e3          	bltu	s2,s7,80004dbe <exec+0x210>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e76:	e9040613          	add	a2,s0,-368
    80004e7a:	85ca                	mv	a1,s2
    80004e7c:	855a                	mv	a0,s6
    80004e7e:	ffffd097          	auipc	ra,0xffffd
    80004e82:	84e080e7          	jalr	-1970(ra) # 800016cc <copyout>
    80004e86:	0e054663          	bltz	a0,80004f72 <exec+0x3c4>
  p->trapframe->a1 = sp;
    80004e8a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004e8e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e92:	df843783          	ld	a5,-520(s0)
    80004e96:	0007c703          	lbu	a4,0(a5)
    80004e9a:	cf11                	beqz	a4,80004eb6 <exec+0x308>
    80004e9c:	0785                	add	a5,a5,1
    if(*s == '/')
    80004e9e:	02f00693          	li	a3,47
    80004ea2:	a039                	j	80004eb0 <exec+0x302>
      last = s+1;
    80004ea4:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004ea8:	0785                	add	a5,a5,1
    80004eaa:	fff7c703          	lbu	a4,-1(a5)
    80004eae:	c701                	beqz	a4,80004eb6 <exec+0x308>
    if(*s == '/')
    80004eb0:	fed71ce3          	bne	a4,a3,80004ea8 <exec+0x2fa>
    80004eb4:	bfc5                	j	80004ea4 <exec+0x2f6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004eb6:	4641                	li	a2,16
    80004eb8:	df843583          	ld	a1,-520(s0)
    80004ebc:	158a8513          	add	a0,s5,344
    80004ec0:	ffffc097          	auipc	ra,0xffffc
    80004ec4:	fb0080e7          	jalr	-80(ra) # 80000e70 <safestrcpy>
  oldpagetable = p->pagetable;
    80004ec8:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004ecc:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004ed0:	e0843783          	ld	a5,-504(s0)
    80004ed4:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004ed8:	058ab783          	ld	a5,88(s5)
    80004edc:	e6843703          	ld	a4,-408(s0)
    80004ee0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ee2:	058ab783          	ld	a5,88(s5)
    80004ee6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004eea:	85e6                	mv	a1,s9
    80004eec:	ffffd097          	auipc	ra,0xffffd
    80004ef0:	ca4080e7          	jalr	-860(ra) # 80001b90 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ef4:	0004851b          	sext.w	a0,s1
    80004ef8:	79be                	ld	s3,488(sp)
    80004efa:	7a1e                	ld	s4,480(sp)
    80004efc:	6afe                	ld	s5,472(sp)
    80004efe:	6b5e                	ld	s6,464(sp)
    80004f00:	6bbe                	ld	s7,456(sp)
    80004f02:	6c1e                	ld	s8,448(sp)
    80004f04:	7cfa                	ld	s9,440(sp)
    80004f06:	7d5a                	ld	s10,432(sp)
    80004f08:	bb05                	j	80004c38 <exec+0x8a>
    80004f0a:	e0943423          	sd	s1,-504(s0)
    80004f0e:	7dba                	ld	s11,424(sp)
    80004f10:	a025                	j	80004f38 <exec+0x38a>
    80004f12:	e0943423          	sd	s1,-504(s0)
    80004f16:	7dba                	ld	s11,424(sp)
    80004f18:	a005                	j	80004f38 <exec+0x38a>
    80004f1a:	e0943423          	sd	s1,-504(s0)
    80004f1e:	7dba                	ld	s11,424(sp)
    80004f20:	a821                	j	80004f38 <exec+0x38a>
    80004f22:	e0943423          	sd	s1,-504(s0)
    80004f26:	7dba                	ld	s11,424(sp)
    80004f28:	a801                	j	80004f38 <exec+0x38a>
  ip = 0;
    80004f2a:	4a01                	li	s4,0
    80004f2c:	a031                	j	80004f38 <exec+0x38a>
    80004f2e:	4a01                	li	s4,0
  if(pagetable)
    80004f30:	a021                	j	80004f38 <exec+0x38a>
    80004f32:	7dba                	ld	s11,424(sp)
    80004f34:	a011                	j	80004f38 <exec+0x38a>
    80004f36:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004f38:	e0843583          	ld	a1,-504(s0)
    80004f3c:	855a                	mv	a0,s6
    80004f3e:	ffffd097          	auipc	ra,0xffffd
    80004f42:	c52080e7          	jalr	-942(ra) # 80001b90 <proc_freepagetable>
  return -1;
    80004f46:	557d                	li	a0,-1
  if(ip){
    80004f48:	000a1b63          	bnez	s4,80004f5e <exec+0x3b0>
    80004f4c:	79be                	ld	s3,488(sp)
    80004f4e:	7a1e                	ld	s4,480(sp)
    80004f50:	6afe                	ld	s5,472(sp)
    80004f52:	6b5e                	ld	s6,464(sp)
    80004f54:	6bbe                	ld	s7,456(sp)
    80004f56:	6c1e                	ld	s8,448(sp)
    80004f58:	7cfa                	ld	s9,440(sp)
    80004f5a:	7d5a                	ld	s10,432(sp)
    80004f5c:	b9f1                	j	80004c38 <exec+0x8a>
    80004f5e:	79be                	ld	s3,488(sp)
    80004f60:	6afe                	ld	s5,472(sp)
    80004f62:	6b5e                	ld	s6,464(sp)
    80004f64:	6bbe                	ld	s7,456(sp)
    80004f66:	6c1e                	ld	s8,448(sp)
    80004f68:	7cfa                	ld	s9,440(sp)
    80004f6a:	7d5a                	ld	s10,432(sp)
    80004f6c:	b95d                	j	80004c22 <exec+0x74>
    80004f6e:	6b5e                	ld	s6,464(sp)
    80004f70:	b94d                	j	80004c22 <exec+0x74>
  sz = sz1;
    80004f72:	e0843983          	ld	s3,-504(s0)
    80004f76:	b5a1                	j	80004dbe <exec+0x210>

0000000080004f78 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f78:	7179                	add	sp,sp,-48
    80004f7a:	f406                	sd	ra,40(sp)
    80004f7c:	f022                	sd	s0,32(sp)
    80004f7e:	ec26                	sd	s1,24(sp)
    80004f80:	e84a                	sd	s2,16(sp)
    80004f82:	1800                	add	s0,sp,48
    80004f84:	892e                	mv	s2,a1
    80004f86:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004f88:	fdc40593          	add	a1,s0,-36
    80004f8c:	ffffe097          	auipc	ra,0xffffe
    80004f90:	b64080e7          	jalr	-1180(ra) # 80002af0 <argint>
    80004f94:	04054063          	bltz	a0,80004fd4 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f98:	fdc42703          	lw	a4,-36(s0)
    80004f9c:	47bd                	li	a5,15
    80004f9e:	02e7ed63          	bltu	a5,a4,80004fd8 <argfd+0x60>
    80004fa2:	ffffd097          	auipc	ra,0xffffd
    80004fa6:	a8e080e7          	jalr	-1394(ra) # 80001a30 <myproc>
    80004faa:	fdc42703          	lw	a4,-36(s0)
    80004fae:	01a70793          	add	a5,a4,26
    80004fb2:	078e                	sll	a5,a5,0x3
    80004fb4:	953e                	add	a0,a0,a5
    80004fb6:	611c                	ld	a5,0(a0)
    80004fb8:	c395                	beqz	a5,80004fdc <argfd+0x64>
    return -1;
  if(pfd)
    80004fba:	00090463          	beqz	s2,80004fc2 <argfd+0x4a>
    *pfd = fd;
    80004fbe:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004fc2:	4501                	li	a0,0
  if(pf)
    80004fc4:	c091                	beqz	s1,80004fc8 <argfd+0x50>
    *pf = f;
    80004fc6:	e09c                	sd	a5,0(s1)
}
    80004fc8:	70a2                	ld	ra,40(sp)
    80004fca:	7402                	ld	s0,32(sp)
    80004fcc:	64e2                	ld	s1,24(sp)
    80004fce:	6942                	ld	s2,16(sp)
    80004fd0:	6145                	add	sp,sp,48
    80004fd2:	8082                	ret
    return -1;
    80004fd4:	557d                	li	a0,-1
    80004fd6:	bfcd                	j	80004fc8 <argfd+0x50>
    return -1;
    80004fd8:	557d                	li	a0,-1
    80004fda:	b7fd                	j	80004fc8 <argfd+0x50>
    80004fdc:	557d                	li	a0,-1
    80004fde:	b7ed                	j	80004fc8 <argfd+0x50>

0000000080004fe0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004fe0:	1101                	add	sp,sp,-32
    80004fe2:	ec06                	sd	ra,24(sp)
    80004fe4:	e822                	sd	s0,16(sp)
    80004fe6:	e426                	sd	s1,8(sp)
    80004fe8:	1000                	add	s0,sp,32
    80004fea:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004fec:	ffffd097          	auipc	ra,0xffffd
    80004ff0:	a44080e7          	jalr	-1468(ra) # 80001a30 <myproc>
    80004ff4:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004ff6:	0d050793          	add	a5,a0,208
    80004ffa:	4501                	li	a0,0
    80004ffc:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ffe:	6398                	ld	a4,0(a5)
    80005000:	cb19                	beqz	a4,80005016 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005002:	2505                	addw	a0,a0,1
    80005004:	07a1                	add	a5,a5,8
    80005006:	fed51ce3          	bne	a0,a3,80004ffe <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000500a:	557d                	li	a0,-1
}
    8000500c:	60e2                	ld	ra,24(sp)
    8000500e:	6442                	ld	s0,16(sp)
    80005010:	64a2                	ld	s1,8(sp)
    80005012:	6105                	add	sp,sp,32
    80005014:	8082                	ret
      p->ofile[fd] = f;
    80005016:	01a50793          	add	a5,a0,26
    8000501a:	078e                	sll	a5,a5,0x3
    8000501c:	963e                	add	a2,a2,a5
    8000501e:	e204                	sd	s1,0(a2)
      return fd;
    80005020:	b7f5                	j	8000500c <fdalloc+0x2c>

0000000080005022 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005022:	715d                	add	sp,sp,-80
    80005024:	e486                	sd	ra,72(sp)
    80005026:	e0a2                	sd	s0,64(sp)
    80005028:	fc26                	sd	s1,56(sp)
    8000502a:	f84a                	sd	s2,48(sp)
    8000502c:	f44e                	sd	s3,40(sp)
    8000502e:	f052                	sd	s4,32(sp)
    80005030:	ec56                	sd	s5,24(sp)
    80005032:	0880                	add	s0,sp,80
    80005034:	8aae                	mv	s5,a1
    80005036:	8a32                	mv	s4,a2
    80005038:	89b6                	mv	s3,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000503a:	fb040593          	add	a1,s0,-80
    8000503e:	fffff097          	auipc	ra,0xfffff
    80005042:	e14080e7          	jalr	-492(ra) # 80003e52 <nameiparent>
    80005046:	892a                	mv	s2,a0
    80005048:	12050c63          	beqz	a0,80005180 <create+0x15e>
    return 0;

  ilock(dp);
    8000504c:	ffffe097          	auipc	ra,0xffffe
    80005050:	616080e7          	jalr	1558(ra) # 80003662 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005054:	4601                	li	a2,0
    80005056:	fb040593          	add	a1,s0,-80
    8000505a:	854a                	mv	a0,s2
    8000505c:	fffff097          	auipc	ra,0xfffff
    80005060:	b06080e7          	jalr	-1274(ra) # 80003b62 <dirlookup>
    80005064:	84aa                	mv	s1,a0
    80005066:	c539                	beqz	a0,800050b4 <create+0x92>
    iunlockput(dp);
    80005068:	854a                	mv	a0,s2
    8000506a:	fffff097          	auipc	ra,0xfffff
    8000506e:	85e080e7          	jalr	-1954(ra) # 800038c8 <iunlockput>
    ilock(ip);
    80005072:	8526                	mv	a0,s1
    80005074:	ffffe097          	auipc	ra,0xffffe
    80005078:	5ee080e7          	jalr	1518(ra) # 80003662 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000507c:	4789                	li	a5,2
    8000507e:	02fa9463          	bne	s5,a5,800050a6 <create+0x84>
    80005082:	0444d783          	lhu	a5,68(s1)
    80005086:	37f9                	addw	a5,a5,-2
    80005088:	17c2                	sll	a5,a5,0x30
    8000508a:	93c1                	srl	a5,a5,0x30
    8000508c:	4705                	li	a4,1
    8000508e:	00f76c63          	bltu	a4,a5,800050a6 <create+0x84>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005092:	8526                	mv	a0,s1
    80005094:	60a6                	ld	ra,72(sp)
    80005096:	6406                	ld	s0,64(sp)
    80005098:	74e2                	ld	s1,56(sp)
    8000509a:	7942                	ld	s2,48(sp)
    8000509c:	79a2                	ld	s3,40(sp)
    8000509e:	7a02                	ld	s4,32(sp)
    800050a0:	6ae2                	ld	s5,24(sp)
    800050a2:	6161                	add	sp,sp,80
    800050a4:	8082                	ret
    iunlockput(ip);
    800050a6:	8526                	mv	a0,s1
    800050a8:	fffff097          	auipc	ra,0xfffff
    800050ac:	820080e7          	jalr	-2016(ra) # 800038c8 <iunlockput>
    return 0;
    800050b0:	4481                	li	s1,0
    800050b2:	b7c5                	j	80005092 <create+0x70>
  if((ip = ialloc(dp->dev, type)) == 0)
    800050b4:	85d6                	mv	a1,s5
    800050b6:	00092503          	lw	a0,0(s2)
    800050ba:	ffffe097          	auipc	ra,0xffffe
    800050be:	414080e7          	jalr	1044(ra) # 800034ce <ialloc>
    800050c2:	84aa                	mv	s1,a0
    800050c4:	c139                	beqz	a0,8000510a <create+0xe8>
  ilock(ip);
    800050c6:	ffffe097          	auipc	ra,0xffffe
    800050ca:	59c080e7          	jalr	1436(ra) # 80003662 <ilock>
  ip->major = major;
    800050ce:	05449323          	sh	s4,70(s1)
  ip->minor = minor;
    800050d2:	05349423          	sh	s3,72(s1)
  ip->nlink = 1;
    800050d6:	4985                	li	s3,1
    800050d8:	05349523          	sh	s3,74(s1)
  iupdate(ip);
    800050dc:	8526                	mv	a0,s1
    800050de:	ffffe097          	auipc	ra,0xffffe
    800050e2:	4b8080e7          	jalr	1208(ra) # 80003596 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800050e6:	033a8a63          	beq	s5,s3,8000511a <create+0xf8>
  if(dirlink(dp, name, ip->inum) < 0)
    800050ea:	40d0                	lw	a2,4(s1)
    800050ec:	fb040593          	add	a1,s0,-80
    800050f0:	854a                	mv	a0,s2
    800050f2:	fffff097          	auipc	ra,0xfffff
    800050f6:	c80080e7          	jalr	-896(ra) # 80003d72 <dirlink>
    800050fa:	06054b63          	bltz	a0,80005170 <create+0x14e>
  iunlockput(dp);
    800050fe:	854a                	mv	a0,s2
    80005100:	ffffe097          	auipc	ra,0xffffe
    80005104:	7c8080e7          	jalr	1992(ra) # 800038c8 <iunlockput>
  return ip;
    80005108:	b769                	j	80005092 <create+0x70>
    panic("create: ialloc");
    8000510a:	00003517          	auipc	a0,0x3
    8000510e:	4c650513          	add	a0,a0,1222 # 800085d0 <etext+0x5d0>
    80005112:	ffffb097          	auipc	ra,0xffffb
    80005116:	448080e7          	jalr	1096(ra) # 8000055a <panic>
    dp->nlink++;  // for ".."
    8000511a:	04a95783          	lhu	a5,74(s2)
    8000511e:	2785                	addw	a5,a5,1
    80005120:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005124:	854a                	mv	a0,s2
    80005126:	ffffe097          	auipc	ra,0xffffe
    8000512a:	470080e7          	jalr	1136(ra) # 80003596 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000512e:	40d0                	lw	a2,4(s1)
    80005130:	00003597          	auipc	a1,0x3
    80005134:	4b058593          	add	a1,a1,1200 # 800085e0 <etext+0x5e0>
    80005138:	8526                	mv	a0,s1
    8000513a:	fffff097          	auipc	ra,0xfffff
    8000513e:	c38080e7          	jalr	-968(ra) # 80003d72 <dirlink>
    80005142:	00054f63          	bltz	a0,80005160 <create+0x13e>
    80005146:	00492603          	lw	a2,4(s2)
    8000514a:	00003597          	auipc	a1,0x3
    8000514e:	49e58593          	add	a1,a1,1182 # 800085e8 <etext+0x5e8>
    80005152:	8526                	mv	a0,s1
    80005154:	fffff097          	auipc	ra,0xfffff
    80005158:	c1e080e7          	jalr	-994(ra) # 80003d72 <dirlink>
    8000515c:	f80557e3          	bgez	a0,800050ea <create+0xc8>
      panic("create dots");
    80005160:	00003517          	auipc	a0,0x3
    80005164:	49050513          	add	a0,a0,1168 # 800085f0 <etext+0x5f0>
    80005168:	ffffb097          	auipc	ra,0xffffb
    8000516c:	3f2080e7          	jalr	1010(ra) # 8000055a <panic>
    panic("create: dirlink");
    80005170:	00003517          	auipc	a0,0x3
    80005174:	49050513          	add	a0,a0,1168 # 80008600 <etext+0x600>
    80005178:	ffffb097          	auipc	ra,0xffffb
    8000517c:	3e2080e7          	jalr	994(ra) # 8000055a <panic>
    return 0;
    80005180:	84aa                	mv	s1,a0
    80005182:	bf01                	j	80005092 <create+0x70>

0000000080005184 <sys_dup>:
{
    80005184:	7179                	add	sp,sp,-48
    80005186:	f406                	sd	ra,40(sp)
    80005188:	f022                	sd	s0,32(sp)
    8000518a:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000518c:	fd840613          	add	a2,s0,-40
    80005190:	4581                	li	a1,0
    80005192:	4501                	li	a0,0
    80005194:	00000097          	auipc	ra,0x0
    80005198:	de4080e7          	jalr	-540(ra) # 80004f78 <argfd>
    return -1;
    8000519c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000519e:	02054763          	bltz	a0,800051cc <sys_dup+0x48>
    800051a2:	ec26                	sd	s1,24(sp)
    800051a4:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800051a6:	fd843903          	ld	s2,-40(s0)
    800051aa:	854a                	mv	a0,s2
    800051ac:	00000097          	auipc	ra,0x0
    800051b0:	e34080e7          	jalr	-460(ra) # 80004fe0 <fdalloc>
    800051b4:	84aa                	mv	s1,a0
    return -1;
    800051b6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051b8:	00054f63          	bltz	a0,800051d6 <sys_dup+0x52>
  filedup(f);
    800051bc:	854a                	mv	a0,s2
    800051be:	fffff097          	auipc	ra,0xfffff
    800051c2:	2ee080e7          	jalr	750(ra) # 800044ac <filedup>
  return fd;
    800051c6:	87a6                	mv	a5,s1
    800051c8:	64e2                	ld	s1,24(sp)
    800051ca:	6942                	ld	s2,16(sp)
}
    800051cc:	853e                	mv	a0,a5
    800051ce:	70a2                	ld	ra,40(sp)
    800051d0:	7402                	ld	s0,32(sp)
    800051d2:	6145                	add	sp,sp,48
    800051d4:	8082                	ret
    800051d6:	64e2                	ld	s1,24(sp)
    800051d8:	6942                	ld	s2,16(sp)
    800051da:	bfcd                	j	800051cc <sys_dup+0x48>

00000000800051dc <sys_read>:
{
    800051dc:	7179                	add	sp,sp,-48
    800051de:	f406                	sd	ra,40(sp)
    800051e0:	f022                	sd	s0,32(sp)
    800051e2:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051e4:	fe840613          	add	a2,s0,-24
    800051e8:	4581                	li	a1,0
    800051ea:	4501                	li	a0,0
    800051ec:	00000097          	auipc	ra,0x0
    800051f0:	d8c080e7          	jalr	-628(ra) # 80004f78 <argfd>
    return -1;
    800051f4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800051f6:	04054163          	bltz	a0,80005238 <sys_read+0x5c>
    800051fa:	fe440593          	add	a1,s0,-28
    800051fe:	4509                	li	a0,2
    80005200:	ffffe097          	auipc	ra,0xffffe
    80005204:	8f0080e7          	jalr	-1808(ra) # 80002af0 <argint>
    return -1;
    80005208:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000520a:	02054763          	bltz	a0,80005238 <sys_read+0x5c>
    8000520e:	fd840593          	add	a1,s0,-40
    80005212:	4505                	li	a0,1
    80005214:	ffffe097          	auipc	ra,0xffffe
    80005218:	8fe080e7          	jalr	-1794(ra) # 80002b12 <argaddr>
    return -1;
    8000521c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000521e:	00054d63          	bltz	a0,80005238 <sys_read+0x5c>
  return fileread(f, p, n);
    80005222:	fe442603          	lw	a2,-28(s0)
    80005226:	fd843583          	ld	a1,-40(s0)
    8000522a:	fe843503          	ld	a0,-24(s0)
    8000522e:	fffff097          	auipc	ra,0xfffff
    80005232:	424080e7          	jalr	1060(ra) # 80004652 <fileread>
    80005236:	87aa                	mv	a5,a0
}
    80005238:	853e                	mv	a0,a5
    8000523a:	70a2                	ld	ra,40(sp)
    8000523c:	7402                	ld	s0,32(sp)
    8000523e:	6145                	add	sp,sp,48
    80005240:	8082                	ret

0000000080005242 <sys_write>:
{
    80005242:	7179                	add	sp,sp,-48
    80005244:	f406                	sd	ra,40(sp)
    80005246:	f022                	sd	s0,32(sp)
    80005248:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000524a:	fe840613          	add	a2,s0,-24
    8000524e:	4581                	li	a1,0
    80005250:	4501                	li	a0,0
    80005252:	00000097          	auipc	ra,0x0
    80005256:	d26080e7          	jalr	-730(ra) # 80004f78 <argfd>
    return -1;
    8000525a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000525c:	04054163          	bltz	a0,8000529e <sys_write+0x5c>
    80005260:	fe440593          	add	a1,s0,-28
    80005264:	4509                	li	a0,2
    80005266:	ffffe097          	auipc	ra,0xffffe
    8000526a:	88a080e7          	jalr	-1910(ra) # 80002af0 <argint>
    return -1;
    8000526e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005270:	02054763          	bltz	a0,8000529e <sys_write+0x5c>
    80005274:	fd840593          	add	a1,s0,-40
    80005278:	4505                	li	a0,1
    8000527a:	ffffe097          	auipc	ra,0xffffe
    8000527e:	898080e7          	jalr	-1896(ra) # 80002b12 <argaddr>
    return -1;
    80005282:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005284:	00054d63          	bltz	a0,8000529e <sys_write+0x5c>
  return filewrite(f, p, n);
    80005288:	fe442603          	lw	a2,-28(s0)
    8000528c:	fd843583          	ld	a1,-40(s0)
    80005290:	fe843503          	ld	a0,-24(s0)
    80005294:	fffff097          	auipc	ra,0xfffff
    80005298:	490080e7          	jalr	1168(ra) # 80004724 <filewrite>
    8000529c:	87aa                	mv	a5,a0
}
    8000529e:	853e                	mv	a0,a5
    800052a0:	70a2                	ld	ra,40(sp)
    800052a2:	7402                	ld	s0,32(sp)
    800052a4:	6145                	add	sp,sp,48
    800052a6:	8082                	ret

00000000800052a8 <sys_close>:
{
    800052a8:	1101                	add	sp,sp,-32
    800052aa:	ec06                	sd	ra,24(sp)
    800052ac:	e822                	sd	s0,16(sp)
    800052ae:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052b0:	fe040613          	add	a2,s0,-32
    800052b4:	fec40593          	add	a1,s0,-20
    800052b8:	4501                	li	a0,0
    800052ba:	00000097          	auipc	ra,0x0
    800052be:	cbe080e7          	jalr	-834(ra) # 80004f78 <argfd>
    return -1;
    800052c2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052c4:	02054463          	bltz	a0,800052ec <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800052c8:	ffffc097          	auipc	ra,0xffffc
    800052cc:	768080e7          	jalr	1896(ra) # 80001a30 <myproc>
    800052d0:	fec42783          	lw	a5,-20(s0)
    800052d4:	07e9                	add	a5,a5,26
    800052d6:	078e                	sll	a5,a5,0x3
    800052d8:	953e                	add	a0,a0,a5
    800052da:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800052de:	fe043503          	ld	a0,-32(s0)
    800052e2:	fffff097          	auipc	ra,0xfffff
    800052e6:	21c080e7          	jalr	540(ra) # 800044fe <fileclose>
  return 0;
    800052ea:	4781                	li	a5,0
}
    800052ec:	853e                	mv	a0,a5
    800052ee:	60e2                	ld	ra,24(sp)
    800052f0:	6442                	ld	s0,16(sp)
    800052f2:	6105                	add	sp,sp,32
    800052f4:	8082                	ret

00000000800052f6 <sys_fstat>:
{
    800052f6:	1101                	add	sp,sp,-32
    800052f8:	ec06                	sd	ra,24(sp)
    800052fa:	e822                	sd	s0,16(sp)
    800052fc:	1000                	add	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800052fe:	fe840613          	add	a2,s0,-24
    80005302:	4581                	li	a1,0
    80005304:	4501                	li	a0,0
    80005306:	00000097          	auipc	ra,0x0
    8000530a:	c72080e7          	jalr	-910(ra) # 80004f78 <argfd>
    return -1;
    8000530e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005310:	02054563          	bltz	a0,8000533a <sys_fstat+0x44>
    80005314:	fe040593          	add	a1,s0,-32
    80005318:	4505                	li	a0,1
    8000531a:	ffffd097          	auipc	ra,0xffffd
    8000531e:	7f8080e7          	jalr	2040(ra) # 80002b12 <argaddr>
    return -1;
    80005322:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005324:	00054b63          	bltz	a0,8000533a <sys_fstat+0x44>
  return filestat(f, st);
    80005328:	fe043583          	ld	a1,-32(s0)
    8000532c:	fe843503          	ld	a0,-24(s0)
    80005330:	fffff097          	auipc	ra,0xfffff
    80005334:	2b0080e7          	jalr	688(ra) # 800045e0 <filestat>
    80005338:	87aa                	mv	a5,a0
}
    8000533a:	853e                	mv	a0,a5
    8000533c:	60e2                	ld	ra,24(sp)
    8000533e:	6442                	ld	s0,16(sp)
    80005340:	6105                	add	sp,sp,32
    80005342:	8082                	ret

0000000080005344 <sys_link>:
{
    80005344:	7169                	add	sp,sp,-304
    80005346:	f606                	sd	ra,296(sp)
    80005348:	f222                	sd	s0,288(sp)
    8000534a:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000534c:	08000613          	li	a2,128
    80005350:	ed040593          	add	a1,s0,-304
    80005354:	4501                	li	a0,0
    80005356:	ffffd097          	auipc	ra,0xffffd
    8000535a:	7de080e7          	jalr	2014(ra) # 80002b34 <argstr>
    return -1;
    8000535e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005360:	12054663          	bltz	a0,8000548c <sys_link+0x148>
    80005364:	08000613          	li	a2,128
    80005368:	f5040593          	add	a1,s0,-176
    8000536c:	4505                	li	a0,1
    8000536e:	ffffd097          	auipc	ra,0xffffd
    80005372:	7c6080e7          	jalr	1990(ra) # 80002b34 <argstr>
    return -1;
    80005376:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005378:	10054a63          	bltz	a0,8000548c <sys_link+0x148>
    8000537c:	ee26                	sd	s1,280(sp)
  begin_op();
    8000537e:	fffff097          	auipc	ra,0xfffff
    80005382:	cb6080e7          	jalr	-842(ra) # 80004034 <begin_op>
  if((ip = namei(old)) == 0){
    80005386:	ed040513          	add	a0,s0,-304
    8000538a:	fffff097          	auipc	ra,0xfffff
    8000538e:	aaa080e7          	jalr	-1366(ra) # 80003e34 <namei>
    80005392:	84aa                	mv	s1,a0
    80005394:	c949                	beqz	a0,80005426 <sys_link+0xe2>
  ilock(ip);
    80005396:	ffffe097          	auipc	ra,0xffffe
    8000539a:	2cc080e7          	jalr	716(ra) # 80003662 <ilock>
  if(ip->type == T_DIR){
    8000539e:	04449703          	lh	a4,68(s1)
    800053a2:	4785                	li	a5,1
    800053a4:	08f70863          	beq	a4,a5,80005434 <sys_link+0xf0>
    800053a8:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800053aa:	04a4d783          	lhu	a5,74(s1)
    800053ae:	2785                	addw	a5,a5,1
    800053b0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053b4:	8526                	mv	a0,s1
    800053b6:	ffffe097          	auipc	ra,0xffffe
    800053ba:	1e0080e7          	jalr	480(ra) # 80003596 <iupdate>
  iunlock(ip);
    800053be:	8526                	mv	a0,s1
    800053c0:	ffffe097          	auipc	ra,0xffffe
    800053c4:	368080e7          	jalr	872(ra) # 80003728 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053c8:	fd040593          	add	a1,s0,-48
    800053cc:	f5040513          	add	a0,s0,-176
    800053d0:	fffff097          	auipc	ra,0xfffff
    800053d4:	a82080e7          	jalr	-1406(ra) # 80003e52 <nameiparent>
    800053d8:	892a                	mv	s2,a0
    800053da:	cd35                	beqz	a0,80005456 <sys_link+0x112>
  ilock(dp);
    800053dc:	ffffe097          	auipc	ra,0xffffe
    800053e0:	286080e7          	jalr	646(ra) # 80003662 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800053e4:	00092703          	lw	a4,0(s2)
    800053e8:	409c                	lw	a5,0(s1)
    800053ea:	06f71163          	bne	a4,a5,8000544c <sys_link+0x108>
    800053ee:	40d0                	lw	a2,4(s1)
    800053f0:	fd040593          	add	a1,s0,-48
    800053f4:	854a                	mv	a0,s2
    800053f6:	fffff097          	auipc	ra,0xfffff
    800053fa:	97c080e7          	jalr	-1668(ra) # 80003d72 <dirlink>
    800053fe:	04054763          	bltz	a0,8000544c <sys_link+0x108>
  iunlockput(dp);
    80005402:	854a                	mv	a0,s2
    80005404:	ffffe097          	auipc	ra,0xffffe
    80005408:	4c4080e7          	jalr	1220(ra) # 800038c8 <iunlockput>
  iput(ip);
    8000540c:	8526                	mv	a0,s1
    8000540e:	ffffe097          	auipc	ra,0xffffe
    80005412:	412080e7          	jalr	1042(ra) # 80003820 <iput>
  end_op();
    80005416:	fffff097          	auipc	ra,0xfffff
    8000541a:	c98080e7          	jalr	-872(ra) # 800040ae <end_op>
  return 0;
    8000541e:	4781                	li	a5,0
    80005420:	64f2                	ld	s1,280(sp)
    80005422:	6952                	ld	s2,272(sp)
    80005424:	a0a5                	j	8000548c <sys_link+0x148>
    end_op();
    80005426:	fffff097          	auipc	ra,0xfffff
    8000542a:	c88080e7          	jalr	-888(ra) # 800040ae <end_op>
    return -1;
    8000542e:	57fd                	li	a5,-1
    80005430:	64f2                	ld	s1,280(sp)
    80005432:	a8a9                	j	8000548c <sys_link+0x148>
    iunlockput(ip);
    80005434:	8526                	mv	a0,s1
    80005436:	ffffe097          	auipc	ra,0xffffe
    8000543a:	492080e7          	jalr	1170(ra) # 800038c8 <iunlockput>
    end_op();
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	c70080e7          	jalr	-912(ra) # 800040ae <end_op>
    return -1;
    80005446:	57fd                	li	a5,-1
    80005448:	64f2                	ld	s1,280(sp)
    8000544a:	a089                	j	8000548c <sys_link+0x148>
    iunlockput(dp);
    8000544c:	854a                	mv	a0,s2
    8000544e:	ffffe097          	auipc	ra,0xffffe
    80005452:	47a080e7          	jalr	1146(ra) # 800038c8 <iunlockput>
  ilock(ip);
    80005456:	8526                	mv	a0,s1
    80005458:	ffffe097          	auipc	ra,0xffffe
    8000545c:	20a080e7          	jalr	522(ra) # 80003662 <ilock>
  ip->nlink--;
    80005460:	04a4d783          	lhu	a5,74(s1)
    80005464:	37fd                	addw	a5,a5,-1
    80005466:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000546a:	8526                	mv	a0,s1
    8000546c:	ffffe097          	auipc	ra,0xffffe
    80005470:	12a080e7          	jalr	298(ra) # 80003596 <iupdate>
  iunlockput(ip);
    80005474:	8526                	mv	a0,s1
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	452080e7          	jalr	1106(ra) # 800038c8 <iunlockput>
  end_op();
    8000547e:	fffff097          	auipc	ra,0xfffff
    80005482:	c30080e7          	jalr	-976(ra) # 800040ae <end_op>
  return -1;
    80005486:	57fd                	li	a5,-1
    80005488:	64f2                	ld	s1,280(sp)
    8000548a:	6952                	ld	s2,272(sp)
}
    8000548c:	853e                	mv	a0,a5
    8000548e:	70b2                	ld	ra,296(sp)
    80005490:	7412                	ld	s0,288(sp)
    80005492:	6155                	add	sp,sp,304
    80005494:	8082                	ret

0000000080005496 <sys_unlink>:
{
    80005496:	7151                	add	sp,sp,-240
    80005498:	f586                	sd	ra,232(sp)
    8000549a:	f1a2                	sd	s0,224(sp)
    8000549c:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000549e:	08000613          	li	a2,128
    800054a2:	f3040593          	add	a1,s0,-208
    800054a6:	4501                	li	a0,0
    800054a8:	ffffd097          	auipc	ra,0xffffd
    800054ac:	68c080e7          	jalr	1676(ra) # 80002b34 <argstr>
    800054b0:	1a054a63          	bltz	a0,80005664 <sys_unlink+0x1ce>
    800054b4:	eda6                	sd	s1,216(sp)
  begin_op();
    800054b6:	fffff097          	auipc	ra,0xfffff
    800054ba:	b7e080e7          	jalr	-1154(ra) # 80004034 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800054be:	fb040593          	add	a1,s0,-80
    800054c2:	f3040513          	add	a0,s0,-208
    800054c6:	fffff097          	auipc	ra,0xfffff
    800054ca:	98c080e7          	jalr	-1652(ra) # 80003e52 <nameiparent>
    800054ce:	84aa                	mv	s1,a0
    800054d0:	cd71                	beqz	a0,800055ac <sys_unlink+0x116>
  ilock(dp);
    800054d2:	ffffe097          	auipc	ra,0xffffe
    800054d6:	190080e7          	jalr	400(ra) # 80003662 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800054da:	00003597          	auipc	a1,0x3
    800054de:	10658593          	add	a1,a1,262 # 800085e0 <etext+0x5e0>
    800054e2:	fb040513          	add	a0,s0,-80
    800054e6:	ffffe097          	auipc	ra,0xffffe
    800054ea:	662080e7          	jalr	1634(ra) # 80003b48 <namecmp>
    800054ee:	14050c63          	beqz	a0,80005646 <sys_unlink+0x1b0>
    800054f2:	00003597          	auipc	a1,0x3
    800054f6:	0f658593          	add	a1,a1,246 # 800085e8 <etext+0x5e8>
    800054fa:	fb040513          	add	a0,s0,-80
    800054fe:	ffffe097          	auipc	ra,0xffffe
    80005502:	64a080e7          	jalr	1610(ra) # 80003b48 <namecmp>
    80005506:	14050063          	beqz	a0,80005646 <sys_unlink+0x1b0>
    8000550a:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000550c:	f2c40613          	add	a2,s0,-212
    80005510:	fb040593          	add	a1,s0,-80
    80005514:	8526                	mv	a0,s1
    80005516:	ffffe097          	auipc	ra,0xffffe
    8000551a:	64c080e7          	jalr	1612(ra) # 80003b62 <dirlookup>
    8000551e:	892a                	mv	s2,a0
    80005520:	12050263          	beqz	a0,80005644 <sys_unlink+0x1ae>
  ilock(ip);
    80005524:	ffffe097          	auipc	ra,0xffffe
    80005528:	13e080e7          	jalr	318(ra) # 80003662 <ilock>
  if(ip->nlink < 1)
    8000552c:	04a91783          	lh	a5,74(s2)
    80005530:	08f05563          	blez	a5,800055ba <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005534:	04491703          	lh	a4,68(s2)
    80005538:	4785                	li	a5,1
    8000553a:	08f70963          	beq	a4,a5,800055cc <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    8000553e:	4641                	li	a2,16
    80005540:	4581                	li	a1,0
    80005542:	fc040513          	add	a0,s0,-64
    80005546:	ffffb097          	auipc	ra,0xffffb
    8000554a:	7e8080e7          	jalr	2024(ra) # 80000d2e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000554e:	4741                	li	a4,16
    80005550:	f2c42683          	lw	a3,-212(s0)
    80005554:	fc040613          	add	a2,s0,-64
    80005558:	4581                	li	a1,0
    8000555a:	8526                	mv	a0,s1
    8000555c:	ffffe097          	auipc	ra,0xffffe
    80005560:	4c2080e7          	jalr	1218(ra) # 80003a1e <writei>
    80005564:	47c1                	li	a5,16
    80005566:	0af51b63          	bne	a0,a5,8000561c <sys_unlink+0x186>
  if(ip->type == T_DIR){
    8000556a:	04491703          	lh	a4,68(s2)
    8000556e:	4785                	li	a5,1
    80005570:	0af70f63          	beq	a4,a5,8000562e <sys_unlink+0x198>
  iunlockput(dp);
    80005574:	8526                	mv	a0,s1
    80005576:	ffffe097          	auipc	ra,0xffffe
    8000557a:	352080e7          	jalr	850(ra) # 800038c8 <iunlockput>
  ip->nlink--;
    8000557e:	04a95783          	lhu	a5,74(s2)
    80005582:	37fd                	addw	a5,a5,-1
    80005584:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005588:	854a                	mv	a0,s2
    8000558a:	ffffe097          	auipc	ra,0xffffe
    8000558e:	00c080e7          	jalr	12(ra) # 80003596 <iupdate>
  iunlockput(ip);
    80005592:	854a                	mv	a0,s2
    80005594:	ffffe097          	auipc	ra,0xffffe
    80005598:	334080e7          	jalr	820(ra) # 800038c8 <iunlockput>
  end_op();
    8000559c:	fffff097          	auipc	ra,0xfffff
    800055a0:	b12080e7          	jalr	-1262(ra) # 800040ae <end_op>
  return 0;
    800055a4:	4501                	li	a0,0
    800055a6:	64ee                	ld	s1,216(sp)
    800055a8:	694e                	ld	s2,208(sp)
    800055aa:	a84d                	j	8000565c <sys_unlink+0x1c6>
    end_op();
    800055ac:	fffff097          	auipc	ra,0xfffff
    800055b0:	b02080e7          	jalr	-1278(ra) # 800040ae <end_op>
    return -1;
    800055b4:	557d                	li	a0,-1
    800055b6:	64ee                	ld	s1,216(sp)
    800055b8:	a055                	j	8000565c <sys_unlink+0x1c6>
    800055ba:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800055bc:	00003517          	auipc	a0,0x3
    800055c0:	05450513          	add	a0,a0,84 # 80008610 <etext+0x610>
    800055c4:	ffffb097          	auipc	ra,0xffffb
    800055c8:	f96080e7          	jalr	-106(ra) # 8000055a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055cc:	04c92703          	lw	a4,76(s2)
    800055d0:	02000793          	li	a5,32
    800055d4:	f6e7f5e3          	bgeu	a5,a4,8000553e <sys_unlink+0xa8>
    800055d8:	e5ce                	sd	s3,200(sp)
    800055da:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055de:	4741                	li	a4,16
    800055e0:	86ce                	mv	a3,s3
    800055e2:	f1840613          	add	a2,s0,-232
    800055e6:	4581                	li	a1,0
    800055e8:	854a                	mv	a0,s2
    800055ea:	ffffe097          	auipc	ra,0xffffe
    800055ee:	330080e7          	jalr	816(ra) # 8000391a <readi>
    800055f2:	47c1                	li	a5,16
    800055f4:	00f51c63          	bne	a0,a5,8000560c <sys_unlink+0x176>
    if(de.inum != 0)
    800055f8:	f1845783          	lhu	a5,-232(s0)
    800055fc:	e7b5                	bnez	a5,80005668 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800055fe:	29c1                	addw	s3,s3,16
    80005600:	04c92783          	lw	a5,76(s2)
    80005604:	fcf9ede3          	bltu	s3,a5,800055de <sys_unlink+0x148>
    80005608:	69ae                	ld	s3,200(sp)
    8000560a:	bf15                	j	8000553e <sys_unlink+0xa8>
      panic("isdirempty: readi");
    8000560c:	00003517          	auipc	a0,0x3
    80005610:	01c50513          	add	a0,a0,28 # 80008628 <etext+0x628>
    80005614:	ffffb097          	auipc	ra,0xffffb
    80005618:	f46080e7          	jalr	-186(ra) # 8000055a <panic>
    8000561c:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000561e:	00003517          	auipc	a0,0x3
    80005622:	02250513          	add	a0,a0,34 # 80008640 <etext+0x640>
    80005626:	ffffb097          	auipc	ra,0xffffb
    8000562a:	f34080e7          	jalr	-204(ra) # 8000055a <panic>
    dp->nlink--;
    8000562e:	04a4d783          	lhu	a5,74(s1)
    80005632:	37fd                	addw	a5,a5,-1
    80005634:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005638:	8526                	mv	a0,s1
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	f5c080e7          	jalr	-164(ra) # 80003596 <iupdate>
    80005642:	bf0d                	j	80005574 <sys_unlink+0xde>
    80005644:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005646:	8526                	mv	a0,s1
    80005648:	ffffe097          	auipc	ra,0xffffe
    8000564c:	280080e7          	jalr	640(ra) # 800038c8 <iunlockput>
  end_op();
    80005650:	fffff097          	auipc	ra,0xfffff
    80005654:	a5e080e7          	jalr	-1442(ra) # 800040ae <end_op>
  return -1;
    80005658:	557d                	li	a0,-1
    8000565a:	64ee                	ld	s1,216(sp)
}
    8000565c:	70ae                	ld	ra,232(sp)
    8000565e:	740e                	ld	s0,224(sp)
    80005660:	616d                	add	sp,sp,240
    80005662:	8082                	ret
    return -1;
    80005664:	557d                	li	a0,-1
    80005666:	bfdd                	j	8000565c <sys_unlink+0x1c6>
    iunlockput(ip);
    80005668:	854a                	mv	a0,s2
    8000566a:	ffffe097          	auipc	ra,0xffffe
    8000566e:	25e080e7          	jalr	606(ra) # 800038c8 <iunlockput>
    goto bad;
    80005672:	694e                	ld	s2,208(sp)
    80005674:	69ae                	ld	s3,200(sp)
    80005676:	bfc1                	j	80005646 <sys_unlink+0x1b0>

0000000080005678 <sys_open>:

uint64
sys_open(void)
{
    80005678:	7131                	add	sp,sp,-192
    8000567a:	fd06                	sd	ra,184(sp)
    8000567c:	f922                	sd	s0,176(sp)
    8000567e:	f526                	sd	s1,168(sp)
    80005680:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005682:	08000613          	li	a2,128
    80005686:	f5040593          	add	a1,s0,-176
    8000568a:	4501                	li	a0,0
    8000568c:	ffffd097          	auipc	ra,0xffffd
    80005690:	4a8080e7          	jalr	1192(ra) # 80002b34 <argstr>
    return -1;
    80005694:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005696:	0c054463          	bltz	a0,8000575e <sys_open+0xe6>
    8000569a:	f4c40593          	add	a1,s0,-180
    8000569e:	4505                	li	a0,1
    800056a0:	ffffd097          	auipc	ra,0xffffd
    800056a4:	450080e7          	jalr	1104(ra) # 80002af0 <argint>
    800056a8:	0a054b63          	bltz	a0,8000575e <sys_open+0xe6>
    800056ac:	f14a                	sd	s2,160(sp)

  begin_op();
    800056ae:	fffff097          	auipc	ra,0xfffff
    800056b2:	986080e7          	jalr	-1658(ra) # 80004034 <begin_op>

  if(omode & O_CREATE){
    800056b6:	f4c42783          	lw	a5,-180(s0)
    800056ba:	2007f793          	and	a5,a5,512
    800056be:	cfc5                	beqz	a5,80005776 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800056c0:	4681                	li	a3,0
    800056c2:	4601                	li	a2,0
    800056c4:	4589                	li	a1,2
    800056c6:	f5040513          	add	a0,s0,-176
    800056ca:	00000097          	auipc	ra,0x0
    800056ce:	958080e7          	jalr	-1704(ra) # 80005022 <create>
    800056d2:	892a                	mv	s2,a0
    if(ip == 0){
    800056d4:	c959                	beqz	a0,8000576a <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800056d6:	04491703          	lh	a4,68(s2)
    800056da:	478d                	li	a5,3
    800056dc:	00f71763          	bne	a4,a5,800056ea <sys_open+0x72>
    800056e0:	04695703          	lhu	a4,70(s2)
    800056e4:	47a5                	li	a5,9
    800056e6:	0ce7ef63          	bltu	a5,a4,800057c4 <sys_open+0x14c>
    800056ea:	ed4e                	sd	s3,152(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800056ec:	fffff097          	auipc	ra,0xfffff
    800056f0:	d56080e7          	jalr	-682(ra) # 80004442 <filealloc>
    800056f4:	89aa                	mv	s3,a0
    800056f6:	c965                	beqz	a0,800057e6 <sys_open+0x16e>
    800056f8:	00000097          	auipc	ra,0x0
    800056fc:	8e8080e7          	jalr	-1816(ra) # 80004fe0 <fdalloc>
    80005700:	84aa                	mv	s1,a0
    80005702:	0c054d63          	bltz	a0,800057dc <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005706:	04491703          	lh	a4,68(s2)
    8000570a:	478d                	li	a5,3
    8000570c:	0ef70a63          	beq	a4,a5,80005800 <sys_open+0x188>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005710:	4789                	li	a5,2
    80005712:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005716:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000571a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000571e:	f4c42783          	lw	a5,-180(s0)
    80005722:	0017c713          	xor	a4,a5,1
    80005726:	8b05                	and	a4,a4,1
    80005728:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000572c:	0037f713          	and	a4,a5,3
    80005730:	00e03733          	snez	a4,a4
    80005734:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005738:	4007f793          	and	a5,a5,1024
    8000573c:	c791                	beqz	a5,80005748 <sys_open+0xd0>
    8000573e:	04491703          	lh	a4,68(s2)
    80005742:	4789                	li	a5,2
    80005744:	0cf70563          	beq	a4,a5,8000580e <sys_open+0x196>
    itrunc(ip);
  }

  iunlock(ip);
    80005748:	854a                	mv	a0,s2
    8000574a:	ffffe097          	auipc	ra,0xffffe
    8000574e:	fde080e7          	jalr	-34(ra) # 80003728 <iunlock>
  end_op();
    80005752:	fffff097          	auipc	ra,0xfffff
    80005756:	95c080e7          	jalr	-1700(ra) # 800040ae <end_op>
    8000575a:	790a                	ld	s2,160(sp)
    8000575c:	69ea                	ld	s3,152(sp)

  return fd;
}
    8000575e:	8526                	mv	a0,s1
    80005760:	70ea                	ld	ra,184(sp)
    80005762:	744a                	ld	s0,176(sp)
    80005764:	74aa                	ld	s1,168(sp)
    80005766:	6129                	add	sp,sp,192
    80005768:	8082                	ret
      end_op();
    8000576a:	fffff097          	auipc	ra,0xfffff
    8000576e:	944080e7          	jalr	-1724(ra) # 800040ae <end_op>
      return -1;
    80005772:	790a                	ld	s2,160(sp)
    80005774:	b7ed                	j	8000575e <sys_open+0xe6>
    if((ip = namei(path)) == 0){
    80005776:	f5040513          	add	a0,s0,-176
    8000577a:	ffffe097          	auipc	ra,0xffffe
    8000577e:	6ba080e7          	jalr	1722(ra) # 80003e34 <namei>
    80005782:	892a                	mv	s2,a0
    80005784:	c90d                	beqz	a0,800057b6 <sys_open+0x13e>
    ilock(ip);
    80005786:	ffffe097          	auipc	ra,0xffffe
    8000578a:	edc080e7          	jalr	-292(ra) # 80003662 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000578e:	04491703          	lh	a4,68(s2)
    80005792:	4785                	li	a5,1
    80005794:	f4f711e3          	bne	a4,a5,800056d6 <sys_open+0x5e>
    80005798:	f4c42783          	lw	a5,-180(s0)
    8000579c:	d7b9                	beqz	a5,800056ea <sys_open+0x72>
      iunlockput(ip);
    8000579e:	854a                	mv	a0,s2
    800057a0:	ffffe097          	auipc	ra,0xffffe
    800057a4:	128080e7          	jalr	296(ra) # 800038c8 <iunlockput>
      end_op();
    800057a8:	fffff097          	auipc	ra,0xfffff
    800057ac:	906080e7          	jalr	-1786(ra) # 800040ae <end_op>
      return -1;
    800057b0:	54fd                	li	s1,-1
    800057b2:	790a                	ld	s2,160(sp)
    800057b4:	b76d                	j	8000575e <sys_open+0xe6>
      end_op();
    800057b6:	fffff097          	auipc	ra,0xfffff
    800057ba:	8f8080e7          	jalr	-1800(ra) # 800040ae <end_op>
      return -1;
    800057be:	54fd                	li	s1,-1
    800057c0:	790a                	ld	s2,160(sp)
    800057c2:	bf71                	j	8000575e <sys_open+0xe6>
    iunlockput(ip);
    800057c4:	854a                	mv	a0,s2
    800057c6:	ffffe097          	auipc	ra,0xffffe
    800057ca:	102080e7          	jalr	258(ra) # 800038c8 <iunlockput>
    end_op();
    800057ce:	fffff097          	auipc	ra,0xfffff
    800057d2:	8e0080e7          	jalr	-1824(ra) # 800040ae <end_op>
    return -1;
    800057d6:	54fd                	li	s1,-1
    800057d8:	790a                	ld	s2,160(sp)
    800057da:	b751                	j	8000575e <sys_open+0xe6>
      fileclose(f);
    800057dc:	854e                	mv	a0,s3
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	d20080e7          	jalr	-736(ra) # 800044fe <fileclose>
    iunlockput(ip);
    800057e6:	854a                	mv	a0,s2
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	0e0080e7          	jalr	224(ra) # 800038c8 <iunlockput>
    end_op();
    800057f0:	fffff097          	auipc	ra,0xfffff
    800057f4:	8be080e7          	jalr	-1858(ra) # 800040ae <end_op>
    return -1;
    800057f8:	54fd                	li	s1,-1
    800057fa:	790a                	ld	s2,160(sp)
    800057fc:	69ea                	ld	s3,152(sp)
    800057fe:	b785                	j	8000575e <sys_open+0xe6>
    f->type = FD_DEVICE;
    80005800:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005804:	04691783          	lh	a5,70(s2)
    80005808:	02f99223          	sh	a5,36(s3)
    8000580c:	b739                	j	8000571a <sys_open+0xa2>
    itrunc(ip);
    8000580e:	854a                	mv	a0,s2
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	f64080e7          	jalr	-156(ra) # 80003774 <itrunc>
    80005818:	bf05                	j	80005748 <sys_open+0xd0>

000000008000581a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000581a:	7175                	add	sp,sp,-144
    8000581c:	e506                	sd	ra,136(sp)
    8000581e:	e122                	sd	s0,128(sp)
    80005820:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005822:	fffff097          	auipc	ra,0xfffff
    80005826:	812080e7          	jalr	-2030(ra) # 80004034 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000582a:	08000613          	li	a2,128
    8000582e:	f7040593          	add	a1,s0,-144
    80005832:	4501                	li	a0,0
    80005834:	ffffd097          	auipc	ra,0xffffd
    80005838:	300080e7          	jalr	768(ra) # 80002b34 <argstr>
    8000583c:	02054963          	bltz	a0,8000586e <sys_mkdir+0x54>
    80005840:	4681                	li	a3,0
    80005842:	4601                	li	a2,0
    80005844:	4585                	li	a1,1
    80005846:	f7040513          	add	a0,s0,-144
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	7d8080e7          	jalr	2008(ra) # 80005022 <create>
    80005852:	cd11                	beqz	a0,8000586e <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	074080e7          	jalr	116(ra) # 800038c8 <iunlockput>
  end_op();
    8000585c:	fffff097          	auipc	ra,0xfffff
    80005860:	852080e7          	jalr	-1966(ra) # 800040ae <end_op>
  return 0;
    80005864:	4501                	li	a0,0
}
    80005866:	60aa                	ld	ra,136(sp)
    80005868:	640a                	ld	s0,128(sp)
    8000586a:	6149                	add	sp,sp,144
    8000586c:	8082                	ret
    end_op();
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	840080e7          	jalr	-1984(ra) # 800040ae <end_op>
    return -1;
    80005876:	557d                	li	a0,-1
    80005878:	b7fd                	j	80005866 <sys_mkdir+0x4c>

000000008000587a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000587a:	7135                	add	sp,sp,-160
    8000587c:	ed06                	sd	ra,152(sp)
    8000587e:	e922                	sd	s0,144(sp)
    80005880:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005882:	ffffe097          	auipc	ra,0xffffe
    80005886:	7b2080e7          	jalr	1970(ra) # 80004034 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000588a:	08000613          	li	a2,128
    8000588e:	f7040593          	add	a1,s0,-144
    80005892:	4501                	li	a0,0
    80005894:	ffffd097          	auipc	ra,0xffffd
    80005898:	2a0080e7          	jalr	672(ra) # 80002b34 <argstr>
    8000589c:	04054a63          	bltz	a0,800058f0 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800058a0:	f6c40593          	add	a1,s0,-148
    800058a4:	4505                	li	a0,1
    800058a6:	ffffd097          	auipc	ra,0xffffd
    800058aa:	24a080e7          	jalr	586(ra) # 80002af0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058ae:	04054163          	bltz	a0,800058f0 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800058b2:	f6840593          	add	a1,s0,-152
    800058b6:	4509                	li	a0,2
    800058b8:	ffffd097          	auipc	ra,0xffffd
    800058bc:	238080e7          	jalr	568(ra) # 80002af0 <argint>
     argint(1, &major) < 0 ||
    800058c0:	02054863          	bltz	a0,800058f0 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800058c4:	f6841683          	lh	a3,-152(s0)
    800058c8:	f6c41603          	lh	a2,-148(s0)
    800058cc:	458d                	li	a1,3
    800058ce:	f7040513          	add	a0,s0,-144
    800058d2:	fffff097          	auipc	ra,0xfffff
    800058d6:	750080e7          	jalr	1872(ra) # 80005022 <create>
     argint(2, &minor) < 0 ||
    800058da:	c919                	beqz	a0,800058f0 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058dc:	ffffe097          	auipc	ra,0xffffe
    800058e0:	fec080e7          	jalr	-20(ra) # 800038c8 <iunlockput>
  end_op();
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	7ca080e7          	jalr	1994(ra) # 800040ae <end_op>
  return 0;
    800058ec:	4501                	li	a0,0
    800058ee:	a031                	j	800058fa <sys_mknod+0x80>
    end_op();
    800058f0:	ffffe097          	auipc	ra,0xffffe
    800058f4:	7be080e7          	jalr	1982(ra) # 800040ae <end_op>
    return -1;
    800058f8:	557d                	li	a0,-1
}
    800058fa:	60ea                	ld	ra,152(sp)
    800058fc:	644a                	ld	s0,144(sp)
    800058fe:	610d                	add	sp,sp,160
    80005900:	8082                	ret

0000000080005902 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005902:	7135                	add	sp,sp,-160
    80005904:	ed06                	sd	ra,152(sp)
    80005906:	e922                	sd	s0,144(sp)
    80005908:	e14a                	sd	s2,128(sp)
    8000590a:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000590c:	ffffc097          	auipc	ra,0xffffc
    80005910:	124080e7          	jalr	292(ra) # 80001a30 <myproc>
    80005914:	892a                	mv	s2,a0
  
  begin_op();
    80005916:	ffffe097          	auipc	ra,0xffffe
    8000591a:	71e080e7          	jalr	1822(ra) # 80004034 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000591e:	08000613          	li	a2,128
    80005922:	f6040593          	add	a1,s0,-160
    80005926:	4501                	li	a0,0
    80005928:	ffffd097          	auipc	ra,0xffffd
    8000592c:	20c080e7          	jalr	524(ra) # 80002b34 <argstr>
    80005930:	04054d63          	bltz	a0,8000598a <sys_chdir+0x88>
    80005934:	e526                	sd	s1,136(sp)
    80005936:	f6040513          	add	a0,s0,-160
    8000593a:	ffffe097          	auipc	ra,0xffffe
    8000593e:	4fa080e7          	jalr	1274(ra) # 80003e34 <namei>
    80005942:	84aa                	mv	s1,a0
    80005944:	c131                	beqz	a0,80005988 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005946:	ffffe097          	auipc	ra,0xffffe
    8000594a:	d1c080e7          	jalr	-740(ra) # 80003662 <ilock>
  if(ip->type != T_DIR){
    8000594e:	04449703          	lh	a4,68(s1)
    80005952:	4785                	li	a5,1
    80005954:	04f71163          	bne	a4,a5,80005996 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005958:	8526                	mv	a0,s1
    8000595a:	ffffe097          	auipc	ra,0xffffe
    8000595e:	dce080e7          	jalr	-562(ra) # 80003728 <iunlock>
  iput(p->cwd);
    80005962:	15093503          	ld	a0,336(s2)
    80005966:	ffffe097          	auipc	ra,0xffffe
    8000596a:	eba080e7          	jalr	-326(ra) # 80003820 <iput>
  end_op();
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	740080e7          	jalr	1856(ra) # 800040ae <end_op>
  p->cwd = ip;
    80005976:	14993823          	sd	s1,336(s2)
  return 0;
    8000597a:	4501                	li	a0,0
    8000597c:	64aa                	ld	s1,136(sp)
}
    8000597e:	60ea                	ld	ra,152(sp)
    80005980:	644a                	ld	s0,144(sp)
    80005982:	690a                	ld	s2,128(sp)
    80005984:	610d                	add	sp,sp,160
    80005986:	8082                	ret
    80005988:	64aa                	ld	s1,136(sp)
    end_op();
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	724080e7          	jalr	1828(ra) # 800040ae <end_op>
    return -1;
    80005992:	557d                	li	a0,-1
    80005994:	b7ed                	j	8000597e <sys_chdir+0x7c>
    iunlockput(ip);
    80005996:	8526                	mv	a0,s1
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	f30080e7          	jalr	-208(ra) # 800038c8 <iunlockput>
    end_op();
    800059a0:	ffffe097          	auipc	ra,0xffffe
    800059a4:	70e080e7          	jalr	1806(ra) # 800040ae <end_op>
    return -1;
    800059a8:	557d                	li	a0,-1
    800059aa:	64aa                	ld	s1,136(sp)
    800059ac:	bfc9                	j	8000597e <sys_chdir+0x7c>

00000000800059ae <sys_exec>:

uint64
sys_exec(void)
{
    800059ae:	7121                	add	sp,sp,-448
    800059b0:	ff06                	sd	ra,440(sp)
    800059b2:	fb22                	sd	s0,432(sp)
    800059b4:	f34a                	sd	s2,416(sp)
    800059b6:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800059b8:	08000613          	li	a2,128
    800059bc:	f5040593          	add	a1,s0,-176
    800059c0:	4501                	li	a0,0
    800059c2:	ffffd097          	auipc	ra,0xffffd
    800059c6:	172080e7          	jalr	370(ra) # 80002b34 <argstr>
    return -1;
    800059ca:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800059cc:	0e054a63          	bltz	a0,80005ac0 <sys_exec+0x112>
    800059d0:	e4840593          	add	a1,s0,-440
    800059d4:	4505                	li	a0,1
    800059d6:	ffffd097          	auipc	ra,0xffffd
    800059da:	13c080e7          	jalr	316(ra) # 80002b12 <argaddr>
    800059de:	0e054163          	bltz	a0,80005ac0 <sys_exec+0x112>
    800059e2:	f726                	sd	s1,424(sp)
    800059e4:	ef4e                	sd	s3,408(sp)
    800059e6:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    800059e8:	10000613          	li	a2,256
    800059ec:	4581                	li	a1,0
    800059ee:	e5040513          	add	a0,s0,-432
    800059f2:	ffffb097          	auipc	ra,0xffffb
    800059f6:	33c080e7          	jalr	828(ra) # 80000d2e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800059fa:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800059fe:	89a6                	mv	s3,s1
    80005a00:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a02:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a06:	00391513          	sll	a0,s2,0x3
    80005a0a:	e4040593          	add	a1,s0,-448
    80005a0e:	e4843783          	ld	a5,-440(s0)
    80005a12:	953e                	add	a0,a0,a5
    80005a14:	ffffd097          	auipc	ra,0xffffd
    80005a18:	042080e7          	jalr	66(ra) # 80002a56 <fetchaddr>
    80005a1c:	02054a63          	bltz	a0,80005a50 <sys_exec+0xa2>
      goto bad;
    }
    if(uarg == 0){
    80005a20:	e4043783          	ld	a5,-448(s0)
    80005a24:	c7b1                	beqz	a5,80005a70 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a26:	ffffb097          	auipc	ra,0xffffb
    80005a2a:	11c080e7          	jalr	284(ra) # 80000b42 <kalloc>
    80005a2e:	85aa                	mv	a1,a0
    80005a30:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a34:	cd11                	beqz	a0,80005a50 <sys_exec+0xa2>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a36:	6605                	lui	a2,0x1
    80005a38:	e4043503          	ld	a0,-448(s0)
    80005a3c:	ffffd097          	auipc	ra,0xffffd
    80005a40:	06c080e7          	jalr	108(ra) # 80002aa8 <fetchstr>
    80005a44:	00054663          	bltz	a0,80005a50 <sys_exec+0xa2>
    if(i >= NELEM(argv)){
    80005a48:	0905                	add	s2,s2,1
    80005a4a:	09a1                	add	s3,s3,8
    80005a4c:	fb491de3          	bne	s2,s4,80005a06 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a50:	f5040913          	add	s2,s0,-176
    80005a54:	6088                	ld	a0,0(s1)
    80005a56:	c12d                	beqz	a0,80005ab8 <sys_exec+0x10a>
    kfree(argv[i]);
    80005a58:	ffffb097          	auipc	ra,0xffffb
    80005a5c:	fec080e7          	jalr	-20(ra) # 80000a44 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a60:	04a1                	add	s1,s1,8
    80005a62:	ff2499e3          	bne	s1,s2,80005a54 <sys_exec+0xa6>
  return -1;
    80005a66:	597d                	li	s2,-1
    80005a68:	74ba                	ld	s1,424(sp)
    80005a6a:	69fa                	ld	s3,408(sp)
    80005a6c:	6a5a                	ld	s4,400(sp)
    80005a6e:	a889                	j	80005ac0 <sys_exec+0x112>
      argv[i] = 0;
    80005a70:	0009079b          	sext.w	a5,s2
    80005a74:	078e                	sll	a5,a5,0x3
    80005a76:	fd078793          	add	a5,a5,-48
    80005a7a:	97a2                	add	a5,a5,s0
    80005a7c:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005a80:	e5040593          	add	a1,s0,-432
    80005a84:	f5040513          	add	a0,s0,-176
    80005a88:	fffff097          	auipc	ra,0xfffff
    80005a8c:	126080e7          	jalr	294(ra) # 80004bae <exec>
    80005a90:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a92:	f5040993          	add	s3,s0,-176
    80005a96:	6088                	ld	a0,0(s1)
    80005a98:	cd01                	beqz	a0,80005ab0 <sys_exec+0x102>
    kfree(argv[i]);
    80005a9a:	ffffb097          	auipc	ra,0xffffb
    80005a9e:	faa080e7          	jalr	-86(ra) # 80000a44 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aa2:	04a1                	add	s1,s1,8
    80005aa4:	ff3499e3          	bne	s1,s3,80005a96 <sys_exec+0xe8>
    80005aa8:	74ba                	ld	s1,424(sp)
    80005aaa:	69fa                	ld	s3,408(sp)
    80005aac:	6a5a                	ld	s4,400(sp)
    80005aae:	a809                	j	80005ac0 <sys_exec+0x112>
  return ret;
    80005ab0:	74ba                	ld	s1,424(sp)
    80005ab2:	69fa                	ld	s3,408(sp)
    80005ab4:	6a5a                	ld	s4,400(sp)
    80005ab6:	a029                	j	80005ac0 <sys_exec+0x112>
  return -1;
    80005ab8:	597d                	li	s2,-1
    80005aba:	74ba                	ld	s1,424(sp)
    80005abc:	69fa                	ld	s3,408(sp)
    80005abe:	6a5a                	ld	s4,400(sp)
}
    80005ac0:	854a                	mv	a0,s2
    80005ac2:	70fa                	ld	ra,440(sp)
    80005ac4:	745a                	ld	s0,432(sp)
    80005ac6:	791a                	ld	s2,416(sp)
    80005ac8:	6139                	add	sp,sp,448
    80005aca:	8082                	ret

0000000080005acc <sys_pipe>:

uint64
sys_pipe(void)
{
    80005acc:	7139                	add	sp,sp,-64
    80005ace:	fc06                	sd	ra,56(sp)
    80005ad0:	f822                	sd	s0,48(sp)
    80005ad2:	f426                	sd	s1,40(sp)
    80005ad4:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ad6:	ffffc097          	auipc	ra,0xffffc
    80005ada:	f5a080e7          	jalr	-166(ra) # 80001a30 <myproc>
    80005ade:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005ae0:	fd840593          	add	a1,s0,-40
    80005ae4:	4501                	li	a0,0
    80005ae6:	ffffd097          	auipc	ra,0xffffd
    80005aea:	02c080e7          	jalr	44(ra) # 80002b12 <argaddr>
    return -1;
    80005aee:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005af0:	0e054063          	bltz	a0,80005bd0 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005af4:	fc840593          	add	a1,s0,-56
    80005af8:	fd040513          	add	a0,s0,-48
    80005afc:	fffff097          	auipc	ra,0xfffff
    80005b00:	d70080e7          	jalr	-656(ra) # 8000486c <pipealloc>
    return -1;
    80005b04:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b06:	0c054563          	bltz	a0,80005bd0 <sys_pipe+0x104>
  fd0 = -1;
    80005b0a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b0e:	fd043503          	ld	a0,-48(s0)
    80005b12:	fffff097          	auipc	ra,0xfffff
    80005b16:	4ce080e7          	jalr	1230(ra) # 80004fe0 <fdalloc>
    80005b1a:	fca42223          	sw	a0,-60(s0)
    80005b1e:	08054c63          	bltz	a0,80005bb6 <sys_pipe+0xea>
    80005b22:	fc843503          	ld	a0,-56(s0)
    80005b26:	fffff097          	auipc	ra,0xfffff
    80005b2a:	4ba080e7          	jalr	1210(ra) # 80004fe0 <fdalloc>
    80005b2e:	fca42023          	sw	a0,-64(s0)
    80005b32:	06054963          	bltz	a0,80005ba4 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b36:	4691                	li	a3,4
    80005b38:	fc440613          	add	a2,s0,-60
    80005b3c:	fd843583          	ld	a1,-40(s0)
    80005b40:	68a8                	ld	a0,80(s1)
    80005b42:	ffffc097          	auipc	ra,0xffffc
    80005b46:	b8a080e7          	jalr	-1142(ra) # 800016cc <copyout>
    80005b4a:	02054063          	bltz	a0,80005b6a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b4e:	4691                	li	a3,4
    80005b50:	fc040613          	add	a2,s0,-64
    80005b54:	fd843583          	ld	a1,-40(s0)
    80005b58:	0591                	add	a1,a1,4
    80005b5a:	68a8                	ld	a0,80(s1)
    80005b5c:	ffffc097          	auipc	ra,0xffffc
    80005b60:	b70080e7          	jalr	-1168(ra) # 800016cc <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b64:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b66:	06055563          	bgez	a0,80005bd0 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005b6a:	fc442783          	lw	a5,-60(s0)
    80005b6e:	07e9                	add	a5,a5,26
    80005b70:	078e                	sll	a5,a5,0x3
    80005b72:	97a6                	add	a5,a5,s1
    80005b74:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b78:	fc042783          	lw	a5,-64(s0)
    80005b7c:	07e9                	add	a5,a5,26
    80005b7e:	078e                	sll	a5,a5,0x3
    80005b80:	00f48533          	add	a0,s1,a5
    80005b84:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005b88:	fd043503          	ld	a0,-48(s0)
    80005b8c:	fffff097          	auipc	ra,0xfffff
    80005b90:	972080e7          	jalr	-1678(ra) # 800044fe <fileclose>
    fileclose(wf);
    80005b94:	fc843503          	ld	a0,-56(s0)
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	966080e7          	jalr	-1690(ra) # 800044fe <fileclose>
    return -1;
    80005ba0:	57fd                	li	a5,-1
    80005ba2:	a03d                	j	80005bd0 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005ba4:	fc442783          	lw	a5,-60(s0)
    80005ba8:	0007c763          	bltz	a5,80005bb6 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005bac:	07e9                	add	a5,a5,26
    80005bae:	078e                	sll	a5,a5,0x3
    80005bb0:	97a6                	add	a5,a5,s1
    80005bb2:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005bb6:	fd043503          	ld	a0,-48(s0)
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	944080e7          	jalr	-1724(ra) # 800044fe <fileclose>
    fileclose(wf);
    80005bc2:	fc843503          	ld	a0,-56(s0)
    80005bc6:	fffff097          	auipc	ra,0xfffff
    80005bca:	938080e7          	jalr	-1736(ra) # 800044fe <fileclose>
    return -1;
    80005bce:	57fd                	li	a5,-1
}
    80005bd0:	853e                	mv	a0,a5
    80005bd2:	70e2                	ld	ra,56(sp)
    80005bd4:	7442                	ld	s0,48(sp)
    80005bd6:	74a2                	ld	s1,40(sp)
    80005bd8:	6121                	add	sp,sp,64
    80005bda:	8082                	ret
    80005bdc:	0000                	unimp
	...

0000000080005be0 <kernelvec>:
    80005be0:	7111                	add	sp,sp,-256
    80005be2:	e006                	sd	ra,0(sp)
    80005be4:	e40a                	sd	sp,8(sp)
    80005be6:	e80e                	sd	gp,16(sp)
    80005be8:	ec12                	sd	tp,24(sp)
    80005bea:	f016                	sd	t0,32(sp)
    80005bec:	f41a                	sd	t1,40(sp)
    80005bee:	f81e                	sd	t2,48(sp)
    80005bf0:	fc22                	sd	s0,56(sp)
    80005bf2:	e0a6                	sd	s1,64(sp)
    80005bf4:	e4aa                	sd	a0,72(sp)
    80005bf6:	e8ae                	sd	a1,80(sp)
    80005bf8:	ecb2                	sd	a2,88(sp)
    80005bfa:	f0b6                	sd	a3,96(sp)
    80005bfc:	f4ba                	sd	a4,104(sp)
    80005bfe:	f8be                	sd	a5,112(sp)
    80005c00:	fcc2                	sd	a6,120(sp)
    80005c02:	e146                	sd	a7,128(sp)
    80005c04:	e54a                	sd	s2,136(sp)
    80005c06:	e94e                	sd	s3,144(sp)
    80005c08:	ed52                	sd	s4,152(sp)
    80005c0a:	f156                	sd	s5,160(sp)
    80005c0c:	f55a                	sd	s6,168(sp)
    80005c0e:	f95e                	sd	s7,176(sp)
    80005c10:	fd62                	sd	s8,184(sp)
    80005c12:	e1e6                	sd	s9,192(sp)
    80005c14:	e5ea                	sd	s10,200(sp)
    80005c16:	e9ee                	sd	s11,208(sp)
    80005c18:	edf2                	sd	t3,216(sp)
    80005c1a:	f1f6                	sd	t4,224(sp)
    80005c1c:	f5fa                	sd	t5,232(sp)
    80005c1e:	f9fe                	sd	t6,240(sp)
    80005c20:	d03fc0ef          	jal	80002922 <kerneltrap>
    80005c24:	6082                	ld	ra,0(sp)
    80005c26:	6122                	ld	sp,8(sp)
    80005c28:	61c2                	ld	gp,16(sp)
    80005c2a:	7282                	ld	t0,32(sp)
    80005c2c:	7322                	ld	t1,40(sp)
    80005c2e:	73c2                	ld	t2,48(sp)
    80005c30:	7462                	ld	s0,56(sp)
    80005c32:	6486                	ld	s1,64(sp)
    80005c34:	6526                	ld	a0,72(sp)
    80005c36:	65c6                	ld	a1,80(sp)
    80005c38:	6666                	ld	a2,88(sp)
    80005c3a:	7686                	ld	a3,96(sp)
    80005c3c:	7726                	ld	a4,104(sp)
    80005c3e:	77c6                	ld	a5,112(sp)
    80005c40:	7866                	ld	a6,120(sp)
    80005c42:	688a                	ld	a7,128(sp)
    80005c44:	692a                	ld	s2,136(sp)
    80005c46:	69ca                	ld	s3,144(sp)
    80005c48:	6a6a                	ld	s4,152(sp)
    80005c4a:	7a8a                	ld	s5,160(sp)
    80005c4c:	7b2a                	ld	s6,168(sp)
    80005c4e:	7bca                	ld	s7,176(sp)
    80005c50:	7c6a                	ld	s8,184(sp)
    80005c52:	6c8e                	ld	s9,192(sp)
    80005c54:	6d2e                	ld	s10,200(sp)
    80005c56:	6dce                	ld	s11,208(sp)
    80005c58:	6e6e                	ld	t3,216(sp)
    80005c5a:	7e8e                	ld	t4,224(sp)
    80005c5c:	7f2e                	ld	t5,232(sp)
    80005c5e:	7fce                	ld	t6,240(sp)
    80005c60:	6111                	add	sp,sp,256
    80005c62:	10200073          	sret
    80005c66:	00000013          	nop
    80005c6a:	00000013          	nop
    80005c6e:	0001                	nop

0000000080005c70 <timervec>:
    80005c70:	34051573          	csrrw	a0,mscratch,a0
    80005c74:	e10c                	sd	a1,0(a0)
    80005c76:	e510                	sd	a2,8(a0)
    80005c78:	e914                	sd	a3,16(a0)
    80005c7a:	6d0c                	ld	a1,24(a0)
    80005c7c:	7110                	ld	a2,32(a0)
    80005c7e:	6194                	ld	a3,0(a1)
    80005c80:	96b2                	add	a3,a3,a2
    80005c82:	e194                	sd	a3,0(a1)
    80005c84:	4589                	li	a1,2
    80005c86:	14459073          	csrw	sip,a1
    80005c8a:	6914                	ld	a3,16(a0)
    80005c8c:	6510                	ld	a2,8(a0)
    80005c8e:	610c                	ld	a1,0(a0)
    80005c90:	34051573          	csrrw	a0,mscratch,a0
    80005c94:	30200073          	mret
	...

0000000080005c9a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c9a:	1141                	add	sp,sp,-16
    80005c9c:	e422                	sd	s0,8(sp)
    80005c9e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ca0:	0c0007b7          	lui	a5,0xc000
    80005ca4:	4705                	li	a4,1
    80005ca6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ca8:	0c0007b7          	lui	a5,0xc000
    80005cac:	c3d8                	sw	a4,4(a5)
}
    80005cae:	6422                	ld	s0,8(sp)
    80005cb0:	0141                	add	sp,sp,16
    80005cb2:	8082                	ret

0000000080005cb4 <plicinithart>:

void
plicinithart(void)
{
    80005cb4:	1141                	add	sp,sp,-16
    80005cb6:	e406                	sd	ra,8(sp)
    80005cb8:	e022                	sd	s0,0(sp)
    80005cba:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005cbc:	ffffc097          	auipc	ra,0xffffc
    80005cc0:	d48080e7          	jalr	-696(ra) # 80001a04 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005cc4:	0085171b          	sllw	a4,a0,0x8
    80005cc8:	0c0027b7          	lui	a5,0xc002
    80005ccc:	97ba                	add	a5,a5,a4
    80005cce:	40200713          	li	a4,1026
    80005cd2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005cd6:	00d5151b          	sllw	a0,a0,0xd
    80005cda:	0c2017b7          	lui	a5,0xc201
    80005cde:	97aa                	add	a5,a5,a0
    80005ce0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005ce4:	60a2                	ld	ra,8(sp)
    80005ce6:	6402                	ld	s0,0(sp)
    80005ce8:	0141                	add	sp,sp,16
    80005cea:	8082                	ret

0000000080005cec <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005cec:	1141                	add	sp,sp,-16
    80005cee:	e406                	sd	ra,8(sp)
    80005cf0:	e022                	sd	s0,0(sp)
    80005cf2:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005cf4:	ffffc097          	auipc	ra,0xffffc
    80005cf8:	d10080e7          	jalr	-752(ra) # 80001a04 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005cfc:	00d5151b          	sllw	a0,a0,0xd
    80005d00:	0c2017b7          	lui	a5,0xc201
    80005d04:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d06:	43c8                	lw	a0,4(a5)
    80005d08:	60a2                	ld	ra,8(sp)
    80005d0a:	6402                	ld	s0,0(sp)
    80005d0c:	0141                	add	sp,sp,16
    80005d0e:	8082                	ret

0000000080005d10 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d10:	1101                	add	sp,sp,-32
    80005d12:	ec06                	sd	ra,24(sp)
    80005d14:	e822                	sd	s0,16(sp)
    80005d16:	e426                	sd	s1,8(sp)
    80005d18:	1000                	add	s0,sp,32
    80005d1a:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d1c:	ffffc097          	auipc	ra,0xffffc
    80005d20:	ce8080e7          	jalr	-792(ra) # 80001a04 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d24:	00d5151b          	sllw	a0,a0,0xd
    80005d28:	0c2017b7          	lui	a5,0xc201
    80005d2c:	97aa                	add	a5,a5,a0
    80005d2e:	c3c4                	sw	s1,4(a5)
}
    80005d30:	60e2                	ld	ra,24(sp)
    80005d32:	6442                	ld	s0,16(sp)
    80005d34:	64a2                	ld	s1,8(sp)
    80005d36:	6105                	add	sp,sp,32
    80005d38:	8082                	ret

0000000080005d3a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d3a:	1141                	add	sp,sp,-16
    80005d3c:	e406                	sd	ra,8(sp)
    80005d3e:	e022                	sd	s0,0(sp)
    80005d40:	0800                	add	s0,sp,16
  if(i >= NUM)
    80005d42:	479d                	li	a5,7
    80005d44:	06a7c863          	blt	a5,a0,80005db4 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80005d48:	0001d717          	auipc	a4,0x1d
    80005d4c:	2b870713          	add	a4,a4,696 # 80023000 <disk>
    80005d50:	972a                	add	a4,a4,a0
    80005d52:	6789                	lui	a5,0x2
    80005d54:	97ba                	add	a5,a5,a4
    80005d56:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005d5a:	e7ad                	bnez	a5,80005dc4 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d5c:	00451793          	sll	a5,a0,0x4
    80005d60:	0001f717          	auipc	a4,0x1f
    80005d64:	2a070713          	add	a4,a4,672 # 80025000 <disk+0x2000>
    80005d68:	6314                	ld	a3,0(a4)
    80005d6a:	96be                	add	a3,a3,a5
    80005d6c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005d70:	6314                	ld	a3,0(a4)
    80005d72:	96be                	add	a3,a3,a5
    80005d74:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005d78:	6314                	ld	a3,0(a4)
    80005d7a:	96be                	add	a3,a3,a5
    80005d7c:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005d80:	6318                	ld	a4,0(a4)
    80005d82:	97ba                	add	a5,a5,a4
    80005d84:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005d88:	0001d717          	auipc	a4,0x1d
    80005d8c:	27870713          	add	a4,a4,632 # 80023000 <disk>
    80005d90:	972a                	add	a4,a4,a0
    80005d92:	6789                	lui	a5,0x2
    80005d94:	97ba                	add	a5,a5,a4
    80005d96:	4705                	li	a4,1
    80005d98:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005d9c:	0001f517          	auipc	a0,0x1f
    80005da0:	27c50513          	add	a0,a0,636 # 80025018 <disk+0x2018>
    80005da4:	ffffc097          	auipc	ra,0xffffc
    80005da8:	4de080e7          	jalr	1246(ra) # 80002282 <wakeup>
}
    80005dac:	60a2                	ld	ra,8(sp)
    80005dae:	6402                	ld	s0,0(sp)
    80005db0:	0141                	add	sp,sp,16
    80005db2:	8082                	ret
    panic("free_desc 1");
    80005db4:	00003517          	auipc	a0,0x3
    80005db8:	89c50513          	add	a0,a0,-1892 # 80008650 <etext+0x650>
    80005dbc:	ffffa097          	auipc	ra,0xffffa
    80005dc0:	79e080e7          	jalr	1950(ra) # 8000055a <panic>
    panic("free_desc 2");
    80005dc4:	00003517          	auipc	a0,0x3
    80005dc8:	89c50513          	add	a0,a0,-1892 # 80008660 <etext+0x660>
    80005dcc:	ffffa097          	auipc	ra,0xffffa
    80005dd0:	78e080e7          	jalr	1934(ra) # 8000055a <panic>

0000000080005dd4 <virtio_disk_init>:
{
    80005dd4:	1141                	add	sp,sp,-16
    80005dd6:	e406                	sd	ra,8(sp)
    80005dd8:	e022                	sd	s0,0(sp)
    80005dda:	0800                	add	s0,sp,16
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ddc:	00003597          	auipc	a1,0x3
    80005de0:	89458593          	add	a1,a1,-1900 # 80008670 <etext+0x670>
    80005de4:	0001f517          	auipc	a0,0x1f
    80005de8:	34450513          	add	a0,a0,836 # 80025128 <disk+0x2128>
    80005dec:	ffffb097          	auipc	ra,0xffffb
    80005df0:	db6080e7          	jalr	-586(ra) # 80000ba2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005df4:	100017b7          	lui	a5,0x10001
    80005df8:	4398                	lw	a4,0(a5)
    80005dfa:	2701                	sext.w	a4,a4
    80005dfc:	747277b7          	lui	a5,0x74727
    80005e00:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e04:	0ef71f63          	bne	a4,a5,80005f02 <virtio_disk_init+0x12e>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e08:	100017b7          	lui	a5,0x10001
    80005e0c:	0791                	add	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005e0e:	439c                	lw	a5,0(a5)
    80005e10:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e12:	4705                	li	a4,1
    80005e14:	0ee79763          	bne	a5,a4,80005f02 <virtio_disk_init+0x12e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e18:	100017b7          	lui	a5,0x10001
    80005e1c:	07a1                	add	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005e1e:	439c                	lw	a5,0(a5)
    80005e20:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e22:	4709                	li	a4,2
    80005e24:	0ce79f63          	bne	a5,a4,80005f02 <virtio_disk_init+0x12e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e28:	100017b7          	lui	a5,0x10001
    80005e2c:	47d8                	lw	a4,12(a5)
    80005e2e:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e30:	554d47b7          	lui	a5,0x554d4
    80005e34:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e38:	0cf71563          	bne	a4,a5,80005f02 <virtio_disk_init+0x12e>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e3c:	100017b7          	lui	a5,0x10001
    80005e40:	4705                	li	a4,1
    80005e42:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e44:	470d                	li	a4,3
    80005e46:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e48:	10001737          	lui	a4,0x10001
    80005e4c:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005e4e:	c7ffe737          	lui	a4,0xc7ffe
    80005e52:	75f70713          	add	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e56:	8ef9                	and	a3,a3,a4
    80005e58:	10001737          	lui	a4,0x10001
    80005e5c:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e5e:	472d                	li	a4,11
    80005e60:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e62:	473d                	li	a4,15
    80005e64:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005e66:	100017b7          	lui	a5,0x10001
    80005e6a:	6705                	lui	a4,0x1
    80005e6c:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e6e:	100017b7          	lui	a5,0x10001
    80005e72:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e76:	100017b7          	lui	a5,0x10001
    80005e7a:	03478793          	add	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005e7e:	439c                	lw	a5,0(a5)
    80005e80:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e82:	cbc1                	beqz	a5,80005f12 <virtio_disk_init+0x13e>
  if(max < NUM)
    80005e84:	471d                	li	a4,7
    80005e86:	08f77e63          	bgeu	a4,a5,80005f22 <virtio_disk_init+0x14e>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e8a:	100017b7          	lui	a5,0x10001
    80005e8e:	4721                	li	a4,8
    80005e90:	df98                	sw	a4,56(a5)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005e92:	6609                	lui	a2,0x2
    80005e94:	4581                	li	a1,0
    80005e96:	0001d517          	auipc	a0,0x1d
    80005e9a:	16a50513          	add	a0,a0,362 # 80023000 <disk>
    80005e9e:	ffffb097          	auipc	ra,0xffffb
    80005ea2:	e90080e7          	jalr	-368(ra) # 80000d2e <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005ea6:	0001d697          	auipc	a3,0x1d
    80005eaa:	15a68693          	add	a3,a3,346 # 80023000 <disk>
    80005eae:	00c6d713          	srl	a4,a3,0xc
    80005eb2:	2701                	sext.w	a4,a4
    80005eb4:	100017b7          	lui	a5,0x10001
    80005eb8:	c3b8                	sw	a4,64(a5)
  disk.desc = (struct virtq_desc *) disk.pages;
    80005eba:	0001f797          	auipc	a5,0x1f
    80005ebe:	14678793          	add	a5,a5,326 # 80025000 <disk+0x2000>
    80005ec2:	e394                	sd	a3,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80005ec4:	0001d717          	auipc	a4,0x1d
    80005ec8:	1bc70713          	add	a4,a4,444 # 80023080 <disk+0x80>
    80005ecc:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80005ece:	0001e717          	auipc	a4,0x1e
    80005ed2:	13270713          	add	a4,a4,306 # 80024000 <disk+0x1000>
    80005ed6:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005ed8:	4705                	li	a4,1
    80005eda:	00e78c23          	sb	a4,24(a5)
    80005ede:	00e78ca3          	sb	a4,25(a5)
    80005ee2:	00e78d23          	sb	a4,26(a5)
    80005ee6:	00e78da3          	sb	a4,27(a5)
    80005eea:	00e78e23          	sb	a4,28(a5)
    80005eee:	00e78ea3          	sb	a4,29(a5)
    80005ef2:	00e78f23          	sb	a4,30(a5)
    80005ef6:	00e78fa3          	sb	a4,31(a5)
}
    80005efa:	60a2                	ld	ra,8(sp)
    80005efc:	6402                	ld	s0,0(sp)
    80005efe:	0141                	add	sp,sp,16
    80005f00:	8082                	ret
    panic("could not find virtio disk");
    80005f02:	00002517          	auipc	a0,0x2
    80005f06:	77e50513          	add	a0,a0,1918 # 80008680 <etext+0x680>
    80005f0a:	ffffa097          	auipc	ra,0xffffa
    80005f0e:	650080e7          	jalr	1616(ra) # 8000055a <panic>
    panic("virtio disk has no queue 0");
    80005f12:	00002517          	auipc	a0,0x2
    80005f16:	78e50513          	add	a0,a0,1934 # 800086a0 <etext+0x6a0>
    80005f1a:	ffffa097          	auipc	ra,0xffffa
    80005f1e:	640080e7          	jalr	1600(ra) # 8000055a <panic>
    panic("virtio disk max queue too short");
    80005f22:	00002517          	auipc	a0,0x2
    80005f26:	79e50513          	add	a0,a0,1950 # 800086c0 <etext+0x6c0>
    80005f2a:	ffffa097          	auipc	ra,0xffffa
    80005f2e:	630080e7          	jalr	1584(ra) # 8000055a <panic>

0000000080005f32 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f32:	7159                	add	sp,sp,-112
    80005f34:	f486                	sd	ra,104(sp)
    80005f36:	f0a2                	sd	s0,96(sp)
    80005f38:	eca6                	sd	s1,88(sp)
    80005f3a:	e8ca                	sd	s2,80(sp)
    80005f3c:	e4ce                	sd	s3,72(sp)
    80005f3e:	e0d2                	sd	s4,64(sp)
    80005f40:	fc56                	sd	s5,56(sp)
    80005f42:	f85a                	sd	s6,48(sp)
    80005f44:	f45e                	sd	s7,40(sp)
    80005f46:	f062                	sd	s8,32(sp)
    80005f48:	ec66                	sd	s9,24(sp)
    80005f4a:	1880                	add	s0,sp,112
    80005f4c:	8a2a                	mv	s4,a0
    80005f4e:	8cae                	mv	s9,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f50:	00c52c03          	lw	s8,12(a0)
    80005f54:	001c1c1b          	sllw	s8,s8,0x1
    80005f58:	1c02                	sll	s8,s8,0x20
    80005f5a:	020c5c13          	srl	s8,s8,0x20

  acquire(&disk.vdisk_lock);
    80005f5e:	0001f517          	auipc	a0,0x1f
    80005f62:	1ca50513          	add	a0,a0,458 # 80025128 <disk+0x2128>
    80005f66:	ffffb097          	auipc	ra,0xffffb
    80005f6a:	ccc080e7          	jalr	-820(ra) # 80000c32 <acquire>
  for(int i = 0; i < 3; i++){
    80005f6e:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005f70:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f72:	0001db97          	auipc	s7,0x1d
    80005f76:	08eb8b93          	add	s7,s7,142 # 80023000 <disk>
    80005f7a:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80005f7c:	4a8d                	li	s5,3
    80005f7e:	a88d                	j	80005ff0 <virtio_disk_rw+0xbe>
      disk.free[i] = 0;
    80005f80:	00fb8733          	add	a4,s7,a5
    80005f84:	975a                	add	a4,a4,s6
    80005f86:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005f8a:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005f8c:	0207c563          	bltz	a5,80005fb6 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80005f90:	2905                	addw	s2,s2,1
    80005f92:	0611                	add	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    80005f94:	1b590163          	beq	s2,s5,80006136 <virtio_disk_rw+0x204>
    idx[i] = alloc_desc();
    80005f98:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005f9a:	0001f717          	auipc	a4,0x1f
    80005f9e:	07e70713          	add	a4,a4,126 # 80025018 <disk+0x2018>
    80005fa2:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005fa4:	00074683          	lbu	a3,0(a4)
    80005fa8:	fee1                	bnez	a3,80005f80 <virtio_disk_rw+0x4e>
  for(int i = 0; i < NUM; i++){
    80005faa:	2785                	addw	a5,a5,1
    80005fac:	0705                	add	a4,a4,1
    80005fae:	fe979be3          	bne	a5,s1,80005fa4 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005fb2:	57fd                	li	a5,-1
    80005fb4:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005fb6:	03205163          	blez	s2,80005fd8 <virtio_disk_rw+0xa6>
        free_desc(idx[j]);
    80005fba:	f9042503          	lw	a0,-112(s0)
    80005fbe:	00000097          	auipc	ra,0x0
    80005fc2:	d7c080e7          	jalr	-644(ra) # 80005d3a <free_desc>
      for(int j = 0; j < i; j++)
    80005fc6:	4785                	li	a5,1
    80005fc8:	0127d863          	bge	a5,s2,80005fd8 <virtio_disk_rw+0xa6>
        free_desc(idx[j]);
    80005fcc:	f9442503          	lw	a0,-108(s0)
    80005fd0:	00000097          	auipc	ra,0x0
    80005fd4:	d6a080e7          	jalr	-662(ra) # 80005d3a <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fd8:	0001f597          	auipc	a1,0x1f
    80005fdc:	15058593          	add	a1,a1,336 # 80025128 <disk+0x2128>
    80005fe0:	0001f517          	auipc	a0,0x1f
    80005fe4:	03850513          	add	a0,a0,56 # 80025018 <disk+0x2018>
    80005fe8:	ffffc097          	auipc	ra,0xffffc
    80005fec:	10e080e7          	jalr	270(ra) # 800020f6 <sleep>
  for(int i = 0; i < 3; i++){
    80005ff0:	f9040613          	add	a2,s0,-112
    80005ff4:	894e                	mv	s2,s3
    80005ff6:	b74d                	j	80005f98 <virtio_disk_rw+0x66>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005ff8:	0001f717          	auipc	a4,0x1f
    80005ffc:	00873703          	ld	a4,8(a4) # 80025000 <disk+0x2000>
    80006000:	973e                	add	a4,a4,a5
    80006002:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006006:	0001d897          	auipc	a7,0x1d
    8000600a:	ffa88893          	add	a7,a7,-6 # 80023000 <disk>
    8000600e:	0001f717          	auipc	a4,0x1f
    80006012:	ff270713          	add	a4,a4,-14 # 80025000 <disk+0x2000>
    80006016:	6314                	ld	a3,0(a4)
    80006018:	96be                	add	a3,a3,a5
    8000601a:	00c6d583          	lhu	a1,12(a3)
    8000601e:	0015e593          	or	a1,a1,1
    80006022:	00b69623          	sh	a1,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006026:	f9842683          	lw	a3,-104(s0)
    8000602a:	630c                	ld	a1,0(a4)
    8000602c:	97ae                	add	a5,a5,a1
    8000602e:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006032:	20050593          	add	a1,a0,512
    80006036:	0592                	sll	a1,a1,0x4
    80006038:	95c6                	add	a1,a1,a7
    8000603a:	57fd                	li	a5,-1
    8000603c:	02f58823          	sb	a5,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006040:	00469793          	sll	a5,a3,0x4
    80006044:	00073803          	ld	a6,0(a4)
    80006048:	983e                	add	a6,a6,a5
    8000604a:	6689                	lui	a3,0x2
    8000604c:	03068693          	add	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006050:	96b2                	add	a3,a3,a2
    80006052:	96c6                	add	a3,a3,a7
    80006054:	00d83023          	sd	a3,0(a6)
  disk.desc[idx[2]].len = 1;
    80006058:	6314                	ld	a3,0(a4)
    8000605a:	96be                	add	a3,a3,a5
    8000605c:	4605                	li	a2,1
    8000605e:	c690                	sw	a2,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006060:	6314                	ld	a3,0(a4)
    80006062:	96be                	add	a3,a3,a5
    80006064:	4809                	li	a6,2
    80006066:	01069623          	sh	a6,12(a3)
  disk.desc[idx[2]].next = 0;
    8000606a:	6314                	ld	a3,0(a4)
    8000606c:	97b6                	add	a5,a5,a3
    8000606e:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006072:	00ca2223          	sw	a2,4(s4)
  disk.info[idx[0]].b = b;
    80006076:	0345b423          	sd	s4,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000607a:	6714                	ld	a3,8(a4)
    8000607c:	0026d783          	lhu	a5,2(a3)
    80006080:	8b9d                	and	a5,a5,7
    80006082:	0786                	sll	a5,a5,0x1
    80006084:	96be                	add	a3,a3,a5
    80006086:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000608a:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000608e:	6718                	ld	a4,8(a4)
    80006090:	00275783          	lhu	a5,2(a4)
    80006094:	2785                	addw	a5,a5,1
    80006096:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000609a:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000609e:	100017b7          	lui	a5,0x10001
    800060a2:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800060a6:	004a2783          	lw	a5,4(s4)
    800060aa:	02c79163          	bne	a5,a2,800060cc <virtio_disk_rw+0x19a>
    sleep(b, &disk.vdisk_lock);
    800060ae:	0001f917          	auipc	s2,0x1f
    800060b2:	07a90913          	add	s2,s2,122 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    800060b6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800060b8:	85ca                	mv	a1,s2
    800060ba:	8552                	mv	a0,s4
    800060bc:	ffffc097          	auipc	ra,0xffffc
    800060c0:	03a080e7          	jalr	58(ra) # 800020f6 <sleep>
  while(b->disk == 1) {
    800060c4:	004a2783          	lw	a5,4(s4)
    800060c8:	fe9788e3          	beq	a5,s1,800060b8 <virtio_disk_rw+0x186>
  }

  disk.info[idx[0]].b = 0;
    800060cc:	f9042903          	lw	s2,-112(s0)
    800060d0:	20090713          	add	a4,s2,512
    800060d4:	0712                	sll	a4,a4,0x4
    800060d6:	0001d797          	auipc	a5,0x1d
    800060da:	f2a78793          	add	a5,a5,-214 # 80023000 <disk>
    800060de:	97ba                	add	a5,a5,a4
    800060e0:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800060e4:	0001f997          	auipc	s3,0x1f
    800060e8:	f1c98993          	add	s3,s3,-228 # 80025000 <disk+0x2000>
    800060ec:	00491713          	sll	a4,s2,0x4
    800060f0:	0009b783          	ld	a5,0(s3)
    800060f4:	97ba                	add	a5,a5,a4
    800060f6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800060fa:	854a                	mv	a0,s2
    800060fc:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006100:	00000097          	auipc	ra,0x0
    80006104:	c3a080e7          	jalr	-966(ra) # 80005d3a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006108:	8885                	and	s1,s1,1
    8000610a:	f0ed                	bnez	s1,800060ec <virtio_disk_rw+0x1ba>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000610c:	0001f517          	auipc	a0,0x1f
    80006110:	01c50513          	add	a0,a0,28 # 80025128 <disk+0x2128>
    80006114:	ffffb097          	auipc	ra,0xffffb
    80006118:	bd2080e7          	jalr	-1070(ra) # 80000ce6 <release>
}
    8000611c:	70a6                	ld	ra,104(sp)
    8000611e:	7406                	ld	s0,96(sp)
    80006120:	64e6                	ld	s1,88(sp)
    80006122:	6946                	ld	s2,80(sp)
    80006124:	69a6                	ld	s3,72(sp)
    80006126:	6a06                	ld	s4,64(sp)
    80006128:	7ae2                	ld	s5,56(sp)
    8000612a:	7b42                	ld	s6,48(sp)
    8000612c:	7ba2                	ld	s7,40(sp)
    8000612e:	7c02                	ld	s8,32(sp)
    80006130:	6ce2                	ld	s9,24(sp)
    80006132:	6165                	add	sp,sp,112
    80006134:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006136:	f9042503          	lw	a0,-112(s0)
    8000613a:	00451613          	sll	a2,a0,0x4
  if(write)
    8000613e:	0001d597          	auipc	a1,0x1d
    80006142:	ec258593          	add	a1,a1,-318 # 80023000 <disk>
    80006146:	20050793          	add	a5,a0,512
    8000614a:	0792                	sll	a5,a5,0x4
    8000614c:	97ae                	add	a5,a5,a1
    8000614e:	01903733          	snez	a4,s9
    80006152:	0ae7a423          	sw	a4,168(a5)
  buf0->reserved = 0;
    80006156:	0a07a623          	sw	zero,172(a5)
  buf0->sector = sector;
    8000615a:	0b87b823          	sd	s8,176(a5)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000615e:	0001f717          	auipc	a4,0x1f
    80006162:	ea270713          	add	a4,a4,-350 # 80025000 <disk+0x2000>
    80006166:	6314                	ld	a3,0(a4)
    80006168:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000616a:	6789                	lui	a5,0x2
    8000616c:	0a878793          	add	a5,a5,168 # 20a8 <_entry-0x7fffdf58>
    80006170:	97b2                	add	a5,a5,a2
    80006172:	97ae                	add	a5,a5,a1
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006174:	e29c                	sd	a5,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006176:	631c                	ld	a5,0(a4)
    80006178:	97b2                	add	a5,a5,a2
    8000617a:	46c1                	li	a3,16
    8000617c:	c794                	sw	a3,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000617e:	631c                	ld	a5,0(a4)
    80006180:	97b2                	add	a5,a5,a2
    80006182:	4685                	li	a3,1
    80006184:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006188:	f9442783          	lw	a5,-108(s0)
    8000618c:	6314                	ld	a3,0(a4)
    8000618e:	96b2                	add	a3,a3,a2
    80006190:	00f69723          	sh	a5,14(a3)
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006194:	0792                	sll	a5,a5,0x4
    80006196:	6314                	ld	a3,0(a4)
    80006198:	96be                	add	a3,a3,a5
    8000619a:	058a0593          	add	a1,s4,88
    8000619e:	e28c                	sd	a1,0(a3)
  disk.desc[idx[1]].len = BSIZE;
    800061a0:	6318                	ld	a4,0(a4)
    800061a2:	973e                	add	a4,a4,a5
    800061a4:	40000693          	li	a3,1024
    800061a8:	c714                	sw	a3,8(a4)
  if(write)
    800061aa:	e40c97e3          	bnez	s9,80005ff8 <virtio_disk_rw+0xc6>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800061ae:	0001f717          	auipc	a4,0x1f
    800061b2:	e5273703          	ld	a4,-430(a4) # 80025000 <disk+0x2000>
    800061b6:	973e                	add	a4,a4,a5
    800061b8:	4689                	li	a3,2
    800061ba:	00d71623          	sh	a3,12(a4)
    800061be:	b5a1                	j	80006006 <virtio_disk_rw+0xd4>

00000000800061c0 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061c0:	1101                	add	sp,sp,-32
    800061c2:	ec06                	sd	ra,24(sp)
    800061c4:	e822                	sd	s0,16(sp)
    800061c6:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061c8:	0001f517          	auipc	a0,0x1f
    800061cc:	f6050513          	add	a0,a0,-160 # 80025128 <disk+0x2128>
    800061d0:	ffffb097          	auipc	ra,0xffffb
    800061d4:	a62080e7          	jalr	-1438(ra) # 80000c32 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800061d8:	100017b7          	lui	a5,0x10001
    800061dc:	53b8                	lw	a4,96(a5)
    800061de:	8b0d                	and	a4,a4,3
    800061e0:	100017b7          	lui	a5,0x10001
    800061e4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800061e6:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800061ea:	0001f797          	auipc	a5,0x1f
    800061ee:	e1678793          	add	a5,a5,-490 # 80025000 <disk+0x2000>
    800061f2:	6b94                	ld	a3,16(a5)
    800061f4:	0207d703          	lhu	a4,32(a5)
    800061f8:	0026d783          	lhu	a5,2(a3)
    800061fc:	06f70563          	beq	a4,a5,80006266 <virtio_disk_intr+0xa6>
    80006200:	e426                	sd	s1,8(sp)
    80006202:	e04a                	sd	s2,0(sp)
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006204:	0001d917          	auipc	s2,0x1d
    80006208:	dfc90913          	add	s2,s2,-516 # 80023000 <disk>
    8000620c:	0001f497          	auipc	s1,0x1f
    80006210:	df448493          	add	s1,s1,-524 # 80025000 <disk+0x2000>
    __sync_synchronize();
    80006214:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006218:	6898                	ld	a4,16(s1)
    8000621a:	0204d783          	lhu	a5,32(s1)
    8000621e:	8b9d                	and	a5,a5,7
    80006220:	078e                	sll	a5,a5,0x3
    80006222:	97ba                	add	a5,a5,a4
    80006224:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006226:	20078713          	add	a4,a5,512
    8000622a:	0712                	sll	a4,a4,0x4
    8000622c:	974a                	add	a4,a4,s2
    8000622e:	03074703          	lbu	a4,48(a4)
    80006232:	e731                	bnez	a4,8000627e <virtio_disk_intr+0xbe>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006234:	20078793          	add	a5,a5,512
    80006238:	0792                	sll	a5,a5,0x4
    8000623a:	97ca                	add	a5,a5,s2
    8000623c:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    8000623e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006242:	ffffc097          	auipc	ra,0xffffc
    80006246:	040080e7          	jalr	64(ra) # 80002282 <wakeup>

    disk.used_idx += 1;
    8000624a:	0204d783          	lhu	a5,32(s1)
    8000624e:	2785                	addw	a5,a5,1
    80006250:	17c2                	sll	a5,a5,0x30
    80006252:	93c1                	srl	a5,a5,0x30
    80006254:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006258:	6898                	ld	a4,16(s1)
    8000625a:	00275703          	lhu	a4,2(a4)
    8000625e:	faf71be3          	bne	a4,a5,80006214 <virtio_disk_intr+0x54>
    80006262:	64a2                	ld	s1,8(sp)
    80006264:	6902                	ld	s2,0(sp)
  }

  release(&disk.vdisk_lock);
    80006266:	0001f517          	auipc	a0,0x1f
    8000626a:	ec250513          	add	a0,a0,-318 # 80025128 <disk+0x2128>
    8000626e:	ffffb097          	auipc	ra,0xffffb
    80006272:	a78080e7          	jalr	-1416(ra) # 80000ce6 <release>
}
    80006276:	60e2                	ld	ra,24(sp)
    80006278:	6442                	ld	s0,16(sp)
    8000627a:	6105                	add	sp,sp,32
    8000627c:	8082                	ret
      panic("virtio_disk_intr status");
    8000627e:	00002517          	auipc	a0,0x2
    80006282:	46250513          	add	a0,a0,1122 # 800086e0 <etext+0x6e0>
    80006286:	ffffa097          	auipc	ra,0xffffa
    8000628a:	2d4080e7          	jalr	724(ra) # 8000055a <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
