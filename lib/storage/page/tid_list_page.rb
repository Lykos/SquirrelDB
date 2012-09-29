require 'storage/item_page'
require 'storage/tid'

# TODO Merge this with index_page
module SquirrelDB

  module Storage

    class TidListPage < ItemPage

      def get(tid_no)
        check_address(tid_no)
        @content[tid_start( tid_no )...tid_start( tid_no + 1 )]
      end
      
      def set(tid_no, new_tid)
        check_address( tid_no )
        if new_tid.kind_of?( TID )
          new_tid = new_tid.to_raw
        end
        @content[tid_start( tid_no )...tid_start( tid_no + 1 )] = new_tid
      end

      def remove(tid_no)
        check_address( tid_no )
        @free_space = free_space - TID_SIZE
        @content[tid_start( tid_no )...tid_start( no_tids - 1 )] = @content[tid_start( tid_no + 1 )...tid_start( no_tids )]
        no_tids = no_tids - 1
      end

      def add(tid_no)
        @free_space = free_space - TID_SIZE
        no_tids = no_tids + 1
        @content[tid_start( no_tids - 1 )...tid_start( no_tids )] = tid_no
        no_tids - 1
      end

      private

      alias :no_tids :no_items

      alias :no_tids= :no_items=

      def tid_start(tid_no)
        HEADER_SIZE + tid_no * TID_SIZE
      end

      def free_space
        @free_space ||= PAGE_SIZE - HEADER_SIZE - no_tids * TID_SIZE
      end

    end

  end
  
end
