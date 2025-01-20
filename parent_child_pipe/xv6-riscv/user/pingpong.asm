
user/_pingpong:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
   0:	7179                	add	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	add	s0,sp,48
    int p[2]; // file descriptors: 0 = reading, 1 = writing
    int r;
    int x; //for integer

    // single pipe created
    pipe(p);
   8:	fd840513          	add	a0,s0,-40
   c:	00000097          	auipc	ra,0x0
  10:	3f0080e7          	jalr	1008(ra) # 3fc <pipe>

    // fork the child process
    r = fork();
  14:	00000097          	auipc	ra,0x0
  18:	3d0080e7          	jalr	976(ra) # 3e4 <fork>
  
    if(r < 0){
  1c:	02054e63          	bltz	a0,58 <main+0x58>
        // fork failed
        fprintf(2, "fork error\n");
        exit(1);
    } else if(r == 0){
  20:	e161                	bnez	a0,e0 <main+0xe0>
        // child

        // get integer from parent
        if(read(p[0], &x, sizeof(int)) != sizeof(int)){
  22:	4611                	li	a2,4
  24:	fd440593          	add	a1,s0,-44
  28:	fd842503          	lw	a0,-40(s0)
  2c:	00000097          	auipc	ra,0x0
  30:	3d8080e7          	jalr	984(ra) # 404 <read>
  34:	4791                	li	a5,4
  36:	04f50063          	beq	a0,a5,76 <main+0x76>
  3a:	ec26                	sd	s1,24(sp)
            fprintf(2, "child read error\n");
  3c:	00001597          	auipc	a1,0x1
  40:	8e458593          	add	a1,a1,-1820 # 920 <malloc+0x114>
  44:	4509                	li	a0,2
  46:	00000097          	auipc	ra,0x0
  4a:	6e0080e7          	jalr	1760(ra) # 726 <fprintf>
            exit(1);
  4e:	4505                	li	a0,1
  50:	00000097          	auipc	ra,0x0
  54:	39c080e7          	jalr	924(ra) # 3ec <exit>
  58:	ec26                	sd	s1,24(sp)
        fprintf(2, "fork error\n");
  5a:	00001597          	auipc	a1,0x1
  5e:	8b658593          	add	a1,a1,-1866 # 910 <malloc+0x104>
  62:	4509                	li	a0,2
  64:	00000097          	auipc	ra,0x0
  68:	6c2080e7          	jalr	1730(ra) # 726 <fprintf>
        exit(1);
  6c:	4505                	li	a0,1
  6e:	00000097          	auipc	ra,0x0
  72:	37e080e7          	jalr	894(ra) # 3ec <exit>
  76:	ec26                	sd	s1,24(sp)
        }

        printf("%d Integer from parent = %d\n", getpid(), x);
  78:	00000097          	auipc	ra,0x0
  7c:	3f4080e7          	jalr	1012(ra) # 46c <getpid>
  80:	85aa                	mv	a1,a0
  82:	fd442603          	lw	a2,-44(s0)
  86:	00001517          	auipc	a0,0x1
  8a:	8b250513          	add	a0,a0,-1870 # 938 <malloc+0x12c>
  8e:	00000097          	auipc	ra,0x0
  92:	6c6080e7          	jalr	1734(ra) # 754 <printf>

        // multiply the integer by 4
        x *= 4;
  96:	fd442783          	lw	a5,-44(s0)
  9a:	0027979b          	sllw	a5,a5,0x2
  9e:	fcf42a23          	sw	a5,-44(s0)
        
        // write the result and send it back to the parent
        if(write(p[1], &x, sizeof(int)) != sizeof(int)){
  a2:	4611                	li	a2,4
  a4:	fd440593          	add	a1,s0,-44
  a8:	fdc42503          	lw	a0,-36(s0)
  ac:	00000097          	auipc	ra,0x0
  b0:	360080e7          	jalr	864(ra) # 40c <write>
  b4:	4791                	li	a5,4
  b6:	02f50063          	beq	a0,a5,d6 <main+0xd6>
            fprintf(2, "child write error\n");
  ba:	00001597          	auipc	a1,0x1
  be:	89e58593          	add	a1,a1,-1890 # 958 <malloc+0x14c>
  c2:	4509                	li	a0,2
  c4:	00000097          	auipc	ra,0x0
  c8:	662080e7          	jalr	1634(ra) # 726 <fprintf>
            exit(1);
  cc:	4505                	li	a0,1
  ce:	00000097          	auipc	ra,0x0
  d2:	31e080e7          	jalr	798(ra) # 3ec <exit>
        }

        exit(0);
  d6:	4501                	li	a0,0
  d8:	00000097          	auipc	ra,0x0
  dc:	314080e7          	jalr	788(ra) # 3ec <exit>
  e0:	ec26                	sd	s1,24(sp)

    } else {
        // parent

        x = 4; //variable init
  e2:	4491                	li	s1,4
  e4:	fc942a23          	sw	s1,-44(s0)

        // write the integer and send it to the child
        if(write(p[1], &x, sizeof(int)) != sizeof(int)){
  e8:	4611                	li	a2,4
  ea:	fd440593          	add	a1,s0,-44
  ee:	fdc42503          	lw	a0,-36(s0)
  f2:	00000097          	auipc	ra,0x0
  f6:	31a080e7          	jalr	794(ra) # 40c <write>
  fa:	02950063          	beq	a0,s1,11a <main+0x11a>
            fprintf(2, "parent write error\n");
  fe:	00001597          	auipc	a1,0x1
 102:	87258593          	add	a1,a1,-1934 # 970 <malloc+0x164>
 106:	4509                	li	a0,2
 108:	00000097          	auipc	ra,0x0
 10c:	61e080e7          	jalr	1566(ra) # 726 <fprintf>
            exit(1);
 110:	4505                	li	a0,1
 112:	00000097          	auipc	ra,0x0
 116:	2da080e7          	jalr	730(ra) # 3ec <exit>
        }

        // get the modified integer sent back
        if(read(p[0], &x, sizeof(int)) != sizeof(int)){
 11a:	4611                	li	a2,4
 11c:	fd440593          	add	a1,s0,-44
 120:	fd842503          	lw	a0,-40(s0)
 124:	00000097          	auipc	ra,0x0
 128:	2e0080e7          	jalr	736(ra) # 404 <read>
 12c:	4791                	li	a5,4
 12e:	02f50063          	beq	a0,a5,14e <main+0x14e>
            fprintf(2, "parent read error\n");
 132:	00001597          	auipc	a1,0x1
 136:	85658593          	add	a1,a1,-1962 # 988 <malloc+0x17c>
 13a:	4509                	li	a0,2
 13c:	00000097          	auipc	ra,0x0
 140:	5ea080e7          	jalr	1514(ra) # 726 <fprintf>
            exit(1);
 144:	4505                	li	a0,1
 146:	00000097          	auipc	ra,0x0
 14a:	2a6080e7          	jalr	678(ra) # 3ec <exit>
        }

        // print parent and the integer
        printf("%d Integer from child = %d\n", getpid(), x);
 14e:	00000097          	auipc	ra,0x0
 152:	31e080e7          	jalr	798(ra) # 46c <getpid>
 156:	85aa                	mv	a1,a0
 158:	fd442603          	lw	a2,-44(s0)
 15c:	00001517          	auipc	a0,0x1
 160:	84450513          	add	a0,a0,-1980 # 9a0 <malloc+0x194>
 164:	00000097          	auipc	ra,0x0
 168:	5f0080e7          	jalr	1520(ra) # 754 <printf>

        // Wait for the child to finish
        wait(0);
 16c:	4501                	li	a0,0
 16e:	00000097          	auipc	ra,0x0
 172:	286080e7          	jalr	646(ra) # 3f4 <wait>

        // parent end
        exit(0);
 176:	4501                	li	a0,0
 178:	00000097          	auipc	ra,0x0
 17c:	274080e7          	jalr	628(ra) # 3ec <exit>

0000000000000180 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 180:	1141                	add	sp,sp,-16
 182:	e422                	sd	s0,8(sp)
 184:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 186:	87aa                	mv	a5,a0
 188:	0585                	add	a1,a1,1
 18a:	0785                	add	a5,a5,1
 18c:	fff5c703          	lbu	a4,-1(a1)
 190:	fee78fa3          	sb	a4,-1(a5)
 194:	fb75                	bnez	a4,188 <strcpy+0x8>
    ;
  return os;
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	add	sp,sp,16
 19a:	8082                	ret

000000000000019c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 19c:	1141                	add	sp,sp,-16
 19e:	e422                	sd	s0,8(sp)
 1a0:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	cb91                	beqz	a5,1ba <strcmp+0x1e>
 1a8:	0005c703          	lbu	a4,0(a1)
 1ac:	00f71763          	bne	a4,a5,1ba <strcmp+0x1e>
    p++, q++;
 1b0:	0505                	add	a0,a0,1
 1b2:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 1b4:	00054783          	lbu	a5,0(a0)
 1b8:	fbe5                	bnez	a5,1a8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ba:	0005c503          	lbu	a0,0(a1)
}
 1be:	40a7853b          	subw	a0,a5,a0
 1c2:	6422                	ld	s0,8(sp)
 1c4:	0141                	add	sp,sp,16
 1c6:	8082                	ret

00000000000001c8 <strlen>:

uint
strlen(const char *s)
{
 1c8:	1141                	add	sp,sp,-16
 1ca:	e422                	sd	s0,8(sp)
 1cc:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ce:	00054783          	lbu	a5,0(a0)
 1d2:	cf91                	beqz	a5,1ee <strlen+0x26>
 1d4:	0505                	add	a0,a0,1
 1d6:	87aa                	mv	a5,a0
 1d8:	86be                	mv	a3,a5
 1da:	0785                	add	a5,a5,1
 1dc:	fff7c703          	lbu	a4,-1(a5)
 1e0:	ff65                	bnez	a4,1d8 <strlen+0x10>
 1e2:	40a6853b          	subw	a0,a3,a0
 1e6:	2505                	addw	a0,a0,1
    ;
  return n;
}
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	add	sp,sp,16
 1ec:	8082                	ret
  for(n = 0; s[n]; n++)
 1ee:	4501                	li	a0,0
 1f0:	bfe5                	j	1e8 <strlen+0x20>

00000000000001f2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f2:	1141                	add	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1f8:	ca19                	beqz	a2,20e <memset+0x1c>
 1fa:	87aa                	mv	a5,a0
 1fc:	1602                	sll	a2,a2,0x20
 1fe:	9201                	srl	a2,a2,0x20
 200:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 204:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 208:	0785                	add	a5,a5,1
 20a:	fee79de3          	bne	a5,a4,204 <memset+0x12>
  }
  return dst;
}
 20e:	6422                	ld	s0,8(sp)
 210:	0141                	add	sp,sp,16
 212:	8082                	ret

0000000000000214 <strchr>:

char*
strchr(const char *s, char c)
{
 214:	1141                	add	sp,sp,-16
 216:	e422                	sd	s0,8(sp)
 218:	0800                	add	s0,sp,16
  for(; *s; s++)
 21a:	00054783          	lbu	a5,0(a0)
 21e:	cb99                	beqz	a5,234 <strchr+0x20>
    if(*s == c)
 220:	00f58763          	beq	a1,a5,22e <strchr+0x1a>
  for(; *s; s++)
 224:	0505                	add	a0,a0,1
 226:	00054783          	lbu	a5,0(a0)
 22a:	fbfd                	bnez	a5,220 <strchr+0xc>
      return (char*)s;
  return 0;
 22c:	4501                	li	a0,0
}
 22e:	6422                	ld	s0,8(sp)
 230:	0141                	add	sp,sp,16
 232:	8082                	ret
  return 0;
 234:	4501                	li	a0,0
 236:	bfe5                	j	22e <strchr+0x1a>

0000000000000238 <gets>:

char*
gets(char *buf, int max)
{
 238:	711d                	add	sp,sp,-96
 23a:	ec86                	sd	ra,88(sp)
 23c:	e8a2                	sd	s0,80(sp)
 23e:	e4a6                	sd	s1,72(sp)
 240:	e0ca                	sd	s2,64(sp)
 242:	fc4e                	sd	s3,56(sp)
 244:	f852                	sd	s4,48(sp)
 246:	f456                	sd	s5,40(sp)
 248:	f05a                	sd	s6,32(sp)
 24a:	ec5e                	sd	s7,24(sp)
 24c:	1080                	add	s0,sp,96
 24e:	8baa                	mv	s7,a0
 250:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 252:	892a                	mv	s2,a0
 254:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 256:	4aa9                	li	s5,10
 258:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 25a:	89a6                	mv	s3,s1
 25c:	2485                	addw	s1,s1,1
 25e:	0344d863          	bge	s1,s4,28e <gets+0x56>
    cc = read(0, &c, 1);
 262:	4605                	li	a2,1
 264:	faf40593          	add	a1,s0,-81
 268:	4501                	li	a0,0
 26a:	00000097          	auipc	ra,0x0
 26e:	19a080e7          	jalr	410(ra) # 404 <read>
    if(cc < 1)
 272:	00a05e63          	blez	a0,28e <gets+0x56>
    buf[i++] = c;
 276:	faf44783          	lbu	a5,-81(s0)
 27a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27e:	01578763          	beq	a5,s5,28c <gets+0x54>
 282:	0905                	add	s2,s2,1
 284:	fd679be3          	bne	a5,s6,25a <gets+0x22>
    buf[i++] = c;
 288:	89a6                	mv	s3,s1
 28a:	a011                	j	28e <gets+0x56>
 28c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28e:	99de                	add	s3,s3,s7
 290:	00098023          	sb	zero,0(s3)
  return buf;
}
 294:	855e                	mv	a0,s7
 296:	60e6                	ld	ra,88(sp)
 298:	6446                	ld	s0,80(sp)
 29a:	64a6                	ld	s1,72(sp)
 29c:	6906                	ld	s2,64(sp)
 29e:	79e2                	ld	s3,56(sp)
 2a0:	7a42                	ld	s4,48(sp)
 2a2:	7aa2                	ld	s5,40(sp)
 2a4:	7b02                	ld	s6,32(sp)
 2a6:	6be2                	ld	s7,24(sp)
 2a8:	6125                	add	sp,sp,96
 2aa:	8082                	ret

00000000000002ac <stat>:

int
stat(const char *n, struct stat *st)
{
 2ac:	1101                	add	sp,sp,-32
 2ae:	ec06                	sd	ra,24(sp)
 2b0:	e822                	sd	s0,16(sp)
 2b2:	e04a                	sd	s2,0(sp)
 2b4:	1000                	add	s0,sp,32
 2b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b8:	4581                	li	a1,0
 2ba:	00000097          	auipc	ra,0x0
 2be:	172080e7          	jalr	370(ra) # 42c <open>
  if(fd < 0)
 2c2:	02054663          	bltz	a0,2ee <stat+0x42>
 2c6:	e426                	sd	s1,8(sp)
 2c8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ca:	85ca                	mv	a1,s2
 2cc:	00000097          	auipc	ra,0x0
 2d0:	178080e7          	jalr	376(ra) # 444 <fstat>
 2d4:	892a                	mv	s2,a0
  close(fd);
 2d6:	8526                	mv	a0,s1
 2d8:	00000097          	auipc	ra,0x0
 2dc:	13c080e7          	jalr	316(ra) # 414 <close>
  return r;
 2e0:	64a2                	ld	s1,8(sp)
}
 2e2:	854a                	mv	a0,s2
 2e4:	60e2                	ld	ra,24(sp)
 2e6:	6442                	ld	s0,16(sp)
 2e8:	6902                	ld	s2,0(sp)
 2ea:	6105                	add	sp,sp,32
 2ec:	8082                	ret
    return -1;
 2ee:	597d                	li	s2,-1
 2f0:	bfcd                	j	2e2 <stat+0x36>

00000000000002f2 <atoi>:

int
atoi(const char *s)
{
 2f2:	1141                	add	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2f8:	00054683          	lbu	a3,0(a0)
 2fc:	fd06879b          	addw	a5,a3,-48
 300:	0ff7f793          	zext.b	a5,a5
 304:	4625                	li	a2,9
 306:	02f66863          	bltu	a2,a5,336 <atoi+0x44>
 30a:	872a                	mv	a4,a0
  n = 0;
 30c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 30e:	0705                	add	a4,a4,1
 310:	0025179b          	sllw	a5,a0,0x2
 314:	9fa9                	addw	a5,a5,a0
 316:	0017979b          	sllw	a5,a5,0x1
 31a:	9fb5                	addw	a5,a5,a3
 31c:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 320:	00074683          	lbu	a3,0(a4)
 324:	fd06879b          	addw	a5,a3,-48
 328:	0ff7f793          	zext.b	a5,a5
 32c:	fef671e3          	bgeu	a2,a5,30e <atoi+0x1c>
  return n;
}
 330:	6422                	ld	s0,8(sp)
 332:	0141                	add	sp,sp,16
 334:	8082                	ret
  n = 0;
 336:	4501                	li	a0,0
 338:	bfe5                	j	330 <atoi+0x3e>

000000000000033a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 33a:	1141                	add	sp,sp,-16
 33c:	e422                	sd	s0,8(sp)
 33e:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 340:	02b57463          	bgeu	a0,a1,368 <memmove+0x2e>
    while(n-- > 0)
 344:	00c05f63          	blez	a2,362 <memmove+0x28>
 348:	1602                	sll	a2,a2,0x20
 34a:	9201                	srl	a2,a2,0x20
 34c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 350:	872a                	mv	a4,a0
      *dst++ = *src++;
 352:	0585                	add	a1,a1,1
 354:	0705                	add	a4,a4,1
 356:	fff5c683          	lbu	a3,-1(a1)
 35a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 35e:	fef71ae3          	bne	a4,a5,352 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 362:	6422                	ld	s0,8(sp)
 364:	0141                	add	sp,sp,16
 366:	8082                	ret
    dst += n;
 368:	00c50733          	add	a4,a0,a2
    src += n;
 36c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 36e:	fec05ae3          	blez	a2,362 <memmove+0x28>
 372:	fff6079b          	addw	a5,a2,-1
 376:	1782                	sll	a5,a5,0x20
 378:	9381                	srl	a5,a5,0x20
 37a:	fff7c793          	not	a5,a5
 37e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 380:	15fd                	add	a1,a1,-1
 382:	177d                	add	a4,a4,-1
 384:	0005c683          	lbu	a3,0(a1)
 388:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 38c:	fee79ae3          	bne	a5,a4,380 <memmove+0x46>
 390:	bfc9                	j	362 <memmove+0x28>

0000000000000392 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 392:	1141                	add	sp,sp,-16
 394:	e422                	sd	s0,8(sp)
 396:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 398:	ca05                	beqz	a2,3c8 <memcmp+0x36>
 39a:	fff6069b          	addw	a3,a2,-1
 39e:	1682                	sll	a3,a3,0x20
 3a0:	9281                	srl	a3,a3,0x20
 3a2:	0685                	add	a3,a3,1
 3a4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3a6:	00054783          	lbu	a5,0(a0)
 3aa:	0005c703          	lbu	a4,0(a1)
 3ae:	00e79863          	bne	a5,a4,3be <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3b2:	0505                	add	a0,a0,1
    p2++;
 3b4:	0585                	add	a1,a1,1
  while (n-- > 0) {
 3b6:	fed518e3          	bne	a0,a3,3a6 <memcmp+0x14>
  }
  return 0;
 3ba:	4501                	li	a0,0
 3bc:	a019                	j	3c2 <memcmp+0x30>
      return *p1 - *p2;
 3be:	40e7853b          	subw	a0,a5,a4
}
 3c2:	6422                	ld	s0,8(sp)
 3c4:	0141                	add	sp,sp,16
 3c6:	8082                	ret
  return 0;
 3c8:	4501                	li	a0,0
 3ca:	bfe5                	j	3c2 <memcmp+0x30>

00000000000003cc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3cc:	1141                	add	sp,sp,-16
 3ce:	e406                	sd	ra,8(sp)
 3d0:	e022                	sd	s0,0(sp)
 3d2:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 3d4:	00000097          	auipc	ra,0x0
 3d8:	f66080e7          	jalr	-154(ra) # 33a <memmove>
}
 3dc:	60a2                	ld	ra,8(sp)
 3de:	6402                	ld	s0,0(sp)
 3e0:	0141                	add	sp,sp,16
 3e2:	8082                	ret

00000000000003e4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3e4:	4885                	li	a7,1
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ec:	4889                	li	a7,2
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3f4:	488d                	li	a7,3
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3fc:	4891                	li	a7,4
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <read>:
.global read
read:
 li a7, SYS_read
 404:	4895                	li	a7,5
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <write>:
.global write
write:
 li a7, SYS_write
 40c:	48c1                	li	a7,16
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <close>:
.global close
close:
 li a7, SYS_close
 414:	48d5                	li	a7,21
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <kill>:
.global kill
kill:
 li a7, SYS_kill
 41c:	4899                	li	a7,6
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <exec>:
.global exec
exec:
 li a7, SYS_exec
 424:	489d                	li	a7,7
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <open>:
.global open
open:
 li a7, SYS_open
 42c:	48bd                	li	a7,15
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 434:	48c5                	li	a7,17
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 43c:	48c9                	li	a7,18
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 444:	48a1                	li	a7,8
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <link>:
.global link
link:
 li a7, SYS_link
 44c:	48cd                	li	a7,19
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 454:	48d1                	li	a7,20
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 45c:	48a5                	li	a7,9
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <dup>:
.global dup
dup:
 li a7, SYS_dup
 464:	48a9                	li	a7,10
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 46c:	48ad                	li	a7,11
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 474:	48b1                	li	a7,12
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 47c:	48b5                	li	a7,13
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 484:	48b9                	li	a7,14
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 48c:	1101                	add	sp,sp,-32
 48e:	ec06                	sd	ra,24(sp)
 490:	e822                	sd	s0,16(sp)
 492:	1000                	add	s0,sp,32
 494:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 498:	4605                	li	a2,1
 49a:	fef40593          	add	a1,s0,-17
 49e:	00000097          	auipc	ra,0x0
 4a2:	f6e080e7          	jalr	-146(ra) # 40c <write>
}
 4a6:	60e2                	ld	ra,24(sp)
 4a8:	6442                	ld	s0,16(sp)
 4aa:	6105                	add	sp,sp,32
 4ac:	8082                	ret

00000000000004ae <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ae:	7139                	add	sp,sp,-64
 4b0:	fc06                	sd	ra,56(sp)
 4b2:	f822                	sd	s0,48(sp)
 4b4:	f426                	sd	s1,40(sp)
 4b6:	0080                	add	s0,sp,64
 4b8:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ba:	c299                	beqz	a3,4c0 <printint+0x12>
 4bc:	0805cb63          	bltz	a1,552 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4c0:	2581                	sext.w	a1,a1
  neg = 0;
 4c2:	4881                	li	a7,0
 4c4:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 4c8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4ca:	2601                	sext.w	a2,a2
 4cc:	00000517          	auipc	a0,0x0
 4d0:	55450513          	add	a0,a0,1364 # a20 <digits>
 4d4:	883a                	mv	a6,a4
 4d6:	2705                	addw	a4,a4,1
 4d8:	02c5f7bb          	remuw	a5,a1,a2
 4dc:	1782                	sll	a5,a5,0x20
 4de:	9381                	srl	a5,a5,0x20
 4e0:	97aa                	add	a5,a5,a0
 4e2:	0007c783          	lbu	a5,0(a5)
 4e6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ea:	0005879b          	sext.w	a5,a1
 4ee:	02c5d5bb          	divuw	a1,a1,a2
 4f2:	0685                	add	a3,a3,1
 4f4:	fec7f0e3          	bgeu	a5,a2,4d4 <printint+0x26>
  if(neg)
 4f8:	00088c63          	beqz	a7,510 <printint+0x62>
    buf[i++] = '-';
 4fc:	fd070793          	add	a5,a4,-48
 500:	00878733          	add	a4,a5,s0
 504:	02d00793          	li	a5,45
 508:	fef70823          	sb	a5,-16(a4)
 50c:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 510:	02e05c63          	blez	a4,548 <printint+0x9a>
 514:	f04a                	sd	s2,32(sp)
 516:	ec4e                	sd	s3,24(sp)
 518:	fc040793          	add	a5,s0,-64
 51c:	00e78933          	add	s2,a5,a4
 520:	fff78993          	add	s3,a5,-1
 524:	99ba                	add	s3,s3,a4
 526:	377d                	addw	a4,a4,-1
 528:	1702                	sll	a4,a4,0x20
 52a:	9301                	srl	a4,a4,0x20
 52c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 530:	fff94583          	lbu	a1,-1(s2)
 534:	8526                	mv	a0,s1
 536:	00000097          	auipc	ra,0x0
 53a:	f56080e7          	jalr	-170(ra) # 48c <putc>
  while(--i >= 0)
 53e:	197d                	add	s2,s2,-1
 540:	ff3918e3          	bne	s2,s3,530 <printint+0x82>
 544:	7902                	ld	s2,32(sp)
 546:	69e2                	ld	s3,24(sp)
}
 548:	70e2                	ld	ra,56(sp)
 54a:	7442                	ld	s0,48(sp)
 54c:	74a2                	ld	s1,40(sp)
 54e:	6121                	add	sp,sp,64
 550:	8082                	ret
    x = -xx;
 552:	40b005bb          	negw	a1,a1
    neg = 1;
 556:	4885                	li	a7,1
    x = -xx;
 558:	b7b5                	j	4c4 <printint+0x16>

000000000000055a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 55a:	715d                	add	sp,sp,-80
 55c:	e486                	sd	ra,72(sp)
 55e:	e0a2                	sd	s0,64(sp)
 560:	f84a                	sd	s2,48(sp)
 562:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 564:	0005c903          	lbu	s2,0(a1)
 568:	1a090a63          	beqz	s2,71c <vprintf+0x1c2>
 56c:	fc26                	sd	s1,56(sp)
 56e:	f44e                	sd	s3,40(sp)
 570:	f052                	sd	s4,32(sp)
 572:	ec56                	sd	s5,24(sp)
 574:	e85a                	sd	s6,16(sp)
 576:	e45e                	sd	s7,8(sp)
 578:	8aaa                	mv	s5,a0
 57a:	8bb2                	mv	s7,a2
 57c:	00158493          	add	s1,a1,1
  state = 0;
 580:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 582:	02500a13          	li	s4,37
 586:	4b55                	li	s6,21
 588:	a839                	j	5a6 <vprintf+0x4c>
        putc(fd, c);
 58a:	85ca                	mv	a1,s2
 58c:	8556                	mv	a0,s5
 58e:	00000097          	auipc	ra,0x0
 592:	efe080e7          	jalr	-258(ra) # 48c <putc>
 596:	a019                	j	59c <vprintf+0x42>
    } else if(state == '%'){
 598:	01498d63          	beq	s3,s4,5b2 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 59c:	0485                	add	s1,s1,1
 59e:	fff4c903          	lbu	s2,-1(s1)
 5a2:	16090763          	beqz	s2,710 <vprintf+0x1b6>
    if(state == 0){
 5a6:	fe0999e3          	bnez	s3,598 <vprintf+0x3e>
      if(c == '%'){
 5aa:	ff4910e3          	bne	s2,s4,58a <vprintf+0x30>
        state = '%';
 5ae:	89d2                	mv	s3,s4
 5b0:	b7f5                	j	59c <vprintf+0x42>
      if(c == 'd'){
 5b2:	13490463          	beq	s2,s4,6da <vprintf+0x180>
 5b6:	f9d9079b          	addw	a5,s2,-99
 5ba:	0ff7f793          	zext.b	a5,a5
 5be:	12fb6763          	bltu	s6,a5,6ec <vprintf+0x192>
 5c2:	f9d9079b          	addw	a5,s2,-99
 5c6:	0ff7f713          	zext.b	a4,a5
 5ca:	12eb6163          	bltu	s6,a4,6ec <vprintf+0x192>
 5ce:	00271793          	sll	a5,a4,0x2
 5d2:	00000717          	auipc	a4,0x0
 5d6:	3f670713          	add	a4,a4,1014 # 9c8 <malloc+0x1bc>
 5da:	97ba                	add	a5,a5,a4
 5dc:	439c                	lw	a5,0(a5)
 5de:	97ba                	add	a5,a5,a4
 5e0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5e2:	008b8913          	add	s2,s7,8
 5e6:	4685                	li	a3,1
 5e8:	4629                	li	a2,10
 5ea:	000ba583          	lw	a1,0(s7)
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	ebe080e7          	jalr	-322(ra) # 4ae <printint>
 5f8:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	b745                	j	59c <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fe:	008b8913          	add	s2,s7,8
 602:	4681                	li	a3,0
 604:	4629                	li	a2,10
 606:	000ba583          	lw	a1,0(s7)
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	ea2080e7          	jalr	-350(ra) # 4ae <printint>
 614:	8bca                	mv	s7,s2
      state = 0;
 616:	4981                	li	s3,0
 618:	b751                	j	59c <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 61a:	008b8913          	add	s2,s7,8
 61e:	4681                	li	a3,0
 620:	4641                	li	a2,16
 622:	000ba583          	lw	a1,0(s7)
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	e86080e7          	jalr	-378(ra) # 4ae <printint>
 630:	8bca                	mv	s7,s2
      state = 0;
 632:	4981                	li	s3,0
 634:	b7a5                	j	59c <vprintf+0x42>
 636:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 638:	008b8c13          	add	s8,s7,8
 63c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 640:	03000593          	li	a1,48
 644:	8556                	mv	a0,s5
 646:	00000097          	auipc	ra,0x0
 64a:	e46080e7          	jalr	-442(ra) # 48c <putc>
  putc(fd, 'x');
 64e:	07800593          	li	a1,120
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	e38080e7          	jalr	-456(ra) # 48c <putc>
 65c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 65e:	00000b97          	auipc	s7,0x0
 662:	3c2b8b93          	add	s7,s7,962 # a20 <digits>
 666:	03c9d793          	srl	a5,s3,0x3c
 66a:	97de                	add	a5,a5,s7
 66c:	0007c583          	lbu	a1,0(a5)
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	e1a080e7          	jalr	-486(ra) # 48c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 67a:	0992                	sll	s3,s3,0x4
 67c:	397d                	addw	s2,s2,-1
 67e:	fe0914e3          	bnez	s2,666 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 682:	8be2                	mv	s7,s8
      state = 0;
 684:	4981                	li	s3,0
 686:	6c02                	ld	s8,0(sp)
 688:	bf11                	j	59c <vprintf+0x42>
        s = va_arg(ap, char*);
 68a:	008b8993          	add	s3,s7,8
 68e:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 692:	02090163          	beqz	s2,6b4 <vprintf+0x15a>
        while(*s != 0){
 696:	00094583          	lbu	a1,0(s2)
 69a:	c9a5                	beqz	a1,70a <vprintf+0x1b0>
          putc(fd, *s);
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	dee080e7          	jalr	-530(ra) # 48c <putc>
          s++;
 6a6:	0905                	add	s2,s2,1
        while(*s != 0){
 6a8:	00094583          	lbu	a1,0(s2)
 6ac:	f9e5                	bnez	a1,69c <vprintf+0x142>
        s = va_arg(ap, char*);
 6ae:	8bce                	mv	s7,s3
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	b5ed                	j	59c <vprintf+0x42>
          s = "(null)";
 6b4:	00000917          	auipc	s2,0x0
 6b8:	30c90913          	add	s2,s2,780 # 9c0 <malloc+0x1b4>
        while(*s != 0){
 6bc:	02800593          	li	a1,40
 6c0:	bff1                	j	69c <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 6c2:	008b8913          	add	s2,s7,8
 6c6:	000bc583          	lbu	a1,0(s7)
 6ca:	8556                	mv	a0,s5
 6cc:	00000097          	auipc	ra,0x0
 6d0:	dc0080e7          	jalr	-576(ra) # 48c <putc>
 6d4:	8bca                	mv	s7,s2
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	b5d1                	j	59c <vprintf+0x42>
        putc(fd, c);
 6da:	02500593          	li	a1,37
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	dac080e7          	jalr	-596(ra) # 48c <putc>
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	bd4d                	j	59c <vprintf+0x42>
        putc(fd, '%');
 6ec:	02500593          	li	a1,37
 6f0:	8556                	mv	a0,s5
 6f2:	00000097          	auipc	ra,0x0
 6f6:	d9a080e7          	jalr	-614(ra) # 48c <putc>
        putc(fd, c);
 6fa:	85ca                	mv	a1,s2
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	d8e080e7          	jalr	-626(ra) # 48c <putc>
      state = 0;
 706:	4981                	li	s3,0
 708:	bd51                	j	59c <vprintf+0x42>
        s = va_arg(ap, char*);
 70a:	8bce                	mv	s7,s3
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b579                	j	59c <vprintf+0x42>
 710:	74e2                	ld	s1,56(sp)
 712:	79a2                	ld	s3,40(sp)
 714:	7a02                	ld	s4,32(sp)
 716:	6ae2                	ld	s5,24(sp)
 718:	6b42                	ld	s6,16(sp)
 71a:	6ba2                	ld	s7,8(sp)
    }
  }
}
 71c:	60a6                	ld	ra,72(sp)
 71e:	6406                	ld	s0,64(sp)
 720:	7942                	ld	s2,48(sp)
 722:	6161                	add	sp,sp,80
 724:	8082                	ret

0000000000000726 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 726:	715d                	add	sp,sp,-80
 728:	ec06                	sd	ra,24(sp)
 72a:	e822                	sd	s0,16(sp)
 72c:	1000                	add	s0,sp,32
 72e:	e010                	sd	a2,0(s0)
 730:	e414                	sd	a3,8(s0)
 732:	e818                	sd	a4,16(s0)
 734:	ec1c                	sd	a5,24(s0)
 736:	03043023          	sd	a6,32(s0)
 73a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 73e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 742:	8622                	mv	a2,s0
 744:	00000097          	auipc	ra,0x0
 748:	e16080e7          	jalr	-490(ra) # 55a <vprintf>
}
 74c:	60e2                	ld	ra,24(sp)
 74e:	6442                	ld	s0,16(sp)
 750:	6161                	add	sp,sp,80
 752:	8082                	ret

0000000000000754 <printf>:

void
printf(const char *fmt, ...)
{
 754:	711d                	add	sp,sp,-96
 756:	ec06                	sd	ra,24(sp)
 758:	e822                	sd	s0,16(sp)
 75a:	1000                	add	s0,sp,32
 75c:	e40c                	sd	a1,8(s0)
 75e:	e810                	sd	a2,16(s0)
 760:	ec14                	sd	a3,24(s0)
 762:	f018                	sd	a4,32(s0)
 764:	f41c                	sd	a5,40(s0)
 766:	03043823          	sd	a6,48(s0)
 76a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 76e:	00840613          	add	a2,s0,8
 772:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 776:	85aa                	mv	a1,a0
 778:	4505                	li	a0,1
 77a:	00000097          	auipc	ra,0x0
 77e:	de0080e7          	jalr	-544(ra) # 55a <vprintf>
}
 782:	60e2                	ld	ra,24(sp)
 784:	6442                	ld	s0,16(sp)
 786:	6125                	add	sp,sp,96
 788:	8082                	ret

000000000000078a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 78a:	1141                	add	sp,sp,-16
 78c:	e422                	sd	s0,8(sp)
 78e:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 790:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 794:	00000797          	auipc	a5,0x0
 798:	2a47b783          	ld	a5,676(a5) # a38 <freep>
 79c:	a02d                	j	7c6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 79e:	4618                	lw	a4,8(a2)
 7a0:	9f2d                	addw	a4,a4,a1
 7a2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a6:	6398                	ld	a4,0(a5)
 7a8:	6310                	ld	a2,0(a4)
 7aa:	a83d                	j	7e8 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ac:	ff852703          	lw	a4,-8(a0)
 7b0:	9f31                	addw	a4,a4,a2
 7b2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7b4:	ff053683          	ld	a3,-16(a0)
 7b8:	a091                	j	7fc <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ba:	6398                	ld	a4,0(a5)
 7bc:	00e7e463          	bltu	a5,a4,7c4 <free+0x3a>
 7c0:	00e6ea63          	bltu	a3,a4,7d4 <free+0x4a>
{
 7c4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c6:	fed7fae3          	bgeu	a5,a3,7ba <free+0x30>
 7ca:	6398                	ld	a4,0(a5)
 7cc:	00e6e463          	bltu	a3,a4,7d4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d0:	fee7eae3          	bltu	a5,a4,7c4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7d4:	ff852583          	lw	a1,-8(a0)
 7d8:	6390                	ld	a2,0(a5)
 7da:	02059813          	sll	a6,a1,0x20
 7de:	01c85713          	srl	a4,a6,0x1c
 7e2:	9736                	add	a4,a4,a3
 7e4:	fae60de3          	beq	a2,a4,79e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7e8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ec:	4790                	lw	a2,8(a5)
 7ee:	02061593          	sll	a1,a2,0x20
 7f2:	01c5d713          	srl	a4,a1,0x1c
 7f6:	973e                	add	a4,a4,a5
 7f8:	fae68ae3          	beq	a3,a4,7ac <free+0x22>
    p->s.ptr = bp->s.ptr;
 7fc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7fe:	00000717          	auipc	a4,0x0
 802:	22f73d23          	sd	a5,570(a4) # a38 <freep>
}
 806:	6422                	ld	s0,8(sp)
 808:	0141                	add	sp,sp,16
 80a:	8082                	ret

000000000000080c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 80c:	7139                	add	sp,sp,-64
 80e:	fc06                	sd	ra,56(sp)
 810:	f822                	sd	s0,48(sp)
 812:	f426                	sd	s1,40(sp)
 814:	ec4e                	sd	s3,24(sp)
 816:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 818:	02051493          	sll	s1,a0,0x20
 81c:	9081                	srl	s1,s1,0x20
 81e:	04bd                	add	s1,s1,15
 820:	8091                	srl	s1,s1,0x4
 822:	0014899b          	addw	s3,s1,1
 826:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 828:	00000517          	auipc	a0,0x0
 82c:	21053503          	ld	a0,528(a0) # a38 <freep>
 830:	c915                	beqz	a0,864 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 832:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 834:	4798                	lw	a4,8(a5)
 836:	08977e63          	bgeu	a4,s1,8d2 <malloc+0xc6>
 83a:	f04a                	sd	s2,32(sp)
 83c:	e852                	sd	s4,16(sp)
 83e:	e456                	sd	s5,8(sp)
 840:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 842:	8a4e                	mv	s4,s3
 844:	0009871b          	sext.w	a4,s3
 848:	6685                	lui	a3,0x1
 84a:	00d77363          	bgeu	a4,a3,850 <malloc+0x44>
 84e:	6a05                	lui	s4,0x1
 850:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 854:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 858:	00000917          	auipc	s2,0x0
 85c:	1e090913          	add	s2,s2,480 # a38 <freep>
  if(p == (char*)-1)
 860:	5afd                	li	s5,-1
 862:	a091                	j	8a6 <malloc+0x9a>
 864:	f04a                	sd	s2,32(sp)
 866:	e852                	sd	s4,16(sp)
 868:	e456                	sd	s5,8(sp)
 86a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 86c:	00000797          	auipc	a5,0x0
 870:	1d478793          	add	a5,a5,468 # a40 <base>
 874:	00000717          	auipc	a4,0x0
 878:	1cf73223          	sd	a5,452(a4) # a38 <freep>
 87c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 87e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 882:	b7c1                	j	842 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 884:	6398                	ld	a4,0(a5)
 886:	e118                	sd	a4,0(a0)
 888:	a08d                	j	8ea <malloc+0xde>
  hp->s.size = nu;
 88a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 88e:	0541                	add	a0,a0,16
 890:	00000097          	auipc	ra,0x0
 894:	efa080e7          	jalr	-262(ra) # 78a <free>
  return freep;
 898:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 89c:	c13d                	beqz	a0,902 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a0:	4798                	lw	a4,8(a5)
 8a2:	02977463          	bgeu	a4,s1,8ca <malloc+0xbe>
    if(p == freep)
 8a6:	00093703          	ld	a4,0(s2)
 8aa:	853e                	mv	a0,a5
 8ac:	fef719e3          	bne	a4,a5,89e <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 8b0:	8552                	mv	a0,s4
 8b2:	00000097          	auipc	ra,0x0
 8b6:	bc2080e7          	jalr	-1086(ra) # 474 <sbrk>
  if(p == (char*)-1)
 8ba:	fd5518e3          	bne	a0,s5,88a <malloc+0x7e>
        return 0;
 8be:	4501                	li	a0,0
 8c0:	7902                	ld	s2,32(sp)
 8c2:	6a42                	ld	s4,16(sp)
 8c4:	6aa2                	ld	s5,8(sp)
 8c6:	6b02                	ld	s6,0(sp)
 8c8:	a03d                	j	8f6 <malloc+0xea>
 8ca:	7902                	ld	s2,32(sp)
 8cc:	6a42                	ld	s4,16(sp)
 8ce:	6aa2                	ld	s5,8(sp)
 8d0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8d2:	fae489e3          	beq	s1,a4,884 <malloc+0x78>
        p->s.size -= nunits;
 8d6:	4137073b          	subw	a4,a4,s3
 8da:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8dc:	02071693          	sll	a3,a4,0x20
 8e0:	01c6d713          	srl	a4,a3,0x1c
 8e4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ea:	00000717          	auipc	a4,0x0
 8ee:	14a73723          	sd	a0,334(a4) # a38 <freep>
      return (void*)(p + 1);
 8f2:	01078513          	add	a0,a5,16
  }
}
 8f6:	70e2                	ld	ra,56(sp)
 8f8:	7442                	ld	s0,48(sp)
 8fa:	74a2                	ld	s1,40(sp)
 8fc:	69e2                	ld	s3,24(sp)
 8fe:	6121                	add	sp,sp,64
 900:	8082                	ret
 902:	7902                	ld	s2,32(sp)
 904:	6a42                	ld	s4,16(sp)
 906:	6aa2                	ld	s5,8(sp)
 908:	6b02                	ld	s6,0(sp)
 90a:	b7f5                	j	8f6 <malloc+0xea>
