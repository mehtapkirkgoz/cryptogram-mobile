extends Node

const CODES = ["tr", "en", "de", "fr", "es"]
var current := "tr"
var catalog: Dictionary = {}

func _ready() -> void:
	for code in CODES:
		catalog[code] = JSON.parse_string(FileAccess.get_file_as_string("res://data/%s.json" % code))
	_expand_puzzles("tr", ["MERAK", "CESARET", "SABIR", "DOSTLUK", "NEŞE", "UMUT", "BİLGİ", "DENGE", "SEVGİ", "EMEK"], ["YENİ YOLLAR AÇAR", "GÜÇ VERİR", "GÜZEL GÜNLER GETİRİR", "KALBİ ISITIR", "HER ŞEYİ DEĞİŞTİRİR", "İÇİMİZİ AYDINLATIR", "BİZİ İLERLETİR", "YARINI KURAR", "HAYATA RENK KATAR", "ZAMANI DEĞERLİ KILAR"])
	_expand_puzzles("en", ["CURIOUS MINDS", "SMALL HABITS", "KIND WORDS", "BRAVE CHOICES", "QUIET MOMENTS", "FRESH IDEAS", "OPEN HEARTS", "PATIENT HANDS", "DAILY PRACTICE", "CLEAR GOALS"], ["OPEN NEW DOORS", "BRING BRIGHT DAYS", "MAKE ROOM FOR GROWTH", "SHAPE A BETTER PATH", "TURN QUESTIONS INTO WISDOM", "CREATE A LITTLE JOY", "BUILD TRUST OVER TIME", "HELP US MOVE FORWARD", "MAKE EACH STEP COUNT", "KEEP HOPE ALIVE"])
	_expand_puzzles("de", ["NEUGIERIGE MENSCHEN", "KLEINE SCHRITTE", "GUTE WORTE", "MUTIGE WAHLEN", "RUHIGE MOMENTE", "FRISCHE IDEEN", "OFFENE HERZEN", "GEDULDIGE HÄNDE", "TÄGLICHE ÜBUNG", "KLARE ZIELE"], ["ÖFFNEN NEUE TÜREN", "BRINGEN HELLE TAGE", "SCHAFFEN NEUE WEGE", "GEBEN UNS KRAFT", "MACHEN FRAGEN KLAR", "BRINGEN FREUDE", "BAUEN VERTRAUEN AUF", "FÜHREN UNS WEITER", "LASSEN UNS WACHSEN", "HALTEN HOFFNUNG WACH"])
	_expand_puzzles("fr", ["LES ESPRITS CURIEUX", "LES PETITS PAS", "LES MOTS GENTILS", "LES CHOIX COURAGEUX", "LES MOMENTS CALMES", "LES IDÉES NEUVES", "LES CŒURS OUVERTS", "LES MAINS PATIENTES", "LA PRATIQUE QUOTIDIENNE", "LES OBJECTIFS CLAIRS"], ["OUVRENT DE NOUVELLES PORTES", "APPORTENT DES JOURS LUMINEUX", "CRÉENT UN CHEMIN", "DONNENT DE LA FORCE", "TRANSFORMENT LES QUESTIONS", "FONT NAÎTRE LA JOIE", "BÂTISSENT LA CONFIANCE", "NOUS FONT AVANCER", "NOUS AIDENT À GRANDIR", "GARDENT L ESPOIR VIVANT"])
	_expand_puzzles("es", ["LAS MENTES CURIOSAS", "LOS PASOS PEQUEÑOS", "LAS PALABRAS AMABLES", "LAS ELECCIONES VALIENTES", "LOS MOMENTOS TRANQUILOS", "LAS IDEAS NUEVAS", "LOS CORAZONES ABIERTOS", "LAS MANOS PACIENTES", "LA PRÁCTICA DIARIA", "LOS OBJETIVOS CLAROS"], ["ABREN NUEVAS PUERTAS", "TRAEN DÍAS BRILLANTES", "CREAN UN CAMINO", "DAN NUEVA FUERZA", "CONVIERTEN PREGUNTAS EN SABIDURÍA", "HACEN NACER LA ALEGRÍA", "CONSTRUYEN CONFIANZA", "NOS HACEN AVANZAR", "NOS AYUDAN A CRECER", "MANTIENEN VIVA LA ESPERANZA"])

func _expand_puzzles(code: String, subjects: Array, predicates: Array) -> void:
	var pool: Array = catalog[code].puzzles
	for index in range(94):
		var sentence := "%s %s." % [subjects[index % subjects.size()], predicates[(int(index / subjects.size())) % predicates.size()]]
		pool.append({"id": "%s_%d" % [code, index + 7], "text": sentence, "topic": "Practice %d" % (index + 1)})
	catalog[code].puzzles = pool

func info() -> Dictionary:
	return catalog[current]

func text(key: String) -> String:
	return info().ui.get(key, key)

func puzzles() -> Array:
	return info().puzzles
