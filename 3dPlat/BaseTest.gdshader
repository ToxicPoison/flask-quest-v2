shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,unshaded;


uniform vec4 color : source_color = vec4(0.5, 0.6, 0.7, 1.0);
uniform vec3 sun_dir = vec3(0.0, 1.0, 0.0);

void fragment() {
	vec3 global_up = mat3(VIEW_MATRIX) * normalize(sun_dir);
	float shade = clamp(dot(NORMAL, global_up), -1.0, 1.0) + 1.0;
	ALBEDO = color.rgb * shade;
}
