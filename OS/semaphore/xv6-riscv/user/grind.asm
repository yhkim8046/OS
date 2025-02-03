
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	add	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	add	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xor	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	add	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	add	a3,a3,797 # 1f31d <__global_pointer$+0x1d3fc>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	add	a2,a2,423 # 41a7 <__global_pointer$+0x2286>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	add	a3,a3,1260 # fffffffffffff4ec <__global_pointer$+0xffffffffffffd5cb>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	add	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	add	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	add	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	add	s0,sp,16
    return (do_rand(&rand_next));
      60:	00001517          	auipc	a0,0x1
      64:	6c850513          	add	a0,a0,1736 # 1728 <rand_next>
      68:	00000097          	auipc	ra,0x0
      6c:	f98080e7          	jalr	-104(ra) # 0 <do_rand>
}
      70:	60a2                	ld	ra,8(sp)
      72:	6402                	ld	s0,0(sp)
      74:	0141                	add	sp,sp,16
      76:	8082                	ret

0000000000000078 <go>:

void
go(int which_child)
{
      78:	7159                	add	sp,sp,-112
      7a:	f486                	sd	ra,104(sp)
      7c:	f0a2                	sd	s0,96(sp)
      7e:	eca6                	sd	s1,88(sp)
      80:	fc56                	sd	s5,56(sp)
      82:	1880                	add	s0,sp,112
      84:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      86:	4501                	li	a0,0
      88:	00001097          	auipc	ra,0x1
      8c:	e0a080e7          	jalr	-502(ra) # e92 <sbrk>
      90:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      92:	00001517          	auipc	a0,0x1
      96:	2b650513          	add	a0,a0,694 # 1348 <malloc+0x106>
      9a:	00001097          	auipc	ra,0x1
      9e:	dd8080e7          	jalr	-552(ra) # e72 <mkdir>
  if(chdir("grindir") != 0){
      a2:	00001517          	auipc	a0,0x1
      a6:	2a650513          	add	a0,a0,678 # 1348 <malloc+0x106>
      aa:	00001097          	auipc	ra,0x1
      ae:	dd0080e7          	jalr	-560(ra) # e7a <chdir>
      b2:	c115                	beqz	a0,d6 <go+0x5e>
      b4:	e8ca                	sd	s2,80(sp)
      b6:	e4ce                	sd	s3,72(sp)
      b8:	e0d2                	sd	s4,64(sp)
      ba:	f85a                	sd	s6,48(sp)
    printf("grind: chdir grindir failed\n");
      bc:	00001517          	auipc	a0,0x1
      c0:	29450513          	add	a0,a0,660 # 1350 <malloc+0x10e>
      c4:	00001097          	auipc	ra,0x1
      c8:	0c6080e7          	jalr	198(ra) # 118a <printf>
    exit(1);
      cc:	4505                	li	a0,1
      ce:	00001097          	auipc	ra,0x1
      d2:	d3c080e7          	jalr	-708(ra) # e0a <exit>
      d6:	e8ca                	sd	s2,80(sp)
      d8:	e4ce                	sd	s3,72(sp)
      da:	e0d2                	sd	s4,64(sp)
      dc:	f85a                	sd	s6,48(sp)
  }
  chdir("/");
      de:	00001517          	auipc	a0,0x1
      e2:	29a50513          	add	a0,a0,666 # 1378 <malloc+0x136>
      e6:	00001097          	auipc	ra,0x1
      ea:	d94080e7          	jalr	-620(ra) # e7a <chdir>
      ee:	00001997          	auipc	s3,0x1
      f2:	29a98993          	add	s3,s3,666 # 1388 <malloc+0x146>
      f6:	c489                	beqz	s1,100 <go+0x88>
      f8:	00001997          	auipc	s3,0x1
      fc:	28898993          	add	s3,s3,648 # 1380 <malloc+0x13e>
  uint64 iters = 0;
     100:	4481                	li	s1,0
  int fd = -1;
     102:	5a7d                	li	s4,-1
     104:	00001917          	auipc	s2,0x1
     108:	55490913          	add	s2,s2,1364 # 1658 <malloc+0x416>
     10c:	a839                	j	12a <go+0xb2>
    iters++;
    if((iters % 500) == 0)
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
     10e:	20200593          	li	a1,514
     112:	00001517          	auipc	a0,0x1
     116:	27e50513          	add	a0,a0,638 # 1390 <malloc+0x14e>
     11a:	00001097          	auipc	ra,0x1
     11e:	d30080e7          	jalr	-720(ra) # e4a <open>
     122:	00001097          	auipc	ra,0x1
     126:	d10080e7          	jalr	-752(ra) # e32 <close>
    iters++;
     12a:	0485                	add	s1,s1,1
    if((iters % 500) == 0)
     12c:	1f400793          	li	a5,500
     130:	02f4f7b3          	remu	a5,s1,a5
     134:	eb81                	bnez	a5,144 <go+0xcc>
      write(1, which_child?"B":"A", 1);
     136:	4605                	li	a2,1
     138:	85ce                	mv	a1,s3
     13a:	4505                	li	a0,1
     13c:	00001097          	auipc	ra,0x1
     140:	cee080e7          	jalr	-786(ra) # e2a <write>
    int what = rand() % 23;
     144:	00000097          	auipc	ra,0x0
     148:	f14080e7          	jalr	-236(ra) # 58 <rand>
     14c:	47dd                	li	a5,23
     14e:	02f5653b          	remw	a0,a0,a5
     152:	0005071b          	sext.w	a4,a0
     156:	47d9                	li	a5,22
     158:	fce7e9e3          	bltu	a5,a4,12a <go+0xb2>
     15c:	02051793          	sll	a5,a0,0x20
     160:	01e7d513          	srl	a0,a5,0x1e
     164:	954a                	add	a0,a0,s2
     166:	411c                	lw	a5,0(a0)
     168:	97ca                	add	a5,a5,s2
     16a:	8782                	jr	a5
    } else if(what == 2){
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     16c:	20200593          	li	a1,514
     170:	00001517          	auipc	a0,0x1
     174:	23050513          	add	a0,a0,560 # 13a0 <malloc+0x15e>
     178:	00001097          	auipc	ra,0x1
     17c:	cd2080e7          	jalr	-814(ra) # e4a <open>
     180:	00001097          	auipc	ra,0x1
     184:	cb2080e7          	jalr	-846(ra) # e32 <close>
     188:	b74d                	j	12a <go+0xb2>
    } else if(what == 3){
      unlink("grindir/../a");
     18a:	00001517          	auipc	a0,0x1
     18e:	20650513          	add	a0,a0,518 # 1390 <malloc+0x14e>
     192:	00001097          	auipc	ra,0x1
     196:	cc8080e7          	jalr	-824(ra) # e5a <unlink>
     19a:	bf41                	j	12a <go+0xb2>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     19c:	00001517          	auipc	a0,0x1
     1a0:	1ac50513          	add	a0,a0,428 # 1348 <malloc+0x106>
     1a4:	00001097          	auipc	ra,0x1
     1a8:	cd6080e7          	jalr	-810(ra) # e7a <chdir>
     1ac:	e115                	bnez	a0,1d0 <go+0x158>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     1ae:	00001517          	auipc	a0,0x1
     1b2:	20a50513          	add	a0,a0,522 # 13b8 <malloc+0x176>
     1b6:	00001097          	auipc	ra,0x1
     1ba:	ca4080e7          	jalr	-860(ra) # e5a <unlink>
      chdir("/");
     1be:	00001517          	auipc	a0,0x1
     1c2:	1ba50513          	add	a0,a0,442 # 1378 <malloc+0x136>
     1c6:	00001097          	auipc	ra,0x1
     1ca:	cb4080e7          	jalr	-844(ra) # e7a <chdir>
     1ce:	bfb1                	j	12a <go+0xb2>
        printf("grind: chdir grindir failed\n");
     1d0:	00001517          	auipc	a0,0x1
     1d4:	18050513          	add	a0,a0,384 # 1350 <malloc+0x10e>
     1d8:	00001097          	auipc	ra,0x1
     1dc:	fb2080e7          	jalr	-78(ra) # 118a <printf>
        exit(1);
     1e0:	4505                	li	a0,1
     1e2:	00001097          	auipc	ra,0x1
     1e6:	c28080e7          	jalr	-984(ra) # e0a <exit>
    } else if(what == 5){
      close(fd);
     1ea:	8552                	mv	a0,s4
     1ec:	00001097          	auipc	ra,0x1
     1f0:	c46080e7          	jalr	-954(ra) # e32 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     1f4:	20200593          	li	a1,514
     1f8:	00001517          	auipc	a0,0x1
     1fc:	1c850513          	add	a0,a0,456 # 13c0 <malloc+0x17e>
     200:	00001097          	auipc	ra,0x1
     204:	c4a080e7          	jalr	-950(ra) # e4a <open>
     208:	8a2a                	mv	s4,a0
     20a:	b705                	j	12a <go+0xb2>
    } else if(what == 6){
      close(fd);
     20c:	8552                	mv	a0,s4
     20e:	00001097          	auipc	ra,0x1
     212:	c24080e7          	jalr	-988(ra) # e32 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     216:	20200593          	li	a1,514
     21a:	00001517          	auipc	a0,0x1
     21e:	1b650513          	add	a0,a0,438 # 13d0 <malloc+0x18e>
     222:	00001097          	auipc	ra,0x1
     226:	c28080e7          	jalr	-984(ra) # e4a <open>
     22a:	8a2a                	mv	s4,a0
     22c:	bdfd                	j	12a <go+0xb2>
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
     22e:	3e700613          	li	a2,999
     232:	00001597          	auipc	a1,0x1
     236:	50658593          	add	a1,a1,1286 # 1738 <buf.0>
     23a:	8552                	mv	a0,s4
     23c:	00001097          	auipc	ra,0x1
     240:	bee080e7          	jalr	-1042(ra) # e2a <write>
     244:	b5dd                	j	12a <go+0xb2>
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     246:	3e700613          	li	a2,999
     24a:	00001597          	auipc	a1,0x1
     24e:	4ee58593          	add	a1,a1,1262 # 1738 <buf.0>
     252:	8552                	mv	a0,s4
     254:	00001097          	auipc	ra,0x1
     258:	bce080e7          	jalr	-1074(ra) # e22 <read>
     25c:	b5f9                	j	12a <go+0xb2>
    } else if(what == 9){
      mkdir("grindir/../a");
     25e:	00001517          	auipc	a0,0x1
     262:	13250513          	add	a0,a0,306 # 1390 <malloc+0x14e>
     266:	00001097          	auipc	ra,0x1
     26a:	c0c080e7          	jalr	-1012(ra) # e72 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     26e:	20200593          	li	a1,514
     272:	00001517          	auipc	a0,0x1
     276:	17650513          	add	a0,a0,374 # 13e8 <malloc+0x1a6>
     27a:	00001097          	auipc	ra,0x1
     27e:	bd0080e7          	jalr	-1072(ra) # e4a <open>
     282:	00001097          	auipc	ra,0x1
     286:	bb0080e7          	jalr	-1104(ra) # e32 <close>
      unlink("a/a");
     28a:	00001517          	auipc	a0,0x1
     28e:	16e50513          	add	a0,a0,366 # 13f8 <malloc+0x1b6>
     292:	00001097          	auipc	ra,0x1
     296:	bc8080e7          	jalr	-1080(ra) # e5a <unlink>
     29a:	bd41                	j	12a <go+0xb2>
    } else if(what == 10){
      mkdir("/../b");
     29c:	00001517          	auipc	a0,0x1
     2a0:	16450513          	add	a0,a0,356 # 1400 <malloc+0x1be>
     2a4:	00001097          	auipc	ra,0x1
     2a8:	bce080e7          	jalr	-1074(ra) # e72 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     2ac:	20200593          	li	a1,514
     2b0:	00001517          	auipc	a0,0x1
     2b4:	15850513          	add	a0,a0,344 # 1408 <malloc+0x1c6>
     2b8:	00001097          	auipc	ra,0x1
     2bc:	b92080e7          	jalr	-1134(ra) # e4a <open>
     2c0:	00001097          	auipc	ra,0x1
     2c4:	b72080e7          	jalr	-1166(ra) # e32 <close>
      unlink("b/b");
     2c8:	00001517          	auipc	a0,0x1
     2cc:	15050513          	add	a0,a0,336 # 1418 <malloc+0x1d6>
     2d0:	00001097          	auipc	ra,0x1
     2d4:	b8a080e7          	jalr	-1142(ra) # e5a <unlink>
     2d8:	bd89                	j	12a <go+0xb2>
    } else if(what == 11){
      unlink("b");
     2da:	00001517          	auipc	a0,0x1
     2de:	14650513          	add	a0,a0,326 # 1420 <malloc+0x1de>
     2e2:	00001097          	auipc	ra,0x1
     2e6:	b78080e7          	jalr	-1160(ra) # e5a <unlink>
      link("../grindir/./../a", "../b");
     2ea:	00001597          	auipc	a1,0x1
     2ee:	0ce58593          	add	a1,a1,206 # 13b8 <malloc+0x176>
     2f2:	00001517          	auipc	a0,0x1
     2f6:	13650513          	add	a0,a0,310 # 1428 <malloc+0x1e6>
     2fa:	00001097          	auipc	ra,0x1
     2fe:	b70080e7          	jalr	-1168(ra) # e6a <link>
     302:	b525                	j	12a <go+0xb2>
    } else if(what == 12){
      unlink("../grindir/../a");
     304:	00001517          	auipc	a0,0x1
     308:	13c50513          	add	a0,a0,316 # 1440 <malloc+0x1fe>
     30c:	00001097          	auipc	ra,0x1
     310:	b4e080e7          	jalr	-1202(ra) # e5a <unlink>
      link(".././b", "/grindir/../a");
     314:	00001597          	auipc	a1,0x1
     318:	0ac58593          	add	a1,a1,172 # 13c0 <malloc+0x17e>
     31c:	00001517          	auipc	a0,0x1
     320:	13450513          	add	a0,a0,308 # 1450 <malloc+0x20e>
     324:	00001097          	auipc	ra,0x1
     328:	b46080e7          	jalr	-1210(ra) # e6a <link>
     32c:	bbfd                	j	12a <go+0xb2>
    } else if(what == 13){
      int pid = fork();
     32e:	00001097          	auipc	ra,0x1
     332:	ad4080e7          	jalr	-1324(ra) # e02 <fork>
      if(pid == 0){
     336:	c909                	beqz	a0,348 <go+0x2d0>
        exit(0);
      } else if(pid < 0){
     338:	00054c63          	bltz	a0,350 <go+0x2d8>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     33c:	4501                	li	a0,0
     33e:	00001097          	auipc	ra,0x1
     342:	ad4080e7          	jalr	-1324(ra) # e12 <wait>
     346:	b3d5                	j	12a <go+0xb2>
        exit(0);
     348:	00001097          	auipc	ra,0x1
     34c:	ac2080e7          	jalr	-1342(ra) # e0a <exit>
        printf("grind: fork failed\n");
     350:	00001517          	auipc	a0,0x1
     354:	10850513          	add	a0,a0,264 # 1458 <malloc+0x216>
     358:	00001097          	auipc	ra,0x1
     35c:	e32080e7          	jalr	-462(ra) # 118a <printf>
        exit(1);
     360:	4505                	li	a0,1
     362:	00001097          	auipc	ra,0x1
     366:	aa8080e7          	jalr	-1368(ra) # e0a <exit>
    } else if(what == 14){
      int pid = fork();
     36a:	00001097          	auipc	ra,0x1
     36e:	a98080e7          	jalr	-1384(ra) # e02 <fork>
      if(pid == 0){
     372:	c909                	beqz	a0,384 <go+0x30c>
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
     374:	02054563          	bltz	a0,39e <go+0x326>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     378:	4501                	li	a0,0
     37a:	00001097          	auipc	ra,0x1
     37e:	a98080e7          	jalr	-1384(ra) # e12 <wait>
     382:	b365                	j	12a <go+0xb2>
        fork();
     384:	00001097          	auipc	ra,0x1
     388:	a7e080e7          	jalr	-1410(ra) # e02 <fork>
        fork();
     38c:	00001097          	auipc	ra,0x1
     390:	a76080e7          	jalr	-1418(ra) # e02 <fork>
        exit(0);
     394:	4501                	li	a0,0
     396:	00001097          	auipc	ra,0x1
     39a:	a74080e7          	jalr	-1420(ra) # e0a <exit>
        printf("grind: fork failed\n");
     39e:	00001517          	auipc	a0,0x1
     3a2:	0ba50513          	add	a0,a0,186 # 1458 <malloc+0x216>
     3a6:	00001097          	auipc	ra,0x1
     3aa:	de4080e7          	jalr	-540(ra) # 118a <printf>
        exit(1);
     3ae:	4505                	li	a0,1
     3b0:	00001097          	auipc	ra,0x1
     3b4:	a5a080e7          	jalr	-1446(ra) # e0a <exit>
    } else if(what == 15){
      sbrk(6011);
     3b8:	6505                	lui	a0,0x1
     3ba:	77b50513          	add	a0,a0,1915 # 177b <buf.0+0x43>
     3be:	00001097          	auipc	ra,0x1
     3c2:	ad4080e7          	jalr	-1324(ra) # e92 <sbrk>
     3c6:	b395                	j	12a <go+0xb2>
    } else if(what == 16){
      if(sbrk(0) > break0)
     3c8:	4501                	li	a0,0
     3ca:	00001097          	auipc	ra,0x1
     3ce:	ac8080e7          	jalr	-1336(ra) # e92 <sbrk>
     3d2:	d4aafce3          	bgeu	s5,a0,12a <go+0xb2>
        sbrk(-(sbrk(0) - break0));
     3d6:	4501                	li	a0,0
     3d8:	00001097          	auipc	ra,0x1
     3dc:	aba080e7          	jalr	-1350(ra) # e92 <sbrk>
     3e0:	40aa853b          	subw	a0,s5,a0
     3e4:	00001097          	auipc	ra,0x1
     3e8:	aae080e7          	jalr	-1362(ra) # e92 <sbrk>
     3ec:	bb3d                	j	12a <go+0xb2>
    } else if(what == 17){
      int pid = fork();
     3ee:	00001097          	auipc	ra,0x1
     3f2:	a14080e7          	jalr	-1516(ra) # e02 <fork>
     3f6:	8b2a                	mv	s6,a0
      if(pid == 0){
     3f8:	c51d                	beqz	a0,426 <go+0x3ae>
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
     3fa:	04054963          	bltz	a0,44c <go+0x3d4>
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
     3fe:	00001517          	auipc	a0,0x1
     402:	07a50513          	add	a0,a0,122 # 1478 <malloc+0x236>
     406:	00001097          	auipc	ra,0x1
     40a:	a74080e7          	jalr	-1420(ra) # e7a <chdir>
     40e:	ed21                	bnez	a0,466 <go+0x3ee>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
     410:	855a                	mv	a0,s6
     412:	00001097          	auipc	ra,0x1
     416:	a28080e7          	jalr	-1496(ra) # e3a <kill>
      wait(0);
     41a:	4501                	li	a0,0
     41c:	00001097          	auipc	ra,0x1
     420:	9f6080e7          	jalr	-1546(ra) # e12 <wait>
     424:	b319                	j	12a <go+0xb2>
        close(open("a", O_CREATE|O_RDWR));
     426:	20200593          	li	a1,514
     42a:	00001517          	auipc	a0,0x1
     42e:	04650513          	add	a0,a0,70 # 1470 <malloc+0x22e>
     432:	00001097          	auipc	ra,0x1
     436:	a18080e7          	jalr	-1512(ra) # e4a <open>
     43a:	00001097          	auipc	ra,0x1
     43e:	9f8080e7          	jalr	-1544(ra) # e32 <close>
        exit(0);
     442:	4501                	li	a0,0
     444:	00001097          	auipc	ra,0x1
     448:	9c6080e7          	jalr	-1594(ra) # e0a <exit>
        printf("grind: fork failed\n");
     44c:	00001517          	auipc	a0,0x1
     450:	00c50513          	add	a0,a0,12 # 1458 <malloc+0x216>
     454:	00001097          	auipc	ra,0x1
     458:	d36080e7          	jalr	-714(ra) # 118a <printf>
        exit(1);
     45c:	4505                	li	a0,1
     45e:	00001097          	auipc	ra,0x1
     462:	9ac080e7          	jalr	-1620(ra) # e0a <exit>
        printf("grind: chdir failed\n");
     466:	00001517          	auipc	a0,0x1
     46a:	02250513          	add	a0,a0,34 # 1488 <malloc+0x246>
     46e:	00001097          	auipc	ra,0x1
     472:	d1c080e7          	jalr	-740(ra) # 118a <printf>
        exit(1);
     476:	4505                	li	a0,1
     478:	00001097          	auipc	ra,0x1
     47c:	992080e7          	jalr	-1646(ra) # e0a <exit>
    } else if(what == 18){
      int pid = fork();
     480:	00001097          	auipc	ra,0x1
     484:	982080e7          	jalr	-1662(ra) # e02 <fork>
      if(pid == 0){
     488:	c909                	beqz	a0,49a <go+0x422>
        kill(getpid());
        exit(0);
      } else if(pid < 0){
     48a:	02054563          	bltz	a0,4b4 <go+0x43c>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     48e:	4501                	li	a0,0
     490:	00001097          	auipc	ra,0x1
     494:	982080e7          	jalr	-1662(ra) # e12 <wait>
     498:	b949                	j	12a <go+0xb2>
        kill(getpid());
     49a:	00001097          	auipc	ra,0x1
     49e:	9f0080e7          	jalr	-1552(ra) # e8a <getpid>
     4a2:	00001097          	auipc	ra,0x1
     4a6:	998080e7          	jalr	-1640(ra) # e3a <kill>
        exit(0);
     4aa:	4501                	li	a0,0
     4ac:	00001097          	auipc	ra,0x1
     4b0:	95e080e7          	jalr	-1698(ra) # e0a <exit>
        printf("grind: fork failed\n");
     4b4:	00001517          	auipc	a0,0x1
     4b8:	fa450513          	add	a0,a0,-92 # 1458 <malloc+0x216>
     4bc:	00001097          	auipc	ra,0x1
     4c0:	cce080e7          	jalr	-818(ra) # 118a <printf>
        exit(1);
     4c4:	4505                	li	a0,1
     4c6:	00001097          	auipc	ra,0x1
     4ca:	944080e7          	jalr	-1724(ra) # e0a <exit>
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
     4ce:	fa840513          	add	a0,s0,-88
     4d2:	00001097          	auipc	ra,0x1
     4d6:	948080e7          	jalr	-1720(ra) # e1a <pipe>
     4da:	02054b63          	bltz	a0,510 <go+0x498>
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
     4de:	00001097          	auipc	ra,0x1
     4e2:	924080e7          	jalr	-1756(ra) # e02 <fork>
      if(pid == 0){
     4e6:	c131                	beqz	a0,52a <go+0x4b2>
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
     4e8:	0a054a63          	bltz	a0,59c <go+0x524>
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
     4ec:	fa842503          	lw	a0,-88(s0)
     4f0:	00001097          	auipc	ra,0x1
     4f4:	942080e7          	jalr	-1726(ra) # e32 <close>
      close(fds[1]);
     4f8:	fac42503          	lw	a0,-84(s0)
     4fc:	00001097          	auipc	ra,0x1
     500:	936080e7          	jalr	-1738(ra) # e32 <close>
      wait(0);
     504:	4501                	li	a0,0
     506:	00001097          	auipc	ra,0x1
     50a:	90c080e7          	jalr	-1780(ra) # e12 <wait>
     50e:	b931                	j	12a <go+0xb2>
        printf("grind: pipe failed\n");
     510:	00001517          	auipc	a0,0x1
     514:	f9050513          	add	a0,a0,-112 # 14a0 <malloc+0x25e>
     518:	00001097          	auipc	ra,0x1
     51c:	c72080e7          	jalr	-910(ra) # 118a <printf>
        exit(1);
     520:	4505                	li	a0,1
     522:	00001097          	auipc	ra,0x1
     526:	8e8080e7          	jalr	-1816(ra) # e0a <exit>
        fork();
     52a:	00001097          	auipc	ra,0x1
     52e:	8d8080e7          	jalr	-1832(ra) # e02 <fork>
        fork();
     532:	00001097          	auipc	ra,0x1
     536:	8d0080e7          	jalr	-1840(ra) # e02 <fork>
        if(write(fds[1], "x", 1) != 1)
     53a:	4605                	li	a2,1
     53c:	00001597          	auipc	a1,0x1
     540:	f7c58593          	add	a1,a1,-132 # 14b8 <malloc+0x276>
     544:	fac42503          	lw	a0,-84(s0)
     548:	00001097          	auipc	ra,0x1
     54c:	8e2080e7          	jalr	-1822(ra) # e2a <write>
     550:	4785                	li	a5,1
     552:	02f51363          	bne	a0,a5,578 <go+0x500>
        if(read(fds[0], &c, 1) != 1)
     556:	4605                	li	a2,1
     558:	fa040593          	add	a1,s0,-96
     55c:	fa842503          	lw	a0,-88(s0)
     560:	00001097          	auipc	ra,0x1
     564:	8c2080e7          	jalr	-1854(ra) # e22 <read>
     568:	4785                	li	a5,1
     56a:	02f51063          	bne	a0,a5,58a <go+0x512>
        exit(0);
     56e:	4501                	li	a0,0
     570:	00001097          	auipc	ra,0x1
     574:	89a080e7          	jalr	-1894(ra) # e0a <exit>
          printf("grind: pipe write failed\n");
     578:	00001517          	auipc	a0,0x1
     57c:	f4850513          	add	a0,a0,-184 # 14c0 <malloc+0x27e>
     580:	00001097          	auipc	ra,0x1
     584:	c0a080e7          	jalr	-1014(ra) # 118a <printf>
     588:	b7f9                	j	556 <go+0x4de>
          printf("grind: pipe read failed\n");
     58a:	00001517          	auipc	a0,0x1
     58e:	f5650513          	add	a0,a0,-170 # 14e0 <malloc+0x29e>
     592:	00001097          	auipc	ra,0x1
     596:	bf8080e7          	jalr	-1032(ra) # 118a <printf>
     59a:	bfd1                	j	56e <go+0x4f6>
        printf("grind: fork failed\n");
     59c:	00001517          	auipc	a0,0x1
     5a0:	ebc50513          	add	a0,a0,-324 # 1458 <malloc+0x216>
     5a4:	00001097          	auipc	ra,0x1
     5a8:	be6080e7          	jalr	-1050(ra) # 118a <printf>
        exit(1);
     5ac:	4505                	li	a0,1
     5ae:	00001097          	auipc	ra,0x1
     5b2:	85c080e7          	jalr	-1956(ra) # e0a <exit>
    } else if(what == 20){
      int pid = fork();
     5b6:	00001097          	auipc	ra,0x1
     5ba:	84c080e7          	jalr	-1972(ra) # e02 <fork>
      if(pid == 0){
     5be:	c909                	beqz	a0,5d0 <go+0x558>
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
     5c0:	06054f63          	bltz	a0,63e <go+0x5c6>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     5c4:	4501                	li	a0,0
     5c6:	00001097          	auipc	ra,0x1
     5ca:	84c080e7          	jalr	-1972(ra) # e12 <wait>
     5ce:	beb1                	j	12a <go+0xb2>
        unlink("a");
     5d0:	00001517          	auipc	a0,0x1
     5d4:	ea050513          	add	a0,a0,-352 # 1470 <malloc+0x22e>
     5d8:	00001097          	auipc	ra,0x1
     5dc:	882080e7          	jalr	-1918(ra) # e5a <unlink>
        mkdir("a");
     5e0:	00001517          	auipc	a0,0x1
     5e4:	e9050513          	add	a0,a0,-368 # 1470 <malloc+0x22e>
     5e8:	00001097          	auipc	ra,0x1
     5ec:	88a080e7          	jalr	-1910(ra) # e72 <mkdir>
        chdir("a");
     5f0:	00001517          	auipc	a0,0x1
     5f4:	e8050513          	add	a0,a0,-384 # 1470 <malloc+0x22e>
     5f8:	00001097          	auipc	ra,0x1
     5fc:	882080e7          	jalr	-1918(ra) # e7a <chdir>
        unlink("../a");
     600:	00001517          	auipc	a0,0x1
     604:	f0050513          	add	a0,a0,-256 # 1500 <malloc+0x2be>
     608:	00001097          	auipc	ra,0x1
     60c:	852080e7          	jalr	-1966(ra) # e5a <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     610:	20200593          	li	a1,514
     614:	00001517          	auipc	a0,0x1
     618:	ea450513          	add	a0,a0,-348 # 14b8 <malloc+0x276>
     61c:	00001097          	auipc	ra,0x1
     620:	82e080e7          	jalr	-2002(ra) # e4a <open>
        unlink("x");
     624:	00001517          	auipc	a0,0x1
     628:	e9450513          	add	a0,a0,-364 # 14b8 <malloc+0x276>
     62c:	00001097          	auipc	ra,0x1
     630:	82e080e7          	jalr	-2002(ra) # e5a <unlink>
        exit(0);
     634:	4501                	li	a0,0
     636:	00000097          	auipc	ra,0x0
     63a:	7d4080e7          	jalr	2004(ra) # e0a <exit>
        printf("grind: fork failed\n");
     63e:	00001517          	auipc	a0,0x1
     642:	e1a50513          	add	a0,a0,-486 # 1458 <malloc+0x216>
     646:	00001097          	auipc	ra,0x1
     64a:	b44080e7          	jalr	-1212(ra) # 118a <printf>
        exit(1);
     64e:	4505                	li	a0,1
     650:	00000097          	auipc	ra,0x0
     654:	7ba080e7          	jalr	1978(ra) # e0a <exit>
    } else if(what == 21){
      unlink("c");
     658:	00001517          	auipc	a0,0x1
     65c:	eb050513          	add	a0,a0,-336 # 1508 <malloc+0x2c6>
     660:	00000097          	auipc	ra,0x0
     664:	7fa080e7          	jalr	2042(ra) # e5a <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     668:	20200593          	li	a1,514
     66c:	00001517          	auipc	a0,0x1
     670:	e9c50513          	add	a0,a0,-356 # 1508 <malloc+0x2c6>
     674:	00000097          	auipc	ra,0x0
     678:	7d6080e7          	jalr	2006(ra) # e4a <open>
     67c:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     67e:	04054f63          	bltz	a0,6dc <go+0x664>
        printf("grind: create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
     682:	4605                	li	a2,1
     684:	00001597          	auipc	a1,0x1
     688:	e3458593          	add	a1,a1,-460 # 14b8 <malloc+0x276>
     68c:	00000097          	auipc	ra,0x0
     690:	79e080e7          	jalr	1950(ra) # e2a <write>
     694:	4785                	li	a5,1
     696:	06f51063          	bne	a0,a5,6f6 <go+0x67e>
        printf("grind: write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     69a:	fa840593          	add	a1,s0,-88
     69e:	855a                	mv	a0,s6
     6a0:	00000097          	auipc	ra,0x0
     6a4:	7c2080e7          	jalr	1986(ra) # e62 <fstat>
     6a8:	e525                	bnez	a0,710 <go+0x698>
        printf("grind: fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
     6aa:	fb843583          	ld	a1,-72(s0)
     6ae:	4785                	li	a5,1
     6b0:	06f59d63          	bne	a1,a5,72a <go+0x6b2>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
     6b4:	fac42583          	lw	a1,-84(s0)
     6b8:	0c800793          	li	a5,200
     6bc:	08b7e563          	bltu	a5,a1,746 <go+0x6ce>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
     6c0:	855a                	mv	a0,s6
     6c2:	00000097          	auipc	ra,0x0
     6c6:	770080e7          	jalr	1904(ra) # e32 <close>
      unlink("c");
     6ca:	00001517          	auipc	a0,0x1
     6ce:	e3e50513          	add	a0,a0,-450 # 1508 <malloc+0x2c6>
     6d2:	00000097          	auipc	ra,0x0
     6d6:	788080e7          	jalr	1928(ra) # e5a <unlink>
     6da:	bc81                	j	12a <go+0xb2>
        printf("grind: create c failed\n");
     6dc:	00001517          	auipc	a0,0x1
     6e0:	e3450513          	add	a0,a0,-460 # 1510 <malloc+0x2ce>
     6e4:	00001097          	auipc	ra,0x1
     6e8:	aa6080e7          	jalr	-1370(ra) # 118a <printf>
        exit(1);
     6ec:	4505                	li	a0,1
     6ee:	00000097          	auipc	ra,0x0
     6f2:	71c080e7          	jalr	1820(ra) # e0a <exit>
        printf("grind: write c failed\n");
     6f6:	00001517          	auipc	a0,0x1
     6fa:	e3250513          	add	a0,a0,-462 # 1528 <malloc+0x2e6>
     6fe:	00001097          	auipc	ra,0x1
     702:	a8c080e7          	jalr	-1396(ra) # 118a <printf>
        exit(1);
     706:	4505                	li	a0,1
     708:	00000097          	auipc	ra,0x0
     70c:	702080e7          	jalr	1794(ra) # e0a <exit>
        printf("grind: fstat failed\n");
     710:	00001517          	auipc	a0,0x1
     714:	e3050513          	add	a0,a0,-464 # 1540 <malloc+0x2fe>
     718:	00001097          	auipc	ra,0x1
     71c:	a72080e7          	jalr	-1422(ra) # 118a <printf>
        exit(1);
     720:	4505                	li	a0,1
     722:	00000097          	auipc	ra,0x0
     726:	6e8080e7          	jalr	1768(ra) # e0a <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     72a:	2581                	sext.w	a1,a1
     72c:	00001517          	auipc	a0,0x1
     730:	e2c50513          	add	a0,a0,-468 # 1558 <malloc+0x316>
     734:	00001097          	auipc	ra,0x1
     738:	a56080e7          	jalr	-1450(ra) # 118a <printf>
        exit(1);
     73c:	4505                	li	a0,1
     73e:	00000097          	auipc	ra,0x0
     742:	6cc080e7          	jalr	1740(ra) # e0a <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     746:	00001517          	auipc	a0,0x1
     74a:	e3a50513          	add	a0,a0,-454 # 1580 <malloc+0x33e>
     74e:	00001097          	auipc	ra,0x1
     752:	a3c080e7          	jalr	-1476(ra) # 118a <printf>
        exit(1);
     756:	4505                	li	a0,1
     758:	00000097          	auipc	ra,0x0
     75c:	6b2080e7          	jalr	1714(ra) # e0a <exit>
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     760:	f9840513          	add	a0,s0,-104
     764:	00000097          	auipc	ra,0x0
     768:	6b6080e7          	jalr	1718(ra) # e1a <pipe>
     76c:	10054063          	bltz	a0,86c <go+0x7f4>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     770:	fa040513          	add	a0,s0,-96
     774:	00000097          	auipc	ra,0x0
     778:	6a6080e7          	jalr	1702(ra) # e1a <pipe>
     77c:	10054663          	bltz	a0,888 <go+0x810>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     780:	00000097          	auipc	ra,0x0
     784:	682080e7          	jalr	1666(ra) # e02 <fork>
      if(pid1 == 0){
     788:	10050e63          	beqz	a0,8a4 <go+0x82c>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     78c:	1c054663          	bltz	a0,958 <go+0x8e0>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     790:	00000097          	auipc	ra,0x0
     794:	672080e7          	jalr	1650(ra) # e02 <fork>
      if(pid2 == 0){
     798:	1c050e63          	beqz	a0,974 <go+0x8fc>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     79c:	2a054a63          	bltz	a0,a50 <go+0x9d8>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     7a0:	f9842503          	lw	a0,-104(s0)
     7a4:	00000097          	auipc	ra,0x0
     7a8:	68e080e7          	jalr	1678(ra) # e32 <close>
      close(aa[1]);
     7ac:	f9c42503          	lw	a0,-100(s0)
     7b0:	00000097          	auipc	ra,0x0
     7b4:	682080e7          	jalr	1666(ra) # e32 <close>
      close(bb[1]);
     7b8:	fa442503          	lw	a0,-92(s0)
     7bc:	00000097          	auipc	ra,0x0
     7c0:	676080e7          	jalr	1654(ra) # e32 <close>
      char buf[4] = { 0, 0, 0, 0 };
     7c4:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     7c8:	4605                	li	a2,1
     7ca:	f9040593          	add	a1,s0,-112
     7ce:	fa042503          	lw	a0,-96(s0)
     7d2:	00000097          	auipc	ra,0x0
     7d6:	650080e7          	jalr	1616(ra) # e22 <read>
      read(bb[0], buf+1, 1);
     7da:	4605                	li	a2,1
     7dc:	f9140593          	add	a1,s0,-111
     7e0:	fa042503          	lw	a0,-96(s0)
     7e4:	00000097          	auipc	ra,0x0
     7e8:	63e080e7          	jalr	1598(ra) # e22 <read>
      read(bb[0], buf+2, 1);
     7ec:	4605                	li	a2,1
     7ee:	f9240593          	add	a1,s0,-110
     7f2:	fa042503          	lw	a0,-96(s0)
     7f6:	00000097          	auipc	ra,0x0
     7fa:	62c080e7          	jalr	1580(ra) # e22 <read>
      close(bb[0]);
     7fe:	fa042503          	lw	a0,-96(s0)
     802:	00000097          	auipc	ra,0x0
     806:	630080e7          	jalr	1584(ra) # e32 <close>
      int st1, st2;
      wait(&st1);
     80a:	f9440513          	add	a0,s0,-108
     80e:	00000097          	auipc	ra,0x0
     812:	604080e7          	jalr	1540(ra) # e12 <wait>
      wait(&st2);
     816:	fa840513          	add	a0,s0,-88
     81a:	00000097          	auipc	ra,0x0
     81e:	5f8080e7          	jalr	1528(ra) # e12 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     822:	f9442783          	lw	a5,-108(s0)
     826:	fa842703          	lw	a4,-88(s0)
     82a:	8fd9                	or	a5,a5,a4
     82c:	ef89                	bnez	a5,846 <go+0x7ce>
     82e:	00001597          	auipc	a1,0x1
     832:	df258593          	add	a1,a1,-526 # 1620 <malloc+0x3de>
     836:	f9040513          	add	a0,s0,-112
     83a:	00000097          	auipc	ra,0x0
     83e:	380080e7          	jalr	896(ra) # bba <strcmp>
     842:	8e0504e3          	beqz	a0,12a <go+0xb2>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     846:	f9040693          	add	a3,s0,-112
     84a:	fa842603          	lw	a2,-88(s0)
     84e:	f9442583          	lw	a1,-108(s0)
     852:	00001517          	auipc	a0,0x1
     856:	dd650513          	add	a0,a0,-554 # 1628 <malloc+0x3e6>
     85a:	00001097          	auipc	ra,0x1
     85e:	930080e7          	jalr	-1744(ra) # 118a <printf>
        exit(1);
     862:	4505                	li	a0,1
     864:	00000097          	auipc	ra,0x0
     868:	5a6080e7          	jalr	1446(ra) # e0a <exit>
        fprintf(2, "grind: pipe failed\n");
     86c:	00001597          	auipc	a1,0x1
     870:	c3458593          	add	a1,a1,-972 # 14a0 <malloc+0x25e>
     874:	4509                	li	a0,2
     876:	00001097          	auipc	ra,0x1
     87a:	8e6080e7          	jalr	-1818(ra) # 115c <fprintf>
        exit(1);
     87e:	4505                	li	a0,1
     880:	00000097          	auipc	ra,0x0
     884:	58a080e7          	jalr	1418(ra) # e0a <exit>
        fprintf(2, "grind: pipe failed\n");
     888:	00001597          	auipc	a1,0x1
     88c:	c1858593          	add	a1,a1,-1000 # 14a0 <malloc+0x25e>
     890:	4509                	li	a0,2
     892:	00001097          	auipc	ra,0x1
     896:	8ca080e7          	jalr	-1846(ra) # 115c <fprintf>
        exit(1);
     89a:	4505                	li	a0,1
     89c:	00000097          	auipc	ra,0x0
     8a0:	56e080e7          	jalr	1390(ra) # e0a <exit>
        close(bb[0]);
     8a4:	fa042503          	lw	a0,-96(s0)
     8a8:	00000097          	auipc	ra,0x0
     8ac:	58a080e7          	jalr	1418(ra) # e32 <close>
        close(bb[1]);
     8b0:	fa442503          	lw	a0,-92(s0)
     8b4:	00000097          	auipc	ra,0x0
     8b8:	57e080e7          	jalr	1406(ra) # e32 <close>
        close(aa[0]);
     8bc:	f9842503          	lw	a0,-104(s0)
     8c0:	00000097          	auipc	ra,0x0
     8c4:	572080e7          	jalr	1394(ra) # e32 <close>
        close(1);
     8c8:	4505                	li	a0,1
     8ca:	00000097          	auipc	ra,0x0
     8ce:	568080e7          	jalr	1384(ra) # e32 <close>
        if(dup(aa[1]) != 1){
     8d2:	f9c42503          	lw	a0,-100(s0)
     8d6:	00000097          	auipc	ra,0x0
     8da:	5ac080e7          	jalr	1452(ra) # e82 <dup>
     8de:	4785                	li	a5,1
     8e0:	02f50063          	beq	a0,a5,900 <go+0x888>
          fprintf(2, "grind: dup failed\n");
     8e4:	00001597          	auipc	a1,0x1
     8e8:	cc458593          	add	a1,a1,-828 # 15a8 <malloc+0x366>
     8ec:	4509                	li	a0,2
     8ee:	00001097          	auipc	ra,0x1
     8f2:	86e080e7          	jalr	-1938(ra) # 115c <fprintf>
          exit(1);
     8f6:	4505                	li	a0,1
     8f8:	00000097          	auipc	ra,0x0
     8fc:	512080e7          	jalr	1298(ra) # e0a <exit>
        close(aa[1]);
     900:	f9c42503          	lw	a0,-100(s0)
     904:	00000097          	auipc	ra,0x0
     908:	52e080e7          	jalr	1326(ra) # e32 <close>
        char *args[3] = { "echo", "hi", 0 };
     90c:	00001797          	auipc	a5,0x1
     910:	cb478793          	add	a5,a5,-844 # 15c0 <malloc+0x37e>
     914:	faf43423          	sd	a5,-88(s0)
     918:	00001797          	auipc	a5,0x1
     91c:	cb078793          	add	a5,a5,-848 # 15c8 <malloc+0x386>
     920:	faf43823          	sd	a5,-80(s0)
     924:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     928:	fa840593          	add	a1,s0,-88
     92c:	00001517          	auipc	a0,0x1
     930:	ca450513          	add	a0,a0,-860 # 15d0 <malloc+0x38e>
     934:	00000097          	auipc	ra,0x0
     938:	50e080e7          	jalr	1294(ra) # e42 <exec>
        fprintf(2, "grind: echo: not found\n");
     93c:	00001597          	auipc	a1,0x1
     940:	ca458593          	add	a1,a1,-860 # 15e0 <malloc+0x39e>
     944:	4509                	li	a0,2
     946:	00001097          	auipc	ra,0x1
     94a:	816080e7          	jalr	-2026(ra) # 115c <fprintf>
        exit(2);
     94e:	4509                	li	a0,2
     950:	00000097          	auipc	ra,0x0
     954:	4ba080e7          	jalr	1210(ra) # e0a <exit>
        fprintf(2, "grind: fork failed\n");
     958:	00001597          	auipc	a1,0x1
     95c:	b0058593          	add	a1,a1,-1280 # 1458 <malloc+0x216>
     960:	4509                	li	a0,2
     962:	00000097          	auipc	ra,0x0
     966:	7fa080e7          	jalr	2042(ra) # 115c <fprintf>
        exit(3);
     96a:	450d                	li	a0,3
     96c:	00000097          	auipc	ra,0x0
     970:	49e080e7          	jalr	1182(ra) # e0a <exit>
        close(aa[1]);
     974:	f9c42503          	lw	a0,-100(s0)
     978:	00000097          	auipc	ra,0x0
     97c:	4ba080e7          	jalr	1210(ra) # e32 <close>
        close(bb[0]);
     980:	fa042503          	lw	a0,-96(s0)
     984:	00000097          	auipc	ra,0x0
     988:	4ae080e7          	jalr	1198(ra) # e32 <close>
        close(0);
     98c:	4501                	li	a0,0
     98e:	00000097          	auipc	ra,0x0
     992:	4a4080e7          	jalr	1188(ra) # e32 <close>
        if(dup(aa[0]) != 0){
     996:	f9842503          	lw	a0,-104(s0)
     99a:	00000097          	auipc	ra,0x0
     99e:	4e8080e7          	jalr	1256(ra) # e82 <dup>
     9a2:	cd19                	beqz	a0,9c0 <go+0x948>
          fprintf(2, "grind: dup failed\n");
     9a4:	00001597          	auipc	a1,0x1
     9a8:	c0458593          	add	a1,a1,-1020 # 15a8 <malloc+0x366>
     9ac:	4509                	li	a0,2
     9ae:	00000097          	auipc	ra,0x0
     9b2:	7ae080e7          	jalr	1966(ra) # 115c <fprintf>
          exit(4);
     9b6:	4511                	li	a0,4
     9b8:	00000097          	auipc	ra,0x0
     9bc:	452080e7          	jalr	1106(ra) # e0a <exit>
        close(aa[0]);
     9c0:	f9842503          	lw	a0,-104(s0)
     9c4:	00000097          	auipc	ra,0x0
     9c8:	46e080e7          	jalr	1134(ra) # e32 <close>
        close(1);
     9cc:	4505                	li	a0,1
     9ce:	00000097          	auipc	ra,0x0
     9d2:	464080e7          	jalr	1124(ra) # e32 <close>
        if(dup(bb[1]) != 1){
     9d6:	fa442503          	lw	a0,-92(s0)
     9da:	00000097          	auipc	ra,0x0
     9de:	4a8080e7          	jalr	1192(ra) # e82 <dup>
     9e2:	4785                	li	a5,1
     9e4:	02f50063          	beq	a0,a5,a04 <go+0x98c>
          fprintf(2, "grind: dup failed\n");
     9e8:	00001597          	auipc	a1,0x1
     9ec:	bc058593          	add	a1,a1,-1088 # 15a8 <malloc+0x366>
     9f0:	4509                	li	a0,2
     9f2:	00000097          	auipc	ra,0x0
     9f6:	76a080e7          	jalr	1898(ra) # 115c <fprintf>
          exit(5);
     9fa:	4515                	li	a0,5
     9fc:	00000097          	auipc	ra,0x0
     a00:	40e080e7          	jalr	1038(ra) # e0a <exit>
        close(bb[1]);
     a04:	fa442503          	lw	a0,-92(s0)
     a08:	00000097          	auipc	ra,0x0
     a0c:	42a080e7          	jalr	1066(ra) # e32 <close>
        char *args[2] = { "cat", 0 };
     a10:	00001797          	auipc	a5,0x1
     a14:	be878793          	add	a5,a5,-1048 # 15f8 <malloc+0x3b6>
     a18:	faf43423          	sd	a5,-88(s0)
     a1c:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     a20:	fa840593          	add	a1,s0,-88
     a24:	00001517          	auipc	a0,0x1
     a28:	bdc50513          	add	a0,a0,-1060 # 1600 <malloc+0x3be>
     a2c:	00000097          	auipc	ra,0x0
     a30:	416080e7          	jalr	1046(ra) # e42 <exec>
        fprintf(2, "grind: cat: not found\n");
     a34:	00001597          	auipc	a1,0x1
     a38:	bd458593          	add	a1,a1,-1068 # 1608 <malloc+0x3c6>
     a3c:	4509                	li	a0,2
     a3e:	00000097          	auipc	ra,0x0
     a42:	71e080e7          	jalr	1822(ra) # 115c <fprintf>
        exit(6);
     a46:	4519                	li	a0,6
     a48:	00000097          	auipc	ra,0x0
     a4c:	3c2080e7          	jalr	962(ra) # e0a <exit>
        fprintf(2, "grind: fork failed\n");
     a50:	00001597          	auipc	a1,0x1
     a54:	a0858593          	add	a1,a1,-1528 # 1458 <malloc+0x216>
     a58:	4509                	li	a0,2
     a5a:	00000097          	auipc	ra,0x0
     a5e:	702080e7          	jalr	1794(ra) # 115c <fprintf>
        exit(7);
     a62:	451d                	li	a0,7
     a64:	00000097          	auipc	ra,0x0
     a68:	3a6080e7          	jalr	934(ra) # e0a <exit>

0000000000000a6c <iter>:
  }
}

void
iter()
{
     a6c:	7179                	add	sp,sp,-48
     a6e:	f406                	sd	ra,40(sp)
     a70:	f022                	sd	s0,32(sp)
     a72:	1800                	add	s0,sp,48
  unlink("a");
     a74:	00001517          	auipc	a0,0x1
     a78:	9fc50513          	add	a0,a0,-1540 # 1470 <malloc+0x22e>
     a7c:	00000097          	auipc	ra,0x0
     a80:	3de080e7          	jalr	990(ra) # e5a <unlink>
  unlink("b");
     a84:	00001517          	auipc	a0,0x1
     a88:	99c50513          	add	a0,a0,-1636 # 1420 <malloc+0x1de>
     a8c:	00000097          	auipc	ra,0x0
     a90:	3ce080e7          	jalr	974(ra) # e5a <unlink>
  
  int pid1 = fork();
     a94:	00000097          	auipc	ra,0x0
     a98:	36e080e7          	jalr	878(ra) # e02 <fork>
  if(pid1 < 0){
     a9c:	02054063          	bltz	a0,abc <iter+0x50>
     aa0:	ec26                	sd	s1,24(sp)
     aa2:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     aa4:	e91d                	bnez	a0,ada <iter+0x6e>
     aa6:	e84a                	sd	s2,16(sp)
    rand_next = 31;
     aa8:	47fd                	li	a5,31
     aaa:	00001717          	auipc	a4,0x1
     aae:	c6f73f23          	sd	a5,-898(a4) # 1728 <rand_next>
    go(0);
     ab2:	4501                	li	a0,0
     ab4:	fffff097          	auipc	ra,0xfffff
     ab8:	5c4080e7          	jalr	1476(ra) # 78 <go>
     abc:	ec26                	sd	s1,24(sp)
     abe:	e84a                	sd	s2,16(sp)
    printf("grind: fork failed\n");
     ac0:	00001517          	auipc	a0,0x1
     ac4:	99850513          	add	a0,a0,-1640 # 1458 <malloc+0x216>
     ac8:	00000097          	auipc	ra,0x0
     acc:	6c2080e7          	jalr	1730(ra) # 118a <printf>
    exit(1);
     ad0:	4505                	li	a0,1
     ad2:	00000097          	auipc	ra,0x0
     ad6:	338080e7          	jalr	824(ra) # e0a <exit>
     ada:	e84a                	sd	s2,16(sp)
    exit(0);
  }

  int pid2 = fork();
     adc:	00000097          	auipc	ra,0x0
     ae0:	326080e7          	jalr	806(ra) # e02 <fork>
     ae4:	892a                	mv	s2,a0
  if(pid2 < 0){
     ae6:	00054f63          	bltz	a0,b04 <iter+0x98>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     aea:	e915                	bnez	a0,b1e <iter+0xb2>
    rand_next = 7177;
     aec:	6789                	lui	a5,0x2
     aee:	c0978793          	add	a5,a5,-1015 # 1c09 <__BSS_END__+0xd9>
     af2:	00001717          	auipc	a4,0x1
     af6:	c2f73b23          	sd	a5,-970(a4) # 1728 <rand_next>
    go(1);
     afa:	4505                	li	a0,1
     afc:	fffff097          	auipc	ra,0xfffff
     b00:	57c080e7          	jalr	1404(ra) # 78 <go>
    printf("grind: fork failed\n");
     b04:	00001517          	auipc	a0,0x1
     b08:	95450513          	add	a0,a0,-1708 # 1458 <malloc+0x216>
     b0c:	00000097          	auipc	ra,0x0
     b10:	67e080e7          	jalr	1662(ra) # 118a <printf>
    exit(1);
     b14:	4505                	li	a0,1
     b16:	00000097          	auipc	ra,0x0
     b1a:	2f4080e7          	jalr	756(ra) # e0a <exit>
    exit(0);
  }

  int st1 = -1;
     b1e:	57fd                	li	a5,-1
     b20:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     b24:	fdc40513          	add	a0,s0,-36
     b28:	00000097          	auipc	ra,0x0
     b2c:	2ea080e7          	jalr	746(ra) # e12 <wait>
  if(st1 != 0){
     b30:	fdc42783          	lw	a5,-36(s0)
     b34:	ef99                	bnez	a5,b52 <iter+0xe6>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     b36:	57fd                	li	a5,-1
     b38:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     b3c:	fd840513          	add	a0,s0,-40
     b40:	00000097          	auipc	ra,0x0
     b44:	2d2080e7          	jalr	722(ra) # e12 <wait>

  exit(0);
     b48:	4501                	li	a0,0
     b4a:	00000097          	auipc	ra,0x0
     b4e:	2c0080e7          	jalr	704(ra) # e0a <exit>
    kill(pid1);
     b52:	8526                	mv	a0,s1
     b54:	00000097          	auipc	ra,0x0
     b58:	2e6080e7          	jalr	742(ra) # e3a <kill>
    kill(pid2);
     b5c:	854a                	mv	a0,s2
     b5e:	00000097          	auipc	ra,0x0
     b62:	2dc080e7          	jalr	732(ra) # e3a <kill>
     b66:	bfc1                	j	b36 <iter+0xca>

0000000000000b68 <main>:
}

int
main()
{
     b68:	1141                	add	sp,sp,-16
     b6a:	e406                	sd	ra,8(sp)
     b6c:	e022                	sd	s0,0(sp)
     b6e:	0800                	add	s0,sp,16
     b70:	a811                	j	b84 <main+0x1c>
  while(1){
    int pid = fork();
    if(pid == 0){
      iter();
     b72:	00000097          	auipc	ra,0x0
     b76:	efa080e7          	jalr	-262(ra) # a6c <iter>
      exit(0);
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
     b7a:	4551                	li	a0,20
     b7c:	00000097          	auipc	ra,0x0
     b80:	31e080e7          	jalr	798(ra) # e9a <sleep>
    int pid = fork();
     b84:	00000097          	auipc	ra,0x0
     b88:	27e080e7          	jalr	638(ra) # e02 <fork>
    if(pid == 0){
     b8c:	d17d                	beqz	a0,b72 <main+0xa>
    if(pid > 0){
     b8e:	fea056e3          	blez	a0,b7a <main+0x12>
      wait(0);
     b92:	4501                	li	a0,0
     b94:	00000097          	auipc	ra,0x0
     b98:	27e080e7          	jalr	638(ra) # e12 <wait>
     b9c:	bff9                	j	b7a <main+0x12>

0000000000000b9e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     b9e:	1141                	add	sp,sp,-16
     ba0:	e422                	sd	s0,8(sp)
     ba2:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     ba4:	87aa                	mv	a5,a0
     ba6:	0585                	add	a1,a1,1
     ba8:	0785                	add	a5,a5,1
     baa:	fff5c703          	lbu	a4,-1(a1)
     bae:	fee78fa3          	sb	a4,-1(a5)
     bb2:	fb75                	bnez	a4,ba6 <strcpy+0x8>
    ;
  return os;
}
     bb4:	6422                	ld	s0,8(sp)
     bb6:	0141                	add	sp,sp,16
     bb8:	8082                	ret

0000000000000bba <strcmp>:

int
strcmp(const char *p, const char *q)
{
     bba:	1141                	add	sp,sp,-16
     bbc:	e422                	sd	s0,8(sp)
     bbe:	0800                	add	s0,sp,16
  while(*p && *p == *q)
     bc0:	00054783          	lbu	a5,0(a0)
     bc4:	cb91                	beqz	a5,bd8 <strcmp+0x1e>
     bc6:	0005c703          	lbu	a4,0(a1)
     bca:	00f71763          	bne	a4,a5,bd8 <strcmp+0x1e>
    p++, q++;
     bce:	0505                	add	a0,a0,1
     bd0:	0585                	add	a1,a1,1
  while(*p && *p == *q)
     bd2:	00054783          	lbu	a5,0(a0)
     bd6:	fbe5                	bnez	a5,bc6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     bd8:	0005c503          	lbu	a0,0(a1)
}
     bdc:	40a7853b          	subw	a0,a5,a0
     be0:	6422                	ld	s0,8(sp)
     be2:	0141                	add	sp,sp,16
     be4:	8082                	ret

0000000000000be6 <strlen>:

uint
strlen(const char *s)
{
     be6:	1141                	add	sp,sp,-16
     be8:	e422                	sd	s0,8(sp)
     bea:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     bec:	00054783          	lbu	a5,0(a0)
     bf0:	cf91                	beqz	a5,c0c <strlen+0x26>
     bf2:	0505                	add	a0,a0,1
     bf4:	87aa                	mv	a5,a0
     bf6:	86be                	mv	a3,a5
     bf8:	0785                	add	a5,a5,1
     bfa:	fff7c703          	lbu	a4,-1(a5)
     bfe:	ff65                	bnez	a4,bf6 <strlen+0x10>
     c00:	40a6853b          	subw	a0,a3,a0
     c04:	2505                	addw	a0,a0,1
    ;
  return n;
}
     c06:	6422                	ld	s0,8(sp)
     c08:	0141                	add	sp,sp,16
     c0a:	8082                	ret
  for(n = 0; s[n]; n++)
     c0c:	4501                	li	a0,0
     c0e:	bfe5                	j	c06 <strlen+0x20>

0000000000000c10 <memset>:

void*
memset(void *dst, int c, uint n)
{
     c10:	1141                	add	sp,sp,-16
     c12:	e422                	sd	s0,8(sp)
     c14:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     c16:	ca19                	beqz	a2,c2c <memset+0x1c>
     c18:	87aa                	mv	a5,a0
     c1a:	1602                	sll	a2,a2,0x20
     c1c:	9201                	srl	a2,a2,0x20
     c1e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     c22:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c26:	0785                	add	a5,a5,1
     c28:	fee79de3          	bne	a5,a4,c22 <memset+0x12>
  }
  return dst;
}
     c2c:	6422                	ld	s0,8(sp)
     c2e:	0141                	add	sp,sp,16
     c30:	8082                	ret

0000000000000c32 <strchr>:

char*
strchr(const char *s, char c)
{
     c32:	1141                	add	sp,sp,-16
     c34:	e422                	sd	s0,8(sp)
     c36:	0800                	add	s0,sp,16
  for(; *s; s++)
     c38:	00054783          	lbu	a5,0(a0)
     c3c:	cb99                	beqz	a5,c52 <strchr+0x20>
    if(*s == c)
     c3e:	00f58763          	beq	a1,a5,c4c <strchr+0x1a>
  for(; *s; s++)
     c42:	0505                	add	a0,a0,1
     c44:	00054783          	lbu	a5,0(a0)
     c48:	fbfd                	bnez	a5,c3e <strchr+0xc>
      return (char*)s;
  return 0;
     c4a:	4501                	li	a0,0
}
     c4c:	6422                	ld	s0,8(sp)
     c4e:	0141                	add	sp,sp,16
     c50:	8082                	ret
  return 0;
     c52:	4501                	li	a0,0
     c54:	bfe5                	j	c4c <strchr+0x1a>

0000000000000c56 <gets>:

char*
gets(char *buf, int max)
{
     c56:	711d                	add	sp,sp,-96
     c58:	ec86                	sd	ra,88(sp)
     c5a:	e8a2                	sd	s0,80(sp)
     c5c:	e4a6                	sd	s1,72(sp)
     c5e:	e0ca                	sd	s2,64(sp)
     c60:	fc4e                	sd	s3,56(sp)
     c62:	f852                	sd	s4,48(sp)
     c64:	f456                	sd	s5,40(sp)
     c66:	f05a                	sd	s6,32(sp)
     c68:	ec5e                	sd	s7,24(sp)
     c6a:	1080                	add	s0,sp,96
     c6c:	8baa                	mv	s7,a0
     c6e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c70:	892a                	mv	s2,a0
     c72:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     c74:	4aa9                	li	s5,10
     c76:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     c78:	89a6                	mv	s3,s1
     c7a:	2485                	addw	s1,s1,1
     c7c:	0344d863          	bge	s1,s4,cac <gets+0x56>
    cc = read(0, &c, 1);
     c80:	4605                	li	a2,1
     c82:	faf40593          	add	a1,s0,-81
     c86:	4501                	li	a0,0
     c88:	00000097          	auipc	ra,0x0
     c8c:	19a080e7          	jalr	410(ra) # e22 <read>
    if(cc < 1)
     c90:	00a05e63          	blez	a0,cac <gets+0x56>
    buf[i++] = c;
     c94:	faf44783          	lbu	a5,-81(s0)
     c98:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     c9c:	01578763          	beq	a5,s5,caa <gets+0x54>
     ca0:	0905                	add	s2,s2,1
     ca2:	fd679be3          	bne	a5,s6,c78 <gets+0x22>
    buf[i++] = c;
     ca6:	89a6                	mv	s3,s1
     ca8:	a011                	j	cac <gets+0x56>
     caa:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     cac:	99de                	add	s3,s3,s7
     cae:	00098023          	sb	zero,0(s3)
  return buf;
}
     cb2:	855e                	mv	a0,s7
     cb4:	60e6                	ld	ra,88(sp)
     cb6:	6446                	ld	s0,80(sp)
     cb8:	64a6                	ld	s1,72(sp)
     cba:	6906                	ld	s2,64(sp)
     cbc:	79e2                	ld	s3,56(sp)
     cbe:	7a42                	ld	s4,48(sp)
     cc0:	7aa2                	ld	s5,40(sp)
     cc2:	7b02                	ld	s6,32(sp)
     cc4:	6be2                	ld	s7,24(sp)
     cc6:	6125                	add	sp,sp,96
     cc8:	8082                	ret

0000000000000cca <stat>:

int
stat(const char *n, struct stat *st)
{
     cca:	1101                	add	sp,sp,-32
     ccc:	ec06                	sd	ra,24(sp)
     cce:	e822                	sd	s0,16(sp)
     cd0:	e04a                	sd	s2,0(sp)
     cd2:	1000                	add	s0,sp,32
     cd4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     cd6:	4581                	li	a1,0
     cd8:	00000097          	auipc	ra,0x0
     cdc:	172080e7          	jalr	370(ra) # e4a <open>
  if(fd < 0)
     ce0:	02054663          	bltz	a0,d0c <stat+0x42>
     ce4:	e426                	sd	s1,8(sp)
     ce6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     ce8:	85ca                	mv	a1,s2
     cea:	00000097          	auipc	ra,0x0
     cee:	178080e7          	jalr	376(ra) # e62 <fstat>
     cf2:	892a                	mv	s2,a0
  close(fd);
     cf4:	8526                	mv	a0,s1
     cf6:	00000097          	auipc	ra,0x0
     cfa:	13c080e7          	jalr	316(ra) # e32 <close>
  return r;
     cfe:	64a2                	ld	s1,8(sp)
}
     d00:	854a                	mv	a0,s2
     d02:	60e2                	ld	ra,24(sp)
     d04:	6442                	ld	s0,16(sp)
     d06:	6902                	ld	s2,0(sp)
     d08:	6105                	add	sp,sp,32
     d0a:	8082                	ret
    return -1;
     d0c:	597d                	li	s2,-1
     d0e:	bfcd                	j	d00 <stat+0x36>

0000000000000d10 <atoi>:

int
atoi(const char *s)
{
     d10:	1141                	add	sp,sp,-16
     d12:	e422                	sd	s0,8(sp)
     d14:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     d16:	00054683          	lbu	a3,0(a0)
     d1a:	fd06879b          	addw	a5,a3,-48
     d1e:	0ff7f793          	zext.b	a5,a5
     d22:	4625                	li	a2,9
     d24:	02f66863          	bltu	a2,a5,d54 <atoi+0x44>
     d28:	872a                	mv	a4,a0
  n = 0;
     d2a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     d2c:	0705                	add	a4,a4,1
     d2e:	0025179b          	sllw	a5,a0,0x2
     d32:	9fa9                	addw	a5,a5,a0
     d34:	0017979b          	sllw	a5,a5,0x1
     d38:	9fb5                	addw	a5,a5,a3
     d3a:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d3e:	00074683          	lbu	a3,0(a4)
     d42:	fd06879b          	addw	a5,a3,-48
     d46:	0ff7f793          	zext.b	a5,a5
     d4a:	fef671e3          	bgeu	a2,a5,d2c <atoi+0x1c>
  return n;
}
     d4e:	6422                	ld	s0,8(sp)
     d50:	0141                	add	sp,sp,16
     d52:	8082                	ret
  n = 0;
     d54:	4501                	li	a0,0
     d56:	bfe5                	j	d4e <atoi+0x3e>

0000000000000d58 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     d58:	1141                	add	sp,sp,-16
     d5a:	e422                	sd	s0,8(sp)
     d5c:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     d5e:	02b57463          	bgeu	a0,a1,d86 <memmove+0x2e>
    while(n-- > 0)
     d62:	00c05f63          	blez	a2,d80 <memmove+0x28>
     d66:	1602                	sll	a2,a2,0x20
     d68:	9201                	srl	a2,a2,0x20
     d6a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     d6e:	872a                	mv	a4,a0
      *dst++ = *src++;
     d70:	0585                	add	a1,a1,1
     d72:	0705                	add	a4,a4,1
     d74:	fff5c683          	lbu	a3,-1(a1)
     d78:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     d7c:	fef71ae3          	bne	a4,a5,d70 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     d80:	6422                	ld	s0,8(sp)
     d82:	0141                	add	sp,sp,16
     d84:	8082                	ret
    dst += n;
     d86:	00c50733          	add	a4,a0,a2
    src += n;
     d8a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     d8c:	fec05ae3          	blez	a2,d80 <memmove+0x28>
     d90:	fff6079b          	addw	a5,a2,-1
     d94:	1782                	sll	a5,a5,0x20
     d96:	9381                	srl	a5,a5,0x20
     d98:	fff7c793          	not	a5,a5
     d9c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     d9e:	15fd                	add	a1,a1,-1
     da0:	177d                	add	a4,a4,-1
     da2:	0005c683          	lbu	a3,0(a1)
     da6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     daa:	fee79ae3          	bne	a5,a4,d9e <memmove+0x46>
     dae:	bfc9                	j	d80 <memmove+0x28>

0000000000000db0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     db0:	1141                	add	sp,sp,-16
     db2:	e422                	sd	s0,8(sp)
     db4:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     db6:	ca05                	beqz	a2,de6 <memcmp+0x36>
     db8:	fff6069b          	addw	a3,a2,-1
     dbc:	1682                	sll	a3,a3,0x20
     dbe:	9281                	srl	a3,a3,0x20
     dc0:	0685                	add	a3,a3,1
     dc2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     dc4:	00054783          	lbu	a5,0(a0)
     dc8:	0005c703          	lbu	a4,0(a1)
     dcc:	00e79863          	bne	a5,a4,ddc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     dd0:	0505                	add	a0,a0,1
    p2++;
     dd2:	0585                	add	a1,a1,1
  while (n-- > 0) {
     dd4:	fed518e3          	bne	a0,a3,dc4 <memcmp+0x14>
  }
  return 0;
     dd8:	4501                	li	a0,0
     dda:	a019                	j	de0 <memcmp+0x30>
      return *p1 - *p2;
     ddc:	40e7853b          	subw	a0,a5,a4
}
     de0:	6422                	ld	s0,8(sp)
     de2:	0141                	add	sp,sp,16
     de4:	8082                	ret
  return 0;
     de6:	4501                	li	a0,0
     de8:	bfe5                	j	de0 <memcmp+0x30>

0000000000000dea <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     dea:	1141                	add	sp,sp,-16
     dec:	e406                	sd	ra,8(sp)
     dee:	e022                	sd	s0,0(sp)
     df0:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
     df2:	00000097          	auipc	ra,0x0
     df6:	f66080e7          	jalr	-154(ra) # d58 <memmove>
}
     dfa:	60a2                	ld	ra,8(sp)
     dfc:	6402                	ld	s0,0(sp)
     dfe:	0141                	add	sp,sp,16
     e00:	8082                	ret

0000000000000e02 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e02:	4885                	li	a7,1
 ecall
     e04:	00000073          	ecall
 ret
     e08:	8082                	ret

0000000000000e0a <exit>:
.global exit
exit:
 li a7, SYS_exit
     e0a:	4889                	li	a7,2
 ecall
     e0c:	00000073          	ecall
 ret
     e10:	8082                	ret

0000000000000e12 <wait>:
.global wait
wait:
 li a7, SYS_wait
     e12:	488d                	li	a7,3
 ecall
     e14:	00000073          	ecall
 ret
     e18:	8082                	ret

0000000000000e1a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     e1a:	4891                	li	a7,4
 ecall
     e1c:	00000073          	ecall
 ret
     e20:	8082                	ret

0000000000000e22 <read>:
.global read
read:
 li a7, SYS_read
     e22:	4895                	li	a7,5
 ecall
     e24:	00000073          	ecall
 ret
     e28:	8082                	ret

0000000000000e2a <write>:
.global write
write:
 li a7, SYS_write
     e2a:	48c1                	li	a7,16
 ecall
     e2c:	00000073          	ecall
 ret
     e30:	8082                	ret

0000000000000e32 <close>:
.global close
close:
 li a7, SYS_close
     e32:	48d5                	li	a7,21
 ecall
     e34:	00000073          	ecall
 ret
     e38:	8082                	ret

0000000000000e3a <kill>:
.global kill
kill:
 li a7, SYS_kill
     e3a:	4899                	li	a7,6
 ecall
     e3c:	00000073          	ecall
 ret
     e40:	8082                	ret

0000000000000e42 <exec>:
.global exec
exec:
 li a7, SYS_exec
     e42:	489d                	li	a7,7
 ecall
     e44:	00000073          	ecall
 ret
     e48:	8082                	ret

0000000000000e4a <open>:
.global open
open:
 li a7, SYS_open
     e4a:	48bd                	li	a7,15
 ecall
     e4c:	00000073          	ecall
 ret
     e50:	8082                	ret

0000000000000e52 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e52:	48c5                	li	a7,17
 ecall
     e54:	00000073          	ecall
 ret
     e58:	8082                	ret

0000000000000e5a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     e5a:	48c9                	li	a7,18
 ecall
     e5c:	00000073          	ecall
 ret
     e60:	8082                	ret

0000000000000e62 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     e62:	48a1                	li	a7,8
 ecall
     e64:	00000073          	ecall
 ret
     e68:	8082                	ret

0000000000000e6a <link>:
.global link
link:
 li a7, SYS_link
     e6a:	48cd                	li	a7,19
 ecall
     e6c:	00000073          	ecall
 ret
     e70:	8082                	ret

0000000000000e72 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     e72:	48d1                	li	a7,20
 ecall
     e74:	00000073          	ecall
 ret
     e78:	8082                	ret

0000000000000e7a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     e7a:	48a5                	li	a7,9
 ecall
     e7c:	00000073          	ecall
 ret
     e80:	8082                	ret

0000000000000e82 <dup>:
.global dup
dup:
 li a7, SYS_dup
     e82:	48a9                	li	a7,10
 ecall
     e84:	00000073          	ecall
 ret
     e88:	8082                	ret

0000000000000e8a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     e8a:	48ad                	li	a7,11
 ecall
     e8c:	00000073          	ecall
 ret
     e90:	8082                	ret

0000000000000e92 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     e92:	48b1                	li	a7,12
 ecall
     e94:	00000073          	ecall
 ret
     e98:	8082                	ret

0000000000000e9a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     e9a:	48b5                	li	a7,13
 ecall
     e9c:	00000073          	ecall
 ret
     ea0:	8082                	ret

0000000000000ea2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     ea2:	48b9                	li	a7,14
 ecall
     ea4:	00000073          	ecall
 ret
     ea8:	8082                	ret

0000000000000eaa <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
     eaa:	48d9                	li	a7,22
 ecall
     eac:	00000073          	ecall
 ret
     eb0:	8082                	ret

0000000000000eb2 <sematest>:
.global sematest
sematest:
 li a7, SYS_sematest
     eb2:	48dd                	li	a7,23
 ecall
     eb4:	00000073          	ecall
 ret
     eb8:	8082                	ret

0000000000000eba <rwsematest>:
.global rwsematest
rwsematest:
 li a7, SYS_rwsematest
     eba:	48e1                	li	a7,24
 ecall
     ebc:	00000073          	ecall
 ret
     ec0:	8082                	ret

0000000000000ec2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     ec2:	1101                	add	sp,sp,-32
     ec4:	ec06                	sd	ra,24(sp)
     ec6:	e822                	sd	s0,16(sp)
     ec8:	1000                	add	s0,sp,32
     eca:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     ece:	4605                	li	a2,1
     ed0:	fef40593          	add	a1,s0,-17
     ed4:	00000097          	auipc	ra,0x0
     ed8:	f56080e7          	jalr	-170(ra) # e2a <write>
}
     edc:	60e2                	ld	ra,24(sp)
     ede:	6442                	ld	s0,16(sp)
     ee0:	6105                	add	sp,sp,32
     ee2:	8082                	ret

0000000000000ee4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     ee4:	7139                	add	sp,sp,-64
     ee6:	fc06                	sd	ra,56(sp)
     ee8:	f822                	sd	s0,48(sp)
     eea:	f426                	sd	s1,40(sp)
     eec:	0080                	add	s0,sp,64
     eee:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     ef0:	c299                	beqz	a3,ef6 <printint+0x12>
     ef2:	0805cb63          	bltz	a1,f88 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     ef6:	2581                	sext.w	a1,a1
  neg = 0;
     ef8:	4881                	li	a7,0
     efa:	fc040693          	add	a3,s0,-64
  }

  i = 0;
     efe:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f00:	2601                	sext.w	a2,a2
     f02:	00001517          	auipc	a0,0x1
     f06:	80e50513          	add	a0,a0,-2034 # 1710 <digits>
     f0a:	883a                	mv	a6,a4
     f0c:	2705                	addw	a4,a4,1
     f0e:	02c5f7bb          	remuw	a5,a1,a2
     f12:	1782                	sll	a5,a5,0x20
     f14:	9381                	srl	a5,a5,0x20
     f16:	97aa                	add	a5,a5,a0
     f18:	0007c783          	lbu	a5,0(a5)
     f1c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     f20:	0005879b          	sext.w	a5,a1
     f24:	02c5d5bb          	divuw	a1,a1,a2
     f28:	0685                	add	a3,a3,1
     f2a:	fec7f0e3          	bgeu	a5,a2,f0a <printint+0x26>
  if(neg)
     f2e:	00088c63          	beqz	a7,f46 <printint+0x62>
    buf[i++] = '-';
     f32:	fd070793          	add	a5,a4,-48
     f36:	00878733          	add	a4,a5,s0
     f3a:	02d00793          	li	a5,45
     f3e:	fef70823          	sb	a5,-16(a4)
     f42:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
     f46:	02e05c63          	blez	a4,f7e <printint+0x9a>
     f4a:	f04a                	sd	s2,32(sp)
     f4c:	ec4e                	sd	s3,24(sp)
     f4e:	fc040793          	add	a5,s0,-64
     f52:	00e78933          	add	s2,a5,a4
     f56:	fff78993          	add	s3,a5,-1
     f5a:	99ba                	add	s3,s3,a4
     f5c:	377d                	addw	a4,a4,-1
     f5e:	1702                	sll	a4,a4,0x20
     f60:	9301                	srl	a4,a4,0x20
     f62:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     f66:	fff94583          	lbu	a1,-1(s2)
     f6a:	8526                	mv	a0,s1
     f6c:	00000097          	auipc	ra,0x0
     f70:	f56080e7          	jalr	-170(ra) # ec2 <putc>
  while(--i >= 0)
     f74:	197d                	add	s2,s2,-1
     f76:	ff3918e3          	bne	s2,s3,f66 <printint+0x82>
     f7a:	7902                	ld	s2,32(sp)
     f7c:	69e2                	ld	s3,24(sp)
}
     f7e:	70e2                	ld	ra,56(sp)
     f80:	7442                	ld	s0,48(sp)
     f82:	74a2                	ld	s1,40(sp)
     f84:	6121                	add	sp,sp,64
     f86:	8082                	ret
    x = -xx;
     f88:	40b005bb          	negw	a1,a1
    neg = 1;
     f8c:	4885                	li	a7,1
    x = -xx;
     f8e:	b7b5                	j	efa <printint+0x16>

0000000000000f90 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     f90:	715d                	add	sp,sp,-80
     f92:	e486                	sd	ra,72(sp)
     f94:	e0a2                	sd	s0,64(sp)
     f96:	f84a                	sd	s2,48(sp)
     f98:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     f9a:	0005c903          	lbu	s2,0(a1)
     f9e:	1a090a63          	beqz	s2,1152 <vprintf+0x1c2>
     fa2:	fc26                	sd	s1,56(sp)
     fa4:	f44e                	sd	s3,40(sp)
     fa6:	f052                	sd	s4,32(sp)
     fa8:	ec56                	sd	s5,24(sp)
     faa:	e85a                	sd	s6,16(sp)
     fac:	e45e                	sd	s7,8(sp)
     fae:	8aaa                	mv	s5,a0
     fb0:	8bb2                	mv	s7,a2
     fb2:	00158493          	add	s1,a1,1
  state = 0;
     fb6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     fb8:	02500a13          	li	s4,37
     fbc:	4b55                	li	s6,21
     fbe:	a839                	j	fdc <vprintf+0x4c>
        putc(fd, c);
     fc0:	85ca                	mv	a1,s2
     fc2:	8556                	mv	a0,s5
     fc4:	00000097          	auipc	ra,0x0
     fc8:	efe080e7          	jalr	-258(ra) # ec2 <putc>
     fcc:	a019                	j	fd2 <vprintf+0x42>
    } else if(state == '%'){
     fce:	01498d63          	beq	s3,s4,fe8 <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
     fd2:	0485                	add	s1,s1,1
     fd4:	fff4c903          	lbu	s2,-1(s1)
     fd8:	16090763          	beqz	s2,1146 <vprintf+0x1b6>
    if(state == 0){
     fdc:	fe0999e3          	bnez	s3,fce <vprintf+0x3e>
      if(c == '%'){
     fe0:	ff4910e3          	bne	s2,s4,fc0 <vprintf+0x30>
        state = '%';
     fe4:	89d2                	mv	s3,s4
     fe6:	b7f5                	j	fd2 <vprintf+0x42>
      if(c == 'd'){
     fe8:	13490463          	beq	s2,s4,1110 <vprintf+0x180>
     fec:	f9d9079b          	addw	a5,s2,-99
     ff0:	0ff7f793          	zext.b	a5,a5
     ff4:	12fb6763          	bltu	s6,a5,1122 <vprintf+0x192>
     ff8:	f9d9079b          	addw	a5,s2,-99
     ffc:	0ff7f713          	zext.b	a4,a5
    1000:	12eb6163          	bltu	s6,a4,1122 <vprintf+0x192>
    1004:	00271793          	sll	a5,a4,0x2
    1008:	00000717          	auipc	a4,0x0
    100c:	6b070713          	add	a4,a4,1712 # 16b8 <malloc+0x476>
    1010:	97ba                	add	a5,a5,a4
    1012:	439c                	lw	a5,0(a5)
    1014:	97ba                	add	a5,a5,a4
    1016:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
    1018:	008b8913          	add	s2,s7,8
    101c:	4685                	li	a3,1
    101e:	4629                	li	a2,10
    1020:	000ba583          	lw	a1,0(s7)
    1024:	8556                	mv	a0,s5
    1026:	00000097          	auipc	ra,0x0
    102a:	ebe080e7          	jalr	-322(ra) # ee4 <printint>
    102e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    1030:	4981                	li	s3,0
    1032:	b745                	j	fd2 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1034:	008b8913          	add	s2,s7,8
    1038:	4681                	li	a3,0
    103a:	4629                	li	a2,10
    103c:	000ba583          	lw	a1,0(s7)
    1040:	8556                	mv	a0,s5
    1042:	00000097          	auipc	ra,0x0
    1046:	ea2080e7          	jalr	-350(ra) # ee4 <printint>
    104a:	8bca                	mv	s7,s2
      state = 0;
    104c:	4981                	li	s3,0
    104e:	b751                	j	fd2 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
    1050:	008b8913          	add	s2,s7,8
    1054:	4681                	li	a3,0
    1056:	4641                	li	a2,16
    1058:	000ba583          	lw	a1,0(s7)
    105c:	8556                	mv	a0,s5
    105e:	00000097          	auipc	ra,0x0
    1062:	e86080e7          	jalr	-378(ra) # ee4 <printint>
    1066:	8bca                	mv	s7,s2
      state = 0;
    1068:	4981                	li	s3,0
    106a:	b7a5                	j	fd2 <vprintf+0x42>
    106c:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
    106e:	008b8c13          	add	s8,s7,8
    1072:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    1076:	03000593          	li	a1,48
    107a:	8556                	mv	a0,s5
    107c:	00000097          	auipc	ra,0x0
    1080:	e46080e7          	jalr	-442(ra) # ec2 <putc>
  putc(fd, 'x');
    1084:	07800593          	li	a1,120
    1088:	8556                	mv	a0,s5
    108a:	00000097          	auipc	ra,0x0
    108e:	e38080e7          	jalr	-456(ra) # ec2 <putc>
    1092:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1094:	00000b97          	auipc	s7,0x0
    1098:	67cb8b93          	add	s7,s7,1660 # 1710 <digits>
    109c:	03c9d793          	srl	a5,s3,0x3c
    10a0:	97de                	add	a5,a5,s7
    10a2:	0007c583          	lbu	a1,0(a5)
    10a6:	8556                	mv	a0,s5
    10a8:	00000097          	auipc	ra,0x0
    10ac:	e1a080e7          	jalr	-486(ra) # ec2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    10b0:	0992                	sll	s3,s3,0x4
    10b2:	397d                	addw	s2,s2,-1
    10b4:	fe0914e3          	bnez	s2,109c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
    10b8:	8be2                	mv	s7,s8
      state = 0;
    10ba:	4981                	li	s3,0
    10bc:	6c02                	ld	s8,0(sp)
    10be:	bf11                	j	fd2 <vprintf+0x42>
        s = va_arg(ap, char*);
    10c0:	008b8993          	add	s3,s7,8
    10c4:	000bb903          	ld	s2,0(s7)
        if(s == 0)
    10c8:	02090163          	beqz	s2,10ea <vprintf+0x15a>
        while(*s != 0){
    10cc:	00094583          	lbu	a1,0(s2)
    10d0:	c9a5                	beqz	a1,1140 <vprintf+0x1b0>
          putc(fd, *s);
    10d2:	8556                	mv	a0,s5
    10d4:	00000097          	auipc	ra,0x0
    10d8:	dee080e7          	jalr	-530(ra) # ec2 <putc>
          s++;
    10dc:	0905                	add	s2,s2,1
        while(*s != 0){
    10de:	00094583          	lbu	a1,0(s2)
    10e2:	f9e5                	bnez	a1,10d2 <vprintf+0x142>
        s = va_arg(ap, char*);
    10e4:	8bce                	mv	s7,s3
      state = 0;
    10e6:	4981                	li	s3,0
    10e8:	b5ed                	j	fd2 <vprintf+0x42>
          s = "(null)";
    10ea:	00000917          	auipc	s2,0x0
    10ee:	56690913          	add	s2,s2,1382 # 1650 <malloc+0x40e>
        while(*s != 0){
    10f2:	02800593          	li	a1,40
    10f6:	bff1                	j	10d2 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
    10f8:	008b8913          	add	s2,s7,8
    10fc:	000bc583          	lbu	a1,0(s7)
    1100:	8556                	mv	a0,s5
    1102:	00000097          	auipc	ra,0x0
    1106:	dc0080e7          	jalr	-576(ra) # ec2 <putc>
    110a:	8bca                	mv	s7,s2
      state = 0;
    110c:	4981                	li	s3,0
    110e:	b5d1                	j	fd2 <vprintf+0x42>
        putc(fd, c);
    1110:	02500593          	li	a1,37
    1114:	8556                	mv	a0,s5
    1116:	00000097          	auipc	ra,0x0
    111a:	dac080e7          	jalr	-596(ra) # ec2 <putc>
      state = 0;
    111e:	4981                	li	s3,0
    1120:	bd4d                	j	fd2 <vprintf+0x42>
        putc(fd, '%');
    1122:	02500593          	li	a1,37
    1126:	8556                	mv	a0,s5
    1128:	00000097          	auipc	ra,0x0
    112c:	d9a080e7          	jalr	-614(ra) # ec2 <putc>
        putc(fd, c);
    1130:	85ca                	mv	a1,s2
    1132:	8556                	mv	a0,s5
    1134:	00000097          	auipc	ra,0x0
    1138:	d8e080e7          	jalr	-626(ra) # ec2 <putc>
      state = 0;
    113c:	4981                	li	s3,0
    113e:	bd51                	j	fd2 <vprintf+0x42>
        s = va_arg(ap, char*);
    1140:	8bce                	mv	s7,s3
      state = 0;
    1142:	4981                	li	s3,0
    1144:	b579                	j	fd2 <vprintf+0x42>
    1146:	74e2                	ld	s1,56(sp)
    1148:	79a2                	ld	s3,40(sp)
    114a:	7a02                	ld	s4,32(sp)
    114c:	6ae2                	ld	s5,24(sp)
    114e:	6b42                	ld	s6,16(sp)
    1150:	6ba2                	ld	s7,8(sp)
    }
  }
}
    1152:	60a6                	ld	ra,72(sp)
    1154:	6406                	ld	s0,64(sp)
    1156:	7942                	ld	s2,48(sp)
    1158:	6161                	add	sp,sp,80
    115a:	8082                	ret

000000000000115c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    115c:	715d                	add	sp,sp,-80
    115e:	ec06                	sd	ra,24(sp)
    1160:	e822                	sd	s0,16(sp)
    1162:	1000                	add	s0,sp,32
    1164:	e010                	sd	a2,0(s0)
    1166:	e414                	sd	a3,8(s0)
    1168:	e818                	sd	a4,16(s0)
    116a:	ec1c                	sd	a5,24(s0)
    116c:	03043023          	sd	a6,32(s0)
    1170:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1174:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1178:	8622                	mv	a2,s0
    117a:	00000097          	auipc	ra,0x0
    117e:	e16080e7          	jalr	-490(ra) # f90 <vprintf>
}
    1182:	60e2                	ld	ra,24(sp)
    1184:	6442                	ld	s0,16(sp)
    1186:	6161                	add	sp,sp,80
    1188:	8082                	ret

000000000000118a <printf>:

void
printf(const char *fmt, ...)
{
    118a:	711d                	add	sp,sp,-96
    118c:	ec06                	sd	ra,24(sp)
    118e:	e822                	sd	s0,16(sp)
    1190:	1000                	add	s0,sp,32
    1192:	e40c                	sd	a1,8(s0)
    1194:	e810                	sd	a2,16(s0)
    1196:	ec14                	sd	a3,24(s0)
    1198:	f018                	sd	a4,32(s0)
    119a:	f41c                	sd	a5,40(s0)
    119c:	03043823          	sd	a6,48(s0)
    11a0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    11a4:	00840613          	add	a2,s0,8
    11a8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    11ac:	85aa                	mv	a1,a0
    11ae:	4505                	li	a0,1
    11b0:	00000097          	auipc	ra,0x0
    11b4:	de0080e7          	jalr	-544(ra) # f90 <vprintf>
}
    11b8:	60e2                	ld	ra,24(sp)
    11ba:	6442                	ld	s0,16(sp)
    11bc:	6125                	add	sp,sp,96
    11be:	8082                	ret

00000000000011c0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    11c0:	1141                	add	sp,sp,-16
    11c2:	e422                	sd	s0,8(sp)
    11c4:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    11c6:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11ca:	00000797          	auipc	a5,0x0
    11ce:	5667b783          	ld	a5,1382(a5) # 1730 <freep>
    11d2:	a02d                	j	11fc <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    11d4:	4618                	lw	a4,8(a2)
    11d6:	9f2d                	addw	a4,a4,a1
    11d8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    11dc:	6398                	ld	a4,0(a5)
    11de:	6310                	ld	a2,0(a4)
    11e0:	a83d                	j	121e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    11e2:	ff852703          	lw	a4,-8(a0)
    11e6:	9f31                	addw	a4,a4,a2
    11e8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    11ea:	ff053683          	ld	a3,-16(a0)
    11ee:	a091                	j	1232 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    11f0:	6398                	ld	a4,0(a5)
    11f2:	00e7e463          	bltu	a5,a4,11fa <free+0x3a>
    11f6:	00e6ea63          	bltu	a3,a4,120a <free+0x4a>
{
    11fa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11fc:	fed7fae3          	bgeu	a5,a3,11f0 <free+0x30>
    1200:	6398                	ld	a4,0(a5)
    1202:	00e6e463          	bltu	a3,a4,120a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1206:	fee7eae3          	bltu	a5,a4,11fa <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    120a:	ff852583          	lw	a1,-8(a0)
    120e:	6390                	ld	a2,0(a5)
    1210:	02059813          	sll	a6,a1,0x20
    1214:	01c85713          	srl	a4,a6,0x1c
    1218:	9736                	add	a4,a4,a3
    121a:	fae60de3          	beq	a2,a4,11d4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    121e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1222:	4790                	lw	a2,8(a5)
    1224:	02061593          	sll	a1,a2,0x20
    1228:	01c5d713          	srl	a4,a1,0x1c
    122c:	973e                	add	a4,a4,a5
    122e:	fae68ae3          	beq	a3,a4,11e2 <free+0x22>
    p->s.ptr = bp->s.ptr;
    1232:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1234:	00000717          	auipc	a4,0x0
    1238:	4ef73e23          	sd	a5,1276(a4) # 1730 <freep>
}
    123c:	6422                	ld	s0,8(sp)
    123e:	0141                	add	sp,sp,16
    1240:	8082                	ret

0000000000001242 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1242:	7139                	add	sp,sp,-64
    1244:	fc06                	sd	ra,56(sp)
    1246:	f822                	sd	s0,48(sp)
    1248:	f426                	sd	s1,40(sp)
    124a:	ec4e                	sd	s3,24(sp)
    124c:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    124e:	02051493          	sll	s1,a0,0x20
    1252:	9081                	srl	s1,s1,0x20
    1254:	04bd                	add	s1,s1,15
    1256:	8091                	srl	s1,s1,0x4
    1258:	0014899b          	addw	s3,s1,1
    125c:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
    125e:	00000517          	auipc	a0,0x0
    1262:	4d253503          	ld	a0,1234(a0) # 1730 <freep>
    1266:	c915                	beqz	a0,129a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1268:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    126a:	4798                	lw	a4,8(a5)
    126c:	08977e63          	bgeu	a4,s1,1308 <malloc+0xc6>
    1270:	f04a                	sd	s2,32(sp)
    1272:	e852                	sd	s4,16(sp)
    1274:	e456                	sd	s5,8(sp)
    1276:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    1278:	8a4e                	mv	s4,s3
    127a:	0009871b          	sext.w	a4,s3
    127e:	6685                	lui	a3,0x1
    1280:	00d77363          	bgeu	a4,a3,1286 <malloc+0x44>
    1284:	6a05                	lui	s4,0x1
    1286:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    128a:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    128e:	00000917          	auipc	s2,0x0
    1292:	4a290913          	add	s2,s2,1186 # 1730 <freep>
  if(p == (char*)-1)
    1296:	5afd                	li	s5,-1
    1298:	a091                	j	12dc <malloc+0x9a>
    129a:	f04a                	sd	s2,32(sp)
    129c:	e852                	sd	s4,16(sp)
    129e:	e456                	sd	s5,8(sp)
    12a0:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    12a2:	00001797          	auipc	a5,0x1
    12a6:	87e78793          	add	a5,a5,-1922 # 1b20 <base>
    12aa:	00000717          	auipc	a4,0x0
    12ae:	48f73323          	sd	a5,1158(a4) # 1730 <freep>
    12b2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    12b4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    12b8:	b7c1                	j	1278 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    12ba:	6398                	ld	a4,0(a5)
    12bc:	e118                	sd	a4,0(a0)
    12be:	a08d                	j	1320 <malloc+0xde>
  hp->s.size = nu;
    12c0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    12c4:	0541                	add	a0,a0,16
    12c6:	00000097          	auipc	ra,0x0
    12ca:	efa080e7          	jalr	-262(ra) # 11c0 <free>
  return freep;
    12ce:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    12d2:	c13d                	beqz	a0,1338 <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12d6:	4798                	lw	a4,8(a5)
    12d8:	02977463          	bgeu	a4,s1,1300 <malloc+0xbe>
    if(p == freep)
    12dc:	00093703          	ld	a4,0(s2)
    12e0:	853e                	mv	a0,a5
    12e2:	fef719e3          	bne	a4,a5,12d4 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
    12e6:	8552                	mv	a0,s4
    12e8:	00000097          	auipc	ra,0x0
    12ec:	baa080e7          	jalr	-1110(ra) # e92 <sbrk>
  if(p == (char*)-1)
    12f0:	fd5518e3          	bne	a0,s5,12c0 <malloc+0x7e>
        return 0;
    12f4:	4501                	li	a0,0
    12f6:	7902                	ld	s2,32(sp)
    12f8:	6a42                	ld	s4,16(sp)
    12fa:	6aa2                	ld	s5,8(sp)
    12fc:	6b02                	ld	s6,0(sp)
    12fe:	a03d                	j	132c <malloc+0xea>
    1300:	7902                	ld	s2,32(sp)
    1302:	6a42                	ld	s4,16(sp)
    1304:	6aa2                	ld	s5,8(sp)
    1306:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    1308:	fae489e3          	beq	s1,a4,12ba <malloc+0x78>
        p->s.size -= nunits;
    130c:	4137073b          	subw	a4,a4,s3
    1310:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1312:	02071693          	sll	a3,a4,0x20
    1316:	01c6d713          	srl	a4,a3,0x1c
    131a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    131c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1320:	00000717          	auipc	a4,0x0
    1324:	40a73823          	sd	a0,1040(a4) # 1730 <freep>
      return (void*)(p + 1);
    1328:	01078513          	add	a0,a5,16
  }
}
    132c:	70e2                	ld	ra,56(sp)
    132e:	7442                	ld	s0,48(sp)
    1330:	74a2                	ld	s1,40(sp)
    1332:	69e2                	ld	s3,24(sp)
    1334:	6121                	add	sp,sp,64
    1336:	8082                	ret
    1338:	7902                	ld	s2,32(sp)
    133a:	6a42                	ld	s4,16(sp)
    133c:	6aa2                	ld	s5,8(sp)
    133e:	6b02                	ld	s6,0(sp)
    1340:	b7f5                	j	132c <malloc+0xea>
