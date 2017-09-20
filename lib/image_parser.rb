module Agendador
  module Image
    class Parser

      def self.parse(image_data)
        @tempfile = Tempfile.new('item_image')
        @tempfile.binmode
        @tempfile.write Base64.decode64(image_data[:content])
        @tempfile.rewind

        uploaded_file = ActionDispatch::Http::UploadedFile.new(
          tempfile: @tempfile,
          filename: image_data[:filename]
        )

        uploaded_file.content_type = image_data[:content_type]
        uploaded_file
      end  

      def self.clean_tempfile
        if @tempfile
          @tempfile.close
          @tempfile.unlink
        end
      end
    end  
  end  
end
