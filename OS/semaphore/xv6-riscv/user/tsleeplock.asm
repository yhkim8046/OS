
user/_tsleeplock:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#define NUMPROCS 10

int sys_testlock(void);

int main() {
   0:	1101                	add	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	add	s0,sp,32
    int i, pid;
    testlock(); // main process acquires the sleeplock
   c:	00000097          	auipc	ra,0x0
  10:	38c080e7          	jalr	908(ra) # 398 <testlock>

    // First create NUMPROCS child processes
    for (i = 0; i < NUMPROCS; i++) {
  14:	4481                	li	s1,0
        pid = fork();
        if (pid) {
            printf("process %d is created\n", i);
  16:	00001917          	auipc	s2,0x1
  1a:	81a90913          	add	s2,s2,-2022 # 830 <malloc+0x100>
        pid = fork();
  1e:	00000097          	auipc	ra,0x0
  22:	2d2080e7          	jalr	722(ra) # 2f0 <fork>
        if (pid) {
  26:	cd0d                	beqz	a0,60 <main+0x60>
            printf("process %d is created\n", i);
  28:	85a6                	mv	a1,s1
  2a:	854a                	mv	a0,s2
  2c:	00000097          	auipc	ra,0x0
  30:	64c080e7          	jalr	1612(ra) # 678 <printf>
            sleep(10);
  34:	4529                	li	a0,10
  36:	00000097          	auipc	ra,0x0
  3a:	352080e7          	jalr	850(ra) # 388 <sleep>
    for (i = 0; i < NUMPROCS; i++) {
  3e:	2485                	addw	s1,s1,1
  40:	47a9                	li	a5,10
  42:	fcf49ee3          	bne	s1,a5,1e <main+0x1e>
            break;
        }
    }

    if (pid) {
        testlock(); // main process releases the sleeplock
  46:	00000097          	auipc	ra,0x0
  4a:	352080e7          	jalr	850(ra) # 398 <testlock>
  4e:	44a9                	li	s1,10
        for (i = 0; i < NUMPROCS; i++) {
            wait(0); // wait for each child process to complete
  50:	4501                	li	a0,0
  52:	00000097          	auipc	ra,0x0
  56:	2ae080e7          	jalr	686(ra) # 300 <wait>
        for (i = 0; i < NUMPROCS; i++) {
  5a:	34fd                	addw	s1,s1,-1
  5c:	f8f5                	bnez	s1,50 <main+0x50>
  5e:	a015                	j	82 <main+0x82>
        }
    } else { // child process
        testlock(); // tries to acquire sleeplock, made to sleep if held by another process
  60:	00000097          	auipc	ra,0x0
  64:	338080e7          	jalr	824(ra) # 398 <testlock>
        int childNumber = i; // Pass the value of i to the child process
        printf("%d have acquired lock\n", childNumber); // acquired the sleeplock
  68:	85a6                	mv	a1,s1
  6a:	00000517          	auipc	a0,0x0
  6e:	7de50513          	add	a0,a0,2014 # 848 <malloc+0x118>
  72:	00000097          	auipc	ra,0x0
  76:	606080e7          	jalr	1542(ra) # 678 <printf>
        testlock(); // releases the sleeplock held
  7a:	00000097          	auipc	ra,0x0
  7e:	31e080e7          	jalr	798(ra) # 398 <testlock>
    }

    exit(0);
  82:	4501                	li	a0,0
  84:	00000097          	auipc	ra,0x0
  88:	274080e7          	jalr	628(ra) # 2f8 <exit>

000000000000008c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  8c:	1141                	add	sp,sp,-16
  8e:	e422                	sd	s0,8(sp)
  90:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  92:	87aa                	mv	a5,a0
  94:	0585                	add	a1,a1,1
  96:	0785                	add	a5,a5,1
  98:	fff5c703          	lbu	a4,-1(a1)
  9c:	fee78fa3          	sb	a4,-1(a5)
  a0:	fb75                	bnez	a4,94 <strcpy+0x8>
    ;
  return os;
}
  a2:	6422                	ld	s0,8(sp)
  a4:	0141                	add	sp,sp,16
  a6:	8082                	ret

00000000000000a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a8:	1141                	add	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  ae:	00054783          	lbu	a5,0(a0)
  b2:	cb91                	beqz	a5,c6 <strcmp+0x1e>
  b4:	0005c703          	lbu	a4,0(a1)
  b8:	00f71763          	bne	a4,a5,c6 <strcmp+0x1e>
    p++, q++;
  bc:	0505                	add	a0,a0,1
  be:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  c0:	00054783          	lbu	a5,0(a0)
  c4:	fbe5                	bnez	a5,b4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  c6:	0005c503          	lbu	a0,0(a1)
}
  ca:	40a7853b          	subw	a0,a5,a0
  ce:	6422                	ld	s0,8(sp)
  d0:	0141                	add	sp,sp,16
  d2:	8082                	ret

00000000000000d4 <strlen>:

uint
strlen(const char *s)
{
  d4:	1141                	add	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  da:	00054783          	lbu	a5,0(a0)
  de:	cf91                	beqz	a5,fa <strlen+0x26>
  e0:	0505                	add	a0,a0,1
  e2:	87aa                	mv	a5,a0
  e4:	86be                	mv	a3,a5
  e6:	0785                	add	a5,a5,1
  e8:	fff7c703          	lbu	a4,-1(a5)
  ec:	ff65                	bnez	a4,e4 <strlen+0x10>
  ee:	40a6853b          	subw	a0,a3,a0
  f2:	2505                	addw	a0,a0,1
    ;
  return n;
}
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	add	sp,sp,16
  f8:	8082                	ret
  for(n = 0; s[n]; n++)
  fa:	4501                	li	a0,0
  fc:	bfe5                	j	f4 <strlen+0x20>

00000000000000fe <memset>:

void*
memset(void *dst, int c, uint n)
{
  fe:	1141                	add	sp,sp,-16
 100:	e422                	sd	s0,8(sp)
 102:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 104:	ca19                	beqz	a2,11a <memset+0x1c>
 106:	87aa                	mv	a5,a0
 108:	1602                	sll	a2,a2,0x20
 10a:	9201                	srl	a2,a2,0x20
 10c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 110:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 114:	0785                	add	a5,a5,1
 116:	fee79de3          	bne	a5,a4,110 <memset+0x12>
  }
  return dst;
}
 11a:	6422                	ld	s0,8(sp)
 11c:	0141                	add	sp,sp,16
 11e:	8082                	ret

0000000000000120 <strchr>:

char*
strchr(const char *s, char c)
{
 120:	1141                	add	sp,sp,-16
 122:	e422                	sd	s0,8(sp)
 124:	0800                	add	s0,sp,16
  for(; *s; s++)
 126:	00054783          	lbu	a5,0(a0)
 12a:	cb99                	beqz	a5,140 <strchr+0x20>
    if(*s == c)
 12c:	00f58763          	beq	a1,a5,13a <strchr+0x1a>
  for(; *s; s++)
 130:	0505                	add	a0,a0,1
 132:	00054783          	lbu	a5,0(a0)
 136:	fbfd                	bnez	a5,12c <strchr+0xc>
      return (char*)s;
  return 0;
 138:	4501                	li	a0,0
}
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	add	sp,sp,16
 13e:	8082                	ret
  return 0;
 140:	4501                	li	a0,0
 142:	bfe5                	j	13a <strchr+0x1a>

0000000000000144 <gets>:

char*
gets(char *buf, int max)
{
 144:	711d                	add	sp,sp,-96
 146:	ec86                	sd	ra,88(sp)
 148:	e8a2                	sd	s0,80(sp)
 14a:	e4a6                	sd	s1,72(sp)
 14c:	e0ca                	sd	s2,64(sp)
 14e:	fc4e                	sd	s3,56(sp)
 150:	f852                	sd	s4,48(sp)
 152:	f456                	sd	s5,40(sp)
 154:	f05a                	sd	s6,32(sp)
 156:	ec5e                	sd	s7,24(sp)
 158:	1080                	add	s0,sp,96
 15a:	8baa                	mv	s7,a0
 15c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15e:	892a                	mv	s2,a0
 160:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 162:	4aa9                	li	s5,10
 164:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 166:	89a6                	mv	s3,s1
 168:	2485                	addw	s1,s1,1
 16a:	0344d863          	bge	s1,s4,19a <gets+0x56>
    cc = read(0, &c, 1);
 16e:	4605                	li	a2,1
 170:	faf40593          	add	a1,s0,-81
 174:	4501                	li	a0,0
 176:	00000097          	auipc	ra,0x0
 17a:	19a080e7          	jalr	410(ra) # 310 <read>
    if(cc < 1)
 17e:	00a05e63          	blez	a0,19a <gets+0x56>
    buf[i++] = c;
 182:	faf44783          	lbu	a5,-81(s0)
 186:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 18a:	01578763          	beq	a5,s5,198 <gets+0x54>
 18e:	0905                	add	s2,s2,1
 190:	fd679be3          	bne	a5,s6,166 <gets+0x22>
    buf[i++] = c;
 194:	89a6                	mv	s3,s1
 196:	a011                	j	19a <gets+0x56>
 198:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 19a:	99de                	add	s3,s3,s7
 19c:	00098023          	sb	zero,0(s3)
  return buf;
}
 1a0:	855e                	mv	a0,s7
 1a2:	60e6                	ld	ra,88(sp)
 1a4:	6446                	ld	s0,80(sp)
 1a6:	64a6                	ld	s1,72(sp)
 1a8:	6906                	ld	s2,64(sp)
 1aa:	79e2                	ld	s3,56(sp)
 1ac:	7a42                	ld	s4,48(sp)
 1ae:	7aa2                	ld	s5,40(sp)
 1b0:	7b02                	ld	s6,32(sp)
 1b2:	6be2                	ld	s7,24(sp)
 1b4:	6125                	add	sp,sp,96
 1b6:	8082                	ret

00000000000001b8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b8:	1101                	add	sp,sp,-32
 1ba:	ec06                	sd	ra,24(sp)
 1bc:	e822                	sd	s0,16(sp)
 1be:	e04a                	sd	s2,0(sp)
 1c0:	1000                	add	s0,sp,32
 1c2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c4:	4581                	li	a1,0
 1c6:	00000097          	auipc	ra,0x0
 1ca:	172080e7          	jalr	370(ra) # 338 <open>
  if(fd < 0)
 1ce:	02054663          	bltz	a0,1fa <stat+0x42>
 1d2:	e426                	sd	s1,8(sp)
 1d4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1d6:	85ca                	mv	a1,s2
 1d8:	00000097          	auipc	ra,0x0
 1dc:	178080e7          	jalr	376(ra) # 350 <fstat>
 1e0:	892a                	mv	s2,a0
  close(fd);
 1e2:	8526                	mv	a0,s1
 1e4:	00000097          	auipc	ra,0x0
 1e8:	13c080e7          	jalr	316(ra) # 320 <close>
  return r;
 1ec:	64a2                	ld	s1,8(sp)
}
 1ee:	854a                	mv	a0,s2
 1f0:	60e2                	ld	ra,24(sp)
 1f2:	6442                	ld	s0,16(sp)
 1f4:	6902                	ld	s2,0(sp)
 1f6:	6105                	add	sp,sp,32
 1f8:	8082                	ret
    return -1;
 1fa:	597d                	li	s2,-1
 1fc:	bfcd                	j	1ee <stat+0x36>

00000000000001fe <atoi>:

int
atoi(const char *s)
{
 1fe:	1141                	add	sp,sp,-16
 200:	e422                	sd	s0,8(sp)
 202:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 204:	00054683          	lbu	a3,0(a0)
 208:	fd06879b          	addw	a5,a3,-48
 20c:	0ff7f793          	zext.b	a5,a5
 210:	4625                	li	a2,9
 212:	02f66863          	bltu	a2,a5,242 <atoi+0x44>
 216:	872a                	mv	a4,a0
  n = 0;
 218:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 21a:	0705                	add	a4,a4,1
 21c:	0025179b          	sllw	a5,a0,0x2
 220:	9fa9                	addw	a5,a5,a0
 222:	0017979b          	sllw	a5,a5,0x1
 226:	9fb5                	addw	a5,a5,a3
 228:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 22c:	00074683          	lbu	a3,0(a4)
 230:	fd06879b          	addw	a5,a3,-48
 234:	0ff7f793          	zext.b	a5,a5
 238:	fef671e3          	bgeu	a2,a5,21a <atoi+0x1c>
  return n;
}
 23c:	6422                	ld	s0,8(sp)
 23e:	0141                	add	sp,sp,16
 240:	8082                	ret
  n = 0;
 242:	4501                	li	a0,0
 244:	bfe5                	j	23c <atoi+0x3e>

0000000000000246 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 246:	1141                	add	sp,sp,-16
 248:	e422                	sd	s0,8(sp)
 24a:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 24c:	02b57463          	bgeu	a0,a1,274 <memmove+0x2e>
    while(n-- > 0)
 250:	00c05f63          	blez	a2,26e <memmove+0x28>
 254:	1602                	sll	a2,a2,0x20
 256:	9201                	srl	a2,a2,0x20
 258:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 25c:	872a                	mv	a4,a0
      *dst++ = *src++;
 25e:	0585                	add	a1,a1,1
 260:	0705                	add	a4,a4,1
 262:	fff5c683          	lbu	a3,-1(a1)
 266:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 26a:	fef71ae3          	bne	a4,a5,25e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	add	sp,sp,16
 272:	8082                	ret
    dst += n;
 274:	00c50733          	add	a4,a0,a2
    src += n;
 278:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 27a:	fec05ae3          	blez	a2,26e <memmove+0x28>
 27e:	fff6079b          	addw	a5,a2,-1
 282:	1782                	sll	a5,a5,0x20
 284:	9381                	srl	a5,a5,0x20
 286:	fff7c793          	not	a5,a5
 28a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 28c:	15fd                	add	a1,a1,-1
 28e:	177d                	add	a4,a4,-1
 290:	0005c683          	lbu	a3,0(a1)
 294:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 298:	fee79ae3          	bne	a5,a4,28c <memmove+0x46>
 29c:	bfc9                	j	26e <memmove+0x28>

000000000000029e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 29e:	1141                	add	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2a4:	ca05                	beqz	a2,2d4 <memcmp+0x36>
 2a6:	fff6069b          	addw	a3,a2,-1
 2aa:	1682                	sll	a3,a3,0x20
 2ac:	9281                	srl	a3,a3,0x20
 2ae:	0685                	add	a3,a3,1
 2b0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2b2:	00054783          	lbu	a5,0(a0)
 2b6:	0005c703          	lbu	a4,0(a1)
 2ba:	00e79863          	bne	a5,a4,2ca <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2be:	0505                	add	a0,a0,1
    p2++;
 2c0:	0585                	add	a1,a1,1
  while (n-- > 0) {
 2c2:	fed518e3          	bne	a0,a3,2b2 <memcmp+0x14>
  }
  return 0;
 2c6:	4501                	li	a0,0
 2c8:	a019                	j	2ce <memcmp+0x30>
      return *p1 - *p2;
 2ca:	40e7853b          	subw	a0,a5,a4
}
 2ce:	6422                	ld	s0,8(sp)
 2d0:	0141                	add	sp,sp,16
 2d2:	8082                	ret
  return 0;
 2d4:	4501                	li	a0,0
 2d6:	bfe5                	j	2ce <memcmp+0x30>

00000000000002d8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d8:	1141                	add	sp,sp,-16
 2da:	e406                	sd	ra,8(sp)
 2dc:	e022                	sd	s0,0(sp)
 2de:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 2e0:	00000097          	auipc	ra,0x0
 2e4:	f66080e7          	jalr	-154(ra) # 246 <memmove>
}
 2e8:	60a2                	ld	ra,8(sp)
 2ea:	6402                	ld	s0,0(sp)
 2ec:	0141                	add	sp,sp,16
 2ee:	8082                	ret

00000000000002f0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2f0:	4885                	li	a7,1
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2f8:	4889                	li	a7,2
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <wait>:
.global wait
wait:
 li a7, SYS_wait
 300:	488d                	li	a7,3
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 308:	4891                	li	a7,4
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <read>:
.global read
read:
 li a7, SYS_read
 310:	4895                	li	a7,5
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <write>:
.global write
write:
 li a7, SYS_write
 318:	48c1                	li	a7,16
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <close>:
.global close
close:
 li a7, SYS_close
 320:	48d5                	li	a7,21
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <kill>:
.global kill
kill:
 li a7, SYS_kill
 328:	4899                	li	a7,6
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <exec>:
.global exec
exec:
 li a7, SYS_exec
 330:	489d                	li	a7,7
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <open>:
.global open
open:
 li a7, SYS_open
 338:	48bd                	li	a7,15
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 340:	48c5                	li	a7,17
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 348:	48c9                	li	a7,18
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 350:	48a1                	li	a7,8
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <link>:
.global link
link:
 li a7, SYS_link
 358:	48cd                	li	a7,19
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 360:	48d1                	li	a7,20
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 368:	48a5                	li	a7,9
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <dup>:
.global dup
dup:
 li a7, SYS_dup
 370:	48a9                	li	a7,10
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 378:	48ad                	li	a7,11
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 380:	48b1                	li	a7,12
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 388:	48b5                	li	a7,13
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 390:	48b9                	li	a7,14
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 398:	48d9                	li	a7,22
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <sematest>:
.global sematest
sematest:
 li a7, SYS_sematest
 3a0:	48dd                	li	a7,23
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <rwsematest>:
.global rwsematest
rwsematest:
 li a7, SYS_rwsematest
 3a8:	48e1                	li	a7,24
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3b0:	1101                	add	sp,sp,-32
 3b2:	ec06                	sd	ra,24(sp)
 3b4:	e822                	sd	s0,16(sp)
 3b6:	1000                	add	s0,sp,32
 3b8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3bc:	4605                	li	a2,1
 3be:	fef40593          	add	a1,s0,-17
 3c2:	00000097          	auipc	ra,0x0
 3c6:	f56080e7          	jalr	-170(ra) # 318 <write>
}
 3ca:	60e2                	ld	ra,24(sp)
 3cc:	6442                	ld	s0,16(sp)
 3ce:	6105                	add	sp,sp,32
 3d0:	8082                	ret

00000000000003d2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d2:	7139                	add	sp,sp,-64
 3d4:	fc06                	sd	ra,56(sp)
 3d6:	f822                	sd	s0,48(sp)
 3d8:	f426                	sd	s1,40(sp)
 3da:	0080                	add	s0,sp,64
 3dc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3de:	c299                	beqz	a3,3e4 <printint+0x12>
 3e0:	0805cb63          	bltz	a1,476 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3e4:	2581                	sext.w	a1,a1
  neg = 0;
 3e6:	4881                	li	a7,0
 3e8:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 3ec:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3ee:	2601                	sext.w	a2,a2
 3f0:	00000517          	auipc	a0,0x0
 3f4:	4d050513          	add	a0,a0,1232 # 8c0 <digits>
 3f8:	883a                	mv	a6,a4
 3fa:	2705                	addw	a4,a4,1
 3fc:	02c5f7bb          	remuw	a5,a1,a2
 400:	1782                	sll	a5,a5,0x20
 402:	9381                	srl	a5,a5,0x20
 404:	97aa                	add	a5,a5,a0
 406:	0007c783          	lbu	a5,0(a5)
 40a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 40e:	0005879b          	sext.w	a5,a1
 412:	02c5d5bb          	divuw	a1,a1,a2
 416:	0685                	add	a3,a3,1
 418:	fec7f0e3          	bgeu	a5,a2,3f8 <printint+0x26>
  if(neg)
 41c:	00088c63          	beqz	a7,434 <printint+0x62>
    buf[i++] = '-';
 420:	fd070793          	add	a5,a4,-48
 424:	00878733          	add	a4,a5,s0
 428:	02d00793          	li	a5,45
 42c:	fef70823          	sb	a5,-16(a4)
 430:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 434:	02e05c63          	blez	a4,46c <printint+0x9a>
 438:	f04a                	sd	s2,32(sp)
 43a:	ec4e                	sd	s3,24(sp)
 43c:	fc040793          	add	a5,s0,-64
 440:	00e78933          	add	s2,a5,a4
 444:	fff78993          	add	s3,a5,-1
 448:	99ba                	add	s3,s3,a4
 44a:	377d                	addw	a4,a4,-1
 44c:	1702                	sll	a4,a4,0x20
 44e:	9301                	srl	a4,a4,0x20
 450:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 454:	fff94583          	lbu	a1,-1(s2)
 458:	8526                	mv	a0,s1
 45a:	00000097          	auipc	ra,0x0
 45e:	f56080e7          	jalr	-170(ra) # 3b0 <putc>
  while(--i >= 0)
 462:	197d                	add	s2,s2,-1
 464:	ff3918e3          	bne	s2,s3,454 <printint+0x82>
 468:	7902                	ld	s2,32(sp)
 46a:	69e2                	ld	s3,24(sp)
}
 46c:	70e2                	ld	ra,56(sp)
 46e:	7442                	ld	s0,48(sp)
 470:	74a2                	ld	s1,40(sp)
 472:	6121                	add	sp,sp,64
 474:	8082                	ret
    x = -xx;
 476:	40b005bb          	negw	a1,a1
    neg = 1;
 47a:	4885                	li	a7,1
    x = -xx;
 47c:	b7b5                	j	3e8 <printint+0x16>

000000000000047e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 47e:	715d                	add	sp,sp,-80
 480:	e486                	sd	ra,72(sp)
 482:	e0a2                	sd	s0,64(sp)
 484:	f84a                	sd	s2,48(sp)
 486:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 488:	0005c903          	lbu	s2,0(a1)
 48c:	1a090a63          	beqz	s2,640 <vprintf+0x1c2>
 490:	fc26                	sd	s1,56(sp)
 492:	f44e                	sd	s3,40(sp)
 494:	f052                	sd	s4,32(sp)
 496:	ec56                	sd	s5,24(sp)
 498:	e85a                	sd	s6,16(sp)
 49a:	e45e                	sd	s7,8(sp)
 49c:	8aaa                	mv	s5,a0
 49e:	8bb2                	mv	s7,a2
 4a0:	00158493          	add	s1,a1,1
  state = 0;
 4a4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4a6:	02500a13          	li	s4,37
 4aa:	4b55                	li	s6,21
 4ac:	a839                	j	4ca <vprintf+0x4c>
        putc(fd, c);
 4ae:	85ca                	mv	a1,s2
 4b0:	8556                	mv	a0,s5
 4b2:	00000097          	auipc	ra,0x0
 4b6:	efe080e7          	jalr	-258(ra) # 3b0 <putc>
 4ba:	a019                	j	4c0 <vprintf+0x42>
    } else if(state == '%'){
 4bc:	01498d63          	beq	s3,s4,4d6 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 4c0:	0485                	add	s1,s1,1
 4c2:	fff4c903          	lbu	s2,-1(s1)
 4c6:	16090763          	beqz	s2,634 <vprintf+0x1b6>
    if(state == 0){
 4ca:	fe0999e3          	bnez	s3,4bc <vprintf+0x3e>
      if(c == '%'){
 4ce:	ff4910e3          	bne	s2,s4,4ae <vprintf+0x30>
        state = '%';
 4d2:	89d2                	mv	s3,s4
 4d4:	b7f5                	j	4c0 <vprintf+0x42>
      if(c == 'd'){
 4d6:	13490463          	beq	s2,s4,5fe <vprintf+0x180>
 4da:	f9d9079b          	addw	a5,s2,-99
 4de:	0ff7f793          	zext.b	a5,a5
 4e2:	12fb6763          	bltu	s6,a5,610 <vprintf+0x192>
 4e6:	f9d9079b          	addw	a5,s2,-99
 4ea:	0ff7f713          	zext.b	a4,a5
 4ee:	12eb6163          	bltu	s6,a4,610 <vprintf+0x192>
 4f2:	00271793          	sll	a5,a4,0x2
 4f6:	00000717          	auipc	a4,0x0
 4fa:	37270713          	add	a4,a4,882 # 868 <malloc+0x138>
 4fe:	97ba                	add	a5,a5,a4
 500:	439c                	lw	a5,0(a5)
 502:	97ba                	add	a5,a5,a4
 504:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 506:	008b8913          	add	s2,s7,8
 50a:	4685                	li	a3,1
 50c:	4629                	li	a2,10
 50e:	000ba583          	lw	a1,0(s7)
 512:	8556                	mv	a0,s5
 514:	00000097          	auipc	ra,0x0
 518:	ebe080e7          	jalr	-322(ra) # 3d2 <printint>
 51c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 51e:	4981                	li	s3,0
 520:	b745                	j	4c0 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 522:	008b8913          	add	s2,s7,8
 526:	4681                	li	a3,0
 528:	4629                	li	a2,10
 52a:	000ba583          	lw	a1,0(s7)
 52e:	8556                	mv	a0,s5
 530:	00000097          	auipc	ra,0x0
 534:	ea2080e7          	jalr	-350(ra) # 3d2 <printint>
 538:	8bca                	mv	s7,s2
      state = 0;
 53a:	4981                	li	s3,0
 53c:	b751                	j	4c0 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 53e:	008b8913          	add	s2,s7,8
 542:	4681                	li	a3,0
 544:	4641                	li	a2,16
 546:	000ba583          	lw	a1,0(s7)
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e86080e7          	jalr	-378(ra) # 3d2 <printint>
 554:	8bca                	mv	s7,s2
      state = 0;
 556:	4981                	li	s3,0
 558:	b7a5                	j	4c0 <vprintf+0x42>
 55a:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 55c:	008b8c13          	add	s8,s7,8
 560:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 564:	03000593          	li	a1,48
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	e46080e7          	jalr	-442(ra) # 3b0 <putc>
  putc(fd, 'x');
 572:	07800593          	li	a1,120
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	e38080e7          	jalr	-456(ra) # 3b0 <putc>
 580:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 582:	00000b97          	auipc	s7,0x0
 586:	33eb8b93          	add	s7,s7,830 # 8c0 <digits>
 58a:	03c9d793          	srl	a5,s3,0x3c
 58e:	97de                	add	a5,a5,s7
 590:	0007c583          	lbu	a1,0(a5)
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	e1a080e7          	jalr	-486(ra) # 3b0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 59e:	0992                	sll	s3,s3,0x4
 5a0:	397d                	addw	s2,s2,-1
 5a2:	fe0914e3          	bnez	s2,58a <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5a6:	8be2                	mv	s7,s8
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	6c02                	ld	s8,0(sp)
 5ac:	bf11                	j	4c0 <vprintf+0x42>
        s = va_arg(ap, char*);
 5ae:	008b8993          	add	s3,s7,8
 5b2:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5b6:	02090163          	beqz	s2,5d8 <vprintf+0x15a>
        while(*s != 0){
 5ba:	00094583          	lbu	a1,0(s2)
 5be:	c9a5                	beqz	a1,62e <vprintf+0x1b0>
          putc(fd, *s);
 5c0:	8556                	mv	a0,s5
 5c2:	00000097          	auipc	ra,0x0
 5c6:	dee080e7          	jalr	-530(ra) # 3b0 <putc>
          s++;
 5ca:	0905                	add	s2,s2,1
        while(*s != 0){
 5cc:	00094583          	lbu	a1,0(s2)
 5d0:	f9e5                	bnez	a1,5c0 <vprintf+0x142>
        s = va_arg(ap, char*);
 5d2:	8bce                	mv	s7,s3
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	b5ed                	j	4c0 <vprintf+0x42>
          s = "(null)";
 5d8:	00000917          	auipc	s2,0x0
 5dc:	28890913          	add	s2,s2,648 # 860 <malloc+0x130>
        while(*s != 0){
 5e0:	02800593          	li	a1,40
 5e4:	bff1                	j	5c0 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 5e6:	008b8913          	add	s2,s7,8
 5ea:	000bc583          	lbu	a1,0(s7)
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	dc0080e7          	jalr	-576(ra) # 3b0 <putc>
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	b5d1                	j	4c0 <vprintf+0x42>
        putc(fd, c);
 5fe:	02500593          	li	a1,37
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	dac080e7          	jalr	-596(ra) # 3b0 <putc>
      state = 0;
 60c:	4981                	li	s3,0
 60e:	bd4d                	j	4c0 <vprintf+0x42>
        putc(fd, '%');
 610:	02500593          	li	a1,37
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	d9a080e7          	jalr	-614(ra) # 3b0 <putc>
        putc(fd, c);
 61e:	85ca                	mv	a1,s2
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	d8e080e7          	jalr	-626(ra) # 3b0 <putc>
      state = 0;
 62a:	4981                	li	s3,0
 62c:	bd51                	j	4c0 <vprintf+0x42>
        s = va_arg(ap, char*);
 62e:	8bce                	mv	s7,s3
      state = 0;
 630:	4981                	li	s3,0
 632:	b579                	j	4c0 <vprintf+0x42>
 634:	74e2                	ld	s1,56(sp)
 636:	79a2                	ld	s3,40(sp)
 638:	7a02                	ld	s4,32(sp)
 63a:	6ae2                	ld	s5,24(sp)
 63c:	6b42                	ld	s6,16(sp)
 63e:	6ba2                	ld	s7,8(sp)
    }
  }
}
 640:	60a6                	ld	ra,72(sp)
 642:	6406                	ld	s0,64(sp)
 644:	7942                	ld	s2,48(sp)
 646:	6161                	add	sp,sp,80
 648:	8082                	ret

000000000000064a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 64a:	715d                	add	sp,sp,-80
 64c:	ec06                	sd	ra,24(sp)
 64e:	e822                	sd	s0,16(sp)
 650:	1000                	add	s0,sp,32
 652:	e010                	sd	a2,0(s0)
 654:	e414                	sd	a3,8(s0)
 656:	e818                	sd	a4,16(s0)
 658:	ec1c                	sd	a5,24(s0)
 65a:	03043023          	sd	a6,32(s0)
 65e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 662:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 666:	8622                	mv	a2,s0
 668:	00000097          	auipc	ra,0x0
 66c:	e16080e7          	jalr	-490(ra) # 47e <vprintf>
}
 670:	60e2                	ld	ra,24(sp)
 672:	6442                	ld	s0,16(sp)
 674:	6161                	add	sp,sp,80
 676:	8082                	ret

0000000000000678 <printf>:

void
printf(const char *fmt, ...)
{
 678:	711d                	add	sp,sp,-96
 67a:	ec06                	sd	ra,24(sp)
 67c:	e822                	sd	s0,16(sp)
 67e:	1000                	add	s0,sp,32
 680:	e40c                	sd	a1,8(s0)
 682:	e810                	sd	a2,16(s0)
 684:	ec14                	sd	a3,24(s0)
 686:	f018                	sd	a4,32(s0)
 688:	f41c                	sd	a5,40(s0)
 68a:	03043823          	sd	a6,48(s0)
 68e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 692:	00840613          	add	a2,s0,8
 696:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 69a:	85aa                	mv	a1,a0
 69c:	4505                	li	a0,1
 69e:	00000097          	auipc	ra,0x0
 6a2:	de0080e7          	jalr	-544(ra) # 47e <vprintf>
}
 6a6:	60e2                	ld	ra,24(sp)
 6a8:	6442                	ld	s0,16(sp)
 6aa:	6125                	add	sp,sp,96
 6ac:	8082                	ret

00000000000006ae <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ae:	1141                	add	sp,sp,-16
 6b0:	e422                	sd	s0,8(sp)
 6b2:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b4:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b8:	00000797          	auipc	a5,0x0
 6bc:	2207b783          	ld	a5,544(a5) # 8d8 <freep>
 6c0:	a02d                	j	6ea <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6c2:	4618                	lw	a4,8(a2)
 6c4:	9f2d                	addw	a4,a4,a1
 6c6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ca:	6398                	ld	a4,0(a5)
 6cc:	6310                	ld	a2,0(a4)
 6ce:	a83d                	j	70c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6d0:	ff852703          	lw	a4,-8(a0)
 6d4:	9f31                	addw	a4,a4,a2
 6d6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6d8:	ff053683          	ld	a3,-16(a0)
 6dc:	a091                	j	720 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6de:	6398                	ld	a4,0(a5)
 6e0:	00e7e463          	bltu	a5,a4,6e8 <free+0x3a>
 6e4:	00e6ea63          	bltu	a3,a4,6f8 <free+0x4a>
{
 6e8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ea:	fed7fae3          	bgeu	a5,a3,6de <free+0x30>
 6ee:	6398                	ld	a4,0(a5)
 6f0:	00e6e463          	bltu	a3,a4,6f8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6f4:	fee7eae3          	bltu	a5,a4,6e8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6f8:	ff852583          	lw	a1,-8(a0)
 6fc:	6390                	ld	a2,0(a5)
 6fe:	02059813          	sll	a6,a1,0x20
 702:	01c85713          	srl	a4,a6,0x1c
 706:	9736                	add	a4,a4,a3
 708:	fae60de3          	beq	a2,a4,6c2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 70c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 710:	4790                	lw	a2,8(a5)
 712:	02061593          	sll	a1,a2,0x20
 716:	01c5d713          	srl	a4,a1,0x1c
 71a:	973e                	add	a4,a4,a5
 71c:	fae68ae3          	beq	a3,a4,6d0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 720:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 722:	00000717          	auipc	a4,0x0
 726:	1af73b23          	sd	a5,438(a4) # 8d8 <freep>
}
 72a:	6422                	ld	s0,8(sp)
 72c:	0141                	add	sp,sp,16
 72e:	8082                	ret

0000000000000730 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 730:	7139                	add	sp,sp,-64
 732:	fc06                	sd	ra,56(sp)
 734:	f822                	sd	s0,48(sp)
 736:	f426                	sd	s1,40(sp)
 738:	ec4e                	sd	s3,24(sp)
 73a:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 73c:	02051493          	sll	s1,a0,0x20
 740:	9081                	srl	s1,s1,0x20
 742:	04bd                	add	s1,s1,15
 744:	8091                	srl	s1,s1,0x4
 746:	0014899b          	addw	s3,s1,1
 74a:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 74c:	00000517          	auipc	a0,0x0
 750:	18c53503          	ld	a0,396(a0) # 8d8 <freep>
 754:	c915                	beqz	a0,788 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 756:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 758:	4798                	lw	a4,8(a5)
 75a:	08977e63          	bgeu	a4,s1,7f6 <malloc+0xc6>
 75e:	f04a                	sd	s2,32(sp)
 760:	e852                	sd	s4,16(sp)
 762:	e456                	sd	s5,8(sp)
 764:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 766:	8a4e                	mv	s4,s3
 768:	0009871b          	sext.w	a4,s3
 76c:	6685                	lui	a3,0x1
 76e:	00d77363          	bgeu	a4,a3,774 <malloc+0x44>
 772:	6a05                	lui	s4,0x1
 774:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 778:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 77c:	00000917          	auipc	s2,0x0
 780:	15c90913          	add	s2,s2,348 # 8d8 <freep>
  if(p == (char*)-1)
 784:	5afd                	li	s5,-1
 786:	a091                	j	7ca <malloc+0x9a>
 788:	f04a                	sd	s2,32(sp)
 78a:	e852                	sd	s4,16(sp)
 78c:	e456                	sd	s5,8(sp)
 78e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 790:	00000797          	auipc	a5,0x0
 794:	15078793          	add	a5,a5,336 # 8e0 <base>
 798:	00000717          	auipc	a4,0x0
 79c:	14f73023          	sd	a5,320(a4) # 8d8 <freep>
 7a0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7a6:	b7c1                	j	766 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7a8:	6398                	ld	a4,0(a5)
 7aa:	e118                	sd	a4,0(a0)
 7ac:	a08d                	j	80e <malloc+0xde>
  hp->s.size = nu;
 7ae:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7b2:	0541                	add	a0,a0,16
 7b4:	00000097          	auipc	ra,0x0
 7b8:	efa080e7          	jalr	-262(ra) # 6ae <free>
  return freep;
 7bc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7c0:	c13d                	beqz	a0,826 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c4:	4798                	lw	a4,8(a5)
 7c6:	02977463          	bgeu	a4,s1,7ee <malloc+0xbe>
    if(p == freep)
 7ca:	00093703          	ld	a4,0(s2)
 7ce:	853e                	mv	a0,a5
 7d0:	fef719e3          	bne	a4,a5,7c2 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 7d4:	8552                	mv	a0,s4
 7d6:	00000097          	auipc	ra,0x0
 7da:	baa080e7          	jalr	-1110(ra) # 380 <sbrk>
  if(p == (char*)-1)
 7de:	fd5518e3          	bne	a0,s5,7ae <malloc+0x7e>
        return 0;
 7e2:	4501                	li	a0,0
 7e4:	7902                	ld	s2,32(sp)
 7e6:	6a42                	ld	s4,16(sp)
 7e8:	6aa2                	ld	s5,8(sp)
 7ea:	6b02                	ld	s6,0(sp)
 7ec:	a03d                	j	81a <malloc+0xea>
 7ee:	7902                	ld	s2,32(sp)
 7f0:	6a42                	ld	s4,16(sp)
 7f2:	6aa2                	ld	s5,8(sp)
 7f4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 7f6:	fae489e3          	beq	s1,a4,7a8 <malloc+0x78>
        p->s.size -= nunits;
 7fa:	4137073b          	subw	a4,a4,s3
 7fe:	c798                	sw	a4,8(a5)
        p += p->s.size;
 800:	02071693          	sll	a3,a4,0x20
 804:	01c6d713          	srl	a4,a3,0x1c
 808:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 80a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 80e:	00000717          	auipc	a4,0x0
 812:	0ca73523          	sd	a0,202(a4) # 8d8 <freep>
      return (void*)(p + 1);
 816:	01078513          	add	a0,a5,16
  }
}
 81a:	70e2                	ld	ra,56(sp)
 81c:	7442                	ld	s0,48(sp)
 81e:	74a2                	ld	s1,40(sp)
 820:	69e2                	ld	s3,24(sp)
 822:	6121                	add	sp,sp,64
 824:	8082                	ret
 826:	7902                	ld	s2,32(sp)
 828:	6a42                	ld	s4,16(sp)
 82a:	6aa2                	ld	s5,8(sp)
 82c:	6b02                	ld	s6,0(sp)
 82e:	b7f5                	j	81a <malloc+0xea>
