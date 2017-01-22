



import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.RRT_Common";
import "ACESlib.Tonescales";




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

const float XYZ_2_P3D60_PRI_MAT[4][4] = XYZtoRGB(P3D60_PRI,1.0);
const float P3D60_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(P3D60_PRI,1.0);




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

  float acesAP0[3] = {rIn, gIn, bIn};

  //float acesAP1[3] = mult_f3_f44( acesAP0, AP0_2_AP1_MAT);
  float XYZ[3] = mult_f3_f44( acesAP0, AP0_2_XYZ_MAT);
  float P3[3]  = mult_f3_f44( XYZ, XYZ_2_P3D60_PRI_MAT);

  //float rgbACES[3] = clamp_f3( acesAP1, 0., HALF_MAX);
  float rgbACES[3] = clamp_f3( P3, 0., HALF_MAX);

  // --- RGB rendering space to OCES --- //
  //float rgbACESClampAP1[3] = mult_f3_f44( rgbACES, AP1_2_AP0_MAT);
  XYZ = mult_f3_f44( rgbACES, P3D60_PRI_2_XYZ_MAT);
  float rgbACESClampAP1[3]  = mult_f3_f44( XYZ, XYZ_2_AP0_MAT);

  float acesOut[3] = restore_hue_dw3( acesAP0, rgbACESClampAP1);



 rOut = acesOut[0];
 gOut = acesOut[1];
 bOut = acesOut[2];      
}



