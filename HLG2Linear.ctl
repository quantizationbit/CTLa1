

// 
// Convert PQ to Hybrid Gamma Log
//

import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Transform_Common.a1.0.1";

import "HLG";

// colorSpace 709D65 ==0, P3D65 == 1, 2020D65 == 2

void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    input uniform float LRefDisplay=800.0,
    input uniform float Lb = 0.05,
    input uniform unsigned int  colorSpace = 0
)
{

 float linearCV[3] = { rIn, gIn, bIn};


 // Input Data from 0.0-1.0
 // (HLG input is [0:1])
 
 // OETF^-1:
 linearCV[0] = HLG_f( linearCV[0])/12.0;
 linearCV[1] = HLG_f( linearCV[1])/12.0;
 linearCV[2] = HLG_f( linearCV[2])/12.0;
 
 // now have scene linear light
 
 // System Gamma correction: (in 0.0-1.0) range
 // Calculate the system gamma
 float gamma = 1.2 + 0.42*log10(LRefDisplay/1000.0);

 
 // calculate scene light luminance
 // and scale factor to remove it's system gamma
 float Ys;
 if (colorSpace == 1) {
 // P3 D65
    Ys = 0.228975*linearCV[0] + 0.691739*linearCV[1] + 0.0792869*linearCV[2];
 }
 else if (colorSpace == 2) {
 //2020 D65
	Ys = 0.2627*linearCV[0] + 0.6780*linearCV[1] + 0.0593*linearCV[2];
  }
 else {
 //709 D65
    Ys = 0.2126*linearCV[0] + 0.7152*linearCV[1] + 0.0722*linearCV[2];
}
 float Yd = pow(Ys,(gamma-1.0));
 float scale;
  if (Ys < 0.0001)
 { scale = 1.0; }
 else
 { scale = Yd/Ys; } 
 
 // scale scene light RGB to apply system gamma
 linearCV[0] = scale*linearCV[0];
 linearCV[1] = scale*linearCV[1];
 linearCV[2] = scale*linearCV[2];
 
 
 // Step 2:  Apply the OETF to the computed
 // scene linear light from the prior step.
 // scale from 0-12. to fit OETF formula
 linearCV[0] = rIn*12.0;
 linearCV[1] = gIn*12.0;
 linearCV[2] = bIn*12.0;
 
 

 
  
 // Encode linear  gamma inverted code values with OETF transfer function
 float outputCV[3];
 outputCV[0] = HLG_r( linearCV[0]);
 outputCV[1] = HLG_r( linearCV[1]);
 outputCV[2] = HLG_r( linearCV[2]);


 rOut = outputCV[0];
 gOut = outputCV[1];
 bOut = outputCV[2];      
}



