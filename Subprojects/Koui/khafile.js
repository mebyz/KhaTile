let project = new Project("Koui");

project.addAssets("Assets/theme.ksn");
project.addAssets("Assets/Montserrat-Bold.ttf");
project.addAssets("Assets/Montserrat-Italic.ttf");
project.addAssets("Assets/Montserrat-Regular.ttf");
project.addSources("Sources");
project.addShaders("Shaders/**");

resolve(project);
