class WebConfig::Router
  def call(env)
    find_route(env).call(env)
  end

private

  def initialize(&block)
    @routes = []
    instance_exec(&block)
  end

  def find_route(env)
      @routes.each do |route|
      if env['REQUEST_METHOD'] == route[:method] && env['REQUEST_PATH'] =~ route[:regexp_in_path]
        env['router.params'] = extract_params(route[:pattern], env['REQUEST_PATH'])
        return route[:app]
      end
    end

    return ->(_env) { [404, {}, ['Page not found']] }
  end

  def get(path, rack_app)
    match('GET', path, rack_app)
  end

  def post(path, rack_app)
    match('POST', path, rack_app)
  end

  def match(http_method, path, rack_app)
    rack_app = get_controller_action(rack_app) if rack_app.is_a?(String)
    @routes << { 
      pattern: path, 
      app: rack_app, 
      regexp_in_path: path_to_regexp(path), 
      method: http_method, 
      regexp: prepare_route_regex(path)}
  end


  def get_controller_action(str)
    controller_name, action_name = str.split('#') # tests#show => ['tests', 'show']
    controller_name = to_upper_camel_case(controller_name)
    Kernel.const_get(controller_name).send(:action, action_name)
  end

  def to_upper_camel_case(str)
    str # 'public_pages/tests' => PublicPages::TestsController
      .split('/') # ['public_pages', 'test']
      .map { |part| part.split('_').map(&:capitalize).join } # ['PublicPages', 'Test']
      .join('::') + 'Controller'
  end

  def prepare_route_regex(path)
    arr = path.split('/')
    temp = arr.map do |e|
      if e[0] == ':'
        name = e[1..-1]
        "(?<#{name}>\\w+)" 
      else
        e
      end 
    end
    reg_str = "^#{temp.join('\/')}$"
    Regexp.new(reg_str)
  end

  def path_to_regexp(path)
    Regexp.new('\A' + path.gsub(/:[\w-]+/, '[\w-]+') + '\Z')
  end

  def extract_params(pattern, path)
    pattern
      .split('/') # ['post', ':name']
      .zip(path.split('/')) # [['post', 'post'],[':name', 'post']]
      .reject { |e| e.first == e.last } # [[':name', 'post']]
      .map { |e| [e.first[1..-1], e.last] } # [['name', 'post']]
      .to_h
  end
end