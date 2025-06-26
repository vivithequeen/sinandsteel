shader_type canvas_item;

uniform int pixel_size = 8;
uniform bool overlay = false;

uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    vec2 uv = FRAGCOORD.xy / vec2(1920,1080);
    vec2 pixel_uv = floor(uv * float(pixel_size)) / float(pixel_size);
    COLOR = texture(screen_texture, pixel_uv);
}