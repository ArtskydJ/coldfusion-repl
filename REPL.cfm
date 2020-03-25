<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<title>ColdFusion REPL</title>
		<style>
			body {
				overflow-y: hidden;
				margin: 0;
			}
			#click-to-focus {
				height: 100vh;
			}
			div#body {
				overflow-y: auto;
				max-height: 100vh;
			}
			pre {
				margin: 0;
			}
			form, .rep {
				margin: 8px;
			}
			.result {
				color: green;
			}
			.error {
				color: red;
			}
			body, input[type="text"] {
				font-family: monospace;
				font-size: 10pt;
			}
			input[type="text"] {
				width: calc(100% - 20px);
				border: none;
				display: inline-block;
				padding: 0;
				margin: 0;
			}
			input[type="text"]:focus {
				outline: none;
			}
			[data-collapsed="1"] {
				display: none;
			}
		</style>
	</head>
	<cfoutput>
		<body>
			<div id="body">
				<cfset allCommands = ''>
				<cfset session_ = isDefined('FORM.session_') ? FORM.session_ : Replace(rand(), '0.', 's')>
				<cfif isDefined('FORM.' & session_)>
					<cfif isDefined('FORM.cmds') AND FORM.cmds NEQ ''>
						<cfset allCommands = FORM.cmds & Chr(10)>
					</cfif>
					<cfset allCommands &= FORM[session_]>
					<cfloop index="command" list="#allCommands#" delimiters="#Chr(10)#">
						<div class="rep">
							<div class="comm">&gt; #XMLFormat(command)#</div>
							<cfif Len(command) GT 0>
								<cftry>
									<cfset command = ReReplace(command, '\{\w*\}', 'structNew()', 'ALL')>
									<cfset command = ReReplace(command, '\[\w*\]', 'arrayNew(1)', 'ALL')>
									<cfset result = Evaluate(command)>
									<cfif isValid('string', result)>
										<cfset result = XMLFormat(result)> <!--- escape HTML --->
									</cfif>
									<div class="result">
										<cfdump var="#IsDefined('result') ? result : '[undefined]'#" expand="yes" format="text" top="5">
									</div>
									<cfcatch>
										<div class="error">
											ERROR: #cfcatch.message#
											<button type="button" onclick="show(this)">▬§¶‼v↕↕◄show details</button>
										</div>
										<div data-collapsed="1"><cfdump var="#cfcatch#"></div>
									</cfcatch>
								</cftry>
							</cfif>
						</div>
					</cfloop>
				</cfif>
				<form method="post">
					<input type="hidden" name="cmds" value="#ReReplace(allCommands, '"', '&quot;', 'ALL')#">
					<input type="hidden" name="session_" value="#session_#">
					&gt; <input type="text" name="#session_#" required autofocus autocomplete="off">
				</form>
			</div>
			<div id="click-to-focus"></div>
			<script>
				function focusTextInput() {
					document.querySelector('input[type="text"]').focus()
				}
				document.onkeydown = function (e) {
					if (!e.ctrlKey) focusTextInput()
				}
				document.getElementById('click-to-focus').onclick = focusTextInput

				var allCommands = `#Replace(allCommands, '\', '\\', 'all')#`.split('\n').filter(a => a !== '')
				var cmdIndex = allCommands.length
				document.querySelector('input[type="text"]').onkeydown = function(e) {
					if (e.key === 'ArrowUp' || e.key === 'ArrowDown') {
						cmdIndex += (e.key === 'ArrowUp') ? -1 : 1
						cmdIndex = Math.min(allCommands.length, Math.max(0, cmdIndex))
						e.srcElement.value = allCommands[cmdIndex] || ''

						e.preventDefault()
					}
				}

				function show(self) {
					var errorDetail = self.parentNode.nextElementSibling
					var isCollapsed = !!(+errorDetail.dataset.collapsed)
					errorDetail.dataset.collapsed = isCollapsed ? 0 : 1
					self.innerHTML = (isCollapsed ? 'hide' : 'show') + ' details'
				}
			</script>
		</body>
	</cfoutput>
</html>
<cfabort>
