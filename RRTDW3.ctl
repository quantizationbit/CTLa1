
// <ACEStransformID>RRT.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 - RRT</ACESuserName>

// 
// Reference Rendering Transform (RRT)
//
//   Input is ACES
//   Output is OCES
//



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




void main 
( 
  input varying float rIn,
  input varying float gIn,
  input varying float bIn,
  input varying float aIn,
  output varying float rOut,
  output varying float gOut,
  output varying float bOut,
  output varying float aOut
)
{
  // --- Initialize a 3-element vector with input variables (ACES) --- //
    float aces[3] = {rIn, gIn, bIn};

  // --- Glow module --- //
    float saturation = rgb_2_saturation( aces);
    float ycIn = rgb_2_yc( aces);
    float s = sigmoid_shaper( (saturation - 0.4) / 0.2);
    float addedGlow = 1. + glow_fwd( ycIn, RRT_GLOW_GAIN * s, RRT_GLOW_MID);

    aces = mult_f_f3( addedGlow, aces);

  // --- Red modifier --- //
    float hue = rgb_2_hue( aces);
    float centeredHue = center_hue( hue, RRT_RED_HUE);
    float hueWeight = cubic_basis_shaper( centeredHue, RRT_RED_WIDTH);

    aces[0] = aces[0] + hueWeight * saturation * (RRT_RED_PIVOT - aces[0]) * (1. - RRT_RED_SCALE);

  // --- ACES to RGB rendering space --- //
    aces = clamp_f3( aces, 0., HALF_POS_INF);  // avoids saturated negative colors from becoming positive in the matrix

    float rgbPre[3] = mult_f3_f44( aces, AP0_2_AP1_MAT);

    rgbPre = clamp_f3( rgbPre, 0., HALF_MAX);

  // --- Global desaturation --- //
    rgbPre = mult_f3_f33( rgbPre, RRT_SAT_MAT);

  // --- Apply the tonescale independently in rendering-space RGB --- //
    float rgbPost[3];
    rgbPost[0] = segmented_spline_c5_fwd( rgbPre[0]);
    rgbPost[1] = segmented_spline_c5_fwd( rgbPre[1]);
    rgbPost[2] = segmented_spline_c5_fwd( rgbPre[2]);
    
  // Restore HUE DW3
  float rgbPostDW3[3] = restore_hue_dw3( rgbPre, rgbPost);
    

  // --- RGB rendering space to OCES --- //
    float rgbOces[3] = mult_f3_f44( rgbPostDW3, AP1_2_AP0_MAT);

  // Assign OCES RGB to output variables (OCES)
    rOut = rgbOces[0];
    gOut = rgbOces[1];
    bOut = rgbOces[2];
    aOut = aIn;
}
