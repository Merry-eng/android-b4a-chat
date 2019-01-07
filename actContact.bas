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
	Private pnlover As Panel
	Dim valid_contact As Map
	Private ulv As UltimateListView
	Dim ls,result As List
	Dim IsInternalContactFetch As Boolean
End Sub

Sub Activity_Create(FirstTime As Boolean)
	
	Activity.LoadLayout("frmcontacts")
	
	ulv.Color = Colors.Transparent
	ulv.FastScroller(False)
	
	Dim cd,line As ColorDrawable
	cd.Initialize(Colors.Transparent,0)
	line.Initialize(Colors.RGB(248,248,248),0)
	ulv.PressedDrawable = cd
	ulv.DividerDrawable = line
	ulv.DividerHeight = 1
 
	UpdateData
	
End Sub

Sub UpdateData
	
	Dim c1 As Contacts2
	ls = c1.GetAll(True,False)

	If ls.Size = 0 Then
		Dim co As ContactsUtils
		co.Initialize
		ls = co.FindAllContacts(True)
	
	Else
		IsInternalContactFetch = True
	End If
	
	result = ls
	
	If File.Exists(File.DirInternal,"valid_contact") = False Then
		valid_contact.Initialize
	Else
		valid_contact = File.ReadMap(File.DirInternal,"valid_contact")
	End If
	
	ulv.ClearContent
	
	ulv.AddLayout("contact","Items_LayoutCreator", "Items_ContentFiller",75dip,True)
	ulv.BulkAddItems(ls.Size,"contact", 1)
	
End Sub

Sub Items_LayoutCreator(LayoutName As String, LayoutPanel As Panel)
	LayoutPanel.LoadLayout("frmtemplate_contacts")
End Sub

Sub Items_ContentFiller(ItemID As Long, LayoutName As String, LayoutPanel As Panel, Position As Int)
	
	Private lbltitle As Label
	Private imgicon As ImageView
	Private name As String
	
	lbltitle = LayoutPanel.GetView(0)
	imgicon = LayoutPanel.GetView(1)
	
	If IsInternalContactFetch Then
		Dim cu3 As Contact
		cu3 = result.Get(Position)
		name = cu3.DisplayName
		
		If ExistContactInSystem2(cu3.GetPhones) = False Then imgicon.Visible = False
		pnlover.Tag = cu3
		
	Else
		Dim cu As cuContact
		cu = result.Get(Position)
		name = cu.DisplayName
	
		Private co As ContactsUtils
		co.Initialize
		If ExistContactInSystem(co.GetPhones(cu.Id)) = False Then imgicon.Visible = False
		pnlover.Tag = cu
		
	End If
	
	
	lbltitle.Text = name
	
	
End Sub

Sub ExistContactInSystem(Phones As List) As Boolean
	
	For i = 0 To Phones.Size - 1
		Dim ph As cuPhone
		ph = Phones.Get(i)
		
		Dim temp As String
		temp = ph.Number.Replace("+98","0").Replace(" ","")
		
		If valid_contact.ContainsKey(temp) = True Then Return	True
	Next
	
	Return False
	
End Sub

Sub ExistContactInSystem2(Phones As Map) As Boolean
	
	For i = 0 To Phones.Size - 1
		
		Dim temp As String
		temp = Phones.GetKeyAt(i)
		temp = temp.Replace("+98","0").Replace(" ","")
		
		If valid_contact.ContainsKey(temp) = True Then Return	True
	Next
	
	Return False
	
End Sub

Sub Activity_Resume
	CheckUserContacts
End Sub

Sub CheckUserContacts
	
	Dim co As ContactsUtils
	Dim js As JSONGenerator
	Dim ls,lsPhones As List
	
	co.Initialize
	ls = co.FindAllContacts(True)
	lsPhones.Initialize
	
	For i = 0 To ls.Size - 1
		
		Dim cu As cuContact
		cu = ls.Get(i)

		Dim p1 As List
		p1 = co.GetPhones(cu.Id)
		For k = 0 To p1.Size - 1
			Dim ph As cuPhone
			ph = p1.Get(k)
			Dim temp As String
			temp = ph.Number.Replace("+98","0").Replace(" ","")
			lsPhones.Add(temp)
		Next
		
	Next
	
	js.Initialize2(lsPhones)

	Dim hu As HttpJob
	hu.Initialize("save",Me)
	hu.PostString("https://yourdomain/test/check_contacts","phones=" & js.ToString)
	
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	ulv.SaveState("list_contact")
End Sub

Sub btnclose_Click
	Activity.Finish
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean 'Return True to consume the event
	
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Activity.Finish
	End If
	
End Sub

Sub pnlover_Click
	
	Dim p As Panel
	p = Sender
	p.Visible = False
	p.SetVisibleAnimated(400,True)
	
	Dim phones As List
	phones.Initialize
	
	If p.Tag Is cuContact Then
		Dim cu As cuContact
		Dim co As ContactsUtils
		co.Initialize
		
		cu = p.Tag

		phones = co.GetPhones(cu.Id)
	
	Else
		
		Dim c As Contact
		c = p.Tag
		
		Dim phones2 As Map
		phones2 = c.GetPhones
		
		For i = 0 To phones2.Size - 1
		
			Dim temp As String
			temp = phones2.GetKeyAt(i)
			temp = temp.Replace("+98","0").Replace(" ","")
			phones.Add(temp)
		Next
		
	End If
	
	If phones.Size = 0 Then
		ToastMessageShow("شماره ای برای این مخاطب وجود ندارد",False)
		Return
	End If
	
	Dim id1 As id
	
	If phones.Size > 1 Then
		Dim res As Int
		res = id1.InputList1(phones,"کدام شماره؟")
	
		If res < 0 Then Return
	Else
		res = 0	
	End If
	
	If p.Tag Is cuContact Then
		Dim cu1 As cuPhone
		cu1 = phones.Get(res)
		actListMessages.MessageDetails = CreateMap("sFromName":cu.DisplayName,"sFrom":cu1.Number.Replace(" ","").Replace("+98","0"))
	
	Else
		Dim k As String
		k = phones.Get(0)
		
		Dim m As Contact
		m = p.Tag
		actListMessages.MessageDetails = CreateMap("sFromName":m.DisplayName,"sFrom":k.Replace(" ","").Replace("+98","0"))
	End If
	
	Activity.Finish
	StartActivity(actListMessages)
	
End Sub

Sub JobDone(Job As HttpJob)
	
	ProgressDialogHide
	Log(Job.GetString)
	
	If Job.Success Then
		
		Dim js As JSONParser
		js.Initialize(Job.GetString)
		Try
			Dim rs As Map
			Dim res As List
			res = js.NextArray
			rs.Initialize
			
			For i = 0 To res.Size - 1
				rs.Put(res.Get(i),"1")
			Next
			
			File.WriteMap(File.DirInternal,"valid_contact",rs)
			
			UpdateData
		
		Catch
			Log(Job.GetString)
		End Try
	
	Else
		Log(Job.GetString)
	End If
	
End Sub