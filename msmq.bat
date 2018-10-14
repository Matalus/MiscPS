TASKKILL /F /FI "IMAGENAME EQ MQSVC.EXE" /T
cd c:\windows\System32\msmq\storage
DEL /Q QMLog
DEL /Q MQInSeqs.lg1
DEL /Q MQInSeqs.lg2
DEL /Q MQTrans.lg1
DEL /Q MQTrans.lg2
reg add HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSMQ\Parameters/v LogDataCreated /t REG_DWORD /d 0 /f
NET START MSMQ
