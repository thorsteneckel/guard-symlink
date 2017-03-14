require 'guard/jobs/pry_wrapper'

Pry::Commands.create_command 'unlink_all' do
  group 'Guard'
  description 'Unlink all symlinks of watched directories.'

  banner <<-BANNER
  Usage: unlink_all <scope>
  Run the Guard plugin `unlink_all` action.
  You may want to specify an optional scope to the action,
  either the name of a Guard plugin or a plugin group.
  BANNER

  def process(*entries)
    scopes, unknown = ::Guard.state.session.convert_scope(entries)

    unless unknown.empty?
      output.puts "Unknown scopes: #{unknown.join(', ')}"
      return
    end

    ::Guard::Runner.new.run(:unlink_all, scopes)
  end
end
