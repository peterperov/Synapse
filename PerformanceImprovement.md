# SQL on VM Performance 

Data generation for WWI on SQL Server takes 3-4 min per day from June 2016. That's ~24 hours per year of data generation. And I want 6 years from 2016 to 2023.

## Current SQL Server VM 

| | | 
|-|-|
| SQL Version | Microsoft SQL Server 2019 (RTM) - 15.0.2000.5 (X64) |
| VM Size | Standard B4ms (4 vcpus, 16 GiB memory) |
| Disk | Standard HDD LRS, Size: 1024, MaxIOPS: 500 | 

## Improvements considerations

### Use Premium/Ultra Disks

| SKU | Size | Max IOPS | Price | 
|-|-|-|-|
| P20 | 512 Gb | 2,300 (3,500) | €76.41 |
| P30 | 1 Tb | 5,000 (30,000) | €141.05 |
| Ultra(*) | 1 Tb | 5,000 | €475.55 | 

(*) Ultra disks are billed on provisioned capacity + IOPS + Throughput see [Ulta Disks](https://azure.microsoft.com/en-us/pricing/details/managed-disks/) for more information 

### Use Faster VM

| Server | SKU | CPU | RAM | Temp Storage | Price | 
| el-cheapo Dev Box | B4ms | 4 | 16 | 32 Gb |  €0.197 p/h, €144 p/m |
| Ds series, standard, v3 | D4s v3 | 4 | 16 | 32 Gb | €0.378 p/h, €275 p/m |
| Ds series, standard vCPU/ram ratio | D4s v5 | 4 | 16 | 0 | €0.378 p/h, €275 p/m |
| Ds series, moar RAM | DS12 v2 | 4 | 28 | €0.461 p/h, €336 p/m |

Database size is ~5Gb for period Jan 2013 - June 2016 + 1 month of generated data. 


RAM: SQL Server is using 5Gb out of 16 Gb available. 


IO: is around 1Mb per second. 


## Theory 

B4ms seem to be bottlenecking on IO throughput in this scenario, CPU and RAM load is minimal. 


Standard Ds series with Premium Disk configured with [best practices](https://learn.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-checklist), most importantly: 

* Standard SSD for OS Disk 
* Premium SSD for Data Disk
* Data Disk Host Cache - Read/Only 
* Place tempdb on Temporary Storage 


Gonna ignore Log/Data on different Disks for the time. 


# Conclusion 

Well... the theory was totally wrong, using the fastest VM improves the situation somewhat, but the main problem was in transaction log bottlenecking with large amount of writes. Setting delayed durability to forced drastically improves the situation for this parctiluar case but puts consistency of data at risk. Do not do this in production. 


```
ALTER DATABASE ... SET DELAYED_DURABILITY = { DISABLED | ALLOWED | FORCED }

ALTER DATABASE WideWorldImporters SET DELAYED_DURABILITY =  FORCED 
```
