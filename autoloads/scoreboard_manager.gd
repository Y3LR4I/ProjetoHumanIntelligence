extends Node

signal score_submitted(success: bool)
signal scores_received(scores: Array)

const SUPABASE_URL: String = "https://njcwkyxslchxhnbsmsif.supabase.co"
const SUPABASE_ANON_KEY: String = "sb_publishable_dX01f-iP3fn6G1O-Na_m6A_ThF5hknO"


func submit_score(player_name: String, score: int) -> void:
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_submit_completed.bind(http_request))

	var url := "%s/rest/v1/scores" % SUPABASE_URL
	var headers := _build_headers()
	headers.append("Prefer: return=minimal")

	var body := JSON.stringify({
		"player_name": player_name,
		"score": score,
	})

	var error := http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("ScoreboardManager: falha ao iniciar submit_score (%s)" % error)
		http_request.queue_free()
		score_submitted.emit(false)


func get_top_scores(limit: int = 10) -> void:
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_scores_completed.bind(http_request))

	var url := "%s/rest/v1/scores?select=player_name,score,created_at&order=score.desc&limit=%d" % [SUPABASE_URL, limit]
	var headers := _build_headers()

	var error := http_request.request(url, headers, HTTPClient.METHOD_GET)
	if error != OK:
		push_error("ScoreboardManager: falha ao iniciar get_top_scores (%s)" % error)
		http_request.queue_free()
		scores_received.emit([])


func _build_headers() -> Array[String]:
	return [
		"apikey: %s" % SUPABASE_ANON_KEY,
		"Authorization: Bearer %s" % SUPABASE_ANON_KEY,
		"Content-Type: application/json",
	]


func _on_submit_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest) -> void:
	http_request.queue_free()
	var success := response_code >= 200 and response_code < 300
	if not success:
		push_error("ScoreboardManager: erro ao registrar score (HTTP %d) - %s" % [response_code, body.get_string_from_utf8()])
	score_submitted.emit(success)


func _on_scores_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, http_request: HTTPRequest) -> void:
	http_request.queue_free()
	if response_code < 200 or response_code >= 300:
		push_error("ScoreboardManager: erro ao buscar placar (HTTP %d) - %s" % [response_code, body.get_string_from_utf8()])
		scores_received.emit([])
		return

	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		push_error("ScoreboardManager: falha ao parsear resposta do placar")
		scores_received.emit([])
		return

	scores_received.emit(json.data)
