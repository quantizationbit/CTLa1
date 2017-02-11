
// <ACEStransformID>ODT.Academy.2020D65_PQ_1000nits.a1.0.0</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - 2020-D65 PQ (1000 nits)</ACESuserName>

// 
// Output Device Transform - 2020D65 (1000 cd/m^2)
//

//
// Summary :
//  This transform is intended for mapping OCES onto an HDR display calibrated 
//  to a D65 white point at 1000 cd/m^2. The assumed observer adapted white is 
//  D65, and the viewing environment is that of a dim surround. 
//
// Device Primaries : 
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.68      0.32
//              Green:        0.265     0.69
//              Blue:         0.15      0.06
//         D60  White:        0.32168   0.33767   1000 cd/m^2
//              D65  { 0.31270,  0.32900}
//
//  Also assumes a black level of 0.005 cd/m^2
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



import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";
import "ACESlib.Transform_Common.a1.0.1";
import "ACESlib.ODT_Common.a1.0.1";
import "ACESlib.Tonescales.a1.0.1";

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


const Chromaticities P3D65_PRI =
{
  { 0.68000,  0.32000},
  { 0.26500,  0.69000},
  { 0.15000,  0.06000},
  { 0.31270,  0.32900}
};


/* --- ODT Parameters --- */
const Chromaticities DISPLAY_PRI = REC2020_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB( DISPLAY_PRI, 1.0);
const float DISPLAY_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(DISPLAY_PRI,1.0);



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
    rgbPost[0] = segmented_spline_c9_fwd( rgbPre[0], ODT_1000nits);
    rgbPost[1] = segmented_spline_c9_fwd( rgbPre[1], ODT_1000nits);
    rgbPost[2] = segmented_spline_c9_fwd( rgbPre[2], ODT_1000nits);

  // Convert to display primary encoding
    // Rendering space RGB to XYZ
    float XYZ[3] = mult_f3_f44( rgbPost, AP1_2_XYZ_MAT);
    
    
  // Apply CAT from ACES white point to assumed observer adapted white point
  XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);    

    // CIE XYZ to display primaries
    float rgb[3] = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);


  
  /* Desaturate negative values going to DISPLAY Gamut */
  int inds[3] = order3( rgb[0], rgb[1], rgb[2]);
  if(rgb[inds[2]]<0.0){
	  float origY = rgb[1];
	  rgb[inds[2]]= -rgb[inds[2]]*1.3 + rgb[inds[2]];
	  rgb[inds[1]]= -rgb[inds[2]]*1.3 + rgb[inds[1]];
	  rgb[inds[0]]= -rgb[inds[2]]*1.3 + rgb[inds[0]];
	  float newXYZ[3] = mult_f3_f44( rgb, DISPLAY_PRI_2_XYZ_MAT);
	  float scaleY = fabs(origY/newXYZ[1]);
	  rgb = mult_f_f3(scaleY,rgb);
  }

    
  // Handle out-of-gamut values
    // Clip values < 0 (i.e. projecting outside the display primaries)
    rgb = clamp_f3( rgb, 0., HALF_POS_INF);    

  // Encode with PQ transfer function
    float outputCV[3] = pq_r_f3( rgb);
  
    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];
    aOut = aIn;
}
