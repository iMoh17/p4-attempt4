#include "types.h"
#include "stat.h"
#include "user.h"
#include "mmu.h"
//#include "defs.h"

int
main(int argc, char *argv[])
{
    char *ptr = sbrk(PGSIZE); // Allocate one page
    
    printf(1,"0000000000000000here000000000000 %s\n",ptr);
   
   mencrypt(ptr, 1); // Encrypt the pages
 
struct pt_entry pt_entry; 
int t = getpgtable(&pt_entry, 10,0); // Get the page table information for newly allocated page
printf(1,"%d\n",t);
exit();
}
