require 'ruby-prof/abstract_printer'
require 'yaml'

module RubyProf
  # Generates call stack profile reports as yaml.
  # To use the yaml graph printer:
  #
  #   result = RubyProf.profile do
  #     [code to profile]
  #   end
  #
  #   printer = RubyProf::GraphYamlPrinter.new(result)
  #   printer.print(STDOUT, 0)
  #
  class GraphYamlPrinter < AbstractPrinter
    # Print a yaml graph profile report to the provided output.
    #
    # output - Any IO oject, including STDOUT or a file.
    # The default value is STDOUT.
    #
    # options - Hash of print options.  See #setup_options
    #           for more information.
    #
    def print(output = STDOUT, options = {})
      @output = output
      setup_options(options)
      gather_threads
      print_result
    end

    private

    def gather_threads
      calculate_thread_times
      @result_yaml = {"total_time" => @thread_times[:total_time], "threads" => {}}
      
      @result.threads.each do |thread_id, methods|
        @result_yaml["threads"][thread_id] = 
          {"total_time" => @thread_times[:threads][thread_id], "methods" => {}}
        
        gather_methods(thread_id, methods)
      end
    end
    
    def gather_methods(thread_id, methods)
      methods = methods.sort

      toplevel = methods.last
      total_time = [toplevel.total_time, 0.01].max
      
      methods.reverse_each do |method|
        total_percentage = (method.total_time/total_time) * 100
        next if total_percentage < min_percent

        result = Hash.new
        result["calls"] = method.called
        result["total_time"] = method.total_time
        result["self_time"] = method.self_time
        result["children"] = get_children(method) unless method.children.empty?
        
        @result_yaml["threads"][thread_id]["methods"][method.full_name] = result
      end
    end
    
    def calculate_thread_times
      # Cache thread times since this is an expensive
      # operation with the required sorting
      @thread_times = {:total_time => 0.0, :threads => {}}
      @result.threads.each do |thread_id, methods|
        top = methods.max
        thread_time = [top.total_time, 0.01].max
        @thread_times[:threads][thread_id] = thread_time
      end
      @thread_times[:total_time] = [@thread_times[:threads].values.max, 0.01].max
    end
    
    def get_children(method)
      method.aggregate_children.sort_by(&:total_time).reverse.map { |c| c.target.full_name }
    end
    
    def print_result
      @output << YAML.dump(@result_yaml)
    end
  end
end
