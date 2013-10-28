require './.guard/templates/do_thingers.rb'

guard :image_copier do
  watch(%r{images/.*})
end

guard :js_copier do
  watch(%r{js/.*})
end

guard :js_config do
  watch('config/presentation.json')
end

guard :sass_compiler do
  watch(%r{(theme/scss/.*|config/presentation\.json)})
end

guard :haml_compiler do
  watch(%r{(templates/.*|content/.*|config/presentation\.json)})
end
