shader_type canvas_item;

uniform int mode = 0;
uniform sampler2D left_camera;
uniform sampler2D right_camera;
uniform bool is_enabled = true;
uniform bool swap = false;

void fragment()
{
	float pixelX = floor(FRAGCOORD.x);
	if (is_enabled)
	{
		if (SCREEN_UV.y < 0.5)
		{
			vec2 uv = SCREEN_UV * vec2(1, 2);
			COLOR = texture(left_camera, uv);
		}
		else
		{
			vec2 uv = (SCREEN_UV - vec2(0, 0.5)) * vec2(1, 2);
			COLOR = texture(right_camera, uv);
		}
	}
	else
	{
		COLOR = texture(left_camera, SCREEN_UV);
	}
}