

// 
// Convert PQ to Gamma
//




import "ACESlib.Utilities";
import "ACESlib.Transform_Common";


const float R2020_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(REC2020_PRI,1.0);
const float XYZ_2_R2020_PRI_MAT[4][4] = XYZtoRGB(REC2020_PRI,1.0);



void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    input uniform float CLIP=10000.0,
    input uniform float BLACK=0.05    
)
{
	
    float PQ[3] = { rIn, gIn, bIn};

  // Decode with inverse PQ transfer function
    float linearCV[3] = ST2084_2_Y_f3( PQ);
    

  
	 linearCV[0] = (linearCV[0]+BLACK)*(10000.0 - BLACK)/10000.0;
	 linearCV[1] = (linearCV[1]+BLACK)*(10000.0 - BLACK)/10000.0;
	 linearCV[2] = (linearCV[2]+BLACK)*(10000.0 - BLACK)/10000.0;
	 


    linearCV = clamp_f3( linearCV, 0., CLIP);
    
    // encode to PQ
     float outputCV[3] = Y_2_ST2084_f3( linearCV);


    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];      
}









