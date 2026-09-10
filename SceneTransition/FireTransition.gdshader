shader_type canvas_item;

// The noise texture we will pass in from the inspector
uniform sampler2D noise_texture;
// The transition progress (0.0 is fully visible, 1.0 is fully invisible)
uniform float progress : hint_range(0.0, 1.0) = 0.0;
// Optional: Add a colored burn edge to the transition
uniform float edge_thickness : hint_range(0.0, 0.1) = 0.02;
uniform vec4 edge_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);

void fragment() {
    // Read the noise value at the current UV coordinate
    float noise_val = texture(noise_texture, UV).r;
    
    // If the noise value is below the progress, make it transparent
    if (noise_val < progress) {
        discard;
    }
    
    // Optional: Draw the glowing edge right at the threshold
    if (noise_val < progress + edge_thickness) {
        COLOR = edge_color;
    } else {
        // Keep the original color of the ColorRect (usually black for a standard screen fade)
        COLOR = COLOR; 
    }
}