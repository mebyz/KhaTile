var project = new Project('Empty');

project.addSources('Sources');
project.addLibrary('primitive');
project.addLibrary('noisetile');
project.addLibrary('instances');
project.addLibrary('colyseus-websocket');
project.addLibrary('colyseus');
project.addShaders('Sources/Shaders/**');
project.addAssets('Assets/**');
project.addAssets('Libraries/instances/Sources/Assets/**');
project.addDefine('kha_html5_disable_automatic_size_adjust');
await project.addProject("Subprojects/koui");
await project.addProject("Subprojects/aura");
if (process.argv.includes("--watch")) { // run only in watch mode
	project.targetOptions.html5.unsafeEval = true; // allow eval in electron
	let libPath = project.addLibrary('hotml'); // client code for code-patching
	project.addDefine('js_classic'); // to support constructors patching, optional
	// start websocket server that will send type diffs to client
	const path = require('path');
	if (!libPath) libPath = path.resolve('./Libraries/hotml');
	const Server = require(`${libPath}/bin/server.js`).hotml.server.Main;
	// path to target build folder and main js file.
	const server = new Server(`${path.resolve('.')}/build/${platform}`, 'kha.js');
	callbacks.postHaxeRecompilation = () => {
		server.reload(); // parse js file every compilation
	}
	// for assets reloading
	callbacks.postAssetReexporting = (path) => {
		server.reloadAsset(path);
	}
}
resolve(project);
