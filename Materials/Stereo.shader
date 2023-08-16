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
		if (mode == 0) // Interlaced
		{
			vec4 leftCol = texture(left_camera, SCREEN_UV);
			vec4 rightCol = texture(right_camera, SCREEN_UV);
			COLOR = mix(rightCol, leftCol, mod(pixelX, 2.0));
		}
		else if (mode == 1) // Over Under
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
		else if (mode == 2) // Over Under
		{
			if (SCREEN_UV.x < 0.5)
			{
				vec2 uv = SCREEN_UV * vec2(2, 1);
				COLOR = texture(left_camera, uv);
			}
			else
			{
				vec2 uv = (SCREEN_UV - vec2(0.5, 0)) * vec2(2, 1);
				COLOR = texture(right_camera, uv);
			}
		}
	}
	else
	{
		COLOR = texture(left_camera, SCREEN_UV);
	}
}