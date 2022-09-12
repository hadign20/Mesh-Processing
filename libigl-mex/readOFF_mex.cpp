#include "mex.h"

#include <Eigen/Core>
#include <igl/readOFF.h>
#include <igl/per_vertex_normals.h>
#include <igl/matlab/prepare_lhs.h>


void mexFunction(
     int          nlhs,
     mxArray      *plhs[],
     int          nrhs,
     const mxArray *prhs[]
     )
{
  using namespace Eigen;
  /* Check for proper number of arguments */

  if (nrhs != 1) 
  {
    mexErrMsgIdAndTxt("MATLAB:mexcpp:nargin",
        "readOBJ requires 1 input arguments, the path of the file to open");
  }

  // Read the file path
  char* file_path = mxArrayToString(prhs[0]);

  MatrixXd V;
  MatrixXi F;
  
  MatrixXd N_vertices;
  MatrixXd N_faces;

  // Read the mesh
  if(!igl::readOFF(file_path,V,F))
  {
    mexErrMsgIdAndTxt("MATLAB:mexcpp:fileio", "igl::readOBJ failed.");
  }

  // Return the matrices to matlab
  switch(nlhs)
  {
    case 4:
	  // Compute per-face normals
	  igl::per_face_normals(V, F, N_faces);
	  N_faces.rowwise().normalize();
	  igl::prepare_lhs_double(N_faces, plhs + 3);

    case 3:
	  // Compute per-vertex normals
	  igl::per_vertex_normals(V, F, N_vertices);
	  N_vertices.rowwise().normalize();
	  igl::prepare_lhs_double(N_vertices, plhs + 2);
	 
    case 2:
      igl::prepare_lhs_index(F,plhs+1);
    case 1:
      igl::prepare_lhs_double(V,plhs);
    default: 
		break;
  }

  return;
}
