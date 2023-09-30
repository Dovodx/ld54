shader_type sky;

void sky() {
	if (AT_CUBEMAP_PASS) {
        // Sets the radiance cubemap to a nice shade of blue instead of doing
        // expensive sky calculations
        COLOR = vec3(0.2, 0.2, 0.2);
    } else {
        // Do expensive sky calculations for background sky only
        COLOR = vec3(0.05, 0.0, 0.25 * EYEDIR.g);
    }
}
