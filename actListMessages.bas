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
	Public MessageDetails As Map
End Sub

Sub Globals
	Private sv1 As ScrollView
	Private lblfromtitle As Label
	Private msg As Messages
	Private util As StringUtils
	Dim Top As Int
	Dim time As Conversion
	Dim MeColor,UserColor As ColorDrawable
	Dim msgList As List
	Private btnmenu As Button
	Private rs As RSPopupMenu
	Private txtmessage As EditText
	Private btnsend As Button
	Private img1 As ImageView
	Private img2 As ImageView
	Private pnlemotion As Panel
End Sub

Sub Activity_Create(FirstTime As Boolean)
	
	Activity.LoadLayout("frmmessagelist")
	lblfromtitle.Text = MessageDetails.Get("sFromName")
	
	rs.Initialize("rs",btnmenu)
	rs.AddMenuItem(0,0,"حذف تاریخچه")
	rs.AddMenuItem(1,1,"جستجوی")
	'rs.AddMenuItem(2,2,"حذف چت")
	
	sv1.Color = Colors.RGB(236,236,236)
	sv1.Panel.Color = Colors.RGB(236,236,236)

	UserColor.Initialize(Colors.White,25)
	MeColor.Initialize(Colors.RGB(246,246,246),25)
	
	UpdateData
	
End Sub

Sub UpdateData
	
	sv1.Panel.RemoveAllViews
	
	msg.Initialize
	msgList = msg.GetMessageForNumber(MessageDetails.Get("sFrom"))
	Top = 18dip
	
	For i = 0 To msgList.Size - 1
		
		Dim m As Map
		m = msgList.Get(i)
		
		AddNewMessage(m,True)

	Next
	
End Sub

Sub PaddingView(View As Label,Left As Int,sTop As Int,Right As Int,Bottom As Int)
	Dim refl As Reflector
	refl.Target=View
	refl.RunMethod4("setPadding", Array As Object(Left, sTop, Right, Bottom), _
    Array As String("java.lang.int", "java.lang.int", "java.lang.int","java.lang.int"))
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub AddNewMessage(m As Map,Left As Boolean)
	
	If m.ContainsKey("empty") Then Return
	If m.Get("IsMe") = "1" Then Left = False
	
	Dim lbl1 As Label
	lbl1.Initialize("lblmessage")
	lbl1.Text = m.Get("sBody")
	lbl1.TextSize = 11
	lbl1.TextColor = Colors.Black
	lbl1.Gravity = Gravity.RIGHT
	lbl1.Typeface = Typeface.LoadFromAssets("iransans.ttf")
		
	'PaddingView(lbl1,15,15,15,15)
		
	If Left Then
		sv1.Panel.AddView(lbl1,14dip,Top,200dip,0)
		lbl1.Background = UserColor
	Else
		sv1.Panel.AddView(lbl1,sv1.Width-210dip,Top,200dip,0)
		lbl1.Background = MeColor
	End If
	
	lbl1.Height = util.MeasureMultilineTextHeight(lbl1,lbl1.Text) + 9dip
		
	If lbl1.Height < 100 Then
		lbl1.Height = 38dip
		lbl1.Padding = Array As Int(15,16,15,15)
	End If
		
	Top = Top + lbl1.Height + 4dip
		
	Dim lb As Label
	lb.Initialize("")
	lb.Text = time.GetTimeAgo(m.Get("sTime"))
	lb.TextColor  = Colors.Gray
	lb.TextSize = 7
	lb.Typeface = Typeface.LoadFromAssets("iransans.ttf")
	
	If Left Then 
		lb.Gravity = Gravity.RIGHT
		sv1.Panel.AddView(lb,200dip - 80dip,Top,93dip,20dip)
	Else 
		lb.Gravity = Gravity.LEFT
		sv1.Panel.AddView(lb,lbl1.Left,Top,93dip,20dip)
	End If
		
	Top = Top + lb.Height + 12dip
	
	sv1.Panel.Height = Top
	
	CallSubDelayed(Me,"GotoBottom")
	
End Sub

Sub GotoBottom
	sv1.ScrollPosition = sv1.Panel.Height
	DoEvents
End Sub

Sub btnclose_Click
	Activity.Finish
End Sub

Sub btnmenu_Click
	rs.Show
End Sub

Sub rs_MenuItemClick (ItemId As Int) As Boolean
	
	Dim s As Messages
	s.Initialize
	
	If ItemId = 0 Then
		Top = 0
		sv1.Panel.RemoveAllViews
		s.DeleteMessageForNumber(MessageDetails.Get("sFrom"))
		
	End If
	
End Sub

Sub txtmessage_EnterPressed
	
	If txtmessage.Text.Trim.Length = 0 Then Return
	SendMessageToUser
	
End Sub

Sub btnsend_Click
	
	If txtmessage.Text.Trim.Length = 0 Then Return
	SendMessageToUser
	
End Sub

Sub SendMessageToUser
	
	AddNewMessage(CreateMap("sBody":txtmessage.Text,"sTime":DateTime.Now,"IsMe":"1"),False)
	msg.AddMessage(Library.Manager.GetString("id"),Library.Manager.GetString2("name","بی نام"),DateTime.Now,txtmessage.Text,"new_message",1,MessageDetails.Get("sFrom"))
	
	Dim ime As IME
	ime.Initialize("")
	ime.HideKeyboard
	
	SendMessage(MessageDetails.Get("sFrom"),Library.Manager.GetString("id"),Library.Manager.GetString2("name","بی نام"),txtmessage.Text)
	
	Dim media As MediaPlayer
	media.Initialize2("")
	media.Load(File.DirAssets,"send.mp3")
	media.Play
	
	txtmessage.Text = ""
	
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Activity.Finish
	End If
	
End Sub

Private Sub SendMessage(ID As String,From As String,FromTitle As String,Body As String)
	
	Dim aes As AES
	Dim sign As CheckSignature
	aes.Initilize(sign.KeyHash)
	
	Dim Job As HttpJob
	Job.Initialize("fcm", Me)
	
	Dim m As Map = CreateMap("to": $"/topics/my${ID}"$,"content_available":True)
	Dim data As Map = CreateMap("froms": From, "body": aes.Encrypt(Body) , "from_title" : FromTitle,"type" : "new_message")
	
	m.Put("data", data)
	
	Dim jg As JSONGenerator
	jg.Initialize(m)
	Job.PostString("https://fcm.googleapis.com/fcm/send", jg.ToString)
	Job.GetRequest.SetContentType("application/json;charset=UTF-8")
	Job.GetRequest.SetHeader("Authorization", "key=" & "AAAAXL-lDxA:APA91bGPc-BEQac0CmfH0fgq9IgymeJLep1mI8ksWx-jbVAOweXMQOrsgvUGRQ5IZw4-BA7DZXb_Q-8YX9UJPc5B4VxgExOOOnU_TuIX2IUVIaHtnRTtzxzL8jwILVPnMPEjL8kqAGyufaGNQ2KKMdfJRH-iKwUMZw")
	
End Sub

Sub JobDone(Job As HttpJob)
	
	If Job.Success Then
		Log("Ok sent")
		Log(Job.GetString)
	Else
		Log("Error send message")
	End If
	
End Sub

Sub lblmessage_Click
	
	Dim lb As Label
	lb = Sender
	
	Dim vanim As AnimationComposer
	vanim.Initialize("Anim","Shake")
	vanim.delay(0).duration(700).playOn(lb)
	
End Sub

Sub txtmessage_TextChanged (Old As String, New As String)
	
	If txtmessage.Text.Length = 0 Then
		btnsend.TextColor = Colors.RGB(104,104,104)
	Else
		btnsend.TextColor = Colors.RGB(1,175,210)
	End If
	
End Sub

Sub img1_Click
	
End Sub

Sub img2_Click
	
End Sub

Sub btnemotion_Click
	pnlemotion.SetLayoutAnimated(400,0,100%y-pnlemotion.Height,pnlemotion.Width,pnlemotion.Height)
End Sub

Sub btnattachment_Click
	
End Sub