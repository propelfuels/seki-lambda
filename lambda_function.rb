require 'aws-sdk-dynamodb'
require 'json'

DDB = Aws::DynamoDB::Client.new
DDB_TABLE = ENV['DDB_TABLE_NAME']
DENIED = {isAuthorized: false}

def lambda_handler(event:, context:)
  return nil unless authorizer_event?(event)
  (t, id, r, m, ip) = parse_event(event)
  ts = Time.now.to_i
  return DENIED if t.nil?
  db_req = {
    key: {
      'token' => t,
      'path' => "#{id}#{r}",
    },
    table_name: DDB_TABLE,
  }
  db_res = DDB.get_item(db_req)
  return DENIED unless (item = db_res.item)
  return DENIED unless item['valid']
  if item['methods'].class == Array
    return DENIED unless item['methods'].include?(m)
  end
  if item['valid_from']
    return DENIED unless ts >= item['valid_from']
  end
  if item['valid_until']
    return DENIED unless ts <= item['valid_until']
  end
  allowed = {isAuthorized: true}
  allowed[:context] = item['context'] if item['context'].class == Hash
  allowed
end

def authorizer_event?(e)
  e['version'] == '2.0' && e['type'] == 'REQUEST'
end

def parse_event(e)
  r = e['routeKey'].split(nil, 2)[1]
  t = e.dig('identitySource', 0)
  id = e.dig('requestContext', 'apiId')
  m = e.dig('requestContext', 'http', 'method')
  ip = e.dig('requestContext', 'http', 'sourceIp')
  m.downcase! if m.class == String
  if t.class == String
    ta = t.split(nil, 2)
    case ta.length
    when 0
      t = nil
    when 1
      t = ta[0]
    when 2
      t = ta[1] if ta[0] == 'Bearer'
    end
  end
  [t, id, r, m, ip]
end
