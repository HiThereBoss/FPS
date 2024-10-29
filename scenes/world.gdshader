shader_type sky;

uniform vec3 skyColor : source_color;
uniform sampler2D skyTexture;

void sky() {
	COLOR = texture(skyTexture,SKY_COORDS).rgb;
}
