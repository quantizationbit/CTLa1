import "ACESlib.Utilities";

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

 float RGB[3];
 RGB[0] = rIn;
 RGB[1] = gIn;
 RGB[2] = bIn;
 RGB = clamp_f3( RGB, 0.0, HALF_MAX);
 
  rOut = RGB[0];
  gOut = RGB[1];
  bOut = RGB[2];
  //aOut = aIn;
}
