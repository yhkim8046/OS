
user/_schedtest2:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:


#define NFORK 10
#define IO 5

int main() {
   0:	715d                	add	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	f052                	sd	s4,32(sp)
   e:	ec56                	sd	s5,24(sp)
  10:	e85a                	sd	s6,16(sp)
  12:	0880                	add	s0,sp,80
  int n, pid;
  int org, new;   
  int wtime, rtime, stime;
  int twtime=0, trtime=0, tstime=0;
  for(n=0; n < NFORK;n++) {
  14:	4481                	li	s1,0
          } else {
            for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process 
          }
          exit(0);
      } else {
		      if (n < IO) {
  16:	4a11                	li	s4,4
  for(n=0; n < NFORK;n++) {
  18:	4b29                	li	s6,10
		         org = setnice(pid, 18);  // Set lower priority for IO bound processes
             new = getnice(pid);
             printf("Process %d original nice is %d, now changed to %d\n", pid, org, new);
  1a:	00001a97          	auipc	s5,0x1
  1e:	8aea8a93          	add	s5,s5,-1874 # 8c8 <malloc+0x100>
  22:	a071                	j	ae <main+0xae>
		      }
      }
  }
  for(;n > 0; n--) {
  24:	00905663          	blez	s1,30 <main+0x30>
  for(n=0; n < NFORK;n++) {
  28:	4a01                	li	s4,0
  2a:	4901                	li	s2,0
  2c:	4981                	li	s3,0
  2e:	a0c9                	j	f0 <main+0xf0>
  for(;n > 0; n--) {
  30:	4a01                	li	s4,0
  32:	4901                	li	s2,0
  34:	4981                	li	s3,0
          trtime += rtime;
          twtime += wtime;
		  tstime += stime;
      } 
  }
  printf("Average run-time = %d,  wait time = %d, sleep time = %d\n", trtime / NFORK, twtime / NFORK, tstime / NFORK);
  36:	45a9                	li	a1,10
  38:	02ba46bb          	divw	a3,s4,a1
  3c:	02b9c63b          	divw	a2,s3,a1
  40:	02b945bb          	divw	a1,s2,a1
  44:	00001517          	auipc	a0,0x1
  48:	8bc50513          	add	a0,a0,-1860 # 900 <malloc+0x138>
  4c:	00000097          	auipc	ra,0x0
  50:	6c4080e7          	jalr	1732(ra) # 710 <printf>
  exit(0);
  54:	4501                	li	a0,0
  56:	00000097          	auipc	ra,0x0
  5a:	33a080e7          	jalr	826(ra) # 390 <exit>
          if (n < IO) {
  5e:	4791                	li	a5,4
  60:	0297dd63          	bge	a5,s1,9a <main+0x9a>
            for (volatile int i = 0; i < 1000000000; i++) {} // CPU bound process 
  64:	fa042823          	sw	zero,-80(s0)
  68:	fb042703          	lw	a4,-80(s0)
  6c:	2701                	sext.w	a4,a4
  6e:	3b9ad7b7          	lui	a5,0x3b9ad
  72:	9ff78793          	add	a5,a5,-1537 # 3b9ac9ff <__global_pointer$+0x3b9ab84e>
  76:	00e7cd63          	blt	a5,a4,90 <main+0x90>
  7a:	873e                	mv	a4,a5
  7c:	fb042783          	lw	a5,-80(s0)
  80:	2785                	addw	a5,a5,1
  82:	faf42823          	sw	a5,-80(s0)
  86:	fb042783          	lw	a5,-80(s0)
  8a:	2781                	sext.w	a5,a5
  8c:	fef758e3          	bge	a4,a5,7c <main+0x7c>
          exit(0);
  90:	4501                	li	a0,0
  92:	00000097          	auipc	ra,0x0
  96:	2fe080e7          	jalr	766(ra) # 390 <exit>
            sleep(200); // IO bound processes
  9a:	0c800513          	li	a0,200
  9e:	00000097          	auipc	ra,0x0
  a2:	382080e7          	jalr	898(ra) # 420 <sleep>
  a6:	b7ed                	j	90 <main+0x90>
  for(n=0; n < NFORK;n++) {
  a8:	2485                	addw	s1,s1,1
  aa:	f7648fe3          	beq	s1,s6,28 <main+0x28>
      pid = fork();
  ae:	00000097          	auipc	ra,0x0
  b2:	2da080e7          	jalr	730(ra) # 388 <fork>
  b6:	892a                	mv	s2,a0
      if (pid < 0)
  b8:	f60546e3          	bltz	a0,24 <main+0x24>
      if (pid == 0) {
  bc:	d14d                	beqz	a0,5e <main+0x5e>
		      if (n < IO) {
  be:	fe9a45e3          	blt	s4,s1,a8 <main+0xa8>
		         org = setnice(pid, 18);  // Set lower priority for IO bound processes
  c2:	45c9                	li	a1,18
  c4:	00000097          	auipc	ra,0x0
  c8:	374080e7          	jalr	884(ra) # 438 <setnice>
  cc:	89aa                	mv	s3,a0
             new = getnice(pid);
  ce:	854a                	mv	a0,s2
  d0:	00000097          	auipc	ra,0x0
  d4:	370080e7          	jalr	880(ra) # 440 <getnice>
  d8:	86aa                	mv	a3,a0
             printf("Process %d original nice is %d, now changed to %d\n", pid, org, new);
  da:	864e                	mv	a2,s3
  dc:	85ca                	mv	a1,s2
  de:	8556                	mv	a0,s5
  e0:	00000097          	auipc	ra,0x0
  e4:	630080e7          	jalr	1584(ra) # 710 <printf>
  for(n=0; n < NFORK;n++) {
  e8:	2485                	addw	s1,s1,1
  ea:	b7d1                	j	ae <main+0xae>
  for(;n > 0; n--) {
  ec:	34fd                	addw	s1,s1,-1
  ee:	d4a1                	beqz	s1,36 <main+0x36>
      if(wait2(0,&rtime,&wtime,&stime) >= 0) {
  f0:	fb440693          	add	a3,s0,-76
  f4:	fbc40613          	add	a2,s0,-68
  f8:	fb840593          	add	a1,s0,-72
  fc:	4501                	li	a0,0
  fe:	00000097          	auipc	ra,0x0
 102:	332080e7          	jalr	818(ra) # 430 <wait2>
 106:	fe0543e3          	bltz	a0,ec <main+0xec>
          trtime += rtime;
 10a:	fb842783          	lw	a5,-72(s0)
 10e:	0127893b          	addw	s2,a5,s2
          twtime += wtime;
 112:	fbc42783          	lw	a5,-68(s0)
 116:	013789bb          	addw	s3,a5,s3
		  tstime += stime;
 11a:	fb442783          	lw	a5,-76(s0)
 11e:	01478a3b          	addw	s4,a5,s4
 122:	b7e9                	j	ec <main+0xec>

0000000000000124 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 124:	1141                	add	sp,sp,-16
 126:	e422                	sd	s0,8(sp)
 128:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 12a:	87aa                	mv	a5,a0
 12c:	0585                	add	a1,a1,1
 12e:	0785                	add	a5,a5,1
 130:	fff5c703          	lbu	a4,-1(a1)
 134:	fee78fa3          	sb	a4,-1(a5)
 138:	fb75                	bnez	a4,12c <strcpy+0x8>
    ;
  return os;
}
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	add	sp,sp,16
 13e:	8082                	ret

0000000000000140 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 140:	1141                	add	sp,sp,-16
 142:	e422                	sd	s0,8(sp)
 144:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 146:	00054783          	lbu	a5,0(a0)
 14a:	cb91                	beqz	a5,15e <strcmp+0x1e>
 14c:	0005c703          	lbu	a4,0(a1)
 150:	00f71763          	bne	a4,a5,15e <strcmp+0x1e>
    p++, q++;
 154:	0505                	add	a0,a0,1
 156:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 158:	00054783          	lbu	a5,0(a0)
 15c:	fbe5                	bnez	a5,14c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 15e:	0005c503          	lbu	a0,0(a1)
}
 162:	40a7853b          	subw	a0,a5,a0
 166:	6422                	ld	s0,8(sp)
 168:	0141                	add	sp,sp,16
 16a:	8082                	ret

000000000000016c <strlen>:

uint
strlen(const char *s)
{
 16c:	1141                	add	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 172:	00054783          	lbu	a5,0(a0)
 176:	cf91                	beqz	a5,192 <strlen+0x26>
 178:	0505                	add	a0,a0,1
 17a:	87aa                	mv	a5,a0
 17c:	86be                	mv	a3,a5
 17e:	0785                	add	a5,a5,1
 180:	fff7c703          	lbu	a4,-1(a5)
 184:	ff65                	bnez	a4,17c <strlen+0x10>
 186:	40a6853b          	subw	a0,a3,a0
 18a:	2505                	addw	a0,a0,1
    ;
  return n;
}
 18c:	6422                	ld	s0,8(sp)
 18e:	0141                	add	sp,sp,16
 190:	8082                	ret
  for(n = 0; s[n]; n++)
 192:	4501                	li	a0,0
 194:	bfe5                	j	18c <strlen+0x20>

0000000000000196 <memset>:

void*
memset(void *dst, int c, uint n)
{
 196:	1141                	add	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 19c:	ca19                	beqz	a2,1b2 <memset+0x1c>
 19e:	87aa                	mv	a5,a0
 1a0:	1602                	sll	a2,a2,0x20
 1a2:	9201                	srl	a2,a2,0x20
 1a4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1a8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ac:	0785                	add	a5,a5,1
 1ae:	fee79de3          	bne	a5,a4,1a8 <memset+0x12>
  }
  return dst;
}
 1b2:	6422                	ld	s0,8(sp)
 1b4:	0141                	add	sp,sp,16
 1b6:	8082                	ret

00000000000001b8 <strchr>:

char*
strchr(const char *s, char c)
{
 1b8:	1141                	add	sp,sp,-16
 1ba:	e422                	sd	s0,8(sp)
 1bc:	0800                	add	s0,sp,16
  for(; *s; s++)
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	cb99                	beqz	a5,1d8 <strchr+0x20>
    if(*s == c)
 1c4:	00f58763          	beq	a1,a5,1d2 <strchr+0x1a>
  for(; *s; s++)
 1c8:	0505                	add	a0,a0,1
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	fbfd                	bnez	a5,1c4 <strchr+0xc>
      return (char*)s;
  return 0;
 1d0:	4501                	li	a0,0
}
 1d2:	6422                	ld	s0,8(sp)
 1d4:	0141                	add	sp,sp,16
 1d6:	8082                	ret
  return 0;
 1d8:	4501                	li	a0,0
 1da:	bfe5                	j	1d2 <strchr+0x1a>

00000000000001dc <gets>:

char*
gets(char *buf, int max)
{
 1dc:	711d                	add	sp,sp,-96
 1de:	ec86                	sd	ra,88(sp)
 1e0:	e8a2                	sd	s0,80(sp)
 1e2:	e4a6                	sd	s1,72(sp)
 1e4:	e0ca                	sd	s2,64(sp)
 1e6:	fc4e                	sd	s3,56(sp)
 1e8:	f852                	sd	s4,48(sp)
 1ea:	f456                	sd	s5,40(sp)
 1ec:	f05a                	sd	s6,32(sp)
 1ee:	ec5e                	sd	s7,24(sp)
 1f0:	1080                	add	s0,sp,96
 1f2:	8baa                	mv	s7,a0
 1f4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f6:	892a                	mv	s2,a0
 1f8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1fa:	4aa9                	li	s5,10
 1fc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1fe:	89a6                	mv	s3,s1
 200:	2485                	addw	s1,s1,1
 202:	0344d863          	bge	s1,s4,232 <gets+0x56>
    cc = read(0, &c, 1);
 206:	4605                	li	a2,1
 208:	faf40593          	add	a1,s0,-81
 20c:	4501                	li	a0,0
 20e:	00000097          	auipc	ra,0x0
 212:	19a080e7          	jalr	410(ra) # 3a8 <read>
    if(cc < 1)
 216:	00a05e63          	blez	a0,232 <gets+0x56>
    buf[i++] = c;
 21a:	faf44783          	lbu	a5,-81(s0)
 21e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 222:	01578763          	beq	a5,s5,230 <gets+0x54>
 226:	0905                	add	s2,s2,1
 228:	fd679be3          	bne	a5,s6,1fe <gets+0x22>
    buf[i++] = c;
 22c:	89a6                	mv	s3,s1
 22e:	a011                	j	232 <gets+0x56>
 230:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 232:	99de                	add	s3,s3,s7
 234:	00098023          	sb	zero,0(s3)
  return buf;
}
 238:	855e                	mv	a0,s7
 23a:	60e6                	ld	ra,88(sp)
 23c:	6446                	ld	s0,80(sp)
 23e:	64a6                	ld	s1,72(sp)
 240:	6906                	ld	s2,64(sp)
 242:	79e2                	ld	s3,56(sp)
 244:	7a42                	ld	s4,48(sp)
 246:	7aa2                	ld	s5,40(sp)
 248:	7b02                	ld	s6,32(sp)
 24a:	6be2                	ld	s7,24(sp)
 24c:	6125                	add	sp,sp,96
 24e:	8082                	ret

0000000000000250 <stat>:

int
stat(const char *n, struct stat *st)
{
 250:	1101                	add	sp,sp,-32
 252:	ec06                	sd	ra,24(sp)
 254:	e822                	sd	s0,16(sp)
 256:	e04a                	sd	s2,0(sp)
 258:	1000                	add	s0,sp,32
 25a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 25c:	4581                	li	a1,0
 25e:	00000097          	auipc	ra,0x0
 262:	172080e7          	jalr	370(ra) # 3d0 <open>
  if(fd < 0)
 266:	02054663          	bltz	a0,292 <stat+0x42>
 26a:	e426                	sd	s1,8(sp)
 26c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 26e:	85ca                	mv	a1,s2
 270:	00000097          	auipc	ra,0x0
 274:	178080e7          	jalr	376(ra) # 3e8 <fstat>
 278:	892a                	mv	s2,a0
  close(fd);
 27a:	8526                	mv	a0,s1
 27c:	00000097          	auipc	ra,0x0
 280:	13c080e7          	jalr	316(ra) # 3b8 <close>
  return r;
 284:	64a2                	ld	s1,8(sp)
}
 286:	854a                	mv	a0,s2
 288:	60e2                	ld	ra,24(sp)
 28a:	6442                	ld	s0,16(sp)
 28c:	6902                	ld	s2,0(sp)
 28e:	6105                	add	sp,sp,32
 290:	8082                	ret
    return -1;
 292:	597d                	li	s2,-1
 294:	bfcd                	j	286 <stat+0x36>

0000000000000296 <atoi>:

int
atoi(const char *s)
{
 296:	1141                	add	sp,sp,-16
 298:	e422                	sd	s0,8(sp)
 29a:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29c:	00054683          	lbu	a3,0(a0)
 2a0:	fd06879b          	addw	a5,a3,-48
 2a4:	0ff7f793          	zext.b	a5,a5
 2a8:	4625                	li	a2,9
 2aa:	02f66863          	bltu	a2,a5,2da <atoi+0x44>
 2ae:	872a                	mv	a4,a0
  n = 0;
 2b0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2b2:	0705                	add	a4,a4,1
 2b4:	0025179b          	sllw	a5,a0,0x2
 2b8:	9fa9                	addw	a5,a5,a0
 2ba:	0017979b          	sllw	a5,a5,0x1
 2be:	9fb5                	addw	a5,a5,a3
 2c0:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2c4:	00074683          	lbu	a3,0(a4)
 2c8:	fd06879b          	addw	a5,a3,-48
 2cc:	0ff7f793          	zext.b	a5,a5
 2d0:	fef671e3          	bgeu	a2,a5,2b2 <atoi+0x1c>
  return n;
}
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	add	sp,sp,16
 2d8:	8082                	ret
  n = 0;
 2da:	4501                	li	a0,0
 2dc:	bfe5                	j	2d4 <atoi+0x3e>

00000000000002de <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2de:	1141                	add	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e4:	02b57463          	bgeu	a0,a1,30c <memmove+0x2e>
    while(n-- > 0)
 2e8:	00c05f63          	blez	a2,306 <memmove+0x28>
 2ec:	1602                	sll	a2,a2,0x20
 2ee:	9201                	srl	a2,a2,0x20
 2f0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f6:	0585                	add	a1,a1,1
 2f8:	0705                	add	a4,a4,1
 2fa:	fff5c683          	lbu	a3,-1(a1)
 2fe:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 302:	fef71ae3          	bne	a4,a5,2f6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	add	sp,sp,16
 30a:	8082                	ret
    dst += n;
 30c:	00c50733          	add	a4,a0,a2
    src += n;
 310:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 312:	fec05ae3          	blez	a2,306 <memmove+0x28>
 316:	fff6079b          	addw	a5,a2,-1
 31a:	1782                	sll	a5,a5,0x20
 31c:	9381                	srl	a5,a5,0x20
 31e:	fff7c793          	not	a5,a5
 322:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 324:	15fd                	add	a1,a1,-1
 326:	177d                	add	a4,a4,-1
 328:	0005c683          	lbu	a3,0(a1)
 32c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 330:	fee79ae3          	bne	a5,a4,324 <memmove+0x46>
 334:	bfc9                	j	306 <memmove+0x28>

0000000000000336 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 336:	1141                	add	sp,sp,-16
 338:	e422                	sd	s0,8(sp)
 33a:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33c:	ca05                	beqz	a2,36c <memcmp+0x36>
 33e:	fff6069b          	addw	a3,a2,-1
 342:	1682                	sll	a3,a3,0x20
 344:	9281                	srl	a3,a3,0x20
 346:	0685                	add	a3,a3,1
 348:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 34a:	00054783          	lbu	a5,0(a0)
 34e:	0005c703          	lbu	a4,0(a1)
 352:	00e79863          	bne	a5,a4,362 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 356:	0505                	add	a0,a0,1
    p2++;
 358:	0585                	add	a1,a1,1
  while (n-- > 0) {
 35a:	fed518e3          	bne	a0,a3,34a <memcmp+0x14>
  }
  return 0;
 35e:	4501                	li	a0,0
 360:	a019                	j	366 <memcmp+0x30>
      return *p1 - *p2;
 362:	40e7853b          	subw	a0,a5,a4
}
 366:	6422                	ld	s0,8(sp)
 368:	0141                	add	sp,sp,16
 36a:	8082                	ret
  return 0;
 36c:	4501                	li	a0,0
 36e:	bfe5                	j	366 <memcmp+0x30>

0000000000000370 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 370:	1141                	add	sp,sp,-16
 372:	e406                	sd	ra,8(sp)
 374:	e022                	sd	s0,0(sp)
 376:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 378:	00000097          	auipc	ra,0x0
 37c:	f66080e7          	jalr	-154(ra) # 2de <memmove>
}
 380:	60a2                	ld	ra,8(sp)
 382:	6402                	ld	s0,0(sp)
 384:	0141                	add	sp,sp,16
 386:	8082                	ret

0000000000000388 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 388:	4885                	li	a7,1
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <exit>:
.global exit
exit:
 li a7, SYS_exit
 390:	4889                	li	a7,2
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <wait>:
.global wait
wait:
 li a7, SYS_wait
 398:	488d                	li	a7,3
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a0:	4891                	li	a7,4
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <read>:
.global read
read:
 li a7, SYS_read
 3a8:	4895                	li	a7,5
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <write>:
.global write
write:
 li a7, SYS_write
 3b0:	48c1                	li	a7,16
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <close>:
.global close
close:
 li a7, SYS_close
 3b8:	48d5                	li	a7,21
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c0:	4899                	li	a7,6
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3c8:	489d                	li	a7,7
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <open>:
.global open
open:
 li a7, SYS_open
 3d0:	48bd                	li	a7,15
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3d8:	48c5                	li	a7,17
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e0:	48c9                	li	a7,18
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3e8:	48a1                	li	a7,8
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <link>:
.global link
link:
 li a7, SYS_link
 3f0:	48cd                	li	a7,19
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3f8:	48d1                	li	a7,20
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 400:	48a5                	li	a7,9
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <dup>:
.global dup
dup:
 li a7, SYS_dup
 408:	48a9                	li	a7,10
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 410:	48ad                	li	a7,11
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 418:	48b1                	li	a7,12
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 420:	48b5                	li	a7,13
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 428:	48b9                	li	a7,14
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <wait2>:
.global wait2
wait2:
 li a7, SYS_wait2
 430:	48d9                	li	a7,22
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <setnice>:
.global setnice
setnice:
 li a7, SYS_setnice
 438:	48dd                	li	a7,23
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <getnice>:
.global getnice
getnice:
 li a7, SYS_getnice
 440:	48e1                	li	a7,24
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 448:	1101                	add	sp,sp,-32
 44a:	ec06                	sd	ra,24(sp)
 44c:	e822                	sd	s0,16(sp)
 44e:	1000                	add	s0,sp,32
 450:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 454:	4605                	li	a2,1
 456:	fef40593          	add	a1,s0,-17
 45a:	00000097          	auipc	ra,0x0
 45e:	f56080e7          	jalr	-170(ra) # 3b0 <write>
}
 462:	60e2                	ld	ra,24(sp)
 464:	6442                	ld	s0,16(sp)
 466:	6105                	add	sp,sp,32
 468:	8082                	ret

000000000000046a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 46a:	7139                	add	sp,sp,-64
 46c:	fc06                	sd	ra,56(sp)
 46e:	f822                	sd	s0,48(sp)
 470:	f426                	sd	s1,40(sp)
 472:	0080                	add	s0,sp,64
 474:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 476:	c299                	beqz	a3,47c <printint+0x12>
 478:	0805cb63          	bltz	a1,50e <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 47c:	2581                	sext.w	a1,a1
  neg = 0;
 47e:	4881                	li	a7,0
 480:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 484:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 486:	2601                	sext.w	a2,a2
 488:	00000517          	auipc	a0,0x0
 48c:	51850513          	add	a0,a0,1304 # 9a0 <digits>
 490:	883a                	mv	a6,a4
 492:	2705                	addw	a4,a4,1
 494:	02c5f7bb          	remuw	a5,a1,a2
 498:	1782                	sll	a5,a5,0x20
 49a:	9381                	srl	a5,a5,0x20
 49c:	97aa                	add	a5,a5,a0
 49e:	0007c783          	lbu	a5,0(a5)
 4a2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4a6:	0005879b          	sext.w	a5,a1
 4aa:	02c5d5bb          	divuw	a1,a1,a2
 4ae:	0685                	add	a3,a3,1
 4b0:	fec7f0e3          	bgeu	a5,a2,490 <printint+0x26>
  if(neg)
 4b4:	00088c63          	beqz	a7,4cc <printint+0x62>
    buf[i++] = '-';
 4b8:	fd070793          	add	a5,a4,-48
 4bc:	00878733          	add	a4,a5,s0
 4c0:	02d00793          	li	a5,45
 4c4:	fef70823          	sb	a5,-16(a4)
 4c8:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 4cc:	02e05c63          	blez	a4,504 <printint+0x9a>
 4d0:	f04a                	sd	s2,32(sp)
 4d2:	ec4e                	sd	s3,24(sp)
 4d4:	fc040793          	add	a5,s0,-64
 4d8:	00e78933          	add	s2,a5,a4
 4dc:	fff78993          	add	s3,a5,-1
 4e0:	99ba                	add	s3,s3,a4
 4e2:	377d                	addw	a4,a4,-1
 4e4:	1702                	sll	a4,a4,0x20
 4e6:	9301                	srl	a4,a4,0x20
 4e8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4ec:	fff94583          	lbu	a1,-1(s2)
 4f0:	8526                	mv	a0,s1
 4f2:	00000097          	auipc	ra,0x0
 4f6:	f56080e7          	jalr	-170(ra) # 448 <putc>
  while(--i >= 0)
 4fa:	197d                	add	s2,s2,-1
 4fc:	ff3918e3          	bne	s2,s3,4ec <printint+0x82>
 500:	7902                	ld	s2,32(sp)
 502:	69e2                	ld	s3,24(sp)
}
 504:	70e2                	ld	ra,56(sp)
 506:	7442                	ld	s0,48(sp)
 508:	74a2                	ld	s1,40(sp)
 50a:	6121                	add	sp,sp,64
 50c:	8082                	ret
    x = -xx;
 50e:	40b005bb          	negw	a1,a1
    neg = 1;
 512:	4885                	li	a7,1
    x = -xx;
 514:	b7b5                	j	480 <printint+0x16>

0000000000000516 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 516:	715d                	add	sp,sp,-80
 518:	e486                	sd	ra,72(sp)
 51a:	e0a2                	sd	s0,64(sp)
 51c:	f84a                	sd	s2,48(sp)
 51e:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 520:	0005c903          	lbu	s2,0(a1)
 524:	1a090a63          	beqz	s2,6d8 <vprintf+0x1c2>
 528:	fc26                	sd	s1,56(sp)
 52a:	f44e                	sd	s3,40(sp)
 52c:	f052                	sd	s4,32(sp)
 52e:	ec56                	sd	s5,24(sp)
 530:	e85a                	sd	s6,16(sp)
 532:	e45e                	sd	s7,8(sp)
 534:	8aaa                	mv	s5,a0
 536:	8bb2                	mv	s7,a2
 538:	00158493          	add	s1,a1,1
  state = 0;
 53c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 53e:	02500a13          	li	s4,37
 542:	4b55                	li	s6,21
 544:	a839                	j	562 <vprintf+0x4c>
        putc(fd, c);
 546:	85ca                	mv	a1,s2
 548:	8556                	mv	a0,s5
 54a:	00000097          	auipc	ra,0x0
 54e:	efe080e7          	jalr	-258(ra) # 448 <putc>
 552:	a019                	j	558 <vprintf+0x42>
    } else if(state == '%'){
 554:	01498d63          	beq	s3,s4,56e <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 558:	0485                	add	s1,s1,1
 55a:	fff4c903          	lbu	s2,-1(s1)
 55e:	16090763          	beqz	s2,6cc <vprintf+0x1b6>
    if(state == 0){
 562:	fe0999e3          	bnez	s3,554 <vprintf+0x3e>
      if(c == '%'){
 566:	ff4910e3          	bne	s2,s4,546 <vprintf+0x30>
        state = '%';
 56a:	89d2                	mv	s3,s4
 56c:	b7f5                	j	558 <vprintf+0x42>
      if(c == 'd'){
 56e:	13490463          	beq	s2,s4,696 <vprintf+0x180>
 572:	f9d9079b          	addw	a5,s2,-99
 576:	0ff7f793          	zext.b	a5,a5
 57a:	12fb6763          	bltu	s6,a5,6a8 <vprintf+0x192>
 57e:	f9d9079b          	addw	a5,s2,-99
 582:	0ff7f713          	zext.b	a4,a5
 586:	12eb6163          	bltu	s6,a4,6a8 <vprintf+0x192>
 58a:	00271793          	sll	a5,a4,0x2
 58e:	00000717          	auipc	a4,0x0
 592:	3ba70713          	add	a4,a4,954 # 948 <malloc+0x180>
 596:	97ba                	add	a5,a5,a4
 598:	439c                	lw	a5,0(a5)
 59a:	97ba                	add	a5,a5,a4
 59c:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 59e:	008b8913          	add	s2,s7,8
 5a2:	4685                	li	a3,1
 5a4:	4629                	li	a2,10
 5a6:	000ba583          	lw	a1,0(s7)
 5aa:	8556                	mv	a0,s5
 5ac:	00000097          	auipc	ra,0x0
 5b0:	ebe080e7          	jalr	-322(ra) # 46a <printint>
 5b4:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	b745                	j	558 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ba:	008b8913          	add	s2,s7,8
 5be:	4681                	li	a3,0
 5c0:	4629                	li	a2,10
 5c2:	000ba583          	lw	a1,0(s7)
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	ea2080e7          	jalr	-350(ra) # 46a <printint>
 5d0:	8bca                	mv	s7,s2
      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b751                	j	558 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5d6:	008b8913          	add	s2,s7,8
 5da:	4681                	li	a3,0
 5dc:	4641                	li	a2,16
 5de:	000ba583          	lw	a1,0(s7)
 5e2:	8556                	mv	a0,s5
 5e4:	00000097          	auipc	ra,0x0
 5e8:	e86080e7          	jalr	-378(ra) # 46a <printint>
 5ec:	8bca                	mv	s7,s2
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	b7a5                	j	558 <vprintf+0x42>
 5f2:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5f4:	008b8c13          	add	s8,s7,8
 5f8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5fc:	03000593          	li	a1,48
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	e46080e7          	jalr	-442(ra) # 448 <putc>
  putc(fd, 'x');
 60a:	07800593          	li	a1,120
 60e:	8556                	mv	a0,s5
 610:	00000097          	auipc	ra,0x0
 614:	e38080e7          	jalr	-456(ra) # 448 <putc>
 618:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61a:	00000b97          	auipc	s7,0x0
 61e:	386b8b93          	add	s7,s7,902 # 9a0 <digits>
 622:	03c9d793          	srl	a5,s3,0x3c
 626:	97de                	add	a5,a5,s7
 628:	0007c583          	lbu	a1,0(a5)
 62c:	8556                	mv	a0,s5
 62e:	00000097          	auipc	ra,0x0
 632:	e1a080e7          	jalr	-486(ra) # 448 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 636:	0992                	sll	s3,s3,0x4
 638:	397d                	addw	s2,s2,-1
 63a:	fe0914e3          	bnez	s2,622 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 63e:	8be2                	mv	s7,s8
      state = 0;
 640:	4981                	li	s3,0
 642:	6c02                	ld	s8,0(sp)
 644:	bf11                	j	558 <vprintf+0x42>
        s = va_arg(ap, char*);
 646:	008b8993          	add	s3,s7,8
 64a:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 64e:	02090163          	beqz	s2,670 <vprintf+0x15a>
        while(*s != 0){
 652:	00094583          	lbu	a1,0(s2)
 656:	c9a5                	beqz	a1,6c6 <vprintf+0x1b0>
          putc(fd, *s);
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	dee080e7          	jalr	-530(ra) # 448 <putc>
          s++;
 662:	0905                	add	s2,s2,1
        while(*s != 0){
 664:	00094583          	lbu	a1,0(s2)
 668:	f9e5                	bnez	a1,658 <vprintf+0x142>
        s = va_arg(ap, char*);
 66a:	8bce                	mv	s7,s3
      state = 0;
 66c:	4981                	li	s3,0
 66e:	b5ed                	j	558 <vprintf+0x42>
          s = "(null)";
 670:	00000917          	auipc	s2,0x0
 674:	2d090913          	add	s2,s2,720 # 940 <malloc+0x178>
        while(*s != 0){
 678:	02800593          	li	a1,40
 67c:	bff1                	j	658 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 67e:	008b8913          	add	s2,s7,8
 682:	000bc583          	lbu	a1,0(s7)
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	dc0080e7          	jalr	-576(ra) # 448 <putc>
 690:	8bca                	mv	s7,s2
      state = 0;
 692:	4981                	li	s3,0
 694:	b5d1                	j	558 <vprintf+0x42>
        putc(fd, c);
 696:	02500593          	li	a1,37
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	dac080e7          	jalr	-596(ra) # 448 <putc>
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	bd4d                	j	558 <vprintf+0x42>
        putc(fd, '%');
 6a8:	02500593          	li	a1,37
 6ac:	8556                	mv	a0,s5
 6ae:	00000097          	auipc	ra,0x0
 6b2:	d9a080e7          	jalr	-614(ra) # 448 <putc>
        putc(fd, c);
 6b6:	85ca                	mv	a1,s2
 6b8:	8556                	mv	a0,s5
 6ba:	00000097          	auipc	ra,0x0
 6be:	d8e080e7          	jalr	-626(ra) # 448 <putc>
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	bd51                	j	558 <vprintf+0x42>
        s = va_arg(ap, char*);
 6c6:	8bce                	mv	s7,s3
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	b579                	j	558 <vprintf+0x42>
 6cc:	74e2                	ld	s1,56(sp)
 6ce:	79a2                	ld	s3,40(sp)
 6d0:	7a02                	ld	s4,32(sp)
 6d2:	6ae2                	ld	s5,24(sp)
 6d4:	6b42                	ld	s6,16(sp)
 6d6:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6d8:	60a6                	ld	ra,72(sp)
 6da:	6406                	ld	s0,64(sp)
 6dc:	7942                	ld	s2,48(sp)
 6de:	6161                	add	sp,sp,80
 6e0:	8082                	ret

00000000000006e2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e2:	715d                	add	sp,sp,-80
 6e4:	ec06                	sd	ra,24(sp)
 6e6:	e822                	sd	s0,16(sp)
 6e8:	1000                	add	s0,sp,32
 6ea:	e010                	sd	a2,0(s0)
 6ec:	e414                	sd	a3,8(s0)
 6ee:	e818                	sd	a4,16(s0)
 6f0:	ec1c                	sd	a5,24(s0)
 6f2:	03043023          	sd	a6,32(s0)
 6f6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6fa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6fe:	8622                	mv	a2,s0
 700:	00000097          	auipc	ra,0x0
 704:	e16080e7          	jalr	-490(ra) # 516 <vprintf>
}
 708:	60e2                	ld	ra,24(sp)
 70a:	6442                	ld	s0,16(sp)
 70c:	6161                	add	sp,sp,80
 70e:	8082                	ret

0000000000000710 <printf>:

void
printf(const char *fmt, ...)
{
 710:	711d                	add	sp,sp,-96
 712:	ec06                	sd	ra,24(sp)
 714:	e822                	sd	s0,16(sp)
 716:	1000                	add	s0,sp,32
 718:	e40c                	sd	a1,8(s0)
 71a:	e810                	sd	a2,16(s0)
 71c:	ec14                	sd	a3,24(s0)
 71e:	f018                	sd	a4,32(s0)
 720:	f41c                	sd	a5,40(s0)
 722:	03043823          	sd	a6,48(s0)
 726:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 72a:	00840613          	add	a2,s0,8
 72e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 732:	85aa                	mv	a1,a0
 734:	4505                	li	a0,1
 736:	00000097          	auipc	ra,0x0
 73a:	de0080e7          	jalr	-544(ra) # 516 <vprintf>
}
 73e:	60e2                	ld	ra,24(sp)
 740:	6442                	ld	s0,16(sp)
 742:	6125                	add	sp,sp,96
 744:	8082                	ret

0000000000000746 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 746:	1141                	add	sp,sp,-16
 748:	e422                	sd	s0,8(sp)
 74a:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 74c:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 750:	00000797          	auipc	a5,0x0
 754:	2687b783          	ld	a5,616(a5) # 9b8 <freep>
 758:	a02d                	j	782 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 75a:	4618                	lw	a4,8(a2)
 75c:	9f2d                	addw	a4,a4,a1
 75e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 762:	6398                	ld	a4,0(a5)
 764:	6310                	ld	a2,0(a4)
 766:	a83d                	j	7a4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 768:	ff852703          	lw	a4,-8(a0)
 76c:	9f31                	addw	a4,a4,a2
 76e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 770:	ff053683          	ld	a3,-16(a0)
 774:	a091                	j	7b8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 776:	6398                	ld	a4,0(a5)
 778:	00e7e463          	bltu	a5,a4,780 <free+0x3a>
 77c:	00e6ea63          	bltu	a3,a4,790 <free+0x4a>
{
 780:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 782:	fed7fae3          	bgeu	a5,a3,776 <free+0x30>
 786:	6398                	ld	a4,0(a5)
 788:	00e6e463          	bltu	a3,a4,790 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 78c:	fee7eae3          	bltu	a5,a4,780 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 790:	ff852583          	lw	a1,-8(a0)
 794:	6390                	ld	a2,0(a5)
 796:	02059813          	sll	a6,a1,0x20
 79a:	01c85713          	srl	a4,a6,0x1c
 79e:	9736                	add	a4,a4,a3
 7a0:	fae60de3          	beq	a2,a4,75a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7a4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7a8:	4790                	lw	a2,8(a5)
 7aa:	02061593          	sll	a1,a2,0x20
 7ae:	01c5d713          	srl	a4,a1,0x1c
 7b2:	973e                	add	a4,a4,a5
 7b4:	fae68ae3          	beq	a3,a4,768 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7b8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7ba:	00000717          	auipc	a4,0x0
 7be:	1ef73f23          	sd	a5,510(a4) # 9b8 <freep>
}
 7c2:	6422                	ld	s0,8(sp)
 7c4:	0141                	add	sp,sp,16
 7c6:	8082                	ret

00000000000007c8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c8:	7139                	add	sp,sp,-64
 7ca:	fc06                	sd	ra,56(sp)
 7cc:	f822                	sd	s0,48(sp)
 7ce:	f426                	sd	s1,40(sp)
 7d0:	ec4e                	sd	s3,24(sp)
 7d2:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d4:	02051493          	sll	s1,a0,0x20
 7d8:	9081                	srl	s1,s1,0x20
 7da:	04bd                	add	s1,s1,15
 7dc:	8091                	srl	s1,s1,0x4
 7de:	0014899b          	addw	s3,s1,1
 7e2:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 7e4:	00000517          	auipc	a0,0x0
 7e8:	1d453503          	ld	a0,468(a0) # 9b8 <freep>
 7ec:	c915                	beqz	a0,820 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7f0:	4798                	lw	a4,8(a5)
 7f2:	08977e63          	bgeu	a4,s1,88e <malloc+0xc6>
 7f6:	f04a                	sd	s2,32(sp)
 7f8:	e852                	sd	s4,16(sp)
 7fa:	e456                	sd	s5,8(sp)
 7fc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7fe:	8a4e                	mv	s4,s3
 800:	0009871b          	sext.w	a4,s3
 804:	6685                	lui	a3,0x1
 806:	00d77363          	bgeu	a4,a3,80c <malloc+0x44>
 80a:	6a05                	lui	s4,0x1
 80c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 810:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 814:	00000917          	auipc	s2,0x0
 818:	1a490913          	add	s2,s2,420 # 9b8 <freep>
  if(p == (char*)-1)
 81c:	5afd                	li	s5,-1
 81e:	a091                	j	862 <malloc+0x9a>
 820:	f04a                	sd	s2,32(sp)
 822:	e852                	sd	s4,16(sp)
 824:	e456                	sd	s5,8(sp)
 826:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 828:	00000797          	auipc	a5,0x0
 82c:	19878793          	add	a5,a5,408 # 9c0 <base>
 830:	00000717          	auipc	a4,0x0
 834:	18f73423          	sd	a5,392(a4) # 9b8 <freep>
 838:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 83a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 83e:	b7c1                	j	7fe <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 840:	6398                	ld	a4,0(a5)
 842:	e118                	sd	a4,0(a0)
 844:	a08d                	j	8a6 <malloc+0xde>
  hp->s.size = nu;
 846:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 84a:	0541                	add	a0,a0,16
 84c:	00000097          	auipc	ra,0x0
 850:	efa080e7          	jalr	-262(ra) # 746 <free>
  return freep;
 854:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 858:	c13d                	beqz	a0,8be <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85c:	4798                	lw	a4,8(a5)
 85e:	02977463          	bgeu	a4,s1,886 <malloc+0xbe>
    if(p == freep)
 862:	00093703          	ld	a4,0(s2)
 866:	853e                	mv	a0,a5
 868:	fef719e3          	bne	a4,a5,85a <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 86c:	8552                	mv	a0,s4
 86e:	00000097          	auipc	ra,0x0
 872:	baa080e7          	jalr	-1110(ra) # 418 <sbrk>
  if(p == (char*)-1)
 876:	fd5518e3          	bne	a0,s5,846 <malloc+0x7e>
        return 0;
 87a:	4501                	li	a0,0
 87c:	7902                	ld	s2,32(sp)
 87e:	6a42                	ld	s4,16(sp)
 880:	6aa2                	ld	s5,8(sp)
 882:	6b02                	ld	s6,0(sp)
 884:	a03d                	j	8b2 <malloc+0xea>
 886:	7902                	ld	s2,32(sp)
 888:	6a42                	ld	s4,16(sp)
 88a:	6aa2                	ld	s5,8(sp)
 88c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 88e:	fae489e3          	beq	s1,a4,840 <malloc+0x78>
        p->s.size -= nunits;
 892:	4137073b          	subw	a4,a4,s3
 896:	c798                	sw	a4,8(a5)
        p += p->s.size;
 898:	02071693          	sll	a3,a4,0x20
 89c:	01c6d713          	srl	a4,a3,0x1c
 8a0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8a2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8a6:	00000717          	auipc	a4,0x0
 8aa:	10a73923          	sd	a0,274(a4) # 9b8 <freep>
      return (void*)(p + 1);
 8ae:	01078513          	add	a0,a5,16
  }
}
 8b2:	70e2                	ld	ra,56(sp)
 8b4:	7442                	ld	s0,48(sp)
 8b6:	74a2                	ld	s1,40(sp)
 8b8:	69e2                	ld	s3,24(sp)
 8ba:	6121                	add	sp,sp,64
 8bc:	8082                	ret
 8be:	7902                	ld	s2,32(sp)
 8c0:	6a42                	ld	s4,16(sp)
 8c2:	6aa2                	ld	s5,8(sp)
 8c4:	6b02                	ld	s6,0(sp)
 8c6:	b7f5                	j	8b2 <malloc+0xea>
