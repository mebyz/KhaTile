var project = new Project('khatile');

project.addSources('src');
project.addShaders('src/Shaders/**');
project.addLibrary('primitive');
return project;
