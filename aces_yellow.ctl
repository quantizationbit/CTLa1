


import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.ODT_Common";
import "ACESlib.Tonescales";


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
    input uniform float yellow = 1.0
)
{
    float rgb[3] = { rIn, gIn, bIn};
    float XYZ[3] = mult_f3_f44(rgb, RGBtoXYZ(AP0,1.0));
    
    if(yellow < 0.0) {

      XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);
      
    }
    
    if(yellow > 0.0) {
	
      XYZ = mult_f3_f33( XYZ, invert_f33( D60_2_D65_CAT));

	}
	
	
	rgb = mult_f3_f44(XYZ, XYZtoRGB(AP0,1.0));
	
	rOut = rgb[0];
    gOut = rgb[1];
    bOut = rgb[2];
    aOut = aIn;
}
