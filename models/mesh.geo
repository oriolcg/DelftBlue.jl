// Gmsh project created on Fri Mar  5 16:43:06 2021
SetFactory("OpenCASCADE");
// [VARIABLES]
// settings for number of mesh points per line
Nx1 = 31; Rx1 = 1.00;		// line segment x: 0.295 to 0.705
Nx2 = 81; Rx2 = 1.00;		// line segment x: 0.705 to 2.5
Nx3 = 21; Rx3 = 1.00;		// line segment x: 0 to 0.295
Ny1 = 31; Ry1 = 1.00;		// line segment y: 0 to 0.41
Ni  = 31; Ri  = 0.96;		// line segment 4 diagonal lines to cylinder
Nc  = 31; Rc  = 1.00;		// line segment 4 sections of cylinder
Nz1 = 31;			// z direction mesh points

// [POINTS]
// 4 points x line: y=0
Point(1) = {0, 0, 0, 1.0};
Point(2) = {0.295, 0, 0, 1.0};
Point(3) = {0.705, 0, 0, 1.0};
Point(4) = {2.5, 0, 0, 1.0};
// 4 points on cylinder circle
Point(5) = {0.464644660941, 0.164644660941, 0, 1.0};
Point(6) = {0.53535533906, 0.164644660941, 0, 1.0};
Point(7) = {0.464644660941, 0.23535533906, 0, 1.0};
Point(8) = {0.53535533906, 0.23535533906, 0, 1.0};
// 4 points x line: y=0.41
Point(9) = {0, 0.41, 0, 1.0};
Point(10) = {0.295, 0.41, 0, 1.0};
Point(11) = {0.705, 0.41, 0, 1.0};
Point(12) = {2.5, 0.41, 0, 1.0};
// center of cylinder
Point(13) = {0.5, 0.2, 0, 1.0};

// [LINES]
// 3 x line segments: y=0
Line(1) = {1, 2};  Transfinite Line {1}  = Nx3 Using Progression Rx3;
Line(2) = {2, 3};  Transfinite Line {2}  = Nx1 Using Progression Rx1;
Line(3) = {3, 4};  Transfinite Line {3}  = Nx2 Using Progression Rx2;
// 3 x line segments: y=0.41
Line(4) = {9, 10};  Transfinite Line {4}  = Nx3 Using Progression Rx3;
Line(5) = {10, 11};  Transfinite Line {5}  = Nx1 Using Progression Rx1;
Line(6) = {11, 12}; Transfinite Line {6}  = Nx2 Using Progression Rx2;
// 4 y line segments: x=0, x=0.295, x=0.705, x=2.5
Line(7) = {1, 9}; Transfinite Line {7} = Ny1 Using Bump Ry1;
Line(8) = {2, 10}; Transfinite Line {8} = Ny1 Using Bump Ry1;
Line(9) = {3, 11}; Transfinite Line {9} = Ny1 Using Bump Ry1;
Line(10) = {4, 12}; Transfinite Line {10} = Ny1 Using Bump Ry1;
// 4 diagonal lines to cylinder
Line(11) = {2, 5};  Transfinite Line {11}  = Ni Using Progression Ri;
Line(12) = {3, 6};  Transfinite Line {12}  = Ni Using Progression Ri;
Line(13) = {11, 8};  Transfinite Line {13}  = Ni Using Progression Ri;
Line(14) = {10, 7};  Transfinite Line {14}  = Ni Using Progression Ri;
// 4 line segments on cylinder
Circle(15) = {5, 13, 6}; Transfinite Line {15} = Nc Using Progression Rc;
Circle(16) = {6, 13, 8}; Transfinite Line {16} = Nc Using Progression Rc;
Circle(17) = {8, 13, 7}; Transfinite Line {17} = Nc Using Progression Rc;
Circle(18) = {7, 13, 5}; Transfinite Line {18} = Nc Using Progression Rc;

// [SURFACES]
// surface 1: x=0 to 0.295; y=0 to 0.41
Line Loop(19) = {1, 8, -4, -7};
Plane Surface(20) = {19};
// surface 2: x=0.295 to 0.705; y=0; diagonal line + bottom cylinder line + diagonal line
Line Loop(21) = {2, 12, -15, -11};
Plane Surface(22) = {21};
// surface 3: x=0.705; y=0 to 0.41; diagonal line + right cylinder line + diagonal line
Line Loop(23) = {12, 16, -13, -9};
Plane Surface(24) = {23};
// surface 4: x=0.295 to 0.705; y=0.41; diagonal line + top cylinder line + diagonal line
Line Loop(25) = {13, 17, -14, 5};
Plane Surface(26) = {25};
// surface 5: x=0.295; y=0 to 0.41; diagonal line + left cylinder line + diagonal line
Line Loop(27) = {14, 18, -11, 8};
Plane Surface(28) = {27};
// surface 6: x=0.705 to 2.5; y=0 to 0.41
Line Loop(29) = {3, 10, -6, -9};
Plane Surface(30) = {29};
// setting up transfinite surfaces for meshing
Transfinite Surface {20};
Transfinite Surface {22};
Transfinite Surface {24};
Transfinite Surface {26};
Transfinite Surface {28};
Transfinite Surface {30};
// recmobining the surfaces
Recombine Surface {20};
Recombine Surface {22};
Recombine Surface {24};
Recombine Surface {26};
Recombine Surface {28};
Recombine Surface {30};
// extrude to build 3D mesh
Extrude {0, 0, 0.41} {
  Surface{20, 22, 24, 26, 28, 30};
  Layers{Nz1};
  Recombine;
}
// set up physical boundary surfaces and physical volume ("internal" in OpenFOAM)
Physical Surface("inlet") = {34}; // inlet
Physical Surface("outlet") = {52}; // outlet
Physical Surface("sides") = {20, 22, 24, 26, 28, 30, 35, 50, 40, 44, 48, 54, 33, 47, 53, 31, 36, 51}; // sides
Physical Surface("cylinder") = {49, 45, 41, 38}; // cylinder
Physical Volume("internal") = {1, 2, 3, 4, 5, 6}; // internal 
