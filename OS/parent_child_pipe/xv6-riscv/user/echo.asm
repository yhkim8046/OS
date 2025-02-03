
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
  34:	7f0a8a93          	add	s5,s5,2032 # 820 <malloc+0x106>
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
  76:	7b658593          	add	a1,a1,1974 # 828 <malloc+0x10e>
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

000000000000039a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 39a:	1101                	add	sp,sp,-32
 39c:	ec06                	sd	ra,24(sp)
 39e:	e822                	sd	s0,16(sp)
 3a0:	1000                	add	s0,sp,32
 3a2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3a6:	4605                	li	a2,1
 3a8:	fef40593          	add	a1,s0,-17
 3ac:	00000097          	auipc	ra,0x0
 3b0:	f6e080e7          	jalr	-146(ra) # 31a <write>
}
 3b4:	60e2                	ld	ra,24(sp)
 3b6:	6442                	ld	s0,16(sp)
 3b8:	6105                	add	sp,sp,32
 3ba:	8082                	ret

00000000000003bc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3bc:	7139                	add	sp,sp,-64
 3be:	fc06                	sd	ra,56(sp)
 3c0:	f822                	sd	s0,48(sp)
 3c2:	f426                	sd	s1,40(sp)
 3c4:	0080                	add	s0,sp,64
 3c6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3c8:	c299                	beqz	a3,3ce <printint+0x12>
 3ca:	0805cb63          	bltz	a1,460 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3ce:	2581                	sext.w	a1,a1
  neg = 0;
 3d0:	4881                	li	a7,0
 3d2:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 3d6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3d8:	2601                	sext.w	a2,a2
 3da:	00000517          	auipc	a0,0x0
 3de:	4b650513          	add	a0,a0,1206 # 890 <digits>
 3e2:	883a                	mv	a6,a4
 3e4:	2705                	addw	a4,a4,1
 3e6:	02c5f7bb          	remuw	a5,a1,a2
 3ea:	1782                	sll	a5,a5,0x20
 3ec:	9381                	srl	a5,a5,0x20
 3ee:	97aa                	add	a5,a5,a0
 3f0:	0007c783          	lbu	a5,0(a5)
 3f4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3f8:	0005879b          	sext.w	a5,a1
 3fc:	02c5d5bb          	divuw	a1,a1,a2
 400:	0685                	add	a3,a3,1
 402:	fec7f0e3          	bgeu	a5,a2,3e2 <printint+0x26>
  if(neg)
 406:	00088c63          	beqz	a7,41e <printint+0x62>
    buf[i++] = '-';
 40a:	fd070793          	add	a5,a4,-48
 40e:	00878733          	add	a4,a5,s0
 412:	02d00793          	li	a5,45
 416:	fef70823          	sb	a5,-16(a4)
 41a:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 41e:	02e05c63          	blez	a4,456 <printint+0x9a>
 422:	f04a                	sd	s2,32(sp)
 424:	ec4e                	sd	s3,24(sp)
 426:	fc040793          	add	a5,s0,-64
 42a:	00e78933          	add	s2,a5,a4
 42e:	fff78993          	add	s3,a5,-1
 432:	99ba                	add	s3,s3,a4
 434:	377d                	addw	a4,a4,-1
 436:	1702                	sll	a4,a4,0x20
 438:	9301                	srl	a4,a4,0x20
 43a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 43e:	fff94583          	lbu	a1,-1(s2)
 442:	8526                	mv	a0,s1
 444:	00000097          	auipc	ra,0x0
 448:	f56080e7          	jalr	-170(ra) # 39a <putc>
  while(--i >= 0)
 44c:	197d                	add	s2,s2,-1
 44e:	ff3918e3          	bne	s2,s3,43e <printint+0x82>
 452:	7902                	ld	s2,32(sp)
 454:	69e2                	ld	s3,24(sp)
}
 456:	70e2                	ld	ra,56(sp)
 458:	7442                	ld	s0,48(sp)
 45a:	74a2                	ld	s1,40(sp)
 45c:	6121                	add	sp,sp,64
 45e:	8082                	ret
    x = -xx;
 460:	40b005bb          	negw	a1,a1
    neg = 1;
 464:	4885                	li	a7,1
    x = -xx;
 466:	b7b5                	j	3d2 <printint+0x16>

0000000000000468 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 468:	715d                	add	sp,sp,-80
 46a:	e486                	sd	ra,72(sp)
 46c:	e0a2                	sd	s0,64(sp)
 46e:	f84a                	sd	s2,48(sp)
 470:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 472:	0005c903          	lbu	s2,0(a1)
 476:	1a090a63          	beqz	s2,62a <vprintf+0x1c2>
 47a:	fc26                	sd	s1,56(sp)
 47c:	f44e                	sd	s3,40(sp)
 47e:	f052                	sd	s4,32(sp)
 480:	ec56                	sd	s5,24(sp)
 482:	e85a                	sd	s6,16(sp)
 484:	e45e                	sd	s7,8(sp)
 486:	8aaa                	mv	s5,a0
 488:	8bb2                	mv	s7,a2
 48a:	00158493          	add	s1,a1,1
  state = 0;
 48e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 490:	02500a13          	li	s4,37
 494:	4b55                	li	s6,21
 496:	a839                	j	4b4 <vprintf+0x4c>
        putc(fd, c);
 498:	85ca                	mv	a1,s2
 49a:	8556                	mv	a0,s5
 49c:	00000097          	auipc	ra,0x0
 4a0:	efe080e7          	jalr	-258(ra) # 39a <putc>
 4a4:	a019                	j	4aa <vprintf+0x42>
    } else if(state == '%'){
 4a6:	01498d63          	beq	s3,s4,4c0 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4aa:	0485                	add	s1,s1,1
 4ac:	fff4c903          	lbu	s2,-1(s1)
 4b0:	16090763          	beqz	s2,61e <vprintf+0x1b6>
    if(state == 0){
 4b4:	fe0999e3          	bnez	s3,4a6 <vprintf+0x3e>
      if(c == '%'){
 4b8:	ff4910e3          	bne	s2,s4,498 <vprintf+0x30>
        state = '%';
 4bc:	89d2                	mv	s3,s4
 4be:	b7f5                	j	4aa <vprintf+0x42>
      if(c == 'd'){
 4c0:	13490463          	beq	s2,s4,5e8 <vprintf+0x180>
 4c4:	f9d9079b          	addw	a5,s2,-99
 4c8:	0ff7f793          	zext.b	a5,a5
 4cc:	12fb6763          	bltu	s6,a5,5fa <vprintf+0x192>
 4d0:	f9d9079b          	addw	a5,s2,-99
 4d4:	0ff7f713          	zext.b	a4,a5
 4d8:	12eb6163          	bltu	s6,a4,5fa <vprintf+0x192>
 4dc:	00271793          	sll	a5,a4,0x2
 4e0:	00000717          	auipc	a4,0x0
 4e4:	35870713          	add	a4,a4,856 # 838 <malloc+0x11e>
 4e8:	97ba                	add	a5,a5,a4
 4ea:	439c                	lw	a5,0(a5)
 4ec:	97ba                	add	a5,a5,a4
 4ee:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4f0:	008b8913          	add	s2,s7,8
 4f4:	4685                	li	a3,1
 4f6:	4629                	li	a2,10
 4f8:	000ba583          	lw	a1,0(s7)
 4fc:	8556                	mv	a0,s5
 4fe:	00000097          	auipc	ra,0x0
 502:	ebe080e7          	jalr	-322(ra) # 3bc <printint>
 506:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 508:	4981                	li	s3,0
 50a:	b745                	j	4aa <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 50c:	008b8913          	add	s2,s7,8
 510:	4681                	li	a3,0
 512:	4629                	li	a2,10
 514:	000ba583          	lw	a1,0(s7)
 518:	8556                	mv	a0,s5
 51a:	00000097          	auipc	ra,0x0
 51e:	ea2080e7          	jalr	-350(ra) # 3bc <printint>
 522:	8bca                	mv	s7,s2
      state = 0;
 524:	4981                	li	s3,0
 526:	b751                	j	4aa <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 528:	008b8913          	add	s2,s7,8
 52c:	4681                	li	a3,0
 52e:	4641                	li	a2,16
 530:	000ba583          	lw	a1,0(s7)
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	e86080e7          	jalr	-378(ra) # 3bc <printint>
 53e:	8bca                	mv	s7,s2
      state = 0;
 540:	4981                	li	s3,0
 542:	b7a5                	j	4aa <vprintf+0x42>
 544:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 546:	008b8c13          	add	s8,s7,8
 54a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 54e:	03000593          	li	a1,48
 552:	8556                	mv	a0,s5
 554:	00000097          	auipc	ra,0x0
 558:	e46080e7          	jalr	-442(ra) # 39a <putc>
  putc(fd, 'x');
 55c:	07800593          	li	a1,120
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	e38080e7          	jalr	-456(ra) # 39a <putc>
 56a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 56c:	00000b97          	auipc	s7,0x0
 570:	324b8b93          	add	s7,s7,804 # 890 <digits>
 574:	03c9d793          	srl	a5,s3,0x3c
 578:	97de                	add	a5,a5,s7
 57a:	0007c583          	lbu	a1,0(a5)
 57e:	8556                	mv	a0,s5
 580:	00000097          	auipc	ra,0x0
 584:	e1a080e7          	jalr	-486(ra) # 39a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 588:	0992                	sll	s3,s3,0x4
 58a:	397d                	addw	s2,s2,-1
 58c:	fe0914e3          	bnez	s2,574 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 590:	8be2                	mv	s7,s8
      state = 0;
 592:	4981                	li	s3,0
 594:	6c02                	ld	s8,0(sp)
 596:	bf11                	j	4aa <vprintf+0x42>
        s = va_arg(ap, char*);
 598:	008b8993          	add	s3,s7,8
 59c:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5a0:	02090163          	beqz	s2,5c2 <vprintf+0x15a>
        while(*s != 0){
 5a4:	00094583          	lbu	a1,0(s2)
 5a8:	c9a5                	beqz	a1,618 <vprintf+0x1b0>
          putc(fd, *s);
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	dee080e7          	jalr	-530(ra) # 39a <putc>
          s++;
 5b4:	0905                	add	s2,s2,1
        while(*s != 0){
 5b6:	00094583          	lbu	a1,0(s2)
 5ba:	f9e5                	bnez	a1,5aa <vprintf+0x142>
        s = va_arg(ap, char*);
 5bc:	8bce                	mv	s7,s3
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	b5ed                	j	4aa <vprintf+0x42>
          s = "(null)";
 5c2:	00000917          	auipc	s2,0x0
 5c6:	26e90913          	add	s2,s2,622 # 830 <malloc+0x116>
        while(*s != 0){
 5ca:	02800593          	li	a1,40
 5ce:	bff1                	j	5aa <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 5d0:	008b8913          	add	s2,s7,8
 5d4:	000bc583          	lbu	a1,0(s7)
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	dc0080e7          	jalr	-576(ra) # 39a <putc>
 5e2:	8bca                	mv	s7,s2
      state = 0;
 5e4:	4981                	li	s3,0
 5e6:	b5d1                	j	4aa <vprintf+0x42>
        putc(fd, c);
 5e8:	02500593          	li	a1,37
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	dac080e7          	jalr	-596(ra) # 39a <putc>
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	bd4d                	j	4aa <vprintf+0x42>
        putc(fd, '%');
 5fa:	02500593          	li	a1,37
 5fe:	8556                	mv	a0,s5
 600:	00000097          	auipc	ra,0x0
 604:	d9a080e7          	jalr	-614(ra) # 39a <putc>
        putc(fd, c);
 608:	85ca                	mv	a1,s2
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	d8e080e7          	jalr	-626(ra) # 39a <putc>
      state = 0;
 614:	4981                	li	s3,0
 616:	bd51                	j	4aa <vprintf+0x42>
        s = va_arg(ap, char*);
 618:	8bce                	mv	s7,s3
      state = 0;
 61a:	4981                	li	s3,0
 61c:	b579                	j	4aa <vprintf+0x42>
 61e:	74e2                	ld	s1,56(sp)
 620:	79a2                	ld	s3,40(sp)
 622:	7a02                	ld	s4,32(sp)
 624:	6ae2                	ld	s5,24(sp)
 626:	6b42                	ld	s6,16(sp)
 628:	6ba2                	ld	s7,8(sp)
    }
  }
}
 62a:	60a6                	ld	ra,72(sp)
 62c:	6406                	ld	s0,64(sp)
 62e:	7942                	ld	s2,48(sp)
 630:	6161                	add	sp,sp,80
 632:	8082                	ret

0000000000000634 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 634:	715d                	add	sp,sp,-80
 636:	ec06                	sd	ra,24(sp)
 638:	e822                	sd	s0,16(sp)
 63a:	1000                	add	s0,sp,32
 63c:	e010                	sd	a2,0(s0)
 63e:	e414                	sd	a3,8(s0)
 640:	e818                	sd	a4,16(s0)
 642:	ec1c                	sd	a5,24(s0)
 644:	03043023          	sd	a6,32(s0)
 648:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 64c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 650:	8622                	mv	a2,s0
 652:	00000097          	auipc	ra,0x0
 656:	e16080e7          	jalr	-490(ra) # 468 <vprintf>
}
 65a:	60e2                	ld	ra,24(sp)
 65c:	6442                	ld	s0,16(sp)
 65e:	6161                	add	sp,sp,80
 660:	8082                	ret

0000000000000662 <printf>:

void
printf(const char *fmt, ...)
{
 662:	711d                	add	sp,sp,-96
 664:	ec06                	sd	ra,24(sp)
 666:	e822                	sd	s0,16(sp)
 668:	1000                	add	s0,sp,32
 66a:	e40c                	sd	a1,8(s0)
 66c:	e810                	sd	a2,16(s0)
 66e:	ec14                	sd	a3,24(s0)
 670:	f018                	sd	a4,32(s0)
 672:	f41c                	sd	a5,40(s0)
 674:	03043823          	sd	a6,48(s0)
 678:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 67c:	00840613          	add	a2,s0,8
 680:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 684:	85aa                	mv	a1,a0
 686:	4505                	li	a0,1
 688:	00000097          	auipc	ra,0x0
 68c:	de0080e7          	jalr	-544(ra) # 468 <vprintf>
}
 690:	60e2                	ld	ra,24(sp)
 692:	6442                	ld	s0,16(sp)
 694:	6125                	add	sp,sp,96
 696:	8082                	ret

0000000000000698 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 698:	1141                	add	sp,sp,-16
 69a:	e422                	sd	s0,8(sp)
 69c:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 69e:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6a2:	00000797          	auipc	a5,0x0
 6a6:	2067b783          	ld	a5,518(a5) # 8a8 <freep>
 6aa:	a02d                	j	6d4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ac:	4618                	lw	a4,8(a2)
 6ae:	9f2d                	addw	a4,a4,a1
 6b0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6b4:	6398                	ld	a4,0(a5)
 6b6:	6310                	ld	a2,0(a4)
 6b8:	a83d                	j	6f6 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6ba:	ff852703          	lw	a4,-8(a0)
 6be:	9f31                	addw	a4,a4,a2
 6c0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6c2:	ff053683          	ld	a3,-16(a0)
 6c6:	a091                	j	70a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c8:	6398                	ld	a4,0(a5)
 6ca:	00e7e463          	bltu	a5,a4,6d2 <free+0x3a>
 6ce:	00e6ea63          	bltu	a3,a4,6e2 <free+0x4a>
{
 6d2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6d4:	fed7fae3          	bgeu	a5,a3,6c8 <free+0x30>
 6d8:	6398                	ld	a4,0(a5)
 6da:	00e6e463          	bltu	a3,a4,6e2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6de:	fee7eae3          	bltu	a5,a4,6d2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6e2:	ff852583          	lw	a1,-8(a0)
 6e6:	6390                	ld	a2,0(a5)
 6e8:	02059813          	sll	a6,a1,0x20
 6ec:	01c85713          	srl	a4,a6,0x1c
 6f0:	9736                	add	a4,a4,a3
 6f2:	fae60de3          	beq	a2,a4,6ac <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6f6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6fa:	4790                	lw	a2,8(a5)
 6fc:	02061593          	sll	a1,a2,0x20
 700:	01c5d713          	srl	a4,a1,0x1c
 704:	973e                	add	a4,a4,a5
 706:	fae68ae3          	beq	a3,a4,6ba <free+0x22>
    p->s.ptr = bp->s.ptr;
 70a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 70c:	00000717          	auipc	a4,0x0
 710:	18f73e23          	sd	a5,412(a4) # 8a8 <freep>
}
 714:	6422                	ld	s0,8(sp)
 716:	0141                	add	sp,sp,16
 718:	8082                	ret

000000000000071a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 71a:	7139                	add	sp,sp,-64
 71c:	fc06                	sd	ra,56(sp)
 71e:	f822                	sd	s0,48(sp)
 720:	f426                	sd	s1,40(sp)
 722:	ec4e                	sd	s3,24(sp)
 724:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 726:	02051493          	sll	s1,a0,0x20
 72a:	9081                	srl	s1,s1,0x20
 72c:	04bd                	add	s1,s1,15
 72e:	8091                	srl	s1,s1,0x4
 730:	0014899b          	addw	s3,s1,1
 734:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 736:	00000517          	auipc	a0,0x0
 73a:	17253503          	ld	a0,370(a0) # 8a8 <freep>
 73e:	c915                	beqz	a0,772 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 740:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 742:	4798                	lw	a4,8(a5)
 744:	08977e63          	bgeu	a4,s1,7e0 <malloc+0xc6>
 748:	f04a                	sd	s2,32(sp)
 74a:	e852                	sd	s4,16(sp)
 74c:	e456                	sd	s5,8(sp)
 74e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 750:	8a4e                	mv	s4,s3
 752:	0009871b          	sext.w	a4,s3
 756:	6685                	lui	a3,0x1
 758:	00d77363          	bgeu	a4,a3,75e <malloc+0x44>
 75c:	6a05                	lui	s4,0x1
 75e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 762:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 766:	00000917          	auipc	s2,0x0
 76a:	14290913          	add	s2,s2,322 # 8a8 <freep>
  if(p == (char*)-1)
 76e:	5afd                	li	s5,-1
 770:	a091                	j	7b4 <malloc+0x9a>
 772:	f04a                	sd	s2,32(sp)
 774:	e852                	sd	s4,16(sp)
 776:	e456                	sd	s5,8(sp)
 778:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 77a:	00000797          	auipc	a5,0x0
 77e:	13678793          	add	a5,a5,310 # 8b0 <base>
 782:	00000717          	auipc	a4,0x0
 786:	12f73323          	sd	a5,294(a4) # 8a8 <freep>
 78a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 78c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 790:	b7c1                	j	750 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 792:	6398                	ld	a4,0(a5)
 794:	e118                	sd	a4,0(a0)
 796:	a08d                	j	7f8 <malloc+0xde>
  hp->s.size = nu;
 798:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 79c:	0541                	add	a0,a0,16
 79e:	00000097          	auipc	ra,0x0
 7a2:	efa080e7          	jalr	-262(ra) # 698 <free>
  return freep;
 7a6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7aa:	c13d                	beqz	a0,810 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ac:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ae:	4798                	lw	a4,8(a5)
 7b0:	02977463          	bgeu	a4,s1,7d8 <malloc+0xbe>
    if(p == freep)
 7b4:	00093703          	ld	a4,0(s2)
 7b8:	853e                	mv	a0,a5
 7ba:	fef719e3          	bne	a4,a5,7ac <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7be:	8552                	mv	a0,s4
 7c0:	00000097          	auipc	ra,0x0
 7c4:	bc2080e7          	jalr	-1086(ra) # 382 <sbrk>
  if(p == (char*)-1)
 7c8:	fd5518e3          	bne	a0,s5,798 <malloc+0x7e>
        return 0;
 7cc:	4501                	li	a0,0
 7ce:	7902                	ld	s2,32(sp)
 7d0:	6a42                	ld	s4,16(sp)
 7d2:	6aa2                	ld	s5,8(sp)
 7d4:	6b02                	ld	s6,0(sp)
 7d6:	a03d                	j	804 <malloc+0xea>
 7d8:	7902                	ld	s2,32(sp)
 7da:	6a42                	ld	s4,16(sp)
 7dc:	6aa2                	ld	s5,8(sp)
 7de:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7e0:	fae489e3          	beq	s1,a4,792 <malloc+0x78>
        p->s.size -= nunits;
 7e4:	4137073b          	subw	a4,a4,s3
 7e8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7ea:	02071693          	sll	a3,a4,0x20
 7ee:	01c6d713          	srl	a4,a3,0x1c
 7f2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7f4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7f8:	00000717          	auipc	a4,0x0
 7fc:	0aa73823          	sd	a0,176(a4) # 8a8 <freep>
      return (void*)(p + 1);
 800:	01078513          	add	a0,a5,16
  }
}
 804:	70e2                	ld	ra,56(sp)
 806:	7442                	ld	s0,48(sp)
 808:	74a2                	ld	s1,40(sp)
 80a:	69e2                	ld	s3,24(sp)
 80c:	6121                	add	sp,sp,64
 80e:	8082                	ret
 810:	7902                	ld	s2,32(sp)
 812:	6a42                	ld	s4,16(sp)
 814:	6aa2                	ld	s5,8(sp)
 816:	6b02                	ld	s6,0(sp)
 818:	b7f5                	j	804 <malloc+0xea>
