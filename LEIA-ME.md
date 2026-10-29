# Planeta Vivo — protótipo 0.1

**Projeto Godot 4.7 / GDScript para Android**

Este ZIP contém um projeto Godot completo, **não apenas arquivos de código isolados**. Você não precisa adicionar nós, materiais, imagens, iluminação nem telas manualmente. O jogo usa o renderizador Compatibility para facilitar testes em Android (inclusive em alguns emuladores). A aparência final depende do dispositivo e de seus drivers gráficos.

## Importar no Godot (IMPORTANTE)

1. **Extraia o ZIP** em uma pasta normal, por exemplo `Documentos/PlanetaVivo_Godot_Android`.
2. No **Gerenciador de Projetos** do Godot, clique em **Importar**.
3. Escolha o arquivo **`project.godot`** da pasta extraída (não selecione o ZIP).
4. Abra o projeto. Na primeira abertura, o Godot precisará importar as três imagens.
5. Pressione **F5** ou clique no botão **Executar Projeto**. A cena principal já está configurada.

**Se o projeto PlanetaVivo vazio que você criou antes estiver aberto:** pode mantê-lo como está. Importe esta nova pasta como OUTRO projeto; não misture os arquivos manualmente.

## Controles

| Computador | Celular Android |
|---|---|
| Arrastar com o botão esquerdo: girar globo | Arrastar com um dedo: girar globo |
| Roda do mouse: zoom | Pinça com dois dedos: zoom |
| Escolher ação e clicar na esfera | Escolher ação e tocar na esfera |
| Botão + 1 ANO: avançar o tempo | Mesmo botão na tela |
| Botão REINICIAR: voltar ao início | Mesmo botão na tela |

### O que já está incluído

- Cena `principal.tscn` com Terra 3D, imagem real da superfície, segunda esfera com nuvens, halo atmosférico, céu estrelado, câmera e Sol.
- Rotação e zoom para mouse ou toque, com zoom limitado.
- Painel inicial para tela **vertical** com ano, temperatura, CO₂, biodiversidade, estabilidade e energia limpa.
- Quatro ações experimentais: **meteoro**, **reflorestar**, **energia limpa** e **aquecer**.
- Marcadores luminosos na superfície onde você toca, textos de resultado e alteração dos indicadores.
- Botões de avanço de ano e reinício.
- Funcionamento **offline**. Nenhuma API, login ou servidor necessário.

**Aviso:** as consequências ambientais são números ilustrativos de jogabilidade, **não resultados validados cientificamente**. Ações ainda não deformam fisicamente a crosta da Terra nem simulam países. Os efeitos são marcadores visuais de prototipagem.

## Colocar para funcionar no Android

1. Instale os **modelos de exportação** correspondentes à versão do Godot: menu **Editor > Gerenciar Modelos de Exportação** (o nome pode variar conforme o idioma).
2. Abra **Editor > Configurações do Editor > Exportação > Android** e configure:
   - **Java SDK Path:** pasta do JDK 17.
   - **Android SDK Path:** pasta do SDK instalada pelo Android Studio, frequentemente `%LOCALAPPDATA%\\Android\\Sdk` no Windows. Confirme no seu Android Studio.
3. Abra **Projeto > Exportar**. A predefinição **Android** já está incluída (`export_presets.cfg`). Confira as opções e siga os avisos de pacotes necessários. O identificador inicial é `org.planetavivo.simulador`.
4. Gere um **APK de teste**; instale no seu celular ou use **implantação remota** com dispositivo conectado por USB e depuração habilitada.
5. Teste rotação, pinça, toques, desempenho e legibilidade. Se houver erros, compartilhe a janela **Saída / Depurador** do Godot.

**Não incluí um APK pronto**, pois os modelos de exportação e o SDK Android precisam estar instalados na sua máquina. O ZIP é um projeto-fonte para importar e exportar pelo Godot.

## Estrutura

```text
PlanetaVivo_Godot_Android/
├── project.godot
├── export_presets.cfg      # Predefinição Android (sem chaves ou credenciais)
├── scenes/
│   └── principal.tscn
├── scripts/
│   ├── principal.gd          # Entrada por mouse/toque, câmera e ações
│   ├── terra.gd              # Rotação, nuvens e marcadores
│   ├── interface.gd          # Painel e botões
│   └── simulacao.gd          # Estado experimental da Terra
├── shaders/
│   └── atmosfera.gdshader
├── assets/
│   ├── terra.jpg
│   ├── nuvens.png
│   └── estrelas.jpg
└── docs/
    └── CREDITOS.md
```

## Qualidade visual e próximos passos

Esta é uma **base gráfica jogável**, não uma reprodução de Solar Smash. Nesta versão os impactos criam pequenos pontos luminosos, sem crateras ou danos permanentes; o visual de destruição avançado, fumaça, fogo e alterações da superfície serão implementados em versões posteriores.

O foco inicial foi manter arquitetura limpa, recursos leves e suporte Android. A renderização *Compatibility* foi escolhida pensando em compatibilidade; se o aparelho tiver suporte Vulkan estável, podemos futuramente experimentar o renderizador *Mobile* para qualidade e performance.

## Observação sobre testes

Os arquivos foram montados e conferidos estaticamente. Este ambiente não possui uma instalação do executável Godot para iniciar a cena, nem emulador Android; portanto, **a primeira execução real e a exportação ainda precisam ser validadas no seu computador**. Caso apareça uma mensagem de erro, envie texto ou captura do painel de saída.
