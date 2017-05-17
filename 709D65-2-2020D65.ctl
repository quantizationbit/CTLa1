//  709 D65 to P3 D65
//  Full range input/output



import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.ODT_Common";
import "ACESlib.Tonescales";



const float XYZ_2_2020D65_PRI_MAT[4][4] = XYZtoRGB(REC2020_PRI,1.0);
const float R709_PRI_2_XYZ_MAT[4][4]  = RGBtoXYZ(REC709_PRI,1.0);


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
  float source[3] = {rIn, gIn, bIn};
  


// convert from P3 to XYZ
     float XYZ[3] = mult_f3_f44( source, R709_PRI_2_XYZ_MAT);
    // Convert from XYZ to ACES primaries
    float dest[3] = mult_f3_f44( XYZ, XYZ_2_2020D65_PRI_MAT);

  rOut = dest[0];
  gOut = dest[1];
  bOut = dest[2];
  //aOut = aIn;
}


