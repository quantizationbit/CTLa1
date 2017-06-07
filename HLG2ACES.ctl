

// 
// Convert PQ to Hybrid Gamma Log
//

import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.ODT_Common";
import "ACESlib.Tonescales";


import "HLG";


const float R2020_PRI_2_XYZ_MAT[4][4]   = RGBtoXYZ(REC2020_PRI,1.0);
const float P3_PRI_2_XYZ_MAT[4][4]   = RGBtoXYZ(P3D65_PRI,1.0);
const float R709_PRI_2_XYZ_MAT[4][4]   = RGBtoXYZ(REC709_PRI,1.0);
const float XYZ_2_AP0_PRI_MAT[4][4] = XYZtoRGB(AP0,1.0);



// colorSpace 709D65 ==0, P3D65 == 1, 2020D65 == 2

void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    input uniform float LRefDisplay=1000.0,
    input uniform float Lb = 0.0,
    input uniform float graphicsWhite = 0.75,
    input uniform float pct18 = 0.38,
    input uniform float pct18scale = 2.6,
    input uniform unsigned int  colorSpace = 2
)
{

 float linearCV[3] = { rIn, gIn, bIn};


 // Input Data from 0.0-1.0
 // (HLG input is [0:1])
 // linear output is [0:12] but will be scaled so that
 // graphics white is 1.0
 // Note DPP document:
 // https://dpp-assets.s3.amazonaws.com/wp-content/uploads/2017/03/DPPHDRSupplement.pdf
 //
 
 // OETF^-1:
 linearCV[0] = HLG_f( linearCV[0]);
 linearCV[1] = HLG_f( linearCV[1]);
 linearCV[2] = HLG_f( linearCV[2]);
  // now have scene linear light from [0-12] in linearCV[]
 
 // these values will be from [0-12]
 float aces75 = HLG_f(graphicsWhite);
 float aces18 = HLG_f(pct18);
 
 //
 // Scale linear so that aces75 is at 1.0 or 
 // but maybe better so that 18 percent card is at aces 0.18 or maybe a 
 // stop above that
 //
 // linearCV = mult_f_f3(1.0/aces75,linearCV);
 // sets the input linearCV such that the result for an 18% card generates 0.18 in scene light
 // ready to match to ACES standard then scaled by pct18scale in case the user wants 18% to display
 // at 26 nits instead of the usual 10 cd/m2
 linearCV = mult_f_f3(pct18scale*0.18/aces18,linearCV);
 
 // Matrix to AP0
 //

float XYZ[3];

 
 if (colorSpace == 1) {
 // P3 D65
    XYZ = mult_f3_f44( linearCV, P3_PRI_2_XYZ_MAT);
 }
 else if (colorSpace == 2) {
 //2020 D65
    XYZ = mult_f3_f44( linearCV, R2020_PRI_2_XYZ_MAT);
  }
 else {
 //709 D65
    XYZ = mult_f3_f44( linearCV, R709_PRI_2_XYZ_MAT);
}

// Apply CAT from assumed observer adapted white to ACES white point
XYZ = mult_f3_f33( XYZ, invert_f33( D60_2_D65_CAT));
// Convert from XYZ to AP0 primaries
linearCV = mult_f3_f44( XYZ, XYZ_2_AP0_PRI_MAT);    


 
 rOut = linearCV[0];
 gOut = linearCV[1];
 bOut = linearCV[2];
 
 
}



