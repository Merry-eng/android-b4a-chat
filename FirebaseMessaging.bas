B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=7.01
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	
#End Region

Sub Process_Globals
   Private fm As FirebaseMessaging
End Sub

Sub Service_Create
   fm.Initialize("fm")
End Sub

Public Sub SubscribeToTopics(Number As String)
   
   fm.SubscribeToTopic("my" & Number)
   
   Dim hu As HttpJob
   hu.Initialize("save",Me)
   hu.PostString("https://yourdomain/test","phone=" & Number)
   
End Sub

Sub JobDone(Job As HttpJob)
	
	If Job.Success Then
		Log(Job.GetString)
	End If
	
End Sub

Sub Service_Start (StartingIntent As Intent)
   If fm.HandleIntent(StartingIntent) Then Return
End Sub

Sub fm_MessageArrived (Message As RemoteMessage)
	
	Dim data As Map
	data = Message.GetData
	
	Dim aes As AES
	Dim sign As CheckSignature
	aes.Initilize(sign.KeyHash)
	data.Put("body",aes.Decrypt(data.Get("body")))
	
	Dim sq As Messages
	sq.Initialize
	sq.AddMessage(data.Get("froms"),data.Get("from_title"),Message.SentTime,data.Get("body"),data.Get("type"),0,"")
	
	If data.Get("type") = "new_message" Then
		
		Dim m As MediaPlayer
		m.Initialize2("")
		m.Load(File.DirAssets,"notify.mp3")
		m.Play
		
		If IsPaused(actListMessages) = False Then
			If actListMessages.MessageDetails.Get("sFrom") = data.Get("froms") Then
				CallSubDelayed3(actListMessages,"AddNewMessage",CreateMap("IsMe" : "0","sBody":data.Get("body"),"sTime":Message.SentTime),True)
				Return	
			End If
		End If
		
		If IsPaused(actMain) = False Then
			CallSubDelayed(actMain,"UpdateData")
		
		Else
			
			Dim notify As Notification
			notify.Initialize
			notify.Icon = "icon"
			notify.SetInfo("پیام از : " & data.Get("from_title"),data.Get("body"),actMain)
			notify.Sound = True
			notify.Vibrate = True
			notify.Notify(1)
			
		End If
	
	Else if  data.Get("type") = "new_photo" Then
		
		
	End If
	
End Sub

Sub fm_TokenRefresh (Token As String)

End Sub

Sub Service_Destroy

End Sub