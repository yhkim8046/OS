
user/_sematest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int 
main()
{
   0:	1101                	add	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	add	s0,sp,32
	int i, pid;

	// initialize the semaphore
	sematest(0);
   c:	4501                	li	a0,0
   e:	00000097          	auipc	ra,0x0
  12:	3ba080e7          	jalr	954(ra) # 3c8 <sematest>

	for (i = 0; i < 10; i++) {
  16:	4481                	li	s1,0
  18:	4929                	li	s2,10
		pid = fork();
  1a:	00000097          	auipc	ra,0x0
  1e:	2fe080e7          	jalr	766(ra) # 318 <fork>

		if (!pid) 
  22:	c521                	beqz	a0,6a <main+0x6a>
	for (i = 0; i < 10; i++) {
  24:	2485                	addw	s1,s1,1
  26:	ff249ae3          	bne	s1,s2,1a <main+0x1a>
  2a:	44a9                	li	s1,10
	}
	
	if (pid) {
//		sleep(300);
		for (i = 0; i < 10; i++) 
			wait(0);
  2c:	4501                	li	a0,0
  2e:	00000097          	auipc	ra,0x0
  32:	2fa080e7          	jalr	762(ra) # 328 <wait>
		for (i = 0; i < 10; i++) 
  36:	34fd                	addw	s1,s1,-1
  38:	f8f5                	bnez	s1,2c <main+0x2c>
		
		sematest(1);
  3a:	4505                	li	a0,1
  3c:	00000097          	auipc	ra,0x0
  40:	38c080e7          	jalr	908(ra) # 3c8 <sematest>
		printf("Final %d\n", sematest(2));
  44:	4509                	li	a0,2
  46:	00000097          	auipc	ra,0x0
  4a:	382080e7          	jalr	898(ra) # 3c8 <sematest>
  4e:	85aa                	mv	a1,a0
  50:	00001517          	auipc	a0,0x1
  54:	80850513          	add	a0,a0,-2040 # 858 <malloc+0x100>
  58:	00000097          	auipc	ra,0x0
  5c:	648080e7          	jalr	1608(ra) # 6a0 <printf>
		printf("%d Down : %d\n", i, sematest(1));
		sleep(100);	
		printf("%d   Up : %d\n", i, sematest(2));
	}
	
	exit(0);
  60:	4501                	li	a0,0
  62:	00000097          	auipc	ra,0x0
  66:	2be080e7          	jalr	702(ra) # 320 <exit>
		printf("%d Down : %d\n", i, sematest(1));
  6a:	4505                	li	a0,1
  6c:	00000097          	auipc	ra,0x0
  70:	35c080e7          	jalr	860(ra) # 3c8 <sematest>
  74:	862a                	mv	a2,a0
  76:	85a6                	mv	a1,s1
  78:	00000517          	auipc	a0,0x0
  7c:	7f050513          	add	a0,a0,2032 # 868 <malloc+0x110>
  80:	00000097          	auipc	ra,0x0
  84:	620080e7          	jalr	1568(ra) # 6a0 <printf>
		sleep(100);	
  88:	06400513          	li	a0,100
  8c:	00000097          	auipc	ra,0x0
  90:	324080e7          	jalr	804(ra) # 3b0 <sleep>
		printf("%d   Up : %d\n", i, sematest(2));
  94:	4509                	li	a0,2
  96:	00000097          	auipc	ra,0x0
  9a:	332080e7          	jalr	818(ra) # 3c8 <sematest>
  9e:	862a                	mv	a2,a0
  a0:	85a6                	mv	a1,s1
  a2:	00000517          	auipc	a0,0x0
  a6:	7d650513          	add	a0,a0,2006 # 878 <malloc+0x120>
  aa:	00000097          	auipc	ra,0x0
  ae:	5f6080e7          	jalr	1526(ra) # 6a0 <printf>
  b2:	b77d                	j	60 <main+0x60>

00000000000000b4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  b4:	1141                	add	sp,sp,-16
  b6:	e422                	sd	s0,8(sp)
  b8:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ba:	87aa                	mv	a5,a0
  bc:	0585                	add	a1,a1,1
  be:	0785                	add	a5,a5,1
  c0:	fff5c703          	lbu	a4,-1(a1)
  c4:	fee78fa3          	sb	a4,-1(a5)
  c8:	fb75                	bnez	a4,bc <strcpy+0x8>
    ;
  return os;
}
  ca:	6422                	ld	s0,8(sp)
  cc:	0141                	add	sp,sp,16
  ce:	8082                	ret

00000000000000d0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d0:	1141                	add	sp,sp,-16
  d2:	e422                	sd	s0,8(sp)
  d4:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  d6:	00054783          	lbu	a5,0(a0)
  da:	cb91                	beqz	a5,ee <strcmp+0x1e>
  dc:	0005c703          	lbu	a4,0(a1)
  e0:	00f71763          	bne	a4,a5,ee <strcmp+0x1e>
    p++, q++;
  e4:	0505                	add	a0,a0,1
  e6:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  e8:	00054783          	lbu	a5,0(a0)
  ec:	fbe5                	bnez	a5,dc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  ee:	0005c503          	lbu	a0,0(a1)
}
  f2:	40a7853b          	subw	a0,a5,a0
  f6:	6422                	ld	s0,8(sp)
  f8:	0141                	add	sp,sp,16
  fa:	8082                	ret

00000000000000fc <strlen>:

uint
strlen(const char *s)
{
  fc:	1141                	add	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 102:	00054783          	lbu	a5,0(a0)
 106:	cf91                	beqz	a5,122 <strlen+0x26>
 108:	0505                	add	a0,a0,1
 10a:	87aa                	mv	a5,a0
 10c:	86be                	mv	a3,a5
 10e:	0785                	add	a5,a5,1
 110:	fff7c703          	lbu	a4,-1(a5)
 114:	ff65                	bnez	a4,10c <strlen+0x10>
 116:	40a6853b          	subw	a0,a3,a0
 11a:	2505                	addw	a0,a0,1
    ;
  return n;
}
 11c:	6422                	ld	s0,8(sp)
 11e:	0141                	add	sp,sp,16
 120:	8082                	ret
  for(n = 0; s[n]; n++)
 122:	4501                	li	a0,0
 124:	bfe5                	j	11c <strlen+0x20>

0000000000000126 <memset>:

void*
memset(void *dst, int c, uint n)
{
 126:	1141                	add	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 12c:	ca19                	beqz	a2,142 <memset+0x1c>
 12e:	87aa                	mv	a5,a0
 130:	1602                	sll	a2,a2,0x20
 132:	9201                	srl	a2,a2,0x20
 134:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 138:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 13c:	0785                	add	a5,a5,1
 13e:	fee79de3          	bne	a5,a4,138 <memset+0x12>
  }
  return dst;
}
 142:	6422                	ld	s0,8(sp)
 144:	0141                	add	sp,sp,16
 146:	8082                	ret

0000000000000148 <strchr>:

char*
strchr(const char *s, char c)
{
 148:	1141                	add	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	add	s0,sp,16
  for(; *s; s++)
 14e:	00054783          	lbu	a5,0(a0)
 152:	cb99                	beqz	a5,168 <strchr+0x20>
    if(*s == c)
 154:	00f58763          	beq	a1,a5,162 <strchr+0x1a>
  for(; *s; s++)
 158:	0505                	add	a0,a0,1
 15a:	00054783          	lbu	a5,0(a0)
 15e:	fbfd                	bnez	a5,154 <strchr+0xc>
      return (char*)s;
  return 0;
 160:	4501                	li	a0,0
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	add	sp,sp,16
 166:	8082                	ret
  return 0;
 168:	4501                	li	a0,0
 16a:	bfe5                	j	162 <strchr+0x1a>

000000000000016c <gets>:

char*
gets(char *buf, int max)
{
 16c:	711d                	add	sp,sp,-96
 16e:	ec86                	sd	ra,88(sp)
 170:	e8a2                	sd	s0,80(sp)
 172:	e4a6                	sd	s1,72(sp)
 174:	e0ca                	sd	s2,64(sp)
 176:	fc4e                	sd	s3,56(sp)
 178:	f852                	sd	s4,48(sp)
 17a:	f456                	sd	s5,40(sp)
 17c:	f05a                	sd	s6,32(sp)
 17e:	ec5e                	sd	s7,24(sp)
 180:	1080                	add	s0,sp,96
 182:	8baa                	mv	s7,a0
 184:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 186:	892a                	mv	s2,a0
 188:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 18a:	4aa9                	li	s5,10
 18c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 18e:	89a6                	mv	s3,s1
 190:	2485                	addw	s1,s1,1
 192:	0344d863          	bge	s1,s4,1c2 <gets+0x56>
    cc = read(0, &c, 1);
 196:	4605                	li	a2,1
 198:	faf40593          	add	a1,s0,-81
 19c:	4501                	li	a0,0
 19e:	00000097          	auipc	ra,0x0
 1a2:	19a080e7          	jalr	410(ra) # 338 <read>
    if(cc < 1)
 1a6:	00a05e63          	blez	a0,1c2 <gets+0x56>
    buf[i++] = c;
 1aa:	faf44783          	lbu	a5,-81(s0)
 1ae:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1b2:	01578763          	beq	a5,s5,1c0 <gets+0x54>
 1b6:	0905                	add	s2,s2,1
 1b8:	fd679be3          	bne	a5,s6,18e <gets+0x22>
    buf[i++] = c;
 1bc:	89a6                	mv	s3,s1
 1be:	a011                	j	1c2 <gets+0x56>
 1c0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c2:	99de                	add	s3,s3,s7
 1c4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1c8:	855e                	mv	a0,s7
 1ca:	60e6                	ld	ra,88(sp)
 1cc:	6446                	ld	s0,80(sp)
 1ce:	64a6                	ld	s1,72(sp)
 1d0:	6906                	ld	s2,64(sp)
 1d2:	79e2                	ld	s3,56(sp)
 1d4:	7a42                	ld	s4,48(sp)
 1d6:	7aa2                	ld	s5,40(sp)
 1d8:	7b02                	ld	s6,32(sp)
 1da:	6be2                	ld	s7,24(sp)
 1dc:	6125                	add	sp,sp,96
 1de:	8082                	ret

00000000000001e0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e0:	1101                	add	sp,sp,-32
 1e2:	ec06                	sd	ra,24(sp)
 1e4:	e822                	sd	s0,16(sp)
 1e6:	e04a                	sd	s2,0(sp)
 1e8:	1000                	add	s0,sp,32
 1ea:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ec:	4581                	li	a1,0
 1ee:	00000097          	auipc	ra,0x0
 1f2:	172080e7          	jalr	370(ra) # 360 <open>
  if(fd < 0)
 1f6:	02054663          	bltz	a0,222 <stat+0x42>
 1fa:	e426                	sd	s1,8(sp)
 1fc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1fe:	85ca                	mv	a1,s2
 200:	00000097          	auipc	ra,0x0
 204:	178080e7          	jalr	376(ra) # 378 <fstat>
 208:	892a                	mv	s2,a0
  close(fd);
 20a:	8526                	mv	a0,s1
 20c:	00000097          	auipc	ra,0x0
 210:	13c080e7          	jalr	316(ra) # 348 <close>
  return r;
 214:	64a2                	ld	s1,8(sp)
}
 216:	854a                	mv	a0,s2
 218:	60e2                	ld	ra,24(sp)
 21a:	6442                	ld	s0,16(sp)
 21c:	6902                	ld	s2,0(sp)
 21e:	6105                	add	sp,sp,32
 220:	8082                	ret
    return -1;
 222:	597d                	li	s2,-1
 224:	bfcd                	j	216 <stat+0x36>

0000000000000226 <atoi>:

int
atoi(const char *s)
{
 226:	1141                	add	sp,sp,-16
 228:	e422                	sd	s0,8(sp)
 22a:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 22c:	00054683          	lbu	a3,0(a0)
 230:	fd06879b          	addw	a5,a3,-48
 234:	0ff7f793          	zext.b	a5,a5
 238:	4625                	li	a2,9
 23a:	02f66863          	bltu	a2,a5,26a <atoi+0x44>
 23e:	872a                	mv	a4,a0
  n = 0;
 240:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 242:	0705                	add	a4,a4,1
 244:	0025179b          	sllw	a5,a0,0x2
 248:	9fa9                	addw	a5,a5,a0
 24a:	0017979b          	sllw	a5,a5,0x1
 24e:	9fb5                	addw	a5,a5,a3
 250:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 254:	00074683          	lbu	a3,0(a4)
 258:	fd06879b          	addw	a5,a3,-48
 25c:	0ff7f793          	zext.b	a5,a5
 260:	fef671e3          	bgeu	a2,a5,242 <atoi+0x1c>
  return n;
}
 264:	6422                	ld	s0,8(sp)
 266:	0141                	add	sp,sp,16
 268:	8082                	ret
  n = 0;
 26a:	4501                	li	a0,0
 26c:	bfe5                	j	264 <atoi+0x3e>

000000000000026e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 26e:	1141                	add	sp,sp,-16
 270:	e422                	sd	s0,8(sp)
 272:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 274:	02b57463          	bgeu	a0,a1,29c <memmove+0x2e>
    while(n-- > 0)
 278:	00c05f63          	blez	a2,296 <memmove+0x28>
 27c:	1602                	sll	a2,a2,0x20
 27e:	9201                	srl	a2,a2,0x20
 280:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 284:	872a                	mv	a4,a0
      *dst++ = *src++;
 286:	0585                	add	a1,a1,1
 288:	0705                	add	a4,a4,1
 28a:	fff5c683          	lbu	a3,-1(a1)
 28e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 292:	fef71ae3          	bne	a4,a5,286 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	add	sp,sp,16
 29a:	8082                	ret
    dst += n;
 29c:	00c50733          	add	a4,a0,a2
    src += n;
 2a0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2a2:	fec05ae3          	blez	a2,296 <memmove+0x28>
 2a6:	fff6079b          	addw	a5,a2,-1
 2aa:	1782                	sll	a5,a5,0x20
 2ac:	9381                	srl	a5,a5,0x20
 2ae:	fff7c793          	not	a5,a5
 2b2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b4:	15fd                	add	a1,a1,-1
 2b6:	177d                	add	a4,a4,-1
 2b8:	0005c683          	lbu	a3,0(a1)
 2bc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2c0:	fee79ae3          	bne	a5,a4,2b4 <memmove+0x46>
 2c4:	bfc9                	j	296 <memmove+0x28>

00000000000002c6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c6:	1141                	add	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2cc:	ca05                	beqz	a2,2fc <memcmp+0x36>
 2ce:	fff6069b          	addw	a3,a2,-1
 2d2:	1682                	sll	a3,a3,0x20
 2d4:	9281                	srl	a3,a3,0x20
 2d6:	0685                	add	a3,a3,1
 2d8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2da:	00054783          	lbu	a5,0(a0)
 2de:	0005c703          	lbu	a4,0(a1)
 2e2:	00e79863          	bne	a5,a4,2f2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2e6:	0505                	add	a0,a0,1
    p2++;
 2e8:	0585                	add	a1,a1,1
  while (n-- > 0) {
 2ea:	fed518e3          	bne	a0,a3,2da <memcmp+0x14>
  }
  return 0;
 2ee:	4501                	li	a0,0
 2f0:	a019                	j	2f6 <memcmp+0x30>
      return *p1 - *p2;
 2f2:	40e7853b          	subw	a0,a5,a4
}
 2f6:	6422                	ld	s0,8(sp)
 2f8:	0141                	add	sp,sp,16
 2fa:	8082                	ret
  return 0;
 2fc:	4501                	li	a0,0
 2fe:	bfe5                	j	2f6 <memcmp+0x30>

0000000000000300 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 300:	1141                	add	sp,sp,-16
 302:	e406                	sd	ra,8(sp)
 304:	e022                	sd	s0,0(sp)
 306:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 308:	00000097          	auipc	ra,0x0
 30c:	f66080e7          	jalr	-154(ra) # 26e <memmove>
}
 310:	60a2                	ld	ra,8(sp)
 312:	6402                	ld	s0,0(sp)
 314:	0141                	add	sp,sp,16
 316:	8082                	ret

0000000000000318 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 318:	4885                	li	a7,1
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <exit>:
.global exit
exit:
 li a7, SYS_exit
 320:	4889                	li	a7,2
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <wait>:
.global wait
wait:
 li a7, SYS_wait
 328:	488d                	li	a7,3
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 330:	4891                	li	a7,4
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <read>:
.global read
read:
 li a7, SYS_read
 338:	4895                	li	a7,5
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <write>:
.global write
write:
 li a7, SYS_write
 340:	48c1                	li	a7,16
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <close>:
.global close
close:
 li a7, SYS_close
 348:	48d5                	li	a7,21
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <kill>:
.global kill
kill:
 li a7, SYS_kill
 350:	4899                	li	a7,6
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <exec>:
.global exec
exec:
 li a7, SYS_exec
 358:	489d                	li	a7,7
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <open>:
.global open
open:
 li a7, SYS_open
 360:	48bd                	li	a7,15
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 368:	48c5                	li	a7,17
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 370:	48c9                	li	a7,18
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 378:	48a1                	li	a7,8
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <link>:
.global link
link:
 li a7, SYS_link
 380:	48cd                	li	a7,19
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 388:	48d1                	li	a7,20
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 390:	48a5                	li	a7,9
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <dup>:
.global dup
dup:
 li a7, SYS_dup
 398:	48a9                	li	a7,10
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3a0:	48ad                	li	a7,11
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3a8:	48b1                	li	a7,12
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3b0:	48b5                	li	a7,13
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b8:	48b9                	li	a7,14
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 3c0:	48d9                	li	a7,22
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <sematest>:
.global sematest
sematest:
 li a7, SYS_sematest
 3c8:	48dd                	li	a7,23
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <rwsematest>:
.global rwsematest
rwsematest:
 li a7, SYS_rwsematest
 3d0:	48e1                	li	a7,24
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3d8:	1101                	add	sp,sp,-32
 3da:	ec06                	sd	ra,24(sp)
 3dc:	e822                	sd	s0,16(sp)
 3de:	1000                	add	s0,sp,32
 3e0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3e4:	4605                	li	a2,1
 3e6:	fef40593          	add	a1,s0,-17
 3ea:	00000097          	auipc	ra,0x0
 3ee:	f56080e7          	jalr	-170(ra) # 340 <write>
}
 3f2:	60e2                	ld	ra,24(sp)
 3f4:	6442                	ld	s0,16(sp)
 3f6:	6105                	add	sp,sp,32
 3f8:	8082                	ret

00000000000003fa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3fa:	7139                	add	sp,sp,-64
 3fc:	fc06                	sd	ra,56(sp)
 3fe:	f822                	sd	s0,48(sp)
 400:	f426                	sd	s1,40(sp)
 402:	0080                	add	s0,sp,64
 404:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 406:	c299                	beqz	a3,40c <printint+0x12>
 408:	0805cb63          	bltz	a1,49e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 40c:	2581                	sext.w	a1,a1
  neg = 0;
 40e:	4881                	li	a7,0
 410:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 414:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 416:	2601                	sext.w	a2,a2
 418:	00000517          	auipc	a0,0x0
 41c:	4d050513          	add	a0,a0,1232 # 8e8 <digits>
 420:	883a                	mv	a6,a4
 422:	2705                	addw	a4,a4,1
 424:	02c5f7bb          	remuw	a5,a1,a2
 428:	1782                	sll	a5,a5,0x20
 42a:	9381                	srl	a5,a5,0x20
 42c:	97aa                	add	a5,a5,a0
 42e:	0007c783          	lbu	a5,0(a5)
 432:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 436:	0005879b          	sext.w	a5,a1
 43a:	02c5d5bb          	divuw	a1,a1,a2
 43e:	0685                	add	a3,a3,1
 440:	fec7f0e3          	bgeu	a5,a2,420 <printint+0x26>
  if(neg)
 444:	00088c63          	beqz	a7,45c <printint+0x62>
    buf[i++] = '-';
 448:	fd070793          	add	a5,a4,-48
 44c:	00878733          	add	a4,a5,s0
 450:	02d00793          	li	a5,45
 454:	fef70823          	sb	a5,-16(a4)
 458:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 45c:	02e05c63          	blez	a4,494 <printint+0x9a>
 460:	f04a                	sd	s2,32(sp)
 462:	ec4e                	sd	s3,24(sp)
 464:	fc040793          	add	a5,s0,-64
 468:	00e78933          	add	s2,a5,a4
 46c:	fff78993          	add	s3,a5,-1
 470:	99ba                	add	s3,s3,a4
 472:	377d                	addw	a4,a4,-1
 474:	1702                	sll	a4,a4,0x20
 476:	9301                	srl	a4,a4,0x20
 478:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 47c:	fff94583          	lbu	a1,-1(s2)
 480:	8526                	mv	a0,s1
 482:	00000097          	auipc	ra,0x0
 486:	f56080e7          	jalr	-170(ra) # 3d8 <putc>
  while(--i >= 0)
 48a:	197d                	add	s2,s2,-1
 48c:	ff3918e3          	bne	s2,s3,47c <printint+0x82>
 490:	7902                	ld	s2,32(sp)
 492:	69e2                	ld	s3,24(sp)
}
 494:	70e2                	ld	ra,56(sp)
 496:	7442                	ld	s0,48(sp)
 498:	74a2                	ld	s1,40(sp)
 49a:	6121                	add	sp,sp,64
 49c:	8082                	ret
    x = -xx;
 49e:	40b005bb          	negw	a1,a1
    neg = 1;
 4a2:	4885                	li	a7,1
    x = -xx;
 4a4:	b7b5                	j	410 <printint+0x16>

00000000000004a6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a6:	715d                	add	sp,sp,-80
 4a8:	e486                	sd	ra,72(sp)
 4aa:	e0a2                	sd	s0,64(sp)
 4ac:	f84a                	sd	s2,48(sp)
 4ae:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b0:	0005c903          	lbu	s2,0(a1)
 4b4:	1a090a63          	beqz	s2,668 <vprintf+0x1c2>
 4b8:	fc26                	sd	s1,56(sp)
 4ba:	f44e                	sd	s3,40(sp)
 4bc:	f052                	sd	s4,32(sp)
 4be:	ec56                	sd	s5,24(sp)
 4c0:	e85a                	sd	s6,16(sp)
 4c2:	e45e                	sd	s7,8(sp)
 4c4:	8aaa                	mv	s5,a0
 4c6:	8bb2                	mv	s7,a2
 4c8:	00158493          	add	s1,a1,1
  state = 0;
 4cc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4ce:	02500a13          	li	s4,37
 4d2:	4b55                	li	s6,21
 4d4:	a839                	j	4f2 <vprintf+0x4c>
        putc(fd, c);
 4d6:	85ca                	mv	a1,s2
 4d8:	8556                	mv	a0,s5
 4da:	00000097          	auipc	ra,0x0
 4de:	efe080e7          	jalr	-258(ra) # 3d8 <putc>
 4e2:	a019                	j	4e8 <vprintf+0x42>
    } else if(state == '%'){
 4e4:	01498d63          	beq	s3,s4,4fe <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4e8:	0485                	add	s1,s1,1
 4ea:	fff4c903          	lbu	s2,-1(s1)
 4ee:	16090763          	beqz	s2,65c <vprintf+0x1b6>
    if(state == 0){
 4f2:	fe0999e3          	bnez	s3,4e4 <vprintf+0x3e>
      if(c == '%'){
 4f6:	ff4910e3          	bne	s2,s4,4d6 <vprintf+0x30>
        state = '%';
 4fa:	89d2                	mv	s3,s4
 4fc:	b7f5                	j	4e8 <vprintf+0x42>
      if(c == 'd'){
 4fe:	13490463          	beq	s2,s4,626 <vprintf+0x180>
 502:	f9d9079b          	addw	a5,s2,-99
 506:	0ff7f793          	zext.b	a5,a5
 50a:	12fb6763          	bltu	s6,a5,638 <vprintf+0x192>
 50e:	f9d9079b          	addw	a5,s2,-99
 512:	0ff7f713          	zext.b	a4,a5
 516:	12eb6163          	bltu	s6,a4,638 <vprintf+0x192>
 51a:	00271793          	sll	a5,a4,0x2
 51e:	00000717          	auipc	a4,0x0
 522:	37270713          	add	a4,a4,882 # 890 <malloc+0x138>
 526:	97ba                	add	a5,a5,a4
 528:	439c                	lw	a5,0(a5)
 52a:	97ba                	add	a5,a5,a4
 52c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 52e:	008b8913          	add	s2,s7,8
 532:	4685                	li	a3,1
 534:	4629                	li	a2,10
 536:	000ba583          	lw	a1,0(s7)
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	ebe080e7          	jalr	-322(ra) # 3fa <printint>
 544:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 546:	4981                	li	s3,0
 548:	b745                	j	4e8 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 54a:	008b8913          	add	s2,s7,8
 54e:	4681                	li	a3,0
 550:	4629                	li	a2,10
 552:	000ba583          	lw	a1,0(s7)
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	ea2080e7          	jalr	-350(ra) # 3fa <printint>
 560:	8bca                	mv	s7,s2
      state = 0;
 562:	4981                	li	s3,0
 564:	b751                	j	4e8 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 566:	008b8913          	add	s2,s7,8
 56a:	4681                	li	a3,0
 56c:	4641                	li	a2,16
 56e:	000ba583          	lw	a1,0(s7)
 572:	8556                	mv	a0,s5
 574:	00000097          	auipc	ra,0x0
 578:	e86080e7          	jalr	-378(ra) # 3fa <printint>
 57c:	8bca                	mv	s7,s2
      state = 0;
 57e:	4981                	li	s3,0
 580:	b7a5                	j	4e8 <vprintf+0x42>
 582:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 584:	008b8c13          	add	s8,s7,8
 588:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 58c:	03000593          	li	a1,48
 590:	8556                	mv	a0,s5
 592:	00000097          	auipc	ra,0x0
 596:	e46080e7          	jalr	-442(ra) # 3d8 <putc>
  putc(fd, 'x');
 59a:	07800593          	li	a1,120
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	e38080e7          	jalr	-456(ra) # 3d8 <putc>
 5a8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5aa:	00000b97          	auipc	s7,0x0
 5ae:	33eb8b93          	add	s7,s7,830 # 8e8 <digits>
 5b2:	03c9d793          	srl	a5,s3,0x3c
 5b6:	97de                	add	a5,a5,s7
 5b8:	0007c583          	lbu	a1,0(a5)
 5bc:	8556                	mv	a0,s5
 5be:	00000097          	auipc	ra,0x0
 5c2:	e1a080e7          	jalr	-486(ra) # 3d8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5c6:	0992                	sll	s3,s3,0x4
 5c8:	397d                	addw	s2,s2,-1
 5ca:	fe0914e3          	bnez	s2,5b2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5ce:	8be2                	mv	s7,s8
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	6c02                	ld	s8,0(sp)
 5d4:	bf11                	j	4e8 <vprintf+0x42>
        s = va_arg(ap, char*);
 5d6:	008b8993          	add	s3,s7,8
 5da:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5de:	02090163          	beqz	s2,600 <vprintf+0x15a>
        while(*s != 0){
 5e2:	00094583          	lbu	a1,0(s2)
 5e6:	c9a5                	beqz	a1,656 <vprintf+0x1b0>
          putc(fd, *s);
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	dee080e7          	jalr	-530(ra) # 3d8 <putc>
          s++;
 5f2:	0905                	add	s2,s2,1
        while(*s != 0){
 5f4:	00094583          	lbu	a1,0(s2)
 5f8:	f9e5                	bnez	a1,5e8 <vprintf+0x142>
        s = va_arg(ap, char*);
 5fa:	8bce                	mv	s7,s3
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b5ed                	j	4e8 <vprintf+0x42>
          s = "(null)";
 600:	00000917          	auipc	s2,0x0
 604:	28890913          	add	s2,s2,648 # 888 <malloc+0x130>
        while(*s != 0){
 608:	02800593          	li	a1,40
 60c:	bff1                	j	5e8 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 60e:	008b8913          	add	s2,s7,8
 612:	000bc583          	lbu	a1,0(s7)
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	dc0080e7          	jalr	-576(ra) # 3d8 <putc>
 620:	8bca                	mv	s7,s2
      state = 0;
 622:	4981                	li	s3,0
 624:	b5d1                	j	4e8 <vprintf+0x42>
        putc(fd, c);
 626:	02500593          	li	a1,37
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	dac080e7          	jalr	-596(ra) # 3d8 <putc>
      state = 0;
 634:	4981                	li	s3,0
 636:	bd4d                	j	4e8 <vprintf+0x42>
        putc(fd, '%');
 638:	02500593          	li	a1,37
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	d9a080e7          	jalr	-614(ra) # 3d8 <putc>
        putc(fd, c);
 646:	85ca                	mv	a1,s2
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	d8e080e7          	jalr	-626(ra) # 3d8 <putc>
      state = 0;
 652:	4981                	li	s3,0
 654:	bd51                	j	4e8 <vprintf+0x42>
        s = va_arg(ap, char*);
 656:	8bce                	mv	s7,s3
      state = 0;
 658:	4981                	li	s3,0
 65a:	b579                	j	4e8 <vprintf+0x42>
 65c:	74e2                	ld	s1,56(sp)
 65e:	79a2                	ld	s3,40(sp)
 660:	7a02                	ld	s4,32(sp)
 662:	6ae2                	ld	s5,24(sp)
 664:	6b42                	ld	s6,16(sp)
 666:	6ba2                	ld	s7,8(sp)
    }
  }
}
 668:	60a6                	ld	ra,72(sp)
 66a:	6406                	ld	s0,64(sp)
 66c:	7942                	ld	s2,48(sp)
 66e:	6161                	add	sp,sp,80
 670:	8082                	ret

0000000000000672 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 672:	715d                	add	sp,sp,-80
 674:	ec06                	sd	ra,24(sp)
 676:	e822                	sd	s0,16(sp)
 678:	1000                	add	s0,sp,32
 67a:	e010                	sd	a2,0(s0)
 67c:	e414                	sd	a3,8(s0)
 67e:	e818                	sd	a4,16(s0)
 680:	ec1c                	sd	a5,24(s0)
 682:	03043023          	sd	a6,32(s0)
 686:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 68a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 68e:	8622                	mv	a2,s0
 690:	00000097          	auipc	ra,0x0
 694:	e16080e7          	jalr	-490(ra) # 4a6 <vprintf>
}
 698:	60e2                	ld	ra,24(sp)
 69a:	6442                	ld	s0,16(sp)
 69c:	6161                	add	sp,sp,80
 69e:	8082                	ret

00000000000006a0 <printf>:

void
printf(const char *fmt, ...)
{
 6a0:	711d                	add	sp,sp,-96
 6a2:	ec06                	sd	ra,24(sp)
 6a4:	e822                	sd	s0,16(sp)
 6a6:	1000                	add	s0,sp,32
 6a8:	e40c                	sd	a1,8(s0)
 6aa:	e810                	sd	a2,16(s0)
 6ac:	ec14                	sd	a3,24(s0)
 6ae:	f018                	sd	a4,32(s0)
 6b0:	f41c                	sd	a5,40(s0)
 6b2:	03043823          	sd	a6,48(s0)
 6b6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ba:	00840613          	add	a2,s0,8
 6be:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6c2:	85aa                	mv	a1,a0
 6c4:	4505                	li	a0,1
 6c6:	00000097          	auipc	ra,0x0
 6ca:	de0080e7          	jalr	-544(ra) # 4a6 <vprintf>
}
 6ce:	60e2                	ld	ra,24(sp)
 6d0:	6442                	ld	s0,16(sp)
 6d2:	6125                	add	sp,sp,96
 6d4:	8082                	ret

00000000000006d6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d6:	1141                	add	sp,sp,-16
 6d8:	e422                	sd	s0,8(sp)
 6da:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6dc:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e0:	00000797          	auipc	a5,0x0
 6e4:	2207b783          	ld	a5,544(a5) # 900 <freep>
 6e8:	a02d                	j	712 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ea:	4618                	lw	a4,8(a2)
 6ec:	9f2d                	addw	a4,a4,a1
 6ee:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f2:	6398                	ld	a4,0(a5)
 6f4:	6310                	ld	a2,0(a4)
 6f6:	a83d                	j	734 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6f8:	ff852703          	lw	a4,-8(a0)
 6fc:	9f31                	addw	a4,a4,a2
 6fe:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 700:	ff053683          	ld	a3,-16(a0)
 704:	a091                	j	748 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 706:	6398                	ld	a4,0(a5)
 708:	00e7e463          	bltu	a5,a4,710 <free+0x3a>
 70c:	00e6ea63          	bltu	a3,a4,720 <free+0x4a>
{
 710:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 712:	fed7fae3          	bgeu	a5,a3,706 <free+0x30>
 716:	6398                	ld	a4,0(a5)
 718:	00e6e463          	bltu	a3,a4,720 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 71c:	fee7eae3          	bltu	a5,a4,710 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 720:	ff852583          	lw	a1,-8(a0)
 724:	6390                	ld	a2,0(a5)
 726:	02059813          	sll	a6,a1,0x20
 72a:	01c85713          	srl	a4,a6,0x1c
 72e:	9736                	add	a4,a4,a3
 730:	fae60de3          	beq	a2,a4,6ea <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 734:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 738:	4790                	lw	a2,8(a5)
 73a:	02061593          	sll	a1,a2,0x20
 73e:	01c5d713          	srl	a4,a1,0x1c
 742:	973e                	add	a4,a4,a5
 744:	fae68ae3          	beq	a3,a4,6f8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 748:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 74a:	00000717          	auipc	a4,0x0
 74e:	1af73b23          	sd	a5,438(a4) # 900 <freep>
}
 752:	6422                	ld	s0,8(sp)
 754:	0141                	add	sp,sp,16
 756:	8082                	ret

0000000000000758 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 758:	7139                	add	sp,sp,-64
 75a:	fc06                	sd	ra,56(sp)
 75c:	f822                	sd	s0,48(sp)
 75e:	f426                	sd	s1,40(sp)
 760:	ec4e                	sd	s3,24(sp)
 762:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 764:	02051493          	sll	s1,a0,0x20
 768:	9081                	srl	s1,s1,0x20
 76a:	04bd                	add	s1,s1,15
 76c:	8091                	srl	s1,s1,0x4
 76e:	0014899b          	addw	s3,s1,1
 772:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 774:	00000517          	auipc	a0,0x0
 778:	18c53503          	ld	a0,396(a0) # 900 <freep>
 77c:	c915                	beqz	a0,7b0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 780:	4798                	lw	a4,8(a5)
 782:	08977e63          	bgeu	a4,s1,81e <malloc+0xc6>
 786:	f04a                	sd	s2,32(sp)
 788:	e852                	sd	s4,16(sp)
 78a:	e456                	sd	s5,8(sp)
 78c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 78e:	8a4e                	mv	s4,s3
 790:	0009871b          	sext.w	a4,s3
 794:	6685                	lui	a3,0x1
 796:	00d77363          	bgeu	a4,a3,79c <malloc+0x44>
 79a:	6a05                	lui	s4,0x1
 79c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7a0:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7a4:	00000917          	auipc	s2,0x0
 7a8:	15c90913          	add	s2,s2,348 # 900 <freep>
  if(p == (char*)-1)
 7ac:	5afd                	li	s5,-1
 7ae:	a091                	j	7f2 <malloc+0x9a>
 7b0:	f04a                	sd	s2,32(sp)
 7b2:	e852                	sd	s4,16(sp)
 7b4:	e456                	sd	s5,8(sp)
 7b6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7b8:	00000797          	auipc	a5,0x0
 7bc:	15078793          	add	a5,a5,336 # 908 <base>
 7c0:	00000717          	auipc	a4,0x0
 7c4:	14f73023          	sd	a5,320(a4) # 900 <freep>
 7c8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7ca:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ce:	b7c1                	j	78e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7d0:	6398                	ld	a4,0(a5)
 7d2:	e118                	sd	a4,0(a0)
 7d4:	a08d                	j	836 <malloc+0xde>
  hp->s.size = nu;
 7d6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7da:	0541                	add	a0,a0,16
 7dc:	00000097          	auipc	ra,0x0
 7e0:	efa080e7          	jalr	-262(ra) # 6d6 <free>
  return freep;
 7e4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7e8:	c13d                	beqz	a0,84e <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ec:	4798                	lw	a4,8(a5)
 7ee:	02977463          	bgeu	a4,s1,816 <malloc+0xbe>
    if(p == freep)
 7f2:	00093703          	ld	a4,0(s2)
 7f6:	853e                	mv	a0,a5
 7f8:	fef719e3          	bne	a4,a5,7ea <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7fc:	8552                	mv	a0,s4
 7fe:	00000097          	auipc	ra,0x0
 802:	baa080e7          	jalr	-1110(ra) # 3a8 <sbrk>
  if(p == (char*)-1)
 806:	fd5518e3          	bne	a0,s5,7d6 <malloc+0x7e>
        return 0;
 80a:	4501                	li	a0,0
 80c:	7902                	ld	s2,32(sp)
 80e:	6a42                	ld	s4,16(sp)
 810:	6aa2                	ld	s5,8(sp)
 812:	6b02                	ld	s6,0(sp)
 814:	a03d                	j	842 <malloc+0xea>
 816:	7902                	ld	s2,32(sp)
 818:	6a42                	ld	s4,16(sp)
 81a:	6aa2                	ld	s5,8(sp)
 81c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 81e:	fae489e3          	beq	s1,a4,7d0 <malloc+0x78>
        p->s.size -= nunits;
 822:	4137073b          	subw	a4,a4,s3
 826:	c798                	sw	a4,8(a5)
        p += p->s.size;
 828:	02071693          	sll	a3,a4,0x20
 82c:	01c6d713          	srl	a4,a3,0x1c
 830:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 832:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 836:	00000717          	auipc	a4,0x0
 83a:	0ca73523          	sd	a0,202(a4) # 900 <freep>
      return (void*)(p + 1);
 83e:	01078513          	add	a0,a5,16
  }
}
 842:	70e2                	ld	ra,56(sp)
 844:	7442                	ld	s0,48(sp)
 846:	74a2                	ld	s1,40(sp)
 848:	69e2                	ld	s3,24(sp)
 84a:	6121                	add	sp,sp,64
 84c:	8082                	ret
 84e:	7902                	ld	s2,32(sp)
 850:	6a42                	ld	s4,16(sp)
 852:	6aa2                	ld	s5,8(sp)
 854:	6b02                	ld	s6,0(sp)
 856:	b7f5                	j	842 <malloc+0xea>
