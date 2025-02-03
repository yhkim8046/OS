
user/_schedtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"
#define NFORK 10
#define IO 5
int main() {
   0:	7139                	add	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	0080                	add	s0,sp,64
  int n, pid;
  int wtime, rtime, stime;
  int twtime=0, trtime=0, tstime=0;
  
  for(n=0; n < NFORK;n++) {
  10:	4481                	li	s1,0
  12:	4929                	li	s2,10
    pid = fork();
  14:	00000097          	auipc	ra,0x0
  18:	334080e7          	jalr	820(ra) # 348 <fork>
    if (pid < 0)
  1c:	00054a63          	bltz	a0,30 <main+0x30>
      break;
    if (pid == 0) {
  20:	c129                	beqz	a0,62 <main+0x62>
  for(n=0; n < NFORK;n++) {
  22:	2485                	addw	s1,s1,1
  24:	ff2498e3          	bne	s1,s2,14 <main+0x14>
  28:	4a01                	li	s4,0
  2a:	4901                	li	s2,0
  2c:	4981                	li	s3,0
  2e:	a049                	j	b0 <main+0xb0>
          for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process
        }
      exit(0);
    }
  }
  for(;n > 0; n--) {
  30:	fe904ce3          	bgtz	s1,28 <main+0x28>
  34:	4a01                	li	s4,0
  36:	4901                	li	s2,0
  38:	4981                	li	s3,0
      trtime += rtime;
      twtime += wtime;
      tstime += stime;
    }
  }
  printf("Average run-time = %d, wait time = %d, sleep time = %d\n", trtime/NFORK, twtime / NFORK, tstime / NFORK);
  3a:	45a9                	li	a1,10
  3c:	02ba46bb          	divw	a3,s4,a1
  40:	02b9c63b          	divw	a2,s3,a1
  44:	02b945bb          	divw	a1,s2,a1
  48:	00001517          	auipc	a0,0x1
  4c:	84050513          	add	a0,a0,-1984 # 888 <malloc+0x100>
  50:	00000097          	auipc	ra,0x0
  54:	680080e7          	jalr	1664(ra) # 6d0 <printf>
  exit(0);
  58:	4501                	li	a0,0
  5a:	00000097          	auipc	ra,0x0
  5e:	2f6080e7          	jalr	758(ra) # 350 <exit>
      if (n < IO) {
  62:	4791                	li	a5,4
  64:	0297dd63          	bge	a5,s1,9e <main+0x9e>
          for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process
  68:	fc042023          	sw	zero,-64(s0)
  6c:	fc042703          	lw	a4,-64(s0)
  70:	2701                	sext.w	a4,a4
  72:	3b9ad7b7          	lui	a5,0x3b9ad
  76:	9ff78793          	add	a5,a5,-1537 # 3b9ac9ff <__global_pointer$+0x3b9ab8ce>
  7a:	00e7cd63          	blt	a5,a4,94 <main+0x94>
  7e:	873e                	mv	a4,a5
  80:	fc042783          	lw	a5,-64(s0)
  84:	2785                	addw	a5,a5,1
  86:	fcf42023          	sw	a5,-64(s0)
  8a:	fc042783          	lw	a5,-64(s0)
  8e:	2781                	sext.w	a5,a5
  90:	fef758e3          	bge	a4,a5,80 <main+0x80>
      exit(0);
  94:	4501                	li	a0,0
  96:	00000097          	auipc	ra,0x0
  9a:	2ba080e7          	jalr	698(ra) # 350 <exit>
        sleep(200); // IO bound processes
  9e:	0c800513          	li	a0,200
  a2:	00000097          	auipc	ra,0x0
  a6:	33e080e7          	jalr	830(ra) # 3e0 <sleep>
  aa:	b7ed                	j	94 <main+0x94>
  for(;n > 0; n--) {
  ac:	34fd                	addw	s1,s1,-1
  ae:	d4d1                	beqz	s1,3a <main+0x3a>
    if(wait2(0,&rtime,&wtime,&stime) >= 0) {
  b0:	fc440693          	add	a3,s0,-60
  b4:	fcc40613          	add	a2,s0,-52
  b8:	fc840593          	add	a1,s0,-56
  bc:	4501                	li	a0,0
  be:	00000097          	auipc	ra,0x0
  c2:	332080e7          	jalr	818(ra) # 3f0 <wait2>
  c6:	fe0543e3          	bltz	a0,ac <main+0xac>
      trtime += rtime;
  ca:	fc842783          	lw	a5,-56(s0)
  ce:	0127893b          	addw	s2,a5,s2
      twtime += wtime;
  d2:	fcc42783          	lw	a5,-52(s0)
  d6:	013789bb          	addw	s3,a5,s3
      tstime += stime;
  da:	fc442783          	lw	a5,-60(s0)
  de:	01478a3b          	addw	s4,a5,s4
  e2:	b7e9                	j	ac <main+0xac>

00000000000000e4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  e4:	1141                	add	sp,sp,-16
  e6:	e422                	sd	s0,8(sp)
  e8:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ea:	87aa                	mv	a5,a0
  ec:	0585                	add	a1,a1,1
  ee:	0785                	add	a5,a5,1
  f0:	fff5c703          	lbu	a4,-1(a1)
  f4:	fee78fa3          	sb	a4,-1(a5)
  f8:	fb75                	bnez	a4,ec <strcpy+0x8>
    ;
  return os;
}
  fa:	6422                	ld	s0,8(sp)
  fc:	0141                	add	sp,sp,16
  fe:	8082                	ret

0000000000000100 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 100:	1141                	add	sp,sp,-16
 102:	e422                	sd	s0,8(sp)
 104:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 106:	00054783          	lbu	a5,0(a0)
 10a:	cb91                	beqz	a5,11e <strcmp+0x1e>
 10c:	0005c703          	lbu	a4,0(a1)
 110:	00f71763          	bne	a4,a5,11e <strcmp+0x1e>
    p++, q++;
 114:	0505                	add	a0,a0,1
 116:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 118:	00054783          	lbu	a5,0(a0)
 11c:	fbe5                	bnez	a5,10c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 11e:	0005c503          	lbu	a0,0(a1)
}
 122:	40a7853b          	subw	a0,a5,a0
 126:	6422                	ld	s0,8(sp)
 128:	0141                	add	sp,sp,16
 12a:	8082                	ret

000000000000012c <strlen>:

uint
strlen(const char *s)
{
 12c:	1141                	add	sp,sp,-16
 12e:	e422                	sd	s0,8(sp)
 130:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 132:	00054783          	lbu	a5,0(a0)
 136:	cf91                	beqz	a5,152 <strlen+0x26>
 138:	0505                	add	a0,a0,1
 13a:	87aa                	mv	a5,a0
 13c:	86be                	mv	a3,a5
 13e:	0785                	add	a5,a5,1
 140:	fff7c703          	lbu	a4,-1(a5)
 144:	ff65                	bnez	a4,13c <strlen+0x10>
 146:	40a6853b          	subw	a0,a3,a0
 14a:	2505                	addw	a0,a0,1
    ;
  return n;
}
 14c:	6422                	ld	s0,8(sp)
 14e:	0141                	add	sp,sp,16
 150:	8082                	ret
  for(n = 0; s[n]; n++)
 152:	4501                	li	a0,0
 154:	bfe5                	j	14c <strlen+0x20>

0000000000000156 <memset>:

void*
memset(void *dst, int c, uint n)
{
 156:	1141                	add	sp,sp,-16
 158:	e422                	sd	s0,8(sp)
 15a:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 15c:	ca19                	beqz	a2,172 <memset+0x1c>
 15e:	87aa                	mv	a5,a0
 160:	1602                	sll	a2,a2,0x20
 162:	9201                	srl	a2,a2,0x20
 164:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 168:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 16c:	0785                	add	a5,a5,1
 16e:	fee79de3          	bne	a5,a4,168 <memset+0x12>
  }
  return dst;
}
 172:	6422                	ld	s0,8(sp)
 174:	0141                	add	sp,sp,16
 176:	8082                	ret

0000000000000178 <strchr>:

char*
strchr(const char *s, char c)
{
 178:	1141                	add	sp,sp,-16
 17a:	e422                	sd	s0,8(sp)
 17c:	0800                	add	s0,sp,16
  for(; *s; s++)
 17e:	00054783          	lbu	a5,0(a0)
 182:	cb99                	beqz	a5,198 <strchr+0x20>
    if(*s == c)
 184:	00f58763          	beq	a1,a5,192 <strchr+0x1a>
  for(; *s; s++)
 188:	0505                	add	a0,a0,1
 18a:	00054783          	lbu	a5,0(a0)
 18e:	fbfd                	bnez	a5,184 <strchr+0xc>
      return (char*)s;
  return 0;
 190:	4501                	li	a0,0
}
 192:	6422                	ld	s0,8(sp)
 194:	0141                	add	sp,sp,16
 196:	8082                	ret
  return 0;
 198:	4501                	li	a0,0
 19a:	bfe5                	j	192 <strchr+0x1a>

000000000000019c <gets>:

char*
gets(char *buf, int max)
{
 19c:	711d                	add	sp,sp,-96
 19e:	ec86                	sd	ra,88(sp)
 1a0:	e8a2                	sd	s0,80(sp)
 1a2:	e4a6                	sd	s1,72(sp)
 1a4:	e0ca                	sd	s2,64(sp)
 1a6:	fc4e                	sd	s3,56(sp)
 1a8:	f852                	sd	s4,48(sp)
 1aa:	f456                	sd	s5,40(sp)
 1ac:	f05a                	sd	s6,32(sp)
 1ae:	ec5e                	sd	s7,24(sp)
 1b0:	1080                	add	s0,sp,96
 1b2:	8baa                	mv	s7,a0
 1b4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b6:	892a                	mv	s2,a0
 1b8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ba:	4aa9                	li	s5,10
 1bc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1be:	89a6                	mv	s3,s1
 1c0:	2485                	addw	s1,s1,1
 1c2:	0344d863          	bge	s1,s4,1f2 <gets+0x56>
    cc = read(0, &c, 1);
 1c6:	4605                	li	a2,1
 1c8:	faf40593          	add	a1,s0,-81
 1cc:	4501                	li	a0,0
 1ce:	00000097          	auipc	ra,0x0
 1d2:	19a080e7          	jalr	410(ra) # 368 <read>
    if(cc < 1)
 1d6:	00a05e63          	blez	a0,1f2 <gets+0x56>
    buf[i++] = c;
 1da:	faf44783          	lbu	a5,-81(s0)
 1de:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e2:	01578763          	beq	a5,s5,1f0 <gets+0x54>
 1e6:	0905                	add	s2,s2,1
 1e8:	fd679be3          	bne	a5,s6,1be <gets+0x22>
    buf[i++] = c;
 1ec:	89a6                	mv	s3,s1
 1ee:	a011                	j	1f2 <gets+0x56>
 1f0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f2:	99de                	add	s3,s3,s7
 1f4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1f8:	855e                	mv	a0,s7
 1fa:	60e6                	ld	ra,88(sp)
 1fc:	6446                	ld	s0,80(sp)
 1fe:	64a6                	ld	s1,72(sp)
 200:	6906                	ld	s2,64(sp)
 202:	79e2                	ld	s3,56(sp)
 204:	7a42                	ld	s4,48(sp)
 206:	7aa2                	ld	s5,40(sp)
 208:	7b02                	ld	s6,32(sp)
 20a:	6be2                	ld	s7,24(sp)
 20c:	6125                	add	sp,sp,96
 20e:	8082                	ret

0000000000000210 <stat>:

int
stat(const char *n, struct stat *st)
{
 210:	1101                	add	sp,sp,-32
 212:	ec06                	sd	ra,24(sp)
 214:	e822                	sd	s0,16(sp)
 216:	e04a                	sd	s2,0(sp)
 218:	1000                	add	s0,sp,32
 21a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 21c:	4581                	li	a1,0
 21e:	00000097          	auipc	ra,0x0
 222:	172080e7          	jalr	370(ra) # 390 <open>
  if(fd < 0)
 226:	02054663          	bltz	a0,252 <stat+0x42>
 22a:	e426                	sd	s1,8(sp)
 22c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 22e:	85ca                	mv	a1,s2
 230:	00000097          	auipc	ra,0x0
 234:	178080e7          	jalr	376(ra) # 3a8 <fstat>
 238:	892a                	mv	s2,a0
  close(fd);
 23a:	8526                	mv	a0,s1
 23c:	00000097          	auipc	ra,0x0
 240:	13c080e7          	jalr	316(ra) # 378 <close>
  return r;
 244:	64a2                	ld	s1,8(sp)
}
 246:	854a                	mv	a0,s2
 248:	60e2                	ld	ra,24(sp)
 24a:	6442                	ld	s0,16(sp)
 24c:	6902                	ld	s2,0(sp)
 24e:	6105                	add	sp,sp,32
 250:	8082                	ret
    return -1;
 252:	597d                	li	s2,-1
 254:	bfcd                	j	246 <stat+0x36>

0000000000000256 <atoi>:

int
atoi(const char *s)
{
 256:	1141                	add	sp,sp,-16
 258:	e422                	sd	s0,8(sp)
 25a:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 25c:	00054683          	lbu	a3,0(a0)
 260:	fd06879b          	addw	a5,a3,-48
 264:	0ff7f793          	zext.b	a5,a5
 268:	4625                	li	a2,9
 26a:	02f66863          	bltu	a2,a5,29a <atoi+0x44>
 26e:	872a                	mv	a4,a0
  n = 0;
 270:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 272:	0705                	add	a4,a4,1
 274:	0025179b          	sllw	a5,a0,0x2
 278:	9fa9                	addw	a5,a5,a0
 27a:	0017979b          	sllw	a5,a5,0x1
 27e:	9fb5                	addw	a5,a5,a3
 280:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 284:	00074683          	lbu	a3,0(a4)
 288:	fd06879b          	addw	a5,a3,-48
 28c:	0ff7f793          	zext.b	a5,a5
 290:	fef671e3          	bgeu	a2,a5,272 <atoi+0x1c>
  return n;
}
 294:	6422                	ld	s0,8(sp)
 296:	0141                	add	sp,sp,16
 298:	8082                	ret
  n = 0;
 29a:	4501                	li	a0,0
 29c:	bfe5                	j	294 <atoi+0x3e>

000000000000029e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 29e:	1141                	add	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a4:	02b57463          	bgeu	a0,a1,2cc <memmove+0x2e>
    while(n-- > 0)
 2a8:	00c05f63          	blez	a2,2c6 <memmove+0x28>
 2ac:	1602                	sll	a2,a2,0x20
 2ae:	9201                	srl	a2,a2,0x20
 2b0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b6:	0585                	add	a1,a1,1
 2b8:	0705                	add	a4,a4,1
 2ba:	fff5c683          	lbu	a3,-1(a1)
 2be:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c2:	fef71ae3          	bne	a4,a5,2b6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c6:	6422                	ld	s0,8(sp)
 2c8:	0141                	add	sp,sp,16
 2ca:	8082                	ret
    dst += n;
 2cc:	00c50733          	add	a4,a0,a2
    src += n;
 2d0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d2:	fec05ae3          	blez	a2,2c6 <memmove+0x28>
 2d6:	fff6079b          	addw	a5,a2,-1
 2da:	1782                	sll	a5,a5,0x20
 2dc:	9381                	srl	a5,a5,0x20
 2de:	fff7c793          	not	a5,a5
 2e2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e4:	15fd                	add	a1,a1,-1
 2e6:	177d                	add	a4,a4,-1
 2e8:	0005c683          	lbu	a3,0(a1)
 2ec:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2f0:	fee79ae3          	bne	a5,a4,2e4 <memmove+0x46>
 2f4:	bfc9                	j	2c6 <memmove+0x28>

00000000000002f6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f6:	1141                	add	sp,sp,-16
 2f8:	e422                	sd	s0,8(sp)
 2fa:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2fc:	ca05                	beqz	a2,32c <memcmp+0x36>
 2fe:	fff6069b          	addw	a3,a2,-1
 302:	1682                	sll	a3,a3,0x20
 304:	9281                	srl	a3,a3,0x20
 306:	0685                	add	a3,a3,1
 308:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 30a:	00054783          	lbu	a5,0(a0)
 30e:	0005c703          	lbu	a4,0(a1)
 312:	00e79863          	bne	a5,a4,322 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 316:	0505                	add	a0,a0,1
    p2++;
 318:	0585                	add	a1,a1,1
  while (n-- > 0) {
 31a:	fed518e3          	bne	a0,a3,30a <memcmp+0x14>
  }
  return 0;
 31e:	4501                	li	a0,0
 320:	a019                	j	326 <memcmp+0x30>
      return *p1 - *p2;
 322:	40e7853b          	subw	a0,a5,a4
}
 326:	6422                	ld	s0,8(sp)
 328:	0141                	add	sp,sp,16
 32a:	8082                	ret
  return 0;
 32c:	4501                	li	a0,0
 32e:	bfe5                	j	326 <memcmp+0x30>

0000000000000330 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 330:	1141                	add	sp,sp,-16
 332:	e406                	sd	ra,8(sp)
 334:	e022                	sd	s0,0(sp)
 336:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 338:	00000097          	auipc	ra,0x0
 33c:	f66080e7          	jalr	-154(ra) # 29e <memmove>
}
 340:	60a2                	ld	ra,8(sp)
 342:	6402                	ld	s0,0(sp)
 344:	0141                	add	sp,sp,16
 346:	8082                	ret

0000000000000348 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 348:	4885                	li	a7,1
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <exit>:
.global exit
exit:
 li a7, SYS_exit
 350:	4889                	li	a7,2
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <wait>:
.global wait
wait:
 li a7, SYS_wait
 358:	488d                	li	a7,3
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 360:	4891                	li	a7,4
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <read>:
.global read
read:
 li a7, SYS_read
 368:	4895                	li	a7,5
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <write>:
.global write
write:
 li a7, SYS_write
 370:	48c1                	li	a7,16
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <close>:
.global close
close:
 li a7, SYS_close
 378:	48d5                	li	a7,21
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <kill>:
.global kill
kill:
 li a7, SYS_kill
 380:	4899                	li	a7,6
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <exec>:
.global exec
exec:
 li a7, SYS_exec
 388:	489d                	li	a7,7
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <open>:
.global open
open:
 li a7, SYS_open
 390:	48bd                	li	a7,15
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 398:	48c5                	li	a7,17
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a0:	48c9                	li	a7,18
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3a8:	48a1                	li	a7,8
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <link>:
.global link
link:
 li a7, SYS_link
 3b0:	48cd                	li	a7,19
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3b8:	48d1                	li	a7,20
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c0:	48a5                	li	a7,9
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3c8:	48a9                	li	a7,10
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d0:	48ad                	li	a7,11
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3d8:	48b1                	li	a7,12
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3e0:	48b5                	li	a7,13
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3e8:	48b9                	li	a7,14
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <wait2>:
.global wait2
wait2:
 li a7, SYS_wait2
 3f0:	48d9                	li	a7,22
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <setnice>:
.global setnice
setnice:
 li a7, SYS_setnice
 3f8:	48dd                	li	a7,23
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <getnice>:
.global getnice
getnice:
 li a7, SYS_getnice
 400:	48e1                	li	a7,24
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 408:	1101                	add	sp,sp,-32
 40a:	ec06                	sd	ra,24(sp)
 40c:	e822                	sd	s0,16(sp)
 40e:	1000                	add	s0,sp,32
 410:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 414:	4605                	li	a2,1
 416:	fef40593          	add	a1,s0,-17
 41a:	00000097          	auipc	ra,0x0
 41e:	f56080e7          	jalr	-170(ra) # 370 <write>
}
 422:	60e2                	ld	ra,24(sp)
 424:	6442                	ld	s0,16(sp)
 426:	6105                	add	sp,sp,32
 428:	8082                	ret

000000000000042a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42a:	7139                	add	sp,sp,-64
 42c:	fc06                	sd	ra,56(sp)
 42e:	f822                	sd	s0,48(sp)
 430:	f426                	sd	s1,40(sp)
 432:	0080                	add	s0,sp,64
 434:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 436:	c299                	beqz	a3,43c <printint+0x12>
 438:	0805cb63          	bltz	a1,4ce <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 43c:	2581                	sext.w	a1,a1
  neg = 0;
 43e:	4881                	li	a7,0
 440:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 444:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 446:	2601                	sext.w	a2,a2
 448:	00000517          	auipc	a0,0x0
 44c:	4d850513          	add	a0,a0,1240 # 920 <digits>
 450:	883a                	mv	a6,a4
 452:	2705                	addw	a4,a4,1
 454:	02c5f7bb          	remuw	a5,a1,a2
 458:	1782                	sll	a5,a5,0x20
 45a:	9381                	srl	a5,a5,0x20
 45c:	97aa                	add	a5,a5,a0
 45e:	0007c783          	lbu	a5,0(a5)
 462:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 466:	0005879b          	sext.w	a5,a1
 46a:	02c5d5bb          	divuw	a1,a1,a2
 46e:	0685                	add	a3,a3,1
 470:	fec7f0e3          	bgeu	a5,a2,450 <printint+0x26>
  if(neg)
 474:	00088c63          	beqz	a7,48c <printint+0x62>
    buf[i++] = '-';
 478:	fd070793          	add	a5,a4,-48
 47c:	00878733          	add	a4,a5,s0
 480:	02d00793          	li	a5,45
 484:	fef70823          	sb	a5,-16(a4)
 488:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 48c:	02e05c63          	blez	a4,4c4 <printint+0x9a>
 490:	f04a                	sd	s2,32(sp)
 492:	ec4e                	sd	s3,24(sp)
 494:	fc040793          	add	a5,s0,-64
 498:	00e78933          	add	s2,a5,a4
 49c:	fff78993          	add	s3,a5,-1
 4a0:	99ba                	add	s3,s3,a4
 4a2:	377d                	addw	a4,a4,-1
 4a4:	1702                	sll	a4,a4,0x20
 4a6:	9301                	srl	a4,a4,0x20
 4a8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ac:	fff94583          	lbu	a1,-1(s2)
 4b0:	8526                	mv	a0,s1
 4b2:	00000097          	auipc	ra,0x0
 4b6:	f56080e7          	jalr	-170(ra) # 408 <putc>
  while(--i >= 0)
 4ba:	197d                	add	s2,s2,-1
 4bc:	ff3918e3          	bne	s2,s3,4ac <printint+0x82>
 4c0:	7902                	ld	s2,32(sp)
 4c2:	69e2                	ld	s3,24(sp)
}
 4c4:	70e2                	ld	ra,56(sp)
 4c6:	7442                	ld	s0,48(sp)
 4c8:	74a2                	ld	s1,40(sp)
 4ca:	6121                	add	sp,sp,64
 4cc:	8082                	ret
    x = -xx;
 4ce:	40b005bb          	negw	a1,a1
    neg = 1;
 4d2:	4885                	li	a7,1
    x = -xx;
 4d4:	b7b5                	j	440 <printint+0x16>

00000000000004d6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4d6:	715d                	add	sp,sp,-80
 4d8:	e486                	sd	ra,72(sp)
 4da:	e0a2                	sd	s0,64(sp)
 4dc:	f84a                	sd	s2,48(sp)
 4de:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e0:	0005c903          	lbu	s2,0(a1)
 4e4:	1a090a63          	beqz	s2,698 <vprintf+0x1c2>
 4e8:	fc26                	sd	s1,56(sp)
 4ea:	f44e                	sd	s3,40(sp)
 4ec:	f052                	sd	s4,32(sp)
 4ee:	ec56                	sd	s5,24(sp)
 4f0:	e85a                	sd	s6,16(sp)
 4f2:	e45e                	sd	s7,8(sp)
 4f4:	8aaa                	mv	s5,a0
 4f6:	8bb2                	mv	s7,a2
 4f8:	00158493          	add	s1,a1,1
  state = 0;
 4fc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4fe:	02500a13          	li	s4,37
 502:	4b55                	li	s6,21
 504:	a839                	j	522 <vprintf+0x4c>
        putc(fd, c);
 506:	85ca                	mv	a1,s2
 508:	8556                	mv	a0,s5
 50a:	00000097          	auipc	ra,0x0
 50e:	efe080e7          	jalr	-258(ra) # 408 <putc>
 512:	a019                	j	518 <vprintf+0x42>
    } else if(state == '%'){
 514:	01498d63          	beq	s3,s4,52e <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 518:	0485                	add	s1,s1,1
 51a:	fff4c903          	lbu	s2,-1(s1)
 51e:	16090763          	beqz	s2,68c <vprintf+0x1b6>
    if(state == 0){
 522:	fe0999e3          	bnez	s3,514 <vprintf+0x3e>
      if(c == '%'){
 526:	ff4910e3          	bne	s2,s4,506 <vprintf+0x30>
        state = '%';
 52a:	89d2                	mv	s3,s4
 52c:	b7f5                	j	518 <vprintf+0x42>
      if(c == 'd'){
 52e:	13490463          	beq	s2,s4,656 <vprintf+0x180>
 532:	f9d9079b          	addw	a5,s2,-99
 536:	0ff7f793          	zext.b	a5,a5
 53a:	12fb6763          	bltu	s6,a5,668 <vprintf+0x192>
 53e:	f9d9079b          	addw	a5,s2,-99
 542:	0ff7f713          	zext.b	a4,a5
 546:	12eb6163          	bltu	s6,a4,668 <vprintf+0x192>
 54a:	00271793          	sll	a5,a4,0x2
 54e:	00000717          	auipc	a4,0x0
 552:	37a70713          	add	a4,a4,890 # 8c8 <malloc+0x140>
 556:	97ba                	add	a5,a5,a4
 558:	439c                	lw	a5,0(a5)
 55a:	97ba                	add	a5,a5,a4
 55c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 55e:	008b8913          	add	s2,s7,8
 562:	4685                	li	a3,1
 564:	4629                	li	a2,10
 566:	000ba583          	lw	a1,0(s7)
 56a:	8556                	mv	a0,s5
 56c:	00000097          	auipc	ra,0x0
 570:	ebe080e7          	jalr	-322(ra) # 42a <printint>
 574:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 576:	4981                	li	s3,0
 578:	b745                	j	518 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 57a:	008b8913          	add	s2,s7,8
 57e:	4681                	li	a3,0
 580:	4629                	li	a2,10
 582:	000ba583          	lw	a1,0(s7)
 586:	8556                	mv	a0,s5
 588:	00000097          	auipc	ra,0x0
 58c:	ea2080e7          	jalr	-350(ra) # 42a <printint>
 590:	8bca                	mv	s7,s2
      state = 0;
 592:	4981                	li	s3,0
 594:	b751                	j	518 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 596:	008b8913          	add	s2,s7,8
 59a:	4681                	li	a3,0
 59c:	4641                	li	a2,16
 59e:	000ba583          	lw	a1,0(s7)
 5a2:	8556                	mv	a0,s5
 5a4:	00000097          	auipc	ra,0x0
 5a8:	e86080e7          	jalr	-378(ra) # 42a <printint>
 5ac:	8bca                	mv	s7,s2
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	b7a5                	j	518 <vprintf+0x42>
 5b2:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5b4:	008b8c13          	add	s8,s7,8
 5b8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5bc:	03000593          	li	a1,48
 5c0:	8556                	mv	a0,s5
 5c2:	00000097          	auipc	ra,0x0
 5c6:	e46080e7          	jalr	-442(ra) # 408 <putc>
  putc(fd, 'x');
 5ca:	07800593          	li	a1,120
 5ce:	8556                	mv	a0,s5
 5d0:	00000097          	auipc	ra,0x0
 5d4:	e38080e7          	jalr	-456(ra) # 408 <putc>
 5d8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5da:	00000b97          	auipc	s7,0x0
 5de:	346b8b93          	add	s7,s7,838 # 920 <digits>
 5e2:	03c9d793          	srl	a5,s3,0x3c
 5e6:	97de                	add	a5,a5,s7
 5e8:	0007c583          	lbu	a1,0(a5)
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	e1a080e7          	jalr	-486(ra) # 408 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5f6:	0992                	sll	s3,s3,0x4
 5f8:	397d                	addw	s2,s2,-1
 5fa:	fe0914e3          	bnez	s2,5e2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5fe:	8be2                	mv	s7,s8
      state = 0;
 600:	4981                	li	s3,0
 602:	6c02                	ld	s8,0(sp)
 604:	bf11                	j	518 <vprintf+0x42>
        s = va_arg(ap, char*);
 606:	008b8993          	add	s3,s7,8
 60a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 60e:	02090163          	beqz	s2,630 <vprintf+0x15a>
        while(*s != 0){
 612:	00094583          	lbu	a1,0(s2)
 616:	c9a5                	beqz	a1,686 <vprintf+0x1b0>
          putc(fd, *s);
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	dee080e7          	jalr	-530(ra) # 408 <putc>
          s++;
 622:	0905                	add	s2,s2,1
        while(*s != 0){
 624:	00094583          	lbu	a1,0(s2)
 628:	f9e5                	bnez	a1,618 <vprintf+0x142>
        s = va_arg(ap, char*);
 62a:	8bce                	mv	s7,s3
      state = 0;
 62c:	4981                	li	s3,0
 62e:	b5ed                	j	518 <vprintf+0x42>
          s = "(null)";
 630:	00000917          	auipc	s2,0x0
 634:	29090913          	add	s2,s2,656 # 8c0 <malloc+0x138>
        while(*s != 0){
 638:	02800593          	li	a1,40
 63c:	bff1                	j	618 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 63e:	008b8913          	add	s2,s7,8
 642:	000bc583          	lbu	a1,0(s7)
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	dc0080e7          	jalr	-576(ra) # 408 <putc>
 650:	8bca                	mv	s7,s2
      state = 0;
 652:	4981                	li	s3,0
 654:	b5d1                	j	518 <vprintf+0x42>
        putc(fd, c);
 656:	02500593          	li	a1,37
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	dac080e7          	jalr	-596(ra) # 408 <putc>
      state = 0;
 664:	4981                	li	s3,0
 666:	bd4d                	j	518 <vprintf+0x42>
        putc(fd, '%');
 668:	02500593          	li	a1,37
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	d9a080e7          	jalr	-614(ra) # 408 <putc>
        putc(fd, c);
 676:	85ca                	mv	a1,s2
 678:	8556                	mv	a0,s5
 67a:	00000097          	auipc	ra,0x0
 67e:	d8e080e7          	jalr	-626(ra) # 408 <putc>
      state = 0;
 682:	4981                	li	s3,0
 684:	bd51                	j	518 <vprintf+0x42>
        s = va_arg(ap, char*);
 686:	8bce                	mv	s7,s3
      state = 0;
 688:	4981                	li	s3,0
 68a:	b579                	j	518 <vprintf+0x42>
 68c:	74e2                	ld	s1,56(sp)
 68e:	79a2                	ld	s3,40(sp)
 690:	7a02                	ld	s4,32(sp)
 692:	6ae2                	ld	s5,24(sp)
 694:	6b42                	ld	s6,16(sp)
 696:	6ba2                	ld	s7,8(sp)
    }
  }
}
 698:	60a6                	ld	ra,72(sp)
 69a:	6406                	ld	s0,64(sp)
 69c:	7942                	ld	s2,48(sp)
 69e:	6161                	add	sp,sp,80
 6a0:	8082                	ret

00000000000006a2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6a2:	715d                	add	sp,sp,-80
 6a4:	ec06                	sd	ra,24(sp)
 6a6:	e822                	sd	s0,16(sp)
 6a8:	1000                	add	s0,sp,32
 6aa:	e010                	sd	a2,0(s0)
 6ac:	e414                	sd	a3,8(s0)
 6ae:	e818                	sd	a4,16(s0)
 6b0:	ec1c                	sd	a5,24(s0)
 6b2:	03043023          	sd	a6,32(s0)
 6b6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ba:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6be:	8622                	mv	a2,s0
 6c0:	00000097          	auipc	ra,0x0
 6c4:	e16080e7          	jalr	-490(ra) # 4d6 <vprintf>
}
 6c8:	60e2                	ld	ra,24(sp)
 6ca:	6442                	ld	s0,16(sp)
 6cc:	6161                	add	sp,sp,80
 6ce:	8082                	ret

00000000000006d0 <printf>:

void
printf(const char *fmt, ...)
{
 6d0:	711d                	add	sp,sp,-96
 6d2:	ec06                	sd	ra,24(sp)
 6d4:	e822                	sd	s0,16(sp)
 6d6:	1000                	add	s0,sp,32
 6d8:	e40c                	sd	a1,8(s0)
 6da:	e810                	sd	a2,16(s0)
 6dc:	ec14                	sd	a3,24(s0)
 6de:	f018                	sd	a4,32(s0)
 6e0:	f41c                	sd	a5,40(s0)
 6e2:	03043823          	sd	a6,48(s0)
 6e6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ea:	00840613          	add	a2,s0,8
 6ee:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6f2:	85aa                	mv	a1,a0
 6f4:	4505                	li	a0,1
 6f6:	00000097          	auipc	ra,0x0
 6fa:	de0080e7          	jalr	-544(ra) # 4d6 <vprintf>
}
 6fe:	60e2                	ld	ra,24(sp)
 700:	6442                	ld	s0,16(sp)
 702:	6125                	add	sp,sp,96
 704:	8082                	ret

0000000000000706 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 706:	1141                	add	sp,sp,-16
 708:	e422                	sd	s0,8(sp)
 70a:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 70c:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 710:	00000797          	auipc	a5,0x0
 714:	2287b783          	ld	a5,552(a5) # 938 <freep>
 718:	a02d                	j	742 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 71a:	4618                	lw	a4,8(a2)
 71c:	9f2d                	addw	a4,a4,a1
 71e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 722:	6398                	ld	a4,0(a5)
 724:	6310                	ld	a2,0(a4)
 726:	a83d                	j	764 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 728:	ff852703          	lw	a4,-8(a0)
 72c:	9f31                	addw	a4,a4,a2
 72e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 730:	ff053683          	ld	a3,-16(a0)
 734:	a091                	j	778 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 736:	6398                	ld	a4,0(a5)
 738:	00e7e463          	bltu	a5,a4,740 <free+0x3a>
 73c:	00e6ea63          	bltu	a3,a4,750 <free+0x4a>
{
 740:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 742:	fed7fae3          	bgeu	a5,a3,736 <free+0x30>
 746:	6398                	ld	a4,0(a5)
 748:	00e6e463          	bltu	a3,a4,750 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74c:	fee7eae3          	bltu	a5,a4,740 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 750:	ff852583          	lw	a1,-8(a0)
 754:	6390                	ld	a2,0(a5)
 756:	02059813          	sll	a6,a1,0x20
 75a:	01c85713          	srl	a4,a6,0x1c
 75e:	9736                	add	a4,a4,a3
 760:	fae60de3          	beq	a2,a4,71a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 764:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 768:	4790                	lw	a2,8(a5)
 76a:	02061593          	sll	a1,a2,0x20
 76e:	01c5d713          	srl	a4,a1,0x1c
 772:	973e                	add	a4,a4,a5
 774:	fae68ae3          	beq	a3,a4,728 <free+0x22>
    p->s.ptr = bp->s.ptr;
 778:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 77a:	00000717          	auipc	a4,0x0
 77e:	1af73f23          	sd	a5,446(a4) # 938 <freep>
}
 782:	6422                	ld	s0,8(sp)
 784:	0141                	add	sp,sp,16
 786:	8082                	ret

0000000000000788 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 788:	7139                	add	sp,sp,-64
 78a:	fc06                	sd	ra,56(sp)
 78c:	f822                	sd	s0,48(sp)
 78e:	f426                	sd	s1,40(sp)
 790:	ec4e                	sd	s3,24(sp)
 792:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 794:	02051493          	sll	s1,a0,0x20
 798:	9081                	srl	s1,s1,0x20
 79a:	04bd                	add	s1,s1,15
 79c:	8091                	srl	s1,s1,0x4
 79e:	0014899b          	addw	s3,s1,1
 7a2:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 7a4:	00000517          	auipc	a0,0x0
 7a8:	19453503          	ld	a0,404(a0) # 938 <freep>
 7ac:	c915                	beqz	a0,7e0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b0:	4798                	lw	a4,8(a5)
 7b2:	08977e63          	bgeu	a4,s1,84e <malloc+0xc6>
 7b6:	f04a                	sd	s2,32(sp)
 7b8:	e852                	sd	s4,16(sp)
 7ba:	e456                	sd	s5,8(sp)
 7bc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7be:	8a4e                	mv	s4,s3
 7c0:	0009871b          	sext.w	a4,s3
 7c4:	6685                	lui	a3,0x1
 7c6:	00d77363          	bgeu	a4,a3,7cc <malloc+0x44>
 7ca:	6a05                	lui	s4,0x1
 7cc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7d0:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d4:	00000917          	auipc	s2,0x0
 7d8:	16490913          	add	s2,s2,356 # 938 <freep>
  if(p == (char*)-1)
 7dc:	5afd                	li	s5,-1
 7de:	a091                	j	822 <malloc+0x9a>
 7e0:	f04a                	sd	s2,32(sp)
 7e2:	e852                	sd	s4,16(sp)
 7e4:	e456                	sd	s5,8(sp)
 7e6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7e8:	00000797          	auipc	a5,0x0
 7ec:	15878793          	add	a5,a5,344 # 940 <base>
 7f0:	00000717          	auipc	a4,0x0
 7f4:	14f73423          	sd	a5,328(a4) # 938 <freep>
 7f8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7fa:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7fe:	b7c1                	j	7be <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 800:	6398                	ld	a4,0(a5)
 802:	e118                	sd	a4,0(a0)
 804:	a08d                	j	866 <malloc+0xde>
  hp->s.size = nu;
 806:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 80a:	0541                	add	a0,a0,16
 80c:	00000097          	auipc	ra,0x0
 810:	efa080e7          	jalr	-262(ra) # 706 <free>
  return freep;
 814:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 818:	c13d                	beqz	a0,87e <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81c:	4798                	lw	a4,8(a5)
 81e:	02977463          	bgeu	a4,s1,846 <malloc+0xbe>
    if(p == freep)
 822:	00093703          	ld	a4,0(s2)
 826:	853e                	mv	a0,a5
 828:	fef719e3          	bne	a4,a5,81a <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 82c:	8552                	mv	a0,s4
 82e:	00000097          	auipc	ra,0x0
 832:	baa080e7          	jalr	-1110(ra) # 3d8 <sbrk>
  if(p == (char*)-1)
 836:	fd5518e3          	bne	a0,s5,806 <malloc+0x7e>
        return 0;
 83a:	4501                	li	a0,0
 83c:	7902                	ld	s2,32(sp)
 83e:	6a42                	ld	s4,16(sp)
 840:	6aa2                	ld	s5,8(sp)
 842:	6b02                	ld	s6,0(sp)
 844:	a03d                	j	872 <malloc+0xea>
 846:	7902                	ld	s2,32(sp)
 848:	6a42                	ld	s4,16(sp)
 84a:	6aa2                	ld	s5,8(sp)
 84c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 84e:	fae489e3          	beq	s1,a4,800 <malloc+0x78>
        p->s.size -= nunits;
 852:	4137073b          	subw	a4,a4,s3
 856:	c798                	sw	a4,8(a5)
        p += p->s.size;
 858:	02071693          	sll	a3,a4,0x20
 85c:	01c6d713          	srl	a4,a3,0x1c
 860:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 862:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 866:	00000717          	auipc	a4,0x0
 86a:	0ca73923          	sd	a0,210(a4) # 938 <freep>
      return (void*)(p + 1);
 86e:	01078513          	add	a0,a5,16
  }
}
 872:	70e2                	ld	ra,56(sp)
 874:	7442                	ld	s0,48(sp)
 876:	74a2                	ld	s1,40(sp)
 878:	69e2                	ld	s3,24(sp)
 87a:	6121                	add	sp,sp,64
 87c:	8082                	ret
 87e:	7902                	ld	s2,32(sp)
 880:	6a42                	ld	s4,16(sp)
 882:	6aa2                	ld	s5,8(sp)
 884:	6b02                	ld	s6,0(sp)
 886:	b7f5                	j	872 <malloc+0xea>
