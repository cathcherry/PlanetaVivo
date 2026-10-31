extends CanvasLayer
## Interface do Planeta Vivo. Controles posicionados conforme a tela Android.

signal acao_selecionada(acao: String)
signal ano_avancado
signal jogo_reiniciado

const COR_FUNDO: Color = Color("09172cee")
const COR_BORDA: Color = Color("34506b")
const COR_TEXTO: Color = Color("e4f0ff")
const COR_SUAVE: Color = Color("8faecb")
const COR_DESTAQUE: Color = Color("72d9f9")

var raiz: Control
var cabecalho: Panel
var rotulo_titulo: Label
var rotulo_subtitulo: Label
var texto_ano: Label
var botao_menu: Button
var painel_noticia: Panel
var texto_mensagem: Label
var painel_controles: Panel
var rolagem: ScrollContainer
var conteudo: VBoxContainer
var menu_fundo: ColorRect
var menu_painel: Panel
var menu_conteudo: VBoxContainer
var menu_titulo: Label
var menu_descricao: Label
var botao_reiniciar: Button
var botao_voltar: Button
var confirmar_reinicio: bool = false

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
    print("Planeta Vivo: MENU DE CONFIGURACOES v0.1.1 ATIVO")
    _montar_interface()
    get_viewport().size_changed.connect(_ajustar_layout)
    call_deferred("_ajustar_layout")
    _selecionar_acao("meteoro")

func _estilo(fundo: Color, borda: Color, raio: int = 14) -> StyleBoxFlat:
    var estilo: StyleBoxFlat = StyleBoxFlat.new()
    estilo.bg_color = fundo
    estilo.border_color = borda
    estilo.set_border_width_all(1)
    estilo.set_corner_radius_all(raio)
    estilo.set_content_margin_all(10.0)
    return estilo

func _rotulo(texto: String, tamanho: int, cor: Color, negrito: bool = false) -> Label:
    var rotulo: Label = Label.new()
    rotulo.text = texto
    rotulo.add_theme_font_size_override("font_size", tamanho)
    rotulo.add_theme_color_override("font_color", cor)
    rotulo.autowrap_mode = TextServer.AUTOWRAP_OFF
    rotulo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    if negrito:
        rotulo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
    return rotulo

func _botao(texto: String, cor: Color) -> Button:
    var botao: Button = Button.new()
    botao.text = texto
    botao.custom_minimum_size.y = 52.0
    botao.add_theme_font_size_override("font_size", 16)
    botao.add_theme_color_override("font_color", COR_TEXTO)
    botao.add_theme_color_override("font_hover_color", Color.WHITE)
    botao.add_theme_stylebox_override("normal", _estilo(Color("14253f"), COR_BORDA, 10))
    botao.add_theme_stylebox_override("hover", _estilo(Color("254567"), cor, 10))
    botao.add_theme_stylebox_override("pressed", _estilo(Color("315777"), cor, 10))
    botao.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
    botao.focus_mode = Control.FOCUS_NONE
    return botao

func _barra(cor: Color) -> ProgressBar:
    var barra: ProgressBar = ProgressBar.new()
    barra.min_value = 0.0
    barra.max_value = 100.0
    barra.show_percentage = false
    barra.custom_minimum_size.y = 9.0
    var fundo: StyleBoxFlat = _estilo(Color("22314a"), Color.TRANSPARENT, 4)
    fundo.set_content_margin_all(0.0)
    var preenchimento: StyleBoxFlat = _estilo(cor, Color.TRANSPARENT, 4)
    preenchimento.set_content_margin_all(0.0)
    barra.add_theme_stylebox_override("background", fundo)
    barra.add_theme_stylebox_override("fill", preenchimento)
    return barra

func _montar_interface() -> void:
    raiz = Control.new()
    raiz.name = "Controles"
    raiz.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(raiz)

    cabecalho = Panel.new()
    cabecalho.name = "Cabecalho"
    cabecalho.mouse_filter = Control.MOUSE_FILTER_PASS
    cabecalho.add_theme_stylebox_override("panel", _estilo(COR_FUNDO, COR_BORDA, 18))
    raiz.add_child(cabecalho)

    rotulo_titulo = _rotulo("PLANETA VIVO", 27, COR_TEXTO, true)
    cabecalho.add_child(rotulo_titulo)
    rotulo_subtitulo = _rotulo("LABORATORIO PLANETARIO · PROTOTIPO 0.1.1", 11, COR_SUAVE)
    cabecalho.add_child(rotulo_subtitulo)
    texto_ano = _rotulo("2026", 20, COR_DESTAQUE, true)
    texto_ano.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    cabecalho.add_child(texto_ano)

    botao_menu = _botao("MENU", COR_DESTAQUE)
    botao_menu.name = "BotaoMenu"
    botao_menu.custom_minimum_size.y = 46.0
    botao_menu.add_theme_font_size_override("font_size", 14)
    botao_menu.pressed.connect(_abrir_menu)
    cabecalho.add_child(botao_menu)

    painel_noticia = Panel.new()
    painel_noticia.name = "Noticia"
    painel_noticia.mouse_filter = Control.MOUSE_FILTER_IGNORE
    painel_noticia.add_theme_stylebox_override("panel", _estilo(Color("0a1b34dd"), Color("315674"), 13))
    raiz.add_child(painel_noticia)
    texto_mensagem = _rotulo("", 14, COR_TEXTO)
    texto_mensagem.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    texto_mensagem.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    painel_noticia.add_child(texto_mensagem)

    painel_controles = Panel.new()
    painel_controles.name = "PainelDeControle"
    painel_controles.mouse_filter = Control.MOUSE_FILTER_STOP
    painel_controles.add_theme_stylebox_override("panel", _estilo(Color("081527f2"), Color("46657f"), 20))
    raiz.add_child(painel_controles)
    rolagem = ScrollContainer.new()
    rolagem.name = "RolagemInterna"
    rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    rolagem.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
    painel_controles.add_child(rolagem)
    conteudo = VBoxContainer.new()
    conteudo.add_theme_constant_override("separation", 10)
    rolagem.add_child(conteudo)

    var linha_titulo: HBoxContainer = HBoxContainer.new()
    conteudo.add_child(linha_titulo)
    var titulo: Label = _rotulo("CONTROLE PLANETARIO", 17, COR_TEXTO, true)
    titulo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    linha_titulo.add_child(titulo)
    var rede: Label = _rotulo("OFFLINE", 12, COR_DESTAQUE)
    rede.custom_minimum_size.x = 82.0
    rede.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    linha_titulo.add_child(rede)

    var linha_dados: HBoxContainer = HBoxContainer.new()
    linha_dados.add_theme_constant_override("separation", 12)
    conteudo.add_child(linha_dados)
    texto_temperatura = _rotulo("+1.50 °C", 20, Color("ffa873"), true)
    texto_temperatura.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    linha_dados.add_child(texto_temperatura)
    texto_carbono = _rotulo("CO₂ 423 ppm", 18, COR_DESTAQUE, true)
    texto_carbono.custom_minimum_size.x = 164.0
    texto_carbono.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    linha_dados.add_child(texto_carbono)

    var linha_medidas: HBoxContainer = HBoxContainer.new()
    linha_medidas.add_theme_constant_override("separation", 12)
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

    conteudo.add_child(_rotulo("ESCOLHA UMA ACAO E TOQUE NA TERRA", 12, COR_SUAVE))
    var grade: GridContainer = GridContainer.new()
    grade.columns = 2
    grade.add_theme_constant_override("h_separation", 10)
    grade.add_theme_constant_override("v_separation", 8)
    grade.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    conteudo.add_child(grade)
    var opcoes: Array = [
        ["meteoro", "METEORO", Color("ff8a5b")],
        ["floresta", "REFLORESTAR", Color("67e7a2")],
        ["energia", "ENERGIA LIMPA", Color("69cbff")],
        ["aquecer", "AQUECER", Color("ffcb79")]
    ]
    for entrada in opcoes:
        var chave: String = entrada[0]
        var botao: Button = _botao(entrada[1], entrada[2])
        botao.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        botao.pressed.connect(_selecionar_acao.bind(chave))
        grade.add_child(botao)
        botoes[chave] = botao

    var botao_ano: Button = _botao("+ 1 ANO", COR_DESTAQUE)
    botao_ano.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    botao_ano.pressed.connect(_avancar_ano)
    conteudo.add_child(botao_ano)

    # Reiniciar fica somente no menu, nao no painel de jogo.
    _criar_menu()
    _ajustar_layout()

func _avancar_ano() -> void:
    ano_avancado.emit()

func _criar_menu() -> void:
    menu_fundo = ColorRect.new()
    menu_fundo.name = "FundoConfiguracoes"
    menu_fundo.color = Color("020815e6")
    menu_fundo.mouse_filter = Control.MOUSE_FILTER_STOP
    menu_fundo.visible = false
    raiz.add_child(menu_fundo)

    menu_painel = Panel.new()
    menu_painel.name = "MenuConfiguracoes"
    menu_painel.add_theme_stylebox_override("panel", _estilo(Color("0b1c32"), COR_BORDA, 20))
    menu_fundo.add_child(menu_painel)

    menu_conteudo = VBoxContainer.new()
    menu_conteudo.add_theme_constant_override("separation", 14)
    menu_painel.add_child(menu_conteudo)
    menu_titulo = _rotulo("CONFIGURACOES", 22, COR_TEXTO, true)
    menu_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    menu_conteudo.add_child(menu_titulo)
    menu_descricao = _rotulo("Gerencie esta sessao do planeta.", 15, COR_SUAVE)
    menu_descricao.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    menu_descricao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    menu_conteudo.add_child(menu_descricao)

    botao_reiniciar = _botao("REINICIAR PLANETA", Color("ff9e8b"))
    botao_reiniciar.pressed.connect(_pedir_reinicio)
    menu_conteudo.add_child(botao_reiniciar)
    botao_voltar = _botao("FECHAR", COR_DESTAQUE)
    botao_voltar.pressed.connect(_fechar_menu)
    menu_conteudo.add_child(botao_voltar)

func _abrir_menu() -> void:
    confirmar_reinicio = false
    _atualizar_menu()
    menu_fundo.visible = true

func _pedir_reinicio() -> void:
    if not confirmar_reinicio:
        confirmar_reinicio = true
        _atualizar_menu()
        return
    menu_fundo.visible = false
    confirmar_reinicio = false
    jogo_reiniciado.emit()

func _fechar_menu() -> void:
    if confirmar_reinicio:
        confirmar_reinicio = false
        _atualizar_menu()
    else:
        menu_fundo.visible = false

func _atualizar_menu() -> void:
    if confirmar_reinicio:
        menu_titulo.text = "REINICIAR PLANETA?"
        menu_descricao.text = "As intervencoes desta sessao serao perdidas."
        botao_reiniciar.text = "SIM, REINICIAR"
        botao_voltar.text = "CANCELAR"
    else:
        menu_titulo.text = "CONFIGURACOES"
        menu_descricao.text = "Gerencie esta sessao do planeta."
        botao_reiniciar.text = "REINICIAR PLANETA"
        botao_voltar.text = "FECHAR"

func _ajustar_layout() -> void:
    if not is_instance_valid(raiz):
        return
    var tela: Vector2 = get_viewport().get_visible_rect().size
    if tela.x < 100.0 or tela.y < 100.0:
        return
    raiz.position = Vector2.ZERO
    raiz.size = tela
    var margem: float = clampf(tela.x * 0.025, 12.0, 24.0)
    var largura: float = tela.x - margem * 2.0
    var altura_cabecalho: float = 94.0
    cabecalho.position = Vector2(margem, margem)
    cabecalho.size = Vector2(largura, altura_cabecalho)
    rotulo_titulo.position = Vector2(14, 10)
    rotulo_titulo.size = Vector2(largura - 192.0, 38.0)
    rotulo_subtitulo.position = Vector2(14, 52)
    rotulo_subtitulo.size = Vector2(largura - 180.0, 20.0)
    texto_ano.position = Vector2(largura - 164.0, 17)
    texto_ano.size = Vector2(74.0, 50.0)
    botao_menu.position = Vector2(largura - 86.0, 21)
    botao_menu.size = Vector2(74.0, 48.0)

    painel_noticia.position = Vector2(margem, margem + altura_cabecalho + 10)
    painel_noticia.size = Vector2(largura, 58.0)
    texto_mensagem.position = Vector2(12.0, 6.0)
    texto_mensagem.size = Vector2(largura - 24.0, 46.0)

    var altura_painel: float = clampf(tela.y * 0.395, 330.0, 465.0)
    painel_controles.position = Vector2(margem, tela.y - altura_painel - margem)
    painel_controles.size = Vector2(largura, altura_painel)
    rolagem.position = Vector2(15.0, 14.0)
    rolagem.size = Vector2(largura - 30.0, altura_painel - 28.0)
    conteudo.custom_minimum_size.x = maxf(210.0, rolagem.size.x - 18.0)

    menu_fundo.position = Vector2.ZERO
    menu_fundo.size = tela
    var largura_menu: float = minf(420.0, tela.x - 36.0)
    var altura_menu: float = 280.0
    menu_painel.position = Vector2((tela.x - largura_menu) * 0.5, (tela.y - altura_menu) * 0.5)
    menu_painel.size = Vector2(largura_menu, altura_menu)
    menu_conteudo.position = Vector2(20.0, 22.0)
    menu_conteudo.size = Vector2(largura_menu - 40.0, altura_menu - 44.0)

func _selecionar_acao(nova_acao: String) -> void:
    acao_atual = nova_acao
    for chave in botoes.keys():
        var botao: Button = botoes[chave]
        var marcado: bool = chave == nova_acao
        var fundo: Color = Color("315575") if marcado else Color("14253f")
        var borda: Color = COR_DESTAQUE if marcado else COR_BORDA
        botao.add_theme_stylebox_override("normal", _estilo(fundo, borda, 10))
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
