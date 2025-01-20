
user/_kill:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char **argv)
{
   0:	1101                	add	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	add	s0,sp,32
  int i;

  if(argc < 2){
   8:	4785                	li	a5,1
   a:	02a7df63          	bge	a5,a0,48 <main+0x48>
   e:	e426                	sd	s1,8(sp)
  10:	e04a                	sd	s2,0(sp)
  12:	00858493          	add	s1,a1,8
  16:	ffe5091b          	addw	s2,a0,-2
  1a:	02091793          	sll	a5,s2,0x20
  1e:	01d7d913          	srl	s2,a5,0x1d
  22:	05c1                	add	a1,a1,16
  24:	992e                	add	s2,s2,a1
    fprintf(2, "usage: kill pid...\n");
    exit(1);
  }
  for(i=1; i<argc; i++)
    kill(atoi(argv[i]));
  26:	6088                	ld	a0,0(s1)
  28:	00000097          	auipc	ra,0x0
  2c:	1b2080e7          	jalr	434(ra) # 1da <atoi>
  30:	00000097          	auipc	ra,0x0
  34:	2d4080e7          	jalr	724(ra) # 304 <kill>
  for(i=1; i<argc; i++)
  38:	04a1                	add	s1,s1,8
  3a:	ff2496e3          	bne	s1,s2,26 <main+0x26>
  exit(0);
  3e:	4501                	li	a0,0
  40:	00000097          	auipc	ra,0x0
  44:	294080e7          	jalr	660(ra) # 2d4 <exit>
  48:	e426                	sd	s1,8(sp)
  4a:	e04a                	sd	s2,0(sp)
    fprintf(2, "usage: kill pid...\n");
  4c:	00000597          	auipc	a1,0x0
  50:	7b458593          	add	a1,a1,1972 # 800 <malloc+0x104>
  54:	4509                	li	a0,2
  56:	00000097          	auipc	ra,0x0
  5a:	5c0080e7          	jalr	1472(ra) # 616 <fprintf>
    exit(1);
  5e:	4505                	li	a0,1
  60:	00000097          	auipc	ra,0x0
  64:	274080e7          	jalr	628(ra) # 2d4 <exit>

0000000000000068 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  68:	1141                	add	sp,sp,-16
  6a:	e422                	sd	s0,8(sp)
  6c:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  6e:	87aa                	mv	a5,a0
  70:	0585                	add	a1,a1,1
  72:	0785                	add	a5,a5,1
  74:	fff5c703          	lbu	a4,-1(a1)
  78:	fee78fa3          	sb	a4,-1(a5)
  7c:	fb75                	bnez	a4,70 <strcpy+0x8>
    ;
  return os;
}
  7e:	6422                	ld	s0,8(sp)
  80:	0141                	add	sp,sp,16
  82:	8082                	ret

0000000000000084 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  84:	1141                	add	sp,sp,-16
  86:	e422                	sd	s0,8(sp)
  88:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  8a:	00054783          	lbu	a5,0(a0)
  8e:	cb91                	beqz	a5,a2 <strcmp+0x1e>
  90:	0005c703          	lbu	a4,0(a1)
  94:	00f71763          	bne	a4,a5,a2 <strcmp+0x1e>
    p++, q++;
  98:	0505                	add	a0,a0,1
  9a:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  9c:	00054783          	lbu	a5,0(a0)
  a0:	fbe5                	bnez	a5,90 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  a2:	0005c503          	lbu	a0,0(a1)
}
  a6:	40a7853b          	subw	a0,a5,a0
  aa:	6422                	ld	s0,8(sp)
  ac:	0141                	add	sp,sp,16
  ae:	8082                	ret

00000000000000b0 <strlen>:

uint
strlen(const char *s)
{
  b0:	1141                	add	sp,sp,-16
  b2:	e422                	sd	s0,8(sp)
  b4:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  b6:	00054783          	lbu	a5,0(a0)
  ba:	cf91                	beqz	a5,d6 <strlen+0x26>
  bc:	0505                	add	a0,a0,1
  be:	87aa                	mv	a5,a0
  c0:	86be                	mv	a3,a5
  c2:	0785                	add	a5,a5,1
  c4:	fff7c703          	lbu	a4,-1(a5)
  c8:	ff65                	bnez	a4,c0 <strlen+0x10>
  ca:	40a6853b          	subw	a0,a3,a0
  ce:	2505                	addw	a0,a0,1
    ;
  return n;
}
  d0:	6422                	ld	s0,8(sp)
  d2:	0141                	add	sp,sp,16
  d4:	8082                	ret
  for(n = 0; s[n]; n++)
  d6:	4501                	li	a0,0
  d8:	bfe5                	j	d0 <strlen+0x20>

00000000000000da <memset>:

void*
memset(void *dst, int c, uint n)
{
  da:	1141                	add	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  e0:	ca19                	beqz	a2,f6 <memset+0x1c>
  e2:	87aa                	mv	a5,a0
  e4:	1602                	sll	a2,a2,0x20
  e6:	9201                	srl	a2,a2,0x20
  e8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ec:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  f0:	0785                	add	a5,a5,1
  f2:	fee79de3          	bne	a5,a4,ec <memset+0x12>
  }
  return dst;
}
  f6:	6422                	ld	s0,8(sp)
  f8:	0141                	add	sp,sp,16
  fa:	8082                	ret

00000000000000fc <strchr>:

char*
strchr(const char *s, char c)
{
  fc:	1141                	add	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	add	s0,sp,16
  for(; *s; s++)
 102:	00054783          	lbu	a5,0(a0)
 106:	cb99                	beqz	a5,11c <strchr+0x20>
    if(*s == c)
 108:	00f58763          	beq	a1,a5,116 <strchr+0x1a>
  for(; *s; s++)
 10c:	0505                	add	a0,a0,1
 10e:	00054783          	lbu	a5,0(a0)
 112:	fbfd                	bnez	a5,108 <strchr+0xc>
      return (char*)s;
  return 0;
 114:	4501                	li	a0,0
}
 116:	6422                	ld	s0,8(sp)
 118:	0141                	add	sp,sp,16
 11a:	8082                	ret
  return 0;
 11c:	4501                	li	a0,0
 11e:	bfe5                	j	116 <strchr+0x1a>

0000000000000120 <gets>:

char*
gets(char *buf, int max)
{
 120:	711d                	add	sp,sp,-96
 122:	ec86                	sd	ra,88(sp)
 124:	e8a2                	sd	s0,80(sp)
 126:	e4a6                	sd	s1,72(sp)
 128:	e0ca                	sd	s2,64(sp)
 12a:	fc4e                	sd	s3,56(sp)
 12c:	f852                	sd	s4,48(sp)
 12e:	f456                	sd	s5,40(sp)
 130:	f05a                	sd	s6,32(sp)
 132:	ec5e                	sd	s7,24(sp)
 134:	1080                	add	s0,sp,96
 136:	8baa                	mv	s7,a0
 138:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 13a:	892a                	mv	s2,a0
 13c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 13e:	4aa9                	li	s5,10
 140:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 142:	89a6                	mv	s3,s1
 144:	2485                	addw	s1,s1,1
 146:	0344d863          	bge	s1,s4,176 <gets+0x56>
    cc = read(0, &c, 1);
 14a:	4605                	li	a2,1
 14c:	faf40593          	add	a1,s0,-81
 150:	4501                	li	a0,0
 152:	00000097          	auipc	ra,0x0
 156:	19a080e7          	jalr	410(ra) # 2ec <read>
    if(cc < 1)
 15a:	00a05e63          	blez	a0,176 <gets+0x56>
    buf[i++] = c;
 15e:	faf44783          	lbu	a5,-81(s0)
 162:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 166:	01578763          	beq	a5,s5,174 <gets+0x54>
 16a:	0905                	add	s2,s2,1
 16c:	fd679be3          	bne	a5,s6,142 <gets+0x22>
    buf[i++] = c;
 170:	89a6                	mv	s3,s1
 172:	a011                	j	176 <gets+0x56>
 174:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 176:	99de                	add	s3,s3,s7
 178:	00098023          	sb	zero,0(s3)
  return buf;
}
 17c:	855e                	mv	a0,s7
 17e:	60e6                	ld	ra,88(sp)
 180:	6446                	ld	s0,80(sp)
 182:	64a6                	ld	s1,72(sp)
 184:	6906                	ld	s2,64(sp)
 186:	79e2                	ld	s3,56(sp)
 188:	7a42                	ld	s4,48(sp)
 18a:	7aa2                	ld	s5,40(sp)
 18c:	7b02                	ld	s6,32(sp)
 18e:	6be2                	ld	s7,24(sp)
 190:	6125                	add	sp,sp,96
 192:	8082                	ret

0000000000000194 <stat>:

int
stat(const char *n, struct stat *st)
{
 194:	1101                	add	sp,sp,-32
 196:	ec06                	sd	ra,24(sp)
 198:	e822                	sd	s0,16(sp)
 19a:	e04a                	sd	s2,0(sp)
 19c:	1000                	add	s0,sp,32
 19e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1a0:	4581                	li	a1,0
 1a2:	00000097          	auipc	ra,0x0
 1a6:	172080e7          	jalr	370(ra) # 314 <open>
  if(fd < 0)
 1aa:	02054663          	bltz	a0,1d6 <stat+0x42>
 1ae:	e426                	sd	s1,8(sp)
 1b0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1b2:	85ca                	mv	a1,s2
 1b4:	00000097          	auipc	ra,0x0
 1b8:	178080e7          	jalr	376(ra) # 32c <fstat>
 1bc:	892a                	mv	s2,a0
  close(fd);
 1be:	8526                	mv	a0,s1
 1c0:	00000097          	auipc	ra,0x0
 1c4:	13c080e7          	jalr	316(ra) # 2fc <close>
  return r;
 1c8:	64a2                	ld	s1,8(sp)
}
 1ca:	854a                	mv	a0,s2
 1cc:	60e2                	ld	ra,24(sp)
 1ce:	6442                	ld	s0,16(sp)
 1d0:	6902                	ld	s2,0(sp)
 1d2:	6105                	add	sp,sp,32
 1d4:	8082                	ret
    return -1;
 1d6:	597d                	li	s2,-1
 1d8:	bfcd                	j	1ca <stat+0x36>

00000000000001da <atoi>:

int
atoi(const char *s)
{
 1da:	1141                	add	sp,sp,-16
 1dc:	e422                	sd	s0,8(sp)
 1de:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1e0:	00054683          	lbu	a3,0(a0)
 1e4:	fd06879b          	addw	a5,a3,-48
 1e8:	0ff7f793          	zext.b	a5,a5
 1ec:	4625                	li	a2,9
 1ee:	02f66863          	bltu	a2,a5,21e <atoi+0x44>
 1f2:	872a                	mv	a4,a0
  n = 0;
 1f4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1f6:	0705                	add	a4,a4,1
 1f8:	0025179b          	sllw	a5,a0,0x2
 1fc:	9fa9                	addw	a5,a5,a0
 1fe:	0017979b          	sllw	a5,a5,0x1
 202:	9fb5                	addw	a5,a5,a3
 204:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 208:	00074683          	lbu	a3,0(a4)
 20c:	fd06879b          	addw	a5,a3,-48
 210:	0ff7f793          	zext.b	a5,a5
 214:	fef671e3          	bgeu	a2,a5,1f6 <atoi+0x1c>
  return n;
}
 218:	6422                	ld	s0,8(sp)
 21a:	0141                	add	sp,sp,16
 21c:	8082                	ret
  n = 0;
 21e:	4501                	li	a0,0
 220:	bfe5                	j	218 <atoi+0x3e>

0000000000000222 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 222:	1141                	add	sp,sp,-16
 224:	e422                	sd	s0,8(sp)
 226:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 228:	02b57463          	bgeu	a0,a1,250 <memmove+0x2e>
    while(n-- > 0)
 22c:	00c05f63          	blez	a2,24a <memmove+0x28>
 230:	1602                	sll	a2,a2,0x20
 232:	9201                	srl	a2,a2,0x20
 234:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 238:	872a                	mv	a4,a0
      *dst++ = *src++;
 23a:	0585                	add	a1,a1,1
 23c:	0705                	add	a4,a4,1
 23e:	fff5c683          	lbu	a3,-1(a1)
 242:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 246:	fef71ae3          	bne	a4,a5,23a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	add	sp,sp,16
 24e:	8082                	ret
    dst += n;
 250:	00c50733          	add	a4,a0,a2
    src += n;
 254:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 256:	fec05ae3          	blez	a2,24a <memmove+0x28>
 25a:	fff6079b          	addw	a5,a2,-1
 25e:	1782                	sll	a5,a5,0x20
 260:	9381                	srl	a5,a5,0x20
 262:	fff7c793          	not	a5,a5
 266:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 268:	15fd                	add	a1,a1,-1
 26a:	177d                	add	a4,a4,-1
 26c:	0005c683          	lbu	a3,0(a1)
 270:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 274:	fee79ae3          	bne	a5,a4,268 <memmove+0x46>
 278:	bfc9                	j	24a <memmove+0x28>

000000000000027a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 27a:	1141                	add	sp,sp,-16
 27c:	e422                	sd	s0,8(sp)
 27e:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 280:	ca05                	beqz	a2,2b0 <memcmp+0x36>
 282:	fff6069b          	addw	a3,a2,-1
 286:	1682                	sll	a3,a3,0x20
 288:	9281                	srl	a3,a3,0x20
 28a:	0685                	add	a3,a3,1
 28c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 28e:	00054783          	lbu	a5,0(a0)
 292:	0005c703          	lbu	a4,0(a1)
 296:	00e79863          	bne	a5,a4,2a6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 29a:	0505                	add	a0,a0,1
    p2++;
 29c:	0585                	add	a1,a1,1
  while (n-- > 0) {
 29e:	fed518e3          	bne	a0,a3,28e <memcmp+0x14>
  }
  return 0;
 2a2:	4501                	li	a0,0
 2a4:	a019                	j	2aa <memcmp+0x30>
      return *p1 - *p2;
 2a6:	40e7853b          	subw	a0,a5,a4
}
 2aa:	6422                	ld	s0,8(sp)
 2ac:	0141                	add	sp,sp,16
 2ae:	8082                	ret
  return 0;
 2b0:	4501                	li	a0,0
 2b2:	bfe5                	j	2aa <memcmp+0x30>

00000000000002b4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2b4:	1141                	add	sp,sp,-16
 2b6:	e406                	sd	ra,8(sp)
 2b8:	e022                	sd	s0,0(sp)
 2ba:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 2bc:	00000097          	auipc	ra,0x0
 2c0:	f66080e7          	jalr	-154(ra) # 222 <memmove>
}
 2c4:	60a2                	ld	ra,8(sp)
 2c6:	6402                	ld	s0,0(sp)
 2c8:	0141                	add	sp,sp,16
 2ca:	8082                	ret

00000000000002cc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2cc:	4885                	li	a7,1
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2d4:	4889                	li	a7,2
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <wait>:
.global wait
wait:
 li a7, SYS_wait
 2dc:	488d                	li	a7,3
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2e4:	4891                	li	a7,4
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <read>:
.global read
read:
 li a7, SYS_read
 2ec:	4895                	li	a7,5
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <write>:
.global write
write:
 li a7, SYS_write
 2f4:	48c1                	li	a7,16
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <close>:
.global close
close:
 li a7, SYS_close
 2fc:	48d5                	li	a7,21
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <kill>:
.global kill
kill:
 li a7, SYS_kill
 304:	4899                	li	a7,6
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <exec>:
.global exec
exec:
 li a7, SYS_exec
 30c:	489d                	li	a7,7
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <open>:
.global open
open:
 li a7, SYS_open
 314:	48bd                	li	a7,15
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 31c:	48c5                	li	a7,17
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 324:	48c9                	li	a7,18
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 32c:	48a1                	li	a7,8
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <link>:
.global link
link:
 li a7, SYS_link
 334:	48cd                	li	a7,19
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 33c:	48d1                	li	a7,20
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 344:	48a5                	li	a7,9
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <dup>:
.global dup
dup:
 li a7, SYS_dup
 34c:	48a9                	li	a7,10
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 354:	48ad                	li	a7,11
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 35c:	48b1                	li	a7,12
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 364:	48b5                	li	a7,13
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 36c:	48b9                	li	a7,14
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <pageAccess>:
.global pageAccess
pageAccess:
 li a7, SYS_pageAccess
 374:	48d9                	li	a7,22
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 37c:	1101                	add	sp,sp,-32
 37e:	ec06                	sd	ra,24(sp)
 380:	e822                	sd	s0,16(sp)
 382:	1000                	add	s0,sp,32
 384:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 388:	4605                	li	a2,1
 38a:	fef40593          	add	a1,s0,-17
 38e:	00000097          	auipc	ra,0x0
 392:	f66080e7          	jalr	-154(ra) # 2f4 <write>
}
 396:	60e2                	ld	ra,24(sp)
 398:	6442                	ld	s0,16(sp)
 39a:	6105                	add	sp,sp,32
 39c:	8082                	ret

000000000000039e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 39e:	7139                	add	sp,sp,-64
 3a0:	fc06                	sd	ra,56(sp)
 3a2:	f822                	sd	s0,48(sp)
 3a4:	f426                	sd	s1,40(sp)
 3a6:	0080                	add	s0,sp,64
 3a8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3aa:	c299                	beqz	a3,3b0 <printint+0x12>
 3ac:	0805cb63          	bltz	a1,442 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3b0:	2581                	sext.w	a1,a1
  neg = 0;
 3b2:	4881                	li	a7,0
 3b4:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 3b8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3ba:	2601                	sext.w	a2,a2
 3bc:	00000517          	auipc	a0,0x0
 3c0:	4bc50513          	add	a0,a0,1212 # 878 <digits>
 3c4:	883a                	mv	a6,a4
 3c6:	2705                	addw	a4,a4,1
 3c8:	02c5f7bb          	remuw	a5,a1,a2
 3cc:	1782                	sll	a5,a5,0x20
 3ce:	9381                	srl	a5,a5,0x20
 3d0:	97aa                	add	a5,a5,a0
 3d2:	0007c783          	lbu	a5,0(a5)
 3d6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3da:	0005879b          	sext.w	a5,a1
 3de:	02c5d5bb          	divuw	a1,a1,a2
 3e2:	0685                	add	a3,a3,1
 3e4:	fec7f0e3          	bgeu	a5,a2,3c4 <printint+0x26>
  if(neg)
 3e8:	00088c63          	beqz	a7,400 <printint+0x62>
    buf[i++] = '-';
 3ec:	fd070793          	add	a5,a4,-48
 3f0:	00878733          	add	a4,a5,s0
 3f4:	02d00793          	li	a5,45
 3f8:	fef70823          	sb	a5,-16(a4)
 3fc:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 400:	02e05c63          	blez	a4,438 <printint+0x9a>
 404:	f04a                	sd	s2,32(sp)
 406:	ec4e                	sd	s3,24(sp)
 408:	fc040793          	add	a5,s0,-64
 40c:	00e78933          	add	s2,a5,a4
 410:	fff78993          	add	s3,a5,-1
 414:	99ba                	add	s3,s3,a4
 416:	377d                	addw	a4,a4,-1
 418:	1702                	sll	a4,a4,0x20
 41a:	9301                	srl	a4,a4,0x20
 41c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 420:	fff94583          	lbu	a1,-1(s2)
 424:	8526                	mv	a0,s1
 426:	00000097          	auipc	ra,0x0
 42a:	f56080e7          	jalr	-170(ra) # 37c <putc>
  while(--i >= 0)
 42e:	197d                	add	s2,s2,-1
 430:	ff3918e3          	bne	s2,s3,420 <printint+0x82>
 434:	7902                	ld	s2,32(sp)
 436:	69e2                	ld	s3,24(sp)
}
 438:	70e2                	ld	ra,56(sp)
 43a:	7442                	ld	s0,48(sp)
 43c:	74a2                	ld	s1,40(sp)
 43e:	6121                	add	sp,sp,64
 440:	8082                	ret
    x = -xx;
 442:	40b005bb          	negw	a1,a1
    neg = 1;
 446:	4885                	li	a7,1
    x = -xx;
 448:	b7b5                	j	3b4 <printint+0x16>

000000000000044a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 44a:	715d                	add	sp,sp,-80
 44c:	e486                	sd	ra,72(sp)
 44e:	e0a2                	sd	s0,64(sp)
 450:	f84a                	sd	s2,48(sp)
 452:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 454:	0005c903          	lbu	s2,0(a1)
 458:	1a090a63          	beqz	s2,60c <vprintf+0x1c2>
 45c:	fc26                	sd	s1,56(sp)
 45e:	f44e                	sd	s3,40(sp)
 460:	f052                	sd	s4,32(sp)
 462:	ec56                	sd	s5,24(sp)
 464:	e85a                	sd	s6,16(sp)
 466:	e45e                	sd	s7,8(sp)
 468:	8aaa                	mv	s5,a0
 46a:	8bb2                	mv	s7,a2
 46c:	00158493          	add	s1,a1,1
  state = 0;
 470:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 472:	02500a13          	li	s4,37
 476:	4b55                	li	s6,21
 478:	a839                	j	496 <vprintf+0x4c>
        putc(fd, c);
 47a:	85ca                	mv	a1,s2
 47c:	8556                	mv	a0,s5
 47e:	00000097          	auipc	ra,0x0
 482:	efe080e7          	jalr	-258(ra) # 37c <putc>
 486:	a019                	j	48c <vprintf+0x42>
    } else if(state == '%'){
 488:	01498d63          	beq	s3,s4,4a2 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 48c:	0485                	add	s1,s1,1
 48e:	fff4c903          	lbu	s2,-1(s1)
 492:	16090763          	beqz	s2,600 <vprintf+0x1b6>
    if(state == 0){
 496:	fe0999e3          	bnez	s3,488 <vprintf+0x3e>
      if(c == '%'){
 49a:	ff4910e3          	bne	s2,s4,47a <vprintf+0x30>
        state = '%';
 49e:	89d2                	mv	s3,s4
 4a0:	b7f5                	j	48c <vprintf+0x42>
      if(c == 'd'){
 4a2:	13490463          	beq	s2,s4,5ca <vprintf+0x180>
 4a6:	f9d9079b          	addw	a5,s2,-99
 4aa:	0ff7f793          	zext.b	a5,a5
 4ae:	12fb6763          	bltu	s6,a5,5dc <vprintf+0x192>
 4b2:	f9d9079b          	addw	a5,s2,-99
 4b6:	0ff7f713          	zext.b	a4,a5
 4ba:	12eb6163          	bltu	s6,a4,5dc <vprintf+0x192>
 4be:	00271793          	sll	a5,a4,0x2
 4c2:	00000717          	auipc	a4,0x0
 4c6:	35e70713          	add	a4,a4,862 # 820 <malloc+0x124>
 4ca:	97ba                	add	a5,a5,a4
 4cc:	439c                	lw	a5,0(a5)
 4ce:	97ba                	add	a5,a5,a4
 4d0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4d2:	008b8913          	add	s2,s7,8
 4d6:	4685                	li	a3,1
 4d8:	4629                	li	a2,10
 4da:	000ba583          	lw	a1,0(s7)
 4de:	8556                	mv	a0,s5
 4e0:	00000097          	auipc	ra,0x0
 4e4:	ebe080e7          	jalr	-322(ra) # 39e <printint>
 4e8:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4ea:	4981                	li	s3,0
 4ec:	b745                	j	48c <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4ee:	008b8913          	add	s2,s7,8
 4f2:	4681                	li	a3,0
 4f4:	4629                	li	a2,10
 4f6:	000ba583          	lw	a1,0(s7)
 4fa:	8556                	mv	a0,s5
 4fc:	00000097          	auipc	ra,0x0
 500:	ea2080e7          	jalr	-350(ra) # 39e <printint>
 504:	8bca                	mv	s7,s2
      state = 0;
 506:	4981                	li	s3,0
 508:	b751                	j	48c <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 50a:	008b8913          	add	s2,s7,8
 50e:	4681                	li	a3,0
 510:	4641                	li	a2,16
 512:	000ba583          	lw	a1,0(s7)
 516:	8556                	mv	a0,s5
 518:	00000097          	auipc	ra,0x0
 51c:	e86080e7          	jalr	-378(ra) # 39e <printint>
 520:	8bca                	mv	s7,s2
      state = 0;
 522:	4981                	li	s3,0
 524:	b7a5                	j	48c <vprintf+0x42>
 526:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 528:	008b8c13          	add	s8,s7,8
 52c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 530:	03000593          	li	a1,48
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	e46080e7          	jalr	-442(ra) # 37c <putc>
  putc(fd, 'x');
 53e:	07800593          	li	a1,120
 542:	8556                	mv	a0,s5
 544:	00000097          	auipc	ra,0x0
 548:	e38080e7          	jalr	-456(ra) # 37c <putc>
 54c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 54e:	00000b97          	auipc	s7,0x0
 552:	32ab8b93          	add	s7,s7,810 # 878 <digits>
 556:	03c9d793          	srl	a5,s3,0x3c
 55a:	97de                	add	a5,a5,s7
 55c:	0007c583          	lbu	a1,0(a5)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	e1a080e7          	jalr	-486(ra) # 37c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 56a:	0992                	sll	s3,s3,0x4
 56c:	397d                	addw	s2,s2,-1
 56e:	fe0914e3          	bnez	s2,556 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 572:	8be2                	mv	s7,s8
      state = 0;
 574:	4981                	li	s3,0
 576:	6c02                	ld	s8,0(sp)
 578:	bf11                	j	48c <vprintf+0x42>
        s = va_arg(ap, char*);
 57a:	008b8993          	add	s3,s7,8
 57e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 582:	02090163          	beqz	s2,5a4 <vprintf+0x15a>
        while(*s != 0){
 586:	00094583          	lbu	a1,0(s2)
 58a:	c9a5                	beqz	a1,5fa <vprintf+0x1b0>
          putc(fd, *s);
 58c:	8556                	mv	a0,s5
 58e:	00000097          	auipc	ra,0x0
 592:	dee080e7          	jalr	-530(ra) # 37c <putc>
          s++;
 596:	0905                	add	s2,s2,1
        while(*s != 0){
 598:	00094583          	lbu	a1,0(s2)
 59c:	f9e5                	bnez	a1,58c <vprintf+0x142>
        s = va_arg(ap, char*);
 59e:	8bce                	mv	s7,s3
      state = 0;
 5a0:	4981                	li	s3,0
 5a2:	b5ed                	j	48c <vprintf+0x42>
          s = "(null)";
 5a4:	00000917          	auipc	s2,0x0
 5a8:	27490913          	add	s2,s2,628 # 818 <malloc+0x11c>
        while(*s != 0){
 5ac:	02800593          	li	a1,40
 5b0:	bff1                	j	58c <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 5b2:	008b8913          	add	s2,s7,8
 5b6:	000bc583          	lbu	a1,0(s7)
 5ba:	8556                	mv	a0,s5
 5bc:	00000097          	auipc	ra,0x0
 5c0:	dc0080e7          	jalr	-576(ra) # 37c <putc>
 5c4:	8bca                	mv	s7,s2
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	b5d1                	j	48c <vprintf+0x42>
        putc(fd, c);
 5ca:	02500593          	li	a1,37
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	dac080e7          	jalr	-596(ra) # 37c <putc>
      state = 0;
 5d8:	4981                	li	s3,0
 5da:	bd4d                	j	48c <vprintf+0x42>
        putc(fd, '%');
 5dc:	02500593          	li	a1,37
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	d9a080e7          	jalr	-614(ra) # 37c <putc>
        putc(fd, c);
 5ea:	85ca                	mv	a1,s2
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	d8e080e7          	jalr	-626(ra) # 37c <putc>
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	bd51                	j	48c <vprintf+0x42>
        s = va_arg(ap, char*);
 5fa:	8bce                	mv	s7,s3
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	b579                	j	48c <vprintf+0x42>
 600:	74e2                	ld	s1,56(sp)
 602:	79a2                	ld	s3,40(sp)
 604:	7a02                	ld	s4,32(sp)
 606:	6ae2                	ld	s5,24(sp)
 608:	6b42                	ld	s6,16(sp)
 60a:	6ba2                	ld	s7,8(sp)
    }
  }
}
 60c:	60a6                	ld	ra,72(sp)
 60e:	6406                	ld	s0,64(sp)
 610:	7942                	ld	s2,48(sp)
 612:	6161                	add	sp,sp,80
 614:	8082                	ret

0000000000000616 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 616:	715d                	add	sp,sp,-80
 618:	ec06                	sd	ra,24(sp)
 61a:	e822                	sd	s0,16(sp)
 61c:	1000                	add	s0,sp,32
 61e:	e010                	sd	a2,0(s0)
 620:	e414                	sd	a3,8(s0)
 622:	e818                	sd	a4,16(s0)
 624:	ec1c                	sd	a5,24(s0)
 626:	03043023          	sd	a6,32(s0)
 62a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 62e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 632:	8622                	mv	a2,s0
 634:	00000097          	auipc	ra,0x0
 638:	e16080e7          	jalr	-490(ra) # 44a <vprintf>
}
 63c:	60e2                	ld	ra,24(sp)
 63e:	6442                	ld	s0,16(sp)
 640:	6161                	add	sp,sp,80
 642:	8082                	ret

0000000000000644 <printf>:

void
printf(const char *fmt, ...)
{
 644:	711d                	add	sp,sp,-96
 646:	ec06                	sd	ra,24(sp)
 648:	e822                	sd	s0,16(sp)
 64a:	1000                	add	s0,sp,32
 64c:	e40c                	sd	a1,8(s0)
 64e:	e810                	sd	a2,16(s0)
 650:	ec14                	sd	a3,24(s0)
 652:	f018                	sd	a4,32(s0)
 654:	f41c                	sd	a5,40(s0)
 656:	03043823          	sd	a6,48(s0)
 65a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 65e:	00840613          	add	a2,s0,8
 662:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 666:	85aa                	mv	a1,a0
 668:	4505                	li	a0,1
 66a:	00000097          	auipc	ra,0x0
 66e:	de0080e7          	jalr	-544(ra) # 44a <vprintf>
}
 672:	60e2                	ld	ra,24(sp)
 674:	6442                	ld	s0,16(sp)
 676:	6125                	add	sp,sp,96
 678:	8082                	ret

000000000000067a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 67a:	1141                	add	sp,sp,-16
 67c:	e422                	sd	s0,8(sp)
 67e:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 680:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 684:	00000797          	auipc	a5,0x0
 688:	20c7b783          	ld	a5,524(a5) # 890 <freep>
 68c:	a02d                	j	6b6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 68e:	4618                	lw	a4,8(a2)
 690:	9f2d                	addw	a4,a4,a1
 692:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 696:	6398                	ld	a4,0(a5)
 698:	6310                	ld	a2,0(a4)
 69a:	a83d                	j	6d8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 69c:	ff852703          	lw	a4,-8(a0)
 6a0:	9f31                	addw	a4,a4,a2
 6a2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6a4:	ff053683          	ld	a3,-16(a0)
 6a8:	a091                	j	6ec <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6aa:	6398                	ld	a4,0(a5)
 6ac:	00e7e463          	bltu	a5,a4,6b4 <free+0x3a>
 6b0:	00e6ea63          	bltu	a3,a4,6c4 <free+0x4a>
{
 6b4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b6:	fed7fae3          	bgeu	a5,a3,6aa <free+0x30>
 6ba:	6398                	ld	a4,0(a5)
 6bc:	00e6e463          	bltu	a3,a4,6c4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c0:	fee7eae3          	bltu	a5,a4,6b4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6c4:	ff852583          	lw	a1,-8(a0)
 6c8:	6390                	ld	a2,0(a5)
 6ca:	02059813          	sll	a6,a1,0x20
 6ce:	01c85713          	srl	a4,a6,0x1c
 6d2:	9736                	add	a4,a4,a3
 6d4:	fae60de3          	beq	a2,a4,68e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6d8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6dc:	4790                	lw	a2,8(a5)
 6de:	02061593          	sll	a1,a2,0x20
 6e2:	01c5d713          	srl	a4,a1,0x1c
 6e6:	973e                	add	a4,a4,a5
 6e8:	fae68ae3          	beq	a3,a4,69c <free+0x22>
    p->s.ptr = bp->s.ptr;
 6ec:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6ee:	00000717          	auipc	a4,0x0
 6f2:	1af73123          	sd	a5,418(a4) # 890 <freep>
}
 6f6:	6422                	ld	s0,8(sp)
 6f8:	0141                	add	sp,sp,16
 6fa:	8082                	ret

00000000000006fc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6fc:	7139                	add	sp,sp,-64
 6fe:	fc06                	sd	ra,56(sp)
 700:	f822                	sd	s0,48(sp)
 702:	f426                	sd	s1,40(sp)
 704:	ec4e                	sd	s3,24(sp)
 706:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 708:	02051493          	sll	s1,a0,0x20
 70c:	9081                	srl	s1,s1,0x20
 70e:	04bd                	add	s1,s1,15
 710:	8091                	srl	s1,s1,0x4
 712:	0014899b          	addw	s3,s1,1
 716:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 718:	00000517          	auipc	a0,0x0
 71c:	17853503          	ld	a0,376(a0) # 890 <freep>
 720:	c915                	beqz	a0,754 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 722:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 724:	4798                	lw	a4,8(a5)
 726:	08977e63          	bgeu	a4,s1,7c2 <malloc+0xc6>
 72a:	f04a                	sd	s2,32(sp)
 72c:	e852                	sd	s4,16(sp)
 72e:	e456                	sd	s5,8(sp)
 730:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 732:	8a4e                	mv	s4,s3
 734:	0009871b          	sext.w	a4,s3
 738:	6685                	lui	a3,0x1
 73a:	00d77363          	bgeu	a4,a3,740 <malloc+0x44>
 73e:	6a05                	lui	s4,0x1
 740:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 744:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 748:	00000917          	auipc	s2,0x0
 74c:	14890913          	add	s2,s2,328 # 890 <freep>
  if(p == (char*)-1)
 750:	5afd                	li	s5,-1
 752:	a091                	j	796 <malloc+0x9a>
 754:	f04a                	sd	s2,32(sp)
 756:	e852                	sd	s4,16(sp)
 758:	e456                	sd	s5,8(sp)
 75a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 75c:	00000797          	auipc	a5,0x0
 760:	13c78793          	add	a5,a5,316 # 898 <base>
 764:	00000717          	auipc	a4,0x0
 768:	12f73623          	sd	a5,300(a4) # 890 <freep>
 76c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 76e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 772:	b7c1                	j	732 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 774:	6398                	ld	a4,0(a5)
 776:	e118                	sd	a4,0(a0)
 778:	a08d                	j	7da <malloc+0xde>
  hp->s.size = nu;
 77a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 77e:	0541                	add	a0,a0,16
 780:	00000097          	auipc	ra,0x0
 784:	efa080e7          	jalr	-262(ra) # 67a <free>
  return freep;
 788:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 78c:	c13d                	beqz	a0,7f2 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 78e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 790:	4798                	lw	a4,8(a5)
 792:	02977463          	bgeu	a4,s1,7ba <malloc+0xbe>
    if(p == freep)
 796:	00093703          	ld	a4,0(s2)
 79a:	853e                	mv	a0,a5
 79c:	fef719e3          	bne	a4,a5,78e <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7a0:	8552                	mv	a0,s4
 7a2:	00000097          	auipc	ra,0x0
 7a6:	bba080e7          	jalr	-1094(ra) # 35c <sbrk>
  if(p == (char*)-1)
 7aa:	fd5518e3          	bne	a0,s5,77a <malloc+0x7e>
        return 0;
 7ae:	4501                	li	a0,0
 7b0:	7902                	ld	s2,32(sp)
 7b2:	6a42                	ld	s4,16(sp)
 7b4:	6aa2                	ld	s5,8(sp)
 7b6:	6b02                	ld	s6,0(sp)
 7b8:	a03d                	j	7e6 <malloc+0xea>
 7ba:	7902                	ld	s2,32(sp)
 7bc:	6a42                	ld	s4,16(sp)
 7be:	6aa2                	ld	s5,8(sp)
 7c0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7c2:	fae489e3          	beq	s1,a4,774 <malloc+0x78>
        p->s.size -= nunits;
 7c6:	4137073b          	subw	a4,a4,s3
 7ca:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7cc:	02071693          	sll	a3,a4,0x20
 7d0:	01c6d713          	srl	a4,a3,0x1c
 7d4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7d6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7da:	00000717          	auipc	a4,0x0
 7de:	0aa73b23          	sd	a0,182(a4) # 890 <freep>
      return (void*)(p + 1);
 7e2:	01078513          	add	a0,a5,16
  }
}
 7e6:	70e2                	ld	ra,56(sp)
 7e8:	7442                	ld	s0,48(sp)
 7ea:	74a2                	ld	s1,40(sp)
 7ec:	69e2                	ld	s3,24(sp)
 7ee:	6121                	add	sp,sp,64
 7f0:	8082                	ret
 7f2:	7902                	ld	s2,32(sp)
 7f4:	6a42                	ld	s4,16(sp)
 7f6:	6aa2                	ld	s5,8(sp)
 7f8:	6b02                	ld	s6,0(sp)
 7fa:	b7f5                	j	7e6 <malloc+0xea>
