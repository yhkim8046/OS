
user/_rwsematest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <starttest>:
#include "kernel/types.h"
#include "user/user.h"

void
starttest(int count, void (*test)(int))
{
   0:	7179                	add	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	add	s0,sp,48
   e:	89ae                	mv	s3,a1
  int i,pid = 0;

  for(i = 0; i < count; i++) {
  10:	02a05d63          	blez	a0,4a <starttest+0x4a>
  14:	892a                	mv	s2,a0
  16:	4481                	li	s1,0
    pid = fork();
  18:	00000097          	auipc	ra,0x0
  1c:	4c6080e7          	jalr	1222(ra) # 4de <fork>
    if(!pid)
  20:	c515                	beqz	a0,4c <starttest+0x4c>
  for(i = 0; i < count; i++) {
  22:	2485                	addw	s1,s1,1
  24:	fe991ae3          	bne	s2,s1,18 <starttest+0x18>
      break;
  }

  if(pid) {
  28:	c90d                	beqz	a0,5a <starttest+0x5a>
    for(i = 0; i < count; i++) 
  2a:	4481                	li	s1,0
      wait(0);
  2c:	4501                	li	a0,0
  2e:	00000097          	auipc	ra,0x0
  32:	4c0080e7          	jalr	1216(ra) # 4ee <wait>
    for(i = 0; i < count; i++) 
  36:	2485                	addw	s1,s1,1
  38:	fe991ae3          	bne	s2,s1,2c <starttest+0x2c>
  }
  else {
    test(i);
    exit(0);
  }
}
  3c:	70a2                	ld	ra,40(sp)
  3e:	7402                	ld	s0,32(sp)
  40:	64e2                	ld	s1,24(sp)
  42:	6942                	ld	s2,16(sp)
  44:	69a2                	ld	s3,8(sp)
  46:	6145                	add	sp,sp,48
  48:	8082                	ret
  for(i = 0; i < count; i++) {
  4a:	4481                	li	s1,0
    test(i);
  4c:	8526                	mv	a0,s1
  4e:	9982                	jalr	s3
    exit(0);
  50:	4501                	li	a0,0
  52:	00000097          	auipc	ra,0x0
  56:	494080e7          	jalr	1172(ra) # 4e6 <exit>
  5a:	84ca                	mv	s1,s2
  5c:	bfc5                	j	4c <starttest+0x4c>

000000000000005e <readlocktest>:

void 
readlocktest(int time)
{
  5e:	1101                	add	sp,sp,-32
  60:	ec06                	sd	ra,24(sp)
  62:	e822                	sd	s0,16(sp)
  64:	e426                	sd	s1,8(sp)
  66:	1000                	add	s0,sp,32
  68:	84aa                	mv	s1,a0
  int r;
  r = rwsematest(1);
  6a:	4505                	li	a0,1
  6c:	00000097          	auipc	ra,0x0
  70:	52a080e7          	jalr	1322(ra) # 596 <rwsematest>
  74:	85aa                	mv	a1,a0
  printf ("RD %d\n", r);
  76:	00001517          	auipc	a0,0x1
  7a:	9aa50513          	add	a0,a0,-1622 # a20 <malloc+0x102>
  7e:	00000097          	auipc	ra,0x0
  82:	7e8080e7          	jalr	2024(ra) # 866 <printf>
  sleep(time);
  86:	8526                	mv	a0,s1
  88:	00000097          	auipc	ra,0x0
  8c:	4ee080e7          	jalr	1262(ra) # 576 <sleep>
  r = rwsematest(2);
  90:	4509                	li	a0,2
  92:	00000097          	auipc	ra,0x0
  96:	504080e7          	jalr	1284(ra) # 596 <rwsematest>
  9a:	85aa                	mv	a1,a0
  printf ("RU %d\n", r);
  9c:	00001517          	auipc	a0,0x1
  a0:	99450513          	add	a0,a0,-1644 # a30 <malloc+0x112>
  a4:	00000097          	auipc	ra,0x0
  a8:	7c2080e7          	jalr	1986(ra) # 866 <printf>
  sleep(time);
  ac:	8526                	mv	a0,s1
  ae:	00000097          	auipc	ra,0x0
  b2:	4c8080e7          	jalr	1224(ra) # 576 <sleep>
}
  b6:	60e2                	ld	ra,24(sp)
  b8:	6442                	ld	s0,16(sp)
  ba:	64a2                	ld	s1,8(sp)
  bc:	6105                	add	sp,sp,32
  be:	8082                	ret

00000000000000c0 <test1>:
  printf ("%d UW\n", i);
}

void
test1(int i)
{
  c0:	1141                	add	sp,sp,-16
  c2:	e406                	sd	ra,8(sp)
  c4:	e022                	sd	s0,0(sp)
  c6:	0800                	add	s0,sp,16
//  readlocktest(0);
  readlocktest((i+1)*10);
  c8:	2505                	addw	a0,a0,1
  ca:	0025179b          	sllw	a5,a0,0x2
  ce:	9d3d                	addw	a0,a0,a5
  d0:	0015151b          	sllw	a0,a0,0x1
  d4:	00000097          	auipc	ra,0x0
  d8:	f8a080e7          	jalr	-118(ra) # 5e <readlocktest>
}
  dc:	60a2                	ld	ra,8(sp)
  de:	6402                	ld	s0,0(sp)
  e0:	0141                	add	sp,sp,16
  e2:	8082                	ret

00000000000000e4 <writelocktest>:
{
  e4:	1101                	add	sp,sp,-32
  e6:	ec06                	sd	ra,24(sp)
  e8:	e822                	sd	s0,16(sp)
  ea:	e426                	sd	s1,8(sp)
  ec:	e04a                	sd	s2,0(sp)
  ee:	1000                	add	s0,sp,32
  f0:	84aa                	mv	s1,a0
  f2:	892e                	mv	s2,a1
  rwsematest(3);
  f4:	450d                	li	a0,3
  f6:	00000097          	auipc	ra,0x0
  fa:	4a0080e7          	jalr	1184(ra) # 596 <rwsematest>
  printf ("%d DW\n", i);
  fe:	85a6                	mv	a1,s1
 100:	00001517          	auipc	a0,0x1
 104:	93850513          	add	a0,a0,-1736 # a38 <malloc+0x11a>
 108:	00000097          	auipc	ra,0x0
 10c:	75e080e7          	jalr	1886(ra) # 866 <printf>
  sleep(time);
 110:	854a                	mv	a0,s2
 112:	00000097          	auipc	ra,0x0
 116:	464080e7          	jalr	1124(ra) # 576 <sleep>
  rwsematest(4);
 11a:	4511                	li	a0,4
 11c:	00000097          	auipc	ra,0x0
 120:	47a080e7          	jalr	1146(ra) # 596 <rwsematest>
  printf ("%d UW\n", i);
 124:	85a6                	mv	a1,s1
 126:	00001517          	auipc	a0,0x1
 12a:	91a50513          	add	a0,a0,-1766 # a40 <malloc+0x122>
 12e:	00000097          	auipc	ra,0x0
 132:	738080e7          	jalr	1848(ra) # 866 <printf>
}
 136:	60e2                	ld	ra,24(sp)
 138:	6442                	ld	s0,16(sp)
 13a:	64a2                	ld	s1,8(sp)
 13c:	6902                	ld	s2,0(sp)
 13e:	6105                	add	sp,sp,32
 140:	8082                	ret

0000000000000142 <test2>:

void
test2(int i)
{
 142:	1101                	add	sp,sp,-32
 144:	ec06                	sd	ra,24(sp)
 146:	e822                	sd	s0,16(sp)
 148:	e426                	sd	s1,8(sp)
 14a:	1000                	add	s0,sp,32
 14c:	84aa                	mv	s1,a0
  sleep((5-i)*10);
 14e:	4795                	li	a5,5
 150:	9f89                	subw	a5,a5,a0
 152:	0027951b          	sllw	a0,a5,0x2
 156:	9d3d                	addw	a0,a0,a5
 158:	0015151b          	sllw	a0,a0,0x1
 15c:	00000097          	auipc	ra,0x0
 160:	41a080e7          	jalr	1050(ra) # 576 <sleep>
  writelocktest(i, (i+2)*10);
 164:	0024879b          	addw	a5,s1,2
 168:	0027959b          	sllw	a1,a5,0x2
 16c:	9dbd                	addw	a1,a1,a5
 16e:	0015959b          	sllw	a1,a1,0x1
 172:	8526                	mv	a0,s1
 174:	00000097          	auipc	ra,0x0
 178:	f70080e7          	jalr	-144(ra) # e4 <writelocktest>
}
 17c:	60e2                	ld	ra,24(sp)
 17e:	6442                	ld	s0,16(sp)
 180:	64a2                	ld	s1,8(sp)
 182:	6105                	add	sp,sp,32
 184:	8082                	ret

0000000000000186 <test3>:

void 
test3(int i)
{
 186:	1101                	add	sp,sp,-32
 188:	ec06                	sd	ra,24(sp)
 18a:	e822                	sd	s0,16(sp)
 18c:	e426                	sd	s1,8(sp)
 18e:	1000                	add	s0,sp,32
 190:	84aa                	mv	s1,a0
  switch (i) {
 192:	4789                	li	a5,2
 194:	02a7c263          	blt	a5,a0,1b8 <test3+0x32>
 198:	02a04663          	bgtz	a0,1c4 <test3+0x3e>
 19c:	e929                	bnez	a0,1ee <test3+0x68>
    case 0: 
      sleep(10);
 19e:	4529                	li	a0,10
 1a0:	00000097          	auipc	ra,0x0
 1a4:	3d6080e7          	jalr	982(ra) # 576 <sleep>
      writelocktest(i, 50);
 1a8:	03200593          	li	a1,50
 1ac:	4501                	li	a0,0
 1ae:	00000097          	auipc	ra,0x0
 1b2:	f36080e7          	jalr	-202(ra) # e4 <writelocktest>
      break;
 1b6:	a825                	j	1ee <test3+0x68>
  switch (i) {
 1b8:	ffd5079b          	addw	a5,a0,-3
 1bc:	4705                	li	a4,1
 1be:	00f77d63          	bgeu	a4,a5,1d8 <test3+0x52>
 1c2:	a035                	j	1ee <test3+0x68>
    case 1:
    case 2:
      sleep(25 + i*10);
 1c4:	0025151b          	sllw	a0,a0,0x2
 1c8:	9d25                	addw	a0,a0,s1
 1ca:	0015151b          	sllw	a0,a0,0x1
 1ce:	2565                	addw	a0,a0,25
 1d0:	00000097          	auipc	ra,0x0
 1d4:	3a6080e7          	jalr	934(ra) # 576 <sleep>
    case 3:
    case 4:
      readlocktest(50 + i*10);
 1d8:	0024951b          	sllw	a0,s1,0x2
 1dc:	9d25                	addw	a0,a0,s1
 1de:	0015151b          	sllw	a0,a0,0x1
 1e2:	0325051b          	addw	a0,a0,50
 1e6:	00000097          	auipc	ra,0x0
 1ea:	e78080e7          	jalr	-392(ra) # 5e <readlocktest>
  }
}
 1ee:	60e2                	ld	ra,24(sp)
 1f0:	6442                	ld	s0,16(sp)
 1f2:	64a2                	ld	s1,8(sp)
 1f4:	6105                	add	sp,sp,32
 1f6:	8082                	ret

00000000000001f8 <main>:
		
int 
main()
{
 1f8:	1141                	add	sp,sp,-16
 1fa:	e406                	sd	ra,8(sp)
 1fc:	e022                	sd	s0,0(sp)
 1fe:	0800                	add	s0,sp,16
  // initialize the semaphore
  rwsematest(0);
 200:	4501                	li	a0,0
 202:	00000097          	auipc	ra,0x0
 206:	394080e7          	jalr	916(ra) # 596 <rwsematest>

  printf("\nread lock test\n");
 20a:	00001517          	auipc	a0,0x1
 20e:	83e50513          	add	a0,a0,-1986 # a48 <malloc+0x12a>
 212:	00000097          	auipc	ra,0x0
 216:	654080e7          	jalr	1620(ra) # 866 <printf>
  starttest(5, test1);
 21a:	00000597          	auipc	a1,0x0
 21e:	ea658593          	add	a1,a1,-346 # c0 <test1>
 222:	4515                	li	a0,5
 224:	00000097          	auipc	ra,0x0
 228:	ddc080e7          	jalr	-548(ra) # 0 <starttest>
  printf("\nwrite lock test\n");
 22c:	00001517          	auipc	a0,0x1
 230:	83450513          	add	a0,a0,-1996 # a60 <malloc+0x142>
 234:	00000097          	auipc	ra,0x0
 238:	632080e7          	jalr	1586(ra) # 866 <printf>
  starttest(5, test2);
 23c:	00000597          	auipc	a1,0x0
 240:	f0658593          	add	a1,a1,-250 # 142 <test2>
 244:	4515                	li	a0,5
 246:	00000097          	auipc	ra,0x0
 24a:	dba080e7          	jalr	-582(ra) # 0 <starttest>

  printf("\nread & write lock test\n");
 24e:	00001517          	auipc	a0,0x1
 252:	82a50513          	add	a0,a0,-2006 # a78 <malloc+0x15a>
 256:	00000097          	auipc	ra,0x0
 25a:	610080e7          	jalr	1552(ra) # 866 <printf>
  starttest(5, test3);
 25e:	00000597          	auipc	a1,0x0
 262:	f2858593          	add	a1,a1,-216 # 186 <test3>
 266:	4515                	li	a0,5
 268:	00000097          	auipc	ra,0x0
 26c:	d98080e7          	jalr	-616(ra) # 0 <starttest>

  exit(0);
 270:	4501                	li	a0,0
 272:	00000097          	auipc	ra,0x0
 276:	274080e7          	jalr	628(ra) # 4e6 <exit>

000000000000027a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 27a:	1141                	add	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 280:	87aa                	mv	a5,a0
 282:	0585                	add	a1,a1,1
 284:	0785                	add	a5,a5,1
 286:	fff5c703          	lbu	a4,-1(a1)
 28a:	fee78fa3          	sb	a4,-1(a5)
 28e:	fb75                	bnez	a4,282 <strcpy+0x8>
    ;
  return os;
}
 290:	6422                	ld	s0,8(sp)
 292:	0141                	add	sp,sp,16
 294:	8082                	ret

0000000000000296 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 296:	1141                	add	sp,sp,-16
 298:	e422                	sd	s0,8(sp)
 29a:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 29c:	00054783          	lbu	a5,0(a0)
 2a0:	cb91                	beqz	a5,2b4 <strcmp+0x1e>
 2a2:	0005c703          	lbu	a4,0(a1)
 2a6:	00f71763          	bne	a4,a5,2b4 <strcmp+0x1e>
    p++, q++;
 2aa:	0505                	add	a0,a0,1
 2ac:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 2ae:	00054783          	lbu	a5,0(a0)
 2b2:	fbe5                	bnez	a5,2a2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b4:	0005c503          	lbu	a0,0(a1)
}
 2b8:	40a7853b          	subw	a0,a5,a0
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	add	sp,sp,16
 2c0:	8082                	ret

00000000000002c2 <strlen>:

uint
strlen(const char *s)
{
 2c2:	1141                	add	sp,sp,-16
 2c4:	e422                	sd	s0,8(sp)
 2c6:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2c8:	00054783          	lbu	a5,0(a0)
 2cc:	cf91                	beqz	a5,2e8 <strlen+0x26>
 2ce:	0505                	add	a0,a0,1
 2d0:	87aa                	mv	a5,a0
 2d2:	86be                	mv	a3,a5
 2d4:	0785                	add	a5,a5,1
 2d6:	fff7c703          	lbu	a4,-1(a5)
 2da:	ff65                	bnez	a4,2d2 <strlen+0x10>
 2dc:	40a6853b          	subw	a0,a3,a0
 2e0:	2505                	addw	a0,a0,1
    ;
  return n;
}
 2e2:	6422                	ld	s0,8(sp)
 2e4:	0141                	add	sp,sp,16
 2e6:	8082                	ret
  for(n = 0; s[n]; n++)
 2e8:	4501                	li	a0,0
 2ea:	bfe5                	j	2e2 <strlen+0x20>

00000000000002ec <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ec:	1141                	add	sp,sp,-16
 2ee:	e422                	sd	s0,8(sp)
 2f0:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f2:	ca19                	beqz	a2,308 <memset+0x1c>
 2f4:	87aa                	mv	a5,a0
 2f6:	1602                	sll	a2,a2,0x20
 2f8:	9201                	srl	a2,a2,0x20
 2fa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2fe:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 302:	0785                	add	a5,a5,1
 304:	fee79de3          	bne	a5,a4,2fe <memset+0x12>
  }
  return dst;
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	add	sp,sp,16
 30c:	8082                	ret

000000000000030e <strchr>:

char*
strchr(const char *s, char c)
{
 30e:	1141                	add	sp,sp,-16
 310:	e422                	sd	s0,8(sp)
 312:	0800                	add	s0,sp,16
  for(; *s; s++)
 314:	00054783          	lbu	a5,0(a0)
 318:	cb99                	beqz	a5,32e <strchr+0x20>
    if(*s == c)
 31a:	00f58763          	beq	a1,a5,328 <strchr+0x1a>
  for(; *s; s++)
 31e:	0505                	add	a0,a0,1
 320:	00054783          	lbu	a5,0(a0)
 324:	fbfd                	bnez	a5,31a <strchr+0xc>
      return (char*)s;
  return 0;
 326:	4501                	li	a0,0
}
 328:	6422                	ld	s0,8(sp)
 32a:	0141                	add	sp,sp,16
 32c:	8082                	ret
  return 0;
 32e:	4501                	li	a0,0
 330:	bfe5                	j	328 <strchr+0x1a>

0000000000000332 <gets>:

char*
gets(char *buf, int max)
{
 332:	711d                	add	sp,sp,-96
 334:	ec86                	sd	ra,88(sp)
 336:	e8a2                	sd	s0,80(sp)
 338:	e4a6                	sd	s1,72(sp)
 33a:	e0ca                	sd	s2,64(sp)
 33c:	fc4e                	sd	s3,56(sp)
 33e:	f852                	sd	s4,48(sp)
 340:	f456                	sd	s5,40(sp)
 342:	f05a                	sd	s6,32(sp)
 344:	ec5e                	sd	s7,24(sp)
 346:	1080                	add	s0,sp,96
 348:	8baa                	mv	s7,a0
 34a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34c:	892a                	mv	s2,a0
 34e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 350:	4aa9                	li	s5,10
 352:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 354:	89a6                	mv	s3,s1
 356:	2485                	addw	s1,s1,1
 358:	0344d863          	bge	s1,s4,388 <gets+0x56>
    cc = read(0, &c, 1);
 35c:	4605                	li	a2,1
 35e:	faf40593          	add	a1,s0,-81
 362:	4501                	li	a0,0
 364:	00000097          	auipc	ra,0x0
 368:	19a080e7          	jalr	410(ra) # 4fe <read>
    if(cc < 1)
 36c:	00a05e63          	blez	a0,388 <gets+0x56>
    buf[i++] = c;
 370:	faf44783          	lbu	a5,-81(s0)
 374:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 378:	01578763          	beq	a5,s5,386 <gets+0x54>
 37c:	0905                	add	s2,s2,1
 37e:	fd679be3          	bne	a5,s6,354 <gets+0x22>
    buf[i++] = c;
 382:	89a6                	mv	s3,s1
 384:	a011                	j	388 <gets+0x56>
 386:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 388:	99de                	add	s3,s3,s7
 38a:	00098023          	sb	zero,0(s3)
  return buf;
}
 38e:	855e                	mv	a0,s7
 390:	60e6                	ld	ra,88(sp)
 392:	6446                	ld	s0,80(sp)
 394:	64a6                	ld	s1,72(sp)
 396:	6906                	ld	s2,64(sp)
 398:	79e2                	ld	s3,56(sp)
 39a:	7a42                	ld	s4,48(sp)
 39c:	7aa2                	ld	s5,40(sp)
 39e:	7b02                	ld	s6,32(sp)
 3a0:	6be2                	ld	s7,24(sp)
 3a2:	6125                	add	sp,sp,96
 3a4:	8082                	ret

00000000000003a6 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a6:	1101                	add	sp,sp,-32
 3a8:	ec06                	sd	ra,24(sp)
 3aa:	e822                	sd	s0,16(sp)
 3ac:	e04a                	sd	s2,0(sp)
 3ae:	1000                	add	s0,sp,32
 3b0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b2:	4581                	li	a1,0
 3b4:	00000097          	auipc	ra,0x0
 3b8:	172080e7          	jalr	370(ra) # 526 <open>
  if(fd < 0)
 3bc:	02054663          	bltz	a0,3e8 <stat+0x42>
 3c0:	e426                	sd	s1,8(sp)
 3c2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3c4:	85ca                	mv	a1,s2
 3c6:	00000097          	auipc	ra,0x0
 3ca:	178080e7          	jalr	376(ra) # 53e <fstat>
 3ce:	892a                	mv	s2,a0
  close(fd);
 3d0:	8526                	mv	a0,s1
 3d2:	00000097          	auipc	ra,0x0
 3d6:	13c080e7          	jalr	316(ra) # 50e <close>
  return r;
 3da:	64a2                	ld	s1,8(sp)
}
 3dc:	854a                	mv	a0,s2
 3de:	60e2                	ld	ra,24(sp)
 3e0:	6442                	ld	s0,16(sp)
 3e2:	6902                	ld	s2,0(sp)
 3e4:	6105                	add	sp,sp,32
 3e6:	8082                	ret
    return -1;
 3e8:	597d                	li	s2,-1
 3ea:	bfcd                	j	3dc <stat+0x36>

00000000000003ec <atoi>:

int
atoi(const char *s)
{
 3ec:	1141                	add	sp,sp,-16
 3ee:	e422                	sd	s0,8(sp)
 3f0:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3f2:	00054683          	lbu	a3,0(a0)
 3f6:	fd06879b          	addw	a5,a3,-48
 3fa:	0ff7f793          	zext.b	a5,a5
 3fe:	4625                	li	a2,9
 400:	02f66863          	bltu	a2,a5,430 <atoi+0x44>
 404:	872a                	mv	a4,a0
  n = 0;
 406:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 408:	0705                	add	a4,a4,1
 40a:	0025179b          	sllw	a5,a0,0x2
 40e:	9fa9                	addw	a5,a5,a0
 410:	0017979b          	sllw	a5,a5,0x1
 414:	9fb5                	addw	a5,a5,a3
 416:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 41a:	00074683          	lbu	a3,0(a4)
 41e:	fd06879b          	addw	a5,a3,-48
 422:	0ff7f793          	zext.b	a5,a5
 426:	fef671e3          	bgeu	a2,a5,408 <atoi+0x1c>
  return n;
}
 42a:	6422                	ld	s0,8(sp)
 42c:	0141                	add	sp,sp,16
 42e:	8082                	ret
  n = 0;
 430:	4501                	li	a0,0
 432:	bfe5                	j	42a <atoi+0x3e>

0000000000000434 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 434:	1141                	add	sp,sp,-16
 436:	e422                	sd	s0,8(sp)
 438:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 43a:	02b57463          	bgeu	a0,a1,462 <memmove+0x2e>
    while(n-- > 0)
 43e:	00c05f63          	blez	a2,45c <memmove+0x28>
 442:	1602                	sll	a2,a2,0x20
 444:	9201                	srl	a2,a2,0x20
 446:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 44a:	872a                	mv	a4,a0
      *dst++ = *src++;
 44c:	0585                	add	a1,a1,1
 44e:	0705                	add	a4,a4,1
 450:	fff5c683          	lbu	a3,-1(a1)
 454:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 458:	fef71ae3          	bne	a4,a5,44c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 45c:	6422                	ld	s0,8(sp)
 45e:	0141                	add	sp,sp,16
 460:	8082                	ret
    dst += n;
 462:	00c50733          	add	a4,a0,a2
    src += n;
 466:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 468:	fec05ae3          	blez	a2,45c <memmove+0x28>
 46c:	fff6079b          	addw	a5,a2,-1
 470:	1782                	sll	a5,a5,0x20
 472:	9381                	srl	a5,a5,0x20
 474:	fff7c793          	not	a5,a5
 478:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 47a:	15fd                	add	a1,a1,-1
 47c:	177d                	add	a4,a4,-1
 47e:	0005c683          	lbu	a3,0(a1)
 482:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 486:	fee79ae3          	bne	a5,a4,47a <memmove+0x46>
 48a:	bfc9                	j	45c <memmove+0x28>

000000000000048c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 48c:	1141                	add	sp,sp,-16
 48e:	e422                	sd	s0,8(sp)
 490:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 492:	ca05                	beqz	a2,4c2 <memcmp+0x36>
 494:	fff6069b          	addw	a3,a2,-1
 498:	1682                	sll	a3,a3,0x20
 49a:	9281                	srl	a3,a3,0x20
 49c:	0685                	add	a3,a3,1
 49e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4a0:	00054783          	lbu	a5,0(a0)
 4a4:	0005c703          	lbu	a4,0(a1)
 4a8:	00e79863          	bne	a5,a4,4b8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4ac:	0505                	add	a0,a0,1
    p2++;
 4ae:	0585                	add	a1,a1,1
  while (n-- > 0) {
 4b0:	fed518e3          	bne	a0,a3,4a0 <memcmp+0x14>
  }
  return 0;
 4b4:	4501                	li	a0,0
 4b6:	a019                	j	4bc <memcmp+0x30>
      return *p1 - *p2;
 4b8:	40e7853b          	subw	a0,a5,a4
}
 4bc:	6422                	ld	s0,8(sp)
 4be:	0141                	add	sp,sp,16
 4c0:	8082                	ret
  return 0;
 4c2:	4501                	li	a0,0
 4c4:	bfe5                	j	4bc <memcmp+0x30>

00000000000004c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4c6:	1141                	add	sp,sp,-16
 4c8:	e406                	sd	ra,8(sp)
 4ca:	e022                	sd	s0,0(sp)
 4cc:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 4ce:	00000097          	auipc	ra,0x0
 4d2:	f66080e7          	jalr	-154(ra) # 434 <memmove>
}
 4d6:	60a2                	ld	ra,8(sp)
 4d8:	6402                	ld	s0,0(sp)
 4da:	0141                	add	sp,sp,16
 4dc:	8082                	ret

00000000000004de <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4de:	4885                	li	a7,1
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4e6:	4889                	li	a7,2
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <wait>:
.global wait
wait:
 li a7, SYS_wait
 4ee:	488d                	li	a7,3
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4f6:	4891                	li	a7,4
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <read>:
.global read
read:
 li a7, SYS_read
 4fe:	4895                	li	a7,5
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <write>:
.global write
write:
 li a7, SYS_write
 506:	48c1                	li	a7,16
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <close>:
.global close
close:
 li a7, SYS_close
 50e:	48d5                	li	a7,21
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <kill>:
.global kill
kill:
 li a7, SYS_kill
 516:	4899                	li	a7,6
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <exec>:
.global exec
exec:
 li a7, SYS_exec
 51e:	489d                	li	a7,7
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <open>:
.global open
open:
 li a7, SYS_open
 526:	48bd                	li	a7,15
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 52e:	48c5                	li	a7,17
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 536:	48c9                	li	a7,18
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 53e:	48a1                	li	a7,8
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <link>:
.global link
link:
 li a7, SYS_link
 546:	48cd                	li	a7,19
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 54e:	48d1                	li	a7,20
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 556:	48a5                	li	a7,9
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <dup>:
.global dup
dup:
 li a7, SYS_dup
 55e:	48a9                	li	a7,10
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 566:	48ad                	li	a7,11
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 56e:	48b1                	li	a7,12
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 576:	48b5                	li	a7,13
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 57e:	48b9                	li	a7,14
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 586:	48d9                	li	a7,22
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <sematest>:
.global sematest
sematest:
 li a7, SYS_sematest
 58e:	48dd                	li	a7,23
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <rwsematest>:
.global rwsematest
rwsematest:
 li a7, SYS_rwsematest
 596:	48e1                	li	a7,24
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 59e:	1101                	add	sp,sp,-32
 5a0:	ec06                	sd	ra,24(sp)
 5a2:	e822                	sd	s0,16(sp)
 5a4:	1000                	add	s0,sp,32
 5a6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5aa:	4605                	li	a2,1
 5ac:	fef40593          	add	a1,s0,-17
 5b0:	00000097          	auipc	ra,0x0
 5b4:	f56080e7          	jalr	-170(ra) # 506 <write>
}
 5b8:	60e2                	ld	ra,24(sp)
 5ba:	6442                	ld	s0,16(sp)
 5bc:	6105                	add	sp,sp,32
 5be:	8082                	ret

00000000000005c0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5c0:	7139                	add	sp,sp,-64
 5c2:	fc06                	sd	ra,56(sp)
 5c4:	f822                	sd	s0,48(sp)
 5c6:	f426                	sd	s1,40(sp)
 5c8:	0080                	add	s0,sp,64
 5ca:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5cc:	c299                	beqz	a3,5d2 <printint+0x12>
 5ce:	0805cb63          	bltz	a1,664 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5d2:	2581                	sext.w	a1,a1
  neg = 0;
 5d4:	4881                	li	a7,0
 5d6:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 5da:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5dc:	2601                	sext.w	a2,a2
 5de:	00000517          	auipc	a0,0x0
 5e2:	51a50513          	add	a0,a0,1306 # af8 <digits>
 5e6:	883a                	mv	a6,a4
 5e8:	2705                	addw	a4,a4,1
 5ea:	02c5f7bb          	remuw	a5,a1,a2
 5ee:	1782                	sll	a5,a5,0x20
 5f0:	9381                	srl	a5,a5,0x20
 5f2:	97aa                	add	a5,a5,a0
 5f4:	0007c783          	lbu	a5,0(a5)
 5f8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5fc:	0005879b          	sext.w	a5,a1
 600:	02c5d5bb          	divuw	a1,a1,a2
 604:	0685                	add	a3,a3,1
 606:	fec7f0e3          	bgeu	a5,a2,5e6 <printint+0x26>
  if(neg)
 60a:	00088c63          	beqz	a7,622 <printint+0x62>
    buf[i++] = '-';
 60e:	fd070793          	add	a5,a4,-48
 612:	00878733          	add	a4,a5,s0
 616:	02d00793          	li	a5,45
 61a:	fef70823          	sb	a5,-16(a4)
 61e:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 622:	02e05c63          	blez	a4,65a <printint+0x9a>
 626:	f04a                	sd	s2,32(sp)
 628:	ec4e                	sd	s3,24(sp)
 62a:	fc040793          	add	a5,s0,-64
 62e:	00e78933          	add	s2,a5,a4
 632:	fff78993          	add	s3,a5,-1
 636:	99ba                	add	s3,s3,a4
 638:	377d                	addw	a4,a4,-1
 63a:	1702                	sll	a4,a4,0x20
 63c:	9301                	srl	a4,a4,0x20
 63e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 642:	fff94583          	lbu	a1,-1(s2)
 646:	8526                	mv	a0,s1
 648:	00000097          	auipc	ra,0x0
 64c:	f56080e7          	jalr	-170(ra) # 59e <putc>
  while(--i >= 0)
 650:	197d                	add	s2,s2,-1
 652:	ff3918e3          	bne	s2,s3,642 <printint+0x82>
 656:	7902                	ld	s2,32(sp)
 658:	69e2                	ld	s3,24(sp)
}
 65a:	70e2                	ld	ra,56(sp)
 65c:	7442                	ld	s0,48(sp)
 65e:	74a2                	ld	s1,40(sp)
 660:	6121                	add	sp,sp,64
 662:	8082                	ret
    x = -xx;
 664:	40b005bb          	negw	a1,a1
    neg = 1;
 668:	4885                	li	a7,1
    x = -xx;
 66a:	b7b5                	j	5d6 <printint+0x16>

000000000000066c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 66c:	715d                	add	sp,sp,-80
 66e:	e486                	sd	ra,72(sp)
 670:	e0a2                	sd	s0,64(sp)
 672:	f84a                	sd	s2,48(sp)
 674:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 676:	0005c903          	lbu	s2,0(a1)
 67a:	1a090a63          	beqz	s2,82e <vprintf+0x1c2>
 67e:	fc26                	sd	s1,56(sp)
 680:	f44e                	sd	s3,40(sp)
 682:	f052                	sd	s4,32(sp)
 684:	ec56                	sd	s5,24(sp)
 686:	e85a                	sd	s6,16(sp)
 688:	e45e                	sd	s7,8(sp)
 68a:	8aaa                	mv	s5,a0
 68c:	8bb2                	mv	s7,a2
 68e:	00158493          	add	s1,a1,1
  state = 0;
 692:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 694:	02500a13          	li	s4,37
 698:	4b55                	li	s6,21
 69a:	a839                	j	6b8 <vprintf+0x4c>
        putc(fd, c);
 69c:	85ca                	mv	a1,s2
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	efe080e7          	jalr	-258(ra) # 59e <putc>
 6a8:	a019                	j	6ae <vprintf+0x42>
    } else if(state == '%'){
 6aa:	01498d63          	beq	s3,s4,6c4 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 6ae:	0485                	add	s1,s1,1
 6b0:	fff4c903          	lbu	s2,-1(s1)
 6b4:	16090763          	beqz	s2,822 <vprintf+0x1b6>
    if(state == 0){
 6b8:	fe0999e3          	bnez	s3,6aa <vprintf+0x3e>
      if(c == '%'){
 6bc:	ff4910e3          	bne	s2,s4,69c <vprintf+0x30>
        state = '%';
 6c0:	89d2                	mv	s3,s4
 6c2:	b7f5                	j	6ae <vprintf+0x42>
      if(c == 'd'){
 6c4:	13490463          	beq	s2,s4,7ec <vprintf+0x180>
 6c8:	f9d9079b          	addw	a5,s2,-99
 6cc:	0ff7f793          	zext.b	a5,a5
 6d0:	12fb6763          	bltu	s6,a5,7fe <vprintf+0x192>
 6d4:	f9d9079b          	addw	a5,s2,-99
 6d8:	0ff7f713          	zext.b	a4,a5
 6dc:	12eb6163          	bltu	s6,a4,7fe <vprintf+0x192>
 6e0:	00271793          	sll	a5,a4,0x2
 6e4:	00000717          	auipc	a4,0x0
 6e8:	3bc70713          	add	a4,a4,956 # aa0 <malloc+0x182>
 6ec:	97ba                	add	a5,a5,a4
 6ee:	439c                	lw	a5,0(a5)
 6f0:	97ba                	add	a5,a5,a4
 6f2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6f4:	008b8913          	add	s2,s7,8
 6f8:	4685                	li	a3,1
 6fa:	4629                	li	a2,10
 6fc:	000ba583          	lw	a1,0(s7)
 700:	8556                	mv	a0,s5
 702:	00000097          	auipc	ra,0x0
 706:	ebe080e7          	jalr	-322(ra) # 5c0 <printint>
 70a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b745                	j	6ae <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 710:	008b8913          	add	s2,s7,8
 714:	4681                	li	a3,0
 716:	4629                	li	a2,10
 718:	000ba583          	lw	a1,0(s7)
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	ea2080e7          	jalr	-350(ra) # 5c0 <printint>
 726:	8bca                	mv	s7,s2
      state = 0;
 728:	4981                	li	s3,0
 72a:	b751                	j	6ae <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 72c:	008b8913          	add	s2,s7,8
 730:	4681                	li	a3,0
 732:	4641                	li	a2,16
 734:	000ba583          	lw	a1,0(s7)
 738:	8556                	mv	a0,s5
 73a:	00000097          	auipc	ra,0x0
 73e:	e86080e7          	jalr	-378(ra) # 5c0 <printint>
 742:	8bca                	mv	s7,s2
      state = 0;
 744:	4981                	li	s3,0
 746:	b7a5                	j	6ae <vprintf+0x42>
 748:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 74a:	008b8c13          	add	s8,s7,8
 74e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 752:	03000593          	li	a1,48
 756:	8556                	mv	a0,s5
 758:	00000097          	auipc	ra,0x0
 75c:	e46080e7          	jalr	-442(ra) # 59e <putc>
  putc(fd, 'x');
 760:	07800593          	li	a1,120
 764:	8556                	mv	a0,s5
 766:	00000097          	auipc	ra,0x0
 76a:	e38080e7          	jalr	-456(ra) # 59e <putc>
 76e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 770:	00000b97          	auipc	s7,0x0
 774:	388b8b93          	add	s7,s7,904 # af8 <digits>
 778:	03c9d793          	srl	a5,s3,0x3c
 77c:	97de                	add	a5,a5,s7
 77e:	0007c583          	lbu	a1,0(a5)
 782:	8556                	mv	a0,s5
 784:	00000097          	auipc	ra,0x0
 788:	e1a080e7          	jalr	-486(ra) # 59e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 78c:	0992                	sll	s3,s3,0x4
 78e:	397d                	addw	s2,s2,-1
 790:	fe0914e3          	bnez	s2,778 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 794:	8be2                	mv	s7,s8
      state = 0;
 796:	4981                	li	s3,0
 798:	6c02                	ld	s8,0(sp)
 79a:	bf11                	j	6ae <vprintf+0x42>
        s = va_arg(ap, char*);
 79c:	008b8993          	add	s3,s7,8
 7a0:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 7a4:	02090163          	beqz	s2,7c6 <vprintf+0x15a>
        while(*s != 0){
 7a8:	00094583          	lbu	a1,0(s2)
 7ac:	c9a5                	beqz	a1,81c <vprintf+0x1b0>
          putc(fd, *s);
 7ae:	8556                	mv	a0,s5
 7b0:	00000097          	auipc	ra,0x0
 7b4:	dee080e7          	jalr	-530(ra) # 59e <putc>
          s++;
 7b8:	0905                	add	s2,s2,1
        while(*s != 0){
 7ba:	00094583          	lbu	a1,0(s2)
 7be:	f9e5                	bnez	a1,7ae <vprintf+0x142>
        s = va_arg(ap, char*);
 7c0:	8bce                	mv	s7,s3
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	b5ed                	j	6ae <vprintf+0x42>
          s = "(null)";
 7c6:	00000917          	auipc	s2,0x0
 7ca:	2d290913          	add	s2,s2,722 # a98 <malloc+0x17a>
        while(*s != 0){
 7ce:	02800593          	li	a1,40
 7d2:	bff1                	j	7ae <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 7d4:	008b8913          	add	s2,s7,8
 7d8:	000bc583          	lbu	a1,0(s7)
 7dc:	8556                	mv	a0,s5
 7de:	00000097          	auipc	ra,0x0
 7e2:	dc0080e7          	jalr	-576(ra) # 59e <putc>
 7e6:	8bca                	mv	s7,s2
      state = 0;
 7e8:	4981                	li	s3,0
 7ea:	b5d1                	j	6ae <vprintf+0x42>
        putc(fd, c);
 7ec:	02500593          	li	a1,37
 7f0:	8556                	mv	a0,s5
 7f2:	00000097          	auipc	ra,0x0
 7f6:	dac080e7          	jalr	-596(ra) # 59e <putc>
      state = 0;
 7fa:	4981                	li	s3,0
 7fc:	bd4d                	j	6ae <vprintf+0x42>
        putc(fd, '%');
 7fe:	02500593          	li	a1,37
 802:	8556                	mv	a0,s5
 804:	00000097          	auipc	ra,0x0
 808:	d9a080e7          	jalr	-614(ra) # 59e <putc>
        putc(fd, c);
 80c:	85ca                	mv	a1,s2
 80e:	8556                	mv	a0,s5
 810:	00000097          	auipc	ra,0x0
 814:	d8e080e7          	jalr	-626(ra) # 59e <putc>
      state = 0;
 818:	4981                	li	s3,0
 81a:	bd51                	j	6ae <vprintf+0x42>
        s = va_arg(ap, char*);
 81c:	8bce                	mv	s7,s3
      state = 0;
 81e:	4981                	li	s3,0
 820:	b579                	j	6ae <vprintf+0x42>
 822:	74e2                	ld	s1,56(sp)
 824:	79a2                	ld	s3,40(sp)
 826:	7a02                	ld	s4,32(sp)
 828:	6ae2                	ld	s5,24(sp)
 82a:	6b42                	ld	s6,16(sp)
 82c:	6ba2                	ld	s7,8(sp)
    }
  }
}
 82e:	60a6                	ld	ra,72(sp)
 830:	6406                	ld	s0,64(sp)
 832:	7942                	ld	s2,48(sp)
 834:	6161                	add	sp,sp,80
 836:	8082                	ret

0000000000000838 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 838:	715d                	add	sp,sp,-80
 83a:	ec06                	sd	ra,24(sp)
 83c:	e822                	sd	s0,16(sp)
 83e:	1000                	add	s0,sp,32
 840:	e010                	sd	a2,0(s0)
 842:	e414                	sd	a3,8(s0)
 844:	e818                	sd	a4,16(s0)
 846:	ec1c                	sd	a5,24(s0)
 848:	03043023          	sd	a6,32(s0)
 84c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 850:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 854:	8622                	mv	a2,s0
 856:	00000097          	auipc	ra,0x0
 85a:	e16080e7          	jalr	-490(ra) # 66c <vprintf>
}
 85e:	60e2                	ld	ra,24(sp)
 860:	6442                	ld	s0,16(sp)
 862:	6161                	add	sp,sp,80
 864:	8082                	ret

0000000000000866 <printf>:

void
printf(const char *fmt, ...)
{
 866:	711d                	add	sp,sp,-96
 868:	ec06                	sd	ra,24(sp)
 86a:	e822                	sd	s0,16(sp)
 86c:	1000                	add	s0,sp,32
 86e:	e40c                	sd	a1,8(s0)
 870:	e810                	sd	a2,16(s0)
 872:	ec14                	sd	a3,24(s0)
 874:	f018                	sd	a4,32(s0)
 876:	f41c                	sd	a5,40(s0)
 878:	03043823          	sd	a6,48(s0)
 87c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 880:	00840613          	add	a2,s0,8
 884:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 888:	85aa                	mv	a1,a0
 88a:	4505                	li	a0,1
 88c:	00000097          	auipc	ra,0x0
 890:	de0080e7          	jalr	-544(ra) # 66c <vprintf>
}
 894:	60e2                	ld	ra,24(sp)
 896:	6442                	ld	s0,16(sp)
 898:	6125                	add	sp,sp,96
 89a:	8082                	ret

000000000000089c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 89c:	1141                	add	sp,sp,-16
 89e:	e422                	sd	s0,8(sp)
 8a0:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8a2:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8a6:	00000797          	auipc	a5,0x0
 8aa:	26a7b783          	ld	a5,618(a5) # b10 <freep>
 8ae:	a02d                	j	8d8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8b0:	4618                	lw	a4,8(a2)
 8b2:	9f2d                	addw	a4,a4,a1
 8b4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8b8:	6398                	ld	a4,0(a5)
 8ba:	6310                	ld	a2,0(a4)
 8bc:	a83d                	j	8fa <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8be:	ff852703          	lw	a4,-8(a0)
 8c2:	9f31                	addw	a4,a4,a2
 8c4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8c6:	ff053683          	ld	a3,-16(a0)
 8ca:	a091                	j	90e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8cc:	6398                	ld	a4,0(a5)
 8ce:	00e7e463          	bltu	a5,a4,8d6 <free+0x3a>
 8d2:	00e6ea63          	bltu	a3,a4,8e6 <free+0x4a>
{
 8d6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d8:	fed7fae3          	bgeu	a5,a3,8cc <free+0x30>
 8dc:	6398                	ld	a4,0(a5)
 8de:	00e6e463          	bltu	a3,a4,8e6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e2:	fee7eae3          	bltu	a5,a4,8d6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8e6:	ff852583          	lw	a1,-8(a0)
 8ea:	6390                	ld	a2,0(a5)
 8ec:	02059813          	sll	a6,a1,0x20
 8f0:	01c85713          	srl	a4,a6,0x1c
 8f4:	9736                	add	a4,a4,a3
 8f6:	fae60de3          	beq	a2,a4,8b0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8fa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8fe:	4790                	lw	a2,8(a5)
 900:	02061593          	sll	a1,a2,0x20
 904:	01c5d713          	srl	a4,a1,0x1c
 908:	973e                	add	a4,a4,a5
 90a:	fae68ae3          	beq	a3,a4,8be <free+0x22>
    p->s.ptr = bp->s.ptr;
 90e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 910:	00000717          	auipc	a4,0x0
 914:	20f73023          	sd	a5,512(a4) # b10 <freep>
}
 918:	6422                	ld	s0,8(sp)
 91a:	0141                	add	sp,sp,16
 91c:	8082                	ret

000000000000091e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 91e:	7139                	add	sp,sp,-64
 920:	fc06                	sd	ra,56(sp)
 922:	f822                	sd	s0,48(sp)
 924:	f426                	sd	s1,40(sp)
 926:	ec4e                	sd	s3,24(sp)
 928:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 92a:	02051493          	sll	s1,a0,0x20
 92e:	9081                	srl	s1,s1,0x20
 930:	04bd                	add	s1,s1,15
 932:	8091                	srl	s1,s1,0x4
 934:	0014899b          	addw	s3,s1,1
 938:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 93a:	00000517          	auipc	a0,0x0
 93e:	1d653503          	ld	a0,470(a0) # b10 <freep>
 942:	c915                	beqz	a0,976 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 944:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 946:	4798                	lw	a4,8(a5)
 948:	08977e63          	bgeu	a4,s1,9e4 <malloc+0xc6>
 94c:	f04a                	sd	s2,32(sp)
 94e:	e852                	sd	s4,16(sp)
 950:	e456                	sd	s5,8(sp)
 952:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 954:	8a4e                	mv	s4,s3
 956:	0009871b          	sext.w	a4,s3
 95a:	6685                	lui	a3,0x1
 95c:	00d77363          	bgeu	a4,a3,962 <malloc+0x44>
 960:	6a05                	lui	s4,0x1
 962:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 966:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 96a:	00000917          	auipc	s2,0x0
 96e:	1a690913          	add	s2,s2,422 # b10 <freep>
  if(p == (char*)-1)
 972:	5afd                	li	s5,-1
 974:	a091                	j	9b8 <malloc+0x9a>
 976:	f04a                	sd	s2,32(sp)
 978:	e852                	sd	s4,16(sp)
 97a:	e456                	sd	s5,8(sp)
 97c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 97e:	00000797          	auipc	a5,0x0
 982:	19a78793          	add	a5,a5,410 # b18 <base>
 986:	00000717          	auipc	a4,0x0
 98a:	18f73523          	sd	a5,394(a4) # b10 <freep>
 98e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 990:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 994:	b7c1                	j	954 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 996:	6398                	ld	a4,0(a5)
 998:	e118                	sd	a4,0(a0)
 99a:	a08d                	j	9fc <malloc+0xde>
  hp->s.size = nu;
 99c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9a0:	0541                	add	a0,a0,16
 9a2:	00000097          	auipc	ra,0x0
 9a6:	efa080e7          	jalr	-262(ra) # 89c <free>
  return freep;
 9aa:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9ae:	c13d                	beqz	a0,a14 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9b2:	4798                	lw	a4,8(a5)
 9b4:	02977463          	bgeu	a4,s1,9dc <malloc+0xbe>
    if(p == freep)
 9b8:	00093703          	ld	a4,0(s2)
 9bc:	853e                	mv	a0,a5
 9be:	fef719e3          	bne	a4,a5,9b0 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 9c2:	8552                	mv	a0,s4
 9c4:	00000097          	auipc	ra,0x0
 9c8:	baa080e7          	jalr	-1110(ra) # 56e <sbrk>
  if(p == (char*)-1)
 9cc:	fd5518e3          	bne	a0,s5,99c <malloc+0x7e>
        return 0;
 9d0:	4501                	li	a0,0
 9d2:	7902                	ld	s2,32(sp)
 9d4:	6a42                	ld	s4,16(sp)
 9d6:	6aa2                	ld	s5,8(sp)
 9d8:	6b02                	ld	s6,0(sp)
 9da:	a03d                	j	a08 <malloc+0xea>
 9dc:	7902                	ld	s2,32(sp)
 9de:	6a42                	ld	s4,16(sp)
 9e0:	6aa2                	ld	s5,8(sp)
 9e2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9e4:	fae489e3          	beq	s1,a4,996 <malloc+0x78>
        p->s.size -= nunits;
 9e8:	4137073b          	subw	a4,a4,s3
 9ec:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9ee:	02071693          	sll	a3,a4,0x20
 9f2:	01c6d713          	srl	a4,a3,0x1c
 9f6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9f8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9fc:	00000717          	auipc	a4,0x0
 a00:	10a73a23          	sd	a0,276(a4) # b10 <freep>
      return (void*)(p + 1);
 a04:	01078513          	add	a0,a5,16
  }
}
 a08:	70e2                	ld	ra,56(sp)
 a0a:	7442                	ld	s0,48(sp)
 a0c:	74a2                	ld	s1,40(sp)
 a0e:	69e2                	ld	s3,24(sp)
 a10:	6121                	add	sp,sp,64
 a12:	8082                	ret
 a14:	7902                	ld	s2,32(sp)
 a16:	6a42                	ld	s4,16(sp)
 a18:	6aa2                	ld	s5,8(sp)
 a1a:	6b02                	ld	s6,0(sp)
 a1c:	b7f5                	j	a08 <malloc+0xea>
