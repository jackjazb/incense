shader_type spatial;
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	ALBEDO = color.rgb * 5.0;
	ALBEDO = mix(ALBEDO, vec3(0.5, 0.5, 0.5), 0.5);
}
