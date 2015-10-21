require 'active_record'

#thes extensions were originall developed for use with the MarskalSearch class
#but they are generic and can be used with any ActiveRecord object
module ActiveRecord

  class Reflection::AssociationReflection
    #get class name from the association symbol
    #ex: Contact.contact_notes.derive_class_from_association()
    def derive_class_from_association()
      eval self.class_name||self.name.to_s.classify
    end

  end

  class Base

    #find the association within the current class
    #ex: Contact.marskal_find_association(:contact_notes)
    def self.marskal_find_association(p_association_symbol)
      l_ret = nil
      self.reflect_on_all_associations.each do |l_association|
        if l_association.name == p_association_symbol
          l_ret = l_association
          break
        end
      end
      l_ret
    end
  end

end