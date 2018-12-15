

// 
// Convert XYZ to P3D65
//




import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.ODT_Common";
import "ACESlib.Tonescales";



/* --- ODT Parameters --- */
const Chromaticities DISPLAY_PRI = P3D65_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(P3D65_PRI,1.0);



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
	
    float XYZ[3] = { rIn, gIn, bIn};

    
    // Convert from XYZ to P3D65 primaries
    float linearCV[3] = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);    

    
    float outputCV[3] = clamp_f3( linearCV, 0., CLIP);
    


    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];      
}









