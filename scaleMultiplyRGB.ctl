import "ACESlib.Utilities.a1.0.1";


void main 
(
  input varying float rIn, 
  input varying float gIn, 
  input varying float bIn, 
  output varying float rOut,
  output varying float gOut,
  output varying float bOut,
  input uniform float scaleRED=1.0,
  input uniform float scaleGREEN=1.0,
  input uniform float scaleBLUE=1.0,
  input uniform float CLIP=65535.0
)
{

  rOut = clamp(rIn*scaleRED, 0.0, CLIP);
  gOut = clamp(gIn*scaleGREEN, 0.0, CLIP);
  bOut = clamp(bIn*scaleBLUE, 0.0, CLIP);
  //aOut = aIn;
}
