
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	add	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	add	s0,sp,64
  int i;

  for(i = 1; i < argc; i++){
  12:	4785                	li	a5,1
  14:	06a7d863          	bge	a5,a0,84 <main+0x84>
  18:	00858493          	add	s1,a1,8
  1c:	3579                	addw	a0,a0,-2
  1e:	02051793          	sll	a5,a0,0x20
  22:	01d7d513          	srl	a0,a5,0x1d
  26:	00a48a33          	add	s4,s1,a0
  2a:	05c1                	add	a1,a1,16
  2c:	00a589b3          	add	s3,a1,a0
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  30:	00000a97          	auipc	s5,0x0
  34:	7f8a8a93          	add	s5,s5,2040 # 828 <malloc+0x106>
  38:	a819                	j	4e <main+0x4e>
  3a:	4605                	li	a2,1
  3c:	85d6                	mv	a1,s5
  3e:	4505                	li	a0,1
  40:	00000097          	auipc	ra,0x0
  44:	2da080e7          	jalr	730(ra) # 31a <write>
  for(i = 1; i < argc; i++){
  48:	04a1                	add	s1,s1,8
  4a:	03348d63          	beq	s1,s3,84 <main+0x84>
    write(1, argv[i], strlen(argv[i]));
  4e:	0004b903          	ld	s2,0(s1)
  52:	854a                	mv	a0,s2
  54:	00000097          	auipc	ra,0x0
  58:	082080e7          	jalr	130(ra) # d6 <strlen>
  5c:	0005061b          	sext.w	a2,a0
  60:	85ca                	mv	a1,s2
  62:	4505                	li	a0,1
  64:	00000097          	auipc	ra,0x0
  68:	2b6080e7          	jalr	694(ra) # 31a <write>
    if(i + 1 < argc){
  6c:	fd4497e3          	bne	s1,s4,3a <main+0x3a>
    } else {
      write(1, "\n", 1);
  70:	4605                	li	a2,1
  72:	00000597          	auipc	a1,0x0
  76:	7be58593          	add	a1,a1,1982 # 830 <malloc+0x10e>
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	29e080e7          	jalr	670(ra) # 31a <write>
    }
  }
  exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	274080e7          	jalr	628(ra) # 2fa <exit>

000000000000008e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  8e:	1141                	add	sp,sp,-16
  90:	e422                	sd	s0,8(sp)
  92:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  94:	87aa                	mv	a5,a0
  96:	0585                	add	a1,a1,1
  98:	0785                	add	a5,a5,1
  9a:	fff5c703          	lbu	a4,-1(a1)
  9e:	fee78fa3          	sb	a4,-1(a5)
  a2:	fb75                	bnez	a4,96 <strcpy+0x8>
    ;
  return os;
}
  a4:	6422                	ld	s0,8(sp)
  a6:	0141                	add	sp,sp,16
  a8:	8082                	ret

00000000000000aa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  aa:	1141                	add	sp,sp,-16
  ac:	e422                	sd	s0,8(sp)
  ae:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  b0:	00054783          	lbu	a5,0(a0)
  b4:	cb91                	beqz	a5,c8 <strcmp+0x1e>
  b6:	0005c703          	lbu	a4,0(a1)
  ba:	00f71763          	bne	a4,a5,c8 <strcmp+0x1e>
    p++, q++;
  be:	0505                	add	a0,a0,1
  c0:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  c2:	00054783          	lbu	a5,0(a0)
  c6:	fbe5                	bnez	a5,b6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  c8:	0005c503          	lbu	a0,0(a1)
}
  cc:	40a7853b          	subw	a0,a5,a0
  d0:	6422                	ld	s0,8(sp)
  d2:	0141                	add	sp,sp,16
  d4:	8082                	ret

00000000000000d6 <strlen>:

uint
strlen(const char *s)
{
  d6:	1141                	add	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	cf91                	beqz	a5,fc <strlen+0x26>
  e2:	0505                	add	a0,a0,1
  e4:	87aa                	mv	a5,a0
  e6:	86be                	mv	a3,a5
  e8:	0785                	add	a5,a5,1
  ea:	fff7c703          	lbu	a4,-1(a5)
  ee:	ff65                	bnez	a4,e6 <strlen+0x10>
  f0:	40a6853b          	subw	a0,a3,a0
  f4:	2505                	addw	a0,a0,1
    ;
  return n;
}
  f6:	6422                	ld	s0,8(sp)
  f8:	0141                	add	sp,sp,16
  fa:	8082                	ret
  for(n = 0; s[n]; n++)
  fc:	4501                	li	a0,0
  fe:	bfe5                	j	f6 <strlen+0x20>

0000000000000100 <memset>:

void*
memset(void *dst, int c, uint n)
{
 100:	1141                	add	sp,sp,-16
 102:	e422                	sd	s0,8(sp)
 104:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 106:	ca19                	beqz	a2,11c <memset+0x1c>
 108:	87aa                	mv	a5,a0
 10a:	1602                	sll	a2,a2,0x20
 10c:	9201                	srl	a2,a2,0x20
 10e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 112:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 116:	0785                	add	a5,a5,1
 118:	fee79de3          	bne	a5,a4,112 <memset+0x12>
  }
  return dst;
}
 11c:	6422                	ld	s0,8(sp)
 11e:	0141                	add	sp,sp,16
 120:	8082                	ret

0000000000000122 <strchr>:

char*
strchr(const char *s, char c)
{
 122:	1141                	add	sp,sp,-16
 124:	e422                	sd	s0,8(sp)
 126:	0800                	add	s0,sp,16
  for(; *s; s++)
 128:	00054783          	lbu	a5,0(a0)
 12c:	cb99                	beqz	a5,142 <strchr+0x20>
    if(*s == c)
 12e:	00f58763          	beq	a1,a5,13c <strchr+0x1a>
  for(; *s; s++)
 132:	0505                	add	a0,a0,1
 134:	00054783          	lbu	a5,0(a0)
 138:	fbfd                	bnez	a5,12e <strchr+0xc>
      return (char*)s;
  return 0;
 13a:	4501                	li	a0,0
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	add	sp,sp,16
 140:	8082                	ret
  return 0;
 142:	4501                	li	a0,0
 144:	bfe5                	j	13c <strchr+0x1a>

0000000000000146 <gets>:

char*
gets(char *buf, int max)
{
 146:	711d                	add	sp,sp,-96
 148:	ec86                	sd	ra,88(sp)
 14a:	e8a2                	sd	s0,80(sp)
 14c:	e4a6                	sd	s1,72(sp)
 14e:	e0ca                	sd	s2,64(sp)
 150:	fc4e                	sd	s3,56(sp)
 152:	f852                	sd	s4,48(sp)
 154:	f456                	sd	s5,40(sp)
 156:	f05a                	sd	s6,32(sp)
 158:	ec5e                	sd	s7,24(sp)
 15a:	1080                	add	s0,sp,96
 15c:	8baa                	mv	s7,a0
 15e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 160:	892a                	mv	s2,a0
 162:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 164:	4aa9                	li	s5,10
 166:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 168:	89a6                	mv	s3,s1
 16a:	2485                	addw	s1,s1,1
 16c:	0344d863          	bge	s1,s4,19c <gets+0x56>
    cc = read(0, &c, 1);
 170:	4605                	li	a2,1
 172:	faf40593          	add	a1,s0,-81
 176:	4501                	li	a0,0
 178:	00000097          	auipc	ra,0x0
 17c:	19a080e7          	jalr	410(ra) # 312 <read>
    if(cc < 1)
 180:	00a05e63          	blez	a0,19c <gets+0x56>
    buf[i++] = c;
 184:	faf44783          	lbu	a5,-81(s0)
 188:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 18c:	01578763          	beq	a5,s5,19a <gets+0x54>
 190:	0905                	add	s2,s2,1
 192:	fd679be3          	bne	a5,s6,168 <gets+0x22>
    buf[i++] = c;
 196:	89a6                	mv	s3,s1
 198:	a011                	j	19c <gets+0x56>
 19a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 19c:	99de                	add	s3,s3,s7
 19e:	00098023          	sb	zero,0(s3)
  return buf;
}
 1a2:	855e                	mv	a0,s7
 1a4:	60e6                	ld	ra,88(sp)
 1a6:	6446                	ld	s0,80(sp)
 1a8:	64a6                	ld	s1,72(sp)
 1aa:	6906                	ld	s2,64(sp)
 1ac:	79e2                	ld	s3,56(sp)
 1ae:	7a42                	ld	s4,48(sp)
 1b0:	7aa2                	ld	s5,40(sp)
 1b2:	7b02                	ld	s6,32(sp)
 1b4:	6be2                	ld	s7,24(sp)
 1b6:	6125                	add	sp,sp,96
 1b8:	8082                	ret

00000000000001ba <stat>:

int
stat(const char *n, struct stat *st)
{
 1ba:	1101                	add	sp,sp,-32
 1bc:	ec06                	sd	ra,24(sp)
 1be:	e822                	sd	s0,16(sp)
 1c0:	e04a                	sd	s2,0(sp)
 1c2:	1000                	add	s0,sp,32
 1c4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c6:	4581                	li	a1,0
 1c8:	00000097          	auipc	ra,0x0
 1cc:	172080e7          	jalr	370(ra) # 33a <open>
  if(fd < 0)
 1d0:	02054663          	bltz	a0,1fc <stat+0x42>
 1d4:	e426                	sd	s1,8(sp)
 1d6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1d8:	85ca                	mv	a1,s2
 1da:	00000097          	auipc	ra,0x0
 1de:	178080e7          	jalr	376(ra) # 352 <fstat>
 1e2:	892a                	mv	s2,a0
  close(fd);
 1e4:	8526                	mv	a0,s1
 1e6:	00000097          	auipc	ra,0x0
 1ea:	13c080e7          	jalr	316(ra) # 322 <close>
  return r;
 1ee:	64a2                	ld	s1,8(sp)
}
 1f0:	854a                	mv	a0,s2
 1f2:	60e2                	ld	ra,24(sp)
 1f4:	6442                	ld	s0,16(sp)
 1f6:	6902                	ld	s2,0(sp)
 1f8:	6105                	add	sp,sp,32
 1fa:	8082                	ret
    return -1;
 1fc:	597d                	li	s2,-1
 1fe:	bfcd                	j	1f0 <stat+0x36>

0000000000000200 <atoi>:

int
atoi(const char *s)
{
 200:	1141                	add	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 206:	00054683          	lbu	a3,0(a0)
 20a:	fd06879b          	addw	a5,a3,-48
 20e:	0ff7f793          	zext.b	a5,a5
 212:	4625                	li	a2,9
 214:	02f66863          	bltu	a2,a5,244 <atoi+0x44>
 218:	872a                	mv	a4,a0
  n = 0;
 21a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 21c:	0705                	add	a4,a4,1
 21e:	0025179b          	sllw	a5,a0,0x2
 222:	9fa9                	addw	a5,a5,a0
 224:	0017979b          	sllw	a5,a5,0x1
 228:	9fb5                	addw	a5,a5,a3
 22a:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 22e:	00074683          	lbu	a3,0(a4)
 232:	fd06879b          	addw	a5,a3,-48
 236:	0ff7f793          	zext.b	a5,a5
 23a:	fef671e3          	bgeu	a2,a5,21c <atoi+0x1c>
  return n;
}
 23e:	6422                	ld	s0,8(sp)
 240:	0141                	add	sp,sp,16
 242:	8082                	ret
  n = 0;
 244:	4501                	li	a0,0
 246:	bfe5                	j	23e <atoi+0x3e>

0000000000000248 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 248:	1141                	add	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 24e:	02b57463          	bgeu	a0,a1,276 <memmove+0x2e>
    while(n-- > 0)
 252:	00c05f63          	blez	a2,270 <memmove+0x28>
 256:	1602                	sll	a2,a2,0x20
 258:	9201                	srl	a2,a2,0x20
 25a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 25e:	872a                	mv	a4,a0
      *dst++ = *src++;
 260:	0585                	add	a1,a1,1
 262:	0705                	add	a4,a4,1
 264:	fff5c683          	lbu	a3,-1(a1)
 268:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 26c:	fef71ae3          	bne	a4,a5,260 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 270:	6422                	ld	s0,8(sp)
 272:	0141                	add	sp,sp,16
 274:	8082                	ret
    dst += n;
 276:	00c50733          	add	a4,a0,a2
    src += n;
 27a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 27c:	fec05ae3          	blez	a2,270 <memmove+0x28>
 280:	fff6079b          	addw	a5,a2,-1
 284:	1782                	sll	a5,a5,0x20
 286:	9381                	srl	a5,a5,0x20
 288:	fff7c793          	not	a5,a5
 28c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 28e:	15fd                	add	a1,a1,-1
 290:	177d                	add	a4,a4,-1
 292:	0005c683          	lbu	a3,0(a1)
 296:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 29a:	fee79ae3          	bne	a5,a4,28e <memmove+0x46>
 29e:	bfc9                	j	270 <memmove+0x28>

00000000000002a0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2a0:	1141                	add	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a6:	ca05                	beqz	a2,2d6 <memcmp+0x36>
 2a8:	fff6069b          	addw	a3,a2,-1
 2ac:	1682                	sll	a3,a3,0x20
 2ae:	9281                	srl	a3,a3,0x20
 2b0:	0685                	add	a3,a3,1
 2b2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2b4:	00054783          	lbu	a5,0(a0)
 2b8:	0005c703          	lbu	a4,0(a1)
 2bc:	00e79863          	bne	a5,a4,2cc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2c0:	0505                	add	a0,a0,1
    p2++;
 2c2:	0585                	add	a1,a1,1
  while (n-- > 0) {
 2c4:	fed518e3          	bne	a0,a3,2b4 <memcmp+0x14>
  }
  return 0;
 2c8:	4501                	li	a0,0
 2ca:	a019                	j	2d0 <memcmp+0x30>
      return *p1 - *p2;
 2cc:	40e7853b          	subw	a0,a5,a4
}
 2d0:	6422                	ld	s0,8(sp)
 2d2:	0141                	add	sp,sp,16
 2d4:	8082                	ret
  return 0;
 2d6:	4501                	li	a0,0
 2d8:	bfe5                	j	2d0 <memcmp+0x30>

00000000000002da <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2da:	1141                	add	sp,sp,-16
 2dc:	e406                	sd	ra,8(sp)
 2de:	e022                	sd	s0,0(sp)
 2e0:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 2e2:	00000097          	auipc	ra,0x0
 2e6:	f66080e7          	jalr	-154(ra) # 248 <memmove>
}
 2ea:	60a2                	ld	ra,8(sp)
 2ec:	6402                	ld	s0,0(sp)
 2ee:	0141                	add	sp,sp,16
 2f0:	8082                	ret

00000000000002f2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2f2:	4885                	li	a7,1
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <exit>:
.global exit
exit:
 li a7, SYS_exit
 2fa:	4889                	li	a7,2
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <wait>:
.global wait
wait:
 li a7, SYS_wait
 302:	488d                	li	a7,3
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 30a:	4891                	li	a7,4
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <read>:
.global read
read:
 li a7, SYS_read
 312:	4895                	li	a7,5
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <write>:
.global write
write:
 li a7, SYS_write
 31a:	48c1                	li	a7,16
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <close>:
.global close
close:
 li a7, SYS_close
 322:	48d5                	li	a7,21
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <kill>:
.global kill
kill:
 li a7, SYS_kill
 32a:	4899                	li	a7,6
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <exec>:
.global exec
exec:
 li a7, SYS_exec
 332:	489d                	li	a7,7
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <open>:
.global open
open:
 li a7, SYS_open
 33a:	48bd                	li	a7,15
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 342:	48c5                	li	a7,17
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 34a:	48c9                	li	a7,18
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 352:	48a1                	li	a7,8
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <link>:
.global link
link:
 li a7, SYS_link
 35a:	48cd                	li	a7,19
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 362:	48d1                	li	a7,20
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 36a:	48a5                	li	a7,9
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <dup>:
.global dup
dup:
 li a7, SYS_dup
 372:	48a9                	li	a7,10
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 37a:	48ad                	li	a7,11
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 382:	48b1                	li	a7,12
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 38a:	48b5                	li	a7,13
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 392:	48b9                	li	a7,14
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <pageAccess>:
.global pageAccess
pageAccess:
 li a7, SYS_pageAccess
 39a:	48d9                	li	a7,22
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a2:	1101                	add	sp,sp,-32
 3a4:	ec06                	sd	ra,24(sp)
 3a6:	e822                	sd	s0,16(sp)
 3a8:	1000                	add	s0,sp,32
 3aa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ae:	4605                	li	a2,1
 3b0:	fef40593          	add	a1,s0,-17
 3b4:	00000097          	auipc	ra,0x0
 3b8:	f66080e7          	jalr	-154(ra) # 31a <write>
}
 3bc:	60e2                	ld	ra,24(sp)
 3be:	6442                	ld	s0,16(sp)
 3c0:	6105                	add	sp,sp,32
 3c2:	8082                	ret

00000000000003c4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c4:	7139                	add	sp,sp,-64
 3c6:	fc06                	sd	ra,56(sp)
 3c8:	f822                	sd	s0,48(sp)
 3ca:	f426                	sd	s1,40(sp)
 3cc:	0080                	add	s0,sp,64
 3ce:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3d0:	c299                	beqz	a3,3d6 <printint+0x12>
 3d2:	0805cb63          	bltz	a1,468 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3d6:	2581                	sext.w	a1,a1
  neg = 0;
 3d8:	4881                	li	a7,0
 3da:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 3de:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3e0:	2601                	sext.w	a2,a2
 3e2:	00000517          	auipc	a0,0x0
 3e6:	4b650513          	add	a0,a0,1206 # 898 <digits>
 3ea:	883a                	mv	a6,a4
 3ec:	2705                	addw	a4,a4,1
 3ee:	02c5f7bb          	remuw	a5,a1,a2
 3f2:	1782                	sll	a5,a5,0x20
 3f4:	9381                	srl	a5,a5,0x20
 3f6:	97aa                	add	a5,a5,a0
 3f8:	0007c783          	lbu	a5,0(a5)
 3fc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 400:	0005879b          	sext.w	a5,a1
 404:	02c5d5bb          	divuw	a1,a1,a2
 408:	0685                	add	a3,a3,1
 40a:	fec7f0e3          	bgeu	a5,a2,3ea <printint+0x26>
  if(neg)
 40e:	00088c63          	beqz	a7,426 <printint+0x62>
    buf[i++] = '-';
 412:	fd070793          	add	a5,a4,-48
 416:	00878733          	add	a4,a5,s0
 41a:	02d00793          	li	a5,45
 41e:	fef70823          	sb	a5,-16(a4)
 422:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 426:	02e05c63          	blez	a4,45e <printint+0x9a>
 42a:	f04a                	sd	s2,32(sp)
 42c:	ec4e                	sd	s3,24(sp)
 42e:	fc040793          	add	a5,s0,-64
 432:	00e78933          	add	s2,a5,a4
 436:	fff78993          	add	s3,a5,-1
 43a:	99ba                	add	s3,s3,a4
 43c:	377d                	addw	a4,a4,-1
 43e:	1702                	sll	a4,a4,0x20
 440:	9301                	srl	a4,a4,0x20
 442:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 446:	fff94583          	lbu	a1,-1(s2)
 44a:	8526                	mv	a0,s1
 44c:	00000097          	auipc	ra,0x0
 450:	f56080e7          	jalr	-170(ra) # 3a2 <putc>
  while(--i >= 0)
 454:	197d                	add	s2,s2,-1
 456:	ff3918e3          	bne	s2,s3,446 <printint+0x82>
 45a:	7902                	ld	s2,32(sp)
 45c:	69e2                	ld	s3,24(sp)
}
 45e:	70e2                	ld	ra,56(sp)
 460:	7442                	ld	s0,48(sp)
 462:	74a2                	ld	s1,40(sp)
 464:	6121                	add	sp,sp,64
 466:	8082                	ret
    x = -xx;
 468:	40b005bb          	negw	a1,a1
    neg = 1;
 46c:	4885                	li	a7,1
    x = -xx;
 46e:	b7b5                	j	3da <printint+0x16>

0000000000000470 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 470:	715d                	add	sp,sp,-80
 472:	e486                	sd	ra,72(sp)
 474:	e0a2                	sd	s0,64(sp)
 476:	f84a                	sd	s2,48(sp)
 478:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 47a:	0005c903          	lbu	s2,0(a1)
 47e:	1a090a63          	beqz	s2,632 <vprintf+0x1c2>
 482:	fc26                	sd	s1,56(sp)
 484:	f44e                	sd	s3,40(sp)
 486:	f052                	sd	s4,32(sp)
 488:	ec56                	sd	s5,24(sp)
 48a:	e85a                	sd	s6,16(sp)
 48c:	e45e                	sd	s7,8(sp)
 48e:	8aaa                	mv	s5,a0
 490:	8bb2                	mv	s7,a2
 492:	00158493          	add	s1,a1,1
  state = 0;
 496:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 498:	02500a13          	li	s4,37
 49c:	4b55                	li	s6,21
 49e:	a839                	j	4bc <vprintf+0x4c>
        putc(fd, c);
 4a0:	85ca                	mv	a1,s2
 4a2:	8556                	mv	a0,s5
 4a4:	00000097          	auipc	ra,0x0
 4a8:	efe080e7          	jalr	-258(ra) # 3a2 <putc>
 4ac:	a019                	j	4b2 <vprintf+0x42>
    } else if(state == '%'){
 4ae:	01498d63          	beq	s3,s4,4c8 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4b2:	0485                	add	s1,s1,1
 4b4:	fff4c903          	lbu	s2,-1(s1)
 4b8:	16090763          	beqz	s2,626 <vprintf+0x1b6>
    if(state == 0){
 4bc:	fe0999e3          	bnez	s3,4ae <vprintf+0x3e>
      if(c == '%'){
 4c0:	ff4910e3          	bne	s2,s4,4a0 <vprintf+0x30>
        state = '%';
 4c4:	89d2                	mv	s3,s4
 4c6:	b7f5                	j	4b2 <vprintf+0x42>
      if(c == 'd'){
 4c8:	13490463          	beq	s2,s4,5f0 <vprintf+0x180>
 4cc:	f9d9079b          	addw	a5,s2,-99
 4d0:	0ff7f793          	zext.b	a5,a5
 4d4:	12fb6763          	bltu	s6,a5,602 <vprintf+0x192>
 4d8:	f9d9079b          	addw	a5,s2,-99
 4dc:	0ff7f713          	zext.b	a4,a5
 4e0:	12eb6163          	bltu	s6,a4,602 <vprintf+0x192>
 4e4:	00271793          	sll	a5,a4,0x2
 4e8:	00000717          	auipc	a4,0x0
 4ec:	35870713          	add	a4,a4,856 # 840 <malloc+0x11e>
 4f0:	97ba                	add	a5,a5,a4
 4f2:	439c                	lw	a5,0(a5)
 4f4:	97ba                	add	a5,a5,a4
 4f6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4f8:	008b8913          	add	s2,s7,8
 4fc:	4685                	li	a3,1
 4fe:	4629                	li	a2,10
 500:	000ba583          	lw	a1,0(s7)
 504:	8556                	mv	a0,s5
 506:	00000097          	auipc	ra,0x0
 50a:	ebe080e7          	jalr	-322(ra) # 3c4 <printint>
 50e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 510:	4981                	li	s3,0
 512:	b745                	j	4b2 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 514:	008b8913          	add	s2,s7,8
 518:	4681                	li	a3,0
 51a:	4629                	li	a2,10
 51c:	000ba583          	lw	a1,0(s7)
 520:	8556                	mv	a0,s5
 522:	00000097          	auipc	ra,0x0
 526:	ea2080e7          	jalr	-350(ra) # 3c4 <printint>
 52a:	8bca                	mv	s7,s2
      state = 0;
 52c:	4981                	li	s3,0
 52e:	b751                	j	4b2 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 530:	008b8913          	add	s2,s7,8
 534:	4681                	li	a3,0
 536:	4641                	li	a2,16
 538:	000ba583          	lw	a1,0(s7)
 53c:	8556                	mv	a0,s5
 53e:	00000097          	auipc	ra,0x0
 542:	e86080e7          	jalr	-378(ra) # 3c4 <printint>
 546:	8bca                	mv	s7,s2
      state = 0;
 548:	4981                	li	s3,0
 54a:	b7a5                	j	4b2 <vprintf+0x42>
 54c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 54e:	008b8c13          	add	s8,s7,8
 552:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 556:	03000593          	li	a1,48
 55a:	8556                	mv	a0,s5
 55c:	00000097          	auipc	ra,0x0
 560:	e46080e7          	jalr	-442(ra) # 3a2 <putc>
  putc(fd, 'x');
 564:	07800593          	li	a1,120
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	e38080e7          	jalr	-456(ra) # 3a2 <putc>
 572:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 574:	00000b97          	auipc	s7,0x0
 578:	324b8b93          	add	s7,s7,804 # 898 <digits>
 57c:	03c9d793          	srl	a5,s3,0x3c
 580:	97de                	add	a5,a5,s7
 582:	0007c583          	lbu	a1,0(a5)
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	e1a080e7          	jalr	-486(ra) # 3a2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 590:	0992                	sll	s3,s3,0x4
 592:	397d                	addw	s2,s2,-1
 594:	fe0914e3          	bnez	s2,57c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 598:	8be2                	mv	s7,s8
      state = 0;
 59a:	4981                	li	s3,0
 59c:	6c02                	ld	s8,0(sp)
 59e:	bf11                	j	4b2 <vprintf+0x42>
        s = va_arg(ap, char*);
 5a0:	008b8993          	add	s3,s7,8
 5a4:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5a8:	02090163          	beqz	s2,5ca <vprintf+0x15a>
        while(*s != 0){
 5ac:	00094583          	lbu	a1,0(s2)
 5b0:	c9a5                	beqz	a1,620 <vprintf+0x1b0>
          putc(fd, *s);
 5b2:	8556                	mv	a0,s5
 5b4:	00000097          	auipc	ra,0x0
 5b8:	dee080e7          	jalr	-530(ra) # 3a2 <putc>
          s++;
 5bc:	0905                	add	s2,s2,1
        while(*s != 0){
 5be:	00094583          	lbu	a1,0(s2)
 5c2:	f9e5                	bnez	a1,5b2 <vprintf+0x142>
        s = va_arg(ap, char*);
 5c4:	8bce                	mv	s7,s3
      state = 0;
 5c6:	4981                	li	s3,0
 5c8:	b5ed                	j	4b2 <vprintf+0x42>
          s = "(null)";
 5ca:	00000917          	auipc	s2,0x0
 5ce:	26e90913          	add	s2,s2,622 # 838 <malloc+0x116>
        while(*s != 0){
 5d2:	02800593          	li	a1,40
 5d6:	bff1                	j	5b2 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 5d8:	008b8913          	add	s2,s7,8
 5dc:	000bc583          	lbu	a1,0(s7)
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	dc0080e7          	jalr	-576(ra) # 3a2 <putc>
 5ea:	8bca                	mv	s7,s2
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	b5d1                	j	4b2 <vprintf+0x42>
        putc(fd, c);
 5f0:	02500593          	li	a1,37
 5f4:	8556                	mv	a0,s5
 5f6:	00000097          	auipc	ra,0x0
 5fa:	dac080e7          	jalr	-596(ra) # 3a2 <putc>
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bd4d                	j	4b2 <vprintf+0x42>
        putc(fd, '%');
 602:	02500593          	li	a1,37
 606:	8556                	mv	a0,s5
 608:	00000097          	auipc	ra,0x0
 60c:	d9a080e7          	jalr	-614(ra) # 3a2 <putc>
        putc(fd, c);
 610:	85ca                	mv	a1,s2
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	d8e080e7          	jalr	-626(ra) # 3a2 <putc>
      state = 0;
 61c:	4981                	li	s3,0
 61e:	bd51                	j	4b2 <vprintf+0x42>
        s = va_arg(ap, char*);
 620:	8bce                	mv	s7,s3
      state = 0;
 622:	4981                	li	s3,0
 624:	b579                	j	4b2 <vprintf+0x42>
 626:	74e2                	ld	s1,56(sp)
 628:	79a2                	ld	s3,40(sp)
 62a:	7a02                	ld	s4,32(sp)
 62c:	6ae2                	ld	s5,24(sp)
 62e:	6b42                	ld	s6,16(sp)
 630:	6ba2                	ld	s7,8(sp)
    }
  }
}
 632:	60a6                	ld	ra,72(sp)
 634:	6406                	ld	s0,64(sp)
 636:	7942                	ld	s2,48(sp)
 638:	6161                	add	sp,sp,80
 63a:	8082                	ret

000000000000063c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 63c:	715d                	add	sp,sp,-80
 63e:	ec06                	sd	ra,24(sp)
 640:	e822                	sd	s0,16(sp)
 642:	1000                	add	s0,sp,32
 644:	e010                	sd	a2,0(s0)
 646:	e414                	sd	a3,8(s0)
 648:	e818                	sd	a4,16(s0)
 64a:	ec1c                	sd	a5,24(s0)
 64c:	03043023          	sd	a6,32(s0)
 650:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 654:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 658:	8622                	mv	a2,s0
 65a:	00000097          	auipc	ra,0x0
 65e:	e16080e7          	jalr	-490(ra) # 470 <vprintf>
}
 662:	60e2                	ld	ra,24(sp)
 664:	6442                	ld	s0,16(sp)
 666:	6161                	add	sp,sp,80
 668:	8082                	ret

000000000000066a <printf>:

void
printf(const char *fmt, ...)
{
 66a:	711d                	add	sp,sp,-96
 66c:	ec06                	sd	ra,24(sp)
 66e:	e822                	sd	s0,16(sp)
 670:	1000                	add	s0,sp,32
 672:	e40c                	sd	a1,8(s0)
 674:	e810                	sd	a2,16(s0)
 676:	ec14                	sd	a3,24(s0)
 678:	f018                	sd	a4,32(s0)
 67a:	f41c                	sd	a5,40(s0)
 67c:	03043823          	sd	a6,48(s0)
 680:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 684:	00840613          	add	a2,s0,8
 688:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 68c:	85aa                	mv	a1,a0
 68e:	4505                	li	a0,1
 690:	00000097          	auipc	ra,0x0
 694:	de0080e7          	jalr	-544(ra) # 470 <vprintf>
}
 698:	60e2                	ld	ra,24(sp)
 69a:	6442                	ld	s0,16(sp)
 69c:	6125                	add	sp,sp,96
 69e:	8082                	ret

00000000000006a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6a0:	1141                	add	sp,sp,-16
 6a2:	e422                	sd	s0,8(sp)
 6a4:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6a6:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6aa:	00000797          	auipc	a5,0x0
 6ae:	2067b783          	ld	a5,518(a5) # 8b0 <freep>
 6b2:	a02d                	j	6dc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6b4:	4618                	lw	a4,8(a2)
 6b6:	9f2d                	addw	a4,a4,a1
 6b8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6bc:	6398                	ld	a4,0(a5)
 6be:	6310                	ld	a2,0(a4)
 6c0:	a83d                	j	6fe <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6c2:	ff852703          	lw	a4,-8(a0)
 6c6:	9f31                	addw	a4,a4,a2
 6c8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6ca:	ff053683          	ld	a3,-16(a0)
 6ce:	a091                	j	712 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6d0:	6398                	ld	a4,0(a5)
 6d2:	00e7e463          	bltu	a5,a4,6da <free+0x3a>
 6d6:	00e6ea63          	bltu	a3,a4,6ea <free+0x4a>
{
 6da:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6dc:	fed7fae3          	bgeu	a5,a3,6d0 <free+0x30>
 6e0:	6398                	ld	a4,0(a5)
 6e2:	00e6e463          	bltu	a3,a4,6ea <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e6:	fee7eae3          	bltu	a5,a4,6da <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6ea:	ff852583          	lw	a1,-8(a0)
 6ee:	6390                	ld	a2,0(a5)
 6f0:	02059813          	sll	a6,a1,0x20
 6f4:	01c85713          	srl	a4,a6,0x1c
 6f8:	9736                	add	a4,a4,a3
 6fa:	fae60de3          	beq	a2,a4,6b4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6fe:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 702:	4790                	lw	a2,8(a5)
 704:	02061593          	sll	a1,a2,0x20
 708:	01c5d713          	srl	a4,a1,0x1c
 70c:	973e                	add	a4,a4,a5
 70e:	fae68ae3          	beq	a3,a4,6c2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 712:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 714:	00000717          	auipc	a4,0x0
 718:	18f73e23          	sd	a5,412(a4) # 8b0 <freep>
}
 71c:	6422                	ld	s0,8(sp)
 71e:	0141                	add	sp,sp,16
 720:	8082                	ret

0000000000000722 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 722:	7139                	add	sp,sp,-64
 724:	fc06                	sd	ra,56(sp)
 726:	f822                	sd	s0,48(sp)
 728:	f426                	sd	s1,40(sp)
 72a:	ec4e                	sd	s3,24(sp)
 72c:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 72e:	02051493          	sll	s1,a0,0x20
 732:	9081                	srl	s1,s1,0x20
 734:	04bd                	add	s1,s1,15
 736:	8091                	srl	s1,s1,0x4
 738:	0014899b          	addw	s3,s1,1
 73c:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 73e:	00000517          	auipc	a0,0x0
 742:	17253503          	ld	a0,370(a0) # 8b0 <freep>
 746:	c915                	beqz	a0,77a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 748:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 74a:	4798                	lw	a4,8(a5)
 74c:	08977e63          	bgeu	a4,s1,7e8 <malloc+0xc6>
 750:	f04a                	sd	s2,32(sp)
 752:	e852                	sd	s4,16(sp)
 754:	e456                	sd	s5,8(sp)
 756:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 758:	8a4e                	mv	s4,s3
 75a:	0009871b          	sext.w	a4,s3
 75e:	6685                	lui	a3,0x1
 760:	00d77363          	bgeu	a4,a3,766 <malloc+0x44>
 764:	6a05                	lui	s4,0x1
 766:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 76a:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 76e:	00000917          	auipc	s2,0x0
 772:	14290913          	add	s2,s2,322 # 8b0 <freep>
  if(p == (char*)-1)
 776:	5afd                	li	s5,-1
 778:	a091                	j	7bc <malloc+0x9a>
 77a:	f04a                	sd	s2,32(sp)
 77c:	e852                	sd	s4,16(sp)
 77e:	e456                	sd	s5,8(sp)
 780:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 782:	00000797          	auipc	a5,0x0
 786:	13678793          	add	a5,a5,310 # 8b8 <base>
 78a:	00000717          	auipc	a4,0x0
 78e:	12f73323          	sd	a5,294(a4) # 8b0 <freep>
 792:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 794:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 798:	b7c1                	j	758 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 79a:	6398                	ld	a4,0(a5)
 79c:	e118                	sd	a4,0(a0)
 79e:	a08d                	j	800 <malloc+0xde>
  hp->s.size = nu;
 7a0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7a4:	0541                	add	a0,a0,16
 7a6:	00000097          	auipc	ra,0x0
 7aa:	efa080e7          	jalr	-262(ra) # 6a0 <free>
  return freep;
 7ae:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7b2:	c13d                	beqz	a0,818 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b6:	4798                	lw	a4,8(a5)
 7b8:	02977463          	bgeu	a4,s1,7e0 <malloc+0xbe>
    if(p == freep)
 7bc:	00093703          	ld	a4,0(s2)
 7c0:	853e                	mv	a0,a5
 7c2:	fef719e3          	bne	a4,a5,7b4 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7c6:	8552                	mv	a0,s4
 7c8:	00000097          	auipc	ra,0x0
 7cc:	bba080e7          	jalr	-1094(ra) # 382 <sbrk>
  if(p == (char*)-1)
 7d0:	fd5518e3          	bne	a0,s5,7a0 <malloc+0x7e>
        return 0;
 7d4:	4501                	li	a0,0
 7d6:	7902                	ld	s2,32(sp)
 7d8:	6a42                	ld	s4,16(sp)
 7da:	6aa2                	ld	s5,8(sp)
 7dc:	6b02                	ld	s6,0(sp)
 7de:	a03d                	j	80c <malloc+0xea>
 7e0:	7902                	ld	s2,32(sp)
 7e2:	6a42                	ld	s4,16(sp)
 7e4:	6aa2                	ld	s5,8(sp)
 7e6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7e8:	fae489e3          	beq	s1,a4,79a <malloc+0x78>
        p->s.size -= nunits;
 7ec:	4137073b          	subw	a4,a4,s3
 7f0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7f2:	02071693          	sll	a3,a4,0x20
 7f6:	01c6d713          	srl	a4,a3,0x1c
 7fa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7fc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 800:	00000717          	auipc	a4,0x0
 804:	0aa73823          	sd	a0,176(a4) # 8b0 <freep>
      return (void*)(p + 1);
 808:	01078513          	add	a0,a5,16
  }
}
 80c:	70e2                	ld	ra,56(sp)
 80e:	7442                	ld	s0,48(sp)
 810:	74a2                	ld	s1,40(sp)
 812:	69e2                	ld	s3,24(sp)
 814:	6121                	add	sp,sp,64
 816:	8082                	ret
 818:	7902                	ld	s2,32(sp)
 81a:	6a42                	ld	s4,16(sp)
 81c:	6aa2                	ld	s5,8(sp)
 81e:	6b02                	ld	s6,0(sp)
 820:	b7f5                	j	80c <malloc+0xea>
