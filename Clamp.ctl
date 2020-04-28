import "ACESlib.Utilities";




void main 
(
  input varying float rIn, 
  input varying float gIn, 
  input varying float bIn,
  input varying float aIn,
  output varying float rOut,
  output varying float gOut,
  output varying float bOut,
  output varying float aOut,
  input uniform float low=0.0,
  input uniform float high=FLT_MAX
)
{
	
// extract out 0-1 range from input that would be MSB justified 0-1
 float RGBFULL[3];
 RGBFULL[0] = rIn;
 RGBFULL[1] = gIn;
 RGBFULL[2] = bIn;

  RGBFULL = clamp_f3( RGBFULL, low, high);
  

  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = RGBFULL[0];
  gOut = RGBFULL[1];
  bOut = RGBFULL[2];
  aOut = aIn;
}
