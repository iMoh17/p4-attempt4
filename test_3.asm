
_test_3:     file format elf32-i386


Disassembly of section .text:

00000000 <err>:
#include "ptentry.h"

#define PGSIZE 4096

static int 
err(char *msg, ...) {
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 ec 08             	sub    $0x8,%esp
    printf(1, "XV6_TEST_OUTPUT %s\n", msg);
   a:	83 ec 04             	sub    $0x4,%esp
   d:	ff 75 08             	pushl  0x8(%ebp)
  10:	68 6c 0a 00 00       	push   $0xa6c
  15:	6a 01                	push   $0x1
  17:	e8 88 06 00 00       	call   6a4 <printf>
  1c:	83 c4 10             	add    $0x10,%esp
    exit();
  1f:	e8 ec 04 00 00       	call   510 <exit>

00000024 <main>:
}

int main(void) {
  24:	f3 0f 1e fb          	endbr32 
  28:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  2c:	83 e4 f0             	and    $0xfffffff0,%esp
  2f:	ff 71 fc             	pushl  -0x4(%ecx)
  32:	55                   	push   %ebp
  33:	89 e5                	mov    %esp,%ebp
  35:	57                   	push   %edi
  36:	56                   	push   %esi
  37:	53                   	push   %ebx
  38:	51                   	push   %ecx
  39:	83 ec 28             	sub    $0x28,%esp
    const uint PAGES_NUM = 1;
  3c:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
    char *buffer = sbrk(PGSIZE * sizeof(char));
  43:	83 ec 0c             	sub    $0xc,%esp
  46:	68 00 10 00 00       	push   $0x1000
  4b:	e8 48 05 00 00       	call   598 <sbrk>
  50:	83 c4 10             	add    $0x10,%esp
  53:	89 45 dc             	mov    %eax,-0x24(%ebp)
    while ((uint)buffer != 0x6000)
  56:	eb 13                	jmp    6b <main+0x47>
        buffer = sbrk(PGSIZE * sizeof(char));
  58:	83 ec 0c             	sub    $0xc,%esp
  5b:	68 00 10 00 00       	push   $0x1000
  60:	e8 33 05 00 00       	call   598 <sbrk>
  65:	83 c4 10             	add    $0x10,%esp
  68:	89 45 dc             	mov    %eax,-0x24(%ebp)
    while ((uint)buffer != 0x6000)
  6b:	81 7d dc 00 60 00 00 	cmpl   $0x6000,-0x24(%ebp)
  72:	75 e4                	jne    58 <main+0x34>
    
    // Allocate one pages of space
    sbrk(PAGES_NUM * PGSIZE);
  74:	8b 45 d8             	mov    -0x28(%ebp),%eax
  77:	c1 e0 0c             	shl    $0xc,%eax
  7a:	83 ec 0c             	sub    $0xc,%esp
  7d:	50                   	push   %eax
  7e:	e8 15 05 00 00       	call   598 <sbrk>
  83:	83 c4 10             	add    $0x10,%esp
    struct pt_entry pt_entries[PAGES_NUM];
  86:	8b 45 d8             	mov    -0x28(%ebp),%eax
  89:	83 e8 01             	sub    $0x1,%eax
  8c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  8f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  92:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  99:	b8 10 00 00 00       	mov    $0x10,%eax
  9e:	83 e8 01             	sub    $0x1,%eax
  a1:	01 d0                	add    %edx,%eax
  a3:	bf 10 00 00 00       	mov    $0x10,%edi
  a8:	ba 00 00 00 00       	mov    $0x0,%edx
  ad:	f7 f7                	div    %edi
  af:	6b c0 10             	imul   $0x10,%eax,%eax
  b2:	89 c2                	mov    %eax,%edx
  b4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  ba:	89 e6                	mov    %esp,%esi
  bc:	29 d6                	sub    %edx,%esi
  be:	89 f2                	mov    %esi,%edx
  c0:	39 d4                	cmp    %edx,%esp
  c2:	74 10                	je     d4 <main+0xb0>
  c4:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  ca:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  d1:	00 
  d2:	eb ec                	jmp    c0 <main+0x9c>
  d4:	89 c2                	mov    %eax,%edx
  d6:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  dc:	29 d4                	sub    %edx,%esp
  de:	89 c2                	mov    %eax,%edx
  e0:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  e6:	85 d2                	test   %edx,%edx
  e8:	74 0d                	je     f7 <main+0xd3>
  ea:	25 ff 0f 00 00       	and    $0xfff,%eax
  ef:	83 e8 04             	sub    $0x4,%eax
  f2:	01 e0                	add    %esp,%eax
  f4:	83 08 00             	orl    $0x0,(%eax)
  f7:	89 e0                	mov    %esp,%eax
  f9:	83 c0 03             	add    $0x3,%eax
  fc:	c1 e8 02             	shr    $0x2,%eax
  ff:	c1 e0 02             	shl    $0x2,%eax
 102:	89 45 d0             	mov    %eax,-0x30(%ebp)

    int retval = getpgtable(pt_entries, PAGES_NUM, 0);
 105:	8b 45 d8             	mov    -0x28(%ebp),%eax
 108:	83 ec 04             	sub    $0x4,%esp
 10b:	6a 00                	push   $0x0
 10d:	50                   	push   %eax
 10e:	ff 75 d0             	pushl  -0x30(%ebp)
 111:	e8 a2 04 00 00       	call   5b8 <getpgtable>
 116:	83 c4 10             	add    $0x10,%esp
 119:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if (retval == PAGES_NUM) {
 11c:	8b 45 d8             	mov    -0x28(%ebp),%eax
 11f:	39 45 cc             	cmp    %eax,-0x34(%ebp)
 122:	0f 85 53 01 00 00    	jne    27b <main+0x257>
        for (int i = 0; i < retval; i++) {
 128:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
 12f:	e9 39 01 00 00       	jmp    26d <main+0x249>
                i,
                pt_entries[i].pdx,
                pt_entries[i].ptx,
                pt_entries[i].writable,
                pt_entries[i].encrypted,
                pt_entries[i].ref
 134:	8b 45 d0             	mov    -0x30(%ebp),%eax
 137:	8b 55 e0             	mov    -0x20(%ebp),%edx
 13a:	0f b6 44 d0 07       	movzbl 0x7(%eax,%edx,8),%eax
 13f:	83 e0 01             	and    $0x1,%eax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 142:	0f b6 f0             	movzbl %al,%esi
                pt_entries[i].encrypted,
 145:	8b 45 d0             	mov    -0x30(%ebp),%eax
 148:	8b 55 e0             	mov    -0x20(%ebp),%edx
 14b:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 150:	c0 e8 07             	shr    $0x7,%al
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 153:	0f b6 d8             	movzbl %al,%ebx
                pt_entries[i].writable,
 156:	8b 45 d0             	mov    -0x30(%ebp),%eax
 159:	8b 55 e0             	mov    -0x20(%ebp),%edx
 15c:	0f b6 44 d0 06       	movzbl 0x6(%eax,%edx,8),%eax
 161:	c0 e8 05             	shr    $0x5,%al
 164:	83 e0 01             	and    $0x1,%eax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 167:	0f b6 c8             	movzbl %al,%ecx
                pt_entries[i].ptx,
 16a:	8b 45 d0             	mov    -0x30(%ebp),%eax
 16d:	8b 55 e0             	mov    -0x20(%ebp),%edx
 170:	8b 04 d0             	mov    (%eax,%edx,8),%eax
 173:	c1 e8 0a             	shr    $0xa,%eax
 176:	66 25 ff 03          	and    $0x3ff,%ax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 17a:	0f b7 d0             	movzwl %ax,%edx
                pt_entries[i].pdx,
 17d:	8b 45 d0             	mov    -0x30(%ebp),%eax
 180:	8b 7d e0             	mov    -0x20(%ebp),%edi
 183:	0f b7 04 f8          	movzwl (%eax,%edi,8),%eax
 187:	66 25 ff 03          	and    $0x3ff,%ax
            printf(1, "XV6_TEST_OUTPUT Index %d: pdx: 0x%x, ptx: 0x%x, writable bit: %d, encrypted: %d, ref: %d\n", 
 18b:	0f b7 c0             	movzwl %ax,%eax
 18e:	56                   	push   %esi
 18f:	53                   	push   %ebx
 190:	51                   	push   %ecx
 191:	52                   	push   %edx
 192:	50                   	push   %eax
 193:	ff 75 e0             	pushl  -0x20(%ebp)
 196:	68 80 0a 00 00       	push   $0xa80
 19b:	6a 01                	push   $0x1
 19d:	e8 02 05 00 00       	call   6a4 <printf>
 1a2:	83 c4 20             	add    $0x20,%esp
            );

            if (dump_rawphymem(pt_entries[i].ppage * PGSIZE, buffer) != 0)
 1a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
 1a8:	8b 55 e0             	mov    -0x20(%ebp),%edx
 1ab:	8b 44 d0 04          	mov    0x4(%eax,%edx,8),%eax
 1af:	25 ff ff 0f 00       	and    $0xfffff,%eax
 1b4:	c1 e0 0c             	shl    $0xc,%eax
 1b7:	83 ec 08             	sub    $0x8,%esp
 1ba:	ff 75 dc             	pushl  -0x24(%ebp)
 1bd:	50                   	push   %eax
 1be:	e8 fd 03 00 00       	call   5c0 <dump_rawphymem>
 1c3:	83 c4 10             	add    $0x10,%esp
 1c6:	85 c0                	test   %eax,%eax
 1c8:	74 10                	je     1da <main+0x1b6>
                err("dump_rawphymem return non-zero value\n");
 1ca:	83 ec 0c             	sub    $0xc,%esp
 1cd:	68 dc 0a 00 00       	push   $0xadc
 1d2:	e8 29 fe ff ff       	call   0 <err>
 1d7:	83 c4 10             	add    $0x10,%esp
            
            for (int j = 0; j < PGSIZE; j++) {
 1da:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
 1e1:	eb 79                	jmp    25c <main+0x238>
                if (buffer[j] != (char)0xFF) {
 1e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 1e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
 1e9:	01 d0                	add    %edx,%eax
 1eb:	0f b6 00             	movzbl (%eax),%eax
 1ee:	3c ff                	cmp    $0xff,%al
 1f0:	74 66                	je     258 <main+0x234>
                    printf(1, "XV6_TEST_OUTPUT: content is incorrect at address 0x%x: expected 0x%x, got 0x%x\n", ((uint)(pt_entries[i].pdx) << 22 | (pt_entries[i].ptx) << 12) + j , 0xFF, buffer[j] & 0xFF);
 1f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 1f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
 1f8:	01 d0                	add    %edx,%eax
 1fa:	0f b6 00             	movzbl (%eax),%eax
 1fd:	0f be c0             	movsbl %al,%eax
 200:	0f b6 c0             	movzbl %al,%eax
 203:	8b 55 d0             	mov    -0x30(%ebp),%edx
 206:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 209:	0f b7 14 ca          	movzwl (%edx,%ecx,8),%edx
 20d:	66 81 e2 ff 03       	and    $0x3ff,%dx
 212:	0f b7 d2             	movzwl %dx,%edx
 215:	89 d3                	mov    %edx,%ebx
 217:	c1 e3 16             	shl    $0x16,%ebx
 21a:	8b 55 d0             	mov    -0x30(%ebp),%edx
 21d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 220:	8b 14 ca             	mov    (%edx,%ecx,8),%edx
 223:	c1 ea 0a             	shr    $0xa,%edx
 226:	66 81 e2 ff 03       	and    $0x3ff,%dx
 22b:	0f b7 d2             	movzwl %dx,%edx
 22e:	c1 e2 0c             	shl    $0xc,%edx
 231:	09 d3                	or     %edx,%ebx
 233:	89 d9                	mov    %ebx,%ecx
 235:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 238:	01 ca                	add    %ecx,%edx
 23a:	83 ec 0c             	sub    $0xc,%esp
 23d:	50                   	push   %eax
 23e:	68 ff 00 00 00       	push   $0xff
 243:	52                   	push   %edx
 244:	68 04 0b 00 00       	push   $0xb04
 249:	6a 01                	push   $0x1
 24b:	e8 54 04 00 00       	call   6a4 <printf>
 250:	83 c4 20             	add    $0x20,%esp
                    exit();
 253:	e8 b8 02 00 00       	call   510 <exit>
            for (int j = 0; j < PGSIZE; j++) {
 258:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
 25c:	81 7d e4 ff 0f 00 00 	cmpl   $0xfff,-0x1c(%ebp)
 263:	0f 8e 7a ff ff ff    	jle    1e3 <main+0x1bf>
        for (int i = 0; i < retval; i++) {
 269:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
 26d:	8b 45 e0             	mov    -0x20(%ebp),%eax
 270:	3b 45 cc             	cmp    -0x34(%ebp),%eax
 273:	0f 8c bb fe ff ff    	jl     134 <main+0x110>
 279:	eb 15                	jmp    290 <main+0x26c>
                }
                    
            }
        }
    } else
        printf(1, "XV6_TEST_OUTPUT: getpgtable returned incorrect value: expected %d, got %d\n", PAGES_NUM, retval);
 27b:	ff 75 cc             	pushl  -0x34(%ebp)
 27e:	ff 75 d8             	pushl  -0x28(%ebp)
 281:	68 54 0b 00 00       	push   $0xb54
 286:	6a 01                	push   $0x1
 288:	e8 17 04 00 00       	call   6a4 <printf>
 28d:	83 c4 10             	add    $0x10,%esp
    
    exit();
 290:	e8 7b 02 00 00       	call   510 <exit>

00000295 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 295:	55                   	push   %ebp
 296:	89 e5                	mov    %esp,%ebp
 298:	57                   	push   %edi
 299:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 29a:	8b 4d 08             	mov    0x8(%ebp),%ecx
 29d:	8b 55 10             	mov    0x10(%ebp),%edx
 2a0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a3:	89 cb                	mov    %ecx,%ebx
 2a5:	89 df                	mov    %ebx,%edi
 2a7:	89 d1                	mov    %edx,%ecx
 2a9:	fc                   	cld    
 2aa:	f3 aa                	rep stos %al,%es:(%edi)
 2ac:	89 ca                	mov    %ecx,%edx
 2ae:	89 fb                	mov    %edi,%ebx
 2b0:	89 5d 08             	mov    %ebx,0x8(%ebp)
 2b3:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 2b6:	90                   	nop
 2b7:	5b                   	pop    %ebx
 2b8:	5f                   	pop    %edi
 2b9:	5d                   	pop    %ebp
 2ba:	c3                   	ret    

000002bb <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 2bb:	f3 0f 1e fb          	endbr32 
 2bf:	55                   	push   %ebp
 2c0:	89 e5                	mov    %esp,%ebp
 2c2:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 2c5:	8b 45 08             	mov    0x8(%ebp),%eax
 2c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 2cb:	90                   	nop
 2cc:	8b 55 0c             	mov    0xc(%ebp),%edx
 2cf:	8d 42 01             	lea    0x1(%edx),%eax
 2d2:	89 45 0c             	mov    %eax,0xc(%ebp)
 2d5:	8b 45 08             	mov    0x8(%ebp),%eax
 2d8:	8d 48 01             	lea    0x1(%eax),%ecx
 2db:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2de:	0f b6 12             	movzbl (%edx),%edx
 2e1:	88 10                	mov    %dl,(%eax)
 2e3:	0f b6 00             	movzbl (%eax),%eax
 2e6:	84 c0                	test   %al,%al
 2e8:	75 e2                	jne    2cc <strcpy+0x11>
    ;
  return os;
 2ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2ed:	c9                   	leave  
 2ee:	c3                   	ret    

000002ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2ef:	f3 0f 1e fb          	endbr32 
 2f3:	55                   	push   %ebp
 2f4:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2f6:	eb 08                	jmp    300 <strcmp+0x11>
    p++, q++;
 2f8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2fc:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 300:	8b 45 08             	mov    0x8(%ebp),%eax
 303:	0f b6 00             	movzbl (%eax),%eax
 306:	84 c0                	test   %al,%al
 308:	74 10                	je     31a <strcmp+0x2b>
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	0f b6 10             	movzbl (%eax),%edx
 310:	8b 45 0c             	mov    0xc(%ebp),%eax
 313:	0f b6 00             	movzbl (%eax),%eax
 316:	38 c2                	cmp    %al,%dl
 318:	74 de                	je     2f8 <strcmp+0x9>
  return (uchar)*p - (uchar)*q;
 31a:	8b 45 08             	mov    0x8(%ebp),%eax
 31d:	0f b6 00             	movzbl (%eax),%eax
 320:	0f b6 d0             	movzbl %al,%edx
 323:	8b 45 0c             	mov    0xc(%ebp),%eax
 326:	0f b6 00             	movzbl (%eax),%eax
 329:	0f b6 c0             	movzbl %al,%eax
 32c:	29 c2                	sub    %eax,%edx
 32e:	89 d0                	mov    %edx,%eax
}
 330:	5d                   	pop    %ebp
 331:	c3                   	ret    

00000332 <strlen>:

uint
strlen(const char *s)
{
 332:	f3 0f 1e fb          	endbr32 
 336:	55                   	push   %ebp
 337:	89 e5                	mov    %esp,%ebp
 339:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 33c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 343:	eb 04                	jmp    349 <strlen+0x17>
 345:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 349:	8b 55 fc             	mov    -0x4(%ebp),%edx
 34c:	8b 45 08             	mov    0x8(%ebp),%eax
 34f:	01 d0                	add    %edx,%eax
 351:	0f b6 00             	movzbl (%eax),%eax
 354:	84 c0                	test   %al,%al
 356:	75 ed                	jne    345 <strlen+0x13>
    ;
  return n;
 358:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 35b:	c9                   	leave  
 35c:	c3                   	ret    

0000035d <memset>:

void*
memset(void *dst, int c, uint n)
{
 35d:	f3 0f 1e fb          	endbr32 
 361:	55                   	push   %ebp
 362:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 364:	8b 45 10             	mov    0x10(%ebp),%eax
 367:	50                   	push   %eax
 368:	ff 75 0c             	pushl  0xc(%ebp)
 36b:	ff 75 08             	pushl  0x8(%ebp)
 36e:	e8 22 ff ff ff       	call   295 <stosb>
 373:	83 c4 0c             	add    $0xc,%esp
  return dst;
 376:	8b 45 08             	mov    0x8(%ebp),%eax
}
 379:	c9                   	leave  
 37a:	c3                   	ret    

0000037b <strchr>:

char*
strchr(const char *s, char c)
{
 37b:	f3 0f 1e fb          	endbr32 
 37f:	55                   	push   %ebp
 380:	89 e5                	mov    %esp,%ebp
 382:	83 ec 04             	sub    $0x4,%esp
 385:	8b 45 0c             	mov    0xc(%ebp),%eax
 388:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 38b:	eb 14                	jmp    3a1 <strchr+0x26>
    if(*s == c)
 38d:	8b 45 08             	mov    0x8(%ebp),%eax
 390:	0f b6 00             	movzbl (%eax),%eax
 393:	38 45 fc             	cmp    %al,-0x4(%ebp)
 396:	75 05                	jne    39d <strchr+0x22>
      return (char*)s;
 398:	8b 45 08             	mov    0x8(%ebp),%eax
 39b:	eb 13                	jmp    3b0 <strchr+0x35>
  for(; *s; s++)
 39d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 3a1:	8b 45 08             	mov    0x8(%ebp),%eax
 3a4:	0f b6 00             	movzbl (%eax),%eax
 3a7:	84 c0                	test   %al,%al
 3a9:	75 e2                	jne    38d <strchr+0x12>
  return 0;
 3ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3b0:	c9                   	leave  
 3b1:	c3                   	ret    

000003b2 <gets>:

char*
gets(char *buf, int max)
{
 3b2:	f3 0f 1e fb          	endbr32 
 3b6:	55                   	push   %ebp
 3b7:	89 e5                	mov    %esp,%ebp
 3b9:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 3c3:	eb 42                	jmp    407 <gets+0x55>
    cc = read(0, &c, 1);
 3c5:	83 ec 04             	sub    $0x4,%esp
 3c8:	6a 01                	push   $0x1
 3ca:	8d 45 ef             	lea    -0x11(%ebp),%eax
 3cd:	50                   	push   %eax
 3ce:	6a 00                	push   $0x0
 3d0:	e8 53 01 00 00       	call   528 <read>
 3d5:	83 c4 10             	add    $0x10,%esp
 3d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 3db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3df:	7e 33                	jle    414 <gets+0x62>
      break;
    buf[i++] = c;
 3e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3e4:	8d 50 01             	lea    0x1(%eax),%edx
 3e7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3ea:	89 c2                	mov    %eax,%edx
 3ec:	8b 45 08             	mov    0x8(%ebp),%eax
 3ef:	01 c2                	add    %eax,%edx
 3f1:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3f5:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3f7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3fb:	3c 0a                	cmp    $0xa,%al
 3fd:	74 16                	je     415 <gets+0x63>
 3ff:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 403:	3c 0d                	cmp    $0xd,%al
 405:	74 0e                	je     415 <gets+0x63>
  for(i=0; i+1 < max; ){
 407:	8b 45 f4             	mov    -0xc(%ebp),%eax
 40a:	83 c0 01             	add    $0x1,%eax
 40d:	39 45 0c             	cmp    %eax,0xc(%ebp)
 410:	7f b3                	jg     3c5 <gets+0x13>
 412:	eb 01                	jmp    415 <gets+0x63>
      break;
 414:	90                   	nop
      break;
  }
  buf[i] = '\0';
 415:	8b 55 f4             	mov    -0xc(%ebp),%edx
 418:	8b 45 08             	mov    0x8(%ebp),%eax
 41b:	01 d0                	add    %edx,%eax
 41d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 420:	8b 45 08             	mov    0x8(%ebp),%eax
}
 423:	c9                   	leave  
 424:	c3                   	ret    

00000425 <stat>:

int
stat(const char *n, struct stat *st)
{
 425:	f3 0f 1e fb          	endbr32 
 429:	55                   	push   %ebp
 42a:	89 e5                	mov    %esp,%ebp
 42c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 42f:	83 ec 08             	sub    $0x8,%esp
 432:	6a 00                	push   $0x0
 434:	ff 75 08             	pushl  0x8(%ebp)
 437:	e8 14 01 00 00       	call   550 <open>
 43c:	83 c4 10             	add    $0x10,%esp
 43f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 442:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 446:	79 07                	jns    44f <stat+0x2a>
    return -1;
 448:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 44d:	eb 25                	jmp    474 <stat+0x4f>
  r = fstat(fd, st);
 44f:	83 ec 08             	sub    $0x8,%esp
 452:	ff 75 0c             	pushl  0xc(%ebp)
 455:	ff 75 f4             	pushl  -0xc(%ebp)
 458:	e8 0b 01 00 00       	call   568 <fstat>
 45d:	83 c4 10             	add    $0x10,%esp
 460:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 463:	83 ec 0c             	sub    $0xc,%esp
 466:	ff 75 f4             	pushl  -0xc(%ebp)
 469:	e8 ca 00 00 00       	call   538 <close>
 46e:	83 c4 10             	add    $0x10,%esp
  return r;
 471:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 474:	c9                   	leave  
 475:	c3                   	ret    

00000476 <atoi>:

int
atoi(const char *s)
{
 476:	f3 0f 1e fb          	endbr32 
 47a:	55                   	push   %ebp
 47b:	89 e5                	mov    %esp,%ebp
 47d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 480:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 487:	eb 25                	jmp    4ae <atoi+0x38>
    n = n*10 + *s++ - '0';
 489:	8b 55 fc             	mov    -0x4(%ebp),%edx
 48c:	89 d0                	mov    %edx,%eax
 48e:	c1 e0 02             	shl    $0x2,%eax
 491:	01 d0                	add    %edx,%eax
 493:	01 c0                	add    %eax,%eax
 495:	89 c1                	mov    %eax,%ecx
 497:	8b 45 08             	mov    0x8(%ebp),%eax
 49a:	8d 50 01             	lea    0x1(%eax),%edx
 49d:	89 55 08             	mov    %edx,0x8(%ebp)
 4a0:	0f b6 00             	movzbl (%eax),%eax
 4a3:	0f be c0             	movsbl %al,%eax
 4a6:	01 c8                	add    %ecx,%eax
 4a8:	83 e8 30             	sub    $0x30,%eax
 4ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 4ae:	8b 45 08             	mov    0x8(%ebp),%eax
 4b1:	0f b6 00             	movzbl (%eax),%eax
 4b4:	3c 2f                	cmp    $0x2f,%al
 4b6:	7e 0a                	jle    4c2 <atoi+0x4c>
 4b8:	8b 45 08             	mov    0x8(%ebp),%eax
 4bb:	0f b6 00             	movzbl (%eax),%eax
 4be:	3c 39                	cmp    $0x39,%al
 4c0:	7e c7                	jle    489 <atoi+0x13>
  return n;
 4c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4c5:	c9                   	leave  
 4c6:	c3                   	ret    

000004c7 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4c7:	f3 0f 1e fb          	endbr32 
 4cb:	55                   	push   %ebp
 4cc:	89 e5                	mov    %esp,%ebp
 4ce:	83 ec 10             	sub    $0x10,%esp
  char *dst;
  const char *src;

  dst = vdst;
 4d1:	8b 45 08             	mov    0x8(%ebp),%eax
 4d4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 4d7:	8b 45 0c             	mov    0xc(%ebp),%eax
 4da:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 4dd:	eb 17                	jmp    4f6 <memmove+0x2f>
    *dst++ = *src++;
 4df:	8b 55 f8             	mov    -0x8(%ebp),%edx
 4e2:	8d 42 01             	lea    0x1(%edx),%eax
 4e5:	89 45 f8             	mov    %eax,-0x8(%ebp)
 4e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 4eb:	8d 48 01             	lea    0x1(%eax),%ecx
 4ee:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 4f1:	0f b6 12             	movzbl (%edx),%edx
 4f4:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4f6:	8b 45 10             	mov    0x10(%ebp),%eax
 4f9:	8d 50 ff             	lea    -0x1(%eax),%edx
 4fc:	89 55 10             	mov    %edx,0x10(%ebp)
 4ff:	85 c0                	test   %eax,%eax
 501:	7f dc                	jg     4df <memmove+0x18>
  return vdst;
 503:	8b 45 08             	mov    0x8(%ebp),%eax
}
 506:	c9                   	leave  
 507:	c3                   	ret    

00000508 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 508:	b8 01 00 00 00       	mov    $0x1,%eax
 50d:	cd 40                	int    $0x40
 50f:	c3                   	ret    

00000510 <exit>:
SYSCALL(exit)
 510:	b8 02 00 00 00       	mov    $0x2,%eax
 515:	cd 40                	int    $0x40
 517:	c3                   	ret    

00000518 <wait>:
SYSCALL(wait)
 518:	b8 03 00 00 00       	mov    $0x3,%eax
 51d:	cd 40                	int    $0x40
 51f:	c3                   	ret    

00000520 <pipe>:
SYSCALL(pipe)
 520:	b8 04 00 00 00       	mov    $0x4,%eax
 525:	cd 40                	int    $0x40
 527:	c3                   	ret    

00000528 <read>:
SYSCALL(read)
 528:	b8 05 00 00 00       	mov    $0x5,%eax
 52d:	cd 40                	int    $0x40
 52f:	c3                   	ret    

00000530 <write>:
SYSCALL(write)
 530:	b8 10 00 00 00       	mov    $0x10,%eax
 535:	cd 40                	int    $0x40
 537:	c3                   	ret    

00000538 <close>:
SYSCALL(close)
 538:	b8 15 00 00 00       	mov    $0x15,%eax
 53d:	cd 40                	int    $0x40
 53f:	c3                   	ret    

00000540 <kill>:
SYSCALL(kill)
 540:	b8 06 00 00 00       	mov    $0x6,%eax
 545:	cd 40                	int    $0x40
 547:	c3                   	ret    

00000548 <exec>:
SYSCALL(exec)
 548:	b8 07 00 00 00       	mov    $0x7,%eax
 54d:	cd 40                	int    $0x40
 54f:	c3                   	ret    

00000550 <open>:
SYSCALL(open)
 550:	b8 0f 00 00 00       	mov    $0xf,%eax
 555:	cd 40                	int    $0x40
 557:	c3                   	ret    

00000558 <mknod>:
SYSCALL(mknod)
 558:	b8 11 00 00 00       	mov    $0x11,%eax
 55d:	cd 40                	int    $0x40
 55f:	c3                   	ret    

00000560 <unlink>:
SYSCALL(unlink)
 560:	b8 12 00 00 00       	mov    $0x12,%eax
 565:	cd 40                	int    $0x40
 567:	c3                   	ret    

00000568 <fstat>:
SYSCALL(fstat)
 568:	b8 08 00 00 00       	mov    $0x8,%eax
 56d:	cd 40                	int    $0x40
 56f:	c3                   	ret    

00000570 <link>:
SYSCALL(link)
 570:	b8 13 00 00 00       	mov    $0x13,%eax
 575:	cd 40                	int    $0x40
 577:	c3                   	ret    

00000578 <mkdir>:
SYSCALL(mkdir)
 578:	b8 14 00 00 00       	mov    $0x14,%eax
 57d:	cd 40                	int    $0x40
 57f:	c3                   	ret    

00000580 <chdir>:
SYSCALL(chdir)
 580:	b8 09 00 00 00       	mov    $0x9,%eax
 585:	cd 40                	int    $0x40
 587:	c3                   	ret    

00000588 <dup>:
SYSCALL(dup)
 588:	b8 0a 00 00 00       	mov    $0xa,%eax
 58d:	cd 40                	int    $0x40
 58f:	c3                   	ret    

00000590 <getpid>:
SYSCALL(getpid)
 590:	b8 0b 00 00 00       	mov    $0xb,%eax
 595:	cd 40                	int    $0x40
 597:	c3                   	ret    

00000598 <sbrk>:
SYSCALL(sbrk)
 598:	b8 0c 00 00 00       	mov    $0xc,%eax
 59d:	cd 40                	int    $0x40
 59f:	c3                   	ret    

000005a0 <sleep>:
SYSCALL(sleep)
 5a0:	b8 0d 00 00 00       	mov    $0xd,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <uptime>:
SYSCALL(uptime)
 5a8:	b8 0e 00 00 00       	mov    $0xe,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <mencrypt>:
SYSCALL(mencrypt)
 5b0:	b8 16 00 00 00       	mov    $0x16,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <getpgtable>:
SYSCALL(getpgtable)
 5b8:	b8 17 00 00 00       	mov    $0x17,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <dump_rawphymem>:
SYSCALL(dump_rawphymem)
 5c0:	b8 18 00 00 00       	mov    $0x18,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 5c8:	f3 0f 1e fb          	endbr32 
 5cc:	55                   	push   %ebp
 5cd:	89 e5                	mov    %esp,%ebp
 5cf:	83 ec 18             	sub    $0x18,%esp
 5d2:	8b 45 0c             	mov    0xc(%ebp),%eax
 5d5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 5d8:	83 ec 04             	sub    $0x4,%esp
 5db:	6a 01                	push   $0x1
 5dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
 5e0:	50                   	push   %eax
 5e1:	ff 75 08             	pushl  0x8(%ebp)
 5e4:	e8 47 ff ff ff       	call   530 <write>
 5e9:	83 c4 10             	add    $0x10,%esp
}
 5ec:	90                   	nop
 5ed:	c9                   	leave  
 5ee:	c3                   	ret    

000005ef <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5ef:	f3 0f 1e fb          	endbr32 
 5f3:	55                   	push   %ebp
 5f4:	89 e5                	mov    %esp,%ebp
 5f6:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 5f9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 600:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 604:	74 17                	je     61d <printint+0x2e>
 606:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 60a:	79 11                	jns    61d <printint+0x2e>
    neg = 1;
 60c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 613:	8b 45 0c             	mov    0xc(%ebp),%eax
 616:	f7 d8                	neg    %eax
 618:	89 45 ec             	mov    %eax,-0x14(%ebp)
 61b:	eb 06                	jmp    623 <printint+0x34>
  } else {
    x = xx;
 61d:	8b 45 0c             	mov    0xc(%ebp),%eax
 620:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 623:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 62a:	8b 4d 10             	mov    0x10(%ebp),%ecx
 62d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 630:	ba 00 00 00 00       	mov    $0x0,%edx
 635:	f7 f1                	div    %ecx
 637:	89 d1                	mov    %edx,%ecx
 639:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63c:	8d 50 01             	lea    0x1(%eax),%edx
 63f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 642:	0f b6 91 14 0e 00 00 	movzbl 0xe14(%ecx),%edx
 649:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 64d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 650:	8b 45 ec             	mov    -0x14(%ebp),%eax
 653:	ba 00 00 00 00       	mov    $0x0,%edx
 658:	f7 f1                	div    %ecx
 65a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 65d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 661:	75 c7                	jne    62a <printint+0x3b>
  if(neg)
 663:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 667:	74 2d                	je     696 <printint+0xa7>
    buf[i++] = '-';
 669:	8b 45 f4             	mov    -0xc(%ebp),%eax
 66c:	8d 50 01             	lea    0x1(%eax),%edx
 66f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 672:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 677:	eb 1d                	jmp    696 <printint+0xa7>
    putc(fd, buf[i]);
 679:	8d 55 dc             	lea    -0x24(%ebp),%edx
 67c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 67f:	01 d0                	add    %edx,%eax
 681:	0f b6 00             	movzbl (%eax),%eax
 684:	0f be c0             	movsbl %al,%eax
 687:	83 ec 08             	sub    $0x8,%esp
 68a:	50                   	push   %eax
 68b:	ff 75 08             	pushl  0x8(%ebp)
 68e:	e8 35 ff ff ff       	call   5c8 <putc>
 693:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 696:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 69a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 69e:	79 d9                	jns    679 <printint+0x8a>
}
 6a0:	90                   	nop
 6a1:	90                   	nop
 6a2:	c9                   	leave  
 6a3:	c3                   	ret    

000006a4 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 6a4:	f3 0f 1e fb          	endbr32 
 6a8:	55                   	push   %ebp
 6a9:	89 e5                	mov    %esp,%ebp
 6ab:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 6ae:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 6b5:	8d 45 0c             	lea    0xc(%ebp),%eax
 6b8:	83 c0 04             	add    $0x4,%eax
 6bb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 6be:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 6c5:	e9 59 01 00 00       	jmp    823 <printf+0x17f>
    c = fmt[i] & 0xff;
 6ca:	8b 55 0c             	mov    0xc(%ebp),%edx
 6cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6d0:	01 d0                	add    %edx,%eax
 6d2:	0f b6 00             	movzbl (%eax),%eax
 6d5:	0f be c0             	movsbl %al,%eax
 6d8:	25 ff 00 00 00       	and    $0xff,%eax
 6dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 6e0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 6e4:	75 2c                	jne    712 <printf+0x6e>
      if(c == '%'){
 6e6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 6ea:	75 0c                	jne    6f8 <printf+0x54>
        state = '%';
 6ec:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 6f3:	e9 27 01 00 00       	jmp    81f <printf+0x17b>
      } else {
        putc(fd, c);
 6f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 6fb:	0f be c0             	movsbl %al,%eax
 6fe:	83 ec 08             	sub    $0x8,%esp
 701:	50                   	push   %eax
 702:	ff 75 08             	pushl  0x8(%ebp)
 705:	e8 be fe ff ff       	call   5c8 <putc>
 70a:	83 c4 10             	add    $0x10,%esp
 70d:	e9 0d 01 00 00       	jmp    81f <printf+0x17b>
      }
    } else if(state == '%'){
 712:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 716:	0f 85 03 01 00 00    	jne    81f <printf+0x17b>
      if(c == 'd'){
 71c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 720:	75 1e                	jne    740 <printf+0x9c>
        printint(fd, *ap, 10, 1);
 722:	8b 45 e8             	mov    -0x18(%ebp),%eax
 725:	8b 00                	mov    (%eax),%eax
 727:	6a 01                	push   $0x1
 729:	6a 0a                	push   $0xa
 72b:	50                   	push   %eax
 72c:	ff 75 08             	pushl  0x8(%ebp)
 72f:	e8 bb fe ff ff       	call   5ef <printint>
 734:	83 c4 10             	add    $0x10,%esp
        ap++;
 737:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 73b:	e9 d8 00 00 00       	jmp    818 <printf+0x174>
      } else if(c == 'x' || c == 'p'){
 740:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 744:	74 06                	je     74c <printf+0xa8>
 746:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 74a:	75 1e                	jne    76a <printf+0xc6>
        printint(fd, *ap, 16, 0);
 74c:	8b 45 e8             	mov    -0x18(%ebp),%eax
 74f:	8b 00                	mov    (%eax),%eax
 751:	6a 00                	push   $0x0
 753:	6a 10                	push   $0x10
 755:	50                   	push   %eax
 756:	ff 75 08             	pushl  0x8(%ebp)
 759:	e8 91 fe ff ff       	call   5ef <printint>
 75e:	83 c4 10             	add    $0x10,%esp
        ap++;
 761:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 765:	e9 ae 00 00 00       	jmp    818 <printf+0x174>
      } else if(c == 's'){
 76a:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 76e:	75 43                	jne    7b3 <printf+0x10f>
        s = (char*)*ap;
 770:	8b 45 e8             	mov    -0x18(%ebp),%eax
 773:	8b 00                	mov    (%eax),%eax
 775:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 778:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 77c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 780:	75 25                	jne    7a7 <printf+0x103>
          s = "(null)";
 782:	c7 45 f4 9f 0b 00 00 	movl   $0xb9f,-0xc(%ebp)
        while(*s != 0){
 789:	eb 1c                	jmp    7a7 <printf+0x103>
          putc(fd, *s);
 78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78e:	0f b6 00             	movzbl (%eax),%eax
 791:	0f be c0             	movsbl %al,%eax
 794:	83 ec 08             	sub    $0x8,%esp
 797:	50                   	push   %eax
 798:	ff 75 08             	pushl  0x8(%ebp)
 79b:	e8 28 fe ff ff       	call   5c8 <putc>
 7a0:	83 c4 10             	add    $0x10,%esp
          s++;
 7a3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 7a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7aa:	0f b6 00             	movzbl (%eax),%eax
 7ad:	84 c0                	test   %al,%al
 7af:	75 da                	jne    78b <printf+0xe7>
 7b1:	eb 65                	jmp    818 <printf+0x174>
        }
      } else if(c == 'c'){
 7b3:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 7b7:	75 1d                	jne    7d6 <printf+0x132>
        putc(fd, *ap);
 7b9:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7bc:	8b 00                	mov    (%eax),%eax
 7be:	0f be c0             	movsbl %al,%eax
 7c1:	83 ec 08             	sub    $0x8,%esp
 7c4:	50                   	push   %eax
 7c5:	ff 75 08             	pushl  0x8(%ebp)
 7c8:	e8 fb fd ff ff       	call   5c8 <putc>
 7cd:	83 c4 10             	add    $0x10,%esp
        ap++;
 7d0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7d4:	eb 42                	jmp    818 <printf+0x174>
      } else if(c == '%'){
 7d6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 7da:	75 17                	jne    7f3 <printf+0x14f>
        putc(fd, c);
 7dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7df:	0f be c0             	movsbl %al,%eax
 7e2:	83 ec 08             	sub    $0x8,%esp
 7e5:	50                   	push   %eax
 7e6:	ff 75 08             	pushl  0x8(%ebp)
 7e9:	e8 da fd ff ff       	call   5c8 <putc>
 7ee:	83 c4 10             	add    $0x10,%esp
 7f1:	eb 25                	jmp    818 <printf+0x174>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7f3:	83 ec 08             	sub    $0x8,%esp
 7f6:	6a 25                	push   $0x25
 7f8:	ff 75 08             	pushl  0x8(%ebp)
 7fb:	e8 c8 fd ff ff       	call   5c8 <putc>
 800:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 803:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 806:	0f be c0             	movsbl %al,%eax
 809:	83 ec 08             	sub    $0x8,%esp
 80c:	50                   	push   %eax
 80d:	ff 75 08             	pushl  0x8(%ebp)
 810:	e8 b3 fd ff ff       	call   5c8 <putc>
 815:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 818:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 81f:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 823:	8b 55 0c             	mov    0xc(%ebp),%edx
 826:	8b 45 f0             	mov    -0x10(%ebp),%eax
 829:	01 d0                	add    %edx,%eax
 82b:	0f b6 00             	movzbl (%eax),%eax
 82e:	84 c0                	test   %al,%al
 830:	0f 85 94 fe ff ff    	jne    6ca <printf+0x26>
    }
  }
}
 836:	90                   	nop
 837:	90                   	nop
 838:	c9                   	leave  
 839:	c3                   	ret    

0000083a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 83a:	f3 0f 1e fb          	endbr32 
 83e:	55                   	push   %ebp
 83f:	89 e5                	mov    %esp,%ebp
 841:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 844:	8b 45 08             	mov    0x8(%ebp),%eax
 847:	83 e8 08             	sub    $0x8,%eax
 84a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 84d:	a1 30 0e 00 00       	mov    0xe30,%eax
 852:	89 45 fc             	mov    %eax,-0x4(%ebp)
 855:	eb 24                	jmp    87b <free+0x41>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 857:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85a:	8b 00                	mov    (%eax),%eax
 85c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 85f:	72 12                	jb     873 <free+0x39>
 861:	8b 45 f8             	mov    -0x8(%ebp),%eax
 864:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 867:	77 24                	ja     88d <free+0x53>
 869:	8b 45 fc             	mov    -0x4(%ebp),%eax
 86c:	8b 00                	mov    (%eax),%eax
 86e:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 871:	72 1a                	jb     88d <free+0x53>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 873:	8b 45 fc             	mov    -0x4(%ebp),%eax
 876:	8b 00                	mov    (%eax),%eax
 878:	89 45 fc             	mov    %eax,-0x4(%ebp)
 87b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 87e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 881:	76 d4                	jbe    857 <free+0x1d>
 883:	8b 45 fc             	mov    -0x4(%ebp),%eax
 886:	8b 00                	mov    (%eax),%eax
 888:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 88b:	73 ca                	jae    857 <free+0x1d>
      break;
  if(bp + bp->s.size == p->s.ptr){
 88d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 890:	8b 40 04             	mov    0x4(%eax),%eax
 893:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 89a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 89d:	01 c2                	add    %eax,%edx
 89f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a2:	8b 00                	mov    (%eax),%eax
 8a4:	39 c2                	cmp    %eax,%edx
 8a6:	75 24                	jne    8cc <free+0x92>
    bp->s.size += p->s.ptr->s.size;
 8a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8ab:	8b 50 04             	mov    0x4(%eax),%edx
 8ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8b1:	8b 00                	mov    (%eax),%eax
 8b3:	8b 40 04             	mov    0x4(%eax),%eax
 8b6:	01 c2                	add    %eax,%edx
 8b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8bb:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 8be:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8c1:	8b 00                	mov    (%eax),%eax
 8c3:	8b 10                	mov    (%eax),%edx
 8c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8c8:	89 10                	mov    %edx,(%eax)
 8ca:	eb 0a                	jmp    8d6 <free+0x9c>
  } else
    bp->s.ptr = p->s.ptr;
 8cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8cf:	8b 10                	mov    (%eax),%edx
 8d1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8d4:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 8d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8d9:	8b 40 04             	mov    0x4(%eax),%eax
 8dc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 8e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8e6:	01 d0                	add    %edx,%eax
 8e8:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 8eb:	75 20                	jne    90d <free+0xd3>
    p->s.size += bp->s.size;
 8ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8f0:	8b 50 04             	mov    0x4(%eax),%edx
 8f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 8f6:	8b 40 04             	mov    0x4(%eax),%eax
 8f9:	01 c2                	add    %eax,%edx
 8fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8fe:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 901:	8b 45 f8             	mov    -0x8(%ebp),%eax
 904:	8b 10                	mov    (%eax),%edx
 906:	8b 45 fc             	mov    -0x4(%ebp),%eax
 909:	89 10                	mov    %edx,(%eax)
 90b:	eb 08                	jmp    915 <free+0xdb>
  } else
    p->s.ptr = bp;
 90d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 910:	8b 55 f8             	mov    -0x8(%ebp),%edx
 913:	89 10                	mov    %edx,(%eax)
  freep = p;
 915:	8b 45 fc             	mov    -0x4(%ebp),%eax
 918:	a3 30 0e 00 00       	mov    %eax,0xe30
}
 91d:	90                   	nop
 91e:	c9                   	leave  
 91f:	c3                   	ret    

00000920 <morecore>:

static Header*
morecore(uint nu)
{
 920:	f3 0f 1e fb          	endbr32 
 924:	55                   	push   %ebp
 925:	89 e5                	mov    %esp,%ebp
 927:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 92a:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 931:	77 07                	ja     93a <morecore+0x1a>
    nu = 4096;
 933:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 93a:	8b 45 08             	mov    0x8(%ebp),%eax
 93d:	c1 e0 03             	shl    $0x3,%eax
 940:	83 ec 0c             	sub    $0xc,%esp
 943:	50                   	push   %eax
 944:	e8 4f fc ff ff       	call   598 <sbrk>
 949:	83 c4 10             	add    $0x10,%esp
 94c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 94f:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 953:	75 07                	jne    95c <morecore+0x3c>
    return 0;
 955:	b8 00 00 00 00       	mov    $0x0,%eax
 95a:	eb 26                	jmp    982 <morecore+0x62>
  hp = (Header*)p;
 95c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 962:	8b 45 f0             	mov    -0x10(%ebp),%eax
 965:	8b 55 08             	mov    0x8(%ebp),%edx
 968:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 96b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 96e:	83 c0 08             	add    $0x8,%eax
 971:	83 ec 0c             	sub    $0xc,%esp
 974:	50                   	push   %eax
 975:	e8 c0 fe ff ff       	call   83a <free>
 97a:	83 c4 10             	add    $0x10,%esp
  return freep;
 97d:	a1 30 0e 00 00       	mov    0xe30,%eax
}
 982:	c9                   	leave  
 983:	c3                   	ret    

00000984 <malloc>:

void*
malloc(uint nbytes)
{
 984:	f3 0f 1e fb          	endbr32 
 988:	55                   	push   %ebp
 989:	89 e5                	mov    %esp,%ebp
 98b:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 98e:	8b 45 08             	mov    0x8(%ebp),%eax
 991:	83 c0 07             	add    $0x7,%eax
 994:	c1 e8 03             	shr    $0x3,%eax
 997:	83 c0 01             	add    $0x1,%eax
 99a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 99d:	a1 30 0e 00 00       	mov    0xe30,%eax
 9a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9a9:	75 23                	jne    9ce <malloc+0x4a>
    base.s.ptr = freep = prevp = &base;
 9ab:	c7 45 f0 28 0e 00 00 	movl   $0xe28,-0x10(%ebp)
 9b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9b5:	a3 30 0e 00 00       	mov    %eax,0xe30
 9ba:	a1 30 0e 00 00       	mov    0xe30,%eax
 9bf:	a3 28 0e 00 00       	mov    %eax,0xe28
    base.s.size = 0;
 9c4:	c7 05 2c 0e 00 00 00 	movl   $0x0,0xe2c
 9cb:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9d1:	8b 00                	mov    (%eax),%eax
 9d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d9:	8b 40 04             	mov    0x4(%eax),%eax
 9dc:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9df:	77 4d                	ja     a2e <malloc+0xaa>
      if(p->s.size == nunits)
 9e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e4:	8b 40 04             	mov    0x4(%eax),%eax
 9e7:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 9ea:	75 0c                	jne    9f8 <malloc+0x74>
        prevp->s.ptr = p->s.ptr;
 9ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ef:	8b 10                	mov    (%eax),%edx
 9f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9f4:	89 10                	mov    %edx,(%eax)
 9f6:	eb 26                	jmp    a1e <malloc+0x9a>
      else {
        p->s.size -= nunits;
 9f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9fb:	8b 40 04             	mov    0x4(%eax),%eax
 9fe:	2b 45 ec             	sub    -0x14(%ebp),%eax
 a01:	89 c2                	mov    %eax,%edx
 a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a06:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a0c:	8b 40 04             	mov    0x4(%eax),%eax
 a0f:	c1 e0 03             	shl    $0x3,%eax
 a12:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a18:	8b 55 ec             	mov    -0x14(%ebp),%edx
 a1b:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a21:	a3 30 0e 00 00       	mov    %eax,0xe30
      return (void*)(p + 1);
 a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a29:	83 c0 08             	add    $0x8,%eax
 a2c:	eb 3b                	jmp    a69 <malloc+0xe5>
    }
    if(p == freep)
 a2e:	a1 30 0e 00 00       	mov    0xe30,%eax
 a33:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 a36:	75 1e                	jne    a56 <malloc+0xd2>
      if((p = morecore(nunits)) == 0)
 a38:	83 ec 0c             	sub    $0xc,%esp
 a3b:	ff 75 ec             	pushl  -0x14(%ebp)
 a3e:	e8 dd fe ff ff       	call   920 <morecore>
 a43:	83 c4 10             	add    $0x10,%esp
 a46:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a49:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a4d:	75 07                	jne    a56 <malloc+0xd2>
        return 0;
 a4f:	b8 00 00 00 00       	mov    $0x0,%eax
 a54:	eb 13                	jmp    a69 <malloc+0xe5>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a59:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a5f:	8b 00                	mov    (%eax),%eax
 a61:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a64:	e9 6d ff ff ff       	jmp    9d6 <malloc+0x52>
  }
}
 a69:	c9                   	leave  
 a6a:	c3                   	ret    
