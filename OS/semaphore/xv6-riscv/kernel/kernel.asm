
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
    80000066:	fee78793          	add	a5,a5,-18 # 80006050 <timervec>
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
    80000496:	30e78793          	add	a5,a5,782 # 800217a0 <devsw>
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
    800004d4:	25860613          	add	a2,a2,600 # 80008728 <digits>
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
    80000606:	126a8a93          	add	s5,s5,294 # 80008728 <digits>
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
    80000f12:	00002097          	auipc	ra,0x2
    80000f16:	988080e7          	jalr	-1656(ra) # 8000289a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f1a:	00005097          	auipc	ra,0x5
    80000f1e:	17a080e7          	jalr	378(ra) # 80006094 <plicinithart>
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
    80000f8a:	00002097          	auipc	ra,0x2
    80000f8e:	8e8080e7          	jalr	-1816(ra) # 80002872 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f92:	00002097          	auipc	ra,0x2
    80000f96:	908080e7          	jalr	-1784(ra) # 8000289a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9a:	00005097          	auipc	ra,0x5
    80000f9e:	0e0080e7          	jalr	224(ra) # 8000607a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa2:	00005097          	auipc	ra,0x5
    80000fa6:	0f2080e7          	jalr	242(ra) # 80006094 <plicinithart>
    binit();         // buffer cache
    80000faa:	00002097          	auipc	ra,0x2
    80000fae:	042080e7          	jalr	66(ra) # 80002fec <binit>
    iinit();         // inode table
    80000fb2:	00002097          	auipc	ra,0x2
    80000fb6:	6ce080e7          	jalr	1742(ra) # 80003680 <iinit>
    fileinit();      // file table
    80000fba:	00003097          	auipc	ra,0x3
    80000fbe:	6de080e7          	jalr	1758(ra) # 80004698 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc2:	00005097          	auipc	ra,0x5
    80000fc6:	1f2080e7          	jalr	498(ra) # 800061b4 <virtio_disk_init>
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
    800018c2:	ff4df937          	lui	s2,0xff4df
    800018c6:	9bd90913          	add	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b89bd>
    800018ca:	0936                	sll	s2,s2,0xd
    800018cc:	6f590913          	add	s2,s2,1781
    800018d0:	0936                	sll	s2,s2,0xd
    800018d2:	bd390913          	add	s2,s2,-1069
    800018d6:	0932                	sll	s2,s2,0xc
    800018d8:	7a790913          	add	s2,s2,1959
    800018dc:	040009b7          	lui	s3,0x4000
    800018e0:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018e2:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e4:	00016a97          	auipc	s5,0x16
    800018e8:	9eca8a93          	add	s5,s5,-1556 # 800172d0 <tickslock>
    char *pa = kalloc();
    800018ec:	fffff097          	auipc	ra,0xfffff
    800018f0:	256080e7          	jalr	598(ra) # 80000b42 <kalloc>
    800018f4:	862a                	mv	a2,a0
    if(pa == 0)
    800018f6:	c121                	beqz	a0,80001936 <proc_mapstacks+0x94>
    uint64 va = KSTACK((int) (p - proc));
    800018f8:	416485b3          	sub	a1,s1,s6
    800018fc:	8591                	sra	a1,a1,0x4
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
    8000191a:	17048493          	add	s1,s1,368
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
    8000199c:	ff4df937          	lui	s2,0xff4df
    800019a0:	9bd90913          	add	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b89bd>
    800019a4:	0936                	sll	s2,s2,0xd
    800019a6:	6f590913          	add	s2,s2,1781
    800019aa:	0936                	sll	s2,s2,0xd
    800019ac:	bd390913          	add	s2,s2,-1069
    800019b0:	0932                	sll	s2,s2,0xc
    800019b2:	7a790913          	add	s2,s2,1959
    800019b6:	040009b7          	lui	s3,0x4000
    800019ba:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019bc:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019be:	00016a17          	auipc	s4,0x16
    800019c2:	912a0a13          	add	s4,s4,-1774 # 800172d0 <tickslock>
      initlock(&p->lock, "proc");
    800019c6:	85da                	mv	a1,s6
    800019c8:	8526                	mv	a0,s1
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	1d8080e7          	jalr	472(ra) # 80000ba2 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    800019d2:	415487b3          	sub	a5,s1,s5
    800019d6:	8791                	sra	a5,a5,0x4
    800019d8:	032787b3          	mul	a5,a5,s2
    800019dc:	2785                	addw	a5,a5,1
    800019de:	00d7979b          	sllw	a5,a5,0xd
    800019e2:	40f987b3          	sub	a5,s3,a5
    800019e6:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019e8:	17048493          	add	s1,s1,368
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
    80001a84:	df07a783          	lw	a5,-528(a5) # 80008870 <first.1>
    80001a88:	eb89                	bnez	a5,80001a9a <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a8a:	00001097          	auipc	ra,0x1
    80001a8e:	e28080e7          	jalr	-472(ra) # 800028b2 <usertrapret>
}
    80001a92:	60a2                	ld	ra,8(sp)
    80001a94:	6402                	ld	s0,0(sp)
    80001a96:	0141                	add	sp,sp,16
    80001a98:	8082                	ret
    first = 0;
    80001a9a:	00007797          	auipc	a5,0x7
    80001a9e:	dc07ab23          	sw	zero,-554(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001aa2:	4505                	li	a0,1
    80001aa4:	00002097          	auipc	ra,0x2
    80001aa8:	b5c080e7          	jalr	-1188(ra) # 80003600 <fsinit>
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
    80001ad0:	da878793          	add	a5,a5,-600 # 80008874 <nextpid>
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
    80001c52:	68290913          	add	s2,s2,1666 # 800172d0 <tickslock>
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
    80001c6e:	17048493          	add	s1,s1,368
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
    80001d2c:	b5858593          	add	a1,a1,-1192 # 80008880 <initcode>
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
    80001d6a:	2e0080e7          	jalr	736(ra) # 80004046 <namei>
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
    80001eb4:	00003097          	auipc	ra,0x3
    80001eb8:	876080e7          	jalr	-1930(ra) # 8000472a <filedup>
    80001ebc:	00a93023          	sd	a0,0(s2)
    80001ec0:	b7e5                	j	80001ea8 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ec2:	150ab503          	ld	a0,336(s5)
    80001ec6:	00002097          	auipc	ra,0x2
    80001eca:	970080e7          	jalr	-1680(ra) # 80003836 <idup>
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
    for(p = &proc[NPROC-1]; p >= proc; p--) {
    80001f88:	0000f917          	auipc	s2,0xf
    80001f8c:	5d890913          	add	s2,s2,1496 # 80011560 <cpus+0x290>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f90:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f94:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f98:	10079073          	csrw	sstatus,a5
    80001f9c:	00015497          	auipc	s1,0x15
    80001fa0:	1c448493          	add	s1,s1,452 # 80017160 <proc+0x5a90>
    80001fa4:	a811                	j	80001fb8 <scheduler+0x74>
      release(&p->lock);
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	fffff097          	auipc	ra,0xfffff
    80001fac:	d3e080e7          	jalr	-706(ra) # 80000ce6 <release>
    for(p = &proc[NPROC-1]; p >= proc; p--) {
    80001fb0:	e9048493          	add	s1,s1,-368
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
    80002198:	13c98993          	add	s3,s3,316 # 800172d0 <tickslock>
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
    80002222:	17048493          	add	s1,s1,368
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
    800022a6:	02e90913          	add	s2,s2,46 # 800172d0 <tickslock>
    800022aa:	a811                	j	800022be <wakeup+0x3c>
      }
      release(&p->lock);
    800022ac:	8526                	mv	a0,s1
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	a38080e7          	jalr	-1480(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022b6:	17048493          	add	s1,s1,368
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
    8000231e:	fb698993          	add	s3,s3,-74 # 800172d0 <tickslock>
    80002322:	a029                	j	8000232c <reparent+0x34>
    80002324:	17048493          	add	s1,s1,368
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
    80002396:	3ea080e7          	jalr	1002(ra) # 8000477c <fileclose>
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
    800023ae:	e9c080e7          	jalr	-356(ra) # 80004246 <begin_op>
  iput(p->cwd);
    800023b2:	1509b503          	ld	a0,336(s3)
    800023b6:	00001097          	auipc	ra,0x1
    800023ba:	67c080e7          	jalr	1660(ra) # 80003a32 <iput>
  end_op();
    800023be:	00002097          	auipc	ra,0x2
    800023c2:	f02080e7          	jalr	-254(ra) # 800042c0 <end_op>
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
    80002444:	e9098993          	add	s3,s3,-368 # 800172d0 <tickslock>
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
    80002462:	17048493          	add	s1,s1,368
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
    80002578:	eb490913          	add	s2,s2,-332 # 80017428 <bcache+0x140>
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
    8000259a:	1aab8b93          	add	s7,s7,426 # 80008740 <states.0>
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
    800025b8:	17048493          	add	s1,s1,368
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

0000000080002660 <initsema>:
#include "kernel/riscv.h"
#include "kernel/spinlock.h"
#include "kernel/semaphore.h"
#include "kernel/defs.h"

void initsema(struct semaphore* s, int count) {
    80002660:	1141                	add	sp,sp,-16
    80002662:	e406                	sd	ra,8(sp)
    80002664:	e022                	sd	s0,0(sp)
    80002666:	0800                	add	s0,sp,16
  s->value = count;
    80002668:	c10c                	sw	a1,0(a0)
  initlock(&s->lk, "Counting Semaphore");
    8000266a:	00006597          	auipc	a1,0x6
    8000266e:	c3658593          	add	a1,a1,-970 # 800082a0 <etext+0x2a0>
    80002672:	0521                	add	a0,a0,8
    80002674:	ffffe097          	auipc	ra,0xffffe
    80002678:	52e080e7          	jalr	1326(ra) # 80000ba2 <initlock>
}
    8000267c:	60a2                	ld	ra,8(sp)
    8000267e:	6402                	ld	s0,0(sp)
    80002680:	0141                	add	sp,sp,16
    80002682:	8082                	ret

0000000080002684 <downsema>:

int downsema(struct semaphore* s) {
    80002684:	1101                	add	sp,sp,-32
    80002686:	ec06                	sd	ra,24(sp)
    80002688:	e822                	sd	s0,16(sp)
    8000268a:	e426                	sd	s1,8(sp)
    8000268c:	e04a                	sd	s2,0(sp)
    8000268e:	1000                	add	s0,sp,32
    80002690:	84aa                	mv	s1,a0
  acquire(&s->lk);
    80002692:	00850913          	add	s2,a0,8
    80002696:	854a                	mv	a0,s2
    80002698:	ffffe097          	auipc	ra,0xffffe
    8000269c:	59a080e7          	jalr	1434(ra) # 80000c32 <acquire>
  while (s->value <=0)
    800026a0:	409c                	lw	a5,0(s1)
    800026a2:	00f04b63          	bgtz	a5,800026b8 <downsema+0x34>
    sleep(s,&s->lk);
    800026a6:	85ca                	mv	a1,s2
    800026a8:	8526                	mv	a0,s1
    800026aa:	00000097          	auipc	ra,0x0
    800026ae:	a4c080e7          	jalr	-1460(ra) # 800020f6 <sleep>
  while (s->value <=0)
    800026b2:	409c                	lw	a5,0(s1)
    800026b4:	fef059e3          	blez	a5,800026a6 <downsema+0x22>
  s->value--;
    800026b8:	37fd                	addw	a5,a5,-1
    800026ba:	c09c                	sw	a5,0(s1)
  release(&s->lk);
    800026bc:	854a                	mv	a0,s2
    800026be:	ffffe097          	auipc	ra,0xffffe
    800026c2:	628080e7          	jalr	1576(ra) # 80000ce6 <release>
  return s->value;
}
    800026c6:	4088                	lw	a0,0(s1)
    800026c8:	60e2                	ld	ra,24(sp)
    800026ca:	6442                	ld	s0,16(sp)
    800026cc:	64a2                	ld	s1,8(sp)
    800026ce:	6902                	ld	s2,0(sp)
    800026d0:	6105                	add	sp,sp,32
    800026d2:	8082                	ret

00000000800026d4 <upsema>:

int upsema(struct semaphore* s) {
    800026d4:	1101                	add	sp,sp,-32
    800026d6:	ec06                	sd	ra,24(sp)
    800026d8:	e822                	sd	s0,16(sp)
    800026da:	e426                	sd	s1,8(sp)
    800026dc:	e04a                	sd	s2,0(sp)
    800026de:	1000                	add	s0,sp,32
    800026e0:	84aa                	mv	s1,a0
  acquire(&s->lk);
    800026e2:	00850913          	add	s2,a0,8
    800026e6:	854a                	mv	a0,s2
    800026e8:	ffffe097          	auipc	ra,0xffffe
    800026ec:	54a080e7          	jalr	1354(ra) # 80000c32 <acquire>
  s->value++;
    800026f0:	409c                	lw	a5,0(s1)
    800026f2:	2785                	addw	a5,a5,1
    800026f4:	c09c                	sw	a5,0(s1)
  wakeup(s);
    800026f6:	8526                	mv	a0,s1
    800026f8:	00000097          	auipc	ra,0x0
    800026fc:	b8a080e7          	jalr	-1142(ra) # 80002282 <wakeup>
  release(&s->lk);
    80002700:	854a                	mv	a0,s2
    80002702:	ffffe097          	auipc	ra,0xffffe
    80002706:	5e4080e7          	jalr	1508(ra) # 80000ce6 <release>
  return s->value;
}
    8000270a:	4088                	lw	a0,0(s1)
    8000270c:	60e2                	ld	ra,24(sp)
    8000270e:	6442                	ld	s0,16(sp)
    80002710:	64a2                	ld	s1,8(sp)
    80002712:	6902                	ld	s2,0(sp)
    80002714:	6105                	add	sp,sp,32
    80002716:	8082                	ret

0000000080002718 <initrwsema>:

void initrwsema(struct rwsemaphore *rws)
{
    80002718:	1141                	add	sp,sp,-16
    8000271a:	e406                	sd	ra,8(sp)
    8000271c:	e022                	sd	s0,0(sp)
    8000271e:	0800                	add	s0,sp,16
   rws->readers = 0;
    80002720:	00052023          	sw	zero,0(a0)
   rws->writers = 0;
    80002724:	00052223          	sw	zero,4(a0)
   initlock(&rws->lk, "Read/Write Semaphore");
    80002728:	00006597          	auipc	a1,0x6
    8000272c:	b9058593          	add	a1,a1,-1136 # 800082b8 <etext+0x2b8>
    80002730:	0521                	add	a0,a0,8
    80002732:	ffffe097          	auipc	ra,0xffffe
    80002736:	470080e7          	jalr	1136(ra) # 80000ba2 <initlock>
}
    8000273a:	60a2                	ld	ra,8(sp)
    8000273c:	6402                	ld	s0,0(sp)
    8000273e:	0141                	add	sp,sp,16
    80002740:	8082                	ret

0000000080002742 <downreadsema>:

// A Reader enters room
int downreadsema(struct rwsemaphore *rws)
{
    80002742:	1101                	add	sp,sp,-32
    80002744:	ec06                	sd	ra,24(sp)
    80002746:	e822                	sd	s0,16(sp)
    80002748:	e426                	sd	s1,8(sp)
    8000274a:	e04a                	sd	s2,0(sp)
    8000274c:	1000                	add	s0,sp,32
    8000274e:	84aa                	mv	s1,a0
    acquire(&rws->lk);
    80002750:	00850913          	add	s2,a0,8
    80002754:	854a                	mv	a0,s2
    80002756:	ffffe097          	auipc	ra,0xffffe
    8000275a:	4dc080e7          	jalr	1244(ra) # 80000c32 <acquire>
    while (rws->writers > 0) {
    8000275e:	40dc                	lw	a5,4(s1)
    80002760:	00f05b63          	blez	a5,80002776 <downreadsema+0x34>
        sleep(rws, &rws->lk); // Wait for no writers
    80002764:	85ca                	mv	a1,s2
    80002766:	8526                	mv	a0,s1
    80002768:	00000097          	auipc	ra,0x0
    8000276c:	98e080e7          	jalr	-1650(ra) # 800020f6 <sleep>
    while (rws->writers > 0) {
    80002770:	40dc                	lw	a5,4(s1)
    80002772:	fef049e3          	bgtz	a5,80002764 <downreadsema+0x22>
    }
    rws->readers++;
    80002776:	409c                	lw	a5,0(s1)
    80002778:	2785                	addw	a5,a5,1
    8000277a:	c09c                	sw	a5,0(s1)
    release(&rws->lk);
    8000277c:	854a                	mv	a0,s2
    8000277e:	ffffe097          	auipc	ra,0xffffe
    80002782:	568080e7          	jalr	1384(ra) # 80000ce6 <release>
    return rws->readers;
}
    80002786:	4088                	lw	a0,0(s1)
    80002788:	60e2                	ld	ra,24(sp)
    8000278a:	6442                	ld	s0,16(sp)
    8000278c:	64a2                	ld	s1,8(sp)
    8000278e:	6902                	ld	s2,0(sp)
    80002790:	6105                	add	sp,sp,32
    80002792:	8082                	ret

0000000080002794 <upreadsema>:

// A Reader exits room
int upreadsema(struct rwsemaphore *rws)
{
    80002794:	1101                	add	sp,sp,-32
    80002796:	ec06                	sd	ra,24(sp)
    80002798:	e822                	sd	s0,16(sp)
    8000279a:	e426                	sd	s1,8(sp)
    8000279c:	e04a                	sd	s2,0(sp)
    8000279e:	1000                	add	s0,sp,32
    800027a0:	84aa                	mv	s1,a0
    acquire(&rws->lk);
    800027a2:	00850913          	add	s2,a0,8
    800027a6:	854a                	mv	a0,s2
    800027a8:	ffffe097          	auipc	ra,0xffffe
    800027ac:	48a080e7          	jalr	1162(ra) # 80000c32 <acquire>
    rws->readers--;
    800027b0:	409c                	lw	a5,0(s1)
    800027b2:	37fd                	addw	a5,a5,-1
    800027b4:	0007871b          	sext.w	a4,a5
    800027b8:	c09c                	sw	a5,0(s1)
    if (rws->readers == 0) {
    800027ba:	cf09                	beqz	a4,800027d4 <upreadsema+0x40>
        wakeup(rws); // Wake up waiting writers
    }
    release(&rws->lk);
    800027bc:	854a                	mv	a0,s2
    800027be:	ffffe097          	auipc	ra,0xffffe
    800027c2:	528080e7          	jalr	1320(ra) # 80000ce6 <release>
    return rws->readers;
}
    800027c6:	4088                	lw	a0,0(s1)
    800027c8:	60e2                	ld	ra,24(sp)
    800027ca:	6442                	ld	s0,16(sp)
    800027cc:	64a2                	ld	s1,8(sp)
    800027ce:	6902                	ld	s2,0(sp)
    800027d0:	6105                	add	sp,sp,32
    800027d2:	8082                	ret
        wakeup(rws); // Wake up waiting writers
    800027d4:	8526                	mv	a0,s1
    800027d6:	00000097          	auipc	ra,0x0
    800027da:	aac080e7          	jalr	-1364(ra) # 80002282 <wakeup>
    800027de:	bff9                	j	800027bc <upreadsema+0x28>

00000000800027e0 <downwritesema>:

// A Writer enters room
void downwritesema(struct rwsemaphore *rws)
{
    800027e0:	1101                	add	sp,sp,-32
    800027e2:	ec06                	sd	ra,24(sp)
    800027e4:	e822                	sd	s0,16(sp)
    800027e6:	e426                	sd	s1,8(sp)
    800027e8:	e04a                	sd	s2,0(sp)
    800027ea:	1000                	add	s0,sp,32
    800027ec:	84aa                	mv	s1,a0
    acquire(&rws->lk);
    800027ee:	00850913          	add	s2,a0,8
    800027f2:	854a                	mv	a0,s2
    800027f4:	ffffe097          	auipc	ra,0xffffe
    800027f8:	43e080e7          	jalr	1086(ra) # 80000c32 <acquire>
    while (rws->writers > 0 || rws->readers > 0) {
    800027fc:	a039                	j	8000280a <downwritesema+0x2a>
        sleep(rws, &rws->lk);
    800027fe:	85ca                	mv	a1,s2
    80002800:	8526                	mv	a0,s1
    80002802:	00000097          	auipc	ra,0x0
    80002806:	8f4080e7          	jalr	-1804(ra) # 800020f6 <sleep>
    while (rws->writers > 0 || rws->readers > 0) {
    8000280a:	40dc                	lw	a5,4(s1)
    8000280c:	fef049e3          	bgtz	a5,800027fe <downwritesema+0x1e>
    80002810:	4098                	lw	a4,0(s1)
    80002812:	fee046e3          	bgtz	a4,800027fe <downwritesema+0x1e>
    }
    rws->writers++;
    80002816:	2785                	addw	a5,a5,1
    80002818:	c0dc                	sw	a5,4(s1)
    release(&rws->lk);
    8000281a:	854a                	mv	a0,s2
    8000281c:	ffffe097          	auipc	ra,0xffffe
    80002820:	4ca080e7          	jalr	1226(ra) # 80000ce6 <release>
}
    80002824:	60e2                	ld	ra,24(sp)
    80002826:	6442                	ld	s0,16(sp)
    80002828:	64a2                	ld	s1,8(sp)
    8000282a:	6902                	ld	s2,0(sp)
    8000282c:	6105                	add	sp,sp,32
    8000282e:	8082                	ret

0000000080002830 <upwritesema>:

// A writer exits room
void upwritesema(struct rwsemaphore *rws)
{
    80002830:	1101                	add	sp,sp,-32
    80002832:	ec06                	sd	ra,24(sp)
    80002834:	e822                	sd	s0,16(sp)
    80002836:	e426                	sd	s1,8(sp)
    80002838:	e04a                	sd	s2,0(sp)
    8000283a:	1000                	add	s0,sp,32
    8000283c:	84aa                	mv	s1,a0
    acquire(&rws->lk);
    8000283e:	00850913          	add	s2,a0,8
    80002842:	854a                	mv	a0,s2
    80002844:	ffffe097          	auipc	ra,0xffffe
    80002848:	3ee080e7          	jalr	1006(ra) # 80000c32 <acquire>
    rws->writers--;
    8000284c:	40dc                	lw	a5,4(s1)
    8000284e:	37fd                	addw	a5,a5,-1
    80002850:	c0dc                	sw	a5,4(s1)
    wakeup(rws);
    80002852:	8526                	mv	a0,s1
    80002854:	00000097          	auipc	ra,0x0
    80002858:	a2e080e7          	jalr	-1490(ra) # 80002282 <wakeup>
    release(&rws->lk);
    8000285c:	854a                	mv	a0,s2
    8000285e:	ffffe097          	auipc	ra,0xffffe
    80002862:	488080e7          	jalr	1160(ra) # 80000ce6 <release>
}
    80002866:	60e2                	ld	ra,24(sp)
    80002868:	6442                	ld	s0,16(sp)
    8000286a:	64a2                	ld	s1,8(sp)
    8000286c:	6902                	ld	s2,0(sp)
    8000286e:	6105                	add	sp,sp,32
    80002870:	8082                	ret

0000000080002872 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002872:	1141                	add	sp,sp,-16
    80002874:	e406                	sd	ra,8(sp)
    80002876:	e022                	sd	s0,0(sp)
    80002878:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    8000287a:	00006597          	auipc	a1,0x6
    8000287e:	a5658593          	add	a1,a1,-1450 # 800082d0 <etext+0x2d0>
    80002882:	00015517          	auipc	a0,0x15
    80002886:	a4e50513          	add	a0,a0,-1458 # 800172d0 <tickslock>
    8000288a:	ffffe097          	auipc	ra,0xffffe
    8000288e:	318080e7          	jalr	792(ra) # 80000ba2 <initlock>
}
    80002892:	60a2                	ld	ra,8(sp)
    80002894:	6402                	ld	s0,0(sp)
    80002896:	0141                	add	sp,sp,16
    80002898:	8082                	ret

000000008000289a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000289a:	1141                	add	sp,sp,-16
    8000289c:	e422                	sd	s0,8(sp)
    8000289e:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028a0:	00003797          	auipc	a5,0x3
    800028a4:	72078793          	add	a5,a5,1824 # 80005fc0 <kernelvec>
    800028a8:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028ac:	6422                	ld	s0,8(sp)
    800028ae:	0141                	add	sp,sp,16
    800028b0:	8082                	ret

00000000800028b2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028b2:	1141                	add	sp,sp,-16
    800028b4:	e406                	sd	ra,8(sp)
    800028b6:	e022                	sd	s0,0(sp)
    800028b8:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    800028ba:	fffff097          	auipc	ra,0xfffff
    800028be:	176080e7          	jalr	374(ra) # 80001a30 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028c2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028c6:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028c8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800028cc:	00004697          	auipc	a3,0x4
    800028d0:	73468693          	add	a3,a3,1844 # 80007000 <_trampoline>
    800028d4:	00004717          	auipc	a4,0x4
    800028d8:	72c70713          	add	a4,a4,1836 # 80007000 <_trampoline>
    800028dc:	8f15                	sub	a4,a4,a3
    800028de:	040007b7          	lui	a5,0x4000
    800028e2:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800028e4:	07b2                	sll	a5,a5,0xc
    800028e6:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028e8:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028ec:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028ee:	18002673          	csrr	a2,satp
    800028f2:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028f4:	6d30                	ld	a2,88(a0)
    800028f6:	6138                	ld	a4,64(a0)
    800028f8:	6585                	lui	a1,0x1
    800028fa:	972e                	add	a4,a4,a1
    800028fc:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800028fe:	6d38                	ld	a4,88(a0)
    80002900:	00000617          	auipc	a2,0x0
    80002904:	14060613          	add	a2,a2,320 # 80002a40 <usertrap>
    80002908:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000290a:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000290c:	8612                	mv	a2,tp
    8000290e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002910:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002914:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002918:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000291c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002920:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002922:	6f18                	ld	a4,24(a4)
    80002924:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002928:	692c                	ld	a1,80(a0)
    8000292a:	81b1                	srl	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000292c:	00004717          	auipc	a4,0x4
    80002930:	76470713          	add	a4,a4,1892 # 80007090 <userret>
    80002934:	8f15                	sub	a4,a4,a3
    80002936:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002938:	577d                	li	a4,-1
    8000293a:	177e                	sll	a4,a4,0x3f
    8000293c:	8dd9                	or	a1,a1,a4
    8000293e:	02000537          	lui	a0,0x2000
    80002942:	157d                	add	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    80002944:	0536                	sll	a0,a0,0xd
    80002946:	9782                	jalr	a5
}
    80002948:	60a2                	ld	ra,8(sp)
    8000294a:	6402                	ld	s0,0(sp)
    8000294c:	0141                	add	sp,sp,16
    8000294e:	8082                	ret

0000000080002950 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002950:	1101                	add	sp,sp,-32
    80002952:	ec06                	sd	ra,24(sp)
    80002954:	e822                	sd	s0,16(sp)
    80002956:	e426                	sd	s1,8(sp)
    80002958:	1000                	add	s0,sp,32
  acquire(&tickslock);
    8000295a:	00015497          	auipc	s1,0x15
    8000295e:	97648493          	add	s1,s1,-1674 # 800172d0 <tickslock>
    80002962:	8526                	mv	a0,s1
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	2ce080e7          	jalr	718(ra) # 80000c32 <acquire>
  ticks++;
    8000296c:	00006517          	auipc	a0,0x6
    80002970:	6c450513          	add	a0,a0,1732 # 80009030 <ticks>
    80002974:	411c                	lw	a5,0(a0)
    80002976:	2785                	addw	a5,a5,1
    80002978:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000297a:	00000097          	auipc	ra,0x0
    8000297e:	908080e7          	jalr	-1784(ra) # 80002282 <wakeup>
  release(&tickslock);
    80002982:	8526                	mv	a0,s1
    80002984:	ffffe097          	auipc	ra,0xffffe
    80002988:	362080e7          	jalr	866(ra) # 80000ce6 <release>
}
    8000298c:	60e2                	ld	ra,24(sp)
    8000298e:	6442                	ld	s0,16(sp)
    80002990:	64a2                	ld	s1,8(sp)
    80002992:	6105                	add	sp,sp,32
    80002994:	8082                	ret

0000000080002996 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002996:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000299a:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    8000299c:	0a07d163          	bgez	a5,80002a3e <devintr+0xa8>
{
    800029a0:	1101                	add	sp,sp,-32
    800029a2:	ec06                	sd	ra,24(sp)
    800029a4:	e822                	sd	s0,16(sp)
    800029a6:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    800029a8:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    800029ac:	46a5                	li	a3,9
    800029ae:	00d70c63          	beq	a4,a3,800029c6 <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    800029b2:	577d                	li	a4,-1
    800029b4:	177e                	sll	a4,a4,0x3f
    800029b6:	0705                	add	a4,a4,1
    return 0;
    800029b8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800029ba:	06e78163          	beq	a5,a4,80002a1c <devintr+0x86>
  }
}
    800029be:	60e2                	ld	ra,24(sp)
    800029c0:	6442                	ld	s0,16(sp)
    800029c2:	6105                	add	sp,sp,32
    800029c4:	8082                	ret
    800029c6:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800029c8:	00003097          	auipc	ra,0x3
    800029cc:	704080e7          	jalr	1796(ra) # 800060cc <plic_claim>
    800029d0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800029d2:	47a9                	li	a5,10
    800029d4:	00f50963          	beq	a0,a5,800029e6 <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    800029d8:	4785                	li	a5,1
    800029da:	00f50b63          	beq	a0,a5,800029f0 <devintr+0x5a>
    return 1;
    800029de:	4505                	li	a0,1
    } else if(irq){
    800029e0:	ec89                	bnez	s1,800029fa <devintr+0x64>
    800029e2:	64a2                	ld	s1,8(sp)
    800029e4:	bfe9                	j	800029be <devintr+0x28>
      uartintr();
    800029e6:	ffffe097          	auipc	ra,0xffffe
    800029ea:	00e080e7          	jalr	14(ra) # 800009f4 <uartintr>
    if(irq)
    800029ee:	a839                	j	80002a0c <devintr+0x76>
      virtio_disk_intr();
    800029f0:	00004097          	auipc	ra,0x4
    800029f4:	bb0080e7          	jalr	-1104(ra) # 800065a0 <virtio_disk_intr>
    if(irq)
    800029f8:	a811                	j	80002a0c <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    800029fa:	85a6                	mv	a1,s1
    800029fc:	00006517          	auipc	a0,0x6
    80002a00:	8dc50513          	add	a0,a0,-1828 # 800082d8 <etext+0x2d8>
    80002a04:	ffffe097          	auipc	ra,0xffffe
    80002a08:	ba0080e7          	jalr	-1120(ra) # 800005a4 <printf>
      plic_complete(irq);
    80002a0c:	8526                	mv	a0,s1
    80002a0e:	00003097          	auipc	ra,0x3
    80002a12:	6e2080e7          	jalr	1762(ra) # 800060f0 <plic_complete>
    return 1;
    80002a16:	4505                	li	a0,1
    80002a18:	64a2                	ld	s1,8(sp)
    80002a1a:	b755                	j	800029be <devintr+0x28>
    if(cpuid() == 0){
    80002a1c:	fffff097          	auipc	ra,0xfffff
    80002a20:	fe8080e7          	jalr	-24(ra) # 80001a04 <cpuid>
    80002a24:	c901                	beqz	a0,80002a34 <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a26:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a2a:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a2c:	14479073          	csrw	sip,a5
    return 2;
    80002a30:	4509                	li	a0,2
    80002a32:	b771                	j	800029be <devintr+0x28>
      clockintr();
    80002a34:	00000097          	auipc	ra,0x0
    80002a38:	f1c080e7          	jalr	-228(ra) # 80002950 <clockintr>
    80002a3c:	b7ed                	j	80002a26 <devintr+0x90>
}
    80002a3e:	8082                	ret

0000000080002a40 <usertrap>:
{
    80002a40:	1101                	add	sp,sp,-32
    80002a42:	ec06                	sd	ra,24(sp)
    80002a44:	e822                	sd	s0,16(sp)
    80002a46:	e426                	sd	s1,8(sp)
    80002a48:	e04a                	sd	s2,0(sp)
    80002a4a:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a4c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a50:	1007f793          	and	a5,a5,256
    80002a54:	e3ad                	bnez	a5,80002ab6 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a56:	00003797          	auipc	a5,0x3
    80002a5a:	56a78793          	add	a5,a5,1386 # 80005fc0 <kernelvec>
    80002a5e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a62:	fffff097          	auipc	ra,0xfffff
    80002a66:	fce080e7          	jalr	-50(ra) # 80001a30 <myproc>
    80002a6a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a6c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a6e:	14102773          	csrr	a4,sepc
    80002a72:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a74:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a78:	47a1                	li	a5,8
    80002a7a:	04f71c63          	bne	a4,a5,80002ad2 <usertrap+0x92>
    if(p->killed)
    80002a7e:	551c                	lw	a5,40(a0)
    80002a80:	e3b9                	bnez	a5,80002ac6 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002a82:	6cb8                	ld	a4,88(s1)
    80002a84:	6f1c                	ld	a5,24(a4)
    80002a86:	0791                	add	a5,a5,4
    80002a88:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a8a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a8e:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a92:	10079073          	csrw	sstatus,a5
    syscall();
    80002a96:	00000097          	auipc	ra,0x0
    80002a9a:	2e0080e7          	jalr	736(ra) # 80002d76 <syscall>
  if(p->killed)
    80002a9e:	549c                	lw	a5,40(s1)
    80002aa0:	ebc1                	bnez	a5,80002b30 <usertrap+0xf0>
  usertrapret();
    80002aa2:	00000097          	auipc	ra,0x0
    80002aa6:	e10080e7          	jalr	-496(ra) # 800028b2 <usertrapret>
}
    80002aaa:	60e2                	ld	ra,24(sp)
    80002aac:	6442                	ld	s0,16(sp)
    80002aae:	64a2                	ld	s1,8(sp)
    80002ab0:	6902                	ld	s2,0(sp)
    80002ab2:	6105                	add	sp,sp,32
    80002ab4:	8082                	ret
    panic("usertrap: not from user mode");
    80002ab6:	00006517          	auipc	a0,0x6
    80002aba:	84250513          	add	a0,a0,-1982 # 800082f8 <etext+0x2f8>
    80002abe:	ffffe097          	auipc	ra,0xffffe
    80002ac2:	a9c080e7          	jalr	-1380(ra) # 8000055a <panic>
      exit(-1);
    80002ac6:	557d                	li	a0,-1
    80002ac8:	00000097          	auipc	ra,0x0
    80002acc:	88a080e7          	jalr	-1910(ra) # 80002352 <exit>
    80002ad0:	bf4d                	j	80002a82 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002ad2:	00000097          	auipc	ra,0x0
    80002ad6:	ec4080e7          	jalr	-316(ra) # 80002996 <devintr>
    80002ada:	892a                	mv	s2,a0
    80002adc:	c501                	beqz	a0,80002ae4 <usertrap+0xa4>
  if(p->killed)
    80002ade:	549c                	lw	a5,40(s1)
    80002ae0:	c3a1                	beqz	a5,80002b20 <usertrap+0xe0>
    80002ae2:	a815                	j	80002b16 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ae4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002ae8:	5890                	lw	a2,48(s1)
    80002aea:	00006517          	auipc	a0,0x6
    80002aee:	82e50513          	add	a0,a0,-2002 # 80008318 <etext+0x318>
    80002af2:	ffffe097          	auipc	ra,0xffffe
    80002af6:	ab2080e7          	jalr	-1358(ra) # 800005a4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002afa:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002afe:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b02:	00006517          	auipc	a0,0x6
    80002b06:	84650513          	add	a0,a0,-1978 # 80008348 <etext+0x348>
    80002b0a:	ffffe097          	auipc	ra,0xffffe
    80002b0e:	a9a080e7          	jalr	-1382(ra) # 800005a4 <printf>
    p->killed = 1;
    80002b12:	4785                	li	a5,1
    80002b14:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002b16:	557d                	li	a0,-1
    80002b18:	00000097          	auipc	ra,0x0
    80002b1c:	83a080e7          	jalr	-1990(ra) # 80002352 <exit>
  if(which_dev == 2)
    80002b20:	4789                	li	a5,2
    80002b22:	f8f910e3          	bne	s2,a5,80002aa2 <usertrap+0x62>
    yield();
    80002b26:	fffff097          	auipc	ra,0xfffff
    80002b2a:	594080e7          	jalr	1428(ra) # 800020ba <yield>
    80002b2e:	bf95                	j	80002aa2 <usertrap+0x62>
  int which_dev = 0;
    80002b30:	4901                	li	s2,0
    80002b32:	b7d5                	j	80002b16 <usertrap+0xd6>

0000000080002b34 <kerneltrap>:
{
    80002b34:	7179                	add	sp,sp,-48
    80002b36:	f406                	sd	ra,40(sp)
    80002b38:	f022                	sd	s0,32(sp)
    80002b3a:	ec26                	sd	s1,24(sp)
    80002b3c:	e84a                	sd	s2,16(sp)
    80002b3e:	e44e                	sd	s3,8(sp)
    80002b40:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b42:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b46:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b4a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b4e:	1004f793          	and	a5,s1,256
    80002b52:	cb85                	beqz	a5,80002b82 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b54:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b58:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002b5a:	ef85                	bnez	a5,80002b92 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002b5c:	00000097          	auipc	ra,0x0
    80002b60:	e3a080e7          	jalr	-454(ra) # 80002996 <devintr>
    80002b64:	cd1d                	beqz	a0,80002ba2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002b66:	4789                	li	a5,2
    80002b68:	06f50a63          	beq	a0,a5,80002bdc <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b6c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b70:	10049073          	csrw	sstatus,s1
}
    80002b74:	70a2                	ld	ra,40(sp)
    80002b76:	7402                	ld	s0,32(sp)
    80002b78:	64e2                	ld	s1,24(sp)
    80002b7a:	6942                	ld	s2,16(sp)
    80002b7c:	69a2                	ld	s3,8(sp)
    80002b7e:	6145                	add	sp,sp,48
    80002b80:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002b82:	00005517          	auipc	a0,0x5
    80002b86:	7e650513          	add	a0,a0,2022 # 80008368 <etext+0x368>
    80002b8a:	ffffe097          	auipc	ra,0xffffe
    80002b8e:	9d0080e7          	jalr	-1584(ra) # 8000055a <panic>
    panic("kerneltrap: interrupts enabled");
    80002b92:	00005517          	auipc	a0,0x5
    80002b96:	7fe50513          	add	a0,a0,2046 # 80008390 <etext+0x390>
    80002b9a:	ffffe097          	auipc	ra,0xffffe
    80002b9e:	9c0080e7          	jalr	-1600(ra) # 8000055a <panic>
    printf("scause %p\n", scause);
    80002ba2:	85ce                	mv	a1,s3
    80002ba4:	00006517          	auipc	a0,0x6
    80002ba8:	80c50513          	add	a0,a0,-2036 # 800083b0 <etext+0x3b0>
    80002bac:	ffffe097          	auipc	ra,0xffffe
    80002bb0:	9f8080e7          	jalr	-1544(ra) # 800005a4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bb4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bb8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bbc:	00006517          	auipc	a0,0x6
    80002bc0:	80450513          	add	a0,a0,-2044 # 800083c0 <etext+0x3c0>
    80002bc4:	ffffe097          	auipc	ra,0xffffe
    80002bc8:	9e0080e7          	jalr	-1568(ra) # 800005a4 <printf>
    panic("kerneltrap");
    80002bcc:	00006517          	auipc	a0,0x6
    80002bd0:	80c50513          	add	a0,a0,-2036 # 800083d8 <etext+0x3d8>
    80002bd4:	ffffe097          	auipc	ra,0xffffe
    80002bd8:	986080e7          	jalr	-1658(ra) # 8000055a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bdc:	fffff097          	auipc	ra,0xfffff
    80002be0:	e54080e7          	jalr	-428(ra) # 80001a30 <myproc>
    80002be4:	d541                	beqz	a0,80002b6c <kerneltrap+0x38>
    80002be6:	fffff097          	auipc	ra,0xfffff
    80002bea:	e4a080e7          	jalr	-438(ra) # 80001a30 <myproc>
    80002bee:	4d18                	lw	a4,24(a0)
    80002bf0:	4791                	li	a5,4
    80002bf2:	f6f71de3          	bne	a4,a5,80002b6c <kerneltrap+0x38>
    yield();
    80002bf6:	fffff097          	auipc	ra,0xfffff
    80002bfa:	4c4080e7          	jalr	1220(ra) # 800020ba <yield>
    80002bfe:	b7bd                	j	80002b6c <kerneltrap+0x38>

0000000080002c00 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c00:	1101                	add	sp,sp,-32
    80002c02:	ec06                	sd	ra,24(sp)
    80002c04:	e822                	sd	s0,16(sp)
    80002c06:	e426                	sd	s1,8(sp)
    80002c08:	1000                	add	s0,sp,32
    80002c0a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c0c:	fffff097          	auipc	ra,0xfffff
    80002c10:	e24080e7          	jalr	-476(ra) # 80001a30 <myproc>
  switch (n) {
    80002c14:	4795                	li	a5,5
    80002c16:	0497e163          	bltu	a5,s1,80002c58 <argraw+0x58>
    80002c1a:	048a                	sll	s1,s1,0x2
    80002c1c:	00006717          	auipc	a4,0x6
    80002c20:	b5470713          	add	a4,a4,-1196 # 80008770 <states.0+0x30>
    80002c24:	94ba                	add	s1,s1,a4
    80002c26:	409c                	lw	a5,0(s1)
    80002c28:	97ba                	add	a5,a5,a4
    80002c2a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c2c:	6d3c                	ld	a5,88(a0)
    80002c2e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c30:	60e2                	ld	ra,24(sp)
    80002c32:	6442                	ld	s0,16(sp)
    80002c34:	64a2                	ld	s1,8(sp)
    80002c36:	6105                	add	sp,sp,32
    80002c38:	8082                	ret
    return p->trapframe->a1;
    80002c3a:	6d3c                	ld	a5,88(a0)
    80002c3c:	7fa8                	ld	a0,120(a5)
    80002c3e:	bfcd                	j	80002c30 <argraw+0x30>
    return p->trapframe->a2;
    80002c40:	6d3c                	ld	a5,88(a0)
    80002c42:	63c8                	ld	a0,128(a5)
    80002c44:	b7f5                	j	80002c30 <argraw+0x30>
    return p->trapframe->a3;
    80002c46:	6d3c                	ld	a5,88(a0)
    80002c48:	67c8                	ld	a0,136(a5)
    80002c4a:	b7dd                	j	80002c30 <argraw+0x30>
    return p->trapframe->a4;
    80002c4c:	6d3c                	ld	a5,88(a0)
    80002c4e:	6bc8                	ld	a0,144(a5)
    80002c50:	b7c5                	j	80002c30 <argraw+0x30>
    return p->trapframe->a5;
    80002c52:	6d3c                	ld	a5,88(a0)
    80002c54:	6fc8                	ld	a0,152(a5)
    80002c56:	bfe9                	j	80002c30 <argraw+0x30>
  panic("argraw");
    80002c58:	00005517          	auipc	a0,0x5
    80002c5c:	79050513          	add	a0,a0,1936 # 800083e8 <etext+0x3e8>
    80002c60:	ffffe097          	auipc	ra,0xffffe
    80002c64:	8fa080e7          	jalr	-1798(ra) # 8000055a <panic>

0000000080002c68 <fetchaddr>:
{
    80002c68:	1101                	add	sp,sp,-32
    80002c6a:	ec06                	sd	ra,24(sp)
    80002c6c:	e822                	sd	s0,16(sp)
    80002c6e:	e426                	sd	s1,8(sp)
    80002c70:	e04a                	sd	s2,0(sp)
    80002c72:	1000                	add	s0,sp,32
    80002c74:	84aa                	mv	s1,a0
    80002c76:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c78:	fffff097          	auipc	ra,0xfffff
    80002c7c:	db8080e7          	jalr	-584(ra) # 80001a30 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002c80:	653c                	ld	a5,72(a0)
    80002c82:	02f4f863          	bgeu	s1,a5,80002cb2 <fetchaddr+0x4a>
    80002c86:	00848713          	add	a4,s1,8
    80002c8a:	02e7e663          	bltu	a5,a4,80002cb6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c8e:	46a1                	li	a3,8
    80002c90:	8626                	mv	a2,s1
    80002c92:	85ca                	mv	a1,s2
    80002c94:	6928                	ld	a0,80(a0)
    80002c96:	fffff097          	auipc	ra,0xfffff
    80002c9a:	ac2080e7          	jalr	-1342(ra) # 80001758 <copyin>
    80002c9e:	00a03533          	snez	a0,a0
    80002ca2:	40a00533          	neg	a0,a0
}
    80002ca6:	60e2                	ld	ra,24(sp)
    80002ca8:	6442                	ld	s0,16(sp)
    80002caa:	64a2                	ld	s1,8(sp)
    80002cac:	6902                	ld	s2,0(sp)
    80002cae:	6105                	add	sp,sp,32
    80002cb0:	8082                	ret
    return -1;
    80002cb2:	557d                	li	a0,-1
    80002cb4:	bfcd                	j	80002ca6 <fetchaddr+0x3e>
    80002cb6:	557d                	li	a0,-1
    80002cb8:	b7fd                	j	80002ca6 <fetchaddr+0x3e>

0000000080002cba <fetchstr>:
{
    80002cba:	7179                	add	sp,sp,-48
    80002cbc:	f406                	sd	ra,40(sp)
    80002cbe:	f022                	sd	s0,32(sp)
    80002cc0:	ec26                	sd	s1,24(sp)
    80002cc2:	e84a                	sd	s2,16(sp)
    80002cc4:	e44e                	sd	s3,8(sp)
    80002cc6:	1800                	add	s0,sp,48
    80002cc8:	892a                	mv	s2,a0
    80002cca:	84ae                	mv	s1,a1
    80002ccc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cce:	fffff097          	auipc	ra,0xfffff
    80002cd2:	d62080e7          	jalr	-670(ra) # 80001a30 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002cd6:	86ce                	mv	a3,s3
    80002cd8:	864a                	mv	a2,s2
    80002cda:	85a6                	mv	a1,s1
    80002cdc:	6928                	ld	a0,80(a0)
    80002cde:	fffff097          	auipc	ra,0xfffff
    80002ce2:	b08080e7          	jalr	-1272(ra) # 800017e6 <copyinstr>
  if(err < 0)
    80002ce6:	00054763          	bltz	a0,80002cf4 <fetchstr+0x3a>
  return strlen(buf);
    80002cea:	8526                	mv	a0,s1
    80002cec:	ffffe097          	auipc	ra,0xffffe
    80002cf0:	1b6080e7          	jalr	438(ra) # 80000ea2 <strlen>
}
    80002cf4:	70a2                	ld	ra,40(sp)
    80002cf6:	7402                	ld	s0,32(sp)
    80002cf8:	64e2                	ld	s1,24(sp)
    80002cfa:	6942                	ld	s2,16(sp)
    80002cfc:	69a2                	ld	s3,8(sp)
    80002cfe:	6145                	add	sp,sp,48
    80002d00:	8082                	ret

0000000080002d02 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002d02:	1101                	add	sp,sp,-32
    80002d04:	ec06                	sd	ra,24(sp)
    80002d06:	e822                	sd	s0,16(sp)
    80002d08:	e426                	sd	s1,8(sp)
    80002d0a:	1000                	add	s0,sp,32
    80002d0c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d0e:	00000097          	auipc	ra,0x0
    80002d12:	ef2080e7          	jalr	-270(ra) # 80002c00 <argraw>
    80002d16:	c088                	sw	a0,0(s1)
  return 0;
}
    80002d18:	4501                	li	a0,0
    80002d1a:	60e2                	ld	ra,24(sp)
    80002d1c:	6442                	ld	s0,16(sp)
    80002d1e:	64a2                	ld	s1,8(sp)
    80002d20:	6105                	add	sp,sp,32
    80002d22:	8082                	ret

0000000080002d24 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002d24:	1101                	add	sp,sp,-32
    80002d26:	ec06                	sd	ra,24(sp)
    80002d28:	e822                	sd	s0,16(sp)
    80002d2a:	e426                	sd	s1,8(sp)
    80002d2c:	1000                	add	s0,sp,32
    80002d2e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d30:	00000097          	auipc	ra,0x0
    80002d34:	ed0080e7          	jalr	-304(ra) # 80002c00 <argraw>
    80002d38:	e088                	sd	a0,0(s1)
  return 0;
}
    80002d3a:	4501                	li	a0,0
    80002d3c:	60e2                	ld	ra,24(sp)
    80002d3e:	6442                	ld	s0,16(sp)
    80002d40:	64a2                	ld	s1,8(sp)
    80002d42:	6105                	add	sp,sp,32
    80002d44:	8082                	ret

0000000080002d46 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d46:	1101                	add	sp,sp,-32
    80002d48:	ec06                	sd	ra,24(sp)
    80002d4a:	e822                	sd	s0,16(sp)
    80002d4c:	e426                	sd	s1,8(sp)
    80002d4e:	e04a                	sd	s2,0(sp)
    80002d50:	1000                	add	s0,sp,32
    80002d52:	84ae                	mv	s1,a1
    80002d54:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002d56:	00000097          	auipc	ra,0x0
    80002d5a:	eaa080e7          	jalr	-342(ra) # 80002c00 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002d5e:	864a                	mv	a2,s2
    80002d60:	85a6                	mv	a1,s1
    80002d62:	00000097          	auipc	ra,0x0
    80002d66:	f58080e7          	jalr	-168(ra) # 80002cba <fetchstr>
}
    80002d6a:	60e2                	ld	ra,24(sp)
    80002d6c:	6442                	ld	s0,16(sp)
    80002d6e:	64a2                	ld	s1,8(sp)
    80002d70:	6902                	ld	s2,0(sp)
    80002d72:	6105                	add	sp,sp,32
    80002d74:	8082                	ret

0000000080002d76 <syscall>:
[SYS_rwsematest]  sys_rwsematest
};

void
syscall(void)
{
    80002d76:	1101                	add	sp,sp,-32
    80002d78:	ec06                	sd	ra,24(sp)
    80002d7a:	e822                	sd	s0,16(sp)
    80002d7c:	e426                	sd	s1,8(sp)
    80002d7e:	e04a                	sd	s2,0(sp)
    80002d80:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d82:	fffff097          	auipc	ra,0xfffff
    80002d86:	cae080e7          	jalr	-850(ra) # 80001a30 <myproc>
    80002d8a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d8c:	05853903          	ld	s2,88(a0)
    80002d90:	0a893783          	ld	a5,168(s2)
    80002d94:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d98:	37fd                	addw	a5,a5,-1
    80002d9a:	475d                	li	a4,23
    80002d9c:	00f76f63          	bltu	a4,a5,80002dba <syscall+0x44>
    80002da0:	00369713          	sll	a4,a3,0x3
    80002da4:	00006797          	auipc	a5,0x6
    80002da8:	9e478793          	add	a5,a5,-1564 # 80008788 <syscalls>
    80002dac:	97ba                	add	a5,a5,a4
    80002dae:	639c                	ld	a5,0(a5)
    80002db0:	c789                	beqz	a5,80002dba <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002db2:	9782                	jalr	a5
    80002db4:	06a93823          	sd	a0,112(s2)
    80002db8:	a839                	j	80002dd6 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002dba:	15848613          	add	a2,s1,344
    80002dbe:	588c                	lw	a1,48(s1)
    80002dc0:	00005517          	auipc	a0,0x5
    80002dc4:	63050513          	add	a0,a0,1584 # 800083f0 <etext+0x3f0>
    80002dc8:	ffffd097          	auipc	ra,0xffffd
    80002dcc:	7dc080e7          	jalr	2012(ra) # 800005a4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002dd0:	6cbc                	ld	a5,88(s1)
    80002dd2:	577d                	li	a4,-1
    80002dd4:	fbb8                	sd	a4,112(a5)
  }
}
    80002dd6:	60e2                	ld	ra,24(sp)
    80002dd8:	6442                	ld	s0,16(sp)
    80002dda:	64a2                	ld	s1,8(sp)
    80002ddc:	6902                	ld	s2,0(sp)
    80002dde:	6105                	add	sp,sp,32
    80002de0:	8082                	ret

0000000080002de2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002de2:	1101                	add	sp,sp,-32
    80002de4:	ec06                	sd	ra,24(sp)
    80002de6:	e822                	sd	s0,16(sp)
    80002de8:	1000                	add	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002dea:	fec40593          	add	a1,s0,-20
    80002dee:	4501                	li	a0,0
    80002df0:	00000097          	auipc	ra,0x0
    80002df4:	f12080e7          	jalr	-238(ra) # 80002d02 <argint>
    return -1;
    80002df8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002dfa:	00054963          	bltz	a0,80002e0c <sys_exit+0x2a>
  exit(n);
    80002dfe:	fec42503          	lw	a0,-20(s0)
    80002e02:	fffff097          	auipc	ra,0xfffff
    80002e06:	550080e7          	jalr	1360(ra) # 80002352 <exit>
  return 0;  // not reached
    80002e0a:	4781                	li	a5,0
}
    80002e0c:	853e                	mv	a0,a5
    80002e0e:	60e2                	ld	ra,24(sp)
    80002e10:	6442                	ld	s0,16(sp)
    80002e12:	6105                	add	sp,sp,32
    80002e14:	8082                	ret

0000000080002e16 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e16:	1141                	add	sp,sp,-16
    80002e18:	e406                	sd	ra,8(sp)
    80002e1a:	e022                	sd	s0,0(sp)
    80002e1c:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002e1e:	fffff097          	auipc	ra,0xfffff
    80002e22:	c12080e7          	jalr	-1006(ra) # 80001a30 <myproc>
}
    80002e26:	5908                	lw	a0,48(a0)
    80002e28:	60a2                	ld	ra,8(sp)
    80002e2a:	6402                	ld	s0,0(sp)
    80002e2c:	0141                	add	sp,sp,16
    80002e2e:	8082                	ret

0000000080002e30 <sys_fork>:

uint64
sys_fork(void)
{
    80002e30:	1141                	add	sp,sp,-16
    80002e32:	e406                	sd	ra,8(sp)
    80002e34:	e022                	sd	s0,0(sp)
    80002e36:	0800                	add	s0,sp,16
  return fork();
    80002e38:	fffff097          	auipc	ra,0xfffff
    80002e3c:	fca080e7          	jalr	-54(ra) # 80001e02 <fork>
}
    80002e40:	60a2                	ld	ra,8(sp)
    80002e42:	6402                	ld	s0,0(sp)
    80002e44:	0141                	add	sp,sp,16
    80002e46:	8082                	ret

0000000080002e48 <sys_wait>:

uint64
sys_wait(void)
{
    80002e48:	1101                	add	sp,sp,-32
    80002e4a:	ec06                	sd	ra,24(sp)
    80002e4c:	e822                	sd	s0,16(sp)
    80002e4e:	1000                	add	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002e50:	fe840593          	add	a1,s0,-24
    80002e54:	4501                	li	a0,0
    80002e56:	00000097          	auipc	ra,0x0
    80002e5a:	ece080e7          	jalr	-306(ra) # 80002d24 <argaddr>
    80002e5e:	87aa                	mv	a5,a0
    return -1;
    80002e60:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002e62:	0007c863          	bltz	a5,80002e72 <sys_wait+0x2a>
  return wait(p);
    80002e66:	fe843503          	ld	a0,-24(s0)
    80002e6a:	fffff097          	auipc	ra,0xfffff
    80002e6e:	2f0080e7          	jalr	752(ra) # 8000215a <wait>
}
    80002e72:	60e2                	ld	ra,24(sp)
    80002e74:	6442                	ld	s0,16(sp)
    80002e76:	6105                	add	sp,sp,32
    80002e78:	8082                	ret

0000000080002e7a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e7a:	7179                	add	sp,sp,-48
    80002e7c:	f406                	sd	ra,40(sp)
    80002e7e:	f022                	sd	s0,32(sp)
    80002e80:	1800                	add	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002e82:	fdc40593          	add	a1,s0,-36
    80002e86:	4501                	li	a0,0
    80002e88:	00000097          	auipc	ra,0x0
    80002e8c:	e7a080e7          	jalr	-390(ra) # 80002d02 <argint>
    80002e90:	87aa                	mv	a5,a0
    return -1;
    80002e92:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002e94:	0207c263          	bltz	a5,80002eb8 <sys_sbrk+0x3e>
    80002e98:	ec26                	sd	s1,24(sp)
  addr = myproc()->sz;
    80002e9a:	fffff097          	auipc	ra,0xfffff
    80002e9e:	b96080e7          	jalr	-1130(ra) # 80001a30 <myproc>
    80002ea2:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002ea4:	fdc42503          	lw	a0,-36(s0)
    80002ea8:	fffff097          	auipc	ra,0xfffff
    80002eac:	ee2080e7          	jalr	-286(ra) # 80001d8a <growproc>
    80002eb0:	00054863          	bltz	a0,80002ec0 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002eb4:	8526                	mv	a0,s1
    80002eb6:	64e2                	ld	s1,24(sp)
}
    80002eb8:	70a2                	ld	ra,40(sp)
    80002eba:	7402                	ld	s0,32(sp)
    80002ebc:	6145                	add	sp,sp,48
    80002ebe:	8082                	ret
    return -1;
    80002ec0:	557d                	li	a0,-1
    80002ec2:	64e2                	ld	s1,24(sp)
    80002ec4:	bfd5                	j	80002eb8 <sys_sbrk+0x3e>

0000000080002ec6 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002ec6:	7139                	add	sp,sp,-64
    80002ec8:	fc06                	sd	ra,56(sp)
    80002eca:	f822                	sd	s0,48(sp)
    80002ecc:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002ece:	fcc40593          	add	a1,s0,-52
    80002ed2:	4501                	li	a0,0
    80002ed4:	00000097          	auipc	ra,0x0
    80002ed8:	e2e080e7          	jalr	-466(ra) # 80002d02 <argint>
    return -1;
    80002edc:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ede:	06054b63          	bltz	a0,80002f54 <sys_sleep+0x8e>
    80002ee2:	f04a                	sd	s2,32(sp)
  acquire(&tickslock);
    80002ee4:	00014517          	auipc	a0,0x14
    80002ee8:	3ec50513          	add	a0,a0,1004 # 800172d0 <tickslock>
    80002eec:	ffffe097          	auipc	ra,0xffffe
    80002ef0:	d46080e7          	jalr	-698(ra) # 80000c32 <acquire>
  ticks0 = ticks;
    80002ef4:	00006917          	auipc	s2,0x6
    80002ef8:	13c92903          	lw	s2,316(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002efc:	fcc42783          	lw	a5,-52(s0)
    80002f00:	c3a1                	beqz	a5,80002f40 <sys_sleep+0x7a>
    80002f02:	f426                	sd	s1,40(sp)
    80002f04:	ec4e                	sd	s3,24(sp)
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f06:	00014997          	auipc	s3,0x14
    80002f0a:	3ca98993          	add	s3,s3,970 # 800172d0 <tickslock>
    80002f0e:	00006497          	auipc	s1,0x6
    80002f12:	12248493          	add	s1,s1,290 # 80009030 <ticks>
    if(myproc()->killed){
    80002f16:	fffff097          	auipc	ra,0xfffff
    80002f1a:	b1a080e7          	jalr	-1254(ra) # 80001a30 <myproc>
    80002f1e:	551c                	lw	a5,40(a0)
    80002f20:	ef9d                	bnez	a5,80002f5e <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002f22:	85ce                	mv	a1,s3
    80002f24:	8526                	mv	a0,s1
    80002f26:	fffff097          	auipc	ra,0xfffff
    80002f2a:	1d0080e7          	jalr	464(ra) # 800020f6 <sleep>
  while(ticks - ticks0 < n){
    80002f2e:	409c                	lw	a5,0(s1)
    80002f30:	412787bb          	subw	a5,a5,s2
    80002f34:	fcc42703          	lw	a4,-52(s0)
    80002f38:	fce7efe3          	bltu	a5,a4,80002f16 <sys_sleep+0x50>
    80002f3c:	74a2                	ld	s1,40(sp)
    80002f3e:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002f40:	00014517          	auipc	a0,0x14
    80002f44:	39050513          	add	a0,a0,912 # 800172d0 <tickslock>
    80002f48:	ffffe097          	auipc	ra,0xffffe
    80002f4c:	d9e080e7          	jalr	-610(ra) # 80000ce6 <release>
  return 0;
    80002f50:	4781                	li	a5,0
    80002f52:	7902                	ld	s2,32(sp)
}
    80002f54:	853e                	mv	a0,a5
    80002f56:	70e2                	ld	ra,56(sp)
    80002f58:	7442                	ld	s0,48(sp)
    80002f5a:	6121                	add	sp,sp,64
    80002f5c:	8082                	ret
      release(&tickslock);
    80002f5e:	00014517          	auipc	a0,0x14
    80002f62:	37250513          	add	a0,a0,882 # 800172d0 <tickslock>
    80002f66:	ffffe097          	auipc	ra,0xffffe
    80002f6a:	d80080e7          	jalr	-640(ra) # 80000ce6 <release>
      return -1;
    80002f6e:	57fd                	li	a5,-1
    80002f70:	74a2                	ld	s1,40(sp)
    80002f72:	7902                	ld	s2,32(sp)
    80002f74:	69e2                	ld	s3,24(sp)
    80002f76:	bff9                	j	80002f54 <sys_sleep+0x8e>

0000000080002f78 <sys_kill>:

uint64
sys_kill(void)
{
    80002f78:	1101                	add	sp,sp,-32
    80002f7a:	ec06                	sd	ra,24(sp)
    80002f7c:	e822                	sd	s0,16(sp)
    80002f7e:	1000                	add	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002f80:	fec40593          	add	a1,s0,-20
    80002f84:	4501                	li	a0,0
    80002f86:	00000097          	auipc	ra,0x0
    80002f8a:	d7c080e7          	jalr	-644(ra) # 80002d02 <argint>
    80002f8e:	87aa                	mv	a5,a0
    return -1;
    80002f90:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002f92:	0007c863          	bltz	a5,80002fa2 <sys_kill+0x2a>
  return kill(pid);
    80002f96:	fec42503          	lw	a0,-20(s0)
    80002f9a:	fffff097          	auipc	ra,0xfffff
    80002f9e:	48e080e7          	jalr	1166(ra) # 80002428 <kill>
}
    80002fa2:	60e2                	ld	ra,24(sp)
    80002fa4:	6442                	ld	s0,16(sp)
    80002fa6:	6105                	add	sp,sp,32
    80002fa8:	8082                	ret

0000000080002faa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002faa:	1101                	add	sp,sp,-32
    80002fac:	ec06                	sd	ra,24(sp)
    80002fae:	e822                	sd	s0,16(sp)
    80002fb0:	e426                	sd	s1,8(sp)
    80002fb2:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002fb4:	00014517          	auipc	a0,0x14
    80002fb8:	31c50513          	add	a0,a0,796 # 800172d0 <tickslock>
    80002fbc:	ffffe097          	auipc	ra,0xffffe
    80002fc0:	c76080e7          	jalr	-906(ra) # 80000c32 <acquire>
  xticks = ticks;
    80002fc4:	00006497          	auipc	s1,0x6
    80002fc8:	06c4a483          	lw	s1,108(s1) # 80009030 <ticks>
  release(&tickslock);
    80002fcc:	00014517          	auipc	a0,0x14
    80002fd0:	30450513          	add	a0,a0,772 # 800172d0 <tickslock>
    80002fd4:	ffffe097          	auipc	ra,0xffffe
    80002fd8:	d12080e7          	jalr	-750(ra) # 80000ce6 <release>
  return xticks;
}
    80002fdc:	02049513          	sll	a0,s1,0x20
    80002fe0:	9101                	srl	a0,a0,0x20
    80002fe2:	60e2                	ld	ra,24(sp)
    80002fe4:	6442                	ld	s0,16(sp)
    80002fe6:	64a2                	ld	s1,8(sp)
    80002fe8:	6105                	add	sp,sp,32
    80002fea:	8082                	ret

0000000080002fec <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fec:	7179                	add	sp,sp,-48
    80002fee:	f406                	sd	ra,40(sp)
    80002ff0:	f022                	sd	s0,32(sp)
    80002ff2:	ec26                	sd	s1,24(sp)
    80002ff4:	e84a                	sd	s2,16(sp)
    80002ff6:	e44e                	sd	s3,8(sp)
    80002ff8:	e052                	sd	s4,0(sp)
    80002ffa:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ffc:	00005597          	auipc	a1,0x5
    80003000:	41458593          	add	a1,a1,1044 # 80008410 <etext+0x410>
    80003004:	00014517          	auipc	a0,0x14
    80003008:	2e450513          	add	a0,a0,740 # 800172e8 <bcache>
    8000300c:	ffffe097          	auipc	ra,0xffffe
    80003010:	b96080e7          	jalr	-1130(ra) # 80000ba2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003014:	0001c797          	auipc	a5,0x1c
    80003018:	2d478793          	add	a5,a5,724 # 8001f2e8 <bcache+0x8000>
    8000301c:	0001c717          	auipc	a4,0x1c
    80003020:	62470713          	add	a4,a4,1572 # 8001f640 <bcache+0x8358>
    80003024:	3ae7b423          	sd	a4,936(a5)
  bcache.head.next = &bcache.head;
    80003028:	3ae7b823          	sd	a4,944(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000302c:	00014497          	auipc	s1,0x14
    80003030:	2d448493          	add	s1,s1,724 # 80017300 <bcache+0x18>
    b->next = bcache.head.next;
    80003034:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003036:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003038:	00005a17          	auipc	s4,0x5
    8000303c:	3e0a0a13          	add	s4,s4,992 # 80008418 <etext+0x418>
    b->next = bcache.head.next;
    80003040:	3b093783          	ld	a5,944(s2)
    80003044:	ecbc                	sd	a5,88(s1)
    b->prev = &bcache.head;
    80003046:	0534b823          	sd	s3,80(s1)
    initsleeplock(&b->lock, "buffer");
    8000304a:	85d2                	mv	a1,s4
    8000304c:	01048513          	add	a0,s1,16
    80003050:	00001097          	auipc	ra,0x1
    80003054:	4b2080e7          	jalr	1202(ra) # 80004502 <initsleeplock>
    bcache.head.next->prev = b;
    80003058:	3b093783          	ld	a5,944(s2)
    8000305c:	eba4                	sd	s1,80(a5)
    bcache.head.next = b;
    8000305e:	3a993823          	sd	s1,944(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003062:	46048493          	add	s1,s1,1120
    80003066:	fd349de3          	bne	s1,s3,80003040 <binit+0x54>
  }
}
    8000306a:	70a2                	ld	ra,40(sp)
    8000306c:	7402                	ld	s0,32(sp)
    8000306e:	64e2                	ld	s1,24(sp)
    80003070:	6942                	ld	s2,16(sp)
    80003072:	69a2                	ld	s3,8(sp)
    80003074:	6a02                	ld	s4,0(sp)
    80003076:	6145                	add	sp,sp,48
    80003078:	8082                	ret

000000008000307a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000307a:	7179                	add	sp,sp,-48
    8000307c:	f406                	sd	ra,40(sp)
    8000307e:	f022                	sd	s0,32(sp)
    80003080:	ec26                	sd	s1,24(sp)
    80003082:	e84a                	sd	s2,16(sp)
    80003084:	e44e                	sd	s3,8(sp)
    80003086:	1800                	add	s0,sp,48
    80003088:	892a                	mv	s2,a0
    8000308a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000308c:	00014517          	auipc	a0,0x14
    80003090:	25c50513          	add	a0,a0,604 # 800172e8 <bcache>
    80003094:	ffffe097          	auipc	ra,0xffffe
    80003098:	b9e080e7          	jalr	-1122(ra) # 80000c32 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000309c:	0001c497          	auipc	s1,0x1c
    800030a0:	5fc4b483          	ld	s1,1532(s1) # 8001f698 <bcache+0x83b0>
    800030a4:	0001c797          	auipc	a5,0x1c
    800030a8:	59c78793          	add	a5,a5,1436 # 8001f640 <bcache+0x8358>
    800030ac:	02f48f63          	beq	s1,a5,800030ea <bread+0x70>
    800030b0:	873e                	mv	a4,a5
    800030b2:	a021                	j	800030ba <bread+0x40>
    800030b4:	6ca4                	ld	s1,88(s1)
    800030b6:	02e48a63          	beq	s1,a4,800030ea <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800030ba:	449c                	lw	a5,8(s1)
    800030bc:	ff279ce3          	bne	a5,s2,800030b4 <bread+0x3a>
    800030c0:	44dc                	lw	a5,12(s1)
    800030c2:	ff3799e3          	bne	a5,s3,800030b4 <bread+0x3a>
      b->refcnt++;
    800030c6:	44bc                	lw	a5,72(s1)
    800030c8:	2785                	addw	a5,a5,1
    800030ca:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    800030cc:	00014517          	auipc	a0,0x14
    800030d0:	21c50513          	add	a0,a0,540 # 800172e8 <bcache>
    800030d4:	ffffe097          	auipc	ra,0xffffe
    800030d8:	c12080e7          	jalr	-1006(ra) # 80000ce6 <release>
      acquiresleep(&b->lock);
    800030dc:	01048513          	add	a0,s1,16
    800030e0:	00001097          	auipc	ra,0x1
    800030e4:	4b2080e7          	jalr	1202(ra) # 80004592 <acquiresleep>
      return b;
    800030e8:	a8b9                	j	80003146 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030ea:	0001c497          	auipc	s1,0x1c
    800030ee:	5a64b483          	ld	s1,1446(s1) # 8001f690 <bcache+0x83a8>
    800030f2:	0001c797          	auipc	a5,0x1c
    800030f6:	54e78793          	add	a5,a5,1358 # 8001f640 <bcache+0x8358>
    800030fa:	00f48863          	beq	s1,a5,8000310a <bread+0x90>
    800030fe:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003100:	44bc                	lw	a5,72(s1)
    80003102:	cf81                	beqz	a5,8000311a <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003104:	68a4                	ld	s1,80(s1)
    80003106:	fee49de3          	bne	s1,a4,80003100 <bread+0x86>
  panic("bget: no buffers");
    8000310a:	00005517          	auipc	a0,0x5
    8000310e:	31650513          	add	a0,a0,790 # 80008420 <etext+0x420>
    80003112:	ffffd097          	auipc	ra,0xffffd
    80003116:	448080e7          	jalr	1096(ra) # 8000055a <panic>
      b->dev = dev;
    8000311a:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000311e:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003122:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003126:	4785                	li	a5,1
    80003128:	c4bc                	sw	a5,72(s1)
      release(&bcache.lock);
    8000312a:	00014517          	auipc	a0,0x14
    8000312e:	1be50513          	add	a0,a0,446 # 800172e8 <bcache>
    80003132:	ffffe097          	auipc	ra,0xffffe
    80003136:	bb4080e7          	jalr	-1100(ra) # 80000ce6 <release>
      acquiresleep(&b->lock);
    8000313a:	01048513          	add	a0,s1,16
    8000313e:	00001097          	auipc	ra,0x1
    80003142:	454080e7          	jalr	1108(ra) # 80004592 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003146:	409c                	lw	a5,0(s1)
    80003148:	cb89                	beqz	a5,8000315a <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000314a:	8526                	mv	a0,s1
    8000314c:	70a2                	ld	ra,40(sp)
    8000314e:	7402                	ld	s0,32(sp)
    80003150:	64e2                	ld	s1,24(sp)
    80003152:	6942                	ld	s2,16(sp)
    80003154:	69a2                	ld	s3,8(sp)
    80003156:	6145                	add	sp,sp,48
    80003158:	8082                	ret
    virtio_disk_rw(b, 0);
    8000315a:	4581                	li	a1,0
    8000315c:	8526                	mv	a0,s1
    8000315e:	00003097          	auipc	ra,0x3
    80003162:	1b4080e7          	jalr	436(ra) # 80006312 <virtio_disk_rw>
    b->valid = 1;
    80003166:	4785                	li	a5,1
    80003168:	c09c                	sw	a5,0(s1)
  return b;
    8000316a:	b7c5                	j	8000314a <bread+0xd0>

000000008000316c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000316c:	1101                	add	sp,sp,-32
    8000316e:	ec06                	sd	ra,24(sp)
    80003170:	e822                	sd	s0,16(sp)
    80003172:	e426                	sd	s1,8(sp)
    80003174:	1000                	add	s0,sp,32
    80003176:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003178:	0541                	add	a0,a0,16
    8000317a:	00001097          	auipc	ra,0x1
    8000317e:	3c2080e7          	jalr	962(ra) # 8000453c <holdingsleep>
    80003182:	cd01                	beqz	a0,8000319a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003184:	4585                	li	a1,1
    80003186:	8526                	mv	a0,s1
    80003188:	00003097          	auipc	ra,0x3
    8000318c:	18a080e7          	jalr	394(ra) # 80006312 <virtio_disk_rw>
}
    80003190:	60e2                	ld	ra,24(sp)
    80003192:	6442                	ld	s0,16(sp)
    80003194:	64a2                	ld	s1,8(sp)
    80003196:	6105                	add	sp,sp,32
    80003198:	8082                	ret
    panic("bwrite");
    8000319a:	00005517          	auipc	a0,0x5
    8000319e:	29e50513          	add	a0,a0,670 # 80008438 <etext+0x438>
    800031a2:	ffffd097          	auipc	ra,0xffffd
    800031a6:	3b8080e7          	jalr	952(ra) # 8000055a <panic>

00000000800031aa <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031aa:	1101                	add	sp,sp,-32
    800031ac:	ec06                	sd	ra,24(sp)
    800031ae:	e822                	sd	s0,16(sp)
    800031b0:	e426                	sd	s1,8(sp)
    800031b2:	e04a                	sd	s2,0(sp)
    800031b4:	1000                	add	s0,sp,32
    800031b6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031b8:	01050913          	add	s2,a0,16
    800031bc:	854a                	mv	a0,s2
    800031be:	00001097          	auipc	ra,0x1
    800031c2:	37e080e7          	jalr	894(ra) # 8000453c <holdingsleep>
    800031c6:	c925                	beqz	a0,80003236 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800031c8:	854a                	mv	a0,s2
    800031ca:	00001097          	auipc	ra,0x1
    800031ce:	454080e7          	jalr	1108(ra) # 8000461e <releasesleep>

  acquire(&bcache.lock);
    800031d2:	00014517          	auipc	a0,0x14
    800031d6:	11650513          	add	a0,a0,278 # 800172e8 <bcache>
    800031da:	ffffe097          	auipc	ra,0xffffe
    800031de:	a58080e7          	jalr	-1448(ra) # 80000c32 <acquire>
  b->refcnt--;
    800031e2:	44bc                	lw	a5,72(s1)
    800031e4:	37fd                	addw	a5,a5,-1
    800031e6:	0007871b          	sext.w	a4,a5
    800031ea:	c4bc                	sw	a5,72(s1)
  if (b->refcnt == 0) {
    800031ec:	e71d                	bnez	a4,8000321a <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031ee:	6cb8                	ld	a4,88(s1)
    800031f0:	68bc                	ld	a5,80(s1)
    800031f2:	eb3c                	sd	a5,80(a4)
    b->prev->next = b->next;
    800031f4:	6cb8                	ld	a4,88(s1)
    800031f6:	efb8                	sd	a4,88(a5)
    b->next = bcache.head.next;
    800031f8:	0001c797          	auipc	a5,0x1c
    800031fc:	0f078793          	add	a5,a5,240 # 8001f2e8 <bcache+0x8000>
    80003200:	3b07b703          	ld	a4,944(a5)
    80003204:	ecb8                	sd	a4,88(s1)
    b->prev = &bcache.head;
    80003206:	0001c717          	auipc	a4,0x1c
    8000320a:	43a70713          	add	a4,a4,1082 # 8001f640 <bcache+0x8358>
    8000320e:	e8b8                	sd	a4,80(s1)
    bcache.head.next->prev = b;
    80003210:	3b07b703          	ld	a4,944(a5)
    80003214:	eb24                	sd	s1,80(a4)
    bcache.head.next = b;
    80003216:	3a97b823          	sd	s1,944(a5)
  }
  
  release(&bcache.lock);
    8000321a:	00014517          	auipc	a0,0x14
    8000321e:	0ce50513          	add	a0,a0,206 # 800172e8 <bcache>
    80003222:	ffffe097          	auipc	ra,0xffffe
    80003226:	ac4080e7          	jalr	-1340(ra) # 80000ce6 <release>
}
    8000322a:	60e2                	ld	ra,24(sp)
    8000322c:	6442                	ld	s0,16(sp)
    8000322e:	64a2                	ld	s1,8(sp)
    80003230:	6902                	ld	s2,0(sp)
    80003232:	6105                	add	sp,sp,32
    80003234:	8082                	ret
    panic("brelse");
    80003236:	00005517          	auipc	a0,0x5
    8000323a:	20a50513          	add	a0,a0,522 # 80008440 <etext+0x440>
    8000323e:	ffffd097          	auipc	ra,0xffffd
    80003242:	31c080e7          	jalr	796(ra) # 8000055a <panic>

0000000080003246 <bpin>:

void
bpin(struct buf *b) {
    80003246:	1101                	add	sp,sp,-32
    80003248:	ec06                	sd	ra,24(sp)
    8000324a:	e822                	sd	s0,16(sp)
    8000324c:	e426                	sd	s1,8(sp)
    8000324e:	1000                	add	s0,sp,32
    80003250:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003252:	00014517          	auipc	a0,0x14
    80003256:	09650513          	add	a0,a0,150 # 800172e8 <bcache>
    8000325a:	ffffe097          	auipc	ra,0xffffe
    8000325e:	9d8080e7          	jalr	-1576(ra) # 80000c32 <acquire>
  b->refcnt++;
    80003262:	44bc                	lw	a5,72(s1)
    80003264:	2785                	addw	a5,a5,1
    80003266:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    80003268:	00014517          	auipc	a0,0x14
    8000326c:	08050513          	add	a0,a0,128 # 800172e8 <bcache>
    80003270:	ffffe097          	auipc	ra,0xffffe
    80003274:	a76080e7          	jalr	-1418(ra) # 80000ce6 <release>
}
    80003278:	60e2                	ld	ra,24(sp)
    8000327a:	6442                	ld	s0,16(sp)
    8000327c:	64a2                	ld	s1,8(sp)
    8000327e:	6105                	add	sp,sp,32
    80003280:	8082                	ret

0000000080003282 <bunpin>:

void
bunpin(struct buf *b) {
    80003282:	1101                	add	sp,sp,-32
    80003284:	ec06                	sd	ra,24(sp)
    80003286:	e822                	sd	s0,16(sp)
    80003288:	e426                	sd	s1,8(sp)
    8000328a:	1000                	add	s0,sp,32
    8000328c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000328e:	00014517          	auipc	a0,0x14
    80003292:	05a50513          	add	a0,a0,90 # 800172e8 <bcache>
    80003296:	ffffe097          	auipc	ra,0xffffe
    8000329a:	99c080e7          	jalr	-1636(ra) # 80000c32 <acquire>
  b->refcnt--;
    8000329e:	44bc                	lw	a5,72(s1)
    800032a0:	37fd                	addw	a5,a5,-1
    800032a2:	c4bc                	sw	a5,72(s1)
  release(&bcache.lock);
    800032a4:	00014517          	auipc	a0,0x14
    800032a8:	04450513          	add	a0,a0,68 # 800172e8 <bcache>
    800032ac:	ffffe097          	auipc	ra,0xffffe
    800032b0:	a3a080e7          	jalr	-1478(ra) # 80000ce6 <release>
}
    800032b4:	60e2                	ld	ra,24(sp)
    800032b6:	6442                	ld	s0,16(sp)
    800032b8:	64a2                	ld	s1,8(sp)
    800032ba:	6105                	add	sp,sp,32
    800032bc:	8082                	ret

00000000800032be <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032be:	1101                	add	sp,sp,-32
    800032c0:	ec06                	sd	ra,24(sp)
    800032c2:	e822                	sd	s0,16(sp)
    800032c4:	e426                	sd	s1,8(sp)
    800032c6:	e04a                	sd	s2,0(sp)
    800032c8:	1000                	add	s0,sp,32
    800032ca:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032cc:	00d5d59b          	srlw	a1,a1,0xd
    800032d0:	0001c797          	auipc	a5,0x1c
    800032d4:	7ec7a783          	lw	a5,2028(a5) # 8001fabc <sb+0x1c>
    800032d8:	9dbd                	addw	a1,a1,a5
    800032da:	00000097          	auipc	ra,0x0
    800032de:	da0080e7          	jalr	-608(ra) # 8000307a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032e2:	0074f713          	and	a4,s1,7
    800032e6:	4785                	li	a5,1
    800032e8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800032ec:	14ce                	sll	s1,s1,0x33
    800032ee:	90d9                	srl	s1,s1,0x36
    800032f0:	00950733          	add	a4,a0,s1
    800032f4:	06074703          	lbu	a4,96(a4)
    800032f8:	00e7f6b3          	and	a3,a5,a4
    800032fc:	c69d                	beqz	a3,8000332a <bfree+0x6c>
    800032fe:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003300:	94aa                	add	s1,s1,a0
    80003302:	fff7c793          	not	a5,a5
    80003306:	8f7d                	and	a4,a4,a5
    80003308:	06e48023          	sb	a4,96(s1)
  log_write(bp);
    8000330c:	00001097          	auipc	ra,0x1
    80003310:	112080e7          	jalr	274(ra) # 8000441e <log_write>
  brelse(bp);
    80003314:	854a                	mv	a0,s2
    80003316:	00000097          	auipc	ra,0x0
    8000331a:	e94080e7          	jalr	-364(ra) # 800031aa <brelse>
}
    8000331e:	60e2                	ld	ra,24(sp)
    80003320:	6442                	ld	s0,16(sp)
    80003322:	64a2                	ld	s1,8(sp)
    80003324:	6902                	ld	s2,0(sp)
    80003326:	6105                	add	sp,sp,32
    80003328:	8082                	ret
    panic("freeing free block");
    8000332a:	00005517          	auipc	a0,0x5
    8000332e:	11e50513          	add	a0,a0,286 # 80008448 <etext+0x448>
    80003332:	ffffd097          	auipc	ra,0xffffd
    80003336:	228080e7          	jalr	552(ra) # 8000055a <panic>

000000008000333a <balloc>:
{
    8000333a:	711d                	add	sp,sp,-96
    8000333c:	ec86                	sd	ra,88(sp)
    8000333e:	e8a2                	sd	s0,80(sp)
    80003340:	e4a6                	sd	s1,72(sp)
    80003342:	e0ca                	sd	s2,64(sp)
    80003344:	fc4e                	sd	s3,56(sp)
    80003346:	f852                	sd	s4,48(sp)
    80003348:	f456                	sd	s5,40(sp)
    8000334a:	f05a                	sd	s6,32(sp)
    8000334c:	ec5e                	sd	s7,24(sp)
    8000334e:	e862                	sd	s8,16(sp)
    80003350:	e466                	sd	s9,8(sp)
    80003352:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003354:	0001c797          	auipc	a5,0x1c
    80003358:	7507a783          	lw	a5,1872(a5) # 8001faa4 <sb+0x4>
    8000335c:	cbc1                	beqz	a5,800033ec <balloc+0xb2>
    8000335e:	8baa                	mv	s7,a0
    80003360:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003362:	0001cb17          	auipc	s6,0x1c
    80003366:	73eb0b13          	add	s6,s6,1854 # 8001faa0 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000336a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000336c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000336e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003370:	6c89                	lui	s9,0x2
    80003372:	a831                	j	8000338e <balloc+0x54>
    brelse(bp);
    80003374:	854a                	mv	a0,s2
    80003376:	00000097          	auipc	ra,0x0
    8000337a:	e34080e7          	jalr	-460(ra) # 800031aa <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000337e:	015c87bb          	addw	a5,s9,s5
    80003382:	00078a9b          	sext.w	s5,a5
    80003386:	004b2703          	lw	a4,4(s6)
    8000338a:	06eaf163          	bgeu	s5,a4,800033ec <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    8000338e:	41fad79b          	sraw	a5,s5,0x1f
    80003392:	0137d79b          	srlw	a5,a5,0x13
    80003396:	015787bb          	addw	a5,a5,s5
    8000339a:	40d7d79b          	sraw	a5,a5,0xd
    8000339e:	01cb2583          	lw	a1,28(s6)
    800033a2:	9dbd                	addw	a1,a1,a5
    800033a4:	855e                	mv	a0,s7
    800033a6:	00000097          	auipc	ra,0x0
    800033aa:	cd4080e7          	jalr	-812(ra) # 8000307a <bread>
    800033ae:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033b0:	004b2503          	lw	a0,4(s6)
    800033b4:	000a849b          	sext.w	s1,s5
    800033b8:	8762                	mv	a4,s8
    800033ba:	faa4fde3          	bgeu	s1,a0,80003374 <balloc+0x3a>
      m = 1 << (bi % 8);
    800033be:	00777693          	and	a3,a4,7
    800033c2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033c6:	41f7579b          	sraw	a5,a4,0x1f
    800033ca:	01d7d79b          	srlw	a5,a5,0x1d
    800033ce:	9fb9                	addw	a5,a5,a4
    800033d0:	4037d79b          	sraw	a5,a5,0x3
    800033d4:	00f90633          	add	a2,s2,a5
    800033d8:	06064603          	lbu	a2,96(a2)
    800033dc:	00c6f5b3          	and	a1,a3,a2
    800033e0:	cd91                	beqz	a1,800033fc <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033e2:	2705                	addw	a4,a4,1
    800033e4:	2485                	addw	s1,s1,1
    800033e6:	fd471ae3          	bne	a4,s4,800033ba <balloc+0x80>
    800033ea:	b769                	j	80003374 <balloc+0x3a>
  panic("balloc: out of blocks");
    800033ec:	00005517          	auipc	a0,0x5
    800033f0:	07450513          	add	a0,a0,116 # 80008460 <etext+0x460>
    800033f4:	ffffd097          	auipc	ra,0xffffd
    800033f8:	166080e7          	jalr	358(ra) # 8000055a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033fc:	97ca                	add	a5,a5,s2
    800033fe:	8e55                	or	a2,a2,a3
    80003400:	06c78023          	sb	a2,96(a5)
        log_write(bp);
    80003404:	854a                	mv	a0,s2
    80003406:	00001097          	auipc	ra,0x1
    8000340a:	018080e7          	jalr	24(ra) # 8000441e <log_write>
        brelse(bp);
    8000340e:	854a                	mv	a0,s2
    80003410:	00000097          	auipc	ra,0x0
    80003414:	d9a080e7          	jalr	-614(ra) # 800031aa <brelse>
  bp = bread(dev, bno);
    80003418:	85a6                	mv	a1,s1
    8000341a:	855e                	mv	a0,s7
    8000341c:	00000097          	auipc	ra,0x0
    80003420:	c5e080e7          	jalr	-930(ra) # 8000307a <bread>
    80003424:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003426:	40000613          	li	a2,1024
    8000342a:	4581                	li	a1,0
    8000342c:	06050513          	add	a0,a0,96
    80003430:	ffffe097          	auipc	ra,0xffffe
    80003434:	8fe080e7          	jalr	-1794(ra) # 80000d2e <memset>
  log_write(bp);
    80003438:	854a                	mv	a0,s2
    8000343a:	00001097          	auipc	ra,0x1
    8000343e:	fe4080e7          	jalr	-28(ra) # 8000441e <log_write>
  brelse(bp);
    80003442:	854a                	mv	a0,s2
    80003444:	00000097          	auipc	ra,0x0
    80003448:	d66080e7          	jalr	-666(ra) # 800031aa <brelse>
}
    8000344c:	8526                	mv	a0,s1
    8000344e:	60e6                	ld	ra,88(sp)
    80003450:	6446                	ld	s0,80(sp)
    80003452:	64a6                	ld	s1,72(sp)
    80003454:	6906                	ld	s2,64(sp)
    80003456:	79e2                	ld	s3,56(sp)
    80003458:	7a42                	ld	s4,48(sp)
    8000345a:	7aa2                	ld	s5,40(sp)
    8000345c:	7b02                	ld	s6,32(sp)
    8000345e:	6be2                	ld	s7,24(sp)
    80003460:	6c42                	ld	s8,16(sp)
    80003462:	6ca2                	ld	s9,8(sp)
    80003464:	6125                	add	sp,sp,96
    80003466:	8082                	ret

0000000080003468 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003468:	7179                	add	sp,sp,-48
    8000346a:	f406                	sd	ra,40(sp)
    8000346c:	f022                	sd	s0,32(sp)
    8000346e:	ec26                	sd	s1,24(sp)
    80003470:	e84a                	sd	s2,16(sp)
    80003472:	e44e                	sd	s3,8(sp)
    80003474:	1800                	add	s0,sp,48
    80003476:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003478:	47ad                	li	a5,11
    8000347a:	04b7ff63          	bgeu	a5,a1,800034d8 <bmap+0x70>
    8000347e:	e052                	sd	s4,0(sp)
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003480:	ff45849b          	addw	s1,a1,-12
    80003484:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003488:	0ff00793          	li	a5,255
    8000348c:	0ae7e463          	bltu	a5,a4,80003534 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003490:	08852583          	lw	a1,136(a0)
    80003494:	c5b5                	beqz	a1,80003500 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003496:	00092503          	lw	a0,0(s2)
    8000349a:	00000097          	auipc	ra,0x0
    8000349e:	be0080e7          	jalr	-1056(ra) # 8000307a <bread>
    800034a2:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034a4:	06050793          	add	a5,a0,96
    if((addr = a[bn]) == 0){
    800034a8:	02049713          	sll	a4,s1,0x20
    800034ac:	01e75593          	srl	a1,a4,0x1e
    800034b0:	00b784b3          	add	s1,a5,a1
    800034b4:	0004a983          	lw	s3,0(s1)
    800034b8:	04098e63          	beqz	s3,80003514 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800034bc:	8552                	mv	a0,s4
    800034be:	00000097          	auipc	ra,0x0
    800034c2:	cec080e7          	jalr	-788(ra) # 800031aa <brelse>
    return addr;
    800034c6:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800034c8:	854e                	mv	a0,s3
    800034ca:	70a2                	ld	ra,40(sp)
    800034cc:	7402                	ld	s0,32(sp)
    800034ce:	64e2                	ld	s1,24(sp)
    800034d0:	6942                	ld	s2,16(sp)
    800034d2:	69a2                	ld	s3,8(sp)
    800034d4:	6145                	add	sp,sp,48
    800034d6:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800034d8:	02059793          	sll	a5,a1,0x20
    800034dc:	01e7d593          	srl	a1,a5,0x1e
    800034e0:	00b504b3          	add	s1,a0,a1
    800034e4:	0584a983          	lw	s3,88(s1)
    800034e8:	fe0990e3          	bnez	s3,800034c8 <bmap+0x60>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800034ec:	4108                	lw	a0,0(a0)
    800034ee:	00000097          	auipc	ra,0x0
    800034f2:	e4c080e7          	jalr	-436(ra) # 8000333a <balloc>
    800034f6:	0005099b          	sext.w	s3,a0
    800034fa:	0534ac23          	sw	s3,88(s1)
    800034fe:	b7e9                	j	800034c8 <bmap+0x60>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003500:	4108                	lw	a0,0(a0)
    80003502:	00000097          	auipc	ra,0x0
    80003506:	e38080e7          	jalr	-456(ra) # 8000333a <balloc>
    8000350a:	0005059b          	sext.w	a1,a0
    8000350e:	08b92423          	sw	a1,136(s2)
    80003512:	b751                	j	80003496 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003514:	00092503          	lw	a0,0(s2)
    80003518:	00000097          	auipc	ra,0x0
    8000351c:	e22080e7          	jalr	-478(ra) # 8000333a <balloc>
    80003520:	0005099b          	sext.w	s3,a0
    80003524:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003528:	8552                	mv	a0,s4
    8000352a:	00001097          	auipc	ra,0x1
    8000352e:	ef4080e7          	jalr	-268(ra) # 8000441e <log_write>
    80003532:	b769                	j	800034bc <bmap+0x54>
  panic("bmap: out of range");
    80003534:	00005517          	auipc	a0,0x5
    80003538:	f4450513          	add	a0,a0,-188 # 80008478 <etext+0x478>
    8000353c:	ffffd097          	auipc	ra,0xffffd
    80003540:	01e080e7          	jalr	30(ra) # 8000055a <panic>

0000000080003544 <iget>:
{
    80003544:	7179                	add	sp,sp,-48
    80003546:	f406                	sd	ra,40(sp)
    80003548:	f022                	sd	s0,32(sp)
    8000354a:	ec26                	sd	s1,24(sp)
    8000354c:	e84a                	sd	s2,16(sp)
    8000354e:	e44e                	sd	s3,8(sp)
    80003550:	e052                	sd	s4,0(sp)
    80003552:	1800                	add	s0,sp,48
    80003554:	89aa                	mv	s3,a0
    80003556:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003558:	0001c517          	auipc	a0,0x1c
    8000355c:	56850513          	add	a0,a0,1384 # 8001fac0 <itable>
    80003560:	ffffd097          	auipc	ra,0xffffd
    80003564:	6d2080e7          	jalr	1746(ra) # 80000c32 <acquire>
  empty = 0;
    80003568:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000356a:	0001c497          	auipc	s1,0x1c
    8000356e:	56e48493          	add	s1,s1,1390 # 8001fad8 <itable+0x18>
    80003572:	0001e697          	auipc	a3,0x1e
    80003576:	18668693          	add	a3,a3,390 # 800216f8 <log>
    8000357a:	a039                	j	80003588 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000357c:	02090b63          	beqz	s2,800035b2 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003580:	09048493          	add	s1,s1,144
    80003584:	02d48a63          	beq	s1,a3,800035b8 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003588:	449c                	lw	a5,8(s1)
    8000358a:	fef059e3          	blez	a5,8000357c <iget+0x38>
    8000358e:	4098                	lw	a4,0(s1)
    80003590:	ff3716e3          	bne	a4,s3,8000357c <iget+0x38>
    80003594:	40d8                	lw	a4,4(s1)
    80003596:	ff4713e3          	bne	a4,s4,8000357c <iget+0x38>
      ip->ref++;
    8000359a:	2785                	addw	a5,a5,1
    8000359c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000359e:	0001c517          	auipc	a0,0x1c
    800035a2:	52250513          	add	a0,a0,1314 # 8001fac0 <itable>
    800035a6:	ffffd097          	auipc	ra,0xffffd
    800035aa:	740080e7          	jalr	1856(ra) # 80000ce6 <release>
      return ip;
    800035ae:	8926                	mv	s2,s1
    800035b0:	a03d                	j	800035de <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035b2:	f7f9                	bnez	a5,80003580 <iget+0x3c>
      empty = ip;
    800035b4:	8926                	mv	s2,s1
    800035b6:	b7e9                	j	80003580 <iget+0x3c>
  if(empty == 0)
    800035b8:	02090c63          	beqz	s2,800035f0 <iget+0xac>
  ip->dev = dev;
    800035bc:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035c0:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035c4:	4785                	li	a5,1
    800035c6:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035ca:	04092423          	sw	zero,72(s2)
  release(&itable.lock);
    800035ce:	0001c517          	auipc	a0,0x1c
    800035d2:	4f250513          	add	a0,a0,1266 # 8001fac0 <itable>
    800035d6:	ffffd097          	auipc	ra,0xffffd
    800035da:	710080e7          	jalr	1808(ra) # 80000ce6 <release>
}
    800035de:	854a                	mv	a0,s2
    800035e0:	70a2                	ld	ra,40(sp)
    800035e2:	7402                	ld	s0,32(sp)
    800035e4:	64e2                	ld	s1,24(sp)
    800035e6:	6942                	ld	s2,16(sp)
    800035e8:	69a2                	ld	s3,8(sp)
    800035ea:	6a02                	ld	s4,0(sp)
    800035ec:	6145                	add	sp,sp,48
    800035ee:	8082                	ret
    panic("iget: no inodes");
    800035f0:	00005517          	auipc	a0,0x5
    800035f4:	ea050513          	add	a0,a0,-352 # 80008490 <etext+0x490>
    800035f8:	ffffd097          	auipc	ra,0xffffd
    800035fc:	f62080e7          	jalr	-158(ra) # 8000055a <panic>

0000000080003600 <fsinit>:
fsinit(int dev) {
    80003600:	7179                	add	sp,sp,-48
    80003602:	f406                	sd	ra,40(sp)
    80003604:	f022                	sd	s0,32(sp)
    80003606:	ec26                	sd	s1,24(sp)
    80003608:	e84a                	sd	s2,16(sp)
    8000360a:	e44e                	sd	s3,8(sp)
    8000360c:	1800                	add	s0,sp,48
    8000360e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003610:	4585                	li	a1,1
    80003612:	00000097          	auipc	ra,0x0
    80003616:	a68080e7          	jalr	-1432(ra) # 8000307a <bread>
    8000361a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000361c:	0001c997          	auipc	s3,0x1c
    80003620:	48498993          	add	s3,s3,1156 # 8001faa0 <sb>
    80003624:	02000613          	li	a2,32
    80003628:	06050593          	add	a1,a0,96
    8000362c:	854e                	mv	a0,s3
    8000362e:	ffffd097          	auipc	ra,0xffffd
    80003632:	75c080e7          	jalr	1884(ra) # 80000d8a <memmove>
  brelse(bp);
    80003636:	8526                	mv	a0,s1
    80003638:	00000097          	auipc	ra,0x0
    8000363c:	b72080e7          	jalr	-1166(ra) # 800031aa <brelse>
  if(sb.magic != FSMAGIC)
    80003640:	0009a703          	lw	a4,0(s3)
    80003644:	102037b7          	lui	a5,0x10203
    80003648:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000364c:	02f71263          	bne	a4,a5,80003670 <fsinit+0x70>
  initlog(dev, &sb);
    80003650:	0001c597          	auipc	a1,0x1c
    80003654:	45058593          	add	a1,a1,1104 # 8001faa0 <sb>
    80003658:	854a                	mv	a0,s2
    8000365a:	00001097          	auipc	ra,0x1
    8000365e:	b54080e7          	jalr	-1196(ra) # 800041ae <initlog>
}
    80003662:	70a2                	ld	ra,40(sp)
    80003664:	7402                	ld	s0,32(sp)
    80003666:	64e2                	ld	s1,24(sp)
    80003668:	6942                	ld	s2,16(sp)
    8000366a:	69a2                	ld	s3,8(sp)
    8000366c:	6145                	add	sp,sp,48
    8000366e:	8082                	ret
    panic("invalid file system");
    80003670:	00005517          	auipc	a0,0x5
    80003674:	e3050513          	add	a0,a0,-464 # 800084a0 <etext+0x4a0>
    80003678:	ffffd097          	auipc	ra,0xffffd
    8000367c:	ee2080e7          	jalr	-286(ra) # 8000055a <panic>

0000000080003680 <iinit>:
{
    80003680:	7179                	add	sp,sp,-48
    80003682:	f406                	sd	ra,40(sp)
    80003684:	f022                	sd	s0,32(sp)
    80003686:	ec26                	sd	s1,24(sp)
    80003688:	e84a                	sd	s2,16(sp)
    8000368a:	e44e                	sd	s3,8(sp)
    8000368c:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    8000368e:	00005597          	auipc	a1,0x5
    80003692:	e2a58593          	add	a1,a1,-470 # 800084b8 <etext+0x4b8>
    80003696:	0001c517          	auipc	a0,0x1c
    8000369a:	42a50513          	add	a0,a0,1066 # 8001fac0 <itable>
    8000369e:	ffffd097          	auipc	ra,0xffffd
    800036a2:	504080e7          	jalr	1284(ra) # 80000ba2 <initlock>
  for(i = 0; i < NINODE; i++) {
    800036a6:	0001c497          	auipc	s1,0x1c
    800036aa:	44248493          	add	s1,s1,1090 # 8001fae8 <itable+0x28>
    800036ae:	0001e997          	auipc	s3,0x1e
    800036b2:	05a98993          	add	s3,s3,90 # 80021708 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036b6:	00005917          	auipc	s2,0x5
    800036ba:	e0a90913          	add	s2,s2,-502 # 800084c0 <etext+0x4c0>
    800036be:	85ca                	mv	a1,s2
    800036c0:	8526                	mv	a0,s1
    800036c2:	00001097          	auipc	ra,0x1
    800036c6:	e40080e7          	jalr	-448(ra) # 80004502 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036ca:	09048493          	add	s1,s1,144
    800036ce:	ff3498e3          	bne	s1,s3,800036be <iinit+0x3e>
}
    800036d2:	70a2                	ld	ra,40(sp)
    800036d4:	7402                	ld	s0,32(sp)
    800036d6:	64e2                	ld	s1,24(sp)
    800036d8:	6942                	ld	s2,16(sp)
    800036da:	69a2                	ld	s3,8(sp)
    800036dc:	6145                	add	sp,sp,48
    800036de:	8082                	ret

00000000800036e0 <ialloc>:
{
    800036e0:	7139                	add	sp,sp,-64
    800036e2:	fc06                	sd	ra,56(sp)
    800036e4:	f822                	sd	s0,48(sp)
    800036e6:	f426                	sd	s1,40(sp)
    800036e8:	f04a                	sd	s2,32(sp)
    800036ea:	ec4e                	sd	s3,24(sp)
    800036ec:	e852                	sd	s4,16(sp)
    800036ee:	e456                	sd	s5,8(sp)
    800036f0:	e05a                	sd	s6,0(sp)
    800036f2:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800036f4:	0001c717          	auipc	a4,0x1c
    800036f8:	3b872703          	lw	a4,952(a4) # 8001faac <sb+0xc>
    800036fc:	4785                	li	a5,1
    800036fe:	04e7f863          	bgeu	a5,a4,8000374e <ialloc+0x6e>
    80003702:	8aaa                	mv	s5,a0
    80003704:	8b2e                	mv	s6,a1
    80003706:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003708:	0001ca17          	auipc	s4,0x1c
    8000370c:	398a0a13          	add	s4,s4,920 # 8001faa0 <sb>
    80003710:	00495593          	srl	a1,s2,0x4
    80003714:	018a2783          	lw	a5,24(s4)
    80003718:	9dbd                	addw	a1,a1,a5
    8000371a:	8556                	mv	a0,s5
    8000371c:	00000097          	auipc	ra,0x0
    80003720:	95e080e7          	jalr	-1698(ra) # 8000307a <bread>
    80003724:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003726:	06050993          	add	s3,a0,96
    8000372a:	00f97793          	and	a5,s2,15
    8000372e:	079a                	sll	a5,a5,0x6
    80003730:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003732:	00099783          	lh	a5,0(s3)
    80003736:	c785                	beqz	a5,8000375e <ialloc+0x7e>
    brelse(bp);
    80003738:	00000097          	auipc	ra,0x0
    8000373c:	a72080e7          	jalr	-1422(ra) # 800031aa <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003740:	0905                	add	s2,s2,1
    80003742:	00ca2703          	lw	a4,12(s4)
    80003746:	0009079b          	sext.w	a5,s2
    8000374a:	fce7e3e3          	bltu	a5,a4,80003710 <ialloc+0x30>
  panic("ialloc: no inodes");
    8000374e:	00005517          	auipc	a0,0x5
    80003752:	d7a50513          	add	a0,a0,-646 # 800084c8 <etext+0x4c8>
    80003756:	ffffd097          	auipc	ra,0xffffd
    8000375a:	e04080e7          	jalr	-508(ra) # 8000055a <panic>
      memset(dip, 0, sizeof(*dip));
    8000375e:	04000613          	li	a2,64
    80003762:	4581                	li	a1,0
    80003764:	854e                	mv	a0,s3
    80003766:	ffffd097          	auipc	ra,0xffffd
    8000376a:	5c8080e7          	jalr	1480(ra) # 80000d2e <memset>
      dip->type = type;
    8000376e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003772:	8526                	mv	a0,s1
    80003774:	00001097          	auipc	ra,0x1
    80003778:	caa080e7          	jalr	-854(ra) # 8000441e <log_write>
      brelse(bp);
    8000377c:	8526                	mv	a0,s1
    8000377e:	00000097          	auipc	ra,0x0
    80003782:	a2c080e7          	jalr	-1492(ra) # 800031aa <brelse>
      return iget(dev, inum);
    80003786:	0009059b          	sext.w	a1,s2
    8000378a:	8556                	mv	a0,s5
    8000378c:	00000097          	auipc	ra,0x0
    80003790:	db8080e7          	jalr	-584(ra) # 80003544 <iget>
}
    80003794:	70e2                	ld	ra,56(sp)
    80003796:	7442                	ld	s0,48(sp)
    80003798:	74a2                	ld	s1,40(sp)
    8000379a:	7902                	ld	s2,32(sp)
    8000379c:	69e2                	ld	s3,24(sp)
    8000379e:	6a42                	ld	s4,16(sp)
    800037a0:	6aa2                	ld	s5,8(sp)
    800037a2:	6b02                	ld	s6,0(sp)
    800037a4:	6121                	add	sp,sp,64
    800037a6:	8082                	ret

00000000800037a8 <iupdate>:
{
    800037a8:	1101                	add	sp,sp,-32
    800037aa:	ec06                	sd	ra,24(sp)
    800037ac:	e822                	sd	s0,16(sp)
    800037ae:	e426                	sd	s1,8(sp)
    800037b0:	e04a                	sd	s2,0(sp)
    800037b2:	1000                	add	s0,sp,32
    800037b4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037b6:	415c                	lw	a5,4(a0)
    800037b8:	0047d79b          	srlw	a5,a5,0x4
    800037bc:	0001c597          	auipc	a1,0x1c
    800037c0:	2fc5a583          	lw	a1,764(a1) # 8001fab8 <sb+0x18>
    800037c4:	9dbd                	addw	a1,a1,a5
    800037c6:	4108                	lw	a0,0(a0)
    800037c8:	00000097          	auipc	ra,0x0
    800037cc:	8b2080e7          	jalr	-1870(ra) # 8000307a <bread>
    800037d0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037d2:	06050793          	add	a5,a0,96
    800037d6:	40d8                	lw	a4,4(s1)
    800037d8:	8b3d                	and	a4,a4,15
    800037da:	071a                	sll	a4,a4,0x6
    800037dc:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800037de:	04c49703          	lh	a4,76(s1)
    800037e2:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800037e6:	04e49703          	lh	a4,78(s1)
    800037ea:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800037ee:	05049703          	lh	a4,80(s1)
    800037f2:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800037f6:	05249703          	lh	a4,82(s1)
    800037fa:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800037fe:	48f8                	lw	a4,84(s1)
    80003800:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003802:	03400613          	li	a2,52
    80003806:	05848593          	add	a1,s1,88
    8000380a:	00c78513          	add	a0,a5,12
    8000380e:	ffffd097          	auipc	ra,0xffffd
    80003812:	57c080e7          	jalr	1404(ra) # 80000d8a <memmove>
  log_write(bp);
    80003816:	854a                	mv	a0,s2
    80003818:	00001097          	auipc	ra,0x1
    8000381c:	c06080e7          	jalr	-1018(ra) # 8000441e <log_write>
  brelse(bp);
    80003820:	854a                	mv	a0,s2
    80003822:	00000097          	auipc	ra,0x0
    80003826:	988080e7          	jalr	-1656(ra) # 800031aa <brelse>
}
    8000382a:	60e2                	ld	ra,24(sp)
    8000382c:	6442                	ld	s0,16(sp)
    8000382e:	64a2                	ld	s1,8(sp)
    80003830:	6902                	ld	s2,0(sp)
    80003832:	6105                	add	sp,sp,32
    80003834:	8082                	ret

0000000080003836 <idup>:
{
    80003836:	1101                	add	sp,sp,-32
    80003838:	ec06                	sd	ra,24(sp)
    8000383a:	e822                	sd	s0,16(sp)
    8000383c:	e426                	sd	s1,8(sp)
    8000383e:	1000                	add	s0,sp,32
    80003840:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003842:	0001c517          	auipc	a0,0x1c
    80003846:	27e50513          	add	a0,a0,638 # 8001fac0 <itable>
    8000384a:	ffffd097          	auipc	ra,0xffffd
    8000384e:	3e8080e7          	jalr	1000(ra) # 80000c32 <acquire>
  ip->ref++;
    80003852:	449c                	lw	a5,8(s1)
    80003854:	2785                	addw	a5,a5,1
    80003856:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003858:	0001c517          	auipc	a0,0x1c
    8000385c:	26850513          	add	a0,a0,616 # 8001fac0 <itable>
    80003860:	ffffd097          	auipc	ra,0xffffd
    80003864:	486080e7          	jalr	1158(ra) # 80000ce6 <release>
}
    80003868:	8526                	mv	a0,s1
    8000386a:	60e2                	ld	ra,24(sp)
    8000386c:	6442                	ld	s0,16(sp)
    8000386e:	64a2                	ld	s1,8(sp)
    80003870:	6105                	add	sp,sp,32
    80003872:	8082                	ret

0000000080003874 <ilock>:
{
    80003874:	1101                	add	sp,sp,-32
    80003876:	ec06                	sd	ra,24(sp)
    80003878:	e822                	sd	s0,16(sp)
    8000387a:	e426                	sd	s1,8(sp)
    8000387c:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000387e:	c10d                	beqz	a0,800038a0 <ilock+0x2c>
    80003880:	84aa                	mv	s1,a0
    80003882:	451c                	lw	a5,8(a0)
    80003884:	00f05e63          	blez	a5,800038a0 <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003888:	0541                	add	a0,a0,16
    8000388a:	00001097          	auipc	ra,0x1
    8000388e:	d08080e7          	jalr	-760(ra) # 80004592 <acquiresleep>
  if(ip->valid == 0){
    80003892:	44bc                	lw	a5,72(s1)
    80003894:	cf99                	beqz	a5,800038b2 <ilock+0x3e>
}
    80003896:	60e2                	ld	ra,24(sp)
    80003898:	6442                	ld	s0,16(sp)
    8000389a:	64a2                	ld	s1,8(sp)
    8000389c:	6105                	add	sp,sp,32
    8000389e:	8082                	ret
    800038a0:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800038a2:	00005517          	auipc	a0,0x5
    800038a6:	c3e50513          	add	a0,a0,-962 # 800084e0 <etext+0x4e0>
    800038aa:	ffffd097          	auipc	ra,0xffffd
    800038ae:	cb0080e7          	jalr	-848(ra) # 8000055a <panic>
    800038b2:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038b4:	40dc                	lw	a5,4(s1)
    800038b6:	0047d79b          	srlw	a5,a5,0x4
    800038ba:	0001c597          	auipc	a1,0x1c
    800038be:	1fe5a583          	lw	a1,510(a1) # 8001fab8 <sb+0x18>
    800038c2:	9dbd                	addw	a1,a1,a5
    800038c4:	4088                	lw	a0,0(s1)
    800038c6:	fffff097          	auipc	ra,0xfffff
    800038ca:	7b4080e7          	jalr	1972(ra) # 8000307a <bread>
    800038ce:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038d0:	06050593          	add	a1,a0,96
    800038d4:	40dc                	lw	a5,4(s1)
    800038d6:	8bbd                	and	a5,a5,15
    800038d8:	079a                	sll	a5,a5,0x6
    800038da:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038dc:	00059783          	lh	a5,0(a1)
    800038e0:	04f49623          	sh	a5,76(s1)
    ip->major = dip->major;
    800038e4:	00259783          	lh	a5,2(a1)
    800038e8:	04f49723          	sh	a5,78(s1)
    ip->minor = dip->minor;
    800038ec:	00459783          	lh	a5,4(a1)
    800038f0:	04f49823          	sh	a5,80(s1)
    ip->nlink = dip->nlink;
    800038f4:	00659783          	lh	a5,6(a1)
    800038f8:	04f49923          	sh	a5,82(s1)
    ip->size = dip->size;
    800038fc:	459c                	lw	a5,8(a1)
    800038fe:	c8fc                	sw	a5,84(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003900:	03400613          	li	a2,52
    80003904:	05b1                	add	a1,a1,12
    80003906:	05848513          	add	a0,s1,88
    8000390a:	ffffd097          	auipc	ra,0xffffd
    8000390e:	480080e7          	jalr	1152(ra) # 80000d8a <memmove>
    brelse(bp);
    80003912:	854a                	mv	a0,s2
    80003914:	00000097          	auipc	ra,0x0
    80003918:	896080e7          	jalr	-1898(ra) # 800031aa <brelse>
    ip->valid = 1;
    8000391c:	4785                	li	a5,1
    8000391e:	c4bc                	sw	a5,72(s1)
    if(ip->type == 0)
    80003920:	04c49783          	lh	a5,76(s1)
    80003924:	c399                	beqz	a5,8000392a <ilock+0xb6>
    80003926:	6902                	ld	s2,0(sp)
    80003928:	b7bd                	j	80003896 <ilock+0x22>
      panic("ilock: no type");
    8000392a:	00005517          	auipc	a0,0x5
    8000392e:	bbe50513          	add	a0,a0,-1090 # 800084e8 <etext+0x4e8>
    80003932:	ffffd097          	auipc	ra,0xffffd
    80003936:	c28080e7          	jalr	-984(ra) # 8000055a <panic>

000000008000393a <iunlock>:
{
    8000393a:	1101                	add	sp,sp,-32
    8000393c:	ec06                	sd	ra,24(sp)
    8000393e:	e822                	sd	s0,16(sp)
    80003940:	e426                	sd	s1,8(sp)
    80003942:	e04a                	sd	s2,0(sp)
    80003944:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003946:	c905                	beqz	a0,80003976 <iunlock+0x3c>
    80003948:	84aa                	mv	s1,a0
    8000394a:	01050913          	add	s2,a0,16
    8000394e:	854a                	mv	a0,s2
    80003950:	00001097          	auipc	ra,0x1
    80003954:	bec080e7          	jalr	-1044(ra) # 8000453c <holdingsleep>
    80003958:	cd19                	beqz	a0,80003976 <iunlock+0x3c>
    8000395a:	449c                	lw	a5,8(s1)
    8000395c:	00f05d63          	blez	a5,80003976 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003960:	854a                	mv	a0,s2
    80003962:	00001097          	auipc	ra,0x1
    80003966:	cbc080e7          	jalr	-836(ra) # 8000461e <releasesleep>
}
    8000396a:	60e2                	ld	ra,24(sp)
    8000396c:	6442                	ld	s0,16(sp)
    8000396e:	64a2                	ld	s1,8(sp)
    80003970:	6902                	ld	s2,0(sp)
    80003972:	6105                	add	sp,sp,32
    80003974:	8082                	ret
    panic("iunlock");
    80003976:	00005517          	auipc	a0,0x5
    8000397a:	b8250513          	add	a0,a0,-1150 # 800084f8 <etext+0x4f8>
    8000397e:	ffffd097          	auipc	ra,0xffffd
    80003982:	bdc080e7          	jalr	-1060(ra) # 8000055a <panic>

0000000080003986 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003986:	7179                	add	sp,sp,-48
    80003988:	f406                	sd	ra,40(sp)
    8000398a:	f022                	sd	s0,32(sp)
    8000398c:	ec26                	sd	s1,24(sp)
    8000398e:	e84a                	sd	s2,16(sp)
    80003990:	e44e                	sd	s3,8(sp)
    80003992:	1800                	add	s0,sp,48
    80003994:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003996:	05850493          	add	s1,a0,88
    8000399a:	08850913          	add	s2,a0,136
    8000399e:	a021                	j	800039a6 <itrunc+0x20>
    800039a0:	0491                	add	s1,s1,4
    800039a2:	01248d63          	beq	s1,s2,800039bc <itrunc+0x36>
    if(ip->addrs[i]){
    800039a6:	408c                	lw	a1,0(s1)
    800039a8:	dde5                	beqz	a1,800039a0 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800039aa:	0009a503          	lw	a0,0(s3)
    800039ae:	00000097          	auipc	ra,0x0
    800039b2:	910080e7          	jalr	-1776(ra) # 800032be <bfree>
      ip->addrs[i] = 0;
    800039b6:	0004a023          	sw	zero,0(s1)
    800039ba:	b7dd                	j	800039a0 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039bc:	0889a583          	lw	a1,136(s3)
    800039c0:	ed99                	bnez	a1,800039de <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039c2:	0409aa23          	sw	zero,84(s3)
  iupdate(ip);
    800039c6:	854e                	mv	a0,s3
    800039c8:	00000097          	auipc	ra,0x0
    800039cc:	de0080e7          	jalr	-544(ra) # 800037a8 <iupdate>
}
    800039d0:	70a2                	ld	ra,40(sp)
    800039d2:	7402                	ld	s0,32(sp)
    800039d4:	64e2                	ld	s1,24(sp)
    800039d6:	6942                	ld	s2,16(sp)
    800039d8:	69a2                	ld	s3,8(sp)
    800039da:	6145                	add	sp,sp,48
    800039dc:	8082                	ret
    800039de:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039e0:	0009a503          	lw	a0,0(s3)
    800039e4:	fffff097          	auipc	ra,0xfffff
    800039e8:	696080e7          	jalr	1686(ra) # 8000307a <bread>
    800039ec:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039ee:	06050493          	add	s1,a0,96
    800039f2:	46050913          	add	s2,a0,1120
    800039f6:	a021                	j	800039fe <itrunc+0x78>
    800039f8:	0491                	add	s1,s1,4
    800039fa:	01248b63          	beq	s1,s2,80003a10 <itrunc+0x8a>
      if(a[j])
    800039fe:	408c                	lw	a1,0(s1)
    80003a00:	dde5                	beqz	a1,800039f8 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003a02:	0009a503          	lw	a0,0(s3)
    80003a06:	00000097          	auipc	ra,0x0
    80003a0a:	8b8080e7          	jalr	-1864(ra) # 800032be <bfree>
    80003a0e:	b7ed                	j	800039f8 <itrunc+0x72>
    brelse(bp);
    80003a10:	8552                	mv	a0,s4
    80003a12:	fffff097          	auipc	ra,0xfffff
    80003a16:	798080e7          	jalr	1944(ra) # 800031aa <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a1a:	0889a583          	lw	a1,136(s3)
    80003a1e:	0009a503          	lw	a0,0(s3)
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	89c080e7          	jalr	-1892(ra) # 800032be <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a2a:	0809a423          	sw	zero,136(s3)
    80003a2e:	6a02                	ld	s4,0(sp)
    80003a30:	bf49                	j	800039c2 <itrunc+0x3c>

0000000080003a32 <iput>:
{
    80003a32:	1101                	add	sp,sp,-32
    80003a34:	ec06                	sd	ra,24(sp)
    80003a36:	e822                	sd	s0,16(sp)
    80003a38:	e426                	sd	s1,8(sp)
    80003a3a:	1000                	add	s0,sp,32
    80003a3c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a3e:	0001c517          	auipc	a0,0x1c
    80003a42:	08250513          	add	a0,a0,130 # 8001fac0 <itable>
    80003a46:	ffffd097          	auipc	ra,0xffffd
    80003a4a:	1ec080e7          	jalr	492(ra) # 80000c32 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a4e:	4498                	lw	a4,8(s1)
    80003a50:	4785                	li	a5,1
    80003a52:	02f70263          	beq	a4,a5,80003a76 <iput+0x44>
  ip->ref--;
    80003a56:	449c                	lw	a5,8(s1)
    80003a58:	37fd                	addw	a5,a5,-1
    80003a5a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a5c:	0001c517          	auipc	a0,0x1c
    80003a60:	06450513          	add	a0,a0,100 # 8001fac0 <itable>
    80003a64:	ffffd097          	auipc	ra,0xffffd
    80003a68:	282080e7          	jalr	642(ra) # 80000ce6 <release>
}
    80003a6c:	60e2                	ld	ra,24(sp)
    80003a6e:	6442                	ld	s0,16(sp)
    80003a70:	64a2                	ld	s1,8(sp)
    80003a72:	6105                	add	sp,sp,32
    80003a74:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a76:	44bc                	lw	a5,72(s1)
    80003a78:	dff9                	beqz	a5,80003a56 <iput+0x24>
    80003a7a:	05249783          	lh	a5,82(s1)
    80003a7e:	ffe1                	bnez	a5,80003a56 <iput+0x24>
    80003a80:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003a82:	01048913          	add	s2,s1,16
    80003a86:	854a                	mv	a0,s2
    80003a88:	00001097          	auipc	ra,0x1
    80003a8c:	b0a080e7          	jalr	-1270(ra) # 80004592 <acquiresleep>
    release(&itable.lock);
    80003a90:	0001c517          	auipc	a0,0x1c
    80003a94:	03050513          	add	a0,a0,48 # 8001fac0 <itable>
    80003a98:	ffffd097          	auipc	ra,0xffffd
    80003a9c:	24e080e7          	jalr	590(ra) # 80000ce6 <release>
    itrunc(ip);
    80003aa0:	8526                	mv	a0,s1
    80003aa2:	00000097          	auipc	ra,0x0
    80003aa6:	ee4080e7          	jalr	-284(ra) # 80003986 <itrunc>
    ip->type = 0;
    80003aaa:	04049623          	sh	zero,76(s1)
    iupdate(ip);
    80003aae:	8526                	mv	a0,s1
    80003ab0:	00000097          	auipc	ra,0x0
    80003ab4:	cf8080e7          	jalr	-776(ra) # 800037a8 <iupdate>
    ip->valid = 0;
    80003ab8:	0404a423          	sw	zero,72(s1)
    releasesleep(&ip->lock);
    80003abc:	854a                	mv	a0,s2
    80003abe:	00001097          	auipc	ra,0x1
    80003ac2:	b60080e7          	jalr	-1184(ra) # 8000461e <releasesleep>
    acquire(&itable.lock);
    80003ac6:	0001c517          	auipc	a0,0x1c
    80003aca:	ffa50513          	add	a0,a0,-6 # 8001fac0 <itable>
    80003ace:	ffffd097          	auipc	ra,0xffffd
    80003ad2:	164080e7          	jalr	356(ra) # 80000c32 <acquire>
    80003ad6:	6902                	ld	s2,0(sp)
    80003ad8:	bfbd                	j	80003a56 <iput+0x24>

0000000080003ada <iunlockput>:
{
    80003ada:	1101                	add	sp,sp,-32
    80003adc:	ec06                	sd	ra,24(sp)
    80003ade:	e822                	sd	s0,16(sp)
    80003ae0:	e426                	sd	s1,8(sp)
    80003ae2:	1000                	add	s0,sp,32
    80003ae4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ae6:	00000097          	auipc	ra,0x0
    80003aea:	e54080e7          	jalr	-428(ra) # 8000393a <iunlock>
  iput(ip);
    80003aee:	8526                	mv	a0,s1
    80003af0:	00000097          	auipc	ra,0x0
    80003af4:	f42080e7          	jalr	-190(ra) # 80003a32 <iput>
}
    80003af8:	60e2                	ld	ra,24(sp)
    80003afa:	6442                	ld	s0,16(sp)
    80003afc:	64a2                	ld	s1,8(sp)
    80003afe:	6105                	add	sp,sp,32
    80003b00:	8082                	ret

0000000080003b02 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b02:	1141                	add	sp,sp,-16
    80003b04:	e422                	sd	s0,8(sp)
    80003b06:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003b08:	411c                	lw	a5,0(a0)
    80003b0a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b0c:	415c                	lw	a5,4(a0)
    80003b0e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b10:	04c51783          	lh	a5,76(a0)
    80003b14:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b18:	05251783          	lh	a5,82(a0)
    80003b1c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b20:	05456783          	lwu	a5,84(a0)
    80003b24:	e99c                	sd	a5,16(a1)
}
    80003b26:	6422                	ld	s0,8(sp)
    80003b28:	0141                	add	sp,sp,16
    80003b2a:	8082                	ret

0000000080003b2c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b2c:	497c                	lw	a5,84(a0)
    80003b2e:	0ed7ef63          	bltu	a5,a3,80003c2c <readi+0x100>
{
    80003b32:	7159                	add	sp,sp,-112
    80003b34:	f486                	sd	ra,104(sp)
    80003b36:	f0a2                	sd	s0,96(sp)
    80003b38:	eca6                	sd	s1,88(sp)
    80003b3a:	fc56                	sd	s5,56(sp)
    80003b3c:	f85a                	sd	s6,48(sp)
    80003b3e:	f45e                	sd	s7,40(sp)
    80003b40:	f062                	sd	s8,32(sp)
    80003b42:	1880                	add	s0,sp,112
    80003b44:	8baa                	mv	s7,a0
    80003b46:	8c2e                	mv	s8,a1
    80003b48:	8ab2                	mv	s5,a2
    80003b4a:	84b6                	mv	s1,a3
    80003b4c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b4e:	9f35                	addw	a4,a4,a3
    return 0;
    80003b50:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b52:	0ad76c63          	bltu	a4,a3,80003c0a <readi+0xde>
    80003b56:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003b58:	00e7f463          	bgeu	a5,a4,80003b60 <readi+0x34>
    n = ip->size - off;
    80003b5c:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b60:	0c0b0463          	beqz	s6,80003c28 <readi+0xfc>
    80003b64:	e8ca                	sd	s2,80(sp)
    80003b66:	e0d2                	sd	s4,64(sp)
    80003b68:	ec66                	sd	s9,24(sp)
    80003b6a:	e86a                	sd	s10,16(sp)
    80003b6c:	e46e                	sd	s11,8(sp)
    80003b6e:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b70:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b74:	5cfd                	li	s9,-1
    80003b76:	a82d                	j	80003bb0 <readi+0x84>
    80003b78:	020a1d93          	sll	s11,s4,0x20
    80003b7c:	020ddd93          	srl	s11,s11,0x20
    80003b80:	06090613          	add	a2,s2,96
    80003b84:	86ee                	mv	a3,s11
    80003b86:	963a                	add	a2,a2,a4
    80003b88:	85d6                	mv	a1,s5
    80003b8a:	8562                	mv	a0,s8
    80003b8c:	fffff097          	auipc	ra,0xfffff
    80003b90:	90e080e7          	jalr	-1778(ra) # 8000249a <either_copyout>
    80003b94:	05950d63          	beq	a0,s9,80003bee <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b98:	854a                	mv	a0,s2
    80003b9a:	fffff097          	auipc	ra,0xfffff
    80003b9e:	610080e7          	jalr	1552(ra) # 800031aa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ba2:	013a09bb          	addw	s3,s4,s3
    80003ba6:	009a04bb          	addw	s1,s4,s1
    80003baa:	9aee                	add	s5,s5,s11
    80003bac:	0769f863          	bgeu	s3,s6,80003c1c <readi+0xf0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003bb0:	000ba903          	lw	s2,0(s7)
    80003bb4:	00a4d59b          	srlw	a1,s1,0xa
    80003bb8:	855e                	mv	a0,s7
    80003bba:	00000097          	auipc	ra,0x0
    80003bbe:	8ae080e7          	jalr	-1874(ra) # 80003468 <bmap>
    80003bc2:	0005059b          	sext.w	a1,a0
    80003bc6:	854a                	mv	a0,s2
    80003bc8:	fffff097          	auipc	ra,0xfffff
    80003bcc:	4b2080e7          	jalr	1202(ra) # 8000307a <bread>
    80003bd0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bd2:	3ff4f713          	and	a4,s1,1023
    80003bd6:	40ed07bb          	subw	a5,s10,a4
    80003bda:	413b06bb          	subw	a3,s6,s3
    80003bde:	8a3e                	mv	s4,a5
    80003be0:	2781                	sext.w	a5,a5
    80003be2:	0006861b          	sext.w	a2,a3
    80003be6:	f8f679e3          	bgeu	a2,a5,80003b78 <readi+0x4c>
    80003bea:	8a36                	mv	s4,a3
    80003bec:	b771                	j	80003b78 <readi+0x4c>
      brelse(bp);
    80003bee:	854a                	mv	a0,s2
    80003bf0:	fffff097          	auipc	ra,0xfffff
    80003bf4:	5ba080e7          	jalr	1466(ra) # 800031aa <brelse>
      tot = -1;
    80003bf8:	59fd                	li	s3,-1
      break;
    80003bfa:	6946                	ld	s2,80(sp)
    80003bfc:	6a06                	ld	s4,64(sp)
    80003bfe:	6ce2                	ld	s9,24(sp)
    80003c00:	6d42                	ld	s10,16(sp)
    80003c02:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003c04:	0009851b          	sext.w	a0,s3
    80003c08:	69a6                	ld	s3,72(sp)
}
    80003c0a:	70a6                	ld	ra,104(sp)
    80003c0c:	7406                	ld	s0,96(sp)
    80003c0e:	64e6                	ld	s1,88(sp)
    80003c10:	7ae2                	ld	s5,56(sp)
    80003c12:	7b42                	ld	s6,48(sp)
    80003c14:	7ba2                	ld	s7,40(sp)
    80003c16:	7c02                	ld	s8,32(sp)
    80003c18:	6165                	add	sp,sp,112
    80003c1a:	8082                	ret
    80003c1c:	6946                	ld	s2,80(sp)
    80003c1e:	6a06                	ld	s4,64(sp)
    80003c20:	6ce2                	ld	s9,24(sp)
    80003c22:	6d42                	ld	s10,16(sp)
    80003c24:	6da2                	ld	s11,8(sp)
    80003c26:	bff9                	j	80003c04 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c28:	89da                	mv	s3,s6
    80003c2a:	bfe9                	j	80003c04 <readi+0xd8>
    return 0;
    80003c2c:	4501                	li	a0,0
}
    80003c2e:	8082                	ret

0000000080003c30 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c30:	497c                	lw	a5,84(a0)
    80003c32:	10d7ee63          	bltu	a5,a3,80003d4e <writei+0x11e>
{
    80003c36:	7159                	add	sp,sp,-112
    80003c38:	f486                	sd	ra,104(sp)
    80003c3a:	f0a2                	sd	s0,96(sp)
    80003c3c:	e8ca                	sd	s2,80(sp)
    80003c3e:	fc56                	sd	s5,56(sp)
    80003c40:	f85a                	sd	s6,48(sp)
    80003c42:	f45e                	sd	s7,40(sp)
    80003c44:	f062                	sd	s8,32(sp)
    80003c46:	1880                	add	s0,sp,112
    80003c48:	8b2a                	mv	s6,a0
    80003c4a:	8c2e                	mv	s8,a1
    80003c4c:	8ab2                	mv	s5,a2
    80003c4e:	8936                	mv	s2,a3
    80003c50:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003c52:	00e687bb          	addw	a5,a3,a4
    80003c56:	0ed7ee63          	bltu	a5,a3,80003d52 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c5a:	00043737          	lui	a4,0x43
    80003c5e:	0ef76c63          	bltu	a4,a5,80003d56 <writei+0x126>
    80003c62:	e0d2                	sd	s4,64(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c64:	0c0b8d63          	beqz	s7,80003d3e <writei+0x10e>
    80003c68:	eca6                	sd	s1,88(sp)
    80003c6a:	e4ce                	sd	s3,72(sp)
    80003c6c:	ec66                	sd	s9,24(sp)
    80003c6e:	e86a                	sd	s10,16(sp)
    80003c70:	e46e                	sd	s11,8(sp)
    80003c72:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c74:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c78:	5cfd                	li	s9,-1
    80003c7a:	a091                	j	80003cbe <writei+0x8e>
    80003c7c:	02099d93          	sll	s11,s3,0x20
    80003c80:	020ddd93          	srl	s11,s11,0x20
    80003c84:	06048513          	add	a0,s1,96
    80003c88:	86ee                	mv	a3,s11
    80003c8a:	8656                	mv	a2,s5
    80003c8c:	85e2                	mv	a1,s8
    80003c8e:	953a                	add	a0,a0,a4
    80003c90:	fffff097          	auipc	ra,0xfffff
    80003c94:	860080e7          	jalr	-1952(ra) # 800024f0 <either_copyin>
    80003c98:	07950263          	beq	a0,s9,80003cfc <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c9c:	8526                	mv	a0,s1
    80003c9e:	00000097          	auipc	ra,0x0
    80003ca2:	780080e7          	jalr	1920(ra) # 8000441e <log_write>
    brelse(bp);
    80003ca6:	8526                	mv	a0,s1
    80003ca8:	fffff097          	auipc	ra,0xfffff
    80003cac:	502080e7          	jalr	1282(ra) # 800031aa <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cb0:	01498a3b          	addw	s4,s3,s4
    80003cb4:	0129893b          	addw	s2,s3,s2
    80003cb8:	9aee                	add	s5,s5,s11
    80003cba:	057a7663          	bgeu	s4,s7,80003d06 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cbe:	000b2483          	lw	s1,0(s6)
    80003cc2:	00a9559b          	srlw	a1,s2,0xa
    80003cc6:	855a                	mv	a0,s6
    80003cc8:	fffff097          	auipc	ra,0xfffff
    80003ccc:	7a0080e7          	jalr	1952(ra) # 80003468 <bmap>
    80003cd0:	0005059b          	sext.w	a1,a0
    80003cd4:	8526                	mv	a0,s1
    80003cd6:	fffff097          	auipc	ra,0xfffff
    80003cda:	3a4080e7          	jalr	932(ra) # 8000307a <bread>
    80003cde:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ce0:	3ff97713          	and	a4,s2,1023
    80003ce4:	40ed07bb          	subw	a5,s10,a4
    80003ce8:	414b86bb          	subw	a3,s7,s4
    80003cec:	89be                	mv	s3,a5
    80003cee:	2781                	sext.w	a5,a5
    80003cf0:	0006861b          	sext.w	a2,a3
    80003cf4:	f8f674e3          	bgeu	a2,a5,80003c7c <writei+0x4c>
    80003cf8:	89b6                	mv	s3,a3
    80003cfa:	b749                	j	80003c7c <writei+0x4c>
      brelse(bp);
    80003cfc:	8526                	mv	a0,s1
    80003cfe:	fffff097          	auipc	ra,0xfffff
    80003d02:	4ac080e7          	jalr	1196(ra) # 800031aa <brelse>
  }

  if(off > ip->size)
    80003d06:	054b2783          	lw	a5,84(s6)
    80003d0a:	0327fc63          	bgeu	a5,s2,80003d42 <writei+0x112>
    ip->size = off;
    80003d0e:	052b2a23          	sw	s2,84(s6)
    80003d12:	64e6                	ld	s1,88(sp)
    80003d14:	69a6                	ld	s3,72(sp)
    80003d16:	6ce2                	ld	s9,24(sp)
    80003d18:	6d42                	ld	s10,16(sp)
    80003d1a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d1c:	855a                	mv	a0,s6
    80003d1e:	00000097          	auipc	ra,0x0
    80003d22:	a8a080e7          	jalr	-1398(ra) # 800037a8 <iupdate>

  return tot;
    80003d26:	000a051b          	sext.w	a0,s4
    80003d2a:	6a06                	ld	s4,64(sp)
}
    80003d2c:	70a6                	ld	ra,104(sp)
    80003d2e:	7406                	ld	s0,96(sp)
    80003d30:	6946                	ld	s2,80(sp)
    80003d32:	7ae2                	ld	s5,56(sp)
    80003d34:	7b42                	ld	s6,48(sp)
    80003d36:	7ba2                	ld	s7,40(sp)
    80003d38:	7c02                	ld	s8,32(sp)
    80003d3a:	6165                	add	sp,sp,112
    80003d3c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d3e:	8a5e                	mv	s4,s7
    80003d40:	bff1                	j	80003d1c <writei+0xec>
    80003d42:	64e6                	ld	s1,88(sp)
    80003d44:	69a6                	ld	s3,72(sp)
    80003d46:	6ce2                	ld	s9,24(sp)
    80003d48:	6d42                	ld	s10,16(sp)
    80003d4a:	6da2                	ld	s11,8(sp)
    80003d4c:	bfc1                	j	80003d1c <writei+0xec>
    return -1;
    80003d4e:	557d                	li	a0,-1
}
    80003d50:	8082                	ret
    return -1;
    80003d52:	557d                	li	a0,-1
    80003d54:	bfe1                	j	80003d2c <writei+0xfc>
    return -1;
    80003d56:	557d                	li	a0,-1
    80003d58:	bfd1                	j	80003d2c <writei+0xfc>

0000000080003d5a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d5a:	1141                	add	sp,sp,-16
    80003d5c:	e406                	sd	ra,8(sp)
    80003d5e:	e022                	sd	s0,0(sp)
    80003d60:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d62:	4639                	li	a2,14
    80003d64:	ffffd097          	auipc	ra,0xffffd
    80003d68:	09a080e7          	jalr	154(ra) # 80000dfe <strncmp>
}
    80003d6c:	60a2                	ld	ra,8(sp)
    80003d6e:	6402                	ld	s0,0(sp)
    80003d70:	0141                	add	sp,sp,16
    80003d72:	8082                	ret

0000000080003d74 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d74:	7139                	add	sp,sp,-64
    80003d76:	fc06                	sd	ra,56(sp)
    80003d78:	f822                	sd	s0,48(sp)
    80003d7a:	f426                	sd	s1,40(sp)
    80003d7c:	f04a                	sd	s2,32(sp)
    80003d7e:	ec4e                	sd	s3,24(sp)
    80003d80:	e852                	sd	s4,16(sp)
    80003d82:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d84:	04c51703          	lh	a4,76(a0)
    80003d88:	4785                	li	a5,1
    80003d8a:	00f71a63          	bne	a4,a5,80003d9e <dirlookup+0x2a>
    80003d8e:	892a                	mv	s2,a0
    80003d90:	89ae                	mv	s3,a1
    80003d92:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d94:	497c                	lw	a5,84(a0)
    80003d96:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d98:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d9a:	e79d                	bnez	a5,80003dc8 <dirlookup+0x54>
    80003d9c:	a8a5                	j	80003e14 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d9e:	00004517          	auipc	a0,0x4
    80003da2:	76250513          	add	a0,a0,1890 # 80008500 <etext+0x500>
    80003da6:	ffffc097          	auipc	ra,0xffffc
    80003daa:	7b4080e7          	jalr	1972(ra) # 8000055a <panic>
      panic("dirlookup read");
    80003dae:	00004517          	auipc	a0,0x4
    80003db2:	76a50513          	add	a0,a0,1898 # 80008518 <etext+0x518>
    80003db6:	ffffc097          	auipc	ra,0xffffc
    80003dba:	7a4080e7          	jalr	1956(ra) # 8000055a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dbe:	24c1                	addw	s1,s1,16
    80003dc0:	05492783          	lw	a5,84(s2)
    80003dc4:	04f4f763          	bgeu	s1,a5,80003e12 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dc8:	4741                	li	a4,16
    80003dca:	86a6                	mv	a3,s1
    80003dcc:	fc040613          	add	a2,s0,-64
    80003dd0:	4581                	li	a1,0
    80003dd2:	854a                	mv	a0,s2
    80003dd4:	00000097          	auipc	ra,0x0
    80003dd8:	d58080e7          	jalr	-680(ra) # 80003b2c <readi>
    80003ddc:	47c1                	li	a5,16
    80003dde:	fcf518e3          	bne	a0,a5,80003dae <dirlookup+0x3a>
    if(de.inum == 0)
    80003de2:	fc045783          	lhu	a5,-64(s0)
    80003de6:	dfe1                	beqz	a5,80003dbe <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003de8:	fc240593          	add	a1,s0,-62
    80003dec:	854e                	mv	a0,s3
    80003dee:	00000097          	auipc	ra,0x0
    80003df2:	f6c080e7          	jalr	-148(ra) # 80003d5a <namecmp>
    80003df6:	f561                	bnez	a0,80003dbe <dirlookup+0x4a>
      if(poff)
    80003df8:	000a0463          	beqz	s4,80003e00 <dirlookup+0x8c>
        *poff = off;
    80003dfc:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e00:	fc045583          	lhu	a1,-64(s0)
    80003e04:	00092503          	lw	a0,0(s2)
    80003e08:	fffff097          	auipc	ra,0xfffff
    80003e0c:	73c080e7          	jalr	1852(ra) # 80003544 <iget>
    80003e10:	a011                	j	80003e14 <dirlookup+0xa0>
  return 0;
    80003e12:	4501                	li	a0,0
}
    80003e14:	70e2                	ld	ra,56(sp)
    80003e16:	7442                	ld	s0,48(sp)
    80003e18:	74a2                	ld	s1,40(sp)
    80003e1a:	7902                	ld	s2,32(sp)
    80003e1c:	69e2                	ld	s3,24(sp)
    80003e1e:	6a42                	ld	s4,16(sp)
    80003e20:	6121                	add	sp,sp,64
    80003e22:	8082                	ret

0000000080003e24 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e24:	711d                	add	sp,sp,-96
    80003e26:	ec86                	sd	ra,88(sp)
    80003e28:	e8a2                	sd	s0,80(sp)
    80003e2a:	e4a6                	sd	s1,72(sp)
    80003e2c:	e0ca                	sd	s2,64(sp)
    80003e2e:	fc4e                	sd	s3,56(sp)
    80003e30:	f852                	sd	s4,48(sp)
    80003e32:	f456                	sd	s5,40(sp)
    80003e34:	f05a                	sd	s6,32(sp)
    80003e36:	ec5e                	sd	s7,24(sp)
    80003e38:	e862                	sd	s8,16(sp)
    80003e3a:	e466                	sd	s9,8(sp)
    80003e3c:	1080                	add	s0,sp,96
    80003e3e:	84aa                	mv	s1,a0
    80003e40:	8b2e                	mv	s6,a1
    80003e42:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e44:	00054703          	lbu	a4,0(a0)
    80003e48:	02f00793          	li	a5,47
    80003e4c:	02f70263          	beq	a4,a5,80003e70 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e50:	ffffe097          	auipc	ra,0xffffe
    80003e54:	be0080e7          	jalr	-1056(ra) # 80001a30 <myproc>
    80003e58:	15053503          	ld	a0,336(a0)
    80003e5c:	00000097          	auipc	ra,0x0
    80003e60:	9da080e7          	jalr	-1574(ra) # 80003836 <idup>
    80003e64:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e66:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003e6a:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e6c:	4b85                	li	s7,1
    80003e6e:	a875                	j	80003f2a <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003e70:	4585                	li	a1,1
    80003e72:	4505                	li	a0,1
    80003e74:	fffff097          	auipc	ra,0xfffff
    80003e78:	6d0080e7          	jalr	1744(ra) # 80003544 <iget>
    80003e7c:	8a2a                	mv	s4,a0
    80003e7e:	b7e5                	j	80003e66 <namex+0x42>
      iunlockput(ip);
    80003e80:	8552                	mv	a0,s4
    80003e82:	00000097          	auipc	ra,0x0
    80003e86:	c58080e7          	jalr	-936(ra) # 80003ada <iunlockput>
      return 0;
    80003e8a:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e8c:	8552                	mv	a0,s4
    80003e8e:	60e6                	ld	ra,88(sp)
    80003e90:	6446                	ld	s0,80(sp)
    80003e92:	64a6                	ld	s1,72(sp)
    80003e94:	6906                	ld	s2,64(sp)
    80003e96:	79e2                	ld	s3,56(sp)
    80003e98:	7a42                	ld	s4,48(sp)
    80003e9a:	7aa2                	ld	s5,40(sp)
    80003e9c:	7b02                	ld	s6,32(sp)
    80003e9e:	6be2                	ld	s7,24(sp)
    80003ea0:	6c42                	ld	s8,16(sp)
    80003ea2:	6ca2                	ld	s9,8(sp)
    80003ea4:	6125                	add	sp,sp,96
    80003ea6:	8082                	ret
      iunlock(ip);
    80003ea8:	8552                	mv	a0,s4
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	a90080e7          	jalr	-1392(ra) # 8000393a <iunlock>
      return ip;
    80003eb2:	bfe9                	j	80003e8c <namex+0x68>
      iunlockput(ip);
    80003eb4:	8552                	mv	a0,s4
    80003eb6:	00000097          	auipc	ra,0x0
    80003eba:	c24080e7          	jalr	-988(ra) # 80003ada <iunlockput>
      return 0;
    80003ebe:	8a4e                	mv	s4,s3
    80003ec0:	b7f1                	j	80003e8c <namex+0x68>
  len = path - s;
    80003ec2:	40998633          	sub	a2,s3,s1
    80003ec6:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003eca:	099c5863          	bge	s8,s9,80003f5a <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003ece:	4639                	li	a2,14
    80003ed0:	85a6                	mv	a1,s1
    80003ed2:	8556                	mv	a0,s5
    80003ed4:	ffffd097          	auipc	ra,0xffffd
    80003ed8:	eb6080e7          	jalr	-330(ra) # 80000d8a <memmove>
    80003edc:	84ce                	mv	s1,s3
  while(*path == '/')
    80003ede:	0004c783          	lbu	a5,0(s1)
    80003ee2:	01279763          	bne	a5,s2,80003ef0 <namex+0xcc>
    path++;
    80003ee6:	0485                	add	s1,s1,1
  while(*path == '/')
    80003ee8:	0004c783          	lbu	a5,0(s1)
    80003eec:	ff278de3          	beq	a5,s2,80003ee6 <namex+0xc2>
    ilock(ip);
    80003ef0:	8552                	mv	a0,s4
    80003ef2:	00000097          	auipc	ra,0x0
    80003ef6:	982080e7          	jalr	-1662(ra) # 80003874 <ilock>
    if(ip->type != T_DIR){
    80003efa:	04ca1783          	lh	a5,76(s4)
    80003efe:	f97791e3          	bne	a5,s7,80003e80 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003f02:	000b0563          	beqz	s6,80003f0c <namex+0xe8>
    80003f06:	0004c783          	lbu	a5,0(s1)
    80003f0a:	dfd9                	beqz	a5,80003ea8 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f0c:	4601                	li	a2,0
    80003f0e:	85d6                	mv	a1,s5
    80003f10:	8552                	mv	a0,s4
    80003f12:	00000097          	auipc	ra,0x0
    80003f16:	e62080e7          	jalr	-414(ra) # 80003d74 <dirlookup>
    80003f1a:	89aa                	mv	s3,a0
    80003f1c:	dd41                	beqz	a0,80003eb4 <namex+0x90>
    iunlockput(ip);
    80003f1e:	8552                	mv	a0,s4
    80003f20:	00000097          	auipc	ra,0x0
    80003f24:	bba080e7          	jalr	-1094(ra) # 80003ada <iunlockput>
    ip = next;
    80003f28:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003f2a:	0004c783          	lbu	a5,0(s1)
    80003f2e:	01279763          	bne	a5,s2,80003f3c <namex+0x118>
    path++;
    80003f32:	0485                	add	s1,s1,1
  while(*path == '/')
    80003f34:	0004c783          	lbu	a5,0(s1)
    80003f38:	ff278de3          	beq	a5,s2,80003f32 <namex+0x10e>
  if(*path == 0)
    80003f3c:	cb9d                	beqz	a5,80003f72 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003f3e:	0004c783          	lbu	a5,0(s1)
    80003f42:	89a6                	mv	s3,s1
  len = path - s;
    80003f44:	4c81                	li	s9,0
    80003f46:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003f48:	01278963          	beq	a5,s2,80003f5a <namex+0x136>
    80003f4c:	dbbd                	beqz	a5,80003ec2 <namex+0x9e>
    path++;
    80003f4e:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80003f50:	0009c783          	lbu	a5,0(s3)
    80003f54:	ff279ce3          	bne	a5,s2,80003f4c <namex+0x128>
    80003f58:	b7ad                	j	80003ec2 <namex+0x9e>
    memmove(name, s, len);
    80003f5a:	2601                	sext.w	a2,a2
    80003f5c:	85a6                	mv	a1,s1
    80003f5e:	8556                	mv	a0,s5
    80003f60:	ffffd097          	auipc	ra,0xffffd
    80003f64:	e2a080e7          	jalr	-470(ra) # 80000d8a <memmove>
    name[len] = 0;
    80003f68:	9cd6                	add	s9,s9,s5
    80003f6a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003f6e:	84ce                	mv	s1,s3
    80003f70:	b7bd                	j	80003ede <namex+0xba>
  if(nameiparent){
    80003f72:	f00b0de3          	beqz	s6,80003e8c <namex+0x68>
    iput(ip);
    80003f76:	8552                	mv	a0,s4
    80003f78:	00000097          	auipc	ra,0x0
    80003f7c:	aba080e7          	jalr	-1350(ra) # 80003a32 <iput>
    return 0;
    80003f80:	4a01                	li	s4,0
    80003f82:	b729                	j	80003e8c <namex+0x68>

0000000080003f84 <dirlink>:
{
    80003f84:	7139                	add	sp,sp,-64
    80003f86:	fc06                	sd	ra,56(sp)
    80003f88:	f822                	sd	s0,48(sp)
    80003f8a:	f04a                	sd	s2,32(sp)
    80003f8c:	ec4e                	sd	s3,24(sp)
    80003f8e:	e852                	sd	s4,16(sp)
    80003f90:	0080                	add	s0,sp,64
    80003f92:	892a                	mv	s2,a0
    80003f94:	8a2e                	mv	s4,a1
    80003f96:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f98:	4601                	li	a2,0
    80003f9a:	00000097          	auipc	ra,0x0
    80003f9e:	dda080e7          	jalr	-550(ra) # 80003d74 <dirlookup>
    80003fa2:	ed25                	bnez	a0,8000401a <dirlink+0x96>
    80003fa4:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fa6:	05492483          	lw	s1,84(s2)
    80003faa:	c49d                	beqz	s1,80003fd8 <dirlink+0x54>
    80003fac:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fae:	4741                	li	a4,16
    80003fb0:	86a6                	mv	a3,s1
    80003fb2:	fc040613          	add	a2,s0,-64
    80003fb6:	4581                	li	a1,0
    80003fb8:	854a                	mv	a0,s2
    80003fba:	00000097          	auipc	ra,0x0
    80003fbe:	b72080e7          	jalr	-1166(ra) # 80003b2c <readi>
    80003fc2:	47c1                	li	a5,16
    80003fc4:	06f51163          	bne	a0,a5,80004026 <dirlink+0xa2>
    if(de.inum == 0)
    80003fc8:	fc045783          	lhu	a5,-64(s0)
    80003fcc:	c791                	beqz	a5,80003fd8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fce:	24c1                	addw	s1,s1,16
    80003fd0:	05492783          	lw	a5,84(s2)
    80003fd4:	fcf4ede3          	bltu	s1,a5,80003fae <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fd8:	4639                	li	a2,14
    80003fda:	85d2                	mv	a1,s4
    80003fdc:	fc240513          	add	a0,s0,-62
    80003fe0:	ffffd097          	auipc	ra,0xffffd
    80003fe4:	e54080e7          	jalr	-428(ra) # 80000e34 <strncpy>
  de.inum = inum;
    80003fe8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fec:	4741                	li	a4,16
    80003fee:	86a6                	mv	a3,s1
    80003ff0:	fc040613          	add	a2,s0,-64
    80003ff4:	4581                	li	a1,0
    80003ff6:	854a                	mv	a0,s2
    80003ff8:	00000097          	auipc	ra,0x0
    80003ffc:	c38080e7          	jalr	-968(ra) # 80003c30 <writei>
    80004000:	872a                	mv	a4,a0
    80004002:	47c1                	li	a5,16
  return 0;
    80004004:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004006:	02f71863          	bne	a4,a5,80004036 <dirlink+0xb2>
    8000400a:	74a2                	ld	s1,40(sp)
}
    8000400c:	70e2                	ld	ra,56(sp)
    8000400e:	7442                	ld	s0,48(sp)
    80004010:	7902                	ld	s2,32(sp)
    80004012:	69e2                	ld	s3,24(sp)
    80004014:	6a42                	ld	s4,16(sp)
    80004016:	6121                	add	sp,sp,64
    80004018:	8082                	ret
    iput(ip);
    8000401a:	00000097          	auipc	ra,0x0
    8000401e:	a18080e7          	jalr	-1512(ra) # 80003a32 <iput>
    return -1;
    80004022:	557d                	li	a0,-1
    80004024:	b7e5                	j	8000400c <dirlink+0x88>
      panic("dirlink read");
    80004026:	00004517          	auipc	a0,0x4
    8000402a:	50250513          	add	a0,a0,1282 # 80008528 <etext+0x528>
    8000402e:	ffffc097          	auipc	ra,0xffffc
    80004032:	52c080e7          	jalr	1324(ra) # 8000055a <panic>
    panic("dirlink");
    80004036:	00004517          	auipc	a0,0x4
    8000403a:	60250513          	add	a0,a0,1538 # 80008638 <etext+0x638>
    8000403e:	ffffc097          	auipc	ra,0xffffc
    80004042:	51c080e7          	jalr	1308(ra) # 8000055a <panic>

0000000080004046 <namei>:

struct inode*
namei(char *path)
{
    80004046:	1101                	add	sp,sp,-32
    80004048:	ec06                	sd	ra,24(sp)
    8000404a:	e822                	sd	s0,16(sp)
    8000404c:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000404e:	fe040613          	add	a2,s0,-32
    80004052:	4581                	li	a1,0
    80004054:	00000097          	auipc	ra,0x0
    80004058:	dd0080e7          	jalr	-560(ra) # 80003e24 <namex>
}
    8000405c:	60e2                	ld	ra,24(sp)
    8000405e:	6442                	ld	s0,16(sp)
    80004060:	6105                	add	sp,sp,32
    80004062:	8082                	ret

0000000080004064 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004064:	1141                	add	sp,sp,-16
    80004066:	e406                	sd	ra,8(sp)
    80004068:	e022                	sd	s0,0(sp)
    8000406a:	0800                	add	s0,sp,16
    8000406c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000406e:	4585                	li	a1,1
    80004070:	00000097          	auipc	ra,0x0
    80004074:	db4080e7          	jalr	-588(ra) # 80003e24 <namex>
}
    80004078:	60a2                	ld	ra,8(sp)
    8000407a:	6402                	ld	s0,0(sp)
    8000407c:	0141                	add	sp,sp,16
    8000407e:	8082                	ret

0000000080004080 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004080:	1101                	add	sp,sp,-32
    80004082:	ec06                	sd	ra,24(sp)
    80004084:	e822                	sd	s0,16(sp)
    80004086:	e426                	sd	s1,8(sp)
    80004088:	e04a                	sd	s2,0(sp)
    8000408a:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000408c:	0001d917          	auipc	s2,0x1d
    80004090:	66c90913          	add	s2,s2,1644 # 800216f8 <log>
    80004094:	01892583          	lw	a1,24(s2)
    80004098:	02892503          	lw	a0,40(s2)
    8000409c:	fffff097          	auipc	ra,0xfffff
    800040a0:	fde080e7          	jalr	-34(ra) # 8000307a <bread>
    800040a4:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040a6:	02c92603          	lw	a2,44(s2)
    800040aa:	d130                	sw	a2,96(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040ac:	00c05f63          	blez	a2,800040ca <write_head+0x4a>
    800040b0:	0001d717          	auipc	a4,0x1d
    800040b4:	67870713          	add	a4,a4,1656 # 80021728 <log+0x30>
    800040b8:	87aa                	mv	a5,a0
    800040ba:	060a                	sll	a2,a2,0x2
    800040bc:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800040be:	4314                	lw	a3,0(a4)
    800040c0:	d3f4                	sw	a3,100(a5)
  for (i = 0; i < log.lh.n; i++) {
    800040c2:	0711                	add	a4,a4,4
    800040c4:	0791                	add	a5,a5,4
    800040c6:	fec79ce3          	bne	a5,a2,800040be <write_head+0x3e>
  }
  bwrite(buf);
    800040ca:	8526                	mv	a0,s1
    800040cc:	fffff097          	auipc	ra,0xfffff
    800040d0:	0a0080e7          	jalr	160(ra) # 8000316c <bwrite>
  brelse(buf);
    800040d4:	8526                	mv	a0,s1
    800040d6:	fffff097          	auipc	ra,0xfffff
    800040da:	0d4080e7          	jalr	212(ra) # 800031aa <brelse>
}
    800040de:	60e2                	ld	ra,24(sp)
    800040e0:	6442                	ld	s0,16(sp)
    800040e2:	64a2                	ld	s1,8(sp)
    800040e4:	6902                	ld	s2,0(sp)
    800040e6:	6105                	add	sp,sp,32
    800040e8:	8082                	ret

00000000800040ea <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040ea:	0001d797          	auipc	a5,0x1d
    800040ee:	63a7a783          	lw	a5,1594(a5) # 80021724 <log+0x2c>
    800040f2:	0af05d63          	blez	a5,800041ac <install_trans+0xc2>
{
    800040f6:	7139                	add	sp,sp,-64
    800040f8:	fc06                	sd	ra,56(sp)
    800040fa:	f822                	sd	s0,48(sp)
    800040fc:	f426                	sd	s1,40(sp)
    800040fe:	f04a                	sd	s2,32(sp)
    80004100:	ec4e                	sd	s3,24(sp)
    80004102:	e852                	sd	s4,16(sp)
    80004104:	e456                	sd	s5,8(sp)
    80004106:	e05a                	sd	s6,0(sp)
    80004108:	0080                	add	s0,sp,64
    8000410a:	8b2a                	mv	s6,a0
    8000410c:	0001da97          	auipc	s5,0x1d
    80004110:	61ca8a93          	add	s5,s5,1564 # 80021728 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004114:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004116:	0001d997          	auipc	s3,0x1d
    8000411a:	5e298993          	add	s3,s3,1506 # 800216f8 <log>
    8000411e:	a00d                	j	80004140 <install_trans+0x56>
    brelse(lbuf);
    80004120:	854a                	mv	a0,s2
    80004122:	fffff097          	auipc	ra,0xfffff
    80004126:	088080e7          	jalr	136(ra) # 800031aa <brelse>
    brelse(dbuf);
    8000412a:	8526                	mv	a0,s1
    8000412c:	fffff097          	auipc	ra,0xfffff
    80004130:	07e080e7          	jalr	126(ra) # 800031aa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004134:	2a05                	addw	s4,s4,1
    80004136:	0a91                	add	s5,s5,4
    80004138:	02c9a783          	lw	a5,44(s3)
    8000413c:	04fa5e63          	bge	s4,a5,80004198 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004140:	0189a583          	lw	a1,24(s3)
    80004144:	014585bb          	addw	a1,a1,s4
    80004148:	2585                	addw	a1,a1,1
    8000414a:	0289a503          	lw	a0,40(s3)
    8000414e:	fffff097          	auipc	ra,0xfffff
    80004152:	f2c080e7          	jalr	-212(ra) # 8000307a <bread>
    80004156:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004158:	000aa583          	lw	a1,0(s5)
    8000415c:	0289a503          	lw	a0,40(s3)
    80004160:	fffff097          	auipc	ra,0xfffff
    80004164:	f1a080e7          	jalr	-230(ra) # 8000307a <bread>
    80004168:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000416a:	40000613          	li	a2,1024
    8000416e:	06090593          	add	a1,s2,96
    80004172:	06050513          	add	a0,a0,96
    80004176:	ffffd097          	auipc	ra,0xffffd
    8000417a:	c14080e7          	jalr	-1004(ra) # 80000d8a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000417e:	8526                	mv	a0,s1
    80004180:	fffff097          	auipc	ra,0xfffff
    80004184:	fec080e7          	jalr	-20(ra) # 8000316c <bwrite>
    if(recovering == 0)
    80004188:	f80b1ce3          	bnez	s6,80004120 <install_trans+0x36>
      bunpin(dbuf);
    8000418c:	8526                	mv	a0,s1
    8000418e:	fffff097          	auipc	ra,0xfffff
    80004192:	0f4080e7          	jalr	244(ra) # 80003282 <bunpin>
    80004196:	b769                	j	80004120 <install_trans+0x36>
}
    80004198:	70e2                	ld	ra,56(sp)
    8000419a:	7442                	ld	s0,48(sp)
    8000419c:	74a2                	ld	s1,40(sp)
    8000419e:	7902                	ld	s2,32(sp)
    800041a0:	69e2                	ld	s3,24(sp)
    800041a2:	6a42                	ld	s4,16(sp)
    800041a4:	6aa2                	ld	s5,8(sp)
    800041a6:	6b02                	ld	s6,0(sp)
    800041a8:	6121                	add	sp,sp,64
    800041aa:	8082                	ret
    800041ac:	8082                	ret

00000000800041ae <initlog>:
{
    800041ae:	7179                	add	sp,sp,-48
    800041b0:	f406                	sd	ra,40(sp)
    800041b2:	f022                	sd	s0,32(sp)
    800041b4:	ec26                	sd	s1,24(sp)
    800041b6:	e84a                	sd	s2,16(sp)
    800041b8:	e44e                	sd	s3,8(sp)
    800041ba:	1800                	add	s0,sp,48
    800041bc:	892a                	mv	s2,a0
    800041be:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041c0:	0001d497          	auipc	s1,0x1d
    800041c4:	53848493          	add	s1,s1,1336 # 800216f8 <log>
    800041c8:	00004597          	auipc	a1,0x4
    800041cc:	37058593          	add	a1,a1,880 # 80008538 <etext+0x538>
    800041d0:	8526                	mv	a0,s1
    800041d2:	ffffd097          	auipc	ra,0xffffd
    800041d6:	9d0080e7          	jalr	-1584(ra) # 80000ba2 <initlock>
  log.start = sb->logstart;
    800041da:	0149a583          	lw	a1,20(s3)
    800041de:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041e0:	0109a783          	lw	a5,16(s3)
    800041e4:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041e6:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041ea:	854a                	mv	a0,s2
    800041ec:	fffff097          	auipc	ra,0xfffff
    800041f0:	e8e080e7          	jalr	-370(ra) # 8000307a <bread>
  log.lh.n = lh->n;
    800041f4:	5130                	lw	a2,96(a0)
    800041f6:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041f8:	00c05f63          	blez	a2,80004216 <initlog+0x68>
    800041fc:	87aa                	mv	a5,a0
    800041fe:	0001d717          	auipc	a4,0x1d
    80004202:	52a70713          	add	a4,a4,1322 # 80021728 <log+0x30>
    80004206:	060a                	sll	a2,a2,0x2
    80004208:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000420a:	53f4                	lw	a3,100(a5)
    8000420c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000420e:	0791                	add	a5,a5,4
    80004210:	0711                	add	a4,a4,4
    80004212:	fec79ce3          	bne	a5,a2,8000420a <initlog+0x5c>
  brelse(buf);
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	f94080e7          	jalr	-108(ra) # 800031aa <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000421e:	4505                	li	a0,1
    80004220:	00000097          	auipc	ra,0x0
    80004224:	eca080e7          	jalr	-310(ra) # 800040ea <install_trans>
  log.lh.n = 0;
    80004228:	0001d797          	auipc	a5,0x1d
    8000422c:	4e07ae23          	sw	zero,1276(a5) # 80021724 <log+0x2c>
  write_head(); // clear the log
    80004230:	00000097          	auipc	ra,0x0
    80004234:	e50080e7          	jalr	-432(ra) # 80004080 <write_head>
}
    80004238:	70a2                	ld	ra,40(sp)
    8000423a:	7402                	ld	s0,32(sp)
    8000423c:	64e2                	ld	s1,24(sp)
    8000423e:	6942                	ld	s2,16(sp)
    80004240:	69a2                	ld	s3,8(sp)
    80004242:	6145                	add	sp,sp,48
    80004244:	8082                	ret

0000000080004246 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004246:	1101                	add	sp,sp,-32
    80004248:	ec06                	sd	ra,24(sp)
    8000424a:	e822                	sd	s0,16(sp)
    8000424c:	e426                	sd	s1,8(sp)
    8000424e:	e04a                	sd	s2,0(sp)
    80004250:	1000                	add	s0,sp,32
  acquire(&log.lock);
    80004252:	0001d517          	auipc	a0,0x1d
    80004256:	4a650513          	add	a0,a0,1190 # 800216f8 <log>
    8000425a:	ffffd097          	auipc	ra,0xffffd
    8000425e:	9d8080e7          	jalr	-1576(ra) # 80000c32 <acquire>
  while(1){
    if(log.committing){
    80004262:	0001d497          	auipc	s1,0x1d
    80004266:	49648493          	add	s1,s1,1174 # 800216f8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000426a:	4979                	li	s2,30
    8000426c:	a039                	j	8000427a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000426e:	85a6                	mv	a1,s1
    80004270:	8526                	mv	a0,s1
    80004272:	ffffe097          	auipc	ra,0xffffe
    80004276:	e84080e7          	jalr	-380(ra) # 800020f6 <sleep>
    if(log.committing){
    8000427a:	50dc                	lw	a5,36(s1)
    8000427c:	fbed                	bnez	a5,8000426e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000427e:	5098                	lw	a4,32(s1)
    80004280:	2705                	addw	a4,a4,1
    80004282:	0027179b          	sllw	a5,a4,0x2
    80004286:	9fb9                	addw	a5,a5,a4
    80004288:	0017979b          	sllw	a5,a5,0x1
    8000428c:	54d4                	lw	a3,44(s1)
    8000428e:	9fb5                	addw	a5,a5,a3
    80004290:	00f95963          	bge	s2,a5,800042a2 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004294:	85a6                	mv	a1,s1
    80004296:	8526                	mv	a0,s1
    80004298:	ffffe097          	auipc	ra,0xffffe
    8000429c:	e5e080e7          	jalr	-418(ra) # 800020f6 <sleep>
    800042a0:	bfe9                	j	8000427a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800042a2:	0001d517          	auipc	a0,0x1d
    800042a6:	45650513          	add	a0,a0,1110 # 800216f8 <log>
    800042aa:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800042ac:	ffffd097          	auipc	ra,0xffffd
    800042b0:	a3a080e7          	jalr	-1478(ra) # 80000ce6 <release>
      break;
    }
  }
}
    800042b4:	60e2                	ld	ra,24(sp)
    800042b6:	6442                	ld	s0,16(sp)
    800042b8:	64a2                	ld	s1,8(sp)
    800042ba:	6902                	ld	s2,0(sp)
    800042bc:	6105                	add	sp,sp,32
    800042be:	8082                	ret

00000000800042c0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042c0:	7139                	add	sp,sp,-64
    800042c2:	fc06                	sd	ra,56(sp)
    800042c4:	f822                	sd	s0,48(sp)
    800042c6:	f426                	sd	s1,40(sp)
    800042c8:	f04a                	sd	s2,32(sp)
    800042ca:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042cc:	0001d497          	auipc	s1,0x1d
    800042d0:	42c48493          	add	s1,s1,1068 # 800216f8 <log>
    800042d4:	8526                	mv	a0,s1
    800042d6:	ffffd097          	auipc	ra,0xffffd
    800042da:	95c080e7          	jalr	-1700(ra) # 80000c32 <acquire>
  log.outstanding -= 1;
    800042de:	509c                	lw	a5,32(s1)
    800042e0:	37fd                	addw	a5,a5,-1
    800042e2:	0007891b          	sext.w	s2,a5
    800042e6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800042e8:	50dc                	lw	a5,36(s1)
    800042ea:	e7b9                	bnez	a5,80004338 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    800042ec:	06091163          	bnez	s2,8000434e <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800042f0:	0001d497          	auipc	s1,0x1d
    800042f4:	40848493          	add	s1,s1,1032 # 800216f8 <log>
    800042f8:	4785                	li	a5,1
    800042fa:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042fc:	8526                	mv	a0,s1
    800042fe:	ffffd097          	auipc	ra,0xffffd
    80004302:	9e8080e7          	jalr	-1560(ra) # 80000ce6 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004306:	54dc                	lw	a5,44(s1)
    80004308:	06f04763          	bgtz	a5,80004376 <end_op+0xb6>
    acquire(&log.lock);
    8000430c:	0001d497          	auipc	s1,0x1d
    80004310:	3ec48493          	add	s1,s1,1004 # 800216f8 <log>
    80004314:	8526                	mv	a0,s1
    80004316:	ffffd097          	auipc	ra,0xffffd
    8000431a:	91c080e7          	jalr	-1764(ra) # 80000c32 <acquire>
    log.committing = 0;
    8000431e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004322:	8526                	mv	a0,s1
    80004324:	ffffe097          	auipc	ra,0xffffe
    80004328:	f5e080e7          	jalr	-162(ra) # 80002282 <wakeup>
    release(&log.lock);
    8000432c:	8526                	mv	a0,s1
    8000432e:	ffffd097          	auipc	ra,0xffffd
    80004332:	9b8080e7          	jalr	-1608(ra) # 80000ce6 <release>
}
    80004336:	a815                	j	8000436a <end_op+0xaa>
    80004338:	ec4e                	sd	s3,24(sp)
    8000433a:	e852                	sd	s4,16(sp)
    8000433c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000433e:	00004517          	auipc	a0,0x4
    80004342:	20250513          	add	a0,a0,514 # 80008540 <etext+0x540>
    80004346:	ffffc097          	auipc	ra,0xffffc
    8000434a:	214080e7          	jalr	532(ra) # 8000055a <panic>
    wakeup(&log);
    8000434e:	0001d497          	auipc	s1,0x1d
    80004352:	3aa48493          	add	s1,s1,938 # 800216f8 <log>
    80004356:	8526                	mv	a0,s1
    80004358:	ffffe097          	auipc	ra,0xffffe
    8000435c:	f2a080e7          	jalr	-214(ra) # 80002282 <wakeup>
  release(&log.lock);
    80004360:	8526                	mv	a0,s1
    80004362:	ffffd097          	auipc	ra,0xffffd
    80004366:	984080e7          	jalr	-1660(ra) # 80000ce6 <release>
}
    8000436a:	70e2                	ld	ra,56(sp)
    8000436c:	7442                	ld	s0,48(sp)
    8000436e:	74a2                	ld	s1,40(sp)
    80004370:	7902                	ld	s2,32(sp)
    80004372:	6121                	add	sp,sp,64
    80004374:	8082                	ret
    80004376:	ec4e                	sd	s3,24(sp)
    80004378:	e852                	sd	s4,16(sp)
    8000437a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000437c:	0001da97          	auipc	s5,0x1d
    80004380:	3aca8a93          	add	s5,s5,940 # 80021728 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004384:	0001da17          	auipc	s4,0x1d
    80004388:	374a0a13          	add	s4,s4,884 # 800216f8 <log>
    8000438c:	018a2583          	lw	a1,24(s4)
    80004390:	012585bb          	addw	a1,a1,s2
    80004394:	2585                	addw	a1,a1,1
    80004396:	028a2503          	lw	a0,40(s4)
    8000439a:	fffff097          	auipc	ra,0xfffff
    8000439e:	ce0080e7          	jalr	-800(ra) # 8000307a <bread>
    800043a2:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043a4:	000aa583          	lw	a1,0(s5)
    800043a8:	028a2503          	lw	a0,40(s4)
    800043ac:	fffff097          	auipc	ra,0xfffff
    800043b0:	cce080e7          	jalr	-818(ra) # 8000307a <bread>
    800043b4:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800043b6:	40000613          	li	a2,1024
    800043ba:	06050593          	add	a1,a0,96
    800043be:	06048513          	add	a0,s1,96
    800043c2:	ffffd097          	auipc	ra,0xffffd
    800043c6:	9c8080e7          	jalr	-1592(ra) # 80000d8a <memmove>
    bwrite(to);  // write the log
    800043ca:	8526                	mv	a0,s1
    800043cc:	fffff097          	auipc	ra,0xfffff
    800043d0:	da0080e7          	jalr	-608(ra) # 8000316c <bwrite>
    brelse(from);
    800043d4:	854e                	mv	a0,s3
    800043d6:	fffff097          	auipc	ra,0xfffff
    800043da:	dd4080e7          	jalr	-556(ra) # 800031aa <brelse>
    brelse(to);
    800043de:	8526                	mv	a0,s1
    800043e0:	fffff097          	auipc	ra,0xfffff
    800043e4:	dca080e7          	jalr	-566(ra) # 800031aa <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043e8:	2905                	addw	s2,s2,1
    800043ea:	0a91                	add	s5,s5,4
    800043ec:	02ca2783          	lw	a5,44(s4)
    800043f0:	f8f94ee3          	blt	s2,a5,8000438c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043f4:	00000097          	auipc	ra,0x0
    800043f8:	c8c080e7          	jalr	-884(ra) # 80004080 <write_head>
    install_trans(0); // Now install writes to home locations
    800043fc:	4501                	li	a0,0
    800043fe:	00000097          	auipc	ra,0x0
    80004402:	cec080e7          	jalr	-788(ra) # 800040ea <install_trans>
    log.lh.n = 0;
    80004406:	0001d797          	auipc	a5,0x1d
    8000440a:	3007af23          	sw	zero,798(a5) # 80021724 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000440e:	00000097          	auipc	ra,0x0
    80004412:	c72080e7          	jalr	-910(ra) # 80004080 <write_head>
    80004416:	69e2                	ld	s3,24(sp)
    80004418:	6a42                	ld	s4,16(sp)
    8000441a:	6aa2                	ld	s5,8(sp)
    8000441c:	bdc5                	j	8000430c <end_op+0x4c>

000000008000441e <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000441e:	1101                	add	sp,sp,-32
    80004420:	ec06                	sd	ra,24(sp)
    80004422:	e822                	sd	s0,16(sp)
    80004424:	e426                	sd	s1,8(sp)
    80004426:	e04a                	sd	s2,0(sp)
    80004428:	1000                	add	s0,sp,32
    8000442a:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000442c:	0001d917          	auipc	s2,0x1d
    80004430:	2cc90913          	add	s2,s2,716 # 800216f8 <log>
    80004434:	854a                	mv	a0,s2
    80004436:	ffffc097          	auipc	ra,0xffffc
    8000443a:	7fc080e7          	jalr	2044(ra) # 80000c32 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000443e:	02c92603          	lw	a2,44(s2)
    80004442:	47f5                	li	a5,29
    80004444:	06c7c563          	blt	a5,a2,800044ae <log_write+0x90>
    80004448:	0001d797          	auipc	a5,0x1d
    8000444c:	2cc7a783          	lw	a5,716(a5) # 80021714 <log+0x1c>
    80004450:	37fd                	addw	a5,a5,-1
    80004452:	04f65e63          	bge	a2,a5,800044ae <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004456:	0001d797          	auipc	a5,0x1d
    8000445a:	2c27a783          	lw	a5,706(a5) # 80021718 <log+0x20>
    8000445e:	06f05063          	blez	a5,800044be <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004462:	4781                	li	a5,0
    80004464:	06c05563          	blez	a2,800044ce <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004468:	44cc                	lw	a1,12(s1)
    8000446a:	0001d717          	auipc	a4,0x1d
    8000446e:	2be70713          	add	a4,a4,702 # 80021728 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004472:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004474:	4314                	lw	a3,0(a4)
    80004476:	04b68c63          	beq	a3,a1,800044ce <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000447a:	2785                	addw	a5,a5,1
    8000447c:	0711                	add	a4,a4,4
    8000447e:	fef61be3          	bne	a2,a5,80004474 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004482:	0621                	add	a2,a2,8
    80004484:	060a                	sll	a2,a2,0x2
    80004486:	0001d797          	auipc	a5,0x1d
    8000448a:	27278793          	add	a5,a5,626 # 800216f8 <log>
    8000448e:	97b2                	add	a5,a5,a2
    80004490:	44d8                	lw	a4,12(s1)
    80004492:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004494:	8526                	mv	a0,s1
    80004496:	fffff097          	auipc	ra,0xfffff
    8000449a:	db0080e7          	jalr	-592(ra) # 80003246 <bpin>
    log.lh.n++;
    8000449e:	0001d717          	auipc	a4,0x1d
    800044a2:	25a70713          	add	a4,a4,602 # 800216f8 <log>
    800044a6:	575c                	lw	a5,44(a4)
    800044a8:	2785                	addw	a5,a5,1
    800044aa:	d75c                	sw	a5,44(a4)
    800044ac:	a82d                	j	800044e6 <log_write+0xc8>
    panic("too big a transaction");
    800044ae:	00004517          	auipc	a0,0x4
    800044b2:	0a250513          	add	a0,a0,162 # 80008550 <etext+0x550>
    800044b6:	ffffc097          	auipc	ra,0xffffc
    800044ba:	0a4080e7          	jalr	164(ra) # 8000055a <panic>
    panic("log_write outside of trans");
    800044be:	00004517          	auipc	a0,0x4
    800044c2:	0aa50513          	add	a0,a0,170 # 80008568 <etext+0x568>
    800044c6:	ffffc097          	auipc	ra,0xffffc
    800044ca:	094080e7          	jalr	148(ra) # 8000055a <panic>
  log.lh.block[i] = b->blockno;
    800044ce:	00878693          	add	a3,a5,8
    800044d2:	068a                	sll	a3,a3,0x2
    800044d4:	0001d717          	auipc	a4,0x1d
    800044d8:	22470713          	add	a4,a4,548 # 800216f8 <log>
    800044dc:	9736                	add	a4,a4,a3
    800044de:	44d4                	lw	a3,12(s1)
    800044e0:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800044e2:	faf609e3          	beq	a2,a5,80004494 <log_write+0x76>
  }
  release(&log.lock);
    800044e6:	0001d517          	auipc	a0,0x1d
    800044ea:	21250513          	add	a0,a0,530 # 800216f8 <log>
    800044ee:	ffffc097          	auipc	ra,0xffffc
    800044f2:	7f8080e7          	jalr	2040(ra) # 80000ce6 <release>
}
    800044f6:	60e2                	ld	ra,24(sp)
    800044f8:	6442                	ld	s0,16(sp)
    800044fa:	64a2                	ld	s1,8(sp)
    800044fc:	6902                	ld	s2,0(sp)
    800044fe:	6105                	add	sp,sp,32
    80004500:	8082                	ret

0000000080004502 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004502:	1101                	add	sp,sp,-32
    80004504:	ec06                	sd	ra,24(sp)
    80004506:	e822                	sd	s0,16(sp)
    80004508:	e426                	sd	s1,8(sp)
    8000450a:	e04a                	sd	s2,0(sp)
    8000450c:	1000                	add	s0,sp,32
    8000450e:	84aa                	mv	s1,a0
    80004510:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004512:	00004597          	auipc	a1,0x4
    80004516:	07658593          	add	a1,a1,118 # 80008588 <etext+0x588>
    8000451a:	0521                	add	a0,a0,8
    8000451c:	ffffc097          	auipc	ra,0xffffc
    80004520:	686080e7          	jalr	1670(ra) # 80000ba2 <initlock>
  lk->name = name;
    80004524:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004528:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000452c:	0204a423          	sw	zero,40(s1)
}
    80004530:	60e2                	ld	ra,24(sp)
    80004532:	6442                	ld	s0,16(sp)
    80004534:	64a2                	ld	s1,8(sp)
    80004536:	6902                	ld	s2,0(sp)
    80004538:	6105                	add	sp,sp,32
    8000453a:	8082                	ret

000000008000453c <holdingsleep>:
  release(&lk->lk);
}*/

int
holdingsleep(struct sleeplock *lk)
{
    8000453c:	7179                	add	sp,sp,-48
    8000453e:	f406                	sd	ra,40(sp)
    80004540:	f022                	sd	s0,32(sp)
    80004542:	ec26                	sd	s1,24(sp)
    80004544:	e84a                	sd	s2,16(sp)
    80004546:	1800                	add	s0,sp,48
    80004548:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000454a:	00850913          	add	s2,a0,8
    8000454e:	854a                	mv	a0,s2
    80004550:	ffffc097          	auipc	ra,0xffffc
    80004554:	6e2080e7          	jalr	1762(ra) # 80000c32 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004558:	409c                	lw	a5,0(s1)
    8000455a:	ef91                	bnez	a5,80004576 <holdingsleep+0x3a>
    8000455c:	4481                	li	s1,0
  release(&lk->lk);
    8000455e:	854a                	mv	a0,s2
    80004560:	ffffc097          	auipc	ra,0xffffc
    80004564:	786080e7          	jalr	1926(ra) # 80000ce6 <release>
  return r;
}
    80004568:	8526                	mv	a0,s1
    8000456a:	70a2                	ld	ra,40(sp)
    8000456c:	7402                	ld	s0,32(sp)
    8000456e:	64e2                	ld	s1,24(sp)
    80004570:	6942                	ld	s2,16(sp)
    80004572:	6145                	add	sp,sp,48
    80004574:	8082                	ret
    80004576:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004578:	0284a983          	lw	s3,40(s1)
    8000457c:	ffffd097          	auipc	ra,0xffffd
    80004580:	4b4080e7          	jalr	1204(ra) # 80001a30 <myproc>
    80004584:	5904                	lw	s1,48(a0)
    80004586:	413484b3          	sub	s1,s1,s3
    8000458a:	0014b493          	seqz	s1,s1
    8000458e:	69a2                	ld	s3,8(sp)
    80004590:	b7f9                	j	8000455e <holdingsleep+0x22>

0000000080004592 <acquiresleep>:


// Lab 9
void
acquiresleep(struct sleeplock *lk)
{
    80004592:	7179                	add	sp,sp,-48
    80004594:	f406                	sd	ra,40(sp)
    80004596:	f022                	sd	s0,32(sp)
    80004598:	e84a                	sd	s2,16(sp)
    8000459a:	e44e                	sd	s3,8(sp)
    8000459c:	1800                	add	s0,sp,48
    8000459e:	892a                	mv	s2,a0
  struct proc *p;

  acquire(&lk->lk);
    800045a0:	00850993          	add	s3,a0,8
    800045a4:	854e                	mv	a0,s3
    800045a6:	ffffc097          	auipc	ra,0xffffc
    800045aa:	68c080e7          	jalr	1676(ra) # 80000c32 <acquire>
  while (lk->locked) {
    800045ae:	00092783          	lw	a5,0(s2)
    800045b2:	c3a9                	beqz	a5,800045f4 <acquiresleep+0x62>
    800045b4:	ec26                	sd	s1,24(sp)
    800045b6:	a005                	j	800045d6 <acquiresleep+0x44>
    p = lk->head;
    if (p == 0) {
      lk->head = myproc();
    800045b8:	ffffd097          	auipc	ra,0xffffd
    800045bc:	478080e7          	jalr	1144(ra) # 80001a30 <myproc>
    800045c0:	02a93823          	sd	a0,48(s2)
      while (p->next) {
        p = p->next;
      }
      p->next = myproc();
    }
    sleep(lk, &lk->lk);
    800045c4:	85ce                	mv	a1,s3
    800045c6:	854a                	mv	a0,s2
    800045c8:	ffffe097          	auipc	ra,0xffffe
    800045cc:	b2e080e7          	jalr	-1234(ra) # 800020f6 <sleep>
  while (lk->locked) {
    800045d0:	00092783          	lw	a5,0(s2)
    800045d4:	cf99                	beqz	a5,800045f2 <acquiresleep+0x60>
    p = lk->head;
    800045d6:	03093783          	ld	a5,48(s2)
    if (p == 0) {
    800045da:	dff9                	beqz	a5,800045b8 <acquiresleep+0x26>
      while (p->next) {
    800045dc:	84be                	mv	s1,a5
    800045de:	1687b783          	ld	a5,360(a5)
    800045e2:	ffed                	bnez	a5,800045dc <acquiresleep+0x4a>
      p->next = myproc();
    800045e4:	ffffd097          	auipc	ra,0xffffd
    800045e8:	44c080e7          	jalr	1100(ra) # 80001a30 <myproc>
    800045ec:	16a4b423          	sd	a0,360(s1)
    800045f0:	bfd1                	j	800045c4 <acquiresleep+0x32>
    800045f2:	64e2                	ld	s1,24(sp)
  }
  lk->locked = 1;
    800045f4:	4785                	li	a5,1
    800045f6:	00f92023          	sw	a5,0(s2)
  lk->pid = myproc()->pid;
    800045fa:	ffffd097          	auipc	ra,0xffffd
    800045fe:	436080e7          	jalr	1078(ra) # 80001a30 <myproc>
    80004602:	591c                	lw	a5,48(a0)
    80004604:	02f92423          	sw	a5,40(s2)
  release(&lk->lk);
    80004608:	854e                	mv	a0,s3
    8000460a:	ffffc097          	auipc	ra,0xffffc
    8000460e:	6dc080e7          	jalr	1756(ra) # 80000ce6 <release>
}
    80004612:	70a2                	ld	ra,40(sp)
    80004614:	7402                	ld	s0,32(sp)
    80004616:	6942                	ld	s2,16(sp)
    80004618:	69a2                	ld	s3,8(sp)
    8000461a:	6145                	add	sp,sp,48
    8000461c:	8082                	ret

000000008000461e <releasesleep>:

// Lab 9 
void
releasesleep(struct sleeplock *lk)
{
    8000461e:	7179                	add	sp,sp,-48
    80004620:	f406                	sd	ra,40(sp)
    80004622:	f022                	sd	s0,32(sp)
    80004624:	ec26                	sd	s1,24(sp)
    80004626:	e84a                	sd	s2,16(sp)
    80004628:	e44e                	sd	s3,8(sp)
    8000462a:	1800                	add	s0,sp,48
    8000462c:	84aa                	mv	s1,a0
  struct proc *p;

  acquire(&lk->lk);
    8000462e:	00850993          	add	s3,a0,8
    80004632:	854e                	mv	a0,s3
    80004634:	ffffc097          	auipc	ra,0xffffc
    80004638:	5fe080e7          	jalr	1534(ra) # 80000c32 <acquire>
  lk->locked = 0;
    8000463c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004640:	0204a423          	sw	zero,40(s1)
  
  p = lk->head;
    80004644:	0304b903          	ld	s2,48(s1)
  if(p) { 
    80004648:	02090463          	beqz	s2,80004670 <releasesleep+0x52>
    acquire(&p->lock); 
    8000464c:	854a                	mv	a0,s2
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	5e4080e7          	jalr	1508(ra) # 80000c32 <acquire>
    if(p->state == SLEEPING && p->chan == lk) 
    80004656:	01892703          	lw	a4,24(s2)
    8000465a:	4789                	li	a5,2
    8000465c:	02f70663          	beq	a4,a5,80004688 <releasesleep+0x6a>
      p->state = RUNNABLE;
    release(&p->lock);
    80004660:	854a                	mv	a0,s2
    80004662:	ffffc097          	auipc	ra,0xffffc
    80004666:	684080e7          	jalr	1668(ra) # 80000ce6 <release>
    lk->head = p->next;
    8000466a:	16893783          	ld	a5,360(s2)
    8000466e:	f89c                	sd	a5,48(s1)
  }
//  wakeup(lk);
  release(&lk->lk);
    80004670:	854e                	mv	a0,s3
    80004672:	ffffc097          	auipc	ra,0xffffc
    80004676:	674080e7          	jalr	1652(ra) # 80000ce6 <release>
}
    8000467a:	70a2                	ld	ra,40(sp)
    8000467c:	7402                	ld	s0,32(sp)
    8000467e:	64e2                	ld	s1,24(sp)
    80004680:	6942                	ld	s2,16(sp)
    80004682:	69a2                	ld	s3,8(sp)
    80004684:	6145                	add	sp,sp,48
    80004686:	8082                	ret
    if(p->state == SLEEPING && p->chan == lk) 
    80004688:	02093783          	ld	a5,32(s2)
    8000468c:	fc979ae3          	bne	a5,s1,80004660 <releasesleep+0x42>
      p->state = RUNNABLE;
    80004690:	478d                	li	a5,3
    80004692:	00f92c23          	sw	a5,24(s2)
    80004696:	b7e9                	j	80004660 <releasesleep+0x42>

0000000080004698 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004698:	1141                	add	sp,sp,-16
    8000469a:	e406                	sd	ra,8(sp)
    8000469c:	e022                	sd	s0,0(sp)
    8000469e:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046a0:	00004597          	auipc	a1,0x4
    800046a4:	ef858593          	add	a1,a1,-264 # 80008598 <etext+0x598>
    800046a8:	0001d517          	auipc	a0,0x1d
    800046ac:	19850513          	add	a0,a0,408 # 80021840 <ftable>
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	4f2080e7          	jalr	1266(ra) # 80000ba2 <initlock>
}
    800046b8:	60a2                	ld	ra,8(sp)
    800046ba:	6402                	ld	s0,0(sp)
    800046bc:	0141                	add	sp,sp,16
    800046be:	8082                	ret

00000000800046c0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046c0:	1101                	add	sp,sp,-32
    800046c2:	ec06                	sd	ra,24(sp)
    800046c4:	e822                	sd	s0,16(sp)
    800046c6:	e426                	sd	s1,8(sp)
    800046c8:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046ca:	0001d517          	auipc	a0,0x1d
    800046ce:	17650513          	add	a0,a0,374 # 80021840 <ftable>
    800046d2:	ffffc097          	auipc	ra,0xffffc
    800046d6:	560080e7          	jalr	1376(ra) # 80000c32 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046da:	0001d497          	auipc	s1,0x1d
    800046de:	17e48493          	add	s1,s1,382 # 80021858 <ftable+0x18>
    800046e2:	0001e717          	auipc	a4,0x1e
    800046e6:	11670713          	add	a4,a4,278 # 800227f8 <lk.2>
    if(f->ref == 0){
    800046ea:	40dc                	lw	a5,4(s1)
    800046ec:	cf99                	beqz	a5,8000470a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046ee:	02848493          	add	s1,s1,40
    800046f2:	fee49ce3          	bne	s1,a4,800046ea <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046f6:	0001d517          	auipc	a0,0x1d
    800046fa:	14a50513          	add	a0,a0,330 # 80021840 <ftable>
    800046fe:	ffffc097          	auipc	ra,0xffffc
    80004702:	5e8080e7          	jalr	1512(ra) # 80000ce6 <release>
  return 0;
    80004706:	4481                	li	s1,0
    80004708:	a819                	j	8000471e <filealloc+0x5e>
      f->ref = 1;
    8000470a:	4785                	li	a5,1
    8000470c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000470e:	0001d517          	auipc	a0,0x1d
    80004712:	13250513          	add	a0,a0,306 # 80021840 <ftable>
    80004716:	ffffc097          	auipc	ra,0xffffc
    8000471a:	5d0080e7          	jalr	1488(ra) # 80000ce6 <release>
}
    8000471e:	8526                	mv	a0,s1
    80004720:	60e2                	ld	ra,24(sp)
    80004722:	6442                	ld	s0,16(sp)
    80004724:	64a2                	ld	s1,8(sp)
    80004726:	6105                	add	sp,sp,32
    80004728:	8082                	ret

000000008000472a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000472a:	1101                	add	sp,sp,-32
    8000472c:	ec06                	sd	ra,24(sp)
    8000472e:	e822                	sd	s0,16(sp)
    80004730:	e426                	sd	s1,8(sp)
    80004732:	1000                	add	s0,sp,32
    80004734:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004736:	0001d517          	auipc	a0,0x1d
    8000473a:	10a50513          	add	a0,a0,266 # 80021840 <ftable>
    8000473e:	ffffc097          	auipc	ra,0xffffc
    80004742:	4f4080e7          	jalr	1268(ra) # 80000c32 <acquire>
  if(f->ref < 1)
    80004746:	40dc                	lw	a5,4(s1)
    80004748:	02f05263          	blez	a5,8000476c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000474c:	2785                	addw	a5,a5,1
    8000474e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004750:	0001d517          	auipc	a0,0x1d
    80004754:	0f050513          	add	a0,a0,240 # 80021840 <ftable>
    80004758:	ffffc097          	auipc	ra,0xffffc
    8000475c:	58e080e7          	jalr	1422(ra) # 80000ce6 <release>
  return f;
}
    80004760:	8526                	mv	a0,s1
    80004762:	60e2                	ld	ra,24(sp)
    80004764:	6442                	ld	s0,16(sp)
    80004766:	64a2                	ld	s1,8(sp)
    80004768:	6105                	add	sp,sp,32
    8000476a:	8082                	ret
    panic("filedup");
    8000476c:	00004517          	auipc	a0,0x4
    80004770:	e3450513          	add	a0,a0,-460 # 800085a0 <etext+0x5a0>
    80004774:	ffffc097          	auipc	ra,0xffffc
    80004778:	de6080e7          	jalr	-538(ra) # 8000055a <panic>

000000008000477c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000477c:	7139                	add	sp,sp,-64
    8000477e:	fc06                	sd	ra,56(sp)
    80004780:	f822                	sd	s0,48(sp)
    80004782:	f426                	sd	s1,40(sp)
    80004784:	0080                	add	s0,sp,64
    80004786:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004788:	0001d517          	auipc	a0,0x1d
    8000478c:	0b850513          	add	a0,a0,184 # 80021840 <ftable>
    80004790:	ffffc097          	auipc	ra,0xffffc
    80004794:	4a2080e7          	jalr	1186(ra) # 80000c32 <acquire>
  if(f->ref < 1)
    80004798:	40dc                	lw	a5,4(s1)
    8000479a:	04f05c63          	blez	a5,800047f2 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    8000479e:	37fd                	addw	a5,a5,-1
    800047a0:	0007871b          	sext.w	a4,a5
    800047a4:	c0dc                	sw	a5,4(s1)
    800047a6:	06e04263          	bgtz	a4,8000480a <fileclose+0x8e>
    800047aa:	f04a                	sd	s2,32(sp)
    800047ac:	ec4e                	sd	s3,24(sp)
    800047ae:	e852                	sd	s4,16(sp)
    800047b0:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047b2:	0004a903          	lw	s2,0(s1)
    800047b6:	0094ca83          	lbu	s5,9(s1)
    800047ba:	0104ba03          	ld	s4,16(s1)
    800047be:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047c2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047c6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047ca:	0001d517          	auipc	a0,0x1d
    800047ce:	07650513          	add	a0,a0,118 # 80021840 <ftable>
    800047d2:	ffffc097          	auipc	ra,0xffffc
    800047d6:	514080e7          	jalr	1300(ra) # 80000ce6 <release>

  if(ff.type == FD_PIPE){
    800047da:	4785                	li	a5,1
    800047dc:	04f90463          	beq	s2,a5,80004824 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047e0:	3979                	addw	s2,s2,-2
    800047e2:	4785                	li	a5,1
    800047e4:	0527fb63          	bgeu	a5,s2,8000483a <fileclose+0xbe>
    800047e8:	7902                	ld	s2,32(sp)
    800047ea:	69e2                	ld	s3,24(sp)
    800047ec:	6a42                	ld	s4,16(sp)
    800047ee:	6aa2                	ld	s5,8(sp)
    800047f0:	a02d                	j	8000481a <fileclose+0x9e>
    800047f2:	f04a                	sd	s2,32(sp)
    800047f4:	ec4e                	sd	s3,24(sp)
    800047f6:	e852                	sd	s4,16(sp)
    800047f8:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800047fa:	00004517          	auipc	a0,0x4
    800047fe:	dae50513          	add	a0,a0,-594 # 800085a8 <etext+0x5a8>
    80004802:	ffffc097          	auipc	ra,0xffffc
    80004806:	d58080e7          	jalr	-680(ra) # 8000055a <panic>
    release(&ftable.lock);
    8000480a:	0001d517          	auipc	a0,0x1d
    8000480e:	03650513          	add	a0,a0,54 # 80021840 <ftable>
    80004812:	ffffc097          	auipc	ra,0xffffc
    80004816:	4d4080e7          	jalr	1236(ra) # 80000ce6 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000481a:	70e2                	ld	ra,56(sp)
    8000481c:	7442                	ld	s0,48(sp)
    8000481e:	74a2                	ld	s1,40(sp)
    80004820:	6121                	add	sp,sp,64
    80004822:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004824:	85d6                	mv	a1,s5
    80004826:	8552                	mv	a0,s4
    80004828:	00000097          	auipc	ra,0x0
    8000482c:	3a2080e7          	jalr	930(ra) # 80004bca <pipeclose>
    80004830:	7902                	ld	s2,32(sp)
    80004832:	69e2                	ld	s3,24(sp)
    80004834:	6a42                	ld	s4,16(sp)
    80004836:	6aa2                	ld	s5,8(sp)
    80004838:	b7cd                	j	8000481a <fileclose+0x9e>
    begin_op();
    8000483a:	00000097          	auipc	ra,0x0
    8000483e:	a0c080e7          	jalr	-1524(ra) # 80004246 <begin_op>
    iput(ff.ip);
    80004842:	854e                	mv	a0,s3
    80004844:	fffff097          	auipc	ra,0xfffff
    80004848:	1ee080e7          	jalr	494(ra) # 80003a32 <iput>
    end_op();
    8000484c:	00000097          	auipc	ra,0x0
    80004850:	a74080e7          	jalr	-1420(ra) # 800042c0 <end_op>
    80004854:	7902                	ld	s2,32(sp)
    80004856:	69e2                	ld	s3,24(sp)
    80004858:	6a42                	ld	s4,16(sp)
    8000485a:	6aa2                	ld	s5,8(sp)
    8000485c:	bf7d                	j	8000481a <fileclose+0x9e>

000000008000485e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000485e:	715d                	add	sp,sp,-80
    80004860:	e486                	sd	ra,72(sp)
    80004862:	e0a2                	sd	s0,64(sp)
    80004864:	fc26                	sd	s1,56(sp)
    80004866:	f44e                	sd	s3,40(sp)
    80004868:	0880                	add	s0,sp,80
    8000486a:	84aa                	mv	s1,a0
    8000486c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000486e:	ffffd097          	auipc	ra,0xffffd
    80004872:	1c2080e7          	jalr	450(ra) # 80001a30 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004876:	409c                	lw	a5,0(s1)
    80004878:	37f9                	addw	a5,a5,-2
    8000487a:	4705                	li	a4,1
    8000487c:	04f76863          	bltu	a4,a5,800048cc <filestat+0x6e>
    80004880:	f84a                	sd	s2,48(sp)
    80004882:	892a                	mv	s2,a0
    ilock(f->ip);
    80004884:	6c88                	ld	a0,24(s1)
    80004886:	fffff097          	auipc	ra,0xfffff
    8000488a:	fee080e7          	jalr	-18(ra) # 80003874 <ilock>
    stati(f->ip, &st);
    8000488e:	fb840593          	add	a1,s0,-72
    80004892:	6c88                	ld	a0,24(s1)
    80004894:	fffff097          	auipc	ra,0xfffff
    80004898:	26e080e7          	jalr	622(ra) # 80003b02 <stati>
    iunlock(f->ip);
    8000489c:	6c88                	ld	a0,24(s1)
    8000489e:	fffff097          	auipc	ra,0xfffff
    800048a2:	09c080e7          	jalr	156(ra) # 8000393a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048a6:	46e1                	li	a3,24
    800048a8:	fb840613          	add	a2,s0,-72
    800048ac:	85ce                	mv	a1,s3
    800048ae:	05093503          	ld	a0,80(s2)
    800048b2:	ffffd097          	auipc	ra,0xffffd
    800048b6:	e1a080e7          	jalr	-486(ra) # 800016cc <copyout>
    800048ba:	41f5551b          	sraw	a0,a0,0x1f
    800048be:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800048c0:	60a6                	ld	ra,72(sp)
    800048c2:	6406                	ld	s0,64(sp)
    800048c4:	74e2                	ld	s1,56(sp)
    800048c6:	79a2                	ld	s3,40(sp)
    800048c8:	6161                	add	sp,sp,80
    800048ca:	8082                	ret
  return -1;
    800048cc:	557d                	li	a0,-1
    800048ce:	bfcd                	j	800048c0 <filestat+0x62>

00000000800048d0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048d0:	7179                	add	sp,sp,-48
    800048d2:	f406                	sd	ra,40(sp)
    800048d4:	f022                	sd	s0,32(sp)
    800048d6:	e84a                	sd	s2,16(sp)
    800048d8:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048da:	00854783          	lbu	a5,8(a0)
    800048de:	cbc5                	beqz	a5,8000498e <fileread+0xbe>
    800048e0:	ec26                	sd	s1,24(sp)
    800048e2:	e44e                	sd	s3,8(sp)
    800048e4:	84aa                	mv	s1,a0
    800048e6:	89ae                	mv	s3,a1
    800048e8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048ea:	411c                	lw	a5,0(a0)
    800048ec:	4705                	li	a4,1
    800048ee:	04e78963          	beq	a5,a4,80004940 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048f2:	470d                	li	a4,3
    800048f4:	04e78f63          	beq	a5,a4,80004952 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048f8:	4709                	li	a4,2
    800048fa:	08e79263          	bne	a5,a4,8000497e <fileread+0xae>
    ilock(f->ip);
    800048fe:	6d08                	ld	a0,24(a0)
    80004900:	fffff097          	auipc	ra,0xfffff
    80004904:	f74080e7          	jalr	-140(ra) # 80003874 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004908:	874a                	mv	a4,s2
    8000490a:	5094                	lw	a3,32(s1)
    8000490c:	864e                	mv	a2,s3
    8000490e:	4585                	li	a1,1
    80004910:	6c88                	ld	a0,24(s1)
    80004912:	fffff097          	auipc	ra,0xfffff
    80004916:	21a080e7          	jalr	538(ra) # 80003b2c <readi>
    8000491a:	892a                	mv	s2,a0
    8000491c:	00a05563          	blez	a0,80004926 <fileread+0x56>
      f->off += r;
    80004920:	509c                	lw	a5,32(s1)
    80004922:	9fa9                	addw	a5,a5,a0
    80004924:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004926:	6c88                	ld	a0,24(s1)
    80004928:	fffff097          	auipc	ra,0xfffff
    8000492c:	012080e7          	jalr	18(ra) # 8000393a <iunlock>
    80004930:	64e2                	ld	s1,24(sp)
    80004932:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004934:	854a                	mv	a0,s2
    80004936:	70a2                	ld	ra,40(sp)
    80004938:	7402                	ld	s0,32(sp)
    8000493a:	6942                	ld	s2,16(sp)
    8000493c:	6145                	add	sp,sp,48
    8000493e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004940:	6908                	ld	a0,16(a0)
    80004942:	00000097          	auipc	ra,0x0
    80004946:	3fa080e7          	jalr	1018(ra) # 80004d3c <piperead>
    8000494a:	892a                	mv	s2,a0
    8000494c:	64e2                	ld	s1,24(sp)
    8000494e:	69a2                	ld	s3,8(sp)
    80004950:	b7d5                	j	80004934 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004952:	02451783          	lh	a5,36(a0)
    80004956:	03079693          	sll	a3,a5,0x30
    8000495a:	92c1                	srl	a3,a3,0x30
    8000495c:	4725                	li	a4,9
    8000495e:	02d76a63          	bltu	a4,a3,80004992 <fileread+0xc2>
    80004962:	0792                	sll	a5,a5,0x4
    80004964:	0001d717          	auipc	a4,0x1d
    80004968:	e3c70713          	add	a4,a4,-452 # 800217a0 <devsw>
    8000496c:	97ba                	add	a5,a5,a4
    8000496e:	639c                	ld	a5,0(a5)
    80004970:	c78d                	beqz	a5,8000499a <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004972:	4505                	li	a0,1
    80004974:	9782                	jalr	a5
    80004976:	892a                	mv	s2,a0
    80004978:	64e2                	ld	s1,24(sp)
    8000497a:	69a2                	ld	s3,8(sp)
    8000497c:	bf65                	j	80004934 <fileread+0x64>
    panic("fileread");
    8000497e:	00004517          	auipc	a0,0x4
    80004982:	c3a50513          	add	a0,a0,-966 # 800085b8 <etext+0x5b8>
    80004986:	ffffc097          	auipc	ra,0xffffc
    8000498a:	bd4080e7          	jalr	-1068(ra) # 8000055a <panic>
    return -1;
    8000498e:	597d                	li	s2,-1
    80004990:	b755                	j	80004934 <fileread+0x64>
      return -1;
    80004992:	597d                	li	s2,-1
    80004994:	64e2                	ld	s1,24(sp)
    80004996:	69a2                	ld	s3,8(sp)
    80004998:	bf71                	j	80004934 <fileread+0x64>
    8000499a:	597d                	li	s2,-1
    8000499c:	64e2                	ld	s1,24(sp)
    8000499e:	69a2                	ld	s3,8(sp)
    800049a0:	bf51                	j	80004934 <fileread+0x64>

00000000800049a2 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800049a2:	00954783          	lbu	a5,9(a0)
    800049a6:	12078963          	beqz	a5,80004ad8 <filewrite+0x136>
{
    800049aa:	715d                	add	sp,sp,-80
    800049ac:	e486                	sd	ra,72(sp)
    800049ae:	e0a2                	sd	s0,64(sp)
    800049b0:	f84a                	sd	s2,48(sp)
    800049b2:	f052                	sd	s4,32(sp)
    800049b4:	e85a                	sd	s6,16(sp)
    800049b6:	0880                	add	s0,sp,80
    800049b8:	892a                	mv	s2,a0
    800049ba:	8b2e                	mv	s6,a1
    800049bc:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049be:	411c                	lw	a5,0(a0)
    800049c0:	4705                	li	a4,1
    800049c2:	02e78763          	beq	a5,a4,800049f0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049c6:	470d                	li	a4,3
    800049c8:	02e78a63          	beq	a5,a4,800049fc <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049cc:	4709                	li	a4,2
    800049ce:	0ee79863          	bne	a5,a4,80004abe <filewrite+0x11c>
    800049d2:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049d4:	0cc05463          	blez	a2,80004a9c <filewrite+0xfa>
    800049d8:	fc26                	sd	s1,56(sp)
    800049da:	ec56                	sd	s5,24(sp)
    800049dc:	e45e                	sd	s7,8(sp)
    800049de:	e062                	sd	s8,0(sp)
    int i = 0;
    800049e0:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800049e2:	6b85                	lui	s7,0x1
    800049e4:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800049e8:	6c05                	lui	s8,0x1
    800049ea:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800049ee:	a851                	j	80004a82 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800049f0:	6908                	ld	a0,16(a0)
    800049f2:	00000097          	auipc	ra,0x0
    800049f6:	248080e7          	jalr	584(ra) # 80004c3a <pipewrite>
    800049fa:	a85d                	j	80004ab0 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049fc:	02451783          	lh	a5,36(a0)
    80004a00:	03079693          	sll	a3,a5,0x30
    80004a04:	92c1                	srl	a3,a3,0x30
    80004a06:	4725                	li	a4,9
    80004a08:	0cd76a63          	bltu	a4,a3,80004adc <filewrite+0x13a>
    80004a0c:	0792                	sll	a5,a5,0x4
    80004a0e:	0001d717          	auipc	a4,0x1d
    80004a12:	d9270713          	add	a4,a4,-622 # 800217a0 <devsw>
    80004a16:	97ba                	add	a5,a5,a4
    80004a18:	679c                	ld	a5,8(a5)
    80004a1a:	c3f9                	beqz	a5,80004ae0 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    80004a1c:	4505                	li	a0,1
    80004a1e:	9782                	jalr	a5
    80004a20:	a841                	j	80004ab0 <filewrite+0x10e>
      if(n1 > max)
    80004a22:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004a26:	00000097          	auipc	ra,0x0
    80004a2a:	820080e7          	jalr	-2016(ra) # 80004246 <begin_op>
      ilock(f->ip);
    80004a2e:	01893503          	ld	a0,24(s2)
    80004a32:	fffff097          	auipc	ra,0xfffff
    80004a36:	e42080e7          	jalr	-446(ra) # 80003874 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a3a:	8756                	mv	a4,s5
    80004a3c:	02092683          	lw	a3,32(s2)
    80004a40:	01698633          	add	a2,s3,s6
    80004a44:	4585                	li	a1,1
    80004a46:	01893503          	ld	a0,24(s2)
    80004a4a:	fffff097          	auipc	ra,0xfffff
    80004a4e:	1e6080e7          	jalr	486(ra) # 80003c30 <writei>
    80004a52:	84aa                	mv	s1,a0
    80004a54:	00a05763          	blez	a0,80004a62 <filewrite+0xc0>
        f->off += r;
    80004a58:	02092783          	lw	a5,32(s2)
    80004a5c:	9fa9                	addw	a5,a5,a0
    80004a5e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a62:	01893503          	ld	a0,24(s2)
    80004a66:	fffff097          	auipc	ra,0xfffff
    80004a6a:	ed4080e7          	jalr	-300(ra) # 8000393a <iunlock>
      end_op();
    80004a6e:	00000097          	auipc	ra,0x0
    80004a72:	852080e7          	jalr	-1966(ra) # 800042c0 <end_op>

      if(r != n1){
    80004a76:	029a9563          	bne	s5,s1,80004aa0 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004a7a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a7e:	0149da63          	bge	s3,s4,80004a92 <filewrite+0xf0>
      int n1 = n - i;
    80004a82:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004a86:	0004879b          	sext.w	a5,s1
    80004a8a:	f8fbdce3          	bge	s7,a5,80004a22 <filewrite+0x80>
    80004a8e:	84e2                	mv	s1,s8
    80004a90:	bf49                	j	80004a22 <filewrite+0x80>
    80004a92:	74e2                	ld	s1,56(sp)
    80004a94:	6ae2                	ld	s5,24(sp)
    80004a96:	6ba2                	ld	s7,8(sp)
    80004a98:	6c02                	ld	s8,0(sp)
    80004a9a:	a039                	j	80004aa8 <filewrite+0x106>
    int i = 0;
    80004a9c:	4981                	li	s3,0
    80004a9e:	a029                	j	80004aa8 <filewrite+0x106>
    80004aa0:	74e2                	ld	s1,56(sp)
    80004aa2:	6ae2                	ld	s5,24(sp)
    80004aa4:	6ba2                	ld	s7,8(sp)
    80004aa6:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004aa8:	033a1e63          	bne	s4,s3,80004ae4 <filewrite+0x142>
    80004aac:	8552                	mv	a0,s4
    80004aae:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004ab0:	60a6                	ld	ra,72(sp)
    80004ab2:	6406                	ld	s0,64(sp)
    80004ab4:	7942                	ld	s2,48(sp)
    80004ab6:	7a02                	ld	s4,32(sp)
    80004ab8:	6b42                	ld	s6,16(sp)
    80004aba:	6161                	add	sp,sp,80
    80004abc:	8082                	ret
    80004abe:	fc26                	sd	s1,56(sp)
    80004ac0:	f44e                	sd	s3,40(sp)
    80004ac2:	ec56                	sd	s5,24(sp)
    80004ac4:	e45e                	sd	s7,8(sp)
    80004ac6:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004ac8:	00004517          	auipc	a0,0x4
    80004acc:	b0050513          	add	a0,a0,-1280 # 800085c8 <etext+0x5c8>
    80004ad0:	ffffc097          	auipc	ra,0xffffc
    80004ad4:	a8a080e7          	jalr	-1398(ra) # 8000055a <panic>
    return -1;
    80004ad8:	557d                	li	a0,-1
}
    80004ada:	8082                	ret
      return -1;
    80004adc:	557d                	li	a0,-1
    80004ade:	bfc9                	j	80004ab0 <filewrite+0x10e>
    80004ae0:	557d                	li	a0,-1
    80004ae2:	b7f9                	j	80004ab0 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004ae4:	557d                	li	a0,-1
    80004ae6:	79a2                	ld	s3,40(sp)
    80004ae8:	b7e1                	j	80004ab0 <filewrite+0x10e>

0000000080004aea <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004aea:	7179                	add	sp,sp,-48
    80004aec:	f406                	sd	ra,40(sp)
    80004aee:	f022                	sd	s0,32(sp)
    80004af0:	ec26                	sd	s1,24(sp)
    80004af2:	e052                	sd	s4,0(sp)
    80004af4:	1800                	add	s0,sp,48
    80004af6:	84aa                	mv	s1,a0
    80004af8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004afa:	0005b023          	sd	zero,0(a1)
    80004afe:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b02:	00000097          	auipc	ra,0x0
    80004b06:	bbe080e7          	jalr	-1090(ra) # 800046c0 <filealloc>
    80004b0a:	e088                	sd	a0,0(s1)
    80004b0c:	cd49                	beqz	a0,80004ba6 <pipealloc+0xbc>
    80004b0e:	00000097          	auipc	ra,0x0
    80004b12:	bb2080e7          	jalr	-1102(ra) # 800046c0 <filealloc>
    80004b16:	00aa3023          	sd	a0,0(s4)
    80004b1a:	c141                	beqz	a0,80004b9a <pipealloc+0xb0>
    80004b1c:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b1e:	ffffc097          	auipc	ra,0xffffc
    80004b22:	024080e7          	jalr	36(ra) # 80000b42 <kalloc>
    80004b26:	892a                	mv	s2,a0
    80004b28:	c13d                	beqz	a0,80004b8e <pipealloc+0xa4>
    80004b2a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004b2c:	4985                	li	s3,1
    80004b2e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b32:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b36:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b3a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b3e:	00004597          	auipc	a1,0x4
    80004b42:	a9a58593          	add	a1,a1,-1382 # 800085d8 <etext+0x5d8>
    80004b46:	ffffc097          	auipc	ra,0xffffc
    80004b4a:	05c080e7          	jalr	92(ra) # 80000ba2 <initlock>
  (*f0)->type = FD_PIPE;
    80004b4e:	609c                	ld	a5,0(s1)
    80004b50:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b54:	609c                	ld	a5,0(s1)
    80004b56:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b5a:	609c                	ld	a5,0(s1)
    80004b5c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b60:	609c                	ld	a5,0(s1)
    80004b62:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b66:	000a3783          	ld	a5,0(s4)
    80004b6a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b6e:	000a3783          	ld	a5,0(s4)
    80004b72:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b76:	000a3783          	ld	a5,0(s4)
    80004b7a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b7e:	000a3783          	ld	a5,0(s4)
    80004b82:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b86:	4501                	li	a0,0
    80004b88:	6942                	ld	s2,16(sp)
    80004b8a:	69a2                	ld	s3,8(sp)
    80004b8c:	a03d                	j	80004bba <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b8e:	6088                	ld	a0,0(s1)
    80004b90:	c119                	beqz	a0,80004b96 <pipealloc+0xac>
    80004b92:	6942                	ld	s2,16(sp)
    80004b94:	a029                	j	80004b9e <pipealloc+0xb4>
    80004b96:	6942                	ld	s2,16(sp)
    80004b98:	a039                	j	80004ba6 <pipealloc+0xbc>
    80004b9a:	6088                	ld	a0,0(s1)
    80004b9c:	c50d                	beqz	a0,80004bc6 <pipealloc+0xdc>
    fileclose(*f0);
    80004b9e:	00000097          	auipc	ra,0x0
    80004ba2:	bde080e7          	jalr	-1058(ra) # 8000477c <fileclose>
  if(*f1)
    80004ba6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004baa:	557d                	li	a0,-1
  if(*f1)
    80004bac:	c799                	beqz	a5,80004bba <pipealloc+0xd0>
    fileclose(*f1);
    80004bae:	853e                	mv	a0,a5
    80004bb0:	00000097          	auipc	ra,0x0
    80004bb4:	bcc080e7          	jalr	-1076(ra) # 8000477c <fileclose>
  return -1;
    80004bb8:	557d                	li	a0,-1
}
    80004bba:	70a2                	ld	ra,40(sp)
    80004bbc:	7402                	ld	s0,32(sp)
    80004bbe:	64e2                	ld	s1,24(sp)
    80004bc0:	6a02                	ld	s4,0(sp)
    80004bc2:	6145                	add	sp,sp,48
    80004bc4:	8082                	ret
  return -1;
    80004bc6:	557d                	li	a0,-1
    80004bc8:	bfcd                	j	80004bba <pipealloc+0xd0>

0000000080004bca <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bca:	1101                	add	sp,sp,-32
    80004bcc:	ec06                	sd	ra,24(sp)
    80004bce:	e822                	sd	s0,16(sp)
    80004bd0:	e426                	sd	s1,8(sp)
    80004bd2:	e04a                	sd	s2,0(sp)
    80004bd4:	1000                	add	s0,sp,32
    80004bd6:	84aa                	mv	s1,a0
    80004bd8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bda:	ffffc097          	auipc	ra,0xffffc
    80004bde:	058080e7          	jalr	88(ra) # 80000c32 <acquire>
  if(writable){
    80004be2:	02090d63          	beqz	s2,80004c1c <pipeclose+0x52>
    pi->writeopen = 0;
    80004be6:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bea:	21848513          	add	a0,s1,536
    80004bee:	ffffd097          	auipc	ra,0xffffd
    80004bf2:	694080e7          	jalr	1684(ra) # 80002282 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bf6:	2204b783          	ld	a5,544(s1)
    80004bfa:	eb95                	bnez	a5,80004c2e <pipeclose+0x64>
    release(&pi->lock);
    80004bfc:	8526                	mv	a0,s1
    80004bfe:	ffffc097          	auipc	ra,0xffffc
    80004c02:	0e8080e7          	jalr	232(ra) # 80000ce6 <release>
    kfree((char*)pi);
    80004c06:	8526                	mv	a0,s1
    80004c08:	ffffc097          	auipc	ra,0xffffc
    80004c0c:	e3c080e7          	jalr	-452(ra) # 80000a44 <kfree>
  } else
    release(&pi->lock);
}
    80004c10:	60e2                	ld	ra,24(sp)
    80004c12:	6442                	ld	s0,16(sp)
    80004c14:	64a2                	ld	s1,8(sp)
    80004c16:	6902                	ld	s2,0(sp)
    80004c18:	6105                	add	sp,sp,32
    80004c1a:	8082                	ret
    pi->readopen = 0;
    80004c1c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c20:	21c48513          	add	a0,s1,540
    80004c24:	ffffd097          	auipc	ra,0xffffd
    80004c28:	65e080e7          	jalr	1630(ra) # 80002282 <wakeup>
    80004c2c:	b7e9                	j	80004bf6 <pipeclose+0x2c>
    release(&pi->lock);
    80004c2e:	8526                	mv	a0,s1
    80004c30:	ffffc097          	auipc	ra,0xffffc
    80004c34:	0b6080e7          	jalr	182(ra) # 80000ce6 <release>
}
    80004c38:	bfe1                	j	80004c10 <pipeclose+0x46>

0000000080004c3a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c3a:	711d                	add	sp,sp,-96
    80004c3c:	ec86                	sd	ra,88(sp)
    80004c3e:	e8a2                	sd	s0,80(sp)
    80004c40:	e4a6                	sd	s1,72(sp)
    80004c42:	e0ca                	sd	s2,64(sp)
    80004c44:	fc4e                	sd	s3,56(sp)
    80004c46:	f852                	sd	s4,48(sp)
    80004c48:	f456                	sd	s5,40(sp)
    80004c4a:	1080                	add	s0,sp,96
    80004c4c:	84aa                	mv	s1,a0
    80004c4e:	8aae                	mv	s5,a1
    80004c50:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c52:	ffffd097          	auipc	ra,0xffffd
    80004c56:	dde080e7          	jalr	-546(ra) # 80001a30 <myproc>
    80004c5a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c5c:	8526                	mv	a0,s1
    80004c5e:	ffffc097          	auipc	ra,0xffffc
    80004c62:	fd4080e7          	jalr	-44(ra) # 80000c32 <acquire>
  while(i < n){
    80004c66:	0d405563          	blez	s4,80004d30 <pipewrite+0xf6>
    80004c6a:	f05a                	sd	s6,32(sp)
    80004c6c:	ec5e                	sd	s7,24(sp)
    80004c6e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004c70:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c72:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c74:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c78:	21c48b93          	add	s7,s1,540
    80004c7c:	a089                	j	80004cbe <pipewrite+0x84>
      release(&pi->lock);
    80004c7e:	8526                	mv	a0,s1
    80004c80:	ffffc097          	auipc	ra,0xffffc
    80004c84:	066080e7          	jalr	102(ra) # 80000ce6 <release>
      return -1;
    80004c88:	597d                	li	s2,-1
    80004c8a:	7b02                	ld	s6,32(sp)
    80004c8c:	6be2                	ld	s7,24(sp)
    80004c8e:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c90:	854a                	mv	a0,s2
    80004c92:	60e6                	ld	ra,88(sp)
    80004c94:	6446                	ld	s0,80(sp)
    80004c96:	64a6                	ld	s1,72(sp)
    80004c98:	6906                	ld	s2,64(sp)
    80004c9a:	79e2                	ld	s3,56(sp)
    80004c9c:	7a42                	ld	s4,48(sp)
    80004c9e:	7aa2                	ld	s5,40(sp)
    80004ca0:	6125                	add	sp,sp,96
    80004ca2:	8082                	ret
      wakeup(&pi->nread);
    80004ca4:	8562                	mv	a0,s8
    80004ca6:	ffffd097          	auipc	ra,0xffffd
    80004caa:	5dc080e7          	jalr	1500(ra) # 80002282 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cae:	85a6                	mv	a1,s1
    80004cb0:	855e                	mv	a0,s7
    80004cb2:	ffffd097          	auipc	ra,0xffffd
    80004cb6:	444080e7          	jalr	1092(ra) # 800020f6 <sleep>
  while(i < n){
    80004cba:	05495c63          	bge	s2,s4,80004d12 <pipewrite+0xd8>
    if(pi->readopen == 0 || pr->killed){
    80004cbe:	2204a783          	lw	a5,544(s1)
    80004cc2:	dfd5                	beqz	a5,80004c7e <pipewrite+0x44>
    80004cc4:	0289a783          	lw	a5,40(s3)
    80004cc8:	fbdd                	bnez	a5,80004c7e <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cca:	2184a783          	lw	a5,536(s1)
    80004cce:	21c4a703          	lw	a4,540(s1)
    80004cd2:	2007879b          	addw	a5,a5,512
    80004cd6:	fcf707e3          	beq	a4,a5,80004ca4 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cda:	4685                	li	a3,1
    80004cdc:	01590633          	add	a2,s2,s5
    80004ce0:	faf40593          	add	a1,s0,-81
    80004ce4:	0509b503          	ld	a0,80(s3)
    80004ce8:	ffffd097          	auipc	ra,0xffffd
    80004cec:	a70080e7          	jalr	-1424(ra) # 80001758 <copyin>
    80004cf0:	05650263          	beq	a0,s6,80004d34 <pipewrite+0xfa>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cf4:	21c4a783          	lw	a5,540(s1)
    80004cf8:	0017871b          	addw	a4,a5,1
    80004cfc:	20e4ae23          	sw	a4,540(s1)
    80004d00:	1ff7f793          	and	a5,a5,511
    80004d04:	97a6                	add	a5,a5,s1
    80004d06:	faf44703          	lbu	a4,-81(s0)
    80004d0a:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d0e:	2905                	addw	s2,s2,1
    80004d10:	b76d                	j	80004cba <pipewrite+0x80>
    80004d12:	7b02                	ld	s6,32(sp)
    80004d14:	6be2                	ld	s7,24(sp)
    80004d16:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004d18:	21848513          	add	a0,s1,536
    80004d1c:	ffffd097          	auipc	ra,0xffffd
    80004d20:	566080e7          	jalr	1382(ra) # 80002282 <wakeup>
  release(&pi->lock);
    80004d24:	8526                	mv	a0,s1
    80004d26:	ffffc097          	auipc	ra,0xffffc
    80004d2a:	fc0080e7          	jalr	-64(ra) # 80000ce6 <release>
  return i;
    80004d2e:	b78d                	j	80004c90 <pipewrite+0x56>
  int i = 0;
    80004d30:	4901                	li	s2,0
    80004d32:	b7dd                	j	80004d18 <pipewrite+0xde>
    80004d34:	7b02                	ld	s6,32(sp)
    80004d36:	6be2                	ld	s7,24(sp)
    80004d38:	6c42                	ld	s8,16(sp)
    80004d3a:	bff9                	j	80004d18 <pipewrite+0xde>

0000000080004d3c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d3c:	715d                	add	sp,sp,-80
    80004d3e:	e486                	sd	ra,72(sp)
    80004d40:	e0a2                	sd	s0,64(sp)
    80004d42:	fc26                	sd	s1,56(sp)
    80004d44:	f84a                	sd	s2,48(sp)
    80004d46:	f44e                	sd	s3,40(sp)
    80004d48:	f052                	sd	s4,32(sp)
    80004d4a:	ec56                	sd	s5,24(sp)
    80004d4c:	0880                	add	s0,sp,80
    80004d4e:	84aa                	mv	s1,a0
    80004d50:	892e                	mv	s2,a1
    80004d52:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d54:	ffffd097          	auipc	ra,0xffffd
    80004d58:	cdc080e7          	jalr	-804(ra) # 80001a30 <myproc>
    80004d5c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d5e:	8526                	mv	a0,s1
    80004d60:	ffffc097          	auipc	ra,0xffffc
    80004d64:	ed2080e7          	jalr	-302(ra) # 80000c32 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d68:	2184a703          	lw	a4,536(s1)
    80004d6c:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d70:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d74:	02f71663          	bne	a4,a5,80004da0 <piperead+0x64>
    80004d78:	2244a783          	lw	a5,548(s1)
    80004d7c:	cb9d                	beqz	a5,80004db2 <piperead+0x76>
    if(pr->killed){
    80004d7e:	028a2783          	lw	a5,40(s4)
    80004d82:	e38d                	bnez	a5,80004da4 <piperead+0x68>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d84:	85a6                	mv	a1,s1
    80004d86:	854e                	mv	a0,s3
    80004d88:	ffffd097          	auipc	ra,0xffffd
    80004d8c:	36e080e7          	jalr	878(ra) # 800020f6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d90:	2184a703          	lw	a4,536(s1)
    80004d94:	21c4a783          	lw	a5,540(s1)
    80004d98:	fef700e3          	beq	a4,a5,80004d78 <piperead+0x3c>
    80004d9c:	e85a                	sd	s6,16(sp)
    80004d9e:	a819                	j	80004db4 <piperead+0x78>
    80004da0:	e85a                	sd	s6,16(sp)
    80004da2:	a809                	j	80004db4 <piperead+0x78>
      release(&pi->lock);
    80004da4:	8526                	mv	a0,s1
    80004da6:	ffffc097          	auipc	ra,0xffffc
    80004daa:	f40080e7          	jalr	-192(ra) # 80000ce6 <release>
      return -1;
    80004dae:	59fd                	li	s3,-1
    80004db0:	a0a5                	j	80004e18 <piperead+0xdc>
    80004db2:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004db4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004db6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004db8:	05505463          	blez	s5,80004e00 <piperead+0xc4>
    if(pi->nread == pi->nwrite)
    80004dbc:	2184a783          	lw	a5,536(s1)
    80004dc0:	21c4a703          	lw	a4,540(s1)
    80004dc4:	02f70e63          	beq	a4,a5,80004e00 <piperead+0xc4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004dc8:	0017871b          	addw	a4,a5,1
    80004dcc:	20e4ac23          	sw	a4,536(s1)
    80004dd0:	1ff7f793          	and	a5,a5,511
    80004dd4:	97a6                	add	a5,a5,s1
    80004dd6:	0187c783          	lbu	a5,24(a5)
    80004dda:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004dde:	4685                	li	a3,1
    80004de0:	fbf40613          	add	a2,s0,-65
    80004de4:	85ca                	mv	a1,s2
    80004de6:	050a3503          	ld	a0,80(s4)
    80004dea:	ffffd097          	auipc	ra,0xffffd
    80004dee:	8e2080e7          	jalr	-1822(ra) # 800016cc <copyout>
    80004df2:	01650763          	beq	a0,s6,80004e00 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004df6:	2985                	addw	s3,s3,1
    80004df8:	0905                	add	s2,s2,1
    80004dfa:	fd3a91e3          	bne	s5,s3,80004dbc <piperead+0x80>
    80004dfe:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e00:	21c48513          	add	a0,s1,540
    80004e04:	ffffd097          	auipc	ra,0xffffd
    80004e08:	47e080e7          	jalr	1150(ra) # 80002282 <wakeup>
  release(&pi->lock);
    80004e0c:	8526                	mv	a0,s1
    80004e0e:	ffffc097          	auipc	ra,0xffffc
    80004e12:	ed8080e7          	jalr	-296(ra) # 80000ce6 <release>
    80004e16:	6b42                	ld	s6,16(sp)
  return i;
}
    80004e18:	854e                	mv	a0,s3
    80004e1a:	60a6                	ld	ra,72(sp)
    80004e1c:	6406                	ld	s0,64(sp)
    80004e1e:	74e2                	ld	s1,56(sp)
    80004e20:	7942                	ld	s2,48(sp)
    80004e22:	79a2                	ld	s3,40(sp)
    80004e24:	7a02                	ld	s4,32(sp)
    80004e26:	6ae2                	ld	s5,24(sp)
    80004e28:	6161                	add	sp,sp,80
    80004e2a:	8082                	ret

0000000080004e2c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004e2c:	df010113          	add	sp,sp,-528
    80004e30:	20113423          	sd	ra,520(sp)
    80004e34:	20813023          	sd	s0,512(sp)
    80004e38:	ffa6                	sd	s1,504(sp)
    80004e3a:	fbca                	sd	s2,496(sp)
    80004e3c:	0c00                	add	s0,sp,528
    80004e3e:	892a                	mv	s2,a0
    80004e40:	dea43c23          	sd	a0,-520(s0)
    80004e44:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e48:	ffffd097          	auipc	ra,0xffffd
    80004e4c:	be8080e7          	jalr	-1048(ra) # 80001a30 <myproc>
    80004e50:	84aa                	mv	s1,a0

  begin_op();
    80004e52:	fffff097          	auipc	ra,0xfffff
    80004e56:	3f4080e7          	jalr	1012(ra) # 80004246 <begin_op>

  if((ip = namei(path)) == 0){
    80004e5a:	854a                	mv	a0,s2
    80004e5c:	fffff097          	auipc	ra,0xfffff
    80004e60:	1ea080e7          	jalr	490(ra) # 80004046 <namei>
    80004e64:	c135                	beqz	a0,80004ec8 <exec+0x9c>
    80004e66:	f3d2                	sd	s4,480(sp)
    80004e68:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e6a:	fffff097          	auipc	ra,0xfffff
    80004e6e:	a0a080e7          	jalr	-1526(ra) # 80003874 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e72:	04000713          	li	a4,64
    80004e76:	4681                	li	a3,0
    80004e78:	e5040613          	add	a2,s0,-432
    80004e7c:	4581                	li	a1,0
    80004e7e:	8552                	mv	a0,s4
    80004e80:	fffff097          	auipc	ra,0xfffff
    80004e84:	cac080e7          	jalr	-852(ra) # 80003b2c <readi>
    80004e88:	04000793          	li	a5,64
    80004e8c:	00f51a63          	bne	a0,a5,80004ea0 <exec+0x74>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e90:	e5042703          	lw	a4,-432(s0)
    80004e94:	464c47b7          	lui	a5,0x464c4
    80004e98:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e9c:	02f70c63          	beq	a4,a5,80004ed4 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ea0:	8552                	mv	a0,s4
    80004ea2:	fffff097          	auipc	ra,0xfffff
    80004ea6:	c38080e7          	jalr	-968(ra) # 80003ada <iunlockput>
    end_op();
    80004eaa:	fffff097          	auipc	ra,0xfffff
    80004eae:	416080e7          	jalr	1046(ra) # 800042c0 <end_op>
  }
  return -1;
    80004eb2:	557d                	li	a0,-1
    80004eb4:	7a1e                	ld	s4,480(sp)
}
    80004eb6:	20813083          	ld	ra,520(sp)
    80004eba:	20013403          	ld	s0,512(sp)
    80004ebe:	74fe                	ld	s1,504(sp)
    80004ec0:	795e                	ld	s2,496(sp)
    80004ec2:	21010113          	add	sp,sp,528
    80004ec6:	8082                	ret
    end_op();
    80004ec8:	fffff097          	auipc	ra,0xfffff
    80004ecc:	3f8080e7          	jalr	1016(ra) # 800042c0 <end_op>
    return -1;
    80004ed0:	557d                	li	a0,-1
    80004ed2:	b7d5                	j	80004eb6 <exec+0x8a>
    80004ed4:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004ed6:	8526                	mv	a0,s1
    80004ed8:	ffffd097          	auipc	ra,0xffffd
    80004edc:	c1c080e7          	jalr	-996(ra) # 80001af4 <proc_pagetable>
    80004ee0:	8b2a                	mv	s6,a0
    80004ee2:	30050563          	beqz	a0,800051ec <exec+0x3c0>
    80004ee6:	f7ce                	sd	s3,488(sp)
    80004ee8:	efd6                	sd	s5,472(sp)
    80004eea:	e7de                	sd	s7,456(sp)
    80004eec:	e3e2                	sd	s8,448(sp)
    80004eee:	ff66                	sd	s9,440(sp)
    80004ef0:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ef2:	e7042d03          	lw	s10,-400(s0)
    80004ef6:	e8845783          	lhu	a5,-376(s0)
    80004efa:	14078563          	beqz	a5,80005044 <exec+0x218>
    80004efe:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f00:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f02:	4d81                	li	s11,0
    if((ph.vaddr % PGSIZE) != 0)
    80004f04:	6c85                	lui	s9,0x1
    80004f06:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f0a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004f0e:	6a85                	lui	s5,0x1
    80004f10:	a0b5                	j	80004f7c <exec+0x150>
      panic("loadseg: address should exist");
    80004f12:	00003517          	auipc	a0,0x3
    80004f16:	6ce50513          	add	a0,a0,1742 # 800085e0 <etext+0x5e0>
    80004f1a:	ffffb097          	auipc	ra,0xffffb
    80004f1e:	640080e7          	jalr	1600(ra) # 8000055a <panic>
    if(sz - i < PGSIZE)
    80004f22:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f24:	8726                	mv	a4,s1
    80004f26:	012c06bb          	addw	a3,s8,s2
    80004f2a:	4581                	li	a1,0
    80004f2c:	8552                	mv	a0,s4
    80004f2e:	fffff097          	auipc	ra,0xfffff
    80004f32:	bfe080e7          	jalr	-1026(ra) # 80003b2c <readi>
    80004f36:	2501                	sext.w	a0,a0
    80004f38:	26a49e63          	bne	s1,a0,800051b4 <exec+0x388>
  for(i = 0; i < sz; i += PGSIZE){
    80004f3c:	012a893b          	addw	s2,s5,s2
    80004f40:	03397563          	bgeu	s2,s3,80004f6a <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80004f44:	02091593          	sll	a1,s2,0x20
    80004f48:	9181                	srl	a1,a1,0x20
    80004f4a:	95de                	add	a1,a1,s7
    80004f4c:	855a                	mv	a0,s6
    80004f4e:	ffffc097          	auipc	ra,0xffffc
    80004f52:	15e080e7          	jalr	350(ra) # 800010ac <walkaddr>
    80004f56:	862a                	mv	a2,a0
    if(pa == 0)
    80004f58:	dd4d                	beqz	a0,80004f12 <exec+0xe6>
    if(sz - i < PGSIZE)
    80004f5a:	412984bb          	subw	s1,s3,s2
    80004f5e:	0004879b          	sext.w	a5,s1
    80004f62:	fcfcf0e3          	bgeu	s9,a5,80004f22 <exec+0xf6>
    80004f66:	84d6                	mv	s1,s5
    80004f68:	bf6d                	j	80004f22 <exec+0xf6>
    sz = sz1;
    80004f6a:	e0843483          	ld	s1,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f6e:	2d85                	addw	s11,s11,1
    80004f70:	038d0d1b          	addw	s10,s10,56
    80004f74:	e8845783          	lhu	a5,-376(s0)
    80004f78:	06fddf63          	bge	s11,a5,80004ff6 <exec+0x1ca>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f7c:	2d01                	sext.w	s10,s10
    80004f7e:	03800713          	li	a4,56
    80004f82:	86ea                	mv	a3,s10
    80004f84:	e1840613          	add	a2,s0,-488
    80004f88:	4581                	li	a1,0
    80004f8a:	8552                	mv	a0,s4
    80004f8c:	fffff097          	auipc	ra,0xfffff
    80004f90:	ba0080e7          	jalr	-1120(ra) # 80003b2c <readi>
    80004f94:	03800793          	li	a5,56
    80004f98:	1ef51863          	bne	a0,a5,80005188 <exec+0x35c>
    if(ph.type != ELF_PROG_LOAD)
    80004f9c:	e1842783          	lw	a5,-488(s0)
    80004fa0:	4705                	li	a4,1
    80004fa2:	fce796e3          	bne	a5,a4,80004f6e <exec+0x142>
    if(ph.memsz < ph.filesz)
    80004fa6:	e4043603          	ld	a2,-448(s0)
    80004faa:	e3843783          	ld	a5,-456(s0)
    80004fae:	1ef66163          	bltu	a2,a5,80005190 <exec+0x364>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004fb2:	e2843783          	ld	a5,-472(s0)
    80004fb6:	963e                	add	a2,a2,a5
    80004fb8:	1ef66063          	bltu	a2,a5,80005198 <exec+0x36c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fbc:	85a6                	mv	a1,s1
    80004fbe:	855a                	mv	a0,s6
    80004fc0:	ffffc097          	auipc	ra,0xffffc
    80004fc4:	4b0080e7          	jalr	1200(ra) # 80001470 <uvmalloc>
    80004fc8:	e0a43423          	sd	a0,-504(s0)
    80004fcc:	1c050a63          	beqz	a0,800051a0 <exec+0x374>
    if((ph.vaddr % PGSIZE) != 0)
    80004fd0:	e2843b83          	ld	s7,-472(s0)
    80004fd4:	df043783          	ld	a5,-528(s0)
    80004fd8:	00fbf7b3          	and	a5,s7,a5
    80004fdc:	1c079a63          	bnez	a5,800051b0 <exec+0x384>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fe0:	e2042c03          	lw	s8,-480(s0)
    80004fe4:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fe8:	00098463          	beqz	s3,80004ff0 <exec+0x1c4>
    80004fec:	4901                	li	s2,0
    80004fee:	bf99                	j	80004f44 <exec+0x118>
    sz = sz1;
    80004ff0:	e0843483          	ld	s1,-504(s0)
    80004ff4:	bfad                	j	80004f6e <exec+0x142>
    80004ff6:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004ff8:	8552                	mv	a0,s4
    80004ffa:	fffff097          	auipc	ra,0xfffff
    80004ffe:	ae0080e7          	jalr	-1312(ra) # 80003ada <iunlockput>
  end_op();
    80005002:	fffff097          	auipc	ra,0xfffff
    80005006:	2be080e7          	jalr	702(ra) # 800042c0 <end_op>
  p = myproc();
    8000500a:	ffffd097          	auipc	ra,0xffffd
    8000500e:	a26080e7          	jalr	-1498(ra) # 80001a30 <myproc>
    80005012:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005014:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005018:	6985                	lui	s3,0x1
    8000501a:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000501c:	99a6                	add	s3,s3,s1
    8000501e:	77fd                	lui	a5,0xfffff
    80005020:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005024:	6609                	lui	a2,0x2
    80005026:	964e                	add	a2,a2,s3
    80005028:	85ce                	mv	a1,s3
    8000502a:	855a                	mv	a0,s6
    8000502c:	ffffc097          	auipc	ra,0xffffc
    80005030:	444080e7          	jalr	1092(ra) # 80001470 <uvmalloc>
    80005034:	892a                	mv	s2,a0
    80005036:	e0a43423          	sd	a0,-504(s0)
    8000503a:	e519                	bnez	a0,80005048 <exec+0x21c>
  if(pagetable)
    8000503c:	e1343423          	sd	s3,-504(s0)
    80005040:	4a01                	li	s4,0
    80005042:	aa95                	j	800051b6 <exec+0x38a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005044:	4481                	li	s1,0
    80005046:	bf4d                	j	80004ff8 <exec+0x1cc>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005048:	75f9                	lui	a1,0xffffe
    8000504a:	95aa                	add	a1,a1,a0
    8000504c:	855a                	mv	a0,s6
    8000504e:	ffffc097          	auipc	ra,0xffffc
    80005052:	64c080e7          	jalr	1612(ra) # 8000169a <uvmclear>
  stackbase = sp - PGSIZE;
    80005056:	7bfd                	lui	s7,0xfffff
    80005058:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000505a:	e0043783          	ld	a5,-512(s0)
    8000505e:	6388                	ld	a0,0(a5)
    80005060:	c52d                	beqz	a0,800050ca <exec+0x29e>
    80005062:	e9040993          	add	s3,s0,-368
    80005066:	f9040c13          	add	s8,s0,-112
    8000506a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000506c:	ffffc097          	auipc	ra,0xffffc
    80005070:	e36080e7          	jalr	-458(ra) # 80000ea2 <strlen>
    80005074:	0015079b          	addw	a5,a0,1
    80005078:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000507c:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    80005080:	13796463          	bltu	s2,s7,800051a8 <exec+0x37c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005084:	e0043d03          	ld	s10,-512(s0)
    80005088:	000d3a03          	ld	s4,0(s10)
    8000508c:	8552                	mv	a0,s4
    8000508e:	ffffc097          	auipc	ra,0xffffc
    80005092:	e14080e7          	jalr	-492(ra) # 80000ea2 <strlen>
    80005096:	0015069b          	addw	a3,a0,1
    8000509a:	8652                	mv	a2,s4
    8000509c:	85ca                	mv	a1,s2
    8000509e:	855a                	mv	a0,s6
    800050a0:	ffffc097          	auipc	ra,0xffffc
    800050a4:	62c080e7          	jalr	1580(ra) # 800016cc <copyout>
    800050a8:	10054263          	bltz	a0,800051ac <exec+0x380>
    ustack[argc] = sp;
    800050ac:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800050b0:	0485                	add	s1,s1,1
    800050b2:	008d0793          	add	a5,s10,8
    800050b6:	e0f43023          	sd	a5,-512(s0)
    800050ba:	008d3503          	ld	a0,8(s10)
    800050be:	c909                	beqz	a0,800050d0 <exec+0x2a4>
    if(argc >= MAXARG)
    800050c0:	09a1                	add	s3,s3,8
    800050c2:	fb8995e3          	bne	s3,s8,8000506c <exec+0x240>
  ip = 0;
    800050c6:	4a01                	li	s4,0
    800050c8:	a0fd                	j	800051b6 <exec+0x38a>
  sp = sz;
    800050ca:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800050ce:	4481                	li	s1,0
  ustack[argc] = 0;
    800050d0:	00349793          	sll	a5,s1,0x3
    800050d4:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd8f90>
    800050d8:	97a2                	add	a5,a5,s0
    800050da:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800050de:	00148693          	add	a3,s1,1
    800050e2:	068e                	sll	a3,a3,0x3
    800050e4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050e8:	ff097913          	and	s2,s2,-16
  sz = sz1;
    800050ec:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800050f0:	f57966e3          	bltu	s2,s7,8000503c <exec+0x210>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050f4:	e9040613          	add	a2,s0,-368
    800050f8:	85ca                	mv	a1,s2
    800050fa:	855a                	mv	a0,s6
    800050fc:	ffffc097          	auipc	ra,0xffffc
    80005100:	5d0080e7          	jalr	1488(ra) # 800016cc <copyout>
    80005104:	0e054663          	bltz	a0,800051f0 <exec+0x3c4>
  p->trapframe->a1 = sp;
    80005108:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000510c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005110:	df843783          	ld	a5,-520(s0)
    80005114:	0007c703          	lbu	a4,0(a5)
    80005118:	cf11                	beqz	a4,80005134 <exec+0x308>
    8000511a:	0785                	add	a5,a5,1
    if(*s == '/')
    8000511c:	02f00693          	li	a3,47
    80005120:	a039                	j	8000512e <exec+0x302>
      last = s+1;
    80005122:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005126:	0785                	add	a5,a5,1
    80005128:	fff7c703          	lbu	a4,-1(a5)
    8000512c:	c701                	beqz	a4,80005134 <exec+0x308>
    if(*s == '/')
    8000512e:	fed71ce3          	bne	a4,a3,80005126 <exec+0x2fa>
    80005132:	bfc5                	j	80005122 <exec+0x2f6>
  safestrcpy(p->name, last, sizeof(p->name));
    80005134:	4641                	li	a2,16
    80005136:	df843583          	ld	a1,-520(s0)
    8000513a:	158a8513          	add	a0,s5,344
    8000513e:	ffffc097          	auipc	ra,0xffffc
    80005142:	d32080e7          	jalr	-718(ra) # 80000e70 <safestrcpy>
  oldpagetable = p->pagetable;
    80005146:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000514a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000514e:	e0843783          	ld	a5,-504(s0)
    80005152:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005156:	058ab783          	ld	a5,88(s5)
    8000515a:	e6843703          	ld	a4,-408(s0)
    8000515e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005160:	058ab783          	ld	a5,88(s5)
    80005164:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005168:	85e6                	mv	a1,s9
    8000516a:	ffffd097          	auipc	ra,0xffffd
    8000516e:	a26080e7          	jalr	-1498(ra) # 80001b90 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005172:	0004851b          	sext.w	a0,s1
    80005176:	79be                	ld	s3,488(sp)
    80005178:	7a1e                	ld	s4,480(sp)
    8000517a:	6afe                	ld	s5,472(sp)
    8000517c:	6b5e                	ld	s6,464(sp)
    8000517e:	6bbe                	ld	s7,456(sp)
    80005180:	6c1e                	ld	s8,448(sp)
    80005182:	7cfa                	ld	s9,440(sp)
    80005184:	7d5a                	ld	s10,432(sp)
    80005186:	bb05                	j	80004eb6 <exec+0x8a>
    80005188:	e0943423          	sd	s1,-504(s0)
    8000518c:	7dba                	ld	s11,424(sp)
    8000518e:	a025                	j	800051b6 <exec+0x38a>
    80005190:	e0943423          	sd	s1,-504(s0)
    80005194:	7dba                	ld	s11,424(sp)
    80005196:	a005                	j	800051b6 <exec+0x38a>
    80005198:	e0943423          	sd	s1,-504(s0)
    8000519c:	7dba                	ld	s11,424(sp)
    8000519e:	a821                	j	800051b6 <exec+0x38a>
    800051a0:	e0943423          	sd	s1,-504(s0)
    800051a4:	7dba                	ld	s11,424(sp)
    800051a6:	a801                	j	800051b6 <exec+0x38a>
  ip = 0;
    800051a8:	4a01                	li	s4,0
    800051aa:	a031                	j	800051b6 <exec+0x38a>
    800051ac:	4a01                	li	s4,0
  if(pagetable)
    800051ae:	a021                	j	800051b6 <exec+0x38a>
    800051b0:	7dba                	ld	s11,424(sp)
    800051b2:	a011                	j	800051b6 <exec+0x38a>
    800051b4:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    800051b6:	e0843583          	ld	a1,-504(s0)
    800051ba:	855a                	mv	a0,s6
    800051bc:	ffffd097          	auipc	ra,0xffffd
    800051c0:	9d4080e7          	jalr	-1580(ra) # 80001b90 <proc_freepagetable>
  return -1;
    800051c4:	557d                	li	a0,-1
  if(ip){
    800051c6:	000a1b63          	bnez	s4,800051dc <exec+0x3b0>
    800051ca:	79be                	ld	s3,488(sp)
    800051cc:	7a1e                	ld	s4,480(sp)
    800051ce:	6afe                	ld	s5,472(sp)
    800051d0:	6b5e                	ld	s6,464(sp)
    800051d2:	6bbe                	ld	s7,456(sp)
    800051d4:	6c1e                	ld	s8,448(sp)
    800051d6:	7cfa                	ld	s9,440(sp)
    800051d8:	7d5a                	ld	s10,432(sp)
    800051da:	b9f1                	j	80004eb6 <exec+0x8a>
    800051dc:	79be                	ld	s3,488(sp)
    800051de:	6afe                	ld	s5,472(sp)
    800051e0:	6b5e                	ld	s6,464(sp)
    800051e2:	6bbe                	ld	s7,456(sp)
    800051e4:	6c1e                	ld	s8,448(sp)
    800051e6:	7cfa                	ld	s9,440(sp)
    800051e8:	7d5a                	ld	s10,432(sp)
    800051ea:	b95d                	j	80004ea0 <exec+0x74>
    800051ec:	6b5e                	ld	s6,464(sp)
    800051ee:	b94d                	j	80004ea0 <exec+0x74>
  sz = sz1;
    800051f0:	e0843983          	ld	s3,-504(s0)
    800051f4:	b5a1                	j	8000503c <exec+0x210>

00000000800051f6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051f6:	7179                	add	sp,sp,-48
    800051f8:	f406                	sd	ra,40(sp)
    800051fa:	f022                	sd	s0,32(sp)
    800051fc:	ec26                	sd	s1,24(sp)
    800051fe:	e84a                	sd	s2,16(sp)
    80005200:	1800                	add	s0,sp,48
    80005202:	892e                	mv	s2,a1
    80005204:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005206:	fdc40593          	add	a1,s0,-36
    8000520a:	ffffe097          	auipc	ra,0xffffe
    8000520e:	af8080e7          	jalr	-1288(ra) # 80002d02 <argint>
    80005212:	04054063          	bltz	a0,80005252 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005216:	fdc42703          	lw	a4,-36(s0)
    8000521a:	47bd                	li	a5,15
    8000521c:	02e7ed63          	bltu	a5,a4,80005256 <argfd+0x60>
    80005220:	ffffd097          	auipc	ra,0xffffd
    80005224:	810080e7          	jalr	-2032(ra) # 80001a30 <myproc>
    80005228:	fdc42703          	lw	a4,-36(s0)
    8000522c:	01a70793          	add	a5,a4,26
    80005230:	078e                	sll	a5,a5,0x3
    80005232:	953e                	add	a0,a0,a5
    80005234:	611c                	ld	a5,0(a0)
    80005236:	c395                	beqz	a5,8000525a <argfd+0x64>
    return -1;
  if(pfd)
    80005238:	00090463          	beqz	s2,80005240 <argfd+0x4a>
    *pfd = fd;
    8000523c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005240:	4501                	li	a0,0
  if(pf)
    80005242:	c091                	beqz	s1,80005246 <argfd+0x50>
    *pf = f;
    80005244:	e09c                	sd	a5,0(s1)
}
    80005246:	70a2                	ld	ra,40(sp)
    80005248:	7402                	ld	s0,32(sp)
    8000524a:	64e2                	ld	s1,24(sp)
    8000524c:	6942                	ld	s2,16(sp)
    8000524e:	6145                	add	sp,sp,48
    80005250:	8082                	ret
    return -1;
    80005252:	557d                	li	a0,-1
    80005254:	bfcd                	j	80005246 <argfd+0x50>
    return -1;
    80005256:	557d                	li	a0,-1
    80005258:	b7fd                	j	80005246 <argfd+0x50>
    8000525a:	557d                	li	a0,-1
    8000525c:	b7ed                	j	80005246 <argfd+0x50>

000000008000525e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000525e:	1101                	add	sp,sp,-32
    80005260:	ec06                	sd	ra,24(sp)
    80005262:	e822                	sd	s0,16(sp)
    80005264:	e426                	sd	s1,8(sp)
    80005266:	1000                	add	s0,sp,32
    80005268:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000526a:	ffffc097          	auipc	ra,0xffffc
    8000526e:	7c6080e7          	jalr	1990(ra) # 80001a30 <myproc>
    80005272:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005274:	0d050793          	add	a5,a0,208
    80005278:	4501                	li	a0,0
    8000527a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000527c:	6398                	ld	a4,0(a5)
    8000527e:	cb19                	beqz	a4,80005294 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005280:	2505                	addw	a0,a0,1
    80005282:	07a1                	add	a5,a5,8
    80005284:	fed51ce3          	bne	a0,a3,8000527c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005288:	557d                	li	a0,-1
}
    8000528a:	60e2                	ld	ra,24(sp)
    8000528c:	6442                	ld	s0,16(sp)
    8000528e:	64a2                	ld	s1,8(sp)
    80005290:	6105                	add	sp,sp,32
    80005292:	8082                	ret
      p->ofile[fd] = f;
    80005294:	01a50793          	add	a5,a0,26
    80005298:	078e                	sll	a5,a5,0x3
    8000529a:	963e                	add	a2,a2,a5
    8000529c:	e204                	sd	s1,0(a2)
      return fd;
    8000529e:	b7f5                	j	8000528a <fdalloc+0x2c>

00000000800052a0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800052a0:	715d                	add	sp,sp,-80
    800052a2:	e486                	sd	ra,72(sp)
    800052a4:	e0a2                	sd	s0,64(sp)
    800052a6:	fc26                	sd	s1,56(sp)
    800052a8:	f84a                	sd	s2,48(sp)
    800052aa:	f44e                	sd	s3,40(sp)
    800052ac:	f052                	sd	s4,32(sp)
    800052ae:	ec56                	sd	s5,24(sp)
    800052b0:	0880                	add	s0,sp,80
    800052b2:	8aae                	mv	s5,a1
    800052b4:	8a32                	mv	s4,a2
    800052b6:	89b6                	mv	s3,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052b8:	fb040593          	add	a1,s0,-80
    800052bc:	fffff097          	auipc	ra,0xfffff
    800052c0:	da8080e7          	jalr	-600(ra) # 80004064 <nameiparent>
    800052c4:	892a                	mv	s2,a0
    800052c6:	12050c63          	beqz	a0,800053fe <create+0x15e>
    return 0;

  ilock(dp);
    800052ca:	ffffe097          	auipc	ra,0xffffe
    800052ce:	5aa080e7          	jalr	1450(ra) # 80003874 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052d2:	4601                	li	a2,0
    800052d4:	fb040593          	add	a1,s0,-80
    800052d8:	854a                	mv	a0,s2
    800052da:	fffff097          	auipc	ra,0xfffff
    800052de:	a9a080e7          	jalr	-1382(ra) # 80003d74 <dirlookup>
    800052e2:	84aa                	mv	s1,a0
    800052e4:	c539                	beqz	a0,80005332 <create+0x92>
    iunlockput(dp);
    800052e6:	854a                	mv	a0,s2
    800052e8:	ffffe097          	auipc	ra,0xffffe
    800052ec:	7f2080e7          	jalr	2034(ra) # 80003ada <iunlockput>
    ilock(ip);
    800052f0:	8526                	mv	a0,s1
    800052f2:	ffffe097          	auipc	ra,0xffffe
    800052f6:	582080e7          	jalr	1410(ra) # 80003874 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052fa:	4789                	li	a5,2
    800052fc:	02fa9463          	bne	s5,a5,80005324 <create+0x84>
    80005300:	04c4d783          	lhu	a5,76(s1)
    80005304:	37f9                	addw	a5,a5,-2
    80005306:	17c2                	sll	a5,a5,0x30
    80005308:	93c1                	srl	a5,a5,0x30
    8000530a:	4705                	li	a4,1
    8000530c:	00f76c63          	bltu	a4,a5,80005324 <create+0x84>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005310:	8526                	mv	a0,s1
    80005312:	60a6                	ld	ra,72(sp)
    80005314:	6406                	ld	s0,64(sp)
    80005316:	74e2                	ld	s1,56(sp)
    80005318:	7942                	ld	s2,48(sp)
    8000531a:	79a2                	ld	s3,40(sp)
    8000531c:	7a02                	ld	s4,32(sp)
    8000531e:	6ae2                	ld	s5,24(sp)
    80005320:	6161                	add	sp,sp,80
    80005322:	8082                	ret
    iunlockput(ip);
    80005324:	8526                	mv	a0,s1
    80005326:	ffffe097          	auipc	ra,0xffffe
    8000532a:	7b4080e7          	jalr	1972(ra) # 80003ada <iunlockput>
    return 0;
    8000532e:	4481                	li	s1,0
    80005330:	b7c5                	j	80005310 <create+0x70>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005332:	85d6                	mv	a1,s5
    80005334:	00092503          	lw	a0,0(s2)
    80005338:	ffffe097          	auipc	ra,0xffffe
    8000533c:	3a8080e7          	jalr	936(ra) # 800036e0 <ialloc>
    80005340:	84aa                	mv	s1,a0
    80005342:	c139                	beqz	a0,80005388 <create+0xe8>
  ilock(ip);
    80005344:	ffffe097          	auipc	ra,0xffffe
    80005348:	530080e7          	jalr	1328(ra) # 80003874 <ilock>
  ip->major = major;
    8000534c:	05449723          	sh	s4,78(s1)
  ip->minor = minor;
    80005350:	05349823          	sh	s3,80(s1)
  ip->nlink = 1;
    80005354:	4985                	li	s3,1
    80005356:	05349923          	sh	s3,82(s1)
  iupdate(ip);
    8000535a:	8526                	mv	a0,s1
    8000535c:	ffffe097          	auipc	ra,0xffffe
    80005360:	44c080e7          	jalr	1100(ra) # 800037a8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005364:	033a8a63          	beq	s5,s3,80005398 <create+0xf8>
  if(dirlink(dp, name, ip->inum) < 0)
    80005368:	40d0                	lw	a2,4(s1)
    8000536a:	fb040593          	add	a1,s0,-80
    8000536e:	854a                	mv	a0,s2
    80005370:	fffff097          	auipc	ra,0xfffff
    80005374:	c14080e7          	jalr	-1004(ra) # 80003f84 <dirlink>
    80005378:	06054b63          	bltz	a0,800053ee <create+0x14e>
  iunlockput(dp);
    8000537c:	854a                	mv	a0,s2
    8000537e:	ffffe097          	auipc	ra,0xffffe
    80005382:	75c080e7          	jalr	1884(ra) # 80003ada <iunlockput>
  return ip;
    80005386:	b769                	j	80005310 <create+0x70>
    panic("create: ialloc");
    80005388:	00003517          	auipc	a0,0x3
    8000538c:	27850513          	add	a0,a0,632 # 80008600 <etext+0x600>
    80005390:	ffffb097          	auipc	ra,0xffffb
    80005394:	1ca080e7          	jalr	458(ra) # 8000055a <panic>
    dp->nlink++;  // for ".."
    80005398:	05295783          	lhu	a5,82(s2)
    8000539c:	2785                	addw	a5,a5,1
    8000539e:	04f91923          	sh	a5,82(s2)
    iupdate(dp);
    800053a2:	854a                	mv	a0,s2
    800053a4:	ffffe097          	auipc	ra,0xffffe
    800053a8:	404080e7          	jalr	1028(ra) # 800037a8 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053ac:	40d0                	lw	a2,4(s1)
    800053ae:	00003597          	auipc	a1,0x3
    800053b2:	26258593          	add	a1,a1,610 # 80008610 <etext+0x610>
    800053b6:	8526                	mv	a0,s1
    800053b8:	fffff097          	auipc	ra,0xfffff
    800053bc:	bcc080e7          	jalr	-1076(ra) # 80003f84 <dirlink>
    800053c0:	00054f63          	bltz	a0,800053de <create+0x13e>
    800053c4:	00492603          	lw	a2,4(s2)
    800053c8:	00003597          	auipc	a1,0x3
    800053cc:	25058593          	add	a1,a1,592 # 80008618 <etext+0x618>
    800053d0:	8526                	mv	a0,s1
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	bb2080e7          	jalr	-1102(ra) # 80003f84 <dirlink>
    800053da:	f80557e3          	bgez	a0,80005368 <create+0xc8>
      panic("create dots");
    800053de:	00003517          	auipc	a0,0x3
    800053e2:	24250513          	add	a0,a0,578 # 80008620 <etext+0x620>
    800053e6:	ffffb097          	auipc	ra,0xffffb
    800053ea:	174080e7          	jalr	372(ra) # 8000055a <panic>
    panic("create: dirlink");
    800053ee:	00003517          	auipc	a0,0x3
    800053f2:	24250513          	add	a0,a0,578 # 80008630 <etext+0x630>
    800053f6:	ffffb097          	auipc	ra,0xffffb
    800053fa:	164080e7          	jalr	356(ra) # 8000055a <panic>
    return 0;
    800053fe:	84aa                	mv	s1,a0
    80005400:	bf01                	j	80005310 <create+0x70>

0000000080005402 <sys_dup>:
{
    80005402:	7179                	add	sp,sp,-48
    80005404:	f406                	sd	ra,40(sp)
    80005406:	f022                	sd	s0,32(sp)
    80005408:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000540a:	fd840613          	add	a2,s0,-40
    8000540e:	4581                	li	a1,0
    80005410:	4501                	li	a0,0
    80005412:	00000097          	auipc	ra,0x0
    80005416:	de4080e7          	jalr	-540(ra) # 800051f6 <argfd>
    return -1;
    8000541a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000541c:	02054763          	bltz	a0,8000544a <sys_dup+0x48>
    80005420:	ec26                	sd	s1,24(sp)
    80005422:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005424:	fd843903          	ld	s2,-40(s0)
    80005428:	854a                	mv	a0,s2
    8000542a:	00000097          	auipc	ra,0x0
    8000542e:	e34080e7          	jalr	-460(ra) # 8000525e <fdalloc>
    80005432:	84aa                	mv	s1,a0
    return -1;
    80005434:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005436:	00054f63          	bltz	a0,80005454 <sys_dup+0x52>
  filedup(f);
    8000543a:	854a                	mv	a0,s2
    8000543c:	fffff097          	auipc	ra,0xfffff
    80005440:	2ee080e7          	jalr	750(ra) # 8000472a <filedup>
  return fd;
    80005444:	87a6                	mv	a5,s1
    80005446:	64e2                	ld	s1,24(sp)
    80005448:	6942                	ld	s2,16(sp)
}
    8000544a:	853e                	mv	a0,a5
    8000544c:	70a2                	ld	ra,40(sp)
    8000544e:	7402                	ld	s0,32(sp)
    80005450:	6145                	add	sp,sp,48
    80005452:	8082                	ret
    80005454:	64e2                	ld	s1,24(sp)
    80005456:	6942                	ld	s2,16(sp)
    80005458:	bfcd                	j	8000544a <sys_dup+0x48>

000000008000545a <sys_read>:
{
    8000545a:	7179                	add	sp,sp,-48
    8000545c:	f406                	sd	ra,40(sp)
    8000545e:	f022                	sd	s0,32(sp)
    80005460:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005462:	fe840613          	add	a2,s0,-24
    80005466:	4581                	li	a1,0
    80005468:	4501                	li	a0,0
    8000546a:	00000097          	auipc	ra,0x0
    8000546e:	d8c080e7          	jalr	-628(ra) # 800051f6 <argfd>
    return -1;
    80005472:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005474:	04054163          	bltz	a0,800054b6 <sys_read+0x5c>
    80005478:	fe440593          	add	a1,s0,-28
    8000547c:	4509                	li	a0,2
    8000547e:	ffffe097          	auipc	ra,0xffffe
    80005482:	884080e7          	jalr	-1916(ra) # 80002d02 <argint>
    return -1;
    80005486:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005488:	02054763          	bltz	a0,800054b6 <sys_read+0x5c>
    8000548c:	fd840593          	add	a1,s0,-40
    80005490:	4505                	li	a0,1
    80005492:	ffffe097          	auipc	ra,0xffffe
    80005496:	892080e7          	jalr	-1902(ra) # 80002d24 <argaddr>
    return -1;
    8000549a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000549c:	00054d63          	bltz	a0,800054b6 <sys_read+0x5c>
  return fileread(f, p, n);
    800054a0:	fe442603          	lw	a2,-28(s0)
    800054a4:	fd843583          	ld	a1,-40(s0)
    800054a8:	fe843503          	ld	a0,-24(s0)
    800054ac:	fffff097          	auipc	ra,0xfffff
    800054b0:	424080e7          	jalr	1060(ra) # 800048d0 <fileread>
    800054b4:	87aa                	mv	a5,a0
}
    800054b6:	853e                	mv	a0,a5
    800054b8:	70a2                	ld	ra,40(sp)
    800054ba:	7402                	ld	s0,32(sp)
    800054bc:	6145                	add	sp,sp,48
    800054be:	8082                	ret

00000000800054c0 <sys_write>:
{
    800054c0:	7179                	add	sp,sp,-48
    800054c2:	f406                	sd	ra,40(sp)
    800054c4:	f022                	sd	s0,32(sp)
    800054c6:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054c8:	fe840613          	add	a2,s0,-24
    800054cc:	4581                	li	a1,0
    800054ce:	4501                	li	a0,0
    800054d0:	00000097          	auipc	ra,0x0
    800054d4:	d26080e7          	jalr	-730(ra) # 800051f6 <argfd>
    return -1;
    800054d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054da:	04054163          	bltz	a0,8000551c <sys_write+0x5c>
    800054de:	fe440593          	add	a1,s0,-28
    800054e2:	4509                	li	a0,2
    800054e4:	ffffe097          	auipc	ra,0xffffe
    800054e8:	81e080e7          	jalr	-2018(ra) # 80002d02 <argint>
    return -1;
    800054ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054ee:	02054763          	bltz	a0,8000551c <sys_write+0x5c>
    800054f2:	fd840593          	add	a1,s0,-40
    800054f6:	4505                	li	a0,1
    800054f8:	ffffe097          	auipc	ra,0xffffe
    800054fc:	82c080e7          	jalr	-2004(ra) # 80002d24 <argaddr>
    return -1;
    80005500:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005502:	00054d63          	bltz	a0,8000551c <sys_write+0x5c>
  return filewrite(f, p, n);
    80005506:	fe442603          	lw	a2,-28(s0)
    8000550a:	fd843583          	ld	a1,-40(s0)
    8000550e:	fe843503          	ld	a0,-24(s0)
    80005512:	fffff097          	auipc	ra,0xfffff
    80005516:	490080e7          	jalr	1168(ra) # 800049a2 <filewrite>
    8000551a:	87aa                	mv	a5,a0
}
    8000551c:	853e                	mv	a0,a5
    8000551e:	70a2                	ld	ra,40(sp)
    80005520:	7402                	ld	s0,32(sp)
    80005522:	6145                	add	sp,sp,48
    80005524:	8082                	ret

0000000080005526 <sys_close>:
{
    80005526:	1101                	add	sp,sp,-32
    80005528:	ec06                	sd	ra,24(sp)
    8000552a:	e822                	sd	s0,16(sp)
    8000552c:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000552e:	fe040613          	add	a2,s0,-32
    80005532:	fec40593          	add	a1,s0,-20
    80005536:	4501                	li	a0,0
    80005538:	00000097          	auipc	ra,0x0
    8000553c:	cbe080e7          	jalr	-834(ra) # 800051f6 <argfd>
    return -1;
    80005540:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005542:	02054463          	bltz	a0,8000556a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005546:	ffffc097          	auipc	ra,0xffffc
    8000554a:	4ea080e7          	jalr	1258(ra) # 80001a30 <myproc>
    8000554e:	fec42783          	lw	a5,-20(s0)
    80005552:	07e9                	add	a5,a5,26
    80005554:	078e                	sll	a5,a5,0x3
    80005556:	953e                	add	a0,a0,a5
    80005558:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000555c:	fe043503          	ld	a0,-32(s0)
    80005560:	fffff097          	auipc	ra,0xfffff
    80005564:	21c080e7          	jalr	540(ra) # 8000477c <fileclose>
  return 0;
    80005568:	4781                	li	a5,0
}
    8000556a:	853e                	mv	a0,a5
    8000556c:	60e2                	ld	ra,24(sp)
    8000556e:	6442                	ld	s0,16(sp)
    80005570:	6105                	add	sp,sp,32
    80005572:	8082                	ret

0000000080005574 <sys_fstat>:
{
    80005574:	1101                	add	sp,sp,-32
    80005576:	ec06                	sd	ra,24(sp)
    80005578:	e822                	sd	s0,16(sp)
    8000557a:	1000                	add	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000557c:	fe840613          	add	a2,s0,-24
    80005580:	4581                	li	a1,0
    80005582:	4501                	li	a0,0
    80005584:	00000097          	auipc	ra,0x0
    80005588:	c72080e7          	jalr	-910(ra) # 800051f6 <argfd>
    return -1;
    8000558c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000558e:	02054563          	bltz	a0,800055b8 <sys_fstat+0x44>
    80005592:	fe040593          	add	a1,s0,-32
    80005596:	4505                	li	a0,1
    80005598:	ffffd097          	auipc	ra,0xffffd
    8000559c:	78c080e7          	jalr	1932(ra) # 80002d24 <argaddr>
    return -1;
    800055a0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800055a2:	00054b63          	bltz	a0,800055b8 <sys_fstat+0x44>
  return filestat(f, st);
    800055a6:	fe043583          	ld	a1,-32(s0)
    800055aa:	fe843503          	ld	a0,-24(s0)
    800055ae:	fffff097          	auipc	ra,0xfffff
    800055b2:	2b0080e7          	jalr	688(ra) # 8000485e <filestat>
    800055b6:	87aa                	mv	a5,a0
}
    800055b8:	853e                	mv	a0,a5
    800055ba:	60e2                	ld	ra,24(sp)
    800055bc:	6442                	ld	s0,16(sp)
    800055be:	6105                	add	sp,sp,32
    800055c0:	8082                	ret

00000000800055c2 <sys_link>:
{
    800055c2:	7169                	add	sp,sp,-304
    800055c4:	f606                	sd	ra,296(sp)
    800055c6:	f222                	sd	s0,288(sp)
    800055c8:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055ca:	08000613          	li	a2,128
    800055ce:	ed040593          	add	a1,s0,-304
    800055d2:	4501                	li	a0,0
    800055d4:	ffffd097          	auipc	ra,0xffffd
    800055d8:	772080e7          	jalr	1906(ra) # 80002d46 <argstr>
    return -1;
    800055dc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055de:	12054663          	bltz	a0,8000570a <sys_link+0x148>
    800055e2:	08000613          	li	a2,128
    800055e6:	f5040593          	add	a1,s0,-176
    800055ea:	4505                	li	a0,1
    800055ec:	ffffd097          	auipc	ra,0xffffd
    800055f0:	75a080e7          	jalr	1882(ra) # 80002d46 <argstr>
    return -1;
    800055f4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055f6:	10054a63          	bltz	a0,8000570a <sys_link+0x148>
    800055fa:	ee26                	sd	s1,280(sp)
  begin_op();
    800055fc:	fffff097          	auipc	ra,0xfffff
    80005600:	c4a080e7          	jalr	-950(ra) # 80004246 <begin_op>
  if((ip = namei(old)) == 0){
    80005604:	ed040513          	add	a0,s0,-304
    80005608:	fffff097          	auipc	ra,0xfffff
    8000560c:	a3e080e7          	jalr	-1474(ra) # 80004046 <namei>
    80005610:	84aa                	mv	s1,a0
    80005612:	c949                	beqz	a0,800056a4 <sys_link+0xe2>
  ilock(ip);
    80005614:	ffffe097          	auipc	ra,0xffffe
    80005618:	260080e7          	jalr	608(ra) # 80003874 <ilock>
  if(ip->type == T_DIR){
    8000561c:	04c49703          	lh	a4,76(s1)
    80005620:	4785                	li	a5,1
    80005622:	08f70863          	beq	a4,a5,800056b2 <sys_link+0xf0>
    80005626:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005628:	0524d783          	lhu	a5,82(s1)
    8000562c:	2785                	addw	a5,a5,1
    8000562e:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    80005632:	8526                	mv	a0,s1
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	174080e7          	jalr	372(ra) # 800037a8 <iupdate>
  iunlock(ip);
    8000563c:	8526                	mv	a0,s1
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	2fc080e7          	jalr	764(ra) # 8000393a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005646:	fd040593          	add	a1,s0,-48
    8000564a:	f5040513          	add	a0,s0,-176
    8000564e:	fffff097          	auipc	ra,0xfffff
    80005652:	a16080e7          	jalr	-1514(ra) # 80004064 <nameiparent>
    80005656:	892a                	mv	s2,a0
    80005658:	cd35                	beqz	a0,800056d4 <sys_link+0x112>
  ilock(dp);
    8000565a:	ffffe097          	auipc	ra,0xffffe
    8000565e:	21a080e7          	jalr	538(ra) # 80003874 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005662:	00092703          	lw	a4,0(s2)
    80005666:	409c                	lw	a5,0(s1)
    80005668:	06f71163          	bne	a4,a5,800056ca <sys_link+0x108>
    8000566c:	40d0                	lw	a2,4(s1)
    8000566e:	fd040593          	add	a1,s0,-48
    80005672:	854a                	mv	a0,s2
    80005674:	fffff097          	auipc	ra,0xfffff
    80005678:	910080e7          	jalr	-1776(ra) # 80003f84 <dirlink>
    8000567c:	04054763          	bltz	a0,800056ca <sys_link+0x108>
  iunlockput(dp);
    80005680:	854a                	mv	a0,s2
    80005682:	ffffe097          	auipc	ra,0xffffe
    80005686:	458080e7          	jalr	1112(ra) # 80003ada <iunlockput>
  iput(ip);
    8000568a:	8526                	mv	a0,s1
    8000568c:	ffffe097          	auipc	ra,0xffffe
    80005690:	3a6080e7          	jalr	934(ra) # 80003a32 <iput>
  end_op();
    80005694:	fffff097          	auipc	ra,0xfffff
    80005698:	c2c080e7          	jalr	-980(ra) # 800042c0 <end_op>
  return 0;
    8000569c:	4781                	li	a5,0
    8000569e:	64f2                	ld	s1,280(sp)
    800056a0:	6952                	ld	s2,272(sp)
    800056a2:	a0a5                	j	8000570a <sys_link+0x148>
    end_op();
    800056a4:	fffff097          	auipc	ra,0xfffff
    800056a8:	c1c080e7          	jalr	-996(ra) # 800042c0 <end_op>
    return -1;
    800056ac:	57fd                	li	a5,-1
    800056ae:	64f2                	ld	s1,280(sp)
    800056b0:	a8a9                	j	8000570a <sys_link+0x148>
    iunlockput(ip);
    800056b2:	8526                	mv	a0,s1
    800056b4:	ffffe097          	auipc	ra,0xffffe
    800056b8:	426080e7          	jalr	1062(ra) # 80003ada <iunlockput>
    end_op();
    800056bc:	fffff097          	auipc	ra,0xfffff
    800056c0:	c04080e7          	jalr	-1020(ra) # 800042c0 <end_op>
    return -1;
    800056c4:	57fd                	li	a5,-1
    800056c6:	64f2                	ld	s1,280(sp)
    800056c8:	a089                	j	8000570a <sys_link+0x148>
    iunlockput(dp);
    800056ca:	854a                	mv	a0,s2
    800056cc:	ffffe097          	auipc	ra,0xffffe
    800056d0:	40e080e7          	jalr	1038(ra) # 80003ada <iunlockput>
  ilock(ip);
    800056d4:	8526                	mv	a0,s1
    800056d6:	ffffe097          	auipc	ra,0xffffe
    800056da:	19e080e7          	jalr	414(ra) # 80003874 <ilock>
  ip->nlink--;
    800056de:	0524d783          	lhu	a5,82(s1)
    800056e2:	37fd                	addw	a5,a5,-1
    800056e4:	04f49923          	sh	a5,82(s1)
  iupdate(ip);
    800056e8:	8526                	mv	a0,s1
    800056ea:	ffffe097          	auipc	ra,0xffffe
    800056ee:	0be080e7          	jalr	190(ra) # 800037a8 <iupdate>
  iunlockput(ip);
    800056f2:	8526                	mv	a0,s1
    800056f4:	ffffe097          	auipc	ra,0xffffe
    800056f8:	3e6080e7          	jalr	998(ra) # 80003ada <iunlockput>
  end_op();
    800056fc:	fffff097          	auipc	ra,0xfffff
    80005700:	bc4080e7          	jalr	-1084(ra) # 800042c0 <end_op>
  return -1;
    80005704:	57fd                	li	a5,-1
    80005706:	64f2                	ld	s1,280(sp)
    80005708:	6952                	ld	s2,272(sp)
}
    8000570a:	853e                	mv	a0,a5
    8000570c:	70b2                	ld	ra,296(sp)
    8000570e:	7412                	ld	s0,288(sp)
    80005710:	6155                	add	sp,sp,304
    80005712:	8082                	ret

0000000080005714 <sys_unlink>:
{
    80005714:	7151                	add	sp,sp,-240
    80005716:	f586                	sd	ra,232(sp)
    80005718:	f1a2                	sd	s0,224(sp)
    8000571a:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000571c:	08000613          	li	a2,128
    80005720:	f3040593          	add	a1,s0,-208
    80005724:	4501                	li	a0,0
    80005726:	ffffd097          	auipc	ra,0xffffd
    8000572a:	620080e7          	jalr	1568(ra) # 80002d46 <argstr>
    8000572e:	1a054a63          	bltz	a0,800058e2 <sys_unlink+0x1ce>
    80005732:	eda6                	sd	s1,216(sp)
  begin_op();
    80005734:	fffff097          	auipc	ra,0xfffff
    80005738:	b12080e7          	jalr	-1262(ra) # 80004246 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000573c:	fb040593          	add	a1,s0,-80
    80005740:	f3040513          	add	a0,s0,-208
    80005744:	fffff097          	auipc	ra,0xfffff
    80005748:	920080e7          	jalr	-1760(ra) # 80004064 <nameiparent>
    8000574c:	84aa                	mv	s1,a0
    8000574e:	cd71                	beqz	a0,8000582a <sys_unlink+0x116>
  ilock(dp);
    80005750:	ffffe097          	auipc	ra,0xffffe
    80005754:	124080e7          	jalr	292(ra) # 80003874 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005758:	00003597          	auipc	a1,0x3
    8000575c:	eb858593          	add	a1,a1,-328 # 80008610 <etext+0x610>
    80005760:	fb040513          	add	a0,s0,-80
    80005764:	ffffe097          	auipc	ra,0xffffe
    80005768:	5f6080e7          	jalr	1526(ra) # 80003d5a <namecmp>
    8000576c:	14050c63          	beqz	a0,800058c4 <sys_unlink+0x1b0>
    80005770:	00003597          	auipc	a1,0x3
    80005774:	ea858593          	add	a1,a1,-344 # 80008618 <etext+0x618>
    80005778:	fb040513          	add	a0,s0,-80
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	5de080e7          	jalr	1502(ra) # 80003d5a <namecmp>
    80005784:	14050063          	beqz	a0,800058c4 <sys_unlink+0x1b0>
    80005788:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000578a:	f2c40613          	add	a2,s0,-212
    8000578e:	fb040593          	add	a1,s0,-80
    80005792:	8526                	mv	a0,s1
    80005794:	ffffe097          	auipc	ra,0xffffe
    80005798:	5e0080e7          	jalr	1504(ra) # 80003d74 <dirlookup>
    8000579c:	892a                	mv	s2,a0
    8000579e:	12050263          	beqz	a0,800058c2 <sys_unlink+0x1ae>
  ilock(ip);
    800057a2:	ffffe097          	auipc	ra,0xffffe
    800057a6:	0d2080e7          	jalr	210(ra) # 80003874 <ilock>
  if(ip->nlink < 1)
    800057aa:	05291783          	lh	a5,82(s2)
    800057ae:	08f05563          	blez	a5,80005838 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800057b2:	04c91703          	lh	a4,76(s2)
    800057b6:	4785                	li	a5,1
    800057b8:	08f70963          	beq	a4,a5,8000584a <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    800057bc:	4641                	li	a2,16
    800057be:	4581                	li	a1,0
    800057c0:	fc040513          	add	a0,s0,-64
    800057c4:	ffffb097          	auipc	ra,0xffffb
    800057c8:	56a080e7          	jalr	1386(ra) # 80000d2e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057cc:	4741                	li	a4,16
    800057ce:	f2c42683          	lw	a3,-212(s0)
    800057d2:	fc040613          	add	a2,s0,-64
    800057d6:	4581                	li	a1,0
    800057d8:	8526                	mv	a0,s1
    800057da:	ffffe097          	auipc	ra,0xffffe
    800057de:	456080e7          	jalr	1110(ra) # 80003c30 <writei>
    800057e2:	47c1                	li	a5,16
    800057e4:	0af51b63          	bne	a0,a5,8000589a <sys_unlink+0x186>
  if(ip->type == T_DIR){
    800057e8:	04c91703          	lh	a4,76(s2)
    800057ec:	4785                	li	a5,1
    800057ee:	0af70f63          	beq	a4,a5,800058ac <sys_unlink+0x198>
  iunlockput(dp);
    800057f2:	8526                	mv	a0,s1
    800057f4:	ffffe097          	auipc	ra,0xffffe
    800057f8:	2e6080e7          	jalr	742(ra) # 80003ada <iunlockput>
  ip->nlink--;
    800057fc:	05295783          	lhu	a5,82(s2)
    80005800:	37fd                	addw	a5,a5,-1
    80005802:	04f91923          	sh	a5,82(s2)
  iupdate(ip);
    80005806:	854a                	mv	a0,s2
    80005808:	ffffe097          	auipc	ra,0xffffe
    8000580c:	fa0080e7          	jalr	-96(ra) # 800037a8 <iupdate>
  iunlockput(ip);
    80005810:	854a                	mv	a0,s2
    80005812:	ffffe097          	auipc	ra,0xffffe
    80005816:	2c8080e7          	jalr	712(ra) # 80003ada <iunlockput>
  end_op();
    8000581a:	fffff097          	auipc	ra,0xfffff
    8000581e:	aa6080e7          	jalr	-1370(ra) # 800042c0 <end_op>
  return 0;
    80005822:	4501                	li	a0,0
    80005824:	64ee                	ld	s1,216(sp)
    80005826:	694e                	ld	s2,208(sp)
    80005828:	a84d                	j	800058da <sys_unlink+0x1c6>
    end_op();
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	a96080e7          	jalr	-1386(ra) # 800042c0 <end_op>
    return -1;
    80005832:	557d                	li	a0,-1
    80005834:	64ee                	ld	s1,216(sp)
    80005836:	a055                	j	800058da <sys_unlink+0x1c6>
    80005838:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000583a:	00003517          	auipc	a0,0x3
    8000583e:	e0650513          	add	a0,a0,-506 # 80008640 <etext+0x640>
    80005842:	ffffb097          	auipc	ra,0xffffb
    80005846:	d18080e7          	jalr	-744(ra) # 8000055a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000584a:	05492703          	lw	a4,84(s2)
    8000584e:	02000793          	li	a5,32
    80005852:	f6e7f5e3          	bgeu	a5,a4,800057bc <sys_unlink+0xa8>
    80005856:	e5ce                	sd	s3,200(sp)
    80005858:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000585c:	4741                	li	a4,16
    8000585e:	86ce                	mv	a3,s3
    80005860:	f1840613          	add	a2,s0,-232
    80005864:	4581                	li	a1,0
    80005866:	854a                	mv	a0,s2
    80005868:	ffffe097          	auipc	ra,0xffffe
    8000586c:	2c4080e7          	jalr	708(ra) # 80003b2c <readi>
    80005870:	47c1                	li	a5,16
    80005872:	00f51c63          	bne	a0,a5,8000588a <sys_unlink+0x176>
    if(de.inum != 0)
    80005876:	f1845783          	lhu	a5,-232(s0)
    8000587a:	e7b5                	bnez	a5,800058e6 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000587c:	29c1                	addw	s3,s3,16
    8000587e:	05492783          	lw	a5,84(s2)
    80005882:	fcf9ede3          	bltu	s3,a5,8000585c <sys_unlink+0x148>
    80005886:	69ae                	ld	s3,200(sp)
    80005888:	bf15                	j	800057bc <sys_unlink+0xa8>
      panic("isdirempty: readi");
    8000588a:	00003517          	auipc	a0,0x3
    8000588e:	dce50513          	add	a0,a0,-562 # 80008658 <etext+0x658>
    80005892:	ffffb097          	auipc	ra,0xffffb
    80005896:	cc8080e7          	jalr	-824(ra) # 8000055a <panic>
    8000589a:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000589c:	00003517          	auipc	a0,0x3
    800058a0:	dd450513          	add	a0,a0,-556 # 80008670 <etext+0x670>
    800058a4:	ffffb097          	auipc	ra,0xffffb
    800058a8:	cb6080e7          	jalr	-842(ra) # 8000055a <panic>
    dp->nlink--;
    800058ac:	0524d783          	lhu	a5,82(s1)
    800058b0:	37fd                	addw	a5,a5,-1
    800058b2:	04f49923          	sh	a5,82(s1)
    iupdate(dp);
    800058b6:	8526                	mv	a0,s1
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	ef0080e7          	jalr	-272(ra) # 800037a8 <iupdate>
    800058c0:	bf0d                	j	800057f2 <sys_unlink+0xde>
    800058c2:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800058c4:	8526                	mv	a0,s1
    800058c6:	ffffe097          	auipc	ra,0xffffe
    800058ca:	214080e7          	jalr	532(ra) # 80003ada <iunlockput>
  end_op();
    800058ce:	fffff097          	auipc	ra,0xfffff
    800058d2:	9f2080e7          	jalr	-1550(ra) # 800042c0 <end_op>
  return -1;
    800058d6:	557d                	li	a0,-1
    800058d8:	64ee                	ld	s1,216(sp)
}
    800058da:	70ae                	ld	ra,232(sp)
    800058dc:	740e                	ld	s0,224(sp)
    800058de:	616d                	add	sp,sp,240
    800058e0:	8082                	ret
    return -1;
    800058e2:	557d                	li	a0,-1
    800058e4:	bfdd                	j	800058da <sys_unlink+0x1c6>
    iunlockput(ip);
    800058e6:	854a                	mv	a0,s2
    800058e8:	ffffe097          	auipc	ra,0xffffe
    800058ec:	1f2080e7          	jalr	498(ra) # 80003ada <iunlockput>
    goto bad;
    800058f0:	694e                	ld	s2,208(sp)
    800058f2:	69ae                	ld	s3,200(sp)
    800058f4:	bfc1                	j	800058c4 <sys_unlink+0x1b0>

00000000800058f6 <sys_open>:

uint64
sys_open(void)
{
    800058f6:	7131                	add	sp,sp,-192
    800058f8:	fd06                	sd	ra,184(sp)
    800058fa:	f922                	sd	s0,176(sp)
    800058fc:	f526                	sd	s1,168(sp)
    800058fe:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005900:	08000613          	li	a2,128
    80005904:	f5040593          	add	a1,s0,-176
    80005908:	4501                	li	a0,0
    8000590a:	ffffd097          	auipc	ra,0xffffd
    8000590e:	43c080e7          	jalr	1084(ra) # 80002d46 <argstr>
    return -1;
    80005912:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005914:	0c054463          	bltz	a0,800059dc <sys_open+0xe6>
    80005918:	f4c40593          	add	a1,s0,-180
    8000591c:	4505                	li	a0,1
    8000591e:	ffffd097          	auipc	ra,0xffffd
    80005922:	3e4080e7          	jalr	996(ra) # 80002d02 <argint>
    80005926:	0a054b63          	bltz	a0,800059dc <sys_open+0xe6>
    8000592a:	f14a                	sd	s2,160(sp)

  begin_op();
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	91a080e7          	jalr	-1766(ra) # 80004246 <begin_op>

  if(omode & O_CREATE){
    80005934:	f4c42783          	lw	a5,-180(s0)
    80005938:	2007f793          	and	a5,a5,512
    8000593c:	cfc5                	beqz	a5,800059f4 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000593e:	4681                	li	a3,0
    80005940:	4601                	li	a2,0
    80005942:	4589                	li	a1,2
    80005944:	f5040513          	add	a0,s0,-176
    80005948:	00000097          	auipc	ra,0x0
    8000594c:	958080e7          	jalr	-1704(ra) # 800052a0 <create>
    80005950:	892a                	mv	s2,a0
    if(ip == 0){
    80005952:	c959                	beqz	a0,800059e8 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005954:	04c91703          	lh	a4,76(s2)
    80005958:	478d                	li	a5,3
    8000595a:	00f71763          	bne	a4,a5,80005968 <sys_open+0x72>
    8000595e:	04e95703          	lhu	a4,78(s2)
    80005962:	47a5                	li	a5,9
    80005964:	0ce7ef63          	bltu	a5,a4,80005a42 <sys_open+0x14c>
    80005968:	ed4e                	sd	s3,152(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000596a:	fffff097          	auipc	ra,0xfffff
    8000596e:	d56080e7          	jalr	-682(ra) # 800046c0 <filealloc>
    80005972:	89aa                	mv	s3,a0
    80005974:	c965                	beqz	a0,80005a64 <sys_open+0x16e>
    80005976:	00000097          	auipc	ra,0x0
    8000597a:	8e8080e7          	jalr	-1816(ra) # 8000525e <fdalloc>
    8000597e:	84aa                	mv	s1,a0
    80005980:	0c054d63          	bltz	a0,80005a5a <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005984:	04c91703          	lh	a4,76(s2)
    80005988:	478d                	li	a5,3
    8000598a:	0ef70a63          	beq	a4,a5,80005a7e <sys_open+0x188>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000598e:	4789                	li	a5,2
    80005990:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005994:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005998:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000599c:	f4c42783          	lw	a5,-180(s0)
    800059a0:	0017c713          	xor	a4,a5,1
    800059a4:	8b05                	and	a4,a4,1
    800059a6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800059aa:	0037f713          	and	a4,a5,3
    800059ae:	00e03733          	snez	a4,a4
    800059b2:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800059b6:	4007f793          	and	a5,a5,1024
    800059ba:	c791                	beqz	a5,800059c6 <sys_open+0xd0>
    800059bc:	04c91703          	lh	a4,76(s2)
    800059c0:	4789                	li	a5,2
    800059c2:	0cf70563          	beq	a4,a5,80005a8c <sys_open+0x196>
    itrunc(ip);
  }

  iunlock(ip);
    800059c6:	854a                	mv	a0,s2
    800059c8:	ffffe097          	auipc	ra,0xffffe
    800059cc:	f72080e7          	jalr	-142(ra) # 8000393a <iunlock>
  end_op();
    800059d0:	fffff097          	auipc	ra,0xfffff
    800059d4:	8f0080e7          	jalr	-1808(ra) # 800042c0 <end_op>
    800059d8:	790a                	ld	s2,160(sp)
    800059da:	69ea                	ld	s3,152(sp)

  return fd;
}
    800059dc:	8526                	mv	a0,s1
    800059de:	70ea                	ld	ra,184(sp)
    800059e0:	744a                	ld	s0,176(sp)
    800059e2:	74aa                	ld	s1,168(sp)
    800059e4:	6129                	add	sp,sp,192
    800059e6:	8082                	ret
      end_op();
    800059e8:	fffff097          	auipc	ra,0xfffff
    800059ec:	8d8080e7          	jalr	-1832(ra) # 800042c0 <end_op>
      return -1;
    800059f0:	790a                	ld	s2,160(sp)
    800059f2:	b7ed                	j	800059dc <sys_open+0xe6>
    if((ip = namei(path)) == 0){
    800059f4:	f5040513          	add	a0,s0,-176
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	64e080e7          	jalr	1614(ra) # 80004046 <namei>
    80005a00:	892a                	mv	s2,a0
    80005a02:	c90d                	beqz	a0,80005a34 <sys_open+0x13e>
    ilock(ip);
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	e70080e7          	jalr	-400(ra) # 80003874 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005a0c:	04c91703          	lh	a4,76(s2)
    80005a10:	4785                	li	a5,1
    80005a12:	f4f711e3          	bne	a4,a5,80005954 <sys_open+0x5e>
    80005a16:	f4c42783          	lw	a5,-180(s0)
    80005a1a:	d7b9                	beqz	a5,80005968 <sys_open+0x72>
      iunlockput(ip);
    80005a1c:	854a                	mv	a0,s2
    80005a1e:	ffffe097          	auipc	ra,0xffffe
    80005a22:	0bc080e7          	jalr	188(ra) # 80003ada <iunlockput>
      end_op();
    80005a26:	fffff097          	auipc	ra,0xfffff
    80005a2a:	89a080e7          	jalr	-1894(ra) # 800042c0 <end_op>
      return -1;
    80005a2e:	54fd                	li	s1,-1
    80005a30:	790a                	ld	s2,160(sp)
    80005a32:	b76d                	j	800059dc <sys_open+0xe6>
      end_op();
    80005a34:	fffff097          	auipc	ra,0xfffff
    80005a38:	88c080e7          	jalr	-1908(ra) # 800042c0 <end_op>
      return -1;
    80005a3c:	54fd                	li	s1,-1
    80005a3e:	790a                	ld	s2,160(sp)
    80005a40:	bf71                	j	800059dc <sys_open+0xe6>
    iunlockput(ip);
    80005a42:	854a                	mv	a0,s2
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	096080e7          	jalr	150(ra) # 80003ada <iunlockput>
    end_op();
    80005a4c:	fffff097          	auipc	ra,0xfffff
    80005a50:	874080e7          	jalr	-1932(ra) # 800042c0 <end_op>
    return -1;
    80005a54:	54fd                	li	s1,-1
    80005a56:	790a                	ld	s2,160(sp)
    80005a58:	b751                	j	800059dc <sys_open+0xe6>
      fileclose(f);
    80005a5a:	854e                	mv	a0,s3
    80005a5c:	fffff097          	auipc	ra,0xfffff
    80005a60:	d20080e7          	jalr	-736(ra) # 8000477c <fileclose>
    iunlockput(ip);
    80005a64:	854a                	mv	a0,s2
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	074080e7          	jalr	116(ra) # 80003ada <iunlockput>
    end_op();
    80005a6e:	fffff097          	auipc	ra,0xfffff
    80005a72:	852080e7          	jalr	-1966(ra) # 800042c0 <end_op>
    return -1;
    80005a76:	54fd                	li	s1,-1
    80005a78:	790a                	ld	s2,160(sp)
    80005a7a:	69ea                	ld	s3,152(sp)
    80005a7c:	b785                	j	800059dc <sys_open+0xe6>
    f->type = FD_DEVICE;
    80005a7e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a82:	04e91783          	lh	a5,78(s2)
    80005a86:	02f99223          	sh	a5,36(s3)
    80005a8a:	b739                	j	80005998 <sys_open+0xa2>
    itrunc(ip);
    80005a8c:	854a                	mv	a0,s2
    80005a8e:	ffffe097          	auipc	ra,0xffffe
    80005a92:	ef8080e7          	jalr	-264(ra) # 80003986 <itrunc>
    80005a96:	bf05                	j	800059c6 <sys_open+0xd0>

0000000080005a98 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a98:	7175                	add	sp,sp,-144
    80005a9a:	e506                	sd	ra,136(sp)
    80005a9c:	e122                	sd	s0,128(sp)
    80005a9e:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005aa0:	ffffe097          	auipc	ra,0xffffe
    80005aa4:	7a6080e7          	jalr	1958(ra) # 80004246 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005aa8:	08000613          	li	a2,128
    80005aac:	f7040593          	add	a1,s0,-144
    80005ab0:	4501                	li	a0,0
    80005ab2:	ffffd097          	auipc	ra,0xffffd
    80005ab6:	294080e7          	jalr	660(ra) # 80002d46 <argstr>
    80005aba:	02054963          	bltz	a0,80005aec <sys_mkdir+0x54>
    80005abe:	4681                	li	a3,0
    80005ac0:	4601                	li	a2,0
    80005ac2:	4585                	li	a1,1
    80005ac4:	f7040513          	add	a0,s0,-144
    80005ac8:	fffff097          	auipc	ra,0xfffff
    80005acc:	7d8080e7          	jalr	2008(ra) # 800052a0 <create>
    80005ad0:	cd11                	beqz	a0,80005aec <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ad2:	ffffe097          	auipc	ra,0xffffe
    80005ad6:	008080e7          	jalr	8(ra) # 80003ada <iunlockput>
  end_op();
    80005ada:	ffffe097          	auipc	ra,0xffffe
    80005ade:	7e6080e7          	jalr	2022(ra) # 800042c0 <end_op>
  return 0;
    80005ae2:	4501                	li	a0,0
}
    80005ae4:	60aa                	ld	ra,136(sp)
    80005ae6:	640a                	ld	s0,128(sp)
    80005ae8:	6149                	add	sp,sp,144
    80005aea:	8082                	ret
    end_op();
    80005aec:	ffffe097          	auipc	ra,0xffffe
    80005af0:	7d4080e7          	jalr	2004(ra) # 800042c0 <end_op>
    return -1;
    80005af4:	557d                	li	a0,-1
    80005af6:	b7fd                	j	80005ae4 <sys_mkdir+0x4c>

0000000080005af8 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005af8:	7135                	add	sp,sp,-160
    80005afa:	ed06                	sd	ra,152(sp)
    80005afc:	e922                	sd	s0,144(sp)
    80005afe:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005b00:	ffffe097          	auipc	ra,0xffffe
    80005b04:	746080e7          	jalr	1862(ra) # 80004246 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b08:	08000613          	li	a2,128
    80005b0c:	f7040593          	add	a1,s0,-144
    80005b10:	4501                	li	a0,0
    80005b12:	ffffd097          	auipc	ra,0xffffd
    80005b16:	234080e7          	jalr	564(ra) # 80002d46 <argstr>
    80005b1a:	04054a63          	bltz	a0,80005b6e <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005b1e:	f6c40593          	add	a1,s0,-148
    80005b22:	4505                	li	a0,1
    80005b24:	ffffd097          	auipc	ra,0xffffd
    80005b28:	1de080e7          	jalr	478(ra) # 80002d02 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b2c:	04054163          	bltz	a0,80005b6e <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005b30:	f6840593          	add	a1,s0,-152
    80005b34:	4509                	li	a0,2
    80005b36:	ffffd097          	auipc	ra,0xffffd
    80005b3a:	1cc080e7          	jalr	460(ra) # 80002d02 <argint>
     argint(1, &major) < 0 ||
    80005b3e:	02054863          	bltz	a0,80005b6e <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b42:	f6841683          	lh	a3,-152(s0)
    80005b46:	f6c41603          	lh	a2,-148(s0)
    80005b4a:	458d                	li	a1,3
    80005b4c:	f7040513          	add	a0,s0,-144
    80005b50:	fffff097          	auipc	ra,0xfffff
    80005b54:	750080e7          	jalr	1872(ra) # 800052a0 <create>
     argint(2, &minor) < 0 ||
    80005b58:	c919                	beqz	a0,80005b6e <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b5a:	ffffe097          	auipc	ra,0xffffe
    80005b5e:	f80080e7          	jalr	-128(ra) # 80003ada <iunlockput>
  end_op();
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	75e080e7          	jalr	1886(ra) # 800042c0 <end_op>
  return 0;
    80005b6a:	4501                	li	a0,0
    80005b6c:	a031                	j	80005b78 <sys_mknod+0x80>
    end_op();
    80005b6e:	ffffe097          	auipc	ra,0xffffe
    80005b72:	752080e7          	jalr	1874(ra) # 800042c0 <end_op>
    return -1;
    80005b76:	557d                	li	a0,-1
}
    80005b78:	60ea                	ld	ra,152(sp)
    80005b7a:	644a                	ld	s0,144(sp)
    80005b7c:	610d                	add	sp,sp,160
    80005b7e:	8082                	ret

0000000080005b80 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b80:	7135                	add	sp,sp,-160
    80005b82:	ed06                	sd	ra,152(sp)
    80005b84:	e922                	sd	s0,144(sp)
    80005b86:	e14a                	sd	s2,128(sp)
    80005b88:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b8a:	ffffc097          	auipc	ra,0xffffc
    80005b8e:	ea6080e7          	jalr	-346(ra) # 80001a30 <myproc>
    80005b92:	892a                	mv	s2,a0
  
  begin_op();
    80005b94:	ffffe097          	auipc	ra,0xffffe
    80005b98:	6b2080e7          	jalr	1714(ra) # 80004246 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b9c:	08000613          	li	a2,128
    80005ba0:	f6040593          	add	a1,s0,-160
    80005ba4:	4501                	li	a0,0
    80005ba6:	ffffd097          	auipc	ra,0xffffd
    80005baa:	1a0080e7          	jalr	416(ra) # 80002d46 <argstr>
    80005bae:	04054d63          	bltz	a0,80005c08 <sys_chdir+0x88>
    80005bb2:	e526                	sd	s1,136(sp)
    80005bb4:	f6040513          	add	a0,s0,-160
    80005bb8:	ffffe097          	auipc	ra,0xffffe
    80005bbc:	48e080e7          	jalr	1166(ra) # 80004046 <namei>
    80005bc0:	84aa                	mv	s1,a0
    80005bc2:	c131                	beqz	a0,80005c06 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005bc4:	ffffe097          	auipc	ra,0xffffe
    80005bc8:	cb0080e7          	jalr	-848(ra) # 80003874 <ilock>
  if(ip->type != T_DIR){
    80005bcc:	04c49703          	lh	a4,76(s1)
    80005bd0:	4785                	li	a5,1
    80005bd2:	04f71163          	bne	a4,a5,80005c14 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005bd6:	8526                	mv	a0,s1
    80005bd8:	ffffe097          	auipc	ra,0xffffe
    80005bdc:	d62080e7          	jalr	-670(ra) # 8000393a <iunlock>
  iput(p->cwd);
    80005be0:	15093503          	ld	a0,336(s2)
    80005be4:	ffffe097          	auipc	ra,0xffffe
    80005be8:	e4e080e7          	jalr	-434(ra) # 80003a32 <iput>
  end_op();
    80005bec:	ffffe097          	auipc	ra,0xffffe
    80005bf0:	6d4080e7          	jalr	1748(ra) # 800042c0 <end_op>
  p->cwd = ip;
    80005bf4:	14993823          	sd	s1,336(s2)
  return 0;
    80005bf8:	4501                	li	a0,0
    80005bfa:	64aa                	ld	s1,136(sp)
}
    80005bfc:	60ea                	ld	ra,152(sp)
    80005bfe:	644a                	ld	s0,144(sp)
    80005c00:	690a                	ld	s2,128(sp)
    80005c02:	610d                	add	sp,sp,160
    80005c04:	8082                	ret
    80005c06:	64aa                	ld	s1,136(sp)
    end_op();
    80005c08:	ffffe097          	auipc	ra,0xffffe
    80005c0c:	6b8080e7          	jalr	1720(ra) # 800042c0 <end_op>
    return -1;
    80005c10:	557d                	li	a0,-1
    80005c12:	b7ed                	j	80005bfc <sys_chdir+0x7c>
    iunlockput(ip);
    80005c14:	8526                	mv	a0,s1
    80005c16:	ffffe097          	auipc	ra,0xffffe
    80005c1a:	ec4080e7          	jalr	-316(ra) # 80003ada <iunlockput>
    end_op();
    80005c1e:	ffffe097          	auipc	ra,0xffffe
    80005c22:	6a2080e7          	jalr	1698(ra) # 800042c0 <end_op>
    return -1;
    80005c26:	557d                	li	a0,-1
    80005c28:	64aa                	ld	s1,136(sp)
    80005c2a:	bfc9                	j	80005bfc <sys_chdir+0x7c>

0000000080005c2c <sys_exec>:

uint64
sys_exec(void)
{
    80005c2c:	7121                	add	sp,sp,-448
    80005c2e:	ff06                	sd	ra,440(sp)
    80005c30:	fb22                	sd	s0,432(sp)
    80005c32:	f34a                	sd	s2,416(sp)
    80005c34:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c36:	08000613          	li	a2,128
    80005c3a:	f5040593          	add	a1,s0,-176
    80005c3e:	4501                	li	a0,0
    80005c40:	ffffd097          	auipc	ra,0xffffd
    80005c44:	106080e7          	jalr	262(ra) # 80002d46 <argstr>
    return -1;
    80005c48:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005c4a:	0e054a63          	bltz	a0,80005d3e <sys_exec+0x112>
    80005c4e:	e4840593          	add	a1,s0,-440
    80005c52:	4505                	li	a0,1
    80005c54:	ffffd097          	auipc	ra,0xffffd
    80005c58:	0d0080e7          	jalr	208(ra) # 80002d24 <argaddr>
    80005c5c:	0e054163          	bltz	a0,80005d3e <sys_exec+0x112>
    80005c60:	f726                	sd	s1,424(sp)
    80005c62:	ef4e                	sd	s3,408(sp)
    80005c64:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005c66:	10000613          	li	a2,256
    80005c6a:	4581                	li	a1,0
    80005c6c:	e5040513          	add	a0,s0,-432
    80005c70:	ffffb097          	auipc	ra,0xffffb
    80005c74:	0be080e7          	jalr	190(ra) # 80000d2e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c78:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005c7c:	89a6                	mv	s3,s1
    80005c7e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c80:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c84:	00391513          	sll	a0,s2,0x3
    80005c88:	e4040593          	add	a1,s0,-448
    80005c8c:	e4843783          	ld	a5,-440(s0)
    80005c90:	953e                	add	a0,a0,a5
    80005c92:	ffffd097          	auipc	ra,0xffffd
    80005c96:	fd6080e7          	jalr	-42(ra) # 80002c68 <fetchaddr>
    80005c9a:	02054a63          	bltz	a0,80005cce <sys_exec+0xa2>
      goto bad;
    }
    if(uarg == 0){
    80005c9e:	e4043783          	ld	a5,-448(s0)
    80005ca2:	c7b1                	beqz	a5,80005cee <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ca4:	ffffb097          	auipc	ra,0xffffb
    80005ca8:	e9e080e7          	jalr	-354(ra) # 80000b42 <kalloc>
    80005cac:	85aa                	mv	a1,a0
    80005cae:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005cb2:	cd11                	beqz	a0,80005cce <sys_exec+0xa2>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005cb4:	6605                	lui	a2,0x1
    80005cb6:	e4043503          	ld	a0,-448(s0)
    80005cba:	ffffd097          	auipc	ra,0xffffd
    80005cbe:	000080e7          	jalr	ra # 80002cba <fetchstr>
    80005cc2:	00054663          	bltz	a0,80005cce <sys_exec+0xa2>
    if(i >= NELEM(argv)){
    80005cc6:	0905                	add	s2,s2,1
    80005cc8:	09a1                	add	s3,s3,8
    80005cca:	fb491de3          	bne	s2,s4,80005c84 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cce:	f5040913          	add	s2,s0,-176
    80005cd2:	6088                	ld	a0,0(s1)
    80005cd4:	c12d                	beqz	a0,80005d36 <sys_exec+0x10a>
    kfree(argv[i]);
    80005cd6:	ffffb097          	auipc	ra,0xffffb
    80005cda:	d6e080e7          	jalr	-658(ra) # 80000a44 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cde:	04a1                	add	s1,s1,8
    80005ce0:	ff2499e3          	bne	s1,s2,80005cd2 <sys_exec+0xa6>
  return -1;
    80005ce4:	597d                	li	s2,-1
    80005ce6:	74ba                	ld	s1,424(sp)
    80005ce8:	69fa                	ld	s3,408(sp)
    80005cea:	6a5a                	ld	s4,400(sp)
    80005cec:	a889                	j	80005d3e <sys_exec+0x112>
      argv[i] = 0;
    80005cee:	0009079b          	sext.w	a5,s2
    80005cf2:	078e                	sll	a5,a5,0x3
    80005cf4:	fd078793          	add	a5,a5,-48
    80005cf8:	97a2                	add	a5,a5,s0
    80005cfa:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005cfe:	e5040593          	add	a1,s0,-432
    80005d02:	f5040513          	add	a0,s0,-176
    80005d06:	fffff097          	auipc	ra,0xfffff
    80005d0a:	126080e7          	jalr	294(ra) # 80004e2c <exec>
    80005d0e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d10:	f5040993          	add	s3,s0,-176
    80005d14:	6088                	ld	a0,0(s1)
    80005d16:	cd01                	beqz	a0,80005d2e <sys_exec+0x102>
    kfree(argv[i]);
    80005d18:	ffffb097          	auipc	ra,0xffffb
    80005d1c:	d2c080e7          	jalr	-724(ra) # 80000a44 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005d20:	04a1                	add	s1,s1,8
    80005d22:	ff3499e3          	bne	s1,s3,80005d14 <sys_exec+0xe8>
    80005d26:	74ba                	ld	s1,424(sp)
    80005d28:	69fa                	ld	s3,408(sp)
    80005d2a:	6a5a                	ld	s4,400(sp)
    80005d2c:	a809                	j	80005d3e <sys_exec+0x112>
  return ret;
    80005d2e:	74ba                	ld	s1,424(sp)
    80005d30:	69fa                	ld	s3,408(sp)
    80005d32:	6a5a                	ld	s4,400(sp)
    80005d34:	a029                	j	80005d3e <sys_exec+0x112>
  return -1;
    80005d36:	597d                	li	s2,-1
    80005d38:	74ba                	ld	s1,424(sp)
    80005d3a:	69fa                	ld	s3,408(sp)
    80005d3c:	6a5a                	ld	s4,400(sp)
}
    80005d3e:	854a                	mv	a0,s2
    80005d40:	70fa                	ld	ra,440(sp)
    80005d42:	745a                	ld	s0,432(sp)
    80005d44:	791a                	ld	s2,416(sp)
    80005d46:	6139                	add	sp,sp,448
    80005d48:	8082                	ret

0000000080005d4a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005d4a:	7139                	add	sp,sp,-64
    80005d4c:	fc06                	sd	ra,56(sp)
    80005d4e:	f822                	sd	s0,48(sp)
    80005d50:	f426                	sd	s1,40(sp)
    80005d52:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d54:	ffffc097          	auipc	ra,0xffffc
    80005d58:	cdc080e7          	jalr	-804(ra) # 80001a30 <myproc>
    80005d5c:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005d5e:	fd840593          	add	a1,s0,-40
    80005d62:	4501                	li	a0,0
    80005d64:	ffffd097          	auipc	ra,0xffffd
    80005d68:	fc0080e7          	jalr	-64(ra) # 80002d24 <argaddr>
    return -1;
    80005d6c:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d6e:	0e054063          	bltz	a0,80005e4e <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d72:	fc840593          	add	a1,s0,-56
    80005d76:	fd040513          	add	a0,s0,-48
    80005d7a:	fffff097          	auipc	ra,0xfffff
    80005d7e:	d70080e7          	jalr	-656(ra) # 80004aea <pipealloc>
    return -1;
    80005d82:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d84:	0c054563          	bltz	a0,80005e4e <sys_pipe+0x104>
  fd0 = -1;
    80005d88:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d8c:	fd043503          	ld	a0,-48(s0)
    80005d90:	fffff097          	auipc	ra,0xfffff
    80005d94:	4ce080e7          	jalr	1230(ra) # 8000525e <fdalloc>
    80005d98:	fca42223          	sw	a0,-60(s0)
    80005d9c:	08054c63          	bltz	a0,80005e34 <sys_pipe+0xea>
    80005da0:	fc843503          	ld	a0,-56(s0)
    80005da4:	fffff097          	auipc	ra,0xfffff
    80005da8:	4ba080e7          	jalr	1210(ra) # 8000525e <fdalloc>
    80005dac:	fca42023          	sw	a0,-64(s0)
    80005db0:	06054963          	bltz	a0,80005e22 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005db4:	4691                	li	a3,4
    80005db6:	fc440613          	add	a2,s0,-60
    80005dba:	fd843583          	ld	a1,-40(s0)
    80005dbe:	68a8                	ld	a0,80(s1)
    80005dc0:	ffffc097          	auipc	ra,0xffffc
    80005dc4:	90c080e7          	jalr	-1780(ra) # 800016cc <copyout>
    80005dc8:	02054063          	bltz	a0,80005de8 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005dcc:	4691                	li	a3,4
    80005dce:	fc040613          	add	a2,s0,-64
    80005dd2:	fd843583          	ld	a1,-40(s0)
    80005dd6:	0591                	add	a1,a1,4
    80005dd8:	68a8                	ld	a0,80(s1)
    80005dda:	ffffc097          	auipc	ra,0xffffc
    80005dde:	8f2080e7          	jalr	-1806(ra) # 800016cc <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005de2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005de4:	06055563          	bgez	a0,80005e4e <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005de8:	fc442783          	lw	a5,-60(s0)
    80005dec:	07e9                	add	a5,a5,26
    80005dee:	078e                	sll	a5,a5,0x3
    80005df0:	97a6                	add	a5,a5,s1
    80005df2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005df6:	fc042783          	lw	a5,-64(s0)
    80005dfa:	07e9                	add	a5,a5,26
    80005dfc:	078e                	sll	a5,a5,0x3
    80005dfe:	00f48533          	add	a0,s1,a5
    80005e02:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005e06:	fd043503          	ld	a0,-48(s0)
    80005e0a:	fffff097          	auipc	ra,0xfffff
    80005e0e:	972080e7          	jalr	-1678(ra) # 8000477c <fileclose>
    fileclose(wf);
    80005e12:	fc843503          	ld	a0,-56(s0)
    80005e16:	fffff097          	auipc	ra,0xfffff
    80005e1a:	966080e7          	jalr	-1690(ra) # 8000477c <fileclose>
    return -1;
    80005e1e:	57fd                	li	a5,-1
    80005e20:	a03d                	j	80005e4e <sys_pipe+0x104>
    if(fd0 >= 0)
    80005e22:	fc442783          	lw	a5,-60(s0)
    80005e26:	0007c763          	bltz	a5,80005e34 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005e2a:	07e9                	add	a5,a5,26
    80005e2c:	078e                	sll	a5,a5,0x3
    80005e2e:	97a6                	add	a5,a5,s1
    80005e30:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005e34:	fd043503          	ld	a0,-48(s0)
    80005e38:	fffff097          	auipc	ra,0xfffff
    80005e3c:	944080e7          	jalr	-1724(ra) # 8000477c <fileclose>
    fileclose(wf);
    80005e40:	fc843503          	ld	a0,-56(s0)
    80005e44:	fffff097          	auipc	ra,0xfffff
    80005e48:	938080e7          	jalr	-1736(ra) # 8000477c <fileclose>
    return -1;
    80005e4c:	57fd                	li	a5,-1
}
    80005e4e:	853e                	mv	a0,a5
    80005e50:	70e2                	ld	ra,56(sp)
    80005e52:	7442                	ld	s0,48(sp)
    80005e54:	74a2                	ld	s1,40(sp)
    80005e56:	6121                	add	sp,sp,64
    80005e58:	8082                	ret

0000000080005e5a <sys_testlock>:

// Lab 9
uint64
sys_testlock(void)
{
    80005e5a:	1141                	add	sp,sp,-16
    80005e5c:	e406                	sd	ra,8(sp)
    80005e5e:	e022                	sd	s0,0(sp)
    80005e60:	0800                	add	s0,sp,16
static struct sleeplock lk;
if(holdingsleep(&lk))
    80005e62:	0001d517          	auipc	a0,0x1d
    80005e66:	99650513          	add	a0,a0,-1642 # 800227f8 <lk.2>
    80005e6a:	ffffe097          	auipc	ra,0xffffe
    80005e6e:	6d2080e7          	jalr	1746(ra) # 8000453c <holdingsleep>
    80005e72:	cd11                	beqz	a0,80005e8e <sys_testlock+0x34>
releasesleep(&lk);
    80005e74:	0001d517          	auipc	a0,0x1d
    80005e78:	98450513          	add	a0,a0,-1660 # 800227f8 <lk.2>
    80005e7c:	ffffe097          	auipc	ra,0xffffe
    80005e80:	7a2080e7          	jalr	1954(ra) # 8000461e <releasesleep>
else
acquiresleep(&lk);
return 0;
}
    80005e84:	4501                	li	a0,0
    80005e86:	60a2                	ld	ra,8(sp)
    80005e88:	6402                	ld	s0,0(sp)
    80005e8a:	0141                	add	sp,sp,16
    80005e8c:	8082                	ret
acquiresleep(&lk);
    80005e8e:	0001d517          	auipc	a0,0x1d
    80005e92:	96a50513          	add	a0,a0,-1686 # 800227f8 <lk.2>
    80005e96:	ffffe097          	auipc	ra,0xffffe
    80005e9a:	6fc080e7          	jalr	1788(ra) # 80004592 <acquiresleep>
    80005e9e:	b7dd                	j	80005e84 <sys_testlock+0x2a>

0000000080005ea0 <sys_sematest>:

// Lab 9
int
sys_sematest(void)
{
    80005ea0:	1101                	add	sp,sp,-32
    80005ea2:	ec06                	sd	ra,24(sp)
    80005ea4:	e822                	sd	s0,16(sp)
    80005ea6:	1000                	add	s0,sp,32
static struct semaphore lk;
int cmd, ret = 0;
if (argint(0, &cmd) < 0)
    80005ea8:	fec40593          	add	a1,s0,-20
    80005eac:	4501                	li	a0,0
    80005eae:	ffffd097          	auipc	ra,0xffffd
    80005eb2:	e54080e7          	jalr	-428(ra) # 80002d02 <argint>
    80005eb6:	04054c63          	bltz	a0,80005f0e <sys_sematest+0x6e>
return -1;
switch (cmd) {
    80005eba:	fec42783          	lw	a5,-20(s0)
    80005ebe:	4705                	li	a4,1
    80005ec0:	02e78563          	beq	a5,a4,80005eea <sys_sematest+0x4a>
    80005ec4:	4709                	li	a4,2
    80005ec6:	02e78b63          	beq	a5,a4,80005efc <sys_sematest+0x5c>
    80005eca:	4501                	li	a0,0
    80005ecc:	eb99                	bnez	a5,80005ee2 <sys_sematest+0x42>
case 0: initsema(&lk, 5); ret = 5; break;
    80005ece:	4595                	li	a1,5
    80005ed0:	0001d517          	auipc	a0,0x1d
    80005ed4:	96050513          	add	a0,a0,-1696 # 80022830 <lk.1>
    80005ed8:	ffffc097          	auipc	ra,0xffffc
    80005edc:	788080e7          	jalr	1928(ra) # 80002660 <initsema>
    80005ee0:	4515                	li	a0,5
case 1: ret = downsema(&lk); break;
case 2: ret = upsema(&lk); break;
}
return ret;
}
    80005ee2:	60e2                	ld	ra,24(sp)
    80005ee4:	6442                	ld	s0,16(sp)
    80005ee6:	6105                	add	sp,sp,32
    80005ee8:	8082                	ret
case 1: ret = downsema(&lk); break;
    80005eea:	0001d517          	auipc	a0,0x1d
    80005eee:	94650513          	add	a0,a0,-1722 # 80022830 <lk.1>
    80005ef2:	ffffc097          	auipc	ra,0xffffc
    80005ef6:	792080e7          	jalr	1938(ra) # 80002684 <downsema>
    80005efa:	b7e5                	j	80005ee2 <sys_sematest+0x42>
case 2: ret = upsema(&lk); break;
    80005efc:	0001d517          	auipc	a0,0x1d
    80005f00:	93450513          	add	a0,a0,-1740 # 80022830 <lk.1>
    80005f04:	ffffc097          	auipc	ra,0xffffc
    80005f08:	7d0080e7          	jalr	2000(ra) # 800026d4 <upsema>
    80005f0c:	bfd9                	j	80005ee2 <sys_sematest+0x42>
return -1;
    80005f0e:	557d                	li	a0,-1
    80005f10:	bfc9                	j	80005ee2 <sys_sematest+0x42>

0000000080005f12 <sys_rwsematest>:

int
sys_rwsematest(void)
{
    80005f12:	7179                	add	sp,sp,-48
    80005f14:	f406                	sd	ra,40(sp)
    80005f16:	f022                	sd	s0,32(sp)
    80005f18:	ec26                	sd	s1,24(sp)
    80005f1a:	1800                	add	s0,sp,48
  static struct rwsemaphore lk;
  int cmd, ret = 0;

  if(argint(0, &cmd) < 0)
    80005f1c:	fdc40593          	add	a1,s0,-36
    80005f20:	4501                	li	a0,0
    80005f22:	ffffd097          	auipc	ra,0xffffd
    80005f26:	de0080e7          	jalr	-544(ra) # 80002d02 <argint>
    80005f2a:	08054763          	bltz	a0,80005fb8 <sys_rwsematest+0xa6>
	return -1;

  switch(cmd) {
    80005f2e:	fdc42483          	lw	s1,-36(s0)
    80005f32:	4791                	li	a5,4
    80005f34:	0897e463          	bltu	a5,s1,80005fbc <sys_rwsematest+0xaa>
    80005f38:	00249793          	sll	a5,s1,0x2
    80005f3c:	00003717          	auipc	a4,0x3
    80005f40:	91470713          	add	a4,a4,-1772 # 80008850 <syscalls+0xc8>
    80005f44:	97ba                	add	a5,a5,a4
    80005f46:	439c                	lw	a5,0(a5)
    80005f48:	97ba                	add	a5,a5,a4
    80005f4a:	8782                	jr	a5
	case 0: initrwsema(&lk); break;
    80005f4c:	0001d517          	auipc	a0,0x1d
    80005f50:	90450513          	add	a0,a0,-1788 # 80022850 <lk.0>
    80005f54:	ffffc097          	auipc	ra,0xffffc
    80005f58:	7c4080e7          	jalr	1988(ra) # 80002718 <initrwsema>
	case 2: ret = upreadsema(&lk); break;
	case 3: downwritesema(&lk); break;
	case 4: upwritesema(&lk); break;
  }
  return ret;
}
    80005f5c:	8526                	mv	a0,s1
    80005f5e:	70a2                	ld	ra,40(sp)
    80005f60:	7402                	ld	s0,32(sp)
    80005f62:	64e2                	ld	s1,24(sp)
    80005f64:	6145                	add	sp,sp,48
    80005f66:	8082                	ret
	case 1: ret = downreadsema(&lk); break;
    80005f68:	0001d517          	auipc	a0,0x1d
    80005f6c:	8e850513          	add	a0,a0,-1816 # 80022850 <lk.0>
    80005f70:	ffffc097          	auipc	ra,0xffffc
    80005f74:	7d2080e7          	jalr	2002(ra) # 80002742 <downreadsema>
    80005f78:	84aa                	mv	s1,a0
    80005f7a:	b7cd                	j	80005f5c <sys_rwsematest+0x4a>
	case 2: ret = upreadsema(&lk); break;
    80005f7c:	0001d517          	auipc	a0,0x1d
    80005f80:	8d450513          	add	a0,a0,-1836 # 80022850 <lk.0>
    80005f84:	ffffd097          	auipc	ra,0xffffd
    80005f88:	810080e7          	jalr	-2032(ra) # 80002794 <upreadsema>
    80005f8c:	84aa                	mv	s1,a0
    80005f8e:	b7f9                	j	80005f5c <sys_rwsematest+0x4a>
	case 3: downwritesema(&lk); break;
    80005f90:	0001d517          	auipc	a0,0x1d
    80005f94:	8c050513          	add	a0,a0,-1856 # 80022850 <lk.0>
    80005f98:	ffffd097          	auipc	ra,0xffffd
    80005f9c:	848080e7          	jalr	-1976(ra) # 800027e0 <downwritesema>
  int cmd, ret = 0;
    80005fa0:	4481                	li	s1,0
	case 3: downwritesema(&lk); break;
    80005fa2:	bf6d                	j	80005f5c <sys_rwsematest+0x4a>
	case 4: upwritesema(&lk); break;
    80005fa4:	0001d517          	auipc	a0,0x1d
    80005fa8:	8ac50513          	add	a0,a0,-1876 # 80022850 <lk.0>
    80005fac:	ffffd097          	auipc	ra,0xffffd
    80005fb0:	884080e7          	jalr	-1916(ra) # 80002830 <upwritesema>
  int cmd, ret = 0;
    80005fb4:	4481                	li	s1,0
	case 4: upwritesema(&lk); break;
    80005fb6:	b75d                	j	80005f5c <sys_rwsematest+0x4a>
	return -1;
    80005fb8:	54fd                	li	s1,-1
    80005fba:	b74d                	j	80005f5c <sys_rwsematest+0x4a>
  switch(cmd) {
    80005fbc:	4481                	li	s1,0
    80005fbe:	bf79                	j	80005f5c <sys_rwsematest+0x4a>

0000000080005fc0 <kernelvec>:
    80005fc0:	7111                	add	sp,sp,-256
    80005fc2:	e006                	sd	ra,0(sp)
    80005fc4:	e40a                	sd	sp,8(sp)
    80005fc6:	e80e                	sd	gp,16(sp)
    80005fc8:	ec12                	sd	tp,24(sp)
    80005fca:	f016                	sd	t0,32(sp)
    80005fcc:	f41a                	sd	t1,40(sp)
    80005fce:	f81e                	sd	t2,48(sp)
    80005fd0:	fc22                	sd	s0,56(sp)
    80005fd2:	e0a6                	sd	s1,64(sp)
    80005fd4:	e4aa                	sd	a0,72(sp)
    80005fd6:	e8ae                	sd	a1,80(sp)
    80005fd8:	ecb2                	sd	a2,88(sp)
    80005fda:	f0b6                	sd	a3,96(sp)
    80005fdc:	f4ba                	sd	a4,104(sp)
    80005fde:	f8be                	sd	a5,112(sp)
    80005fe0:	fcc2                	sd	a6,120(sp)
    80005fe2:	e146                	sd	a7,128(sp)
    80005fe4:	e54a                	sd	s2,136(sp)
    80005fe6:	e94e                	sd	s3,144(sp)
    80005fe8:	ed52                	sd	s4,152(sp)
    80005fea:	f156                	sd	s5,160(sp)
    80005fec:	f55a                	sd	s6,168(sp)
    80005fee:	f95e                	sd	s7,176(sp)
    80005ff0:	fd62                	sd	s8,184(sp)
    80005ff2:	e1e6                	sd	s9,192(sp)
    80005ff4:	e5ea                	sd	s10,200(sp)
    80005ff6:	e9ee                	sd	s11,208(sp)
    80005ff8:	edf2                	sd	t3,216(sp)
    80005ffa:	f1f6                	sd	t4,224(sp)
    80005ffc:	f5fa                	sd	t5,232(sp)
    80005ffe:	f9fe                	sd	t6,240(sp)
    80006000:	b35fc0ef          	jal	80002b34 <kerneltrap>
    80006004:	6082                	ld	ra,0(sp)
    80006006:	6122                	ld	sp,8(sp)
    80006008:	61c2                	ld	gp,16(sp)
    8000600a:	7282                	ld	t0,32(sp)
    8000600c:	7322                	ld	t1,40(sp)
    8000600e:	73c2                	ld	t2,48(sp)
    80006010:	7462                	ld	s0,56(sp)
    80006012:	6486                	ld	s1,64(sp)
    80006014:	6526                	ld	a0,72(sp)
    80006016:	65c6                	ld	a1,80(sp)
    80006018:	6666                	ld	a2,88(sp)
    8000601a:	7686                	ld	a3,96(sp)
    8000601c:	7726                	ld	a4,104(sp)
    8000601e:	77c6                	ld	a5,112(sp)
    80006020:	7866                	ld	a6,120(sp)
    80006022:	688a                	ld	a7,128(sp)
    80006024:	692a                	ld	s2,136(sp)
    80006026:	69ca                	ld	s3,144(sp)
    80006028:	6a6a                	ld	s4,152(sp)
    8000602a:	7a8a                	ld	s5,160(sp)
    8000602c:	7b2a                	ld	s6,168(sp)
    8000602e:	7bca                	ld	s7,176(sp)
    80006030:	7c6a                	ld	s8,184(sp)
    80006032:	6c8e                	ld	s9,192(sp)
    80006034:	6d2e                	ld	s10,200(sp)
    80006036:	6dce                	ld	s11,208(sp)
    80006038:	6e6e                	ld	t3,216(sp)
    8000603a:	7e8e                	ld	t4,224(sp)
    8000603c:	7f2e                	ld	t5,232(sp)
    8000603e:	7fce                	ld	t6,240(sp)
    80006040:	6111                	add	sp,sp,256
    80006042:	10200073          	sret
    80006046:	00000013          	nop
    8000604a:	00000013          	nop
    8000604e:	0001                	nop

0000000080006050 <timervec>:
    80006050:	34051573          	csrrw	a0,mscratch,a0
    80006054:	e10c                	sd	a1,0(a0)
    80006056:	e510                	sd	a2,8(a0)
    80006058:	e914                	sd	a3,16(a0)
    8000605a:	6d0c                	ld	a1,24(a0)
    8000605c:	7110                	ld	a2,32(a0)
    8000605e:	6194                	ld	a3,0(a1)
    80006060:	96b2                	add	a3,a3,a2
    80006062:	e194                	sd	a3,0(a1)
    80006064:	4589                	li	a1,2
    80006066:	14459073          	csrw	sip,a1
    8000606a:	6914                	ld	a3,16(a0)
    8000606c:	6510                	ld	a2,8(a0)
    8000606e:	610c                	ld	a1,0(a0)
    80006070:	34051573          	csrrw	a0,mscratch,a0
    80006074:	30200073          	mret
	...

000000008000607a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000607a:	1141                	add	sp,sp,-16
    8000607c:	e422                	sd	s0,8(sp)
    8000607e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006080:	0c0007b7          	lui	a5,0xc000
    80006084:	4705                	li	a4,1
    80006086:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006088:	0c0007b7          	lui	a5,0xc000
    8000608c:	c3d8                	sw	a4,4(a5)
}
    8000608e:	6422                	ld	s0,8(sp)
    80006090:	0141                	add	sp,sp,16
    80006092:	8082                	ret

0000000080006094 <plicinithart>:

void
plicinithart(void)
{
    80006094:	1141                	add	sp,sp,-16
    80006096:	e406                	sd	ra,8(sp)
    80006098:	e022                	sd	s0,0(sp)
    8000609a:	0800                	add	s0,sp,16
  int hart = cpuid();
    8000609c:	ffffc097          	auipc	ra,0xffffc
    800060a0:	968080e7          	jalr	-1688(ra) # 80001a04 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800060a4:	0085171b          	sllw	a4,a0,0x8
    800060a8:	0c0027b7          	lui	a5,0xc002
    800060ac:	97ba                	add	a5,a5,a4
    800060ae:	40200713          	li	a4,1026
    800060b2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800060b6:	00d5151b          	sllw	a0,a0,0xd
    800060ba:	0c2017b7          	lui	a5,0xc201
    800060be:	97aa                	add	a5,a5,a0
    800060c0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800060c4:	60a2                	ld	ra,8(sp)
    800060c6:	6402                	ld	s0,0(sp)
    800060c8:	0141                	add	sp,sp,16
    800060ca:	8082                	ret

00000000800060cc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800060cc:	1141                	add	sp,sp,-16
    800060ce:	e406                	sd	ra,8(sp)
    800060d0:	e022                	sd	s0,0(sp)
    800060d2:	0800                	add	s0,sp,16
  int hart = cpuid();
    800060d4:	ffffc097          	auipc	ra,0xffffc
    800060d8:	930080e7          	jalr	-1744(ra) # 80001a04 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800060dc:	00d5151b          	sllw	a0,a0,0xd
    800060e0:	0c2017b7          	lui	a5,0xc201
    800060e4:	97aa                	add	a5,a5,a0
  return irq;
}
    800060e6:	43c8                	lw	a0,4(a5)
    800060e8:	60a2                	ld	ra,8(sp)
    800060ea:	6402                	ld	s0,0(sp)
    800060ec:	0141                	add	sp,sp,16
    800060ee:	8082                	ret

00000000800060f0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060f0:	1101                	add	sp,sp,-32
    800060f2:	ec06                	sd	ra,24(sp)
    800060f4:	e822                	sd	s0,16(sp)
    800060f6:	e426                	sd	s1,8(sp)
    800060f8:	1000                	add	s0,sp,32
    800060fa:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060fc:	ffffc097          	auipc	ra,0xffffc
    80006100:	908080e7          	jalr	-1784(ra) # 80001a04 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006104:	00d5151b          	sllw	a0,a0,0xd
    80006108:	0c2017b7          	lui	a5,0xc201
    8000610c:	97aa                	add	a5,a5,a0
    8000610e:	c3c4                	sw	s1,4(a5)
}
    80006110:	60e2                	ld	ra,24(sp)
    80006112:	6442                	ld	s0,16(sp)
    80006114:	64a2                	ld	s1,8(sp)
    80006116:	6105                	add	sp,sp,32
    80006118:	8082                	ret

000000008000611a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000611a:	1141                	add	sp,sp,-16
    8000611c:	e406                	sd	ra,8(sp)
    8000611e:	e022                	sd	s0,0(sp)
    80006120:	0800                	add	s0,sp,16
  if(i >= NUM)
    80006122:	479d                	li	a5,7
    80006124:	06a7c863          	blt	a5,a0,80006194 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80006128:	0001d717          	auipc	a4,0x1d
    8000612c:	ed870713          	add	a4,a4,-296 # 80023000 <disk>
    80006130:	972a                	add	a4,a4,a0
    80006132:	6789                	lui	a5,0x2
    80006134:	97ba                	add	a5,a5,a4
    80006136:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    8000613a:	e7ad                	bnez	a5,800061a4 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000613c:	00451793          	sll	a5,a0,0x4
    80006140:	0001f717          	auipc	a4,0x1f
    80006144:	ec070713          	add	a4,a4,-320 # 80025000 <disk+0x2000>
    80006148:	6314                	ld	a3,0(a4)
    8000614a:	96be                	add	a3,a3,a5
    8000614c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006150:	6314                	ld	a3,0(a4)
    80006152:	96be                	add	a3,a3,a5
    80006154:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006158:	6314                	ld	a3,0(a4)
    8000615a:	96be                	add	a3,a3,a5
    8000615c:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006160:	6318                	ld	a4,0(a4)
    80006162:	97ba                	add	a5,a5,a4
    80006164:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006168:	0001d717          	auipc	a4,0x1d
    8000616c:	e9870713          	add	a4,a4,-360 # 80023000 <disk>
    80006170:	972a                	add	a4,a4,a0
    80006172:	6789                	lui	a5,0x2
    80006174:	97ba                	add	a5,a5,a4
    80006176:	4705                	li	a4,1
    80006178:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000617c:	0001f517          	auipc	a0,0x1f
    80006180:	e9c50513          	add	a0,a0,-356 # 80025018 <disk+0x2018>
    80006184:	ffffc097          	auipc	ra,0xffffc
    80006188:	0fe080e7          	jalr	254(ra) # 80002282 <wakeup>
}
    8000618c:	60a2                	ld	ra,8(sp)
    8000618e:	6402                	ld	s0,0(sp)
    80006190:	0141                	add	sp,sp,16
    80006192:	8082                	ret
    panic("free_desc 1");
    80006194:	00002517          	auipc	a0,0x2
    80006198:	4ec50513          	add	a0,a0,1260 # 80008680 <etext+0x680>
    8000619c:	ffffa097          	auipc	ra,0xffffa
    800061a0:	3be080e7          	jalr	958(ra) # 8000055a <panic>
    panic("free_desc 2");
    800061a4:	00002517          	auipc	a0,0x2
    800061a8:	4ec50513          	add	a0,a0,1260 # 80008690 <etext+0x690>
    800061ac:	ffffa097          	auipc	ra,0xffffa
    800061b0:	3ae080e7          	jalr	942(ra) # 8000055a <panic>

00000000800061b4 <virtio_disk_init>:
{
    800061b4:	1141                	add	sp,sp,-16
    800061b6:	e406                	sd	ra,8(sp)
    800061b8:	e022                	sd	s0,0(sp)
    800061ba:	0800                	add	s0,sp,16
  initlock(&disk.vdisk_lock, "virtio_disk");
    800061bc:	00002597          	auipc	a1,0x2
    800061c0:	4e458593          	add	a1,a1,1252 # 800086a0 <etext+0x6a0>
    800061c4:	0001f517          	auipc	a0,0x1f
    800061c8:	f6450513          	add	a0,a0,-156 # 80025128 <disk+0x2128>
    800061cc:	ffffb097          	auipc	ra,0xffffb
    800061d0:	9d6080e7          	jalr	-1578(ra) # 80000ba2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061d4:	100017b7          	lui	a5,0x10001
    800061d8:	4398                	lw	a4,0(a5)
    800061da:	2701                	sext.w	a4,a4
    800061dc:	747277b7          	lui	a5,0x74727
    800061e0:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800061e4:	0ef71f63          	bne	a4,a5,800062e2 <virtio_disk_init+0x12e>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800061e8:	100017b7          	lui	a5,0x10001
    800061ec:	0791                	add	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800061ee:	439c                	lw	a5,0(a5)
    800061f0:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061f2:	4705                	li	a4,1
    800061f4:	0ee79763          	bne	a5,a4,800062e2 <virtio_disk_init+0x12e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061f8:	100017b7          	lui	a5,0x10001
    800061fc:	07a1                	add	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800061fe:	439c                	lw	a5,0(a5)
    80006200:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006202:	4709                	li	a4,2
    80006204:	0ce79f63          	bne	a5,a4,800062e2 <virtio_disk_init+0x12e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006208:	100017b7          	lui	a5,0x10001
    8000620c:	47d8                	lw	a4,12(a5)
    8000620e:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006210:	554d47b7          	lui	a5,0x554d4
    80006214:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006218:	0cf71563          	bne	a4,a5,800062e2 <virtio_disk_init+0x12e>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000621c:	100017b7          	lui	a5,0x10001
    80006220:	4705                	li	a4,1
    80006222:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006224:	470d                	li	a4,3
    80006226:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006228:	10001737          	lui	a4,0x10001
    8000622c:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000622e:	c7ffe737          	lui	a4,0xc7ffe
    80006232:	75f70713          	add	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006236:	8ef9                	and	a3,a3,a4
    80006238:	10001737          	lui	a4,0x10001
    8000623c:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000623e:	472d                	li	a4,11
    80006240:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006242:	473d                	li	a4,15
    80006244:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006246:	100017b7          	lui	a5,0x10001
    8000624a:	6705                	lui	a4,0x1
    8000624c:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000624e:	100017b7          	lui	a5,0x10001
    80006252:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006256:	100017b7          	lui	a5,0x10001
    8000625a:	03478793          	add	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    8000625e:	439c                	lw	a5,0(a5)
    80006260:	2781                	sext.w	a5,a5
  if(max == 0)
    80006262:	cbc1                	beqz	a5,800062f2 <virtio_disk_init+0x13e>
  if(max < NUM)
    80006264:	471d                	li	a4,7
    80006266:	08f77e63          	bgeu	a4,a5,80006302 <virtio_disk_init+0x14e>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000626a:	100017b7          	lui	a5,0x10001
    8000626e:	4721                	li	a4,8
    80006270:	df98                	sw	a4,56(a5)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006272:	6609                	lui	a2,0x2
    80006274:	4581                	li	a1,0
    80006276:	0001d517          	auipc	a0,0x1d
    8000627a:	d8a50513          	add	a0,a0,-630 # 80023000 <disk>
    8000627e:	ffffb097          	auipc	ra,0xffffb
    80006282:	ab0080e7          	jalr	-1360(ra) # 80000d2e <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006286:	0001d697          	auipc	a3,0x1d
    8000628a:	d7a68693          	add	a3,a3,-646 # 80023000 <disk>
    8000628e:	00c6d713          	srl	a4,a3,0xc
    80006292:	2701                	sext.w	a4,a4
    80006294:	100017b7          	lui	a5,0x10001
    80006298:	c3b8                	sw	a4,64(a5)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000629a:	0001f797          	auipc	a5,0x1f
    8000629e:	d6678793          	add	a5,a5,-666 # 80025000 <disk+0x2000>
    800062a2:	e394                	sd	a3,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800062a4:	0001d717          	auipc	a4,0x1d
    800062a8:	ddc70713          	add	a4,a4,-548 # 80023080 <disk+0x80>
    800062ac:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800062ae:	0001e717          	auipc	a4,0x1e
    800062b2:	d5270713          	add	a4,a4,-686 # 80024000 <disk+0x1000>
    800062b6:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800062b8:	4705                	li	a4,1
    800062ba:	00e78c23          	sb	a4,24(a5)
    800062be:	00e78ca3          	sb	a4,25(a5)
    800062c2:	00e78d23          	sb	a4,26(a5)
    800062c6:	00e78da3          	sb	a4,27(a5)
    800062ca:	00e78e23          	sb	a4,28(a5)
    800062ce:	00e78ea3          	sb	a4,29(a5)
    800062d2:	00e78f23          	sb	a4,30(a5)
    800062d6:	00e78fa3          	sb	a4,31(a5)
}
    800062da:	60a2                	ld	ra,8(sp)
    800062dc:	6402                	ld	s0,0(sp)
    800062de:	0141                	add	sp,sp,16
    800062e0:	8082                	ret
    panic("could not find virtio disk");
    800062e2:	00002517          	auipc	a0,0x2
    800062e6:	3ce50513          	add	a0,a0,974 # 800086b0 <etext+0x6b0>
    800062ea:	ffffa097          	auipc	ra,0xffffa
    800062ee:	270080e7          	jalr	624(ra) # 8000055a <panic>
    panic("virtio disk has no queue 0");
    800062f2:	00002517          	auipc	a0,0x2
    800062f6:	3de50513          	add	a0,a0,990 # 800086d0 <etext+0x6d0>
    800062fa:	ffffa097          	auipc	ra,0xffffa
    800062fe:	260080e7          	jalr	608(ra) # 8000055a <panic>
    panic("virtio disk max queue too short");
    80006302:	00002517          	auipc	a0,0x2
    80006306:	3ee50513          	add	a0,a0,1006 # 800086f0 <etext+0x6f0>
    8000630a:	ffffa097          	auipc	ra,0xffffa
    8000630e:	250080e7          	jalr	592(ra) # 8000055a <panic>

0000000080006312 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006312:	7159                	add	sp,sp,-112
    80006314:	f486                	sd	ra,104(sp)
    80006316:	f0a2                	sd	s0,96(sp)
    80006318:	eca6                	sd	s1,88(sp)
    8000631a:	e8ca                	sd	s2,80(sp)
    8000631c:	e4ce                	sd	s3,72(sp)
    8000631e:	e0d2                	sd	s4,64(sp)
    80006320:	fc56                	sd	s5,56(sp)
    80006322:	f85a                	sd	s6,48(sp)
    80006324:	f45e                	sd	s7,40(sp)
    80006326:	f062                	sd	s8,32(sp)
    80006328:	ec66                	sd	s9,24(sp)
    8000632a:	1880                	add	s0,sp,112
    8000632c:	8a2a                	mv	s4,a0
    8000632e:	8cae                	mv	s9,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006330:	00c52c03          	lw	s8,12(a0)
    80006334:	001c1c1b          	sllw	s8,s8,0x1
    80006338:	1c02                	sll	s8,s8,0x20
    8000633a:	020c5c13          	srl	s8,s8,0x20

  acquire(&disk.vdisk_lock);
    8000633e:	0001f517          	auipc	a0,0x1f
    80006342:	dea50513          	add	a0,a0,-534 # 80025128 <disk+0x2128>
    80006346:	ffffb097          	auipc	ra,0xffffb
    8000634a:	8ec080e7          	jalr	-1812(ra) # 80000c32 <acquire>
  for(int i = 0; i < 3; i++){
    8000634e:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006350:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006352:	0001db97          	auipc	s7,0x1d
    80006356:	caeb8b93          	add	s7,s7,-850 # 80023000 <disk>
    8000635a:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    8000635c:	4a8d                	li	s5,3
    8000635e:	a88d                	j	800063d0 <virtio_disk_rw+0xbe>
      disk.free[i] = 0;
    80006360:	00fb8733          	add	a4,s7,a5
    80006364:	975a                	add	a4,a4,s6
    80006366:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000636a:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000636c:	0207c563          	bltz	a5,80006396 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80006370:	2905                	addw	s2,s2,1
    80006372:	0611                	add	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    80006374:	1b590163          	beq	s2,s5,80006516 <virtio_disk_rw+0x204>
    idx[i] = alloc_desc();
    80006378:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000637a:	0001f717          	auipc	a4,0x1f
    8000637e:	c9e70713          	add	a4,a4,-866 # 80025018 <disk+0x2018>
    80006382:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006384:	00074683          	lbu	a3,0(a4)
    80006388:	fee1                	bnez	a3,80006360 <virtio_disk_rw+0x4e>
  for(int i = 0; i < NUM; i++){
    8000638a:	2785                	addw	a5,a5,1
    8000638c:	0705                	add	a4,a4,1
    8000638e:	fe979be3          	bne	a5,s1,80006384 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80006392:	57fd                	li	a5,-1
    80006394:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006396:	03205163          	blez	s2,800063b8 <virtio_disk_rw+0xa6>
        free_desc(idx[j]);
    8000639a:	f9042503          	lw	a0,-112(s0)
    8000639e:	00000097          	auipc	ra,0x0
    800063a2:	d7c080e7          	jalr	-644(ra) # 8000611a <free_desc>
      for(int j = 0; j < i; j++)
    800063a6:	4785                	li	a5,1
    800063a8:	0127d863          	bge	a5,s2,800063b8 <virtio_disk_rw+0xa6>
        free_desc(idx[j]);
    800063ac:	f9442503          	lw	a0,-108(s0)
    800063b0:	00000097          	auipc	ra,0x0
    800063b4:	d6a080e7          	jalr	-662(ra) # 8000611a <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800063b8:	0001f597          	auipc	a1,0x1f
    800063bc:	d7058593          	add	a1,a1,-656 # 80025128 <disk+0x2128>
    800063c0:	0001f517          	auipc	a0,0x1f
    800063c4:	c5850513          	add	a0,a0,-936 # 80025018 <disk+0x2018>
    800063c8:	ffffc097          	auipc	ra,0xffffc
    800063cc:	d2e080e7          	jalr	-722(ra) # 800020f6 <sleep>
  for(int i = 0; i < 3; i++){
    800063d0:	f9040613          	add	a2,s0,-112
    800063d4:	894e                	mv	s2,s3
    800063d6:	b74d                	j	80006378 <virtio_disk_rw+0x66>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800063d8:	0001f717          	auipc	a4,0x1f
    800063dc:	c2873703          	ld	a4,-984(a4) # 80025000 <disk+0x2000>
    800063e0:	973e                	add	a4,a4,a5
    800063e2:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800063e6:	0001d897          	auipc	a7,0x1d
    800063ea:	c1a88893          	add	a7,a7,-998 # 80023000 <disk>
    800063ee:	0001f717          	auipc	a4,0x1f
    800063f2:	c1270713          	add	a4,a4,-1006 # 80025000 <disk+0x2000>
    800063f6:	6314                	ld	a3,0(a4)
    800063f8:	96be                	add	a3,a3,a5
    800063fa:	00c6d583          	lhu	a1,12(a3)
    800063fe:	0015e593          	or	a1,a1,1
    80006402:	00b69623          	sh	a1,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006406:	f9842683          	lw	a3,-104(s0)
    8000640a:	630c                	ld	a1,0(a4)
    8000640c:	97ae                	add	a5,a5,a1
    8000640e:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006412:	20050593          	add	a1,a0,512
    80006416:	0592                	sll	a1,a1,0x4
    80006418:	95c6                	add	a1,a1,a7
    8000641a:	57fd                	li	a5,-1
    8000641c:	02f58823          	sb	a5,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006420:	00469793          	sll	a5,a3,0x4
    80006424:	00073803          	ld	a6,0(a4)
    80006428:	983e                	add	a6,a6,a5
    8000642a:	6689                	lui	a3,0x2
    8000642c:	03068693          	add	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006430:	96b2                	add	a3,a3,a2
    80006432:	96c6                	add	a3,a3,a7
    80006434:	00d83023          	sd	a3,0(a6)
  disk.desc[idx[2]].len = 1;
    80006438:	6314                	ld	a3,0(a4)
    8000643a:	96be                	add	a3,a3,a5
    8000643c:	4605                	li	a2,1
    8000643e:	c690                	sw	a2,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006440:	6314                	ld	a3,0(a4)
    80006442:	96be                	add	a3,a3,a5
    80006444:	4809                	li	a6,2
    80006446:	01069623          	sh	a6,12(a3)
  disk.desc[idx[2]].next = 0;
    8000644a:	6314                	ld	a3,0(a4)
    8000644c:	97b6                	add	a5,a5,a3
    8000644e:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006452:	00ca2223          	sw	a2,4(s4)
  disk.info[idx[0]].b = b;
    80006456:	0345b423          	sd	s4,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000645a:	6714                	ld	a3,8(a4)
    8000645c:	0026d783          	lhu	a5,2(a3)
    80006460:	8b9d                	and	a5,a5,7
    80006462:	0786                	sll	a5,a5,0x1
    80006464:	96be                	add	a3,a3,a5
    80006466:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    8000646a:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000646e:	6718                	ld	a4,8(a4)
    80006470:	00275783          	lhu	a5,2(a4)
    80006474:	2785                	addw	a5,a5,1
    80006476:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    8000647a:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000647e:	100017b7          	lui	a5,0x10001
    80006482:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006486:	004a2783          	lw	a5,4(s4)
    8000648a:	02c79163          	bne	a5,a2,800064ac <virtio_disk_rw+0x19a>
    sleep(b, &disk.vdisk_lock);
    8000648e:	0001f917          	auipc	s2,0x1f
    80006492:	c9a90913          	add	s2,s2,-870 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    80006496:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006498:	85ca                	mv	a1,s2
    8000649a:	8552                	mv	a0,s4
    8000649c:	ffffc097          	auipc	ra,0xffffc
    800064a0:	c5a080e7          	jalr	-934(ra) # 800020f6 <sleep>
  while(b->disk == 1) {
    800064a4:	004a2783          	lw	a5,4(s4)
    800064a8:	fe9788e3          	beq	a5,s1,80006498 <virtio_disk_rw+0x186>
  }

  disk.info[idx[0]].b = 0;
    800064ac:	f9042903          	lw	s2,-112(s0)
    800064b0:	20090713          	add	a4,s2,512
    800064b4:	0712                	sll	a4,a4,0x4
    800064b6:	0001d797          	auipc	a5,0x1d
    800064ba:	b4a78793          	add	a5,a5,-1206 # 80023000 <disk>
    800064be:	97ba                	add	a5,a5,a4
    800064c0:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800064c4:	0001f997          	auipc	s3,0x1f
    800064c8:	b3c98993          	add	s3,s3,-1220 # 80025000 <disk+0x2000>
    800064cc:	00491713          	sll	a4,s2,0x4
    800064d0:	0009b783          	ld	a5,0(s3)
    800064d4:	97ba                	add	a5,a5,a4
    800064d6:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064da:	854a                	mv	a0,s2
    800064dc:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064e0:	00000097          	auipc	ra,0x0
    800064e4:	c3a080e7          	jalr	-966(ra) # 8000611a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064e8:	8885                	and	s1,s1,1
    800064ea:	f0ed                	bnez	s1,800064cc <virtio_disk_rw+0x1ba>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064ec:	0001f517          	auipc	a0,0x1f
    800064f0:	c3c50513          	add	a0,a0,-964 # 80025128 <disk+0x2128>
    800064f4:	ffffa097          	auipc	ra,0xffffa
    800064f8:	7f2080e7          	jalr	2034(ra) # 80000ce6 <release>
}
    800064fc:	70a6                	ld	ra,104(sp)
    800064fe:	7406                	ld	s0,96(sp)
    80006500:	64e6                	ld	s1,88(sp)
    80006502:	6946                	ld	s2,80(sp)
    80006504:	69a6                	ld	s3,72(sp)
    80006506:	6a06                	ld	s4,64(sp)
    80006508:	7ae2                	ld	s5,56(sp)
    8000650a:	7b42                	ld	s6,48(sp)
    8000650c:	7ba2                	ld	s7,40(sp)
    8000650e:	7c02                	ld	s8,32(sp)
    80006510:	6ce2                	ld	s9,24(sp)
    80006512:	6165                	add	sp,sp,112
    80006514:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006516:	f9042503          	lw	a0,-112(s0)
    8000651a:	00451613          	sll	a2,a0,0x4
  if(write)
    8000651e:	0001d597          	auipc	a1,0x1d
    80006522:	ae258593          	add	a1,a1,-1310 # 80023000 <disk>
    80006526:	20050793          	add	a5,a0,512
    8000652a:	0792                	sll	a5,a5,0x4
    8000652c:	97ae                	add	a5,a5,a1
    8000652e:	01903733          	snez	a4,s9
    80006532:	0ae7a423          	sw	a4,168(a5)
  buf0->reserved = 0;
    80006536:	0a07a623          	sw	zero,172(a5)
  buf0->sector = sector;
    8000653a:	0b87b823          	sd	s8,176(a5)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000653e:	0001f717          	auipc	a4,0x1f
    80006542:	ac270713          	add	a4,a4,-1342 # 80025000 <disk+0x2000>
    80006546:	6314                	ld	a3,0(a4)
    80006548:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000654a:	6789                	lui	a5,0x2
    8000654c:	0a878793          	add	a5,a5,168 # 20a8 <_entry-0x7fffdf58>
    80006550:	97b2                	add	a5,a5,a2
    80006552:	97ae                	add	a5,a5,a1
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006554:	e29c                	sd	a5,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006556:	631c                	ld	a5,0(a4)
    80006558:	97b2                	add	a5,a5,a2
    8000655a:	46c1                	li	a3,16
    8000655c:	c794                	sw	a3,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000655e:	631c                	ld	a5,0(a4)
    80006560:	97b2                	add	a5,a5,a2
    80006562:	4685                	li	a3,1
    80006564:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006568:	f9442783          	lw	a5,-108(s0)
    8000656c:	6314                	ld	a3,0(a4)
    8000656e:	96b2                	add	a3,a3,a2
    80006570:	00f69723          	sh	a5,14(a3)
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006574:	0792                	sll	a5,a5,0x4
    80006576:	6314                	ld	a3,0(a4)
    80006578:	96be                	add	a3,a3,a5
    8000657a:	060a0593          	add	a1,s4,96
    8000657e:	e28c                	sd	a1,0(a3)
  disk.desc[idx[1]].len = BSIZE;
    80006580:	6318                	ld	a4,0(a4)
    80006582:	973e                	add	a4,a4,a5
    80006584:	40000693          	li	a3,1024
    80006588:	c714                	sw	a3,8(a4)
  if(write)
    8000658a:	e40c97e3          	bnez	s9,800063d8 <virtio_disk_rw+0xc6>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000658e:	0001f717          	auipc	a4,0x1f
    80006592:	a7273703          	ld	a4,-1422(a4) # 80025000 <disk+0x2000>
    80006596:	973e                	add	a4,a4,a5
    80006598:	4689                	li	a3,2
    8000659a:	00d71623          	sh	a3,12(a4)
    8000659e:	b5a1                	j	800063e6 <virtio_disk_rw+0xd4>

00000000800065a0 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800065a0:	1101                	add	sp,sp,-32
    800065a2:	ec06                	sd	ra,24(sp)
    800065a4:	e822                	sd	s0,16(sp)
    800065a6:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    800065a8:	0001f517          	auipc	a0,0x1f
    800065ac:	b8050513          	add	a0,a0,-1152 # 80025128 <disk+0x2128>
    800065b0:	ffffa097          	auipc	ra,0xffffa
    800065b4:	682080e7          	jalr	1666(ra) # 80000c32 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800065b8:	100017b7          	lui	a5,0x10001
    800065bc:	53b8                	lw	a4,96(a5)
    800065be:	8b0d                	and	a4,a4,3
    800065c0:	100017b7          	lui	a5,0x10001
    800065c4:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    800065c6:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800065ca:	0001f797          	auipc	a5,0x1f
    800065ce:	a3678793          	add	a5,a5,-1482 # 80025000 <disk+0x2000>
    800065d2:	6b94                	ld	a3,16(a5)
    800065d4:	0207d703          	lhu	a4,32(a5)
    800065d8:	0026d783          	lhu	a5,2(a3)
    800065dc:	06f70563          	beq	a4,a5,80006646 <virtio_disk_intr+0xa6>
    800065e0:	e426                	sd	s1,8(sp)
    800065e2:	e04a                	sd	s2,0(sp)
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065e4:	0001d917          	auipc	s2,0x1d
    800065e8:	a1c90913          	add	s2,s2,-1508 # 80023000 <disk>
    800065ec:	0001f497          	auipc	s1,0x1f
    800065f0:	a1448493          	add	s1,s1,-1516 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800065f4:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065f8:	6898                	ld	a4,16(s1)
    800065fa:	0204d783          	lhu	a5,32(s1)
    800065fe:	8b9d                	and	a5,a5,7
    80006600:	078e                	sll	a5,a5,0x3
    80006602:	97ba                	add	a5,a5,a4
    80006604:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006606:	20078713          	add	a4,a5,512
    8000660a:	0712                	sll	a4,a4,0x4
    8000660c:	974a                	add	a4,a4,s2
    8000660e:	03074703          	lbu	a4,48(a4)
    80006612:	e731                	bnez	a4,8000665e <virtio_disk_intr+0xbe>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006614:	20078793          	add	a5,a5,512
    80006618:	0792                	sll	a5,a5,0x4
    8000661a:	97ca                	add	a5,a5,s2
    8000661c:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    8000661e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006622:	ffffc097          	auipc	ra,0xffffc
    80006626:	c60080e7          	jalr	-928(ra) # 80002282 <wakeup>

    disk.used_idx += 1;
    8000662a:	0204d783          	lhu	a5,32(s1)
    8000662e:	2785                	addw	a5,a5,1
    80006630:	17c2                	sll	a5,a5,0x30
    80006632:	93c1                	srl	a5,a5,0x30
    80006634:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006638:	6898                	ld	a4,16(s1)
    8000663a:	00275703          	lhu	a4,2(a4)
    8000663e:	faf71be3          	bne	a4,a5,800065f4 <virtio_disk_intr+0x54>
    80006642:	64a2                	ld	s1,8(sp)
    80006644:	6902                	ld	s2,0(sp)
  }

  release(&disk.vdisk_lock);
    80006646:	0001f517          	auipc	a0,0x1f
    8000664a:	ae250513          	add	a0,a0,-1310 # 80025128 <disk+0x2128>
    8000664e:	ffffa097          	auipc	ra,0xffffa
    80006652:	698080e7          	jalr	1688(ra) # 80000ce6 <release>
}
    80006656:	60e2                	ld	ra,24(sp)
    80006658:	6442                	ld	s0,16(sp)
    8000665a:	6105                	add	sp,sp,32
    8000665c:	8082                	ret
      panic("virtio_disk_intr status");
    8000665e:	00002517          	auipc	a0,0x2
    80006662:	0b250513          	add	a0,a0,178 # 80008710 <etext+0x710>
    80006666:	ffffa097          	auipc	ra,0xffffa
    8000666a:	ef4080e7          	jalr	-268(ra) # 8000055a <panic>
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
