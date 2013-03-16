<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2006/xpath-functions"
	version="2.0">

	<!--
		Licensed to the Apache Software Foundation (ASF) under one or more
		contributor license agreements. See the NOTICE file distributed with
		this work for additional information regarding copyright ownership.
		The ASF licenses this file to You under the Apache License, Version
		2.0 (the "License"); you may not use this file except in compliance
		with the License. You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0 Unless required by
		applicable law or agreed to in writing, software distributed under the
		License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
		CONDITIONS OF ANY KIND, either express or implied. See the License for
		the specific language governing permissions and limitations under the
		License.
	-->

	<!--
		Stylesheet for processing 2.1 output format test result files To uses
		this directly in a browser, add the following to the JTL file as line
		2: <?xml-stylesheet type="text/xsl"
		href="../extras/jmeter-results-detail-report_21.xsl"?> and you can
		then view the JTL in a browser
	-->

	<xsl:output method="xml" indent="yes" encoding="US-ASCII"/>


	<!-- Defined parameters (overrideable) -->
	<xsl:param name="showData" select="'n'" />


	<xsl:template match="testResults">
	<root>
<xsl:call-template name="summary" />
					<xsl:call-template name="create-pagelist" />
</root>
	</xsl:template>
<xsl:template name="summary">

			<summary>
				<xsl:variable name="allCount" select="count(/testResults/*)" />
			<xsl:variable name="allFailureCount" select="count(/testResults/*[attribute::s='false'])" />
			<xsl:variable name="allSuccessCount" select="count(/testResults/*[attribute::s='true'])" />
			<xsl:variable name="allSuccessPercent" select="$allSuccessCount div $allCount" />
			<xsl:variable name="allTotalTime" select="sum(/testResults/*/@t)" />
			<xsl:variable name="allAverageTime" select="$allTotalTime div $allCount" />
			<xsl:variable name="allMinTime">
				<xsl:call-template name="min">
					<xsl:with-param name="nodes" select="/testResults/*/@t" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="allMaxTime">
				<xsl:call-template name="max">
					<xsl:with-param name="nodes" select="/testResults/*/@t" />
				</xsl:call-template>
			</xsl:variable>

				<allCount>
					<xsl:value-of select="$allCount" />
				</allCount>
				<allFailureCount>
					<xsl:value-of select="$allFailureCount" />
				</allFailureCount>
				<allSuccessPercent>
					<xsl:call-template name="display-percent">
						<xsl:with-param name="value" select="$allSuccessPercent" />
					</xsl:call-template>
				</allSuccessPercent>
				<allAverageTime>
					<xsl:call-template name="display-time">
						<xsl:with-param name="value" select="$allAverageTime" />
					</xsl:call-template>
				</allAverageTime>
				<allMinTime>
					<xsl:call-template name="display-time">
						<xsl:with-param name="value" select="$allMinTime" />
					</xsl:call-template>
				</allMinTime>
				<allMaxTime>
					<xsl:call-template name="display-time">
						<xsl:with-param name="value" select="$allMaxTime" />
					</xsl:call-template>
				</allMaxTime>
		</summary>
	</xsl:template>


	<xsl:template name="create-pagelist">

			<xsl:for-each
				select="/testResults/*[not(@lb = preceding::*/@lb) and not(contains(@lb , '.jpg') or contains(@lb, '.png') or contains(@lb, '.gif') or contains(@lb, '.css') or contains(@lb, '.js') or contains(@lb , '.JPG') or contains(@lb, '.PNG') or contains(@lb, '.GIF') or contains(@lb, '.CSS') or contains(@lb, '.JS'))]">
				<xsl:variable name="uniqueLabel" select="@lb"/>

				<uniquelist><xsl:attribute name="lb"><xsl:value-of select="@lb" /></xsl:attribute>

				<xsl:for-each select="/testResults/*">
					<xsl:if test="starts-with(@lb, $uniqueLabel)">
						<value>
							<xsl:attribute name="lb"><xsl:value-of select="@lb" /></xsl:attribute>
							<xsl:attribute name="t"><xsl:value-of select="@t"/></xsl:attribute>
							<xsl:attribute name="ts"><xsl:value-of select="@ts"/></xsl:attribute>
							<xsl:attribute name="s"><xsl:value-of select="@s"/></xsl:attribute>
							<xsl:attribute name="tn"><xsl:value-of select="@tn"/></xsl:attribute>
							<xsl:attribute name="by"><xsl:value-of select="@by"/></xsl:attribute>
							<xsl:attribute name="rc"><xsl:value-of select="@rc"/></xsl:attribute>
							<xsl:attribute name="rs"><xsl:value-of select="@rs"/></xsl:attribute>
							<xsl:attribute name="rm"><xsl:value-of select="@rm"/></xsl:attribute>
							<assertionResult>
								<name><xsl:value-of select="assertionResult/name" /></name>
								<failure><xsl:value-of select="assertionResult/failure" /></failure>
								<error><xsl:value-of select="assertionResult/error" /></error>
								<failureMessage><xsl:value-of select="assertionResult/failureMessage" /></failureMessage>
							</assertionResult>
							<responseHeader><xsl:value-of select="responseHeader" /></responseHeader>
							<requestHeader><xsl:value-of select="requestHeader" /></requestHeader>
							<responseData><xsl:value-of select="responseData" /></responseData>
							<responseFile><xsl:value-of select="responseFile" /></responseFile>
							<cookies><xsl:value-of select="cookies" /></cookies>
							<method><xsl:value-of select="method" /></method>
							<queryString><xsl:value-of select="queryString" /></queryString>
							<java.net.URL><xsl:value-of select="java.net.URL" /></java.net.URL>
							<binary><xsl:value-of select="binary" /></binary>
						</value>
					</xsl:if>
				</xsl:for-each>
				</uniquelist>

			</xsl:for-each>

	</xsl:template>


	<xsl:template name="min">
		<xsl:param name="nodes" select="/.." />
		<xsl:choose>
			<xsl:when test="not($nodes)">
				NaN
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$nodes">
					<xsl:sort data-type="number" />
					<xsl:if test="position() = 1">
						<xsl:value-of select="number(.)" />
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="max">
		<xsl:param name="nodes" select="/.." />
		<xsl:choose>
			<xsl:when test="not($nodes)">
				NaN
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$nodes">
					<xsl:sort data-type="number" order="descending" />
					<xsl:if test="position() = 1">
						<xsl:value-of select="number(.)" />
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="display-percent">
		<xsl:param name="value" />
		<xsl:value-of select="format-number($value,'0.00%')" />
	</xsl:template>

	<xsl:template name="display-time">
		<xsl:param name="value" />
		<xsl:value-of select="format-number($value,'0 ms')" />
	</xsl:template>

</xsl:stylesheet>
