shader_type spatial;
//render_mode world_vertex_coords;

//uniform sampler2D height_map;
uniform sampler2D surface_map;

uniform sampler2D tex_0 : hint_albedo;
uniform sampler2D tex_1 : hint_albedo;
uniform sampler2D tex_2 : hint_albedo;
uniform sampler2D tex_3 : hint_albedo;
uniform sampler2D tex_4 : hint_albedo;
uniform sampler2D tex_5 : hint_albedo;
uniform sampler2D tex_6 : hint_albedo;
uniform sampler2D tex_7 : hint_albedo;

uniform float uv1_blend_sharpness;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

varying vec3 uv1_power_normal;
varying vec3 uv1_triplanar_pos;
varying flat float surf_A;
varying flat float surf_B;
varying float Acomp;
varying float Bcomp;

float hash(vec2 p) {
  return fract(sin(dot(p * 17.17, vec2(14.91, 67.31))) * 4791.9511);
}

float noise(vec2 x) {
  vec2 p = floor(x);
  vec2 f = fract(x);
  f = f * f * (3.0 - 2.0 * f);
  vec2 a = vec2(1.0, 0.0);
  return mix(mix(hash(p + a.yy), hash(p + a.xy), f.x),
         mix(hash(p + a.yx), hash(p + a.xx), f.x), f.y);
}

float fbm(vec2 x) {
  float height = 0.0;
  float amplitude = 0.5;
  float frequency = 3.0;
  for (int i = 0; i < 6; i++){
    height += noise(x * frequency) * amplitude;
    amplitude *= 0.5;
    frequency *= 2.0;
  }
  return height;
}

void vertex() {
	vec4 hData;
	float height;
	float hA,hB;
	vec3 A,B;
	vec2 iUV=vec2(float(int((VERTEX.x+100.0)/200.0)),
				  float(int((VERTEX.z+100.0)/200.0)));
	vec2 hUV=(VERTEX.xz+vec2(100.0,100.0)-(iUV*200.0))/200.0;
	//hData=texture(height_map,hUV)*255.0;
	//height=hData.r/256.0+hData.g;
	//height-=128.0;
	height=(fbm(VERTEX.xz/256.0)-0.25)*32.0;
	VERTEX.y+=height;
	
	hData=texture(surface_map,hUV);
	surf_A=hData.r*7.0;
	surf_B=hData.g*7.0;
	Bcomp=hData.b;
	Acomp=1.0-hData.b;

	//iUV=vec2(float(int((VERTEX.x+100.0)/200.0)),
	//		 float(int((VERTEX.z+100.0)/200.0)));
	//hUV=vec2(VERTEX.xz+vec2(99.0,100.0)-(iUV*200.0))/200.0;
	//hData=texture(height_map,hUV)*255.0;
	//hA=hData.r/256.0+hData.g;
	//hA-=128.0;
	hA=(fbm((VERTEX.xz+vec2(-1.0,0.0))/256.0)-0.25)*32.0;
	A=vec3(VERTEX.x-1.0,hA,VERTEX.z);

	//iUV=vec2(float(int((VERTEX.x+100.0)/200.0)),
	//		 float(int((VERTEX.z+100.0)/200.0)));
	//hUV=vec2(VERTEX.xz+vec2(99.0,99.0)-(iUV*200.0))/200.0;
	//hData=texture(height_map,hUV)*255.0;
	//hB=hData.r/256.0+hData.g;
	//hB-=128.0;
	hB=(fbm((VERTEX.xz+vec2(-1.0,-1.0))/256.0)-0.25)*32.0;
	B=vec3(VERTEX.x-1.0,hA,VERTEX.z-1.0);
	NORMAL=normalize(cross(B-VERTEX,A-VERTEX));
	
	TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0,1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);


	uv1_power_normal=pow(abs(NORMAL),vec3(uv1_blend_sharpness));
	uv1_power_normal/=dot(uv1_power_normal,vec3(1.0));
	uv1_triplanar_pos = VERTEX * uv1_scale + uv1_offset;
	uv1_triplanar_pos *= vec3(1.0,-1.0, 1.0);

}

vec4 triplanar_texture(sampler2D p_sampler,vec3 p_weights,vec3 p_triplanar_pos) {
	vec4 samp=vec4(0.0);
	samp+= texture(p_sampler,p_triplanar_pos.xy) * p_weights.z;
	samp+= texture(p_sampler,p_triplanar_pos.xz) * p_weights.y;
	samp+= texture(p_sampler,p_triplanar_pos.zy * vec2(-1.0,1.0)) * p_weights.x;
	return samp;
}

void fragment() {
	int index_A=int(surf_A+0.5);
	int index_B=int(surf_B+0.5);
	vec3 frag_A=vec3(1.0,0.0,0.0);
	vec3 frag_B=vec3(0.0,0.0,1.0);
	//index_A=0;
	//index_B=1;
	
	if (index_A==0) {
		frag_A=Acomp*triplanar_texture(tex_0,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_A==1) {
		frag_A=Acomp*triplanar_texture(tex_1,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_A==2) {
		frag_A=Acomp*triplanar_texture(tex_2,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_A==3) {
		frag_A=Acomp*triplanar_texture(tex_3,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_A==4) {
		frag_A=Acomp*triplanar_texture(tex_4,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_A==5) {
		frag_A=Acomp*triplanar_texture(tex_5,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_A==6) {
		frag_A=Acomp*triplanar_texture(tex_6,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_A==7) {
		frag_A=Acomp*triplanar_texture(tex_7,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_B==0) {
		frag_B=Bcomp*triplanar_texture(tex_0,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_B==1) {
		frag_B=Bcomp*triplanar_texture(tex_1,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_B==2) {
		frag_B=Bcomp*triplanar_texture(tex_2,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_B==3) {
		frag_B=Bcomp*triplanar_texture(tex_3,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_B==4) {
		frag_B=Bcomp*triplanar_texture(tex_4,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_B==5) {
		frag_B=Bcomp*triplanar_texture(tex_5,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_B==6) {
		frag_B=Bcomp*triplanar_texture(tex_6,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	if (index_B==7) {
		frag_B=Bcomp*triplanar_texture(tex_7,uv1_power_normal,uv1_triplanar_pos).rgb;
	}
	
	ALBEDO=frag_A+frag_B;
}
