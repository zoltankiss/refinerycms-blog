class FactoryGirlCustomMethods
  # its faster to start a sequence at the last sequence index
  # instead of having to wipe to db between test runs
  def self.starting_sequence_index(model, attribute, regex)
    attributes = model.pluck(attribute.to_sym)
    if attributes.blank?
      0
    else
      attributes.map { |attribute| attribute.match(regex)[1].to_i }.sort { |a, b| b <=> a }.first + 1
    end
  end
end