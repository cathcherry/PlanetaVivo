extends Node3D
## Globo 3D, nuvens independentes e marcadores luminosos das intervencoes.

@onready var nuvens: MeshInstance3D = $Nuvens
var rotacao_automatica: bool = true
var tempo: float = 0.0
var velocidade_inercia: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
    tempo += delta
    if rotacao_automatica:
        rotate_y(delta * 0.014)
    elif velocidade_inercia.length() > 0.015:
        _aplicar_rotacao(velocidade_inercia * delta)
        velocidade_inercia *= exp(-6.0 * delta)
    nuvens.rotate_y(delta * 0.0035)

func girar(deslocamento: Vector2) -> void:
    rotacao_automatica = false
    var rotacao: Vector2 = deslocamento * 0.0045
    _aplicar_rotacao(rotacao)
    velocidade_inercia = (rotacao * 45.0).limit_length(3.0)

func parar_inercia() -> void:
    velocidade_inercia = Vector2.ZERO

func _aplicar_rotacao(quantidade: Vector2) -> void:
    rotation.y += quantidade.x
    rotation.x = clampf(rotation.x + quantidade.y, -1.2, 1.2)

func reiniciar_globo() -> void:
    rotation = Vector3.ZERO
    rotacao_automatica = true
    velocidade_inercia = Vector2.ZERO
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
