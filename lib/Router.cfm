<!--- Determine if this is a field post. --->
<cfif NOT StructIsEmpty(form) and isDefined('form.extTID') and isDefined('form.extAction') and isDefined('form.extMethod')>
	<cfset jsonPacket = StructNew() />
	<cfset jsonPacket['tid'] = form.extTID />
	<cfset jsonPacket['action'] = form.extAction />
	<cfset jsonPacket['method'] = form.extMethod />
	<cfset jsonPacket['type'] = 'rpc' />
    
	<cftry>            
            <cfinvoke component="#form.extAction#" method="#form.extMethod#" argumentcollection="#form#" returnVariable="result" />
            <cfcatch type="any">
                <cfset jsonPacket['type'] = 'exception' />
                <cfset jsonPacket['message'] = cfcatch.Message />
               <!--- <cfset jsonPacket['where'] = cfcatch.TagContext.Line/> --->
                <cfcontent reset="true" /><cfoutput>#SerializeJson(jsonPacket)#</cfoutput><cfabort/>
            </cfcatch>
        </cftry>
	<cfset jsonPacket['result'] = result />
		
	<cfset json = SerializeJson(jsonPacket) />
	<cfif form.extUpload eq "true">
		<cfoutput>
		<cfsavecontent variable="output"><html><body><textarea>#json#</textarea></body></html></cfsavecontent>
		</cfoutput>
	<cfelse>
		<cfset output = json />
	</cfif>
	<cfcontent reset="true" /><cfoutput>#output#</cfoutput>
<!--- must have been JSON posted in form body --->
<cfelse>
	<cfset direct = CreateObject('component', 'Direct') />
	<cfset postBody = direct.getPostBody() />
	<cfset requests = DeserializeJSON(postBody) />
	<cfif NOT IsArray(requests)>
		<cfset tmp = requests />
		<cfset requests = ArrayNew(1) />
		<cfset requests[1] = tmp />
	</cfif>
	<cfset requestLn = ArrayLen(requests) />
	<cfloop from="1" to="#requestLn#" index="i">
		<cfset curReq = requests[i] />
                <cftry>
                    <cfset result = direct.invokeCall(curReq) />
                    <cfcatch type="any">
                        <cfset jsonPacket = StructNew() />
                        <cfset jsonPacket['type'] = 'exception' />
                        <cfset jsonPacket['tid'] = curReq['tId'] />
                        <cfset jsonPacket['message'] = cfcatch.Message />
                       <!--- <cfset jsonPacket['where'] = cfcatch.TagContext.Line/> --->
                        <cfcontent reset="true" /><cfoutput>#SerializeJson(jsonPacket)#</cfoutput><cfabort/>
                    </cfcatch>
                </cftry>
		<cfif IsStruct(result) AND StructKeyExists(result, 'name') AND StructKeyExists(result, 'result')>
			<cfset curReq['name'] = result.name />
			<cfset curReq['result'] = result.result />
		<cfelse>
			<cfset curReq['result'] = result />
		</cfif>
		<cfset StructDelete(curReq, 'data') />
	</cfloop>
	<cfcontent reset="true" /><cfoutput>#SerializeJson(requests)#</cfoutput>
</cfif>
