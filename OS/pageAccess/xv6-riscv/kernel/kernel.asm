
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
    80000066:	e2e78793          	add	a5,a5,-466 # 80005e90 <timervec>
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
    8000012e:	4c0080e7          	jalr	1216(ra) # 800025ea <either_copyin>
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
    800001c0:	96e080e7          	jalr	-1682(ra) # 80001b2a <myproc>
    800001c4:	551c                	lw	a5,40(a0)
    800001c6:	e7ad                	bnez	a5,80000230 <consoleread+0xc2>
      sleep(&cons.r, &cons.lock);
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	024080e7          	jalr	36(ra) # 800021f0 <sleep>
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
    80000218:	380080e7          	jalr	896(ra) # 80002594 <either_copyout>
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
    80000306:	33e080e7          	jalr	830(ra) # 80002640 <procdump>
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
    80000464:	f1c080e7          	jalr	-228(ra) # 8000237c <wakeup>
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
    800008f0:	a90080e7          	jalr	-1392(ra) # 8000237c <wakeup>
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
    8000097a:	00002097          	auipc	ra,0x2
    8000097e:	876080e7          	jalr	-1930(ra) # 800021f0 <sleep>
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
    80000bd0:	f42080e7          	jalr	-190(ra) # 80001b0e <mycpu>
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
    80000c02:	f10080e7          	jalr	-240(ra) # 80001b0e <mycpu>
    80000c06:	5d3c                	lw	a5,120(a0)
    80000c08:	cf89                	beqz	a5,80000c22 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c0a:	00001097          	auipc	ra,0x1
    80000c0e:	f04080e7          	jalr	-252(ra) # 80001b0e <mycpu>
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
    80000c26:	eec080e7          	jalr	-276(ra) # 80001b0e <mycpu>
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
    80000c66:	eac080e7          	jalr	-340(ra) # 80001b0e <mycpu>
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
    80000c92:	e80080e7          	jalr	-384(ra) # 80001b0e <mycpu>
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
    80000d2e:	1141                	add	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	add	s0,sp,16
    80000d34:	ca19                	beqz	a2,80000d4a <memset+0x1c>
    80000d36:	87aa                	mv	a5,a0
    80000d38:	1602                	sll	a2,a2,0x20
    80000d3a:	9201                	srl	a2,a2,0x20
    80000d3c:	00a60733          	add	a4,a2,a0
    80000d40:	00b78023          	sb	a1,0(a5)
    80000d44:	0785                	add	a5,a5,1
    80000d46:	fee79de3          	bne	a5,a4,80000d40 <memset+0x12>
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	add	sp,sp,16
    80000d4e:	8082                	ret

0000000080000d50 <memcmp>:
    80000d50:	1141                	add	sp,sp,-16
    80000d52:	e422                	sd	s0,8(sp)
    80000d54:	0800                	add	s0,sp,16
    80000d56:	ca05                	beqz	a2,80000d86 <memcmp+0x36>
    80000d58:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d5c:	1682                	sll	a3,a3,0x20
    80000d5e:	9281                	srl	a3,a3,0x20
    80000d60:	0685                	add	a3,a3,1
    80000d62:	96aa                	add	a3,a3,a0
    80000d64:	00054783          	lbu	a5,0(a0)
    80000d68:	0005c703          	lbu	a4,0(a1)
    80000d6c:	00e79863          	bne	a5,a4,80000d7c <memcmp+0x2c>
    80000d70:	0505                	add	a0,a0,1
    80000d72:	0585                	add	a1,a1,1
    80000d74:	fed518e3          	bne	a0,a3,80000d64 <memcmp+0x14>
    80000d78:	4501                	li	a0,0
    80000d7a:	a019                	j	80000d80 <memcmp+0x30>
    80000d7c:	40e7853b          	subw	a0,a5,a4
    80000d80:	6422                	ld	s0,8(sp)
    80000d82:	0141                	add	sp,sp,16
    80000d84:	8082                	ret
    80000d86:	4501                	li	a0,0
    80000d88:	bfe5                	j	80000d80 <memcmp+0x30>

0000000080000d8a <memmove>:
    80000d8a:	1141                	add	sp,sp,-16
    80000d8c:	e422                	sd	s0,8(sp)
    80000d8e:	0800                	add	s0,sp,16
    80000d90:	c205                	beqz	a2,80000db0 <memmove+0x26>
    80000d92:	02a5e263          	bltu	a1,a0,80000db6 <memmove+0x2c>
    80000d96:	1602                	sll	a2,a2,0x20
    80000d98:	9201                	srl	a2,a2,0x20
    80000d9a:	00c587b3          	add	a5,a1,a2
    80000d9e:	872a                	mv	a4,a0
    80000da0:	0585                	add	a1,a1,1
    80000da2:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd9001>
    80000da4:	fff5c683          	lbu	a3,-1(a1)
    80000da8:	fed70fa3          	sb	a3,-1(a4)
    80000dac:	feb79ae3          	bne	a5,a1,80000da0 <memmove+0x16>
    80000db0:	6422                	ld	s0,8(sp)
    80000db2:	0141                	add	sp,sp,16
    80000db4:	8082                	ret
    80000db6:	02061693          	sll	a3,a2,0x20
    80000dba:	9281                	srl	a3,a3,0x20
    80000dbc:	00d58733          	add	a4,a1,a3
    80000dc0:	fce57be3          	bgeu	a0,a4,80000d96 <memmove+0xc>
    80000dc4:	96aa                	add	a3,a3,a0
    80000dc6:	fff6079b          	addw	a5,a2,-1
    80000dca:	1782                	sll	a5,a5,0x20
    80000dcc:	9381                	srl	a5,a5,0x20
    80000dce:	fff7c793          	not	a5,a5
    80000dd2:	97ba                	add	a5,a5,a4
    80000dd4:	177d                	add	a4,a4,-1
    80000dd6:	16fd                	add	a3,a3,-1
    80000dd8:	00074603          	lbu	a2,0(a4)
    80000ddc:	00c68023          	sb	a2,0(a3)
    80000de0:	fef71ae3          	bne	a4,a5,80000dd4 <memmove+0x4a>
    80000de4:	b7f1                	j	80000db0 <memmove+0x26>

0000000080000de6 <memcpy>:
    80000de6:	1141                	add	sp,sp,-16
    80000de8:	e406                	sd	ra,8(sp)
    80000dea:	e022                	sd	s0,0(sp)
    80000dec:	0800                	add	s0,sp,16
    80000dee:	00000097          	auipc	ra,0x0
    80000df2:	f9c080e7          	jalr	-100(ra) # 80000d8a <memmove>
    80000df6:	60a2                	ld	ra,8(sp)
    80000df8:	6402                	ld	s0,0(sp)
    80000dfa:	0141                	add	sp,sp,16
    80000dfc:	8082                	ret

0000000080000dfe <strncmp>:
    80000dfe:	1141                	add	sp,sp,-16
    80000e00:	e422                	sd	s0,8(sp)
    80000e02:	0800                	add	s0,sp,16
    80000e04:	ce11                	beqz	a2,80000e20 <strncmp+0x22>
    80000e06:	00054783          	lbu	a5,0(a0)
    80000e0a:	cf89                	beqz	a5,80000e24 <strncmp+0x26>
    80000e0c:	0005c703          	lbu	a4,0(a1)
    80000e10:	00f71a63          	bne	a4,a5,80000e24 <strncmp+0x26>
    80000e14:	367d                	addw	a2,a2,-1
    80000e16:	0505                	add	a0,a0,1
    80000e18:	0585                	add	a1,a1,1
    80000e1a:	f675                	bnez	a2,80000e06 <strncmp+0x8>
    80000e1c:	4501                	li	a0,0
    80000e1e:	a801                	j	80000e2e <strncmp+0x30>
    80000e20:	4501                	li	a0,0
    80000e22:	a031                	j	80000e2e <strncmp+0x30>
    80000e24:	00054503          	lbu	a0,0(a0)
    80000e28:	0005c783          	lbu	a5,0(a1)
    80000e2c:	9d1d                	subw	a0,a0,a5
    80000e2e:	6422                	ld	s0,8(sp)
    80000e30:	0141                	add	sp,sp,16
    80000e32:	8082                	ret

0000000080000e34 <strncpy>:
    80000e34:	1141                	add	sp,sp,-16
    80000e36:	e422                	sd	s0,8(sp)
    80000e38:	0800                	add	s0,sp,16
    80000e3a:	87aa                	mv	a5,a0
    80000e3c:	86b2                	mv	a3,a2
    80000e3e:	367d                	addw	a2,a2,-1
    80000e40:	02d05563          	blez	a3,80000e6a <strncpy+0x36>
    80000e44:	0785                	add	a5,a5,1
    80000e46:	0005c703          	lbu	a4,0(a1)
    80000e4a:	fee78fa3          	sb	a4,-1(a5)
    80000e4e:	0585                	add	a1,a1,1
    80000e50:	f775                	bnez	a4,80000e3c <strncpy+0x8>
    80000e52:	873e                	mv	a4,a5
    80000e54:	9fb5                	addw	a5,a5,a3
    80000e56:	37fd                	addw	a5,a5,-1
    80000e58:	00c05963          	blez	a2,80000e6a <strncpy+0x36>
    80000e5c:	0705                	add	a4,a4,1
    80000e5e:	fe070fa3          	sb	zero,-1(a4)
    80000e62:	40e786bb          	subw	a3,a5,a4
    80000e66:	fed04be3          	bgtz	a3,80000e5c <strncpy+0x28>
    80000e6a:	6422                	ld	s0,8(sp)
    80000e6c:	0141                	add	sp,sp,16
    80000e6e:	8082                	ret

0000000080000e70 <safestrcpy>:
    80000e70:	1141                	add	sp,sp,-16
    80000e72:	e422                	sd	s0,8(sp)
    80000e74:	0800                	add	s0,sp,16
    80000e76:	02c05363          	blez	a2,80000e9c <safestrcpy+0x2c>
    80000e7a:	fff6069b          	addw	a3,a2,-1
    80000e7e:	1682                	sll	a3,a3,0x20
    80000e80:	9281                	srl	a3,a3,0x20
    80000e82:	96ae                	add	a3,a3,a1
    80000e84:	87aa                	mv	a5,a0
    80000e86:	00d58963          	beq	a1,a3,80000e98 <safestrcpy+0x28>
    80000e8a:	0585                	add	a1,a1,1
    80000e8c:	0785                	add	a5,a5,1
    80000e8e:	fff5c703          	lbu	a4,-1(a1)
    80000e92:	fee78fa3          	sb	a4,-1(a5)
    80000e96:	fb65                	bnez	a4,80000e86 <safestrcpy+0x16>
    80000e98:	00078023          	sb	zero,0(a5)
    80000e9c:	6422                	ld	s0,8(sp)
    80000e9e:	0141                	add	sp,sp,16
    80000ea0:	8082                	ret

0000000080000ea2 <strlen>:
    80000ea2:	1141                	add	sp,sp,-16
    80000ea4:	e422                	sd	s0,8(sp)
    80000ea6:	0800                	add	s0,sp,16
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
    80000ec2:	6422                	ld	s0,8(sp)
    80000ec4:	0141                	add	sp,sp,16
    80000ec6:	8082                	ret
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
    80000ed8:	c2a080e7          	jalr	-982(ra) # 80001afe <cpuid>
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
    80000ef4:	c0e080e7          	jalr	-1010(ra) # 80001afe <cpuid>
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
    80000f16:	870080e7          	jalr	-1936(ra) # 80002782 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f1a:	00005097          	auipc	ra,0x5
    80000f1e:	fba080e7          	jalr	-70(ra) # 80005ed4 <plicinithart>
  }

  scheduler();        
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	11c080e7          	jalr	284(ra) # 8000203e <scheduler>
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
    80000f86:	abe080e7          	jalr	-1346(ra) # 80001a40 <procinit>
    trapinit();      // trap vectors
    80000f8a:	00001097          	auipc	ra,0x1
    80000f8e:	7d0080e7          	jalr	2000(ra) # 8000275a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f92:	00001097          	auipc	ra,0x1
    80000f96:	7f0080e7          	jalr	2032(ra) # 80002782 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f9a:	00005097          	auipc	ra,0x5
    80000f9e:	f20080e7          	jalr	-224(ra) # 80005eba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fa2:	00005097          	auipc	ra,0x5
    80000fa6:	f32080e7          	jalr	-206(ra) # 80005ed4 <plicinithart>
    binit();         // buffer cache
    80000faa:	00002097          	auipc	ra,0x2
    80000fae:	040080e7          	jalr	64(ra) # 80002fea <binit>
    iinit();         // inode table
    80000fb2:	00002097          	auipc	ra,0x2
    80000fb6:	6cc080e7          	jalr	1740(ra) # 8000367e <iinit>
    fileinit();      // file table
    80000fba:	00003097          	auipc	ra,0x3
    80000fbe:	670080e7          	jalr	1648(ra) # 8000462a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc2:	00005097          	auipc	ra,0x5
    80000fc6:	032080e7          	jalr	50(ra) # 80005ff4 <virtio_disk_init>
    userinit();      // first user process
    80000fca:	00001097          	auipc	ra,0x1
    80000fce:	e38080e7          	jalr	-456(ra) # 80001e02 <userinit>
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
    80001282:	71e080e7          	jalr	1822(ra) # 8000199c <proc_mapstacks>
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

00000000800018a2 <ptableprint_level>:

//lab6
void
ptableprint_level(pagetable_t pagetable, int level)
{
    800018a2:	7159                	add	sp,sp,-112
    800018a4:	f486                	sd	ra,104(sp)
    800018a6:	f0a2                	sd	s0,96(sp)
    800018a8:	eca6                	sd	s1,88(sp)
    800018aa:	e8ca                	sd	s2,80(sp)
    800018ac:	e4ce                	sd	s3,72(sp)
    800018ae:	e0d2                	sd	s4,64(sp)
    800018b0:	fc56                	sd	s5,56(sp)
    800018b2:	f85a                	sd	s6,48(sp)
    800018b4:	f45e                	sd	s7,40(sp)
    800018b6:	f062                	sd	s8,32(sp)
    800018b8:	ec66                	sd	s9,24(sp)
    800018ba:	e86a                	sd	s10,16(sp)
    800018bc:	e46e                	sd	s11,8(sp)
    800018be:	1880                	add	s0,sp,112
    800018c0:	892e                	mv	s2,a1
  for(int i = 0 ; i < 512; i++) {
    800018c2:	8aaa                	mv	s5,a0
    800018c4:	4a01                	li	s4,0

    if (!(pte & PTE_V)) continue;

    for (int j = 0; j < level; j++) printf(".. ");

    printf("..%d: pte %p pa %p\n", i, pte, PTE2PA(pte));
    800018c6:	00007c17          	auipc	s8,0x7
    800018ca:	8fac0c13          	add	s8,s8,-1798 # 800081c0 <etext+0x1c0>
    for (int j = 0; j < level; j++) printf(".. ");
    800018ce:	4d01                	li	s10,0
    800018d0:	00007997          	auipc	s3,0x7
    800018d4:	8e898993          	add	s3,s3,-1816 # 800081b8 <etext+0x1b8>

    if (level == 2) continue;
    800018d8:	4c89                	li	s9,2
  for(int i = 0 ; i < 512; i++) {
    800018da:	20000b93          	li	s7,512
    800018de:	a029                	j	800018e8 <ptableprint_level+0x46>
    800018e0:	2a05                	addw	s4,s4,1
    800018e2:	0aa1                	add	s5,s5,8 # fffffffffffff008 <end+0xffffffff7ffd9008>
    800018e4:	077a0363          	beq	s4,s7,8000194a <ptableprint_level+0xa8>
    pte_t pte = pagetable[i];
    800018e8:	000abb03          	ld	s6,0(s5)
    if (!(pte & PTE_V)) continue;
    800018ec:	001b7793          	and	a5,s6,1
    800018f0:	dbe5                	beqz	a5,800018e0 <ptableprint_level+0x3e>
    for (int j = 0; j < level; j++) printf(".. ");
    800018f2:	05205063          	blez	s2,80001932 <ptableprint_level+0x90>
    800018f6:	84ea                	mv	s1,s10
    800018f8:	854e                	mv	a0,s3
    800018fa:	fffff097          	auipc	ra,0xfffff
    800018fe:	caa080e7          	jalr	-854(ra) # 800005a4 <printf>
    80001902:	2485                	addw	s1,s1,1
    80001904:	fe991ae3          	bne	s2,s1,800018f8 <ptableprint_level+0x56>
    printf("..%d: pte %p pa %p\n", i, pte, PTE2PA(pte));
    80001908:	00ab5d93          	srl	s11,s6,0xa
    8000190c:	0db2                	sll	s11,s11,0xc
    8000190e:	86ee                	mv	a3,s11
    80001910:	865a                	mv	a2,s6
    80001912:	85d2                	mv	a1,s4
    80001914:	8562                	mv	a0,s8
    80001916:	fffff097          	auipc	ra,0xfffff
    8000191a:	c8e080e7          	jalr	-882(ra) # 800005a4 <printf>
    if (level == 2) continue;
    8000191e:	fd9481e3          	beq	s1,s9,800018e0 <ptableprint_level+0x3e>

    uint64 child = PTE2PA(pte);
    ptableprint_level((pagetable_t)child, level + 1);
    80001922:	0019059b          	addw	a1,s2,1
    80001926:	856e                	mv	a0,s11
    80001928:	00000097          	auipc	ra,0x0
    8000192c:	f7a080e7          	jalr	-134(ra) # 800018a2 <ptableprint_level>
    80001930:	bf45                	j	800018e0 <ptableprint_level+0x3e>
    printf("..%d: pte %p pa %p\n", i, pte, PTE2PA(pte));
    80001932:	00ab5d93          	srl	s11,s6,0xa
    80001936:	0db2                	sll	s11,s11,0xc
    80001938:	86ee                	mv	a3,s11
    8000193a:	865a                	mv	a2,s6
    8000193c:	85d2                	mv	a1,s4
    8000193e:	8562                	mv	a0,s8
    80001940:	fffff097          	auipc	ra,0xfffff
    80001944:	c64080e7          	jalr	-924(ra) # 800005a4 <printf>
    if (level == 2) continue;
    80001948:	bfe9                	j	80001922 <ptableprint_level+0x80>
  }
}
    8000194a:	70a6                	ld	ra,104(sp)
    8000194c:	7406                	ld	s0,96(sp)
    8000194e:	64e6                	ld	s1,88(sp)
    80001950:	6946                	ld	s2,80(sp)
    80001952:	69a6                	ld	s3,72(sp)
    80001954:	6a06                	ld	s4,64(sp)
    80001956:	7ae2                	ld	s5,56(sp)
    80001958:	7b42                	ld	s6,48(sp)
    8000195a:	7ba2                	ld	s7,40(sp)
    8000195c:	7c02                	ld	s8,32(sp)
    8000195e:	6ce2                	ld	s9,24(sp)
    80001960:	6d42                	ld	s10,16(sp)
    80001962:	6da2                	ld	s11,8(sp)
    80001964:	6165                	add	sp,sp,112
    80001966:	8082                	ret

0000000080001968 <ptableprint>:

void
ptableprint(pagetable_t pagetable)
{
    80001968:	1101                	add	sp,sp,-32
    8000196a:	ec06                	sd	ra,24(sp)
    8000196c:	e822                	sd	s0,16(sp)
    8000196e:	e426                	sd	s1,8(sp)
    80001970:	1000                	add	s0,sp,32
    80001972:	84aa                	mv	s1,a0
  printf("page table %p\n", pagetable);
    80001974:	85aa                	mv	a1,a0
    80001976:	00007517          	auipc	a0,0x7
    8000197a:	86250513          	add	a0,a0,-1950 # 800081d8 <etext+0x1d8>
    8000197e:	fffff097          	auipc	ra,0xfffff
    80001982:	c26080e7          	jalr	-986(ra) # 800005a4 <printf>

  ptableprint_level(pagetable, 0);
    80001986:	4581                	li	a1,0
    80001988:	8526                	mv	a0,s1
    8000198a:	00000097          	auipc	ra,0x0
    8000198e:	f18080e7          	jalr	-232(ra) # 800018a2 <ptableprint_level>
}
    80001992:	60e2                	ld	ra,24(sp)
    80001994:	6442                	ld	s0,16(sp)
    80001996:	64a2                	ld	s1,8(sp)
    80001998:	6105                	add	sp,sp,32
    8000199a:	8082                	ret

000000008000199c <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    8000199c:	7139                	add	sp,sp,-64
    8000199e:	fc06                	sd	ra,56(sp)
    800019a0:	f822                	sd	s0,48(sp)
    800019a2:	f426                	sd	s1,40(sp)
    800019a4:	f04a                	sd	s2,32(sp)
    800019a6:	ec4e                	sd	s3,24(sp)
    800019a8:	e852                	sd	s4,16(sp)
    800019aa:	e456                	sd	s5,8(sp)
    800019ac:	e05a                	sd	s6,0(sp)
    800019ae:	0080                	add	s0,sp,64
    800019b0:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b2:	00010497          	auipc	s1,0x10
    800019b6:	d1e48493          	add	s1,s1,-738 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800019ba:	8b26                	mv	s6,s1
    800019bc:	04fa5937          	lui	s2,0x4fa5
    800019c0:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    800019c4:	0932                	sll	s2,s2,0xc
    800019c6:	fa590913          	add	s2,s2,-91
    800019ca:	0932                	sll	s2,s2,0xc
    800019cc:	fa590913          	add	s2,s2,-91
    800019d0:	0932                	sll	s2,s2,0xc
    800019d2:	fa590913          	add	s2,s2,-91
    800019d6:	040009b7          	lui	s3,0x4000
    800019da:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019dc:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019de:	00015a97          	auipc	s5,0x15
    800019e2:	6f2a8a93          	add	s5,s5,1778 # 800170d0 <tickslock>
    char *pa = kalloc();
    800019e6:	fffff097          	auipc	ra,0xfffff
    800019ea:	15c080e7          	jalr	348(ra) # 80000b42 <kalloc>
    800019ee:	862a                	mv	a2,a0
    if(pa == 0)
    800019f0:	c121                	beqz	a0,80001a30 <proc_mapstacks+0x94>
    uint64 va = KSTACK((int) (p - proc));
    800019f2:	416485b3          	sub	a1,s1,s6
    800019f6:	858d                	sra	a1,a1,0x3
    800019f8:	032585b3          	mul	a1,a1,s2
    800019fc:	2585                	addw	a1,a1,1
    800019fe:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001a02:	4719                	li	a4,6
    80001a04:	6685                	lui	a3,0x1
    80001a06:	40b985b3          	sub	a1,s3,a1
    80001a0a:	8552                	mv	a0,s4
    80001a0c:	fffff097          	auipc	ra,0xfffff
    80001a10:	782080e7          	jalr	1922(ra) # 8000118e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a14:	16848493          	add	s1,s1,360
    80001a18:	fd5497e3          	bne	s1,s5,800019e6 <proc_mapstacks+0x4a>
  }
}
    80001a1c:	70e2                	ld	ra,56(sp)
    80001a1e:	7442                	ld	s0,48(sp)
    80001a20:	74a2                	ld	s1,40(sp)
    80001a22:	7902                	ld	s2,32(sp)
    80001a24:	69e2                	ld	s3,24(sp)
    80001a26:	6a42                	ld	s4,16(sp)
    80001a28:	6aa2                	ld	s5,8(sp)
    80001a2a:	6b02                	ld	s6,0(sp)
    80001a2c:	6121                	add	sp,sp,64
    80001a2e:	8082                	ret
      panic("kalloc");
    80001a30:	00006517          	auipc	a0,0x6
    80001a34:	7b850513          	add	a0,a0,1976 # 800081e8 <etext+0x1e8>
    80001a38:	fffff097          	auipc	ra,0xfffff
    80001a3c:	b22080e7          	jalr	-1246(ra) # 8000055a <panic>

0000000080001a40 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001a40:	7139                	add	sp,sp,-64
    80001a42:	fc06                	sd	ra,56(sp)
    80001a44:	f822                	sd	s0,48(sp)
    80001a46:	f426                	sd	s1,40(sp)
    80001a48:	f04a                	sd	s2,32(sp)
    80001a4a:	ec4e                	sd	s3,24(sp)
    80001a4c:	e852                	sd	s4,16(sp)
    80001a4e:	e456                	sd	s5,8(sp)
    80001a50:	e05a                	sd	s6,0(sp)
    80001a52:	0080                	add	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001a54:	00006597          	auipc	a1,0x6
    80001a58:	79c58593          	add	a1,a1,1948 # 800081f0 <etext+0x1f0>
    80001a5c:	00010517          	auipc	a0,0x10
    80001a60:	84450513          	add	a0,a0,-1980 # 800112a0 <pid_lock>
    80001a64:	fffff097          	auipc	ra,0xfffff
    80001a68:	13e080e7          	jalr	318(ra) # 80000ba2 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001a6c:	00006597          	auipc	a1,0x6
    80001a70:	78c58593          	add	a1,a1,1932 # 800081f8 <etext+0x1f8>
    80001a74:	00010517          	auipc	a0,0x10
    80001a78:	84450513          	add	a0,a0,-1980 # 800112b8 <wait_lock>
    80001a7c:	fffff097          	auipc	ra,0xfffff
    80001a80:	126080e7          	jalr	294(ra) # 80000ba2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a84:	00010497          	auipc	s1,0x10
    80001a88:	c4c48493          	add	s1,s1,-948 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001a8c:	00006b17          	auipc	s6,0x6
    80001a90:	77cb0b13          	add	s6,s6,1916 # 80008208 <etext+0x208>
      p->kstack = KSTACK((int) (p - proc));
    80001a94:	8aa6                	mv	s5,s1
    80001a96:	04fa5937          	lui	s2,0x4fa5
    80001a9a:	fa590913          	add	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001a9e:	0932                	sll	s2,s2,0xc
    80001aa0:	fa590913          	add	s2,s2,-91
    80001aa4:	0932                	sll	s2,s2,0xc
    80001aa6:	fa590913          	add	s2,s2,-91
    80001aaa:	0932                	sll	s2,s2,0xc
    80001aac:	fa590913          	add	s2,s2,-91
    80001ab0:	040009b7          	lui	s3,0x4000
    80001ab4:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001ab6:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ab8:	00015a17          	auipc	s4,0x15
    80001abc:	618a0a13          	add	s4,s4,1560 # 800170d0 <tickslock>
      initlock(&p->lock, "proc");
    80001ac0:	85da                	mv	a1,s6
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	0de080e7          	jalr	222(ra) # 80000ba2 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001acc:	415487b3          	sub	a5,s1,s5
    80001ad0:	878d                	sra	a5,a5,0x3
    80001ad2:	032787b3          	mul	a5,a5,s2
    80001ad6:	2785                	addw	a5,a5,1
    80001ad8:	00d7979b          	sllw	a5,a5,0xd
    80001adc:	40f987b3          	sub	a5,s3,a5
    80001ae0:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ae2:	16848493          	add	s1,s1,360
    80001ae6:	fd449de3          	bne	s1,s4,80001ac0 <procinit+0x80>
  }
}
    80001aea:	70e2                	ld	ra,56(sp)
    80001aec:	7442                	ld	s0,48(sp)
    80001aee:	74a2                	ld	s1,40(sp)
    80001af0:	7902                	ld	s2,32(sp)
    80001af2:	69e2                	ld	s3,24(sp)
    80001af4:	6a42                	ld	s4,16(sp)
    80001af6:	6aa2                	ld	s5,8(sp)
    80001af8:	6b02                	ld	s6,0(sp)
    80001afa:	6121                	add	sp,sp,64
    80001afc:	8082                	ret

0000000080001afe <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001afe:	1141                	add	sp,sp,-16
    80001b00:	e422                	sd	s0,8(sp)
    80001b02:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b04:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001b06:	2501                	sext.w	a0,a0
    80001b08:	6422                	ld	s0,8(sp)
    80001b0a:	0141                	add	sp,sp,16
    80001b0c:	8082                	ret

0000000080001b0e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001b0e:	1141                	add	sp,sp,-16
    80001b10:	e422                	sd	s0,8(sp)
    80001b12:	0800                	add	s0,sp,16
    80001b14:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001b16:	2781                	sext.w	a5,a5
    80001b18:	079e                	sll	a5,a5,0x7
  return c;
}
    80001b1a:	0000f517          	auipc	a0,0xf
    80001b1e:	7b650513          	add	a0,a0,1974 # 800112d0 <cpus>
    80001b22:	953e                	add	a0,a0,a5
    80001b24:	6422                	ld	s0,8(sp)
    80001b26:	0141                	add	sp,sp,16
    80001b28:	8082                	ret

0000000080001b2a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001b2a:	1101                	add	sp,sp,-32
    80001b2c:	ec06                	sd	ra,24(sp)
    80001b2e:	e822                	sd	s0,16(sp)
    80001b30:	e426                	sd	s1,8(sp)
    80001b32:	1000                	add	s0,sp,32
  push_off();
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	0b2080e7          	jalr	178(ra) # 80000be6 <push_off>
    80001b3c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b3e:	2781                	sext.w	a5,a5
    80001b40:	079e                	sll	a5,a5,0x7
    80001b42:	0000f717          	auipc	a4,0xf
    80001b46:	75e70713          	add	a4,a4,1886 # 800112a0 <pid_lock>
    80001b4a:	97ba                	add	a5,a5,a4
    80001b4c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b4e:	fffff097          	auipc	ra,0xfffff
    80001b52:	138080e7          	jalr	312(ra) # 80000c86 <pop_off>
  return p;
}
    80001b56:	8526                	mv	a0,s1
    80001b58:	60e2                	ld	ra,24(sp)
    80001b5a:	6442                	ld	s0,16(sp)
    80001b5c:	64a2                	ld	s1,8(sp)
    80001b5e:	6105                	add	sp,sp,32
    80001b60:	8082                	ret

0000000080001b62 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b62:	1141                	add	sp,sp,-16
    80001b64:	e406                	sd	ra,8(sp)
    80001b66:	e022                	sd	s0,0(sp)
    80001b68:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	fc0080e7          	jalr	-64(ra) # 80001b2a <myproc>
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	174080e7          	jalr	372(ra) # 80000ce6 <release>

  if (first) {
    80001b7a:	00007797          	auipc	a5,0x7
    80001b7e:	cc67a783          	lw	a5,-826(a5) # 80008840 <first.1>
    80001b82:	eb89                	bnez	a5,80001b94 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b84:	00001097          	auipc	ra,0x1
    80001b88:	c16080e7          	jalr	-1002(ra) # 8000279a <usertrapret>
}
    80001b8c:	60a2                	ld	ra,8(sp)
    80001b8e:	6402                	ld	s0,0(sp)
    80001b90:	0141                	add	sp,sp,16
    80001b92:	8082                	ret
    first = 0;
    80001b94:	00007797          	auipc	a5,0x7
    80001b98:	ca07a623          	sw	zero,-852(a5) # 80008840 <first.1>
    fsinit(ROOTDEV);
    80001b9c:	4505                	li	a0,1
    80001b9e:	00002097          	auipc	ra,0x2
    80001ba2:	a60080e7          	jalr	-1440(ra) # 800035fe <fsinit>
    80001ba6:	bff9                	j	80001b84 <forkret+0x22>

0000000080001ba8 <allocpid>:
allocpid() {
    80001ba8:	1101                	add	sp,sp,-32
    80001baa:	ec06                	sd	ra,24(sp)
    80001bac:	e822                	sd	s0,16(sp)
    80001bae:	e426                	sd	s1,8(sp)
    80001bb0:	e04a                	sd	s2,0(sp)
    80001bb2:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001bb4:	0000f917          	auipc	s2,0xf
    80001bb8:	6ec90913          	add	s2,s2,1772 # 800112a0 <pid_lock>
    80001bbc:	854a                	mv	a0,s2
    80001bbe:	fffff097          	auipc	ra,0xfffff
    80001bc2:	074080e7          	jalr	116(ra) # 80000c32 <acquire>
  pid = nextpid;
    80001bc6:	00007797          	auipc	a5,0x7
    80001bca:	c7e78793          	add	a5,a5,-898 # 80008844 <nextpid>
    80001bce:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001bd0:	0014871b          	addw	a4,s1,1
    80001bd4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001bd6:	854a                	mv	a0,s2
    80001bd8:	fffff097          	auipc	ra,0xfffff
    80001bdc:	10e080e7          	jalr	270(ra) # 80000ce6 <release>
}
    80001be0:	8526                	mv	a0,s1
    80001be2:	60e2                	ld	ra,24(sp)
    80001be4:	6442                	ld	s0,16(sp)
    80001be6:	64a2                	ld	s1,8(sp)
    80001be8:	6902                	ld	s2,0(sp)
    80001bea:	6105                	add	sp,sp,32
    80001bec:	8082                	ret

0000000080001bee <proc_pagetable>:
{
    80001bee:	1101                	add	sp,sp,-32
    80001bf0:	ec06                	sd	ra,24(sp)
    80001bf2:	e822                	sd	s0,16(sp)
    80001bf4:	e426                	sd	s1,8(sp)
    80001bf6:	e04a                	sd	s2,0(sp)
    80001bf8:	1000                	add	s0,sp,32
    80001bfa:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bfc:	fffff097          	auipc	ra,0xfffff
    80001c00:	78c080e7          	jalr	1932(ra) # 80001388 <uvmcreate>
    80001c04:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c06:	c121                	beqz	a0,80001c46 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c08:	4729                	li	a4,10
    80001c0a:	00005697          	auipc	a3,0x5
    80001c0e:	3f668693          	add	a3,a3,1014 # 80007000 <_trampoline>
    80001c12:	6605                	lui	a2,0x1
    80001c14:	040005b7          	lui	a1,0x4000
    80001c18:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c1a:	05b2                	sll	a1,a1,0xc
    80001c1c:	fffff097          	auipc	ra,0xfffff
    80001c20:	4d2080e7          	jalr	1234(ra) # 800010ee <mappages>
    80001c24:	02054863          	bltz	a0,80001c54 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c28:	4719                	li	a4,6
    80001c2a:	05893683          	ld	a3,88(s2)
    80001c2e:	6605                	lui	a2,0x1
    80001c30:	020005b7          	lui	a1,0x2000
    80001c34:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c36:	05b6                	sll	a1,a1,0xd
    80001c38:	8526                	mv	a0,s1
    80001c3a:	fffff097          	auipc	ra,0xfffff
    80001c3e:	4b4080e7          	jalr	1204(ra) # 800010ee <mappages>
    80001c42:	02054163          	bltz	a0,80001c64 <proc_pagetable+0x76>
}
    80001c46:	8526                	mv	a0,s1
    80001c48:	60e2                	ld	ra,24(sp)
    80001c4a:	6442                	ld	s0,16(sp)
    80001c4c:	64a2                	ld	s1,8(sp)
    80001c4e:	6902                	ld	s2,0(sp)
    80001c50:	6105                	add	sp,sp,32
    80001c52:	8082                	ret
    uvmfree(pagetable, 0);
    80001c54:	4581                	li	a1,0
    80001c56:	8526                	mv	a0,s1
    80001c58:	00000097          	auipc	ra,0x0
    80001c5c:	936080e7          	jalr	-1738(ra) # 8000158e <uvmfree>
    return 0;
    80001c60:	4481                	li	s1,0
    80001c62:	b7d5                	j	80001c46 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c64:	4681                	li	a3,0
    80001c66:	4605                	li	a2,1
    80001c68:	040005b7          	lui	a1,0x4000
    80001c6c:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c6e:	05b2                	sll	a1,a1,0xc
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	642080e7          	jalr	1602(ra) # 800012b4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c7a:	4581                	li	a1,0
    80001c7c:	8526                	mv	a0,s1
    80001c7e:	00000097          	auipc	ra,0x0
    80001c82:	910080e7          	jalr	-1776(ra) # 8000158e <uvmfree>
    return 0;
    80001c86:	4481                	li	s1,0
    80001c88:	bf7d                	j	80001c46 <proc_pagetable+0x58>

0000000080001c8a <proc_freepagetable>:
{
    80001c8a:	1101                	add	sp,sp,-32
    80001c8c:	ec06                	sd	ra,24(sp)
    80001c8e:	e822                	sd	s0,16(sp)
    80001c90:	e426                	sd	s1,8(sp)
    80001c92:	e04a                	sd	s2,0(sp)
    80001c94:	1000                	add	s0,sp,32
    80001c96:	84aa                	mv	s1,a0
    80001c98:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c9a:	4681                	li	a3,0
    80001c9c:	4605                	li	a2,1
    80001c9e:	040005b7          	lui	a1,0x4000
    80001ca2:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ca4:	05b2                	sll	a1,a1,0xc
    80001ca6:	fffff097          	auipc	ra,0xfffff
    80001caa:	60e080e7          	jalr	1550(ra) # 800012b4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cae:	4681                	li	a3,0
    80001cb0:	4605                	li	a2,1
    80001cb2:	020005b7          	lui	a1,0x2000
    80001cb6:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cb8:	05b6                	sll	a1,a1,0xd
    80001cba:	8526                	mv	a0,s1
    80001cbc:	fffff097          	auipc	ra,0xfffff
    80001cc0:	5f8080e7          	jalr	1528(ra) # 800012b4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001cc4:	85ca                	mv	a1,s2
    80001cc6:	8526                	mv	a0,s1
    80001cc8:	00000097          	auipc	ra,0x0
    80001ccc:	8c6080e7          	jalr	-1850(ra) # 8000158e <uvmfree>
}
    80001cd0:	60e2                	ld	ra,24(sp)
    80001cd2:	6442                	ld	s0,16(sp)
    80001cd4:	64a2                	ld	s1,8(sp)
    80001cd6:	6902                	ld	s2,0(sp)
    80001cd8:	6105                	add	sp,sp,32
    80001cda:	8082                	ret

0000000080001cdc <freeproc>:
{
    80001cdc:	1101                	add	sp,sp,-32
    80001cde:	ec06                	sd	ra,24(sp)
    80001ce0:	e822                	sd	s0,16(sp)
    80001ce2:	e426                	sd	s1,8(sp)
    80001ce4:	1000                	add	s0,sp,32
    80001ce6:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001ce8:	6d28                	ld	a0,88(a0)
    80001cea:	c509                	beqz	a0,80001cf4 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001cec:	fffff097          	auipc	ra,0xfffff
    80001cf0:	d58080e7          	jalr	-680(ra) # 80000a44 <kfree>
  p->trapframe = 0;
    80001cf4:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001cf8:	68a8                	ld	a0,80(s1)
    80001cfa:	c511                	beqz	a0,80001d06 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001cfc:	64ac                	ld	a1,72(s1)
    80001cfe:	00000097          	auipc	ra,0x0
    80001d02:	f8c080e7          	jalr	-116(ra) # 80001c8a <proc_freepagetable>
  p->pagetable = 0;
    80001d06:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001d0a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001d0e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001d12:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001d16:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001d1a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001d1e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001d22:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001d26:	0004ac23          	sw	zero,24(s1)
}
    80001d2a:	60e2                	ld	ra,24(sp)
    80001d2c:	6442                	ld	s0,16(sp)
    80001d2e:	64a2                	ld	s1,8(sp)
    80001d30:	6105                	add	sp,sp,32
    80001d32:	8082                	ret

0000000080001d34 <allocproc>:
{
    80001d34:	1101                	add	sp,sp,-32
    80001d36:	ec06                	sd	ra,24(sp)
    80001d38:	e822                	sd	s0,16(sp)
    80001d3a:	e426                	sd	s1,8(sp)
    80001d3c:	e04a                	sd	s2,0(sp)
    80001d3e:	1000                	add	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d40:	00010497          	auipc	s1,0x10
    80001d44:	99048493          	add	s1,s1,-1648 # 800116d0 <proc>
    80001d48:	00015917          	auipc	s2,0x15
    80001d4c:	38890913          	add	s2,s2,904 # 800170d0 <tickslock>
    acquire(&p->lock);
    80001d50:	8526                	mv	a0,s1
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	ee0080e7          	jalr	-288(ra) # 80000c32 <acquire>
    if(p->state == UNUSED) {
    80001d5a:	4c9c                	lw	a5,24(s1)
    80001d5c:	cf81                	beqz	a5,80001d74 <allocproc+0x40>
      release(&p->lock);
    80001d5e:	8526                	mv	a0,s1
    80001d60:	fffff097          	auipc	ra,0xfffff
    80001d64:	f86080e7          	jalr	-122(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d68:	16848493          	add	s1,s1,360
    80001d6c:	ff2492e3          	bne	s1,s2,80001d50 <allocproc+0x1c>
  return 0;
    80001d70:	4481                	li	s1,0
    80001d72:	a889                	j	80001dc4 <allocproc+0x90>
  p->pid = allocpid();
    80001d74:	00000097          	auipc	ra,0x0
    80001d78:	e34080e7          	jalr	-460(ra) # 80001ba8 <allocpid>
    80001d7c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d7e:	4785                	li	a5,1
    80001d80:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d82:	fffff097          	auipc	ra,0xfffff
    80001d86:	dc0080e7          	jalr	-576(ra) # 80000b42 <kalloc>
    80001d8a:	892a                	mv	s2,a0
    80001d8c:	eca8                	sd	a0,88(s1)
    80001d8e:	c131                	beqz	a0,80001dd2 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001d90:	8526                	mv	a0,s1
    80001d92:	00000097          	auipc	ra,0x0
    80001d96:	e5c080e7          	jalr	-420(ra) # 80001bee <proc_pagetable>
    80001d9a:	892a                	mv	s2,a0
    80001d9c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d9e:	c531                	beqz	a0,80001dea <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001da0:	07000613          	li	a2,112
    80001da4:	4581                	li	a1,0
    80001da6:	06048513          	add	a0,s1,96
    80001daa:	fffff097          	auipc	ra,0xfffff
    80001dae:	f84080e7          	jalr	-124(ra) # 80000d2e <memset>
  p->context.ra = (uint64)forkret;
    80001db2:	00000797          	auipc	a5,0x0
    80001db6:	db078793          	add	a5,a5,-592 # 80001b62 <forkret>
    80001dba:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001dbc:	60bc                	ld	a5,64(s1)
    80001dbe:	6705                	lui	a4,0x1
    80001dc0:	97ba                	add	a5,a5,a4
    80001dc2:	f4bc                	sd	a5,104(s1)
}
    80001dc4:	8526                	mv	a0,s1
    80001dc6:	60e2                	ld	ra,24(sp)
    80001dc8:	6442                	ld	s0,16(sp)
    80001dca:	64a2                	ld	s1,8(sp)
    80001dcc:	6902                	ld	s2,0(sp)
    80001dce:	6105                	add	sp,sp,32
    80001dd0:	8082                	ret
    freeproc(p);
    80001dd2:	8526                	mv	a0,s1
    80001dd4:	00000097          	auipc	ra,0x0
    80001dd8:	f08080e7          	jalr	-248(ra) # 80001cdc <freeproc>
    release(&p->lock);
    80001ddc:	8526                	mv	a0,s1
    80001dde:	fffff097          	auipc	ra,0xfffff
    80001de2:	f08080e7          	jalr	-248(ra) # 80000ce6 <release>
    return 0;
    80001de6:	84ca                	mv	s1,s2
    80001de8:	bff1                	j	80001dc4 <allocproc+0x90>
    freeproc(p);
    80001dea:	8526                	mv	a0,s1
    80001dec:	00000097          	auipc	ra,0x0
    80001df0:	ef0080e7          	jalr	-272(ra) # 80001cdc <freeproc>
    release(&p->lock);
    80001df4:	8526                	mv	a0,s1
    80001df6:	fffff097          	auipc	ra,0xfffff
    80001dfa:	ef0080e7          	jalr	-272(ra) # 80000ce6 <release>
    return 0;
    80001dfe:	84ca                	mv	s1,s2
    80001e00:	b7d1                	j	80001dc4 <allocproc+0x90>

0000000080001e02 <userinit>:
{
    80001e02:	1101                	add	sp,sp,-32
    80001e04:	ec06                	sd	ra,24(sp)
    80001e06:	e822                	sd	s0,16(sp)
    80001e08:	e426                	sd	s1,8(sp)
    80001e0a:	1000                	add	s0,sp,32
  p = allocproc();
    80001e0c:	00000097          	auipc	ra,0x0
    80001e10:	f28080e7          	jalr	-216(ra) # 80001d34 <allocproc>
    80001e14:	84aa                	mv	s1,a0
  initproc = p;
    80001e16:	00007797          	auipc	a5,0x7
    80001e1a:	20a7b923          	sd	a0,530(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001e1e:	03400613          	li	a2,52
    80001e22:	00007597          	auipc	a1,0x7
    80001e26:	a2e58593          	add	a1,a1,-1490 # 80008850 <initcode>
    80001e2a:	6928                	ld	a0,80(a0)
    80001e2c:	fffff097          	auipc	ra,0xfffff
    80001e30:	58a080e7          	jalr	1418(ra) # 800013b6 <uvminit>
  p->sz = PGSIZE;
    80001e34:	6785                	lui	a5,0x1
    80001e36:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001e38:	6cb8                	ld	a4,88(s1)
    80001e3a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001e3e:	6cb8                	ld	a4,88(s1)
    80001e40:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e42:	4641                	li	a2,16
    80001e44:	00006597          	auipc	a1,0x6
    80001e48:	3cc58593          	add	a1,a1,972 # 80008210 <etext+0x210>
    80001e4c:	15848513          	add	a0,s1,344
    80001e50:	fffff097          	auipc	ra,0xfffff
    80001e54:	020080e7          	jalr	32(ra) # 80000e70 <safestrcpy>
  p->cwd = namei("/");
    80001e58:	00006517          	auipc	a0,0x6
    80001e5c:	3c850513          	add	a0,a0,968 # 80008220 <etext+0x220>
    80001e60:	00002097          	auipc	ra,0x2
    80001e64:	1e4080e7          	jalr	484(ra) # 80004044 <namei>
    80001e68:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e6c:	478d                	li	a5,3
    80001e6e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e70:	8526                	mv	a0,s1
    80001e72:	fffff097          	auipc	ra,0xfffff
    80001e76:	e74080e7          	jalr	-396(ra) # 80000ce6 <release>
}
    80001e7a:	60e2                	ld	ra,24(sp)
    80001e7c:	6442                	ld	s0,16(sp)
    80001e7e:	64a2                	ld	s1,8(sp)
    80001e80:	6105                	add	sp,sp,32
    80001e82:	8082                	ret

0000000080001e84 <growproc>:
{
    80001e84:	1101                	add	sp,sp,-32
    80001e86:	ec06                	sd	ra,24(sp)
    80001e88:	e822                	sd	s0,16(sp)
    80001e8a:	e426                	sd	s1,8(sp)
    80001e8c:	e04a                	sd	s2,0(sp)
    80001e8e:	1000                	add	s0,sp,32
    80001e90:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e92:	00000097          	auipc	ra,0x0
    80001e96:	c98080e7          	jalr	-872(ra) # 80001b2a <myproc>
    80001e9a:	892a                	mv	s2,a0
  sz = p->sz;
    80001e9c:	652c                	ld	a1,72(a0)
    80001e9e:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001ea2:	00904f63          	bgtz	s1,80001ec0 <growproc+0x3c>
  } else if(n < 0){
    80001ea6:	0204cd63          	bltz	s1,80001ee0 <growproc+0x5c>
  p->sz = sz;
    80001eaa:	1782                	sll	a5,a5,0x20
    80001eac:	9381                	srl	a5,a5,0x20
    80001eae:	04f93423          	sd	a5,72(s2)
  return 0;
    80001eb2:	4501                	li	a0,0
}
    80001eb4:	60e2                	ld	ra,24(sp)
    80001eb6:	6442                	ld	s0,16(sp)
    80001eb8:	64a2                	ld	s1,8(sp)
    80001eba:	6902                	ld	s2,0(sp)
    80001ebc:	6105                	add	sp,sp,32
    80001ebe:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001ec0:	00f4863b          	addw	a2,s1,a5
    80001ec4:	1602                	sll	a2,a2,0x20
    80001ec6:	9201                	srl	a2,a2,0x20
    80001ec8:	1582                	sll	a1,a1,0x20
    80001eca:	9181                	srl	a1,a1,0x20
    80001ecc:	6928                	ld	a0,80(a0)
    80001ece:	fffff097          	auipc	ra,0xfffff
    80001ed2:	5a2080e7          	jalr	1442(ra) # 80001470 <uvmalloc>
    80001ed6:	0005079b          	sext.w	a5,a0
    80001eda:	fbe1                	bnez	a5,80001eaa <growproc+0x26>
      return -1;
    80001edc:	557d                	li	a0,-1
    80001ede:	bfd9                	j	80001eb4 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ee0:	00f4863b          	addw	a2,s1,a5
    80001ee4:	1602                	sll	a2,a2,0x20
    80001ee6:	9201                	srl	a2,a2,0x20
    80001ee8:	1582                	sll	a1,a1,0x20
    80001eea:	9181                	srl	a1,a1,0x20
    80001eec:	6928                	ld	a0,80(a0)
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	53a080e7          	jalr	1338(ra) # 80001428 <uvmdealloc>
    80001ef6:	0005079b          	sext.w	a5,a0
    80001efa:	bf45                	j	80001eaa <growproc+0x26>

0000000080001efc <fork>:
{
    80001efc:	7139                	add	sp,sp,-64
    80001efe:	fc06                	sd	ra,56(sp)
    80001f00:	f822                	sd	s0,48(sp)
    80001f02:	f04a                	sd	s2,32(sp)
    80001f04:	e456                	sd	s5,8(sp)
    80001f06:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001f08:	00000097          	auipc	ra,0x0
    80001f0c:	c22080e7          	jalr	-990(ra) # 80001b2a <myproc>
    80001f10:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001f12:	00000097          	auipc	ra,0x0
    80001f16:	e22080e7          	jalr	-478(ra) # 80001d34 <allocproc>
    80001f1a:	12050063          	beqz	a0,8000203a <fork+0x13e>
    80001f1e:	e852                	sd	s4,16(sp)
    80001f20:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001f22:	048ab603          	ld	a2,72(s5)
    80001f26:	692c                	ld	a1,80(a0)
    80001f28:	050ab503          	ld	a0,80(s5)
    80001f2c:	fffff097          	auipc	ra,0xfffff
    80001f30:	69c080e7          	jalr	1692(ra) # 800015c8 <uvmcopy>
    80001f34:	04054a63          	bltz	a0,80001f88 <fork+0x8c>
    80001f38:	f426                	sd	s1,40(sp)
    80001f3a:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001f3c:	048ab783          	ld	a5,72(s5)
    80001f40:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001f44:	058ab683          	ld	a3,88(s5)
    80001f48:	87b6                	mv	a5,a3
    80001f4a:	058a3703          	ld	a4,88(s4)
    80001f4e:	12068693          	add	a3,a3,288
    80001f52:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f56:	6788                	ld	a0,8(a5)
    80001f58:	6b8c                	ld	a1,16(a5)
    80001f5a:	6f90                	ld	a2,24(a5)
    80001f5c:	01073023          	sd	a6,0(a4)
    80001f60:	e708                	sd	a0,8(a4)
    80001f62:	eb0c                	sd	a1,16(a4)
    80001f64:	ef10                	sd	a2,24(a4)
    80001f66:	02078793          	add	a5,a5,32
    80001f6a:	02070713          	add	a4,a4,32
    80001f6e:	fed792e3          	bne	a5,a3,80001f52 <fork+0x56>
  np->trapframe->a0 = 0;
    80001f72:	058a3783          	ld	a5,88(s4)
    80001f76:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f7a:	0d0a8493          	add	s1,s5,208
    80001f7e:	0d0a0913          	add	s2,s4,208
    80001f82:	150a8993          	add	s3,s5,336
    80001f86:	a015                	j	80001faa <fork+0xae>
    freeproc(np);
    80001f88:	8552                	mv	a0,s4
    80001f8a:	00000097          	auipc	ra,0x0
    80001f8e:	d52080e7          	jalr	-686(ra) # 80001cdc <freeproc>
    release(&np->lock);
    80001f92:	8552                	mv	a0,s4
    80001f94:	fffff097          	auipc	ra,0xfffff
    80001f98:	d52080e7          	jalr	-686(ra) # 80000ce6 <release>
    return -1;
    80001f9c:	597d                	li	s2,-1
    80001f9e:	6a42                	ld	s4,16(sp)
    80001fa0:	a071                	j	8000202c <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001fa2:	04a1                	add	s1,s1,8
    80001fa4:	0921                	add	s2,s2,8
    80001fa6:	01348b63          	beq	s1,s3,80001fbc <fork+0xc0>
    if(p->ofile[i])
    80001faa:	6088                	ld	a0,0(s1)
    80001fac:	d97d                	beqz	a0,80001fa2 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001fae:	00002097          	auipc	ra,0x2
    80001fb2:	70e080e7          	jalr	1806(ra) # 800046bc <filedup>
    80001fb6:	00a93023          	sd	a0,0(s2)
    80001fba:	b7e5                	j	80001fa2 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001fbc:	150ab503          	ld	a0,336(s5)
    80001fc0:	00002097          	auipc	ra,0x2
    80001fc4:	874080e7          	jalr	-1932(ra) # 80003834 <idup>
    80001fc8:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001fcc:	4641                	li	a2,16
    80001fce:	158a8593          	add	a1,s5,344
    80001fd2:	158a0513          	add	a0,s4,344
    80001fd6:	fffff097          	auipc	ra,0xfffff
    80001fda:	e9a080e7          	jalr	-358(ra) # 80000e70 <safestrcpy>
  pid = np->pid;
    80001fde:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001fe2:	8552                	mv	a0,s4
    80001fe4:	fffff097          	auipc	ra,0xfffff
    80001fe8:	d02080e7          	jalr	-766(ra) # 80000ce6 <release>
  acquire(&wait_lock);
    80001fec:	0000f497          	auipc	s1,0xf
    80001ff0:	2cc48493          	add	s1,s1,716 # 800112b8 <wait_lock>
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	fffff097          	auipc	ra,0xfffff
    80001ffa:	c3c080e7          	jalr	-964(ra) # 80000c32 <acquire>
  np->parent = p;
    80001ffe:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80002002:	8526                	mv	a0,s1
    80002004:	fffff097          	auipc	ra,0xfffff
    80002008:	ce2080e7          	jalr	-798(ra) # 80000ce6 <release>
  acquire(&np->lock);
    8000200c:	8552                	mv	a0,s4
    8000200e:	fffff097          	auipc	ra,0xfffff
    80002012:	c24080e7          	jalr	-988(ra) # 80000c32 <acquire>
  np->state = RUNNABLE;
    80002016:	478d                	li	a5,3
    80002018:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    8000201c:	8552                	mv	a0,s4
    8000201e:	fffff097          	auipc	ra,0xfffff
    80002022:	cc8080e7          	jalr	-824(ra) # 80000ce6 <release>
  return pid;
    80002026:	74a2                	ld	s1,40(sp)
    80002028:	69e2                	ld	s3,24(sp)
    8000202a:	6a42                	ld	s4,16(sp)
}
    8000202c:	854a                	mv	a0,s2
    8000202e:	70e2                	ld	ra,56(sp)
    80002030:	7442                	ld	s0,48(sp)
    80002032:	7902                	ld	s2,32(sp)
    80002034:	6aa2                	ld	s5,8(sp)
    80002036:	6121                	add	sp,sp,64
    80002038:	8082                	ret
    return -1;
    8000203a:	597d                	li	s2,-1
    8000203c:	bfc5                	j	8000202c <fork+0x130>

000000008000203e <scheduler>:
{
    8000203e:	7139                	add	sp,sp,-64
    80002040:	fc06                	sd	ra,56(sp)
    80002042:	f822                	sd	s0,48(sp)
    80002044:	f426                	sd	s1,40(sp)
    80002046:	f04a                	sd	s2,32(sp)
    80002048:	ec4e                	sd	s3,24(sp)
    8000204a:	e852                	sd	s4,16(sp)
    8000204c:	e456                	sd	s5,8(sp)
    8000204e:	e05a                	sd	s6,0(sp)
    80002050:	0080                	add	s0,sp,64
    80002052:	8792                	mv	a5,tp
  int id = r_tp();
    80002054:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002056:	00779a93          	sll	s5,a5,0x7
    8000205a:	0000f717          	auipc	a4,0xf
    8000205e:	24670713          	add	a4,a4,582 # 800112a0 <pid_lock>
    80002062:	9756                	add	a4,a4,s5
    80002064:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002068:	0000f717          	auipc	a4,0xf
    8000206c:	27070713          	add	a4,a4,624 # 800112d8 <cpus+0x8>
    80002070:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80002072:	498d                	li	s3,3
        p->state = RUNNING;
    80002074:	4b11                	li	s6,4
        c->proc = p;
    80002076:	079e                	sll	a5,a5,0x7
    80002078:	0000fa17          	auipc	s4,0xf
    8000207c:	228a0a13          	add	s4,s4,552 # 800112a0 <pid_lock>
    80002080:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002082:	00015917          	auipc	s2,0x15
    80002086:	04e90913          	add	s2,s2,78 # 800170d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000208a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000208e:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002092:	10079073          	csrw	sstatus,a5
    80002096:	0000f497          	auipc	s1,0xf
    8000209a:	63a48493          	add	s1,s1,1594 # 800116d0 <proc>
    8000209e:	a811                	j	800020b2 <scheduler+0x74>
      release(&p->lock);
    800020a0:	8526                	mv	a0,s1
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	c44080e7          	jalr	-956(ra) # 80000ce6 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800020aa:	16848493          	add	s1,s1,360
    800020ae:	fd248ee3          	beq	s1,s2,8000208a <scheduler+0x4c>
      acquire(&p->lock);
    800020b2:	8526                	mv	a0,s1
    800020b4:	fffff097          	auipc	ra,0xfffff
    800020b8:	b7e080e7          	jalr	-1154(ra) # 80000c32 <acquire>
      if(p->state == RUNNABLE) {
    800020bc:	4c9c                	lw	a5,24(s1)
    800020be:	ff3791e3          	bne	a5,s3,800020a0 <scheduler+0x62>
        p->state = RUNNING;
    800020c2:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    800020c6:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800020ca:	06048593          	add	a1,s1,96
    800020ce:	8556                	mv	a0,s5
    800020d0:	00000097          	auipc	ra,0x0
    800020d4:	620080e7          	jalr	1568(ra) # 800026f0 <swtch>
        c->proc = 0;
    800020d8:	020a3823          	sd	zero,48(s4)
    800020dc:	b7d1                	j	800020a0 <scheduler+0x62>

00000000800020de <sched>:
{
    800020de:	7179                	add	sp,sp,-48
    800020e0:	f406                	sd	ra,40(sp)
    800020e2:	f022                	sd	s0,32(sp)
    800020e4:	ec26                	sd	s1,24(sp)
    800020e6:	e84a                	sd	s2,16(sp)
    800020e8:	e44e                	sd	s3,8(sp)
    800020ea:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    800020ec:	00000097          	auipc	ra,0x0
    800020f0:	a3e080e7          	jalr	-1474(ra) # 80001b2a <myproc>
    800020f4:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	ac2080e7          	jalr	-1342(ra) # 80000bb8 <holding>
    800020fe:	c93d                	beqz	a0,80002174 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002100:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002102:	2781                	sext.w	a5,a5
    80002104:	079e                	sll	a5,a5,0x7
    80002106:	0000f717          	auipc	a4,0xf
    8000210a:	19a70713          	add	a4,a4,410 # 800112a0 <pid_lock>
    8000210e:	97ba                	add	a5,a5,a4
    80002110:	0a87a703          	lw	a4,168(a5)
    80002114:	4785                	li	a5,1
    80002116:	06f71763          	bne	a4,a5,80002184 <sched+0xa6>
  if(p->state == RUNNING)
    8000211a:	4c98                	lw	a4,24(s1)
    8000211c:	4791                	li	a5,4
    8000211e:	06f70b63          	beq	a4,a5,80002194 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002122:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002126:	8b89                	and	a5,a5,2
  if(intr_get())
    80002128:	efb5                	bnez	a5,800021a4 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000212a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000212c:	0000f917          	auipc	s2,0xf
    80002130:	17490913          	add	s2,s2,372 # 800112a0 <pid_lock>
    80002134:	2781                	sext.w	a5,a5
    80002136:	079e                	sll	a5,a5,0x7
    80002138:	97ca                	add	a5,a5,s2
    8000213a:	0ac7a983          	lw	s3,172(a5)
    8000213e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002140:	2781                	sext.w	a5,a5
    80002142:	079e                	sll	a5,a5,0x7
    80002144:	0000f597          	auipc	a1,0xf
    80002148:	19458593          	add	a1,a1,404 # 800112d8 <cpus+0x8>
    8000214c:	95be                	add	a1,a1,a5
    8000214e:	06048513          	add	a0,s1,96
    80002152:	00000097          	auipc	ra,0x0
    80002156:	59e080e7          	jalr	1438(ra) # 800026f0 <swtch>
    8000215a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000215c:	2781                	sext.w	a5,a5
    8000215e:	079e                	sll	a5,a5,0x7
    80002160:	993e                	add	s2,s2,a5
    80002162:	0b392623          	sw	s3,172(s2)
}
    80002166:	70a2                	ld	ra,40(sp)
    80002168:	7402                	ld	s0,32(sp)
    8000216a:	64e2                	ld	s1,24(sp)
    8000216c:	6942                	ld	s2,16(sp)
    8000216e:	69a2                	ld	s3,8(sp)
    80002170:	6145                	add	sp,sp,48
    80002172:	8082                	ret
    panic("sched p->lock");
    80002174:	00006517          	auipc	a0,0x6
    80002178:	0b450513          	add	a0,a0,180 # 80008228 <etext+0x228>
    8000217c:	ffffe097          	auipc	ra,0xffffe
    80002180:	3de080e7          	jalr	990(ra) # 8000055a <panic>
    panic("sched locks");
    80002184:	00006517          	auipc	a0,0x6
    80002188:	0b450513          	add	a0,a0,180 # 80008238 <etext+0x238>
    8000218c:	ffffe097          	auipc	ra,0xffffe
    80002190:	3ce080e7          	jalr	974(ra) # 8000055a <panic>
    panic("sched running");
    80002194:	00006517          	auipc	a0,0x6
    80002198:	0b450513          	add	a0,a0,180 # 80008248 <etext+0x248>
    8000219c:	ffffe097          	auipc	ra,0xffffe
    800021a0:	3be080e7          	jalr	958(ra) # 8000055a <panic>
    panic("sched interruptible");
    800021a4:	00006517          	auipc	a0,0x6
    800021a8:	0b450513          	add	a0,a0,180 # 80008258 <etext+0x258>
    800021ac:	ffffe097          	auipc	ra,0xffffe
    800021b0:	3ae080e7          	jalr	942(ra) # 8000055a <panic>

00000000800021b4 <yield>:
{
    800021b4:	1101                	add	sp,sp,-32
    800021b6:	ec06                	sd	ra,24(sp)
    800021b8:	e822                	sd	s0,16(sp)
    800021ba:	e426                	sd	s1,8(sp)
    800021bc:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    800021be:	00000097          	auipc	ra,0x0
    800021c2:	96c080e7          	jalr	-1684(ra) # 80001b2a <myproc>
    800021c6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	a6a080e7          	jalr	-1430(ra) # 80000c32 <acquire>
  p->state = RUNNABLE;
    800021d0:	478d                	li	a5,3
    800021d2:	cc9c                	sw	a5,24(s1)
  sched();
    800021d4:	00000097          	auipc	ra,0x0
    800021d8:	f0a080e7          	jalr	-246(ra) # 800020de <sched>
  release(&p->lock);
    800021dc:	8526                	mv	a0,s1
    800021de:	fffff097          	auipc	ra,0xfffff
    800021e2:	b08080e7          	jalr	-1272(ra) # 80000ce6 <release>
}
    800021e6:	60e2                	ld	ra,24(sp)
    800021e8:	6442                	ld	s0,16(sp)
    800021ea:	64a2                	ld	s1,8(sp)
    800021ec:	6105                	add	sp,sp,32
    800021ee:	8082                	ret

00000000800021f0 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800021f0:	7179                	add	sp,sp,-48
    800021f2:	f406                	sd	ra,40(sp)
    800021f4:	f022                	sd	s0,32(sp)
    800021f6:	ec26                	sd	s1,24(sp)
    800021f8:	e84a                	sd	s2,16(sp)
    800021fa:	e44e                	sd	s3,8(sp)
    800021fc:	1800                	add	s0,sp,48
    800021fe:	89aa                	mv	s3,a0
    80002200:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002202:	00000097          	auipc	ra,0x0
    80002206:	928080e7          	jalr	-1752(ra) # 80001b2a <myproc>
    8000220a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000220c:	fffff097          	auipc	ra,0xfffff
    80002210:	a26080e7          	jalr	-1498(ra) # 80000c32 <acquire>
  release(lk);
    80002214:	854a                	mv	a0,s2
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	ad0080e7          	jalr	-1328(ra) # 80000ce6 <release>

  // Go to sleep.
  p->chan = chan;
    8000221e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002222:	4789                	li	a5,2
    80002224:	cc9c                	sw	a5,24(s1)

  sched();
    80002226:	00000097          	auipc	ra,0x0
    8000222a:	eb8080e7          	jalr	-328(ra) # 800020de <sched>

  // Tidy up.
  p->chan = 0;
    8000222e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002232:	8526                	mv	a0,s1
    80002234:	fffff097          	auipc	ra,0xfffff
    80002238:	ab2080e7          	jalr	-1358(ra) # 80000ce6 <release>
  acquire(lk);
    8000223c:	854a                	mv	a0,s2
    8000223e:	fffff097          	auipc	ra,0xfffff
    80002242:	9f4080e7          	jalr	-1548(ra) # 80000c32 <acquire>
}
    80002246:	70a2                	ld	ra,40(sp)
    80002248:	7402                	ld	s0,32(sp)
    8000224a:	64e2                	ld	s1,24(sp)
    8000224c:	6942                	ld	s2,16(sp)
    8000224e:	69a2                	ld	s3,8(sp)
    80002250:	6145                	add	sp,sp,48
    80002252:	8082                	ret

0000000080002254 <wait>:
{
    80002254:	715d                	add	sp,sp,-80
    80002256:	e486                	sd	ra,72(sp)
    80002258:	e0a2                	sd	s0,64(sp)
    8000225a:	fc26                	sd	s1,56(sp)
    8000225c:	f84a                	sd	s2,48(sp)
    8000225e:	f44e                	sd	s3,40(sp)
    80002260:	f052                	sd	s4,32(sp)
    80002262:	ec56                	sd	s5,24(sp)
    80002264:	e85a                	sd	s6,16(sp)
    80002266:	e45e                	sd	s7,8(sp)
    80002268:	e062                	sd	s8,0(sp)
    8000226a:	0880                	add	s0,sp,80
    8000226c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000226e:	00000097          	auipc	ra,0x0
    80002272:	8bc080e7          	jalr	-1860(ra) # 80001b2a <myproc>
    80002276:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002278:	0000f517          	auipc	a0,0xf
    8000227c:	04050513          	add	a0,a0,64 # 800112b8 <wait_lock>
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	9b2080e7          	jalr	-1614(ra) # 80000c32 <acquire>
    havekids = 0;
    80002288:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000228a:	4a15                	li	s4,5
        havekids = 1;
    8000228c:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000228e:	00015997          	auipc	s3,0x15
    80002292:	e4298993          	add	s3,s3,-446 # 800170d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002296:	0000fc17          	auipc	s8,0xf
    8000229a:	022c0c13          	add	s8,s8,34 # 800112b8 <wait_lock>
    8000229e:	a87d                	j	8000235c <wait+0x108>
          pid = np->pid;
    800022a0:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022a4:	000b0e63          	beqz	s6,800022c0 <wait+0x6c>
    800022a8:	4691                	li	a3,4
    800022aa:	02c48613          	add	a2,s1,44
    800022ae:	85da                	mv	a1,s6
    800022b0:	05093503          	ld	a0,80(s2)
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	418080e7          	jalr	1048(ra) # 800016cc <copyout>
    800022bc:	04054163          	bltz	a0,800022fe <wait+0xaa>
          freeproc(np);
    800022c0:	8526                	mv	a0,s1
    800022c2:	00000097          	auipc	ra,0x0
    800022c6:	a1a080e7          	jalr	-1510(ra) # 80001cdc <freeproc>
          release(&np->lock);
    800022ca:	8526                	mv	a0,s1
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	a1a080e7          	jalr	-1510(ra) # 80000ce6 <release>
          release(&wait_lock);
    800022d4:	0000f517          	auipc	a0,0xf
    800022d8:	fe450513          	add	a0,a0,-28 # 800112b8 <wait_lock>
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	a0a080e7          	jalr	-1526(ra) # 80000ce6 <release>
}
    800022e4:	854e                	mv	a0,s3
    800022e6:	60a6                	ld	ra,72(sp)
    800022e8:	6406                	ld	s0,64(sp)
    800022ea:	74e2                	ld	s1,56(sp)
    800022ec:	7942                	ld	s2,48(sp)
    800022ee:	79a2                	ld	s3,40(sp)
    800022f0:	7a02                	ld	s4,32(sp)
    800022f2:	6ae2                	ld	s5,24(sp)
    800022f4:	6b42                	ld	s6,16(sp)
    800022f6:	6ba2                	ld	s7,8(sp)
    800022f8:	6c02                	ld	s8,0(sp)
    800022fa:	6161                	add	sp,sp,80
    800022fc:	8082                	ret
            release(&np->lock);
    800022fe:	8526                	mv	a0,s1
    80002300:	fffff097          	auipc	ra,0xfffff
    80002304:	9e6080e7          	jalr	-1562(ra) # 80000ce6 <release>
            release(&wait_lock);
    80002308:	0000f517          	auipc	a0,0xf
    8000230c:	fb050513          	add	a0,a0,-80 # 800112b8 <wait_lock>
    80002310:	fffff097          	auipc	ra,0xfffff
    80002314:	9d6080e7          	jalr	-1578(ra) # 80000ce6 <release>
            return -1;
    80002318:	59fd                	li	s3,-1
    8000231a:	b7e9                	j	800022e4 <wait+0x90>
    for(np = proc; np < &proc[NPROC]; np++){
    8000231c:	16848493          	add	s1,s1,360
    80002320:	03348463          	beq	s1,s3,80002348 <wait+0xf4>
      if(np->parent == p){
    80002324:	7c9c                	ld	a5,56(s1)
    80002326:	ff279be3          	bne	a5,s2,8000231c <wait+0xc8>
        acquire(&np->lock);
    8000232a:	8526                	mv	a0,s1
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	906080e7          	jalr	-1786(ra) # 80000c32 <acquire>
        if(np->state == ZOMBIE){
    80002334:	4c9c                	lw	a5,24(s1)
    80002336:	f74785e3          	beq	a5,s4,800022a0 <wait+0x4c>
        release(&np->lock);
    8000233a:	8526                	mv	a0,s1
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	9aa080e7          	jalr	-1622(ra) # 80000ce6 <release>
        havekids = 1;
    80002344:	8756                	mv	a4,s5
    80002346:	bfd9                	j	8000231c <wait+0xc8>
    if(!havekids || p->killed){
    80002348:	c305                	beqz	a4,80002368 <wait+0x114>
    8000234a:	02892783          	lw	a5,40(s2)
    8000234e:	ef89                	bnez	a5,80002368 <wait+0x114>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002350:	85e2                	mv	a1,s8
    80002352:	854a                	mv	a0,s2
    80002354:	00000097          	auipc	ra,0x0
    80002358:	e9c080e7          	jalr	-356(ra) # 800021f0 <sleep>
    havekids = 0;
    8000235c:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    8000235e:	0000f497          	auipc	s1,0xf
    80002362:	37248493          	add	s1,s1,882 # 800116d0 <proc>
    80002366:	bf7d                	j	80002324 <wait+0xd0>
      release(&wait_lock);
    80002368:	0000f517          	auipc	a0,0xf
    8000236c:	f5050513          	add	a0,a0,-176 # 800112b8 <wait_lock>
    80002370:	fffff097          	auipc	ra,0xfffff
    80002374:	976080e7          	jalr	-1674(ra) # 80000ce6 <release>
      return -1;
    80002378:	59fd                	li	s3,-1
    8000237a:	b7ad                	j	800022e4 <wait+0x90>

000000008000237c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000237c:	7139                	add	sp,sp,-64
    8000237e:	fc06                	sd	ra,56(sp)
    80002380:	f822                	sd	s0,48(sp)
    80002382:	f426                	sd	s1,40(sp)
    80002384:	f04a                	sd	s2,32(sp)
    80002386:	ec4e                	sd	s3,24(sp)
    80002388:	e852                	sd	s4,16(sp)
    8000238a:	e456                	sd	s5,8(sp)
    8000238c:	0080                	add	s0,sp,64
    8000238e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002390:	0000f497          	auipc	s1,0xf
    80002394:	34048493          	add	s1,s1,832 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002398:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000239a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000239c:	00015917          	auipc	s2,0x15
    800023a0:	d3490913          	add	s2,s2,-716 # 800170d0 <tickslock>
    800023a4:	a811                	j	800023b8 <wakeup+0x3c>
      }
      release(&p->lock);
    800023a6:	8526                	mv	a0,s1
    800023a8:	fffff097          	auipc	ra,0xfffff
    800023ac:	93e080e7          	jalr	-1730(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023b0:	16848493          	add	s1,s1,360
    800023b4:	03248663          	beq	s1,s2,800023e0 <wakeup+0x64>
    if(p != myproc()){
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	772080e7          	jalr	1906(ra) # 80001b2a <myproc>
    800023c0:	fea488e3          	beq	s1,a0,800023b0 <wakeup+0x34>
      acquire(&p->lock);
    800023c4:	8526                	mv	a0,s1
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	86c080e7          	jalr	-1940(ra) # 80000c32 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800023ce:	4c9c                	lw	a5,24(s1)
    800023d0:	fd379be3          	bne	a5,s3,800023a6 <wakeup+0x2a>
    800023d4:	709c                	ld	a5,32(s1)
    800023d6:	fd4798e3          	bne	a5,s4,800023a6 <wakeup+0x2a>
        p->state = RUNNABLE;
    800023da:	0154ac23          	sw	s5,24(s1)
    800023de:	b7e1                	j	800023a6 <wakeup+0x2a>
    }
  }
}
    800023e0:	70e2                	ld	ra,56(sp)
    800023e2:	7442                	ld	s0,48(sp)
    800023e4:	74a2                	ld	s1,40(sp)
    800023e6:	7902                	ld	s2,32(sp)
    800023e8:	69e2                	ld	s3,24(sp)
    800023ea:	6a42                	ld	s4,16(sp)
    800023ec:	6aa2                	ld	s5,8(sp)
    800023ee:	6121                	add	sp,sp,64
    800023f0:	8082                	ret

00000000800023f2 <reparent>:
{
    800023f2:	7179                	add	sp,sp,-48
    800023f4:	f406                	sd	ra,40(sp)
    800023f6:	f022                	sd	s0,32(sp)
    800023f8:	ec26                	sd	s1,24(sp)
    800023fa:	e84a                	sd	s2,16(sp)
    800023fc:	e44e                	sd	s3,8(sp)
    800023fe:	e052                	sd	s4,0(sp)
    80002400:	1800                	add	s0,sp,48
    80002402:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002404:	0000f497          	auipc	s1,0xf
    80002408:	2cc48493          	add	s1,s1,716 # 800116d0 <proc>
      pp->parent = initproc;
    8000240c:	00007a17          	auipc	s4,0x7
    80002410:	c1ca0a13          	add	s4,s4,-996 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002414:	00015997          	auipc	s3,0x15
    80002418:	cbc98993          	add	s3,s3,-836 # 800170d0 <tickslock>
    8000241c:	a029                	j	80002426 <reparent+0x34>
    8000241e:	16848493          	add	s1,s1,360
    80002422:	01348d63          	beq	s1,s3,8000243c <reparent+0x4a>
    if(pp->parent == p){
    80002426:	7c9c                	ld	a5,56(s1)
    80002428:	ff279be3          	bne	a5,s2,8000241e <reparent+0x2c>
      pp->parent = initproc;
    8000242c:	000a3503          	ld	a0,0(s4)
    80002430:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002432:	00000097          	auipc	ra,0x0
    80002436:	f4a080e7          	jalr	-182(ra) # 8000237c <wakeup>
    8000243a:	b7d5                	j	8000241e <reparent+0x2c>
}
    8000243c:	70a2                	ld	ra,40(sp)
    8000243e:	7402                	ld	s0,32(sp)
    80002440:	64e2                	ld	s1,24(sp)
    80002442:	6942                	ld	s2,16(sp)
    80002444:	69a2                	ld	s3,8(sp)
    80002446:	6a02                	ld	s4,0(sp)
    80002448:	6145                	add	sp,sp,48
    8000244a:	8082                	ret

000000008000244c <exit>:
{
    8000244c:	7179                	add	sp,sp,-48
    8000244e:	f406                	sd	ra,40(sp)
    80002450:	f022                	sd	s0,32(sp)
    80002452:	ec26                	sd	s1,24(sp)
    80002454:	e84a                	sd	s2,16(sp)
    80002456:	e44e                	sd	s3,8(sp)
    80002458:	e052                	sd	s4,0(sp)
    8000245a:	1800                	add	s0,sp,48
    8000245c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000245e:	fffff097          	auipc	ra,0xfffff
    80002462:	6cc080e7          	jalr	1740(ra) # 80001b2a <myproc>
    80002466:	89aa                	mv	s3,a0
  if(p == initproc)
    80002468:	00007797          	auipc	a5,0x7
    8000246c:	bc07b783          	ld	a5,-1088(a5) # 80009028 <initproc>
    80002470:	0d050493          	add	s1,a0,208
    80002474:	15050913          	add	s2,a0,336
    80002478:	02a79363          	bne	a5,a0,8000249e <exit+0x52>
    panic("init exiting");
    8000247c:	00006517          	auipc	a0,0x6
    80002480:	df450513          	add	a0,a0,-524 # 80008270 <etext+0x270>
    80002484:	ffffe097          	auipc	ra,0xffffe
    80002488:	0d6080e7          	jalr	214(ra) # 8000055a <panic>
      fileclose(f);
    8000248c:	00002097          	auipc	ra,0x2
    80002490:	282080e7          	jalr	642(ra) # 8000470e <fileclose>
      p->ofile[fd] = 0;
    80002494:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002498:	04a1                	add	s1,s1,8
    8000249a:	01248563          	beq	s1,s2,800024a4 <exit+0x58>
    if(p->ofile[fd]){
    8000249e:	6088                	ld	a0,0(s1)
    800024a0:	f575                	bnez	a0,8000248c <exit+0x40>
    800024a2:	bfdd                	j	80002498 <exit+0x4c>
  begin_op();
    800024a4:	00002097          	auipc	ra,0x2
    800024a8:	da0080e7          	jalr	-608(ra) # 80004244 <begin_op>
  iput(p->cwd);
    800024ac:	1509b503          	ld	a0,336(s3)
    800024b0:	00001097          	auipc	ra,0x1
    800024b4:	580080e7          	jalr	1408(ra) # 80003a30 <iput>
  end_op();
    800024b8:	00002097          	auipc	ra,0x2
    800024bc:	e06080e7          	jalr	-506(ra) # 800042be <end_op>
  p->cwd = 0;
    800024c0:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800024c4:	0000f497          	auipc	s1,0xf
    800024c8:	df448493          	add	s1,s1,-524 # 800112b8 <wait_lock>
    800024cc:	8526                	mv	a0,s1
    800024ce:	ffffe097          	auipc	ra,0xffffe
    800024d2:	764080e7          	jalr	1892(ra) # 80000c32 <acquire>
  reparent(p);
    800024d6:	854e                	mv	a0,s3
    800024d8:	00000097          	auipc	ra,0x0
    800024dc:	f1a080e7          	jalr	-230(ra) # 800023f2 <reparent>
  wakeup(p->parent);
    800024e0:	0389b503          	ld	a0,56(s3)
    800024e4:	00000097          	auipc	ra,0x0
    800024e8:	e98080e7          	jalr	-360(ra) # 8000237c <wakeup>
  acquire(&p->lock);
    800024ec:	854e                	mv	a0,s3
    800024ee:	ffffe097          	auipc	ra,0xffffe
    800024f2:	744080e7          	jalr	1860(ra) # 80000c32 <acquire>
  p->xstate = status;
    800024f6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800024fa:	4795                	li	a5,5
    800024fc:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002500:	8526                	mv	a0,s1
    80002502:	ffffe097          	auipc	ra,0xffffe
    80002506:	7e4080e7          	jalr	2020(ra) # 80000ce6 <release>
  sched();
    8000250a:	00000097          	auipc	ra,0x0
    8000250e:	bd4080e7          	jalr	-1068(ra) # 800020de <sched>
  panic("zombie exit");
    80002512:	00006517          	auipc	a0,0x6
    80002516:	d6e50513          	add	a0,a0,-658 # 80008280 <etext+0x280>
    8000251a:	ffffe097          	auipc	ra,0xffffe
    8000251e:	040080e7          	jalr	64(ra) # 8000055a <panic>

0000000080002522 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002522:	7179                	add	sp,sp,-48
    80002524:	f406                	sd	ra,40(sp)
    80002526:	f022                	sd	s0,32(sp)
    80002528:	ec26                	sd	s1,24(sp)
    8000252a:	e84a                	sd	s2,16(sp)
    8000252c:	e44e                	sd	s3,8(sp)
    8000252e:	1800                	add	s0,sp,48
    80002530:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002532:	0000f497          	auipc	s1,0xf
    80002536:	19e48493          	add	s1,s1,414 # 800116d0 <proc>
    8000253a:	00015997          	auipc	s3,0x15
    8000253e:	b9698993          	add	s3,s3,-1130 # 800170d0 <tickslock>
    acquire(&p->lock);
    80002542:	8526                	mv	a0,s1
    80002544:	ffffe097          	auipc	ra,0xffffe
    80002548:	6ee080e7          	jalr	1774(ra) # 80000c32 <acquire>
    if(p->pid == pid){
    8000254c:	589c                	lw	a5,48(s1)
    8000254e:	01278d63          	beq	a5,s2,80002568 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002552:	8526                	mv	a0,s1
    80002554:	ffffe097          	auipc	ra,0xffffe
    80002558:	792080e7          	jalr	1938(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000255c:	16848493          	add	s1,s1,360
    80002560:	ff3491e3          	bne	s1,s3,80002542 <kill+0x20>
  }
  return -1;
    80002564:	557d                	li	a0,-1
    80002566:	a829                	j	80002580 <kill+0x5e>
      p->killed = 1;
    80002568:	4785                	li	a5,1
    8000256a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000256c:	4c98                	lw	a4,24(s1)
    8000256e:	4789                	li	a5,2
    80002570:	00f70f63          	beq	a4,a5,8000258e <kill+0x6c>
      release(&p->lock);
    80002574:	8526                	mv	a0,s1
    80002576:	ffffe097          	auipc	ra,0xffffe
    8000257a:	770080e7          	jalr	1904(ra) # 80000ce6 <release>
      return 0;
    8000257e:	4501                	li	a0,0
}
    80002580:	70a2                	ld	ra,40(sp)
    80002582:	7402                	ld	s0,32(sp)
    80002584:	64e2                	ld	s1,24(sp)
    80002586:	6942                	ld	s2,16(sp)
    80002588:	69a2                	ld	s3,8(sp)
    8000258a:	6145                	add	sp,sp,48
    8000258c:	8082                	ret
        p->state = RUNNABLE;
    8000258e:	478d                	li	a5,3
    80002590:	cc9c                	sw	a5,24(s1)
    80002592:	b7cd                	j	80002574 <kill+0x52>

0000000080002594 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002594:	7179                	add	sp,sp,-48
    80002596:	f406                	sd	ra,40(sp)
    80002598:	f022                	sd	s0,32(sp)
    8000259a:	ec26                	sd	s1,24(sp)
    8000259c:	e84a                	sd	s2,16(sp)
    8000259e:	e44e                	sd	s3,8(sp)
    800025a0:	e052                	sd	s4,0(sp)
    800025a2:	1800                	add	s0,sp,48
    800025a4:	84aa                	mv	s1,a0
    800025a6:	892e                	mv	s2,a1
    800025a8:	89b2                	mv	s3,a2
    800025aa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025ac:	fffff097          	auipc	ra,0xfffff
    800025b0:	57e080e7          	jalr	1406(ra) # 80001b2a <myproc>
  if(user_dst){
    800025b4:	c08d                	beqz	s1,800025d6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025b6:	86d2                	mv	a3,s4
    800025b8:	864e                	mv	a2,s3
    800025ba:	85ca                	mv	a1,s2
    800025bc:	6928                	ld	a0,80(a0)
    800025be:	fffff097          	auipc	ra,0xfffff
    800025c2:	10e080e7          	jalr	270(ra) # 800016cc <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025c6:	70a2                	ld	ra,40(sp)
    800025c8:	7402                	ld	s0,32(sp)
    800025ca:	64e2                	ld	s1,24(sp)
    800025cc:	6942                	ld	s2,16(sp)
    800025ce:	69a2                	ld	s3,8(sp)
    800025d0:	6a02                	ld	s4,0(sp)
    800025d2:	6145                	add	sp,sp,48
    800025d4:	8082                	ret
    memmove((char *)dst, src, len);
    800025d6:	000a061b          	sext.w	a2,s4
    800025da:	85ce                	mv	a1,s3
    800025dc:	854a                	mv	a0,s2
    800025de:	ffffe097          	auipc	ra,0xffffe
    800025e2:	7ac080e7          	jalr	1964(ra) # 80000d8a <memmove>
    return 0;
    800025e6:	8526                	mv	a0,s1
    800025e8:	bff9                	j	800025c6 <either_copyout+0x32>

00000000800025ea <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025ea:	7179                	add	sp,sp,-48
    800025ec:	f406                	sd	ra,40(sp)
    800025ee:	f022                	sd	s0,32(sp)
    800025f0:	ec26                	sd	s1,24(sp)
    800025f2:	e84a                	sd	s2,16(sp)
    800025f4:	e44e                	sd	s3,8(sp)
    800025f6:	e052                	sd	s4,0(sp)
    800025f8:	1800                	add	s0,sp,48
    800025fa:	892a                	mv	s2,a0
    800025fc:	84ae                	mv	s1,a1
    800025fe:	89b2                	mv	s3,a2
    80002600:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002602:	fffff097          	auipc	ra,0xfffff
    80002606:	528080e7          	jalr	1320(ra) # 80001b2a <myproc>
  if(user_src){
    8000260a:	c08d                	beqz	s1,8000262c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000260c:	86d2                	mv	a3,s4
    8000260e:	864e                	mv	a2,s3
    80002610:	85ca                	mv	a1,s2
    80002612:	6928                	ld	a0,80(a0)
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	144080e7          	jalr	324(ra) # 80001758 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000261c:	70a2                	ld	ra,40(sp)
    8000261e:	7402                	ld	s0,32(sp)
    80002620:	64e2                	ld	s1,24(sp)
    80002622:	6942                	ld	s2,16(sp)
    80002624:	69a2                	ld	s3,8(sp)
    80002626:	6a02                	ld	s4,0(sp)
    80002628:	6145                	add	sp,sp,48
    8000262a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000262c:	000a061b          	sext.w	a2,s4
    80002630:	85ce                	mv	a1,s3
    80002632:	854a                	mv	a0,s2
    80002634:	ffffe097          	auipc	ra,0xffffe
    80002638:	756080e7          	jalr	1878(ra) # 80000d8a <memmove>
    return 0;
    8000263c:	8526                	mv	a0,s1
    8000263e:	bff9                	j	8000261c <either_copyin+0x32>

0000000080002640 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002640:	715d                	add	sp,sp,-80
    80002642:	e486                	sd	ra,72(sp)
    80002644:	e0a2                	sd	s0,64(sp)
    80002646:	fc26                	sd	s1,56(sp)
    80002648:	f84a                	sd	s2,48(sp)
    8000264a:	f44e                	sd	s3,40(sp)
    8000264c:	f052                	sd	s4,32(sp)
    8000264e:	ec56                	sd	s5,24(sp)
    80002650:	e85a                	sd	s6,16(sp)
    80002652:	e45e                	sd	s7,8(sp)
    80002654:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002656:	00006517          	auipc	a0,0x6
    8000265a:	9ba50513          	add	a0,a0,-1606 # 80008010 <etext+0x10>
    8000265e:	ffffe097          	auipc	ra,0xffffe
    80002662:	f46080e7          	jalr	-186(ra) # 800005a4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002666:	0000f497          	auipc	s1,0xf
    8000266a:	1c248493          	add	s1,s1,450 # 80011828 <proc+0x158>
    8000266e:	00015917          	auipc	s2,0x15
    80002672:	bba90913          	add	s2,s2,-1094 # 80017228 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002676:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002678:	00006997          	auipc	s3,0x6
    8000267c:	c1898993          	add	s3,s3,-1000 # 80008290 <etext+0x290>
    printf("%d %s %s", p->pid, state, p->name);
    80002680:	00006a97          	auipc	s5,0x6
    80002684:	c18a8a93          	add	s5,s5,-1000 # 80008298 <etext+0x298>
    printf("\n");
    80002688:	00006a17          	auipc	s4,0x6
    8000268c:	988a0a13          	add	s4,s4,-1656 # 80008010 <etext+0x10>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002690:	00006b97          	auipc	s7,0x6
    80002694:	0b0b8b93          	add	s7,s7,176 # 80008740 <states.0>
    80002698:	a00d                	j	800026ba <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000269a:	ed86a583          	lw	a1,-296(a3)
    8000269e:	8556                	mv	a0,s5
    800026a0:	ffffe097          	auipc	ra,0xffffe
    800026a4:	f04080e7          	jalr	-252(ra) # 800005a4 <printf>
    printf("\n");
    800026a8:	8552                	mv	a0,s4
    800026aa:	ffffe097          	auipc	ra,0xffffe
    800026ae:	efa080e7          	jalr	-262(ra) # 800005a4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026b2:	16848493          	add	s1,s1,360
    800026b6:	03248263          	beq	s1,s2,800026da <procdump+0x9a>
    if(p->state == UNUSED)
    800026ba:	86a6                	mv	a3,s1
    800026bc:	ec04a783          	lw	a5,-320(s1)
    800026c0:	dbed                	beqz	a5,800026b2 <procdump+0x72>
      state = "???";
    800026c2:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026c4:	fcfb6be3          	bltu	s6,a5,8000269a <procdump+0x5a>
    800026c8:	02079713          	sll	a4,a5,0x20
    800026cc:	01d75793          	srl	a5,a4,0x1d
    800026d0:	97de                	add	a5,a5,s7
    800026d2:	6390                	ld	a2,0(a5)
    800026d4:	f279                	bnez	a2,8000269a <procdump+0x5a>
      state = "???";
    800026d6:	864e                	mv	a2,s3
    800026d8:	b7c9                	j	8000269a <procdump+0x5a>
  }
}
    800026da:	60a6                	ld	ra,72(sp)
    800026dc:	6406                	ld	s0,64(sp)
    800026de:	74e2                	ld	s1,56(sp)
    800026e0:	7942                	ld	s2,48(sp)
    800026e2:	79a2                	ld	s3,40(sp)
    800026e4:	7a02                	ld	s4,32(sp)
    800026e6:	6ae2                	ld	s5,24(sp)
    800026e8:	6b42                	ld	s6,16(sp)
    800026ea:	6ba2                	ld	s7,8(sp)
    800026ec:	6161                	add	sp,sp,80
    800026ee:	8082                	ret

00000000800026f0 <swtch>:
    800026f0:	00153023          	sd	ra,0(a0)
    800026f4:	00253423          	sd	sp,8(a0)
    800026f8:	e900                	sd	s0,16(a0)
    800026fa:	ed04                	sd	s1,24(a0)
    800026fc:	03253023          	sd	s2,32(a0)
    80002700:	03353423          	sd	s3,40(a0)
    80002704:	03453823          	sd	s4,48(a0)
    80002708:	03553c23          	sd	s5,56(a0)
    8000270c:	05653023          	sd	s6,64(a0)
    80002710:	05753423          	sd	s7,72(a0)
    80002714:	05853823          	sd	s8,80(a0)
    80002718:	05953c23          	sd	s9,88(a0)
    8000271c:	07a53023          	sd	s10,96(a0)
    80002720:	07b53423          	sd	s11,104(a0)
    80002724:	0005b083          	ld	ra,0(a1)
    80002728:	0085b103          	ld	sp,8(a1)
    8000272c:	6980                	ld	s0,16(a1)
    8000272e:	6d84                	ld	s1,24(a1)
    80002730:	0205b903          	ld	s2,32(a1)
    80002734:	0285b983          	ld	s3,40(a1)
    80002738:	0305ba03          	ld	s4,48(a1)
    8000273c:	0385ba83          	ld	s5,56(a1)
    80002740:	0405bb03          	ld	s6,64(a1)
    80002744:	0485bb83          	ld	s7,72(a1)
    80002748:	0505bc03          	ld	s8,80(a1)
    8000274c:	0585bc83          	ld	s9,88(a1)
    80002750:	0605bd03          	ld	s10,96(a1)
    80002754:	0685bd83          	ld	s11,104(a1)
    80002758:	8082                	ret

000000008000275a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000275a:	1141                	add	sp,sp,-16
    8000275c:	e406                	sd	ra,8(sp)
    8000275e:	e022                	sd	s0,0(sp)
    80002760:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    80002762:	00006597          	auipc	a1,0x6
    80002766:	b6e58593          	add	a1,a1,-1170 # 800082d0 <etext+0x2d0>
    8000276a:	00015517          	auipc	a0,0x15
    8000276e:	96650513          	add	a0,a0,-1690 # 800170d0 <tickslock>
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	430080e7          	jalr	1072(ra) # 80000ba2 <initlock>
}
    8000277a:	60a2                	ld	ra,8(sp)
    8000277c:	6402                	ld	s0,0(sp)
    8000277e:	0141                	add	sp,sp,16
    80002780:	8082                	ret

0000000080002782 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002782:	1141                	add	sp,sp,-16
    80002784:	e422                	sd	s0,8(sp)
    80002786:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002788:	00003797          	auipc	a5,0x3
    8000278c:	67878793          	add	a5,a5,1656 # 80005e00 <kernelvec>
    80002790:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002794:	6422                	ld	s0,8(sp)
    80002796:	0141                	add	sp,sp,16
    80002798:	8082                	ret

000000008000279a <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000279a:	1141                	add	sp,sp,-16
    8000279c:	e406                	sd	ra,8(sp)
    8000279e:	e022                	sd	s0,0(sp)
    800027a0:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    800027a2:	fffff097          	auipc	ra,0xfffff
    800027a6:	388080e7          	jalr	904(ra) # 80001b2a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027aa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027ae:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027b0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800027b4:	00005697          	auipc	a3,0x5
    800027b8:	84c68693          	add	a3,a3,-1972 # 80007000 <_trampoline>
    800027bc:	00005717          	auipc	a4,0x5
    800027c0:	84470713          	add	a4,a4,-1980 # 80007000 <_trampoline>
    800027c4:	8f15                	sub	a4,a4,a3
    800027c6:	040007b7          	lui	a5,0x4000
    800027ca:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800027cc:	07b2                	sll	a5,a5,0xc
    800027ce:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027d0:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027d4:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027d6:	18002673          	csrr	a2,satp
    800027da:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027dc:	6d30                	ld	a2,88(a0)
    800027de:	6138                	ld	a4,64(a0)
    800027e0:	6585                	lui	a1,0x1
    800027e2:	972e                	add	a4,a4,a1
    800027e4:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027e6:	6d38                	ld	a4,88(a0)
    800027e8:	00000617          	auipc	a2,0x0
    800027ec:	14060613          	add	a2,a2,320 # 80002928 <usertrap>
    800027f0:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027f2:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027f4:	8612                	mv	a2,tp
    800027f6:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027f8:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800027fc:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002800:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002804:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002808:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000280a:	6f18                	ld	a4,24(a4)
    8000280c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002810:	692c                	ld	a1,80(a0)
    80002812:	81b1                	srl	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002814:	00005717          	auipc	a4,0x5
    80002818:	87c70713          	add	a4,a4,-1924 # 80007090 <userret>
    8000281c:	8f15                	sub	a4,a4,a3
    8000281e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002820:	577d                	li	a4,-1
    80002822:	177e                	sll	a4,a4,0x3f
    80002824:	8dd9                	or	a1,a1,a4
    80002826:	02000537          	lui	a0,0x2000
    8000282a:	157d                	add	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000282c:	0536                	sll	a0,a0,0xd
    8000282e:	9782                	jalr	a5
}
    80002830:	60a2                	ld	ra,8(sp)
    80002832:	6402                	ld	s0,0(sp)
    80002834:	0141                	add	sp,sp,16
    80002836:	8082                	ret

0000000080002838 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002838:	1101                	add	sp,sp,-32
    8000283a:	ec06                	sd	ra,24(sp)
    8000283c:	e822                	sd	s0,16(sp)
    8000283e:	e426                	sd	s1,8(sp)
    80002840:	1000                	add	s0,sp,32
  acquire(&tickslock);
    80002842:	00015497          	auipc	s1,0x15
    80002846:	88e48493          	add	s1,s1,-1906 # 800170d0 <tickslock>
    8000284a:	8526                	mv	a0,s1
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	3e6080e7          	jalr	998(ra) # 80000c32 <acquire>
  ticks++;
    80002854:	00006517          	auipc	a0,0x6
    80002858:	7dc50513          	add	a0,a0,2012 # 80009030 <ticks>
    8000285c:	411c                	lw	a5,0(a0)
    8000285e:	2785                	addw	a5,a5,1
    80002860:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002862:	00000097          	auipc	ra,0x0
    80002866:	b1a080e7          	jalr	-1254(ra) # 8000237c <wakeup>
  release(&tickslock);
    8000286a:	8526                	mv	a0,s1
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	47a080e7          	jalr	1146(ra) # 80000ce6 <release>
}
    80002874:	60e2                	ld	ra,24(sp)
    80002876:	6442                	ld	s0,16(sp)
    80002878:	64a2                	ld	s1,8(sp)
    8000287a:	6105                	add	sp,sp,32
    8000287c:	8082                	ret

000000008000287e <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000287e:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002882:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002884:	0a07d163          	bgez	a5,80002926 <devintr+0xa8>
{
    80002888:	1101                	add	sp,sp,-32
    8000288a:	ec06                	sd	ra,24(sp)
    8000288c:	e822                	sd	s0,16(sp)
    8000288e:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    80002890:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002894:	46a5                	li	a3,9
    80002896:	00d70c63          	beq	a4,a3,800028ae <devintr+0x30>
  } else if(scause == 0x8000000000000001L){
    8000289a:	577d                	li	a4,-1
    8000289c:	177e                	sll	a4,a4,0x3f
    8000289e:	0705                	add	a4,a4,1
    return 0;
    800028a0:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800028a2:	06e78163          	beq	a5,a4,80002904 <devintr+0x86>
  }
}
    800028a6:	60e2                	ld	ra,24(sp)
    800028a8:	6442                	ld	s0,16(sp)
    800028aa:	6105                	add	sp,sp,32
    800028ac:	8082                	ret
    800028ae:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800028b0:	00003097          	auipc	ra,0x3
    800028b4:	65c080e7          	jalr	1628(ra) # 80005f0c <plic_claim>
    800028b8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028ba:	47a9                	li	a5,10
    800028bc:	00f50963          	beq	a0,a5,800028ce <devintr+0x50>
    } else if(irq == VIRTIO0_IRQ){
    800028c0:	4785                	li	a5,1
    800028c2:	00f50b63          	beq	a0,a5,800028d8 <devintr+0x5a>
    return 1;
    800028c6:	4505                	li	a0,1
    } else if(irq){
    800028c8:	ec89                	bnez	s1,800028e2 <devintr+0x64>
    800028ca:	64a2                	ld	s1,8(sp)
    800028cc:	bfe9                	j	800028a6 <devintr+0x28>
      uartintr();
    800028ce:	ffffe097          	auipc	ra,0xffffe
    800028d2:	126080e7          	jalr	294(ra) # 800009f4 <uartintr>
    if(irq)
    800028d6:	a839                	j	800028f4 <devintr+0x76>
      virtio_disk_intr();
    800028d8:	00004097          	auipc	ra,0x4
    800028dc:	b08080e7          	jalr	-1272(ra) # 800063e0 <virtio_disk_intr>
    if(irq)
    800028e0:	a811                	j	800028f4 <devintr+0x76>
      printf("unexpected interrupt irq=%d\n", irq);
    800028e2:	85a6                	mv	a1,s1
    800028e4:	00006517          	auipc	a0,0x6
    800028e8:	9f450513          	add	a0,a0,-1548 # 800082d8 <etext+0x2d8>
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	cb8080e7          	jalr	-840(ra) # 800005a4 <printf>
      plic_complete(irq);
    800028f4:	8526                	mv	a0,s1
    800028f6:	00003097          	auipc	ra,0x3
    800028fa:	63a080e7          	jalr	1594(ra) # 80005f30 <plic_complete>
    return 1;
    800028fe:	4505                	li	a0,1
    80002900:	64a2                	ld	s1,8(sp)
    80002902:	b755                	j	800028a6 <devintr+0x28>
    if(cpuid() == 0){
    80002904:	fffff097          	auipc	ra,0xfffff
    80002908:	1fa080e7          	jalr	506(ra) # 80001afe <cpuid>
    8000290c:	c901                	beqz	a0,8000291c <devintr+0x9e>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000290e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002912:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002914:	14479073          	csrw	sip,a5
    return 2;
    80002918:	4509                	li	a0,2
    8000291a:	b771                	j	800028a6 <devintr+0x28>
      clockintr();
    8000291c:	00000097          	auipc	ra,0x0
    80002920:	f1c080e7          	jalr	-228(ra) # 80002838 <clockintr>
    80002924:	b7ed                	j	8000290e <devintr+0x90>
}
    80002926:	8082                	ret

0000000080002928 <usertrap>:
{
    80002928:	1101                	add	sp,sp,-32
    8000292a:	ec06                	sd	ra,24(sp)
    8000292c:	e822                	sd	s0,16(sp)
    8000292e:	e426                	sd	s1,8(sp)
    80002930:	e04a                	sd	s2,0(sp)
    80002932:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002934:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002938:	1007f793          	and	a5,a5,256
    8000293c:	e3ad                	bnez	a5,8000299e <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000293e:	00003797          	auipc	a5,0x3
    80002942:	4c278793          	add	a5,a5,1218 # 80005e00 <kernelvec>
    80002946:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000294a:	fffff097          	auipc	ra,0xfffff
    8000294e:	1e0080e7          	jalr	480(ra) # 80001b2a <myproc>
    80002952:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002954:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002956:	14102773          	csrr	a4,sepc
    8000295a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000295c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002960:	47a1                	li	a5,8
    80002962:	04f71c63          	bne	a4,a5,800029ba <usertrap+0x92>
    if(p->killed)
    80002966:	551c                	lw	a5,40(a0)
    80002968:	e3b9                	bnez	a5,800029ae <usertrap+0x86>
    p->trapframe->epc += 4;
    8000296a:	6cb8                	ld	a4,88(s1)
    8000296c:	6f1c                	ld	a5,24(a4)
    8000296e:	0791                	add	a5,a5,4
    80002970:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002972:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002976:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000297a:	10079073          	csrw	sstatus,a5
    syscall();
    8000297e:	00000097          	auipc	ra,0x0
    80002982:	2e0080e7          	jalr	736(ra) # 80002c5e <syscall>
  if(p->killed)
    80002986:	549c                	lw	a5,40(s1)
    80002988:	ebc1                	bnez	a5,80002a18 <usertrap+0xf0>
  usertrapret();
    8000298a:	00000097          	auipc	ra,0x0
    8000298e:	e10080e7          	jalr	-496(ra) # 8000279a <usertrapret>
}
    80002992:	60e2                	ld	ra,24(sp)
    80002994:	6442                	ld	s0,16(sp)
    80002996:	64a2                	ld	s1,8(sp)
    80002998:	6902                	ld	s2,0(sp)
    8000299a:	6105                	add	sp,sp,32
    8000299c:	8082                	ret
    panic("usertrap: not from user mode");
    8000299e:	00006517          	auipc	a0,0x6
    800029a2:	95a50513          	add	a0,a0,-1702 # 800082f8 <etext+0x2f8>
    800029a6:	ffffe097          	auipc	ra,0xffffe
    800029aa:	bb4080e7          	jalr	-1100(ra) # 8000055a <panic>
      exit(-1);
    800029ae:	557d                	li	a0,-1
    800029b0:	00000097          	auipc	ra,0x0
    800029b4:	a9c080e7          	jalr	-1380(ra) # 8000244c <exit>
    800029b8:	bf4d                	j	8000296a <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800029ba:	00000097          	auipc	ra,0x0
    800029be:	ec4080e7          	jalr	-316(ra) # 8000287e <devintr>
    800029c2:	892a                	mv	s2,a0
    800029c4:	c501                	beqz	a0,800029cc <usertrap+0xa4>
  if(p->killed)
    800029c6:	549c                	lw	a5,40(s1)
    800029c8:	c3a1                	beqz	a5,80002a08 <usertrap+0xe0>
    800029ca:	a815                	j	800029fe <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029cc:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029d0:	5890                	lw	a2,48(s1)
    800029d2:	00006517          	auipc	a0,0x6
    800029d6:	94650513          	add	a0,a0,-1722 # 80008318 <etext+0x318>
    800029da:	ffffe097          	auipc	ra,0xffffe
    800029de:	bca080e7          	jalr	-1078(ra) # 800005a4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029e2:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029e6:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029ea:	00006517          	auipc	a0,0x6
    800029ee:	95e50513          	add	a0,a0,-1698 # 80008348 <etext+0x348>
    800029f2:	ffffe097          	auipc	ra,0xffffe
    800029f6:	bb2080e7          	jalr	-1102(ra) # 800005a4 <printf>
    p->killed = 1;
    800029fa:	4785                	li	a5,1
    800029fc:	d49c                	sw	a5,40(s1)
    exit(-1);
    800029fe:	557d                	li	a0,-1
    80002a00:	00000097          	auipc	ra,0x0
    80002a04:	a4c080e7          	jalr	-1460(ra) # 8000244c <exit>
  if(which_dev == 2)
    80002a08:	4789                	li	a5,2
    80002a0a:	f8f910e3          	bne	s2,a5,8000298a <usertrap+0x62>
    yield();
    80002a0e:	fffff097          	auipc	ra,0xfffff
    80002a12:	7a6080e7          	jalr	1958(ra) # 800021b4 <yield>
    80002a16:	bf95                	j	8000298a <usertrap+0x62>
  int which_dev = 0;
    80002a18:	4901                	li	s2,0
    80002a1a:	b7d5                	j	800029fe <usertrap+0xd6>

0000000080002a1c <kerneltrap>:
{
    80002a1c:	7179                	add	sp,sp,-48
    80002a1e:	f406                	sd	ra,40(sp)
    80002a20:	f022                	sd	s0,32(sp)
    80002a22:	ec26                	sd	s1,24(sp)
    80002a24:	e84a                	sd	s2,16(sp)
    80002a26:	e44e                	sd	s3,8(sp)
    80002a28:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a2a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a2e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a32:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a36:	1004f793          	and	a5,s1,256
    80002a3a:	cb85                	beqz	a5,80002a6a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a3c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a40:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002a42:	ef85                	bnez	a5,80002a7a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a44:	00000097          	auipc	ra,0x0
    80002a48:	e3a080e7          	jalr	-454(ra) # 8000287e <devintr>
    80002a4c:	cd1d                	beqz	a0,80002a8a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a4e:	4789                	li	a5,2
    80002a50:	06f50a63          	beq	a0,a5,80002ac4 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a54:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a58:	10049073          	csrw	sstatus,s1
}
    80002a5c:	70a2                	ld	ra,40(sp)
    80002a5e:	7402                	ld	s0,32(sp)
    80002a60:	64e2                	ld	s1,24(sp)
    80002a62:	6942                	ld	s2,16(sp)
    80002a64:	69a2                	ld	s3,8(sp)
    80002a66:	6145                	add	sp,sp,48
    80002a68:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a6a:	00006517          	auipc	a0,0x6
    80002a6e:	8fe50513          	add	a0,a0,-1794 # 80008368 <etext+0x368>
    80002a72:	ffffe097          	auipc	ra,0xffffe
    80002a76:	ae8080e7          	jalr	-1304(ra) # 8000055a <panic>
    panic("kerneltrap: interrupts enabled");
    80002a7a:	00006517          	auipc	a0,0x6
    80002a7e:	91650513          	add	a0,a0,-1770 # 80008390 <etext+0x390>
    80002a82:	ffffe097          	auipc	ra,0xffffe
    80002a86:	ad8080e7          	jalr	-1320(ra) # 8000055a <panic>
    printf("scause %p\n", scause);
    80002a8a:	85ce                	mv	a1,s3
    80002a8c:	00006517          	auipc	a0,0x6
    80002a90:	92450513          	add	a0,a0,-1756 # 800083b0 <etext+0x3b0>
    80002a94:	ffffe097          	auipc	ra,0xffffe
    80002a98:	b10080e7          	jalr	-1264(ra) # 800005a4 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a9c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002aa0:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002aa4:	00006517          	auipc	a0,0x6
    80002aa8:	91c50513          	add	a0,a0,-1764 # 800083c0 <etext+0x3c0>
    80002aac:	ffffe097          	auipc	ra,0xffffe
    80002ab0:	af8080e7          	jalr	-1288(ra) # 800005a4 <printf>
    panic("kerneltrap");
    80002ab4:	00006517          	auipc	a0,0x6
    80002ab8:	92450513          	add	a0,a0,-1756 # 800083d8 <etext+0x3d8>
    80002abc:	ffffe097          	auipc	ra,0xffffe
    80002ac0:	a9e080e7          	jalr	-1378(ra) # 8000055a <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ac4:	fffff097          	auipc	ra,0xfffff
    80002ac8:	066080e7          	jalr	102(ra) # 80001b2a <myproc>
    80002acc:	d541                	beqz	a0,80002a54 <kerneltrap+0x38>
    80002ace:	fffff097          	auipc	ra,0xfffff
    80002ad2:	05c080e7          	jalr	92(ra) # 80001b2a <myproc>
    80002ad6:	4d18                	lw	a4,24(a0)
    80002ad8:	4791                	li	a5,4
    80002ada:	f6f71de3          	bne	a4,a5,80002a54 <kerneltrap+0x38>
    yield();
    80002ade:	fffff097          	auipc	ra,0xfffff
    80002ae2:	6d6080e7          	jalr	1750(ra) # 800021b4 <yield>
    80002ae6:	b7bd                	j	80002a54 <kerneltrap+0x38>

0000000080002ae8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ae8:	1101                	add	sp,sp,-32
    80002aea:	ec06                	sd	ra,24(sp)
    80002aec:	e822                	sd	s0,16(sp)
    80002aee:	e426                	sd	s1,8(sp)
    80002af0:	1000                	add	s0,sp,32
    80002af2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002af4:	fffff097          	auipc	ra,0xfffff
    80002af8:	036080e7          	jalr	54(ra) # 80001b2a <myproc>
  switch (n) {
    80002afc:	4795                	li	a5,5
    80002afe:	0497e163          	bltu	a5,s1,80002b40 <argraw+0x58>
    80002b02:	048a                	sll	s1,s1,0x2
    80002b04:	00006717          	auipc	a4,0x6
    80002b08:	c6c70713          	add	a4,a4,-916 # 80008770 <states.0+0x30>
    80002b0c:	94ba                	add	s1,s1,a4
    80002b0e:	409c                	lw	a5,0(s1)
    80002b10:	97ba                	add	a5,a5,a4
    80002b12:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b14:	6d3c                	ld	a5,88(a0)
    80002b16:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b18:	60e2                	ld	ra,24(sp)
    80002b1a:	6442                	ld	s0,16(sp)
    80002b1c:	64a2                	ld	s1,8(sp)
    80002b1e:	6105                	add	sp,sp,32
    80002b20:	8082                	ret
    return p->trapframe->a1;
    80002b22:	6d3c                	ld	a5,88(a0)
    80002b24:	7fa8                	ld	a0,120(a5)
    80002b26:	bfcd                	j	80002b18 <argraw+0x30>
    return p->trapframe->a2;
    80002b28:	6d3c                	ld	a5,88(a0)
    80002b2a:	63c8                	ld	a0,128(a5)
    80002b2c:	b7f5                	j	80002b18 <argraw+0x30>
    return p->trapframe->a3;
    80002b2e:	6d3c                	ld	a5,88(a0)
    80002b30:	67c8                	ld	a0,136(a5)
    80002b32:	b7dd                	j	80002b18 <argraw+0x30>
    return p->trapframe->a4;
    80002b34:	6d3c                	ld	a5,88(a0)
    80002b36:	6bc8                	ld	a0,144(a5)
    80002b38:	b7c5                	j	80002b18 <argraw+0x30>
    return p->trapframe->a5;
    80002b3a:	6d3c                	ld	a5,88(a0)
    80002b3c:	6fc8                	ld	a0,152(a5)
    80002b3e:	bfe9                	j	80002b18 <argraw+0x30>
  panic("argraw");
    80002b40:	00006517          	auipc	a0,0x6
    80002b44:	8a850513          	add	a0,a0,-1880 # 800083e8 <etext+0x3e8>
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	a12080e7          	jalr	-1518(ra) # 8000055a <panic>

0000000080002b50 <fetchaddr>:
{
    80002b50:	1101                	add	sp,sp,-32
    80002b52:	ec06                	sd	ra,24(sp)
    80002b54:	e822                	sd	s0,16(sp)
    80002b56:	e426                	sd	s1,8(sp)
    80002b58:	e04a                	sd	s2,0(sp)
    80002b5a:	1000                	add	s0,sp,32
    80002b5c:	84aa                	mv	s1,a0
    80002b5e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b60:	fffff097          	auipc	ra,0xfffff
    80002b64:	fca080e7          	jalr	-54(ra) # 80001b2a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b68:	653c                	ld	a5,72(a0)
    80002b6a:	02f4f863          	bgeu	s1,a5,80002b9a <fetchaddr+0x4a>
    80002b6e:	00848713          	add	a4,s1,8
    80002b72:	02e7e663          	bltu	a5,a4,80002b9e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b76:	46a1                	li	a3,8
    80002b78:	8626                	mv	a2,s1
    80002b7a:	85ca                	mv	a1,s2
    80002b7c:	6928                	ld	a0,80(a0)
    80002b7e:	fffff097          	auipc	ra,0xfffff
    80002b82:	bda080e7          	jalr	-1062(ra) # 80001758 <copyin>
    80002b86:	00a03533          	snez	a0,a0
    80002b8a:	40a00533          	neg	a0,a0
}
    80002b8e:	60e2                	ld	ra,24(sp)
    80002b90:	6442                	ld	s0,16(sp)
    80002b92:	64a2                	ld	s1,8(sp)
    80002b94:	6902                	ld	s2,0(sp)
    80002b96:	6105                	add	sp,sp,32
    80002b98:	8082                	ret
    return -1;
    80002b9a:	557d                	li	a0,-1
    80002b9c:	bfcd                	j	80002b8e <fetchaddr+0x3e>
    80002b9e:	557d                	li	a0,-1
    80002ba0:	b7fd                	j	80002b8e <fetchaddr+0x3e>

0000000080002ba2 <fetchstr>:
{
    80002ba2:	7179                	add	sp,sp,-48
    80002ba4:	f406                	sd	ra,40(sp)
    80002ba6:	f022                	sd	s0,32(sp)
    80002ba8:	ec26                	sd	s1,24(sp)
    80002baa:	e84a                	sd	s2,16(sp)
    80002bac:	e44e                	sd	s3,8(sp)
    80002bae:	1800                	add	s0,sp,48
    80002bb0:	892a                	mv	s2,a0
    80002bb2:	84ae                	mv	s1,a1
    80002bb4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bb6:	fffff097          	auipc	ra,0xfffff
    80002bba:	f74080e7          	jalr	-140(ra) # 80001b2a <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002bbe:	86ce                	mv	a3,s3
    80002bc0:	864a                	mv	a2,s2
    80002bc2:	85a6                	mv	a1,s1
    80002bc4:	6928                	ld	a0,80(a0)
    80002bc6:	fffff097          	auipc	ra,0xfffff
    80002bca:	c20080e7          	jalr	-992(ra) # 800017e6 <copyinstr>
  if(err < 0)
    80002bce:	00054763          	bltz	a0,80002bdc <fetchstr+0x3a>
  return strlen(buf);
    80002bd2:	8526                	mv	a0,s1
    80002bd4:	ffffe097          	auipc	ra,0xffffe
    80002bd8:	2ce080e7          	jalr	718(ra) # 80000ea2 <strlen>
}
    80002bdc:	70a2                	ld	ra,40(sp)
    80002bde:	7402                	ld	s0,32(sp)
    80002be0:	64e2                	ld	s1,24(sp)
    80002be2:	6942                	ld	s2,16(sp)
    80002be4:	69a2                	ld	s3,8(sp)
    80002be6:	6145                	add	sp,sp,48
    80002be8:	8082                	ret

0000000080002bea <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002bea:	1101                	add	sp,sp,-32
    80002bec:	ec06                	sd	ra,24(sp)
    80002bee:	e822                	sd	s0,16(sp)
    80002bf0:	e426                	sd	s1,8(sp)
    80002bf2:	1000                	add	s0,sp,32
    80002bf4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bf6:	00000097          	auipc	ra,0x0
    80002bfa:	ef2080e7          	jalr	-270(ra) # 80002ae8 <argraw>
    80002bfe:	c088                	sw	a0,0(s1)
  return 0;
}
    80002c00:	4501                	li	a0,0
    80002c02:	60e2                	ld	ra,24(sp)
    80002c04:	6442                	ld	s0,16(sp)
    80002c06:	64a2                	ld	s1,8(sp)
    80002c08:	6105                	add	sp,sp,32
    80002c0a:	8082                	ret

0000000080002c0c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002c0c:	1101                	add	sp,sp,-32
    80002c0e:	ec06                	sd	ra,24(sp)
    80002c10:	e822                	sd	s0,16(sp)
    80002c12:	e426                	sd	s1,8(sp)
    80002c14:	1000                	add	s0,sp,32
    80002c16:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c18:	00000097          	auipc	ra,0x0
    80002c1c:	ed0080e7          	jalr	-304(ra) # 80002ae8 <argraw>
    80002c20:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c22:	4501                	li	a0,0
    80002c24:	60e2                	ld	ra,24(sp)
    80002c26:	6442                	ld	s0,16(sp)
    80002c28:	64a2                	ld	s1,8(sp)
    80002c2a:	6105                	add	sp,sp,32
    80002c2c:	8082                	ret

0000000080002c2e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c2e:	1101                	add	sp,sp,-32
    80002c30:	ec06                	sd	ra,24(sp)
    80002c32:	e822                	sd	s0,16(sp)
    80002c34:	e426                	sd	s1,8(sp)
    80002c36:	e04a                	sd	s2,0(sp)
    80002c38:	1000                	add	s0,sp,32
    80002c3a:	84ae                	mv	s1,a1
    80002c3c:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c3e:	00000097          	auipc	ra,0x0
    80002c42:	eaa080e7          	jalr	-342(ra) # 80002ae8 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c46:	864a                	mv	a2,s2
    80002c48:	85a6                	mv	a1,s1
    80002c4a:	00000097          	auipc	ra,0x0
    80002c4e:	f58080e7          	jalr	-168(ra) # 80002ba2 <fetchstr>
}
    80002c52:	60e2                	ld	ra,24(sp)
    80002c54:	6442                	ld	s0,16(sp)
    80002c56:	64a2                	ld	s1,8(sp)
    80002c58:	6902                	ld	s2,0(sp)
    80002c5a:	6105                	add	sp,sp,32
    80002c5c:	8082                	ret

0000000080002c5e <syscall>:
[SYS_pageAccess] sys_pageAccess,
};

void
syscall(void)
{
    80002c5e:	1101                	add	sp,sp,-32
    80002c60:	ec06                	sd	ra,24(sp)
    80002c62:	e822                	sd	s0,16(sp)
    80002c64:	e426                	sd	s1,8(sp)
    80002c66:	e04a                	sd	s2,0(sp)
    80002c68:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c6a:	fffff097          	auipc	ra,0xfffff
    80002c6e:	ec0080e7          	jalr	-320(ra) # 80001b2a <myproc>
    80002c72:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c74:	05853903          	ld	s2,88(a0)
    80002c78:	0a893783          	ld	a5,168(s2)
    80002c7c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c80:	37fd                	addw	a5,a5,-1
    80002c82:	4755                	li	a4,21
    80002c84:	00f76f63          	bltu	a4,a5,80002ca2 <syscall+0x44>
    80002c88:	00369713          	sll	a4,a3,0x3
    80002c8c:	00006797          	auipc	a5,0x6
    80002c90:	afc78793          	add	a5,a5,-1284 # 80008788 <syscalls>
    80002c94:	97ba                	add	a5,a5,a4
    80002c96:	639c                	ld	a5,0(a5)
    80002c98:	c789                	beqz	a5,80002ca2 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002c9a:	9782                	jalr	a5
    80002c9c:	06a93823          	sd	a0,112(s2)
    80002ca0:	a839                	j	80002cbe <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ca2:	15848613          	add	a2,s1,344
    80002ca6:	588c                	lw	a1,48(s1)
    80002ca8:	00005517          	auipc	a0,0x5
    80002cac:	74850513          	add	a0,a0,1864 # 800083f0 <etext+0x3f0>
    80002cb0:	ffffe097          	auipc	ra,0xffffe
    80002cb4:	8f4080e7          	jalr	-1804(ra) # 800005a4 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002cb8:	6cbc                	ld	a5,88(s1)
    80002cba:	577d                	li	a4,-1
    80002cbc:	fbb8                	sd	a4,112(a5)
  }
}
    80002cbe:	60e2                	ld	ra,24(sp)
    80002cc0:	6442                	ld	s0,16(sp)
    80002cc2:	64a2                	ld	s1,8(sp)
    80002cc4:	6902                	ld	s2,0(sp)
    80002cc6:	6105                	add	sp,sp,32
    80002cc8:	8082                	ret

0000000080002cca <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cca:	1101                	add	sp,sp,-32
    80002ccc:	ec06                	sd	ra,24(sp)
    80002cce:	e822                	sd	s0,16(sp)
    80002cd0:	1000                	add	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002cd2:	fec40593          	add	a1,s0,-20
    80002cd6:	4501                	li	a0,0
    80002cd8:	00000097          	auipc	ra,0x0
    80002cdc:	f12080e7          	jalr	-238(ra) # 80002bea <argint>
    return -1;
    80002ce0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ce2:	00054963          	bltz	a0,80002cf4 <sys_exit+0x2a>
  exit(n);
    80002ce6:	fec42503          	lw	a0,-20(s0)
    80002cea:	fffff097          	auipc	ra,0xfffff
    80002cee:	762080e7          	jalr	1890(ra) # 8000244c <exit>
  return 0;  // not reached
    80002cf2:	4781                	li	a5,0
}
    80002cf4:	853e                	mv	a0,a5
    80002cf6:	60e2                	ld	ra,24(sp)
    80002cf8:	6442                	ld	s0,16(sp)
    80002cfa:	6105                	add	sp,sp,32
    80002cfc:	8082                	ret

0000000080002cfe <sys_getpid>:

uint64
sys_getpid(void)
{
    80002cfe:	1141                	add	sp,sp,-16
    80002d00:	e406                	sd	ra,8(sp)
    80002d02:	e022                	sd	s0,0(sp)
    80002d04:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002d06:	fffff097          	auipc	ra,0xfffff
    80002d0a:	e24080e7          	jalr	-476(ra) # 80001b2a <myproc>
}
    80002d0e:	5908                	lw	a0,48(a0)
    80002d10:	60a2                	ld	ra,8(sp)
    80002d12:	6402                	ld	s0,0(sp)
    80002d14:	0141                	add	sp,sp,16
    80002d16:	8082                	ret

0000000080002d18 <sys_fork>:

uint64
sys_fork(void)
{
    80002d18:	1141                	add	sp,sp,-16
    80002d1a:	e406                	sd	ra,8(sp)
    80002d1c:	e022                	sd	s0,0(sp)
    80002d1e:	0800                	add	s0,sp,16
  return fork();
    80002d20:	fffff097          	auipc	ra,0xfffff
    80002d24:	1dc080e7          	jalr	476(ra) # 80001efc <fork>
}
    80002d28:	60a2                	ld	ra,8(sp)
    80002d2a:	6402                	ld	s0,0(sp)
    80002d2c:	0141                	add	sp,sp,16
    80002d2e:	8082                	ret

0000000080002d30 <sys_wait>:

uint64
sys_wait(void)
{
    80002d30:	1101                	add	sp,sp,-32
    80002d32:	ec06                	sd	ra,24(sp)
    80002d34:	e822                	sd	s0,16(sp)
    80002d36:	1000                	add	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d38:	fe840593          	add	a1,s0,-24
    80002d3c:	4501                	li	a0,0
    80002d3e:	00000097          	auipc	ra,0x0
    80002d42:	ece080e7          	jalr	-306(ra) # 80002c0c <argaddr>
    80002d46:	87aa                	mv	a5,a0
    return -1;
    80002d48:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002d4a:	0007c863          	bltz	a5,80002d5a <sys_wait+0x2a>
  return wait(p);
    80002d4e:	fe843503          	ld	a0,-24(s0)
    80002d52:	fffff097          	auipc	ra,0xfffff
    80002d56:	502080e7          	jalr	1282(ra) # 80002254 <wait>
}
    80002d5a:	60e2                	ld	ra,24(sp)
    80002d5c:	6442                	ld	s0,16(sp)
    80002d5e:	6105                	add	sp,sp,32
    80002d60:	8082                	ret

0000000080002d62 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d62:	7179                	add	sp,sp,-48
    80002d64:	f406                	sd	ra,40(sp)
    80002d66:	f022                	sd	s0,32(sp)
    80002d68:	1800                	add	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002d6a:	fdc40593          	add	a1,s0,-36
    80002d6e:	4501                	li	a0,0
    80002d70:	00000097          	auipc	ra,0x0
    80002d74:	e7a080e7          	jalr	-390(ra) # 80002bea <argint>
    80002d78:	87aa                	mv	a5,a0
    return -1;
    80002d7a:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002d7c:	0207c263          	bltz	a5,80002da0 <sys_sbrk+0x3e>
    80002d80:	ec26                	sd	s1,24(sp)
  addr = myproc()->sz;
    80002d82:	fffff097          	auipc	ra,0xfffff
    80002d86:	da8080e7          	jalr	-600(ra) # 80001b2a <myproc>
    80002d8a:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002d8c:	fdc42503          	lw	a0,-36(s0)
    80002d90:	fffff097          	auipc	ra,0xfffff
    80002d94:	0f4080e7          	jalr	244(ra) # 80001e84 <growproc>
    80002d98:	00054863          	bltz	a0,80002da8 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002d9c:	8526                	mv	a0,s1
    80002d9e:	64e2                	ld	s1,24(sp)
}
    80002da0:	70a2                	ld	ra,40(sp)
    80002da2:	7402                	ld	s0,32(sp)
    80002da4:	6145                	add	sp,sp,48
    80002da6:	8082                	ret
    return -1;
    80002da8:	557d                	li	a0,-1
    80002daa:	64e2                	ld	s1,24(sp)
    80002dac:	bfd5                	j	80002da0 <sys_sbrk+0x3e>

0000000080002dae <sys_sleep>:

uint64
sys_sleep(void)
{
    80002dae:	7139                	add	sp,sp,-64
    80002db0:	fc06                	sd	ra,56(sp)
    80002db2:	f822                	sd	s0,48(sp)
    80002db4:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002db6:	fcc40593          	add	a1,s0,-52
    80002dba:	4501                	li	a0,0
    80002dbc:	00000097          	auipc	ra,0x0
    80002dc0:	e2e080e7          	jalr	-466(ra) # 80002bea <argint>
    return -1;
    80002dc4:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002dc6:	06054b63          	bltz	a0,80002e3c <sys_sleep+0x8e>
    80002dca:	f04a                	sd	s2,32(sp)
  acquire(&tickslock);
    80002dcc:	00014517          	auipc	a0,0x14
    80002dd0:	30450513          	add	a0,a0,772 # 800170d0 <tickslock>
    80002dd4:	ffffe097          	auipc	ra,0xffffe
    80002dd8:	e5e080e7          	jalr	-418(ra) # 80000c32 <acquire>
  ticks0 = ticks;
    80002ddc:	00006917          	auipc	s2,0x6
    80002de0:	25492903          	lw	s2,596(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002de4:	fcc42783          	lw	a5,-52(s0)
    80002de8:	c3a1                	beqz	a5,80002e28 <sys_sleep+0x7a>
    80002dea:	f426                	sd	s1,40(sp)
    80002dec:	ec4e                	sd	s3,24(sp)
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dee:	00014997          	auipc	s3,0x14
    80002df2:	2e298993          	add	s3,s3,738 # 800170d0 <tickslock>
    80002df6:	00006497          	auipc	s1,0x6
    80002dfa:	23a48493          	add	s1,s1,570 # 80009030 <ticks>
    if(myproc()->killed){
    80002dfe:	fffff097          	auipc	ra,0xfffff
    80002e02:	d2c080e7          	jalr	-724(ra) # 80001b2a <myproc>
    80002e06:	551c                	lw	a5,40(a0)
    80002e08:	ef9d                	bnez	a5,80002e46 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002e0a:	85ce                	mv	a1,s3
    80002e0c:	8526                	mv	a0,s1
    80002e0e:	fffff097          	auipc	ra,0xfffff
    80002e12:	3e2080e7          	jalr	994(ra) # 800021f0 <sleep>
  while(ticks - ticks0 < n){
    80002e16:	409c                	lw	a5,0(s1)
    80002e18:	412787bb          	subw	a5,a5,s2
    80002e1c:	fcc42703          	lw	a4,-52(s0)
    80002e20:	fce7efe3          	bltu	a5,a4,80002dfe <sys_sleep+0x50>
    80002e24:	74a2                	ld	s1,40(sp)
    80002e26:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002e28:	00014517          	auipc	a0,0x14
    80002e2c:	2a850513          	add	a0,a0,680 # 800170d0 <tickslock>
    80002e30:	ffffe097          	auipc	ra,0xffffe
    80002e34:	eb6080e7          	jalr	-330(ra) # 80000ce6 <release>
  return 0;
    80002e38:	4781                	li	a5,0
    80002e3a:	7902                	ld	s2,32(sp)
}
    80002e3c:	853e                	mv	a0,a5
    80002e3e:	70e2                	ld	ra,56(sp)
    80002e40:	7442                	ld	s0,48(sp)
    80002e42:	6121                	add	sp,sp,64
    80002e44:	8082                	ret
      release(&tickslock);
    80002e46:	00014517          	auipc	a0,0x14
    80002e4a:	28a50513          	add	a0,a0,650 # 800170d0 <tickslock>
    80002e4e:	ffffe097          	auipc	ra,0xffffe
    80002e52:	e98080e7          	jalr	-360(ra) # 80000ce6 <release>
      return -1;
    80002e56:	57fd                	li	a5,-1
    80002e58:	74a2                	ld	s1,40(sp)
    80002e5a:	7902                	ld	s2,32(sp)
    80002e5c:	69e2                	ld	s3,24(sp)
    80002e5e:	bff9                	j	80002e3c <sys_sleep+0x8e>

0000000080002e60 <sys_kill>:

uint64
sys_kill(void)
{
    80002e60:	1101                	add	sp,sp,-32
    80002e62:	ec06                	sd	ra,24(sp)
    80002e64:	e822                	sd	s0,16(sp)
    80002e66:	1000                	add	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002e68:	fec40593          	add	a1,s0,-20
    80002e6c:	4501                	li	a0,0
    80002e6e:	00000097          	auipc	ra,0x0
    80002e72:	d7c080e7          	jalr	-644(ra) # 80002bea <argint>
    80002e76:	87aa                	mv	a5,a0
    return -1;
    80002e78:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e7a:	0007c863          	bltz	a5,80002e8a <sys_kill+0x2a>
  return kill(pid);
    80002e7e:	fec42503          	lw	a0,-20(s0)
    80002e82:	fffff097          	auipc	ra,0xfffff
    80002e86:	6a0080e7          	jalr	1696(ra) # 80002522 <kill>
}
    80002e8a:	60e2                	ld	ra,24(sp)
    80002e8c:	6442                	ld	s0,16(sp)
    80002e8e:	6105                	add	sp,sp,32
    80002e90:	8082                	ret

0000000080002e92 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e92:	1101                	add	sp,sp,-32
    80002e94:	ec06                	sd	ra,24(sp)
    80002e96:	e822                	sd	s0,16(sp)
    80002e98:	e426                	sd	s1,8(sp)
    80002e9a:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e9c:	00014517          	auipc	a0,0x14
    80002ea0:	23450513          	add	a0,a0,564 # 800170d0 <tickslock>
    80002ea4:	ffffe097          	auipc	ra,0xffffe
    80002ea8:	d8e080e7          	jalr	-626(ra) # 80000c32 <acquire>
  xticks = ticks;
    80002eac:	00006497          	auipc	s1,0x6
    80002eb0:	1844a483          	lw	s1,388(s1) # 80009030 <ticks>
  release(&tickslock);
    80002eb4:	00014517          	auipc	a0,0x14
    80002eb8:	21c50513          	add	a0,a0,540 # 800170d0 <tickslock>
    80002ebc:	ffffe097          	auipc	ra,0xffffe
    80002ec0:	e2a080e7          	jalr	-470(ra) # 80000ce6 <release>
  return xticks;
}
    80002ec4:	02049513          	sll	a0,s1,0x20
    80002ec8:	9101                	srl	a0,a0,0x20
    80002eca:	60e2                	ld	ra,24(sp)
    80002ecc:	6442                	ld	s0,16(sp)
    80002ece:	64a2                	ld	s1,8(sp)
    80002ed0:	6105                	add	sp,sp,32
    80002ed2:	8082                	ret

0000000080002ed4 <sys_pageAccess>:

// Implementation of the pageAccess system call
// This system call checks if specific virtual memory pages have been accessed recently.
// It returns a bitmap where each bit corresponds to the access status of a page.
// Additionally, it clears the accessed (PTE_A) bit for the examined pages.
int sys_pageAccess(void) {
    80002ed4:	711d                	add	sp,sp,-96
    80002ed6:	ec86                	sd	ra,88(sp)
    80002ed8:	e8a2                	sd	s0,80(sp)
    80002eda:	1080                	add	s0,sp,96
    uint64 usrpage_ptr; // Starting virtual address provided by the user
    int npages;         // Number of pages to examine
    uint64 usraddr;     // Address to store the resulting bitmap in user space
    
    // Retrieve arguments from the system call
    argaddr(0, &usrpage_ptr);
    80002edc:	fb840593          	add	a1,s0,-72
    80002ee0:	4501                	li	a0,0
    80002ee2:	00000097          	auipc	ra,0x0
    80002ee6:	d2a080e7          	jalr	-726(ra) # 80002c0c <argaddr>
    argint(1, &npages);
    80002eea:	fb440593          	add	a1,s0,-76
    80002eee:	4505                	li	a0,1
    80002ef0:	00000097          	auipc	ra,0x0
    80002ef4:	cfa080e7          	jalr	-774(ra) # 80002bea <argint>
    argaddr(2, &usraddr);
    80002ef8:	fa840593          	add	a1,s0,-88
    80002efc:	4509                	li	a0,2
    80002efe:	00000097          	auipc	ra,0x0
    80002f02:	d0e080e7          	jalr	-754(ra) # 80002c0c <argaddr>

    struct proc* p = myproc(); // Get the current process
    80002f06:	fffff097          	auipc	ra,0xfffff
    80002f0a:	c24080e7          	jalr	-988(ra) # 80001b2a <myproc>
    unsigned long bitmap = 0;  // Initialize the bitmap to track accessed pages
    80002f0e:	fa043023          	sd	zero,-96(s0)

    // Validate the number of pages
    if (npages <= 0 || npages > 64)
    80002f12:	fb442783          	lw	a5,-76(s0)
    80002f16:	37fd                	addw	a5,a5,-1
    80002f18:	03f00713          	li	a4,63
    80002f1c:	0af76263          	bltu	a4,a5,80002fc0 <sys_pageAccess+0xec>
    80002f20:	fc4e                	sd	s3,56(sp)
    80002f22:	89aa                	mv	s3,a0
        return -1; // Return error if npages is out of bounds
  
    // Traverse the page table for the specified range
    for (int i = 0; i < npages; i++) {
        uint64 va = usrpage_ptr + i * PGSIZE; // Calculate the virtual address for the ith page
    80002f24:	fb843583          	ld	a1,-72(s0)

        // Ensure the virtual address is valid
        if (va >= MAXVA)
    80002f28:	57fd                	li	a5,-1
    80002f2a:	83e9                	srl	a5,a5,0x1a
    80002f2c:	08b7ec63          	bltu	a5,a1,80002fc4 <sys_pageAccess+0xf0>
    80002f30:	e4a6                	sd	s1,72(sp)
    80002f32:	e0ca                	sd	s2,64(sp)
    80002f34:	f852                	sd	s4,48(sp)
    80002f36:	f456                	sd	s5,40(sp)
    80002f38:	f05a                	sd	s6,32(sp)
    80002f3a:	6905                	lui	s2,0x1
    for (int i = 0; i < npages; i++) {
    80002f3c:	4481                	li	s1,0
        if ((*pte & PTE_V) == 0)
            continue; // Skip invalid pages

        // Check if the page has been accessed (PTE_A bit set)
        if (*pte & PTE_A) {
            bitmap |= (1UL << i); // Set the corresponding bit in the bitmap for the accessed page
    80002f3e:	4b05                	li	s6,1
        if (va >= MAXVA)
    80002f40:	6a85                	lui	s5,0x1
    80002f42:	8a3e                	mv	s4,a5
    80002f44:	a005                	j	80002f64 <sys_pageAccess+0x90>
        }

        // Clear the PTE_A bit to reset the access record for future checks
        *pte &= ~PTE_A;
    80002f46:	611c                	ld	a5,0(a0)
    80002f48:	fbf7f793          	and	a5,a5,-65
    80002f4c:	e11c                	sd	a5,0(a0)
    for (int i = 0; i < npages; i++) {
    80002f4e:	2485                	addw	s1,s1,1
    80002f50:	fb442783          	lw	a5,-76(s0)
    80002f54:	02f4df63          	bge	s1,a5,80002f92 <sys_pageAccess+0xbe>
        uint64 va = usrpage_ptr + i * PGSIZE; // Calculate the virtual address for the ith page
    80002f58:	fb843583          	ld	a1,-72(s0)
    80002f5c:	95ca                	add	a1,a1,s2
        if (va >= MAXVA)
    80002f5e:	9956                	add	s2,s2,s5
    80002f60:	06ba6563          	bltu	s4,a1,80002fca <sys_pageAccess+0xf6>
        pte_t *pte = walk(p->pagetable, va, 0);
    80002f64:	4601                	li	a2,0
    80002f66:	0509b503          	ld	a0,80(s3)
    80002f6a:	ffffe097          	auipc	ra,0xffffe
    80002f6e:	09c080e7          	jalr	156(ra) # 80001006 <walk>
        if (pte == 0)
    80002f72:	c525                	beqz	a0,80002fda <sys_pageAccess+0x106>
        if ((*pte & PTE_V) == 0)
    80002f74:	611c                	ld	a5,0(a0)
    80002f76:	0017f713          	and	a4,a5,1
    80002f7a:	db71                	beqz	a4,80002f4e <sys_pageAccess+0x7a>
        if (*pte & PTE_A) {
    80002f7c:	0407f793          	and	a5,a5,64
    80002f80:	d3f9                	beqz	a5,80002f46 <sys_pageAccess+0x72>
            bitmap |= (1UL << i); // Set the corresponding bit in the bitmap for the accessed page
    80002f82:	009b1733          	sll	a4,s6,s1
    80002f86:	fa043783          	ld	a5,-96(s0)
    80002f8a:	8fd9                	or	a5,a5,a4
    80002f8c:	faf43023          	sd	a5,-96(s0)
    80002f90:	bf5d                	j	80002f46 <sys_pageAccess+0x72>
    }

    // Copy the resulting bitmap to the user-space address
    if (copyout(p->pagetable, usraddr, (char*)&bitmap, sizeof(bitmap)) < 0)
    80002f92:	46a1                	li	a3,8
    80002f94:	fa040613          	add	a2,s0,-96
    80002f98:	fa843583          	ld	a1,-88(s0)
    80002f9c:	0509b503          	ld	a0,80(s3)
    80002fa0:	ffffe097          	auipc	ra,0xffffe
    80002fa4:	72c080e7          	jalr	1836(ra) # 800016cc <copyout>
    80002fa8:	41f5551b          	sraw	a0,a0,0x1f
    80002fac:	64a6                	ld	s1,72(sp)
    80002fae:	6906                	ld	s2,64(sp)
    80002fb0:	79e2                	ld	s3,56(sp)
    80002fb2:	7a42                	ld	s4,48(sp)
    80002fb4:	7aa2                	ld	s5,40(sp)
    80002fb6:	7b02                	ld	s6,32(sp)
        return -1; // Return error if the bitmap could not be copied

    return 0; // Success
}
    80002fb8:	60e6                	ld	ra,88(sp)
    80002fba:	6446                	ld	s0,80(sp)
    80002fbc:	6125                	add	sp,sp,96
    80002fbe:	8082                	ret
        return -1; // Return error if npages is out of bounds
    80002fc0:	557d                	li	a0,-1
    80002fc2:	bfdd                	j	80002fb8 <sys_pageAccess+0xe4>
            return -1; // Return error if address exceeds the maximum valid address
    80002fc4:	557d                	li	a0,-1
    80002fc6:	79e2                	ld	s3,56(sp)
    80002fc8:	bfc5                	j	80002fb8 <sys_pageAccess+0xe4>
    80002fca:	557d                	li	a0,-1
    80002fcc:	64a6                	ld	s1,72(sp)
    80002fce:	6906                	ld	s2,64(sp)
    80002fd0:	79e2                	ld	s3,56(sp)
    80002fd2:	7a42                	ld	s4,48(sp)
    80002fd4:	7aa2                	ld	s5,40(sp)
    80002fd6:	7b02                	ld	s6,32(sp)
    80002fd8:	b7c5                	j	80002fb8 <sys_pageAccess+0xe4>
            return -1; // Return error if PTE is not found
    80002fda:	557d                	li	a0,-1
    80002fdc:	64a6                	ld	s1,72(sp)
    80002fde:	6906                	ld	s2,64(sp)
    80002fe0:	79e2                	ld	s3,56(sp)
    80002fe2:	7a42                	ld	s4,48(sp)
    80002fe4:	7aa2                	ld	s5,40(sp)
    80002fe6:	7b02                	ld	s6,32(sp)
    80002fe8:	bfc1                	j	80002fb8 <sys_pageAccess+0xe4>

0000000080002fea <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002fea:	7179                	add	sp,sp,-48
    80002fec:	f406                	sd	ra,40(sp)
    80002fee:	f022                	sd	s0,32(sp)
    80002ff0:	ec26                	sd	s1,24(sp)
    80002ff2:	e84a                	sd	s2,16(sp)
    80002ff4:	e44e                	sd	s3,8(sp)
    80002ff6:	e052                	sd	s4,0(sp)
    80002ff8:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ffa:	00005597          	auipc	a1,0x5
    80002ffe:	41658593          	add	a1,a1,1046 # 80008410 <etext+0x410>
    80003002:	00014517          	auipc	a0,0x14
    80003006:	0e650513          	add	a0,a0,230 # 800170e8 <bcache>
    8000300a:	ffffe097          	auipc	ra,0xffffe
    8000300e:	b98080e7          	jalr	-1128(ra) # 80000ba2 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003012:	0001c797          	auipc	a5,0x1c
    80003016:	0d678793          	add	a5,a5,214 # 8001f0e8 <bcache+0x8000>
    8000301a:	0001c717          	auipc	a4,0x1c
    8000301e:	33670713          	add	a4,a4,822 # 8001f350 <bcache+0x8268>
    80003022:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003026:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000302a:	00014497          	auipc	s1,0x14
    8000302e:	0d648493          	add	s1,s1,214 # 80017100 <bcache+0x18>
    b->next = bcache.head.next;
    80003032:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003034:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003036:	00005a17          	auipc	s4,0x5
    8000303a:	3e2a0a13          	add	s4,s4,994 # 80008418 <etext+0x418>
    b->next = bcache.head.next;
    8000303e:	2b893783          	ld	a5,696(s2) # 12b8 <_entry-0x7fffed48>
    80003042:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003044:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003048:	85d2                	mv	a1,s4
    8000304a:	01048513          	add	a0,s1,16
    8000304e:	00001097          	auipc	ra,0x1
    80003052:	4b2080e7          	jalr	1202(ra) # 80004500 <initsleeplock>
    bcache.head.next->prev = b;
    80003056:	2b893783          	ld	a5,696(s2)
    8000305a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000305c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003060:	45848493          	add	s1,s1,1112
    80003064:	fd349de3          	bne	s1,s3,8000303e <binit+0x54>
  }
}
    80003068:	70a2                	ld	ra,40(sp)
    8000306a:	7402                	ld	s0,32(sp)
    8000306c:	64e2                	ld	s1,24(sp)
    8000306e:	6942                	ld	s2,16(sp)
    80003070:	69a2                	ld	s3,8(sp)
    80003072:	6a02                	ld	s4,0(sp)
    80003074:	6145                	add	sp,sp,48
    80003076:	8082                	ret

0000000080003078 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003078:	7179                	add	sp,sp,-48
    8000307a:	f406                	sd	ra,40(sp)
    8000307c:	f022                	sd	s0,32(sp)
    8000307e:	ec26                	sd	s1,24(sp)
    80003080:	e84a                	sd	s2,16(sp)
    80003082:	e44e                	sd	s3,8(sp)
    80003084:	1800                	add	s0,sp,48
    80003086:	892a                	mv	s2,a0
    80003088:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000308a:	00014517          	auipc	a0,0x14
    8000308e:	05e50513          	add	a0,a0,94 # 800170e8 <bcache>
    80003092:	ffffe097          	auipc	ra,0xffffe
    80003096:	ba0080e7          	jalr	-1120(ra) # 80000c32 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000309a:	0001c497          	auipc	s1,0x1c
    8000309e:	3064b483          	ld	s1,774(s1) # 8001f3a0 <bcache+0x82b8>
    800030a2:	0001c797          	auipc	a5,0x1c
    800030a6:	2ae78793          	add	a5,a5,686 # 8001f350 <bcache+0x8268>
    800030aa:	02f48f63          	beq	s1,a5,800030e8 <bread+0x70>
    800030ae:	873e                	mv	a4,a5
    800030b0:	a021                	j	800030b8 <bread+0x40>
    800030b2:	68a4                	ld	s1,80(s1)
    800030b4:	02e48a63          	beq	s1,a4,800030e8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800030b8:	449c                	lw	a5,8(s1)
    800030ba:	ff279ce3          	bne	a5,s2,800030b2 <bread+0x3a>
    800030be:	44dc                	lw	a5,12(s1)
    800030c0:	ff3799e3          	bne	a5,s3,800030b2 <bread+0x3a>
      b->refcnt++;
    800030c4:	40bc                	lw	a5,64(s1)
    800030c6:	2785                	addw	a5,a5,1
    800030c8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800030ca:	00014517          	auipc	a0,0x14
    800030ce:	01e50513          	add	a0,a0,30 # 800170e8 <bcache>
    800030d2:	ffffe097          	auipc	ra,0xffffe
    800030d6:	c14080e7          	jalr	-1004(ra) # 80000ce6 <release>
      acquiresleep(&b->lock);
    800030da:	01048513          	add	a0,s1,16
    800030de:	00001097          	auipc	ra,0x1
    800030e2:	45c080e7          	jalr	1116(ra) # 8000453a <acquiresleep>
      return b;
    800030e6:	a8b9                	j	80003144 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800030e8:	0001c497          	auipc	s1,0x1c
    800030ec:	2b04b483          	ld	s1,688(s1) # 8001f398 <bcache+0x82b0>
    800030f0:	0001c797          	auipc	a5,0x1c
    800030f4:	26078793          	add	a5,a5,608 # 8001f350 <bcache+0x8268>
    800030f8:	00f48863          	beq	s1,a5,80003108 <bread+0x90>
    800030fc:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800030fe:	40bc                	lw	a5,64(s1)
    80003100:	cf81                	beqz	a5,80003118 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003102:	64a4                	ld	s1,72(s1)
    80003104:	fee49de3          	bne	s1,a4,800030fe <bread+0x86>
  panic("bget: no buffers");
    80003108:	00005517          	auipc	a0,0x5
    8000310c:	31850513          	add	a0,a0,792 # 80008420 <etext+0x420>
    80003110:	ffffd097          	auipc	ra,0xffffd
    80003114:	44a080e7          	jalr	1098(ra) # 8000055a <panic>
      b->dev = dev;
    80003118:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000311c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003120:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003124:	4785                	li	a5,1
    80003126:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003128:	00014517          	auipc	a0,0x14
    8000312c:	fc050513          	add	a0,a0,-64 # 800170e8 <bcache>
    80003130:	ffffe097          	auipc	ra,0xffffe
    80003134:	bb6080e7          	jalr	-1098(ra) # 80000ce6 <release>
      acquiresleep(&b->lock);
    80003138:	01048513          	add	a0,s1,16
    8000313c:	00001097          	auipc	ra,0x1
    80003140:	3fe080e7          	jalr	1022(ra) # 8000453a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003144:	409c                	lw	a5,0(s1)
    80003146:	cb89                	beqz	a5,80003158 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003148:	8526                	mv	a0,s1
    8000314a:	70a2                	ld	ra,40(sp)
    8000314c:	7402                	ld	s0,32(sp)
    8000314e:	64e2                	ld	s1,24(sp)
    80003150:	6942                	ld	s2,16(sp)
    80003152:	69a2                	ld	s3,8(sp)
    80003154:	6145                	add	sp,sp,48
    80003156:	8082                	ret
    virtio_disk_rw(b, 0);
    80003158:	4581                	li	a1,0
    8000315a:	8526                	mv	a0,s1
    8000315c:	00003097          	auipc	ra,0x3
    80003160:	ff6080e7          	jalr	-10(ra) # 80006152 <virtio_disk_rw>
    b->valid = 1;
    80003164:	4785                	li	a5,1
    80003166:	c09c                	sw	a5,0(s1)
  return b;
    80003168:	b7c5                	j	80003148 <bread+0xd0>

000000008000316a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000316a:	1101                	add	sp,sp,-32
    8000316c:	ec06                	sd	ra,24(sp)
    8000316e:	e822                	sd	s0,16(sp)
    80003170:	e426                	sd	s1,8(sp)
    80003172:	1000                	add	s0,sp,32
    80003174:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003176:	0541                	add	a0,a0,16
    80003178:	00001097          	auipc	ra,0x1
    8000317c:	45c080e7          	jalr	1116(ra) # 800045d4 <holdingsleep>
    80003180:	cd01                	beqz	a0,80003198 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003182:	4585                	li	a1,1
    80003184:	8526                	mv	a0,s1
    80003186:	00003097          	auipc	ra,0x3
    8000318a:	fcc080e7          	jalr	-52(ra) # 80006152 <virtio_disk_rw>
}
    8000318e:	60e2                	ld	ra,24(sp)
    80003190:	6442                	ld	s0,16(sp)
    80003192:	64a2                	ld	s1,8(sp)
    80003194:	6105                	add	sp,sp,32
    80003196:	8082                	ret
    panic("bwrite");
    80003198:	00005517          	auipc	a0,0x5
    8000319c:	2a050513          	add	a0,a0,672 # 80008438 <etext+0x438>
    800031a0:	ffffd097          	auipc	ra,0xffffd
    800031a4:	3ba080e7          	jalr	954(ra) # 8000055a <panic>

00000000800031a8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031a8:	1101                	add	sp,sp,-32
    800031aa:	ec06                	sd	ra,24(sp)
    800031ac:	e822                	sd	s0,16(sp)
    800031ae:	e426                	sd	s1,8(sp)
    800031b0:	e04a                	sd	s2,0(sp)
    800031b2:	1000                	add	s0,sp,32
    800031b4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031b6:	01050913          	add	s2,a0,16
    800031ba:	854a                	mv	a0,s2
    800031bc:	00001097          	auipc	ra,0x1
    800031c0:	418080e7          	jalr	1048(ra) # 800045d4 <holdingsleep>
    800031c4:	c925                	beqz	a0,80003234 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800031c6:	854a                	mv	a0,s2
    800031c8:	00001097          	auipc	ra,0x1
    800031cc:	3c8080e7          	jalr	968(ra) # 80004590 <releasesleep>

  acquire(&bcache.lock);
    800031d0:	00014517          	auipc	a0,0x14
    800031d4:	f1850513          	add	a0,a0,-232 # 800170e8 <bcache>
    800031d8:	ffffe097          	auipc	ra,0xffffe
    800031dc:	a5a080e7          	jalr	-1446(ra) # 80000c32 <acquire>
  b->refcnt--;
    800031e0:	40bc                	lw	a5,64(s1)
    800031e2:	37fd                	addw	a5,a5,-1
    800031e4:	0007871b          	sext.w	a4,a5
    800031e8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800031ea:	e71d                	bnez	a4,80003218 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800031ec:	68b8                	ld	a4,80(s1)
    800031ee:	64bc                	ld	a5,72(s1)
    800031f0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800031f2:	68b8                	ld	a4,80(s1)
    800031f4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800031f6:	0001c797          	auipc	a5,0x1c
    800031fa:	ef278793          	add	a5,a5,-270 # 8001f0e8 <bcache+0x8000>
    800031fe:	2b87b703          	ld	a4,696(a5)
    80003202:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003204:	0001c717          	auipc	a4,0x1c
    80003208:	14c70713          	add	a4,a4,332 # 8001f350 <bcache+0x8268>
    8000320c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000320e:	2b87b703          	ld	a4,696(a5)
    80003212:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003214:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003218:	00014517          	auipc	a0,0x14
    8000321c:	ed050513          	add	a0,a0,-304 # 800170e8 <bcache>
    80003220:	ffffe097          	auipc	ra,0xffffe
    80003224:	ac6080e7          	jalr	-1338(ra) # 80000ce6 <release>
}
    80003228:	60e2                	ld	ra,24(sp)
    8000322a:	6442                	ld	s0,16(sp)
    8000322c:	64a2                	ld	s1,8(sp)
    8000322e:	6902                	ld	s2,0(sp)
    80003230:	6105                	add	sp,sp,32
    80003232:	8082                	ret
    panic("brelse");
    80003234:	00005517          	auipc	a0,0x5
    80003238:	20c50513          	add	a0,a0,524 # 80008440 <etext+0x440>
    8000323c:	ffffd097          	auipc	ra,0xffffd
    80003240:	31e080e7          	jalr	798(ra) # 8000055a <panic>

0000000080003244 <bpin>:

void
bpin(struct buf *b) {
    80003244:	1101                	add	sp,sp,-32
    80003246:	ec06                	sd	ra,24(sp)
    80003248:	e822                	sd	s0,16(sp)
    8000324a:	e426                	sd	s1,8(sp)
    8000324c:	1000                	add	s0,sp,32
    8000324e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003250:	00014517          	auipc	a0,0x14
    80003254:	e9850513          	add	a0,a0,-360 # 800170e8 <bcache>
    80003258:	ffffe097          	auipc	ra,0xffffe
    8000325c:	9da080e7          	jalr	-1574(ra) # 80000c32 <acquire>
  b->refcnt++;
    80003260:	40bc                	lw	a5,64(s1)
    80003262:	2785                	addw	a5,a5,1
    80003264:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003266:	00014517          	auipc	a0,0x14
    8000326a:	e8250513          	add	a0,a0,-382 # 800170e8 <bcache>
    8000326e:	ffffe097          	auipc	ra,0xffffe
    80003272:	a78080e7          	jalr	-1416(ra) # 80000ce6 <release>
}
    80003276:	60e2                	ld	ra,24(sp)
    80003278:	6442                	ld	s0,16(sp)
    8000327a:	64a2                	ld	s1,8(sp)
    8000327c:	6105                	add	sp,sp,32
    8000327e:	8082                	ret

0000000080003280 <bunpin>:

void
bunpin(struct buf *b) {
    80003280:	1101                	add	sp,sp,-32
    80003282:	ec06                	sd	ra,24(sp)
    80003284:	e822                	sd	s0,16(sp)
    80003286:	e426                	sd	s1,8(sp)
    80003288:	1000                	add	s0,sp,32
    8000328a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000328c:	00014517          	auipc	a0,0x14
    80003290:	e5c50513          	add	a0,a0,-420 # 800170e8 <bcache>
    80003294:	ffffe097          	auipc	ra,0xffffe
    80003298:	99e080e7          	jalr	-1634(ra) # 80000c32 <acquire>
  b->refcnt--;
    8000329c:	40bc                	lw	a5,64(s1)
    8000329e:	37fd                	addw	a5,a5,-1
    800032a0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032a2:	00014517          	auipc	a0,0x14
    800032a6:	e4650513          	add	a0,a0,-442 # 800170e8 <bcache>
    800032aa:	ffffe097          	auipc	ra,0xffffe
    800032ae:	a3c080e7          	jalr	-1476(ra) # 80000ce6 <release>
}
    800032b2:	60e2                	ld	ra,24(sp)
    800032b4:	6442                	ld	s0,16(sp)
    800032b6:	64a2                	ld	s1,8(sp)
    800032b8:	6105                	add	sp,sp,32
    800032ba:	8082                	ret

00000000800032bc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032bc:	1101                	add	sp,sp,-32
    800032be:	ec06                	sd	ra,24(sp)
    800032c0:	e822                	sd	s0,16(sp)
    800032c2:	e426                	sd	s1,8(sp)
    800032c4:	e04a                	sd	s2,0(sp)
    800032c6:	1000                	add	s0,sp,32
    800032c8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800032ca:	00d5d59b          	srlw	a1,a1,0xd
    800032ce:	0001c797          	auipc	a5,0x1c
    800032d2:	4f67a783          	lw	a5,1270(a5) # 8001f7c4 <sb+0x1c>
    800032d6:	9dbd                	addw	a1,a1,a5
    800032d8:	00000097          	auipc	ra,0x0
    800032dc:	da0080e7          	jalr	-608(ra) # 80003078 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800032e0:	0074f713          	and	a4,s1,7
    800032e4:	4785                	li	a5,1
    800032e6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800032ea:	14ce                	sll	s1,s1,0x33
    800032ec:	90d9                	srl	s1,s1,0x36
    800032ee:	00950733          	add	a4,a0,s1
    800032f2:	05874703          	lbu	a4,88(a4)
    800032f6:	00e7f6b3          	and	a3,a5,a4
    800032fa:	c69d                	beqz	a3,80003328 <bfree+0x6c>
    800032fc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800032fe:	94aa                	add	s1,s1,a0
    80003300:	fff7c793          	not	a5,a5
    80003304:	8f7d                	and	a4,a4,a5
    80003306:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000330a:	00001097          	auipc	ra,0x1
    8000330e:	112080e7          	jalr	274(ra) # 8000441c <log_write>
  brelse(bp);
    80003312:	854a                	mv	a0,s2
    80003314:	00000097          	auipc	ra,0x0
    80003318:	e94080e7          	jalr	-364(ra) # 800031a8 <brelse>
}
    8000331c:	60e2                	ld	ra,24(sp)
    8000331e:	6442                	ld	s0,16(sp)
    80003320:	64a2                	ld	s1,8(sp)
    80003322:	6902                	ld	s2,0(sp)
    80003324:	6105                	add	sp,sp,32
    80003326:	8082                	ret
    panic("freeing free block");
    80003328:	00005517          	auipc	a0,0x5
    8000332c:	12050513          	add	a0,a0,288 # 80008448 <etext+0x448>
    80003330:	ffffd097          	auipc	ra,0xffffd
    80003334:	22a080e7          	jalr	554(ra) # 8000055a <panic>

0000000080003338 <balloc>:
{
    80003338:	711d                	add	sp,sp,-96
    8000333a:	ec86                	sd	ra,88(sp)
    8000333c:	e8a2                	sd	s0,80(sp)
    8000333e:	e4a6                	sd	s1,72(sp)
    80003340:	e0ca                	sd	s2,64(sp)
    80003342:	fc4e                	sd	s3,56(sp)
    80003344:	f852                	sd	s4,48(sp)
    80003346:	f456                	sd	s5,40(sp)
    80003348:	f05a                	sd	s6,32(sp)
    8000334a:	ec5e                	sd	s7,24(sp)
    8000334c:	e862                	sd	s8,16(sp)
    8000334e:	e466                	sd	s9,8(sp)
    80003350:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003352:	0001c797          	auipc	a5,0x1c
    80003356:	45a7a783          	lw	a5,1114(a5) # 8001f7ac <sb+0x4>
    8000335a:	cbc1                	beqz	a5,800033ea <balloc+0xb2>
    8000335c:	8baa                	mv	s7,a0
    8000335e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003360:	0001cb17          	auipc	s6,0x1c
    80003364:	448b0b13          	add	s6,s6,1096 # 8001f7a8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003368:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000336a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000336c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000336e:	6c89                	lui	s9,0x2
    80003370:	a831                	j	8000338c <balloc+0x54>
    brelse(bp);
    80003372:	854a                	mv	a0,s2
    80003374:	00000097          	auipc	ra,0x0
    80003378:	e34080e7          	jalr	-460(ra) # 800031a8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000337c:	015c87bb          	addw	a5,s9,s5
    80003380:	00078a9b          	sext.w	s5,a5
    80003384:	004b2703          	lw	a4,4(s6)
    80003388:	06eaf163          	bgeu	s5,a4,800033ea <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    8000338c:	41fad79b          	sraw	a5,s5,0x1f
    80003390:	0137d79b          	srlw	a5,a5,0x13
    80003394:	015787bb          	addw	a5,a5,s5
    80003398:	40d7d79b          	sraw	a5,a5,0xd
    8000339c:	01cb2583          	lw	a1,28(s6)
    800033a0:	9dbd                	addw	a1,a1,a5
    800033a2:	855e                	mv	a0,s7
    800033a4:	00000097          	auipc	ra,0x0
    800033a8:	cd4080e7          	jalr	-812(ra) # 80003078 <bread>
    800033ac:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033ae:	004b2503          	lw	a0,4(s6)
    800033b2:	000a849b          	sext.w	s1,s5
    800033b6:	8762                	mv	a4,s8
    800033b8:	faa4fde3          	bgeu	s1,a0,80003372 <balloc+0x3a>
      m = 1 << (bi % 8);
    800033bc:	00777693          	and	a3,a4,7
    800033c0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800033c4:	41f7579b          	sraw	a5,a4,0x1f
    800033c8:	01d7d79b          	srlw	a5,a5,0x1d
    800033cc:	9fb9                	addw	a5,a5,a4
    800033ce:	4037d79b          	sraw	a5,a5,0x3
    800033d2:	00f90633          	add	a2,s2,a5
    800033d6:	05864603          	lbu	a2,88(a2)
    800033da:	00c6f5b3          	and	a1,a3,a2
    800033de:	cd91                	beqz	a1,800033fa <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033e0:	2705                	addw	a4,a4,1
    800033e2:	2485                	addw	s1,s1,1
    800033e4:	fd471ae3          	bne	a4,s4,800033b8 <balloc+0x80>
    800033e8:	b769                	j	80003372 <balloc+0x3a>
  panic("balloc: out of blocks");
    800033ea:	00005517          	auipc	a0,0x5
    800033ee:	07650513          	add	a0,a0,118 # 80008460 <etext+0x460>
    800033f2:	ffffd097          	auipc	ra,0xffffd
    800033f6:	168080e7          	jalr	360(ra) # 8000055a <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033fa:	97ca                	add	a5,a5,s2
    800033fc:	8e55                	or	a2,a2,a3
    800033fe:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003402:	854a                	mv	a0,s2
    80003404:	00001097          	auipc	ra,0x1
    80003408:	018080e7          	jalr	24(ra) # 8000441c <log_write>
        brelse(bp);
    8000340c:	854a                	mv	a0,s2
    8000340e:	00000097          	auipc	ra,0x0
    80003412:	d9a080e7          	jalr	-614(ra) # 800031a8 <brelse>
  bp = bread(dev, bno);
    80003416:	85a6                	mv	a1,s1
    80003418:	855e                	mv	a0,s7
    8000341a:	00000097          	auipc	ra,0x0
    8000341e:	c5e080e7          	jalr	-930(ra) # 80003078 <bread>
    80003422:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003424:	40000613          	li	a2,1024
    80003428:	4581                	li	a1,0
    8000342a:	05850513          	add	a0,a0,88
    8000342e:	ffffe097          	auipc	ra,0xffffe
    80003432:	900080e7          	jalr	-1792(ra) # 80000d2e <memset>
  log_write(bp);
    80003436:	854a                	mv	a0,s2
    80003438:	00001097          	auipc	ra,0x1
    8000343c:	fe4080e7          	jalr	-28(ra) # 8000441c <log_write>
  brelse(bp);
    80003440:	854a                	mv	a0,s2
    80003442:	00000097          	auipc	ra,0x0
    80003446:	d66080e7          	jalr	-666(ra) # 800031a8 <brelse>
}
    8000344a:	8526                	mv	a0,s1
    8000344c:	60e6                	ld	ra,88(sp)
    8000344e:	6446                	ld	s0,80(sp)
    80003450:	64a6                	ld	s1,72(sp)
    80003452:	6906                	ld	s2,64(sp)
    80003454:	79e2                	ld	s3,56(sp)
    80003456:	7a42                	ld	s4,48(sp)
    80003458:	7aa2                	ld	s5,40(sp)
    8000345a:	7b02                	ld	s6,32(sp)
    8000345c:	6be2                	ld	s7,24(sp)
    8000345e:	6c42                	ld	s8,16(sp)
    80003460:	6ca2                	ld	s9,8(sp)
    80003462:	6125                	add	sp,sp,96
    80003464:	8082                	ret

0000000080003466 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003466:	7179                	add	sp,sp,-48
    80003468:	f406                	sd	ra,40(sp)
    8000346a:	f022                	sd	s0,32(sp)
    8000346c:	ec26                	sd	s1,24(sp)
    8000346e:	e84a                	sd	s2,16(sp)
    80003470:	e44e                	sd	s3,8(sp)
    80003472:	1800                	add	s0,sp,48
    80003474:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003476:	47ad                	li	a5,11
    80003478:	04b7ff63          	bgeu	a5,a1,800034d6 <bmap+0x70>
    8000347c:	e052                	sd	s4,0(sp)
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000347e:	ff45849b          	addw	s1,a1,-12
    80003482:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003486:	0ff00793          	li	a5,255
    8000348a:	0ae7e463          	bltu	a5,a4,80003532 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000348e:	08052583          	lw	a1,128(a0)
    80003492:	c5b5                	beqz	a1,800034fe <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003494:	00092503          	lw	a0,0(s2)
    80003498:	00000097          	auipc	ra,0x0
    8000349c:	be0080e7          	jalr	-1056(ra) # 80003078 <bread>
    800034a0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800034a2:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    800034a6:	02049713          	sll	a4,s1,0x20
    800034aa:	01e75593          	srl	a1,a4,0x1e
    800034ae:	00b784b3          	add	s1,a5,a1
    800034b2:	0004a983          	lw	s3,0(s1)
    800034b6:	04098e63          	beqz	s3,80003512 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800034ba:	8552                	mv	a0,s4
    800034bc:	00000097          	auipc	ra,0x0
    800034c0:	cec080e7          	jalr	-788(ra) # 800031a8 <brelse>
    return addr;
    800034c4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800034c6:	854e                	mv	a0,s3
    800034c8:	70a2                	ld	ra,40(sp)
    800034ca:	7402                	ld	s0,32(sp)
    800034cc:	64e2                	ld	s1,24(sp)
    800034ce:	6942                	ld	s2,16(sp)
    800034d0:	69a2                	ld	s3,8(sp)
    800034d2:	6145                	add	sp,sp,48
    800034d4:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800034d6:	02059793          	sll	a5,a1,0x20
    800034da:	01e7d593          	srl	a1,a5,0x1e
    800034de:	00b504b3          	add	s1,a0,a1
    800034e2:	0504a983          	lw	s3,80(s1)
    800034e6:	fe0990e3          	bnez	s3,800034c6 <bmap+0x60>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800034ea:	4108                	lw	a0,0(a0)
    800034ec:	00000097          	auipc	ra,0x0
    800034f0:	e4c080e7          	jalr	-436(ra) # 80003338 <balloc>
    800034f4:	0005099b          	sext.w	s3,a0
    800034f8:	0534a823          	sw	s3,80(s1)
    800034fc:	b7e9                	j	800034c6 <bmap+0x60>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800034fe:	4108                	lw	a0,0(a0)
    80003500:	00000097          	auipc	ra,0x0
    80003504:	e38080e7          	jalr	-456(ra) # 80003338 <balloc>
    80003508:	0005059b          	sext.w	a1,a0
    8000350c:	08b92023          	sw	a1,128(s2)
    80003510:	b751                	j	80003494 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003512:	00092503          	lw	a0,0(s2)
    80003516:	00000097          	auipc	ra,0x0
    8000351a:	e22080e7          	jalr	-478(ra) # 80003338 <balloc>
    8000351e:	0005099b          	sext.w	s3,a0
    80003522:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003526:	8552                	mv	a0,s4
    80003528:	00001097          	auipc	ra,0x1
    8000352c:	ef4080e7          	jalr	-268(ra) # 8000441c <log_write>
    80003530:	b769                	j	800034ba <bmap+0x54>
  panic("bmap: out of range");
    80003532:	00005517          	auipc	a0,0x5
    80003536:	f4650513          	add	a0,a0,-186 # 80008478 <etext+0x478>
    8000353a:	ffffd097          	auipc	ra,0xffffd
    8000353e:	020080e7          	jalr	32(ra) # 8000055a <panic>

0000000080003542 <iget>:
{
    80003542:	7179                	add	sp,sp,-48
    80003544:	f406                	sd	ra,40(sp)
    80003546:	f022                	sd	s0,32(sp)
    80003548:	ec26                	sd	s1,24(sp)
    8000354a:	e84a                	sd	s2,16(sp)
    8000354c:	e44e                	sd	s3,8(sp)
    8000354e:	e052                	sd	s4,0(sp)
    80003550:	1800                	add	s0,sp,48
    80003552:	89aa                	mv	s3,a0
    80003554:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003556:	0001c517          	auipc	a0,0x1c
    8000355a:	27250513          	add	a0,a0,626 # 8001f7c8 <itable>
    8000355e:	ffffd097          	auipc	ra,0xffffd
    80003562:	6d4080e7          	jalr	1748(ra) # 80000c32 <acquire>
  empty = 0;
    80003566:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003568:	0001c497          	auipc	s1,0x1c
    8000356c:	27848493          	add	s1,s1,632 # 8001f7e0 <itable+0x18>
    80003570:	0001e697          	auipc	a3,0x1e
    80003574:	d0068693          	add	a3,a3,-768 # 80021270 <log>
    80003578:	a039                	j	80003586 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000357a:	02090b63          	beqz	s2,800035b0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000357e:	08848493          	add	s1,s1,136
    80003582:	02d48a63          	beq	s1,a3,800035b6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003586:	449c                	lw	a5,8(s1)
    80003588:	fef059e3          	blez	a5,8000357a <iget+0x38>
    8000358c:	4098                	lw	a4,0(s1)
    8000358e:	ff3716e3          	bne	a4,s3,8000357a <iget+0x38>
    80003592:	40d8                	lw	a4,4(s1)
    80003594:	ff4713e3          	bne	a4,s4,8000357a <iget+0x38>
      ip->ref++;
    80003598:	2785                	addw	a5,a5,1
    8000359a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000359c:	0001c517          	auipc	a0,0x1c
    800035a0:	22c50513          	add	a0,a0,556 # 8001f7c8 <itable>
    800035a4:	ffffd097          	auipc	ra,0xffffd
    800035a8:	742080e7          	jalr	1858(ra) # 80000ce6 <release>
      return ip;
    800035ac:	8926                	mv	s2,s1
    800035ae:	a03d                	j	800035dc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035b0:	f7f9                	bnez	a5,8000357e <iget+0x3c>
      empty = ip;
    800035b2:	8926                	mv	s2,s1
    800035b4:	b7e9                	j	8000357e <iget+0x3c>
  if(empty == 0)
    800035b6:	02090c63          	beqz	s2,800035ee <iget+0xac>
  ip->dev = dev;
    800035ba:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035be:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035c2:	4785                	li	a5,1
    800035c4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035c8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800035cc:	0001c517          	auipc	a0,0x1c
    800035d0:	1fc50513          	add	a0,a0,508 # 8001f7c8 <itable>
    800035d4:	ffffd097          	auipc	ra,0xffffd
    800035d8:	712080e7          	jalr	1810(ra) # 80000ce6 <release>
}
    800035dc:	854a                	mv	a0,s2
    800035de:	70a2                	ld	ra,40(sp)
    800035e0:	7402                	ld	s0,32(sp)
    800035e2:	64e2                	ld	s1,24(sp)
    800035e4:	6942                	ld	s2,16(sp)
    800035e6:	69a2                	ld	s3,8(sp)
    800035e8:	6a02                	ld	s4,0(sp)
    800035ea:	6145                	add	sp,sp,48
    800035ec:	8082                	ret
    panic("iget: no inodes");
    800035ee:	00005517          	auipc	a0,0x5
    800035f2:	ea250513          	add	a0,a0,-350 # 80008490 <etext+0x490>
    800035f6:	ffffd097          	auipc	ra,0xffffd
    800035fa:	f64080e7          	jalr	-156(ra) # 8000055a <panic>

00000000800035fe <fsinit>:
fsinit(int dev) {
    800035fe:	7179                	add	sp,sp,-48
    80003600:	f406                	sd	ra,40(sp)
    80003602:	f022                	sd	s0,32(sp)
    80003604:	ec26                	sd	s1,24(sp)
    80003606:	e84a                	sd	s2,16(sp)
    80003608:	e44e                	sd	s3,8(sp)
    8000360a:	1800                	add	s0,sp,48
    8000360c:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000360e:	4585                	li	a1,1
    80003610:	00000097          	auipc	ra,0x0
    80003614:	a68080e7          	jalr	-1432(ra) # 80003078 <bread>
    80003618:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000361a:	0001c997          	auipc	s3,0x1c
    8000361e:	18e98993          	add	s3,s3,398 # 8001f7a8 <sb>
    80003622:	02000613          	li	a2,32
    80003626:	05850593          	add	a1,a0,88
    8000362a:	854e                	mv	a0,s3
    8000362c:	ffffd097          	auipc	ra,0xffffd
    80003630:	75e080e7          	jalr	1886(ra) # 80000d8a <memmove>
  brelse(bp);
    80003634:	8526                	mv	a0,s1
    80003636:	00000097          	auipc	ra,0x0
    8000363a:	b72080e7          	jalr	-1166(ra) # 800031a8 <brelse>
  if(sb.magic != FSMAGIC)
    8000363e:	0009a703          	lw	a4,0(s3)
    80003642:	102037b7          	lui	a5,0x10203
    80003646:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000364a:	02f71263          	bne	a4,a5,8000366e <fsinit+0x70>
  initlog(dev, &sb);
    8000364e:	0001c597          	auipc	a1,0x1c
    80003652:	15a58593          	add	a1,a1,346 # 8001f7a8 <sb>
    80003656:	854a                	mv	a0,s2
    80003658:	00001097          	auipc	ra,0x1
    8000365c:	b54080e7          	jalr	-1196(ra) # 800041ac <initlog>
}
    80003660:	70a2                	ld	ra,40(sp)
    80003662:	7402                	ld	s0,32(sp)
    80003664:	64e2                	ld	s1,24(sp)
    80003666:	6942                	ld	s2,16(sp)
    80003668:	69a2                	ld	s3,8(sp)
    8000366a:	6145                	add	sp,sp,48
    8000366c:	8082                	ret
    panic("invalid file system");
    8000366e:	00005517          	auipc	a0,0x5
    80003672:	e3250513          	add	a0,a0,-462 # 800084a0 <etext+0x4a0>
    80003676:	ffffd097          	auipc	ra,0xffffd
    8000367a:	ee4080e7          	jalr	-284(ra) # 8000055a <panic>

000000008000367e <iinit>:
{
    8000367e:	7179                	add	sp,sp,-48
    80003680:	f406                	sd	ra,40(sp)
    80003682:	f022                	sd	s0,32(sp)
    80003684:	ec26                	sd	s1,24(sp)
    80003686:	e84a                	sd	s2,16(sp)
    80003688:	e44e                	sd	s3,8(sp)
    8000368a:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    8000368c:	00005597          	auipc	a1,0x5
    80003690:	e2c58593          	add	a1,a1,-468 # 800084b8 <etext+0x4b8>
    80003694:	0001c517          	auipc	a0,0x1c
    80003698:	13450513          	add	a0,a0,308 # 8001f7c8 <itable>
    8000369c:	ffffd097          	auipc	ra,0xffffd
    800036a0:	506080e7          	jalr	1286(ra) # 80000ba2 <initlock>
  for(i = 0; i < NINODE; i++) {
    800036a4:	0001c497          	auipc	s1,0x1c
    800036a8:	14c48493          	add	s1,s1,332 # 8001f7f0 <itable+0x28>
    800036ac:	0001e997          	auipc	s3,0x1e
    800036b0:	bd498993          	add	s3,s3,-1068 # 80021280 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036b4:	00005917          	auipc	s2,0x5
    800036b8:	e0c90913          	add	s2,s2,-500 # 800084c0 <etext+0x4c0>
    800036bc:	85ca                	mv	a1,s2
    800036be:	8526                	mv	a0,s1
    800036c0:	00001097          	auipc	ra,0x1
    800036c4:	e40080e7          	jalr	-448(ra) # 80004500 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036c8:	08848493          	add	s1,s1,136
    800036cc:	ff3498e3          	bne	s1,s3,800036bc <iinit+0x3e>
}
    800036d0:	70a2                	ld	ra,40(sp)
    800036d2:	7402                	ld	s0,32(sp)
    800036d4:	64e2                	ld	s1,24(sp)
    800036d6:	6942                	ld	s2,16(sp)
    800036d8:	69a2                	ld	s3,8(sp)
    800036da:	6145                	add	sp,sp,48
    800036dc:	8082                	ret

00000000800036de <ialloc>:
{
    800036de:	7139                	add	sp,sp,-64
    800036e0:	fc06                	sd	ra,56(sp)
    800036e2:	f822                	sd	s0,48(sp)
    800036e4:	f426                	sd	s1,40(sp)
    800036e6:	f04a                	sd	s2,32(sp)
    800036e8:	ec4e                	sd	s3,24(sp)
    800036ea:	e852                	sd	s4,16(sp)
    800036ec:	e456                	sd	s5,8(sp)
    800036ee:	e05a                	sd	s6,0(sp)
    800036f0:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800036f2:	0001c717          	auipc	a4,0x1c
    800036f6:	0c272703          	lw	a4,194(a4) # 8001f7b4 <sb+0xc>
    800036fa:	4785                	li	a5,1
    800036fc:	04e7f863          	bgeu	a5,a4,8000374c <ialloc+0x6e>
    80003700:	8aaa                	mv	s5,a0
    80003702:	8b2e                	mv	s6,a1
    80003704:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003706:	0001ca17          	auipc	s4,0x1c
    8000370a:	0a2a0a13          	add	s4,s4,162 # 8001f7a8 <sb>
    8000370e:	00495593          	srl	a1,s2,0x4
    80003712:	018a2783          	lw	a5,24(s4)
    80003716:	9dbd                	addw	a1,a1,a5
    80003718:	8556                	mv	a0,s5
    8000371a:	00000097          	auipc	ra,0x0
    8000371e:	95e080e7          	jalr	-1698(ra) # 80003078 <bread>
    80003722:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003724:	05850993          	add	s3,a0,88
    80003728:	00f97793          	and	a5,s2,15
    8000372c:	079a                	sll	a5,a5,0x6
    8000372e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003730:	00099783          	lh	a5,0(s3)
    80003734:	c785                	beqz	a5,8000375c <ialloc+0x7e>
    brelse(bp);
    80003736:	00000097          	auipc	ra,0x0
    8000373a:	a72080e7          	jalr	-1422(ra) # 800031a8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000373e:	0905                	add	s2,s2,1
    80003740:	00ca2703          	lw	a4,12(s4)
    80003744:	0009079b          	sext.w	a5,s2
    80003748:	fce7e3e3          	bltu	a5,a4,8000370e <ialloc+0x30>
  panic("ialloc: no inodes");
    8000374c:	00005517          	auipc	a0,0x5
    80003750:	d7c50513          	add	a0,a0,-644 # 800084c8 <etext+0x4c8>
    80003754:	ffffd097          	auipc	ra,0xffffd
    80003758:	e06080e7          	jalr	-506(ra) # 8000055a <panic>
      memset(dip, 0, sizeof(*dip));
    8000375c:	04000613          	li	a2,64
    80003760:	4581                	li	a1,0
    80003762:	854e                	mv	a0,s3
    80003764:	ffffd097          	auipc	ra,0xffffd
    80003768:	5ca080e7          	jalr	1482(ra) # 80000d2e <memset>
      dip->type = type;
    8000376c:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003770:	8526                	mv	a0,s1
    80003772:	00001097          	auipc	ra,0x1
    80003776:	caa080e7          	jalr	-854(ra) # 8000441c <log_write>
      brelse(bp);
    8000377a:	8526                	mv	a0,s1
    8000377c:	00000097          	auipc	ra,0x0
    80003780:	a2c080e7          	jalr	-1492(ra) # 800031a8 <brelse>
      return iget(dev, inum);
    80003784:	0009059b          	sext.w	a1,s2
    80003788:	8556                	mv	a0,s5
    8000378a:	00000097          	auipc	ra,0x0
    8000378e:	db8080e7          	jalr	-584(ra) # 80003542 <iget>
}
    80003792:	70e2                	ld	ra,56(sp)
    80003794:	7442                	ld	s0,48(sp)
    80003796:	74a2                	ld	s1,40(sp)
    80003798:	7902                	ld	s2,32(sp)
    8000379a:	69e2                	ld	s3,24(sp)
    8000379c:	6a42                	ld	s4,16(sp)
    8000379e:	6aa2                	ld	s5,8(sp)
    800037a0:	6b02                	ld	s6,0(sp)
    800037a2:	6121                	add	sp,sp,64
    800037a4:	8082                	ret

00000000800037a6 <iupdate>:
{
    800037a6:	1101                	add	sp,sp,-32
    800037a8:	ec06                	sd	ra,24(sp)
    800037aa:	e822                	sd	s0,16(sp)
    800037ac:	e426                	sd	s1,8(sp)
    800037ae:	e04a                	sd	s2,0(sp)
    800037b0:	1000                	add	s0,sp,32
    800037b2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037b4:	415c                	lw	a5,4(a0)
    800037b6:	0047d79b          	srlw	a5,a5,0x4
    800037ba:	0001c597          	auipc	a1,0x1c
    800037be:	0065a583          	lw	a1,6(a1) # 8001f7c0 <sb+0x18>
    800037c2:	9dbd                	addw	a1,a1,a5
    800037c4:	4108                	lw	a0,0(a0)
    800037c6:	00000097          	auipc	ra,0x0
    800037ca:	8b2080e7          	jalr	-1870(ra) # 80003078 <bread>
    800037ce:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037d0:	05850793          	add	a5,a0,88
    800037d4:	40d8                	lw	a4,4(s1)
    800037d6:	8b3d                	and	a4,a4,15
    800037d8:	071a                	sll	a4,a4,0x6
    800037da:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800037dc:	04449703          	lh	a4,68(s1)
    800037e0:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800037e4:	04649703          	lh	a4,70(s1)
    800037e8:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800037ec:	04849703          	lh	a4,72(s1)
    800037f0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800037f4:	04a49703          	lh	a4,74(s1)
    800037f8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800037fc:	44f8                	lw	a4,76(s1)
    800037fe:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003800:	03400613          	li	a2,52
    80003804:	05048593          	add	a1,s1,80
    80003808:	00c78513          	add	a0,a5,12
    8000380c:	ffffd097          	auipc	ra,0xffffd
    80003810:	57e080e7          	jalr	1406(ra) # 80000d8a <memmove>
  log_write(bp);
    80003814:	854a                	mv	a0,s2
    80003816:	00001097          	auipc	ra,0x1
    8000381a:	c06080e7          	jalr	-1018(ra) # 8000441c <log_write>
  brelse(bp);
    8000381e:	854a                	mv	a0,s2
    80003820:	00000097          	auipc	ra,0x0
    80003824:	988080e7          	jalr	-1656(ra) # 800031a8 <brelse>
}
    80003828:	60e2                	ld	ra,24(sp)
    8000382a:	6442                	ld	s0,16(sp)
    8000382c:	64a2                	ld	s1,8(sp)
    8000382e:	6902                	ld	s2,0(sp)
    80003830:	6105                	add	sp,sp,32
    80003832:	8082                	ret

0000000080003834 <idup>:
{
    80003834:	1101                	add	sp,sp,-32
    80003836:	ec06                	sd	ra,24(sp)
    80003838:	e822                	sd	s0,16(sp)
    8000383a:	e426                	sd	s1,8(sp)
    8000383c:	1000                	add	s0,sp,32
    8000383e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003840:	0001c517          	auipc	a0,0x1c
    80003844:	f8850513          	add	a0,a0,-120 # 8001f7c8 <itable>
    80003848:	ffffd097          	auipc	ra,0xffffd
    8000384c:	3ea080e7          	jalr	1002(ra) # 80000c32 <acquire>
  ip->ref++;
    80003850:	449c                	lw	a5,8(s1)
    80003852:	2785                	addw	a5,a5,1
    80003854:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003856:	0001c517          	auipc	a0,0x1c
    8000385a:	f7250513          	add	a0,a0,-142 # 8001f7c8 <itable>
    8000385e:	ffffd097          	auipc	ra,0xffffd
    80003862:	488080e7          	jalr	1160(ra) # 80000ce6 <release>
}
    80003866:	8526                	mv	a0,s1
    80003868:	60e2                	ld	ra,24(sp)
    8000386a:	6442                	ld	s0,16(sp)
    8000386c:	64a2                	ld	s1,8(sp)
    8000386e:	6105                	add	sp,sp,32
    80003870:	8082                	ret

0000000080003872 <ilock>:
{
    80003872:	1101                	add	sp,sp,-32
    80003874:	ec06                	sd	ra,24(sp)
    80003876:	e822                	sd	s0,16(sp)
    80003878:	e426                	sd	s1,8(sp)
    8000387a:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000387c:	c10d                	beqz	a0,8000389e <ilock+0x2c>
    8000387e:	84aa                	mv	s1,a0
    80003880:	451c                	lw	a5,8(a0)
    80003882:	00f05e63          	blez	a5,8000389e <ilock+0x2c>
  acquiresleep(&ip->lock);
    80003886:	0541                	add	a0,a0,16
    80003888:	00001097          	auipc	ra,0x1
    8000388c:	cb2080e7          	jalr	-846(ra) # 8000453a <acquiresleep>
  if(ip->valid == 0){
    80003890:	40bc                	lw	a5,64(s1)
    80003892:	cf99                	beqz	a5,800038b0 <ilock+0x3e>
}
    80003894:	60e2                	ld	ra,24(sp)
    80003896:	6442                	ld	s0,16(sp)
    80003898:	64a2                	ld	s1,8(sp)
    8000389a:	6105                	add	sp,sp,32
    8000389c:	8082                	ret
    8000389e:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800038a0:	00005517          	auipc	a0,0x5
    800038a4:	c4050513          	add	a0,a0,-960 # 800084e0 <etext+0x4e0>
    800038a8:	ffffd097          	auipc	ra,0xffffd
    800038ac:	cb2080e7          	jalr	-846(ra) # 8000055a <panic>
    800038b0:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800038b2:	40dc                	lw	a5,4(s1)
    800038b4:	0047d79b          	srlw	a5,a5,0x4
    800038b8:	0001c597          	auipc	a1,0x1c
    800038bc:	f085a583          	lw	a1,-248(a1) # 8001f7c0 <sb+0x18>
    800038c0:	9dbd                	addw	a1,a1,a5
    800038c2:	4088                	lw	a0,0(s1)
    800038c4:	fffff097          	auipc	ra,0xfffff
    800038c8:	7b4080e7          	jalr	1972(ra) # 80003078 <bread>
    800038cc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038ce:	05850593          	add	a1,a0,88
    800038d2:	40dc                	lw	a5,4(s1)
    800038d4:	8bbd                	and	a5,a5,15
    800038d6:	079a                	sll	a5,a5,0x6
    800038d8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038da:	00059783          	lh	a5,0(a1)
    800038de:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038e2:	00259783          	lh	a5,2(a1)
    800038e6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038ea:	00459783          	lh	a5,4(a1)
    800038ee:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038f2:	00659783          	lh	a5,6(a1)
    800038f6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038fa:	459c                	lw	a5,8(a1)
    800038fc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800038fe:	03400613          	li	a2,52
    80003902:	05b1                	add	a1,a1,12
    80003904:	05048513          	add	a0,s1,80
    80003908:	ffffd097          	auipc	ra,0xffffd
    8000390c:	482080e7          	jalr	1154(ra) # 80000d8a <memmove>
    brelse(bp);
    80003910:	854a                	mv	a0,s2
    80003912:	00000097          	auipc	ra,0x0
    80003916:	896080e7          	jalr	-1898(ra) # 800031a8 <brelse>
    ip->valid = 1;
    8000391a:	4785                	li	a5,1
    8000391c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000391e:	04449783          	lh	a5,68(s1)
    80003922:	c399                	beqz	a5,80003928 <ilock+0xb6>
    80003924:	6902                	ld	s2,0(sp)
    80003926:	b7bd                	j	80003894 <ilock+0x22>
      panic("ilock: no type");
    80003928:	00005517          	auipc	a0,0x5
    8000392c:	bc050513          	add	a0,a0,-1088 # 800084e8 <etext+0x4e8>
    80003930:	ffffd097          	auipc	ra,0xffffd
    80003934:	c2a080e7          	jalr	-982(ra) # 8000055a <panic>

0000000080003938 <iunlock>:
{
    80003938:	1101                	add	sp,sp,-32
    8000393a:	ec06                	sd	ra,24(sp)
    8000393c:	e822                	sd	s0,16(sp)
    8000393e:	e426                	sd	s1,8(sp)
    80003940:	e04a                	sd	s2,0(sp)
    80003942:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003944:	c905                	beqz	a0,80003974 <iunlock+0x3c>
    80003946:	84aa                	mv	s1,a0
    80003948:	01050913          	add	s2,a0,16
    8000394c:	854a                	mv	a0,s2
    8000394e:	00001097          	auipc	ra,0x1
    80003952:	c86080e7          	jalr	-890(ra) # 800045d4 <holdingsleep>
    80003956:	cd19                	beqz	a0,80003974 <iunlock+0x3c>
    80003958:	449c                	lw	a5,8(s1)
    8000395a:	00f05d63          	blez	a5,80003974 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000395e:	854a                	mv	a0,s2
    80003960:	00001097          	auipc	ra,0x1
    80003964:	c30080e7          	jalr	-976(ra) # 80004590 <releasesleep>
}
    80003968:	60e2                	ld	ra,24(sp)
    8000396a:	6442                	ld	s0,16(sp)
    8000396c:	64a2                	ld	s1,8(sp)
    8000396e:	6902                	ld	s2,0(sp)
    80003970:	6105                	add	sp,sp,32
    80003972:	8082                	ret
    panic("iunlock");
    80003974:	00005517          	auipc	a0,0x5
    80003978:	b8450513          	add	a0,a0,-1148 # 800084f8 <etext+0x4f8>
    8000397c:	ffffd097          	auipc	ra,0xffffd
    80003980:	bde080e7          	jalr	-1058(ra) # 8000055a <panic>

0000000080003984 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003984:	7179                	add	sp,sp,-48
    80003986:	f406                	sd	ra,40(sp)
    80003988:	f022                	sd	s0,32(sp)
    8000398a:	ec26                	sd	s1,24(sp)
    8000398c:	e84a                	sd	s2,16(sp)
    8000398e:	e44e                	sd	s3,8(sp)
    80003990:	1800                	add	s0,sp,48
    80003992:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003994:	05050493          	add	s1,a0,80
    80003998:	08050913          	add	s2,a0,128
    8000399c:	a021                	j	800039a4 <itrunc+0x20>
    8000399e:	0491                	add	s1,s1,4
    800039a0:	01248d63          	beq	s1,s2,800039ba <itrunc+0x36>
    if(ip->addrs[i]){
    800039a4:	408c                	lw	a1,0(s1)
    800039a6:	dde5                	beqz	a1,8000399e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800039a8:	0009a503          	lw	a0,0(s3)
    800039ac:	00000097          	auipc	ra,0x0
    800039b0:	910080e7          	jalr	-1776(ra) # 800032bc <bfree>
      ip->addrs[i] = 0;
    800039b4:	0004a023          	sw	zero,0(s1)
    800039b8:	b7dd                	j	8000399e <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800039ba:	0809a583          	lw	a1,128(s3)
    800039be:	ed99                	bnez	a1,800039dc <itrunc+0x58>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800039c0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800039c4:	854e                	mv	a0,s3
    800039c6:	00000097          	auipc	ra,0x0
    800039ca:	de0080e7          	jalr	-544(ra) # 800037a6 <iupdate>
}
    800039ce:	70a2                	ld	ra,40(sp)
    800039d0:	7402                	ld	s0,32(sp)
    800039d2:	64e2                	ld	s1,24(sp)
    800039d4:	6942                	ld	s2,16(sp)
    800039d6:	69a2                	ld	s3,8(sp)
    800039d8:	6145                	add	sp,sp,48
    800039da:	8082                	ret
    800039dc:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039de:	0009a503          	lw	a0,0(s3)
    800039e2:	fffff097          	auipc	ra,0xfffff
    800039e6:	696080e7          	jalr	1686(ra) # 80003078 <bread>
    800039ea:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039ec:	05850493          	add	s1,a0,88
    800039f0:	45850913          	add	s2,a0,1112
    800039f4:	a021                	j	800039fc <itrunc+0x78>
    800039f6:	0491                	add	s1,s1,4
    800039f8:	01248b63          	beq	s1,s2,80003a0e <itrunc+0x8a>
      if(a[j])
    800039fc:	408c                	lw	a1,0(s1)
    800039fe:	dde5                	beqz	a1,800039f6 <itrunc+0x72>
        bfree(ip->dev, a[j]);
    80003a00:	0009a503          	lw	a0,0(s3)
    80003a04:	00000097          	auipc	ra,0x0
    80003a08:	8b8080e7          	jalr	-1864(ra) # 800032bc <bfree>
    80003a0c:	b7ed                	j	800039f6 <itrunc+0x72>
    brelse(bp);
    80003a0e:	8552                	mv	a0,s4
    80003a10:	fffff097          	auipc	ra,0xfffff
    80003a14:	798080e7          	jalr	1944(ra) # 800031a8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a18:	0809a583          	lw	a1,128(s3)
    80003a1c:	0009a503          	lw	a0,0(s3)
    80003a20:	00000097          	auipc	ra,0x0
    80003a24:	89c080e7          	jalr	-1892(ra) # 800032bc <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a28:	0809a023          	sw	zero,128(s3)
    80003a2c:	6a02                	ld	s4,0(sp)
    80003a2e:	bf49                	j	800039c0 <itrunc+0x3c>

0000000080003a30 <iput>:
{
    80003a30:	1101                	add	sp,sp,-32
    80003a32:	ec06                	sd	ra,24(sp)
    80003a34:	e822                	sd	s0,16(sp)
    80003a36:	e426                	sd	s1,8(sp)
    80003a38:	1000                	add	s0,sp,32
    80003a3a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a3c:	0001c517          	auipc	a0,0x1c
    80003a40:	d8c50513          	add	a0,a0,-628 # 8001f7c8 <itable>
    80003a44:	ffffd097          	auipc	ra,0xffffd
    80003a48:	1ee080e7          	jalr	494(ra) # 80000c32 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a4c:	4498                	lw	a4,8(s1)
    80003a4e:	4785                	li	a5,1
    80003a50:	02f70263          	beq	a4,a5,80003a74 <iput+0x44>
  ip->ref--;
    80003a54:	449c                	lw	a5,8(s1)
    80003a56:	37fd                	addw	a5,a5,-1
    80003a58:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a5a:	0001c517          	auipc	a0,0x1c
    80003a5e:	d6e50513          	add	a0,a0,-658 # 8001f7c8 <itable>
    80003a62:	ffffd097          	auipc	ra,0xffffd
    80003a66:	284080e7          	jalr	644(ra) # 80000ce6 <release>
}
    80003a6a:	60e2                	ld	ra,24(sp)
    80003a6c:	6442                	ld	s0,16(sp)
    80003a6e:	64a2                	ld	s1,8(sp)
    80003a70:	6105                	add	sp,sp,32
    80003a72:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a74:	40bc                	lw	a5,64(s1)
    80003a76:	dff9                	beqz	a5,80003a54 <iput+0x24>
    80003a78:	04a49783          	lh	a5,74(s1)
    80003a7c:	ffe1                	bnez	a5,80003a54 <iput+0x24>
    80003a7e:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003a80:	01048913          	add	s2,s1,16
    80003a84:	854a                	mv	a0,s2
    80003a86:	00001097          	auipc	ra,0x1
    80003a8a:	ab4080e7          	jalr	-1356(ra) # 8000453a <acquiresleep>
    release(&itable.lock);
    80003a8e:	0001c517          	auipc	a0,0x1c
    80003a92:	d3a50513          	add	a0,a0,-710 # 8001f7c8 <itable>
    80003a96:	ffffd097          	auipc	ra,0xffffd
    80003a9a:	250080e7          	jalr	592(ra) # 80000ce6 <release>
    itrunc(ip);
    80003a9e:	8526                	mv	a0,s1
    80003aa0:	00000097          	auipc	ra,0x0
    80003aa4:	ee4080e7          	jalr	-284(ra) # 80003984 <itrunc>
    ip->type = 0;
    80003aa8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003aac:	8526                	mv	a0,s1
    80003aae:	00000097          	auipc	ra,0x0
    80003ab2:	cf8080e7          	jalr	-776(ra) # 800037a6 <iupdate>
    ip->valid = 0;
    80003ab6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003aba:	854a                	mv	a0,s2
    80003abc:	00001097          	auipc	ra,0x1
    80003ac0:	ad4080e7          	jalr	-1324(ra) # 80004590 <releasesleep>
    acquire(&itable.lock);
    80003ac4:	0001c517          	auipc	a0,0x1c
    80003ac8:	d0450513          	add	a0,a0,-764 # 8001f7c8 <itable>
    80003acc:	ffffd097          	auipc	ra,0xffffd
    80003ad0:	166080e7          	jalr	358(ra) # 80000c32 <acquire>
    80003ad4:	6902                	ld	s2,0(sp)
    80003ad6:	bfbd                	j	80003a54 <iput+0x24>

0000000080003ad8 <iunlockput>:
{
    80003ad8:	1101                	add	sp,sp,-32
    80003ada:	ec06                	sd	ra,24(sp)
    80003adc:	e822                	sd	s0,16(sp)
    80003ade:	e426                	sd	s1,8(sp)
    80003ae0:	1000                	add	s0,sp,32
    80003ae2:	84aa                	mv	s1,a0
  iunlock(ip);
    80003ae4:	00000097          	auipc	ra,0x0
    80003ae8:	e54080e7          	jalr	-428(ra) # 80003938 <iunlock>
  iput(ip);
    80003aec:	8526                	mv	a0,s1
    80003aee:	00000097          	auipc	ra,0x0
    80003af2:	f42080e7          	jalr	-190(ra) # 80003a30 <iput>
}
    80003af6:	60e2                	ld	ra,24(sp)
    80003af8:	6442                	ld	s0,16(sp)
    80003afa:	64a2                	ld	s1,8(sp)
    80003afc:	6105                	add	sp,sp,32
    80003afe:	8082                	ret

0000000080003b00 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b00:	1141                	add	sp,sp,-16
    80003b02:	e422                	sd	s0,8(sp)
    80003b04:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003b06:	411c                	lw	a5,0(a0)
    80003b08:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b0a:	415c                	lw	a5,4(a0)
    80003b0c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b0e:	04451783          	lh	a5,68(a0)
    80003b12:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b16:	04a51783          	lh	a5,74(a0)
    80003b1a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b1e:	04c56783          	lwu	a5,76(a0)
    80003b22:	e99c                	sd	a5,16(a1)
}
    80003b24:	6422                	ld	s0,8(sp)
    80003b26:	0141                	add	sp,sp,16
    80003b28:	8082                	ret

0000000080003b2a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b2a:	457c                	lw	a5,76(a0)
    80003b2c:	0ed7ef63          	bltu	a5,a3,80003c2a <readi+0x100>
{
    80003b30:	7159                	add	sp,sp,-112
    80003b32:	f486                	sd	ra,104(sp)
    80003b34:	f0a2                	sd	s0,96(sp)
    80003b36:	eca6                	sd	s1,88(sp)
    80003b38:	fc56                	sd	s5,56(sp)
    80003b3a:	f85a                	sd	s6,48(sp)
    80003b3c:	f45e                	sd	s7,40(sp)
    80003b3e:	f062                	sd	s8,32(sp)
    80003b40:	1880                	add	s0,sp,112
    80003b42:	8baa                	mv	s7,a0
    80003b44:	8c2e                	mv	s8,a1
    80003b46:	8ab2                	mv	s5,a2
    80003b48:	84b6                	mv	s1,a3
    80003b4a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b4c:	9f35                	addw	a4,a4,a3
    return 0;
    80003b4e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b50:	0ad76c63          	bltu	a4,a3,80003c08 <readi+0xde>
    80003b54:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003b56:	00e7f463          	bgeu	a5,a4,80003b5e <readi+0x34>
    n = ip->size - off;
    80003b5a:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b5e:	0c0b0463          	beqz	s6,80003c26 <readi+0xfc>
    80003b62:	e8ca                	sd	s2,80(sp)
    80003b64:	e0d2                	sd	s4,64(sp)
    80003b66:	ec66                	sd	s9,24(sp)
    80003b68:	e86a                	sd	s10,16(sp)
    80003b6a:	e46e                	sd	s11,8(sp)
    80003b6c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b6e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003b72:	5cfd                	li	s9,-1
    80003b74:	a82d                	j	80003bae <readi+0x84>
    80003b76:	020a1d93          	sll	s11,s4,0x20
    80003b7a:	020ddd93          	srl	s11,s11,0x20
    80003b7e:	05890613          	add	a2,s2,88
    80003b82:	86ee                	mv	a3,s11
    80003b84:	963a                	add	a2,a2,a4
    80003b86:	85d6                	mv	a1,s5
    80003b88:	8562                	mv	a0,s8
    80003b8a:	fffff097          	auipc	ra,0xfffff
    80003b8e:	a0a080e7          	jalr	-1526(ra) # 80002594 <either_copyout>
    80003b92:	05950d63          	beq	a0,s9,80003bec <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003b96:	854a                	mv	a0,s2
    80003b98:	fffff097          	auipc	ra,0xfffff
    80003b9c:	610080e7          	jalr	1552(ra) # 800031a8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ba0:	013a09bb          	addw	s3,s4,s3
    80003ba4:	009a04bb          	addw	s1,s4,s1
    80003ba8:	9aee                	add	s5,s5,s11
    80003baa:	0769f863          	bgeu	s3,s6,80003c1a <readi+0xf0>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003bae:	000ba903          	lw	s2,0(s7)
    80003bb2:	00a4d59b          	srlw	a1,s1,0xa
    80003bb6:	855e                	mv	a0,s7
    80003bb8:	00000097          	auipc	ra,0x0
    80003bbc:	8ae080e7          	jalr	-1874(ra) # 80003466 <bmap>
    80003bc0:	0005059b          	sext.w	a1,a0
    80003bc4:	854a                	mv	a0,s2
    80003bc6:	fffff097          	auipc	ra,0xfffff
    80003bca:	4b2080e7          	jalr	1202(ra) # 80003078 <bread>
    80003bce:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bd0:	3ff4f713          	and	a4,s1,1023
    80003bd4:	40ed07bb          	subw	a5,s10,a4
    80003bd8:	413b06bb          	subw	a3,s6,s3
    80003bdc:	8a3e                	mv	s4,a5
    80003bde:	2781                	sext.w	a5,a5
    80003be0:	0006861b          	sext.w	a2,a3
    80003be4:	f8f679e3          	bgeu	a2,a5,80003b76 <readi+0x4c>
    80003be8:	8a36                	mv	s4,a3
    80003bea:	b771                	j	80003b76 <readi+0x4c>
      brelse(bp);
    80003bec:	854a                	mv	a0,s2
    80003bee:	fffff097          	auipc	ra,0xfffff
    80003bf2:	5ba080e7          	jalr	1466(ra) # 800031a8 <brelse>
      tot = -1;
    80003bf6:	59fd                	li	s3,-1
      break;
    80003bf8:	6946                	ld	s2,80(sp)
    80003bfa:	6a06                	ld	s4,64(sp)
    80003bfc:	6ce2                	ld	s9,24(sp)
    80003bfe:	6d42                	ld	s10,16(sp)
    80003c00:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003c02:	0009851b          	sext.w	a0,s3
    80003c06:	69a6                	ld	s3,72(sp)
}
    80003c08:	70a6                	ld	ra,104(sp)
    80003c0a:	7406                	ld	s0,96(sp)
    80003c0c:	64e6                	ld	s1,88(sp)
    80003c0e:	7ae2                	ld	s5,56(sp)
    80003c10:	7b42                	ld	s6,48(sp)
    80003c12:	7ba2                	ld	s7,40(sp)
    80003c14:	7c02                	ld	s8,32(sp)
    80003c16:	6165                	add	sp,sp,112
    80003c18:	8082                	ret
    80003c1a:	6946                	ld	s2,80(sp)
    80003c1c:	6a06                	ld	s4,64(sp)
    80003c1e:	6ce2                	ld	s9,24(sp)
    80003c20:	6d42                	ld	s10,16(sp)
    80003c22:	6da2                	ld	s11,8(sp)
    80003c24:	bff9                	j	80003c02 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c26:	89da                	mv	s3,s6
    80003c28:	bfe9                	j	80003c02 <readi+0xd8>
    return 0;
    80003c2a:	4501                	li	a0,0
}
    80003c2c:	8082                	ret

0000000080003c2e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c2e:	457c                	lw	a5,76(a0)
    80003c30:	10d7ee63          	bltu	a5,a3,80003d4c <writei+0x11e>
{
    80003c34:	7159                	add	sp,sp,-112
    80003c36:	f486                	sd	ra,104(sp)
    80003c38:	f0a2                	sd	s0,96(sp)
    80003c3a:	e8ca                	sd	s2,80(sp)
    80003c3c:	fc56                	sd	s5,56(sp)
    80003c3e:	f85a                	sd	s6,48(sp)
    80003c40:	f45e                	sd	s7,40(sp)
    80003c42:	f062                	sd	s8,32(sp)
    80003c44:	1880                	add	s0,sp,112
    80003c46:	8b2a                	mv	s6,a0
    80003c48:	8c2e                	mv	s8,a1
    80003c4a:	8ab2                	mv	s5,a2
    80003c4c:	8936                	mv	s2,a3
    80003c4e:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003c50:	00e687bb          	addw	a5,a3,a4
    80003c54:	0ed7ee63          	bltu	a5,a3,80003d50 <writei+0x122>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c58:	00043737          	lui	a4,0x43
    80003c5c:	0ef76c63          	bltu	a4,a5,80003d54 <writei+0x126>
    80003c60:	e0d2                	sd	s4,64(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c62:	0c0b8d63          	beqz	s7,80003d3c <writei+0x10e>
    80003c66:	eca6                	sd	s1,88(sp)
    80003c68:	e4ce                	sd	s3,72(sp)
    80003c6a:	ec66                	sd	s9,24(sp)
    80003c6c:	e86a                	sd	s10,16(sp)
    80003c6e:	e46e                	sd	s11,8(sp)
    80003c70:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c72:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003c76:	5cfd                	li	s9,-1
    80003c78:	a091                	j	80003cbc <writei+0x8e>
    80003c7a:	02099d93          	sll	s11,s3,0x20
    80003c7e:	020ddd93          	srl	s11,s11,0x20
    80003c82:	05848513          	add	a0,s1,88
    80003c86:	86ee                	mv	a3,s11
    80003c88:	8656                	mv	a2,s5
    80003c8a:	85e2                	mv	a1,s8
    80003c8c:	953a                	add	a0,a0,a4
    80003c8e:	fffff097          	auipc	ra,0xfffff
    80003c92:	95c080e7          	jalr	-1700(ra) # 800025ea <either_copyin>
    80003c96:	07950263          	beq	a0,s9,80003cfa <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c9a:	8526                	mv	a0,s1
    80003c9c:	00000097          	auipc	ra,0x0
    80003ca0:	780080e7          	jalr	1920(ra) # 8000441c <log_write>
    brelse(bp);
    80003ca4:	8526                	mv	a0,s1
    80003ca6:	fffff097          	auipc	ra,0xfffff
    80003caa:	502080e7          	jalr	1282(ra) # 800031a8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cae:	01498a3b          	addw	s4,s3,s4
    80003cb2:	0129893b          	addw	s2,s3,s2
    80003cb6:	9aee                	add	s5,s5,s11
    80003cb8:	057a7663          	bgeu	s4,s7,80003d04 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003cbc:	000b2483          	lw	s1,0(s6)
    80003cc0:	00a9559b          	srlw	a1,s2,0xa
    80003cc4:	855a                	mv	a0,s6
    80003cc6:	fffff097          	auipc	ra,0xfffff
    80003cca:	7a0080e7          	jalr	1952(ra) # 80003466 <bmap>
    80003cce:	0005059b          	sext.w	a1,a0
    80003cd2:	8526                	mv	a0,s1
    80003cd4:	fffff097          	auipc	ra,0xfffff
    80003cd8:	3a4080e7          	jalr	932(ra) # 80003078 <bread>
    80003cdc:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cde:	3ff97713          	and	a4,s2,1023
    80003ce2:	40ed07bb          	subw	a5,s10,a4
    80003ce6:	414b86bb          	subw	a3,s7,s4
    80003cea:	89be                	mv	s3,a5
    80003cec:	2781                	sext.w	a5,a5
    80003cee:	0006861b          	sext.w	a2,a3
    80003cf2:	f8f674e3          	bgeu	a2,a5,80003c7a <writei+0x4c>
    80003cf6:	89b6                	mv	s3,a3
    80003cf8:	b749                	j	80003c7a <writei+0x4c>
      brelse(bp);
    80003cfa:	8526                	mv	a0,s1
    80003cfc:	fffff097          	auipc	ra,0xfffff
    80003d00:	4ac080e7          	jalr	1196(ra) # 800031a8 <brelse>
  }

  if(off > ip->size)
    80003d04:	04cb2783          	lw	a5,76(s6)
    80003d08:	0327fc63          	bgeu	a5,s2,80003d40 <writei+0x112>
    ip->size = off;
    80003d0c:	052b2623          	sw	s2,76(s6)
    80003d10:	64e6                	ld	s1,88(sp)
    80003d12:	69a6                	ld	s3,72(sp)
    80003d14:	6ce2                	ld	s9,24(sp)
    80003d16:	6d42                	ld	s10,16(sp)
    80003d18:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d1a:	855a                	mv	a0,s6
    80003d1c:	00000097          	auipc	ra,0x0
    80003d20:	a8a080e7          	jalr	-1398(ra) # 800037a6 <iupdate>

  return tot;
    80003d24:	000a051b          	sext.w	a0,s4
    80003d28:	6a06                	ld	s4,64(sp)
}
    80003d2a:	70a6                	ld	ra,104(sp)
    80003d2c:	7406                	ld	s0,96(sp)
    80003d2e:	6946                	ld	s2,80(sp)
    80003d30:	7ae2                	ld	s5,56(sp)
    80003d32:	7b42                	ld	s6,48(sp)
    80003d34:	7ba2                	ld	s7,40(sp)
    80003d36:	7c02                	ld	s8,32(sp)
    80003d38:	6165                	add	sp,sp,112
    80003d3a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d3c:	8a5e                	mv	s4,s7
    80003d3e:	bff1                	j	80003d1a <writei+0xec>
    80003d40:	64e6                	ld	s1,88(sp)
    80003d42:	69a6                	ld	s3,72(sp)
    80003d44:	6ce2                	ld	s9,24(sp)
    80003d46:	6d42                	ld	s10,16(sp)
    80003d48:	6da2                	ld	s11,8(sp)
    80003d4a:	bfc1                	j	80003d1a <writei+0xec>
    return -1;
    80003d4c:	557d                	li	a0,-1
}
    80003d4e:	8082                	ret
    return -1;
    80003d50:	557d                	li	a0,-1
    80003d52:	bfe1                	j	80003d2a <writei+0xfc>
    return -1;
    80003d54:	557d                	li	a0,-1
    80003d56:	bfd1                	j	80003d2a <writei+0xfc>

0000000080003d58 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d58:	1141                	add	sp,sp,-16
    80003d5a:	e406                	sd	ra,8(sp)
    80003d5c:	e022                	sd	s0,0(sp)
    80003d5e:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d60:	4639                	li	a2,14
    80003d62:	ffffd097          	auipc	ra,0xffffd
    80003d66:	09c080e7          	jalr	156(ra) # 80000dfe <strncmp>
}
    80003d6a:	60a2                	ld	ra,8(sp)
    80003d6c:	6402                	ld	s0,0(sp)
    80003d6e:	0141                	add	sp,sp,16
    80003d70:	8082                	ret

0000000080003d72 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d72:	7139                	add	sp,sp,-64
    80003d74:	fc06                	sd	ra,56(sp)
    80003d76:	f822                	sd	s0,48(sp)
    80003d78:	f426                	sd	s1,40(sp)
    80003d7a:	f04a                	sd	s2,32(sp)
    80003d7c:	ec4e                	sd	s3,24(sp)
    80003d7e:	e852                	sd	s4,16(sp)
    80003d80:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d82:	04451703          	lh	a4,68(a0)
    80003d86:	4785                	li	a5,1
    80003d88:	00f71a63          	bne	a4,a5,80003d9c <dirlookup+0x2a>
    80003d8c:	892a                	mv	s2,a0
    80003d8e:	89ae                	mv	s3,a1
    80003d90:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d92:	457c                	lw	a5,76(a0)
    80003d94:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003d96:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d98:	e79d                	bnez	a5,80003dc6 <dirlookup+0x54>
    80003d9a:	a8a5                	j	80003e12 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003d9c:	00004517          	auipc	a0,0x4
    80003da0:	76450513          	add	a0,a0,1892 # 80008500 <etext+0x500>
    80003da4:	ffffc097          	auipc	ra,0xffffc
    80003da8:	7b6080e7          	jalr	1974(ra) # 8000055a <panic>
      panic("dirlookup read");
    80003dac:	00004517          	auipc	a0,0x4
    80003db0:	76c50513          	add	a0,a0,1900 # 80008518 <etext+0x518>
    80003db4:	ffffc097          	auipc	ra,0xffffc
    80003db8:	7a6080e7          	jalr	1958(ra) # 8000055a <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dbc:	24c1                	addw	s1,s1,16
    80003dbe:	04c92783          	lw	a5,76(s2)
    80003dc2:	04f4f763          	bgeu	s1,a5,80003e10 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dc6:	4741                	li	a4,16
    80003dc8:	86a6                	mv	a3,s1
    80003dca:	fc040613          	add	a2,s0,-64
    80003dce:	4581                	li	a1,0
    80003dd0:	854a                	mv	a0,s2
    80003dd2:	00000097          	auipc	ra,0x0
    80003dd6:	d58080e7          	jalr	-680(ra) # 80003b2a <readi>
    80003dda:	47c1                	li	a5,16
    80003ddc:	fcf518e3          	bne	a0,a5,80003dac <dirlookup+0x3a>
    if(de.inum == 0)
    80003de0:	fc045783          	lhu	a5,-64(s0)
    80003de4:	dfe1                	beqz	a5,80003dbc <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003de6:	fc240593          	add	a1,s0,-62
    80003dea:	854e                	mv	a0,s3
    80003dec:	00000097          	auipc	ra,0x0
    80003df0:	f6c080e7          	jalr	-148(ra) # 80003d58 <namecmp>
    80003df4:	f561                	bnez	a0,80003dbc <dirlookup+0x4a>
      if(poff)
    80003df6:	000a0463          	beqz	s4,80003dfe <dirlookup+0x8c>
        *poff = off;
    80003dfa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003dfe:	fc045583          	lhu	a1,-64(s0)
    80003e02:	00092503          	lw	a0,0(s2)
    80003e06:	fffff097          	auipc	ra,0xfffff
    80003e0a:	73c080e7          	jalr	1852(ra) # 80003542 <iget>
    80003e0e:	a011                	j	80003e12 <dirlookup+0xa0>
  return 0;
    80003e10:	4501                	li	a0,0
}
    80003e12:	70e2                	ld	ra,56(sp)
    80003e14:	7442                	ld	s0,48(sp)
    80003e16:	74a2                	ld	s1,40(sp)
    80003e18:	7902                	ld	s2,32(sp)
    80003e1a:	69e2                	ld	s3,24(sp)
    80003e1c:	6a42                	ld	s4,16(sp)
    80003e1e:	6121                	add	sp,sp,64
    80003e20:	8082                	ret

0000000080003e22 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e22:	711d                	add	sp,sp,-96
    80003e24:	ec86                	sd	ra,88(sp)
    80003e26:	e8a2                	sd	s0,80(sp)
    80003e28:	e4a6                	sd	s1,72(sp)
    80003e2a:	e0ca                	sd	s2,64(sp)
    80003e2c:	fc4e                	sd	s3,56(sp)
    80003e2e:	f852                	sd	s4,48(sp)
    80003e30:	f456                	sd	s5,40(sp)
    80003e32:	f05a                	sd	s6,32(sp)
    80003e34:	ec5e                	sd	s7,24(sp)
    80003e36:	e862                	sd	s8,16(sp)
    80003e38:	e466                	sd	s9,8(sp)
    80003e3a:	1080                	add	s0,sp,96
    80003e3c:	84aa                	mv	s1,a0
    80003e3e:	8b2e                	mv	s6,a1
    80003e40:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e42:	00054703          	lbu	a4,0(a0)
    80003e46:	02f00793          	li	a5,47
    80003e4a:	02f70263          	beq	a4,a5,80003e6e <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e4e:	ffffe097          	auipc	ra,0xffffe
    80003e52:	cdc080e7          	jalr	-804(ra) # 80001b2a <myproc>
    80003e56:	15053503          	ld	a0,336(a0)
    80003e5a:	00000097          	auipc	ra,0x0
    80003e5e:	9da080e7          	jalr	-1574(ra) # 80003834 <idup>
    80003e62:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e64:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003e68:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e6a:	4b85                	li	s7,1
    80003e6c:	a875                	j	80003f28 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003e6e:	4585                	li	a1,1
    80003e70:	4505                	li	a0,1
    80003e72:	fffff097          	auipc	ra,0xfffff
    80003e76:	6d0080e7          	jalr	1744(ra) # 80003542 <iget>
    80003e7a:	8a2a                	mv	s4,a0
    80003e7c:	b7e5                	j	80003e64 <namex+0x42>
      iunlockput(ip);
    80003e7e:	8552                	mv	a0,s4
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	c58080e7          	jalr	-936(ra) # 80003ad8 <iunlockput>
      return 0;
    80003e88:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e8a:	8552                	mv	a0,s4
    80003e8c:	60e6                	ld	ra,88(sp)
    80003e8e:	6446                	ld	s0,80(sp)
    80003e90:	64a6                	ld	s1,72(sp)
    80003e92:	6906                	ld	s2,64(sp)
    80003e94:	79e2                	ld	s3,56(sp)
    80003e96:	7a42                	ld	s4,48(sp)
    80003e98:	7aa2                	ld	s5,40(sp)
    80003e9a:	7b02                	ld	s6,32(sp)
    80003e9c:	6be2                	ld	s7,24(sp)
    80003e9e:	6c42                	ld	s8,16(sp)
    80003ea0:	6ca2                	ld	s9,8(sp)
    80003ea2:	6125                	add	sp,sp,96
    80003ea4:	8082                	ret
      iunlock(ip);
    80003ea6:	8552                	mv	a0,s4
    80003ea8:	00000097          	auipc	ra,0x0
    80003eac:	a90080e7          	jalr	-1392(ra) # 80003938 <iunlock>
      return ip;
    80003eb0:	bfe9                	j	80003e8a <namex+0x68>
      iunlockput(ip);
    80003eb2:	8552                	mv	a0,s4
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	c24080e7          	jalr	-988(ra) # 80003ad8 <iunlockput>
      return 0;
    80003ebc:	8a4e                	mv	s4,s3
    80003ebe:	b7f1                	j	80003e8a <namex+0x68>
  len = path - s;
    80003ec0:	40998633          	sub	a2,s3,s1
    80003ec4:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003ec8:	099c5863          	bge	s8,s9,80003f58 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003ecc:	4639                	li	a2,14
    80003ece:	85a6                	mv	a1,s1
    80003ed0:	8556                	mv	a0,s5
    80003ed2:	ffffd097          	auipc	ra,0xffffd
    80003ed6:	eb8080e7          	jalr	-328(ra) # 80000d8a <memmove>
    80003eda:	84ce                	mv	s1,s3
  while(*path == '/')
    80003edc:	0004c783          	lbu	a5,0(s1)
    80003ee0:	01279763          	bne	a5,s2,80003eee <namex+0xcc>
    path++;
    80003ee4:	0485                	add	s1,s1,1
  while(*path == '/')
    80003ee6:	0004c783          	lbu	a5,0(s1)
    80003eea:	ff278de3          	beq	a5,s2,80003ee4 <namex+0xc2>
    ilock(ip);
    80003eee:	8552                	mv	a0,s4
    80003ef0:	00000097          	auipc	ra,0x0
    80003ef4:	982080e7          	jalr	-1662(ra) # 80003872 <ilock>
    if(ip->type != T_DIR){
    80003ef8:	044a1783          	lh	a5,68(s4)
    80003efc:	f97791e3          	bne	a5,s7,80003e7e <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003f00:	000b0563          	beqz	s6,80003f0a <namex+0xe8>
    80003f04:	0004c783          	lbu	a5,0(s1)
    80003f08:	dfd9                	beqz	a5,80003ea6 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f0a:	4601                	li	a2,0
    80003f0c:	85d6                	mv	a1,s5
    80003f0e:	8552                	mv	a0,s4
    80003f10:	00000097          	auipc	ra,0x0
    80003f14:	e62080e7          	jalr	-414(ra) # 80003d72 <dirlookup>
    80003f18:	89aa                	mv	s3,a0
    80003f1a:	dd41                	beqz	a0,80003eb2 <namex+0x90>
    iunlockput(ip);
    80003f1c:	8552                	mv	a0,s4
    80003f1e:	00000097          	auipc	ra,0x0
    80003f22:	bba080e7          	jalr	-1094(ra) # 80003ad8 <iunlockput>
    ip = next;
    80003f26:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003f28:	0004c783          	lbu	a5,0(s1)
    80003f2c:	01279763          	bne	a5,s2,80003f3a <namex+0x118>
    path++;
    80003f30:	0485                	add	s1,s1,1
  while(*path == '/')
    80003f32:	0004c783          	lbu	a5,0(s1)
    80003f36:	ff278de3          	beq	a5,s2,80003f30 <namex+0x10e>
  if(*path == 0)
    80003f3a:	cb9d                	beqz	a5,80003f70 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003f3c:	0004c783          	lbu	a5,0(s1)
    80003f40:	89a6                	mv	s3,s1
  len = path - s;
    80003f42:	4c81                	li	s9,0
    80003f44:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003f46:	01278963          	beq	a5,s2,80003f58 <namex+0x136>
    80003f4a:	dbbd                	beqz	a5,80003ec0 <namex+0x9e>
    path++;
    80003f4c:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80003f4e:	0009c783          	lbu	a5,0(s3)
    80003f52:	ff279ce3          	bne	a5,s2,80003f4a <namex+0x128>
    80003f56:	b7ad                	j	80003ec0 <namex+0x9e>
    memmove(name, s, len);
    80003f58:	2601                	sext.w	a2,a2
    80003f5a:	85a6                	mv	a1,s1
    80003f5c:	8556                	mv	a0,s5
    80003f5e:	ffffd097          	auipc	ra,0xffffd
    80003f62:	e2c080e7          	jalr	-468(ra) # 80000d8a <memmove>
    name[len] = 0;
    80003f66:	9cd6                	add	s9,s9,s5
    80003f68:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003f6c:	84ce                	mv	s1,s3
    80003f6e:	b7bd                	j	80003edc <namex+0xba>
  if(nameiparent){
    80003f70:	f00b0de3          	beqz	s6,80003e8a <namex+0x68>
    iput(ip);
    80003f74:	8552                	mv	a0,s4
    80003f76:	00000097          	auipc	ra,0x0
    80003f7a:	aba080e7          	jalr	-1350(ra) # 80003a30 <iput>
    return 0;
    80003f7e:	4a01                	li	s4,0
    80003f80:	b729                	j	80003e8a <namex+0x68>

0000000080003f82 <dirlink>:
{
    80003f82:	7139                	add	sp,sp,-64
    80003f84:	fc06                	sd	ra,56(sp)
    80003f86:	f822                	sd	s0,48(sp)
    80003f88:	f04a                	sd	s2,32(sp)
    80003f8a:	ec4e                	sd	s3,24(sp)
    80003f8c:	e852                	sd	s4,16(sp)
    80003f8e:	0080                	add	s0,sp,64
    80003f90:	892a                	mv	s2,a0
    80003f92:	8a2e                	mv	s4,a1
    80003f94:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f96:	4601                	li	a2,0
    80003f98:	00000097          	auipc	ra,0x0
    80003f9c:	dda080e7          	jalr	-550(ra) # 80003d72 <dirlookup>
    80003fa0:	ed25                	bnez	a0,80004018 <dirlink+0x96>
    80003fa2:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fa4:	04c92483          	lw	s1,76(s2)
    80003fa8:	c49d                	beqz	s1,80003fd6 <dirlink+0x54>
    80003faa:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fac:	4741                	li	a4,16
    80003fae:	86a6                	mv	a3,s1
    80003fb0:	fc040613          	add	a2,s0,-64
    80003fb4:	4581                	li	a1,0
    80003fb6:	854a                	mv	a0,s2
    80003fb8:	00000097          	auipc	ra,0x0
    80003fbc:	b72080e7          	jalr	-1166(ra) # 80003b2a <readi>
    80003fc0:	47c1                	li	a5,16
    80003fc2:	06f51163          	bne	a0,a5,80004024 <dirlink+0xa2>
    if(de.inum == 0)
    80003fc6:	fc045783          	lhu	a5,-64(s0)
    80003fca:	c791                	beqz	a5,80003fd6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fcc:	24c1                	addw	s1,s1,16
    80003fce:	04c92783          	lw	a5,76(s2)
    80003fd2:	fcf4ede3          	bltu	s1,a5,80003fac <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003fd6:	4639                	li	a2,14
    80003fd8:	85d2                	mv	a1,s4
    80003fda:	fc240513          	add	a0,s0,-62
    80003fde:	ffffd097          	auipc	ra,0xffffd
    80003fe2:	e56080e7          	jalr	-426(ra) # 80000e34 <strncpy>
  de.inum = inum;
    80003fe6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fea:	4741                	li	a4,16
    80003fec:	86a6                	mv	a3,s1
    80003fee:	fc040613          	add	a2,s0,-64
    80003ff2:	4581                	li	a1,0
    80003ff4:	854a                	mv	a0,s2
    80003ff6:	00000097          	auipc	ra,0x0
    80003ffa:	c38080e7          	jalr	-968(ra) # 80003c2e <writei>
    80003ffe:	872a                	mv	a4,a0
    80004000:	47c1                	li	a5,16
  return 0;
    80004002:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004004:	02f71863          	bne	a4,a5,80004034 <dirlink+0xb2>
    80004008:	74a2                	ld	s1,40(sp)
}
    8000400a:	70e2                	ld	ra,56(sp)
    8000400c:	7442                	ld	s0,48(sp)
    8000400e:	7902                	ld	s2,32(sp)
    80004010:	69e2                	ld	s3,24(sp)
    80004012:	6a42                	ld	s4,16(sp)
    80004014:	6121                	add	sp,sp,64
    80004016:	8082                	ret
    iput(ip);
    80004018:	00000097          	auipc	ra,0x0
    8000401c:	a18080e7          	jalr	-1512(ra) # 80003a30 <iput>
    return -1;
    80004020:	557d                	li	a0,-1
    80004022:	b7e5                	j	8000400a <dirlink+0x88>
      panic("dirlink read");
    80004024:	00004517          	auipc	a0,0x4
    80004028:	50450513          	add	a0,a0,1284 # 80008528 <etext+0x528>
    8000402c:	ffffc097          	auipc	ra,0xffffc
    80004030:	52e080e7          	jalr	1326(ra) # 8000055a <panic>
    panic("dirlink");
    80004034:	00004517          	auipc	a0,0x4
    80004038:	60450513          	add	a0,a0,1540 # 80008638 <etext+0x638>
    8000403c:	ffffc097          	auipc	ra,0xffffc
    80004040:	51e080e7          	jalr	1310(ra) # 8000055a <panic>

0000000080004044 <namei>:

struct inode*
namei(char *path)
{
    80004044:	1101                	add	sp,sp,-32
    80004046:	ec06                	sd	ra,24(sp)
    80004048:	e822                	sd	s0,16(sp)
    8000404a:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000404c:	fe040613          	add	a2,s0,-32
    80004050:	4581                	li	a1,0
    80004052:	00000097          	auipc	ra,0x0
    80004056:	dd0080e7          	jalr	-560(ra) # 80003e22 <namex>
}
    8000405a:	60e2                	ld	ra,24(sp)
    8000405c:	6442                	ld	s0,16(sp)
    8000405e:	6105                	add	sp,sp,32
    80004060:	8082                	ret

0000000080004062 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004062:	1141                	add	sp,sp,-16
    80004064:	e406                	sd	ra,8(sp)
    80004066:	e022                	sd	s0,0(sp)
    80004068:	0800                	add	s0,sp,16
    8000406a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000406c:	4585                	li	a1,1
    8000406e:	00000097          	auipc	ra,0x0
    80004072:	db4080e7          	jalr	-588(ra) # 80003e22 <namex>
}
    80004076:	60a2                	ld	ra,8(sp)
    80004078:	6402                	ld	s0,0(sp)
    8000407a:	0141                	add	sp,sp,16
    8000407c:	8082                	ret

000000008000407e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000407e:	1101                	add	sp,sp,-32
    80004080:	ec06                	sd	ra,24(sp)
    80004082:	e822                	sd	s0,16(sp)
    80004084:	e426                	sd	s1,8(sp)
    80004086:	e04a                	sd	s2,0(sp)
    80004088:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000408a:	0001d917          	auipc	s2,0x1d
    8000408e:	1e690913          	add	s2,s2,486 # 80021270 <log>
    80004092:	01892583          	lw	a1,24(s2)
    80004096:	02892503          	lw	a0,40(s2)
    8000409a:	fffff097          	auipc	ra,0xfffff
    8000409e:	fde080e7          	jalr	-34(ra) # 80003078 <bread>
    800040a2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040a4:	02c92603          	lw	a2,44(s2)
    800040a8:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040aa:	00c05f63          	blez	a2,800040c8 <write_head+0x4a>
    800040ae:	0001d717          	auipc	a4,0x1d
    800040b2:	1f270713          	add	a4,a4,498 # 800212a0 <log+0x30>
    800040b6:	87aa                	mv	a5,a0
    800040b8:	060a                	sll	a2,a2,0x2
    800040ba:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800040bc:	4314                	lw	a3,0(a4)
    800040be:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800040c0:	0711                	add	a4,a4,4
    800040c2:	0791                	add	a5,a5,4
    800040c4:	fec79ce3          	bne	a5,a2,800040bc <write_head+0x3e>
  }
  bwrite(buf);
    800040c8:	8526                	mv	a0,s1
    800040ca:	fffff097          	auipc	ra,0xfffff
    800040ce:	0a0080e7          	jalr	160(ra) # 8000316a <bwrite>
  brelse(buf);
    800040d2:	8526                	mv	a0,s1
    800040d4:	fffff097          	auipc	ra,0xfffff
    800040d8:	0d4080e7          	jalr	212(ra) # 800031a8 <brelse>
}
    800040dc:	60e2                	ld	ra,24(sp)
    800040de:	6442                	ld	s0,16(sp)
    800040e0:	64a2                	ld	s1,8(sp)
    800040e2:	6902                	ld	s2,0(sp)
    800040e4:	6105                	add	sp,sp,32
    800040e6:	8082                	ret

00000000800040e8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040e8:	0001d797          	auipc	a5,0x1d
    800040ec:	1b47a783          	lw	a5,436(a5) # 8002129c <log+0x2c>
    800040f0:	0af05d63          	blez	a5,800041aa <install_trans+0xc2>
{
    800040f4:	7139                	add	sp,sp,-64
    800040f6:	fc06                	sd	ra,56(sp)
    800040f8:	f822                	sd	s0,48(sp)
    800040fa:	f426                	sd	s1,40(sp)
    800040fc:	f04a                	sd	s2,32(sp)
    800040fe:	ec4e                	sd	s3,24(sp)
    80004100:	e852                	sd	s4,16(sp)
    80004102:	e456                	sd	s5,8(sp)
    80004104:	e05a                	sd	s6,0(sp)
    80004106:	0080                	add	s0,sp,64
    80004108:	8b2a                	mv	s6,a0
    8000410a:	0001da97          	auipc	s5,0x1d
    8000410e:	196a8a93          	add	s5,s5,406 # 800212a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004112:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004114:	0001d997          	auipc	s3,0x1d
    80004118:	15c98993          	add	s3,s3,348 # 80021270 <log>
    8000411c:	a00d                	j	8000413e <install_trans+0x56>
    brelse(lbuf);
    8000411e:	854a                	mv	a0,s2
    80004120:	fffff097          	auipc	ra,0xfffff
    80004124:	088080e7          	jalr	136(ra) # 800031a8 <brelse>
    brelse(dbuf);
    80004128:	8526                	mv	a0,s1
    8000412a:	fffff097          	auipc	ra,0xfffff
    8000412e:	07e080e7          	jalr	126(ra) # 800031a8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004132:	2a05                	addw	s4,s4,1
    80004134:	0a91                	add	s5,s5,4
    80004136:	02c9a783          	lw	a5,44(s3)
    8000413a:	04fa5e63          	bge	s4,a5,80004196 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000413e:	0189a583          	lw	a1,24(s3)
    80004142:	014585bb          	addw	a1,a1,s4
    80004146:	2585                	addw	a1,a1,1
    80004148:	0289a503          	lw	a0,40(s3)
    8000414c:	fffff097          	auipc	ra,0xfffff
    80004150:	f2c080e7          	jalr	-212(ra) # 80003078 <bread>
    80004154:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004156:	000aa583          	lw	a1,0(s5)
    8000415a:	0289a503          	lw	a0,40(s3)
    8000415e:	fffff097          	auipc	ra,0xfffff
    80004162:	f1a080e7          	jalr	-230(ra) # 80003078 <bread>
    80004166:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004168:	40000613          	li	a2,1024
    8000416c:	05890593          	add	a1,s2,88
    80004170:	05850513          	add	a0,a0,88
    80004174:	ffffd097          	auipc	ra,0xffffd
    80004178:	c16080e7          	jalr	-1002(ra) # 80000d8a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000417c:	8526                	mv	a0,s1
    8000417e:	fffff097          	auipc	ra,0xfffff
    80004182:	fec080e7          	jalr	-20(ra) # 8000316a <bwrite>
    if(recovering == 0)
    80004186:	f80b1ce3          	bnez	s6,8000411e <install_trans+0x36>
      bunpin(dbuf);
    8000418a:	8526                	mv	a0,s1
    8000418c:	fffff097          	auipc	ra,0xfffff
    80004190:	0f4080e7          	jalr	244(ra) # 80003280 <bunpin>
    80004194:	b769                	j	8000411e <install_trans+0x36>
}
    80004196:	70e2                	ld	ra,56(sp)
    80004198:	7442                	ld	s0,48(sp)
    8000419a:	74a2                	ld	s1,40(sp)
    8000419c:	7902                	ld	s2,32(sp)
    8000419e:	69e2                	ld	s3,24(sp)
    800041a0:	6a42                	ld	s4,16(sp)
    800041a2:	6aa2                	ld	s5,8(sp)
    800041a4:	6b02                	ld	s6,0(sp)
    800041a6:	6121                	add	sp,sp,64
    800041a8:	8082                	ret
    800041aa:	8082                	ret

00000000800041ac <initlog>:
{
    800041ac:	7179                	add	sp,sp,-48
    800041ae:	f406                	sd	ra,40(sp)
    800041b0:	f022                	sd	s0,32(sp)
    800041b2:	ec26                	sd	s1,24(sp)
    800041b4:	e84a                	sd	s2,16(sp)
    800041b6:	e44e                	sd	s3,8(sp)
    800041b8:	1800                	add	s0,sp,48
    800041ba:	892a                	mv	s2,a0
    800041bc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041be:	0001d497          	auipc	s1,0x1d
    800041c2:	0b248493          	add	s1,s1,178 # 80021270 <log>
    800041c6:	00004597          	auipc	a1,0x4
    800041ca:	37258593          	add	a1,a1,882 # 80008538 <etext+0x538>
    800041ce:	8526                	mv	a0,s1
    800041d0:	ffffd097          	auipc	ra,0xffffd
    800041d4:	9d2080e7          	jalr	-1582(ra) # 80000ba2 <initlock>
  log.start = sb->logstart;
    800041d8:	0149a583          	lw	a1,20(s3)
    800041dc:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800041de:	0109a783          	lw	a5,16(s3)
    800041e2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800041e4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800041e8:	854a                	mv	a0,s2
    800041ea:	fffff097          	auipc	ra,0xfffff
    800041ee:	e8e080e7          	jalr	-370(ra) # 80003078 <bread>
  log.lh.n = lh->n;
    800041f2:	4d30                	lw	a2,88(a0)
    800041f4:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800041f6:	00c05f63          	blez	a2,80004214 <initlog+0x68>
    800041fa:	87aa                	mv	a5,a0
    800041fc:	0001d717          	auipc	a4,0x1d
    80004200:	0a470713          	add	a4,a4,164 # 800212a0 <log+0x30>
    80004204:	060a                	sll	a2,a2,0x2
    80004206:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004208:	4ff4                	lw	a3,92(a5)
    8000420a:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000420c:	0791                	add	a5,a5,4
    8000420e:	0711                	add	a4,a4,4
    80004210:	fec79ce3          	bne	a5,a2,80004208 <initlog+0x5c>
  brelse(buf);
    80004214:	fffff097          	auipc	ra,0xfffff
    80004218:	f94080e7          	jalr	-108(ra) # 800031a8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000421c:	4505                	li	a0,1
    8000421e:	00000097          	auipc	ra,0x0
    80004222:	eca080e7          	jalr	-310(ra) # 800040e8 <install_trans>
  log.lh.n = 0;
    80004226:	0001d797          	auipc	a5,0x1d
    8000422a:	0607ab23          	sw	zero,118(a5) # 8002129c <log+0x2c>
  write_head(); // clear the log
    8000422e:	00000097          	auipc	ra,0x0
    80004232:	e50080e7          	jalr	-432(ra) # 8000407e <write_head>
}
    80004236:	70a2                	ld	ra,40(sp)
    80004238:	7402                	ld	s0,32(sp)
    8000423a:	64e2                	ld	s1,24(sp)
    8000423c:	6942                	ld	s2,16(sp)
    8000423e:	69a2                	ld	s3,8(sp)
    80004240:	6145                	add	sp,sp,48
    80004242:	8082                	ret

0000000080004244 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004244:	1101                	add	sp,sp,-32
    80004246:	ec06                	sd	ra,24(sp)
    80004248:	e822                	sd	s0,16(sp)
    8000424a:	e426                	sd	s1,8(sp)
    8000424c:	e04a                	sd	s2,0(sp)
    8000424e:	1000                	add	s0,sp,32
  acquire(&log.lock);
    80004250:	0001d517          	auipc	a0,0x1d
    80004254:	02050513          	add	a0,a0,32 # 80021270 <log>
    80004258:	ffffd097          	auipc	ra,0xffffd
    8000425c:	9da080e7          	jalr	-1574(ra) # 80000c32 <acquire>
  while(1){
    if(log.committing){
    80004260:	0001d497          	auipc	s1,0x1d
    80004264:	01048493          	add	s1,s1,16 # 80021270 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004268:	4979                	li	s2,30
    8000426a:	a039                	j	80004278 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000426c:	85a6                	mv	a1,s1
    8000426e:	8526                	mv	a0,s1
    80004270:	ffffe097          	auipc	ra,0xffffe
    80004274:	f80080e7          	jalr	-128(ra) # 800021f0 <sleep>
    if(log.committing){
    80004278:	50dc                	lw	a5,36(s1)
    8000427a:	fbed                	bnez	a5,8000426c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000427c:	5098                	lw	a4,32(s1)
    8000427e:	2705                	addw	a4,a4,1
    80004280:	0027179b          	sllw	a5,a4,0x2
    80004284:	9fb9                	addw	a5,a5,a4
    80004286:	0017979b          	sllw	a5,a5,0x1
    8000428a:	54d4                	lw	a3,44(s1)
    8000428c:	9fb5                	addw	a5,a5,a3
    8000428e:	00f95963          	bge	s2,a5,800042a0 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004292:	85a6                	mv	a1,s1
    80004294:	8526                	mv	a0,s1
    80004296:	ffffe097          	auipc	ra,0xffffe
    8000429a:	f5a080e7          	jalr	-166(ra) # 800021f0 <sleep>
    8000429e:	bfe9                	j	80004278 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800042a0:	0001d517          	auipc	a0,0x1d
    800042a4:	fd050513          	add	a0,a0,-48 # 80021270 <log>
    800042a8:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800042aa:	ffffd097          	auipc	ra,0xffffd
    800042ae:	a3c080e7          	jalr	-1476(ra) # 80000ce6 <release>
      break;
    }
  }
}
    800042b2:	60e2                	ld	ra,24(sp)
    800042b4:	6442                	ld	s0,16(sp)
    800042b6:	64a2                	ld	s1,8(sp)
    800042b8:	6902                	ld	s2,0(sp)
    800042ba:	6105                	add	sp,sp,32
    800042bc:	8082                	ret

00000000800042be <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042be:	7139                	add	sp,sp,-64
    800042c0:	fc06                	sd	ra,56(sp)
    800042c2:	f822                	sd	s0,48(sp)
    800042c4:	f426                	sd	s1,40(sp)
    800042c6:	f04a                	sd	s2,32(sp)
    800042c8:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042ca:	0001d497          	auipc	s1,0x1d
    800042ce:	fa648493          	add	s1,s1,-90 # 80021270 <log>
    800042d2:	8526                	mv	a0,s1
    800042d4:	ffffd097          	auipc	ra,0xffffd
    800042d8:	95e080e7          	jalr	-1698(ra) # 80000c32 <acquire>
  log.outstanding -= 1;
    800042dc:	509c                	lw	a5,32(s1)
    800042de:	37fd                	addw	a5,a5,-1
    800042e0:	0007891b          	sext.w	s2,a5
    800042e4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800042e6:	50dc                	lw	a5,36(s1)
    800042e8:	e7b9                	bnez	a5,80004336 <end_op+0x78>
    panic("log.committing");
  if(log.outstanding == 0){
    800042ea:	06091163          	bnez	s2,8000434c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800042ee:	0001d497          	auipc	s1,0x1d
    800042f2:	f8248493          	add	s1,s1,-126 # 80021270 <log>
    800042f6:	4785                	li	a5,1
    800042f8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042fa:	8526                	mv	a0,s1
    800042fc:	ffffd097          	auipc	ra,0xffffd
    80004300:	9ea080e7          	jalr	-1558(ra) # 80000ce6 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004304:	54dc                	lw	a5,44(s1)
    80004306:	06f04763          	bgtz	a5,80004374 <end_op+0xb6>
    acquire(&log.lock);
    8000430a:	0001d497          	auipc	s1,0x1d
    8000430e:	f6648493          	add	s1,s1,-154 # 80021270 <log>
    80004312:	8526                	mv	a0,s1
    80004314:	ffffd097          	auipc	ra,0xffffd
    80004318:	91e080e7          	jalr	-1762(ra) # 80000c32 <acquire>
    log.committing = 0;
    8000431c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004320:	8526                	mv	a0,s1
    80004322:	ffffe097          	auipc	ra,0xffffe
    80004326:	05a080e7          	jalr	90(ra) # 8000237c <wakeup>
    release(&log.lock);
    8000432a:	8526                	mv	a0,s1
    8000432c:	ffffd097          	auipc	ra,0xffffd
    80004330:	9ba080e7          	jalr	-1606(ra) # 80000ce6 <release>
}
    80004334:	a815                	j	80004368 <end_op+0xaa>
    80004336:	ec4e                	sd	s3,24(sp)
    80004338:	e852                	sd	s4,16(sp)
    8000433a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000433c:	00004517          	auipc	a0,0x4
    80004340:	20450513          	add	a0,a0,516 # 80008540 <etext+0x540>
    80004344:	ffffc097          	auipc	ra,0xffffc
    80004348:	216080e7          	jalr	534(ra) # 8000055a <panic>
    wakeup(&log);
    8000434c:	0001d497          	auipc	s1,0x1d
    80004350:	f2448493          	add	s1,s1,-220 # 80021270 <log>
    80004354:	8526                	mv	a0,s1
    80004356:	ffffe097          	auipc	ra,0xffffe
    8000435a:	026080e7          	jalr	38(ra) # 8000237c <wakeup>
  release(&log.lock);
    8000435e:	8526                	mv	a0,s1
    80004360:	ffffd097          	auipc	ra,0xffffd
    80004364:	986080e7          	jalr	-1658(ra) # 80000ce6 <release>
}
    80004368:	70e2                	ld	ra,56(sp)
    8000436a:	7442                	ld	s0,48(sp)
    8000436c:	74a2                	ld	s1,40(sp)
    8000436e:	7902                	ld	s2,32(sp)
    80004370:	6121                	add	sp,sp,64
    80004372:	8082                	ret
    80004374:	ec4e                	sd	s3,24(sp)
    80004376:	e852                	sd	s4,16(sp)
    80004378:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000437a:	0001da97          	auipc	s5,0x1d
    8000437e:	f26a8a93          	add	s5,s5,-218 # 800212a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004382:	0001da17          	auipc	s4,0x1d
    80004386:	eeea0a13          	add	s4,s4,-274 # 80021270 <log>
    8000438a:	018a2583          	lw	a1,24(s4)
    8000438e:	012585bb          	addw	a1,a1,s2
    80004392:	2585                	addw	a1,a1,1
    80004394:	028a2503          	lw	a0,40(s4)
    80004398:	fffff097          	auipc	ra,0xfffff
    8000439c:	ce0080e7          	jalr	-800(ra) # 80003078 <bread>
    800043a0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043a2:	000aa583          	lw	a1,0(s5)
    800043a6:	028a2503          	lw	a0,40(s4)
    800043aa:	fffff097          	auipc	ra,0xfffff
    800043ae:	cce080e7          	jalr	-818(ra) # 80003078 <bread>
    800043b2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800043b4:	40000613          	li	a2,1024
    800043b8:	05850593          	add	a1,a0,88
    800043bc:	05848513          	add	a0,s1,88
    800043c0:	ffffd097          	auipc	ra,0xffffd
    800043c4:	9ca080e7          	jalr	-1590(ra) # 80000d8a <memmove>
    bwrite(to);  // write the log
    800043c8:	8526                	mv	a0,s1
    800043ca:	fffff097          	auipc	ra,0xfffff
    800043ce:	da0080e7          	jalr	-608(ra) # 8000316a <bwrite>
    brelse(from);
    800043d2:	854e                	mv	a0,s3
    800043d4:	fffff097          	auipc	ra,0xfffff
    800043d8:	dd4080e7          	jalr	-556(ra) # 800031a8 <brelse>
    brelse(to);
    800043dc:	8526                	mv	a0,s1
    800043de:	fffff097          	auipc	ra,0xfffff
    800043e2:	dca080e7          	jalr	-566(ra) # 800031a8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043e6:	2905                	addw	s2,s2,1
    800043e8:	0a91                	add	s5,s5,4
    800043ea:	02ca2783          	lw	a5,44(s4)
    800043ee:	f8f94ee3          	blt	s2,a5,8000438a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043f2:	00000097          	auipc	ra,0x0
    800043f6:	c8c080e7          	jalr	-884(ra) # 8000407e <write_head>
    install_trans(0); // Now install writes to home locations
    800043fa:	4501                	li	a0,0
    800043fc:	00000097          	auipc	ra,0x0
    80004400:	cec080e7          	jalr	-788(ra) # 800040e8 <install_trans>
    log.lh.n = 0;
    80004404:	0001d797          	auipc	a5,0x1d
    80004408:	e807ac23          	sw	zero,-360(a5) # 8002129c <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000440c:	00000097          	auipc	ra,0x0
    80004410:	c72080e7          	jalr	-910(ra) # 8000407e <write_head>
    80004414:	69e2                	ld	s3,24(sp)
    80004416:	6a42                	ld	s4,16(sp)
    80004418:	6aa2                	ld	s5,8(sp)
    8000441a:	bdc5                	j	8000430a <end_op+0x4c>

000000008000441c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000441c:	1101                	add	sp,sp,-32
    8000441e:	ec06                	sd	ra,24(sp)
    80004420:	e822                	sd	s0,16(sp)
    80004422:	e426                	sd	s1,8(sp)
    80004424:	e04a                	sd	s2,0(sp)
    80004426:	1000                	add	s0,sp,32
    80004428:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000442a:	0001d917          	auipc	s2,0x1d
    8000442e:	e4690913          	add	s2,s2,-442 # 80021270 <log>
    80004432:	854a                	mv	a0,s2
    80004434:	ffffc097          	auipc	ra,0xffffc
    80004438:	7fe080e7          	jalr	2046(ra) # 80000c32 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000443c:	02c92603          	lw	a2,44(s2)
    80004440:	47f5                	li	a5,29
    80004442:	06c7c563          	blt	a5,a2,800044ac <log_write+0x90>
    80004446:	0001d797          	auipc	a5,0x1d
    8000444a:	e467a783          	lw	a5,-442(a5) # 8002128c <log+0x1c>
    8000444e:	37fd                	addw	a5,a5,-1
    80004450:	04f65e63          	bge	a2,a5,800044ac <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004454:	0001d797          	auipc	a5,0x1d
    80004458:	e3c7a783          	lw	a5,-452(a5) # 80021290 <log+0x20>
    8000445c:	06f05063          	blez	a5,800044bc <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004460:	4781                	li	a5,0
    80004462:	06c05563          	blez	a2,800044cc <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004466:	44cc                	lw	a1,12(s1)
    80004468:	0001d717          	auipc	a4,0x1d
    8000446c:	e3870713          	add	a4,a4,-456 # 800212a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004470:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004472:	4314                	lw	a3,0(a4)
    80004474:	04b68c63          	beq	a3,a1,800044cc <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004478:	2785                	addw	a5,a5,1
    8000447a:	0711                	add	a4,a4,4
    8000447c:	fef61be3          	bne	a2,a5,80004472 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004480:	0621                	add	a2,a2,8
    80004482:	060a                	sll	a2,a2,0x2
    80004484:	0001d797          	auipc	a5,0x1d
    80004488:	dec78793          	add	a5,a5,-532 # 80021270 <log>
    8000448c:	97b2                	add	a5,a5,a2
    8000448e:	44d8                	lw	a4,12(s1)
    80004490:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004492:	8526                	mv	a0,s1
    80004494:	fffff097          	auipc	ra,0xfffff
    80004498:	db0080e7          	jalr	-592(ra) # 80003244 <bpin>
    log.lh.n++;
    8000449c:	0001d717          	auipc	a4,0x1d
    800044a0:	dd470713          	add	a4,a4,-556 # 80021270 <log>
    800044a4:	575c                	lw	a5,44(a4)
    800044a6:	2785                	addw	a5,a5,1
    800044a8:	d75c                	sw	a5,44(a4)
    800044aa:	a82d                	j	800044e4 <log_write+0xc8>
    panic("too big a transaction");
    800044ac:	00004517          	auipc	a0,0x4
    800044b0:	0a450513          	add	a0,a0,164 # 80008550 <etext+0x550>
    800044b4:	ffffc097          	auipc	ra,0xffffc
    800044b8:	0a6080e7          	jalr	166(ra) # 8000055a <panic>
    panic("log_write outside of trans");
    800044bc:	00004517          	auipc	a0,0x4
    800044c0:	0ac50513          	add	a0,a0,172 # 80008568 <etext+0x568>
    800044c4:	ffffc097          	auipc	ra,0xffffc
    800044c8:	096080e7          	jalr	150(ra) # 8000055a <panic>
  log.lh.block[i] = b->blockno;
    800044cc:	00878693          	add	a3,a5,8
    800044d0:	068a                	sll	a3,a3,0x2
    800044d2:	0001d717          	auipc	a4,0x1d
    800044d6:	d9e70713          	add	a4,a4,-610 # 80021270 <log>
    800044da:	9736                	add	a4,a4,a3
    800044dc:	44d4                	lw	a3,12(s1)
    800044de:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800044e0:	faf609e3          	beq	a2,a5,80004492 <log_write+0x76>
  }
  release(&log.lock);
    800044e4:	0001d517          	auipc	a0,0x1d
    800044e8:	d8c50513          	add	a0,a0,-628 # 80021270 <log>
    800044ec:	ffffc097          	auipc	ra,0xffffc
    800044f0:	7fa080e7          	jalr	2042(ra) # 80000ce6 <release>
}
    800044f4:	60e2                	ld	ra,24(sp)
    800044f6:	6442                	ld	s0,16(sp)
    800044f8:	64a2                	ld	s1,8(sp)
    800044fa:	6902                	ld	s2,0(sp)
    800044fc:	6105                	add	sp,sp,32
    800044fe:	8082                	ret

0000000080004500 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004500:	1101                	add	sp,sp,-32
    80004502:	ec06                	sd	ra,24(sp)
    80004504:	e822                	sd	s0,16(sp)
    80004506:	e426                	sd	s1,8(sp)
    80004508:	e04a                	sd	s2,0(sp)
    8000450a:	1000                	add	s0,sp,32
    8000450c:	84aa                	mv	s1,a0
    8000450e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004510:	00004597          	auipc	a1,0x4
    80004514:	07858593          	add	a1,a1,120 # 80008588 <etext+0x588>
    80004518:	0521                	add	a0,a0,8
    8000451a:	ffffc097          	auipc	ra,0xffffc
    8000451e:	688080e7          	jalr	1672(ra) # 80000ba2 <initlock>
  lk->name = name;
    80004522:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004526:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000452a:	0204a423          	sw	zero,40(s1)
}
    8000452e:	60e2                	ld	ra,24(sp)
    80004530:	6442                	ld	s0,16(sp)
    80004532:	64a2                	ld	s1,8(sp)
    80004534:	6902                	ld	s2,0(sp)
    80004536:	6105                	add	sp,sp,32
    80004538:	8082                	ret

000000008000453a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000453a:	1101                	add	sp,sp,-32
    8000453c:	ec06                	sd	ra,24(sp)
    8000453e:	e822                	sd	s0,16(sp)
    80004540:	e426                	sd	s1,8(sp)
    80004542:	e04a                	sd	s2,0(sp)
    80004544:	1000                	add	s0,sp,32
    80004546:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004548:	00850913          	add	s2,a0,8
    8000454c:	854a                	mv	a0,s2
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	6e4080e7          	jalr	1764(ra) # 80000c32 <acquire>
  while (lk->locked) {
    80004556:	409c                	lw	a5,0(s1)
    80004558:	cb89                	beqz	a5,8000456a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000455a:	85ca                	mv	a1,s2
    8000455c:	8526                	mv	a0,s1
    8000455e:	ffffe097          	auipc	ra,0xffffe
    80004562:	c92080e7          	jalr	-878(ra) # 800021f0 <sleep>
  while (lk->locked) {
    80004566:	409c                	lw	a5,0(s1)
    80004568:	fbed                	bnez	a5,8000455a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000456a:	4785                	li	a5,1
    8000456c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000456e:	ffffd097          	auipc	ra,0xffffd
    80004572:	5bc080e7          	jalr	1468(ra) # 80001b2a <myproc>
    80004576:	591c                	lw	a5,48(a0)
    80004578:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000457a:	854a                	mv	a0,s2
    8000457c:	ffffc097          	auipc	ra,0xffffc
    80004580:	76a080e7          	jalr	1898(ra) # 80000ce6 <release>
}
    80004584:	60e2                	ld	ra,24(sp)
    80004586:	6442                	ld	s0,16(sp)
    80004588:	64a2                	ld	s1,8(sp)
    8000458a:	6902                	ld	s2,0(sp)
    8000458c:	6105                	add	sp,sp,32
    8000458e:	8082                	ret

0000000080004590 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004590:	1101                	add	sp,sp,-32
    80004592:	ec06                	sd	ra,24(sp)
    80004594:	e822                	sd	s0,16(sp)
    80004596:	e426                	sd	s1,8(sp)
    80004598:	e04a                	sd	s2,0(sp)
    8000459a:	1000                	add	s0,sp,32
    8000459c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000459e:	00850913          	add	s2,a0,8
    800045a2:	854a                	mv	a0,s2
    800045a4:	ffffc097          	auipc	ra,0xffffc
    800045a8:	68e080e7          	jalr	1678(ra) # 80000c32 <acquire>
  lk->locked = 0;
    800045ac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045b0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800045b4:	8526                	mv	a0,s1
    800045b6:	ffffe097          	auipc	ra,0xffffe
    800045ba:	dc6080e7          	jalr	-570(ra) # 8000237c <wakeup>
  release(&lk->lk);
    800045be:	854a                	mv	a0,s2
    800045c0:	ffffc097          	auipc	ra,0xffffc
    800045c4:	726080e7          	jalr	1830(ra) # 80000ce6 <release>
}
    800045c8:	60e2                	ld	ra,24(sp)
    800045ca:	6442                	ld	s0,16(sp)
    800045cc:	64a2                	ld	s1,8(sp)
    800045ce:	6902                	ld	s2,0(sp)
    800045d0:	6105                	add	sp,sp,32
    800045d2:	8082                	ret

00000000800045d4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800045d4:	7179                	add	sp,sp,-48
    800045d6:	f406                	sd	ra,40(sp)
    800045d8:	f022                	sd	s0,32(sp)
    800045da:	ec26                	sd	s1,24(sp)
    800045dc:	e84a                	sd	s2,16(sp)
    800045de:	1800                	add	s0,sp,48
    800045e0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800045e2:	00850913          	add	s2,a0,8
    800045e6:	854a                	mv	a0,s2
    800045e8:	ffffc097          	auipc	ra,0xffffc
    800045ec:	64a080e7          	jalr	1610(ra) # 80000c32 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800045f0:	409c                	lw	a5,0(s1)
    800045f2:	ef91                	bnez	a5,8000460e <holdingsleep+0x3a>
    800045f4:	4481                	li	s1,0
  release(&lk->lk);
    800045f6:	854a                	mv	a0,s2
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	6ee080e7          	jalr	1774(ra) # 80000ce6 <release>
  return r;
}
    80004600:	8526                	mv	a0,s1
    80004602:	70a2                	ld	ra,40(sp)
    80004604:	7402                	ld	s0,32(sp)
    80004606:	64e2                	ld	s1,24(sp)
    80004608:	6942                	ld	s2,16(sp)
    8000460a:	6145                	add	sp,sp,48
    8000460c:	8082                	ret
    8000460e:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004610:	0284a983          	lw	s3,40(s1)
    80004614:	ffffd097          	auipc	ra,0xffffd
    80004618:	516080e7          	jalr	1302(ra) # 80001b2a <myproc>
    8000461c:	5904                	lw	s1,48(a0)
    8000461e:	413484b3          	sub	s1,s1,s3
    80004622:	0014b493          	seqz	s1,s1
    80004626:	69a2                	ld	s3,8(sp)
    80004628:	b7f9                	j	800045f6 <holdingsleep+0x22>

000000008000462a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000462a:	1141                	add	sp,sp,-16
    8000462c:	e406                	sd	ra,8(sp)
    8000462e:	e022                	sd	s0,0(sp)
    80004630:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004632:	00004597          	auipc	a1,0x4
    80004636:	f6658593          	add	a1,a1,-154 # 80008598 <etext+0x598>
    8000463a:	0001d517          	auipc	a0,0x1d
    8000463e:	d7e50513          	add	a0,a0,-642 # 800213b8 <ftable>
    80004642:	ffffc097          	auipc	ra,0xffffc
    80004646:	560080e7          	jalr	1376(ra) # 80000ba2 <initlock>
}
    8000464a:	60a2                	ld	ra,8(sp)
    8000464c:	6402                	ld	s0,0(sp)
    8000464e:	0141                	add	sp,sp,16
    80004650:	8082                	ret

0000000080004652 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004652:	1101                	add	sp,sp,-32
    80004654:	ec06                	sd	ra,24(sp)
    80004656:	e822                	sd	s0,16(sp)
    80004658:	e426                	sd	s1,8(sp)
    8000465a:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000465c:	0001d517          	auipc	a0,0x1d
    80004660:	d5c50513          	add	a0,a0,-676 # 800213b8 <ftable>
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	5ce080e7          	jalr	1486(ra) # 80000c32 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000466c:	0001d497          	auipc	s1,0x1d
    80004670:	d6448493          	add	s1,s1,-668 # 800213d0 <ftable+0x18>
    80004674:	0001e717          	auipc	a4,0x1e
    80004678:	cfc70713          	add	a4,a4,-772 # 80022370 <ftable+0xfb8>
    if(f->ref == 0){
    8000467c:	40dc                	lw	a5,4(s1)
    8000467e:	cf99                	beqz	a5,8000469c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004680:	02848493          	add	s1,s1,40
    80004684:	fee49ce3          	bne	s1,a4,8000467c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004688:	0001d517          	auipc	a0,0x1d
    8000468c:	d3050513          	add	a0,a0,-720 # 800213b8 <ftable>
    80004690:	ffffc097          	auipc	ra,0xffffc
    80004694:	656080e7          	jalr	1622(ra) # 80000ce6 <release>
  return 0;
    80004698:	4481                	li	s1,0
    8000469a:	a819                	j	800046b0 <filealloc+0x5e>
      f->ref = 1;
    8000469c:	4785                	li	a5,1
    8000469e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800046a0:	0001d517          	auipc	a0,0x1d
    800046a4:	d1850513          	add	a0,a0,-744 # 800213b8 <ftable>
    800046a8:	ffffc097          	auipc	ra,0xffffc
    800046ac:	63e080e7          	jalr	1598(ra) # 80000ce6 <release>
}
    800046b0:	8526                	mv	a0,s1
    800046b2:	60e2                	ld	ra,24(sp)
    800046b4:	6442                	ld	s0,16(sp)
    800046b6:	64a2                	ld	s1,8(sp)
    800046b8:	6105                	add	sp,sp,32
    800046ba:	8082                	ret

00000000800046bc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800046bc:	1101                	add	sp,sp,-32
    800046be:	ec06                	sd	ra,24(sp)
    800046c0:	e822                	sd	s0,16(sp)
    800046c2:	e426                	sd	s1,8(sp)
    800046c4:	1000                	add	s0,sp,32
    800046c6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800046c8:	0001d517          	auipc	a0,0x1d
    800046cc:	cf050513          	add	a0,a0,-784 # 800213b8 <ftable>
    800046d0:	ffffc097          	auipc	ra,0xffffc
    800046d4:	562080e7          	jalr	1378(ra) # 80000c32 <acquire>
  if(f->ref < 1)
    800046d8:	40dc                	lw	a5,4(s1)
    800046da:	02f05263          	blez	a5,800046fe <filedup+0x42>
    panic("filedup");
  f->ref++;
    800046de:	2785                	addw	a5,a5,1
    800046e0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800046e2:	0001d517          	auipc	a0,0x1d
    800046e6:	cd650513          	add	a0,a0,-810 # 800213b8 <ftable>
    800046ea:	ffffc097          	auipc	ra,0xffffc
    800046ee:	5fc080e7          	jalr	1532(ra) # 80000ce6 <release>
  return f;
}
    800046f2:	8526                	mv	a0,s1
    800046f4:	60e2                	ld	ra,24(sp)
    800046f6:	6442                	ld	s0,16(sp)
    800046f8:	64a2                	ld	s1,8(sp)
    800046fa:	6105                	add	sp,sp,32
    800046fc:	8082                	ret
    panic("filedup");
    800046fe:	00004517          	auipc	a0,0x4
    80004702:	ea250513          	add	a0,a0,-350 # 800085a0 <etext+0x5a0>
    80004706:	ffffc097          	auipc	ra,0xffffc
    8000470a:	e54080e7          	jalr	-428(ra) # 8000055a <panic>

000000008000470e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000470e:	7139                	add	sp,sp,-64
    80004710:	fc06                	sd	ra,56(sp)
    80004712:	f822                	sd	s0,48(sp)
    80004714:	f426                	sd	s1,40(sp)
    80004716:	0080                	add	s0,sp,64
    80004718:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000471a:	0001d517          	auipc	a0,0x1d
    8000471e:	c9e50513          	add	a0,a0,-866 # 800213b8 <ftable>
    80004722:	ffffc097          	auipc	ra,0xffffc
    80004726:	510080e7          	jalr	1296(ra) # 80000c32 <acquire>
  if(f->ref < 1)
    8000472a:	40dc                	lw	a5,4(s1)
    8000472c:	04f05c63          	blez	a5,80004784 <fileclose+0x76>
    panic("fileclose");
  if(--f->ref > 0){
    80004730:	37fd                	addw	a5,a5,-1
    80004732:	0007871b          	sext.w	a4,a5
    80004736:	c0dc                	sw	a5,4(s1)
    80004738:	06e04263          	bgtz	a4,8000479c <fileclose+0x8e>
    8000473c:	f04a                	sd	s2,32(sp)
    8000473e:	ec4e                	sd	s3,24(sp)
    80004740:	e852                	sd	s4,16(sp)
    80004742:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004744:	0004a903          	lw	s2,0(s1)
    80004748:	0094ca83          	lbu	s5,9(s1)
    8000474c:	0104ba03          	ld	s4,16(s1)
    80004750:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004754:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004758:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000475c:	0001d517          	auipc	a0,0x1d
    80004760:	c5c50513          	add	a0,a0,-932 # 800213b8 <ftable>
    80004764:	ffffc097          	auipc	ra,0xffffc
    80004768:	582080e7          	jalr	1410(ra) # 80000ce6 <release>

  if(ff.type == FD_PIPE){
    8000476c:	4785                	li	a5,1
    8000476e:	04f90463          	beq	s2,a5,800047b6 <fileclose+0xa8>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004772:	3979                	addw	s2,s2,-2
    80004774:	4785                	li	a5,1
    80004776:	0527fb63          	bgeu	a5,s2,800047cc <fileclose+0xbe>
    8000477a:	7902                	ld	s2,32(sp)
    8000477c:	69e2                	ld	s3,24(sp)
    8000477e:	6a42                	ld	s4,16(sp)
    80004780:	6aa2                	ld	s5,8(sp)
    80004782:	a02d                	j	800047ac <fileclose+0x9e>
    80004784:	f04a                	sd	s2,32(sp)
    80004786:	ec4e                	sd	s3,24(sp)
    80004788:	e852                	sd	s4,16(sp)
    8000478a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000478c:	00004517          	auipc	a0,0x4
    80004790:	e1c50513          	add	a0,a0,-484 # 800085a8 <etext+0x5a8>
    80004794:	ffffc097          	auipc	ra,0xffffc
    80004798:	dc6080e7          	jalr	-570(ra) # 8000055a <panic>
    release(&ftable.lock);
    8000479c:	0001d517          	auipc	a0,0x1d
    800047a0:	c1c50513          	add	a0,a0,-996 # 800213b8 <ftable>
    800047a4:	ffffc097          	auipc	ra,0xffffc
    800047a8:	542080e7          	jalr	1346(ra) # 80000ce6 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800047ac:	70e2                	ld	ra,56(sp)
    800047ae:	7442                	ld	s0,48(sp)
    800047b0:	74a2                	ld	s1,40(sp)
    800047b2:	6121                	add	sp,sp,64
    800047b4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800047b6:	85d6                	mv	a1,s5
    800047b8:	8552                	mv	a0,s4
    800047ba:	00000097          	auipc	ra,0x0
    800047be:	3a2080e7          	jalr	930(ra) # 80004b5c <pipeclose>
    800047c2:	7902                	ld	s2,32(sp)
    800047c4:	69e2                	ld	s3,24(sp)
    800047c6:	6a42                	ld	s4,16(sp)
    800047c8:	6aa2                	ld	s5,8(sp)
    800047ca:	b7cd                	j	800047ac <fileclose+0x9e>
    begin_op();
    800047cc:	00000097          	auipc	ra,0x0
    800047d0:	a78080e7          	jalr	-1416(ra) # 80004244 <begin_op>
    iput(ff.ip);
    800047d4:	854e                	mv	a0,s3
    800047d6:	fffff097          	auipc	ra,0xfffff
    800047da:	25a080e7          	jalr	602(ra) # 80003a30 <iput>
    end_op();
    800047de:	00000097          	auipc	ra,0x0
    800047e2:	ae0080e7          	jalr	-1312(ra) # 800042be <end_op>
    800047e6:	7902                	ld	s2,32(sp)
    800047e8:	69e2                	ld	s3,24(sp)
    800047ea:	6a42                	ld	s4,16(sp)
    800047ec:	6aa2                	ld	s5,8(sp)
    800047ee:	bf7d                	j	800047ac <fileclose+0x9e>

00000000800047f0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800047f0:	715d                	add	sp,sp,-80
    800047f2:	e486                	sd	ra,72(sp)
    800047f4:	e0a2                	sd	s0,64(sp)
    800047f6:	fc26                	sd	s1,56(sp)
    800047f8:	f44e                	sd	s3,40(sp)
    800047fa:	0880                	add	s0,sp,80
    800047fc:	84aa                	mv	s1,a0
    800047fe:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004800:	ffffd097          	auipc	ra,0xffffd
    80004804:	32a080e7          	jalr	810(ra) # 80001b2a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004808:	409c                	lw	a5,0(s1)
    8000480a:	37f9                	addw	a5,a5,-2
    8000480c:	4705                	li	a4,1
    8000480e:	04f76863          	bltu	a4,a5,8000485e <filestat+0x6e>
    80004812:	f84a                	sd	s2,48(sp)
    80004814:	892a                	mv	s2,a0
    ilock(f->ip);
    80004816:	6c88                	ld	a0,24(s1)
    80004818:	fffff097          	auipc	ra,0xfffff
    8000481c:	05a080e7          	jalr	90(ra) # 80003872 <ilock>
    stati(f->ip, &st);
    80004820:	fb840593          	add	a1,s0,-72
    80004824:	6c88                	ld	a0,24(s1)
    80004826:	fffff097          	auipc	ra,0xfffff
    8000482a:	2da080e7          	jalr	730(ra) # 80003b00 <stati>
    iunlock(f->ip);
    8000482e:	6c88                	ld	a0,24(s1)
    80004830:	fffff097          	auipc	ra,0xfffff
    80004834:	108080e7          	jalr	264(ra) # 80003938 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004838:	46e1                	li	a3,24
    8000483a:	fb840613          	add	a2,s0,-72
    8000483e:	85ce                	mv	a1,s3
    80004840:	05093503          	ld	a0,80(s2)
    80004844:	ffffd097          	auipc	ra,0xffffd
    80004848:	e88080e7          	jalr	-376(ra) # 800016cc <copyout>
    8000484c:	41f5551b          	sraw	a0,a0,0x1f
    80004850:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004852:	60a6                	ld	ra,72(sp)
    80004854:	6406                	ld	s0,64(sp)
    80004856:	74e2                	ld	s1,56(sp)
    80004858:	79a2                	ld	s3,40(sp)
    8000485a:	6161                	add	sp,sp,80
    8000485c:	8082                	ret
  return -1;
    8000485e:	557d                	li	a0,-1
    80004860:	bfcd                	j	80004852 <filestat+0x62>

0000000080004862 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004862:	7179                	add	sp,sp,-48
    80004864:	f406                	sd	ra,40(sp)
    80004866:	f022                	sd	s0,32(sp)
    80004868:	e84a                	sd	s2,16(sp)
    8000486a:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000486c:	00854783          	lbu	a5,8(a0)
    80004870:	cbc5                	beqz	a5,80004920 <fileread+0xbe>
    80004872:	ec26                	sd	s1,24(sp)
    80004874:	e44e                	sd	s3,8(sp)
    80004876:	84aa                	mv	s1,a0
    80004878:	89ae                	mv	s3,a1
    8000487a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000487c:	411c                	lw	a5,0(a0)
    8000487e:	4705                	li	a4,1
    80004880:	04e78963          	beq	a5,a4,800048d2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004884:	470d                	li	a4,3
    80004886:	04e78f63          	beq	a5,a4,800048e4 <fileread+0x82>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000488a:	4709                	li	a4,2
    8000488c:	08e79263          	bne	a5,a4,80004910 <fileread+0xae>
    ilock(f->ip);
    80004890:	6d08                	ld	a0,24(a0)
    80004892:	fffff097          	auipc	ra,0xfffff
    80004896:	fe0080e7          	jalr	-32(ra) # 80003872 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000489a:	874a                	mv	a4,s2
    8000489c:	5094                	lw	a3,32(s1)
    8000489e:	864e                	mv	a2,s3
    800048a0:	4585                	li	a1,1
    800048a2:	6c88                	ld	a0,24(s1)
    800048a4:	fffff097          	auipc	ra,0xfffff
    800048a8:	286080e7          	jalr	646(ra) # 80003b2a <readi>
    800048ac:	892a                	mv	s2,a0
    800048ae:	00a05563          	blez	a0,800048b8 <fileread+0x56>
      f->off += r;
    800048b2:	509c                	lw	a5,32(s1)
    800048b4:	9fa9                	addw	a5,a5,a0
    800048b6:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800048b8:	6c88                	ld	a0,24(s1)
    800048ba:	fffff097          	auipc	ra,0xfffff
    800048be:	07e080e7          	jalr	126(ra) # 80003938 <iunlock>
    800048c2:	64e2                	ld	s1,24(sp)
    800048c4:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800048c6:	854a                	mv	a0,s2
    800048c8:	70a2                	ld	ra,40(sp)
    800048ca:	7402                	ld	s0,32(sp)
    800048cc:	6942                	ld	s2,16(sp)
    800048ce:	6145                	add	sp,sp,48
    800048d0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800048d2:	6908                	ld	a0,16(a0)
    800048d4:	00000097          	auipc	ra,0x0
    800048d8:	3fa080e7          	jalr	1018(ra) # 80004cce <piperead>
    800048dc:	892a                	mv	s2,a0
    800048de:	64e2                	ld	s1,24(sp)
    800048e0:	69a2                	ld	s3,8(sp)
    800048e2:	b7d5                	j	800048c6 <fileread+0x64>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800048e4:	02451783          	lh	a5,36(a0)
    800048e8:	03079693          	sll	a3,a5,0x30
    800048ec:	92c1                	srl	a3,a3,0x30
    800048ee:	4725                	li	a4,9
    800048f0:	02d76a63          	bltu	a4,a3,80004924 <fileread+0xc2>
    800048f4:	0792                	sll	a5,a5,0x4
    800048f6:	0001d717          	auipc	a4,0x1d
    800048fa:	a2270713          	add	a4,a4,-1502 # 80021318 <devsw>
    800048fe:	97ba                	add	a5,a5,a4
    80004900:	639c                	ld	a5,0(a5)
    80004902:	c78d                	beqz	a5,8000492c <fileread+0xca>
    r = devsw[f->major].read(1, addr, n);
    80004904:	4505                	li	a0,1
    80004906:	9782                	jalr	a5
    80004908:	892a                	mv	s2,a0
    8000490a:	64e2                	ld	s1,24(sp)
    8000490c:	69a2                	ld	s3,8(sp)
    8000490e:	bf65                	j	800048c6 <fileread+0x64>
    panic("fileread");
    80004910:	00004517          	auipc	a0,0x4
    80004914:	ca850513          	add	a0,a0,-856 # 800085b8 <etext+0x5b8>
    80004918:	ffffc097          	auipc	ra,0xffffc
    8000491c:	c42080e7          	jalr	-958(ra) # 8000055a <panic>
    return -1;
    80004920:	597d                	li	s2,-1
    80004922:	b755                	j	800048c6 <fileread+0x64>
      return -1;
    80004924:	597d                	li	s2,-1
    80004926:	64e2                	ld	s1,24(sp)
    80004928:	69a2                	ld	s3,8(sp)
    8000492a:	bf71                	j	800048c6 <fileread+0x64>
    8000492c:	597d                	li	s2,-1
    8000492e:	64e2                	ld	s1,24(sp)
    80004930:	69a2                	ld	s3,8(sp)
    80004932:	bf51                	j	800048c6 <fileread+0x64>

0000000080004934 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004934:	00954783          	lbu	a5,9(a0)
    80004938:	12078963          	beqz	a5,80004a6a <filewrite+0x136>
{
    8000493c:	715d                	add	sp,sp,-80
    8000493e:	e486                	sd	ra,72(sp)
    80004940:	e0a2                	sd	s0,64(sp)
    80004942:	f84a                	sd	s2,48(sp)
    80004944:	f052                	sd	s4,32(sp)
    80004946:	e85a                	sd	s6,16(sp)
    80004948:	0880                	add	s0,sp,80
    8000494a:	892a                	mv	s2,a0
    8000494c:	8b2e                	mv	s6,a1
    8000494e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004950:	411c                	lw	a5,0(a0)
    80004952:	4705                	li	a4,1
    80004954:	02e78763          	beq	a5,a4,80004982 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004958:	470d                	li	a4,3
    8000495a:	02e78a63          	beq	a5,a4,8000498e <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000495e:	4709                	li	a4,2
    80004960:	0ee79863          	bne	a5,a4,80004a50 <filewrite+0x11c>
    80004964:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004966:	0cc05463          	blez	a2,80004a2e <filewrite+0xfa>
    8000496a:	fc26                	sd	s1,56(sp)
    8000496c:	ec56                	sd	s5,24(sp)
    8000496e:	e45e                	sd	s7,8(sp)
    80004970:	e062                	sd	s8,0(sp)
    int i = 0;
    80004972:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004974:	6b85                	lui	s7,0x1
    80004976:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000497a:	6c05                	lui	s8,0x1
    8000497c:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004980:	a851                	j	80004a14 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004982:	6908                	ld	a0,16(a0)
    80004984:	00000097          	auipc	ra,0x0
    80004988:	248080e7          	jalr	584(ra) # 80004bcc <pipewrite>
    8000498c:	a85d                	j	80004a42 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000498e:	02451783          	lh	a5,36(a0)
    80004992:	03079693          	sll	a3,a5,0x30
    80004996:	92c1                	srl	a3,a3,0x30
    80004998:	4725                	li	a4,9
    8000499a:	0cd76a63          	bltu	a4,a3,80004a6e <filewrite+0x13a>
    8000499e:	0792                	sll	a5,a5,0x4
    800049a0:	0001d717          	auipc	a4,0x1d
    800049a4:	97870713          	add	a4,a4,-1672 # 80021318 <devsw>
    800049a8:	97ba                	add	a5,a5,a4
    800049aa:	679c                	ld	a5,8(a5)
    800049ac:	c3f9                	beqz	a5,80004a72 <filewrite+0x13e>
    ret = devsw[f->major].write(1, addr, n);
    800049ae:	4505                	li	a0,1
    800049b0:	9782                	jalr	a5
    800049b2:	a841                	j	80004a42 <filewrite+0x10e>
      if(n1 > max)
    800049b4:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800049b8:	00000097          	auipc	ra,0x0
    800049bc:	88c080e7          	jalr	-1908(ra) # 80004244 <begin_op>
      ilock(f->ip);
    800049c0:	01893503          	ld	a0,24(s2)
    800049c4:	fffff097          	auipc	ra,0xfffff
    800049c8:	eae080e7          	jalr	-338(ra) # 80003872 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800049cc:	8756                	mv	a4,s5
    800049ce:	02092683          	lw	a3,32(s2)
    800049d2:	01698633          	add	a2,s3,s6
    800049d6:	4585                	li	a1,1
    800049d8:	01893503          	ld	a0,24(s2)
    800049dc:	fffff097          	auipc	ra,0xfffff
    800049e0:	252080e7          	jalr	594(ra) # 80003c2e <writei>
    800049e4:	84aa                	mv	s1,a0
    800049e6:	00a05763          	blez	a0,800049f4 <filewrite+0xc0>
        f->off += r;
    800049ea:	02092783          	lw	a5,32(s2)
    800049ee:	9fa9                	addw	a5,a5,a0
    800049f0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800049f4:	01893503          	ld	a0,24(s2)
    800049f8:	fffff097          	auipc	ra,0xfffff
    800049fc:	f40080e7          	jalr	-192(ra) # 80003938 <iunlock>
      end_op();
    80004a00:	00000097          	auipc	ra,0x0
    80004a04:	8be080e7          	jalr	-1858(ra) # 800042be <end_op>

      if(r != n1){
    80004a08:	029a9563          	bne	s5,s1,80004a32 <filewrite+0xfe>
        // error from writei
        break;
      }
      i += r;
    80004a0c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a10:	0149da63          	bge	s3,s4,80004a24 <filewrite+0xf0>
      int n1 = n - i;
    80004a14:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004a18:	0004879b          	sext.w	a5,s1
    80004a1c:	f8fbdce3          	bge	s7,a5,800049b4 <filewrite+0x80>
    80004a20:	84e2                	mv	s1,s8
    80004a22:	bf49                	j	800049b4 <filewrite+0x80>
    80004a24:	74e2                	ld	s1,56(sp)
    80004a26:	6ae2                	ld	s5,24(sp)
    80004a28:	6ba2                	ld	s7,8(sp)
    80004a2a:	6c02                	ld	s8,0(sp)
    80004a2c:	a039                	j	80004a3a <filewrite+0x106>
    int i = 0;
    80004a2e:	4981                	li	s3,0
    80004a30:	a029                	j	80004a3a <filewrite+0x106>
    80004a32:	74e2                	ld	s1,56(sp)
    80004a34:	6ae2                	ld	s5,24(sp)
    80004a36:	6ba2                	ld	s7,8(sp)
    80004a38:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004a3a:	033a1e63          	bne	s4,s3,80004a76 <filewrite+0x142>
    80004a3e:	8552                	mv	a0,s4
    80004a40:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a42:	60a6                	ld	ra,72(sp)
    80004a44:	6406                	ld	s0,64(sp)
    80004a46:	7942                	ld	s2,48(sp)
    80004a48:	7a02                	ld	s4,32(sp)
    80004a4a:	6b42                	ld	s6,16(sp)
    80004a4c:	6161                	add	sp,sp,80
    80004a4e:	8082                	ret
    80004a50:	fc26                	sd	s1,56(sp)
    80004a52:	f44e                	sd	s3,40(sp)
    80004a54:	ec56                	sd	s5,24(sp)
    80004a56:	e45e                	sd	s7,8(sp)
    80004a58:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004a5a:	00004517          	auipc	a0,0x4
    80004a5e:	b6e50513          	add	a0,a0,-1170 # 800085c8 <etext+0x5c8>
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	af8080e7          	jalr	-1288(ra) # 8000055a <panic>
    return -1;
    80004a6a:	557d                	li	a0,-1
}
    80004a6c:	8082                	ret
      return -1;
    80004a6e:	557d                	li	a0,-1
    80004a70:	bfc9                	j	80004a42 <filewrite+0x10e>
    80004a72:	557d                	li	a0,-1
    80004a74:	b7f9                	j	80004a42 <filewrite+0x10e>
    ret = (i == n ? n : -1);
    80004a76:	557d                	li	a0,-1
    80004a78:	79a2                	ld	s3,40(sp)
    80004a7a:	b7e1                	j	80004a42 <filewrite+0x10e>

0000000080004a7c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004a7c:	7179                	add	sp,sp,-48
    80004a7e:	f406                	sd	ra,40(sp)
    80004a80:	f022                	sd	s0,32(sp)
    80004a82:	ec26                	sd	s1,24(sp)
    80004a84:	e052                	sd	s4,0(sp)
    80004a86:	1800                	add	s0,sp,48
    80004a88:	84aa                	mv	s1,a0
    80004a8a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004a8c:	0005b023          	sd	zero,0(a1)
    80004a90:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004a94:	00000097          	auipc	ra,0x0
    80004a98:	bbe080e7          	jalr	-1090(ra) # 80004652 <filealloc>
    80004a9c:	e088                	sd	a0,0(s1)
    80004a9e:	cd49                	beqz	a0,80004b38 <pipealloc+0xbc>
    80004aa0:	00000097          	auipc	ra,0x0
    80004aa4:	bb2080e7          	jalr	-1102(ra) # 80004652 <filealloc>
    80004aa8:	00aa3023          	sd	a0,0(s4)
    80004aac:	c141                	beqz	a0,80004b2c <pipealloc+0xb0>
    80004aae:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ab0:	ffffc097          	auipc	ra,0xffffc
    80004ab4:	092080e7          	jalr	146(ra) # 80000b42 <kalloc>
    80004ab8:	892a                	mv	s2,a0
    80004aba:	c13d                	beqz	a0,80004b20 <pipealloc+0xa4>
    80004abc:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004abe:	4985                	li	s3,1
    80004ac0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004ac4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ac8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004acc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004ad0:	00004597          	auipc	a1,0x4
    80004ad4:	b0858593          	add	a1,a1,-1272 # 800085d8 <etext+0x5d8>
    80004ad8:	ffffc097          	auipc	ra,0xffffc
    80004adc:	0ca080e7          	jalr	202(ra) # 80000ba2 <initlock>
  (*f0)->type = FD_PIPE;
    80004ae0:	609c                	ld	a5,0(s1)
    80004ae2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ae6:	609c                	ld	a5,0(s1)
    80004ae8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004aec:	609c                	ld	a5,0(s1)
    80004aee:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004af2:	609c                	ld	a5,0(s1)
    80004af4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004af8:	000a3783          	ld	a5,0(s4)
    80004afc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b00:	000a3783          	ld	a5,0(s4)
    80004b04:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b08:	000a3783          	ld	a5,0(s4)
    80004b0c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b10:	000a3783          	ld	a5,0(s4)
    80004b14:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b18:	4501                	li	a0,0
    80004b1a:	6942                	ld	s2,16(sp)
    80004b1c:	69a2                	ld	s3,8(sp)
    80004b1e:	a03d                	j	80004b4c <pipealloc+0xd0>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b20:	6088                	ld	a0,0(s1)
    80004b22:	c119                	beqz	a0,80004b28 <pipealloc+0xac>
    80004b24:	6942                	ld	s2,16(sp)
    80004b26:	a029                	j	80004b30 <pipealloc+0xb4>
    80004b28:	6942                	ld	s2,16(sp)
    80004b2a:	a039                	j	80004b38 <pipealloc+0xbc>
    80004b2c:	6088                	ld	a0,0(s1)
    80004b2e:	c50d                	beqz	a0,80004b58 <pipealloc+0xdc>
    fileclose(*f0);
    80004b30:	00000097          	auipc	ra,0x0
    80004b34:	bde080e7          	jalr	-1058(ra) # 8000470e <fileclose>
  if(*f1)
    80004b38:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b3c:	557d                	li	a0,-1
  if(*f1)
    80004b3e:	c799                	beqz	a5,80004b4c <pipealloc+0xd0>
    fileclose(*f1);
    80004b40:	853e                	mv	a0,a5
    80004b42:	00000097          	auipc	ra,0x0
    80004b46:	bcc080e7          	jalr	-1076(ra) # 8000470e <fileclose>
  return -1;
    80004b4a:	557d                	li	a0,-1
}
    80004b4c:	70a2                	ld	ra,40(sp)
    80004b4e:	7402                	ld	s0,32(sp)
    80004b50:	64e2                	ld	s1,24(sp)
    80004b52:	6a02                	ld	s4,0(sp)
    80004b54:	6145                	add	sp,sp,48
    80004b56:	8082                	ret
  return -1;
    80004b58:	557d                	li	a0,-1
    80004b5a:	bfcd                	j	80004b4c <pipealloc+0xd0>

0000000080004b5c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b5c:	1101                	add	sp,sp,-32
    80004b5e:	ec06                	sd	ra,24(sp)
    80004b60:	e822                	sd	s0,16(sp)
    80004b62:	e426                	sd	s1,8(sp)
    80004b64:	e04a                	sd	s2,0(sp)
    80004b66:	1000                	add	s0,sp,32
    80004b68:	84aa                	mv	s1,a0
    80004b6a:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b6c:	ffffc097          	auipc	ra,0xffffc
    80004b70:	0c6080e7          	jalr	198(ra) # 80000c32 <acquire>
  if(writable){
    80004b74:	02090d63          	beqz	s2,80004bae <pipeclose+0x52>
    pi->writeopen = 0;
    80004b78:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004b7c:	21848513          	add	a0,s1,536
    80004b80:	ffffd097          	auipc	ra,0xffffd
    80004b84:	7fc080e7          	jalr	2044(ra) # 8000237c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004b88:	2204b783          	ld	a5,544(s1)
    80004b8c:	eb95                	bnez	a5,80004bc0 <pipeclose+0x64>
    release(&pi->lock);
    80004b8e:	8526                	mv	a0,s1
    80004b90:	ffffc097          	auipc	ra,0xffffc
    80004b94:	156080e7          	jalr	342(ra) # 80000ce6 <release>
    kfree((char*)pi);
    80004b98:	8526                	mv	a0,s1
    80004b9a:	ffffc097          	auipc	ra,0xffffc
    80004b9e:	eaa080e7          	jalr	-342(ra) # 80000a44 <kfree>
  } else
    release(&pi->lock);
}
    80004ba2:	60e2                	ld	ra,24(sp)
    80004ba4:	6442                	ld	s0,16(sp)
    80004ba6:	64a2                	ld	s1,8(sp)
    80004ba8:	6902                	ld	s2,0(sp)
    80004baa:	6105                	add	sp,sp,32
    80004bac:	8082                	ret
    pi->readopen = 0;
    80004bae:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004bb2:	21c48513          	add	a0,s1,540
    80004bb6:	ffffd097          	auipc	ra,0xffffd
    80004bba:	7c6080e7          	jalr	1990(ra) # 8000237c <wakeup>
    80004bbe:	b7e9                	j	80004b88 <pipeclose+0x2c>
    release(&pi->lock);
    80004bc0:	8526                	mv	a0,s1
    80004bc2:	ffffc097          	auipc	ra,0xffffc
    80004bc6:	124080e7          	jalr	292(ra) # 80000ce6 <release>
}
    80004bca:	bfe1                	j	80004ba2 <pipeclose+0x46>

0000000080004bcc <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bcc:	711d                	add	sp,sp,-96
    80004bce:	ec86                	sd	ra,88(sp)
    80004bd0:	e8a2                	sd	s0,80(sp)
    80004bd2:	e4a6                	sd	s1,72(sp)
    80004bd4:	e0ca                	sd	s2,64(sp)
    80004bd6:	fc4e                	sd	s3,56(sp)
    80004bd8:	f852                	sd	s4,48(sp)
    80004bda:	f456                	sd	s5,40(sp)
    80004bdc:	1080                	add	s0,sp,96
    80004bde:	84aa                	mv	s1,a0
    80004be0:	8aae                	mv	s5,a1
    80004be2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004be4:	ffffd097          	auipc	ra,0xffffd
    80004be8:	f46080e7          	jalr	-186(ra) # 80001b2a <myproc>
    80004bec:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004bee:	8526                	mv	a0,s1
    80004bf0:	ffffc097          	auipc	ra,0xffffc
    80004bf4:	042080e7          	jalr	66(ra) # 80000c32 <acquire>
  while(i < n){
    80004bf8:	0d405563          	blez	s4,80004cc2 <pipewrite+0xf6>
    80004bfc:	f05a                	sd	s6,32(sp)
    80004bfe:	ec5e                	sd	s7,24(sp)
    80004c00:	e862                	sd	s8,16(sp)
  int i = 0;
    80004c02:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c04:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c06:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c0a:	21c48b93          	add	s7,s1,540
    80004c0e:	a089                	j	80004c50 <pipewrite+0x84>
      release(&pi->lock);
    80004c10:	8526                	mv	a0,s1
    80004c12:	ffffc097          	auipc	ra,0xffffc
    80004c16:	0d4080e7          	jalr	212(ra) # 80000ce6 <release>
      return -1;
    80004c1a:	597d                	li	s2,-1
    80004c1c:	7b02                	ld	s6,32(sp)
    80004c1e:	6be2                	ld	s7,24(sp)
    80004c20:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c22:	854a                	mv	a0,s2
    80004c24:	60e6                	ld	ra,88(sp)
    80004c26:	6446                	ld	s0,80(sp)
    80004c28:	64a6                	ld	s1,72(sp)
    80004c2a:	6906                	ld	s2,64(sp)
    80004c2c:	79e2                	ld	s3,56(sp)
    80004c2e:	7a42                	ld	s4,48(sp)
    80004c30:	7aa2                	ld	s5,40(sp)
    80004c32:	6125                	add	sp,sp,96
    80004c34:	8082                	ret
      wakeup(&pi->nread);
    80004c36:	8562                	mv	a0,s8
    80004c38:	ffffd097          	auipc	ra,0xffffd
    80004c3c:	744080e7          	jalr	1860(ra) # 8000237c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c40:	85a6                	mv	a1,s1
    80004c42:	855e                	mv	a0,s7
    80004c44:	ffffd097          	auipc	ra,0xffffd
    80004c48:	5ac080e7          	jalr	1452(ra) # 800021f0 <sleep>
  while(i < n){
    80004c4c:	05495c63          	bge	s2,s4,80004ca4 <pipewrite+0xd8>
    if(pi->readopen == 0 || pr->killed){
    80004c50:	2204a783          	lw	a5,544(s1)
    80004c54:	dfd5                	beqz	a5,80004c10 <pipewrite+0x44>
    80004c56:	0289a783          	lw	a5,40(s3)
    80004c5a:	fbdd                	bnez	a5,80004c10 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c5c:	2184a783          	lw	a5,536(s1)
    80004c60:	21c4a703          	lw	a4,540(s1)
    80004c64:	2007879b          	addw	a5,a5,512
    80004c68:	fcf707e3          	beq	a4,a5,80004c36 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c6c:	4685                	li	a3,1
    80004c6e:	01590633          	add	a2,s2,s5
    80004c72:	faf40593          	add	a1,s0,-81
    80004c76:	0509b503          	ld	a0,80(s3)
    80004c7a:	ffffd097          	auipc	ra,0xffffd
    80004c7e:	ade080e7          	jalr	-1314(ra) # 80001758 <copyin>
    80004c82:	05650263          	beq	a0,s6,80004cc6 <pipewrite+0xfa>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004c86:	21c4a783          	lw	a5,540(s1)
    80004c8a:	0017871b          	addw	a4,a5,1
    80004c8e:	20e4ae23          	sw	a4,540(s1)
    80004c92:	1ff7f793          	and	a5,a5,511
    80004c96:	97a6                	add	a5,a5,s1
    80004c98:	faf44703          	lbu	a4,-81(s0)
    80004c9c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ca0:	2905                	addw	s2,s2,1
    80004ca2:	b76d                	j	80004c4c <pipewrite+0x80>
    80004ca4:	7b02                	ld	s6,32(sp)
    80004ca6:	6be2                	ld	s7,24(sp)
    80004ca8:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004caa:	21848513          	add	a0,s1,536
    80004cae:	ffffd097          	auipc	ra,0xffffd
    80004cb2:	6ce080e7          	jalr	1742(ra) # 8000237c <wakeup>
  release(&pi->lock);
    80004cb6:	8526                	mv	a0,s1
    80004cb8:	ffffc097          	auipc	ra,0xffffc
    80004cbc:	02e080e7          	jalr	46(ra) # 80000ce6 <release>
  return i;
    80004cc0:	b78d                	j	80004c22 <pipewrite+0x56>
  int i = 0;
    80004cc2:	4901                	li	s2,0
    80004cc4:	b7dd                	j	80004caa <pipewrite+0xde>
    80004cc6:	7b02                	ld	s6,32(sp)
    80004cc8:	6be2                	ld	s7,24(sp)
    80004cca:	6c42                	ld	s8,16(sp)
    80004ccc:	bff9                	j	80004caa <pipewrite+0xde>

0000000080004cce <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cce:	715d                	add	sp,sp,-80
    80004cd0:	e486                	sd	ra,72(sp)
    80004cd2:	e0a2                	sd	s0,64(sp)
    80004cd4:	fc26                	sd	s1,56(sp)
    80004cd6:	f84a                	sd	s2,48(sp)
    80004cd8:	f44e                	sd	s3,40(sp)
    80004cda:	f052                	sd	s4,32(sp)
    80004cdc:	ec56                	sd	s5,24(sp)
    80004cde:	0880                	add	s0,sp,80
    80004ce0:	84aa                	mv	s1,a0
    80004ce2:	892e                	mv	s2,a1
    80004ce4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ce6:	ffffd097          	auipc	ra,0xffffd
    80004cea:	e44080e7          	jalr	-444(ra) # 80001b2a <myproc>
    80004cee:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004cf0:	8526                	mv	a0,s1
    80004cf2:	ffffc097          	auipc	ra,0xffffc
    80004cf6:	f40080e7          	jalr	-192(ra) # 80000c32 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004cfa:	2184a703          	lw	a4,536(s1)
    80004cfe:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d02:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d06:	02f71663          	bne	a4,a5,80004d32 <piperead+0x64>
    80004d0a:	2244a783          	lw	a5,548(s1)
    80004d0e:	cb9d                	beqz	a5,80004d44 <piperead+0x76>
    if(pr->killed){
    80004d10:	028a2783          	lw	a5,40(s4)
    80004d14:	e38d                	bnez	a5,80004d36 <piperead+0x68>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d16:	85a6                	mv	a1,s1
    80004d18:	854e                	mv	a0,s3
    80004d1a:	ffffd097          	auipc	ra,0xffffd
    80004d1e:	4d6080e7          	jalr	1238(ra) # 800021f0 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d22:	2184a703          	lw	a4,536(s1)
    80004d26:	21c4a783          	lw	a5,540(s1)
    80004d2a:	fef700e3          	beq	a4,a5,80004d0a <piperead+0x3c>
    80004d2e:	e85a                	sd	s6,16(sp)
    80004d30:	a819                	j	80004d46 <piperead+0x78>
    80004d32:	e85a                	sd	s6,16(sp)
    80004d34:	a809                	j	80004d46 <piperead+0x78>
      release(&pi->lock);
    80004d36:	8526                	mv	a0,s1
    80004d38:	ffffc097          	auipc	ra,0xffffc
    80004d3c:	fae080e7          	jalr	-82(ra) # 80000ce6 <release>
      return -1;
    80004d40:	59fd                	li	s3,-1
    80004d42:	a0a5                	j	80004daa <piperead+0xdc>
    80004d44:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d46:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d48:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d4a:	05505463          	blez	s5,80004d92 <piperead+0xc4>
    if(pi->nread == pi->nwrite)
    80004d4e:	2184a783          	lw	a5,536(s1)
    80004d52:	21c4a703          	lw	a4,540(s1)
    80004d56:	02f70e63          	beq	a4,a5,80004d92 <piperead+0xc4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d5a:	0017871b          	addw	a4,a5,1
    80004d5e:	20e4ac23          	sw	a4,536(s1)
    80004d62:	1ff7f793          	and	a5,a5,511
    80004d66:	97a6                	add	a5,a5,s1
    80004d68:	0187c783          	lbu	a5,24(a5)
    80004d6c:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d70:	4685                	li	a3,1
    80004d72:	fbf40613          	add	a2,s0,-65
    80004d76:	85ca                	mv	a1,s2
    80004d78:	050a3503          	ld	a0,80(s4)
    80004d7c:	ffffd097          	auipc	ra,0xffffd
    80004d80:	950080e7          	jalr	-1712(ra) # 800016cc <copyout>
    80004d84:	01650763          	beq	a0,s6,80004d92 <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d88:	2985                	addw	s3,s3,1
    80004d8a:	0905                	add	s2,s2,1
    80004d8c:	fd3a91e3          	bne	s5,s3,80004d4e <piperead+0x80>
    80004d90:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004d92:	21c48513          	add	a0,s1,540
    80004d96:	ffffd097          	auipc	ra,0xffffd
    80004d9a:	5e6080e7          	jalr	1510(ra) # 8000237c <wakeup>
  release(&pi->lock);
    80004d9e:	8526                	mv	a0,s1
    80004da0:	ffffc097          	auipc	ra,0xffffc
    80004da4:	f46080e7          	jalr	-186(ra) # 80000ce6 <release>
    80004da8:	6b42                	ld	s6,16(sp)
  return i;
}
    80004daa:	854e                	mv	a0,s3
    80004dac:	60a6                	ld	ra,72(sp)
    80004dae:	6406                	ld	s0,64(sp)
    80004db0:	74e2                	ld	s1,56(sp)
    80004db2:	7942                	ld	s2,48(sp)
    80004db4:	79a2                	ld	s3,40(sp)
    80004db6:	7a02                	ld	s4,32(sp)
    80004db8:	6ae2                	ld	s5,24(sp)
    80004dba:	6161                	add	sp,sp,80
    80004dbc:	8082                	ret

0000000080004dbe <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004dbe:	df010113          	add	sp,sp,-528
    80004dc2:	20113423          	sd	ra,520(sp)
    80004dc6:	20813023          	sd	s0,512(sp)
    80004dca:	ffa6                	sd	s1,504(sp)
    80004dcc:	fbca                	sd	s2,496(sp)
    80004dce:	0c00                	add	s0,sp,528
    80004dd0:	892a                	mv	s2,a0
    80004dd2:	dea43c23          	sd	a0,-520(s0)
    80004dd6:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004dda:	ffffd097          	auipc	ra,0xffffd
    80004dde:	d50080e7          	jalr	-688(ra) # 80001b2a <myproc>
    80004de2:	84aa                	mv	s1,a0

  begin_op();
    80004de4:	fffff097          	auipc	ra,0xfffff
    80004de8:	460080e7          	jalr	1120(ra) # 80004244 <begin_op>

  if((ip = namei(path)) == 0){
    80004dec:	854a                	mv	a0,s2
    80004dee:	fffff097          	auipc	ra,0xfffff
    80004df2:	256080e7          	jalr	598(ra) # 80004044 <namei>
    80004df6:	c135                	beqz	a0,80004e5a <exec+0x9c>
    80004df8:	f3d2                	sd	s4,480(sp)
    80004dfa:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004dfc:	fffff097          	auipc	ra,0xfffff
    80004e00:	a76080e7          	jalr	-1418(ra) # 80003872 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e04:	04000713          	li	a4,64
    80004e08:	4681                	li	a3,0
    80004e0a:	e5040613          	add	a2,s0,-432
    80004e0e:	4581                	li	a1,0
    80004e10:	8552                	mv	a0,s4
    80004e12:	fffff097          	auipc	ra,0xfffff
    80004e16:	d18080e7          	jalr	-744(ra) # 80003b2a <readi>
    80004e1a:	04000793          	li	a5,64
    80004e1e:	00f51a63          	bne	a0,a5,80004e32 <exec+0x74>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004e22:	e5042703          	lw	a4,-432(s0)
    80004e26:	464c47b7          	lui	a5,0x464c4
    80004e2a:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e2e:	02f70c63          	beq	a4,a5,80004e66 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e32:	8552                	mv	a0,s4
    80004e34:	fffff097          	auipc	ra,0xfffff
    80004e38:	ca4080e7          	jalr	-860(ra) # 80003ad8 <iunlockput>
    end_op();
    80004e3c:	fffff097          	auipc	ra,0xfffff
    80004e40:	482080e7          	jalr	1154(ra) # 800042be <end_op>
  }
  return -1;
    80004e44:	557d                	li	a0,-1
    80004e46:	7a1e                	ld	s4,480(sp)
}
    80004e48:	20813083          	ld	ra,520(sp)
    80004e4c:	20013403          	ld	s0,512(sp)
    80004e50:	74fe                	ld	s1,504(sp)
    80004e52:	795e                	ld	s2,496(sp)
    80004e54:	21010113          	add	sp,sp,528
    80004e58:	8082                	ret
    end_op();
    80004e5a:	fffff097          	auipc	ra,0xfffff
    80004e5e:	464080e7          	jalr	1124(ra) # 800042be <end_op>
    return -1;
    80004e62:	557d                	li	a0,-1
    80004e64:	b7d5                	j	80004e48 <exec+0x8a>
    80004e66:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004e68:	8526                	mv	a0,s1
    80004e6a:	ffffd097          	auipc	ra,0xffffd
    80004e6e:	d84080e7          	jalr	-636(ra) # 80001bee <proc_pagetable>
    80004e72:	8b2a                	mv	s6,a0
    80004e74:	30050b63          	beqz	a0,8000518a <exec+0x3cc>
    80004e78:	f7ce                	sd	s3,488(sp)
    80004e7a:	efd6                	sd	s5,472(sp)
    80004e7c:	e7de                	sd	s7,456(sp)
    80004e7e:	e3e2                	sd	s8,448(sp)
    80004e80:	ff66                	sd	s9,440(sp)
    80004e82:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e84:	e7042d03          	lw	s10,-400(s0)
    80004e88:	e8845783          	lhu	a5,-376(s0)
    80004e8c:	14078563          	beqz	a5,80004fd6 <exec+0x218>
    80004e90:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e92:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e94:	4d81                	li	s11,0
    if((ph.vaddr % PGSIZE) != 0)
    80004e96:	6c85                	lui	s9,0x1
    80004e98:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004e9c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004ea0:	6a85                	lui	s5,0x1
    80004ea2:	a0b5                	j	80004f0e <exec+0x150>
      panic("loadseg: address should exist");
    80004ea4:	00003517          	auipc	a0,0x3
    80004ea8:	73c50513          	add	a0,a0,1852 # 800085e0 <etext+0x5e0>
    80004eac:	ffffb097          	auipc	ra,0xffffb
    80004eb0:	6ae080e7          	jalr	1710(ra) # 8000055a <panic>
    if(sz - i < PGSIZE)
    80004eb4:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004eb6:	8726                	mv	a4,s1
    80004eb8:	012c06bb          	addw	a3,s8,s2
    80004ebc:	4581                	li	a1,0
    80004ebe:	8552                	mv	a0,s4
    80004ec0:	fffff097          	auipc	ra,0xfffff
    80004ec4:	c6a080e7          	jalr	-918(ra) # 80003b2a <readi>
    80004ec8:	2501                	sext.w	a0,a0
    80004eca:	28a49463          	bne	s1,a0,80005152 <exec+0x394>
  for(i = 0; i < sz; i += PGSIZE){
    80004ece:	012a893b          	addw	s2,s5,s2
    80004ed2:	03397563          	bgeu	s2,s3,80004efc <exec+0x13e>
    pa = walkaddr(pagetable, va + i);
    80004ed6:	02091593          	sll	a1,s2,0x20
    80004eda:	9181                	srl	a1,a1,0x20
    80004edc:	95de                	add	a1,a1,s7
    80004ede:	855a                	mv	a0,s6
    80004ee0:	ffffc097          	auipc	ra,0xffffc
    80004ee4:	1cc080e7          	jalr	460(ra) # 800010ac <walkaddr>
    80004ee8:	862a                	mv	a2,a0
    if(pa == 0)
    80004eea:	dd4d                	beqz	a0,80004ea4 <exec+0xe6>
    if(sz - i < PGSIZE)
    80004eec:	412984bb          	subw	s1,s3,s2
    80004ef0:	0004879b          	sext.w	a5,s1
    80004ef4:	fcfcf0e3          	bgeu	s9,a5,80004eb4 <exec+0xf6>
    80004ef8:	84d6                	mv	s1,s5
    80004efa:	bf6d                	j	80004eb4 <exec+0xf6>
    sz = sz1;
    80004efc:	e0843483          	ld	s1,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f00:	2d85                	addw	s11,s11,1
    80004f02:	038d0d1b          	addw	s10,s10,56
    80004f06:	e8845783          	lhu	a5,-376(s0)
    80004f0a:	06fddf63          	bge	s11,a5,80004f88 <exec+0x1ca>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f0e:	2d01                	sext.w	s10,s10
    80004f10:	03800713          	li	a4,56
    80004f14:	86ea                	mv	a3,s10
    80004f16:	e1840613          	add	a2,s0,-488
    80004f1a:	4581                	li	a1,0
    80004f1c:	8552                	mv	a0,s4
    80004f1e:	fffff097          	auipc	ra,0xfffff
    80004f22:	c0c080e7          	jalr	-1012(ra) # 80003b2a <readi>
    80004f26:	03800793          	li	a5,56
    80004f2a:	1ef51e63          	bne	a0,a5,80005126 <exec+0x368>
    if(ph.type != ELF_PROG_LOAD)
    80004f2e:	e1842783          	lw	a5,-488(s0)
    80004f32:	4705                	li	a4,1
    80004f34:	fce796e3          	bne	a5,a4,80004f00 <exec+0x142>
    if(ph.memsz < ph.filesz)
    80004f38:	e4043603          	ld	a2,-448(s0)
    80004f3c:	e3843783          	ld	a5,-456(s0)
    80004f40:	1ef66763          	bltu	a2,a5,8000512e <exec+0x370>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004f44:	e2843783          	ld	a5,-472(s0)
    80004f48:	963e                	add	a2,a2,a5
    80004f4a:	1ef66663          	bltu	a2,a5,80005136 <exec+0x378>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f4e:	85a6                	mv	a1,s1
    80004f50:	855a                	mv	a0,s6
    80004f52:	ffffc097          	auipc	ra,0xffffc
    80004f56:	51e080e7          	jalr	1310(ra) # 80001470 <uvmalloc>
    80004f5a:	e0a43423          	sd	a0,-504(s0)
    80004f5e:	1e050063          	beqz	a0,8000513e <exec+0x380>
    if((ph.vaddr % PGSIZE) != 0)
    80004f62:	e2843b83          	ld	s7,-472(s0)
    80004f66:	df043783          	ld	a5,-528(s0)
    80004f6a:	00fbf7b3          	and	a5,s7,a5
    80004f6e:	1e079063          	bnez	a5,8000514e <exec+0x390>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f72:	e2042c03          	lw	s8,-480(s0)
    80004f76:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004f7a:	00098463          	beqz	s3,80004f82 <exec+0x1c4>
    80004f7e:	4901                	li	s2,0
    80004f80:	bf99                	j	80004ed6 <exec+0x118>
    sz = sz1;
    80004f82:	e0843483          	ld	s1,-504(s0)
    80004f86:	bfad                	j	80004f00 <exec+0x142>
    80004f88:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004f8a:	8552                	mv	a0,s4
    80004f8c:	fffff097          	auipc	ra,0xfffff
    80004f90:	b4c080e7          	jalr	-1204(ra) # 80003ad8 <iunlockput>
  end_op();
    80004f94:	fffff097          	auipc	ra,0xfffff
    80004f98:	32a080e7          	jalr	810(ra) # 800042be <end_op>
  p = myproc();
    80004f9c:	ffffd097          	auipc	ra,0xffffd
    80004fa0:	b8e080e7          	jalr	-1138(ra) # 80001b2a <myproc>
    80004fa4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004fa6:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004faa:	6985                	lui	s3,0x1
    80004fac:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004fae:	99a6                	add	s3,s3,s1
    80004fb0:	77fd                	lui	a5,0xfffff
    80004fb2:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004fb6:	6609                	lui	a2,0x2
    80004fb8:	964e                	add	a2,a2,s3
    80004fba:	85ce                	mv	a1,s3
    80004fbc:	855a                	mv	a0,s6
    80004fbe:	ffffc097          	auipc	ra,0xffffc
    80004fc2:	4b2080e7          	jalr	1202(ra) # 80001470 <uvmalloc>
    80004fc6:	892a                	mv	s2,a0
    80004fc8:	e0a43423          	sd	a0,-504(s0)
    80004fcc:	e519                	bnez	a0,80004fda <exec+0x21c>
  if(pagetable)
    80004fce:	e1343423          	sd	s3,-504(s0)
    80004fd2:	4a01                	li	s4,0
    80004fd4:	a241                	j	80005154 <exec+0x396>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fd6:	4481                	li	s1,0
    80004fd8:	bf4d                	j	80004f8a <exec+0x1cc>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fda:	75f9                	lui	a1,0xffffe
    80004fdc:	95aa                	add	a1,a1,a0
    80004fde:	855a                	mv	a0,s6
    80004fe0:	ffffc097          	auipc	ra,0xffffc
    80004fe4:	6ba080e7          	jalr	1722(ra) # 8000169a <uvmclear>
  stackbase = sp - PGSIZE;
    80004fe8:	7bfd                	lui	s7,0xfffff
    80004fea:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004fec:	e0043783          	ld	a5,-512(s0)
    80004ff0:	6388                	ld	a0,0(a5)
    80004ff2:	c52d                	beqz	a0,8000505c <exec+0x29e>
    80004ff4:	e9040993          	add	s3,s0,-368
    80004ff8:	f9040c13          	add	s8,s0,-112
    80004ffc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004ffe:	ffffc097          	auipc	ra,0xffffc
    80005002:	ea4080e7          	jalr	-348(ra) # 80000ea2 <strlen>
    80005006:	0015079b          	addw	a5,a0,1
    8000500a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000500e:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    80005012:	13796a63          	bltu	s2,s7,80005146 <exec+0x388>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005016:	e0043d03          	ld	s10,-512(s0)
    8000501a:	000d3a03          	ld	s4,0(s10)
    8000501e:	8552                	mv	a0,s4
    80005020:	ffffc097          	auipc	ra,0xffffc
    80005024:	e82080e7          	jalr	-382(ra) # 80000ea2 <strlen>
    80005028:	0015069b          	addw	a3,a0,1
    8000502c:	8652                	mv	a2,s4
    8000502e:	85ca                	mv	a1,s2
    80005030:	855a                	mv	a0,s6
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	69a080e7          	jalr	1690(ra) # 800016cc <copyout>
    8000503a:	10054863          	bltz	a0,8000514a <exec+0x38c>
    ustack[argc] = sp;
    8000503e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005042:	0485                	add	s1,s1,1
    80005044:	008d0793          	add	a5,s10,8
    80005048:	e0f43023          	sd	a5,-512(s0)
    8000504c:	008d3503          	ld	a0,8(s10)
    80005050:	c909                	beqz	a0,80005062 <exec+0x2a4>
    if(argc >= MAXARG)
    80005052:	09a1                	add	s3,s3,8
    80005054:	fb8995e3          	bne	s3,s8,80004ffe <exec+0x240>
  ip = 0;
    80005058:	4a01                	li	s4,0
    8000505a:	a8ed                	j	80005154 <exec+0x396>
  sp = sz;
    8000505c:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005060:	4481                	li	s1,0
  ustack[argc] = 0;
    80005062:	00349793          	sll	a5,s1,0x3
    80005066:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd8f90>
    8000506a:	97a2                	add	a5,a5,s0
    8000506c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005070:	00148693          	add	a3,s1,1
    80005074:	068e                	sll	a3,a3,0x3
    80005076:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000507a:	ff097913          	and	s2,s2,-16
  sz = sz1;
    8000507e:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80005082:	f57966e3          	bltu	s2,s7,80004fce <exec+0x210>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005086:	e9040613          	add	a2,s0,-368
    8000508a:	85ca                	mv	a1,s2
    8000508c:	855a                	mv	a0,s6
    8000508e:	ffffc097          	auipc	ra,0xffffc
    80005092:	63e080e7          	jalr	1598(ra) # 800016cc <copyout>
    80005096:	0e054c63          	bltz	a0,8000518e <exec+0x3d0>
  p->trapframe->a1 = sp;
    8000509a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000509e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050a2:	df843783          	ld	a5,-520(s0)
    800050a6:	0007c703          	lbu	a4,0(a5)
    800050aa:	cf11                	beqz	a4,800050c6 <exec+0x308>
    800050ac:	0785                	add	a5,a5,1
    if(*s == '/')
    800050ae:	02f00693          	li	a3,47
    800050b2:	a039                	j	800050c0 <exec+0x302>
      last = s+1;
    800050b4:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800050b8:	0785                	add	a5,a5,1
    800050ba:	fff7c703          	lbu	a4,-1(a5)
    800050be:	c701                	beqz	a4,800050c6 <exec+0x308>
    if(*s == '/')
    800050c0:	fed71ce3          	bne	a4,a3,800050b8 <exec+0x2fa>
    800050c4:	bfc5                	j	800050b4 <exec+0x2f6>
  safestrcpy(p->name, last, sizeof(p->name));
    800050c6:	4641                	li	a2,16
    800050c8:	df843583          	ld	a1,-520(s0)
    800050cc:	158a8513          	add	a0,s5,344
    800050d0:	ffffc097          	auipc	ra,0xffffc
    800050d4:	da0080e7          	jalr	-608(ra) # 80000e70 <safestrcpy>
  oldpagetable = p->pagetable;
    800050d8:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800050dc:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800050e0:	e0843783          	ld	a5,-504(s0)
    800050e4:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050e8:	058ab783          	ld	a5,88(s5)
    800050ec:	e6843703          	ld	a4,-408(s0)
    800050f0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050f2:	058ab783          	ld	a5,88(s5)
    800050f6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050fa:	85e6                	mv	a1,s9
    800050fc:	ffffd097          	auipc	ra,0xffffd
    80005100:	b8e080e7          	jalr	-1138(ra) # 80001c8a <proc_freepagetable>
  ptableprint(p->pagetable);
    80005104:	050ab503          	ld	a0,80(s5)
    80005108:	ffffd097          	auipc	ra,0xffffd
    8000510c:	860080e7          	jalr	-1952(ra) # 80001968 <ptableprint>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005110:	0004851b          	sext.w	a0,s1
    80005114:	79be                	ld	s3,488(sp)
    80005116:	7a1e                	ld	s4,480(sp)
    80005118:	6afe                	ld	s5,472(sp)
    8000511a:	6b5e                	ld	s6,464(sp)
    8000511c:	6bbe                	ld	s7,456(sp)
    8000511e:	6c1e                	ld	s8,448(sp)
    80005120:	7cfa                	ld	s9,440(sp)
    80005122:	7d5a                	ld	s10,432(sp)
    80005124:	b315                	j	80004e48 <exec+0x8a>
    80005126:	e0943423          	sd	s1,-504(s0)
    8000512a:	7dba                	ld	s11,424(sp)
    8000512c:	a025                	j	80005154 <exec+0x396>
    8000512e:	e0943423          	sd	s1,-504(s0)
    80005132:	7dba                	ld	s11,424(sp)
    80005134:	a005                	j	80005154 <exec+0x396>
    80005136:	e0943423          	sd	s1,-504(s0)
    8000513a:	7dba                	ld	s11,424(sp)
    8000513c:	a821                	j	80005154 <exec+0x396>
    8000513e:	e0943423          	sd	s1,-504(s0)
    80005142:	7dba                	ld	s11,424(sp)
    80005144:	a801                	j	80005154 <exec+0x396>
  ip = 0;
    80005146:	4a01                	li	s4,0
    80005148:	a031                	j	80005154 <exec+0x396>
    8000514a:	4a01                	li	s4,0
  if(pagetable)
    8000514c:	a021                	j	80005154 <exec+0x396>
    8000514e:	7dba                	ld	s11,424(sp)
    80005150:	a011                	j	80005154 <exec+0x396>
    80005152:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005154:	e0843583          	ld	a1,-504(s0)
    80005158:	855a                	mv	a0,s6
    8000515a:	ffffd097          	auipc	ra,0xffffd
    8000515e:	b30080e7          	jalr	-1232(ra) # 80001c8a <proc_freepagetable>
  return -1;
    80005162:	557d                	li	a0,-1
  if(ip){
    80005164:	000a1b63          	bnez	s4,8000517a <exec+0x3bc>
    80005168:	79be                	ld	s3,488(sp)
    8000516a:	7a1e                	ld	s4,480(sp)
    8000516c:	6afe                	ld	s5,472(sp)
    8000516e:	6b5e                	ld	s6,464(sp)
    80005170:	6bbe                	ld	s7,456(sp)
    80005172:	6c1e                	ld	s8,448(sp)
    80005174:	7cfa                	ld	s9,440(sp)
    80005176:	7d5a                	ld	s10,432(sp)
    80005178:	b9c1                	j	80004e48 <exec+0x8a>
    8000517a:	79be                	ld	s3,488(sp)
    8000517c:	6afe                	ld	s5,472(sp)
    8000517e:	6b5e                	ld	s6,464(sp)
    80005180:	6bbe                	ld	s7,456(sp)
    80005182:	6c1e                	ld	s8,448(sp)
    80005184:	7cfa                	ld	s9,440(sp)
    80005186:	7d5a                	ld	s10,432(sp)
    80005188:	b16d                	j	80004e32 <exec+0x74>
    8000518a:	6b5e                	ld	s6,464(sp)
    8000518c:	b15d                	j	80004e32 <exec+0x74>
  sz = sz1;
    8000518e:	e0843983          	ld	s3,-504(s0)
    80005192:	bd35                	j	80004fce <exec+0x210>

0000000080005194 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005194:	7179                	add	sp,sp,-48
    80005196:	f406                	sd	ra,40(sp)
    80005198:	f022                	sd	s0,32(sp)
    8000519a:	ec26                	sd	s1,24(sp)
    8000519c:	e84a                	sd	s2,16(sp)
    8000519e:	1800                	add	s0,sp,48
    800051a0:	892e                	mv	s2,a1
    800051a2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800051a4:	fdc40593          	add	a1,s0,-36
    800051a8:	ffffe097          	auipc	ra,0xffffe
    800051ac:	a42080e7          	jalr	-1470(ra) # 80002bea <argint>
    800051b0:	04054063          	bltz	a0,800051f0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051b4:	fdc42703          	lw	a4,-36(s0)
    800051b8:	47bd                	li	a5,15
    800051ba:	02e7ed63          	bltu	a5,a4,800051f4 <argfd+0x60>
    800051be:	ffffd097          	auipc	ra,0xffffd
    800051c2:	96c080e7          	jalr	-1684(ra) # 80001b2a <myproc>
    800051c6:	fdc42703          	lw	a4,-36(s0)
    800051ca:	01a70793          	add	a5,a4,26
    800051ce:	078e                	sll	a5,a5,0x3
    800051d0:	953e                	add	a0,a0,a5
    800051d2:	611c                	ld	a5,0(a0)
    800051d4:	c395                	beqz	a5,800051f8 <argfd+0x64>
    return -1;
  if(pfd)
    800051d6:	00090463          	beqz	s2,800051de <argfd+0x4a>
    *pfd = fd;
    800051da:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051de:	4501                	li	a0,0
  if(pf)
    800051e0:	c091                	beqz	s1,800051e4 <argfd+0x50>
    *pf = f;
    800051e2:	e09c                	sd	a5,0(s1)
}
    800051e4:	70a2                	ld	ra,40(sp)
    800051e6:	7402                	ld	s0,32(sp)
    800051e8:	64e2                	ld	s1,24(sp)
    800051ea:	6942                	ld	s2,16(sp)
    800051ec:	6145                	add	sp,sp,48
    800051ee:	8082                	ret
    return -1;
    800051f0:	557d                	li	a0,-1
    800051f2:	bfcd                	j	800051e4 <argfd+0x50>
    return -1;
    800051f4:	557d                	li	a0,-1
    800051f6:	b7fd                	j	800051e4 <argfd+0x50>
    800051f8:	557d                	li	a0,-1
    800051fa:	b7ed                	j	800051e4 <argfd+0x50>

00000000800051fc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800051fc:	1101                	add	sp,sp,-32
    800051fe:	ec06                	sd	ra,24(sp)
    80005200:	e822                	sd	s0,16(sp)
    80005202:	e426                	sd	s1,8(sp)
    80005204:	1000                	add	s0,sp,32
    80005206:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005208:	ffffd097          	auipc	ra,0xffffd
    8000520c:	922080e7          	jalr	-1758(ra) # 80001b2a <myproc>
    80005210:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005212:	0d050793          	add	a5,a0,208
    80005216:	4501                	li	a0,0
    80005218:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000521a:	6398                	ld	a4,0(a5)
    8000521c:	cb19                	beqz	a4,80005232 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000521e:	2505                	addw	a0,a0,1
    80005220:	07a1                	add	a5,a5,8
    80005222:	fed51ce3          	bne	a0,a3,8000521a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005226:	557d                	li	a0,-1
}
    80005228:	60e2                	ld	ra,24(sp)
    8000522a:	6442                	ld	s0,16(sp)
    8000522c:	64a2                	ld	s1,8(sp)
    8000522e:	6105                	add	sp,sp,32
    80005230:	8082                	ret
      p->ofile[fd] = f;
    80005232:	01a50793          	add	a5,a0,26
    80005236:	078e                	sll	a5,a5,0x3
    80005238:	963e                	add	a2,a2,a5
    8000523a:	e204                	sd	s1,0(a2)
      return fd;
    8000523c:	b7f5                	j	80005228 <fdalloc+0x2c>

000000008000523e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000523e:	715d                	add	sp,sp,-80
    80005240:	e486                	sd	ra,72(sp)
    80005242:	e0a2                	sd	s0,64(sp)
    80005244:	fc26                	sd	s1,56(sp)
    80005246:	f84a                	sd	s2,48(sp)
    80005248:	f44e                	sd	s3,40(sp)
    8000524a:	f052                	sd	s4,32(sp)
    8000524c:	ec56                	sd	s5,24(sp)
    8000524e:	0880                	add	s0,sp,80
    80005250:	8aae                	mv	s5,a1
    80005252:	8a32                	mv	s4,a2
    80005254:	89b6                	mv	s3,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005256:	fb040593          	add	a1,s0,-80
    8000525a:	fffff097          	auipc	ra,0xfffff
    8000525e:	e08080e7          	jalr	-504(ra) # 80004062 <nameiparent>
    80005262:	892a                	mv	s2,a0
    80005264:	12050c63          	beqz	a0,8000539c <create+0x15e>
    return 0;

  ilock(dp);
    80005268:	ffffe097          	auipc	ra,0xffffe
    8000526c:	60a080e7          	jalr	1546(ra) # 80003872 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005270:	4601                	li	a2,0
    80005272:	fb040593          	add	a1,s0,-80
    80005276:	854a                	mv	a0,s2
    80005278:	fffff097          	auipc	ra,0xfffff
    8000527c:	afa080e7          	jalr	-1286(ra) # 80003d72 <dirlookup>
    80005280:	84aa                	mv	s1,a0
    80005282:	c539                	beqz	a0,800052d0 <create+0x92>
    iunlockput(dp);
    80005284:	854a                	mv	a0,s2
    80005286:	fffff097          	auipc	ra,0xfffff
    8000528a:	852080e7          	jalr	-1966(ra) # 80003ad8 <iunlockput>
    ilock(ip);
    8000528e:	8526                	mv	a0,s1
    80005290:	ffffe097          	auipc	ra,0xffffe
    80005294:	5e2080e7          	jalr	1506(ra) # 80003872 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005298:	4789                	li	a5,2
    8000529a:	02fa9463          	bne	s5,a5,800052c2 <create+0x84>
    8000529e:	0444d783          	lhu	a5,68(s1)
    800052a2:	37f9                	addw	a5,a5,-2
    800052a4:	17c2                	sll	a5,a5,0x30
    800052a6:	93c1                	srl	a5,a5,0x30
    800052a8:	4705                	li	a4,1
    800052aa:	00f76c63          	bltu	a4,a5,800052c2 <create+0x84>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800052ae:	8526                	mv	a0,s1
    800052b0:	60a6                	ld	ra,72(sp)
    800052b2:	6406                	ld	s0,64(sp)
    800052b4:	74e2                	ld	s1,56(sp)
    800052b6:	7942                	ld	s2,48(sp)
    800052b8:	79a2                	ld	s3,40(sp)
    800052ba:	7a02                	ld	s4,32(sp)
    800052bc:	6ae2                	ld	s5,24(sp)
    800052be:	6161                	add	sp,sp,80
    800052c0:	8082                	ret
    iunlockput(ip);
    800052c2:	8526                	mv	a0,s1
    800052c4:	fffff097          	auipc	ra,0xfffff
    800052c8:	814080e7          	jalr	-2028(ra) # 80003ad8 <iunlockput>
    return 0;
    800052cc:	4481                	li	s1,0
    800052ce:	b7c5                	j	800052ae <create+0x70>
  if((ip = ialloc(dp->dev, type)) == 0)
    800052d0:	85d6                	mv	a1,s5
    800052d2:	00092503          	lw	a0,0(s2)
    800052d6:	ffffe097          	auipc	ra,0xffffe
    800052da:	408080e7          	jalr	1032(ra) # 800036de <ialloc>
    800052de:	84aa                	mv	s1,a0
    800052e0:	c139                	beqz	a0,80005326 <create+0xe8>
  ilock(ip);
    800052e2:	ffffe097          	auipc	ra,0xffffe
    800052e6:	590080e7          	jalr	1424(ra) # 80003872 <ilock>
  ip->major = major;
    800052ea:	05449323          	sh	s4,70(s1)
  ip->minor = minor;
    800052ee:	05349423          	sh	s3,72(s1)
  ip->nlink = 1;
    800052f2:	4985                	li	s3,1
    800052f4:	05349523          	sh	s3,74(s1)
  iupdate(ip);
    800052f8:	8526                	mv	a0,s1
    800052fa:	ffffe097          	auipc	ra,0xffffe
    800052fe:	4ac080e7          	jalr	1196(ra) # 800037a6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005302:	033a8a63          	beq	s5,s3,80005336 <create+0xf8>
  if(dirlink(dp, name, ip->inum) < 0)
    80005306:	40d0                	lw	a2,4(s1)
    80005308:	fb040593          	add	a1,s0,-80
    8000530c:	854a                	mv	a0,s2
    8000530e:	fffff097          	auipc	ra,0xfffff
    80005312:	c74080e7          	jalr	-908(ra) # 80003f82 <dirlink>
    80005316:	06054b63          	bltz	a0,8000538c <create+0x14e>
  iunlockput(dp);
    8000531a:	854a                	mv	a0,s2
    8000531c:	ffffe097          	auipc	ra,0xffffe
    80005320:	7bc080e7          	jalr	1980(ra) # 80003ad8 <iunlockput>
  return ip;
    80005324:	b769                	j	800052ae <create+0x70>
    panic("create: ialloc");
    80005326:	00003517          	auipc	a0,0x3
    8000532a:	2da50513          	add	a0,a0,730 # 80008600 <etext+0x600>
    8000532e:	ffffb097          	auipc	ra,0xffffb
    80005332:	22c080e7          	jalr	556(ra) # 8000055a <panic>
    dp->nlink++;  // for ".."
    80005336:	04a95783          	lhu	a5,74(s2)
    8000533a:	2785                	addw	a5,a5,1
    8000533c:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005340:	854a                	mv	a0,s2
    80005342:	ffffe097          	auipc	ra,0xffffe
    80005346:	464080e7          	jalr	1124(ra) # 800037a6 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000534a:	40d0                	lw	a2,4(s1)
    8000534c:	00003597          	auipc	a1,0x3
    80005350:	2c458593          	add	a1,a1,708 # 80008610 <etext+0x610>
    80005354:	8526                	mv	a0,s1
    80005356:	fffff097          	auipc	ra,0xfffff
    8000535a:	c2c080e7          	jalr	-980(ra) # 80003f82 <dirlink>
    8000535e:	00054f63          	bltz	a0,8000537c <create+0x13e>
    80005362:	00492603          	lw	a2,4(s2)
    80005366:	00003597          	auipc	a1,0x3
    8000536a:	2b258593          	add	a1,a1,690 # 80008618 <etext+0x618>
    8000536e:	8526                	mv	a0,s1
    80005370:	fffff097          	auipc	ra,0xfffff
    80005374:	c12080e7          	jalr	-1006(ra) # 80003f82 <dirlink>
    80005378:	f80557e3          	bgez	a0,80005306 <create+0xc8>
      panic("create dots");
    8000537c:	00003517          	auipc	a0,0x3
    80005380:	2a450513          	add	a0,a0,676 # 80008620 <etext+0x620>
    80005384:	ffffb097          	auipc	ra,0xffffb
    80005388:	1d6080e7          	jalr	470(ra) # 8000055a <panic>
    panic("create: dirlink");
    8000538c:	00003517          	auipc	a0,0x3
    80005390:	2a450513          	add	a0,a0,676 # 80008630 <etext+0x630>
    80005394:	ffffb097          	auipc	ra,0xffffb
    80005398:	1c6080e7          	jalr	454(ra) # 8000055a <panic>
    return 0;
    8000539c:	84aa                	mv	s1,a0
    8000539e:	bf01                	j	800052ae <create+0x70>

00000000800053a0 <sys_dup>:
{
    800053a0:	7179                	add	sp,sp,-48
    800053a2:	f406                	sd	ra,40(sp)
    800053a4:	f022                	sd	s0,32(sp)
    800053a6:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053a8:	fd840613          	add	a2,s0,-40
    800053ac:	4581                	li	a1,0
    800053ae:	4501                	li	a0,0
    800053b0:	00000097          	auipc	ra,0x0
    800053b4:	de4080e7          	jalr	-540(ra) # 80005194 <argfd>
    return -1;
    800053b8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053ba:	02054763          	bltz	a0,800053e8 <sys_dup+0x48>
    800053be:	ec26                	sd	s1,24(sp)
    800053c0:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800053c2:	fd843903          	ld	s2,-40(s0)
    800053c6:	854a                	mv	a0,s2
    800053c8:	00000097          	auipc	ra,0x0
    800053cc:	e34080e7          	jalr	-460(ra) # 800051fc <fdalloc>
    800053d0:	84aa                	mv	s1,a0
    return -1;
    800053d2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053d4:	00054f63          	bltz	a0,800053f2 <sys_dup+0x52>
  filedup(f);
    800053d8:	854a                	mv	a0,s2
    800053da:	fffff097          	auipc	ra,0xfffff
    800053de:	2e2080e7          	jalr	738(ra) # 800046bc <filedup>
  return fd;
    800053e2:	87a6                	mv	a5,s1
    800053e4:	64e2                	ld	s1,24(sp)
    800053e6:	6942                	ld	s2,16(sp)
}
    800053e8:	853e                	mv	a0,a5
    800053ea:	70a2                	ld	ra,40(sp)
    800053ec:	7402                	ld	s0,32(sp)
    800053ee:	6145                	add	sp,sp,48
    800053f0:	8082                	ret
    800053f2:	64e2                	ld	s1,24(sp)
    800053f4:	6942                	ld	s2,16(sp)
    800053f6:	bfcd                	j	800053e8 <sys_dup+0x48>

00000000800053f8 <sys_read>:
{
    800053f8:	7179                	add	sp,sp,-48
    800053fa:	f406                	sd	ra,40(sp)
    800053fc:	f022                	sd	s0,32(sp)
    800053fe:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005400:	fe840613          	add	a2,s0,-24
    80005404:	4581                	li	a1,0
    80005406:	4501                	li	a0,0
    80005408:	00000097          	auipc	ra,0x0
    8000540c:	d8c080e7          	jalr	-628(ra) # 80005194 <argfd>
    return -1;
    80005410:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005412:	04054163          	bltz	a0,80005454 <sys_read+0x5c>
    80005416:	fe440593          	add	a1,s0,-28
    8000541a:	4509                	li	a0,2
    8000541c:	ffffd097          	auipc	ra,0xffffd
    80005420:	7ce080e7          	jalr	1998(ra) # 80002bea <argint>
    return -1;
    80005424:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005426:	02054763          	bltz	a0,80005454 <sys_read+0x5c>
    8000542a:	fd840593          	add	a1,s0,-40
    8000542e:	4505                	li	a0,1
    80005430:	ffffd097          	auipc	ra,0xffffd
    80005434:	7dc080e7          	jalr	2012(ra) # 80002c0c <argaddr>
    return -1;
    80005438:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000543a:	00054d63          	bltz	a0,80005454 <sys_read+0x5c>
  return fileread(f, p, n);
    8000543e:	fe442603          	lw	a2,-28(s0)
    80005442:	fd843583          	ld	a1,-40(s0)
    80005446:	fe843503          	ld	a0,-24(s0)
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	418080e7          	jalr	1048(ra) # 80004862 <fileread>
    80005452:	87aa                	mv	a5,a0
}
    80005454:	853e                	mv	a0,a5
    80005456:	70a2                	ld	ra,40(sp)
    80005458:	7402                	ld	s0,32(sp)
    8000545a:	6145                	add	sp,sp,48
    8000545c:	8082                	ret

000000008000545e <sys_write>:
{
    8000545e:	7179                	add	sp,sp,-48
    80005460:	f406                	sd	ra,40(sp)
    80005462:	f022                	sd	s0,32(sp)
    80005464:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005466:	fe840613          	add	a2,s0,-24
    8000546a:	4581                	li	a1,0
    8000546c:	4501                	li	a0,0
    8000546e:	00000097          	auipc	ra,0x0
    80005472:	d26080e7          	jalr	-730(ra) # 80005194 <argfd>
    return -1;
    80005476:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005478:	04054163          	bltz	a0,800054ba <sys_write+0x5c>
    8000547c:	fe440593          	add	a1,s0,-28
    80005480:	4509                	li	a0,2
    80005482:	ffffd097          	auipc	ra,0xffffd
    80005486:	768080e7          	jalr	1896(ra) # 80002bea <argint>
    return -1;
    8000548a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000548c:	02054763          	bltz	a0,800054ba <sys_write+0x5c>
    80005490:	fd840593          	add	a1,s0,-40
    80005494:	4505                	li	a0,1
    80005496:	ffffd097          	auipc	ra,0xffffd
    8000549a:	776080e7          	jalr	1910(ra) # 80002c0c <argaddr>
    return -1;
    8000549e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800054a0:	00054d63          	bltz	a0,800054ba <sys_write+0x5c>
  return filewrite(f, p, n);
    800054a4:	fe442603          	lw	a2,-28(s0)
    800054a8:	fd843583          	ld	a1,-40(s0)
    800054ac:	fe843503          	ld	a0,-24(s0)
    800054b0:	fffff097          	auipc	ra,0xfffff
    800054b4:	484080e7          	jalr	1156(ra) # 80004934 <filewrite>
    800054b8:	87aa                	mv	a5,a0
}
    800054ba:	853e                	mv	a0,a5
    800054bc:	70a2                	ld	ra,40(sp)
    800054be:	7402                	ld	s0,32(sp)
    800054c0:	6145                	add	sp,sp,48
    800054c2:	8082                	ret

00000000800054c4 <sys_close>:
{
    800054c4:	1101                	add	sp,sp,-32
    800054c6:	ec06                	sd	ra,24(sp)
    800054c8:	e822                	sd	s0,16(sp)
    800054ca:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054cc:	fe040613          	add	a2,s0,-32
    800054d0:	fec40593          	add	a1,s0,-20
    800054d4:	4501                	li	a0,0
    800054d6:	00000097          	auipc	ra,0x0
    800054da:	cbe080e7          	jalr	-834(ra) # 80005194 <argfd>
    return -1;
    800054de:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054e0:	02054463          	bltz	a0,80005508 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800054e4:	ffffc097          	auipc	ra,0xffffc
    800054e8:	646080e7          	jalr	1606(ra) # 80001b2a <myproc>
    800054ec:	fec42783          	lw	a5,-20(s0)
    800054f0:	07e9                	add	a5,a5,26
    800054f2:	078e                	sll	a5,a5,0x3
    800054f4:	953e                	add	a0,a0,a5
    800054f6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800054fa:	fe043503          	ld	a0,-32(s0)
    800054fe:	fffff097          	auipc	ra,0xfffff
    80005502:	210080e7          	jalr	528(ra) # 8000470e <fileclose>
  return 0;
    80005506:	4781                	li	a5,0
}
    80005508:	853e                	mv	a0,a5
    8000550a:	60e2                	ld	ra,24(sp)
    8000550c:	6442                	ld	s0,16(sp)
    8000550e:	6105                	add	sp,sp,32
    80005510:	8082                	ret

0000000080005512 <sys_fstat>:
{
    80005512:	1101                	add	sp,sp,-32
    80005514:	ec06                	sd	ra,24(sp)
    80005516:	e822                	sd	s0,16(sp)
    80005518:	1000                	add	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000551a:	fe840613          	add	a2,s0,-24
    8000551e:	4581                	li	a1,0
    80005520:	4501                	li	a0,0
    80005522:	00000097          	auipc	ra,0x0
    80005526:	c72080e7          	jalr	-910(ra) # 80005194 <argfd>
    return -1;
    8000552a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000552c:	02054563          	bltz	a0,80005556 <sys_fstat+0x44>
    80005530:	fe040593          	add	a1,s0,-32
    80005534:	4505                	li	a0,1
    80005536:	ffffd097          	auipc	ra,0xffffd
    8000553a:	6d6080e7          	jalr	1750(ra) # 80002c0c <argaddr>
    return -1;
    8000553e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005540:	00054b63          	bltz	a0,80005556 <sys_fstat+0x44>
  return filestat(f, st);
    80005544:	fe043583          	ld	a1,-32(s0)
    80005548:	fe843503          	ld	a0,-24(s0)
    8000554c:	fffff097          	auipc	ra,0xfffff
    80005550:	2a4080e7          	jalr	676(ra) # 800047f0 <filestat>
    80005554:	87aa                	mv	a5,a0
}
    80005556:	853e                	mv	a0,a5
    80005558:	60e2                	ld	ra,24(sp)
    8000555a:	6442                	ld	s0,16(sp)
    8000555c:	6105                	add	sp,sp,32
    8000555e:	8082                	ret

0000000080005560 <sys_link>:
{
    80005560:	7169                	add	sp,sp,-304
    80005562:	f606                	sd	ra,296(sp)
    80005564:	f222                	sd	s0,288(sp)
    80005566:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005568:	08000613          	li	a2,128
    8000556c:	ed040593          	add	a1,s0,-304
    80005570:	4501                	li	a0,0
    80005572:	ffffd097          	auipc	ra,0xffffd
    80005576:	6bc080e7          	jalr	1724(ra) # 80002c2e <argstr>
    return -1;
    8000557a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000557c:	12054663          	bltz	a0,800056a8 <sys_link+0x148>
    80005580:	08000613          	li	a2,128
    80005584:	f5040593          	add	a1,s0,-176
    80005588:	4505                	li	a0,1
    8000558a:	ffffd097          	auipc	ra,0xffffd
    8000558e:	6a4080e7          	jalr	1700(ra) # 80002c2e <argstr>
    return -1;
    80005592:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005594:	10054a63          	bltz	a0,800056a8 <sys_link+0x148>
    80005598:	ee26                	sd	s1,280(sp)
  begin_op();
    8000559a:	fffff097          	auipc	ra,0xfffff
    8000559e:	caa080e7          	jalr	-854(ra) # 80004244 <begin_op>
  if((ip = namei(old)) == 0){
    800055a2:	ed040513          	add	a0,s0,-304
    800055a6:	fffff097          	auipc	ra,0xfffff
    800055aa:	a9e080e7          	jalr	-1378(ra) # 80004044 <namei>
    800055ae:	84aa                	mv	s1,a0
    800055b0:	c949                	beqz	a0,80005642 <sys_link+0xe2>
  ilock(ip);
    800055b2:	ffffe097          	auipc	ra,0xffffe
    800055b6:	2c0080e7          	jalr	704(ra) # 80003872 <ilock>
  if(ip->type == T_DIR){
    800055ba:	04449703          	lh	a4,68(s1)
    800055be:	4785                	li	a5,1
    800055c0:	08f70863          	beq	a4,a5,80005650 <sys_link+0xf0>
    800055c4:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800055c6:	04a4d783          	lhu	a5,74(s1)
    800055ca:	2785                	addw	a5,a5,1
    800055cc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055d0:	8526                	mv	a0,s1
    800055d2:	ffffe097          	auipc	ra,0xffffe
    800055d6:	1d4080e7          	jalr	468(ra) # 800037a6 <iupdate>
  iunlock(ip);
    800055da:	8526                	mv	a0,s1
    800055dc:	ffffe097          	auipc	ra,0xffffe
    800055e0:	35c080e7          	jalr	860(ra) # 80003938 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055e4:	fd040593          	add	a1,s0,-48
    800055e8:	f5040513          	add	a0,s0,-176
    800055ec:	fffff097          	auipc	ra,0xfffff
    800055f0:	a76080e7          	jalr	-1418(ra) # 80004062 <nameiparent>
    800055f4:	892a                	mv	s2,a0
    800055f6:	cd35                	beqz	a0,80005672 <sys_link+0x112>
  ilock(dp);
    800055f8:	ffffe097          	auipc	ra,0xffffe
    800055fc:	27a080e7          	jalr	634(ra) # 80003872 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005600:	00092703          	lw	a4,0(s2)
    80005604:	409c                	lw	a5,0(s1)
    80005606:	06f71163          	bne	a4,a5,80005668 <sys_link+0x108>
    8000560a:	40d0                	lw	a2,4(s1)
    8000560c:	fd040593          	add	a1,s0,-48
    80005610:	854a                	mv	a0,s2
    80005612:	fffff097          	auipc	ra,0xfffff
    80005616:	970080e7          	jalr	-1680(ra) # 80003f82 <dirlink>
    8000561a:	04054763          	bltz	a0,80005668 <sys_link+0x108>
  iunlockput(dp);
    8000561e:	854a                	mv	a0,s2
    80005620:	ffffe097          	auipc	ra,0xffffe
    80005624:	4b8080e7          	jalr	1208(ra) # 80003ad8 <iunlockput>
  iput(ip);
    80005628:	8526                	mv	a0,s1
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	406080e7          	jalr	1030(ra) # 80003a30 <iput>
  end_op();
    80005632:	fffff097          	auipc	ra,0xfffff
    80005636:	c8c080e7          	jalr	-884(ra) # 800042be <end_op>
  return 0;
    8000563a:	4781                	li	a5,0
    8000563c:	64f2                	ld	s1,280(sp)
    8000563e:	6952                	ld	s2,272(sp)
    80005640:	a0a5                	j	800056a8 <sys_link+0x148>
    end_op();
    80005642:	fffff097          	auipc	ra,0xfffff
    80005646:	c7c080e7          	jalr	-900(ra) # 800042be <end_op>
    return -1;
    8000564a:	57fd                	li	a5,-1
    8000564c:	64f2                	ld	s1,280(sp)
    8000564e:	a8a9                	j	800056a8 <sys_link+0x148>
    iunlockput(ip);
    80005650:	8526                	mv	a0,s1
    80005652:	ffffe097          	auipc	ra,0xffffe
    80005656:	486080e7          	jalr	1158(ra) # 80003ad8 <iunlockput>
    end_op();
    8000565a:	fffff097          	auipc	ra,0xfffff
    8000565e:	c64080e7          	jalr	-924(ra) # 800042be <end_op>
    return -1;
    80005662:	57fd                	li	a5,-1
    80005664:	64f2                	ld	s1,280(sp)
    80005666:	a089                	j	800056a8 <sys_link+0x148>
    iunlockput(dp);
    80005668:	854a                	mv	a0,s2
    8000566a:	ffffe097          	auipc	ra,0xffffe
    8000566e:	46e080e7          	jalr	1134(ra) # 80003ad8 <iunlockput>
  ilock(ip);
    80005672:	8526                	mv	a0,s1
    80005674:	ffffe097          	auipc	ra,0xffffe
    80005678:	1fe080e7          	jalr	510(ra) # 80003872 <ilock>
  ip->nlink--;
    8000567c:	04a4d783          	lhu	a5,74(s1)
    80005680:	37fd                	addw	a5,a5,-1
    80005682:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005686:	8526                	mv	a0,s1
    80005688:	ffffe097          	auipc	ra,0xffffe
    8000568c:	11e080e7          	jalr	286(ra) # 800037a6 <iupdate>
  iunlockput(ip);
    80005690:	8526                	mv	a0,s1
    80005692:	ffffe097          	auipc	ra,0xffffe
    80005696:	446080e7          	jalr	1094(ra) # 80003ad8 <iunlockput>
  end_op();
    8000569a:	fffff097          	auipc	ra,0xfffff
    8000569e:	c24080e7          	jalr	-988(ra) # 800042be <end_op>
  return -1;
    800056a2:	57fd                	li	a5,-1
    800056a4:	64f2                	ld	s1,280(sp)
    800056a6:	6952                	ld	s2,272(sp)
}
    800056a8:	853e                	mv	a0,a5
    800056aa:	70b2                	ld	ra,296(sp)
    800056ac:	7412                	ld	s0,288(sp)
    800056ae:	6155                	add	sp,sp,304
    800056b0:	8082                	ret

00000000800056b2 <sys_unlink>:
{
    800056b2:	7151                	add	sp,sp,-240
    800056b4:	f586                	sd	ra,232(sp)
    800056b6:	f1a2                	sd	s0,224(sp)
    800056b8:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056ba:	08000613          	li	a2,128
    800056be:	f3040593          	add	a1,s0,-208
    800056c2:	4501                	li	a0,0
    800056c4:	ffffd097          	auipc	ra,0xffffd
    800056c8:	56a080e7          	jalr	1386(ra) # 80002c2e <argstr>
    800056cc:	1a054a63          	bltz	a0,80005880 <sys_unlink+0x1ce>
    800056d0:	eda6                	sd	s1,216(sp)
  begin_op();
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	b72080e7          	jalr	-1166(ra) # 80004244 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056da:	fb040593          	add	a1,s0,-80
    800056de:	f3040513          	add	a0,s0,-208
    800056e2:	fffff097          	auipc	ra,0xfffff
    800056e6:	980080e7          	jalr	-1664(ra) # 80004062 <nameiparent>
    800056ea:	84aa                	mv	s1,a0
    800056ec:	cd71                	beqz	a0,800057c8 <sys_unlink+0x116>
  ilock(dp);
    800056ee:	ffffe097          	auipc	ra,0xffffe
    800056f2:	184080e7          	jalr	388(ra) # 80003872 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056f6:	00003597          	auipc	a1,0x3
    800056fa:	f1a58593          	add	a1,a1,-230 # 80008610 <etext+0x610>
    800056fe:	fb040513          	add	a0,s0,-80
    80005702:	ffffe097          	auipc	ra,0xffffe
    80005706:	656080e7          	jalr	1622(ra) # 80003d58 <namecmp>
    8000570a:	14050c63          	beqz	a0,80005862 <sys_unlink+0x1b0>
    8000570e:	00003597          	auipc	a1,0x3
    80005712:	f0a58593          	add	a1,a1,-246 # 80008618 <etext+0x618>
    80005716:	fb040513          	add	a0,s0,-80
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	63e080e7          	jalr	1598(ra) # 80003d58 <namecmp>
    80005722:	14050063          	beqz	a0,80005862 <sys_unlink+0x1b0>
    80005726:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005728:	f2c40613          	add	a2,s0,-212
    8000572c:	fb040593          	add	a1,s0,-80
    80005730:	8526                	mv	a0,s1
    80005732:	ffffe097          	auipc	ra,0xffffe
    80005736:	640080e7          	jalr	1600(ra) # 80003d72 <dirlookup>
    8000573a:	892a                	mv	s2,a0
    8000573c:	12050263          	beqz	a0,80005860 <sys_unlink+0x1ae>
  ilock(ip);
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	132080e7          	jalr	306(ra) # 80003872 <ilock>
  if(ip->nlink < 1)
    80005748:	04a91783          	lh	a5,74(s2)
    8000574c:	08f05563          	blez	a5,800057d6 <sys_unlink+0x124>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005750:	04491703          	lh	a4,68(s2)
    80005754:	4785                	li	a5,1
    80005756:	08f70963          	beq	a4,a5,800057e8 <sys_unlink+0x136>
  memset(&de, 0, sizeof(de));
    8000575a:	4641                	li	a2,16
    8000575c:	4581                	li	a1,0
    8000575e:	fc040513          	add	a0,s0,-64
    80005762:	ffffb097          	auipc	ra,0xffffb
    80005766:	5cc080e7          	jalr	1484(ra) # 80000d2e <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000576a:	4741                	li	a4,16
    8000576c:	f2c42683          	lw	a3,-212(s0)
    80005770:	fc040613          	add	a2,s0,-64
    80005774:	4581                	li	a1,0
    80005776:	8526                	mv	a0,s1
    80005778:	ffffe097          	auipc	ra,0xffffe
    8000577c:	4b6080e7          	jalr	1206(ra) # 80003c2e <writei>
    80005780:	47c1                	li	a5,16
    80005782:	0af51b63          	bne	a0,a5,80005838 <sys_unlink+0x186>
  if(ip->type == T_DIR){
    80005786:	04491703          	lh	a4,68(s2)
    8000578a:	4785                	li	a5,1
    8000578c:	0af70f63          	beq	a4,a5,8000584a <sys_unlink+0x198>
  iunlockput(dp);
    80005790:	8526                	mv	a0,s1
    80005792:	ffffe097          	auipc	ra,0xffffe
    80005796:	346080e7          	jalr	838(ra) # 80003ad8 <iunlockput>
  ip->nlink--;
    8000579a:	04a95783          	lhu	a5,74(s2)
    8000579e:	37fd                	addw	a5,a5,-1
    800057a0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057a4:	854a                	mv	a0,s2
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	000080e7          	jalr	ra # 800037a6 <iupdate>
  iunlockput(ip);
    800057ae:	854a                	mv	a0,s2
    800057b0:	ffffe097          	auipc	ra,0xffffe
    800057b4:	328080e7          	jalr	808(ra) # 80003ad8 <iunlockput>
  end_op();
    800057b8:	fffff097          	auipc	ra,0xfffff
    800057bc:	b06080e7          	jalr	-1274(ra) # 800042be <end_op>
  return 0;
    800057c0:	4501                	li	a0,0
    800057c2:	64ee                	ld	s1,216(sp)
    800057c4:	694e                	ld	s2,208(sp)
    800057c6:	a84d                	j	80005878 <sys_unlink+0x1c6>
    end_op();
    800057c8:	fffff097          	auipc	ra,0xfffff
    800057cc:	af6080e7          	jalr	-1290(ra) # 800042be <end_op>
    return -1;
    800057d0:	557d                	li	a0,-1
    800057d2:	64ee                	ld	s1,216(sp)
    800057d4:	a055                	j	80005878 <sys_unlink+0x1c6>
    800057d6:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800057d8:	00003517          	auipc	a0,0x3
    800057dc:	e6850513          	add	a0,a0,-408 # 80008640 <etext+0x640>
    800057e0:	ffffb097          	auipc	ra,0xffffb
    800057e4:	d7a080e7          	jalr	-646(ra) # 8000055a <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057e8:	04c92703          	lw	a4,76(s2)
    800057ec:	02000793          	li	a5,32
    800057f0:	f6e7f5e3          	bgeu	a5,a4,8000575a <sys_unlink+0xa8>
    800057f4:	e5ce                	sd	s3,200(sp)
    800057f6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057fa:	4741                	li	a4,16
    800057fc:	86ce                	mv	a3,s3
    800057fe:	f1840613          	add	a2,s0,-232
    80005802:	4581                	li	a1,0
    80005804:	854a                	mv	a0,s2
    80005806:	ffffe097          	auipc	ra,0xffffe
    8000580a:	324080e7          	jalr	804(ra) # 80003b2a <readi>
    8000580e:	47c1                	li	a5,16
    80005810:	00f51c63          	bne	a0,a5,80005828 <sys_unlink+0x176>
    if(de.inum != 0)
    80005814:	f1845783          	lhu	a5,-232(s0)
    80005818:	e7b5                	bnez	a5,80005884 <sys_unlink+0x1d2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000581a:	29c1                	addw	s3,s3,16
    8000581c:	04c92783          	lw	a5,76(s2)
    80005820:	fcf9ede3          	bltu	s3,a5,800057fa <sys_unlink+0x148>
    80005824:	69ae                	ld	s3,200(sp)
    80005826:	bf15                	j	8000575a <sys_unlink+0xa8>
      panic("isdirempty: readi");
    80005828:	00003517          	auipc	a0,0x3
    8000582c:	e3050513          	add	a0,a0,-464 # 80008658 <etext+0x658>
    80005830:	ffffb097          	auipc	ra,0xffffb
    80005834:	d2a080e7          	jalr	-726(ra) # 8000055a <panic>
    80005838:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000583a:	00003517          	auipc	a0,0x3
    8000583e:	e3650513          	add	a0,a0,-458 # 80008670 <etext+0x670>
    80005842:	ffffb097          	auipc	ra,0xffffb
    80005846:	d18080e7          	jalr	-744(ra) # 8000055a <panic>
    dp->nlink--;
    8000584a:	04a4d783          	lhu	a5,74(s1)
    8000584e:	37fd                	addw	a5,a5,-1
    80005850:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005854:	8526                	mv	a0,s1
    80005856:	ffffe097          	auipc	ra,0xffffe
    8000585a:	f50080e7          	jalr	-176(ra) # 800037a6 <iupdate>
    8000585e:	bf0d                	j	80005790 <sys_unlink+0xde>
    80005860:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005862:	8526                	mv	a0,s1
    80005864:	ffffe097          	auipc	ra,0xffffe
    80005868:	274080e7          	jalr	628(ra) # 80003ad8 <iunlockput>
  end_op();
    8000586c:	fffff097          	auipc	ra,0xfffff
    80005870:	a52080e7          	jalr	-1454(ra) # 800042be <end_op>
  return -1;
    80005874:	557d                	li	a0,-1
    80005876:	64ee                	ld	s1,216(sp)
}
    80005878:	70ae                	ld	ra,232(sp)
    8000587a:	740e                	ld	s0,224(sp)
    8000587c:	616d                	add	sp,sp,240
    8000587e:	8082                	ret
    return -1;
    80005880:	557d                	li	a0,-1
    80005882:	bfdd                	j	80005878 <sys_unlink+0x1c6>
    iunlockput(ip);
    80005884:	854a                	mv	a0,s2
    80005886:	ffffe097          	auipc	ra,0xffffe
    8000588a:	252080e7          	jalr	594(ra) # 80003ad8 <iunlockput>
    goto bad;
    8000588e:	694e                	ld	s2,208(sp)
    80005890:	69ae                	ld	s3,200(sp)
    80005892:	bfc1                	j	80005862 <sys_unlink+0x1b0>

0000000080005894 <sys_open>:

uint64
sys_open(void)
{
    80005894:	7131                	add	sp,sp,-192
    80005896:	fd06                	sd	ra,184(sp)
    80005898:	f922                	sd	s0,176(sp)
    8000589a:	f526                	sd	s1,168(sp)
    8000589c:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    8000589e:	08000613          	li	a2,128
    800058a2:	f5040593          	add	a1,s0,-176
    800058a6:	4501                	li	a0,0
    800058a8:	ffffd097          	auipc	ra,0xffffd
    800058ac:	386080e7          	jalr	902(ra) # 80002c2e <argstr>
    return -1;
    800058b0:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800058b2:	0c054463          	bltz	a0,8000597a <sys_open+0xe6>
    800058b6:	f4c40593          	add	a1,s0,-180
    800058ba:	4505                	li	a0,1
    800058bc:	ffffd097          	auipc	ra,0xffffd
    800058c0:	32e080e7          	jalr	814(ra) # 80002bea <argint>
    800058c4:	0a054b63          	bltz	a0,8000597a <sys_open+0xe6>
    800058c8:	f14a                	sd	s2,160(sp)

  begin_op();
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	97a080e7          	jalr	-1670(ra) # 80004244 <begin_op>

  if(omode & O_CREATE){
    800058d2:	f4c42783          	lw	a5,-180(s0)
    800058d6:	2007f793          	and	a5,a5,512
    800058da:	cfc5                	beqz	a5,80005992 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058dc:	4681                	li	a3,0
    800058de:	4601                	li	a2,0
    800058e0:	4589                	li	a1,2
    800058e2:	f5040513          	add	a0,s0,-176
    800058e6:	00000097          	auipc	ra,0x0
    800058ea:	958080e7          	jalr	-1704(ra) # 8000523e <create>
    800058ee:	892a                	mv	s2,a0
    if(ip == 0){
    800058f0:	c959                	beqz	a0,80005986 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058f2:	04491703          	lh	a4,68(s2)
    800058f6:	478d                	li	a5,3
    800058f8:	00f71763          	bne	a4,a5,80005906 <sys_open+0x72>
    800058fc:	04695703          	lhu	a4,70(s2)
    80005900:	47a5                	li	a5,9
    80005902:	0ce7ef63          	bltu	a5,a4,800059e0 <sys_open+0x14c>
    80005906:	ed4e                	sd	s3,152(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005908:	fffff097          	auipc	ra,0xfffff
    8000590c:	d4a080e7          	jalr	-694(ra) # 80004652 <filealloc>
    80005910:	89aa                	mv	s3,a0
    80005912:	c965                	beqz	a0,80005a02 <sys_open+0x16e>
    80005914:	00000097          	auipc	ra,0x0
    80005918:	8e8080e7          	jalr	-1816(ra) # 800051fc <fdalloc>
    8000591c:	84aa                	mv	s1,a0
    8000591e:	0c054d63          	bltz	a0,800059f8 <sys_open+0x164>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005922:	04491703          	lh	a4,68(s2)
    80005926:	478d                	li	a5,3
    80005928:	0ef70a63          	beq	a4,a5,80005a1c <sys_open+0x188>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000592c:	4789                	li	a5,2
    8000592e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005932:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005936:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000593a:	f4c42783          	lw	a5,-180(s0)
    8000593e:	0017c713          	xor	a4,a5,1
    80005942:	8b05                	and	a4,a4,1
    80005944:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005948:	0037f713          	and	a4,a5,3
    8000594c:	00e03733          	snez	a4,a4
    80005950:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005954:	4007f793          	and	a5,a5,1024
    80005958:	c791                	beqz	a5,80005964 <sys_open+0xd0>
    8000595a:	04491703          	lh	a4,68(s2)
    8000595e:	4789                	li	a5,2
    80005960:	0cf70563          	beq	a4,a5,80005a2a <sys_open+0x196>
    itrunc(ip);
  }

  iunlock(ip);
    80005964:	854a                	mv	a0,s2
    80005966:	ffffe097          	auipc	ra,0xffffe
    8000596a:	fd2080e7          	jalr	-46(ra) # 80003938 <iunlock>
  end_op();
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	950080e7          	jalr	-1712(ra) # 800042be <end_op>
    80005976:	790a                	ld	s2,160(sp)
    80005978:	69ea                	ld	s3,152(sp)

  return fd;
}
    8000597a:	8526                	mv	a0,s1
    8000597c:	70ea                	ld	ra,184(sp)
    8000597e:	744a                	ld	s0,176(sp)
    80005980:	74aa                	ld	s1,168(sp)
    80005982:	6129                	add	sp,sp,192
    80005984:	8082                	ret
      end_op();
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	938080e7          	jalr	-1736(ra) # 800042be <end_op>
      return -1;
    8000598e:	790a                	ld	s2,160(sp)
    80005990:	b7ed                	j	8000597a <sys_open+0xe6>
    if((ip = namei(path)) == 0){
    80005992:	f5040513          	add	a0,s0,-176
    80005996:	ffffe097          	auipc	ra,0xffffe
    8000599a:	6ae080e7          	jalr	1710(ra) # 80004044 <namei>
    8000599e:	892a                	mv	s2,a0
    800059a0:	c90d                	beqz	a0,800059d2 <sys_open+0x13e>
    ilock(ip);
    800059a2:	ffffe097          	auipc	ra,0xffffe
    800059a6:	ed0080e7          	jalr	-304(ra) # 80003872 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059aa:	04491703          	lh	a4,68(s2)
    800059ae:	4785                	li	a5,1
    800059b0:	f4f711e3          	bne	a4,a5,800058f2 <sys_open+0x5e>
    800059b4:	f4c42783          	lw	a5,-180(s0)
    800059b8:	d7b9                	beqz	a5,80005906 <sys_open+0x72>
      iunlockput(ip);
    800059ba:	854a                	mv	a0,s2
    800059bc:	ffffe097          	auipc	ra,0xffffe
    800059c0:	11c080e7          	jalr	284(ra) # 80003ad8 <iunlockput>
      end_op();
    800059c4:	fffff097          	auipc	ra,0xfffff
    800059c8:	8fa080e7          	jalr	-1798(ra) # 800042be <end_op>
      return -1;
    800059cc:	54fd                	li	s1,-1
    800059ce:	790a                	ld	s2,160(sp)
    800059d0:	b76d                	j	8000597a <sys_open+0xe6>
      end_op();
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	8ec080e7          	jalr	-1812(ra) # 800042be <end_op>
      return -1;
    800059da:	54fd                	li	s1,-1
    800059dc:	790a                	ld	s2,160(sp)
    800059de:	bf71                	j	8000597a <sys_open+0xe6>
    iunlockput(ip);
    800059e0:	854a                	mv	a0,s2
    800059e2:	ffffe097          	auipc	ra,0xffffe
    800059e6:	0f6080e7          	jalr	246(ra) # 80003ad8 <iunlockput>
    end_op();
    800059ea:	fffff097          	auipc	ra,0xfffff
    800059ee:	8d4080e7          	jalr	-1836(ra) # 800042be <end_op>
    return -1;
    800059f2:	54fd                	li	s1,-1
    800059f4:	790a                	ld	s2,160(sp)
    800059f6:	b751                	j	8000597a <sys_open+0xe6>
      fileclose(f);
    800059f8:	854e                	mv	a0,s3
    800059fa:	fffff097          	auipc	ra,0xfffff
    800059fe:	d14080e7          	jalr	-748(ra) # 8000470e <fileclose>
    iunlockput(ip);
    80005a02:	854a                	mv	a0,s2
    80005a04:	ffffe097          	auipc	ra,0xffffe
    80005a08:	0d4080e7          	jalr	212(ra) # 80003ad8 <iunlockput>
    end_op();
    80005a0c:	fffff097          	auipc	ra,0xfffff
    80005a10:	8b2080e7          	jalr	-1870(ra) # 800042be <end_op>
    return -1;
    80005a14:	54fd                	li	s1,-1
    80005a16:	790a                	ld	s2,160(sp)
    80005a18:	69ea                	ld	s3,152(sp)
    80005a1a:	b785                	j	8000597a <sys_open+0xe6>
    f->type = FD_DEVICE;
    80005a1c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a20:	04691783          	lh	a5,70(s2)
    80005a24:	02f99223          	sh	a5,36(s3)
    80005a28:	b739                	j	80005936 <sys_open+0xa2>
    itrunc(ip);
    80005a2a:	854a                	mv	a0,s2
    80005a2c:	ffffe097          	auipc	ra,0xffffe
    80005a30:	f58080e7          	jalr	-168(ra) # 80003984 <itrunc>
    80005a34:	bf05                	j	80005964 <sys_open+0xd0>

0000000080005a36 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a36:	7175                	add	sp,sp,-144
    80005a38:	e506                	sd	ra,136(sp)
    80005a3a:	e122                	sd	s0,128(sp)
    80005a3c:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a3e:	fffff097          	auipc	ra,0xfffff
    80005a42:	806080e7          	jalr	-2042(ra) # 80004244 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a46:	08000613          	li	a2,128
    80005a4a:	f7040593          	add	a1,s0,-144
    80005a4e:	4501                	li	a0,0
    80005a50:	ffffd097          	auipc	ra,0xffffd
    80005a54:	1de080e7          	jalr	478(ra) # 80002c2e <argstr>
    80005a58:	02054963          	bltz	a0,80005a8a <sys_mkdir+0x54>
    80005a5c:	4681                	li	a3,0
    80005a5e:	4601                	li	a2,0
    80005a60:	4585                	li	a1,1
    80005a62:	f7040513          	add	a0,s0,-144
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	7d8080e7          	jalr	2008(ra) # 8000523e <create>
    80005a6e:	cd11                	beqz	a0,80005a8a <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a70:	ffffe097          	auipc	ra,0xffffe
    80005a74:	068080e7          	jalr	104(ra) # 80003ad8 <iunlockput>
  end_op();
    80005a78:	fffff097          	auipc	ra,0xfffff
    80005a7c:	846080e7          	jalr	-1978(ra) # 800042be <end_op>
  return 0;
    80005a80:	4501                	li	a0,0
}
    80005a82:	60aa                	ld	ra,136(sp)
    80005a84:	640a                	ld	s0,128(sp)
    80005a86:	6149                	add	sp,sp,144
    80005a88:	8082                	ret
    end_op();
    80005a8a:	fffff097          	auipc	ra,0xfffff
    80005a8e:	834080e7          	jalr	-1996(ra) # 800042be <end_op>
    return -1;
    80005a92:	557d                	li	a0,-1
    80005a94:	b7fd                	j	80005a82 <sys_mkdir+0x4c>

0000000080005a96 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a96:	7135                	add	sp,sp,-160
    80005a98:	ed06                	sd	ra,152(sp)
    80005a9a:	e922                	sd	s0,144(sp)
    80005a9c:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a9e:	ffffe097          	auipc	ra,0xffffe
    80005aa2:	7a6080e7          	jalr	1958(ra) # 80004244 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aa6:	08000613          	li	a2,128
    80005aaa:	f7040593          	add	a1,s0,-144
    80005aae:	4501                	li	a0,0
    80005ab0:	ffffd097          	auipc	ra,0xffffd
    80005ab4:	17e080e7          	jalr	382(ra) # 80002c2e <argstr>
    80005ab8:	04054a63          	bltz	a0,80005b0c <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005abc:	f6c40593          	add	a1,s0,-148
    80005ac0:	4505                	li	a0,1
    80005ac2:	ffffd097          	auipc	ra,0xffffd
    80005ac6:	128080e7          	jalr	296(ra) # 80002bea <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aca:	04054163          	bltz	a0,80005b0c <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005ace:	f6840593          	add	a1,s0,-152
    80005ad2:	4509                	li	a0,2
    80005ad4:	ffffd097          	auipc	ra,0xffffd
    80005ad8:	116080e7          	jalr	278(ra) # 80002bea <argint>
     argint(1, &major) < 0 ||
    80005adc:	02054863          	bltz	a0,80005b0c <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005ae0:	f6841683          	lh	a3,-152(s0)
    80005ae4:	f6c41603          	lh	a2,-148(s0)
    80005ae8:	458d                	li	a1,3
    80005aea:	f7040513          	add	a0,s0,-144
    80005aee:	fffff097          	auipc	ra,0xfffff
    80005af2:	750080e7          	jalr	1872(ra) # 8000523e <create>
     argint(2, &minor) < 0 ||
    80005af6:	c919                	beqz	a0,80005b0c <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005af8:	ffffe097          	auipc	ra,0xffffe
    80005afc:	fe0080e7          	jalr	-32(ra) # 80003ad8 <iunlockput>
  end_op();
    80005b00:	ffffe097          	auipc	ra,0xffffe
    80005b04:	7be080e7          	jalr	1982(ra) # 800042be <end_op>
  return 0;
    80005b08:	4501                	li	a0,0
    80005b0a:	a031                	j	80005b16 <sys_mknod+0x80>
    end_op();
    80005b0c:	ffffe097          	auipc	ra,0xffffe
    80005b10:	7b2080e7          	jalr	1970(ra) # 800042be <end_op>
    return -1;
    80005b14:	557d                	li	a0,-1
}
    80005b16:	60ea                	ld	ra,152(sp)
    80005b18:	644a                	ld	s0,144(sp)
    80005b1a:	610d                	add	sp,sp,160
    80005b1c:	8082                	ret

0000000080005b1e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b1e:	7135                	add	sp,sp,-160
    80005b20:	ed06                	sd	ra,152(sp)
    80005b22:	e922                	sd	s0,144(sp)
    80005b24:	e14a                	sd	s2,128(sp)
    80005b26:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b28:	ffffc097          	auipc	ra,0xffffc
    80005b2c:	002080e7          	jalr	2(ra) # 80001b2a <myproc>
    80005b30:	892a                	mv	s2,a0
  
  begin_op();
    80005b32:	ffffe097          	auipc	ra,0xffffe
    80005b36:	712080e7          	jalr	1810(ra) # 80004244 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b3a:	08000613          	li	a2,128
    80005b3e:	f6040593          	add	a1,s0,-160
    80005b42:	4501                	li	a0,0
    80005b44:	ffffd097          	auipc	ra,0xffffd
    80005b48:	0ea080e7          	jalr	234(ra) # 80002c2e <argstr>
    80005b4c:	04054d63          	bltz	a0,80005ba6 <sys_chdir+0x88>
    80005b50:	e526                	sd	s1,136(sp)
    80005b52:	f6040513          	add	a0,s0,-160
    80005b56:	ffffe097          	auipc	ra,0xffffe
    80005b5a:	4ee080e7          	jalr	1262(ra) # 80004044 <namei>
    80005b5e:	84aa                	mv	s1,a0
    80005b60:	c131                	beqz	a0,80005ba4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	d10080e7          	jalr	-752(ra) # 80003872 <ilock>
  if(ip->type != T_DIR){
    80005b6a:	04449703          	lh	a4,68(s1)
    80005b6e:	4785                	li	a5,1
    80005b70:	04f71163          	bne	a4,a5,80005bb2 <sys_chdir+0x94>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b74:	8526                	mv	a0,s1
    80005b76:	ffffe097          	auipc	ra,0xffffe
    80005b7a:	dc2080e7          	jalr	-574(ra) # 80003938 <iunlock>
  iput(p->cwd);
    80005b7e:	15093503          	ld	a0,336(s2)
    80005b82:	ffffe097          	auipc	ra,0xffffe
    80005b86:	eae080e7          	jalr	-338(ra) # 80003a30 <iput>
  end_op();
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	734080e7          	jalr	1844(ra) # 800042be <end_op>
  p->cwd = ip;
    80005b92:	14993823          	sd	s1,336(s2)
  return 0;
    80005b96:	4501                	li	a0,0
    80005b98:	64aa                	ld	s1,136(sp)
}
    80005b9a:	60ea                	ld	ra,152(sp)
    80005b9c:	644a                	ld	s0,144(sp)
    80005b9e:	690a                	ld	s2,128(sp)
    80005ba0:	610d                	add	sp,sp,160
    80005ba2:	8082                	ret
    80005ba4:	64aa                	ld	s1,136(sp)
    end_op();
    80005ba6:	ffffe097          	auipc	ra,0xffffe
    80005baa:	718080e7          	jalr	1816(ra) # 800042be <end_op>
    return -1;
    80005bae:	557d                	li	a0,-1
    80005bb0:	b7ed                	j	80005b9a <sys_chdir+0x7c>
    iunlockput(ip);
    80005bb2:	8526                	mv	a0,s1
    80005bb4:	ffffe097          	auipc	ra,0xffffe
    80005bb8:	f24080e7          	jalr	-220(ra) # 80003ad8 <iunlockput>
    end_op();
    80005bbc:	ffffe097          	auipc	ra,0xffffe
    80005bc0:	702080e7          	jalr	1794(ra) # 800042be <end_op>
    return -1;
    80005bc4:	557d                	li	a0,-1
    80005bc6:	64aa                	ld	s1,136(sp)
    80005bc8:	bfc9                	j	80005b9a <sys_chdir+0x7c>

0000000080005bca <sys_exec>:

uint64
sys_exec(void)
{
    80005bca:	7121                	add	sp,sp,-448
    80005bcc:	ff06                	sd	ra,440(sp)
    80005bce:	fb22                	sd	s0,432(sp)
    80005bd0:	f34a                	sd	s2,416(sp)
    80005bd2:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005bd4:	08000613          	li	a2,128
    80005bd8:	f5040593          	add	a1,s0,-176
    80005bdc:	4501                	li	a0,0
    80005bde:	ffffd097          	auipc	ra,0xffffd
    80005be2:	050080e7          	jalr	80(ra) # 80002c2e <argstr>
    return -1;
    80005be6:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005be8:	0e054a63          	bltz	a0,80005cdc <sys_exec+0x112>
    80005bec:	e4840593          	add	a1,s0,-440
    80005bf0:	4505                	li	a0,1
    80005bf2:	ffffd097          	auipc	ra,0xffffd
    80005bf6:	01a080e7          	jalr	26(ra) # 80002c0c <argaddr>
    80005bfa:	0e054163          	bltz	a0,80005cdc <sys_exec+0x112>
    80005bfe:	f726                	sd	s1,424(sp)
    80005c00:	ef4e                	sd	s3,408(sp)
    80005c02:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005c04:	10000613          	li	a2,256
    80005c08:	4581                	li	a1,0
    80005c0a:	e5040513          	add	a0,s0,-432
    80005c0e:	ffffb097          	auipc	ra,0xffffb
    80005c12:	120080e7          	jalr	288(ra) # 80000d2e <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c16:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005c1a:	89a6                	mv	s3,s1
    80005c1c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c1e:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c22:	00391513          	sll	a0,s2,0x3
    80005c26:	e4040593          	add	a1,s0,-448
    80005c2a:	e4843783          	ld	a5,-440(s0)
    80005c2e:	953e                	add	a0,a0,a5
    80005c30:	ffffd097          	auipc	ra,0xffffd
    80005c34:	f20080e7          	jalr	-224(ra) # 80002b50 <fetchaddr>
    80005c38:	02054a63          	bltz	a0,80005c6c <sys_exec+0xa2>
      goto bad;
    }
    if(uarg == 0){
    80005c3c:	e4043783          	ld	a5,-448(s0)
    80005c40:	c7b1                	beqz	a5,80005c8c <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c42:	ffffb097          	auipc	ra,0xffffb
    80005c46:	f00080e7          	jalr	-256(ra) # 80000b42 <kalloc>
    80005c4a:	85aa                	mv	a1,a0
    80005c4c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c50:	cd11                	beqz	a0,80005c6c <sys_exec+0xa2>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c52:	6605                	lui	a2,0x1
    80005c54:	e4043503          	ld	a0,-448(s0)
    80005c58:	ffffd097          	auipc	ra,0xffffd
    80005c5c:	f4a080e7          	jalr	-182(ra) # 80002ba2 <fetchstr>
    80005c60:	00054663          	bltz	a0,80005c6c <sys_exec+0xa2>
    if(i >= NELEM(argv)){
    80005c64:	0905                	add	s2,s2,1
    80005c66:	09a1                	add	s3,s3,8
    80005c68:	fb491de3          	bne	s2,s4,80005c22 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c6c:	f5040913          	add	s2,s0,-176
    80005c70:	6088                	ld	a0,0(s1)
    80005c72:	c12d                	beqz	a0,80005cd4 <sys_exec+0x10a>
    kfree(argv[i]);
    80005c74:	ffffb097          	auipc	ra,0xffffb
    80005c78:	dd0080e7          	jalr	-560(ra) # 80000a44 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c7c:	04a1                	add	s1,s1,8
    80005c7e:	ff2499e3          	bne	s1,s2,80005c70 <sys_exec+0xa6>
  return -1;
    80005c82:	597d                	li	s2,-1
    80005c84:	74ba                	ld	s1,424(sp)
    80005c86:	69fa                	ld	s3,408(sp)
    80005c88:	6a5a                	ld	s4,400(sp)
    80005c8a:	a889                	j	80005cdc <sys_exec+0x112>
      argv[i] = 0;
    80005c8c:	0009079b          	sext.w	a5,s2
    80005c90:	078e                	sll	a5,a5,0x3
    80005c92:	fd078793          	add	a5,a5,-48
    80005c96:	97a2                	add	a5,a5,s0
    80005c98:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005c9c:	e5040593          	add	a1,s0,-432
    80005ca0:	f5040513          	add	a0,s0,-176
    80005ca4:	fffff097          	auipc	ra,0xfffff
    80005ca8:	11a080e7          	jalr	282(ra) # 80004dbe <exec>
    80005cac:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cae:	f5040993          	add	s3,s0,-176
    80005cb2:	6088                	ld	a0,0(s1)
    80005cb4:	cd01                	beqz	a0,80005ccc <sys_exec+0x102>
    kfree(argv[i]);
    80005cb6:	ffffb097          	auipc	ra,0xffffb
    80005cba:	d8e080e7          	jalr	-626(ra) # 80000a44 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cbe:	04a1                	add	s1,s1,8
    80005cc0:	ff3499e3          	bne	s1,s3,80005cb2 <sys_exec+0xe8>
    80005cc4:	74ba                	ld	s1,424(sp)
    80005cc6:	69fa                	ld	s3,408(sp)
    80005cc8:	6a5a                	ld	s4,400(sp)
    80005cca:	a809                	j	80005cdc <sys_exec+0x112>
  return ret;
    80005ccc:	74ba                	ld	s1,424(sp)
    80005cce:	69fa                	ld	s3,408(sp)
    80005cd0:	6a5a                	ld	s4,400(sp)
    80005cd2:	a029                	j	80005cdc <sys_exec+0x112>
  return -1;
    80005cd4:	597d                	li	s2,-1
    80005cd6:	74ba                	ld	s1,424(sp)
    80005cd8:	69fa                	ld	s3,408(sp)
    80005cda:	6a5a                	ld	s4,400(sp)
}
    80005cdc:	854a                	mv	a0,s2
    80005cde:	70fa                	ld	ra,440(sp)
    80005ce0:	745a                	ld	s0,432(sp)
    80005ce2:	791a                	ld	s2,416(sp)
    80005ce4:	6139                	add	sp,sp,448
    80005ce6:	8082                	ret

0000000080005ce8 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ce8:	7139                	add	sp,sp,-64
    80005cea:	fc06                	sd	ra,56(sp)
    80005cec:	f822                	sd	s0,48(sp)
    80005cee:	f426                	sd	s1,40(sp)
    80005cf0:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cf2:	ffffc097          	auipc	ra,0xffffc
    80005cf6:	e38080e7          	jalr	-456(ra) # 80001b2a <myproc>
    80005cfa:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005cfc:	fd840593          	add	a1,s0,-40
    80005d00:	4501                	li	a0,0
    80005d02:	ffffd097          	auipc	ra,0xffffd
    80005d06:	f0a080e7          	jalr	-246(ra) # 80002c0c <argaddr>
    return -1;
    80005d0a:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005d0c:	0e054063          	bltz	a0,80005dec <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005d10:	fc840593          	add	a1,s0,-56
    80005d14:	fd040513          	add	a0,s0,-48
    80005d18:	fffff097          	auipc	ra,0xfffff
    80005d1c:	d64080e7          	jalr	-668(ra) # 80004a7c <pipealloc>
    return -1;
    80005d20:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d22:	0c054563          	bltz	a0,80005dec <sys_pipe+0x104>
  fd0 = -1;
    80005d26:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d2a:	fd043503          	ld	a0,-48(s0)
    80005d2e:	fffff097          	auipc	ra,0xfffff
    80005d32:	4ce080e7          	jalr	1230(ra) # 800051fc <fdalloc>
    80005d36:	fca42223          	sw	a0,-60(s0)
    80005d3a:	08054c63          	bltz	a0,80005dd2 <sys_pipe+0xea>
    80005d3e:	fc843503          	ld	a0,-56(s0)
    80005d42:	fffff097          	auipc	ra,0xfffff
    80005d46:	4ba080e7          	jalr	1210(ra) # 800051fc <fdalloc>
    80005d4a:	fca42023          	sw	a0,-64(s0)
    80005d4e:	06054963          	bltz	a0,80005dc0 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d52:	4691                	li	a3,4
    80005d54:	fc440613          	add	a2,s0,-60
    80005d58:	fd843583          	ld	a1,-40(s0)
    80005d5c:	68a8                	ld	a0,80(s1)
    80005d5e:	ffffc097          	auipc	ra,0xffffc
    80005d62:	96e080e7          	jalr	-1682(ra) # 800016cc <copyout>
    80005d66:	02054063          	bltz	a0,80005d86 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d6a:	4691                	li	a3,4
    80005d6c:	fc040613          	add	a2,s0,-64
    80005d70:	fd843583          	ld	a1,-40(s0)
    80005d74:	0591                	add	a1,a1,4
    80005d76:	68a8                	ld	a0,80(s1)
    80005d78:	ffffc097          	auipc	ra,0xffffc
    80005d7c:	954080e7          	jalr	-1708(ra) # 800016cc <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d80:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d82:	06055563          	bgez	a0,80005dec <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005d86:	fc442783          	lw	a5,-60(s0)
    80005d8a:	07e9                	add	a5,a5,26
    80005d8c:	078e                	sll	a5,a5,0x3
    80005d8e:	97a6                	add	a5,a5,s1
    80005d90:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d94:	fc042783          	lw	a5,-64(s0)
    80005d98:	07e9                	add	a5,a5,26
    80005d9a:	078e                	sll	a5,a5,0x3
    80005d9c:	00f48533          	add	a0,s1,a5
    80005da0:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005da4:	fd043503          	ld	a0,-48(s0)
    80005da8:	fffff097          	auipc	ra,0xfffff
    80005dac:	966080e7          	jalr	-1690(ra) # 8000470e <fileclose>
    fileclose(wf);
    80005db0:	fc843503          	ld	a0,-56(s0)
    80005db4:	fffff097          	auipc	ra,0xfffff
    80005db8:	95a080e7          	jalr	-1702(ra) # 8000470e <fileclose>
    return -1;
    80005dbc:	57fd                	li	a5,-1
    80005dbe:	a03d                	j	80005dec <sys_pipe+0x104>
    if(fd0 >= 0)
    80005dc0:	fc442783          	lw	a5,-60(s0)
    80005dc4:	0007c763          	bltz	a5,80005dd2 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005dc8:	07e9                	add	a5,a5,26
    80005dca:	078e                	sll	a5,a5,0x3
    80005dcc:	97a6                	add	a5,a5,s1
    80005dce:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005dd2:	fd043503          	ld	a0,-48(s0)
    80005dd6:	fffff097          	auipc	ra,0xfffff
    80005dda:	938080e7          	jalr	-1736(ra) # 8000470e <fileclose>
    fileclose(wf);
    80005dde:	fc843503          	ld	a0,-56(s0)
    80005de2:	fffff097          	auipc	ra,0xfffff
    80005de6:	92c080e7          	jalr	-1748(ra) # 8000470e <fileclose>
    return -1;
    80005dea:	57fd                	li	a5,-1
}
    80005dec:	853e                	mv	a0,a5
    80005dee:	70e2                	ld	ra,56(sp)
    80005df0:	7442                	ld	s0,48(sp)
    80005df2:	74a2                	ld	s1,40(sp)
    80005df4:	6121                	add	sp,sp,64
    80005df6:	8082                	ret
	...

0000000080005e00 <kernelvec>:
    80005e00:	7111                	add	sp,sp,-256
    80005e02:	e006                	sd	ra,0(sp)
    80005e04:	e40a                	sd	sp,8(sp)
    80005e06:	e80e                	sd	gp,16(sp)
    80005e08:	ec12                	sd	tp,24(sp)
    80005e0a:	f016                	sd	t0,32(sp)
    80005e0c:	f41a                	sd	t1,40(sp)
    80005e0e:	f81e                	sd	t2,48(sp)
    80005e10:	fc22                	sd	s0,56(sp)
    80005e12:	e0a6                	sd	s1,64(sp)
    80005e14:	e4aa                	sd	a0,72(sp)
    80005e16:	e8ae                	sd	a1,80(sp)
    80005e18:	ecb2                	sd	a2,88(sp)
    80005e1a:	f0b6                	sd	a3,96(sp)
    80005e1c:	f4ba                	sd	a4,104(sp)
    80005e1e:	f8be                	sd	a5,112(sp)
    80005e20:	fcc2                	sd	a6,120(sp)
    80005e22:	e146                	sd	a7,128(sp)
    80005e24:	e54a                	sd	s2,136(sp)
    80005e26:	e94e                	sd	s3,144(sp)
    80005e28:	ed52                	sd	s4,152(sp)
    80005e2a:	f156                	sd	s5,160(sp)
    80005e2c:	f55a                	sd	s6,168(sp)
    80005e2e:	f95e                	sd	s7,176(sp)
    80005e30:	fd62                	sd	s8,184(sp)
    80005e32:	e1e6                	sd	s9,192(sp)
    80005e34:	e5ea                	sd	s10,200(sp)
    80005e36:	e9ee                	sd	s11,208(sp)
    80005e38:	edf2                	sd	t3,216(sp)
    80005e3a:	f1f6                	sd	t4,224(sp)
    80005e3c:	f5fa                	sd	t5,232(sp)
    80005e3e:	f9fe                	sd	t6,240(sp)
    80005e40:	bddfc0ef          	jal	80002a1c <kerneltrap>
    80005e44:	6082                	ld	ra,0(sp)
    80005e46:	6122                	ld	sp,8(sp)
    80005e48:	61c2                	ld	gp,16(sp)
    80005e4a:	7282                	ld	t0,32(sp)
    80005e4c:	7322                	ld	t1,40(sp)
    80005e4e:	73c2                	ld	t2,48(sp)
    80005e50:	7462                	ld	s0,56(sp)
    80005e52:	6486                	ld	s1,64(sp)
    80005e54:	6526                	ld	a0,72(sp)
    80005e56:	65c6                	ld	a1,80(sp)
    80005e58:	6666                	ld	a2,88(sp)
    80005e5a:	7686                	ld	a3,96(sp)
    80005e5c:	7726                	ld	a4,104(sp)
    80005e5e:	77c6                	ld	a5,112(sp)
    80005e60:	7866                	ld	a6,120(sp)
    80005e62:	688a                	ld	a7,128(sp)
    80005e64:	692a                	ld	s2,136(sp)
    80005e66:	69ca                	ld	s3,144(sp)
    80005e68:	6a6a                	ld	s4,152(sp)
    80005e6a:	7a8a                	ld	s5,160(sp)
    80005e6c:	7b2a                	ld	s6,168(sp)
    80005e6e:	7bca                	ld	s7,176(sp)
    80005e70:	7c6a                	ld	s8,184(sp)
    80005e72:	6c8e                	ld	s9,192(sp)
    80005e74:	6d2e                	ld	s10,200(sp)
    80005e76:	6dce                	ld	s11,208(sp)
    80005e78:	6e6e                	ld	t3,216(sp)
    80005e7a:	7e8e                	ld	t4,224(sp)
    80005e7c:	7f2e                	ld	t5,232(sp)
    80005e7e:	7fce                	ld	t6,240(sp)
    80005e80:	6111                	add	sp,sp,256
    80005e82:	10200073          	sret
    80005e86:	00000013          	nop
    80005e8a:	00000013          	nop
    80005e8e:	0001                	nop

0000000080005e90 <timervec>:
    80005e90:	34051573          	csrrw	a0,mscratch,a0
    80005e94:	e10c                	sd	a1,0(a0)
    80005e96:	e510                	sd	a2,8(a0)
    80005e98:	e914                	sd	a3,16(a0)
    80005e9a:	6d0c                	ld	a1,24(a0)
    80005e9c:	7110                	ld	a2,32(a0)
    80005e9e:	6194                	ld	a3,0(a1)
    80005ea0:	96b2                	add	a3,a3,a2
    80005ea2:	e194                	sd	a3,0(a1)
    80005ea4:	4589                	li	a1,2
    80005ea6:	14459073          	csrw	sip,a1
    80005eaa:	6914                	ld	a3,16(a0)
    80005eac:	6510                	ld	a2,8(a0)
    80005eae:	610c                	ld	a1,0(a0)
    80005eb0:	34051573          	csrrw	a0,mscratch,a0
    80005eb4:	30200073          	mret
	...

0000000080005eba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eba:	1141                	add	sp,sp,-16
    80005ebc:	e422                	sd	s0,8(sp)
    80005ebe:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ec0:	0c0007b7          	lui	a5,0xc000
    80005ec4:	4705                	li	a4,1
    80005ec6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ec8:	0c0007b7          	lui	a5,0xc000
    80005ecc:	c3d8                	sw	a4,4(a5)
}
    80005ece:	6422                	ld	s0,8(sp)
    80005ed0:	0141                	add	sp,sp,16
    80005ed2:	8082                	ret

0000000080005ed4 <plicinithart>:

void
plicinithart(void)
{
    80005ed4:	1141                	add	sp,sp,-16
    80005ed6:	e406                	sd	ra,8(sp)
    80005ed8:	e022                	sd	s0,0(sp)
    80005eda:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005edc:	ffffc097          	auipc	ra,0xffffc
    80005ee0:	c22080e7          	jalr	-990(ra) # 80001afe <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ee4:	0085171b          	sllw	a4,a0,0x8
    80005ee8:	0c0027b7          	lui	a5,0xc002
    80005eec:	97ba                	add	a5,a5,a4
    80005eee:	40200713          	li	a4,1026
    80005ef2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ef6:	00d5151b          	sllw	a0,a0,0xd
    80005efa:	0c2017b7          	lui	a5,0xc201
    80005efe:	97aa                	add	a5,a5,a0
    80005f00:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005f04:	60a2                	ld	ra,8(sp)
    80005f06:	6402                	ld	s0,0(sp)
    80005f08:	0141                	add	sp,sp,16
    80005f0a:	8082                	ret

0000000080005f0c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f0c:	1141                	add	sp,sp,-16
    80005f0e:	e406                	sd	ra,8(sp)
    80005f10:	e022                	sd	s0,0(sp)
    80005f12:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005f14:	ffffc097          	auipc	ra,0xffffc
    80005f18:	bea080e7          	jalr	-1046(ra) # 80001afe <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f1c:	00d5151b          	sllw	a0,a0,0xd
    80005f20:	0c2017b7          	lui	a5,0xc201
    80005f24:	97aa                	add	a5,a5,a0
  return irq;
}
    80005f26:	43c8                	lw	a0,4(a5)
    80005f28:	60a2                	ld	ra,8(sp)
    80005f2a:	6402                	ld	s0,0(sp)
    80005f2c:	0141                	add	sp,sp,16
    80005f2e:	8082                	ret

0000000080005f30 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f30:	1101                	add	sp,sp,-32
    80005f32:	ec06                	sd	ra,24(sp)
    80005f34:	e822                	sd	s0,16(sp)
    80005f36:	e426                	sd	s1,8(sp)
    80005f38:	1000                	add	s0,sp,32
    80005f3a:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f3c:	ffffc097          	auipc	ra,0xffffc
    80005f40:	bc2080e7          	jalr	-1086(ra) # 80001afe <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f44:	00d5151b          	sllw	a0,a0,0xd
    80005f48:	0c2017b7          	lui	a5,0xc201
    80005f4c:	97aa                	add	a5,a5,a0
    80005f4e:	c3c4                	sw	s1,4(a5)
}
    80005f50:	60e2                	ld	ra,24(sp)
    80005f52:	6442                	ld	s0,16(sp)
    80005f54:	64a2                	ld	s1,8(sp)
    80005f56:	6105                	add	sp,sp,32
    80005f58:	8082                	ret

0000000080005f5a <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f5a:	1141                	add	sp,sp,-16
    80005f5c:	e406                	sd	ra,8(sp)
    80005f5e:	e022                	sd	s0,0(sp)
    80005f60:	0800                	add	s0,sp,16
  if(i >= NUM)
    80005f62:	479d                	li	a5,7
    80005f64:	06a7c863          	blt	a5,a0,80005fd4 <free_desc+0x7a>
    panic("free_desc 1");
  if(disk.free[i])
    80005f68:	0001d717          	auipc	a4,0x1d
    80005f6c:	09870713          	add	a4,a4,152 # 80023000 <disk>
    80005f70:	972a                	add	a4,a4,a0
    80005f72:	6789                	lui	a5,0x2
    80005f74:	97ba                	add	a5,a5,a4
    80005f76:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005f7a:	e7ad                	bnez	a5,80005fe4 <free_desc+0x8a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f7c:	00451793          	sll	a5,a0,0x4
    80005f80:	0001f717          	auipc	a4,0x1f
    80005f84:	08070713          	add	a4,a4,128 # 80025000 <disk+0x2000>
    80005f88:	6314                	ld	a3,0(a4)
    80005f8a:	96be                	add	a3,a3,a5
    80005f8c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005f90:	6314                	ld	a3,0(a4)
    80005f92:	96be                	add	a3,a3,a5
    80005f94:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005f98:	6314                	ld	a3,0(a4)
    80005f9a:	96be                	add	a3,a3,a5
    80005f9c:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005fa0:	6318                	ld	a4,0(a4)
    80005fa2:	97ba                	add	a5,a5,a4
    80005fa4:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80005fa8:	0001d717          	auipc	a4,0x1d
    80005fac:	05870713          	add	a4,a4,88 # 80023000 <disk>
    80005fb0:	972a                	add	a4,a4,a0
    80005fb2:	6789                	lui	a5,0x2
    80005fb4:	97ba                	add	a5,a5,a4
    80005fb6:	4705                	li	a4,1
    80005fb8:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005fbc:	0001f517          	auipc	a0,0x1f
    80005fc0:	05c50513          	add	a0,a0,92 # 80025018 <disk+0x2018>
    80005fc4:	ffffc097          	auipc	ra,0xffffc
    80005fc8:	3b8080e7          	jalr	952(ra) # 8000237c <wakeup>
}
    80005fcc:	60a2                	ld	ra,8(sp)
    80005fce:	6402                	ld	s0,0(sp)
    80005fd0:	0141                	add	sp,sp,16
    80005fd2:	8082                	ret
    panic("free_desc 1");
    80005fd4:	00002517          	auipc	a0,0x2
    80005fd8:	6ac50513          	add	a0,a0,1708 # 80008680 <etext+0x680>
    80005fdc:	ffffa097          	auipc	ra,0xffffa
    80005fe0:	57e080e7          	jalr	1406(ra) # 8000055a <panic>
    panic("free_desc 2");
    80005fe4:	00002517          	auipc	a0,0x2
    80005fe8:	6ac50513          	add	a0,a0,1708 # 80008690 <etext+0x690>
    80005fec:	ffffa097          	auipc	ra,0xffffa
    80005ff0:	56e080e7          	jalr	1390(ra) # 8000055a <panic>

0000000080005ff4 <virtio_disk_init>:
{
    80005ff4:	1141                	add	sp,sp,-16
    80005ff6:	e406                	sd	ra,8(sp)
    80005ff8:	e022                	sd	s0,0(sp)
    80005ffa:	0800                	add	s0,sp,16
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ffc:	00002597          	auipc	a1,0x2
    80006000:	6a458593          	add	a1,a1,1700 # 800086a0 <etext+0x6a0>
    80006004:	0001f517          	auipc	a0,0x1f
    80006008:	12450513          	add	a0,a0,292 # 80025128 <disk+0x2128>
    8000600c:	ffffb097          	auipc	ra,0xffffb
    80006010:	b96080e7          	jalr	-1130(ra) # 80000ba2 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006014:	100017b7          	lui	a5,0x10001
    80006018:	4398                	lw	a4,0(a5)
    8000601a:	2701                	sext.w	a4,a4
    8000601c:	747277b7          	lui	a5,0x74727
    80006020:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006024:	0ef71f63          	bne	a4,a5,80006122 <virtio_disk_init+0x12e>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006028:	100017b7          	lui	a5,0x10001
    8000602c:	0791                	add	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    8000602e:	439c                	lw	a5,0(a5)
    80006030:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006032:	4705                	li	a4,1
    80006034:	0ee79763          	bne	a5,a4,80006122 <virtio_disk_init+0x12e>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006038:	100017b7          	lui	a5,0x10001
    8000603c:	07a1                	add	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    8000603e:	439c                	lw	a5,0(a5)
    80006040:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006042:	4709                	li	a4,2
    80006044:	0ce79f63          	bne	a5,a4,80006122 <virtio_disk_init+0x12e>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006048:	100017b7          	lui	a5,0x10001
    8000604c:	47d8                	lw	a4,12(a5)
    8000604e:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006050:	554d47b7          	lui	a5,0x554d4
    80006054:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006058:	0cf71563          	bne	a4,a5,80006122 <virtio_disk_init+0x12e>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000605c:	100017b7          	lui	a5,0x10001
    80006060:	4705                	li	a4,1
    80006062:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006064:	470d                	li	a4,3
    80006066:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006068:	10001737          	lui	a4,0x10001
    8000606c:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    8000606e:	c7ffe737          	lui	a4,0xc7ffe
    80006072:	75f70713          	add	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006076:	8ef9                	and	a3,a3,a4
    80006078:	10001737          	lui	a4,0x10001
    8000607c:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000607e:	472d                	li	a4,11
    80006080:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006082:	473d                	li	a4,15
    80006084:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006086:	100017b7          	lui	a5,0x10001
    8000608a:	6705                	lui	a4,0x1
    8000608c:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000608e:	100017b7          	lui	a5,0x10001
    80006092:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006096:	100017b7          	lui	a5,0x10001
    8000609a:	03478793          	add	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    8000609e:	439c                	lw	a5,0(a5)
    800060a0:	2781                	sext.w	a5,a5
  if(max == 0)
    800060a2:	cbc1                	beqz	a5,80006132 <virtio_disk_init+0x13e>
  if(max < NUM)
    800060a4:	471d                	li	a4,7
    800060a6:	08f77e63          	bgeu	a4,a5,80006142 <virtio_disk_init+0x14e>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800060aa:	100017b7          	lui	a5,0x10001
    800060ae:	4721                	li	a4,8
    800060b0:	df98                	sw	a4,56(a5)
  memset(disk.pages, 0, sizeof(disk.pages));
    800060b2:	6609                	lui	a2,0x2
    800060b4:	4581                	li	a1,0
    800060b6:	0001d517          	auipc	a0,0x1d
    800060ba:	f4a50513          	add	a0,a0,-182 # 80023000 <disk>
    800060be:	ffffb097          	auipc	ra,0xffffb
    800060c2:	c70080e7          	jalr	-912(ra) # 80000d2e <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800060c6:	0001d697          	auipc	a3,0x1d
    800060ca:	f3a68693          	add	a3,a3,-198 # 80023000 <disk>
    800060ce:	00c6d713          	srl	a4,a3,0xc
    800060d2:	2701                	sext.w	a4,a4
    800060d4:	100017b7          	lui	a5,0x10001
    800060d8:	c3b8                	sw	a4,64(a5)
  disk.desc = (struct virtq_desc *) disk.pages;
    800060da:	0001f797          	auipc	a5,0x1f
    800060de:	f2678793          	add	a5,a5,-218 # 80025000 <disk+0x2000>
    800060e2:	e394                	sd	a3,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800060e4:	0001d717          	auipc	a4,0x1d
    800060e8:	f9c70713          	add	a4,a4,-100 # 80023080 <disk+0x80>
    800060ec:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800060ee:	0001e717          	auipc	a4,0x1e
    800060f2:	f1270713          	add	a4,a4,-238 # 80024000 <disk+0x1000>
    800060f6:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800060f8:	4705                	li	a4,1
    800060fa:	00e78c23          	sb	a4,24(a5)
    800060fe:	00e78ca3          	sb	a4,25(a5)
    80006102:	00e78d23          	sb	a4,26(a5)
    80006106:	00e78da3          	sb	a4,27(a5)
    8000610a:	00e78e23          	sb	a4,28(a5)
    8000610e:	00e78ea3          	sb	a4,29(a5)
    80006112:	00e78f23          	sb	a4,30(a5)
    80006116:	00e78fa3          	sb	a4,31(a5)
}
    8000611a:	60a2                	ld	ra,8(sp)
    8000611c:	6402                	ld	s0,0(sp)
    8000611e:	0141                	add	sp,sp,16
    80006120:	8082                	ret
    panic("could not find virtio disk");
    80006122:	00002517          	auipc	a0,0x2
    80006126:	58e50513          	add	a0,a0,1422 # 800086b0 <etext+0x6b0>
    8000612a:	ffffa097          	auipc	ra,0xffffa
    8000612e:	430080e7          	jalr	1072(ra) # 8000055a <panic>
    panic("virtio disk has no queue 0");
    80006132:	00002517          	auipc	a0,0x2
    80006136:	59e50513          	add	a0,a0,1438 # 800086d0 <etext+0x6d0>
    8000613a:	ffffa097          	auipc	ra,0xffffa
    8000613e:	420080e7          	jalr	1056(ra) # 8000055a <panic>
    panic("virtio disk max queue too short");
    80006142:	00002517          	auipc	a0,0x2
    80006146:	5ae50513          	add	a0,a0,1454 # 800086f0 <etext+0x6f0>
    8000614a:	ffffa097          	auipc	ra,0xffffa
    8000614e:	410080e7          	jalr	1040(ra) # 8000055a <panic>

0000000080006152 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006152:	7159                	add	sp,sp,-112
    80006154:	f486                	sd	ra,104(sp)
    80006156:	f0a2                	sd	s0,96(sp)
    80006158:	eca6                	sd	s1,88(sp)
    8000615a:	e8ca                	sd	s2,80(sp)
    8000615c:	e4ce                	sd	s3,72(sp)
    8000615e:	e0d2                	sd	s4,64(sp)
    80006160:	fc56                	sd	s5,56(sp)
    80006162:	f85a                	sd	s6,48(sp)
    80006164:	f45e                	sd	s7,40(sp)
    80006166:	f062                	sd	s8,32(sp)
    80006168:	ec66                	sd	s9,24(sp)
    8000616a:	1880                	add	s0,sp,112
    8000616c:	8a2a                	mv	s4,a0
    8000616e:	8cae                	mv	s9,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006170:	00c52c03          	lw	s8,12(a0)
    80006174:	001c1c1b          	sllw	s8,s8,0x1
    80006178:	1c02                	sll	s8,s8,0x20
    8000617a:	020c5c13          	srl	s8,s8,0x20

  acquire(&disk.vdisk_lock);
    8000617e:	0001f517          	auipc	a0,0x1f
    80006182:	faa50513          	add	a0,a0,-86 # 80025128 <disk+0x2128>
    80006186:	ffffb097          	auipc	ra,0xffffb
    8000618a:	aac080e7          	jalr	-1364(ra) # 80000c32 <acquire>
  for(int i = 0; i < 3; i++){
    8000618e:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006190:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006192:	0001db97          	auipc	s7,0x1d
    80006196:	e6eb8b93          	add	s7,s7,-402 # 80023000 <disk>
    8000619a:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    8000619c:	4a8d                	li	s5,3
    8000619e:	a88d                	j	80006210 <virtio_disk_rw+0xbe>
      disk.free[i] = 0;
    800061a0:	00fb8733          	add	a4,s7,a5
    800061a4:	975a                	add	a4,a4,s6
    800061a6:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800061aa:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800061ac:	0207c563          	bltz	a5,800061d6 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800061b0:	2905                	addw	s2,s2,1
    800061b2:	0611                	add	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    800061b4:	1b590163          	beq	s2,s5,80006356 <virtio_disk_rw+0x204>
    idx[i] = alloc_desc();
    800061b8:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800061ba:	0001f717          	auipc	a4,0x1f
    800061be:	e5e70713          	add	a4,a4,-418 # 80025018 <disk+0x2018>
    800061c2:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800061c4:	00074683          	lbu	a3,0(a4)
    800061c8:	fee1                	bnez	a3,800061a0 <virtio_disk_rw+0x4e>
  for(int i = 0; i < NUM; i++){
    800061ca:	2785                	addw	a5,a5,1
    800061cc:	0705                	add	a4,a4,1
    800061ce:	fe979be3          	bne	a5,s1,800061c4 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800061d2:	57fd                	li	a5,-1
    800061d4:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800061d6:	03205163          	blez	s2,800061f8 <virtio_disk_rw+0xa6>
        free_desc(idx[j]);
    800061da:	f9042503          	lw	a0,-112(s0)
    800061de:	00000097          	auipc	ra,0x0
    800061e2:	d7c080e7          	jalr	-644(ra) # 80005f5a <free_desc>
      for(int j = 0; j < i; j++)
    800061e6:	4785                	li	a5,1
    800061e8:	0127d863          	bge	a5,s2,800061f8 <virtio_disk_rw+0xa6>
        free_desc(idx[j]);
    800061ec:	f9442503          	lw	a0,-108(s0)
    800061f0:	00000097          	auipc	ra,0x0
    800061f4:	d6a080e7          	jalr	-662(ra) # 80005f5a <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061f8:	0001f597          	auipc	a1,0x1f
    800061fc:	f3058593          	add	a1,a1,-208 # 80025128 <disk+0x2128>
    80006200:	0001f517          	auipc	a0,0x1f
    80006204:	e1850513          	add	a0,a0,-488 # 80025018 <disk+0x2018>
    80006208:	ffffc097          	auipc	ra,0xffffc
    8000620c:	fe8080e7          	jalr	-24(ra) # 800021f0 <sleep>
  for(int i = 0; i < 3; i++){
    80006210:	f9040613          	add	a2,s0,-112
    80006214:	894e                	mv	s2,s3
    80006216:	b74d                	j	800061b8 <virtio_disk_rw+0x66>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006218:	0001f717          	auipc	a4,0x1f
    8000621c:	de873703          	ld	a4,-536(a4) # 80025000 <disk+0x2000>
    80006220:	973e                	add	a4,a4,a5
    80006222:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006226:	0001d897          	auipc	a7,0x1d
    8000622a:	dda88893          	add	a7,a7,-550 # 80023000 <disk>
    8000622e:	0001f717          	auipc	a4,0x1f
    80006232:	dd270713          	add	a4,a4,-558 # 80025000 <disk+0x2000>
    80006236:	6314                	ld	a3,0(a4)
    80006238:	96be                	add	a3,a3,a5
    8000623a:	00c6d583          	lhu	a1,12(a3)
    8000623e:	0015e593          	or	a1,a1,1
    80006242:	00b69623          	sh	a1,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006246:	f9842683          	lw	a3,-104(s0)
    8000624a:	630c                	ld	a1,0(a4)
    8000624c:	97ae                	add	a5,a5,a1
    8000624e:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006252:	20050593          	add	a1,a0,512
    80006256:	0592                	sll	a1,a1,0x4
    80006258:	95c6                	add	a1,a1,a7
    8000625a:	57fd                	li	a5,-1
    8000625c:	02f58823          	sb	a5,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006260:	00469793          	sll	a5,a3,0x4
    80006264:	00073803          	ld	a6,0(a4)
    80006268:	983e                	add	a6,a6,a5
    8000626a:	6689                	lui	a3,0x2
    8000626c:	03068693          	add	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006270:	96b2                	add	a3,a3,a2
    80006272:	96c6                	add	a3,a3,a7
    80006274:	00d83023          	sd	a3,0(a6)
  disk.desc[idx[2]].len = 1;
    80006278:	6314                	ld	a3,0(a4)
    8000627a:	96be                	add	a3,a3,a5
    8000627c:	4605                	li	a2,1
    8000627e:	c690                	sw	a2,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006280:	6314                	ld	a3,0(a4)
    80006282:	96be                	add	a3,a3,a5
    80006284:	4809                	li	a6,2
    80006286:	01069623          	sh	a6,12(a3)
  disk.desc[idx[2]].next = 0;
    8000628a:	6314                	ld	a3,0(a4)
    8000628c:	97b6                	add	a5,a5,a3
    8000628e:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006292:	00ca2223          	sw	a2,4(s4)
  disk.info[idx[0]].b = b;
    80006296:	0345b423          	sd	s4,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000629a:	6714                	ld	a3,8(a4)
    8000629c:	0026d783          	lhu	a5,2(a3)
    800062a0:	8b9d                	and	a5,a5,7
    800062a2:	0786                	sll	a5,a5,0x1
    800062a4:	96be                	add	a3,a3,a5
    800062a6:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800062aa:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800062ae:	6718                	ld	a4,8(a4)
    800062b0:	00275783          	lhu	a5,2(a4)
    800062b4:	2785                	addw	a5,a5,1
    800062b6:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800062ba:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800062be:	100017b7          	lui	a5,0x10001
    800062c2:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800062c6:	004a2783          	lw	a5,4(s4)
    800062ca:	02c79163          	bne	a5,a2,800062ec <virtio_disk_rw+0x19a>
    sleep(b, &disk.vdisk_lock);
    800062ce:	0001f917          	auipc	s2,0x1f
    800062d2:	e5a90913          	add	s2,s2,-422 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    800062d6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800062d8:	85ca                	mv	a1,s2
    800062da:	8552                	mv	a0,s4
    800062dc:	ffffc097          	auipc	ra,0xffffc
    800062e0:	f14080e7          	jalr	-236(ra) # 800021f0 <sleep>
  while(b->disk == 1) {
    800062e4:	004a2783          	lw	a5,4(s4)
    800062e8:	fe9788e3          	beq	a5,s1,800062d8 <virtio_disk_rw+0x186>
  }

  disk.info[idx[0]].b = 0;
    800062ec:	f9042903          	lw	s2,-112(s0)
    800062f0:	20090713          	add	a4,s2,512
    800062f4:	0712                	sll	a4,a4,0x4
    800062f6:	0001d797          	auipc	a5,0x1d
    800062fa:	d0a78793          	add	a5,a5,-758 # 80023000 <disk>
    800062fe:	97ba                	add	a5,a5,a4
    80006300:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006304:	0001f997          	auipc	s3,0x1f
    80006308:	cfc98993          	add	s3,s3,-772 # 80025000 <disk+0x2000>
    8000630c:	00491713          	sll	a4,s2,0x4
    80006310:	0009b783          	ld	a5,0(s3)
    80006314:	97ba                	add	a5,a5,a4
    80006316:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000631a:	854a                	mv	a0,s2
    8000631c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006320:	00000097          	auipc	ra,0x0
    80006324:	c3a080e7          	jalr	-966(ra) # 80005f5a <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006328:	8885                	and	s1,s1,1
    8000632a:	f0ed                	bnez	s1,8000630c <virtio_disk_rw+0x1ba>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000632c:	0001f517          	auipc	a0,0x1f
    80006330:	dfc50513          	add	a0,a0,-516 # 80025128 <disk+0x2128>
    80006334:	ffffb097          	auipc	ra,0xffffb
    80006338:	9b2080e7          	jalr	-1614(ra) # 80000ce6 <release>
}
    8000633c:	70a6                	ld	ra,104(sp)
    8000633e:	7406                	ld	s0,96(sp)
    80006340:	64e6                	ld	s1,88(sp)
    80006342:	6946                	ld	s2,80(sp)
    80006344:	69a6                	ld	s3,72(sp)
    80006346:	6a06                	ld	s4,64(sp)
    80006348:	7ae2                	ld	s5,56(sp)
    8000634a:	7b42                	ld	s6,48(sp)
    8000634c:	7ba2                	ld	s7,40(sp)
    8000634e:	7c02                	ld	s8,32(sp)
    80006350:	6ce2                	ld	s9,24(sp)
    80006352:	6165                	add	sp,sp,112
    80006354:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006356:	f9042503          	lw	a0,-112(s0)
    8000635a:	00451613          	sll	a2,a0,0x4
  if(write)
    8000635e:	0001d597          	auipc	a1,0x1d
    80006362:	ca258593          	add	a1,a1,-862 # 80023000 <disk>
    80006366:	20050793          	add	a5,a0,512
    8000636a:	0792                	sll	a5,a5,0x4
    8000636c:	97ae                	add	a5,a5,a1
    8000636e:	01903733          	snez	a4,s9
    80006372:	0ae7a423          	sw	a4,168(a5)
  buf0->reserved = 0;
    80006376:	0a07a623          	sw	zero,172(a5)
  buf0->sector = sector;
    8000637a:	0b87b823          	sd	s8,176(a5)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000637e:	0001f717          	auipc	a4,0x1f
    80006382:	c8270713          	add	a4,a4,-894 # 80025000 <disk+0x2000>
    80006386:	6314                	ld	a3,0(a4)
    80006388:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000638a:	6789                	lui	a5,0x2
    8000638c:	0a878793          	add	a5,a5,168 # 20a8 <_entry-0x7fffdf58>
    80006390:	97b2                	add	a5,a5,a2
    80006392:	97ae                	add	a5,a5,a1
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006394:	e29c                	sd	a5,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006396:	631c                	ld	a5,0(a4)
    80006398:	97b2                	add	a5,a5,a2
    8000639a:	46c1                	li	a3,16
    8000639c:	c794                	sw	a3,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000639e:	631c                	ld	a5,0(a4)
    800063a0:	97b2                	add	a5,a5,a2
    800063a2:	4685                	li	a3,1
    800063a4:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800063a8:	f9442783          	lw	a5,-108(s0)
    800063ac:	6314                	ld	a3,0(a4)
    800063ae:	96b2                	add	a3,a3,a2
    800063b0:	00f69723          	sh	a5,14(a3)
  disk.desc[idx[1]].addr = (uint64) b->data;
    800063b4:	0792                	sll	a5,a5,0x4
    800063b6:	6314                	ld	a3,0(a4)
    800063b8:	96be                	add	a3,a3,a5
    800063ba:	058a0593          	add	a1,s4,88
    800063be:	e28c                	sd	a1,0(a3)
  disk.desc[idx[1]].len = BSIZE;
    800063c0:	6318                	ld	a4,0(a4)
    800063c2:	973e                	add	a4,a4,a5
    800063c4:	40000693          	li	a3,1024
    800063c8:	c714                	sw	a3,8(a4)
  if(write)
    800063ca:	e40c97e3          	bnez	s9,80006218 <virtio_disk_rw+0xc6>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800063ce:	0001f717          	auipc	a4,0x1f
    800063d2:	c3273703          	ld	a4,-974(a4) # 80025000 <disk+0x2000>
    800063d6:	973e                	add	a4,a4,a5
    800063d8:	4689                	li	a3,2
    800063da:	00d71623          	sh	a3,12(a4)
    800063de:	b5a1                	j	80006226 <virtio_disk_rw+0xd4>

00000000800063e0 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063e0:	1101                	add	sp,sp,-32
    800063e2:	ec06                	sd	ra,24(sp)
    800063e4:	e822                	sd	s0,16(sp)
    800063e6:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063e8:	0001f517          	auipc	a0,0x1f
    800063ec:	d4050513          	add	a0,a0,-704 # 80025128 <disk+0x2128>
    800063f0:	ffffb097          	auipc	ra,0xffffb
    800063f4:	842080e7          	jalr	-1982(ra) # 80000c32 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800063f8:	100017b7          	lui	a5,0x10001
    800063fc:	53b8                	lw	a4,96(a5)
    800063fe:	8b0d                	and	a4,a4,3
    80006400:	100017b7          	lui	a5,0x10001
    80006404:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80006406:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000640a:	0001f797          	auipc	a5,0x1f
    8000640e:	bf678793          	add	a5,a5,-1034 # 80025000 <disk+0x2000>
    80006412:	6b94                	ld	a3,16(a5)
    80006414:	0207d703          	lhu	a4,32(a5)
    80006418:	0026d783          	lhu	a5,2(a3)
    8000641c:	06f70563          	beq	a4,a5,80006486 <virtio_disk_intr+0xa6>
    80006420:	e426                	sd	s1,8(sp)
    80006422:	e04a                	sd	s2,0(sp)
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006424:	0001d917          	auipc	s2,0x1d
    80006428:	bdc90913          	add	s2,s2,-1060 # 80023000 <disk>
    8000642c:	0001f497          	auipc	s1,0x1f
    80006430:	bd448493          	add	s1,s1,-1068 # 80025000 <disk+0x2000>
    __sync_synchronize();
    80006434:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006438:	6898                	ld	a4,16(s1)
    8000643a:	0204d783          	lhu	a5,32(s1)
    8000643e:	8b9d                	and	a5,a5,7
    80006440:	078e                	sll	a5,a5,0x3
    80006442:	97ba                	add	a5,a5,a4
    80006444:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006446:	20078713          	add	a4,a5,512
    8000644a:	0712                	sll	a4,a4,0x4
    8000644c:	974a                	add	a4,a4,s2
    8000644e:	03074703          	lbu	a4,48(a4)
    80006452:	e731                	bnez	a4,8000649e <virtio_disk_intr+0xbe>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006454:	20078793          	add	a5,a5,512
    80006458:	0792                	sll	a5,a5,0x4
    8000645a:	97ca                	add	a5,a5,s2
    8000645c:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    8000645e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006462:	ffffc097          	auipc	ra,0xffffc
    80006466:	f1a080e7          	jalr	-230(ra) # 8000237c <wakeup>

    disk.used_idx += 1;
    8000646a:	0204d783          	lhu	a5,32(s1)
    8000646e:	2785                	addw	a5,a5,1
    80006470:	17c2                	sll	a5,a5,0x30
    80006472:	93c1                	srl	a5,a5,0x30
    80006474:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006478:	6898                	ld	a4,16(s1)
    8000647a:	00275703          	lhu	a4,2(a4)
    8000647e:	faf71be3          	bne	a4,a5,80006434 <virtio_disk_intr+0x54>
    80006482:	64a2                	ld	s1,8(sp)
    80006484:	6902                	ld	s2,0(sp)
  }

  release(&disk.vdisk_lock);
    80006486:	0001f517          	auipc	a0,0x1f
    8000648a:	ca250513          	add	a0,a0,-862 # 80025128 <disk+0x2128>
    8000648e:	ffffb097          	auipc	ra,0xffffb
    80006492:	858080e7          	jalr	-1960(ra) # 80000ce6 <release>
}
    80006496:	60e2                	ld	ra,24(sp)
    80006498:	6442                	ld	s0,16(sp)
    8000649a:	6105                	add	sp,sp,32
    8000649c:	8082                	ret
      panic("virtio_disk_intr status");
    8000649e:	00002517          	auipc	a0,0x2
    800064a2:	27250513          	add	a0,a0,626 # 80008710 <etext+0x710>
    800064a6:	ffffa097          	auipc	ra,0xffffa
    800064aa:	0b4080e7          	jalr	180(ra) # 8000055a <panic>
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
