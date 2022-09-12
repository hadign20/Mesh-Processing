load_paths();
close all;
mesh_viewer = MeshViewerUI();
mesh_viewer.loadModel('data/cube_1.obj');
cameratoolbar;
cameratoolbar('SetMode','orbit');
clear mesh_viewer;