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
resolve(project);
