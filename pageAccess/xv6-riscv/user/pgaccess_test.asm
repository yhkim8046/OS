
user/_pgaccess_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

#define PGSIZE 4096

int main() {
   0:	7179                	add	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	add	s0,sp,48
    char *buf;
    unsigned int abits;
    printf("Page access test starting\n");
   a:	00001517          	auipc	a0,0x1
   e:	8be50513          	add	a0,a0,-1858 # 8c8 <malloc+0x104>
  12:	00000097          	auipc	ra,0x0
  16:	6fa080e7          	jalr	1786(ra) # 70c <printf>

    buf = malloc(32 * PGSIZE);   // allocate 32 pages of physical memory
  1a:	00020537          	lui	a0,0x20
  1e:	00000097          	auipc	ra,0x0
  22:	7a6080e7          	jalr	1958(ra) # 7c4 <malloc>
  26:	84aa                	mv	s1,a0
    if (pageAccess(buf, 32, &abits) < 0) {   // Call the system call
  28:	fdc40613          	add	a2,s0,-36
  2c:	02000593          	li	a1,32
  30:	00000097          	auipc	ra,0x0
  34:	40c080e7          	jalr	1036(ra) # 43c <pageAccess>
  38:	08054f63          	bltz	a0,d6 <main+0xd6>
        free(buf);
        exit(1);
    }

    // Initially, abits should be zero since no page has been accessed
    printf("Initial page access bitmap: %x\n", abits);
  3c:	fdc42583          	lw	a1,-36(s0)
  40:	00001517          	auipc	a0,0x1
  44:	8c050513          	add	a0,a0,-1856 # 900 <malloc+0x13c>
  48:	00000097          	auipc	ra,0x0
  4c:	6c4080e7          	jalr	1732(ra) # 70c <printf>

    // Access some pages
    buf[PGSIZE * 1] += 1;  // Access page 1
  50:	6785                	lui	a5,0x1
  52:	97a6                	add	a5,a5,s1
  54:	0007c703          	lbu	a4,0(a5) # 1000 <__BSS_END__+0x5e0>
  58:	2705                	addw	a4,a4,1
  5a:	00e78023          	sb	a4,0(a5)
    buf[PGSIZE * 2] += 1;  // Access page 2
  5e:	6789                	lui	a5,0x2
  60:	97a6                	add	a5,a5,s1
  62:	0007c703          	lbu	a4,0(a5) # 2000 <__global_pointer$+0xdff>
  66:	2705                	addw	a4,a4,1
  68:	00e78023          	sb	a4,0(a5)
    buf[PGSIZE * 30] += 1; // Access page 30
  6c:	67f9                	lui	a5,0x1e
  6e:	97a6                	add	a5,a5,s1
  70:	0007c703          	lbu	a4,0(a5) # 1e000 <__global_pointer$+0x1cdff>
  74:	2705                	addw	a4,a4,1
  76:	00e78023          	sb	a4,0(a5)

    // Call pageAccess again to check the accessed pages
    if (pageAccess(buf, 32, &abits) < 0) {
  7a:	fdc40613          	add	a2,s0,-36
  7e:	02000593          	li	a1,32
  82:	8526                	mv	a0,s1
  84:	00000097          	auipc	ra,0x0
  88:	3b8080e7          	jalr	952(ra) # 43c <pageAccess>
  8c:	06054763          	bltz	a0,fa <main+0xfa>
        printf("pageAccess failed\n");
        free(buf);
        exit(1);
    }

    printf("Page access bitmap after access: %x\n", abits);
  90:	fdc42583          	lw	a1,-36(s0)
  94:	00001517          	auipc	a0,0x1
  98:	88c50513          	add	a0,a0,-1908 # 920 <malloc+0x15c>
  9c:	00000097          	auipc	ra,0x0
  a0:	670080e7          	jalr	1648(ra) # 70c <printf>

    // Check if the bitmap corresponds to pages 1, 2, and 30 being accessed
    if (abits != ((1 << 1) | (1 << 2) | (1 << 30))) {
  a4:	fdc42703          	lw	a4,-36(s0)
  a8:	400007b7          	lui	a5,0x40000
  ac:	0799                	add	a5,a5,6 # 40000006 <__global_pointer$+0x3fffee05>
  ae:	06f70863          	beq	a4,a5,11e <main+0x11e>
        printf("Incorrect access bits set\n");
  b2:	00001517          	auipc	a0,0x1
  b6:	89650513          	add	a0,a0,-1898 # 948 <malloc+0x184>
  ba:	00000097          	auipc	ra,0x0
  be:	652080e7          	jalr	1618(ra) # 70c <printf>
    } else {
        printf("pageAccess is working correctly\n");
    }

    free(buf);
  c2:	8526                	mv	a0,s1
  c4:	00000097          	auipc	ra,0x0
  c8:	67e080e7          	jalr	1662(ra) # 742 <free>
    exit(0);
  cc:	4501                	li	a0,0
  ce:	00000097          	auipc	ra,0x0
  d2:	2ce080e7          	jalr	718(ra) # 39c <exit>
        printf("pageAccess failed\n");
  d6:	00001517          	auipc	a0,0x1
  da:	81250513          	add	a0,a0,-2030 # 8e8 <malloc+0x124>
  de:	00000097          	auipc	ra,0x0
  e2:	62e080e7          	jalr	1582(ra) # 70c <printf>
        free(buf);
  e6:	8526                	mv	a0,s1
  e8:	00000097          	auipc	ra,0x0
  ec:	65a080e7          	jalr	1626(ra) # 742 <free>
        exit(1);
  f0:	4505                	li	a0,1
  f2:	00000097          	auipc	ra,0x0
  f6:	2aa080e7          	jalr	682(ra) # 39c <exit>
        printf("pageAccess failed\n");
  fa:	00000517          	auipc	a0,0x0
  fe:	7ee50513          	add	a0,a0,2030 # 8e8 <malloc+0x124>
 102:	00000097          	auipc	ra,0x0
 106:	60a080e7          	jalr	1546(ra) # 70c <printf>
        free(buf);
 10a:	8526                	mv	a0,s1
 10c:	00000097          	auipc	ra,0x0
 110:	636080e7          	jalr	1590(ra) # 742 <free>
        exit(1);
 114:	4505                	li	a0,1
 116:	00000097          	auipc	ra,0x0
 11a:	286080e7          	jalr	646(ra) # 39c <exit>
        printf("pageAccess is working correctly\n");
 11e:	00001517          	auipc	a0,0x1
 122:	84a50513          	add	a0,a0,-1974 # 968 <malloc+0x1a4>
 126:	00000097          	auipc	ra,0x0
 12a:	5e6080e7          	jalr	1510(ra) # 70c <printf>
 12e:	bf51                	j	c2 <main+0xc2>

0000000000000130 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 130:	1141                	add	sp,sp,-16
 132:	e422                	sd	s0,8(sp)
 134:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 136:	87aa                	mv	a5,a0
 138:	0585                	add	a1,a1,1
 13a:	0785                	add	a5,a5,1
 13c:	fff5c703          	lbu	a4,-1(a1)
 140:	fee78fa3          	sb	a4,-1(a5)
 144:	fb75                	bnez	a4,138 <strcpy+0x8>
    ;
  return os;
}
 146:	6422                	ld	s0,8(sp)
 148:	0141                	add	sp,sp,16
 14a:	8082                	ret

000000000000014c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 14c:	1141                	add	sp,sp,-16
 14e:	e422                	sd	s0,8(sp)
 150:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 152:	00054783          	lbu	a5,0(a0)
 156:	cb91                	beqz	a5,16a <strcmp+0x1e>
 158:	0005c703          	lbu	a4,0(a1)
 15c:	00f71763          	bne	a4,a5,16a <strcmp+0x1e>
    p++, q++;
 160:	0505                	add	a0,a0,1
 162:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 164:	00054783          	lbu	a5,0(a0)
 168:	fbe5                	bnez	a5,158 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 16a:	0005c503          	lbu	a0,0(a1)
}
 16e:	40a7853b          	subw	a0,a5,a0
 172:	6422                	ld	s0,8(sp)
 174:	0141                	add	sp,sp,16
 176:	8082                	ret

0000000000000178 <strlen>:

uint
strlen(const char *s)
{
 178:	1141                	add	sp,sp,-16
 17a:	e422                	sd	s0,8(sp)
 17c:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 17e:	00054783          	lbu	a5,0(a0)
 182:	cf91                	beqz	a5,19e <strlen+0x26>
 184:	0505                	add	a0,a0,1
 186:	87aa                	mv	a5,a0
 188:	86be                	mv	a3,a5
 18a:	0785                	add	a5,a5,1
 18c:	fff7c703          	lbu	a4,-1(a5)
 190:	ff65                	bnez	a4,188 <strlen+0x10>
 192:	40a6853b          	subw	a0,a3,a0
 196:	2505                	addw	a0,a0,1
    ;
  return n;
}
 198:	6422                	ld	s0,8(sp)
 19a:	0141                	add	sp,sp,16
 19c:	8082                	ret
  for(n = 0; s[n]; n++)
 19e:	4501                	li	a0,0
 1a0:	bfe5                	j	198 <strlen+0x20>

00000000000001a2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a2:	1141                	add	sp,sp,-16
 1a4:	e422                	sd	s0,8(sp)
 1a6:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1a8:	ca19                	beqz	a2,1be <memset+0x1c>
 1aa:	87aa                	mv	a5,a0
 1ac:	1602                	sll	a2,a2,0x20
 1ae:	9201                	srl	a2,a2,0x20
 1b0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1b4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1b8:	0785                	add	a5,a5,1
 1ba:	fee79de3          	bne	a5,a4,1b4 <memset+0x12>
  }
  return dst;
}
 1be:	6422                	ld	s0,8(sp)
 1c0:	0141                	add	sp,sp,16
 1c2:	8082                	ret

00000000000001c4 <strchr>:

char*
strchr(const char *s, char c)
{
 1c4:	1141                	add	sp,sp,-16
 1c6:	e422                	sd	s0,8(sp)
 1c8:	0800                	add	s0,sp,16
  for(; *s; s++)
 1ca:	00054783          	lbu	a5,0(a0)
 1ce:	cb99                	beqz	a5,1e4 <strchr+0x20>
    if(*s == c)
 1d0:	00f58763          	beq	a1,a5,1de <strchr+0x1a>
  for(; *s; s++)
 1d4:	0505                	add	a0,a0,1
 1d6:	00054783          	lbu	a5,0(a0)
 1da:	fbfd                	bnez	a5,1d0 <strchr+0xc>
      return (char*)s;
  return 0;
 1dc:	4501                	li	a0,0
}
 1de:	6422                	ld	s0,8(sp)
 1e0:	0141                	add	sp,sp,16
 1e2:	8082                	ret
  return 0;
 1e4:	4501                	li	a0,0
 1e6:	bfe5                	j	1de <strchr+0x1a>

00000000000001e8 <gets>:

char*
gets(char *buf, int max)
{
 1e8:	711d                	add	sp,sp,-96
 1ea:	ec86                	sd	ra,88(sp)
 1ec:	e8a2                	sd	s0,80(sp)
 1ee:	e4a6                	sd	s1,72(sp)
 1f0:	e0ca                	sd	s2,64(sp)
 1f2:	fc4e                	sd	s3,56(sp)
 1f4:	f852                	sd	s4,48(sp)
 1f6:	f456                	sd	s5,40(sp)
 1f8:	f05a                	sd	s6,32(sp)
 1fa:	ec5e                	sd	s7,24(sp)
 1fc:	1080                	add	s0,sp,96
 1fe:	8baa                	mv	s7,a0
 200:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 202:	892a                	mv	s2,a0
 204:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 206:	4aa9                	li	s5,10
 208:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 20a:	89a6                	mv	s3,s1
 20c:	2485                	addw	s1,s1,1
 20e:	0344d863          	bge	s1,s4,23e <gets+0x56>
    cc = read(0, &c, 1);
 212:	4605                	li	a2,1
 214:	faf40593          	add	a1,s0,-81
 218:	4501                	li	a0,0
 21a:	00000097          	auipc	ra,0x0
 21e:	19a080e7          	jalr	410(ra) # 3b4 <read>
    if(cc < 1)
 222:	00a05e63          	blez	a0,23e <gets+0x56>
    buf[i++] = c;
 226:	faf44783          	lbu	a5,-81(s0)
 22a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 22e:	01578763          	beq	a5,s5,23c <gets+0x54>
 232:	0905                	add	s2,s2,1
 234:	fd679be3          	bne	a5,s6,20a <gets+0x22>
    buf[i++] = c;
 238:	89a6                	mv	s3,s1
 23a:	a011                	j	23e <gets+0x56>
 23c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 23e:	99de                	add	s3,s3,s7
 240:	00098023          	sb	zero,0(s3)
  return buf;
}
 244:	855e                	mv	a0,s7
 246:	60e6                	ld	ra,88(sp)
 248:	6446                	ld	s0,80(sp)
 24a:	64a6                	ld	s1,72(sp)
 24c:	6906                	ld	s2,64(sp)
 24e:	79e2                	ld	s3,56(sp)
 250:	7a42                	ld	s4,48(sp)
 252:	7aa2                	ld	s5,40(sp)
 254:	7b02                	ld	s6,32(sp)
 256:	6be2                	ld	s7,24(sp)
 258:	6125                	add	sp,sp,96
 25a:	8082                	ret

000000000000025c <stat>:

int
stat(const char *n, struct stat *st)
{
 25c:	1101                	add	sp,sp,-32
 25e:	ec06                	sd	ra,24(sp)
 260:	e822                	sd	s0,16(sp)
 262:	e04a                	sd	s2,0(sp)
 264:	1000                	add	s0,sp,32
 266:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 268:	4581                	li	a1,0
 26a:	00000097          	auipc	ra,0x0
 26e:	172080e7          	jalr	370(ra) # 3dc <open>
  if(fd < 0)
 272:	02054663          	bltz	a0,29e <stat+0x42>
 276:	e426                	sd	s1,8(sp)
 278:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 27a:	85ca                	mv	a1,s2
 27c:	00000097          	auipc	ra,0x0
 280:	178080e7          	jalr	376(ra) # 3f4 <fstat>
 284:	892a                	mv	s2,a0
  close(fd);
 286:	8526                	mv	a0,s1
 288:	00000097          	auipc	ra,0x0
 28c:	13c080e7          	jalr	316(ra) # 3c4 <close>
  return r;
 290:	64a2                	ld	s1,8(sp)
}
 292:	854a                	mv	a0,s2
 294:	60e2                	ld	ra,24(sp)
 296:	6442                	ld	s0,16(sp)
 298:	6902                	ld	s2,0(sp)
 29a:	6105                	add	sp,sp,32
 29c:	8082                	ret
    return -1;
 29e:	597d                	li	s2,-1
 2a0:	bfcd                	j	292 <stat+0x36>

00000000000002a2 <atoi>:

int
atoi(const char *s)
{
 2a2:	1141                	add	sp,sp,-16
 2a4:	e422                	sd	s0,8(sp)
 2a6:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2a8:	00054683          	lbu	a3,0(a0)
 2ac:	fd06879b          	addw	a5,a3,-48
 2b0:	0ff7f793          	zext.b	a5,a5
 2b4:	4625                	li	a2,9
 2b6:	02f66863          	bltu	a2,a5,2e6 <atoi+0x44>
 2ba:	872a                	mv	a4,a0
  n = 0;
 2bc:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2be:	0705                	add	a4,a4,1
 2c0:	0025179b          	sllw	a5,a0,0x2
 2c4:	9fa9                	addw	a5,a5,a0
 2c6:	0017979b          	sllw	a5,a5,0x1
 2ca:	9fb5                	addw	a5,a5,a3
 2cc:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2d0:	00074683          	lbu	a3,0(a4)
 2d4:	fd06879b          	addw	a5,a3,-48
 2d8:	0ff7f793          	zext.b	a5,a5
 2dc:	fef671e3          	bgeu	a2,a5,2be <atoi+0x1c>
  return n;
}
 2e0:	6422                	ld	s0,8(sp)
 2e2:	0141                	add	sp,sp,16
 2e4:	8082                	ret
  n = 0;
 2e6:	4501                	li	a0,0
 2e8:	bfe5                	j	2e0 <atoi+0x3e>

00000000000002ea <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ea:	1141                	add	sp,sp,-16
 2ec:	e422                	sd	s0,8(sp)
 2ee:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2f0:	02b57463          	bgeu	a0,a1,318 <memmove+0x2e>
    while(n-- > 0)
 2f4:	00c05f63          	blez	a2,312 <memmove+0x28>
 2f8:	1602                	sll	a2,a2,0x20
 2fa:	9201                	srl	a2,a2,0x20
 2fc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 300:	872a                	mv	a4,a0
      *dst++ = *src++;
 302:	0585                	add	a1,a1,1
 304:	0705                	add	a4,a4,1
 306:	fff5c683          	lbu	a3,-1(a1)
 30a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 30e:	fef71ae3          	bne	a4,a5,302 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 312:	6422                	ld	s0,8(sp)
 314:	0141                	add	sp,sp,16
 316:	8082                	ret
    dst += n;
 318:	00c50733          	add	a4,a0,a2
    src += n;
 31c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 31e:	fec05ae3          	blez	a2,312 <memmove+0x28>
 322:	fff6079b          	addw	a5,a2,-1
 326:	1782                	sll	a5,a5,0x20
 328:	9381                	srl	a5,a5,0x20
 32a:	fff7c793          	not	a5,a5
 32e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 330:	15fd                	add	a1,a1,-1
 332:	177d                	add	a4,a4,-1
 334:	0005c683          	lbu	a3,0(a1)
 338:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 33c:	fee79ae3          	bne	a5,a4,330 <memmove+0x46>
 340:	bfc9                	j	312 <memmove+0x28>

0000000000000342 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 342:	1141                	add	sp,sp,-16
 344:	e422                	sd	s0,8(sp)
 346:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 348:	ca05                	beqz	a2,378 <memcmp+0x36>
 34a:	fff6069b          	addw	a3,a2,-1
 34e:	1682                	sll	a3,a3,0x20
 350:	9281                	srl	a3,a3,0x20
 352:	0685                	add	a3,a3,1
 354:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 356:	00054783          	lbu	a5,0(a0)
 35a:	0005c703          	lbu	a4,0(a1)
 35e:	00e79863          	bne	a5,a4,36e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 362:	0505                	add	a0,a0,1
    p2++;
 364:	0585                	add	a1,a1,1
  while (n-- > 0) {
 366:	fed518e3          	bne	a0,a3,356 <memcmp+0x14>
  }
  return 0;
 36a:	4501                	li	a0,0
 36c:	a019                	j	372 <memcmp+0x30>
      return *p1 - *p2;
 36e:	40e7853b          	subw	a0,a5,a4
}
 372:	6422                	ld	s0,8(sp)
 374:	0141                	add	sp,sp,16
 376:	8082                	ret
  return 0;
 378:	4501                	li	a0,0
 37a:	bfe5                	j	372 <memcmp+0x30>

000000000000037c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 37c:	1141                	add	sp,sp,-16
 37e:	e406                	sd	ra,8(sp)
 380:	e022                	sd	s0,0(sp)
 382:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 384:	00000097          	auipc	ra,0x0
 388:	f66080e7          	jalr	-154(ra) # 2ea <memmove>
}
 38c:	60a2                	ld	ra,8(sp)
 38e:	6402                	ld	s0,0(sp)
 390:	0141                	add	sp,sp,16
 392:	8082                	ret

0000000000000394 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 394:	4885                	li	a7,1
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <exit>:
.global exit
exit:
 li a7, SYS_exit
 39c:	4889                	li	a7,2
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a4:	488d                	li	a7,3
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ac:	4891                	li	a7,4
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <read>:
.global read
read:
 li a7, SYS_read
 3b4:	4895                	li	a7,5
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <write>:
.global write
write:
 li a7, SYS_write
 3bc:	48c1                	li	a7,16
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <close>:
.global close
close:
 li a7, SYS_close
 3c4:	48d5                	li	a7,21
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3cc:	4899                	li	a7,6
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d4:	489d                	li	a7,7
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <open>:
.global open
open:
 li a7, SYS_open
 3dc:	48bd                	li	a7,15
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e4:	48c5                	li	a7,17
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ec:	48c9                	li	a7,18
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f4:	48a1                	li	a7,8
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <link>:
.global link
link:
 li a7, SYS_link
 3fc:	48cd                	li	a7,19
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 404:	48d1                	li	a7,20
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 40c:	48a5                	li	a7,9
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <dup>:
.global dup
dup:
 li a7, SYS_dup
 414:	48a9                	li	a7,10
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 41c:	48ad                	li	a7,11
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 424:	48b1                	li	a7,12
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 42c:	48b5                	li	a7,13
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 434:	48b9                	li	a7,14
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <pageAccess>:
.global pageAccess
pageAccess:
 li a7, SYS_pageAccess
 43c:	48d9                	li	a7,22
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 444:	1101                	add	sp,sp,-32
 446:	ec06                	sd	ra,24(sp)
 448:	e822                	sd	s0,16(sp)
 44a:	1000                	add	s0,sp,32
 44c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 450:	4605                	li	a2,1
 452:	fef40593          	add	a1,s0,-17
 456:	00000097          	auipc	ra,0x0
 45a:	f66080e7          	jalr	-154(ra) # 3bc <write>
}
 45e:	60e2                	ld	ra,24(sp)
 460:	6442                	ld	s0,16(sp)
 462:	6105                	add	sp,sp,32
 464:	8082                	ret

0000000000000466 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 466:	7139                	add	sp,sp,-64
 468:	fc06                	sd	ra,56(sp)
 46a:	f822                	sd	s0,48(sp)
 46c:	f426                	sd	s1,40(sp)
 46e:	0080                	add	s0,sp,64
 470:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 472:	c299                	beqz	a3,478 <printint+0x12>
 474:	0805cb63          	bltz	a1,50a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 478:	2581                	sext.w	a1,a1
  neg = 0;
 47a:	4881                	li	a7,0
 47c:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 480:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 482:	2601                	sext.w	a2,a2
 484:	00000517          	auipc	a0,0x0
 488:	56c50513          	add	a0,a0,1388 # 9f0 <digits>
 48c:	883a                	mv	a6,a4
 48e:	2705                	addw	a4,a4,1
 490:	02c5f7bb          	remuw	a5,a1,a2
 494:	1782                	sll	a5,a5,0x20
 496:	9381                	srl	a5,a5,0x20
 498:	97aa                	add	a5,a5,a0
 49a:	0007c783          	lbu	a5,0(a5)
 49e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4a2:	0005879b          	sext.w	a5,a1
 4a6:	02c5d5bb          	divuw	a1,a1,a2
 4aa:	0685                	add	a3,a3,1
 4ac:	fec7f0e3          	bgeu	a5,a2,48c <printint+0x26>
  if(neg)
 4b0:	00088c63          	beqz	a7,4c8 <printint+0x62>
    buf[i++] = '-';
 4b4:	fd070793          	add	a5,a4,-48
 4b8:	00878733          	add	a4,a5,s0
 4bc:	02d00793          	li	a5,45
 4c0:	fef70823          	sb	a5,-16(a4)
 4c4:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 4c8:	02e05c63          	blez	a4,500 <printint+0x9a>
 4cc:	f04a                	sd	s2,32(sp)
 4ce:	ec4e                	sd	s3,24(sp)
 4d0:	fc040793          	add	a5,s0,-64
 4d4:	00e78933          	add	s2,a5,a4
 4d8:	fff78993          	add	s3,a5,-1
 4dc:	99ba                	add	s3,s3,a4
 4de:	377d                	addw	a4,a4,-1
 4e0:	1702                	sll	a4,a4,0x20
 4e2:	9301                	srl	a4,a4,0x20
 4e4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4e8:	fff94583          	lbu	a1,-1(s2)
 4ec:	8526                	mv	a0,s1
 4ee:	00000097          	auipc	ra,0x0
 4f2:	f56080e7          	jalr	-170(ra) # 444 <putc>
  while(--i >= 0)
 4f6:	197d                	add	s2,s2,-1
 4f8:	ff3918e3          	bne	s2,s3,4e8 <printint+0x82>
 4fc:	7902                	ld	s2,32(sp)
 4fe:	69e2                	ld	s3,24(sp)
}
 500:	70e2                	ld	ra,56(sp)
 502:	7442                	ld	s0,48(sp)
 504:	74a2                	ld	s1,40(sp)
 506:	6121                	add	sp,sp,64
 508:	8082                	ret
    x = -xx;
 50a:	40b005bb          	negw	a1,a1
    neg = 1;
 50e:	4885                	li	a7,1
    x = -xx;
 510:	b7b5                	j	47c <printint+0x16>

0000000000000512 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 512:	715d                	add	sp,sp,-80
 514:	e486                	sd	ra,72(sp)
 516:	e0a2                	sd	s0,64(sp)
 518:	f84a                	sd	s2,48(sp)
 51a:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 51c:	0005c903          	lbu	s2,0(a1)
 520:	1a090a63          	beqz	s2,6d4 <vprintf+0x1c2>
 524:	fc26                	sd	s1,56(sp)
 526:	f44e                	sd	s3,40(sp)
 528:	f052                	sd	s4,32(sp)
 52a:	ec56                	sd	s5,24(sp)
 52c:	e85a                	sd	s6,16(sp)
 52e:	e45e                	sd	s7,8(sp)
 530:	8aaa                	mv	s5,a0
 532:	8bb2                	mv	s7,a2
 534:	00158493          	add	s1,a1,1
  state = 0;
 538:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 53a:	02500a13          	li	s4,37
 53e:	4b55                	li	s6,21
 540:	a839                	j	55e <vprintf+0x4c>
        putc(fd, c);
 542:	85ca                	mv	a1,s2
 544:	8556                	mv	a0,s5
 546:	00000097          	auipc	ra,0x0
 54a:	efe080e7          	jalr	-258(ra) # 444 <putc>
 54e:	a019                	j	554 <vprintf+0x42>
    } else if(state == '%'){
 550:	01498d63          	beq	s3,s4,56a <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 554:	0485                	add	s1,s1,1
 556:	fff4c903          	lbu	s2,-1(s1)
 55a:	16090763          	beqz	s2,6c8 <vprintf+0x1b6>
    if(state == 0){
 55e:	fe0999e3          	bnez	s3,550 <vprintf+0x3e>
      if(c == '%'){
 562:	ff4910e3          	bne	s2,s4,542 <vprintf+0x30>
        state = '%';
 566:	89d2                	mv	s3,s4
 568:	b7f5                	j	554 <vprintf+0x42>
      if(c == 'd'){
 56a:	13490463          	beq	s2,s4,692 <vprintf+0x180>
 56e:	f9d9079b          	addw	a5,s2,-99
 572:	0ff7f793          	zext.b	a5,a5
 576:	12fb6763          	bltu	s6,a5,6a4 <vprintf+0x192>
 57a:	f9d9079b          	addw	a5,s2,-99
 57e:	0ff7f713          	zext.b	a4,a5
 582:	12eb6163          	bltu	s6,a4,6a4 <vprintf+0x192>
 586:	00271793          	sll	a5,a4,0x2
 58a:	00000717          	auipc	a4,0x0
 58e:	40e70713          	add	a4,a4,1038 # 998 <malloc+0x1d4>
 592:	97ba                	add	a5,a5,a4
 594:	439c                	lw	a5,0(a5)
 596:	97ba                	add	a5,a5,a4
 598:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 59a:	008b8913          	add	s2,s7,8
 59e:	4685                	li	a3,1
 5a0:	4629                	li	a2,10
 5a2:	000ba583          	lw	a1,0(s7)
 5a6:	8556                	mv	a0,s5
 5a8:	00000097          	auipc	ra,0x0
 5ac:	ebe080e7          	jalr	-322(ra) # 466 <printint>
 5b0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5b2:	4981                	li	s3,0
 5b4:	b745                	j	554 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b6:	008b8913          	add	s2,s7,8
 5ba:	4681                	li	a3,0
 5bc:	4629                	li	a2,10
 5be:	000ba583          	lw	a1,0(s7)
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	ea2080e7          	jalr	-350(ra) # 466 <printint>
 5cc:	8bca                	mv	s7,s2
      state = 0;
 5ce:	4981                	li	s3,0
 5d0:	b751                	j	554 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 5d2:	008b8913          	add	s2,s7,8
 5d6:	4681                	li	a3,0
 5d8:	4641                	li	a2,16
 5da:	000ba583          	lw	a1,0(s7)
 5de:	8556                	mv	a0,s5
 5e0:	00000097          	auipc	ra,0x0
 5e4:	e86080e7          	jalr	-378(ra) # 466 <printint>
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b7a5                	j	554 <vprintf+0x42>
 5ee:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5f0:	008b8c13          	add	s8,s7,8
 5f4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5f8:	03000593          	li	a1,48
 5fc:	8556                	mv	a0,s5
 5fe:	00000097          	auipc	ra,0x0
 602:	e46080e7          	jalr	-442(ra) # 444 <putc>
  putc(fd, 'x');
 606:	07800593          	li	a1,120
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	e38080e7          	jalr	-456(ra) # 444 <putc>
 614:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 616:	00000b97          	auipc	s7,0x0
 61a:	3dab8b93          	add	s7,s7,986 # 9f0 <digits>
 61e:	03c9d793          	srl	a5,s3,0x3c
 622:	97de                	add	a5,a5,s7
 624:	0007c583          	lbu	a1,0(a5)
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	e1a080e7          	jalr	-486(ra) # 444 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 632:	0992                	sll	s3,s3,0x4
 634:	397d                	addw	s2,s2,-1
 636:	fe0914e3          	bnez	s2,61e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 63a:	8be2                	mv	s7,s8
      state = 0;
 63c:	4981                	li	s3,0
 63e:	6c02                	ld	s8,0(sp)
 640:	bf11                	j	554 <vprintf+0x42>
        s = va_arg(ap, char*);
 642:	008b8993          	add	s3,s7,8
 646:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 64a:	02090163          	beqz	s2,66c <vprintf+0x15a>
        while(*s != 0){
 64e:	00094583          	lbu	a1,0(s2)
 652:	c9a5                	beqz	a1,6c2 <vprintf+0x1b0>
          putc(fd, *s);
 654:	8556                	mv	a0,s5
 656:	00000097          	auipc	ra,0x0
 65a:	dee080e7          	jalr	-530(ra) # 444 <putc>
          s++;
 65e:	0905                	add	s2,s2,1
        while(*s != 0){
 660:	00094583          	lbu	a1,0(s2)
 664:	f9e5                	bnez	a1,654 <vprintf+0x142>
        s = va_arg(ap, char*);
 666:	8bce                	mv	s7,s3
      state = 0;
 668:	4981                	li	s3,0
 66a:	b5ed                	j	554 <vprintf+0x42>
          s = "(null)";
 66c:	00000917          	auipc	s2,0x0
 670:	32490913          	add	s2,s2,804 # 990 <malloc+0x1cc>
        while(*s != 0){
 674:	02800593          	li	a1,40
 678:	bff1                	j	654 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 67a:	008b8913          	add	s2,s7,8
 67e:	000bc583          	lbu	a1,0(s7)
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	dc0080e7          	jalr	-576(ra) # 444 <putc>
 68c:	8bca                	mv	s7,s2
      state = 0;
 68e:	4981                	li	s3,0
 690:	b5d1                	j	554 <vprintf+0x42>
        putc(fd, c);
 692:	02500593          	li	a1,37
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	dac080e7          	jalr	-596(ra) # 444 <putc>
      state = 0;
 6a0:	4981                	li	s3,0
 6a2:	bd4d                	j	554 <vprintf+0x42>
        putc(fd, '%');
 6a4:	02500593          	li	a1,37
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	d9a080e7          	jalr	-614(ra) # 444 <putc>
        putc(fd, c);
 6b2:	85ca                	mv	a1,s2
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	d8e080e7          	jalr	-626(ra) # 444 <putc>
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	bd51                	j	554 <vprintf+0x42>
        s = va_arg(ap, char*);
 6c2:	8bce                	mv	s7,s3
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	b579                	j	554 <vprintf+0x42>
 6c8:	74e2                	ld	s1,56(sp)
 6ca:	79a2                	ld	s3,40(sp)
 6cc:	7a02                	ld	s4,32(sp)
 6ce:	6ae2                	ld	s5,24(sp)
 6d0:	6b42                	ld	s6,16(sp)
 6d2:	6ba2                	ld	s7,8(sp)
    }
  }
}
 6d4:	60a6                	ld	ra,72(sp)
 6d6:	6406                	ld	s0,64(sp)
 6d8:	7942                	ld	s2,48(sp)
 6da:	6161                	add	sp,sp,80
 6dc:	8082                	ret

00000000000006de <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6de:	715d                	add	sp,sp,-80
 6e0:	ec06                	sd	ra,24(sp)
 6e2:	e822                	sd	s0,16(sp)
 6e4:	1000                	add	s0,sp,32
 6e6:	e010                	sd	a2,0(s0)
 6e8:	e414                	sd	a3,8(s0)
 6ea:	e818                	sd	a4,16(s0)
 6ec:	ec1c                	sd	a5,24(s0)
 6ee:	03043023          	sd	a6,32(s0)
 6f2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6f6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6fa:	8622                	mv	a2,s0
 6fc:	00000097          	auipc	ra,0x0
 700:	e16080e7          	jalr	-490(ra) # 512 <vprintf>
}
 704:	60e2                	ld	ra,24(sp)
 706:	6442                	ld	s0,16(sp)
 708:	6161                	add	sp,sp,80
 70a:	8082                	ret

000000000000070c <printf>:

void
printf(const char *fmt, ...)
{
 70c:	711d                	add	sp,sp,-96
 70e:	ec06                	sd	ra,24(sp)
 710:	e822                	sd	s0,16(sp)
 712:	1000                	add	s0,sp,32
 714:	e40c                	sd	a1,8(s0)
 716:	e810                	sd	a2,16(s0)
 718:	ec14                	sd	a3,24(s0)
 71a:	f018                	sd	a4,32(s0)
 71c:	f41c                	sd	a5,40(s0)
 71e:	03043823          	sd	a6,48(s0)
 722:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 726:	00840613          	add	a2,s0,8
 72a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 72e:	85aa                	mv	a1,a0
 730:	4505                	li	a0,1
 732:	00000097          	auipc	ra,0x0
 736:	de0080e7          	jalr	-544(ra) # 512 <vprintf>
}
 73a:	60e2                	ld	ra,24(sp)
 73c:	6442                	ld	s0,16(sp)
 73e:	6125                	add	sp,sp,96
 740:	8082                	ret

0000000000000742 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 742:	1141                	add	sp,sp,-16
 744:	e422                	sd	s0,8(sp)
 746:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 748:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 74c:	00000797          	auipc	a5,0x0
 750:	2bc7b783          	ld	a5,700(a5) # a08 <freep>
 754:	a02d                	j	77e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 756:	4618                	lw	a4,8(a2)
 758:	9f2d                	addw	a4,a4,a1
 75a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 75e:	6398                	ld	a4,0(a5)
 760:	6310                	ld	a2,0(a4)
 762:	a83d                	j	7a0 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 764:	ff852703          	lw	a4,-8(a0)
 768:	9f31                	addw	a4,a4,a2
 76a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 76c:	ff053683          	ld	a3,-16(a0)
 770:	a091                	j	7b4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 772:	6398                	ld	a4,0(a5)
 774:	00e7e463          	bltu	a5,a4,77c <free+0x3a>
 778:	00e6ea63          	bltu	a3,a4,78c <free+0x4a>
{
 77c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77e:	fed7fae3          	bgeu	a5,a3,772 <free+0x30>
 782:	6398                	ld	a4,0(a5)
 784:	00e6e463          	bltu	a3,a4,78c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 788:	fee7eae3          	bltu	a5,a4,77c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 78c:	ff852583          	lw	a1,-8(a0)
 790:	6390                	ld	a2,0(a5)
 792:	02059813          	sll	a6,a1,0x20
 796:	01c85713          	srl	a4,a6,0x1c
 79a:	9736                	add	a4,a4,a3
 79c:	fae60de3          	beq	a2,a4,756 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7a0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7a4:	4790                	lw	a2,8(a5)
 7a6:	02061593          	sll	a1,a2,0x20
 7aa:	01c5d713          	srl	a4,a1,0x1c
 7ae:	973e                	add	a4,a4,a5
 7b0:	fae68ae3          	beq	a3,a4,764 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7b4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7b6:	00000717          	auipc	a4,0x0
 7ba:	24f73923          	sd	a5,594(a4) # a08 <freep>
}
 7be:	6422                	ld	s0,8(sp)
 7c0:	0141                	add	sp,sp,16
 7c2:	8082                	ret

00000000000007c4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7c4:	7139                	add	sp,sp,-64
 7c6:	fc06                	sd	ra,56(sp)
 7c8:	f822                	sd	s0,48(sp)
 7ca:	f426                	sd	s1,40(sp)
 7cc:	ec4e                	sd	s3,24(sp)
 7ce:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d0:	02051493          	sll	s1,a0,0x20
 7d4:	9081                	srl	s1,s1,0x20
 7d6:	04bd                	add	s1,s1,15
 7d8:	8091                	srl	s1,s1,0x4
 7da:	0014899b          	addw	s3,s1,1
 7de:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 7e0:	00000517          	auipc	a0,0x0
 7e4:	22853503          	ld	a0,552(a0) # a08 <freep>
 7e8:	c915                	beqz	a0,81c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ec:	4798                	lw	a4,8(a5)
 7ee:	08977e63          	bgeu	a4,s1,88a <malloc+0xc6>
 7f2:	f04a                	sd	s2,32(sp)
 7f4:	e852                	sd	s4,16(sp)
 7f6:	e456                	sd	s5,8(sp)
 7f8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7fa:	8a4e                	mv	s4,s3
 7fc:	0009871b          	sext.w	a4,s3
 800:	6685                	lui	a3,0x1
 802:	00d77363          	bgeu	a4,a3,808 <malloc+0x44>
 806:	6a05                	lui	s4,0x1
 808:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 80c:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 810:	00000917          	auipc	s2,0x0
 814:	1f890913          	add	s2,s2,504 # a08 <freep>
  if(p == (char*)-1)
 818:	5afd                	li	s5,-1
 81a:	a091                	j	85e <malloc+0x9a>
 81c:	f04a                	sd	s2,32(sp)
 81e:	e852                	sd	s4,16(sp)
 820:	e456                	sd	s5,8(sp)
 822:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 824:	00000797          	auipc	a5,0x0
 828:	1ec78793          	add	a5,a5,492 # a10 <base>
 82c:	00000717          	auipc	a4,0x0
 830:	1cf73e23          	sd	a5,476(a4) # a08 <freep>
 834:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 836:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 83a:	b7c1                	j	7fa <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 83c:	6398                	ld	a4,0(a5)
 83e:	e118                	sd	a4,0(a0)
 840:	a08d                	j	8a2 <malloc+0xde>
  hp->s.size = nu;
 842:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 846:	0541                	add	a0,a0,16
 848:	00000097          	auipc	ra,0x0
 84c:	efa080e7          	jalr	-262(ra) # 742 <free>
  return freep;
 850:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 854:	c13d                	beqz	a0,8ba <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 856:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 858:	4798                	lw	a4,8(a5)
 85a:	02977463          	bgeu	a4,s1,882 <malloc+0xbe>
    if(p == freep)
 85e:	00093703          	ld	a4,0(s2)
 862:	853e                	mv	a0,a5
 864:	fef719e3          	bne	a4,a5,856 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 868:	8552                	mv	a0,s4
 86a:	00000097          	auipc	ra,0x0
 86e:	bba080e7          	jalr	-1094(ra) # 424 <sbrk>
  if(p == (char*)-1)
 872:	fd5518e3          	bne	a0,s5,842 <malloc+0x7e>
        return 0;
 876:	4501                	li	a0,0
 878:	7902                	ld	s2,32(sp)
 87a:	6a42                	ld	s4,16(sp)
 87c:	6aa2                	ld	s5,8(sp)
 87e:	6b02                	ld	s6,0(sp)
 880:	a03d                	j	8ae <malloc+0xea>
 882:	7902                	ld	s2,32(sp)
 884:	6a42                	ld	s4,16(sp)
 886:	6aa2                	ld	s5,8(sp)
 888:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 88a:	fae489e3          	beq	s1,a4,83c <malloc+0x78>
        p->s.size -= nunits;
 88e:	4137073b          	subw	a4,a4,s3
 892:	c798                	sw	a4,8(a5)
        p += p->s.size;
 894:	02071693          	sll	a3,a4,0x20
 898:	01c6d713          	srl	a4,a3,0x1c
 89c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 89e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8a2:	00000717          	auipc	a4,0x0
 8a6:	16a73323          	sd	a0,358(a4) # a08 <freep>
      return (void*)(p + 1);
 8aa:	01078513          	add	a0,a5,16
  }
}
 8ae:	70e2                	ld	ra,56(sp)
 8b0:	7442                	ld	s0,48(sp)
 8b2:	74a2                	ld	s1,40(sp)
 8b4:	69e2                	ld	s3,24(sp)
 8b6:	6121                	add	sp,sp,64
 8b8:	8082                	ret
 8ba:	7902                	ld	s2,32(sp)
 8bc:	6a42                	ld	s4,16(sp)
 8be:	6aa2                	ld	s5,8(sp)
 8c0:	6b02                	ld	s6,0(sp)
 8c2:	b7f5                	j	8ae <malloc+0xea>
