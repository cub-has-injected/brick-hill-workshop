shader_type spatial;
render_mode blend_mix,depth_draw_always,cull_disabled,diffuse_burley,specular_schlick_ggx;

const int MESH_CUBE = 0;
const int MESH_CYLINDER = 1;
const int MESH_CYLINDER_HALF = 2;
const int MESH_CYLINDER_QUARTER = 3;
const int MESH_INVERSE_CYLINDER_HALF = 4;
const int MESH_INVERSE_CYLINDER_QUARTER = 5;
const int MESH_SPHERE = 6;
const int MESH_SPHERE_HALF = 7;
const int MESH_SPHERE_QUARTER = 8;
const int MESH_SPHERE_EIGTH = 9;
const int MESH_WEDGE = 10;
const int MESH_WEDGE_CORNER = 11;
const int MESH_WEDGE_EDGE = 12;

const float DEPTH_SCALE = 0.25;
uniform int depth_min_layers = 8;
uniform int depth_max_layers = 32;

uniform sampler2DArray material_textures : hint_albedo;
uniform sampler2DArray normal_textures : hint_normal;

uniform float bevel_width : hint_range(0, 1) = 0.15;

uniform vec2 texel_density = vec2(64.0, 64.0);

uniform sampler2D stud_normal : hint_normal;
uniform sampler2D stud_depth : hint_black;

uniform sampler2D albedo_palette : hint_white;
uniform sampler2D emission_palette : hint_black;
uniform sampler2D surface_palette : hint_black;

// IFNDEF INSTANCED
uniform float uniform_mesh_type;
uniform float uniform_material_idx;
uniform float uniform_palette_idx;
uniform float uniform_uv_offset;

uniform float uniform_roughness;
uniform float uniform_metallic;
uniform float uniform_opacity;
uniform float uniform_refraction;
// ENDIF

// IFDEF SINGLE_FACE
uniform int single_face = 0;
// ENDIF

// Mesh color data
varying flat float surface_idx;

// Instance color data
varying flat float roughness;
varying flat float metallic;
varying flat float opacity;
varying flat float refraction;

// Instance custom data
varying flat float mesh_type;
varying flat float material_idx;
varying flat float palette_idx;
varying flat float uv_offset;

varying flat vec3 extents;
varying vec3 model_tangent;
varying vec3 model_binormal;

float sample_depth(vec2 offset) {
	return textureLod(stud_depth, offset, 0.0).r;
}

vec2 get_texture_uv(vec2 base_uv, ivec2 texture_size) {
	vec2 ofs = vec2(mod(uv_offset, float(texture_size.x)), uv_offset / float(texture_size.x));
	return (base_uv + ofs) * (texel_density / vec2(texture_size));
}

void vertex() {
	surface_idx = UV2.x;
	
	// IFDEF INSTANCED
	roughness = COLOR.x;
	metallic = COLOR.y;
	opacity = COLOR.z;
	refraction = COLOR.w;
	// ELSE
	roughness = uniform_roughness;
	metallic = uniform_metallic;
	opacity = uniform_opacity;
	refraction = uniform_refraction;
	// ENDIF
	
	// IFDEF INSTANCED
	mesh_type = INSTANCE_CUSTOM.x;
	material_idx = INSTANCE_CUSTOM.y;
	palette_idx = INSTANCE_CUSTOM.z;
	uv_offset = INSTANCE_CUSTOM.w;
	// ELSE
	mesh_type = uniform_mesh_type;
	material_idx = uniform_material_idx;
	palette_idx = uniform_palette_idx;
	uv_offset = uniform_uv_offset;
	// ENDIF
	
	extents = vec3(
		length(WORLD_MATRIX[0]),
		length(WORLD_MATRIX[1]),
		length(WORLD_MATRIX[2])
	);
	
	model_tangent = TANGENT;
	model_binormal = BINORMAL;
	
	// ensure_correct_normals, but for MultiMeshInstance
	vec3 x0 = vec3(1.0, 0.0, 0.0);
	vec3 y0 = vec3(0.0, 1.0, 0.0);
	vec3 z0 = vec3(0.0, 0.0, 1.0);
	
	vec3 x1 = WORLD_MATRIX[0].xyz;
	vec3 y1 = WORLD_MATRIX[1].xyz;
	vec3 z1 = WORLD_MATRIX[2].xyz;
	
	float sz0 = dot(cross(x0, y0), z0);
	float sy0 = dot(cross(z0, x0), y0);
	float sx0 = dot(cross(y0, z0), x0);
	
	float sz1 = dot(cross(x1, y1), z1);
	float sy1 = dot(cross(z1, x1), y1);
	float sx1 = dot(cross(y1, z1), x1);
	
	if((sx0*sx1<0.0)||(sy0*sy1<0.0)||(sz0*sz1<0.0)) {
		NORMAL *= -1.0;
	}
}

vec2 uv_studded(in vec2 base_uv, in vec3 vertex, in vec3 normal, in vec3 binormal, in vec3 tangent, in float flip_sign) {
	vec2 depth_ofs = vec2(0);
	mat3 tangent_space = mat3(tangent * flip_sign, -binormal * flip_sign, normal);
	vec3 view_dir = normalize(normalize(-vertex) * tangent_space);
	float num_layers = mix(float(depth_max_layers), float(depth_min_layers), abs(dot(vec3(0.0, 0.0, 1.0), view_dir)));
	float layer_depth = 1.0 / num_layers;
	float current_layer_depth = 0.0;
	vec2 P = view_dir.xy * DEPTH_SCALE;
	vec2 delta = P / num_layers;
	float depth = sample_depth(base_uv + depth_ofs);
	float current_depth = 0.0;
	while(current_depth < depth) {
		depth_ofs -= delta;
		depth = sample_depth(base_uv + depth_ofs);
		current_depth += layer_depth;
	}
	vec2 prev_ofs = depth_ofs + delta;
	float after_depth  = depth - current_depth;
	float before_depth = sample_depth(base_uv + prev_ofs.xy) - current_depth + layer_depth;
	float weight = after_depth / (after_depth - before_depth);
	depth_ofs = mix(depth_ofs,prev_ofs,weight);
	
	return base_uv + depth_ofs;
}

vec3 normal_studded(in vec2 base_uv, in vec3 normal) {
	vec3 normal_stud = (2.0 * texture(stud_normal, base_uv).rgb - 1.0);
	return normal + normal_stud;
}

vec3 cardinalize(vec3 vec) {
	float dx = abs(dot(vec, vec3(1, 0, 0)));
	float dy = abs(dot(vec, vec3(0, 1, 0)));
	float dz = abs(dot(vec, vec3(0, 0, 1)));
	
	if(dx > dy && dx > dz) {
		return vec3(sign(vec.x), 0, 0);
	}
	else if(dy > dx && dy > dz) {
		return vec3(0, sign(vec.y), 0);
	}
	else if(dz > dx && dz > dy) {
		return vec3(0, 0, sign(vec.z));
	}
	
	return vec;
}

vec3 circ_bevel(in vec2 base_uv, in vec3 normal) {
	return normal;
}

void uv_extent(out vec2 uv_extent, out float aspect) {
	float u_extent = dot(abs(cardinalize(model_tangent)), extents);
	float v_extent = dot(abs(cardinalize(model_binormal)), extents);
	uv_extent = vec2(u_extent, v_extent);
	aspect = uv_extent.x / uv_extent.y;
}

vec3 cylinder_wall_bevel(in vec2 base_uv, in vec3 normal) {
	vec2 uv_ex;
	float aspect;
	uv_extent(uv_ex, aspect);
	
	float bevel_size = 0.5 * bevel_width;
	vec2 face_sub_bevel = uv_ex - bevel_width;
	
	if(base_uv.y < bevel_size)
	{
		normal.y = mix(0.75, 0.5, smoothstep(0.0, bevel_size, base_uv.y));
	}
	else if(base_uv.y > face_sub_bevel.y)
	{
		normal.y = mix(0.5, 0.25, smoothstep(face_sub_bevel.y, uv_ex.y, base_uv.y));
	}
	
	return normal;
}

vec3 quad_bevel(in vec2 base_uv, in vec3 normal) {
	vec2 uv_ex;
	float aspect;
	uv_extent(uv_ex, aspect);
	
	float bevel_size = 0.5 * bevel_width;
	vec2 face_sub_bevel = uv_ex - bevel_width;
	
	if(base_uv.x < bevel_size)
	{
		normal.x = mix(0.25, 0.5, smoothstep(0.0, bevel_size, base_uv.x));
	}
	else if(base_uv.x > face_sub_bevel.x)
	{
		normal.x = mix(0.5, 0.75, smoothstep(face_sub_bevel.x, uv_ex.x, base_uv.x));
	}
	
	if(base_uv.y < bevel_size)
	{
		normal.y = mix(0.75, 0.5, smoothstep(0.0, bevel_size, base_uv.y));
	}
	else if(base_uv.y > face_sub_bevel.y)
	{
		normal.y = mix(0.5, 0.25, smoothstep(face_sub_bevel.y, uv_ex.y, base_uv.y));
	}
	
	return normal;
}

vec3 normal_beveled(in vec2 base_uv, in vec3 normal) {
	int shape = int(mesh_type);
	int surface = int(surface_idx);
	
	vec3 qb = quad_bevel(base_uv, normal);
	vec3 cb = circ_bevel(base_uv, normal);
	vec3 cwb = cylinder_wall_bevel(base_uv, normal);
	
	vec3 out_normal = normal;
	out_normal = mix(out_normal, qb, shape == MESH_CUBE ? 1.0: 0.0);
	
	vec3 cn = mix(cb, cwb, surface == 1 ? 1.0 : 0.0);
	out_normal = mix(out_normal, cn, shape == MESH_CYLINDER ? 1.0 : 0.0);
	out_normal = mix(out_normal, cn, shape == MESH_CYLINDER_HALF ? 1.0 : 0.0);
	out_normal = mix(out_normal, cn, shape == MESH_CYLINDER_QUARTER ? 1.0 : 0.0);
	out_normal = mix(out_normal, cn, shape == MESH_INVERSE_CYLINDER_HALF ? 1.0 : 0.0);
	out_normal = mix(out_normal, cn, shape == MESH_INVERSE_CYLINDER_QUARTER ? 1.0 : 0.0);
	
	out_normal = mix(out_normal, normal, shape == MESH_SPHERE ? 1.0 : 0.0);
	out_normal = mix(out_normal, cn, shape == MESH_SPHERE_HALF ? 1.0 : 0.0);
	out_normal = mix(out_normal, cn, shape == MESH_SPHERE_QUARTER ? 1.0 : 0.0);
	out_normal = mix(out_normal, cn, shape == MESH_SPHERE_EIGTH ? 1.0 : 0.0);
	
	out_normal = mix(out_normal, qb, shape == MESH_WEDGE ? 1.0: 0.0);
	out_normal = mix(out_normal, qb, shape == MESH_WEDGE_CORNER ? 1.0: 0.0);
	out_normal = mix(out_normal, qb, shape == MESH_WEDGE_CORNER ? 1.0: 0.0);
	
	return out_normal;
}


void fragment() {
	// IFDEF SINGLE_FACE
		if(single_face >= 0 && int(surface_idx) != single_face) {
			discard;
		}
	// ENDIF
	
	vec2 base_uv = UV;
	
	float u_extent = dot(abs(cardinalize(model_tangent)), extents);
	float v_extent = dot(abs(cardinalize(model_binormal)), extents);
	
	base_uv *= vec2(u_extent, v_extent);
	
	int surface_flags = int(texelFetch(surface_palette, ivec2(int(surface_idx), int(palette_idx)), 0).x);
	bool studded = (1 & surface_flags) == 1;
	bool alternating = (2 & surface_flags) == 2;
	bool flip = (4 & surface_flags) == 4;
	bool bevel = (8 & surface_flags) == 8;
	
	// Depth flipping / alternating for studs / inlets
	float flip_sign = flip ? 1.0 : -1.0;
	vec2 uv_mod = round(mod(base_uv, 2.0) * 0.5);
	float flip_sign_mod = flip_sign * (uv_mod.x == uv_mod.y ? 1.0 : -1.0);
	flip_sign = mix(flip_sign, flip_sign_mod, alternating ? 1.0 : 0.0);
	
	// IFDEF PARALLAX_OCCLUSION_MAPPING
		base_uv = mix(base_uv, uv_studded(base_uv, VERTEX, NORMAL, BINORMAL, TANGENT, flip_sign), studded ? 1.0 : 0.0);
	// ENDIF
	
	// Albedo
	vec3 out_albedo = texture(material_textures, vec3(get_texture_uv(base_uv, textureSize(material_textures, 0).xy), material_idx)).rgb;
	out_albedo *= texelFetch(albedo_palette, ivec2(int(surface_idx), int(palette_idx)), 0).xyz;
	
	// Emissive
	vec3 out_emission = texelFetch(emission_palette, ivec2(int(surface_idx), int(palette_idx)), 0).xyz;
	
	// Normals
	vec3 normal = 2.0 * texture(normal_textures, vec3(get_texture_uv(base_uv, textureSize(normal_textures, 0).xy), material_idx)).rgb - 1.0;
	normal = mix(normal, normal_studded(base_uv, normal), studded ? 1.0 : 0.0);
	normal = (clamp(normal, -1.0, 1.0) * 0.5) + 0.5;
	normal = mix(normal, normal_beveled(base_uv, normal), bevel ? 1.0 : 0.0);
	
	ALBEDO = out_albedo;
	EMISSION = out_emission;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = 0.5;
	NORMALMAP = normal;
	NORMALMAP_DEPTH = -flip_sign;
	AO_LIGHT_AFFECT = 0.0;
	
	// IFDEF TRANSPARENT
		vec2 emission_uv = SCREEN_UV;
		
		// IFDEF REFRACTIVE
			vec3 ref_normal = vec3(2.0, 2.0, 1.0) * normal - vec3(1.0, 1.0, 0.0);
			ref_normal = normalize(NORMAL * ref_normal.z + TANGENT * ref_normal.x + BINORMAL * ref_normal.y);
			emission_uv -= ref_normal.xy * refraction;
		// ENDIF
		
		// IFDEF TRANSLUCENT
			EMISSION += textureLod(SCREEN_TEXTURE, emission_uv, ROUGHNESS * 8.0).rgb * (1.0 - opacity);
		// ELSE
			EMISSION += texture(SCREEN_TEXTURE, emission_uv).rgb * (1.0 - opacity);
		// ENDIF
	// ENDIF
}
