

// 
// Convert PQ to linear
//




import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Transform_Common.a1.0.1";
import "ACESlib.ODT_Common.a1.0.1";
import "ACESlib.Tonescales.a1.0.1";




const float L_W = 1.0;
const float L_B = 0.0;



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
    input uniform float CLIP=10000.0
)
{
	
    float PQ[3] = { rIn, gIn, bIn};

  // Decode with inverse PQ transfer function
    float linearCV[3] = ST2048_2_Y_f3( PQ);

    
  // Clip range 
    linearCV = clamp_f3( linearCV, 0., CLIP);
  
  


    rOut = linearCV[0];
    gOut = linearCV[1];
    bOut = linearCV[2];      
    aOut = aIn;
}
