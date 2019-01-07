B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.01
@EndOfDesignText@
'Class module
Sub Class_Globals
	Private lsheader As ListView
	Private sm As SlidingMenu
	Private imgLogo As ImageView
	Private action As String
	Private tmr As Timer
	Private pnlheader As Panel
End Sub

Public Sub Initialize(titlebarHeight As Int,Module As Object)
	
	Dim offset As Int = 90dip
	
	sm.Initialize("Menu")
	
	sm.BehindOffset = offset
	sm.Mode = sm.RIGHT
	
	lsheader.Initialize("lsheader")
	
	imgLogo.Initialize("")

	sm.Menu.Color = Colors.White
	
	sm.Menu.AddView(imgLogo,0,0, 100%x-offset, 235dip)
	sm.Menu.AddView(lsheader,0,imgLogo.Height, 100%x-offset, 100%y - imgLogo.Height)
	
	imgLogo.Bitmap = LoadBitmap(File.DirAssets,"logo.jpg")
	
	ChangeListviewStyle(lsheader)
'	lsheader.TwoLinesLayout.SecondLabel.TextColor = Colors.RGB(137, 137, 137)
	SetDivider(lsheader,Colors.RGB(242, 242, 242),1)

	AddHeader
	
End Sub

Public Sub ToggleMenu
	
	If sm.Visible = True Then
		sm.HideMenus
	Else
		sm.ShowMenu
	End If
	
End Sub

Public Sub AddHeader
	
	lsheader.Clear

	lsheader.AddTwoLines2("پروفایل من","","account")
	lsheader.AddTwoLines2("مخاطبین من","","contacts")
	
	lsheader.AddSingleLine("")
	lsheader.AddTwoLines2("ارتباط با ما","","contact")
	lsheader.AddTwoLines2("درباره ما","","about")
	
	lsheader.AddSingleLine("")
	lsheader.AddTwoLines2("تنظیمات","","setting")
	lsheader.AddTwoLines2("اشتراک ایرانگرام","","shareme")
	lsheader.AddTwoLines2("دعوت دوستان","","shareall")
	
End Sub

Private Sub lsheader_ItemClick (Position As Int, Value1 As Object)
	
	action = Value1
	sm.HideMenus
	tmr.Initialize("tmr",500)
	tmr.Enabled = True
	
End Sub

Sub tmr_Tick
	
	tmr.Enabled = False
	
	If action = "account" Then
		StartActivity(actProfile)
	End If
	
End Sub

Public Sub GetVisible As Boolean
	Return sm.Visible
End Sub

Sub GetDevicePhysicalSize As Float
	Dim lv As LayoutValues
	lv = GetDeviceLayoutValues
	Return Sqrt(Power(lv.Height / lv.Scale / 160, 2) + Power(lv.Width / lv.Scale / 160, 2))
End Sub

Sub ChangeListviewStyle(lv1 As ListView)
	
	If GetDevicePhysicalSize > 5 Then
		lv1.TwoLinesLayout.ItemHeight = 160   'ertefa har menu
	Else
		lv1.TwoLinesLayout.ItemHeight = 50dip
		lv1.SingleLineLayout.ItemHeight = 40dip
	End If
	
	If GetDevicePhysicalSize < 6 Then
		lv1.TwoLinesLayout.Label.TextSize = 12
		lv1.SingleLineLayout.Label.TextSize = 12
		lv1.TwoLinesLayout.SecondLabel.TextSize = 19
	Else
		lv1.TwoLinesLayout.Label.TextSize = 16
		lv1.SingleLineLayout.Label.TextSize = 19
		lv1.TwoLinesLayout.SecondLabel.TextSize = 22
	End If
	
	lv1.TwoLinesLayout.Label.Height = lv1.TwoLinesLayout.ItemHeight
	lv1.TwoLinesLayout.SecondLabel.Height = lv1.TwoLinesLayout.Label.Height
	
	lv1.TwoLinesLayout.Label.TextColor	= Colors.RGB(137, 137, 137)
	lv1.SingleLineLayout.Label.TextColor = Colors.White
	lv1.TwoLinesLayout.SecondLabel.TextColor	= Colors.RGB(1,175,210)
	
	Dim c1 As ColorDrawable
	c1.Initialize(Colors.RGB(242, 242, 242),0)
	lv1.SingleLineLayout.Background = c1
	
	lv1.TwoLinesLayout.Label.Typeface		= Typeface.LoadFromAssets("iransans.ttf")
	lv1.SingleLineLayout.Label.Typeface		= Typeface.LoadFromAssets("iransans.ttf")
	lv1.TwoLinesLayout.SecondLabel.Typeface	= Typeface.LoadFromAssets("icomoon.ttf")
	
	lv1.TwoLinesLayout.SecondLabel.Top		= lv1.TwoLinesLayout.Label.Top
	lv1.TwoLinesLayout.Label.Top			= lv1.TwoLinesLayout.Label.Top+2dip
	lv1.SingleLineLayout.Label.Top			= lv1.TwoLinesLayout.Label.Top
	
	lv1.TwoLinesLayout.SecondLabel.Width	= lv1.Width-22dip
	lv1.TwoLinesLayout.Label.Width			= lv1.Width-50dip
	lv1.SingleLineLayout.Label.Width		= lv1.TwoLinesLayout.SecondLabel.Width
	
	lv1.TwoLinesLayout.Label.Gravity = Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lv1.TwoLinesLayout.SecondLabel.Gravity = Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	lv1.SingleLineLayout.Label.Gravity = Bit.Or(Gravity.RIGHT,Gravity.CENTER_VERTICAL)
	
End Sub

Sub SetDivider(lv As ListView, Color As Int, Height As Int)
	Dim R As Reflector
	R.Target = lv
	Dim CD As ColorDrawable
	CD.Initialize(Color, 0)
	R.RunMethod4("setDivider", Array As Object(CD), Array As String("android.graphics.drawable.Drawable"))
	R.RunMethod2("setDividerHeight", Height, "java.lang.int")
End Sub