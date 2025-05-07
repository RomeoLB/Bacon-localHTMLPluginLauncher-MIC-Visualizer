'06/05/25 launch HTML App instance via plugin - RLB
'app package name - bundle.zip
'Working and tested on XD1035 (BOS 9.0.189) with USB microphone iGOKU

'plugin name - localHTMLAppLauncher

Function localHTMLAppLauncher_Initialize(msgPort As Object, userVariables As Object, bsp as Object)

    print "localHTMLAppLauncher_Initialize - entry"
    print "type of msgPort is ";type(msgPort)
    print "type of userVariables is ";type(userVariables)

    localHTMLAppLauncher = newlocalHTMLAppLauncher(msgPort, userVariables, bsp)

    return localHTMLAppLauncher

End Function



Function newlocalHTMLAppLauncher(msgPort As Object, userVariables As Object, bsp as Object)
	
	' Create the object to return and set it up
	s = {}
	s.version = "1.0.8"
	s.msgPort = msgPort
	s.userVariables = userVariables
	s.bsp = bsp
	s.ProcessEvent = localHTMLAppLauncher_ProcessEvent
	s.HandlePluginTimerEvent = HandlePluginTimerEvent
	s.HandleSentPluginMsg = HandleSentPluginMsg
	s.PluginSendMessage = PluginSendMessage
	s.PluginSendZonemessage = PluginSendZonemessage
	s.PluginSystemLog = CreateObject("roSystemLog")
	s.sTime = createObject("roSystemTime")
	s.objectName = "localHTMLAppLauncher_object_plugin"
	s.StartIndexedSequenceTimer = StartIndexedSequenceTimer
	s.currentDrive = GetDefaultDrive()
	print ""
	print "currentDrive: "; s.currentDrive
	print ""
	s.appURL = "file:///nodeApp/mic.html" 
  	s.nodeUnpack = nodeUnpack
  	s.PluginInitHTMLWidgetStatic = PluginInitHTMLWidgetStatic
	s.FirstSerialmsg = true
	s.FunctionSequenceOrderAr = [["nodeUnpack",2000],
								["PluginInitHTMLWidgetStatic",5000]]								
  's.FunctionSequenceOrderAr = [["InitNodeJS",2000]]
	s.FunctionListIndex = 0
	s.StartIndexedSequenceTimer(s.FunctionSequenceOrderAr[s.FunctionListIndex][0], s.FunctionSequenceOrderAr[s.FunctionListIndex][1])

	print "newlocalHTMLAppLauncher Plugin - V" + s.version

	s.PluginSystemLog.sendline("newlocalHTMLAppLauncher Plugin - V" + s.version) 
	return s
End Function



Function localHTMLAppLauncher_ProcessEvent(event As Object) as boolean

	retval = false
	' print ""
    ' print "localHTMLAppLauncher_ProcessEvent - entry"
    ' print "type of m is ";type(m)
    ' print "localHTMLAppLauncher_ProcessEvent - type of event is ";type(event)
	' print ""

	if type(event) = "roAssociativeArray" then
		if type(event["EventType"]) = "roString"

			' print ""
			' print " @@@ Event Type "; event["EventType"]
			' print ""

			'USER_VARIABLES_UPDATED
			if (event["EventType"] = "USER_VARIABLES_UPDATED") then
				if m.bsp.sign.zoneshsm[0].loadinghtmlwidget <> invalid then

					' if m.bsp.currentuservariables.sensorvar1 <> invalid AND m.bsp.currentuservariables.sensorvar2 <> invalid AND m.bsp.currentuservariables.sensorvar3 <> invalid then
					' 	m.bsp.sign.zoneshsm[0].loadinghtmlwidget.PostJSMessage({sensorvarlist: variableList})
					'end if	
				end if	
			end if	

			if event["EventType"] = "USER_VARIABLE_CHANGE" then

				' print ""
				' print " @@@ event - USER_VARIABLE_CHANGE event.UserVariable @@@ ";
				' print event.UserVariable.name$ 
				' print ""
			end if

			if (event["EventType"] = "SEND_ZONE_MESSAGE") then
				payload$ = event["EventParameter"]
			end if

			if (event["EventType"] = "SEND_PLUGIN_MESSAGE") then
				if event["PluginName"] = "localHTMLAppLauncher" then
					pluginMessage$ = event["PluginMessage"]
					'sent Plugin messages
					print "SEND_PLUGIN/EVENT_MESSAGE: ";pluginMessage$
					m.PluginSystemLog.sendline(" @@@ SEND_PLUGIN/EVENT_MESSAGE:  " + pluginMessage$)
					retval = HandleSentPluginMsg(pluginMessage$, m)
				end if
			else if (event["EventType"] = "EVENT_PLUGIN_MESSAGE") then
				if event["PluginName"] = "localHTMLAppLauncher" then
					pluginMessage$ = event["PluginMessage"]
					'acting on Transition Events defined within BA
					print "EVENT_PLUGIN_MESSAGE: ";pluginMessage$
					m.PluginSystemLog.sendline(" @@@ EVENT_PLUGIN_MESSAGE:  " + pluginMessage$)
				end if
			end if
		end if
	else if type(event) = "roHtmlWidgetEvent" then
	
		eventData = event.GetData()
		
		if type(eventData) = "roAssociativeArray" and type(eventData.reason) = "roString" then
		
            Print "!!!!!reason in Plugin!!!!! = " + eventData.reason
			
			if eventData.reason = "message" then

			else if eventData.reason = "load-finished" then	

			end if			
		end if	
	else if type(event) = "roTCPConnectEvent" then
		'retval = HandlePluginTCPConnectEvent(event, m)
	else if type(event) = "roStreamLineEvent" then
		'retval = HandleStreamEventPlugin(event, m)	
		'retval = HandlePluginTCPStreamLineEvent(event, m)
	else if type(event) = "roStreamEndEvent" then
		'retval = HandlePluginStreamEndEvent(event, m)	
	else if type(event) = "roTimerEvent" then
		retval = HandlePluginTimerEvent(event, m)
	else if type(event) = "roDatagramEvent" then
		'retval = HandlePluginUDPEvent(event, m)
	else if type(event) = "roNodeJsEvent" then
		print " @@@ roNodeJsEvent @@@ "
		print event.GetData()			
	end if

	return retval
End Function



Function StartIndexedSequenceTimer(FunctionName as String, TimeoutVal as integer)

    userdata = {}
    userdata.FunctionName = FunctionName
    userdata.TimeoutVal = TimeoutVal

    newTimeout = m.sTime.GetLocalDateTime()
    newTimeout.AddMilliseconds(TimeoutVal)
    m.IndexedSequenceTimer = CreateObject("roTimer")
    m.IndexedSequenceTimer.SetPort(m.msgPort)	
    m.IndexedSequenceTimer.SetDateTime(newTimeout)
    m.IndexedSequenceTimer.SetUserData(userdata)	
    ok = m.IndexedSequenceTimer.Start()

    'print "Before: "; m.sTime.GetLocalDateTime()
End Function



Function HandlePluginTimerEvent(origMsg as Object, m as Object) as boolean

		timerIdentity = origMsg.GetSourceIdentity()
		
		if type(m.IndexedSequenceTimer) = "roTimer" then
			
			if m.IndexedSequenceTimer.GetIdentity() = origMsg.GetSourceIdentity() then

				'print "After: "; m.sTime.GetLocalDateTime()

				userData = origMsg.GetUserData()
				'print "FunctionName: "; userData.FunctionName
				'print "TimeoutVal: ";  userData.TimeoutVal

				FunctionName = userData.FunctionName

				if FunctionName = "PluginInitHTMLWidgetStatic" then
					m.PluginInitHTMLWidgetStatic()
				else if FunctionName = "nodeUnpack" then
					m.nodeUnpack()		  
				end if   

				if m.FunctionListIndex < m.FunctionSequenceOrderAr.count() - 1 then
					m.FunctionListIndex = m.FunctionListIndex + 1
					m.StartIndexedSequenceTimer(m.FunctionSequenceOrderAr[m.FunctionListIndex][0], m.FunctionSequenceOrderAr[m.FunctionListIndex][1])
				end if 
				
				return true
			end if
		end if	
End Function



Function PluginSendMessage(Pmessage$ As String)

	pluginMessageCmd = CreateObject("roAssociativeArray")
	'pluginMessageCmd["EventType"] = "EVENT_PLUGIN_MESSAGE"
	pluginMessageCmd["EventType"] = "SEND_PLUGIN_MESSAGE"
	pluginMessageCmd["PluginName"] = "localHTMLAppLauncher"
	pluginMessageCmd["PluginMessage"] = Pmessage$
	m.msgPort.PostMessage(pluginMessageCmd)
End Function



Sub PluginSendZonemessage(msg$ as String)
	' send ZoneMessage message
	zoneMessageCmd = CreateObject("roAssociativeArray")
	zoneMessageCmd["EventType"] = "SEND_ZONE_MESSAGE"
	zoneMessageCmd["EventParameter"] = msg$
	m.msgPort.PostMessage(zoneMessageCmd)
End Sub



Function nodeUnpack()

	nodeZIPPathinPool$ = m.bsp.assetPoolFiles.getPoolFilePath("bundle.zip")

	if nodeZIPPathinPool$ <> "" then
		nodePackage = createObject("roBrightPackage", m.bsp.assetPoolFiles.getPoolFilePath("bundle.zip"))

		if nodePackage <> invalid then
			CreateDirectory("nodeApp")
			nodeAppPath = m.currentDrive + "nodeApp/"
			nodePackage.Unpack(nodeAppPath)
		end if
	else 
		m.PluginSystemLog.sendline("@@@ Unable to find bundle.zip file in pool")		
	end if 	
End Function



Function HandleSentPluginMsg(origMsg as string, m as object) as boolean
	retval = false
		
	' convert the message to all lower case for easier string matching later
	msg = lcase(origMsg)
	print "Received Plugin message: " + msg

	return (retVal)
end Function


Function PluginInitHTMLWidgetStatic()

	m.PluginRect = CreateObject("roRectangle", 0,0,1920,1080)
	'filepath$ = "Login.js"
	
	is = {
		port: 2999
	}
	m.config = {
		nodejs_enabled: true,
		javascript_injection: { 
		   document_creation: [], 
			document_ready: [],
			deferred: [] 
			'deferred: [{source: filepath$ }]
		},
		javascript_enabled: true,
		port: m.msgPort,
		inspector_server: is,
		brightsign_js_objects_enabled: true,
		url: m.appURL,
		mouse_enabled: true,
		storage_quota: "20000000000",
		storage_path: "CacheFolder",
		security_params: {websecurity: true, camera_enabled: false, audio_capture_enabled: true}
		'transform: "rot90" 
	}
	
	m.PluginHTMLWidget = CreateObject("roHtmlWidget", m.PluginRect, m.config)
	m.PluginHTMLWidget.Show()
End Function