# 'demo' Puppet Provider
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
Puppet::Type.type(:demo).provide(:demo) do
 
  # The class variables are global to ALL providers. Make sure you
  # never reuse names!
  # An easy way to do this is to use @@<providername>_classvars since
  # the provider name has to be globally unique.
  @@demo_classvars = {
    # This provider is set up to only target *one* file. To target
    # multiple files, you'll need to do some creative adjustment to
    # how your provider works.
    :target_file => "/tmp/demo_provider.txt",
 
    # The original content of the target file (if any).
    :old_content => "",
 
    # The new content of the target file.
    # Since we're ordered, we'll hash off of the order and title.
    :new_content => {},
 
    # Don't read the file every time.
    # This is essentially a prefetch without the magic.
    :initialized => false,
 
    # How many resources do we have of the demo type?
    :num_demo_resources => 0,
 
    # How many times have we hit the demo provider?
    :num_runs => 0
  }
 
  def initialize(*args)
    super(*args)
 
    # Check to see if we've already initialized.
    if not @@demo_classvars[:initialized] then
 
      # Load the old file content (if any).
      if File.file?(@@demo_classvars[:target_file]) then
        Puppet::Util::FileLocking.readlock(@@demo_classvars[:target_file]) { |fh|
          # In this case, we're ignoring trailing spaces.
          @@demo_classvars[:old_content] = fh.read.strip
        }
      end
 
      @@demo_classvars[:initialized] = true
    end
  end
 
  def content
    @@demo_classvars[:num_runs] += 1
 
    # Only run through the catalog once.
    if @@demo_classvars[:num_demo_resources] == 0 then
      # How many resources (lines) are we managing?
      @@demo_classvars[:num_demo_resources] =
        # If you had other requirements for matching, then you could
        # process on other type attributes in the catalog.
        resource.catalog.resources.find_all{ |x|
          x.is_a?(Puppet::Type.type(:demo))
        }.count
    end
 
    # Normally, you would do any target manipulation in the
    # prop=(should) # method.
    #
    # However, in this case, this resource may not actually be
    # handling the manipulation of the target file so you have to do
    # the in-memory manipulation in the comparator.
      @@demo_classvars[:new_content]["#{resource[:order]}_#{resource[:name]}"] =
        resource[:content]
 
    # You do not want each resource to drop a log into the log file,
    # only the last one. So we only declare a change on the last
    # entry.
    if @@demo_classvars[:num_runs] == @@demo_classvars[:num_demo_resources] then
      if collate_output != @@demo_classvars[:old_content] then
        return {
          :orig => @@demo_classvars[:old_content],
          :new  => collate_output
        }
      end
    end
 
    # We are not ready to do anything yet, just return yourself so that
    # the resource doesn't trigger.
    return resource[:content]
  end
 
  def content=(should)
    # Don't do anything here, just wait for the flush.
    # We have to wait for all other potential properties to be handled
    # prior to the final dump.
  end
 
  def flush
    # If we've gotten here, then there was something to do. However,
    # we should only get here if all resources have run since nothing
    # else will actually trigger the event.
    Puppet::Util::FileLocking.writelock(@@demo_classvars[:target_file],0644) { |fh|
      fh.rewind
      fh.puts(collate_output)
    }
  end
 
  private
 
  # Sort by the key and output the resulting text.
  def collate_output
    toret = @@demo_classvars[:new_content].keys.sort_by{ |x|
      human_sort(x)
    }.map{ |x|
      @@demo_classvars[:new_content][x]
    }.join("\n")
 
    return toret
  end
 
  def human_sort(obj)
    # This regex taken from
    # http://www.bofh.org.uk/2007/12/16/comprehensible-sorting-in-ruby
    obj.to_s.split(/((?:(?:^|\s)[-+])?(?:\.\d+|\d+(?:\.\d+?(?:[eE]\d+)?(?:$|(?![eE\.])))?))/ms).map { |v|
      Float(v) rescue v.downcase
    }
  end
 
end
