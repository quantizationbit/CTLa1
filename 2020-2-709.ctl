

import "ACESlib.Utilities";
import "ACESlib.Transform_Common";



const float XYZ_2_709_PRI_MAT[4][4] = XYZtoRGB(REC709_PRI,1.0);
const float R2020_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(REC2020_PRI,1.0);


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
  // Put input variables (OCES) into a 3-element vector
  float R2020[3] = {rIn, gIn, bIn};
  

// convert from P3 to XYZ
     float XYZ[3] = mult_f3_f44( R2020, R2020_PRI_2_XYZ_MAT);
    // Convert from XYZ to ACES primaries
    float R709[3] = mult_f3_f44( XYZ, XYZ_2_709_PRI_MAT);

  rOut = R709[0];
  gOut = R709[1];
  bOut = R709[2];
  //aOut = aIn;
}


