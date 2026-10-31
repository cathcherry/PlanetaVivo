extends Node3D
## Globo 3D, nuvens e marcadores.
## Rotacao direta: a superficie acompanha o arrasto, sem inercia artificial.

@onready var nuvens: MeshInstance3D = $Nuvens
@onready var camera: Camera3D = $"../Camera3D"

var rotacao_automatica: bool = true

func _process(delta: float) -> void:
    if rotacao_automatica:
        rotate_y(delta * 0.014)
    nuvens.rotate_y(delta * 0.0035)

func girar(deslocamento: Vector2) -> void:
    # O objeto acompanha a mao enquanto houver movimento do mouse/dedo.
    if deslocamento.length_squared() < 0.001:
        return

    rotacao_automatica = false
    var movimento: Vector2 = deslocamento.limit_length(90.0)
    var sensibilidade: float = _sensibilidade_do_globo()

    # Eixos fixos da tela/camera, em vez de somar angulos Euler no objeto.
    # Direita leva a superficie para a direita; baixo leva-a para baixo.
    var eixo_para_cima: Vector3 = camera.global_transform.basis.y.normalized()
    var eixo_para_direita: Vector3 = camera.global_transform.basis.x.normalized()
    var giro_horizontal: Quaternion = Quaternion(eixo_para_cima, movimento.x * sensibilidade)
    var giro_vertical: Quaternion = Quaternion(eixo_para_direita, movimento.y * sensibilidade)
    quaternion = (giro_horizontal * giro_vertical * quaternion).normalized()

func _sensibilidade_do_globo() -> float:
    # Ajusta a velocidade do giro ao tamanho aparente da Terra.
    # Assim, o arrasto tambem fica consistente apos usar o zoom.
    var centro: Vector2 = camera.unproject_position(global_position)
    var borda: Vector2 = camera.unproject_position(
        global_position + camera.global_transform.basis.x.normalized() * 1.6
    )
    var raio_em_pixels: float = maxf(1.0, centro.distance_to(borda))
    return clampf(1.0 / raio_em_pixels, 0.0015, 0.008)

func parar_inercia() -> void:
    # Mantido por compatibilidade com principal.gd.
    # Nesta versao o movimento termina imediatamente ao soltar.
    pass

func reiniciar_globo() -> void:
    quaternion = Quaternion.IDENTITY
    rotacao_automatica = true
    for filho in get_children():
        if filho.name.begins_with("Marca_"):
            filho.queue_free()

func marcar_ponto(posicao_local: Vector3, acao: String) -> void:
    var ponto := MeshInstance3D.new()
    ponto.name = "Marca_" + acao
    var esfera := SphereMesh.new()
    esfera.radius = 0.065 if acao == "meteoro" else 0.043
    esfera.height = esfera.radius * 2.0
    esfera.radial_segments = 12
    esfera.rings = 6
    ponto.mesh = esfera
    var material := StandardMaterial3D.new()
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.albedo_color = _cor_acao(acao)
    material.emission_enabled = true
    material.emission = _cor_acao(acao)
    material.emission_energy_multiplier = 2.2
    ponto.material_override = material
    ponto.position = posicao_local.normalized() * 1.635
    ponto.scale = Vector3.ONE * 0.02
    add_child(ponto)
    var animacao := create_tween()
    animacao.tween_property(ponto, "scale", Vector3.ONE * 1.25, 0.30).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    animacao.tween_property(ponto, "scale", Vector3.ONE * 0.80, 0.50)
    animacao.tween_interval(5.0)
    animacao.tween_property(ponto, "scale", Vector3.ZERO, 0.5)
    animacao.tween_callback(ponto.queue_free)

func _cor_acao(acao: String) -> Color:
    match acao:
        "meteoro": return Color("ff7549")
        "floresta": return Color("71f09e")
        "energia": return Color("7fdafa")
        "aquecer": return Color("ffc27a")
    return Color.WHITE
