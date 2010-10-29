<cfset contentType = "text/javascript" />
<!--- Configure API Namespace and Description variable names --->
<cfset args = StructNew() />
<cfset args['ns'] = "Ext.ss" />
<cfset args['desc'] = "APIDesc" />
<cfif StructKeyExists(url, "format")>
    <cfset args['format'] = url.format />
    <cfif url.format eq "json">
        <cfset contentType = "application/json" />
    </cfif>
</cfif>

<cfinvoke component="Direct" method="getAPIScript" argumentcollection="#args#" returnVariable="apiScript" />
<cfcontent reset="true" />
<cfheader name="Content-Type" value="#contentType#" />
<cfoutput>#apiScript#</cfoutput>
