class Oauth2Database < OmniAuth::Strategies::OAuth2
  option :name, 'oauth2'

  def initialize(app, *args, &block)

    # database lookup
    config  = Setting.get('auth_oauth2_credentials') || {}
    args[0] = config['app_id']
    args[1] = config['app_secret']
    args[2][:client_options] = args[2][:client_options].merge(config.symbolize_keys)
    super
  end
  
  def callback_url
    full_host + script_name + callback_path
  end

  uid { raw_info['nextgis_guid'] }

  info do
    {
      email: raw_info['email'],
      username: raw_info['first_name'] + ' ' + raw_info['last_name'],
      login: raw_info['email'],
      first_name: raw_info['first_name'],
      last_name: raw_info['last_name'],
    }
  end

  extra do
    {
      'raw_info' => raw_info
    }
  end

  def raw_info
    @raw_info ||= access_token.get('/api/v1/user_info/').parsed
  end

end
