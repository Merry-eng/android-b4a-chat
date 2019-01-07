B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.01
@EndOfDesignText@
Sub Class_Globals
	Private sql1 As SQL
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize

	If File.Exists(File.DirInternal,"report6") = False Then
		File.Copy(File.DirAssets,"data.sqlite",File.DirInternal,"report6")
	End If
	
	File.Copy(File.DirInternal,"report6",File.DirRootExternal,"report6")
	
	sql1.Initialize(File.DirInternal,"report6",False)
	File.Copy(File.DirInternal,"report6",File.DirRootExternal,"a.db")
	
	
End Sub

Sub AddMessage(sFrom As String,sFromTitle As String,sTime As String,sBody As String,sType As String,IsMe As Int,sTo As String)
	
	Dim s As String
	s = $"INSERT INTO tbl_data(sFrom,sFromTitle,sTime,sBody,sType,sSeen,sIsMe,sTo) VALUES('${sFrom}','${sFromTitle}','${sTime}','${sBody}','${sType}','0',${IsMe},'${sTo}')"$
	
	sql1.ExecNonQuery(s)
	
End Sub

Sub GetMessage(sType As String) As List
	
	Dim cu As Cursor
	cu = sql1.ExecQuery("SELECT * FROM tbl_data WHERE sType = '" & sType & "' AND sTo ='' GROUP BY sFrom ORDER BY sTime DESC")
	
	Dim ls As List
	ls.Initialize
	
	For i = 0 To cu.RowCount - 1
		
		cu.Position = i
		
		ls.Add(CreateMap("sFrom":cu.GetString("sFrom"),"sFromName":cu.GetString("sFromTitle"),"sBody":cu.GetString("sBody"),"sTime":cu.GetString("sTime"),"IsMe":cu.GetString("sIsMe")))
		
	Next
	
	Return ls
	
End Sub

Sub GetMessageForNumber(sFrom As String) As List
	
	Dim cu As Cursor
	cu = sql1.ExecQuery("SELECT * FROM tbl_data WHERE sFrom = '" & sFrom & "' OR sTo = '" & sFrom & "' ORDER BY sTime ASC")
	
	Dim ls As List
	ls.Initialize
	
	For i = 0 To cu.RowCount - 1
		
		cu.Position = i
		
		ls.Add(CreateMap("sFrom":cu.GetString("sFrom"),"sFromName":cu.GetString("sFromTitle"),"sBody":cu.GetString("sBody"),"sTime":cu.GetString("sTime"),"IsMe":cu.GetString("sIsMe")))
		
	Next
	
	sql1.ExecNonQuery("UPDATE tbl_data SET sSeen = '1' WHERE sFrom = '" & sFrom & "'")
	
	Return ls
	
End Sub

Sub GetUnSeenMessage(FromNumber As String) As Int
	
	Return sql1.ExecQuerySingleResult("SELECT COUNT(sSeen) FROM tbl_data WHERE sFrom = '" & FromNumber & "' AND sSeen = '0' AND sIsMe = 0")
	
End Sub

Sub DeleteMessageForNumber(sFrom As String)
	sql1.ExecNonQuery("DELETE FROM tbl_data WHERE sFrom = '" & sFrom & "' OR sTo = '" & sFrom & "'")
End Sub