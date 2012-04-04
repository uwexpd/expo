# A ManualPopulation is a special type of Population that is not based on query, but rather on a specific set of objects that are supplied by the user. Thus this type of population cannot be "regenerated" or modified in any automated way.
class ManualPopulation < Population

  def objects_generated_at
    updated_at
  end

  def objects(force = false)
    collect_objects
  end

  def generate_objects!
    true
  end

  protected

  # Collects the objects based on the object_ids instead of re-generating the entire collection
  def collect_objects
    results = []
    begin
      object_ids.each do |model_name, ids|
        results << model_name.to_s.constantize.find(ids)
      end
      results.flatten
    # rescue ActiveRecord::RecordNotFound
    #   generate_objects!
    #   collect_objects
    end
  end

  
end