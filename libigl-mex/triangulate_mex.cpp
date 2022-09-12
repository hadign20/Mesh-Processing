#include "mex.h"

#include <Eigen/Core>
#include <igl/matlab/prepare_lhs.h>
#include <igl/matlab/parse_rhs.h>
#include <igl/triangle/triangulate.h>

void mexFunction(
        int          nlhs,
        mxArray      *plhs[],
        int          nrhs,
        const mxArray *prhs[]
        )
{
    // Triangulate the interior of a polygon using the triangle library.
    //
    // Inputs:
    //   V #V by 2 list of 2D vertex positions
    //   E #E by 2 list of vertex ids forming unoriented edges of the boundary of the polygon
    //   H #H by 2 coordinates of points contained inside holes of the polygon
    //   flags  string of options pass to triangle (see triangle documentation)
    // Outputs:
    //   V2  #V2 by 2  coordinates of the vertives of the generated triangulation
    //   F2  #F2 by 3  list of indices forming the faces of the generated triangulation
    //
    // TODO: expose the option to prevent Steiner points on the boundary
    //
    
    using namespace Eigen;
    
    if (nrhs != 4)
    {
        mexErrMsgIdAndTxt("MATLAB:mexcpp:nargin", "triangulate_mex requires 4 input arguments\n.");
    }
    
    // input polygon
    MatrixXd V;
    MatrixXi E;
    MatrixXd H;
    
    // triangulated interior
    MatrixXd V2;
    MatrixXi F2;
    
    // get matrices
	igl::parse_rhs_double(prhs + 0, V);
	igl::parse_rhs_index(prhs + 1, E);
    igl::parse_rhs_double(prhs + 2, H);

	// Create the boundary of a square
	//V.resize(8, 2);
	//E.resize(8, 2);
	//H.resize(1, 2);

	//V << -1, -1,   1, -1,   1, 1,   -1, 1,	-2, -2,   2, -2,   2, 2,   -2, 2;
	//E << 0, 1, 1, 2, 2, 3, 3, 0, 4, 5, 5, 6, 6, 7, 7, 4;
	//H << 0, 0;
    
    // triangulate the interior
    igl::triangulate(V,E,H,"a0.05q",V2,F2);
        
    // return the matrices to MATLAB
    switch(nlhs)
    {  
		default:
		mexErrMsgIdAndTxt("MATLAB:mexcpp:nargout", "triangulate_mex requires 2 output arguments\n.");
		break;

        case 2:
			igl::prepare_lhs_index(F2, plhs + 1);
		case 1:
			igl::prepare_lhs_double(V2, plhs + 0);
    }
    
    return;
}
