# Config for Non-production Environments
unless Rails.env.production?
  Paperclip::Attachment.default_options[:validate_media_type] = false

  Paperclip::Attachment.default_options.merge!({

  })

  Paperclip::Attachment.default_options.update({
#    :url => "/public/:class/:attachment/:id_partition/:style/:basename.:hash.:extension", # Only here as an example
#    hash_secret: Rails.application.secrets.secret_key_base
    hash_secret: "" # Hopefully this lets us verify the hash externally by using the same "secret"
  })

  Paperclip.options[:content_type_mappings] = {
    json: ["/\Atext\/.*\Z/", "application/json"]
  }
end