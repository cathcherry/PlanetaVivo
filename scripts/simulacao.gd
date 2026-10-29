extends RefCounted
## Valores ilustrativos para uma experiência de jogo, NÃO previsões científicas.

var ano: int = 2026
var temperatura: float = 1.5
var carbono: float = 423.0
var biodiversidade: float = 74.0
var estabilidade: float = 78.0
var energia_limpa: float = 35.0
var meteoros: int = 0

func reiniciar() -> void:
    ano = 2026
    temperatura = 1.5
    carbono = 423.0
    biodiversidade = 74.0
    estabilidade = 78.0
    energia_limpa = 35.0
    meteoros = 0

func agir(acao: String) -> String:
    match acao:
        "meteoro":
            meteoros += 1
            biodiversidade -= 8.0
            estabilidade -= 12.0
            temperatura += 0.12
            return "Impacto detectado! Ecossistemas e infraestrutura foram afetados."
        "floresta":
            biodiversidade += 5.0
            carbono -= 1.5
            return "Projeto de recuperacao ambiental iniciado."
        "energia":
            energia_limpa += 8.0
            return "Investimento em energia limpa realizado."
        "aquecer":
            temperatura += 0.25
            estabilidade -= 2.0
            return "Aumento artificial da temperatura global."
    return "Nenhuma intervencao selecionada."

func passar_ano() -> String:
    ano += 1
    # Regras de jogo simplificadas, não física climática quantitativa.
    carbono += (100.0 - energia_limpa) * 0.11
    carbono -= max(0.0, biodiversidade - 74.0) * 0.022
    temperatura += max(0.0, carbono - 410.0) * 0.00075
    biodiversidade -= max(0.0, temperatura - 1.4) * 0.14
    estabilidade -= max(0.0, temperatura - 1.7) * 0.15
    _limitar()
    if temperatura >= 3.0:
        return "Ano %d: crise climatica em agravamento." % ano
    if biodiversidade > 80.0:
        return "Ano %d: ecossistemas mostram recuperacao." % ano
    return "Ano %d: novos dados planetarios disponiveis." % ano

func _limitar() -> void:
    carbono = clampf(carbono, 250.0, 2000.0)
    temperatura = clampf(temperatura, -10.0, 15.0)
    biodiversidade = clampf(biodiversidade, 0.0, 100.0)
    estabilidade = clampf(estabilidade, 0.0, 100.0)
    energia_limpa = clampf(energia_limpa, 0.0, 100.0)

func estado() -> Dictionary:
    _limitar()
    return {
        "ano": ano,
        "temperatura": temperatura,
        "carbono": carbono,
        "biodiversidade": biodiversidade,
        "estabilidade": estabilidade,
        "energia_limpa": energia_limpa,
        "meteoros": meteoros
    }
