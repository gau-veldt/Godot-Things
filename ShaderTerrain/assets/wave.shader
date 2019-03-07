shader_type spatial;

uniform sampler2D test_tex : hint_albedo;
uniform vec4 alb_color : hint_color;
uniform vec4 alb_blend : hint_color;
uniform float alb_blend_alpha : hint_range(0,1);
uniform float wave_rate;
uniform float wave_amplitude;
uniform float water_tex_scale;
uniform vec4 water_glow : hint_color;
uniform float normal_gran;

float offset(vec2 pos,float time) {
	return (wave_amplitude*sin(pos.x+cos(wave_rate*time))+wave_amplitude*sin(pos.y+sin(wave_rate*time)))/2.0;
}

void vertex() {
	float move=offset(VERTEX.xz,TIME);

	vec2 e=vec2(normal_gran,0.0);
	vec3 normal=normalize(vec3(offset(VERTEX.xz - e,TIME) - offset(VERTEX.xz + e,TIME), 2.0 * e.x,
	                      offset(VERTEX.xz - e.yx,TIME) - offset(VERTEX.xz + e.yx,TIME)));
	NORMAL=normal;
	
	TANGENT = vec3(0.0,0.0,-1.0) * abs(NORMAL.x);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.y);
	TANGENT+= vec3(1.0,0.0,0.0) * abs(NORMAL.z);
	TANGENT = normalize(TANGENT);
	BINORMAL = vec3(0.0,1.0,0.0) * abs(NORMAL.x);
	BINORMAL+= vec3(0.0,0.0,-1.0) * abs(NORMAL.y);
	BINORMAL+= vec3(0.0,1.0,0.0) * abs(NORMAL.z);
	BINORMAL = normalize(BINORMAL);

	VERTEX.y+=move;
}

vec2 get_cell_uv(vec3 posi) {
	return vec2(fract(1.0*posi.x),fract(1.0*posi.z));
}
vec2 get_water_uv(vec3 posi) {
	return vec2(fract(water_tex_scale*posi.x),fract(water_tex_scale*posi.z));
}

void fragment() {
	vec3 frag;
	vec2 cell_uv=get_cell_uv(VERTEX);
	vec3 alb_tex=texture(test_tex,cell_uv).rgb;
	vec3 surf=texture(test_tex,get_water_uv(VERTEX)).rgb;
	float alb_tex_alpha=1.0-alb_blend_alpha;

	frag=alb_color.rgb*alb_tex*alb_tex_alpha+alb_blend.rgb*alb_blend_alpha;
	ALBEDO=frag;
	ALPHA=alb_color.a;
	SPECULAR=0.5;
	METALLIC=0.7;
	ROUGHNESS=0.01;
	TRANSMISSION=water_glow.rgb*4.0;
	RIM=.1;
	//EMISSION=water_glow.rgb*0.15;

	float intense=(surf.r+surf.g+surf.b)/3.0;
	vec3 grey=vec3(intense,intense,intense);
	NORMALMAP=grey;
}
