4050 // Long-term locks for processes
4051 struct sleeplock {
4052   uint locked;       // Is the lock held?
4053   struct spinlock lk; // spinlock protecting this sleep lock
4054 
4055   // For debugging:
4056   char *name;        // Name of lock.
4057   int pid;           // Process holding lock
4058 };
4059 
4060 
4061 
4062 
4063 
4064 
4065 
4066 
4067 
4068 
4069 
4070 
4071 
4072 
4073 
4074 
4075 
4076 
4077 
4078 
4079 
4080 
4081 
4082 
4083 
4084 
4085 
4086 
4087 
4088 
4089 
4090 
4091 
4092 
4093 
4094 
4095 
4096 
4097 
4098 
4099 
