B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.01
@EndOfDesignText@
'Code module
'Subs in this code module will be accessible from all modules.
Sub Process_Globals
	Public Manager As PreferenceManager
End Sub

Sub CheckInternet As Boolean
	
	Dim P As Phone,server As ServerSocket'Add a reference to the network library  'Check status: DISCONNECTED 0
	Try
		server.Initialize(0, "")
		If server.GetMyIP = "127.0.0.1" Then Return False  'this is the local host address
		If Not(P.GetDataState.EqualsIgnoreCase("CONNECTED")) And server.GetMyWifiIP = "127.0.0.1" Then Return False
		Return True
	Catch
		Return False
	End Try

	
End Sub
