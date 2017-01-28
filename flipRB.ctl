

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
  float RGB[3] = {rIn, gIn, bIn};
  


  rOut = RGB[2];
  gOut = RGB[1];
  bOut = RGB[0];
  //aOut = aIn;
}


