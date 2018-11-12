<!--
// Name: Stack Complete
// Committer: nagababut@wilcosource.com
// Update: code review comment added
-->
<script>
//--- RULE JSON REPRESENTATION ---
var ruleJson = {"type":"rool","updated":"2017-11-07 17:33:10","active":true,"button":"Stack Complete","name":"Stack Complete","conditions":{"logic":"and","arguments":[{"name":"doc.X(\"X_buttonAction\")","value":"Stack Complete","operation":"equals"}]},"consequence":{"doit":"YWxlcnQoIkBAQEAgU3RhY2sgQ29tcGxldGUgUnVsZSBGaXJlZCBAQEAjIik7CgovKiBDbGVhciB0aGUgdHJpZ2dlciB0aGF0IGludm9rZWQgdGhpcyBydWxlICovCnZhciBhcnJPZlBhaXJzID0gW107CmFyck9mUGFpcnMucHVzaCgiWF9idXR0b25BY3Rpb24iLCAiIik7CmFyck9mUGFpcnMucHVzaCgiWF90cmlhZ2VTdGF0dXMiLCAiQ29tcGxldGUiKTsKaWYgKDE9PT0xKSB7IC8vRVJTMTcwOTA5ICM0MDU5MiBmb3IgekRvY1NldCBzdGF0dXNlcwogICAgdmFyIGJhPWRvYy5YKCJYX2J1dHRvbkFjdGlvbiIpKyJlZCIucmVwbGFjZSgiQ29tcGxldGVlZCIsIkNvbXBsZXRlZCIpOwogICAgYmE9YmEuc3Vic3RyaW5nKDErYmEubGFzdEluZGV4T2YoIiAiKSk7CiAgICB2YXIgbm93MCA9IGdldEN1ckRhdGVBbmRUaW1lKGRvYyxmYWxzZSx0cnVlKTsKICAgIGFyck9mUGFpcnMucHVzaCgiWF9yZXZpZXdlZFN0YXR1cyIsYmEpOwogICAgYXJyT2ZQYWlycy5wdXNoKCJYX3Jldmlld3MiLFgoZG9jLCJYX3Jldmlld3MiKStiYSsiIGJ5ICIrZG9jLmtiRGF0YS5yZW1vdGVVc2VyKyIgYXQgIitub3cwKyI8YnIvPiIpOyAvL0VSUzE3MDkwOSAjNDA1OTIKfQp1cGRhdGVEQihkb2MsYXJyT2ZQYWlycyk7Cgp2YXIgc2ZTdGFja0lkID0gWChkb2MsIlhfc2ZTdGFja0lkIik7IC8vRVJTMTcwNzI3ICM0MDQ0NwovL0NSTjE3MDYyNiBBbHNvIHNhdmUgdGhlIHN0YXR1cyBpbiB0aGUgelN0YWNrIHJlY29yZC4KaWYgKHNmU3RhY2tJZD09PSIiKSBzZlN0YWNrSWQgPSBYKGRvYywiWF9hdHRhY2hlZFRvIik7CmFsZXJ0KCJAQEBAQEAgQ09NUExFVEUgU1RBQ0sgLS0gQ3VycmVudGx5IGF0dGFjaGVkIHRvIFN0YWNrX19jIHdpdGggSUQ6ICIgKyBzZlN0YWNrSWQpOwppZiAoc2ZTdGFja0lkICYmIHNmU3RhY2tJZC5sZW5ndGggPiAwKSB7CiAgaWYgKHNmU3RhY2tJZC5sYXN0SW5kZXhPZignLycpID49IDApIHsKICAgIHNmU3RhY2tJZCA9IHNmU3RhY2tJZC5zdWJzdHJpbmcoc2ZTdGFja0lkLmxhc3RJbmRleE9mKCcvJykrMSk7CiAgICBpZiAoc2ZTdGFja0lkLmluZGV4T2YoJywnKSA+PSAwKSB7IHNmU3RhY2tJZCA9IHNmU3RhY2tJZC5zdWJzdHJpbmcoMCwgc2ZTdGFja0lkLmluZGV4T2YoJywnKSk7IH0KICB9Cn0KaWYgKHNmU3RhY2tJZCAmJiBzZlN0YWNrSWQubGVuZ3RoID4gMCkgewogIGFyck9mUGFpcnMgPSBbXTsKICAgYXJyT2ZQYWlycy5wdXNoKCJaUEFQRVJfX1N0YXR1c19fYyIsICJDb21wbGV0ZSIpOwogICBhcnJPZlBhaXJzLnB1c2goIlpQQVBFUl9fU3RhZ2VfX2MiLCAiQ29tcGxldGVkIik7CiAgIC8vdXBkYXRpbmcgelN0YWNrIG93bmVyIGFzIHF1ZXVlIAogICBpZiAoekRhdGEub3duZXJJZCkgYXJyT2ZQYWlycy5wdXNoKCJPd25lcklkIix6RGF0YS5vd25lcklkKTsKICB1cGRhdGVTRlJlY29yZChkb2MsICJaUEFQRVJfX3pTdGFja19fYyIsIHNmU3RhY2tJZCwgYXJyT2ZQYWlycyk7Cn0KdmFyIHN0YWNrRmllbGRzID0gZ2V0U0ZGaWVsZHMoZG9jLCAiWlBBUEVSX196U3RhY2tfX2MiLCAiWlBBUEVSX19DYXNlX19jLFpQQVBFUl9fUGF0aWVudF9fYyIsIG51bGwsIHNmU3RhY2tJZCk7CnZhciBjYXNlSWQgPSBYKGRvYywgIlpQQVBFUl9fQ2FzZV9fYyIsIHN0YWNrRmllbGRzKTsKdmFyIHBhdGllbnRJZCA9IFgoZG9jLCAiWlBBUEVSX19QYXRpZW50X19jIiwgc3RhY2tGaWVsZHMpOwoKdmFyIGNvbXBhbnlDb2RlID0gZG9jLmRlbGl2ZXJlZFRvOwphbGVydCgiIyMjIyMgQ09NUExFVEUgU1RBQ0s6IGNvbXBhbnlDb2RlID0gIiArIGNvbXBhbnlDb2RlKTsKdmFyIG9sZEZvbGRlciA9IGNvbXBhbnlDb2RlLmluZGV4T2YoIjEzMDYiKSA+IDAgPyAiMjA1MDBUcmlhZ2UtUzFBIiA6ICIyMDUwMFRyaWFnZS1TMUIiOwoKYWxlcnQoIiMjIyMjIENPTVBMRVRFIFNUQUNLOiBtb3ZpbmcgZnJvbSBvbGRGb2xkZXI6ICIgKyBvbGRGb2xkZXIpOwptb3ZlRG9jdW1lbnQoZG9jLG9sZEZvbGRlciwiIik7CnJlbG9hZEJ5QkFURVMoZG9jLG9sZEZvbGRlcik7CnVubG9ja0RvY3VtZW50KGRvYyk7Cgp0cmFjayhkb2MsICJTdGFjayBjb21wbGV0ZWQiLCBkb2MuQkFURVMsIGRvYy5udW1QYWdlcyk7CmhpZGVEb2N1bWVudChkb2MpOwovL0NSTjE2MTAwNSBDYXNlICMzMDE3MyBDbGVhciBsYWJlbCBiYXIgd2hlbiBTdGFjayBpcyBjb21wbGV0ZWQKYWRkUG9zdEV4ZWN1dGlvblNjcmlwdChkb2MsICI7ICQoJyNyZWNvcmRMYWJlbCcpLmh0bWwoJycpOyAkKCcjREVGb3Jtc0xpc3QnKS5oaWRlKCk7ICQoJyNkYXRhRW50cnlESVYnKS5oaWRlKCk7Iik7Ci8vcmVkaXJlY3QgdG8gZWl0aGVyIGNhc2Ugb3IgcGF0aWVudCBvbmNlIFN0YWNrIGNvbXBsZXRlCmlmIChjYXNlSWQpIHsKICAgICAgICAgICAKICAgIGFkZFBvc3RFeGVjdXRpb25TY3JpcHQoZG9jLCAiO2lmKGNvbmZpcm0oJ2RvIHdhbnQgdG8gcmVkaXJlY3QgdG8gY2FzZScpKXsgbG9jYXRpb24uaHJlZj0nIiArIGRvYy5zZlNlcnZlciArICIvIiArIGNhc2VJZCArICInfSIpOwp9CmVsc2UgewogICAgCiAgICBhZGRQb3N0RXhlY3V0aW9uU2NyaXB0KGRvYywgIjtpZihjb25maXJtKCdkbyB3YW50IHRvIHJlZGlyZWN0IHRvIHBhdGllbnQnKSl7IGxvY2F0aW9uLmhyZWY9JyIgKyBkb2Muc2ZTZXJ2ZXIgKyAiLyIgKyBwYXRpZW50SWQgKyAiJ30iKTsKfQovL2FkZFBvc3RFeGVjdXRpb25TY3JpcHQoZG9jLCAiO2lzTG9ja2VkID0gfk15VW5Mb2NrZWR+O2lmIChjb25maXJtKH5DbG9zZSB3aW5kb3d+KSkgd2luZG93LmNsb3NlKCk7Iik7Ci8qIGVuZCBvZiBydWxlICovCg=="},"ordinal":9}

//--- RULE JSON REPRESENTATION - END ---

//--- RULE CONSEQUENCE CODE ---
alert("@@@@ Stack Complete Rule Fired @@@#");

/* Clear the trigger that invoked this rule */
var arrOfPairs = [];
arrOfPairs.push("X_buttonAction", "");
arrOfPairs.push("X_triageStatus", "Complete");
if (1===1) { //ERS170909 #40592 for zDocSet statuses
    var ba=doc.X("X_buttonAction")+"ed".replace("Completeed","Completed");
    ba=ba.substring(1+ba.lastIndexOf(" "));
    var now0 = getCurDateAndTime(doc,false,true);
    arrOfPairs.push("X_reviewedStatus",ba);
    arrOfPairs.push("X_reviews",X(doc,"X_reviews")+ba+" by "+doc.kbData.remoteUser+" at "+now0+"<br/>"); //ERS170909 #40592
}
updateDB(doc,arrOfPairs);

var sfStackId = X(doc,"X_sfStackId"); //ERS170727 #40447
//CRN170626 Also save the status in the zStack record.
if (sfStackId==="") sfStackId = X(doc,"X_attachedTo");
alert("@@@@@@ COMPLETE STACK -- Currently attached to Stack__c with ID: " + sfStackId);
if (sfStackId && sfStackId.length > 0) {
  if (sfStackId.lastIndexOf('/') >= 0) {
    sfStackId = sfStackId.substring(sfStackId.lastIndexOf('/')+1);
    if (sfStackId.indexOf(',') >= 0) { sfStackId = sfStackId.substring(0, sfStackId.indexOf(',')); }
  }
}
if (sfStackId && sfStackId.length > 0) {
  arrOfPairs = [];
   arrOfPairs.push("ZPAPER__Status__c", "Complete");
   arrOfPairs.push("ZPAPER__Stage__c", "Completed");
   //updating zStack owner as queue 
   if (zData.ownerId) arrOfPairs.push("OwnerId",zData.ownerId);
  updateSFRecord(doc, "ZPAPER__zStack__c", sfStackId, arrOfPairs);
}
var stackFields = getSFFields(doc, "ZPAPER__zStack__c", "ZPAPER__Case__c,ZPAPER__Patient__c", null, sfStackId);
var caseId = X(doc, "ZPAPER__Case__c", stackFields);
var patientId = X(doc, "ZPAPER__Patient__c", stackFields);

var companyCode = doc.deliveredTo;
alert("##### COMPLETE STACK: companyCode = " + companyCode);
var oldFolder = companyCode.indexOf("1306") > 0 ? "20500Triage-S1A" : "20500Triage-S1B";

alert("##### COMPLETE STACK: moving from oldFolder: " + oldFolder);
moveDocument(doc,oldFolder,"");
reloadByBATES(doc,oldFolder);
unlockDocument(doc);

track(doc, "Stack completed", doc.BATES, doc.numPages);
hideDocument(doc);
//CRN161005 Case #30173 Clear label bar when Stack is completed
addPostExecutionScript(doc, "; $('#recordLabel').html(''); $('#DEFormsList').hide(); $('#dataEntryDIV').hide();");
//redirect to either case or patient once Stack complete
if (caseId) {
           
    addPostExecutionScript(doc, ";if(confirm('do want to redirect to case')){ location.href='" + doc.sfServer + "/" + caseId + "'}");
}
else {
    
    addPostExecutionScript(doc, ";if(confirm('do want to redirect to patient')){ location.href='" + doc.sfServer + "/" + patientId + "'}");
}
//addPostExecutionScript(doc, ";isLocked = ~MyUnLocked~;if (confirm(~Close window~)) window.close();");
/* end of rule */

//--- RULE CONSEQUENCE CODE - END ---

//--- RULE VALIDATION CODE ---
CgpmdW5jdGlvbiBkb1ZhbGlkYXRpb24oKSB7CiAgICAgCiAgICAvL3ZhbGlkYXRpb24gdG8gbWFrZSBzdXJlIGFsbCBzdGFjayBwYWdlcyBnZXQgaW5kZXhlZCBvciBpZ25vcmVkIGJlZm9yZSBtYWtlIFN0YWNrIGFzIENvbXBsZXRlIAogICAgLy90b3RhbHBBZ2VzID0gaW5kZXhlZFBhZ2VzK2lnbm9yZWRQYWdlcwogICAgIHZhciBpbmRleFBhZ2VzOwogICAgIGlmKF96RGF0YVsiWF9pbmRleGVkUGFnZXMiXSl7CiAgICAgICAgIGluZGV4UGFnZXMgPSAoX3pEYXRhWyJYX2luZGV4ZWRQYWdlcyJdKTsKICAgICB9CiAgICAgdmFyIHBhZ2VDb3VudCA9IF96RGF0YVsiWF9jb3VudCJdOwogICAgIHZhciBub3RJbmRleGVkPSIiOwogICAgIHZhciBpZ25vcmVkUGFnZXMgPSBfekRhdGFbIlhfaWdub3JlZFBhZ2VzIl07CiAgICAgaWYoIGlnbm9yZWRQYWdlcyAmJiBpZ25vcmVkUGFnZXMubGVuZ3RoID4wKXsKICAgICAgICAgaW5kZXhQYWdlcyA9IGluZGV4UGFnZXMuY29uY2F0KGlnbm9yZWRQYWdlcyk7CiAgICAgfSAgICAgCiAgICAgZm9yKHZhciBpPTE7aTw9IHBhZ2VDb3VudDtpKyspewogICAgCWlmKGluZGV4UGFnZXMgJiYgIWluZGV4UGFnZXMuY29udGFpbnMoaSkpewogICAgICAgICAgICBub3RJbmRleGVkICs9IGkrIiwiOwogICAgCX1lbHNlIGlmKCFpbmRleFBhZ2VzKXsKICAgIAkgICAgbm90SW5kZXhlZCArPSBpKyIsIjsKICAgIAl9CiAgICB9CiAgIAogICAgaWYgKG5vdEluZGV4ZWQubGVuZ3RoID4gMCkgewogICAgICAgIGFsZXJ0KCJFUlJPUjogVGhlIGZvbGxvd2luZyBwYWdlcyBhcmUgbm90IGluZGV4ZWQgOiAiICsgbm90SW5kZXhlZCk7CiAgICAgICAgcmV0dXJuIGZhbHNlOyAgIC8vQ1JOMTcwNzE5IG9uZSBvciBtb3JlIGZpZWxkIGlzIG1pc3NpbmcsIGRvbid0IHNlbmQgdG8gdGhlIHJ1bGVzIGVuZ2luZQogICAgfQoKCXJldHVybiB0cnVlOwp9CgpyZXR1cm4gZG9WYWxpZGF0aW9uKCk7
//--- RULE VALIDATION CODE - END ---

</script>
