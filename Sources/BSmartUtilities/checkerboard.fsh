void main() {
    int size = 10;
    int h = int(v_tex_coord.x * u_texture_size.x) / size % 2;
    int v = int(v_tex_coord.y * u_texture_size.y) / size % 2;
    gl_FragColor = float4(v ^ h, v ^ h, v ^ h, 1.0);
}
