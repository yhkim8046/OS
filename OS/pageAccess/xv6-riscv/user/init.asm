
user/_init:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	1101                	add	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	add	s0,sp,32
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
   c:	4589                	li	a1,2
   e:	00001517          	auipc	a0,0x1
  12:	88250513          	add	a0,a0,-1918 # 890 <malloc+0x104>
  16:	00000097          	auipc	ra,0x0
  1a:	38e080e7          	jalr	910(ra) # 3a4 <open>
  1e:	06054363          	bltz	a0,84 <main+0x84>
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
  }
  dup(0);  // stdout
  22:	4501                	li	a0,0
  24:	00000097          	auipc	ra,0x0
  28:	3b8080e7          	jalr	952(ra) # 3dc <dup>
  dup(0);  // stderr
  2c:	4501                	li	a0,0
  2e:	00000097          	auipc	ra,0x0
  32:	3ae080e7          	jalr	942(ra) # 3dc <dup>

  for(;;){
    printf("init: starting sh\n");
  36:	00001917          	auipc	s2,0x1
  3a:	86290913          	add	s2,s2,-1950 # 898 <malloc+0x10c>
  3e:	854a                	mv	a0,s2
  40:	00000097          	auipc	ra,0x0
  44:	694080e7          	jalr	1684(ra) # 6d4 <printf>
    pid = fork();
  48:	00000097          	auipc	ra,0x0
  4c:	314080e7          	jalr	788(ra) # 35c <fork>
  50:	84aa                	mv	s1,a0
    if(pid < 0){
  52:	04054d63          	bltz	a0,ac <main+0xac>
      printf("init: fork failed\n");
      exit(1);
    }
    if(pid == 0){
  56:	c925                	beqz	a0,c6 <main+0xc6>
    }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
  58:	4501                	li	a0,0
  5a:	00000097          	auipc	ra,0x0
  5e:	312080e7          	jalr	786(ra) # 36c <wait>
      if(wpid == pid){
  62:	fca48ee3          	beq	s1,a0,3e <main+0x3e>
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
  66:	fe0559e3          	bgez	a0,58 <main+0x58>
        printf("init: wait returned an error\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	87e50513          	add	a0,a0,-1922 # 8e8 <malloc+0x15c>
  72:	00000097          	auipc	ra,0x0
  76:	662080e7          	jalr	1634(ra) # 6d4 <printf>
        exit(1);
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	2e8080e7          	jalr	744(ra) # 364 <exit>
    mknod("console", CONSOLE, 0);
  84:	4601                	li	a2,0
  86:	4585                	li	a1,1
  88:	00001517          	auipc	a0,0x1
  8c:	80850513          	add	a0,a0,-2040 # 890 <malloc+0x104>
  90:	00000097          	auipc	ra,0x0
  94:	31c080e7          	jalr	796(ra) # 3ac <mknod>
    open("console", O_RDWR);
  98:	4589                	li	a1,2
  9a:	00000517          	auipc	a0,0x0
  9e:	7f650513          	add	a0,a0,2038 # 890 <malloc+0x104>
  a2:	00000097          	auipc	ra,0x0
  a6:	302080e7          	jalr	770(ra) # 3a4 <open>
  aa:	bfa5                	j	22 <main+0x22>
      printf("init: fork failed\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	80450513          	add	a0,a0,-2044 # 8b0 <malloc+0x124>
  b4:	00000097          	auipc	ra,0x0
  b8:	620080e7          	jalr	1568(ra) # 6d4 <printf>
      exit(1);
  bc:	4505                	li	a0,1
  be:	00000097          	auipc	ra,0x0
  c2:	2a6080e7          	jalr	678(ra) # 364 <exit>
      exec("sh", argv);
  c6:	00001597          	auipc	a1,0x1
  ca:	8ba58593          	add	a1,a1,-1862 # 980 <argv>
  ce:	00000517          	auipc	a0,0x0
  d2:	7fa50513          	add	a0,a0,2042 # 8c8 <malloc+0x13c>
  d6:	00000097          	auipc	ra,0x0
  da:	2c6080e7          	jalr	710(ra) # 39c <exec>
      printf("init: exec sh failed\n");
  de:	00000517          	auipc	a0,0x0
  e2:	7f250513          	add	a0,a0,2034 # 8d0 <malloc+0x144>
  e6:	00000097          	auipc	ra,0x0
  ea:	5ee080e7          	jalr	1518(ra) # 6d4 <printf>
      exit(1);
  ee:	4505                	li	a0,1
  f0:	00000097          	auipc	ra,0x0
  f4:	274080e7          	jalr	628(ra) # 364 <exit>

00000000000000f8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  f8:	1141                	add	sp,sp,-16
  fa:	e422                	sd	s0,8(sp)
  fc:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  fe:	87aa                	mv	a5,a0
 100:	0585                	add	a1,a1,1
 102:	0785                	add	a5,a5,1
 104:	fff5c703          	lbu	a4,-1(a1)
 108:	fee78fa3          	sb	a4,-1(a5)
 10c:	fb75                	bnez	a4,100 <strcpy+0x8>
    ;
  return os;
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	add	sp,sp,16
 112:	8082                	ret

0000000000000114 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 114:	1141                	add	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cb91                	beqz	a5,132 <strcmp+0x1e>
 120:	0005c703          	lbu	a4,0(a1)
 124:	00f71763          	bne	a4,a5,132 <strcmp+0x1e>
    p++, q++;
 128:	0505                	add	a0,a0,1
 12a:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 12c:	00054783          	lbu	a5,0(a0)
 130:	fbe5                	bnez	a5,120 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 132:	0005c503          	lbu	a0,0(a1)
}
 136:	40a7853b          	subw	a0,a5,a0
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	add	sp,sp,16
 13e:	8082                	ret

0000000000000140 <strlen>:

uint
strlen(const char *s)
{
 140:	1141                	add	sp,sp,-16
 142:	e422                	sd	s0,8(sp)
 144:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 146:	00054783          	lbu	a5,0(a0)
 14a:	cf91                	beqz	a5,166 <strlen+0x26>
 14c:	0505                	add	a0,a0,1
 14e:	87aa                	mv	a5,a0
 150:	86be                	mv	a3,a5
 152:	0785                	add	a5,a5,1
 154:	fff7c703          	lbu	a4,-1(a5)
 158:	ff65                	bnez	a4,150 <strlen+0x10>
 15a:	40a6853b          	subw	a0,a3,a0
 15e:	2505                	addw	a0,a0,1
    ;
  return n;
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	add	sp,sp,16
 164:	8082                	ret
  for(n = 0; s[n]; n++)
 166:	4501                	li	a0,0
 168:	bfe5                	j	160 <strlen+0x20>

000000000000016a <memset>:

void*
memset(void *dst, int c, uint n)
{
 16a:	1141                	add	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 170:	ca19                	beqz	a2,186 <memset+0x1c>
 172:	87aa                	mv	a5,a0
 174:	1602                	sll	a2,a2,0x20
 176:	9201                	srl	a2,a2,0x20
 178:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 17c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 180:	0785                	add	a5,a5,1
 182:	fee79de3          	bne	a5,a4,17c <memset+0x12>
  }
  return dst;
}
 186:	6422                	ld	s0,8(sp)
 188:	0141                	add	sp,sp,16
 18a:	8082                	ret

000000000000018c <strchr>:

char*
strchr(const char *s, char c)
{
 18c:	1141                	add	sp,sp,-16
 18e:	e422                	sd	s0,8(sp)
 190:	0800                	add	s0,sp,16
  for(; *s; s++)
 192:	00054783          	lbu	a5,0(a0)
 196:	cb99                	beqz	a5,1ac <strchr+0x20>
    if(*s == c)
 198:	00f58763          	beq	a1,a5,1a6 <strchr+0x1a>
  for(; *s; s++)
 19c:	0505                	add	a0,a0,1
 19e:	00054783          	lbu	a5,0(a0)
 1a2:	fbfd                	bnez	a5,198 <strchr+0xc>
      return (char*)s;
  return 0;
 1a4:	4501                	li	a0,0
}
 1a6:	6422                	ld	s0,8(sp)
 1a8:	0141                	add	sp,sp,16
 1aa:	8082                	ret
  return 0;
 1ac:	4501                	li	a0,0
 1ae:	bfe5                	j	1a6 <strchr+0x1a>

00000000000001b0 <gets>:

char*
gets(char *buf, int max)
{
 1b0:	711d                	add	sp,sp,-96
 1b2:	ec86                	sd	ra,88(sp)
 1b4:	e8a2                	sd	s0,80(sp)
 1b6:	e4a6                	sd	s1,72(sp)
 1b8:	e0ca                	sd	s2,64(sp)
 1ba:	fc4e                	sd	s3,56(sp)
 1bc:	f852                	sd	s4,48(sp)
 1be:	f456                	sd	s5,40(sp)
 1c0:	f05a                	sd	s6,32(sp)
 1c2:	ec5e                	sd	s7,24(sp)
 1c4:	1080                	add	s0,sp,96
 1c6:	8baa                	mv	s7,a0
 1c8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ca:	892a                	mv	s2,a0
 1cc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ce:	4aa9                	li	s5,10
 1d0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d2:	89a6                	mv	s3,s1
 1d4:	2485                	addw	s1,s1,1
 1d6:	0344d863          	bge	s1,s4,206 <gets+0x56>
    cc = read(0, &c, 1);
 1da:	4605                	li	a2,1
 1dc:	faf40593          	add	a1,s0,-81
 1e0:	4501                	li	a0,0
 1e2:	00000097          	auipc	ra,0x0
 1e6:	19a080e7          	jalr	410(ra) # 37c <read>
    if(cc < 1)
 1ea:	00a05e63          	blez	a0,206 <gets+0x56>
    buf[i++] = c;
 1ee:	faf44783          	lbu	a5,-81(s0)
 1f2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1f6:	01578763          	beq	a5,s5,204 <gets+0x54>
 1fa:	0905                	add	s2,s2,1
 1fc:	fd679be3          	bne	a5,s6,1d2 <gets+0x22>
    buf[i++] = c;
 200:	89a6                	mv	s3,s1
 202:	a011                	j	206 <gets+0x56>
 204:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 206:	99de                	add	s3,s3,s7
 208:	00098023          	sb	zero,0(s3)
  return buf;
}
 20c:	855e                	mv	a0,s7
 20e:	60e6                	ld	ra,88(sp)
 210:	6446                	ld	s0,80(sp)
 212:	64a6                	ld	s1,72(sp)
 214:	6906                	ld	s2,64(sp)
 216:	79e2                	ld	s3,56(sp)
 218:	7a42                	ld	s4,48(sp)
 21a:	7aa2                	ld	s5,40(sp)
 21c:	7b02                	ld	s6,32(sp)
 21e:	6be2                	ld	s7,24(sp)
 220:	6125                	add	sp,sp,96
 222:	8082                	ret

0000000000000224 <stat>:

int
stat(const char *n, struct stat *st)
{
 224:	1101                	add	sp,sp,-32
 226:	ec06                	sd	ra,24(sp)
 228:	e822                	sd	s0,16(sp)
 22a:	e04a                	sd	s2,0(sp)
 22c:	1000                	add	s0,sp,32
 22e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 230:	4581                	li	a1,0
 232:	00000097          	auipc	ra,0x0
 236:	172080e7          	jalr	370(ra) # 3a4 <open>
  if(fd < 0)
 23a:	02054663          	bltz	a0,266 <stat+0x42>
 23e:	e426                	sd	s1,8(sp)
 240:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 242:	85ca                	mv	a1,s2
 244:	00000097          	auipc	ra,0x0
 248:	178080e7          	jalr	376(ra) # 3bc <fstat>
 24c:	892a                	mv	s2,a0
  close(fd);
 24e:	8526                	mv	a0,s1
 250:	00000097          	auipc	ra,0x0
 254:	13c080e7          	jalr	316(ra) # 38c <close>
  return r;
 258:	64a2                	ld	s1,8(sp)
}
 25a:	854a                	mv	a0,s2
 25c:	60e2                	ld	ra,24(sp)
 25e:	6442                	ld	s0,16(sp)
 260:	6902                	ld	s2,0(sp)
 262:	6105                	add	sp,sp,32
 264:	8082                	ret
    return -1;
 266:	597d                	li	s2,-1
 268:	bfcd                	j	25a <stat+0x36>

000000000000026a <atoi>:

int
atoi(const char *s)
{
 26a:	1141                	add	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 270:	00054683          	lbu	a3,0(a0)
 274:	fd06879b          	addw	a5,a3,-48
 278:	0ff7f793          	zext.b	a5,a5
 27c:	4625                	li	a2,9
 27e:	02f66863          	bltu	a2,a5,2ae <atoi+0x44>
 282:	872a                	mv	a4,a0
  n = 0;
 284:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 286:	0705                	add	a4,a4,1
 288:	0025179b          	sllw	a5,a0,0x2
 28c:	9fa9                	addw	a5,a5,a0
 28e:	0017979b          	sllw	a5,a5,0x1
 292:	9fb5                	addw	a5,a5,a3
 294:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 298:	00074683          	lbu	a3,0(a4)
 29c:	fd06879b          	addw	a5,a3,-48
 2a0:	0ff7f793          	zext.b	a5,a5
 2a4:	fef671e3          	bgeu	a2,a5,286 <atoi+0x1c>
  return n;
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	add	sp,sp,16
 2ac:	8082                	ret
  n = 0;
 2ae:	4501                	li	a0,0
 2b0:	bfe5                	j	2a8 <atoi+0x3e>

00000000000002b2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2b2:	1141                	add	sp,sp,-16
 2b4:	e422                	sd	s0,8(sp)
 2b6:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2b8:	02b57463          	bgeu	a0,a1,2e0 <memmove+0x2e>
    while(n-- > 0)
 2bc:	00c05f63          	blez	a2,2da <memmove+0x28>
 2c0:	1602                	sll	a2,a2,0x20
 2c2:	9201                	srl	a2,a2,0x20
 2c4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2c8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ca:	0585                	add	a1,a1,1
 2cc:	0705                	add	a4,a4,1
 2ce:	fff5c683          	lbu	a3,-1(a1)
 2d2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d6:	fef71ae3          	bne	a4,a5,2ca <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	add	sp,sp,16
 2de:	8082                	ret
    dst += n;
 2e0:	00c50733          	add	a4,a0,a2
    src += n;
 2e4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e6:	fec05ae3          	blez	a2,2da <memmove+0x28>
 2ea:	fff6079b          	addw	a5,a2,-1
 2ee:	1782                	sll	a5,a5,0x20
 2f0:	9381                	srl	a5,a5,0x20
 2f2:	fff7c793          	not	a5,a5
 2f6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f8:	15fd                	add	a1,a1,-1
 2fa:	177d                	add	a4,a4,-1
 2fc:	0005c683          	lbu	a3,0(a1)
 300:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 304:	fee79ae3          	bne	a5,a4,2f8 <memmove+0x46>
 308:	bfc9                	j	2da <memmove+0x28>

000000000000030a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 30a:	1141                	add	sp,sp,-16
 30c:	e422                	sd	s0,8(sp)
 30e:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 310:	ca05                	beqz	a2,340 <memcmp+0x36>
 312:	fff6069b          	addw	a3,a2,-1
 316:	1682                	sll	a3,a3,0x20
 318:	9281                	srl	a3,a3,0x20
 31a:	0685                	add	a3,a3,1
 31c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 31e:	00054783          	lbu	a5,0(a0)
 322:	0005c703          	lbu	a4,0(a1)
 326:	00e79863          	bne	a5,a4,336 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 32a:	0505                	add	a0,a0,1
    p2++;
 32c:	0585                	add	a1,a1,1
  while (n-- > 0) {
 32e:	fed518e3          	bne	a0,a3,31e <memcmp+0x14>
  }
  return 0;
 332:	4501                	li	a0,0
 334:	a019                	j	33a <memcmp+0x30>
      return *p1 - *p2;
 336:	40e7853b          	subw	a0,a5,a4
}
 33a:	6422                	ld	s0,8(sp)
 33c:	0141                	add	sp,sp,16
 33e:	8082                	ret
  return 0;
 340:	4501                	li	a0,0
 342:	bfe5                	j	33a <memcmp+0x30>

0000000000000344 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 344:	1141                	add	sp,sp,-16
 346:	e406                	sd	ra,8(sp)
 348:	e022                	sd	s0,0(sp)
 34a:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 34c:	00000097          	auipc	ra,0x0
 350:	f66080e7          	jalr	-154(ra) # 2b2 <memmove>
}
 354:	60a2                	ld	ra,8(sp)
 356:	6402                	ld	s0,0(sp)
 358:	0141                	add	sp,sp,16
 35a:	8082                	ret

000000000000035c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 35c:	4885                	li	a7,1
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <exit>:
.global exit
exit:
 li a7, SYS_exit
 364:	4889                	li	a7,2
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <wait>:
.global wait
wait:
 li a7, SYS_wait
 36c:	488d                	li	a7,3
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 374:	4891                	li	a7,4
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <read>:
.global read
read:
 li a7, SYS_read
 37c:	4895                	li	a7,5
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <write>:
.global write
write:
 li a7, SYS_write
 384:	48c1                	li	a7,16
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <close>:
.global close
close:
 li a7, SYS_close
 38c:	48d5                	li	a7,21
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <kill>:
.global kill
kill:
 li a7, SYS_kill
 394:	4899                	li	a7,6
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <exec>:
.global exec
exec:
 li a7, SYS_exec
 39c:	489d                	li	a7,7
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <open>:
.global open
open:
 li a7, SYS_open
 3a4:	48bd                	li	a7,15
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ac:	48c5                	li	a7,17
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b4:	48c9                	li	a7,18
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3bc:	48a1                	li	a7,8
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <link>:
.global link
link:
 li a7, SYS_link
 3c4:	48cd                	li	a7,19
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3cc:	48d1                	li	a7,20
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d4:	48a5                	li	a7,9
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <dup>:
.global dup
dup:
 li a7, SYS_dup
 3dc:	48a9                	li	a7,10
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e4:	48ad                	li	a7,11
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3ec:	48b1                	li	a7,12
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3f4:	48b5                	li	a7,13
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3fc:	48b9                	li	a7,14
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <pageAccess>:
.global pageAccess
pageAccess:
 li a7, SYS_pageAccess
 404:	48d9                	li	a7,22
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40c:	1101                	add	sp,sp,-32
 40e:	ec06                	sd	ra,24(sp)
 410:	e822                	sd	s0,16(sp)
 412:	1000                	add	s0,sp,32
 414:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 418:	4605                	li	a2,1
 41a:	fef40593          	add	a1,s0,-17
 41e:	00000097          	auipc	ra,0x0
 422:	f66080e7          	jalr	-154(ra) # 384 <write>
}
 426:	60e2                	ld	ra,24(sp)
 428:	6442                	ld	s0,16(sp)
 42a:	6105                	add	sp,sp,32
 42c:	8082                	ret

000000000000042e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 42e:	7139                	add	sp,sp,-64
 430:	fc06                	sd	ra,56(sp)
 432:	f822                	sd	s0,48(sp)
 434:	f426                	sd	s1,40(sp)
 436:	0080                	add	s0,sp,64
 438:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 43a:	c299                	beqz	a3,440 <printint+0x12>
 43c:	0805cb63          	bltz	a1,4d2 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 440:	2581                	sext.w	a1,a1
  neg = 0;
 442:	4881                	li	a7,0
 444:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 448:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 44a:	2601                	sext.w	a2,a2
 44c:	00000517          	auipc	a0,0x0
 450:	51c50513          	add	a0,a0,1308 # 968 <digits>
 454:	883a                	mv	a6,a4
 456:	2705                	addw	a4,a4,1
 458:	02c5f7bb          	remuw	a5,a1,a2
 45c:	1782                	sll	a5,a5,0x20
 45e:	9381                	srl	a5,a5,0x20
 460:	97aa                	add	a5,a5,a0
 462:	0007c783          	lbu	a5,0(a5)
 466:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 46a:	0005879b          	sext.w	a5,a1
 46e:	02c5d5bb          	divuw	a1,a1,a2
 472:	0685                	add	a3,a3,1
 474:	fec7f0e3          	bgeu	a5,a2,454 <printint+0x26>
  if(neg)
 478:	00088c63          	beqz	a7,490 <printint+0x62>
    buf[i++] = '-';
 47c:	fd070793          	add	a5,a4,-48
 480:	00878733          	add	a4,a5,s0
 484:	02d00793          	li	a5,45
 488:	fef70823          	sb	a5,-16(a4)
 48c:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 490:	02e05c63          	blez	a4,4c8 <printint+0x9a>
 494:	f04a                	sd	s2,32(sp)
 496:	ec4e                	sd	s3,24(sp)
 498:	fc040793          	add	a5,s0,-64
 49c:	00e78933          	add	s2,a5,a4
 4a0:	fff78993          	add	s3,a5,-1
 4a4:	99ba                	add	s3,s3,a4
 4a6:	377d                	addw	a4,a4,-1
 4a8:	1702                	sll	a4,a4,0x20
 4aa:	9301                	srl	a4,a4,0x20
 4ac:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4b0:	fff94583          	lbu	a1,-1(s2)
 4b4:	8526                	mv	a0,s1
 4b6:	00000097          	auipc	ra,0x0
 4ba:	f56080e7          	jalr	-170(ra) # 40c <putc>
  while(--i >= 0)
 4be:	197d                	add	s2,s2,-1
 4c0:	ff3918e3          	bne	s2,s3,4b0 <printint+0x82>
 4c4:	7902                	ld	s2,32(sp)
 4c6:	69e2                	ld	s3,24(sp)
}
 4c8:	70e2                	ld	ra,56(sp)
 4ca:	7442                	ld	s0,48(sp)
 4cc:	74a2                	ld	s1,40(sp)
 4ce:	6121                	add	sp,sp,64
 4d0:	8082                	ret
    x = -xx;
 4d2:	40b005bb          	negw	a1,a1
    neg = 1;
 4d6:	4885                	li	a7,1
    x = -xx;
 4d8:	b7b5                	j	444 <printint+0x16>

00000000000004da <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4da:	715d                	add	sp,sp,-80
 4dc:	e486                	sd	ra,72(sp)
 4de:	e0a2                	sd	s0,64(sp)
 4e0:	f84a                	sd	s2,48(sp)
 4e2:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e4:	0005c903          	lbu	s2,0(a1)
 4e8:	1a090a63          	beqz	s2,69c <vprintf+0x1c2>
 4ec:	fc26                	sd	s1,56(sp)
 4ee:	f44e                	sd	s3,40(sp)
 4f0:	f052                	sd	s4,32(sp)
 4f2:	ec56                	sd	s5,24(sp)
 4f4:	e85a                	sd	s6,16(sp)
 4f6:	e45e                	sd	s7,8(sp)
 4f8:	8aaa                	mv	s5,a0
 4fa:	8bb2                	mv	s7,a2
 4fc:	00158493          	add	s1,a1,1
  state = 0;
 500:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 502:	02500a13          	li	s4,37
 506:	4b55                	li	s6,21
 508:	a839                	j	526 <vprintf+0x4c>
        putc(fd, c);
 50a:	85ca                	mv	a1,s2
 50c:	8556                	mv	a0,s5
 50e:	00000097          	auipc	ra,0x0
 512:	efe080e7          	jalr	-258(ra) # 40c <putc>
 516:	a019                	j	51c <vprintf+0x42>
    } else if(state == '%'){
 518:	01498d63          	beq	s3,s4,532 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 51c:	0485                	add	s1,s1,1
 51e:	fff4c903          	lbu	s2,-1(s1)
 522:	16090763          	beqz	s2,690 <vprintf+0x1b6>
    if(state == 0){
 526:	fe0999e3          	bnez	s3,518 <vprintf+0x3e>
      if(c == '%'){
 52a:	ff4910e3          	bne	s2,s4,50a <vprintf+0x30>
        state = '%';
 52e:	89d2                	mv	s3,s4
 530:	b7f5                	j	51c <vprintf+0x42>
      if(c == 'd'){
 532:	13490463          	beq	s2,s4,65a <vprintf+0x180>
 536:	f9d9079b          	addw	a5,s2,-99
 53a:	0ff7f793          	zext.b	a5,a5
 53e:	12fb6763          	bltu	s6,a5,66c <vprintf+0x192>
 542:	f9d9079b          	addw	a5,s2,-99
 546:	0ff7f713          	zext.b	a4,a5
 54a:	12eb6163          	bltu	s6,a4,66c <vprintf+0x192>
 54e:	00271793          	sll	a5,a4,0x2
 552:	00000717          	auipc	a4,0x0
 556:	3be70713          	add	a4,a4,958 # 910 <malloc+0x184>
 55a:	97ba                	add	a5,a5,a4
 55c:	439c                	lw	a5,0(a5)
 55e:	97ba                	add	a5,a5,a4
 560:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 562:	008b8913          	add	s2,s7,8
 566:	4685                	li	a3,1
 568:	4629                	li	a2,10
 56a:	000ba583          	lw	a1,0(s7)
 56e:	8556                	mv	a0,s5
 570:	00000097          	auipc	ra,0x0
 574:	ebe080e7          	jalr	-322(ra) # 42e <printint>
 578:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 57a:	4981                	li	s3,0
 57c:	b745                	j	51c <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 57e:	008b8913          	add	s2,s7,8
 582:	4681                	li	a3,0
 584:	4629                	li	a2,10
 586:	000ba583          	lw	a1,0(s7)
 58a:	8556                	mv	a0,s5
 58c:	00000097          	auipc	ra,0x0
 590:	ea2080e7          	jalr	-350(ra) # 42e <printint>
 594:	8bca                	mv	s7,s2
      state = 0;
 596:	4981                	li	s3,0
 598:	b751                	j	51c <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 59a:	008b8913          	add	s2,s7,8
 59e:	4681                	li	a3,0
 5a0:	4641                	li	a2,16
 5a2:	000ba583          	lw	a1,0(s7)
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	e86080e7          	jalr	-378(ra) # 42e <printint>
 5b0:	8bca                	mv	s7,s2
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	b7a5                	j	51c <vprintf+0x42>
 5b6:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5b8:	008b8c13          	add	s8,s7,8
 5bc:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5c0:	03000593          	li	a1,48
 5c4:	8556                	mv	a0,s5
 5c6:	00000097          	auipc	ra,0x0
 5ca:	e46080e7          	jalr	-442(ra) # 40c <putc>
  putc(fd, 'x');
 5ce:	07800593          	li	a1,120
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	e38080e7          	jalr	-456(ra) # 40c <putc>
 5dc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5de:	00000b97          	auipc	s7,0x0
 5e2:	38ab8b93          	add	s7,s7,906 # 968 <digits>
 5e6:	03c9d793          	srl	a5,s3,0x3c
 5ea:	97de                	add	a5,a5,s7
 5ec:	0007c583          	lbu	a1,0(a5)
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	e1a080e7          	jalr	-486(ra) # 40c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5fa:	0992                	sll	s3,s3,0x4
 5fc:	397d                	addw	s2,s2,-1
 5fe:	fe0914e3          	bnez	s2,5e6 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 602:	8be2                	mv	s7,s8
      state = 0;
 604:	4981                	li	s3,0
 606:	6c02                	ld	s8,0(sp)
 608:	bf11                	j	51c <vprintf+0x42>
        s = va_arg(ap, char*);
 60a:	008b8993          	add	s3,s7,8
 60e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 612:	02090163          	beqz	s2,634 <vprintf+0x15a>
        while(*s != 0){
 616:	00094583          	lbu	a1,0(s2)
 61a:	c9a5                	beqz	a1,68a <vprintf+0x1b0>
          putc(fd, *s);
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	dee080e7          	jalr	-530(ra) # 40c <putc>
          s++;
 626:	0905                	add	s2,s2,1
        while(*s != 0){
 628:	00094583          	lbu	a1,0(s2)
 62c:	f9e5                	bnez	a1,61c <vprintf+0x142>
        s = va_arg(ap, char*);
 62e:	8bce                	mv	s7,s3
      state = 0;
 630:	4981                	li	s3,0
 632:	b5ed                	j	51c <vprintf+0x42>
          s = "(null)";
 634:	00000917          	auipc	s2,0x0
 638:	2d490913          	add	s2,s2,724 # 908 <malloc+0x17c>
        while(*s != 0){
 63c:	02800593          	li	a1,40
 640:	bff1                	j	61c <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 642:	008b8913          	add	s2,s7,8
 646:	000bc583          	lbu	a1,0(s7)
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	dc0080e7          	jalr	-576(ra) # 40c <putc>
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
 658:	b5d1                	j	51c <vprintf+0x42>
        putc(fd, c);
 65a:	02500593          	li	a1,37
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	dac080e7          	jalr	-596(ra) # 40c <putc>
      state = 0;
 668:	4981                	li	s3,0
 66a:	bd4d                	j	51c <vprintf+0x42>
        putc(fd, '%');
 66c:	02500593          	li	a1,37
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	d9a080e7          	jalr	-614(ra) # 40c <putc>
        putc(fd, c);
 67a:	85ca                	mv	a1,s2
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	d8e080e7          	jalr	-626(ra) # 40c <putc>
      state = 0;
 686:	4981                	li	s3,0
 688:	bd51                	j	51c <vprintf+0x42>
        s = va_arg(ap, char*);
 68a:	8bce                	mv	s7,s3
      state = 0;
 68c:	4981                	li	s3,0
 68e:	b579                	j	51c <vprintf+0x42>
 690:	74e2                	ld	s1,56(sp)
 692:	79a2                	ld	s3,40(sp)
 694:	7a02                	ld	s4,32(sp)
 696:	6ae2                	ld	s5,24(sp)
 698:	6b42                	ld	s6,16(sp)
 69a:	6ba2                	ld	s7,8(sp)
    }
  }
}
 69c:	60a6                	ld	ra,72(sp)
 69e:	6406                	ld	s0,64(sp)
 6a0:	7942                	ld	s2,48(sp)
 6a2:	6161                	add	sp,sp,80
 6a4:	8082                	ret

00000000000006a6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6a6:	715d                	add	sp,sp,-80
 6a8:	ec06                	sd	ra,24(sp)
 6aa:	e822                	sd	s0,16(sp)
 6ac:	1000                	add	s0,sp,32
 6ae:	e010                	sd	a2,0(s0)
 6b0:	e414                	sd	a3,8(s0)
 6b2:	e818                	sd	a4,16(s0)
 6b4:	ec1c                	sd	a5,24(s0)
 6b6:	03043023          	sd	a6,32(s0)
 6ba:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6be:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6c2:	8622                	mv	a2,s0
 6c4:	00000097          	auipc	ra,0x0
 6c8:	e16080e7          	jalr	-490(ra) # 4da <vprintf>
}
 6cc:	60e2                	ld	ra,24(sp)
 6ce:	6442                	ld	s0,16(sp)
 6d0:	6161                	add	sp,sp,80
 6d2:	8082                	ret

00000000000006d4 <printf>:

void
printf(const char *fmt, ...)
{
 6d4:	711d                	add	sp,sp,-96
 6d6:	ec06                	sd	ra,24(sp)
 6d8:	e822                	sd	s0,16(sp)
 6da:	1000                	add	s0,sp,32
 6dc:	e40c                	sd	a1,8(s0)
 6de:	e810                	sd	a2,16(s0)
 6e0:	ec14                	sd	a3,24(s0)
 6e2:	f018                	sd	a4,32(s0)
 6e4:	f41c                	sd	a5,40(s0)
 6e6:	03043823          	sd	a6,48(s0)
 6ea:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ee:	00840613          	add	a2,s0,8
 6f2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6f6:	85aa                	mv	a1,a0
 6f8:	4505                	li	a0,1
 6fa:	00000097          	auipc	ra,0x0
 6fe:	de0080e7          	jalr	-544(ra) # 4da <vprintf>
}
 702:	60e2                	ld	ra,24(sp)
 704:	6442                	ld	s0,16(sp)
 706:	6125                	add	sp,sp,96
 708:	8082                	ret

000000000000070a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 70a:	1141                	add	sp,sp,-16
 70c:	e422                	sd	s0,8(sp)
 70e:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 710:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 714:	00000797          	auipc	a5,0x0
 718:	27c7b783          	ld	a5,636(a5) # 990 <freep>
 71c:	a02d                	j	746 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 71e:	4618                	lw	a4,8(a2)
 720:	9f2d                	addw	a4,a4,a1
 722:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 726:	6398                	ld	a4,0(a5)
 728:	6310                	ld	a2,0(a4)
 72a:	a83d                	j	768 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 72c:	ff852703          	lw	a4,-8(a0)
 730:	9f31                	addw	a4,a4,a2
 732:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 734:	ff053683          	ld	a3,-16(a0)
 738:	a091                	j	77c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 73a:	6398                	ld	a4,0(a5)
 73c:	00e7e463          	bltu	a5,a4,744 <free+0x3a>
 740:	00e6ea63          	bltu	a3,a4,754 <free+0x4a>
{
 744:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 746:	fed7fae3          	bgeu	a5,a3,73a <free+0x30>
 74a:	6398                	ld	a4,0(a5)
 74c:	00e6e463          	bltu	a3,a4,754 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 750:	fee7eae3          	bltu	a5,a4,744 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 754:	ff852583          	lw	a1,-8(a0)
 758:	6390                	ld	a2,0(a5)
 75a:	02059813          	sll	a6,a1,0x20
 75e:	01c85713          	srl	a4,a6,0x1c
 762:	9736                	add	a4,a4,a3
 764:	fae60de3          	beq	a2,a4,71e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 768:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 76c:	4790                	lw	a2,8(a5)
 76e:	02061593          	sll	a1,a2,0x20
 772:	01c5d713          	srl	a4,a1,0x1c
 776:	973e                	add	a4,a4,a5
 778:	fae68ae3          	beq	a3,a4,72c <free+0x22>
    p->s.ptr = bp->s.ptr;
 77c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 77e:	00000717          	auipc	a4,0x0
 782:	20f73923          	sd	a5,530(a4) # 990 <freep>
}
 786:	6422                	ld	s0,8(sp)
 788:	0141                	add	sp,sp,16
 78a:	8082                	ret

000000000000078c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 78c:	7139                	add	sp,sp,-64
 78e:	fc06                	sd	ra,56(sp)
 790:	f822                	sd	s0,48(sp)
 792:	f426                	sd	s1,40(sp)
 794:	ec4e                	sd	s3,24(sp)
 796:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 798:	02051493          	sll	s1,a0,0x20
 79c:	9081                	srl	s1,s1,0x20
 79e:	04bd                	add	s1,s1,15
 7a0:	8091                	srl	s1,s1,0x4
 7a2:	0014899b          	addw	s3,s1,1
 7a6:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 7a8:	00000517          	auipc	a0,0x0
 7ac:	1e853503          	ld	a0,488(a0) # 990 <freep>
 7b0:	c915                	beqz	a0,7e4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7b4:	4798                	lw	a4,8(a5)
 7b6:	08977e63          	bgeu	a4,s1,852 <malloc+0xc6>
 7ba:	f04a                	sd	s2,32(sp)
 7bc:	e852                	sd	s4,16(sp)
 7be:	e456                	sd	s5,8(sp)
 7c0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7c2:	8a4e                	mv	s4,s3
 7c4:	0009871b          	sext.w	a4,s3
 7c8:	6685                	lui	a3,0x1
 7ca:	00d77363          	bgeu	a4,a3,7d0 <malloc+0x44>
 7ce:	6a05                	lui	s4,0x1
 7d0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7d4:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7d8:	00000917          	auipc	s2,0x0
 7dc:	1b890913          	add	s2,s2,440 # 990 <freep>
  if(p == (char*)-1)
 7e0:	5afd                	li	s5,-1
 7e2:	a091                	j	826 <malloc+0x9a>
 7e4:	f04a                	sd	s2,32(sp)
 7e6:	e852                	sd	s4,16(sp)
 7e8:	e456                	sd	s5,8(sp)
 7ea:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7ec:	00000797          	auipc	a5,0x0
 7f0:	1ac78793          	add	a5,a5,428 # 998 <base>
 7f4:	00000717          	auipc	a4,0x0
 7f8:	18f73e23          	sd	a5,412(a4) # 990 <freep>
 7fc:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7fe:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 802:	b7c1                	j	7c2 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 804:	6398                	ld	a4,0(a5)
 806:	e118                	sd	a4,0(a0)
 808:	a08d                	j	86a <malloc+0xde>
  hp->s.size = nu;
 80a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 80e:	0541                	add	a0,a0,16
 810:	00000097          	auipc	ra,0x0
 814:	efa080e7          	jalr	-262(ra) # 70a <free>
  return freep;
 818:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 81c:	c13d                	beqz	a0,882 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 81e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 820:	4798                	lw	a4,8(a5)
 822:	02977463          	bgeu	a4,s1,84a <malloc+0xbe>
    if(p == freep)
 826:	00093703          	ld	a4,0(s2)
 82a:	853e                	mv	a0,a5
 82c:	fef719e3          	bne	a4,a5,81e <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 830:	8552                	mv	a0,s4
 832:	00000097          	auipc	ra,0x0
 836:	bba080e7          	jalr	-1094(ra) # 3ec <sbrk>
  if(p == (char*)-1)
 83a:	fd5518e3          	bne	a0,s5,80a <malloc+0x7e>
        return 0;
 83e:	4501                	li	a0,0
 840:	7902                	ld	s2,32(sp)
 842:	6a42                	ld	s4,16(sp)
 844:	6aa2                	ld	s5,8(sp)
 846:	6b02                	ld	s6,0(sp)
 848:	a03d                	j	876 <malloc+0xea>
 84a:	7902                	ld	s2,32(sp)
 84c:	6a42                	ld	s4,16(sp)
 84e:	6aa2                	ld	s5,8(sp)
 850:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 852:	fae489e3          	beq	s1,a4,804 <malloc+0x78>
        p->s.size -= nunits;
 856:	4137073b          	subw	a4,a4,s3
 85a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 85c:	02071693          	sll	a3,a4,0x20
 860:	01c6d713          	srl	a4,a3,0x1c
 864:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 866:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 86a:	00000717          	auipc	a4,0x0
 86e:	12a73323          	sd	a0,294(a4) # 990 <freep>
      return (void*)(p + 1);
 872:	01078513          	add	a0,a5,16
  }
}
 876:	70e2                	ld	ra,56(sp)
 878:	7442                	ld	s0,48(sp)
 87a:	74a2                	ld	s1,40(sp)
 87c:	69e2                	ld	s3,24(sp)
 87e:	6121                	add	sp,sp,64
 880:	8082                	ret
 882:	7902                	ld	s2,32(sp)
 884:	6a42                	ld	s4,16(sp)
 886:	6aa2                	ld	s5,8(sp)
 888:	6b02                	ld	s6,0(sp)
 88a:	b7f5                	j	876 <malloc+0xea>
