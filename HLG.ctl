import "ACESlib.Utilities";


// 
// Hybrid Gamma Log
//
//OETF function
// encodes scene linear to HLG 100% relative


// NHK HLG constants:
const float a= 0.17883277;
const float b= 0.28466892;
const float c= 0.55991073;

float HLG_r( float L)
{
  float Lc = clamp(L, 0.0, 12.0);
  
  float V;
  // input assumes normalized luma 0-1+ (12)
  
  if(Lc <= 1.0) {
     V = 0.5 * pow(Lc, 0.5);
  } else {
     V = a * log(Lc - b) + c;
  }

  return V;
}


// OETF^-1
float HLG_f( float V)
{
  // input assumes HLG input V of [0:1]
  
  float L;
  
  if(V <= 0.5) {
     L = 4.0 * pow(V, 2.0);
  } else {
     L = exp((V-c)/a)+b;
  }
  
  // output normalizes Luma to 0-1+ (12)
  L = clamp(L, 0.0, 12.0);
  return L;
}
