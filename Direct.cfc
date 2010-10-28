<cfcomponent name="Direct">
	<cfset variables.routerUrl = 'Router.cfm' />
	<cfset variables.remotingType = 'remoting' />
	
	<cffunction name="getPostBody" returnType="string" output="false">
        <cfreturn toString(getHttpRequestData().content) />
	</cffunction>

	<cffunction name="invokeCall">
		<cfargument name="request" />
		<cfset var idx = 1 />
		<cfset var mthIdx = 1 />
		<cfset var result = '' />
		<cfset var args = StructNew() />
		<cfset var maxParams = '' />
	
		<!--- find the methods index in the metadata --->	
		<cfset var newCfComponentMeta = GetComponentMetaData(arguments.request.action) />	

		<cfloop from="1" to="#arrayLen(newCfComponentMeta.Functions)#" index="idx">		
			<cfif newCfComponentMeta.Functions[idx]['name'] eq arguments.request.method>
				<cfset mthIdx = idx />
				<cfbreak />
			</cfif>
		</cfloop>		
	
		<cfif NOT IsArray(arguments.request.data)>
			<cfset maxParams = 0 />
		<cfelseif ArrayLen(arguments.request.data) lt ArrayLen(newCfComponentMeta.Functions[mthIdx].parameters)>
			<cfset maxParams = ArrayLen(arguments.request.data) />
		<cfelse>
			<cfset maxParams = ArrayLen(newCfComponentMeta.Functions[mthIdx].parameters) />
		</cfif>
		<!--- marry the parameters in the metadata to params passed in the request. --->		
		<cfloop from="0" to="#maxParams - 1#" index="idx">
			<cfset args[newCfComponentMeta['Functions'][mthIdx].parameters[idx+1].name] = arguments.request.data[idx+1] />
		</cfloop>
	
		<cfinvoke component="#arguments.request.Action#" method="#arguments.request.method#" argumentcollection="#args#" returnvariable="result">
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getAPIScript">
		<cfargument name="ns" />
		<cfargument name="desc" />

        <cfset var i = '' />
		<cfset var totalCFCs = '' />
		<cfset var cfcName = '' />
		<cfset var CFCApi = '' />
		<cfset var fnLen = '' />
		<cfset var Fn = '' />
		<cfset var currFn = '' />
		<cfset var newCfComponentMeta = '' />
		<cfset var script = '' />
		<cfset var jsonPacket = StructNew() />		
		<cfset jsonPacket['url'] = variables.routerUrl />
		<cfset jsonPacket['type'] = variables.remotingType />
		<cfset jsonPacket['namespace'] = arguments.ns />
		<cfset jsonPacket['actions'] = StructNew() />

		<cfdirectory action="list" directory="#expandPath('.')#" name="totalCFCs" filter="*.cfc" recurse="false" />

		<cfloop	query="totalCFCs">
			<cfset cfcName = ListFirst(totalCFCs.name, '.') />
			<cfset newCfComponentMeta = GetComponentMetaData(cfcName) />
			<cfif StructKeyExists(newCfComponentMeta, "ExtDirect")>		
				<cfset CFCApi = ArrayNew(1) />
		
				<cfset fnLen = ArrayLen(newCFComponentMeta.Functions) />
				<cfloop from="1" to="#fnLen#" index="i">
					<cfset currFn = newCfComponentMeta.Functions[i] />
					<cfif StructKeyExists(currFn, "ExtDirect")>
						<cfset Fn = StructNew() />
						<cfset Fn['name'] = currFn.Name/>
						<cfset Fn['len'] = ArrayLen(currFn.Parameters) />
						<cfif StructKeyExists(currFn, "ExtFormHandler")>
							<cfset Fn['formHandler'] = true />
						</cfif>
						<cfset ArrayAppend(CFCApi, Fn) />
					</cfif>
				</cfloop>	
				<cfset jsonPacket['actions'][cfcName] = CFCApi />
			</cfif>
		</cfloop>

		<cfoutput><cfsavecontent variable="script">Ext.ns('#arguments.ns#');#arguments.ns#.#desc# = #SerializeJson(jsonPacket)#;</cfsavecontent></cfoutput>
		<cfreturn script />
	</cffunction>
</cfcomponent>
