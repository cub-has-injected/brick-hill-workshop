shader_type spatial;
render_mode unshaded, depth_draw_never, depth_test_disable;

uniform float size = 2.0;
uniform float z_near = 0.05;
uniform float z_far = 100.0;
uniform vec4 highlight_color: hint_color = vec4(0.1, 0.1, 0.8, 1.0);

const float edge_count_rcp = 1.0 / 9.0;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

float sample_depth(sampler2D depth, vec2 uv)
{
    float z_b = texture(depth, uv).x;
    float z_n = 2.0 * z_b - 1.0;
    return 2.0 * z_near * z_far / (z_far + z_near - z_n * (z_far - z_near));
}

float linearize_depth(float depth, vec2 screen_uv, mat4 inv_projection) {
	vec3 ndc = vec3(screen_uv, depth) * 2.0 - 1.0;
	vec4 view = inv_projection * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	return linear_depth;
}

float get_depth(sampler2D tex, vec2 screen_uv, mat4 inv_projection) {
	return linearize_depth(texture(tex, screen_uv).r, screen_uv, inv_projection);
}
	
void fragment() {
	vec2 frag_size = fwidth(SCREEN_UV);
	float depth = get_depth(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX);
	
	float edge = 0.0;
	for(float x = -size; x <= size; x += size)
	{
		for(float y = -size; y <= size; y += size)
		{
			float depth_left = sample_depth(DEPTH_TEXTURE, SCREEN_UV + vec2(x, y) * frag_size);
			float depth_delta = depth_left - depth;
			edge += depth_delta;
		}
	}
	edge *= edge_count_rcp;
	edge = max(edge, 0);
	
	ALBEDO = vec3(depth);
}