#version 130

in vec2 texCoord;
out vec4 outColor;

// SUGAR auto-feed
uniform usampler2D screenData;
uniform vec3 palette[256];
uniform vec2 screenSize;
uniform vec2 realSize; // window size in pixels

uniform usampler2D overlayData;
uniform vec2 overlaySize;
uniform int overlayCKey;

uniform float time;


vec3 pixel(vec2 co){
	uint ov = texture(overlayData, co).r;
  int a = abs(sign(int(ov)-overlayCKey));

  return palette[uint(a)*ov + uint(1-a)*texture(screenData, co).r];
}

vec3 scrnpixel(vec2 co){
  return palette[texture(screenData, co).r];
}

vec4 ovpixel(vec2 co){
	uint ov = texture(overlayData, co).r;
  float a = float(abs(sign(int(ov)-overlayCKey)));
	
	return vec4(a*palette[ov], a);
}

vec4 ovmix(vec4 a, vec4 b, float i){
	float tot = max((1.0-i)*a.a+i*b.a,0.01);
	return sign(a.a+b.a)*vec4((1.0-i)*a.a/tot*a.rgb + i*b.a/tot*b.rgb, a.a*(1.0-i)+b.a*i);
}

vec4 ovapprox(vec2 coords){
	vec2 pi = 1.0 / overlaySize;
	vec2 rpi = vec2(-pi.x, pi.y);
	
	vec2 v = mod(coords * overlaySize - vec2(0.5,0.5), 1.0);
	
	vec2 a = sign(v-vec2(0.5));
	vec2 b = mod(-a*v, 0.5)*2.0;
	b *= b;
	b *= b;
	
	vec2 d = b*b;
	d *= d;
	
	vec2 m = realSize/overlaySize;
	float f = clamp(min(m.x, m.y) * 0.17, 0.0, 1.0);
	v = ((1-f)*b + f*d) *0.5;

	vec2 c = max(a, 0.0);
	v = (vec2(1.0)-c)*v + c*(vec2(1.0)-v);
	
	return ovmix(
		ovmix(
			ovpixel(coords-pi*0.499),
			ovpixel(coords-rpi*0.499),
			v.x
		),
		ovmix(
			ovpixel(coords+rpi*0.499),
			ovpixel(coords+pi*0.499),
			v.x
		),
		v.y
	);
}

vec3 scrnapprox(vec2 coords){
	vec2 pi = 1.0 / screenSize;
	vec2 rpi = vec2(-pi.x, pi.y);
	
	vec2 v = mod(coords * screenSize - vec2(0.5,0.5), 1.0);
	
	vec2 a = sign(v-vec2(0.5));
	vec2 b = mod(-a*v, 0.5)*2.0;
	b *= b;
	b *= b;
	
	vec2 d = b*b;
	d *= d;
	
	vec2 m = realSize/screenSize;
	float f = clamp(min(m.x, m.y) * 0.17, 0.0, 1.0);
	v = ((1-f)*b + f*d) *0.5;

	vec2 c = max(a, 0.0);
	v = (vec2(1.0)-c)*v + c*(vec2(1.0)-v);
	
	return mix(
		mix(
			scrnpixel(coords-pi*0.499),
			scrnpixel(coords-rpi*0.499),
			v.x
		),
		mix(
			scrnpixel(coords+rpi*0.499),
			scrnpixel(coords+pi*0.499),
			v.x
		),
		v.y
	);
}

vec3 approx(vec2 coords){
	vec4 ov = ovapprox(coords);
	
	return ov.a * ov.rgb + (1.0-ov.a) * scrnapprox(coords);
}

void main(){
	vec2 pix = realSize/screenSize;
	float apx = sign(mod(min(pix.x, pix.y), 1.0));
	
	outColor = vec4((1.0-apx)*pixel(texCoord) + apx*approx(texCoord), 1.0);
}

