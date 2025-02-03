
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	add	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	add	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	286080e7          	jalr	646(ra) # 28e <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  exit(0);
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	280080e7          	jalr	640(ra) # 296 <exit>
    sleep(5);  // Let child exit before parent.
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	306080e7          	jalr	774(ra) # 326 <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  2a:	1141                	add	sp,sp,-16
  2c:	e422                	sd	s0,8(sp)
  2e:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  30:	87aa                	mv	a5,a0
  32:	0585                	add	a1,a1,1
  34:	0785                	add	a5,a5,1
  36:	fff5c703          	lbu	a4,-1(a1)
  3a:	fee78fa3          	sb	a4,-1(a5)
  3e:	fb75                	bnez	a4,32 <strcpy+0x8>
    ;
  return os;
}
  40:	6422                	ld	s0,8(sp)
  42:	0141                	add	sp,sp,16
  44:	8082                	ret

0000000000000046 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  46:	1141                	add	sp,sp,-16
  48:	e422                	sd	s0,8(sp)
  4a:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  4c:	00054783          	lbu	a5,0(a0)
  50:	cb91                	beqz	a5,64 <strcmp+0x1e>
  52:	0005c703          	lbu	a4,0(a1)
  56:	00f71763          	bne	a4,a5,64 <strcmp+0x1e>
    p++, q++;
  5a:	0505                	add	a0,a0,1
  5c:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  5e:	00054783          	lbu	a5,0(a0)
  62:	fbe5                	bnez	a5,52 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  64:	0005c503          	lbu	a0,0(a1)
}
  68:	40a7853b          	subw	a0,a5,a0
  6c:	6422                	ld	s0,8(sp)
  6e:	0141                	add	sp,sp,16
  70:	8082                	ret

0000000000000072 <strlen>:

uint
strlen(const char *s)
{
  72:	1141                	add	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  78:	00054783          	lbu	a5,0(a0)
  7c:	cf91                	beqz	a5,98 <strlen+0x26>
  7e:	0505                	add	a0,a0,1
  80:	87aa                	mv	a5,a0
  82:	86be                	mv	a3,a5
  84:	0785                	add	a5,a5,1
  86:	fff7c703          	lbu	a4,-1(a5)
  8a:	ff65                	bnez	a4,82 <strlen+0x10>
  8c:	40a6853b          	subw	a0,a3,a0
  90:	2505                	addw	a0,a0,1
    ;
  return n;
}
  92:	6422                	ld	s0,8(sp)
  94:	0141                	add	sp,sp,16
  96:	8082                	ret
  for(n = 0; s[n]; n++)
  98:	4501                	li	a0,0
  9a:	bfe5                	j	92 <strlen+0x20>

000000000000009c <memset>:

void*
memset(void *dst, int c, uint n)
{
  9c:	1141                	add	sp,sp,-16
  9e:	e422                	sd	s0,8(sp)
  a0:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a2:	ca19                	beqz	a2,b8 <memset+0x1c>
  a4:	87aa                	mv	a5,a0
  a6:	1602                	sll	a2,a2,0x20
  a8:	9201                	srl	a2,a2,0x20
  aa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ae:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b2:	0785                	add	a5,a5,1
  b4:	fee79de3          	bne	a5,a4,ae <memset+0x12>
  }
  return dst;
}
  b8:	6422                	ld	s0,8(sp)
  ba:	0141                	add	sp,sp,16
  bc:	8082                	ret

00000000000000be <strchr>:

char*
strchr(const char *s, char c)
{
  be:	1141                	add	sp,sp,-16
  c0:	e422                	sd	s0,8(sp)
  c2:	0800                	add	s0,sp,16
  for(; *s; s++)
  c4:	00054783          	lbu	a5,0(a0)
  c8:	cb99                	beqz	a5,de <strchr+0x20>
    if(*s == c)
  ca:	00f58763          	beq	a1,a5,d8 <strchr+0x1a>
  for(; *s; s++)
  ce:	0505                	add	a0,a0,1
  d0:	00054783          	lbu	a5,0(a0)
  d4:	fbfd                	bnez	a5,ca <strchr+0xc>
      return (char*)s;
  return 0;
  d6:	4501                	li	a0,0
}
  d8:	6422                	ld	s0,8(sp)
  da:	0141                	add	sp,sp,16
  dc:	8082                	ret
  return 0;
  de:	4501                	li	a0,0
  e0:	bfe5                	j	d8 <strchr+0x1a>

00000000000000e2 <gets>:

char*
gets(char *buf, int max)
{
  e2:	711d                	add	sp,sp,-96
  e4:	ec86                	sd	ra,88(sp)
  e6:	e8a2                	sd	s0,80(sp)
  e8:	e4a6                	sd	s1,72(sp)
  ea:	e0ca                	sd	s2,64(sp)
  ec:	fc4e                	sd	s3,56(sp)
  ee:	f852                	sd	s4,48(sp)
  f0:	f456                	sd	s5,40(sp)
  f2:	f05a                	sd	s6,32(sp)
  f4:	ec5e                	sd	s7,24(sp)
  f6:	1080                	add	s0,sp,96
  f8:	8baa                	mv	s7,a0
  fa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  fc:	892a                	mv	s2,a0
  fe:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 100:	4aa9                	li	s5,10
 102:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 104:	89a6                	mv	s3,s1
 106:	2485                	addw	s1,s1,1
 108:	0344d863          	bge	s1,s4,138 <gets+0x56>
    cc = read(0, &c, 1);
 10c:	4605                	li	a2,1
 10e:	faf40593          	add	a1,s0,-81
 112:	4501                	li	a0,0
 114:	00000097          	auipc	ra,0x0
 118:	19a080e7          	jalr	410(ra) # 2ae <read>
    if(cc < 1)
 11c:	00a05e63          	blez	a0,138 <gets+0x56>
    buf[i++] = c;
 120:	faf44783          	lbu	a5,-81(s0)
 124:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 128:	01578763          	beq	a5,s5,136 <gets+0x54>
 12c:	0905                	add	s2,s2,1
 12e:	fd679be3          	bne	a5,s6,104 <gets+0x22>
    buf[i++] = c;
 132:	89a6                	mv	s3,s1
 134:	a011                	j	138 <gets+0x56>
 136:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 138:	99de                	add	s3,s3,s7
 13a:	00098023          	sb	zero,0(s3)
  return buf;
}
 13e:	855e                	mv	a0,s7
 140:	60e6                	ld	ra,88(sp)
 142:	6446                	ld	s0,80(sp)
 144:	64a6                	ld	s1,72(sp)
 146:	6906                	ld	s2,64(sp)
 148:	79e2                	ld	s3,56(sp)
 14a:	7a42                	ld	s4,48(sp)
 14c:	7aa2                	ld	s5,40(sp)
 14e:	7b02                	ld	s6,32(sp)
 150:	6be2                	ld	s7,24(sp)
 152:	6125                	add	sp,sp,96
 154:	8082                	ret

0000000000000156 <stat>:

int
stat(const char *n, struct stat *st)
{
 156:	1101                	add	sp,sp,-32
 158:	ec06                	sd	ra,24(sp)
 15a:	e822                	sd	s0,16(sp)
 15c:	e04a                	sd	s2,0(sp)
 15e:	1000                	add	s0,sp,32
 160:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 162:	4581                	li	a1,0
 164:	00000097          	auipc	ra,0x0
 168:	172080e7          	jalr	370(ra) # 2d6 <open>
  if(fd < 0)
 16c:	02054663          	bltz	a0,198 <stat+0x42>
 170:	e426                	sd	s1,8(sp)
 172:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 174:	85ca                	mv	a1,s2
 176:	00000097          	auipc	ra,0x0
 17a:	178080e7          	jalr	376(ra) # 2ee <fstat>
 17e:	892a                	mv	s2,a0
  close(fd);
 180:	8526                	mv	a0,s1
 182:	00000097          	auipc	ra,0x0
 186:	13c080e7          	jalr	316(ra) # 2be <close>
  return r;
 18a:	64a2                	ld	s1,8(sp)
}
 18c:	854a                	mv	a0,s2
 18e:	60e2                	ld	ra,24(sp)
 190:	6442                	ld	s0,16(sp)
 192:	6902                	ld	s2,0(sp)
 194:	6105                	add	sp,sp,32
 196:	8082                	ret
    return -1;
 198:	597d                	li	s2,-1
 19a:	bfcd                	j	18c <stat+0x36>

000000000000019c <atoi>:

int
atoi(const char *s)
{
 19c:	1141                	add	sp,sp,-16
 19e:	e422                	sd	s0,8(sp)
 1a0:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1a2:	00054683          	lbu	a3,0(a0)
 1a6:	fd06879b          	addw	a5,a3,-48
 1aa:	0ff7f793          	zext.b	a5,a5
 1ae:	4625                	li	a2,9
 1b0:	02f66863          	bltu	a2,a5,1e0 <atoi+0x44>
 1b4:	872a                	mv	a4,a0
  n = 0;
 1b6:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1b8:	0705                	add	a4,a4,1
 1ba:	0025179b          	sllw	a5,a0,0x2
 1be:	9fa9                	addw	a5,a5,a0
 1c0:	0017979b          	sllw	a5,a5,0x1
 1c4:	9fb5                	addw	a5,a5,a3
 1c6:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1ca:	00074683          	lbu	a3,0(a4)
 1ce:	fd06879b          	addw	a5,a3,-48
 1d2:	0ff7f793          	zext.b	a5,a5
 1d6:	fef671e3          	bgeu	a2,a5,1b8 <atoi+0x1c>
  return n;
}
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	add	sp,sp,16
 1de:	8082                	ret
  n = 0;
 1e0:	4501                	li	a0,0
 1e2:	bfe5                	j	1da <atoi+0x3e>

00000000000001e4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e4:	1141                	add	sp,sp,-16
 1e6:	e422                	sd	s0,8(sp)
 1e8:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1ea:	02b57463          	bgeu	a0,a1,212 <memmove+0x2e>
    while(n-- > 0)
 1ee:	00c05f63          	blez	a2,20c <memmove+0x28>
 1f2:	1602                	sll	a2,a2,0x20
 1f4:	9201                	srl	a2,a2,0x20
 1f6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1fa:	872a                	mv	a4,a0
      *dst++ = *src++;
 1fc:	0585                	add	a1,a1,1
 1fe:	0705                	add	a4,a4,1
 200:	fff5c683          	lbu	a3,-1(a1)
 204:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 208:	fef71ae3          	bne	a4,a5,1fc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 20c:	6422                	ld	s0,8(sp)
 20e:	0141                	add	sp,sp,16
 210:	8082                	ret
    dst += n;
 212:	00c50733          	add	a4,a0,a2
    src += n;
 216:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 218:	fec05ae3          	blez	a2,20c <memmove+0x28>
 21c:	fff6079b          	addw	a5,a2,-1
 220:	1782                	sll	a5,a5,0x20
 222:	9381                	srl	a5,a5,0x20
 224:	fff7c793          	not	a5,a5
 228:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 22a:	15fd                	add	a1,a1,-1
 22c:	177d                	add	a4,a4,-1
 22e:	0005c683          	lbu	a3,0(a1)
 232:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 236:	fee79ae3          	bne	a5,a4,22a <memmove+0x46>
 23a:	bfc9                	j	20c <memmove+0x28>

000000000000023c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 23c:	1141                	add	sp,sp,-16
 23e:	e422                	sd	s0,8(sp)
 240:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 242:	ca05                	beqz	a2,272 <memcmp+0x36>
 244:	fff6069b          	addw	a3,a2,-1
 248:	1682                	sll	a3,a3,0x20
 24a:	9281                	srl	a3,a3,0x20
 24c:	0685                	add	a3,a3,1
 24e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 250:	00054783          	lbu	a5,0(a0)
 254:	0005c703          	lbu	a4,0(a1)
 258:	00e79863          	bne	a5,a4,268 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 25c:	0505                	add	a0,a0,1
    p2++;
 25e:	0585                	add	a1,a1,1
  while (n-- > 0) {
 260:	fed518e3          	bne	a0,a3,250 <memcmp+0x14>
  }
  return 0;
 264:	4501                	li	a0,0
 266:	a019                	j	26c <memcmp+0x30>
      return *p1 - *p2;
 268:	40e7853b          	subw	a0,a5,a4
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	add	sp,sp,16
 270:	8082                	ret
  return 0;
 272:	4501                	li	a0,0
 274:	bfe5                	j	26c <memcmp+0x30>

0000000000000276 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 276:	1141                	add	sp,sp,-16
 278:	e406                	sd	ra,8(sp)
 27a:	e022                	sd	s0,0(sp)
 27c:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 27e:	00000097          	auipc	ra,0x0
 282:	f66080e7          	jalr	-154(ra) # 1e4 <memmove>
}
 286:	60a2                	ld	ra,8(sp)
 288:	6402                	ld	s0,0(sp)
 28a:	0141                	add	sp,sp,16
 28c:	8082                	ret

000000000000028e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 28e:	4885                	li	a7,1
 ecall
 290:	00000073          	ecall
 ret
 294:	8082                	ret

0000000000000296 <exit>:
.global exit
exit:
 li a7, SYS_exit
 296:	4889                	li	a7,2
 ecall
 298:	00000073          	ecall
 ret
 29c:	8082                	ret

000000000000029e <wait>:
.global wait
wait:
 li a7, SYS_wait
 29e:	488d                	li	a7,3
 ecall
 2a0:	00000073          	ecall
 ret
 2a4:	8082                	ret

00000000000002a6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2a6:	4891                	li	a7,4
 ecall
 2a8:	00000073          	ecall
 ret
 2ac:	8082                	ret

00000000000002ae <read>:
.global read
read:
 li a7, SYS_read
 2ae:	4895                	li	a7,5
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <write>:
.global write
write:
 li a7, SYS_write
 2b6:	48c1                	li	a7,16
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <close>:
.global close
close:
 li a7, SYS_close
 2be:	48d5                	li	a7,21
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2c6:	4899                	li	a7,6
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <exec>:
.global exec
exec:
 li a7, SYS_exec
 2ce:	489d                	li	a7,7
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <open>:
.global open
open:
 li a7, SYS_open
 2d6:	48bd                	li	a7,15
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2de:	48c5                	li	a7,17
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2e6:	48c9                	li	a7,18
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2ee:	48a1                	li	a7,8
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <link>:
.global link
link:
 li a7, SYS_link
 2f6:	48cd                	li	a7,19
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2fe:	48d1                	li	a7,20
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 306:	48a5                	li	a7,9
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <dup>:
.global dup
dup:
 li a7, SYS_dup
 30e:	48a9                	li	a7,10
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 316:	48ad                	li	a7,11
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 31e:	48b1                	li	a7,12
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 326:	48b5                	li	a7,13
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 32e:	48b9                	li	a7,14
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <wait2>:
.global wait2
wait2:
 li a7, SYS_wait2
 336:	48d9                	li	a7,22
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <setnice>:
.global setnice
setnice:
 li a7, SYS_setnice
 33e:	48dd                	li	a7,23
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <getnice>:
.global getnice
getnice:
 li a7, SYS_getnice
 346:	48e1                	li	a7,24
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 34e:	1101                	add	sp,sp,-32
 350:	ec06                	sd	ra,24(sp)
 352:	e822                	sd	s0,16(sp)
 354:	1000                	add	s0,sp,32
 356:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 35a:	4605                	li	a2,1
 35c:	fef40593          	add	a1,s0,-17
 360:	00000097          	auipc	ra,0x0
 364:	f56080e7          	jalr	-170(ra) # 2b6 <write>
}
 368:	60e2                	ld	ra,24(sp)
 36a:	6442                	ld	s0,16(sp)
 36c:	6105                	add	sp,sp,32
 36e:	8082                	ret

0000000000000370 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 370:	7139                	add	sp,sp,-64
 372:	fc06                	sd	ra,56(sp)
 374:	f822                	sd	s0,48(sp)
 376:	f426                	sd	s1,40(sp)
 378:	0080                	add	s0,sp,64
 37a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 37c:	c299                	beqz	a3,382 <printint+0x12>
 37e:	0805cb63          	bltz	a1,414 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 382:	2581                	sext.w	a1,a1
  neg = 0;
 384:	4881                	li	a7,0
 386:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 38a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 38c:	2601                	sext.w	a2,a2
 38e:	00000517          	auipc	a0,0x0
 392:	4a250513          	add	a0,a0,1186 # 830 <digits>
 396:	883a                	mv	a6,a4
 398:	2705                	addw	a4,a4,1
 39a:	02c5f7bb          	remuw	a5,a1,a2
 39e:	1782                	sll	a5,a5,0x20
 3a0:	9381                	srl	a5,a5,0x20
 3a2:	97aa                	add	a5,a5,a0
 3a4:	0007c783          	lbu	a5,0(a5)
 3a8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3ac:	0005879b          	sext.w	a5,a1
 3b0:	02c5d5bb          	divuw	a1,a1,a2
 3b4:	0685                	add	a3,a3,1
 3b6:	fec7f0e3          	bgeu	a5,a2,396 <printint+0x26>
  if(neg)
 3ba:	00088c63          	beqz	a7,3d2 <printint+0x62>
    buf[i++] = '-';
 3be:	fd070793          	add	a5,a4,-48
 3c2:	00878733          	add	a4,a5,s0
 3c6:	02d00793          	li	a5,45
 3ca:	fef70823          	sb	a5,-16(a4)
 3ce:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 3d2:	02e05c63          	blez	a4,40a <printint+0x9a>
 3d6:	f04a                	sd	s2,32(sp)
 3d8:	ec4e                	sd	s3,24(sp)
 3da:	fc040793          	add	a5,s0,-64
 3de:	00e78933          	add	s2,a5,a4
 3e2:	fff78993          	add	s3,a5,-1
 3e6:	99ba                	add	s3,s3,a4
 3e8:	377d                	addw	a4,a4,-1
 3ea:	1702                	sll	a4,a4,0x20
 3ec:	9301                	srl	a4,a4,0x20
 3ee:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3f2:	fff94583          	lbu	a1,-1(s2)
 3f6:	8526                	mv	a0,s1
 3f8:	00000097          	auipc	ra,0x0
 3fc:	f56080e7          	jalr	-170(ra) # 34e <putc>
  while(--i >= 0)
 400:	197d                	add	s2,s2,-1
 402:	ff3918e3          	bne	s2,s3,3f2 <printint+0x82>
 406:	7902                	ld	s2,32(sp)
 408:	69e2                	ld	s3,24(sp)
}
 40a:	70e2                	ld	ra,56(sp)
 40c:	7442                	ld	s0,48(sp)
 40e:	74a2                	ld	s1,40(sp)
 410:	6121                	add	sp,sp,64
 412:	8082                	ret
    x = -xx;
 414:	40b005bb          	negw	a1,a1
    neg = 1;
 418:	4885                	li	a7,1
    x = -xx;
 41a:	b7b5                	j	386 <printint+0x16>

000000000000041c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 41c:	715d                	add	sp,sp,-80
 41e:	e486                	sd	ra,72(sp)
 420:	e0a2                	sd	s0,64(sp)
 422:	f84a                	sd	s2,48(sp)
 424:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 426:	0005c903          	lbu	s2,0(a1)
 42a:	1a090a63          	beqz	s2,5de <vprintf+0x1c2>
 42e:	fc26                	sd	s1,56(sp)
 430:	f44e                	sd	s3,40(sp)
 432:	f052                	sd	s4,32(sp)
 434:	ec56                	sd	s5,24(sp)
 436:	e85a                	sd	s6,16(sp)
 438:	e45e                	sd	s7,8(sp)
 43a:	8aaa                	mv	s5,a0
 43c:	8bb2                	mv	s7,a2
 43e:	00158493          	add	s1,a1,1
  state = 0;
 442:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 444:	02500a13          	li	s4,37
 448:	4b55                	li	s6,21
 44a:	a839                	j	468 <vprintf+0x4c>
        putc(fd, c);
 44c:	85ca                	mv	a1,s2
 44e:	8556                	mv	a0,s5
 450:	00000097          	auipc	ra,0x0
 454:	efe080e7          	jalr	-258(ra) # 34e <putc>
 458:	a019                	j	45e <vprintf+0x42>
    } else if(state == '%'){
 45a:	01498d63          	beq	s3,s4,474 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 45e:	0485                	add	s1,s1,1
 460:	fff4c903          	lbu	s2,-1(s1)
 464:	16090763          	beqz	s2,5d2 <vprintf+0x1b6>
    if(state == 0){
 468:	fe0999e3          	bnez	s3,45a <vprintf+0x3e>
      if(c == '%'){
 46c:	ff4910e3          	bne	s2,s4,44c <vprintf+0x30>
        state = '%';
 470:	89d2                	mv	s3,s4
 472:	b7f5                	j	45e <vprintf+0x42>
      if(c == 'd'){
 474:	13490463          	beq	s2,s4,59c <vprintf+0x180>
 478:	f9d9079b          	addw	a5,s2,-99
 47c:	0ff7f793          	zext.b	a5,a5
 480:	12fb6763          	bltu	s6,a5,5ae <vprintf+0x192>
 484:	f9d9079b          	addw	a5,s2,-99
 488:	0ff7f713          	zext.b	a4,a5
 48c:	12eb6163          	bltu	s6,a4,5ae <vprintf+0x192>
 490:	00271793          	sll	a5,a4,0x2
 494:	00000717          	auipc	a4,0x0
 498:	34470713          	add	a4,a4,836 # 7d8 <malloc+0x10a>
 49c:	97ba                	add	a5,a5,a4
 49e:	439c                	lw	a5,0(a5)
 4a0:	97ba                	add	a5,a5,a4
 4a2:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4a4:	008b8913          	add	s2,s7,8
 4a8:	4685                	li	a3,1
 4aa:	4629                	li	a2,10
 4ac:	000ba583          	lw	a1,0(s7)
 4b0:	8556                	mv	a0,s5
 4b2:	00000097          	auipc	ra,0x0
 4b6:	ebe080e7          	jalr	-322(ra) # 370 <printint>
 4ba:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4bc:	4981                	li	s3,0
 4be:	b745                	j	45e <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4c0:	008b8913          	add	s2,s7,8
 4c4:	4681                	li	a3,0
 4c6:	4629                	li	a2,10
 4c8:	000ba583          	lw	a1,0(s7)
 4cc:	8556                	mv	a0,s5
 4ce:	00000097          	auipc	ra,0x0
 4d2:	ea2080e7          	jalr	-350(ra) # 370 <printint>
 4d6:	8bca                	mv	s7,s2
      state = 0;
 4d8:	4981                	li	s3,0
 4da:	b751                	j	45e <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 4dc:	008b8913          	add	s2,s7,8
 4e0:	4681                	li	a3,0
 4e2:	4641                	li	a2,16
 4e4:	000ba583          	lw	a1,0(s7)
 4e8:	8556                	mv	a0,s5
 4ea:	00000097          	auipc	ra,0x0
 4ee:	e86080e7          	jalr	-378(ra) # 370 <printint>
 4f2:	8bca                	mv	s7,s2
      state = 0;
 4f4:	4981                	li	s3,0
 4f6:	b7a5                	j	45e <vprintf+0x42>
 4f8:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 4fa:	008b8c13          	add	s8,s7,8
 4fe:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 502:	03000593          	li	a1,48
 506:	8556                	mv	a0,s5
 508:	00000097          	auipc	ra,0x0
 50c:	e46080e7          	jalr	-442(ra) # 34e <putc>
  putc(fd, 'x');
 510:	07800593          	li	a1,120
 514:	8556                	mv	a0,s5
 516:	00000097          	auipc	ra,0x0
 51a:	e38080e7          	jalr	-456(ra) # 34e <putc>
 51e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 520:	00000b97          	auipc	s7,0x0
 524:	310b8b93          	add	s7,s7,784 # 830 <digits>
 528:	03c9d793          	srl	a5,s3,0x3c
 52c:	97de                	add	a5,a5,s7
 52e:	0007c583          	lbu	a1,0(a5)
 532:	8556                	mv	a0,s5
 534:	00000097          	auipc	ra,0x0
 538:	e1a080e7          	jalr	-486(ra) # 34e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 53c:	0992                	sll	s3,s3,0x4
 53e:	397d                	addw	s2,s2,-1
 540:	fe0914e3          	bnez	s2,528 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 544:	8be2                	mv	s7,s8
      state = 0;
 546:	4981                	li	s3,0
 548:	6c02                	ld	s8,0(sp)
 54a:	bf11                	j	45e <vprintf+0x42>
        s = va_arg(ap, char*);
 54c:	008b8993          	add	s3,s7,8
 550:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 554:	02090163          	beqz	s2,576 <vprintf+0x15a>
        while(*s != 0){
 558:	00094583          	lbu	a1,0(s2)
 55c:	c9a5                	beqz	a1,5cc <vprintf+0x1b0>
          putc(fd, *s);
 55e:	8556                	mv	a0,s5
 560:	00000097          	auipc	ra,0x0
 564:	dee080e7          	jalr	-530(ra) # 34e <putc>
          s++;
 568:	0905                	add	s2,s2,1
        while(*s != 0){
 56a:	00094583          	lbu	a1,0(s2)
 56e:	f9e5                	bnez	a1,55e <vprintf+0x142>
        s = va_arg(ap, char*);
 570:	8bce                	mv	s7,s3
      state = 0;
 572:	4981                	li	s3,0
 574:	b5ed                	j	45e <vprintf+0x42>
          s = "(null)";
 576:	00000917          	auipc	s2,0x0
 57a:	25a90913          	add	s2,s2,602 # 7d0 <malloc+0x102>
        while(*s != 0){
 57e:	02800593          	li	a1,40
 582:	bff1                	j	55e <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 584:	008b8913          	add	s2,s7,8
 588:	000bc583          	lbu	a1,0(s7)
 58c:	8556                	mv	a0,s5
 58e:	00000097          	auipc	ra,0x0
 592:	dc0080e7          	jalr	-576(ra) # 34e <putc>
 596:	8bca                	mv	s7,s2
      state = 0;
 598:	4981                	li	s3,0
 59a:	b5d1                	j	45e <vprintf+0x42>
        putc(fd, c);
 59c:	02500593          	li	a1,37
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	dac080e7          	jalr	-596(ra) # 34e <putc>
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	bd4d                	j	45e <vprintf+0x42>
        putc(fd, '%');
 5ae:	02500593          	li	a1,37
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	d9a080e7          	jalr	-614(ra) # 34e <putc>
        putc(fd, c);
 5bc:	85ca                	mv	a1,s2
 5be:	8556                	mv	a0,s5
 5c0:	00000097          	auipc	ra,0x0
 5c4:	d8e080e7          	jalr	-626(ra) # 34e <putc>
      state = 0;
 5c8:	4981                	li	s3,0
 5ca:	bd51                	j	45e <vprintf+0x42>
        s = va_arg(ap, char*);
 5cc:	8bce                	mv	s7,s3
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	b579                	j	45e <vprintf+0x42>
 5d2:	74e2                	ld	s1,56(sp)
 5d4:	79a2                	ld	s3,40(sp)
 5d6:	7a02                	ld	s4,32(sp)
 5d8:	6ae2                	ld	s5,24(sp)
 5da:	6b42                	ld	s6,16(sp)
 5dc:	6ba2                	ld	s7,8(sp)
    }
  }
}
 5de:	60a6                	ld	ra,72(sp)
 5e0:	6406                	ld	s0,64(sp)
 5e2:	7942                	ld	s2,48(sp)
 5e4:	6161                	add	sp,sp,80
 5e6:	8082                	ret

00000000000005e8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5e8:	715d                	add	sp,sp,-80
 5ea:	ec06                	sd	ra,24(sp)
 5ec:	e822                	sd	s0,16(sp)
 5ee:	1000                	add	s0,sp,32
 5f0:	e010                	sd	a2,0(s0)
 5f2:	e414                	sd	a3,8(s0)
 5f4:	e818                	sd	a4,16(s0)
 5f6:	ec1c                	sd	a5,24(s0)
 5f8:	03043023          	sd	a6,32(s0)
 5fc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 600:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 604:	8622                	mv	a2,s0
 606:	00000097          	auipc	ra,0x0
 60a:	e16080e7          	jalr	-490(ra) # 41c <vprintf>
}
 60e:	60e2                	ld	ra,24(sp)
 610:	6442                	ld	s0,16(sp)
 612:	6161                	add	sp,sp,80
 614:	8082                	ret

0000000000000616 <printf>:

void
printf(const char *fmt, ...)
{
 616:	711d                	add	sp,sp,-96
 618:	ec06                	sd	ra,24(sp)
 61a:	e822                	sd	s0,16(sp)
 61c:	1000                	add	s0,sp,32
 61e:	e40c                	sd	a1,8(s0)
 620:	e810                	sd	a2,16(s0)
 622:	ec14                	sd	a3,24(s0)
 624:	f018                	sd	a4,32(s0)
 626:	f41c                	sd	a5,40(s0)
 628:	03043823          	sd	a6,48(s0)
 62c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 630:	00840613          	add	a2,s0,8
 634:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 638:	85aa                	mv	a1,a0
 63a:	4505                	li	a0,1
 63c:	00000097          	auipc	ra,0x0
 640:	de0080e7          	jalr	-544(ra) # 41c <vprintf>
}
 644:	60e2                	ld	ra,24(sp)
 646:	6442                	ld	s0,16(sp)
 648:	6125                	add	sp,sp,96
 64a:	8082                	ret

000000000000064c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 64c:	1141                	add	sp,sp,-16
 64e:	e422                	sd	s0,8(sp)
 650:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 652:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 656:	00000797          	auipc	a5,0x0
 65a:	1f27b783          	ld	a5,498(a5) # 848 <freep>
 65e:	a02d                	j	688 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 660:	4618                	lw	a4,8(a2)
 662:	9f2d                	addw	a4,a4,a1
 664:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 668:	6398                	ld	a4,0(a5)
 66a:	6310                	ld	a2,0(a4)
 66c:	a83d                	j	6aa <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 66e:	ff852703          	lw	a4,-8(a0)
 672:	9f31                	addw	a4,a4,a2
 674:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 676:	ff053683          	ld	a3,-16(a0)
 67a:	a091                	j	6be <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 67c:	6398                	ld	a4,0(a5)
 67e:	00e7e463          	bltu	a5,a4,686 <free+0x3a>
 682:	00e6ea63          	bltu	a3,a4,696 <free+0x4a>
{
 686:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 688:	fed7fae3          	bgeu	a5,a3,67c <free+0x30>
 68c:	6398                	ld	a4,0(a5)
 68e:	00e6e463          	bltu	a3,a4,696 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 692:	fee7eae3          	bltu	a5,a4,686 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 696:	ff852583          	lw	a1,-8(a0)
 69a:	6390                	ld	a2,0(a5)
 69c:	02059813          	sll	a6,a1,0x20
 6a0:	01c85713          	srl	a4,a6,0x1c
 6a4:	9736                	add	a4,a4,a3
 6a6:	fae60de3          	beq	a2,a4,660 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6aa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6ae:	4790                	lw	a2,8(a5)
 6b0:	02061593          	sll	a1,a2,0x20
 6b4:	01c5d713          	srl	a4,a1,0x1c
 6b8:	973e                	add	a4,a4,a5
 6ba:	fae68ae3          	beq	a3,a4,66e <free+0x22>
    p->s.ptr = bp->s.ptr;
 6be:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6c0:	00000717          	auipc	a4,0x0
 6c4:	18f73423          	sd	a5,392(a4) # 848 <freep>
}
 6c8:	6422                	ld	s0,8(sp)
 6ca:	0141                	add	sp,sp,16
 6cc:	8082                	ret

00000000000006ce <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6ce:	7139                	add	sp,sp,-64
 6d0:	fc06                	sd	ra,56(sp)
 6d2:	f822                	sd	s0,48(sp)
 6d4:	f426                	sd	s1,40(sp)
 6d6:	ec4e                	sd	s3,24(sp)
 6d8:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6da:	02051493          	sll	s1,a0,0x20
 6de:	9081                	srl	s1,s1,0x20
 6e0:	04bd                	add	s1,s1,15
 6e2:	8091                	srl	s1,s1,0x4
 6e4:	0014899b          	addw	s3,s1,1
 6e8:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 6ea:	00000517          	auipc	a0,0x0
 6ee:	15e53503          	ld	a0,350(a0) # 848 <freep>
 6f2:	c915                	beqz	a0,726 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 6f6:	4798                	lw	a4,8(a5)
 6f8:	08977e63          	bgeu	a4,s1,794 <malloc+0xc6>
 6fc:	f04a                	sd	s2,32(sp)
 6fe:	e852                	sd	s4,16(sp)
 700:	e456                	sd	s5,8(sp)
 702:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 704:	8a4e                	mv	s4,s3
 706:	0009871b          	sext.w	a4,s3
 70a:	6685                	lui	a3,0x1
 70c:	00d77363          	bgeu	a4,a3,712 <malloc+0x44>
 710:	6a05                	lui	s4,0x1
 712:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 716:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 71a:	00000917          	auipc	s2,0x0
 71e:	12e90913          	add	s2,s2,302 # 848 <freep>
  if(p == (char*)-1)
 722:	5afd                	li	s5,-1
 724:	a091                	j	768 <malloc+0x9a>
 726:	f04a                	sd	s2,32(sp)
 728:	e852                	sd	s4,16(sp)
 72a:	e456                	sd	s5,8(sp)
 72c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 72e:	00000797          	auipc	a5,0x0
 732:	12278793          	add	a5,a5,290 # 850 <base>
 736:	00000717          	auipc	a4,0x0
 73a:	10f73923          	sd	a5,274(a4) # 848 <freep>
 73e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 740:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 744:	b7c1                	j	704 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 746:	6398                	ld	a4,0(a5)
 748:	e118                	sd	a4,0(a0)
 74a:	a08d                	j	7ac <malloc+0xde>
  hp->s.size = nu;
 74c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 750:	0541                	add	a0,a0,16
 752:	00000097          	auipc	ra,0x0
 756:	efa080e7          	jalr	-262(ra) # 64c <free>
  return freep;
 75a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 75e:	c13d                	beqz	a0,7c4 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 760:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 762:	4798                	lw	a4,8(a5)
 764:	02977463          	bgeu	a4,s1,78c <malloc+0xbe>
    if(p == freep)
 768:	00093703          	ld	a4,0(s2)
 76c:	853e                	mv	a0,a5
 76e:	fef719e3          	bne	a4,a5,760 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 772:	8552                	mv	a0,s4
 774:	00000097          	auipc	ra,0x0
 778:	baa080e7          	jalr	-1110(ra) # 31e <sbrk>
  if(p == (char*)-1)
 77c:	fd5518e3          	bne	a0,s5,74c <malloc+0x7e>
        return 0;
 780:	4501                	li	a0,0
 782:	7902                	ld	s2,32(sp)
 784:	6a42                	ld	s4,16(sp)
 786:	6aa2                	ld	s5,8(sp)
 788:	6b02                	ld	s6,0(sp)
 78a:	a03d                	j	7b8 <malloc+0xea>
 78c:	7902                	ld	s2,32(sp)
 78e:	6a42                	ld	s4,16(sp)
 790:	6aa2                	ld	s5,8(sp)
 792:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 794:	fae489e3          	beq	s1,a4,746 <malloc+0x78>
        p->s.size -= nunits;
 798:	4137073b          	subw	a4,a4,s3
 79c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 79e:	02071693          	sll	a3,a4,0x20
 7a2:	01c6d713          	srl	a4,a3,0x1c
 7a6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7a8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7ac:	00000717          	auipc	a4,0x0
 7b0:	08a73e23          	sd	a0,156(a4) # 848 <freep>
      return (void*)(p + 1);
 7b4:	01078513          	add	a0,a5,16
  }
}
 7b8:	70e2                	ld	ra,56(sp)
 7ba:	7442                	ld	s0,48(sp)
 7bc:	74a2                	ld	s1,40(sp)
 7be:	69e2                	ld	s3,24(sp)
 7c0:	6121                	add	sp,sp,64
 7c2:	8082                	ret
 7c4:	7902                	ld	s2,32(sp)
 7c6:	6a42                	ld	s4,16(sp)
 7c8:	6aa2                	ld	s5,8(sp)
 7ca:	6b02                	ld	s6,0(sp)
 7cc:	b7f5                	j	7b8 <malloc+0xea>
