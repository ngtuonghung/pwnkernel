#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL"); 
  
int init_module(void) 
{ 
    printk(KERN_INFO "Hello ngtuonghung1337!\n");
    return 0;
} 
  
void cleanup_module(void) 
{ 
    printk(KERN_INFO "Goodbye ngtuonghung1337!\n");
} 
