# DBO5 Sheet Pipeline — VIVO Pipeline

This pipeline copies **VIVO operational data** from the FTP source into the SQL Server staging table and then performs an **incremental merge** into the destination table using stored procedures.

---

# Pipeline Details

**Data Factory:** JL-ADF-01

**Pipeline Hierarchy:** Stock_Consumption_New_Report

**Pipeline Name:** VIVO Pipeline

**Load Type:** Incremental

**Lookup Activity Description:** Ingests data from the FTP server into **stg5.vivo** and then updates **dbo5.Vivo** using incremental stored procedures.

**Log Update:** NO

---

# Source

**Source Type:** FTP

**Source Linked Service:** SAP_INPUT_LS

**IP:** 11.0.6.219

**Source File Folder Path:** BW_SAP_DATA_DUMP

**Source File Name / Filter Logic:** VIVOGETDATA.csv

**Source DB Name:** TestDB

**Source Table Name:** stg5.vivo

**Pre Copy Script:**

```sql
TRUNCATE TABLE stg5.vivo;
```

---

# Sink

**Sink Type:** SQL Server

**Sink Linked Service:** Source_Staging

**SP Name:**

* [dbo5].[update_from_stgTodbo_Vivo]
* [dbo5].[insert_from_stgTodbo_Vivo]

**dbo Table Name:** dbo5.Vivo

---

# Notes

* Copies **VIVOGETDATA.csv** from the FTP server (**11.0.6.219**) into the staging table **stg5.vivo**.
* Executes **TRUNCATE TABLE stg5.vivo;** before loading the latest file.
* Executes **[dbo5].[update_from_stgTodbo_Vivo]** to update existing records.
* Executes **[dbo5].[insert_from_stgTodbo_Vivo]** to insert newly arrived records.
* Performs an **Incremental Load** into **dbo5.Vivo**.

---

# Column Mapping (Source to Destination)

**Source File Name / Filter Logic:** VIVOGETDATA.csv

**Source DB Name:** TestDB

**Source Table Name:** stg5.vivo

| #  | Source Column                    | Source Type | Destination Column               | Destination Type |
| -- | -------------------------------- | ----------- | -------------------------------- | ---------------- |
| 1  | Plant                            | String      | Plant                            | nvarchar         |
| 2  | Billing Type                     | String      | Billing Type                     | nvarchar         |
| 3  | Sales Document Type              | String      | Sales Document Type              | nvarchar         |
| 4  | Plant Name                       | String      | Plant Name                       | nvarchar         |
| 5  | Division                         | String      | Division                         | nvarchar         |
| 6  | Division Name                    | String      | Division Name                    | nvarchar         |
| 7  | Customer                         | String      | Customer                         | nvarchar         |
| 8  | Customer Name                    | String      | Customer Name                    | nvarchar         |
| 9  | Sales Document                   | String      | Sales Document                   | nvarchar         |
| 10 | SAP Despatch Date                | Date        | SAP Despatch Date                | datetime         |
| 11 | Billing Document                 | String      | Billing Document                 | nvarchar         |
| 12 | Delivery No                      | String      | Delivery No                      | nvarchar         |
| 13 | Gate Entry No.                   | String      | Gate Entry No.                   | nvarchar         |
| 14 | Vehicle No.                      | String      | Vehicle No.                      | nvarchar         |
| 15 | Transporter Name                 | String      | Transporter Name                 | nvarchar         |
| 16 | Gate IN Date                     | Date        | Gate IN Date                     | datetime         |
| 17 | Gate IN Time                     | Time        | Gate IN Time                     | time             |
| 18 | Gate Out Entry No                | String      | Gate Out Entry No                | nvarchar         |
| 19 | Gate Out Date                    | Date        | Gate Out Date                    | datetime         |
| 20 | Gate Out Time                    | Time        | Gate Out Time                    | time             |
| 21 | Destination                      | String      | Destination                      | nvarchar         |
| 22 | Purchase order no.               | String      | Purchase order no.               | nvarchar         |
| 23 | Gate IN to Tare Wt.              | Time        | Gate IN to Tare Wt.              | nvarchar         |
| 24 | Tare Wt. to DO Release           | Time        | Tare Wt. to DO Release           | nvarchar         |
| 25 | DO to Loading                    | Time        | DO to Loading                    | nvarchar         |
| 26 | Loading to Gross Wt.             | Time        | Loading to Gross Wt.             | nvarchar         |
| 27 | Gross Wt. to PGI                 | Time        | Gross Wt. to PGI                 | nvarchar         |
| 28 | PGI to Way Bill                  | Time        | PGI to Way Bill                  | nvarchar         |
| 29 | Waybill to Gateout               | Time        | Waybill to Gateout               | nvarchar         |
| 30 | IG to OG                         | Time        | IG to OG                         | nvarchar         |
| 31 | Days                             | Integer     | Days                             | int              |
| 32 | Hours                            | Integer     | Hours                            | int              |
| 33 | Minutes                          | Integer     | Minutes                          | int              |
| 34 | Status                           | String      | Status                           | nvarchar         |
| 35 | Status Text                      | String      | Status Text                      | nvarchar         |
| 36 | Days Bucket                      | String      | Days Bucket                      | nvarchar         |
| 37 | Converted Gate IN to Tare WT     | Decimal     | Converted Gate IN to Tare WT     | decimal          |
| 38 | Converted Tare Wt. to DO Release | Decimal     | Converted Tare Wt. to DO Release | decimal          |
| 39 | Converted DO to Loading          | Decimal     | Converted DO to Loading          | decimal          |
| 40 | Converted Loading to Gross Wt.   | Decimal     | Converted Loading to Gross Wt.   | decimal          |
| 41 | Converted Gross Wt. to PGI       | Decimal     | Converted Gross Wt. to PGI       | decimal          |
| 42 | Converted PGI to Way Bill        | Decimal     | Converted PGI to Way Bill        | decimal          |
| 43 | Converted Waybill to Gateout     | Decimal     | Converted Waybill to Gateout     | decimal          |
| 44 | ActiveRecords                    | Integer     | ActiveRecords                    | int              |

> **Note:** The destination data types are inferred from the sample data. If the SQL Server schema for **dbo5.Vivo** differs, the destination types should be updated to match the actual table definition.
