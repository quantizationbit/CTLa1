

// 
// Convert Gamma to linear
//

import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Transform_Common.a1.0.1";

const float DCI_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(P3DCI_PRI,1.0);
const float R709_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(REC709_PRI,1.0);
const float XYZ_2_709_MAT[4][4] = XYZtoRGB(REC709_PRI,1.0);


// colorSpace 709D65 ==0, P3D65 == 1, 2020D65 == 2

void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    output varying float rOut,
    output varying float gOut,
    output varying float bOut
)
{

 float linearCV[3] = { rIn, gIn, bIn};


// matrix 709 to XYZ (stupidly in gamma)
float XYZ[3] = mult_f3_f44( linearCV, R709_PRI_2_XYZ_MAT);


//remove gamma 2.6

XYZ = dcdm_decode( XYZ);

 
 // flip in linear to 708 g22
 linearCV = mult_f3_f44( XYZ, XYZ_2_709_MAT);
 
 // add gamma 2.2
 //709 D65
 float Ys = 0.212639*linearCV[0] + 0.715169*linearCV[1] + 0.0721923*linearCV[2];

float Yd = pow(Ys, 1/2.2);
float scale;
 if (Ys < FLT_MIN)
 { scale = 1.0; }
 else
 { scale = Yd/Ys; }
 
 // scale display light RGB to remove system gamma
 linearCV[0] = scale*linearCV[0];
 linearCV[1] = scale*linearCV[1];
 linearCV[2] = scale*linearCV[2];
 

    linearCV = clamp_f3(linearCV, 0.0, 1.0);


 rOut = linearCV[0];
 gOut = linearCV[1];
 bOut = linearCV[2];      
}



