
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	add	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	add	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	add	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
      return 1;
  3c:	4505                	li	a0,1
  return 0;
}
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	add	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  if(re[0] == '\0')
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
{
  54:	1141                	add	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	add	s0,sp,16
  5c:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  72:	0005c683          	lbu	a3,0(a1)
  return 0;
  76:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  return 0;
  82:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
}
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	add	sp,sp,16
  8e:	8082                	ret
    return matchstar(re[0], re+2, text);
  90:	862e                	mv	a2,a1
  92:	00250593          	add	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  return 0;
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
    return *text == '\0';
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b8:	0585                	add	a1,a1,1
  ba:	00178513          	add	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
    return 1;
  c8:	4505                	li	a0,1
}
  ca:	8082                	ret

00000000000000cc <match>:
{
  cc:	1101                	add	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	e04a                	sd	s2,0(sp)
  d6:	1000                	add	s0,sp,32
  d8:	892a                	mv	s2,a0
  da:	84ae                	mv	s1,a1
  if(re[0] == '^')
  dc:	00054703          	lbu	a4,0(a0)
  e0:	05e00793          	li	a5,94
  e4:	00f70e63          	beq	a4,a5,100 <match+0x34>
    if(matchhere(re, text))
  e8:	85a6                	mv	a1,s1
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	f62080e7          	jalr	-158(ra) # 4e <matchhere>
  f4:	ed01                	bnez	a0,10c <match+0x40>
  }while(*text++ != '\0');
  f6:	0485                	add	s1,s1,1
  f8:	fff4c783          	lbu	a5,-1(s1)
  fc:	f7f5                	bnez	a5,e8 <match+0x1c>
  fe:	a801                	j	10e <match+0x42>
    return matchhere(re+1, text);
 100:	0505                	add	a0,a0,1
 102:	00000097          	auipc	ra,0x0
 106:	f4c080e7          	jalr	-180(ra) # 4e <matchhere>
 10a:	a011                	j	10e <match+0x42>
      return 1;
 10c:	4505                	li	a0,1
}
 10e:	60e2                	ld	ra,24(sp)
 110:	6442                	ld	s0,16(sp)
 112:	64a2                	ld	s1,8(sp)
 114:	6902                	ld	s2,0(sp)
 116:	6105                	add	sp,sp,32
 118:	8082                	ret

000000000000011a <grep>:
{
 11a:	715d                	add	sp,sp,-80
 11c:	e486                	sd	ra,72(sp)
 11e:	e0a2                	sd	s0,64(sp)
 120:	fc26                	sd	s1,56(sp)
 122:	f84a                	sd	s2,48(sp)
 124:	f44e                	sd	s3,40(sp)
 126:	f052                	sd	s4,32(sp)
 128:	ec56                	sd	s5,24(sp)
 12a:	e85a                	sd	s6,16(sp)
 12c:	e45e                	sd	s7,8(sp)
 12e:	e062                	sd	s8,0(sp)
 130:	0880                	add	s0,sp,80
 132:	89aa                	mv	s3,a0
 134:	8b2e                	mv	s6,a1
  m = 0;
 136:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 138:	3ff00b93          	li	s7,1023
 13c:	00001a97          	auipc	s5,0x1
 140:	9cca8a93          	add	s5,s5,-1588 # b08 <buf>
 144:	a0a1                	j	18c <grep+0x72>
      p = q+1;
 146:	00148913          	add	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 14a:	45a9                	li	a1,10
 14c:	854a                	mv	a0,s2
 14e:	00000097          	auipc	ra,0x0
 152:	1f0080e7          	jalr	496(ra) # 33e <strchr>
 156:	84aa                	mv	s1,a0
 158:	c905                	beqz	a0,188 <grep+0x6e>
      *q = 0;
 15a:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 15e:	85ca                	mv	a1,s2
 160:	854e                	mv	a0,s3
 162:	00000097          	auipc	ra,0x0
 166:	f6a080e7          	jalr	-150(ra) # cc <match>
 16a:	dd71                	beqz	a0,146 <grep+0x2c>
        *q = '\n';
 16c:	47a9                	li	a5,10
 16e:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 172:	00148613          	add	a2,s1,1
 176:	4126063b          	subw	a2,a2,s2
 17a:	85ca                	mv	a1,s2
 17c:	4505                	li	a0,1
 17e:	00000097          	auipc	ra,0x0
 182:	3b8080e7          	jalr	952(ra) # 536 <write>
 186:	b7c1                	j	146 <grep+0x2c>
    if(m > 0){
 188:	03404763          	bgtz	s4,1b6 <grep+0x9c>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 18c:	414b863b          	subw	a2,s7,s4
 190:	014a85b3          	add	a1,s5,s4
 194:	855a                	mv	a0,s6
 196:	00000097          	auipc	ra,0x0
 19a:	398080e7          	jalr	920(ra) # 52e <read>
 19e:	02a05b63          	blez	a0,1d4 <grep+0xba>
    m += n;
 1a2:	00aa0c3b          	addw	s8,s4,a0
 1a6:	000c0a1b          	sext.w	s4,s8
    buf[m] = '\0';
 1aa:	014a87b3          	add	a5,s5,s4
 1ae:	00078023          	sb	zero,0(a5)
    p = buf;
 1b2:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 1b4:	bf59                	j	14a <grep+0x30>
      m -= p - buf;
 1b6:	00001517          	auipc	a0,0x1
 1ba:	95250513          	add	a0,a0,-1710 # b08 <buf>
 1be:	40a90a33          	sub	s4,s2,a0
 1c2:	414c0a3b          	subw	s4,s8,s4
      memmove(buf, p, m);
 1c6:	8652                	mv	a2,s4
 1c8:	85ca                	mv	a1,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	29a080e7          	jalr	666(ra) # 464 <memmove>
 1d2:	bf6d                	j	18c <grep+0x72>
}
 1d4:	60a6                	ld	ra,72(sp)
 1d6:	6406                	ld	s0,64(sp)
 1d8:	74e2                	ld	s1,56(sp)
 1da:	7942                	ld	s2,48(sp)
 1dc:	79a2                	ld	s3,40(sp)
 1de:	7a02                	ld	s4,32(sp)
 1e0:	6ae2                	ld	s5,24(sp)
 1e2:	6b42                	ld	s6,16(sp)
 1e4:	6ba2                	ld	s7,8(sp)
 1e6:	6c02                	ld	s8,0(sp)
 1e8:	6161                	add	sp,sp,80
 1ea:	8082                	ret

00000000000001ec <main>:
{
 1ec:	7179                	add	sp,sp,-48
 1ee:	f406                	sd	ra,40(sp)
 1f0:	f022                	sd	s0,32(sp)
 1f2:	ec26                	sd	s1,24(sp)
 1f4:	e84a                	sd	s2,16(sp)
 1f6:	e44e                	sd	s3,8(sp)
 1f8:	e052                	sd	s4,0(sp)
 1fa:	1800                	add	s0,sp,48
  if(argc <= 1){
 1fc:	4785                	li	a5,1
 1fe:	04a7de63          	bge	a5,a0,25a <main+0x6e>
  pattern = argv[1];
 202:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 206:	4789                	li	a5,2
 208:	06a7d763          	bge	a5,a0,276 <main+0x8a>
 20c:	01058913          	add	s2,a1,16
 210:	ffd5099b          	addw	s3,a0,-3
 214:	02099793          	sll	a5,s3,0x20
 218:	01d7d993          	srl	s3,a5,0x1d
 21c:	05e1                	add	a1,a1,24
 21e:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], 0)) < 0){
 220:	4581                	li	a1,0
 222:	00093503          	ld	a0,0(s2)
 226:	00000097          	auipc	ra,0x0
 22a:	330080e7          	jalr	816(ra) # 556 <open>
 22e:	84aa                	mv	s1,a0
 230:	04054e63          	bltz	a0,28c <main+0xa0>
    grep(pattern, fd);
 234:	85aa                	mv	a1,a0
 236:	8552                	mv	a0,s4
 238:	00000097          	auipc	ra,0x0
 23c:	ee2080e7          	jalr	-286(ra) # 11a <grep>
    close(fd);
 240:	8526                	mv	a0,s1
 242:	00000097          	auipc	ra,0x0
 246:	2fc080e7          	jalr	764(ra) # 53e <close>
  for(i = 2; i < argc; i++){
 24a:	0921                	add	s2,s2,8
 24c:	fd391ae3          	bne	s2,s3,220 <main+0x34>
  exit(0);
 250:	4501                	li	a0,0
 252:	00000097          	auipc	ra,0x0
 256:	2c4080e7          	jalr	708(ra) # 516 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 25a:	00000597          	auipc	a1,0x0
 25e:	7f658593          	add	a1,a1,2038 # a50 <malloc+0x102>
 262:	4509                	li	a0,2
 264:	00000097          	auipc	ra,0x0
 268:	604080e7          	jalr	1540(ra) # 868 <fprintf>
    exit(1);
 26c:	4505                	li	a0,1
 26e:	00000097          	auipc	ra,0x0
 272:	2a8080e7          	jalr	680(ra) # 516 <exit>
    grep(pattern, 0);
 276:	4581                	li	a1,0
 278:	8552                	mv	a0,s4
 27a:	00000097          	auipc	ra,0x0
 27e:	ea0080e7          	jalr	-352(ra) # 11a <grep>
    exit(0);
 282:	4501                	li	a0,0
 284:	00000097          	auipc	ra,0x0
 288:	292080e7          	jalr	658(ra) # 516 <exit>
      printf("grep: cannot open %s\n", argv[i]);
 28c:	00093583          	ld	a1,0(s2)
 290:	00000517          	auipc	a0,0x0
 294:	7e050513          	add	a0,a0,2016 # a70 <malloc+0x122>
 298:	00000097          	auipc	ra,0x0
 29c:	5fe080e7          	jalr	1534(ra) # 896 <printf>
      exit(1);
 2a0:	4505                	li	a0,1
 2a2:	00000097          	auipc	ra,0x0
 2a6:	274080e7          	jalr	628(ra) # 516 <exit>

00000000000002aa <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 2aa:	1141                	add	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2b0:	87aa                	mv	a5,a0
 2b2:	0585                	add	a1,a1,1
 2b4:	0785                	add	a5,a5,1
 2b6:	fff5c703          	lbu	a4,-1(a1)
 2ba:	fee78fa3          	sb	a4,-1(a5)
 2be:	fb75                	bnez	a4,2b2 <strcpy+0x8>
    ;
  return os;
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	add	sp,sp,16
 2c4:	8082                	ret

00000000000002c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2c6:	1141                	add	sp,sp,-16
 2c8:	e422                	sd	s0,8(sp)
 2ca:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 2cc:	00054783          	lbu	a5,0(a0)
 2d0:	cb91                	beqz	a5,2e4 <strcmp+0x1e>
 2d2:	0005c703          	lbu	a4,0(a1)
 2d6:	00f71763          	bne	a4,a5,2e4 <strcmp+0x1e>
    p++, q++;
 2da:	0505                	add	a0,a0,1
 2dc:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 2de:	00054783          	lbu	a5,0(a0)
 2e2:	fbe5                	bnez	a5,2d2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2e4:	0005c503          	lbu	a0,0(a1)
}
 2e8:	40a7853b          	subw	a0,a5,a0
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	add	sp,sp,16
 2f0:	8082                	ret

00000000000002f2 <strlen>:

uint
strlen(const char *s)
{
 2f2:	1141                	add	sp,sp,-16
 2f4:	e422                	sd	s0,8(sp)
 2f6:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	cf91                	beqz	a5,318 <strlen+0x26>
 2fe:	0505                	add	a0,a0,1
 300:	87aa                	mv	a5,a0
 302:	86be                	mv	a3,a5
 304:	0785                	add	a5,a5,1
 306:	fff7c703          	lbu	a4,-1(a5)
 30a:	ff65                	bnez	a4,302 <strlen+0x10>
 30c:	40a6853b          	subw	a0,a3,a0
 310:	2505                	addw	a0,a0,1
    ;
  return n;
}
 312:	6422                	ld	s0,8(sp)
 314:	0141                	add	sp,sp,16
 316:	8082                	ret
  for(n = 0; s[n]; n++)
 318:	4501                	li	a0,0
 31a:	bfe5                	j	312 <strlen+0x20>

000000000000031c <memset>:

void*
memset(void *dst, int c, uint n)
{
 31c:	1141                	add	sp,sp,-16
 31e:	e422                	sd	s0,8(sp)
 320:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 322:	ca19                	beqz	a2,338 <memset+0x1c>
 324:	87aa                	mv	a5,a0
 326:	1602                	sll	a2,a2,0x20
 328:	9201                	srl	a2,a2,0x20
 32a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 32e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 332:	0785                	add	a5,a5,1
 334:	fee79de3          	bne	a5,a4,32e <memset+0x12>
  }
  return dst;
}
 338:	6422                	ld	s0,8(sp)
 33a:	0141                	add	sp,sp,16
 33c:	8082                	ret

000000000000033e <strchr>:

char*
strchr(const char *s, char c)
{
 33e:	1141                	add	sp,sp,-16
 340:	e422                	sd	s0,8(sp)
 342:	0800                	add	s0,sp,16
  for(; *s; s++)
 344:	00054783          	lbu	a5,0(a0)
 348:	cb99                	beqz	a5,35e <strchr+0x20>
    if(*s == c)
 34a:	00f58763          	beq	a1,a5,358 <strchr+0x1a>
  for(; *s; s++)
 34e:	0505                	add	a0,a0,1
 350:	00054783          	lbu	a5,0(a0)
 354:	fbfd                	bnez	a5,34a <strchr+0xc>
      return (char*)s;
  return 0;
 356:	4501                	li	a0,0
}
 358:	6422                	ld	s0,8(sp)
 35a:	0141                	add	sp,sp,16
 35c:	8082                	ret
  return 0;
 35e:	4501                	li	a0,0
 360:	bfe5                	j	358 <strchr+0x1a>

0000000000000362 <gets>:

char*
gets(char *buf, int max)
{
 362:	711d                	add	sp,sp,-96
 364:	ec86                	sd	ra,88(sp)
 366:	e8a2                	sd	s0,80(sp)
 368:	e4a6                	sd	s1,72(sp)
 36a:	e0ca                	sd	s2,64(sp)
 36c:	fc4e                	sd	s3,56(sp)
 36e:	f852                	sd	s4,48(sp)
 370:	f456                	sd	s5,40(sp)
 372:	f05a                	sd	s6,32(sp)
 374:	ec5e                	sd	s7,24(sp)
 376:	1080                	add	s0,sp,96
 378:	8baa                	mv	s7,a0
 37a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 37c:	892a                	mv	s2,a0
 37e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 380:	4aa9                	li	s5,10
 382:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 384:	89a6                	mv	s3,s1
 386:	2485                	addw	s1,s1,1
 388:	0344d863          	bge	s1,s4,3b8 <gets+0x56>
    cc = read(0, &c, 1);
 38c:	4605                	li	a2,1
 38e:	faf40593          	add	a1,s0,-81
 392:	4501                	li	a0,0
 394:	00000097          	auipc	ra,0x0
 398:	19a080e7          	jalr	410(ra) # 52e <read>
    if(cc < 1)
 39c:	00a05e63          	blez	a0,3b8 <gets+0x56>
    buf[i++] = c;
 3a0:	faf44783          	lbu	a5,-81(s0)
 3a4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3a8:	01578763          	beq	a5,s5,3b6 <gets+0x54>
 3ac:	0905                	add	s2,s2,1
 3ae:	fd679be3          	bne	a5,s6,384 <gets+0x22>
    buf[i++] = c;
 3b2:	89a6                	mv	s3,s1
 3b4:	a011                	j	3b8 <gets+0x56>
 3b6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3b8:	99de                	add	s3,s3,s7
 3ba:	00098023          	sb	zero,0(s3)
  return buf;
}
 3be:	855e                	mv	a0,s7
 3c0:	60e6                	ld	ra,88(sp)
 3c2:	6446                	ld	s0,80(sp)
 3c4:	64a6                	ld	s1,72(sp)
 3c6:	6906                	ld	s2,64(sp)
 3c8:	79e2                	ld	s3,56(sp)
 3ca:	7a42                	ld	s4,48(sp)
 3cc:	7aa2                	ld	s5,40(sp)
 3ce:	7b02                	ld	s6,32(sp)
 3d0:	6be2                	ld	s7,24(sp)
 3d2:	6125                	add	sp,sp,96
 3d4:	8082                	ret

00000000000003d6 <stat>:

int
stat(const char *n, struct stat *st)
{
 3d6:	1101                	add	sp,sp,-32
 3d8:	ec06                	sd	ra,24(sp)
 3da:	e822                	sd	s0,16(sp)
 3dc:	e04a                	sd	s2,0(sp)
 3de:	1000                	add	s0,sp,32
 3e0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3e2:	4581                	li	a1,0
 3e4:	00000097          	auipc	ra,0x0
 3e8:	172080e7          	jalr	370(ra) # 556 <open>
  if(fd < 0)
 3ec:	02054663          	bltz	a0,418 <stat+0x42>
 3f0:	e426                	sd	s1,8(sp)
 3f2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3f4:	85ca                	mv	a1,s2
 3f6:	00000097          	auipc	ra,0x0
 3fa:	178080e7          	jalr	376(ra) # 56e <fstat>
 3fe:	892a                	mv	s2,a0
  close(fd);
 400:	8526                	mv	a0,s1
 402:	00000097          	auipc	ra,0x0
 406:	13c080e7          	jalr	316(ra) # 53e <close>
  return r;
 40a:	64a2                	ld	s1,8(sp)
}
 40c:	854a                	mv	a0,s2
 40e:	60e2                	ld	ra,24(sp)
 410:	6442                	ld	s0,16(sp)
 412:	6902                	ld	s2,0(sp)
 414:	6105                	add	sp,sp,32
 416:	8082                	ret
    return -1;
 418:	597d                	li	s2,-1
 41a:	bfcd                	j	40c <stat+0x36>

000000000000041c <atoi>:

int
atoi(const char *s)
{
 41c:	1141                	add	sp,sp,-16
 41e:	e422                	sd	s0,8(sp)
 420:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 422:	00054683          	lbu	a3,0(a0)
 426:	fd06879b          	addw	a5,a3,-48
 42a:	0ff7f793          	zext.b	a5,a5
 42e:	4625                	li	a2,9
 430:	02f66863          	bltu	a2,a5,460 <atoi+0x44>
 434:	872a                	mv	a4,a0
  n = 0;
 436:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 438:	0705                	add	a4,a4,1
 43a:	0025179b          	sllw	a5,a0,0x2
 43e:	9fa9                	addw	a5,a5,a0
 440:	0017979b          	sllw	a5,a5,0x1
 444:	9fb5                	addw	a5,a5,a3
 446:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 44a:	00074683          	lbu	a3,0(a4)
 44e:	fd06879b          	addw	a5,a3,-48
 452:	0ff7f793          	zext.b	a5,a5
 456:	fef671e3          	bgeu	a2,a5,438 <atoi+0x1c>
  return n;
}
 45a:	6422                	ld	s0,8(sp)
 45c:	0141                	add	sp,sp,16
 45e:	8082                	ret
  n = 0;
 460:	4501                	li	a0,0
 462:	bfe5                	j	45a <atoi+0x3e>

0000000000000464 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 464:	1141                	add	sp,sp,-16
 466:	e422                	sd	s0,8(sp)
 468:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 46a:	02b57463          	bgeu	a0,a1,492 <memmove+0x2e>
    while(n-- > 0)
 46e:	00c05f63          	blez	a2,48c <memmove+0x28>
 472:	1602                	sll	a2,a2,0x20
 474:	9201                	srl	a2,a2,0x20
 476:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 47a:	872a                	mv	a4,a0
      *dst++ = *src++;
 47c:	0585                	add	a1,a1,1
 47e:	0705                	add	a4,a4,1
 480:	fff5c683          	lbu	a3,-1(a1)
 484:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 488:	fef71ae3          	bne	a4,a5,47c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 48c:	6422                	ld	s0,8(sp)
 48e:	0141                	add	sp,sp,16
 490:	8082                	ret
    dst += n;
 492:	00c50733          	add	a4,a0,a2
    src += n;
 496:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 498:	fec05ae3          	blez	a2,48c <memmove+0x28>
 49c:	fff6079b          	addw	a5,a2,-1
 4a0:	1782                	sll	a5,a5,0x20
 4a2:	9381                	srl	a5,a5,0x20
 4a4:	fff7c793          	not	a5,a5
 4a8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4aa:	15fd                	add	a1,a1,-1
 4ac:	177d                	add	a4,a4,-1
 4ae:	0005c683          	lbu	a3,0(a1)
 4b2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4b6:	fee79ae3          	bne	a5,a4,4aa <memmove+0x46>
 4ba:	bfc9                	j	48c <memmove+0x28>

00000000000004bc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4bc:	1141                	add	sp,sp,-16
 4be:	e422                	sd	s0,8(sp)
 4c0:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4c2:	ca05                	beqz	a2,4f2 <memcmp+0x36>
 4c4:	fff6069b          	addw	a3,a2,-1
 4c8:	1682                	sll	a3,a3,0x20
 4ca:	9281                	srl	a3,a3,0x20
 4cc:	0685                	add	a3,a3,1
 4ce:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4d0:	00054783          	lbu	a5,0(a0)
 4d4:	0005c703          	lbu	a4,0(a1)
 4d8:	00e79863          	bne	a5,a4,4e8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4dc:	0505                	add	a0,a0,1
    p2++;
 4de:	0585                	add	a1,a1,1
  while (n-- > 0) {
 4e0:	fed518e3          	bne	a0,a3,4d0 <memcmp+0x14>
  }
  return 0;
 4e4:	4501                	li	a0,0
 4e6:	a019                	j	4ec <memcmp+0x30>
      return *p1 - *p2;
 4e8:	40e7853b          	subw	a0,a5,a4
}
 4ec:	6422                	ld	s0,8(sp)
 4ee:	0141                	add	sp,sp,16
 4f0:	8082                	ret
  return 0;
 4f2:	4501                	li	a0,0
 4f4:	bfe5                	j	4ec <memcmp+0x30>

00000000000004f6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4f6:	1141                	add	sp,sp,-16
 4f8:	e406                	sd	ra,8(sp)
 4fa:	e022                	sd	s0,0(sp)
 4fc:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 4fe:	00000097          	auipc	ra,0x0
 502:	f66080e7          	jalr	-154(ra) # 464 <memmove>
}
 506:	60a2                	ld	ra,8(sp)
 508:	6402                	ld	s0,0(sp)
 50a:	0141                	add	sp,sp,16
 50c:	8082                	ret

000000000000050e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 50e:	4885                	li	a7,1
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <exit>:
.global exit
exit:
 li a7, SYS_exit
 516:	4889                	li	a7,2
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <wait>:
.global wait
wait:
 li a7, SYS_wait
 51e:	488d                	li	a7,3
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 526:	4891                	li	a7,4
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <read>:
.global read
read:
 li a7, SYS_read
 52e:	4895                	li	a7,5
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <write>:
.global write
write:
 li a7, SYS_write
 536:	48c1                	li	a7,16
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <close>:
.global close
close:
 li a7, SYS_close
 53e:	48d5                	li	a7,21
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <kill>:
.global kill
kill:
 li a7, SYS_kill
 546:	4899                	li	a7,6
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <exec>:
.global exec
exec:
 li a7, SYS_exec
 54e:	489d                	li	a7,7
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <open>:
.global open
open:
 li a7, SYS_open
 556:	48bd                	li	a7,15
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 55e:	48c5                	li	a7,17
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 566:	48c9                	li	a7,18
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 56e:	48a1                	li	a7,8
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <link>:
.global link
link:
 li a7, SYS_link
 576:	48cd                	li	a7,19
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 57e:	48d1                	li	a7,20
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 586:	48a5                	li	a7,9
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <dup>:
.global dup
dup:
 li a7, SYS_dup
 58e:	48a9                	li	a7,10
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 596:	48ad                	li	a7,11
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 59e:	48b1                	li	a7,12
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5a6:	48b5                	li	a7,13
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5ae:	48b9                	li	a7,14
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 5b6:	48d9                	li	a7,22
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <sematest>:
.global sematest
sematest:
 li a7, SYS_sematest
 5be:	48dd                	li	a7,23
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <rwsematest>:
.global rwsematest
rwsematest:
 li a7, SYS_rwsematest
 5c6:	48e1                	li	a7,24
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5ce:	1101                	add	sp,sp,-32
 5d0:	ec06                	sd	ra,24(sp)
 5d2:	e822                	sd	s0,16(sp)
 5d4:	1000                	add	s0,sp,32
 5d6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5da:	4605                	li	a2,1
 5dc:	fef40593          	add	a1,s0,-17
 5e0:	00000097          	auipc	ra,0x0
 5e4:	f56080e7          	jalr	-170(ra) # 536 <write>
}
 5e8:	60e2                	ld	ra,24(sp)
 5ea:	6442                	ld	s0,16(sp)
 5ec:	6105                	add	sp,sp,32
 5ee:	8082                	ret

00000000000005f0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5f0:	7139                	add	sp,sp,-64
 5f2:	fc06                	sd	ra,56(sp)
 5f4:	f822                	sd	s0,48(sp)
 5f6:	f426                	sd	s1,40(sp)
 5f8:	0080                	add	s0,sp,64
 5fa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5fc:	c299                	beqz	a3,602 <printint+0x12>
 5fe:	0805cb63          	bltz	a1,694 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 602:	2581                	sext.w	a1,a1
  neg = 0;
 604:	4881                	li	a7,0
 606:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 60a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 60c:	2601                	sext.w	a2,a2
 60e:	00000517          	auipc	a0,0x0
 612:	4da50513          	add	a0,a0,1242 # ae8 <digits>
 616:	883a                	mv	a6,a4
 618:	2705                	addw	a4,a4,1
 61a:	02c5f7bb          	remuw	a5,a1,a2
 61e:	1782                	sll	a5,a5,0x20
 620:	9381                	srl	a5,a5,0x20
 622:	97aa                	add	a5,a5,a0
 624:	0007c783          	lbu	a5,0(a5)
 628:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 62c:	0005879b          	sext.w	a5,a1
 630:	02c5d5bb          	divuw	a1,a1,a2
 634:	0685                	add	a3,a3,1
 636:	fec7f0e3          	bgeu	a5,a2,616 <printint+0x26>
  if(neg)
 63a:	00088c63          	beqz	a7,652 <printint+0x62>
    buf[i++] = '-';
 63e:	fd070793          	add	a5,a4,-48
 642:	00878733          	add	a4,a5,s0
 646:	02d00793          	li	a5,45
 64a:	fef70823          	sb	a5,-16(a4)
 64e:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 652:	02e05c63          	blez	a4,68a <printint+0x9a>
 656:	f04a                	sd	s2,32(sp)
 658:	ec4e                	sd	s3,24(sp)
 65a:	fc040793          	add	a5,s0,-64
 65e:	00e78933          	add	s2,a5,a4
 662:	fff78993          	add	s3,a5,-1
 666:	99ba                	add	s3,s3,a4
 668:	377d                	addw	a4,a4,-1
 66a:	1702                	sll	a4,a4,0x20
 66c:	9301                	srl	a4,a4,0x20
 66e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 672:	fff94583          	lbu	a1,-1(s2)
 676:	8526                	mv	a0,s1
 678:	00000097          	auipc	ra,0x0
 67c:	f56080e7          	jalr	-170(ra) # 5ce <putc>
  while(--i >= 0)
 680:	197d                	add	s2,s2,-1
 682:	ff3918e3          	bne	s2,s3,672 <printint+0x82>
 686:	7902                	ld	s2,32(sp)
 688:	69e2                	ld	s3,24(sp)
}
 68a:	70e2                	ld	ra,56(sp)
 68c:	7442                	ld	s0,48(sp)
 68e:	74a2                	ld	s1,40(sp)
 690:	6121                	add	sp,sp,64
 692:	8082                	ret
    x = -xx;
 694:	40b005bb          	negw	a1,a1
    neg = 1;
 698:	4885                	li	a7,1
    x = -xx;
 69a:	b7b5                	j	606 <printint+0x16>

000000000000069c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 69c:	715d                	add	sp,sp,-80
 69e:	e486                	sd	ra,72(sp)
 6a0:	e0a2                	sd	s0,64(sp)
 6a2:	f84a                	sd	s2,48(sp)
 6a4:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6a6:	0005c903          	lbu	s2,0(a1)
 6aa:	1a090a63          	beqz	s2,85e <vprintf+0x1c2>
 6ae:	fc26                	sd	s1,56(sp)
 6b0:	f44e                	sd	s3,40(sp)
 6b2:	f052                	sd	s4,32(sp)
 6b4:	ec56                	sd	s5,24(sp)
 6b6:	e85a                	sd	s6,16(sp)
 6b8:	e45e                	sd	s7,8(sp)
 6ba:	8aaa                	mv	s5,a0
 6bc:	8bb2                	mv	s7,a2
 6be:	00158493          	add	s1,a1,1
  state = 0;
 6c2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6c4:	02500a13          	li	s4,37
 6c8:	4b55                	li	s6,21
 6ca:	a839                	j	6e8 <vprintf+0x4c>
        putc(fd, c);
 6cc:	85ca                	mv	a1,s2
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	efe080e7          	jalr	-258(ra) # 5ce <putc>
 6d8:	a019                	j	6de <vprintf+0x42>
    } else if(state == '%'){
 6da:	01498d63          	beq	s3,s4,6f4 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 6de:	0485                	add	s1,s1,1
 6e0:	fff4c903          	lbu	s2,-1(s1)
 6e4:	16090763          	beqz	s2,852 <vprintf+0x1b6>
    if(state == 0){
 6e8:	fe0999e3          	bnez	s3,6da <vprintf+0x3e>
      if(c == '%'){
 6ec:	ff4910e3          	bne	s2,s4,6cc <vprintf+0x30>
        state = '%';
 6f0:	89d2                	mv	s3,s4
 6f2:	b7f5                	j	6de <vprintf+0x42>
      if(c == 'd'){
 6f4:	13490463          	beq	s2,s4,81c <vprintf+0x180>
 6f8:	f9d9079b          	addw	a5,s2,-99
 6fc:	0ff7f793          	zext.b	a5,a5
 700:	12fb6763          	bltu	s6,a5,82e <vprintf+0x192>
 704:	f9d9079b          	addw	a5,s2,-99
 708:	0ff7f713          	zext.b	a4,a5
 70c:	12eb6163          	bltu	s6,a4,82e <vprintf+0x192>
 710:	00271793          	sll	a5,a4,0x2
 714:	00000717          	auipc	a4,0x0
 718:	37c70713          	add	a4,a4,892 # a90 <malloc+0x142>
 71c:	97ba                	add	a5,a5,a4
 71e:	439c                	lw	a5,0(a5)
 720:	97ba                	add	a5,a5,a4
 722:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 724:	008b8913          	add	s2,s7,8
 728:	4685                	li	a3,1
 72a:	4629                	li	a2,10
 72c:	000ba583          	lw	a1,0(s7)
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	ebe080e7          	jalr	-322(ra) # 5f0 <printint>
 73a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 73c:	4981                	li	s3,0
 73e:	b745                	j	6de <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 740:	008b8913          	add	s2,s7,8
 744:	4681                	li	a3,0
 746:	4629                	li	a2,10
 748:	000ba583          	lw	a1,0(s7)
 74c:	8556                	mv	a0,s5
 74e:	00000097          	auipc	ra,0x0
 752:	ea2080e7          	jalr	-350(ra) # 5f0 <printint>
 756:	8bca                	mv	s7,s2
      state = 0;
 758:	4981                	li	s3,0
 75a:	b751                	j	6de <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 75c:	008b8913          	add	s2,s7,8
 760:	4681                	li	a3,0
 762:	4641                	li	a2,16
 764:	000ba583          	lw	a1,0(s7)
 768:	8556                	mv	a0,s5
 76a:	00000097          	auipc	ra,0x0
 76e:	e86080e7          	jalr	-378(ra) # 5f0 <printint>
 772:	8bca                	mv	s7,s2
      state = 0;
 774:	4981                	li	s3,0
 776:	b7a5                	j	6de <vprintf+0x42>
 778:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 77a:	008b8c13          	add	s8,s7,8
 77e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 782:	03000593          	li	a1,48
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	e46080e7          	jalr	-442(ra) # 5ce <putc>
  putc(fd, 'x');
 790:	07800593          	li	a1,120
 794:	8556                	mv	a0,s5
 796:	00000097          	auipc	ra,0x0
 79a:	e38080e7          	jalr	-456(ra) # 5ce <putc>
 79e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7a0:	00000b97          	auipc	s7,0x0
 7a4:	348b8b93          	add	s7,s7,840 # ae8 <digits>
 7a8:	03c9d793          	srl	a5,s3,0x3c
 7ac:	97de                	add	a5,a5,s7
 7ae:	0007c583          	lbu	a1,0(a5)
 7b2:	8556                	mv	a0,s5
 7b4:	00000097          	auipc	ra,0x0
 7b8:	e1a080e7          	jalr	-486(ra) # 5ce <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7bc:	0992                	sll	s3,s3,0x4
 7be:	397d                	addw	s2,s2,-1
 7c0:	fe0914e3          	bnez	s2,7a8 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 7c4:	8be2                	mv	s7,s8
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	6c02                	ld	s8,0(sp)
 7ca:	bf11                	j	6de <vprintf+0x42>
        s = va_arg(ap, char*);
 7cc:	008b8993          	add	s3,s7,8
 7d0:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 7d4:	02090163          	beqz	s2,7f6 <vprintf+0x15a>
        while(*s != 0){
 7d8:	00094583          	lbu	a1,0(s2)
 7dc:	c9a5                	beqz	a1,84c <vprintf+0x1b0>
          putc(fd, *s);
 7de:	8556                	mv	a0,s5
 7e0:	00000097          	auipc	ra,0x0
 7e4:	dee080e7          	jalr	-530(ra) # 5ce <putc>
          s++;
 7e8:	0905                	add	s2,s2,1
        while(*s != 0){
 7ea:	00094583          	lbu	a1,0(s2)
 7ee:	f9e5                	bnez	a1,7de <vprintf+0x142>
        s = va_arg(ap, char*);
 7f0:	8bce                	mv	s7,s3
      state = 0;
 7f2:	4981                	li	s3,0
 7f4:	b5ed                	j	6de <vprintf+0x42>
          s = "(null)";
 7f6:	00000917          	auipc	s2,0x0
 7fa:	29290913          	add	s2,s2,658 # a88 <malloc+0x13a>
        while(*s != 0){
 7fe:	02800593          	li	a1,40
 802:	bff1                	j	7de <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 804:	008b8913          	add	s2,s7,8
 808:	000bc583          	lbu	a1,0(s7)
 80c:	8556                	mv	a0,s5
 80e:	00000097          	auipc	ra,0x0
 812:	dc0080e7          	jalr	-576(ra) # 5ce <putc>
 816:	8bca                	mv	s7,s2
      state = 0;
 818:	4981                	li	s3,0
 81a:	b5d1                	j	6de <vprintf+0x42>
        putc(fd, c);
 81c:	02500593          	li	a1,37
 820:	8556                	mv	a0,s5
 822:	00000097          	auipc	ra,0x0
 826:	dac080e7          	jalr	-596(ra) # 5ce <putc>
      state = 0;
 82a:	4981                	li	s3,0
 82c:	bd4d                	j	6de <vprintf+0x42>
        putc(fd, '%');
 82e:	02500593          	li	a1,37
 832:	8556                	mv	a0,s5
 834:	00000097          	auipc	ra,0x0
 838:	d9a080e7          	jalr	-614(ra) # 5ce <putc>
        putc(fd, c);
 83c:	85ca                	mv	a1,s2
 83e:	8556                	mv	a0,s5
 840:	00000097          	auipc	ra,0x0
 844:	d8e080e7          	jalr	-626(ra) # 5ce <putc>
      state = 0;
 848:	4981                	li	s3,0
 84a:	bd51                	j	6de <vprintf+0x42>
        s = va_arg(ap, char*);
 84c:	8bce                	mv	s7,s3
      state = 0;
 84e:	4981                	li	s3,0
 850:	b579                	j	6de <vprintf+0x42>
 852:	74e2                	ld	s1,56(sp)
 854:	79a2                	ld	s3,40(sp)
 856:	7a02                	ld	s4,32(sp)
 858:	6ae2                	ld	s5,24(sp)
 85a:	6b42                	ld	s6,16(sp)
 85c:	6ba2                	ld	s7,8(sp)
    }
  }
}
 85e:	60a6                	ld	ra,72(sp)
 860:	6406                	ld	s0,64(sp)
 862:	7942                	ld	s2,48(sp)
 864:	6161                	add	sp,sp,80
 866:	8082                	ret

0000000000000868 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 868:	715d                	add	sp,sp,-80
 86a:	ec06                	sd	ra,24(sp)
 86c:	e822                	sd	s0,16(sp)
 86e:	1000                	add	s0,sp,32
 870:	e010                	sd	a2,0(s0)
 872:	e414                	sd	a3,8(s0)
 874:	e818                	sd	a4,16(s0)
 876:	ec1c                	sd	a5,24(s0)
 878:	03043023          	sd	a6,32(s0)
 87c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 880:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 884:	8622                	mv	a2,s0
 886:	00000097          	auipc	ra,0x0
 88a:	e16080e7          	jalr	-490(ra) # 69c <vprintf>
}
 88e:	60e2                	ld	ra,24(sp)
 890:	6442                	ld	s0,16(sp)
 892:	6161                	add	sp,sp,80
 894:	8082                	ret

0000000000000896 <printf>:

void
printf(const char *fmt, ...)
{
 896:	711d                	add	sp,sp,-96
 898:	ec06                	sd	ra,24(sp)
 89a:	e822                	sd	s0,16(sp)
 89c:	1000                	add	s0,sp,32
 89e:	e40c                	sd	a1,8(s0)
 8a0:	e810                	sd	a2,16(s0)
 8a2:	ec14                	sd	a3,24(s0)
 8a4:	f018                	sd	a4,32(s0)
 8a6:	f41c                	sd	a5,40(s0)
 8a8:	03043823          	sd	a6,48(s0)
 8ac:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8b0:	00840613          	add	a2,s0,8
 8b4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8b8:	85aa                	mv	a1,a0
 8ba:	4505                	li	a0,1
 8bc:	00000097          	auipc	ra,0x0
 8c0:	de0080e7          	jalr	-544(ra) # 69c <vprintf>
}
 8c4:	60e2                	ld	ra,24(sp)
 8c6:	6442                	ld	s0,16(sp)
 8c8:	6125                	add	sp,sp,96
 8ca:	8082                	ret

00000000000008cc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8cc:	1141                	add	sp,sp,-16
 8ce:	e422                	sd	s0,8(sp)
 8d0:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8d2:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8d6:	00000797          	auipc	a5,0x0
 8da:	22a7b783          	ld	a5,554(a5) # b00 <freep>
 8de:	a02d                	j	908 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8e0:	4618                	lw	a4,8(a2)
 8e2:	9f2d                	addw	a4,a4,a1
 8e4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8e8:	6398                	ld	a4,0(a5)
 8ea:	6310                	ld	a2,0(a4)
 8ec:	a83d                	j	92a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8ee:	ff852703          	lw	a4,-8(a0)
 8f2:	9f31                	addw	a4,a4,a2
 8f4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8f6:	ff053683          	ld	a3,-16(a0)
 8fa:	a091                	j	93e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8fc:	6398                	ld	a4,0(a5)
 8fe:	00e7e463          	bltu	a5,a4,906 <free+0x3a>
 902:	00e6ea63          	bltu	a3,a4,916 <free+0x4a>
{
 906:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 908:	fed7fae3          	bgeu	a5,a3,8fc <free+0x30>
 90c:	6398                	ld	a4,0(a5)
 90e:	00e6e463          	bltu	a3,a4,916 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 912:	fee7eae3          	bltu	a5,a4,906 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 916:	ff852583          	lw	a1,-8(a0)
 91a:	6390                	ld	a2,0(a5)
 91c:	02059813          	sll	a6,a1,0x20
 920:	01c85713          	srl	a4,a6,0x1c
 924:	9736                	add	a4,a4,a3
 926:	fae60de3          	beq	a2,a4,8e0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 92a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 92e:	4790                	lw	a2,8(a5)
 930:	02061593          	sll	a1,a2,0x20
 934:	01c5d713          	srl	a4,a1,0x1c
 938:	973e                	add	a4,a4,a5
 93a:	fae68ae3          	beq	a3,a4,8ee <free+0x22>
    p->s.ptr = bp->s.ptr;
 93e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 940:	00000717          	auipc	a4,0x0
 944:	1cf73023          	sd	a5,448(a4) # b00 <freep>
}
 948:	6422                	ld	s0,8(sp)
 94a:	0141                	add	sp,sp,16
 94c:	8082                	ret

000000000000094e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 94e:	7139                	add	sp,sp,-64
 950:	fc06                	sd	ra,56(sp)
 952:	f822                	sd	s0,48(sp)
 954:	f426                	sd	s1,40(sp)
 956:	ec4e                	sd	s3,24(sp)
 958:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 95a:	02051493          	sll	s1,a0,0x20
 95e:	9081                	srl	s1,s1,0x20
 960:	04bd                	add	s1,s1,15
 962:	8091                	srl	s1,s1,0x4
 964:	0014899b          	addw	s3,s1,1
 968:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 96a:	00000517          	auipc	a0,0x0
 96e:	19653503          	ld	a0,406(a0) # b00 <freep>
 972:	c915                	beqz	a0,9a6 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 974:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 976:	4798                	lw	a4,8(a5)
 978:	08977e63          	bgeu	a4,s1,a14 <malloc+0xc6>
 97c:	f04a                	sd	s2,32(sp)
 97e:	e852                	sd	s4,16(sp)
 980:	e456                	sd	s5,8(sp)
 982:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 984:	8a4e                	mv	s4,s3
 986:	0009871b          	sext.w	a4,s3
 98a:	6685                	lui	a3,0x1
 98c:	00d77363          	bgeu	a4,a3,992 <malloc+0x44>
 990:	6a05                	lui	s4,0x1
 992:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 996:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 99a:	00000917          	auipc	s2,0x0
 99e:	16690913          	add	s2,s2,358 # b00 <freep>
  if(p == (char*)-1)
 9a2:	5afd                	li	s5,-1
 9a4:	a091                	j	9e8 <malloc+0x9a>
 9a6:	f04a                	sd	s2,32(sp)
 9a8:	e852                	sd	s4,16(sp)
 9aa:	e456                	sd	s5,8(sp)
 9ac:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9ae:	00000797          	auipc	a5,0x0
 9b2:	55a78793          	add	a5,a5,1370 # f08 <base>
 9b6:	00000717          	auipc	a4,0x0
 9ba:	14f73523          	sd	a5,330(a4) # b00 <freep>
 9be:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9c0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9c4:	b7c1                	j	984 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9c6:	6398                	ld	a4,0(a5)
 9c8:	e118                	sd	a4,0(a0)
 9ca:	a08d                	j	a2c <malloc+0xde>
  hp->s.size = nu;
 9cc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9d0:	0541                	add	a0,a0,16
 9d2:	00000097          	auipc	ra,0x0
 9d6:	efa080e7          	jalr	-262(ra) # 8cc <free>
  return freep;
 9da:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9de:	c13d                	beqz	a0,a44 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e2:	4798                	lw	a4,8(a5)
 9e4:	02977463          	bgeu	a4,s1,a0c <malloc+0xbe>
    if(p == freep)
 9e8:	00093703          	ld	a4,0(s2)
 9ec:	853e                	mv	a0,a5
 9ee:	fef719e3          	bne	a4,a5,9e0 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 9f2:	8552                	mv	a0,s4
 9f4:	00000097          	auipc	ra,0x0
 9f8:	baa080e7          	jalr	-1110(ra) # 59e <sbrk>
  if(p == (char*)-1)
 9fc:	fd5518e3          	bne	a0,s5,9cc <malloc+0x7e>
        return 0;
 a00:	4501                	li	a0,0
 a02:	7902                	ld	s2,32(sp)
 a04:	6a42                	ld	s4,16(sp)
 a06:	6aa2                	ld	s5,8(sp)
 a08:	6b02                	ld	s6,0(sp)
 a0a:	a03d                	j	a38 <malloc+0xea>
 a0c:	7902                	ld	s2,32(sp)
 a0e:	6a42                	ld	s4,16(sp)
 a10:	6aa2                	ld	s5,8(sp)
 a12:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a14:	fae489e3          	beq	s1,a4,9c6 <malloc+0x78>
        p->s.size -= nunits;
 a18:	4137073b          	subw	a4,a4,s3
 a1c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a1e:	02071693          	sll	a3,a4,0x20
 a22:	01c6d713          	srl	a4,a3,0x1c
 a26:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a28:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a2c:	00000717          	auipc	a4,0x0
 a30:	0ca73a23          	sd	a0,212(a4) # b00 <freep>
      return (void*)(p + 1);
 a34:	01078513          	add	a0,a5,16
  }
}
 a38:	70e2                	ld	ra,56(sp)
 a3a:	7442                	ld	s0,48(sp)
 a3c:	74a2                	ld	s1,40(sp)
 a3e:	69e2                	ld	s3,24(sp)
 a40:	6121                	add	sp,sp,64
 a42:	8082                	ret
 a44:	7902                	ld	s2,32(sp)
 a46:	6a42                	ld	s4,16(sp)
 a48:	6aa2                	ld	s5,8(sp)
 a4a:	6b02                	ld	s6,0(sp)
 a4c:	b7f5                	j	a38 <malloc+0xea>
