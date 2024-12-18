require "pagy/extras/array"
require "pagy/extras/metadata"

# Pagy initializer file
# See https://ddnexus.github.io/pagy/api/pagy#configuration
Pagy::DEFAULT.merge!(
  items: 20,        # Default items per page
  max_items: 1000,   # Max items per page
  metadata: [ :page, :count, :pages, :prev, :next ]  # Extra metadata
)
