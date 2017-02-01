

// 
// Convert 2020D65 to P3D60 using D60 sim (not CAT)
//




import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.ODT_Common";
import "ACESlib.Tonescales";



/* --- ODT Parameters --- */
const Chromaticities DISPLAY_PRI = P3D60_PRI;
const float R2020_PRI_2_XYZ_MAT[4][4]   = RGBtoXYZ(REC2020_PRI,1.0);
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(P3D60_PRI,1.0);



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
	
    float linearCV[3] = { rIn, gIn, bIn};

    
    // convert from 2020 to XYZ
    float XYZ[3] = mult_f3_f44( linearCV, R2020_PRI_2_XYZ_MAT);

    // Apply CAT from assumed observer adapted white to ACES white point
    XYZ = mult_f3_f33( XYZ, invert_f33( D60_2_D65_CAT));


    // Convert from XYZ to P3D60 primaries
    linearCV = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);    

    
    float outputCV[3] = clamp_f3( linearCV, 0., CLIP);
    


    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];      
}









