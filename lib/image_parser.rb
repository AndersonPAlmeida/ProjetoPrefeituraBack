# This file is part of Agendador.
#
# Agendador is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Agendador is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Agendador.  If not, see <https://www.gnu.org/licenses/>.

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
