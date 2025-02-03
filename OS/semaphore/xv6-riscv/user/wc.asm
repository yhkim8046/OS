
user/_wc:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <wc>:

char buf[512];

void
wc(int fd, char *name)
{
   0:	7119                	add	sp,sp,-128
   2:	fc86                	sd	ra,120(sp)
   4:	f8a2                	sd	s0,112(sp)
   6:	f4a6                	sd	s1,104(sp)
   8:	f0ca                	sd	s2,96(sp)
   a:	ecce                	sd	s3,88(sp)
   c:	e8d2                	sd	s4,80(sp)
   e:	e4d6                	sd	s5,72(sp)
  10:	e0da                	sd	s6,64(sp)
  12:	fc5e                	sd	s7,56(sp)
  14:	f862                	sd	s8,48(sp)
  16:	f466                	sd	s9,40(sp)
  18:	f06a                	sd	s10,32(sp)
  1a:	ec6e                	sd	s11,24(sp)
  1c:	0100                	add	s0,sp,128
  1e:	f8a43423          	sd	a0,-120(s0)
  22:	f8b43023          	sd	a1,-128(s0)
  int i, n;
  int l, w, c, inword;

  l = w = c = 0;
  inword = 0;
  26:	4901                	li	s2,0
  l = w = c = 0;
  28:	4d01                	li	s10,0
  2a:	4c81                	li	s9,0
  2c:	4c01                	li	s8,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  2e:	00001d97          	auipc	s11,0x1
  32:	9d2d8d93          	add	s11,s11,-1582 # a00 <buf>
    for(i=0; i<n; i++){
      c++;
      if(buf[i] == '\n')
  36:	4aa9                	li	s5,10
        l++;
      if(strchr(" \r\t\n\v", buf[i]))
  38:	00001a17          	auipc	s4,0x1
  3c:	900a0a13          	add	s4,s4,-1792 # 938 <malloc+0x104>
        inword = 0;
  40:	4b81                	li	s7,0
  while((n = read(fd, buf, sizeof(buf))) > 0){
  42:	a805                	j	72 <wc+0x72>
      if(strchr(" \r\t\n\v", buf[i]))
  44:	8552                	mv	a0,s4
  46:	00000097          	auipc	ra,0x0
  4a:	1de080e7          	jalr	478(ra) # 224 <strchr>
  4e:	c919                	beqz	a0,64 <wc+0x64>
        inword = 0;
  50:	895e                	mv	s2,s7
    for(i=0; i<n; i++){
  52:	0485                	add	s1,s1,1
  54:	01348d63          	beq	s1,s3,6e <wc+0x6e>
      if(buf[i] == '\n')
  58:	0004c583          	lbu	a1,0(s1)
  5c:	ff5594e3          	bne	a1,s5,44 <wc+0x44>
        l++;
  60:	2c05                	addw	s8,s8,1
  62:	b7cd                	j	44 <wc+0x44>
      else if(!inword){
  64:	fe0917e3          	bnez	s2,52 <wc+0x52>
        w++;
  68:	2c85                	addw	s9,s9,1
        inword = 1;
  6a:	4905                	li	s2,1
  6c:	b7dd                	j	52 <wc+0x52>
  6e:	01ab0d3b          	addw	s10,s6,s10
  while((n = read(fd, buf, sizeof(buf))) > 0){
  72:	20000613          	li	a2,512
  76:	85ee                	mv	a1,s11
  78:	f8843503          	ld	a0,-120(s0)
  7c:	00000097          	auipc	ra,0x0
  80:	398080e7          	jalr	920(ra) # 414 <read>
  84:	8b2a                	mv	s6,a0
  86:	00a05963          	blez	a0,98 <wc+0x98>
    for(i=0; i<n; i++){
  8a:	00001497          	auipc	s1,0x1
  8e:	97648493          	add	s1,s1,-1674 # a00 <buf>
  92:	009509b3          	add	s3,a0,s1
  96:	b7c9                	j	58 <wc+0x58>
      }
    }
  }
  if(n < 0){
  98:	02054e63          	bltz	a0,d4 <wc+0xd4>
    printf("wc: read error\n");
    exit(1);
  }
  printf("%d %d %d %s\n", l, w, c, name);
  9c:	f8043703          	ld	a4,-128(s0)
  a0:	86ea                	mv	a3,s10
  a2:	8666                	mv	a2,s9
  a4:	85e2                	mv	a1,s8
  a6:	00001517          	auipc	a0,0x1
  aa:	8b250513          	add	a0,a0,-1870 # 958 <malloc+0x124>
  ae:	00000097          	auipc	ra,0x0
  b2:	6ce080e7          	jalr	1742(ra) # 77c <printf>
}
  b6:	70e6                	ld	ra,120(sp)
  b8:	7446                	ld	s0,112(sp)
  ba:	74a6                	ld	s1,104(sp)
  bc:	7906                	ld	s2,96(sp)
  be:	69e6                	ld	s3,88(sp)
  c0:	6a46                	ld	s4,80(sp)
  c2:	6aa6                	ld	s5,72(sp)
  c4:	6b06                	ld	s6,64(sp)
  c6:	7be2                	ld	s7,56(sp)
  c8:	7c42                	ld	s8,48(sp)
  ca:	7ca2                	ld	s9,40(sp)
  cc:	7d02                	ld	s10,32(sp)
  ce:	6de2                	ld	s11,24(sp)
  d0:	6109                	add	sp,sp,128
  d2:	8082                	ret
    printf("wc: read error\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	87450513          	add	a0,a0,-1932 # 948 <malloc+0x114>
  dc:	00000097          	auipc	ra,0x0
  e0:	6a0080e7          	jalr	1696(ra) # 77c <printf>
    exit(1);
  e4:	4505                	li	a0,1
  e6:	00000097          	auipc	ra,0x0
  ea:	316080e7          	jalr	790(ra) # 3fc <exit>

00000000000000ee <main>:

int
main(int argc, char *argv[])
{
  ee:	7179                	add	sp,sp,-48
  f0:	f406                	sd	ra,40(sp)
  f2:	f022                	sd	s0,32(sp)
  f4:	1800                	add	s0,sp,48
  int fd, i;

  if(argc <= 1){
  f6:	4785                	li	a5,1
  f8:	04a7dc63          	bge	a5,a0,150 <main+0x62>
  fc:	ec26                	sd	s1,24(sp)
  fe:	e84a                	sd	s2,16(sp)
 100:	e44e                	sd	s3,8(sp)
 102:	00858913          	add	s2,a1,8
 106:	ffe5099b          	addw	s3,a0,-2
 10a:	02099793          	sll	a5,s3,0x20
 10e:	01d7d993          	srl	s3,a5,0x1d
 112:	05c1                	add	a1,a1,16
 114:	99ae                	add	s3,s3,a1
    wc(0, "");
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], 0)) < 0){
 116:	4581                	li	a1,0
 118:	00093503          	ld	a0,0(s2)
 11c:	00000097          	auipc	ra,0x0
 120:	320080e7          	jalr	800(ra) # 43c <open>
 124:	84aa                	mv	s1,a0
 126:	04054663          	bltz	a0,172 <main+0x84>
      printf("wc: cannot open %s\n", argv[i]);
      exit(1);
    }
    wc(fd, argv[i]);
 12a:	00093583          	ld	a1,0(s2)
 12e:	00000097          	auipc	ra,0x0
 132:	ed2080e7          	jalr	-302(ra) # 0 <wc>
    close(fd);
 136:	8526                	mv	a0,s1
 138:	00000097          	auipc	ra,0x0
 13c:	2ec080e7          	jalr	748(ra) # 424 <close>
  for(i = 1; i < argc; i++){
 140:	0921                	add	s2,s2,8
 142:	fd391ae3          	bne	s2,s3,116 <main+0x28>
  }
  exit(0);
 146:	4501                	li	a0,0
 148:	00000097          	auipc	ra,0x0
 14c:	2b4080e7          	jalr	692(ra) # 3fc <exit>
 150:	ec26                	sd	s1,24(sp)
 152:	e84a                	sd	s2,16(sp)
 154:	e44e                	sd	s3,8(sp)
    wc(0, "");
 156:	00000597          	auipc	a1,0x0
 15a:	7ea58593          	add	a1,a1,2026 # 940 <malloc+0x10c>
 15e:	4501                	li	a0,0
 160:	00000097          	auipc	ra,0x0
 164:	ea0080e7          	jalr	-352(ra) # 0 <wc>
    exit(0);
 168:	4501                	li	a0,0
 16a:	00000097          	auipc	ra,0x0
 16e:	292080e7          	jalr	658(ra) # 3fc <exit>
      printf("wc: cannot open %s\n", argv[i]);
 172:	00093583          	ld	a1,0(s2)
 176:	00000517          	auipc	a0,0x0
 17a:	7f250513          	add	a0,a0,2034 # 968 <malloc+0x134>
 17e:	00000097          	auipc	ra,0x0
 182:	5fe080e7          	jalr	1534(ra) # 77c <printf>
      exit(1);
 186:	4505                	li	a0,1
 188:	00000097          	auipc	ra,0x0
 18c:	274080e7          	jalr	628(ra) # 3fc <exit>

0000000000000190 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 190:	1141                	add	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 196:	87aa                	mv	a5,a0
 198:	0585                	add	a1,a1,1
 19a:	0785                	add	a5,a5,1
 19c:	fff5c703          	lbu	a4,-1(a1)
 1a0:	fee78fa3          	sb	a4,-1(a5)
 1a4:	fb75                	bnez	a4,198 <strcpy+0x8>
    ;
  return os;
}
 1a6:	6422                	ld	s0,8(sp)
 1a8:	0141                	add	sp,sp,16
 1aa:	8082                	ret

00000000000001ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ac:	1141                	add	sp,sp,-16
 1ae:	e422                	sd	s0,8(sp)
 1b0:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	cb91                	beqz	a5,1ca <strcmp+0x1e>
 1b8:	0005c703          	lbu	a4,0(a1)
 1bc:	00f71763          	bne	a4,a5,1ca <strcmp+0x1e>
    p++, q++;
 1c0:	0505                	add	a0,a0,1
 1c2:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 1c4:	00054783          	lbu	a5,0(a0)
 1c8:	fbe5                	bnez	a5,1b8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ca:	0005c503          	lbu	a0,0(a1)
}
 1ce:	40a7853b          	subw	a0,a5,a0
 1d2:	6422                	ld	s0,8(sp)
 1d4:	0141                	add	sp,sp,16
 1d6:	8082                	ret

00000000000001d8 <strlen>:

uint
strlen(const char *s)
{
 1d8:	1141                	add	sp,sp,-16
 1da:	e422                	sd	s0,8(sp)
 1dc:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	cf91                	beqz	a5,1fe <strlen+0x26>
 1e4:	0505                	add	a0,a0,1
 1e6:	87aa                	mv	a5,a0
 1e8:	86be                	mv	a3,a5
 1ea:	0785                	add	a5,a5,1
 1ec:	fff7c703          	lbu	a4,-1(a5)
 1f0:	ff65                	bnez	a4,1e8 <strlen+0x10>
 1f2:	40a6853b          	subw	a0,a3,a0
 1f6:	2505                	addw	a0,a0,1
    ;
  return n;
}
 1f8:	6422                	ld	s0,8(sp)
 1fa:	0141                	add	sp,sp,16
 1fc:	8082                	ret
  for(n = 0; s[n]; n++)
 1fe:	4501                	li	a0,0
 200:	bfe5                	j	1f8 <strlen+0x20>

0000000000000202 <memset>:

void*
memset(void *dst, int c, uint n)
{
 202:	1141                	add	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 208:	ca19                	beqz	a2,21e <memset+0x1c>
 20a:	87aa                	mv	a5,a0
 20c:	1602                	sll	a2,a2,0x20
 20e:	9201                	srl	a2,a2,0x20
 210:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 214:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 218:	0785                	add	a5,a5,1
 21a:	fee79de3          	bne	a5,a4,214 <memset+0x12>
  }
  return dst;
}
 21e:	6422                	ld	s0,8(sp)
 220:	0141                	add	sp,sp,16
 222:	8082                	ret

0000000000000224 <strchr>:

char*
strchr(const char *s, char c)
{
 224:	1141                	add	sp,sp,-16
 226:	e422                	sd	s0,8(sp)
 228:	0800                	add	s0,sp,16
  for(; *s; s++)
 22a:	00054783          	lbu	a5,0(a0)
 22e:	cb99                	beqz	a5,244 <strchr+0x20>
    if(*s == c)
 230:	00f58763          	beq	a1,a5,23e <strchr+0x1a>
  for(; *s; s++)
 234:	0505                	add	a0,a0,1
 236:	00054783          	lbu	a5,0(a0)
 23a:	fbfd                	bnez	a5,230 <strchr+0xc>
      return (char*)s;
  return 0;
 23c:	4501                	li	a0,0
}
 23e:	6422                	ld	s0,8(sp)
 240:	0141                	add	sp,sp,16
 242:	8082                	ret
  return 0;
 244:	4501                	li	a0,0
 246:	bfe5                	j	23e <strchr+0x1a>

0000000000000248 <gets>:

char*
gets(char *buf, int max)
{
 248:	711d                	add	sp,sp,-96
 24a:	ec86                	sd	ra,88(sp)
 24c:	e8a2                	sd	s0,80(sp)
 24e:	e4a6                	sd	s1,72(sp)
 250:	e0ca                	sd	s2,64(sp)
 252:	fc4e                	sd	s3,56(sp)
 254:	f852                	sd	s4,48(sp)
 256:	f456                	sd	s5,40(sp)
 258:	f05a                	sd	s6,32(sp)
 25a:	ec5e                	sd	s7,24(sp)
 25c:	1080                	add	s0,sp,96
 25e:	8baa                	mv	s7,a0
 260:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 262:	892a                	mv	s2,a0
 264:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 266:	4aa9                	li	s5,10
 268:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 26a:	89a6                	mv	s3,s1
 26c:	2485                	addw	s1,s1,1
 26e:	0344d863          	bge	s1,s4,29e <gets+0x56>
    cc = read(0, &c, 1);
 272:	4605                	li	a2,1
 274:	faf40593          	add	a1,s0,-81
 278:	4501                	li	a0,0
 27a:	00000097          	auipc	ra,0x0
 27e:	19a080e7          	jalr	410(ra) # 414 <read>
    if(cc < 1)
 282:	00a05e63          	blez	a0,29e <gets+0x56>
    buf[i++] = c;
 286:	faf44783          	lbu	a5,-81(s0)
 28a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 28e:	01578763          	beq	a5,s5,29c <gets+0x54>
 292:	0905                	add	s2,s2,1
 294:	fd679be3          	bne	a5,s6,26a <gets+0x22>
    buf[i++] = c;
 298:	89a6                	mv	s3,s1
 29a:	a011                	j	29e <gets+0x56>
 29c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 29e:	99de                	add	s3,s3,s7
 2a0:	00098023          	sb	zero,0(s3)
  return buf;
}
 2a4:	855e                	mv	a0,s7
 2a6:	60e6                	ld	ra,88(sp)
 2a8:	6446                	ld	s0,80(sp)
 2aa:	64a6                	ld	s1,72(sp)
 2ac:	6906                	ld	s2,64(sp)
 2ae:	79e2                	ld	s3,56(sp)
 2b0:	7a42                	ld	s4,48(sp)
 2b2:	7aa2                	ld	s5,40(sp)
 2b4:	7b02                	ld	s6,32(sp)
 2b6:	6be2                	ld	s7,24(sp)
 2b8:	6125                	add	sp,sp,96
 2ba:	8082                	ret

00000000000002bc <stat>:

int
stat(const char *n, struct stat *st)
{
 2bc:	1101                	add	sp,sp,-32
 2be:	ec06                	sd	ra,24(sp)
 2c0:	e822                	sd	s0,16(sp)
 2c2:	e04a                	sd	s2,0(sp)
 2c4:	1000                	add	s0,sp,32
 2c6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2c8:	4581                	li	a1,0
 2ca:	00000097          	auipc	ra,0x0
 2ce:	172080e7          	jalr	370(ra) # 43c <open>
  if(fd < 0)
 2d2:	02054663          	bltz	a0,2fe <stat+0x42>
 2d6:	e426                	sd	s1,8(sp)
 2d8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2da:	85ca                	mv	a1,s2
 2dc:	00000097          	auipc	ra,0x0
 2e0:	178080e7          	jalr	376(ra) # 454 <fstat>
 2e4:	892a                	mv	s2,a0
  close(fd);
 2e6:	8526                	mv	a0,s1
 2e8:	00000097          	auipc	ra,0x0
 2ec:	13c080e7          	jalr	316(ra) # 424 <close>
  return r;
 2f0:	64a2                	ld	s1,8(sp)
}
 2f2:	854a                	mv	a0,s2
 2f4:	60e2                	ld	ra,24(sp)
 2f6:	6442                	ld	s0,16(sp)
 2f8:	6902                	ld	s2,0(sp)
 2fa:	6105                	add	sp,sp,32
 2fc:	8082                	ret
    return -1;
 2fe:	597d                	li	s2,-1
 300:	bfcd                	j	2f2 <stat+0x36>

0000000000000302 <atoi>:

int
atoi(const char *s)
{
 302:	1141                	add	sp,sp,-16
 304:	e422                	sd	s0,8(sp)
 306:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 308:	00054683          	lbu	a3,0(a0)
 30c:	fd06879b          	addw	a5,a3,-48
 310:	0ff7f793          	zext.b	a5,a5
 314:	4625                	li	a2,9
 316:	02f66863          	bltu	a2,a5,346 <atoi+0x44>
 31a:	872a                	mv	a4,a0
  n = 0;
 31c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 31e:	0705                	add	a4,a4,1
 320:	0025179b          	sllw	a5,a0,0x2
 324:	9fa9                	addw	a5,a5,a0
 326:	0017979b          	sllw	a5,a5,0x1
 32a:	9fb5                	addw	a5,a5,a3
 32c:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 330:	00074683          	lbu	a3,0(a4)
 334:	fd06879b          	addw	a5,a3,-48
 338:	0ff7f793          	zext.b	a5,a5
 33c:	fef671e3          	bgeu	a2,a5,31e <atoi+0x1c>
  return n;
}
 340:	6422                	ld	s0,8(sp)
 342:	0141                	add	sp,sp,16
 344:	8082                	ret
  n = 0;
 346:	4501                	li	a0,0
 348:	bfe5                	j	340 <atoi+0x3e>

000000000000034a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 34a:	1141                	add	sp,sp,-16
 34c:	e422                	sd	s0,8(sp)
 34e:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 350:	02b57463          	bgeu	a0,a1,378 <memmove+0x2e>
    while(n-- > 0)
 354:	00c05f63          	blez	a2,372 <memmove+0x28>
 358:	1602                	sll	a2,a2,0x20
 35a:	9201                	srl	a2,a2,0x20
 35c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 360:	872a                	mv	a4,a0
      *dst++ = *src++;
 362:	0585                	add	a1,a1,1
 364:	0705                	add	a4,a4,1
 366:	fff5c683          	lbu	a3,-1(a1)
 36a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 36e:	fef71ae3          	bne	a4,a5,362 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 372:	6422                	ld	s0,8(sp)
 374:	0141                	add	sp,sp,16
 376:	8082                	ret
    dst += n;
 378:	00c50733          	add	a4,a0,a2
    src += n;
 37c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 37e:	fec05ae3          	blez	a2,372 <memmove+0x28>
 382:	fff6079b          	addw	a5,a2,-1
 386:	1782                	sll	a5,a5,0x20
 388:	9381                	srl	a5,a5,0x20
 38a:	fff7c793          	not	a5,a5
 38e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 390:	15fd                	add	a1,a1,-1
 392:	177d                	add	a4,a4,-1
 394:	0005c683          	lbu	a3,0(a1)
 398:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 39c:	fee79ae3          	bne	a5,a4,390 <memmove+0x46>
 3a0:	bfc9                	j	372 <memmove+0x28>

00000000000003a2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3a2:	1141                	add	sp,sp,-16
 3a4:	e422                	sd	s0,8(sp)
 3a6:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3a8:	ca05                	beqz	a2,3d8 <memcmp+0x36>
 3aa:	fff6069b          	addw	a3,a2,-1
 3ae:	1682                	sll	a3,a3,0x20
 3b0:	9281                	srl	a3,a3,0x20
 3b2:	0685                	add	a3,a3,1
 3b4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3b6:	00054783          	lbu	a5,0(a0)
 3ba:	0005c703          	lbu	a4,0(a1)
 3be:	00e79863          	bne	a5,a4,3ce <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3c2:	0505                	add	a0,a0,1
    p2++;
 3c4:	0585                	add	a1,a1,1
  while (n-- > 0) {
 3c6:	fed518e3          	bne	a0,a3,3b6 <memcmp+0x14>
  }
  return 0;
 3ca:	4501                	li	a0,0
 3cc:	a019                	j	3d2 <memcmp+0x30>
      return *p1 - *p2;
 3ce:	40e7853b          	subw	a0,a5,a4
}
 3d2:	6422                	ld	s0,8(sp)
 3d4:	0141                	add	sp,sp,16
 3d6:	8082                	ret
  return 0;
 3d8:	4501                	li	a0,0
 3da:	bfe5                	j	3d2 <memcmp+0x30>

00000000000003dc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3dc:	1141                	add	sp,sp,-16
 3de:	e406                	sd	ra,8(sp)
 3e0:	e022                	sd	s0,0(sp)
 3e2:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 3e4:	00000097          	auipc	ra,0x0
 3e8:	f66080e7          	jalr	-154(ra) # 34a <memmove>
}
 3ec:	60a2                	ld	ra,8(sp)
 3ee:	6402                	ld	s0,0(sp)
 3f0:	0141                	add	sp,sp,16
 3f2:	8082                	ret

00000000000003f4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3f4:	4885                	li	a7,1
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3fc:	4889                	li	a7,2
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <wait>:
.global wait
wait:
 li a7, SYS_wait
 404:	488d                	li	a7,3
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 40c:	4891                	li	a7,4
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <read>:
.global read
read:
 li a7, SYS_read
 414:	4895                	li	a7,5
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <write>:
.global write
write:
 li a7, SYS_write
 41c:	48c1                	li	a7,16
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <close>:
.global close
close:
 li a7, SYS_close
 424:	48d5                	li	a7,21
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <kill>:
.global kill
kill:
 li a7, SYS_kill
 42c:	4899                	li	a7,6
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <exec>:
.global exec
exec:
 li a7, SYS_exec
 434:	489d                	li	a7,7
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <open>:
.global open
open:
 li a7, SYS_open
 43c:	48bd                	li	a7,15
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 444:	48c5                	li	a7,17
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 44c:	48c9                	li	a7,18
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 454:	48a1                	li	a7,8
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <link>:
.global link
link:
 li a7, SYS_link
 45c:	48cd                	li	a7,19
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 464:	48d1                	li	a7,20
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 46c:	48a5                	li	a7,9
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <dup>:
.global dup
dup:
 li a7, SYS_dup
 474:	48a9                	li	a7,10
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 47c:	48ad                	li	a7,11
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 484:	48b1                	li	a7,12
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 48c:	48b5                	li	a7,13
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 494:	48b9                	li	a7,14
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 49c:	48d9                	li	a7,22
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <sematest>:
.global sematest
sematest:
 li a7, SYS_sematest
 4a4:	48dd                	li	a7,23
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <rwsematest>:
.global rwsematest
rwsematest:
 li a7, SYS_rwsematest
 4ac:	48e1                	li	a7,24
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4b4:	1101                	add	sp,sp,-32
 4b6:	ec06                	sd	ra,24(sp)
 4b8:	e822                	sd	s0,16(sp)
 4ba:	1000                	add	s0,sp,32
 4bc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c0:	4605                	li	a2,1
 4c2:	fef40593          	add	a1,s0,-17
 4c6:	00000097          	auipc	ra,0x0
 4ca:	f56080e7          	jalr	-170(ra) # 41c <write>
}
 4ce:	60e2                	ld	ra,24(sp)
 4d0:	6442                	ld	s0,16(sp)
 4d2:	6105                	add	sp,sp,32
 4d4:	8082                	ret

00000000000004d6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4d6:	7139                	add	sp,sp,-64
 4d8:	fc06                	sd	ra,56(sp)
 4da:	f822                	sd	s0,48(sp)
 4dc:	f426                	sd	s1,40(sp)
 4de:	0080                	add	s0,sp,64
 4e0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e2:	c299                	beqz	a3,4e8 <printint+0x12>
 4e4:	0805cb63          	bltz	a1,57a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4e8:	2581                	sext.w	a1,a1
  neg = 0;
 4ea:	4881                	li	a7,0
 4ec:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 4f0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f2:	2601                	sext.w	a2,a2
 4f4:	00000517          	auipc	a0,0x0
 4f8:	4ec50513          	add	a0,a0,1260 # 9e0 <digits>
 4fc:	883a                	mv	a6,a4
 4fe:	2705                	addw	a4,a4,1
 500:	02c5f7bb          	remuw	a5,a1,a2
 504:	1782                	sll	a5,a5,0x20
 506:	9381                	srl	a5,a5,0x20
 508:	97aa                	add	a5,a5,a0
 50a:	0007c783          	lbu	a5,0(a5)
 50e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 512:	0005879b          	sext.w	a5,a1
 516:	02c5d5bb          	divuw	a1,a1,a2
 51a:	0685                	add	a3,a3,1
 51c:	fec7f0e3          	bgeu	a5,a2,4fc <printint+0x26>
  if(neg)
 520:	00088c63          	beqz	a7,538 <printint+0x62>
    buf[i++] = '-';
 524:	fd070793          	add	a5,a4,-48
 528:	00878733          	add	a4,a5,s0
 52c:	02d00793          	li	a5,45
 530:	fef70823          	sb	a5,-16(a4)
 534:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 538:	02e05c63          	blez	a4,570 <printint+0x9a>
 53c:	f04a                	sd	s2,32(sp)
 53e:	ec4e                	sd	s3,24(sp)
 540:	fc040793          	add	a5,s0,-64
 544:	00e78933          	add	s2,a5,a4
 548:	fff78993          	add	s3,a5,-1
 54c:	99ba                	add	s3,s3,a4
 54e:	377d                	addw	a4,a4,-1
 550:	1702                	sll	a4,a4,0x20
 552:	9301                	srl	a4,a4,0x20
 554:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 558:	fff94583          	lbu	a1,-1(s2)
 55c:	8526                	mv	a0,s1
 55e:	00000097          	auipc	ra,0x0
 562:	f56080e7          	jalr	-170(ra) # 4b4 <putc>
  while(--i >= 0)
 566:	197d                	add	s2,s2,-1
 568:	ff3918e3          	bne	s2,s3,558 <printint+0x82>
 56c:	7902                	ld	s2,32(sp)
 56e:	69e2                	ld	s3,24(sp)
}
 570:	70e2                	ld	ra,56(sp)
 572:	7442                	ld	s0,48(sp)
 574:	74a2                	ld	s1,40(sp)
 576:	6121                	add	sp,sp,64
 578:	8082                	ret
    x = -xx;
 57a:	40b005bb          	negw	a1,a1
    neg = 1;
 57e:	4885                	li	a7,1
    x = -xx;
 580:	b7b5                	j	4ec <printint+0x16>

0000000000000582 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 582:	715d                	add	sp,sp,-80
 584:	e486                	sd	ra,72(sp)
 586:	e0a2                	sd	s0,64(sp)
 588:	f84a                	sd	s2,48(sp)
 58a:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 58c:	0005c903          	lbu	s2,0(a1)
 590:	1a090a63          	beqz	s2,744 <vprintf+0x1c2>
 594:	fc26                	sd	s1,56(sp)
 596:	f44e                	sd	s3,40(sp)
 598:	f052                	sd	s4,32(sp)
 59a:	ec56                	sd	s5,24(sp)
 59c:	e85a                	sd	s6,16(sp)
 59e:	e45e                	sd	s7,8(sp)
 5a0:	8aaa                	mv	s5,a0
 5a2:	8bb2                	mv	s7,a2
 5a4:	00158493          	add	s1,a1,1
  state = 0;
 5a8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5aa:	02500a13          	li	s4,37
 5ae:	4b55                	li	s6,21
 5b0:	a839                	j	5ce <vprintf+0x4c>
        putc(fd, c);
 5b2:	85ca                	mv	a1,s2
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	efe080e7          	jalr	-258(ra) # 4b4 <putc>
 5be:	a019                	j	5c4 <vprintf+0x42>
    } else if(state == '%'){
 5c0:	01498d63          	beq	s3,s4,5da <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 5c4:	0485                	add	s1,s1,1
 5c6:	fff4c903          	lbu	s2,-1(s1)
 5ca:	16090763          	beqz	s2,738 <vprintf+0x1b6>
    if(state == 0){
 5ce:	fe0999e3          	bnez	s3,5c0 <vprintf+0x3e>
      if(c == '%'){
 5d2:	ff4910e3          	bne	s2,s4,5b2 <vprintf+0x30>
        state = '%';
 5d6:	89d2                	mv	s3,s4
 5d8:	b7f5                	j	5c4 <vprintf+0x42>
      if(c == 'd'){
 5da:	13490463          	beq	s2,s4,702 <vprintf+0x180>
 5de:	f9d9079b          	addw	a5,s2,-99
 5e2:	0ff7f793          	zext.b	a5,a5
 5e6:	12fb6763          	bltu	s6,a5,714 <vprintf+0x192>
 5ea:	f9d9079b          	addw	a5,s2,-99
 5ee:	0ff7f713          	zext.b	a4,a5
 5f2:	12eb6163          	bltu	s6,a4,714 <vprintf+0x192>
 5f6:	00271793          	sll	a5,a4,0x2
 5fa:	00000717          	auipc	a4,0x0
 5fe:	38e70713          	add	a4,a4,910 # 988 <malloc+0x154>
 602:	97ba                	add	a5,a5,a4
 604:	439c                	lw	a5,0(a5)
 606:	97ba                	add	a5,a5,a4
 608:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 60a:	008b8913          	add	s2,s7,8
 60e:	4685                	li	a3,1
 610:	4629                	li	a2,10
 612:	000ba583          	lw	a1,0(s7)
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	ebe080e7          	jalr	-322(ra) # 4d6 <printint>
 620:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 622:	4981                	li	s3,0
 624:	b745                	j	5c4 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 626:	008b8913          	add	s2,s7,8
 62a:	4681                	li	a3,0
 62c:	4629                	li	a2,10
 62e:	000ba583          	lw	a1,0(s7)
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	ea2080e7          	jalr	-350(ra) # 4d6 <printint>
 63c:	8bca                	mv	s7,s2
      state = 0;
 63e:	4981                	li	s3,0
 640:	b751                	j	5c4 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 642:	008b8913          	add	s2,s7,8
 646:	4681                	li	a3,0
 648:	4641                	li	a2,16
 64a:	000ba583          	lw	a1,0(s7)
 64e:	8556                	mv	a0,s5
 650:	00000097          	auipc	ra,0x0
 654:	e86080e7          	jalr	-378(ra) # 4d6 <printint>
 658:	8bca                	mv	s7,s2
      state = 0;
 65a:	4981                	li	s3,0
 65c:	b7a5                	j	5c4 <vprintf+0x42>
 65e:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 660:	008b8c13          	add	s8,s7,8
 664:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 668:	03000593          	li	a1,48
 66c:	8556                	mv	a0,s5
 66e:	00000097          	auipc	ra,0x0
 672:	e46080e7          	jalr	-442(ra) # 4b4 <putc>
  putc(fd, 'x');
 676:	07800593          	li	a1,120
 67a:	8556                	mv	a0,s5
 67c:	00000097          	auipc	ra,0x0
 680:	e38080e7          	jalr	-456(ra) # 4b4 <putc>
 684:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 686:	00000b97          	auipc	s7,0x0
 68a:	35ab8b93          	add	s7,s7,858 # 9e0 <digits>
 68e:	03c9d793          	srl	a5,s3,0x3c
 692:	97de                	add	a5,a5,s7
 694:	0007c583          	lbu	a1,0(a5)
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	e1a080e7          	jalr	-486(ra) # 4b4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a2:	0992                	sll	s3,s3,0x4
 6a4:	397d                	addw	s2,s2,-1
 6a6:	fe0914e3          	bnez	s2,68e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6aa:	8be2                	mv	s7,s8
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	6c02                	ld	s8,0(sp)
 6b0:	bf11                	j	5c4 <vprintf+0x42>
        s = va_arg(ap, char*);
 6b2:	008b8993          	add	s3,s7,8
 6b6:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6ba:	02090163          	beqz	s2,6dc <vprintf+0x15a>
        while(*s != 0){
 6be:	00094583          	lbu	a1,0(s2)
 6c2:	c9a5                	beqz	a1,732 <vprintf+0x1b0>
          putc(fd, *s);
 6c4:	8556                	mv	a0,s5
 6c6:	00000097          	auipc	ra,0x0
 6ca:	dee080e7          	jalr	-530(ra) # 4b4 <putc>
          s++;
 6ce:	0905                	add	s2,s2,1
        while(*s != 0){
 6d0:	00094583          	lbu	a1,0(s2)
 6d4:	f9e5                	bnez	a1,6c4 <vprintf+0x142>
        s = va_arg(ap, char*);
 6d6:	8bce                	mv	s7,s3
      state = 0;
 6d8:	4981                	li	s3,0
 6da:	b5ed                	j	5c4 <vprintf+0x42>
          s = "(null)";
 6dc:	00000917          	auipc	s2,0x0
 6e0:	2a490913          	add	s2,s2,676 # 980 <malloc+0x14c>
        while(*s != 0){
 6e4:	02800593          	li	a1,40
 6e8:	bff1                	j	6c4 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 6ea:	008b8913          	add	s2,s7,8
 6ee:	000bc583          	lbu	a1,0(s7)
 6f2:	8556                	mv	a0,s5
 6f4:	00000097          	auipc	ra,0x0
 6f8:	dc0080e7          	jalr	-576(ra) # 4b4 <putc>
 6fc:	8bca                	mv	s7,s2
      state = 0;
 6fe:	4981                	li	s3,0
 700:	b5d1                	j	5c4 <vprintf+0x42>
        putc(fd, c);
 702:	02500593          	li	a1,37
 706:	8556                	mv	a0,s5
 708:	00000097          	auipc	ra,0x0
 70c:	dac080e7          	jalr	-596(ra) # 4b4 <putc>
      state = 0;
 710:	4981                	li	s3,0
 712:	bd4d                	j	5c4 <vprintf+0x42>
        putc(fd, '%');
 714:	02500593          	li	a1,37
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	d9a080e7          	jalr	-614(ra) # 4b4 <putc>
        putc(fd, c);
 722:	85ca                	mv	a1,s2
 724:	8556                	mv	a0,s5
 726:	00000097          	auipc	ra,0x0
 72a:	d8e080e7          	jalr	-626(ra) # 4b4 <putc>
      state = 0;
 72e:	4981                	li	s3,0
 730:	bd51                	j	5c4 <vprintf+0x42>
        s = va_arg(ap, char*);
 732:	8bce                	mv	s7,s3
      state = 0;
 734:	4981                	li	s3,0
 736:	b579                	j	5c4 <vprintf+0x42>
 738:	74e2                	ld	s1,56(sp)
 73a:	79a2                	ld	s3,40(sp)
 73c:	7a02                	ld	s4,32(sp)
 73e:	6ae2                	ld	s5,24(sp)
 740:	6b42                	ld	s6,16(sp)
 742:	6ba2                	ld	s7,8(sp)
    }
  }
}
 744:	60a6                	ld	ra,72(sp)
 746:	6406                	ld	s0,64(sp)
 748:	7942                	ld	s2,48(sp)
 74a:	6161                	add	sp,sp,80
 74c:	8082                	ret

000000000000074e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 74e:	715d                	add	sp,sp,-80
 750:	ec06                	sd	ra,24(sp)
 752:	e822                	sd	s0,16(sp)
 754:	1000                	add	s0,sp,32
 756:	e010                	sd	a2,0(s0)
 758:	e414                	sd	a3,8(s0)
 75a:	e818                	sd	a4,16(s0)
 75c:	ec1c                	sd	a5,24(s0)
 75e:	03043023          	sd	a6,32(s0)
 762:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 766:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 76a:	8622                	mv	a2,s0
 76c:	00000097          	auipc	ra,0x0
 770:	e16080e7          	jalr	-490(ra) # 582 <vprintf>
}
 774:	60e2                	ld	ra,24(sp)
 776:	6442                	ld	s0,16(sp)
 778:	6161                	add	sp,sp,80
 77a:	8082                	ret

000000000000077c <printf>:

void
printf(const char *fmt, ...)
{
 77c:	711d                	add	sp,sp,-96
 77e:	ec06                	sd	ra,24(sp)
 780:	e822                	sd	s0,16(sp)
 782:	1000                	add	s0,sp,32
 784:	e40c                	sd	a1,8(s0)
 786:	e810                	sd	a2,16(s0)
 788:	ec14                	sd	a3,24(s0)
 78a:	f018                	sd	a4,32(s0)
 78c:	f41c                	sd	a5,40(s0)
 78e:	03043823          	sd	a6,48(s0)
 792:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 796:	00840613          	add	a2,s0,8
 79a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 79e:	85aa                	mv	a1,a0
 7a0:	4505                	li	a0,1
 7a2:	00000097          	auipc	ra,0x0
 7a6:	de0080e7          	jalr	-544(ra) # 582 <vprintf>
}
 7aa:	60e2                	ld	ra,24(sp)
 7ac:	6442                	ld	s0,16(sp)
 7ae:	6125                	add	sp,sp,96
 7b0:	8082                	ret

00000000000007b2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b2:	1141                	add	sp,sp,-16
 7b4:	e422                	sd	s0,8(sp)
 7b6:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b8:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7bc:	00000797          	auipc	a5,0x0
 7c0:	23c7b783          	ld	a5,572(a5) # 9f8 <freep>
 7c4:	a02d                	j	7ee <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7c6:	4618                	lw	a4,8(a2)
 7c8:	9f2d                	addw	a4,a4,a1
 7ca:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ce:	6398                	ld	a4,0(a5)
 7d0:	6310                	ld	a2,0(a4)
 7d2:	a83d                	j	810 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7d4:	ff852703          	lw	a4,-8(a0)
 7d8:	9f31                	addw	a4,a4,a2
 7da:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7dc:	ff053683          	ld	a3,-16(a0)
 7e0:	a091                	j	824 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e2:	6398                	ld	a4,0(a5)
 7e4:	00e7e463          	bltu	a5,a4,7ec <free+0x3a>
 7e8:	00e6ea63          	bltu	a3,a4,7fc <free+0x4a>
{
 7ec:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ee:	fed7fae3          	bgeu	a5,a3,7e2 <free+0x30>
 7f2:	6398                	ld	a4,0(a5)
 7f4:	00e6e463          	bltu	a3,a4,7fc <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f8:	fee7eae3          	bltu	a5,a4,7ec <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7fc:	ff852583          	lw	a1,-8(a0)
 800:	6390                	ld	a2,0(a5)
 802:	02059813          	sll	a6,a1,0x20
 806:	01c85713          	srl	a4,a6,0x1c
 80a:	9736                	add	a4,a4,a3
 80c:	fae60de3          	beq	a2,a4,7c6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 810:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 814:	4790                	lw	a2,8(a5)
 816:	02061593          	sll	a1,a2,0x20
 81a:	01c5d713          	srl	a4,a1,0x1c
 81e:	973e                	add	a4,a4,a5
 820:	fae68ae3          	beq	a3,a4,7d4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 824:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 826:	00000717          	auipc	a4,0x0
 82a:	1cf73923          	sd	a5,466(a4) # 9f8 <freep>
}
 82e:	6422                	ld	s0,8(sp)
 830:	0141                	add	sp,sp,16
 832:	8082                	ret

0000000000000834 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 834:	7139                	add	sp,sp,-64
 836:	fc06                	sd	ra,56(sp)
 838:	f822                	sd	s0,48(sp)
 83a:	f426                	sd	s1,40(sp)
 83c:	ec4e                	sd	s3,24(sp)
 83e:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 840:	02051493          	sll	s1,a0,0x20
 844:	9081                	srl	s1,s1,0x20
 846:	04bd                	add	s1,s1,15
 848:	8091                	srl	s1,s1,0x4
 84a:	0014899b          	addw	s3,s1,1
 84e:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 850:	00000517          	auipc	a0,0x0
 854:	1a853503          	ld	a0,424(a0) # 9f8 <freep>
 858:	c915                	beqz	a0,88c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85c:	4798                	lw	a4,8(a5)
 85e:	08977e63          	bgeu	a4,s1,8fa <malloc+0xc6>
 862:	f04a                	sd	s2,32(sp)
 864:	e852                	sd	s4,16(sp)
 866:	e456                	sd	s5,8(sp)
 868:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 86a:	8a4e                	mv	s4,s3
 86c:	0009871b          	sext.w	a4,s3
 870:	6685                	lui	a3,0x1
 872:	00d77363          	bgeu	a4,a3,878 <malloc+0x44>
 876:	6a05                	lui	s4,0x1
 878:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 87c:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 880:	00000917          	auipc	s2,0x0
 884:	17890913          	add	s2,s2,376 # 9f8 <freep>
  if(p == (char*)-1)
 888:	5afd                	li	s5,-1
 88a:	a091                	j	8ce <malloc+0x9a>
 88c:	f04a                	sd	s2,32(sp)
 88e:	e852                	sd	s4,16(sp)
 890:	e456                	sd	s5,8(sp)
 892:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 894:	00000797          	auipc	a5,0x0
 898:	36c78793          	add	a5,a5,876 # c00 <base>
 89c:	00000717          	auipc	a4,0x0
 8a0:	14f73e23          	sd	a5,348(a4) # 9f8 <freep>
 8a4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8a6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8aa:	b7c1                	j	86a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8ac:	6398                	ld	a4,0(a5)
 8ae:	e118                	sd	a4,0(a0)
 8b0:	a08d                	j	912 <malloc+0xde>
  hp->s.size = nu;
 8b2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8b6:	0541                	add	a0,a0,16
 8b8:	00000097          	auipc	ra,0x0
 8bc:	efa080e7          	jalr	-262(ra) # 7b2 <free>
  return freep;
 8c0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8c4:	c13d                	beqz	a0,92a <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c8:	4798                	lw	a4,8(a5)
 8ca:	02977463          	bgeu	a4,s1,8f2 <malloc+0xbe>
    if(p == freep)
 8ce:	00093703          	ld	a4,0(s2)
 8d2:	853e                	mv	a0,a5
 8d4:	fef719e3          	bne	a4,a5,8c6 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 8d8:	8552                	mv	a0,s4
 8da:	00000097          	auipc	ra,0x0
 8de:	baa080e7          	jalr	-1110(ra) # 484 <sbrk>
  if(p == (char*)-1)
 8e2:	fd5518e3          	bne	a0,s5,8b2 <malloc+0x7e>
        return 0;
 8e6:	4501                	li	a0,0
 8e8:	7902                	ld	s2,32(sp)
 8ea:	6a42                	ld	s4,16(sp)
 8ec:	6aa2                	ld	s5,8(sp)
 8ee:	6b02                	ld	s6,0(sp)
 8f0:	a03d                	j	91e <malloc+0xea>
 8f2:	7902                	ld	s2,32(sp)
 8f4:	6a42                	ld	s4,16(sp)
 8f6:	6aa2                	ld	s5,8(sp)
 8f8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8fa:	fae489e3          	beq	s1,a4,8ac <malloc+0x78>
        p->s.size -= nunits;
 8fe:	4137073b          	subw	a4,a4,s3
 902:	c798                	sw	a4,8(a5)
        p += p->s.size;
 904:	02071693          	sll	a3,a4,0x20
 908:	01c6d713          	srl	a4,a3,0x1c
 90c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 90e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 912:	00000717          	auipc	a4,0x0
 916:	0ea73323          	sd	a0,230(a4) # 9f8 <freep>
      return (void*)(p + 1);
 91a:	01078513          	add	a0,a5,16
  }
}
 91e:	70e2                	ld	ra,56(sp)
 920:	7442                	ld	s0,48(sp)
 922:	74a2                	ld	s1,40(sp)
 924:	69e2                	ld	s3,24(sp)
 926:	6121                	add	sp,sp,64
 928:	8082                	ret
 92a:	7902                	ld	s2,32(sp)
 92c:	6a42                	ld	s4,16(sp)
 92e:	6aa2                	ld	s5,8(sp)
 930:	6b02                	ld	s6,0(sp)
 932:	b7f5                	j	91e <malloc+0xea>
