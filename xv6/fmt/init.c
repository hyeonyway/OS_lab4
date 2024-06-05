8700 // init: The initial user-level program
8701 
8702 #include "types.h"
8703 #include "stat.h"
8704 #include "user.h"
8705 #include "fcntl.h"
8706 
8707 char *argv[] = { "sh", 0 };
8708 
8709 int
8710 main(void)
8711 {
8712   int pid, wpid;
8713 
8714   if(open("console", O_RDWR) < 0){
8715     mknod("console", 1, 1);
8716     open("console", O_RDWR);
8717   }
8718   dup(0);  // stdout
8719   dup(0);  // stderr
8720 
8721   for(;;){
8722     printf(1, "init: starting sh\n");
8723     pid = fork();
8724     if(pid < 0){
8725       printf(1, "init: fork failed\n");
8726       exit();
8727     }
8728     if(pid == 0){
8729       exec("sh", argv);
8730       printf(1, "init: exec sh failed\n");
8731       exit();
8732     }
8733     while((wpid=wait()) >= 0 && wpid != pid)
8734       printf(1, "zombie!\n");
8735   }
8736 }
8737 
8738 
8739 
8740 
8741 
8742 
8743 
8744 
8745 
8746 
8747 
8748 
8749 
