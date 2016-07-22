# Usage: rails new myapp -m neo4j.rb -O

gem 'neo4j'
# gem 'neo4j', github: 'neo4jrb/neo4j', branch: 'rails5' # This was needed when using Rails 5 until a couple weeks ago. Neo4jrb officially supports it now.

# Additional Gems
gem 'neo4jrb-paperclip', :require => 'neo4jrb_paperclip'
gem 'plist'              # For DayOne Entries
gem "font-awesome-rails" # UI glyphs like the Up arrow
gem 'redcarpet'          # Markdown render
gem 'reverse_markdown'   # Convert HTML to markdown. Handy for Importing HTML.


generator = %q[
    config.generators do |g|
      g.orm             :neo4j
    end

    # Configure where the embedded neo4j database should exist
    # Notice embedded db is only available for JRuby
    # config.neo4j.session_type = :embedded_db  # default #server_db
    # config.neo4j.session_path = File.expand_path('neo4j-db', Rails.root)
]

application generator

application_code = "\nrequire 'neo4j/railtie'"
inject_into_file 'config/application.rb', application_code, after: 'require "sprockets/railtie"'

semanticUIRetinaSupport_header = '
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
'

inject_into_file 'app/views/layouts/application.html.erb', semanticUIRetinaSupport_header, after: '<head>'

semanticUI_header = '
    <%= stylesheet_link_tag    "application", media: "all", "data-turbolinks-track": "reload" %>
    <%= javascript_include_tag "application", "data-turbolinks-track": "reload" %>

    <link rel="stylesheet" media="all" href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.2/components/form.min.css">
    <link rel="stylesheet" media="all" href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.2/components/dropdown.min.css">
    <link rel="stylesheet" media="all" href="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.2/semantic.min.css">
    <link rel="stylesheet" media="all" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.6.1/css/font-awesome.css">
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.0.0/jquery.js"></script>
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.2/semantic.min.js"></script>
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.2/components/form.min.js"></script>
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.2.2/components/dropdown.min.js"></script>

    <%= csrf_meta_tags %>
'

# Changed this to replace basically the whole head - It was ending up with a duplicate of the `stylesheet_link_tag` and `javascript_include_tag` lines
gsub_file 'app/views/layouts/application.html.erb', /    <%= csrf_meta_tags %>\n\n    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>\n    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>/, semanticUI_header

yaml_data = <<YAML
development:
  type: server_db
  url: http://localhost:7474
test:
  type: server_db
  url: http://localhost:7575
YAML

create_file 'config/neo4j.yml', yaml_data



changeto_0000_1 = "
require 'rails/commands/server'
module Rails
  class Server
    def default_options
      super.merge(Host:  '0.0.0.0', Port: 3000)
    end
  end
end
"

append_file 'config/boot.rb', changeto_0000_1


changeto_0000_2 = "
  class Application < Rails::Application
    config.web_console.whitelisted_ips = '192.168.0.0/16'
  end
"

inject_into_file 'config/environments/development.rb', changeto_0000_2, after: 'Rails.application.configure do'


# Add the monkeypatch functions to 'config/initializers/' by hardlinking
#`cp -al ./Shared_Code/config_initializers/* config/initializers/` # cp-al doesn't always work on osx
configInitializersTemplatePathString = "./Shared_Code/config_initializers"
configInitializersTemplatePath = File.expand_path(configInitializersTemplatePathString)
Dir.glob("#{configInitializersTemplatePath}/*").select { |fn| 
  if File.file?(fn)
    # puts "Linking config/initializers/*" # Use this line indicate hard link instead of copy (I personally prefer hard linking)
    puts "Copying config/initializers/*"
    # FileUtils.ln fn, "config/initializers/#{File.basename(fn)}", :verbose => true # Use this line to hard link instead of copy (I personally prefer hard linking)
    FileUtils.cp fn, "config/initializers/#{File.basename(fn)}", :verbose => true
  end
} # Only doing a single level of directory structure. Subfolders need '/**/*', and probably more thought


## Add the scaffold templates 
#`cp -al ./Shared_Code/Templates/* lib/`# cp-al doesn't always work on osx
erbTemplatePathString = "./Shared_Code/Templates/templates"
erbTemplatePath = File.expand_path(erbTemplatePathString)
Dir.glob("#{erbTemplatePath}/**/*").select { |fn| 
  if File.file?(fn)
    if localPath = fn.gsub(/#{erbTemplatePath}/, '')
      # puts "Hard linking lib/templates/*/*" # Use this line indicate hard link instead of copy (I personally prefer hard linking)
      puts "Copying lib/templates/*/*"
      FileUtils.mkdir_p("lib/templates#{File.dirname(localPath)}")
      # FileUtils.ln fn, "lib/templates#{localPath}", :verbose => false # Use this line to hard link instead of copy (I personally prefer hard linking)
      FileUtils.cp fn, "lib/templates#{localPath}", :verbose => false
    end
    
  end
} # Must do recursive linking. TEST ON FIRST RUN

markdown_formatter_Redcarpet = '
  def render_markdown(text) #Allows the ability to render markdown inline. Example: `<%= render_markdown(@artefact.content) %>`
    options = {
      filter_html:     true,
      hard_wrap:       true,
      link_attributes: { rel: "nofollow", target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink:           true,
      superscript:        true,
      disable_indented_code_blocks: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end
'

inject_into_file 'app/helpers/application_helper.rb', markdown_formatter_Redcarpet, after: 'module ApplicationHelper'