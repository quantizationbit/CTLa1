//import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities";


void main 
(
  input varying float rIn, 
  input varying float gIn, 
  input varying float bIn, 
  output varying float rOut,
  output varying float gOut,
  output varying float bOut,
  input uniform float min=0.0,
  input uniform float max=10000.0,
  input uniform float scaleBLUE=1.0,
  input uniform float CLIP=65535.0
)
{

  rOut = clamp((max/(max-min))*(rIn-min), 0.0, CLIP);
  gOut = clamp((max/(max-min))*(gIn-min), 0.0, CLIP);
  bOut = clamp((max/(max-min))*(bIn-min), 0.0, CLIP);
  //aOut = aIn;
}
