#include "mex.h"

#include <Eigen/Core>
#include <Eigen/Sparse>
//#include <igl/per_vertex_normals.h>
//#include <igl/per_face_normals.h>
//#include <igl/per_corner_normals.h>
#include <igl/cotmatrix.h>
#include <igl/massmatrix.h>
#include <igl/matlab/prepare_lhs.h>
#include <igl/matlab/parse_rhs.h>


void prepare_lhs_sparse(
	const Eigen::SparseMatrix<double> &M, mxArray *plhs[])
{
	using namespace std;
	//plhs[0] = mxCreateDoubleMatrix(V.rows(), V.cols(), mxREAL)
	plhs[0] = mxCreateSparse(V.rows(), V.cols(), V.size(), mxREAL);
	
	// output matrix
	double* Vp = mxGetPr(plhs[0]);
	
	for (unsigned k = 0; k<(unsigned)M.outerSize(); ++k)
	{
		for (Eigen::SparseMatrix<double>::InnerIterator it(M, k); it; ++it)
		{
			T(count, 0) = it.row();
			T(count, 1) = it.col();
			T(count, 2) = it.value();
			++count;
		}
	}

}


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
			"compLaplacian requires 1 input arguments, the path of the file to open");
	}

	Eigen::MatrixXd V;
	Eigen::MatrixXi F;

	VectorXd dblA;
	Eigen::SparseMatrix<double> L;

	// get matrices
	igl::parse_rhs_double(prhs, 0, V);
	igl::parse_rhs_index(prhs, 1, F);

	// Return the matrices to matlab
	switch (nlhs)
	{
	case 2:
		
		igl::doublearea(V, F, dblA);
		igl::prepare_lhs_double(V, plhs + 1);
	case 1:				
		igl::cotmatrix(V, F, L);
		prepare_lhs_sparse(L, plhs);
	default:
		break;
	}


	
	// Alternative construction of same Laplacian
	//SparseMatrix<double> G, K;
	// Gradient/Divergence
	//igl::grad(V, F, G);
	// Diagonal per-triangle "mass matrix"
	//VectorXd dblA;
	//igl::doublearea(V, F, dblA);


	//// Return the matrices to matlab
	//switch(nlhs)
	//{
	//case 4:
	// // Compute per-face normals
	// igl::per_face_normals(V, F, N_faces);
	// N_faces.rowwise().normalize();
	// igl::prepare_lhs_double(N_faces, plhs + 3);

	//case 3:
	// // Compute per-vertex normals
	// igl::per_vertex_normals(V, F, N_vertices);
	// N_vertices.rowwise().normalize();
	// igl::prepare_lhs_double(N_vertices, plhs + 2);

	// // Compute per-corner normals, |dihedral angle| > 20 degrees --> crease
	// //igl::per_corner_normals(V, F, 20, N_corners);
	// 	  
	//  case 2:
	//    igl::prepare_lhs_index(F,plhs+1);
	//  case 1:
	//    igl::prepare_lhs_double(V,plhs);
	//  default: 
	//break;
	//}

	return;
}
