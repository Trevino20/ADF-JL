# dbo5.DimCustomer_OB_AFD

<img width="959" height="479" alt="image" src="https://github.com/user-attachments/assets/47b00cab-250c-4ac7-b4e7-d04cdffa4e12" />
# DBO5 Sheet Pipeline — sap_to_dwh_AFD

This pipeline copies **SAP Invoice** data from **Azure Data Lake Storage (ADLS)** into the SQL Server staging table and then performs an **incremental load** into the destination table using stored procedures.

---

# Pipeline Details

**Data Factory:** JL-ADF-01

**Pipeline Hierarchy:** ADLS_DWH → Executeall_ADLS_to_DWH_AFD

**Pipeline Name:** sap_to_dwh_AFD

**Load Type:** Incremental

**Lookup Activity Description:** Ingests data from ADLS into **stg5.SAPData_AFD** and incrementally updates **dbo5.DimCustomer_OB_AFD**.

**Log Update:** Yes

---

# Source

**Source Type:** ADLS

**Source Linked Service:** Storage_LS

**Source File Folder Path:** afdreport/Invoice_File_AFD

**Source File Name / Filter Logic:** Sap_adls_to_dwh_AFD

**Source DB Name:** TestDB

**Source Table Name:** stg5.SAPData_AFD

**Pre Copy Script:** None

---

# Sink

**Sink Type:** ADLS

**Sink Linked Service:** DWH_TestDB

**SP Name:**

* [dbo5].[sp_update_to_varchar_SAP_AFD]
* [dbo5].[update_from_stgTodbo_SAP_incremental_AFD]
* [dbo5].[insert_from_stgTodbo_SAP_incremental_AFD]

**dbo Table Name:** dbo5.DimCustomer_OB_AFD

---

# Notes

* Reads the **Sap_adls_to_dwh_AFD** file from **ADLS** under **afdreport/Invoice_File_AFD**.
* Loads the source data into **stg5.SAPData_AFD**.
* Executes **[dbo5].[sp_update_to_varchar_SAP_AFD]** to perform required data type conversions before loading.
* Executes **[dbo5].[update_from_stgTodbo_SAP_incremental_AFD]** to update existing records in the destination table.
* Executes **[dbo5].[insert_from_stgTodbo_SAP_incremental_AFD]** to insert new records into the destination table.
* Performs an **Incremental Load** into **dbo5.DimCustomer_OB_AFD**.

---

# Source Table

**Source File Name / Filter Logic:** Sap_adls_to_dwh_AFD

**Source DB Name:** TestDB

**Source Table Name:** stg5.SAPData_AFD

| #   | Source Column                   |
| --- | ------------------------------- |
| 1   | Natural Number                  |
| 2   | Excise Invoice Number           |
| 3   | Invoice Date                    |
| 4   | Ref Invoice Num                 |
| 5   | Legacy Invoice Number           |
| 6   | Sales Organization              |
| 7   | Distribution Channel            |
| 8   | Division                        |
| 9   | Plant                           |
| 10  | Storage Location                |
| 11  | Chapter ID                      |
| 12  | Excise Type                     |
| 13  | ARE1/ARE3                       |
| 14  | Billing Type                    |
| 15  | Buyer                           |
| 16  | Buyer Address                   |
| 17  | Buyer State                     |
| 18  | Buyer TIN/CST No                |
| 19  | Consignee                       |
| 20  | Consignee Address               |
| 21  | Delivery At                     |
| 22  | Consignee State                 |
| 23  | Consignee TIN/CST No            |
| 24  | PO Number                       |
| 25  | PO Date                         |
| 26  | Material Code                   |
| 27  | Material Description            |
| 28  | Material Group                  |
| 29  | Business area description       |
| 30  | Delivery                        |
| 31  | Quantity1                       |
| 32  | UOM1                            |
| 33  | Quantity2                       |
| 34  | UOM2                            |
| 35  | Quantity3                       |
| 36  | UOM3                            |
| 37  | Base Quantity                   |
| 38  | Base UOM                        |
| 39  | Material Rate                   |
| 40  | Cash Discount                   |
| 41  | Assessable Value                |
| 42  | Excise Duty                     |
| 43  | Education Cess                  |
| 44  | H & Edu Cess                    |
| 45  | Rate of Tax (VAT/CST)           |
| 46  | VAT                             |
| 47  | CST                             |
| 48  | Freight                         |
| 49  | Name of Comm1 Agent             |
| 50  | Commission1                     |
| 51  | Name of Comm2 Agent             |
| 52  | Commission2                     |
| 53  | Invoice Value                   |
| 54  | LR No                           |
| 55  | LR Date                         |
| 56  | Transporter Amount              |
| 57  | Transporter Name                |
| 58  | Seller Waybill No               |
| 59  | Gate Pass                       |
| 60  | Gate In Date                    |
| 61  | Truck Number                    |
| 62  | C - Form Serial No              |
| 63  | C - Form received date          |
| 64  | Cancelled                       |
| 65  | Thickness                       |
| 66  | Remarks                         |
| 67  | Unit Name                       |
| 68  | Auction Sale                    |
| 69  | Bill-To-Party Name              |
| 70  | Packaging Qty (KG)              |
| 71  | Basic Rate                      |
| 72  | Item Specification              |
| 73  | Length                          |
| 74  | Material Width                  |
| 75  | Material Thickness              |
| 76  | Special Discount                |
| 77  | Additional Cost                 |
| 78  | SO Charge                       |
| 79  | SO3 Meter Discount              |
| 80  | Quantity Discount               |
| 81  | Item Sl No                      |
| 82  | Tukra Discount                  |
| 83  | Special GR Charge               |
| 84  | B/E Charge                      |
| 85  | Less Qty Charge in %            |
| 86  | Less Qty Chrg in Qty            |
| 87  | PE Discount                     |
| 88  | SO Discount                     |
| 89  | Special Discount in %           |
| 90  | Freight VAT                     |
| 91  | Inspection Charge Qty           |
| 92  | Cutting Charge 3 MTR            |
| 93  | Export Freight                  |
| 94  | Export Insurance                |
| 95  | FOB Amount                      |
| 96  | CGST                            |
| 97  | SGST                            |
| 98  | IGST                            |
| 99  | Cancelled1                      |
| 100 | Cancelled BillDoc               |
| 101 | GSTIN No                        |
| 102 | Dumping Charges                 |
| 103 | Auction Sell Info               |
| 104 | Sales Order Number              |
| 105 | e-SalesDiscount(% in Total Val) |
| 106 | Insurance Charges               |
| 107 | Krishi Cess                     |
| 108 | Discount Net                    |
| 109 | Packing Charges                 |
| 110 | PE 3 Mtr Dis                    |
| 111 | Swach Cess                      |
| 112 | S/S Charge                      |
| 113 | Serv Tax                        |
| 114 | Bill to Party State             |
| 115 | e-Sales Disc(Value/Ton)         |
| 116 | e-Sales CondDisc(Total Value)   |
| 117 | Credit Charge                   |
| 118 | Zone                            |
| 119 | Incoterms                       |
| 120 | Length Calculation              |
| 121 | Width Calculation               |
| 122 | Thickness Calculation           |
| 123 | Material Thickness1             |
| 124 | Material Width1                 |
| 125 | Weighbridge Reference Number    |
| 126 | Packaging Qty (KG)1             |
| 127 | Tare Weight                     |
| 128 | Gross Weight                    |
| 129 | Net Weight                      |
| 130 | Route                           |
| 131 | Route Description               |
| 132 | Descriptn                       |
| 133 | Descriptn1                      |
| 134 | Descriptn2                      |
| 135 | MTR_GRP4                        |
| 136 | MTR_GRP5                        |
| 137 | Container No                    |
| 138 | RFID Seal No                    |
| 139 | Agent Seal No                   |
| 140 | Advance Licence No              |
| 141 | Advance Licence Date            |
| 142 | CommBill No                     |
| 143 | Special Note                    |
| 144 | Shipping bill number            |
| 145 | Shipping bill date              |
| 146 | Exchange Rate                   |
| 147 | Foreign Currency                |
| 148 | Foreign Curr Amt                |
| 149 | Buyer Code                      |
| 150 | Consign Code                    |
| 151 | Bill To Party Code              |
| 152 | SO Delivery Date                |
| 153 | Freight booking amount in SO    |
| 154 | Rate adjustment amt             |
| 155 | City code                       |
| 156 | Terms of Payment Key            |
| 157 | Terms of Payment Description    |
| 158 | Batch Stock                     |
| 159 | Batch SLocation                 |
| 160 | E-Way Bill Number               |
| 161 | E-Way Bill Date                 |
| 162 | IRN Number                      |
| 163 | IRN Date                        |
| 164 | STD-Act Qty Tolerance%          |
| 165 | Sales G/L account               |
| 166 | Actual Thickness                |
| 167 | OD Size of Pipe                 |
| 168 | STD Weight                      |
| 169 | Order                           |
| 170 | Short Text                      |
| 171 | Sales Document Type             |
| 172 | ExtState                        |
| 173 | LessCForm                       |
| 174 | ExtAZ150                        |
| 175 | ExtProfilSheet                  |
| 176 | Colour Charge                   |
| 177 | Less Freight                    |
| 178 | Category                        |
| 179 | filtercol                       |
| 180 | Base_Quantity_New               |
| 181 | Category_1                      |

---

# Destination Table

**dbo Table Name:** dbo5.DimCustomer_OB_AFD

| #  | Destination Column     |
| -- | ---------------------- |
| 1  | CustomerKey            |
| 2  | Customer Code          |
| 3  | Appended Customer Code |
| 4  | Distribution Channel   |
| 5  | Customer Name          |
| 6  | City                   |
| 7  | Region                 |
| 8  | State                  |
| 9  | House Number           |
| 10 | Postal Code            |
| 11 | District               |
| 12 | Mail Address           |
| 13 | Telephone Number       |
| 14 | Contact Person         |
| 15 | Country                |
| 16 | Street                 |
| 17 | GST                    |
| 18 | Recon account          |
| 19 | Customer Type          |
| 20 | PAN                    |
| 21 | Bank Key               |
| 22 | Bank Country           |
| 23 | SWIFT/BIC              |
| 24 | Bank Account           |
| 25 | TAN NO                 |
| 26 | AAdhaar No             |
