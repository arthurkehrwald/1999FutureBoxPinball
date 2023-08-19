shader_type canvas_item;
render_mode unshaded;

uniform sampler2D displace: hint_albedo;
uniform float dispOffset: hint_range(-5,5);
uniform float dispAmt: hint_range(0, 1.0);
uniform vec2 abberationAmt;
uniform vec2 dispSize;
uniform float maxAlpha: hint_range(0, 1.0);
uniform sampler2D scanlines: hint_albedo;
uniform float scanlineSize: hint_range(0, 2.0) = 1.0;
uniform float scanlineIntensity: hint_range(0.0, 1.0) = 0.5;

varying vec2 scale;

void vertex()
{
	vec3 worldXAxis = WORLD_MATRIX[0].xyz;
	vec3 worldYAxis = WORLD_MATRIX[1].xyz;
	scale.x = length(worldXAxis);
	scale.y = length(worldYAxis);
}

void fragment()
{
	// displace
	vec2 displacement = texture(displace, mod(UV * dispSize + dispOffset, 1.0)).xy;
	displacement *= dispAmt * scale / 100.0;
	vec2 displacedScreenUv = SCREEN_UV + displacement;
	
	// abberation
	vec2 scaledAbberationAmt = abberationAmt * scale / 100.0;
	COLOR.r = texture(SCREEN_TEXTURE, displacedScreenUv - scaledAbberationAmt).r;
	COLOR.ga = texture(SCREEN_TEXTURE, displacedScreenUv).ga;
	COLOR.b = texture(SCREEN_TEXTURE, displacedScreenUv + scaledAbberationAmt).b;
	
	// scanlines
	vec2 scanlineUv = mod(UV * scanlineSize + dispOffset, 1.0);
	vec3 scanlineCol = texture(scanlines, scanlineUv).rgb;
	COLOR.rgb = mix(COLOR.rgb, vec3(0.5), scanlineCol * scanlineIntensity);
}