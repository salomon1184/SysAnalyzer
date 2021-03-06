VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "mscomctl.ocx"
Begin VB.Form frmMemoryMap 
   Caption         =   "Memory Map"
   ClientHeight    =   6165
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   11655
   LinkTopic       =   "Form1"
   ScaleHeight     =   6165
   ScaleWidth      =   11655
   StartUpPosition =   3  'Windows Default
   Begin MSComctlLib.ListView lv2 
      Height          =   4125
      Left            =   1740
      TabIndex        =   2
      Top             =   480
      Visible         =   0   'False
      Width           =   8895
      _ExtentX        =   15690
      _ExtentY        =   7276
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   -1  'True
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   3
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Base"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "Size"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(3) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   2
         Text            =   "Module"
         Object.Width           =   2540
      EndProperty
   End
   Begin VB.ListBox List1 
      Height          =   1035
      Left            =   90
      TabIndex        =   1
      Top             =   5070
      Width           =   11475
   End
   Begin MSComctlLib.ListView lv 
      Height          =   4935
      Left            =   60
      TabIndex        =   0
      Top             =   60
      Width           =   11505
      _ExtentX        =   20294
      _ExtentY        =   8705
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   -1  'True
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   6
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Base"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "Size"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(3) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   2
         Text            =   "Protect"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(4) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   3
         Text            =   "Type"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(5) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   4
         Text            =   "Module"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(6) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   5
         Text            =   "Entropy"
         Object.Width           =   2540
      EndProperty
   End
   Begin VB.Menu mnuPopup 
      Caption         =   "mnuPopup"
      Visible         =   0   'False
      Begin VB.Menu mnuViewMemory 
         Caption         =   "View"
      End
      Begin VB.Menu mnuSaveMemory 
         Caption         =   "Save"
      End
      Begin VB.Menu mnuStrings 
         Caption         =   "Strings"
      End
      Begin VB.Menu mnuSearchMemory 
         Caption         =   "Search"
      End
   End
   Begin VB.Menu mnuPopup2 
      Caption         =   "mnuPopup2"
      Visible         =   0   'False
      Begin VB.Menu mnuDumpDll 
         Caption         =   "Dump Dll"
      End
      Begin VB.Menu mnuSaveDll 
         Caption         =   "Save Dll"
      End
   End
End
Attribute VB_Name = "frmMemoryMap"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim pi As New CProcessInfo
Dim active_pid As Long
Dim selli As ListItem

Public Sub ShowDlls(pid As Long) 'x64 ok.

    Dim c As Collection
    Dim cm As CModule
    Dim li As ListItem
    
    lv.Visible = False
    lv2.Visible = True
    active_pid = pid
    Me.Visible = True
    
    On Error Resume Next
    'If known.Loaded And known.Ready Then ado.OpenConnection
    
    Set c = pi.GetProcessModules(pid)
    
    For Each cm In c
        Set li = lv2.ListItems.Add(, , cm.HexBase)
        li.SubItems(1) = cm.HexSize
        li.SubItems(2) = cm.path
        
        If known.Loaded And known.Ready Then
            mm = known.isFileKnown(cm.path)
            li.ListSubItems(2).ForeColor = IIf(mm = exact_match, vbGreen, vbRed)
        End If
        
        DoEvents
    Next
    
    'If known.Loaded And known.Ready Then ado.CloseConnection
    'Me.Show
    
End Sub

Public Sub ShowMemoryMap(pid As Long) 'not x64 compatiabled...
    
    Dim c As Collection
    Dim cMem As CMemory
    Dim li As ListItem
    Dim modules As Long
    Dim execSections As Long
    Dim mm As matchModes
    Dim knownModules As Long
    
    On Error Resume Next
    'If known.Loaded And known.Ready Then ado.OpenConnection
    active_pid = pid
    
    Me.Visible = True
    List1.AddItem "Loading memory map for pid: " & pid
    
    Set c = pi.GetMemoryMap(pid)
    
    If c.count = 0 Then
        List1.AddItem "Failed to load memory map!"
        Exit Sub
    End If
    
    lv.ListItems.Clear
    For Each cMem In c
        Set li = lv.ListItems.Add(, , Hex(cMem.Base))
        li.SubItems(1) = Hex(cMem.size)
        li.SubItems(2) = cMem.MemTypeAsString()
        li.SubItems(3) = cMem.ProtectionAsString()
        li.SubItems(4) = cMem.ModuleName
        
        If known.Loaded And known.Ready Then
            If Len(cMem.ModuleName) > 0 Then
                mm = known.isFileKnown(cMem.ModuleName)
                li.ListSubItems(4).ForeColor = IIf(mm = exact_match, vbGreen, vbRed)
                knownModules = knownModules + 1
            End If
        End If
            
        If Len(cMem.ModuleName) > 0 Then modules = modules + 1
        
        If cMem.Protection = PAGE_EXECUTE_READWRITE Or _
            cMem.Protection = PAGE_EXECUTE_READ Or _
            cMem.Protection = PAGE_EXECUTE_WRITECOPY _
        Then
            If cMem.Protection = PAGE_EXECUTE_READWRITE And cMem.MemType <> MEM_IMAGE Then
                SetLiColor li, vbRed
                If VBA.Left(pi.ReadMemory(cMem.pid, cMem.Base, 2), 2) = "MZ" Then
                    List1.AddItem Hex(cMem.Base) & " is RWE but not part of an image (CONFIRMED INJECTION)"
                Else
                    List1.AddItem Hex(cMem.Base) & " is RWE but not part of an image..possible injection"
                End If
            Else
                SetLiColor li, vbBlue
                execSections = execSections + 1
                'List1.AddItem Hex(cMem.Base) & " is " & cMem.ProtectionAsString(true)
            End If
        End If
    Next
    
    List1.AddItem "Found " & modules & " modules and " & execSections & " executable sections"
    
    If known.Loaded And known.Ready Then
        List1.AddItem knownModules & " known modules found"
        'ado.CloseConnection
    End If
    
    
End Sub

Private Sub Form_Load()
    On Error Resume Next
    lv.ColumnHeaders(5).Width = lv.Width - lv.ColumnHeaders(5).Left - 350
    lv2.Move lv.Left, lv.top, lv.Width, lv.Height
    lv2.ColumnHeaders(3).Width = lv2.Width - lv2.ColumnHeaders(3).Left - 350
End Sub

Private Sub lv_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)
    LV_ColumnSort lv, ColumnHeader
End Sub

Private Sub lv_DblClick()
    mnuViewMemory_Click
End Sub

Private Sub lv_ItemClick(ByVal Item As MSComctlLib.ListItem)
    Set selli = Item
End Sub

Private Sub lv_MouseUp(Button As Integer, Shift As Integer, X As Single, y As Single)
    If Button = 2 Then PopupMenu mnuPopup
End Sub

Private Sub lv2_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)
    LV_ColumnSort lv2, ColumnHeader
End Sub

Private Sub lv2_ItemClick(ByVal Item As MSComctlLib.ListItem)
    Set selli = Item
End Sub

Private Sub lv2_MouseUp(Button As Integer, Shift As Integer, X As Single, y As Single)
    If Button = 2 Then PopupMenu mnuPopup2
End Sub

Private Sub mnuDumpDll_Click()
    If selli Is Nothing Then Exit Sub
    Dim f As String
    Dim n As String
    Dim orgPath As String
    On Error Resume Next
    
    'MsgBox dlg.SaveDialog(AllFiles)
     
    orgPath = selli.SubItems(2)
    n = fso.FileNameFromPath(orgPath) & ".dmp"
    'f = InputBox("Save file as: ", , UserDeskTopFolder & "\" & n)
    f = frmDlg.SaveDialog(AllFiles, UserDeskTopFolder, "Save Dll Dump as:", , Me, n)
    If Len(f) = 0 Then Exit Sub
    
    'If pi.DumpProcessMemory(active_pid, CLng("&h" & selli.Text), CLng("&h" & selli.SubItems(1)), f) Then
    
    If pi.DumpMemory(active_pid, selli.Text, selli.SubItems(1), f) Then   'x64 enabled version...
        MsgBox "File successfully saved"
    Else
        MsgBox "Error saving file: " & Err.Description
    End If
    
End Sub

Private Sub mnuSaveDll_Click()
    If selli Is Nothing Then Exit Sub
    Dim f As String
    Dim n As String
    Dim orgPath As String
    
    On Error Resume Next
    orgPath = selli.SubItems(2)
    
    If Not fso.FileExists(orgPath) Then
        List1.AddItem "Error: Could not find: " & orgPath
        Exit Sub
    End If
    
    n = fso.FileNameFromPath(orgPath)
    'f = InputBox("Save file as: ", , UserDeskTopFolder & "\" & n)
    'If Len(f) = 0 Then Exit Sub
    fso.Copy orgPath, UserDeskTopFolder
    
    If Not fso.FileExists(UserDeskTopFolder & "\" & n) Then
        List1.AddItem "Failed to copy file to " & UserDeskTopFolder
    Else
        List1.AddItem "File copied to " & UserDeskTopFolder
    End If
    
End Sub

Private Sub mnuSaveMemory_Click()
    If selli Is Nothing Then Exit Sub
    Dim f As String
    On Error Resume Next
    'f = InputBox("Save file as: ", , UserDeskTopFolder & "\" & selli.Text & ".mem")
    f = frmDlg.SaveDialog(AllFiles, UserDeskTopFolder, "Save Memory as:", , Me, selli.Text & ".mem")
    If Len(f) = 0 Then Exit Sub
    If pi.DumpProcessMemory(active_pid, CLng("&h" & selli.Text), CLng("&h" & selli.SubItems(1)), f) Then
        MsgBox "File successfully saved"
    Else
        MsgBox "Error saving file: " & Err.Description
    End If
End Sub

Private Sub mnuSearchMemory_Click()
    Dim li As ListItem
    Dim s As String
    Dim s2 As String
    Dim ret As String
    Dim a As Long
    Dim b As Long
    Dim m As String
    
    If lv.ListItems.count = 0 Then
        MsgBox "Nothing to search"
        Exit Sub
    End If
    
    s = InputBox("Enter string to search for:")
    If Len(s) = 0 Then Exit Sub
    
    s2 = StrConv(s, vbUnicode, LANG_US)
    'abort = False
    
    Dim Base As Long
    Dim size As Long
    
    For Each li In lv.ListItems
        'If abort = True Then Exit For
        li.Selected = True
        li.EnsureVisible
        DoEvents
        lv.Refresh
        Base = CLng("&h" & li.Text)
        size = CLng("&h" & li.SubItems(1))
        m = pi.ReadMemory(active_pid, Base, size)
        a = InStr(1, m, s, vbTextCompare)
        b = InStr(1, m, s2, vbTextCompare)
        If a > 0 Then ret = ret & "pid: " & li.Text & " base: " & li.SubItems(1) & " offset: " & Hex(Base + a) & " ASCII " & li.SubItems(5) & vbCrLf
        If b > 0 Then ret = ret & "pid: " & li.Text & " base: " & li.SubItems(1) & " offset: " & Hex(Base + b) & " UNICODE " & li.SubItems(5) & vbCrLf
    Next
    
    If Len(ret) > 0 Then
        frmReport.ShowList ret
    Else
        MsgBox "Specified string not found (ASCII or UNICODE)", vbInformation
    End If
    
End Sub

Private Sub mnuStrings_Click()
    If selli Is Nothing Then Exit Sub
    On Error Resume Next
    Dim f As String
    f = fso.GetFreeFileName(Environ("temp"), ".bin")
    If pi.DumpProcessMemory(active_pid, CLng("&h" & selli.Text), CLng("&h" & selli.SubItems(1)), f) Then
       LaunchStrings f, True
    Else
        MsgBox "Error saving file: " & Err.Description
    End If
End Sub

Private Sub mnuViewMemory_Click()
    If selli Is Nothing Then Exit Sub
    Dim s As String
    Dim Base As Long
    On Error Resume Next
    Base = CLng("&h" & selli.Text)
    s = pi.ReadMemory(active_pid, Base, CLng("&h" & selli.SubItems(1)))
    If Len(s) = 0 Then
        List1.AddItem "Failed to readmemory?"
        Exit Sub
    End If
    'frmReport.ShowList HexDump(s, , base), False, selli.Text & ".mem", False
    Dim f As New rhexed.CHexEditor
    f.Editor.AdjustBaseOffset = Base
    f.Editor.LoadString s
End Sub
