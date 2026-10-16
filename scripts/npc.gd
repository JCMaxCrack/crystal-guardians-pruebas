extends Node2D

@export var npc_name: String = "Anciano"

@onready var interactive_area: Area2D = $InteractiveArea
var player_nearby: bool = false

func _ready() -> void:
	if not interactive_area.body_entered.is_connected(_on_interactive_area_body_entered):
		interactive_area.body_entered.connect(
			_on_interactive_area_body_entered
		)
	if not interactive_area.body_exited.is_connected(_on_interactive_area_body_exited):
		interactive_area.body_exited.connect(
			_on_interactive_area_body_exited
		)
	
func _process(_delta: float) -> void:
	if player_nearby and Input.is_action_just_pressed("interact"):
		var dialogue_ui = get_dialogue_ui()
		if dialogue_ui != null and dialogue_ui.is_open:
			dialogue_ui.next_dialogue()
		else:
			interact()

func get_dialogue_ui() -> Node:
	return get_tree().get_first_node_in_group("dialogue_ui")

func interact() -> void:
	var dialogue_ui = get_dialogue_ui()
	if dialogue_ui == null:
		return

	var dialogues: Array[String] = []

	match QuestManager.quest_state:
		QuestManager.QuestState.NOT_STARTED:
			dialogues = [
				"¡Hola, viajero! Los guardias han robado los cristales sagrados.",
				"Necesito que recojas %d cristales y me los traigas." % QuestManager.required_crystals,
				"Ten cuidado con los guardias que los protegen."
			]
			QuestManager.start_quest()

		QuestManager.QuestState.ACTIVE:
			dialogues = [
				"Aún te faltan cristales por recoger.",
				"Llevas %d de %d cristales." % [
					QuestManager.collected_crystals,
					QuestManager.required_crystals
				]
			]

		QuestManager.QuestState.READY_TO_DELIVER:
			dialogues = [
				"¡Has recuperado todos los cristales!",
				"Muchas gracias, guardián. La aldea está a salvo."
			]
			QuestManager.complete_quest()

		QuestManager.QuestState.COMPLETED:
			dialogues = [
				"Gracias de nuevo por tu ayuda, guardián del cristal."
			]

	dialogue_ui.show_dialogue(npc_name, dialogues)

func _on_interactive_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true


func _on_interactive_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		var dialogue_ui = get_dialogue_ui()
		if dialogue_ui != null and dialogue_ui.is_open:
			dialogue_ui.close_dialogue()
