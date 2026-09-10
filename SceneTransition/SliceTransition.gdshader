shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float slice_count = 20.0;
uniform vec4 wipe_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
    float slice_id = floor(UV.y * slice_count);
    
    // Generate random value per slice
    float r = fract(sin(slice_id * 43.13) * 437.54);
    
    // Map progress (0 -> 1) to a sweep threshold (-0.5 -> 1.5) 
    // This guarantees it starts completely off-screen and ends completely covering it
    float sweep = progress * 2.0 - 0.5; 
    
    // Add the random offset to the threshold
    float threshold = sweep + (r - 0.5) * 0.5;
    
    // Alternate direction based on even/odd slices
    bool left_to_right = mod(slice_id, 2.0) == 0.0;
    
    bool covered = false;
    if (left_to_right) {
        if (UV.x < threshold) covered = true;
    } else {
        if (1.0 - UV.x < threshold) covered = true;
    }
    
    if (!covered) {
        discard;
    }
    
    COLOR = wipe_color;
}