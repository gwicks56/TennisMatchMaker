json.array!(@matches) do |match|
  json.extract! match, :id, :player1_id, :player2_id, :player3_id, :player4_id, :start, :end, :court, :desc, :match_type, :conversation_id
  json.url match_url(match, format: :json)
end
