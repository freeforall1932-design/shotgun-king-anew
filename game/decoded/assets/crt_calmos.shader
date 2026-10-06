#version 130

in vec2 texCoord;
out vec4 outColor;

uniform usampler2D screenData;
uniform vec3 palette[256];
uniform vec2 screenSize;
uniform usampler2D overlayData;
uniform int overlayCKey;

uniform float flash = 0.0;

uniform float curve = 0.02;
uniform float chroma = 0.4;


const float PI = 3.1415926535897932384626433832795;

const vec2 adco = vec2(0.499, 0.499);
const vec2 bdco = vec2(0.499, -0.499);

const vec2 rshft = -vec2(-0.4381, 0.2409);
const vec2 gshft = -vec2(0.0, -0.5);
const vec2 bshft = -vec2(0.4381, 0.2409);


vec3 pixel(vec2 co, vec2 dco){
	uint ov = texture(overlayData, co).r;
  int a = abs(sign(int(ov)-overlayCKey));

  return palette[uint(a)*ov + uint(1-a)*texture(screenData, co+dco).r];
}

vec3 get_col(vec2 coords, vec2 cellco, vec2 dco){
  vec3 col = pixel(coords, dco/screenSize);
  
  cellco = cellco - dco;
  
  float hv = 0.5-0.5*cos((min(abs(cellco.x)*1.0, 1.0)+1.0) * PI);
  float vv = 0.5-0.5*cos((max(abs(cellco.y)*1.5-0.5, 0.0)+1.0) * PI);
  
  return min(hv * vv * vv * (1.0 + flash), 1.0) * col;
}

vec3 get_col2(vec2 coords){
  vec2 cellco = mod(coords * screenSize - vec2(0.5, 0.5), 1.0) - vec2(0.5,0.5);

  vec3 col = get_col(coords, cellco, -adco)
           + get_col(coords, cellco,  bdco)
           + get_col(coords, cellco, -bdco)
           + get_col(coords, cellco,  adco);
  
  return col;
}

void main(){
  //flash = 1.0 + 1.0 * cos(time);
  
  vec2 coords = texCoord;
  
  // CRT screen curvature
  coords = coords * 2.0 - vec2(1.0, 1.0);
  coords += (coords.yx * coords.yx) * coords * curve;
  
  float fflsh = 1.0-max(coords.x*coords.x, 0.0)*max(coords.y*coords.y, 0.0);
  fflsh = flash * fflsh * fflsh;
  
  coords = coords / 2.0 + vec2(0.5, 0.5);

  vec2 pi = 1.0 / screenSize;
  
  vec2 cor = coords + chroma * rshft * pi;
  vec2 cog = coords + chroma * gshft * pi;
  vec2 cob = coords + chroma * bshft * pi;
  
  vec3 colr = get_col2(cor);
  vec3 colg = get_col2(cog);
  vec3 colb = get_col2(cob);
  
  //flash
  vec3 col = vec3(colr.r, colg.g, colb.b) * (1.0 + fflsh);
  
  // result
  outColor = vec4(col, 1.0);//vec4(min(lcol + 0.25*acol + pcol, 1.0), 1.0);
}
