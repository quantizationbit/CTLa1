
// <ACEStransformID>ODT.Academy.Rec2020_ST2084_1000nits.a1.0.3</ACEStransformID>
// <ACESuserName>ACES 1.0 Output - Rec.2020 ST2084 (1000 nits)</ACESuserName>

// 
// Output Device Transform - Rec.2020 (1000 cd/m^2)
// Gamut clipped to P3
// RGB limited to 1000 per channel component
//

//
// Summary :
//  This transform is intended for mapping OCES onto a Rec.2020 HDR display calibrated 
//  to a D65 white point at 1000 cd/m^2. The assumed observer adapted white is 
//  D65, and the viewing environment is that of a dim surround. 
//
// Device Primaries : 
//  Primaries are those specified in Rec. ITU-R BT.2020
//  CIE 1931 chromaticities:  x         y         Y
//              Red:          0.708     0.292
//              Green:        0.17      0.797
//              Blue:         0.131     0.046
//              White:        0.3127    0.329     1000 cd/m^2
//
// Display EOTF :
//  The reference electro-optical transfer function specified in SMPTE ST 
//  2084-2014. This transform makes no attempt to address the Annex functions 
//  which address integer quantization.
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.3127       0.329
//
// Viewing Environment:
//  This ODT is designed for a viewing environment more typically associated 
//  with video mastering.
//



import "ACESlib.Utilities";
import "ACESlib.Transform_Common";
import "ACESlib.ODT_Common";
import "ACESlib.Tonescales";



/* --- ODT Parameters --- */
const Chromaticities DISPLAY_PRI = REC2020_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB( DISPLAY_PRI, 1.0);
const float XYZ_2_P3_PRI_MAT[4][4] = XYZtoRGB(P3D65_PRI,1.0);
const float P3_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(P3D65_PRI,1.0);



void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    input varying float aIn,
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    output varying float aOut,
    input uniform float clip=1000.0
)
{
    float oces[3] = { rIn, gIn, bIn};

  // OCES to RGB rendering space
    float rgbPre[3] = mult_f3_f44( oces, AP0_2_AP1_MAT);

  // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3];
    rgbPost[0] = rgbPre[0];
    rgbPost[1] = rgbPre[1];
    rgbPost[2] = rgbPre[2];

  // Subtract small offset to allow for a code value of 0
    rgbPost = add_f_f3( -pow10(-4.4550166483), rgbPost);

  // Convert to display primary encoding
    // Rendering space RGB to XYZ
    float XYZ[3] = mult_f3_f44( rgbPost, AP1_2_XYZ_MAT);

      // Apply CAT from ACES white point to assumed observer adapted white point
      XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);

   // CIE XYZ to P3 primaries clamped to 1000 per channel
    float rgbP3[3] = mult_f3_f44( XYZ, XYZ_2_P3_PRI_MAT);
    // Handle out-of- P3 gamut values by clipping
    // Clip values < 0 (i.e. projecting outside the display primaries)
    // Clamp to 1000 per RGB channel
    rgbP3 = clamp_f3( rgbP3, 0., clip); 
    
    // P3 RGB to XYZ
    XYZ = mult_f3_f44( rgbP3, P3_PRI_2_XYZ_MAT);    
 
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
