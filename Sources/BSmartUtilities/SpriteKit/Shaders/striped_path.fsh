/*
void main() {
    vec4 current_color = texture2D(u_texture, v_tex_coord);
    float diff = u_path_length / u_stripe_lenght;
    float stripe = u_path_length / diff;
    float distance = v_path_distance;
    int h = int(mod(distance / stripe, 2.0));
    gl_FragColor = h * vec4(current_color.rgb, 1.0 / distance);
}
*/
void main() {
    int stripe = int(u_stripe_length);
    int h = int(v_path_distance) / stripe % 2;
    gl_FragColor = float4(SKDefaultShading().xyz, h);
}
