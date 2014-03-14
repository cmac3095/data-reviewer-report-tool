<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:esri="http://www.esri.com/schemas/ArcGIS/10.0"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<!-- xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/-->
<xsl:output method="text" indent="yes"/>
<!--xsl:output method="xml" indent="yes" /-->
<xsl:strip-space elements="*"/>

<!-- Initialization section - Global settings -->
<!-- indentation per level -->
<xsl:param name="level" select="1"/>
<xsl:variable name="indent" select=" ' ' "/>
<xsl:variable name="domainIndent">
	<xsl:call-template name="dup">
		<xsl:with-param name="input" select="$indent"/>
		<xsl:with-param name="count" select="2"/>
	</xsl:call-template>
</xsl:variable>
<!-- Formatting - the column width for displaying output -->
<xsl:variable name="colWidth" select="38"/>
<!-- Common settings and outputs re-used in the various templates -->
<!--xsl:variable name="_newLine">
	<xsl:text>&#xa;</xsl:text><xsl:text/>
</xsl:variable-->
<xsl:variable name="_newLine">
	<xsl:text>&#x0d;&#x0a;</xsl:text><xsl:text/>
</xsl:variable>


<xsl:variable name="spacer">
	<xsl:call-template name="dup">
		<xsl:with-param name="input" select="$indent"/>
		<xsl:with-param name="count" select="$colWidth"/>
	</xsl:call-template>
</xsl:variable>
<xsl:variable name="underline">
	<xsl:call-template name="dup">
		<xsl:with-param name="input" select=" '-' "/>
		<xsl:with-param name="count" select="80"/>
	</xsl:call-template>
	<xsl:value-of select="$_newLine"/>
</xsl:variable>
<!--  END Initialization section  Global settings -->

<!-- main entry point -->
<xsl:template match="/">
	<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="BatchJobDescription">
	<xsl:variable name="_indent">
		<xsl:value-of select="substring($spacer,1,count(ancestor::*) )"/>
	</xsl:variable>
		<!-- Header -->
	<xsl:text/><xsl:value-of select="$indent"/>General Information<xsl:value-of select="$_newLine"/>
	<xsl:text/><xsl:value-of select="$indent"/><xsl:value-of select="$underline"/>
	
	<xsl:for-each select="*">
		<xsl:call-template name="colFormat">
			<!-- provide the appropriate indent -->
			<xsl:with-param name="margin" select="$_indent"/>
			<xsl:with-param name="colName" select="local-name(.)"/>
			<xsl:with-param name="colValue" select="normalize-space( translate(.,'–','-' ) )"/>
			<xsl:with-param name="wd" select="$colWidth"/>
		</xsl:call-template>
	</xsl:for-each>
	<xsl:call-template name="PrintStats"/>
</xsl:template>

<xsl:template name="PrintStats">
	<xsl:variable name="_indent">
		<xsl:text/><xsl:value-of select="concat($indent,$indent)"/>
	</xsl:variable>
	<!-- Header -->
	<xsl:text/><xsl:value-of select="$_newLine"/>
	<xsl:text/><xsl:value-of select="$indent"/>Statistics<xsl:value-of select="$_newLine"/>
	<xsl:text/><xsl:value-of select="$indent"/><xsl:value-of select="$underline"/>
	<!-- collect the stats -->
		<!-- Get the number of resources in the Batch Job -->
	<xsl:variable name="_rez" select="count(//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'UniqueResources']/Value/PropertyArray/PropertySetProperty/Key)"/>
	
	<!-- Get the number of filters in the Batch Job -->
	<xsl:variable name="_filters" select="count(//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'Filters']/Value/PropertyArray/PropertySetProperty/Value[*]) "/>
									
	<!-- Get the number of checks in the Batch Job -->
	<xsl:variable name="_checks" select="count(//CheckGroup/RevCheckConfig/ConfigProperties/PropertyArray/PropertySetProperty[
	translate(Key,'V','v') = 'Reviewer Check GUID']) "/>

	 <!-- print the stats out -->
	<xsl:call-template name="colFormat">
		<xsl:with-param name="margin" select="$_indent"/>
		<xsl:with-param name="colName" select=" 'Resources' "/>
		<xsl:with-param name="colValue" select="$_rez"/>
		<xsl:with-param name="wd" select="$colWidth"/>
	</xsl:call-template>
	
	<xsl:call-template name="colFormat">
		<xsl:with-param name="margin" select="$_indent"/>
		<xsl:with-param name="colName" select=" 'Filters' "/>
		<xsl:with-param name="colValue">
			<xsl:choose>
				<xsl:when test="not($_filters)"><xsl:value-of select=" '0' "/></xsl:when>
				<xsl:otherwise><xsl:value-of select="$_filters"/></xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name="wd" select="$colWidth"/>
	</xsl:call-template>
	
	<!-- Now the checks - title first then the count of the check types -->
	<xsl:text/><xsl:value-of select="$_newLine"/>
	<xsl:text/><xsl:value-of select="$_indent"/><xsl:value-of select=" 'Checks' "/><xsl:value-of select="$_newLine"/>

	<!-- list out the count of each check type -->
	<!-- make a list of all checks in the batch job -->
	<xsl:variable name="_allChecks" 
	 select="//CheckGroup/RevCheckConfig/ConfigProperties/PropertyArray/PropertySetProperty[translate(Key,'V','v') = 'Reviewer Check Name'] "/>

	<!-- make a list of all unique checks in the batch job from the list of checks -->
	<xsl:variable name="_uniqueChecks" select="$_allChecks[not(Value = preceding::Value)]"/>
	<xsl:for-each select="$_uniqueChecks">
		<xsl:sort select="Value" order="ascending"/>
		<xsl:variable name="_currCheck" select="Value"/>
		<!-- list out the checks -->
		<xsl:call-template name="colFormat">
			<xsl:with-param name="margin" select="concat($indent,$_indent)"/>
			<xsl:with-param name="colName" select=" $_currCheck "/>
			<xsl:with-param name="colValue">
				<xsl:value-of select="count(//CheckGroup/RevCheckConfig/ConfigProperties/PropertyArray/PropertySetProperty[translate(Key,'V','v') = 'Reviewer Check Name' and Value = $_currCheck])"/>
			</xsl:with-param>
			<xsl:with-param name="wd" select="$colWidth"/>
		</xsl:call-template>
	</xsl:for-each>
	<!-- Now the total -->
   <xsl:text/><xsl:value-of select="concat($indent,$_indent)"/><xsl:value-of select="$underline"/>
	<xsl:call-template name="colFormat">
		<xsl:with-param name="margin" select="concat($indent,$_indent)"/>
		<xsl:with-param name="colName" select=" 'Total' "/>
		<xsl:with-param name="colValue" select="$_checks"/>
		<xsl:with-param name="wd" select="$colWidth"/>
	</xsl:call-template>
</xsl:template>

<!-- These are no ops-->
<xsl:template match="PropertySetProperty[Key = 'Filters' ]"/>
<xsl:template match="PropertySetProperty[Key = 'UniqueResources' ]"/>
<xsl:template match="PropertySetProperty[Key = 'KeyHash' ]"/>

<xsl:template match="CheckGroup[@xsi:type='esri:BatchJobGroup' ]">
	<xsl:text/><xsl:value-of select="$_newLine"/><!-- space above the group name -->
	<xsl:variable name="_indent">
		<xsl:value-of select="substring($spacer,1,count(ancestor::*) - 1)"/>
	</xsl:variable>
	<!-- Group Name -->
	<xsl:value-of select="$_indent"/><xsl:text>Group:  </xsl:text><xsl:value-of select="normalize-space( translate(GroupName,'–','-' ) )"/><xsl:value-of select="$_newLine"/>
	<!-- list out all the checks per group -->
	<xsl:for-each select="RevCheckConfig">
		
		<xsl:if test="position() > 1">
			<xsl:text/><xsl:value-of select="$_newLine"/><!-- space above the check name -->
		</xsl:if>
		
		<!-- Check name -->
		<xsl:call-template name="colFormat">
				<!-- provide the appropriate indent -->
				<xsl:with-param name="margin" select="concat($indent,$_indent)"/>
				<xsl:with-param name="colName" select=" concat(concat(concat('Check','['),position()),']') "/>
				<xsl:with-param name="colValue" select="ConfigProperties/PropertyArray/PropertySetProperty[translate(Key,'V','v')='Reviewer Check Name' ]/Value"/>
				<xsl:with-param name="wd" select="$colWidth"/>
		</xsl:call-template>
		<!-- User Title -->
		<xsl:call-template name="colFormat">
				<!-- provide the appropriate indent -->
				<xsl:with-param name="margin" select="concat($indent,$_indent)"/>
				<xsl:with-param name="colName" select=" 'Title' "/>
				<xsl:with-param name="colValue" select="normalize-space( translate(ConfigProperties/PropertyArray/PropertySetProperty[translate(Key,'V','v')='Reviewer Check Title' ]/Value,'–','-' ) )"/>
				<xsl:with-param name="wd" select="$colWidth"/>
		</xsl:call-template>
		
		<!-- Check Resources -->
		<xsl:value-of select="concat($indent,$_indent)"/><xsl:text>Resources:  </xsl:text><xsl:value-of select="$_newLine"/>
		
		<xsl:variable name="res-key" select="Resources/ResourceToValidateKey"/>
		<xsl:variable name="hash-key" select="//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'KeyHash' ]/Value/PropertyArray/PropertySetProperty[Key = $res-key]/Value"/>
				
		<xsl:call-template name="PrintResource">						
		    <xsl:with-param name="title" select=" 'Primary Resource' "/>
			<xsl:with-param name="resource" select="//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'UniqueResources' ]/Value/PropertyArray/PropertySetProperty[Key = $hash-key]"/>
			<xsl:with-param name="filter" select="//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'Filters' ]/Value/PropertyArray/PropertySetProperty[Key = $res-key]/Value"/>
			<xsl:with-param name="margin" select="concat(concat(concat($indent,$_indent),$indent),$indent)"/>
		</xsl:call-template>
		
		<!-- are there any secondary resources? -->
	<xsl:if test="count(Resources/SecondaryResourceKeys/PropertyArray/PropertySetProperty) > 0">
		<xsl:for-each select="Resources/SecondaryResourceKeys/PropertyArray/PropertySetProperty">
			<xsl:variable name="sec-res-key" select="Value"/>
			<xsl:variable name="sec-hash-key" select="//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'KeyHash' ]/Value/PropertyArray/PropertySetProperty[Key = $sec-res-key]/Value"/>
			
			<xsl:call-template name="PrintResource">
				<xsl:with-param name="title" select="Key"/>
				<xsl:with-param name="resource" select="//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'UniqueResources' ]/Value/PropertyArray/PropertySetProperty[Key = $sec-hash-key]"/>
				<xsl:with-param name="filter" select="//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'Filters' ]/Value/PropertyArray/PropertySetProperty[Key = $sec-res-key]/Value"/>
				<xsl:with-param name="margin" select="concat(concat(concat($indent,$_indent),$indent),$indent)"/>
			</xsl:call-template>		
		
		</xsl:for-each>
	</xsl:if>
	
		<xsl:for-each select="ConfigProperties/PropertyArray/PropertySetProperty[translate(Key,'V','v') !='Reviewer Check Name' and translate(Key,'V','v') !='Reviewer Check Title' and translate(Key,'V','v') !='Reviewer Check GUID' and Key != 'ToleranceUnits'] ">
			
			<xsl:call-template name="PrintRevCheckConfigParams">
					<xsl:with-param name="_indent" select="concat($indent,$_indent)"/>
			</xsl:call-template>

		</xsl:for-each>
											
	</xsl:for-each>
</xsl:template>

<xsl:template name="PrintRevCheckConfigParams">
	<xsl:param name="_indent" select=" $indent "/>
	
	<xsl:choose>
			<xsl:when test="contains(Key,'_')">
				<!-- This is a composite check -->
				<xsl:if test="substring-before(Key,'_') = 'Config' ">
					<!-- print out the contents of the composite check params -->
					<xsl:variable name="_cNum" select=" substring-after(Key,'_') "/>
					<xsl:call-template name="colFormat">
						<!-- provide the appropriate indent -->
						<xsl:with-param name="margin" select="concat($_indent,$indent)"/>
						<xsl:with-param name="colName" select=" concat(concat('Composite Check[',$_cNum),']') "/>
						<xsl:with-param name="colValue" select=" following-sibling::*[Key = concat('ParameterKey_',$_cNum)]/Value "/>
						<xsl:with-param name="wd" select="$colWidth"/>
					</xsl:call-template>
					<!-- These are the params -->
					<!--resources first -->
					<xsl:variable name="res-key" select="Value/Resources/ResourceToValidateKey"/>
					<xsl:variable name="hash-key" select="//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'KeyHash' ]/Value/PropertyArray/PropertySetProperty[Key = $res-key]/Value"/>
					<!--Primary -->
					<xsl:call-template name="PrintResource">						
						<xsl:with-param name="title" select=" 'Primary Resource' "/>
						<xsl:with-param name="resource" select="//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'UniqueResources' ]/Value/PropertyArray/PropertySetProperty[Key = $hash-key]"/>
						<xsl:with-param name="filter" select="//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'Filters' ]/Value/PropertyArray/PropertySetProperty[Key = $res-key]/Value"/>
						<xsl:with-param name="margin" select="concat(concat($_indent,$indent),$indent)"/>
					</xsl:call-template>					
					<!-- Secondary -->
					
					<xsl:if test="count(Value/Resources/SecondaryResourceKeys/PropertyArray/PropertySetProperty/Value) > 0">
						<xsl:for-each select="Value/Resources/SecondaryResourceKeys/PropertyArray/PropertySetProperty">
							<xsl:variable name="sec-res-key" select="Value"/>
							<xsl:variable name="sec-hash-key" select="//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'KeyHash' ]/Value/PropertyArray/PropertySetProperty[Key = $sec-res-key]/Value"/>
							
							<xsl:call-template name="PrintResource">
								<xsl:with-param name="title" select=" Key "/>
								<xsl:with-param name="resource" select="//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'UniqueResources' ]/Value/PropertyArray/PropertySetProperty[Key = $sec-hash-key]"/>
								<xsl:with-param name="filter" select="//ResourceRegistry/RegistryStorage/PropertyArray/PropertySetProperty[Key = 'Filters' ]/Value/PropertyArray/PropertySetProperty[Key = $sec-res-key]/Value"/>
								<xsl:with-param name="margin" select="concat(concat($_indent,$indent),$indent)"/>
							</xsl:call-template>		
						
						</xsl:for-each>
					</xsl:if>
					<!-- now the rest of the params -->
					<xsl:for-each select="Value/ConfigProperties/PropertyArray/PropertySetProperty[translate(Key,'V','v') !='Reviewer Check GUID' and Key != 'ToleranceUnits']">
					
						<xsl:call-template name="PrintRevCheckConfigParams">
							<xsl:with-param name="_indent" select="concat($indent,$_indent)"/>
						</xsl:call-template>
					</xsl:for-each>	
				</xsl:if>
			</xsl:when>
			<xsl:when test="Key = 'ErrorConditions'">
				<!-- If there are error conditions, list them -->
				<xsl:if test="Value[count(*) > 0]">
					<xsl:value-of select="concat(concat(concat($indent,$_indent),$indent),$indent)"/>ErrorConditions:<xsl:value-of select="$_newLine"/>
					<xsl:call-template name="ErrorConditions">
						<xsl:with-param name="conditions" select="Value"/>
						<xsl:with-param name="margin" select="concat(concat(concat($_indent,$indent),$indent),$indent)"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="Key = 'CNTOIDs'">
				<xsl:text/><xsl:value-of select="concat($_indent,$indent)"/><xsl:value-of select=" 'CNTOIDs' "/><xsl:value-of select="$_newLine"/>
				<xsl:call-template name="colFormat">
					<!-- provide the appropriate indent -->
					<xsl:with-param name="margin" select="concat(concat($_indent,$indent),$indent)"/>
					<xsl:with-param name="colName" select=" 'CNTCount' "/>
					<xsl:with-param name="colValue" select=" Value/CNTCount "/>
					<xsl:with-param name="wd" select="$colWidth"/>
				</xsl:call-template>
				
				<xsl:for-each select="Value/CNTHelper/*[local-name() !='GUID']">
					<xsl:variable name="_cnt" select="count(parent::*/preceding-sibling::CNTHelper) + 1"/>
					
					<xsl:call-template name="colFormat">
						<!-- provide the appropriate indent -->
						<xsl:with-param name="margin" select="concat(concat(concat($_indent,$indent),$indent),$indent)"/>
						<xsl:with-param name="colName" select=" concat(concat(concat(local-name(.),'['),$_cnt),']') "/>
						<xsl:with-param name="colValue" select=" . "/>
						<xsl:with-param name="wd" select="$colWidth"/>
					</xsl:call-template>
				</xsl:for-each>	
			</xsl:when>		
			<!-- Evaluator Helper -->
			<xsl:when test="Key = 'EvaluatorHelper'">
				<xsl:text/><xsl:value-of select="concat($_indent,$indent)"/><xsl:value-of select=" 'EvaluatorHelper' "/><xsl:value-of select="$_newLine"/>
				<xsl:call-template name="colFormat">
					<!-- provide the appropriate indent -->
					<xsl:with-param name="margin" select="concat(concat($_indent,$indent),$indent)"/>
					<xsl:with-param name="colName" select=" 'WhatToEvaluate' "/>
					<xsl:with-param name="colValue" select=" ../PropertySetProperty[Key = 'WhatToEvaluate']/Value "/>
					<xsl:with-param name="wd" select="$colWidth"/>
				</xsl:call-template>
				
				<xsl:for-each select="Value/*">
					<xsl:call-template name="colFormat">
						<!-- provide the appropriate indent -->
						<xsl:with-param name="margin" select="concat(concat($_indent,$indent),$indent)"/>
						<xsl:with-param name="colName" select=" local-name(.) "/>
						<xsl:with-param name="colValue" select=" . "/>
						<xsl:with-param name="wd" select="$colWidth"/>
					</xsl:call-template>
				</xsl:for-each>	
			</xsl:when>		
			<!-- no-op for WhatToEvaluate -->
			<xsl:when test="Key = 'WhatToEvaluate'"/>
			
			<!-- metadata properties -->
			<xsl:when test="Key = 'MetadataSourceCollection' ">
				<xsl:call-template name="colFormat">
					<!-- provide the appropriate indent -->
					<xsl:with-param name="margin" select="$_indent"/>
					<xsl:with-param name="colName" select=" 'Metadata Source Collection' "/>
					<xsl:with-param name="colValue" select=" '' "/>
					<xsl:with-param name="wd" select="$colWidth"/>
				</xsl:call-template>
				<xsl:for-each select="Value/MetadataSourceCollectionSet/PropertyArray/PropertySetProperty/Value[@xsi:type='typens:RevMetadataSource']">
					
					<!-- Each Metadata source collection has an index or 'Key' -->
					<xsl:call-template name="colFormat">
						<!-- provide the appropriate indent -->
						<xsl:with-param name="margin" select="concat($indent,$_indent)"/>
						<xsl:with-param name="colName" select=" 'Key' "/>
						<xsl:with-param name="colValue" select="../Key"/>
						<xsl:with-param name="wd" select="$colWidth"/>
					</xsl:call-template>
					
					<!-- source name and type -->
					<xsl:call-template name="colFormat">
						<!-- provide the appropriate indent -->
						<xsl:with-param name="margin" select="concat(concat($indent,$_indent),$_indent)"/>
						<xsl:with-param name="colName" select="MetadataSourceName"/>
						<xsl:with-param name="colValue">
							<xsl:value-of select="MetadataSourceName"/>(<xsl:text/>
							<xsl:call-template name="LUTDatasetType">
								<xsl:with-param name="dstype" select="MetadataSourceType"/>
							</xsl:call-template>
							<xsl:text>)</xsl:text>
						</xsl:with-param>
						<xsl:with-param name="wd" select="$colWidth"/>
					</xsl:call-template>							
					
					<!-- source containing name and type -->
					<xsl:call-template name="colFormat">
							<!-- provide the appropriate indent -->
							<xsl:with-param name="margin" select="concat(concat($indent,$_indent),$_indent)"/>
							<xsl:with-param name="colName" select="MetadataSourceContainingName"/>
							<xsl:with-param name="colValue">
								<xsl:value-of select="MetadataSourceContainingName"/>(<xsl:text/>
								<xsl:call-template name="LUTDatasetType">
									<xsl:with-param name="dstype" select="MetadataSourceContainingType"/>
								</xsl:call-template>
								<xsl:text>)</xsl:text>
							</xsl:with-param>
							<xsl:with-param name="wd" select="$colWidth"/>
						</xsl:call-template>
					</xsl:for-each>
			</xsl:when>
			<xsl:when test="Key = 'XPathExpressionCollection' ">
				<xsl:call-template name="colFormat">
					<!-- provide the appropriate indent -->
					<xsl:with-param name="margin" select="$_indent"/>
					<xsl:with-param name="colName" select=" 'XPath Expression Collection:' "/>
					<xsl:with-param name="colValue" select=" '' "/>
					<xsl:with-param name="wd" select="$colWidth"/>
				</xsl:call-template>
				<xsl:for-each select="Value/RevXPathCollectionSet/PropertyArray/PropertySetProperty/Value[@xsi:type='typens:RevXPathExpression']">
					<!-- Each XPath expression collection has an index or 'Key' -->
					<xsl:call-template name="colFormat">
						<!-- provide the appropriate indent -->
						<xsl:with-param name="margin" select="concat($indent,$_indent)"/>
						<xsl:with-param name="colName" select=" 'Key' "/>
						<xsl:with-param name="colValue" select="../Key"/>
						<xsl:with-param name="wd" select="$colWidth"/>
					</xsl:call-template>
					<!-- now list out the xpath expression components -->
					<xsl:for-each select="*">
						<!-- print out each child -->
						<xsl:call-template name="colFormat">
								<!-- provide the appropriate indent -->
								<xsl:with-param name="margin" select="concat(concat($indent,$_indent),$_indent)"/>
								<xsl:with-param name="colName" select="local-name(.)"/>
								<xsl:with-param name="colValue" select="."/>
								<xsl:with-param name="wd" select="$colWidth"/>
							</xsl:call-template>
					</xsl:for-each>
				</xsl:for-each>
				
			</xsl:when>
			<!-- Regular Expressions -->
			<xsl:when test=" Key = 'RegularExpressions' ">
				<xsl:call-template name="colFormat">
					<!-- provide the appropriate indent -->
					<xsl:with-param name="margin" select="$_indent"/>
					<xsl:with-param name="colName" select=" 'RegularExpression' "/>
					<xsl:with-param name="colValue" select=" '' "/>
					<xsl:with-param name="wd" select="$colWidth"/>
				</xsl:call-template>

				<!-- Print out the regular expression field -->
				<xsl:call-template name="colFormat">
					<!-- provide the appropriate indent -->
					<xsl:with-param name="margin" select="concat($_indent,$indent)"/>
					<xsl:with-param name="colName" select=" 'Field' "/>
					<xsl:with-param name="colValue">
						<xsl:call-template name="PrintField">
							<xsl:with-param name="_fld" select="Value/RegularExpressionConstraint/Field"/>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="wd" select="$colWidth"/>
				</xsl:call-template>
				
				<!-- Print out the regular expression pattern -->
				<xsl:call-template name="colFormat">
					<!-- provide the appropriate indent -->
					<xsl:with-param name="margin" select="concat($_indent,$indent)"/>
					<xsl:with-param name="colName" select=" 'Pattern' "/>
					<xsl:with-param name="colValue" select="Value/RegularExpressionConstraint/RegularExpressionPattern"/>
					<xsl:with-param name="wd" select="$colWidth"/>
				</xsl:call-template>			
			</xsl:when>
			<xsl:otherwise>
			<!-- These properties are matched as formatted Column Name: Column Value pairs
				  One per line -->
				  <xsl:call-template name="colFormat">
					<!-- provide the appropriate indent -->
					<xsl:with-param name="margin" select="concat($indent,$_indent)"/>
					<xsl:with-param name="colName" select="Key"/>
					<xsl:with-param name="colValue">
						<!-- translate the value for certain params like spatialenum and tolerance units -->
						<xsl:choose>
							<xsl:when test="Key = 'SpatialEnum' ">
								<xsl:call-template name="LUTSpatialEnum">
									<xsl:with-param name="spatenum" select="Value"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="Key = 'Tolerance' ">
								<xsl:variable name="tolunits">
									<xsl:call-template name="LUTToleranceUnits">
										<xsl:with-param name="tolunit" select="../PropertySetProperty[Key='ToleranceUnits']/Value"/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:value-of select="concat(concat(Value,' '),$tolunits)"/>
							</xsl:when>
							<xsl:otherwise>
								<!-- default -->
								<xsl:value-of select="normalize-space( translate(Value,'–˚','-o' ) )"/>
							</xsl:otherwise>
						</xsl:choose>				
					</xsl:with-param>
					<xsl:with-param name="wd" select="$colWidth"/>
				</xsl:call-template>				
			</xsl:otherwise>
		</xsl:choose>

</xsl:template>

<!-- This is a resource for a check -->
<xsl:template name="PrintResource">
	<xsl:param name="title"/>
	<xsl:param name="resource"/>
	<xsl:param name="filter"/>
	<xsl:param name="margin"/>
	
	<xsl:call-template name="colFormat">
		<!-- provide the appropriate indent -->
		<xsl:with-param name="margin" select="$margin"/>
		<xsl:with-param name="colName" select="$title"/>
		<xsl:with-param name="colValue" select="$resource//RevDatasetName"/>
		<xsl:with-param name="wd" select="$colWidth"/>
	</xsl:call-template>
	
	<xsl:for-each select="$resource//ConnectionProperties/PropertyArray/PropertySetProperty[Key != 'PROVIDERCLSID' and Key != 'AUTHENTICATION_MODE' and Key != 'PASSWORD' ]">
		<xsl:call-template name="colFormat">
			<!-- provide the appropriate indent -->
			<xsl:with-param name="margin" select="concat($indent,$margin)"/>
			<xsl:with-param name="colName" select="Key"/>
			<xsl:with-param name="colValue" select=" normalize-space(Value)"/>
			<xsl:with-param name="wd" select="$colWidth"/>
		</xsl:call-template>
	</xsl:for-each>
	<!-- Handle any filters -->
	<xsl:if test="$filter[*]">
		<!-- we have children -->
		<xsl:value-of select="concat($indent,$margin)"/>Filter(s):<xsl:value-of select="$_newLine"/>
		<!-- subfields -->
		<xsl:if test="$filter/Filter[@xsi:type='esri:RevSQLQueryFilter']/InternalQuery/SubFields">
			<xsl:call-template name="colFormat">
				<!-- provide the appropriate indent -->
				<xsl:with-param name="margin" select="concat(concat($indent,$margin),$indent)"/>
				<xsl:with-param name="colName" select=" 'SubFields' "/>
				<!--xsl:with-param name="colValue" select="concat(concat('''',$filter/Filter[@xsi:type='esri:RevSQLQueryFilter']/InternalQuery/SubFields),'''') "/-->
				<xsl:with-param name="colValue" select="$filter/Filter[@xsi:type='esri:RevSQLQueryFilter']/InternalQuery/SubFields "/>
				<xsl:with-param name="wd" select="$colWidth"/>
			</xsl:call-template>
		</xsl:if>
		
		<!-- "Standard" where clause -->
		<xsl:if test="$filter/Filter[@xsi:type='esri:RevSQLQueryFilter']/InternalQuery/WhereClause">
			<xsl:call-template name="colFormat">
				<!-- provide the appropriate indent -->
				<xsl:with-param name="margin" select="concat(concat($indent,$margin),$indent)"/>
				<xsl:with-param name="colName" select=" 'Where Clause' "/>
				<xsl:with-param name="colValue" select="$filter/Filter[@xsi:type='esri:RevSQLQueryFilter']/InternalQuery/WhereClause"/>
				<xsl:with-param name="wd" select="$colWidth"/>
			</xsl:call-template>
		</xsl:if>
		<!-- Subtype -->
		<xsl:if test="$filter/Filter[@xsi:type='esri:RevSubtypeFilter']/SubtypeWhereClause">
			<xsl:call-template name="colFormat">
				<!-- provide the appropriate indent -->
				<xsl:with-param name="margin" select="concat(concat($indent,$margin),$indent)"/>
				<xsl:with-param name="colName" select=" 'Subtype' "/>
				<xsl:with-param name="colValue" select="$filter/Filter[@xsi:type='esri:RevSubtypeFilter']/SubtypeWhereClause"/>
				<xsl:with-param name="wd" select="$colWidth"/>
			</xsl:call-template>
		</xsl:if>
		
	</xsl:if>
	
</xsl:template>

<!-- list out associated error conditions for the check -->
<xsl:template name="ErrorConditions">
	<xsl:param name="conditions"/>
	<xsl:param name="margin"/>
	
	<xsl:for-each select="$conditions/RowComparison">
		<!-- each row is an error comparison -->
		<xsl:value-of select="$margin"/><xsl:text/>
		<xsl:text/><xsl:call-template name="PrintField"><xsl:with-param name="_fld" select="ValueField"/></xsl:call-template><xsl:text />
		<xsl:text/><xsl:value-of select="ComparisonOperator"/><xsl:text/>
		<xsl:text/><xsl:call-template name="PrintField"><xsl:with-param name="_fld" select="SearchField"/></xsl:call-template><xsl:text/>
		<xsl:text/><xsl:value-of select="$_newLine"/>
	</xsl:for-each>
	
</xsl:template>

<xsl:template name="PrintField">
   <xsl:param name="_fld"/>
	
	<!-- Field Name -->
	<xsl:text/>[<xsl:value-of select="$_fld/Name"/>] <xsl:text/>
	
	<!-- Field Definition -->	
	<xsl:text/>(<xsl:value-of select="$_fld/Type"/><xsl:text/>

	<xsl:if test="$_fld/Type = 'esriFieldTypeString' ">
		<xsl:text>(</xsl:text><xsl:value-of select="$_fld/Length"/><xsl:text>)</xsl:text>
	</xsl:if>
	<!-- nullable -->
	<xsl:choose>
		<xsl:when test="$_fld/IsNullable = 'true' "><xsl:text> null</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text> not null</xsl:text></xsl:otherwise>
	</xsl:choose>
	<!-- required -->
	<xsl:if test="$_fld/Required[. = 'true'] ">
		<xsl:text>, required</xsl:text>
	</xsl:if>
	<!-- editable -->
	<xsl:if test="$_fld/Editable[. = 'false'] ">
		<xsl:text>, readonly</xsl:text>
	</xsl:if>
	<!-- alias -->
	<xsl:if test="$_fld/AliasName[. != '' ]">
			<xsl:text>, alias: [</xsl:text><xsl:value-of select="$_fld/AliasName"/>]<xsl:text/>
		</xsl:if>
	<!-- model -->
	<xsl:if test="$_fld/ModelName[. != '' ]">
		<xsl:text>, model: [</xsl:text><xsl:value-of select="$_fld/ModelName"/>]<xsl:text/>
	</xsl:if>

	<xsl:text>)</xsl:text><xsl:text/>
</xsl:template>
	
<xsl:template match="* | @*">
	<xsl:apply-templates select="node() | @*"/>
</xsl:template>

<!-- Lookups -->
<xsl:template name="LUTSpatialEnum">
	<xsl:param name="spatenum"/>
	
	<xsl:choose>
		<xsl:when test="$spatenum = '1' "><xsl:text>Intersects</xsl:text></xsl:when>
		<xsl:when test="$spatenum = '2' "><xsl:text>Envelope Intersects</xsl:text></xsl:when>
		<xsl:when test="$spatenum = '3' "><xsl:text>Index Intersects</xsl:text></xsl:when>
		<xsl:when test="$spatenum = '4' "><xsl:text>Touches</xsl:text></xsl:when>
		<xsl:when test="$spatenum = '5' "><xsl:text>Overlaps</xsl:text></xsl:when>
		<xsl:when test="$spatenum = '6' "><xsl:text>Crosses</xsl:text></xsl:when>
		<xsl:when test="$spatenum = '7' "><xsl:text>Within</xsl:text></xsl:when>
		<xsl:when test="$spatenum = '8' "><xsl:text>Contains</xsl:text></xsl:when>
		<xsl:when test="$spatenum = '9' "><xsl:text>Relation</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text>Unknown</xsl:text></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="LUTToleranceUnits">
	<xsl:param name="tolunit"/>
	
	<xsl:choose>
		<xsl:when test="$tolunit = '1' "><xsl:text>Inches</xsl:text></xsl:when>
		<xsl:when test="$tolunit = '2' "><xsl:text>Points</xsl:text></xsl:when>
		<xsl:when test="$tolunit = '3' "><xsl:text>Feet</xsl:text></xsl:when>
		<xsl:when test="$tolunit = '4' "><xsl:text>Yards</xsl:text></xsl:when>
		<xsl:when test="$tolunit = '5' "><xsl:text>Miles</xsl:text></xsl:when>
		<xsl:when test="$tolunit = '6' "><xsl:text>Nautical Miles</xsl:text></xsl:when>
		<xsl:when test="$tolunit = '7' "><xsl:text>Millimeters</xsl:text></xsl:when>
		<xsl:when test="$tolunit = '8' "><xsl:text>Centimeters</xsl:text></xsl:when>
		<xsl:when test="$tolunit = '9' "><xsl:text>Meters</xsl:text></xsl:when>
		<xsl:when test="$tolunit = '10' "><xsl:text>Kilometers</xsl:text></xsl:when>
		<xsl:when test="$tolunit = '11' "><xsl:text>Decimal Degrees</xsl:text></xsl:when>
		<xsl:when test="$tolunit = '12' "><xsl:text>Decimeters</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text>Unknown</xsl:text></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="LUTReviewerResourceType">
	<xsl:param name="revres"/>
	
	<xsl:choose>
		<xsl:when test="$revres = '0' "><xsl:text>Workspace</xsl:text></xsl:when>
		<xsl:when test="$revres = '1' "><xsl:text>TopoFeatureClass</xsl:text></xsl:when>
		<xsl:when test="$revres = '2' "><xsl:text>Table</xsl:text></xsl:when>
		<xsl:when test="$revres = '3' "><xsl:text>FeatureClass</xsl:text></xsl:when>
		<xsl:when test="$revres = '4' "><xsl:text>Row</xsl:text></xsl:when>
		<xsl:when test="$revres = '5' "><xsl:text>Feature</xsl:text></xsl:when>
		<xsl:when test="$revres = '6' "><xsl:text>TopoFeature</xsl:text></xsl:when>
		<xsl:when test="$revres = '7' "><xsl:text>GeometricNetwork</xsl:text></xsl:when>
		<xsl:when test="$revres = '8' "><xsl:text>RelationshipClass</xsl:text></xsl:when>
		<xsl:when test="$revres = '9' "><xsl:text>ListOfResources</xsl:text></xsl:when>
		<xsl:when test="$revres = '10' "><xsl:text>Topology</xsl:text></xsl:when>
		<xsl:when test="$revres = '11' "><xsl:text>Folder</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text>Unknown</xsl:text></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="LUTDatasetType">
	<xsl:param name="dstype"/>
	
	<xsl:choose>
		<xsl:when test="$dstype = '1' "><xsl:text>Any</xsl:text></xsl:when>
		<xsl:when test="$dstype = '2' "><xsl:text>Container</xsl:text></xsl:when>
		<xsl:when test="$dstype = '3' "><xsl:text>GeoDataset</xsl:text></xsl:when>
		<xsl:when test="$dstype = '4' "><xsl:text>FeatureDataset</xsl:text></xsl:when>
		<xsl:when test="$dstype = '5' "><xsl:text>FeatureClass</xsl:text></xsl:when>
		<xsl:when test="$dstype = '6' "><xsl:text>PlanarGraph</xsl:text></xsl:when>
		<xsl:when test="$dstype = '7' "><xsl:text>GeometricNetwork</xsl:text></xsl:when>
		<xsl:when test="$dstype = '8' "><xsl:text>Topology</xsl:text></xsl:when>
		<xsl:when test="$dstype = '9' "><xsl:text>Text</xsl:text></xsl:when>
		<xsl:when test="$dstype = '10' "><xsl:text>Table</xsl:text></xsl:when>
		<xsl:when test="$dstype = '11' "><xsl:text>RelationshipClass</xsl:text></xsl:when>
		<xsl:when test="$dstype = '12' "><xsl:text>RasterDataset</xsl:text></xsl:when>
		<xsl:when test="$dstype = '13' "><xsl:text>RasterBand</xsl:text></xsl:when>
		<xsl:when test="$dstype = '14' "><xsl:text>Tin</xsl:text></xsl:when>
		<xsl:when test="$dstype = '15' "><xsl:text>CadDrawing</xsl:text></xsl:when>
		<xsl:when test="$dstype = '16' "><xsl:text>RasterCatalog</xsl:text></xsl:when>
		<xsl:when test="$dstype = '17' "><xsl:text>Toolbox</xsl:text></xsl:when>
		<xsl:when test="$dstype = '18' "><xsl:text>Tool</xsl:text></xsl:when>
		<xsl:when test="$dstype = '19' "><xsl:text>NetworkDataset</xsl:text></xsl:when>
		<xsl:when test="$dstype = '20' "><xsl:text>Terrain</xsl:text></xsl:when>
		<xsl:when test="$dstype = '21' "><xsl:text>RepresentationClass</xsl:text></xsl:when>
		<xsl:when test="$dstype = '22' "><xsl:text>CadastralFabric</xsl:text></xsl:when>
		<xsl:when test="$dstype = '23' "><xsl:text>SchematicDataset</xsl:text></xsl:when>
		<xsl:when test="$dstype = '24' "><xsl:text>Locator</xsl:text></xsl:when>
		<!-- There is NO '25' -->
		<xsl:when test="$dstype = '26' "><xsl:text>Map</xsl:text></xsl:when>
		<xsl:when test="$dstype = '27' "><xsl:text>Layer</xsl:text></xsl:when>
		<xsl:when test="$dstype = '28' "><xsl:text>Style</xsl:text></xsl:when>
		<xsl:when test="$dstype = '29' "><xsl:text>MosaicDataset</xsl:text></xsl:when>
		<xsl:when test="$dstype = '30' "><xsl:text>LasDataset</xsl:text></xsl:when>
		<xsl:otherwise><xsl:text>Unknown</xsl:text></xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- ================================================================== -->
<!-- Utility templates -->
<xsl:template name="colFormat">
	<xsl:param name="margin" select = " ' ' "/>
	<xsl:param name="colName" select=" '' "/>
	<xsl:param name="colValue" select=" '' "/>
	<xsl:param name="wd" select="22"/>
	
	<!-- format the output -->
	
	<!-- First - if the column content is too long, truncate it -->
	<xsl:variable name="_colName">
		<xsl:choose>
			<!-- the "$wd - 4" bit accounts for three elipses "..." plus a colon ":" that would
                  need to be appended to the truncated string -->
			<xsl:when test="string-length(concat($margin,$colName)) > ($wd - 4)">
				<xsl:value-of select="$margin"/><xsl:value-of select="concat(substring($colName,1, $wd - 4 - string-length($margin)),'...')  "/>:<xsl:text/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$margin"/><xsl:value-of select="$colName"/>:<xsl:text/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- print it -->
	<xsl:value-of select="$_colName"/>
	<!-- now the value -->
	<xsl:choose>
		<xsl:when test="not($colValue)"/>
		<xsl:otherwise>
			<!-- fill out the column to align the text 'nicely' 
				  The "+1" is for the colon ":" placed after the "$colName" -->
			<xsl:value-of select="substring($spacer,1,$wd - string-length($_colName))"/>
			<!-- Now the value..... -->
			<xsl:value-of select="$colValue"/><xsl:text/>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:text>&#xa;</xsl:text><xsl:text/>	
</xsl:template>

<!-- Duplicate the input string 'n' times -->
<xsl:template name="dup">
	<xsl:param name="input"/>
	<xsl:param name="count" select="1"/>
	<xsl:choose>
		<xsl:when test="not($count) or not($input)"></xsl:when>
		<xsl:when test="$count = 1">
			<xsl:value-of select="$input"/>
		</xsl:when>
		<xsl:otherwise>
			<!-- if count is odd, append an extra copy of input -->
			<xsl:if test="$count mod 2">
				<xsl:value-of select="$input"/>
			</xsl:if>
			<!-- recursively apply template after doubling input -->
			<xsl:call-template name="dup">
				<xsl:with-param name="input" select="concat($input,$input)"/>
				<xsl:with-param name="count" select="floor($count div 2)"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

	<!-- Case-insensitive searches for the occurence of one string within another. These are alternatives
	       to the ~standard~ xslt "substring-before() and substring-after() case-sensitive functions.
	       
	       Note: Contrary to the standard "substring-before() and substring-after()" behaviour, these functions return
	       the input string if the search string is not found (within the input string). substring-before() and substring-after()
	       return an empty (null) string.
	   -->
    <xsl:template name="string-before">
		<xsl:param name="string"/>
		<xsl:param name="find-what"/>
		
		<!-- lower case the string buffer and the search parameter -->
		<xsl:variable name="string-lc" select="translate($string,'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
		<xsl:variable name="find-what-lc" select="translate($find-what,
														'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>

		<!-- search for the occurence of the search-string in the string buffer and return the string that is
		       before it. Use the index of the search-string to "find" it in the original -->
		<xsl:choose>
			<xsl:when test="$find-what-lc != '' and contains($string-lc,$find-what-lc)">
				<xsl:value-of select="substring($string,1,string-length(substring-before($string-lc,$find-what-lc)))"/>
			</xsl:when>
			<!-- search parameter does not occur within the string. Return the original (unlike "null" string for substring-before()) -->
			<xsl:otherwise>
				<xsl:value-of select="$string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="string-after">
		<xsl:param name="string"/>
		<xsl:param name="find-what"/>
		
		<!-- lower case the string buffer and the search parameter -->
		<xsl:variable name="string-lc" select="translate($string,'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>
		<xsl:variable name="find-what-lc" select="translate($find-what,
														'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')"/>

		<!-- search for the occurence of the search-string in the string buffer and return the string that is
		       after it. Use the index of the search-string to "find" it in the original -->
		<xsl:choose>
			<xsl:when test="$find-what-lc != '' and contains($string-lc,$find-what-lc)">
				<xsl:value-of select="substring($string,string-length(substring-before($string-lc,$find-what-lc))+string-length($find-what-lc)+1)"/>
			</xsl:when>
			<!-- search parameter does not occur within the string. Return the original (unlike "null" string for substring-after()) -->
			<xsl:otherwise>
				<xsl:value-of select="$string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
	
