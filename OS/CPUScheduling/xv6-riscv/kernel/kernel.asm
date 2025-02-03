
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
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
    80000022:	f14027f3          	csrr	a5,mhartid
    80000026:	0007859b          	sext.w	a1,a5
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
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	ff070713          	add	a4,a4,-16 # 80009040 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
    8000005a:	ef1c                	sd	a5,24(a4)
    8000005c:	f310                	sd	a2,32(a4)
    8000005e:	34071073          	csrw	mscratch,a4
    80000062:	00006797          	auipc	a5,0x6
    80000066:	ffe78793          	add	a5,a5,-2 # 80006060 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
    8000006e:	300027f3          	csrr	a5,mstatus
    80000072:	0087e793          	or	a5,a5,8
    80000076:	30079073          	csrw	mstatus,a5
    8000007a:	304027f3          	csrr	a5,mie
    8000007e:	0807e793          	or	a5,a5,128
    80000082:	30479073          	csrw	mie,a5
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
    80000094:	300027f3          	csrr	a5,mstatus
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    8000009e:	8ff9                	and	a5,a5,a4
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
    800000a8:	30079073          	csrw	mstatus,a5
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e2078793          	add	a5,a5,-480 # 80000ecc <main>
    800000b4:	34179073          	csrw	mepc,a5
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
    800000c6:	30379073          	csrw	mideleg,a5
    800000ca:	104027f3          	csrr	a5,sie
    800000ce:	2227e793          	or	a5,a5,546
    800000d2:	10479073          	csrw	sie,a5
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
    800000ec:	f14027f3          	csrr	a5,mhartid
    800000f0:	2781                	sext.w	a5,a5
    800000f2:	823e                	mv	tp,a5
    800000f4:	30200073          	mret
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	f84a                	sd	s2,48(sp)
    80000108:	0880                	add	s0,sp,80
    8000010a:	04c05663          	blez	a2,80000156 <consolewrite+0x56>
    8000010e:	fc26                	sd	s1,56(sp)
    80000110:	f44e                	sd	s3,40(sp)
    80000112:	f052                	sd	s4,32(sp)
    80000114:	ec56                	sd	s5,24(sp)
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	3e4080e7          	jalr	996(ra) # 8000250e <either_copyin>
    80000132:	03550463          	beq	a0,s5,8000015a <consolewrite+0x5a>
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	7de080e7          	jalr	2014(ra) # 80000918 <uartputc>
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
    80000162:	854a                	mv	a0,s2
    80000164:	60a6                	ld	ra,72(sp)
    80000166:	6406                	ld	s0,64(sp)
    80000168:	7942                	ld	s2,48(sp)
    8000016a:	6161                	add	sp,sp,80
    8000016c:	8082                	ret

000000008000016e <consoleread>:
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
    80000188:	00060b1b          	sext.w	s6,a2
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	ff450513          	add	a0,a0,-12 # 80011180 <cons>
    80000194:	00001097          	auipc	ra,0x1
    80000198:	a9e080e7          	jalr	-1378(ra) # 80000c32 <acquire>
    8000019c:	00011497          	auipc	s1,0x11
    800001a0:	fe448493          	add	s1,s1,-28 # 80011180 <cons>
    800001a4:	00011917          	auipc	s2,0x11
    800001a8:	07490913          	add	s2,s2,116 # 80011218 <cons+0x98>
    800001ac:	0d305463          	blez	s3,80000274 <consoleread+0x106>
    800001b0:	0984a783          	lw	a5,152(s1)
    800001b4:	09c4a703          	lw	a4,156(s1)
    800001b8:	0af71963          	bne	a4,a5,8000026a <consoleread+0xfc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	868080e7          	jalr	-1944(ra) # 80001a24 <myproc>
    800001c4:	4d3c                	lw	a5,88(a0)
    800001c6:	e7ad                	bnez	a5,80000230 <consoleread+0xc2>
    800001c8:	85a6                	mv	a1,s1
    800001ca:	854a                	mv	a0,s2
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	f3c080e7          	jalr	-196(ra) # 80002108 <sleep>
    800001d4:	0984a783          	lw	a5,152(s1)
    800001d8:	09c4a703          	lw	a4,156(s1)
    800001dc:	fef700e3          	beq	a4,a5,800001bc <consoleread+0x4e>
    800001e0:	ec5e                	sd	s7,24(sp)
    800001e2:	00011717          	auipc	a4,0x11
    800001e6:	f9e70713          	add	a4,a4,-98 # 80011180 <cons>
    800001ea:	0017869b          	addw	a3,a5,1
    800001ee:	08d72c23          	sw	a3,152(a4)
    800001f2:	07f7f693          	and	a3,a5,127
    800001f6:	9736                	add	a4,a4,a3
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070b9b          	sext.w	s7,a4
    80000200:	4691                	li	a3,4
    80000202:	04db8a63          	beq	s7,a3,80000256 <consoleread+0xe8>
    80000206:	fae407a3          	sb	a4,-81(s0)
    8000020a:	4685                	li	a3,1
    8000020c:	faf40613          	add	a2,s0,-81
    80000210:	85d2                	mv	a1,s4
    80000212:	8556                	mv	a0,s5
    80000214:	00002097          	auipc	ra,0x2
    80000218:	2a4080e7          	jalr	676(ra) # 800024b8 <either_copyout>
    8000021c:	57fd                	li	a5,-1
    8000021e:	04f50a63          	beq	a0,a5,80000272 <consoleread+0x104>
    80000222:	0a05                	add	s4,s4,1
    80000224:	39fd                	addw	s3,s3,-1
    80000226:	47a9                	li	a5,10
    80000228:	06fb8163          	beq	s7,a5,8000028a <consoleread+0x11c>
    8000022c:	6be2                	ld	s7,24(sp)
    8000022e:	bfbd                	j	800001ac <consoleread+0x3e>
    80000230:	00011517          	auipc	a0,0x11
    80000234:	f5050513          	add	a0,a0,-176 # 80011180 <cons>
    80000238:	00001097          	auipc	ra,0x1
    8000023c:	aae080e7          	jalr	-1362(ra) # 80000ce6 <release>
    80000240:	557d                	li	a0,-1
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
    80000256:	0009871b          	sext.w	a4,s3
    8000025a:	01677a63          	bgeu	a4,s6,8000026e <consoleread+0x100>
    8000025e:	00011717          	auipc	a4,0x11
    80000262:	faf72d23          	sw	a5,-70(a4) # 80011218 <cons+0x98>
    80000266:	6be2                	ld	s7,24(sp)
    80000268:	a031                	j	80000274 <consoleread+0x106>
    8000026a:	ec5e                	sd	s7,24(sp)
    8000026c:	bf9d                	j	800001e2 <consoleread+0x74>
    8000026e:	6be2                	ld	s7,24(sp)
    80000270:	a011                	j	80000274 <consoleread+0x106>
    80000272:	6be2                	ld	s7,24(sp)
    80000274:	00011517          	auipc	a0,0x11
    80000278:	f0c50513          	add	a0,a0,-244 # 80011180 <cons>
    8000027c:	00001097          	auipc	ra,0x1
    80000280:	a6a080e7          	jalr	-1430(ra) # 80000ce6 <release>
    80000284:	413b053b          	subw	a0,s6,s3
    80000288:	bf6d                	j	80000242 <consoleread+0xd4>
    8000028a:	6be2                	ld	s7,24(sp)
    8000028c:	b7e5                	j	80000274 <consoleread+0x106>

000000008000028e <consputc>:
    8000028e:	1141                	add	sp,sp,-16
    80000290:	e406                	sd	ra,8(sp)
    80000292:	e022                	sd	s0,0(sp)
    80000294:	0800                	add	s0,sp,16
    80000296:	10000793          	li	a5,256
    8000029a:	00f50a63          	beq	a0,a5,800002ae <consputc+0x20>
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	59c080e7          	jalr	1436(ra) # 8000083a <uartputc_sync>
    800002a6:	60a2                	ld	ra,8(sp)
    800002a8:	6402                	ld	s0,0(sp)
    800002aa:	0141                	add	sp,sp,16
    800002ac:	8082                	ret
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
    800002d0:	1101                	add	sp,sp,-32
    800002d2:	ec06                	sd	ra,24(sp)
    800002d4:	e822                	sd	s0,16(sp)
    800002d6:	e426                	sd	s1,8(sp)
    800002d8:	1000                	add	s0,sp,32
    800002da:	84aa                	mv	s1,a0
    800002dc:	00011517          	auipc	a0,0x11
    800002e0:	ea450513          	add	a0,a0,-348 # 80011180 <cons>
    800002e4:	00001097          	auipc	ra,0x1
    800002e8:	94e080e7          	jalr	-1714(ra) # 80000c32 <acquire>
    800002ec:	47d5                	li	a5,21
    800002ee:	0af48563          	beq	s1,a5,80000398 <consoleintr+0xc8>
    800002f2:	0297c963          	blt	a5,s1,80000324 <consoleintr+0x54>
    800002f6:	47a1                	li	a5,8
    800002f8:	0ef48c63          	beq	s1,a5,800003f0 <consoleintr+0x120>
    800002fc:	47c1                	li	a5,16
    800002fe:	10f49f63          	bne	s1,a5,8000041c <consoleintr+0x14c>
    80000302:	00002097          	auipc	ra,0x2
    80000306:	262080e7          	jalr	610(ra) # 80002564 <procdump>
    8000030a:	00011517          	auipc	a0,0x11
    8000030e:	e7650513          	add	a0,a0,-394 # 80011180 <cons>
    80000312:	00001097          	auipc	ra,0x1
    80000316:	9d4080e7          	jalr	-1580(ra) # 80000ce6 <release>
    8000031a:	60e2                	ld	ra,24(sp)
    8000031c:	6442                	ld	s0,16(sp)
    8000031e:	64a2                	ld	s1,8(sp)
    80000320:	6105                	add	sp,sp,32
    80000322:	8082                	ret
    80000324:	07f00793          	li	a5,127
    80000328:	0cf48463          	beq	s1,a5,800003f0 <consoleintr+0x120>
    8000032c:	00011717          	auipc	a4,0x11
    80000330:	e5470713          	add	a4,a4,-428 # 80011180 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09872703          	lw	a4,152(a4)
    8000033c:	9f99                	subw	a5,a5,a4
    8000033e:	07f00713          	li	a4,127
    80000342:	fcf764e3          	bltu	a4,a5,8000030a <consoleintr+0x3a>
    80000346:	47b5                	li	a5,13
    80000348:	0cf48d63          	beq	s1,a5,80000422 <consoleintr+0x152>
    8000034c:	8526                	mv	a0,s1
    8000034e:	00000097          	auipc	ra,0x0
    80000352:	f40080e7          	jalr	-192(ra) # 8000028e <consputc>
    80000356:	00011797          	auipc	a5,0x11
    8000035a:	e2a78793          	add	a5,a5,-470 # 80011180 <cons>
    8000035e:	0a07a703          	lw	a4,160(a5)
    80000362:	0017069b          	addw	a3,a4,1
    80000366:	0006861b          	sext.w	a2,a3
    8000036a:	0ad7a023          	sw	a3,160(a5)
    8000036e:	07f77713          	and	a4,a4,127
    80000372:	97ba                	add	a5,a5,a4
    80000374:	00978c23          	sb	s1,24(a5)
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
    8000039a:	00011717          	auipc	a4,0x11
    8000039e:	de670713          	add	a4,a4,-538 # 80011180 <cons>
    800003a2:	0a072783          	lw	a5,160(a4)
    800003a6:	09c72703          	lw	a4,156(a4)
    800003aa:	00011497          	auipc	s1,0x11
    800003ae:	dd648493          	add	s1,s1,-554 # 80011180 <cons>
    800003b2:	4929                	li	s2,10
    800003b4:	02f70a63          	beq	a4,a5,800003e8 <consoleintr+0x118>
    800003b8:	37fd                	addw	a5,a5,-1
    800003ba:	07f7f713          	and	a4,a5,127
    800003be:	9726                	add	a4,a4,s1
    800003c0:	01874703          	lbu	a4,24(a4)
    800003c4:	03270463          	beq	a4,s2,800003ec <consoleintr+0x11c>
    800003c8:	0af4a023          	sw	a5,160(s1)
    800003cc:	10000513          	li	a0,256
    800003d0:	00000097          	auipc	ra,0x0
    800003d4:	ebe080e7          	jalr	-322(ra) # 8000028e <consputc>
    800003d8:	0a04a783          	lw	a5,160(s1)
    800003dc:	09c4a703          	lw	a4,156(s1)
    800003e0:	fcf71ce3          	bne	a4,a5,800003b8 <consoleintr+0xe8>
    800003e4:	6902                	ld	s2,0(sp)
    800003e6:	b715                	j	8000030a <consoleintr+0x3a>
    800003e8:	6902                	ld	s2,0(sp)
    800003ea:	b705                	j	8000030a <consoleintr+0x3a>
    800003ec:	6902                	ld	s2,0(sp)
    800003ee:	bf31                	j	8000030a <consoleintr+0x3a>
    800003f0:	00011717          	auipc	a4,0x11
    800003f4:	d9070713          	add	a4,a4,-624 # 80011180 <cons>
    800003f8:	0a072783          	lw	a5,160(a4)
    800003fc:	09c72703          	lw	a4,156(a4)
    80000400:	f0f705e3          	beq	a4,a5,8000030a <consoleintr+0x3a>
    80000404:	37fd                	addw	a5,a5,-1
    80000406:	00011717          	auipc	a4,0x11
    8000040a:	e0f72d23          	sw	a5,-486(a4) # 80011220 <cons+0xa0>
    8000040e:	10000513          	li	a0,256
    80000412:	00000097          	auipc	ra,0x0
    80000416:	e7c080e7          	jalr	-388(ra) # 8000028e <consputc>
    8000041a:	bdc5                	j	8000030a <consoleintr+0x3a>
    8000041c:	ee0487e3          	beqz	s1,8000030a <consoleintr+0x3a>
    80000420:	b731                	j	8000032c <consoleintr+0x5c>
    80000422:	4529                	li	a0,10
    80000424:	00000097          	auipc	ra,0x0
    80000428:	e6a080e7          	jalr	-406(ra) # 8000028e <consputc>
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
    80000450:	00011797          	auipc	a5,0x11
    80000454:	dcc7a623          	sw	a2,-564(a5) # 8001121c <cons+0x9c>
    80000458:	00011517          	auipc	a0,0x11
    8000045c:	dc050513          	add	a0,a0,-576 # 80011218 <cons+0x98>
    80000460:	00002097          	auipc	ra,0x2
    80000464:	e34080e7          	jalr	-460(ra) # 80002294 <wakeup>
    80000468:	b54d                	j	8000030a <consoleintr+0x3a>

000000008000046a <consoleinit>:
    8000046a:	1141                	add	sp,sp,-16
    8000046c:	e406                	sd	ra,8(sp)
    8000046e:	e022                	sd	s0,0(sp)
    80000470:	0800                	add	s0,sp,16
    80000472:	00008597          	auipc	a1,0x8
    80000476:	b8e58593          	add	a1,a1,-1138 # 80008000 <etext>
    8000047a:	00011517          	auipc	a0,0x11
    8000047e:	d0650513          	add	a0,a0,-762 # 80011180 <cons>
    80000482:	00000097          	auipc	ra,0x0
    80000486:	720080e7          	jalr	1824(ra) # 80000ba2 <initlock>
    8000048a:	00000097          	auipc	ra,0x0
    8000048e:	354080e7          	jalr	852(ra) # 800007de <uartinit>
    80000492:	00022797          	auipc	a5,0x22
    80000496:	a8678793          	add	a5,a5,-1402 # 80021f18 <devsw>
    8000049a:	00000717          	auipc	a4,0x0
    8000049e:	cd470713          	add	a4,a4,-812 # 8000016e <consoleread>
    800004a2:	eb98                	sd	a4,16(a5)
    800004a4:	00000717          	auipc	a4,0x0
    800004a8:	c5c70713          	add	a4,a4,-932 # 80000100 <consolewrite>
    800004ac:	ef98                	sd	a4,24(a5)
    800004ae:	60a2                	ld	ra,8(sp)
    800004b0:	6402                	ld	s0,0(sp)
    800004b2:	0141                	add	sp,sp,16
    800004b4:	8082                	ret

00000000800004b6 <printint>:
    800004b6:	7179                	add	sp,sp,-48
    800004b8:	f406                	sd	ra,40(sp)
    800004ba:	f022                	sd	s0,32(sp)
    800004bc:	1800                	add	s0,sp,48
    800004be:	c219                	beqz	a2,800004c4 <printint+0xe>
    800004c0:	08054963          	bltz	a0,80000552 <printint+0x9c>
    800004c4:	2501                	sext.w	a0,a0
    800004c6:	4881                	li	a7,0
    800004c8:	fd040693          	add	a3,s0,-48
    800004cc:	4701                	li	a4,0
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
    800004ee:	0005079b          	sext.w	a5,a0
    800004f2:	02b5553b          	divuw	a0,a0,a1
    800004f6:	0685                	add	a3,a3,1
    800004f8:	feb7f0e3          	bgeu	a5,a1,800004d8 <printint+0x22>
    800004fc:	00088c63          	beqz	a7,80000514 <printint+0x5e>
    80000500:	fe070793          	add	a5,a4,-32
    80000504:	00878733          	add	a4,a5,s0
    80000508:	02d00793          	li	a5,45
    8000050c:	fef70823          	sb	a5,-16(a4)
    80000510:	0028071b          	addw	a4,a6,2
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
    80000534:	fff4c503          	lbu	a0,-1(s1)
    80000538:	00000097          	auipc	ra,0x0
    8000053c:	d56080e7          	jalr	-682(ra) # 8000028e <consputc>
    80000540:	14fd                	add	s1,s1,-1
    80000542:	ff2499e3          	bne	s1,s2,80000534 <printint+0x7e>
    80000546:	64e2                	ld	s1,24(sp)
    80000548:	6942                	ld	s2,16(sp)
    8000054a:	70a2                	ld	ra,40(sp)
    8000054c:	7402                	ld	s0,32(sp)
    8000054e:	6145                	add	sp,sp,48
    80000550:	8082                	ret
    80000552:	40a0053b          	negw	a0,a0
    80000556:	4885                	li	a7,1
    80000558:	bf85                	j	800004c8 <printint+0x12>

000000008000055a <panic>:
    8000055a:	1101                	add	sp,sp,-32
    8000055c:	ec06                	sd	ra,24(sp)
    8000055e:	e822                	sd	s0,16(sp)
    80000560:	e426                	sd	s1,8(sp)
    80000562:	1000                	add	s0,sp,32
    80000564:	84aa                	mv	s1,a0
    80000566:	00011797          	auipc	a5,0x11
    8000056a:	cc07ad23          	sw	zero,-806(a5) # 80011240 <pr+0x18>
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	a9a50513          	add	a0,a0,-1382 # 80008008 <etext+0x8>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	02e080e7          	jalr	46(ra) # 800005a4 <printf>
    8000057e:	8526                	mv	a0,s1
    80000580:	00000097          	auipc	ra,0x0
    80000584:	024080e7          	jalr	36(ra) # 800005a4 <printf>
    80000588:	00008517          	auipc	a0,0x8
    8000058c:	a8850513          	add	a0,a0,-1400 # 80008010 <etext+0x10>
    80000590:	00000097          	auipc	ra,0x0
    80000594:	014080e7          	jalr	20(ra) # 800005a4 <printf>
    80000598:	4785                	li	a5,1
    8000059a:	00009717          	auipc	a4,0x9
    8000059e:	a6f72323          	sw	a5,-1434(a4) # 80009000 <panicked>
    800005a2:	a001                	j	800005a2 <panic+0x48>

00000000800005a4 <printf>:
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
    800005c4:	00011d17          	auipc	s10,0x11
    800005c8:	c7cd2d03          	lw	s10,-900(s10) # 80011240 <pr+0x18>
    800005cc:	040d1463          	bnez	s10,80000614 <printf+0x70>
    800005d0:	040a0b63          	beqz	s4,80000626 <printf+0x82>
    800005d4:	00840793          	add	a5,s0,8
    800005d8:	f8f43423          	sd	a5,-120(s0)
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
    800005f8:	02500b13          	li	s6,37
    800005fc:	07000b93          	li	s7,112
    80000600:	4cc1                	li	s9,16
    80000602:	00008a97          	auipc	s5,0x8
    80000606:	0f6a8a93          	add	s5,s5,246 # 800086f8 <digits>
    8000060a:	07300c13          	li	s8,115
    8000060e:	06400d93          	li	s11,100
    80000612:	a0b1                	j	8000065e <printf+0xba>
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
    80000638:	00008517          	auipc	a0,0x8
    8000063c:	9e850513          	add	a0,a0,-1560 # 80008020 <etext+0x20>
    80000640:	00000097          	auipc	ra,0x0
    80000644:	f1a080e7          	jalr	-230(ra) # 8000055a <panic>
    80000648:	00000097          	auipc	ra,0x0
    8000064c:	c46080e7          	jalr	-954(ra) # 8000028e <consputc>
    80000650:	2985                	addw	s3,s3,1
    80000652:	013a07b3          	add	a5,s4,s3
    80000656:	0007c503          	lbu	a0,0(a5)
    8000065a:	10050563          	beqz	a0,80000764 <printf+0x1c0>
    8000065e:	ff6515e3          	bne	a0,s6,80000648 <printf+0xa4>
    80000662:	2985                	addw	s3,s3,1
    80000664:	013a07b3          	add	a5,s4,s3
    80000668:	0007c783          	lbu	a5,0(a5)
    8000066c:	0007849b          	sext.w	s1,a5
    80000670:	10078b63          	beqz	a5,80000786 <printf+0x1e2>
    80000674:	05778a63          	beq	a5,s7,800006c8 <printf+0x124>
    80000678:	02fbf663          	bgeu	s7,a5,800006a4 <printf+0x100>
    8000067c:	09878863          	beq	a5,s8,8000070c <printf+0x168>
    80000680:	07800713          	li	a4,120
    80000684:	0ce79563          	bne	a5,a4,8000074e <printf+0x1aa>
    80000688:	f8843783          	ld	a5,-120(s0)
    8000068c:	00878713          	add	a4,a5,8
    80000690:	f8e43423          	sd	a4,-120(s0)
    80000694:	4605                	li	a2,1
    80000696:	85e6                	mv	a1,s9
    80000698:	4388                	lw	a0,0(a5)
    8000069a:	00000097          	auipc	ra,0x0
    8000069e:	e1c080e7          	jalr	-484(ra) # 800004b6 <printint>
    800006a2:	b77d                	j	80000650 <printf+0xac>
    800006a4:	09678f63          	beq	a5,s6,80000742 <printf+0x19e>
    800006a8:	0bb79363          	bne	a5,s11,8000074e <printf+0x1aa>
    800006ac:	f8843783          	ld	a5,-120(s0)
    800006b0:	00878713          	add	a4,a5,8
    800006b4:	f8e43423          	sd	a4,-120(s0)
    800006b8:	4605                	li	a2,1
    800006ba:	45a9                	li	a1,10
    800006bc:	4388                	lw	a0,0(a5)
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	df8080e7          	jalr	-520(ra) # 800004b6 <printint>
    800006c6:	b769                	j	80000650 <printf+0xac>
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	add	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	0007b903          	ld	s2,0(a5)
    800006d8:	03000513          	li	a0,48
    800006dc:	00000097          	auipc	ra,0x0
    800006e0:	bb2080e7          	jalr	-1102(ra) # 8000028e <consputc>
    800006e4:	07800513          	li	a0,120
    800006e8:	00000097          	auipc	ra,0x0
    800006ec:	ba6080e7          	jalr	-1114(ra) # 8000028e <consputc>
    800006f0:	84e6                	mv	s1,s9
    800006f2:	03c95793          	srl	a5,s2,0x3c
    800006f6:	97d6                	add	a5,a5,s5
    800006f8:	0007c503          	lbu	a0,0(a5)
    800006fc:	00000097          	auipc	ra,0x0
    80000700:	b92080e7          	jalr	-1134(ra) # 8000028e <consputc>
    80000704:	0912                	sll	s2,s2,0x4
    80000706:	34fd                	addw	s1,s1,-1
    80000708:	f4ed                	bnez	s1,800006f2 <printf+0x14e>
    8000070a:	b799                	j	80000650 <printf+0xac>
    8000070c:	f8843783          	ld	a5,-120(s0)
    80000710:	00878713          	add	a4,a5,8
    80000714:	f8e43423          	sd	a4,-120(s0)
    80000718:	6384                	ld	s1,0(a5)
    8000071a:	cc89                	beqz	s1,80000734 <printf+0x190>
    8000071c:	0004c503          	lbu	a0,0(s1)
    80000720:	d905                	beqz	a0,80000650 <printf+0xac>
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b6c080e7          	jalr	-1172(ra) # 8000028e <consputc>
    8000072a:	0485                	add	s1,s1,1
    8000072c:	0004c503          	lbu	a0,0(s1)
    80000730:	f96d                	bnez	a0,80000722 <printf+0x17e>
    80000732:	bf39                	j	80000650 <printf+0xac>
    80000734:	00008497          	auipc	s1,0x8
    80000738:	8e448493          	add	s1,s1,-1820 # 80008018 <etext+0x18>
    8000073c:	02800513          	li	a0,40
    80000740:	b7cd                	j	80000722 <printf+0x17e>
    80000742:	855a                	mv	a0,s6
    80000744:	00000097          	auipc	ra,0x0
    80000748:	b4a080e7          	jalr	-1206(ra) # 8000028e <consputc>
    8000074c:	b711                	j	80000650 <printf+0xac>
    8000074e:	855a                	mv	a0,s6
    80000750:	00000097          	auipc	ra,0x0
    80000754:	b3e080e7          	jalr	-1218(ra) # 8000028e <consputc>
    80000758:	8526                	mv	a0,s1
    8000075a:	00000097          	auipc	ra,0x0
    8000075e:	b34080e7          	jalr	-1228(ra) # 8000028e <consputc>
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
    80000776:	020d1263          	bnez	s10,8000079a <printf+0x1f6>
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
    8000079a:	00011517          	auipc	a0,0x11
    8000079e:	a8e50513          	add	a0,a0,-1394 # 80011228 <pr>
    800007a2:	00000097          	auipc	ra,0x0
    800007a6:	544080e7          	jalr	1348(ra) # 80000ce6 <release>
    800007aa:	bfc1                	j	8000077a <printf+0x1d6>

00000000800007ac <printfinit>:
    800007ac:	1101                	add	sp,sp,-32
    800007ae:	ec06                	sd	ra,24(sp)
    800007b0:	e822                	sd	s0,16(sp)
    800007b2:	e426                	sd	s1,8(sp)
    800007b4:	1000                	add	s0,sp,32
    800007b6:	00011497          	auipc	s1,0x11
    800007ba:	a7248493          	add	s1,s1,-1422 # 80011228 <pr>
    800007be:	00008597          	auipc	a1,0x8
    800007c2:	87258593          	add	a1,a1,-1934 # 80008030 <etext+0x30>
    800007c6:	8526                	mv	a0,s1
    800007c8:	00000097          	auipc	ra,0x0
    800007cc:	3da080e7          	jalr	986(ra) # 80000ba2 <initlock>
    800007d0:	4785                	li	a5,1
    800007d2:	cc9c                	sw	a5,24(s1)
    800007d4:	60e2                	ld	ra,24(sp)
    800007d6:	6442                	ld	s0,16(sp)
    800007d8:	64a2                	ld	s1,8(sp)
    800007da:	6105                	add	sp,sp,32
    800007dc:	8082                	ret

00000000800007de <uartinit>:
    800007de:	1141                	add	sp,sp,-16
    800007e0:	e406                	sd	ra,8(sp)
    800007e2:	e022                	sd	s0,0(sp)
    800007e4:	0800                	add	s0,sp,16
    800007e6:	100007b7          	lui	a5,0x10000
    800007ea:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>
    800007ee:	10000737          	lui	a4,0x10000
    800007f2:	f8000693          	li	a3,-128
    800007f6:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>
    800007fa:	468d                	li	a3,3
    800007fc:	10000637          	lui	a2,0x10000
    80000800:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>
    80000804:	000780a3          	sb	zero,1(a5)
    80000808:	00d701a3          	sb	a3,3(a4)
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	461d                	li	a2,7
    80000812:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>
    80000816:	00d780a3          	sb	a3,1(a5)
    8000081a:	00008597          	auipc	a1,0x8
    8000081e:	81e58593          	add	a1,a1,-2018 # 80008038 <etext+0x38>
    80000822:	00011517          	auipc	a0,0x11
    80000826:	a2650513          	add	a0,a0,-1498 # 80011248 <uart_tx_lock>
    8000082a:	00000097          	auipc	ra,0x0
    8000082e:	378080e7          	jalr	888(ra) # 80000ba2 <initlock>
    80000832:	60a2                	ld	ra,8(sp)
    80000834:	6402                	ld	s0,0(sp)
    80000836:	0141                	add	sp,sp,16
    80000838:	8082                	ret

000000008000083a <uartputc_sync>:
    8000083a:	1101                	add	sp,sp,-32
    8000083c:	ec06                	sd	ra,24(sp)
    8000083e:	e822                	sd	s0,16(sp)
    80000840:	e426                	sd	s1,8(sp)
    80000842:	1000                	add	s0,sp,32
    80000844:	84aa                	mv	s1,a0
    80000846:	00000097          	auipc	ra,0x0
    8000084a:	3a0080e7          	jalr	928(ra) # 80000be6 <push_off>
    8000084e:	00008797          	auipc	a5,0x8
    80000852:	7b27a783          	lw	a5,1970(a5) # 80009000 <panicked>
    80000856:	eb85                	bnez	a5,80000886 <uartputc_sync+0x4c>
    80000858:	10000737          	lui	a4,0x10000
    8000085c:	0715                	add	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    8000085e:	00074783          	lbu	a5,0(a4)
    80000862:	0207f793          	and	a5,a5,32
    80000866:	dfe5                	beqz	a5,8000085e <uartputc_sync+0x24>
    80000868:	0ff4f513          	zext.b	a0,s1
    8000086c:	100007b7          	lui	a5,0x10000
    80000870:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>
    80000874:	00000097          	auipc	ra,0x0
    80000878:	412080e7          	jalr	1042(ra) # 80000c86 <pop_off>
    8000087c:	60e2                	ld	ra,24(sp)
    8000087e:	6442                	ld	s0,16(sp)
    80000880:	64a2                	ld	s1,8(sp)
    80000882:	6105                	add	sp,sp,32
    80000884:	8082                	ret
    80000886:	a001                	j	80000886 <uartputc_sync+0x4c>

0000000080000888 <uartstart>:
    80000888:	00008797          	auipc	a5,0x8
    8000088c:	7807b783          	ld	a5,1920(a5) # 80009008 <uart_tx_r>
    80000890:	00008717          	auipc	a4,0x8
    80000894:	78073703          	ld	a4,1920(a4) # 80009010 <uart_tx_w>
    80000898:	06f70f63          	beq	a4,a5,80000916 <uartstart+0x8e>
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
    800008b0:	10000937          	lui	s2,0x10000
    800008b4:	0915                	add	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
    800008b6:	00011a97          	auipc	s5,0x11
    800008ba:	992a8a93          	add	s5,s5,-1646 # 80011248 <uart_tx_lock>
    800008be:	00008497          	auipc	s1,0x8
    800008c2:	74a48493          	add	s1,s1,1866 # 80009008 <uart_tx_r>
    800008c6:	10000a37          	lui	s4,0x10000
    800008ca:	00008997          	auipc	s3,0x8
    800008ce:	74698993          	add	s3,s3,1862 # 80009010 <uart_tx_w>
    800008d2:	00094703          	lbu	a4,0(s2)
    800008d6:	02077713          	and	a4,a4,32
    800008da:	c705                	beqz	a4,80000902 <uartstart+0x7a>
    800008dc:	01f7f713          	and	a4,a5,31
    800008e0:	9756                	add	a4,a4,s5
    800008e2:	01874b03          	lbu	s6,24(a4)
    800008e6:	0785                	add	a5,a5,1
    800008e8:	e09c                	sd	a5,0(s1)
    800008ea:	8526                	mv	a0,s1
    800008ec:	00002097          	auipc	ra,0x2
    800008f0:	9a8080e7          	jalr	-1624(ra) # 80002294 <wakeup>
    800008f4:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    800008f8:	609c                	ld	a5,0(s1)
    800008fa:	0009b703          	ld	a4,0(s3)
    800008fe:	fcf71ae3          	bne	a4,a5,800008d2 <uartstart+0x4a>
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
    80000918:	7179                	add	sp,sp,-48
    8000091a:	f406                	sd	ra,40(sp)
    8000091c:	f022                	sd	s0,32(sp)
    8000091e:	e052                	sd	s4,0(sp)
    80000920:	1800                	add	s0,sp,48
    80000922:	8a2a                	mv	s4,a0
    80000924:	00011517          	auipc	a0,0x11
    80000928:	92450513          	add	a0,a0,-1756 # 80011248 <uart_tx_lock>
    8000092c:	00000097          	auipc	ra,0x0
    80000930:	306080e7          	jalr	774(ra) # 80000c32 <acquire>
    80000934:	00008797          	auipc	a5,0x8
    80000938:	6cc7a783          	lw	a5,1740(a5) # 80009000 <panicked>
    8000093c:	c391                	beqz	a5,80000940 <uartputc+0x28>
    8000093e:	a001                	j	8000093e <uartputc+0x26>
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	00008717          	auipc	a4,0x8
    80000946:	6ce73703          	ld	a4,1742(a4) # 80009010 <uart_tx_w>
    8000094a:	00008797          	auipc	a5,0x8
    8000094e:	6be7b783          	ld	a5,1726(a5) # 80009008 <uart_tx_r>
    80000952:	02078793          	add	a5,a5,32
    80000956:	02e79f63          	bne	a5,a4,80000994 <uartputc+0x7c>
    8000095a:	e84a                	sd	s2,16(sp)
    8000095c:	e44e                	sd	s3,8(sp)
    8000095e:	00011997          	auipc	s3,0x11
    80000962:	8ea98993          	add	s3,s3,-1814 # 80011248 <uart_tx_lock>
    80000966:	00008497          	auipc	s1,0x8
    8000096a:	6a248493          	add	s1,s1,1698 # 80009008 <uart_tx_r>
    8000096e:	00008917          	auipc	s2,0x8
    80000972:	6a290913          	add	s2,s2,1698 # 80009010 <uart_tx_w>
    80000976:	85ce                	mv	a1,s3
    80000978:	8526                	mv	a0,s1
    8000097a:	00001097          	auipc	ra,0x1
    8000097e:	78e080e7          	jalr	1934(ra) # 80002108 <sleep>
    80000982:	00093703          	ld	a4,0(s2)
    80000986:	609c                	ld	a5,0(s1)
    80000988:	02078793          	add	a5,a5,32
    8000098c:	fee785e3          	beq	a5,a4,80000976 <uartputc+0x5e>
    80000990:	6942                	ld	s2,16(sp)
    80000992:	69a2                	ld	s3,8(sp)
    80000994:	00011497          	auipc	s1,0x11
    80000998:	8b448493          	add	s1,s1,-1868 # 80011248 <uart_tx_lock>
    8000099c:	01f77793          	and	a5,a4,31
    800009a0:	97a6                	add	a5,a5,s1
    800009a2:	01478c23          	sb	s4,24(a5)
    800009a6:	0705                	add	a4,a4,1
    800009a8:	00008797          	auipc	a5,0x8
    800009ac:	66e7b423          	sd	a4,1640(a5) # 80009010 <uart_tx_w>
    800009b0:	00000097          	auipc	ra,0x0
    800009b4:	ed8080e7          	jalr	-296(ra) # 80000888 <uartstart>
    800009b8:	8526                	mv	a0,s1
    800009ba:	00000097          	auipc	ra,0x0
    800009be:	32c080e7          	jalr	812(ra) # 80000ce6 <release>
    800009c2:	64e2                	ld	s1,24(sp)
    800009c4:	70a2                	ld	ra,40(sp)
    800009c6:	7402                	ld	s0,32(sp)
    800009c8:	6a02                	ld	s4,0(sp)
    800009ca:	6145                	add	sp,sp,48
    800009cc:	8082                	ret

00000000800009ce <uartgetc>:
    800009ce:	1141                	add	sp,sp,-16
    800009d0:	e422                	sd	s0,8(sp)
    800009d2:	0800                	add	s0,sp,16
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	0795                	add	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009da:	0007c783          	lbu	a5,0(a5)
    800009de:	8b85                	and	a5,a5,1
    800009e0:	cb81                	beqz	a5,800009f0 <uartgetc+0x22>
    800009e2:	100007b7          	lui	a5,0x10000
    800009e6:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009ea:	6422                	ld	s0,8(sp)
    800009ec:	0141                	add	sp,sp,16
    800009ee:	8082                	ret
    800009f0:	557d                	li	a0,-1
    800009f2:	bfe5                	j	800009ea <uartgetc+0x1c>

00000000800009f4 <uartintr>:
    800009f4:	1101                	add	sp,sp,-32
    800009f6:	ec06                	sd	ra,24(sp)
    800009f8:	e822                	sd	s0,16(sp)
    800009fa:	e426                	sd	s1,8(sp)
    800009fc:	1000                	add	s0,sp,32
    800009fe:	54fd                	li	s1,-1
    80000a00:	a029                	j	80000a0a <uartintr+0x16>
    80000a02:	00000097          	auipc	ra,0x0
    80000a06:	8ce080e7          	jalr	-1842(ra) # 800002d0 <consoleintr>
    80000a0a:	00000097          	auipc	ra,0x0
    80000a0e:	fc4080e7          	jalr	-60(ra) # 800009ce <uartgetc>
    80000a12:	fe9518e3          	bne	a0,s1,80000a02 <uartintr+0xe>
    80000a16:	00011497          	auipc	s1,0x11
    80000a1a:	83248493          	add	s1,s1,-1998 # 80011248 <uart_tx_lock>
    80000a1e:	8526                	mv	a0,s1
    80000a20:	00000097          	auipc	ra,0x0
    80000a24:	212080e7          	jalr	530(ra) # 80000c32 <acquire>
    80000a28:	00000097          	auipc	ra,0x0
    80000a2c:	e60080e7          	jalr	-416(ra) # 80000888 <uartstart>
    80000a30:	8526                	mv	a0,s1
    80000a32:	00000097          	auipc	ra,0x0
    80000a36:	2b4080e7          	jalr	692(ra) # 80000ce6 <release>
    80000a3a:	60e2                	ld	ra,24(sp)
    80000a3c:	6442                	ld	s0,16(sp)
    80000a3e:	64a2                	ld	s1,8(sp)
    80000a40:	6105                	add	sp,sp,32
    80000a42:	8082                	ret

0000000080000a44 <kfree>:
    80000a44:	1101                	add	sp,sp,-32
    80000a46:	ec06                	sd	ra,24(sp)
    80000a48:	e822                	sd	s0,16(sp)
    80000a4a:	e426                	sd	s1,8(sp)
    80000a4c:	e04a                	sd	s2,0(sp)
    80000a4e:	1000                	add	s0,sp,32
    80000a50:	03451793          	sll	a5,a0,0x34
    80000a54:	ebb9                	bnez	a5,80000aaa <kfree+0x66>
    80000a56:	84aa                	mv	s1,a0
    80000a58:	00025797          	auipc	a5,0x25
    80000a5c:	5a878793          	add	a5,a5,1448 # 80026000 <end>
    80000a60:	04f56563          	bltu	a0,a5,80000aaa <kfree+0x66>
    80000a64:	47c5                	li	a5,17
    80000a66:	07ee                	sll	a5,a5,0x1b
    80000a68:	04f57163          	bgeu	a0,a5,80000aaa <kfree+0x66>
    80000a6c:	6605                	lui	a2,0x1
    80000a6e:	4585                	li	a1,1
    80000a70:	00000097          	auipc	ra,0x0
    80000a74:	2be080e7          	jalr	702(ra) # 80000d2e <memset>
    80000a78:	00011917          	auipc	s2,0x11
    80000a7c:	80890913          	add	s2,s2,-2040 # 80011280 <kmem>
    80000a80:	854a                	mv	a0,s2
    80000a82:	00000097          	auipc	ra,0x0
    80000a86:	1b0080e7          	jalr	432(ra) # 80000c32 <acquire>
    80000a8a:	01893783          	ld	a5,24(s2)
    80000a8e:	e09c                	sd	a5,0(s1)
    80000a90:	00993c23          	sd	s1,24(s2)
    80000a94:	854a                	mv	a0,s2
    80000a96:	00000097          	auipc	ra,0x0
    80000a9a:	250080e7          	jalr	592(ra) # 80000ce6 <release>
    80000a9e:	60e2                	ld	ra,24(sp)
    80000aa0:	6442                	ld	s0,16(sp)
    80000aa2:	64a2                	ld	s1,8(sp)
    80000aa4:	6902                	ld	s2,0(sp)
    80000aa6:	6105                	add	sp,sp,32
    80000aa8:	8082                	ret
    80000aaa:	00007517          	auipc	a0,0x7
    80000aae:	59650513          	add	a0,a0,1430 # 80008040 <etext+0x40>
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	aa8080e7          	jalr	-1368(ra) # 8000055a <panic>

0000000080000aba <freerange>:
    80000aba:	7179                	add	sp,sp,-48
    80000abc:	f406                	sd	ra,40(sp)
    80000abe:	f022                	sd	s0,32(sp)
    80000ac0:	ec26                	sd	s1,24(sp)
    80000ac2:	1800                	add	s0,sp,48
    80000ac4:	6785                	lui	a5,0x1
    80000ac6:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000aca:	00e504b3          	add	s1,a0,a4
    80000ace:	777d                	lui	a4,0xfffff
    80000ad0:	8cf9                	and	s1,s1,a4
    80000ad2:	94be                	add	s1,s1,a5
    80000ad4:	0295e463          	bltu	a1,s1,80000afc <freerange+0x42>
    80000ad8:	e84a                	sd	s2,16(sp)
    80000ada:	e44e                	sd	s3,8(sp)
    80000adc:	e052                	sd	s4,0(sp)
    80000ade:	892e                	mv	s2,a1
    80000ae0:	7a7d                	lui	s4,0xfffff
    80000ae2:	6985                	lui	s3,0x1
    80000ae4:	01448533          	add	a0,s1,s4
    80000ae8:	00000097          	auipc	ra,0x0
    80000aec:	f5c080e7          	jalr	-164(ra) # 80000a44 <kfree>
    80000af0:	94ce                	add	s1,s1,s3
    80000af2:	fe9979e3          	bgeu	s2,s1,80000ae4 <freerange+0x2a>
    80000af6:	6942                	ld	s2,16(sp)
    80000af8:	69a2                	ld	s3,8(sp)
    80000afa:	6a02                	ld	s4,0(sp)
    80000afc:	70a2                	ld	ra,40(sp)
    80000afe:	7402                	ld	s0,32(sp)
    80000b00:	64e2                	ld	s1,24(sp)
    80000b02:	6145                	add	sp,sp,48
    80000b04:	8082                	ret

0000000080000b06 <kinit>:
    80000b06:	1141                	add	sp,sp,-16
    80000b08:	e406                	sd	ra,8(sp)
    80000b0a:	e022                	sd	s0,0(sp)
    80000b0c:	0800                	add	s0,sp,16
    80000b0e:	00007597          	auipc	a1,0x7
    80000b12:	53a58593          	add	a1,a1,1338 # 80008048 <etext+0x48>
    80000b16:	00010517          	auipc	a0,0x10
    80000b1a:	76a50513          	add	a0,a0,1898 # 80011280 <kmem>
    80000b1e:	00000097          	auipc	ra,0x0
    80000b22:	084080e7          	jalr	132(ra) # 80000ba2 <initlock>
    80000b26:	45c5                	li	a1,17
    80000b28:	05ee                	sll	a1,a1,0x1b
    80000b2a:	00025517          	auipc	a0,0x25
    80000b2e:	4d650513          	add	a0,a0,1238 # 80026000 <end>
    80000b32:	00000097          	auipc	ra,0x0
    80000b36:	f88080e7          	jalr	-120(ra) # 80000aba <freerange>
    80000b3a:	60a2                	ld	ra,8(sp)
    80000b3c:	6402                	ld	s0,0(sp)
    80000b3e:	0141                	add	sp,sp,16
    80000b40:	8082                	ret

0000000080000b42 <kalloc>:
    80000b42:	1101                	add	sp,sp,-32
    80000b44:	ec06                	sd	ra,24(sp)
    80000b46:	e822                	sd	s0,16(sp)
    80000b48:	e426                	sd	s1,8(sp)
    80000b4a:	1000                	add	s0,sp,32
    80000b4c:	00010497          	auipc	s1,0x10
    80000b50:	73448493          	add	s1,s1,1844 # 80011280 <kmem>
    80000b54:	8526                	mv	a0,s1
    80000b56:	00000097          	auipc	ra,0x0
    80000b5a:	0dc080e7          	jalr	220(ra) # 80000c32 <acquire>
    80000b5e:	6c84                	ld	s1,24(s1)
    80000b60:	c885                	beqz	s1,80000b90 <kalloc+0x4e>
    80000b62:	609c                	ld	a5,0(s1)
    80000b64:	00010517          	auipc	a0,0x10
    80000b68:	71c50513          	add	a0,a0,1820 # 80011280 <kmem>
    80000b6c:	ed1c                	sd	a5,24(a0)
    80000b6e:	00000097          	auipc	ra,0x0
    80000b72:	178080e7          	jalr	376(ra) # 80000ce6 <release>
    80000b76:	6605                	lui	a2,0x1
    80000b78:	4595                	li	a1,5
    80000b7a:	8526                	mv	a0,s1
    80000b7c:	00000097          	auipc	ra,0x0
    80000b80:	1b2080e7          	jalr	434(ra) # 80000d2e <memset>
    80000b84:	8526                	mv	a0,s1
    80000b86:	60e2                	ld	ra,24(sp)
    80000b88:	6442                	ld	s0,16(sp)
    80000b8a:	64a2                	ld	s1,8(sp)
    80000b8c:	6105                	add	sp,sp,32
    80000b8e:	8082                	ret
    80000b90:	00010517          	auipc	a0,0x10
    80000b94:	6f050513          	add	a0,a0,1776 # 80011280 <kmem>
    80000b98:	00000097          	auipc	ra,0x0
    80000b9c:	14e080e7          	jalr	334(ra) # 80000ce6 <release>
    80000ba0:	b7d5                	j	80000b84 <kalloc+0x42>

0000000080000ba2 <initlock>:
    80000ba2:	1141                	add	sp,sp,-16
    80000ba4:	e422                	sd	s0,8(sp)
    80000ba6:	0800                	add	s0,sp,16
    80000ba8:	e50c                	sd	a1,8(a0)
    80000baa:	00052023          	sw	zero,0(a0)
    80000bae:	00053823          	sd	zero,16(a0)
    80000bb2:	6422                	ld	s0,8(sp)
    80000bb4:	0141                	add	sp,sp,16
    80000bb6:	8082                	ret

0000000080000bb8 <holding>:
    80000bb8:	411c                	lw	a5,0(a0)
    80000bba:	e399                	bnez	a5,80000bc0 <holding+0x8>
    80000bbc:	4501                	li	a0,0
    80000bbe:	8082                	ret
    80000bc0:	1101                	add	sp,sp,-32
    80000bc2:	ec06                	sd	ra,24(sp)
    80000bc4:	e822                	sd	s0,16(sp)
    80000bc6:	e426                	sd	s1,8(sp)
    80000bc8:	1000                	add	s0,sp,32
    80000bca:	6904                	ld	s1,16(a0)
    80000bcc:	00001097          	auipc	ra,0x1
    80000bd0:	e3c080e7          	jalr	-452(ra) # 80001a08 <mycpu>
    80000bd4:	40a48533          	sub	a0,s1,a0
    80000bd8:	00153513          	seqz	a0,a0
    80000bdc:	60e2                	ld	ra,24(sp)
    80000bde:	6442                	ld	s0,16(sp)
    80000be0:	64a2                	ld	s1,8(sp)
    80000be2:	6105                	add	sp,sp,32
    80000be4:	8082                	ret

0000000080000be6 <push_off>:
    80000be6:	1101                	add	sp,sp,-32
    80000be8:	ec06                	sd	ra,24(sp)
    80000bea:	e822                	sd	s0,16(sp)
    80000bec:	e426                	sd	s1,8(sp)
    80000bee:	1000                	add	s0,sp,32
    80000bf0:	100024f3          	csrr	s1,sstatus
    80000bf4:	100027f3          	csrr	a5,sstatus
    80000bf8:	9bf5                	and	a5,a5,-3
    80000bfa:	10079073          	csrw	sstatus,a5
    80000bfe:	00001097          	auipc	ra,0x1
    80000c02:	e0a080e7          	jalr	-502(ra) # 80001a08 <mycpu>
    80000c06:	5d3c                	lw	a5,120(a0)
    80000c08:	cf89                	beqz	a5,80000c22 <push_off+0x3c>
    80000c0a:	00001097          	auipc	ra,0x1
    80000c0e:	dfe080e7          	jalr	-514(ra) # 80001a08 <mycpu>
    80000c12:	5d3c                	lw	a5,120(a0)
    80000c14:	2785                	addw	a5,a5,1
    80000c16:	dd3c                	sw	a5,120(a0)
    80000c18:	60e2                	ld	ra,24(sp)
    80000c1a:	6442                	ld	s0,16(sp)
    80000c1c:	64a2                	ld	s1,8(sp)
    80000c1e:	6105                	add	sp,sp,32
    80000c20:	8082                	ret
    80000c22:	00001097          	auipc	ra,0x1
    80000c26:	de6080e7          	jalr	-538(ra) # 80001a08 <mycpu>
    80000c2a:	8085                	srl	s1,s1,0x1
    80000c2c:	8885                	and	s1,s1,1
    80000c2e:	dd64                	sw	s1,124(a0)
    80000c30:	bfe9                	j	80000c0a <push_off+0x24>

0000000080000c32 <acquire>:
    80000c32:	1101                	add	sp,sp,-32
    80000c34:	ec06                	sd	ra,24(sp)
    80000c36:	e822                	sd	s0,16(sp)
    80000c38:	e426                	sd	s1,8(sp)
    80000c3a:	1000                	add	s0,sp,32
    80000c3c:	84aa                	mv	s1,a0
    80000c3e:	00000097          	auipc	ra,0x0
    80000c42:	fa8080e7          	jalr	-88(ra) # 80000be6 <push_off>
    80000c46:	8526                	mv	a0,s1
    80000c48:	00000097          	auipc	ra,0x0
    80000c4c:	f70080e7          	jalr	-144(ra) # 80000bb8 <holding>
    80000c50:	4705                	li	a4,1
    80000c52:	e115                	bnez	a0,80000c76 <acquire+0x44>
    80000c54:	87ba                	mv	a5,a4
    80000c56:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c5a:	2781                	sext.w	a5,a5
    80000c5c:	ffe5                	bnez	a5,80000c54 <acquire+0x22>
    80000c5e:	0ff0000f          	fence
    80000c62:	00001097          	auipc	ra,0x1
    80000c66:	da6080e7          	jalr	-602(ra) # 80001a08 <mycpu>
    80000c6a:	e888                	sd	a0,16(s1)
    80000c6c:	60e2                	ld	ra,24(sp)
    80000c6e:	6442                	ld	s0,16(sp)
    80000c70:	64a2                	ld	s1,8(sp)
    80000c72:	6105                	add	sp,sp,32
    80000c74:	8082                	ret
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	3da50513          	add	a0,a0,986 # 80008050 <etext+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8dc080e7          	jalr	-1828(ra) # 8000055a <panic>

0000000080000c86 <pop_off>:
    80000c86:	1141                	add	sp,sp,-16
    80000c88:	e406                	sd	ra,8(sp)
    80000c8a:	e022                	sd	s0,0(sp)
    80000c8c:	0800                	add	s0,sp,16
    80000c8e:	00001097          	auipc	ra,0x1
    80000c92:	d7a080e7          	jalr	-646(ra) # 80001a08 <mycpu>
    80000c96:	100027f3          	csrr	a5,sstatus
    80000c9a:	8b89                	and	a5,a5,2
    80000c9c:	e78d                	bnez	a5,80000cc6 <pop_off+0x40>
    80000c9e:	5d3c                	lw	a5,120(a0)
    80000ca0:	02f05b63          	blez	a5,80000cd6 <pop_off+0x50>
    80000ca4:	37fd                	addw	a5,a5,-1
    80000ca6:	0007871b          	sext.w	a4,a5
    80000caa:	dd3c                	sw	a5,120(a0)
    80000cac:	eb09                	bnez	a4,80000cbe <pop_off+0x38>
    80000cae:	5d7c                	lw	a5,124(a0)
    80000cb0:	c799                	beqz	a5,80000cbe <pop_off+0x38>
    80000cb2:	100027f3          	csrr	a5,sstatus
    80000cb6:	0027e793          	or	a5,a5,2
    80000cba:	10079073          	csrw	sstatus,a5
    80000cbe:	60a2                	ld	ra,8(sp)
    80000cc0:	6402                	ld	s0,0(sp)
    80000cc2:	0141                	add	sp,sp,16
    80000cc4:	8082                	ret
    80000cc6:	00007517          	auipc	a0,0x7
    80000cca:	39250513          	add	a0,a0,914 # 80008058 <etext+0x58>
    80000cce:	00000097          	auipc	ra,0x0
    80000cd2:	88c080e7          	jalr	-1908(ra) # 8000055a <panic>
    80000cd6:	00007517          	auipc	a0,0x7
    80000cda:	39a50513          	add	a0,a0,922 # 80008070 <etext+0x70>
    80000cde:	00000097          	auipc	ra,0x0
    80000ce2:	87c080e7          	jalr	-1924(ra) # 8000055a <panic>

0000000080000ce6 <release>:
    80000ce6:	1101                	add	sp,sp,-32
    80000ce8:	ec06                	sd	ra,24(sp)
    80000cea:	e822                	sd	s0,16(sp)
    80000cec:	e426                	sd	s1,8(sp)
    80000cee:	1000                	add	s0,sp,32
    80000cf0:	84aa                	mv	s1,a0
    80000cf2:	00000097          	auipc	ra,0x0
    80000cf6:	ec6080e7          	jalr	-314(ra) # 80000bb8 <holding>
    80000cfa:	c115                	beqz	a0,80000d1e <release+0x38>
    80000cfc:	0004b823          	sd	zero,16(s1)
    80000d00:	0ff0000f          	fence
    80000d04:	0f50000f          	fence	iorw,ow
    80000d08:	0804a02f          	amoswap.w	zero,zero,(s1)
    80000d0c:	00000097          	auipc	ra,0x0
    80000d10:	f7a080e7          	jalr	-134(ra) # 80000c86 <pop_off>
    80000d14:	60e2                	ld	ra,24(sp)
    80000d16:	6442                	ld	s0,16(sp)
    80000d18:	64a2                	ld	s1,8(sp)
    80000d1a:	6105                	add	sp,sp,32
    80000d1c:	8082                	ret
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
    80000ecc:	1141                	add	sp,sp,-16
    80000ece:	e406                	sd	ra,8(sp)
    80000ed0:	e022                	sd	s0,0(sp)
    80000ed2:	0800                	add	s0,sp,16
    80000ed4:	00001097          	auipc	ra,0x1
    80000ed8:	b24080e7          	jalr	-1244(ra) # 800019f8 <cpuid>
    80000edc:	00008717          	auipc	a4,0x8
    80000ee0:	13c70713          	add	a4,a4,316 # 80009018 <started>
    80000ee4:	c139                	beqz	a0,80000f2a <main+0x5e>
    80000ee6:	431c                	lw	a5,0(a4)
    80000ee8:	2781                	sext.w	a5,a5
    80000eea:	dff5                	beqz	a5,80000ee6 <main+0x1a>
    80000eec:	0ff0000f          	fence
    80000ef0:	00001097          	auipc	ra,0x1
    80000ef4:	b08080e7          	jalr	-1272(ra) # 800019f8 <cpuid>
    80000ef8:	85aa                	mv	a1,a0
    80000efa:	00007517          	auipc	a0,0x7
    80000efe:	19e50513          	add	a0,a0,414 # 80008098 <etext+0x98>
    80000f02:	fffff097          	auipc	ra,0xfffff
    80000f06:	6a2080e7          	jalr	1698(ra) # 800005a4 <printf>
    80000f0a:	00000097          	auipc	ra,0x0
    80000f0e:	0d8080e7          	jalr	216(ra) # 80000fe2 <kvminithart>
    80000f12:	00002097          	auipc	ra,0x2
    80000f16:	93e080e7          	jalr	-1730(ra) # 80002850 <trapinithart>
    80000f1a:	00005097          	auipc	ra,0x5
    80000f1e:	18a080e7          	jalr	394(ra) # 800060a4 <plicinithart>
    80000f22:	00001097          	auipc	ra,0x1
    80000f26:	034080e7          	jalr	52(ra) # 80001f56 <scheduler>
    80000f2a:	fffff097          	auipc	ra,0xfffff
    80000f2e:	540080e7          	jalr	1344(ra) # 8000046a <consoleinit>
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	87a080e7          	jalr	-1926(ra) # 800007ac <printfinit>
    80000f3a:	00007517          	auipc	a0,0x7
    80000f3e:	0d650513          	add	a0,a0,214 # 80008010 <etext+0x10>
    80000f42:	fffff097          	auipc	ra,0xfffff
    80000f46:	662080e7          	jalr	1634(ra) # 800005a4 <printf>
    80000f4a:	00007517          	auipc	a0,0x7
    80000f4e:	13650513          	add	a0,a0,310 # 80008080 <etext+0x80>
    80000f52:	fffff097          	auipc	ra,0xfffff
    80000f56:	652080e7          	jalr	1618(ra) # 800005a4 <printf>
    80000f5a:	00007517          	auipc	a0,0x7
    80000f5e:	0b650513          	add	a0,a0,182 # 80008010 <etext+0x10>
    80000f62:	fffff097          	auipc	ra,0xfffff
    80000f66:	642080e7          	jalr	1602(ra) # 800005a4 <printf>
    80000f6a:	00000097          	auipc	ra,0x0
    80000f6e:	b9c080e7          	jalr	-1124(ra) # 80000b06 <kinit>
    80000f72:	00000097          	auipc	ra,0x0
    80000f76:	322080e7          	jalr	802(ra) # 80001294 <kvminit>
    80000f7a:	00000097          	auipc	ra,0x0
    80000f7e:	068080e7          	jalr	104(ra) # 80000fe2 <kvminithart>
    80000f82:	00001097          	auipc	ra,0x1
    80000f86:	9be080e7          	jalr	-1602(ra) # 80001940 <procinit>
    80000f8a:	00002097          	auipc	ra,0x2
    80000f8e:	89e080e7          	jalr	-1890(ra) # 80002828 <trapinit>
    80000f92:	00002097          	auipc	ra,0x2
    80000f96:	8be080e7          	jalr	-1858(ra) # 80002850 <trapinithart>
    80000f9a:	00005097          	auipc	ra,0x5
    80000f9e:	0f0080e7          	jalr	240(ra) # 8000608a <plicinit>
    80000fa2:	00005097          	auipc	ra,0x5
    80000fa6:	102080e7          	jalr	258(ra) # 800060a4 <plicinithart>
    80000faa:	00002097          	auipc	ra,0x2
    80000fae:	214080e7          	jalr	532(ra) # 800031be <binit>
    80000fb2:	00003097          	auipc	ra,0x3
    80000fb6:	8a0080e7          	jalr	-1888(ra) # 80003852 <iinit>
    80000fba:	00004097          	auipc	ra,0x4
    80000fbe:	844080e7          	jalr	-1980(ra) # 800047fe <fileinit>
    80000fc2:	00005097          	auipc	ra,0x5
    80000fc6:	202080e7          	jalr	514(ra) # 800061c4 <virtio_disk_init>
    80000fca:	00001097          	auipc	ra,0x1
    80000fce:	d50080e7          	jalr	-688(ra) # 80001d1a <userinit>
    80000fd2:	0ff0000f          	fence
    80000fd6:	4785                	li	a5,1
    80000fd8:	00008717          	auipc	a4,0x8
    80000fdc:	04f72023          	sw	a5,64(a4) # 80009018 <started>
    80000fe0:	b789                	j	80000f22 <main+0x56>

0000000080000fe2 <kvminithart>:
    80000fe2:	1141                	add	sp,sp,-16
    80000fe4:	e422                	sd	s0,8(sp)
    80000fe6:	0800                	add	s0,sp,16
    80000fe8:	00008797          	auipc	a5,0x8
    80000fec:	0387b783          	ld	a5,56(a5) # 80009020 <kernel_pagetable>
    80000ff0:	83b1                	srl	a5,a5,0xc
    80000ff2:	577d                	li	a4,-1
    80000ff4:	177e                	sll	a4,a4,0x3f
    80000ff6:	8fd9                	or	a5,a5,a4
    80000ff8:	18079073          	csrw	satp,a5
    80000ffc:	12000073          	sfence.vma
    80001000:	6422                	ld	s0,8(sp)
    80001002:	0141                	add	sp,sp,16
    80001004:	8082                	ret

0000000080001006 <walk>:
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
    80001020:	57fd                	li	a5,-1
    80001022:	83e9                	srl	a5,a5,0x1a
    80001024:	4a79                	li	s4,30
    80001026:	4b31                	li	s6,12
    80001028:	04b7f263          	bgeu	a5,a1,8000106c <walk+0x66>
    8000102c:	00007517          	auipc	a0,0x7
    80001030:	08450513          	add	a0,a0,132 # 800080b0 <etext+0xb0>
    80001034:	fffff097          	auipc	ra,0xfffff
    80001038:	526080e7          	jalr	1318(ra) # 8000055a <panic>
    8000103c:	060a8663          	beqz	s5,800010a8 <walk+0xa2>
    80001040:	00000097          	auipc	ra,0x0
    80001044:	b02080e7          	jalr	-1278(ra) # 80000b42 <kalloc>
    80001048:	84aa                	mv	s1,a0
    8000104a:	c529                	beqz	a0,80001094 <walk+0x8e>
    8000104c:	6605                	lui	a2,0x1
    8000104e:	4581                	li	a1,0
    80001050:	00000097          	auipc	ra,0x0
    80001054:	cde080e7          	jalr	-802(ra) # 80000d2e <memset>
    80001058:	00c4d793          	srl	a5,s1,0xc
    8000105c:	07aa                	sll	a5,a5,0xa
    8000105e:	0017e793          	or	a5,a5,1
    80001062:	00f93023          	sd	a5,0(s2)
    80001066:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd8ff7>
    80001068:	036a0063          	beq	s4,s6,80001088 <walk+0x82>
    8000106c:	0149d933          	srl	s2,s3,s4
    80001070:	1ff97913          	and	s2,s2,511
    80001074:	090e                	sll	s2,s2,0x3
    80001076:	9926                	add	s2,s2,s1
    80001078:	00093483          	ld	s1,0(s2)
    8000107c:	0014f793          	and	a5,s1,1
    80001080:	dfd5                	beqz	a5,8000103c <walk+0x36>
    80001082:	80a9                	srl	s1,s1,0xa
    80001084:	04b2                	sll	s1,s1,0xc
    80001086:	b7c5                	j	80001066 <walk+0x60>
    80001088:	00c9d513          	srl	a0,s3,0xc
    8000108c:	1ff57513          	and	a0,a0,511
    80001090:	050e                	sll	a0,a0,0x3
    80001092:	9526                	add	a0,a0,s1
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
    800010a8:	4501                	li	a0,0
    800010aa:	b7ed                	j	80001094 <walk+0x8e>

00000000800010ac <walkaddr>:
    800010ac:	57fd                	li	a5,-1
    800010ae:	83e9                	srl	a5,a5,0x1a
    800010b0:	00b7f463          	bgeu	a5,a1,800010b8 <walkaddr+0xc>
    800010b4:	4501                	li	a0,0
    800010b6:	8082                	ret
    800010b8:	1141                	add	sp,sp,-16
    800010ba:	e406                	sd	ra,8(sp)
    800010bc:	e022                	sd	s0,0(sp)
    800010be:	0800                	add	s0,sp,16
    800010c0:	4601                	li	a2,0
    800010c2:	00000097          	auipc	ra,0x0
    800010c6:	f44080e7          	jalr	-188(ra) # 80001006 <walk>
    800010ca:	c105                	beqz	a0,800010ea <walkaddr+0x3e>
    800010cc:	611c                	ld	a5,0(a0)
    800010ce:	0117f693          	and	a3,a5,17
    800010d2:	4745                	li	a4,17
    800010d4:	4501                	li	a0,0
    800010d6:	00e68663          	beq	a3,a4,800010e2 <walkaddr+0x36>
    800010da:	60a2                	ld	ra,8(sp)
    800010dc:	6402                	ld	s0,0(sp)
    800010de:	0141                	add	sp,sp,16
    800010e0:	8082                	ret
    800010e2:	83a9                	srl	a5,a5,0xa
    800010e4:	00c79513          	sll	a0,a5,0xc
    800010e8:	bfcd                	j	800010da <walkaddr+0x2e>
    800010ea:	4501                	li	a0,0
    800010ec:	b7fd                	j	800010da <walkaddr+0x2e>

00000000800010ee <mappages>:
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
    80001104:	c639                	beqz	a2,80001152 <mappages+0x64>
    80001106:	8aaa                	mv	s5,a0
    80001108:	8b3a                	mv	s6,a4
    8000110a:	777d                	lui	a4,0xfffff
    8000110c:	00e5f7b3          	and	a5,a1,a4
    80001110:	fff58993          	add	s3,a1,-1
    80001114:	99b2                	add	s3,s3,a2
    80001116:	00e9f9b3          	and	s3,s3,a4
    8000111a:	893e                	mv	s2,a5
    8000111c:	40f68a33          	sub	s4,a3,a5
    80001120:	6b85                	lui	s7,0x1
    80001122:	014904b3          	add	s1,s2,s4
    80001126:	4605                	li	a2,1
    80001128:	85ca                	mv	a1,s2
    8000112a:	8556                	mv	a0,s5
    8000112c:	00000097          	auipc	ra,0x0
    80001130:	eda080e7          	jalr	-294(ra) # 80001006 <walk>
    80001134:	cd1d                	beqz	a0,80001172 <mappages+0x84>
    80001136:	611c                	ld	a5,0(a0)
    80001138:	8b85                	and	a5,a5,1
    8000113a:	e785                	bnez	a5,80001162 <mappages+0x74>
    8000113c:	80b1                	srl	s1,s1,0xc
    8000113e:	04aa                	sll	s1,s1,0xa
    80001140:	0164e4b3          	or	s1,s1,s6
    80001144:	0014e493          	or	s1,s1,1
    80001148:	e104                	sd	s1,0(a0)
    8000114a:	05390063          	beq	s2,s3,8000118a <mappages+0x9c>
    8000114e:	995e                	add	s2,s2,s7
    80001150:	bfc9                	j	80001122 <mappages+0x34>
    80001152:	00007517          	auipc	a0,0x7
    80001156:	f6650513          	add	a0,a0,-154 # 800080b8 <etext+0xb8>
    8000115a:	fffff097          	auipc	ra,0xfffff
    8000115e:	400080e7          	jalr	1024(ra) # 8000055a <panic>
    80001162:	00007517          	auipc	a0,0x7
    80001166:	f6650513          	add	a0,a0,-154 # 800080c8 <etext+0xc8>
    8000116a:	fffff097          	auipc	ra,0xfffff
    8000116e:	3f0080e7          	jalr	1008(ra) # 8000055a <panic>
    80001172:	557d                	li	a0,-1
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
    8000118a:	4501                	li	a0,0
    8000118c:	b7e5                	j	80001174 <mappages+0x86>

000000008000118e <kvmmap>:
    8000118e:	1141                	add	sp,sp,-16
    80001190:	e406                	sd	ra,8(sp)
    80001192:	e022                	sd	s0,0(sp)
    80001194:	0800                	add	s0,sp,16
    80001196:	87b6                	mv	a5,a3
    80001198:	86b2                	mv	a3,a2
    8000119a:	863e                	mv	a2,a5
    8000119c:	00000097          	auipc	ra,0x0
    800011a0:	f52080e7          	jalr	-174(ra) # 800010ee <mappages>
    800011a4:	e509                	bnez	a0,800011ae <kvmmap+0x20>
    800011a6:	60a2                	ld	ra,8(sp)
    800011a8:	6402                	ld	s0,0(sp)
    800011aa:	0141                	add	sp,sp,16
    800011ac:	8082                	ret
    800011ae:	00007517          	auipc	a0,0x7
    800011b2:	f2a50513          	add	a0,a0,-214 # 800080d8 <etext+0xd8>
    800011b6:	fffff097          	auipc	ra,0xfffff
    800011ba:	3a4080e7          	jalr	932(ra) # 8000055a <panic>

00000000800011be <kvmmake>:
    800011be:	1101                	add	sp,sp,-32
    800011c0:	ec06                	sd	ra,24(sp)
    800011c2:	e822                	sd	s0,16(sp)
    800011c4:	e426                	sd	s1,8(sp)
    800011c6:	e04a                	sd	s2,0(sp)
    800011c8:	1000                	add	s0,sp,32
    800011ca:	00000097          	auipc	ra,0x0
    800011ce:	978080e7          	jalr	-1672(ra) # 80000b42 <kalloc>
    800011d2:	84aa                	mv	s1,a0
    800011d4:	6605                	lui	a2,0x1
    800011d6:	4581                	li	a1,0
    800011d8:	00000097          	auipc	ra,0x0
    800011dc:	b56080e7          	jalr	-1194(ra) # 80000d2e <memset>
    800011e0:	4719                	li	a4,6
    800011e2:	6685                	lui	a3,0x1
    800011e4:	10000637          	lui	a2,0x10000
    800011e8:	100005b7          	lui	a1,0x10000
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	fa0080e7          	jalr	-96(ra) # 8000118e <kvmmap>
    800011f6:	4719                	li	a4,6
    800011f8:	6685                	lui	a3,0x1
    800011fa:	10001637          	lui	a2,0x10001
    800011fe:	100015b7          	lui	a1,0x10001
    80001202:	8526                	mv	a0,s1
    80001204:	00000097          	auipc	ra,0x0
    80001208:	f8a080e7          	jalr	-118(ra) # 8000118e <kvmmap>
    8000120c:	4719                	li	a4,6
    8000120e:	004006b7          	lui	a3,0x400
    80001212:	0c000637          	lui	a2,0xc000
    80001216:	0c0005b7          	lui	a1,0xc000
    8000121a:	8526                	mv	a0,s1
    8000121c:	00000097          	auipc	ra,0x0
    80001220:	f72080e7          	jalr	-142(ra) # 8000118e <kvmmap>
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
    80001246:	46c5                	li	a3,17
    80001248:	06ee                	sll	a3,a3,0x1b
    8000124a:	4719                	li	a4,6
    8000124c:	412686b3          	sub	a3,a3,s2
    80001250:	864a                	mv	a2,s2
    80001252:	85ca                	mv	a1,s2
    80001254:	8526                	mv	a0,s1
    80001256:	00000097          	auipc	ra,0x0
    8000125a:	f38080e7          	jalr	-200(ra) # 8000118e <kvmmap>
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
    8000127c:	8526                	mv	a0,s1
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	624080e7          	jalr	1572(ra) # 800018a2 <proc_mapstacks>
    80001286:	8526                	mv	a0,s1
    80001288:	60e2                	ld	ra,24(sp)
    8000128a:	6442                	ld	s0,16(sp)
    8000128c:	64a2                	ld	s1,8(sp)
    8000128e:	6902                	ld	s2,0(sp)
    80001290:	6105                	add	sp,sp,32
    80001292:	8082                	ret

0000000080001294 <kvminit>:
    80001294:	1141                	add	sp,sp,-16
    80001296:	e406                	sd	ra,8(sp)
    80001298:	e022                	sd	s0,0(sp)
    8000129a:	0800                	add	s0,sp,16
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	f22080e7          	jalr	-222(ra) # 800011be <kvmmake>
    800012a4:	00008797          	auipc	a5,0x8
    800012a8:	d6a7be23          	sd	a0,-644(a5) # 80009020 <kernel_pagetable>
    800012ac:	60a2                	ld	ra,8(sp)
    800012ae:	6402                	ld	s0,0(sp)
    800012b0:	0141                	add	sp,sp,16
    800012b2:	8082                	ret

00000000800012b4 <uvmunmap>:
    800012b4:	715d                	add	sp,sp,-80
    800012b6:	e486                	sd	ra,72(sp)
    800012b8:	e0a2                	sd	s0,64(sp)
    800012ba:	0880                	add	s0,sp,80
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
    800012d4:	0632                	sll	a2,a2,0xc
    800012d6:	00b609b3          	add	s3,a2,a1
    800012da:	4b85                	li	s7,1
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
    800012f4:	00007517          	auipc	a0,0x7
    800012f8:	dec50513          	add	a0,a0,-532 # 800080e0 <etext+0xe0>
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	25e080e7          	jalr	606(ra) # 8000055a <panic>
    80001304:	00007517          	auipc	a0,0x7
    80001308:	df450513          	add	a0,a0,-524 # 800080f8 <etext+0xf8>
    8000130c:	fffff097          	auipc	ra,0xfffff
    80001310:	24e080e7          	jalr	590(ra) # 8000055a <panic>
    80001314:	00007517          	auipc	a0,0x7
    80001318:	df450513          	add	a0,a0,-524 # 80008108 <etext+0x108>
    8000131c:	fffff097          	auipc	ra,0xfffff
    80001320:	23e080e7          	jalr	574(ra) # 8000055a <panic>
    80001324:	00007517          	auipc	a0,0x7
    80001328:	dfc50513          	add	a0,a0,-516 # 80008120 <etext+0x120>
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	22e080e7          	jalr	558(ra) # 8000055a <panic>
    80001334:	0004b023          	sd	zero,0(s1)
    80001338:	995a                	add	s2,s2,s6
    8000133a:	03397c63          	bgeu	s2,s3,80001372 <uvmunmap+0xbe>
    8000133e:	4601                	li	a2,0
    80001340:	85ca                	mv	a1,s2
    80001342:	8552                	mv	a0,s4
    80001344:	00000097          	auipc	ra,0x0
    80001348:	cc2080e7          	jalr	-830(ra) # 80001006 <walk>
    8000134c:	84aa                	mv	s1,a0
    8000134e:	d95d                	beqz	a0,80001304 <uvmunmap+0x50>
    80001350:	6108                	ld	a0,0(a0)
    80001352:	00157793          	and	a5,a0,1
    80001356:	dfdd                	beqz	a5,80001314 <uvmunmap+0x60>
    80001358:	3ff57793          	and	a5,a0,1023
    8000135c:	fd7784e3          	beq	a5,s7,80001324 <uvmunmap+0x70>
    80001360:	fc0a8ae3          	beqz	s5,80001334 <uvmunmap+0x80>
    80001364:	8129                	srl	a0,a0,0xa
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
    80001380:	60a6                	ld	ra,72(sp)
    80001382:	6406                	ld	s0,64(sp)
    80001384:	6161                	add	sp,sp,80
    80001386:	8082                	ret

0000000080001388 <uvmcreate>:
    80001388:	1101                	add	sp,sp,-32
    8000138a:	ec06                	sd	ra,24(sp)
    8000138c:	e822                	sd	s0,16(sp)
    8000138e:	e426                	sd	s1,8(sp)
    80001390:	1000                	add	s0,sp,32
    80001392:	fffff097          	auipc	ra,0xfffff
    80001396:	7b0080e7          	jalr	1968(ra) # 80000b42 <kalloc>
    8000139a:	84aa                	mv	s1,a0
    8000139c:	c519                	beqz	a0,800013aa <uvmcreate+0x22>
    8000139e:	6605                	lui	a2,0x1
    800013a0:	4581                	li	a1,0
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	98c080e7          	jalr	-1652(ra) # 80000d2e <memset>
    800013aa:	8526                	mv	a0,s1
    800013ac:	60e2                	ld	ra,24(sp)
    800013ae:	6442                	ld	s0,16(sp)
    800013b0:	64a2                	ld	s1,8(sp)
    800013b2:	6105                	add	sp,sp,32
    800013b4:	8082                	ret

00000000800013b6 <uvminit>:
    800013b6:	7179                	add	sp,sp,-48
    800013b8:	f406                	sd	ra,40(sp)
    800013ba:	f022                	sd	s0,32(sp)
    800013bc:	ec26                	sd	s1,24(sp)
    800013be:	e84a                	sd	s2,16(sp)
    800013c0:	e44e                	sd	s3,8(sp)
    800013c2:	e052                	sd	s4,0(sp)
    800013c4:	1800                	add	s0,sp,48
    800013c6:	6785                	lui	a5,0x1
    800013c8:	04f67863          	bgeu	a2,a5,80001418 <uvminit+0x62>
    800013cc:	8a2a                	mv	s4,a0
    800013ce:	89ae                	mv	s3,a1
    800013d0:	84b2                	mv	s1,a2
    800013d2:	fffff097          	auipc	ra,0xfffff
    800013d6:	770080e7          	jalr	1904(ra) # 80000b42 <kalloc>
    800013da:	892a                	mv	s2,a0
    800013dc:	6605                	lui	a2,0x1
    800013de:	4581                	li	a1,0
    800013e0:	00000097          	auipc	ra,0x0
    800013e4:	94e080e7          	jalr	-1714(ra) # 80000d2e <memset>
    800013e8:	4779                	li	a4,30
    800013ea:	86ca                	mv	a3,s2
    800013ec:	6605                	lui	a2,0x1
    800013ee:	4581                	li	a1,0
    800013f0:	8552                	mv	a0,s4
    800013f2:	00000097          	auipc	ra,0x0
    800013f6:	cfc080e7          	jalr	-772(ra) # 800010ee <mappages>
    800013fa:	8626                	mv	a2,s1
    800013fc:	85ce                	mv	a1,s3
    800013fe:	854a                	mv	a0,s2
    80001400:	00000097          	auipc	ra,0x0
    80001404:	98a080e7          	jalr	-1654(ra) # 80000d8a <memmove>
    80001408:	70a2                	ld	ra,40(sp)
    8000140a:	7402                	ld	s0,32(sp)
    8000140c:	64e2                	ld	s1,24(sp)
    8000140e:	6942                	ld	s2,16(sp)
    80001410:	69a2                	ld	s3,8(sp)
    80001412:	6a02                	ld	s4,0(sp)
    80001414:	6145                	add	sp,sp,48
    80001416:	8082                	ret
    80001418:	00007517          	auipc	a0,0x7
    8000141c:	d2050513          	add	a0,a0,-736 # 80008138 <etext+0x138>
    80001420:	fffff097          	auipc	ra,0xfffff
    80001424:	13a080e7          	jalr	314(ra) # 8000055a <panic>

0000000080001428 <uvmdealloc>:
    80001428:	1101                	add	sp,sp,-32
    8000142a:	ec06                	sd	ra,24(sp)
    8000142c:	e822                	sd	s0,16(sp)
    8000142e:	e426                	sd	s1,8(sp)
    80001430:	1000                	add	s0,sp,32
    80001432:	84ae                	mv	s1,a1
    80001434:	00b67d63          	bgeu	a2,a1,8000144e <uvmdealloc+0x26>
    80001438:	84b2                	mv	s1,a2
    8000143a:	6785                	lui	a5,0x1
    8000143c:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000143e:	00f60733          	add	a4,a2,a5
    80001442:	76fd                	lui	a3,0xfffff
    80001444:	8f75                	and	a4,a4,a3
    80001446:	97ae                	add	a5,a5,a1
    80001448:	8ff5                	and	a5,a5,a3
    8000144a:	00f76863          	bltu	a4,a5,8000145a <uvmdealloc+0x32>
    8000144e:	8526                	mv	a0,s1
    80001450:	60e2                	ld	ra,24(sp)
    80001452:	6442                	ld	s0,16(sp)
    80001454:	64a2                	ld	s1,8(sp)
    80001456:	6105                	add	sp,sp,32
    80001458:	8082                	ret
    8000145a:	8f99                	sub	a5,a5,a4
    8000145c:	83b1                	srl	a5,a5,0xc
    8000145e:	4685                	li	a3,1
    80001460:	0007861b          	sext.w	a2,a5
    80001464:	85ba                	mv	a1,a4
    80001466:	00000097          	auipc	ra,0x0
    8000146a:	e4e080e7          	jalr	-434(ra) # 800012b4 <uvmunmap>
    8000146e:	b7c5                	j	8000144e <uvmdealloc+0x26>

0000000080001470 <uvmalloc>:
    80001470:	0ab66563          	bltu	a2,a1,8000151a <uvmalloc+0xaa>
    80001474:	7139                	add	sp,sp,-64
    80001476:	fc06                	sd	ra,56(sp)
    80001478:	f822                	sd	s0,48(sp)
    8000147a:	ec4e                	sd	s3,24(sp)
    8000147c:	e852                	sd	s4,16(sp)
    8000147e:	e456                	sd	s5,8(sp)
    80001480:	0080                	add	s0,sp,64
    80001482:	8aaa                	mv	s5,a0
    80001484:	8a32                	mv	s4,a2
    80001486:	6785                	lui	a5,0x1
    80001488:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000148a:	95be                	add	a1,a1,a5
    8000148c:	77fd                	lui	a5,0xfffff
    8000148e:	00f5f9b3          	and	s3,a1,a5
    80001492:	08c9f663          	bgeu	s3,a2,8000151e <uvmalloc+0xae>
    80001496:	f426                	sd	s1,40(sp)
    80001498:	f04a                	sd	s2,32(sp)
    8000149a:	894e                	mv	s2,s3
    8000149c:	fffff097          	auipc	ra,0xfffff
    800014a0:	6a6080e7          	jalr	1702(ra) # 80000b42 <kalloc>
    800014a4:	84aa                	mv	s1,a0
    800014a6:	c90d                	beqz	a0,800014d8 <uvmalloc+0x68>
    800014a8:	6605                	lui	a2,0x1
    800014aa:	4581                	li	a1,0
    800014ac:	00000097          	auipc	ra,0x0
    800014b0:	882080e7          	jalr	-1918(ra) # 80000d2e <memset>
    800014b4:	4779                	li	a4,30
    800014b6:	86a6                	mv	a3,s1
    800014b8:	6605                	lui	a2,0x1
    800014ba:	85ca                	mv	a1,s2
    800014bc:	8556                	mv	a0,s5
    800014be:	00000097          	auipc	ra,0x0
    800014c2:	c30080e7          	jalr	-976(ra) # 800010ee <mappages>
    800014c6:	e915                	bnez	a0,800014fa <uvmalloc+0x8a>
    800014c8:	6785                	lui	a5,0x1
    800014ca:	993e                	add	s2,s2,a5
    800014cc:	fd4968e3          	bltu	s2,s4,8000149c <uvmalloc+0x2c>
    800014d0:	8552                	mv	a0,s4
    800014d2:	74a2                	ld	s1,40(sp)
    800014d4:	7902                	ld	s2,32(sp)
    800014d6:	a819                	j	800014ec <uvmalloc+0x7c>
    800014d8:	864e                	mv	a2,s3
    800014da:	85ca                	mv	a1,s2
    800014dc:	8556                	mv	a0,s5
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	f4a080e7          	jalr	-182(ra) # 80001428 <uvmdealloc>
    800014e6:	4501                	li	a0,0
    800014e8:	74a2                	ld	s1,40(sp)
    800014ea:	7902                	ld	s2,32(sp)
    800014ec:	70e2                	ld	ra,56(sp)
    800014ee:	7442                	ld	s0,48(sp)
    800014f0:	69e2                	ld	s3,24(sp)
    800014f2:	6a42                	ld	s4,16(sp)
    800014f4:	6aa2                	ld	s5,8(sp)
    800014f6:	6121                	add	sp,sp,64
    800014f8:	8082                	ret
    800014fa:	8526                	mv	a0,s1
    800014fc:	fffff097          	auipc	ra,0xfffff
    80001500:	548080e7          	jalr	1352(ra) # 80000a44 <kfree>
    80001504:	864e                	mv	a2,s3
    80001506:	85ca                	mv	a1,s2
    80001508:	8556                	mv	a0,s5
    8000150a:	00000097          	auipc	ra,0x0
    8000150e:	f1e080e7          	jalr	-226(ra) # 80001428 <uvmdealloc>
    80001512:	4501                	li	a0,0
    80001514:	74a2                	ld	s1,40(sp)
    80001516:	7902                	ld	s2,32(sp)
    80001518:	bfd1                	j	800014ec <uvmalloc+0x7c>
    8000151a:	852e                	mv	a0,a1
    8000151c:	8082                	ret
    8000151e:	8532                	mv	a0,a2
    80001520:	b7f1                	j	800014ec <uvmalloc+0x7c>

0000000080001522 <freewalk>:
    80001522:	7179                	add	sp,sp,-48
    80001524:	f406                	sd	ra,40(sp)
    80001526:	f022                	sd	s0,32(sp)
    80001528:	ec26                	sd	s1,24(sp)
    8000152a:	e84a                	sd	s2,16(sp)
    8000152c:	e44e                	sd	s3,8(sp)
    8000152e:	e052                	sd	s4,0(sp)
    80001530:	1800                	add	s0,sp,48
    80001532:	8a2a                	mv	s4,a0
    80001534:	84aa                	mv	s1,a0
    80001536:	6905                	lui	s2,0x1
    80001538:	992a                	add	s2,s2,a0
    8000153a:	4985                	li	s3,1
    8000153c:	a829                	j	80001556 <freewalk+0x34>
    8000153e:	83a9                	srl	a5,a5,0xa
    80001540:	00c79513          	sll	a0,a5,0xc
    80001544:	00000097          	auipc	ra,0x0
    80001548:	fde080e7          	jalr	-34(ra) # 80001522 <freewalk>
    8000154c:	0004b023          	sd	zero,0(s1)
    80001550:	04a1                	add	s1,s1,8
    80001552:	03248163          	beq	s1,s2,80001574 <freewalk+0x52>
    80001556:	609c                	ld	a5,0(s1)
    80001558:	00f7f713          	and	a4,a5,15
    8000155c:	ff3701e3          	beq	a4,s3,8000153e <freewalk+0x1c>
    80001560:	8b85                	and	a5,a5,1
    80001562:	d7fd                	beqz	a5,80001550 <freewalk+0x2e>
    80001564:	00007517          	auipc	a0,0x7
    80001568:	bf450513          	add	a0,a0,-1036 # 80008158 <etext+0x158>
    8000156c:	fffff097          	auipc	ra,0xfffff
    80001570:	fee080e7          	jalr	-18(ra) # 8000055a <panic>
    80001574:	8552                	mv	a0,s4
    80001576:	fffff097          	auipc	ra,0xfffff
    8000157a:	4ce080e7          	jalr	1230(ra) # 80000a44 <kfree>
    8000157e:	70a2                	ld	ra,40(sp)
    80001580:	7402                	ld	s0,32(sp)
    80001582:	64e2                	ld	s1,24(sp)
    80001584:	6942                	ld	s2,16(sp)
    80001586:	69a2                	ld	s3,8(sp)
    80001588:	6a02                	ld	s4,0(sp)
    8000158a:	6145                	add	sp,sp,48
    8000158c:	8082                	ret

000000008000158e <uvmfree>:
    8000158e:	1101                	add	sp,sp,-32
    80001590:	ec06                	sd	ra,24(sp)
    80001592:	e822                	sd	s0,16(sp)
    80001594:	e426                	sd	s1,8(sp)
    80001596:	1000                	add	s0,sp,32
    80001598:	84aa                	mv	s1,a0
    8000159a:	e999                	bnez	a1,800015b0 <uvmfree+0x22>
    8000159c:	8526                	mv	a0,s1
    8000159e:	00000097          	auipc	ra,0x0
    800015a2:	f84080e7          	jalr	-124(ra) # 80001522 <freewalk>
    800015a6:	60e2                	ld	ra,24(sp)
    800015a8:	6442                	ld	s0,16(sp)
    800015aa:	64a2                	ld	s1,8(sp)
    800015ac:	6105                	add	sp,sp,32
    800015ae:	8082                	ret
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
    800015c8:	c679                	beqz	a2,80001696 <uvmcopy+0xce>
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
    800015e6:	4981                	li	s3,0
    800015e8:	4601                	li	a2,0
    800015ea:	85ce                	mv	a1,s3
    800015ec:	855a                	mv	a0,s6
    800015ee:	00000097          	auipc	ra,0x0
    800015f2:	a18080e7          	jalr	-1512(ra) # 80001006 <walk>
    800015f6:	c531                	beqz	a0,80001642 <uvmcopy+0x7a>
    800015f8:	6118                	ld	a4,0(a0)
    800015fa:	00177793          	and	a5,a4,1
    800015fe:	cbb1                	beqz	a5,80001652 <uvmcopy+0x8a>
    80001600:	00a75593          	srl	a1,a4,0xa
    80001604:	00c59b93          	sll	s7,a1,0xc
    80001608:	3ff77493          	and	s1,a4,1023
    8000160c:	fffff097          	auipc	ra,0xfffff
    80001610:	536080e7          	jalr	1334(ra) # 80000b42 <kalloc>
    80001614:	892a                	mv	s2,a0
    80001616:	c939                	beqz	a0,8000166c <uvmcopy+0xa4>
    80001618:	6605                	lui	a2,0x1
    8000161a:	85de                	mv	a1,s7
    8000161c:	fffff097          	auipc	ra,0xfffff
    80001620:	76e080e7          	jalr	1902(ra) # 80000d8a <memmove>
    80001624:	8726                	mv	a4,s1
    80001626:	86ca                	mv	a3,s2
    80001628:	6605                	lui	a2,0x1
    8000162a:	85ce                	mv	a1,s3
    8000162c:	8556                	mv	a0,s5
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	ac0080e7          	jalr	-1344(ra) # 800010ee <mappages>
    80001636:	e515                	bnez	a0,80001662 <uvmcopy+0x9a>
    80001638:	6785                	lui	a5,0x1
    8000163a:	99be                	add	s3,s3,a5
    8000163c:	fb49e6e3          	bltu	s3,s4,800015e8 <uvmcopy+0x20>
    80001640:	a081                	j	80001680 <uvmcopy+0xb8>
    80001642:	00007517          	auipc	a0,0x7
    80001646:	b2650513          	add	a0,a0,-1242 # 80008168 <etext+0x168>
    8000164a:	fffff097          	auipc	ra,0xfffff
    8000164e:	f10080e7          	jalr	-240(ra) # 8000055a <panic>
    80001652:	00007517          	auipc	a0,0x7
    80001656:	b3650513          	add	a0,a0,-1226 # 80008188 <etext+0x188>
    8000165a:	fffff097          	auipc	ra,0xfffff
    8000165e:	f00080e7          	jalr	-256(ra) # 8000055a <panic>
    80001662:	854a                	mv	a0,s2
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	3e0080e7          	jalr	992(ra) # 80000a44 <kfree>
    8000166c:	4685                	li	a3,1
    8000166e:	00c9d613          	srl	a2,s3,0xc
    80001672:	4581                	li	a1,0
    80001674:	8556                	mv	a0,s5
    80001676:	00000097          	auipc	ra,0x0
    8000167a:	c3e080e7          	jalr	-962(ra) # 800012b4 <uvmunmap>
    8000167e:	557d                	li	a0,-1
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
    80001696:	4501                	li	a0,0
    80001698:	8082                	ret

000000008000169a <uvmclear>:
    8000169a:	1141                	add	sp,sp,-16
    8000169c:	e406                	sd	ra,8(sp)
    8000169e:	e022                	sd	s0,0(sp)
    800016a0:	0800                	add	s0,sp,16
    800016a2:	4601                	li	a2,0
    800016a4:	00000097          	auipc	ra,0x0
    800016a8:	962080e7          	jalr	-1694(ra) # 80001006 <walk>
    800016ac:	c901                	beqz	a0,800016bc <uvmclear+0x22>
    800016ae:	611c                	ld	a5,0(a0)
    800016b0:	9bbd                	and	a5,a5,-17
    800016b2:	e11c                	sd	a5,0(a0)
    800016b4:	60a2                	ld	ra,8(sp)
    800016b6:	6402                	ld	s0,0(sp)
    800016b8:	0141                	add	sp,sp,16
    800016ba:	8082                	ret
    800016bc:	00007517          	auipc	a0,0x7
    800016c0:	aec50513          	add	a0,a0,-1300 # 800081a8 <etext+0x1a8>
    800016c4:	fffff097          	auipc	ra,0xfffff
    800016c8:	e96080e7          	jalr	-362(ra) # 8000055a <panic>

00000000800016cc <copyout>:
    800016cc:	c6bd                	beqz	a3,8000173a <copyout+0x6e>
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
    800016ee:	7bfd                	lui	s7,0xfffff
    800016f0:	6a85                	lui	s5,0x1
    800016f2:	a015                	j	80001716 <copyout+0x4a>
    800016f4:	9562                	add	a0,a0,s8
    800016f6:	0004861b          	sext.w	a2,s1
    800016fa:	85d2                	mv	a1,s4
    800016fc:	41250533          	sub	a0,a0,s2
    80001700:	fffff097          	auipc	ra,0xfffff
    80001704:	68a080e7          	jalr	1674(ra) # 80000d8a <memmove>
    80001708:	409989b3          	sub	s3,s3,s1
    8000170c:	9a26                	add	s4,s4,s1
    8000170e:	01590c33          	add	s8,s2,s5
    80001712:	02098263          	beqz	s3,80001736 <copyout+0x6a>
    80001716:	017c7933          	and	s2,s8,s7
    8000171a:	85ca                	mv	a1,s2
    8000171c:	855a                	mv	a0,s6
    8000171e:	00000097          	auipc	ra,0x0
    80001722:	98e080e7          	jalr	-1650(ra) # 800010ac <walkaddr>
    80001726:	cd01                	beqz	a0,8000173e <copyout+0x72>
    80001728:	418904b3          	sub	s1,s2,s8
    8000172c:	94d6                	add	s1,s1,s5
    8000172e:	fc99f3e3          	bgeu	s3,s1,800016f4 <copyout+0x28>
    80001732:	84ce                	mv	s1,s3
    80001734:	b7c1                	j	800016f4 <copyout+0x28>
    80001736:	4501                	li	a0,0
    80001738:	a021                	j	80001740 <copyout+0x74>
    8000173a:	4501                	li	a0,0
    8000173c:	8082                	ret
    8000173e:	557d                	li	a0,-1
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
    80001758:	caa5                	beqz	a3,800017c8 <copyin+0x70>
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
    8000177a:	7bfd                	lui	s7,0xfffff
    8000177c:	6a85                	lui	s5,0x1
    8000177e:	a01d                	j	800017a4 <copyin+0x4c>
    80001780:	018505b3          	add	a1,a0,s8
    80001784:	0004861b          	sext.w	a2,s1
    80001788:	412585b3          	sub	a1,a1,s2
    8000178c:	8552                	mv	a0,s4
    8000178e:	fffff097          	auipc	ra,0xfffff
    80001792:	5fc080e7          	jalr	1532(ra) # 80000d8a <memmove>
    80001796:	409989b3          	sub	s3,s3,s1
    8000179a:	9a26                	add	s4,s4,s1
    8000179c:	01590c33          	add	s8,s2,s5
    800017a0:	02098263          	beqz	s3,800017c4 <copyin+0x6c>
    800017a4:	017c7933          	and	s2,s8,s7
    800017a8:	85ca                	mv	a1,s2
    800017aa:	855a                	mv	a0,s6
    800017ac:	00000097          	auipc	ra,0x0
    800017b0:	900080e7          	jalr	-1792(ra) # 800010ac <walkaddr>
    800017b4:	cd01                	beqz	a0,800017cc <copyin+0x74>
    800017b6:	418904b3          	sub	s1,s2,s8
    800017ba:	94d6                	add	s1,s1,s5
    800017bc:	fc99f2e3          	bgeu	s3,s1,80001780 <copyin+0x28>
    800017c0:	84ce                	mv	s1,s3
    800017c2:	bf7d                	j	80001780 <copyin+0x28>
    800017c4:	4501                	li	a0,0
    800017c6:	a021                	j	800017ce <copyin+0x76>
    800017c8:	4501                	li	a0,0
    800017ca:	8082                	ret
    800017cc:	557d                	li	a0,-1
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
    800017e6:	cacd                	beqz	a3,80001898 <copyinstr+0xb2>
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
    80001806:	7afd                	lui	s5,0xfffff
    80001808:	6985                	lui	s3,0x1
    8000180a:	a825                	j	80001842 <copyinstr+0x5c>
    8000180c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001810:	4785                	li	a5,1
    80001812:	37fd                	addw	a5,a5,-1
    80001814:	0007851b          	sext.w	a0,a5
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
    80001834:	40b70933          	sub	s2,a4,a1
    80001838:	01348bb3          	add	s7,s1,s3
    8000183c:	04e58663          	beq	a1,a4,80001888 <copyinstr+0xa2>
    80001840:	8b3e                	mv	s6,a5
    80001842:	015bf4b3          	and	s1,s7,s5
    80001846:	85a6                	mv	a1,s1
    80001848:	8552                	mv	a0,s4
    8000184a:	00000097          	auipc	ra,0x0
    8000184e:	862080e7          	jalr	-1950(ra) # 800010ac <walkaddr>
    80001852:	cd0d                	beqz	a0,8000188c <copyinstr+0xa6>
    80001854:	417486b3          	sub	a3,s1,s7
    80001858:	96ce                	add	a3,a3,s3
    8000185a:	00d97363          	bgeu	s2,a3,80001860 <copyinstr+0x7a>
    8000185e:	86ca                	mv	a3,s2
    80001860:	955e                	add	a0,a0,s7
    80001862:	8d05                	sub	a0,a0,s1
    80001864:	c695                	beqz	a3,80001890 <copyinstr+0xaa>
    80001866:	87da                	mv	a5,s6
    80001868:	885a                	mv	a6,s6
    8000186a:	41650633          	sub	a2,a0,s6
    8000186e:	96da                	add	a3,a3,s6
    80001870:	85be                	mv	a1,a5
    80001872:	00f60733          	add	a4,a2,a5
    80001876:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    8000187a:	db49                	beqz	a4,8000180c <copyinstr+0x26>
    8000187c:	00e78023          	sb	a4,0(a5)
    80001880:	0785                	add	a5,a5,1
    80001882:	fed797e3          	bne	a5,a3,80001870 <copyinstr+0x8a>
    80001886:	b765                	j	8000182e <copyinstr+0x48>
    80001888:	4781                	li	a5,0
    8000188a:	b761                	j	80001812 <copyinstr+0x2c>
    8000188c:	557d                	li	a0,-1
    8000188e:	b769                	j	80001818 <copyinstr+0x32>
    80001890:	6b85                	lui	s7,0x1
    80001892:	9ba6                	add	s7,s7,s1
    80001894:	87da                	mv	a5,s6
    80001896:	b76d                	j	80001840 <copyinstr+0x5a>
    80001898:	4781                	li	a5,0
    8000189a:	37fd                	addw	a5,a5,-1
    8000189c:	0007851b          	sext.w	a0,a5
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
    800018c2:	fafb0937          	lui	s2,0xfafb0
    800018c6:	afb90913          	add	s2,s2,-1285 # fffffffffafafafb <end+0xffffffff7af89afb>
    800018ca:	0942                	sll	s2,s2,0x10
    800018cc:	afb90913          	add	s2,s2,-1285
    800018d0:	0942                	sll	s2,s2,0x10
    800018d2:	afb90913          	add	s2,s2,-1285
    800018d6:	040009b7          	lui	s3,0x4000
    800018da:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018dc:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018de:	00016a97          	auipc	s5,0x16
    800018e2:	3f2a8a93          	add	s5,s5,1010 # 80017cd0 <tickslock>
    char *pa = kalloc();
    800018e6:	fffff097          	auipc	ra,0xfffff
    800018ea:	25c080e7          	jalr	604(ra) # 80000b42 <kalloc>
    800018ee:	862a                	mv	a2,a0
    if(pa == 0)
    800018f0:	c121                	beqz	a0,80001930 <proc_mapstacks+0x8e>
    uint64 va = KSTACK((int) (p - proc));
    800018f2:	416485b3          	sub	a1,s1,s6
    800018f6:	858d                	sra	a1,a1,0x3
    800018f8:	032585b3          	mul	a1,a1,s2
    800018fc:	2585                	addw	a1,a1,1
    800018fe:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001902:	4719                	li	a4,6
    80001904:	6685                	lui	a3,0x1
    80001906:	40b985b3          	sub	a1,s3,a1
    8000190a:	8552                	mv	a0,s4
    8000190c:	00000097          	auipc	ra,0x0
    80001910:	882080e7          	jalr	-1918(ra) # 8000118e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001914:	19848493          	add	s1,s1,408
    80001918:	fd5497e3          	bne	s1,s5,800018e6 <proc_mapstacks+0x44>
  }
}
    8000191c:	70e2                	ld	ra,56(sp)
    8000191e:	7442                	ld	s0,48(sp)
    80001920:	74a2                	ld	s1,40(sp)
    80001922:	7902                	ld	s2,32(sp)
    80001924:	69e2                	ld	s3,24(sp)
    80001926:	6a42                	ld	s4,16(sp)
    80001928:	6aa2                	ld	s5,8(sp)
    8000192a:	6b02                	ld	s6,0(sp)
    8000192c:	6121                	add	sp,sp,64
    8000192e:	8082                	ret
      panic("kalloc");
    80001930:	00007517          	auipc	a0,0x7
    80001934:	88850513          	add	a0,a0,-1912 # 800081b8 <etext+0x1b8>
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	c22080e7          	jalr	-990(ra) # 8000055a <panic>

0000000080001940 <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001940:	7139                	add	sp,sp,-64
    80001942:	fc06                	sd	ra,56(sp)
    80001944:	f822                	sd	s0,48(sp)
    80001946:	f426                	sd	s1,40(sp)
    80001948:	f04a                	sd	s2,32(sp)
    8000194a:	ec4e                	sd	s3,24(sp)
    8000194c:	e852                	sd	s4,16(sp)
    8000194e:	e456                	sd	s5,8(sp)
    80001950:	e05a                	sd	s6,0(sp)
    80001952:	0080                	add	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001954:	00007597          	auipc	a1,0x7
    80001958:	86c58593          	add	a1,a1,-1940 # 800081c0 <etext+0x1c0>
    8000195c:	00010517          	auipc	a0,0x10
    80001960:	94450513          	add	a0,a0,-1724 # 800112a0 <pid_lock>
    80001964:	fffff097          	auipc	ra,0xfffff
    80001968:	23e080e7          	jalr	574(ra) # 80000ba2 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000196c:	00007597          	auipc	a1,0x7
    80001970:	85c58593          	add	a1,a1,-1956 # 800081c8 <etext+0x1c8>
    80001974:	00010517          	auipc	a0,0x10
    80001978:	94450513          	add	a0,a0,-1724 # 800112b8 <wait_lock>
    8000197c:	fffff097          	auipc	ra,0xfffff
    80001980:	226080e7          	jalr	550(ra) # 80000ba2 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001984:	00010497          	auipc	s1,0x10
    80001988:	d4c48493          	add	s1,s1,-692 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    8000198c:	00007b17          	auipc	s6,0x7
    80001990:	84cb0b13          	add	s6,s6,-1972 # 800081d8 <etext+0x1d8>
      p->kstack = KSTACK((int) (p - proc));
    80001994:	8aa6                	mv	s5,s1
    80001996:	fafb0937          	lui	s2,0xfafb0
    8000199a:	afb90913          	add	s2,s2,-1285 # fffffffffafafafb <end+0xffffffff7af89afb>
    8000199e:	0942                	sll	s2,s2,0x10
    800019a0:	afb90913          	add	s2,s2,-1285
    800019a4:	0942                	sll	s2,s2,0x10
    800019a6:	afb90913          	add	s2,s2,-1285
    800019aa:	040009b7          	lui	s3,0x4000
    800019ae:	19fd                	add	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800019b0:	09b2                	sll	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b2:	00016a17          	auipc	s4,0x16
    800019b6:	31ea0a13          	add	s4,s4,798 # 80017cd0 <tickslock>
      initlock(&p->lock, "proc");
    800019ba:	85da                	mv	a1,s6
    800019bc:	8526                	mv	a0,s1
    800019be:	fffff097          	auipc	ra,0xfffff
    800019c2:	1e4080e7          	jalr	484(ra) # 80000ba2 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    800019c6:	415487b3          	sub	a5,s1,s5
    800019ca:	878d                	sra	a5,a5,0x3
    800019cc:	032787b3          	mul	a5,a5,s2
    800019d0:	2785                	addw	a5,a5,1
    800019d2:	00d7979b          	sllw	a5,a5,0xd
    800019d6:	40f987b3          	sub	a5,s3,a5
    800019da:	f8bc                	sd	a5,112(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019dc:	19848493          	add	s1,s1,408
    800019e0:	fd449de3          	bne	s1,s4,800019ba <procinit+0x7a>
  }
}
    800019e4:	70e2                	ld	ra,56(sp)
    800019e6:	7442                	ld	s0,48(sp)
    800019e8:	74a2                	ld	s1,40(sp)
    800019ea:	7902                	ld	s2,32(sp)
    800019ec:	69e2                	ld	s3,24(sp)
    800019ee:	6a42                	ld	s4,16(sp)
    800019f0:	6aa2                	ld	s5,8(sp)
    800019f2:	6b02                	ld	s6,0(sp)
    800019f4:	6121                	add	sp,sp,64
    800019f6:	8082                	ret

00000000800019f8 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019f8:	1141                	add	sp,sp,-16
    800019fa:	e422                	sd	s0,8(sp)
    800019fc:	0800                	add	s0,sp,16
// this core's hartid (core number), the index into cpus[].
static inline uint64
r_tp()
{
  uint64 x;
  asm volatile("mv %0, tp" : "=r" (x) );
    800019fe:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a00:	2501                	sext.w	a0,a0
    80001a02:	6422                	ld	s0,8(sp)
    80001a04:	0141                	add	sp,sp,16
    80001a06:	8082                	ret

0000000080001a08 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001a08:	1141                	add	sp,sp,-16
    80001a0a:	e422                	sd	s0,8(sp)
    80001a0c:	0800                	add	s0,sp,16
    80001a0e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a10:	2781                	sext.w	a5,a5
    80001a12:	079e                	sll	a5,a5,0x7
  return c;
}
    80001a14:	00010517          	auipc	a0,0x10
    80001a18:	8bc50513          	add	a0,a0,-1860 # 800112d0 <cpus>
    80001a1c:	953e                	add	a0,a0,a5
    80001a1e:	6422                	ld	s0,8(sp)
    80001a20:	0141                	add	sp,sp,16
    80001a22:	8082                	ret

0000000080001a24 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001a24:	1101                	add	sp,sp,-32
    80001a26:	ec06                	sd	ra,24(sp)
    80001a28:	e822                	sd	s0,16(sp)
    80001a2a:	e426                	sd	s1,8(sp)
    80001a2c:	1000                	add	s0,sp,32
  push_off();
    80001a2e:	fffff097          	auipc	ra,0xfffff
    80001a32:	1b8080e7          	jalr	440(ra) # 80000be6 <push_off>
    80001a36:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a38:	2781                	sext.w	a5,a5
    80001a3a:	079e                	sll	a5,a5,0x7
    80001a3c:	00010717          	auipc	a4,0x10
    80001a40:	86470713          	add	a4,a4,-1948 # 800112a0 <pid_lock>
    80001a44:	97ba                	add	a5,a5,a4
    80001a46:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a48:	fffff097          	auipc	ra,0xfffff
    80001a4c:	23e080e7          	jalr	574(ra) # 80000c86 <pop_off>
  return p;
}
    80001a50:	8526                	mv	a0,s1
    80001a52:	60e2                	ld	ra,24(sp)
    80001a54:	6442                	ld	s0,16(sp)
    80001a56:	64a2                	ld	s1,8(sp)
    80001a58:	6105                	add	sp,sp,32
    80001a5a:	8082                	ret

0000000080001a5c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a5c:	1141                	add	sp,sp,-16
    80001a5e:	e406                	sd	ra,8(sp)
    80001a60:	e022                	sd	s0,0(sp)
    80001a62:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a64:	00000097          	auipc	ra,0x0
    80001a68:	fc0080e7          	jalr	-64(ra) # 80001a24 <myproc>
    80001a6c:	fffff097          	auipc	ra,0xfffff
    80001a70:	27a080e7          	jalr	634(ra) # 80000ce6 <release>

  if (first) {
    80001a74:	00007797          	auipc	a5,0x7
    80001a78:	dac7a783          	lw	a5,-596(a5) # 80008820 <first.1>
    80001a7c:	eb89                	bnez	a5,80001a8e <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a7e:	00001097          	auipc	ra,0x1
    80001a82:	dea080e7          	jalr	-534(ra) # 80002868 <usertrapret>
}
    80001a86:	60a2                	ld	ra,8(sp)
    80001a88:	6402                	ld	s0,0(sp)
    80001a8a:	0141                	add	sp,sp,16
    80001a8c:	8082                	ret
    first = 0;
    80001a8e:	00007797          	auipc	a5,0x7
    80001a92:	d807a923          	sw	zero,-622(a5) # 80008820 <first.1>
    fsinit(ROOTDEV);
    80001a96:	4505                	li	a0,1
    80001a98:	00002097          	auipc	ra,0x2
    80001a9c:	d3a080e7          	jalr	-710(ra) # 800037d2 <fsinit>
    80001aa0:	bff9                	j	80001a7e <forkret+0x22>

0000000080001aa2 <allocpid>:
allocpid() {
    80001aa2:	1101                	add	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001aae:	0000f917          	auipc	s2,0xf
    80001ab2:	7f290913          	add	s2,s2,2034 # 800112a0 <pid_lock>
    80001ab6:	854a                	mv	a0,s2
    80001ab8:	fffff097          	auipc	ra,0xfffff
    80001abc:	17a080e7          	jalr	378(ra) # 80000c32 <acquire>
  pid = nextpid;
    80001ac0:	00007797          	auipc	a5,0x7
    80001ac4:	d6478793          	add	a5,a5,-668 # 80008824 <nextpid>
    80001ac8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001aca:	0014871b          	addw	a4,s1,1
    80001ace:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ad0:	854a                	mv	a0,s2
    80001ad2:	fffff097          	auipc	ra,0xfffff
    80001ad6:	214080e7          	jalr	532(ra) # 80000ce6 <release>
}
    80001ada:	8526                	mv	a0,s1
    80001adc:	60e2                	ld	ra,24(sp)
    80001ade:	6442                	ld	s0,16(sp)
    80001ae0:	64a2                	ld	s1,8(sp)
    80001ae2:	6902                	ld	s2,0(sp)
    80001ae4:	6105                	add	sp,sp,32
    80001ae6:	8082                	ret

0000000080001ae8 <proc_pagetable>:
{
    80001ae8:	1101                	add	sp,sp,-32
    80001aea:	ec06                	sd	ra,24(sp)
    80001aec:	e822                	sd	s0,16(sp)
    80001aee:	e426                	sd	s1,8(sp)
    80001af0:	e04a                	sd	s2,0(sp)
    80001af2:	1000                	add	s0,sp,32
    80001af4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001af6:	00000097          	auipc	ra,0x0
    80001afa:	892080e7          	jalr	-1902(ra) # 80001388 <uvmcreate>
    80001afe:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b00:	c121                	beqz	a0,80001b40 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b02:	4729                	li	a4,10
    80001b04:	00005697          	auipc	a3,0x5
    80001b08:	4fc68693          	add	a3,a3,1276 # 80007000 <_trampoline>
    80001b0c:	6605                	lui	a2,0x1
    80001b0e:	040005b7          	lui	a1,0x4000
    80001b12:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b14:	05b2                	sll	a1,a1,0xc
    80001b16:	fffff097          	auipc	ra,0xfffff
    80001b1a:	5d8080e7          	jalr	1496(ra) # 800010ee <mappages>
    80001b1e:	02054863          	bltz	a0,80001b4e <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b22:	4719                	li	a4,6
    80001b24:	08893683          	ld	a3,136(s2)
    80001b28:	6605                	lui	a2,0x1
    80001b2a:	020005b7          	lui	a1,0x2000
    80001b2e:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b30:	05b6                	sll	a1,a1,0xd
    80001b32:	8526                	mv	a0,s1
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	5ba080e7          	jalr	1466(ra) # 800010ee <mappages>
    80001b3c:	02054163          	bltz	a0,80001b5e <proc_pagetable+0x76>
}
    80001b40:	8526                	mv	a0,s1
    80001b42:	60e2                	ld	ra,24(sp)
    80001b44:	6442                	ld	s0,16(sp)
    80001b46:	64a2                	ld	s1,8(sp)
    80001b48:	6902                	ld	s2,0(sp)
    80001b4a:	6105                	add	sp,sp,32
    80001b4c:	8082                	ret
    uvmfree(pagetable, 0);
    80001b4e:	4581                	li	a1,0
    80001b50:	8526                	mv	a0,s1
    80001b52:	00000097          	auipc	ra,0x0
    80001b56:	a3c080e7          	jalr	-1476(ra) # 8000158e <uvmfree>
    return 0;
    80001b5a:	4481                	li	s1,0
    80001b5c:	b7d5                	j	80001b40 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b5e:	4681                	li	a3,0
    80001b60:	4605                	li	a2,1
    80001b62:	040005b7          	lui	a1,0x4000
    80001b66:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b68:	05b2                	sll	a1,a1,0xc
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	fffff097          	auipc	ra,0xfffff
    80001b70:	748080e7          	jalr	1864(ra) # 800012b4 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b74:	4581                	li	a1,0
    80001b76:	8526                	mv	a0,s1
    80001b78:	00000097          	auipc	ra,0x0
    80001b7c:	a16080e7          	jalr	-1514(ra) # 8000158e <uvmfree>
    return 0;
    80001b80:	4481                	li	s1,0
    80001b82:	bf7d                	j	80001b40 <proc_pagetable+0x58>

0000000080001b84 <proc_freepagetable>:
{
    80001b84:	1101                	add	sp,sp,-32
    80001b86:	ec06                	sd	ra,24(sp)
    80001b88:	e822                	sd	s0,16(sp)
    80001b8a:	e426                	sd	s1,8(sp)
    80001b8c:	e04a                	sd	s2,0(sp)
    80001b8e:	1000                	add	s0,sp,32
    80001b90:	84aa                	mv	s1,a0
    80001b92:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b94:	4681                	li	a3,0
    80001b96:	4605                	li	a2,1
    80001b98:	040005b7          	lui	a1,0x4000
    80001b9c:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b9e:	05b2                	sll	a1,a1,0xc
    80001ba0:	fffff097          	auipc	ra,0xfffff
    80001ba4:	714080e7          	jalr	1812(ra) # 800012b4 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ba8:	4681                	li	a3,0
    80001baa:	4605                	li	a2,1
    80001bac:	020005b7          	lui	a1,0x2000
    80001bb0:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bb2:	05b6                	sll	a1,a1,0xd
    80001bb4:	8526                	mv	a0,s1
    80001bb6:	fffff097          	auipc	ra,0xfffff
    80001bba:	6fe080e7          	jalr	1790(ra) # 800012b4 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bbe:	85ca                	mv	a1,s2
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	00000097          	auipc	ra,0x0
    80001bc6:	9cc080e7          	jalr	-1588(ra) # 8000158e <uvmfree>
}
    80001bca:	60e2                	ld	ra,24(sp)
    80001bcc:	6442                	ld	s0,16(sp)
    80001bce:	64a2                	ld	s1,8(sp)
    80001bd0:	6902                	ld	s2,0(sp)
    80001bd2:	6105                	add	sp,sp,32
    80001bd4:	8082                	ret

0000000080001bd6 <freeproc>:
{
    80001bd6:	1101                	add	sp,sp,-32
    80001bd8:	ec06                	sd	ra,24(sp)
    80001bda:	e822                	sd	s0,16(sp)
    80001bdc:	e426                	sd	s1,8(sp)
    80001bde:	1000                	add	s0,sp,32
    80001be0:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001be2:	6548                	ld	a0,136(a0)
    80001be4:	c509                	beqz	a0,80001bee <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001be6:	fffff097          	auipc	ra,0xfffff
    80001bea:	e5e080e7          	jalr	-418(ra) # 80000a44 <kfree>
  p->trapframe = 0;
    80001bee:	0804b423          	sd	zero,136(s1)
  if(p->pagetable)
    80001bf2:	60c8                	ld	a0,128(s1)
    80001bf4:	c511                	beqz	a0,80001c00 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bf6:	7cac                	ld	a1,120(s1)
    80001bf8:	00000097          	auipc	ra,0x0
    80001bfc:	f8c080e7          	jalr	-116(ra) # 80001b84 <proc_freepagetable>
  p->pagetable = 0;
    80001c00:	0804b023          	sd	zero,128(s1)
  p->sz = 0;
    80001c04:	0604bc23          	sd	zero,120(s1)
  p->pid = 0;
    80001c08:	0604a023          	sw	zero,96(s1)
  p->parent = 0;
    80001c0c:	0604b423          	sd	zero,104(s1)
  p->name[0] = 0;
    80001c10:	18048423          	sb	zero,392(s1)
  p->chan = 0;
    80001c14:	0404b823          	sd	zero,80(s1)
  p->killed = 0;
    80001c18:	0404ac23          	sw	zero,88(s1)
  p->xstate = 0;
    80001c1c:	0404ae23          	sw	zero,92(s1)
  p->state = UNUSED;
    80001c20:	0404a423          	sw	zero,72(s1)
}
    80001c24:	60e2                	ld	ra,24(sp)
    80001c26:	6442                	ld	s0,16(sp)
    80001c28:	64a2                	ld	s1,8(sp)
    80001c2a:	6105                	add	sp,sp,32
    80001c2c:	8082                	ret

0000000080001c2e <allocproc>:
{
    80001c2e:	1101                	add	sp,sp,-32
    80001c30:	ec06                	sd	ra,24(sp)
    80001c32:	e822                	sd	s0,16(sp)
    80001c34:	e426                	sd	s1,8(sp)
    80001c36:	e04a                	sd	s2,0(sp)
    80001c38:	1000                	add	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c3a:	00010497          	auipc	s1,0x10
    80001c3e:	a9648493          	add	s1,s1,-1386 # 800116d0 <proc>
    80001c42:	00016917          	auipc	s2,0x16
    80001c46:	08e90913          	add	s2,s2,142 # 80017cd0 <tickslock>
    acquire(&p->lock);
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	fffff097          	auipc	ra,0xfffff
    80001c50:	fe6080e7          	jalr	-26(ra) # 80000c32 <acquire>
    if(p->state == UNUSED) {
    80001c54:	44bc                	lw	a5,72(s1)
    80001c56:	cf81                	beqz	a5,80001c6e <allocproc+0x40>
      release(&p->lock);
    80001c58:	8526                	mv	a0,s1
    80001c5a:	fffff097          	auipc	ra,0xfffff
    80001c5e:	08c080e7          	jalr	140(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c62:	19848493          	add	s1,s1,408
    80001c66:	ff2492e3          	bne	s1,s2,80001c4a <allocproc+0x1c>
  return 0;
    80001c6a:	4481                	li	s1,0
    80001c6c:	a885                	j	80001cdc <allocproc+0xae>
  p->pid = allocpid();
    80001c6e:	00000097          	auipc	ra,0x0
    80001c72:	e34080e7          	jalr	-460(ra) # 80001aa2 <allocpid>
    80001c76:	d0a8                	sw	a0,96(s1)
  p->state = USED;
    80001c78:	4785                	li	a5,1
    80001c7a:	c4bc                	sw	a5,72(s1)
  p->nice = 10;
    80001c7c:	47a9                	li	a5,10
    80001c7e:	cc9c                	sw	a5,24(s1)
  p->create_time = ticks;
    80001c80:	00007797          	auipc	a5,0x7
    80001c84:	3b07e783          	lwu	a5,944(a5) # 80009030 <ticks>
    80001c88:	f09c                	sd	a5,32(s1)
  p->run_time = 0;
    80001c8a:	0204b423          	sd	zero,40(s1)
  p->wait_time = 0;
    80001c8e:	0204b823          	sd	zero,48(s1)
  p->sleep_time = 0;
    80001c92:	0204bc23          	sd	zero,56(s1)
  p->exit_time = 0;
    80001c96:	0404b023          	sd	zero,64(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c9a:	fffff097          	auipc	ra,0xfffff
    80001c9e:	ea8080e7          	jalr	-344(ra) # 80000b42 <kalloc>
    80001ca2:	892a                	mv	s2,a0
    80001ca4:	e4c8                	sd	a0,136(s1)
    80001ca6:	c131                	beqz	a0,80001cea <allocproc+0xbc>
  p->pagetable = proc_pagetable(p);
    80001ca8:	8526                	mv	a0,s1
    80001caa:	00000097          	auipc	ra,0x0
    80001cae:	e3e080e7          	jalr	-450(ra) # 80001ae8 <proc_pagetable>
    80001cb2:	892a                	mv	s2,a0
    80001cb4:	e0c8                	sd	a0,128(s1)
  if(p->pagetable == 0){
    80001cb6:	c531                	beqz	a0,80001d02 <allocproc+0xd4>
  memset(&p->context, 0, sizeof(p->context));
    80001cb8:	07000613          	li	a2,112
    80001cbc:	4581                	li	a1,0
    80001cbe:	09048513          	add	a0,s1,144
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	06c080e7          	jalr	108(ra) # 80000d2e <memset>
  p->context.ra = (uint64)forkret;
    80001cca:	00000797          	auipc	a5,0x0
    80001cce:	d9278793          	add	a5,a5,-622 # 80001a5c <forkret>
    80001cd2:	e8dc                	sd	a5,144(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cd4:	78bc                	ld	a5,112(s1)
    80001cd6:	6705                	lui	a4,0x1
    80001cd8:	97ba                	add	a5,a5,a4
    80001cda:	ecdc                	sd	a5,152(s1)
}
    80001cdc:	8526                	mv	a0,s1
    80001cde:	60e2                	ld	ra,24(sp)
    80001ce0:	6442                	ld	s0,16(sp)
    80001ce2:	64a2                	ld	s1,8(sp)
    80001ce4:	6902                	ld	s2,0(sp)
    80001ce6:	6105                	add	sp,sp,32
    80001ce8:	8082                	ret
    freeproc(p);
    80001cea:	8526                	mv	a0,s1
    80001cec:	00000097          	auipc	ra,0x0
    80001cf0:	eea080e7          	jalr	-278(ra) # 80001bd6 <freeproc>
    release(&p->lock);
    80001cf4:	8526                	mv	a0,s1
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	ff0080e7          	jalr	-16(ra) # 80000ce6 <release>
    return 0;
    80001cfe:	84ca                	mv	s1,s2
    80001d00:	bff1                	j	80001cdc <allocproc+0xae>
    freeproc(p);
    80001d02:	8526                	mv	a0,s1
    80001d04:	00000097          	auipc	ra,0x0
    80001d08:	ed2080e7          	jalr	-302(ra) # 80001bd6 <freeproc>
    release(&p->lock);
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	fffff097          	auipc	ra,0xfffff
    80001d12:	fd8080e7          	jalr	-40(ra) # 80000ce6 <release>
    return 0;
    80001d16:	84ca                	mv	s1,s2
    80001d18:	b7d1                	j	80001cdc <allocproc+0xae>

0000000080001d1a <userinit>:
{
    80001d1a:	1101                	add	sp,sp,-32
    80001d1c:	ec06                	sd	ra,24(sp)
    80001d1e:	e822                	sd	s0,16(sp)
    80001d20:	e426                	sd	s1,8(sp)
    80001d22:	1000                	add	s0,sp,32
  p = allocproc();
    80001d24:	00000097          	auipc	ra,0x0
    80001d28:	f0a080e7          	jalr	-246(ra) # 80001c2e <allocproc>
    80001d2c:	84aa                	mv	s1,a0
  initproc = p;
    80001d2e:	00007797          	auipc	a5,0x7
    80001d32:	2ea7bd23          	sd	a0,762(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d36:	03400613          	li	a2,52
    80001d3a:	00007597          	auipc	a1,0x7
    80001d3e:	af658593          	add	a1,a1,-1290 # 80008830 <initcode>
    80001d42:	6148                	ld	a0,128(a0)
    80001d44:	fffff097          	auipc	ra,0xfffff
    80001d48:	672080e7          	jalr	1650(ra) # 800013b6 <uvminit>
  p->sz = PGSIZE;
    80001d4c:	6785                	lui	a5,0x1
    80001d4e:	fcbc                	sd	a5,120(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d50:	64d8                	ld	a4,136(s1)
    80001d52:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d56:	64d8                	ld	a4,136(s1)
    80001d58:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d5a:	4641                	li	a2,16
    80001d5c:	00006597          	auipc	a1,0x6
    80001d60:	48458593          	add	a1,a1,1156 # 800081e0 <etext+0x1e0>
    80001d64:	18848513          	add	a0,s1,392
    80001d68:	fffff097          	auipc	ra,0xfffff
    80001d6c:	108080e7          	jalr	264(ra) # 80000e70 <safestrcpy>
  p->cwd = namei("/");
    80001d70:	00006517          	auipc	a0,0x6
    80001d74:	48050513          	add	a0,a0,1152 # 800081f0 <etext+0x1f0>
    80001d78:	00002097          	auipc	ra,0x2
    80001d7c:	4a0080e7          	jalr	1184(ra) # 80004218 <namei>
    80001d80:	18a4b023          	sd	a0,384(s1)
  p->state = RUNNABLE;
    80001d84:	478d                	li	a5,3
    80001d86:	c4bc                	sw	a5,72(s1)
  release(&p->lock);
    80001d88:	8526                	mv	a0,s1
    80001d8a:	fffff097          	auipc	ra,0xfffff
    80001d8e:	f5c080e7          	jalr	-164(ra) # 80000ce6 <release>
}
    80001d92:	60e2                	ld	ra,24(sp)
    80001d94:	6442                	ld	s0,16(sp)
    80001d96:	64a2                	ld	s1,8(sp)
    80001d98:	6105                	add	sp,sp,32
    80001d9a:	8082                	ret

0000000080001d9c <growproc>:
{
    80001d9c:	1101                	add	sp,sp,-32
    80001d9e:	ec06                	sd	ra,24(sp)
    80001da0:	e822                	sd	s0,16(sp)
    80001da2:	e426                	sd	s1,8(sp)
    80001da4:	e04a                	sd	s2,0(sp)
    80001da6:	1000                	add	s0,sp,32
    80001da8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001daa:	00000097          	auipc	ra,0x0
    80001dae:	c7a080e7          	jalr	-902(ra) # 80001a24 <myproc>
    80001db2:	892a                	mv	s2,a0
  sz = p->sz;
    80001db4:	7d2c                	ld	a1,120(a0)
    80001db6:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001dba:	00904f63          	bgtz	s1,80001dd8 <growproc+0x3c>
  } else if(n < 0){
    80001dbe:	0204cd63          	bltz	s1,80001df8 <growproc+0x5c>
  p->sz = sz;
    80001dc2:	1782                	sll	a5,a5,0x20
    80001dc4:	9381                	srl	a5,a5,0x20
    80001dc6:	06f93c23          	sd	a5,120(s2)
  return 0;
    80001dca:	4501                	li	a0,0
}
    80001dcc:	60e2                	ld	ra,24(sp)
    80001dce:	6442                	ld	s0,16(sp)
    80001dd0:	64a2                	ld	s1,8(sp)
    80001dd2:	6902                	ld	s2,0(sp)
    80001dd4:	6105                	add	sp,sp,32
    80001dd6:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001dd8:	00f4863b          	addw	a2,s1,a5
    80001ddc:	1602                	sll	a2,a2,0x20
    80001dde:	9201                	srl	a2,a2,0x20
    80001de0:	1582                	sll	a1,a1,0x20
    80001de2:	9181                	srl	a1,a1,0x20
    80001de4:	6148                	ld	a0,128(a0)
    80001de6:	fffff097          	auipc	ra,0xfffff
    80001dea:	68a080e7          	jalr	1674(ra) # 80001470 <uvmalloc>
    80001dee:	0005079b          	sext.w	a5,a0
    80001df2:	fbe1                	bnez	a5,80001dc2 <growproc+0x26>
      return -1;
    80001df4:	557d                	li	a0,-1
    80001df6:	bfd9                	j	80001dcc <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001df8:	00f4863b          	addw	a2,s1,a5
    80001dfc:	1602                	sll	a2,a2,0x20
    80001dfe:	9201                	srl	a2,a2,0x20
    80001e00:	1582                	sll	a1,a1,0x20
    80001e02:	9181                	srl	a1,a1,0x20
    80001e04:	6148                	ld	a0,128(a0)
    80001e06:	fffff097          	auipc	ra,0xfffff
    80001e0a:	622080e7          	jalr	1570(ra) # 80001428 <uvmdealloc>
    80001e0e:	0005079b          	sext.w	a5,a0
    80001e12:	bf45                	j	80001dc2 <growproc+0x26>

0000000080001e14 <fork>:
{
    80001e14:	7139                	add	sp,sp,-64
    80001e16:	fc06                	sd	ra,56(sp)
    80001e18:	f822                	sd	s0,48(sp)
    80001e1a:	f04a                	sd	s2,32(sp)
    80001e1c:	e456                	sd	s5,8(sp)
    80001e1e:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001e20:	00000097          	auipc	ra,0x0
    80001e24:	c04080e7          	jalr	-1020(ra) # 80001a24 <myproc>
    80001e28:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e2a:	00000097          	auipc	ra,0x0
    80001e2e:	e04080e7          	jalr	-508(ra) # 80001c2e <allocproc>
    80001e32:	12050063          	beqz	a0,80001f52 <fork+0x13e>
    80001e36:	e852                	sd	s4,16(sp)
    80001e38:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e3a:	078ab603          	ld	a2,120(s5)
    80001e3e:	614c                	ld	a1,128(a0)
    80001e40:	080ab503          	ld	a0,128(s5)
    80001e44:	fffff097          	auipc	ra,0xfffff
    80001e48:	784080e7          	jalr	1924(ra) # 800015c8 <uvmcopy>
    80001e4c:	04054a63          	bltz	a0,80001ea0 <fork+0x8c>
    80001e50:	f426                	sd	s1,40(sp)
    80001e52:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001e54:	078ab783          	ld	a5,120(s5)
    80001e58:	06fa3c23          	sd	a5,120(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e5c:	088ab683          	ld	a3,136(s5)
    80001e60:	87b6                	mv	a5,a3
    80001e62:	088a3703          	ld	a4,136(s4)
    80001e66:	12068693          	add	a3,a3,288
    80001e6a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e6e:	6788                	ld	a0,8(a5)
    80001e70:	6b8c                	ld	a1,16(a5)
    80001e72:	6f90                	ld	a2,24(a5)
    80001e74:	01073023          	sd	a6,0(a4)
    80001e78:	e708                	sd	a0,8(a4)
    80001e7a:	eb0c                	sd	a1,16(a4)
    80001e7c:	ef10                	sd	a2,24(a4)
    80001e7e:	02078793          	add	a5,a5,32
    80001e82:	02070713          	add	a4,a4,32
    80001e86:	fed792e3          	bne	a5,a3,80001e6a <fork+0x56>
  np->trapframe->a0 = 0;
    80001e8a:	088a3783          	ld	a5,136(s4)
    80001e8e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e92:	100a8493          	add	s1,s5,256
    80001e96:	100a0913          	add	s2,s4,256
    80001e9a:	180a8993          	add	s3,s5,384
    80001e9e:	a015                	j	80001ec2 <fork+0xae>
    freeproc(np);
    80001ea0:	8552                	mv	a0,s4
    80001ea2:	00000097          	auipc	ra,0x0
    80001ea6:	d34080e7          	jalr	-716(ra) # 80001bd6 <freeproc>
    release(&np->lock);
    80001eaa:	8552                	mv	a0,s4
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	e3a080e7          	jalr	-454(ra) # 80000ce6 <release>
    return -1;
    80001eb4:	597d                	li	s2,-1
    80001eb6:	6a42                	ld	s4,16(sp)
    80001eb8:	a071                	j	80001f44 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001eba:	04a1                	add	s1,s1,8
    80001ebc:	0921                	add	s2,s2,8
    80001ebe:	01348b63          	beq	s1,s3,80001ed4 <fork+0xc0>
    if(p->ofile[i])
    80001ec2:	6088                	ld	a0,0(s1)
    80001ec4:	d97d                	beqz	a0,80001eba <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ec6:	00003097          	auipc	ra,0x3
    80001eca:	9ca080e7          	jalr	-1590(ra) # 80004890 <filedup>
    80001ece:	00a93023          	sd	a0,0(s2)
    80001ed2:	b7e5                	j	80001eba <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001ed4:	180ab503          	ld	a0,384(s5)
    80001ed8:	00002097          	auipc	ra,0x2
    80001edc:	b30080e7          	jalr	-1232(ra) # 80003a08 <idup>
    80001ee0:	18aa3023          	sd	a0,384(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ee4:	4641                	li	a2,16
    80001ee6:	188a8593          	add	a1,s5,392
    80001eea:	188a0513          	add	a0,s4,392
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	f82080e7          	jalr	-126(ra) # 80000e70 <safestrcpy>
  pid = np->pid;
    80001ef6:	060a2903          	lw	s2,96(s4)
  release(&np->lock);
    80001efa:	8552                	mv	a0,s4
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	dea080e7          	jalr	-534(ra) # 80000ce6 <release>
  acquire(&wait_lock);
    80001f04:	0000f497          	auipc	s1,0xf
    80001f08:	3b448493          	add	s1,s1,948 # 800112b8 <wait_lock>
    80001f0c:	8526                	mv	a0,s1
    80001f0e:	fffff097          	auipc	ra,0xfffff
    80001f12:	d24080e7          	jalr	-732(ra) # 80000c32 <acquire>
  np->parent = p;
    80001f16:	075a3423          	sd	s5,104(s4)
  release(&wait_lock);
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	fffff097          	auipc	ra,0xfffff
    80001f20:	dca080e7          	jalr	-566(ra) # 80000ce6 <release>
  acquire(&np->lock);
    80001f24:	8552                	mv	a0,s4
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	d0c080e7          	jalr	-756(ra) # 80000c32 <acquire>
  np->state = RUNNABLE;
    80001f2e:	478d                	li	a5,3
    80001f30:	04fa2423          	sw	a5,72(s4)
  release(&np->lock);
    80001f34:	8552                	mv	a0,s4
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	db0080e7          	jalr	-592(ra) # 80000ce6 <release>
  return pid;
    80001f3e:	74a2                	ld	s1,40(sp)
    80001f40:	69e2                	ld	s3,24(sp)
    80001f42:	6a42                	ld	s4,16(sp)
}
    80001f44:	854a                	mv	a0,s2
    80001f46:	70e2                	ld	ra,56(sp)
    80001f48:	7442                	ld	s0,48(sp)
    80001f4a:	7902                	ld	s2,32(sp)
    80001f4c:	6aa2                	ld	s5,8(sp)
    80001f4e:	6121                	add	sp,sp,64
    80001f50:	8082                	ret
    return -1;
    80001f52:	597d                	li	s2,-1
    80001f54:	bfc5                	j	80001f44 <fork+0x130>

0000000080001f56 <scheduler>:
{
    80001f56:	7139                	add	sp,sp,-64
    80001f58:	fc06                	sd	ra,56(sp)
    80001f5a:	f822                	sd	s0,48(sp)
    80001f5c:	f426                	sd	s1,40(sp)
    80001f5e:	f04a                	sd	s2,32(sp)
    80001f60:	ec4e                	sd	s3,24(sp)
    80001f62:	e852                	sd	s4,16(sp)
    80001f64:	e456                	sd	s5,8(sp)
    80001f66:	e05a                	sd	s6,0(sp)
    80001f68:	0080                	add	s0,sp,64
    80001f6a:	8792                	mv	a5,tp
  int id = r_tp();
    80001f6c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f6e:	00779a93          	sll	s5,a5,0x7
    80001f72:	0000f717          	auipc	a4,0xf
    80001f76:	32e70713          	add	a4,a4,814 # 800112a0 <pid_lock>
    80001f7a:	9756                	add	a4,a4,s5
    80001f7c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f80:	0000f717          	auipc	a4,0xf
    80001f84:	35870713          	add	a4,a4,856 # 800112d8 <cpus+0x8>
    80001f88:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f8a:	498d                	li	s3,3
        p->state = RUNNING;
    80001f8c:	4b11                	li	s6,4
        c->proc = p;
    80001f8e:	079e                	sll	a5,a5,0x7
    80001f90:	0000fa17          	auipc	s4,0xf
    80001f94:	310a0a13          	add	s4,s4,784 # 800112a0 <pid_lock>
    80001f98:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f9a:	00016917          	auipc	s2,0x16
    80001f9e:	d3690913          	add	s2,s2,-714 # 80017cd0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fa6:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001faa:	10079073          	csrw	sstatus,a5
    80001fae:	0000f497          	auipc	s1,0xf
    80001fb2:	72248493          	add	s1,s1,1826 # 800116d0 <proc>
    80001fb6:	a811                	j	80001fca <scheduler+0x74>
      release(&p->lock);
    80001fb8:	8526                	mv	a0,s1
    80001fba:	fffff097          	auipc	ra,0xfffff
    80001fbe:	d2c080e7          	jalr	-724(ra) # 80000ce6 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fc2:	19848493          	add	s1,s1,408
    80001fc6:	fd248ee3          	beq	s1,s2,80001fa2 <scheduler+0x4c>
      acquire(&p->lock);
    80001fca:	8526                	mv	a0,s1
    80001fcc:	fffff097          	auipc	ra,0xfffff
    80001fd0:	c66080e7          	jalr	-922(ra) # 80000c32 <acquire>
      if(p->state == RUNNABLE) {
    80001fd4:	44bc                	lw	a5,72(s1)
    80001fd6:	ff3791e3          	bne	a5,s3,80001fb8 <scheduler+0x62>
        p->state = RUNNING;
    80001fda:	0564a423          	sw	s6,72(s1)
        c->proc = p;
    80001fde:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fe2:	09048593          	add	a1,s1,144
    80001fe6:	8556                	mv	a0,s5
    80001fe8:	00000097          	auipc	ra,0x0
    80001fec:	7d6080e7          	jalr	2006(ra) # 800027be <swtch>
        c->proc = 0;
    80001ff0:	020a3823          	sd	zero,48(s4)
    80001ff4:	b7d1                	j	80001fb8 <scheduler+0x62>

0000000080001ff6 <sched>:
{
    80001ff6:	7179                	add	sp,sp,-48
    80001ff8:	f406                	sd	ra,40(sp)
    80001ffa:	f022                	sd	s0,32(sp)
    80001ffc:	ec26                	sd	s1,24(sp)
    80001ffe:	e84a                	sd	s2,16(sp)
    80002000:	e44e                	sd	s3,8(sp)
    80002002:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80002004:	00000097          	auipc	ra,0x0
    80002008:	a20080e7          	jalr	-1504(ra) # 80001a24 <myproc>
    8000200c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000200e:	fffff097          	auipc	ra,0xfffff
    80002012:	baa080e7          	jalr	-1110(ra) # 80000bb8 <holding>
    80002016:	c93d                	beqz	a0,8000208c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002018:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000201a:	2781                	sext.w	a5,a5
    8000201c:	079e                	sll	a5,a5,0x7
    8000201e:	0000f717          	auipc	a4,0xf
    80002022:	28270713          	add	a4,a4,642 # 800112a0 <pid_lock>
    80002026:	97ba                	add	a5,a5,a4
    80002028:	0a87a703          	lw	a4,168(a5)
    8000202c:	4785                	li	a5,1
    8000202e:	06f71763          	bne	a4,a5,8000209c <sched+0xa6>
  if(p->state == RUNNING)
    80002032:	44b8                	lw	a4,72(s1)
    80002034:	4791                	li	a5,4
    80002036:	06f70b63          	beq	a4,a5,800020ac <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000203a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000203e:	8b89                	and	a5,a5,2
  if(intr_get())
    80002040:	efb5                	bnez	a5,800020bc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002042:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002044:	0000f917          	auipc	s2,0xf
    80002048:	25c90913          	add	s2,s2,604 # 800112a0 <pid_lock>
    8000204c:	2781                	sext.w	a5,a5
    8000204e:	079e                	sll	a5,a5,0x7
    80002050:	97ca                	add	a5,a5,s2
    80002052:	0ac7a983          	lw	s3,172(a5)
    80002056:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002058:	2781                	sext.w	a5,a5
    8000205a:	079e                	sll	a5,a5,0x7
    8000205c:	0000f597          	auipc	a1,0xf
    80002060:	27c58593          	add	a1,a1,636 # 800112d8 <cpus+0x8>
    80002064:	95be                	add	a1,a1,a5
    80002066:	09048513          	add	a0,s1,144
    8000206a:	00000097          	auipc	ra,0x0
    8000206e:	754080e7          	jalr	1876(ra) # 800027be <swtch>
    80002072:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002074:	2781                	sext.w	a5,a5
    80002076:	079e                	sll	a5,a5,0x7
    80002078:	993e                	add	s2,s2,a5
    8000207a:	0b392623          	sw	s3,172(s2)
}
    8000207e:	70a2                	ld	ra,40(sp)
    80002080:	7402                	ld	s0,32(sp)
    80002082:	64e2                	ld	s1,24(sp)
    80002084:	6942                	ld	s2,16(sp)
    80002086:	69a2                	ld	s3,8(sp)
    80002088:	6145                	add	sp,sp,48
    8000208a:	8082                	ret
    panic("sched p->lock");
    8000208c:	00006517          	auipc	a0,0x6
    80002090:	16c50513          	add	a0,a0,364 # 800081f8 <etext+0x1f8>
    80002094:	ffffe097          	auipc	ra,0xffffe
    80002098:	4c6080e7          	jalr	1222(ra) # 8000055a <panic>
    panic("sched locks");
    8000209c:	00006517          	auipc	a0,0x6
    800020a0:	16c50513          	add	a0,a0,364 # 80008208 <etext+0x208>
    800020a4:	ffffe097          	auipc	ra,0xffffe
    800020a8:	4b6080e7          	jalr	1206(ra) # 8000055a <panic>
    panic("sched running");
    800020ac:	00006517          	auipc	a0,0x6
    800020b0:	16c50513          	add	a0,a0,364 # 80008218 <etext+0x218>
    800020b4:	ffffe097          	auipc	ra,0xffffe
    800020b8:	4a6080e7          	jalr	1190(ra) # 8000055a <panic>
    panic("sched interruptible");
    800020bc:	00006517          	auipc	a0,0x6
    800020c0:	16c50513          	add	a0,a0,364 # 80008228 <etext+0x228>
    800020c4:	ffffe097          	auipc	ra,0xffffe
    800020c8:	496080e7          	jalr	1174(ra) # 8000055a <panic>

00000000800020cc <yield>:
{
    800020cc:	1101                	add	sp,sp,-32
    800020ce:	ec06                	sd	ra,24(sp)
    800020d0:	e822                	sd	s0,16(sp)
    800020d2:	e426                	sd	s1,8(sp)
    800020d4:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    800020d6:	00000097          	auipc	ra,0x0
    800020da:	94e080e7          	jalr	-1714(ra) # 80001a24 <myproc>
    800020de:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020e0:	fffff097          	auipc	ra,0xfffff
    800020e4:	b52080e7          	jalr	-1198(ra) # 80000c32 <acquire>
  p->state = RUNNABLE;
    800020e8:	478d                	li	a5,3
    800020ea:	c4bc                	sw	a5,72(s1)
  sched();
    800020ec:	00000097          	auipc	ra,0x0
    800020f0:	f0a080e7          	jalr	-246(ra) # 80001ff6 <sched>
  release(&p->lock);
    800020f4:	8526                	mv	a0,s1
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	bf0080e7          	jalr	-1040(ra) # 80000ce6 <release>
}
    800020fe:	60e2                	ld	ra,24(sp)
    80002100:	6442                	ld	s0,16(sp)
    80002102:	64a2                	ld	s1,8(sp)
    80002104:	6105                	add	sp,sp,32
    80002106:	8082                	ret

0000000080002108 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002108:	7179                	add	sp,sp,-48
    8000210a:	f406                	sd	ra,40(sp)
    8000210c:	f022                	sd	s0,32(sp)
    8000210e:	ec26                	sd	s1,24(sp)
    80002110:	e84a                	sd	s2,16(sp)
    80002112:	e44e                	sd	s3,8(sp)
    80002114:	1800                	add	s0,sp,48
    80002116:	89aa                	mv	s3,a0
    80002118:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000211a:	00000097          	auipc	ra,0x0
    8000211e:	90a080e7          	jalr	-1782(ra) # 80001a24 <myproc>
    80002122:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	b0e080e7          	jalr	-1266(ra) # 80000c32 <acquire>
  release(lk);
    8000212c:	854a                	mv	a0,s2
    8000212e:	fffff097          	auipc	ra,0xfffff
    80002132:	bb8080e7          	jalr	-1096(ra) # 80000ce6 <release>

  // Go to sleep.
  p->chan = chan;
    80002136:	0534b823          	sd	s3,80(s1)
  p->state = SLEEPING;
    8000213a:	4789                	li	a5,2
    8000213c:	c4bc                	sw	a5,72(s1)

  sched();
    8000213e:	00000097          	auipc	ra,0x0
    80002142:	eb8080e7          	jalr	-328(ra) # 80001ff6 <sched>

  // Tidy up.
  p->chan = 0;
    80002146:	0404b823          	sd	zero,80(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000214a:	8526                	mv	a0,s1
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	b9a080e7          	jalr	-1126(ra) # 80000ce6 <release>
  acquire(lk);
    80002154:	854a                	mv	a0,s2
    80002156:	fffff097          	auipc	ra,0xfffff
    8000215a:	adc080e7          	jalr	-1316(ra) # 80000c32 <acquire>
}
    8000215e:	70a2                	ld	ra,40(sp)
    80002160:	7402                	ld	s0,32(sp)
    80002162:	64e2                	ld	s1,24(sp)
    80002164:	6942                	ld	s2,16(sp)
    80002166:	69a2                	ld	s3,8(sp)
    80002168:	6145                	add	sp,sp,48
    8000216a:	8082                	ret

000000008000216c <wait>:
{
    8000216c:	715d                	add	sp,sp,-80
    8000216e:	e486                	sd	ra,72(sp)
    80002170:	e0a2                	sd	s0,64(sp)
    80002172:	fc26                	sd	s1,56(sp)
    80002174:	f84a                	sd	s2,48(sp)
    80002176:	f44e                	sd	s3,40(sp)
    80002178:	f052                	sd	s4,32(sp)
    8000217a:	ec56                	sd	s5,24(sp)
    8000217c:	e85a                	sd	s6,16(sp)
    8000217e:	e45e                	sd	s7,8(sp)
    80002180:	e062                	sd	s8,0(sp)
    80002182:	0880                	add	s0,sp,80
    80002184:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002186:	00000097          	auipc	ra,0x0
    8000218a:	89e080e7          	jalr	-1890(ra) # 80001a24 <myproc>
    8000218e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002190:	0000f517          	auipc	a0,0xf
    80002194:	12850513          	add	a0,a0,296 # 800112b8 <wait_lock>
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	a9a080e7          	jalr	-1382(ra) # 80000c32 <acquire>
    havekids = 0;
    800021a0:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800021a2:	4a15                	li	s4,5
        havekids = 1;
    800021a4:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800021a6:	00016997          	auipc	s3,0x16
    800021aa:	b2a98993          	add	s3,s3,-1238 # 80017cd0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021ae:	0000fc17          	auipc	s8,0xf
    800021b2:	10ac0c13          	add	s8,s8,266 # 800112b8 <wait_lock>
    800021b6:	a87d                	j	80002274 <wait+0x108>
          pid = np->pid;
    800021b8:	0604a983          	lw	s3,96(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800021bc:	000b0e63          	beqz	s6,800021d8 <wait+0x6c>
    800021c0:	4691                	li	a3,4
    800021c2:	05c48613          	add	a2,s1,92
    800021c6:	85da                	mv	a1,s6
    800021c8:	08093503          	ld	a0,128(s2)
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	500080e7          	jalr	1280(ra) # 800016cc <copyout>
    800021d4:	04054163          	bltz	a0,80002216 <wait+0xaa>
          freeproc(np);
    800021d8:	8526                	mv	a0,s1
    800021da:	00000097          	auipc	ra,0x0
    800021de:	9fc080e7          	jalr	-1540(ra) # 80001bd6 <freeproc>
          release(&np->lock);
    800021e2:	8526                	mv	a0,s1
    800021e4:	fffff097          	auipc	ra,0xfffff
    800021e8:	b02080e7          	jalr	-1278(ra) # 80000ce6 <release>
          release(&wait_lock);
    800021ec:	0000f517          	auipc	a0,0xf
    800021f0:	0cc50513          	add	a0,a0,204 # 800112b8 <wait_lock>
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	af2080e7          	jalr	-1294(ra) # 80000ce6 <release>
}
    800021fc:	854e                	mv	a0,s3
    800021fe:	60a6                	ld	ra,72(sp)
    80002200:	6406                	ld	s0,64(sp)
    80002202:	74e2                	ld	s1,56(sp)
    80002204:	7942                	ld	s2,48(sp)
    80002206:	79a2                	ld	s3,40(sp)
    80002208:	7a02                	ld	s4,32(sp)
    8000220a:	6ae2                	ld	s5,24(sp)
    8000220c:	6b42                	ld	s6,16(sp)
    8000220e:	6ba2                	ld	s7,8(sp)
    80002210:	6c02                	ld	s8,0(sp)
    80002212:	6161                	add	sp,sp,80
    80002214:	8082                	ret
            release(&np->lock);
    80002216:	8526                	mv	a0,s1
    80002218:	fffff097          	auipc	ra,0xfffff
    8000221c:	ace080e7          	jalr	-1330(ra) # 80000ce6 <release>
            release(&wait_lock);
    80002220:	0000f517          	auipc	a0,0xf
    80002224:	09850513          	add	a0,a0,152 # 800112b8 <wait_lock>
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	abe080e7          	jalr	-1346(ra) # 80000ce6 <release>
            return -1;
    80002230:	59fd                	li	s3,-1
    80002232:	b7e9                	j	800021fc <wait+0x90>
    for(np = proc; np < &proc[NPROC]; np++){
    80002234:	19848493          	add	s1,s1,408
    80002238:	03348463          	beq	s1,s3,80002260 <wait+0xf4>
      if(np->parent == p){
    8000223c:	74bc                	ld	a5,104(s1)
    8000223e:	ff279be3          	bne	a5,s2,80002234 <wait+0xc8>
        acquire(&np->lock);
    80002242:	8526                	mv	a0,s1
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	9ee080e7          	jalr	-1554(ra) # 80000c32 <acquire>
        if(np->state == ZOMBIE){
    8000224c:	44bc                	lw	a5,72(s1)
    8000224e:	f74785e3          	beq	a5,s4,800021b8 <wait+0x4c>
        release(&np->lock);
    80002252:	8526                	mv	a0,s1
    80002254:	fffff097          	auipc	ra,0xfffff
    80002258:	a92080e7          	jalr	-1390(ra) # 80000ce6 <release>
        havekids = 1;
    8000225c:	8756                	mv	a4,s5
    8000225e:	bfd9                	j	80002234 <wait+0xc8>
    if(!havekids || p->killed){
    80002260:	c305                	beqz	a4,80002280 <wait+0x114>
    80002262:	05892783          	lw	a5,88(s2)
    80002266:	ef89                	bnez	a5,80002280 <wait+0x114>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002268:	85e2                	mv	a1,s8
    8000226a:	854a                	mv	a0,s2
    8000226c:	00000097          	auipc	ra,0x0
    80002270:	e9c080e7          	jalr	-356(ra) # 80002108 <sleep>
    havekids = 0;
    80002274:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002276:	0000f497          	auipc	s1,0xf
    8000227a:	45a48493          	add	s1,s1,1114 # 800116d0 <proc>
    8000227e:	bf7d                	j	8000223c <wait+0xd0>
      release(&wait_lock);
    80002280:	0000f517          	auipc	a0,0xf
    80002284:	03850513          	add	a0,a0,56 # 800112b8 <wait_lock>
    80002288:	fffff097          	auipc	ra,0xfffff
    8000228c:	a5e080e7          	jalr	-1442(ra) # 80000ce6 <release>
      return -1;
    80002290:	59fd                	li	s3,-1
    80002292:	b7ad                	j	800021fc <wait+0x90>

0000000080002294 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002294:	7139                	add	sp,sp,-64
    80002296:	fc06                	sd	ra,56(sp)
    80002298:	f822                	sd	s0,48(sp)
    8000229a:	f426                	sd	s1,40(sp)
    8000229c:	f04a                	sd	s2,32(sp)
    8000229e:	ec4e                	sd	s3,24(sp)
    800022a0:	e852                	sd	s4,16(sp)
    800022a2:	e456                	sd	s5,8(sp)
    800022a4:	0080                	add	s0,sp,64
    800022a6:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800022a8:	0000f497          	auipc	s1,0xf
    800022ac:	42848493          	add	s1,s1,1064 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800022b0:	4989                	li	s3,2
        p->state = RUNNABLE;
    800022b2:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800022b4:	00016917          	auipc	s2,0x16
    800022b8:	a1c90913          	add	s2,s2,-1508 # 80017cd0 <tickslock>
    800022bc:	a811                	j	800022d0 <wakeup+0x3c>
      }
      release(&p->lock);
    800022be:	8526                	mv	a0,s1
    800022c0:	fffff097          	auipc	ra,0xfffff
    800022c4:	a26080e7          	jalr	-1498(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022c8:	19848493          	add	s1,s1,408
    800022cc:	03248663          	beq	s1,s2,800022f8 <wakeup+0x64>
    if(p != myproc()){
    800022d0:	fffff097          	auipc	ra,0xfffff
    800022d4:	754080e7          	jalr	1876(ra) # 80001a24 <myproc>
    800022d8:	fea488e3          	beq	s1,a0,800022c8 <wakeup+0x34>
      acquire(&p->lock);
    800022dc:	8526                	mv	a0,s1
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	954080e7          	jalr	-1708(ra) # 80000c32 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022e6:	44bc                	lw	a5,72(s1)
    800022e8:	fd379be3          	bne	a5,s3,800022be <wakeup+0x2a>
    800022ec:	68bc                	ld	a5,80(s1)
    800022ee:	fd4798e3          	bne	a5,s4,800022be <wakeup+0x2a>
        p->state = RUNNABLE;
    800022f2:	0554a423          	sw	s5,72(s1)
    800022f6:	b7e1                	j	800022be <wakeup+0x2a>
    }
  }
}
    800022f8:	70e2                	ld	ra,56(sp)
    800022fa:	7442                	ld	s0,48(sp)
    800022fc:	74a2                	ld	s1,40(sp)
    800022fe:	7902                	ld	s2,32(sp)
    80002300:	69e2                	ld	s3,24(sp)
    80002302:	6a42                	ld	s4,16(sp)
    80002304:	6aa2                	ld	s5,8(sp)
    80002306:	6121                	add	sp,sp,64
    80002308:	8082                	ret

000000008000230a <reparent>:
{
    8000230a:	7179                	add	sp,sp,-48
    8000230c:	f406                	sd	ra,40(sp)
    8000230e:	f022                	sd	s0,32(sp)
    80002310:	ec26                	sd	s1,24(sp)
    80002312:	e84a                	sd	s2,16(sp)
    80002314:	e44e                	sd	s3,8(sp)
    80002316:	e052                	sd	s4,0(sp)
    80002318:	1800                	add	s0,sp,48
    8000231a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000231c:	0000f497          	auipc	s1,0xf
    80002320:	3b448493          	add	s1,s1,948 # 800116d0 <proc>
      pp->parent = initproc;
    80002324:	00007a17          	auipc	s4,0x7
    80002328:	d04a0a13          	add	s4,s4,-764 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000232c:	00016997          	auipc	s3,0x16
    80002330:	9a498993          	add	s3,s3,-1628 # 80017cd0 <tickslock>
    80002334:	a029                	j	8000233e <reparent+0x34>
    80002336:	19848493          	add	s1,s1,408
    8000233a:	01348d63          	beq	s1,s3,80002354 <reparent+0x4a>
    if(pp->parent == p){
    8000233e:	74bc                	ld	a5,104(s1)
    80002340:	ff279be3          	bne	a5,s2,80002336 <reparent+0x2c>
      pp->parent = initproc;
    80002344:	000a3503          	ld	a0,0(s4)
    80002348:	f4a8                	sd	a0,104(s1)
      wakeup(initproc);
    8000234a:	00000097          	auipc	ra,0x0
    8000234e:	f4a080e7          	jalr	-182(ra) # 80002294 <wakeup>
    80002352:	b7d5                	j	80002336 <reparent+0x2c>
}
    80002354:	70a2                	ld	ra,40(sp)
    80002356:	7402                	ld	s0,32(sp)
    80002358:	64e2                	ld	s1,24(sp)
    8000235a:	6942                	ld	s2,16(sp)
    8000235c:	69a2                	ld	s3,8(sp)
    8000235e:	6a02                	ld	s4,0(sp)
    80002360:	6145                	add	sp,sp,48
    80002362:	8082                	ret

0000000080002364 <exit>:
{
    80002364:	7179                	add	sp,sp,-48
    80002366:	f406                	sd	ra,40(sp)
    80002368:	f022                	sd	s0,32(sp)
    8000236a:	ec26                	sd	s1,24(sp)
    8000236c:	e84a                	sd	s2,16(sp)
    8000236e:	e44e                	sd	s3,8(sp)
    80002370:	e052                	sd	s4,0(sp)
    80002372:	1800                	add	s0,sp,48
    80002374:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	6ae080e7          	jalr	1710(ra) # 80001a24 <myproc>
    8000237e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002380:	00007797          	auipc	a5,0x7
    80002384:	ca87b783          	ld	a5,-856(a5) # 80009028 <initproc>
    80002388:	10050493          	add	s1,a0,256
    8000238c:	18050913          	add	s2,a0,384
    80002390:	02a79363          	bne	a5,a0,800023b6 <exit+0x52>
    panic("init exiting");
    80002394:	00006517          	auipc	a0,0x6
    80002398:	eac50513          	add	a0,a0,-340 # 80008240 <etext+0x240>
    8000239c:	ffffe097          	auipc	ra,0xffffe
    800023a0:	1be080e7          	jalr	446(ra) # 8000055a <panic>
      fileclose(f);
    800023a4:	00002097          	auipc	ra,0x2
    800023a8:	53e080e7          	jalr	1342(ra) # 800048e2 <fileclose>
      p->ofile[fd] = 0;
    800023ac:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800023b0:	04a1                	add	s1,s1,8
    800023b2:	01248563          	beq	s1,s2,800023bc <exit+0x58>
    if(p->ofile[fd]){
    800023b6:	6088                	ld	a0,0(s1)
    800023b8:	f575                	bnez	a0,800023a4 <exit+0x40>
    800023ba:	bfdd                	j	800023b0 <exit+0x4c>
  begin_op();
    800023bc:	00002097          	auipc	ra,0x2
    800023c0:	05c080e7          	jalr	92(ra) # 80004418 <begin_op>
  iput(p->cwd);
    800023c4:	1809b503          	ld	a0,384(s3)
    800023c8:	00002097          	auipc	ra,0x2
    800023cc:	83c080e7          	jalr	-1988(ra) # 80003c04 <iput>
  end_op();
    800023d0:	00002097          	auipc	ra,0x2
    800023d4:	0c2080e7          	jalr	194(ra) # 80004492 <end_op>
  p->cwd = 0;
    800023d8:	1809b023          	sd	zero,384(s3)
  acquire(&wait_lock);
    800023dc:	0000f497          	auipc	s1,0xf
    800023e0:	edc48493          	add	s1,s1,-292 # 800112b8 <wait_lock>
    800023e4:	8526                	mv	a0,s1
    800023e6:	fffff097          	auipc	ra,0xfffff
    800023ea:	84c080e7          	jalr	-1972(ra) # 80000c32 <acquire>
  reparent(p);
    800023ee:	854e                	mv	a0,s3
    800023f0:	00000097          	auipc	ra,0x0
    800023f4:	f1a080e7          	jalr	-230(ra) # 8000230a <reparent>
  wakeup(p->parent);
    800023f8:	0689b503          	ld	a0,104(s3)
    800023fc:	00000097          	auipc	ra,0x0
    80002400:	e98080e7          	jalr	-360(ra) # 80002294 <wakeup>
  acquire(&p->lock);
    80002404:	854e                	mv	a0,s3
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	82c080e7          	jalr	-2004(ra) # 80000c32 <acquire>
  p->xstate = status;
    8000240e:	0549ae23          	sw	s4,92(s3)
  p->state = ZOMBIE;
    80002412:	4795                	li	a5,5
    80002414:	04f9a423          	sw	a5,72(s3)
  p->exit_time = ticks;
    80002418:	00007797          	auipc	a5,0x7
    8000241c:	c187e783          	lwu	a5,-1000(a5) # 80009030 <ticks>
    80002420:	04f9b023          	sd	a5,64(s3)
  release(&wait_lock);
    80002424:	8526                	mv	a0,s1
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	8c0080e7          	jalr	-1856(ra) # 80000ce6 <release>
  sched();
    8000242e:	00000097          	auipc	ra,0x0
    80002432:	bc8080e7          	jalr	-1080(ra) # 80001ff6 <sched>
  panic("zombie exit");
    80002436:	00006517          	auipc	a0,0x6
    8000243a:	e1a50513          	add	a0,a0,-486 # 80008250 <etext+0x250>
    8000243e:	ffffe097          	auipc	ra,0xffffe
    80002442:	11c080e7          	jalr	284(ra) # 8000055a <panic>

0000000080002446 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002446:	7179                	add	sp,sp,-48
    80002448:	f406                	sd	ra,40(sp)
    8000244a:	f022                	sd	s0,32(sp)
    8000244c:	ec26                	sd	s1,24(sp)
    8000244e:	e84a                	sd	s2,16(sp)
    80002450:	e44e                	sd	s3,8(sp)
    80002452:	1800                	add	s0,sp,48
    80002454:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002456:	0000f497          	auipc	s1,0xf
    8000245a:	27a48493          	add	s1,s1,634 # 800116d0 <proc>
    8000245e:	00016997          	auipc	s3,0x16
    80002462:	87298993          	add	s3,s3,-1934 # 80017cd0 <tickslock>
    acquire(&p->lock);
    80002466:	8526                	mv	a0,s1
    80002468:	ffffe097          	auipc	ra,0xffffe
    8000246c:	7ca080e7          	jalr	1994(ra) # 80000c32 <acquire>
    if(p->pid == pid){
    80002470:	50bc                	lw	a5,96(s1)
    80002472:	01278d63          	beq	a5,s2,8000248c <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002476:	8526                	mv	a0,s1
    80002478:	fffff097          	auipc	ra,0xfffff
    8000247c:	86e080e7          	jalr	-1938(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002480:	19848493          	add	s1,s1,408
    80002484:	ff3491e3          	bne	s1,s3,80002466 <kill+0x20>
  }
  return -1;
    80002488:	557d                	li	a0,-1
    8000248a:	a829                	j	800024a4 <kill+0x5e>
      p->killed = 1;
    8000248c:	4785                	li	a5,1
    8000248e:	ccbc                	sw	a5,88(s1)
      if(p->state == SLEEPING){
    80002490:	44b8                	lw	a4,72(s1)
    80002492:	4789                	li	a5,2
    80002494:	00f70f63          	beq	a4,a5,800024b2 <kill+0x6c>
      release(&p->lock);
    80002498:	8526                	mv	a0,s1
    8000249a:	fffff097          	auipc	ra,0xfffff
    8000249e:	84c080e7          	jalr	-1972(ra) # 80000ce6 <release>
      return 0;
    800024a2:	4501                	li	a0,0
}
    800024a4:	70a2                	ld	ra,40(sp)
    800024a6:	7402                	ld	s0,32(sp)
    800024a8:	64e2                	ld	s1,24(sp)
    800024aa:	6942                	ld	s2,16(sp)
    800024ac:	69a2                	ld	s3,8(sp)
    800024ae:	6145                	add	sp,sp,48
    800024b0:	8082                	ret
        p->state = RUNNABLE;
    800024b2:	478d                	li	a5,3
    800024b4:	c4bc                	sw	a5,72(s1)
    800024b6:	b7cd                	j	80002498 <kill+0x52>

00000000800024b8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024b8:	7179                	add	sp,sp,-48
    800024ba:	f406                	sd	ra,40(sp)
    800024bc:	f022                	sd	s0,32(sp)
    800024be:	ec26                	sd	s1,24(sp)
    800024c0:	e84a                	sd	s2,16(sp)
    800024c2:	e44e                	sd	s3,8(sp)
    800024c4:	e052                	sd	s4,0(sp)
    800024c6:	1800                	add	s0,sp,48
    800024c8:	84aa                	mv	s1,a0
    800024ca:	892e                	mv	s2,a1
    800024cc:	89b2                	mv	s3,a2
    800024ce:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024d0:	fffff097          	auipc	ra,0xfffff
    800024d4:	554080e7          	jalr	1364(ra) # 80001a24 <myproc>
  if(user_dst){
    800024d8:	c08d                	beqz	s1,800024fa <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024da:	86d2                	mv	a3,s4
    800024dc:	864e                	mv	a2,s3
    800024de:	85ca                	mv	a1,s2
    800024e0:	6148                	ld	a0,128(a0)
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	1ea080e7          	jalr	490(ra) # 800016cc <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024ea:	70a2                	ld	ra,40(sp)
    800024ec:	7402                	ld	s0,32(sp)
    800024ee:	64e2                	ld	s1,24(sp)
    800024f0:	6942                	ld	s2,16(sp)
    800024f2:	69a2                	ld	s3,8(sp)
    800024f4:	6a02                	ld	s4,0(sp)
    800024f6:	6145                	add	sp,sp,48
    800024f8:	8082                	ret
    memmove((char *)dst, src, len);
    800024fa:	000a061b          	sext.w	a2,s4
    800024fe:	85ce                	mv	a1,s3
    80002500:	854a                	mv	a0,s2
    80002502:	fffff097          	auipc	ra,0xfffff
    80002506:	888080e7          	jalr	-1912(ra) # 80000d8a <memmove>
    return 0;
    8000250a:	8526                	mv	a0,s1
    8000250c:	bff9                	j	800024ea <either_copyout+0x32>

000000008000250e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000250e:	7179                	add	sp,sp,-48
    80002510:	f406                	sd	ra,40(sp)
    80002512:	f022                	sd	s0,32(sp)
    80002514:	ec26                	sd	s1,24(sp)
    80002516:	e84a                	sd	s2,16(sp)
    80002518:	e44e                	sd	s3,8(sp)
    8000251a:	e052                	sd	s4,0(sp)
    8000251c:	1800                	add	s0,sp,48
    8000251e:	892a                	mv	s2,a0
    80002520:	84ae                	mv	s1,a1
    80002522:	89b2                	mv	s3,a2
    80002524:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002526:	fffff097          	auipc	ra,0xfffff
    8000252a:	4fe080e7          	jalr	1278(ra) # 80001a24 <myproc>
  if(user_src){
    8000252e:	c08d                	beqz	s1,80002550 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002530:	86d2                	mv	a3,s4
    80002532:	864e                	mv	a2,s3
    80002534:	85ca                	mv	a1,s2
    80002536:	6148                	ld	a0,128(a0)
    80002538:	fffff097          	auipc	ra,0xfffff
    8000253c:	220080e7          	jalr	544(ra) # 80001758 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002540:	70a2                	ld	ra,40(sp)
    80002542:	7402                	ld	s0,32(sp)
    80002544:	64e2                	ld	s1,24(sp)
    80002546:	6942                	ld	s2,16(sp)
    80002548:	69a2                	ld	s3,8(sp)
    8000254a:	6a02                	ld	s4,0(sp)
    8000254c:	6145                	add	sp,sp,48
    8000254e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002550:	000a061b          	sext.w	a2,s4
    80002554:	85ce                	mv	a1,s3
    80002556:	854a                	mv	a0,s2
    80002558:	fffff097          	auipc	ra,0xfffff
    8000255c:	832080e7          	jalr	-1998(ra) # 80000d8a <memmove>
    return 0;
    80002560:	8526                	mv	a0,s1
    80002562:	bff9                	j	80002540 <either_copyin+0x32>

0000000080002564 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002564:	715d                	add	sp,sp,-80
    80002566:	e486                	sd	ra,72(sp)
    80002568:	e0a2                	sd	s0,64(sp)
    8000256a:	fc26                	sd	s1,56(sp)
    8000256c:	f84a                	sd	s2,48(sp)
    8000256e:	f44e                	sd	s3,40(sp)
    80002570:	f052                	sd	s4,32(sp)
    80002572:	ec56                	sd	s5,24(sp)
    80002574:	e85a                	sd	s6,16(sp)
    80002576:	e45e                	sd	s7,8(sp)
    80002578:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000257a:	00006517          	auipc	a0,0x6
    8000257e:	a9650513          	add	a0,a0,-1386 # 80008010 <etext+0x10>
    80002582:	ffffe097          	auipc	ra,0xffffe
    80002586:	022080e7          	jalr	34(ra) # 800005a4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000258a:	0000f497          	auipc	s1,0xf
    8000258e:	2ce48493          	add	s1,s1,718 # 80011858 <proc+0x188>
    80002592:	00016917          	auipc	s2,0x16
    80002596:	8c690913          	add	s2,s2,-1850 # 80017e58 <bcache+0x170>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000259a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000259c:	00006997          	auipc	s3,0x6
    800025a0:	cc498993          	add	s3,s3,-828 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    800025a4:	00006a97          	auipc	s5,0x6
    800025a8:	cc4a8a93          	add	s5,s5,-828 # 80008268 <etext+0x268>
    printf("\n");
    800025ac:	00006a17          	auipc	s4,0x6
    800025b0:	a64a0a13          	add	s4,s4,-1436 # 80008010 <etext+0x10>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025b4:	00006b97          	auipc	s7,0x6
    800025b8:	15cb8b93          	add	s7,s7,348 # 80008710 <states.0>
    800025bc:	a00d                	j	800025de <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025be:	ed86a583          	lw	a1,-296(a3)
    800025c2:	8556                	mv	a0,s5
    800025c4:	ffffe097          	auipc	ra,0xffffe
    800025c8:	fe0080e7          	jalr	-32(ra) # 800005a4 <printf>
    printf("\n");
    800025cc:	8552                	mv	a0,s4
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	fd6080e7          	jalr	-42(ra) # 800005a4 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025d6:	19848493          	add	s1,s1,408
    800025da:	03248263          	beq	s1,s2,800025fe <procdump+0x9a>
    if(p->state == UNUSED)
    800025de:	86a6                	mv	a3,s1
    800025e0:	ec04a783          	lw	a5,-320(s1)
    800025e4:	dbed                	beqz	a5,800025d6 <procdump+0x72>
      state = "???";
    800025e6:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025e8:	fcfb6be3          	bltu	s6,a5,800025be <procdump+0x5a>
    800025ec:	02079713          	sll	a4,a5,0x20
    800025f0:	01d75793          	srl	a5,a4,0x1d
    800025f4:	97de                	add	a5,a5,s7
    800025f6:	6390                	ld	a2,0(a5)
    800025f8:	f279                	bnez	a2,800025be <procdump+0x5a>
      state = "???";
    800025fa:	864e                	mv	a2,s3
    800025fc:	b7c9                	j	800025be <procdump+0x5a>
  }
}
    800025fe:	60a6                	ld	ra,72(sp)
    80002600:	6406                	ld	s0,64(sp)
    80002602:	74e2                	ld	s1,56(sp)
    80002604:	7942                	ld	s2,48(sp)
    80002606:	79a2                	ld	s3,40(sp)
    80002608:	7a02                	ld	s4,32(sp)
    8000260a:	6ae2                	ld	s5,24(sp)
    8000260c:	6b42                	ld	s6,16(sp)
    8000260e:	6ba2                	ld	s7,8(sp)
    80002610:	6161                	add	sp,sp,80
    80002612:	8082                	ret

0000000080002614 <update_timings>:

// Lab 7
void
update_timings(void)
{
    80002614:	7139                	add	sp,sp,-64
    80002616:	fc06                	sd	ra,56(sp)
    80002618:	f822                	sd	s0,48(sp)
    8000261a:	f426                	sd	s1,40(sp)
    8000261c:	f04a                	sd	s2,32(sp)
    8000261e:	ec4e                	sd	s3,24(sp)
    80002620:	e852                	sd	s4,16(sp)
    80002622:	e456                	sd	s5,8(sp)
    80002624:	0080                	add	s0,sp,64
  struct proc* p;
  for(p = proc; p < &proc[NPROC]; p++)
    80002626:	0000f497          	auipc	s1,0xf
    8000262a:	0aa48493          	add	s1,s1,170 # 800116d0 <proc>
    acquire(&p->lock);
    if(p->state == UNUSED){
      release(&p->lock);
      continue; // Skip UNUSED processes
    }
    if(p->state == RUNNING){
    8000262e:	4991                	li	s3,4
      p->run_time += 1;
    }
    else if(p->state == RUNNABLE) {
    80002630:	4a0d                	li	s4,3
      p->wait_time += 1;
    } else if(p->state == SLEEPING){
    80002632:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++)
    80002634:	00015917          	auipc	s2,0x15
    80002638:	69c90913          	add	s2,s2,1692 # 80017cd0 <tickslock>
    8000263c:	a01d                	j	80002662 <update_timings+0x4e>
      release(&p->lock);
    8000263e:	8526                	mv	a0,s1
    80002640:	ffffe097          	auipc	ra,0xffffe
    80002644:	6a6080e7          	jalr	1702(ra) # 80000ce6 <release>
      continue; // Skip UNUSED processes
    80002648:	a809                	j	8000265a <update_timings+0x46>
      p->run_time += 1;
    8000264a:	749c                	ld	a5,40(s1)
    8000264c:	0785                	add	a5,a5,1
    8000264e:	f49c                	sd	a5,40(s1)
      p->sleep_time += 1;
    }
    release(&p->lock);
    80002650:	8526                	mv	a0,s1
    80002652:	ffffe097          	auipc	ra,0xffffe
    80002656:	694080e7          	jalr	1684(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++)
    8000265a:	19848493          	add	s1,s1,408
    8000265e:	03248763          	beq	s1,s2,8000268c <update_timings+0x78>
    acquire(&p->lock);
    80002662:	8526                	mv	a0,s1
    80002664:	ffffe097          	auipc	ra,0xffffe
    80002668:	5ce080e7          	jalr	1486(ra) # 80000c32 <acquire>
    if(p->state == UNUSED){
    8000266c:	44bc                	lw	a5,72(s1)
    8000266e:	dbe1                	beqz	a5,8000263e <update_timings+0x2a>
    if(p->state == RUNNING){
    80002670:	fd378de3          	beq	a5,s3,8000264a <update_timings+0x36>
    else if(p->state == RUNNABLE) {
    80002674:	01478863          	beq	a5,s4,80002684 <update_timings+0x70>
    } else if(p->state == SLEEPING){
    80002678:	fd579ce3          	bne	a5,s5,80002650 <update_timings+0x3c>
      p->sleep_time += 1;
    8000267c:	7c9c                	ld	a5,56(s1)
    8000267e:	0785                	add	a5,a5,1
    80002680:	fc9c                	sd	a5,56(s1)
    80002682:	b7f9                	j	80002650 <update_timings+0x3c>
      p->wait_time += 1;
    80002684:	789c                	ld	a5,48(s1)
    80002686:	0785                	add	a5,a5,1
    80002688:	f89c                	sd	a5,48(s1)
    8000268a:	b7d9                	j	80002650 <update_timings+0x3c>
  }
}
    8000268c:	70e2                	ld	ra,56(sp)
    8000268e:	7442                	ld	s0,48(sp)
    80002690:	74a2                	ld	s1,40(sp)
    80002692:	7902                	ld	s2,32(sp)
    80002694:	69e2                	ld	s3,24(sp)
    80002696:	6a42                	ld	s4,16(sp)
    80002698:	6aa2                	ld	s5,8(sp)
    8000269a:	6121                	add	sp,sp,64
    8000269c:	8082                	ret

000000008000269e <wait2>:

// Lab 7
int
wait2(int *rtime, int *wtime, int *stime, int *status)
{
    8000269e:	7159                	add	sp,sp,-112
    800026a0:	f486                	sd	ra,104(sp)
    800026a2:	f0a2                	sd	s0,96(sp)
    800026a4:	eca6                	sd	s1,88(sp)
    800026a6:	e8ca                	sd	s2,80(sp)
    800026a8:	e4ce                	sd	s3,72(sp)
    800026aa:	e0d2                	sd	s4,64(sp)
    800026ac:	fc56                	sd	s5,56(sp)
    800026ae:	f85a                	sd	s6,48(sp)
    800026b0:	f45e                	sd	s7,40(sp)
    800026b2:	f062                	sd	s8,32(sp)
    800026b4:	ec66                	sd	s9,24(sp)
    800026b6:	e86a                	sd	s10,16(sp)
    800026b8:	e46e                	sd	s11,8(sp)
    800026ba:	1880                	add	s0,sp,112
    800026bc:	8caa                	mv	s9,a0
    800026be:	8c2e                	mv	s8,a1
    800026c0:	8bb2                	mv	s7,a2
    800026c2:	8d36                	mv	s10,a3
  struct proc *p;
  int havekids, pid;

  acquire(&wait_lock);
    800026c4:	0000f517          	auipc	a0,0xf
    800026c8:	bf450513          	add	a0,a0,-1036 # 800112b8 <wait_lock>
    800026cc:	ffffe097          	auipc	ra,0xffffe
    800026d0:	566080e7          	jalr	1382(ra) # 80000c32 <acquire>

  for (;;) {
    // Scan through table looking for exited children.
    havekids = 0;
    800026d4:	4d81                	li	s11,0
    for (p = proc; p < &proc[NPROC]; p++) {
      if (p->parent != myproc())
        continue;
      havekids = 1;
      if (p->state == ZOMBIE) {
    800026d6:	4a95                	li	s5,5
      havekids = 1;
    800026d8:	4b05                	li	s6,1
    for (p = proc; p < &proc[NPROC]; p++) {
    800026da:	00015997          	auipc	s3,0x15
    800026de:	5f698993          	add	s3,s3,1526 # 80017cd0 <tickslock>
    havekids = 0;
    800026e2:	8a6e                	mv	s4,s11
    for (p = proc; p < &proc[NPROC]; p++) {
    800026e4:	0000f497          	auipc	s1,0xf
    800026e8:	fec48493          	add	s1,s1,-20 # 800116d0 <proc>
    800026ec:	a8ad                	j	80002766 <wait2+0xc8>
        // Found one.
        pid = p->pid;
    800026ee:	0604a903          	lw	s2,96(s1)
        if (status != 0) {
    800026f2:	000d0563          	beqz	s10,800026fc <wait2+0x5e>
          *status = p->xstate;
    800026f6:	4cfc                	lw	a5,92(s1)
    800026f8:	00fd2023          	sw	a5,0(s10)
        }

        if (rtime != 0) {
    800026fc:	000c8a63          	beqz	s9,80002710 <wait2+0x72>
          // Calculate runtime as ticks - create_time
          *rtime = ticks - p->create_time;
    80002700:	7098                	ld	a4,32(s1)
    80002702:	00007797          	auipc	a5,0x7
    80002706:	92e7a783          	lw	a5,-1746(a5) # 80009030 <ticks>
    8000270a:	9f99                	subw	a5,a5,a4
    8000270c:	00fca023          	sw	a5,0(s9)
        }
        if (wtime != 0) {
    80002710:	000c0563          	beqz	s8,8000271a <wait2+0x7c>
          // Calculate waittime as wait_time
          *wtime = p->wait_time;
    80002714:	789c                	ld	a5,48(s1)
    80002716:	00fc2023          	sw	a5,0(s8)
        }
        if (stime != 0) {
    8000271a:	000b8563          	beqz	s7,80002724 <wait2+0x86>
          // Calculate sleeptime as sleep_time
          *stime = p->sleep_time;
    8000271e:	7c9c                	ld	a5,56(s1)
    80002720:	00fba023          	sw	a5,0(s7)
        }

        // Remove the zombie process from the process table.
        freeproc(p);
    80002724:	8526                	mv	a0,s1
    80002726:	fffff097          	auipc	ra,0xfffff
    8000272a:	4b0080e7          	jalr	1200(ra) # 80001bd6 <freeproc>
        release(&wait_lock);
    8000272e:	0000f517          	auipc	a0,0xf
    80002732:	b8a50513          	add	a0,a0,-1142 # 800112b8 <wait_lock>
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	5b0080e7          	jalr	1456(ra) # 80000ce6 <release>
    }

    // Wait for children to exit.
    sleep(myproc(), &wait_lock);  //DOC: wait-sleep
  }
}
    8000273e:	854a                	mv	a0,s2
    80002740:	70a6                	ld	ra,104(sp)
    80002742:	7406                	ld	s0,96(sp)
    80002744:	64e6                	ld	s1,88(sp)
    80002746:	6946                	ld	s2,80(sp)
    80002748:	69a6                	ld	s3,72(sp)
    8000274a:	6a06                	ld	s4,64(sp)
    8000274c:	7ae2                	ld	s5,56(sp)
    8000274e:	7b42                	ld	s6,48(sp)
    80002750:	7ba2                	ld	s7,40(sp)
    80002752:	7c02                	ld	s8,32(sp)
    80002754:	6ce2                	ld	s9,24(sp)
    80002756:	6d42                	ld	s10,16(sp)
    80002758:	6da2                	ld	s11,8(sp)
    8000275a:	6165                	add	sp,sp,112
    8000275c:	8082                	ret
    for (p = proc; p < &proc[NPROC]; p++) {
    8000275e:	19848493          	add	s1,s1,408
    80002762:	01348f63          	beq	s1,s3,80002780 <wait2+0xe2>
      if (p->parent != myproc())
    80002766:	0684b903          	ld	s2,104(s1)
    8000276a:	fffff097          	auipc	ra,0xfffff
    8000276e:	2ba080e7          	jalr	698(ra) # 80001a24 <myproc>
    80002772:	fea916e3          	bne	s2,a0,8000275e <wait2+0xc0>
      if (p->state == ZOMBIE) {
    80002776:	44bc                	lw	a5,72(s1)
    80002778:	f7578be3          	beq	a5,s5,800026ee <wait2+0x50>
      havekids = 1;
    8000277c:	8a5a                	mv	s4,s6
    8000277e:	b7c5                	j	8000275e <wait2+0xc0>
    if (!havekids || myproc()->killed) {
    80002780:	020a0563          	beqz	s4,800027aa <wait2+0x10c>
    80002784:	fffff097          	auipc	ra,0xfffff
    80002788:	2a0080e7          	jalr	672(ra) # 80001a24 <myproc>
    8000278c:	4d3c                	lw	a5,88(a0)
    8000278e:	ef91                	bnez	a5,800027aa <wait2+0x10c>
    sleep(myproc(), &wait_lock);  //DOC: wait-sleep
    80002790:	fffff097          	auipc	ra,0xfffff
    80002794:	294080e7          	jalr	660(ra) # 80001a24 <myproc>
    80002798:	0000f597          	auipc	a1,0xf
    8000279c:	b2058593          	add	a1,a1,-1248 # 800112b8 <wait_lock>
    800027a0:	00000097          	auipc	ra,0x0
    800027a4:	968080e7          	jalr	-1688(ra) # 80002108 <sleep>
    havekids = 0;
    800027a8:	bf2d                	j	800026e2 <wait2+0x44>
      release(&wait_lock);
    800027aa:	0000f517          	auipc	a0,0xf
    800027ae:	b0e50513          	add	a0,a0,-1266 # 800112b8 <wait_lock>
    800027b2:	ffffe097          	auipc	ra,0xffffe
    800027b6:	534080e7          	jalr	1332(ra) # 80000ce6 <release>
      return -1;
    800027ba:	597d                	li	s2,-1
    800027bc:	b749                	j	8000273e <wait2+0xa0>

00000000800027be <swtch>:
    800027be:	00153023          	sd	ra,0(a0)
    800027c2:	00253423          	sd	sp,8(a0)
    800027c6:	e900                	sd	s0,16(a0)
    800027c8:	ed04                	sd	s1,24(a0)
    800027ca:	03253023          	sd	s2,32(a0)
    800027ce:	03353423          	sd	s3,40(a0)
    800027d2:	03453823          	sd	s4,48(a0)
    800027d6:	03553c23          	sd	s5,56(a0)
    800027da:	05653023          	sd	s6,64(a0)
    800027de:	05753423          	sd	s7,72(a0)
    800027e2:	05853823          	sd	s8,80(a0)
    800027e6:	05953c23          	sd	s9,88(a0)
    800027ea:	07a53023          	sd	s10,96(a0)
    800027ee:	07b53423          	sd	s11,104(a0)
    800027f2:	0005b083          	ld	ra,0(a1)
    800027f6:	0085b103          	ld	sp,8(a1)
    800027fa:	6980                	ld	s0,16(a1)
    800027fc:	6d84                	ld	s1,24(a1)
    800027fe:	0205b903          	ld	s2,32(a1)
    80002802:	0285b983          	ld	s3,40(a1)
    80002806:	0305ba03          	ld	s4,48(a1)
    8000280a:	0385ba83          	ld	s5,56(a1)
    8000280e:	0405bb03          	ld	s6,64(a1)
    80002812:	0485bb83          	ld	s7,72(a1)
    80002816:	0505bc03          	ld	s8,80(a1)
    8000281a:	0585bc83          	ld	s9,88(a1)
    8000281e:	0605bd03          	ld	s10,96(a1)
    80002822:	0685bd83          	ld	s11,104(a1)
    80002826:	8082                	ret

0000000080002828 <trapinit>:
    80002828:	1141                	add	sp,sp,-16
    8000282a:	e406                	sd	ra,8(sp)
    8000282c:	e022                	sd	s0,0(sp)
    8000282e:	0800                	add	s0,sp,16
    80002830:	00006597          	auipc	a1,0x6
    80002834:	a7058593          	add	a1,a1,-1424 # 800082a0 <etext+0x2a0>
    80002838:	00015517          	auipc	a0,0x15
    8000283c:	49850513          	add	a0,a0,1176 # 80017cd0 <tickslock>
    80002840:	ffffe097          	auipc	ra,0xffffe
    80002844:	362080e7          	jalr	866(ra) # 80000ba2 <initlock>
    80002848:	60a2                	ld	ra,8(sp)
    8000284a:	6402                	ld	s0,0(sp)
    8000284c:	0141                	add	sp,sp,16
    8000284e:	8082                	ret

0000000080002850 <trapinithart>:
    80002850:	1141                	add	sp,sp,-16
    80002852:	e422                	sd	s0,8(sp)
    80002854:	0800                	add	s0,sp,16
    80002856:	00003797          	auipc	a5,0x3
    8000285a:	77a78793          	add	a5,a5,1914 # 80005fd0 <kernelvec>
    8000285e:	10579073          	csrw	stvec,a5
    80002862:	6422                	ld	s0,8(sp)
    80002864:	0141                	add	sp,sp,16
    80002866:	8082                	ret

0000000080002868 <usertrapret>:
    80002868:	1141                	add	sp,sp,-16
    8000286a:	e406                	sd	ra,8(sp)
    8000286c:	e022                	sd	s0,0(sp)
    8000286e:	0800                	add	s0,sp,16
    80002870:	fffff097          	auipc	ra,0xfffff
    80002874:	1b4080e7          	jalr	436(ra) # 80001a24 <myproc>
    80002878:	100027f3          	csrr	a5,sstatus
    8000287c:	9bf5                	and	a5,a5,-3
    8000287e:	10079073          	csrw	sstatus,a5
    80002882:	00004697          	auipc	a3,0x4
    80002886:	77e68693          	add	a3,a3,1918 # 80007000 <_trampoline>
    8000288a:	00004717          	auipc	a4,0x4
    8000288e:	77670713          	add	a4,a4,1910 # 80007000 <_trampoline>
    80002892:	8f15                	sub	a4,a4,a3
    80002894:	040007b7          	lui	a5,0x4000
    80002898:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000289a:	07b2                	sll	a5,a5,0xc
    8000289c:	973e                	add	a4,a4,a5
    8000289e:	10571073          	csrw	stvec,a4
    800028a2:	6558                	ld	a4,136(a0)
    800028a4:	18002673          	csrr	a2,satp
    800028a8:	e310                	sd	a2,0(a4)
    800028aa:	6550                	ld	a2,136(a0)
    800028ac:	7938                	ld	a4,112(a0)
    800028ae:	6585                	lui	a1,0x1
    800028b0:	972e                	add	a4,a4,a1
    800028b2:	e618                	sd	a4,8(a2)
    800028b4:	6558                	ld	a4,136(a0)
    800028b6:	00000617          	auipc	a2,0x0
    800028ba:	14e60613          	add	a2,a2,334 # 80002a04 <usertrap>
    800028be:	eb10                	sd	a2,16(a4)
    800028c0:	6558                	ld	a4,136(a0)
    800028c2:	8612                	mv	a2,tp
    800028c4:	f310                	sd	a2,32(a4)
    800028c6:	10002773          	csrr	a4,sstatus
    800028ca:	eff77713          	and	a4,a4,-257
    800028ce:	02076713          	or	a4,a4,32
    800028d2:	10071073          	csrw	sstatus,a4
    800028d6:	6558                	ld	a4,136(a0)
    800028d8:	6f18                	ld	a4,24(a4)
    800028da:	14171073          	csrw	sepc,a4
    800028de:	614c                	ld	a1,128(a0)
    800028e0:	81b1                	srl	a1,a1,0xc
    800028e2:	00004717          	auipc	a4,0x4
    800028e6:	7ae70713          	add	a4,a4,1966 # 80007090 <userret>
    800028ea:	8f15                	sub	a4,a4,a3
    800028ec:	97ba                	add	a5,a5,a4
    800028ee:	577d                	li	a4,-1
    800028f0:	177e                	sll	a4,a4,0x3f
    800028f2:	8dd9                	or	a1,a1,a4
    800028f4:	02000537          	lui	a0,0x2000
    800028f8:	157d                	add	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800028fa:	0536                	sll	a0,a0,0xd
    800028fc:	9782                	jalr	a5
    800028fe:	60a2                	ld	ra,8(sp)
    80002900:	6402                	ld	s0,0(sp)
    80002902:	0141                	add	sp,sp,16
    80002904:	8082                	ret

0000000080002906 <clockintr>:
    80002906:	1101                	add	sp,sp,-32
    80002908:	ec06                	sd	ra,24(sp)
    8000290a:	e822                	sd	s0,16(sp)
    8000290c:	e426                	sd	s1,8(sp)
    8000290e:	e04a                	sd	s2,0(sp)
    80002910:	1000                	add	s0,sp,32
    80002912:	00015917          	auipc	s2,0x15
    80002916:	3be90913          	add	s2,s2,958 # 80017cd0 <tickslock>
    8000291a:	854a                	mv	a0,s2
    8000291c:	ffffe097          	auipc	ra,0xffffe
    80002920:	316080e7          	jalr	790(ra) # 80000c32 <acquire>
    80002924:	00006497          	auipc	s1,0x6
    80002928:	70c48493          	add	s1,s1,1804 # 80009030 <ticks>
    8000292c:	409c                	lw	a5,0(s1)
    8000292e:	2785                	addw	a5,a5,1
    80002930:	c09c                	sw	a5,0(s1)
    80002932:	00000097          	auipc	ra,0x0
    80002936:	ce2080e7          	jalr	-798(ra) # 80002614 <update_timings>
    8000293a:	8526                	mv	a0,s1
    8000293c:	00000097          	auipc	ra,0x0
    80002940:	958080e7          	jalr	-1704(ra) # 80002294 <wakeup>
    80002944:	854a                	mv	a0,s2
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	3a0080e7          	jalr	928(ra) # 80000ce6 <release>
    8000294e:	60e2                	ld	ra,24(sp)
    80002950:	6442                	ld	s0,16(sp)
    80002952:	64a2                	ld	s1,8(sp)
    80002954:	6902                	ld	s2,0(sp)
    80002956:	6105                	add	sp,sp,32
    80002958:	8082                	ret

000000008000295a <devintr>:
    8000295a:	142027f3          	csrr	a5,scause
    8000295e:	4501                	li	a0,0
    80002960:	0a07d163          	bgez	a5,80002a02 <devintr+0xa8>
    80002964:	1101                	add	sp,sp,-32
    80002966:	ec06                	sd	ra,24(sp)
    80002968:	e822                	sd	s0,16(sp)
    8000296a:	1000                	add	s0,sp,32
    8000296c:	0ff7f713          	zext.b	a4,a5
    80002970:	46a5                	li	a3,9
    80002972:	00d70c63          	beq	a4,a3,8000298a <devintr+0x30>
    80002976:	577d                	li	a4,-1
    80002978:	177e                	sll	a4,a4,0x3f
    8000297a:	0705                	add	a4,a4,1
    8000297c:	4501                	li	a0,0
    8000297e:	06e78163          	beq	a5,a4,800029e0 <devintr+0x86>
    80002982:	60e2                	ld	ra,24(sp)
    80002984:	6442                	ld	s0,16(sp)
    80002986:	6105                	add	sp,sp,32
    80002988:	8082                	ret
    8000298a:	e426                	sd	s1,8(sp)
    8000298c:	00003097          	auipc	ra,0x3
    80002990:	750080e7          	jalr	1872(ra) # 800060dc <plic_claim>
    80002994:	84aa                	mv	s1,a0
    80002996:	47a9                	li	a5,10
    80002998:	00f50963          	beq	a0,a5,800029aa <devintr+0x50>
    8000299c:	4785                	li	a5,1
    8000299e:	00f50b63          	beq	a0,a5,800029b4 <devintr+0x5a>
    800029a2:	4505                	li	a0,1
    800029a4:	ec89                	bnez	s1,800029be <devintr+0x64>
    800029a6:	64a2                	ld	s1,8(sp)
    800029a8:	bfe9                	j	80002982 <devintr+0x28>
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	04a080e7          	jalr	74(ra) # 800009f4 <uartintr>
    800029b2:	a839                	j	800029d0 <devintr+0x76>
    800029b4:	00004097          	auipc	ra,0x4
    800029b8:	bfc080e7          	jalr	-1028(ra) # 800065b0 <virtio_disk_intr>
    800029bc:	a811                	j	800029d0 <devintr+0x76>
    800029be:	85a6                	mv	a1,s1
    800029c0:	00006517          	auipc	a0,0x6
    800029c4:	8e850513          	add	a0,a0,-1816 # 800082a8 <etext+0x2a8>
    800029c8:	ffffe097          	auipc	ra,0xffffe
    800029cc:	bdc080e7          	jalr	-1060(ra) # 800005a4 <printf>
    800029d0:	8526                	mv	a0,s1
    800029d2:	00003097          	auipc	ra,0x3
    800029d6:	72e080e7          	jalr	1838(ra) # 80006100 <plic_complete>
    800029da:	4505                	li	a0,1
    800029dc:	64a2                	ld	s1,8(sp)
    800029de:	b755                	j	80002982 <devintr+0x28>
    800029e0:	fffff097          	auipc	ra,0xfffff
    800029e4:	018080e7          	jalr	24(ra) # 800019f8 <cpuid>
    800029e8:	c901                	beqz	a0,800029f8 <devintr+0x9e>
    800029ea:	144027f3          	csrr	a5,sip
    800029ee:	9bf5                	and	a5,a5,-3
    800029f0:	14479073          	csrw	sip,a5
    800029f4:	4509                	li	a0,2
    800029f6:	b771                	j	80002982 <devintr+0x28>
    800029f8:	00000097          	auipc	ra,0x0
    800029fc:	f0e080e7          	jalr	-242(ra) # 80002906 <clockintr>
    80002a00:	b7ed                	j	800029ea <devintr+0x90>
    80002a02:	8082                	ret

0000000080002a04 <usertrap>:
    80002a04:	1101                	add	sp,sp,-32
    80002a06:	ec06                	sd	ra,24(sp)
    80002a08:	e822                	sd	s0,16(sp)
    80002a0a:	e426                	sd	s1,8(sp)
    80002a0c:	e04a                	sd	s2,0(sp)
    80002a0e:	1000                	add	s0,sp,32
    80002a10:	100027f3          	csrr	a5,sstatus
    80002a14:	1007f793          	and	a5,a5,256
    80002a18:	e3ad                	bnez	a5,80002a7a <usertrap+0x76>
    80002a1a:	00003797          	auipc	a5,0x3
    80002a1e:	5b678793          	add	a5,a5,1462 # 80005fd0 <kernelvec>
    80002a22:	10579073          	csrw	stvec,a5
    80002a26:	fffff097          	auipc	ra,0xfffff
    80002a2a:	ffe080e7          	jalr	-2(ra) # 80001a24 <myproc>
    80002a2e:	84aa                	mv	s1,a0
    80002a30:	655c                	ld	a5,136(a0)
    80002a32:	14102773          	csrr	a4,sepc
    80002a36:	ef98                	sd	a4,24(a5)
    80002a38:	14202773          	csrr	a4,scause
    80002a3c:	47a1                	li	a5,8
    80002a3e:	04f71c63          	bne	a4,a5,80002a96 <usertrap+0x92>
    80002a42:	4d3c                	lw	a5,88(a0)
    80002a44:	e3b9                	bnez	a5,80002a8a <usertrap+0x86>
    80002a46:	64d8                	ld	a4,136(s1)
    80002a48:	6f1c                	ld	a5,24(a4)
    80002a4a:	0791                	add	a5,a5,4
    80002a4c:	ef1c                	sd	a5,24(a4)
    80002a4e:	100027f3          	csrr	a5,sstatus
    80002a52:	0027e793          	or	a5,a5,2
    80002a56:	10079073          	csrw	sstatus,a5
    80002a5a:	00000097          	auipc	ra,0x0
    80002a5e:	2e0080e7          	jalr	736(ra) # 80002d3a <syscall>
    80002a62:	4cbc                	lw	a5,88(s1)
    80002a64:	ebc1                	bnez	a5,80002af4 <usertrap+0xf0>
    80002a66:	00000097          	auipc	ra,0x0
    80002a6a:	e02080e7          	jalr	-510(ra) # 80002868 <usertrapret>
    80002a6e:	60e2                	ld	ra,24(sp)
    80002a70:	6442                	ld	s0,16(sp)
    80002a72:	64a2                	ld	s1,8(sp)
    80002a74:	6902                	ld	s2,0(sp)
    80002a76:	6105                	add	sp,sp,32
    80002a78:	8082                	ret
    80002a7a:	00006517          	auipc	a0,0x6
    80002a7e:	84e50513          	add	a0,a0,-1970 # 800082c8 <etext+0x2c8>
    80002a82:	ffffe097          	auipc	ra,0xffffe
    80002a86:	ad8080e7          	jalr	-1320(ra) # 8000055a <panic>
    80002a8a:	557d                	li	a0,-1
    80002a8c:	00000097          	auipc	ra,0x0
    80002a90:	8d8080e7          	jalr	-1832(ra) # 80002364 <exit>
    80002a94:	bf4d                	j	80002a46 <usertrap+0x42>
    80002a96:	00000097          	auipc	ra,0x0
    80002a9a:	ec4080e7          	jalr	-316(ra) # 8000295a <devintr>
    80002a9e:	892a                	mv	s2,a0
    80002aa0:	c501                	beqz	a0,80002aa8 <usertrap+0xa4>
    80002aa2:	4cbc                	lw	a5,88(s1)
    80002aa4:	c3a1                	beqz	a5,80002ae4 <usertrap+0xe0>
    80002aa6:	a815                	j	80002ada <usertrap+0xd6>
    80002aa8:	142025f3          	csrr	a1,scause
    80002aac:	50b0                	lw	a2,96(s1)
    80002aae:	00006517          	auipc	a0,0x6
    80002ab2:	83a50513          	add	a0,a0,-1990 # 800082e8 <etext+0x2e8>
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	aee080e7          	jalr	-1298(ra) # 800005a4 <printf>
    80002abe:	141025f3          	csrr	a1,sepc
    80002ac2:	14302673          	csrr	a2,stval
    80002ac6:	00006517          	auipc	a0,0x6
    80002aca:	85250513          	add	a0,a0,-1966 # 80008318 <etext+0x318>
    80002ace:	ffffe097          	auipc	ra,0xffffe
    80002ad2:	ad6080e7          	jalr	-1322(ra) # 800005a4 <printf>
    80002ad6:	4785                	li	a5,1
    80002ad8:	ccbc                	sw	a5,88(s1)
    80002ada:	557d                	li	a0,-1
    80002adc:	00000097          	auipc	ra,0x0
    80002ae0:	888080e7          	jalr	-1912(ra) # 80002364 <exit>
    80002ae4:	4789                	li	a5,2
    80002ae6:	f8f910e3          	bne	s2,a5,80002a66 <usertrap+0x62>
    80002aea:	fffff097          	auipc	ra,0xfffff
    80002aee:	5e2080e7          	jalr	1506(ra) # 800020cc <yield>
    80002af2:	bf95                	j	80002a66 <usertrap+0x62>
    80002af4:	4901                	li	s2,0
    80002af6:	b7d5                	j	80002ada <usertrap+0xd6>

0000000080002af8 <kerneltrap>:
    80002af8:	7179                	add	sp,sp,-48
    80002afa:	f406                	sd	ra,40(sp)
    80002afc:	f022                	sd	s0,32(sp)
    80002afe:	ec26                	sd	s1,24(sp)
    80002b00:	e84a                	sd	s2,16(sp)
    80002b02:	e44e                	sd	s3,8(sp)
    80002b04:	1800                	add	s0,sp,48
    80002b06:	14102973          	csrr	s2,sepc
    80002b0a:	100024f3          	csrr	s1,sstatus
    80002b0e:	142029f3          	csrr	s3,scause
    80002b12:	1004f793          	and	a5,s1,256
    80002b16:	cb85                	beqz	a5,80002b46 <kerneltrap+0x4e>
    80002b18:	100027f3          	csrr	a5,sstatus
    80002b1c:	8b89                	and	a5,a5,2
    80002b1e:	ef85                	bnez	a5,80002b56 <kerneltrap+0x5e>
    80002b20:	00000097          	auipc	ra,0x0
    80002b24:	e3a080e7          	jalr	-454(ra) # 8000295a <devintr>
    80002b28:	cd1d                	beqz	a0,80002b66 <kerneltrap+0x6e>
    80002b2a:	4789                	li	a5,2
    80002b2c:	06f50a63          	beq	a0,a5,80002ba0 <kerneltrap+0xa8>
    80002b30:	14191073          	csrw	sepc,s2
    80002b34:	10049073          	csrw	sstatus,s1
    80002b38:	70a2                	ld	ra,40(sp)
    80002b3a:	7402                	ld	s0,32(sp)
    80002b3c:	64e2                	ld	s1,24(sp)
    80002b3e:	6942                	ld	s2,16(sp)
    80002b40:	69a2                	ld	s3,8(sp)
    80002b42:	6145                	add	sp,sp,48
    80002b44:	8082                	ret
    80002b46:	00005517          	auipc	a0,0x5
    80002b4a:	7f250513          	add	a0,a0,2034 # 80008338 <etext+0x338>
    80002b4e:	ffffe097          	auipc	ra,0xffffe
    80002b52:	a0c080e7          	jalr	-1524(ra) # 8000055a <panic>
    80002b56:	00006517          	auipc	a0,0x6
    80002b5a:	80a50513          	add	a0,a0,-2038 # 80008360 <etext+0x360>
    80002b5e:	ffffe097          	auipc	ra,0xffffe
    80002b62:	9fc080e7          	jalr	-1540(ra) # 8000055a <panic>
    80002b66:	85ce                	mv	a1,s3
    80002b68:	00006517          	auipc	a0,0x6
    80002b6c:	81850513          	add	a0,a0,-2024 # 80008380 <etext+0x380>
    80002b70:	ffffe097          	auipc	ra,0xffffe
    80002b74:	a34080e7          	jalr	-1484(ra) # 800005a4 <printf>
    80002b78:	141025f3          	csrr	a1,sepc
    80002b7c:	14302673          	csrr	a2,stval
    80002b80:	00006517          	auipc	a0,0x6
    80002b84:	81050513          	add	a0,a0,-2032 # 80008390 <etext+0x390>
    80002b88:	ffffe097          	auipc	ra,0xffffe
    80002b8c:	a1c080e7          	jalr	-1508(ra) # 800005a4 <printf>
    80002b90:	00006517          	auipc	a0,0x6
    80002b94:	81850513          	add	a0,a0,-2024 # 800083a8 <etext+0x3a8>
    80002b98:	ffffe097          	auipc	ra,0xffffe
    80002b9c:	9c2080e7          	jalr	-1598(ra) # 8000055a <panic>
    80002ba0:	fffff097          	auipc	ra,0xfffff
    80002ba4:	e84080e7          	jalr	-380(ra) # 80001a24 <myproc>
    80002ba8:	d541                	beqz	a0,80002b30 <kerneltrap+0x38>
    80002baa:	fffff097          	auipc	ra,0xfffff
    80002bae:	e7a080e7          	jalr	-390(ra) # 80001a24 <myproc>
    80002bb2:	4538                	lw	a4,72(a0)
    80002bb4:	4791                	li	a5,4
    80002bb6:	f6f71de3          	bne	a4,a5,80002b30 <kerneltrap+0x38>
    80002bba:	fffff097          	auipc	ra,0xfffff
    80002bbe:	512080e7          	jalr	1298(ra) # 800020cc <yield>
    80002bc2:	b7bd                	j	80002b30 <kerneltrap+0x38>

0000000080002bc4 <argraw>:
    80002bc4:	1101                	add	sp,sp,-32
    80002bc6:	ec06                	sd	ra,24(sp)
    80002bc8:	e822                	sd	s0,16(sp)
    80002bca:	e426                	sd	s1,8(sp)
    80002bcc:	1000                	add	s0,sp,32
    80002bce:	84aa                	mv	s1,a0
    80002bd0:	fffff097          	auipc	ra,0xfffff
    80002bd4:	e54080e7          	jalr	-428(ra) # 80001a24 <myproc>
    80002bd8:	4795                	li	a5,5
    80002bda:	0497e163          	bltu	a5,s1,80002c1c <argraw+0x58>
    80002bde:	048a                	sll	s1,s1,0x2
    80002be0:	00006717          	auipc	a4,0x6
    80002be4:	b6070713          	add	a4,a4,-1184 # 80008740 <states.0+0x30>
    80002be8:	94ba                	add	s1,s1,a4
    80002bea:	409c                	lw	a5,0(s1)
    80002bec:	97ba                	add	a5,a5,a4
    80002bee:	8782                	jr	a5
    80002bf0:	655c                	ld	a5,136(a0)
    80002bf2:	7ba8                	ld	a0,112(a5)
    80002bf4:	60e2                	ld	ra,24(sp)
    80002bf6:	6442                	ld	s0,16(sp)
    80002bf8:	64a2                	ld	s1,8(sp)
    80002bfa:	6105                	add	sp,sp,32
    80002bfc:	8082                	ret
    80002bfe:	655c                	ld	a5,136(a0)
    80002c00:	7fa8                	ld	a0,120(a5)
    80002c02:	bfcd                	j	80002bf4 <argraw+0x30>
    80002c04:	655c                	ld	a5,136(a0)
    80002c06:	63c8                	ld	a0,128(a5)
    80002c08:	b7f5                	j	80002bf4 <argraw+0x30>
    80002c0a:	655c                	ld	a5,136(a0)
    80002c0c:	67c8                	ld	a0,136(a5)
    80002c0e:	b7dd                	j	80002bf4 <argraw+0x30>
    80002c10:	655c                	ld	a5,136(a0)
    80002c12:	6bc8                	ld	a0,144(a5)
    80002c14:	b7c5                	j	80002bf4 <argraw+0x30>
    80002c16:	655c                	ld	a5,136(a0)
    80002c18:	6fc8                	ld	a0,152(a5)
    80002c1a:	bfe9                	j	80002bf4 <argraw+0x30>
    80002c1c:	00005517          	auipc	a0,0x5
    80002c20:	79c50513          	add	a0,a0,1948 # 800083b8 <etext+0x3b8>
    80002c24:	ffffe097          	auipc	ra,0xffffe
    80002c28:	936080e7          	jalr	-1738(ra) # 8000055a <panic>

0000000080002c2c <fetchaddr>:
    80002c2c:	1101                	add	sp,sp,-32
    80002c2e:	ec06                	sd	ra,24(sp)
    80002c30:	e822                	sd	s0,16(sp)
    80002c32:	e426                	sd	s1,8(sp)
    80002c34:	e04a                	sd	s2,0(sp)
    80002c36:	1000                	add	s0,sp,32
    80002c38:	84aa                	mv	s1,a0
    80002c3a:	892e                	mv	s2,a1
    80002c3c:	fffff097          	auipc	ra,0xfffff
    80002c40:	de8080e7          	jalr	-536(ra) # 80001a24 <myproc>
    80002c44:	7d3c                	ld	a5,120(a0)
    80002c46:	02f4f863          	bgeu	s1,a5,80002c76 <fetchaddr+0x4a>
    80002c4a:	00848713          	add	a4,s1,8
    80002c4e:	02e7e663          	bltu	a5,a4,80002c7a <fetchaddr+0x4e>
    80002c52:	46a1                	li	a3,8
    80002c54:	8626                	mv	a2,s1
    80002c56:	85ca                	mv	a1,s2
    80002c58:	6148                	ld	a0,128(a0)
    80002c5a:	fffff097          	auipc	ra,0xfffff
    80002c5e:	afe080e7          	jalr	-1282(ra) # 80001758 <copyin>
    80002c62:	00a03533          	snez	a0,a0
    80002c66:	40a00533          	neg	a0,a0
    80002c6a:	60e2                	ld	ra,24(sp)
    80002c6c:	6442                	ld	s0,16(sp)
    80002c6e:	64a2                	ld	s1,8(sp)
    80002c70:	6902                	ld	s2,0(sp)
    80002c72:	6105                	add	sp,sp,32
    80002c74:	8082                	ret
    80002c76:	557d                	li	a0,-1
    80002c78:	bfcd                	j	80002c6a <fetchaddr+0x3e>
    80002c7a:	557d                	li	a0,-1
    80002c7c:	b7fd                	j	80002c6a <fetchaddr+0x3e>

0000000080002c7e <fetchstr>:
    80002c7e:	7179                	add	sp,sp,-48
    80002c80:	f406                	sd	ra,40(sp)
    80002c82:	f022                	sd	s0,32(sp)
    80002c84:	ec26                	sd	s1,24(sp)
    80002c86:	e84a                	sd	s2,16(sp)
    80002c88:	e44e                	sd	s3,8(sp)
    80002c8a:	1800                	add	s0,sp,48
    80002c8c:	892a                	mv	s2,a0
    80002c8e:	84ae                	mv	s1,a1
    80002c90:	89b2                	mv	s3,a2
    80002c92:	fffff097          	auipc	ra,0xfffff
    80002c96:	d92080e7          	jalr	-622(ra) # 80001a24 <myproc>
    80002c9a:	86ce                	mv	a3,s3
    80002c9c:	864a                	mv	a2,s2
    80002c9e:	85a6                	mv	a1,s1
    80002ca0:	6148                	ld	a0,128(a0)
    80002ca2:	fffff097          	auipc	ra,0xfffff
    80002ca6:	b44080e7          	jalr	-1212(ra) # 800017e6 <copyinstr>
    80002caa:	00054763          	bltz	a0,80002cb8 <fetchstr+0x3a>
    80002cae:	8526                	mv	a0,s1
    80002cb0:	ffffe097          	auipc	ra,0xffffe
    80002cb4:	1f2080e7          	jalr	498(ra) # 80000ea2 <strlen>
    80002cb8:	70a2                	ld	ra,40(sp)
    80002cba:	7402                	ld	s0,32(sp)
    80002cbc:	64e2                	ld	s1,24(sp)
    80002cbe:	6942                	ld	s2,16(sp)
    80002cc0:	69a2                	ld	s3,8(sp)
    80002cc2:	6145                	add	sp,sp,48
    80002cc4:	8082                	ret

0000000080002cc6 <argint>:
    80002cc6:	1101                	add	sp,sp,-32
    80002cc8:	ec06                	sd	ra,24(sp)
    80002cca:	e822                	sd	s0,16(sp)
    80002ccc:	e426                	sd	s1,8(sp)
    80002cce:	1000                	add	s0,sp,32
    80002cd0:	84ae                	mv	s1,a1
    80002cd2:	00000097          	auipc	ra,0x0
    80002cd6:	ef2080e7          	jalr	-270(ra) # 80002bc4 <argraw>
    80002cda:	c088                	sw	a0,0(s1)
    80002cdc:	4501                	li	a0,0
    80002cde:	60e2                	ld	ra,24(sp)
    80002ce0:	6442                	ld	s0,16(sp)
    80002ce2:	64a2                	ld	s1,8(sp)
    80002ce4:	6105                	add	sp,sp,32
    80002ce6:	8082                	ret

0000000080002ce8 <argaddr>:
    80002ce8:	1101                	add	sp,sp,-32
    80002cea:	ec06                	sd	ra,24(sp)
    80002cec:	e822                	sd	s0,16(sp)
    80002cee:	e426                	sd	s1,8(sp)
    80002cf0:	1000                	add	s0,sp,32
    80002cf2:	84ae                	mv	s1,a1
    80002cf4:	00000097          	auipc	ra,0x0
    80002cf8:	ed0080e7          	jalr	-304(ra) # 80002bc4 <argraw>
    80002cfc:	e088                	sd	a0,0(s1)
    80002cfe:	4501                	li	a0,0
    80002d00:	60e2                	ld	ra,24(sp)
    80002d02:	6442                	ld	s0,16(sp)
    80002d04:	64a2                	ld	s1,8(sp)
    80002d06:	6105                	add	sp,sp,32
    80002d08:	8082                	ret

0000000080002d0a <argstr>:
    80002d0a:	1101                	add	sp,sp,-32
    80002d0c:	ec06                	sd	ra,24(sp)
    80002d0e:	e822                	sd	s0,16(sp)
    80002d10:	e426                	sd	s1,8(sp)
    80002d12:	e04a                	sd	s2,0(sp)
    80002d14:	1000                	add	s0,sp,32
    80002d16:	84ae                	mv	s1,a1
    80002d18:	8932                	mv	s2,a2
    80002d1a:	00000097          	auipc	ra,0x0
    80002d1e:	eaa080e7          	jalr	-342(ra) # 80002bc4 <argraw>
    80002d22:	864a                	mv	a2,s2
    80002d24:	85a6                	mv	a1,s1
    80002d26:	00000097          	auipc	ra,0x0
    80002d2a:	f58080e7          	jalr	-168(ra) # 80002c7e <fetchstr>
    80002d2e:	60e2                	ld	ra,24(sp)
    80002d30:	6442                	ld	s0,16(sp)
    80002d32:	64a2                	ld	s1,8(sp)
    80002d34:	6902                	ld	s2,0(sp)
    80002d36:	6105                	add	sp,sp,32
    80002d38:	8082                	ret

0000000080002d3a <syscall>:
    80002d3a:	1101                	add	sp,sp,-32
    80002d3c:	ec06                	sd	ra,24(sp)
    80002d3e:	e822                	sd	s0,16(sp)
    80002d40:	e426                	sd	s1,8(sp)
    80002d42:	e04a                	sd	s2,0(sp)
    80002d44:	1000                	add	s0,sp,32
    80002d46:	fffff097          	auipc	ra,0xfffff
    80002d4a:	cde080e7          	jalr	-802(ra) # 80001a24 <myproc>
    80002d4e:	84aa                	mv	s1,a0
    80002d50:	08853903          	ld	s2,136(a0)
    80002d54:	0a893783          	ld	a5,168(s2)
    80002d58:	0007869b          	sext.w	a3,a5
    80002d5c:	37fd                	addw	a5,a5,-1
    80002d5e:	475d                	li	a4,23
    80002d60:	00f76f63          	bltu	a4,a5,80002d7e <syscall+0x44>
    80002d64:	00369713          	sll	a4,a3,0x3
    80002d68:	00006797          	auipc	a5,0x6
    80002d6c:	9f078793          	add	a5,a5,-1552 # 80008758 <syscalls>
    80002d70:	97ba                	add	a5,a5,a4
    80002d72:	639c                	ld	a5,0(a5)
    80002d74:	c789                	beqz	a5,80002d7e <syscall+0x44>
    80002d76:	9782                	jalr	a5
    80002d78:	06a93823          	sd	a0,112(s2)
    80002d7c:	a839                	j	80002d9a <syscall+0x60>
    80002d7e:	18848613          	add	a2,s1,392
    80002d82:	50ac                	lw	a1,96(s1)
    80002d84:	00005517          	auipc	a0,0x5
    80002d88:	63c50513          	add	a0,a0,1596 # 800083c0 <etext+0x3c0>
    80002d8c:	ffffe097          	auipc	ra,0xffffe
    80002d90:	818080e7          	jalr	-2024(ra) # 800005a4 <printf>
    80002d94:	64dc                	ld	a5,136(s1)
    80002d96:	577d                	li	a4,-1
    80002d98:	fbb8                	sd	a4,112(a5)
    80002d9a:	60e2                	ld	ra,24(sp)
    80002d9c:	6442                	ld	s0,16(sp)
    80002d9e:	64a2                	ld	s1,8(sp)
    80002da0:	6902                	ld	s2,0(sp)
    80002da2:	6105                	add	sp,sp,32
    80002da4:	8082                	ret

0000000080002da6 <sys_exit>:
extern struct proc proc[NPROC];


uint64
sys_exit(void)
{
    80002da6:	1101                	add	sp,sp,-32
    80002da8:	ec06                	sd	ra,24(sp)
    80002daa:	e822                	sd	s0,16(sp)
    80002dac:	1000                	add	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002dae:	fec40593          	add	a1,s0,-20
    80002db2:	4501                	li	a0,0
    80002db4:	00000097          	auipc	ra,0x0
    80002db8:	f12080e7          	jalr	-238(ra) # 80002cc6 <argint>
    return -1;
    80002dbc:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002dbe:	00054963          	bltz	a0,80002dd0 <sys_exit+0x2a>
  exit(n);
    80002dc2:	fec42503          	lw	a0,-20(s0)
    80002dc6:	fffff097          	auipc	ra,0xfffff
    80002dca:	59e080e7          	jalr	1438(ra) # 80002364 <exit>
  return 0;  // not reached
    80002dce:	4781                	li	a5,0
}
    80002dd0:	853e                	mv	a0,a5
    80002dd2:	60e2                	ld	ra,24(sp)
    80002dd4:	6442                	ld	s0,16(sp)
    80002dd6:	6105                	add	sp,sp,32
    80002dd8:	8082                	ret

0000000080002dda <sys_getpid>:

uint64
sys_getpid(void)
{
    80002dda:	1141                	add	sp,sp,-16
    80002ddc:	e406                	sd	ra,8(sp)
    80002dde:	e022                	sd	s0,0(sp)
    80002de0:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002de2:	fffff097          	auipc	ra,0xfffff
    80002de6:	c42080e7          	jalr	-958(ra) # 80001a24 <myproc>
}
    80002dea:	5128                	lw	a0,96(a0)
    80002dec:	60a2                	ld	ra,8(sp)
    80002dee:	6402                	ld	s0,0(sp)
    80002df0:	0141                	add	sp,sp,16
    80002df2:	8082                	ret

0000000080002df4 <sys_fork>:

uint64
sys_fork(void)
{
    80002df4:	1141                	add	sp,sp,-16
    80002df6:	e406                	sd	ra,8(sp)
    80002df8:	e022                	sd	s0,0(sp)
    80002dfa:	0800                	add	s0,sp,16
  return fork();
    80002dfc:	fffff097          	auipc	ra,0xfffff
    80002e00:	018080e7          	jalr	24(ra) # 80001e14 <fork>
}
    80002e04:	60a2                	ld	ra,8(sp)
    80002e06:	6402                	ld	s0,0(sp)
    80002e08:	0141                	add	sp,sp,16
    80002e0a:	8082                	ret

0000000080002e0c <sys_wait>:

uint64
sys_wait(void)
{
    80002e0c:	1101                	add	sp,sp,-32
    80002e0e:	ec06                	sd	ra,24(sp)
    80002e10:	e822                	sd	s0,16(sp)
    80002e12:	1000                	add	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002e14:	fe840593          	add	a1,s0,-24
    80002e18:	4501                	li	a0,0
    80002e1a:	00000097          	auipc	ra,0x0
    80002e1e:	ece080e7          	jalr	-306(ra) # 80002ce8 <argaddr>
    80002e22:	87aa                	mv	a5,a0
    return -1;
    80002e24:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002e26:	0007c863          	bltz	a5,80002e36 <sys_wait+0x2a>
  return wait(p);
    80002e2a:	fe843503          	ld	a0,-24(s0)
    80002e2e:	fffff097          	auipc	ra,0xfffff
    80002e32:	33e080e7          	jalr	830(ra) # 8000216c <wait>
}
    80002e36:	60e2                	ld	ra,24(sp)
    80002e38:	6442                	ld	s0,16(sp)
    80002e3a:	6105                	add	sp,sp,32
    80002e3c:	8082                	ret

0000000080002e3e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e3e:	7179                	add	sp,sp,-48
    80002e40:	f406                	sd	ra,40(sp)
    80002e42:	f022                	sd	s0,32(sp)
    80002e44:	1800                	add	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002e46:	fdc40593          	add	a1,s0,-36
    80002e4a:	4501                	li	a0,0
    80002e4c:	00000097          	auipc	ra,0x0
    80002e50:	e7a080e7          	jalr	-390(ra) # 80002cc6 <argint>
    80002e54:	87aa                	mv	a5,a0
    return -1;
    80002e56:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002e58:	0207c263          	bltz	a5,80002e7c <sys_sbrk+0x3e>
    80002e5c:	ec26                	sd	s1,24(sp)
  addr = myproc()->sz;
    80002e5e:	fffff097          	auipc	ra,0xfffff
    80002e62:	bc6080e7          	jalr	-1082(ra) # 80001a24 <myproc>
    80002e66:	5d24                	lw	s1,120(a0)
  if(growproc(n) < 0)
    80002e68:	fdc42503          	lw	a0,-36(s0)
    80002e6c:	fffff097          	auipc	ra,0xfffff
    80002e70:	f30080e7          	jalr	-208(ra) # 80001d9c <growproc>
    80002e74:	00054863          	bltz	a0,80002e84 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002e78:	8526                	mv	a0,s1
    80002e7a:	64e2                	ld	s1,24(sp)
}
    80002e7c:	70a2                	ld	ra,40(sp)
    80002e7e:	7402                	ld	s0,32(sp)
    80002e80:	6145                	add	sp,sp,48
    80002e82:	8082                	ret
    return -1;
    80002e84:	557d                	li	a0,-1
    80002e86:	64e2                	ld	s1,24(sp)
    80002e88:	bfd5                	j	80002e7c <sys_sbrk+0x3e>

0000000080002e8a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e8a:	7139                	add	sp,sp,-64
    80002e8c:	fc06                	sd	ra,56(sp)
    80002e8e:	f822                	sd	s0,48(sp)
    80002e90:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002e92:	fcc40593          	add	a1,s0,-52
    80002e96:	4501                	li	a0,0
    80002e98:	00000097          	auipc	ra,0x0
    80002e9c:	e2e080e7          	jalr	-466(ra) # 80002cc6 <argint>
    return -1;
    80002ea0:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ea2:	06054b63          	bltz	a0,80002f18 <sys_sleep+0x8e>
    80002ea6:	f04a                	sd	s2,32(sp)
  acquire(&tickslock);
    80002ea8:	00015517          	auipc	a0,0x15
    80002eac:	e2850513          	add	a0,a0,-472 # 80017cd0 <tickslock>
    80002eb0:	ffffe097          	auipc	ra,0xffffe
    80002eb4:	d82080e7          	jalr	-638(ra) # 80000c32 <acquire>
  ticks0 = ticks;
    80002eb8:	00006917          	auipc	s2,0x6
    80002ebc:	17892903          	lw	s2,376(s2) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80002ec0:	fcc42783          	lw	a5,-52(s0)
    80002ec4:	c3a1                	beqz	a5,80002f04 <sys_sleep+0x7a>
    80002ec6:	f426                	sd	s1,40(sp)
    80002ec8:	ec4e                	sd	s3,24(sp)
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002eca:	00015997          	auipc	s3,0x15
    80002ece:	e0698993          	add	s3,s3,-506 # 80017cd0 <tickslock>
    80002ed2:	00006497          	auipc	s1,0x6
    80002ed6:	15e48493          	add	s1,s1,350 # 80009030 <ticks>
    if(myproc()->killed){
    80002eda:	fffff097          	auipc	ra,0xfffff
    80002ede:	b4a080e7          	jalr	-1206(ra) # 80001a24 <myproc>
    80002ee2:	4d3c                	lw	a5,88(a0)
    80002ee4:	ef9d                	bnez	a5,80002f22 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002ee6:	85ce                	mv	a1,s3
    80002ee8:	8526                	mv	a0,s1
    80002eea:	fffff097          	auipc	ra,0xfffff
    80002eee:	21e080e7          	jalr	542(ra) # 80002108 <sleep>
  while(ticks - ticks0 < n){
    80002ef2:	409c                	lw	a5,0(s1)
    80002ef4:	412787bb          	subw	a5,a5,s2
    80002ef8:	fcc42703          	lw	a4,-52(s0)
    80002efc:	fce7efe3          	bltu	a5,a4,80002eda <sys_sleep+0x50>
    80002f00:	74a2                	ld	s1,40(sp)
    80002f02:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002f04:	00015517          	auipc	a0,0x15
    80002f08:	dcc50513          	add	a0,a0,-564 # 80017cd0 <tickslock>
    80002f0c:	ffffe097          	auipc	ra,0xffffe
    80002f10:	dda080e7          	jalr	-550(ra) # 80000ce6 <release>
  return 0;
    80002f14:	4781                	li	a5,0
    80002f16:	7902                	ld	s2,32(sp)
}
    80002f18:	853e                	mv	a0,a5
    80002f1a:	70e2                	ld	ra,56(sp)
    80002f1c:	7442                	ld	s0,48(sp)
    80002f1e:	6121                	add	sp,sp,64
    80002f20:	8082                	ret
      release(&tickslock);
    80002f22:	00015517          	auipc	a0,0x15
    80002f26:	dae50513          	add	a0,a0,-594 # 80017cd0 <tickslock>
    80002f2a:	ffffe097          	auipc	ra,0xffffe
    80002f2e:	dbc080e7          	jalr	-580(ra) # 80000ce6 <release>
      return -1;
    80002f32:	57fd                	li	a5,-1
    80002f34:	74a2                	ld	s1,40(sp)
    80002f36:	7902                	ld	s2,32(sp)
    80002f38:	69e2                	ld	s3,24(sp)
    80002f3a:	bff9                	j	80002f18 <sys_sleep+0x8e>

0000000080002f3c <sys_kill>:

uint64
sys_kill(void)
{
    80002f3c:	1101                	add	sp,sp,-32
    80002f3e:	ec06                	sd	ra,24(sp)
    80002f40:	e822                	sd	s0,16(sp)
    80002f42:	1000                	add	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002f44:	fec40593          	add	a1,s0,-20
    80002f48:	4501                	li	a0,0
    80002f4a:	00000097          	auipc	ra,0x0
    80002f4e:	d7c080e7          	jalr	-644(ra) # 80002cc6 <argint>
    80002f52:	87aa                	mv	a5,a0
    return -1;
    80002f54:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002f56:	0007c863          	bltz	a5,80002f66 <sys_kill+0x2a>
  return kill(pid);
    80002f5a:	fec42503          	lw	a0,-20(s0)
    80002f5e:	fffff097          	auipc	ra,0xfffff
    80002f62:	4e8080e7          	jalr	1256(ra) # 80002446 <kill>
}
    80002f66:	60e2                	ld	ra,24(sp)
    80002f68:	6442                	ld	s0,16(sp)
    80002f6a:	6105                	add	sp,sp,32
    80002f6c:	8082                	ret

0000000080002f6e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f6e:	1101                	add	sp,sp,-32
    80002f70:	ec06                	sd	ra,24(sp)
    80002f72:	e822                	sd	s0,16(sp)
    80002f74:	e426                	sd	s1,8(sp)
    80002f76:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f78:	00015517          	auipc	a0,0x15
    80002f7c:	d5850513          	add	a0,a0,-680 # 80017cd0 <tickslock>
    80002f80:	ffffe097          	auipc	ra,0xffffe
    80002f84:	cb2080e7          	jalr	-846(ra) # 80000c32 <acquire>
  xticks = ticks;
    80002f88:	00006497          	auipc	s1,0x6
    80002f8c:	0a84a483          	lw	s1,168(s1) # 80009030 <ticks>
  release(&tickslock);
    80002f90:	00015517          	auipc	a0,0x15
    80002f94:	d4050513          	add	a0,a0,-704 # 80017cd0 <tickslock>
    80002f98:	ffffe097          	auipc	ra,0xffffe
    80002f9c:	d4e080e7          	jalr	-690(ra) # 80000ce6 <release>
  return xticks;
}
    80002fa0:	02049513          	sll	a0,s1,0x20
    80002fa4:	9101                	srl	a0,a0,0x20
    80002fa6:	60e2                	ld	ra,24(sp)
    80002fa8:	6442                	ld	s0,16(sp)
    80002faa:	64a2                	ld	s1,8(sp)
    80002fac:	6105                	add	sp,sp,32
    80002fae:	8082                	ret

0000000080002fb0 <sys_wait2>:


uint64
sys_wait2(void)
{
    80002fb0:	715d                	add	sp,sp,-80
    80002fb2:	e486                	sd	ra,72(sp)
    80002fb4:	e0a2                	sd	s0,64(sp)
    80002fb6:	0880                	add	s0,sp,80
  uint64 addr, addr1, addr2, addr3;
  int wtime, rtime, stime; // Change to int
  if (argaddr(0, &addr) < 0)
    80002fb8:	fd840593          	add	a1,s0,-40
    80002fbc:	4501                	li	a0,0
    80002fbe:	00000097          	auipc	ra,0x0
    80002fc2:	d2a080e7          	jalr	-726(ra) # 80002ce8 <argaddr>
    return -1;
    80002fc6:	57fd                	li	a5,-1
  if (argaddr(0, &addr) < 0)
    80002fc8:	0a054c63          	bltz	a0,80003080 <sys_wait2+0xd0>
  if (argaddr(1, &addr1) < 0) // user virtual memory
    80002fcc:	fd040593          	add	a1,s0,-48
    80002fd0:	4505                	li	a0,1
    80002fd2:	00000097          	auipc	ra,0x0
    80002fd6:	d16080e7          	jalr	-746(ra) # 80002ce8 <argaddr>
    return -1;
    80002fda:	57fd                	li	a5,-1
  if (argaddr(1, &addr1) < 0) // user virtual memory
    80002fdc:	0a054263          	bltz	a0,80003080 <sys_wait2+0xd0>
  if (argaddr(2, &addr2) < 0)
    80002fe0:	fc840593          	add	a1,s0,-56
    80002fe4:	4509                	li	a0,2
    80002fe6:	00000097          	auipc	ra,0x0
    80002fea:	d02080e7          	jalr	-766(ra) # 80002ce8 <argaddr>
    return -1;
    80002fee:	57fd                	li	a5,-1
  if (argaddr(2, &addr2) < 0)
    80002ff0:	08054863          	bltz	a0,80003080 <sys_wait2+0xd0>
  if (argaddr(3, &addr3) < 0)
    80002ff4:	fc040593          	add	a1,s0,-64
    80002ff8:	450d                	li	a0,3
    80002ffa:	00000097          	auipc	ra,0x0
    80002ffe:	cee080e7          	jalr	-786(ra) # 80002ce8 <argaddr>
    return -1;
    80003002:	57fd                	li	a5,-1
  if (argaddr(3, &addr3) < 0)
    80003004:	06054e63          	bltz	a0,80003080 <sys_wait2+0xd0>
    80003008:	fc26                	sd	s1,56(sp)
    8000300a:	f84a                	sd	s2,48(sp)

  int ret = wait2(&rtime, &wtime, &stime, 0); // Pass addresses
    8000300c:	4681                	li	a3,0
    8000300e:	fb440613          	add	a2,s0,-76
    80003012:	fbc40593          	add	a1,s0,-68
    80003016:	fb840513          	add	a0,s0,-72
    8000301a:	fffff097          	auipc	ra,0xfffff
    8000301e:	684080e7          	jalr	1668(ra) # 8000269e <wait2>
    80003022:	892a                	mv	s2,a0

  struct proc *p = myproc();
    80003024:	fffff097          	auipc	ra,0xfffff
    80003028:	a00080e7          	jalr	-1536(ra) # 80001a24 <myproc>
    8000302c:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000302e:	4691                	li	a3,4
    80003030:	fbc40613          	add	a2,s0,-68
    80003034:	fd043583          	ld	a1,-48(s0)
    80003038:	6148                	ld	a0,128(a0)
    8000303a:	ffffe097          	auipc	ra,0xffffe
    8000303e:	692080e7          	jalr	1682(ra) # 800016cc <copyout>
    return -1;
    80003042:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003044:	04054763          	bltz	a0,80003092 <sys_wait2+0xe2>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    80003048:	4691                	li	a3,4
    8000304a:	fb840613          	add	a2,s0,-72
    8000304e:	fc843583          	ld	a1,-56(s0)
    80003052:	60c8                	ld	a0,128(s1)
    80003054:	ffffe097          	auipc	ra,0xffffe
    80003058:	678080e7          	jalr	1656(ra) # 800016cc <copyout>
    return -1;
    8000305c:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    8000305e:	02054d63          	bltz	a0,80003098 <sys_wait2+0xe8>
  if (copyout(p->pagetable, addr3, (char *)&stime, sizeof(int)) < 0)
    80003062:	4691                	li	a3,4
    80003064:	fb440613          	add	a2,s0,-76
    80003068:	fc043583          	ld	a1,-64(s0)
    8000306c:	60c8                	ld	a0,128(s1)
    8000306e:	ffffe097          	auipc	ra,0xffffe
    80003072:	65e080e7          	jalr	1630(ra) # 800016cc <copyout>
    80003076:	00054a63          	bltz	a0,8000308a <sys_wait2+0xda>
    return -1;

  return ret;
    8000307a:	87ca                	mv	a5,s2
    8000307c:	74e2                	ld	s1,56(sp)
    8000307e:	7942                	ld	s2,48(sp)
}
    80003080:	853e                	mv	a0,a5
    80003082:	60a6                	ld	ra,72(sp)
    80003084:	6406                	ld	s0,64(sp)
    80003086:	6161                	add	sp,sp,80
    80003088:	8082                	ret
    return -1;
    8000308a:	57fd                	li	a5,-1
    8000308c:	74e2                	ld	s1,56(sp)
    8000308e:	7942                	ld	s2,48(sp)
    80003090:	bfc5                	j	80003080 <sys_wait2+0xd0>
    80003092:	74e2                	ld	s1,56(sp)
    80003094:	7942                	ld	s2,48(sp)
    80003096:	b7ed                	j	80003080 <sys_wait2+0xd0>
    80003098:	74e2                	ld	s1,56(sp)
    8000309a:	7942                	ld	s2,48(sp)
    8000309c:	b7d5                	j	80003080 <sys_wait2+0xd0>

000000008000309e <sys_setnice>:
 * - Searches the process table to find the process with the given `pid`.
 * - If found, updates its "nice" value and returns the original "nice" value.
 */
uint64
sys_setnice(void)
{
    8000309e:	7179                	add	sp,sp,-48
    800030a0:	f406                	sd	ra,40(sp)
    800030a2:	f022                	sd	s0,32(sp)
    800030a4:	1800                	add	s0,sp,48
  //init variables
  int pid, n, original_nice;
  struct proc *p;
  
  //validating process
  if(argint(0, &pid) < 0 || argint(1, &n) < 0)
    800030a6:	fdc40593          	add	a1,s0,-36
    800030aa:	4501                	li	a0,0
    800030ac:	00000097          	auipc	ra,0x0
    800030b0:	c1a080e7          	jalr	-998(ra) # 80002cc6 <argint>
    800030b4:	87aa                	mv	a5,a0
    return -1;
    800030b6:	557d                	li	a0,-1
  if(argint(0, &pid) < 0 || argint(1, &n) < 0)
    800030b8:	0607cf63          	bltz	a5,80003136 <sys_setnice+0x98>
    800030bc:	fd840593          	add	a1,s0,-40
    800030c0:	4505                	li	a0,1
    800030c2:	00000097          	auipc	ra,0x0
    800030c6:	c04080e7          	jalr	-1020(ra) # 80002cc6 <argint>
    800030ca:	06054a63          	bltz	a0,8000313e <sys_setnice+0xa0>
  
  //validating nice value in the proper range
  if(n < 0 || n > 20)
    800030ce:	fd842703          	lw	a4,-40(s0)
    800030d2:	47d1                	li	a5,20
    return -1;
    800030d4:	557d                	li	a0,-1
  if(n < 0 || n > 20)
    800030d6:	06e7e063          	bltu	a5,a4,80003136 <sys_setnice+0x98>
    800030da:	ec26                	sd	s1,24(sp)
    800030dc:	e84a                	sd	s2,16(sp)

  // loop process table
  for(p = proc; p < &proc[NPROC]; p++)
    800030de:	0000e497          	auipc	s1,0xe
    800030e2:	5f248493          	add	s1,s1,1522 # 800116d0 <proc>
    800030e6:	00015917          	auipc	s2,0x15
    800030ea:	bea90913          	add	s2,s2,-1046 # 80017cd0 <tickslock>
  {
    //lock
    acquire(&p->lock);
    800030ee:	8526                	mv	a0,s1
    800030f0:	ffffe097          	auipc	ra,0xffffe
    800030f4:	b42080e7          	jalr	-1214(ra) # 80000c32 <acquire>
    
    //set value
    if(p->pid == pid)
    800030f8:	50b8                	lw	a4,96(s1)
    800030fa:	fdc42783          	lw	a5,-36(s0)
    800030fe:	00f70f63          	beq	a4,a5,8000311c <sys_setnice+0x7e>
      //return original nice value
      return original_nice;
    }
    
    //unlock
    release(&p->lock);
    80003102:	8526                	mv	a0,s1
    80003104:	ffffe097          	auipc	ra,0xffffe
    80003108:	be2080e7          	jalr	-1054(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++)
    8000310c:	19848493          	add	s1,s1,408
    80003110:	fd249fe3          	bne	s1,s2,800030ee <sys_setnice+0x50>
  }
  return -1; //process not found
    80003114:	557d                	li	a0,-1
    80003116:	64e2                	ld	s1,24(sp)
    80003118:	6942                	ld	s2,16(sp)
    8000311a:	a831                	j	80003136 <sys_setnice+0x98>
      original_nice = p->nice;
    8000311c:	0184a903          	lw	s2,24(s1)
      p->nice = n;
    80003120:	fd842783          	lw	a5,-40(s0)
    80003124:	cc9c                	sw	a5,24(s1)
      release(&p->lock);
    80003126:	8526                	mv	a0,s1
    80003128:	ffffe097          	auipc	ra,0xffffe
    8000312c:	bbe080e7          	jalr	-1090(ra) # 80000ce6 <release>
      return original_nice;
    80003130:	854a                	mv	a0,s2
    80003132:	64e2                	ld	s1,24(sp)
    80003134:	6942                	ld	s2,16(sp)
}
    80003136:	70a2                	ld	ra,40(sp)
    80003138:	7402                	ld	s0,32(sp)
    8000313a:	6145                	add	sp,sp,48
    8000313c:	8082                	ret
    return -1;
    8000313e:	557d                	li	a0,-1
    80003140:	bfdd                	j	80003136 <sys_setnice+0x98>

0000000080003142 <sys_getnice>:
 * - Searches the process table to find the process with the given `pid`.
 * - If found, retrieves and returns its "nice" value.
 */
uint64
sys_getnice(void)
{
    80003142:	7179                	add	sp,sp,-48
    80003144:	f406                	sd	ra,40(sp)
    80003146:	f022                	sd	s0,32(sp)
    80003148:	1800                	add	s0,sp,48
  //init variables
  int pid;
  struct proc *p;
  
  //validating process
  if(argint(0, &pid) < 0)
    8000314a:	fdc40593          	add	a1,s0,-36
    8000314e:	4501                	li	a0,0
    80003150:	00000097          	auipc	ra,0x0
    80003154:	b76080e7          	jalr	-1162(ra) # 80002cc6 <argint>
    80003158:	06054163          	bltz	a0,800031ba <sys_getnice+0x78>
    8000315c:	ec26                	sd	s1,24(sp)
    8000315e:	e84a                	sd	s2,16(sp)
    return -1;

  //loop process table
  for(p = proc; p < &proc[NPROC]; p++){
    80003160:	0000e497          	auipc	s1,0xe
    80003164:	57048493          	add	s1,s1,1392 # 800116d0 <proc>
    80003168:	00015917          	auipc	s2,0x15
    8000316c:	b6890913          	add	s2,s2,-1176 # 80017cd0 <tickslock>
    
    //lock
    acquire(&p->lock);
    80003170:	8526                	mv	a0,s1
    80003172:	ffffe097          	auipc	ra,0xffffe
    80003176:	ac0080e7          	jalr	-1344(ra) # 80000c32 <acquire>
    
    //find target and set value
    if(p->pid == pid){
    8000317a:	50b8                	lw	a4,96(s1)
    8000317c:	fdc42783          	lw	a5,-36(s0)
    80003180:	00f70f63          	beq	a4,a5,8000319e <sys_getnice+0x5c>
      //get value
      return nice_value;
    }
    
    //unlock
    release(&p->lock);
    80003184:	8526                	mv	a0,s1
    80003186:	ffffe097          	auipc	ra,0xffffe
    8000318a:	b60080e7          	jalr	-1184(ra) # 80000ce6 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000318e:	19848493          	add	s1,s1,408
    80003192:	fd249fe3          	bne	s1,s2,80003170 <sys_getnice+0x2e>
  }
  return -1; // process not found
    80003196:	557d                	li	a0,-1
    80003198:	64e2                	ld	s1,24(sp)
    8000319a:	6942                	ld	s2,16(sp)
    8000319c:	a819                	j	800031b2 <sys_getnice+0x70>
      int nice_value = p->nice;
    8000319e:	0184a903          	lw	s2,24(s1)
      release(&p->lock);
    800031a2:	8526                	mv	a0,s1
    800031a4:	ffffe097          	auipc	ra,0xffffe
    800031a8:	b42080e7          	jalr	-1214(ra) # 80000ce6 <release>
      return nice_value;
    800031ac:	854a                	mv	a0,s2
    800031ae:	64e2                	ld	s1,24(sp)
    800031b0:	6942                	ld	s2,16(sp)
}
    800031b2:	70a2                	ld	ra,40(sp)
    800031b4:	7402                	ld	s0,32(sp)
    800031b6:	6145                	add	sp,sp,48
    800031b8:	8082                	ret
    return -1;
    800031ba:	557d                	li	a0,-1
    800031bc:	bfdd                	j	800031b2 <sys_getnice+0x70>

00000000800031be <binit>:
    800031be:	7179                	add	sp,sp,-48
    800031c0:	f406                	sd	ra,40(sp)
    800031c2:	f022                	sd	s0,32(sp)
    800031c4:	ec26                	sd	s1,24(sp)
    800031c6:	e84a                	sd	s2,16(sp)
    800031c8:	e44e                	sd	s3,8(sp)
    800031ca:	e052                	sd	s4,0(sp)
    800031cc:	1800                	add	s0,sp,48
    800031ce:	00005597          	auipc	a1,0x5
    800031d2:	21258593          	add	a1,a1,530 # 800083e0 <etext+0x3e0>
    800031d6:	00015517          	auipc	a0,0x15
    800031da:	b1250513          	add	a0,a0,-1262 # 80017ce8 <bcache>
    800031de:	ffffe097          	auipc	ra,0xffffe
    800031e2:	9c4080e7          	jalr	-1596(ra) # 80000ba2 <initlock>
    800031e6:	0001d797          	auipc	a5,0x1d
    800031ea:	b0278793          	add	a5,a5,-1278 # 8001fce8 <bcache+0x8000>
    800031ee:	0001d717          	auipc	a4,0x1d
    800031f2:	d6270713          	add	a4,a4,-670 # 8001ff50 <bcache+0x8268>
    800031f6:	2ae7b823          	sd	a4,688(a5)
    800031fa:	2ae7bc23          	sd	a4,696(a5)
    800031fe:	00015497          	auipc	s1,0x15
    80003202:	b0248493          	add	s1,s1,-1278 # 80017d00 <bcache+0x18>
    80003206:	893e                	mv	s2,a5
    80003208:	89ba                	mv	s3,a4
    8000320a:	00005a17          	auipc	s4,0x5
    8000320e:	1dea0a13          	add	s4,s4,478 # 800083e8 <etext+0x3e8>
    80003212:	2b893783          	ld	a5,696(s2)
    80003216:	e8bc                	sd	a5,80(s1)
    80003218:	0534b423          	sd	s3,72(s1)
    8000321c:	85d2                	mv	a1,s4
    8000321e:	01048513          	add	a0,s1,16
    80003222:	00001097          	auipc	ra,0x1
    80003226:	4b2080e7          	jalr	1202(ra) # 800046d4 <initsleeplock>
    8000322a:	2b893783          	ld	a5,696(s2)
    8000322e:	e7a4                	sd	s1,72(a5)
    80003230:	2a993c23          	sd	s1,696(s2)
    80003234:	45848493          	add	s1,s1,1112
    80003238:	fd349de3          	bne	s1,s3,80003212 <binit+0x54>
    8000323c:	70a2                	ld	ra,40(sp)
    8000323e:	7402                	ld	s0,32(sp)
    80003240:	64e2                	ld	s1,24(sp)
    80003242:	6942                	ld	s2,16(sp)
    80003244:	69a2                	ld	s3,8(sp)
    80003246:	6a02                	ld	s4,0(sp)
    80003248:	6145                	add	sp,sp,48
    8000324a:	8082                	ret

000000008000324c <bread>:
    8000324c:	7179                	add	sp,sp,-48
    8000324e:	f406                	sd	ra,40(sp)
    80003250:	f022                	sd	s0,32(sp)
    80003252:	ec26                	sd	s1,24(sp)
    80003254:	e84a                	sd	s2,16(sp)
    80003256:	e44e                	sd	s3,8(sp)
    80003258:	1800                	add	s0,sp,48
    8000325a:	892a                	mv	s2,a0
    8000325c:	89ae                	mv	s3,a1
    8000325e:	00015517          	auipc	a0,0x15
    80003262:	a8a50513          	add	a0,a0,-1398 # 80017ce8 <bcache>
    80003266:	ffffe097          	auipc	ra,0xffffe
    8000326a:	9cc080e7          	jalr	-1588(ra) # 80000c32 <acquire>
    8000326e:	0001d497          	auipc	s1,0x1d
    80003272:	d324b483          	ld	s1,-718(s1) # 8001ffa0 <bcache+0x82b8>
    80003276:	0001d797          	auipc	a5,0x1d
    8000327a:	cda78793          	add	a5,a5,-806 # 8001ff50 <bcache+0x8268>
    8000327e:	02f48f63          	beq	s1,a5,800032bc <bread+0x70>
    80003282:	873e                	mv	a4,a5
    80003284:	a021                	j	8000328c <bread+0x40>
    80003286:	68a4                	ld	s1,80(s1)
    80003288:	02e48a63          	beq	s1,a4,800032bc <bread+0x70>
    8000328c:	449c                	lw	a5,8(s1)
    8000328e:	ff279ce3          	bne	a5,s2,80003286 <bread+0x3a>
    80003292:	44dc                	lw	a5,12(s1)
    80003294:	ff3799e3          	bne	a5,s3,80003286 <bread+0x3a>
    80003298:	40bc                	lw	a5,64(s1)
    8000329a:	2785                	addw	a5,a5,1
    8000329c:	c0bc                	sw	a5,64(s1)
    8000329e:	00015517          	auipc	a0,0x15
    800032a2:	a4a50513          	add	a0,a0,-1462 # 80017ce8 <bcache>
    800032a6:	ffffe097          	auipc	ra,0xffffe
    800032aa:	a40080e7          	jalr	-1472(ra) # 80000ce6 <release>
    800032ae:	01048513          	add	a0,s1,16
    800032b2:	00001097          	auipc	ra,0x1
    800032b6:	45c080e7          	jalr	1116(ra) # 8000470e <acquiresleep>
    800032ba:	a8b9                	j	80003318 <bread+0xcc>
    800032bc:	0001d497          	auipc	s1,0x1d
    800032c0:	cdc4b483          	ld	s1,-804(s1) # 8001ff98 <bcache+0x82b0>
    800032c4:	0001d797          	auipc	a5,0x1d
    800032c8:	c8c78793          	add	a5,a5,-884 # 8001ff50 <bcache+0x8268>
    800032cc:	00f48863          	beq	s1,a5,800032dc <bread+0x90>
    800032d0:	873e                	mv	a4,a5
    800032d2:	40bc                	lw	a5,64(s1)
    800032d4:	cf81                	beqz	a5,800032ec <bread+0xa0>
    800032d6:	64a4                	ld	s1,72(s1)
    800032d8:	fee49de3          	bne	s1,a4,800032d2 <bread+0x86>
    800032dc:	00005517          	auipc	a0,0x5
    800032e0:	11450513          	add	a0,a0,276 # 800083f0 <etext+0x3f0>
    800032e4:	ffffd097          	auipc	ra,0xffffd
    800032e8:	276080e7          	jalr	630(ra) # 8000055a <panic>
    800032ec:	0124a423          	sw	s2,8(s1)
    800032f0:	0134a623          	sw	s3,12(s1)
    800032f4:	0004a023          	sw	zero,0(s1)
    800032f8:	4785                	li	a5,1
    800032fa:	c0bc                	sw	a5,64(s1)
    800032fc:	00015517          	auipc	a0,0x15
    80003300:	9ec50513          	add	a0,a0,-1556 # 80017ce8 <bcache>
    80003304:	ffffe097          	auipc	ra,0xffffe
    80003308:	9e2080e7          	jalr	-1566(ra) # 80000ce6 <release>
    8000330c:	01048513          	add	a0,s1,16
    80003310:	00001097          	auipc	ra,0x1
    80003314:	3fe080e7          	jalr	1022(ra) # 8000470e <acquiresleep>
    80003318:	409c                	lw	a5,0(s1)
    8000331a:	cb89                	beqz	a5,8000332c <bread+0xe0>
    8000331c:	8526                	mv	a0,s1
    8000331e:	70a2                	ld	ra,40(sp)
    80003320:	7402                	ld	s0,32(sp)
    80003322:	64e2                	ld	s1,24(sp)
    80003324:	6942                	ld	s2,16(sp)
    80003326:	69a2                	ld	s3,8(sp)
    80003328:	6145                	add	sp,sp,48
    8000332a:	8082                	ret
    8000332c:	4581                	li	a1,0
    8000332e:	8526                	mv	a0,s1
    80003330:	00003097          	auipc	ra,0x3
    80003334:	ff2080e7          	jalr	-14(ra) # 80006322 <virtio_disk_rw>
    80003338:	4785                	li	a5,1
    8000333a:	c09c                	sw	a5,0(s1)
    8000333c:	b7c5                	j	8000331c <bread+0xd0>

000000008000333e <bwrite>:
    8000333e:	1101                	add	sp,sp,-32
    80003340:	ec06                	sd	ra,24(sp)
    80003342:	e822                	sd	s0,16(sp)
    80003344:	e426                	sd	s1,8(sp)
    80003346:	1000                	add	s0,sp,32
    80003348:	84aa                	mv	s1,a0
    8000334a:	0541                	add	a0,a0,16
    8000334c:	00001097          	auipc	ra,0x1
    80003350:	45c080e7          	jalr	1116(ra) # 800047a8 <holdingsleep>
    80003354:	cd01                	beqz	a0,8000336c <bwrite+0x2e>
    80003356:	4585                	li	a1,1
    80003358:	8526                	mv	a0,s1
    8000335a:	00003097          	auipc	ra,0x3
    8000335e:	fc8080e7          	jalr	-56(ra) # 80006322 <virtio_disk_rw>
    80003362:	60e2                	ld	ra,24(sp)
    80003364:	6442                	ld	s0,16(sp)
    80003366:	64a2                	ld	s1,8(sp)
    80003368:	6105                	add	sp,sp,32
    8000336a:	8082                	ret
    8000336c:	00005517          	auipc	a0,0x5
    80003370:	09c50513          	add	a0,a0,156 # 80008408 <etext+0x408>
    80003374:	ffffd097          	auipc	ra,0xffffd
    80003378:	1e6080e7          	jalr	486(ra) # 8000055a <panic>

000000008000337c <brelse>:
    8000337c:	1101                	add	sp,sp,-32
    8000337e:	ec06                	sd	ra,24(sp)
    80003380:	e822                	sd	s0,16(sp)
    80003382:	e426                	sd	s1,8(sp)
    80003384:	e04a                	sd	s2,0(sp)
    80003386:	1000                	add	s0,sp,32
    80003388:	84aa                	mv	s1,a0
    8000338a:	01050913          	add	s2,a0,16
    8000338e:	854a                	mv	a0,s2
    80003390:	00001097          	auipc	ra,0x1
    80003394:	418080e7          	jalr	1048(ra) # 800047a8 <holdingsleep>
    80003398:	c925                	beqz	a0,80003408 <brelse+0x8c>
    8000339a:	854a                	mv	a0,s2
    8000339c:	00001097          	auipc	ra,0x1
    800033a0:	3c8080e7          	jalr	968(ra) # 80004764 <releasesleep>
    800033a4:	00015517          	auipc	a0,0x15
    800033a8:	94450513          	add	a0,a0,-1724 # 80017ce8 <bcache>
    800033ac:	ffffe097          	auipc	ra,0xffffe
    800033b0:	886080e7          	jalr	-1914(ra) # 80000c32 <acquire>
    800033b4:	40bc                	lw	a5,64(s1)
    800033b6:	37fd                	addw	a5,a5,-1
    800033b8:	0007871b          	sext.w	a4,a5
    800033bc:	c0bc                	sw	a5,64(s1)
    800033be:	e71d                	bnez	a4,800033ec <brelse+0x70>
    800033c0:	68b8                	ld	a4,80(s1)
    800033c2:	64bc                	ld	a5,72(s1)
    800033c4:	e73c                	sd	a5,72(a4)
    800033c6:	68b8                	ld	a4,80(s1)
    800033c8:	ebb8                	sd	a4,80(a5)
    800033ca:	0001d797          	auipc	a5,0x1d
    800033ce:	91e78793          	add	a5,a5,-1762 # 8001fce8 <bcache+0x8000>
    800033d2:	2b87b703          	ld	a4,696(a5)
    800033d6:	e8b8                	sd	a4,80(s1)
    800033d8:	0001d717          	auipc	a4,0x1d
    800033dc:	b7870713          	add	a4,a4,-1160 # 8001ff50 <bcache+0x8268>
    800033e0:	e4b8                	sd	a4,72(s1)
    800033e2:	2b87b703          	ld	a4,696(a5)
    800033e6:	e724                	sd	s1,72(a4)
    800033e8:	2a97bc23          	sd	s1,696(a5)
    800033ec:	00015517          	auipc	a0,0x15
    800033f0:	8fc50513          	add	a0,a0,-1796 # 80017ce8 <bcache>
    800033f4:	ffffe097          	auipc	ra,0xffffe
    800033f8:	8f2080e7          	jalr	-1806(ra) # 80000ce6 <release>
    800033fc:	60e2                	ld	ra,24(sp)
    800033fe:	6442                	ld	s0,16(sp)
    80003400:	64a2                	ld	s1,8(sp)
    80003402:	6902                	ld	s2,0(sp)
    80003404:	6105                	add	sp,sp,32
    80003406:	8082                	ret
    80003408:	00005517          	auipc	a0,0x5
    8000340c:	00850513          	add	a0,a0,8 # 80008410 <etext+0x410>
    80003410:	ffffd097          	auipc	ra,0xffffd
    80003414:	14a080e7          	jalr	330(ra) # 8000055a <panic>

0000000080003418 <bpin>:
    80003418:	1101                	add	sp,sp,-32
    8000341a:	ec06                	sd	ra,24(sp)
    8000341c:	e822                	sd	s0,16(sp)
    8000341e:	e426                	sd	s1,8(sp)
    80003420:	1000                	add	s0,sp,32
    80003422:	84aa                	mv	s1,a0
    80003424:	00015517          	auipc	a0,0x15
    80003428:	8c450513          	add	a0,a0,-1852 # 80017ce8 <bcache>
    8000342c:	ffffe097          	auipc	ra,0xffffe
    80003430:	806080e7          	jalr	-2042(ra) # 80000c32 <acquire>
    80003434:	40bc                	lw	a5,64(s1)
    80003436:	2785                	addw	a5,a5,1
    80003438:	c0bc                	sw	a5,64(s1)
    8000343a:	00015517          	auipc	a0,0x15
    8000343e:	8ae50513          	add	a0,a0,-1874 # 80017ce8 <bcache>
    80003442:	ffffe097          	auipc	ra,0xffffe
    80003446:	8a4080e7          	jalr	-1884(ra) # 80000ce6 <release>
    8000344a:	60e2                	ld	ra,24(sp)
    8000344c:	6442                	ld	s0,16(sp)
    8000344e:	64a2                	ld	s1,8(sp)
    80003450:	6105                	add	sp,sp,32
    80003452:	8082                	ret

0000000080003454 <bunpin>:
    80003454:	1101                	add	sp,sp,-32
    80003456:	ec06                	sd	ra,24(sp)
    80003458:	e822                	sd	s0,16(sp)
    8000345a:	e426                	sd	s1,8(sp)
    8000345c:	1000                	add	s0,sp,32
    8000345e:	84aa                	mv	s1,a0
    80003460:	00015517          	auipc	a0,0x15
    80003464:	88850513          	add	a0,a0,-1912 # 80017ce8 <bcache>
    80003468:	ffffd097          	auipc	ra,0xffffd
    8000346c:	7ca080e7          	jalr	1994(ra) # 80000c32 <acquire>
    80003470:	40bc                	lw	a5,64(s1)
    80003472:	37fd                	addw	a5,a5,-1
    80003474:	c0bc                	sw	a5,64(s1)
    80003476:	00015517          	auipc	a0,0x15
    8000347a:	87250513          	add	a0,a0,-1934 # 80017ce8 <bcache>
    8000347e:	ffffe097          	auipc	ra,0xffffe
    80003482:	868080e7          	jalr	-1944(ra) # 80000ce6 <release>
    80003486:	60e2                	ld	ra,24(sp)
    80003488:	6442                	ld	s0,16(sp)
    8000348a:	64a2                	ld	s1,8(sp)
    8000348c:	6105                	add	sp,sp,32
    8000348e:	8082                	ret

0000000080003490 <bfree>:
    80003490:	1101                	add	sp,sp,-32
    80003492:	ec06                	sd	ra,24(sp)
    80003494:	e822                	sd	s0,16(sp)
    80003496:	e426                	sd	s1,8(sp)
    80003498:	e04a                	sd	s2,0(sp)
    8000349a:	1000                	add	s0,sp,32
    8000349c:	84ae                	mv	s1,a1
    8000349e:	00d5d59b          	srlw	a1,a1,0xd
    800034a2:	0001d797          	auipc	a5,0x1d
    800034a6:	f227a783          	lw	a5,-222(a5) # 800203c4 <sb+0x1c>
    800034aa:	9dbd                	addw	a1,a1,a5
    800034ac:	00000097          	auipc	ra,0x0
    800034b0:	da0080e7          	jalr	-608(ra) # 8000324c <bread>
    800034b4:	0074f713          	and	a4,s1,7
    800034b8:	4785                	li	a5,1
    800034ba:	00e797bb          	sllw	a5,a5,a4
    800034be:	14ce                	sll	s1,s1,0x33
    800034c0:	90d9                	srl	s1,s1,0x36
    800034c2:	00950733          	add	a4,a0,s1
    800034c6:	05874703          	lbu	a4,88(a4)
    800034ca:	00e7f6b3          	and	a3,a5,a4
    800034ce:	c69d                	beqz	a3,800034fc <bfree+0x6c>
    800034d0:	892a                	mv	s2,a0
    800034d2:	94aa                	add	s1,s1,a0
    800034d4:	fff7c793          	not	a5,a5
    800034d8:	8f7d                	and	a4,a4,a5
    800034da:	04e48c23          	sb	a4,88(s1)
    800034de:	00001097          	auipc	ra,0x1
    800034e2:	112080e7          	jalr	274(ra) # 800045f0 <log_write>
    800034e6:	854a                	mv	a0,s2
    800034e8:	00000097          	auipc	ra,0x0
    800034ec:	e94080e7          	jalr	-364(ra) # 8000337c <brelse>
    800034f0:	60e2                	ld	ra,24(sp)
    800034f2:	6442                	ld	s0,16(sp)
    800034f4:	64a2                	ld	s1,8(sp)
    800034f6:	6902                	ld	s2,0(sp)
    800034f8:	6105                	add	sp,sp,32
    800034fa:	8082                	ret
    800034fc:	00005517          	auipc	a0,0x5
    80003500:	f1c50513          	add	a0,a0,-228 # 80008418 <etext+0x418>
    80003504:	ffffd097          	auipc	ra,0xffffd
    80003508:	056080e7          	jalr	86(ra) # 8000055a <panic>

000000008000350c <balloc>:
    8000350c:	711d                	add	sp,sp,-96
    8000350e:	ec86                	sd	ra,88(sp)
    80003510:	e8a2                	sd	s0,80(sp)
    80003512:	e4a6                	sd	s1,72(sp)
    80003514:	e0ca                	sd	s2,64(sp)
    80003516:	fc4e                	sd	s3,56(sp)
    80003518:	f852                	sd	s4,48(sp)
    8000351a:	f456                	sd	s5,40(sp)
    8000351c:	f05a                	sd	s6,32(sp)
    8000351e:	ec5e                	sd	s7,24(sp)
    80003520:	e862                	sd	s8,16(sp)
    80003522:	e466                	sd	s9,8(sp)
    80003524:	1080                	add	s0,sp,96
    80003526:	0001d797          	auipc	a5,0x1d
    8000352a:	e867a783          	lw	a5,-378(a5) # 800203ac <sb+0x4>
    8000352e:	cbc1                	beqz	a5,800035be <balloc+0xb2>
    80003530:	8baa                	mv	s7,a0
    80003532:	4a81                	li	s5,0
    80003534:	0001db17          	auipc	s6,0x1d
    80003538:	e74b0b13          	add	s6,s6,-396 # 800203a8 <sb>
    8000353c:	4c01                	li	s8,0
    8000353e:	4985                	li	s3,1
    80003540:	6a09                	lui	s4,0x2
    80003542:	6c89                	lui	s9,0x2
    80003544:	a831                	j	80003560 <balloc+0x54>
    80003546:	854a                	mv	a0,s2
    80003548:	00000097          	auipc	ra,0x0
    8000354c:	e34080e7          	jalr	-460(ra) # 8000337c <brelse>
    80003550:	015c87bb          	addw	a5,s9,s5
    80003554:	00078a9b          	sext.w	s5,a5
    80003558:	004b2703          	lw	a4,4(s6)
    8000355c:	06eaf163          	bgeu	s5,a4,800035be <balloc+0xb2>
    80003560:	41fad79b          	sraw	a5,s5,0x1f
    80003564:	0137d79b          	srlw	a5,a5,0x13
    80003568:	015787bb          	addw	a5,a5,s5
    8000356c:	40d7d79b          	sraw	a5,a5,0xd
    80003570:	01cb2583          	lw	a1,28(s6)
    80003574:	9dbd                	addw	a1,a1,a5
    80003576:	855e                	mv	a0,s7
    80003578:	00000097          	auipc	ra,0x0
    8000357c:	cd4080e7          	jalr	-812(ra) # 8000324c <bread>
    80003580:	892a                	mv	s2,a0
    80003582:	004b2503          	lw	a0,4(s6)
    80003586:	000a849b          	sext.w	s1,s5
    8000358a:	8762                	mv	a4,s8
    8000358c:	faa4fde3          	bgeu	s1,a0,80003546 <balloc+0x3a>
    80003590:	00777693          	and	a3,a4,7
    80003594:	00d996bb          	sllw	a3,s3,a3
    80003598:	41f7579b          	sraw	a5,a4,0x1f
    8000359c:	01d7d79b          	srlw	a5,a5,0x1d
    800035a0:	9fb9                	addw	a5,a5,a4
    800035a2:	4037d79b          	sraw	a5,a5,0x3
    800035a6:	00f90633          	add	a2,s2,a5
    800035aa:	05864603          	lbu	a2,88(a2)
    800035ae:	00c6f5b3          	and	a1,a3,a2
    800035b2:	cd91                	beqz	a1,800035ce <balloc+0xc2>
    800035b4:	2705                	addw	a4,a4,1
    800035b6:	2485                	addw	s1,s1,1
    800035b8:	fd471ae3          	bne	a4,s4,8000358c <balloc+0x80>
    800035bc:	b769                	j	80003546 <balloc+0x3a>
    800035be:	00005517          	auipc	a0,0x5
    800035c2:	e7250513          	add	a0,a0,-398 # 80008430 <etext+0x430>
    800035c6:	ffffd097          	auipc	ra,0xffffd
    800035ca:	f94080e7          	jalr	-108(ra) # 8000055a <panic>
    800035ce:	97ca                	add	a5,a5,s2
    800035d0:	8e55                	or	a2,a2,a3
    800035d2:	04c78c23          	sb	a2,88(a5)
    800035d6:	854a                	mv	a0,s2
    800035d8:	00001097          	auipc	ra,0x1
    800035dc:	018080e7          	jalr	24(ra) # 800045f0 <log_write>
    800035e0:	854a                	mv	a0,s2
    800035e2:	00000097          	auipc	ra,0x0
    800035e6:	d9a080e7          	jalr	-614(ra) # 8000337c <brelse>
    800035ea:	85a6                	mv	a1,s1
    800035ec:	855e                	mv	a0,s7
    800035ee:	00000097          	auipc	ra,0x0
    800035f2:	c5e080e7          	jalr	-930(ra) # 8000324c <bread>
    800035f6:	892a                	mv	s2,a0
    800035f8:	40000613          	li	a2,1024
    800035fc:	4581                	li	a1,0
    800035fe:	05850513          	add	a0,a0,88
    80003602:	ffffd097          	auipc	ra,0xffffd
    80003606:	72c080e7          	jalr	1836(ra) # 80000d2e <memset>
    8000360a:	854a                	mv	a0,s2
    8000360c:	00001097          	auipc	ra,0x1
    80003610:	fe4080e7          	jalr	-28(ra) # 800045f0 <log_write>
    80003614:	854a                	mv	a0,s2
    80003616:	00000097          	auipc	ra,0x0
    8000361a:	d66080e7          	jalr	-666(ra) # 8000337c <brelse>
    8000361e:	8526                	mv	a0,s1
    80003620:	60e6                	ld	ra,88(sp)
    80003622:	6446                	ld	s0,80(sp)
    80003624:	64a6                	ld	s1,72(sp)
    80003626:	6906                	ld	s2,64(sp)
    80003628:	79e2                	ld	s3,56(sp)
    8000362a:	7a42                	ld	s4,48(sp)
    8000362c:	7aa2                	ld	s5,40(sp)
    8000362e:	7b02                	ld	s6,32(sp)
    80003630:	6be2                	ld	s7,24(sp)
    80003632:	6c42                	ld	s8,16(sp)
    80003634:	6ca2                	ld	s9,8(sp)
    80003636:	6125                	add	sp,sp,96
    80003638:	8082                	ret

000000008000363a <bmap>:
    8000363a:	7179                	add	sp,sp,-48
    8000363c:	f406                	sd	ra,40(sp)
    8000363e:	f022                	sd	s0,32(sp)
    80003640:	ec26                	sd	s1,24(sp)
    80003642:	e84a                	sd	s2,16(sp)
    80003644:	e44e                	sd	s3,8(sp)
    80003646:	1800                	add	s0,sp,48
    80003648:	892a                	mv	s2,a0
    8000364a:	47ad                	li	a5,11
    8000364c:	04b7ff63          	bgeu	a5,a1,800036aa <bmap+0x70>
    80003650:	e052                	sd	s4,0(sp)
    80003652:	ff45849b          	addw	s1,a1,-12
    80003656:	0004871b          	sext.w	a4,s1
    8000365a:	0ff00793          	li	a5,255
    8000365e:	0ae7e463          	bltu	a5,a4,80003706 <bmap+0xcc>
    80003662:	08052583          	lw	a1,128(a0)
    80003666:	c5b5                	beqz	a1,800036d2 <bmap+0x98>
    80003668:	00092503          	lw	a0,0(s2)
    8000366c:	00000097          	auipc	ra,0x0
    80003670:	be0080e7          	jalr	-1056(ra) # 8000324c <bread>
    80003674:	8a2a                	mv	s4,a0
    80003676:	05850793          	add	a5,a0,88
    8000367a:	02049713          	sll	a4,s1,0x20
    8000367e:	01e75593          	srl	a1,a4,0x1e
    80003682:	00b784b3          	add	s1,a5,a1
    80003686:	0004a983          	lw	s3,0(s1)
    8000368a:	04098e63          	beqz	s3,800036e6 <bmap+0xac>
    8000368e:	8552                	mv	a0,s4
    80003690:	00000097          	auipc	ra,0x0
    80003694:	cec080e7          	jalr	-788(ra) # 8000337c <brelse>
    80003698:	6a02                	ld	s4,0(sp)
    8000369a:	854e                	mv	a0,s3
    8000369c:	70a2                	ld	ra,40(sp)
    8000369e:	7402                	ld	s0,32(sp)
    800036a0:	64e2                	ld	s1,24(sp)
    800036a2:	6942                	ld	s2,16(sp)
    800036a4:	69a2                	ld	s3,8(sp)
    800036a6:	6145                	add	sp,sp,48
    800036a8:	8082                	ret
    800036aa:	02059793          	sll	a5,a1,0x20
    800036ae:	01e7d593          	srl	a1,a5,0x1e
    800036b2:	00b504b3          	add	s1,a0,a1
    800036b6:	0504a983          	lw	s3,80(s1)
    800036ba:	fe0990e3          	bnez	s3,8000369a <bmap+0x60>
    800036be:	4108                	lw	a0,0(a0)
    800036c0:	00000097          	auipc	ra,0x0
    800036c4:	e4c080e7          	jalr	-436(ra) # 8000350c <balloc>
    800036c8:	0005099b          	sext.w	s3,a0
    800036cc:	0534a823          	sw	s3,80(s1)
    800036d0:	b7e9                	j	8000369a <bmap+0x60>
    800036d2:	4108                	lw	a0,0(a0)
    800036d4:	00000097          	auipc	ra,0x0
    800036d8:	e38080e7          	jalr	-456(ra) # 8000350c <balloc>
    800036dc:	0005059b          	sext.w	a1,a0
    800036e0:	08b92023          	sw	a1,128(s2)
    800036e4:	b751                	j	80003668 <bmap+0x2e>
    800036e6:	00092503          	lw	a0,0(s2)
    800036ea:	00000097          	auipc	ra,0x0
    800036ee:	e22080e7          	jalr	-478(ra) # 8000350c <balloc>
    800036f2:	0005099b          	sext.w	s3,a0
    800036f6:	0134a023          	sw	s3,0(s1)
    800036fa:	8552                	mv	a0,s4
    800036fc:	00001097          	auipc	ra,0x1
    80003700:	ef4080e7          	jalr	-268(ra) # 800045f0 <log_write>
    80003704:	b769                	j	8000368e <bmap+0x54>
    80003706:	00005517          	auipc	a0,0x5
    8000370a:	d4250513          	add	a0,a0,-702 # 80008448 <etext+0x448>
    8000370e:	ffffd097          	auipc	ra,0xffffd
    80003712:	e4c080e7          	jalr	-436(ra) # 8000055a <panic>

0000000080003716 <iget>:
    80003716:	7179                	add	sp,sp,-48
    80003718:	f406                	sd	ra,40(sp)
    8000371a:	f022                	sd	s0,32(sp)
    8000371c:	ec26                	sd	s1,24(sp)
    8000371e:	e84a                	sd	s2,16(sp)
    80003720:	e44e                	sd	s3,8(sp)
    80003722:	e052                	sd	s4,0(sp)
    80003724:	1800                	add	s0,sp,48
    80003726:	89aa                	mv	s3,a0
    80003728:	8a2e                	mv	s4,a1
    8000372a:	0001d517          	auipc	a0,0x1d
    8000372e:	c9e50513          	add	a0,a0,-866 # 800203c8 <itable>
    80003732:	ffffd097          	auipc	ra,0xffffd
    80003736:	500080e7          	jalr	1280(ra) # 80000c32 <acquire>
    8000373a:	4901                	li	s2,0
    8000373c:	0001d497          	auipc	s1,0x1d
    80003740:	ca448493          	add	s1,s1,-860 # 800203e0 <itable+0x18>
    80003744:	0001e697          	auipc	a3,0x1e
    80003748:	72c68693          	add	a3,a3,1836 # 80021e70 <log>
    8000374c:	a039                	j	8000375a <iget+0x44>
    8000374e:	02090b63          	beqz	s2,80003784 <iget+0x6e>
    80003752:	08848493          	add	s1,s1,136
    80003756:	02d48a63          	beq	s1,a3,8000378a <iget+0x74>
    8000375a:	449c                	lw	a5,8(s1)
    8000375c:	fef059e3          	blez	a5,8000374e <iget+0x38>
    80003760:	4098                	lw	a4,0(s1)
    80003762:	ff3716e3          	bne	a4,s3,8000374e <iget+0x38>
    80003766:	40d8                	lw	a4,4(s1)
    80003768:	ff4713e3          	bne	a4,s4,8000374e <iget+0x38>
    8000376c:	2785                	addw	a5,a5,1
    8000376e:	c49c                	sw	a5,8(s1)
    80003770:	0001d517          	auipc	a0,0x1d
    80003774:	c5850513          	add	a0,a0,-936 # 800203c8 <itable>
    80003778:	ffffd097          	auipc	ra,0xffffd
    8000377c:	56e080e7          	jalr	1390(ra) # 80000ce6 <release>
    80003780:	8926                	mv	s2,s1
    80003782:	a03d                	j	800037b0 <iget+0x9a>
    80003784:	f7f9                	bnez	a5,80003752 <iget+0x3c>
    80003786:	8926                	mv	s2,s1
    80003788:	b7e9                	j	80003752 <iget+0x3c>
    8000378a:	02090c63          	beqz	s2,800037c2 <iget+0xac>
    8000378e:	01392023          	sw	s3,0(s2)
    80003792:	01492223          	sw	s4,4(s2)
    80003796:	4785                	li	a5,1
    80003798:	00f92423          	sw	a5,8(s2)
    8000379c:	04092023          	sw	zero,64(s2)
    800037a0:	0001d517          	auipc	a0,0x1d
    800037a4:	c2850513          	add	a0,a0,-984 # 800203c8 <itable>
    800037a8:	ffffd097          	auipc	ra,0xffffd
    800037ac:	53e080e7          	jalr	1342(ra) # 80000ce6 <release>
    800037b0:	854a                	mv	a0,s2
    800037b2:	70a2                	ld	ra,40(sp)
    800037b4:	7402                	ld	s0,32(sp)
    800037b6:	64e2                	ld	s1,24(sp)
    800037b8:	6942                	ld	s2,16(sp)
    800037ba:	69a2                	ld	s3,8(sp)
    800037bc:	6a02                	ld	s4,0(sp)
    800037be:	6145                	add	sp,sp,48
    800037c0:	8082                	ret
    800037c2:	00005517          	auipc	a0,0x5
    800037c6:	c9e50513          	add	a0,a0,-866 # 80008460 <etext+0x460>
    800037ca:	ffffd097          	auipc	ra,0xffffd
    800037ce:	d90080e7          	jalr	-624(ra) # 8000055a <panic>

00000000800037d2 <fsinit>:
    800037d2:	7179                	add	sp,sp,-48
    800037d4:	f406                	sd	ra,40(sp)
    800037d6:	f022                	sd	s0,32(sp)
    800037d8:	ec26                	sd	s1,24(sp)
    800037da:	e84a                	sd	s2,16(sp)
    800037dc:	e44e                	sd	s3,8(sp)
    800037de:	1800                	add	s0,sp,48
    800037e0:	892a                	mv	s2,a0
    800037e2:	4585                	li	a1,1
    800037e4:	00000097          	auipc	ra,0x0
    800037e8:	a68080e7          	jalr	-1432(ra) # 8000324c <bread>
    800037ec:	84aa                	mv	s1,a0
    800037ee:	0001d997          	auipc	s3,0x1d
    800037f2:	bba98993          	add	s3,s3,-1094 # 800203a8 <sb>
    800037f6:	02000613          	li	a2,32
    800037fa:	05850593          	add	a1,a0,88
    800037fe:	854e                	mv	a0,s3
    80003800:	ffffd097          	auipc	ra,0xffffd
    80003804:	58a080e7          	jalr	1418(ra) # 80000d8a <memmove>
    80003808:	8526                	mv	a0,s1
    8000380a:	00000097          	auipc	ra,0x0
    8000380e:	b72080e7          	jalr	-1166(ra) # 8000337c <brelse>
    80003812:	0009a703          	lw	a4,0(s3)
    80003816:	102037b7          	lui	a5,0x10203
    8000381a:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000381e:	02f71263          	bne	a4,a5,80003842 <fsinit+0x70>
    80003822:	0001d597          	auipc	a1,0x1d
    80003826:	b8658593          	add	a1,a1,-1146 # 800203a8 <sb>
    8000382a:	854a                	mv	a0,s2
    8000382c:	00001097          	auipc	ra,0x1
    80003830:	b54080e7          	jalr	-1196(ra) # 80004380 <initlog>
    80003834:	70a2                	ld	ra,40(sp)
    80003836:	7402                	ld	s0,32(sp)
    80003838:	64e2                	ld	s1,24(sp)
    8000383a:	6942                	ld	s2,16(sp)
    8000383c:	69a2                	ld	s3,8(sp)
    8000383e:	6145                	add	sp,sp,48
    80003840:	8082                	ret
    80003842:	00005517          	auipc	a0,0x5
    80003846:	c2e50513          	add	a0,a0,-978 # 80008470 <etext+0x470>
    8000384a:	ffffd097          	auipc	ra,0xffffd
    8000384e:	d10080e7          	jalr	-752(ra) # 8000055a <panic>

0000000080003852 <iinit>:
    80003852:	7179                	add	sp,sp,-48
    80003854:	f406                	sd	ra,40(sp)
    80003856:	f022                	sd	s0,32(sp)
    80003858:	ec26                	sd	s1,24(sp)
    8000385a:	e84a                	sd	s2,16(sp)
    8000385c:	e44e                	sd	s3,8(sp)
    8000385e:	1800                	add	s0,sp,48
    80003860:	00005597          	auipc	a1,0x5
    80003864:	c2858593          	add	a1,a1,-984 # 80008488 <etext+0x488>
    80003868:	0001d517          	auipc	a0,0x1d
    8000386c:	b6050513          	add	a0,a0,-1184 # 800203c8 <itable>
    80003870:	ffffd097          	auipc	ra,0xffffd
    80003874:	332080e7          	jalr	818(ra) # 80000ba2 <initlock>
    80003878:	0001d497          	auipc	s1,0x1d
    8000387c:	b7848493          	add	s1,s1,-1160 # 800203f0 <itable+0x28>
    80003880:	0001e997          	auipc	s3,0x1e
    80003884:	60098993          	add	s3,s3,1536 # 80021e80 <log+0x10>
    80003888:	00005917          	auipc	s2,0x5
    8000388c:	c0890913          	add	s2,s2,-1016 # 80008490 <etext+0x490>
    80003890:	85ca                	mv	a1,s2
    80003892:	8526                	mv	a0,s1
    80003894:	00001097          	auipc	ra,0x1
    80003898:	e40080e7          	jalr	-448(ra) # 800046d4 <initsleeplock>
    8000389c:	08848493          	add	s1,s1,136
    800038a0:	ff3498e3          	bne	s1,s3,80003890 <iinit+0x3e>
    800038a4:	70a2                	ld	ra,40(sp)
    800038a6:	7402                	ld	s0,32(sp)
    800038a8:	64e2                	ld	s1,24(sp)
    800038aa:	6942                	ld	s2,16(sp)
    800038ac:	69a2                	ld	s3,8(sp)
    800038ae:	6145                	add	sp,sp,48
    800038b0:	8082                	ret

00000000800038b2 <ialloc>:
    800038b2:	7139                	add	sp,sp,-64
    800038b4:	fc06                	sd	ra,56(sp)
    800038b6:	f822                	sd	s0,48(sp)
    800038b8:	f426                	sd	s1,40(sp)
    800038ba:	f04a                	sd	s2,32(sp)
    800038bc:	ec4e                	sd	s3,24(sp)
    800038be:	e852                	sd	s4,16(sp)
    800038c0:	e456                	sd	s5,8(sp)
    800038c2:	e05a                	sd	s6,0(sp)
    800038c4:	0080                	add	s0,sp,64
    800038c6:	0001d717          	auipc	a4,0x1d
    800038ca:	aee72703          	lw	a4,-1298(a4) # 800203b4 <sb+0xc>
    800038ce:	4785                	li	a5,1
    800038d0:	04e7f863          	bgeu	a5,a4,80003920 <ialloc+0x6e>
    800038d4:	8aaa                	mv	s5,a0
    800038d6:	8b2e                	mv	s6,a1
    800038d8:	4905                	li	s2,1
    800038da:	0001da17          	auipc	s4,0x1d
    800038de:	acea0a13          	add	s4,s4,-1330 # 800203a8 <sb>
    800038e2:	00495593          	srl	a1,s2,0x4
    800038e6:	018a2783          	lw	a5,24(s4)
    800038ea:	9dbd                	addw	a1,a1,a5
    800038ec:	8556                	mv	a0,s5
    800038ee:	00000097          	auipc	ra,0x0
    800038f2:	95e080e7          	jalr	-1698(ra) # 8000324c <bread>
    800038f6:	84aa                	mv	s1,a0
    800038f8:	05850993          	add	s3,a0,88
    800038fc:	00f97793          	and	a5,s2,15
    80003900:	079a                	sll	a5,a5,0x6
    80003902:	99be                	add	s3,s3,a5
    80003904:	00099783          	lh	a5,0(s3)
    80003908:	c785                	beqz	a5,80003930 <ialloc+0x7e>
    8000390a:	00000097          	auipc	ra,0x0
    8000390e:	a72080e7          	jalr	-1422(ra) # 8000337c <brelse>
    80003912:	0905                	add	s2,s2,1
    80003914:	00ca2703          	lw	a4,12(s4)
    80003918:	0009079b          	sext.w	a5,s2
    8000391c:	fce7e3e3          	bltu	a5,a4,800038e2 <ialloc+0x30>
    80003920:	00005517          	auipc	a0,0x5
    80003924:	b7850513          	add	a0,a0,-1160 # 80008498 <etext+0x498>
    80003928:	ffffd097          	auipc	ra,0xffffd
    8000392c:	c32080e7          	jalr	-974(ra) # 8000055a <panic>
    80003930:	04000613          	li	a2,64
    80003934:	4581                	li	a1,0
    80003936:	854e                	mv	a0,s3
    80003938:	ffffd097          	auipc	ra,0xffffd
    8000393c:	3f6080e7          	jalr	1014(ra) # 80000d2e <memset>
    80003940:	01699023          	sh	s6,0(s3)
    80003944:	8526                	mv	a0,s1
    80003946:	00001097          	auipc	ra,0x1
    8000394a:	caa080e7          	jalr	-854(ra) # 800045f0 <log_write>
    8000394e:	8526                	mv	a0,s1
    80003950:	00000097          	auipc	ra,0x0
    80003954:	a2c080e7          	jalr	-1492(ra) # 8000337c <brelse>
    80003958:	0009059b          	sext.w	a1,s2
    8000395c:	8556                	mv	a0,s5
    8000395e:	00000097          	auipc	ra,0x0
    80003962:	db8080e7          	jalr	-584(ra) # 80003716 <iget>
    80003966:	70e2                	ld	ra,56(sp)
    80003968:	7442                	ld	s0,48(sp)
    8000396a:	74a2                	ld	s1,40(sp)
    8000396c:	7902                	ld	s2,32(sp)
    8000396e:	69e2                	ld	s3,24(sp)
    80003970:	6a42                	ld	s4,16(sp)
    80003972:	6aa2                	ld	s5,8(sp)
    80003974:	6b02                	ld	s6,0(sp)
    80003976:	6121                	add	sp,sp,64
    80003978:	8082                	ret

000000008000397a <iupdate>:
    8000397a:	1101                	add	sp,sp,-32
    8000397c:	ec06                	sd	ra,24(sp)
    8000397e:	e822                	sd	s0,16(sp)
    80003980:	e426                	sd	s1,8(sp)
    80003982:	e04a                	sd	s2,0(sp)
    80003984:	1000                	add	s0,sp,32
    80003986:	84aa                	mv	s1,a0
    80003988:	415c                	lw	a5,4(a0)
    8000398a:	0047d79b          	srlw	a5,a5,0x4
    8000398e:	0001d597          	auipc	a1,0x1d
    80003992:	a325a583          	lw	a1,-1486(a1) # 800203c0 <sb+0x18>
    80003996:	9dbd                	addw	a1,a1,a5
    80003998:	4108                	lw	a0,0(a0)
    8000399a:	00000097          	auipc	ra,0x0
    8000399e:	8b2080e7          	jalr	-1870(ra) # 8000324c <bread>
    800039a2:	892a                	mv	s2,a0
    800039a4:	05850793          	add	a5,a0,88
    800039a8:	40d8                	lw	a4,4(s1)
    800039aa:	8b3d                	and	a4,a4,15
    800039ac:	071a                	sll	a4,a4,0x6
    800039ae:	97ba                	add	a5,a5,a4
    800039b0:	04449703          	lh	a4,68(s1)
    800039b4:	00e79023          	sh	a4,0(a5)
    800039b8:	04649703          	lh	a4,70(s1)
    800039bc:	00e79123          	sh	a4,2(a5)
    800039c0:	04849703          	lh	a4,72(s1)
    800039c4:	00e79223          	sh	a4,4(a5)
    800039c8:	04a49703          	lh	a4,74(s1)
    800039cc:	00e79323          	sh	a4,6(a5)
    800039d0:	44f8                	lw	a4,76(s1)
    800039d2:	c798                	sw	a4,8(a5)
    800039d4:	03400613          	li	a2,52
    800039d8:	05048593          	add	a1,s1,80
    800039dc:	00c78513          	add	a0,a5,12
    800039e0:	ffffd097          	auipc	ra,0xffffd
    800039e4:	3aa080e7          	jalr	938(ra) # 80000d8a <memmove>
    800039e8:	854a                	mv	a0,s2
    800039ea:	00001097          	auipc	ra,0x1
    800039ee:	c06080e7          	jalr	-1018(ra) # 800045f0 <log_write>
    800039f2:	854a                	mv	a0,s2
    800039f4:	00000097          	auipc	ra,0x0
    800039f8:	988080e7          	jalr	-1656(ra) # 8000337c <brelse>
    800039fc:	60e2                	ld	ra,24(sp)
    800039fe:	6442                	ld	s0,16(sp)
    80003a00:	64a2                	ld	s1,8(sp)
    80003a02:	6902                	ld	s2,0(sp)
    80003a04:	6105                	add	sp,sp,32
    80003a06:	8082                	ret

0000000080003a08 <idup>:
    80003a08:	1101                	add	sp,sp,-32
    80003a0a:	ec06                	sd	ra,24(sp)
    80003a0c:	e822                	sd	s0,16(sp)
    80003a0e:	e426                	sd	s1,8(sp)
    80003a10:	1000                	add	s0,sp,32
    80003a12:	84aa                	mv	s1,a0
    80003a14:	0001d517          	auipc	a0,0x1d
    80003a18:	9b450513          	add	a0,a0,-1612 # 800203c8 <itable>
    80003a1c:	ffffd097          	auipc	ra,0xffffd
    80003a20:	216080e7          	jalr	534(ra) # 80000c32 <acquire>
    80003a24:	449c                	lw	a5,8(s1)
    80003a26:	2785                	addw	a5,a5,1
    80003a28:	c49c                	sw	a5,8(s1)
    80003a2a:	0001d517          	auipc	a0,0x1d
    80003a2e:	99e50513          	add	a0,a0,-1634 # 800203c8 <itable>
    80003a32:	ffffd097          	auipc	ra,0xffffd
    80003a36:	2b4080e7          	jalr	692(ra) # 80000ce6 <release>
    80003a3a:	8526                	mv	a0,s1
    80003a3c:	60e2                	ld	ra,24(sp)
    80003a3e:	6442                	ld	s0,16(sp)
    80003a40:	64a2                	ld	s1,8(sp)
    80003a42:	6105                	add	sp,sp,32
    80003a44:	8082                	ret

0000000080003a46 <ilock>:
    80003a46:	1101                	add	sp,sp,-32
    80003a48:	ec06                	sd	ra,24(sp)
    80003a4a:	e822                	sd	s0,16(sp)
    80003a4c:	e426                	sd	s1,8(sp)
    80003a4e:	1000                	add	s0,sp,32
    80003a50:	c10d                	beqz	a0,80003a72 <ilock+0x2c>
    80003a52:	84aa                	mv	s1,a0
    80003a54:	451c                	lw	a5,8(a0)
    80003a56:	00f05e63          	blez	a5,80003a72 <ilock+0x2c>
    80003a5a:	0541                	add	a0,a0,16
    80003a5c:	00001097          	auipc	ra,0x1
    80003a60:	cb2080e7          	jalr	-846(ra) # 8000470e <acquiresleep>
    80003a64:	40bc                	lw	a5,64(s1)
    80003a66:	cf99                	beqz	a5,80003a84 <ilock+0x3e>
    80003a68:	60e2                	ld	ra,24(sp)
    80003a6a:	6442                	ld	s0,16(sp)
    80003a6c:	64a2                	ld	s1,8(sp)
    80003a6e:	6105                	add	sp,sp,32
    80003a70:	8082                	ret
    80003a72:	e04a                	sd	s2,0(sp)
    80003a74:	00005517          	auipc	a0,0x5
    80003a78:	a3c50513          	add	a0,a0,-1476 # 800084b0 <etext+0x4b0>
    80003a7c:	ffffd097          	auipc	ra,0xffffd
    80003a80:	ade080e7          	jalr	-1314(ra) # 8000055a <panic>
    80003a84:	e04a                	sd	s2,0(sp)
    80003a86:	40dc                	lw	a5,4(s1)
    80003a88:	0047d79b          	srlw	a5,a5,0x4
    80003a8c:	0001d597          	auipc	a1,0x1d
    80003a90:	9345a583          	lw	a1,-1740(a1) # 800203c0 <sb+0x18>
    80003a94:	9dbd                	addw	a1,a1,a5
    80003a96:	4088                	lw	a0,0(s1)
    80003a98:	fffff097          	auipc	ra,0xfffff
    80003a9c:	7b4080e7          	jalr	1972(ra) # 8000324c <bread>
    80003aa0:	892a                	mv	s2,a0
    80003aa2:	05850593          	add	a1,a0,88
    80003aa6:	40dc                	lw	a5,4(s1)
    80003aa8:	8bbd                	and	a5,a5,15
    80003aaa:	079a                	sll	a5,a5,0x6
    80003aac:	95be                	add	a1,a1,a5
    80003aae:	00059783          	lh	a5,0(a1)
    80003ab2:	04f49223          	sh	a5,68(s1)
    80003ab6:	00259783          	lh	a5,2(a1)
    80003aba:	04f49323          	sh	a5,70(s1)
    80003abe:	00459783          	lh	a5,4(a1)
    80003ac2:	04f49423          	sh	a5,72(s1)
    80003ac6:	00659783          	lh	a5,6(a1)
    80003aca:	04f49523          	sh	a5,74(s1)
    80003ace:	459c                	lw	a5,8(a1)
    80003ad0:	c4fc                	sw	a5,76(s1)
    80003ad2:	03400613          	li	a2,52
    80003ad6:	05b1                	add	a1,a1,12
    80003ad8:	05048513          	add	a0,s1,80
    80003adc:	ffffd097          	auipc	ra,0xffffd
    80003ae0:	2ae080e7          	jalr	686(ra) # 80000d8a <memmove>
    80003ae4:	854a                	mv	a0,s2
    80003ae6:	00000097          	auipc	ra,0x0
    80003aea:	896080e7          	jalr	-1898(ra) # 8000337c <brelse>
    80003aee:	4785                	li	a5,1
    80003af0:	c0bc                	sw	a5,64(s1)
    80003af2:	04449783          	lh	a5,68(s1)
    80003af6:	c399                	beqz	a5,80003afc <ilock+0xb6>
    80003af8:	6902                	ld	s2,0(sp)
    80003afa:	b7bd                	j	80003a68 <ilock+0x22>
    80003afc:	00005517          	auipc	a0,0x5
    80003b00:	9bc50513          	add	a0,a0,-1604 # 800084b8 <etext+0x4b8>
    80003b04:	ffffd097          	auipc	ra,0xffffd
    80003b08:	a56080e7          	jalr	-1450(ra) # 8000055a <panic>

0000000080003b0c <iunlock>:
    80003b0c:	1101                	add	sp,sp,-32
    80003b0e:	ec06                	sd	ra,24(sp)
    80003b10:	e822                	sd	s0,16(sp)
    80003b12:	e426                	sd	s1,8(sp)
    80003b14:	e04a                	sd	s2,0(sp)
    80003b16:	1000                	add	s0,sp,32
    80003b18:	c905                	beqz	a0,80003b48 <iunlock+0x3c>
    80003b1a:	84aa                	mv	s1,a0
    80003b1c:	01050913          	add	s2,a0,16
    80003b20:	854a                	mv	a0,s2
    80003b22:	00001097          	auipc	ra,0x1
    80003b26:	c86080e7          	jalr	-890(ra) # 800047a8 <holdingsleep>
    80003b2a:	cd19                	beqz	a0,80003b48 <iunlock+0x3c>
    80003b2c:	449c                	lw	a5,8(s1)
    80003b2e:	00f05d63          	blez	a5,80003b48 <iunlock+0x3c>
    80003b32:	854a                	mv	a0,s2
    80003b34:	00001097          	auipc	ra,0x1
    80003b38:	c30080e7          	jalr	-976(ra) # 80004764 <releasesleep>
    80003b3c:	60e2                	ld	ra,24(sp)
    80003b3e:	6442                	ld	s0,16(sp)
    80003b40:	64a2                	ld	s1,8(sp)
    80003b42:	6902                	ld	s2,0(sp)
    80003b44:	6105                	add	sp,sp,32
    80003b46:	8082                	ret
    80003b48:	00005517          	auipc	a0,0x5
    80003b4c:	98050513          	add	a0,a0,-1664 # 800084c8 <etext+0x4c8>
    80003b50:	ffffd097          	auipc	ra,0xffffd
    80003b54:	a0a080e7          	jalr	-1526(ra) # 8000055a <panic>

0000000080003b58 <itrunc>:
    80003b58:	7179                	add	sp,sp,-48
    80003b5a:	f406                	sd	ra,40(sp)
    80003b5c:	f022                	sd	s0,32(sp)
    80003b5e:	ec26                	sd	s1,24(sp)
    80003b60:	e84a                	sd	s2,16(sp)
    80003b62:	e44e                	sd	s3,8(sp)
    80003b64:	1800                	add	s0,sp,48
    80003b66:	89aa                	mv	s3,a0
    80003b68:	05050493          	add	s1,a0,80
    80003b6c:	08050913          	add	s2,a0,128
    80003b70:	a021                	j	80003b78 <itrunc+0x20>
    80003b72:	0491                	add	s1,s1,4
    80003b74:	01248d63          	beq	s1,s2,80003b8e <itrunc+0x36>
    80003b78:	408c                	lw	a1,0(s1)
    80003b7a:	dde5                	beqz	a1,80003b72 <itrunc+0x1a>
    80003b7c:	0009a503          	lw	a0,0(s3)
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	910080e7          	jalr	-1776(ra) # 80003490 <bfree>
    80003b88:	0004a023          	sw	zero,0(s1)
    80003b8c:	b7dd                	j	80003b72 <itrunc+0x1a>
    80003b8e:	0809a583          	lw	a1,128(s3)
    80003b92:	ed99                	bnez	a1,80003bb0 <itrunc+0x58>
    80003b94:	0409a623          	sw	zero,76(s3)
    80003b98:	854e                	mv	a0,s3
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	de0080e7          	jalr	-544(ra) # 8000397a <iupdate>
    80003ba2:	70a2                	ld	ra,40(sp)
    80003ba4:	7402                	ld	s0,32(sp)
    80003ba6:	64e2                	ld	s1,24(sp)
    80003ba8:	6942                	ld	s2,16(sp)
    80003baa:	69a2                	ld	s3,8(sp)
    80003bac:	6145                	add	sp,sp,48
    80003bae:	8082                	ret
    80003bb0:	e052                	sd	s4,0(sp)
    80003bb2:	0009a503          	lw	a0,0(s3)
    80003bb6:	fffff097          	auipc	ra,0xfffff
    80003bba:	696080e7          	jalr	1686(ra) # 8000324c <bread>
    80003bbe:	8a2a                	mv	s4,a0
    80003bc0:	05850493          	add	s1,a0,88
    80003bc4:	45850913          	add	s2,a0,1112
    80003bc8:	a021                	j	80003bd0 <itrunc+0x78>
    80003bca:	0491                	add	s1,s1,4
    80003bcc:	01248b63          	beq	s1,s2,80003be2 <itrunc+0x8a>
    80003bd0:	408c                	lw	a1,0(s1)
    80003bd2:	dde5                	beqz	a1,80003bca <itrunc+0x72>
    80003bd4:	0009a503          	lw	a0,0(s3)
    80003bd8:	00000097          	auipc	ra,0x0
    80003bdc:	8b8080e7          	jalr	-1864(ra) # 80003490 <bfree>
    80003be0:	b7ed                	j	80003bca <itrunc+0x72>
    80003be2:	8552                	mv	a0,s4
    80003be4:	fffff097          	auipc	ra,0xfffff
    80003be8:	798080e7          	jalr	1944(ra) # 8000337c <brelse>
    80003bec:	0809a583          	lw	a1,128(s3)
    80003bf0:	0009a503          	lw	a0,0(s3)
    80003bf4:	00000097          	auipc	ra,0x0
    80003bf8:	89c080e7          	jalr	-1892(ra) # 80003490 <bfree>
    80003bfc:	0809a023          	sw	zero,128(s3)
    80003c00:	6a02                	ld	s4,0(sp)
    80003c02:	bf49                	j	80003b94 <itrunc+0x3c>

0000000080003c04 <iput>:
    80003c04:	1101                	add	sp,sp,-32
    80003c06:	ec06                	sd	ra,24(sp)
    80003c08:	e822                	sd	s0,16(sp)
    80003c0a:	e426                	sd	s1,8(sp)
    80003c0c:	1000                	add	s0,sp,32
    80003c0e:	84aa                	mv	s1,a0
    80003c10:	0001c517          	auipc	a0,0x1c
    80003c14:	7b850513          	add	a0,a0,1976 # 800203c8 <itable>
    80003c18:	ffffd097          	auipc	ra,0xffffd
    80003c1c:	01a080e7          	jalr	26(ra) # 80000c32 <acquire>
    80003c20:	4498                	lw	a4,8(s1)
    80003c22:	4785                	li	a5,1
    80003c24:	02f70263          	beq	a4,a5,80003c48 <iput+0x44>
    80003c28:	449c                	lw	a5,8(s1)
    80003c2a:	37fd                	addw	a5,a5,-1
    80003c2c:	c49c                	sw	a5,8(s1)
    80003c2e:	0001c517          	auipc	a0,0x1c
    80003c32:	79a50513          	add	a0,a0,1946 # 800203c8 <itable>
    80003c36:	ffffd097          	auipc	ra,0xffffd
    80003c3a:	0b0080e7          	jalr	176(ra) # 80000ce6 <release>
    80003c3e:	60e2                	ld	ra,24(sp)
    80003c40:	6442                	ld	s0,16(sp)
    80003c42:	64a2                	ld	s1,8(sp)
    80003c44:	6105                	add	sp,sp,32
    80003c46:	8082                	ret
    80003c48:	40bc                	lw	a5,64(s1)
    80003c4a:	dff9                	beqz	a5,80003c28 <iput+0x24>
    80003c4c:	04a49783          	lh	a5,74(s1)
    80003c50:	ffe1                	bnez	a5,80003c28 <iput+0x24>
    80003c52:	e04a                	sd	s2,0(sp)
    80003c54:	01048913          	add	s2,s1,16
    80003c58:	854a                	mv	a0,s2
    80003c5a:	00001097          	auipc	ra,0x1
    80003c5e:	ab4080e7          	jalr	-1356(ra) # 8000470e <acquiresleep>
    80003c62:	0001c517          	auipc	a0,0x1c
    80003c66:	76650513          	add	a0,a0,1894 # 800203c8 <itable>
    80003c6a:	ffffd097          	auipc	ra,0xffffd
    80003c6e:	07c080e7          	jalr	124(ra) # 80000ce6 <release>
    80003c72:	8526                	mv	a0,s1
    80003c74:	00000097          	auipc	ra,0x0
    80003c78:	ee4080e7          	jalr	-284(ra) # 80003b58 <itrunc>
    80003c7c:	04049223          	sh	zero,68(s1)
    80003c80:	8526                	mv	a0,s1
    80003c82:	00000097          	auipc	ra,0x0
    80003c86:	cf8080e7          	jalr	-776(ra) # 8000397a <iupdate>
    80003c8a:	0404a023          	sw	zero,64(s1)
    80003c8e:	854a                	mv	a0,s2
    80003c90:	00001097          	auipc	ra,0x1
    80003c94:	ad4080e7          	jalr	-1324(ra) # 80004764 <releasesleep>
    80003c98:	0001c517          	auipc	a0,0x1c
    80003c9c:	73050513          	add	a0,a0,1840 # 800203c8 <itable>
    80003ca0:	ffffd097          	auipc	ra,0xffffd
    80003ca4:	f92080e7          	jalr	-110(ra) # 80000c32 <acquire>
    80003ca8:	6902                	ld	s2,0(sp)
    80003caa:	bfbd                	j	80003c28 <iput+0x24>

0000000080003cac <iunlockput>:
    80003cac:	1101                	add	sp,sp,-32
    80003cae:	ec06                	sd	ra,24(sp)
    80003cb0:	e822                	sd	s0,16(sp)
    80003cb2:	e426                	sd	s1,8(sp)
    80003cb4:	1000                	add	s0,sp,32
    80003cb6:	84aa                	mv	s1,a0
    80003cb8:	00000097          	auipc	ra,0x0
    80003cbc:	e54080e7          	jalr	-428(ra) # 80003b0c <iunlock>
    80003cc0:	8526                	mv	a0,s1
    80003cc2:	00000097          	auipc	ra,0x0
    80003cc6:	f42080e7          	jalr	-190(ra) # 80003c04 <iput>
    80003cca:	60e2                	ld	ra,24(sp)
    80003ccc:	6442                	ld	s0,16(sp)
    80003cce:	64a2                	ld	s1,8(sp)
    80003cd0:	6105                	add	sp,sp,32
    80003cd2:	8082                	ret

0000000080003cd4 <stati>:
    80003cd4:	1141                	add	sp,sp,-16
    80003cd6:	e422                	sd	s0,8(sp)
    80003cd8:	0800                	add	s0,sp,16
    80003cda:	411c                	lw	a5,0(a0)
    80003cdc:	c19c                	sw	a5,0(a1)
    80003cde:	415c                	lw	a5,4(a0)
    80003ce0:	c1dc                	sw	a5,4(a1)
    80003ce2:	04451783          	lh	a5,68(a0)
    80003ce6:	00f59423          	sh	a5,8(a1)
    80003cea:	04a51783          	lh	a5,74(a0)
    80003cee:	00f59523          	sh	a5,10(a1)
    80003cf2:	04c56783          	lwu	a5,76(a0)
    80003cf6:	e99c                	sd	a5,16(a1)
    80003cf8:	6422                	ld	s0,8(sp)
    80003cfa:	0141                	add	sp,sp,16
    80003cfc:	8082                	ret

0000000080003cfe <readi>:
    80003cfe:	457c                	lw	a5,76(a0)
    80003d00:	0ed7ef63          	bltu	a5,a3,80003dfe <readi+0x100>
    80003d04:	7159                	add	sp,sp,-112
    80003d06:	f486                	sd	ra,104(sp)
    80003d08:	f0a2                	sd	s0,96(sp)
    80003d0a:	eca6                	sd	s1,88(sp)
    80003d0c:	fc56                	sd	s5,56(sp)
    80003d0e:	f85a                	sd	s6,48(sp)
    80003d10:	f45e                	sd	s7,40(sp)
    80003d12:	f062                	sd	s8,32(sp)
    80003d14:	1880                	add	s0,sp,112
    80003d16:	8baa                	mv	s7,a0
    80003d18:	8c2e                	mv	s8,a1
    80003d1a:	8ab2                	mv	s5,a2
    80003d1c:	84b6                	mv	s1,a3
    80003d1e:	8b3a                	mv	s6,a4
    80003d20:	9f35                	addw	a4,a4,a3
    80003d22:	4501                	li	a0,0
    80003d24:	0ad76c63          	bltu	a4,a3,80003ddc <readi+0xde>
    80003d28:	e4ce                	sd	s3,72(sp)
    80003d2a:	00e7f463          	bgeu	a5,a4,80003d32 <readi+0x34>
    80003d2e:	40d78b3b          	subw	s6,a5,a3
    80003d32:	0c0b0463          	beqz	s6,80003dfa <readi+0xfc>
    80003d36:	e8ca                	sd	s2,80(sp)
    80003d38:	e0d2                	sd	s4,64(sp)
    80003d3a:	ec66                	sd	s9,24(sp)
    80003d3c:	e86a                	sd	s10,16(sp)
    80003d3e:	e46e                	sd	s11,8(sp)
    80003d40:	4981                	li	s3,0
    80003d42:	40000d13          	li	s10,1024
    80003d46:	5cfd                	li	s9,-1
    80003d48:	a82d                	j	80003d82 <readi+0x84>
    80003d4a:	020a1d93          	sll	s11,s4,0x20
    80003d4e:	020ddd93          	srl	s11,s11,0x20
    80003d52:	05890613          	add	a2,s2,88
    80003d56:	86ee                	mv	a3,s11
    80003d58:	963a                	add	a2,a2,a4
    80003d5a:	85d6                	mv	a1,s5
    80003d5c:	8562                	mv	a0,s8
    80003d5e:	ffffe097          	auipc	ra,0xffffe
    80003d62:	75a080e7          	jalr	1882(ra) # 800024b8 <either_copyout>
    80003d66:	05950d63          	beq	a0,s9,80003dc0 <readi+0xc2>
    80003d6a:	854a                	mv	a0,s2
    80003d6c:	fffff097          	auipc	ra,0xfffff
    80003d70:	610080e7          	jalr	1552(ra) # 8000337c <brelse>
    80003d74:	013a09bb          	addw	s3,s4,s3
    80003d78:	009a04bb          	addw	s1,s4,s1
    80003d7c:	9aee                	add	s5,s5,s11
    80003d7e:	0769f863          	bgeu	s3,s6,80003dee <readi+0xf0>
    80003d82:	000ba903          	lw	s2,0(s7)
    80003d86:	00a4d59b          	srlw	a1,s1,0xa
    80003d8a:	855e                	mv	a0,s7
    80003d8c:	00000097          	auipc	ra,0x0
    80003d90:	8ae080e7          	jalr	-1874(ra) # 8000363a <bmap>
    80003d94:	0005059b          	sext.w	a1,a0
    80003d98:	854a                	mv	a0,s2
    80003d9a:	fffff097          	auipc	ra,0xfffff
    80003d9e:	4b2080e7          	jalr	1202(ra) # 8000324c <bread>
    80003da2:	892a                	mv	s2,a0
    80003da4:	3ff4f713          	and	a4,s1,1023
    80003da8:	40ed07bb          	subw	a5,s10,a4
    80003dac:	413b06bb          	subw	a3,s6,s3
    80003db0:	8a3e                	mv	s4,a5
    80003db2:	2781                	sext.w	a5,a5
    80003db4:	0006861b          	sext.w	a2,a3
    80003db8:	f8f679e3          	bgeu	a2,a5,80003d4a <readi+0x4c>
    80003dbc:	8a36                	mv	s4,a3
    80003dbe:	b771                	j	80003d4a <readi+0x4c>
    80003dc0:	854a                	mv	a0,s2
    80003dc2:	fffff097          	auipc	ra,0xfffff
    80003dc6:	5ba080e7          	jalr	1466(ra) # 8000337c <brelse>
    80003dca:	59fd                	li	s3,-1
    80003dcc:	6946                	ld	s2,80(sp)
    80003dce:	6a06                	ld	s4,64(sp)
    80003dd0:	6ce2                	ld	s9,24(sp)
    80003dd2:	6d42                	ld	s10,16(sp)
    80003dd4:	6da2                	ld	s11,8(sp)
    80003dd6:	0009851b          	sext.w	a0,s3
    80003dda:	69a6                	ld	s3,72(sp)
    80003ddc:	70a6                	ld	ra,104(sp)
    80003dde:	7406                	ld	s0,96(sp)
    80003de0:	64e6                	ld	s1,88(sp)
    80003de2:	7ae2                	ld	s5,56(sp)
    80003de4:	7b42                	ld	s6,48(sp)
    80003de6:	7ba2                	ld	s7,40(sp)
    80003de8:	7c02                	ld	s8,32(sp)
    80003dea:	6165                	add	sp,sp,112
    80003dec:	8082                	ret
    80003dee:	6946                	ld	s2,80(sp)
    80003df0:	6a06                	ld	s4,64(sp)
    80003df2:	6ce2                	ld	s9,24(sp)
    80003df4:	6d42                	ld	s10,16(sp)
    80003df6:	6da2                	ld	s11,8(sp)
    80003df8:	bff9                	j	80003dd6 <readi+0xd8>
    80003dfa:	89da                	mv	s3,s6
    80003dfc:	bfe9                	j	80003dd6 <readi+0xd8>
    80003dfe:	4501                	li	a0,0
    80003e00:	8082                	ret

0000000080003e02 <writei>:
    80003e02:	457c                	lw	a5,76(a0)
    80003e04:	10d7ee63          	bltu	a5,a3,80003f20 <writei+0x11e>
    80003e08:	7159                	add	sp,sp,-112
    80003e0a:	f486                	sd	ra,104(sp)
    80003e0c:	f0a2                	sd	s0,96(sp)
    80003e0e:	e8ca                	sd	s2,80(sp)
    80003e10:	fc56                	sd	s5,56(sp)
    80003e12:	f85a                	sd	s6,48(sp)
    80003e14:	f45e                	sd	s7,40(sp)
    80003e16:	f062                	sd	s8,32(sp)
    80003e18:	1880                	add	s0,sp,112
    80003e1a:	8b2a                	mv	s6,a0
    80003e1c:	8c2e                	mv	s8,a1
    80003e1e:	8ab2                	mv	s5,a2
    80003e20:	8936                	mv	s2,a3
    80003e22:	8bba                	mv	s7,a4
    80003e24:	00e687bb          	addw	a5,a3,a4
    80003e28:	0ed7ee63          	bltu	a5,a3,80003f24 <writei+0x122>
    80003e2c:	00043737          	lui	a4,0x43
    80003e30:	0ef76c63          	bltu	a4,a5,80003f28 <writei+0x126>
    80003e34:	e0d2                	sd	s4,64(sp)
    80003e36:	0c0b8d63          	beqz	s7,80003f10 <writei+0x10e>
    80003e3a:	eca6                	sd	s1,88(sp)
    80003e3c:	e4ce                	sd	s3,72(sp)
    80003e3e:	ec66                	sd	s9,24(sp)
    80003e40:	e86a                	sd	s10,16(sp)
    80003e42:	e46e                	sd	s11,8(sp)
    80003e44:	4a01                	li	s4,0
    80003e46:	40000d13          	li	s10,1024
    80003e4a:	5cfd                	li	s9,-1
    80003e4c:	a091                	j	80003e90 <writei+0x8e>
    80003e4e:	02099d93          	sll	s11,s3,0x20
    80003e52:	020ddd93          	srl	s11,s11,0x20
    80003e56:	05848513          	add	a0,s1,88
    80003e5a:	86ee                	mv	a3,s11
    80003e5c:	8656                	mv	a2,s5
    80003e5e:	85e2                	mv	a1,s8
    80003e60:	953a                	add	a0,a0,a4
    80003e62:	ffffe097          	auipc	ra,0xffffe
    80003e66:	6ac080e7          	jalr	1708(ra) # 8000250e <either_copyin>
    80003e6a:	07950263          	beq	a0,s9,80003ece <writei+0xcc>
    80003e6e:	8526                	mv	a0,s1
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	780080e7          	jalr	1920(ra) # 800045f0 <log_write>
    80003e78:	8526                	mv	a0,s1
    80003e7a:	fffff097          	auipc	ra,0xfffff
    80003e7e:	502080e7          	jalr	1282(ra) # 8000337c <brelse>
    80003e82:	01498a3b          	addw	s4,s3,s4
    80003e86:	0129893b          	addw	s2,s3,s2
    80003e8a:	9aee                	add	s5,s5,s11
    80003e8c:	057a7663          	bgeu	s4,s7,80003ed8 <writei+0xd6>
    80003e90:	000b2483          	lw	s1,0(s6)
    80003e94:	00a9559b          	srlw	a1,s2,0xa
    80003e98:	855a                	mv	a0,s6
    80003e9a:	fffff097          	auipc	ra,0xfffff
    80003e9e:	7a0080e7          	jalr	1952(ra) # 8000363a <bmap>
    80003ea2:	0005059b          	sext.w	a1,a0
    80003ea6:	8526                	mv	a0,s1
    80003ea8:	fffff097          	auipc	ra,0xfffff
    80003eac:	3a4080e7          	jalr	932(ra) # 8000324c <bread>
    80003eb0:	84aa                	mv	s1,a0
    80003eb2:	3ff97713          	and	a4,s2,1023
    80003eb6:	40ed07bb          	subw	a5,s10,a4
    80003eba:	414b86bb          	subw	a3,s7,s4
    80003ebe:	89be                	mv	s3,a5
    80003ec0:	2781                	sext.w	a5,a5
    80003ec2:	0006861b          	sext.w	a2,a3
    80003ec6:	f8f674e3          	bgeu	a2,a5,80003e4e <writei+0x4c>
    80003eca:	89b6                	mv	s3,a3
    80003ecc:	b749                	j	80003e4e <writei+0x4c>
    80003ece:	8526                	mv	a0,s1
    80003ed0:	fffff097          	auipc	ra,0xfffff
    80003ed4:	4ac080e7          	jalr	1196(ra) # 8000337c <brelse>
    80003ed8:	04cb2783          	lw	a5,76(s6)
    80003edc:	0327fc63          	bgeu	a5,s2,80003f14 <writei+0x112>
    80003ee0:	052b2623          	sw	s2,76(s6)
    80003ee4:	64e6                	ld	s1,88(sp)
    80003ee6:	69a6                	ld	s3,72(sp)
    80003ee8:	6ce2                	ld	s9,24(sp)
    80003eea:	6d42                	ld	s10,16(sp)
    80003eec:	6da2                	ld	s11,8(sp)
    80003eee:	855a                	mv	a0,s6
    80003ef0:	00000097          	auipc	ra,0x0
    80003ef4:	a8a080e7          	jalr	-1398(ra) # 8000397a <iupdate>
    80003ef8:	000a051b          	sext.w	a0,s4
    80003efc:	6a06                	ld	s4,64(sp)
    80003efe:	70a6                	ld	ra,104(sp)
    80003f00:	7406                	ld	s0,96(sp)
    80003f02:	6946                	ld	s2,80(sp)
    80003f04:	7ae2                	ld	s5,56(sp)
    80003f06:	7b42                	ld	s6,48(sp)
    80003f08:	7ba2                	ld	s7,40(sp)
    80003f0a:	7c02                	ld	s8,32(sp)
    80003f0c:	6165                	add	sp,sp,112
    80003f0e:	8082                	ret
    80003f10:	8a5e                	mv	s4,s7
    80003f12:	bff1                	j	80003eee <writei+0xec>
    80003f14:	64e6                	ld	s1,88(sp)
    80003f16:	69a6                	ld	s3,72(sp)
    80003f18:	6ce2                	ld	s9,24(sp)
    80003f1a:	6d42                	ld	s10,16(sp)
    80003f1c:	6da2                	ld	s11,8(sp)
    80003f1e:	bfc1                	j	80003eee <writei+0xec>
    80003f20:	557d                	li	a0,-1
    80003f22:	8082                	ret
    80003f24:	557d                	li	a0,-1
    80003f26:	bfe1                	j	80003efe <writei+0xfc>
    80003f28:	557d                	li	a0,-1
    80003f2a:	bfd1                	j	80003efe <writei+0xfc>

0000000080003f2c <namecmp>:
    80003f2c:	1141                	add	sp,sp,-16
    80003f2e:	e406                	sd	ra,8(sp)
    80003f30:	e022                	sd	s0,0(sp)
    80003f32:	0800                	add	s0,sp,16
    80003f34:	4639                	li	a2,14
    80003f36:	ffffd097          	auipc	ra,0xffffd
    80003f3a:	ec8080e7          	jalr	-312(ra) # 80000dfe <strncmp>
    80003f3e:	60a2                	ld	ra,8(sp)
    80003f40:	6402                	ld	s0,0(sp)
    80003f42:	0141                	add	sp,sp,16
    80003f44:	8082                	ret

0000000080003f46 <dirlookup>:
    80003f46:	7139                	add	sp,sp,-64
    80003f48:	fc06                	sd	ra,56(sp)
    80003f4a:	f822                	sd	s0,48(sp)
    80003f4c:	f426                	sd	s1,40(sp)
    80003f4e:	f04a                	sd	s2,32(sp)
    80003f50:	ec4e                	sd	s3,24(sp)
    80003f52:	e852                	sd	s4,16(sp)
    80003f54:	0080                	add	s0,sp,64
    80003f56:	04451703          	lh	a4,68(a0)
    80003f5a:	4785                	li	a5,1
    80003f5c:	00f71a63          	bne	a4,a5,80003f70 <dirlookup+0x2a>
    80003f60:	892a                	mv	s2,a0
    80003f62:	89ae                	mv	s3,a1
    80003f64:	8a32                	mv	s4,a2
    80003f66:	457c                	lw	a5,76(a0)
    80003f68:	4481                	li	s1,0
    80003f6a:	4501                	li	a0,0
    80003f6c:	e79d                	bnez	a5,80003f9a <dirlookup+0x54>
    80003f6e:	a8a5                	j	80003fe6 <dirlookup+0xa0>
    80003f70:	00004517          	auipc	a0,0x4
    80003f74:	56050513          	add	a0,a0,1376 # 800084d0 <etext+0x4d0>
    80003f78:	ffffc097          	auipc	ra,0xffffc
    80003f7c:	5e2080e7          	jalr	1506(ra) # 8000055a <panic>
    80003f80:	00004517          	auipc	a0,0x4
    80003f84:	56850513          	add	a0,a0,1384 # 800084e8 <etext+0x4e8>
    80003f88:	ffffc097          	auipc	ra,0xffffc
    80003f8c:	5d2080e7          	jalr	1490(ra) # 8000055a <panic>
    80003f90:	24c1                	addw	s1,s1,16
    80003f92:	04c92783          	lw	a5,76(s2)
    80003f96:	04f4f763          	bgeu	s1,a5,80003fe4 <dirlookup+0x9e>
    80003f9a:	4741                	li	a4,16
    80003f9c:	86a6                	mv	a3,s1
    80003f9e:	fc040613          	add	a2,s0,-64
    80003fa2:	4581                	li	a1,0
    80003fa4:	854a                	mv	a0,s2
    80003fa6:	00000097          	auipc	ra,0x0
    80003faa:	d58080e7          	jalr	-680(ra) # 80003cfe <readi>
    80003fae:	47c1                	li	a5,16
    80003fb0:	fcf518e3          	bne	a0,a5,80003f80 <dirlookup+0x3a>
    80003fb4:	fc045783          	lhu	a5,-64(s0)
    80003fb8:	dfe1                	beqz	a5,80003f90 <dirlookup+0x4a>
    80003fba:	fc240593          	add	a1,s0,-62
    80003fbe:	854e                	mv	a0,s3
    80003fc0:	00000097          	auipc	ra,0x0
    80003fc4:	f6c080e7          	jalr	-148(ra) # 80003f2c <namecmp>
    80003fc8:	f561                	bnez	a0,80003f90 <dirlookup+0x4a>
    80003fca:	000a0463          	beqz	s4,80003fd2 <dirlookup+0x8c>
    80003fce:	009a2023          	sw	s1,0(s4)
    80003fd2:	fc045583          	lhu	a1,-64(s0)
    80003fd6:	00092503          	lw	a0,0(s2)
    80003fda:	fffff097          	auipc	ra,0xfffff
    80003fde:	73c080e7          	jalr	1852(ra) # 80003716 <iget>
    80003fe2:	a011                	j	80003fe6 <dirlookup+0xa0>
    80003fe4:	4501                	li	a0,0
    80003fe6:	70e2                	ld	ra,56(sp)
    80003fe8:	7442                	ld	s0,48(sp)
    80003fea:	74a2                	ld	s1,40(sp)
    80003fec:	7902                	ld	s2,32(sp)
    80003fee:	69e2                	ld	s3,24(sp)
    80003ff0:	6a42                	ld	s4,16(sp)
    80003ff2:	6121                	add	sp,sp,64
    80003ff4:	8082                	ret

0000000080003ff6 <namex>:
    80003ff6:	711d                	add	sp,sp,-96
    80003ff8:	ec86                	sd	ra,88(sp)
    80003ffa:	e8a2                	sd	s0,80(sp)
    80003ffc:	e4a6                	sd	s1,72(sp)
    80003ffe:	e0ca                	sd	s2,64(sp)
    80004000:	fc4e                	sd	s3,56(sp)
    80004002:	f852                	sd	s4,48(sp)
    80004004:	f456                	sd	s5,40(sp)
    80004006:	f05a                	sd	s6,32(sp)
    80004008:	ec5e                	sd	s7,24(sp)
    8000400a:	e862                	sd	s8,16(sp)
    8000400c:	e466                	sd	s9,8(sp)
    8000400e:	1080                	add	s0,sp,96
    80004010:	84aa                	mv	s1,a0
    80004012:	8b2e                	mv	s6,a1
    80004014:	8ab2                	mv	s5,a2
    80004016:	00054703          	lbu	a4,0(a0)
    8000401a:	02f00793          	li	a5,47
    8000401e:	02f70263          	beq	a4,a5,80004042 <namex+0x4c>
    80004022:	ffffe097          	auipc	ra,0xffffe
    80004026:	a02080e7          	jalr	-1534(ra) # 80001a24 <myproc>
    8000402a:	18053503          	ld	a0,384(a0)
    8000402e:	00000097          	auipc	ra,0x0
    80004032:	9da080e7          	jalr	-1574(ra) # 80003a08 <idup>
    80004036:	8a2a                	mv	s4,a0
    80004038:	02f00913          	li	s2,47
    8000403c:	4c35                	li	s8,13
    8000403e:	4b85                	li	s7,1
    80004040:	a875                	j	800040fc <namex+0x106>
    80004042:	4585                	li	a1,1
    80004044:	4505                	li	a0,1
    80004046:	fffff097          	auipc	ra,0xfffff
    8000404a:	6d0080e7          	jalr	1744(ra) # 80003716 <iget>
    8000404e:	8a2a                	mv	s4,a0
    80004050:	b7e5                	j	80004038 <namex+0x42>
    80004052:	8552                	mv	a0,s4
    80004054:	00000097          	auipc	ra,0x0
    80004058:	c58080e7          	jalr	-936(ra) # 80003cac <iunlockput>
    8000405c:	4a01                	li	s4,0
    8000405e:	8552                	mv	a0,s4
    80004060:	60e6                	ld	ra,88(sp)
    80004062:	6446                	ld	s0,80(sp)
    80004064:	64a6                	ld	s1,72(sp)
    80004066:	6906                	ld	s2,64(sp)
    80004068:	79e2                	ld	s3,56(sp)
    8000406a:	7a42                	ld	s4,48(sp)
    8000406c:	7aa2                	ld	s5,40(sp)
    8000406e:	7b02                	ld	s6,32(sp)
    80004070:	6be2                	ld	s7,24(sp)
    80004072:	6c42                	ld	s8,16(sp)
    80004074:	6ca2                	ld	s9,8(sp)
    80004076:	6125                	add	sp,sp,96
    80004078:	8082                	ret
    8000407a:	8552                	mv	a0,s4
    8000407c:	00000097          	auipc	ra,0x0
    80004080:	a90080e7          	jalr	-1392(ra) # 80003b0c <iunlock>
    80004084:	bfe9                	j	8000405e <namex+0x68>
    80004086:	8552                	mv	a0,s4
    80004088:	00000097          	auipc	ra,0x0
    8000408c:	c24080e7          	jalr	-988(ra) # 80003cac <iunlockput>
    80004090:	8a4e                	mv	s4,s3
    80004092:	b7f1                	j	8000405e <namex+0x68>
    80004094:	40998633          	sub	a2,s3,s1
    80004098:	00060c9b          	sext.w	s9,a2
    8000409c:	099c5863          	bge	s8,s9,8000412c <namex+0x136>
    800040a0:	4639                	li	a2,14
    800040a2:	85a6                	mv	a1,s1
    800040a4:	8556                	mv	a0,s5
    800040a6:	ffffd097          	auipc	ra,0xffffd
    800040aa:	ce4080e7          	jalr	-796(ra) # 80000d8a <memmove>
    800040ae:	84ce                	mv	s1,s3
    800040b0:	0004c783          	lbu	a5,0(s1)
    800040b4:	01279763          	bne	a5,s2,800040c2 <namex+0xcc>
    800040b8:	0485                	add	s1,s1,1
    800040ba:	0004c783          	lbu	a5,0(s1)
    800040be:	ff278de3          	beq	a5,s2,800040b8 <namex+0xc2>
    800040c2:	8552                	mv	a0,s4
    800040c4:	00000097          	auipc	ra,0x0
    800040c8:	982080e7          	jalr	-1662(ra) # 80003a46 <ilock>
    800040cc:	044a1783          	lh	a5,68(s4)
    800040d0:	f97791e3          	bne	a5,s7,80004052 <namex+0x5c>
    800040d4:	000b0563          	beqz	s6,800040de <namex+0xe8>
    800040d8:	0004c783          	lbu	a5,0(s1)
    800040dc:	dfd9                	beqz	a5,8000407a <namex+0x84>
    800040de:	4601                	li	a2,0
    800040e0:	85d6                	mv	a1,s5
    800040e2:	8552                	mv	a0,s4
    800040e4:	00000097          	auipc	ra,0x0
    800040e8:	e62080e7          	jalr	-414(ra) # 80003f46 <dirlookup>
    800040ec:	89aa                	mv	s3,a0
    800040ee:	dd41                	beqz	a0,80004086 <namex+0x90>
    800040f0:	8552                	mv	a0,s4
    800040f2:	00000097          	auipc	ra,0x0
    800040f6:	bba080e7          	jalr	-1094(ra) # 80003cac <iunlockput>
    800040fa:	8a4e                	mv	s4,s3
    800040fc:	0004c783          	lbu	a5,0(s1)
    80004100:	01279763          	bne	a5,s2,8000410e <namex+0x118>
    80004104:	0485                	add	s1,s1,1
    80004106:	0004c783          	lbu	a5,0(s1)
    8000410a:	ff278de3          	beq	a5,s2,80004104 <namex+0x10e>
    8000410e:	cb9d                	beqz	a5,80004144 <namex+0x14e>
    80004110:	0004c783          	lbu	a5,0(s1)
    80004114:	89a6                	mv	s3,s1
    80004116:	4c81                	li	s9,0
    80004118:	4601                	li	a2,0
    8000411a:	01278963          	beq	a5,s2,8000412c <namex+0x136>
    8000411e:	dbbd                	beqz	a5,80004094 <namex+0x9e>
    80004120:	0985                	add	s3,s3,1
    80004122:	0009c783          	lbu	a5,0(s3)
    80004126:	ff279ce3          	bne	a5,s2,8000411e <namex+0x128>
    8000412a:	b7ad                	j	80004094 <namex+0x9e>
    8000412c:	2601                	sext.w	a2,a2
    8000412e:	85a6                	mv	a1,s1
    80004130:	8556                	mv	a0,s5
    80004132:	ffffd097          	auipc	ra,0xffffd
    80004136:	c58080e7          	jalr	-936(ra) # 80000d8a <memmove>
    8000413a:	9cd6                	add	s9,s9,s5
    8000413c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004140:	84ce                	mv	s1,s3
    80004142:	b7bd                	j	800040b0 <namex+0xba>
    80004144:	f00b0de3          	beqz	s6,8000405e <namex+0x68>
    80004148:	8552                	mv	a0,s4
    8000414a:	00000097          	auipc	ra,0x0
    8000414e:	aba080e7          	jalr	-1350(ra) # 80003c04 <iput>
    80004152:	4a01                	li	s4,0
    80004154:	b729                	j	8000405e <namex+0x68>

0000000080004156 <dirlink>:
    80004156:	7139                	add	sp,sp,-64
    80004158:	fc06                	sd	ra,56(sp)
    8000415a:	f822                	sd	s0,48(sp)
    8000415c:	f04a                	sd	s2,32(sp)
    8000415e:	ec4e                	sd	s3,24(sp)
    80004160:	e852                	sd	s4,16(sp)
    80004162:	0080                	add	s0,sp,64
    80004164:	892a                	mv	s2,a0
    80004166:	8a2e                	mv	s4,a1
    80004168:	89b2                	mv	s3,a2
    8000416a:	4601                	li	a2,0
    8000416c:	00000097          	auipc	ra,0x0
    80004170:	dda080e7          	jalr	-550(ra) # 80003f46 <dirlookup>
    80004174:	ed25                	bnez	a0,800041ec <dirlink+0x96>
    80004176:	f426                	sd	s1,40(sp)
    80004178:	04c92483          	lw	s1,76(s2)
    8000417c:	c49d                	beqz	s1,800041aa <dirlink+0x54>
    8000417e:	4481                	li	s1,0
    80004180:	4741                	li	a4,16
    80004182:	86a6                	mv	a3,s1
    80004184:	fc040613          	add	a2,s0,-64
    80004188:	4581                	li	a1,0
    8000418a:	854a                	mv	a0,s2
    8000418c:	00000097          	auipc	ra,0x0
    80004190:	b72080e7          	jalr	-1166(ra) # 80003cfe <readi>
    80004194:	47c1                	li	a5,16
    80004196:	06f51163          	bne	a0,a5,800041f8 <dirlink+0xa2>
    8000419a:	fc045783          	lhu	a5,-64(s0)
    8000419e:	c791                	beqz	a5,800041aa <dirlink+0x54>
    800041a0:	24c1                	addw	s1,s1,16
    800041a2:	04c92783          	lw	a5,76(s2)
    800041a6:	fcf4ede3          	bltu	s1,a5,80004180 <dirlink+0x2a>
    800041aa:	4639                	li	a2,14
    800041ac:	85d2                	mv	a1,s4
    800041ae:	fc240513          	add	a0,s0,-62
    800041b2:	ffffd097          	auipc	ra,0xffffd
    800041b6:	c82080e7          	jalr	-894(ra) # 80000e34 <strncpy>
    800041ba:	fd341023          	sh	s3,-64(s0)
    800041be:	4741                	li	a4,16
    800041c0:	86a6                	mv	a3,s1
    800041c2:	fc040613          	add	a2,s0,-64
    800041c6:	4581                	li	a1,0
    800041c8:	854a                	mv	a0,s2
    800041ca:	00000097          	auipc	ra,0x0
    800041ce:	c38080e7          	jalr	-968(ra) # 80003e02 <writei>
    800041d2:	872a                	mv	a4,a0
    800041d4:	47c1                	li	a5,16
    800041d6:	4501                	li	a0,0
    800041d8:	02f71863          	bne	a4,a5,80004208 <dirlink+0xb2>
    800041dc:	74a2                	ld	s1,40(sp)
    800041de:	70e2                	ld	ra,56(sp)
    800041e0:	7442                	ld	s0,48(sp)
    800041e2:	7902                	ld	s2,32(sp)
    800041e4:	69e2                	ld	s3,24(sp)
    800041e6:	6a42                	ld	s4,16(sp)
    800041e8:	6121                	add	sp,sp,64
    800041ea:	8082                	ret
    800041ec:	00000097          	auipc	ra,0x0
    800041f0:	a18080e7          	jalr	-1512(ra) # 80003c04 <iput>
    800041f4:	557d                	li	a0,-1
    800041f6:	b7e5                	j	800041de <dirlink+0x88>
    800041f8:	00004517          	auipc	a0,0x4
    800041fc:	30050513          	add	a0,a0,768 # 800084f8 <etext+0x4f8>
    80004200:	ffffc097          	auipc	ra,0xffffc
    80004204:	35a080e7          	jalr	858(ra) # 8000055a <panic>
    80004208:	00004517          	auipc	a0,0x4
    8000420c:	40050513          	add	a0,a0,1024 # 80008608 <etext+0x608>
    80004210:	ffffc097          	auipc	ra,0xffffc
    80004214:	34a080e7          	jalr	842(ra) # 8000055a <panic>

0000000080004218 <namei>:
    80004218:	1101                	add	sp,sp,-32
    8000421a:	ec06                	sd	ra,24(sp)
    8000421c:	e822                	sd	s0,16(sp)
    8000421e:	1000                	add	s0,sp,32
    80004220:	fe040613          	add	a2,s0,-32
    80004224:	4581                	li	a1,0
    80004226:	00000097          	auipc	ra,0x0
    8000422a:	dd0080e7          	jalr	-560(ra) # 80003ff6 <namex>
    8000422e:	60e2                	ld	ra,24(sp)
    80004230:	6442                	ld	s0,16(sp)
    80004232:	6105                	add	sp,sp,32
    80004234:	8082                	ret

0000000080004236 <nameiparent>:
    80004236:	1141                	add	sp,sp,-16
    80004238:	e406                	sd	ra,8(sp)
    8000423a:	e022                	sd	s0,0(sp)
    8000423c:	0800                	add	s0,sp,16
    8000423e:	862e                	mv	a2,a1
    80004240:	4585                	li	a1,1
    80004242:	00000097          	auipc	ra,0x0
    80004246:	db4080e7          	jalr	-588(ra) # 80003ff6 <namex>
    8000424a:	60a2                	ld	ra,8(sp)
    8000424c:	6402                	ld	s0,0(sp)
    8000424e:	0141                	add	sp,sp,16
    80004250:	8082                	ret

0000000080004252 <write_head>:
    80004252:	1101                	add	sp,sp,-32
    80004254:	ec06                	sd	ra,24(sp)
    80004256:	e822                	sd	s0,16(sp)
    80004258:	e426                	sd	s1,8(sp)
    8000425a:	e04a                	sd	s2,0(sp)
    8000425c:	1000                	add	s0,sp,32
    8000425e:	0001e917          	auipc	s2,0x1e
    80004262:	c1290913          	add	s2,s2,-1006 # 80021e70 <log>
    80004266:	01892583          	lw	a1,24(s2)
    8000426a:	02892503          	lw	a0,40(s2)
    8000426e:	fffff097          	auipc	ra,0xfffff
    80004272:	fde080e7          	jalr	-34(ra) # 8000324c <bread>
    80004276:	84aa                	mv	s1,a0
    80004278:	02c92603          	lw	a2,44(s2)
    8000427c:	cd30                	sw	a2,88(a0)
    8000427e:	00c05f63          	blez	a2,8000429c <write_head+0x4a>
    80004282:	0001e717          	auipc	a4,0x1e
    80004286:	c1e70713          	add	a4,a4,-994 # 80021ea0 <log+0x30>
    8000428a:	87aa                	mv	a5,a0
    8000428c:	060a                	sll	a2,a2,0x2
    8000428e:	962a                	add	a2,a2,a0
    80004290:	4314                	lw	a3,0(a4)
    80004292:	cff4                	sw	a3,92(a5)
    80004294:	0711                	add	a4,a4,4
    80004296:	0791                	add	a5,a5,4
    80004298:	fec79ce3          	bne	a5,a2,80004290 <write_head+0x3e>
    8000429c:	8526                	mv	a0,s1
    8000429e:	fffff097          	auipc	ra,0xfffff
    800042a2:	0a0080e7          	jalr	160(ra) # 8000333e <bwrite>
    800042a6:	8526                	mv	a0,s1
    800042a8:	fffff097          	auipc	ra,0xfffff
    800042ac:	0d4080e7          	jalr	212(ra) # 8000337c <brelse>
    800042b0:	60e2                	ld	ra,24(sp)
    800042b2:	6442                	ld	s0,16(sp)
    800042b4:	64a2                	ld	s1,8(sp)
    800042b6:	6902                	ld	s2,0(sp)
    800042b8:	6105                	add	sp,sp,32
    800042ba:	8082                	ret

00000000800042bc <install_trans>:
    800042bc:	0001e797          	auipc	a5,0x1e
    800042c0:	be07a783          	lw	a5,-1056(a5) # 80021e9c <log+0x2c>
    800042c4:	0af05d63          	blez	a5,8000437e <install_trans+0xc2>
    800042c8:	7139                	add	sp,sp,-64
    800042ca:	fc06                	sd	ra,56(sp)
    800042cc:	f822                	sd	s0,48(sp)
    800042ce:	f426                	sd	s1,40(sp)
    800042d0:	f04a                	sd	s2,32(sp)
    800042d2:	ec4e                	sd	s3,24(sp)
    800042d4:	e852                	sd	s4,16(sp)
    800042d6:	e456                	sd	s5,8(sp)
    800042d8:	e05a                	sd	s6,0(sp)
    800042da:	0080                	add	s0,sp,64
    800042dc:	8b2a                	mv	s6,a0
    800042de:	0001ea97          	auipc	s5,0x1e
    800042e2:	bc2a8a93          	add	s5,s5,-1086 # 80021ea0 <log+0x30>
    800042e6:	4a01                	li	s4,0
    800042e8:	0001e997          	auipc	s3,0x1e
    800042ec:	b8898993          	add	s3,s3,-1144 # 80021e70 <log>
    800042f0:	a00d                	j	80004312 <install_trans+0x56>
    800042f2:	854a                	mv	a0,s2
    800042f4:	fffff097          	auipc	ra,0xfffff
    800042f8:	088080e7          	jalr	136(ra) # 8000337c <brelse>
    800042fc:	8526                	mv	a0,s1
    800042fe:	fffff097          	auipc	ra,0xfffff
    80004302:	07e080e7          	jalr	126(ra) # 8000337c <brelse>
    80004306:	2a05                	addw	s4,s4,1
    80004308:	0a91                	add	s5,s5,4
    8000430a:	02c9a783          	lw	a5,44(s3)
    8000430e:	04fa5e63          	bge	s4,a5,8000436a <install_trans+0xae>
    80004312:	0189a583          	lw	a1,24(s3)
    80004316:	014585bb          	addw	a1,a1,s4
    8000431a:	2585                	addw	a1,a1,1
    8000431c:	0289a503          	lw	a0,40(s3)
    80004320:	fffff097          	auipc	ra,0xfffff
    80004324:	f2c080e7          	jalr	-212(ra) # 8000324c <bread>
    80004328:	892a                	mv	s2,a0
    8000432a:	000aa583          	lw	a1,0(s5)
    8000432e:	0289a503          	lw	a0,40(s3)
    80004332:	fffff097          	auipc	ra,0xfffff
    80004336:	f1a080e7          	jalr	-230(ra) # 8000324c <bread>
    8000433a:	84aa                	mv	s1,a0
    8000433c:	40000613          	li	a2,1024
    80004340:	05890593          	add	a1,s2,88
    80004344:	05850513          	add	a0,a0,88
    80004348:	ffffd097          	auipc	ra,0xffffd
    8000434c:	a42080e7          	jalr	-1470(ra) # 80000d8a <memmove>
    80004350:	8526                	mv	a0,s1
    80004352:	fffff097          	auipc	ra,0xfffff
    80004356:	fec080e7          	jalr	-20(ra) # 8000333e <bwrite>
    8000435a:	f80b1ce3          	bnez	s6,800042f2 <install_trans+0x36>
    8000435e:	8526                	mv	a0,s1
    80004360:	fffff097          	auipc	ra,0xfffff
    80004364:	0f4080e7          	jalr	244(ra) # 80003454 <bunpin>
    80004368:	b769                	j	800042f2 <install_trans+0x36>
    8000436a:	70e2                	ld	ra,56(sp)
    8000436c:	7442                	ld	s0,48(sp)
    8000436e:	74a2                	ld	s1,40(sp)
    80004370:	7902                	ld	s2,32(sp)
    80004372:	69e2                	ld	s3,24(sp)
    80004374:	6a42                	ld	s4,16(sp)
    80004376:	6aa2                	ld	s5,8(sp)
    80004378:	6b02                	ld	s6,0(sp)
    8000437a:	6121                	add	sp,sp,64
    8000437c:	8082                	ret
    8000437e:	8082                	ret

0000000080004380 <initlog>:
    80004380:	7179                	add	sp,sp,-48
    80004382:	f406                	sd	ra,40(sp)
    80004384:	f022                	sd	s0,32(sp)
    80004386:	ec26                	sd	s1,24(sp)
    80004388:	e84a                	sd	s2,16(sp)
    8000438a:	e44e                	sd	s3,8(sp)
    8000438c:	1800                	add	s0,sp,48
    8000438e:	892a                	mv	s2,a0
    80004390:	89ae                	mv	s3,a1
    80004392:	0001e497          	auipc	s1,0x1e
    80004396:	ade48493          	add	s1,s1,-1314 # 80021e70 <log>
    8000439a:	00004597          	auipc	a1,0x4
    8000439e:	16e58593          	add	a1,a1,366 # 80008508 <etext+0x508>
    800043a2:	8526                	mv	a0,s1
    800043a4:	ffffc097          	auipc	ra,0xffffc
    800043a8:	7fe080e7          	jalr	2046(ra) # 80000ba2 <initlock>
    800043ac:	0149a583          	lw	a1,20(s3)
    800043b0:	cc8c                	sw	a1,24(s1)
    800043b2:	0109a783          	lw	a5,16(s3)
    800043b6:	ccdc                	sw	a5,28(s1)
    800043b8:	0324a423          	sw	s2,40(s1)
    800043bc:	854a                	mv	a0,s2
    800043be:	fffff097          	auipc	ra,0xfffff
    800043c2:	e8e080e7          	jalr	-370(ra) # 8000324c <bread>
    800043c6:	4d30                	lw	a2,88(a0)
    800043c8:	d4d0                	sw	a2,44(s1)
    800043ca:	00c05f63          	blez	a2,800043e8 <initlog+0x68>
    800043ce:	87aa                	mv	a5,a0
    800043d0:	0001e717          	auipc	a4,0x1e
    800043d4:	ad070713          	add	a4,a4,-1328 # 80021ea0 <log+0x30>
    800043d8:	060a                	sll	a2,a2,0x2
    800043da:	962a                	add	a2,a2,a0
    800043dc:	4ff4                	lw	a3,92(a5)
    800043de:	c314                	sw	a3,0(a4)
    800043e0:	0791                	add	a5,a5,4
    800043e2:	0711                	add	a4,a4,4
    800043e4:	fec79ce3          	bne	a5,a2,800043dc <initlog+0x5c>
    800043e8:	fffff097          	auipc	ra,0xfffff
    800043ec:	f94080e7          	jalr	-108(ra) # 8000337c <brelse>
    800043f0:	4505                	li	a0,1
    800043f2:	00000097          	auipc	ra,0x0
    800043f6:	eca080e7          	jalr	-310(ra) # 800042bc <install_trans>
    800043fa:	0001e797          	auipc	a5,0x1e
    800043fe:	aa07a123          	sw	zero,-1374(a5) # 80021e9c <log+0x2c>
    80004402:	00000097          	auipc	ra,0x0
    80004406:	e50080e7          	jalr	-432(ra) # 80004252 <write_head>
    8000440a:	70a2                	ld	ra,40(sp)
    8000440c:	7402                	ld	s0,32(sp)
    8000440e:	64e2                	ld	s1,24(sp)
    80004410:	6942                	ld	s2,16(sp)
    80004412:	69a2                	ld	s3,8(sp)
    80004414:	6145                	add	sp,sp,48
    80004416:	8082                	ret

0000000080004418 <begin_op>:
    80004418:	1101                	add	sp,sp,-32
    8000441a:	ec06                	sd	ra,24(sp)
    8000441c:	e822                	sd	s0,16(sp)
    8000441e:	e426                	sd	s1,8(sp)
    80004420:	e04a                	sd	s2,0(sp)
    80004422:	1000                	add	s0,sp,32
    80004424:	0001e517          	auipc	a0,0x1e
    80004428:	a4c50513          	add	a0,a0,-1460 # 80021e70 <log>
    8000442c:	ffffd097          	auipc	ra,0xffffd
    80004430:	806080e7          	jalr	-2042(ra) # 80000c32 <acquire>
    80004434:	0001e497          	auipc	s1,0x1e
    80004438:	a3c48493          	add	s1,s1,-1476 # 80021e70 <log>
    8000443c:	4979                	li	s2,30
    8000443e:	a039                	j	8000444c <begin_op+0x34>
    80004440:	85a6                	mv	a1,s1
    80004442:	8526                	mv	a0,s1
    80004444:	ffffe097          	auipc	ra,0xffffe
    80004448:	cc4080e7          	jalr	-828(ra) # 80002108 <sleep>
    8000444c:	50dc                	lw	a5,36(s1)
    8000444e:	fbed                	bnez	a5,80004440 <begin_op+0x28>
    80004450:	5098                	lw	a4,32(s1)
    80004452:	2705                	addw	a4,a4,1
    80004454:	0027179b          	sllw	a5,a4,0x2
    80004458:	9fb9                	addw	a5,a5,a4
    8000445a:	0017979b          	sllw	a5,a5,0x1
    8000445e:	54d4                	lw	a3,44(s1)
    80004460:	9fb5                	addw	a5,a5,a3
    80004462:	00f95963          	bge	s2,a5,80004474 <begin_op+0x5c>
    80004466:	85a6                	mv	a1,s1
    80004468:	8526                	mv	a0,s1
    8000446a:	ffffe097          	auipc	ra,0xffffe
    8000446e:	c9e080e7          	jalr	-866(ra) # 80002108 <sleep>
    80004472:	bfe9                	j	8000444c <begin_op+0x34>
    80004474:	0001e517          	auipc	a0,0x1e
    80004478:	9fc50513          	add	a0,a0,-1540 # 80021e70 <log>
    8000447c:	d118                	sw	a4,32(a0)
    8000447e:	ffffd097          	auipc	ra,0xffffd
    80004482:	868080e7          	jalr	-1944(ra) # 80000ce6 <release>
    80004486:	60e2                	ld	ra,24(sp)
    80004488:	6442                	ld	s0,16(sp)
    8000448a:	64a2                	ld	s1,8(sp)
    8000448c:	6902                	ld	s2,0(sp)
    8000448e:	6105                	add	sp,sp,32
    80004490:	8082                	ret

0000000080004492 <end_op>:
    80004492:	7139                	add	sp,sp,-64
    80004494:	fc06                	sd	ra,56(sp)
    80004496:	f822                	sd	s0,48(sp)
    80004498:	f426                	sd	s1,40(sp)
    8000449a:	f04a                	sd	s2,32(sp)
    8000449c:	0080                	add	s0,sp,64
    8000449e:	0001e497          	auipc	s1,0x1e
    800044a2:	9d248493          	add	s1,s1,-1582 # 80021e70 <log>
    800044a6:	8526                	mv	a0,s1
    800044a8:	ffffc097          	auipc	ra,0xffffc
    800044ac:	78a080e7          	jalr	1930(ra) # 80000c32 <acquire>
    800044b0:	509c                	lw	a5,32(s1)
    800044b2:	37fd                	addw	a5,a5,-1
    800044b4:	0007891b          	sext.w	s2,a5
    800044b8:	d09c                	sw	a5,32(s1)
    800044ba:	50dc                	lw	a5,36(s1)
    800044bc:	e7b9                	bnez	a5,8000450a <end_op+0x78>
    800044be:	06091163          	bnez	s2,80004520 <end_op+0x8e>
    800044c2:	0001e497          	auipc	s1,0x1e
    800044c6:	9ae48493          	add	s1,s1,-1618 # 80021e70 <log>
    800044ca:	4785                	li	a5,1
    800044cc:	d0dc                	sw	a5,36(s1)
    800044ce:	8526                	mv	a0,s1
    800044d0:	ffffd097          	auipc	ra,0xffffd
    800044d4:	816080e7          	jalr	-2026(ra) # 80000ce6 <release>
    800044d8:	54dc                	lw	a5,44(s1)
    800044da:	06f04763          	bgtz	a5,80004548 <end_op+0xb6>
    800044de:	0001e497          	auipc	s1,0x1e
    800044e2:	99248493          	add	s1,s1,-1646 # 80021e70 <log>
    800044e6:	8526                	mv	a0,s1
    800044e8:	ffffc097          	auipc	ra,0xffffc
    800044ec:	74a080e7          	jalr	1866(ra) # 80000c32 <acquire>
    800044f0:	0204a223          	sw	zero,36(s1)
    800044f4:	8526                	mv	a0,s1
    800044f6:	ffffe097          	auipc	ra,0xffffe
    800044fa:	d9e080e7          	jalr	-610(ra) # 80002294 <wakeup>
    800044fe:	8526                	mv	a0,s1
    80004500:	ffffc097          	auipc	ra,0xffffc
    80004504:	7e6080e7          	jalr	2022(ra) # 80000ce6 <release>
    80004508:	a815                	j	8000453c <end_op+0xaa>
    8000450a:	ec4e                	sd	s3,24(sp)
    8000450c:	e852                	sd	s4,16(sp)
    8000450e:	e456                	sd	s5,8(sp)
    80004510:	00004517          	auipc	a0,0x4
    80004514:	00050513          	mv	a0,a0
    80004518:	ffffc097          	auipc	ra,0xffffc
    8000451c:	042080e7          	jalr	66(ra) # 8000055a <panic>
    80004520:	0001e497          	auipc	s1,0x1e
    80004524:	95048493          	add	s1,s1,-1712 # 80021e70 <log>
    80004528:	8526                	mv	a0,s1
    8000452a:	ffffe097          	auipc	ra,0xffffe
    8000452e:	d6a080e7          	jalr	-662(ra) # 80002294 <wakeup>
    80004532:	8526                	mv	a0,s1
    80004534:	ffffc097          	auipc	ra,0xffffc
    80004538:	7b2080e7          	jalr	1970(ra) # 80000ce6 <release>
    8000453c:	70e2                	ld	ra,56(sp)
    8000453e:	7442                	ld	s0,48(sp)
    80004540:	74a2                	ld	s1,40(sp)
    80004542:	7902                	ld	s2,32(sp)
    80004544:	6121                	add	sp,sp,64
    80004546:	8082                	ret
    80004548:	ec4e                	sd	s3,24(sp)
    8000454a:	e852                	sd	s4,16(sp)
    8000454c:	e456                	sd	s5,8(sp)
    8000454e:	0001ea97          	auipc	s5,0x1e
    80004552:	952a8a93          	add	s5,s5,-1710 # 80021ea0 <log+0x30>
    80004556:	0001ea17          	auipc	s4,0x1e
    8000455a:	91aa0a13          	add	s4,s4,-1766 # 80021e70 <log>
    8000455e:	018a2583          	lw	a1,24(s4)
    80004562:	012585bb          	addw	a1,a1,s2
    80004566:	2585                	addw	a1,a1,1
    80004568:	028a2503          	lw	a0,40(s4)
    8000456c:	fffff097          	auipc	ra,0xfffff
    80004570:	ce0080e7          	jalr	-800(ra) # 8000324c <bread>
    80004574:	84aa                	mv	s1,a0
    80004576:	000aa583          	lw	a1,0(s5)
    8000457a:	028a2503          	lw	a0,40(s4)
    8000457e:	fffff097          	auipc	ra,0xfffff
    80004582:	cce080e7          	jalr	-818(ra) # 8000324c <bread>
    80004586:	89aa                	mv	s3,a0
    80004588:	40000613          	li	a2,1024
    8000458c:	05850593          	add	a1,a0,88 # 80008568 <etext+0x568>
    80004590:	05848513          	add	a0,s1,88
    80004594:	ffffc097          	auipc	ra,0xffffc
    80004598:	7f6080e7          	jalr	2038(ra) # 80000d8a <memmove>
    8000459c:	8526                	mv	a0,s1
    8000459e:	fffff097          	auipc	ra,0xfffff
    800045a2:	da0080e7          	jalr	-608(ra) # 8000333e <bwrite>
    800045a6:	854e                	mv	a0,s3
    800045a8:	fffff097          	auipc	ra,0xfffff
    800045ac:	dd4080e7          	jalr	-556(ra) # 8000337c <brelse>
    800045b0:	8526                	mv	a0,s1
    800045b2:	fffff097          	auipc	ra,0xfffff
    800045b6:	dca080e7          	jalr	-566(ra) # 8000337c <brelse>
    800045ba:	2905                	addw	s2,s2,1
    800045bc:	0a91                	add	s5,s5,4
    800045be:	02ca2783          	lw	a5,44(s4)
    800045c2:	f8f94ee3          	blt	s2,a5,8000455e <end_op+0xcc>
    800045c6:	00000097          	auipc	ra,0x0
    800045ca:	c8c080e7          	jalr	-884(ra) # 80004252 <write_head>
    800045ce:	4501                	li	a0,0
    800045d0:	00000097          	auipc	ra,0x0
    800045d4:	cec080e7          	jalr	-788(ra) # 800042bc <install_trans>
    800045d8:	0001e797          	auipc	a5,0x1e
    800045dc:	8c07a223          	sw	zero,-1852(a5) # 80021e9c <log+0x2c>
    800045e0:	00000097          	auipc	ra,0x0
    800045e4:	c72080e7          	jalr	-910(ra) # 80004252 <write_head>
    800045e8:	69e2                	ld	s3,24(sp)
    800045ea:	6a42                	ld	s4,16(sp)
    800045ec:	6aa2                	ld	s5,8(sp)
    800045ee:	bdc5                	j	800044de <end_op+0x4c>

00000000800045f0 <log_write>:
    800045f0:	1101                	add	sp,sp,-32
    800045f2:	ec06                	sd	ra,24(sp)
    800045f4:	e822                	sd	s0,16(sp)
    800045f6:	e426                	sd	s1,8(sp)
    800045f8:	e04a                	sd	s2,0(sp)
    800045fa:	1000                	add	s0,sp,32
    800045fc:	84aa                	mv	s1,a0
    800045fe:	0001e917          	auipc	s2,0x1e
    80004602:	87290913          	add	s2,s2,-1934 # 80021e70 <log>
    80004606:	854a                	mv	a0,s2
    80004608:	ffffc097          	auipc	ra,0xffffc
    8000460c:	62a080e7          	jalr	1578(ra) # 80000c32 <acquire>
    80004610:	02c92603          	lw	a2,44(s2)
    80004614:	47f5                	li	a5,29
    80004616:	06c7c563          	blt	a5,a2,80004680 <log_write+0x90>
    8000461a:	0001e797          	auipc	a5,0x1e
    8000461e:	8727a783          	lw	a5,-1934(a5) # 80021e8c <log+0x1c>
    80004622:	37fd                	addw	a5,a5,-1
    80004624:	04f65e63          	bge	a2,a5,80004680 <log_write+0x90>
    80004628:	0001e797          	auipc	a5,0x1e
    8000462c:	8687a783          	lw	a5,-1944(a5) # 80021e90 <log+0x20>
    80004630:	06f05063          	blez	a5,80004690 <log_write+0xa0>
    80004634:	4781                	li	a5,0
    80004636:	06c05563          	blez	a2,800046a0 <log_write+0xb0>
    8000463a:	44cc                	lw	a1,12(s1)
    8000463c:	0001e717          	auipc	a4,0x1e
    80004640:	86470713          	add	a4,a4,-1948 # 80021ea0 <log+0x30>
    80004644:	4781                	li	a5,0
    80004646:	4314                	lw	a3,0(a4)
    80004648:	04b68c63          	beq	a3,a1,800046a0 <log_write+0xb0>
    8000464c:	2785                	addw	a5,a5,1
    8000464e:	0711                	add	a4,a4,4
    80004650:	fef61be3          	bne	a2,a5,80004646 <log_write+0x56>
    80004654:	0621                	add	a2,a2,8
    80004656:	060a                	sll	a2,a2,0x2
    80004658:	0001e797          	auipc	a5,0x1e
    8000465c:	81878793          	add	a5,a5,-2024 # 80021e70 <log>
    80004660:	97b2                	add	a5,a5,a2
    80004662:	44d8                	lw	a4,12(s1)
    80004664:	cb98                	sw	a4,16(a5)
    80004666:	8526                	mv	a0,s1
    80004668:	fffff097          	auipc	ra,0xfffff
    8000466c:	db0080e7          	jalr	-592(ra) # 80003418 <bpin>
    80004670:	0001e717          	auipc	a4,0x1e
    80004674:	80070713          	add	a4,a4,-2048 # 80021e70 <log>
    80004678:	575c                	lw	a5,44(a4)
    8000467a:	2785                	addw	a5,a5,1
    8000467c:	d75c                	sw	a5,44(a4)
    8000467e:	a82d                	j	800046b8 <log_write+0xc8>
    80004680:	00004517          	auipc	a0,0x4
    80004684:	ea050513          	add	a0,a0,-352 # 80008520 <etext+0x520>
    80004688:	ffffc097          	auipc	ra,0xffffc
    8000468c:	ed2080e7          	jalr	-302(ra) # 8000055a <panic>
    80004690:	00004517          	auipc	a0,0x4
    80004694:	ea850513          	add	a0,a0,-344 # 80008538 <etext+0x538>
    80004698:	ffffc097          	auipc	ra,0xffffc
    8000469c:	ec2080e7          	jalr	-318(ra) # 8000055a <panic>
    800046a0:	00878693          	add	a3,a5,8
    800046a4:	068a                	sll	a3,a3,0x2
    800046a6:	0001d717          	auipc	a4,0x1d
    800046aa:	7ca70713          	add	a4,a4,1994 # 80021e70 <log>
    800046ae:	9736                	add	a4,a4,a3
    800046b0:	44d4                	lw	a3,12(s1)
    800046b2:	cb14                	sw	a3,16(a4)
    800046b4:	faf609e3          	beq	a2,a5,80004666 <log_write+0x76>
    800046b8:	0001d517          	auipc	a0,0x1d
    800046bc:	7b850513          	add	a0,a0,1976 # 80021e70 <log>
    800046c0:	ffffc097          	auipc	ra,0xffffc
    800046c4:	626080e7          	jalr	1574(ra) # 80000ce6 <release>
    800046c8:	60e2                	ld	ra,24(sp)
    800046ca:	6442                	ld	s0,16(sp)
    800046cc:	64a2                	ld	s1,8(sp)
    800046ce:	6902                	ld	s2,0(sp)
    800046d0:	6105                	add	sp,sp,32
    800046d2:	8082                	ret

00000000800046d4 <initsleeplock>:
    800046d4:	1101                	add	sp,sp,-32
    800046d6:	ec06                	sd	ra,24(sp)
    800046d8:	e822                	sd	s0,16(sp)
    800046da:	e426                	sd	s1,8(sp)
    800046dc:	e04a                	sd	s2,0(sp)
    800046de:	1000                	add	s0,sp,32
    800046e0:	84aa                	mv	s1,a0
    800046e2:	892e                	mv	s2,a1
    800046e4:	00004597          	auipc	a1,0x4
    800046e8:	e7458593          	add	a1,a1,-396 # 80008558 <etext+0x558>
    800046ec:	0521                	add	a0,a0,8
    800046ee:	ffffc097          	auipc	ra,0xffffc
    800046f2:	4b4080e7          	jalr	1204(ra) # 80000ba2 <initlock>
    800046f6:	0324b023          	sd	s2,32(s1)
    800046fa:	0004a023          	sw	zero,0(s1)
    800046fe:	0204a423          	sw	zero,40(s1)
    80004702:	60e2                	ld	ra,24(sp)
    80004704:	6442                	ld	s0,16(sp)
    80004706:	64a2                	ld	s1,8(sp)
    80004708:	6902                	ld	s2,0(sp)
    8000470a:	6105                	add	sp,sp,32
    8000470c:	8082                	ret

000000008000470e <acquiresleep>:
    8000470e:	1101                	add	sp,sp,-32
    80004710:	ec06                	sd	ra,24(sp)
    80004712:	e822                	sd	s0,16(sp)
    80004714:	e426                	sd	s1,8(sp)
    80004716:	e04a                	sd	s2,0(sp)
    80004718:	1000                	add	s0,sp,32
    8000471a:	84aa                	mv	s1,a0
    8000471c:	00850913          	add	s2,a0,8
    80004720:	854a                	mv	a0,s2
    80004722:	ffffc097          	auipc	ra,0xffffc
    80004726:	510080e7          	jalr	1296(ra) # 80000c32 <acquire>
    8000472a:	409c                	lw	a5,0(s1)
    8000472c:	cb89                	beqz	a5,8000473e <acquiresleep+0x30>
    8000472e:	85ca                	mv	a1,s2
    80004730:	8526                	mv	a0,s1
    80004732:	ffffe097          	auipc	ra,0xffffe
    80004736:	9d6080e7          	jalr	-1578(ra) # 80002108 <sleep>
    8000473a:	409c                	lw	a5,0(s1)
    8000473c:	fbed                	bnez	a5,8000472e <acquiresleep+0x20>
    8000473e:	4785                	li	a5,1
    80004740:	c09c                	sw	a5,0(s1)
    80004742:	ffffd097          	auipc	ra,0xffffd
    80004746:	2e2080e7          	jalr	738(ra) # 80001a24 <myproc>
    8000474a:	513c                	lw	a5,96(a0)
    8000474c:	d49c                	sw	a5,40(s1)
    8000474e:	854a                	mv	a0,s2
    80004750:	ffffc097          	auipc	ra,0xffffc
    80004754:	596080e7          	jalr	1430(ra) # 80000ce6 <release>
    80004758:	60e2                	ld	ra,24(sp)
    8000475a:	6442                	ld	s0,16(sp)
    8000475c:	64a2                	ld	s1,8(sp)
    8000475e:	6902                	ld	s2,0(sp)
    80004760:	6105                	add	sp,sp,32
    80004762:	8082                	ret

0000000080004764 <releasesleep>:
    80004764:	1101                	add	sp,sp,-32
    80004766:	ec06                	sd	ra,24(sp)
    80004768:	e822                	sd	s0,16(sp)
    8000476a:	e426                	sd	s1,8(sp)
    8000476c:	e04a                	sd	s2,0(sp)
    8000476e:	1000                	add	s0,sp,32
    80004770:	84aa                	mv	s1,a0
    80004772:	00850913          	add	s2,a0,8
    80004776:	854a                	mv	a0,s2
    80004778:	ffffc097          	auipc	ra,0xffffc
    8000477c:	4ba080e7          	jalr	1210(ra) # 80000c32 <acquire>
    80004780:	0004a023          	sw	zero,0(s1)
    80004784:	0204a423          	sw	zero,40(s1)
    80004788:	8526                	mv	a0,s1
    8000478a:	ffffe097          	auipc	ra,0xffffe
    8000478e:	b0a080e7          	jalr	-1270(ra) # 80002294 <wakeup>
    80004792:	854a                	mv	a0,s2
    80004794:	ffffc097          	auipc	ra,0xffffc
    80004798:	552080e7          	jalr	1362(ra) # 80000ce6 <release>
    8000479c:	60e2                	ld	ra,24(sp)
    8000479e:	6442                	ld	s0,16(sp)
    800047a0:	64a2                	ld	s1,8(sp)
    800047a2:	6902                	ld	s2,0(sp)
    800047a4:	6105                	add	sp,sp,32
    800047a6:	8082                	ret

00000000800047a8 <holdingsleep>:
    800047a8:	7179                	add	sp,sp,-48
    800047aa:	f406                	sd	ra,40(sp)
    800047ac:	f022                	sd	s0,32(sp)
    800047ae:	ec26                	sd	s1,24(sp)
    800047b0:	e84a                	sd	s2,16(sp)
    800047b2:	1800                	add	s0,sp,48
    800047b4:	84aa                	mv	s1,a0
    800047b6:	00850913          	add	s2,a0,8
    800047ba:	854a                	mv	a0,s2
    800047bc:	ffffc097          	auipc	ra,0xffffc
    800047c0:	476080e7          	jalr	1142(ra) # 80000c32 <acquire>
    800047c4:	409c                	lw	a5,0(s1)
    800047c6:	ef91                	bnez	a5,800047e2 <holdingsleep+0x3a>
    800047c8:	4481                	li	s1,0
    800047ca:	854a                	mv	a0,s2
    800047cc:	ffffc097          	auipc	ra,0xffffc
    800047d0:	51a080e7          	jalr	1306(ra) # 80000ce6 <release>
    800047d4:	8526                	mv	a0,s1
    800047d6:	70a2                	ld	ra,40(sp)
    800047d8:	7402                	ld	s0,32(sp)
    800047da:	64e2                	ld	s1,24(sp)
    800047dc:	6942                	ld	s2,16(sp)
    800047de:	6145                	add	sp,sp,48
    800047e0:	8082                	ret
    800047e2:	e44e                	sd	s3,8(sp)
    800047e4:	0284a983          	lw	s3,40(s1)
    800047e8:	ffffd097          	auipc	ra,0xffffd
    800047ec:	23c080e7          	jalr	572(ra) # 80001a24 <myproc>
    800047f0:	5124                	lw	s1,96(a0)
    800047f2:	413484b3          	sub	s1,s1,s3
    800047f6:	0014b493          	seqz	s1,s1
    800047fa:	69a2                	ld	s3,8(sp)
    800047fc:	b7f9                	j	800047ca <holdingsleep+0x22>

00000000800047fe <fileinit>:
    800047fe:	1141                	add	sp,sp,-16
    80004800:	e406                	sd	ra,8(sp)
    80004802:	e022                	sd	s0,0(sp)
    80004804:	0800                	add	s0,sp,16
    80004806:	00004597          	auipc	a1,0x4
    8000480a:	d6258593          	add	a1,a1,-670 # 80008568 <etext+0x568>
    8000480e:	0001d517          	auipc	a0,0x1d
    80004812:	7aa50513          	add	a0,a0,1962 # 80021fb8 <ftable>
    80004816:	ffffc097          	auipc	ra,0xffffc
    8000481a:	38c080e7          	jalr	908(ra) # 80000ba2 <initlock>
    8000481e:	60a2                	ld	ra,8(sp)
    80004820:	6402                	ld	s0,0(sp)
    80004822:	0141                	add	sp,sp,16
    80004824:	8082                	ret

0000000080004826 <filealloc>:
    80004826:	1101                	add	sp,sp,-32
    80004828:	ec06                	sd	ra,24(sp)
    8000482a:	e822                	sd	s0,16(sp)
    8000482c:	e426                	sd	s1,8(sp)
    8000482e:	1000                	add	s0,sp,32
    80004830:	0001d517          	auipc	a0,0x1d
    80004834:	78850513          	add	a0,a0,1928 # 80021fb8 <ftable>
    80004838:	ffffc097          	auipc	ra,0xffffc
    8000483c:	3fa080e7          	jalr	1018(ra) # 80000c32 <acquire>
    80004840:	0001d497          	auipc	s1,0x1d
    80004844:	79048493          	add	s1,s1,1936 # 80021fd0 <ftable+0x18>
    80004848:	0001e717          	auipc	a4,0x1e
    8000484c:	72870713          	add	a4,a4,1832 # 80022f70 <ftable+0xfb8>
    80004850:	40dc                	lw	a5,4(s1)
    80004852:	cf99                	beqz	a5,80004870 <filealloc+0x4a>
    80004854:	02848493          	add	s1,s1,40
    80004858:	fee49ce3          	bne	s1,a4,80004850 <filealloc+0x2a>
    8000485c:	0001d517          	auipc	a0,0x1d
    80004860:	75c50513          	add	a0,a0,1884 # 80021fb8 <ftable>
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	482080e7          	jalr	1154(ra) # 80000ce6 <release>
    8000486c:	4481                	li	s1,0
    8000486e:	a819                	j	80004884 <filealloc+0x5e>
    80004870:	4785                	li	a5,1
    80004872:	c0dc                	sw	a5,4(s1)
    80004874:	0001d517          	auipc	a0,0x1d
    80004878:	74450513          	add	a0,a0,1860 # 80021fb8 <ftable>
    8000487c:	ffffc097          	auipc	ra,0xffffc
    80004880:	46a080e7          	jalr	1130(ra) # 80000ce6 <release>
    80004884:	8526                	mv	a0,s1
    80004886:	60e2                	ld	ra,24(sp)
    80004888:	6442                	ld	s0,16(sp)
    8000488a:	64a2                	ld	s1,8(sp)
    8000488c:	6105                	add	sp,sp,32
    8000488e:	8082                	ret

0000000080004890 <filedup>:
    80004890:	1101                	add	sp,sp,-32
    80004892:	ec06                	sd	ra,24(sp)
    80004894:	e822                	sd	s0,16(sp)
    80004896:	e426                	sd	s1,8(sp)
    80004898:	1000                	add	s0,sp,32
    8000489a:	84aa                	mv	s1,a0
    8000489c:	0001d517          	auipc	a0,0x1d
    800048a0:	71c50513          	add	a0,a0,1820 # 80021fb8 <ftable>
    800048a4:	ffffc097          	auipc	ra,0xffffc
    800048a8:	38e080e7          	jalr	910(ra) # 80000c32 <acquire>
    800048ac:	40dc                	lw	a5,4(s1)
    800048ae:	02f05263          	blez	a5,800048d2 <filedup+0x42>
    800048b2:	2785                	addw	a5,a5,1
    800048b4:	c0dc                	sw	a5,4(s1)
    800048b6:	0001d517          	auipc	a0,0x1d
    800048ba:	70250513          	add	a0,a0,1794 # 80021fb8 <ftable>
    800048be:	ffffc097          	auipc	ra,0xffffc
    800048c2:	428080e7          	jalr	1064(ra) # 80000ce6 <release>
    800048c6:	8526                	mv	a0,s1
    800048c8:	60e2                	ld	ra,24(sp)
    800048ca:	6442                	ld	s0,16(sp)
    800048cc:	64a2                	ld	s1,8(sp)
    800048ce:	6105                	add	sp,sp,32
    800048d0:	8082                	ret
    800048d2:	00004517          	auipc	a0,0x4
    800048d6:	c9e50513          	add	a0,a0,-866 # 80008570 <etext+0x570>
    800048da:	ffffc097          	auipc	ra,0xffffc
    800048de:	c80080e7          	jalr	-896(ra) # 8000055a <panic>

00000000800048e2 <fileclose>:
    800048e2:	7139                	add	sp,sp,-64
    800048e4:	fc06                	sd	ra,56(sp)
    800048e6:	f822                	sd	s0,48(sp)
    800048e8:	f426                	sd	s1,40(sp)
    800048ea:	0080                	add	s0,sp,64
    800048ec:	84aa                	mv	s1,a0
    800048ee:	0001d517          	auipc	a0,0x1d
    800048f2:	6ca50513          	add	a0,a0,1738 # 80021fb8 <ftable>
    800048f6:	ffffc097          	auipc	ra,0xffffc
    800048fa:	33c080e7          	jalr	828(ra) # 80000c32 <acquire>
    800048fe:	40dc                	lw	a5,4(s1)
    80004900:	04f05c63          	blez	a5,80004958 <fileclose+0x76>
    80004904:	37fd                	addw	a5,a5,-1
    80004906:	0007871b          	sext.w	a4,a5
    8000490a:	c0dc                	sw	a5,4(s1)
    8000490c:	06e04263          	bgtz	a4,80004970 <fileclose+0x8e>
    80004910:	f04a                	sd	s2,32(sp)
    80004912:	ec4e                	sd	s3,24(sp)
    80004914:	e852                	sd	s4,16(sp)
    80004916:	e456                	sd	s5,8(sp)
    80004918:	0004a903          	lw	s2,0(s1)
    8000491c:	0094ca83          	lbu	s5,9(s1)
    80004920:	0104ba03          	ld	s4,16(s1)
    80004924:	0184b983          	ld	s3,24(s1)
    80004928:	0004a223          	sw	zero,4(s1)
    8000492c:	0004a023          	sw	zero,0(s1)
    80004930:	0001d517          	auipc	a0,0x1d
    80004934:	68850513          	add	a0,a0,1672 # 80021fb8 <ftable>
    80004938:	ffffc097          	auipc	ra,0xffffc
    8000493c:	3ae080e7          	jalr	942(ra) # 80000ce6 <release>
    80004940:	4785                	li	a5,1
    80004942:	04f90463          	beq	s2,a5,8000498a <fileclose+0xa8>
    80004946:	3979                	addw	s2,s2,-2
    80004948:	4785                	li	a5,1
    8000494a:	0527fb63          	bgeu	a5,s2,800049a0 <fileclose+0xbe>
    8000494e:	7902                	ld	s2,32(sp)
    80004950:	69e2                	ld	s3,24(sp)
    80004952:	6a42                	ld	s4,16(sp)
    80004954:	6aa2                	ld	s5,8(sp)
    80004956:	a02d                	j	80004980 <fileclose+0x9e>
    80004958:	f04a                	sd	s2,32(sp)
    8000495a:	ec4e                	sd	s3,24(sp)
    8000495c:	e852                	sd	s4,16(sp)
    8000495e:	e456                	sd	s5,8(sp)
    80004960:	00004517          	auipc	a0,0x4
    80004964:	c1850513          	add	a0,a0,-1000 # 80008578 <etext+0x578>
    80004968:	ffffc097          	auipc	ra,0xffffc
    8000496c:	bf2080e7          	jalr	-1038(ra) # 8000055a <panic>
    80004970:	0001d517          	auipc	a0,0x1d
    80004974:	64850513          	add	a0,a0,1608 # 80021fb8 <ftable>
    80004978:	ffffc097          	auipc	ra,0xffffc
    8000497c:	36e080e7          	jalr	878(ra) # 80000ce6 <release>
    80004980:	70e2                	ld	ra,56(sp)
    80004982:	7442                	ld	s0,48(sp)
    80004984:	74a2                	ld	s1,40(sp)
    80004986:	6121                	add	sp,sp,64
    80004988:	8082                	ret
    8000498a:	85d6                	mv	a1,s5
    8000498c:	8552                	mv	a0,s4
    8000498e:	00000097          	auipc	ra,0x0
    80004992:	3a2080e7          	jalr	930(ra) # 80004d30 <pipeclose>
    80004996:	7902                	ld	s2,32(sp)
    80004998:	69e2                	ld	s3,24(sp)
    8000499a:	6a42                	ld	s4,16(sp)
    8000499c:	6aa2                	ld	s5,8(sp)
    8000499e:	b7cd                	j	80004980 <fileclose+0x9e>
    800049a0:	00000097          	auipc	ra,0x0
    800049a4:	a78080e7          	jalr	-1416(ra) # 80004418 <begin_op>
    800049a8:	854e                	mv	a0,s3
    800049aa:	fffff097          	auipc	ra,0xfffff
    800049ae:	25a080e7          	jalr	602(ra) # 80003c04 <iput>
    800049b2:	00000097          	auipc	ra,0x0
    800049b6:	ae0080e7          	jalr	-1312(ra) # 80004492 <end_op>
    800049ba:	7902                	ld	s2,32(sp)
    800049bc:	69e2                	ld	s3,24(sp)
    800049be:	6a42                	ld	s4,16(sp)
    800049c0:	6aa2                	ld	s5,8(sp)
    800049c2:	bf7d                	j	80004980 <fileclose+0x9e>

00000000800049c4 <filestat>:
    800049c4:	715d                	add	sp,sp,-80
    800049c6:	e486                	sd	ra,72(sp)
    800049c8:	e0a2                	sd	s0,64(sp)
    800049ca:	fc26                	sd	s1,56(sp)
    800049cc:	f44e                	sd	s3,40(sp)
    800049ce:	0880                	add	s0,sp,80
    800049d0:	84aa                	mv	s1,a0
    800049d2:	89ae                	mv	s3,a1
    800049d4:	ffffd097          	auipc	ra,0xffffd
    800049d8:	050080e7          	jalr	80(ra) # 80001a24 <myproc>
    800049dc:	409c                	lw	a5,0(s1)
    800049de:	37f9                	addw	a5,a5,-2
    800049e0:	4705                	li	a4,1
    800049e2:	04f76863          	bltu	a4,a5,80004a32 <filestat+0x6e>
    800049e6:	f84a                	sd	s2,48(sp)
    800049e8:	892a                	mv	s2,a0
    800049ea:	6c88                	ld	a0,24(s1)
    800049ec:	fffff097          	auipc	ra,0xfffff
    800049f0:	05a080e7          	jalr	90(ra) # 80003a46 <ilock>
    800049f4:	fb840593          	add	a1,s0,-72
    800049f8:	6c88                	ld	a0,24(s1)
    800049fa:	fffff097          	auipc	ra,0xfffff
    800049fe:	2da080e7          	jalr	730(ra) # 80003cd4 <stati>
    80004a02:	6c88                	ld	a0,24(s1)
    80004a04:	fffff097          	auipc	ra,0xfffff
    80004a08:	108080e7          	jalr	264(ra) # 80003b0c <iunlock>
    80004a0c:	46e1                	li	a3,24
    80004a0e:	fb840613          	add	a2,s0,-72
    80004a12:	85ce                	mv	a1,s3
    80004a14:	08093503          	ld	a0,128(s2)
    80004a18:	ffffd097          	auipc	ra,0xffffd
    80004a1c:	cb4080e7          	jalr	-844(ra) # 800016cc <copyout>
    80004a20:	41f5551b          	sraw	a0,a0,0x1f
    80004a24:	7942                	ld	s2,48(sp)
    80004a26:	60a6                	ld	ra,72(sp)
    80004a28:	6406                	ld	s0,64(sp)
    80004a2a:	74e2                	ld	s1,56(sp)
    80004a2c:	79a2                	ld	s3,40(sp)
    80004a2e:	6161                	add	sp,sp,80
    80004a30:	8082                	ret
    80004a32:	557d                	li	a0,-1
    80004a34:	bfcd                	j	80004a26 <filestat+0x62>

0000000080004a36 <fileread>:
    80004a36:	7179                	add	sp,sp,-48
    80004a38:	f406                	sd	ra,40(sp)
    80004a3a:	f022                	sd	s0,32(sp)
    80004a3c:	e84a                	sd	s2,16(sp)
    80004a3e:	1800                	add	s0,sp,48
    80004a40:	00854783          	lbu	a5,8(a0)
    80004a44:	cbc5                	beqz	a5,80004af4 <fileread+0xbe>
    80004a46:	ec26                	sd	s1,24(sp)
    80004a48:	e44e                	sd	s3,8(sp)
    80004a4a:	84aa                	mv	s1,a0
    80004a4c:	89ae                	mv	s3,a1
    80004a4e:	8932                	mv	s2,a2
    80004a50:	411c                	lw	a5,0(a0)
    80004a52:	4705                	li	a4,1
    80004a54:	04e78963          	beq	a5,a4,80004aa6 <fileread+0x70>
    80004a58:	470d                	li	a4,3
    80004a5a:	04e78f63          	beq	a5,a4,80004ab8 <fileread+0x82>
    80004a5e:	4709                	li	a4,2
    80004a60:	08e79263          	bne	a5,a4,80004ae4 <fileread+0xae>
    80004a64:	6d08                	ld	a0,24(a0)
    80004a66:	fffff097          	auipc	ra,0xfffff
    80004a6a:	fe0080e7          	jalr	-32(ra) # 80003a46 <ilock>
    80004a6e:	874a                	mv	a4,s2
    80004a70:	5094                	lw	a3,32(s1)
    80004a72:	864e                	mv	a2,s3
    80004a74:	4585                	li	a1,1
    80004a76:	6c88                	ld	a0,24(s1)
    80004a78:	fffff097          	auipc	ra,0xfffff
    80004a7c:	286080e7          	jalr	646(ra) # 80003cfe <readi>
    80004a80:	892a                	mv	s2,a0
    80004a82:	00a05563          	blez	a0,80004a8c <fileread+0x56>
    80004a86:	509c                	lw	a5,32(s1)
    80004a88:	9fa9                	addw	a5,a5,a0
    80004a8a:	d09c                	sw	a5,32(s1)
    80004a8c:	6c88                	ld	a0,24(s1)
    80004a8e:	fffff097          	auipc	ra,0xfffff
    80004a92:	07e080e7          	jalr	126(ra) # 80003b0c <iunlock>
    80004a96:	64e2                	ld	s1,24(sp)
    80004a98:	69a2                	ld	s3,8(sp)
    80004a9a:	854a                	mv	a0,s2
    80004a9c:	70a2                	ld	ra,40(sp)
    80004a9e:	7402                	ld	s0,32(sp)
    80004aa0:	6942                	ld	s2,16(sp)
    80004aa2:	6145                	add	sp,sp,48
    80004aa4:	8082                	ret
    80004aa6:	6908                	ld	a0,16(a0)
    80004aa8:	00000097          	auipc	ra,0x0
    80004aac:	3fa080e7          	jalr	1018(ra) # 80004ea2 <piperead>
    80004ab0:	892a                	mv	s2,a0
    80004ab2:	64e2                	ld	s1,24(sp)
    80004ab4:	69a2                	ld	s3,8(sp)
    80004ab6:	b7d5                	j	80004a9a <fileread+0x64>
    80004ab8:	02451783          	lh	a5,36(a0)
    80004abc:	03079693          	sll	a3,a5,0x30
    80004ac0:	92c1                	srl	a3,a3,0x30
    80004ac2:	4725                	li	a4,9
    80004ac4:	02d76a63          	bltu	a4,a3,80004af8 <fileread+0xc2>
    80004ac8:	0792                	sll	a5,a5,0x4
    80004aca:	0001d717          	auipc	a4,0x1d
    80004ace:	44e70713          	add	a4,a4,1102 # 80021f18 <devsw>
    80004ad2:	97ba                	add	a5,a5,a4
    80004ad4:	639c                	ld	a5,0(a5)
    80004ad6:	c78d                	beqz	a5,80004b00 <fileread+0xca>
    80004ad8:	4505                	li	a0,1
    80004ada:	9782                	jalr	a5
    80004adc:	892a                	mv	s2,a0
    80004ade:	64e2                	ld	s1,24(sp)
    80004ae0:	69a2                	ld	s3,8(sp)
    80004ae2:	bf65                	j	80004a9a <fileread+0x64>
    80004ae4:	00004517          	auipc	a0,0x4
    80004ae8:	aa450513          	add	a0,a0,-1372 # 80008588 <etext+0x588>
    80004aec:	ffffc097          	auipc	ra,0xffffc
    80004af0:	a6e080e7          	jalr	-1426(ra) # 8000055a <panic>
    80004af4:	597d                	li	s2,-1
    80004af6:	b755                	j	80004a9a <fileread+0x64>
    80004af8:	597d                	li	s2,-1
    80004afa:	64e2                	ld	s1,24(sp)
    80004afc:	69a2                	ld	s3,8(sp)
    80004afe:	bf71                	j	80004a9a <fileread+0x64>
    80004b00:	597d                	li	s2,-1
    80004b02:	64e2                	ld	s1,24(sp)
    80004b04:	69a2                	ld	s3,8(sp)
    80004b06:	bf51                	j	80004a9a <fileread+0x64>

0000000080004b08 <filewrite>:
    80004b08:	00954783          	lbu	a5,9(a0)
    80004b0c:	12078963          	beqz	a5,80004c3e <filewrite+0x136>
    80004b10:	715d                	add	sp,sp,-80
    80004b12:	e486                	sd	ra,72(sp)
    80004b14:	e0a2                	sd	s0,64(sp)
    80004b16:	f84a                	sd	s2,48(sp)
    80004b18:	f052                	sd	s4,32(sp)
    80004b1a:	e85a                	sd	s6,16(sp)
    80004b1c:	0880                	add	s0,sp,80
    80004b1e:	892a                	mv	s2,a0
    80004b20:	8b2e                	mv	s6,a1
    80004b22:	8a32                	mv	s4,a2
    80004b24:	411c                	lw	a5,0(a0)
    80004b26:	4705                	li	a4,1
    80004b28:	02e78763          	beq	a5,a4,80004b56 <filewrite+0x4e>
    80004b2c:	470d                	li	a4,3
    80004b2e:	02e78a63          	beq	a5,a4,80004b62 <filewrite+0x5a>
    80004b32:	4709                	li	a4,2
    80004b34:	0ee79863          	bne	a5,a4,80004c24 <filewrite+0x11c>
    80004b38:	f44e                	sd	s3,40(sp)
    80004b3a:	0cc05463          	blez	a2,80004c02 <filewrite+0xfa>
    80004b3e:	fc26                	sd	s1,56(sp)
    80004b40:	ec56                	sd	s5,24(sp)
    80004b42:	e45e                	sd	s7,8(sp)
    80004b44:	e062                	sd	s8,0(sp)
    80004b46:	4981                	li	s3,0
    80004b48:	6b85                	lui	s7,0x1
    80004b4a:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004b4e:	6c05                	lui	s8,0x1
    80004b50:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004b54:	a851                	j	80004be8 <filewrite+0xe0>
    80004b56:	6908                	ld	a0,16(a0)
    80004b58:	00000097          	auipc	ra,0x0
    80004b5c:	248080e7          	jalr	584(ra) # 80004da0 <pipewrite>
    80004b60:	a85d                	j	80004c16 <filewrite+0x10e>
    80004b62:	02451783          	lh	a5,36(a0)
    80004b66:	03079693          	sll	a3,a5,0x30
    80004b6a:	92c1                	srl	a3,a3,0x30
    80004b6c:	4725                	li	a4,9
    80004b6e:	0cd76a63          	bltu	a4,a3,80004c42 <filewrite+0x13a>
    80004b72:	0792                	sll	a5,a5,0x4
    80004b74:	0001d717          	auipc	a4,0x1d
    80004b78:	3a470713          	add	a4,a4,932 # 80021f18 <devsw>
    80004b7c:	97ba                	add	a5,a5,a4
    80004b7e:	679c                	ld	a5,8(a5)
    80004b80:	c3f9                	beqz	a5,80004c46 <filewrite+0x13e>
    80004b82:	4505                	li	a0,1
    80004b84:	9782                	jalr	a5
    80004b86:	a841                	j	80004c16 <filewrite+0x10e>
    80004b88:	00048a9b          	sext.w	s5,s1
    80004b8c:	00000097          	auipc	ra,0x0
    80004b90:	88c080e7          	jalr	-1908(ra) # 80004418 <begin_op>
    80004b94:	01893503          	ld	a0,24(s2)
    80004b98:	fffff097          	auipc	ra,0xfffff
    80004b9c:	eae080e7          	jalr	-338(ra) # 80003a46 <ilock>
    80004ba0:	8756                	mv	a4,s5
    80004ba2:	02092683          	lw	a3,32(s2)
    80004ba6:	01698633          	add	a2,s3,s6
    80004baa:	4585                	li	a1,1
    80004bac:	01893503          	ld	a0,24(s2)
    80004bb0:	fffff097          	auipc	ra,0xfffff
    80004bb4:	252080e7          	jalr	594(ra) # 80003e02 <writei>
    80004bb8:	84aa                	mv	s1,a0
    80004bba:	00a05763          	blez	a0,80004bc8 <filewrite+0xc0>
    80004bbe:	02092783          	lw	a5,32(s2)
    80004bc2:	9fa9                	addw	a5,a5,a0
    80004bc4:	02f92023          	sw	a5,32(s2)
    80004bc8:	01893503          	ld	a0,24(s2)
    80004bcc:	fffff097          	auipc	ra,0xfffff
    80004bd0:	f40080e7          	jalr	-192(ra) # 80003b0c <iunlock>
    80004bd4:	00000097          	auipc	ra,0x0
    80004bd8:	8be080e7          	jalr	-1858(ra) # 80004492 <end_op>
    80004bdc:	029a9563          	bne	s5,s1,80004c06 <filewrite+0xfe>
    80004be0:	013489bb          	addw	s3,s1,s3
    80004be4:	0149da63          	bge	s3,s4,80004bf8 <filewrite+0xf0>
    80004be8:	413a04bb          	subw	s1,s4,s3
    80004bec:	0004879b          	sext.w	a5,s1
    80004bf0:	f8fbdce3          	bge	s7,a5,80004b88 <filewrite+0x80>
    80004bf4:	84e2                	mv	s1,s8
    80004bf6:	bf49                	j	80004b88 <filewrite+0x80>
    80004bf8:	74e2                	ld	s1,56(sp)
    80004bfa:	6ae2                	ld	s5,24(sp)
    80004bfc:	6ba2                	ld	s7,8(sp)
    80004bfe:	6c02                	ld	s8,0(sp)
    80004c00:	a039                	j	80004c0e <filewrite+0x106>
    80004c02:	4981                	li	s3,0
    80004c04:	a029                	j	80004c0e <filewrite+0x106>
    80004c06:	74e2                	ld	s1,56(sp)
    80004c08:	6ae2                	ld	s5,24(sp)
    80004c0a:	6ba2                	ld	s7,8(sp)
    80004c0c:	6c02                	ld	s8,0(sp)
    80004c0e:	033a1e63          	bne	s4,s3,80004c4a <filewrite+0x142>
    80004c12:	8552                	mv	a0,s4
    80004c14:	79a2                	ld	s3,40(sp)
    80004c16:	60a6                	ld	ra,72(sp)
    80004c18:	6406                	ld	s0,64(sp)
    80004c1a:	7942                	ld	s2,48(sp)
    80004c1c:	7a02                	ld	s4,32(sp)
    80004c1e:	6b42                	ld	s6,16(sp)
    80004c20:	6161                	add	sp,sp,80
    80004c22:	8082                	ret
    80004c24:	fc26                	sd	s1,56(sp)
    80004c26:	f44e                	sd	s3,40(sp)
    80004c28:	ec56                	sd	s5,24(sp)
    80004c2a:	e45e                	sd	s7,8(sp)
    80004c2c:	e062                	sd	s8,0(sp)
    80004c2e:	00004517          	auipc	a0,0x4
    80004c32:	96a50513          	add	a0,a0,-1686 # 80008598 <etext+0x598>
    80004c36:	ffffc097          	auipc	ra,0xffffc
    80004c3a:	924080e7          	jalr	-1756(ra) # 8000055a <panic>
    80004c3e:	557d                	li	a0,-1
    80004c40:	8082                	ret
    80004c42:	557d                	li	a0,-1
    80004c44:	bfc9                	j	80004c16 <filewrite+0x10e>
    80004c46:	557d                	li	a0,-1
    80004c48:	b7f9                	j	80004c16 <filewrite+0x10e>
    80004c4a:	557d                	li	a0,-1
    80004c4c:	79a2                	ld	s3,40(sp)
    80004c4e:	b7e1                	j	80004c16 <filewrite+0x10e>

0000000080004c50 <pipealloc>:
    80004c50:	7179                	add	sp,sp,-48
    80004c52:	f406                	sd	ra,40(sp)
    80004c54:	f022                	sd	s0,32(sp)
    80004c56:	ec26                	sd	s1,24(sp)
    80004c58:	e052                	sd	s4,0(sp)
    80004c5a:	1800                	add	s0,sp,48
    80004c5c:	84aa                	mv	s1,a0
    80004c5e:	8a2e                	mv	s4,a1
    80004c60:	0005b023          	sd	zero,0(a1)
    80004c64:	00053023          	sd	zero,0(a0)
    80004c68:	00000097          	auipc	ra,0x0
    80004c6c:	bbe080e7          	jalr	-1090(ra) # 80004826 <filealloc>
    80004c70:	e088                	sd	a0,0(s1)
    80004c72:	cd49                	beqz	a0,80004d0c <pipealloc+0xbc>
    80004c74:	00000097          	auipc	ra,0x0
    80004c78:	bb2080e7          	jalr	-1102(ra) # 80004826 <filealloc>
    80004c7c:	00aa3023          	sd	a0,0(s4)
    80004c80:	c141                	beqz	a0,80004d00 <pipealloc+0xb0>
    80004c82:	e84a                	sd	s2,16(sp)
    80004c84:	ffffc097          	auipc	ra,0xffffc
    80004c88:	ebe080e7          	jalr	-322(ra) # 80000b42 <kalloc>
    80004c8c:	892a                	mv	s2,a0
    80004c8e:	c13d                	beqz	a0,80004cf4 <pipealloc+0xa4>
    80004c90:	e44e                	sd	s3,8(sp)
    80004c92:	4985                	li	s3,1
    80004c94:	23352023          	sw	s3,544(a0)
    80004c98:	23352223          	sw	s3,548(a0)
    80004c9c:	20052e23          	sw	zero,540(a0)
    80004ca0:	20052c23          	sw	zero,536(a0)
    80004ca4:	00004597          	auipc	a1,0x4
    80004ca8:	90458593          	add	a1,a1,-1788 # 800085a8 <etext+0x5a8>
    80004cac:	ffffc097          	auipc	ra,0xffffc
    80004cb0:	ef6080e7          	jalr	-266(ra) # 80000ba2 <initlock>
    80004cb4:	609c                	ld	a5,0(s1)
    80004cb6:	0137a023          	sw	s3,0(a5)
    80004cba:	609c                	ld	a5,0(s1)
    80004cbc:	01378423          	sb	s3,8(a5)
    80004cc0:	609c                	ld	a5,0(s1)
    80004cc2:	000784a3          	sb	zero,9(a5)
    80004cc6:	609c                	ld	a5,0(s1)
    80004cc8:	0127b823          	sd	s2,16(a5)
    80004ccc:	000a3783          	ld	a5,0(s4)
    80004cd0:	0137a023          	sw	s3,0(a5)
    80004cd4:	000a3783          	ld	a5,0(s4)
    80004cd8:	00078423          	sb	zero,8(a5)
    80004cdc:	000a3783          	ld	a5,0(s4)
    80004ce0:	013784a3          	sb	s3,9(a5)
    80004ce4:	000a3783          	ld	a5,0(s4)
    80004ce8:	0127b823          	sd	s2,16(a5)
    80004cec:	4501                	li	a0,0
    80004cee:	6942                	ld	s2,16(sp)
    80004cf0:	69a2                	ld	s3,8(sp)
    80004cf2:	a03d                	j	80004d20 <pipealloc+0xd0>
    80004cf4:	6088                	ld	a0,0(s1)
    80004cf6:	c119                	beqz	a0,80004cfc <pipealloc+0xac>
    80004cf8:	6942                	ld	s2,16(sp)
    80004cfa:	a029                	j	80004d04 <pipealloc+0xb4>
    80004cfc:	6942                	ld	s2,16(sp)
    80004cfe:	a039                	j	80004d0c <pipealloc+0xbc>
    80004d00:	6088                	ld	a0,0(s1)
    80004d02:	c50d                	beqz	a0,80004d2c <pipealloc+0xdc>
    80004d04:	00000097          	auipc	ra,0x0
    80004d08:	bde080e7          	jalr	-1058(ra) # 800048e2 <fileclose>
    80004d0c:	000a3783          	ld	a5,0(s4)
    80004d10:	557d                	li	a0,-1
    80004d12:	c799                	beqz	a5,80004d20 <pipealloc+0xd0>
    80004d14:	853e                	mv	a0,a5
    80004d16:	00000097          	auipc	ra,0x0
    80004d1a:	bcc080e7          	jalr	-1076(ra) # 800048e2 <fileclose>
    80004d1e:	557d                	li	a0,-1
    80004d20:	70a2                	ld	ra,40(sp)
    80004d22:	7402                	ld	s0,32(sp)
    80004d24:	64e2                	ld	s1,24(sp)
    80004d26:	6a02                	ld	s4,0(sp)
    80004d28:	6145                	add	sp,sp,48
    80004d2a:	8082                	ret
    80004d2c:	557d                	li	a0,-1
    80004d2e:	bfcd                	j	80004d20 <pipealloc+0xd0>

0000000080004d30 <pipeclose>:
    80004d30:	1101                	add	sp,sp,-32
    80004d32:	ec06                	sd	ra,24(sp)
    80004d34:	e822                	sd	s0,16(sp)
    80004d36:	e426                	sd	s1,8(sp)
    80004d38:	e04a                	sd	s2,0(sp)
    80004d3a:	1000                	add	s0,sp,32
    80004d3c:	84aa                	mv	s1,a0
    80004d3e:	892e                	mv	s2,a1
    80004d40:	ffffc097          	auipc	ra,0xffffc
    80004d44:	ef2080e7          	jalr	-270(ra) # 80000c32 <acquire>
    80004d48:	02090d63          	beqz	s2,80004d82 <pipeclose+0x52>
    80004d4c:	2204a223          	sw	zero,548(s1)
    80004d50:	21848513          	add	a0,s1,536
    80004d54:	ffffd097          	auipc	ra,0xffffd
    80004d58:	540080e7          	jalr	1344(ra) # 80002294 <wakeup>
    80004d5c:	2204b783          	ld	a5,544(s1)
    80004d60:	eb95                	bnez	a5,80004d94 <pipeclose+0x64>
    80004d62:	8526                	mv	a0,s1
    80004d64:	ffffc097          	auipc	ra,0xffffc
    80004d68:	f82080e7          	jalr	-126(ra) # 80000ce6 <release>
    80004d6c:	8526                	mv	a0,s1
    80004d6e:	ffffc097          	auipc	ra,0xffffc
    80004d72:	cd6080e7          	jalr	-810(ra) # 80000a44 <kfree>
    80004d76:	60e2                	ld	ra,24(sp)
    80004d78:	6442                	ld	s0,16(sp)
    80004d7a:	64a2                	ld	s1,8(sp)
    80004d7c:	6902                	ld	s2,0(sp)
    80004d7e:	6105                	add	sp,sp,32
    80004d80:	8082                	ret
    80004d82:	2204a023          	sw	zero,544(s1)
    80004d86:	21c48513          	add	a0,s1,540
    80004d8a:	ffffd097          	auipc	ra,0xffffd
    80004d8e:	50a080e7          	jalr	1290(ra) # 80002294 <wakeup>
    80004d92:	b7e9                	j	80004d5c <pipeclose+0x2c>
    80004d94:	8526                	mv	a0,s1
    80004d96:	ffffc097          	auipc	ra,0xffffc
    80004d9a:	f50080e7          	jalr	-176(ra) # 80000ce6 <release>
    80004d9e:	bfe1                	j	80004d76 <pipeclose+0x46>

0000000080004da0 <pipewrite>:
    80004da0:	711d                	add	sp,sp,-96
    80004da2:	ec86                	sd	ra,88(sp)
    80004da4:	e8a2                	sd	s0,80(sp)
    80004da6:	e4a6                	sd	s1,72(sp)
    80004da8:	e0ca                	sd	s2,64(sp)
    80004daa:	fc4e                	sd	s3,56(sp)
    80004dac:	f852                	sd	s4,48(sp)
    80004dae:	f456                	sd	s5,40(sp)
    80004db0:	1080                	add	s0,sp,96
    80004db2:	84aa                	mv	s1,a0
    80004db4:	8aae                	mv	s5,a1
    80004db6:	8a32                	mv	s4,a2
    80004db8:	ffffd097          	auipc	ra,0xffffd
    80004dbc:	c6c080e7          	jalr	-916(ra) # 80001a24 <myproc>
    80004dc0:	89aa                	mv	s3,a0
    80004dc2:	8526                	mv	a0,s1
    80004dc4:	ffffc097          	auipc	ra,0xffffc
    80004dc8:	e6e080e7          	jalr	-402(ra) # 80000c32 <acquire>
    80004dcc:	0d405563          	blez	s4,80004e96 <pipewrite+0xf6>
    80004dd0:	f05a                	sd	s6,32(sp)
    80004dd2:	ec5e                	sd	s7,24(sp)
    80004dd4:	e862                	sd	s8,16(sp)
    80004dd6:	4901                	li	s2,0
    80004dd8:	5b7d                	li	s6,-1
    80004dda:	21848c13          	add	s8,s1,536
    80004dde:	21c48b93          	add	s7,s1,540
    80004de2:	a089                	j	80004e24 <pipewrite+0x84>
    80004de4:	8526                	mv	a0,s1
    80004de6:	ffffc097          	auipc	ra,0xffffc
    80004dea:	f00080e7          	jalr	-256(ra) # 80000ce6 <release>
    80004dee:	597d                	li	s2,-1
    80004df0:	7b02                	ld	s6,32(sp)
    80004df2:	6be2                	ld	s7,24(sp)
    80004df4:	6c42                	ld	s8,16(sp)
    80004df6:	854a                	mv	a0,s2
    80004df8:	60e6                	ld	ra,88(sp)
    80004dfa:	6446                	ld	s0,80(sp)
    80004dfc:	64a6                	ld	s1,72(sp)
    80004dfe:	6906                	ld	s2,64(sp)
    80004e00:	79e2                	ld	s3,56(sp)
    80004e02:	7a42                	ld	s4,48(sp)
    80004e04:	7aa2                	ld	s5,40(sp)
    80004e06:	6125                	add	sp,sp,96
    80004e08:	8082                	ret
    80004e0a:	8562                	mv	a0,s8
    80004e0c:	ffffd097          	auipc	ra,0xffffd
    80004e10:	488080e7          	jalr	1160(ra) # 80002294 <wakeup>
    80004e14:	85a6                	mv	a1,s1
    80004e16:	855e                	mv	a0,s7
    80004e18:	ffffd097          	auipc	ra,0xffffd
    80004e1c:	2f0080e7          	jalr	752(ra) # 80002108 <sleep>
    80004e20:	05495c63          	bge	s2,s4,80004e78 <pipewrite+0xd8>
    80004e24:	2204a783          	lw	a5,544(s1)
    80004e28:	dfd5                	beqz	a5,80004de4 <pipewrite+0x44>
    80004e2a:	0589a783          	lw	a5,88(s3)
    80004e2e:	fbdd                	bnez	a5,80004de4 <pipewrite+0x44>
    80004e30:	2184a783          	lw	a5,536(s1)
    80004e34:	21c4a703          	lw	a4,540(s1)
    80004e38:	2007879b          	addw	a5,a5,512
    80004e3c:	fcf707e3          	beq	a4,a5,80004e0a <pipewrite+0x6a>
    80004e40:	4685                	li	a3,1
    80004e42:	01590633          	add	a2,s2,s5
    80004e46:	faf40593          	add	a1,s0,-81
    80004e4a:	0809b503          	ld	a0,128(s3)
    80004e4e:	ffffd097          	auipc	ra,0xffffd
    80004e52:	90a080e7          	jalr	-1782(ra) # 80001758 <copyin>
    80004e56:	05650263          	beq	a0,s6,80004e9a <pipewrite+0xfa>
    80004e5a:	21c4a783          	lw	a5,540(s1)
    80004e5e:	0017871b          	addw	a4,a5,1
    80004e62:	20e4ae23          	sw	a4,540(s1)
    80004e66:	1ff7f793          	and	a5,a5,511
    80004e6a:	97a6                	add	a5,a5,s1
    80004e6c:	faf44703          	lbu	a4,-81(s0)
    80004e70:	00e78c23          	sb	a4,24(a5)
    80004e74:	2905                	addw	s2,s2,1
    80004e76:	b76d                	j	80004e20 <pipewrite+0x80>
    80004e78:	7b02                	ld	s6,32(sp)
    80004e7a:	6be2                	ld	s7,24(sp)
    80004e7c:	6c42                	ld	s8,16(sp)
    80004e7e:	21848513          	add	a0,s1,536
    80004e82:	ffffd097          	auipc	ra,0xffffd
    80004e86:	412080e7          	jalr	1042(ra) # 80002294 <wakeup>
    80004e8a:	8526                	mv	a0,s1
    80004e8c:	ffffc097          	auipc	ra,0xffffc
    80004e90:	e5a080e7          	jalr	-422(ra) # 80000ce6 <release>
    80004e94:	b78d                	j	80004df6 <pipewrite+0x56>
    80004e96:	4901                	li	s2,0
    80004e98:	b7dd                	j	80004e7e <pipewrite+0xde>
    80004e9a:	7b02                	ld	s6,32(sp)
    80004e9c:	6be2                	ld	s7,24(sp)
    80004e9e:	6c42                	ld	s8,16(sp)
    80004ea0:	bff9                	j	80004e7e <pipewrite+0xde>

0000000080004ea2 <piperead>:
    80004ea2:	715d                	add	sp,sp,-80
    80004ea4:	e486                	sd	ra,72(sp)
    80004ea6:	e0a2                	sd	s0,64(sp)
    80004ea8:	fc26                	sd	s1,56(sp)
    80004eaa:	f84a                	sd	s2,48(sp)
    80004eac:	f44e                	sd	s3,40(sp)
    80004eae:	f052                	sd	s4,32(sp)
    80004eb0:	ec56                	sd	s5,24(sp)
    80004eb2:	0880                	add	s0,sp,80
    80004eb4:	84aa                	mv	s1,a0
    80004eb6:	892e                	mv	s2,a1
    80004eb8:	8ab2                	mv	s5,a2
    80004eba:	ffffd097          	auipc	ra,0xffffd
    80004ebe:	b6a080e7          	jalr	-1174(ra) # 80001a24 <myproc>
    80004ec2:	8a2a                	mv	s4,a0
    80004ec4:	8526                	mv	a0,s1
    80004ec6:	ffffc097          	auipc	ra,0xffffc
    80004eca:	d6c080e7          	jalr	-660(ra) # 80000c32 <acquire>
    80004ece:	2184a703          	lw	a4,536(s1)
    80004ed2:	21c4a783          	lw	a5,540(s1)
    80004ed6:	21848993          	add	s3,s1,536
    80004eda:	02f71663          	bne	a4,a5,80004f06 <piperead+0x64>
    80004ede:	2244a783          	lw	a5,548(s1)
    80004ee2:	cb9d                	beqz	a5,80004f18 <piperead+0x76>
    80004ee4:	058a2783          	lw	a5,88(s4)
    80004ee8:	e38d                	bnez	a5,80004f0a <piperead+0x68>
    80004eea:	85a6                	mv	a1,s1
    80004eec:	854e                	mv	a0,s3
    80004eee:	ffffd097          	auipc	ra,0xffffd
    80004ef2:	21a080e7          	jalr	538(ra) # 80002108 <sleep>
    80004ef6:	2184a703          	lw	a4,536(s1)
    80004efa:	21c4a783          	lw	a5,540(s1)
    80004efe:	fef700e3          	beq	a4,a5,80004ede <piperead+0x3c>
    80004f02:	e85a                	sd	s6,16(sp)
    80004f04:	a819                	j	80004f1a <piperead+0x78>
    80004f06:	e85a                	sd	s6,16(sp)
    80004f08:	a809                	j	80004f1a <piperead+0x78>
    80004f0a:	8526                	mv	a0,s1
    80004f0c:	ffffc097          	auipc	ra,0xffffc
    80004f10:	dda080e7          	jalr	-550(ra) # 80000ce6 <release>
    80004f14:	59fd                	li	s3,-1
    80004f16:	a0a5                	j	80004f7e <piperead+0xdc>
    80004f18:	e85a                	sd	s6,16(sp)
    80004f1a:	4981                	li	s3,0
    80004f1c:	5b7d                	li	s6,-1
    80004f1e:	05505463          	blez	s5,80004f66 <piperead+0xc4>
    80004f22:	2184a783          	lw	a5,536(s1)
    80004f26:	21c4a703          	lw	a4,540(s1)
    80004f2a:	02f70e63          	beq	a4,a5,80004f66 <piperead+0xc4>
    80004f2e:	0017871b          	addw	a4,a5,1
    80004f32:	20e4ac23          	sw	a4,536(s1)
    80004f36:	1ff7f793          	and	a5,a5,511
    80004f3a:	97a6                	add	a5,a5,s1
    80004f3c:	0187c783          	lbu	a5,24(a5)
    80004f40:	faf40fa3          	sb	a5,-65(s0)
    80004f44:	4685                	li	a3,1
    80004f46:	fbf40613          	add	a2,s0,-65
    80004f4a:	85ca                	mv	a1,s2
    80004f4c:	080a3503          	ld	a0,128(s4)
    80004f50:	ffffc097          	auipc	ra,0xffffc
    80004f54:	77c080e7          	jalr	1916(ra) # 800016cc <copyout>
    80004f58:	01650763          	beq	a0,s6,80004f66 <piperead+0xc4>
    80004f5c:	2985                	addw	s3,s3,1
    80004f5e:	0905                	add	s2,s2,1
    80004f60:	fd3a91e3          	bne	s5,s3,80004f22 <piperead+0x80>
    80004f64:	89d6                	mv	s3,s5
    80004f66:	21c48513          	add	a0,s1,540
    80004f6a:	ffffd097          	auipc	ra,0xffffd
    80004f6e:	32a080e7          	jalr	810(ra) # 80002294 <wakeup>
    80004f72:	8526                	mv	a0,s1
    80004f74:	ffffc097          	auipc	ra,0xffffc
    80004f78:	d72080e7          	jalr	-654(ra) # 80000ce6 <release>
    80004f7c:	6b42                	ld	s6,16(sp)
    80004f7e:	854e                	mv	a0,s3
    80004f80:	60a6                	ld	ra,72(sp)
    80004f82:	6406                	ld	s0,64(sp)
    80004f84:	74e2                	ld	s1,56(sp)
    80004f86:	7942                	ld	s2,48(sp)
    80004f88:	79a2                	ld	s3,40(sp)
    80004f8a:	7a02                	ld	s4,32(sp)
    80004f8c:	6ae2                	ld	s5,24(sp)
    80004f8e:	6161                	add	sp,sp,80
    80004f90:	8082                	ret

0000000080004f92 <exec>:
    80004f92:	df010113          	add	sp,sp,-528
    80004f96:	20113423          	sd	ra,520(sp)
    80004f9a:	20813023          	sd	s0,512(sp)
    80004f9e:	ffa6                	sd	s1,504(sp)
    80004fa0:	fbca                	sd	s2,496(sp)
    80004fa2:	0c00                	add	s0,sp,528
    80004fa4:	892a                	mv	s2,a0
    80004fa6:	dea43c23          	sd	a0,-520(s0)
    80004faa:	e0b43023          	sd	a1,-512(s0)
    80004fae:	ffffd097          	auipc	ra,0xffffd
    80004fb2:	a76080e7          	jalr	-1418(ra) # 80001a24 <myproc>
    80004fb6:	84aa                	mv	s1,a0
    80004fb8:	fffff097          	auipc	ra,0xfffff
    80004fbc:	460080e7          	jalr	1120(ra) # 80004418 <begin_op>
    80004fc0:	854a                	mv	a0,s2
    80004fc2:	fffff097          	auipc	ra,0xfffff
    80004fc6:	256080e7          	jalr	598(ra) # 80004218 <namei>
    80004fca:	c135                	beqz	a0,8000502e <exec+0x9c>
    80004fcc:	f3d2                	sd	s4,480(sp)
    80004fce:	8a2a                	mv	s4,a0
    80004fd0:	fffff097          	auipc	ra,0xfffff
    80004fd4:	a76080e7          	jalr	-1418(ra) # 80003a46 <ilock>
    80004fd8:	04000713          	li	a4,64
    80004fdc:	4681                	li	a3,0
    80004fde:	e5040613          	add	a2,s0,-432
    80004fe2:	4581                	li	a1,0
    80004fe4:	8552                	mv	a0,s4
    80004fe6:	fffff097          	auipc	ra,0xfffff
    80004fea:	d18080e7          	jalr	-744(ra) # 80003cfe <readi>
    80004fee:	04000793          	li	a5,64
    80004ff2:	00f51a63          	bne	a0,a5,80005006 <exec+0x74>
    80004ff6:	e5042703          	lw	a4,-432(s0)
    80004ffa:	464c47b7          	lui	a5,0x464c4
    80004ffe:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005002:	02f70c63          	beq	a4,a5,8000503a <exec+0xa8>
    80005006:	8552                	mv	a0,s4
    80005008:	fffff097          	auipc	ra,0xfffff
    8000500c:	ca4080e7          	jalr	-860(ra) # 80003cac <iunlockput>
    80005010:	fffff097          	auipc	ra,0xfffff
    80005014:	482080e7          	jalr	1154(ra) # 80004492 <end_op>
    80005018:	557d                	li	a0,-1
    8000501a:	7a1e                	ld	s4,480(sp)
    8000501c:	20813083          	ld	ra,520(sp)
    80005020:	20013403          	ld	s0,512(sp)
    80005024:	74fe                	ld	s1,504(sp)
    80005026:	795e                	ld	s2,496(sp)
    80005028:	21010113          	add	sp,sp,528
    8000502c:	8082                	ret
    8000502e:	fffff097          	auipc	ra,0xfffff
    80005032:	464080e7          	jalr	1124(ra) # 80004492 <end_op>
    80005036:	557d                	li	a0,-1
    80005038:	b7d5                	j	8000501c <exec+0x8a>
    8000503a:	ebda                	sd	s6,464(sp)
    8000503c:	8526                	mv	a0,s1
    8000503e:	ffffd097          	auipc	ra,0xffffd
    80005042:	aaa080e7          	jalr	-1366(ra) # 80001ae8 <proc_pagetable>
    80005046:	8b2a                	mv	s6,a0
    80005048:	30050563          	beqz	a0,80005352 <exec+0x3c0>
    8000504c:	f7ce                	sd	s3,488(sp)
    8000504e:	efd6                	sd	s5,472(sp)
    80005050:	e7de                	sd	s7,456(sp)
    80005052:	e3e2                	sd	s8,448(sp)
    80005054:	ff66                	sd	s9,440(sp)
    80005056:	fb6a                	sd	s10,432(sp)
    80005058:	e7042d03          	lw	s10,-400(s0)
    8000505c:	e8845783          	lhu	a5,-376(s0)
    80005060:	14078563          	beqz	a5,800051aa <exec+0x218>
    80005064:	f76e                	sd	s11,424(sp)
    80005066:	4481                	li	s1,0
    80005068:	4d81                	li	s11,0
    8000506a:	6c85                	lui	s9,0x1
    8000506c:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    80005070:	def43823          	sd	a5,-528(s0)
    80005074:	6a85                	lui	s5,0x1
    80005076:	a0b5                	j	800050e2 <exec+0x150>
    80005078:	00003517          	auipc	a0,0x3
    8000507c:	53850513          	add	a0,a0,1336 # 800085b0 <etext+0x5b0>
    80005080:	ffffb097          	auipc	ra,0xffffb
    80005084:	4da080e7          	jalr	1242(ra) # 8000055a <panic>
    80005088:	2481                	sext.w	s1,s1
    8000508a:	8726                	mv	a4,s1
    8000508c:	012c06bb          	addw	a3,s8,s2
    80005090:	4581                	li	a1,0
    80005092:	8552                	mv	a0,s4
    80005094:	fffff097          	auipc	ra,0xfffff
    80005098:	c6a080e7          	jalr	-918(ra) # 80003cfe <readi>
    8000509c:	2501                	sext.w	a0,a0
    8000509e:	26a49e63          	bne	s1,a0,8000531a <exec+0x388>
    800050a2:	012a893b          	addw	s2,s5,s2
    800050a6:	03397563          	bgeu	s2,s3,800050d0 <exec+0x13e>
    800050aa:	02091593          	sll	a1,s2,0x20
    800050ae:	9181                	srl	a1,a1,0x20
    800050b0:	95de                	add	a1,a1,s7
    800050b2:	855a                	mv	a0,s6
    800050b4:	ffffc097          	auipc	ra,0xffffc
    800050b8:	ff8080e7          	jalr	-8(ra) # 800010ac <walkaddr>
    800050bc:	862a                	mv	a2,a0
    800050be:	dd4d                	beqz	a0,80005078 <exec+0xe6>
    800050c0:	412984bb          	subw	s1,s3,s2
    800050c4:	0004879b          	sext.w	a5,s1
    800050c8:	fcfcf0e3          	bgeu	s9,a5,80005088 <exec+0xf6>
    800050cc:	84d6                	mv	s1,s5
    800050ce:	bf6d                	j	80005088 <exec+0xf6>
    800050d0:	e0843483          	ld	s1,-504(s0)
    800050d4:	2d85                	addw	s11,s11,1
    800050d6:	038d0d1b          	addw	s10,s10,56
    800050da:	e8845783          	lhu	a5,-376(s0)
    800050de:	06fddf63          	bge	s11,a5,8000515c <exec+0x1ca>
    800050e2:	2d01                	sext.w	s10,s10
    800050e4:	03800713          	li	a4,56
    800050e8:	86ea                	mv	a3,s10
    800050ea:	e1840613          	add	a2,s0,-488
    800050ee:	4581                	li	a1,0
    800050f0:	8552                	mv	a0,s4
    800050f2:	fffff097          	auipc	ra,0xfffff
    800050f6:	c0c080e7          	jalr	-1012(ra) # 80003cfe <readi>
    800050fa:	03800793          	li	a5,56
    800050fe:	1ef51863          	bne	a0,a5,800052ee <exec+0x35c>
    80005102:	e1842783          	lw	a5,-488(s0)
    80005106:	4705                	li	a4,1
    80005108:	fce796e3          	bne	a5,a4,800050d4 <exec+0x142>
    8000510c:	e4043603          	ld	a2,-448(s0)
    80005110:	e3843783          	ld	a5,-456(s0)
    80005114:	1ef66163          	bltu	a2,a5,800052f6 <exec+0x364>
    80005118:	e2843783          	ld	a5,-472(s0)
    8000511c:	963e                	add	a2,a2,a5
    8000511e:	1ef66063          	bltu	a2,a5,800052fe <exec+0x36c>
    80005122:	85a6                	mv	a1,s1
    80005124:	855a                	mv	a0,s6
    80005126:	ffffc097          	auipc	ra,0xffffc
    8000512a:	34a080e7          	jalr	842(ra) # 80001470 <uvmalloc>
    8000512e:	e0a43423          	sd	a0,-504(s0)
    80005132:	1c050a63          	beqz	a0,80005306 <exec+0x374>
    80005136:	e2843b83          	ld	s7,-472(s0)
    8000513a:	df043783          	ld	a5,-528(s0)
    8000513e:	00fbf7b3          	and	a5,s7,a5
    80005142:	1c079a63          	bnez	a5,80005316 <exec+0x384>
    80005146:	e2042c03          	lw	s8,-480(s0)
    8000514a:	e3842983          	lw	s3,-456(s0)
    8000514e:	00098463          	beqz	s3,80005156 <exec+0x1c4>
    80005152:	4901                	li	s2,0
    80005154:	bf99                	j	800050aa <exec+0x118>
    80005156:	e0843483          	ld	s1,-504(s0)
    8000515a:	bfad                	j	800050d4 <exec+0x142>
    8000515c:	7dba                	ld	s11,424(sp)
    8000515e:	8552                	mv	a0,s4
    80005160:	fffff097          	auipc	ra,0xfffff
    80005164:	b4c080e7          	jalr	-1204(ra) # 80003cac <iunlockput>
    80005168:	fffff097          	auipc	ra,0xfffff
    8000516c:	32a080e7          	jalr	810(ra) # 80004492 <end_op>
    80005170:	ffffd097          	auipc	ra,0xffffd
    80005174:	8b4080e7          	jalr	-1868(ra) # 80001a24 <myproc>
    80005178:	8aaa                	mv	s5,a0
    8000517a:	07853c83          	ld	s9,120(a0)
    8000517e:	6985                	lui	s3,0x1
    80005180:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    80005182:	99a6                	add	s3,s3,s1
    80005184:	77fd                	lui	a5,0xfffff
    80005186:	00f9f9b3          	and	s3,s3,a5
    8000518a:	6609                	lui	a2,0x2
    8000518c:	964e                	add	a2,a2,s3
    8000518e:	85ce                	mv	a1,s3
    80005190:	855a                	mv	a0,s6
    80005192:	ffffc097          	auipc	ra,0xffffc
    80005196:	2de080e7          	jalr	734(ra) # 80001470 <uvmalloc>
    8000519a:	892a                	mv	s2,a0
    8000519c:	e0a43423          	sd	a0,-504(s0)
    800051a0:	e519                	bnez	a0,800051ae <exec+0x21c>
    800051a2:	e1343423          	sd	s3,-504(s0)
    800051a6:	4a01                	li	s4,0
    800051a8:	aa95                	j	8000531c <exec+0x38a>
    800051aa:	4481                	li	s1,0
    800051ac:	bf4d                	j	8000515e <exec+0x1cc>
    800051ae:	75f9                	lui	a1,0xffffe
    800051b0:	95aa                	add	a1,a1,a0
    800051b2:	855a                	mv	a0,s6
    800051b4:	ffffc097          	auipc	ra,0xffffc
    800051b8:	4e6080e7          	jalr	1254(ra) # 8000169a <uvmclear>
    800051bc:	7bfd                	lui	s7,0xfffff
    800051be:	9bca                	add	s7,s7,s2
    800051c0:	e0043783          	ld	a5,-512(s0)
    800051c4:	6388                	ld	a0,0(a5)
    800051c6:	c52d                	beqz	a0,80005230 <exec+0x29e>
    800051c8:	e9040993          	add	s3,s0,-368
    800051cc:	f9040c13          	add	s8,s0,-112
    800051d0:	4481                	li	s1,0
    800051d2:	ffffc097          	auipc	ra,0xffffc
    800051d6:	cd0080e7          	jalr	-816(ra) # 80000ea2 <strlen>
    800051da:	0015079b          	addw	a5,a0,1
    800051de:	40f907b3          	sub	a5,s2,a5
    800051e2:	ff07f913          	and	s2,a5,-16
    800051e6:	13796463          	bltu	s2,s7,8000530e <exec+0x37c>
    800051ea:	e0043d03          	ld	s10,-512(s0)
    800051ee:	000d3a03          	ld	s4,0(s10)
    800051f2:	8552                	mv	a0,s4
    800051f4:	ffffc097          	auipc	ra,0xffffc
    800051f8:	cae080e7          	jalr	-850(ra) # 80000ea2 <strlen>
    800051fc:	0015069b          	addw	a3,a0,1
    80005200:	8652                	mv	a2,s4
    80005202:	85ca                	mv	a1,s2
    80005204:	855a                	mv	a0,s6
    80005206:	ffffc097          	auipc	ra,0xffffc
    8000520a:	4c6080e7          	jalr	1222(ra) # 800016cc <copyout>
    8000520e:	10054263          	bltz	a0,80005312 <exec+0x380>
    80005212:	0129b023          	sd	s2,0(s3)
    80005216:	0485                	add	s1,s1,1
    80005218:	008d0793          	add	a5,s10,8
    8000521c:	e0f43023          	sd	a5,-512(s0)
    80005220:	008d3503          	ld	a0,8(s10)
    80005224:	c909                	beqz	a0,80005236 <exec+0x2a4>
    80005226:	09a1                	add	s3,s3,8
    80005228:	fb8995e3          	bne	s3,s8,800051d2 <exec+0x240>
    8000522c:	4a01                	li	s4,0
    8000522e:	a0fd                	j	8000531c <exec+0x38a>
    80005230:	e0843903          	ld	s2,-504(s0)
    80005234:	4481                	li	s1,0
    80005236:	00349793          	sll	a5,s1,0x3
    8000523a:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd8f90>
    8000523e:	97a2                	add	a5,a5,s0
    80005240:	f007b023          	sd	zero,-256(a5)
    80005244:	00148693          	add	a3,s1,1
    80005248:	068e                	sll	a3,a3,0x3
    8000524a:	40d90933          	sub	s2,s2,a3
    8000524e:	ff097913          	and	s2,s2,-16
    80005252:	e0843983          	ld	s3,-504(s0)
    80005256:	f57966e3          	bltu	s2,s7,800051a2 <exec+0x210>
    8000525a:	e9040613          	add	a2,s0,-368
    8000525e:	85ca                	mv	a1,s2
    80005260:	855a                	mv	a0,s6
    80005262:	ffffc097          	auipc	ra,0xffffc
    80005266:	46a080e7          	jalr	1130(ra) # 800016cc <copyout>
    8000526a:	0e054663          	bltz	a0,80005356 <exec+0x3c4>
    8000526e:	088ab783          	ld	a5,136(s5) # 1088 <_entry-0x7fffef78>
    80005272:	0727bc23          	sd	s2,120(a5)
    80005276:	df843783          	ld	a5,-520(s0)
    8000527a:	0007c703          	lbu	a4,0(a5)
    8000527e:	cf11                	beqz	a4,8000529a <exec+0x308>
    80005280:	0785                	add	a5,a5,1
    80005282:	02f00693          	li	a3,47
    80005286:	a039                	j	80005294 <exec+0x302>
    80005288:	def43c23          	sd	a5,-520(s0)
    8000528c:	0785                	add	a5,a5,1
    8000528e:	fff7c703          	lbu	a4,-1(a5)
    80005292:	c701                	beqz	a4,8000529a <exec+0x308>
    80005294:	fed71ce3          	bne	a4,a3,8000528c <exec+0x2fa>
    80005298:	bfc5                	j	80005288 <exec+0x2f6>
    8000529a:	4641                	li	a2,16
    8000529c:	df843583          	ld	a1,-520(s0)
    800052a0:	188a8513          	add	a0,s5,392
    800052a4:	ffffc097          	auipc	ra,0xffffc
    800052a8:	bcc080e7          	jalr	-1076(ra) # 80000e70 <safestrcpy>
    800052ac:	080ab503          	ld	a0,128(s5)
    800052b0:	096ab023          	sd	s6,128(s5)
    800052b4:	e0843783          	ld	a5,-504(s0)
    800052b8:	06fabc23          	sd	a5,120(s5)
    800052bc:	088ab783          	ld	a5,136(s5)
    800052c0:	e6843703          	ld	a4,-408(s0)
    800052c4:	ef98                	sd	a4,24(a5)
    800052c6:	088ab783          	ld	a5,136(s5)
    800052ca:	0327b823          	sd	s2,48(a5)
    800052ce:	85e6                	mv	a1,s9
    800052d0:	ffffd097          	auipc	ra,0xffffd
    800052d4:	8b4080e7          	jalr	-1868(ra) # 80001b84 <proc_freepagetable>
    800052d8:	0004851b          	sext.w	a0,s1
    800052dc:	79be                	ld	s3,488(sp)
    800052de:	7a1e                	ld	s4,480(sp)
    800052e0:	6afe                	ld	s5,472(sp)
    800052e2:	6b5e                	ld	s6,464(sp)
    800052e4:	6bbe                	ld	s7,456(sp)
    800052e6:	6c1e                	ld	s8,448(sp)
    800052e8:	7cfa                	ld	s9,440(sp)
    800052ea:	7d5a                	ld	s10,432(sp)
    800052ec:	bb05                	j	8000501c <exec+0x8a>
    800052ee:	e0943423          	sd	s1,-504(s0)
    800052f2:	7dba                	ld	s11,424(sp)
    800052f4:	a025                	j	8000531c <exec+0x38a>
    800052f6:	e0943423          	sd	s1,-504(s0)
    800052fa:	7dba                	ld	s11,424(sp)
    800052fc:	a005                	j	8000531c <exec+0x38a>
    800052fe:	e0943423          	sd	s1,-504(s0)
    80005302:	7dba                	ld	s11,424(sp)
    80005304:	a821                	j	8000531c <exec+0x38a>
    80005306:	e0943423          	sd	s1,-504(s0)
    8000530a:	7dba                	ld	s11,424(sp)
    8000530c:	a801                	j	8000531c <exec+0x38a>
    8000530e:	4a01                	li	s4,0
    80005310:	a031                	j	8000531c <exec+0x38a>
    80005312:	4a01                	li	s4,0
    80005314:	a021                	j	8000531c <exec+0x38a>
    80005316:	7dba                	ld	s11,424(sp)
    80005318:	a011                	j	8000531c <exec+0x38a>
    8000531a:	7dba                	ld	s11,424(sp)
    8000531c:	e0843583          	ld	a1,-504(s0)
    80005320:	855a                	mv	a0,s6
    80005322:	ffffd097          	auipc	ra,0xffffd
    80005326:	862080e7          	jalr	-1950(ra) # 80001b84 <proc_freepagetable>
    8000532a:	557d                	li	a0,-1
    8000532c:	000a1b63          	bnez	s4,80005342 <exec+0x3b0>
    80005330:	79be                	ld	s3,488(sp)
    80005332:	7a1e                	ld	s4,480(sp)
    80005334:	6afe                	ld	s5,472(sp)
    80005336:	6b5e                	ld	s6,464(sp)
    80005338:	6bbe                	ld	s7,456(sp)
    8000533a:	6c1e                	ld	s8,448(sp)
    8000533c:	7cfa                	ld	s9,440(sp)
    8000533e:	7d5a                	ld	s10,432(sp)
    80005340:	b9f1                	j	8000501c <exec+0x8a>
    80005342:	79be                	ld	s3,488(sp)
    80005344:	6afe                	ld	s5,472(sp)
    80005346:	6b5e                	ld	s6,464(sp)
    80005348:	6bbe                	ld	s7,456(sp)
    8000534a:	6c1e                	ld	s8,448(sp)
    8000534c:	7cfa                	ld	s9,440(sp)
    8000534e:	7d5a                	ld	s10,432(sp)
    80005350:	b95d                	j	80005006 <exec+0x74>
    80005352:	6b5e                	ld	s6,464(sp)
    80005354:	b94d                	j	80005006 <exec+0x74>
    80005356:	e0843983          	ld	s3,-504(s0)
    8000535a:	b5a1                	j	800051a2 <exec+0x210>

000000008000535c <argfd>:
    8000535c:	7179                	add	sp,sp,-48
    8000535e:	f406                	sd	ra,40(sp)
    80005360:	f022                	sd	s0,32(sp)
    80005362:	ec26                	sd	s1,24(sp)
    80005364:	e84a                	sd	s2,16(sp)
    80005366:	1800                	add	s0,sp,48
    80005368:	892e                	mv	s2,a1
    8000536a:	84b2                	mv	s1,a2
    8000536c:	fdc40593          	add	a1,s0,-36
    80005370:	ffffe097          	auipc	ra,0xffffe
    80005374:	956080e7          	jalr	-1706(ra) # 80002cc6 <argint>
    80005378:	04054063          	bltz	a0,800053b8 <argfd+0x5c>
    8000537c:	fdc42703          	lw	a4,-36(s0)
    80005380:	47bd                	li	a5,15
    80005382:	02e7ed63          	bltu	a5,a4,800053bc <argfd+0x60>
    80005386:	ffffc097          	auipc	ra,0xffffc
    8000538a:	69e080e7          	jalr	1694(ra) # 80001a24 <myproc>
    8000538e:	fdc42703          	lw	a4,-36(s0)
    80005392:	02070793          	add	a5,a4,32
    80005396:	078e                	sll	a5,a5,0x3
    80005398:	953e                	add	a0,a0,a5
    8000539a:	611c                	ld	a5,0(a0)
    8000539c:	c395                	beqz	a5,800053c0 <argfd+0x64>
    8000539e:	00090463          	beqz	s2,800053a6 <argfd+0x4a>
    800053a2:	00e92023          	sw	a4,0(s2)
    800053a6:	4501                	li	a0,0
    800053a8:	c091                	beqz	s1,800053ac <argfd+0x50>
    800053aa:	e09c                	sd	a5,0(s1)
    800053ac:	70a2                	ld	ra,40(sp)
    800053ae:	7402                	ld	s0,32(sp)
    800053b0:	64e2                	ld	s1,24(sp)
    800053b2:	6942                	ld	s2,16(sp)
    800053b4:	6145                	add	sp,sp,48
    800053b6:	8082                	ret
    800053b8:	557d                	li	a0,-1
    800053ba:	bfcd                	j	800053ac <argfd+0x50>
    800053bc:	557d                	li	a0,-1
    800053be:	b7fd                	j	800053ac <argfd+0x50>
    800053c0:	557d                	li	a0,-1
    800053c2:	b7ed                	j	800053ac <argfd+0x50>

00000000800053c4 <fdalloc>:
    800053c4:	1101                	add	sp,sp,-32
    800053c6:	ec06                	sd	ra,24(sp)
    800053c8:	e822                	sd	s0,16(sp)
    800053ca:	e426                	sd	s1,8(sp)
    800053cc:	1000                	add	s0,sp,32
    800053ce:	84aa                	mv	s1,a0
    800053d0:	ffffc097          	auipc	ra,0xffffc
    800053d4:	654080e7          	jalr	1620(ra) # 80001a24 <myproc>
    800053d8:	862a                	mv	a2,a0
    800053da:	10050793          	add	a5,a0,256
    800053de:	4501                	li	a0,0
    800053e0:	46c1                	li	a3,16
    800053e2:	6398                	ld	a4,0(a5)
    800053e4:	cb19                	beqz	a4,800053fa <fdalloc+0x36>
    800053e6:	2505                	addw	a0,a0,1
    800053e8:	07a1                	add	a5,a5,8
    800053ea:	fed51ce3          	bne	a0,a3,800053e2 <fdalloc+0x1e>
    800053ee:	557d                	li	a0,-1
    800053f0:	60e2                	ld	ra,24(sp)
    800053f2:	6442                	ld	s0,16(sp)
    800053f4:	64a2                	ld	s1,8(sp)
    800053f6:	6105                	add	sp,sp,32
    800053f8:	8082                	ret
    800053fa:	02050793          	add	a5,a0,32
    800053fe:	078e                	sll	a5,a5,0x3
    80005400:	963e                	add	a2,a2,a5
    80005402:	e204                	sd	s1,0(a2)
    80005404:	b7f5                	j	800053f0 <fdalloc+0x2c>

0000000080005406 <create>:
    80005406:	715d                	add	sp,sp,-80
    80005408:	e486                	sd	ra,72(sp)
    8000540a:	e0a2                	sd	s0,64(sp)
    8000540c:	fc26                	sd	s1,56(sp)
    8000540e:	f84a                	sd	s2,48(sp)
    80005410:	f44e                	sd	s3,40(sp)
    80005412:	f052                	sd	s4,32(sp)
    80005414:	ec56                	sd	s5,24(sp)
    80005416:	0880                	add	s0,sp,80
    80005418:	8aae                	mv	s5,a1
    8000541a:	8a32                	mv	s4,a2
    8000541c:	89b6                	mv	s3,a3
    8000541e:	fb040593          	add	a1,s0,-80
    80005422:	fffff097          	auipc	ra,0xfffff
    80005426:	e14080e7          	jalr	-492(ra) # 80004236 <nameiparent>
    8000542a:	892a                	mv	s2,a0
    8000542c:	12050c63          	beqz	a0,80005564 <create+0x15e>
    80005430:	ffffe097          	auipc	ra,0xffffe
    80005434:	616080e7          	jalr	1558(ra) # 80003a46 <ilock>
    80005438:	4601                	li	a2,0
    8000543a:	fb040593          	add	a1,s0,-80
    8000543e:	854a                	mv	a0,s2
    80005440:	fffff097          	auipc	ra,0xfffff
    80005444:	b06080e7          	jalr	-1274(ra) # 80003f46 <dirlookup>
    80005448:	84aa                	mv	s1,a0
    8000544a:	c539                	beqz	a0,80005498 <create+0x92>
    8000544c:	854a                	mv	a0,s2
    8000544e:	fffff097          	auipc	ra,0xfffff
    80005452:	85e080e7          	jalr	-1954(ra) # 80003cac <iunlockput>
    80005456:	8526                	mv	a0,s1
    80005458:	ffffe097          	auipc	ra,0xffffe
    8000545c:	5ee080e7          	jalr	1518(ra) # 80003a46 <ilock>
    80005460:	4789                	li	a5,2
    80005462:	02fa9463          	bne	s5,a5,8000548a <create+0x84>
    80005466:	0444d783          	lhu	a5,68(s1)
    8000546a:	37f9                	addw	a5,a5,-2
    8000546c:	17c2                	sll	a5,a5,0x30
    8000546e:	93c1                	srl	a5,a5,0x30
    80005470:	4705                	li	a4,1
    80005472:	00f76c63          	bltu	a4,a5,8000548a <create+0x84>
    80005476:	8526                	mv	a0,s1
    80005478:	60a6                	ld	ra,72(sp)
    8000547a:	6406                	ld	s0,64(sp)
    8000547c:	74e2                	ld	s1,56(sp)
    8000547e:	7942                	ld	s2,48(sp)
    80005480:	79a2                	ld	s3,40(sp)
    80005482:	7a02                	ld	s4,32(sp)
    80005484:	6ae2                	ld	s5,24(sp)
    80005486:	6161                	add	sp,sp,80
    80005488:	8082                	ret
    8000548a:	8526                	mv	a0,s1
    8000548c:	fffff097          	auipc	ra,0xfffff
    80005490:	820080e7          	jalr	-2016(ra) # 80003cac <iunlockput>
    80005494:	4481                	li	s1,0
    80005496:	b7c5                	j	80005476 <create+0x70>
    80005498:	85d6                	mv	a1,s5
    8000549a:	00092503          	lw	a0,0(s2)
    8000549e:	ffffe097          	auipc	ra,0xffffe
    800054a2:	414080e7          	jalr	1044(ra) # 800038b2 <ialloc>
    800054a6:	84aa                	mv	s1,a0
    800054a8:	c139                	beqz	a0,800054ee <create+0xe8>
    800054aa:	ffffe097          	auipc	ra,0xffffe
    800054ae:	59c080e7          	jalr	1436(ra) # 80003a46 <ilock>
    800054b2:	05449323          	sh	s4,70(s1)
    800054b6:	05349423          	sh	s3,72(s1)
    800054ba:	4985                	li	s3,1
    800054bc:	05349523          	sh	s3,74(s1)
    800054c0:	8526                	mv	a0,s1
    800054c2:	ffffe097          	auipc	ra,0xffffe
    800054c6:	4b8080e7          	jalr	1208(ra) # 8000397a <iupdate>
    800054ca:	033a8a63          	beq	s5,s3,800054fe <create+0xf8>
    800054ce:	40d0                	lw	a2,4(s1)
    800054d0:	fb040593          	add	a1,s0,-80
    800054d4:	854a                	mv	a0,s2
    800054d6:	fffff097          	auipc	ra,0xfffff
    800054da:	c80080e7          	jalr	-896(ra) # 80004156 <dirlink>
    800054de:	06054b63          	bltz	a0,80005554 <create+0x14e>
    800054e2:	854a                	mv	a0,s2
    800054e4:	ffffe097          	auipc	ra,0xffffe
    800054e8:	7c8080e7          	jalr	1992(ra) # 80003cac <iunlockput>
    800054ec:	b769                	j	80005476 <create+0x70>
    800054ee:	00003517          	auipc	a0,0x3
    800054f2:	0e250513          	add	a0,a0,226 # 800085d0 <etext+0x5d0>
    800054f6:	ffffb097          	auipc	ra,0xffffb
    800054fa:	064080e7          	jalr	100(ra) # 8000055a <panic>
    800054fe:	04a95783          	lhu	a5,74(s2)
    80005502:	2785                	addw	a5,a5,1
    80005504:	04f91523          	sh	a5,74(s2)
    80005508:	854a                	mv	a0,s2
    8000550a:	ffffe097          	auipc	ra,0xffffe
    8000550e:	470080e7          	jalr	1136(ra) # 8000397a <iupdate>
    80005512:	40d0                	lw	a2,4(s1)
    80005514:	00003597          	auipc	a1,0x3
    80005518:	0cc58593          	add	a1,a1,204 # 800085e0 <etext+0x5e0>
    8000551c:	8526                	mv	a0,s1
    8000551e:	fffff097          	auipc	ra,0xfffff
    80005522:	c38080e7          	jalr	-968(ra) # 80004156 <dirlink>
    80005526:	00054f63          	bltz	a0,80005544 <create+0x13e>
    8000552a:	00492603          	lw	a2,4(s2)
    8000552e:	00003597          	auipc	a1,0x3
    80005532:	0ba58593          	add	a1,a1,186 # 800085e8 <etext+0x5e8>
    80005536:	8526                	mv	a0,s1
    80005538:	fffff097          	auipc	ra,0xfffff
    8000553c:	c1e080e7          	jalr	-994(ra) # 80004156 <dirlink>
    80005540:	f80557e3          	bgez	a0,800054ce <create+0xc8>
    80005544:	00003517          	auipc	a0,0x3
    80005548:	0ac50513          	add	a0,a0,172 # 800085f0 <etext+0x5f0>
    8000554c:	ffffb097          	auipc	ra,0xffffb
    80005550:	00e080e7          	jalr	14(ra) # 8000055a <panic>
    80005554:	00003517          	auipc	a0,0x3
    80005558:	0ac50513          	add	a0,a0,172 # 80008600 <etext+0x600>
    8000555c:	ffffb097          	auipc	ra,0xffffb
    80005560:	ffe080e7          	jalr	-2(ra) # 8000055a <panic>
    80005564:	84aa                	mv	s1,a0
    80005566:	bf01                	j	80005476 <create+0x70>

0000000080005568 <sys_dup>:
    80005568:	7179                	add	sp,sp,-48
    8000556a:	f406                	sd	ra,40(sp)
    8000556c:	f022                	sd	s0,32(sp)
    8000556e:	1800                	add	s0,sp,48
    80005570:	fd840613          	add	a2,s0,-40
    80005574:	4581                	li	a1,0
    80005576:	4501                	li	a0,0
    80005578:	00000097          	auipc	ra,0x0
    8000557c:	de4080e7          	jalr	-540(ra) # 8000535c <argfd>
    80005580:	57fd                	li	a5,-1
    80005582:	02054763          	bltz	a0,800055b0 <sys_dup+0x48>
    80005586:	ec26                	sd	s1,24(sp)
    80005588:	e84a                	sd	s2,16(sp)
    8000558a:	fd843903          	ld	s2,-40(s0)
    8000558e:	854a                	mv	a0,s2
    80005590:	00000097          	auipc	ra,0x0
    80005594:	e34080e7          	jalr	-460(ra) # 800053c4 <fdalloc>
    80005598:	84aa                	mv	s1,a0
    8000559a:	57fd                	li	a5,-1
    8000559c:	00054f63          	bltz	a0,800055ba <sys_dup+0x52>
    800055a0:	854a                	mv	a0,s2
    800055a2:	fffff097          	auipc	ra,0xfffff
    800055a6:	2ee080e7          	jalr	750(ra) # 80004890 <filedup>
    800055aa:	87a6                	mv	a5,s1
    800055ac:	64e2                	ld	s1,24(sp)
    800055ae:	6942                	ld	s2,16(sp)
    800055b0:	853e                	mv	a0,a5
    800055b2:	70a2                	ld	ra,40(sp)
    800055b4:	7402                	ld	s0,32(sp)
    800055b6:	6145                	add	sp,sp,48
    800055b8:	8082                	ret
    800055ba:	64e2                	ld	s1,24(sp)
    800055bc:	6942                	ld	s2,16(sp)
    800055be:	bfcd                	j	800055b0 <sys_dup+0x48>

00000000800055c0 <sys_read>:
    800055c0:	7179                	add	sp,sp,-48
    800055c2:	f406                	sd	ra,40(sp)
    800055c4:	f022                	sd	s0,32(sp)
    800055c6:	1800                	add	s0,sp,48
    800055c8:	fe840613          	add	a2,s0,-24
    800055cc:	4581                	li	a1,0
    800055ce:	4501                	li	a0,0
    800055d0:	00000097          	auipc	ra,0x0
    800055d4:	d8c080e7          	jalr	-628(ra) # 8000535c <argfd>
    800055d8:	57fd                	li	a5,-1
    800055da:	04054163          	bltz	a0,8000561c <sys_read+0x5c>
    800055de:	fe440593          	add	a1,s0,-28
    800055e2:	4509                	li	a0,2
    800055e4:	ffffd097          	auipc	ra,0xffffd
    800055e8:	6e2080e7          	jalr	1762(ra) # 80002cc6 <argint>
    800055ec:	57fd                	li	a5,-1
    800055ee:	02054763          	bltz	a0,8000561c <sys_read+0x5c>
    800055f2:	fd840593          	add	a1,s0,-40
    800055f6:	4505                	li	a0,1
    800055f8:	ffffd097          	auipc	ra,0xffffd
    800055fc:	6f0080e7          	jalr	1776(ra) # 80002ce8 <argaddr>
    80005600:	57fd                	li	a5,-1
    80005602:	00054d63          	bltz	a0,8000561c <sys_read+0x5c>
    80005606:	fe442603          	lw	a2,-28(s0)
    8000560a:	fd843583          	ld	a1,-40(s0)
    8000560e:	fe843503          	ld	a0,-24(s0)
    80005612:	fffff097          	auipc	ra,0xfffff
    80005616:	424080e7          	jalr	1060(ra) # 80004a36 <fileread>
    8000561a:	87aa                	mv	a5,a0
    8000561c:	853e                	mv	a0,a5
    8000561e:	70a2                	ld	ra,40(sp)
    80005620:	7402                	ld	s0,32(sp)
    80005622:	6145                	add	sp,sp,48
    80005624:	8082                	ret

0000000080005626 <sys_write>:
    80005626:	7179                	add	sp,sp,-48
    80005628:	f406                	sd	ra,40(sp)
    8000562a:	f022                	sd	s0,32(sp)
    8000562c:	1800                	add	s0,sp,48
    8000562e:	fe840613          	add	a2,s0,-24
    80005632:	4581                	li	a1,0
    80005634:	4501                	li	a0,0
    80005636:	00000097          	auipc	ra,0x0
    8000563a:	d26080e7          	jalr	-730(ra) # 8000535c <argfd>
    8000563e:	57fd                	li	a5,-1
    80005640:	04054163          	bltz	a0,80005682 <sys_write+0x5c>
    80005644:	fe440593          	add	a1,s0,-28
    80005648:	4509                	li	a0,2
    8000564a:	ffffd097          	auipc	ra,0xffffd
    8000564e:	67c080e7          	jalr	1660(ra) # 80002cc6 <argint>
    80005652:	57fd                	li	a5,-1
    80005654:	02054763          	bltz	a0,80005682 <sys_write+0x5c>
    80005658:	fd840593          	add	a1,s0,-40
    8000565c:	4505                	li	a0,1
    8000565e:	ffffd097          	auipc	ra,0xffffd
    80005662:	68a080e7          	jalr	1674(ra) # 80002ce8 <argaddr>
    80005666:	57fd                	li	a5,-1
    80005668:	00054d63          	bltz	a0,80005682 <sys_write+0x5c>
    8000566c:	fe442603          	lw	a2,-28(s0)
    80005670:	fd843583          	ld	a1,-40(s0)
    80005674:	fe843503          	ld	a0,-24(s0)
    80005678:	fffff097          	auipc	ra,0xfffff
    8000567c:	490080e7          	jalr	1168(ra) # 80004b08 <filewrite>
    80005680:	87aa                	mv	a5,a0
    80005682:	853e                	mv	a0,a5
    80005684:	70a2                	ld	ra,40(sp)
    80005686:	7402                	ld	s0,32(sp)
    80005688:	6145                	add	sp,sp,48
    8000568a:	8082                	ret

000000008000568c <sys_close>:
    8000568c:	1101                	add	sp,sp,-32
    8000568e:	ec06                	sd	ra,24(sp)
    80005690:	e822                	sd	s0,16(sp)
    80005692:	1000                	add	s0,sp,32
    80005694:	fe040613          	add	a2,s0,-32
    80005698:	fec40593          	add	a1,s0,-20
    8000569c:	4501                	li	a0,0
    8000569e:	00000097          	auipc	ra,0x0
    800056a2:	cbe080e7          	jalr	-834(ra) # 8000535c <argfd>
    800056a6:	57fd                	li	a5,-1
    800056a8:	02054563          	bltz	a0,800056d2 <sys_close+0x46>
    800056ac:	ffffc097          	auipc	ra,0xffffc
    800056b0:	378080e7          	jalr	888(ra) # 80001a24 <myproc>
    800056b4:	fec42783          	lw	a5,-20(s0)
    800056b8:	02078793          	add	a5,a5,32
    800056bc:	078e                	sll	a5,a5,0x3
    800056be:	953e                	add	a0,a0,a5
    800056c0:	00053023          	sd	zero,0(a0)
    800056c4:	fe043503          	ld	a0,-32(s0)
    800056c8:	fffff097          	auipc	ra,0xfffff
    800056cc:	21a080e7          	jalr	538(ra) # 800048e2 <fileclose>
    800056d0:	4781                	li	a5,0
    800056d2:	853e                	mv	a0,a5
    800056d4:	60e2                	ld	ra,24(sp)
    800056d6:	6442                	ld	s0,16(sp)
    800056d8:	6105                	add	sp,sp,32
    800056da:	8082                	ret

00000000800056dc <sys_fstat>:
    800056dc:	1101                	add	sp,sp,-32
    800056de:	ec06                	sd	ra,24(sp)
    800056e0:	e822                	sd	s0,16(sp)
    800056e2:	1000                	add	s0,sp,32
    800056e4:	fe840613          	add	a2,s0,-24
    800056e8:	4581                	li	a1,0
    800056ea:	4501                	li	a0,0
    800056ec:	00000097          	auipc	ra,0x0
    800056f0:	c70080e7          	jalr	-912(ra) # 8000535c <argfd>
    800056f4:	57fd                	li	a5,-1
    800056f6:	02054563          	bltz	a0,80005720 <sys_fstat+0x44>
    800056fa:	fe040593          	add	a1,s0,-32
    800056fe:	4505                	li	a0,1
    80005700:	ffffd097          	auipc	ra,0xffffd
    80005704:	5e8080e7          	jalr	1512(ra) # 80002ce8 <argaddr>
    80005708:	57fd                	li	a5,-1
    8000570a:	00054b63          	bltz	a0,80005720 <sys_fstat+0x44>
    8000570e:	fe043583          	ld	a1,-32(s0)
    80005712:	fe843503          	ld	a0,-24(s0)
    80005716:	fffff097          	auipc	ra,0xfffff
    8000571a:	2ae080e7          	jalr	686(ra) # 800049c4 <filestat>
    8000571e:	87aa                	mv	a5,a0
    80005720:	853e                	mv	a0,a5
    80005722:	60e2                	ld	ra,24(sp)
    80005724:	6442                	ld	s0,16(sp)
    80005726:	6105                	add	sp,sp,32
    80005728:	8082                	ret

000000008000572a <sys_link>:
    8000572a:	7169                	add	sp,sp,-304
    8000572c:	f606                	sd	ra,296(sp)
    8000572e:	f222                	sd	s0,288(sp)
    80005730:	1a00                	add	s0,sp,304
    80005732:	08000613          	li	a2,128
    80005736:	ed040593          	add	a1,s0,-304
    8000573a:	4501                	li	a0,0
    8000573c:	ffffd097          	auipc	ra,0xffffd
    80005740:	5ce080e7          	jalr	1486(ra) # 80002d0a <argstr>
    80005744:	57fd                	li	a5,-1
    80005746:	12054663          	bltz	a0,80005872 <sys_link+0x148>
    8000574a:	08000613          	li	a2,128
    8000574e:	f5040593          	add	a1,s0,-176
    80005752:	4505                	li	a0,1
    80005754:	ffffd097          	auipc	ra,0xffffd
    80005758:	5b6080e7          	jalr	1462(ra) # 80002d0a <argstr>
    8000575c:	57fd                	li	a5,-1
    8000575e:	10054a63          	bltz	a0,80005872 <sys_link+0x148>
    80005762:	ee26                	sd	s1,280(sp)
    80005764:	fffff097          	auipc	ra,0xfffff
    80005768:	cb4080e7          	jalr	-844(ra) # 80004418 <begin_op>
    8000576c:	ed040513          	add	a0,s0,-304
    80005770:	fffff097          	auipc	ra,0xfffff
    80005774:	aa8080e7          	jalr	-1368(ra) # 80004218 <namei>
    80005778:	84aa                	mv	s1,a0
    8000577a:	c949                	beqz	a0,8000580c <sys_link+0xe2>
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	2ca080e7          	jalr	714(ra) # 80003a46 <ilock>
    80005784:	04449703          	lh	a4,68(s1)
    80005788:	4785                	li	a5,1
    8000578a:	08f70863          	beq	a4,a5,8000581a <sys_link+0xf0>
    8000578e:	ea4a                	sd	s2,272(sp)
    80005790:	04a4d783          	lhu	a5,74(s1)
    80005794:	2785                	addw	a5,a5,1
    80005796:	04f49523          	sh	a5,74(s1)
    8000579a:	8526                	mv	a0,s1
    8000579c:	ffffe097          	auipc	ra,0xffffe
    800057a0:	1de080e7          	jalr	478(ra) # 8000397a <iupdate>
    800057a4:	8526                	mv	a0,s1
    800057a6:	ffffe097          	auipc	ra,0xffffe
    800057aa:	366080e7          	jalr	870(ra) # 80003b0c <iunlock>
    800057ae:	fd040593          	add	a1,s0,-48
    800057b2:	f5040513          	add	a0,s0,-176
    800057b6:	fffff097          	auipc	ra,0xfffff
    800057ba:	a80080e7          	jalr	-1408(ra) # 80004236 <nameiparent>
    800057be:	892a                	mv	s2,a0
    800057c0:	cd35                	beqz	a0,8000583c <sys_link+0x112>
    800057c2:	ffffe097          	auipc	ra,0xffffe
    800057c6:	284080e7          	jalr	644(ra) # 80003a46 <ilock>
    800057ca:	00092703          	lw	a4,0(s2)
    800057ce:	409c                	lw	a5,0(s1)
    800057d0:	06f71163          	bne	a4,a5,80005832 <sys_link+0x108>
    800057d4:	40d0                	lw	a2,4(s1)
    800057d6:	fd040593          	add	a1,s0,-48
    800057da:	854a                	mv	a0,s2
    800057dc:	fffff097          	auipc	ra,0xfffff
    800057e0:	97a080e7          	jalr	-1670(ra) # 80004156 <dirlink>
    800057e4:	04054763          	bltz	a0,80005832 <sys_link+0x108>
    800057e8:	854a                	mv	a0,s2
    800057ea:	ffffe097          	auipc	ra,0xffffe
    800057ee:	4c2080e7          	jalr	1218(ra) # 80003cac <iunlockput>
    800057f2:	8526                	mv	a0,s1
    800057f4:	ffffe097          	auipc	ra,0xffffe
    800057f8:	410080e7          	jalr	1040(ra) # 80003c04 <iput>
    800057fc:	fffff097          	auipc	ra,0xfffff
    80005800:	c96080e7          	jalr	-874(ra) # 80004492 <end_op>
    80005804:	4781                	li	a5,0
    80005806:	64f2                	ld	s1,280(sp)
    80005808:	6952                	ld	s2,272(sp)
    8000580a:	a0a5                	j	80005872 <sys_link+0x148>
    8000580c:	fffff097          	auipc	ra,0xfffff
    80005810:	c86080e7          	jalr	-890(ra) # 80004492 <end_op>
    80005814:	57fd                	li	a5,-1
    80005816:	64f2                	ld	s1,280(sp)
    80005818:	a8a9                	j	80005872 <sys_link+0x148>
    8000581a:	8526                	mv	a0,s1
    8000581c:	ffffe097          	auipc	ra,0xffffe
    80005820:	490080e7          	jalr	1168(ra) # 80003cac <iunlockput>
    80005824:	fffff097          	auipc	ra,0xfffff
    80005828:	c6e080e7          	jalr	-914(ra) # 80004492 <end_op>
    8000582c:	57fd                	li	a5,-1
    8000582e:	64f2                	ld	s1,280(sp)
    80005830:	a089                	j	80005872 <sys_link+0x148>
    80005832:	854a                	mv	a0,s2
    80005834:	ffffe097          	auipc	ra,0xffffe
    80005838:	478080e7          	jalr	1144(ra) # 80003cac <iunlockput>
    8000583c:	8526                	mv	a0,s1
    8000583e:	ffffe097          	auipc	ra,0xffffe
    80005842:	208080e7          	jalr	520(ra) # 80003a46 <ilock>
    80005846:	04a4d783          	lhu	a5,74(s1)
    8000584a:	37fd                	addw	a5,a5,-1
    8000584c:	04f49523          	sh	a5,74(s1)
    80005850:	8526                	mv	a0,s1
    80005852:	ffffe097          	auipc	ra,0xffffe
    80005856:	128080e7          	jalr	296(ra) # 8000397a <iupdate>
    8000585a:	8526                	mv	a0,s1
    8000585c:	ffffe097          	auipc	ra,0xffffe
    80005860:	450080e7          	jalr	1104(ra) # 80003cac <iunlockput>
    80005864:	fffff097          	auipc	ra,0xfffff
    80005868:	c2e080e7          	jalr	-978(ra) # 80004492 <end_op>
    8000586c:	57fd                	li	a5,-1
    8000586e:	64f2                	ld	s1,280(sp)
    80005870:	6952                	ld	s2,272(sp)
    80005872:	853e                	mv	a0,a5
    80005874:	70b2                	ld	ra,296(sp)
    80005876:	7412                	ld	s0,288(sp)
    80005878:	6155                	add	sp,sp,304
    8000587a:	8082                	ret

000000008000587c <sys_unlink>:
    8000587c:	7151                	add	sp,sp,-240
    8000587e:	f586                	sd	ra,232(sp)
    80005880:	f1a2                	sd	s0,224(sp)
    80005882:	1980                	add	s0,sp,240
    80005884:	08000613          	li	a2,128
    80005888:	f3040593          	add	a1,s0,-208
    8000588c:	4501                	li	a0,0
    8000588e:	ffffd097          	auipc	ra,0xffffd
    80005892:	47c080e7          	jalr	1148(ra) # 80002d0a <argstr>
    80005896:	1a054a63          	bltz	a0,80005a4a <sys_unlink+0x1ce>
    8000589a:	eda6                	sd	s1,216(sp)
    8000589c:	fffff097          	auipc	ra,0xfffff
    800058a0:	b7c080e7          	jalr	-1156(ra) # 80004418 <begin_op>
    800058a4:	fb040593          	add	a1,s0,-80
    800058a8:	f3040513          	add	a0,s0,-208
    800058ac:	fffff097          	auipc	ra,0xfffff
    800058b0:	98a080e7          	jalr	-1654(ra) # 80004236 <nameiparent>
    800058b4:	84aa                	mv	s1,a0
    800058b6:	cd71                	beqz	a0,80005992 <sys_unlink+0x116>
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	18e080e7          	jalr	398(ra) # 80003a46 <ilock>
    800058c0:	00003597          	auipc	a1,0x3
    800058c4:	d2058593          	add	a1,a1,-736 # 800085e0 <etext+0x5e0>
    800058c8:	fb040513          	add	a0,s0,-80
    800058cc:	ffffe097          	auipc	ra,0xffffe
    800058d0:	660080e7          	jalr	1632(ra) # 80003f2c <namecmp>
    800058d4:	14050c63          	beqz	a0,80005a2c <sys_unlink+0x1b0>
    800058d8:	00003597          	auipc	a1,0x3
    800058dc:	d1058593          	add	a1,a1,-752 # 800085e8 <etext+0x5e8>
    800058e0:	fb040513          	add	a0,s0,-80
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	648080e7          	jalr	1608(ra) # 80003f2c <namecmp>
    800058ec:	14050063          	beqz	a0,80005a2c <sys_unlink+0x1b0>
    800058f0:	e9ca                	sd	s2,208(sp)
    800058f2:	f2c40613          	add	a2,s0,-212
    800058f6:	fb040593          	add	a1,s0,-80
    800058fa:	8526                	mv	a0,s1
    800058fc:	ffffe097          	auipc	ra,0xffffe
    80005900:	64a080e7          	jalr	1610(ra) # 80003f46 <dirlookup>
    80005904:	892a                	mv	s2,a0
    80005906:	12050263          	beqz	a0,80005a2a <sys_unlink+0x1ae>
    8000590a:	ffffe097          	auipc	ra,0xffffe
    8000590e:	13c080e7          	jalr	316(ra) # 80003a46 <ilock>
    80005912:	04a91783          	lh	a5,74(s2)
    80005916:	08f05563          	blez	a5,800059a0 <sys_unlink+0x124>
    8000591a:	04491703          	lh	a4,68(s2)
    8000591e:	4785                	li	a5,1
    80005920:	08f70963          	beq	a4,a5,800059b2 <sys_unlink+0x136>
    80005924:	4641                	li	a2,16
    80005926:	4581                	li	a1,0
    80005928:	fc040513          	add	a0,s0,-64
    8000592c:	ffffb097          	auipc	ra,0xffffb
    80005930:	402080e7          	jalr	1026(ra) # 80000d2e <memset>
    80005934:	4741                	li	a4,16
    80005936:	f2c42683          	lw	a3,-212(s0)
    8000593a:	fc040613          	add	a2,s0,-64
    8000593e:	4581                	li	a1,0
    80005940:	8526                	mv	a0,s1
    80005942:	ffffe097          	auipc	ra,0xffffe
    80005946:	4c0080e7          	jalr	1216(ra) # 80003e02 <writei>
    8000594a:	47c1                	li	a5,16
    8000594c:	0af51b63          	bne	a0,a5,80005a02 <sys_unlink+0x186>
    80005950:	04491703          	lh	a4,68(s2)
    80005954:	4785                	li	a5,1
    80005956:	0af70f63          	beq	a4,a5,80005a14 <sys_unlink+0x198>
    8000595a:	8526                	mv	a0,s1
    8000595c:	ffffe097          	auipc	ra,0xffffe
    80005960:	350080e7          	jalr	848(ra) # 80003cac <iunlockput>
    80005964:	04a95783          	lhu	a5,74(s2)
    80005968:	37fd                	addw	a5,a5,-1
    8000596a:	04f91523          	sh	a5,74(s2)
    8000596e:	854a                	mv	a0,s2
    80005970:	ffffe097          	auipc	ra,0xffffe
    80005974:	00a080e7          	jalr	10(ra) # 8000397a <iupdate>
    80005978:	854a                	mv	a0,s2
    8000597a:	ffffe097          	auipc	ra,0xffffe
    8000597e:	332080e7          	jalr	818(ra) # 80003cac <iunlockput>
    80005982:	fffff097          	auipc	ra,0xfffff
    80005986:	b10080e7          	jalr	-1264(ra) # 80004492 <end_op>
    8000598a:	4501                	li	a0,0
    8000598c:	64ee                	ld	s1,216(sp)
    8000598e:	694e                	ld	s2,208(sp)
    80005990:	a84d                	j	80005a42 <sys_unlink+0x1c6>
    80005992:	fffff097          	auipc	ra,0xfffff
    80005996:	b00080e7          	jalr	-1280(ra) # 80004492 <end_op>
    8000599a:	557d                	li	a0,-1
    8000599c:	64ee                	ld	s1,216(sp)
    8000599e:	a055                	j	80005a42 <sys_unlink+0x1c6>
    800059a0:	e5ce                	sd	s3,200(sp)
    800059a2:	00003517          	auipc	a0,0x3
    800059a6:	c6e50513          	add	a0,a0,-914 # 80008610 <etext+0x610>
    800059aa:	ffffb097          	auipc	ra,0xffffb
    800059ae:	bb0080e7          	jalr	-1104(ra) # 8000055a <panic>
    800059b2:	04c92703          	lw	a4,76(s2)
    800059b6:	02000793          	li	a5,32
    800059ba:	f6e7f5e3          	bgeu	a5,a4,80005924 <sys_unlink+0xa8>
    800059be:	e5ce                	sd	s3,200(sp)
    800059c0:	02000993          	li	s3,32
    800059c4:	4741                	li	a4,16
    800059c6:	86ce                	mv	a3,s3
    800059c8:	f1840613          	add	a2,s0,-232
    800059cc:	4581                	li	a1,0
    800059ce:	854a                	mv	a0,s2
    800059d0:	ffffe097          	auipc	ra,0xffffe
    800059d4:	32e080e7          	jalr	814(ra) # 80003cfe <readi>
    800059d8:	47c1                	li	a5,16
    800059da:	00f51c63          	bne	a0,a5,800059f2 <sys_unlink+0x176>
    800059de:	f1845783          	lhu	a5,-232(s0)
    800059e2:	e7b5                	bnez	a5,80005a4e <sys_unlink+0x1d2>
    800059e4:	29c1                	addw	s3,s3,16
    800059e6:	04c92783          	lw	a5,76(s2)
    800059ea:	fcf9ede3          	bltu	s3,a5,800059c4 <sys_unlink+0x148>
    800059ee:	69ae                	ld	s3,200(sp)
    800059f0:	bf15                	j	80005924 <sys_unlink+0xa8>
    800059f2:	00003517          	auipc	a0,0x3
    800059f6:	c3650513          	add	a0,a0,-970 # 80008628 <etext+0x628>
    800059fa:	ffffb097          	auipc	ra,0xffffb
    800059fe:	b60080e7          	jalr	-1184(ra) # 8000055a <panic>
    80005a02:	e5ce                	sd	s3,200(sp)
    80005a04:	00003517          	auipc	a0,0x3
    80005a08:	c3c50513          	add	a0,a0,-964 # 80008640 <etext+0x640>
    80005a0c:	ffffb097          	auipc	ra,0xffffb
    80005a10:	b4e080e7          	jalr	-1202(ra) # 8000055a <panic>
    80005a14:	04a4d783          	lhu	a5,74(s1)
    80005a18:	37fd                	addw	a5,a5,-1
    80005a1a:	04f49523          	sh	a5,74(s1)
    80005a1e:	8526                	mv	a0,s1
    80005a20:	ffffe097          	auipc	ra,0xffffe
    80005a24:	f5a080e7          	jalr	-166(ra) # 8000397a <iupdate>
    80005a28:	bf0d                	j	8000595a <sys_unlink+0xde>
    80005a2a:	694e                	ld	s2,208(sp)
    80005a2c:	8526                	mv	a0,s1
    80005a2e:	ffffe097          	auipc	ra,0xffffe
    80005a32:	27e080e7          	jalr	638(ra) # 80003cac <iunlockput>
    80005a36:	fffff097          	auipc	ra,0xfffff
    80005a3a:	a5c080e7          	jalr	-1444(ra) # 80004492 <end_op>
    80005a3e:	557d                	li	a0,-1
    80005a40:	64ee                	ld	s1,216(sp)
    80005a42:	70ae                	ld	ra,232(sp)
    80005a44:	740e                	ld	s0,224(sp)
    80005a46:	616d                	add	sp,sp,240
    80005a48:	8082                	ret
    80005a4a:	557d                	li	a0,-1
    80005a4c:	bfdd                	j	80005a42 <sys_unlink+0x1c6>
    80005a4e:	854a                	mv	a0,s2
    80005a50:	ffffe097          	auipc	ra,0xffffe
    80005a54:	25c080e7          	jalr	604(ra) # 80003cac <iunlockput>
    80005a58:	694e                	ld	s2,208(sp)
    80005a5a:	69ae                	ld	s3,200(sp)
    80005a5c:	bfc1                	j	80005a2c <sys_unlink+0x1b0>

0000000080005a5e <sys_open>:
    80005a5e:	7131                	add	sp,sp,-192
    80005a60:	fd06                	sd	ra,184(sp)
    80005a62:	f922                	sd	s0,176(sp)
    80005a64:	f526                	sd	s1,168(sp)
    80005a66:	0180                	add	s0,sp,192
    80005a68:	08000613          	li	a2,128
    80005a6c:	f5040593          	add	a1,s0,-176
    80005a70:	4501                	li	a0,0
    80005a72:	ffffd097          	auipc	ra,0xffffd
    80005a76:	298080e7          	jalr	664(ra) # 80002d0a <argstr>
    80005a7a:	54fd                	li	s1,-1
    80005a7c:	0c054463          	bltz	a0,80005b44 <sys_open+0xe6>
    80005a80:	f4c40593          	add	a1,s0,-180
    80005a84:	4505                	li	a0,1
    80005a86:	ffffd097          	auipc	ra,0xffffd
    80005a8a:	240080e7          	jalr	576(ra) # 80002cc6 <argint>
    80005a8e:	0a054b63          	bltz	a0,80005b44 <sys_open+0xe6>
    80005a92:	f14a                	sd	s2,160(sp)
    80005a94:	fffff097          	auipc	ra,0xfffff
    80005a98:	984080e7          	jalr	-1660(ra) # 80004418 <begin_op>
    80005a9c:	f4c42783          	lw	a5,-180(s0)
    80005aa0:	2007f793          	and	a5,a5,512
    80005aa4:	cfc5                	beqz	a5,80005b5c <sys_open+0xfe>
    80005aa6:	4681                	li	a3,0
    80005aa8:	4601                	li	a2,0
    80005aaa:	4589                	li	a1,2
    80005aac:	f5040513          	add	a0,s0,-176
    80005ab0:	00000097          	auipc	ra,0x0
    80005ab4:	956080e7          	jalr	-1706(ra) # 80005406 <create>
    80005ab8:	892a                	mv	s2,a0
    80005aba:	c959                	beqz	a0,80005b50 <sys_open+0xf2>
    80005abc:	04491703          	lh	a4,68(s2)
    80005ac0:	478d                	li	a5,3
    80005ac2:	00f71763          	bne	a4,a5,80005ad0 <sys_open+0x72>
    80005ac6:	04695703          	lhu	a4,70(s2)
    80005aca:	47a5                	li	a5,9
    80005acc:	0ce7ef63          	bltu	a5,a4,80005baa <sys_open+0x14c>
    80005ad0:	ed4e                	sd	s3,152(sp)
    80005ad2:	fffff097          	auipc	ra,0xfffff
    80005ad6:	d54080e7          	jalr	-684(ra) # 80004826 <filealloc>
    80005ada:	89aa                	mv	s3,a0
    80005adc:	c965                	beqz	a0,80005bcc <sys_open+0x16e>
    80005ade:	00000097          	auipc	ra,0x0
    80005ae2:	8e6080e7          	jalr	-1818(ra) # 800053c4 <fdalloc>
    80005ae6:	84aa                	mv	s1,a0
    80005ae8:	0c054d63          	bltz	a0,80005bc2 <sys_open+0x164>
    80005aec:	04491703          	lh	a4,68(s2)
    80005af0:	478d                	li	a5,3
    80005af2:	0ef70a63          	beq	a4,a5,80005be6 <sys_open+0x188>
    80005af6:	4789                	li	a5,2
    80005af8:	00f9a023          	sw	a5,0(s3)
    80005afc:	0209a023          	sw	zero,32(s3)
    80005b00:	0129bc23          	sd	s2,24(s3)
    80005b04:	f4c42783          	lw	a5,-180(s0)
    80005b08:	0017c713          	xor	a4,a5,1
    80005b0c:	8b05                	and	a4,a4,1
    80005b0e:	00e98423          	sb	a4,8(s3)
    80005b12:	0037f713          	and	a4,a5,3
    80005b16:	00e03733          	snez	a4,a4
    80005b1a:	00e984a3          	sb	a4,9(s3)
    80005b1e:	4007f793          	and	a5,a5,1024
    80005b22:	c791                	beqz	a5,80005b2e <sys_open+0xd0>
    80005b24:	04491703          	lh	a4,68(s2)
    80005b28:	4789                	li	a5,2
    80005b2a:	0cf70563          	beq	a4,a5,80005bf4 <sys_open+0x196>
    80005b2e:	854a                	mv	a0,s2
    80005b30:	ffffe097          	auipc	ra,0xffffe
    80005b34:	fdc080e7          	jalr	-36(ra) # 80003b0c <iunlock>
    80005b38:	fffff097          	auipc	ra,0xfffff
    80005b3c:	95a080e7          	jalr	-1702(ra) # 80004492 <end_op>
    80005b40:	790a                	ld	s2,160(sp)
    80005b42:	69ea                	ld	s3,152(sp)
    80005b44:	8526                	mv	a0,s1
    80005b46:	70ea                	ld	ra,184(sp)
    80005b48:	744a                	ld	s0,176(sp)
    80005b4a:	74aa                	ld	s1,168(sp)
    80005b4c:	6129                	add	sp,sp,192
    80005b4e:	8082                	ret
    80005b50:	fffff097          	auipc	ra,0xfffff
    80005b54:	942080e7          	jalr	-1726(ra) # 80004492 <end_op>
    80005b58:	790a                	ld	s2,160(sp)
    80005b5a:	b7ed                	j	80005b44 <sys_open+0xe6>
    80005b5c:	f5040513          	add	a0,s0,-176
    80005b60:	ffffe097          	auipc	ra,0xffffe
    80005b64:	6b8080e7          	jalr	1720(ra) # 80004218 <namei>
    80005b68:	892a                	mv	s2,a0
    80005b6a:	c90d                	beqz	a0,80005b9c <sys_open+0x13e>
    80005b6c:	ffffe097          	auipc	ra,0xffffe
    80005b70:	eda080e7          	jalr	-294(ra) # 80003a46 <ilock>
    80005b74:	04491703          	lh	a4,68(s2)
    80005b78:	4785                	li	a5,1
    80005b7a:	f4f711e3          	bne	a4,a5,80005abc <sys_open+0x5e>
    80005b7e:	f4c42783          	lw	a5,-180(s0)
    80005b82:	d7b9                	beqz	a5,80005ad0 <sys_open+0x72>
    80005b84:	854a                	mv	a0,s2
    80005b86:	ffffe097          	auipc	ra,0xffffe
    80005b8a:	126080e7          	jalr	294(ra) # 80003cac <iunlockput>
    80005b8e:	fffff097          	auipc	ra,0xfffff
    80005b92:	904080e7          	jalr	-1788(ra) # 80004492 <end_op>
    80005b96:	54fd                	li	s1,-1
    80005b98:	790a                	ld	s2,160(sp)
    80005b9a:	b76d                	j	80005b44 <sys_open+0xe6>
    80005b9c:	fffff097          	auipc	ra,0xfffff
    80005ba0:	8f6080e7          	jalr	-1802(ra) # 80004492 <end_op>
    80005ba4:	54fd                	li	s1,-1
    80005ba6:	790a                	ld	s2,160(sp)
    80005ba8:	bf71                	j	80005b44 <sys_open+0xe6>
    80005baa:	854a                	mv	a0,s2
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	100080e7          	jalr	256(ra) # 80003cac <iunlockput>
    80005bb4:	fffff097          	auipc	ra,0xfffff
    80005bb8:	8de080e7          	jalr	-1826(ra) # 80004492 <end_op>
    80005bbc:	54fd                	li	s1,-1
    80005bbe:	790a                	ld	s2,160(sp)
    80005bc0:	b751                	j	80005b44 <sys_open+0xe6>
    80005bc2:	854e                	mv	a0,s3
    80005bc4:	fffff097          	auipc	ra,0xfffff
    80005bc8:	d1e080e7          	jalr	-738(ra) # 800048e2 <fileclose>
    80005bcc:	854a                	mv	a0,s2
    80005bce:	ffffe097          	auipc	ra,0xffffe
    80005bd2:	0de080e7          	jalr	222(ra) # 80003cac <iunlockput>
    80005bd6:	fffff097          	auipc	ra,0xfffff
    80005bda:	8bc080e7          	jalr	-1860(ra) # 80004492 <end_op>
    80005bde:	54fd                	li	s1,-1
    80005be0:	790a                	ld	s2,160(sp)
    80005be2:	69ea                	ld	s3,152(sp)
    80005be4:	b785                	j	80005b44 <sys_open+0xe6>
    80005be6:	00f9a023          	sw	a5,0(s3)
    80005bea:	04691783          	lh	a5,70(s2)
    80005bee:	02f99223          	sh	a5,36(s3)
    80005bf2:	b739                	j	80005b00 <sys_open+0xa2>
    80005bf4:	854a                	mv	a0,s2
    80005bf6:	ffffe097          	auipc	ra,0xffffe
    80005bfa:	f62080e7          	jalr	-158(ra) # 80003b58 <itrunc>
    80005bfe:	bf05                	j	80005b2e <sys_open+0xd0>

0000000080005c00 <sys_mkdir>:
    80005c00:	7175                	add	sp,sp,-144
    80005c02:	e506                	sd	ra,136(sp)
    80005c04:	e122                	sd	s0,128(sp)
    80005c06:	0900                	add	s0,sp,144
    80005c08:	fffff097          	auipc	ra,0xfffff
    80005c0c:	810080e7          	jalr	-2032(ra) # 80004418 <begin_op>
    80005c10:	08000613          	li	a2,128
    80005c14:	f7040593          	add	a1,s0,-144
    80005c18:	4501                	li	a0,0
    80005c1a:	ffffd097          	auipc	ra,0xffffd
    80005c1e:	0f0080e7          	jalr	240(ra) # 80002d0a <argstr>
    80005c22:	02054963          	bltz	a0,80005c54 <sys_mkdir+0x54>
    80005c26:	4681                	li	a3,0
    80005c28:	4601                	li	a2,0
    80005c2a:	4585                	li	a1,1
    80005c2c:	f7040513          	add	a0,s0,-144
    80005c30:	fffff097          	auipc	ra,0xfffff
    80005c34:	7d6080e7          	jalr	2006(ra) # 80005406 <create>
    80005c38:	cd11                	beqz	a0,80005c54 <sys_mkdir+0x54>
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	072080e7          	jalr	114(ra) # 80003cac <iunlockput>
    80005c42:	fffff097          	auipc	ra,0xfffff
    80005c46:	850080e7          	jalr	-1968(ra) # 80004492 <end_op>
    80005c4a:	4501                	li	a0,0
    80005c4c:	60aa                	ld	ra,136(sp)
    80005c4e:	640a                	ld	s0,128(sp)
    80005c50:	6149                	add	sp,sp,144
    80005c52:	8082                	ret
    80005c54:	fffff097          	auipc	ra,0xfffff
    80005c58:	83e080e7          	jalr	-1986(ra) # 80004492 <end_op>
    80005c5c:	557d                	li	a0,-1
    80005c5e:	b7fd                	j	80005c4c <sys_mkdir+0x4c>

0000000080005c60 <sys_mknod>:
    80005c60:	7135                	add	sp,sp,-160
    80005c62:	ed06                	sd	ra,152(sp)
    80005c64:	e922                	sd	s0,144(sp)
    80005c66:	1100                	add	s0,sp,160
    80005c68:	ffffe097          	auipc	ra,0xffffe
    80005c6c:	7b0080e7          	jalr	1968(ra) # 80004418 <begin_op>
    80005c70:	08000613          	li	a2,128
    80005c74:	f7040593          	add	a1,s0,-144
    80005c78:	4501                	li	a0,0
    80005c7a:	ffffd097          	auipc	ra,0xffffd
    80005c7e:	090080e7          	jalr	144(ra) # 80002d0a <argstr>
    80005c82:	04054a63          	bltz	a0,80005cd6 <sys_mknod+0x76>
    80005c86:	f6c40593          	add	a1,s0,-148
    80005c8a:	4505                	li	a0,1
    80005c8c:	ffffd097          	auipc	ra,0xffffd
    80005c90:	03a080e7          	jalr	58(ra) # 80002cc6 <argint>
    80005c94:	04054163          	bltz	a0,80005cd6 <sys_mknod+0x76>
    80005c98:	f6840593          	add	a1,s0,-152
    80005c9c:	4509                	li	a0,2
    80005c9e:	ffffd097          	auipc	ra,0xffffd
    80005ca2:	028080e7          	jalr	40(ra) # 80002cc6 <argint>
    80005ca6:	02054863          	bltz	a0,80005cd6 <sys_mknod+0x76>
    80005caa:	f6841683          	lh	a3,-152(s0)
    80005cae:	f6c41603          	lh	a2,-148(s0)
    80005cb2:	458d                	li	a1,3
    80005cb4:	f7040513          	add	a0,s0,-144
    80005cb8:	fffff097          	auipc	ra,0xfffff
    80005cbc:	74e080e7          	jalr	1870(ra) # 80005406 <create>
    80005cc0:	c919                	beqz	a0,80005cd6 <sys_mknod+0x76>
    80005cc2:	ffffe097          	auipc	ra,0xffffe
    80005cc6:	fea080e7          	jalr	-22(ra) # 80003cac <iunlockput>
    80005cca:	ffffe097          	auipc	ra,0xffffe
    80005cce:	7c8080e7          	jalr	1992(ra) # 80004492 <end_op>
    80005cd2:	4501                	li	a0,0
    80005cd4:	a031                	j	80005ce0 <sys_mknod+0x80>
    80005cd6:	ffffe097          	auipc	ra,0xffffe
    80005cda:	7bc080e7          	jalr	1980(ra) # 80004492 <end_op>
    80005cde:	557d                	li	a0,-1
    80005ce0:	60ea                	ld	ra,152(sp)
    80005ce2:	644a                	ld	s0,144(sp)
    80005ce4:	610d                	add	sp,sp,160
    80005ce6:	8082                	ret

0000000080005ce8 <sys_chdir>:
    80005ce8:	7135                	add	sp,sp,-160
    80005cea:	ed06                	sd	ra,152(sp)
    80005cec:	e922                	sd	s0,144(sp)
    80005cee:	e14a                	sd	s2,128(sp)
    80005cf0:	1100                	add	s0,sp,160
    80005cf2:	ffffc097          	auipc	ra,0xffffc
    80005cf6:	d32080e7          	jalr	-718(ra) # 80001a24 <myproc>
    80005cfa:	892a                	mv	s2,a0
    80005cfc:	ffffe097          	auipc	ra,0xffffe
    80005d00:	71c080e7          	jalr	1820(ra) # 80004418 <begin_op>
    80005d04:	08000613          	li	a2,128
    80005d08:	f6040593          	add	a1,s0,-160
    80005d0c:	4501                	li	a0,0
    80005d0e:	ffffd097          	auipc	ra,0xffffd
    80005d12:	ffc080e7          	jalr	-4(ra) # 80002d0a <argstr>
    80005d16:	04054d63          	bltz	a0,80005d70 <sys_chdir+0x88>
    80005d1a:	e526                	sd	s1,136(sp)
    80005d1c:	f6040513          	add	a0,s0,-160
    80005d20:	ffffe097          	auipc	ra,0xffffe
    80005d24:	4f8080e7          	jalr	1272(ra) # 80004218 <namei>
    80005d28:	84aa                	mv	s1,a0
    80005d2a:	c131                	beqz	a0,80005d6e <sys_chdir+0x86>
    80005d2c:	ffffe097          	auipc	ra,0xffffe
    80005d30:	d1a080e7          	jalr	-742(ra) # 80003a46 <ilock>
    80005d34:	04449703          	lh	a4,68(s1)
    80005d38:	4785                	li	a5,1
    80005d3a:	04f71163          	bne	a4,a5,80005d7c <sys_chdir+0x94>
    80005d3e:	8526                	mv	a0,s1
    80005d40:	ffffe097          	auipc	ra,0xffffe
    80005d44:	dcc080e7          	jalr	-564(ra) # 80003b0c <iunlock>
    80005d48:	18093503          	ld	a0,384(s2)
    80005d4c:	ffffe097          	auipc	ra,0xffffe
    80005d50:	eb8080e7          	jalr	-328(ra) # 80003c04 <iput>
    80005d54:	ffffe097          	auipc	ra,0xffffe
    80005d58:	73e080e7          	jalr	1854(ra) # 80004492 <end_op>
    80005d5c:	18993023          	sd	s1,384(s2)
    80005d60:	4501                	li	a0,0
    80005d62:	64aa                	ld	s1,136(sp)
    80005d64:	60ea                	ld	ra,152(sp)
    80005d66:	644a                	ld	s0,144(sp)
    80005d68:	690a                	ld	s2,128(sp)
    80005d6a:	610d                	add	sp,sp,160
    80005d6c:	8082                	ret
    80005d6e:	64aa                	ld	s1,136(sp)
    80005d70:	ffffe097          	auipc	ra,0xffffe
    80005d74:	722080e7          	jalr	1826(ra) # 80004492 <end_op>
    80005d78:	557d                	li	a0,-1
    80005d7a:	b7ed                	j	80005d64 <sys_chdir+0x7c>
    80005d7c:	8526                	mv	a0,s1
    80005d7e:	ffffe097          	auipc	ra,0xffffe
    80005d82:	f2e080e7          	jalr	-210(ra) # 80003cac <iunlockput>
    80005d86:	ffffe097          	auipc	ra,0xffffe
    80005d8a:	70c080e7          	jalr	1804(ra) # 80004492 <end_op>
    80005d8e:	557d                	li	a0,-1
    80005d90:	64aa                	ld	s1,136(sp)
    80005d92:	bfc9                	j	80005d64 <sys_chdir+0x7c>

0000000080005d94 <sys_exec>:
    80005d94:	7121                	add	sp,sp,-448
    80005d96:	ff06                	sd	ra,440(sp)
    80005d98:	fb22                	sd	s0,432(sp)
    80005d9a:	f34a                	sd	s2,416(sp)
    80005d9c:	0380                	add	s0,sp,448
    80005d9e:	08000613          	li	a2,128
    80005da2:	f5040593          	add	a1,s0,-176
    80005da6:	4501                	li	a0,0
    80005da8:	ffffd097          	auipc	ra,0xffffd
    80005dac:	f62080e7          	jalr	-158(ra) # 80002d0a <argstr>
    80005db0:	597d                	li	s2,-1
    80005db2:	0e054a63          	bltz	a0,80005ea6 <sys_exec+0x112>
    80005db6:	e4840593          	add	a1,s0,-440
    80005dba:	4505                	li	a0,1
    80005dbc:	ffffd097          	auipc	ra,0xffffd
    80005dc0:	f2c080e7          	jalr	-212(ra) # 80002ce8 <argaddr>
    80005dc4:	0e054163          	bltz	a0,80005ea6 <sys_exec+0x112>
    80005dc8:	f726                	sd	s1,424(sp)
    80005dca:	ef4e                	sd	s3,408(sp)
    80005dcc:	eb52                	sd	s4,400(sp)
    80005dce:	10000613          	li	a2,256
    80005dd2:	4581                	li	a1,0
    80005dd4:	e5040513          	add	a0,s0,-432
    80005dd8:	ffffb097          	auipc	ra,0xffffb
    80005ddc:	f56080e7          	jalr	-170(ra) # 80000d2e <memset>
    80005de0:	e5040493          	add	s1,s0,-432
    80005de4:	89a6                	mv	s3,s1
    80005de6:	4901                	li	s2,0
    80005de8:	02000a13          	li	s4,32
    80005dec:	00391513          	sll	a0,s2,0x3
    80005df0:	e4040593          	add	a1,s0,-448
    80005df4:	e4843783          	ld	a5,-440(s0)
    80005df8:	953e                	add	a0,a0,a5
    80005dfa:	ffffd097          	auipc	ra,0xffffd
    80005dfe:	e32080e7          	jalr	-462(ra) # 80002c2c <fetchaddr>
    80005e02:	02054a63          	bltz	a0,80005e36 <sys_exec+0xa2>
    80005e06:	e4043783          	ld	a5,-448(s0)
    80005e0a:	c7b1                	beqz	a5,80005e56 <sys_exec+0xc2>
    80005e0c:	ffffb097          	auipc	ra,0xffffb
    80005e10:	d36080e7          	jalr	-714(ra) # 80000b42 <kalloc>
    80005e14:	85aa                	mv	a1,a0
    80005e16:	00a9b023          	sd	a0,0(s3)
    80005e1a:	cd11                	beqz	a0,80005e36 <sys_exec+0xa2>
    80005e1c:	6605                	lui	a2,0x1
    80005e1e:	e4043503          	ld	a0,-448(s0)
    80005e22:	ffffd097          	auipc	ra,0xffffd
    80005e26:	e5c080e7          	jalr	-420(ra) # 80002c7e <fetchstr>
    80005e2a:	00054663          	bltz	a0,80005e36 <sys_exec+0xa2>
    80005e2e:	0905                	add	s2,s2,1
    80005e30:	09a1                	add	s3,s3,8
    80005e32:	fb491de3          	bne	s2,s4,80005dec <sys_exec+0x58>
    80005e36:	f5040913          	add	s2,s0,-176
    80005e3a:	6088                	ld	a0,0(s1)
    80005e3c:	c12d                	beqz	a0,80005e9e <sys_exec+0x10a>
    80005e3e:	ffffb097          	auipc	ra,0xffffb
    80005e42:	c06080e7          	jalr	-1018(ra) # 80000a44 <kfree>
    80005e46:	04a1                	add	s1,s1,8
    80005e48:	ff2499e3          	bne	s1,s2,80005e3a <sys_exec+0xa6>
    80005e4c:	597d                	li	s2,-1
    80005e4e:	74ba                	ld	s1,424(sp)
    80005e50:	69fa                	ld	s3,408(sp)
    80005e52:	6a5a                	ld	s4,400(sp)
    80005e54:	a889                	j	80005ea6 <sys_exec+0x112>
    80005e56:	0009079b          	sext.w	a5,s2
    80005e5a:	078e                	sll	a5,a5,0x3
    80005e5c:	fd078793          	add	a5,a5,-48
    80005e60:	97a2                	add	a5,a5,s0
    80005e62:	e807b023          	sd	zero,-384(a5)
    80005e66:	e5040593          	add	a1,s0,-432
    80005e6a:	f5040513          	add	a0,s0,-176
    80005e6e:	fffff097          	auipc	ra,0xfffff
    80005e72:	124080e7          	jalr	292(ra) # 80004f92 <exec>
    80005e76:	892a                	mv	s2,a0
    80005e78:	f5040993          	add	s3,s0,-176
    80005e7c:	6088                	ld	a0,0(s1)
    80005e7e:	cd01                	beqz	a0,80005e96 <sys_exec+0x102>
    80005e80:	ffffb097          	auipc	ra,0xffffb
    80005e84:	bc4080e7          	jalr	-1084(ra) # 80000a44 <kfree>
    80005e88:	04a1                	add	s1,s1,8
    80005e8a:	ff3499e3          	bne	s1,s3,80005e7c <sys_exec+0xe8>
    80005e8e:	74ba                	ld	s1,424(sp)
    80005e90:	69fa                	ld	s3,408(sp)
    80005e92:	6a5a                	ld	s4,400(sp)
    80005e94:	a809                	j	80005ea6 <sys_exec+0x112>
    80005e96:	74ba                	ld	s1,424(sp)
    80005e98:	69fa                	ld	s3,408(sp)
    80005e9a:	6a5a                	ld	s4,400(sp)
    80005e9c:	a029                	j	80005ea6 <sys_exec+0x112>
    80005e9e:	597d                	li	s2,-1
    80005ea0:	74ba                	ld	s1,424(sp)
    80005ea2:	69fa                	ld	s3,408(sp)
    80005ea4:	6a5a                	ld	s4,400(sp)
    80005ea6:	854a                	mv	a0,s2
    80005ea8:	70fa                	ld	ra,440(sp)
    80005eaa:	745a                	ld	s0,432(sp)
    80005eac:	791a                	ld	s2,416(sp)
    80005eae:	6139                	add	sp,sp,448
    80005eb0:	8082                	ret

0000000080005eb2 <sys_pipe>:
    80005eb2:	7139                	add	sp,sp,-64
    80005eb4:	fc06                	sd	ra,56(sp)
    80005eb6:	f822                	sd	s0,48(sp)
    80005eb8:	f426                	sd	s1,40(sp)
    80005eba:	0080                	add	s0,sp,64
    80005ebc:	ffffc097          	auipc	ra,0xffffc
    80005ec0:	b68080e7          	jalr	-1176(ra) # 80001a24 <myproc>
    80005ec4:	84aa                	mv	s1,a0
    80005ec6:	fd840593          	add	a1,s0,-40
    80005eca:	4501                	li	a0,0
    80005ecc:	ffffd097          	auipc	ra,0xffffd
    80005ed0:	e1c080e7          	jalr	-484(ra) # 80002ce8 <argaddr>
    80005ed4:	57fd                	li	a5,-1
    80005ed6:	0e054363          	bltz	a0,80005fbc <sys_pipe+0x10a>
    80005eda:	fc840593          	add	a1,s0,-56
    80005ede:	fd040513          	add	a0,s0,-48
    80005ee2:	fffff097          	auipc	ra,0xfffff
    80005ee6:	d6e080e7          	jalr	-658(ra) # 80004c50 <pipealloc>
    80005eea:	57fd                	li	a5,-1
    80005eec:	0c054863          	bltz	a0,80005fbc <sys_pipe+0x10a>
    80005ef0:	fcf42223          	sw	a5,-60(s0)
    80005ef4:	fd043503          	ld	a0,-48(s0)
    80005ef8:	fffff097          	auipc	ra,0xfffff
    80005efc:	4cc080e7          	jalr	1228(ra) # 800053c4 <fdalloc>
    80005f00:	fca42223          	sw	a0,-60(s0)
    80005f04:	08054f63          	bltz	a0,80005fa2 <sys_pipe+0xf0>
    80005f08:	fc843503          	ld	a0,-56(s0)
    80005f0c:	fffff097          	auipc	ra,0xfffff
    80005f10:	4b8080e7          	jalr	1208(ra) # 800053c4 <fdalloc>
    80005f14:	fca42023          	sw	a0,-64(s0)
    80005f18:	06054b63          	bltz	a0,80005f8e <sys_pipe+0xdc>
    80005f1c:	4691                	li	a3,4
    80005f1e:	fc440613          	add	a2,s0,-60
    80005f22:	fd843583          	ld	a1,-40(s0)
    80005f26:	60c8                	ld	a0,128(s1)
    80005f28:	ffffb097          	auipc	ra,0xffffb
    80005f2c:	7a4080e7          	jalr	1956(ra) # 800016cc <copyout>
    80005f30:	02054063          	bltz	a0,80005f50 <sys_pipe+0x9e>
    80005f34:	4691                	li	a3,4
    80005f36:	fc040613          	add	a2,s0,-64
    80005f3a:	fd843583          	ld	a1,-40(s0)
    80005f3e:	0591                	add	a1,a1,4
    80005f40:	60c8                	ld	a0,128(s1)
    80005f42:	ffffb097          	auipc	ra,0xffffb
    80005f46:	78a080e7          	jalr	1930(ra) # 800016cc <copyout>
    80005f4a:	4781                	li	a5,0
    80005f4c:	06055863          	bgez	a0,80005fbc <sys_pipe+0x10a>
    80005f50:	fc442783          	lw	a5,-60(s0)
    80005f54:	02078793          	add	a5,a5,32
    80005f58:	078e                	sll	a5,a5,0x3
    80005f5a:	97a6                	add	a5,a5,s1
    80005f5c:	0007b023          	sd	zero,0(a5)
    80005f60:	fc042783          	lw	a5,-64(s0)
    80005f64:	02078793          	add	a5,a5,32
    80005f68:	078e                	sll	a5,a5,0x3
    80005f6a:	00f48533          	add	a0,s1,a5
    80005f6e:	00053023          	sd	zero,0(a0)
    80005f72:	fd043503          	ld	a0,-48(s0)
    80005f76:	fffff097          	auipc	ra,0xfffff
    80005f7a:	96c080e7          	jalr	-1684(ra) # 800048e2 <fileclose>
    80005f7e:	fc843503          	ld	a0,-56(s0)
    80005f82:	fffff097          	auipc	ra,0xfffff
    80005f86:	960080e7          	jalr	-1696(ra) # 800048e2 <fileclose>
    80005f8a:	57fd                	li	a5,-1
    80005f8c:	a805                	j	80005fbc <sys_pipe+0x10a>
    80005f8e:	fc442783          	lw	a5,-60(s0)
    80005f92:	0007c863          	bltz	a5,80005fa2 <sys_pipe+0xf0>
    80005f96:	02078793          	add	a5,a5,32
    80005f9a:	078e                	sll	a5,a5,0x3
    80005f9c:	97a6                	add	a5,a5,s1
    80005f9e:	0007b023          	sd	zero,0(a5)
    80005fa2:	fd043503          	ld	a0,-48(s0)
    80005fa6:	fffff097          	auipc	ra,0xfffff
    80005faa:	93c080e7          	jalr	-1732(ra) # 800048e2 <fileclose>
    80005fae:	fc843503          	ld	a0,-56(s0)
    80005fb2:	fffff097          	auipc	ra,0xfffff
    80005fb6:	930080e7          	jalr	-1744(ra) # 800048e2 <fileclose>
    80005fba:	57fd                	li	a5,-1
    80005fbc:	853e                	mv	a0,a5
    80005fbe:	70e2                	ld	ra,56(sp)
    80005fc0:	7442                	ld	s0,48(sp)
    80005fc2:	74a2                	ld	s1,40(sp)
    80005fc4:	6121                	add	sp,sp,64
    80005fc6:	8082                	ret
	...

0000000080005fd0 <kernelvec>:
    80005fd0:	7111                	add	sp,sp,-256
    80005fd2:	e006                	sd	ra,0(sp)
    80005fd4:	e40a                	sd	sp,8(sp)
    80005fd6:	e80e                	sd	gp,16(sp)
    80005fd8:	ec12                	sd	tp,24(sp)
    80005fda:	f016                	sd	t0,32(sp)
    80005fdc:	f41a                	sd	t1,40(sp)
    80005fde:	f81e                	sd	t2,48(sp)
    80005fe0:	fc22                	sd	s0,56(sp)
    80005fe2:	e0a6                	sd	s1,64(sp)
    80005fe4:	e4aa                	sd	a0,72(sp)
    80005fe6:	e8ae                	sd	a1,80(sp)
    80005fe8:	ecb2                	sd	a2,88(sp)
    80005fea:	f0b6                	sd	a3,96(sp)
    80005fec:	f4ba                	sd	a4,104(sp)
    80005fee:	f8be                	sd	a5,112(sp)
    80005ff0:	fcc2                	sd	a6,120(sp)
    80005ff2:	e146                	sd	a7,128(sp)
    80005ff4:	e54a                	sd	s2,136(sp)
    80005ff6:	e94e                	sd	s3,144(sp)
    80005ff8:	ed52                	sd	s4,152(sp)
    80005ffa:	f156                	sd	s5,160(sp)
    80005ffc:	f55a                	sd	s6,168(sp)
    80005ffe:	f95e                	sd	s7,176(sp)
    80006000:	fd62                	sd	s8,184(sp)
    80006002:	e1e6                	sd	s9,192(sp)
    80006004:	e5ea                	sd	s10,200(sp)
    80006006:	e9ee                	sd	s11,208(sp)
    80006008:	edf2                	sd	t3,216(sp)
    8000600a:	f1f6                	sd	t4,224(sp)
    8000600c:	f5fa                	sd	t5,232(sp)
    8000600e:	f9fe                	sd	t6,240(sp)
    80006010:	ae9fc0ef          	jal	80002af8 <kerneltrap>
    80006014:	6082                	ld	ra,0(sp)
    80006016:	6122                	ld	sp,8(sp)
    80006018:	61c2                	ld	gp,16(sp)
    8000601a:	7282                	ld	t0,32(sp)
    8000601c:	7322                	ld	t1,40(sp)
    8000601e:	73c2                	ld	t2,48(sp)
    80006020:	7462                	ld	s0,56(sp)
    80006022:	6486                	ld	s1,64(sp)
    80006024:	6526                	ld	a0,72(sp)
    80006026:	65c6                	ld	a1,80(sp)
    80006028:	6666                	ld	a2,88(sp)
    8000602a:	7686                	ld	a3,96(sp)
    8000602c:	7726                	ld	a4,104(sp)
    8000602e:	77c6                	ld	a5,112(sp)
    80006030:	7866                	ld	a6,120(sp)
    80006032:	688a                	ld	a7,128(sp)
    80006034:	692a                	ld	s2,136(sp)
    80006036:	69ca                	ld	s3,144(sp)
    80006038:	6a6a                	ld	s4,152(sp)
    8000603a:	7a8a                	ld	s5,160(sp)
    8000603c:	7b2a                	ld	s6,168(sp)
    8000603e:	7bca                	ld	s7,176(sp)
    80006040:	7c6a                	ld	s8,184(sp)
    80006042:	6c8e                	ld	s9,192(sp)
    80006044:	6d2e                	ld	s10,200(sp)
    80006046:	6dce                	ld	s11,208(sp)
    80006048:	6e6e                	ld	t3,216(sp)
    8000604a:	7e8e                	ld	t4,224(sp)
    8000604c:	7f2e                	ld	t5,232(sp)
    8000604e:	7fce                	ld	t6,240(sp)
    80006050:	6111                	add	sp,sp,256
    80006052:	10200073          	sret
    80006056:	00000013          	nop
    8000605a:	00000013          	nop
    8000605e:	0001                	nop

0000000080006060 <timervec>:
    80006060:	34051573          	csrrw	a0,mscratch,a0
    80006064:	e10c                	sd	a1,0(a0)
    80006066:	e510                	sd	a2,8(a0)
    80006068:	e914                	sd	a3,16(a0)
    8000606a:	6d0c                	ld	a1,24(a0)
    8000606c:	7110                	ld	a2,32(a0)
    8000606e:	6194                	ld	a3,0(a1)
    80006070:	96b2                	add	a3,a3,a2
    80006072:	e194                	sd	a3,0(a1)
    80006074:	4589                	li	a1,2
    80006076:	14459073          	csrw	sip,a1
    8000607a:	6914                	ld	a3,16(a0)
    8000607c:	6510                	ld	a2,8(a0)
    8000607e:	610c                	ld	a1,0(a0)
    80006080:	34051573          	csrrw	a0,mscratch,a0
    80006084:	30200073          	mret
	...

000000008000608a <plicinit>:
    8000608a:	1141                	add	sp,sp,-16
    8000608c:	e422                	sd	s0,8(sp)
    8000608e:	0800                	add	s0,sp,16
    80006090:	0c0007b7          	lui	a5,0xc000
    80006094:	4705                	li	a4,1
    80006096:	d798                	sw	a4,40(a5)
    80006098:	0c0007b7          	lui	a5,0xc000
    8000609c:	c3d8                	sw	a4,4(a5)
    8000609e:	6422                	ld	s0,8(sp)
    800060a0:	0141                	add	sp,sp,16
    800060a2:	8082                	ret

00000000800060a4 <plicinithart>:
    800060a4:	1141                	add	sp,sp,-16
    800060a6:	e406                	sd	ra,8(sp)
    800060a8:	e022                	sd	s0,0(sp)
    800060aa:	0800                	add	s0,sp,16
    800060ac:	ffffc097          	auipc	ra,0xffffc
    800060b0:	94c080e7          	jalr	-1716(ra) # 800019f8 <cpuid>
    800060b4:	0085171b          	sllw	a4,a0,0x8
    800060b8:	0c0027b7          	lui	a5,0xc002
    800060bc:	97ba                	add	a5,a5,a4
    800060be:	40200713          	li	a4,1026
    800060c2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>
    800060c6:	00d5151b          	sllw	a0,a0,0xd
    800060ca:	0c2017b7          	lui	a5,0xc201
    800060ce:	97aa                	add	a5,a5,a0
    800060d0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
    800060d4:	60a2                	ld	ra,8(sp)
    800060d6:	6402                	ld	s0,0(sp)
    800060d8:	0141                	add	sp,sp,16
    800060da:	8082                	ret

00000000800060dc <plic_claim>:
    800060dc:	1141                	add	sp,sp,-16
    800060de:	e406                	sd	ra,8(sp)
    800060e0:	e022                	sd	s0,0(sp)
    800060e2:	0800                	add	s0,sp,16
    800060e4:	ffffc097          	auipc	ra,0xffffc
    800060e8:	914080e7          	jalr	-1772(ra) # 800019f8 <cpuid>
    800060ec:	00d5151b          	sllw	a0,a0,0xd
    800060f0:	0c2017b7          	lui	a5,0xc201
    800060f4:	97aa                	add	a5,a5,a0
    800060f6:	43c8                	lw	a0,4(a5)
    800060f8:	60a2                	ld	ra,8(sp)
    800060fa:	6402                	ld	s0,0(sp)
    800060fc:	0141                	add	sp,sp,16
    800060fe:	8082                	ret

0000000080006100 <plic_complete>:
    80006100:	1101                	add	sp,sp,-32
    80006102:	ec06                	sd	ra,24(sp)
    80006104:	e822                	sd	s0,16(sp)
    80006106:	e426                	sd	s1,8(sp)
    80006108:	1000                	add	s0,sp,32
    8000610a:	84aa                	mv	s1,a0
    8000610c:	ffffc097          	auipc	ra,0xffffc
    80006110:	8ec080e7          	jalr	-1812(ra) # 800019f8 <cpuid>
    80006114:	00d5151b          	sllw	a0,a0,0xd
    80006118:	0c2017b7          	lui	a5,0xc201
    8000611c:	97aa                	add	a5,a5,a0
    8000611e:	c3c4                	sw	s1,4(a5)
    80006120:	60e2                	ld	ra,24(sp)
    80006122:	6442                	ld	s0,16(sp)
    80006124:	64a2                	ld	s1,8(sp)
    80006126:	6105                	add	sp,sp,32
    80006128:	8082                	ret

000000008000612a <free_desc>:
    8000612a:	1141                	add	sp,sp,-16
    8000612c:	e406                	sd	ra,8(sp)
    8000612e:	e022                	sd	s0,0(sp)
    80006130:	0800                	add	s0,sp,16
    80006132:	479d                	li	a5,7
    80006134:	06a7c863          	blt	a5,a0,800061a4 <free_desc+0x7a>
    80006138:	0001d717          	auipc	a4,0x1d
    8000613c:	ec870713          	add	a4,a4,-312 # 80023000 <disk>
    80006140:	972a                	add	a4,a4,a0
    80006142:	6789                	lui	a5,0x2
    80006144:	97ba                	add	a5,a5,a4
    80006146:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    8000614a:	e7ad                	bnez	a5,800061b4 <free_desc+0x8a>
    8000614c:	00451793          	sll	a5,a0,0x4
    80006150:	0001f717          	auipc	a4,0x1f
    80006154:	eb070713          	add	a4,a4,-336 # 80025000 <disk+0x2000>
    80006158:	6314                	ld	a3,0(a4)
    8000615a:	96be                	add	a3,a3,a5
    8000615c:	0006b023          	sd	zero,0(a3)
    80006160:	6314                	ld	a3,0(a4)
    80006162:	96be                	add	a3,a3,a5
    80006164:	0006a423          	sw	zero,8(a3)
    80006168:	6314                	ld	a3,0(a4)
    8000616a:	96be                	add	a3,a3,a5
    8000616c:	00069623          	sh	zero,12(a3)
    80006170:	6318                	ld	a4,0(a4)
    80006172:	97ba                	add	a5,a5,a4
    80006174:	00079723          	sh	zero,14(a5)
    80006178:	0001d717          	auipc	a4,0x1d
    8000617c:	e8870713          	add	a4,a4,-376 # 80023000 <disk>
    80006180:	972a                	add	a4,a4,a0
    80006182:	6789                	lui	a5,0x2
    80006184:	97ba                	add	a5,a5,a4
    80006186:	4705                	li	a4,1
    80006188:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
    8000618c:	0001f517          	auipc	a0,0x1f
    80006190:	e8c50513          	add	a0,a0,-372 # 80025018 <disk+0x2018>
    80006194:	ffffc097          	auipc	ra,0xffffc
    80006198:	100080e7          	jalr	256(ra) # 80002294 <wakeup>
    8000619c:	60a2                	ld	ra,8(sp)
    8000619e:	6402                	ld	s0,0(sp)
    800061a0:	0141                	add	sp,sp,16
    800061a2:	8082                	ret
    800061a4:	00002517          	auipc	a0,0x2
    800061a8:	4ac50513          	add	a0,a0,1196 # 80008650 <etext+0x650>
    800061ac:	ffffa097          	auipc	ra,0xffffa
    800061b0:	3ae080e7          	jalr	942(ra) # 8000055a <panic>
    800061b4:	00002517          	auipc	a0,0x2
    800061b8:	4ac50513          	add	a0,a0,1196 # 80008660 <etext+0x660>
    800061bc:	ffffa097          	auipc	ra,0xffffa
    800061c0:	39e080e7          	jalr	926(ra) # 8000055a <panic>

00000000800061c4 <virtio_disk_init>:
    800061c4:	1141                	add	sp,sp,-16
    800061c6:	e406                	sd	ra,8(sp)
    800061c8:	e022                	sd	s0,0(sp)
    800061ca:	0800                	add	s0,sp,16
    800061cc:	00002597          	auipc	a1,0x2
    800061d0:	4a458593          	add	a1,a1,1188 # 80008670 <etext+0x670>
    800061d4:	0001f517          	auipc	a0,0x1f
    800061d8:	f5450513          	add	a0,a0,-172 # 80025128 <disk+0x2128>
    800061dc:	ffffb097          	auipc	ra,0xffffb
    800061e0:	9c6080e7          	jalr	-1594(ra) # 80000ba2 <initlock>
    800061e4:	100017b7          	lui	a5,0x10001
    800061e8:	4398                	lw	a4,0(a5)
    800061ea:	2701                	sext.w	a4,a4
    800061ec:	747277b7          	lui	a5,0x74727
    800061f0:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800061f4:	0ef71f63          	bne	a4,a5,800062f2 <virtio_disk_init+0x12e>
    800061f8:	100017b7          	lui	a5,0x10001
    800061fc:	0791                	add	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800061fe:	439c                	lw	a5,0(a5)
    80006200:	2781                	sext.w	a5,a5
    80006202:	4705                	li	a4,1
    80006204:	0ee79763          	bne	a5,a4,800062f2 <virtio_disk_init+0x12e>
    80006208:	100017b7          	lui	a5,0x10001
    8000620c:	07a1                	add	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    8000620e:	439c                	lw	a5,0(a5)
    80006210:	2781                	sext.w	a5,a5
    80006212:	4709                	li	a4,2
    80006214:	0ce79f63          	bne	a5,a4,800062f2 <virtio_disk_init+0x12e>
    80006218:	100017b7          	lui	a5,0x10001
    8000621c:	47d8                	lw	a4,12(a5)
    8000621e:	2701                	sext.w	a4,a4
    80006220:	554d47b7          	lui	a5,0x554d4
    80006224:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006228:	0cf71563          	bne	a4,a5,800062f2 <virtio_disk_init+0x12e>
    8000622c:	100017b7          	lui	a5,0x10001
    80006230:	4705                	li	a4,1
    80006232:	dbb8                	sw	a4,112(a5)
    80006234:	470d                	li	a4,3
    80006236:	dbb8                	sw	a4,112(a5)
    80006238:	10001737          	lui	a4,0x10001
    8000623c:	4b14                	lw	a3,16(a4)
    8000623e:	c7ffe737          	lui	a4,0xc7ffe
    80006242:	75f70713          	add	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80006246:	8ef9                	and	a3,a3,a4
    80006248:	10001737          	lui	a4,0x10001
    8000624c:	d314                	sw	a3,32(a4)
    8000624e:	472d                	li	a4,11
    80006250:	dbb8                	sw	a4,112(a5)
    80006252:	473d                	li	a4,15
    80006254:	dbb8                	sw	a4,112(a5)
    80006256:	100017b7          	lui	a5,0x10001
    8000625a:	6705                	lui	a4,0x1
    8000625c:	d798                	sw	a4,40(a5)
    8000625e:	100017b7          	lui	a5,0x10001
    80006262:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
    80006266:	100017b7          	lui	a5,0x10001
    8000626a:	03478793          	add	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    8000626e:	439c                	lw	a5,0(a5)
    80006270:	2781                	sext.w	a5,a5
    80006272:	cbc1                	beqz	a5,80006302 <virtio_disk_init+0x13e>
    80006274:	471d                	li	a4,7
    80006276:	08f77e63          	bgeu	a4,a5,80006312 <virtio_disk_init+0x14e>
    8000627a:	100017b7          	lui	a5,0x10001
    8000627e:	4721                	li	a4,8
    80006280:	df98                	sw	a4,56(a5)
    80006282:	6609                	lui	a2,0x2
    80006284:	4581                	li	a1,0
    80006286:	0001d517          	auipc	a0,0x1d
    8000628a:	d7a50513          	add	a0,a0,-646 # 80023000 <disk>
    8000628e:	ffffb097          	auipc	ra,0xffffb
    80006292:	aa0080e7          	jalr	-1376(ra) # 80000d2e <memset>
    80006296:	0001d697          	auipc	a3,0x1d
    8000629a:	d6a68693          	add	a3,a3,-662 # 80023000 <disk>
    8000629e:	00c6d713          	srl	a4,a3,0xc
    800062a2:	2701                	sext.w	a4,a4
    800062a4:	100017b7          	lui	a5,0x10001
    800062a8:	c3b8                	sw	a4,64(a5)
    800062aa:	0001f797          	auipc	a5,0x1f
    800062ae:	d5678793          	add	a5,a5,-682 # 80025000 <disk+0x2000>
    800062b2:	e394                	sd	a3,0(a5)
    800062b4:	0001d717          	auipc	a4,0x1d
    800062b8:	dcc70713          	add	a4,a4,-564 # 80023080 <disk+0x80>
    800062bc:	e798                	sd	a4,8(a5)
    800062be:	0001e717          	auipc	a4,0x1e
    800062c2:	d4270713          	add	a4,a4,-702 # 80024000 <disk+0x1000>
    800062c6:	eb98                	sd	a4,16(a5)
    800062c8:	4705                	li	a4,1
    800062ca:	00e78c23          	sb	a4,24(a5)
    800062ce:	00e78ca3          	sb	a4,25(a5)
    800062d2:	00e78d23          	sb	a4,26(a5)
    800062d6:	00e78da3          	sb	a4,27(a5)
    800062da:	00e78e23          	sb	a4,28(a5)
    800062de:	00e78ea3          	sb	a4,29(a5)
    800062e2:	00e78f23          	sb	a4,30(a5)
    800062e6:	00e78fa3          	sb	a4,31(a5)
    800062ea:	60a2                	ld	ra,8(sp)
    800062ec:	6402                	ld	s0,0(sp)
    800062ee:	0141                	add	sp,sp,16
    800062f0:	8082                	ret
    800062f2:	00002517          	auipc	a0,0x2
    800062f6:	38e50513          	add	a0,a0,910 # 80008680 <etext+0x680>
    800062fa:	ffffa097          	auipc	ra,0xffffa
    800062fe:	260080e7          	jalr	608(ra) # 8000055a <panic>
    80006302:	00002517          	auipc	a0,0x2
    80006306:	39e50513          	add	a0,a0,926 # 800086a0 <etext+0x6a0>
    8000630a:	ffffa097          	auipc	ra,0xffffa
    8000630e:	250080e7          	jalr	592(ra) # 8000055a <panic>
    80006312:	00002517          	auipc	a0,0x2
    80006316:	3ae50513          	add	a0,a0,942 # 800086c0 <etext+0x6c0>
    8000631a:	ffffa097          	auipc	ra,0xffffa
    8000631e:	240080e7          	jalr	576(ra) # 8000055a <panic>

0000000080006322 <virtio_disk_rw>:
    80006322:	7159                	add	sp,sp,-112
    80006324:	f486                	sd	ra,104(sp)
    80006326:	f0a2                	sd	s0,96(sp)
    80006328:	eca6                	sd	s1,88(sp)
    8000632a:	e8ca                	sd	s2,80(sp)
    8000632c:	e4ce                	sd	s3,72(sp)
    8000632e:	e0d2                	sd	s4,64(sp)
    80006330:	fc56                	sd	s5,56(sp)
    80006332:	f85a                	sd	s6,48(sp)
    80006334:	f45e                	sd	s7,40(sp)
    80006336:	f062                	sd	s8,32(sp)
    80006338:	ec66                	sd	s9,24(sp)
    8000633a:	1880                	add	s0,sp,112
    8000633c:	8a2a                	mv	s4,a0
    8000633e:	8cae                	mv	s9,a1
    80006340:	00c52c03          	lw	s8,12(a0)
    80006344:	001c1c1b          	sllw	s8,s8,0x1
    80006348:	1c02                	sll	s8,s8,0x20
    8000634a:	020c5c13          	srl	s8,s8,0x20
    8000634e:	0001f517          	auipc	a0,0x1f
    80006352:	dda50513          	add	a0,a0,-550 # 80025128 <disk+0x2128>
    80006356:	ffffb097          	auipc	ra,0xffffb
    8000635a:	8dc080e7          	jalr	-1828(ra) # 80000c32 <acquire>
    8000635e:	4981                	li	s3,0
    80006360:	44a1                	li	s1,8
    80006362:	0001db97          	auipc	s7,0x1d
    80006366:	c9eb8b93          	add	s7,s7,-866 # 80023000 <disk>
    8000636a:	6b09                	lui	s6,0x2
    8000636c:	4a8d                	li	s5,3
    8000636e:	a88d                	j	800063e0 <virtio_disk_rw+0xbe>
    80006370:	00fb8733          	add	a4,s7,a5
    80006374:	975a                	add	a4,a4,s6
    80006376:	00070c23          	sb	zero,24(a4)
    8000637a:	c19c                	sw	a5,0(a1)
    8000637c:	0207c563          	bltz	a5,800063a6 <virtio_disk_rw+0x84>
    80006380:	2905                	addw	s2,s2,1
    80006382:	0611                	add	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    80006384:	1b590163          	beq	s2,s5,80006526 <virtio_disk_rw+0x204>
    80006388:	85b2                	mv	a1,a2
    8000638a:	0001f717          	auipc	a4,0x1f
    8000638e:	c8e70713          	add	a4,a4,-882 # 80025018 <disk+0x2018>
    80006392:	87ce                	mv	a5,s3
    80006394:	00074683          	lbu	a3,0(a4)
    80006398:	fee1                	bnez	a3,80006370 <virtio_disk_rw+0x4e>
    8000639a:	2785                	addw	a5,a5,1
    8000639c:	0705                	add	a4,a4,1
    8000639e:	fe979be3          	bne	a5,s1,80006394 <virtio_disk_rw+0x72>
    800063a2:	57fd                	li	a5,-1
    800063a4:	c19c                	sw	a5,0(a1)
    800063a6:	03205163          	blez	s2,800063c8 <virtio_disk_rw+0xa6>
    800063aa:	f9042503          	lw	a0,-112(s0)
    800063ae:	00000097          	auipc	ra,0x0
    800063b2:	d7c080e7          	jalr	-644(ra) # 8000612a <free_desc>
    800063b6:	4785                	li	a5,1
    800063b8:	0127d863          	bge	a5,s2,800063c8 <virtio_disk_rw+0xa6>
    800063bc:	f9442503          	lw	a0,-108(s0)
    800063c0:	00000097          	auipc	ra,0x0
    800063c4:	d6a080e7          	jalr	-662(ra) # 8000612a <free_desc>
    800063c8:	0001f597          	auipc	a1,0x1f
    800063cc:	d6058593          	add	a1,a1,-672 # 80025128 <disk+0x2128>
    800063d0:	0001f517          	auipc	a0,0x1f
    800063d4:	c4850513          	add	a0,a0,-952 # 80025018 <disk+0x2018>
    800063d8:	ffffc097          	auipc	ra,0xffffc
    800063dc:	d30080e7          	jalr	-720(ra) # 80002108 <sleep>
    800063e0:	f9040613          	add	a2,s0,-112
    800063e4:	894e                	mv	s2,s3
    800063e6:	b74d                	j	80006388 <virtio_disk_rw+0x66>
    800063e8:	0001f717          	auipc	a4,0x1f
    800063ec:	c1873703          	ld	a4,-1000(a4) # 80025000 <disk+0x2000>
    800063f0:	973e                	add	a4,a4,a5
    800063f2:	00071623          	sh	zero,12(a4)
    800063f6:	0001d897          	auipc	a7,0x1d
    800063fa:	c0a88893          	add	a7,a7,-1014 # 80023000 <disk>
    800063fe:	0001f717          	auipc	a4,0x1f
    80006402:	c0270713          	add	a4,a4,-1022 # 80025000 <disk+0x2000>
    80006406:	6314                	ld	a3,0(a4)
    80006408:	96be                	add	a3,a3,a5
    8000640a:	00c6d583          	lhu	a1,12(a3)
    8000640e:	0015e593          	or	a1,a1,1
    80006412:	00b69623          	sh	a1,12(a3)
    80006416:	f9842683          	lw	a3,-104(s0)
    8000641a:	630c                	ld	a1,0(a4)
    8000641c:	97ae                	add	a5,a5,a1
    8000641e:	00d79723          	sh	a3,14(a5)
    80006422:	20050593          	add	a1,a0,512
    80006426:	0592                	sll	a1,a1,0x4
    80006428:	95c6                	add	a1,a1,a7
    8000642a:	57fd                	li	a5,-1
    8000642c:	02f58823          	sb	a5,48(a1)
    80006430:	00469793          	sll	a5,a3,0x4
    80006434:	00073803          	ld	a6,0(a4)
    80006438:	983e                	add	a6,a6,a5
    8000643a:	6689                	lui	a3,0x2
    8000643c:	03068693          	add	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006440:	96b2                	add	a3,a3,a2
    80006442:	96c6                	add	a3,a3,a7
    80006444:	00d83023          	sd	a3,0(a6)
    80006448:	6314                	ld	a3,0(a4)
    8000644a:	96be                	add	a3,a3,a5
    8000644c:	4605                	li	a2,1
    8000644e:	c690                	sw	a2,8(a3)
    80006450:	6314                	ld	a3,0(a4)
    80006452:	96be                	add	a3,a3,a5
    80006454:	4809                	li	a6,2
    80006456:	01069623          	sh	a6,12(a3)
    8000645a:	6314                	ld	a3,0(a4)
    8000645c:	97b6                	add	a5,a5,a3
    8000645e:	00079723          	sh	zero,14(a5)
    80006462:	00ca2223          	sw	a2,4(s4)
    80006466:	0345b423          	sd	s4,40(a1)
    8000646a:	6714                	ld	a3,8(a4)
    8000646c:	0026d783          	lhu	a5,2(a3)
    80006470:	8b9d                	and	a5,a5,7
    80006472:	0786                	sll	a5,a5,0x1
    80006474:	96be                	add	a3,a3,a5
    80006476:	00a69223          	sh	a0,4(a3)
    8000647a:	0ff0000f          	fence
    8000647e:	6718                	ld	a4,8(a4)
    80006480:	00275783          	lhu	a5,2(a4)
    80006484:	2785                	addw	a5,a5,1
    80006486:	00f71123          	sh	a5,2(a4)
    8000648a:	0ff0000f          	fence
    8000648e:	100017b7          	lui	a5,0x10001
    80006492:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>
    80006496:	004a2783          	lw	a5,4(s4)
    8000649a:	02c79163          	bne	a5,a2,800064bc <virtio_disk_rw+0x19a>
    8000649e:	0001f917          	auipc	s2,0x1f
    800064a2:	c8a90913          	add	s2,s2,-886 # 80025128 <disk+0x2128>
    800064a6:	4485                	li	s1,1
    800064a8:	85ca                	mv	a1,s2
    800064aa:	8552                	mv	a0,s4
    800064ac:	ffffc097          	auipc	ra,0xffffc
    800064b0:	c5c080e7          	jalr	-932(ra) # 80002108 <sleep>
    800064b4:	004a2783          	lw	a5,4(s4)
    800064b8:	fe9788e3          	beq	a5,s1,800064a8 <virtio_disk_rw+0x186>
    800064bc:	f9042903          	lw	s2,-112(s0)
    800064c0:	20090713          	add	a4,s2,512
    800064c4:	0712                	sll	a4,a4,0x4
    800064c6:	0001d797          	auipc	a5,0x1d
    800064ca:	b3a78793          	add	a5,a5,-1222 # 80023000 <disk>
    800064ce:	97ba                	add	a5,a5,a4
    800064d0:	0207b423          	sd	zero,40(a5)
    800064d4:	0001f997          	auipc	s3,0x1f
    800064d8:	b2c98993          	add	s3,s3,-1236 # 80025000 <disk+0x2000>
    800064dc:	00491713          	sll	a4,s2,0x4
    800064e0:	0009b783          	ld	a5,0(s3)
    800064e4:	97ba                	add	a5,a5,a4
    800064e6:	00c7d483          	lhu	s1,12(a5)
    800064ea:	854a                	mv	a0,s2
    800064ec:	00e7d903          	lhu	s2,14(a5)
    800064f0:	00000097          	auipc	ra,0x0
    800064f4:	c3a080e7          	jalr	-966(ra) # 8000612a <free_desc>
    800064f8:	8885                	and	s1,s1,1
    800064fa:	f0ed                	bnez	s1,800064dc <virtio_disk_rw+0x1ba>
    800064fc:	0001f517          	auipc	a0,0x1f
    80006500:	c2c50513          	add	a0,a0,-980 # 80025128 <disk+0x2128>
    80006504:	ffffa097          	auipc	ra,0xffffa
    80006508:	7e2080e7          	jalr	2018(ra) # 80000ce6 <release>
    8000650c:	70a6                	ld	ra,104(sp)
    8000650e:	7406                	ld	s0,96(sp)
    80006510:	64e6                	ld	s1,88(sp)
    80006512:	6946                	ld	s2,80(sp)
    80006514:	69a6                	ld	s3,72(sp)
    80006516:	6a06                	ld	s4,64(sp)
    80006518:	7ae2                	ld	s5,56(sp)
    8000651a:	7b42                	ld	s6,48(sp)
    8000651c:	7ba2                	ld	s7,40(sp)
    8000651e:	7c02                	ld	s8,32(sp)
    80006520:	6ce2                	ld	s9,24(sp)
    80006522:	6165                	add	sp,sp,112
    80006524:	8082                	ret
    80006526:	f9042503          	lw	a0,-112(s0)
    8000652a:	00451613          	sll	a2,a0,0x4
    8000652e:	0001d597          	auipc	a1,0x1d
    80006532:	ad258593          	add	a1,a1,-1326 # 80023000 <disk>
    80006536:	20050793          	add	a5,a0,512
    8000653a:	0792                	sll	a5,a5,0x4
    8000653c:	97ae                	add	a5,a5,a1
    8000653e:	01903733          	snez	a4,s9
    80006542:	0ae7a423          	sw	a4,168(a5)
    80006546:	0a07a623          	sw	zero,172(a5)
    8000654a:	0b87b823          	sd	s8,176(a5)
    8000654e:	0001f717          	auipc	a4,0x1f
    80006552:	ab270713          	add	a4,a4,-1358 # 80025000 <disk+0x2000>
    80006556:	6314                	ld	a3,0(a4)
    80006558:	96b2                	add	a3,a3,a2
    8000655a:	6789                	lui	a5,0x2
    8000655c:	0a878793          	add	a5,a5,168 # 20a8 <_entry-0x7fffdf58>
    80006560:	97b2                	add	a5,a5,a2
    80006562:	97ae                	add	a5,a5,a1
    80006564:	e29c                	sd	a5,0(a3)
    80006566:	631c                	ld	a5,0(a4)
    80006568:	97b2                	add	a5,a5,a2
    8000656a:	46c1                	li	a3,16
    8000656c:	c794                	sw	a3,8(a5)
    8000656e:	631c                	ld	a5,0(a4)
    80006570:	97b2                	add	a5,a5,a2
    80006572:	4685                	li	a3,1
    80006574:	00d79623          	sh	a3,12(a5)
    80006578:	f9442783          	lw	a5,-108(s0)
    8000657c:	6314                	ld	a3,0(a4)
    8000657e:	96b2                	add	a3,a3,a2
    80006580:	00f69723          	sh	a5,14(a3)
    80006584:	0792                	sll	a5,a5,0x4
    80006586:	6314                	ld	a3,0(a4)
    80006588:	96be                	add	a3,a3,a5
    8000658a:	058a0593          	add	a1,s4,88
    8000658e:	e28c                	sd	a1,0(a3)
    80006590:	6318                	ld	a4,0(a4)
    80006592:	973e                	add	a4,a4,a5
    80006594:	40000693          	li	a3,1024
    80006598:	c714                	sw	a3,8(a4)
    8000659a:	e40c97e3          	bnez	s9,800063e8 <virtio_disk_rw+0xc6>
    8000659e:	0001f717          	auipc	a4,0x1f
    800065a2:	a6273703          	ld	a4,-1438(a4) # 80025000 <disk+0x2000>
    800065a6:	973e                	add	a4,a4,a5
    800065a8:	4689                	li	a3,2
    800065aa:	00d71623          	sh	a3,12(a4)
    800065ae:	b5a1                	j	800063f6 <virtio_disk_rw+0xd4>

00000000800065b0 <virtio_disk_intr>:
    800065b0:	1101                	add	sp,sp,-32
    800065b2:	ec06                	sd	ra,24(sp)
    800065b4:	e822                	sd	s0,16(sp)
    800065b6:	1000                	add	s0,sp,32
    800065b8:	0001f517          	auipc	a0,0x1f
    800065bc:	b7050513          	add	a0,a0,-1168 # 80025128 <disk+0x2128>
    800065c0:	ffffa097          	auipc	ra,0xffffa
    800065c4:	672080e7          	jalr	1650(ra) # 80000c32 <acquire>
    800065c8:	100017b7          	lui	a5,0x10001
    800065cc:	53b8                	lw	a4,96(a5)
    800065ce:	8b0d                	and	a4,a4,3
    800065d0:	100017b7          	lui	a5,0x10001
    800065d4:	d3f8                	sw	a4,100(a5)
    800065d6:	0ff0000f          	fence
    800065da:	0001f797          	auipc	a5,0x1f
    800065de:	a2678793          	add	a5,a5,-1498 # 80025000 <disk+0x2000>
    800065e2:	6b94                	ld	a3,16(a5)
    800065e4:	0207d703          	lhu	a4,32(a5)
    800065e8:	0026d783          	lhu	a5,2(a3)
    800065ec:	06f70563          	beq	a4,a5,80006656 <virtio_disk_intr+0xa6>
    800065f0:	e426                	sd	s1,8(sp)
    800065f2:	e04a                	sd	s2,0(sp)
    800065f4:	0001d917          	auipc	s2,0x1d
    800065f8:	a0c90913          	add	s2,s2,-1524 # 80023000 <disk>
    800065fc:	0001f497          	auipc	s1,0x1f
    80006600:	a0448493          	add	s1,s1,-1532 # 80025000 <disk+0x2000>
    80006604:	0ff0000f          	fence
    80006608:	6898                	ld	a4,16(s1)
    8000660a:	0204d783          	lhu	a5,32(s1)
    8000660e:	8b9d                	and	a5,a5,7
    80006610:	078e                	sll	a5,a5,0x3
    80006612:	97ba                	add	a5,a5,a4
    80006614:	43dc                	lw	a5,4(a5)
    80006616:	20078713          	add	a4,a5,512
    8000661a:	0712                	sll	a4,a4,0x4
    8000661c:	974a                	add	a4,a4,s2
    8000661e:	03074703          	lbu	a4,48(a4)
    80006622:	e731                	bnez	a4,8000666e <virtio_disk_intr+0xbe>
    80006624:	20078793          	add	a5,a5,512
    80006628:	0792                	sll	a5,a5,0x4
    8000662a:	97ca                	add	a5,a5,s2
    8000662c:	7788                	ld	a0,40(a5)
    8000662e:	00052223          	sw	zero,4(a0)
    80006632:	ffffc097          	auipc	ra,0xffffc
    80006636:	c62080e7          	jalr	-926(ra) # 80002294 <wakeup>
    8000663a:	0204d783          	lhu	a5,32(s1)
    8000663e:	2785                	addw	a5,a5,1
    80006640:	17c2                	sll	a5,a5,0x30
    80006642:	93c1                	srl	a5,a5,0x30
    80006644:	02f49023          	sh	a5,32(s1)
    80006648:	6898                	ld	a4,16(s1)
    8000664a:	00275703          	lhu	a4,2(a4)
    8000664e:	faf71be3          	bne	a4,a5,80006604 <virtio_disk_intr+0x54>
    80006652:	64a2                	ld	s1,8(sp)
    80006654:	6902                	ld	s2,0(sp)
    80006656:	0001f517          	auipc	a0,0x1f
    8000665a:	ad250513          	add	a0,a0,-1326 # 80025128 <disk+0x2128>
    8000665e:	ffffa097          	auipc	ra,0xffffa
    80006662:	688080e7          	jalr	1672(ra) # 80000ce6 <release>
    80006666:	60e2                	ld	ra,24(sp)
    80006668:	6442                	ld	s0,16(sp)
    8000666a:	6105                	add	sp,sp,32
    8000666c:	8082                	ret
    8000666e:	00002517          	auipc	a0,0x2
    80006672:	07250513          	add	a0,a0,114 # 800086e0 <etext+0x6e0>
    80006676:	ffffa097          	auipc	ra,0xffffa
    8000667a:	ee4080e7          	jalr	-284(ra) # 8000055a <panic>
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
