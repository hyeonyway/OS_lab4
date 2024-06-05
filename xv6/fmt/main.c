1200 #include "types.h"
1201 #include "defs.h"
1202 #include "param.h"
1203 #include "memlayout.h"
1204 #include "mmu.h"
1205 #include "proc.h"
1206 #include "x86.h"
1207 #include "mp_uefi.h"
1208 #include "debug.h"
1209 #include "graphic.h"
1210 #include "font.h"
1211 #include "pci.h"
1212 #include "i8254.h"
1213 #include "arp.h"
1214 
1215 static void startothers(void);
1216 static void mpmain(void)  __attribute__((noreturn));
1217 extern pde_t *kpgdir;
1218 extern char end[]; // first address after kernel loaded from ELF file
1219 
1220 // Bootstrap processor starts running C code here.
1221 // Allocate a real stack and switch to it, first
1222 // doing some setup required for memory allocator to work.
1223 int
1224 main(void)
1225 {
1226   graphic_init();
1227   kinit1(end, P2V(4*1024*1024)); // phys page allocator
1228   kvmalloc();      // kernel page table
1229   mpinit_uefi();
1230   lapicinit();     // interrupt controller
1231   seginit();       // segment descriptors
1232   picinit();    // disable pic
1233   ioapicinit();    // another interrupt controller
1234   consoleinit();   // console hardware
1235   uartinit();      // serial port
1236   pinit();         // process table
1237   tvinit();        // trap vectors
1238   binit();         // buffer cache
1239   fileinit();      // file table
1240   ideinit();       // disk
1241   startothers();   // start other processors
1242   kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
1243   pci_init();
1244   arp_scan();
1245   //i8254_recv();
1246   userinit();      // first user process
1247 
1248   mpmain();        // finish this processor's setup
1249 }
1250 // Other CPUs jump here from entryother.S.
1251 static void
1252 mpenter(void)
1253 {
1254   switchkvm();
1255   seginit();
1256   lapicinit();
1257   mpmain();
1258 }
1259 
1260 // Common CPU setup code.
1261 static void
1262 mpmain(void)
1263 {
1264   cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
1265   idtinit();       // load idt register
1266   xchg(&(mycpu()->started), 1); // tell startothers() we're up
1267   scheduler();     // start running processes
1268 }
1269 
1270 pde_t entrypgdir[];  // For entry.S
1271 
1272 // Start the non-boot (AP) processors.
1273 static void
1274 startothers(void)
1275 {
1276   extern uchar _binary_entryother_start[], _binary_entryother_size[];
1277   uchar *code;
1278   struct cpu *c;
1279   char *stack;
1280 
1281   // Write entry code to unused memory at 0x7000.
1282   // The linker has placed the image of entryother.S in
1283   // _binary_entryother_start.
1284   code = P2V(0x7000);
1285   memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
1286 
1287   for(c = cpus; c < cpus+ncpu; c++){
1288     if(c == mycpu()){  // We've started already.
1289       continue;
1290     }
1291     // Tell entryother.S what stack to use, where to enter, and what
1292     // pgdir to use. We cannot use kpgdir yet, because the AP processor
1293     // is running in low  memory, so we use entrypgdir for the APs too.
1294     stack = kalloc();
1295     *(void**)(code-4) = stack + KSTACKSIZE;
1296     *(void**)(code-8) = mpenter;
1297     *(int**)(code-12) = (void *) V2P(entrypgdir);
1298 
1299     lapicstartap(c->apicid, V2P(code));
1300     // wait for cpu to finish mpmain()
1301     while(c->started == 0)
1302       ;
1303   }
1304 }
1305 
1306 // The boot page table used in entry.S and entryother.S.
1307 // Page directories (and page tables) must start on page boundaries,
1308 // hence the __aligned__ attribute.
1309 // PTE_PS in a page directory entry enables 4Mbyte pages.
1310 
1311 __attribute__((__aligned__(PGSIZE)))
1312 pde_t entrypgdir[NPDENTRIES] = {
1313   // Map VA's [0, 4MB) to PA's [0, 4MB)
1314   [0] = (0) | PTE_P | PTE_W | PTE_PS,
1315   // Map VA's [KERNBASE, KERNBASE+4MB) to PA's [0, 4MB)
1316   [KERNBASE>>PDXSHIFT] = (0) | PTE_P | PTE_W | PTE_PS,
1317 };
1318 
1319 
1320 
1321 
1322 
1323 
1324 
1325 
1326 
1327 
1328 
1329 
1330 
1331 
1332 
1333 
1334 
1335 
1336 
1337 
1338 
1339 
1340 
1341 
1342 
1343 
1344 
1345 
1346 
1347 
1348 
1349 
1350 // Blank page.
1351 
1352 
1353 
1354 
1355 
1356 
1357 
1358 
1359 
1360 
1361 
1362 
1363 
1364 
1365 
1366 
1367 
1368 
1369 
1370 
1371 
1372 
1373 
1374 
1375 
1376 
1377 
1378 
1379 
1380 
1381 
1382 
1383 
1384 
1385 
1386 
1387 
1388 
1389 
1390 
1391 
1392 
1393 
1394 
1395 
1396 
1397 
1398 
1399 
1400 // Blank page.
1401 
1402 
1403 
1404 
1405 
1406 
1407 
1408 
1409 
1410 
1411 
1412 
1413 
1414 
1415 
1416 
1417 
1418 
1419 
1420 
1421 
1422 
1423 
1424 
1425 
1426 
1427 
1428 
1429 
1430 
1431 
1432 
1433 
1434 
1435 
1436 
1437 
1438 
1439 
1440 
1441 
1442 
1443 
1444 
1445 
1446 
1447 
1448 
1449 
1450 // Blank page.
1451 
1452 
1453 
1454 
1455 
1456 
1457 
1458 
1459 
1460 
1461 
1462 
1463 
1464 
1465 
1466 
1467 
1468 
1469 
1470 
1471 
1472 
1473 
1474 
1475 
1476 
1477 
1478 
1479 
1480 
1481 
1482 
1483 
1484 
1485 
1486 
1487 
1488 
1489 
1490 
1491 
1492 
1493 
1494 
1495 
1496 
1497 
1498 
1499 
