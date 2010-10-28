<cfcomponent name="Direct">
	<cfset variables.routerUrl = 'Router.cfm' />
	<cfset variables.remotingType = 'remoting' />
	
	<cffunction name="getPostBody" returnType="string" output="false">
	   <cfscript>
	      var size=GetPageContext().getRequest().getContentLength();
	      var emptyByteArray = createObject("java", "java.io.ByteArrayOutputStream").init().toByteArray();
	      var byteClass = createObject("java", "java.lang.Byte").TYPE;	      
	      var byteArray = createObject("java","java.lang.reflect.Array").newInstance(byteClass, size);
	      GetPageContext().getRequest().getInputStream().readLine(byteArray, 0, size);
	      createObject('java', 'java.lang.System').out.println("{GetJSONRequest} ByteArray.ToString=" &ToString( byteArray ) );
	      return ToString( byteArray );
	   </cfscript>
	</cffunction>

	<cffunction name="invokeCall">
		<cfargument name="request" />
		<cfset var idx = 1 />
		<cfset var mthIdx = 1 />
		<cfset var result = '' />
		<cfset var args = StructNew() />
	
		<!--- find the methods index in the metadata --->	
		<cfset newCfComponentMeta = GetComponentMetaData(request.action) />	

		<cfloop from="1" to="#arrayLen(newCfComponentMeta.Functions)#" index="idx">		
			<cfif newCfComponentMeta.Functions[idx]['name'] eq request.method>
				<cfset mthIdx = idx />
				<cfbreak />
			</cfif>
		</cfloop>		
	
		<cfif NOT IsArray(request.data)>
			<cfset maxParams = 0 />
		<cfelseif ArrayLen(request.data) lt ArrayLen(newCfComponentMeta.Functions[mthIdx].parameters)>
			<cfset maxParams = ArrayLen(request.data) />
		<cfelse>
			<cfset maxParams = ArrayLen(newCfComponentMeta.Functions[mthIdx].parameters) />
		</cfif>
		<!--- marry the parameters in the metadata to params passed in the request. --->		
		<cfloop from="0" to="#maxParams - 1#" index="idx">
			<cfset args[newCfComponentMeta['Functions'][mthIdx].parameters[idx+1].name] = request.data[idx+1] />
		</cfloop>
	
		<cfinvoke component="#request.Action#" method="#request.method#" argumentcollection="#args#" returnvariable="result">
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getAPIScript">
		<cfargument name="ns" />
		<cfargument name="desc" />

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
		<cfset jsonPacket['namespace'] = 'Ext.ss' />
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
