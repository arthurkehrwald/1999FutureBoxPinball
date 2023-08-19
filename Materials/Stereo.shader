shader_type canvas_item;

uniform int mode = 0;
uniform sampler2D left_camera;
uniform sampler2D right_camera;
uniform sampler2D overlay;
uniform bool show_overlay = true;
uniform bool is_enabled = true;
uniform bool swap = false;

void calcUvAndEye(vec2 screen_uv, vec4 frag_coord, out vec2 uv, out bool isLeft)
{
	if (mode == 0) // Interlaced
	{
		uv = screen_uv;
		isLeft = mod(floor(frag_coord.x), 2.0) < 0.5;
	}
	else if (mode == 1) // Over Under
	{
		if (screen_uv.y < 0.5)
		{
			uv = screen_uv * vec2(1, 2);
			isLeft = true;
		}
		else
		{
			uv = (screen_uv - vec2(0, 0.5)) * vec2(1, 2);
			isLeft = false;
		}
	}
	else if (mode == 2) // Left Right
	{
		if (screen_uv.x < 0.5)
		{
			uv = screen_uv * vec2(2, 1);
			isLeft = true;
		}
		else
		{
			uv = (screen_uv - vec2(0.5, 0)) * vec2(2, 1);
			isLeft = false;
		}
	}
}

void fragment()
{
	if (is_enabled)
	{
		vec2 uv;
		bool is_left;
		calcUvAndEye(SCREEN_UV, FRAGCOORD, uv, is_left);
		if (show_overlay)
		{
			if (is_left)
			{
				COLOR = texture(left_camera, uv) * texture(overlay, uv);
			}
			else
			{
				COLOR = texture(right_camera, uv) * texture(overlay, uv);
			}
		}
		else
		{
			if (is_left)
			{
				COLOR = texture(left_camera, uv);
			}
			else
			{
				COLOR = texture(right_camera, uv);
			}
		}
	}
	else
	{
		COLOR = texture(left_camera, SCREEN_UV);
	}
}