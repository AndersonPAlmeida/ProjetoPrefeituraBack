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

class CityHallSerializer < ActiveModel::Serializer
  attributes :id, 
    :active, 
    :address_complement, 
    :address_number, 
    :address_street, 
    :block_text, 
    :citizen_access, 
    :citizen_register, 
    :cep, 
    :description, 
    :email, 
    :logo_content_type, 
    :logo_file_name, 
    :logo_file_size, 
    :logo_updated_at, 
    :name, 
    :neighborhood, 
    :phone1, 
    :phone2, 
    :schedule_period, 
    :show_professional, 
    :support_email, 
    :url
  belongs_to :city
end
