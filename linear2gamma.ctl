

// 
// Convert Gamma to linear
//

import "ACESlib.Utilities_Color";


// colorSpace 709D65 ==0, P3D65 == 1, 2020D65 == 2

void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    input uniform float gamma=2.4,
    input uniform unsigned int  colorSpace = 0
)
{

 float linearCV[3] = { 
	 bt1886_r(rIn, gamma, 100.0, 0.0), 
	 bt1886_r(gIn, gamma, 100.0, 0.0), 
	 bt1886_r(bIn, gamma, 100.0, 0.0)};



 rOut = linearCV[0];
 gOut = linearCV[1];
 bOut = linearCV[2];      
}

