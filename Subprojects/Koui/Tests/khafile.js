let project = new Project('Tests');

project.addSources(".");
project.addLibrary("utest");
await project.addProject("../");

project.addCDefine("KINC_NO_WAYLAND"); // Causes errors in the CI

// For higher build test coverage
project.addDefine("KOUI_DEBUG_LAYOUT");

// project.addDefine("UTEST_PRINT_TESTS");

resolve(project);
