require './.guard/templates/copier.rb'

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
  watch(%r{theme/scss/.*})
end

guard :css_copier do
  watch(%r{theme/css/.*})
end

guard :haml_compiler do
  watch('config/presentation.json')
  watch(%r{templates/.*})
end

guard :haml_compiler do
  watch('config/presentation.json')
  watch(%r{content/.*})
end
