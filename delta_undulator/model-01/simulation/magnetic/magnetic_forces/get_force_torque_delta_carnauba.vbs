' Simcenter MAGNET 64-bit Version 2019.1.0.33 (2019/11/22 0:42 R2019-2)
' Computer: LNLS362, User: luana.vilela
' Time: 18/07/2020 10:52:50
Call SetLocale("en-us")

pid = 1
Call GetForceTorque(pid)

Function GetForceTorque(pid)

  Set objFSO = CreateObject("Scripting.FileSystemObject")
  Set objDoc = objFSO.GetFile(getDocument().getFilePath())
  documentPath = objFSO.GetParentFolderName(objDoc)
  documentName = objFSO.GetBaseName(objDoc)
  baseName = Split(documentName, ".mn")(0)

  'Center of mass
  Call getDocument().getSolution().getParameter("", "dP", dP)
  Call getDocument().getSolution().getParameter("", "dCP", dCP)
  Call getDocument().getSolution().getParameter("", "dGV", dGV)
  Call getDocument().getSolution().getParameter("", "dGH", dGH)

  z0 = -591.13
  Dim zs
  ReDim zs(216)

  zs(0) = z0
  zs(1) = zs(0) + 4.99
  zs(2) = zs(1) + 3.54
  zs(3) = zs(2) + 5.43
  zs(4) = zs(3) + 5.17
  For i = 5 To 212
    zs(i) = zs(4) + (i-4)*5.5
  Next
  zs(213) = zs(212) + 5.17
  zs(214) = zs(213) + 5.43
  zs(215) = zs(214) + 3.54
  zs(216) = zs(215) + 4.99

  nb = Ubound(zs)

  xcsd = -17.452
  ycsd = 0
  Dim zscsd
  ReDim zscsd(nb)
  For i = 0 To nb
    zscsd(i) = zs(i) + dGV
  Next

  xcse = 0
  ycse = 17.452
  Dim zscse
  ReDim zscse(nb)
  For i = 0 To nb
    zscse(i) = zs(i) + dGV + dGH + dP + dCP
  Next

  xcie = 17.452
  ycie = 0
  Dim zscie
  ReDim zscie(nb)
  For i = 0 To nb
    zscie(i) = zs(i) + dGH
  Next

  xcid = 0
  ycid = -17.452
  Dim zscid
  ReDim zscid(nb)
  For i = 0 To nb
    zscid(i) = zs(i) + dP - dCP
  Next

  'Cassette CSD
  cassette = "CSD"
  iid = 1
  fid = 217
  icomp = "CSD1"
  fcomp = "CSD217"
  cx = xcsd
  cy = ycsd
  czs = zscsd

  fullFilename = objFSO.BuildPath(documentPath, baseName & "_PID" & Cstr(pid) & "_Cassette" & cassette & ".txt")
  Call GetForceTorqueCassette(pid, cassette, fullFilename, iid, fid, icomp, fcomp, cx, cy, czs)

  'Cassette CSE
  cassette = "CSE"
  iid = 218
  fid = 434
  icomp = "CSE1"
  fcomp = "CSE217"
  cx = xcse
  cy = ycse
  czs = zscse

  fullFilename = objFSO.BuildPath(documentPath, baseName & "_PID" & Cstr(pid) & "_Cassette" & cassette & ".txt")
  Call GetForceTorqueCassette(pid, cassette, fullFilename, iid, fid, icomp, fcomp, cx, cy, czs)

  'Cassette CIE
  cassette = "CIE"
  iid = 435
  fid = 651
  icomp = "CIE1"
  fcomp = "CIE217"
  cx = xcie
  cy = ycie
  czs = zscie

  fullFilename = objFSO.BuildPath(documentPath, baseName & "_PID" & Cstr(pid) & "_Cassette" & cassette & ".txt")
  Call GetForceTorqueCassette(pid, cassette, fullFilename, iid, fid, icomp, fcomp, cx, cy, czs)

  'Cassette CID
  cassette = "CID"
  iid = 652
  fid = 868
  icomp = "CID1"
  fcomp = "CID217"
  cx = xcid
  cy = ycid
  czs = zscid

  fullFilename = objFSO.BuildPath(documentPath, baseName & "_PID" & Cstr(pid) & "_Cassette" & cassette & ".txt")
  Call GetForceTorqueCassette(pid, cassette, fullFilename, iid, fid, icomp, fcomp, cx, cy, czs)

End Function


Function GetForceTorqueCassette(pid, cassette, fullFilename, iid, fid, icomp, fcomp, cx, cy, czs)

  Call getDocument().getSolution().getPathsInBody(pid, iid, paths)
  If (InStr(paths(0), icomp) = 0) Then
    MsgBox("Inconsistent initial body ID for cassette " & cassette)
    Exit Function
  End If

  Call getDocument().getSolution().getPathsInBody(pid, fid, paths)
  If (InStr(paths(0), fcomp) = 0) Then
    MsgBox("Inconsistent final body ID for cassette " & cassette)
    Exit Function
  End If

  Set objFSO = CreateObject("Scripting.FileSystemObject")
  Set objFile = objFSO.CreateTextFile(fullFilename, True)

  'objFile.Write "BodyID" & vbTab
  objFile.Write "Força X [N]" & vbTab & "Força Y [N]" & vbTab & "Força Z [N]" & vbTab
  objFile.Write "Torque X [N.m]" & vbTab & "Torque Y [N.m]" & vbTab & "Torque Z [N.m]" & vbCrlf
  'objFile.Write "Cx[mm]" & vbTab & "Cy[mm]" & vbTab & "Cz[mm]" & vbCrlf

  count = 0
  For bodyid = iid To fid
    cz = czs(count)
    Call getDocument().getSolution().getForceOnBody(pid, bodyid, fx, fy, fz)
    Call getDocument().getSolution().getTorqueOnBody(pid, bodyid, Array(cx, cy, cz), tx, ty, tz)

    'objFile.Write Cstr(bodyid) & vbTab
    objFile.Write Cstr(fx) & vbTab & Cstr(fy) & vbTab & Cstr(fz) & vbTab
    objFile.Write Cstr(tx) & vbTab & Cstr(ty) & vbTab & Cstr(tz) & vbCrlf
    'objFile.Write Cstr(cx) & vbTab & Cstr(cy) & vbTab & Cstr(cz) & vbCrlf

    count = count + 1
  Next

  objFile.Close

End Function
