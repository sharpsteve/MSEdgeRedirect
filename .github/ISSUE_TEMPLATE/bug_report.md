---
name: Bug report
about: Create a report to help us improve
title: ''
labels: 'bug'
assignees: ''

---

**Check List**
- [ ] The App appears in the system tray
- [ ] Running `microsoft-edge:https://google.com` redirects successfully

**Describe the bug**\
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**⚠️ File Upload ⚠️**

1. Leave edge open
2. Open Powershell
3. Run `gwmi Win32_Process | where { $_.name -like "msedge*.exe"} | Select-Object CommandLine | Format-Table -Wrap -AutoSize | Out-File $env:LOCALAPPDATA\MSEdgeRedirect\logs\edge.txt`
4. Open %localappdata%\MSEdgeRedirect\logs
5. Attach the log files

**Desktop (please complete the following information):**
 - Windows Version: [e.g. 11]
 - Windows Build: [e.g. 22494]

**Additional context**\
Add any other context about the problem here.
