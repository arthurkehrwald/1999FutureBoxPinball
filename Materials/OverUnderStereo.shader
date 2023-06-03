shader_type canvas_item;

uniform sampler2D left_camera;
uniform sampler2D right_camera;
uniform bool isEnabled = true;
uniform bool swap = false;

void fragment()
{
	vec4 leftCol = texture(left_camera, SCREEN_UV);
	vec4 rightCol = texture(right_camera, SCREEN_UV);
	
	if (swap)
	{
		vec4 tmp = leftCol;
		leftCol = rightCol;
		rightCol = tmp;
	}

	float pixelX = floor(FRAGCOORD.x);
	if (isEnabled)
	{
		if (SCREEN_UV.y < 0.5)
		{
			COLOR = leftCol;
		}
		else
		{
			COLOR = rightCol;
		}
	}
	else
	{
		COLOR = leftCol;
	}
}