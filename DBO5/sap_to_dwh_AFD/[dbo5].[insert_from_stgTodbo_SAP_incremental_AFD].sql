/****** Object:  StoredProcedure [dbo5].[insert_from_stgTodbo_SAP_incremental_AFD]    Script Date: 29-07-2026 15:30:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE    PROCEDURE [dbo5].[insert_from_stgTodbo_SAP_incremental_AFD] AS

begin

DECLARE @activity_name VARCHAR(100) 
SET @activity_name='dbo5.insert_from_stgTodbo_SAP_incremental_AFD'
DECLARE @activity_type VARCHAR(100)
SET @activity_type='Transformation'
DECLARE @inserted_rows INT
SET @inserted_rows=0
DECLARE @modulename VARCHAR(100)
SET @modulename='SAP'
DECLARE @Platform_of_insertion VARCHAR(100)
SET @Platform_of_insertion='Stored Procedure'
DECLARE @time_para DATETIME 
SET @time_para=GETDATE()
DECLARE @destination VARCHAR(100)
SET @destination='DataWarehouse_Published'
DECLARE @LogID INT
DECLARE @TempTable TABLE (ActivityLog_ID INT)


INSERT INTO @TempTable
EXEC [dbo5].[Log_system_insert_detail] @Platform_of_insertion,@inserted_rows, @activity_name,'4',@modulename, @activity_type,@time_para ,@destination ;

SELECT @LogID=ActivityLog_ID FROM @TempTable
begin transaction;

begin try


INSERT INTO dbo5.FactSAP_AFD
select distinct 
 [DateKey]
      ,[GeoKey]
      ,[MaterialKey]
      ,[CustomerKey]
      ,[Excise Invoice Number]
      ,[Invoice Date]
      ,[Ref Invoice Num]
      ,[Legacy Invoice Number]
      ,[Sales Organization]
      ,[Distribution Channel]
      ,[Division]
      ,[Plant]
      ,[Storage Location]
      ,[Chapter ID]
      ,[Excise Type]
      ,[ARE1/ARE3]
      ,[Billing Type]
      ,[Buyer]
      ,[Buyer Address]
      ,[Buyer State]
      ,[Buyer TIN/CST No]
      ,[Consignee]
		, [Consignee Address],
         [Delivery At:]
      ,[Consignee State]
      ,[Consignee TIN/CST No]
      ,[PO Number]
      ,[Po Date]
      ,[Material Code]
      , [Material Description]
      ,[Material Group]
      ,[Business area description]
      ,[Delivery]
      ,[Quantity1]
      ,[UOM1]
      ,[Quantity2]
      ,[UOM2]
      ,[Quantity3]
      ,[UOM3]
      , [Base Quantity]
      ,[Base UOM]
      ,[Material Rate]
      ,[Cash Discount]
      ,[Assessable Value]
      ,[Excise Duty]
      ,[Education Cess]
      ,[H & Edu Cess]
      ,[Rate of Tax(VAT/CST)]
      ,[VAT]
      ,[CST]
      ,[Freight]
      ,[Name of Comm1 Agent]
      ,[Commission1]
      ,[Name of Comm2 Agent]
      ,[Commission2]
      ,[Invoice Value]
      ,[LR No]
      ,[LR Date]
      ,[Transporter Amount]
      ,[Transporter Name]
      ,[Seller Waybill No]
      ,[Gate Pass]
      ,[Gate In Date]
      ,[Truck Number]
      ,[C - Form Serial No]
      ,[C - Form received date]
      ,[Cancelled]
      ,[Thickness]
      ,[Remarks]
      ,[Unit Name]
      ,[Auction Sale]
      ,[Bill-To-Party Name]
      ,[Packaging Qty (KG)]
      ,[Basic Rate]
      ,[Item Specification]
      ,[Length]
      ,[Material Width]
      ,[Material Thickness]
      ,[Special Discount]
      ,[Additional Cost]
      ,[SO Charge]
      ,[SO3 Meter Discount]
      ,[Quantity Discount]
      ,[Item Sl No]
      ,[Tukra Discount]
      ,[Special GR Charge]
      ,[B/E Bharge]
      ,[Less Qty Charge in %]
      ,[Less Qty Chrg in Qty]
      ,[PE Discount]
      ,[SO Discount]
      ,[Special Disnt in %]
      ,[Freight VAT]
      ,[Inspection Charge Qty]
      ,[Cutting Charge 3 MTR]
      ,[Export Freight]
      ,[Export Insuran]
      ,[FOB Amount]
      ,[CGST]
      ,[SGST]
      ,[IGST]
      ,[Cancelled1]
      ,[Cancelled BillDoc]
      ,[GSTIN No]
      ,[Dumping Charges]
      ,[Auction Sell Info]
      ,[Sales Order Number]
      ,[e-SalesDiscount(%in Total Val)]
      ,[Insurance Charges]
      ,[Krishi Cess]
      ,[Discount Net]
      ,[Packing Charges]
      ,[PE 3 Mtr Dis]
      ,[Swach Cess]
      ,[S/S Charge]
      ,[Serv Tax]
      ,[Bill to party State]
      ,[e-Sales Disc(Value/Ton)]
      ,[e-Sales CondDisc(Total Value)]
      ,[Credit Charge]
      ,[Zone]
      ,[Incoterms]
      ,[Length Calculation]
      ,[Width Calculation]
      ,[Thickness Calculation]
      ,[Material Thickness1]
      ,[Material Width1]
      ,[Weighbridge Reference Number]
      ,[Packaging Qty (KG)1]
      ,[Tare Weight]
      ,[Gross Weight]
      ,[Net Weight]
      ,[Route]
      ,[Route Description]
      ,[Descriptn]
      ,[Descriptn1]
      ,[Descriptn2]
      ,[MTR_GRP4]
      ,[MTR_GRP5]
      ,[Container No]
      ,[RFID Seal No]
      ,[Agent Seal No]
      ,[Advance Licence No]
      ,[Advance Licence Date]
      ,[CommBill No]
      ,[Special Note]
      ,[Shipping bill number]
      ,[Shipping bill date]
      ,[Exchange Rate]
      ,[Foreign Currency]
      ,[Foreign Curr Amt]
      ,[Buyer Code]
      ,[Consign Code]
      ,[Bill To Party Code]
      ,[SO Delivery Date]
      ,[Freight booking amount in SO]
      ,[Rate adjustment amt]
      ,[City code]
      ,[Terms of Payment Key]
      ,[Terms of Payment Description]
      ,[Batch Stock]
      ,[Batch SLocation]
      ,[E-Way Bill Number]
      ,[E-Way Bill Date]
      ,[IRN Number]
      ,[IRN Date]
      ,[STD-Act Qty Tolerance%]
      ,[Sales G/L account]
      ,[Actual Thickness]
      ,[OD Size of Pipe]
      ,[STD Weight]
      ,[Order]
      ,[Short Text]
      ,[Sales Document Type]
      ,[ExtState]
      ,[LessCForm]
      ,[ExtAZ150]
      ,[ExtProfilSheet]
      ,[Colour Charge]
      ,[Less Freight]
	  ,[Category]
	  ,[Natural Number]
	  ,[Base_Quantity_New]
	  ,[Category_1]
from
(SELECT ROW_NUMBER() over(partition by c.[DateKey]
      ,g.[GeoKey]
      ,m.[MaterialKey]
      ,cs.[CustomerKey],s.[Natural Number] order by c.[DateKey]
      ,g.[GeoKey]
      ,m.[MaterialKey]
      ,cs.[CustomerKey],s.[Natural Number]  ) as row_rank,
	  
	  
	  
	  c.[DateKey]
      ,g.[GeoKey]
      ,m.[MaterialKey]
      ,cs.[CustomerKey]
      ,s.[Excise Invoice Number]
      ,s.[Invoice Date]
      ,s.[Ref Invoice Num]
      ,s.[Legacy Invoice Number]
      ,s.[Sales Organization]
      ,s.[Distribution Channel]
      ,s.[Division]
      ,s.[Plant]
      ,s.[Storage Location]
      ,s.[Chapter ID]
      ,s.[Excise Type]
      ,s.[ARE1/ARE3]
      ,s.[Billing Type]
      ,s.[Buyer]
      ,CONVERT(NVARCHAR, s.[Buyer Address]) AS [Buyer Address]
      ,s.[Buyer State]
      ,s.[Buyer TIN/CST No]
      ,s.[Consignee]
		,CONVERT(NVARCHAR, s.[Consignee Address]) AS [Consignee Address],
        CONVERT(NVARCHAR, s.[Delivery At:]) AS [Delivery At:]
      ,s.[Consignee State]
      ,s.[Consignee TIN/CST No]
      ,s.[PO Number]
      ,s.[Po Date]
      ,s.[Material Code]
      ,CONVERT(NVARCHAR, s.[Material Description]) AS [Material Description]
      ,s.[Material Group]
      ,s.[Business area description]
      ,s.[Delivery]
      ,s.[Quantity1]
      ,s.[UOM1]
      ,s.[Quantity2]
      ,s.[UOM2]
      ,s.[Quantity3]
      ,s.[UOM3]
      ,CONVERT(float,s.[Base Quantity]) [Base Quantity]
      ,s.[Base UOM]
      ,s.[Material Rate]
      ,s.[Cash Discount]
      ,s.[Assessable Value]
      ,s.[Excise Duty]
      ,s.[Education Cess]
      ,s.[H & Edu Cess]
      ,s.[Rate of Tax(VAT/CST)]
      ,s.[VAT]
      ,s.[CST]
      ,s.[Freight]
      ,s.[Name of Comm1 Agent]
      ,s.[Commission1]
      ,s.[Name of Comm2 Agent]
      ,s.[Commission2]
      ,s.[Invoice Value]
      ,s.[LR No]
      ,s.[LR Date]
      ,s.[Transporter Amount]
      ,s.[Transporter Name]
      ,s.[Seller Waybill No]
      ,s.[Gate Pass]
      ,s.[Gate In Date]
      ,s.[Truck Number]
      ,s.[C - Form Serial No]
      ,s.[C - Form received date]
      ,s.[Cancelled]
      ,s.[Thickness]
      ,s.[Remarks]
      ,s.[Unit Name]
      ,s.[Auction Sale]
      ,s.[Bill-To-Party Name]
      ,s.[Packaging Qty (KG)]
      ,s.[Basic Rate]
      ,s.[Item Specification]
      ,s.[Length]
      ,s.[Material Width]
      ,s.[Material Thickness]
      ,s.[Special Discount]
      ,s.[Additional Cost]
      ,s.[SO Charge]
      ,s.[SO3 Meter Discount]
      ,s.[Quantity Discount]
      ,s.[Item Sl No]
      ,s.[Tukra Discount]
      ,s.[Special GR Charge]
      ,s.[B/E Bharge]
      ,s.[Less Qty Charge in %]
      ,s.[Less Qty Chrg in Qty]
      ,s.[PE Discount]
      ,s.[SO Discount]
      ,s.[Special Disnt in %]
      ,s.[Freight VAT]
      ,s.[Inspection Charge Qty]
      ,s.[Cutting Charge 3 MTR]
      ,s.[Export Freight]
      ,s.[Export Insuran]
      ,s.[FOB Amount]
      ,s.[CGST]
      ,s.[SGST]
      ,s.[IGST]
      ,s.[Cancelled1]
      ,s.[Cancelled BillDoc]
      ,s.[GSTIN No]
      ,s.[Dumping Charges]
      ,s.[Auction Sell Info]
      ,s.[Sales Order Number]
      ,s.[e-SalesDiscount(%in Total Val)]
      ,s.[Insurance Charges]
      ,s.[Krishi Cess]
      ,s.[Discount Net]
      ,s.[Packing Charges]
      ,s.[PE 3 Mtr Dis]
      ,s.[Swach Cess]
      ,s.[S/S Charge]
      ,s.[Serv Tax]
      ,s.[Bill to party State]
      ,s.[e-Sales Disc(Value/Ton)]
      ,s.[e-Sales CondDisc(Total Value)]
      ,s.[Credit Charge]
      ,s.[Zone]
      ,s.[Incoterms]
      ,s.[Length Calculation]
      ,s.[Width Calculation]
      ,s.[Thickness Calculation]
      ,s.[Material Thickness1]
      ,s.[Material Width1]
      ,s.[Weighbridge Reference Number]
      ,s.[Packaging Qty (KG)1]
      ,s.[Tare Weight]
      ,s.[Gross Weight]
      ,s.[Net Weight]
      ,s.[Route]
      ,s.[Route Description]
      ,s.[Descriptn]
      ,s.[Descriptn1]
      ,s.[Descriptn2]
      ,s.[MTR_GRP4]
      ,s.[MTR_GRP5]
      ,s.[Container No]
      ,s.[RFID Seal No]
      ,s.[Agent Seal No]
      ,s.[Advance Licence No]
      ,s.[Advance Licence Date]
      ,s.[CommBill No]
      ,s.[Special Note]
      ,s.[Shipping bill number]
      ,s.[Shipping bill date]
      ,s.[Exchange Rate]
      ,s.[Foreign Currency]
      ,s.[Foreign Curr Amt]
      ,s.[Buyer Code]
      ,s.[Consign Code]
      ,s.[Bill To Party Code]
      ,s.[SO Delivery Date]
      ,s.[Freight booking amount in SO]
      ,s.[Rate adjustment amt]
      ,s.[City code]
      ,s.[Terms of Payment Key]
      ,s.[Terms of Payment Description]
      ,s.[Batch Stock]
      ,s.[Batch SLocation]
      ,s.[E-Way Bill Number]
      ,s.[E-Way Bill Date]
      ,s.[IRN Number]
      ,s.[IRN Date]
      ,s.[STD-Act Qty Tolerance%]
      ,s.[Sales G/L account]
      ,s.[Actual Thickness]
      ,s.[OD Size of Pipe]
      ,s.[STD Weight]
      ,s.[Order]
      ,s.[Short Text]
      ,s.[Sales Document Type]
      ,s.[ExtState]
      ,s.[LessCForm]
      ,s.[ExtAZ150]
      ,s.[ExtProfilSheet]
      ,s.[Colour Charge]
      ,s.[Less Freight]
	  ,s.[Category]
	  ,s.[Natural Number]
	  ,s.[Base_Quantity_New]
	  ,s.[Category_1]
from stg5.SAPData_AFD s
left join [dbo5].[DimCalendar] c on convert(nvarchar,
convert(date,s.[Invoice Date],103),23) = c.[Date]
left join [dbo5].[DimCustomer_OB_AFD] cs on s.[Buyer Code] = cs.[Customer Code]
left join [dbo5].[DimMaterial_OB_AFD] m on s.[Material Code] = m.[MaterialCode]
left join [dbo5].[DimGeo_AFD] g on lower(trim(s.[Consignee State])) = lower(trim(g.state))

WHERE
m.[Material Code]  IS NOT NULL AND 
cs.[Customer Code] IS  NOT NULL AND
(filtercol IS NOT NULL) AND Category IS NOT NULL and 
g.GeoKey is not null      
AND
               
 s.[Invoice Date]>(SELECT LastModifiedDate
								FROM dbo5.high_watermark
								WHERE TableName='dbo5.FactSAP_AFD'
						)


)as a

where row_rank=1    


SET @inserted_rows=@@ROWCOUNT;


------------------------------Convert Invoice Back to string-------------------------

ALTER TABLE stg5.SAPData_AFD
ALTER COLUMN [Invoice Date] nvarchar(255)


alter table stg5.SAPData_AFD                                         ---text
alter column [Buyer Address] nvarchar(1000)


alter table stg5.SAPData_AFD                                            ---text
alter column [Consignee Address] nvarchar(1000)


alter table stg5.SAPData_AFD                                             ---text
alter column [Delivery At:] nvarchar(1000)

alter table stg5.SAPData_AFD                                           ---text
alter column [Material Description] nvarchar(1000)

ALTER TABLE stg5.SAPData_AFD  ---float
ALTER COLUMN [Base Quantity] nvarchar(255)

ALTER TABLE stg5.SAPData_AFD                                             ---decimal(10,5)
ALTER COLUMN [Base_Quantity_New] nvarchar(255)

alter table stg5.SAPData_AFD
alter column [Descriptn] nvarchar(1000)

ALTER TABLE stg5.SAPData_AFD
ALTER COLUMN [PO Date] NVARCHAR(100);



EXEC [dbo5].[Log_system_Update_detail] @LogID,@inserted_rows,@modulename,@activity_type,NULL,@destination,0;

COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- If any error occurs, print the error message and roll back the transaction
        PRINT 'Error occurred: ' + ERROR_MESSAGE();

			IF XACT_STATE() <> 0 
		BEGIN             -- If there is an active or uncommittable transaction
    ROLLBACK TRANSACTION;
	END         
		DECLARE @remarks NVARCHAR(MAX)
		SET @remarks=ERROR_MESSAGE()
		EXEC [dbo5].[Log_system_Update_detail_error_log] @LogID,@inserted_rows,@modulename,@activity_type,@remarks,@destination;
    END CATCH;
END;
GO


