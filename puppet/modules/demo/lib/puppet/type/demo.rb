# 'demo' Puppet Type
#
# Copyright 2013 Onyx Point, Inc.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module Puppet
  newtype(:demo) do
    @doc = <<-EOM
      A demo type for showing how to use final provider execution.
 
      Puts together a file at /tmp/demo_provider.txt with ordered
      lines based on the combination of the 'order' and 'name'
      parameters.
    EOM
 
    def initialize(args)
      super(args)
    end
 
    newparam(:name) do
      desc "An arbitrary, but unique, name for the resource."
 
      isnamevar
    end
 
    newparam(:order) do
      desc <<-EOM
        The numeric order in which items should be arranged.
        In the case of a tie, resources are ordered by :name.
 
        Default: 100
      EOM
 
      newvalues(/^(\d+)$/)
 
      defaultto('100')
    end
 
    newproperty(:content) do
      desc <<-EOM
        The actual content of the line in the file.
      EOM
 
      isrequired
 
      def change_to_s(current_value,new_value)
        return "Changing\n'#{current_value[:orig]}'\nTo\n'#{current_value[:new]}'"
      end
    end
 
    validate do
      if not self[:content] then
        raise(ArgumentError,"Hey, where's the content?")
      end
    end
  end
end
