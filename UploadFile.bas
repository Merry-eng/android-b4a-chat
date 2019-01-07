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
	Public sPath,sFile,sTypeFile As String
End Sub

Sub Service_Create

End Sub

Sub Upload
	
	Dim su As StringUtils
	Dim ou As OutputStream
	Dim ht As HttpJob
	
	ou.InitializeToBytesArray(0)
	
	File.Copy2(File.OpenInput(sPath,sFile),ou)
	ou.Close
	
	Dim sType,ext As String
	ext = getFileExtension(sFile)
	sType = getFileType(ext)
	
	ht.Initialize("upload",Me)
	ht.PostString("",su.EncodeBase64(ou.ToBytesArray))
	ht.GetRequest.SetContentType(sType)
	ht.GetRequest.SetHeader("type_file",sTypeFile)
	
End Sub

Sub JobDone(Job As HttpJob)

	If Job.Success Then
		
		If Job.JobName = "upload" Then
			
		End If
		
	Else
		ToastMessageShow("متاسفانه فایل مورد نظر دانلود نشد.دوباره تلاش کنید",False)
	End If
	
End Sub

Sub getFileType(strExtension As String) As String
	Select Case strExtension.ToLowerCase
		Case "txt": Return "text/plain"
		Case "rtf": Return "text/rtf"
		Case "csv": Return "text/csv"
		Case "txt": Return "text/plain"
		Case "png", "jpg", "jpeg", "bmp", "gif", "tif", "tiff": Return "image/*"
		Case "xml", "fb2": Return "text/*"
		Case "pdf": Return "application/pdf"
		Case "mp4", "mpg", "avi", "mov", "mkv": Return "video/*"
		Case "mp3", "m4a": Return "audio/*"
		Case "zip": Return "application/zip"
		Case Else: Return "text/*"
	End Select
End Sub

Sub getFileExtension(sFilename As String) As String
	Dim s2 As Int
	s2 = sFilename.LastIndexOf(".")
	Dim p As String
	p = sFilename.SubString2(s2+1,sFilename.Length)
	Return p
End Sub

Sub Service_Start (StartingIntent As Intent)

End Sub

Sub Service_Destroy

End Sub
