module SquirrelDB
  
  module Data

    module Constants

      # TODO Find a better place for these constants
      INTERNAL_SCOPE = "#internal#"
      TOPLEVEL_SCOPE_ID = 1
      INTERNAL_TABLE_IDS = {
        "schemata" => 1,
        "variables" => 2,
        "tables" => 3,
        "sequences" => 4
      }
      
      META_DATA_PAGE_NO = 0
      INTERNAL_PAGE_NOS = {
        1 => 1,
        2 => 2,
        3 => 3,
        4 => 4
      }
            
    end

  end
  
end
