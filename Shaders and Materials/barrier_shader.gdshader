shader_type spatial;
render_mode blend_add, unshaded;

void fragment() {
	ALBEDO = vec3(0.0, 0.3, 1.0);
	ALPHA = sin(UV.y * 50.0 + -TIME / 2.0) / 6.0 + 0.4;
	METALLIC = 1.0;
}
