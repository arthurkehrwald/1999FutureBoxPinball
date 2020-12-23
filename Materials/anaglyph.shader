shader_type spatial;

uniform float screen_width = 3.75;
uniform float stereo_offset = 1.0;
uniform float max_uv_offset = .1;
uniform float error_tolerance = 0.1;
uniform mat3 left_col_balance;
uniform mat3 right_col_balance;
uniform vec3 screen_pos;
uniform vec3 screen_normal;

varying mat4 CAMERA;

void vertex()
{
	POSITION = vec4(VERTEX, 1.0);
	CAMERA = CAMERA_MATRIX;
}

vec3 line_plane_intersect(vec3 plane_point, vec3 plane_normal, vec3 line_point, vec3 line_dir)
{
	// check if line is in plane
	if (dot(plane_normal, line_dir) == 0.0)
		return vec3(0, 0, 0);
	
	// calculate intersection
	float t = (dot(plane_normal, plane_point) - dot(plane_normal, line_point))
			/ dot(plane_normal, line_dir);
	return line_point + line_dir * t;
}

void fragment()
{
	vec3 world_cam_pos = (CAMERA_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec3 fake_cam_pos = world_cam_pos + vec3(stereo_offset, 0, 0);
	float uv_offset = 0.0;
	for(uv_offset = 0.0; uv_offset < max_uv_offset; uv_offset += 1.0 / VIEWPORT_SIZE.x)
	{
		vec2 shifted_uv = SCREEN_UV + vec2(-uv_offset, 0.0);
		float depth = texture(DEPTH_TEXTURE, shifted_uv).x;
		vec3 ndc = vec3(shifted_uv, depth) * 2.0 - 1.0;
		vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
		vec4 world = CAMERA * view;
		vec3 world_pos = world.xyz / world.w;
		
		vec3 view_dir_r = normalize(world_pos - world_cam_pos);
		vec3 screen_intersect_r = line_plane_intersect(screen_pos, normalize(screen_normal), world_cam_pos, view_dir_r);
		
		vec3 view_dir_l = normalize(world_pos - fake_cam_pos);
		vec3 screen_intersect_l = line_plane_intersect(screen_pos, normalize(screen_normal), fake_cam_pos, view_dir_l);
		
		float screen_offset = distance(screen_intersect_r, screen_intersect_l);
		if (abs(screen_offset - uv_offset * screen_width) < error_tolerance * .001)
		{
			break;
		} 
	}
	if(uv_offset >= max_uv_offset)
		ALBEDO = vec3(1, 0, 1);
	else
	{
		vec3 left_col = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(uv_offset, 0.0)).rgb;
		vec3 right_col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
		
		float left_r = left_col.r * left_col_balance[0][0]
				+ left_col.g * left_col_balance[0][1]
				+ left_col.b * left_col_balance[0][2];
		float left_g = left_col.r * left_col_balance[1][0]
				+ left_col.g * left_col_balance[1][1]
				+ left_col.b * left_col_balance[1][2];
		float left_b = left_col.r * left_col_balance[2][0]
				+ left_col.g * left_col_balance[2][1]
				+ left_col.b * left_col_balance[2][2];
		
		float right_r = right_col.r * right_col_balance[0][0]
				+ right_col.g * right_col_balance[0][1]
				+ right_col.g * right_col_balance[0][2];
		float right_g = right_col.r * right_col_balance[1][0]
				+ right_col.g * right_col_balance[1][1]
				+ right_col.b * right_col_balance[1][2];
		float right_b = right_col.r * right_col_balance[2][0]
				+ right_col.b * right_col_balance[2][1]
				+ right_col.g * right_col_balance[2][2];
		
		ALBEDO = vec3(left_r + right_r, left_g + right_g, left_b + right_b);
		//ALBEDO = left_col;
	}
}