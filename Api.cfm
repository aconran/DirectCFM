<!--- Configure API Namespace and Description variable names --->
<cfset args = StructNew() />
<cfset args['ns'] = "Ext.ss" />
<cfset args['desc'] = "APIDesc" />
<cfinvoke component="Direct" method="getAPIScript" argumentcollection="#args#" returnVariable="apiScript" />
<cfcontent reset="true" />
<cfheader name="Content-Type" value="text/javascript" />
<cfoutput>#apiScript#</cfoutput>
