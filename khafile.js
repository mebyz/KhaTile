var project = new Project('khatile');

project.addSources('src');
project.addShaders('src/Shaders/**');
project.addLibrary('primitive');
project.addLibrary('noisetile');
return project;
