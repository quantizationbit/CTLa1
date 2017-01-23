

import "ACESlib.Utilities";
import "ACESlib.Transform_Common";




void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    output varying float rOut,
    output varying float gOut,
    output varying float bOut
)
{
  float rgb[3] = {rIn, gIn, bIn};

  // Encode with PQ transfer function
    float outputCV[3] = Y_2_ST2084_f3( rgb);
  
    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];
}


