extends CanvasLayer
## HUD vertical com tamanhos explicitos: nao depende do tamanho minimo dos filhos.
## O painel inferior tem altura fixa relativa a tela e rolagem interna.

signal acao_selecionada(acao: String)
signal ano_avancado
signal jogo_reiniciado

const COR_FUNDO = Color("09172ccc")
const COR_BORDA = Color("34506b")
const COR_TEXTO = Color("e4f0ff")
const COR_SUAVE = Color("8faecb")
const COR_DESTAQUE = Color("72d9f9")

var raiz: Control
var topo: Panel
var aviso: Panel
var painel: Panel
var linha_topo: HBoxContainer
var rolagem: ScrollContainer
var conteudo: VBoxContainer

var texto_ano: Label
var texto_mensagem: Label
var texto_temperatura: Label
var texto_carbono: Label
var texto_vida: Label
var texto_estabilidade: Label
var texto_energia: Label
var barra_vida: ProgressBar
var barra_estabilidade: ProgressBar
var botoes: Dictionary = {}
var acao_atual: String = "meteoro"

func _ready() -> void:
    _montar_interface()
    get_viewport().size_changed.connect(_ajustar_layout)
    # O tamanho real da janela so e garantido depois da primeira atualizacao.
    call_deferred("_ajustar_layout")
    _selecionar_acao("meteoro")

func _estilo(fundo: Color, borda: Color, raio: int = 18) -> StyleBoxFlat:
    var estilo: StyleBoxFlat = StyleBoxFlat.new()
    estilo.bg_color = fundo
    estilo.border_color = borda
    estilo.set_border_width_all(1)
    estilo.set_corner_radius_all(raio)
    estilo.set_content_margin_all(12.0)
    return estilo

func _rotulo(texto: String, tamanho: int, cor: Color, negrito: bool = false) -> Label:
    var rotulo: Label = Label.new()
    rotulo.text = texto
    rotulo.add_theme_font_size_override("font_size", tamanho)
    rotulo.add_theme_color_override("font_color", cor)
    rotulo.autowrap_mode = TextServer.AUTOWRAP_OFF
    if negrito:
        rotulo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.55))
        rotulo.add_theme_constant_override("shadow_offset_x", 1)
        rotulo.add_theme_constant_override("shadow_offset_y", 2)
    return rotulo

func _botao(texto: String, cor: Color) -> Button:
    var botao: Button = Button.new()
    botao.text = texto
    botao.custom_minimum_size = Vector2(0, 53)
    botao.add_theme_font_size_override("font_size", 17)
    botao.add_theme_color_override("font_color", COR_TEXTO)
    botao.add_theme_color_override("font_hover_color", Color.WHITE)
    botao.add_theme_stylebox_override("normal", _estilo(Color("14253f"), COR_BORDA, 12))
    botao.add_theme_stylebox_override("hover", _estilo(Color("254567"), cor, 12))
    botao.add_theme_stylebox_override("pressed", _estilo(Color("315777"), COR_DESTAQUE, 12))
    botao.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    botao.focus_mode = Control.FOCUS_NONE
    return botao

func _montar_interface() -> void:
    raiz = Control.new()
    raiz.name = "Controles"
    raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(raiz)

    topo = Panel.new()
    topo.name = "Cabecalho"
    topo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    topo.add_theme_stylebox_override("panel", _estilo(COR_FUNDO, COR_BORDA))
    raiz.add_child(topo)

    linha_topo = HBoxContainer.new()
    linha_topo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    linha_topo.add_theme_constant_override("separation", 10)
    topo.add_child(linha_topo)
    var titulos: VBoxContainer = VBoxContainer.new()
    titulos.mouse_filter = Control.MOUSE_FILTER_IGNORE
    titulos.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    titulos.add_theme_constant_override("separation", 2)
    linha_topo.add_child(titulos)
    titulos.add_child(_rotulo("PLANETA VIVO", 28, COR_TEXTO, true))
    titulos.add_child(_rotulo("LABORATORIO PLANETARIO · PROTOTIPO 0.1.1", 12, COR_SUAVE))
    texto_ano = _rotulo("2026", 24, COR_DESTAQUE, true)
    texto_ano.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    texto_ano.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    texto_ano.custom_minimum_size.x = 75
    linha_topo.add_child(texto_ano)

    aviso = Panel.new()
    aviso.name = "Noticia"
    aviso.mouse_filter = Control.MOUSE_FILTER_IGNORE
    aviso.add_theme_stylebox_override("panel", _estilo(Color("0a1b34dd"), Color("315674"), 14))
    raiz.add_child(aviso)
    texto_mensagem = _rotulo("", 15, COR_TEXTO)
    texto_mensagem.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    texto_mensagem.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    texto_mensagem.mouse_filter = Control.MOUSE_FILTER_IGNORE
    aviso.add_child(texto_mensagem)

    # Panel (nao PanelContainer) impede que a altura minima dos controles
    # empurre a interface inteira para fora da janela.
    painel = Panel.new()
    painel.name = "PainelDeControle"
    painel.mouse_filter = Control.MOUSE_FILTER_STOP
    painel.add_theme_stylebox_override("panel", _estilo(Color("081527f2"), Color("46657f"), 22))
    raiz.add_child(painel)

    rolagem = ScrollContainer.new()
    rolagem.name = "RolagemInterna"
    rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    rolagem.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    rolagem.mouse_filter = Control.MOUSE_FILTER_STOP
    painel.add_child(rolagem)

    conteudo = VBoxContainer.new()
    conteudo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    conteudo.add_theme_constant_override("separation", 10)
    rolagem.add_child(conteudo)

    var titulo_linha: HBoxContainer = HBoxContainer.new()
    conteudo.add_child(titulo_linha)
    var titulo: Label = _rotulo("CONTROLE PLANETARIO", 18, COR_TEXTO, true)
    titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    titulo_linha.add_child(titulo)
    var estado_rede: Label = _rotulo("OFFLINE", 12, COR_DESTAQUE)
    estado_rede.custom_minimum_size.x = 85
    estado_rede.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    titulo_linha.add_child(estado_rede)

    var linha_dados: HBoxContainer = HBoxContainer.new()
    linha_dados.add_theme_constant_override("separation", 14)
    conteudo.add_child(linha_dados)
    texto_temperatura = _rotulo("+1.50 °C", 21, Color("ffa873"), true)
    texto_temperatura.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    linha_dados.add_child(texto_temperatura)
    texto_carbono = _rotulo("CO₂ 423 ppm", 19, COR_DESTAQUE, true)
    texto_carbono.custom_minimum_size.x = 165
    texto_carbono.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    linha_dados.add_child(texto_carbono)

    var linha_medidas: HBoxContainer = HBoxContainer.new()
    linha_medidas.add_theme_constant_override("separation", 14)
    conteudo.add_child(linha_medidas)
    var coluna_vida: VBoxContainer = VBoxContainer.new()
    coluna_vida.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    linha_medidas.add_child(coluna_vida)
    texto_vida = _rotulo("Biodiversidade 74%", 14, COR_SUAVE)
    coluna_vida.add_child(texto_vida)
    barra_vida = _barra(Color("4dd9a4"))
    coluna_vida.add_child(barra_vida)
    var coluna_estabilidade: VBoxContainer = VBoxContainer.new()
    coluna_estabilidade.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    linha_medidas.add_child(coluna_estabilidade)
    texto_estabilidade = _rotulo("Estabilidade 78%", 14, COR_SUAVE)
    coluna_estabilidade.add_child(texto_estabilidade)
    barra_estabilidade = _barra(Color("6bbff7"))
    coluna_estabilidade.add_child(barra_estabilidade)
    texto_energia = _rotulo("Energia limpa: 35%", 14, COR_SUAVE)
    conteudo.add_child(texto_energia)

    var subtitulo: Label = _rotulo("ESCOLHA UMA ACAO E TOQUE NA TERRA", 12, COR_SUAVE)
    conteudo.add_child(subtitulo)
    var grade: GridContainer = GridContainer.new()
    grade.columns = 2
    grade.add_theme_constant_override("h_separation", 10)
    grade.add_theme_constant_override("v_separation", 9)
    grade.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    conteudo.add_child(grade)
    for entrada in [
        ["meteoro", "METEORO", Color("ff8a5b")],
        ["floresta", "REFLORESTAR", Color("67e7a2")],
        ["energia", "ENERGIA LIMPA", Color("69cbff")],
        ["aquecer", "AQUECER", Color("ffcb79")]
    ]:
        var botao: Button = _botao(entrada[1], entrada[2])
        botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var chave: String = entrada[0]
        botao.pressed.connect(_selecionar_acao.bind(chave))
        grade.add_child(botao)
        botoes[chave] = botao

    var comandos: HBoxContainer = HBoxContainer.new()
    comandos.add_theme_constant_override("separation", 10)
    conteudo.add_child(comandos)
    var avancar: Button = _botao("+ 1 ANO", COR_DESTAQUE)
    avancar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    avancar.pressed.connect(func() -> void: ano_avancado.emit())
    comandos.add_child(avancar)
    var reiniciar: Button = _botao("REINICIAR", Color("ff9e8b"))
    reiniciar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    reiniciar.pressed.connect(func() -> void: jogo_reiniciado.emit())
    comandos.add_child(reiniciar)

    var rodape: Label = _rotulo("Indicadores ilustrativos: nao sao previsoes cientificas.", 11, COR_SUAVE)
    rodape.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    rodape.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    conteudo.add_child(rodape)

    _ajustar_layout()

func _ajustar_layout() -> void:
    if not is_instance_valid(raiz):
        return
    var tela: Vector2 = get_viewport().get_visible_rect().size
    if tela.x < 100.0 or tela.y < 100.0:
        return

    # Geometria calculada em coordenadas do viewport, nao em ancoras
    # dependentes do tamanho minimo de containers dinamicos.
    raiz.position = Vector2.ZERO
    raiz.size = tela
    var margem: float = clampf(tela.x * 0.025, 12.0, 24.0)
    var largura: float = tela.x - margem * 2.0
    var altura_topo: float = 94.0
    topo.position = Vector2(margem, margem)
    topo.size = Vector2(largura, altura_topo)
    linha_topo.position = Vector2(14.0, 10.0)
    linha_topo.size = Vector2(largura - 28.0, altura_topo - 20.0)

    aviso.position = Vector2(margem, margem + altura_topo + 10.0)
    aviso.size = Vector2(largura, 58.0)
    texto_mensagem.position = Vector2(12.0, 6.0)
    texto_mensagem.size = Vector2(largura - 24.0, 46.0)

    var altura_painel: float = clampf(tela.y * 0.41, 330.0, 480.0)
    painel.position = Vector2(margem, tela.y - altura_painel - margem)
    painel.size = Vector2(largura, altura_painel)
    rolagem.position = Vector2(15.0, 14.0)
    rolagem.size = Vector2(largura - 30.0, altura_painel - 28.0)
    conteudo.custom_minimum_size.x = maxf(210.0, rolagem.size.x - 18.0)

func _barra(cor: Color) -> ProgressBar:
    var barra: ProgressBar = ProgressBar.new()
    barra.min_value = 0
    barra.max_value = 100
    barra.show_percentage = false
    barra.custom_minimum_size.y = 9
    var fundo: StyleBoxFlat = _estilo(Color("22314a"), Color.TRANSPARENT, 4)
    fundo.set_content_margin_all(0.0)
    var preenchimento: StyleBoxFlat = _estilo(cor, Color.TRANSPARENT, 4)
    preenchimento.set_content_margin_all(0.0)
    barra.add_theme_stylebox_override("background", fundo)
    barra.add_theme_stylebox_override("fill", preenchimento)
    return barra

func _selecionar_acao(nova_acao: String) -> void:
    acao_atual = nova_acao
    for chave in botoes.keys():
        var botao: Button = botoes[chave]
        var marcado: bool = chave == nova_acao
        var fundo: Color = Color("315575") if marcado else Color("14253f")
        var borda: Color = COR_DESTAQUE if marcado else COR_BORDA
        botao.add_theme_stylebox_override("normal", _estilo(fundo, borda, 12))
        botao.add_theme_color_override("font_color", Color.WHITE if marcado else COR_TEXTO)
    acao_selecionada.emit(nova_acao)

func mudar_estado(dados: Dictionary) -> void:
    texto_ano.text = str(dados["ano"])
    texto_temperatura.text = "%+.2f °C" % dados["temperatura"]
    texto_carbono.text = "CO₂ %.0f ppm" % dados["carbono"]
    texto_vida.text = "Biodiversidade %.0f%%" % dados["biodiversidade"]
    texto_estabilidade.text = "Estabilidade %.0f%%" % dados["estabilidade"]
    barra_vida.value = dados["biodiversidade"]
    barra_estabilidade.value = dados["estabilidade"]
    texto_energia.text = "Energia limpa: %.0f%%  |  Meteoros: %d" % [dados["energia_limpa"], dados["meteoros"]]

func mostrar_mensagem(mensagem: String) -> void:
    texto_mensagem.text = mensagem
