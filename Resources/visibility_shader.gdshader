shader_type canvas_item;

uniform vec4 modulate_color;

void fragment() {
    COLOR *= modulate_color;
}