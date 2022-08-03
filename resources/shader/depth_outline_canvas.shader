shader_type canvas_item;
render_mode unshaded, blend_mix;

uniform float size = 2.0;
uniform vec4 highlight_color: hint_color = vec4(0.1, 0.1, 0.8, 1.0);

const float edge_count_rcp = 1.0 / 9.0;

uniform mat3 sobel_kernel = mat3(
	vec3(-1, -1, -1),
	vec3(-1, +8, -1),
	vec3(-1, -1, -1)
);

vec3 sobel(sampler2D tex, vec2 uv, vec2 frag_size) {
	vec3 col = sobel_kernel[1][1] * texture(tex, uv).xyz;
    col += sobel_kernel[2][1] * texture(tex, uv + vec2(0.0, frag_size.y)).xyz;
    col += sobel_kernel[0][1] * texture(tex, uv + vec2(0.0, -frag_size.y)).xyz;
    col += sobel_kernel[1][2] * texture(tex, uv + vec2(frag_size.x, 0.0)).xyz;
    col += sobel_kernel[1][0] * texture(tex, uv + vec2(-frag_size.x, 0.0)).xyz;
    col += sobel_kernel[2][2] * texture(tex, uv + frag_size.xy).xyz;
    col += sobel_kernel[0][0] * texture(tex, uv - frag_size.xy).xyz;
    col += sobel_kernel[2][0] * texture(tex, uv + vec2(-frag_size.x, frag_size.y)).xyz;
    col += sobel_kernel[0][2] * texture(tex, uv + vec2(frag_size.x, -frag_size.y)).xyz;
	return col;
}

void fragment() {
	vec2 uv = UV;
	vec2 frag_size = SCREEN_PIXEL_SIZE * size;
	vec3 edge = sobel(TEXTURE, uv, frag_size);
	
	COLOR.xyz = highlight_color.xyz;
	COLOR.a = highlight_color.a * clamp(edge.r, 0.0, 1.0);
}
