//
// Desaturating P3DCI/RRT inversion to ACES
//


// Common Libraries
import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Transform_Common.a1.0.1";
import "ACESlib.Tonescales.a1.0.1";




// <ACEStransformID>InvODT.Academy.P3DCI_48nits.a1.0.1</ACEStransformID>
// <ACESuserName>ACES 1.0 Inverse Output - P3-DCI</ACESuserName>

// 
// Inverse Output Device Transform - P3DCI (D60 Simulation)
//
import "ACESlib.ODT_Common.a1.0.1";


// <ACEStransformID>InvRRT.a1.0.1</ACEStransformID>

// 
// Inverse Reference Rendering Transform (RRT)
//
//   Input is OCES
//   Output is ACES
//
import "ACESlib.RRT_Common.a1.0.1";



// Hue Restore

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
const Chromaticities DISPLAY_PRI = P3DCI_PRI;
const float DISPLAY_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(DISPLAY_PRI,1.0);

const float DISPGAMMA = 2.6; 

// Rolloff white settings for P3DCI
const float NEW_WHT = 0.918;
const float ROLL_WIDTH = 0.5;    
const float SCALE = 0.96;



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
    float outputCV[3] = { rIn, gIn, bIn};

  // Decode to linear code values with inverse transfer function
    float linearCV[3] = pow_f3( outputCV, DISPGAMMA);
    
  // Convert from display primary encoding
    // Display primaries to CIE XYZ
    float XYZ[3] = mult_f3_f44( linearCV, DISPLAY_PRI_2_XYZ_MAT);
  
    // CIE XYZ to rendering space RGB
    linearCV = mult_f3_f44( XYZ, XYZ_2_AP1_MAT);

  // Undo highlight roll-off and scaling
    linearCV[0] = roll_white_rev( linearCV[0] / SCALE, NEW_WHT, ROLL_WIDTH);
    linearCV[1] = roll_white_rev( linearCV[1] / SCALE, NEW_WHT, ROLL_WIDTH);
    linearCV[2] = roll_white_rev( linearCV[2] / SCALE, NEW_WHT, ROLL_WIDTH);
  
  // Scale linear code value to luminance
    float rgbPre[3];
    rgbPre[0] = linCV_2_Y( linearCV[0], CINEMA_WHITE, CINEMA_BLACK);
    rgbPre[1] = linCV_2_Y( linearCV[1], CINEMA_WHITE, CINEMA_BLACK);
    rgbPre[2] = linCV_2_Y( linearCV[2], CINEMA_WHITE, CINEMA_BLACK);
    
  // Store pre inversion rgb AP1 values
  float pre_tone[3] = rgbPre;    

  // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3];
    rgbPost[0] = segmented_spline_c9_rev( rgbPre[0]);
    rgbPost[1] = segmented_spline_c9_rev( rgbPre[1]);
    rgbPost[2] = segmented_spline_c9_rev( rgbPre[2]);

  // Rendering space RGB to OCES
    float oces[3] = mult_f3_f44( rgbPost, AP1_2_AP0_MAT);

    
   
  //
  // INV RRT PROCESSING
  // 
    

  // --- OCES to RGB rendering space --- //
  rgbPre = mult_f3_f44( oces, AP0_2_AP1_MAT);

  // --- Apply the tonescale independently in rendering-space RGB --- //
    rgbPost[0] = segmented_spline_c5_rev( rgbPre[0]);
    rgbPost[1] = segmented_spline_c5_rev( rgbPre[1]);
    rgbPost[2] = segmented_spline_c5_rev( rgbPre[2]);

  // --- Global desaturation --- //
    rgbPost = mult_f3_f33( rgbPost, invert_f33(RRT_SAT_MAT));

    rgbPost = clamp_f3( rgbPost, 0., HALF_MAX);

  // restore HUE around the inversion
  float restoreHueAP1[3] = restore_hue_dw3(  pre_tone,  rgbPost);

  // --- RGB rendering space to ACES --- //
    float aces[3] = mult_f3_f44( restoreHueAP1, AP1_2_AP0_MAT);

    aces = clamp_f3( aces, 0., HALF_MAX);

  // --- Red modifier --- //
    float hue = rgb_2_hue( aces);
    float centeredHue = center_hue( hue, RRT_RED_HUE);
    float hueWeight = cubic_basis_shaper( centeredHue, RRT_RED_WIDTH);

    float minChan;
    if (centeredHue < 0) { // min_f3(aces) = aces[1] (i.e. magenta-red)
      minChan = aces[1];
    } else { // min_f3(aces) = aces[2] (i.e. yellow-red)
      minChan = aces[2];
    }

    float a = hueWeight * (1. - RRT_RED_SCALE) - 1.;
    float b = aces[0] - hueWeight * (RRT_RED_PIVOT + minChan) * (1. - RRT_RED_SCALE);
    float c = hueWeight * RRT_RED_PIVOT * minChan * (1. - RRT_RED_SCALE);

    aces[0] = ( -b - sqrt( b * b - 4. * a * c)) / ( 2. * a);

  // --- Glow module --- //
    float saturation = rgb_2_saturation( aces);
    float ycOut = rgb_2_yc( aces);
    float s = sigmoid_shaper( (saturation - 0.4) / 0.2);
    float reducedGlow = 1. + glow_inv( ycOut, RRT_GLOW_GAIN * s, RRT_GLOW_MID);

    aces = mult_f_f3( ( reducedGlow), aces);
    
  // Assign ACES RGB to output variables (ACES)
    rOut = aces[0];
    gOut = aces[1];
    bOut = aces[2];
    aOut = aIn;    
    
    
}







