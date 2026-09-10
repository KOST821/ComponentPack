shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

// Angle in degrees. 0 = Left to Right, 90 = Top to Bottom, etc.
uniform float angle : hint_range(0.0, 360.0) = 45.0; 

uniform vec4 wipe_color : source_color = vec4(0.42, 0.60, 1.0, 1.0);
uniform float edge_thickness : hint_range(0.0, 0.2) = 0.05;
uniform vec4 edge_color : source_color = vec4(1.0, 0.95, 0.84, 1.0);

// Control the jaggedness of the laser
uniform float wave_freq = 16.62;
uniform float wave_amp = 0.05;

void fragment() {
    // 1. Convert angle to radians and get the direction vector
    float rad = radians(angle);
    vec2 dir = vec2(cos(rad), sin(rad));
    
    // 2. Center the UV coordinates (-0.5 to 0.5)
    vec2 centered_uv = UV - vec2(0.5);
    
    // 3. Project the UVs onto the direction vector using Dot Product
    float proj = dot(centered_uv, dir);
    
    // 4. Calculate the exact maximum bound based on the angle
    // This is the secret sauce that guarantees 0 to 1 perfectly covers the screen at ANY angle
    float bound = abs(dir.x * 0.5) + abs(dir.y * 0.5);
    
    // Normalize the projected value so it goes exactly from 0.0 (start) to 1.0 (end)
    float val = (proj / bound) * 0.5 + 0.5;
    
    // 5. Create a perpendicular vector so the wave runs ALONG the laser cut, not across it
    vec2 perp = vec2(-dir.y, dir.x);
    float wave_coord = dot(centered_uv, perp);
    
    // Add the sine wave distortion
    float wave = sin(wave_coord * wave_freq) * wave_amp;
    val += wave;
    
    // 6. Map progress to account for the wave offset so it doesn't bleed at 0.0 or 1.0
    float threshold = progress * (1.0 + wave_amp * 2.0) - wave_amp;
    
    // Discard everything ahead of the laser sweep
    if (val > threshold) {
        discard;
    }
    
    // Draw the glowing edge if we are just behind the threshold
    if (val > threshold - edge_thickness) {
        COLOR = edge_color;
    } else {
        COLOR = wipe_color;
    }
}