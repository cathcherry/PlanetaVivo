extends Node3D
## Controlador da cena: navegação, cliques e estado local do planeta.

const ArquivoSimulacao = preload("res://scripts/simulacao.gd")

@onready var terra: Node3D = $Terra
@onready var camera: Camera3D = $Camera3D
@onready var interface: CanvasLayer = $Interface

var simulacao = ArquivoSimulacao.new()
var acao: String = "meteoro"
var arrastando: bool = false
var mouse_moveu: bool = false
var dedo_moveu: bool = false
var teve_pinca: bool = false
var inicio_toque: Vector2 = Vector2.ZERO
var posicao_toque: Vector2 = Vector2.ZERO
var distancia_camera: float = 6.8
var toques: Dictionary = {}
var distancia_pinca: float = 0.0

func _ready() -> void:
    interface.connect("acao_selecionada", _trocar_acao)
    interface.connect("ano_avancado", _avancar_ano)
    interface.connect("jogo_reiniciado", _reiniciar)
    interface.connect("orientacao_restaurada", _endireitar_globo)
    interface.call("mudar_estado", simulacao.estado())
    interface.call("mostrar_mensagem", "Selecione uma acao e toque na Terra.")

func _unhandled_input(evento: InputEvent) -> void:
    if evento is InputEventMouseButton:
        if evento.button_index == MOUSE_BUTTON_WHEEL_UP and evento.pressed:
            _aproximar(-0.35)
            return
        if evento.button_index == MOUSE_BUTTON_WHEEL_DOWN and evento.pressed:
            _aproximar(0.35)
            return
        if evento.button_index == MOUSE_BUTTON_LEFT:
            if evento.pressed:
                # O arrasto so comeca quando o clique inicia no planeta.
                # Clicar no fundo preto nao gira o globo.
                if not _esta_sobre_terra(evento.position):
                    return
                arrastando = true
                mouse_moveu = false
                terra.call("iniciar_arrasto")
                inicio_toque = evento.position
                posicao_toque = evento.position
            elif arrastando:
                arrastando = false
                terra.call("finalizar_arrasto")
                if not mouse_moveu and inicio_toque.distance_to(evento.position) < 15.0:
                    _intervir(evento.position)
    elif evento is InputEventMouseMotion and arrastando:
        if inicio_toque.distance_to(evento.position) >= 15.0:
            mouse_moveu = true
        if mouse_moveu:
            terra.call("girar", evento.position - posicao_toque)
        posicao_toque = evento.position
    elif evento is InputEventScreenTouch:
        if evento.pressed:
            # O primeiro dedo precisa tocar a Terra.
            # O segundo pode estar fora para permitir o gesto de pinca.
            if toques.is_empty() and not _esta_sobre_terra(evento.position):
                return
            toques[evento.index] = evento.position
            if toques.size() == 1:
                teve_pinca = false
                dedo_moveu = false
                terra.call("iniciar_arrasto")
                inicio_toque = evento.position
                posicao_toque = evento.position
            if toques.size() == 2:
                terra.call("finalizar_arrasto")
                teve_pinca = true
                distancia_pinca = _distancia_dedos()
        else:
            # Ignora dedos cujo gesto comecou no fundo preto.
            if not toques.has(evento.index):
                return
            if toques.size() == 1 and toques.has(evento.index) and not teve_pinca and not dedo_moveu and inicio_toque.distance_to(evento.position) < 15.0:
                _intervir(evento.position)
            toques.erase(evento.index)
            if toques.is_empty():
                terra.call("finalizar_arrasto")
                distancia_pinca = 0.0
                teve_pinca = false
                dedo_moveu = false
    elif evento is InputEventScreenDrag:
        # Nao transforma um arrasto iniciado fora da Terra em um gesto valido.
        if not toques.has(evento.index):
            return
        toques[evento.index] = evento.position
        if toques.size() == 1 and not teve_pinca:
            if inicio_toque.distance_to(evento.position) >= 15.0:
                dedo_moveu = true
            if dedo_moveu:
                terra.call("girar", evento.relative)
        elif toques.size() == 2:
            teve_pinca = true
            var distancia_nova: float = _distancia_dedos()
            if distancia_pinca > 0.0:
                _aproximar((distancia_pinca - distancia_nova) * 0.009)
            distancia_pinca = distancia_nova

func _distancia_dedos() -> float:
    var indices := toques.keys()
    if indices.size() < 2:
        return 0.0
    var primeira: Vector2 = toques[indices[0]]
    var segunda: Vector2 = toques[indices[1]]
    return primeira.distance_to(segunda)

func _aproximar(diferenca: float) -> void:
    distancia_camera = clampf(distancia_camera + diferenca, 4.6, 9.4)
    camera.position.z = distancia_camera

func _esta_sobre_terra(posicao_tela: Vector2) -> bool:
    # Verifica se o clique atravessa a esfera que representa o planeta.
    # Usa o mesmo raio (1.63) do calculo de aplicacao das intervencoes.
    var origem_global: Vector3 = camera.project_ray_origin(posicao_tela)
    var direcao_global: Vector3 = camera.project_ray_normal(posicao_tela)
    var origem: Vector3 = terra.to_local(origem_global)
    var direcao: Vector3 = (terra.to_local(origem_global + direcao_global) - origem).normalized()
    var b: float = 2.0 * origem.dot(direcao)
    var c: float = origem.length_squared() - 1.63 * 1.63
    var discriminante: float = b * b - 4.0 * c
    if discriminante < 0.0:
        return false
    var distancia: float = (-b - sqrt(discriminante)) / 2.0
    return distancia >= 0.0

func _intervir(posicao_tela: Vector2) -> void:
    # Projeta o toque em uma esfera matematica; dispensa colisores e fisica pesada.
    var origem_global := camera.project_ray_origin(posicao_tela)
    var direcao_global := camera.project_ray_normal(posicao_tela)
    var origem := terra.to_local(origem_global)
    var direcao := (terra.to_local(origem_global + direcao_global) - origem).normalized()
    var b := 2.0 * origem.dot(direcao)
    var c := origem.length_squared() - 1.63 * 1.63
    var discriminante := b * b - 4.0 * c
    if discriminante < 0.0:
        return
    var distancia := (-b - sqrt(discriminante)) / 2.0
    if distancia < 0.0:
        return
    var ponto := origem + direcao * distancia
    terra.call("marcar_ponto", ponto, acao)
    var mensagem: String = simulacao.agir(acao)
    interface.call("mudar_estado", simulacao.estado())
    interface.call("mostrar_mensagem", mensagem)

func _trocar_acao(nova_acao: String) -> void:
    acao = nova_acao
    var nomes := {
        "meteoro": "Meteoro: toque em algum ponto da Terra.",
        "floresta": "Reflorestamento: toque em uma regiao.",
        "energia": "Energia limpa: toque no planeta para investir.",
        "aquecer": "Aquecimento: toque no planeta para experimentar."
    }
    interface.call("mostrar_mensagem", nomes.get(acao, "Toque no planeta."))

func _avancar_ano() -> void:
    interface.call("mostrar_mensagem", simulacao.passar_ano())
    interface.call("mudar_estado", simulacao.estado())

func _endireitar_globo() -> void:
    terra.call("endireitar_globo")
    interface.call("mostrar_mensagem", "Globo endireitado: norte para cima.")

func _reiniciar() -> void:
    simulacao.reiniciar()
    terra.call("reiniciar_globo")
    camera.position.z = 6.8
    distancia_camera = 6.8
    interface.call("mudar_estado", simulacao.estado())
    interface.call("mostrar_mensagem", "Planeta restaurado. Inicie uma nova experiencia.")
