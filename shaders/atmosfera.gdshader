shader_type spatial;
render_mode unshaded, blend_add, cull_back, depth_draw_never, fog_disabled;

// Halo simples e leve para Android, visto nas bordas do globo.
void fragment() {
    float frente = max(dot(normalize(NORMAL), normalize(VIEW)), 0.0);
    float halo = pow(1.0 - frente, 3.8);
    ALBEDO = vec3(0.19, 0.48, 1.0);
    ALPHA = halo * 0.48;
}
