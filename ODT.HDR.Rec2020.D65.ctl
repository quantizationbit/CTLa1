


// 
// Output Device Transform - Rec2020 D65 (1000 cd/m^2)
//





import "ACESlib.Utilities.a1.0.0";
import "ACESlib.Transform_Common.a1.0.0";
import "ACESlib.ODT_Common.a1.0.0";
import "ACESlib.Tonescales.a1.0.0";



/* --- ODT Parameters --- */
const Chromaticities DISPLAY_PRI = REC2020_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(DISPLAY_PRI,1.0);


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
    input uniform float MAX=1000.0
)
{

    float fudgeMax;
    float exrMAX=16.2917402385;
    float n700  = 1028.0;
    float n1000 = 2120.0;
    float n1200 = 3700.0;
    const float maxLMT700 = segmented_spline_c9_fwd(segmented_spline_c5_fwd(exrMAX)*1000.0/n700, ODT_1000nits)*n700/1000.0;
    const float maxLMT1000 = segmented_spline_c9_fwd(segmented_spline_c5_fwd(exrMAX)*1000.0/n1000, ODT_1000nits)*n1000/1000.0;
    const float maxLMT1200 = segmented_spline_c9_fwd(segmented_spline_c5_fwd(exrMAX)*1000.0/n1200, ODT_1000nits)*n1200/1000.0;
    
    if(MAX >= 699.99 && MAX <= 1000.0) fudgeMax = n700 + (n1000-n700)*(MAX-700.0)/300.0;
    if(MAX > 1000.0 && MAX <= 1200.01) fudgeMax = n1000 + (n1200-n1000)*(MAX-1000.0)/200.0;
    
    //const float fudgeMax = pow(MAX/100.0,1.22)*100.0;
    const float scaleMax = fudgeMax/1000.0; 
    print(MAX, " ", maxLMT700, " ", maxLMT1000, " ", maxLMT1200, " ", fudgeMax, "\n");
    
    //const float fudgeMax = pow(MAX/100.0,1.22)*100.0;
    const float scaleMax = fudgeMax/1000.0; 
    print(MAX, " ", maxLMT700, " ", maxLMT1000, " ", maxLMT1200, " ", fudgeMax, "\n");
	
    float oces[3] = { rIn, gIn, bIn};

  // OCES to RGB rendering space
    float rgbPre[3] = mult_f3_f44( oces, AP0_2_AP1_MAT);

  // Apply the tonescale independently in rendering-space RGB
    float rgbPost[3];
    float tcMaxStart = ODT_1000nits.midPoint.x*fudgeMax/ODT_1000nits.maxPoint.y;
    
    if ( rgbPre[0] >= tcMaxStart)
        rgbPost[0] = segmented_spline_c9_fwd( rgbPre[0]/scaleMax, ODT_1000nits)*scaleMax;
    else
        rgbPost[0] = segmented_spline_c9_fwd( rgbPre[0], ODT_1000nits);
    
    if ( rgbPre[1] >= tcMaxStart)
        rgbPost[1] = segmented_spline_c9_fwd( rgbPre[1]/scaleMax, ODT_1000nits)*scaleMax;
    else
        rgbPost[1] = segmented_spline_c9_fwd( rgbPre[1], ODT_1000nits);
        
    if ( rgbPre[2] >= tcMaxStart)
        rgbPost[2] = segmented_spline_c9_fwd( rgbPre[2]/scaleMax, ODT_1000nits)*scaleMax;
    else
        rgbPost[2] = segmented_spline_c9_fwd( rgbPre[2], ODT_1000nits);        

  // Convert to display primary encoding
    // Rendering space RGB to XYZ
    float XYZ[3] = mult_f3_f44( rgbPost, AP1_2_XYZ_MAT);
    
      // Apply CAT from ACES white point to assumed observer adapted white point
      XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);

    // CIE XYZ to display primaries
    float rgb[3] = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);
    
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


