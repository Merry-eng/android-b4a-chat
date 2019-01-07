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
	Private sm As SlideMenu
	Private lblunseenmessage As Label
	Private lbltitle As Label
	Private lbltime As Label
	Private msg As Messages
	Private sv1 As ScrollView
	Private lblmessage As Label
	Private lblcomment As Label
	Private btnsend As Button
End Sub

Sub Activity_Create(FirstTime As Boolean)

	Activity.LoadLayout("frmmain")
	sm.Initialize(90dip,Me)
	
End Sub

Sub UpdateData
	
	Dim Top As Int
	Dim time As Conversion
	Dim msgList As List
	
	sv1.Panel.RemoveAllViews
	
	msg.Initialize
	msgList = msg.GetMessage("new_message")
	Top = 3dip
	
	If msgList.Size = 0 Then
		lblcomment.Visible = True
	Else
		lblcomment.Visible = False
	End If
	
	For i = 0 To msgList.Size - 1
		Dim m As Map
		m = msgList.Get(i)
		
		Dim p As Panel
		p.Initialize("")
		
		sv1.Panel.AddView(p,0,Top,sv1.Width,70dip)
		p.LoadLayout("frmtemplate_message")
		
		Top = Top + p.Height + 2dip
		
		lbltitle.Text = m.Get("sFromName")
		lbltime.Text = time.GetTimeAgo(m.Get("sTime"))
		lblmessage.Text = BreakString(m.Get("sBody"))
		
		p.Tag = m
		
		Dim seen As Int
		seen = msg.GetUnSeenMessage(m.Get("sFrom"))
		
		If seen > 0 Then
			lblunseenmessage.Text = seen
			lblunseenmessage.Visible = True
		End If
		
	Next
	
	sv1.Panel.Height = Top
	
End Sub

Sub Activity_Resume
	
	UpdateData
	
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub lblitem_Click
	
	Dim p As View
	p = Sender
	p = p.Parent
	p.Visible = False
	p.SetVisibleAnimated(500,True)
	
	actListMessages.MessageDetails = p.Tag
	StartActivity(actListMessages)
	
End Sub

Sub lblitem_LongClick
	
	Dim p As View
	p = Sender
	p = p.Parent
	p.Visible = False
	p.SetVisibleAnimated(500,True)
	
	actListMessages.MessageDetails = p.Tag
	StartActivity(actListMessages)
	
End Sub

Sub BreakString(Str As String) As String
	
	If Str.Length > 100 Then
		Return Str.SubString2(0,100)
	Else
		Return Str
	End If
	
End Sub

Sub btnsend_Click
	StartActivity(actContact)
End Sub

Sub btnmenu_Click
	sm.ToggleMenu
End Sub