shader_type spatial;
render_mode unshaded, depth_draw_alpha_prepass, cull_disabled;

const float width = 1.0;
const int sample_count = 4;

vec3 sample_grid(vec3 world_pos, vec3 line_width) {
	vec3 mod_pos = mod(world_pos, 1.0);
	vec3 dist = abs(0.5 - mod_pos);
	return smoothstep(vec3(0.5) - line_width * 0.5, vec3(0.5) + line_width * 0.5, dist);
}

float draw_grid(vec3 vertex, mat4 camera_matrix, vec3 grid_size, float samples)
{
	vec3 grid = vec3(0);
	for(float x = 0.0; x < samples; x += 1.0)
	{
		for(float y = 0.0; y < samples; y += 1.0)
		{
			vec4 world_pos = camera_matrix * vec4(vertex, 1.0);
			world_pos *= vec4(grid_size, 1.0);
			vec4 world_fwidth = fwidth(world_pos);
			
			vec3 offset = vec3(x, 0, y);
			offset -= (samples - 1.0) * 0.5;
			offset /= samples;
			offset *= world_fwidth.xyz;
			
			grid += sample_grid(world_pos.xyz + offset, width * world_fwidth.xyz);
		}
	}
	grid /= samples * samples;
	return max(grid.x, grid.z);
}

void fragment() {
	float samples = float(sample_count);
	float macro_grid = draw_grid(VERTEX, CAMERA_MATRIX, vec3(0.25), samples) * 2.0;
	float micro_grid = draw_grid(VERTEX, CAMERA_MATRIX, vec3(1.0), samples) * 0.5;
	
	ALBEDO = vec3(1.0);
	ALPHA = max(macro_grid, micro_grid);
}