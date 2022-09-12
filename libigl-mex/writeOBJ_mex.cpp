#include "mex.h"

#include <Eigen/Core>
#include <igl/writeOBJ.h>
#include <igl/matlab/parse_rhs.h>


void mexFunction(
        int          nlhs,
        mxArray      *plhs[],
        int          nrhs,
        const mxArray *prhs[]
        )
{
    using namespace Eigen;
    /* Check for proper number of arguments */
    
    if (nrhs != 3)
    {
        mexErrMsgIdAndTxt("MATLAB:mexcpp:nargin",
                "writeOBJ requires 3 input arguments: filename, vertices, faces");
    }
    
    // write to the file path
    char* file_path = mxArrayToString(prhs[0]);
    
    // matrices for positions and faces
    MatrixXd V;
    MatrixXi F;
    
    // get matrices
    igl::parse_rhs_double(prhs + 1, V);
    igl::parse_rhs_index(prhs + 2, F);
    
    // write the mesh
    if(!igl::writeOBJ(file_path,V,F))
    {
        mexErrMsgIdAndTxt("MATLAB:mexcpp:fileio", "igl::writeOBJ failed.");
    }
    
    return;
}
