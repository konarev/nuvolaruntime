/*
 * Copyright 2014 Jiří Janoušek <janousek.jiri@gmail.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: 
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution. 
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

require("prototype");
require("signals");

/**
 * Class to manage Nuvola Player Core
 */
var Core = $prototype(null, SignalsMixin);

Core.$init = function()
{
	/** 
	 * @signal init-app-runner     initialize app runner process hook
	 * 
	 * This signal is emitted at start-up when initialization of the app runner process is needed.
	 * You can use it to append entries to initialization form (e. g. preferred national variant
	 * or address of custom service instance) and to perform own initialization routine.
	 * 
	 * @param Object initValues    initialization values to fill the initialization form with
	 * @param Array formSpec       specification of entries to show in the initialization form
	 */
	this.addSignal("init-app-runner");
	
	/** 
	 * @signal init-web-worker     initialize web worker process hook
	 * 
	 * This signal is emitted just before a web page is loaded in the main frame of the web view.
	 */
	this.addSignal("init-web-worker");
	
	this.registerSignals(["home-page", "navigation-request", "uri-changed", "last-page", "append-preferences"]);
}

Core.setHideOnClose = function(hide)
{
	return Nuvola._sendMessageSync("Nuvola.setHideOnClose", hide);
}

// export public items
Nuvola.CorePrototype = Core;
Nuvola.Core = $object(Core);
