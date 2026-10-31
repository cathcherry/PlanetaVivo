extends Node3D
## Globo 3D, nuvens e marcadores.
## Controle tipo globo: norte sempre para cima, com inclinacao vertical limitada.

@onready var nuvens: MeshInstance3D = $Nuvens
@onready var camera: Camera3D = $"../Camera3D"

const LIMITE_INCLINACAO: float = 1.43117 # Aproximadamente 82 graus.
const PESO_DO_ARRASTO: float = 0.69 # 15% mais sensivel que a versao anterior (0.60).

var rotacao_automatica: bool = true
var longitude: float = 0.0
var inclinacao: float = 0.0
var animacao_orientacao: Tween

func _process(delta: float) -> void:
    # Rotacao lenta padrao, sem modificar a inclinacao do eixo.
    if rotacao_automatica:
        longitude = wrapf(longitude + delta * 0.014, -PI, PI)
        _aplicar_orientacao()
    nuvens.rotate_y(delta * 0.0035)

func iniciar_arrasto() -> void:
    # O usuario assume o controle imediatamente, inclusive durante o retorno ao norte.
    parar_inercia()

func finalizar_arrasto() -> void:
    # Mantido para compatibilidade com principal.gd.
    # Soltar o dedo ou mouse ja encerra o movimento naturalmente.
    pass

func girar(deslocamento: Vector2) -> void:
    if deslocamento.length_squared() < 0.001:
        return
    rotacao_automatica = false
    var movimento: Vector2 = deslocamento.limit_length(90.0)
    var sensibilidade: float = _sensibilidade_do_globo() * PESO_DO_ARRASTO

    # Arrasto continuo: exige maior deslocamento para o mesmo giro.
    # Nao existe mais um teto de rotacao que congele o planeta no meio do gesto.
    longitude = wrapf(longitude + movimento.x * sensibilidade, -PI, PI)
    inclinacao = clampf(
        inclinacao + movimento.y * sensibilidade,
        -LIMITE_INCLINACAO,
        LIMITE_INCLINACAO
    )
    _aplicar_orientacao()

func _aplicar_orientacao() -> void:
    # A inclinacao usa o eixo horizontal fixo da tela.
    # A longitude gira dentro desse referencial, como em um globo fisico:
    # isso impede que arrastos diagonais criem um movimento estranho nos polos.
    # A ordem das multiplicacoes importa: primeiro a longitude, depois a inclinacao.
    var giro_horizontal: Quaternion = Quaternion(Vector3.UP, longitude)
    var giro_vertical: Quaternion = Quaternion(Vector3.RIGHT, inclinacao)
    quaternion = (giro_vertical * giro_horizontal).normalized()

func _sensibilidade_do_globo() -> float:
    # Compensa o tamanho aparente do globo apos aproximar/afastar a camera.
    var centro: Vector2 = camera.unproject_position(global_position)
    var borda: Vector2 = camera.unproject_position(
        global_position + camera.global_transform.basis.x.normalized() * 1.6
    )
    var raio_em_pixels: float = maxf(1.0, centro.distance_to(borda))
    return clampf(1.0 / raio_em_pixels, 0.0015, 0.008)

func parar_inercia() -> void:
    # Compatibilidade com principal.gd: cancela a animacao ao comecar a arrastar.
    if animacao_orientacao != null and animacao_orientacao.is_valid():
        animacao_orientacao.kill()
        animacao_orientacao = null

func endireitar_globo() -> void:
    # Corrige apenas a inclinacao. Nao apaga intervencoes nem muda a longitude.
    finalizar_arrasto()
    parar_inercia()
    if absf(inclinacao) < 0.005:
        inclinacao = 0.0
        _aplicar_orientacao()
        return
    rotacao_automatica = false
    animacao_orientacao = create_tween()
    animacao_orientacao.set_trans(Tween.TRANS_CUBIC)
    animacao_orientacao.set_ease(Tween.EASE_IN_OUT)
    animacao_orientacao.tween_method(_definir_inclinacao, inclinacao, 0.0, 0.52)

func _definir_inclinacao(valor: float) -> void:
    inclinacao = valor
    _aplicar_orientacao()

func reiniciar_globo() -> void:
    finalizar_arrasto()
    parar_inercia()
    longitude = 0.0
    inclinacao = 0.0
    rotacao_automatica = true
    _aplicar_orientacao()
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
