
_trial:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "mmu.h"
//#include "defs.h"

int
main(int argc, char *argv[])
{
   0:	f3 0f 1e fb          	endbr32 
   4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   8:	83 e4 f0             	and    $0xfffffff0,%esp
   b:	ff 71 fc             	pushl  -0x4(%ecx)
   e:	55                   	push   %ebp
   f:	89 e5                	mov    %esp,%ebp
  11:	51                   	push   %ecx
  12:	83 ec 14             	sub    $0x14,%esp
    char *ptr = sbrk(PGSIZE); // Allocate one page
  15:	83 ec 0c             	sub    $0xc,%esp
  18:	68 00 10 00 00       	push   $0x1000
  1d:	e8 5e 03 00 00       	call   380 <sbrk>
  22:	83 c4 10             	add    $0x10,%esp
  25:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    printf(1,"0000000000000000here000000000000 %s\n",ptr);
  28:	83 ec 04             	sub    $0x4,%esp
  2b:	ff 75 f4             	pushl  -0xc(%ebp)
  2e:	68 54 08 00 00       	push   $0x854
  33:	6a 01                	push   $0x1
  35:	e8 52 04 00 00       	call   48c <printf>
  3a:	83 c4 10             	add    $0x10,%esp
   
   mencrypt(ptr, 1); // Encrypt the pages
  3d:	83 ec 08             	sub    $0x8,%esp
  40:	6a 01                	push   $0x1
  42:	ff 75 f4             	pushl  -0xc(%ebp)
  45:	e8 4e 03 00 00       	call   398 <mencrypt>
  4a:	83 c4 10             	add    $0x10,%esp
 
struct pt_entry pt_entry; 
int t = getpgtable(&pt_entry, 10,0); // Get the page table information for newly allocated page
  4d:	83 ec 04             	sub    $0x4,%esp
  50:	6a 00                	push   $0x0
  52:	6a 0a                	push   $0xa
  54:	8d 45 e8             	lea    -0x18(%ebp),%eax
  57:	50                   	push   %eax
  58:	e8 43 03 00 00       	call   3a0 <getpgtable>
  5d:	83 c4 10             	add    $0x10,%esp
  60:	89 45 f0             	mov    %eax,-0x10(%ebp)
printf(1,"%d\n",t);
  63:	83 ec 04             	sub    $0x4,%esp
  66:	ff 75 f0             	pushl  -0x10(%ebp)
  69:	68 79 08 00 00       	push   $0x879
  6e:	6a 01                	push   $0x1
  70:	e8 17 04 00 00       	call   48c <printf>
  75:	83 c4 10             	add    $0x10,%esp
exit();
  78:	e8 7b 02 00 00       	call   2f8 <exit>

0000007d <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  7d:	55                   	push   %ebp
  7e:	89 e5                	mov    %esp,%ebp
  80:	57                   	push   %edi
  81:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  85:	8b 55 10             	mov    0x10(%ebp),%edx
  88:	8b 45 0c             	mov    0xc(%ebp),%eax
  8b:	89 cb                	mov    %ecx,%ebx
  8d:	89 df                	mov    %ebx,%edi
  8f:	89 d1                	mov    %edx,%ecx
  91:	fc                   	cld    
  92:	f3 aa                	rep stos %al,%es:(%edi)
  94:	89 ca                	mov    %ecx,%edx
  96:	89 fb                	mov    %edi,%ebx
  98:	89 5d 08             	mov    %ebx,0x8(%ebp)
  9b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  9e:	90                   	nop
  9f:	5b                   	pop    %ebx
  a0:	5f                   	pop    %edi
  a1:	5d                   	pop    %ebp
  a2:	c3                   	ret    

000000a3 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  a3:	f3 0f 1e fb          	endbr32 
  a7:	55                   	push   %ebp
  a8:	89 e5                	mov    %esp,%ebp
  aa:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  ad:	8b 45 08             	mov    0x8(%ebp),%eax
  b0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  b3:	90                   	nop
  b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  b7:	8d 42 01             	lea    0x1(%edx),%eax
  ba:	89 45 0c             	mov    %eax,0xc(%ebp)
  bd:	8b 45 08             	mov    0x8(%ebp),%eax
  c0:	8d 48 01             	lea    0x1(%eax),%ecx
  c3:	89 4d 08             	mov    %ecx,0x8(%ebp)
  c6:	0f b6 12             	movzbl (%edx),%edx
  c9:	88 10                	mov    %dl,(%eax)
  cb:	0f b6 00             	movzbl (%eax),%eax
  ce:	84 c0                	test   %al,%al
  d0:	75 e2                	jne    b4 <strcpy+0x11>
    ;
  return os;
  d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  d5:	c9                   	leave  
  d6:	c3                   	ret    

000000d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d7:	f3 0f 1e fb          	endbr32 
  db:	55                   	push   %ebp
  dc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  de:	eb 08                	jmp    e8 <strcmp+0x11>
    p++, q++;
  e0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  e4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
  e8:	8b 45 08             	mov    0x8(%ebp),%eax
  eb:	0f b6 00             	movzbl (%eax),%eax
  ee:	84 c0                	test   %al,%al
  f0:	74 10                	je     102 <strcmp+0x2b>
  f2:	8b 45 08             	mov    0x8(%ebp),%eax
  f5:	0f b6 10             	movzbl (%eax),%edx
  f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  fb:	0f b6 00             	movzbl (%eax),%eax
  fe:	38 c2                	cmp    %al,%dl
 100:	74 de                	je     e0 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 102:	8b 45 08             	mov    0x8(%ebp),%eax
 105:	0f b6 00             	movzbl (%eax),%eax
 108:	0f b6 d0             	movzbl %al,%edx
 10b:	8b 45 0c             	mov    0xc(%ebp),%eax
 10e:	0f b6 00             	movzbl (%eax),%eax
 111:	0f b6 c0             	movzbl %al,%eax
 114:	29 c2                	sub    %eax,%edx
 116:	89 d0                	mov    %edx,%eax
}
 118:	5d                   	pop    %ebp
 119:	c3                   	ret    

0000011a <strlen>:

uint
strlen(const char *s)
{
 11a:	f3 0f 1e fb          	endbr32 
 11e:	55                   	push   %ebp
 11f:	89 e5                	mov    %esp,%ebp
 121:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 124:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 12b:	eb 04                	jmp    131 <strlen+0x17>
 12d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 131:	8b 55 fc             	mov    -0x4(%ebp),%edx
 134:	8b 45 08             	mov    0x8(%ebp),%eax
 137:	01 d0                	add    %edx,%eax
 139:	0f b6 00             	movzbl (%eax),%eax
 13c:	84 c0                	test   %al,%al
 13e:	75 ed                	jne    12d <strlen+0x13>
    ;
  return n;
 140:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 143:	c9                   	leave  
 144:	c3                   	ret    

00000145 <memset>:

void*
memset(void *dst, int c, uint n)
{
 145:	f3 0f 1e fb          	endbr32 
 149:	55                   	push   %ebp
 14a:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 14c:	8b 45 10             	mov    0x10(%ebp),%eax
 14f:	50                   	push   %eax
 150:	ff 75 0c             	pushl  0xc(%ebp)
 153:	ff 75 08             	pushl  0x8(%ebp)
 156:	e8 22 ff ff ff       	call   7d <stosb>
 15b:	83 c4 0c             	add    $0xc,%esp
  return dst;
 15e:	8b 45 08             	mov    0x8(%ebp),%eax
}
 161:	c9                   	leave  
 162:	c3                   	ret    

00000163 <strchr>:

char*
strchr(const char *s, char c)
{
 163:	f3 0f 1e fb          	endbr32 
 167:	55                   	push   %ebp
 168:	89 e5                	mov    %esp,%ebp
 16a:	83 ec 04             	sub    $0x4,%esp
 16d:	8b 45 0c             	mov    0xc(%ebp),%eax
 170:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 173:	eb 14                	jmp    189 <strchr+0x26>
    if(*s == c)
 175:	8b 45 08             	mov    0x8(%ebp),%eax
 178:	0f b6 00             	movzbl (%eax),%eax
 17b:	38 45 fc             	cmp    %al,-0x4(%ebp)
 17e:	75 05                	jne    185 <strchr+0x22>
      return (char*)s;
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	eb 13                	jmp    198 <strchr+0x35>
  for(; *s; s++)
 185:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	0f b6 00             	movzbl (%eax),%eax
 18f:	84 c0                	test   %al,%al
 191:	75 e2                	jne    175 <strchr+0x12>
  return 0;
 193:	b8 00 00 00 00       	mov    $0x0,%eax
}
 198:	c9                   	leave  
 199:	c3                   	ret    

0000019a <gets>:

char*
gets(char *buf, int max)
{
 19a:	f3 0f 1e fb          	endbr32 
 19e:	55                   	push   %ebp
 19f:	89 e5                	mov    %esp,%ebp
 1a1:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1ab:	eb 42                	jmp    1ef <gets+0x55>
    cc = read(0, &c, 1);
 1ad:	83 ec 04             	sub    $0x4,%esp
 1b0:	6a 01                	push   $0x1
 1b2:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1b5:	50                   	push   %eax
 1b6:	6a 00                	push   $0x0
 1b8:	e8 53 01 00 00       	call   310 <read>
 1bd:	83 c4 10             	add    $0x10,%esp
 1c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c7:	7e 33                	jle    1fc <gets+0x62>
      break;
    buf[i++] = c;
 1c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1cc:	8d 50 01             	lea    0x1(%eax),%edx
 1cf:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1d2:	89 c2                	mov    %eax,%edx
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
 1d7:	01 c2                	add    %eax,%edx
 1d9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1dd:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1df:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e3:	3c 0a                	cmp    $0xa,%al
 1e5:	74 16                	je     1fd <gets+0x63>
 1e7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1eb:	3c 0d                	cmp    $0xd,%al
 1ed:	74 0e                	je     1fd <gets+0x63>
  for(i=0; i+1 < max; ){
 1ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f2:	83 c0 01             	add    $0x1,%eax
 1f5:	39 45 0c             	cmp    %eax,0xc(%ebp)
 1f8:	7f b3                	jg     1ad <gets+0x13>
 1fa:	eb 01                	jmp    1fd <gets+0x63>
      break;
 1fc:	90                   	nop
      break;
  }
  buf[i] = '\0';
 1fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 200:	8b 45 08             	mov    0x8(%ebp),%eax
 203:	01 d0                	add    %edx,%eax
 205:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 208:	8b 45 08             	mov    0x8(%ebp),%eax
}
 20b:	c9                   	leave  
 20c:	c3                   	ret    

0000020d <stat>:

int
stat(const char *n, struct stat *st)
{
 20d:	f3 0f 1e fb          	endbr32 
 211:	55                   	push   %ebp
 212:	89 e5                	mov    %esp,%ebp
 214:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 217:	83 ec 08             	sub    $0x8,%esp
 21a:	6a 00                	push   $0x0
 21c:	ff 75 08             	pushl  0x8(%ebp)
 21f:	e8 14 01 00 00       	call   338 <open>
 224:	83 c4 10             	add    $0x10,%esp
 227:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 22a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 22e:	79 07                	jns    237 <stat+0x2a>
    return -1;
 230:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 235:	eb 25                	jmp    25c <stat+0x4f>
  r = fstat(fd, st);
 237:	83 ec 08             	sub    $0x8,%esp
 23a:	ff 75 0c             	pushl  0xc(%ebp)
 23d:	ff 75 f4             	pushl  -0xc(%ebp)
 240:	e8 0b 01 00 00       	call   350 <fstat>
 245:	83 c4 10             	add    $0x10,%esp
 248:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 24b:	83 ec 0c             	sub    $0xc,%esp
 24e:	ff 75 f4             	pushl  -0xc(%ebp)
 251:	e8 ca 00 00 00       	call   320 <close>
 256:	83 c4 10             	add    $0x10,%esp
  return r;
 259:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 25c:	c9                   	leave  
 25d:	c3                   	ret    

0000025e <atoi>:

int
atoi(const char *s)
{
 25e:	f3 0f 1e fb          	endbr32 
 262:	55                   	push   %ebp
 263:	89 e5                	mov    %esp,%ebp
 265:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 268:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 26f:	eb 25                	jmp    296 <atoi+0x38>
    n = n*10 + *s++ - '0';
 271:	8b 55 fc             	mov    -0x4(%ebp),%edx
 274:	89 d0                	mov    %edx,%eax
 276:	c1 e0 02             	shl    $0x2,%eax
 279:	01 d0                	add    %edx,%eax
 27b:	01 c0                	add    %eax,%eax
 27d:	89 c1                	mov    %eax,%ecx
 27f:	8b 45 08             	mov    0x8(%ebp),%eax
 282:	8d 50 01             	lea    0x1(%eax),%edx
 285:	89 55 08             	mov    %edx,0x8(%ebp)
 288:	0f b6 00             	movzbl (%eax),%eax
 28b:	0f be c0             	movsbl %al,%eax
 28e:	01 c8                	add    %ecx,%eax
 290:	83 e8 30             	sub    $0x30,%eax
 293:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 296:	8b 45 08             	mov    0x8(%ebp),%eax
 299:	0f b6 00             	movzbl (%eax),%eax
 29c:	3c 2f                	cmp    $0x2f,%al
 29e:	7e 0a                	jle    2aa <atoi+0x4c>
 2a0:	8b 45 08             	mov    0x8(%ebp),%eax
 2a3:	0f b6 00             	movzbl (%eax),%eax
 2a6:	3c 39                	cmp    $0x39,%al
 2a8:	7e c7                	jle    271 <atoi+0x13>
  return n;
 2aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2ad:	c9                   	leave  
 2ae:	c3                   	ret    

000002af <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2af:	f3 0f 1e fb          	endbr32 
 2b3:	55                   	push   %ebp
 2b4:	89 e5                	mov    %esp,%ebp
 2b6:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 2b9:	8b 45 08             	mov    0x8(%ebp),%eax
 2bc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2bf:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c2:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2c5:	eb 17                	jmp    2de <memmove+0x2f>
    *dst++ = *src++;
 2c7:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2ca:	8d 42 01             	lea    0x1(%edx),%eax
 2cd:	89 45 f8             	mov    %eax,-0x8(%ebp)
 2d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2d3:	8d 48 01             	lea    0x1(%eax),%ecx
 2d6:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 2d9:	0f b6 12             	movzbl (%edx),%edx
 2dc:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 2de:	8b 45 10             	mov    0x10(%ebp),%eax
 2e1:	8d 50 ff             	lea    -0x1(%eax),%edx
 2e4:	89 55 10             	mov    %edx,0x10(%ebp)
 2e7:	85 c0                	test   %eax,%eax
 2e9:	7f dc                	jg     2c7 <memmove+0x18>
  return vdst;
 2eb:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ee:	c9                   	leave  
 2ef:	c3                   	ret    

000002f0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2f0:	b8 01 00 00 00       	mov    $0x1,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <exit>:
SYSCALL(exit)
 2f8:	b8 02 00 00 00       	mov    $0x2,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <wait>:
SYSCALL(wait)
 300:	b8 03 00 00 00       	mov    $0x3,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <pipe>:
SYSCALL(pipe)
 308:	b8 04 00 00 00       	mov    $0x4,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <read>:
SYSCALL(read)
 310:	b8 05 00 00 00       	mov    $0x5,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <write>:
SYSCALL(write)
 318:	b8 10 00 00 00       	mov    $0x10,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <close>:
SYSCALL(close)
 320:	b8 15 00 00 00       	mov    $0x15,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <kill>:
SYSCALL(kill)
 328:	b8 06 00 00 00       	mov    $0x6,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <exec>:
SYSCALL(exec)
 330:	b8 07 00 00 00       	mov    $0x7,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <open>:
SYSCALL(open)
 338:	b8 0f 00 00 00       	mov    $0xf,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <mknod>:
SYSCALL(mknod)
 340:	b8 11 00 00 00       	mov    $0x11,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <unlink>:
SYSCALL(unlink)
 348:	b8 12 00 00 00       	mov    $0x12,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <fstat>:
SYSCALL(fstat)
 350:	b8 08 00 00 00       	mov    $0x8,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <link>:
SYSCALL(link)
 358:	b8 13 00 00 00       	mov    $0x13,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <mkdir>:
SYSCALL(mkdir)
 360:	b8 14 00 00 00       	mov    $0x14,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <chdir>:
SYSCALL(chdir)
 368:	b8 09 00 00 00       	mov    $0x9,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <dup>:
SYSCALL(dup)
 370:	b8 0a 00 00 00       	mov    $0xa,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <getpid>:
SYSCALL(getpid)
 378:	b8 0b 00 00 00       	mov    $0xb,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <sbrk>:
SYSCALL(sbrk)
 380:	b8 0c 00 00 00       	mov    $0xc,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <sleep>:
SYSCALL(sleep)
 388:	b8 0d 00 00 00       	mov    $0xd,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <uptime>:
SYSCALL(uptime)
 390:	b8 0e 00 00 00       	mov    $0xe,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <mencrypt>:
SYSCALL(mencrypt)
 398:	b8 16 00 00 00       	mov    $0x16,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <getpgtable>:
SYSCALL(getpgtable)
 3a0:	b8 17 00 00 00       	mov    $0x17,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <dump_rawphymem>:
SYSCALL(dump_rawphymem)
 3a8:	b8 18 00 00 00       	mov    $0x18,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3b0:	f3 0f 1e fb          	endbr32 
 3b4:	55                   	push   %ebp
 3b5:	89 e5                	mov    %esp,%ebp
 3b7:	83 ec 18             	sub    $0x18,%esp
 3ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 3bd:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3c0:	83 ec 04             	sub    $0x4,%esp
 3c3:	6a 01                	push   $0x1
 3c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3c8:	50                   	push   %eax
 3c9:	ff 75 08             	pushl  0x8(%ebp)
 3cc:	e8 47 ff ff ff       	call   318 <write>
 3d1:	83 c4 10             	add    $0x10,%esp
}
 3d4:	90                   	nop
 3d5:	c9                   	leave  
 3d6:	c3                   	ret    

000003d7 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d7:	f3 0f 1e fb          	endbr32 
 3db:	55                   	push   %ebp
 3dc:	89 e5                	mov    %esp,%ebp
 3de:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3e8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3ec:	74 17                	je     405 <printint+0x2e>
 3ee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3f2:	79 11                	jns    405 <printint+0x2e>
    neg = 1;
 3f4:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3fb:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fe:	f7 d8                	neg    %eax
 400:	89 45 ec             	mov    %eax,-0x14(%ebp)
 403:	eb 06                	jmp    40b <printint+0x34>
  } else {
    x = xx;
 405:	8b 45 0c             	mov    0xc(%ebp),%eax
 408:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 40b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 412:	8b 4d 10             	mov    0x10(%ebp),%ecx
 415:	8b 45 ec             	mov    -0x14(%ebp),%eax
 418:	ba 00 00 00 00       	mov    $0x0,%edx
 41d:	f7 f1                	div    %ecx
 41f:	89 d1                	mov    %edx,%ecx
 421:	8b 45 f4             	mov    -0xc(%ebp),%eax
 424:	8d 50 01             	lea    0x1(%eax),%edx
 427:	89 55 f4             	mov    %edx,-0xc(%ebp)
 42a:	0f b6 91 c8 0a 00 00 	movzbl 0xac8(%ecx),%edx
 431:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 435:	8b 4d 10             	mov    0x10(%ebp),%ecx
 438:	8b 45 ec             	mov    -0x14(%ebp),%eax
 43b:	ba 00 00 00 00       	mov    $0x0,%edx
 440:	f7 f1                	div    %ecx
 442:	89 45 ec             	mov    %eax,-0x14(%ebp)
 445:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 449:	75 c7                	jne    412 <printint+0x3b>
  if(neg)
 44b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 44f:	74 2d                	je     47e <printint+0xa7>
    buf[i++] = '-';
 451:	8b 45 f4             	mov    -0xc(%ebp),%eax
 454:	8d 50 01             	lea    0x1(%eax),%edx
 457:	89 55 f4             	mov    %edx,-0xc(%ebp)
 45a:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 45f:	eb 1d                	jmp    47e <printint+0xa7>
    putc(fd, buf[i]);
 461:	8d 55 dc             	lea    -0x24(%ebp),%edx
 464:	8b 45 f4             	mov    -0xc(%ebp),%eax
 467:	01 d0                	add    %edx,%eax
 469:	0f b6 00             	movzbl (%eax),%eax
 46c:	0f be c0             	movsbl %al,%eax
 46f:	83 ec 08             	sub    $0x8,%esp
 472:	50                   	push   %eax
 473:	ff 75 08             	pushl  0x8(%ebp)
 476:	e8 35 ff ff ff       	call   3b0 <putc>
 47b:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 47e:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 482:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 486:	79 d9                	jns    461 <printint+0x8a>
}
 488:	90                   	nop
 489:	90                   	nop
 48a:	c9                   	leave  
 48b:	c3                   	ret    

0000048c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 48c:	f3 0f 1e fb          	endbr32 
 490:	55                   	push   %ebp
 491:	89 e5                	mov    %esp,%ebp
 493:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 496:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 49d:	8d 45 0c             	lea    0xc(%ebp),%eax
 4a0:	83 c0 04             	add    $0x4,%eax
 4a3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 4a6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4ad:	e9 59 01 00 00       	jmp    60b <printf+0x17f>
    c = fmt[i] & 0xff;
 4b2:	8b 55 0c             	mov    0xc(%ebp),%edx
 4b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 4b8:	01 d0                	add    %edx,%eax
 4ba:	0f b6 00             	movzbl (%eax),%eax
 4bd:	0f be c0             	movsbl %al,%eax
 4c0:	25 ff 00 00 00       	and    $0xff,%eax
 4c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4cc:	75 2c                	jne    4fa <printf+0x6e>
      if(c == '%'){
 4ce:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4d2:	75 0c                	jne    4e0 <printf+0x54>
        state = '%';
 4d4:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4db:	e9 27 01 00 00       	jmp    607 <printf+0x17b>
      } else {
        putc(fd, c);
 4e0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4e3:	0f be c0             	movsbl %al,%eax
 4e6:	83 ec 08             	sub    $0x8,%esp
 4e9:	50                   	push   %eax
 4ea:	ff 75 08             	pushl  0x8(%ebp)
 4ed:	e8 be fe ff ff       	call   3b0 <putc>
 4f2:	83 c4 10             	add    $0x10,%esp
 4f5:	e9 0d 01 00 00       	jmp    607 <printf+0x17b>
      }
    } else if(state == '%'){
 4fa:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4fe:	0f 85 03 01 00 00    	jne    607 <printf+0x17b>
      if(c == 'd'){
 504:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 508:	75 1e                	jne    528 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 50a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50d:	8b 00                	mov    (%eax),%eax
 50f:	6a 01                	push   $0x1
 511:	6a 0a                	push   $0xa
 513:	50                   	push   %eax
 514:	ff 75 08             	pushl  0x8(%ebp)
 517:	e8 bb fe ff ff       	call   3d7 <printint>
 51c:	83 c4 10             	add    $0x10,%esp
        ap++;
 51f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 523:	e9 d8 00 00 00       	jmp    600 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 528:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 52c:	74 06                	je     534 <printf+0xa8>
 52e:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 532:	75 1e                	jne    552 <printf+0xc6>
        printint(fd, *ap, 16, 0);
 534:	8b 45 e8             	mov    -0x18(%ebp),%eax
 537:	8b 00                	mov    (%eax),%eax
 539:	6a 00                	push   $0x0
 53b:	6a 10                	push   $0x10
 53d:	50                   	push   %eax
 53e:	ff 75 08             	pushl  0x8(%ebp)
 541:	e8 91 fe ff ff       	call   3d7 <printint>
 546:	83 c4 10             	add    $0x10,%esp
        ap++;
 549:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 54d:	e9 ae 00 00 00       	jmp    600 <printf+0x174>
      } else if(c == 's'){
 552:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 556:	75 43                	jne    59b <printf+0x10f>
        s = (char*)*ap;
 558:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55b:	8b 00                	mov    (%eax),%eax
 55d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 560:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 564:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 568:	75 25                	jne    58f <printf+0x103>
          s = "(null)";
 56a:	c7 45 f4 7d 08 00 00 	movl   $0x87d,-0xc(%ebp)
        while(*s != 0){
 571:	eb 1c                	jmp    58f <printf+0x103>
          putc(fd, *s);
 573:	8b 45 f4             	mov    -0xc(%ebp),%eax
 576:	0f b6 00             	movzbl (%eax),%eax
 579:	0f be c0             	movsbl %al,%eax
 57c:	83 ec 08             	sub    $0x8,%esp
 57f:	50                   	push   %eax
 580:	ff 75 08             	pushl  0x8(%ebp)
 583:	e8 28 fe ff ff       	call   3b0 <putc>
 588:	83 c4 10             	add    $0x10,%esp
          s++;
 58b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 58f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 592:	0f b6 00             	movzbl (%eax),%eax
 595:	84 c0                	test   %al,%al
 597:	75 da                	jne    573 <printf+0xe7>
 599:	eb 65                	jmp    600 <printf+0x174>
        }
      } else if(c == 'c'){
 59b:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 59f:	75 1d                	jne    5be <printf+0x132>
        putc(fd, *ap);
 5a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a4:	8b 00                	mov    (%eax),%eax
 5a6:	0f be c0             	movsbl %al,%eax
 5a9:	83 ec 08             	sub    $0x8,%esp
 5ac:	50                   	push   %eax
 5ad:	ff 75 08             	pushl  0x8(%ebp)
 5b0:	e8 fb fd ff ff       	call   3b0 <putc>
 5b5:	83 c4 10             	add    $0x10,%esp
        ap++;
 5b8:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5bc:	eb 42                	jmp    600 <printf+0x174>
      } else if(c == '%'){
 5be:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5c2:	75 17                	jne    5db <printf+0x14f>
        putc(fd, c);
 5c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c7:	0f be c0             	movsbl %al,%eax
 5ca:	83 ec 08             	sub    $0x8,%esp
 5cd:	50                   	push   %eax
 5ce:	ff 75 08             	pushl  0x8(%ebp)
 5d1:	e8 da fd ff ff       	call   3b0 <putc>
 5d6:	83 c4 10             	add    $0x10,%esp
 5d9:	eb 25                	jmp    600 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5db:	83 ec 08             	sub    $0x8,%esp
 5de:	6a 25                	push   $0x25
 5e0:	ff 75 08             	pushl  0x8(%ebp)
 5e3:	e8 c8 fd ff ff       	call   3b0 <putc>
 5e8:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5ee:	0f be c0             	movsbl %al,%eax
 5f1:	83 ec 08             	sub    $0x8,%esp
 5f4:	50                   	push   %eax
 5f5:	ff 75 08             	pushl  0x8(%ebp)
 5f8:	e8 b3 fd ff ff       	call   3b0 <putc>
 5fd:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 600:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 607:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 60b:	8b 55 0c             	mov    0xc(%ebp),%edx
 60e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 611:	01 d0                	add    %edx,%eax
 613:	0f b6 00             	movzbl (%eax),%eax
 616:	84 c0                	test   %al,%al
 618:	0f 85 94 fe ff ff    	jne    4b2 <printf+0x26>
    }
  }
}
 61e:	90                   	nop
 61f:	90                   	nop
 620:	c9                   	leave  
 621:	c3                   	ret    

00000622 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 622:	f3 0f 1e fb          	endbr32 
 626:	55                   	push   %ebp
 627:	89 e5                	mov    %esp,%ebp
 629:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 62c:	8b 45 08             	mov    0x8(%ebp),%eax
 62f:	83 e8 08             	sub    $0x8,%eax
 632:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 635:	a1 e4 0a 00 00       	mov    0xae4,%eax
 63a:	89 45 fc             	mov    %eax,-0x4(%ebp)
 63d:	eb 24                	jmp    663 <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 63f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 642:	8b 00                	mov    (%eax),%eax
 644:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 647:	72 12                	jb     65b <free+0x39>
 649:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 64f:	77 24                	ja     675 <free+0x53>
 651:	8b 45 fc             	mov    -0x4(%ebp),%eax
 654:	8b 00                	mov    (%eax),%eax
 656:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 659:	72 1a                	jb     675 <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 65b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65e:	8b 00                	mov    (%eax),%eax
 660:	89 45 fc             	mov    %eax,-0x4(%ebp)
 663:	8b 45 f8             	mov    -0x8(%ebp),%eax
 666:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 669:	76 d4                	jbe    63f <free+0x1d>
 66b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66e:	8b 00                	mov    (%eax),%eax
 670:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 673:	73 ca                	jae    63f <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 675:	8b 45 f8             	mov    -0x8(%ebp),%eax
 678:	8b 40 04             	mov    0x4(%eax),%eax
 67b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 682:	8b 45 f8             	mov    -0x8(%ebp),%eax
 685:	01 c2                	add    %eax,%edx
 687:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68a:	8b 00                	mov    (%eax),%eax
 68c:	39 c2                	cmp    %eax,%edx
 68e:	75 24                	jne    6b4 <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 690:	8b 45 f8             	mov    -0x8(%ebp),%eax
 693:	8b 50 04             	mov    0x4(%eax),%edx
 696:	8b 45 fc             	mov    -0x4(%ebp),%eax
 699:	8b 00                	mov    (%eax),%eax
 69b:	8b 40 04             	mov    0x4(%eax),%eax
 69e:	01 c2                	add    %eax,%edx
 6a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a3:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 6a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a9:	8b 00                	mov    (%eax),%eax
 6ab:	8b 10                	mov    (%eax),%edx
 6ad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b0:	89 10                	mov    %edx,(%eax)
 6b2:	eb 0a                	jmp    6be <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 6b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b7:	8b 10                	mov    (%eax),%edx
 6b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bc:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 6be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c1:	8b 40 04             	mov    0x4(%eax),%eax
 6c4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ce:	01 d0                	add    %edx,%eax
 6d0:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6d3:	75 20                	jne    6f5 <free+0xd3>
    p->s.size += bp->s.size;
 6d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d8:	8b 50 04             	mov    0x4(%eax),%edx
 6db:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6de:	8b 40 04             	mov    0x4(%eax),%eax
 6e1:	01 c2                	add    %eax,%edx
 6e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e6:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6e9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ec:	8b 10                	mov    (%eax),%edx
 6ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f1:	89 10                	mov    %edx,(%eax)
 6f3:	eb 08                	jmp    6fd <free+0xdb>
  } else
    p->s.ptr = bp;
 6f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6f8:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6fb:	89 10                	mov    %edx,(%eax)
  freep = p;
 6fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 700:	a3 e4 0a 00 00       	mov    %eax,0xae4
}
 705:	90                   	nop
 706:	c9                   	leave  
 707:	c3                   	ret    

00000708 <morecore>:

static Header*
morecore(uint nu)
{
 708:	f3 0f 1e fb          	endbr32 
 70c:	55                   	push   %ebp
 70d:	89 e5                	mov    %esp,%ebp
 70f:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 712:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 719:	77 07                	ja     722 <morecore+0x1a>
    nu = 4096;
 71b:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 722:	8b 45 08             	mov    0x8(%ebp),%eax
 725:	c1 e0 03             	shl    $0x3,%eax
 728:	83 ec 0c             	sub    $0xc,%esp
 72b:	50                   	push   %eax
 72c:	e8 4f fc ff ff       	call   380 <sbrk>
 731:	83 c4 10             	add    $0x10,%esp
 734:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 737:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 73b:	75 07                	jne    744 <morecore+0x3c>
    return 0;
 73d:	b8 00 00 00 00       	mov    $0x0,%eax
 742:	eb 26                	jmp    76a <morecore+0x62>
  hp = (Header*)p;
 744:	8b 45 f4             	mov    -0xc(%ebp),%eax
 747:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 74a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74d:	8b 55 08             	mov    0x8(%ebp),%edx
 750:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 753:	8b 45 f0             	mov    -0x10(%ebp),%eax
 756:	83 c0 08             	add    $0x8,%eax
 759:	83 ec 0c             	sub    $0xc,%esp
 75c:	50                   	push   %eax
 75d:	e8 c0 fe ff ff       	call   622 <free>
 762:	83 c4 10             	add    $0x10,%esp
  return freep;
 765:	a1 e4 0a 00 00       	mov    0xae4,%eax
}
 76a:	c9                   	leave  
 76b:	c3                   	ret    

0000076c <malloc>:

void*
malloc(uint nbytes)
{
 76c:	f3 0f 1e fb          	endbr32 
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
 785:	a1 e4 0a 00 00       	mov    0xae4,%eax
 78a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 78d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 791:	75 23                	jne    7b6 <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 793:	c7 45 f0 dc 0a 00 00 	movl   $0xadc,-0x10(%ebp)
 79a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 79d:	a3 e4 0a 00 00       	mov    %eax,0xae4
 7a2:	a1 e4 0a 00 00       	mov    0xae4,%eax
 7a7:	a3 dc 0a 00 00       	mov    %eax,0xadc
    base.s.size = 0;
 7ac:	c7 05 e0 0a 00 00 00 	movl   $0x0,0xae0
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
 7c7:	77 4d                	ja     816 <malloc+0xaa>
      if(p->s.size == nunits)
 7c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cc:	8b 40 04             	mov    0x4(%eax),%eax
 7cf:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 7d2:	75 0c                	jne    7e0 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 7d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d7:	8b 10                	mov    (%eax),%edx
 7d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7dc:	89 10                	mov    %edx,(%eax)
 7de:	eb 26                	jmp    806 <malloc+0x9a>
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
 809:	a3 e4 0a 00 00       	mov    %eax,0xae4
      return (void*)(p + 1);
 80e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 811:	83 c0 08             	add    $0x8,%eax
 814:	eb 3b                	jmp    851 <malloc+0xe5>
    }
    if(p == freep)
 816:	a1 e4 0a 00 00       	mov    0xae4,%eax
 81b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 81e:	75 1e                	jne    83e <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 820:	83 ec 0c             	sub    $0xc,%esp
 823:	ff 75 ec             	pushl  -0x14(%ebp)
 826:	e8 dd fe ff ff       	call   708 <morecore>
 82b:	83 c4 10             	add    $0x10,%esp
 82e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 831:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 835:	75 07                	jne    83e <malloc+0xd2>
        return 0;
 837:	b8 00 00 00 00       	mov    $0x0,%eax
 83c:	eb 13                	jmp    851 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 841:	89 45 f0             	mov    %eax,-0x10(%ebp)
 844:	8b 45 f4             	mov    -0xc(%ebp),%eax
 847:	8b 00                	mov    (%eax),%eax
 849:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 84c:	e9 6d ff ff ff       	jmp    7be <malloc+0x52>
  }
}
 851:	c9                   	leave  
 852:	c3                   	ret    
