shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float pixel_size : hint_range(1.0, 100.0) = 40.0;
uniform vec4 wipe_color : source_color = vec4(0.01, 0.05, 0.1, 1.0);

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 grid_uv = floor(UV * pixel_size) / pixel_size;
    
    // Calculate distance from center
    float dist = distance(grid_uv, center);
    
    // Normalize distance. Max distance to corner is ~0.707. 
    // Dividing by 0.7071 scales the corner distance perfectly to 1.0.
    float normalized_dist = dist / 0.7071;
    
    // Generate pseudo-random noise per grid cell (0.0 to 1.0)
    float r = fract(sin(dot(grid_uv, vec2(12.9898, 78.233))) * 43758.5453);
    
    // Combine normalized distance and a scaled noise value
    float val = normalized_dist + r * 0.4;
    
    // Map progress (0.0 to 1.0) to completely envelop the min (0.0) and max (1.4) of 'val'
    float threshold = progress * 1.6 - 0.1;
    
    // If the pixel's value is greater than the expanding threshold, it stays invisible
    if (val > threshold) {
        discard;
    }
    
    COLOR = wipe_color;
}