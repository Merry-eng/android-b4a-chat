B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=7.01
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: False
#End Region

Sub Process_Globals

End Sub

Sub Globals
	Private txtname As EditText
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("frmprofile")
	txtname.Text = Library.Manager.GetString2("name","بی نام")
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub btnsave_Click
	Library.Manager.SetString("name",txtname.Text)
	Activity.Finish
End Sub

Sub btnclose_Click
	Activity.Finish
End Sub