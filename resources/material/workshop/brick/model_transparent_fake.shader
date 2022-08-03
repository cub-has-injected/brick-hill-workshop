shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_back,diffuse_burley,specular_schlick_ggx;

uniform float specular : hint_range(0,1) = 0.5;
uniform float metallic_scale : hint_range(0,1) = 0.0;
uniform float roughness_scale : hint_range(0,1) = 0.25;
uniform float ao_light_affect : hint_range(0,1) = 0.0;

uniform float normal_scale : hint_range(-16,16) = 1.0;

uniform vec2 texture_uv_offset = vec2(0, 0);
uniform vec2 texel_density = vec2(64.0, 64.0);

uniform float refraction: hint_range(0.0, 0.2) = 0.05;

uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D texture_normal : hint_normal;
uniform sampler2D texture_metallic : hint_white;
uniform sampler2D texture_roughness : hint_white;
uniform sampler2D texture_ambient_occlusion : hint_white;

varying float flip_sign;
void vertex() {
	if (!OUTPUT_IS_SRGB) {
		COLOR.rgb = mix( pow((COLOR.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)), COLOR.rgb* (1.0 / 12.92), lessThan(COLOR.rgb,vec3(0.04045)) );
	}
}

vec2 get_texture_uv(sampler2D tex, vec2 base_uv) {
	return (base_uv + texture_uv_offset) * (texel_density / vec2(textureSize(tex, 0)));
}

void fragment() {
	// Parallax Occlusion Mapping
	vec2 base_uv = UV;
	
	vec3 albedo = texture(texture_albedo, get_texture_uv(texture_albedo, base_uv)).rgb;
	{
		albedo *= COLOR.rgb;
	}
	
	// Normals
	vec3 normal = texture(texture_normal, get_texture_uv(texture_normal, base_uv)).rgb;
	normal.xy -= 0.5;
	normal.xy *= 2.0;
	normal = (clamp(normal, -1.0, 1.0) * 0.5) + 0.5;
	
	float metallic = texture(texture_metallic, get_texture_uv(texture_metallic, base_uv)).r;
	float roughness = texture(texture_roughness, get_texture_uv(texture_roughness, base_uv)).r;
	
	ALBEDO = albedo * COLOR.a;
	METALLIC = metallic * metallic_scale;
	ROUGHNESS = roughness * roughness_scale;
	SPECULAR = specular;
	
	NORMALMAP = normal;
	NORMALMAP_DEPTH = normal_scale;
	
	AO = texture(texture_ambient_occlusion, base_uv).x;
	AO_LIGHT_AFFECT = ao_light_affect;
	
	vec3 ref_normal = (normal * vec3(2.0, 2.0, 1.0)) - vec3(1.0, 1.0, 0.0);
	ref_normal = normalize(NORMAL * ref_normal.z + TANGENT * ref_normal.x + BINORMAL * ref_normal.y);
	vec2 ref_ofs = SCREEN_UV - ref_normal.xy * refraction;
	float ref_amount = 1.0 - COLOR.a;
	EMISSION += textureLod(SCREEN_TEXTURE, ref_ofs, ROUGHNESS * 8.0).rgb * ref_amount;
}
