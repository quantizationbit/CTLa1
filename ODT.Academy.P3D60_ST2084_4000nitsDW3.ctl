
// <ACEStransformID>ODT.Academy.P3D60_ST2084_4000nits.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - P3-D60 ST2084 (4000 nits)</ACESuserName>

// 
// Output Device Transform - P3D60 (4000 cd/m^2)
//

//
// Summary :
//  This transform is intended for mapping OCES onto an HDR display calibrated 
//  to a D60 white point at 4000 cd/m^2. The assumed observer adapted white is 
//  D60, and the viewing environment is that of a dim surround. 
//
// Device Primaries : 
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.68      0.32
//              Green:        0.265     0.69
//              Blue:         0.15      0.06
//              White:        0.32168   0.33767   4000 cd/m^2
//
// Display EOTF :
//  The reference electro-optical transfer function specified in SMPTE ST 
//  2084-2014. This transform makes no attempt to address the Annex functions 
//  which address integer quantization.
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.32168      0.33767
//
// Viewing Environment:
//  This ODT is designed for a viewing environment more typically associated 
//  with video mastering.
//



import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.ODT_Common";
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



/* --- ODT Parameters --- */
const Chromaticities DISPLAY_PRI = P3D60_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB( DISPLAY_PRI, 1.0);



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
    float oces[3] = { rIn, gIn, bIn};

  // OCES to RGB rendering space
    float rgbPre[3] = mult_f3_f44( oces, AP0_2_AP1_MAT);

  // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3];
    rgbPost[0] = segmented_spline_c9_fwd( rgbPre[0], ODT_4000nits);
    rgbPost[1] = segmented_spline_c9_fwd( rgbPre[1], ODT_4000nits);
    rgbPost[2] = segmented_spline_c9_fwd( rgbPre[2], ODT_4000nits);

  // Subtract small offset to allow for a code value of 0
    rgbPost = add_f_f3( -pow10(-4.4550166483), rgbPost);


  // Restore HUE DW3
  float rgbPostDW3[3] = restore_hue_dw3( rgbPre, rgbPost);



  // Convert to display primary encoding
    // Rendering space RGB to XYZ
    float XYZ[3] = mult_f3_f44( rgbPostDW3, AP1_2_XYZ_MAT);

    // CIE XYZ to display primaries
    float rgb[3] = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);
    

  // Handle out-of-gamut values
    // Clip values < 0 (i.e. projecting outside the display primaries)
    rgb = clamp_f3( rgb, 0., HALF_POS_INF);

  // Encode with ST2084 transfer function
    float outputCV[3] = Y_2_ST2084_f3( rgb);

    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];
    aOut = aIn;
}
