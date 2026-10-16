extends Node2D

@onready var crystal_label: Label = \
	$UI/HUD/CrystalLabel

func _ready() -> void:
	var crystals := $crystals.get_children()

	QuestManager.required_crystals = crystals.size()

	for crystal in crystals:
		if not crystal.collected.is_connected(_on_crystal_collected):
			crystal.collected.connect(
				_on_crystal_collected
			)

	QuestManager.quest_updated.connect(update_crystal_label)

	update_crystal_label()

func _on_crystal_collected() -> void:
	update_crystal_label()

	if QuestManager.quest_state == QuestManager.QuestState.READY_TO_DELIVER:
		print("¡Todos los cristales recolectados!")

func update_crystal_label() -> void:
	crystal_label.text = "Cristales: %d / %d" % [
		QuestManager.collected_crystals,
		QuestManager.required_crystals
	]
