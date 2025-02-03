
user/_ln:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1101                	add	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	add	s0,sp,32
  if(argc != 3){
   8:	478d                	li	a5,3
   a:	02f50163          	beq	a0,a5,2c <main+0x2c>
   e:	e426                	sd	s1,8(sp)
    fprintf(2, "Usage: ln old new\n");
  10:	00000597          	auipc	a1,0x0
  14:	7f858593          	add	a1,a1,2040 # 808 <malloc+0x102>
  18:	4509                	li	a0,2
  1a:	00000097          	auipc	ra,0x0
  1e:	606080e7          	jalr	1542(ra) # 620 <fprintf>
    exit(1);
  22:	4505                	li	a0,1
  24:	00000097          	auipc	ra,0x0
  28:	2aa080e7          	jalr	682(ra) # 2ce <exit>
  2c:	e426                	sd	s1,8(sp)
  2e:	84ae                	mv	s1,a1
  }
  if(link(argv[1], argv[2]) < 0)
  30:	698c                	ld	a1,16(a1)
  32:	6488                	ld	a0,8(s1)
  34:	00000097          	auipc	ra,0x0
  38:	2fa080e7          	jalr	762(ra) # 32e <link>
  3c:	00054763          	bltz	a0,4a <main+0x4a>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  exit(0);
  40:	4501                	li	a0,0
  42:	00000097          	auipc	ra,0x0
  46:	28c080e7          	jalr	652(ra) # 2ce <exit>
    fprintf(2, "link %s %s: failed\n", argv[1], argv[2]);
  4a:	6894                	ld	a3,16(s1)
  4c:	6490                	ld	a2,8(s1)
  4e:	00000597          	auipc	a1,0x0
  52:	7d258593          	add	a1,a1,2002 # 820 <malloc+0x11a>
  56:	4509                	li	a0,2
  58:	00000097          	auipc	ra,0x0
  5c:	5c8080e7          	jalr	1480(ra) # 620 <fprintf>
  60:	b7c5                	j	40 <main+0x40>

0000000000000062 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  62:	1141                	add	sp,sp,-16
  64:	e422                	sd	s0,8(sp)
  66:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  68:	87aa                	mv	a5,a0
  6a:	0585                	add	a1,a1,1
  6c:	0785                	add	a5,a5,1
  6e:	fff5c703          	lbu	a4,-1(a1)
  72:	fee78fa3          	sb	a4,-1(a5)
  76:	fb75                	bnez	a4,6a <strcpy+0x8>
    ;
  return os;
}
  78:	6422                	ld	s0,8(sp)
  7a:	0141                	add	sp,sp,16
  7c:	8082                	ret

000000000000007e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  7e:	1141                	add	sp,sp,-16
  80:	e422                	sd	s0,8(sp)
  82:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  84:	00054783          	lbu	a5,0(a0)
  88:	cb91                	beqz	a5,9c <strcmp+0x1e>
  8a:	0005c703          	lbu	a4,0(a1)
  8e:	00f71763          	bne	a4,a5,9c <strcmp+0x1e>
    p++, q++;
  92:	0505                	add	a0,a0,1
  94:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  96:	00054783          	lbu	a5,0(a0)
  9a:	fbe5                	bnez	a5,8a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  9c:	0005c503          	lbu	a0,0(a1)
}
  a0:	40a7853b          	subw	a0,a5,a0
  a4:	6422                	ld	s0,8(sp)
  a6:	0141                	add	sp,sp,16
  a8:	8082                	ret

00000000000000aa <strlen>:

uint
strlen(const char *s)
{
  aa:	1141                	add	sp,sp,-16
  ac:	e422                	sd	s0,8(sp)
  ae:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  b0:	00054783          	lbu	a5,0(a0)
  b4:	cf91                	beqz	a5,d0 <strlen+0x26>
  b6:	0505                	add	a0,a0,1
  b8:	87aa                	mv	a5,a0
  ba:	86be                	mv	a3,a5
  bc:	0785                	add	a5,a5,1
  be:	fff7c703          	lbu	a4,-1(a5)
  c2:	ff65                	bnez	a4,ba <strlen+0x10>
  c4:	40a6853b          	subw	a0,a3,a0
  c8:	2505                	addw	a0,a0,1
    ;
  return n;
}
  ca:	6422                	ld	s0,8(sp)
  cc:	0141                	add	sp,sp,16
  ce:	8082                	ret
  for(n = 0; s[n]; n++)
  d0:	4501                	li	a0,0
  d2:	bfe5                	j	ca <strlen+0x20>

00000000000000d4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d4:	1141                	add	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  da:	ca19                	beqz	a2,f0 <memset+0x1c>
  dc:	87aa                	mv	a5,a0
  de:	1602                	sll	a2,a2,0x20
  e0:	9201                	srl	a2,a2,0x20
  e2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  e6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ea:	0785                	add	a5,a5,1
  ec:	fee79de3          	bne	a5,a4,e6 <memset+0x12>
  }
  return dst;
}
  f0:	6422                	ld	s0,8(sp)
  f2:	0141                	add	sp,sp,16
  f4:	8082                	ret

00000000000000f6 <strchr>:

char*
strchr(const char *s, char c)
{
  f6:	1141                	add	sp,sp,-16
  f8:	e422                	sd	s0,8(sp)
  fa:	0800                	add	s0,sp,16
  for(; *s; s++)
  fc:	00054783          	lbu	a5,0(a0)
 100:	cb99                	beqz	a5,116 <strchr+0x20>
    if(*s == c)
 102:	00f58763          	beq	a1,a5,110 <strchr+0x1a>
  for(; *s; s++)
 106:	0505                	add	a0,a0,1
 108:	00054783          	lbu	a5,0(a0)
 10c:	fbfd                	bnez	a5,102 <strchr+0xc>
      return (char*)s;
  return 0;
 10e:	4501                	li	a0,0
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	add	sp,sp,16
 114:	8082                	ret
  return 0;
 116:	4501                	li	a0,0
 118:	bfe5                	j	110 <strchr+0x1a>

000000000000011a <gets>:

char*
gets(char *buf, int max)
{
 11a:	711d                	add	sp,sp,-96
 11c:	ec86                	sd	ra,88(sp)
 11e:	e8a2                	sd	s0,80(sp)
 120:	e4a6                	sd	s1,72(sp)
 122:	e0ca                	sd	s2,64(sp)
 124:	fc4e                	sd	s3,56(sp)
 126:	f852                	sd	s4,48(sp)
 128:	f456                	sd	s5,40(sp)
 12a:	f05a                	sd	s6,32(sp)
 12c:	ec5e                	sd	s7,24(sp)
 12e:	1080                	add	s0,sp,96
 130:	8baa                	mv	s7,a0
 132:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 134:	892a                	mv	s2,a0
 136:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 138:	4aa9                	li	s5,10
 13a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 13c:	89a6                	mv	s3,s1
 13e:	2485                	addw	s1,s1,1
 140:	0344d863          	bge	s1,s4,170 <gets+0x56>
    cc = read(0, &c, 1);
 144:	4605                	li	a2,1
 146:	faf40593          	add	a1,s0,-81
 14a:	4501                	li	a0,0
 14c:	00000097          	auipc	ra,0x0
 150:	19a080e7          	jalr	410(ra) # 2e6 <read>
    if(cc < 1)
 154:	00a05e63          	blez	a0,170 <gets+0x56>
    buf[i++] = c;
 158:	faf44783          	lbu	a5,-81(s0)
 15c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 160:	01578763          	beq	a5,s5,16e <gets+0x54>
 164:	0905                	add	s2,s2,1
 166:	fd679be3          	bne	a5,s6,13c <gets+0x22>
    buf[i++] = c;
 16a:	89a6                	mv	s3,s1
 16c:	a011                	j	170 <gets+0x56>
 16e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 170:	99de                	add	s3,s3,s7
 172:	00098023          	sb	zero,0(s3)
  return buf;
}
 176:	855e                	mv	a0,s7
 178:	60e6                	ld	ra,88(sp)
 17a:	6446                	ld	s0,80(sp)
 17c:	64a6                	ld	s1,72(sp)
 17e:	6906                	ld	s2,64(sp)
 180:	79e2                	ld	s3,56(sp)
 182:	7a42                	ld	s4,48(sp)
 184:	7aa2                	ld	s5,40(sp)
 186:	7b02                	ld	s6,32(sp)
 188:	6be2                	ld	s7,24(sp)
 18a:	6125                	add	sp,sp,96
 18c:	8082                	ret

000000000000018e <stat>:

int
stat(const char *n, struct stat *st)
{
 18e:	1101                	add	sp,sp,-32
 190:	ec06                	sd	ra,24(sp)
 192:	e822                	sd	s0,16(sp)
 194:	e04a                	sd	s2,0(sp)
 196:	1000                	add	s0,sp,32
 198:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19a:	4581                	li	a1,0
 19c:	00000097          	auipc	ra,0x0
 1a0:	172080e7          	jalr	370(ra) # 30e <open>
  if(fd < 0)
 1a4:	02054663          	bltz	a0,1d0 <stat+0x42>
 1a8:	e426                	sd	s1,8(sp)
 1aa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ac:	85ca                	mv	a1,s2
 1ae:	00000097          	auipc	ra,0x0
 1b2:	178080e7          	jalr	376(ra) # 326 <fstat>
 1b6:	892a                	mv	s2,a0
  close(fd);
 1b8:	8526                	mv	a0,s1
 1ba:	00000097          	auipc	ra,0x0
 1be:	13c080e7          	jalr	316(ra) # 2f6 <close>
  return r;
 1c2:	64a2                	ld	s1,8(sp)
}
 1c4:	854a                	mv	a0,s2
 1c6:	60e2                	ld	ra,24(sp)
 1c8:	6442                	ld	s0,16(sp)
 1ca:	6902                	ld	s2,0(sp)
 1cc:	6105                	add	sp,sp,32
 1ce:	8082                	ret
    return -1;
 1d0:	597d                	li	s2,-1
 1d2:	bfcd                	j	1c4 <stat+0x36>

00000000000001d4 <atoi>:

int
atoi(const char *s)
{
 1d4:	1141                	add	sp,sp,-16
 1d6:	e422                	sd	s0,8(sp)
 1d8:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1da:	00054683          	lbu	a3,0(a0)
 1de:	fd06879b          	addw	a5,a3,-48
 1e2:	0ff7f793          	zext.b	a5,a5
 1e6:	4625                	li	a2,9
 1e8:	02f66863          	bltu	a2,a5,218 <atoi+0x44>
 1ec:	872a                	mv	a4,a0
  n = 0;
 1ee:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1f0:	0705                	add	a4,a4,1
 1f2:	0025179b          	sllw	a5,a0,0x2
 1f6:	9fa9                	addw	a5,a5,a0
 1f8:	0017979b          	sllw	a5,a5,0x1
 1fc:	9fb5                	addw	a5,a5,a3
 1fe:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 202:	00074683          	lbu	a3,0(a4)
 206:	fd06879b          	addw	a5,a3,-48
 20a:	0ff7f793          	zext.b	a5,a5
 20e:	fef671e3          	bgeu	a2,a5,1f0 <atoi+0x1c>
  return n;
}
 212:	6422                	ld	s0,8(sp)
 214:	0141                	add	sp,sp,16
 216:	8082                	ret
  n = 0;
 218:	4501                	li	a0,0
 21a:	bfe5                	j	212 <atoi+0x3e>

000000000000021c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 21c:	1141                	add	sp,sp,-16
 21e:	e422                	sd	s0,8(sp)
 220:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 222:	02b57463          	bgeu	a0,a1,24a <memmove+0x2e>
    while(n-- > 0)
 226:	00c05f63          	blez	a2,244 <memmove+0x28>
 22a:	1602                	sll	a2,a2,0x20
 22c:	9201                	srl	a2,a2,0x20
 22e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 232:	872a                	mv	a4,a0
      *dst++ = *src++;
 234:	0585                	add	a1,a1,1
 236:	0705                	add	a4,a4,1
 238:	fff5c683          	lbu	a3,-1(a1)
 23c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 240:	fef71ae3          	bne	a4,a5,234 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 244:	6422                	ld	s0,8(sp)
 246:	0141                	add	sp,sp,16
 248:	8082                	ret
    dst += n;
 24a:	00c50733          	add	a4,a0,a2
    src += n;
 24e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 250:	fec05ae3          	blez	a2,244 <memmove+0x28>
 254:	fff6079b          	addw	a5,a2,-1
 258:	1782                	sll	a5,a5,0x20
 25a:	9381                	srl	a5,a5,0x20
 25c:	fff7c793          	not	a5,a5
 260:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 262:	15fd                	add	a1,a1,-1
 264:	177d                	add	a4,a4,-1
 266:	0005c683          	lbu	a3,0(a1)
 26a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 26e:	fee79ae3          	bne	a5,a4,262 <memmove+0x46>
 272:	bfc9                	j	244 <memmove+0x28>

0000000000000274 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 274:	1141                	add	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 27a:	ca05                	beqz	a2,2aa <memcmp+0x36>
 27c:	fff6069b          	addw	a3,a2,-1
 280:	1682                	sll	a3,a3,0x20
 282:	9281                	srl	a3,a3,0x20
 284:	0685                	add	a3,a3,1
 286:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 288:	00054783          	lbu	a5,0(a0)
 28c:	0005c703          	lbu	a4,0(a1)
 290:	00e79863          	bne	a5,a4,2a0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 294:	0505                	add	a0,a0,1
    p2++;
 296:	0585                	add	a1,a1,1
  while (n-- > 0) {
 298:	fed518e3          	bne	a0,a3,288 <memcmp+0x14>
  }
  return 0;
 29c:	4501                	li	a0,0
 29e:	a019                	j	2a4 <memcmp+0x30>
      return *p1 - *p2;
 2a0:	40e7853b          	subw	a0,a5,a4
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	add	sp,sp,16
 2a8:	8082                	ret
  return 0;
 2aa:	4501                	li	a0,0
 2ac:	bfe5                	j	2a4 <memcmp+0x30>

00000000000002ae <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2ae:	1141                	add	sp,sp,-16
 2b0:	e406                	sd	ra,8(sp)
 2b2:	e022                	sd	s0,0(sp)
 2b4:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 2b6:	00000097          	auipc	ra,0x0
 2ba:	f66080e7          	jalr	-154(ra) # 21c <memmove>
}
 2be:	60a2                	ld	ra,8(sp)
 2c0:	6402                	ld	s0,0(sp)
 2c2:	0141                	add	sp,sp,16
 2c4:	8082                	ret

00000000000002c6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2c6:	4885                	li	a7,1
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ce:	4889                	li	a7,2
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2d6:	488d                	li	a7,3
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2de:	4891                	li	a7,4
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <read>:
.global read
read:
 li a7, SYS_read
 2e6:	4895                	li	a7,5
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <write>:
.global write
write:
 li a7, SYS_write
 2ee:	48c1                	li	a7,16
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <close>:
.global close
close:
 li a7, SYS_close
 2f6:	48d5                	li	a7,21
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <kill>:
.global kill
kill:
 li a7, SYS_kill
 2fe:	4899                	li	a7,6
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <exec>:
.global exec
exec:
 li a7, SYS_exec
 306:	489d                	li	a7,7
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <open>:
.global open
open:
 li a7, SYS_open
 30e:	48bd                	li	a7,15
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 316:	48c5                	li	a7,17
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 31e:	48c9                	li	a7,18
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 326:	48a1                	li	a7,8
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <link>:
.global link
link:
 li a7, SYS_link
 32e:	48cd                	li	a7,19
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 336:	48d1                	li	a7,20
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 33e:	48a5                	li	a7,9
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <dup>:
.global dup
dup:
 li a7, SYS_dup
 346:	48a9                	li	a7,10
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 34e:	48ad                	li	a7,11
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 356:	48b1                	li	a7,12
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 35e:	48b5                	li	a7,13
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 366:	48b9                	li	a7,14
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <wait2>:
.global wait2
wait2:
 li a7, SYS_wait2
 36e:	48d9                	li	a7,22
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <setnice>:
.global setnice
setnice:
 li a7, SYS_setnice
 376:	48dd                	li	a7,23
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <getnice>:
.global getnice
getnice:
 li a7, SYS_getnice
 37e:	48e1                	li	a7,24
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 386:	1101                	add	sp,sp,-32
 388:	ec06                	sd	ra,24(sp)
 38a:	e822                	sd	s0,16(sp)
 38c:	1000                	add	s0,sp,32
 38e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 392:	4605                	li	a2,1
 394:	fef40593          	add	a1,s0,-17
 398:	00000097          	auipc	ra,0x0
 39c:	f56080e7          	jalr	-170(ra) # 2ee <write>
}
 3a0:	60e2                	ld	ra,24(sp)
 3a2:	6442                	ld	s0,16(sp)
 3a4:	6105                	add	sp,sp,32
 3a6:	8082                	ret

00000000000003a8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a8:	7139                	add	sp,sp,-64
 3aa:	fc06                	sd	ra,56(sp)
 3ac:	f822                	sd	s0,48(sp)
 3ae:	f426                	sd	s1,40(sp)
 3b0:	0080                	add	s0,sp,64
 3b2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3b4:	c299                	beqz	a3,3ba <printint+0x12>
 3b6:	0805cb63          	bltz	a1,44c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3ba:	2581                	sext.w	a1,a1
  neg = 0;
 3bc:	4881                	li	a7,0
 3be:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 3c2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3c4:	2601                	sext.w	a2,a2
 3c6:	00000517          	auipc	a0,0x0
 3ca:	4d250513          	add	a0,a0,1234 # 898 <digits>
 3ce:	883a                	mv	a6,a4
 3d0:	2705                	addw	a4,a4,1
 3d2:	02c5f7bb          	remuw	a5,a1,a2
 3d6:	1782                	sll	a5,a5,0x20
 3d8:	9381                	srl	a5,a5,0x20
 3da:	97aa                	add	a5,a5,a0
 3dc:	0007c783          	lbu	a5,0(a5)
 3e0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3e4:	0005879b          	sext.w	a5,a1
 3e8:	02c5d5bb          	divuw	a1,a1,a2
 3ec:	0685                	add	a3,a3,1
 3ee:	fec7f0e3          	bgeu	a5,a2,3ce <printint+0x26>
  if(neg)
 3f2:	00088c63          	beqz	a7,40a <printint+0x62>
    buf[i++] = '-';
 3f6:	fd070793          	add	a5,a4,-48
 3fa:	00878733          	add	a4,a5,s0
 3fe:	02d00793          	li	a5,45
 402:	fef70823          	sb	a5,-16(a4)
 406:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 40a:	02e05c63          	blez	a4,442 <printint+0x9a>
 40e:	f04a                	sd	s2,32(sp)
 410:	ec4e                	sd	s3,24(sp)
 412:	fc040793          	add	a5,s0,-64
 416:	00e78933          	add	s2,a5,a4
 41a:	fff78993          	add	s3,a5,-1
 41e:	99ba                	add	s3,s3,a4
 420:	377d                	addw	a4,a4,-1
 422:	1702                	sll	a4,a4,0x20
 424:	9301                	srl	a4,a4,0x20
 426:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 42a:	fff94583          	lbu	a1,-1(s2)
 42e:	8526                	mv	a0,s1
 430:	00000097          	auipc	ra,0x0
 434:	f56080e7          	jalr	-170(ra) # 386 <putc>
  while(--i >= 0)
 438:	197d                	add	s2,s2,-1
 43a:	ff3918e3          	bne	s2,s3,42a <printint+0x82>
 43e:	7902                	ld	s2,32(sp)
 440:	69e2                	ld	s3,24(sp)
}
 442:	70e2                	ld	ra,56(sp)
 444:	7442                	ld	s0,48(sp)
 446:	74a2                	ld	s1,40(sp)
 448:	6121                	add	sp,sp,64
 44a:	8082                	ret
    x = -xx;
 44c:	40b005bb          	negw	a1,a1
    neg = 1;
 450:	4885                	li	a7,1
    x = -xx;
 452:	b7b5                	j	3be <printint+0x16>

0000000000000454 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 454:	715d                	add	sp,sp,-80
 456:	e486                	sd	ra,72(sp)
 458:	e0a2                	sd	s0,64(sp)
 45a:	f84a                	sd	s2,48(sp)
 45c:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 45e:	0005c903          	lbu	s2,0(a1)
 462:	1a090a63          	beqz	s2,616 <vprintf+0x1c2>
 466:	fc26                	sd	s1,56(sp)
 468:	f44e                	sd	s3,40(sp)
 46a:	f052                	sd	s4,32(sp)
 46c:	ec56                	sd	s5,24(sp)
 46e:	e85a                	sd	s6,16(sp)
 470:	e45e                	sd	s7,8(sp)
 472:	8aaa                	mv	s5,a0
 474:	8bb2                	mv	s7,a2
 476:	00158493          	add	s1,a1,1
  state = 0;
 47a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 47c:	02500a13          	li	s4,37
 480:	4b55                	li	s6,21
 482:	a839                	j	4a0 <vprintf+0x4c>
        putc(fd, c);
 484:	85ca                	mv	a1,s2
 486:	8556                	mv	a0,s5
 488:	00000097          	auipc	ra,0x0
 48c:	efe080e7          	jalr	-258(ra) # 386 <putc>
 490:	a019                	j	496 <vprintf+0x42>
    } else if(state == '%'){
 492:	01498d63          	beq	s3,s4,4ac <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 496:	0485                	add	s1,s1,1
 498:	fff4c903          	lbu	s2,-1(s1)
 49c:	16090763          	beqz	s2,60a <vprintf+0x1b6>
    if(state == 0){
 4a0:	fe0999e3          	bnez	s3,492 <vprintf+0x3e>
      if(c == '%'){
 4a4:	ff4910e3          	bne	s2,s4,484 <vprintf+0x30>
        state = '%';
 4a8:	89d2                	mv	s3,s4
 4aa:	b7f5                	j	496 <vprintf+0x42>
      if(c == 'd'){
 4ac:	13490463          	beq	s2,s4,5d4 <vprintf+0x180>
 4b0:	f9d9079b          	addw	a5,s2,-99
 4b4:	0ff7f793          	zext.b	a5,a5
 4b8:	12fb6763          	bltu	s6,a5,5e6 <vprintf+0x192>
 4bc:	f9d9079b          	addw	a5,s2,-99
 4c0:	0ff7f713          	zext.b	a4,a5
 4c4:	12eb6163          	bltu	s6,a4,5e6 <vprintf+0x192>
 4c8:	00271793          	sll	a5,a4,0x2
 4cc:	00000717          	auipc	a4,0x0
 4d0:	37470713          	add	a4,a4,884 # 840 <malloc+0x13a>
 4d4:	97ba                	add	a5,a5,a4
 4d6:	439c                	lw	a5,0(a5)
 4d8:	97ba                	add	a5,a5,a4
 4da:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4dc:	008b8913          	add	s2,s7,8
 4e0:	4685                	li	a3,1
 4e2:	4629                	li	a2,10
 4e4:	000ba583          	lw	a1,0(s7)
 4e8:	8556                	mv	a0,s5
 4ea:	00000097          	auipc	ra,0x0
 4ee:	ebe080e7          	jalr	-322(ra) # 3a8 <printint>
 4f2:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4f4:	4981                	li	s3,0
 4f6:	b745                	j	496 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4f8:	008b8913          	add	s2,s7,8
 4fc:	4681                	li	a3,0
 4fe:	4629                	li	a2,10
 500:	000ba583          	lw	a1,0(s7)
 504:	8556                	mv	a0,s5
 506:	00000097          	auipc	ra,0x0
 50a:	ea2080e7          	jalr	-350(ra) # 3a8 <printint>
 50e:	8bca                	mv	s7,s2
      state = 0;
 510:	4981                	li	s3,0
 512:	b751                	j	496 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 514:	008b8913          	add	s2,s7,8
 518:	4681                	li	a3,0
 51a:	4641                	li	a2,16
 51c:	000ba583          	lw	a1,0(s7)
 520:	8556                	mv	a0,s5
 522:	00000097          	auipc	ra,0x0
 526:	e86080e7          	jalr	-378(ra) # 3a8 <printint>
 52a:	8bca                	mv	s7,s2
      state = 0;
 52c:	4981                	li	s3,0
 52e:	b7a5                	j	496 <vprintf+0x42>
 530:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 532:	008b8c13          	add	s8,s7,8
 536:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 53a:	03000593          	li	a1,48
 53e:	8556                	mv	a0,s5
 540:	00000097          	auipc	ra,0x0
 544:	e46080e7          	jalr	-442(ra) # 386 <putc>
  putc(fd, 'x');
 548:	07800593          	li	a1,120
 54c:	8556                	mv	a0,s5
 54e:	00000097          	auipc	ra,0x0
 552:	e38080e7          	jalr	-456(ra) # 386 <putc>
 556:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 558:	00000b97          	auipc	s7,0x0
 55c:	340b8b93          	add	s7,s7,832 # 898 <digits>
 560:	03c9d793          	srl	a5,s3,0x3c
 564:	97de                	add	a5,a5,s7
 566:	0007c583          	lbu	a1,0(a5)
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	e1a080e7          	jalr	-486(ra) # 386 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 574:	0992                	sll	s3,s3,0x4
 576:	397d                	addw	s2,s2,-1
 578:	fe0914e3          	bnez	s2,560 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 57c:	8be2                	mv	s7,s8
      state = 0;
 57e:	4981                	li	s3,0
 580:	6c02                	ld	s8,0(sp)
 582:	bf11                	j	496 <vprintf+0x42>
        s = va_arg(ap, char*);
 584:	008b8993          	add	s3,s7,8
 588:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 58c:	02090163          	beqz	s2,5ae <vprintf+0x15a>
        while(*s != 0){
 590:	00094583          	lbu	a1,0(s2)
 594:	c9a5                	beqz	a1,604 <vprintf+0x1b0>
          putc(fd, *s);
 596:	8556                	mv	a0,s5
 598:	00000097          	auipc	ra,0x0
 59c:	dee080e7          	jalr	-530(ra) # 386 <putc>
          s++;
 5a0:	0905                	add	s2,s2,1
        while(*s != 0){
 5a2:	00094583          	lbu	a1,0(s2)
 5a6:	f9e5                	bnez	a1,596 <vprintf+0x142>
        s = va_arg(ap, char*);
 5a8:	8bce                	mv	s7,s3
      state = 0;
 5aa:	4981                	li	s3,0
 5ac:	b5ed                	j	496 <vprintf+0x42>
          s = "(null)";
 5ae:	00000917          	auipc	s2,0x0
 5b2:	28a90913          	add	s2,s2,650 # 838 <malloc+0x132>
        while(*s != 0){
 5b6:	02800593          	li	a1,40
 5ba:	bff1                	j	596 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 5bc:	008b8913          	add	s2,s7,8
 5c0:	000bc583          	lbu	a1,0(s7)
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	dc0080e7          	jalr	-576(ra) # 386 <putc>
 5ce:	8bca                	mv	s7,s2
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	b5d1                	j	496 <vprintf+0x42>
        putc(fd, c);
 5d4:	02500593          	li	a1,37
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	dac080e7          	jalr	-596(ra) # 386 <putc>
      state = 0;
 5e2:	4981                	li	s3,0
 5e4:	bd4d                	j	496 <vprintf+0x42>
        putc(fd, '%');
 5e6:	02500593          	li	a1,37
 5ea:	8556                	mv	a0,s5
 5ec:	00000097          	auipc	ra,0x0
 5f0:	d9a080e7          	jalr	-614(ra) # 386 <putc>
        putc(fd, c);
 5f4:	85ca                	mv	a1,s2
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	d8e080e7          	jalr	-626(ra) # 386 <putc>
      state = 0;
 600:	4981                	li	s3,0
 602:	bd51                	j	496 <vprintf+0x42>
        s = va_arg(ap, char*);
 604:	8bce                	mv	s7,s3
      state = 0;
 606:	4981                	li	s3,0
 608:	b579                	j	496 <vprintf+0x42>
 60a:	74e2                	ld	s1,56(sp)
 60c:	79a2                	ld	s3,40(sp)
 60e:	7a02                	ld	s4,32(sp)
 610:	6ae2                	ld	s5,24(sp)
 612:	6b42                	ld	s6,16(sp)
 614:	6ba2                	ld	s7,8(sp)
    }
  }
}
 616:	60a6                	ld	ra,72(sp)
 618:	6406                	ld	s0,64(sp)
 61a:	7942                	ld	s2,48(sp)
 61c:	6161                	add	sp,sp,80
 61e:	8082                	ret

0000000000000620 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 620:	715d                	add	sp,sp,-80
 622:	ec06                	sd	ra,24(sp)
 624:	e822                	sd	s0,16(sp)
 626:	1000                	add	s0,sp,32
 628:	e010                	sd	a2,0(s0)
 62a:	e414                	sd	a3,8(s0)
 62c:	e818                	sd	a4,16(s0)
 62e:	ec1c                	sd	a5,24(s0)
 630:	03043023          	sd	a6,32(s0)
 634:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 638:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 63c:	8622                	mv	a2,s0
 63e:	00000097          	auipc	ra,0x0
 642:	e16080e7          	jalr	-490(ra) # 454 <vprintf>
}
 646:	60e2                	ld	ra,24(sp)
 648:	6442                	ld	s0,16(sp)
 64a:	6161                	add	sp,sp,80
 64c:	8082                	ret

000000000000064e <printf>:

void
printf(const char *fmt, ...)
{
 64e:	711d                	add	sp,sp,-96
 650:	ec06                	sd	ra,24(sp)
 652:	e822                	sd	s0,16(sp)
 654:	1000                	add	s0,sp,32
 656:	e40c                	sd	a1,8(s0)
 658:	e810                	sd	a2,16(s0)
 65a:	ec14                	sd	a3,24(s0)
 65c:	f018                	sd	a4,32(s0)
 65e:	f41c                	sd	a5,40(s0)
 660:	03043823          	sd	a6,48(s0)
 664:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 668:	00840613          	add	a2,s0,8
 66c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 670:	85aa                	mv	a1,a0
 672:	4505                	li	a0,1
 674:	00000097          	auipc	ra,0x0
 678:	de0080e7          	jalr	-544(ra) # 454 <vprintf>
}
 67c:	60e2                	ld	ra,24(sp)
 67e:	6442                	ld	s0,16(sp)
 680:	6125                	add	sp,sp,96
 682:	8082                	ret

0000000000000684 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 684:	1141                	add	sp,sp,-16
 686:	e422                	sd	s0,8(sp)
 688:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 68a:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 68e:	00000797          	auipc	a5,0x0
 692:	2227b783          	ld	a5,546(a5) # 8b0 <freep>
 696:	a02d                	j	6c0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 698:	4618                	lw	a4,8(a2)
 69a:	9f2d                	addw	a4,a4,a1
 69c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a0:	6398                	ld	a4,0(a5)
 6a2:	6310                	ld	a2,0(a4)
 6a4:	a83d                	j	6e2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6a6:	ff852703          	lw	a4,-8(a0)
 6aa:	9f31                	addw	a4,a4,a2
 6ac:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6ae:	ff053683          	ld	a3,-16(a0)
 6b2:	a091                	j	6f6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6b4:	6398                	ld	a4,0(a5)
 6b6:	00e7e463          	bltu	a5,a4,6be <free+0x3a>
 6ba:	00e6ea63          	bltu	a3,a4,6ce <free+0x4a>
{
 6be:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c0:	fed7fae3          	bgeu	a5,a3,6b4 <free+0x30>
 6c4:	6398                	ld	a4,0(a5)
 6c6:	00e6e463          	bltu	a3,a4,6ce <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ca:	fee7eae3          	bltu	a5,a4,6be <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6ce:	ff852583          	lw	a1,-8(a0)
 6d2:	6390                	ld	a2,0(a5)
 6d4:	02059813          	sll	a6,a1,0x20
 6d8:	01c85713          	srl	a4,a6,0x1c
 6dc:	9736                	add	a4,a4,a3
 6de:	fae60de3          	beq	a2,a4,698 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6e2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6e6:	4790                	lw	a2,8(a5)
 6e8:	02061593          	sll	a1,a2,0x20
 6ec:	01c5d713          	srl	a4,a1,0x1c
 6f0:	973e                	add	a4,a4,a5
 6f2:	fae68ae3          	beq	a3,a4,6a6 <free+0x22>
    p->s.ptr = bp->s.ptr;
 6f6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6f8:	00000717          	auipc	a4,0x0
 6fc:	1af73c23          	sd	a5,440(a4) # 8b0 <freep>
}
 700:	6422                	ld	s0,8(sp)
 702:	0141                	add	sp,sp,16
 704:	8082                	ret

0000000000000706 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 706:	7139                	add	sp,sp,-64
 708:	fc06                	sd	ra,56(sp)
 70a:	f822                	sd	s0,48(sp)
 70c:	f426                	sd	s1,40(sp)
 70e:	ec4e                	sd	s3,24(sp)
 710:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 712:	02051493          	sll	s1,a0,0x20
 716:	9081                	srl	s1,s1,0x20
 718:	04bd                	add	s1,s1,15
 71a:	8091                	srl	s1,s1,0x4
 71c:	0014899b          	addw	s3,s1,1
 720:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 722:	00000517          	auipc	a0,0x0
 726:	18e53503          	ld	a0,398(a0) # 8b0 <freep>
 72a:	c915                	beqz	a0,75e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 72c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 72e:	4798                	lw	a4,8(a5)
 730:	08977e63          	bgeu	a4,s1,7cc <malloc+0xc6>
 734:	f04a                	sd	s2,32(sp)
 736:	e852                	sd	s4,16(sp)
 738:	e456                	sd	s5,8(sp)
 73a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 73c:	8a4e                	mv	s4,s3
 73e:	0009871b          	sext.w	a4,s3
 742:	6685                	lui	a3,0x1
 744:	00d77363          	bgeu	a4,a3,74a <malloc+0x44>
 748:	6a05                	lui	s4,0x1
 74a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 74e:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 752:	00000917          	auipc	s2,0x0
 756:	15e90913          	add	s2,s2,350 # 8b0 <freep>
  if(p == (char*)-1)
 75a:	5afd                	li	s5,-1
 75c:	a091                	j	7a0 <malloc+0x9a>
 75e:	f04a                	sd	s2,32(sp)
 760:	e852                	sd	s4,16(sp)
 762:	e456                	sd	s5,8(sp)
 764:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 766:	00000797          	auipc	a5,0x0
 76a:	15278793          	add	a5,a5,338 # 8b8 <base>
 76e:	00000717          	auipc	a4,0x0
 772:	14f73123          	sd	a5,322(a4) # 8b0 <freep>
 776:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 778:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 77c:	b7c1                	j	73c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 77e:	6398                	ld	a4,0(a5)
 780:	e118                	sd	a4,0(a0)
 782:	a08d                	j	7e4 <malloc+0xde>
  hp->s.size = nu;
 784:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 788:	0541                	add	a0,a0,16
 78a:	00000097          	auipc	ra,0x0
 78e:	efa080e7          	jalr	-262(ra) # 684 <free>
  return freep;
 792:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 796:	c13d                	beqz	a0,7fc <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 798:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 79a:	4798                	lw	a4,8(a5)
 79c:	02977463          	bgeu	a4,s1,7c4 <malloc+0xbe>
    if(p == freep)
 7a0:	00093703          	ld	a4,0(s2)
 7a4:	853e                	mv	a0,a5
 7a6:	fef719e3          	bne	a4,a5,798 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7aa:	8552                	mv	a0,s4
 7ac:	00000097          	auipc	ra,0x0
 7b0:	baa080e7          	jalr	-1110(ra) # 356 <sbrk>
  if(p == (char*)-1)
 7b4:	fd5518e3          	bne	a0,s5,784 <malloc+0x7e>
        return 0;
 7b8:	4501                	li	a0,0
 7ba:	7902                	ld	s2,32(sp)
 7bc:	6a42                	ld	s4,16(sp)
 7be:	6aa2                	ld	s5,8(sp)
 7c0:	6b02                	ld	s6,0(sp)
 7c2:	a03d                	j	7f0 <malloc+0xea>
 7c4:	7902                	ld	s2,32(sp)
 7c6:	6a42                	ld	s4,16(sp)
 7c8:	6aa2                	ld	s5,8(sp)
 7ca:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7cc:	fae489e3          	beq	s1,a4,77e <malloc+0x78>
        p->s.size -= nunits;
 7d0:	4137073b          	subw	a4,a4,s3
 7d4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7d6:	02071693          	sll	a3,a4,0x20
 7da:	01c6d713          	srl	a4,a3,0x1c
 7de:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7e0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7e4:	00000717          	auipc	a4,0x0
 7e8:	0ca73623          	sd	a0,204(a4) # 8b0 <freep>
      return (void*)(p + 1);
 7ec:	01078513          	add	a0,a5,16
  }
}
 7f0:	70e2                	ld	ra,56(sp)
 7f2:	7442                	ld	s0,48(sp)
 7f4:	74a2                	ld	s1,40(sp)
 7f6:	69e2                	ld	s3,24(sp)
 7f8:	6121                	add	sp,sp,64
 7fa:	8082                	ret
 7fc:	7902                	ld	s2,32(sp)
 7fe:	6a42                	ld	s4,16(sp)
 800:	6aa2                	ld	s5,8(sp)
 802:	6b02                	ld	s6,0(sp)
 804:	b7f5                	j	7f0 <malloc+0xea>
