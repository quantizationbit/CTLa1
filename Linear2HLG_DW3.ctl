

// 
// Convert PQ to Hybrid Gamma Log
//

import "ACESlib.Utilities";
import "ACESlib.Transform_Common";

import "HLG";



// ------- Hue restore functions
int[3] order3( float r, float g, float b)
{  
   // determines sort order, highest to lowest
   
   if (r > g) {
      if (g > b) {                    // r g b, hue [0,60]
         int order[3] = {0, 1, 2};
         return order;
      } else {
         if (r > b) {                 // r b g, hue [300,360]
            int order[3] = {0, 2, 1};
            return order;
         } else {                     // b r g, hue [240,300]
            int order[3] = {2, 0, 1};
            return order;
         }
      }
   }
   else {
      if (r > b) {                    // g r b, hue [60,120]
         int order[3] = {1, 0, 2};
         return order;
      } else {
         if (g > b) {                 // g b r, hue [120,180]
            int order[3] = {1, 2, 0};
            return order;
         } else {                     // b g r, hue [180,240]
            int order[3] = {2, 1, 0};
            return order;
         }
      }
   }
}



float[3] restore_hue_dw3( float pre_tone[3], float post_tone[3])
{
    // modifies the hue of post_tone RGB to match hue pre_tone RGB, by moving 
    // the middle channel

    int inds[3] = order3( pre_tone[0], pre_tone[1], pre_tone[2]);

    float orig_chroma = pre_tone[ inds[0]] - pre_tone[ inds[2]]; 

    float hue_factor = 0;

    if (orig_chroma != 0.) hue_factor = ( pre_tone[ inds[1] ] - pre_tone[ inds[2] ]) / orig_chroma;

    float new_chroma = post_tone[ inds[0] ] - post_tone[ inds[2] ];

    float out[3];
    out[ inds[ 0] ] = post_tone[ inds[0] ];
    out[ inds[ 1] ] = hue_factor * new_chroma + post_tone[ inds[2] ];
    out[ inds[ 2] ] = post_tone[ inds[2] ];

    return out;
}



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
    input uniform float Lb = 0.0,
    input uniform unsigned int  colorSpace = 0,
    input uniform unsigned int  DW3 = 1
)
{

 float linearCV[3] = { rIn, gIn, bIn};



 // Input Data from 0.0-1.0
 // (assuming normalized linear display light)
 
 // Step 1: Remove system gamma:
 // Requires that you know the display brightness
 // or creatively can pick a reference display brightness
 // to invert that creatively works...
 
 // System Gamma correction: (in 0.0-1.0) range
 // Calculate the system gamma
 float gamma = 1.2 + 0.42*log10(LRefDisplay/1000.0);

 
 // calculate display light luminance
 // and scale factor to remove it's system gamma
 float Yd;
 if (colorSpace == 1) {
 // P3 D65
    Yd = 0.228975*linearCV[0] + 0.691739*linearCV[1] + 0.0792869*linearCV[2];
 }
 else if (colorSpace == 2) {
 //2020 D65
	Yd = 0.2627*linearCV[0] + 0.677998*linearCV[1] + 0.0593017*linearCV[2];
  }
 else {
 //709 D65
    Yd = 0.212639*linearCV[0] + 0.715169*linearCV[1] + 0.0721923*linearCV[2];
}
 float Ys = pow(Yd, 1.0/gamma);
 float scale;
 if (Yd < FLT_MIN)
 { scale = 1.0; }
 else
 { scale = Ys/Yd; }
 
 float post_tone[3];
 
 // scale display light RGB to remove system gamma
 post_tone[0] = 12.0*scale*linearCV[0];
 post_tone[1] = 12.0*scale*linearCV[1];
 post_tone[2] = 12.0*scale*linearCV[2];
 
 if(DW3)
 {
    //clamp to 12 and cause gamut clipping
    post_tone = clamp_f3(post_tone, 0.0, 12.0);
 
    //try to recover from it 
    linearCV = restore_hue_dw3( linearCV, post_tone);
} else
{
	linearCV = post_tone;
}
 
  
 // Encode linear  gamma inverted code values with OETF transfer function
 float outputCV[3];
 outputCV[0] = HLG_r( linearCV[0]);
 outputCV[1] = HLG_r( linearCV[1]);
 outputCV[2] = HLG_r( linearCV[2]);


 rOut = outputCV[0];
 gOut = outputCV[1];
 bOut = outputCV[2];      
}



