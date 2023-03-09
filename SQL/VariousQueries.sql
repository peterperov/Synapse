/*

use WideWorldImportersDW
go 

EXECUTE [Application].Configuration_ReseedETL

*/

/*

WorldWideImportersDW
*/

/*

select * from FAct.Movement

select * from Integration.[ETL Cutoff]

*/

select min([Invoice Date Key]), max([Invoice Date Key]) from fact.sale

select [Invoice Date Key], count(1) 
from Fact.Sale
group by [Invoice Date Key]
order by 1 desc


select * from integration.Lineage


SELECT distinct [calendar year] from dimension.[date]
order by 1


select * from Integration.Movement_Staging


select [date key] from Integration.Movement_Staging
where [date key] not in ( select [date] from dimension.date) 

/*

WorldWideImporters
*/

select invoiceDate, count(1) 
from Sales.Invoices
group by invoicedate 
order by 1 desc
