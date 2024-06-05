
_recurse:     file format elf32-i386


Disassembly of section .text:

00000000 <recurse>:
// Prevent this function from being optimized, which might give it closed form
#pragma GCC push_options
#pragma GCC optimize ("O0")

static int recurse(int n)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  if(n == 0)
   6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
   a:	75 07                	jne    13 <recurse+0x13>
    return 0;
   c:	b8 00 00 00 00       	mov    $0x0,%eax
  11:	eb 17                	jmp    2a <recurse+0x2a>
  return n + recurse(n - 1);
  13:	8b 45 08             	mov    0x8(%ebp),%eax
  16:	83 e8 01             	sub    $0x1,%eax
  19:	83 ec 0c             	sub    $0xc,%esp
  1c:	50                   	push   %eax
  1d:	e8 de ff ff ff       	call   0 <recurse>
  22:	83 c4 10             	add    $0x10,%esp
  25:	8b 55 08             	mov    0x8(%ebp),%edx
  28:	01 d0                	add    %edx,%eax
}
  2a:	c9                   	leave  
  2b:	c3                   	ret    

0000002c <main>:
#pragma GCC pop_options

int main(int argc, char *argv[])
{
  2c:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  30:	83 e4 f0             	and    $0xfffffff0,%esp
  33:	ff 71 fc             	push   -0x4(%ecx)
  36:	55                   	push   %ebp
  37:	89 e5                	mov    %esp,%ebp
  39:	51                   	push   %ecx
  3a:	83 ec 14             	sub    $0x14,%esp
  3d:	89 c8                	mov    %ecx,%eax
  int n, m;

  if(argc != 2){
  3f:	83 38 02             	cmpl   $0x2,(%eax)
  42:	74 1d                	je     61 <main+0x35>
    printf(1, "Usage: %s levels\n", argv[0]);
  44:	8b 40 04             	mov    0x4(%eax),%eax
  47:	8b 00                	mov    (%eax),%eax
  49:	83 ec 04             	sub    $0x4,%esp
  4c:	50                   	push   %eax
  4d:	68 53 08 00 00       	push   $0x853
  52:	6a 01                	push   $0x1
  54:	e8 43 04 00 00       	call   49c <printf>
  59:	83 c4 10             	add    $0x10,%esp
    exit();
  5c:	e8 bf 02 00 00       	call   320 <exit>
  }
  // printpt(getpid()); // Uncomment for the test.
  n = atoi(argv[1]);
  61:	8b 40 04             	mov    0x4(%eax),%eax
  64:	83 c0 04             	add    $0x4,%eax
  67:	8b 00                	mov    (%eax),%eax
  69:	83 ec 0c             	sub    $0xc,%esp
  6c:	50                   	push   %eax
  6d:	e8 1c 02 00 00       	call   28e <atoi>
  72:	83 c4 10             	add    $0x10,%esp
  75:	89 45 f4             	mov    %eax,-0xc(%ebp)
  printf(1, "Recursing %d levels\n", n);
  78:	83 ec 04             	sub    $0x4,%esp
  7b:	ff 75 f4             	push   -0xc(%ebp)
  7e:	68 65 08 00 00       	push   $0x865
  83:	6a 01                	push   $0x1
  85:	e8 12 04 00 00       	call   49c <printf>
  8a:	83 c4 10             	add    $0x10,%esp
  m = recurse(n);
  8d:	83 ec 0c             	sub    $0xc,%esp
  90:	ff 75 f4             	push   -0xc(%ebp)
  93:	e8 68 ff ff ff       	call   0 <recurse>
  98:	83 c4 10             	add    $0x10,%esp
  9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  printf(1, "Yielded a value of %d\n", m);
  9e:	83 ec 04             	sub    $0x4,%esp
  a1:	ff 75 f0             	push   -0x10(%ebp)
  a4:	68 7a 08 00 00       	push   $0x87a
  a9:	6a 01                	push   $0x1
  ab:	e8 ec 03 00 00       	call   49c <printf>
  b0:	83 c4 10             	add    $0x10,%esp
  printpt(getpid()); // Uncomment for the test.
  b3:	e8 e8 02 00 00       	call   3a0 <getpid>
  b8:	83 ec 0c             	sub    $0xc,%esp
  bb:	50                   	push   %eax
  bc:	e8 ff 02 00 00       	call   3c0 <printpt>
  c1:	83 c4 10             	add    $0x10,%esp
  exit();
  c4:	e8 57 02 00 00       	call   320 <exit>

000000c9 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  c9:	55                   	push   %ebp
  ca:	89 e5                	mov    %esp,%ebp
  cc:	57                   	push   %edi
  cd:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  d1:	8b 55 10             	mov    0x10(%ebp),%edx
  d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  d7:	89 cb                	mov    %ecx,%ebx
  d9:	89 df                	mov    %ebx,%edi
  db:	89 d1                	mov    %edx,%ecx
  dd:	fc                   	cld    
  de:	f3 aa                	rep stos %al,%es:(%edi)
  e0:	89 ca                	mov    %ecx,%edx
  e2:	89 fb                	mov    %edi,%ebx
  e4:	89 5d 08             	mov    %ebx,0x8(%ebp)
  e7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  ea:	90                   	nop
  eb:	5b                   	pop    %ebx
  ec:	5f                   	pop    %edi
  ed:	5d                   	pop    %ebp
  ee:	c3                   	ret    

000000ef <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  ef:	55                   	push   %ebp
  f0:	89 e5                	mov    %esp,%ebp
  f2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  f5:	8b 45 08             	mov    0x8(%ebp),%eax
  f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  fb:	90                   	nop
  fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  ff:	8d 42 01             	lea    0x1(%edx),%eax
 102:	89 45 0c             	mov    %eax,0xc(%ebp)
 105:	8b 45 08             	mov    0x8(%ebp),%eax
 108:	8d 48 01             	lea    0x1(%eax),%ecx
 10b:	89 4d 08             	mov    %ecx,0x8(%ebp)
 10e:	0f b6 12             	movzbl (%edx),%edx
 111:	88 10                	mov    %dl,(%eax)
 113:	0f b6 00             	movzbl (%eax),%eax
 116:	84 c0                	test   %al,%al
 118:	75 e2                	jne    fc <strcpy+0xd>
    ;
  return os;
 11a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 11d:	c9                   	leave  
 11e:	c3                   	ret    

0000011f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11f:	55                   	push   %ebp
 120:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 122:	eb 08                	jmp    12c <strcmp+0xd>
    p++, q++;
 124:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 128:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 12c:	8b 45 08             	mov    0x8(%ebp),%eax
 12f:	0f b6 00             	movzbl (%eax),%eax
 132:	84 c0                	test   %al,%al
 134:	74 10                	je     146 <strcmp+0x27>
 136:	8b 45 08             	mov    0x8(%ebp),%eax
 139:	0f b6 10             	movzbl (%eax),%edx
 13c:	8b 45 0c             	mov    0xc(%ebp),%eax
 13f:	0f b6 00             	movzbl (%eax),%eax
 142:	38 c2                	cmp    %al,%dl
 144:	74 de                	je     124 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 146:	8b 45 08             	mov    0x8(%ebp),%eax
 149:	0f b6 00             	movzbl (%eax),%eax
 14c:	0f b6 d0             	movzbl %al,%edx
 14f:	8b 45 0c             	mov    0xc(%ebp),%eax
 152:	0f b6 00             	movzbl (%eax),%eax
 155:	0f b6 c8             	movzbl %al,%ecx
 158:	89 d0                	mov    %edx,%eax
 15a:	29 c8                	sub    %ecx,%eax
}
 15c:	5d                   	pop    %ebp
 15d:	c3                   	ret    

0000015e <strlen>:

uint
strlen(char *s)
{
 15e:	55                   	push   %ebp
 15f:	89 e5                	mov    %esp,%ebp
 161:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 164:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 16b:	eb 04                	jmp    171 <strlen+0x13>
 16d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 171:	8b 55 fc             	mov    -0x4(%ebp),%edx
 174:	8b 45 08             	mov    0x8(%ebp),%eax
 177:	01 d0                	add    %edx,%eax
 179:	0f b6 00             	movzbl (%eax),%eax
 17c:	84 c0                	test   %al,%al
 17e:	75 ed                	jne    16d <strlen+0xf>
    ;
  return n;
 180:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 183:	c9                   	leave  
 184:	c3                   	ret    

00000185 <memset>:

void*
memset(void *dst, int c, uint n)
{
 185:	55                   	push   %ebp
 186:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 188:	8b 45 10             	mov    0x10(%ebp),%eax
 18b:	50                   	push   %eax
 18c:	ff 75 0c             	push   0xc(%ebp)
 18f:	ff 75 08             	push   0x8(%ebp)
 192:	e8 32 ff ff ff       	call   c9 <stosb>
 197:	83 c4 0c             	add    $0xc,%esp
  return dst;
 19a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 19d:	c9                   	leave  
 19e:	c3                   	ret    

0000019f <strchr>:

char*
strchr(const char *s, char c)
{
 19f:	55                   	push   %ebp
 1a0:	89 e5                	mov    %esp,%ebp
 1a2:	83 ec 04             	sub    $0x4,%esp
 1a5:	8b 45 0c             	mov    0xc(%ebp),%eax
 1a8:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1ab:	eb 14                	jmp    1c1 <strchr+0x22>
    if(*s == c)
 1ad:	8b 45 08             	mov    0x8(%ebp),%eax
 1b0:	0f b6 00             	movzbl (%eax),%eax
 1b3:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1b6:	75 05                	jne    1bd <strchr+0x1e>
      return (char*)s;
 1b8:	8b 45 08             	mov    0x8(%ebp),%eax
 1bb:	eb 13                	jmp    1d0 <strchr+0x31>
  for(; *s; s++)
 1bd:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1c1:	8b 45 08             	mov    0x8(%ebp),%eax
 1c4:	0f b6 00             	movzbl (%eax),%eax
 1c7:	84 c0                	test   %al,%al
 1c9:	75 e2                	jne    1ad <strchr+0xe>
  return 0;
 1cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1d0:	c9                   	leave  
 1d1:	c3                   	ret    

000001d2 <gets>:

char*
gets(char *buf, int max)
{
 1d2:	55                   	push   %ebp
 1d3:	89 e5                	mov    %esp,%ebp
 1d5:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1df:	eb 42                	jmp    223 <gets+0x51>
    cc = read(0, &c, 1);
 1e1:	83 ec 04             	sub    $0x4,%esp
 1e4:	6a 01                	push   $0x1
 1e6:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1e9:	50                   	push   %eax
 1ea:	6a 00                	push   $0x0
 1ec:	e8 47 01 00 00       	call   338 <read>
 1f1:	83 c4 10             	add    $0x10,%esp
 1f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1fb:	7e 33                	jle    230 <gets+0x5e>
      break;
    buf[i++] = c;
 1fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 200:	8d 50 01             	lea    0x1(%eax),%edx
 203:	89 55 f4             	mov    %edx,-0xc(%ebp)
 206:	89 c2                	mov    %eax,%edx
 208:	8b 45 08             	mov    0x8(%ebp),%eax
 20b:	01 c2                	add    %eax,%edx
 20d:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 211:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 213:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 217:	3c 0a                	cmp    $0xa,%al
 219:	74 16                	je     231 <gets+0x5f>
 21b:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 21f:	3c 0d                	cmp    $0xd,%al
 221:	74 0e                	je     231 <gets+0x5f>
  for(i=0; i+1 < max; ){
 223:	8b 45 f4             	mov    -0xc(%ebp),%eax
 226:	83 c0 01             	add    $0x1,%eax
 229:	39 45 0c             	cmp    %eax,0xc(%ebp)
 22c:	7f b3                	jg     1e1 <gets+0xf>
 22e:	eb 01                	jmp    231 <gets+0x5f>
      break;
 230:	90                   	nop
      break;
  }
  buf[i] = '\0';
 231:	8b 55 f4             	mov    -0xc(%ebp),%edx
 234:	8b 45 08             	mov    0x8(%ebp),%eax
 237:	01 d0                	add    %edx,%eax
 239:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 23c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 23f:	c9                   	leave  
 240:	c3                   	ret    

00000241 <stat>:

int
stat(char *n, struct stat *st)
{
 241:	55                   	push   %ebp
 242:	89 e5                	mov    %esp,%ebp
 244:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 247:	83 ec 08             	sub    $0x8,%esp
 24a:	6a 00                	push   $0x0
 24c:	ff 75 08             	push   0x8(%ebp)
 24f:	e8 0c 01 00 00       	call   360 <open>
 254:	83 c4 10             	add    $0x10,%esp
 257:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 25a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 25e:	79 07                	jns    267 <stat+0x26>
    return -1;
 260:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 265:	eb 25                	jmp    28c <stat+0x4b>
  r = fstat(fd, st);
 267:	83 ec 08             	sub    $0x8,%esp
 26a:	ff 75 0c             	push   0xc(%ebp)
 26d:	ff 75 f4             	push   -0xc(%ebp)
 270:	e8 03 01 00 00       	call   378 <fstat>
 275:	83 c4 10             	add    $0x10,%esp
 278:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 27b:	83 ec 0c             	sub    $0xc,%esp
 27e:	ff 75 f4             	push   -0xc(%ebp)
 281:	e8 c2 00 00 00       	call   348 <close>
 286:	83 c4 10             	add    $0x10,%esp
  return r;
 289:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 28c:	c9                   	leave  
 28d:	c3                   	ret    

0000028e <atoi>:

int
atoi(const char *s)
{
 28e:	55                   	push   %ebp
 28f:	89 e5                	mov    %esp,%ebp
 291:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 294:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 29b:	eb 25                	jmp    2c2 <atoi+0x34>
    n = n*10 + *s++ - '0';
 29d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2a0:	89 d0                	mov    %edx,%eax
 2a2:	c1 e0 02             	shl    $0x2,%eax
 2a5:	01 d0                	add    %edx,%eax
 2a7:	01 c0                	add    %eax,%eax
 2a9:	89 c1                	mov    %eax,%ecx
 2ab:	8b 45 08             	mov    0x8(%ebp),%eax
 2ae:	8d 50 01             	lea    0x1(%eax),%edx
 2b1:	89 55 08             	mov    %edx,0x8(%ebp)
 2b4:	0f b6 00             	movzbl (%eax),%eax
 2b7:	0f be c0             	movsbl %al,%eax
 2ba:	01 c8                	add    %ecx,%eax
 2bc:	83 e8 30             	sub    $0x30,%eax
 2bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2c2:	8b 45 08             	mov    0x8(%ebp),%eax
 2c5:	0f b6 00             	movzbl (%eax),%eax
 2c8:	3c 2f                	cmp    $0x2f,%al
 2ca:	7e 0a                	jle    2d6 <atoi+0x48>
 2cc:	8b 45 08             	mov    0x8(%ebp),%eax
 2cf:	0f b6 00             	movzbl (%eax),%eax
 2d2:	3c 39                	cmp    $0x39,%al
 2d4:	7e c7                	jle    29d <atoi+0xf>
  return n;
 2d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2d9:	c9                   	leave  
 2da:	c3                   	ret    

000002db <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2db:	55                   	push   %ebp
 2dc:	89 e5                	mov    %esp,%ebp
 2de:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 2e1:	8b 45 08             	mov    0x8(%ebp),%eax
 2e4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ea:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2ed:	eb 17                	jmp    306 <memmove+0x2b>
    *dst++ = *src++;
 2ef:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2f2:	8d 42 01             	lea    0x1(%edx),%eax
 2f5:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2fb:	8d 48 01             	lea    0x1(%eax),%ecx
 2fe:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 301:	0f b6 12             	movzbl (%edx),%edx
 304:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 306:	8b 45 10             	mov    0x10(%ebp),%eax
 309:	8d 50 ff             	lea    -0x1(%eax),%edx
 30c:	89 55 10             	mov    %edx,0x10(%ebp)
 30f:	85 c0                	test   %eax,%eax
 311:	7f dc                	jg     2ef <memmove+0x14>
  return vdst;
 313:	8b 45 08             	mov    0x8(%ebp),%eax
}
 316:	c9                   	leave  
 317:	c3                   	ret    

00000318 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 318:	b8 01 00 00 00       	mov    $0x1,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <exit>:
SYSCALL(exit)
 320:	b8 02 00 00 00       	mov    $0x2,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <wait>:
SYSCALL(wait)
 328:	b8 03 00 00 00       	mov    $0x3,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <pipe>:
SYSCALL(pipe)
 330:	b8 04 00 00 00       	mov    $0x4,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <read>:
SYSCALL(read)
 338:	b8 05 00 00 00       	mov    $0x5,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <write>:
SYSCALL(write)
 340:	b8 10 00 00 00       	mov    $0x10,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <close>:
SYSCALL(close)
 348:	b8 15 00 00 00       	mov    $0x15,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <kill>:
SYSCALL(kill)
 350:	b8 06 00 00 00       	mov    $0x6,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <exec>:
SYSCALL(exec)
 358:	b8 07 00 00 00       	mov    $0x7,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <open>:
SYSCALL(open)
 360:	b8 0f 00 00 00       	mov    $0xf,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <mknod>:
SYSCALL(mknod)
 368:	b8 11 00 00 00       	mov    $0x11,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <unlink>:
SYSCALL(unlink)
 370:	b8 12 00 00 00       	mov    $0x12,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <fstat>:
SYSCALL(fstat)
 378:	b8 08 00 00 00       	mov    $0x8,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <link>:
SYSCALL(link)
 380:	b8 13 00 00 00       	mov    $0x13,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <mkdir>:
SYSCALL(mkdir)
 388:	b8 14 00 00 00       	mov    $0x14,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <chdir>:
SYSCALL(chdir)
 390:	b8 09 00 00 00       	mov    $0x9,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <dup>:
SYSCALL(dup)
 398:	b8 0a 00 00 00       	mov    $0xa,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <getpid>:
SYSCALL(getpid)
 3a0:	b8 0b 00 00 00       	mov    $0xb,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <sbrk>:
SYSCALL(sbrk)
 3a8:	b8 0c 00 00 00       	mov    $0xc,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <sleep>:
SYSCALL(sleep)
 3b0:	b8 0d 00 00 00       	mov    $0xd,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <uptime>:
SYSCALL(uptime)
 3b8:	b8 0e 00 00 00       	mov    $0xe,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <printpt>:
SYSCALL(printpt)
 3c0:	b8 16 00 00 00       	mov    $0x16,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3c8:	55                   	push   %ebp
 3c9:	89 e5                	mov    %esp,%ebp
 3cb:	83 ec 18             	sub    $0x18,%esp
 3ce:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3d4:	83 ec 04             	sub    $0x4,%esp
 3d7:	6a 01                	push   $0x1
 3d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3dc:	50                   	push   %eax
 3dd:	ff 75 08             	push   0x8(%ebp)
 3e0:	e8 5b ff ff ff       	call   340 <write>
 3e5:	83 c4 10             	add    $0x10,%esp
}
 3e8:	90                   	nop
 3e9:	c9                   	leave  
 3ea:	c3                   	ret    

000003eb <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3eb:	55                   	push   %ebp
 3ec:	89 e5                	mov    %esp,%ebp
 3ee:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3f1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3f8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3fc:	74 17                	je     415 <printint+0x2a>
 3fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 402:	79 11                	jns    415 <printint+0x2a>
    neg = 1;
 404:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 40b:	8b 45 0c             	mov    0xc(%ebp),%eax
 40e:	f7 d8                	neg    %eax
 410:	89 45 ec             	mov    %eax,-0x14(%ebp)
 413:	eb 06                	jmp    41b <printint+0x30>
  } else {
    x = xx;
 415:	8b 45 0c             	mov    0xc(%ebp),%eax
 418:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 41b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 422:	8b 4d 10             	mov    0x10(%ebp),%ecx
 425:	8b 45 ec             	mov    -0x14(%ebp),%eax
 428:	ba 00 00 00 00       	mov    $0x0,%edx
 42d:	f7 f1                	div    %ecx
 42f:	89 d1                	mov    %edx,%ecx
 431:	8b 45 f4             	mov    -0xc(%ebp),%eax
 434:	8d 50 01             	lea    0x1(%eax),%edx
 437:	89 55 f4             	mov    %edx,-0xc(%ebp)
 43a:	0f b6 91 fc 0a 00 00 	movzbl 0xafc(%ecx),%edx
 441:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 445:	8b 4d 10             	mov    0x10(%ebp),%ecx
 448:	8b 45 ec             	mov    -0x14(%ebp),%eax
 44b:	ba 00 00 00 00       	mov    $0x0,%edx
 450:	f7 f1                	div    %ecx
 452:	89 45 ec             	mov    %eax,-0x14(%ebp)
 455:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 459:	75 c7                	jne    422 <printint+0x37>
  if(neg)
 45b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 45f:	74 2d                	je     48e <printint+0xa3>
    buf[i++] = '-';
 461:	8b 45 f4             	mov    -0xc(%ebp),%eax
 464:	8d 50 01             	lea    0x1(%eax),%edx
 467:	89 55 f4             	mov    %edx,-0xc(%ebp)
 46a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 46f:	eb 1d                	jmp    48e <printint+0xa3>
    putc(fd, buf[i]);
 471:	8d 55 dc             	lea    -0x24(%ebp),%edx
 474:	8b 45 f4             	mov    -0xc(%ebp),%eax
 477:	01 d0                	add    %edx,%eax
 479:	0f b6 00             	movzbl (%eax),%eax
 47c:	0f be c0             	movsbl %al,%eax
 47f:	83 ec 08             	sub    $0x8,%esp
 482:	50                   	push   %eax
 483:	ff 75 08             	push   0x8(%ebp)
 486:	e8 3d ff ff ff       	call   3c8 <putc>
 48b:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 48e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 492:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 496:	79 d9                	jns    471 <printint+0x86>
}
 498:	90                   	nop
 499:	90                   	nop
 49a:	c9                   	leave  
 49b:	c3                   	ret    

0000049c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 49c:	55                   	push   %ebp
 49d:	89 e5                	mov    %esp,%ebp
 49f:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4a2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 4a9:	8d 45 0c             	lea    0xc(%ebp),%eax
 4ac:	83 c0 04             	add    $0x4,%eax
 4af:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4b2:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4b9:	e9 59 01 00 00       	jmp    617 <printf+0x17b>
    c = fmt[i] & 0xff;
 4be:	8b 55 0c             	mov    0xc(%ebp),%edx
 4c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4c4:	01 d0                	add    %edx,%eax
 4c6:	0f b6 00             	movzbl (%eax),%eax
 4c9:	0f be c0             	movsbl %al,%eax
 4cc:	25 ff 00 00 00       	and    $0xff,%eax
 4d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4d4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4d8:	75 2c                	jne    506 <printf+0x6a>
      if(c == '%'){
 4da:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4de:	75 0c                	jne    4ec <printf+0x50>
        state = '%';
 4e0:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4e7:	e9 27 01 00 00       	jmp    613 <printf+0x177>
      } else {
        putc(fd, c);
 4ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4ef:	0f be c0             	movsbl %al,%eax
 4f2:	83 ec 08             	sub    $0x8,%esp
 4f5:	50                   	push   %eax
 4f6:	ff 75 08             	push   0x8(%ebp)
 4f9:	e8 ca fe ff ff       	call   3c8 <putc>
 4fe:	83 c4 10             	add    $0x10,%esp
 501:	e9 0d 01 00 00       	jmp    613 <printf+0x177>
      }
    } else if(state == '%'){
 506:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 50a:	0f 85 03 01 00 00    	jne    613 <printf+0x177>
      if(c == 'd'){
 510:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 514:	75 1e                	jne    534 <printf+0x98>
        printint(fd, *ap, 10, 1);
 516:	8b 45 e8             	mov    -0x18(%ebp),%eax
 519:	8b 00                	mov    (%eax),%eax
 51b:	6a 01                	push   $0x1
 51d:	6a 0a                	push   $0xa
 51f:	50                   	push   %eax
 520:	ff 75 08             	push   0x8(%ebp)
 523:	e8 c3 fe ff ff       	call   3eb <printint>
 528:	83 c4 10             	add    $0x10,%esp
        ap++;
 52b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 52f:	e9 d8 00 00 00       	jmp    60c <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 534:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 538:	74 06                	je     540 <printf+0xa4>
 53a:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 53e:	75 1e                	jne    55e <printf+0xc2>
        printint(fd, *ap, 16, 0);
 540:	8b 45 e8             	mov    -0x18(%ebp),%eax
 543:	8b 00                	mov    (%eax),%eax
 545:	6a 00                	push   $0x0
 547:	6a 10                	push   $0x10
 549:	50                   	push   %eax
 54a:	ff 75 08             	push   0x8(%ebp)
 54d:	e8 99 fe ff ff       	call   3eb <printint>
 552:	83 c4 10             	add    $0x10,%esp
        ap++;
 555:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 559:	e9 ae 00 00 00       	jmp    60c <printf+0x170>
      } else if(c == 's'){
 55e:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 562:	75 43                	jne    5a7 <printf+0x10b>
        s = (char*)*ap;
 564:	8b 45 e8             	mov    -0x18(%ebp),%eax
 567:	8b 00                	mov    (%eax),%eax
 569:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 56c:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 570:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 574:	75 25                	jne    59b <printf+0xff>
          s = "(null)";
 576:	c7 45 f4 91 08 00 00 	movl   $0x891,-0xc(%ebp)
        while(*s != 0){
 57d:	eb 1c                	jmp    59b <printf+0xff>
          putc(fd, *s);
 57f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 582:	0f b6 00             	movzbl (%eax),%eax
 585:	0f be c0             	movsbl %al,%eax
 588:	83 ec 08             	sub    $0x8,%esp
 58b:	50                   	push   %eax
 58c:	ff 75 08             	push   0x8(%ebp)
 58f:	e8 34 fe ff ff       	call   3c8 <putc>
 594:	83 c4 10             	add    $0x10,%esp
          s++;
 597:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 59b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 59e:	0f b6 00             	movzbl (%eax),%eax
 5a1:	84 c0                	test   %al,%al
 5a3:	75 da                	jne    57f <printf+0xe3>
 5a5:	eb 65                	jmp    60c <printf+0x170>
        }
      } else if(c == 'c'){
 5a7:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 5ab:	75 1d                	jne    5ca <printf+0x12e>
        putc(fd, *ap);
 5ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5b0:	8b 00                	mov    (%eax),%eax
 5b2:	0f be c0             	movsbl %al,%eax
 5b5:	83 ec 08             	sub    $0x8,%esp
 5b8:	50                   	push   %eax
 5b9:	ff 75 08             	push   0x8(%ebp)
 5bc:	e8 07 fe ff ff       	call   3c8 <putc>
 5c1:	83 c4 10             	add    $0x10,%esp
        ap++;
 5c4:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5c8:	eb 42                	jmp    60c <printf+0x170>
      } else if(c == '%'){
 5ca:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5ce:	75 17                	jne    5e7 <printf+0x14b>
        putc(fd, c);
 5d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d3:	0f be c0             	movsbl %al,%eax
 5d6:	83 ec 08             	sub    $0x8,%esp
 5d9:	50                   	push   %eax
 5da:	ff 75 08             	push   0x8(%ebp)
 5dd:	e8 e6 fd ff ff       	call   3c8 <putc>
 5e2:	83 c4 10             	add    $0x10,%esp
 5e5:	eb 25                	jmp    60c <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5e7:	83 ec 08             	sub    $0x8,%esp
 5ea:	6a 25                	push   $0x25
 5ec:	ff 75 08             	push   0x8(%ebp)
 5ef:	e8 d4 fd ff ff       	call   3c8 <putc>
 5f4:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5fa:	0f be c0             	movsbl %al,%eax
 5fd:	83 ec 08             	sub    $0x8,%esp
 600:	50                   	push   %eax
 601:	ff 75 08             	push   0x8(%ebp)
 604:	e8 bf fd ff ff       	call   3c8 <putc>
 609:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 60c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 613:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 617:	8b 55 0c             	mov    0xc(%ebp),%edx
 61a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 61d:	01 d0                	add    %edx,%eax
 61f:	0f b6 00             	movzbl (%eax),%eax
 622:	84 c0                	test   %al,%al
 624:	0f 85 94 fe ff ff    	jne    4be <printf+0x22>
    }
  }
}
 62a:	90                   	nop
 62b:	90                   	nop
 62c:	c9                   	leave  
 62d:	c3                   	ret    

0000062e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 62e:	55                   	push   %ebp
 62f:	89 e5                	mov    %esp,%ebp
 631:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 634:	8b 45 08             	mov    0x8(%ebp),%eax
 637:	83 e8 08             	sub    $0x8,%eax
 63a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 63d:	a1 18 0b 00 00       	mov    0xb18,%eax
 642:	89 45 fc             	mov    %eax,-0x4(%ebp)
 645:	eb 24                	jmp    66b <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 647:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64a:	8b 00                	mov    (%eax),%eax
 64c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 64f:	72 12                	jb     663 <free+0x35>
 651:	8b 45 f8             	mov    -0x8(%ebp),%eax
 654:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 657:	77 24                	ja     67d <free+0x4f>
 659:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65c:	8b 00                	mov    (%eax),%eax
 65e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 661:	72 1a                	jb     67d <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 663:	8b 45 fc             	mov    -0x4(%ebp),%eax
 666:	8b 00                	mov    (%eax),%eax
 668:	89 45 fc             	mov    %eax,-0x4(%ebp)
 66b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 66e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 671:	76 d4                	jbe    647 <free+0x19>
 673:	8b 45 fc             	mov    -0x4(%ebp),%eax
 676:	8b 00                	mov    (%eax),%eax
 678:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 67b:	73 ca                	jae    647 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 67d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 680:	8b 40 04             	mov    0x4(%eax),%eax
 683:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 68a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68d:	01 c2                	add    %eax,%edx
 68f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 692:	8b 00                	mov    (%eax),%eax
 694:	39 c2                	cmp    %eax,%edx
 696:	75 24                	jne    6bc <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 698:	8b 45 f8             	mov    -0x8(%ebp),%eax
 69b:	8b 50 04             	mov    0x4(%eax),%edx
 69e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a1:	8b 00                	mov    (%eax),%eax
 6a3:	8b 40 04             	mov    0x4(%eax),%eax
 6a6:	01 c2                	add    %eax,%edx
 6a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ab:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b1:	8b 00                	mov    (%eax),%eax
 6b3:	8b 10                	mov    (%eax),%edx
 6b5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b8:	89 10                	mov    %edx,(%eax)
 6ba:	eb 0a                	jmp    6c6 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 6bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6bf:	8b 10                	mov    (%eax),%edx
 6c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c4:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c9:	8b 40 04             	mov    0x4(%eax),%eax
 6cc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d6:	01 d0                	add    %edx,%eax
 6d8:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6db:	75 20                	jne    6fd <free+0xcf>
    p->s.size += bp->s.size;
 6dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e0:	8b 50 04             	mov    0x4(%eax),%edx
 6e3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6e6:	8b 40 04             	mov    0x4(%eax),%eax
 6e9:	01 c2                	add    %eax,%edx
 6eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ee:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f4:	8b 10                	mov    (%eax),%edx
 6f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f9:	89 10                	mov    %edx,(%eax)
 6fb:	eb 08                	jmp    705 <free+0xd7>
  } else
    p->s.ptr = bp;
 6fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 700:	8b 55 f8             	mov    -0x8(%ebp),%edx
 703:	89 10                	mov    %edx,(%eax)
  freep = p;
 705:	8b 45 fc             	mov    -0x4(%ebp),%eax
 708:	a3 18 0b 00 00       	mov    %eax,0xb18
}
 70d:	90                   	nop
 70e:	c9                   	leave  
 70f:	c3                   	ret    

00000710 <morecore>:

static Header*
morecore(uint nu)
{
 710:	55                   	push   %ebp
 711:	89 e5                	mov    %esp,%ebp
 713:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 716:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 71d:	77 07                	ja     726 <morecore+0x16>
    nu = 4096;
 71f:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 726:	8b 45 08             	mov    0x8(%ebp),%eax
 729:	c1 e0 03             	shl    $0x3,%eax
 72c:	83 ec 0c             	sub    $0xc,%esp
 72f:	50                   	push   %eax
 730:	e8 73 fc ff ff       	call   3a8 <sbrk>
 735:	83 c4 10             	add    $0x10,%esp
 738:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 73b:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 73f:	75 07                	jne    748 <morecore+0x38>
    return 0;
 741:	b8 00 00 00 00       	mov    $0x0,%eax
 746:	eb 26                	jmp    76e <morecore+0x5e>
  hp = (Header*)p;
 748:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 74e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 751:	8b 55 08             	mov    0x8(%ebp),%edx
 754:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 757:	8b 45 f0             	mov    -0x10(%ebp),%eax
 75a:	83 c0 08             	add    $0x8,%eax
 75d:	83 ec 0c             	sub    $0xc,%esp
 760:	50                   	push   %eax
 761:	e8 c8 fe ff ff       	call   62e <free>
 766:	83 c4 10             	add    $0x10,%esp
  return freep;
 769:	a1 18 0b 00 00       	mov    0xb18,%eax
}
 76e:	c9                   	leave  
 76f:	c3                   	ret    

00000770 <malloc>:

void*
malloc(uint nbytes)
{
 770:	55                   	push   %ebp
 771:	89 e5                	mov    %esp,%ebp
 773:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 776:	8b 45 08             	mov    0x8(%ebp),%eax
 779:	83 c0 07             	add    $0x7,%eax
 77c:	c1 e8 03             	shr    $0x3,%eax
 77f:	83 c0 01             	add    $0x1,%eax
 782:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 785:	a1 18 0b 00 00       	mov    0xb18,%eax
 78a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 78d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 791:	75 23                	jne    7b6 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 793:	c7 45 f0 10 0b 00 00 	movl   $0xb10,-0x10(%ebp)
 79a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79d:	a3 18 0b 00 00       	mov    %eax,0xb18
 7a2:	a1 18 0b 00 00       	mov    0xb18,%eax
 7a7:	a3 10 0b 00 00       	mov    %eax,0xb10
    base.s.size = 0;
 7ac:	c7 05 14 0b 00 00 00 	movl   $0x0,0xb14
 7b3:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b9:	8b 00                	mov    (%eax),%eax
 7bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 7be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c1:	8b 40 04             	mov    0x4(%eax),%eax
 7c4:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7c7:	77 4d                	ja     816 <malloc+0xa6>
      if(p->s.size == nunits)
 7c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cc:	8b 40 04             	mov    0x4(%eax),%eax
 7cf:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7d2:	75 0c                	jne    7e0 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d7:	8b 10                	mov    (%eax),%edx
 7d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dc:	89 10                	mov    %edx,(%eax)
 7de:	eb 26                	jmp    806 <malloc+0x96>
      else {
        p->s.size -= nunits;
 7e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e3:	8b 40 04             	mov    0x4(%eax),%eax
 7e6:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7e9:	89 c2                	mov    %eax,%edx
 7eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ee:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f4:	8b 40 04             	mov    0x4(%eax),%eax
 7f7:	c1 e0 03             	shl    $0x3,%eax
 7fa:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 800:	8b 55 ec             	mov    -0x14(%ebp),%edx
 803:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 806:	8b 45 f0             	mov    -0x10(%ebp),%eax
 809:	a3 18 0b 00 00       	mov    %eax,0xb18
      return (void*)(p + 1);
 80e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 811:	83 c0 08             	add    $0x8,%eax
 814:	eb 3b                	jmp    851 <malloc+0xe1>
    }
    if(p == freep)
 816:	a1 18 0b 00 00       	mov    0xb18,%eax
 81b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 81e:	75 1e                	jne    83e <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 820:	83 ec 0c             	sub    $0xc,%esp
 823:	ff 75 ec             	push   -0x14(%ebp)
 826:	e8 e5 fe ff ff       	call   710 <morecore>
 82b:	83 c4 10             	add    $0x10,%esp
 82e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 831:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 835:	75 07                	jne    83e <malloc+0xce>
        return 0;
 837:	b8 00 00 00 00       	mov    $0x0,%eax
 83c:	eb 13                	jmp    851 <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 841:	89 45 f0             	mov    %eax,-0x10(%ebp)
 844:	8b 45 f4             	mov    -0xc(%ebp),%eax
 847:	8b 00                	mov    (%eax),%eax
 849:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 84c:	e9 6d ff ff ff       	jmp    7be <malloc+0x4e>
  }
}
 851:	c9                   	leave  
 852:	c3                   	ret    
