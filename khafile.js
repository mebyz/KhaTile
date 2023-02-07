var project = new Project('Empty');

project.addSources('Sources');
project.addLibrary('primitive');
project.addLibrary('noisetile');
project.addLibrary('instances');
project.addLibrary('colyseus');
project.addShaders('Sources/Shaders/**');
project.addAssets('Assets/**');
project.addAssets('Libraries/instances/Sources/Assets/**');
await project.addProject("Subprojects/Koui");
await project.addProject("Subprojects/aura");
resolve(project);