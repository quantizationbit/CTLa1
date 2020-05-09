

// 
// Convert PQ to Gamma
//




import "ACESlib.Utilities";
import "ACESlib.Transform_Common";


const float R2020_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(REC2020_PRI,1.0);



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
    
     float XYZ[3] = mult_f3_f44( linearCV, R2020_PRI_2_XYZ_MAT);
  
  if (XYZ[1] <= BLACK) {
	  linearCV[0] = linearCV[0] + BLACK;
	  linearCV[1] = linearCV[1] + BLACK;
	  linearCV[2] = linearCV[2] + BLACK;
  }
    
    // encode to PQ
  
    float outputCV[3] = Y_2_ST2084_f3( linearCV);


    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];      
}









