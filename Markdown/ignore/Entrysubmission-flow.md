## Single Entry Submission Workflow

> Adjustment Entry:save(nil, true, false) - updateTable, exportEntry, skipLockouts
> 
> entry:GetSaveDetails()
> 
> DKPManager:ExportEntry(entry)
> 
> SyncSmall Comms Message
> 
> PDKP_OnComm_EntrySync (SyncSmall)
> 
> DKPManager:ImportEntry(entry)
> 
> Lockouts:AddMemberLockouts - returns the number of eligible members.
> 
> Ledger:ImportEntry - Returns true if you can import it, false otherwise.
> 
> importEntry:Save(true, nil, nil) - updateTable, exportEntry, skipLockouts

---
