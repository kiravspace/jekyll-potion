require_relative "lib/models/page-potion"
require_relative "lib/models/data-page"

require_relative "lib/logger"
require_relative "lib/processor"
require_relative "lib/config"
require_relative "lib/tag"

module Jekyll::Potion
  Config.load_config
end

require_relative "lib/tags/alerts"
require_relative "lib/tags/api"
require_relative "lib/tags/code"
require_relative "lib/tags/file"
require_relative "lib/tags/link"
require_relative "lib/tags/tabs"
