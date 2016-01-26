var project = new Project('khatile');

project.addSources('src');
project.addShaders('src/Shaders/**');
project.addAssets('Assets/**');
project.addLibrary('primitive');
project.addLibrary('noisetile');
return project;
