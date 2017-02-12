

// 
// Convert PQ to Gamma
//




import "ACESlib.Utilities";
import "ACESlib.Transform_Common";


const Chromaticities P3D65_PRI =
{
  { 0.68000,  0.32000},
  { 0.26500,  0.69000},
  { 0.15000,  0.06000},
  { 0.31270,  0.32900}
};


const float L_W = 1.0;
const float L_B = 0.0;

const float XYZ_2_P3_PRI_MAT[4][4] = XYZtoRGB(P3D65_PRI,1.0);
const float XYZ_2_R2020_PRI_MAT[4][4] = XYZtoRGB(REC2020_PRI,1.0);
const float R2020_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(REC2020_PRI,1.0);
const float P3_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(P3D65_PRI,1.0);


void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    input uniform float CLIP=10000.0    
)
{
	
    float PQ[3] = { rIn, gIn, bIn};

  // Decode with inverse PQ transfer function
    float linearCV[3] = ST2084_2_Y_f3( PQ);
    
  // convert from 2020 to XYZ
     float XYZ[3] = mult_f3_f44( linearCV, R2020_PRI_2_XYZ_MAT);
    // Convert from XYZ to 709 primaries
    linearCV = mult_f3_f44( XYZ, XYZ_2_P3_PRI_MAT);    

    
    linearCV = clamp_f3( linearCV, 0., CLIP);
    
  // multiply back to 2020
    // convert from P3 to XYZ
     XYZ = mult_f3_f44( linearCV, P3_PRI_2_XYZ_MAT);
    // Convert from XYZ to 2020 primaries
    linearCV = mult_f3_f44( XYZ, XYZ_2_R2020_PRI_MAT);    
    linearCV = clamp_f3( linearCV, 0., CLIP);
    
    // encode to PQ
  
    float outputCV[3] = Y_2_ST2084_f3( linearCV);


    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];      
}









