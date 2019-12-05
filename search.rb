require 'sinatra'
require 'mysql2'
require 'json'

puts ENV['user']

Mysqlclient = Mysql2::Client.new(host: 'mysql',
                                 username: ENV['user'],
                                 password: ENV['pwd'],
                                 database: ENV['db'])

def full_text_search(term)
  Mysqlclient.query("SELECT 
  field_path_value,
  field_short_description_value,
  title
FROM 
  node__field_short_description AS descr 
LEFT JOIN 
  node__field_instructions AS instr  
ON descr.entity_id = instr.entity_id
LEFT JOIN 
  node__body AS body
ON descr.entity_id = body.entity_id
LEFT JOIN 
  node__field_tags AS tags
ON descr.entity_id = tags.entity_id
LEFT JOIN 
  node__field_path AS paths
ON descr.entity_id = paths.entity_id
LEFT JOIN 
  node_field_data AS data
ON descr.entity_id = data.nid
WHERE MATCH(field_short_description_value) AGAINST('#{term}')
  OR MATCH(field_instructions_value) AGAINST('#{term}')
  OR MATCH(body_value) AGAINST('#{term}')
  OR MATCH(field_tags_value) AGAINST('#{term}');", :as => :hash).to_a
end

get '/' do
  data = full_text_search params[:term]
  content_type :json
  data.to_json
end