var project = new Project('Empty');

project.addSources('Sources');
project.addLibrary('primitive');
project.addLibrary('noisetile');
project.addShaders('Sources/Shaders/**');
project.addAssets('Assets/**');
project.addLibrary('primitive');
project.addLibrary('noisetile');
project.addLibrary('instances');
project.addAssets('Libraries/instances/Sources/Assets/**');

return project;
