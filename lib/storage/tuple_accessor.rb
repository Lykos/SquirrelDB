require 'storage/tid'

module RubyDB

  module Storage

    class TupleAccessor

      def initialize( page_accessor )
        @page_accessor = page_accessor
      end

      include Constants

      def get( tids )
        tids.sort!
        tuple_nos = []
        results = []
        moved_tids = []
        tids.each_with_index do |t, i|
          tuple_nos.push( t.tuple_no )
          if i + 1 >= tids.length or tids[i + 1].page_no > t.page_no
            new_results, new_tids = get_page( t.page_no, tuple_nos )
            results += new_results
            moved_tids += new_tids
            tuple_nos = []
          end
        end
        results += get( moved_tids ) unless moved_tids.empty?
        results
      end

      def get_tuple( tid )
        results, moved_tids = get_page( tid.page_no, [tid.tuple_no] )
        unless moved_tids.empty?
          raise if moved_tids.length > 0 || !results.empty?
          results, moved_tids = get_page( tid.page_no, moved_tids )
          raise unless results.length == 1 and moved_tids.empty?
        end
        raise if results.length != 1
        results[0]
      end

      def set( tids, values )
        raise ArgumentError.new( "tids and values have different lengths." ) if tids.length != values.length
        tids_values = tids.zip( values )
        tids_values.sort! { |tv1, tv2| tv1[0] <=> tv2[0] }
        tuple_nos = []
        page_values = []
        tids_values.each_with_index do |tv, i|
          tuple_nos.push( tv[0].tuple_no )
          page_values.push( tv[1] )
          if i + 1 >= tids_values.length or tids_values[i + 1][0].page_no > tv[0].page_no
            set_page( tv[0].page_no, tuple_nos, page_values )
            tuple_nos = []
            page_values = []
          end
        end
      end

      def remove_tuple( tid )
        remove_page( tid.page_no, [tid.tuple_no] )
      end

      def remove( tids )
        tids.sort!
        tuple_nos = []
        tids.each_with_index do |t, i|
          tuple_nos.push( t.tuple_no )
          if i + 1 >= tids.length or tids[i + 1].page_no > t.page_no
            remove_page( t.page_no, tuple_nos )
            tuple_nos = []
          elsif tids[i + 1].page_no < t.page_no
            raise
          end
        end
      end

      def set_tuple( tid, value )
        set_page( tid.page_no, [tid.tuple_no], [value] )
      end

      def add_tuple( value )
        page_no = 0
        tuple_no = nil
        page = nil
        length = value.bytesize
        # TODO find free page more efficiently
        loop do
          page = @page_accessor.get( page_no )
          if page.has_space?( length )
            tuple_no = page.add_tuple( value )
            break
          end
          page_no += 1
        end
        @page_accessor.put( page )
        return TID.new( page_no, tuple_no )
      end

      def close
        @page_accessor.close
      end

      private

      def get_page( page_no, tuple_nos )
        results = []
        tids = []
        page = @page_accessor.get( page_no )
        tuple_nos.each do |tuple_no|
          if page.moved?( tuple_no )
            tids.push( page.get_tid( tuple_no ) )
          else
            results.push( page.get_tuple( tuple_no ) )
          end
        end
        [results, tids]
      end

      def set_page( page_no, tuple_nos, values )
        page = @page_accessor.get( page_no )
        tuple_nos.each_with_index do |t, i|
          v = values[i]
          # TODO check for moved
          if page.can_resize?( t, v.bytesize )
            page.set_tuple( t, v )
          else
            page.set_tid( t, add_tuple( values ) )
          end
        end
        @page_accessor.put( page )
      end

      def remove_page( page_no, tuple_nos )
        page = @page_accessor.get( page_no )
        tuple_nos.each { |t| page.remove_tuple( t ) }
        @page_accessor.put( page )
      end
      
    end
    
  end

end
